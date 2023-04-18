#####################################################
# 1. Configure Squid client
# 2. Update OS and Reboot
# 3. Install Necessary Packages
# 4. Execute Ansible galaxy role to install Management
# services for SAP installation
# 5. Execute Ansible galaxy role to prepare OS for SAP
#####################################################

locals {
  scr_scripts_dir = "${path.module}/../terraform_templates"
  dst_scripts_dir = "/root/terraform_scripts"

  src_services_init_tpl_path    = "${local.scr_scripts_dir}/services_init.sh.tftpl"
  dst_services_init_path        = "${local.dst_scripts_dir}/services_init.sh"
  src_install_packages_tpl_path = "${local.scr_scripts_dir}/install_packages.sh.tftpl"
  dst_install_packages_path     = "${local.dst_scripts_dir}/install_packages.sh"

  ansible_connect_mgmt_svs_playbook_name     = "powervs-services.yml"
  ansible_configure_os_for_sap_playbook_name = var.os_image_distro == "SLES" ? "powervs-sles.yml" : var.os_image_distro == "RHEL" ? "powervs-rhel.yml" : "unknown"
  src_ansible_exec_tpl_path                  = "${local.scr_scripts_dir}/ansible_exec.sh.tftpl"
  dst_ansible_vars_connect_mgmt_svs_path     = "${local.dst_scripts_dir}/ansible_connect_to_mgmt_svs.yml"
  dst_ansible_vars_configure_os_for_sap_path = "${local.dst_scripts_dir}/ansible_configure_os_for_sap.yml"
}

#####################################################
# 1. Configure Squid client
#####################################################

resource "null_resource" "perform_proxy_client_setup" {

  count = var.perform_proxy_client_setup != null && var.perform_proxy_client_setup["enable"] == true ? length(var.target_server_ips) : 0

  connection {
    type         = "ssh"
    user         = "root"
    bastion_host = var.access_host_or_ip
    host         = var.target_server_ips[count.index]
    private_key  = var.ssh_private_key
    agent        = false
    timeout      = "5m"
  }

  ####### Create Terraform scripts directory ############
  provisioner "remote-exec" {
    inline = [
      "mkdir -p ${local.dst_scripts_dir}",
      "chmod 777 ${local.dst_scripts_dir}",
    ]
  }

  ####### Copy template file to target host ############
  provisioner "file" {
    destination = local.dst_services_init_path
    content = templatefile(
      local.src_services_init_tpl_path,
      {
        "proxy_ip_and_port" : var.perform_proxy_client_setup["server_ip_port"]
        "no_proxy_ip" : var.perform_proxy_client_setup["no_proxy_hosts"]
      }
    )
  }

  #######  Execute script: SQUID Forward Proxy client setup and OS Registration ############
  provisioner "remote-exec" {
    inline = [
      "chmod +x ${local.dst_services_init_path}",
      "${local.dst_services_init_path} setup_proxy",
      "${local.dst_services_init_path} register_os"
    ]
  }
}


#####################################################
# 2. Update OS and Reboot
#####################################################

resource "null_resource" "update_os" {
  depends_on = [null_resource.perform_proxy_client_setup]
  count      = length(var.target_server_ips)

  connection {
    type         = "ssh"
    user         = "root"
    bastion_host = var.access_host_or_ip
    host         = var.target_server_ips[count.index]
    private_key  = var.ssh_private_key
    agent        = false
    timeout      = "5m"
  }

  ####### Create Terraform scripts directory , Update OS and Reboot ############
  provisioner "remote-exec" {
    inline = [
      "mkdir -p ${local.dst_scripts_dir}",
      "chmod 777 ${local.dst_scripts_dir}",
    ]
  }

  ####### Copy Template file to target host ############
  provisioner "file" {
    destination = local.dst_services_init_path
    content = templatefile(
      local.src_services_init_tpl_path,
      {
        "proxy_ip_and_port" : "${var.perform_proxy_client_setup["squid_server_ip"]}:${var.perform_proxy_client_setup["squid_port"]}"
        "no_proxy_ip" : var.perform_proxy_client_setup["no_proxy_hosts"]
      }
    )
  }

  ####### Update OS and Reboot ############
  provisioner "remote-exec" {
    inline = [
      "chmod +x ${local.dst_services_init_path}",
      "${local.dst_services_init_path} update_os",
    ]
  }
}

