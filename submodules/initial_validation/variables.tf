variable "configure_os_validate" {
  description = "Verify configure_os variable with access_host_or_ip, ssh_private_key and proxy_host_or_ip_port"
  type = object({
    configure_os          = bool
    access_host_or_ip     = string
    ssh_private_key       = string
    proxy_host_or_ip_port = string
  })

  validation {
    condition     = var.configure_os_validate["configure_os"] ? var.configure_os_validate["access_host_or_ip"] != null && var.configure_os_validate["access_host_or_ip"] != "" && var.configure_os_validate["ssh_private_key"] != null && var.configure_os_validate["ssh_private_key"] != "" && var.configure_os_validate["proxy_host_or_ip_port"] != null && var.configure_os_validate["proxy_host_or_ip_port"] != "" : true
    error_message = "If configure_os is true then value has to be set for access_host_ip, ssh_private_key and proxy_host_or_ip_port to continue"
  }
}
