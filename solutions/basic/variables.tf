variable "ibmcloud_api_key" {
  description = "The IBM Cloud platform API key needed to deploy IAM enabled resources."
  type        = string
  sensitive   = true
}

variable "powervs_zone" {
  description = "IBM Cloud PowerVS zone."
  type        = string
  default     = "syd05"
  validation {
    condition     = contains(["syd04", "syd05", "eu-de-1", "eu-de-2", "lon04", "lon06", "us-east", "us-south", "dal10", "dal12", "tok04", "osa21", "sao01", "mon01", "tor01"], var.powervs_zone)
    error_message = "Only Following DC values are supported : syd04, syd05, eu-de-1, eu-de-2, lon04, lon06, us-east, us-south, dal10, dal12, tok04, osa21, sao01, mon01, tor01"
  }
}

variable "prefix" {
  description = "A unique identifier for resources. Must begin with a lowercase letter and end with a lowercase letter or number. "
  type        = string
}

variable "powervs_resource_group_name" {
  description = "Existing IBM Cloud resource group name."
  type        = string
  default     = "Default"
}

variable "powervs_workspace_name" {
  description = "Name of the PowerVS workspace to create."
  type        = string
  default     = "power-workspace"
}
