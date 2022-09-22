variable "access_host_or_ip" {
  description = "Public IP of Bastion Host"
  type        = string
}

variable "os_image_distro" {
  description = "Image distribution to use. Supported values are 'SLES' or 'RHEL'. OS release versions may be specified in optional parameters."
  type        = string
}

variable "sap_domain" {
  description = "Domain name to be set."
  type        = string
  default     = ""
}

variable "target_server_ips" {
  description = "List of private IPs of PowerVS instances reachable from the access host."
  type        = list(string)
}

variable "ssh_private_key" {
  description = "Private Key to configure Instance, Will not be uploaded to server."
  type        = string
}

variable "sap_solutions" {
  description = "List of SAP solution configurations to be executed on the PowerVS instances defined in 'target_server_ips'. The order should match to 'target_server_ips'. Possible values are 'HANA', 'NETWEAVER', 'NONE'."
  type        = list(string)
}


variable "powervs_instance_storage_configs" {
  description = "List of storage configurations for PowerVS instances defined in 'target_server_ips'. The order should match to 'target_server_ips'. Storage configurations have following form: '{names = \"\" disks_size = \"\" counts = \"\" tiers = \"\" paths = \"\" wwns = \"\"}'"
  type = list(object(
    {
      names      = string
      disks_size = string
      counts     = string
      tiers      = string
      paths      = string
      wwns       = string
    }
    )
  )
}

variable "perform_proxy_client_setup" {
  description = "Configures a PowerVS instance to have internet access by setting proxy on it. E.g., 10.10.10.4:3128 <ip:port>"
  type = object(
    {
      enable         = bool
      server_ip_port = string
      no_proxy_hosts = string
    }
  )
  default = {
    enable         = false
    server_ip_port = ""
    no_proxy_hosts = ""
  }
}

variable "perform_ntp_client_setup" {
  description = "Configures a PowerVS instance to use NTP server."
  type = object(
    {
      enable    = bool
      server_ip = string
    }
  )
  default = {
    enable    = false
    server_ip = ""
  }
}

variable "perform_dns_client_setup" {
  description = "Configures a PowerVS instance to use DNS server."
  type = object(
    {
      enable    = bool
      server_ip = string
    }
  )
  default = {
    enable    = false
    server_ip = ""
  }
}

variable "perform_nfs_client_setup" {
  description = "Mounts NFS share on PowerVS instance."
  type = object(
    {
      enable          = bool
      nfs_server_path = string
      nfs_client_path = string
    }
  )
  default = {
    enable          = false
    nfs_server_path = ""
    nfs_client_path = ""
  }
}
