output "access_host_or_ip" {
  description = "Public IP to manage the environment"
  value       = var.access_host_or_ip
}

output "hana_instance_private_ips" {
  description = "Private IPs of the HANA instance."
  value       = module.sap_hana_instance.instance_private_ips
}

output "netweaver_instance_private_ips" {
  description = "Private IPs of the NetWeaver instance."
  value       = module.sap_netweaver_instance.*.instance_private_ips
}

output "share_fs_instance_private_ips" {
  description = "Private IPs of the Share FS instance."
  value       = module.share_fs_instance.*.instance_private_ips
}
