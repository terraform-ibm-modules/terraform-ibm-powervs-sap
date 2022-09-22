#  PowerVS SAP system example to create SAP prepared PowerVS instances from IBM Cloud Catalog

The PowerVS SAP system example automates the following tasks:
- Creates and configures one PowerVS instance for SAP HANA based on best practises
- Creates and configures 1..n PowerVS instances for SAP NetWeaver based on best practises
- Creates and configures one optional PowerVS instance that can be used for sharing SAP files between other system instances.
- Connects all created PowerVS instances to proxy server specified by IP address or host name
- Optionally connects all created PowerVS instances to NTP and/or DNS forwarder specified by IP address or host name
- Optionally configures on all created PowerVS instances a shared NFS directory provided by NFS server specified by IP address or host name

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >=1.1 |
| <a name="requirement_ibm"></a> [ibm](#requirement\_ibm) | >=1.44.3 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_sap_systems"></a> [sap\_systems](#module\_sap\_systems) | ../../../ | n/a |

## Resources

| Name | Type |
|------|------|
| [ibm_schematics_output.schematics_output](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/data-sources/schematics_output) | data source |
| [ibm_schematics_workspace.schematics_workspace](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/data-sources/schematics_workspace) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_calculate_hana_fs_sizes_automatically"></a> [calculate\_hana\_fs\_sizes\_automatically](#input\_calculate\_hana\_fs\_sizes\_automatically) | Specify if SAP HANA file system sizes should be calculated automatically instead of using specification defined in optional parameters. | `bool` | `true` | no |
| <a name="input_create_separate_fs_share"></a> [create\_separate\_fs\_share](#input\_create\_separate\_fs\_share) | Deploy separate IBM PowerVS instance as central file system share. Instance can be configured in optional parameters (cpus, memory size, etc.). Otherwise, defaults will be used. | `bool` | `false` | no |
| <a name="input_default_hana_rhel_image"></a> [default\_hana\_rhel\_image](#input\_default\_hana\_rhel\_image) | Default Red Hat Linux image to use for SAP HANA PowerVS instances. | `string` | `"RHEL8-SP4-SAP"` | no |
| <a name="input_default_hana_sles_image"></a> [default\_hana\_sles\_image](#input\_default\_hana\_sles\_image) | Default SuSE Linux image to use for SAP HANA PowerVS instances. | `string` | `"SLES15-SP3-SAP"` | no |
| <a name="input_default_netweaver_rhel_image"></a> [default\_netweaver\_rhel\_image](#input\_default\_netweaver\_rhel\_image) | Default Red Hat Linux image to use for SAP NetWeaver PowerVS instances. | `string` | `"RHEL8-SP4-SAP-NETWEAVER"` | no |
| <a name="input_default_netweaver_sles_image"></a> [default\_netweaver\_sles\_image](#input\_default\_netweaver\_sles\_image) | Default SuSE Linux image to use for SAP NetWeaver PowerVS instances. | `string` | `"SLES15-SP3-SAP-NETWEAVER"` | no |
| <a name="input_default_shared_fs_rhel_image"></a> [default\_shared\_fs\_rhel\_image](#input\_default\_shared\_fs\_rhel\_image) | Default Red Hat Linux image to use for SAP shared FS PowerVS instances. | `string` | `"RHEL8-SP4-SAP-NETWEAVER"` | no |
| <a name="input_default_shared_fs_sles_image"></a> [default\_shared\_fs\_sles\_image](#input\_default\_shared\_fs\_sles\_image) | Default SuSE Linux image to use for SAP shared FS PowerVS instances | `string` | `"SLES15-SP3-SAP-NETWEAVER"` | no |
| <a name="input_ibm_pvs_zone_region_map"></a> [ibm\_pvs\_zone\_region\_map](#input\_ibm\_pvs\_zone\_region\_map) | Map of IBM Power VS zone to the region of PowerVS Infrastructure | `map(any)` | <pre>{<br>  "dal12": "us-south",<br>  "eu-de-1": "eu-de",<br>  "eu-de-2": "eu-de",<br>  "lon04": "lon",<br>  "lon06": "lon",<br>  "mon01": "mon",<br>  "osa21": "osa",<br>  "sao01": "sao",<br>  "syd04": "syd",<br>  "syd05": "syd",<br>  "tok04": "tok",<br>  "tor01": "tor",<br>  "us-east": "us-east",<br>  "us-south": "us-south"<br>}</pre> | no |
| <a name="input_ibmcloud_api_key"></a> [ibmcloud\_api\_key](#input\_ibmcloud\_api\_key) | IBM Cloud Api Key | `string` | n/a | yes |
| <a name="input_os_image_distro"></a> [os\_image\_distro](#input\_os\_image\_distro) | Image distribution to use. Supported values are 'SLES' or 'RHEL'. OS release versions may be specified in optional parameters. | `string` | n/a | yes |
| <a name="input_powervs_infrastructure_workspace_id"></a> [powervs\_infrastructure\_workspace\_id](#input\_powervs\_infrastructure\_workspace\_id) | IBM cloud schematics workspace ID to reuse values from IBM PowerVS infrastructure workspace | `string` | n/a | yes |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | Unique prefix for resources to be created (e.g., SAP system name). | `string` | n/a | yes |
| <a name="input_pvs_sap_network_cidr"></a> [pvs\_sap\_network\_cidr](#input\_pvs\_sap\_network\_cidr) | Network range for separate SAP network. E.g., '10.111.1.0/24' | `string` | n/a | yes |
| <a name="input_pvs_zone"></a> [pvs\_zone](#input\_pvs\_zone) | IBM Cloud PowerVS Zone. Valid values: sao01,osa21,tor01,us-south,dal12,us-east,tok04,lon04,lon06,eu-de-1,eu-de-2,syd04,syd05 | `string` | n/a | yes |
| <a name="input_sap_domain_name"></a> [sap\_domain\_name](#input\_sap\_domain\_name) | Default network domain name for all IBM PowerVS instances. May be overwritten by individual instance configurations in optional paramteres. | `string` | n/a | yes |
| <a name="input_sap_hana_additional_storage_config"></a> [sap\_hana\_additional\_storage\_config](#input\_sap\_hana\_additional\_storage\_config) | File systems to be created and attached to PowerVS instance for SAP HANA. 'disk\_sizes' are in GB. 'count' specify over how many sotrage volumes the file system will be striped. 'tiers' specifies the storage tier in PowerVS service. For creating multiple file systems, specify multiple entries in each parameter in the strucutre. E.g., for creating 2 file systems, specify 2 names, 2 disk sizes, 2 counts, 2 tiers and 2 paths. | <pre>object({<br>    names      = string<br>    disks_size = string<br>    counts     = string<br>    tiers      = string<br>    paths      = string<br>  })</pre> | <pre>{<br>  "counts": "4,4,1,1",<br>  "disks_size": "250,150,1000,50",<br>  "names": "data,log,shared,usrsap",<br>  "paths": "/hana/data,/hana/log,/hana/shared,/usr/sap",<br>  "tiers": "tier1,tier1,tier3,tier3"<br>}</pre> | no |
| <a name="input_sap_hana_hostname"></a> [sap\_hana\_hostname](#input\_sap\_hana\_hostname) | SAP HANA hostname (non FQDN). If not specified - will get the form of <prefix>-hana. | `string` | n/a | yes |
| <a name="input_sap_hana_instance_config"></a> [sap\_hana\_instance\_config](#input\_sap\_hana\_instance\_config) | SAP HANA PowerVS instance configuration. If data is specified here - will replace other input. | <pre>object({<br>    hostname       = string<br>    domain         = string<br>    host_ip        = string<br>    sap_profile_id = string<br>    os_image_name  = string<br>  })</pre> | <pre>{<br>  "domain": "",<br>  "host_ip": "",<br>  "hostname": "",<br>  "os_image_name": "",<br>  "sap_profile_id": ""<br>}</pre> | no |
| <a name="input_sap_hana_ip"></a> [sap\_hana\_ip](#input\_sap\_hana\_ip) | Optional SAP HANA IP address (in SAP system network, specified over 'pvs\_sap\_network\_cidr' parameter). | `string` | `""` | no |
| <a name="input_sap_hana_profile"></a> [sap\_hana\_profile](#input\_sap\_hana\_profile) | SAP HANA profile to use. Must be one of the supported profiles. See XXX. | `string` | n/a | yes |
| <a name="input_sap_netweaver_cpu_number"></a> [sap\_netweaver\_cpu\_number](#input\_sap\_netweaver\_cpu\_number) | Number of CPUs for each SAP NetWeaver instance. | `string` | n/a | yes |
| <a name="input_sap_netweaver_hostname"></a> [sap\_netweaver\_hostname](#input\_sap\_netweaver\_hostname) | Comma separated list of SAP Netweaver hostnames (non FQDN). If not specified - will get the form of <prefix>-nw-<number>. | `string` | n/a | yes |
| <a name="input_sap_netweaver_instance_config"></a> [sap\_netweaver\_instance\_config](#input\_sap\_netweaver\_instance\_config) | SAP NetWeaver PowerVS instance configuration. If data is specified here - will replace other input. | <pre>object({<br>    number_of_instances  = string<br>    hostname             = string<br>    domain               = string<br>    host_ips             = string<br>    os_image_name        = string<br>    cpu_proc_type        = string<br>    number_of_processors = string<br>    memory_size          = string<br>    server_type          = string<br>  })</pre> | <pre>{<br>  "cpu_proc_type": "shared",<br>  "domain": "",<br>  "host_ips": "",<br>  "hostname": "",<br>  "memory_size": "",<br>  "number_of_instances": "",<br>  "number_of_processors": "",<br>  "os_image_name": "",<br>  "server_type": "s922"<br>}</pre> | no |
| <a name="input_sap_netweaver_instance_number"></a> [sap\_netweaver\_instance\_number](#input\_sap\_netweaver\_instance\_number) | Number of SAP NetWeaver instances that should be created. | `number` | `1` | no |
| <a name="input_sap_netweaver_ips"></a> [sap\_netweaver\_ips](#input\_sap\_netweaver\_ips) | List of optional SAP NetWeaver IP addresses (in SAP system network, specified over 'pvs\_sap\_network\_cidr' parameter). | `list(string)` | `[]` | no |
| <a name="input_sap_netweaver_memory_size"></a> [sap\_netweaver\_memory\_size](#input\_sap\_netweaver\_memory\_size) | Memory size for each SAP NetWeaver instance. | `string` | n/a | yes |
| <a name="input_sap_netweaver_storage_config"></a> [sap\_netweaver\_storage\_config](#input\_sap\_netweaver\_storage\_config) | File systems to be created and attached to PowerVS instance for SAP NetWeaver. 'disk\_sizes' are in GB. 'count' specify over how many sotrage volumes the file system will be striped. 'tiers' specifies the storage tier in PowerVS service. For creating multiple file systems, specify multiple entries in each parameter in the strucutre. E.g., for creating 2 file systems, specify 2 names, 2 disk sizes, 2 counts, 2 tiers and 2 paths. | <pre>object({<br>    names      = string<br>    disks_size = string<br>    counts     = string<br>    tiers      = string<br>    paths      = string<br>  })</pre> | <pre>{<br>  "counts": "1,1",<br>  "disks_size": "50,50",<br>  "names": "usrsap,usrtrans",<br>  "paths": "/usr/sap,/usr/sap/trans",<br>  "tiers": "tier3,tier3"<br>}</pre> | no |
| <a name="input_sap_share_instance_config"></a> [sap\_share\_instance\_config](#input\_sap\_share\_instance\_config) | SAP shared file system PowerVS instance configuration. If data is specified here - will replace other input. | <pre>object({<br>    hostname             = string<br>    domain               = string<br>    host_ip              = string<br>    os_image_name        = string<br>    cpu_proc_type        = string<br>    number_of_processors = string<br>    memory_size          = string<br>    server_type          = string<br>  })</pre> | <pre>{<br>  "cpu_proc_type": "shared",<br>  "domain": "",<br>  "host_ip": "",<br>  "hostname": "",<br>  "memory_size": "4",<br>  "number_of_processors": "0.5",<br>  "os_image_name": "",<br>  "server_type": "s922"<br>}</pre> | no |
| <a name="input_sap_share_storage_config"></a> [sap\_share\_storage\_config](#input\_sap\_share\_storage\_config) | File systems to be created and attached to PowerVS instance for shared storage file systems. 'disk\_sizes' are in GB. 'count' specify over how many sotrage volumes the file system will be striped. 'tiers' specifies the storage tier in PowerVS service. For creating multiple file systems, specify multiple entries in each parameter in the strucutre. E.g., for creating 2 file systems, specify 2 names, 2 disk sizes, 2 counts, 2 tiers and 2 paths. | <pre>object({<br>    names      = string<br>    disks_size = string<br>    counts     = string<br>    tiers      = string<br>    paths      = string<br>  })</pre> | <pre>{<br>  "counts": "1",<br>  "disks_size": "1000",<br>  "names": "share",<br>  "paths": "/share",<br>  "tiers": "tier3"<br>}</pre> | no |
| <a name="input_ssh_private_key"></a> [ssh\_private\_key](#input\_ssh\_private\_key) | Private SSH key used to login to IBM PowerVS instances. Should match to uploaded public SSH key referenced by 'pvs\_sshkey\_name'. Entered data must be in heredoc strings format (https://www.terraform.io/language/expressions/strings#heredoc-strings). | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_access_host_or_ip"></a> [access\_host\_or\_ip](#output\_access\_host\_or\_ip) | Public IP of Provided Bastion/JumpServer Host |
| <a name="output_entered_data_non_sensitive"></a> [entered\_data\_non\_sensitive](#output\_entered\_data\_non\_sensitive) | User input (non sensitive) |
| <a name="output_entered_data_sensitive"></a> [entered\_data\_sensitive](#output\_entered\_data\_sensitive) | User input (ensitive) |
| <a name="output_hana_ips"></a> [hana\_ips](#output\_hana\_ips) | All private IPS of HANA instance |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
