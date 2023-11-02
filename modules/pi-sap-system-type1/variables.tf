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
  validation {
    condition     = anytrue([can(regex("^10\\.((([2][0-5]{2})|([0-1]{0,1}[0-9]{1,2}))\\.){2}(([2][0-5]{2})|([0-1]{0,1}[0-9]{1,2}))", var.pi_sap_network_cidr)), can(regex("^192\\.168\\.((([2][0-5]{2})|([0-1]{0,1}[0-9]{1,2}))\\.)(([2][0-5]{2})|([0-1]{0,1}[0-9]{1,2}))", var.pi_sap_network_cidr)), can(regex("^172\\.(([1][6-9])|([2][0-9])|([3][0-1]))\\.((([2][0-5]{2})|([0-1]{0,1}[0-9]{1,2}))\\.)(([2][0-5]{2})|([0-1]{0,1}[0-9]{1,2}))", var.pi_sap_network_cidr))])
    error_message = "Must be a valid private IPv4 CIDR block address."
  }
}


variable "cloud_connection_count" {
  description = "Existing number of Cloud connections to which new subnet must be attached. Will be ignored in case of PER enabled DC."
  type        = string
  default     = 2
}

#####################################################
# PowerVS Shared FS Instance parameters
#####################################################

variable "pi_sharefs_instance" {
  description = "Deploy separate IBM PowerVS instance as central file system share. All filesystems defined in 'pi_sharefs_instance_storage_config' variable will be NFS exported and mounted on Netweaver PowerVS instances if enabled. 'size' is in GB. 'count' specify over how many storage volumes the file system will be striped. 'tier' specifies the storage tier in PowerVS workspace. 'mount' specifies the target mount point on OS."
  type = object({
    enable     = bool
    name       = string
    image_id   = string
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
    enable     = false
    name       = "share"
    image_id   = "insert_value_here"
    processors = "0.5"
    memory     = "2"
    proc_type  = "shared"
    storage_config = [{
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

variable "pi_hana_instance" {
  description = "SAP HANA hostname (non FQDN) will get the form of <var.prefix>-<var.pi_hana_instance_name>. SAP HANA profile to use. Must be one of the supported profiles. See [here](https://cloud.ibm.com/docs/sap?topic=sap-hana-iaas-offerings-profiles-power-vs). File system sizes are automatically calculated. Override automatic calculation by setting values in optional 'pi_hana_instance_custom_storage_config' parameter. 'additional_storage_config' additional file systems to be created and attached to PowerVS instance for SAP HANA. 'size' is in GB. 'count' specify over how many storage volumes the file system will be striped. 'tier' specifies the storage tier in PowerVS workspace. 'mount' specifies the target mount point on OS."
  type = object({
    name           = string
    image_id       = string
    sap_profile_id = string
    additional_storage_config = list(object({
      name  = string
      size  = string
      count = string
      tier  = string
      mount = string
    }))
  })
  default = {
    name           = "hana"
    image_id       = "insert_value_here"
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

#####################################################
# PowerVS NetWeaver Instance parameters
#####################################################

variable "pi_netweaver_instance" {
  description = "'instance_count' is number of SAP NetWeaver instances that should be created. 'size' is in GB. 'count' specify over how many storage volumes the file system will be striped. 'tier' specifies the storage tier in PowerVS workspace. 'mount' specifies the target mount point on OS. "
  type = object({
    instance_count = number
    name           = string
    image_id       = string
    processors     = string
    memory         = string
    proc_type      = string
    storage_config = list(object({
      name  = string
      size  = string
      count = string
      tier  = string
      mount = string
    }))
  })
  default = {
    instance_count = 1
    name           = "nw"
    image_id       = "insert_value_here"
    processors     = "0.5"
    memory         = "2"
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
