#####################################################
# Install SAP HANA
#####################################################

locals {

  scr_scripts_dir = "${path.module}/templates"
  dst_scripts_dir = "/root/terraform_scripts"

  src_script_install_hana_tfpl_path = "${local.scr_scripts_dir}/install_hana.sh.tfpl"
  dst_script_install_hana_tfpl_path = "${local.dst_scripts_dir}/install_hana.sh"
  dst_ansible_hana_vars_path        = "${local.dst_scripts_dir}/ansible_hana_vars.yml"
}


resource "null_resource" "sap_install_hanadb" {
  connection {
    type         = "ssh"
    user         = "root"
    bastion_host = var.access_host_or_ip
    host         = var.target_server_ip
    private_key  = var.ssh_private_key
    agent        = false
    timeout      = "10m"
  }

  provisioner "file" {

    ######### Write the HANA installation variables in ansible var file. ####
    content = <<EOF
# Install directory must contain
#   1.  IMDB_SERVER*SAR file
#   2.  IMDB_*SAR files for all components you wish to install
#   3.  SAPCAR executable

${yamlencode(var.sap_hana_vars)}
EOF

    destination = local.dst_ansible_hana_vars_path

  }

  ####  Encrypting the ansible var file with sensitive information  ####
  provisioner "remote-exec" {
    inline = [
      "echo ${var.ansible_vault_password} > password_file",
      "ansible-vault encrypt ${local.dst_ansible_hana_vars_path} --vault-password-file password_file"
    ]
  }

  #### Copy the bash template to target host  ####
  provisioner "file" {
    destination = local.dst_script_install_hana_tfpl_path
    content = templatefile(
      local.src_script_install_hana_tfpl_path,
      {
        "ansible_extra_vars_path" : local.dst_ansible_hana_vars_path
        "ansible_log_path" : local.dst_scripts_dir
      }
    )
  }

  ####  Execute sap_hana_install linux system role to install HANA. ####
  provisioner "remote-exec" {
    inline = [
      "chmod +x ${local.dst_script_install_hana_tfpl_path}",
      local.dst_script_install_hana_tfpl_path,
      # Deleting Ansible Vault password used to encrypt the var files with sensitive information
      "rm -rf password_file"
    ]
  }
}
