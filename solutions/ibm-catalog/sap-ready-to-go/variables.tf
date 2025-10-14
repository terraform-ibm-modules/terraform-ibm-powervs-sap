variable "ibmcloud_api_key" {
  description = "IBM Cloud platform API key needed to deploy IAM enabled resources."
  type        = string
  sensitive   = true
}

variable "powervs_zone" {
  description = "IBM Cloud data center location where IBM PowerVS infrastructure will be created."
  type        = string
}

variable "powervs_resource_group_name" {
  description = "Existing IBM Cloud resource group name."
  type        = string
}

variable "prefix" {
  description = "Unique prefix for resources to be created (e.g., SAP system name). Must be an alphanumeric string with maximum length of 8 characters."
  type        = string
  validation {
    condition = (
      var.prefix != null &&
      var.prefix != "" &&
      length(var.prefix) <= 8 &&
      can(regex("^[a-z0-9-]+$", var.prefix))
    )
    error_message = "Prefix must be up to 8 characters long and may include lowercase letters, numbers, and hyphens only."
  }
}

variable "powervs_sap_network_cidr" {
  description = "Network range for dedicated SAP network. Used for communication between SAP Application servers with SAP HANA Database. E.g., '10.51.0.0/24'"
  type        = string
  default     = "10.51.0.0/24"
}

variable "os_image_distro" {
  description = "Image distribution to use for all instances(HANA, NetWeaver). OS release versions may be specified in 'powervs_sap_default_images' optional parameters below."
  type        = string

  validation {
    condition     = (upper(var.os_image_distro) == "RHEL" || upper(var.os_image_distro) == "SLES")
    error_message = "Supported values are 'RHEL' or 'SLES' only."
  }
}

variable "external_access_ip" {
  description = "Specify the IP address or CIDR to login through SSH to the environment after deployment. Access to this environment will be allowed only from this IP address."
  type        = string
}


#####################################################
# PowerVS HANA Instance parameters
#####################################################

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

variable "powervs_netweaver_instance_count" {
  description = "Number of PowerVS SAP NetWeaver instances that should be created. 'powervs_netweaver_instance_count' cannot exceed 10."
  type        = number
  default     = 1
}

variable "powervs_netweaver_cpu_number" {
  description = "Number of CPUs for each PowerVS SAP NetWeaver instance."
  type        = string
  default     = "3"
}

