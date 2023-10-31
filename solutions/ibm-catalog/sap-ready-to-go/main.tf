#####################################################
# Deploy SAP system ( 1 HANA instance and 0:N Netweaver Instance)
#####################################################

provider "ibm" {
  alias            = "ibm-pi"
  region           = lookup(local.ibm_powervs_zone_region_map, var.powervs_zone, null)
  zone             = var.powervs_zone
  ibmcloud_api_key = var.ibmcloud_api_key != null ? var.ibmcloud_api_key : null
}

module "sap_system" {
  source = "../../../modules/pi-sap-system-type1"
  providers = {
    ibm = ibm.ibm-pi
  }
  pi_workspace_guid           = local.powervs_workspace_guid
  pi_images                   = local.powervs_images
  powervs_zone                = var.powervs_zone
  powervs_resource_group_name = local.powervs_resource_group_name
  #powervs_workspace_name                 = local.powervs_workspace_name
  powervs_sshkey_name                    = local.powervs_sshkey_name
  prefix                                 = var.prefix
  ssh_private_key                        = var.ssh_private_key
  powervs_sap_network_cidr               = var.powervs_sap_network_cidr
  cloud_connection_count                 = local.cloud_connection_count
  additional_networks                    = local.additional_networks
  os_image_distro                        = var.os_image_distro
  powervs_create_separate_fs_share       = var.powervs_create_separate_fs_share
  powervs_hana_instance_name             = var.powervs_hana_instance_name
  powervs_hana_sap_profile_id            = var.powervs_hana_sap_profile_id
  powervs_netweaver_instance_count       = var.powervs_netweaver_instance_count
  powervs_netweaver_instance_name        = var.powervs_netweaver_instance_name
  powervs_netweaver_cpu_number           = var.powervs_netweaver_cpu_number
  powervs_netweaver_memory_size          = var.powervs_netweaver_memory_size
  access_host_or_ip                      = local.access_host_or_ip
  proxy_host_or_ip_port                  = local.proxy_host_or_ip_port
  dns_host_or_ip                         = local.dns_host_or_ip
  ntp_host_or_ip                         = local.ntp_host_or_ip
  nfs_host_or_ip_path                    = local.nfs_host_or_ip_path
  sap_domain                             = var.sap_domain
  powervs_share_storage_config           = var.powervs_share_storage_config
  powervs_hana_custom_storage_config     = var.powervs_hana_custom_storage_config
  powervs_hana_additional_storage_config = var.powervs_hana_additional_storage_config
  powervs_netweaver_storage_config       = var.powervs_netweaver_storage_config
  powervs_default_images                 = var.powervs_default_images
}
