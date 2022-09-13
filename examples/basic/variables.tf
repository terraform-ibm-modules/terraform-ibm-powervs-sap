#####################################################
# Parameters for the configuraion of the PowerVS infrastructure layer
# Copyright 2022 IBM
#####################################################

variable "pvs_zone" {
  description = "IBM Cloud PowerVS Zone. Valid values: sao01,osa21,tor01,us-south,dal12,us-east,tok04,lon04,lon06,eu-de-1,eu-de-2,syd04,syd05"
  type        = string
  default     = "mon01"
  validation {
    condition     = contains(["syd04", "syd05", "eu-de-1", "eu-de-2", "lon04", "lon06", "wdc04", "us-east", "us-south", "dal12", "dal13", "tor01", "tok04", "osa21", "sao01", "mon01"], var.pvs_zone)
    error_message = "Supported values for pvs_zone are: syd04,syd05,eu-de-1,eu-de-2,lon04,lon06,wdc04,us-east,us-south,dal12,dal13,tor01,tok04,osa21,sao01,mon01"
  }
}

variable "resource_group" {
  type        = string
  description = "Existing resource group name to use for this example. If null, a new resource group will be created."
}

variable "pvs_service_name" {
  description = "Name of IBM Cloud PowerVS service which will be created"
  type        = string
  default     = "power-service"
}

variable "pvs_ssh_key_name" {
  description = "Name of IBM Cloud PowerVS SSH Key which will be created"
  type        = string
  default     = "ssh-key-pvs"
}

variable "pvs_management_network" {
  description = "IBM Cloud PowerVS Management Subnet name and cidr which will be created."
  type = object({
    name = string
    cidr = string
  })
  default = {
    "name" = "mgmt_net"
    "cidr" = "10.51.0.0/24"
  }
}

variable "pvs_backup_network" {
  description = "IBM Cloud PowerVS Backup Network name and cidr which will be created."
  type = object({
    name = string
    cidr = string
  })
  default = {
    "name" = "bkp_net"
    "cidr" = "10.52.0.0/24"
  }
}

variable "transit_gateway_name" {
  description = "Name of the existing transit gateway. Existing name must be provided when you want to create new cloud connections."
  type        = string
  default     = null
}

variable "reuse_cloud_connections" {
  description = "When the value is true, cloud connections will be reused (and is already attached to Transit gateway)"
  type        = bool
  default     = true
}

variable "cloud_connection_count" {
  description = "Required number of Cloud connections which will be created/Reused. Maximum is 2 per location"
  type        = number
  default     = 0
}

variable "cloud_connection_speed" {
  description = "Speed in megabits per sec. Supported values are 50, 100, 200, 500, 1000, 2000, 5000, 10000. Required when creating new connection"
  type        = number
  default     = 5000
}

variable "configure_proxy" {
  description = "Proxy is required to establish connectivity from PowerVS VSIs to the public internet. Do not configure proxy in this example by default."
  type        = bool
  default     = false
}

variable "configure_ntp_forwarder" {
  description = "NTP is required to sync time over time server not reachable directly from PowerVS VSIs. Do not configure NTP forwarder in this example by default."
  type        = bool
  default     = false
}

variable "configure_dns_forwarder" {
  description = "DNS is required to configure DNS resolution over server that is not reachable directly from PowerVS VSIs. Do not configure DNS forwarder in this example by default."
  type        = bool
  default     = false
}

variable "configure_nfs_server" {
  description = "NFS server may be used to provide shared FS for PowerVS VSIs. Do not configure NFS server in this example by default."
  type        = bool
  default     = false
}

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

variable "prefix" {
  description = "Prefix for resources which will be created."
  type        = string
  default     = "pvs"
}

variable "squid_proxy_config" {
  description = "Configure SQUID proxy to use with IBM Cloud PowerVS instances."
  type = object({
    squid_proxy_host_or_ip = string
  })
  default = {
    squid_proxy_host_or_ip = null
  }
}

variable "dns_forwarder_config" {
  description = "Configure DNS forwarder to existing DNS service that is not reachable directly from PowerVS."
  type = object({
    dns_forwarder_host_or_ip = string
    dns_servers              = string
  })
  default = {
    dns_forwarder_host_or_ip = null
    dns_servers              = "161.26.0.7; 161.26.0.8; 9.9.9.9;"
  }
}

variable "ntp_forwarder_config" {
  description = "Configure NTP forwarder to existing NTP service that is not reachable directly from PowerVS."
  type = object({
    ntp_forwarder_host_or_ip = string
  })
  default = {
    ntp_forwarder_host_or_ip = null
  }
}

variable "nfs_server_config" {
  description = "Configure shared NFS file system (e.g., for installation media)."
  type = object({
    nfs_server_host_or_ip = string
    nfs_directory         = string
  })
  default = {
    nfs_server_host_or_ip = null
    nfs_directory         = "/nfs"
  }
}

#####################################################
# Parameters for the SAP on PowerVs deployment layer
# Copyright 2022 IBM
#####################################################

variable "ibmcloud_api_key" {
  description = "IBM Cloud Api Key"
  type        = string
  sensitive   = true
  default     = null
}

variable "pvs_sap_network_cidr" {
  description = "CIDR for new Network for SAP system"
  type        = string
  default     = "10.111.1.1/24"
}

variable "pvs_sap_network_name" {
  description = "Name for new Network for SAP system"
  type        = string
  default     = "sap_net"
}

variable "pvs_sap_hana_instance_config" {
  description = "SAP HANA PowerVS instance configuration. If data is specified here - will replace other input."
  type = object({
    name-suffix         = string
    ip                  = string
    sap_hana_profile_id = string
    sap_image_name      = string
  })
  default = {
    name-suffix         = "hana"
    ip                  = ""
    sap_hana_profile_id = "cnp-2x32"
    sap_image_name      = "SLES15-SP3-SAP"
  }
}

variable "pvs_sap_hana_storage_config" {
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

variable "pvs_sap_share_instance_config" {
  description = "SAP shared file systems PowerVS instance configuration. If data is specified here - will replace other input."
  type = object({
    name-suffix          = string
    number_of_instances  = string
    hostname             = string
    ip                   = string
    cpu_proc_type        = string
    number_of_processors = string
    memory_size          = string
    sap_image_name       = string
  })
  default = {
    name-suffix          = "share-fs"
    number_of_instances  = "1"
    hostname             = "share-fs"
    ip                   = ""
    cpu_proc_type        = "shared"
    number_of_processors = "0.5"
    memory_size          = "2"
    sap_image_name       = "SLES15-SP3-SAP-NETWEAVER"
  }
}

variable "pvs_sap_share_storage_config" {
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

variable "pvs_sap_netweaver_instance_config" {
  description = "SAP NetWeaver PowerVS instance configuration. If data is specified here - will replace other input."
  type = object({
    name-suffix          = string
    number_of_instances  = string
    hostnames            = string
    ips                  = string
    cpu_proc_type        = string
    number_of_processors = string
    memory_size          = string
    sap_image_name       = string
  })
  default = {
    name-suffix          = "nw-app"
    number_of_instances  = "1"
    hostnames            = "nw-app"
    ips                  = ""
    cpu_proc_type        = "shared"
    number_of_processors = "0.5"
    memory_size          = "2"
    sap_image_name       = "SLES15-SP3-SAP-NETWEAVER"
  }
}

variable "pvs_sap_netweaver_storage_config" {
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
