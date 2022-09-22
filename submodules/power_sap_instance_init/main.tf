#####################################################
# PowerVs Instance Initialization for SLES Configuration
#####################################################

#####################################################
# Configure Squid client
#####################################################

locals {
  scripts_location     = "${path.module}/scripts"
  squidscript_location = "${local.scripts_location}/init_powervs.sh"
}

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

  provisioner "file" {
    source      = local.squidscript_location
    destination = "/root/init_powervs.sh"
  }

  provisioner "remote-exec" {
    inline = [
      #######  SQUID Forward PROXY CLIENT SETUP ############
      "chmod +x /root/init_powervs.sh",
      "/root/init_powervs.sh -p ${var.perform_proxy_client_setup["server_ip"]}:3128 -n ${var.perform_proxy_client_setup["no_proxy_env"]}",
    ]
  }
}

#####################################################
# Install Necessary Packages
#####################################################

resource "null_resource" "install_packages" {
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

  provisioner "file" {
    source      = local.squidscript_location
    destination = "/root/init_powervs.sh"
  }

  provisioner "remote-exec" {
    inline = [
      #######  Install packages ############
      "chmod +x /root/init_powervs.sh",
      "/root/init_powervs.sh -i",
    ]
  }
}

#####################################################
# Execute Ansible galaxy role to prepare the system
#####################################################

locals {
  #disks_config = { for key, value in var.powervs_instance_storage_config : key => split(",", var.powervs_instance_storage_config[key]) }
  #server_config_option_tmp = merge(var.service_config, { "enable" = true })
  #server_config_options    = { for key, value in local.server_config_option_tmp : key => local.server_config_option_tmp[key] }
  #server_config_name       = split("_", one([for item in keys(var.service_config) : item if can(regex("enable", item))]))[0]
  ansible_playbook_name = var.os_image_distro == "SLES" ? "powervs-sles.yml" : var.os_image_distro == "RHEL" ? "powervs-rhel.yml" : "unknown"
}


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

  provisioner "file" {

    #### Write the variables required for ansible roles to file under /root/tf_connect_to_mgmt_svs.yml  ####

    content = <<EOF
  client_config : {
    squid : {
      enable : ${var.perform_proxy_client_setup["enable"]},
      squid_server_ip_port : '${var.perform_proxy_client_setup["server_ip"]}:3128',
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

    destination = "tf_connect_to_mgmt_svs.yml"
  }

  provisioner "remote-exec" {
    inline = [

      ####  Execute ansible role : powervs_client_enable_services  ####

      "ansible-galaxy collection install ibm.power_linux_sap",
      "unbuffer ansible-playbook --connection=local -i 'localhost,' ~/.ansible/collections/ansible_collections/ibm/power_linux_sap/playbooks/powervs-services.yml --extra-vars '@/root/tf_connect_to_mgmt_svs.yml' 2>&1 | tee ansible_execution_mgmt_svs.log ",
    ]
  }
}

resource "null_resource" "configure_for_sap" {
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

  provisioner "file" {

    #### Write the disks wwns and other variables required for ansible roles to file under /root/tf_configure_for_sap.yml  ####

    content = <<EOF
disks_configuration : ${jsonencode({ for key, value in var.powervs_instance_storage_configs[count.index] : key => split(",", var.powervs_instance_storage_configs[count.index][key]) })}
sap_solution : '${var.sap_solutions[count.index]}'
sap_domain : '${var.sap_domain}'
EOF

    destination = "tf_configure_for_sap.yml"
  }

  provisioner "remote-exec" {
    inline = [

      ####  Execute ansible roles: prepare_sles/rhel_sap, powervs_fs_creation and powervs_swap_creation  ####

      "ansible-galaxy collection install ibm.power_linux_sap",
      "unbuffer ansible-playbook --connection=local -i 'localhost,' ~/.ansible/collections/ansible_collections/ibm/power_linux_sap/playbooks/${local.ansible_playbook_name} --extra-vars '@/root/tf_configure_for_sap.yml' 2>&1 | tee ansible_execution.log ",
    ]
  }

}
