variable "pvs_zone" {
  description = "IBM Cloud Zone"
  type        = string
}

variable "pvs_resource_group_name" {
  description = "Existing Resource Group Name"
  type        = string
}

variable "pvs_service_name" {
  description = "Existing PowerVS Service Name"
  type        = string
}

variable "pvs_os_image_name" {
  description = "Name of image to Import"
  type        = string
}
