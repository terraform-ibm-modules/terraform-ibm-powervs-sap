#####################################################
# Create SAP network for the SAP System
#####################################################

resource "ibm_pi_network" "sap_network" {
  pi_cloud_instance_id = var.pi_workspace_guid
  pi_network_name      = "${var.prefix}-sap-net"
  pi_cidr              = var.pi_sap_network_cidr
  pi_network_type      = "vlan"
  pi_network_mtu       = 9000
}

locals {
  pi_sap_network = { "name" = "${var.prefix}-net", "cidr" = var.pi_sap_network_cidr, "id" = ibm_pi_network.sap_network.network_id }
  pi_networks    = concat(var.pi_networks, [local.pi_sap_network])
}

#####################################################
# Set server type based on region
#####################################################
locals {
  p10_unsupported_regions = ["che01", "lon04", "lon06", "mon01", "syd04", "syd05", "tor01", "us-east"] # datacenters that don't support P10 yet
  server_type             = contains(local.p10_unsupported_regions, var.pi_region) ? "s922" : "s1022"
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
  version = "2.7.0"

  pi_workspace_guid          = var.pi_workspace_guid
  pi_instance_name           = local.pi_hana_instance_name
  pi_ssh_public_key_name     = var.pi_ssh_public_key_name
  pi_image_id                = var.pi_hana_instance.image_id
  pi_networks                = local.pi_networks
  pi_sap_profile_id          = var.pi_hana_instance.sap_profile_id
  pi_boot_image_storage_tier = "tier3"
  pi_storage_config          = module.pi_hana_storage_calculation.pi_hana_storage_config
  pi_instance_init_linux     = var.pi_instance_init_linux
  pi_network_services_config = var.sap_network_services_config
  ansible_vault_password     = var.ansible_vault_password
}

locals {
  pi_hana_instance_ips    = split(", ", module.pi_hana_instance.pi_instance_private_ips)
  pi_hana_instance_sap_ip = local.pi_hana_instance_ips[index([for ip in local.pi_hana_instance_ips : alltrue([for i, v in split(".", ip) : tonumber(split(".", cidrhost(var.pi_sap_network_cidr, 0))[i]) <= tonumber(v) && tonumber(v) <= tonumber(split(".", cidrhost(var.pi_sap_network_cidr, -1))[i])])], true)]
}


##########################################################################################################
# Deploy SAP NetWeaver Instances
##########################################################################################################

locals {
  pi_netweaver_instance_name                   = "${var.prefix}-${var.pi_netweaver_instance.name}"
  pi_netweaver_instance_sapmnt_storage         = [{ "name" : "sapmnt", "size" : "300", "count" : "1", "tier" : "tier3", "mount" : "/sapmnt" }]
  pi_netweaver_primary_instance_storage_config = concat(var.pi_netweaver_instance.storage_config, local.pi_netweaver_instance_sapmnt_storage)
  pi_netweaver_primary_instance_nfs_server_config = {
    nfs = {
      enable      = var.pi_netweaver_instance.instance_count > 1,
      directories = var.pi_netweaver_instance.instance_count > 1 ? [local.pi_netweaver_instance_sapmnt_storage[0].mount] : []
    }
  }
}

resource "time_sleep" "wait_1_min" {
  depends_on      = [ibm_pi_network.sap_network]
  create_duration = "60s"
}

module "pi_netweaver_primary_instance" {
  source     = "terraform-ibm-modules/powervs-instance/ibm"
  version    = "2.7.0"
  count      = var.pi_netweaver_instance.instance_count > 0 ? 1 : 0
  depends_on = [time_sleep.wait_1_min]

  pi_workspace_guid          = var.pi_workspace_guid
  pi_instance_name           = "${local.pi_netweaver_instance_name}-${count.index + 1}"
  pi_ssh_public_key_name     = var.pi_ssh_public_key_name
  pi_image_id                = var.pi_netweaver_instance.image_id
  pi_networks                = local.pi_networks
  pi_sap_profile_id          = null
  pi_boot_image_storage_tier = "tier3"
  pi_number_of_processors    = var.pi_netweaver_instance.processors
  pi_memory_size             = var.pi_netweaver_instance.memory
  pi_server_type             = local.server_type
  pi_cpu_proc_type           = var.pi_netweaver_instance.proc_type
  pi_storage_config          = local.pi_netweaver_primary_instance_storage_config
  pi_instance_init_linux     = var.pi_instance_init_linux
  pi_network_services_config = var.sap_network_services_config
  ansible_vault_password     = var.ansible_vault_password
}

