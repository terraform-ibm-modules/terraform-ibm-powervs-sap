output "infrastructure_data" {
  description = "Data from PowerVS infrastructure layer"
  value       = jsondecode(data.ibm_schematics_output.schematics_output.output_json)
}

output "access_host_or_ip" {
  description = "Public IP of Provided Bastion/JumpServer Host"
  value       = module.sap_systems.access_host_or_ip
}

output "hana_ips" {
  description = "All private IPS of HANA instance"
  value       = module.sap_systems.hana_instance_private_ips
}

output "netweaver_ips" {
  description = "All private IPS of NetWeaver instances"
  value       = module.sap_systems.netweaver_instance_private_ips
}

output "share_fs_ips" {
  description = "Private IPs of the Share FS instance."
  value       = module.sap_systems.share_fs_instance_private_ips
}