resource "time_sleep" "wait_for_reboot" {
  depends_on      = [null_resource.update_os]
  create_duration = "120s"
}


#####################################################
# 3. Install Necessary Packages
#####################################################

resource "null_resource" "install_packages" {
  depends_on = [time_sleep.wait_for_reboot]
  count      = length(var.target_server_ips)

  connection {
    type         = "ssh"
    user         = "root"
    bastion_host = var.access_host_or_ip
    host         = var.target_server_ips[count.index]
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

  ####### Copy Template file to target host ############
  provisioner "file" {
    destination = local.dst_install_packages_path
    content = templatefile(
      local.src_install_packages_tpl_path,
      {
        "install_packages" : true
      }
    )
  }

  #######  Execute script: Install packages ############
  provisioner "remote-exec" {
    inline = [
      "chmod +x ${local.dst_install_packages_path}",
      local.dst_install_packages_path
    ]
  }
}

#####################################################
# 4. Execute Ansible galaxy role to connect to
# management services
#####################################################

resource "null_resource" "connect_to_mgmt_svs" {
  depends_on = [null_resource.install_packages]
  count      = length(var.target_server_ips)

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

    destination = local.dst_ansible_vars_connect_mgmt_svs_path
    content     = <<EOF
client_config : {
    squid : {
      enable : ${var.perform_proxy_client_setup["enable"]},
      squid_server_ip_port : '${var.perform_proxy_client_setup["server_ip_port"]}',
      no_proxy_hosts : '${var.perform_proxy_client_setup["no_proxy_hosts"]}'
    },
    ntp : {
      enable : ${var.perform_ntp_client_setup["enable"]},
      ntp_server_ip : '${var.perform_ntp_client_setup["server_ip"]}'
    },
    nfs : {
      enable : ${var.perform_nfs_client_setup["enable"]},
      nfs_server_path : '${var.perform_nfs_client_setup["nfs_server_path"]}',
      nfs_client_path : '${var.perform_nfs_client_setup["nfs_client_path"]}'
    },
    dns : {
      enable : ${var.perform_dns_client_setup["enable"]},
      dns_server_ip : '${var.perform_dns_client_setup["server_ip"]}'
    }
  }
EOF

  }

  ####### Copy Template file to target host ############
  provisioner "file" {
    destination = "${local.dst_scripts_dir}/connect_to_mgmt_svs.sh"
    content = templatefile(
      local.src_ansible_exec_tpl_path,
      {
        "ansible_playbook_name" : local.ansible_connect_mgmt_svs_playbook_name
        "ansible_extra_vars_path" : local.dst_ansible_vars_connect_mgmt_svs_path
        "ansible_log_path" : local.dst_scripts_dir
      }
    )
  }

  ####  Execute ansible role : powervs_client_enable_services  ####
  provisioner "remote-exec" {
    inline = [
      "chmod +x ${local.dst_scripts_dir}/connect_to_mgmt_svs.sh",
      "${local.dst_scripts_dir}/connect_to_mgmt_svs.sh"
    ]
  }
}

#####################################################
# 5. Execute Ansible galaxy role to prepare OS for SAP
#####################################################

resource "null_resource" "configure_os_for_sap" {
  depends_on = [null_resource.connect_to_mgmt_svs]
  count      = length(var.target_server_ips)

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
disks_configuration : ${jsonencode({ for key, value in var.powervs_instance_storage_configs[count.index] : key => split(",", var.powervs_instance_storage_configs[count.index][key]) })}
sap_solution : '${var.sap_solutions[count.index]}'
sap_domain : '${var.sap_domain}'
EOF

  }

  ####### Copy Template file to target host ############
  provisioner "file" {
    destination = "${local.dst_scripts_dir}/configure_os_for_sap.sh"
    content = templatefile(
      local.src_ansible_exec_tpl_path,
      {
        "ansible_playbook_name" : local.ansible_configure_os_for_sap_playbook_name
        "ansible_extra_vars_path" : local.dst_ansible_vars_configure_os_for_sap_path
        "ansible_log_path" : local.dst_scripts_dir
      }
    )
  }

  ####  Execute ansible roles: prepare_sles/rhel_sap, powervs_fs_creation and powervs_swap_creation  ####
  provisioner "remote-exec" {
    inline = [
      "chmod +x ${local.dst_scripts_dir}/configure_os_for_sap.sh",
      "${local.dst_scripts_dir}/configure_os_for_sap.sh"
    ]
  }

}
