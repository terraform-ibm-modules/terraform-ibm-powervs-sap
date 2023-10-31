variable "pi_zone" {
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

variable "pi_workspace_guid" {
  description = "PowerVS infrastructure workspace guid. The GUID of the resource instance."
  type        = string
}

variable "pi_ssh_public_key_name" {
  description = "Existing PowerVS SSH Public Key Name."
  type        = string
}

variable "pi_networks" {
  description = "Existing list of subnets to be attached to PowerVS instances. The first element will become the primary interface. Run 'ibmcloud pi networks' to list available private subnets."
  type = list(
    object({
      name = string
      id   = string
      cidr = optional(string)
    })
  )
}

variable "pi_sap_network_cidr" {
  description = "Additional private subnet for SAP communication which will be created. CIDR for SAP network. E.g., '10.53.1.0/24'"
  type        = string
  default     = "10.53.1.0/24"
}


variable "cloud_connection_count" {
  description = "Existing number of Cloud connections to which new subnet must be attached. Will be ignored in case of PER enabled DC."
  type        = string
  default     = 2
}

#####################################################
# PowerVS Shared FS Instance parameters
#####################################################

variable "pi_create_separate_fsshare_instance" {
  description = "Deploy separate IBM PowerVS instance(0.5 cpus, 2 GB memory size, shared processor on s922.) as central file system share. All filesystems defined in 'pi_fsshare_instance_storage_config' optional variable will be NFS exported and mounted on Netweaver PowerVS instances."
  type        = bool
}

variable "pi_fsshare_instance_image_id" {
  description = "Image ID used for PowerVS fsshare instance. Run 'ibmcloud pi images' to list available images."
  type        = string
  default     = null
}

variable "pi_fsshare_instance_cpu_number" {
  description = "Number of CPUs for fsshare instance."
  type        = string
  default     = ".5"
}

variable "pi_fsshare_instance_memory_size" {
  description = "Memory size for fsshare instance."
  type        = string
  default     = "2"
}

variable "pi_fsshare_instance_cpu_proc_type" {
  description = "Dedicated or shared processors. "
  type        = string
  default     = "shared"
}

variable "pi_fsshare_instance_storage_config" {
  description = "File systems to be created and attached to PowerVS instance for shared storage file systems. 'size' is in GB. 'count' specify over how many storage volumes the file system will be striped. 'tier' specifies the storage tier in PowerVS workspace. 'mount' specifies the target mount point on OS."
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

#####################################################
# PowerVS HANA Instance parameters
#####################################################

variable "pi_hana_instance_name" {
  description = "SAP HANA hostname (non FQDN). Will get the form of <var.prefix>-<var.pi_hana_instance_name>. Max length of final hostname must be <= 13 characters."
  type        = string
  default     = "hana"
}

variable "pi_hana_instance_sap_profile_id" {
  description = "SAP HANA profile to use. Must be one of the supported profiles. See [here](https://cloud.ibm.com/docs/sap?topic=sap-hana-iaas-offerings-profiles-power-vs). File system sizes are automatically calculated. Override automatic calculation by setting values in optional 'pi_hana_instance_custom_storage_config' parameter."
  type        = string
  default     = "ush1-4x256"
}

variable "pi_hana_instance_image_id" {
  description = "Image ID used for PowerVS HANA instance. Run 'ibmcloud pi images' to list available images."
  type        = string
}

variable "pi_hana_instance_custom_storage_config" {
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

variable "pi_hana_instance_additional_storage_config" {
  description = "Additional File systems to be created and attached to PowerVS instance for SAP HANA. 'size' is in GB. 'count' specify over how many storage volumes the file system will be striped. 'tier' specifies the storage tier in PowerVS workspace. 'mount' specifies the target mount point on OS."
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

#####################################################
# PowerVS NetWeaver Instance parameters
#####################################################

variable "pi_netweaver_instance_count" {
  description = "Number of SAP NetWeaver instances that should be created."
  type        = number
  default     = 1
}

variable "pi_netweaver_instance_name" {
  description = "SAP Netweaver hostname (non FQDN). Will get the form of <var.prefix>-<var.pi_netweaver_instance_name>-<number>. Max length of final hostname must be <= 13 characters."
  type        = string
  default     = "nw"
}

variable "pi_netweaver_instance_image_id" {
  description = "Image ID used for PowerVS Netweaver instance. Run 'ibmcloud pi images' to list available images."
  type        = string
  default     = null
}

variable "pi_netweaver_instance_cpu_number" {
  description = "Number of CPUs for each SAP NetWeaver instance."
  type        = string
  default     = "3"
}

variable "pi_netweaver_instance_memory_size" {
  description = "Memory size for each SAP NetWeaver instance."
  type        = string
  default     = "32"
}

variable "pi_netweaver_instance_cpu_proc_type" {
  description = "Dedicated or shared processors for each SAP NetWeaver instance."
  type        = string
  default     = "shared"
}

variable "pi_netweaver_instance_storage_config" {
  description = "File systems to be created and attached to PowerVS instance for SAP NetWeaver. 'size' is in GB. 'count' specify over how many storage volumes the file system will be striped. 'tier' specifies the storage tier in PowerVS workspace. 'mount' specifies the target mount point on OS."
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

#####################################################
# PVS SAP instance Initialization
#####################################################

variable "pi_instance_init_linux" {
  description = "Configures a PowerVS linux instance to have internet access by setting proxy on it, updates os and create filesystems using ansible collection [ibm.power_linux_sap collection](https://galaxy.ansible.com/ui/repo/published/ibm/power_linux_sap/). where 'proxy_host_or_ip_port' E.g., 10.10.10.4:3128 <ip:port>, 'bastion_host_ip' is public IP of bastion/jump host to access the private IP of created linux PowerVS instance."
  sensitive   = true
  type = object(
    {
      enable                = bool
      bastion_host_ip       = string
      ssh_private_key       = string
      proxy_host_or_ip_port = string
      no_proxy_hosts        = string
    }
  )
}

variable "sap_network_services_config" {
  description = "Configures network services NTP, NFS and DNS on PowerVS instance. Requires 'pi_instance_init_linux' to be specified as internet access is required to download ansible collection [ibm.power_linux_sap collection](https://galaxy.ansible.com/ui/repo/published/ibm/power_linux_sap/) to configure these services."
  type = object(
    {
      nfs = object({ enable = bool, nfs_server_path = string, nfs_client_path = string })
      dns = object({ enable = bool, dns_server_ip = string })
      ntp = object({ enable = bool, ntp_server_ip = string })
    }
  )

  default = {
    nfs = { enable = false, nfs_server_path = "", nfs_client_path = "" }
    dns = { enable = false, dns_server_ip = "" }
    ntp = { enable = false, ntp_server_ip = "" }
  }

}

variable "sap_domain" {
  description = "SAP domain to be set for entire landscape."
  type        = string
  default     = "sap.com"
}
