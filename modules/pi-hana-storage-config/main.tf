#######################################################
### Storage Calculation for HANA Instance
#######################################################

locals {
  memory_size = tonumber(element(split("x", var.pi_hana_instance_sap_profile_id), 1))
  auto_cal_storage_config = {
    "memory_lt_900" = {
      shared_disk = { tier = "tier3", count = "1", size = local.memory_size },                                                          #3 IOPS/GB
      log_disk    = { tier = "tier5k", count = "4", size = ceil((local.memory_size / 2) / 4) },                                         #fixed 5k iops
      data_disk   = { tier = "tier0", count = "4", size = local.memory_size < 256 ? 81 : floor((local.memory_size * 1.5 * 1.074) / 4) } #25 IOPS/GB
    },
    "memory_bt_900_1850" = {
      shared_disk = { tier = "tier3", count = "1", size = 1000 }, #3 IOPS/GB
      log_disk    = { tier = "tier0", count = "4", size = 128 },  #25 IOPS/GB
      data_disk   = { tier = "tier3", count = "4", size = 670 }   #3 IOPS/GB
    },
    "memory_gt_2100" = {
      shared_disk = { tier = "tier3", count = "1", size = 1000 },                                        #3 IOPS/GB
      log_disk    = { tier = "tier0", count = "4", size = 128 },                                         #25 IOPS/GB
      data_disk   = { tier = "tier3", count = "4", size = floor((local.memory_size * 1.5 * 1.074) / 4) } #3 IOPS/GB
    }
  }

  storage_config = local.memory_size < 900 ? local.auto_cal_storage_config["memory_lt_900"] : local.memory_size > 1850 ? local.auto_cal_storage_config["memory_gt_2100"] : local.auto_cal_storage_config["memory_bt_900_1850"]

  auto_cal_hana_storage_config = [
    {
      name  = "data"
      size  = local.storage_config["data_disk"]["size"]
      count = local.storage_config["data_disk"]["count"]
      tier  = local.storage_config["data_disk"]["tier"]
      mount = "/hana/data"
    },
    {
      name  = "log"
      size  = local.storage_config["log_disk"]["size"]
      count = local.storage_config["log_disk"]["count"]
      tier  = local.storage_config["log_disk"]["tier"]
      mount = "/hana/log"
    },
    {
      name  = "shared"
      size  = local.storage_config["shared_disk"]["size"]
      count = local.storage_config["shared_disk"]["count"]
      tier  = local.storage_config["shared_disk"]["tier"]
      mount = "/hana/shared"
    }
  ]

  additional_hana_storage_set = var.pi_hana_instance_additional_storage_config != null ? var.pi_hana_instance_additional_storage_config[0].count != "" ? true : false : false
  custom_hana_storage_set     = var.pi_hana_instance_custom_storage_config != null ? var.pi_hana_instance_custom_storage_config[0].count != "" ? true : false : false
  hana_storage_config         = local.custom_hana_storage_set ? local.additional_hana_storage_set ? concat(var.pi_hana_instance_custom_storage_config, var.pi_hana_instance_additional_storage_config) : var.pi_hana_instance_custom_storage_config : local.additional_hana_storage_set ? concat(local.auto_cal_hana_storage_config, var.pi_hana_instance_additional_storage_config) : local.auto_cal_hana_storage_config
}
