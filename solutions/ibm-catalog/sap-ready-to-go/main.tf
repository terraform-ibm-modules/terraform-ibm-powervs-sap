#######################################################
# Power Virtual Server with VPC landing zone module
# VPC landing zone
# PowerVS Workspace
#######################################################

module "standard" {
  source  = "terraform-ibm-modules/powervs-infrastructure/ibm//modules/powervs-vpc-landing-zone"
  version = "9.0.1"

  providers = {
    ibm.ibm-is = ibm.ibm-is
    ibm.ibm-pi = ibm.ibm-pi
    ibm.ibm-sm = ibm.ibm-sm
  }

  powervs_zone                                 = var.powervs_zone
  powervs_resource_group_name                  = var.powervs_resource_group_name
  prefix                                       = var.prefix
  external_access_ip                           = var.external_access_ip
  vpc_intel_images                             = var.vpc_intel_images
  ssh_public_key                               = var.ssh_public_key
  ssh_private_key                              = var.ssh_private_key
  powervs_management_network                   = var.powervs_management_network
  powervs_backup_network                       = var.powervs_backup_network
  configure_dns_forwarder                      = true
  configure_ntp_forwarder                      = true
  configure_nfs_server                         = true
  nfs_server_config                            = var.nfs_server_config
  dns_forwarder_config                         = { "dns_servers" : "161.26.0.7; 161.26.0.8; 9.9.9.9;" }
  tags                                         = var.tags
  powervs_custom_images                        = var.powervs_custom_images
  powervs_custom_image_cos_configuration       = var.powervs_custom_image_cos_configuration
  powervs_custom_image_cos_service_credentials = var.powervs_custom_image_cos_service_credentials
  client_to_site_vpn                           = var.client_to_site_vpn
  sm_service_plan                              = var.sm_service_plan
  existing_sm_instance_guid                    = var.existing_sm_instance_guid
  existing_sm_instance_region                  = var.existing_sm_instance_region
  enable_monitoring                            = var.enable_monitoring
  existing_monitoring_instance_crn             = var.existing_monitoring_instance_crn
  enable_scc_wp                                = var.enable_scc_wp
  ansible_vault_password                       = var.ansible_vault_password
}


#######################################################
# Power Virtual Server SAP ready-to-go
# Deploy SAP system
# 1 HANA instance
# 0:N NetWeaver Instance
# SAP instance Init
#######################################################

module "sap_system" {
  source    = "../../../modules/pi-sap-system-type1"
  providers = { ibm = ibm.ibm-pi }

  prefix                                 = var.prefix
  pi_workspace_guid                      = module.standard.powervs_workspace_guid
  pi_region                              = var.powervs_zone
  pi_ssh_public_key_name                 = module.standard.powervs_ssh_public_key.name
  pi_networks                            = []
  pi_sap_network_cidr                    = var.powervs_sap_network_cidr
  pi_hana_instance                       = local.powervs_hana_instance
  pi_hana_instance_custom_storage_config = var.powervs_hana_instance_custom_storage_config
  pi_netweaver_instance                  = local.powervs_netweaver_instance
  pi_instance_init_linux                 = local.powervs_instance_init_linux
  sap_network_services_config            = local.powervs_network_services_config
  sap_domain                             = var.sap_domain
  ansible_vault_password                 = var.ansible_vault_password
}
