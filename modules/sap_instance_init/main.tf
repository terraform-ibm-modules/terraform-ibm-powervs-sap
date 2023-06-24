#####################################################
# 1. Execute Ansible galaxy role to prepare OS for SAP
#####################################################

locals {
  scr_scripts_dir = "${path.module}/templates"
  dst_scripts_dir = "/root/terraform_scripts"

  ansible_configure_os_for_sap_playbook_name = "power-linux-configure.yml"
  src_script_configure_os_for_sap_tfpl_path  = "${local.scr_scripts_dir}/configure_os_for_sap.sh.tfpl"
  dst_script_configure_os_for_sap_sh_path    = "${local.dst_scripts_dir}/configure_os_for_sap.sh"
  dst_ansible_vars_configure_os_for_sap_path = "${local.dst_scripts_dir}/ansible_configure_os_for_sap.yml"
}

#####################################################
# 1. Execute Ansible galaxy role to prepare OS for SAP
#####################################################

resource "null_resource" "configure_os_for_sap" {
  count = length(var.target_server_ips)

  connection {
    type         = "ssh"
    user         = "root"
    bastion_host = var.access_host_or_ip
    host         = var.target_server_ips[count.index]
    private_key  = var.ssh_private_key
    agent        = false
    timeout      = "5m"
  }

  #### Write the variables required for ansible roles to file on target host ####
  provisioner "file" {
    destination = local.dst_ansible_vars_configure_os_for_sap_path
    content     = <<EOF
sap_solution : '${var.sap_solutions[count.index]}'
sap_domain : '${var.sap_domain}'
EOF

  }

  ####### Copy Template file to target host ############
  provisioner "file" {
    destination = local.dst_script_configure_os_for_sap_sh_path
    content = templatefile(
      local.src_script_configure_os_for_sap_tfpl_path,
      {
        "ansible_playbook_name" : local.ansible_configure_os_for_sap_playbook_name
        "ansible_extra_vars_path" : local.dst_ansible_vars_configure_os_for_sap_path
        "ansible_log_path" : local.dst_scripts_dir
      }
    )
  }

  ####  Execute ansible roles: to hana/netweaver preconfigure  ####
  provisioner "remote-exec" {
    inline = [
      "chmod +x ${local.dst_script_configure_os_for_sap_sh_path}",
      local.dst_script_configure_os_for_sap_sh_path
    ]
  }

}
