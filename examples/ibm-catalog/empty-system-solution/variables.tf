#####################################################
# Parameters for the configuraion of the PowerVS infrastructure layer
# Copyright 2022 IBM
#####################################################

variable "ibmcloud_api_key" {
  description = "IBM Cloud Api Key"
  type        = string
  sensitive   = true
}

variable "pvs_zone" {
  description = "IBM Cloud PowerVS Zone. Valid values: sao01,osa21,tor01,us-south,dal12,us-east,tok04,lon04,lon06,eu-de-1,eu-de-2,syd04,syd05"
  type        = string
  validation {
    condition     = contains(["syd04", "syd05", "eu-de-1", "eu-de-2", "lon04", "lon06", "wdc04", "us-east", "us-south", "dal12", "dal13", "tor01", "tok04", "osa21", "sao01", "mon01"], var.pvs_zone)
    error_message = "Supported values for pvs_zone are: syd04,syd05,eu-de-1,eu-de-2,lon04,lon06,wdc04,us-east,us-south,dal12,dal13,tor01,tok04,osa21,sao01,mon01"
  }
}

variable "powervs_infrastructure_workspace_id" {
  description = "IBM cloud schematics workspace ID to reuse values from IBM PowerVS infrastructure workspace"
  type        = string
}

variable "ssh_private_key" {
  description = "Private SSH key used to login to IBM PowerVS instances. Should match to uploaded public SSH key referenced by 'pvs_sshkey_name'. Entered data must be in heredoc strings format (https://www.terraform.io/language/expressions/strings#heredoc-strings)."
  type        = string
}

variable "os_image_distro" {
  description = "Image distribution to use. Supported values are 'SLES' or 'RHEL'. OS release versions may be specified in optional parameters."
  type        = string
}

variable "prefix" {
  description = "Unique prefix for resources to be created (e.g., SAP system name)."
  type        = string
}

variable "pvs_sap_network_cidr" {
  description = "Network range for separate SAP network. E.g., '10.111.1.0/24'"
  type        = string
}

variable "sap_domain_name" {
  description = "Default network domain name for all IBM PowerVS instances. May be overwritten by individual instance configurations in optional paramteres."
  type        = string
}

variable "sap_hana_hostname" {
  description = "SAP HANA hostname (non FQDN). If not specified - will get the form of <prefix>-hana."
  type        = string
}

variable "sap_hana_ip" {
  description = "Optional SAP HANA IP address (in SAP system network, specified over 'pvs_sap_network_cidr' parameter)."
  type        = string
  default     = ""
}

variable "sap_hana_profile" {
  description = "SAP HANA profile to use. Must be one of the supported profiles. See XXX."
  type        = string
}

variable "calculate_hana_fs_sizes_automatically" {
  description = "Specify if SAP HANA file system sizes should be calculated automatically instead of using specification defined in optional parameters."
  type        = bool
  default     = true
}

variable "sap_netweaver_instance_number" {
  description = "Number of SAP NetWeaver instances that should be created."
  type        = number
  default     = 1
}

variable "sap_netweaver_hostname" {
  description = "Comma separated list of SAP Netweaver hostnames (non FQDN). If not specified - will get the form of <prefix>-nw-<number>."
  type        = string
}

variable "sap_netweaver_ips" {
  description = "List of optional SAP NetWeaver IP addresses (in SAP system network, specified over 'pvs_sap_network_cidr' parameter)."
  type        = list(string)
  default     = []
}

variable "sap_netweaver_memory_size" {
  description = "Memory size for each SAP NetWeaver instance."
  type        = string
}

variable "sap_netweaver_cpu_number" {
  description = "Number of CPUs for each SAP NetWeaver instance."
  type        = string
}

variable "create_separate_fs_share" {
  description = "Deploy separate IBM PowerVS instance as central file system share. Instance can be configured in optional parameters (cpus, memory size, etc.). Otherwise, defaults will be used."
  type        = bool
  default     = false
}

variable "default_hana_sles_image" {
  description = "Default SuSE Linux image to use for SAP HANA PowerVS instances."
  type        = string
  default     = "SLES15-SP3-SAP"
}

variable "default_netweaver_sles_image" {
  description = "Default SuSE Linux image to use for SAP NetWeaver PowerVS instances."
  type        = string
  default     = "SLES15-SP3-SAP-NETWEAVER"
}

variable "default_shared_fs_sles_image" {
  description = "Default SuSE Linux image to use for SAP shared FS PowerVS instances"
  type        = string
  default     = "SLES15-SP3-SAP-NETWEAVER"
}

variable "default_hana_rhel_image" {
  description = "Default Red Hat Linux image to use for SAP HANA PowerVS instances."
  type        = string
  default     = "RHEL8-SP4-SAP"
}

variable "default_netweaver_rhel_image" {
  description = "Default Red Hat Linux image to use for SAP NetWeaver PowerVS instances."
  type        = string
  default     = "RHEL8-SP4-SAP-NETWEAVER"
}

