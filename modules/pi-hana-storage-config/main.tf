#######################################################
### Storage Calculation for HANA Instance
#######################################################
locals {
  memory_size = tonumber(element(split("x", var.pi_hana_instance_sap_profile_id), 1))
  auto_cal_storage_config = {
    "memory_lt_900" = {
      "shared_disk_size" = local.memory_size,
      "shared_disk_tier" = "tier3", #3 IOPS/GB
      "log_disk_size"    = ceil((local.memory_size / 2) / 4),
      "log_disk_tier"    = "tier5k", #fixed 5k iops
      "data_disk_size"   = local.memory_size < 256 ? 77 : ceil((local.memory_size * 1.2) / 4),
      "data_disk_tier"   = "tier0" #10 IOPS/GB
    },
    "memory_bt_900_2100" = {
      "shared_disk_size" = 1000,
      "shared_disk_tier" = "tier3", #3 IOPS/GB
      "log_disk_size"    = 128,
      "log_disk_tier"    = "tier0", #10 IOPS/GB
      "data_disk_size"   = 648,
      "data_disk_tier"   = "tier3" #3 IOPS/GB
    },
    "memory_gt_2100" = {
      "shared_disk_size" = 1000,
      "shared_disk_tier" = "tier3", #3 IOPS/GB
      "log_disk_size"    = 128,
      "log_disk_tier"    = "tier0", #10 IOPS/GB
      "data_disk_size"   = floor((local.memory_size * 1.2) / 4),
      "data_disk_tier"   = "tier3", #3 IOPS/GB
    }
  }

  storage_config = local.memory_size < 900 ? local.auto_cal_storage_config["memory_lt_900"] : local.memory_size > 2100 ? local.auto_cal_storage_config["memory_gt_2100"] : local.auto_cal_storage_config["memory_bt_900_2100"]
  auto_cal_hana_storage_config = [
    {
      name = "data", size = local.storage_config["data_disk_size"], count = "4", tier = local.storage_config["data_disk_tier"], mount = "/hana/data"
    },
    {
      name = "log", size = local.storage_config["log_disk_size"], count = "4", tier = local.storage_config["log_disk_tier"], mount = "/hana/log"
    },
    {
      name = "shared", size = local.storage_config["shared_disk_size"], count = "1", tier = local.storage_config["shared_disk_tier"], mount = "/hana/shared"
    }
  ]

  additional_hana_storage_set = var.pi_hana_instance_additional_storage_config != null ? var.pi_hana_instance_additional_storage_config[0].count != "" ? true : false : false
  custom_hana_storage_set     = var.pi_hana_instance_custom_storage_config != null ? var.pi_hana_instance_custom_storage_config[0].count != "" ? true : false : false
  hana_storage_config         = local.custom_hana_storage_set ? local.additional_hana_storage_set ? concat(var.pi_hana_instance_custom_storage_config, var.pi_hana_instance_additional_storage_config) : var.pi_hana_instance_custom_storage_config : local.additional_hana_storage_set ? concat(local.auto_cal_hana_storage_config, var.pi_hana_instance_additional_storage_config) : local.auto_cal_hana_storage_config
}
