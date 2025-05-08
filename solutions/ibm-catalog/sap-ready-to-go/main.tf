#####################################################
# Deploy SAP system
# 1 HANA instance
# 0:N NetWeaver Instance
#####################################################
locals {
  powervs_hana_instance = {
    name                      = var.powervs_hana_instance_name
    image_id                  = local.hana_image_id
    sap_profile_id            = var.powervs_hana_instance_sap_profile_id
    additional_storage_config = var.powervs_hana_instance_additional_storage_config
  }

  powervs_netweaver_instance = {
    instance_count = var.powervs_netweaver_instance_count
    name           = var.powervs_netweaver_instance_name
    image_id       = local.netweaver_image_id
    processors     = var.powervs_netweaver_cpu_number
    memory         = var.powervs_netweaver_memory_size
    proc_type      = "shared"
    storage_config = var.powervs_netweaver_instance_storage_config
  }
}

module "sap_system" {
  source = "../../../modules/pi-sap-system-type1"

  prefix                                 = var.prefix
  pi_workspace_guid                      = local.powervs_workspace_guid
  pi_region                              = var.powervs_zone
  pi_ssh_public_key_name                 = local.powervs_sshkey_name
  pi_networks                            = local.powervs_networks
  pi_sap_network_cidr                    = var.powervs_sap_network_cidr
  pi_hana_instance                       = local.powervs_hana_instance
  pi_hana_instance_custom_storage_config = var.powervs_hana_instance_custom_storage_config
  pi_netweaver_instance                  = local.powervs_netweaver_instance
  pi_instance_init_linux                 = local.powervs_instance_init_linux
  sap_network_services_config            = local.powervs_network_services_config
  sap_domain                             = var.sap_domain
  ansible_vault_password                 = var.ansible_vault_password
  scc_wp_instance                        = local.scc_wp_instance
}
