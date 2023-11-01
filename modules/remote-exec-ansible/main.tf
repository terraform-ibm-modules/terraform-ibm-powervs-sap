#####################################################
# 1. Execute Ansible galaxy role
#####################################################

locals {
  src_ansible_templates_dir = "${path.module}/../templates-ansible"
  dst_files_dir             = "/root/terraform_files"

  src_script_tftpl_path   = "${local.src_ansible_templates_dir}/${var.src_script_template_name}"
  dst_script_file_path    = "${local.dst_files_dir}/${var.dst_script_file_name}"
  src_playbook_tftpl_path = "${local.src_ansible_templates_dir}/${var.src_playbook_template_name}"
  dst_playbook_file_path  = "${local.dst_files_dir}/${var.dst_playbook_file_name}"

}

resource "terraform_data" "remote_exec_ansible" {

  connection {
    type         = "ssh"
    user         = "root"
    bastion_host = var.bastion_host
    host         = var.host
    private_key  = var.ssh_private_key
    agent        = false
    timeout      = "10m"
  }

  ####### Execute commands on target host ############
  provisioner "remote-exec" {
    inline = ["mkdir -p ${local.dst_files_dir}", "chmod 777 ${local.dst_files_dir}", ]
  }

  ####### Copy first template file to target host ############
  provisioner "file" {
    content     = templatefile(local.src_playbook_tftpl_path, var.playbook_template_content)
    destination = local.dst_playbook_file_path
  }

  ####### Copy second template file to target host ############
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
}
