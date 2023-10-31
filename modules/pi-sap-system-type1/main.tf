#####################################################
# Create SAP network for the SAP System
#####################################################

resource "ibm_pi_network" "sap_network" {
  pi_cloud_instance_id = var.pi_workspace_guid
  pi_network_name      = "${var.prefix}-net"
  pi_cidr              = var.powervs_sap_network_cidr
  pi_dns               = ["127.0.0.1"]
  pi_network_type      = "vlan"
  pi_network_jumbo     = true
}

module "powervs_attach_sap_network" {
  source  = "terraform-ibm-modules/powervs-workspace/ibm//modules/pi-cloudconnection-attach"
  version = "1.1.3"
  count   = local.per_enabled ? 0 : 1

  pi_workspace_guid         = var.pi_workspace_guid
  pi_private_subnet_ids     = [resource.ibm_pi_network.sap_network.network_id]
  pi_cloud_connection_count = 2
}

locals {
  powervs_sap_network = { "name" = "${var.prefix}-net", "cidr" = var.powervs_sap_network_cidr, "id" = resource.ibm_pi_network.sap_network.network_id }
  powervs_networks    = concat(var.additional_networks, [local.powervs_sap_network])
}

#####################################################
# Deploy share fs instance
#####################################################

/*locals {

  powervs_share_hostname    = "${var.prefix}-share"
  powervs_share_os_image    = var.os_image_distro == "SLES" ? var.powervs_default_images.sles_nw_image : var.powervs_default_images.rhel_nw_image
  powervs_share_os_image_id = lookup(var.pi_images, local.powervs_share_os_image, null)
}

module "powervs_sharefs_instance" {
  source  = "terraform-ibm-modules/powervs-instance/ibm"
  version = "1.0.1"
  count   = var.powervs_create_separate_fs_share ? 1 : 0

  pi_workspace_guid          = var.pi_workspace_guid
  pi_instance_name           = local.powervs_share_hostname
  pi_ssh_public_key_name     = var.powervs_sshkey_name
  pi_image_id                = local.powervs_share_os_image_id
  pi_networks                = local.powervs_networks
  pi_sap_profile_id          = null
  pi_number_of_processors    = "0.5"
  pi_memory_size             = "2"
  pi_server_type             = "s922"
  pi_cpu_proc_type           = "shared"
  pi_storage_config          = var.powervs_share_storage_config
  pi_instance_init_linux     = local.powervs_instance_init_linux
  pi_network_services_config = local.powervs_netweaver_network_services_config
}

module "sharefs_instance_init" {
  source     = "./submodule/sharefs_instance_init"
  depends_on = [module.powervs_sharefs_instance]
  count      = var.powervs_create_separate_fs_share ? 1 : 0

  access_host_or_ip = var.access_host_or_ip
  target_server_ip  = module.powervs_sharefs_instance[0].pi_instance_mgmt_ip
  ssh_private_key   = var.ssh_private_key
  service_config    = local.sharefs_nfs_server_config
} */

#####################################################
# Deploy SAP HANA Instance
#####################################################
locals {

  powervs_hana_hostname    = "${var.prefix}-${var.powervs_hana_instance_name}"
  powervs_hana_os_image    = var.os_image_distro == "SLES" ? var.powervs_default_images.sles_hana_image : var.powervs_default_images.rhel_hana_image
  powervs_hana_os_image_id = lookup(var.pi_images, local.powervs_hana_os_image, null)
}

module "powervs_hana_storage_calculation" {
  source                                 = "../pi-hana-storage-config"
  powervs_hana_sap_profile_id            = var.powervs_hana_sap_profile_id
  powervs_hana_additional_storage_config = var.powervs_hana_additional_storage_config
  powervs_hana_custom_storage_config     = var.powervs_hana_custom_storage_config
}

module "powervs_hana_instance" {
  source  = "terraform-ibm-modules/powervs-instance/ibm"
  version = "1.0.1"
  # insert the 5 required variables here

