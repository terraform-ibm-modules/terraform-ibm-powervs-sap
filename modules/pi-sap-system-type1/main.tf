#####################################################
# Create SAP network for the SAP System
#####################################################

resource "ibm_pi_network" "sap_network" {
  pi_cloud_instance_id = var.pi_workspace_guid
  pi_network_name      = "${var.prefix}-net"
  pi_cidr              = var.pi_sap_network_cidr
  pi_dns               = ["127.0.0.1"]
  pi_network_type      = "vlan"
  pi_network_jumbo     = true
}

#####################################################
# Non PER DC: Attach the SAP network to CCs
#####################################################

locals {
  per_enabled_dc_list = ["dal10"]
  per_enabled         = contains(local.per_enabled_dc_list, var.pi_zone)
}

module "pi_attach_sap_network" {
  source  = "terraform-ibm-modules/powervs-workspace/ibm//modules/pi-cloudconnection-attach"
  version = "1.2.0"
  count   = local.per_enabled ? 0 : 1

  pi_workspace_guid         = var.pi_workspace_guid
  pi_private_subnet_ids     = [resource.ibm_pi_network.sap_network.network_id]
  pi_cloud_connection_count = var.cloud_connection_count
}

locals {
  pi_sap_network = { "name" = "${var.prefix}-net", "cidr" = var.pi_sap_network_cidr, "id" = ibm_pi_network.sap_network.network_id }
  pi_networks    = concat(var.pi_networks, [local.pi_sap_network])
}


##########################################################################################################
# Deploy sharefs instance
##########################################################################################################

locals {
  pi_sharefs_instance_name = "${var.prefix}-${var.pi_sharefs_instance.name}"
}

module "pi_sharefs_instance" {
  source  = "terraform-ibm-modules/powervs-instance/ibm"
  version = "1.0.2"
  count   = var.pi_sharefs_instance.enable ? 1 : 0

  pi_workspace_guid          = var.pi_workspace_guid
  pi_instance_name           = local.pi_sharefs_instance_name
  pi_ssh_public_key_name     = var.pi_ssh_public_key_name
  pi_image_id                = var.pi_sharefs_instance.image_id
  pi_networks                = local.pi_networks
  pi_sap_profile_id          = null
  pi_number_of_processors    = var.pi_sharefs_instance.processors
  pi_memory_size             = var.pi_sharefs_instance.memory
  pi_server_type             = "s922"
  pi_cpu_proc_type           = var.pi_sharefs_instance.proc_type
  pi_storage_config          = var.pi_sharefs_instance.storage_config
  pi_instance_init_linux     = var.pi_instance_init_linux
  pi_network_services_config = var.sap_network_services_config
}

# Configuration for sharefs instance as NFS server
locals {
  valid_sharefs_nfs_config = var.pi_sharefs_instance.enable && var.pi_sharefs_instance.storage_config != null ? var.pi_sharefs_instance.storage_config[0].name != "" ? true : false : false
  pi_sharefs_instance_nfs_server_config = {
    nfs = {
      enable = local.valid_sharefs_nfs_config ? true : false,
      nfs_file_system = local.valid_sharefs_nfs_config ? [
        for volume in var.pi_sharefs_instance.storage_config :
        { name       = volume.name,
          mount_path = volume.mount,
          size       = volume.size
        }
    ] : [] }
  }
}

module "ansible_sharefs_instance_exportfs" {
  source     = "../remote-exec-ansible"
  depends_on = [module.pi_sharefs_instance]
  count      = var.pi_sharefs_instance.enable ? 1 : 0

  bastion_host               = var.pi_instance_init_linux.bastion_host_ip
  host                       = module.pi_sharefs_instance[0].pi_instance_primary_ip
  ssh_private_key            = var.pi_instance_init_linux.ssh_private_key
  src_script_template_name   = "ansible_exec.sh.tftpl"
  dst_script_file_name       = "configure_nfs_server.sh"
  src_playbook_template_name = "playbook-configure-network-services.yml.tftpl"
  dst_playbook_file_name     = "playbook-configure-nfs-server.yml"
  playbook_template_content  = { server_config = jsonencode(local.pi_sharefs_instance_nfs_server_config), client_config = jsonencode({}) }
}


##########################################################################################################
# Deploy SAP HANA Instance
##########################################################################################################

locals {
  pi_hana_instance_name = "${var.prefix}-${var.pi_hana_instance.name}"
}

module "pi_hana_storage_calculation" {
  source                                     = "../pi-hana-storage-config"
  pi_hana_instance_sap_profile_id            = var.pi_hana_instance.sap_profile_id
  pi_hana_instance_additional_storage_config = var.pi_hana_instance.additional_storage_config
  pi_hana_instance_custom_storage_config     = var.pi_hana_instance_custom_storage_config
}

module "pi_hana_instance" {
  source  = "terraform-ibm-modules/powervs-instance/ibm"
  version = "1.0.2"

  pi_workspace_guid          = var.pi_workspace_guid
  pi_instance_name           = local.pi_hana_instance_name
  pi_ssh_public_key_name     = var.pi_ssh_public_key_name
  pi_image_id                = var.pi_hana_instance.image_id
  pi_networks                = local.pi_networks
  pi_sap_profile_id          = var.pi_hana_instance.sap_profile_id
  pi_storage_config          = module.pi_hana_storage_calculation.pi_hana_storage_config
  pi_instance_init_linux     = var.pi_instance_init_linux
  pi_network_services_config = var.sap_network_services_config
}