variable "powervs_netweaver_memory_size" {
  description = "Memory size for each PowerVS SAP NetWeaver instance."
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

variable "ssh_public_key" {
  description = "Public SSH Key for VSI creation. Must be an RSA key with a key size of either 2048 bits or 4096 bits (recommended). Must be a valid SSH key that does not already exist in the deployment region."
  type        = string
}

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

variable "nfs_server_config" {
  description = "Configuration for the NFS server. 'size' is in GB, 'iops' is maximum input/output operation performance bandwidth per second, 'mount_path' defines the target mount point on os. Set 'configure_nfs_server' to false to ignore creating file storage share."
  type = object({
    size       = number
    iops       = number
    mount_path = string
  })

  default = {
    "size" : 200,
    "iops" : 600,
    "mount_path" : "/nfs"
  }
}

#####################################################
# Parameters for Image
#####################################################
variable "vpc_intel_images" {
  description = "Stock OS image names for creating VPC landing zone VSI instances: RHEL (management and network services) and SLES (monitoring)."
  type = object({
    rhel_image = string
    sles_image = string
  })
  default = {
    "rhel_image" : "ibm-redhat-9-6-amd64-sap-applications-1"
    "sles_image" : "ibm-sles-15-7-amd64-sap-applications-1"
  }
}

variable "powervs_default_sap_images" {
  description = "Default SUSE and Red Hat Linux Full Linux subscription images to use for PowerVS SAP HANA and SAP NetWeaver instances. If you're using a byol or a custom RHEL/SLES image, additionally specify the optional values for 'powervs_os_registration_username', 'powervs_os_registration_password' and 'ansible_vault_password'"
  type = object({
    sles_hana_image = string
    sles_nw_image   = string
    rhel_hana_image = string
    rhel_nw_image   = string
  })
  default = {
    "sles_hana_image" : "SLES15-SP6-SAP",
    "rhel_hana_image" : "RHEL9-SP4-SAP",
    "sles_nw_image" : "SLES15-SP6-SAP-NETWEAVER",
    "rhel_nw_image" : "RHEL9-SP4-SAP-NETWEAVER"
  }
}

variable "powervs_os_registration_username" {
  description = "If you're using a byol or a custom RHEL/SLES image for SAP HANA and Netweaver you need to provide your OS registration credentials here. Leave empty if you're using an IBM provided subscription (FLS)."
  type        = string
  default     = ""
}

variable "powervs_os_registration_password" {
  description = "If you're using a byol or a custom RHEL/SLES image for SAP HANA and Netweaver you need to provide your OS registration credentials here. Leave empty if you're using an IBM provided subscription (FLS)."
  type        = string
  sensitive   = true
  default     = ""
}

variable "powervs_custom_images" {
  description = "Optionally import up to three custom images from Cloud Object Storage into PowerVS workspace. Requires 'powervs_custom_image_cos_configuration' to be set. image_name: string, must be unique. Name of image inside PowerVS workspace. file_name: string, object key of image inside COS bucket. storage_tier: string, storage tier which image will be stored in after import. Supported values: tier0, tier1, tier3, tier5k. sap_type: optional string, Supported values: null, Hana, Netweaver, use null for non-SAP image."
  type = object({
    powervs_custom_image1 = object({
      image_name   = string
      file_name    = string
      storage_tier = string
      sap_type     = optional(string)
    }),
    powervs_custom_image2 = object({
      image_name   = string
      file_name    = string
      storage_tier = string
      sap_type     = optional(string)
    }),
    powervs_custom_image3 = object({
      image_name   = string
      file_name    = string
      storage_tier = string
      sap_type     = optional(string)
    })
  })
  default = {
    "powervs_custom_image1" : {
      "image_name" : "",
      "file_name" : "",
      "storage_tier" : "",
      "sap_type" : null
    },
    "powervs_custom_image2" : {
      "image_name" : "",
      "file_name" : "",
      "storage_tier" : "",
      "sap_type" : null
    },
    "powervs_custom_image3" : {
      "image_name" : "",
      "file_name" : "",
      "storage_tier" : "",
      "sap_type" : null
    }
  }
}

variable "powervs_custom_image_cos_configuration" {
  description = "Cloud Object Storage bucket containing custom PowerVS images. bucket_name: string, name of the COS bucket. bucket_access: string, possible values: public, private (private requires powervs_custom_image_cos_service_credentials). bucket_region: string, COS bucket region"
  type = object({
    bucket_name   = string
    bucket_access = string
    bucket_region = string
  })
  default = {
    "bucket_name" : "",
    "bucket_access" : "",
    "bucket_region" : ""
  }
}

variable "powervs_custom_image_cos_service_credentials" {
  description = "Service credentials for the Cloud Object Storage bucket containing the custom PowerVS images. The bucket must have HMAC credentials enabled. Click [here](https://cloud.ibm.com/docs/cloud-object-storage?topic=cloud-object-storage-service-credentials) for a json example of a service credential."
  type        = string
  sensitive   = true
  default     = null
}


#####################################################
# Optional Parameters VPN and Secrets Manager
#####################################################

variable "client_to_site_vpn" {
  description = "VPN configuration - the client ip pool and list of users email ids to access the environment. If enabled, then a Secret Manager instance is also provisioned with certificates generated. See optional parameters to reuse an existing Secrets manager instance."
  type = object({
    enable                        = bool
    client_ip_pool                = string
    vpn_client_access_group_users = list(string)
  })

  default = {
    "enable" : true,
    "client_ip_pool" : "192.168.0.0/16",
    "vpn_client_access_group_users" : []
  }
}

variable "sm_service_plan" {
  type        = string
  description = "The service/pricing plan to use when provisioning a new Secrets Manager instance. Allowed values: `standard` and `trial`. Only used if `existing_sm_instance_guid` is set to null."
  default     = "standard"
}

variable "existing_sm_instance_guid" {
  type        = string
  description = "An existing Secrets Manager GUID. If not provided a new instance will be provisioned."
  default     = null
}

variable "existing_sm_instance_region" {
  type        = string
  description = "Required if value is passed into `var.existing_sm_instance_guid`."
  default     = null

}

#####################################################
# Parameters Monitoring
#####################################################

variable "enable_monitoring" {
  description = "Specify whether Monitoring will be enabled. This includes the creation of an IBM Cloud Monitoring Instance and an Intel Monitoring Instance to host the services. If you already have an existing monitoring instance then specify in optional parameter 'existing_monitoring_instance_crn'."
  type        = bool
}

variable "existing_monitoring_instance_crn" {
  description = "Existing CRN of IBM Cloud Monitoring Instance. If value is null, then an IBM Cloud Monitoring Instance will not be created but an intel VSI instance will be created if 'enable_monitoring' is true. "
  type        = string
  default     = null
}

#################################################
# Parameters SCC Workload Protection
#################################################

variable "enable_scc_wp" {
  description = "Set to true to enable SCC Workload Protection and install and configure the SCC Workload Protection agent on all VSIs and PowerVS instances in this deployment."
  type        = bool
}

variable "ansible_vault_password" {
  description = "Vault password to encrypt ansible playbooks that contain sensitive information. Required when SCC workload Protection is enabled. Password requirements: 15-100 characters and at least one uppercase letter, one lowercase letter, one number, and one special character. Allowed characters: A-Z, a-z, 0-9, !#$%&()*+-.:;<=>?@[]_{|}~."
  type        = string
  sensitive   = true
  default     = ""
}

variable "tags" {
  description = "List of tag names for the IBM Cloud PowerVS workspace"
  type        = list(string)
  default     = []
}

#####################################################
# Optional Parameters VPC subnets
#####################################################

variable "vpc_subnet_cidrs" {
  description = "CIDR values for the VPC subnets to be created. It's customer responsibility that none of the defined networks collide, including the PowerVS subnets and VPN client pool."
  type = object({
    vpn  = string
    mgmt = string
    vpe  = string
    edge = string
  })
  default = {
    "vpn"  = "10.30.10.0/24"
    "mgmt" = "10.30.20.0/24"
    "vpe"  = "10.30.30.0/24"
    "edge" = "10.30.40.0/24"
  }
}
