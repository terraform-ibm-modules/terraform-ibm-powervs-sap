#####################################################
# PVS SAP instance Configuration
#####################################################

module "initial_validation" {
  source = "./submodules/initial_validation"
  configure_os_validate = {
    configure_os          = var.configure_os
    access_host_or_ip     = var.access_host_or_ip
    ssh_private_key       = var.ssh_private_key
    proxy_host_or_ip_port = var.proxy_host_or_ip_port
  }
}

module "create_sap_network" {
  source       = "./submodules/power_create_private_network"
  powervs_zone = var.powervs_zone

  powervs_resource_group_name = var.powervs_resource_group_name
  powervs_workspace_name      = var.powervs_workspace_name
  powervs_sap_network         = var.powervs_sap_network
}

module "attach_sap_network" {
  source     = "./submodules/power_attach_private_network"
  depends_on = [module.create_sap_network]

  powervs_zone                   = var.powervs_zone
  powervs_resource_group_name    = var.powervs_resource_group_name
  powervs_workspace_name         = var.powervs_workspace_name
  powervs_sap_network_name       = var.powervs_sap_network["name"]
  powervs_cloud_connection_count = var.powervs_cloud_connection_count
}

module "share_fs_instance" {
  source = "./submodules/power_instance"
  count  = var.powervs_share_number_of_instances

  powervs_zone                 = var.powervs_zone
  powervs_resource_group_name  = var.powervs_resource_group_name
  powervs_workspace_name       = var.powervs_workspace_name
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

#######################################################
### Storage Calculation for HANA Instance
#######################################################
locals {
  additional_hana_storage_set  = var.powervs_hana_additional_storage_config != null && var.powervs_hana_additional_storage_config["disks_size"] != "" ? true : false
  custom_hana_storage_set      = var.powervs_hana_custom_storage_config != null && var.powervs_hana_custom_storage_config["disks_size"] != "" ? true : false
  auto_cal_hana_disks_counts   = "4,4,1"
  auto_cal_hana_paths          = "/hana/data,/hana/log,/hana/shared"
  auto_cal_hana_tiers          = "tier1,tier1,tier3"
  auto_cal_memory_size         = tonumber(element(split("x", var.powervs_hana_sap_profile_id), 1)) < 128 ? 128 : tonumber(element(split("x", var.powervs_hana_sap_profile_id), 1))
  auto_cal_data_volume_size    = floor((local.auto_cal_memory_size * 1.1) / 4) + 1
  auto_cal_log_volume_size_tmp = floor((local.auto_cal_memory_size * 0.5) / 4) + 1
  auto_cal_log_volume_size     = local.auto_cal_log_volume_size_tmp > 512 ? 512 : local.auto_cal_log_volume_size_tmp
  auto_cal_shared_volume_size  = floor(local.auto_cal_memory_size > 1024 ? 1024 : local.auto_cal_memory_size)
  auto_cal_hana_storage_config = {
    names      = local.additional_hana_storage_set ? "data,log,shared,${var.powervs_hana_additional_storage_config["names"]}" : "data,log,shared"
    disks_size = local.additional_hana_storage_set ? "${local.auto_cal_data_volume_size},${local.auto_cal_log_volume_size},${local.auto_cal_shared_volume_size},${var.powervs_hana_additional_storage_config["disks_size"]}" : "${local.auto_cal_data_volume_size},${local.auto_cal_log_volume_size},${local.auto_cal_shared_volume_size}"
    counts     = local.additional_hana_storage_set ? "${local.auto_cal_hana_disks_counts},${var.powervs_hana_additional_storage_config["counts"]}" : local.auto_cal_hana_disks_counts
    tiers      = local.additional_hana_storage_set ? "tier1,tier1,tier1,${var.powervs_hana_additional_storage_config["tiers"]}" : local.auto_cal_hana_tiers
    paths      = local.additional_hana_storage_set ? "/hana/data,/hana/log,/hana/shared,${var.powervs_hana_additional_storage_config["paths"]}" : local.auto_cal_hana_paths
  }
  custom_storage_config = local.custom_hana_storage_set ? {
    names      = local.additional_hana_storage_set ? "${var.powervs_hana_custom_storage_config["names"]},${var.powervs_hana_additional_storage_config["names"]}" : var.powervs_hana_custom_storage_config["names"]
    disks_size = local.additional_hana_storage_set ? "${var.powervs_hana_custom_storage_config["disks_size"]},${var.powervs_hana_additional_storage_config["disks_size"]}" : var.powervs_hana_custom_storage_config["disks_size"]
    counts     = local.additional_hana_storage_set ? "${var.powervs_hana_custom_storage_config["counts"]},${var.powervs_hana_additional_storage_config["counts"]}" : var.powervs_hana_custom_storage_config["counts"]
    tiers      = local.additional_hana_storage_set ? "${var.powervs_hana_custom_storage_config["tiers"]},${var.powervs_hana_additional_storage_config["tiers"]}" : var.powervs_hana_custom_storage_config["tiers"]
    paths      = local.additional_hana_storage_set ? "${var.powervs_hana_custom_storage_config["paths"]},${var.powervs_hana_additional_storage_config["paths"]}" : var.powervs_hana_custom_storage_config["paths"]
  } : null
  powervs_hana_storage_config = local.custom_hana_storage_set ? local.custom_storage_config : local.auto_cal_hana_storage_config
}

module "sap_hana_instance" {
  source     = "./submodules/power_instance"
  depends_on = [module.attach_sap_network]

