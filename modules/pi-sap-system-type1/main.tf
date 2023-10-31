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

module "pi_attach_sap_network" {
  source  = "terraform-ibm-modules/powervs-workspace/ibm//modules/pi-cloudconnection-attach"
  version = "1.1.3"
  count   = local.per_enabled ? 0 : 1

  pi_workspace_guid         = var.pi_workspace_guid
  pi_private_subnet_ids     = [resource.ibm_pi_network.sap_network.network_id]
  pi_cloud_connection_count = 2
}

locals {
  pi_sap_network = { "name" = "${var.prefix}-net", "cidr" = var.pi_sap_network_cidr, "id" = ibm_pi_network.sap_network.network_id }
  pi_networks    = concat(var.pi_networks, [local.pi_sap_network])
}

##########################################################################################################
# Deploy fsshare instance
##########################################################################################################

locals {
  pi_fsshare_instance_name = "${var.prefix}-share"
}

module "pi_fsshare_instance" {
  source  = "terraform-ibm-modules/powervs-instance/ibm"
  version = "1.0.1"
  count   = var.pi_create_separate_fsshare_instance ? 1 : 0

  pi_workspace_guid          = var.pi_workspace_guid
  pi_instance_name           = local.pi_fsshare_instance_name
  pi_ssh_public_key_name     = var.pi_ssh_public_key_name
  pi_image_id                = var.pi_fsshare_instance_image_id
  pi_networks                = local.pi_networks
  pi_sap_profile_id          = null
  pi_number_of_processors    = var.pi_fsshare_instance_cpu_number
  pi_memory_size             = var.pi_fsshare_instance_memory_size
  pi_server_type             = "s922"
  pi_cpu_proc_type           = var.pi_fsshare_instance_cpu_proc_type
  pi_storage_config          = var.pi_fsshare_instance_storage_config
  pi_instance_init_linux     = var.pi_instance_init_linux
  pi_network_services_config = var.sap_network_services_config
}

module "ansible_fsshare_instance_init" {
  source     = "./submodule/sharefs_instance_init"
  depends_on = [module.pi_fsshare_instance]
  count      = var.pi_create_separate_fsshare_instance ? 1 : 0

  access_host_or_ip = var.pi_instance_init_linux.bastion_host_ip
  target_server_ip  = module.pi_fsshare_instance[0].pi_instance_primary_ip
  ssh_private_key   = var.pi_instance_init_linux.ssh_private_key
  service_config    = local.fsshare_nfs_server_config
}


##########################################################################################################
# Deploy SAP HANA Instance
##########################################################################################################

locals {
  pi_hana_instance_name = "${var.prefix}-${var.pi_hana_instance_name}"
}

module "pi_hana_storage_calculation" {
  source                                     = "../pi-hana-storage-config"
  pi_hana_instance_sap_profile_id            = var.pi_hana_instance_sap_profile_id
  pi_hana_instance_additional_storage_config = var.pi_hana_instance_additional_storage_config
  pi_hana_instance_custom_storage_config     = var.pi_hana_instance_custom_storage_config
}

module "pi_hana_instance" {
  source  = "terraform-ibm-modules/powervs-instance/ibm"
  version = "1.0.1"

  pi_workspace_guid          = var.pi_workspace_guid
  pi_instance_name           = local.pi_hana_instance_name
  pi_ssh_public_key_name     = var.pi_ssh_public_key_name
  pi_image_id                = var.pi_hana_instance_image_id
  pi_networks                = local.pi_networks
  pi_sap_profile_id          = var.pi_hana_instance_sap_profile_id
  pi_storage_config          = module.pi_hana_storage_calculation.pi_hana_storage_config
  pi_instance_init_linux     = var.pi_instance_init_linux
  pi_network_services_config = var.sap_network_services_config
}

locals {
  pi_hana_instance_ips    = split(", ", module.pi_hana_instance.pi_instance_private_ips)
  pi_hana_instance_sap_ip = local.pi_hana_instance_ips[index([for ip in local.pi_hana_instance_ips : alltrue([for i, v in split(".", ip) : tonumber(split(".", cidrhost(var.pi_sap_network_cidr, 0))[i]) <= tonumber(v) && tonumber(v) <= tonumber(split(".", cidrhost(var.pi_sap_network_cidr, -1))[i])])], true)]
}


##########################################################################################################
# Deploy SAP Netweaver Instances
##########################################################################################################

locals {

  pi_netweaver_instance_name           = "${var.prefix}-${var.pi_netweaver_instance_name}"
  pi_netweaver_instance_sapmnt_storage = [{ "name" : "sapmnt", "size" : "300", "count" : "1", "tier" : "tier3", "mount" : "/sapmnt" }]
  pi_netweaver_instance_storage_config = var.pi_create_separate_fsshare_instance ? var.pi_netweaver_instance_storage_config : concat(var.pi_netweaver_instance_storage_config, local.pi_netweaver_instance_sapmnt_storage)
}

module "pi_netweaver_instance" {
  source     = "terraform-ibm-modules/powervs-instance/ibm"
  version    = "1.0.1"
  depends_on = [module.ansible_fsshare_instance_init]
  count      = var.pi_netweaver_instance_count

  pi_workspace_guid          = var.pi_workspace_guid
  pi_instance_name           = "${local.pi_netweaver_instance_name}-${count.index + 1}"
  pi_ssh_public_key_name     = var.pi_ssh_public_key_name
  pi_image_id                = var.pi_netweaver_instance_image_id
  pi_networks                = local.pi_networks
  pi_sap_profile_id          = null
  pi_number_of_processors    = var.pi_netweaver_instance_cpu_number
  pi_memory_size             = var.pi_netweaver_instance_memory_size
  pi_server_type             = "s922"
  pi_cpu_proc_type           = var.pi_netweaver_instance_cpu_proc_type
  pi_storage_config          = local.pi_netweaver_instance_storage_config
  pi_instance_init_linux     = var.pi_instance_init_linux
  pi_network_services_config = local.pi_netweaver_network_services_config
}


#####################################################
# Prepare OS for SAP
#####################################################

locals {
  target_server_ips = concat([module.pi_hana_instance.pi_instance_primary_ip], module.pi_netweaver_instance[*].pi_instance_primary_ip)
  sap_solutions     = concat(["HANA"], [for ip in module.pi_netweaver_instance[*].pi_instance_primary_ip : "NETWEAVER"])
}

module "ansible_sap_instance_init" {

  source     = "../ansible-sap-instance-init"
  depends_on = [module.pi_hana_instance, module.pi_netweaver_instance]
  count      = length(local.target_server_ips)

  access_host_or_ip = var.pi_instance_init_linux.bastion_host_ip
  target_server_ip  = local.target_server_ips[count.index]
  ssh_private_key   = var.pi_instance_init_linux.ssh_private_key
  sap_solution      = local.sap_solutions[count.index]
  sap_domain        = var.sap_domain

}



moved {
  from = module.sap_instance_init
  to   = module.ansible_sap_instance_init
}


moved {
  from = module.powervs_sharefs_instance
  to   = module.pi_fsshare_instance
}

moved {
  from = module.powervs_hana_storage_calculation
  to   = module.pi_hana_storage_calculation
}


moved {
  from = module.powervs_hana_instance
  to   = module.pi_hana_instance
}

moved {
  from = module.powervs_netweaver_instance
  to   = module.pi_netweaver_instance
}
