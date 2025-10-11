#####################################################
# Deploy PowerVS Instance
#####################################################

module "hana_storage_calculation" {
  source                                     = "../../modules/pi-hana-storage-config"
  pi_hana_instance_sap_profile_id            = var.powervs_hana_instance_sap_profile_id
  pi_hana_instance_additional_storage_config = var.powervs_hana_instance_additional_storage_config
  pi_hana_instance_custom_storage_config     = var.powervs_hana_instance_custom_storage_config
}

module "sap_hana_instance" {
  source  = "terraform-ibm-modules/powervs-instance/ibm"
  version = "2.8.2"

  pi_workspace_guid          = var.powervs_workspace_guid
  pi_ssh_public_key_name     = var.powervs_ssh_public_key_name
  pi_image_id                = var.powervs_image_name
  pi_instance_name           = var.powervs_instance_name
  pi_boot_image_storage_tier = var.powervs_boot_image_storage_tier
  pi_sap_profile_id          = var.powervs_hana_instance_sap_profile_id
  pi_server_type             = var.powervs_server_type
  pi_deployment_target       = var.powervs_deployment_target
  pi_networks                = var.powervs_networks
  pi_storage_config          = module.hana_storage_calculation.pi_hana_storage_config
  ansible_vault_password     = var.ansible_vault_password
  pi_instance_init_linux = merge(var.powervs_instance_init_linux,
    {
      ssh_private_key = var.ssh_private_key,
      custom_os_registration = (
        try(trim(var.powervs_os_registration_username), "") != "" &&
        try(trim(var.powervs_os_registration_password), "") != ""
        ) ? {
        username = var.powervs_os_registration_username
        password = var.powervs_os_registration_password
      } : null

  })
  pi_network_services_config = var.powervs_network_services_config
}

module "configure_os_for_sap" {

  source     = "../../modules/ansible"
  depends_on = [module.sap_hana_instance]
  count      = var.powervs_instance_init_linux.enable ? 1 : 0

  bastion_host_ip        = var.powervs_instance_init_linux.bastion_host_ip
  ansible_host_or_ip     = var.powervs_instance_init_linux.ansible_host_or_ip
  ssh_private_key        = var.ssh_private_key
  configure_ansible_host = true

  src_script_template_name = "configure-os-for-sap/ansible_exec.sh.tftpl"
  dst_script_file_name     = "${var.powervs_instance_name}_configure_os_for_sap.sh"

  src_playbook_template_name = "configure-os-for-sap/playbook-configure-os-for-sap.yml.tftpl"
  dst_playbook_file_name     = "${var.powervs_instance_name}-playbook-configure-os-for-sap.yml"
  playbook_template_vars = {
    "sap_solution" : "HANA",
    "sap_domain" : var.sap_domain
  }

  src_inventory_template_name = "pi-instance-inventory.tftpl"
  dst_inventory_file_name     = "${var.powervs_instance_name}-instance-inventory"
  inventory_template_vars     = { "pi_instance_management_ip" : module.sap_hana_instance.pi_instance_primary_ip }
}
