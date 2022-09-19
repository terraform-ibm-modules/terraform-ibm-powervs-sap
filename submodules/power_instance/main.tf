#####################################################
# PowerVs SAP Instance Create Configuration
#####################################################

locals {
  pvs_service_type = "power-iaas"
}

data "ibm_resource_group" "resource_group_ds" {
  name = var.pvs_resource_group_name
}

data "ibm_resource_instance" "pvs_service_ds" {
  name              = var.pvs_service_name
  service           = local.pvs_service_type
  location          = var.pvs_zone
  resource_group_id = data.ibm_resource_group.resource_group_ds.id
}

data "ibm_pi_key" "key_ds" {
  pi_cloud_instance_id = data.ibm_resource_instance.pvs_service_ds.guid
  pi_key_name          = var.pvs_sshkey_name
}

data "ibm_pi_image" "image_ds" {
  pi_image_name        = var.pvs_os_image_name
  pi_cloud_instance_id = data.ibm_resource_instance.pvs_service_ds.guid
}

data "ibm_pi_network" "pvs_subnets_ds" {
  count                = length(var.pvs_networks)
  pi_cloud_instance_id = data.ibm_resource_instance.pvs_service_ds.guid
  pi_network_name      = var.pvs_networks[count.index]
}

#####################################################
# Create PowerVs Instance
#####################################################

resource "ibm_pi_instance" "sap_instance" {
  pi_cloud_instance_id     = data.ibm_resource_instance.pvs_service_ds.guid
  pi_instance_name         = var.pvs_instance_name
  pi_image_id              = data.ibm_pi_image.image_ds.id
  pi_sap_profile_id        = var.pvs_sap_profile_id == null ? null : var.pvs_sap_profile_id
  pi_processors            = var.pvs_sap_profile_id != null ? null : var.pvs_number_of_processors
  pi_memory                = var.pvs_sap_profile_id != null ? null : var.pvs_memory_size
  pi_sys_type              = var.pvs_sap_profile_id != null ? null : var.pvs_server_type
  pi_proc_type             = var.pvs_sap_profile_id != null ? null : var.pvs_cpu_proc_type
  pi_key_pair_name         = data.ibm_pi_key.key_ds.id
  pi_health_status         = "OK"
  pi_storage_pool_affinity = false
  pi_storage_type          = var.pvs_os_image_storage_type

  dynamic "pi_network" {
    for_each = tolist(data.ibm_pi_network.pvs_subnets_ds.*.id)
    content {
      network_id = pi_network.value
    }
  }

}

#####################################################
# Create Disks mapping variables
# Copyright 2022 IBM
#####################################################

locals {
  disks_counts   = length(var.pvs_storage_config["counts"]) > 0 ? [for x in(split(",", var.pvs_storage_config["counts"])) : tonumber(trimspace(x))] : null
  disks_size_tmp = length(var.pvs_storage_config["counts"]) > 0 ? [for disk_size in split(",", var.pvs_storage_config["disks_size"]) : tonumber(trimspace(disk_size))] : null
  disks_size     = length(var.pvs_storage_config["counts"]) > 0 ? flatten([for idx, disk_count in local.disks_counts : [for i in range(disk_count) : local.disks_size_tmp[idx]]]) : null

  tier_types_tmp = length(var.pvs_storage_config["counts"]) > 0 ? [for tier_type in split(",", var.pvs_storage_config["tiers"]) : trimspace(tier_type)] : null
  tiers_type     = length(var.pvs_storage_config["counts"]) > 0 ? flatten([for idx, disk_count in local.disks_counts : [for i in range(disk_count) : local.tier_types_tmp[idx]]]) : null

  disks_name_tmp = length(var.pvs_storage_config["counts"]) > 0 ? [for disk_name in split(",", var.pvs_storage_config["names"]) : trimspace(disk_name)] : null
  disks_name     = length(var.pvs_storage_config["counts"]) > 0 ? flatten([for idx, disk_count in local.disks_counts : [for i in range(disk_count) : local.disks_name_tmp[idx]]]) : null

  disks_number = length(var.pvs_storage_config["counts"]) > 0 ? sum([for x in(split(",", var.pvs_storage_config["counts"])) : tonumber(trimspace(x))]) : 0
}

#####################################################
# Create Volumes
# Copyright 2022 IBM
#####################################################

resource "ibm_pi_volume" "create_volume" {
  depends_on           = [ibm_pi_instance.sap_instance]
  count                = local.disks_number
  pi_volume_size       = local.disks_size[count.index - (local.disks_number * floor(count.index / local.disks_number))]
  pi_volume_name       = "${var.pvs_instance_name}-${local.disks_name[count.index - (local.disks_number * floor(count.index / local.disks_number))]}-volume${count.index + 1}-${count.index}"
  pi_volume_type       = local.tiers_type[count.index - (local.disks_number * floor(count.index / local.disks_number))]
  pi_volume_shareable  = false
  pi_cloud_instance_id = data.ibm_resource_instance.pvs_service_ds.guid
}

#####################################################
# Attach Volumes to the Instance
# Copyright 2022 IBM
#####################################################

resource "ibm_pi_volume_attach" "instance_volumes_attach" {
  depends_on           = [ibm_pi_volume.create_volume, ibm_pi_instance.sap_instance]
  count                = local.disks_number
  pi_cloud_instance_id = data.ibm_resource_instance.pvs_service_ds.guid
  pi_volume_id         = ibm_pi_volume.create_volume[count.index].volume_id
  pi_instance_id       = ibm_pi_instance.sap_instance.instance_id
}

data "ibm_pi_instance_ip" "instance_mgmt_ip_ds" {
  depends_on           = [ibm_pi_instance.sap_instance]
  pi_network_name      = var.pvs_networks[0]
  pi_instance_name     = ibm_pi_instance.sap_instance.pi_instance_name
  pi_cloud_instance_id = data.ibm_resource_instance.pvs_service_ds.guid
}

data "ibm_pi_instance" "instance_ips_ds" {
  depends_on           = [ibm_pi_instance.sap_instance]
  pi_instance_name     = ibm_pi_instance.sap_instance.pi_instance_name
  pi_cloud_instance_id = data.ibm_resource_instance.pvs_service_ds.guid
}
