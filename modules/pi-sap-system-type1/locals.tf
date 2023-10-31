locals {
  per_enabled_dc_list = ["dal10"]
  per_enabled         = contains(local.per_enabled_dc_list, var.powervs_zone)
}

#####################################################
# Prepare locals for SAP systems
#####################################################

locals {
  powervs_instance_init_linux = {
    enable                = true
    bastion_host_ip       = var.access_host_or_ip
    ssh_private_key       = var.ssh_private_key
    proxy_host_or_ip_port = var.proxy_host_or_ip_port
    no_proxy_hosts        = "161.0.0.0/8,10.0.0.0/8"
  }

  ## Configuration for sharefs instance and HANA instance
  powervs_network_services_config = {
    nfs = { enable = var.nfs_host_or_ip_path != "" ? true : false, nfs_server_path = var.nfs_host_or_ip_path, nfs_client_path = "/nfs" }
    dns = { enable = var.dns_host_or_ip != "" ? true : false, dns_server_ip = var.dns_host_or_ip }
    ntp = { enable = var.ntp_host_or_ip != "" ? true : false, ntp_server_ip = var.ntp_host_or_ip }
  }

  ## Configuration for sharefs instance as NFS server
  sharefs_nfs_server_config = {
    nfs : {
      enable : var.powervs_create_separate_fs_share ? true : false,
    nfs_file_system : [for volume in var.powervs_share_storage_config : { name : volume.name, mount_path : volume.mount, size : volume.size }] }
  }

  /*## Configuration for Netweaver instance
  nfs_server_path = var.powervs_create_separate_fs_share ? join(";", concat([var.nfs_host_or_ip_path], [for volume in var.powervs_share_storage_config : "${module.powervs_sharefs_instance[0].pi_instance_mgmt_ip}:${volume.mount}"])) : var.nfs_host_or_ip_path
  nfs_client_path = var.powervs_create_separate_fs_share ? join(";", concat(["/nfs"], [for volume in var.powervs_share_storage_config : volume.mount])) : "/nfs"
  powervs_netweaver_network_services_config = {
    nfs = { enable = var.nfs_host_or_ip_path != "" ? true : false, nfs_server_path = local.nfs_server_path, nfs_client_path = local.nfs_client_path }
    dns = { enable = var.dns_host_or_ip != "" ? true : false, dns_server_ip = var.dns_host_or_ip }
    ntp = { enable = var.ntp_host_or_ip != "" ? true : false, ntp_server_ip = var.ntp_host_or_ip }
  }*/
}

