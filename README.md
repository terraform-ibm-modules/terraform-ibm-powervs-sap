<!-- BEGIN MODULE HOOK -->

# SAP on secure Power Virtual Servers module

<!-- UPDATE BADGE: Update the link for the badge below-->
[![Graduated (Supported)](https://img.shields.io/badge/status-Graduated%20(Supported)-brightgreen?style=plastic)](https://terraform-ibm-modules.github.io/documentation/#/badge-status)
[![build status](https://github.com/terraform-ibm-modules/terraform-ibm-landing-zone/actions/workflows/ci.yml/badge.svg)](https://github.com/terraform-ibm-modules/terraform-ibm-landing-zone/actions/workflows/ci.yml)
[![semantic-release](https://img.shields.io/badge/%20%20%F0%9F%93%A6%F0%9F%9A%80-semantic--release-e10079.svg)](https://github.com/semantic-release/semantic-release)
[![pre-commit](https://img.shields.io/badge/pre--commit-enabled-brightgreen?logo=pre-commit&logoColor=white)](https://github.com/pre-commit/pre-commit)
[![latest release](https://img.shields.io/github/v/release/terraform-ibm-modules/terraform-ibm-powervs-sap?logo=GitHub&sort=semver)](https://github.com/terraform-ibm-modules/terraform-ibm-powervs-sap/releases/latest)

The SAP on secure Power Virtual Servers (PowerVS) module automates the following tasks:

- Creates and configures one PowerVS instance for SAP HANA that is based on best practices.
- Creates and configures multiple PowerVS instances for SAP NetWeaver that are based on best practices.
- Creates and configures one optional PowerVS instance that can be used for sharing SAP files between other system instances.
- Connects all created PowerVS instances to a proxy server that is specified by IP address or hostname.
- Optionally connects all created PowerVS instances to an NTP server and DNS forwarder that are specified by IP address or hostname.
- Optionally configures a shared NFS directory on all created PowerVS instances. The directory is provided by an NFS server that is specified by IP address or hostname.

The following limitations apply to the module:

- The name of the SAP system network must be unique and cannot be reused. If you destroy a system and re-create it, you must use a different network name.
- Only the following operating systems are supported:
    - SUSE Linux Enterprise Server (SLES) version 15 SP3
    - Red Hat Enterprise Linux (RHEL) version 8.4

## Reference architectures

- [SAP Ready to go PowerVS](reference-architectures/sap-ready-to-go/deploy-arch-ibm-pvs-sap-ready-to-go.md)

## Usage

```hcl
provider "ibm" {
  region           = var.powervs_region
  zone             = var.powervs_zone
  ibmcloud_api_key = var.ibmcloud_api_key != null ? var.ibmcloud_api_key : null
}

module "sap_systems" {
  source                                 = "git::https://github.com/terraform-ibm-modules/terraform-ibm-powervs-sap.git?ref=main"
  powervs_zone                           = var.powervs_zone
  powervs_resource_group_name            = var.resource_group_name
  powervs_workspace_name                 = var.powervs_workspace_name
  powervs_sshkey_name                    = var.powervs_sshkey_name
  powervs_sap_network                    = var.powervs_sap_network
  powervs_additional_networks            = var.powervs_additional_networks
  powervs_cloud_connection_count         = var.cloud_connection_count

  powervs_share_instance_name            = var.powervs_share_hostname
  powervs_share_image_name               = var.powervs_share_os_image
  powervs_share_number_of_instances      = var.powervs_share_number_of_instances
  powervs_share_number_of_processors     = var.powervs_share_number_of_processors
  powervs_share_memory_size              = var.powervs_share_memory_size
  powervs_share_cpu_proc_type            = var.powervs_share_cpu_proc_type
  powervs_share_server_type              = var.powervs_share_server_type
  powervs_share_storage_config           = var.powervs_share_storage_config

  powervs_hana_instance_name             = var.powervs_hana_hostname
  powervs_hana_image_name                = var.powervs_hana_os_image
  powervs_hana_sap_profile_id            = var.powervs_hana_sap_profile_id
  powervs_hana_additional_storage_config = var.powervs_hana_additional_storage_config
  powervs_hana_custom_storage_config     = var.powervs_hana_custom_storage_config

  powervs_netweaver_instance_name        = var.powervs_netweaver_hostname
  powervs_netweaver_image_name           = var.powervs_netweaver_os_image
  powervs_netweaver_number_of_instances  = var.powervs_sap_netweaver_instance_number
  powervs_netweaver_number_of_processors = var.powervs_netweaver_number_of_processors
  powervs_netweaver_memory_size          = var.powervs_netweaver_memory_size
  powervs_netweaver_cpu_proc_type        = var.powervs_netweaver_cpu_proc_type
  powervs_netweaver_server_type          = var.powervs_netweaver_server_type
  powervs_netweaver_storage_config       = var.powervs_netweaver_storage_config

  configure_os                           = var.configure_os
  os_image_distro                        = var.os_image_distro
  access_host_or_ip                      = var.access_host_or_ip
  ssh_private_key                        = var.ssh_private_key
  proxy_host_or_ip_port                  = var.proxy_host_or_ip_port
  ntp_host_or_ip                         = var.ntp_host_or_ip
  dns_host_or_ip                         = var.dns_host_or_ip
  nfs_host_or_ip_path                    = var.nfs_host_or_ip_path
  nfs_client_directory                   = var.nfs_client_directory
  sap_domain                             = var.sap_domain
}
```
## Required IAM access policies

You need the following permissions to run this module.

- Account Management
    - **Resource Group** service
        - `Viewer` platform access
    - IAM Services
        - **Workspace for Power Systems Virtual Server** service
        - **Power Systems Virtual Server** service
            - `Editor` platform access
        - **VPC Infrastructure Services** service
            - `Editor` platform access
        - **Transit Gateway** service
            - `Editor` platform access
        - **Direct Link** service
            - `Editor` platform access

<!-- END MODULE HOOK -->

<!-- BEGIN EXAMPLES HOOK -->
## Examples

- [ Basic PowerVS SAP system Module Example](examples/basic)
- [ PowerVS SAP system example to create SAP prepared PowerVS instances from IBM Cloud Catalog](examples/ibm-catalog/deployable-architectures/sap-ready-to-go)
- [ PowerVS SAP system example to create SAP prepared PowerVS instances](examples/terraform-registry/sap-ready-to-go)
<!-- END EXAMPLES HOOK -->

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.0 |
| <a name="requirement_ibm"></a> [ibm](#requirement\_ibm) | >=1.49.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_attach_sap_network"></a> [attach\_sap\_network](#module\_attach\_sap\_network) | ./submodules/power_attach_private_network | n/a |
| <a name="module_create_sap_network"></a> [create\_sap\_network](#module\_create\_sap\_network) | ./submodules/power_create_private_network | n/a |
| <a name="module_initial_validation"></a> [initial\_validation](#module\_initial\_validation) | ./submodules/initial_validation | n/a |
| <a name="module_instance_init"></a> [instance\_init](#module\_instance\_init) | ./submodules/power_sap_instance_init | n/a |
| <a name="module_sap_hana_instance"></a> [sap\_hana\_instance](#module\_sap\_hana\_instance) | ./submodules/power_instance | n/a |
| <a name="module_sap_netweaver_instance"></a> [sap\_netweaver\_instance](#module\_sap\_netweaver\_instance) | ./submodules/power_instance | n/a |
| <a name="module_share_fs_instance"></a> [share\_fs\_instance](#module\_share\_fs\_instance) | ./submodules/power_instance | n/a |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_access_host_or_ip"></a> [access\_host\_or\_ip](#input\_access\_host\_or\_ip) | Public IP of Bastion/jumpserver Host | `string` | `null` | no |
| <a name="input_configure_os"></a> [configure\_os](#input\_configure\_os) | Specify if OS on PowerVS instances should be configured for SAP or if only PowerVS instances should be created. | `bool` | `true` | no |
| <a name="input_dns_host_or_ip"></a> [dns\_host\_or\_ip](#input\_dns\_host\_or\_ip) | DNS forwarder/server hostname or IP address. E.g., 10.10.10.6 | `string` | `""` | no |
| <a name="input_nfs_client_directory"></a> [nfs\_client\_directory](#input\_nfs\_client\_directory) | NFS directory on PowerVS instances. Will be used only if nfs\_server is setup in 'Power infrastructure for regulated industries' | `string` | `"/nfs"` | no |
| <a name="input_nfs_host_or_ip_path"></a> [nfs\_host\_or\_ip\_path](#input\_nfs\_host\_or\_ip\_path) | Full path on NFS server (in form <hostname\_or\_ip>:<directory>, e.g., '10.20.10.4:/nfs'). | `string` | `""` | no |
| <a name="input_ntp_host_or_ip"></a> [ntp\_host\_or\_ip](#input\_ntp\_host\_or\_ip) | NTP forwarder/server hostname or IP address. E.g., 10.10.10.7 | `string` | `""` | no |
| <a name="input_os_image_distro"></a> [os\_image\_distro](#input\_os\_image\_distro) | Image distribution to use for all instances(Shared, HANA, Netweaver). Supported values are 'SLES' or 'RHEL'. OS release versions may be specified in optional parameters. | `string` | n/a | yes |
| <a name="input_powervs_additional_networks"></a> [powervs\_additional\_networks](#input\_powervs\_additional\_networks) | Existing list of subnets name to be attached to an instance. First network has to be a management network. | `list(any)` | n/a | yes |
| <a name="input_powervs_cloud_connection_count"></a> [powervs\_cloud\_connection\_count](#input\_powervs\_cloud\_connection\_count) | Existing number of Cloud connections to which new subnet must be attached. | `string` | `2` | no |
| <a name="input_powervs_hana_additional_storage_config"></a> [powervs\_hana\_additional\_storage\_config](#input\_powervs\_hana\_additional\_storage\_config) | Additional File systems to be created and attached to PowerVS instance for SAP HANA. 'disk\_sizes' are in GB. 'count' specify over how many storage volumes the file system will be striped. 'tiers' specifies the storage tier in PowerVS workspace. For creating multiple file systems, specify multiple entries in each parameter in the structure. E.g., for creating 2 file systems, specify 2 names, 2 disk sizes, 2 counts, 2 tiers and 2 paths. | <pre>object({<br>    names      = string<br>    disks_size = string<br>    counts     = string<br>    tiers      = string<br>    paths      = string<br>  })</pre> | <pre>{<br>  "counts": "1",<br>  "disks_size": "50",<br>  "names": "usrsap",<br>  "paths": "/usr/sap",<br>  "tiers": "tier3"<br>}</pre> | no |
| <a name="input_powervs_hana_custom_storage_config"></a> [powervs\_hana\_custom\_storage\_config](#input\_powervs\_hana\_custom\_storage\_config) | Custom File systems to be created and attached to PowerVS instance for SAP HANA. 'disk\_sizes' are in GB. 'count' specify over how many storage volumes the file system will be striped. 'tiers' specifies the storage tier in PowerVS workspace. For creating multiple file systems, specify multiple entries in each parameter in the structure. E.g., for creating 2 file systems, specify 2 names, 2 disk sizes, 2 counts, 2 tiers and 2 paths. | <pre>object({<br>    names      = string<br>    disks_size = string<br>    counts     = string<br>    tiers      = string<br>    paths      = string<br>  })</pre> | <pre>{<br>  "counts": "",<br>  "disks_size": "",<br>  "names": "",<br>  "paths": "",<br>  "tiers": ""<br>}</pre> | no |
| <a name="input_powervs_hana_image_name"></a> [powervs\_hana\_image\_name](#input\_powervs\_hana\_image\_name) | Image Name for HANA Instance. | `string` | n/a | yes |
| <a name="input_powervs_hana_instance_name"></a> [powervs\_hana\_instance\_name](#input\_powervs\_hana\_instance\_name) | Name of instance which will be created. | `string` | n/a | yes |
| <a name="input_powervs_hana_sap_profile_id"></a> [powervs\_hana\_sap\_profile\_id](#input\_powervs\_hana\_sap\_profile\_id) | SAP HANA profile to use. Must be one of the supported profiles. See [here](https://cloud.ibm.com/docs/sap?topic=sap-hana-iaas-offerings-profiles-power-vs). File system sizes are automatically calculated. Override automatic calculation by setting values in optional powervs\_hana\_custom\_storage\_config parameter. | `string` | `"cnp-2x64"` | no |
| <a name="input_powervs_netweaver_cpu_proc_type"></a> [powervs\_netweaver\_cpu\_proc\_type](#input\_powervs\_netweaver\_cpu\_proc\_type) | Dedicated or shared processors | `string` | `"shared"` | no |
| <a name="input_powervs_netweaver_image_name"></a> [powervs\_netweaver\_image\_name](#input\_powervs\_netweaver\_image\_name) | Image Name for netweaver instance | `string` | n/a | yes |
| <a name="input_powervs_netweaver_instance_name"></a> [powervs\_netweaver\_instance\_name](#input\_powervs\_netweaver\_instance\_name) | Name of netweaver instance which will be created | `string` | n/a | yes |
| <a name="input_powervs_netweaver_memory_size"></a> [powervs\_netweaver\_memory\_size](#input\_powervs\_netweaver\_memory\_size) | Amount of memory | `string` | n/a | yes |
| <a name="input_powervs_netweaver_number_of_instances"></a> [powervs\_netweaver\_number\_of\_instances](#input\_powervs\_netweaver\_number\_of\_instances) | Number of instances | `number` | `1` | no |
| <a name="input_powervs_netweaver_number_of_processors"></a> [powervs\_netweaver\_number\_of\_processors](#input\_powervs\_netweaver\_number\_of\_processors) | Number of processors | `string` | n/a | yes |
| <a name="input_powervs_netweaver_server_type"></a> [powervs\_netweaver\_server\_type](#input\_powervs\_netweaver\_server\_type) | Processor type e980, s922, s1022 or e1080 | `string` | `"s922"` | no |
| <a name="input_powervs_netweaver_storage_config"></a> [powervs\_netweaver\_storage\_config](#input\_powervs\_netweaver\_storage\_config) | File systems to be created and attached to PowerVS instance for SAP NetWeaver. 'disk\_sizes' are in GB. 'count' specify over how many storage volumes the file system will be striped. 'tiers' specifies the storage tier in PowerVS workspace. For creating multiple file systems, specify multiple entries in each parameter in the structure. E.g., for creating 2 file systems, specify 2 names, 2 disk sizes, 2 counts, 2 tiers and 2 paths. | <pre>object({<br>    names      = string<br>    disks_size = string<br>    counts     = string<br>    tiers      = string<br>    paths      = string<br>  })</pre> | <pre>{<br>  "counts": "",<br>  "disks_size": "",<br>  "names": "",<br>  "paths": "",<br>  "tiers": ""<br>}</pre> | no |
| <a name="input_powervs_resource_group_name"></a> [powervs\_resource\_group\_name](#input\_powervs\_resource\_group\_name) | Existing IBM Cloud resource group name. | `string` | n/a | yes |
| <a name="input_powervs_sap_network"></a> [powervs\_sap\_network](#input\_powervs\_sap\_network) | Name and CIDR for new network for SAP system to create. | <pre>object({<br>    name = string<br>    cidr = string<br>  })</pre> | n/a | yes |
| <a name="input_powervs_share_cpu_proc_type"></a> [powervs\_share\_cpu\_proc\_type](#input\_powervs\_share\_cpu\_proc\_type) | Dedicated or shared processors | `string` | `"shared"` | no |
| <a name="input_powervs_share_image_name"></a> [powervs\_share\_image\_name](#input\_powervs\_share\_image\_name) | Image Name for Shared Instance. | `string` | n/a | yes |
| <a name="input_powervs_share_instance_name"></a> [powervs\_share\_instance\_name](#input\_powervs\_share\_instance\_name) | Name of instance which will be created | `string` | n/a | yes |
| <a name="input_powervs_share_memory_size"></a> [powervs\_share\_memory\_size](#input\_powervs\_share\_memory\_size) | Amount of memory | `string` | `2` | no |
| <a name="input_powervs_share_number_of_instances"></a> [powervs\_share\_number\_of\_instances](#input\_powervs\_share\_number\_of\_instances) | Number of instances | `string` | n/a | yes |
| <a name="input_powervs_share_number_of_processors"></a> [powervs\_share\_number\_of\_processors](#input\_powervs\_share\_number\_of\_processors) | Number of processors | `string` | `0.5` | no |
| <a name="input_powervs_share_server_type"></a> [powervs\_share\_server\_type](#input\_powervs\_share\_server\_type) | Processor type e980, s922, s1022 or e1080 | `string` | `"s922"` | no |
| <a name="input_powervs_share_storage_config"></a> [powervs\_share\_storage\_config](#input\_powervs\_share\_storage\_config) | File systems to be created and attached to PowerVS instance for shared storage file systems. 'disk\_sizes' are in GB. 'count' specify over how many storage volumes the file system will be striped. 'tiers' specifies the storage tier in PowerVS workspace. For creating multiple file systems, specify multiple entries in each parameter in the structure. E.g., for creating 2 file systems, specify 2 names, 2 disk sizes, 2 counts, 2 tiers and 2 paths. | <pre>object({<br>    names      = string<br>    disks_size = string<br>    counts     = string<br>    tiers      = string<br>    paths      = string<br>  })</pre> | <pre>{<br>  "counts": "",<br>  "disks_size": "",<br>  "names": "",<br>  "paths": "",<br>  "tiers": ""<br>}</pre> | no |
| <a name="input_powervs_sshkey_name"></a> [powervs\_sshkey\_name](#input\_powervs\_sshkey\_name) | Existing PowerVs SSH key name. | `string` | n/a | yes |
| <a name="input_powervs_workspace_name"></a> [powervs\_workspace\_name](#input\_powervs\_workspace\_name) | Existing Name of the PowerVS workspace. | `string` | n/a | yes |
| <a name="input_powervs_zone"></a> [powervs\_zone](#input\_powervs\_zone) | IBM Cloud PowerVS zone. | `string` | n/a | yes |
| <a name="input_proxy_host_or_ip_port"></a> [proxy\_host\_or\_ip\_port](#input\_proxy\_host\_or\_ip\_port) | Proxy hostname or IP address with port. E.g., 10.10.10.4:3128 <ip:port> | `string` | `""` | no |
| <a name="input_sap_domain"></a> [sap\_domain](#input\_sap\_domain) | Domain name to be set. | `string` | `""` | no |
| <a name="input_ssh_private_key"></a> [ssh\_private\_key](#input\_ssh\_private\_key) | Private SSH key used to login to IBM PowerVS instances. Should match to uploaded public SSH key referenced by 'powervs\_sshkey\_name'. | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_access_host_or_ip"></a> [access\_host\_or\_ip](#output\_access\_host\_or\_ip) | Public IP to manage the environment |
| <a name="output_hana_instance_private_ips"></a> [hana\_instance\_private\_ips](#output\_hana\_instance\_private\_ips) | Private IPs of the HANA instance. |
| <a name="output_netweaver_instance_private_ips"></a> [netweaver\_instance\_private\_ips](#output\_netweaver\_instance\_private\_ips) | Private IPs of all NetWeaver instances. |
| <a name="output_share_fs_instance_private_ips"></a> [share\_fs\_instance\_private\_ips](#output\_share\_fs\_instance\_private\_ips) | Private IPs of the Share FS instance. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

<!-- BEGIN CONTRIBUTING HOOK -->
## Contributing

You can report issues and request features for this module in GitHub issues in the module repo. See [Report an issue or request a feature](https://github.com/terraform-ibm-modules/.github/blob/main/.github/SUPPORT.md).

To set up your local development environment, see [Local development setup](https://terraform-ibm-modules.github.io/documentation/#/local-dev-setup) in the project documentation.
<!-- END CONTRIBUTING HOOK -->
