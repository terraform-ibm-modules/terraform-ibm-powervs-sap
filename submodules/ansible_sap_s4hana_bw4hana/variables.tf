variable "access_host_or_ip" {
  description = "Public IP of Bastion Host"
  type        = string
}

variable "target_server_hana_ip" {
  description = "HANA Private IP of PowerVS instance reachable from the access host."
  type        = string
}

variable "target_server_nw_ip" {
  description = "Netweaver Private IP of PowerVS instance reachable from the access host."
  type        = string
}

variable "ssh_private_key" {
  description = "Private Key to configure Instance, Will not be uploaded to server."
  type        = string
  sensitive   = true
}

variable "ansible_parameters" {
  description = "HANA and S4HANA/BW4HANA Installation parameters"
  type = object(
    {
      enable                      = bool
      solution                    = string
      hana_ansible_vars           = map(any)
      netweaver_ansible_vars      = map(any)
      hana_instance_sap_ip        = string
      hana_instance_hostname      = string
      netweaver_instance_hostname = string

    }
  )
}
