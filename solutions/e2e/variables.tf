#####################################################
#
# Required Parameters
#
#####################################################
variable "ibmcloud_api_key" {
  description = "The IBM Cloud platform API key needed to deploy IAM enabled resources."
  type        = string
  sensitive   = true
}

variable "powervs_zone" {
  description = "IBM Cloud data center location where IBM PowerVS infrastructure will be created."
  type        = string
}

variable "prefix" {
  description = "A unique identifier for resources. Must begin with a lowercase letter and end with a lowercase letter or number. This prefix will be prepended to any resources provisioned by this template."
  type        = string
}

variable "powervs_resource_group_name" {
  description = "Existing IBM Cloud resource group name."
  type        = string
}

variable "external_access_ip" {
  description = "Specify the IP address or CIDR to login through SSH to the environment after deployment. Access to this environment will be allowed only from this IP address."
  type        = string
}

variable "ssh_public_key" {
  description = "Public SSH Key for VSI creation. Must be an RSA key with a key size of either 2048 bits or 4096 bits (recommended). Must be a valid SSH key that does not already exist in the deployment region."
  type        = string
}

variable "ssh_private_key" {
  description = "Private SSH key (RSA format) used to login to IBM PowerVS instances. Should match to the public SSH key referenced by 'ssh_public_key' which was created previously. The key is temporarily stored and deleted. For more information about SSH keys, see [SSH keys](https://cloud.ibm.com/docs/vpc?topic=vpc-ssh-keys)."
  type        = string
  sensitive   = true
}

variable "os_image_distro" {
  description = "Image distribution to use for all instances(Shared, HANA, NetWeaver). OS release versions may be specified in 'var.powervs_default_images' optional parameters below."
  type        = string

  validation {
    condition     = (upper(var.os_image_distro) == "RHEL" || upper(var.os_image_distro) == "SLES")
    error_message = "Supported values are 'RHEL' or 'SLES' only."
  }
}

variable "powervs_create_separate_sharefs_instance" {
  description = "Deploy separate IBM PowerVS instance as central file system share. All filesystems defined in 'powervs_sharefs_instance_storage_config' variable will be NFS exported and mounted on NetWeaver PowerVS instances if enabled. Optional parameter 'powervs_share_fs_instance' can be configured if enabled."
  type        = bool
}

#####################################################
#
# Optional Parameters
#
#####################################################

variable "configure_dns_forwarder" {
  description = "Specify if DNS forwarder will be configured. This will allow you to use central DNS servers (e.g. IBM Cloud DNS servers) sitting outside of the created IBM PowerVS infrastructure. If yes, ensure 'dns_forwarder_config' optional variable is set properly. DNS forwarder will be installed on the network-services vsi."
  type        = bool
  default     = true
}

variable "configure_ntp_forwarder" {
  description = "Specify if NTP forwarder will be configured. This will allow you to synchronize time between IBM PowerVS instances. NTP forwarder will be installed on the network-services vsi."
  type        = bool
  default     = true
}

variable "configure_nfs_server" {
  description = "Specify if NFS server will be configured. This will allow you easily to share files between PowerVS instances (e.g., SAP installation files). NFS server will be installed on the network-services vsi. If yes, ensure 'nfs_server_config' optional variable is set properly below. Default value is 200GB which will be mounted on /nfs."
  type        = bool
  default     = true
}

#################################
# PowerVS SAP System Parameters
#################################

variable "powervs_sap_network_cidr" {
  description = "Additional private subnet for SAP communication which will be created. CIDR for SAP network. E.g., '10.53.0.0/24'"
  type        = string
  default     = "10.53.0.0/24"
}

variable "powervs_default_sap_images" {
  description = "Default SUSE and Red Hat Linux images to use for SAP HANA and SAP NetWeaver PowerVS instances."
  type = object({
    sles_hana_image = string
    sles_nw_image   = string
    rhel_hana_image = string
    rhel_nw_image   = string
  })
  default = {
    "sles_hana_image" : "SLES15-SP5-SAP",
    "rhel_hana_image" : "RHEL9-SP2-SAP",
    "sles_nw_image" : "SLES15-SP5-SAP-NETWEAVER",
    "rhel_nw_image" : "RHEL9-SP2-SAP-NETWEAVER"
  }
}

