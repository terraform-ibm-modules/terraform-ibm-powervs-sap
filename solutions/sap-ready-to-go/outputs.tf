output "infrastructure_data" {
  description = "Data from PowerVS infrastructure layer"
  value       = jsondecode(data.ibm_schematics_output.schematics_output.output_json)
}

output "access_host_or_ip" {
  description = "Public IP of Provided Bastion/JumpServer Host"
  value       = local.access_host_or_ip
}

output "powervs_hana_instance_ips" {
  description = "All private IPS of HANA instance"
  value       = module.sap_hana_instance.pi_instance_private_ips
}

output "powervs_hana_instance_management_ip" {
  description = "Management IP of HANA Instance"
  value       = module.sap_hana_instance.pi_instance_mgmt_ip
}

output "powervs_netweaver_instance_ips" {
  description = "All private IPS of NetWeaver instances"
  value       = var.powervs_netweaver_instance_count >= 1 ? join(",", module.sap_netweaver_instance[*].pi_instance_private_ips) : ""
}

output "powervs_netweaver_instance_management_ips" {
  description = "Management IPS of NetWeaver instances"
  value       = var.powervs_netweaver_instance_count >= 1 ? join(",", module.sap_netweaver_instance[*].pi_instance_mgmt_ip) : ""
}

output "share_fs_ips" {
  description = "Private IPs of the Share FS instance."
  value       = var.create_separate_fs_share ? module.sharefs_instance[0].pi_instance_mgmt_ip : ""
}

output "powervs_lpars_data" {
  description = "All private IPS of PowerVS instances and Jump IP to access the host."
  value = {
    "access_host_or_ip"                 = local.access_host_or_ip
    "hana_instance_management_ip"       = module.sap_hana_instance.pi_instance_mgmt_ip
    "hana_instance_ips"                 = module.sap_hana_instance.pi_instance_private_ips
    "netweaver_instances_management_ip" = var.powervs_netweaver_instance_count >= 1 ? join(",", module.sap_netweaver_instance[*].pi_instance_mgmt_ip) : ""
    "netweaver_ips"                     = var.powervs_netweaver_instance_count >= 1 ? join(",", module.sap_netweaver_instance[*].pi_instance_private_ips) : ""
    "share_fs_ip"                       = var.create_separate_fs_share ? module.sharefs_instance[0].pi_instance_mgmt_ip : ""
  }
}
