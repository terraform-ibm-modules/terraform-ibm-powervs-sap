#####################################################
# 1. Execute Ansible galaxy role to prepare OS for SAP
#####################################################

locals {
  src_ansible_templates_dir = "${path.module}/templates/"
  dst_files_dir             = "/root/terraform_files"

  src_configure_os_for_sap_tpl_path           = "${local.src_ansible_templates_dir}/ansible_exec.sh.tftpl"
  dst_configure_os_for_sap_file_path          = "${local.dst_files_dir}/configure_os_for_sap.sh"
  src_playbook_configure_os_for_sap_tpl_path  = "${local.src_ansible_templates_dir}/playbook_configure_os_for_sap.yml.tftpl"
  dst_playbook_configure_os_for_sap_file_path = "${local.dst_files_dir}/playbook_configure_os_for_sap.yml"


  pi_configure_os_for_sap = {
    # Creates terraform scripts directory
    provisioner_remote_exec_inline_pre_exec_commands = ["mkdir -p ${local.dst_files_dir}", "chmod 777 ${local.dst_files_dir}", ]

    # Copy playbook template file to target host
    provisioner_file_1 = {
      destination_file_path     = local.dst_playbook_configure_os_for_sap_file_path,
      source_template_file_path = local.src_playbook_configure_os_for_sap_tpl_path,
      template_content          = { sap_solution = var.sap_solution, sap_domain = var.sap_domain }
    }

    # Copy ansible exec template file to target host
    provisioner_file_2 = {
      destination_file_path     = local.dst_configure_os_for_sap_file_path,
      source_template_file_path = local.src_configure_os_for_sap_tpl_path,
      template_content = {
        "ansible_playbook_file" : local.dst_playbook_configure_os_for_sap_file_path
        "ansible_log_path" : local.dst_files_dir
      }
    }

    #  Execute script: configure_os_for_sap.sh
    provisioner_remote_exec_inline_post_exec_commands = [
      "chmod +x ${local.dst_configure_os_for_sap_file_path}",
      local.dst_configure_os_for_sap_file_path,
    ]
  }
}



module "ansible_sap_instance_init" {
  source  = "terraform-ibm-modules/powervs-instance/ibm//modules//remote-exec-ansible"
  version = "1.0.1"

  bastion_host_ip                                   = var.access_host_or_ip
  host_ip                                           = var.target_server_ip
  ssh_private_key                                   = var.ssh_private_key
  provisioner_remote_exec_inline_pre_exec_commands  = local.pi_configure_os_for_sap.provisioner_remote_exec_inline_pre_exec_commands
  provisioner_file_1                                = local.pi_configure_os_for_sap.provisioner_file_1
  provisioner_file_2                                = local.pi_configure_os_for_sap.provisioner_file_2
  provisioner_remote_exec_inline_post_exec_commands = local.pi_configure_os_for_sap.provisioner_remote_exec_inline_post_exec_commands
}
