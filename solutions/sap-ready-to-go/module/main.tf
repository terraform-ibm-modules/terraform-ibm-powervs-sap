#####################################################
# Get Values from Infrastructure Workspace
#####################################################

locals {

  powervs_resource_group_name = var.powervs_resource_group_name
  powervs_workspace_name      = var.powervs_workspace_name
  powervs_sshkey_name         = var.powervs_sshkey_name
  access_host_or_ip           = var.access_host_or_ip
  cloud_connection_count      = var.cloud_connection_count
  proxy_host_or_ip_port       = var.proxy_host_or_ip_port
  ntp_host_or_ip              = var.ntp_host_or_ip
  dns_host_or_ip              = var.dns_host_or_ip
  nfs_host_or_ip_path         = var.nfs_host_or_ip_path
}

#####################################################
# Prepare locals for SAP systems
#####################################################

locals {

  powervs_sap_network = { "name" = "${var.prefix}-net", "cidr" = var.powervs_sap_network_cidr }
  powervs_networks    = concat(var.additional_networks, [local.powervs_sap_network.name])
  powervs_instance_init = {
    enable            = true
    access_host_or_ip = local.access_host_or_ip
    ssh_private_key   = var.ssh_private_key
  }
  powervs_proxy_settings = {
    proxy_host_or_ip_port = local.proxy_host_or_ip_port
    no_proxy_hosts        = "161.0.0.0/8,10.0.0.0/8"
  }
  powervs_network_services_config = {
    nfs = { enable = local.nfs_host_or_ip_path != "" ? true : false, nfs_server_path = local.nfs_host_or_ip_path, nfs_client_path = "/nfs" }
    dns = { enable = local.dns_host_or_ip != "" ? true : false, dns_server_ip = local.dns_host_or_ip }
    ntp = { enable = local.ntp_host_or_ip != "" ? true : false, ntp_server_ip = local.ntp_host_or_ip }
  }

}

#####################################################
# Create SAP network for the SAP System
#####################################################

module "powervs_create_sap_network" {
  source       = "../../../modules/powervs_create_private_network"
  powervs_zone = var.powervs_zone

  powervs_resource_group_name = local.powervs_resource_group_name
  powervs_workspace_name      = local.powervs_workspace_name
  powervs_sap_network         = local.powervs_sap_network
}

module "powervs_attach_sap_network" {
  source     = "../../../modules/powervs_attach_private_network"
  depends_on = [module.powervs_create_sap_network]

  powervs_zone                   = var.powervs_zone
  powervs_resource_group_name    = local.powervs_resource_group_name
  powervs_workspace_name         = local.powervs_workspace_name
  powervs_sap_network_name       = local.powervs_sap_network.name
  powervs_cloud_connection_count = local.cloud_connection_count
}

#####################################################
# Deploy share fs instance
#####################################################

locals {

  powervs_share_hostname = "${var.prefix}-share"
  powervs_share_os_image = var.os_image_distro == "SLES" ? var.powervs_default_images.sles_nw_image : var.powervs_default_images.rhel_nw_image
}

module "powervs_sharefs_instance" {
  source     = "git::https://github.com/terraform-ibm-modules/terraform-ibm-powervs-instance.git?ref=v0.2.6"
  depends_on = [module.powervs_attach_sap_network]
  count      = var.powervs_create_separate_fs_share ? 1 : 0

  pi_zone                    = var.powervs_zone
  pi_resource_group_name     = local.powervs_resource_group_name
  pi_workspace_name          = local.powervs_workspace_name
  pi_sshkey_name             = local.powervs_sshkey_name
  pi_instance_name           = local.powervs_share_hostname
  pi_os_image_name           = local.powervs_share_os_image
  pi_networks                = local.powervs_networks
  pi_sap_profile_id          = null
  pi_number_of_processors    = "0.5"
  pi_memory_size             = "2"
  pi_server_type             = "s922"
  pi_cpu_proc_type           = "shared"
  pi_storage_config          = var.powervs_share_storage_config
  pi_instance_init           = local.powervs_instance_init
  pi_proxy_settings          = local.powervs_proxy_settings
  pi_network_services_config = local.powervs_network_services_config

}

