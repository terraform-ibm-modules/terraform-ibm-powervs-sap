######################################################
# Deploy SAP S/4HANA or SAP BW/4HANA
# 1 HANA instance
# 1 NetWeaver Instance
######################################################

locals {
  powervs_hana_instance = {
    name                      = var.powervs_hana_instance_name
    image_id                  = local.hana_image_id
    sap_profile_id            = var.powervs_hana_instance_sap_profile_id
    additional_storage_config = var.powervs_hana_instance_additional_storage_config
  }

  powervs_netweaver_instance = {
    instance_count = 1
    name           = var.powervs_netweaver_instance_name
    image_id       = local.netweaver_image_id
    processors     = var.powervs_netweaver_cpu_number
    memory         = var.powervs_netweaver_memory_size
    proc_type      = "shared"
    storage_config = var.powervs_netweaver_instance_storage_config
  }
}

module "sap_system" {
  source = "../../../modules/pi-sap-system-type1"

  prefix                                 = var.prefix
  pi_workspace_guid                      = local.powervs_workspace_guid
  pi_region                              = var.powervs_zone
  pi_ssh_public_key_name                 = local.powervs_sshkey_name
  pi_networks                            = local.powervs_networks
  pi_sap_network_cidr                    = var.powervs_sap_network_cidr
  pi_hana_instance                       = local.powervs_hana_instance
  pi_hana_instance_custom_storage_config = var.powervs_hana_instance_custom_storage_config
  pi_netweaver_instance                  = local.powervs_netweaver_instance
  pi_instance_init_linux                 = local.powervs_instance_init_linux
  sap_network_services_config            = local.powervs_network_services_config
  sap_domain                             = var.sap_domain
  ansible_vault_password                 = var.ansible_vault_password
  scc_wp_instance                        = local.scc_wp_instance
}


######################################################
# COS Service credentials
# Download HANA binaries and SAP Solution binaries
# from IBM Cloud Object Storage(COS) to Ansible host
# host NFS mount point
######################################################

locals {
  cos_service_credentials  = jsondecode(var.ibmcloud_cos_service_credentials)
  cos_apikey               = local.cos_service_credentials.apikey
  cos_resource_instance_id = local.cos_service_credentials.resource_instance_id
}

locals {

  ibmcloud_cos_hana_configuration = {
    cos_apikey               = local.cos_apikey
    cos_region               = var.ibmcloud_cos_configuration.cos_region
    cos_resource_instance_id = local.cos_resource_instance_id
    cos_bucket_name          = var.ibmcloud_cos_configuration.cos_bucket_name
    cos_dir_name             = var.ibmcloud_cos_configuration.cos_hana_software_path
    download_dir_path        = local.network_services_config.nfs.nfs_client_path
  }

  ibmcloud_cos_solution_configuration = {
    cos_apikey               = local.cos_apikey
    cos_region               = var.ibmcloud_cos_configuration.cos_region
    cos_resource_instance_id = local.cos_resource_instance_id
    cos_bucket_name          = var.ibmcloud_cos_configuration.cos_bucket_name
    cos_dir_name             = var.ibmcloud_cos_configuration.cos_solution_software_path
    download_dir_path        = local.network_services_config.nfs.nfs_client_path
  }

  ibmcloud_cos_monitoring_configuration = {
    cos_apikey               = local.cos_apikey
    cos_region               = var.ibmcloud_cos_configuration.cos_region
    cos_resource_instance_id = local.cos_resource_instance_id
    cos_bucket_name          = var.ibmcloud_cos_configuration.cos_bucket_name
    cos_dir_name             = var.ibmcloud_cos_configuration.cos_monitoring_software_path
    download_dir_path        = local.network_services_config.nfs.nfs_client_path
  }
}

module "ibmcloud_cos_download_hana_binaries" {
  source = "../../../modules/ibmcloud-cos"
  count  = local.powervs_network_services_config.nfs.enable ? 1 : 0

  access_host_or_ip          = local.access_host_or_ip
  target_server_ip           = local.ansible_host_or_ip
  ssh_private_key            = var.ssh_private_key
  ibmcloud_cos_configuration = local.ibmcloud_cos_hana_configuration
}

module "ibmcloud_cos_download_netweaver_binaries" {
  source     = "../../../modules/ibmcloud-cos"
  depends_on = [module.ibmcloud_cos_download_hana_binaries]
  count      = local.powervs_network_services_config.nfs.enable ? 1 : 0

  access_host_or_ip          = local.access_host_or_ip
  target_server_ip           = local.ansible_host_or_ip
  ssh_private_key            = var.ssh_private_key
  ibmcloud_cos_configuration = local.ibmcloud_cos_solution_configuration
}

