data "ibm_pi_image" "powervs_hana_os_image" {
  pi_image_name        = var.powervs_hana_instance_image_id
  pi_cloud_instance_id = var.powervs_workspace_guid
}

data "ibm_pi_image" "powervs_netweaver_os_image" {
  pi_image_name        = var.powervs_netweaver_instance_image_id
  pi_cloud_instance_id = var.powervs_workspace_guid
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
  missing_byol     = local.use_fls ? false : var.powervs_instance_init_linux.custom_os_registration == null
  missing_byol_msg = "Missing byol credentials for activation of linux subscription."
  # tflint-ignore: terraform_unused_declarations
  validate_byol_provided = regex("^${local.missing_byol_msg}$", (local.missing_byol ? "" : local.missing_byol_msg))

  # validate the user didn't specify os registration credentials for fls images
  byol_and_fls     = local.use_fls && var.powervs_instance_init_linux.custom_os_registration != null
  byol_and_fls_msg = "FLS images and user provided linux subscription detected. Can't use both at the same time."
  # tflint-ignore: terraform_unused_declarations
  validate_byol_and_fls = regex("^${local.byol_and_fls_msg}$", (local.byol_and_fls ? "" : local.byol_and_fls_msg))

}