variable "powervs_sharefs_instance" {
  description = "Share fs instance. This parameter is effective if 'powervs_create_separate_sharefs_instance' is set to true. size' is in GB. 'count' specify over how many storage volumes the file system will be striped. 'tier' specifies the storage tier in PowerVS workspace. 'mount' specifies the target mount point on OS."
  type = object({
    name       = string
    processors = string
    memory     = string
    proc_type  = string
    storage_config = list(object({
      name  = string
      size  = string
      count = string
      tier  = string
      mount = string
      pool  = optional(string)
    }))
  })
  default = {
    "name" : "share",
    "processors" : "0.5",
    "memory" : "2",
    "proc_type" : "shared",
    "storage_config" : [{
      "name" : "sapmnt",
      "size" : "300",
      "count" : "1",
      "tier" : "tier3",
      "mount" : "/sapmnt"
      },
      {
        "name" : "trans",
        "size" : "50",
        "count" : "1",
        "tier" : "tier3",
        "mount" : "/usr/trans"
    }]
  }
}

variable "powervs_hana_instance" {
  description = "SAP HANA hostname (non FQDN) will get the form of <var.prefix>-<var.pi_hana_instance_name>. SAP HANA profile to use. Must be one of the supported profiles. See [here](https://cloud.ibm.com/docs/sap?topic=sap-hana-iaas-offerings-profiles-power-vs). File system sizes are automatically calculated. Override automatic calculation by setting values in optional 'pi_hana_instance_custom_storage_config' parameter. 'additional_storage_config' additional file systems to be created and attached to PowerVS instance for SAP HANA. 'size' is in GB. 'count' specify over how many storage volumes the file system will be striped. 'tier' specifies the storage tier in PowerVS workspace. 'mount' specifies the target mount point on OS."
  type = object({
    name           = string
    sap_profile_id = string
    additional_storage_config = list(object({
      name  = string
      size  = string
      count = string
      tier  = string
      mount = string
      pool  = optional(string)
    }))
  })
  default = {
    name           = "hana"
    sap_profile_id = "ush1-4x256"
    additional_storage_config = [{
      "name" : "usrsap",
      "size" : "50",
      "count" : "1",
      "tier" : "tier3",
      "mount" : "/usr/sap"
    }]
  }
}

variable "powervs_hana_instance_custom_storage_config" {
  description = "Custom File systems to be created and attached to PowerVS instance for SAP HANA. 'size' is in GB. 'count' specify over how many storage volumes the file system will be striped. 'tier' specifies the storage tier in PowerVS workspace. 'mount' specifies the target mount point on OS."
  type = list(object({
    name  = string
    size  = string
    count = string
    tier  = string
    mount = string
    pool  = optional(string)
  }))
  default = [{
    "name" : "",
    "size" : "",
    "count" : "",
    "tier" : "",
    "mount" : ""
  }]
}

variable "powervs_netweaver_instance" {
  description = "'instance_count' is number of SAP NetWeaver instances that should be created. 'size' is in GB. 'count' specify over how many storage volumes the file system will be striped. 'tier' specifies the storage tier in PowerVS workspace. 'mount' specifies the target mount point on OS. "
  type = object({
    instance_count = number
    name           = string
    processors     = string
    memory         = string
    proc_type      = string
    storage_config = list(object({
      name  = string
      size  = string
      count = string
      tier  = string
      mount = string
      pool  = optional(string)
    }))
  })
  default = {
    instance_count = 1
    name           = "nw"
    processors     = "3"
    memory         = "32"
    proc_type      = "shared"
    storage_config = [{
      "name" : "usrsap",
      "size" : "50",
      "count" : "1",
      "tier" : "tier3",
      "mount" : "/usr/sap"
    }]
  }
}

variable "sap_domain" {
  description = "SAP domain to be set for entire landscape."
  type        = string
  default     = "sap.com"
}
