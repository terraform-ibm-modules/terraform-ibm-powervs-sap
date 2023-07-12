variable "ibmcloud_api_key" {
  description = "The IBM Cloud platform API key needed to deploy IAM enabled resources."
  type        = string
  sensitive   = true
}

variable "prerequisite_workspace_id" {
  description = "IBM Cloud Schematics workspace ID of an existing Power infrastructure for regulated industries deployment. If you do not yet have an existing deployment, click [here](https://cloud.ibm.com/catalog/) and search for 'Power Virtual Server with VPC landing zone' to create one."
  type        = string
}

variable "powervs_zone" {
  description = "IBM Cloud data center location where IBM PowerVS Workspace exists."
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
  description = "Network range for separate SAP network. E.g., '10.53.1.0/24'"
  type        = string
  default     = "10.53.1.0/24"
}

#####################################################
# PowerVS HANA Instance parameters
#####################################################

variable "powervs_hana_instance_name" {
  description = "SAP HANA hostname (non FQDN). Will get the form of <var.prefix>-<var.powervs_hana_instance_name>. Max length of final hostname must be <= 13 characters."
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

variable "powervs_netweaver_instance_name" {
  description = "SAP Netweaver hostname (non FQDN). Will get the form of <var.prefix>-<var.powervs_netweaver_instance_name>-<number>. Max length of final hostname must be <= 13 characters."
  type        = string
  default     = "nw"
}

variable "powervs_netweaver_cpu_number" {
  description = "Number of CPUs SAP NetWeaver instance."
  type        = string
  default     = "3"
}

variable "powervs_netweaver_memory_size" {
  description = "Memory size SAP NetWeaver instance."
  type        = string
  default     = "32"
}

#####################################################
# OS parameters
#####################################################

variable "ssh_private_key" {
  description = "Private SSH key (RSA format) used to login to IBM PowerVS instances. Should match to uploaded public SSH key referenced by 'ssh_public_key' which was created previously. Entered data must be in [heredoc strings format](https://www.terraform.io/language/expressions/strings#heredoc-strings). The key is not uploaded or stored. For more information about SSH keys, see [SSH keys](https://cloud.ibm.com/docs/vpc?topic=vpc-ssh-keys)."
  type        = string
  sensitive   = true
}

#####################################################
# COS Parameters to download binaries
#####################################################

variable "cos_configuration" {
  description = "COS details to download the files to the target host. 'cos_hana_software_path' should contain only binaries required for HANA DB installation. 'cos_solution_software_path' should contain only binaries required for S4HANA or BW4HANA installation. It shouldn't contain any DB files as playbook will run into an error. Give the folder paths in COS."
  type = object({
    cos_apikey                 = string
    cos_region                 = string
    cos_resource_instance_id   = string
    cos_bucket_name            = string
    cos_hana_software_path     = string
    cos_solution_software_path = string
  })
  sensitive = true
}

#####################################################
# Ansible SAP Installation Parameters
#####################################################

variable "sap_solution" {
  description = "SAP Solution"
  type        = string
  validation {
    condition     = contains(["s4hana-2022", "s4hana-2021", "s4hana-2020", "bw4hana-2021"], var.sap_solution) ? true : false
    error_message = "Solution value has to be one of 's4hana-2022', 's4hana-2021', 's4hana-2020', 'bw4hana-2021'"
  }
}

variable "ansible_vault_password" {
  description = "Vault password to encrypt ansible variable file for SAP installation"
  type        = string
  sensitive   = true
}

variable "sap_hana_vars" {
  description = "SAP HANA variables for HANA DB installation"
  type = object({
    sap_hana_install_sid             = string
    sap_hana_install_number          = string
    sap_hana_install_master_password = string
  })
  default = {
    "sap_hana_install_sid" : "HDB"
    "sap_hana_install_number" : "02"
    "sap_hana_install_master_password" : "NewPass$321"
  }
  sensitive = true
}

variable "sap_solution_vars" {
  description = "SAP solution variables for SWPM installation"
  type = object({
    sap_swpm_sid              = string
    sap_swpm_ascs_instance_nr = string
    sap_swpm_pas_instance_nr  = string
    sap_swpm_master_password  = string
  })
  default = {
    "sap_swpm_sid" : "S4H"
    "sap_swpm_ascs_instance_nr" : "00"
    "sap_swpm_pas_instance_nr" : "01"
    "sap_swpm_master_password" : "NewPass$321"
  }
  sensitive = true
}

variable "sap_domain" {
  description = "SAP domain to be set for entire landscape. Set to null or empty if not configuring OS."
  type        = string
  default     = "sap.com"
}

#####################################################
# Optional Parameters
#####################################################

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
    "rhel_hana_image" : "RHEL8-SP4-SAP"
    "rhel_nw_image" : "RHEL8-SP4-SAP-NETWEAVER"
    "sles_hana_image" : "SLES15-SP3-SAP"
    "sles_nw_image" : "SLES15-SP3-SAP-NETWEAVER"
  }
}
