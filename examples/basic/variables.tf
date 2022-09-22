variable "powervs_zone" {
  description = "IBM Cloud data center location where IBM PowerVS infrastructure will be created. Following locations are currently supported: syd04, syd05, eu-de-1, eu-de-2, lon04, lon06, wdc04, us-east, us-south, dal12, dal13, tor01, tok04, osa21, sao01, mon01"
  type        = string
  default     = "syd04"
  validation {
    condition     = contains(["syd04", "syd05", "eu-de-1", "eu-de-2", "lon04", "lon06", "wdc04", "us-east", "us-south", "dal12", "dal13", "tor01", "tok04", "osa21", "sao01", "mon01"], var.powervs_zone)
    error_message = "Supported values for powervs_zone are: syd04, syd05, eu-de-1, eu-de-2, lon04, lon06, wdc04, us-east, us-south, dal12, dal13, tor01, tok04, osa21, sao01, mon01."
  }
}

variable "resource_group" {
  type        = string
  description = "Existing IBM Cloud resource group name. If null, a new resource group will be created."
  default     = null
}

variable "prefix" {
  description = "Prefix for resources which will be created."
  type        = string
  default     = "pvs"
}

variable "powervs_service_name" {
  description = "Name of the PowerVS service to create"
  type        = string
  default     = "power-service"
}

variable "powervs_sshkey_name" {
  description = "Name of the PowerVS SSH key to create"
  type        = string
  default     = "ssh-key-pvs"
}

variable "powervs_management_network" {
  description = "Name of the IBM Cloud PowerVS management subnet and CIDR to create"
  type = object({
    name = string
    cidr = string
  })
  default = {
    name = "mgmt_net"
    cidr = "10.51.0.0/24"
  }
}

variable "powervs_backup_network" {
  description = "Name of the IBM Cloud PowerVS backup network and CIDR to create"
  type = object({
    name = string
    cidr = string
  })
  default = {
    name = "bkp_net"
    cidr = "10.52.0.0/24"
  }
}

variable "transit_gateway_name" {
  description = "Name of the existing transit gateway. Required when you create new IBM Cloud connections."
  type        = string
  default     = null
}

variable "reuse_cloud_connections" {
  description = "When true, IBM Cloud connections are reused (if attached to the transit gateway)."
  type        = bool
  default     = true
}

variable "cloud_connection_count" {
  description = "Required number of Cloud connections to create or reuse. The maximum number of connections is two per location."
  type        = number
  default     = 0
}

variable "cloud_connection_speed" {
  description = "Speed in megabits per second. Supported values are 50, 100, 200, 500, 1000, 2000, 5000, 10000. Required when you create a connection."
  type        = number
  default     = 5000
}

variable "ibmcloud_api_key" {
  description = "IBM Cloud Api Key"
  type        = string
  sensitive   = true
}

#####################################################
# Optional Parameters
#####################################################

variable "resource_tags" {
  type        = list(string)
  description = "Optional list of tags to be added to created resources"
  default     = []
}

variable "cloud_connection_gr" {
  description = "Enable global routing for this cloud connection. Can be specified when creating new connection"
  type        = bool
  default     = true
}

variable "cloud_connection_metered" {
  description = "Enable metered for this cloud connection. Can be specified when creating new connection"
  type        = bool
  default     = false
}

variable "access_host_or_ip" {
  description = "The public IP address for the jump or Bastion server. The address is used to reach the target or server_host IP address and to configure the DNS, NTP, NFS, and Squid proxy services."
  type        = string
  default     = null
}

variable "squid_config" {
  description = "Configuration for the Squid proxy setup"
  type = object({
    squid_enable      = bool
    server_host_or_ip = string
  })
  default = {
    "squid_enable"      = "false"
    "server_host_or_ip" = ""
  }
}

variable "dns_forwarder_config" {
  description = "Configuration for the DNS forwarder to a DNS service that is not reachable directly from PowerVS"
  type = object({
    dns_enable        = bool
    server_host_or_ip = string
    dns_servers       = string
  })
  default = {
    "dns_enable"        = "false"
    "server_host_or_ip" = ""
    "dns_servers"       = "161.26.0.7; 161.26.0.8; 9.9.9.9;"
  }
}

