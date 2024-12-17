output "infrastructure_data" {
  description = "PowerVS infrastructure details."
  value       = { for k, v in local.powervs_infrastructure[0] : k => v.value }
}

output "access_host_or_ip" {
  description = "Public IP of Provided Bastion/JumpServer Host."
  value       = local.access_host_or_ip
}

output "powervs_hana_instance_ips" {
  description = "All private IPS of HANA instance."
  value       = module.sap_system.pi_hana_instance_ips
}

output "powervs_hana_instance_management_ip" {
  description = "Management IP of HANA Instance."
  value       = module.sap_system.pi_hana_instance_management_ip
}

output "powervs_netweaver_instance_ips" {
  description = "All private IPs of NetWeaver instance."
  value       = module.sap_system.pi_netweaver_instance_ips
}

output "powervs_netweaver_instance_management_ip" {
  description = "Management IP of NetWeaver instance."
  value       = module.sap_system.pi_netweaver_instance_management_ips
}

output "powervs_sharefs_instance_ips" {
  description = "Private IPs of the Share FS instance."
  value       = module.sap_system.pi_sharefs_instance_ips
}

output "powervs_lpars_data" {
  description = "All private IPS of PowerVS instances and Jump IP to access the host."
  value       = module.sap_system.pi_lpars_data
}

output "sap_hana_vars" {
  description = "SAP HANA system details."
  value       = var.sap_hana_vars
}

output "sap_solution_vars" {
  description = "SAP NetWeaver system details."
  value       = var.sap_solution_vars
}

output "sap_monitoring_vars" {
  description = "SAP Monitoring Instance details."
  value       = merge(var.sap_monitoring_vars, local.powervs_infrastructure[0].monitoring_instance.value)
}