module "ansible_pi_netweaver_primary_instance_exportfs" {

  source                 = "../ansible"
  depends_on             = [module.pi_netweaver_primary_instance]
  count                  = var.pi_netweaver_instance.instance_count > 1 ? 1 : 0
  bastion_host_ip        = var.pi_instance_init_linux.bastion_host_ip
  ansible_host_or_ip     = var.pi_instance_init_linux.ansible_host_or_ip
  ssh_private_key        = var.pi_instance_init_linux.ssh_private_key
  configure_ansible_host = false

  src_script_template_name = "configure-network-services/ansible_exec.sh.tftpl"
  dst_script_file_name     = "${local.sap_instance_names[count.index]}_configure_nfs_server.sh"

  src_playbook_template_name = "configure-network-services/playbook-configure-network-services.yml.tftpl"
  dst_playbook_file_name     = "${local.sap_instance_names[count.index]}-playbook-configure-nfs-server.yml"
  playbook_template_vars = {
    "server_config" : jsonencode(local.pi_netweaver_primary_instance_nfs_server_config),
    "client_config" : jsonencode({})
  }

  src_inventory_template_name = "pi-instance-inventory.tftpl"
  dst_inventory_file_name     = "pi-netweaver-primary-instance-inventory"
  inventory_template_vars     = { "pi_instance_management_ip" : module.pi_netweaver_primary_instance[0].pi_instance_primary_ip }
}

module "pi_netweaver_secondary_instances" {
  source     = "terraform-ibm-modules/powervs-instance/ibm"
  version    = "2.7.0"
  count      = var.pi_netweaver_instance.instance_count > 1 ? var.pi_netweaver_instance.instance_count - 1 : 0
  depends_on = [time_sleep.wait_1_min]

  pi_workspace_guid          = var.pi_workspace_guid
  pi_instance_name           = "${local.pi_netweaver_instance_name}-${count.index + 2}"
  pi_ssh_public_key_name     = var.pi_ssh_public_key_name
  pi_image_id                = var.pi_netweaver_instance.image_id
  pi_networks                = local.pi_networks
  pi_sap_profile_id          = null
  pi_boot_image_storage_tier = "tier3"
  pi_number_of_processors    = var.pi_netweaver_instance.processors
  pi_memory_size             = var.pi_netweaver_instance.memory
  pi_server_type             = local.server_type
  pi_cpu_proc_type           = var.pi_netweaver_instance.proc_type
  pi_storage_config          = var.pi_netweaver_instance.storage_config
  pi_instance_init_linux     = var.pi_instance_init_linux
  pi_network_services_config = var.sap_network_services_config
  ansible_vault_password     = var.ansible_vault_password
}

locals {
  pi_netweaver_instance_sapmnt_config = {
    nfs = {
      enable          = var.pi_netweaver_instance.instance_count > 1 ? true : false,
      nfs_server_path = var.pi_netweaver_instance.instance_count > 1 ? "${module.pi_netweaver_primary_instance[0].pi_instance_primary_ip}:${local.pi_netweaver_instance_sapmnt_storage[0].mount}" : "",
      nfs_client_path = var.pi_netweaver_instance.instance_count > 1 ? local.pi_netweaver_instance_sapmnt_storage[0].mount : "",
      opts            = "sec=sys,nfsvers=4.1,nofail",
      fstype          = "nfs4"
    }
  }
}

module "ansible_pi_netweaver_secondary_instances_sapmnt_mount" {

  source                 = "../ansible"
  depends_on             = [module.pi_netweaver_primary_instance, module.ansible_pi_netweaver_primary_instance_exportfs, module.pi_netweaver_secondary_instances]
  count                  = var.pi_netweaver_instance.instance_count > 1 ? 1 : 0
  bastion_host_ip        = var.pi_instance_init_linux.bastion_host_ip
  ansible_host_or_ip     = var.pi_instance_init_linux.ansible_host_or_ip
  ssh_private_key        = var.pi_instance_init_linux.ssh_private_key
  configure_ansible_host = false

  src_script_template_name = "configure-network-services/ansible_exec.sh.tftpl"
  dst_script_file_name     = "pi-netweaver-secondary-instances_sapmnt_mount.sh"

