locals {
  ibm_powervs_zone_region_map = {
    "syd04"    = "syd"
    "syd05"    = "syd"
    "eu-de-1"  = "eu-de"
    "eu-de-2"  = "eu-de"
    "lon04"    = "lon"
    "lon06"    = "lon"
    "wdc04"    = "us-east"
    "us-east"  = "us-east"
    "us-south" = "us-south"
    "dal12"    = "us-south"
    "dal13"    = "us-south"
    "tor01"    = "tor"
    "tok04"    = "tok"
    "osa21"    = "osa"
    "sao01"    = "sao"
    "mon01"    = "mon"
  }
}

provider "ibm" {
  region           = lookup(local.ibm_powervs_zone_region_map, var.powervs_zone, null)
  zone             = var.powervs_zone
  ibmcloud_api_key = var.ibmcloud_api_key != null ? var.ibmcloud_api_key : null
}

locals {

  def_share_memory_size          = 2
  def_share_number_of_processors = 0.5
  def_share_cpu_proc_type        = "shared"
  def_share_server_type          = "s922"
  def_netweaver_cpu_proc_type    = "shared"
  def_netweaver_server_type      = "s922"

  powervs_share_number_of_instances  = var.create_separate_fs_share ? 1 : 0
  powervs_share_hostname             = "${var.prefix}-share"
  powervs_share_default_os_image     = var.os_image_distro == "SLES" ? var.default_shared_fs_sles_image : var.default_shared_fs_rhel_image
  powervs_share_os_image             = var.sap_share_instance_config["os_image_name"] != null && var.sap_share_instance_config["os_image_name"] != "" ? var.sap_share_instance_config["os_image_name"] : local.powervs_share_default_os_image
  powervs_share_number_of_processors = var.sap_share_instance_config["number_of_processors"] != null && var.sap_share_instance_config["number_of_processors"] != "" ? var.sap_share_instance_config["number_of_processors"] : local.def_share_number_of_processors
  powervs_share_memory_size          = var.sap_share_instance_config["memory_size"] != null && var.sap_share_instance_config["memory_size"] != "" ? var.sap_share_instance_config["memory_size"] : local.def_share_memory_size
  powervs_share_cpu_proc_type        = var.sap_share_instance_config["cpu_proc_type"] != null && var.sap_share_instance_config["cpu_proc_type"] != "" ? var.sap_share_instance_config["cpu_proc_type"] : local.def_share_cpu_proc_type
  powervs_share_server_type          = var.sap_share_instance_config["server_type"] != null && var.sap_share_instance_config["server_type"] != "" ? var.sap_share_instance_config["server_type"] : local.def_share_server_type

  powervs_hana_hostname         = "${var.prefix}-${var.sap_hana_hostname}"
  powervs_hana_default_os_image = var.os_image_distro == "SLES" ? var.default_hana_sles_image : var.default_hana_rhel_image
  powervs_hana_os_image         = var.sap_hana_instance_config["os_image_name"] != null && var.sap_hana_instance_config["os_image_name"] != "" ? var.sap_hana_instance_config["os_image_name"] : local.powervs_hana_default_os_image
  powervs_hana_sap_profile_id   = var.sap_hana_instance_config["sap_profile_id"] != null && var.sap_hana_instance_config["sap_profile_id"] != "" ? var.sap_hana_instance_config["sap_profile_id"] : var.sap_hana_profile

  powervs_sap_netweaver_instance_number  = var.sap_netweaver_instance_config["number_of_instances"] != null && var.sap_netweaver_instance_config["number_of_instances"] != "" ? var.sap_netweaver_instance_config["number_of_instances"] : var.sap_netweaver_instance_number
  powervs_netweaver_default_os_image     = var.os_image_distro == "SLES" ? var.default_netweaver_sles_image : var.default_netweaver_rhel_image
  powervs_netweaver_os_image             = var.sap_netweaver_instance_config["os_image_name"] != null && var.sap_netweaver_instance_config["os_image_name"] != "" ? var.sap_netweaver_instance_config["os_image_name"] : local.powervs_netweaver_default_os_image
  powervs_netweaver_hostname             = "${var.prefix}-${var.sap_netweaver_hostname}"
  powervs_netweaver_number_of_processors = var.sap_netweaver_instance_config["number_of_processors"] != null && var.sap_netweaver_instance_config["number_of_processors"] != "" ? var.sap_netweaver_instance_config["number_of_processors"] : var.sap_netweaver_cpu_number
  powervs_netweaver_memory_size          = var.sap_netweaver_instance_config["memory_size"] != null && var.sap_netweaver_instance_config["memory_size"] != "" ? var.sap_netweaver_instance_config["memory_size"] : var.sap_netweaver_memory_size
  powervs_netweaver_cpu_proc_type        = var.sap_netweaver_instance_config["cpu_proc_type"] != null && var.sap_netweaver_instance_config["cpu_proc_type"] != "" ? var.sap_netweaver_instance_config["cpu_proc_type"] : local.def_netweaver_cpu_proc_type
  powervs_netweaver_server_type          = var.sap_netweaver_instance_config["server_type"] != null && var.sap_netweaver_instance_config["server_type"] != "" ? var.sap_netweaver_instance_config["server_type"] : local.def_netweaver_server_type
}