  powervs_zone                = var.powervs_zone
  powervs_resource_group_name = var.powervs_resource_group_name
  powervs_workspace_name      = var.powervs_workspace_name
  powervs_instance_name       = var.powervs_hana_instance_name
  powervs_sshkey_name         = var.powervs_sshkey_name
  powervs_os_image_name       = var.powervs_hana_image_name
  powervs_sap_profile_id      = var.powervs_hana_sap_profile_id
  powervs_networks            = concat(var.powervs_additional_networks, [var.powervs_sap_network["name"]])
  powervs_storage_config      = local.powervs_hana_storage_config
}

module "sap_netweaver_instance" {
  source     = "./submodules/power_instance"
  depends_on = [module.attach_sap_network]

  count                        = var.powervs_netweaver_number_of_instances
  powervs_zone                 = var.powervs_zone
  powervs_resource_group_name  = var.powervs_resource_group_name
  powervs_workspace_name       = var.powervs_workspace_name
  powervs_instance_name        = "${var.powervs_netweaver_instance_name}-${count.index + 1}"
  powervs_sshkey_name          = var.powervs_sshkey_name
  powervs_os_image_name        = var.powervs_netweaver_image_name
  powervs_server_type          = var.powervs_netweaver_server_type
  powervs_cpu_proc_type        = var.powervs_netweaver_cpu_proc_type
  powervs_number_of_processors = var.powervs_netweaver_number_of_processors
  powervs_memory_size          = var.powervs_netweaver_memory_size
  powervs_networks             = concat(var.powervs_additional_networks, [var.powervs_sap_network["name"]])
  powervs_storage_config       = var.powervs_netweaver_storage_config
}

locals {
  perform_proxy_client_setup = {
    enable         = var.proxy_host_or_ip_port != null && var.proxy_host_or_ip_port != "" ? true : false
    server_ip_port = var.proxy_host_or_ip_port
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
    enable          = var.nfs_host_or_ip_path != null && var.nfs_host_or_ip_path != "" ? true : false
    nfs_server_path = var.nfs_host_or_ip_path
    nfs_client_path = var.nfs_client_directory
  }

  target_server_ips         = concat([module.sap_hana_instance.instance_mgmt_ip], module.share_fs_instance[*].instance_mgmt_ip, module.sap_netweaver_instance[*].instance_mgmt_ip)
  hana_storage_configs      = [merge(local.powervs_hana_storage_config, { "wwns" = join(",", module.sap_hana_instance.instance_wwns) })]
  sharefs_storage_configs   = [for instance_wwns in module.share_fs_instance[*].instance_wwns : merge(var.powervs_share_storage_config, { "wwns" = join(",", instance_wwns) })]
  netweaver_storage_configs = [for instance_wwns in module.sap_netweaver_instance[*].instance_wwns : merge(var.powervs_netweaver_storage_config, { "wwns" = join(",", instance_wwns) })]
  all_storage_configs       = concat(local.hana_storage_configs, local.sharefs_storage_configs, local.netweaver_storage_configs)
  sap_solutions             = concat(["HANA"], [for ip in module.share_fs_instance[*].instance_mgmt_ip : "NONE"], [for ip in module.sap_netweaver_instance[*].instance_mgmt_ip : "NETWEAVER"])
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

# Download sap binaries from COS to private VSI on intel.
module "cos_sap_download" {

  source     = "./submodules/cos_sap_download"
  depends_on = [module.instance_init]
  count      = var.nfs_host_or_ip_path != null && var.nfs_host_or_ip_path != "" && var.cos_config["cos_access_key"] != "" && var.cos_config["cos_access_key"] != null ? 1 : 0

  access_host_or_ip = var.access_host_or_ip
  host_ip           = split(":", var.nfs_host_or_ip_path)[0]
  ssh_private_key   = var.ssh_private_key
  cos_config        = var.cos_config
}

module "ansible_s4hana_bw4hana" {

  source     = "./submodules/ansible_sap_s4hana_bw4hana"
  depends_on = [module.cos_sap_download, module.sap_hana_instance, module.sap_netweaver_instance, module.instance_init]
  count      = var.ansible_sap_solution["enable"] && contains(["s4hana", "bw4hana"], var.ansible_sap_solution["solution"]) ? 1 : 0

  access_host_or_ip     = var.access_host_or_ip
  target_server_hana_ip = module.sap_hana_instance.instance_mgmt_ip
  target_server_nw_ip   = module.sap_netweaver_instance[0].instance_mgmt_ip
  ssh_private_key       = var.ssh_private_key
  ansible_parameters = merge(var.ansible_sap_solution,
    { "hana_instance_sap_ip"   = module.sap_hana_instance.instance_sap_ip
      "hana_instance_hostname" = var.powervs_hana_instance_name
    "netweaver_instance_hostname" = "${var.powervs_netweaver_instance_name}-1" }
  )
  ansible_vault_password = var.ansible_vault_password
}