  src_playbook_template_name = "configure-network-services/playbook-configure-network-services.yml.tftpl"
  dst_playbook_file_name     = "pi-netweaver-secondary-instances-playbook-configure-sapmnt.yml"
  playbook_template_vars = {
    "server_config" : jsonencode({}),
    "client_config" : jsonencode(local.pi_netweaver_instance_sapmnt_config)
  }

  src_inventory_template_name = "pi-instance-inventory.tftpl"
  dst_inventory_file_name     = "pi-netweaver-secondary-instances-inventory"
  inventory_template_vars     = { "pi_instance_management_ip" : join("\n", module.pi_netweaver_secondary_instances[*].pi_instance_primary_ip) }
}

#####################################################
# Configure OS for SAP
#####################################################

locals {
  target_server_ips  = concat([module.pi_hana_instance.pi_instance_primary_ip], module.pi_netweaver_primary_instance[*].pi_instance_primary_ip)
  sap_solutions      = concat(["HANA"], [for ip in module.pi_netweaver_primary_instance[*].pi_instance_primary_ip : "NETWEAVER"])
  sap_instance_names = concat([local.pi_hana_instance_name], module.pi_netweaver_primary_instance[*].pi_instance_name)
}

module "ansible_sap_instance_init" {

  source                 = "../ansible"
  depends_on             = [module.pi_hana_instance, module.ansible_pi_netweaver_primary_instance_exportfs, module.ansible_pi_netweaver_secondary_instances_sapmnt_mount]
  count                  = length(local.target_server_ips)
  bastion_host_ip        = var.pi_instance_init_linux.bastion_host_ip
  ansible_host_or_ip     = var.pi_instance_init_linux.ansible_host_or_ip
  ssh_private_key        = var.pi_instance_init_linux.ssh_private_key
  configure_ansible_host = false

  src_script_template_name = "configure-os-for-sap/ansible_exec.sh.tftpl"
  dst_script_file_name     = "${local.sap_instance_names[count.index]}_configure_os_for_sap.sh"

  src_playbook_template_name = "configure-os-for-sap/playbook-configure-os-for-sap.yml.tftpl"
  dst_playbook_file_name     = "${local.sap_instance_names[count.index]}-playbook-configure-os-for-sap.yml"
  playbook_template_vars = {
    "sap_solution" : local.sap_solutions[count.index],
    "sap_domain" : var.sap_domain
  }

  src_inventory_template_name = "pi-instance-inventory.tftpl"
  dst_inventory_file_name     = "${local.sap_instance_names[count.index]}-instance-inventory"
  inventory_template_vars     = { "pi_instance_management_ip" : local.target_server_ips[count.index] }
}

#######################################################################
# Ansible Install Sysdig agent and connect to SCC Workload Protection
#######################################################################
module "configure_scc_wp_agent" {

  source     = "../ansible"
  depends_on = [module.ansible_sap_instance_init]
  count      = var.scc_wp_instance.enable ? 1 : 0

  bastion_host_ip        = var.pi_instance_init_linux.bastion_host_ip
  ansible_host_or_ip     = var.pi_instance_init_linux.ansible_host_or_ip
  ssh_private_key        = var.pi_instance_init_linux.ssh_private_key
  ansible_vault_password = var.ansible_vault_password
  configure_ansible_host = false

  src_script_template_name = "configure-scc-wp-agent/ansible_configure_scc_wp_agent.sh.tftpl"
  dst_script_file_name     = "${var.prefix}-configure_scc_wp_agent.sh"

  src_playbook_template_name = "configure-scc-wp-agent/playbook-configure-scc-wp-agent.yml.tftpl"
  dst_playbook_file_name     = "${var.prefix}-playbook-configure-scc-wp-agent.yml"
  playbook_template_vars = {
    COLLECTOR_ENDPOINT : var.scc_wp_instance.ingestion_endpoint,
    API_ENDPOINT : var.scc_wp_instance.api_endpoint,
    ACCESS_KEY : var.scc_wp_instance.access_key
  }
  src_inventory_template_name = "pi-instance-inventory.tftpl"
  dst_inventory_file_name     = "${var.prefix}-scc-wp-inventory"
  inventory_template_vars     = { "pi_instance_management_ip" : join("\n", [module.pi_hana_instance.pi_instance_primary_ip], var.pi_netweaver_instance.instance_count > 0 ? module.pi_netweaver_primary_instance[*].pi_instance_primary_ip : [], var.pi_netweaver_instance.instance_count > 1 ? module.pi_netweaver_secondary_instances[*].pi_instance_primary_ip : []) }
}
