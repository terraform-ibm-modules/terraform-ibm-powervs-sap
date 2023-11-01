#######################################################
### Storage Calculation for HANA Instance
#######################################################
locals {

  auto_cal_memory_size        = tonumber(element(split("x", var.pi_hana_instance_sap_profile_id), 1)) < 256 ? 256 : tonumber(element(split("x", var.pi_hana_instance_sap_profile_id), 1))
  auto_cal_data_volume_size   = floor((local.auto_cal_memory_size * 1.1) / 4) + 1
  auto_cal_log_volume_size    = floor((local.auto_cal_memory_size * 0.5) / 4) + 1 > 512 ? 512 : floor((local.auto_cal_memory_size * 0.5) / 4) + 1
  auto_cal_shared_volume_size = floor(local.auto_cal_memory_size > 1024 ? 1024 : local.auto_cal_memory_size)
  auto_cal_hana_storage_config = [
    {
      name = "data", size = local.auto_cal_data_volume_size, count = "4", tier = "tier1", mount = "/hana/data"
    },
    {
      name = "log", size = local.auto_cal_log_volume_size, count = "4", tier = "tier1", mount = "/hana/log"
    },
    {
      name = "shared", size = local.auto_cal_shared_volume_size, count = "1", tier = "tier3", mount = "/hana/shared"
    }
  ]

  additional_hana_storage_set = var.pi_hana_instance_additional_storage_config != null ? var.pi_hana_instance_additional_storage_config[0].count != "" ? true : false : false
  custom_hana_storage_set     = var.pi_hana_instance_custom_storage_config != null ? var.pi_hana_instance_custom_storage_config[0].count != "" ? true : false : false
  hana_storage_config         = local.custom_hana_storage_set ? local.additional_hana_storage_set ? concat(var.pi_hana_instance_custom_storage_config, var.pi_hana_instance_additional_storage_config) : var.pi_hana_instance_custom_storage_config : local.additional_hana_storage_set ? concat(local.auto_cal_hana_storage_config, var.pi_hana_instance_additional_storage_config) : local.auto_cal_hana_storage_config
}
