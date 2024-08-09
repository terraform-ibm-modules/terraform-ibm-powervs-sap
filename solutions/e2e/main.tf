#######################################################
# Power Virtual Server with VPC landing zone module
# VPC landing zone
# PowerVS Workspace
# Transit Gateway, CCs, PowerVS catalog images
#######################################################

module "powervs_infra" {
  source  = "terraform-ibm-modules/powervs-infrastructure/ibm//modules/powervs-vpc-landing-zone"
  version = "6.0.0"

  providers = { ibm.ibm-is = ibm.ibm-is, ibm.ibm-pi = ibm.ibm-pi, ibm.ibm-sm = ibm.ibm-sm }

  powervs_zone                = var.powervs_zone
  prefix                      = var.prefix
  external_access_ip          = var.external_access_ip
  ssh_public_key              = var.ssh_public_key
  ssh_private_key             = var.ssh_private_key
  powervs_resource_group_name = var.powervs_resource_group_name
  configure_dns_forwarder     = var.configure_dns_forwarder
  configure_ntp_forwarder     = var.configure_ntp_forwarder
  configure_nfs_server        = var.configure_nfs_server
  powervs_image_names         = ["SLES15-SP5-SAP", "RHEL9-SP2-SAP", "SLES15-SP5-SAP-NETWEAVER", "RHEL9-SP2-SAP-NETWEAVER"]
}

resource "time_sleep" "wait_10_mins" {
  create_duration = "600s"
}
#######################################################
# Power Virtual Server SAP ready-to-go
# Deploy SAP system
# 1 HANA instance
# 0:N NetWeaver Instance
# 1 Optional Sharefs instance
# SAP instance Init
#######################################################

locals {
  powervs_networks           = [module.powervs_infra.powervs_management_subnet, module.powervs_infra.powervs_backup_subnet]
  powervs_sharefs_os_image   = var.os_image_distro == "SLES" ? var.powervs_default_sap_images.sles_nw_image : var.powervs_default_sap_images.rhel_nw_image
  powervs_hana_os_image      = var.os_image_distro == "SLES" ? var.powervs_default_sap_images.sles_hana_image : var.powervs_default_sap_images.rhel_hana_image
  powervs_netweaver_os_image = var.os_image_distro == "SLES" ? var.powervs_default_sap_images.sles_nw_image : var.powervs_default_sap_images.rhel_nw_image

  powervs_sharefs_instance   = merge(var.powervs_sharefs_instance, { enable = var.powervs_create_separate_sharefs_instance, image_id = lookup(module.powervs_infra.powervs_images, local.powervs_sharefs_os_image, null) })
  powervs_hana_instance      = merge(var.powervs_hana_instance, { image_id = lookup(module.powervs_infra.powervs_images, local.powervs_hana_os_image, null) })
  powervs_netweaver_instance = merge(var.powervs_netweaver_instance, { image_id = lookup(module.powervs_infra.powervs_images, local.powervs_netweaver_os_image, null) })

  powervs_instance_init_linux = {
    enable             = true
    bastion_host_ip    = module.powervs_infra.access_host_or_ip
    ansible_host_or_ip = module.powervs_infra.ansible_host_or_ip
    ssh_private_key    = var.ssh_private_key
  }

  sap_network_services_config = {
    squid = { enable = true, squid_server_ip_port = module.powervs_infra.proxy_host_or_ip_port
    no_proxy_hosts = "161.0.0.0/8,10.0.0.0/8" }
    nfs = { enable = var.configure_nfs_server, nfs_server_path = module.powervs_infra.nfs_host_or_ip_path, nfs_client_path = "/nfs", opts = module.powervs_infra.network_services_config.nfs.opts, fstype = module.powervs_infra.network_services_config.nfs.fstype }
    dns = { enable = var.configure_dns_forwarder, dns_server_ip = module.powervs_infra.dns_host_or_ip }
    ntp = { enable = var.configure_ntp_forwarder, ntp_server_ip = module.powervs_infra.ntp_host_or_ip }
  }
}

module "sap_system" {
  source     = "../../modules/pi-sap-system-type1"
  depends_on = [time_sleep.wait_10_mins]
  providers  = { ibm = ibm.ibm-pi }

  prefix                                 = var.prefix
  pi_workspace_guid                      = module.powervs_infra.powervs_workspace_guid
  pi_ssh_public_key_name                 = module.powervs_infra.powervs_ssh_public_key.name
  pi_networks                            = local.powervs_networks
  pi_sap_network_cidr                    = var.powervs_sap_network_cidr
  pi_sharefs_instance                    = local.powervs_sharefs_instance
  pi_hana_instance                       = local.powervs_hana_instance
  pi_hana_instance_custom_storage_config = var.powervs_hana_instance_custom_storage_config
  pi_netweaver_instance                  = local.powervs_netweaver_instance
  pi_instance_init_linux                 = local.powervs_instance_init_linux
  sap_network_services_config            = local.sap_network_services_config
  sap_domain                             = var.sap_domain

}
