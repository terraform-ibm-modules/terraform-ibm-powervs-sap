#####################################################
# PowerVS Service parameters
# Copyright 2022 IBM
#####################################################

variable "greenfield" {
  description = "Specifies if PowerVS service is created in the workflow directly (greenfield deployment)."
  type        = bool
  default     = false
}

variable "pvs_zone" {
  description = "IBM Cloud Zone"
  type        = string
}

variable "pvs_resource_group_name" {
  description = "Existing PowerVS service resource group Name"
  type        = string
}

variable "pvs_service_name" {
  description = "Existing Name of the PowerVS service"
  type        = string
}

variable "pvs_sshkey_name" {
  description = "Existing SSH key name"
  type        = string
}

variable "pvs_cloud_connection_count" {
  description = "Required number of Cloud connections which will be created/Reused. Maximum is 2 per location"
  type        = string
  default     = 0
}

variable "pvs_additional_networks" {
  description = "Existing list of subnets name to be attached to node. First network has to be a management network"
  type        = list(any)
}

#####################################################
# PowerVS HANA Instance parameters
# Copyright 2022 IBM
#####################################################

variable "pvs_hana_instance_name" {
  description = "Name of instance which will be created"
  type        = string
}

variable "pvs_hana_image_name" {
  description = "Image Names to import into the service"
  type        = string
}

variable "pvs_hana_sap_profile_id" {
  description = "SAP PROFILE ID. If this is mentioned then Memory, processors, proc_type and sys_type will not be taken into account"
  type        = string
  default     = null
}

variable "pvs_hana_storage_config" {
  description = "DISKS To be created and attached to node.Comma separated values"
  type        = map(any)
  default = {
    names      = ""
    paths      = ""
    disks_size = ""
    counts     = ""
    tiers      = ""
  }
}

#####################################################
# PowerVS NetWeaver Instance parameters
# Copyright 2022 IBM
#####################################################

variable "pvs_netweaver_instance_name" {
  description = "Name of instance which will be created"
  type        = string
}

variable "pvs_netweaver_image_name" {
  description = "Image Names to import into the service"
  type        = string
}

variable "pvs_netweaver_number_of_instances" {
  description = "Number of instances"
  type        = string
  default     = 1
}

variable "pvs_netweaver_server_type" {
  description = "Processor type e980, s922, s1022 or e1080"
  type        = string
  default     = "s922"
}

variable "pvs_netweaver_cpu_proc_type" {
  description = "Dedicated or shared processors"
  type        = string
  default     = "shared"
}

variable "pvs_netweaver_number_of_processors" {
  description = "Number of processors"
  type        = string
}

variable "pvs_netweaver_memory_size" {
  description = "Amount of memory"
  type        = string
}

variable "pvs_netweaver_storage_config" {
  description = "DISKS To be created and attached to node.Comma separated values"
  type        = map(any)
  default = {
    names      = ""
    paths      = ""
    disks_size = ""
    counts     = ""
    tiers      = ""
  }
}

#####################################################
# PowerVS Shared FS Instance parameters
# Copyright 2022 IBM
#####################################################

variable "pvs_share_instance_name" {
  description = "Name of instance which will be created"
  type        = string
}

variable "pvs_share_image_name" {
  description = "Image Names to import into the service"
  type        = string
}

variable "pvs_share_number_of_instances" {
  description = "Number of instances"
  type        = string
  default     = 1
}

variable "pvs_share_server_type" {
  description = "Processor type e980, s922, s1022 or e1080"
  type        = string
  default     = "s922"
}

variable "pvs_share_cpu_proc_type" {
  description = "Dedicated or shared processors"
  type        = string
  default     = "shared"
}

variable "pvs_share_number_of_processors" {
  description = "Number of processors"
  type        = string
  default     = 0.5
}

variable "pvs_share_memory_size" {
  description = "Amount of memory"
  type        = string
  default     = 2
}

variable "pvs_share_storage_config" {
  description = "DISKS To be created and attached to node.Comma separated values"
  type        = map(any)
  default = {
    names      = ""
    paths      = ""
    disks_size = ""
    counts     = ""
    tiers      = ""
  }
}

#####################################################
# PVS SAP instance Initialization
# Copyright 2022 IBM
#####################################################

variable "access_host_or_ip" {
  description = "Public IP of Bastion/jumpserver Host"
  type        = string
}

/***
variable "ssh_private_key" {
  description = "Private Key to configure Instance, Will not be uploaded to server"
  type        = string
}

variable "proxy_ip_or_post" {
  description = "Proxy hosname or IP address with port. E.g., 10.10.10.4:3128"
  type        = string
  default     = null
}

variable "nfs_server_ip_or_post" {
  description = "NFS server hosname or IP address. E.g., 10.10.10.5"
  type        = string
  default     = null
}

variable "dns_ip_or_post" {
  description = "DNS forwarder/server hosname or IP address. E.g., 10.10.10.6"
  type        = string
  default     = null
}

variable "ntp_ip_or_post" {
  description = "NTP forwarder/server hosname or IP address. E.g., 10.10.10.7"
  type        = string
  default     = null
}

variable "os_activation" {
  description = "SUSE/RHEL activation email and code to register OS. Used only for OS images without IBM subscription."
  type        = map(any)
  default = {
    required            = false
    activation_username = ""
    activation_password = ""
  }
}

variable "sap_domain" {
  description = "Domain name to be set. Required when using RHEL image"
  type        = string
  default     = null
}


#### weiter hier
variable "hana_hostname" {
  description = "Hostname for HANA instance"
  type        = string
  default     = null
}

variable "netweaver_hostnames" {
  description = "Domain name to be set. Required when using RHEL image"
  type        = list(string)
  default     = null
}

variable "sap_solution" {
  description = "To Execute Playbooks for Hana or NetWeaver. Value can be either HANA OR NETWEAVER"
  type        = string
}
***/

variable "pvs_sap_network" {
  description = "New Network for SAP system"
  type        = map(any)
}
