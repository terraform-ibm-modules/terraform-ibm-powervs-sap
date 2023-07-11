#####################################################
# Install SAP Solution
#####################################################

locals {

  solution_templates = {
    "s4b4" = "${local.scr_scripts_dir}/sap-swpm-install-vars-s4hana-bw4hana.yml.tfpl"

  }
  solution_template = lookup(local.solution_templates, var.solution_template, null)

  sap_solution_vars = var.solution_template == "s4b4" ? templatefile(local.solution_template,
    { sap_swpm_product_catalog_id        = var.sap_solution_vars.sap_swpm_product_catalog_id
      sap_install_media_detect_directory = var.sap_solution_vars.sap_install_media_detect_directory
      sap_swpm_sid                       = var.sap_solution_vars.sap_swpm_sid
      sap_swpm_pas_instance_nr           = var.sap_solution_vars.sap_swpm_pas_instance_nr
      sap_swpm_ascs_instance_nr          = var.sap_solution_vars.sap_swpm_ascs_instance_nr
      sap_swpm_master_password           = var.sap_solution_vars.sap_swpm_master_password
      sap_swpm_ascs_instance_hostname    = var.sap_solution_vars.sap_swpm_ascs_instance_hostname
      sap_domain                         = var.sap_solution_vars.sap_domain
      sap_swpm_db_host                   = var.sap_solution_vars.sap_swpm_db_host
      sap_swpm_db_ip                     = var.sap_solution_vars.sap_swpm_db_ip
      sap_swpm_db_sid                    = var.sap_solution_vars.sap_swpm_db_sid
      sap_swpm_db_instance_nr            = var.sap_solution_vars.sap_swpm_db_instance_nr
      sap_swpm_db_master_password        = var.sap_solution_vars.sap_swpm_db_master_password
  }) : ""

  scr_scripts_dir                       = "${path.module}/templates"
  dst_scripts_dir                       = "/root/terraform_scripts"
  src_script_install_solution_tfpl_path = "${local.scr_scripts_dir}/install_swpm.sh.tfpl"
  dst_script_install_solution_tfpl_path = "${local.dst_scripts_dir}/install_swpm.sh"
  src_ansible_playbook_path             = "${local.scr_scripts_dir}/sap-swpm-install.yml"
  dst_ansible_playbook_path             = "${local.dst_scripts_dir}/sap-swpm-install.yml"
  dst_ansible_solution_vars_path        = "${local.dst_scripts_dir}/ansible_swpm_vars.yml"
}


resource "null_resource" "sap_install_solution" {
  connection {
    type         = "ssh"
    user         = "root"
    bastion_host = var.access_host_or_ip
    host         = var.target_server_ip
    private_key  = var.ssh_private_key
    agent        = false
    timeout      = "10m"
  }


  ####### Create Terraform scripts directory ############
  provisioner "remote-exec" {
    inline = [
      "mkdir -p ${local.dst_scripts_dir}",
      "chmod 777 ${local.dst_scripts_dir}",
    ]
  }

  provisioner "file" {

    ######### Write the SWPM installation variables in ansible var file. ####
    content     = <<EOF
${local.sap_solution_vars}
EOF
    destination = local.dst_ansible_solution_vars_path
  }

  ####  Encrypting the ansible var file with sensitive information  ####
  provisioner "remote-exec" {
    inline = [
      "echo ${var.ansible_vault_password} > password_file",
      "ansible-vault encrypt ${local.dst_ansible_solution_vars_path} --vault-password-file password_file"
    ]
  }

  ######### Copy playbook to remote host ####
  provisioner "file" {
    source      = local.src_ansible_playbook_path
    destination = local.dst_ansible_playbook_path
  }

  #### Copy the bash template to target host  ####
  provisioner "file" {
    destination = local.dst_script_install_solution_tfpl_path
    content = templatefile(
      local.src_script_install_solution_tfpl_path,
      {
        "ansible_playbook_path" : local.dst_ansible_playbook_path
        "ansible_extra_vars_path" : local.dst_ansible_solution_vars_path
        "ansible_log_path" : local.dst_scripts_dir
      }
    )
  }

  ####  Execute community swpm role to install Netweaver. ####
  provisioner "remote-exec" {
    inline = [
      "chmod +x ${local.dst_script_install_solution_tfpl_path}",
      local.dst_script_install_solution_tfpl_path,
    ]
  }

  # Deleting Ansible Vault password used to encrypt the var files with sensitive information
  provisioner "remote-exec" {
    inline = [
      "rm -rf password_file"
    ]
  }
}
