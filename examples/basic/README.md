# Basic PowerVS SAP system Module Example

This example illustrates how to use the `power-sap` module.
It provisions the following infrastructure:
- Creates a [PowerVS infrastrucutre ](https://github.com/terraform-ibm-modules/terraform-ibm-powervs-infrastructure) calling basic example of this module <br/>
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
| <a name="requirement_ibm"></a> [ibm](#requirement\_ibm) | >=1.43.0 |
| <a name="requirement_tls"></a> [tls](#requirement\_tls) | 4.0.1 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_powervs_infratructure"></a> [powervs\_infratructure](#module\_powervs\_infratructure) | git::https://github.com/terraform-ibm-modules/terraform-ibm-powervs-infrastructure.git | v1.6.0 |
| <a name="module_sap_systems"></a> [sap\_systems](#module\_sap\_systems) | ../../ | n/a |

## Resources

| Name | Type |
|------|------|
| [ibm_is_ssh_key.ssh_key](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/is_ssh_key) | resource |
| [tls_private_key.tls_key](https://registry.terraform.io/providers/hashicorp/tls/4.0.1/docs/resources/private_key) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cloud_connection_count"></a> [cloud\_connection\_count](#input\_cloud\_connection\_count) | Required number of Cloud connections which will be created/Reused. Maximum is 2 per location | `number` | `0` | no |
| <a name="input_cloud_connection_gr"></a> [cloud\_connection\_gr](#input\_cloud\_connection\_gr) | Enable global routing for this cloud connection. Can be specified when creating new connection | `bool` | `true` | no |
| <a name="input_cloud_connection_metered"></a> [cloud\_connection\_metered](#input\_cloud\_connection\_metered) | Enable metered for this cloud connection. Can be specified when creating new connection | `bool` | `false` | no |
| <a name="input_cloud_connection_speed"></a> [cloud\_connection\_speed](#input\_cloud\_connection\_speed) | Speed in megabits per sec. Supported values are 50, 100, 200, 500, 1000, 2000, 5000, 10000. Required when creating new connection | `number` | `5000` | no |
| <a name="input_configure_dns_forwarder"></a> [configure\_dns\_forwarder](#input\_configure\_dns\_forwarder) | DNS is required to configure DNS resolution over server that is not reachable directly from PowerVS VSIs. Do not configure DNS forwarder in this example by default. | `bool` | `false` | no |
| <a name="input_configure_nfs_server"></a> [configure\_nfs\_server](#input\_configure\_nfs\_server) | NFS server may be used to provide shared FS for PowerVS VSIs. Do not configure NFS server in this example by default. | `bool` | `false` | no |
| <a name="input_configure_ntp_forwarder"></a> [configure\_ntp\_forwarder](#input\_configure\_ntp\_forwarder) | NTP is required to sync time over time server not reachable directly from PowerVS VSIs. Do not configure NTP forwarder in this example by default. | `bool` | `false` | no |
| <a name="input_configure_proxy"></a> [configure\_proxy](#input\_configure\_proxy) | Proxy is required to establish connectivity from PowerVS VSIs to the public internet. Do not configure proxy in this example by default. | `bool` | `false` | no |
| <a name="input_dns_forwarder_config"></a> [dns\_forwarder\_config](#input\_dns\_forwarder\_config) | Configure DNS forwarder to existing DNS service that is not reachable directly from PowerVS. | <pre>object({<br>    dns_forwarder_host_or_ip = string<br>    dns_servers              = string<br>  })</pre> | <pre>{<br>  "dns_forwarder_host_or_ip": null,<br>  "dns_servers": "161.26.0.7; 161.26.0.8; 9.9.9.9;"<br>}</pre> | no |
| <a name="input_ibmcloud_api_key"></a> [ibmcloud\_api\_key](#input\_ibmcloud\_api\_key) | IBM Cloud Api Key | `string` | `null` | no |
| <a name="input_nfs_server_config"></a> [nfs\_server\_config](#input\_nfs\_server\_config) | Configure shared NFS file system (e.g., for installation media). | <pre>object({<br>    nfs_server_host_or_ip = string<br>    nfs_directory         = string<br>  })</pre> | <pre>{<br>  "nfs_directory": "/nfs",<br>  "nfs_server_host_or_ip": null<br>}</pre> | no |
| <a name="input_ntp_forwarder_config"></a> [ntp\_forwarder\_config](#input\_ntp\_forwarder\_config) | Configure NTP forwarder to existing NTP service that is not reachable directly from PowerVS. | <pre>object({<br>    ntp_forwarder_host_or_ip = string<br>  })</pre> | <pre>{<br>  "ntp_forwarder_host_or_ip": null<br>}</pre> | no |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | Prefix for resources which will be created. | `string` | `"pvs"` | no |
| <a name="input_pvs_backup_network"></a> [pvs\_backup\_network](#input\_pvs\_backup\_network) | IBM Cloud PowerVS Backup Network name and cidr which will be created. | <pre>object({<br>    name = string<br>    cidr = string<br>  })</pre> | <pre>{<br>  "cidr": "10.52.0.0/24",<br>  "name": "bkp_net"<br>}</pre> | no |
| <a name="input_pvs_management_network"></a> [pvs\_management\_network](#input\_pvs\_management\_network) | IBM Cloud PowerVS Management Subnet name and cidr which will be created. | <pre>object({<br>    name = string<br>    cidr = string<br>  })</pre> | <pre>{<br>  "cidr": "10.51.0.0/24",<br>  "name": "mgmt_net"<br>}</pre> | no |
| <a name="input_pvs_sap_hana_instance_config"></a> [pvs\_sap\_hana\_instance\_config](#input\_pvs\_sap\_hana\_instance\_config) | SAP HANA PowerVS instance configuration. If data is specified here - will replace other input. | <pre>object({<br>    name-suffix         = string<br>    ip                  = string<br>    sap_hana_profile_id = string<br>    sap_image_name      = string<br>  })</pre> | <pre>{<br>  "ip": "",<br>  "name-suffix": "hana",<br>  "sap_hana_profile_id": "cnp-2x32",<br>  "sap_image_name": "SLES15-SP3-SAP"<br>}</pre> | no |
| <a name="input_pvs_sap_hana_storage_config"></a> [pvs\_sap\_hana\_storage\_config](#input\_pvs\_sap\_hana\_storage\_config) | File systems to be created and attached to PowerVS instance for SAP HANA. 'disk\_sizes' are in GB. 'count' specify over how many sotrage volumes the file system will be striped. 'tiers' specifies the storage tier in PowerVS service. For creating multiple file systems, specify multiple entries in each parameter in the strucutre. E.g., for creating 2 file systems, specify 2 names, 2 disk sizes, 2 counts, 2 tiers and 2 paths. | <pre>object({<br>    names      = string<br>    disks_size = string<br>    counts     = string<br>    tiers      = string<br>    paths      = string<br>  })</pre> | <pre>{<br>  "counts": "2,2,1,1",<br>  "disks_size": "10,10,10,10",<br>  "names": "data,log,shared,usrsap",<br>  "paths": "/hana/data,/hana/log,/hana/shared,/usr/sap",<br>  "tiers": "tier1,tier1,tier3,tier3"<br>}</pre> | no |
| <a name="input_pvs_sap_netweaver_instance_config"></a> [pvs\_sap\_netweaver\_instance\_config](#input\_pvs\_sap\_netweaver\_instance\_config) | SAP NetWeaver PowerVS instance configuration. If data is specified here - will replace other input. | <pre>object({<br>    name-suffix          = string<br>    number_of_instances  = string<br>    hostnames            = string<br>    ips                  = string<br>    cpu_proc_type        = string<br>    number_of_processors = string<br>    memory_size          = string<br>    sap_image_name       = string<br>  })</pre> | <pre>{<br>  "cpu_proc_type": "shared",<br>  "hostnames": "nw-app",<br>  "ips": "",<br>  "memory_size": "2",<br>  "name-suffix": "nw-app",<br>  "number_of_instances": "1",<br>  "number_of_processors": "0.5",<br>  "sap_image_name": "SLES15-SP3-SAP-NETWEAVER"<br>}</pre> | no |
| <a name="input_pvs_sap_netweaver_storage_config"></a> [pvs\_sap\_netweaver\_storage\_config](#input\_pvs\_sap\_netweaver\_storage\_config) | File systems to be created and attached to PowerVS instance for SAP NetWeaver. 'disk\_sizes' are in GB. 'count' specify over how many sotrage volumes the file system will be striped. 'tiers' specifies the storage tier in PowerVS service. For creating multiple file systems, specify multiple entries in each parameter in the strucutre. E.g., for creating 2 file systems, specify 2 names, 2 disk sizes, 2 counts, 2 tiers and 2 paths. | <pre>object({<br>    names      = string<br>    disks_size = string<br>    counts     = string<br>    tiers      = string<br>    paths      = string<br>  })</pre> | <pre>{<br>  "counts": "1,1",<br>  "disks_size": "10,10",<br>  "names": "usrsap,usrtrans",<br>  "paths": "/usr/sap,/usr/sap/trans",<br>  "tiers": "tier3,tier3"<br>}</pre> | no |
| <a name="input_pvs_sap_network_cidr"></a> [pvs\_sap\_network\_cidr](#input\_pvs\_sap\_network\_cidr) | CIDR for new Network for SAP system | `string` | `"10.111.1.1/24"` | no |
| <a name="input_pvs_sap_network_name"></a> [pvs\_sap\_network\_name](#input\_pvs\_sap\_network\_name) | Name for new Network for SAP system | `string` | `"sap_net"` | no |
| <a name="input_pvs_sap_share_instance_config"></a> [pvs\_sap\_share\_instance\_config](#input\_pvs\_sap\_share\_instance\_config) | SAP shared file systems PowerVS instance configuration. If data is specified here - will replace other input. | <pre>object({<br>    name-suffix          = string<br>    number_of_instances  = string<br>    hostname             = string<br>    ip                   = string<br>    cpu_proc_type        = string<br>    number_of_processors = string<br>    memory_size          = string<br>    sap_image_name       = string<br>  })</pre> | <pre>{<br>  "cpu_proc_type": "shared",<br>  "hostname": "share-fs",<br>  "ip": "",<br>  "memory_size": "2",<br>  "name-suffix": "share-fs",<br>  "number_of_instances": "1",<br>  "number_of_processors": "0.5",<br>  "sap_image_name": "SLES15-SP3-SAP-NETWEAVER"<br>}</pre> | no |
| <a name="input_pvs_sap_share_storage_config"></a> [pvs\_sap\_share\_storage\_config](#input\_pvs\_sap\_share\_storage\_config) | File systems to be created and attached to PowerVS instance for shared file systems. 'disk\_sizes' are in GB. 'count' specify over how many sotrage volumes the file system will be striped. 'tiers' specifies the storage tier in PowerVS service. For creating multiple file systems, specify multiple entries in each parameter in the strucutre. E.g., for creating 2 file systems, specify 2 names, 2 disk sizes, 2 counts, 2 tiers and 2 paths. | <pre>object({<br>    names      = string<br>    disks_size = string<br>    counts     = string<br>    tiers      = string<br>    paths      = string<br>  })</pre> | <pre>{<br>  "counts": "1",<br>  "disks_size": "10",<br>  "names": "share",<br>  "paths": "/share",<br>  "tiers": "tier3"<br>}</pre> | no |
| <a name="input_pvs_service_name"></a> [pvs\_service\_name](#input\_pvs\_service\_name) | Name of IBM Cloud PowerVS service which will be created | `string` | `"power-service"` | no |
| <a name="input_pvs_ssh_key_name"></a> [pvs\_ssh\_key\_name](#input\_pvs\_ssh\_key\_name) | Name of IBM Cloud PowerVS SSH Key which will be created | `string` | `"ssh-key-pvs"` | no |
| <a name="input_pvs_zone"></a> [pvs\_zone](#input\_pvs\_zone) | IBM Cloud PowerVS Zone. Valid values: sao01,osa21,tor01,us-south,dal12,us-east,tok04,lon04,lon06,eu-de-1,eu-de-2,syd04,syd05 | `string` | `"mon01"` | no |
| <a name="input_resource_group"></a> [resource\_group](#input\_resource\_group) | Existing resource group name to use for this example. If null, a new resource group will be created. | `string` | n/a | yes |
| <a name="input_resource_tags"></a> [resource\_tags](#input\_resource\_tags) | Optional list of tags to be added to created resources | `list(string)` | `[]` | no |
| <a name="input_reuse_cloud_connections"></a> [reuse\_cloud\_connections](#input\_reuse\_cloud\_connections) | When the value is true, cloud connections will be reused (and is already attached to Transit gateway) | `bool` | `true` | no |
| <a name="input_squid_proxy_config"></a> [squid\_proxy\_config](#input\_squid\_proxy\_config) | Configure SQUID proxy to use with IBM Cloud PowerVS instances. | <pre>object({<br>    squid_proxy_host_or_ip = string<br>  })</pre> | <pre>{<br>  "squid_proxy_host_or_ip": null<br>}</pre> | no |
| <a name="input_transit_gateway_name"></a> [transit\_gateway\_name](#input\_transit\_gateway\_name) | Name of the existing transit gateway. Existing name must be provided when you want to create new cloud connections. | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_access_host_or_ip"></a> [access\_host\_or\_ip](#output\_access\_host\_or\_ip) | Public IP of Provided Bastion/JumpServer Host |
| <a name="output_hana_ips"></a> [hana\_ips](#output\_hana\_ips) | All private IPS of HANA instance |
| <a name="output_netweaver_ips"></a> [netweaver\_ips](#output\_netweaver\_ips) | All private IPs of NetWeaver instances |
| <a name="output_share_fs_ips"></a> [share\_fs\_ips](#output\_share\_fs\_ips) | All private IPs of share FS instance (if created) |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
