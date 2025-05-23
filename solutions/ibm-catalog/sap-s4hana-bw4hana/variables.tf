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
  default     = "sh2-4x256"
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

variable "powervs_netweaver_instance_storage_config" {
  description = "File systems to be created and attached to PowerVS SAP NetWeaver instance. 'size' is in GB. 'count' specifies over how many storage volumes the file system will be striped. 'tier' specifies the storage tier in PowerVS workspace. 'mount' specifies the target mount point on OS."
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

variable "software_download_directory" {
  description = "Software installation binaries will be downloaded to this directory."
  type        = string
  default     = "/software"
}

#####################################################
# Parameters for Image
#####################################################

variable "powervs_default_sap_images" {
  description = "Default Red Hat Linux Full Linux subscription images to use for PowerVS SAP HANA and SAP NetWeaver instances. If you're using a byol or a custom RHEL image, additionally specify the optional values for 'powervs_os_registration_username', 'powervs_os_registration_password' and 'ansible_vault_password'"
  type = object({
    rhel_hana_image = string
    rhel_nw_image   = string
  })
  default = {
    "rhel_hana_image" : "RHEL9-SP4-SAP",
    "rhel_nw_image" : "RHEL9-SP4-SAP-NETWEAVER"
  }
}

variable "powervs_os_registration_username" {
  description = "If you're using a byol or a custom RHEL image for SAP HANA and Netweaver you need to provide your OS registration credentials here. Leave empty if you're using an IBM provided subscription (FLS)."
  type        = string
  default     = ""
}

variable "powervs_os_registration_password" {
  description = "If you're using a byol or a custom RHEL image for SAP HANA and Netweaver you need to provide your OS registration credentials here. Leave empty if you're using an IBM provided subscription (FLS)."
  type        = string
  sensitive   = true
  default     = ""
}

#####################################################
# Parameters for SAP Installation
#####################################################

variable "sap_solution" {
  description = "SAP Solution to be installed on Power Virtual Server."
  type        = string
  validation {
    condition     = contains(["s4hana-2023", "s4hana-2022", "s4hana-2021", "s4hana-2020", "bw4hana-2021"], var.sap_solution) ? true : false
    error_message = "Solution value has to be one of 's4hana-2023', 's4hana-2022', 's4hana-2021', 's4hana-2020', 'bw4hana-2021'"
  }
}

variable "ibmcloud_cos_configuration" {
  description = "Cloud Object Storage instance containing SAP installation files that will be downloaded to NFS share. 'cos_hana_software_path' must contain only binaries required for HANA DB installation. 'cos_solution_software_path' must contain only binaries required for S/4HANA or BW/4HANA installation and must not contain any IMDB files. 'cos_monitoring_software_path' is optional and must contain x86_64 SAPCAR and SAP HANA client binaries required for configuring monitoring instance. The binaries required for installation can be found [here](https://github.com/terraform-ibm-modules/terraform-ibm-powervs-sap/blob/main/solutions/ibm-catalog/sap-s4hana-bw4hana/docs/s4hana23_bw4hana21_binaries.md) If you have an optional stack xml file (maintenance planner), place it under the 'cos_solution_software_path' directory. Avoid inserting '/' at the beginning for 'cos_hana_software_path', 'cos_solution_software_path' and 'cos_monitoring_software_path'."
  type = object({
    cos_region                   = string
    cos_bucket_name              = string
    cos_hana_software_path       = string
    cos_solution_software_path   = string
    cos_monitoring_software_path = optional(string)
    cos_swpm_mp_stack_file_name  = string
  })
  default = {
    "cos_region" : "eu-geo",
    "cos_bucket_name" : "powervs-automation",
    "cos_hana_software_path" : "HANA_DB/rev78",
    "cos_solution_software_path" : "S4HANA_2023",
    "cos_monitoring_software_path" : "HANA_CLIENT/x86_64",
    "cos_swpm_mp_stack_file_name" : ""
  }
}

variable "ibmcloud_cos_service_credentials" {
  description = "IBM Cloud Object Storage instance service credentials to access the bucket in the instance.[json example of service credential](https://cloud.ibm.com/docs/cloud-object-storage?topic=cloud-object-storage-service-credentials)"
  type        = string
  sensitive   = true
}

variable "sap_hana_master_password" {
  description = "SAP HANA master password."
  type        = string
  sensitive   = true

  validation {
    condition     = length(var.sap_hana_master_password) >= 8 && length(var.sap_hana_master_password) <= 30 && can(regex("[A-Z]", var.sap_hana_master_password)) && can(regex("[a-z]", var.sap_hana_master_password)) && can(regex("[0-9]", var.sap_hana_master_password)) && !can(regex("[\\\\\"]", var.sap_hana_master_password))
    error_message = "The SAP HANA master password must be 8-30 characters long containing at least one lower character (a-z), one upper character (A-Z) and one digit (0-9), and must not include a backslash (\\) or double quote (\")."
  }
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
  validation {
    condition     = can(regex("^[A-Z][A-Z0-9]{2}$", var.sap_hana_vars.sap_hana_install_sid))
    error_message = "The provided sap_hana_vars configuration is invalid. The sap_hana_install_sid value must consist of exactly three alphanumeric characters, all uppercase, and the first character must be a letter."
  }

  validation {
    condition     = can(regex("^[0-9]{2}$", var.sap_hana_vars.sap_hana_install_number))
    error_message = "The sap_hana_install_number must be a numeric value between 00 and 99. For single-digit numbers, append a leading zero."
  }

}

variable "sap_swpm_master_password" {
  description = "SAP SWPM master password."
  type        = string
  sensitive   = true
  validation {
    condition     = length(var.sap_swpm_master_password) >= 8 && length(var.sap_swpm_master_password) <= 30 && can(regex("[A-Z]", var.sap_swpm_master_password)) && can(regex("[a-z]", var.sap_swpm_master_password)) && can(regex("[0-9]", var.sap_swpm_master_password)) && !can(regex("[\\\\\"]", var.sap_swpm_master_password))
    error_message = "The SAP Software Provisioning Manager master password must be 8-30 characters long containing at least one lower character (a-z), one upper character (A-Z) and one digit (0-9), and must not include a backslash (\\) or double quote (\")."
  }
}

variable "sap_solution_vars" {
  description = "SAP SID, ASCS and PAS instance numbers and service/protectedwebmethods parameters."
  type = object({
    sap_swpm_sid                         = string
    sap_swpm_ascs_instance_nr            = string
    sap_swpm_pas_instance_nr             = string
    sap_swpm_service_protectedwebmethods = string

  })
  default = {
    "sap_swpm_sid" : "S4H",
    "sap_swpm_ascs_instance_nr" : "00",
    "sap_swpm_pas_instance_nr" : "01",
    "sap_swpm_service_protectedwebmethods" : "SDEFAULT -GetQueueStatistic -ABAPGetWPTable -EnqGetStatistic -GetProcessList -GetEnvironment -BAPGetSystemWPTable"
  }
  validation {
    condition     = var.sap_solution_vars.sap_swpm_ascs_instance_nr != var.sap_solution_vars.sap_swpm_pas_instance_nr
    error_message = "ASCS and PAS instance number must not be same"
  }
}

variable "ansible_vault_password" {
  description = "Vault password to encrypt SAP installation parameters in the OS. Password requirements: 15-100 characters and at least one uppercase letter, one lowercase letter, one number, and one special character. Allowed characters: A-Z, a-z, 0-9, !#$%&()*+-.:;<=>?@[]_{|}~."
  type        = string
  sensitive   = true
}

#####################################################
# Parameters for Monitoring
#####################################################

variable "sap_monitoring_vars" {
  description = "Configuration details for SAP monitoring dashboard. Takes effect only when a monitoring instance was deployed as part of Power Virtual Server with VPC landing zone deployment. If 'config_override' is true, an existing configuration will be overwritten, 'sap_monitoring_nr' Two-digit incremental number starting with 01 up to 99. This is not a existing SAP ID, but a pure virtual number and 'sap_monitoring_solution_name' is a virtual arbitrary short name to recognize SAP System."
  type = object({
    config_override              = bool
    sap_monitoring_nr            = string
    sap_monitoring_solution_name = string
  })
  default = {
    "config_override" : false,
    "sap_monitoring_nr" : "01",
    "sap_monitoring_solution_name" : ""
  }
  validation {
    condition     = (length(var.sap_monitoring_vars.sap_monitoring_nr) == 2 && tonumber(var.sap_monitoring_vars.sap_monitoring_nr) >= 0 && tonumber(var.sap_monitoring_vars.sap_monitoring_nr) <= 99) || var.sap_monitoring_vars.sap_monitoring_nr == ""
    error_message = "sap_monitoring_nr should be a 2-digit number between 00 and 99. or empty"
  }
}
