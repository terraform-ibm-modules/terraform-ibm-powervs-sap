#####################################################
# PowerVS Service parameters
#####################################################

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

variable "pvs_sshkey_name" {
  description = "Existing SSH key name"
  type        = string
}

variable "pvs_cloud_connection_count" {
  description = "Required number of Cloud connections which will be created/Reused. Maximum is 2 per location"
  type        = string
  default     = 2
}

variable "pvs_additional_networks" {
  description = "Existing list of subnets name to be attached to node. First network has to be a management network"
  type        = list(any)
}

#####################################################
# PowerVS HANA Instance parameters
#####################################################

variable "pvs_hana_instance_name" {
  description = "Name of instance which will be created"
  type        = string
}

variable "pvs_hana_image_name" {
  description = "Image Names to import into the service"
  type        = string
}

variable "pvs_hana_sap_profile_id" {
  description = "SAP PROFILE ID. If this is mentioned then Memory, processors, proc_type and sys_type will not be taken into account"
  type        = string
  default     = null
}

variable "pvs_hana_storage_config" {
  description = "File systems to be created and attached to PowerVS instance for SAP HANA. 'disk_sizes' are in GB. 'count' specify over how many sotrage volumes the file system will be striped. 'tiers' specifies the storage tier in PowerVS service. For creating multiple file systems, specify multiple entries in each parameter in the strucutre. E.g., for creating 2 file systems, specify 2 names, 2 disk sizes, 2 counts, 2 tiers and 2 paths."
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

variable "pvs_netweaver_instance_name" {
  description = "Name of instance which will be created"
  type        = string
}

variable "pvs_netweaver_image_name" {
  description = "Image Names to import into the service"
  type        = string
}

variable "pvs_netweaver_number_of_instances" {
  description = "Number of instances"
  type        = string
  default     = 1
}

variable "pvs_netweaver_server_type" {
  description = "Processor type e980, s922, s1022 or e1080"
  type        = string
  default     = "s922"
}

variable "pvs_netweaver_cpu_proc_type" {
  description = "Dedicated or shared processors"
  type        = string
  default     = "shared"
}

variable "pvs_netweaver_number_of_processors" {
  description = "Number of processors"
  type        = string
}

variable "pvs_netweaver_memory_size" {
  description = "Amount of memory"
  type        = string
}

variable "pvs_netweaver_storage_config" {
  description = "File systems to be created and attached to PowerVS instance for SAP NetWeaver. 'disk_sizes' are in GB. 'count' specify over how many sotrage volumes the file system will be striped. 'tiers' specifies the storage tier in PowerVS service. For creating multiple file systems, specify multiple entries in each parameter in the strucutre. E.g., for creating 2 file systems, specify 2 names, 2 disk sizes, 2 counts, 2 tiers and 2 paths."
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
# PowerVS Shared FS Instance parameters
#####################################################

variable "pvs_share_instance_name" {
  description = "Name of instance which will be created"
  type        = string
}

variable "pvs_share_image_name" {
  description = "Image Names to import into the service"
  type        = string
}

variable "pvs_share_number_of_instances" {
  description = "Number of instances"
  type        = string
}

variable "pvs_share_server_type" {
  description = "Processor type e980, s922, s1022 or e1080"
  type        = string
  default     = "s922"
}

variable "pvs_share_cpu_proc_type" {
  description = "Dedicated or shared processors"
  type        = string
  default     = "shared"
}

variable "pvs_share_number_of_processors" {
  description = "Number of processors"
  type        = string
  default     = 0.5
}

variable "pvs_share_memory_size" {
  description = "Amount of memory"
  type        = string
  default     = 2
}

variable "pvs_share_storage_config" {
  description = "File systems to be created and attached to PowerVS instance for shared storage file systems. 'disk_sizes' are in GB. 'count' specify over how many sotrage volumes the file system will be striped. 'tiers' specifies the storage tier in PowerVS service. For creating multiple file systems, specify multiple entries in each parameter in the strucutre. E.g., for creating 2 file systems, specify 2 names, 2 disk sizes, 2 counts, 2 tiers and 2 paths."
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

variable "access_host_or_ip" {
  description = "Public IP of Bastion/jumpserver Host"
  type        = string
}


variable "ssh_private_key" {
  description = "Private Key to configure Instance, Will not be uploaded to server"
  type        = string
}

variable "proxy_host_or_ip" {
  description = "Proxy hosname or IP address with port. E.g., 10.10.10.4:3128"
  type        = string
  default     = ""
}

variable "nfs_host_or_ip" {
  description = "NFS server hosname or IP address. E.g., 10.10.10.5"
  type        = string
  default     = ""
}

variable "dns_host_or_ip" {
  description = "DNS forwarder/server hosname or IP address. E.g., 10.10.10.6"
  type        = string
  default     = ""
}

variable "ntp_host_or_ip" {
  description = "NTP forwarder/server hosname or IP address. E.g., 10.10.10.7"
  type        = string
  default     = ""
}

variable "sap_domain" {
  description = "Domain name to be set."
  type        = string
  default     = ""
}

variable "configure_os" {
  description = "Specify if OS on PowerVS instances should be configure for SAP or if only PowerVS instances should be created."
  type        = bool
  default     = true
}

variable "os_image_distro" {
  description = "Image distribution to use. Supported values are 'SLES' or 'RHEL'. OS release versions may be specified in optional parameters."
  type        = string
}

variable "nfs_path" {
  description = "NFS directory on NFS server."
  type        = string
  default     = "/nfs"
}

variable "nfs_client_directory" {
  description = "NFS directory on PowerVS instances."
  type        = string
  default     = "/nfs"
}

variable "pvs_sap_network_name" {
  description = "Name for new network for SAP system"
  type        = string
}

variable "pvs_sap_network_cidr" {
  description = "CIDR for new network for SAP system"
  type        = string
}
