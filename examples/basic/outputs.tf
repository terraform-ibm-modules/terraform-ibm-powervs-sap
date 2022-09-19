output "access_host_or_ip" {
  description = "Public IP of Provided Bastion/JumpServer Host"
  value       = module.sap_systems.access_host_or_ip
}

output "hana_ips" {
  description = "All private IPS of HANA instance"
  value       = module.sap_systems.hana_instance_private_ips
}

output "netweaver_ips" {
  description = "All private IPs of NetWeaver instances"
  value       = module.sap_systems.netweaver_instance_private_ips
}

output "share_fs_ips" {
  description = "All private IPs of share FS instance (if created)"
  value       = module.sap_systems.netweaver_instance_private_ips
}
