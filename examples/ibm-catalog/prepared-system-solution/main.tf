#####################################################
# PVS SAP Instance Deployment example for SAP SYSTEM with new private network
#####################################################

provider "ibm" {
  region           = lookup(var.ibm_pvs_zone_region_map, var.pvs_zone, null)
  zone             = var.pvs_zone
  ibmcloud_api_key = var.ibmcloud_api_key != null ? var.ibmcloud_api_key : null
}

data "ibm_schematics_workspace" "schematics_workspace" {
  workspace_id = var.powervs_infrastructure_workspace_id
}

data "ibm_schematics_output" "schematics_output" {
  workspace_id = var.powervs_infrastructure_workspace_id
  template_id  = data.ibm_schematics_workspace.schematics_workspace.runtime_data[0].id
}

locals {
  powerinfra_output = jsondecode(data.ibm_schematics_output.schematics_output.output_json)

  resource_group_name     = local.powerinfra_output[0].resource_group_name.value
  pvs_service_name        = local.powerinfra_output[0].pvs_service_name.value
  pvs_sshkey_name         = local.powerinfra_output[0].pvs_sshkey_name.value
  access_host_or_ip       = local.powerinfra_output[0].access_host_or_ip.value
  management_network_name = local.powerinfra_output[0].pvs_management_network.value
  backup_network_name     = local.powerinfra_output[0].pvs_backup_network.value
  cloud_connection_count  = local.powerinfra_output[0].cloud_connection_count.value

}

locals {

  def_share_memory_size          = 2
  def_share_number_of_processors = 0.5
  def_share_cpu_proc_type        = "shared"
  def_share_server_type          = "s922"
  def_netweaver_cpu_proc_type    = "shared"
  def_netweaver_server_type      = "s922"

  pvs_sap_network_name          = "${var.prefix}-net"
  pvs_share_number_of_instances = var.create_separate_fs_share ? 1 : 0
  pvs_share_default_os_image    = var.os_image_distro == "SLES" ? var.default_shared_fs_sles_image : var.default_shared_fs_rhel_image
  pvs_share_os_image            = var.sap_share_instance_config["os_image_name"] != null && var.sap_share_instance_config["os_image_name"] != "" ? var.sap_share_instance_config["os_image_name"] : local.pvs_share_default_os_image
  pvs_share_hostname            = var.sap_share_instance_config["hostname"] != null && var.sap_share_instance_config["hostname"] != "" ? var.sap_share_instance_config["hostname"] : "${var.prefix}-share"
  #pvs_share_domain               = var.sap_share_instance_config["domain"] != null && var.sap_share_instance_config["domain"] != "" ? var.sap_share_instance_config["domain"] : var.sap_domain_name
  pvs_share_memory_size          = var.sap_share_instance_config["memory_size"] != null && var.sap_share_instance_config["memory_size"] != "" ? var.sap_share_instance_config["memory_size"] : local.def_share_memory_size
  pvs_share_number_of_processors = var.sap_share_instance_config["number_of_processors"] != null && var.sap_share_instance_config["number_of_processors"] != "" ? var.sap_share_instance_config["number_of_processors"] : local.def_share_number_of_processors
  pvs_share_cpu_proc_type        = var.sap_share_instance_config["cpu_proc_type"] != null && var.sap_share_instance_config["cpu_proc_type"] != "" ? var.sap_share_instance_config["cpu_proc_type"] : local.def_share_cpu_proc_type
  pvs_share_server_type          = var.sap_share_instance_config["server_type"] != null && var.sap_share_instance_config["server_type"] != "" ? var.sap_share_instance_config["server_type"] : local.def_share_server_type

  pvs_hana_default_os_image = var.os_image_distro == "SLES" ? var.default_hana_sles_image : var.default_hana_rhel_image
  pvs_hana_os_image         = var.sap_hana_instance_config["os_image_name"] != null && var.sap_hana_instance_config["os_image_name"] != "" ? var.sap_hana_instance_config["os_image_name"] : local.pvs_hana_default_os_image
  pvs_hana_hostname         = var.sap_hana_instance_config["hostname"] != null && var.sap_hana_instance_config["hostname"] != "" ? var.sap_hana_instance_config["hostname"] : var.sap_hana_hostname
  #pvs_hana_domain           = var.sap_hana_instance_config["domain"] != null && var.sap_hana_instance_config["domain"] != "" ? var.sap_hana_instance_config["domain"] : var.sap_domain_name
  pvs_hana_sap_profile_id = var.sap_hana_instance_config["sap_profile_id"] != null && var.sap_hana_instance_config["sap_profile_id"] != "" ? var.sap_hana_instance_config["sap_profile_id"] : var.sap_hana_profile


  pvs_sap_netweaver_instance_number = var.sap_netweaver_instance_config["number_of_instances"] != null && var.sap_netweaver_instance_config["number_of_instances"] != "" ? var.sap_netweaver_instance_config["number_of_instances"] : var.sap_netweaver_instance_number
  pvs_netweaver_default_os_image    = var.os_image_distro == "SLES" ? var.default_netweaver_sles_image : var.default_netweaver_rhel_image
  pvs_netweaver_os_image            = var.sap_netweaver_instance_config["os_image_name"] != null && var.sap_netweaver_instance_config["os_image_name"] != "" ? var.sap_netweaver_instance_config["os_image_name"] : local.pvs_netweaver_default_os_image
  pvs_netweaver_hostname            = var.sap_netweaver_instance_config["hostname"] != null && var.sap_netweaver_instance_config["hostname"] != "" ? var.sap_netweaver_instance_config["hostname"] : var.sap_netweaver_hostname
  #pvs_netweaver_domain               = var.sap_netweaver_instance_config["domain"] != null && var.sap_netweaver_instance_config["domain"] != "" ? var.sap_netweaver_instance_config["domain"] : var.sap_domain_name
  pvs_netweaver_memory_size          = var.sap_netweaver_instance_config["memory_size"] != null && var.sap_netweaver_instance_config["memory_size"] != "" ? var.sap_netweaver_instance_config["memory_size"] : var.sap_netweaver_memory_size
  pvs_netweaver_number_of_processors = var.sap_netweaver_instance_config["number_of_processors"] != null && var.sap_netweaver_instance_config["number_of_processors"] != "" ? var.sap_netweaver_instance_config["number_of_processors"] : var.sap_netweaver_cpu_number
  pvs_netweaver_cpu_proc_type        = var.sap_netweaver_instance_config["cpu_proc_type"] != null && var.sap_netweaver_instance_config["cpu_proc_type"] != "" ? var.sap_netweaver_instance_config["cpu_proc_type"] : local.def_netweaver_cpu_proc_type
  pvs_netweaver_server_type          = var.sap_netweaver_instance_config["server_type"] != null && var.sap_netweaver_instance_config["server_type"] != "" ? var.sap_netweaver_instance_config["server_type"] : local.def_netweaver_server_type
}