module "ibmcloud_cos_download_monitoring_binaries" {
  source     = "../../../modules/ibmcloud-cos"
  depends_on = [module.ibmcloud_cos_download_netweaver_binaries]
  count      = local.monitoring_instance.enable ? 1 : 0

  access_host_or_ip          = local.access_host_or_ip
  target_server_ip           = local.ansible_host_or_ip
  ssh_private_key            = var.ssh_private_key
  ibmcloud_cos_configuration = local.ibmcloud_cos_monitoring_configuration
}

#####################################################
# Ansible vars validation
#####################################################

locals {
  instance_nr_validation     = length([var.sap_hana_vars.sap_hana_install_number, var.sap_solution_vars.sap_swpm_ascs_instance_nr, var.sap_solution_vars.sap_swpm_pas_instance_nr]) == length(distinct([var.sap_hana_vars.sap_hana_install_number, var.sap_solution_vars.sap_swpm_ascs_instance_nr, var.sap_solution_vars.sap_swpm_pas_instance_nr]))
  instance_nr_validation_msg = "HANA sap_hana_install_number , ASCS sap_swpm_ascs_instance_nr and PAS sap_swpm_pas_instance_nr instance numbers must not be same"
  # tflint-ignore: terraform_unused_declarations
  instance_nr_validation_chk = regex("^${local.instance_nr_validation_msg}$", (local.instance_nr_validation ? local.instance_nr_validation_msg : ""))
}


#####################################################
# Ansible Install HANA DB
#####################################################

locals {
  ansible_sap_hana_playbook_vars = merge(var.sap_hana_vars,
    {
      sap_hana_install_software_directory = "${var.software_download_directory}/${var.ibmcloud_cos_configuration.cos_hana_software_path}",
      sap_hana_install_master_password    = var.sap_hana_master_password
    }
  )
}

module "ansible_sap_install_hana" {

  source                 = "../../../modules/ansible"
  depends_on             = [module.ibmcloud_cos_download_hana_binaries, module.sap_system]
  count                  = local.powervs_network_services_config.nfs.enable ? 1 : 0
  bastion_host_ip        = local.access_host_or_ip
  ansible_host_or_ip     = local.ansible_host_or_ip
  ssh_private_key        = var.ssh_private_key
  configure_ansible_host = false
  ansible_vault_password = var.ansible_vault_password

  src_script_template_name = "hanadb/install_hana.sh.tftpl"
  dst_script_file_name     = "${var.prefix}-${var.powervs_hana_instance_name}_install_hana.sh"

  src_playbook_template_name = "hanadb/playbook-sap-hana-install.yml.tftpl"
  dst_playbook_file_name     = "${var.prefix}-${var.powervs_hana_instance_name}-playbook-sap-hana-install.yml"
  playbook_template_vars     = local.ansible_sap_hana_playbook_vars

  src_inventory_template_name = "pi-instance-inventory.tftpl"
  dst_inventory_file_name     = "${var.prefix}-${var.powervs_hana_instance_name}-instance-inventory"
  inventory_template_vars     = { "pi_instance_management_ip" : module.sap_system.pi_hana_instance_management_ip }
}

####################################################
# Ansible Install NetWeaver solution
#####################################################

locals {
  product_catalog_map = {
    "s4hana-2020"  = "NW_ABAP_OneHost:S4HANA2020.CORE.HDB.ABAP"
    "s4hana-2021"  = "NW_ABAP_OneHost:S4HANA2021.CORE.HDB.ABAP"
    "s4hana-2022"  = "NW_ABAP_OneHost:S4HANA2022.CORE.HDB.ABAP"
    "s4hana-2023"  = "NW_ABAP_OneHost:S4HANA2023.CORE.HDB.ABAP"
    "bw4hana-2021" = "NW_ABAP_OneHost:BW4HANA2021.CORE.HDB.ABAP"
  }

  ansible_sap_solution_playbook_vars = merge(var.sap_solution_vars,
    {
      sap_swpm_product_catalog_id        = lookup(local.product_catalog_map, var.sap_solution, null)
      sap_install_media_detect_directory = "${var.software_download_directory}/${var.ibmcloud_cos_configuration.cos_solution_software_path}"
      sap_swpm_mp_stack_file_name        = var.ibmcloud_cos_configuration.cos_swpm_mp_stack_file_name
      sap_swpm_master_password           = var.sap_swpm_master_password
      sap_swpm_ascs_instance_hostname    = "${var.prefix}-${var.powervs_netweaver_instance_name}-1"
      sap_domain                         = var.sap_domain
      sap_swpm_db_host                   = "${var.prefix}-${var.powervs_hana_instance_name}"
      sap_swpm_db_ip                     = module.sap_system.pi_hana_instance_sap_ip
      sap_swpm_db_sid                    = var.sap_hana_vars.sap_hana_install_sid
      sap_swpm_db_instance_nr            = var.sap_hana_vars.sap_hana_install_number
      sap_swpm_db_master_password        = var.sap_hana_master_password
    }
  )
}

