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

variable "powervs_workspace_guid" {
  description = "PowerVS infrastructure workspace guid. The GUID of the resource instance."
  type        = string
}

variable "powervs_ssh_public_key_name" {
  description = "Existing PowerVS SSH Public Key Name."
  type        = string
}

variable "powervs_networks" {
  description = "Existing list of subnets to be attached to PowerVS instances. The first element will become the primary interface. Run 'ibmcloud pi networks' to list available private subnets."
  type = list(
    object({
      name = string
      id   = string
      cidr = optional(string)
    })
  )
}

variable "powervs_sap_network_cidr" {
  description = "Additional private subnet for SAP communication which will be created. CIDR for SAP network. E.g., '10.53.0.0/24'"
  type        = string
}

variable "powervs_create_sharefs_instance" {
  description = "value"
  type = object({
    enable   = bool
    image_id = string
  })

}

variable "powervs_hana_instance_image_id" {
  description = "Image ID to be used for PowerVS HANA instance. Run 'ibmcloud pi images' to list available images."
  type        = string
}

variable "powervs_netweaver_instance_image_id" {
  description = "Image ID to be used for PowerVS Netweaver instance. Run 'ibmcloud pi images' to list available images."
  type        = string
}

variable "powervs_instance_init_linux" {
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


#####################################################
#
# Optional Parameters
#
#####################################################

variable "cloud_connection_count" {
  description = "Existing number of Cloud connections to which new subnet must be attached. Will be ignored in case of PER enabled DC."
  type        = string
  default     = 2
}

variable "powervs_sharefs_instance" {
  description = "Deploy separate IBM PowerVS instance as central file system share. All filesystems defined in 'powervs_sharefs_instance_storage_config' variable will be NFS exported and mounted on Netweaver PowerVS instances if enabled. 'size' is in GB. 'count' specify over how many storage volumes the file system will be striped. 'tier' specifies the storage tier in PowerVS workspace. 'mount' specifies the target mount point on OS."
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
    name       = "share"
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

###################################
# PowerVS HANA Instance parameters
###################################

variable "powervs_hana_instance" {
  description = "SAP HANA hostname (non FQDN) will get the form of <var.prefix>-<var.powervs_hana_instance_name>. SAP HANA profile to use. Must be one of the supported profiles. See [here](https://cloud.ibm.com/docs/sap?topic=sap-hana-iaas-offerings-profiles-power-vs). File system sizes are automatically calculated. Override automatic calculation by setting values in optional 'powervs_hana_instance_custom_storage_config' parameter. Additional File systems to be created and attached to PowerVS instance for SAP HANA. 'size' is in GB. 'count' specify over how many storage volumes the file system will be striped. 'tier' specifies the storage tier in PowerVS workspace. 'mount' specifies the target mount point on OS."
  type = object({
    name           = string
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
  }))
  default = [{
    "name" : "",
    "size" : "",
    "count" : "",
    "tier" : "",
    "mount" : ""
  }]
}

########################################
# PowerVS NetWeaver Instance parameters
########################################

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

######################################
# PVS SAP instance Network Services
######################################

variable "sap_network_services_config" {
  description = "Configures network services NTP, NFS and DNS on PowerVS instance. Requires 'powervs_instance_init_linux' to be specified as internet access is required to download ansible collection [ibm.power_linux_sap collection](https://galaxy.ansible.com/ui/repo/published/ibm/power_linux_sap/) to configure these services."
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
