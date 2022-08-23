output "access_host_or_ip" {
  description = "Public IP of Provided Bastion/JumpServer Host"
  value       = module.sap_systems.access_host_or_ip
}

output "hana_ips" {
  description = "All private IPS of HANA instance"
  value       = module.sap_systems.hana_instance_private_ips
}

output "region" {
  description = "Region for deployment"
  value       = var.region
}

/***
output "PVS_NW_IPS" {
  description = "All private IPs of NW instances"
  value       = module.sap_systems.*.instance_private_ips
}
***/
