# Power Virtual Server for SAP SYSTEM MODULE
The Power Virtual Server for SAP module automates the following tasks:

- Creates and configures one PowerVS instance for SAP HANA that is based on best practices.
- Creates and configures multiple PowerVS instances for SAP NetWeaver that are based on best practices.
- Creates and configures one optional PowerVS instance that can be used for sharing SAP files between other system instances.
- Connects all created PowerVS instances to a proxy server that is specified by IP address or hostname.
- Optionally connects all created PowerVS instances to an NTP server and DNS forwarder that are specified by IP address or hostname.
- Optionally configures a shared NFS directory on all created PowerVS instances.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
### Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3 |
| <a name="requirement_ibm"></a> [ibm](#requirement\_ibm) | >= 1.49.0 |
| <a name="requirement_null"></a> [null](#requirement\_null) | >= 3.2.1 |

### Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_powervs_attach_sap_network"></a> [powervs\_attach\_sap\_network](#module\_powervs\_attach\_sap\_network) | ../../../modules/powervs_attach_private_network | n/a |
| <a name="module_powervs_create_sap_network"></a> [powervs\_create\_sap\_network](#module\_powervs\_create\_sap\_network) | ../../../modules/powervs_create_private_network | n/a |
| <a name="module_powervs_hana_instance"></a> [powervs\_hana\_instance](#module\_powervs\_hana\_instance) | git::https://github.com/terraform-ibm-modules/terraform-ibm-powervs-instance.git | v0.3.0 |
| <a name="module_powervs_hana_storage_calculation"></a> [powervs\_hana\_storage\_calculation](#module\_powervs\_hana\_storage\_calculation) | ../../../modules/powervs_hana_storage_config | n/a |
| <a name="module_powervs_netweaver_instance"></a> [powervs\_netweaver\_instance](#module\_powervs\_netweaver\_instance) | git::https://github.com/terraform-ibm-modules/terraform-ibm-powervs-instance.git | v0.3.0 |
| <a name="module_powervs_sharefs_instance"></a> [powervs\_sharefs\_instance](#module\_powervs\_sharefs\_instance) | git::https://github.com/terraform-ibm-modules/terraform-ibm-powervs-instance.git | v0.3.0 |
| <a name="module_sap_instance_init"></a> [sap\_instance\_init](#module\_sap\_instance\_init) | ../../../modules/sap_instance_init | n/a |

### Resources

No resources.

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_access_host_or_ip"></a> [access\_host\_or\_ip](#input\_access\_host\_or\_ip) | The public IP address or hostname for the access host. The address is used to reach the target or server\_host IP address and to configure the DNS, NTP, NFS, and Squid proxy services. Set to null or empty if not configuring OS. | `string` | n/a | yes |
| <a name="input_additional_networks"></a> [additional\_networks](#input\_additional\_networks) | Existing list of subnets name to be attached to PowerVS instances. First network has to be a management network. | `list(string)` | <pre>[<br>  "mgmt_net",<br>  "bkp_net"<br>]</pre> | no |
| <a name="input_cloud_connection_count"></a> [cloud\_connection\_count](#input\_cloud\_connection\_count) | Existing number of Cloud connections to which new subnet must be attached. | `string` | `2` | no |
| <a name="input_dns_host_or_ip"></a> [dns\_host\_or\_ip](#input\_dns\_host\_or\_ip) | Private IP address of DNS server, resolver or forwarder. Set empty if not configuring OS. | `string` | n/a | yes |
| <a name="input_nfs_host_or_ip_path"></a> [nfs\_host\_or\_ip\_path](#input\_nfs\_host\_or\_ip\_path) | Full path on NFS server (in form <hostname\_or\_ip>:<directory>, e.g., '10.20.10.4:/nfs'). Set to empty if not configuring OS. | `string` | n/a | yes |
| <a name="input_ntp_host_or_ip"></a> [ntp\_host\_or\_ip](#input\_ntp\_host\_or\_ip) | Private IP address of NTP time server or forwarder. Set empty if not configuring OS. | `string` | n/a | yes |
| <a name="input_os_image_distro"></a> [os\_image\_distro](#input\_os\_image\_distro) | Image distribution to use for all instances(Shared, HANA, Netweaver). OS release versions may be specified in 'var.powervs\_default\_images' optional parameters below. | `string` | `"RHEL"` | no |
| <a name="input_powervs_create_separate_fs_share"></a> [powervs\_create\_separate\_fs\_share](#input\_powervs\_create\_separate\_fs\_share) | Deploy separate IBM PowerVS instance as central file system share. Instance can be configured in optional parameters (cpus, memory size, etc.). Otherwise, defaults will be used. | `bool` | n/a | yes |
| <a name="input_powervs_default_images"></a> [powervs\_default\_images](#input\_powervs\_default\_images) | Default SuSE and Red Hat Linux images to use for SAP HANA and SAP NetWeaver PowerVS instances. | <pre>object({<br>    sles_hana_image = string<br>    sles_nw_image   = string<br>    rhel_hana_image = string<br>    rhel_nw_image   = string<br>  })</pre> | <pre>{<br>  "rhel_hana_image": "RHEL8-SP4-SAP",<br>  "rhel_nw_image": "RHEL8-SP4-SAP-NETWEAVER",<br>  "sles_hana_image": "SLES15-SP3-SAP",<br>  "sles_nw_image": "SLES15-SP3-SAP-NETWEAVER"<br>}</pre> | no |
| <a name="input_powervs_hana_additional_storage_config"></a> [powervs\_hana\_additional\_storage\_config](#input\_powervs\_hana\_additional\_storage\_config) | Additional File systems to be created and attached to PowerVS instance for SAP HANA. 'size' is in GB. 'count' specify over how many storage volumes the file system will be striped. 'tier' specifies the storage tier in PowerVS workspace. 'mount' specifies the target mount point on OS. | <pre>list(object({<br>    name  = string<br>    size  = string<br>    count = string<br>    tier  = string<br>    mount = string<br>  }))</pre> | <pre>[<br>  {<br>    "count": "1",<br>    "mount": "/usr/sap",<br>    "name": "usrsap",<br>    "size": "50",<br>    "tier": "tier3"<br>  }<br>]</pre> | no |
| <a name="input_powervs_hana_custom_storage_config"></a> [powervs\_hana\_custom\_storage\_config](#input\_powervs\_hana\_custom\_storage\_config) | Custom File systems to be created and attached to PowerVS instance for SAP HANA. 'size' is in GB. 'count' specify over how many storage volumes the file system will be striped. 'tier' specifies the storage tier in PowerVS workspace. 'mount' specifies the target mount point on OS. | <pre>list(object({<br>    name  = string<br>    size  = string<br>    count = string<br>    tier  = string<br>    mount = string<br>  }))</pre> | <pre>[<br>  {<br>    "count": "",<br>    "mount": "",<br>    "name": "",<br>    "size": "",<br>    "tier": ""<br>  }<br>]</pre> | no |
| <a name="input_powervs_hana_instance_name"></a> [powervs\_hana\_instance\_name](#input\_powervs\_hana\_instance\_name) | SAP HANA hostname (non FQDN). Will get the form of <var.prefix>-<var.powervs\_hana\_instance\_name>. Max length of final hostname must be <= 13 characters. | `string` | `"hana"` | no |
| <a name="input_powervs_hana_sap_profile_id"></a> [powervs\_hana\_sap\_profile\_id](#input\_powervs\_hana\_sap\_profile\_id) | SAP HANA profile to use. Must be one of the supported profiles. See [here](https://cloud.ibm.com/docs/sap?topic=sap-hana-iaas-offerings-profiles-power-vs). File system sizes are automatically calculated. Override automatic calculation by setting values in optional sap\_hana\_custom\_storage\_config parameter. | `string` | `"ush1-4x256"` | no |
| <a name="input_powervs_netweaver_cpu_number"></a> [powervs\_netweaver\_cpu\_number](#input\_powervs\_netweaver\_cpu\_number) | Number of CPUs for each SAP NetWeaver instance. | `string` | `"3"` | no |
| <a name="input_powervs_netweaver_instance_count"></a> [powervs\_netweaver\_instance\_count](#input\_powervs\_netweaver\_instance\_count) | Number of SAP NetWeaver instances that should be created. | `number` | `1` | no |
| <a name="input_powervs_netweaver_instance_name"></a> [powervs\_netweaver\_instance\_name](#input\_powervs\_netweaver\_instance\_name) | SAP Netweaver hostname (non FQDN). Will get the form of <var.prefix>-<var.powervs\_netweaver\_instance\_name>-<number>. Max length of final hostname must be <= 13 characters. | `string` | `"nw"` | no |
| <a name="input_powervs_netweaver_memory_size"></a> [powervs\_netweaver\_memory\_size](#input\_powervs\_netweaver\_memory\_size) | Memory size for each SAP NetWeaver instance. | `string` | `"32"` | no |
| <a name="input_powervs_netweaver_storage_config"></a> [powervs\_netweaver\_storage\_config](#input\_powervs\_netweaver\_storage\_config) | File systems to be created and attached to PowerVS instance for SAP NetWeaver. 'size' is in GB. 'count' specify over how many storage volumes the file system will be striped. 'tier' specifies the storage tier in PowerVS workspace. 'mount' specifies the target mount point on OS. | <pre>list(object({<br>    name  = string<br>    size  = string<br>    count = string<br>    tier  = string<br>    mount = string<br>  }))</pre> | <pre>[<br>  {<br>    "count": "1",<br>    "mount": "/usr/sap",<br>    "name": "usrsap",<br>    "size": "50",<br>    "tier": "tier3"<br>  },<br>  {<br>    "count": "1",<br>    "mount": "/usr/sap/trans",<br>    "name": "usrtrans",<br>    "size": "50",<br>    "tier": "tier3"<br>  }<br>]</pre> | no |
| <a name="input_powervs_resource_group_name"></a> [powervs\_resource\_group\_name](#input\_powervs\_resource\_group\_name) | Existing IBM Cloud resource group name. | `string` | n/a | yes |
| <a name="input_powervs_sap_network_cidr"></a> [powervs\_sap\_network\_cidr](#input\_powervs\_sap\_network\_cidr) | Network range for separate SAP network. E.g., '10.53.1.0/24' | `string` | `"10.53.1.0/24"` | no |
| <a name="input_powervs_share_storage_config"></a> [powervs\_share\_storage\_config](#input\_powervs\_share\_storage\_config) | File systems to be created and attached to PowerVS instance for shared storage file systems. 'size' is in GB. 'count' specify over how many storage volumes the file system will be striped. 'tier' specifies the storage tier in PowerVS workspace. 'mount' specifies the target mount point on OS. | <pre>list(object({<br>    name  = string<br>    size  = string<br>    count = string<br>    tier  = string<br>    mount = string<br>  }))</pre> | <pre>[<br>  {<br>    "count": "1",<br>    "mount": "/share",<br>    "name": "share",<br>    "size": "1000",<br>    "tier": "tier3"<br>  }<br>]</pre> | no |
| <a name="input_powervs_sshkey_name"></a> [powervs\_sshkey\_name](#input\_powervs\_sshkey\_name) | Existing PowerVS SSH Key Name. | `string` | n/a | yes |
| <a name="input_powervs_workspace_name"></a> [powervs\_workspace\_name](#input\_powervs\_workspace\_name) | Existing Name of PowerVS workspace. | `string` | n/a | yes |
| <a name="input_powervs_zone"></a> [powervs\_zone](#input\_powervs\_zone) | IBM Cloud data center location where IBM PowerVS Workspace exists. | `string` | n/a | yes |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | Unique prefix for resources to be created (e.g., SAP system name). Max length must be less than or equal to 6. | `string` | n/a | yes |
| <a name="input_proxy_host_or_ip_port"></a> [proxy\_host\_or\_ip\_port](#input\_proxy\_host\_or\_ip\_port) | Proxy hostname or IP address with port. E.g., 10.10.10.4:3128 <ip:port>. | `string` | n/a | yes |
| <a name="input_sap_domain"></a> [sap\_domain](#input\_sap\_domain) | SAP domain to be set for entire landscape. Set to null or empty if not configuring OS. | `string` | `"sap.com"` | no |
| <a name="input_ssh_private_key"></a> [ssh\_private\_key](#input\_ssh\_private\_key) | Private SSH key (RSA format) used to login to IBM PowerVS instances. Should match to uploaded public SSH key referenced by 'ssh\_public\_key' which was created previously. Entered data must be in [heredoc strings format](https://www.terraform.io/language/expressions/strings#heredoc-strings). The key is not uploaded or stored. For more information about SSH keys, see [SSH keys](https://cloud.ibm.com/docs/vpc?topic=vpc-ssh-keys). | `string` | n/a | yes |

### Outputs

| Name | Description |
|------|-------------|
| <a name="output_access_host_or_ip"></a> [access\_host\_or\_ip](#output\_access\_host\_or\_ip) | Public IP of Provided Bastion/JumpServer Host |
| <a name="output_powervs_hana_instance_ips"></a> [powervs\_hana\_instance\_ips](#output\_powervs\_hana\_instance\_ips) | All private IPS of HANA instance |
| <a name="output_powervs_hana_instance_management_ip"></a> [powervs\_hana\_instance\_management\_ip](#output\_powervs\_hana\_instance\_management\_ip) | Management IP of HANA Instance |
| <a name="output_powervs_lpars_data"></a> [powervs\_lpars\_data](#output\_powervs\_lpars\_data) | All private IPS of PowerVS instances and Jump IP to access the host. |
| <a name="output_powervs_netweaver_instance_ips"></a> [powervs\_netweaver\_instance\_ips](#output\_powervs\_netweaver\_instance\_ips) | All private IPS of NetWeaver instances |
| <a name="output_powervs_netweaver_instance_management_ips"></a> [powervs\_netweaver\_instance\_management\_ips](#output\_powervs\_netweaver\_instance\_management\_ips) | Management IPS of NetWeaver instances |
| <a name="output_powervs_share_fs_ips"></a> [powervs\_share\_fs\_ips](#output\_powervs\_share\_fs\_ips) | Private IPs of the Share FS instance. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
