#####################################################
# PVS SAP instance Configuration
# Copyright 2022 IBM
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

/****
module "instance_sap_init_sles" {
  count                          = length(regexall(".*SUSE.*", var.pvs_instance_image_name)) > 0 ? 1: 0
  source                         = "./power-sap-instance-init-sles"
  depends_on                     = [module.instance-sap]

  bastion_public_ip              = var.bastion_public_ip
  host_private_ip                = module.instance-sap.instance_mgmt_ip
  ssh_private_key                = var.ssh_private_key
  vpc_bastion_proxy_config       = {
                                     required               = var.proxy_config == "SQUID" ? true : false
                                     vpc_bastion_private_ip = var.bastion_private_ip
                                     no_proxy_ips           = module.instance-sap.instance_private_ips
                                   }
  os_activation                  = merge(var.os_activation,{"os_release" = "${element(local.os_release_list, length(local.os_release_list) - 2)}.${element(local.os_release_list, length(local.os_release_list) - 1)}"})
  pvs_instance_storage_config    = merge(var.pvs_instance_storage_config,{"wwns" = join(",", module.instance-sap.instance_wwns)})
  sap_solution                   = var.sap_solution
}

module "instance_sap_init_rhel" {
  count                          = length(regexall(".*RHEL.*", var.pvs_instance_image_name)) > 0 ? 1: 0
  source                         = "./power-sap-instance-init-rhel"
  depends_on                     = [module.instance-sap]

  bastion_public_ip            = var.bastion_public_ip
  host_private_ip              = module.instance-sap.instance_mgmt_ip
  ssh_private_key              = var.ssh_private_key
  vpc_bastion_proxy_config     = {
                                   required               = var.proxy_config == "SQUID" ? true : false
                                   vpc_bastion_private_ip = var.bastion_private_ip
                                   no_proxy_ips           = module.instance-sap.instance_private_ips
                                 }
  os_activation                = merge(var.os_activation,{"os_release" = "${element(local.os_release_list, length(local.os_release_list) - 2)}.${element(local.os_release_list, length(local.os_release_list) - 1)}"})
  pvs_instance_storage_config  = merge(var.pvs_instance_storage_config,{"wwns" = join(",", module.instance-sap.instance_wwns)})
  sap_solution                 = var.sap_solution
  sap_domain                   = var.sap_domain
}
****/
