# PowerVS SAP system example to create SAP S4HANA SYSTEM

The PowerVS SAP system example automates the following tasks:

- Creates and configures one PowerVS instance for SAP HANA that is based on best practices and install SAP HANA Database.
- Creates and configures one PowerVS instances for SAP NetWeaver that is based on best practices and install S4HANA/BW4HANA solution.
- Connects all created PowerVS instances to a proxy server that is specified by IP address or hostname.
- Optionally Downloads the SAP software Binaries from Cloud Object Storage to the NFS path specified.
- Optionally connects all created PowerVS instances to an NTP server and DNS forwarder that are specified by IP address or hostname.
- Optionally configures a shared NFS directory on all created PowerVS instances. The directory is provided by an NFS server that is specified by IP address or hostname.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.0 |
| <a name="requirement_ibm"></a> [ibm](#requirement\_ibm) | =1.50.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_sap_systems"></a> [sap\_systems](#module\_sap\_systems) | ../../../../ | n/a |

## Resources

| Name | Type |
|------|------|
| [ibm_schematics_output.schematics_output](https://registry.terraform.io/providers/IBM-Cloud/ibm/1.50.0/docs/data-sources/schematics_output) | data source |
| [ibm_schematics_workspace.schematics_workspace](https://registry.terraform.io/providers/IBM-Cloud/ibm/1.50.0/docs/data-sources/schematics_workspace) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cos_config"></a> [cos\_config](#input\_cos\_config) | COS bucket access information to copy the SAP Software to LOCAL DISK. HANA software directory must contain all files related for HANA DB installation. IMDB server and SAPCAr.EXE file. Solution software directory must contain 2020 S4hana files, SAPCAR.EXE file and SWPM20SP13\_4-80003426.SAR | <pre>object(<br>    {<br>      cos_bucket_name                 = string<br>      cos_access_key                  = string<br>      cos_secret_access_key           = string<br>      cos_endpoint_url                = string<br>      cos_hana_software_directory     = string<br>      cos_solution_software_directory = string<br>    }<br>  )</pre> | n/a | yes |
| <a name="input_create_separate_fs_share"></a> [create\_separate\_fs\_share](#input\_create\_separate\_fs\_share) | Deploy separate IBM PowerVS instance as central file system share. Instance can be configured in optional parameters (cpus, memory size, etc.). Otherwise, defaults will be used. | `bool` | `false` | no |
| <a name="input_db_instance_number"></a> [db\_instance\_number](#input\_db\_instance\_number) | Instance Number for HANA Installation. | `string` | `"00"` | no |
| <a name="input_db_master_password"></a> [db\_master\_password](#input\_db\_master\_password) | Master Password for HANA database | `string` | `"NewPass$321"` | no |
| <a name="input_db_sid"></a> [db\_sid](#input\_db\_sid) | SID for HANA Installation. | `string` | `"HDB"` | no |
| <a name="input_default_hana_rhel_image"></a> [default\_hana\_rhel\_image](#input\_default\_hana\_rhel\_image) | Default Red Hat Linux image to use for SAP HANA PowerVS instances. | `string` | `"RHEL8-SP4-SAP"` | no |
| <a name="input_default_hana_sles_image"></a> [default\_hana\_sles\_image](#input\_default\_hana\_sles\_image) | Default SuSE Linux image to use for SAP HANA PowerVS instances. | `string` | `"SLES15-SP3-SAP"` | no |
| <a name="input_default_netweaver_rhel_image"></a> [default\_netweaver\_rhel\_image](#input\_default\_netweaver\_rhel\_image) | Default Red Hat Linux image to use for SAP NetWeaver PowerVS instances. | `string` | `"RHEL8-SP4-SAP-NETWEAVER"` | no |
| <a name="input_default_netweaver_sles_image"></a> [default\_netweaver\_sles\_image](#input\_default\_netweaver\_sles\_image) | Default SuSE Linux image to use for SAP NetWeaver PowerVS instances. | `string` | `"SLES15-SP3-SAP-NETWEAVER"` | no |
| <a name="input_default_shared_fs_rhel_image"></a> [default\_shared\_fs\_rhel\_image](#input\_default\_shared\_fs\_rhel\_image) | Default Red Hat Linux image to use for SAP shared FS PowerVS instances. | `string` | `"RHEL8-SP4-SAP-NETWEAVER"` | no |
| <a name="input_default_shared_fs_sles_image"></a> [default\_shared\_fs\_sles\_image](#input\_default\_shared\_fs\_sles\_image) | Default SuSE Linux image to use for SAP shared FS PowerVS instances | `string` | `"SLES15-SP3-SAP-NETWEAVER"` | no |
| <a name="input_ibmcloud_api_key"></a> [ibmcloud\_api\_key](#input\_ibmcloud\_api\_key) | IBM Cloud Api Key | `string` | n/a | yes |
| <a name="input_nfs_client_directory"></a> [nfs\_client\_directory](#input\_nfs\_client\_directory) | NFS directory on PowerVS instances. Will be used only if nfs\_server is setup in 'Power infrastructure for regulated industries' | `string` | `"/nfs"` | no |
| <a name="input_os_image_distro"></a> [os\_image\_distro](#input\_os\_image\_distro) | Image distribution to use. Supported values are 'SLES' or 'RHEL'. OS release versions may be specified in optional parameters. | `string` | `"RHEL"` | no |
| <a name="input_powervs_sap_network_cidr"></a> [powervs\_sap\_network\_cidr](#input\_powervs\_sap\_network\_cidr) | Network range for separate SAP network. E.g., '10.111.1.0/24' | `string` | `"10.111.1.0/24"` | no |
| <a name="input_powervs_zone"></a> [powervs\_zone](#input\_powervs\_zone) | IBM Cloud data center location where IBM PowerVS infrastructure will be created. | `string` | n/a | yes |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | Unique prefix for resources to be created (e.g., SAP system name). Max length must be less than or equal to 6. | `string` | n/a | yes |
| <a name="input_prerequisite_workspace_id"></a> [prerequisite\_workspace\_id](#input\_prerequisite\_workspace\_id) | IBM Cloud Schematics workspace ID of an existing Power infrastructure for regulated industries deployment. If you do not yet have an existing deployment, click [here](https://cloud.ibm.com/catalog/content/terraform-ibm-powervs-catalog-powervs-sap-infrastructure-07e92c55-6a5b-4f3d-aa0e-30212e108af9-global#create) to create one. | `string` | n/a | yes |
| <a name="input_sap_domain"></a> [sap\_domain](#input\_sap\_domain) | SAP domain to be set for entire landscape. Set to null or empty if not configuring OS. | `string` | `"sap.com"` | no |
| <a name="input_sap_hana_additional_storage_config"></a> [sap\_hana\_additional\_storage\_config](#input\_sap\_hana\_additional\_storage\_config) | Additional File systems to be created and attached to PowerVS instance for SAP HANA. 'disk\_sizes' are in GB. 'count' specify over how many storage volumes the file system will be striped. 'tiers' specifies the storage tier in PowerVS workspace. For creating multiple file systems, specify multiple entries in each parameter in the structure. E.g., for creating 2 file systems, specify 2 names, 2 disk sizes, 2 counts, 2 tiers and 2 paths. | <pre>object({<br>    names      = string<br>    disks_size = string<br>    counts     = string<br>    tiers      = string<br>    paths      = string<br>  })</pre> | <pre>{<br>  "counts": "1",<br>  "disks_size": "50",<br>  "names": "usrsap",<br>  "paths": "/usr/sap",<br>  "tiers": "tier3"<br>}</pre> | no |
| <a name="input_sap_hana_custom_storage_config"></a> [sap\_hana\_custom\_storage\_config](#input\_sap\_hana\_custom\_storage\_config) | Custom File systems to be created and attached to PowerVS instance for SAP HANA. 'disk\_sizes' are in GB. 'count' specify over how many storage volumes the file system will be striped. 'tiers' specifies the storage tier in PowerVS workspace. For creating multiple file systems, specify multiple entries in each parameter in the structure. E.g., for creating 2 file systems, specify 2 names, 2 disk sizes, 2 counts, 2 tiers and 2 paths. | <pre>object({<br>    names      = string<br>    disks_size = string<br>    counts     = string<br>    tiers      = string<br>    paths      = string<br>  })</pre> | <pre>{<br>  "counts": "",<br>  "disks_size": "",<br>  "names": "",<br>  "paths": "",<br>  "tiers": ""<br>}</pre> | no |
| <a name="input_sap_hana_hostname"></a> [sap\_hana\_hostname](#input\_sap\_hana\_hostname) | SAP HANA hostname (non FQDN). Will get the form of <prefix>-<sap\_hana\_hostname>. Max length of final hostname must be <= 13 characters. | `string` | `"hana"` | no |
| <a name="input_sap_hana_instance_config"></a> [sap\_hana\_instance\_config](#input\_sap\_hana\_instance\_config) | SAP HANA PowerVS instance configuration. If data is specified here - will replace other input. | <pre>object({<br>    os_image_name  = string<br>    sap_profile_id = string<br>  })</pre> | <pre>{<br>  "os_image_name": "",<br>  "sap_profile_id": ""<br>}</pre> | no |
| <a name="input_sap_hana_profile"></a> [sap\_hana\_profile](#input\_sap\_hana\_profile) | SAP HANA profile to use. Must be one of the supported profiles. See [here](https://cloud.ibm.com/docs/sap?topic=sap-hana-iaas-offerings-profiles-power-vs). File system sizes are automatically calculated. Override automatic calculation by setting values in optional sap\_hana\_custom\_storage\_config parameter. | `string` | `"cnp-4x128"` | no |
| <a name="input_sap_netweaver_cpu_number"></a> [sap\_netweaver\_cpu\_number](#input\_sap\_netweaver\_cpu\_number) | Number of CPUs for each SAP NetWeaver instance. | `string` | `"3"` | no |
| <a name="input_sap_netweaver_hostname"></a> [sap\_netweaver\_hostname](#input\_sap\_netweaver\_hostname) | SAP Netweaver hostname (non FQDN). Will get the form of <prefix>-<sap\_netweaver\_hostname>-<number>. Max length of final hostname must be <= 13 characters. | `string` | `"nw"` | no |
| <a name="input_sap_netweaver_instance_config"></a> [sap\_netweaver\_instance\_config](#input\_sap\_netweaver\_instance\_config) | SAP NetWeaver PowerVS instance configuration. If data is specified here - will replace other input. | <pre>object({<br>    os_image_name        = string<br>    number_of_processors = string<br>    memory_size          = string<br>    cpu_proc_type        = string<br>    server_type          = string<br>  })</pre> | <pre>{<br>  "cpu_proc_type": "shared",<br>  "memory_size": "",<br>  "number_of_processors": "",<br>  "os_image_name": "",<br>  "server_type": "s922"<br>}</pre> | no |
| <a name="input_sap_netweaver_memory_size"></a> [sap\_netweaver\_memory\_size](#input\_sap\_netweaver\_memory\_size) | Memory size for each SAP NetWeaver instance. | `string` | `"32"` | no |
| <a name="input_sap_netweaver_storage_config"></a> [sap\_netweaver\_storage\_config](#input\_sap\_netweaver\_storage\_config) | File systems to be created and attached to PowerVS instance for SAP NetWeaver. 'disk\_sizes' are in GB. 'count' specify over how many storage volumes the file system will be striped. 'tiers' specifies the storage tier in PowerVS workspace. For creating multiple file systems, specify multiple entries in each parameter in the structure. E.g., for creating 2 file systems, specify 2 names, 2 disk sizes, 2 counts, 2 tiers and 2 paths. | <pre>object({<br>    names      = string<br>    disks_size = string<br>    counts     = string<br>    tiers      = string<br>    paths      = string<br>  })</pre> | <pre>{<br>  "counts": "1,1,1",<br>  "disks_size": "50,50,50",<br>  "names": "usrsap,usrtrans,sapmnt",<br>  "paths": "/usr/sap,/usr/sap/trans,/sapmnt",<br>  "tiers": "tier3,tier3,tier3"<br>}</pre> | no |
| <a name="input_sap_share_instance_config"></a> [sap\_share\_instance\_config](#input\_sap\_share\_instance\_config) | SAP shared file system PowerVS instance configuration. If data is specified here - will replace other input. | <pre>object({<br>    os_image_name        = string<br>    number_of_processors = string<br>    memory_size          = string<br>    cpu_proc_type        = string<br>    server_type          = string<br>  })</pre> | <pre>{<br>  "cpu_proc_type": "shared",<br>  "memory_size": "4",<br>  "number_of_processors": "0.5",<br>  "os_image_name": "",<br>  "server_type": "s922"<br>}</pre> | no |
| <a name="input_sap_share_storage_config"></a> [sap\_share\_storage\_config](#input\_sap\_share\_storage\_config) | File systems to be created and attached to PowerVS instance for shared storage file systems. 'disk\_sizes' are in GB. 'count' specify over how many storage volumes the file system will be striped. 'tiers' specifies the storage tier in PowerVS workspace. For creating multiple file systems, specify multiple entries in each parameter in the structure. E.g., for creating 2 file systems, specify 2 names, 2 disk sizes, 2 counts, 2 tiers and 2 paths. | <pre>object({<br>    names      = string<br>    disks_size = string<br>    counts     = string<br>    tiers      = string<br>    paths      = string<br>  })</pre> | <pre>{<br>  "counts": "1",<br>  "disks_size": "1000",<br>  "names": "share",<br>  "paths": "/share",<br>  "tiers": "tier3"<br>}</pre> | no |
| <a name="input_sap_solution"></a> [sap\_solution](#input\_sap\_solution) | SAP Solution value has to be either s4hana or bw4hana | `string` | n/a | yes |
| <a name="input_sap_solution_version"></a> [sap\_solution\_version](#input\_sap\_solution\_version) | SAP S4HANA or BW4HANA year. Should be 4 digits like 2020, 2021 .. | `number` | n/a | yes |
| <a name="input_ssh_private_key"></a> [ssh\_private\_key](#input\_ssh\_private\_key) | Private SSH key (RSA format) used to login to IBM PowerVS instances. Should match to uploaded public SSH key referenced by 'ssh\_public\_key'. Entered data must be in [heredoc strings format](https://www.terraform.io/language/expressions/strings#heredoc-strings). The key is not uploaded or stored. For more information about SSH keys, see [SSH keys](https://cloud.ibm.com/docs/vpc?topic=vpc-ssh-keys). | `string` | n/a | yes |
| <a name="input_swpm_ascs_instance_nr"></a> [swpm\_ascs\_instance\_nr](#input\_swpm\_ascs\_instance\_nr) | ASCS Instance Number for Netweaver. | `string` | `"01"` | no |
| <a name="input_swpm_master_password"></a> [swpm\_master\_password](#input\_swpm\_master\_password) | Master password for Netweaver. | `string` | `"NewPass$321"` | no |
| <a name="input_swpm_pas_instance_nr"></a> [swpm\_pas\_instance\_nr](#input\_swpm\_pas\_instance\_nr) | PAS Instance number for Netweaver. | `string` | `"02"` | no |
| <a name="input_swpm_sid"></a> [swpm\_sid](#input\_swpm\_sid) | SID for Netweaver. | `string` | `"S4H"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_access_host_or_ip"></a> [access\_host\_or\_ip](#output\_access\_host\_or\_ip) | Public IP of Provided Bastion/JumpServer Host |
| <a name="output_hana_instance_management_ip"></a> [hana\_instance\_management\_ip](#output\_hana\_instance\_management\_ip) | Management IP of HANA Instance |
| <a name="output_hana_ips"></a> [hana\_ips](#output\_hana\_ips) | All private IPS of HANA instance |
| <a name="output_infrastructure_data"></a> [infrastructure\_data](#output\_infrastructure\_data) | Data from PowerVS infrastructure layer |
| <a name="output_netweaver_ips"></a> [netweaver\_ips](#output\_netweaver\_ips) | All private IPS of NetWeaver instances |
| <a name="output_powervs_lpars_data"></a> [powervs\_lpars\_data](#output\_powervs\_lpars\_data) | All private IPS of PowerVS instances and Jump IP to access the host. |
| <a name="output_share_fs_ips"></a> [share\_fs\_ips](#output\_share\_fs\_ips) | Private IPs of the Share FS instance. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
