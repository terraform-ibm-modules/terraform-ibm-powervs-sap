#######################################################
# Power Virtual Server with VPC landing zone module
# VPC landing zone
# PowerVS Workspace
# Transit Gateway, CCs, PowerVS catalog images
#######################################################

module "standard" {
  source  = "terraform-ibm-modules/powervs-infrastructure/ibm//modules/powervs-vpc-landing-zone"
  version = "9.0.0"

  providers = { ibm.ibm-is = ibm.ibm-is, ibm.ibm-pi = ibm.ibm-pi, ibm.ibm-sm = ibm.ibm-sm }

  powervs_zone                = var.powervs_zone
  prefix                      = var.prefix
  external_access_ip          = var.external_access_ip
  ssh_public_key              = var.ssh_public_key
  ssh_private_key             = var.ssh_private_key
  vpc_intel_images            = var.vpc_intel_images
  powervs_resource_group_name = var.powervs_resource_group_name
  configure_dns_forwarder     = var.configure_dns_forwarder
  configure_ntp_forwarder     = var.configure_ntp_forwarder
  configure_nfs_server        = var.configure_nfs_server
  enable_monitoring           = false
  enable_scc_wp               = false
  client_to_site_vpn          = { enable = false, client_ip_pool = "", vpn_client_access_group_users = [] }
}


resource "time_sleep" "wait_15_mins" {
  create_duration = "900s"
}


#######################################################
# Power Virtual Server SAP ready-to-go
# Deploy SAP system
# 1 HANA instance
# 0:N NetWeaver Instance
# SAP instance Init
#######################################################

data "ibm_pi_catalog_images" "catalog_images_ds" {
  provider             = ibm.ibm-pi
  pi_cloud_instance_id = module.standard.powervs_workspace_guid
  sap                  = true
}

locals {
  powervs_networks           = [module.standard.powervs_management_subnet, module.standard.powervs_backup_subnet]
  powervs_hana_os_image      = var.os_image_distro == "SLES" ? var.powervs_default_sap_images.sles_hana_image : var.powervs_default_sap_images.rhel_hana_image
  powervs_netweaver_os_image = var.os_image_distro == "SLES" ? var.powervs_default_sap_images.sles_nw_image : var.powervs_default_sap_images.rhel_nw_image

  powervs_hana_instance = merge(var.powervs_hana_instance, { image_id = one([
    for img in data.ibm_pi_catalog_images.catalog_images_ds.images :
    img.image_id if img.name == local.powervs_hana_os_image
  ]) })
  powervs_netweaver_instance = merge(var.powervs_netweaver_instance, { image_id = one([
    for img in data.ibm_pi_catalog_images.catalog_images_ds.images :
    img.image_id if img.name == local.powervs_netweaver_os_image
  ]) })

  powervs_instance_init_linux = {
    enable             = true
    bastion_host_ip    = module.standard.access_host_or_ip
    ansible_host_or_ip = module.standard.ansible_host_or_ip
    ssh_private_key    = var.ssh_private_key
  }

  sap_network_services_config = {
    squid = { enable = true, squid_server_ip_port = module.standard.proxy_host_or_ip_port
    no_proxy_hosts = "161.0.0.0/8,10.0.0.0/8" }
    nfs = { enable = var.configure_nfs_server, nfs_server_path = module.standard.nfs_host_or_ip_path, nfs_client_path = "/nfs", opts = module.standard.network_services_config.nfs.opts, fstype = module.standard.network_services_config.nfs.fstype }
    dns = { enable = var.configure_dns_forwarder, dns_server_ip = module.standard.dns_host_or_ip }
    ntp = { enable = var.configure_ntp_forwarder, ntp_server_ip = module.standard.ntp_host_or_ip }
  }
}

module "sap_system" {
  source     = "../../modules/pi-sap-system-type1"
  depends_on = [time_sleep.wait_15_mins]
  providers  = { ibm = ibm.ibm-pi }

  prefix                                 = var.prefix
  pi_workspace_guid                      = module.standard.powervs_workspace_guid
  pi_region                              = var.powervs_zone
  pi_ssh_public_key_name                 = module.standard.powervs_ssh_public_key.name
  pi_networks                            = local.powervs_networks
  pi_sap_network_cidr                    = var.powervs_sap_network_cidr
  pi_hana_instance                       = local.powervs_hana_instance
  pi_hana_instance_custom_storage_config = var.powervs_hana_instance_custom_storage_config
  pi_netweaver_instance                  = local.powervs_netweaver_instance
  pi_instance_init_linux                 = local.powervs_instance_init_linux
  sap_network_services_config            = local.sap_network_services_config
  sap_domain                             = var.sap_domain

}
