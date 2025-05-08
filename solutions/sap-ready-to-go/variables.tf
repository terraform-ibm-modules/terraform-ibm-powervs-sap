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
    condition     = length(var.prefix) <= 6 && can(regex("^[A-Za-z0-9]+$", var.prefix))
    error_message = "Prefix must be an alphanumeric string with maximum length of 6 characters."
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
  description = "Network range for dedicated SAP network. Used for communication between SAP Application servers with SAP HANA Database. E.g., '10.53.0.0/24'"
  type        = string
}


#####################################################
# PowerVS HANA Instance parameters
#####################################################

variable "powervs_hana_instance_image_id" {
  description = "Image ID to be used for PowerVS HANA instance. Run 'ibmcloud pi images' to list available images."
  type        = string
}

variable "powervs_hana_instance" {
  description = "PowerVS SAP HANA instance hostname (non FQDN) will get the form of <var.prefix>-<var.powervs_hana_instance_name>. PowerVS SAP HANA instance profile to use. Must be one of the supported profiles. See [here](https://cloud.ibm.com/docs/sap?topic=sap-hana-iaas-offerings-profiles-power-vs). File system sizes are automatically calculated. Override automatic calculation by setting values in optional 'powervs_hana_instance_custom_storage_config' parameter. Additional File systems to be created and attached to PowerVS instance for SAP HANA. 'size' is in GB. 'count' specify over how many storage volumes the file system will be striped. 'tier' specifies the storage tier in PowerVS workspace. 'mount' specifies the target mount point on OS."
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
    "name" : "hana",
    "sap_profile_id" : "ush1-4x256",
    "additional_storage_config" : [{
      "name" : "usrsap",
      "size" : "50",
      "count" : "1",
      "tier" : "tier3",
      "mount" : "/usr/sap"
    }]
  }
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

#####################################################
# PowerVS NetWeaver Instance parameters
#####################################################

variable "powervs_netweaver_instance_image_id" {
  description = "Image ID to be used for PowerVS NetWeaver instance. Run 'ibmcloud pi images' to list available images."
  type        = string
}

variable "powervs_netweaver_instance" {
  description = "PowerVS SAP NetWeaver instance hostname (non FQDN). Will get the form of <var.prefix>-<var.powervs_netweaver_instance_name>-<number>. Max length of final hostname must be <= 13 characters.. 'instance_count' is number of PowerVS SAP NetWeaver instances that should be created. 'size' is in GB. 'count' specify over how many storage volumes the file system will be striped. 'tier' specifies the storage tier in PowerVS workspace. 'mount' specifies the target mount point on OS. "
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
    "instance_count" : "1",
    "name" : "nw",
    "processors" : "3",
    "memory" : "32",
    "proc_type" : "shared",
    "storage_config" : [{
      "name" : "usrsap",
      "size" : "50",
      "count" : "1",
      "tier" : "tier3",
      "mount" : "/usr/sap"
    }]
  }
}

#####################################################
# OS parameters
#####################################################

variable "powervs_instance_init_linux" {
  description = "Configures a PowerVS linux instance to have internet access by setting proxy on it, updates os and create filesystems using ansible collection [ibm.power_linux_sap collection](https://galaxy.ansible.com/ui/repo/published/ibm/power_linux_sap/) where 'bastion_host_ip' is public IP of bastion/jump host to access the 'ansible_host_or_ip' private IP of ansible node. This ansible host must have access to the power virtual server instance and ansible host OS must be RHEL distribution. When using a custom image or a byol image, you need to provide os registration credentials and an ansible vault password."
  sensitive   = true
  type = object(
    {
      enable             = bool
      bastion_host_ip    = string
      ansible_host_or_ip = string
      ssh_private_key    = string
      custom_os_registration = optional(object({
        username = string
        password = string
      }))
    }
  )
}

variable "ansible_vault_password" {
  description = "Vault password to encrypt OS registration parameters. Required only if you bring your own linux license. Password requirements: 15-100 characters and at least one uppercase letter, one lowercase letter, one number, and one special character. Allowed characters: A-Z, a-z, 0-9, !#$%&()*+-.:;<=>?@[]_{|}~."
  type        = string
  sensitive   = true
  default     = null
}

variable "sap_network_services_config" {
  description = "Configures network services NTP, NFS and DNS on PowerVS instance. Requires 'pi_instance_init_linux' to be specified."
  type = object(
    {
      squid = object({ enable = bool, squid_server_ip_port = string, no_proxy_hosts = string })
      nfs   = object({ enable = bool, nfs_server_path = string, nfs_client_path = string, opts = string, fstype = string })
      dns   = object({ enable = bool, dns_server_ip = string })
      ntp   = object({ enable = bool, ntp_server_ip = string })
    }
  )

  default = {
    squid = { enable = false, squid_server_ip_port = "", no_proxy_hosts = "" }
    nfs   = { enable = false, nfs_server_path = "", nfs_client_path = "", opts = "", fstype = "" }
    dns   = { enable = false, dns_server_ip = "" }
    ntp   = { enable = false, ntp_server_ip = "" }
  }
}

variable "sap_domain" {
  description = "SAP network domain name."
  type        = string
  default     = "sap.com"
}

variable "scc_wp_instance" {
  description = "SCC Workload Protection instance to connect to. Set enable to false to not use it."
  type = object({
    enable             = bool
    guid               = string,
    access_key         = string,
    api_endpoint       = string,
    ingestion_endpoint = string
  })
  default = {
    enable             = false
    guid               = "",
    access_key         = "",
    api_endpoint       = "",
    ingestion_endpoint = ""
  }
}

variable "os_image_distro" {
  description = "Image distribution that's used for all instances(HANA, NetWeaver). Only required for hotfix of networks getting attached in random order. Will be removed in future releases. Possible values: RHEL or SLES."
  type        = string

  validation {
    condition     = (upper(var.os_image_distro) == "RHEL" || upper(var.os_image_distro) == "SLES")
    error_message = "Supported values are 'RHEL' or 'SLES' only."
  }
}
