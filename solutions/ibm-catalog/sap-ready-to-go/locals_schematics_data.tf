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
  powervs_infrastructure = jsondecode(data.ibm_schematics_output.schematics_output.output_json)

  powervs_workspace_guid  = local.powervs_infrastructure[0].powervs_workspace_guid.value
  powervs_sshkey_name     = local.powervs_infrastructure[0].powervs_ssh_public_key.value.name
  powervs_images          = local.powervs_infrastructure[0].powervs_images.value
  powervs_networks        = [local.powervs_infrastructure[0].powervs_management_subnet.value, local.powervs_infrastructure[0].powervs_backup_subnet.value]
  access_host_or_ip       = local.powervs_infrastructure[0].access_host_or_ip.value
  proxy_host_or_ip_port   = local.powervs_infrastructure[0].proxy_host_or_ip_port.value
  dns_host_or_ip          = local.powervs_infrastructure[0].dns_host_or_ip.value
  ntp_host_or_ip          = local.powervs_infrastructure[0].ntp_host_or_ip.value
  nfs_host_or_ip_path     = local.powervs_infrastructure[0].nfs_host_or_ip_path.value
  ansible_host_or_ip      = local.powervs_infrastructure[0].ansible_host_or_ip.value
  network_services_config = local.powervs_infrastructure[0].network_services_config.value
}

locals {
  powervs_sharefs_os_image   = var.os_image_distro == "SLES" ? var.powervs_default_sap_images.sles_nw_image : var.powervs_default_sap_images.rhel_nw_image
  powervs_hana_os_image      = var.os_image_distro == "SLES" ? var.powervs_default_sap_images.sles_hana_image : var.powervs_default_sap_images.rhel_hana_image
  powervs_netweaver_os_image = var.os_image_distro == "SLES" ? var.powervs_default_sap_images.sles_nw_image : var.powervs_default_sap_images.rhel_nw_image

  powervs_instance_init_linux = {
    enable                 = true
    bastion_host_ip        = local.access_host_or_ip
    ansible_host_or_ip     = local.ansible_host_or_ip
    ssh_private_key        = var.ssh_private_key
    custom_os_registration = local.use_fls ? null : { "username" : var.powervs_os_registration_username, "password" : var.powervs_os_registration_password }
  }

  powervs_network_services_config = {
    squid = { enable = true, squid_server_ip_port = local.proxy_host_or_ip_port, no_proxy_hosts = "161.0.0.0/8,10.0.0.0/8" }
    nfs   = { enable = local.nfs_host_or_ip_path != "" ? true : false, nfs_server_path = local.nfs_host_or_ip_path, nfs_client_path = var.nfs_directory, opts = local.network_services_config.nfs.opts, fstype = local.network_services_config.nfs.fstype }
    dns   = { enable = local.dns_host_or_ip != "" ? true : false, dns_server_ip = local.dns_host_or_ip }
    ntp   = { enable = local.ntp_host_or_ip != "" ? true : false, ntp_server_ip = local.ntp_host_or_ip }
  }
}

data "ibm_pi_image" "powervs_hana_os_image" {
  pi_image_name        = local.powervs_hana_os_image
  pi_cloud_instance_id = local.powervs_workspace_guid
}

data "ibm_pi_image" "powervs_netweaver_os_image" {
  pi_image_name        = local.powervs_netweaver_os_image
  pi_cloud_instance_id = local.powervs_workspace_guid
}

locals {
  # The image type as read by the "ibm_pi_image" data source in terraform
  fls_image_types = ["stock-sap-fls", "stock-sap-netweaver-fls"]

  # Check if images are fls type images
  hana_is_fls_image      = contains(local.fls_image_types, data.ibm_pi_image.powervs_hana_os_image.image_type)
  netweaver_is_fls_image = contains(local.fls_image_types, data.ibm_pi_image.powervs_netweaver_os_image.image_type)

  # validate same type of linux subscription is used on both images
  images_mixed     = local.hana_is_fls_image != local.netweaver_is_fls_image
  images_mixed_msg = "You've selected an fls image and a byol image for hana and netweaver. Using byol on one and fls on another is currently not supported."
  # tflint-ignore: terraform_unused_declarations
  validate_images_mixed = regex("^${local.images_mixed_msg}$", (local.images_mixed ? "" : local.images_mixed_msg))

  # validate byol credentials are provided when fls isn't used
  use_fls          = local.hana_is_fls_image && local.netweaver_is_fls_image
  missing_byol     = local.use_fls ? false : !(length(var.powervs_os_registration_username) > 0 && length(var.powervs_os_registration_password) > 0)
  missing_byol_msg = "Missing byol credentials for activation of linux subscription."
  # tflint-ignore: terraform_unused_declarations
  validate_byol_provided = regex("^${local.missing_byol_msg}$", (local.missing_byol ? "" : local.missing_byol_msg))

  # validate the user didn't specify os registration credentials for fls images
  byol_and_fls     = local.use_fls && length(var.powervs_os_registration_username) > 0 && length(var.powervs_os_registration_password) > 0
  byol_and_fls_msg = "FLS images and user provided linux subscription detected. Can't use both at the same time."
  # tflint-ignore: terraform_unused_declarations
  validate_byol_and_fls = regex("^${local.byol_and_fls_msg}$", (local.byol_and_fls ? "" : local.byol_and_fls_msg))

}
