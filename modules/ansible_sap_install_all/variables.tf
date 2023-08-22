
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

variable "solution_template" {
  description = "Template name for installation. Supported values are 's4b4_solution', 's4b4_hana'"
  type        = string
  validation {
    condition     = contains(["s4b4_solution", "s4b4_hana"], var.solution_template)
    error_message = "Supported values are 's4b4_solution', 's4b4_hana'"
  }
}

variable "ansible_sap_solution_vars" {
  description = "Ansible SAP solution variables"
  type        = map(any)
  sensitive   = true
}
