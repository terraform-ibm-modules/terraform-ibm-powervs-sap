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
# Simple Resource
#####################################################

locals {
  service_type = "power-iaas"
  plan         = "power-virtual-server-group"
}

data "ibm_resource_group" "resource_group_ds" {
  name = var.powervs_resource_group_name
}

resource "ibm_resource_instance" "powervs_workspace" {
  name              = "${var.prefix}-${var.powervs_workspace_name}"
  service           = local.service_type
  plan              = local.plan
  location          = var.powervs_zone
  resource_group_id = data.ibm_resource_group.resource_group_ds.id

  timeouts {
    create = "6m"
    update = "5m"
    delete = "10m"
  }
}
