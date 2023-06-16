variable "access_host_or_ip" {
  description = "Public IP of Bastion Host"
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
  sensitive   = true
}

variable "sap_solutions" {
  description = "List of SAP solution configurations to be executed on the PowerVS instances defined in 'target_server_ips'. The order should match to 'target_server_ips'. Possible values are 'HANA', 'NETWEAVER', 'NONE'."
  type        = list(string)
}
