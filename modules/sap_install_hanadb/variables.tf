
variable "access_host_or_ip" {
  description = "Public IP of Bastion Host"
  type        = string
}

variable "target_server_ip" {
  description = "Private IP of PowerVS instance reachable from the access host."
  type        = string
}

variable "ssh_private_key" {
  description = "Private Key to configure Instance, Will not be uploaded to server."
  type        = string
  sensitive   = true
}

variable "ansible_vault_password" {
  description = "Vault password to encrypt ansible variable file for SAP installation"
  type        = string
  sensitive   = true
}

variable "hana_template" {
  description = "Template name for installation. Supported values are s4hana, bw4hana"
  type        = string
  validation {
    condition     = (upper(var.hana_template) == "S4B4")
    error_message = "Supported values are 'S4B4"
  }
}

variable "ansible_sap_hana_vars" {
  description = "Ansible SAP HANA variables for HANA DB installation"
  type        = map(any)
  sensitive   = true
}
