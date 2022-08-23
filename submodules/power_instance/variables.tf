variable "pvs_zone" {
  description = "IBM Cloud Zone"
  type        = string
}

variable "pvs_resource_group_name" {
  description = "Existing PowerVS service resource group Name"
  type        = string
}

variable "pvs_service_name" {
  description = "Existing Name of the PowerVS service"
  type        = string
}

variable "pvs_instance_name" {
  description = "Name of instance which will be created"
  type        = string
}

variable "pvs_sshkey_name" {
  description = "Existing SSH key name"
  type        = string
}

variable "pvs_os_image_name" {
  description = "Image Name for node"
  type        = string
}

variable "pvs_sap_profile_id" {
  description = "SAP PROFILE ID. If this is mentioned then Memory, processors, proc_type and sys_type will not be taken into account"
  type        = string
  default     = null
}

variable "pvs_server_type" {
  description = "Processor type e980/s922/e1080/s1022"
  type        = string
  default     = null
}

variable "pvs_cpu_proc_type" {
  description = "Dedicated or shared processors"
  type        = string
  default     = null
}

variable "pvs_number_of_processors" {
  description = "Number of processors"
  type        = string
  default     = null
}

variable "pvs_memory_size" {
  description = "Amount of memory"
  type        = string
  default     = null
}

variable "pvs_os_image_storage_type" {
  description = "Storage type for OS"
  type        = string
  default     = "tier3"
}

variable "pvs_networks" {
  description = "Existing map of subnet names and IPs to be attached to the node. First network has to be a management network. If IP is null, the address will be generated."
  type        = list(any)
  default     = ["mgmt_net", "backup_net"]
}

variable "pvs_storage_config" {
  description = "DISKS To be created and attached to node. Comma separated values"
  type        = map(any)
  default = {
    names      = ""
    paths      = ""
    disks_size = ""
    counts     = ""
    tiers      = ""
  }
}
