locals {
  ibm_pvs_zone_region_map = {
    "syd04"    = "syd"
    "syd05"    = "syd"
    "eu-de-1"  = "eu-de"
    "eu-de-2"  = "eu-de"
    "lon04"    = "lon"
    "lon06"    = "lon"
    "tok04"    = "tok"
    "us-east"  = "us-east"
    "us-south" = "us-south"
    "dal12"    = "us-south"
    "tor01"    = "tor"
    "osa21"    = "osa"
    "sao01"    = "sao"
    "mon01"    = "mon"
  }

  ibm_pvs_zone_cloud_region_map = {
    "syd04"    = "au-syd"
    "syd05"    = "au-syd"
    "eu-de-1"  = "eu-de"
    "eu-de-2"  = "eu-de"
    "lon04"    = "eu-gb"
    "lon06"    = "eu-gb"
    "tok04"    = "jp-tok"
    "us-east"  = "us-east"
    "us-south" = "us-south"
    "dal12"    = "us-south"
    "tor01"    = "ca-tor"
    "osa21"    = "jp-osa"
    "sao01"    = "br-sao"
    "mon01"    = "ca-tor"
  }
}

#####################################################
# PVS SAP Instance Deployment example for SAP SYSTEM with new private network
# Copyright 2022 IBM
#####################################################

# There are discrepancies between the region inputs on the powervs terraform resource, and the vpc ("is") resources
provider "ibm" {
  region           = lookup(local.ibm_pvs_zone_region_map, var.pvs_zone, null)
  zone             = var.pvs_zone
  ibmcloud_api_key = var.ibmcloud_api_key != null ? var.ibmcloud_api_key : null
}

provider "ibm" {
  alias            = "ibm-is"
  region           = lookup(local.ibm_pvs_zone_cloud_region_map, var.pvs_zone, null)
  zone             = var.pvs_zone
  ibmcloud_api_key = var.ibmcloud_api_key != null ? var.ibmcloud_api_key : null
}

#####################################################
# Create a new PowerVS infrastructure from scratch
# Copyright 2022 IBM
#####################################################

locals {
  squid_config = merge(var.squid_proxy_config, {
    "squid_enable"      = var.configure_proxy
    "server_host_or_ip" = var.squid_proxy_config["squid_proxy_host_or_ip"] != null && var.squid_proxy_config["squid_proxy_host_or_ip"] != "" ? var.squid_proxy_config["squid_proxy_host_or_ip"] : var.internet_services_host_or_ip
  })
  dns_forwarder_config = merge(var.dns_forwarder_config, {
    "dns_enable"        = var.configure_dns_forwarder
    "server_host_or_ip" = var.dns_forwarder_config["dns_forwarder_host_or_ip"] != null && var.dns_forwarder_config["dns_forwarder_host_or_ip"] != "" ? var.dns_forwarder_config["dns_forwarder_host_or_ip"] : var.private_services_host_or_ip
  })
  ntp_forwarder_config = merge(var.ntp_forwarder_config, {
    "ntp_enable"        = var.configure_ntp_forwarder
    "server_host_or_ip" = var.ntp_forwarder_config["ntp_forwarder_host_or_ip"] != null && var.ntp_forwarder_config["ntp_forwarder_host_or_ip"] != "" ? var.ntp_forwarder_config["ntp_forwarder_host_or_ip"] : var.private_services_host_or_ip
  })
  nfs_config = merge(var.nfs_server_config, {
    "nfs_enable"        = var.configure_nfs_server
    "server_host_or_ip" = var.nfs_server_config["nfs_server_host_or_ip"] != null && var.nfs_server_config["nfs_server_host_or_ip"] != "" ? var.nfs_server_config["nfs_server_host_or_ip"] : var.private_services_host_or_ip
  })
}

resource "tls_private_key" "tls_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "ibm_is_ssh_key" "ssh_key" {
  provider   = ibm.ibm-is
  name       = "${var.prefix}-${var.pvs_ssh_key_name}"
  public_key = trimspace(tls_private_key.tls_key.public_key_openssh)
}

module "powervs_infratructure" {
  source                  = "git::https://github.com/terraform-ibm-modules/terraform-ibm-powervs-infrastructure.git?ref=v1.2.2-sap2"
  depends_on              = [ibm_is_ssh_key.ssh_key]
  access_host_or_ip       = var.access_host_or_ip
  pvs_zone                = var.pvs_zone
  ssh_private_key         = trimspace(tls_private_key.tls_key.private_key_openssh)
  pvs_resource_group_name = var.resource_group
  ssh_public_key          = ibm_is_ssh_key.ssh_key.public_key
  reuse_cloud_connections = var.reuse_cloud_connections
  #### add / change ###
  pvs_service_name         = "${var.prefix}-${var.pvs_service_name}"
  tags                     = var.resource_tags
  pvs_sshkey_name          = "${var.prefix}-${var.pvs_ssh_key_name}"
  pvs_management_network   = var.pvs_management_network
  pvs_backup_network       = var.pvs_backup_network
  transit_gateway_name     = var.transit_gateway_name
  cloud_connection_count   = var.cloud_connection_count
  cloud_connection_speed   = var.cloud_connection_speed
  cloud_connection_gr      = var.cloud_connection_gr
  cloud_connection_metered = var.cloud_connection_metered
  squid_config             = local.squid_config
  dns_forwarder_config     = local.dns_forwarder_config
  ntp_forwarder_config     = local.ntp_forwarder_config
  nfs_config               = local.nfs_config
}

