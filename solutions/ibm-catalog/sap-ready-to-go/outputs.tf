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
  value       = module.powervs_hana_instance.pi_instance_private_ips
}

output "powervs_hana_instance_management_ip" {
  description = "Management IP of HANA Instance"
  value       = module.powervs_hana_instance.pi_instance_mgmt_ip
}

output "powervs_netweaver_instance_ips" {
  description = "All private IPS of NetWeaver instances"
  value       = var.powervs_netweaver_instance_count >= 1 ? module.powervs_netweaver_instance[*].pi_instance_private_ips : [""]
}

output "powervs_netweaver_instance_management_ips" {
  description = "Management IPS of NetWeaver instances"
  value       = var.powervs_netweaver_instance_count >= 1 ? join(",", module.powervs_netweaver_instance[*].pi_instance_mgmt_ip) : ""
}

output "powervs_share_fs_ips" {
  description = "Private IPs of the Share FS instance."
  value       = var.powervs_create_separate_fs_share ? module.powervs_sharefs_instance[0].pi_instance_mgmt_ip : ""
}

output "powervs_lpars_data" {
  description = "All private IPS of PowerVS instances and Jump IP to access the host."
  value = {
    "access_host_or_ip"                         = local.access_host_or_ip
    "powervs_hana_instance_management_ip"       = module.powervs_hana_instance.pi_instance_mgmt_ip
    "powervs_hana_instance_ips"                 = module.powervs_hana_instance.pi_instance_private_ips
    "powervs_netweaver_instances_management_ip" = var.powervs_netweaver_instance_count >= 1 ? join(",", module.powervs_netweaver_instance[*].pi_instance_mgmt_ip) : ""
    "powervs_netweaver_ips"                     = var.powervs_netweaver_instance_count >= 1 ? module.powervs_netweaver_instance[*].pi_instance_private_ips : [""]
    "powervs_share_fs_ip"                       = var.powervs_create_separate_fs_share ? module.powervs_sharefs_instance[0].pi_instance_mgmt_ip : ""
  }
}
