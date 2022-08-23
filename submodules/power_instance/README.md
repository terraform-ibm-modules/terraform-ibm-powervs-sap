# Module pvs-sap-instance

This module creates an instance on PowerVS, Creates volumes, attaches volumes and attaches private network

## Example Usage
```
```

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >=1.1 |
| <a name="requirement_ibm"></a> [ibm](#requirement\_ibm) | >=1.43.0 |

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
| [ibm_pi_network.pvs_subnets_ds](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/data-sources/pi_network) | data source |
| [ibm_resource_group.resource_group_ds](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/data-sources/resource_group) | data source |
| [ibm_resource_instance.pvs_service_ds](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/data-sources/resource_instance) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_pvs_cpu_proc_type"></a> [pvs\_cpu\_proc\_type](#input\_pvs\_cpu\_proc\_type) | Dedicated or shared processors | `string` | `null` | no |
| <a name="input_pvs_instance_name"></a> [pvs\_instance\_name](#input\_pvs\_instance\_name) | Name of instance which will be created | `string` | n/a | yes |
| <a name="input_pvs_memory_size"></a> [pvs\_memory\_size](#input\_pvs\_memory\_size) | Amount of memory | `string` | `null` | no |
| <a name="input_pvs_networks"></a> [pvs\_networks](#input\_pvs\_networks) | Existing map of subnet names and IPs to be attached to the node. First network has to be a management network. If IP is null, the address will be generated. | `list(any)` | <pre>[<br>  "mgmt_net",<br>  "backup_net"<br>]</pre> | no |
| <a name="input_pvs_number_of_processors"></a> [pvs\_number\_of\_processors](#input\_pvs\_number\_of\_processors) | Number of processors | `string` | `null` | no |
| <a name="input_pvs_os_image_name"></a> [pvs\_os\_image\_name](#input\_pvs\_os\_image\_name) | Image Name for node | `string` | n/a | yes |
| <a name="input_pvs_os_image_storage_type"></a> [pvs\_os\_image\_storage\_type](#input\_pvs\_os\_image\_storage\_type) | Storage type for OS | `string` | `"tier3"` | no |
| <a name="input_pvs_resource_group_name"></a> [pvs\_resource\_group\_name](#input\_pvs\_resource\_group\_name) | Existing PowerVS service resource group Name | `string` | n/a | yes |
| <a name="input_pvs_sap_profile_id"></a> [pvs\_sap\_profile\_id](#input\_pvs\_sap\_profile\_id) | SAP PROFILE ID. If this is mentioned then Memory, processors, proc\_type and sys\_type will not be taken into account | `string` | `null` | no |
| <a name="input_pvs_server_type"></a> [pvs\_server\_type](#input\_pvs\_server\_type) | Processor type e980/s922/e1080/s1022 | `string` | `null` | no |
| <a name="input_pvs_service_name"></a> [pvs\_service\_name](#input\_pvs\_service\_name) | Existing Name of the PowerVS service | `string` | n/a | yes |
| <a name="input_pvs_sshkey_name"></a> [pvs\_sshkey\_name](#input\_pvs\_sshkey\_name) | Existing SSH key name | `string` | n/a | yes |
| <a name="input_pvs_storage_config"></a> [pvs\_storage\_config](#input\_pvs\_storage\_config) | DISKS To be created and attached to node. Comma separated values | `map(any)` | <pre>{<br>  "counts": "",<br>  "disks_size": "",<br>  "names": "",<br>  "paths": "",<br>  "tiers": ""<br>}</pre> | no |
| <a name="input_pvs_zone"></a> [pvs\_zone](#input\_pvs\_zone) | IBM Cloud Zone | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_instance_mgmt_ip"></a> [instance\_mgmt\_ip](#output\_instance\_mgmt\_ip) | IP address of the management network interface of IBM PowerVS instance. |
| <a name="output_instance_private_ips"></a> [instance\_private\_ips](#output\_instance\_private\_ips) | All private IP addresses (as a list) of IBM PowerVS instance. |
| <a name="output_instance_private_ips_info"></a> [instance\_private\_ips\_info](#output\_instance\_private\_ips\_info) | Complete info about all private IP addresses of IBM PowerVS instance. |
| <a name="output_instance_wwns"></a> [instance\_wwns](#output\_instance\_wwns) | Unique volume IDs (wwns) of all volumes attached to IBM PowerVS instance. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