#####################################################
# Import Catalog Images
# Copyright 2022 IBM
#####################################################

locals {
  service_type = "power-iaas"
}

data "ibm_resource_group" "resource_group_ds" {
  name = module.powervs_infratructure.pvs_resource_group_name
}

data "ibm_resource_instance" "pvs_service" {
  depends_on        = [module.powervs_infratructure]
  name              = module.powervs_infratructure.pvs_service_name
  service           = local.service_type
  location          = module.powervs_infratructure.pvs_zone
  resource_group_id = data.ibm_resource_group.resource_group_ds.id
}

data "ibm_pi_catalog_images" "catalog_images_ds" {
  sap                  = true
  pi_cloud_instance_id = data.ibm_resource_instance.pvs_service.guid
}

locals {
  image_names              = distinct([var.pvs_sap_hana_instance_config["sap_image_name"], var.pvs_sap_netweaver_instance_config["sap_image_name"], var.pvs_sap_share_instance_config["sap_image_name"]])
  catalog_images_to_import = flatten([for stock_image in data.ibm_pi_catalog_images.catalog_images_ds.images : [for image_name in local.image_names : stock_image if stock_image.name == image_name]])
}

resource "ibm_pi_image" "import_images" {
  count                = length(local.image_names)
  pi_cloud_instance_id = data.ibm_resource_instance.pvs_service.guid
  pi_image_id          = local.catalog_images_to_import[count.index].image_id
  pi_image_name        = local.image_names[count.index]
}

locals {
  networks = [module.powervs_infratructure.pvs_management_network_name, module.powervs_infratructure.pvs_backup_network_name]
}

#####################################################
# Deploy SAP systems
# Copyright 2022 IBM
#####################################################

module "sap_systems" {
  depends_on                = [module.powervs_infratructure, ibm_pi_image.import_images]
  source                    = "../../"
  greenfield                = true
  pvs_zone                  = module.powervs_infratructure.pvs_zone
  pvs_resource_group_name   = module.powervs_infratructure.pvs_resource_group_name
  pvs_service_name          = module.powervs_infratructure.pvs_service_name
  pvs_sshkey_name           = module.powervs_infratructure.pvs_ssh_key_name
  pvs_sap_network_name      = var.pvs_sap_network_name
  pvs_sap_network_cidr      = var.pvs_sap_network_cidr
  pvs_additional_networks   = local.networks
  pvs_image_list_for_import = var.images_for_import

  pvs_share_number_of_instances  = var.pvs_sap_share_instance_config["number_of_instances"]
  pvs_share_image_name           = var.pvs_sap_share_instance_config["sap_image_name"]
  pvs_share_instance_name        = "${var.prefix}-${var.pvs_sap_share_instance_config["name-suffix"]}"
  pvs_share_memory_size          = var.pvs_sap_share_instance_config["memory_size"]
  pvs_share_number_of_processors = var.pvs_sap_share_instance_config["number_of_processors"]
  pvs_share_cpu_proc_type        = var.pvs_sap_share_instance_config["cpu_proc_type"]
  pvs_share_storage_config       = var.pvs_sap_share_storage_config

  pvs_hana_instance_name  = "${var.prefix}-${var.pvs_sap_hana_instance_config["name-suffix"]}"
  pvs_hana_image_name     = var.pvs_sap_hana_instance_config["sap_image_name"]
  pvs_hana_sap_profile_id = var.pvs_sap_hana_instance_config["sap_hana_profile_id"]
  pvs_hana_storage_config = var.pvs_sap_hana_storage_config

  pvs_netweaver_number_of_instances  = var.pvs_sap_netweaver_instance_config["number_of_instances"]
  pvs_netweaver_image_name           = var.pvs_sap_netweaver_instance_config["sap_image_name"]
  pvs_netweaver_instance_name        = "${var.prefix}-${var.pvs_sap_netweaver_instance_config["name-suffix"]}"
  pvs_netweaver_memory_size          = var.pvs_sap_netweaver_instance_config["memory_size"]
  pvs_netweaver_number_of_processors = var.pvs_sap_netweaver_instance_config["number_of_processors"]
  pvs_netweaver_cpu_proc_type        = var.pvs_sap_netweaver_instance_config["cpu_proc_type"]
  pvs_netweaver_storage_config       = var.pvs_sap_netweaver_storage_config

  access_host_or_ip = var.access_host_or_ip
}
