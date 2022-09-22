output "access_host_or_ip" {
  description = "Public IP of Provided Bastion/JumpServer Host"
  value       = module.sap_systems.access_host_or_ip
}

output "hana_ips" {
  description = "All private IPS of HANA instance"
  value       = module.sap_systems.hana_instance_private_ips
}

output "entered_data_non_sensitive" {
  description = "User input (non sensitive)"
  value = {
    calculate_hana_fs_sizes_automatically = var.calculate_hana_fs_sizes_automatically
    sap_hana_ip                           = var.sap_hana_ip
    sap_domain_name                       = var.sap_domain_name
    sap_netweaver_ips                     = var.sap_netweaver_ips
    nfs_host_or_ip                        = var.nfs_host_or_ip
    ntp_host_or_ip                        = var.ntp_host_or_ip
    dns_host_or_ip                        = var.dns_host_or_ip
    proxy_host_or_ip                      = var.proxy_host_or_ip
  }
}

output "entered_data_sensitive" {
  description = "User input (ensitive)"
  sensitive   = true
  value = {
    ssh_private_key = var.ssh_private_key
  }
}
