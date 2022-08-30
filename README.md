# Module powervs-sap-instance

This module creates an instance on PowerVS, Creates volumes, attaches volumes and attaches private network

## Example Usage
```
```

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.0 |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.1.0 |
| <a name="requirement_ibm"></a> [ibm](#requirement\_ibm) | >= 1.43.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_new_sap_network"></a> [new\_sap\_network](#module\_new\_sap\_network) | ./submodules/power_create_and_add_private_network | n/a |
| <a name="module_sap_hana_instance"></a> [sap\_hana\_instance](#module\_sap\_hana\_instance) | ./submodules/power_instance | n/a |
| <a name="module_sap_images_import"></a> [sap\_images\_import](#module\_sap\_images\_import) | ./submodules/power_image_import | n/a |
| <a name="module_sap_netweaver_instance"></a> [sap\_netweaver\_instance](#module\_sap\_netweaver\_instance) | ./submodules/power_instance | n/a |
| <a name="module_share_fs_instance"></a> [share\_fs\_instance](#module\_share\_fs\_instance) | ./submodules/power_instance | n/a |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_access_host_or_ip"></a> [access\_host\_or\_ip](#input\_access\_host\_or\_ip) | Public IP of Bastion/jumpserver Host | `string` | n/a | yes |
| <a name="input_greenfield"></a> [greenfield](#input\_greenfield) | Specifies if PowerVS service is created in the workflow directly (greenfield deployment). | `bool` | `false` | no |
| <a name="input_pvs_additional_networks"></a> [pvs\_additional\_networks](#input\_pvs\_additional\_networks) | Existing list of subnets name to be attached to node. First network has to be a management network | `list(any)` | n/a | yes |
| <a name="input_pvs_cloud_connection_count"></a> [pvs\_cloud\_connection\_count](#input\_pvs\_cloud\_connection\_count) | Required number of Cloud connections which will be created/Reused. Maximum is 2 per location | `string` | `2` | no |
| <a name="input_pvs_hana_image_name"></a> [pvs\_hana\_image\_name](#input\_pvs\_hana\_image\_name) | Image Names to import into the service | `string` | n/a | yes |
| <a name="input_pvs_hana_instance_name"></a> [pvs\_hana\_instance\_name](#input\_pvs\_hana\_instance\_name) | Name of instance which will be created | `string` | n/a | yes |
| <a name="input_pvs_hana_sap_profile_id"></a> [pvs\_hana\_sap\_profile\_id](#input\_pvs\_hana\_sap\_profile\_id) | SAP PROFILE ID. If this is mentioned then Memory, processors, proc\_type and sys\_type will not be taken into account | `string` | `null` | no |
| <a name="input_pvs_hana_storage_config"></a> [pvs\_hana\_storage\_config](#input\_pvs\_hana\_storage\_config) | DISKS To be created and attached to node.Comma separated values | `map(any)` | <pre>{<br>  "counts": "",<br>  "disks_size": "",<br>  "names": "",<br>  "paths": "",<br>  "tiers": ""<br>}</pre> | no |
| <a name="input_pvs_image_list_for_import"></a> [pvs\_image\_list\_for\_import](#input\_pvs\_image\_list\_for\_import) | Image Names to import into the service | `list(string)` | n/a | yes |
| <a name="input_pvs_netweaver_cpu_proc_type"></a> [pvs\_netweaver\_cpu\_proc\_type](#input\_pvs\_netweaver\_cpu\_proc\_type) | Dedicated or shared processors | `string` | `"shared"` | no |
| <a name="input_pvs_netweaver_image_name"></a> [pvs\_netweaver\_image\_name](#input\_pvs\_netweaver\_image\_name) | Image Names to import into the service | `string` | n/a | yes |
| <a name="input_pvs_netweaver_instance_name"></a> [pvs\_netweaver\_instance\_name](#input\_pvs\_netweaver\_instance\_name) | Name of instance which will be created | `string` | n/a | yes |
| <a name="input_pvs_netweaver_memory_size"></a> [pvs\_netweaver\_memory\_size](#input\_pvs\_netweaver\_memory\_size) | Amount of memory | `string` | n/a | yes |
| <a name="input_pvs_netweaver_number_of_instances"></a> [pvs\_netweaver\_number\_of\_instances](#input\_pvs\_netweaver\_number\_of\_instances) | Number of instances | `string` | `1` | no |
| <a name="input_pvs_netweaver_number_of_processors"></a> [pvs\_netweaver\_number\_of\_processors](#input\_pvs\_netweaver\_number\_of\_processors) | Number of processors | `string` | n/a | yes |
| <a name="input_pvs_netweaver_server_type"></a> [pvs\_netweaver\_server\_type](#input\_pvs\_netweaver\_server\_type) | Processor type e980, s922, s1022 or e1080 | `string` | `"s922"` | no |
| <a name="input_pvs_netweaver_storage_config"></a> [pvs\_netweaver\_storage\_config](#input\_pvs\_netweaver\_storage\_config) | DISKS To be created and attached to node.Comma separated values | `map(any)` | <pre>{<br>  "counts": "",<br>  "disks_size": "",<br>  "names": "",<br>  "paths": "",<br>  "tiers": ""<br>}</pre> | no |
| <a name="input_pvs_resource_group_name"></a> [pvs\_resource\_group\_name](#input\_pvs\_resource\_group\_name) | Existing PowerVS service resource group Name | `string` | n/a | yes |
| <a name="input_pvs_sap_network_cidr"></a> [pvs\_sap\_network\_cidr](#input\_pvs\_sap\_network\_cidr) | CIDR for new network for SAP system | `string` | n/a | yes |
| <a name="input_pvs_sap_network_name"></a> [pvs\_sap\_network\_name](#input\_pvs\_sap\_network\_name) | Name for new network for SAP system | `string` | n/a | yes |
| <a name="input_pvs_service_name"></a> [pvs\_service\_name](#input\_pvs\_service\_name) | Existing Name of the PowerVS service | `string` | n/a | yes |
| <a name="input_pvs_share_cpu_proc_type"></a> [pvs\_share\_cpu\_proc\_type](#input\_pvs\_share\_cpu\_proc\_type) | Dedicated or shared processors | `string` | `"shared"` | no |
| <a name="input_pvs_share_image_name"></a> [pvs\_share\_image\_name](#input\_pvs\_share\_image\_name) | Image Names to import into the service | `string` | n/a | yes |
| <a name="input_pvs_share_instance_name"></a> [pvs\_share\_instance\_name](#input\_pvs\_share\_instance\_name) | Name of instance which will be created | `string` | n/a | yes |
| <a name="input_pvs_share_memory_size"></a> [pvs\_share\_memory\_size](#input\_pvs\_share\_memory\_size) | Amount of memory | `string` | `2` | no |
| <a name="input_pvs_share_number_of_instances"></a> [pvs\_share\_number\_of\_instances](#input\_pvs\_share\_number\_of\_instances) | Number of instances | `string` | n/a | yes |
| <a name="input_pvs_share_number_of_processors"></a> [pvs\_share\_number\_of\_processors](#input\_pvs\_share\_number\_of\_processors) | Number of processors | `string` | `0.5` | no |
| <a name="input_pvs_share_server_type"></a> [pvs\_share\_server\_type](#input\_pvs\_share\_server\_type) | Processor type e980, s922, s1022 or e1080 | `string` | `"s922"` | no |
| <a name="input_pvs_share_storage_config"></a> [pvs\_share\_storage\_config](#input\_pvs\_share\_storage\_config) | DISKS To be created and attached to node.Comma separated values | `map(any)` | <pre>{<br>  "counts": "",<br>  "disks_size": "",<br>  "names": "",<br>  "paths": "",<br>  "tiers": ""<br>}</pre> | no |
| <a name="input_pvs_sshkey_name"></a> [pvs\_sshkey\_name](#input\_pvs\_sshkey\_name) | Existing SSH key name | `string` | n/a | yes |
| <a name="input_pvs_zone"></a> [pvs\_zone](#input\_pvs\_zone) | IBM Cloud Zone | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_access_host_or_ip"></a> [access\_host\_or\_ip](#output\_access\_host\_or\_ip) | Public IP to manage the environment |
| <a name="output_hana_instance_private_ips"></a> [hana\_instance\_private\_ips](#output\_hana\_instance\_private\_ips) | Private IPs of the HANA instance. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
