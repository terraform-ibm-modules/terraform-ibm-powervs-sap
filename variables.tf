variable "powervs_zone" {
  description = "IBM Cloud PowerVS zone."
  type        = string
  validation {
    condition     = contains(["syd04", "syd05", "eu-de-1", "eu-de-2", "lon04", "lon06", "wdc04", "us-east", "us-south", "dal12", "dal13", "tor01", "tok04", "osa21", "sao01", "mon01"], var.powervs_zone)
    error_message = "Only Following DC values are supported :  syd04, syd05, eu-de-1, eu-de-2, lon04, lon06, wdc04, us-east, us-south, dal12, dal13, tor01, tok04, osa21, sao01, mon01"
  }
}

variable "powervs_resource_group_name" {
  description = "Existing IBM Cloud resource group name."
  type        = string
}

variable "powervs_workspace_name" {
  description = "Existing Name of the PowerVS workspace."
  type        = string
}

variable "powervs_sshkey_name" {
  description = "Existing PowerVs SSH key name."
  type        = string
}

variable "powervs_sap_network" {
  description = "Name and CIDR for new network for SAP system to create."
  type = object({
    name = string
    cidr = string
  })
}

variable "powervs_additional_networks" {
  description = "Existing list of subnets name to be attached to an instance. First network has to be a management network."
  type        = list(any)
}

variable "powervs_cloud_connection_count" {
  description = "Existing number of Cloud connections to which new subnet must be attached."
  type        = string
  default     = 2
}

#####################################################
# PowerVS Shared FS Instance parameters
#####################################################

variable "powervs_share_instance_name" {
  description = "Name of instance which will be created"
  type        = string
}

variable "powervs_share_image_name" {
  description = "Image Name for Shared Instance."
  type        = string
}

variable "powervs_share_number_of_instances" {
  description = "Number of instances"
  type        = string
}

variable "powervs_share_number_of_processors" {
  description = "Number of processors"
  type        = string
  default     = 0.5
}

variable "powervs_share_memory_size" {
  description = "Amount of memory"
  type        = string
  default     = 2
}

variable "powervs_share_cpu_proc_type" {
  description = "Dedicated or shared processors"
  type        = string
  default     = "shared"
}

variable "powervs_share_server_type" {
  description = "Processor type e980, s922, s1022 or e1080"
  type        = string
  default     = "s922"
}

variable "powervs_share_storage_config" {
  description = "File systems to be created and attached to PowerVS instance for shared storage file systems. 'disk_sizes' are in GB. 'count' specify over how many storage volumes the file system will be striped. 'tiers' specifies the storage tier in PowerVS workspace. For creating multiple file systems, specify multiple entries in each parameter in the structure. E.g., for creating 2 file systems, specify 2 names, 2 disk sizes, 2 counts, 2 tiers and 2 paths."
  type = object({
    names      = string
    disks_size = string
    counts     = string
    tiers      = string
    paths      = string
  })
  default = {
    names      = ""
    disks_size = ""
    counts     = ""
    tiers      = ""
    paths      = ""
  }
}

#####################################################
# PowerVS HANA Instance parameters
#####################################################

variable "powervs_hana_instance_name" {
  description = "Name of instance which will be created."
  type        = string
}

variable "powervs_hana_image_name" {
  description = "Image Name for HANA Instance."
  type        = string
}

variable "powervs_hana_sap_profile_id" {
  description = "SAP HANA profile to use. Must be one of the supported profiles. See [here](https://cloud.ibm.com/docs/sap?topic=sap-hana-iaas-offerings-profiles-power-vs). File system sizes are automatically calculated. Override automatic calculation by setting values in optional powervs_hana_custom_storage_config parameter."
  type        = string
  default     = "cnp-2x64"
}

variable "powervs_hana_additional_storage_config" {
  description = "Additional File systems to be created and attached to PowerVS instance for SAP HANA. 'disk_sizes' are in GB. 'count' specify over how many storage volumes the file system will be striped. 'tiers' specifies the storage tier in PowerVS workspace. For creating multiple file systems, specify multiple entries in each parameter in the structure. E.g., for creating 2 file systems, specify 2 names, 2 disk sizes, 2 counts, 2 tiers and 2 paths."
  type = object({
    names      = string
    disks_size = string
    counts     = string
    tiers      = string
    paths      = string
  })
  default = {
    names      = "usrsap"
    disks_size = "50"
    counts     = "1"
    tiers      = "tier3"
    paths      = "/usr/sap"
  }
}

