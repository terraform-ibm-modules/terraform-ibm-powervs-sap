#####################################################
# Install SAP Solution
#####################################################

locals {

  ansible_sap_solution = lookup(local.ansible_sap_solutions, var.solution_template, null)

  ansible_variables                     = templatefile(local.ansible_sap_solution.src_ansible_variable_path, var.ansible_sap_solution_vars)
  dst_ansible_variable_path             = local.ansible_sap_solution.dst_ansible_variable_path
  src_ansible_playbook_path             = local.ansible_sap_solution.src_ansible_playbook_path
  dst_ansible_playbook_path             = local.ansible_sap_solution.dst_ansible_playbook_path
  src_script_install_solution_tfpl_path = local.ansible_sap_solution.src_script_install_solution_tfpl_path
  dst_script_install_solution_tfpl_path = local.ansible_sap_solution.dst_script_install_solution_tfpl_path

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

  ######### Create Terraform scripts directory #########
  provisioner "remote-exec" {
    inline = [
      "mkdir -p ${local.dst_scripts_dir}",
      "chmod 777 ${local.dst_scripts_dir}",
    ]
  }

  ######### Write the SWPM installation variables in ansible var file. #########
  provisioner "file" {
    destination = local.dst_ansible_variable_path
    content     = <<EOF
${local.ansible_variables}
EOF

  }

  #########  Encrypting the ansible var file with sensitive information using ansible vault  #########
  provisioner "remote-exec" {
    inline = [
      "echo ${var.ansible_vault_password} > password_file",
      "ansible-vault encrypt ${local.dst_ansible_variable_path} --vault-password-file password_file"
    ]
  }

  ######### Copy playbook to remote host #########
  provisioner "file" {
    source      = local.src_ansible_playbook_path
    destination = local.dst_ansible_playbook_path
  }

  ######### Copy the bash template to target host  #########
  provisioner "file" {
    destination = local.dst_script_install_solution_tfpl_path
    content = templatefile(local.src_script_install_solution_tfpl_path,
      {
        "ansible_playbook_path" : local.dst_ansible_playbook_path
        "ansible_extra_vars_path" : local.dst_ansible_variable_path
        "ansible_log_path" : local.dst_scripts_dir
      }
    )
  }

  #########  Execute community swpm role to install Netweaver. #########
  provisioner "remote-exec" {
    inline = [
      "chmod +x ${local.dst_script_install_solution_tfpl_path}",
      local.dst_script_install_solution_tfpl_path,
    ]
  }

  ########## Deleting Ansible Vault password used to encrypt the var files with sensitive information
  provisioner "remote-exec" {
    inline = [
      "rm -rf password_file"
    ]
  }
}
