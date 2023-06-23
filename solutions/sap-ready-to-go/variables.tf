variable "ibmcloud_api_key" {
  description = "The IBM Cloud platform API key needed to deploy IAM enabled resources."
  type        = string
  sensitive   = true
}

variable "powervs_zone" {
  description = "IBM Cloud data center location where IBM PowerVS infrastructure will be created."
  type        = string
}

variable "powervs_resource_group_name" {
  description = "Existing IBM Cloud resource group name."
  type        = string
}

variable "powervs_workspace_name" {
  description = "Existing Name of PowerVS workspace."
  type        = string
}

variable "powervs_sshkey_name" {
  description = "Existing PowerVS SSH Key Name."
  type        = string
}

variable "prefix" {
  description = "Unique prefix for resources to be created (e.g., SAP system name). Max length must be less than or equal to 6."
  type        = string
  validation {
    condition     = length(var.prefix) <= 6
    error_message = "Prefix length exceeds 6 characters"
  }
}

variable "ssh_private_key" {
  description = "Private SSH key (RSA format) used to login to IBM PowerVS instances. Should match to uploaded public SSH key referenced by 'ssh_public_key' which was created previously. Entered data must be in [heredoc strings format](https://www.terraform.io/language/expressions/strings#heredoc-strings). The key is not uploaded or stored. For more information about SSH keys, see [SSH keys](https://cloud.ibm.com/docs/vpc?topic=vpc-ssh-keys)."
  type        = string
  sensitive   = true
}

variable "cloud_connection_count" {
  description = "Existing number of Cloud connections to which new subnet must be attached."
  type        = string
  default     = 2
}

variable "additional_networks" {
  description = "Existing list of subnets name to be attached to PowerVS instances. First network has to be a management network."
  type        = list(string)
  default     = ["mgmt_net", "bkp_net"]
}

variable "powervs_sap_network_cidr" {
  description = "Network range for separate SAP network. E.g., '10.53.1.0/24'"
  type        = string
  default     = "10.53.1.0/24"
}

variable "os_image_distro" {
  description = "Image distribution to use for all instances(Shared, HANA, Netweaver). OS release versions may be specified in optional parameters."
  type        = string
  default     = "RHEL"

  validation {
    condition     = (upper(var.os_image_distro) == "RHEL" || upper(var.os_image_distro) == "SLES")
    error_message = "Supported values are 'RHEL' or 'SLES' only."
  }
}

#####################################################
# PowerVS Shared FS Instance parameters
#####################################################

variable "powervs_create_separate_fs_share" {
  description = "Deploy separate IBM PowerVS instance as central file system share. Instance can be configured in optional parameters (cpus, memory size, etc.). Otherwise, defaults will be used."
  type        = bool
}

#####################################################
# PowerVS HANA Instance parameters
#####################################################

variable "powervs_hana_instance_name" {
  description = "SAP HANA hostname (non FQDN). Will get the form of <prefix>-<sap_hana_hostname>. Max length of final hostname must be <= 13 characters."
  type        = string
  default     = "hana"
}

variable "powervs_hana_sap_profile_id" {
  description = "SAP HANA profile to use. Must be one of the supported profiles. See [here](https://cloud.ibm.com/docs/sap?topic=sap-hana-iaas-offerings-profiles-power-vs). File system sizes are automatically calculated. Override automatic calculation by setting values in optional sap_hana_custom_storage_config parameter."
  type        = string
  default     = "ush1-4x256"
}

#####################################################
# PowerVS NetWeaver Instance parameters
#####################################################

variable "powervs_netweaver_instance_count" {
  description = "Number of SAP NetWeaver instances that should be created."
  type        = number
  default     = 1
}

variable "powervs_netweaver_instance_name" {
  description = "SAP Netweaver hostname (non FQDN). Will get the form of <prefix>-<sap_netweaver_hostname>-<number>. Max length of final hostname must be <= 13 characters."
  type        = string
  default     = "nw"
}

variable "powervs_netweaver_cpu_number" {
  description = "Number of CPUs for each SAP NetWeaver instance."
  type        = string
  default     = "3"
}

variable "powervs_netweaver_memory_size" {
  description = "Memory size for each SAP NetWeaver instance."
  type        = string
  default     = "32"
}

#####################################################
# PVS SAP instance Initialization
#####################################################

variable "access_host_or_ip" {
  description = "The public IP address or hostname for the access host. The address is used to reach the target or server_host IP address and to configure the DNS, NTP, NFS, and Squid proxy services. Set to null or empty if not configuring OS."
  type        = string
}

