output "infrastructure_data" {
  description = "Data from PowerVS infrastructure layer"
  value       = jsondecode(data.ibm_schematics_output.schematics_output.output_json)
}

output "access_host_or_ip" {
  description = "Public IP of Provided Bastion/JumpServer Host"
  value       = module.sap_system.access_host_or_ip
}

output "powervs_hana_instance_ips" {
  description = "All private IPS of HANA instance"
  value       = module.sap_system.powervs_hana_instance_ips
}

output "powervs_hana_instance_management_ip" {
  description = "Management IP of HANA Instance"
  value       = module.sap_system.powervs_hana_instance_management_ip
}

output "powervs_netweaver_instance_ips" {
  description = "All private IPS of NetWeaver instances"
  value       = module.sap_system.powervs_netweaver_instance_ips
}

output "powervs_netweaver_instance_management_ip" {
  description = "Management IP of NetWeaver instance"
  value       = module.sap_system.powervs_netweaver_instance_management_ips
}

output "powervs_lpars_data" {
  description = "All private IPS of PowerVS instances and Jump IP to access the host."
  value       = module.sap_system.powervs_lpars_data
}

output "ansible_sap_hana_vars" {
  description = "HANA system details"
  value       = var.ansible_sap_hana_vars
}

output "ansible_sap_solution_vars" {
  description = "Netweaver system details"
  value       = var.ansible_sap_solution_vars
}
