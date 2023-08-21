#####################################################
# Install SAP Solution
#####################################################

locals {

  ansible_variables_templates = {
    "s4b4" = "${local.scr_scripts_dir}/sap-swpm-install-vars-s4hana-bw4hana.yml.tfpl"
  }

  ansible_playbooks = {
    "s4b4" = "${local.scr_scripts_dir}/sap-swpm-install.yml"
  }

  ansible_sap_solution_vars = templatefile(lookup(local.ansible_variables_templates, var.solution_template, null), var.ansible_sap_solution_vars)
  ansible_playbook          = lookup(local.ansible_playbooks, var.solution_template, null)

  scr_scripts_dir                       = "${path.module}/templates"
  dst_scripts_dir                       = "/root/terraform_scripts"
  src_script_install_solution_tfpl_path = "${local.scr_scripts_dir}/install_swpm.sh.tfpl"
  dst_script_install_solution_tfpl_path = "${local.dst_scripts_dir}/install_swpm.sh"
  src_ansible_playbook_path             = "${local.scr_scripts_dir}/${local.ansible_playbook}"
  dst_ansible_playbook_path             = "${local.dst_scripts_dir}/sap-swpm-install.yml"
  dst_ansible_solution_vars_path        = "${local.dst_scripts_dir}/sap-swpm-install-vars.yml"
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
${local.ansible_sap_solution_vars}
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
