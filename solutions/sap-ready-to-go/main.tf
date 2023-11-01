
#####################################################
# Deploy SAP system
# 1 HANA instance
# 0:N Netweaver Instance
# 1 Optional Sharefs instance
#####################################################

module "sap_system" {
  source = "../../modules/pi-sap-system-type1"

  pi_zone                                = var.powervs_zone
  prefix                                 = var.prefix
  pi_workspace_guid                      = var.powervs_workspace_guid
  pi_ssh_public_key_name                 = var.powervs_ssh_public_key_name
  pi_networks                            = var.powervs_networks
  pi_sap_network_cidr                    = var.powervs_sap_network_cidr
  cloud_connection_count                 = var.cloud_connection_count
  pi_sharefs_instance                    = var.powervs_sharefs_instance
  pi_hana_instance                       = var.powervs_hana_instance
  pi_hana_instance_custom_storage_config = var.powervs_hana_instance_custom_storage_config
  pi_netweaver_instance                  = var.powervs_netweaver_instance
  pi_instance_init_linux                 = var.powervs_instance_init_linux
  sap_network_services_config            = var.sap_network_services_config
  sap_domain                             = var.sap_domain

}
