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
  region           = var.powervs_region
  zone             = var.powervs_zone
  ibmcloud_api_key = var.ibmcloud_api_key != null ? var.ibmcloud_api_key : null
}

module "sap_systems" {
  source                     = "git::https://github.com/terraform-ibm-modules/terraform-ibm-powervs-sap.git?ref=main"
  powervs_zone                           = var.powervs_zone
  powervs_resource_group_name            = var.resource_group_name
  powervs_service_name                   = var.powervs_service_name
  powervs_sshkey_name                    = var.powervs_sshkey_name
  powervs_sap_network_name               = var.powervs_sap_network_name
  powervs_sap_network_cidr               = var.powervs_sap_network_cidr
  powervs_additional_networks            = var.powervs_additional_networks
  powervs_cloud_connection_count         = var.cloud_connection_count

  powervs_share_instance_name            = var.powervs_share_hostname
  powervs_share_image_name               = var.powervs_share_os_image
  powervs_share_number_of_instances      = var.powervs_share_number_of_instances
  powervs_share_number_of_processors     = var.powervs_share_number_of_processors
  powervs_share_memory_size              = var.powervs_share_memory_size
  powervs_share_cpu_proc_type            = var.powervs_share_cpu_proc_type
  powervs_share_server_type              = var.powervs_share_server_type
  powervs_share_storage_config           = var.sap_share_storage_config

  powervs_hana_instance_name             = var.powervs_hana_hostname
  powervs_hana_image_name                = var.powervs_hana_os_image
  powervs_hana_sap_profile_id            = var.powervs_hana_sap_profile_id
  powervs_hana_storage_config            = var.sap_hana_additional_storage_config


  powervs_netweaver_instance_name        = var.powervs_netweaver_hostname
  powervs_netweaver_image_name           = var.powervs_netweaver_os_image
  powervs_netweaver_number_of_instances  = var.powervs_sap_netweaver_instance_number
  powervs_netweaver_number_of_processors = var.powervs_netweaver_number_of_processors
  powervs_netweaver_memory_size          = var.powervs_netweaver_memory_size
  powervs_netweaver_cpu_proc_type        = var.powervs_netweaver_cpu_proc_type
  powervs_netweaver_server_type          = var.powervs_netweaver_server_type
  powervs_netweaver_storage_config       = var.sap_netweaver_storage_config

