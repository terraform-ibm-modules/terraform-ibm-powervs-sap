################################################################
#
# Required Parameters
#
################################################################

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
    condition     = length(var.prefix) <= 6
    error_message = "Prefix length exceeds 6 characters"
  }
}

variable "powervs_sap_network_cidr" {
  description = "Network range for dedicated SAP network. Used for communication between SAP Application servers with SAP HANA Database. E.g., '10.53.0.0/24'"
  type        = string
  default     = "10.53.0.0/24"
}

variable "powervs_create_separate_sharefs_instance" {
  description = "Deploy separate IBM PowerVS instance as central file system share. All filesystems defined in 'powervs_sharefs_instance_storage_config' variable will be NFS exported and mounted on SAP NetWeaver PowerVS instances if enabled. Optional parameter 'powervs_share_fs_instance' can be configured if enabled."
  type        = bool
}

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

variable "powervs_netweaver_instance_name" {
  description = "PowerVS SAP NetWeaver instance hostname (non FQDN). Will get the form of <var.prefix>-<var.powervs_netweaver_instance_name>-<number>. Max length of final hostname must be <= 13 characters."
  type        = string
  default     = "nw"
}

variable "powervs_netweaver_cpu_number" {
  description = "Number of CPUs for PowerVS SAP NetWeaver instance."
  type        = string
  default     = "3"
}

variable "powervs_netweaver_memory_size" {
  description = "Memory size for PowerVS SAP NetWeaver instance."
  type        = string
  default     = "32"
}

variable "ibmcloud_cos_service_credentials" {
  description = "IBM Cloud Object Storage instance service credentials to access the bucket in the instance.[json example of service credential](https://cloud.ibm.com/docs/cloud-object-storage?topic=cloud-object-storage-service-credentials)"
  type        = string
  sensitive   = true
}

variable "ibmcloud_cos_configuration" {
  description = "Cloud Object Storage instance containing SAP installation files that will be downloaded to NFS share. 'cos_hana_software_path' must contain only binaries required for HANA DB installation. 'cos_solution_software_path' must contain only binaries required for S/4HANA or BW/4HANA installation and must not contain any IMDB files. If you have an optional stack xml file (maintenance planner), place it under the 'cos_solution_software_path' directory. Avoid inserting '/' at the beginning for 'cos_hana_software_path' and 'cos_solution_software_path'."
  type = object({
    cos_region                  = string
    cos_bucket_name             = string
    cos_hana_software_path      = string
    cos_solution_software_path  = string
    cos_swpm_mp_stack_file_name = string
  })
  default = {
    "cos_region" : "eu-geo",
    "cos_bucket_name" : "powervs-automation",
    "cos_hana_software_path" : "HANA_DB/rev66",
    "cos_solution_software_path" : "S4HANA_2022",
    "cos_swpm_mp_stack_file_name" : ""
  }
}

variable "sap_solution" {
  description = "SAP Solution to be installed on Power Virtual Server."
  type        = string
  validation {
    condition     = contains(["s4hana-2022", "s4hana-2021", "s4hana-2020", "bw4hana-2021"], var.sap_solution) ? true : false
    error_message = "Solution value has to be one of 's4hana-2022', 's4hana-2021', 's4hana-2020', 'bw4hana-2021'"
  }
}

variable "sap_hana_master_password" {
  description = "SAP HANA master password."
  type        = string
  sensitive   = true
}

variable "sap_hana_vars" {
  description = "SAP HANA SID and instance number."
  type = object({
    sap_hana_install_sid    = string
    sap_hana_install_number = string
  })
  default = {
    "sap_hana_install_sid" : "HDB",
    "sap_hana_install_number" : "02"
  }
}

variable "sap_swpm_master_password" {
  description = "SAP SWPM master password."
  type        = string
  sensitive   = true
}

variable "sap_solution_vars" {
  description = "SAP SID, ASCS and PAS instance numbers."
  type = object({
    sap_swpm_sid              = string
    sap_swpm_ascs_instance_nr = string
    sap_swpm_pas_instance_nr  = string

  })
  default = {
    "sap_swpm_sid" : "S4H",
    "sap_swpm_ascs_instance_nr" : "00",
    "sap_swpm_pas_instance_nr" : "01"
  }
  validation {
    condition     = var.sap_solution_vars.sap_swpm_ascs_instance_nr != var.sap_solution_vars.sap_swpm_pas_instance_nr
    error_message = "ASCS and PAS instance number must not be same"
  }
}

variable "sap_domain" {
  description = "SAP network domain name."
  type        = string
  default     = "sap.com"
}

variable "ansible_vault_password" {
  description = "Vault password to encrypt SAP installation parameters in the OS."
  type        = string
  sensitive   = true
}

variable "ssh_private_key" {
  description = "Private SSH key (RSA format) used to login to IBM PowerVS instances. Should match to uploaded public SSH key referenced by 'ssh_public_key' which was created previously. Entered data must be in [heredoc strings format](https://www.terraform.io/language/expressions/strings#heredoc-strings). The key is not uploaded or stored. For more information about SSH keys, see [SSH keys](https://cloud.ibm.com/docs/vpc?topic=vpc-ssh-keys)."
  type        = string
  sensitive   = true
}

variable "ibmcloud_api_key" {
  description = "IBM Cloud platform API key needed to deploy IAM enabled resources."
  type        = string
  sensitive   = true
}


################################################################
#
# Optional Parameters
#
################################################################

variable "powervs_hana_instance_custom_storage_config" {
  description = "Custom file systems to be created and attached to PowerVS SAP HANA instance. 'size' is in GB. 'count' specify over how many storage volumes the file system will be striped. 'tier' specifies the storage tier in PowerVS workspace. 'mount' specifies the target mount point on OS."
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

variable "powervs_netweaver_instance_storage_config" {
  description = "File systems to be created and attached to PowerVS SAP NetWeaver instance. 'size' is in GB. 'count' specify over how many storage volumes the file system will be striped. 'tier' specifies the storage tier in PowerVS workspace. 'mount' specifies the target mount point on OS. Do not specify volume for 'sapmnt' as this will be created internally if 'powervs_create_separate_sharefs_instance' is false, else 'sapmnt' will mounted from sharefs instance."
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
    }
  ]
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

variable "powervs_default_sap_images" {
  description = "Default Red Hat Linux images to use for PowerVS SAP HANA and SAP NetWeaver instances."
  type = object({
    rhel_hana_image = string
    rhel_nw_image   = string
  })
  default = {
    "rhel_hana_image" : "RHEL8-SP6-SAP",
    "rhel_nw_image" : "RHEL8-SP6-SAP-NETWEAVER"
  }
}
