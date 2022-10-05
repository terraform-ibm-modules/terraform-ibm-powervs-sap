variable "ibmcloud_api_key" {
  description = "IBM Cloud Api Key"
  type        = string
  sensitive   = true
}

variable "powervs_zone" {
  description = "IBM Cloud data center location where IBM PowerVS infrastructure will be created. Following locations are currently supported: syd04, syd05, eu-de-1, eu-de-2, tok04, osa21, sao01"
  type        = string
}

variable "powervs_resource_group_name" {
  description = "Existing IBM Cloud resource group name."
  type        = string
}

variable "powervs_service_name" {
  description = "Name of IBM Cloud PowerVS service which will be created."
  type        = string
}

variable "powervs_sshkey_name" {
  description = "Exisiting PowerVS SSH Key Name."
  type        = string
}

variable "prefix" {
  description = "Prefix for resources which will be created."
  type        = string
  default     = "pvs"
}

variable "ssh_private_key" {
  description = "Private SSH key (RSA format) used to login to IBM PowerVS instances. Should match to uploaded public SSH key referenced by 'ssh_public_key'. Entered data must be in [heredoc strings format] (https://www.terraform.io/language/expressions/strings#heredoc-strings). The key is not uploaded or stored. Read [here] more about SSH keys in IBM Cloud (https://cloud.ibm.com/docs/vpc?topic=vpc-ssh-keys)."
  type        = string
  sensitive   = true
}

variable "additional_networks" {
  description = "Additional existing private networks that will be attached to IBM PowerVS instances."
  type        = list(string)
  default     = ["mgmt_net", "bkp_net"]
}

variable "cloud_connection_count" {
  description = "Existing number of Cloud connections to which new subnet must be attached."
  type        = string
  default     = 2
}

variable "powervs_sap_network_cidr" {
  description = "Network range for separate SAP network. E.g., '10.111.1.0/24'"
  type        = string
  default     = "10.111.1.0/24"
}

variable "os_image_distro" {
  description = "Image distribution to use. Supported values are 'SLES' or 'RHEL'. OS release versions may be specified in optional parameters."
  type        = string
  default     = "SLES"
}

variable "sap_hana_hostname" {
  description = "SAP HANA hostname (non FQDN). Will get the form of <prefix>-<sap_hana_hostname>."
  type        = string
  default     = "hana"
}

variable "sap_hana_profile" {
  description = "SAP HANA profile to use. Must be one of the supported profiles. See [here](https://cloud.ibm.com/docs/sap?topic=sap-hana-iaas-offerings-profiles-power-vs). Also ensure that sap_hana_additional_storage_config parameter is modified in order to provide a required filesystem sizes."
  type        = string
  default     = "cnp-2x64"
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

variable "sap_netweaver_instance_number" {
  description = "Number of SAP NetWeaver instances that should be created."
  type        = number
  default     = 1
}

variable "sap_netweaver_hostname" {
  description = "SAP Netweaver hostname (non FQDN). Will get the form of <prefix>-<sap_netweaver_hostname>-<number>."
  type        = string
  default     = "nw"
}

variable "sap_netweaver_cpu_number" {
  description = "Number of CPUs for each SAP NetWeaver instance."
  type        = string
}

variable "sap_netweaver_memory_size" {
  description = "Memory size for each SAP NetWeaver instance."
  type        = string
}

variable "create_separate_fs_share" {
  description = "Deploy separate IBM PowerVS instance as central file system share. Instance can be configured in optional parameters (cpus, memory size, etc.). Otherwise, defaults will be used."
  type        = bool
  default     = false
}

variable "configure_os" {
  description = "Specify if OS on PowerVS instances should be configure for SAP or if only PowerVS instances should be created."
  type        = bool
  default     = true
}

variable "access_host_or_ip" {
  description = "The public IP address or hostname for the access host. The address is used to reach the target or server_host IP address and to configure the DNS, NTP, NFS, and Squid proxy services."
  type        = string
}

variable "proxy_host_or_ip_port" {
  description = "Proxy hosname or IP address with port. E.g., 10.10.10.4:3128 <ip:port>"
  type        = string
  default     = ""
}

variable "dns_host_or_ip" {
  description = "Private IP address of DNS server, resolver or forwarder."
  type        = string
  default     = ""
}

variable "ntp_host_or_ip" {
  description = "Private IP address of NTP time server or forwarder."
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

#####################################################
# Optional Parameters
#####################################################

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
