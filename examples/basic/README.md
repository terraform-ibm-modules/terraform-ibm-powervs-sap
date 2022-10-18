# Basic PowerVS SAP system Module Example

This example illustrates how to use the `power-sap` module.
It provisions the following infrastructure:
- Creates a [PowerVS infrastructure ](https://github.com/terraform-ibm-modules/terraform-ibm-powervs-infrastructure) calling basic example of this module <br/>
- Creates and configures one PowerVS instance for SAP HANA based on best practises
- Creates and configures one PowerVS instances for SAP NetWeaver based on best practises
- Creates and configures one PowerVS instance that can be used for sharing SAP files between other system instances.

:warning: For experimentation purposes only.
For ease of use, this quick start example generates a private/public ssh key pair. The private key generated in this example will be stored unencrypted in your Terraform state file.
Use of this resource for production deployments is not recommended. Instead, generate a ssh key pair outside of Terraform and pass the public key via the [ssh_public_key input](https://github.com/terraform-ibm-modules/terraform-ibm-powervs-infrastructure/tree/v0.1#input_ssh_public_key)

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >=1.1 |
| <a name="requirement_ibm"></a> [ibm](#requirement\_ibm) | =1.45.1 |
| <a name="requirement_tls"></a> [tls](#requirement\_tls) | 4.0.1 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_power_infrastructure"></a> [power\_infrastructure](#module\_power\_infrastructure) | git::https://github.com/terraform-ibm-modules/terraform-ibm-powervs-infrastructure.git | v5.0.0 |
| <a name="module_resource_group"></a> [resource\_group](#module\_resource\_group) | git::https://github.com/terraform-ibm-modules/terraform-ibm-resource-group.git | v1.0.1 |
| <a name="module_sap_systems"></a> [sap\_systems](#module\_sap\_systems) | ../../ | n/a |

## Resources

| Name | Type |
|------|------|
| [ibm_is_ssh_key.ssh_key](https://registry.terraform.io/providers/IBM-Cloud/ibm/1.45.1/docs/resources/is_ssh_key) | resource |
| [tls_private_key.tls_key](https://registry.terraform.io/providers/hashicorp/tls/4.0.1/docs/resources/private_key) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_access_host_or_ip"></a> [access\_host\_or\_ip](#input\_access\_host\_or\_ip) | The public IP address for the jump or Bastion server. The address is used to reach the target or server\_host IP address and to configure the DNS, NTP, NFS, and Squid proxy services. | `string` | `null` | no |
| <a name="input_cloud_connection_count"></a> [cloud\_connection\_count](#input\_cloud\_connection\_count) | Required number of Cloud connections to create or reuse. The maximum number of connections is two per location. | `number` | `0` | no |
| <a name="input_cloud_connection_gr"></a> [cloud\_connection\_gr](#input\_cloud\_connection\_gr) | Enable global routing for this cloud connection. Can be specified when creating new connection | `bool` | `true` | no |
| <a name="input_cloud_connection_metered"></a> [cloud\_connection\_metered](#input\_cloud\_connection\_metered) | Enable metered for this cloud connection. Can be specified when creating new connection | `bool` | `false` | no |
| <a name="input_cloud_connection_speed"></a> [cloud\_connection\_speed](#input\_cloud\_connection\_speed) | Speed in megabits per second. Supported values are 50, 100, 200, 500, 1000, 2000, 5000, 10000. Required when you create a connection. | `number` | `5000` | no |
| <a name="input_configure_os"></a> [configure\_os](#input\_configure\_os) | Specify if OS on PowerVS instances should be configure for SAP or if only PowerVS instances should be created. | `bool` | `false` | no |
| <a name="input_create_separate_fs_share"></a> [create\_separate\_fs\_share](#input\_create\_separate\_fs\_share) | Deploy separate IBM PowerVS instance as central file system share. Instance can be configured in optional parameters (cpus, memory size, etc.). Otherwise, defaults will be used. | `bool` | `false` | no |
| <a name="input_dns_forwarder_config"></a> [dns\_forwarder\_config](#input\_dns\_forwarder\_config) | Configuration for the DNS forwarder to a DNS service that is not reachable directly from PowerVS | <pre>object({<br>    dns_enable        = bool<br>    server_host_or_ip = string<br>    dns_servers       = string<br>  })</pre> | <pre>{<br>  "dns_enable": "false",<br>  "dns_servers": "161.26.0.7; 161.26.0.8; 9.9.9.9;",<br>  "server_host_or_ip": ""<br>}</pre> | no |
| <a name="input_ibmcloud_api_key"></a> [ibmcloud\_api\_key](#input\_ibmcloud\_api\_key) | IBM Cloud Api Key | `string` | n/a | yes |
| <a name="input_nfs_client_directory"></a> [nfs\_client\_directory](#input\_nfs\_client\_directory) | NFS directory on PowerVS instances. Will be used only if nfs\_server is setup in 'Power infrastructure for regulated industries' | `string` | `"/nfs"` | no |
| <a name="input_nfs_config"></a> [nfs\_config](#input\_nfs\_config) | Configuration for the shared NFS file system (for example, for the installation media). | <pre>object({<br>    nfs_enable        = bool<br>    server_host_or_ip = string<br>    nfs_directory     = string<br>  })</pre> | <pre>{<br>  "nfs_directory": "/nfs",<br>  "nfs_enable": "false",<br>  "server_host_or_ip": ""<br>}</pre> | no |
| <a name="input_ntp_forwarder_config"></a> [ntp\_forwarder\_config](#input\_ntp\_forwarder\_config) | Configuration for the NTP forwarder to an NTP service that is not reachable directly from PowerVS | <pre>object({<br>    ntp_enable        = bool<br>    server_host_or_ip = string<br>  })</pre> | <pre>{<br>  "ntp_enable": "false",<br>  "server_host_or_ip": ""<br>}</pre> | no |
| <a name="input_os_image_distro"></a> [os\_image\_distro](#input\_os\_image\_distro) | Image distribution to use. Supported values are 'SLES' or 'RHEL'. OS release versions may be specified in optional parameters. | `string` | `"SLES"` | no |
| <a name="input_perform_proxy_client_setup"></a> [perform\_proxy\_client\_setup](#input\_perform\_proxy\_client\_setup) | Proxy configuration to allow internet access for a VM or LPAR. | <pre>object(<br>    {<br>      squid_client_ips = list(string)<br>      squid_server_ip  = string<br>      no_proxy_env     = string<br>    }<br>  )</pre> | `null` | no |
| <a name="input_powervs_backup_network"></a> [powervs\_backup\_network](#input\_powervs\_backup\_network) | Name of the IBM Cloud PowerVS backup network and CIDR to create | <pre>object({<br>    name = string<br>    cidr = string<br>  })</pre> | <pre>{<br>  "cidr": "10.52.0.0/24",<br>  "name": "bkp_net"<br>}</pre> | no |
| <a name="input_powervs_management_network"></a> [powervs\_management\_network](#input\_powervs\_management\_network) | Name of the IBM Cloud PowerVS management subnet and CIDR to create | <pre>object({<br>    name = string<br>    cidr = string<br>  })</pre> | <pre>{<br>  "cidr": "10.51.0.0/24",<br>  "name": "mgmt_net"<br>}</pre> | no |
| <a name="input_powervs_sap_network_cidr"></a> [powervs\_sap\_network\_cidr](#input\_powervs\_sap\_network\_cidr) | Network range for separate SAP network. E.g., '10.111.1.0/24' | `string` | `"10.111.1.0/24"` | no |
| <a name="input_powervs_sshkey_name"></a> [powervs\_sshkey\_name](#input\_powervs\_sshkey\_name) | Name of the PowerVS SSH key to create | `string` | `"ssh-key-pvs"` | no |
| <a name="input_powervs_workspace_name"></a> [powervs\_workspace\_name](#input\_powervs\_workspace\_name) | Name of the PowerVS Workspace to create | `string` | `"power-workspace"` | no |
| <a name="input_powervs_zone"></a> [powervs\_zone](#input\_powervs\_zone) | IBM Cloud data center location where IBM PowerVS infrastructure will be created. Following locations are currently supported: syd04, syd05, eu-de-1, eu-de-2, tok04, osa21, sao01 | `string` | `"syd04"` | no |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | Prefix for resources which will be created. | `string` | `"pvs"` | no |
| <a name="input_resource_group"></a> [resource\_group](#input\_resource\_group) | Existing IBM Cloud resource group name. If null, a new resource group will be created. | `string` | `null` | no |
| <a name="input_resource_tags"></a> [resource\_tags](#input\_resource\_tags) | Optional list of tags to be added to created resources | `list(string)` | `[]` | no |
| <a name="input_reuse_cloud_connections"></a> [reuse\_cloud\_connections](#input\_reuse\_cloud\_connections) | When true, IBM Cloud connections are reused (if attached to the transit gateway). | `bool` | `true` | no |
| <a name="input_sap_domain"></a> [sap\_domain](#input\_sap\_domain) | SAP domain to be set for entire landscape. Set to null or empty if not configuring OS. | `string` | `null` | no |
| <a name="input_sap_hana_additional_storage_config"></a> [sap\_hana\_additional\_storage\_config](#input\_sap\_hana\_additional\_storage\_config) | Additional File systems to be created and attached to PowerVS instance for SAP HANA. 'disk\_sizes' are in GB. 'count' specify over how many storage volumes the file system will be striped. 'tiers' specifies the storage tier in PowerVS workspace. For creating multiple file systems, specify multiple entries in each parameter in the structure. E.g., for creating 2 file systems, specify 2 names, 2 disk sizes, 2 counts, 2 tiers and 2 paths. | <pre>object({<br>    names      = string<br>    disks_size = string<br>    counts     = string<br>    tiers      = string<br>    paths      = string<br>  })</pre> | <pre>{<br>  "counts": "1",<br>  "disks_size": "50",<br>  "names": "usrsap",<br>  "paths": "/usr/sap",<br>  "tiers": "tier3"<br>}</pre> | no |
| <a name="input_sap_hana_custom_storage_config"></a> [sap\_hana\_custom\_storage\_config](#input\_sap\_hana\_custom\_storage\_config) | Custom File systems to be created and attached to PowerVS instance for SAP HANA. 'disk\_sizes' are in GB. 'count' specify over how many storage volumes the file system will be striped. 'tiers' specifies the storage tier in PowerVS workspace. For creating multiple file systems, specify multiple entries in each parameter in the structure. E.g., for creating 2 file systems, specify 2 names, 2 disk sizes, 2 counts, 2 tiers and 2 paths. | <pre>object({<br>    names      = string<br>    disks_size = string<br>    counts     = string<br>    tiers      = string<br>    paths      = string<br>  })</pre> | <pre>{<br>  "counts": "",<br>  "disks_size": "",<br>  "names": "",<br>  "paths": "",<br>  "tiers": ""<br>}</pre> | no |
| <a name="input_sap_hana_instance_config"></a> [sap\_hana\_instance\_config](#input\_sap\_hana\_instance\_config) | SAP HANA PowerVS instance configuration. | <pre>object({<br>    hostname       = string<br>    sap_profile_id = string<br>    os_image_name  = string<br>  })</pre> | <pre>{<br>  "hostname": "hana",<br>  "os_image_name": "SLES15-SP3-SAP",<br>  "sap_profile_id": "cnp-2x32"<br>}</pre> | no |
| <a name="input_sap_netweaver_instance_config"></a> [sap\_netweaver\_instance\_config](#input\_sap\_netweaver\_instance\_config) | SAP NetWeaver PowerVS instance configuration. | <pre>object({<br>    number_of_instances  = string<br>    hostname             = string<br>    os_image_name        = string<br>    cpu_proc_type        = string<br>    number_of_processors = string<br>    memory_size          = string<br>    server_type          = string<br>  })</pre> | <pre>{<br>  "cpu_proc_type": "shared",<br>  "hostname": "nw",<br>  "memory_size": "2",<br>  "number_of_instances": "1",<br>  "number_of_processors": "0.5",<br>  "os_image_name": "SLES15-SP3-SAP-NETWEAVER",<br>  "server_type": "s922"<br>}</pre> | no |
| <a name="input_sap_netweaver_storage_config"></a> [sap\_netweaver\_storage\_config](#input\_sap\_netweaver\_storage\_config) | File systems to be created and attached to PowerVS instance for SAP NetWeaver. 'disk\_sizes' are in GB. 'count' specify over how many sotrage volumes the file system will be striped. 'tiers' specifies the storage tier in PowerVS workspace. For creating multiple file systems, specify multiple entries in each parameter in the structure. E.g., for creating 2 file systems, specify 2 names, 2 disk sizes, 2 counts, 2 tiers and 2 paths. | <pre>object({<br>    names      = string<br>    disks_size = string<br>    counts     = string<br>    tiers      = string<br>    paths      = string<br>  })</pre> | <pre>{<br>  "counts": "1,1",<br>  "disks_size": "10,10",<br>  "names": "usrsap,usrtrans",<br>  "paths": "/usr/sap,/usr/sap/trans",<br>  "tiers": "tier3,tier3"<br>}</pre> | no |
| <a name="input_sap_share_instance_config"></a> [sap\_share\_instance\_config](#input\_sap\_share\_instance\_config) | SAP shared file system PowerVS instance configuration. | <pre>object({<br>    hostname             = string<br>    os_image_name        = string<br>    cpu_proc_type        = string<br>    number_of_processors = string<br>    memory_size          = string<br>    server_type          = string<br>  })</pre> | <pre>{<br>  "cpu_proc_type": "shared",<br>  "hostname": "share-fs",<br>  "memory_size": "2",<br>  "number_of_processors": "0.5",<br>  "os_image_name": "SLES15-SP3-SAP-NETWEAVER",<br>  "server_type": "s922"<br>}</pre> | no |
| <a name="input_sap_share_storage_config"></a> [sap\_share\_storage\_config](#input\_sap\_share\_storage\_config) | File systems to be created and attached to PowerVS instance for shared file systems. 'disk\_sizes' are in GB. 'count' specify over how many sotrage volumes the file system will be striped. 'tiers' specifies the storage tier in PowerVS workspace. For creating multiple file systems, specify multiple entries in each parameter in the structure. E.g., for creating 2 file systems, specify 2 names, 2 disk sizes, 2 counts, 2 tiers and 2 paths. | <pre>object({<br>    names      = string<br>    disks_size = string<br>    counts     = string<br>    tiers      = string<br>    paths      = string<br>  })</pre> | <pre>{<br>  "counts": "1",<br>  "disks_size": "10",<br>  "names": "share",<br>  "paths": "/share",<br>  "tiers": "tier3"<br>}</pre> | no |
| <a name="input_squid_config"></a> [squid\_config](#input\_squid\_config) | Configuration for the Squid proxy setup | <pre>object({<br>    squid_enable      = bool<br>    server_host_or_ip = string<br>  })</pre> | <pre>{<br>  "server_host_or_ip": "",<br>  "squid_enable": "false"<br>}</pre> | no |
| <a name="input_transit_gateway_name"></a> [transit\_gateway\_name](#input\_transit\_gateway\_name) | Name of the existing transit gateway. Required when you create new IBM Cloud connections. | `string` | `null` | no |

## Outputs

No outputs.
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
