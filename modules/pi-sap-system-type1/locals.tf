locals {
  per_enabled_dc_list = ["dal10"]
  per_enabled         = contains(local.per_enabled_dc_list, var.pi_zone)
}

locals {

  ## Configuration for fsshare instance as NFS server
  fsshare_nfs_server_config = {
    nfs : {
      enable : var.pi_create_separate_fsshare_instance ? true : false,
    nfs_file_system : var.pi_create_separate_fsshare_instance && var.pi_fsshare_instance_storage_config != null ? [for volume in var.pi_fsshare_instance_storage_config : { name : volume.name, mount_path : volume.mount, size : volume.size }] : [] }
  }

  ## Configuration for Netweaver instance
  nfs_server_path = var.pi_create_separate_fsshare_instance && var.pi_fsshare_instance_storage_config != null ? join(";", concat([var.sap_network_services_config.nfs_server_path], [for volume in var.pi_fsshare_instance_storage_config : "${module.pi_fsshare_instance[0].pi_instance_primary_ip}:${volume.mount}"])) : var.sap_network_services_config.nfs.nfs_server_path
  nfs_client_path = var.pi_create_separate_fsshare_instance ? join(";", concat(["/nfs"], [for volume in var.pi_fsshare_instance_storage_config : volume.mount])) : "/nfs"
  pi_netweaver_network_services_config = {
    nfs = { enable = var.sap_network_services_config.nfs.enable ? true : false, nfs_server_path = local.nfs_server_path, nfs_client_path = local.nfs_client_path }
    dns = { enable = var.sap_network_services_config.dns.enable ? true : false, dns_server_ip = var.sap_network_services_config.dns.dns_server_ip }
    ntp = { enable = var.sap_network_services_config.ntp.enable ? true : false, ntp_server_ip = var.sap_network_services_config.ntp.ntp_server_ip }
  }
}
