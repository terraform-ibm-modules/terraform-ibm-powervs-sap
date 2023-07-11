#####################################################
# Install SAP HANA
#####################################################

locals {

  hana_templates = {
    "s4hana"  = "${local.scr_scripts_dir}/sap-hana-install-vars-for-s4hana-bw4hana.yml.tfpl"
    "bw4hana" = "${local.scr_scripts_dir}/sap-hana-install-vars-for-s4hana-bw4hana.yml.tfpl"
  }
  hana_template = lookup(local.hana_templates, var.hana_template, null)

  sap_hana_vars = var.hana_template == "s4hana" || var.hana_template == "bw4hana" ? templatefile(local.hana_template,
    { sap_hana_install_software_directory = var.sap_hana_vars.sap_hana_install_software_directory,
      sap_hana_install_sid                = var.sap_hana_vars.sap_hana_install_sid,
      sap_hana_install_number             = var.sap_hana_vars.sap_hana_install_number,
      sap_hana_install_master_password    = var.sap_hana_vars.sap_hana_install_master_password
  }) : ""

  scr_scripts_dir                   = "${path.module}/templates"
  dst_scripts_dir                   = "/root/terraform_scripts"
  src_script_install_hana_tfpl_path = "${local.scr_scripts_dir}/install_hana.sh.tfpl"
  dst_script_install_hana_tfpl_path = "${local.dst_scripts_dir}/install_hana.sh"
  src_ansible_playbook_path         = "${local.scr_scripts_dir}/sap-hana-install.yml"
  dst_ansible_playbook_path         = "${local.dst_scripts_dir}/sap-hana-install.yml"
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


  ####### Create Terraform scripts directory ############
  provisioner "remote-exec" {
    inline = [
      "mkdir -p ${local.dst_scripts_dir}",
      "chmod 777 ${local.dst_scripts_dir}",
    ]
  }

  provisioner "file" {

    ######### Write the HANA installation variables in ansible var file. ####
    content     = <<EOF
${local.sap_hana_vars}
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

  ######### Copy playbook to remote host ####
  provisioner "file" {
    source      = local.src_ansible_playbook_path
    destination = local.dst_ansible_playbook_path
  }

  #### Copy the bash template to target host  ####
  provisioner "file" {
    destination = local.dst_script_install_hana_tfpl_path
    content = templatefile(
      local.src_script_install_hana_tfpl_path,
      {
        "ansible_playbook_path" : local.dst_ansible_playbook_path
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
    ]
  }

  # Deleting Ansible Vault password used to encrypt the var files with sensitive information
  provisioner "remote-exec" {
    inline = [
      "rm -rf password_file"
    ]
  }
}
