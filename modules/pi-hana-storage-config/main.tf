#######################################################
### Storage Calculation for HANA Instance
#######################################################

locals {
  memory_size = tonumber(element(split("x", var.pi_hana_instance_sap_profile_id), 1))
  auto_cal_hana_storage_config = [
    {
      name  = "data"
      size  = local.memory_size < 300 ? 80 : floor((local.memory_size * 1.2) / 4)
      count = 4
      tier  = local.memory_size < 1950 ? "tier0" : "tier3"
      mount = "/hana/data"
    },
    {
      name  = "log"
      size  = 128
      count = 4
      tier  = "tier0"
      mount = "/hana/log"
    },
    {
      name  = "shared"
      size  = 200
      count = 1
      tier  = "tier0"
      mount = "/hana/shared"
    }
  ]

  additional_hana_storage_set = var.pi_hana_instance_additional_storage_config != null ? var.pi_hana_instance_additional_storage_config[0].count != "" ? true : false : false
  custom_hana_storage_set     = var.pi_hana_instance_custom_storage_config != null ? var.pi_hana_instance_custom_storage_config[0].count != "" ? true : false : false
  hana_storage_config         = local.custom_hana_storage_set ? local.additional_hana_storage_set ? concat(var.pi_hana_instance_custom_storage_config, var.pi_hana_instance_additional_storage_config) : var.pi_hana_instance_custom_storage_config : local.additional_hana_storage_set ? concat(local.auto_cal_hana_storage_config, var.pi_hana_instance_additional_storage_config) : local.auto_cal_hana_storage_config
}
