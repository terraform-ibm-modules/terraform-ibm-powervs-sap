#####################################################
# Execute ansible galaxy role with ansible vault
#####################################################

locals {
  src_ansible_templates_dir = "${path.module}/../templates-ansible"
  dst_files_dir             = "/root/terraform_files"

  src_script_tftpl_path   = "${local.src_ansible_templates_dir}/${var.src_script_template_name}"
  dst_script_file_path    = "${local.dst_files_dir}/${var.dst_script_file_name}"
  src_playbook_tftpl_path = "${local.src_ansible_templates_dir}/${var.src_playbook_template_name}"
  dst_playbook_file_path  = "${local.dst_files_dir}/${var.dst_playbook_file_name}"

}

resource "terraform_data" "ansible_sap_install_solution" {

  connection {
    type         = "ssh"
    user         = "root"
    bastion_host = var.bastion_host
    host         = var.host
    private_key  = var.ssh_private_key
    agent        = false
    timeout      = "10m"
  }

  ######### Create Terraform scripts directory #########
  provisioner "remote-exec" {
    inline = ["mkdir -p ${local.dst_files_dir}", "chmod 777 ${local.dst_files_dir}", ]
  }

  ####### Copy playbook to target host ############
  provisioner "file" {
    content     = templatefile(local.src_playbook_tftpl_path, var.playbook_template_content)
    destination = local.dst_playbook_file_path
  }

  #########  Encrypting the ansible var file with sensitive information using ansible vault  #########
  provisioner "remote-exec" {
    inline = [
      "echo ${var.ansible_vault_password} > password_file",
      "ansible-vault encrypt ${local.dst_playbook_file_path} --vault-password-file password_file"
    ]
  }

  ####### Copy ansible exec shell script to target host ############
  provisioner "file" {
    content     = templatefile(local.src_script_tftpl_path, { "ansible_playbook_file" : local.dst_playbook_file_path, "ansible_log_path" : local.dst_files_dir })
    destination = local.dst_script_file_path
  }

  #######   Execute commands on target host ############
  provisioner "remote-exec" {
    inline = [
      "chmod +x ${local.dst_script_file_path}",
      local.dst_script_file_path,
    ]
  }

  ########## Deleting Ansible Vault password used to encrypt the var files with sensitive information
  provisioner "remote-exec" {
    inline = [
      "rm -rf password_file"
    ]
  }
}
