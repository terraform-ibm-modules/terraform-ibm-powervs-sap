locals {
  ibm_powervs_zone_region_map = {
    "lon04"    = "lon"
    "lon06"    = "lon"
    "eu-de-1"  = "eu-de"
    "eu-de-2"  = "eu-de"
    "tor01"    = "tor"
    "mon01"    = "mon"
    "osa21"    = "osa"
    "tok04"    = "tok"
    "syd04"    = "syd"
    "syd05"    = "syd"
    "sao01"    = "sao"
    "us-south" = "us-south"
    "dal10"    = "us-south"
    "dal12"    = "us-south"
    "us-east"  = "us-east"
  }
}

provider "ibm" {
  region           = lookup(local.ibm_powervs_zone_region_map, var.powervs_zone, null)
  zone             = var.powervs_zone
  ibmcloud_api_key = var.ibmcloud_api_key != null ? var.ibmcloud_api_key : null
}

#####################################################
# Get Values from Infrastructure Workspace
#####################################################

locals {
  location = regex("^[a-z/-]+", var.prerequisite_workspace_id)
}

data "ibm_schematics_workspace" "schematics_workspace" {
  workspace_id = var.prerequisite_workspace_id
  location     = local.location
}

data "ibm_schematics_output" "schematics_output" {
  workspace_id = var.prerequisite_workspace_id
  location     = local.location
  template_id  = data.ibm_schematics_workspace.schematics_workspace.runtime_data[0].id
}

locals {
  powerinfra_output = jsondecode(data.ibm_schematics_output.schematics_output.output_json)

  powervs_resource_group_name = local.powerinfra_output[0].powervs_resource_group_name.value
  powervs_workspace_name      = local.powerinfra_output[0].powervs_workspace_name.value
  powervs_sshkey_name         = local.powerinfra_output[0].powervs_sshkey_name.value
  cloud_connection_count      = local.powerinfra_output[0].cloud_connection_count.value
  additional_networks         = [local.powerinfra_output[0].powervs_management_network_name.value, local.powerinfra_output[0].powervs_backup_network_name.value]
  access_host_or_ip           = local.powerinfra_output[0].access_host_or_ip.value
  proxy_host_or_ip_port       = local.powerinfra_output[0].proxy_host_or_ip_port.value
  dns_host_or_ip              = local.powerinfra_output[0].dns_host_or_ip.value
  ntp_host_or_ip              = local.powerinfra_output[0].ntp_host_or_ip.value
  nfs_host_or_ip_path         = local.powerinfra_output[0].nfs_host_or_ip_path.value
}

#####################################################
# Deploy PowerVS SAP instance ( 1 HANA instance and 1 Netweaver Instance)
#####################################################
module "sap_system" {
  source                                 = "../../sap-ready-to-go/module"
  powervs_zone                           = var.powervs_zone
  powervs_resource_group_name            = local.powervs_resource_group_name
  powervs_workspace_name                 = local.powervs_workspace_name
  powervs_sshkey_name                    = local.powervs_sshkey_name
  prefix                                 = var.prefix
  ssh_private_key                        = var.ssh_private_key
  powervs_sap_network_cidr               = var.powervs_sap_network_cidr
  cloud_connection_count                 = local.cloud_connection_count
  additional_networks                    = local.additional_networks
  os_image_distro                        = "RHEL"
  powervs_create_separate_fs_share       = false
  powervs_hana_instance_name             = var.powervs_hana_instance_name
  powervs_hana_sap_profile_id            = var.powervs_hana_sap_profile_id
  powervs_netweaver_instance_count       = "1"
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

#####################################################
# Download HANA binaries from COS to nfs host
#####################################################

locals {
  nfs_directory = split(":", local.nfs_host_or_ip_path)[1]
  cos_hana_configuration = {
    cos_apikey               = var.cos_configuration.cos_apikey
    cos_region               = var.cos_configuration.cos_region
    cos_resource_instance_id = var.cos_configuration.cos_resource_instance_id
    cos_bucket_name          = var.cos_configuration.cos_bucket_name
    cos_dir_name             = var.cos_configuration.cos_hana_software_path
    download_dir_path        = local.nfs_directory
  }
}

module "cos_download_hana_binaries" {
  source            = "../../../modules/ibmcloud_cos"
  depends_on        = [module.sap_system]
  access_host_or_ip = local.access_host_or_ip
  target_server_ip  = local.ntp_host_or_ip
  ssh_private_key   = var.ssh_private_key
  cos_configuration = local.cos_hana_configuration
}


#####################################################
# Install HANA DB
#####################################################

locals {
  sap_hana_playbook_vars = {
    sap_hana_install_software_directory = "${local.nfs_directory}/${var.cos_configuration.cos_hana_software_path}"
    sap_hana_install_sid                = var.sap_hana_vars.sap_hana_install_sid
    sap_hana_install_number             = var.sap_hana_vars.sap_hana_install_number
    sap_hana_install_master_password    = var.sap_hana_vars.sap_hana_install_master_password
  }
}

module "sap_install_hana" {
  source                 = "../../../modules/sap_install_hanadb"
  depends_on             = [module.cos_download_hana_binaries]
  access_host_or_ip      = local.access_host_or_ip
  target_server_ip       = module.sap_system.powervs_hana_instance_management_ip
  ssh_private_key        = var.ssh_private_key
  ansible_vault_password = var.ansible_vault_password
  sap_hana_vars          = local.sap_hana_playbook_vars
  hana_template          = "s4hana"
}
/*
#####################################################
# Download Solution(S4HANA/Bw4HANA) binaries from COS to nfs host
#####################################################

locals {
  cos_solution_configuration = {
    cos_apikey               = var.cos_configuration.cos_apikey
    cos_region               = var.cos_configuration.cos_region
    cos_resource_instance_id = var.cos_configuration.cos_resource_instance_id
    cos_bucket_name          = var.cos_configuration.cos_bucket_name
    cos_dir_name             = var.cos_configuration.cos_solution_software_path
    download_dir_path        = local.nfs_directory
  }
}

module "cos_download_netweaver_binaries" {
  source            = "../../../modules/ibmcloud_cos"
  depends_on        = [module.sap_system]
  access_host_or_ip = local.access_host_or_ip
  target_server_ip  = local.ntp_host_or_ip
  ssh_private_key   = var.ssh_private_key
  cos_configuration = local.cos_solution_configuration
}

####################################################
# Install Netweaver solution
#####################################################

locals {
  sap_solution_vars = {
    sap_hana_install_software_directory = "${local.nfs_directory}/${var.cos_configuration.cos_hana_software_path}"



    sap_hana_install_sid             = var.sap_hana_vars.sap_hana_install_sid
    sap_hana_install_number          = var.sap_hana_vars.sap_hana_install_number
    sap_hana_install_master_password = var.sap_hana_vars.sap_hana_install_master_password
  }
}

module "sap_install_netweaver" {
  source                 = "../../../modules/sap_install_solutions"
  depends_on             = [module.cos_download_hana_binaries]
  access_host_or_ip      = local.access_host_or_ip
  target_server_ip       = module.sap_system.powervs_nw_instance_management_ip
  ssh_private_key        = var.ssh_private_key
  ansible_vault_password = var.ansible_vault_password
  sap_hana_vars          = local.sap_solution_vars
}
*/
