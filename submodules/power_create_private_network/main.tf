#####################################################
# IBM Cloud PowerVS Resource Configuration
#####################################################

locals {
  service_type = "power-iaas"
}

data "ibm_resource_group" "resource_group_ds" {
  name = var.powervs_resource_group_name
}

data "ibm_resource_instance" "powervs_service_ds" {
  name              = var.powervs_service_name
  service           = local.service_type
  location          = var.powervs_zone
  resource_group_id = data.ibm_resource_group.resource_group_ds.id
}

#####################################################
# Create Additional Private Subnet
#####################################################

resource "ibm_pi_network" "additional_network" {
  pi_cloud_instance_id = data.ibm_resource_instance.powervs_service_ds.guid
  pi_network_name      = var.powervs_sap_network_name
  pi_cidr              = var.powervs_sap_network_cidr
  pi_dns               = ["127.0.0.1"]
  pi_network_type      = "vlan"
  pi_network_jumbo     = true
}
