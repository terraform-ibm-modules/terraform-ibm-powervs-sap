variable "bastion_host" {
  description = "Public IP of bastion host."
  type        = string
}

variable "host" {
  description = "Private IP of instance reachable from the bastion host."
  type        = string
}

variable "ssh_private_key" {
  description = "Private Key to configure Instance, will not be uploaded to server."
  type        = string
  sensitive   = true
}

variable "src_script_template_name" {
  description = "Bash template script filename."
  type        = string
}

variable "dst_script_file_name" {
  description = "Bash script filename."
  type        = string
}

variable "src_playbook_template_name" {
  description = "Playbook template filename."
  type        = string
}

variable "dst_playbook_file_name" {
  description = "Playbook filename."
  type        = string
}

variable "playbook_template_content" {
  description = "Playbook template content."
  type        = map(any)
}
