# Module power_instance
This module creates and configures a PowerVS instance for SAP in the Power Virtual Server service of choice. The instances can be created for different use cases like HANA, Netweaver etc based on the inputs provided like image, profile etc.

## Prerequisites
- Installation of 'Secure infrastructure on VPC for regulated industries' catalog provision of version v1.7.1 or above.
- Installation of 'Power infrastructure for regulated industries' catalog provision of version v4.0.0 or above.

## Usage
```hcl
provider "ibm" {
  region           = var.powervs_region
  zone             = var.powervs_zone
  ibmcloud_api_key = var.ibmcloud_api_key != null ? var.ibmcloud_api_key : null
}

module "share_fs_instance" {
  count  = var.powervs_share_number_of_instances

  powervs_zone                 = var.powervs_zone
  powervs_resource_group_name  = var.powervs_resource_group_name
  powervs_workspace_name         = var.powervs_workspace_name
  powervs_instance_name        = var.powervs_share_instance_name
  powervs_sshkey_name          = var.powervs_sshkey_name
  powervs_os_image_name        = var.powervs_share_image_name
  powervs_server_type          = var.powervs_share_server_type
  powervs_cpu_proc_type        = var.powervs_share_cpu_proc_type
  powervs_number_of_processors = var.powervs_share_number_of_processors
  powervs_memory_size          = var.powervs_share_memory_size
  powervs_networks             = var.powervs_additional_networks
  powervs_storage_config       = var.powervs_share_storage_config
}

module "sap_hana_instance" {
  powervs_zone                = var.powervs_zone
  powervs_resource_group_name = var.powervs_resource_group_name
  powervs_workspace_name        = var.powervs_workspace_name
  powervs_instance_name       = var.powervs_hana_instance_name
  powervs_sshkey_name         = var.powervs_sshkey_name
  powervs_os_image_name       = var.powervs_hana_image_name
  powervs_sap_profile_id      = var.powervs_hana_sap_profile_id
  powervs_networks            = concat(var.powervs_additional_networks, [var.powervs_sap_network_name])
  powervs_storage_config      = var.powervs_hana_storage_config
}

module "sap_netweaver_instance" {

  count                        = var.powervs_netweaver_number_of_instances
  powervs_zone                 = var.powervs_zone
  powervs_resource_group_name  = var.powervs_resource_group_name
  powervs_workspace_name         = var.powervs_workspace_name
  powervs_instance_name        = "${var.powervs_netweaver_instance_name}-${count.index + 1}"
  powervs_sshkey_name          = var.powervs_sshkey_name
  powervs_os_image_name        = var.powervs_netweaver_image_name
  powervs_server_type          = var.powervs_netweaver_server_type
  powervs_cpu_proc_type        = var.powervs_netweaver_cpu_proc_type
  powervs_number_of_processors = var.powervs_netweaver_number_of_processors
  powervs_memory_size          = var.powervs_netweaver_memory_size
  powervs_networks             = concat(var.powervs_additional_networks, [var.powervs_sap_network_name])
  powervs_storage_config       = var.powervs_netweaver_storage_config
}
```
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >=1.1 |
| <a name="requirement_ibm"></a> [ibm](#requirement\_ibm) | >=1.48.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [ibm_pi_instance.sap_instance](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/pi_instance) | resource |
| [ibm_pi_volume.create_volume](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/pi_volume) | resource |
| [ibm_pi_volume_attach.instance_volumes_attach](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/pi_volume_attach) | resource |
| [ibm_pi_image.image_ds](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/data-sources/pi_image) | data source |
| [ibm_pi_instance.instance_ips_ds](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/data-sources/pi_instance) | data source |
| [ibm_pi_instance_ip.instance_mgmt_ip_ds](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/data-sources/pi_instance_ip) | data source |
| [ibm_pi_key.key_ds](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/data-sources/pi_key) | data source |
| [ibm_pi_network.powervs_subnets_ds](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/data-sources/pi_network) | data source |
| [ibm_resource_group.resource_group_ds](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/data-sources/resource_group) | data source |
| [ibm_resource_instance.powervs_workspace_ds](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/data-sources/resource_instance) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_powervs_cpu_proc_type"></a> [powervs\_cpu\_proc\_type](#input\_powervs\_cpu\_proc\_type) | Dedicated or shared processors | `string` | `null` | no |
| <a name="input_powervs_instance_name"></a> [powervs\_instance\_name](#input\_powervs\_instance\_name) | Name of instance which will be created | `string` | n/a | yes |
| <a name="input_powervs_memory_size"></a> [powervs\_memory\_size](#input\_powervs\_memory\_size) | Amount of memory | `string` | `null` | no |
| <a name="input_powervs_networks"></a> [powervs\_networks](#input\_powervs\_networks) | Existing map of subnet names and IPs to be attached to the node. First network has to be a management network. If IP is null, the address will be generated. | `list(string)` | n/a | yes |
| <a name="input_powervs_number_of_processors"></a> [powervs\_number\_of\_processors](#input\_powervs\_number\_of\_processors) | Number of processors | `string` | `null` | no |
| <a name="input_powervs_os_image_name"></a> [powervs\_os\_image\_name](#input\_powervs\_os\_image\_name) | Image Name for PowerVS Instance | `string` | n/a | yes |
| <a name="input_powervs_os_image_storage_type"></a> [powervs\_os\_image\_storage\_type](#input\_powervs\_os\_image\_storage\_type) | Storage type for OS | `string` | `"tier3"` | no |
| <a name="input_powervs_resource_group_name"></a> [powervs\_resource\_group\_name](#input\_powervs\_resource\_group\_name) | Existing IBM Cloud resource group name. | `string` | n/a | yes |
| <a name="input_powervs_sap_profile_id"></a> [powervs\_sap\_profile\_id](#input\_powervs\_sap\_profile\_id) | SAP PROFILE ID. If this is mentioned then Memory, processors, proc\_type and sys\_type will not be taken into account | `string` | `null` | no |
| <a name="input_powervs_server_type"></a> [powervs\_server\_type](#input\_powervs\_server\_type) | Processor type e980/s922/e1080/s1022 | `string` | `null` | no |
| <a name="input_powervs_sshkey_name"></a> [powervs\_sshkey\_name](#input\_powervs\_sshkey\_name) | Existing PowerVs SSH key name. | `string` | n/a | yes |
| <a name="input_powervs_storage_config"></a> [powervs\_storage\_config](#input\_powervs\_storage\_config) | DISKS To be created and attached to PowerVS Instance. Comma separated values.'disk\_sizes' are in GB. 'count' specify over how many storage volumes the file system will be striped. 'tiers' specifies the storage tier in PowerVS workspace. For creating multiple file systems, specify multiple entries in each parameter in the structure. E.g., for creating 2 file systems, specify 2 names, 2 disk sizes, 2 counts, 2 tiers and 2 paths. | <pre>object({<br>    names      = string<br>    disks_size = string<br>    counts     = string<br>    tiers      = string<br>    paths      = string<br>  })</pre> | <pre>{<br>  "counts": "",<br>  "disks_size": "",<br>  "names": "",<br>  "paths": "",<br>  "tiers": ""<br>}</pre> | no |
| <a name="input_powervs_workspace_name"></a> [powervs\_workspace\_name](#input\_powervs\_workspace\_name) | Existing Name of the PowerVS workspace. | `string` | n/a | yes |
| <a name="input_powervs_zone"></a> [powervs\_zone](#input\_powervs\_zone) | IBM Cloud PowerVS zone. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_instance_mgmt_ip"></a> [instance\_mgmt\_ip](#output\_instance\_mgmt\_ip) | IP address of the management network interface of IBM PowerVS instance. |
| <a name="output_instance_private_ips"></a> [instance\_private\_ips](#output\_instance\_private\_ips) | All private IP addresses (as a list) of IBM PowerVS instance. |
| <a name="output_instance_private_ips_info"></a> [instance\_private\_ips\_info](#output\_instance\_private\_ips\_info) | Complete info about all private IP addresses of IBM PowerVS instance. |
| <a name="output_instance_wwns"></a> [instance\_wwns](#output\_instance\_wwns) | Unique volume IDs (wwns) of all volumes attached to IBM PowerVS instance. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