#####################################################
# Deploy SAP HANA Instance
#####################################################

locals {

  powervs_hana_hostname = "${var.prefix}-${var.powervs_hana_instance_name}"
  powervs_hana_os_image = var.os_image_distro == "SLES" ? var.powervs_default_images.sles_hana_image : var.powervs_default_images.rhel_hana_image
}

module "powervs_hana_storage_calculation" {

  source                                 = "../../../modules/powervs_hana_storage_config"
  powervs_hana_sap_profile_id            = var.powervs_hana_sap_profile_id
  powervs_hana_additional_storage_config = var.powervs_hana_additional_storage_config
  powervs_hana_custom_storage_config     = var.powervs_hana_custom_storage_config
}

module "powervs_hana_instance" {
  source     = "git::https://github.com/terraform-ibm-modules/terraform-ibm-powervs-instance.git?ref=v0.2.6"
  depends_on = [module.powervs_attach_sap_network]

  pi_zone                    = var.powervs_zone
  pi_resource_group_name     = local.powervs_resource_group_name
  pi_workspace_name          = local.powervs_workspace_name
  pi_sshkey_name             = local.powervs_sshkey_name
  pi_instance_name           = local.powervs_hana_hostname
  pi_os_image_name           = local.powervs_hana_os_image
  pi_networks                = local.powervs_networks
  pi_sap_profile_id          = var.powervs_hana_sap_profile_id
  pi_storage_config          = module.powervs_hana_storage_calculation.hana_storage_config
  pi_instance_init           = local.powervs_instance_init
  pi_proxy_settings          = local.powervs_proxy_settings
  pi_network_services_config = local.powervs_network_services_config

}

#####################################################
# Deploy SAP Netweaver Instance
#####################################################

locals {

  powervs_netweaver_hostname = "${var.prefix}-${var.powervs_netweaver_instance_name}"
  powervs_netweaver_os_image = var.os_image_distro == "SLES" ? var.powervs_default_images.sles_nw_image : var.powervs_default_images.rhel_nw_image
}

module "powervs_netweaver_instance" {
  source     = "git::https://github.com/terraform-ibm-modules/terraform-ibm-powervs-instance.git?ref=v0.2.6"
  depends_on = [module.powervs_attach_sap_network]
  count      = var.powervs_netweaver_instance_count

  pi_zone                    = var.powervs_zone
  pi_resource_group_name     = local.powervs_resource_group_name
  pi_workspace_name          = local.powervs_workspace_name
  pi_sshkey_name             = local.powervs_sshkey_name
  pi_instance_name           = "${local.powervs_netweaver_hostname}-${count.index + 1}"
  pi_os_image_name           = local.powervs_netweaver_os_image
  pi_networks                = local.powervs_networks
  pi_sap_profile_id          = null
  pi_number_of_processors    = var.powervs_netweaver_cpu_number
  pi_memory_size             = var.powervs_netweaver_memory_size
  pi_server_type             = "s922"
  pi_cpu_proc_type           = "shared"
  pi_storage_config          = var.powervs_netweaver_storage_config
  pi_instance_init           = local.powervs_instance_init
  pi_proxy_settings          = local.powervs_proxy_settings
  pi_network_services_config = local.powervs_network_services_config

}

#####################################################
# Prepare OS for SAP
#####################################################

locals {
  target_server_ips = concat([module.powervs_hana_instance.pi_instance_mgmt_ip], module.powervs_netweaver_instance[*].pi_instance_mgmt_ip)
  sap_solutions     = concat(["HANA"], [for ip in module.powervs_netweaver_instance[*].pi_instance_mgmt_ip : "NETWEAVER"])
}

module "sap_instance_init" {

  source     = "../../../modules/sap_instance_init"
  depends_on = [module.powervs_hana_instance, module.powervs_netweaver_instance]

  access_host_or_ip = local.access_host_or_ip
  target_server_ips = local.target_server_ips
  sap_solutions     = local.sap_solutions
  ssh_private_key   = var.ssh_private_key
  sap_domain        = var.sap_domain
}