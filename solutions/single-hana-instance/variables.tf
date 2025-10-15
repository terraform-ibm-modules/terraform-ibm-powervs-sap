variable "ibmcloud_api_key" {
  description = "The IBM Cloud platform API key needed to deploy IAM enabled resources."
  type        = string
  sensitive   = true
}

variable "powervs_zone" {
  description = "IBM Cloud PowerVS zone."
  type        = string
  validation {
    condition     = contains(["syd04", "syd05", "eu-de-1", "eu-de-2", "lon04", "lon06", "tok04", "us-east", "us-south", "dal10", "dal12", "dal14", "tor01", "osa21", "sao01", "sao04", "mon01", "wdc06", "wdc07", "che01", "mad02", "mad04", "wdc06-pvs-01"], var.powervs_zone)
    error_message = "Only Following DC values are supported :  syd04, syd05, eu-de-1, eu-de-2, lon04, lon06, tok04, us-east, us-south, dal10, dal12, dal14, tor01, osa21, sao01, sao04, mon01, wdc06, wdc07,che01, mad02, mad04, wdc06-pvs-01"
  }
}

variable "powervs_workspace_guid" {
  description = "Existing GUID of the PowerVS workspace. The GUID of the service instance associated with an account."
  type        = string
}

variable "powervs_ssh_public_key_name" {
  description = "Name of the existing PowerVS SSH public key."
  type        = string
}

#####################################################
# PowerVS Instance Parameters
#####################################################

variable "powervs_instance_name" {
  description = "Name of instance which will be created. Must be less than 13 characters."
  type        = string
  validation {
    condition     = length(var.powervs_instance_name) < 13
    error_message = "The instance name must be less than 13 characters."
  }
}

variable "powervs_image_name" {
  description = "Image name used for PowerVS instance. Run 'ibmcloud pi images' to list available images."
  type        = string
}

variable "powervs_boot_image_storage_tier" {
  description = "Storage type for server deployment. If storage type is not provided the storage type will default to tier3. Possible values tier0, tier1 and tier3"
  type        = string
  default     = null
}

variable "powervs_hana_instance_sap_profile_id" {
  description = "PowerVS SAP HANA instance profile to use. Must be one of the supported profiles. See [here](https://cloud.ibm.com/docs/sap?topic=sap-hana-iaas-offerings-profiles-power-vs). File system sizes are automatically calculated. Override automatic calculation by setting values in optional parameter 'powervs_hana_instance_custom_storage_config'."
  type        = string
  default     = "sh2-4x256"
}

variable "powervs_server_type" {
  description = "By default SAP profile will be deployed on default system type. Override this to specify the type of system on which to create the VM. Supported values are s922/e980/s1022/e1050/e1080/s1122/e1150/e1180. Mandatory when using dedicated hosts."
  type        = string
  default     = null
}

variable "powervs_deployment_target" {
  description = "The deployment of a dedicated host. Max items: 1, id is the uuid of the host group or host. type is the deployment target type, supported values are host and hostGroup"
  type = list(object(
    {
      type = string
      id   = string
    }
  ))
  default = null
}

variable "powervs_networks" {
  description = "Existing list of private subnet ids to be attached to an instance. The first element will become the primary interface. Run 'ibmcloud pi subnets' to list available subnets."
  type = list(
    object({
      name = string
      id   = string
      cidr = optional(string)
    })
  )
}

variable "powervs_hana_instance_custom_storage_config" {
  description = "Custom file systems to be created and attached to PowerVS SAP HANA instance. 'size' is in GB. 'count' specify over how many storage volumes the file system will be striped. 'tier' specifies the storage tier in PowerVS workspace. 'mount' specifies the target mount point on OS. If not specified, volumes for '/hana/data', '/hana/log', '/hana/shared' are automatically calculated and created."
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
# PowerVS Instance Initialization Optional parameters.
#####################################################

variable "powervs_instance_init_linux" {
  description = "Configures a PowerVS linux instance to have internet access by setting proxy on it, updates os and create filesystems using ansible collection [ibm.power_linux_sap collection](https://galaxy.ansible.com/ui/repo/published/ibm/power_linux_sap/). where 'proxy_host_or_ip_port' E.g., 10.10.10.4:3128 <ip:port>, 'bastion_host_ip' is public IP of bastion/jump host to access the private IP of created linux PowerVS instance."
  sensitive   = true
  type = object(
    {
      enable             = bool
      bastion_host_ip    = string
      ansible_host_or_ip = string
    }
  )

  default = {
    enable             = false
    bastion_host_ip    = ""
    ansible_host_or_ip = ""
  }
  validation {
    condition     = var.powervs_instance_init_linux.enable == false || (var.powervs_instance_init_linux.enable == true && length(var.powervs_instance_init_linux.bastion_host_ip) > 0 && length(var.powervs_instance_init_linux.ansible_host_or_ip) > 0)
    error_message = "bastion_host_ip and ansible_host_or_ip must be provided when powervs_instance_init_linux is enabled."
  }
}

variable "ssh_private_key" {
  description = "SSH private key to access the PowerVS instance via bastion host."
  type        = string
  sensitive   = true
  default     = ""

  validation {
    condition     = var.powervs_instance_init_linux.enable == false || (var.powervs_instance_init_linux.enable == true && length(var.ssh_private_key) > 0)
    error_message = "ssh_private_key must be provided when powervs_instance_init_linux is enabled."
  }

}
variable "powervs_network_services_config" {
  description = "Configures network services NTP, NFS and DNS on PowerVS instance. Requires 'powervs_instance_init_linux' to be specified as internet access is required to download ansible collection [ibm.power_linux_sap collection](https://galaxy.ansible.com/ui/repo/published/ibm/power_linux_sap/) to configure these services. The 'opts' attribute can take in comma separated values."
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
    ntp   = { enable = false, ntp_server_ip = "" },
    dns   = { enable = false, dns_server_ip = "" }
  }

}

variable "sap_domain" {
  description = "SAP network domain name."
  type        = string
  default     = "sap.com"
}

variable "powervs_os_registration_username" {
  description = "If you're using a byol or a custom RHEL/SLES image for SAP HANA and Netweaver you need to provide your OS registration credentials here. Leave empty if you're using an IBM provided subscription (FLS)."
  type        = string
  default     = null
}

variable "powervs_os_registration_password" {
  description = "If you're using a byol or a custom RHEL/SLES image for SAP HANA and Netweaver you need to provide your OS registration credentials here. Leave empty if you're using an IBM provided subscription (FLS)."
  type        = string
  sensitive   = true
  default     = null
}

variable "ansible_vault_password" {
  description = "Vault password to encrypt ansible playbooks that contain sensitive information. Required with customer provided linux subscription (powervs_os_registration). Password requirements: 15-100 characters and at least one uppercase letter, one lowercase letter, one number, and one special character. Allowed characters: A-Z, a-z, 0-9, !#$%&()*+-.:;<=>?@[]_{|}~."
  type        = string
  sensitive   = true
  default     = ""
}