variable "powervs_hana_custom_storage_config" {
  description = "Custom File systems to be created and attached to PowerVS instance for SAP HANA. 'disk_sizes' are in GB. 'count' specify over how many storage volumes the file system will be striped. 'tiers' specifies the storage tier in PowerVS workspace. For creating multiple file systems, specify multiple entries in each parameter in the structure. E.g., for creating 2 file systems, specify 2 names, 2 disk sizes, 2 counts, 2 tiers and 2 paths."
  type = object({
    names      = string
    disks_size = string
    counts     = string
    tiers      = string
    paths      = string
  })
  default = {
    names      = ""
    disks_size = ""
    counts     = ""
    tiers      = ""
    paths      = ""
  }
}

#####################################################
# PowerVS NetWeaver Instance parameters
#####################################################

variable "powervs_netweaver_number_of_instances" {
  description = "Number of instances"
  type        = number
  default     = 1
}

variable "powervs_netweaver_instance_name" {
  description = "Name of netweaver instance which will be created"
  type        = string
}

variable "powervs_netweaver_image_name" {
  description = "Image Name for netweaver instance"
  type        = string
}

variable "powervs_netweaver_number_of_processors" {
  description = "Number of processors"
  type        = string
}

variable "powervs_netweaver_memory_size" {
  description = "Amount of memory"
  type        = string
}

variable "powervs_netweaver_cpu_proc_type" {
  description = "Dedicated or shared processors"
  type        = string
  default     = "shared"
}

variable "powervs_netweaver_server_type" {
  description = "Processor type e980, s922, s1022 or e1080"
  type        = string
  default     = "s922"
}

variable "powervs_netweaver_storage_config" {
  description = "File systems to be created and attached to PowerVS instance for SAP NetWeaver. 'disk_sizes' are in GB. 'count' specify over how many storage volumes the file system will be striped. 'tiers' specifies the storage tier in PowerVS workspace. For creating multiple file systems, specify multiple entries in each parameter in the structure. E.g., for creating 2 file systems, specify 2 names, 2 disk sizes, 2 counts, 2 tiers and 2 paths."
  type = object({
    names      = string
    disks_size = string
    counts     = string
    tiers      = string
    paths      = string
  })
  default = {
    names      = ""
    disks_size = ""
    counts     = ""
    tiers      = ""
    paths      = ""
  }
}

#####################################################
# PVS SAP instance Initialization
#####################################################

variable "configure_os" {
  description = "Specify if OS on PowerVS instances should be configured for SAP or if only PowerVS instances should be created."
  type        = bool
  default     = true
}

variable "os_image_distro" {
  description = "Image distribution to use for all instances(Shared, HANA, Netweaver). Supported values are 'SLES' or 'RHEL'. OS release versions may be specified in optional parameters."
  type        = string
}

variable "access_host_or_ip" {
  description = "Public IP of Bastion/jumpserver Host"
  type        = string
  default     = null
}

variable "ssh_private_key" {
  description = "Private SSH key used to login to IBM PowerVS instances. Should match to uploaded public SSH key referenced by 'powervs_sshkey_name'."
  type        = string
  sensitive   = true
  default     = null
}

variable "proxy_host_or_ip_port" {
  description = "Proxy hostname or IP address with port. E.g., 10.10.10.4:3128 <ip:port>"
  type        = string
  default     = ""
}

variable "ntp_host_or_ip" {
  description = "NTP forwarder/server hostname or IP address. E.g., 10.10.10.7"
  type        = string
  default     = ""
}

variable "dns_host_or_ip" {
  description = "DNS forwarder/server hostname or IP address. E.g., 10.10.10.6"
  type        = string
  default     = ""
}

variable "nfs_host_or_ip_path" {
  description = "Full path on NFS server (in form <hostname_or_ip>:<directory>, e.g., '10.20.10.4:/nfs')."
  type        = string
  default     = ""
}

variable "nfs_client_directory" {
  description = "NFS directory on PowerVS instances. Will be used only if nfs_server is setup in 'Power infrastructure for regulated industries'"
  type        = string
  default     = "/nfs"
}

variable "sap_domain" {
  description = "Domain name to be set."
  type        = string
  default     = ""
}

#####################################################
# PVS SAP SYSTEM Software Ansible Parameters
#####################################################

variable "cos_config" {
  description = "COS bucket access information to copy the software to LOCAL DISK"
  type = object(
    {
      cos_bucket_name          = string
      cos_access_key           = string
      cos_secret_access_key    = string
      cos_endpoint_url         = string
      cos_source_folders_paths = list(string)
      target_folder_path_local = string
    }
  )

  default = {
    cos_bucket_name          = ""
    cos_access_key           = ""
    cos_secret_access_key    = ""
    cos_endpoint_url         = ""
    cos_source_folders_paths = [""]
    target_folder_path_local = ""
  }
}

variable "ansible_sap_solution" {
  description = "Product catalog solution."
  type        = any
  default = {
    "enable"   = false
    "solution" = ""
  }
}

variable "ansible_vault_password" {
  description = "Ansible Vault password to encrypt ansible variable files."
  default     = null
  type        = string
}
