
#####################################################
# Deploy SAP system
# 1 HANA instance
# 0:N NetWeaver Instance
#####################################################

locals {
  powervs_hana_instance      = merge(var.powervs_hana_instance, { image_id = var.powervs_hana_instance_image_id })
  powervs_netweaver_instance = merge(var.powervs_netweaver_instance, { image_id = var.powervs_netweaver_instance_image_id })
}

module "sap_system" {
  source = "../../modules/pi-sap-system-type1"

  prefix                                 = var.prefix
  pi_workspace_guid                      = var.powervs_workspace_guid
  pi_region                              = var.powervs_zone
  pi_ssh_public_key_name                 = var.powervs_ssh_public_key_name
  pi_networks                            = var.powervs_networks
  pi_sap_network_cidr                    = var.powervs_sap_network_cidr
  pi_hana_instance                       = local.powervs_hana_instance
  pi_hana_instance_custom_storage_config = var.powervs_hana_instance_custom_storage_config
  pi_netweaver_instance                  = local.powervs_netweaver_instance
  pi_instance_init_linux                 = var.powervs_instance_init_linux
  sap_network_services_config            = var.sap_network_services_config
  sap_domain                             = var.sap_domain
  ansible_vault_password                 = var.ansible_vault_password
  scc_wp_instance                        = var.scc_wp_instance
}
