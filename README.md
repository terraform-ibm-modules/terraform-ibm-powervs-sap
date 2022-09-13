# PowerVS SAP system module

The PowerVS SAP system module automates the following tasks:
- Creates and configures one PowerVS instance for SAP HANA based on best practises
- Creates and configures 1..n PowerVS instances for SAP NetWeaver based on best practises
- Creates and configures one optional PowerVS instance that can be used for sharing SAP files between other system instances.
- Connects all created PowerVS instances to proxy server specified by IP address or host name
- Optionally connects all created PowerVS instances to NTP and/or DNS forwarder specified by IP address or host name
- Optionally configures on all created PowerVS instances a shared NFS directory provided by NFS server specified by IP address or host name

## Example Usage
```hcl
provider "ibm" {
  region           = var.pvs_region
  zone             = var.pvs_zone
  ibmcloud_api_key = var.ibmcloud_api_key != null ? var.ibmcloud_api_key : null
}

module "sap_systems" {
  source                     = "git::https://github.com/terraform-ibm-modules/terraform-ibm-powervs-sap.git?ref=main"
  pvs_zone                   = var.pvs_zone
  pvs_resource_group_name    = var.resource_group_name
  pvs_service_name           = var.pvs_service_name
  pvs_sshkey_name            = var.pvs_sshkey_name
  pvs_sap_network_cidr       = var.pvs_sap_network_cidr
  pvs_sap_network_name       = local.pvs_sap_network_name
  pvs_additional_networks    = var.additional_networks
  pvs_cloud_connection_count = var.cloud_connection_count

  pvs_share_number_of_instances  = local.pvs_share_number_of_instances
  pvs_share_image_name           = local.pvs_share_os_image
  pvs_share_instance_name        = local.pvs_share_hostname
  pvs_share_memory_size          = local.pvs_share_memory_size
  pvs_share_number_of_processors = local.pvs_share_number_of_processors
  pvs_share_cpu_proc_type        = local.pvs_share_cpu_proc_type
  pvs_share_server_type          = local.pvs_share_server_type
  pvs_share_storage_config       = var.sap_share_storage_config

  pvs_hana_instance_name  = local.pvs_hana_hostname
  pvs_hana_image_name     = local.pvs_hana_os_image
  pvs_hana_sap_profile_id = local.pvs_hana_sap_profile_id
  pvs_hana_storage_config = var.sap_hana_additional_storage_config

  pvs_netweaver_number_of_instances  = local.pvs_sap_netweaver_instance_number
  pvs_netweaver_image_name           = local.pvs_netweaver_os_image
  pvs_netweaver_instance_name        = local.pvs_netweaver_hostname
  pvs_netweaver_memory_size          = local.pvs_netweaver_memory_size
  pvs_netweaver_number_of_processors = local.pvs_netweaver_number_of_processors
  pvs_netweaver_cpu_proc_type        = local.pvs_netweaver_cpu_proc_type
  pvs_netweaver_server_type          = local.pvs_netweaver_server_type
  pvs_netweaver_storage_config       = var.sap_netweaver_storage_config

  access_host_or_ip    = var.access_host_or_ip
  proxy_host_or_ip     = var.proxy_host_or_ip
  nfs_host_or_ip       = var.nfs_host_or_ip
  ntp_host_or_ip       = var.ntp_host_or_ip
  dns_host_or_ip       = var.dns_host_or_ip
  ssh_private_key      = var.ssh_private_key
  os_image_distro      = var.os_image_distro
  nfs_path             = var.nfs_path
  nfs_client_directory = var.nfs_client_directory
}
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
| <a name="module_attach_sap_network"></a> [attach\_sap\_network](#module\_attach\_sap\_network) | ./submodules/power_attach_private_network | n/a |
| <a name="module_create_sap_network"></a> [create\_sap\_network](#module\_create\_sap\_network) | ./submodules/power_create_private_network | n/a |
| <a name="module_instance_init"></a> [instance\_init](#module\_instance\_init) | ./submodules/power_sap_instance_init | n/a |
| <a name="module_sap_hana_instance"></a> [sap\_hana\_instance](#module\_sap\_hana\_instance) | ./submodules/power_instance | n/a |
| <a name="module_sap_netweaver_instance"></a> [sap\_netweaver\_instance](#module\_sap\_netweaver\_instance) | ./submodules/power_instance | n/a |
| <a name="module_share_fs_instance"></a> [share\_fs\_instance](#module\_share\_fs\_instance) | ./submodules/power_instance | n/a |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_access_host_or_ip"></a> [access\_host\_or\_ip](#input\_access\_host\_or\_ip) | Public IP of Bastion/jumpserver Host | `string` | n/a | yes |
| <a name="input_configure_os"></a> [configure\_os](#input\_configure\_os) | Specify if OS on PowerVS instances should be configure for SAP or if only PowerVS instances should be created. | `bool` | `true` | no |
| <a name="input_dns_host_or_ip"></a> [dns\_host\_or\_ip](#input\_dns\_host\_or\_ip) | DNS forwarder/server hosname or IP address. E.g., 10.10.10.6 | `string` | `""` | no |
| <a name="input_nfs_client_directory"></a> [nfs\_client\_directory](#input\_nfs\_client\_directory) | NFS directory on PowerVS instances. | `string` | `"/nfs"` | no |
| <a name="input_nfs_host_or_ip"></a> [nfs\_host\_or\_ip](#input\_nfs\_host\_or\_ip) | NFS server hosname or IP address. E.g., 10.10.10.5 | `string` | `""` | no |
| <a name="input_nfs_path"></a> [nfs\_path](#input\_nfs\_path) | NFS directory on NFS server. | `string` | `"/nfs"` | no |
| <a name="input_ntp_host_or_ip"></a> [ntp\_host\_or\_ip](#input\_ntp\_host\_or\_ip) | NTP forwarder/server hosname or IP address. E.g., 10.10.10.7 | `string` | `""` | no |
| <a name="input_os_image_distro"></a> [os\_image\_distro](#input\_os\_image\_distro) | Image distribution to use. Supported values are 'SLES' or 'RHEL'. OS release versions may be specified in optional parameters. | `string` | n/a | yes |
| <a name="input_proxy_host_or_ip"></a> [proxy\_host\_or\_ip](#input\_proxy\_host\_or\_ip) | Proxy hosname or IP address with port. E.g., 10.10.10.4:3128 | `string` | `""` | no |
| <a name="input_pvs_additional_networks"></a> [pvs\_additional\_networks](#input\_pvs\_additional\_networks) | Existing list of subnets name to be attached to node. First network has to be a management network | `list(any)` | n/a | yes |
| <a name="input_pvs_cloud_connection_count"></a> [pvs\_cloud\_connection\_count](#input\_pvs\_cloud\_connection\_count) | Required number of Cloud connections which will be created/Reused. Maximum is 2 per location | `string` | `2` | no |
| <a name="input_pvs_hana_image_name"></a> [pvs\_hana\_image\_name](#input\_pvs\_hana\_image\_name) | Image Names to import into the service | `string` | n/a | yes |
| <a name="input_pvs_hana_instance_name"></a> [pvs\_hana\_instance\_name](#input\_pvs\_hana\_instance\_name) | Name of instance which will be created | `string` | n/a | yes |
| <a name="input_pvs_hana_sap_profile_id"></a> [pvs\_hana\_sap\_profile\_id](#input\_pvs\_hana\_sap\_profile\_id) | SAP PROFILE ID. If this is mentioned then Memory, processors, proc\_type and sys\_type will not be taken into account | `string` | `null` | no |
| <a name="input_pvs_hana_storage_config"></a> [pvs\_hana\_storage\_config](#input\_pvs\_hana\_storage\_config) | File systems to be created and attached to PowerVS instance for SAP HANA. 'disk\_sizes' are in GB. 'count' specify over how many sotrage volumes the file system will be striped. 'tiers' specifies the storage tier in PowerVS service. For creating multiple file systems, specify multiple entries in each parameter in the strucutre. E.g., for creating 2 file systems, specify 2 names, 2 disk sizes, 2 counts, 2 tiers and 2 paths. | <pre>object({<br>    names      = string<br>    disks_size = string<br>    counts     = string<br>    tiers      = string<br>    paths      = string<br>  })</pre> | <pre>{<br>  "counts": "",<br>  "disks_size": "",<br>  "names": "",<br>  "paths": "",<br>  "tiers": ""<br>}</pre> | no |
| <a name="input_pvs_netweaver_cpu_proc_type"></a> [pvs\_netweaver\_cpu\_proc\_type](#input\_pvs\_netweaver\_cpu\_proc\_type) | Dedicated or shared processors | `string` | `"shared"` | no |
| <a name="input_pvs_netweaver_image_name"></a> [pvs\_netweaver\_image\_name](#input\_pvs\_netweaver\_image\_name) | Image Names to import into the service | `string` | n/a | yes |
| <a name="input_pvs_netweaver_instance_name"></a> [pvs\_netweaver\_instance\_name](#input\_pvs\_netweaver\_instance\_name) | Name of instance which will be created | `string` | n/a | yes |
| <a name="input_pvs_netweaver_memory_size"></a> [pvs\_netweaver\_memory\_size](#input\_pvs\_netweaver\_memory\_size) | Amount of memory | `string` | n/a | yes |
| <a name="input_pvs_netweaver_number_of_instances"></a> [pvs\_netweaver\_number\_of\_instances](#input\_pvs\_netweaver\_number\_of\_instances) | Number of instances | `string` | `1` | no |
| <a name="input_pvs_netweaver_number_of_processors"></a> [pvs\_netweaver\_number\_of\_processors](#input\_pvs\_netweaver\_number\_of\_processors) | Number of processors | `string` | n/a | yes |
| <a name="input_pvs_netweaver_server_type"></a> [pvs\_netweaver\_server\_type](#input\_pvs\_netweaver\_server\_type) | Processor type e980, s922, s1022 or e1080 | `string` | `"s922"` | no |
| <a name="input_pvs_netweaver_storage_config"></a> [pvs\_netweaver\_storage\_config](#input\_pvs\_netweaver\_storage\_config) | File systems to be created and attached to PowerVS instance for SAP NetWeaver. 'disk\_sizes' are in GB. 'count' specify over how many sotrage volumes the file system will be striped. 'tiers' specifies the storage tier in PowerVS service. For creating multiple file systems, specify multiple entries in each parameter in the strucutre. E.g., for creating 2 file systems, specify 2 names, 2 disk sizes, 2 counts, 2 tiers and 2 paths. | <pre>object({<br>    names      = string<br>    disks_size = string<br>    counts     = string<br>    tiers      = string<br>    paths      = string<br>  })</pre> | <pre>{<br>  "counts": "",<br>  "disks_size": "",<br>  "names": "",<br>  "paths": "",<br>  "tiers": ""<br>}</pre> | no |
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
| <a name="input_pvs_share_storage_config"></a> [pvs\_share\_storage\_config](#input\_pvs\_share\_storage\_config) | File systems to be created and attached to PowerVS instance for shared storage file systems. 'disk\_sizes' are in GB. 'count' specify over how many sotrage volumes the file system will be striped. 'tiers' specifies the storage tier in PowerVS service. For creating multiple file systems, specify multiple entries in each parameter in the strucutre. E.g., for creating 2 file systems, specify 2 names, 2 disk sizes, 2 counts, 2 tiers and 2 paths. | <pre>object({<br>    names      = string<br>    disks_size = string<br>    counts     = string<br>    tiers      = string<br>    paths      = string<br>  })</pre> | <pre>{<br>  "counts": "",<br>  "disks_size": "",<br>  "names": "",<br>  "paths": "",<br>  "tiers": ""<br>}</pre> | no |
| <a name="input_pvs_sshkey_name"></a> [pvs\_sshkey\_name](#input\_pvs\_sshkey\_name) | Existing SSH key name | `string` | n/a | yes |
| <a name="input_pvs_zone"></a> [pvs\_zone](#input\_pvs\_zone) | IBM Cloud Zone | `string` | n/a | yes |
| <a name="input_sap_domain"></a> [sap\_domain](#input\_sap\_domain) | Domain name to be set. | `string` | `""` | no |
| <a name="input_ssh_private_key"></a> [ssh\_private\_key](#input\_ssh\_private\_key) | Private Key to configure Instance, Will not be uploaded to server | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_access_host_or_ip"></a> [access\_host\_or\_ip](#output\_access\_host\_or\_ip) | Public IP to manage the environment |
| <a name="output_hana_instance_private_ips"></a> [hana\_instance\_private\_ips](#output\_hana\_instance\_private\_ips) | Private IPs of the HANA instance. |
| <a name="output_netweaver_instance_private_ips"></a> [netweaver\_instance\_private\_ips](#output\_netweaver\_instance\_private\_ips) | Private IPs of the NetWeaver instance. |
| <a name="output_share_fs_instance_private_ips"></a> [share\_fs\_instance\_private\_ips](#output\_share\_fs\_instance\_private\_ips) | Private IPs of the Share FS instance. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
