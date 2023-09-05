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
  powervs_default_images      = merge(var.powervs_default_images, { "sles_hana_image" : "SLES15-SP4-SAP", "sles_nw_image" : "SLES15-SP4-SAP-NETWEAVER" })
}


#####################################################
# Deploy PowerVS SAP instance
# ( 1 HANA instance and 1 Netweaver Instance)
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
  powervs_create_separate_fs_share       = var.powervs_create_separate_fs_share
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
  powervs_default_images                 = local.powervs_default_images
}

#####################################################
# COS Service credentials
# Download HANA binaries and SAP Solution binaries
# from COS to nfs host
#####################################################

locals {
  cos_service_credentials  = jsondecode(var.cos_service_credentials)
  cos_apikey               = local.cos_service_credentials.apikey
  cos_resource_instance_id = local.cos_service_credentials.resource_instance_id
}

locals {
  nfs_directory = split(":", local.nfs_host_or_ip_path)[1]

  cos_hana_configuration = {
    cos_apikey               = local.cos_apikey
    cos_region               = var.cos_configuration.cos_region
    cos_resource_instance_id = local.cos_resource_instance_id
    cos_bucket_name          = var.cos_configuration.cos_bucket_name
    cos_dir_name             = var.cos_configuration.cos_hana_software_path
    download_dir_path        = local.nfs_directory
  }

  cos_solution_configuration = {
    cos_apikey               = local.cos_apikey
    cos_region               = var.cos_configuration.cos_region
    cos_resource_instance_id = local.cos_resource_instance_id
    cos_bucket_name          = var.cos_configuration.cos_bucket_name
    cos_dir_name             = var.cos_configuration.cos_solution_software_path
    download_dir_path        = local.nfs_directory
  }
}

module "cos_download_hana_binaries" {
  source            = "../../../modules/ibmcloud_cos"
  access_host_or_ip = local.access_host_or_ip
  target_server_ip  = local.ntp_host_or_ip
  ssh_private_key   = var.ssh_private_key
  cos_configuration = local.cos_hana_configuration
}

module "cos_download_netweaver_binaries" {
  source            = "../../../modules/ibmcloud_cos"
  depends_on        = [module.cos_download_hana_binaries]
  access_host_or_ip = local.access_host_or_ip
  target_server_ip  = local.ntp_host_or_ip
  ssh_private_key   = var.ssh_private_key
  cos_configuration = local.cos_solution_configuration
}


#####################################################
# Install HANA DB
#####################################################

locals {
  ansible_sap_hana_playbook_vars = {
    sap_hana_install_software_directory = "${local.nfs_directory}/${var.cos_configuration.cos_hana_software_path}"
    sap_hana_install_sid                = var.ansible_sap_hana_vars.sap_hana_install_sid
    sap_hana_install_number             = var.ansible_sap_hana_vars.sap_hana_install_number
    sap_hana_install_master_password    = var.sap_hana_install_master_password
  }
}

module "ansible_sap_install_hana" {
  source                    = "../../../modules/ansible_sap_install_all"
  depends_on                = [module.cos_download_hana_binaries, module.sap_system]
  access_host_or_ip         = local.access_host_or_ip
  target_server_ip          = module.sap_system.powervs_hana_instance_management_ip
  ssh_private_key           = var.ssh_private_key
  ansible_vault_password    = var.ansible_vault_password
  ansible_sap_solution_vars = local.ansible_sap_hana_playbook_vars
  solution_template         = "s4b4_hana"
}


####################################################
# Install Netweaver solution
#####################################################

locals {
  product_catalog_map = {
    "s4hana-2020"  = "NW_ABAP_OneHost:S4HANA2020.CORE.HDB.ABAP"
    "s4hana-2021"  = "NW_ABAP_OneHost:S4HANA2021.CORE.HDB.ABAP"
    "s4hana-2022"  = "NW_ABAP_OneHost:S4HANA2022.CORE.HDB.ABAP"
    "bw4hana-2021" = "NW_ABAP_OneHost:BW4HANA2021.CORE.HDB.ABAP"
  }

  ansible_sap_solution_playbook_vars = {
    sap_swpm_product_catalog_id        = lookup(local.product_catalog_map, var.sap_solution)
    sap_install_media_detect_directory = "${local.nfs_directory}/${var.cos_configuration.cos_solution_software_path}"
    sap_swpm_sid                       = var.ansible_sap_solution_vars.sap_swpm_sid
    sap_swpm_pas_instance_nr           = var.ansible_sap_solution_vars.sap_swpm_pas_instance_nr
    sap_swpm_ascs_instance_nr          = var.ansible_sap_solution_vars.sap_swpm_ascs_instance_nr
    sap_swpm_mp_stack_path             = var.ansible_sap_solution_vars.sap_swpm_mp_stack_path
    sap_swpm_mp_stack_file_name        = var.ansible_sap_solution_vars.sap_swpm_mp_stack_file_name
    sap_swpm_configure_tms             = var.ansible_sap_solution_vars.sap_swpm_configure_tms
    sap_swpm_tms_tr_files_path         = var.ansible_sap_solution_vars.sap_swpm_tms_tr_files_path
    sap_swpm_master_password           = var.sap_swpm_master_password
    sap_swpm_ascs_instance_hostname    = "${var.prefix}-${var.powervs_netweaver_instance_name}-1"
    sap_domain                         = var.sap_domain
    sap_swpm_db_host                   = "${var.prefix}-${var.powervs_hana_instance_name}"
    sap_swpm_db_ip                     = module.sap_system.powervs_hana_instance_sap_ip
    sap_swpm_db_sid                    = var.ansible_sap_hana_vars.sap_hana_install_sid
    sap_swpm_db_instance_nr            = var.ansible_sap_hana_vars.sap_hana_install_number
    sap_swpm_db_master_password        = var.sap_hana_install_master_password
  }
}

module "ansible_sap_install_netweaver" {
  source                    = "../../../modules/ansible_sap_install_all"
  depends_on                = [module.cos_download_netweaver_binaries, module.ansible_sap_install_hana]
  access_host_or_ip         = local.access_host_or_ip
  target_server_ip          = module.sap_system.powervs_netweaver_instance_management_ips
  ssh_private_key           = var.ssh_private_key
  ansible_vault_password    = var.ansible_vault_password
  ansible_sap_solution_vars = local.ansible_sap_solution_playbook_vars
  solution_template         = "s4b4_solution"
}