variable "ntp_forwarder_config" {
  description = "Configuration for the NTP forwarder to an NTP service that is not reachable directly from PowerVS"
  type = object({
    ntp_enable        = bool
    server_host_or_ip = string
  })
  default = {
    "ntp_enable"        = "false"
    "server_host_or_ip" = ""
  }
}

variable "nfs_config" {
  description = "Configuration for the shared NFS file system (for example, for the installation media)."
  type = object({
    nfs_enable        = bool
    server_host_or_ip = string
    nfs_directory     = string
  })
  default = {
    "nfs_enable"        = "false"
    "server_host_or_ip" = ""
    "nfs_directory"     = "/nfs"
  }
}

variable "perform_proxy_client_setup" {
  description = "Proxy configuration to allow internet access for a VM or LPAR."
  type = object(
    {
      squid_client_ips = list(string)
      squid_server_ip  = string
      no_proxy_env     = string
    }
  )
  default = null
}

#####################################################
# Parameters for the SAP on PowerVS deployment layer
#####################################################

variable "powervs_sap_network_cidr" {
  description = "Network range for separate SAP network. E.g., '10.111.1.0/24'"
  type        = string
  default     = "10.111.1.0/24"
}

variable "configure_os" {
  description = "Specify if OS on PowerVS instances should be configure for SAP or if only PowerVS instances should be created."
  type        = bool
  default     = false
}

variable "os_image_distro" {
  description = "Image distribution to use. Supported values are 'SLES' or 'RHEL'. OS release versions may be specified in optional parameters."
  type        = string
  default     = "SLES"
}

variable "create_separate_fs_share" {
  description = "Deploy separate IBM PowerVS instance as central file system share. Instance can be configured in optional parameters (cpus, memory size, etc.). Otherwise, defaults will be used."
  type        = bool
  default     = false
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
    hostname             = "share-fs"
    domain               = ""
    host_ip              = ""
    os_image_name        = "SLES15-SP3-SAP-NETWEAVER"
    cpu_proc_type        = "shared"
    number_of_processors = "0.5"
    memory_size          = "2"
    server_type          = "s922"

  }
}

variable "sap_share_storage_config" {
  description = "File systems to be created and attached to PowerVS instance for shared file systems. 'disk_sizes' are in GB. 'count' specify over how many sotrage volumes the file system will be striped. 'tiers' specifies the storage tier in PowerVS service. For creating multiple file systems, specify multiple entries in each parameter in the strucutre. E.g., for creating 2 file systems, specify 2 names, 2 disk sizes, 2 counts, 2 tiers and 2 paths."
  type = object({
    names      = string
    disks_size = string
    counts     = string
    tiers      = string
    paths      = string
  })
  default = {
    names      = "share"
    disks_size = "10"
    counts     = "1"
    tiers      = "tier3"
    paths      = "/share"
  }
}

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
    hostname       = "hana"
    domain         = ""
    host_ip        = ""
    sap_profile_id = "cnp-2x32"
    os_image_name  = "SLES15-SP3-SAP"

  }
}

variable "sap_hana_storage_config" {
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
    disks_size = "10,10,10,10"
    counts     = "2,2,1,1"
    tiers      = "tier1,tier1,tier3,tier3"
    paths      = "/hana/data,/hana/log,/hana/shared,/usr/sap"
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
    number_of_instances  = "1"
    hostname             = "nw"
    domain               = ""
    host_ips             = ""
    os_image_name        = "SLES15-SP3-SAP-NETWEAVER"
    cpu_proc_type        = "shared"
    number_of_processors = "0.5"
    memory_size          = "2"
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
    disks_size = "10,10"
    counts     = "1,1"
    tiers      = "tier3,tier3"
    paths      = "/usr/sap,/usr/sap/trans"
  }
}

variable "nfs_client_directory" {
  description = "NFS directory on PowerVS instances. Will be used only if nfs_server is setup in 'Power infrastructure for regulated industries'"
  type        = string
  default     = "/nfs"
}
