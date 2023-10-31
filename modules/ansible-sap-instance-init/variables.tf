variable "access_host_or_ip" {
  description = "Public IP of Bastion Host"
  type        = string
}

variable "sap_domain" {
  description = "Domain name to be set."
  type        = string
  default     = ""
}

variable "target_server_ip" {
  description = "List of private IPs of PowerVS instances reachable from the access host."
  type        = string
}

variable "ssh_private_key" {
  description = "Private Key to configure Instance, Will not be uploaded to server."
  type        = string
  sensitive   = true
}

variable "sap_solution" {
  description = "SAP solution configuration to be executed on the PowerVS instances defined in 'target_server_ip'. Possible values are 'HANA', 'NETWEAVER', 'NONE'."
  type        = string
}
