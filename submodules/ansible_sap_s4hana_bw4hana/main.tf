#####################################################
# Download collections from ansible galaxy and install HANA & Netweaver
#####################################################

locals {

  scr_scripts_dir = "${path.module}/../terraform_templates"
  dst_scripts_dir = "/root/terraform_scripts"

  src_ansible_exec_tpl_path              = "${local.scr_scripts_dir}/ansible_exec.sh.tftpl"
  ansible_sap_hana_install_playbook_name = "sample-sap-hana-install.yml"
  ansible_sap_swpm_install_playbook_name = "sample-sap-swpm.yml"
  dst_ansible_vars_hana_path             = "${local.dst_scripts_dir}/ansible_hana_vars.yml"
  dst_ansible_vars_swpm_path             = "${local.dst_scripts_dir}/ansible_s4hana_bw4hana_vars.yml"
}

locals {
  nw_hostname   = var.ansible_parameters["netweaver_instance_hostname"]
  hana_hostname = var.ansible_parameters["hana_instance_hostname"]
  hana_sap_ip   = var.ansible_parameters["hana_instance_sap_ip"]
}

resource "null_resource" "sap_hana_install" {
  connection {
    type         = "ssh"
    user         = "root"
    bastion_host = var.access_host_or_ip
    host         = var.target_server_hana_ip
    private_key  = var.ssh_private_key
    agent        = false
    timeout      = "5m"
  }

  provisioner "file" {

    ######### Write the HANA installation variables in ansible var file. ####

    content = <<EOF
# Install directory must contain
#   1.  IMDB_SERVER*SAR file
#   2.  IMDB_*SAR files for all components you wish to install
#   3.  SAPCAR executable

${yamlencode(var.ansible_parameters["hana_ansible_vars"])}
EOF

    destination = local.dst_ansible_vars_hana_path

  }

  provisioner "file" {
    destination = "${local.dst_scripts_dir}/hana_install.sh"
    content = templatefile(
      local.src_ansible_exec_tpl_path,
      {
        "ansible_playbook_name" : local.ansible_sap_hana_install_playbook_name
        "ansible_extra_vars_path" : local.dst_ansible_vars_hana_path
      }
    )
  }

  provisioner "remote-exec" {
    inline = [
      ####  Execute ansible community role to install HANA. ####

      "chmod +x ${local.dst_scripts_dir}/hana_install.sh",
      "${local.dst_scripts_dir}/hana_install.sh"
    ]
  }
}

resource "null_resource" "sap_nw_install" {
  depends_on = [null_resource.sap_hana_install]
  connection {
    type         = "ssh"
    user         = "root"
    bastion_host = var.access_host_or_ip
    host         = var.target_server_nw_ip
    private_key  = var.ssh_private_key
    agent        = false
    timeout      = "5m"
  }

  provisioner "file" {

    #### Write the netweaver installation variables in ansible var file ####

    content = <<EOF
${yamlencode(var.ansible_parameters["netweaver_ansible_vars"])}
sap_swpm_ascs_instance_hostname: '${local.nw_hostname}'
sap_swpm_db_host: '${local.hana_hostname}'
sap_swpm_db_ip: '${local.hana_sap_ip}'

EOF

    destination = local.dst_ansible_vars_swpm_path
  }

  provisioner "file" {
    destination = "${local.dst_scripts_dir}/swpm_install.sh"
    content = templatefile(
      local.src_ansible_exec_tpl_path,
      {
        "ansible_playbook_name" : local.ansible_sap_swpm_install_playbook_name
        "ansible_extra_vars_path" : local.dst_ansible_vars_swpm_path
      }
    )
  }

  provisioner "remote-exec" {
    inline = [
      ####  Execute ansible community role to install S4HANA/BW4HANA based on solution passed  ####

      "chmod +x ${local.dst_scripts_dir}/swpm_install.sh",
      "${local.dst_scripts_dir}/swpm_install.sh"
    ]
  }
}
