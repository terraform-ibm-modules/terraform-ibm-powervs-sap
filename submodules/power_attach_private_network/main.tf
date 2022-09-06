#####################################################
# IBM Cloud PowerVS Resource Configuration
#####################################################

locals {
  service_type = "power-iaas"
}

data "ibm_resource_group" "resource_group_ds" {
  name = var.pvs_resource_group_name
}

data "ibm_resource_instance" "pvs_service_ds" {
  name              = var.pvs_service_name
  service           = local.service_type
  location          = var.pvs_zone
  resource_group_id = data.ibm_resource_group.resource_group_ds.id
}

#####################################################
# Create Additional Private Subnet
#####################################################

data "ibm_pi_network" "additional_network_ds" {
  pi_cloud_instance_id = data.ibm_resource_instance.pvs_service_ds.guid
  pi_network_name      = var.pvs_sap_network_name
}

#####################################################
# Reuse Cloud Connection to attach PVS subnets
#####################################################

data "ibm_pi_cloud_connections" "cloud_connection_ds" {
  pi_cloud_instance_id = data.ibm_resource_instance.pvs_service_ds.guid
}

#########################################################################
# Extend landscape and attach additional workload specific private network
#########################################################################

resource "ibm_pi_cloud_connection_network_attach" "pvs_subnet_instance_nw_attach" {
  count                  = var.pvs_cloud_connection_count > 0 ? 1 : 0
  pi_cloud_instance_id   = data.ibm_resource_instance.pvs_service_ds.guid
  pi_cloud_connection_id = data.ibm_pi_cloud_connections.cloud_connection_ds.connections[0].cloud_connection_id
  pi_network_id          = data.ibm_pi_network.additional_network_ds.pi_network_name
}

resource "ibm_pi_cloud_connection_network_attach" "pvs_subnet_instance_nw_attach_backup" {
  depends_on             = [ibm_pi_cloud_connection_network_attach.pvs_subnet_instance_nw_attach]
  count                  = var.pvs_cloud_connection_count > 1 ? 1 : 0
  pi_cloud_instance_id   = data.ibm_resource_instance.pvs_service_ds.guid
  pi_cloud_connection_id = data.ibm_pi_cloud_connections.cloud_connection_ds.connections[1].cloud_connection_id
  pi_network_id          = data.ibm_pi_network.additional_network_ds.pi_network_name
}
