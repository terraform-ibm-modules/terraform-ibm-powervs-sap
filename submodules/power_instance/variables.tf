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

variable "powervs_instance_name" {
  description = "Name of instance which will be created"
  type        = string
  validation {
    condition     = length(var.powervs_instance_name) <= 13
    error_message = "Maximum length of Instance name must be less or equal to 13 characters only."
  }
}

variable "powervs_sshkey_name" {
  description = "Existing PowerVs SSH key name."
  type        = string
}

variable "powervs_os_image_name" {
  description = "Image Name for PowerVS Instance"
  type        = string
}

variable "powervs_sap_profile_id" {
  description = "SAP PROFILE ID. If this is mentioned then Memory, processors, proc_type and sys_type will not be taken into account"
  type        = string
  default     = null
}

variable "powervs_server_type" {
  description = "Processor type e980/s922/e1080/s1022"
  type        = string
  default     = null
}

variable "powervs_cpu_proc_type" {
  description = "Dedicated or shared processors"
  type        = string
  default     = null
}

variable "powervs_number_of_processors" {
  description = "Number of processors"
  type        = string
  default     = null
}

variable "powervs_memory_size" {
  description = "Amount of memory"
  type        = string
  default     = null
}

variable "powervs_os_image_storage_type" {
  description = "Storage type for OS"
  type        = string
  default     = "tier1"
}

variable "powervs_networks" {
  description = "Existing map of subnet names and IPs to be attached to the node. First network has to be a management network. If IP is null, the address will be generated."
  type        = list(string)
}

variable "powervs_storage_config" {
  description = "DISKS To be created and attached to PowerVS Instance. Comma separated values.'disk_sizes' are in GB. 'count' specify over how many storage volumes the file system will be striped. 'tiers' specifies the storage tier in PowerVS workspace. For creating multiple file systems, specify multiple entries in each parameter in the structure. E.g., for creating 2 file systems, specify 2 names, 2 disk sizes, 2 counts, 2 tiers and 2 paths."
  type = object({
    names      = string
    disks_size = string
    counts     = string
    tiers      = string
    paths      = string
  })
  default = {
    names      = ""
    disks_size = ""
    counts     = ""
    tiers      = ""
    paths      = ""
  }
}
