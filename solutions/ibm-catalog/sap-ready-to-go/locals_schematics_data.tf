############################################################
# Get Values from PowerVS with VPC Landing Zone Workspace
############################################################

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
  powervs_workspace_guid      = local.powerinfra_output[0].powervs_workspace_guid.value
  powervs_sshkey_name         = local.powerinfra_output[0].powervs_ssh_public_key.value.name
  powervs_images              = local.powerinfra_output[0].powervs_images.value
  cloud_connection_count      = local.powerinfra_output[0].cloud_connection_count.value
  additional_networks         = [local.powerinfra_output[0].powervs_management_subnet.value, local.powerinfra_output[0].powervs_backup_subnet.value]
  access_host_or_ip           = local.powerinfra_output[0].access_host_or_ip.value
  proxy_host_or_ip_port       = local.powerinfra_output[0].proxy_host_or_ip_port.value
  dns_host_or_ip              = local.powerinfra_output[0].dns_host_or_ip.value
  ntp_host_or_ip              = local.powerinfra_output[0].ntp_host_or_ip.value
  nfs_host_or_ip_path         = local.powerinfra_output[0].nfs_host_or_ip_path.value
}
