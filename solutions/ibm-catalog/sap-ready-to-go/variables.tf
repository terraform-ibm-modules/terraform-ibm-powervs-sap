variable "ibmcloud_api_key" {
  description = "IBM Cloud platform API key needed to deploy IAM enabled resources."
  type        = string
  sensitive   = true
}

variable "prerequisite_workspace_id" {
  description = "IBM Cloud Schematics workspace ID of an existing 'Power Virtual Server with VPC landing zone' catalog solution. If you do not yet have an existing deployment, click [here](https://cloud.ibm.com/catalog/architecture/deploy-arch-ibm-pvs-inf-2dd486c7-b317-4aaa-907b-42671485ad96-global?) to create one."
  type        = string
}

variable "powervs_zone" {
  description = "IBM Cloud data center location corresponding to the location used in 'Power Virtual Server with VPC landing zone' pre-requisite deployment."
  type        = string
}

variable "prefix" {
  description = "Unique prefix for resources to be created (e.g., SAP system name). Max length must be less than or equal to 6."
  type        = string
  validation {
    condition     = length(var.prefix) <= 6 && can(regex("^[A-Za-z0-9]+$", var.prefix))
    error_message = "Prefix must be an alphanumeric string with maximum length of 6 characters."
  }
}

variable "powervs_sap_network_cidr" {
  description = "Network range for dedicated SAP network. Used for communication between SAP Application servers with SAP HANA Database. E.g., '10.53.0.0/24'"
  type        = string
  default     = "10.53.0.0/24"
}

variable "os_image_distro" {
  description = "Image distribution to use for all instances(Shared, HANA, NetWeaver). OS release versions may be specified in 'powervs_sap_default_images' optional parameters below."
  type        = string

  validation {
    condition     = (upper(var.os_image_distro) == "RHEL" || upper(var.os_image_distro) == "SLES")
    error_message = "Supported values are 'RHEL' or 'SLES' only."
  }
}

#####################################################
# PowerVS Shared FS Instance parameters
#####################################################