  pi_workspace_guid          = var.pi_workspace_guid
  pi_instance_name           = local.powervs_hana_hostname
  pi_ssh_public_key_name     = var.powervs_sshkey_name
  pi_image_id                = local.powervs_hana_os_image_id
  pi_networks                = local.powervs_networks
  pi_sap_profile_id          = var.powervs_hana_sap_profile_id
  pi_storage_config          = module.powervs_hana_storage_calculation.hana_storage_config
  pi_instance_init_linux     = local.powervs_instance_init_linux
  pi_network_services_config = local.powervs_network_services_config
}

locals {
  powervs_hana_instance_ips    = split(", ", module.powervs_hana_instance.pi_instance_private_ips)
  powervs_hana_instance_sap_ip = local.powervs_hana_instance_ips[index([for ip in local.powervs_hana_instance_ips : alltrue([for i, v in split(".", ip) : tonumber(split(".", cidrhost(local.powervs_sap_network.cidr, 0))[i]) <= tonumber(v) && tonumber(v) <= tonumber(split(".", cidrhost(local.powervs_sap_network.cidr, -1))[i])])], true)]
}

/*locals {
  powervs_hana_instance_ips    = split(", ", module.powervs_hana_instance.pi_instance_private_ips)
  powervs_hana_instance_sap_ip = local.powervs_hana_instance_ips[index([for ip in local.powervs_hana_instance_ips : alltrue([for i, v in split(".", ip) : tonumber(split(".", cidrhost(local.powervs_sap_network.cidr, 0))[i]) <= tonumber(v) && tonumber(v) <= tonumber(split(".", cidrhost(local.powervs_sap_network.cidr, -1))[i])])], true)]
}
#####################################################
# Deploy SAP Netweaver Instance
#####################################################

locals {

  powervs_netweaver_hostname       = "${var.prefix}-${var.powervs_netweaver_instance_name}"
  powervs_netweaver_os_image       = var.os_image_distro == "SLES" ? var.powervs_default_images.sles_nw_image : var.powervs_default_images.rhel_nw_image
  powervs_netweaver_os_image_id = lookup(var.pi_images, local.powervs_netweaver_os_image, null)
  netweaver_sapmnt_storage         = [{ "name" : "sapmnt", "size" : "300", "count" : "1", "tier" : "tier3", "mount" : "/sapmnt" }]
  powervs_netweaver_storage_config = var.powervs_create_separate_fs_share ? var.powervs_netweaver_storage_config : concat(var.powervs_netweaver_storage_config, local.netweaver_sapmnt_storage)

}

module "powervs_netweaver_instance" {
  source  = "terraform-ibm-modules/powervs-instance/ibm"
  version = "1.0.1"
  depends_on = [module.sharefs_instance_init]
  count      = var.powervs_netweaver_instance_count

  pi_workspace_guid          = var.pi_workspace_guid
  pi_instance_name           = "${local.powervs_netweaver_hostname}-${count.index + 1}"
  pi_ssh_public_key_name     = var.powervs_sshkey_name
  pi_image_id                = local.powervs_netweaver_os_image_id
  pi_networks                = local.powervs_networks
  pi_sap_profile_id          = null
  pi_number_of_processors    = var.powervs_netweaver_cpu_number
  pi_memory_size             = var.powervs_netweaver_memory_size
  pi_server_type             = "s922"
  pi_cpu_proc_type           = "shared"
  pi_storage_config          = local.powervs_netweaver_storage_config
  pi_instance_init_linux     = local.powervs_instance_init_linux
  pi_network_services_config = local.powervs_netweaver_network_services_config
}

#####################################################
# Prepare OS for SAP
#####################################################

locals {
  target_server_ips = concat([module.powervs_hana_instance.pi_instance_mgmt_ip], module.powervs_netweaver_instance[*].pi_instance_mgmt_ip)
  sap_solutions     = concat(["HANA"], [for ip in module.powervs_netweaver_instance[*].pi_instance_mgmt_ip : "NETWEAVER"])
}

module "ansible_sap_instance_init" {

  source     = "../ansible-sap-instance-init"
  depends_on = [module.powervs_hana_instance, module.powervs_netweaver_instance]

  access_host_or_ip = local.access_host_or_ip
  target_server_ips = local.target_server_ips
  ssh_private_key   = var.ssh_private_key
  sap_solutions     = local.sap_solutions
  sap_domain        = var.sap_domain

}

moved {
  from = module.sap_instance_init
  to   = module.ansible_sap_instance_init
}
*/
