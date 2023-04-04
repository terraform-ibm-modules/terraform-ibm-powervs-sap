output "instance_private_ips" {
  description = "All private IP addresses (as a list) of IBM PowerVS instance."
  value       = join(", ", [for ip in data.ibm_pi_instance.instance_ips_ds.networks[*].ip : format("%s", ip)])
}

output "instance_private_ips_info" {
  description = "Complete info about all private IP addresses of IBM PowerVS instance."
  value       = data.ibm_pi_network.powervs_subnets_ds
}

output "instance_mgmt_ip" {
  description = "IP address of the management network interface of IBM PowerVS instance."
  value       = data.ibm_pi_instance_ip.instance_mgmt_ip_ds.ip
}

output "instance_sap_ip" {
  description = "IP address of the sap network interface of IBM PowerVS instance."
  value       = data.ibm_pi_instance_ip.instance_sap_ip_ds.ip
}

output "instance_wwns" {
  description = "Unique volume IDs (wwns) of all volumes attached to IBM PowerVS instance."
  depends_on  = [ibm_pi_volume.create_volume]
  value       = ibm_pi_volume.create_volume[*].wwn
}
