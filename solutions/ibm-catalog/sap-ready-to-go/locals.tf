locals {
  powervs_hana_instance = {
    name                      = "${var.prefix}-hana"
    image_id                  = local.hana_image_id
    sap_profile_id            = var.powervs_hana_instance_sap_profile_id
    additional_storage_config = var.powervs_hana_instance_additional_storage_config
  }

  powervs_netweaver_instance = {
    instance_count = var.powervs_netweaver_instance_count
    name           = "${var.prefix}-hnw"
    image_id       = local.netweaver_image_id
    processors     = var.powervs_netweaver_cpu_number
    memory         = var.powervs_netweaver_memory_size
    proc_type      = "shared"
    storage_config = var.powervs_netweaver_instance_storage_config
  }

  powervs_instance_init_linux = {
    enable             = true
    bastion_host_ip    = module.standard.access_host_or_ip
    ansible_host_or_ip = module.standard.ansible_host_or_ip
    ssh_private_key    = var.ssh_private_key
    custom_os_registration = local.use_fls ? null : {
      "username" : var.powervs_os_registration_username,
      "password" : var.powervs_os_registration_password
    }
  }

  powervs_network_services_config = {
    squid = {
      enable               = true
      squid_server_ip_port = module.standard.proxy_host_or_ip_port
      no_proxy_hosts       = "161.0.0.0/8,10.0.0.0/8"
    }
    nfs = {
      enable          = true
      nfs_server_path = module.standard.nfs_host_or_ip_path
      nfs_client_path = var.nfs_server_config.mount_path
      opts            = module.standard.network_services_config.nfs.opts
      fstype          = module.standard.network_services_config.nfs.fstype
    }
    dns = {
      enable        = true
      dns_server_ip = module.standard.dns_host_or_ip
    }
    ntp = {
      enable        = module.standard.ntp_host_or_ip != "" ? true : false
      ntp_server_ip = module.standard.ntp_host_or_ip
    }
  }
}
