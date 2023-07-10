
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

variable "sap_hana_vars" {
  description = "SAP HANA variables for HANA DB installation"
  type = object({
    sap_hana_install_software_directory = string
    sap_hana_install_sid                = string
    sap_hana_install_number             = string
    sap_hana_install_master_password    = string
  })
  sensitive = true
}