variable "default_shared_fs_rhel_image" {
  description = "Default Red Hat Linux image to use for SAP shared FS PowerVS instances."
  type        = string
  default     = "RHEL8-SP4-SAP-NETWEAVER"
}

#####################################################
# Parameters for the SAP on PowerVS deployment layer
# Copyright 2022 IBM
#####################################################

variable "sap_hana_instance_config" {
  description = "SAP HANA PowerVS instance configuration. If data is specified here - will replace other input."
  type = object({
    hostname       = string
    domain         = string
    host_ip        = string
    sap_profile_id = string
    os_image_name  = string
  })
  default = {
    hostname       = ""
    domain         = ""
    host_ip        = ""
    sap_profile_id = ""
    os_image_name  = ""
  }
}

variable "sap_hana_additional_storage_config" {
  description = "File systems to be created and attached to PowerVS instance for SAP HANA. 'disk_sizes' are in GB. 'count' specify over how many sotrage volumes the file system will be striped. 'tiers' specifies the storage tier in PowerVS service. For creating multiple file systems, specify multiple entries in each parameter in the strucutre. E.g., for creating 2 file systems, specify 2 names, 2 disk sizes, 2 counts, 2 tiers and 2 paths."
  type = object({
    names      = string
    disks_size = string
    counts     = string
    tiers      = string
    paths      = string
  })
  default = {
    names      = "data,log,shared,usrsap"
    disks_size = "250,150,1000,50"
    counts     = "4,4,1,1"
    tiers      = "tier1,tier1,tier3,tier3"
    paths      = "/hana/data,/hana/log,/hana/shared,/usr/sap"
  }
}

variable "sap_share_instance_config" {
  description = "SAP shared file system PowerVS instance configuration. If data is specified here - will replace other input."
  type = object({
    hostname             = string
    domain               = string
    host_ip              = string
    os_image_name        = string
    cpu_proc_type        = string
    number_of_processors = string
    memory_size          = string
    server_type          = string
  })
  default = {
    hostname             = ""
    domain               = ""
    host_ip              = ""
    os_image_name        = ""
    cpu_proc_type        = "shared"
    number_of_processors = "0.5"
    memory_size          = "4"
    server_type          = "s922"
  }
}

variable "sap_share_storage_config" {
  description = "File systems to be created and attached to PowerVS instance for shared storage file systems. 'disk_sizes' are in GB. 'count' specify over how many sotrage volumes the file system will be striped. 'tiers' specifies the storage tier in PowerVS service. For creating multiple file systems, specify multiple entries in each parameter in the strucutre. E.g., for creating 2 file systems, specify 2 names, 2 disk sizes, 2 counts, 2 tiers and 2 paths."
  type = object({
    names      = string
    disks_size = string
    counts     = string
    tiers      = string
    paths      = string
  })
  default = {
    names      = "share"
    disks_size = "1000"
    counts     = "1"
    tiers      = "tier3"
    paths      = "/share"
  }
}

variable "sap_netweaver_instance_config" {
  description = "SAP NetWeaver PowerVS instance configuration. If data is specified here - will replace other input."
  type = object({
    number_of_instances  = string
    hostname             = string
    domain               = string
    host_ips             = string
    os_image_name        = string
    cpu_proc_type        = string
    number_of_processors = string
    memory_size          = string
    server_type          = string
  })
  default = {
    number_of_instances  = ""
    hostname             = ""
    domain               = ""
    host_ips             = ""
    os_image_name        = ""
    cpu_proc_type        = "shared"
    number_of_processors = ""
    memory_size          = ""
    server_type          = "s922"
  }
}

variable "sap_netweaver_storage_config" {
  description = "File systems to be created and attached to PowerVS instance for SAP NetWeaver. 'disk_sizes' are in GB. 'count' specify over how many sotrage volumes the file system will be striped. 'tiers' specifies the storage tier in PowerVS service. For creating multiple file systems, specify multiple entries in each parameter in the strucutre. E.g., for creating 2 file systems, specify 2 names, 2 disk sizes, 2 counts, 2 tiers and 2 paths."
  type = object({
    names      = string
    disks_size = string
    counts     = string
    tiers      = string
    paths      = string
  })
  default = {
    names      = "usrsap,usrtrans"
    disks_size = "50,50"
    counts     = "1,1"
    tiers      = "tier3,tier3"
    paths      = "/usr/sap,/usr/sap/trans"
  }
}

variable "ibm_pvs_zone_region_map" {
  description = "Map of IBM Power VS zone to the region of PowerVS Infrastructure"
  type        = map(any)
  default = {
    "syd04"    = "syd"
    "syd05"    = "syd"
    "eu-de-1"  = "eu-de"
    "eu-de-2"  = "eu-de"
    "lon04"    = "lon"
    "lon06"    = "lon"
    "tok04"    = "tok"
    "us-east"  = "us-east"
    "us-south" = "us-south"
    "dal12"    = "us-south"
    "tor01"    = "tor"
    "osa21"    = "osa"
    "sao01"    = "sao"
    "mon01"    = "mon"
  }
}
