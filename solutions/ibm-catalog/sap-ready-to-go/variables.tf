variable "prerequisite_workspace_id" {
  description = "IBM Cloud Schematics workspace ID of an existing Power infrastructure for regulated industries deployment. If you do not yet have an existing deployment, click [here](https://cloud.ibm.com/catalog/) and search for 'Power Virtual Server with VPC landing zone' to create one."
  type        = string
}

variable "powervs_zone" {
  description = "IBM Cloud data center location where IBM PowerVS infrastructure will be created."
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

variable "sap_domain" {
  description = "SAP domain to be set for entire landscape. Set to null or empty if not configuring OS."
  type        = string
  default     = "sap.com"
}

#####################################################
# PowerVS Shared FS Instance parameters
#####################################################

variable "create_separate_fs_share" {
  description = "Deploy separate IBM PowerVS instance as central file system share. Instance can be configured in optional parameters (cpus, memory size, etc.). Otherwise, defaults will be used."
  type        = bool
  default     = false
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
  default     = "ush1-4x128"
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
# Optional Parameters
#####################################################

variable "default_hana_sles_image" {
  description = "Default SuSE Linux image to use for SAP HANA PowerVS instances."
  type        = string
  default     = "SLES15-SP3-SAP"
}

variable "default_hana_rhel_image" {
  description = "Default Red Hat Linux image to use for SAP HANA PowerVS instances."
  type        = string
  default     = "RHEL8-SP4-SAP"
}

variable "default_netweaver_sles_image" {
  description = "Default SuSE Linux image to use for SAP NetWeaver PowerVS instances."
  type        = string
  default     = "SLES15-SP3-SAP-NETWEAVER"
}

variable "default_netweaver_rhel_image" {
  description = "Default Red Hat Linux image to use for SAP NetWeaver PowerVS instances."
  type        = string
  default     = "RHEL8-SP4-SAP-NETWEAVER"
}

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

variable "sap_hana_custom_storage_config" {
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

variable "sap_hana_additional_storage_config" {
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

variable "sap_netweaver_storage_config" {
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

variable "ibmcloud_api_key" {
  description = "The IBM Cloud platform API key needed to deploy IAM enabled resources."
  type        = string
  sensitive   = true
  default     = null
}
