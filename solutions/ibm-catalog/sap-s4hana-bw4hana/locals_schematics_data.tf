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
  powervs_infrastructure  = jsondecode(data.ibm_schematics_output.schematics_output.output_json)
  powervs_workspace_guid  = local.powervs_infrastructure[0].powervs_workspace_guid.value
  powervs_sshkey_name     = local.powervs_infrastructure[0].powervs_ssh_public_key.value.name
  powervs_custom_images   = local.powervs_infrastructure[0].powervs_images.value
  powervs_networks        = [local.powervs_infrastructure[0].powervs_management_subnet.value, local.powervs_infrastructure[0].powervs_backup_subnet.value]
  access_host_or_ip       = local.powervs_infrastructure[0].access_host_or_ip.value
  proxy_host_or_ip_port   = local.powervs_infrastructure[0].proxy_host_or_ip_port.value
  dns_host_or_ip          = local.powervs_infrastructure[0].dns_host_or_ip.value
  ntp_host_or_ip          = local.powervs_infrastructure[0].ntp_host_or_ip.value
  nfs_host_or_ip_path     = local.powervs_infrastructure[0].nfs_host_or_ip_path.value
  ansible_host_or_ip      = local.powervs_infrastructure[0].ansible_host_or_ip.value
  network_services_config = local.powervs_infrastructure[0].network_services_config.value
  monitoring_instance     = local.powervs_infrastructure[0].monitoring_instance.value
  scc_wp_instance         = local.powervs_infrastructure[0].scc_wp_instance.value
}

############################################################
# Verify OS image type
############################################################
locals {
  selected_hana_image      = var.powervs_default_sap_images.rhel_hana_image
  selected_netweaver_image = var.powervs_default_sap_images.rhel_nw_image
  fls_image_types          = ["stock-sap-fls", "stock-sap-netweaver-fls"]
  use_custom_images = (
    length(local.powervs_custom_images) > 0 &&
    alltrue([
      for name in [local.selected_hana_image, local.selected_netweaver_image] : (
        contains(keys(local.powervs_custom_images), name) ?
        local.powervs_custom_images[name].image_vendor == "SAP" : false
      )
    ])
  )

}

# Stock image data (only if not using custom)
data "ibm_pi_catalog_images" "catalog_images_ds" {
  count = local.use_custom_images ? 0 : 1

  pi_cloud_instance_id = local.powervs_workspace_guid
  sap                  = true
}

# Custom image data (only if using custom)
data "ibm_pi_image" "custom_images" {
  count = local.use_custom_images ? 2 : 0

  pi_image_name        = element([local.selected_hana_image, local.selected_netweaver_image], count.index)
  pi_cloud_instance_id = local.powervs_workspace_guid
}

locals {
  # Determine image types
  hana_image_type = local.use_custom_images ? data.ibm_pi_image.custom_images[0].image_type : one([
    for img in data.ibm_pi_catalog_images.catalog_images_ds[0].images :
    img.image_type if img.name == local.selected_hana_image
  ])

  netweaver_image_type = local.use_custom_images ? data.ibm_pi_image.custom_images[1].image_type : one([
    for img in data.ibm_pi_catalog_images.catalog_images_ds[0].images :
    img.image_type if img.name == local.selected_netweaver_image
  ])

  hana_image_id = local.use_custom_images ? lookup(local.powervs_custom_images, local.selected_hana_image, null) : one([
    for img in data.ibm_pi_catalog_images.catalog_images_ds[0].images :
    img.image_id if img.name == local.selected_hana_image
  ])

  netweaver_image_id = local.use_custom_images ? lookup(local.powervs_custom_images, local.selected_netweaver_image, null) : one([
    for img in data.ibm_pi_catalog_images.catalog_images_ds[0].images :
    img.image_id if img.name == local.selected_netweaver_image
  ])

  hana_is_fls        = contains(local.fls_image_types, local.hana_image_type)
  netweaver_is_fls   = contains(local.fls_image_types, local.netweaver_image_type)
  images_mixed       = local.hana_is_fls != local.netweaver_is_fls
  use_fls            = local.hana_is_fls && local.netweaver_is_fls
  has_byol_creds     = length(var.powervs_os_registration_username) > 0 && length(var.powervs_os_registration_password) > 0
  byol_and_fls       = local.use_fls && local.has_byol_creds
  missing_byol_creds = !local.use_fls && !local.has_byol_creds

  # Validation messages
  images_mixed_msg = "You've selected an fls image and a byol image for hana and netweaver. Using byol on one and fls on another is currently not supported."
  # tflint-ignore: terraform_unused_declarations
  validate_images_mixed = regex("^${local.images_mixed_msg}$", (local.images_mixed ? "" : local.images_mixed_msg))

  missing_byol_msg = "Missing byol credentials for activation of linux subscription."
  # tflint-ignore: terraform_unused_declarations
  validate_byol_provided = regex("^${local.missing_byol_msg}$", (local.missing_byol_creds ? "" : local.missing_byol_msg))

  byol_and_fls_msg = "FLS images and user provided linux subscription detected. Can't use both at the same time."
  # tflint-ignore: terraform_unused_declarations
  validate_byol_and_fls = regex("^${local.byol_and_fls_msg}$", (local.byol_and_fls ? "" : local.byol_and_fls_msg))

}

locals {
  powervs_instance_init_linux = {
    enable                 = true
    bastion_host_ip        = local.access_host_or_ip
    ansible_host_or_ip     = local.ansible_host_or_ip
    ssh_private_key        = var.ssh_private_key
    custom_os_registration = local.use_fls ? null : { "username" : var.powervs_os_registration_username, "password" : var.powervs_os_registration_password }
  }

  powervs_network_services_config = {
    squid = { enable = true, squid_server_ip_port = local.proxy_host_or_ip_port, no_proxy_hosts = "161.0.0.0/8,10.0.0.0/8" }
    nfs   = { enable = local.nfs_host_or_ip_path != "" ? true : false, nfs_server_path = local.nfs_host_or_ip_path, nfs_client_path = var.software_download_directory, opts = local.network_services_config.nfs.opts, fstype = local.network_services_config.nfs.fstype }
    dns   = { enable = local.dns_host_or_ip != "" ? true : false, dns_server_ip = local.dns_host_or_ip }
    ntp   = { enable = local.ntp_host_or_ip != "" ? true : false, ntp_server_ip = local.ntp_host_or_ip }
  }
}
