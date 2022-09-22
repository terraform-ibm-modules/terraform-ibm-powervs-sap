#####################################################
# PVS SAP instance Configuration
#####################################################

module "create_sap_network" {
  source       = "./submodules/power_create_private_network"
  powervs_zone = var.powervs_zone

  powervs_resource_group_name = var.powervs_resource_group_name
  powervs_service_name        = var.powervs_service_name
  powervs_sap_network_name    = var.powervs_sap_network_name
  powervs_sap_network_cidr    = var.powervs_sap_network_cidr
}

module "attach_sap_network" {
  source     = "./submodules/power_attach_private_network"
  depends_on = [module.create_sap_network]

  powervs_zone                   = var.powervs_zone
  powervs_resource_group_name    = var.powervs_resource_group_name
  powervs_service_name           = var.powervs_service_name
  powervs_sap_network_name       = var.powervs_sap_network_name
  powervs_cloud_connection_count = var.powervs_cloud_connection_count
}

module "share_fs_instance" {
  source = "./submodules/power_instance"
  count  = var.powervs_share_number_of_instances

  powervs_zone                 = var.powervs_zone
  powervs_resource_group_name  = var.powervs_resource_group_name
  powervs_service_name         = var.powervs_service_name
  powervs_instance_name        = var.powervs_share_instance_name
  powervs_sshkey_name          = var.powervs_sshkey_name
  powervs_os_image_name        = var.powervs_share_image_name
  powervs_server_type          = var.powervs_share_server_type
  powervs_cpu_proc_type        = var.powervs_share_cpu_proc_type
  powervs_number_of_processors = var.powervs_share_number_of_processors
  powervs_memory_size          = var.powervs_share_memory_size
  powervs_networks             = var.powervs_additional_networks
  powervs_storage_config       = var.powervs_share_storage_config
}

module "sap_hana_instance" {
  source     = "./submodules/power_instance"
  depends_on = [module.attach_sap_network]

  powervs_zone                = var.powervs_zone
  powervs_resource_group_name = var.powervs_resource_group_name
  powervs_service_name        = var.powervs_service_name
  powervs_instance_name       = var.powervs_hana_instance_name
  powervs_sshkey_name         = var.powervs_sshkey_name
  powervs_os_image_name       = var.powervs_hana_image_name
  powervs_sap_profile_id      = var.powervs_hana_sap_profile_id
  powervs_networks            = concat(var.powervs_additional_networks, [var.powervs_sap_network_name])
  powervs_storage_config      = var.powervs_hana_storage_config
}

module "sap_netweaver_instance" {
  source     = "./submodules/power_instance"
  depends_on = [module.attach_sap_network]

  count                        = var.powervs_netweaver_number_of_instances
  powervs_zone                 = var.powervs_zone
  powervs_resource_group_name  = var.powervs_resource_group_name
  powervs_service_name         = var.powervs_service_name
  powervs_instance_name        = "${var.powervs_netweaver_instance_name}-${count.index + 1}"
  powervs_sshkey_name          = var.powervs_sshkey_name
  powervs_os_image_name        = var.powervs_netweaver_image_name
  powervs_server_type          = var.powervs_netweaver_server_type
  powervs_cpu_proc_type        = var.powervs_netweaver_cpu_proc_type
  powervs_number_of_processors = var.powervs_netweaver_number_of_processors
  powervs_memory_size          = var.powervs_netweaver_memory_size
  powervs_networks             = concat(var.powervs_additional_networks, [var.powervs_sap_network_name])
  powervs_storage_config       = var.powervs_netweaver_storage_config
}

locals {
  perform_proxy_client_setup = {
    enable         = var.proxy_host_or_ip != null && var.proxy_host_or_ip != "" ? true : false
    server_ip      = var.proxy_host_or_ip
    no_proxy_hosts = "161.0.0.0/8,10.0.0.0/8"
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
    enable          = var.nfs_path != null && var.nfs_path != "" ? true : false
    nfs_server_path = var.nfs_path
    nfs_client_path = var.nfs_client_directory
  }
  target_server_ips         = concat([module.sap_hana_instance.instance_mgmt_ip], module.share_fs_instance.*.instance_mgmt_ip, module.sap_netweaver_instance.*.instance_mgmt_ip)
  hana_storage_configs      = [merge(var.powervs_hana_storage_config, { "wwns" = join(",", module.sap_hana_instance.instance_wwns) })]
  sharefs_storage_configs   = [for instance_wwns in module.share_fs_instance.*.instance_wwns : merge(var.powervs_share_storage_config, { "wwns" = join(",", instance_wwns) })]
  netweaver_storage_configs = [for instance_wwns in module.sap_netweaver_instance.*.instance_wwns : merge(var.powervs_netweaver_storage_config, { "wwns" = join(",", instance_wwns) })]
  all_storage_configs       = concat(local.hana_storage_configs, local.sharefs_storage_configs, local.netweaver_storage_configs)

  sap_solutions = concat(["HANA"], [for ip in module.share_fs_instance.*.instance_mgmt_ip : "NONE"], [for ip in module.sap_netweaver_instance.*.instance_mgmt_ip : "NETWEAVER"])
}

module "instance_init" {

  source     = "./submodules/power_sap_instance_init"
  depends_on = [module.share_fs_instance, module.sap_hana_instance, module.sap_netweaver_instance]

  count                            = var.configure_os == true ? 1 : 0
  access_host_or_ip                = var.access_host_or_ip
  os_image_distro                  = var.os_image_distro
  target_server_ips                = local.target_server_ips
  powervs_instance_storage_configs = local.all_storage_configs
  sap_solutions                    = local.sap_solutions
  ssh_private_key                  = var.ssh_private_key
  perform_proxy_client_setup       = local.perform_proxy_client_setup
  perform_nfs_client_setup         = local.perform_nfs_client_setup
  perform_ntp_client_setup         = local.perform_ntp_client_setup
  perform_dns_client_setup         = local.perform_dns_client_setup
  sap_domain                       = var.sap_domain
}
