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
    "netweaver_ips"                     = length(module.sap_systems.netweaver_instance_private_ips) >= 1 ? list(module.sap_systems.netweaver_instance_private_ips) : ""
    "share_fs_ips"                      = length(module.sap_systems.share_fs_instance_private_ips) >= 1 ? list(module.sap_systems.share_fs_instance_private_ips) : ""
  }
}

output "proxy_host_or_ip_port" {
  description = "Proxy host:port of PowerVS infrastructure."
  value       = var.proxy_host_or_ip_port
}

output "dns_host_or_ip" {
  description = "DNS forwarder host of PowerVS infrastructure."
  value       = var.dns_host_or_ip
}

output "ntp_host_or_ip" {
  description = "NTP host of PowerVS infrastructure."
  value       = var.ntp_host_or_ip
}

output "nfs_host_or_ip_path" {
  description = "NFS host of PowerVS infrastructure."
  value       = var.nfs_host_or_ip_path
}
