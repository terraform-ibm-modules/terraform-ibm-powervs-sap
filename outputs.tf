output "access_host_or_ip" {
  description = "Public IP to manage the environment"
  value       = var.access_host_or_ip
}

output "hana_instance_private_ips" {
  description = "Private IPs of the HANA instance."
  value       = module.sap_hana_instance.instance_private_ips
}

output "hana_instance_management_ip" {
  description = "Management IP of HANA Instance"
  value       = module.sap_hana_instance.instance_mgmt_ip
}

output "netweaver_instance_private_ips" {
  description = "Private IPs of all NetWeaver instances."
  value       = module.sap_netweaver_instance[*].instance_private_ips
}

output "share_fs_instance_private_ips" {
  description = "Private IPs of the Share FS instance."
  value       = module.share_fs_instance[*].instance_private_ips
}