variable "proxy_host_or_ip_port" {
  description = "Proxy hostname or IP address with port. E.g., 10.10.10.4:3128 <ip:port>."
  type        = string

  validation {
    condition     = can(regex("\\b(?:(?:2(?:[0-4][0-9]|5[0-5])|[0-1]?[0-9]?[0-9])\\.){3}(?:(?:2([0-4][0-9]|5[0-5])|[0-1]?[0-9]?[0-9]))\\b:[0-9]+", var.proxy_host_or_ip_port))
    error_message = "Proxy hostname or IP address with port. E.g., 10.10.10.4:3128 <ip:port>."
  }
}

variable "dns_host_or_ip" {
  description = "Private IP address of DNS server, resolver or forwarder. Set empty if not configuring OS."
  type        = string
}

variable "ntp_host_or_ip" {
  description = "Private IP address of NTP time server or forwarder. Set empty if not configuring OS."
  type        = string
}

variable "nfs_host_or_ip_path" {
  description = "Full path on NFS server (in form <hostname_or_ip>:<directory>, e.g., '10.20.10.4:/nfs'). Set to empty if not configuring OS."
  type        = string

  validation {
    condition     = can(regex("\\b(?:(?:2(?:[0-4][0-9]|5[0-5])|[0-1]?[0-9]?[0-9])\\.){3}(?:(?:2([0-4][0-9]|5[0-5])|[0-1]?[0-9]?[0-9]))\\b:\\/[A-Za-z0-9]+", var.nfs_host_or_ip_path)) || var.nfs_host_or_ip_path == ""
    error_message = "Full path on NFS server (in form <hostname_or_ip>:<directory>, e.g., '10.20.10.4:/nfs') or it should be empty"
  }
}

variable "sap_domain" {
  description = "SAP domain to be set for entire landscape. Set to null or empty if not configuring OS."
  type        = string
  default     = "sap.com"
}

#####################################################
# Optional Parameters
#####################################################

variable "powervs_share_storage_config" {
  description = "File systems to be created and attached to PowerVS instance for shared storage file systems. 'size' is in GB. 'count' specify over how many storage volumes the file system will be striped. 'tier' specifies the storage tier in PowerVS workspace. 'mount' specifies the target mount point on OS."
  type = list(object({
    name  = string
    size  = string
    count = string
    tier  = string
    mount = string
  }))
  default = [{
    "name" : "share",
    "size" : "1000",
    "count" : "1",
    "tier" : "tier3",
    "mount" : "/share"

  }]
}

variable "powervs_hana_custom_storage_config" {
  description = "Custom File systems to be created and attached to PowerVS instance for SAP HANA. 'size' is in GB. 'count' specify over how many storage volumes the file system will be striped. 'tier' specifies the storage tier in PowerVS workspace. 'mount' specifies the target mount point on OS."
  type = list(object({
    name  = string
    size  = string
    count = string
    tier  = string
    mount = string
  }))
  default = [{
    "name" : "",
    "size" : "",
    "count" : "",
    "tier" : "",
    "mount" : ""
  }]
}

variable "powervs_hana_additional_storage_config" {
  description = "Additional File systems to be created and attached to PowerVS instance for SAP HANA. 'size' is in GB. 'count' specify over how many storage volumes the file system will be striped. 'tier' specifies the storage tier in PowerVS workspace. 'mount' specifies the target mount point on OS."
  type = list(object({
    name  = string
    size  = string
    count = string
    tier  = string
    mount = string
  }))
  default = [{
    "name" : "usrsap",
    "size" : "50",
    "count" : "1",
    "tier" : "tier3",
    "mount" : "/usr/sap"

  }]
}

variable "powervs_netweaver_storage_config" {
  description = "File systems to be created and attached to PowerVS instance for SAP NetWeaver. 'size' is in GB. 'count' specify over how many storage volumes the file system will be striped. 'tier' specifies the storage tier in PowerVS workspace. 'mount' specifies the target mount point on OS."
  type = list(object({
    name  = string
    size  = string
    count = string
    tier  = string
    mount = string
  }))
  default = [
    {
      "name" : "usrsap",
      "size" : "50",
      "count" : "1",
      "tier" : "tier3",
      "mount" : "/usr/sap"
    },
    {
      "name" : "usrtrans",
      "size" : "50",
      "count" : "1",
      "tier" : "tier3",
      "mount" : "/usr/sap/trans"
    }
  ]
}

variable "powervs_default_images" {
  description = "Default SuSE and Red Hat Linux images to use for SAP HANA and SAP NetWeaver PowerVS instances."
  type = object({
    sles_hana_image = string
    sles_nw_image   = string
    rhel_hana_image = string
    rhel_nw_image   = string
  })
  default = {
    "sles_hana_image" : "SLES15-SP3-SAP"
    "rhel_hana_image" : "RHEL8-SP4-SAP"
    "sles_nw_image" : "SLES15-SP3-SAP-NETWEAVER"
    "rhel_nw_image" : "RHEL8-SP4-SAP-NETWEAVER"
  }
}
