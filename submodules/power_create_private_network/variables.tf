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

variable "powervs_sap_network" {
  description = "Name and CIDR for new network for SAP system to create."
  type = object({
    name = string
    cidr = string
  })
}