#####################################################
# Deploy SAP systems
#####################################################


module "sap_systems" {
  source                     = "../../../"
  pvs_zone                   = var.pvs_zone
  pvs_resource_group_name    = local.resource_group_name
  pvs_service_name           = local.pvs_service_name
  pvs_sshkey_name            = local.pvs_sshkey_name
  pvs_sap_network_name       = local.pvs_sap_network_name
  pvs_sap_network_cidr       = var.pvs_sap_network_cidr
  pvs_additional_networks    = [local.management_network_name, local.backup_network_name]
  pvs_cloud_connection_count = local.cloud_connection_count

  pvs_share_number_of_instances  = local.pvs_share_number_of_instances
  pvs_share_image_name           = local.pvs_share_os_image
  pvs_share_instance_name        = local.pvs_share_hostname
  pvs_share_memory_size          = local.pvs_share_memory_size
  pvs_share_number_of_processors = local.pvs_share_number_of_processors
  pvs_share_cpu_proc_type        = local.pvs_share_cpu_proc_type
  pvs_share_server_type          = local.pvs_share_server_type
  pvs_share_storage_config       = var.sap_share_storage_config

  pvs_hana_instance_name  = local.pvs_hana_hostname
  pvs_hana_image_name     = local.pvs_hana_os_image
  pvs_hana_sap_profile_id = local.pvs_hana_sap_profile_id
  pvs_hana_storage_config = var.sap_hana_additional_storage_config

  pvs_netweaver_number_of_instances  = local.pvs_sap_netweaver_instance_number
  pvs_netweaver_image_name           = local.pvs_netweaver_os_image
  pvs_netweaver_instance_name        = local.pvs_netweaver_hostname
  pvs_netweaver_memory_size          = local.pvs_netweaver_memory_size
  pvs_netweaver_number_of_processors = local.pvs_netweaver_number_of_processors
  pvs_netweaver_cpu_proc_type        = local.pvs_netweaver_cpu_proc_type
  pvs_netweaver_server_type          = local.pvs_netweaver_server_type
  pvs_netweaver_storage_config       = var.sap_netweaver_storage_config

  access_host_or_ip = local.access_host_or_ip
  ssh_private_key   = var.ssh_private_key
  os_image_distro   = var.os_image_distro
}
