# PowerVS SAP system example to create SAP prepared PowerVS instances

The PowerVS SAP system example automates the following tasks:

- Creates and configures one PowerVS instance for SAP HANA that is based on best practices.
- Creates and configures multiple PowerVS instances for SAP NetWeaver that are based on best practices.
- Creates and configures one optional PowerVS instance that can be used for sharing SAP files between other system instances.
- Connects all created PowerVS instances to a proxy server that is specified by IP address or hostname.
- Optionally connects all created PowerVS instances to an NTP server nd DNS forwarder that are specified by IP address or hostname.
- Optionally configures a shared NFS directory on all created PowerVS instances. The directory is provided by an NFS server that is specified by IP address or hostname.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >=1.1 |
| <a name="requirement_ibm"></a> [ibm](#requirement\_ibm) | =1.49.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_sap_systems"></a> [sap\_systems](#module\_sap\_systems) | ../../ | n/a |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_access_host_or_ip"></a> [access\_host\_or\_ip](#input\_access\_host\_or\_ip) | The public IP address or hostname for the access host. The address is used to reach the target or server\_host IP address and to configure the DNS, NTP, NFS, and Squid proxy services. Set to null or empty if not configuring OS. | `string` | n/a | yes |
| <a name="input_additional_networks"></a> [additional\_networks](#input\_additional\_networks) | Existing list of subnets name to be attached to PowerVS instances. First network has to be a management network. | `list(string)` | <pre>[<br>  "mgmt_net",<br>  "bkp_net"<br>]</pre> | no |
| <a name="input_cloud_connection_count"></a> [cloud\_connection\_count](#input\_cloud\_connection\_count) | Existing number of Cloud connections to which new subnet must be attached. | `string` | `2` | no |
| <a name="input_configure_os"></a> [configure\_os](#input\_configure\_os) | Specify if OS on PowerVS instances should be configured for SAP or if only PowerVS instances should be created. If configure\_os is true then value has to be set for access\_host\_ip, ssh\_private\_key and proxy\_host\_or\_ip\_port to continue | `bool` | n/a | yes |
| <a name="input_create_separate_fs_share"></a> [create\_separate\_fs\_share](#input\_create\_separate\_fs\_share) | Deploy separate IBM PowerVS instance as central file system share. Instance can be configured in optional parameters (cpus, memory size, etc.). Otherwise, defaults will be used. | `bool` | n/a | yes |
| <a name="input_default_hana_rhel_image"></a> [default\_hana\_rhel\_image](#input\_default\_hana\_rhel\_image) | Default Red Hat Linux image to use for SAP HANA PowerVS instances. | `string` | `"RHEL8-SP4-SAP"` | no |
| <a name="input_default_hana_sles_image"></a> [default\_hana\_sles\_image](#input\_default\_hana\_sles\_image) | Default SuSE Linux image to use for SAP HANA PowerVS instances. | `string` | `"SLES15-SP3-SAP"` | no |
| <a name="input_default_netweaver_rhel_image"></a> [default\_netweaver\_rhel\_image](#input\_default\_netweaver\_rhel\_image) | Default Red Hat Linux image to use for SAP NetWeaver PowerVS instances. | `string` | `"RHEL8-SP4-SAP-NETWEAVER"` | no |
| <a name="input_default_netweaver_sles_image"></a> [default\_netweaver\_sles\_image](#input\_default\_netweaver\_sles\_image) | Default SuSE Linux image to use for SAP NetWeaver PowerVS instances. | `string` | `"SLES15-SP3-SAP-NETWEAVER"` | no |
| <a name="input_default_shared_fs_rhel_image"></a> [default\_shared\_fs\_rhel\_image](#input\_default\_shared\_fs\_rhel\_image) | Default Red Hat Linux image to use for SAP shared FS PowerVS instances. | `string` | `"RHEL8-SP4-SAP-NETWEAVER"` | no |
| <a name="input_default_shared_fs_sles_image"></a> [default\_shared\_fs\_sles\_image](#input\_default\_shared\_fs\_sles\_image) | Default SuSE Linux image to use for SAP shared FS PowerVS instances | `string` | `"SLES15-SP3-SAP-NETWEAVER"` | no |
| <a name="input_dns_host_or_ip"></a> [dns\_host\_or\_ip](#input\_dns\_host\_or\_ip) | Private IP address of DNS server, resolver or forwarder. Set to null or empty if not configuring OS. | `string` | n/a | yes |
| <a name="input_ibmcloud_api_key"></a> [ibmcloud\_api\_key](#input\_ibmcloud\_api\_key) | IBM Cloud Api Key | `string` | n/a | yes |
| <a name="input_nfs_client_directory"></a> [nfs\_client\_directory](#input\_nfs\_client\_directory) | NFS directory on PowerVS instances. Will be used only if nfs\_server is setup in 'Power infrastructure for regulated industries'. Set to null or empty if not configuring OS. | `string` | n/a | yes |
| <a name="input_nfs_path"></a> [nfs\_path](#input\_nfs\_path) | Full path on NFS server (in form <hostname\_or\_ip>:<directory>, e.g., '10.20.10.4:/nfs'). Set to null or empty if not configuring OS. | `string` | n/a | yes |
| <a name="input_ntp_host_or_ip"></a> [ntp\_host\_or\_ip](#input\_ntp\_host\_or\_ip) | Private IP address of NTP time server or forwarder. Set to null or empty if not configuring OS. | `string` | n/a | yes |
| <a name="input_os_image_distro"></a> [os\_image\_distro](#input\_os\_image\_distro) | Image distribution to use for all instances(Shared, HANA, Netweaver). Supported values are 'SLES' or 'RHEL'. OS release versions may be specified in optional parameters. | `string` | n/a | yes |
| <a name="input_powervs_resource_group_name"></a> [powervs\_resource\_group\_name](#input\_powervs\_resource\_group\_name) | Existing IBM Cloud resource group name. | `string` | n/a | yes |
| <a name="input_powervs_sap_network_cidr"></a> [powervs\_sap\_network\_cidr](#input\_powervs\_sap\_network\_cidr) | Network range for separate SAP network. E.g., '10.111.1.0/24' | `string` | `"10.111.1.0/24"` | no |
| <a name="input_powervs_sshkey_name"></a> [powervs\_sshkey\_name](#input\_powervs\_sshkey\_name) | Exisiting PowerVS SSH Key Name. | `string` | n/a | yes |
| <a name="input_powervs_workspace_name"></a> [powervs\_workspace\_name](#input\_powervs\_workspace\_name) | Existing Name of PowerVS workspace. | `string` | n/a | yes |
| <a name="input_powervs_zone"></a> [powervs\_zone](#input\_powervs\_zone) | IBM Cloud data center location where IBM PowerVS infrastructure will be created. Following locations are currently supported: syd04, syd05, eu-de-1, eu-de-2, tok04, osa21, sao01, lon04, lon06. | `string` | n/a | yes |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | Prefix for resources which will be created. Max length must be less than or equal to 6. | `string` | n/a | yes |
| <a name="input_proxy_host_or_ip_port"></a> [proxy\_host\_or\_ip\_port](#input\_proxy\_host\_or\_ip\_port) | Proxy hosname or IP address with port. E.g., 10.10.10.4:3128 <ip:port>. Set to null or empty if not configuring OS. | `string` | n/a | yes |
| <a name="input_sap_domain"></a> [sap\_domain](#input\_sap\_domain) | SAP domain to be set for entire landscape. Set to null or empty if not configuring OS. | `string` | n/a | yes |
| <a name="input_sap_hana_additional_storage_config"></a> [sap\_hana\_additional\_storage\_config](#input\_sap\_hana\_additional\_storage\_config) | Additional File systems to be created and attached to PowerVS instance for SAP HANA. 'disk\_sizes' are in GB. 'count' specify over how many storage volumes the file system will be striped. 'tiers' specifies the storage tier in PowerVS workspace. For creating multiple file systems, specify multiple entries in each parameter in the structure. E.g., for creating 2 file systems, specify 2 names, 2 disk sizes, 2 counts, 2 tiers and 2 paths. | <pre>object({<br>    names      = string<br>    disks_size = string<br>    counts     = string<br>    tiers      = string<br>    paths      = string<br>  })</pre> | <pre>{<br>  "counts": "1",<br>  "disks_size": "50",<br>  "names": "usrsap",<br>  "paths": "/usr/sap",<br>  "tiers": "tier3"<br>}</pre> | no |
| <a name="input_sap_hana_custom_storage_config"></a> [sap\_hana\_custom\_storage\_config](#input\_sap\_hana\_custom\_storage\_config) | Custom File systems to be created and attached to PowerVS instance for SAP HANA. 'disk\_sizes' are in GB. 'count' specify over how many storage volumes the file system will be striped. 'tiers' specifies the storage tier in PowerVS workspace. For creating multiple file systems, specify multiple entries in each parameter in the structure. E.g., for creating 2 file systems, specify 2 names, 2 disk sizes, 2 counts, 2 tiers and 2 paths. | <pre>object({<br>    names      = string<br>    disks_size = string<br>    counts     = string<br>    tiers      = string<br>    paths      = string<br>  })</pre> | <pre>{<br>  "counts": "",<br>  "disks_size": "",<br>  "names": "",<br>  "paths": "",<br>  "tiers": ""<br>}</pre> | no |
| <a name="input_sap_hana_hostname"></a> [sap\_hana\_hostname](#input\_sap\_hana\_hostname) | SAP HANA hostname (non FQDN). Will get the form of <prefix>-<sap\_hana\_hostname>. Max length of final hostname must be <= 13 characters. | `string` | `"hana"` | no |
| <a name="input_sap_hana_instance_config"></a> [sap\_hana\_instance\_config](#input\_sap\_hana\_instance\_config) | SAP HANA PowerVS instance configuration. If data is specified here - will replace other input. | <pre>object({<br>    os_image_name  = string<br>    sap_profile_id = string<br>  })</pre> | <pre>{<br>  "os_image_name": "",<br>  "sap_profile_id": ""<br>}</pre> | no |
| <a name="input_sap_hana_profile"></a> [sap\_hana\_profile](#input\_sap\_hana\_profile) | SAP HANA profile to use. Must be one of the supported profiles. See [here](https://cloud.ibm.com/docs/sap?topic=sap-hana-iaas-offerings-profiles-power-vs). File system sizes are automatically calculated. Override automatic calculation by setting values in optional sap\_hana\_custom\_storage\_config parameter. | `string` | `"cnp-2x64"` | no |
| <a name="input_sap_netweaver_cpu_number"></a> [sap\_netweaver\_cpu\_number](#input\_sap\_netweaver\_cpu\_number) | Number of CPUs for each SAP NetWeaver instance. | `string` | n/a | yes |
| <a name="input_sap_netweaver_hostname"></a> [sap\_netweaver\_hostname](#input\_sap\_netweaver\_hostname) | SAP Netweaver hostname (non FQDN). Will get the form of <prefix>-<sap\_netweaver\_hostname>-<number>. Max length of final hostname must be <= 13 characters. | `string` | `"nw"` | no |
| <a name="input_sap_netweaver_instance_config"></a> [sap\_netweaver\_instance\_config](#input\_sap\_netweaver\_instance\_config) | SAP NetWeaver PowerVS instance configuration. If data is specified here - will replace other input. | <pre>object({<br>    number_of_instances  = string<br>    os_image_name        = string<br>    number_of_processors = string<br>    memory_size          = string<br>    cpu_proc_type        = string<br>    server_type          = string<br>  })</pre> | <pre>{<br>  "cpu_proc_type": "shared",<br>  "memory_size": "",<br>  "number_of_instances": "",<br>  "number_of_processors": "",<br>  "os_image_name": "",<br>  "server_type": "s922"<br>}</pre> | no |
| <a name="input_sap_netweaver_instance_number"></a> [sap\_netweaver\_instance\_number](#input\_sap\_netweaver\_instance\_number) | Number of SAP NetWeaver instances that should be created. | `number` | `1` | no |
| <a name="input_sap_netweaver_memory_size"></a> [sap\_netweaver\_memory\_size](#input\_sap\_netweaver\_memory\_size) | Memory size for each SAP NetWeaver instance. | `string` | n/a | yes |
| <a name="input_sap_netweaver_storage_config"></a> [sap\_netweaver\_storage\_config](#input\_sap\_netweaver\_storage\_config) | File systems to be created and attached to PowerVS instance for SAP NetWeaver. 'disk\_sizes' are in GB. 'count' specify over how many sotrage volumes the file system will be striped. 'tiers' specifies the storage tier in PowerVS workspace. For creating multiple file systems, specify multiple entries in each parameter in the structure. E.g., for creating 2 file systems, specify 2 names, 2 disk sizes, 2 counts, 2 tiers and 2 paths. | <pre>object({<br>    names      = string<br>    disks_size = string<br>    counts     = string<br>    tiers      = string<br>    paths      = string<br>  })</pre> | <pre>{<br>  "counts": "1,1",<br>  "disks_size": "50,50",<br>  "names": "usrsap,usrtrans",<br>  "paths": "/usr/sap,/usr/sap/trans",<br>  "tiers": "tier3,tier3"<br>}</pre> | no |
| <a name="input_sap_share_instance_config"></a> [sap\_share\_instance\_config](#input\_sap\_share\_instance\_config) | SAP shared file system PowerVS instance configuration. If data is specified here - will replace other input. | <pre>object({<br>    os_image_name        = string<br>    number_of_processors = string<br>    memory_size          = string<br>    cpu_proc_type        = string<br>    server_type          = string<br>  })</pre> | <pre>{<br>  "cpu_proc_type": "shared",<br>  "memory_size": "4",<br>  "number_of_processors": "0.5",<br>  "os_image_name": "",<br>  "server_type": "s922"<br>}</pre> | no |
| <a name="input_sap_share_storage_config"></a> [sap\_share\_storage\_config](#input\_sap\_share\_storage\_config) | File systems to be created and attached to PowerVS instance for shared storage file systems. 'disk\_sizes' are in GB. 'count' specify over how many sotrage volumes the file system will be striped. 'tiers' specifies the storage tier in PowerVS workspace. For creating multiple file systems, specify multiple entries in each parameter in the structure. E.g., for creating 2 file systems, specify 2 names, 2 disk sizes, 2 counts, 2 tiers and 2 paths. | <pre>object({<br>    names      = string<br>    disks_size = string<br>    counts     = string<br>    tiers      = string<br>    paths      = string<br>  })</pre> | <pre>{<br>  "counts": "1",<br>  "disks_size": "1000",<br>  "names": "share",<br>  "paths": "/share",<br>  "tiers": "tier3"<br>}</pre> | no |
| <a name="input_ssh_private_key"></a> [ssh\_private\_key](#input\_ssh\_private\_key) | Private SSH key (RSA format) used to login to IBM PowerVS instances. Should match to uploaded public SSH key referenced by 'ssh\_public\_key'. Entered data must be in [heredoc strings format](https://www.terraform.io/language/expressions/strings#heredoc-strings). The key is not uploaded or stored. For more information about SSH keys, see [SSH keys](https://cloud.ibm.com/docs/vpc?topic=vpc-ssh-keys). | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_access_host_or_ip"></a> [access\_host\_or\_ip](#output\_access\_host\_or\_ip) | Public IP of Provided Bastion/JumpServer Host |
| <a name="output_hana_ips"></a> [hana\_ips](#output\_hana\_ips) | All private IPS of HANA instance |
| <a name="output_netweaver_ips"></a> [netweaver\_ips](#output\_netweaver\_ips) | All private IPS of NetWeaver instances |
| <a name="output_share_fs_ips"></a> [share\_fs\_ips](#output\_share\_fs\_ips) | Private IPs of the Share FS instance. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
