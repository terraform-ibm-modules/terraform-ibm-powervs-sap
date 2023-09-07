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
# PowerVS Shared FS Instance parameters
#####################################################

variable "powervs_create_separate_fs_share" {
  description = "Deploy separate IBM PowerVS instance(0.5 cpus, 2 GB memory size, shared processor on s922.) as central file system share. All filesystems defined in 'powervs_share_storage_config' optional variable will be NFS exported and mounted on Netweaver PowerVS instances."
  type        = bool
  default     = true
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
variable "cos_service_credentials" {
  description = "Cloud object storage Instance service credentials to access the cos bucket [a json example of a service credential](https://cloud.ibm.com/docs/cloud-object-storage?topic=cloud-object-storage-service-credentials)"
  type        = string
  sensitive   = true
}

variable "cos_configuration" {
  description = "Cloud object storage Instance details to download the files to the target host. 'cos_hana_software_path' should contain only binaries required for HANA DB installation. 'cos_solution_software_path' should contain only binaries required for S4HANA or BW4HANA installation. If you have a stack xml file (maintainance planner) also place it under the 'cos_solution_software_path' dir and shouldn't contain any DB files as playbook will run into an error. Give the folder paths in Cloud object storage Instance."
  type = object({
    cos_region                 = string
    cos_bucket_name            = string
    cos_hana_software_path     = string
    cos_solution_software_path = string
  })
  default = {
    "cos_region" : "eu-geo",
    "cos_bucket_name" : "powervs-automation",
    "cos_hana_software_path" : "HANA_DB/rev66",
    "cos_solution_software_path" : "S4HANA_2022"
  }
}

#####################################################
# Ansible SAP Installation Parameters
#####################################################

variable "sap_solution" {
  description = "SAP Solution."
  type        = string
  validation {
    condition     = contains(["s4hana-2022", "s4hana-2021", "s4hana-2020", "bw4hana-2021"], var.sap_solution) ? true : false
    error_message = "Solution value has to be one of 's4hana-2022', 's4hana-2021', 's4hana-2020', 'bw4hana-2021'"
  }
}

variable "ansible_vault_password" {
  description = "Vault password to encrypt ansible variable file for SAP installation."
  type        = string
  sensitive   = true
}

variable "sap_hana_master_password" {
  description = "SAP HANA master password"
  type        = string
  sensitive   = true
}

variable "ansible_sap_hana_vars" {
  description = "SAP HANA variables for HANA DB installation."
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

variable "ansible_sap_solution_vars" {
  description = "SAP solution variables for SWPM installation. If sap_swpm_mp_stack_file_name is empty, then installation will not use maintainance planner and tms will not be installed and configured. "
  type = object({
    sap_swpm_sid                = string
    sap_swpm_ascs_instance_nr   = string
    sap_swpm_pas_instance_nr    = string
    sap_swpm_mp_stack_file_name = string

  })
  default = {
    "sap_swpm_sid" : "S4H",
    "sap_swpm_ascs_instance_nr" : "00",
    "sap_swpm_pas_instance_nr" : "01",
    "sap_swpm_mp_stack_file_name" : "MP_Stack.xml",
  }
  validation {
    condition     = var.ansible_sap_solution_vars.sap_swpm_ascs_instance_nr != var.ansible_sap_solution_vars.sap_swpm_pas_instance_nr
    error_message = "ASCS and PAS instance number must not be same"
  }
}

variable "sap_domain" {
  description = "SAP domain to be set for entire landscape."
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
    }
  ]
}

variable "powervs_default_images" {
  description = "Default Red Hat Linux images to use for SAP HANA and SAP NetWeaver PowerVS instances."
  type = object({
    rhel_hana_image = string
    rhel_nw_image   = string
  })
  default = {
    "rhel_hana_image" : "RHEL8-SP6-SAP",
    "rhel_nw_image" : "RHEL8-SP6-SAP-NETWEAVER"
  }
}
