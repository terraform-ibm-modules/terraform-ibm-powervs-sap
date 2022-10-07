variable "powervs_zone" {
  description = "IBM Cloud PowerVS zone."
  type        = string
  validation {
    condition     = contains(["sao01", "syd04", "syd05", "osa21", "tok04", "eu-de-1", "eu-de-2"], var.powervs_zone)
    error_message = "Only Following DCs are tested and verified : sao01, syd04, syd05, osa21, tok04, eu-de-1, eu-de-2."
  }
}

variable "powervs_resource_group_name" {
  description = "Existing IBM Cloud resource group name."
  type        = string
}

variable "powervs_workspace_name" {
  description = "Existing Name of the PowerVS workspace."
  type        = string
}

variable "powervs_sshkey_name" {
  description = "Existing PowerVs SSH key name."
  type        = string
}

variable "powervs_sap_network" {
  description = "Name and CIDR for new network for SAP system to create."
  type = object({
    name = string
    cidr = string
  })
}

variable "powervs_additional_networks" {
  description = "Existing list of subnets name to be attached to an instance. First network has to be a management network."
  type        = list(any)
}

variable "powervs_cloud_connection_count" {
  description = "Number of existing Cloud connections to attach new private network"
  type        = string
  default     = 2
}

#####################################################
# PowerVS Shared FS Instance parameters
#####################################################

variable "powervs_share_instance_name" {
  description = "Name of instance which will be created"
  type        = string
}

variable "powervs_share_image_name" {
  description = "Image Name for Shared Instance."
  type        = string
}

variable "powervs_share_number_of_instances" {
  description = "Number of instances"
  type        = string
}

variable "powervs_share_number_of_processors" {
  description = "Number of processors"
  type        = string
  default     = 0.5
}

variable "powervs_share_memory_size" {
  description = "Amount of memory"
  type        = string
  default     = 2
}

variable "powervs_share_cpu_proc_type" {
  description = "Dedicated or shared processors"
  type        = string
  default     = "shared"
}

variable "powervs_share_server_type" {
  description = "Processor type e980, s922, s1022 or e1080"
  type        = string
  default     = "s922"
}

variable "powervs_share_storage_config" {
  description = "File systems to be created and attached to PowerVS instance for shared storage file systems. 'disk_sizes' are in GB. 'count' specify over how many storage volumes the file system will be striped. 'tiers' specifies the storage tier in PowerVS workspace. For creating multiple file systems, specify multiple entries in each parameter in the structure. E.g., for creating 2 file systems, specify 2 names, 2 disk sizes, 2 counts, 2 tiers and 2 paths."
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

#####################################################
# PowerVS HANA Instance parameters
#####################################################

variable "powervs_hana_instance_name" {
  description = "Name of instance which will be created."
  type        = string
}

variable "powervs_hana_image_name" {
  description = "Image Name for HANA Instance."
  type        = string
}

variable "powervs_hana_sap_profile_id" {
  description = "SAP Profile Id for HANA instance"
  type        = string
  default     = "cnp-2x64"
}

variable "powervs_hana_storage_config" {
  description = "File systems to be created and attached to PowerVS instance for SAP HANA. 'disk_sizes' are in GB. 'count' specify over how many storage volumes the file system will be striped. 'tiers' specifies the storage tier in PowerVS workspace. For creating multiple file systems, specify multiple entries in each parameter in the structure. E.g., for creating 2 file systems, specify 2 names, 2 disk sizes, 2 counts, 2 tiers and 2 paths."
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

#####################################################
# PowerVS NetWeaver Instance parameters
#####################################################

variable "powervs_netweaver_instance_name" {
  description = "Name of instance which will be created"
  type        = string
}

variable "powervs_netweaver_image_name" {
  description = "Image Name for netweaver instance"
  type        = string
}

variable "powervs_netweaver_number_of_instances" {
  description = "Number of instances"
  type        = string
  default     = 1
}

variable "powervs_netweaver_number_of_processors" {
  description = "Number of processors"
  type        = string
}

variable "powervs_netweaver_memory_size" {
  description = "Amount of memory"
  type        = string
}

variable "powervs_netweaver_cpu_proc_type" {
  description = "Dedicated or shared processors"
  type        = string
  default     = "shared"
}

variable "powervs_netweaver_server_type" {
  description = "Processor type e980, s922, s1022 or e1080"
  type        = string
  default     = "s922"
}

variable "powervs_netweaver_storage_config" {
  description = "File systems to be created and attached to PowerVS instance for SAP NetWeaver. 'disk_sizes' are in GB. 'count' specify over how many storage volumes the file system will be striped. 'tiers' specifies the storage tier in PowerVS workspace. For creating multiple file systems, specify multiple entries in each parameter in the structure. E.g., for creating 2 file systems, specify 2 names, 2 disk sizes, 2 counts, 2 tiers and 2 paths."
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

#####################################################
# PVS SAP instance Initialization
#####################################################

variable "configure_os" {
  description = "Specify if OS on PowerVS instances should be configured for SAP or if only PowerVS instances should be created."
  type        = bool
  default     = true
}

variable "os_image_distro" {
  description = "Image distribution to use for all instances(Shared, HANA, Netweaver). Supported values are 'SLES' or 'RHEL'. OS release versions may be specified in optional parameters."
  type        = string
}

variable "access_host_or_ip" {
  description = "Public IP of Bastion/jumpserver Host"
  type        = string
  default     = null
}

variable "ssh_private_key" {
  description = "Private SSH key used to login to IBM PowerVS instances. Should match to uploaded public SSH key referenced by 'powervs_sshkey_name'."
  type        = string
  sensitive   = true
  default     = null
}

variable "proxy_host_or_ip_port" {
  description = "Proxy hosname or IP address with port. E.g., 10.10.10.4:3128 <ip:port>"
  type        = string
  default     = ""
}

variable "ntp_host_or_ip" {
  description = "NTP forwarder/server hosname or IP address. E.g., 10.10.10.7"
  type        = string
  default     = ""
}

variable "dns_host_or_ip" {
  description = "DNS forwarder/server hosname or IP address. E.g., 10.10.10.6"
  type        = string
  default     = ""
}

variable "nfs_path" {
  description = "Full path on NFS server (in form <hostname_or_ip>:<directory>, e.g., '10.20.10.4:/nfs')."
  type        = string
  default     = ""
}

variable "nfs_client_directory" {
  description = "NFS directory on PowerVS instances. Will be used only if nfs_server is setup in 'Power infrastructure for regulated industries'"
  type        = string
  default     = "/nfs"
}

variable "sap_domain" {
  description = "Domain name to be set."
  type        = string
  default     = ""
}
