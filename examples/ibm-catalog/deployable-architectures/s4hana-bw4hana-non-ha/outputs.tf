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

output "hana_instance_management_ip" {
  description = "Management IP of HANA Instance"
  value       = module.sap_systems.hana_instance_management_ip
}

output "netweaver_ips" {
  description = "All private IPS of NetWeaver instances"
  value       = length(module.sap_systems.netweaver_instance_private_ips) >= 1 ? module.sap_systems.netweaver_instance_private_ips : null
}

output "share_fs_ips" {
  description = "Private IPs of the Share FS instance."
  value       = length(module.sap_systems.share_fs_instance_private_ips) >= 1 ? module.sap_systems.share_fs_instance_private_ips : null
}

output "powervs_lpars_data" {
  description = "All private IPS of PowerVS instances and Jump IP to access the host."
  value = {
    "access_host_or_ip"                 = module.sap_systems.access_host_or_ip
    "hana_instance_management_ip"       = module.sap_systems.hana_instance_management_ip
    "hana_instance_ips"                 = module.sap_systems.hana_instance_private_ips
    "netweaver_instances_management_ip" = module.sap_systems.netweaver_instances_management_ip
    "netweaver_ips"                     = length(module.sap_systems.netweaver_instance_private_ips) >= 1 ? module.sap_systems.netweaver_instance_private_ips : null
    "share_fs_ips"                      = length(module.sap_systems.share_fs_instance_private_ips) >= 1 ? module.sap_systems.share_fs_instance_private_ips : null
  }
}
