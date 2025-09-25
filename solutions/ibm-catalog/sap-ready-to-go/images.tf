# Stock image data (only if not using custom)
data "ibm_pi_catalog_images" "catalog_images_ds" {
  count                = local.use_custom_images ? 0 : 1
  provider             = ibm.ibm-pi
  pi_cloud_instance_id = module.standard.powervs_workspace_guid
  sap                  = true
}

# Custom image data (only if using custom)
data "ibm_pi_image" "custom_images" {
  count                = local.use_custom_images ? 2 : 0
  provider             = ibm.ibm-pi
  pi_image_name        = element([local.selected_hana_image, local.selected_netweaver_image], count.index)
  pi_cloud_instance_id = module.standard.powervs_workspace_guid
}

locals {
  powervs_custom_images = module.standard.powervs_images
}

locals {
  selected_hana_image      = var.os_image_distro == "SLES" ? var.powervs_default_sap_images.sles_hana_image : var.powervs_default_sap_images.rhel_hana_image
  selected_netweaver_image = var.os_image_distro == "SLES" ? var.powervs_default_sap_images.sles_nw_image : var.powervs_default_sap_images.rhel_nw_image

  fls_image_types = ["stock-sap-fls", "stock-sap-netweaver-fls"]

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

locals {
  hana_image_type = local.use_custom_images ? data.ibm_pi_image.custom_images[0].image_type : one([
    for img in data.ibm_pi_catalog_images.catalog_images_ds[0].images :
    img.image_type if img.name == local.selected_hana_image
  ])

  netweaver_image_type = local.use_custom_images ? data.ibm_pi_image.custom_images[1].image_type : one([
    for img in data.ibm_pi_catalog_images.catalog_images_ds[0].images :
    img.image_type if img.name == local.selected_netweaver_image
  ])

  hana_image_id = local.use_custom_images ? lookup(local.powervs_custom_images, local.selected_hana_image, null).image_id : one([
    for img in data.ibm_pi_catalog_images.catalog_images_ds[0].images :
    img.image_id if img.name == local.selected_hana_image
  ])

  netweaver_image_id = local.use_custom_images ? lookup(local.powervs_custom_images, local.selected_netweaver_image, null).image_id : one([
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

  images_mixed_msg      = "You've selected an fls image and a byol image for hana and netweaver. Using byol on one and fls on another is currently not supported."
  validate_images_mixed = regex("^${local.images_mixed_msg}$", (local.images_mixed ? "" : local.images_mixed_msg))

  missing_byol_msg       = "Missing byol credentials for activation of linux subscription."
  validate_byol_provided = regex("^${local.missing_byol_msg}$", (local.missing_byol_creds ? "" : local.missing_byol_msg))

  byol_and_fls_msg      = "FLS images and user provided linux subscription detected. Can't use both at the same time."
  validate_byol_and_fls = regex("^${local.byol_and_fls_msg}$", (local.byol_and_fls ? "" : local.byol_and_fls_msg))
}
