#####################################################
# PowerVs Image import Configuration
# Copyright 2022 IBM
#####################################################

locals {
  service_type = "power-iaas"
}

data "ibm_resource_group" "resource_group_ds" {
  name = var.pvs_resource_group_name
}

data "ibm_resource_instance" "pvs_service_ds" {
  name              = var.pvs_service_name
  service           = local.service_type
  location          = var.pvs_zone
  resource_group_id = data.ibm_resource_group.resource_group_ds.id
}

data "ibm_pi_images" "existing_images_ds" {
  pi_cloud_instance_id = data.ibm_resource_instance.pvs_service_ds.guid
}

data "ibm_pi_catalog_images" "catalog_images_ds" {
  sap                  = true
  pi_cloud_instance_id = data.ibm_resource_instance.pvs_service_ds.guid
}

locals {
  image         = [for x in data.ibm_pi_images.existing_images_ds.image_info : x if x.name == var.pvs_os_image_name]
  catalog_image = [for stock_image in data.ibm_pi_catalog_images.catalog_images_ds.images : stock_image if stock_image.name == var.pvs_os_image_name]
}

resource "ibm_pi_image" "image" {
  count                = length(local.image) == 0 ? 1 : 0
  pi_cloud_instance_id = data.ibm_resource_instance.pvs_service_ds.guid
  pi_image_id          = local.catalog_image[0].image_id
  pi_image_name        = var.pvs_os_image_name


}