locals {
  pi_hana_instance_ips    = split(", ", module.pi_hana_instance.pi_instance_private_ips)
  pi_hana_instance_sap_ip = local.pi_hana_instance_ips[index([for ip in local.pi_hana_instance_ips : alltrue([for i, v in split(".", ip) : tonumber(split(".", cidrhost(var.pi_sap_network_cidr, 0))[i]) <= tonumber(v) && tonumber(v) <= tonumber(split(".", cidrhost(var.pi_sap_network_cidr, -1))[i])])], true)]
}


##########################################################################################################
# Deploy SAP NetWeaver Instances
##########################################################################################################

locals {

  pi_netweaver_instance_name           = "${var.prefix}-${var.pi_netweaver_instance.name}"
  pi_netweaver_instance_sapmnt_storage = [{ "name" : "sapmnt", "size" : "300", "count" : "1", "tier" : "tier3", "mount" : "/sapmnt" }]
  pi_netweaver_instance_storage_config = var.pi_sharefs_instance.enable ? var.pi_netweaver_instance.storage_config : concat(var.pi_netweaver_instance.storage_config, local.pi_netweaver_instance_sapmnt_storage)
}

resource "time_sleep" "wait_1_min" {
  depends_on      = [ibm_pi_network.sap_network]
  create_duration = "60s"
}

module "pi_netweaver_instance" {
  source     = "terraform-ibm-modules/powervs-instance/ibm"
  version    = "1.0.2"
  count      = var.pi_netweaver_instance.instance_count
  depends_on = [time_sleep.wait_1_min]

  pi_workspace_guid          = var.pi_workspace_guid
  pi_instance_name           = "${local.pi_netweaver_instance_name}-${count.index + 1}"
  pi_ssh_public_key_name     = var.pi_ssh_public_key_name
  pi_image_id                = var.pi_netweaver_instance.image_id
  pi_networks                = local.pi_networks
  pi_sap_profile_id          = null
  pi_number_of_processors    = var.pi_netweaver_instance.processors
  pi_memory_size             = var.pi_netweaver_instance.memory
  pi_server_type             = "s922"
  pi_cpu_proc_type           = var.pi_netweaver_instance.proc_type
  pi_storage_config          = local.pi_netweaver_instance_storage_config
  pi_instance_init_linux     = var.pi_instance_init_linux
  pi_network_services_config = var.sap_network_services_config
}

locals {
  pi_netweaver_instance_sapmnt_config = {
    nfs = {
      enable          = local.valid_sharefs_nfs_config ? true : false,
      nfs_server_path = local.valid_sharefs_nfs_config ? join(";", [for volume in var.pi_sharefs_instance.storage_config : "${module.pi_sharefs_instance[0].pi_instance_primary_ip}:${volume.mount}"]) : "",
      nfs_client_path = local.valid_sharefs_nfs_config ? join(";", [for volume in var.pi_sharefs_instance.storage_config : volume.mount]) : ""
    }
  }
}

module "ansible_netweaver_sapmnt_mount" {

  source     = "../remote-exec-ansible"
  depends_on = [module.ansible_sharefs_instance_exportfs, module.pi_netweaver_instance]
  count      = var.pi_sharefs_instance.enable && local.valid_sharefs_nfs_config ? var.pi_netweaver_instance.instance_count : 0

  bastion_host               = var.pi_instance_init_linux.bastion_host_ip
  host                       = module.pi_netweaver_instance[count.index].pi_instance_primary_ip
  ssh_private_key            = var.pi_instance_init_linux.ssh_private_key
  src_script_template_name   = "ansible_exec.sh.tftpl"
  dst_script_file_name       = "sapmnt_mount.sh"
  src_playbook_template_name = "playbook-configure-network-services.yml.tftpl"
  dst_playbook_file_name     = "playbook-configure-sapmnt.yml"
  playbook_template_content  = { server_config = jsonencode({}), client_config = jsonencode(local.pi_netweaver_instance_sapmnt_config) }
}


#####################################################
# Prepare OS for SAP
#####################################################

locals {
  target_server_ips = concat([module.pi_hana_instance.pi_instance_primary_ip], module.pi_netweaver_instance[*].pi_instance_primary_ip)
  sap_solutions     = concat(["HANA"], [for ip in module.pi_netweaver_instance[*].pi_instance_primary_ip : "NETWEAVER"])
}

module "ansible_sap_instance_init" {

  source     = "../remote-exec-ansible"
  depends_on = [module.pi_hana_instance, module.pi_netweaver_instance, module.ansible_netweaver_sapmnt_mount]
  count      = length(local.target_server_ips)

  bastion_host               = var.pi_instance_init_linux.bastion_host_ip
  host                       = local.target_server_ips[count.index]
  ssh_private_key            = var.pi_instance_init_linux.ssh_private_key
  src_script_template_name   = "ansible_exec.sh.tftpl"
  dst_script_file_name       = "configure_os_for_sap.sh"
  src_playbook_template_name = "playbook-configure-os-for-sap.yml.tftpl"
  dst_playbook_file_name     = "playbook-configure-os-for-sap.yml"
  playbook_template_content  = { sap_solution = local.sap_solutions[count.index], sap_domain = var.sap_domain }
}