  configure_os                           = var.configure_os
  os_image_distro                        = var.os_image_distro
  access_host_or_ip                      = var.access_host_or_ip
  ssh_private_key                        = var.ssh_private_key
  proxy_host_or_ip                       = var.proxy_host_or_ip
  ntp_host_or_ip                         = var.ntp_host_or_ip
  dns_host_or_ip                         = var.dns_host_or_ip
  nfs_path                               = var.nfs_path
  nfs_client_directory                   = var.nfs_client_directory
  sap_domain                             = var.sap_domain
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
| <a name="input_nfs_path"></a> [nfs\_path](#input\_nfs\_path) | Full path on NFS server (in form <hostname\_or\_ip>:<directory>, e.g., '10.20.10.4:/nfs'). | `string` | `""` | no |
| <a name="input_ntp_host_or_ip"></a> [ntp\_host\_or\_ip](#input\_ntp\_host\_or\_ip) | NTP forwarder/server hosname or IP address. E.g., 10.10.10.7 | `string` | `""` | no |
| <a name="input_os_image_distro"></a> [os\_image\_distro](#input\_os\_image\_distro) | Image distribution to use. Supported values are 'SLES' or 'RHEL'. OS release versions may be specified in optional parameters. | `string` | n/a | yes |
| <a name="input_powervs_additional_networks"></a> [powervs\_additional\_networks](#input\_powervs\_additional\_networks) | Existing list of subnets name to be attached to an instance. First network has to be a management network. | `list(any)` | n/a | yes |
| <a name="input_powervs_cloud_connection_count"></a> [powervs\_cloud\_connection\_count](#input\_powervs\_cloud\_connection\_count) | Number of existing Cloud connections to attach new private network | `string` | `2` | no |
| <a name="input_powervs_hana_image_name"></a> [powervs\_hana\_image\_name](#input\_powervs\_hana\_image\_name) | Image Names to import into the service. | `string` | n/a | yes |
| <a name="input_powervs_hana_instance_name"></a> [powervs\_hana\_instance\_name](#input\_powervs\_hana\_instance\_name) | Name of instance which will be created. | `string` | n/a | yes |
| <a name="input_powervs_hana_sap_profile_id"></a> [powervs\_hana\_sap\_profile\_id](#input\_powervs\_hana\_sap\_profile\_id) | SAP PROFILE ID. If this is mentioned then Memory, processors, proc\_type and sys\_type will not be taken into account. | `string` | `null` | no |
| <a name="input_powervs_hana_storage_config"></a> [powervs\_hana\_storage\_config](#input\_powervs\_hana\_storage\_config) | File systems to be created and attached to PowerVS instance for SAP HANA. 'disk\_sizes' are in GB. 'count' specify over how many sotrage volumes the file system will be striped. 'tiers' specifies the storage tier in PowerVS service. For creating multiple file systems, specify multiple entries in each parameter in the strucutre. E.g., for creating 2 file systems, specify 2 names, 2 disk sizes, 2 counts, 2 tiers and 2 paths. | <pre>object({<br>    names      = string<br>    disks_size = string<br>    counts     = string<br>    tiers      = string<br>    paths      = string<br>  })</pre> | <pre>{<br>  "counts": "",<br>  "disks_size": "",<br>  "names": "",<br>  "paths": "",<br>  "tiers": ""<br>}</pre> | no |
| <a name="input_powervs_netweaver_cpu_proc_type"></a> [powervs\_netweaver\_cpu\_proc\_type](#input\_powervs\_netweaver\_cpu\_proc\_type) | Dedicated or shared processors | `string` | `"shared"` | no |
| <a name="input_powervs_netweaver_image_name"></a> [powervs\_netweaver\_image\_name](#input\_powervs\_netweaver\_image\_name) | Image Names to import into the service | `string` | n/a | yes |
| <a name="input_powervs_netweaver_instance_name"></a> [powervs\_netweaver\_instance\_name](#input\_powervs\_netweaver\_instance\_name) | Name of instance which will be created | `string` | n/a | yes |
| <a name="input_powervs_netweaver_memory_size"></a> [powervs\_netweaver\_memory\_size](#input\_powervs\_netweaver\_memory\_size) | Amount of memory | `string` | n/a | yes |
| <a name="input_powervs_netweaver_number_of_instances"></a> [powervs\_netweaver\_number\_of\_instances](#input\_powervs\_netweaver\_number\_of\_instances) | Number of instances | `string` | `1` | no |
| <a name="input_powervs_netweaver_number_of_processors"></a> [powervs\_netweaver\_number\_of\_processors](#input\_powervs\_netweaver\_number\_of\_processors) | Number of processors | `string` | n/a | yes |
| <a name="input_powervs_netweaver_server_type"></a> [powervs\_netweaver\_server\_type](#input\_powervs\_netweaver\_server\_type) | Processor type e980, s922, s1022 or e1080 | `string` | `"s922"` | no |
| <a name="input_powervs_netweaver_storage_config"></a> [powervs\_netweaver\_storage\_config](#input\_powervs\_netweaver\_storage\_config) | File systems to be created and attached to PowerVS instance for SAP NetWeaver. 'disk\_sizes' are in GB. 'count' specify over how many sotrage volumes the file system will be striped. 'tiers' specifies the storage tier in PowerVS service. For creating multiple file systems, specify multiple entries in each parameter in the strucutre. E.g., for creating 2 file systems, specify 2 names, 2 disk sizes, 2 counts, 2 tiers and 2 paths. | <pre>object({<br>    names      = string<br>    disks_size = string<br>    counts     = string<br>    tiers      = string<br>    paths      = string<br>  })</pre> | <pre>{<br>  "counts": "",<br>  "disks_size": "",<br>  "names": "",<br>  "paths": "",<br>  "tiers": ""<br>}</pre> | no |
| <a name="input_powervs_resource_group_name"></a> [powervs\_resource\_group\_name](#input\_powervs\_resource\_group\_name) | Existing IBM Cloud resource group name. | `string` | n/a | yes |
| <a name="input_powervs_sap_network_cidr"></a> [powervs\_sap\_network\_cidr](#input\_powervs\_sap\_network\_cidr) | CIDR for new network for SAP system | `string` | n/a | yes |
| <a name="input_powervs_sap_network_name"></a> [powervs\_sap\_network\_name](#input\_powervs\_sap\_network\_name) | Name for new network for SAP system | `string` | n/a | yes |
| <a name="input_powervs_service_name"></a> [powervs\_service\_name](#input\_powervs\_service\_name) | Existing Name of the PowerVS service. | `string` | n/a | yes |
| <a name="input_powervs_share_cpu_proc_type"></a> [powervs\_share\_cpu\_proc\_type](#input\_powervs\_share\_cpu\_proc\_type) | Dedicated or shared processors | `string` | `"shared"` | no |
| <a name="input_powervs_share_image_name"></a> [powervs\_share\_image\_name](#input\_powervs\_share\_image\_name) | Image Names to import into the service | `string` | n/a | yes |
| <a name="input_powervs_share_instance_name"></a> [powervs\_share\_instance\_name](#input\_powervs\_share\_instance\_name) | Name of instance which will be created | `string` | n/a | yes |
| <a name="input_powervs_share_memory_size"></a> [powervs\_share\_memory\_size](#input\_powervs\_share\_memory\_size) | Amount of memory | `string` | `2` | no |
| <a name="input_powervs_share_number_of_instances"></a> [powervs\_share\_number\_of\_instances](#input\_powervs\_share\_number\_of\_instances) | Number of instances | `string` | n/a | yes |
| <a name="input_powervs_share_number_of_processors"></a> [powervs\_share\_number\_of\_processors](#input\_powervs\_share\_number\_of\_processors) | Number of processors | `string` | `0.5` | no |
| <a name="input_powervs_share_server_type"></a> [powervs\_share\_server\_type](#input\_powervs\_share\_server\_type) | Processor type e980, s922, s1022 or e1080 | `string` | `"s922"` | no |
| <a name="input_powervs_share_storage_config"></a> [powervs\_share\_storage\_config](#input\_powervs\_share\_storage\_config) | File systems to be created and attached to PowerVS instance for shared storage file systems. 'disk\_sizes' are in GB. 'count' specify over how many sotrage volumes the file system will be striped. 'tiers' specifies the storage tier in PowerVS service. For creating multiple file systems, specify multiple entries in each parameter in the strucutre. E.g., for creating 2 file systems, specify 2 names, 2 disk sizes, 2 counts, 2 tiers and 2 paths. | <pre>object({<br>    names      = string<br>    disks_size = string<br>    counts     = string<br>    tiers      = string<br>    paths      = string<br>  })</pre> | <pre>{<br>  "counts": "",<br>  "disks_size": "",<br>  "names": "",<br>  "paths": "",<br>  "tiers": ""<br>}</pre> | no |
| <a name="input_powervs_sshkey_name"></a> [powervs\_sshkey\_name](#input\_powervs\_sshkey\_name) | Existing PowerVs SSH key name. | `string` | n/a | yes |
| <a name="input_powervs_zone"></a> [powervs\_zone](#input\_powervs\_zone) | IBM Cloud PowerVS zone. | `string` | n/a | yes |
| <a name="input_proxy_host_or_ip"></a> [proxy\_host\_or\_ip](#input\_proxy\_host\_or\_ip) | Proxy hosname or IP address with port. E.g., 10.10.10.4:3128 | `string` | `""` | no |
| <a name="input_sap_domain"></a> [sap\_domain](#input\_sap\_domain) | Domain name to be set. | `string` | `""` | no |
| <a name="input_ssh_private_key"></a> [ssh\_private\_key](#input\_ssh\_private\_key) | Private SSH key used to login to IBM PowerVS instances. Should match to uploaded public SSH key referenced by 'ssh\_public\_key'. Entered data must be in heredoc strings format (https://www.terraform.io/language/expressions/strings#heredoc-strings). The key is not uploaded or stored. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_access_host_or_ip"></a> [access\_host\_or\_ip](#output\_access\_host\_or\_ip) | Public IP to manage the environment |
| <a name="output_hana_instance_private_ips"></a> [hana\_instance\_private\_ips](#output\_hana\_instance\_private\_ips) | Private IPs of the HANA instance. |
| <a name="output_netweaver_instance_private_ips"></a> [netweaver\_instance\_private\_ips](#output\_netweaver\_instance\_private\_ips) | Private IPs of all NetWeaver instances. |
| <a name="output_share_fs_instance_private_ips"></a> [share\_fs\_instance\_private\_ips](#output\_share\_fs\_instance\_private\_ips) | Private IPs of the Share FS instance. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
