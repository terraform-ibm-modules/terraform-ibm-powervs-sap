#####################################################
# PowerVs Instance Initialization for RHEL Configuration
# Copyright 2022 IBM
#####################################################

locals {
  private_key     = var.ssh_private_key
  os_release_list = split(".", var.os_activation.os_release)
}

#####################################################
# Forward Proxy squid configuration
# Copyright 2022 IBM
#####################################################

resource "null_resource" "configure_proxy" {
  count = var.vpc_bastion_proxy_config["required"] && var.vpc_bastion_proxy_config["vpc_bastion_private_ip"] != "" ? 1 : 0

  connection {
    type         = "ssh"
    user         = "root"
    bastion_host = var.bastion_public_ip
    host         = var.host_private_ip
    private_key  = local.private_key
    agent        = false
    timeout      = "15m"
  }

  provisioner "remote-exec" {
    inline = [

      #######  SQUID Forward PROXY CLIENT SETUP ############

      "echo -e \"export http_proxy=http://${var.vpc_bastion_proxy_config["vpc_bastion_private_ip"]}:3128\nexport https_proxy=http://${var.vpc_bastion_proxy_config["vpc_bastion_private_ip"]}:3128\nexport HTTP_proxy=http://${var.vpc_bastion_proxy_config["vpc_bastion_private_ip"]}:3128\nexport HTTPS_proxy=http://${var.vpc_bastion_proxy_config["vpc_bastion_private_ip"]}:3128\nexport no_proxy='${var.vpc_bastion_proxy_config["no_proxy_ips"]}'\nexport NO_PROXY='${var.vpc_bastion_proxy_config["no_proxy_ips"]}'\" >> /etc/bashrc",

      "echo \"proxy=http://${var.vpc_bastion_proxy_config["vpc_bastion_private_ip"]}:3128\" >> /etc/dnf/dnf.conf",

      ###### Restart Network #######

      "/usr/bin/systemctl restart NetworkManager ",
    ]
  }
}

#####################################################
# RHEL Registration
# Copyright 2022 IBM
#####################################################

resource "null_resource" "rhel_register" {
  count      = var.os_activation["required"] ? 1 : 0
  depends_on = [null_resource.configure_proxy]

  connection {
    type         = "ssh"
    user         = "root"
    bastion_host = var.bastion_public_ip
    host         = var.host_private_ip
    private_key  = local.private_key
    agent        = false
    timeout      = "15m"
  }

  provisioner "remote-exec" {
    inline = [

      ##### Register RHEL #####
      "subscription-manager register --username ${var.os_activation["activation_username"]} --password ${var.os_activation["activation_password"]} --auto-attach --force",
      "subscription-manager release  --set=${local.os_release_list[0]}.${local.os_release_list[1]}",
      "subscription-manager repos --enable=rhel-${local.os_release_list[0]}-for-ppc64le-baseos-e4s-rpms --enable=rhel-${local.os_release_list[0]}-for-ppc64le-appstream-e4s-rpms --enable=rhel-${local.os_release_list[0]}-for-ppc64le-sap-solutions-e4s-rpms --enable=rhel-${local.os_release_list[0]}-for-ppc64le-sap-netweaver-e4s-rpms"

    ]
  }
}

#####################################################
# Install Necessary Packages On RHEL
# Copyright 2022 IBM
#####################################################

resource "null_resource" "install_packages" {
  depends_on = [null_resource.rhel_register]

  connection {
    type         = "ssh"
    user         = "root"
    bastion_host = var.bastion_public_ip
    host         = var.host_private_ip
    private_key  = local.private_key
    agent        = false
    timeout      = "15m"
  }

  provisioner "remote-exec" {
    inline = [

      ##### Install Ansible, Git and Expect packages #####

      "yum install -y ansible",
      "yum install -y git",
      "yum install -y expect"

    ]
  }
}


#####################################################
# Execute Ansible galaxy role to prepare the system
# for SAP installation
# Copyright 2022 IBM
#####################################################

locals {
  disks_config = { for key, value in var.pvs_instance_storage_config : key => split(",", var.pvs_instance_storage_config[key]) }
}

resource "null_resource" "execute_ansible_role" {
  depends_on = [null_resource.install_packages]

  connection {
    type         = "ssh"
    user         = "root"
    bastion_host = var.bastion_public_ip
    host         = var.host_private_ip
    private_key  = local.private_key
    agent        = false
    timeout      = "15m"
  }

  provisioner "file" {

    #### Write the disks wwns and other variables required for ansible roles to file under /root/terraform_vars.yml  ####

    content = <<EOF
disks_configuration : ${jsonencode(local.disks_config)}
sap_solution : '${var.sap_solution}'
terraform_wrapper : True
sap_domain: '${var.sap_domain}'
EOF

    destination = "terraform_vars.yml"
  }

  provisioner "remote-exec" {
    inline = [

      ####  Execute ansible roles: prepare_rhel_sap, fs_creation and swap_creation  ####
      "rm -rf /usr/share/ansible/roles/*",
      "ansible-galaxy collection install ibm.power_linux_sap",
      "ansible-galaxy collection install -r ~/.ansible/collections/ansible_collections/ibm/power_linux_sap/requirements.yml",
      "unbuffer ansible-playbook --connection=local -i 'localhost,' /root/.ansible/collections/ansible_collections/ibm/power_linux_sap/playbooks/playbook-rhel.yml --extra-vars '@/root/terraform_vars.yml' 2>&1 | tee ansible_execution.log ",
    ]
  }

}
