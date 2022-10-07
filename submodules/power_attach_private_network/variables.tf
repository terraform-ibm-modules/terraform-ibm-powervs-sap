variable "powervs_zone" {
  description = "IBM Cloud PowerVS zone."
  type        = string
}

variable "powervs_resource_group_name" {
  description = "Existing IBM Cloud resource group name."
  type        = string
}

variable "powervs_workspace_name" {
  description = "Existing Name of the PowerVS workspace."
  type        = string
}

variable "powervs_sap_network_name" {
  description = "Name for new network for SAP system"
  type        = string
}

variable "powervs_cloud_connection_count" {
  description = "Number of existing Cloud connections to attach new private network"
  type        = string
}