#####################################################
# Deploy SAP systems
#####################################################


module "sap_systems" {
  source                         = "../../"
  powervs_zone                   = var.powervs_zone
  powervs_resource_group_name    = var.powervs_resource_group_name
  powervs_workspace_name         = var.powervs_workspace_name
  powervs_sshkey_name            = var.powervs_sshkey_name
  powervs_sap_network            = { "name" = "${var.prefix}-net", "cidr" = var.powervs_sap_network_cidr }
  powervs_additional_networks    = var.additional_networks
  powervs_cloud_connection_count = var.cloud_connection_count

  powervs_share_instance_name        = local.powervs_share_hostname
  powervs_share_image_name           = local.powervs_share_os_image
  powervs_share_number_of_instances  = local.powervs_share_number_of_instances
  powervs_share_number_of_processors = local.powervs_share_number_of_processors
  powervs_share_memory_size          = local.powervs_share_memory_size
  powervs_share_cpu_proc_type        = local.powervs_share_cpu_proc_type
  powervs_share_server_type          = local.powervs_share_server_type
  powervs_share_storage_config       = var.sap_share_storage_config

  powervs_hana_instance_name             = local.powervs_hana_hostname
  powervs_hana_image_name                = local.powervs_hana_os_image
  powervs_hana_sap_profile_id            = local.powervs_hana_sap_profile_id
  powervs_hana_custom_storage_config     = var.sap_hana_custom_storage_config
  powervs_hana_additional_storage_config = var.sap_hana_additional_storage_config

  powervs_netweaver_instance_name        = local.powervs_netweaver_hostname
  powervs_netweaver_image_name           = local.powervs_netweaver_os_image
  powervs_netweaver_number_of_instances  = local.powervs_sap_netweaver_instance_number
  powervs_netweaver_number_of_processors = local.powervs_netweaver_number_of_processors
  powervs_netweaver_memory_size          = local.powervs_netweaver_memory_size
  powervs_netweaver_cpu_proc_type        = local.powervs_netweaver_cpu_proc_type
  powervs_netweaver_server_type          = local.powervs_netweaver_server_type
  powervs_netweaver_storage_config       = var.sap_netweaver_storage_config

  configure_os          = var.configure_os
  os_image_distro       = var.os_image_distro
  access_host_or_ip     = var.access_host_or_ip
  ssh_private_key       = var.ssh_private_key
  proxy_host_or_ip_port = var.proxy_host_or_ip_port
  ntp_host_or_ip        = var.ntp_host_or_ip
  dns_host_or_ip        = var.dns_host_or_ip
  nfs_path              = var.nfs_path
  nfs_client_directory  = var.nfs_client_directory
  sap_domain            = var.sap_domain
}
