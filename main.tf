#####################################################
# PVS SAP instance Configuration TEST
#####################################################

module "create_sap_network" {
  source                  = "./submodules/power_create_private_network"
  pvs_zone                = var.pvs_zone
  pvs_resource_group_name = var.pvs_resource_group_name
  pvs_service_name        = var.pvs_service_name
  pvs_sap_network_name    = var.pvs_sap_network_name
  pvs_sap_network_cidr    = var.pvs_sap_network_cidr
}

module "attach_sap_network" {
  source                     = "./submodules/power_attach_private_network"
  depends_on                 = [module.create_sap_network]
  pvs_zone                   = var.pvs_zone
  pvs_resource_group_name    = var.pvs_resource_group_name
  pvs_service_name           = var.pvs_service_name
  pvs_sap_network_name       = var.pvs_sap_network_name
  pvs_cloud_connection_count = var.pvs_cloud_connection_count
}

module "share_fs_instance" {
  source                   = "./submodules/power_instance"
  count                    = var.pvs_share_number_of_instances
  pvs_zone                 = var.pvs_zone
  pvs_resource_group_name  = var.pvs_resource_group_name
  pvs_service_name         = var.pvs_service_name
  pvs_instance_name        = var.pvs_share_instance_name
  pvs_sshkey_name          = var.pvs_sshkey_name
  pvs_os_image_name        = var.pvs_share_image_name
  pvs_server_type          = var.pvs_share_server_type
  pvs_cpu_proc_type        = var.pvs_share_cpu_proc_type
  pvs_number_of_processors = var.pvs_share_number_of_processors
  pvs_memory_size          = var.pvs_share_memory_size
  pvs_networks             = var.pvs_additional_networks
  pvs_storage_config       = var.pvs_share_storage_config
}

module "sap_hana_instance" {
  source                  = "./submodules/power_instance"
  depends_on              = [module.attach_sap_network]
  pvs_zone                = var.pvs_zone
  pvs_resource_group_name = var.pvs_resource_group_name
  pvs_service_name        = var.pvs_service_name
  pvs_instance_name       = var.pvs_hana_instance_name
  pvs_sshkey_name         = var.pvs_sshkey_name
  pvs_os_image_name       = var.pvs_hana_image_name
  pvs_sap_profile_id      = var.pvs_hana_sap_profile_id
  pvs_networks            = concat(var.pvs_additional_networks, [var.pvs_sap_network_name])
  pvs_storage_config      = var.pvs_hana_storage_config
}

module "sap_netweaver_instance" {
  source                   = "./submodules/power_instance"
  depends_on               = [module.attach_sap_network]
  count                    = var.pvs_netweaver_number_of_instances
  pvs_zone                 = var.pvs_zone
  pvs_resource_group_name  = var.pvs_resource_group_name
  pvs_service_name         = var.pvs_service_name
  pvs_instance_name        = "${var.pvs_netweaver_instance_name}-${count.index + 1}"
  pvs_sshkey_name          = var.pvs_sshkey_name
  pvs_os_image_name        = var.pvs_netweaver_image_name
  pvs_server_type          = var.pvs_netweaver_server_type
  pvs_cpu_proc_type        = var.pvs_netweaver_cpu_proc_type
  pvs_number_of_processors = var.pvs_netweaver_number_of_processors
  pvs_memory_size          = var.pvs_netweaver_memory_size
  pvs_networks             = concat(var.pvs_additional_networks, [var.pvs_sap_network_name])
  pvs_storage_config       = var.pvs_netweaver_storage_config
}

locals {
  perform_proxy_client_setup = {
    enable       = var.proxy_host_or_ip != null && var.proxy_host_or_ip != "" ? true : false
    server_ip    = var.proxy_host_or_ip
    no_proxy_env = "161.0.0.0/8, 10.0.0.0/8"
  }
  perform_ntp_client_setup = {
    enable    = var.ntp_host_or_ip != null && var.ntp_host_or_ip != "" ? true : false
    server_ip = var.ntp_host_or_ip
  }
  perform_dns_client_setup = {
    enable    = var.dns_host_or_ip != null && var.dns_host_or_ip != "" ? true : false
    server_ip = var.dns_host_or_ip
  }
  perform_nfs_client_setup = {
    enable          = var.nfs_host_or_ip != null && var.nfs_host_or_ip != "" ? true : false
    nfs_server_path = "${var.nfs_host_or_ip}:${var.nfs_path}"
    nfs_client_path = var.nfs_client_directory
  }
  target_server_ips         = concat([module.sap_hana_instance.instance_mgmt_ip], module.share_fs_instance.*.instance_mgmt_ip, module.sap_netweaver_instance.*.instance_mgmt_ip)
  hana_storage_configs      = [merge(var.pvs_hana_storage_config, { "wwns" = join(",", module.sap_hana_instance.instance_wwns) })]
  sharefs_storage_configs   = [for instance_wwns in module.share_fs_instance.*.instance_wwns : merge(var.pvs_share_storage_config, { "wwns" = join(",", instance_wwns) })]
  netweaver_storage_configs = [for instance_wwns in module.sap_netweaver_instance.*.instance_wwns : merge(var.pvs_netweaver_storage_config, { "wwns" = join(",", instance_wwns) })]
  all_storage_configs       = concat(local.hana_storage_configs, local.sharefs_storage_configs, local.netweaver_storage_configs)

  sap_solutions = concat(["HANA"], [for ip in module.share_fs_instance.*.instance_mgmt_ip : "NONE"], [for ip in module.sap_netweaver_instance.*.instance_mgmt_ip : "NETWEAVER"])
}

module "instance_init" {

  source                       = "./submodules/power_sap_instance_init"
  depends_on                   = [module.share_fs_instance, module.sap_hana_instance, module.sap_netweaver_instance]
  count                        = var.configure_os == true ? 1 : 0
  access_host_or_ip            = var.access_host_or_ip
  os_image_distro              = var.os_image_distro
  target_server_ips            = local.target_server_ips
  pvs_instance_storage_configs = local.all_storage_configs
  sap_solutions                = local.sap_solutions
  ssh_private_key              = var.ssh_private_key
  perform_proxy_client_setup   = local.perform_proxy_client_setup
  perform_nfs_client_setup     = local.perform_nfs_client_setup
  perform_ntp_client_setup     = local.perform_ntp_client_setup
  perform_dns_client_setup     = local.perform_dns_client_setup
  sap_domain                   = var.sap_domain
}
