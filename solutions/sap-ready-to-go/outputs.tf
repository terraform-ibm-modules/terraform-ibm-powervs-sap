output "access_host_or_ip" {
  description = "Public IP of Provided Bastion/JumpServer Host"
  value       = var.powervs_instance_init_linux.bastion_host_ip
}

output "powervs_hana_instance_ips" {
  description = "All private IPS of HANA instance"
  value       = module.sap_system.pi_hana_instance_ips
}

output "powervs_hana_instance_management_ip" {
  description = "Management IP of HANA Instance"
  value       = module.sap_system.pi_hana_instance_management_ip
}

output "powervs_netweaver_instance_ips" {
  description = "All private IPS of NetWeaver instances"
  value       = module.sap_system.pi_netweaver_instance_ips
}

output "powervs_netweaver_instance_management_ips" {
  description = "Management IPS of NetWeaver instances"
  value       = module.sap_system.pi_netweaver_instance_management_ips
}

output "powervs_share_fs_ips" {
  description = "Private IPs of the Share FS instance."
  value       = module.sap_system.pi_sharefs_instance_ips
}

output "powervs_lpars_data" {
  description = "All private IPS of PowerVS instances and Jump IP to access the host."
  value       = module.sap_system.pi_lpars_data
}
