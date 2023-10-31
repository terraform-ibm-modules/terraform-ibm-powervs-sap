locals {
  scr_scripts_dir = "${path.module}/templates"
  dst_scripts_dir = "/root/terraform_files"

  ansible_configure_network_services_playbook_name = "powervs-services.yml"
  src_script_configure_network_services_tftpl_path = "${local.scr_scripts_dir}/configure_network_services.sh.tftpl"
  dst_script_configure_network_services_sh_path    = "${local.dst_scripts_dir}/server_config.sh"
  dst_ansible_vars_path                            = "${local.dst_scripts_dir}/server_config.yml"

}
resource "null_resource" "sharefs_nfs_server" {
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
    content     = <<EOF
server_config: ${jsonencode(var.service_config)}
EOF
    destination = local.dst_ansible_vars_path
  }

  ####### Copy Template file to target host ############
  provisioner "file" {
    destination = local.dst_script_configure_network_services_sh_path
    content = templatefile(
      local.src_script_configure_network_services_tftpl_path,
      {
        "ansible_playbook_name" : local.ansible_configure_network_services_playbook_name
        "ansible_extra_vars_path" : local.dst_ansible_vars_path
        "ansible_log_path" : local.dst_scripts_dir
      }
    )
  }

  ####  Execute ansible roles: to hana/netweaver preconfigure  ####
  provisioner "remote-exec" {
    inline = [
      "chmod +x ${local.dst_script_configure_network_services_sh_path}",
      local.dst_script_configure_network_services_sh_path
    ]
  }

}