variable "powervs_create_separate_sharefs_instance" {
  description = "Deploy separate IBM PowerVS instance as central file system share. All filesystems defined in 'powervs_sharefs_instance_storage_config' variable will be NFS exported and mounted on SAP NetWeaver PowerVS instances if enabled. Optional parameter 'powervs_share_fs_instance' can be configured if enabled."
  type        = bool
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

#####################################################
# PowerVS HANA Instance parameters
#####################################################

variable "powervs_hana_instance_name" {
  description = "PowerVS SAP HANA instance hostname (non FQDN). Will get the form of <var.prefix>-<var.powervs_hana_instance_name>. Max length of final hostname must be <= 13 characters."
  type        = string
  default     = "hana"
}

variable "powervs_hana_instance_sap_profile_id" {
  description = "PowerVS SAP HANA instance profile to use. Must be one of the supported profiles. See [here](https://cloud.ibm.com/docs/sap?topic=sap-hana-iaas-offerings-profiles-power-vs). File system sizes are automatically calculated. Override automatic calculation by setting values in optional parameter 'powervs_hana_instance_custom_storage_config'."
  type        = string
  default     = "ush1-4x256"
}

variable "powervs_hana_instance_custom_storage_config" {
  description = "Custom file systems to be created and attached to PowerVS SAP HANA instance. 'size' is in GB. 'count' specify over how many storage volumes the file system will be striped. 'tier' specifies the storage tier in PowerVS workspace. 'mount' specifies the target mount point on OS."
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

variable "powervs_hana_instance_additional_storage_config" {
  description = "Additional File systems to be created and attached to PowerVS SAP HANA instance. 'size' is in GB. 'count' specify over how many storage volumes the file system will be striped. 'tier' specifies the storage tier in PowerVS workspace. 'mount' specifies the target mount point on OS."
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

#####################################################
# PowerVS NetWeaver Instance parameters
#####################################################

variable "powervs_netweaver_instance_count" {
  description = "Number of PowerVS SAP NetWeaver instances that should be created."
  type        = number
  default     = 1
}

variable "powervs_netweaver_instance_name" {
  description = "PowerVS SAP NetWeaver instance hostname (non FQDN). Will get the form of <var.prefix>-<var.powervs_netweaver_instance_name>-<number>. Max length of final hostname must be <= 13 characters."
  type        = string
  default     = "nw"
}

variable "powervs_netweaver_cpu_number" {
  description = "Number of CPUs for each PowerVS SAP NetWeaver instance."
  type        = string
  default     = "3"
}

variable "powervs_netweaver_memory_size" {
  description = "Memory size for each PowerVS SAP NetWeaver instance."
  type        = string
  default     = "32"
}

variable "powervs_netweaver_instance_storage_config" {
  description = "File systems to be created and attached to PowerVS SAP NetWeaver instance. 'size' is in GB. 'count' specify over how many storage volumes the file system will be striped. 'tier' specifies the storage tier in PowerVS workspace. 'mount' specifies the target mount point on OS. Do not specify volume for 'sapmnt' as this will be created internally if 'powervs_create_separate_sharefs_instance' is false, else 'sapmnt' will be mounted from sharefs instance."
  type = list(object({
    name  = string
    size  = string
    count = string
    tier  = string
    mount = string
    pool  = optional(string)
  }))
  default = [
    {
      "name" : "usrsap",
      "size" : "50",
      "count" : "1",
      "tier" : "tier3",
      "mount" : "/usr/sap"
    }
  ]
}

#####################################################
# OS parameters
#####################################################

variable "ssh_private_key" {
  description = "Private SSH key (RSA format) used to login to IBM PowerVS instances. Should match to uploaded public SSH key referenced by 'ssh_public_key' which was created previously. The key is temporarily stored and deleted. For more information about SSH keys, see [SSH keys](https://cloud.ibm.com/docs/vpc?topic=vpc-ssh-keys)."
  type        = string
  sensitive   = true
}

variable "sap_domain" {
  description = "SAP network domain name."
  type        = string
  default     = "sap.com"
}

variable "nfs_directory" {
  description = "Target directory on which the file storage share from VPC will be mounted."
  type        = string
  default     = "/nfs"
}

#####################################################
# Parameters for Image
#####################################################

variable "powervs_default_sap_images" {
  description = "Default SUSE and Red Hat Linux Full Linux subscription images to use for PowerVS SAP HANA and SAP NetWeaver instances. If you're using a byol or a custom RHEL/SLES image, additionally specify the optional values for 'powervs_os_registration_username', 'powervs_os_registration_password' and 'ansible_vault_password'"
  type = object({
    sles_hana_image = string
    sles_nw_image   = string
    rhel_hana_image = string
    rhel_nw_image   = string
  })
  default = {
    "sles_hana_image" : "SLES15-SP5-SAP",
    "rhel_hana_image" : "RHEL9-SP4-SAP",
    "sles_nw_image" : "SLES15-SP5-SAP-NETWEAVER",
    "rhel_nw_image" : "RHEL9-SP4-SAP-NETWEAVER"
  }
}

variable "ansible_vault_password" {
  description = "Vault password to encrypt ansible playbooks that contain sensitive information. Required with customer provided linux subscription (pi_os_registration) or when SCC workload protection instance is enabled. Password requirements: 15-100 characters and at least one uppercase letter, one lowercase letter, one number, and one special character. Allowed characters: A-Z, a-z, 0-9, !#$%&()*+-.:;<=>?@[]_{|}~."
  type        = string
  sensitive   = true
  default     = null
}

variable "powervs_os_registration_username" {
  description = "If you're using a byol or a custom RHEL/SLES image for SAP HANA and Netweaver you need to provide your OS registration credentials here. Leave empty if you're using an IBM provided subscription (FLS)."
  type        = string
  default     = ""
}

variable "powervs_os_registration_password" {
  description = "If you're using a byol or a custom RHEL/SLES image for SAP HANA and Netweaver you need to provide your OS registration credentials here. Leave empty if you're using an IBM provided subscription (FLS)."
  type        = string
  sensitive   = true
  default     = ""
}
