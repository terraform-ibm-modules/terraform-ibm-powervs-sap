variable "bastion_public_ip" {
  description = "Public IP of Bastion Host"
  type        = string
}

variable "host_private_ip" {
  description = "Private IP of NetWeaver/HANA Host reachable from bastion"
  type        = string
}

variable "ssh_private_key" {
  description = "Private Key to configure Instance, Will not be uploaded to server"
  type        = string
}

variable "vpc_bastion_proxy_config" {
  description = "SQUID configuration if required on HANA/nw node to reach public internet via the Bastion host on VSI running SQUID server"
  type        = map(any)
  default = {
    required               = false
    vpc_bastion_private_ip = ""
    no_proxy_ips           = ""
  }
}

variable "os_activation" {
  description = "SuSe activation username, password and Os release to register Os. Release value should be in for x.x. For example SLES15 SP3, value would be 15.3"
  type        = map(any)
  default = {
    required            = false
    activation_username = ""
    activation_password = ""
    os_release          = "15.3"
  }
}

variable "pvs_instance_storage_config" {
  description = "Disks properties to create filesystems"
  type        = map(any)
  default = {
    names      = ""
    paths      = ""
    disks_size = ""
    counts     = ""
    wwns       = ""
  }
}

variable "sap_solution" {
  description = "To Execute Playbooks for Hana or NetWeaver. Value can be either HANA OR NETWEAVER"
  type        = string
}
