#####################################################
# Deploy SAP system 
# 1 HANA instance 
# 0:N Netweaver Instance
# 1 Optional Sharefs instance
#####################################################

module "sap_system" {
  source = "../../../modules/pi-sap-system-type1"

  pi_zone                                    = var.powervs_zone
  prefix                                     = var.prefix
  pi_workspace_guid                          = local.powervs_workspace_guid
  pi_ssh_public_key_name                     = local.powervs_sshkey_name
  pi_networks                                = local.powervs_networks
  pi_sap_network_cidr                        = var.powervs_sap_network_cidr
  cloud_connection_count                     = local.cloud_connection_count
  pi_create_separate_fsshare_instance        = false
  pi_fsshare_instance_image_id               = local.powervs_fsshare_instance_image_id
  pi_fsshare_instance_cpu_number             = "0.5"
  pi_fsshare_instance_memory_size            = "2"
  pi_fsshare_instance_cpu_proc_type          = "shared"
  pi_fsshare_instance_storage_config         = null
  pi_hana_instance_name                      = var.powervs_hana_instance_name
  pi_hana_instance_sap_profile_id            = var.powervs_hana_sap_profile_id
  pi_hana_instance_image_id                  = local.powervs_hana_os_image
  pi_hana_instance_custom_storage_config     = var.powervs_hana_custom_storage_config
  pi_hana_instance_additional_storage_config = var.powervs_hana_additional_storage_config
  pi_netweaver_instance_count                = var.powervs_netweaver_instance_count
  pi_netweaver_instance_name                 = var.powervs_netweaver_instance_name
  pi_netweaver_instance_image_id             = local.powervs_netweaver_instance_image_id
  pi_netweaver_instance_cpu_number           = var.powervs_netweaver_cpu_number
  pi_netweaver_instance_memory_size          = var.powervs_netweaver_memory_size
  pi_netweaver_instance_cpu_proc_type        = "shared"
  pi_netweaver_instance_storage_config       = var.powervs_netweaver_storage_config
  pi_instance_init_linux                     = local.powervs_instance_init_linux
  sap_network_services_config                = local.powervs_network_services_config
  sap_domain                                 = var.sap_domain

}
