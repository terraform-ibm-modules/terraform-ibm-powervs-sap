variable "pvs_zone" {
  description = "IBM Cloud PowerVS Zone."
  type        = string
}

variable "pvs_resource_group_name" {
  description = "Existing Resource Group Name"
  type        = string
}

variable "pvs_service_name" {
  description = "Name of IBM Cloud PowerVS service which will be created"
  type        = string
}

variable "pvs_sap_network_name" {
  description = "Name for new network for SAP system"
  type        = string
}

variable "pvs_sap_network_cidr" {
  description = "CIDR for new network for SAP system"
  type        = string
}
