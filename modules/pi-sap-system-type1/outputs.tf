output "access_host_or_ip" {
  description = "Public IP of Provided Bastion/JumpServer Host"
  value       = var.pi_instance_init_linux.bastion_host_ip
}

output "pi_hana_instance_ips" {
  description = "All private IPS of HANA instance"
  value       = module.pi_hana_instance.pi_instance_private_ips
}

output "pi_hana_instance_management_ip" {
  description = "Management IP of HANA Instance"
  value       = module.pi_hana_instance.pi_instance_primary_ip
}

output "pi_hana_instance_sap_ip" {
  description = "SAP IP of PowerVS HANA Instance"
  value       = local.pi_hana_instance_sap_ip
}

output "pi_netweaver_instance_ips" {
  description = "All private IPS of NetWeaver instances"
  value       = var.pi_netweaver_instance.instance_count >= 1 ? concat(module.pi_netweaver_primary_instance[*].pi_instance_private_ips, module.pi_netweaver_secondary_instances[*].pi_instance_private_ips) : [""]
}

output "pi_netweaver_instance_management_ips" {
  description = "Management IPS of NetWeaver instances"
  value       = var.pi_netweaver_instance.instance_count >= 1 ? join(",", module.pi_netweaver_primary_instance[*].pi_instance_primary_ip, module.pi_netweaver_secondary_instances[*].pi_instance_primary_ip) : ""
}

output "pi_lpars_data" {
  description = "All private IPS of PowerVS instances and Jump IP to access the host."
  value = {
    "access_host_or_ip"                    = nonsensitive(var.pi_instance_init_linux.bastion_host_ip)
    "pi_hana_instance_management_ip"       = module.pi_hana_instance.pi_instance_primary_ip
    "pi_hana_instance_ips"                 = module.pi_hana_instance.pi_instance_private_ips
    "pi_netweaver_instances_management_ip" = var.pi_netweaver_instance.instance_count >= 1 ? join(",", module.pi_netweaver_primary_instance[*].pi_instance_primary_ip, module.pi_netweaver_secondary_instances[*].pi_instance_primary_ip) : ""
    "pi_netweaver_instance_ips"            = var.pi_netweaver_instance.instance_count >= 1 ? concat(module.pi_netweaver_primary_instance[*].pi_instance_private_ips, module.pi_netweaver_secondary_instances[*].pi_instance_private_ips) : [""]
  }
}
