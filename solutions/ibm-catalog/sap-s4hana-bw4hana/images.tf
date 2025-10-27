###############################################################################
#  PowerVS Custom / Stock Image Logic
###############################################################################

locals {
  # --------------------------------------------------------------------------
  # Determine how many valid custom images exist
  # --------------------------------------------------------------------------
  custom_image_count = length([for _, img in module.standard.powervs_images : img if img.image_license_type == "byol"])
  use_custom_images  = local.custom_image_count > 0

  # --------------------------------------------------------------------------
  # Set image names
  # --------------------------------------------------------------------------
  selected_hana_image = local.use_custom_images ? (
    length(trim(var.powervs_custom_images.powervs_custom_image1.image_name, " ")) > 0 ?
    var.powervs_custom_images.powervs_custom_image1.image_name :
    ""
  ) : var.powervs_default_sap_images.rhel_hana_image

  selected_netweaver_image = local.use_custom_images ? (
    length(trim(var.powervs_custom_images.powervs_custom_image2.image_name, " ")) > 0 ?
    var.powervs_custom_images.powervs_custom_image2.image_name :
    var.powervs_custom_images.powervs_custom_image1.image_name
  ) : var.powervs_default_sap_images.rhel_nw_image

  fls_image_types               = ["stock-sap-fls", "stock-sap-netweaver-fls"]
  selected_hana_image_type      = local.use_custom_images || strcontains(local.selected_hana_image, "BYOL") ? "byol" : "stock-sap-fls"
  selected_netweaver_image_type = local.use_custom_images || strcontains(local.selected_netweaver_image, "BYOL") ? "byol" : "stock-sap-netweaver-fls"

  # --------------------------------------------------------------------------
  # FLS and BYOL logic
  # --------------------------------------------------------------------------
  hana_is_fls        = contains(local.fls_image_types, local.selected_hana_image_type)
  netweaver_is_fls   = contains(local.fls_image_types, local.selected_netweaver_image_type)
  images_mixed       = local.hana_is_fls != local.netweaver_is_fls
  use_fls            = local.hana_is_fls && local.netweaver_is_fls
  has_byol_creds     = length(var.powervs_os_registration_username) > 0 && length(var.powervs_os_registration_password) > 0
  byol_and_fls       = local.use_fls && local.has_byol_creds
  missing_byol_creds = !local.use_fls && !local.has_byol_creds

  # --------------------------------------------------------------------------
  # Validation messages
  # --------------------------------------------------------------------------
  images_mixed_msg = "You've selected an FLS image and a BYOL image for HANA and NetWeaver. Using BYOL on one and FLS on another is not supported."
  # tflint-ignore: terraform_unused_declarations
  validate_images_mixed = regex("^${local.images_mixed_msg}$", (local.images_mixed ? "" : local.images_mixed_msg))

  missing_byol_msg = "Missing BYOL credentials for activation of Linux subscription."
  # tflint-ignore: terraform_unused_declarations
  validate_byol_provided = regex("^${local.missing_byol_msg}$", (local.missing_byol_creds ? "" : local.missing_byol_msg))

  byol_and_fls_msg = "FLS images and user-provided Linux subscription detected. Can't use both at the same time."
  # tflint-ignore: terraform_unused_declarations
  validate_byol_and_fls = regex("^${local.byol_and_fls_msg}$", (local.byol_and_fls ? "" : local.byol_and_fls_msg))
}