module "ansible_sap_install_solution" {

  source     = "../../../modules/ansible"
  depends_on = [module.ibmcloud_cos_download_netweaver_binaries, module.ansible_sap_install_hana]
  count      = local.powervs_network_services_config.nfs.enable ? 1 : 0

  bastion_host_ip        = local.access_host_or_ip
  ansible_host_or_ip     = local.ansible_host_or_ip
  ssh_private_key        = var.ssh_private_key
  configure_ansible_host = false
  ansible_vault_password = var.ansible_vault_password

  src_script_template_name = "s4hanab4hana-solution/install_swpm.sh.tftpl"
  dst_script_file_name     = "${var.prefix}-${var.powervs_netweaver_instance_name}_install_swpm.sh"

  src_playbook_template_name = "s4hanab4hana-solution/playbook-sap-swpm-install.yml.tftpl"
  dst_playbook_file_name     = "${var.prefix}-${var.powervs_netweaver_instance_name}-playbook-sap-swpm-install.yml"
  playbook_template_vars     = local.ansible_sap_solution_playbook_vars

  src_inventory_template_name = "pi-instance-inventory.tftpl"
  dst_inventory_file_name     = "${var.prefix}-${var.powervs_netweaver_instance_name}-instance-inventory"
  inventory_template_vars     = { "pi_instance_management_ip" : module.sap_system.pi_netweaver_instance_management_ips }
}

####################################################
# Ansible Install Monitoring SAP solution
#####################################################

locals {

  ansible_monitoring_solution_playbook_vars = merge(var.sap_monitoring_vars,
    {
      sap_monitoring_action          = "add"
      sap_tools_directory            = "${local.network_services_config.nfs.nfs_client_path}/${var.ibmcloud_cos_configuration.cos_monitoring_software_path}"
      sap_hana_ip                    = module.sap_system.pi_hana_instance_management_ip
      sap_hana_http_port             = "5${var.sap_hana_vars.sap_hana_install_number}13"
      sap_hana_sql_systemdb_port     = "3${var.sap_hana_vars.sap_hana_install_number}13"
      sap_hana_sql_systemdb_user     = "system"
      sap_hana_sql_systemdb_password = var.sap_hana_master_password
      sap_ascs_ip                    = module.sap_system.pi_netweaver_instance_management_ips
      sap_ascs_http_port             = "5${var.sap_solution_vars.sap_swpm_ascs_instance_nr}13"
      sap_app_server = jsonencode([
        {
          sap_app_server_nr = "01"
          ip                = module.sap_system.pi_netweaver_instance_management_ips
          port              = "5${var.sap_solution_vars.sap_swpm_pas_instance_nr}13"
        }]
      )
      ibmcloud_monitoring_instance_url           = "https://ingest.prws.private.${local.monitoring_instance.location}.monitoring.cloud.ibm.com/prometheus/remote/write"
      ibmcloud_monitoring_request_credential_url = "https://${local.monitoring_instance.location}.monitoring.cloud.ibm.com/api/token"
      ibmcloud_monitoring_instance_guid          = local.monitoring_instance.guid
    }
  )
}


module "ansible_monitoring_sap_install_solution" {

  source     = "../../../modules/ansible"
  depends_on = [module.ibmcloud_cos_download_monitoring_binaries, module.ansible_sap_install_hana, module.ansible_sap_install_solution]
  count      = local.monitoring_instance.enable ? 1 : 0

  bastion_host_ip        = local.access_host_or_ip
  ansible_host_or_ip     = local.ansible_host_or_ip
  ssh_private_key        = var.ssh_private_key
  ansible_vault_password = var.ansible_vault_password
  configure_ansible_host = false
  ibmcloud_api_key       = var.ibmcloud_api_key

  src_script_template_name = "configure-monitoring-sap/ansible_configure_monitoring.sh.tftpl"
  dst_script_file_name     = "${var.prefix}-configure_monitoring.sh"

  src_playbook_template_name  = "configure-monitoring-sap/playbook-configure-monitoring-sap.yml.tftpl"
  dst_playbook_file_name      = "${var.prefix}-playbook-configure-monitoring-sap.yml"
  playbook_template_vars      = local.ansible_monitoring_solution_playbook_vars
  src_inventory_template_name = "monitoring-inventory.tftpl"
  dst_inventory_file_name     = "${var.prefix}-monitoring-instance-inventory"
  inventory_template_vars     = { "monitoring_host_ip" : local.monitoring_instance.monitoring_host_ip }
}
