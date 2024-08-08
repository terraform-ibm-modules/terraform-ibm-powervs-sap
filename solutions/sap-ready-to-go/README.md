# Power Virtual Server for SAP HANA: 'sap-ready-to-go'

The 'sap-ready-to-go' solution automates the following tasks:

- Creates a new private subnet for SAP communication for the entire landscape.
- Creates and configures one PowerVS instance for SAP HANA based on best practices.
- Creates and configures multiple PowerVS instances for SAP NetWeaver based on best practices.
- Creates and configures one optional PowerVS instance for sharing SAP files between other system instances.
- Connects all created PowerVS instances to a proxy server specified by IP address or hostname.
- Optionally connects all created PowerVS instances to an NTP server and DNS forwarder specified by IP address or hostname.
- Optionally configures a shared NFS directory on all created PowerVS instances.
- Post-instance provisioning, Ansible Galaxy collection roles from [IBM](https://galaxy.ansible.com/ui/repo/published/ibm/power_linux_sap/) are executed: `power_linux_sap`.
- Tested with RHEL8.4,/8.6/8.8/9.2, SLES15-SP3/SP5 images.


## Before you begin
- Power Virtual Server Workspace, images, management subnet, and SSH key must exist. This solution does not create these resources.

## Notes
- **Does not install any SAP software or solutions.**
- Filesystem sizes for HANA data and HANA log are **calculated automatically** based on the **memory size**.
- Custom storage configuration by providing custom volume size, **iops**(tier0, tier1, tier3, tier5k), counts and mount points is supported
- If **sharefs instance is enabled**, then all filesystems provisioned for sharefs instance will be **NFS exported and mounted** on all NetWeaver Instances.
- **Do not specify** a filesystem `/sapmnt` explicitly for NetWeaver instance as, it is created internally when sharefs instance is not enabled.


|                                  Variation                                  | Available on IBM Catalog | Requires Schematics Workspace ID | Creates PowerVS with VPC landing zone | Creates PowerVS HANA Instance | Creates PowerVS NW Instances | Performs PowerVS OS Config | Performs PowerVS SAP Tuning | Install SAP software |
|:---------------------------------------------------------------------------:|:------------------------:|:--------------------------------:|:-------------------------------------:|:-----------------------------:|:----------------------------:|:--------------------------:|:---------------------------:|:--------------------:|
|             [ sap-ready-to-go ](./)             |            N/A           |                N/A               |                  N/A                  |               1               |            0 to N            |     :heavy_check_mark:     |      :heavy_check_mark:     |          N/A         |

## Architecture Diagram
![sap-ready-to-go](https://github.com/terraform-ibm-modules/terraform-ibm-powervs-sap/blob/main/reference-architectures/sap-ready-to-go/deploy-arch-ibm-pvs-sap-ready-to-go.svg)

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
### Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3 |
| <a name="requirement_ibm"></a> [ibm](#requirement\_ibm) | >= 1.68.0 |

### Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_sap_system"></a> [sap\_system](#module\_sap\_system) | ../../modules/pi-sap-system-type1 | n/a |

### Resources

No resources.

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_ibmcloud_api_key"></a> [ibmcloud\_api\_key](#input\_ibmcloud\_api\_key) | The IBM Cloud platform API key needed to deploy IAM enabled resources. | `string` | n/a | yes |
| <a name="input_powervs_create_sharefs_instance"></a> [powervs\_create\_sharefs\_instance](#input\_powervs\_create\_sharefs\_instance) | Deploy separate IBM PowerVS instance as central file system share. All filesystems defined in 'powervs\_sharefs\_instance\_storage\_config' variable will be NFS exported and mounted on SAP NetWeaver PowerVS instances if enabled. Optional parameter 'powervs\_share\_fs\_instance' can be configured if enabled. | <pre>object({<br>    enable   = bool<br>    image_id = string<br>  })</pre> | n/a | yes |
| <a name="input_powervs_hana_instance"></a> [powervs\_hana\_instance](#input\_powervs\_hana\_instance) | PowerVS SAP HANA instance hostname (non FQDN) will get the form of <var.prefix>-<var.powervs\_hana\_instance\_name>. PowerVS SAP HANA instance profile to use. Must be one of the supported profiles. See [here](https://cloud.ibm.com/docs/sap?topic=sap-hana-iaas-offerings-profiles-power-vs). File system sizes are automatically calculated. Override automatic calculation by setting values in optional 'powervs\_hana\_instance\_custom\_storage\_config' parameter. Additional File systems to be created and attached to PowerVS instance for SAP HANA. 'size' is in GB. 'count' specify over how many storage volumes the file system will be striped. 'tier' specifies the storage tier in PowerVS workspace. 'mount' specifies the target mount point on OS. | <pre>object({<br>    name           = string<br>    sap_profile_id = string<br>    additional_storage_config = list(object({<br>      name  = string<br>      size  = string<br>      count = string<br>      tier  = string<br>      mount = string<br>      pool  = optional(string)<br>    }))<br>  })</pre> | <pre>{<br>  "additional_storage_config": [<br>    {<br>      "count": "1",<br>      "mount": "/usr/sap",<br>      "name": "usrsap",<br>      "size": "50",<br>      "tier": "tier3"<br>    }<br>  ],<br>  "name": "hana",<br>  "sap_profile_id": "ush1-4x256"<br>}</pre> | no |
| <a name="input_powervs_hana_instance_custom_storage_config"></a> [powervs\_hana\_instance\_custom\_storage\_config](#input\_powervs\_hana\_instance\_custom\_storage\_config) | Custom file systems to be created and attached to PowerVS SAP HANA instance. 'size' is in GB. 'count' specify over how many storage volumes the file system will be striped. 'tier' specifies the storage tier in PowerVS workspace. 'mount' specifies the target mount point on OS. | <pre>list(object({<br>    name  = string<br>    size  = string<br>    count = string<br>    tier  = string<br>    mount = string<br>    pool  = optional(string)<br>  }))</pre> | <pre>[<br>  {<br>    "count": "",<br>    "mount": "",<br>    "name": "",<br>    "size": "",<br>    "tier": ""<br>  }<br>]</pre> | no |
| <a name="input_powervs_hana_instance_image_id"></a> [powervs\_hana\_instance\_image\_id](#input\_powervs\_hana\_instance\_image\_id) | Image ID to be used for PowerVS HANA instance. Run 'ibmcloud pi images' to list available images. | `string` | n/a | yes |
| <a name="input_powervs_instance_init_linux"></a> [powervs\_instance\_init\_linux](#input\_powervs\_instance\_init\_linux) | Configures a PowerVS linux instance to have internet access by setting proxy on it, updates os and create filesystems using ansible collection [ibm.power\_linux\_sap collection](https://galaxy.ansible.com/ui/repo/published/ibm/power_linux_sap/) where 'bastion\_host\_ip' is public IP of bastion/jump host to access the 'ansible\_host\_or\_ip' private IP of ansible node. This ansible host must have access to the power virtual server instance and ansible host OS must be RHEL distribution. | <pre>object(<br>    {<br>      enable             = bool<br>      bastion_host_ip    = string<br>      ansible_host_or_ip = string<br>      ssh_private_key    = string<br>    }<br>  )</pre> | n/a | yes |
| <a name="input_powervs_netweaver_instance"></a> [powervs\_netweaver\_instance](#input\_powervs\_netweaver\_instance) | PowerVS SAP NetWeaver instance hostname (non FQDN). Will get the form of <var.prefix>-<var.powervs\_netweaver\_instance\_name>-<number>. Max length of final hostname must be <= 13 characters.. 'instance\_count' is number of PowerVS SAP NetWeaver instances that should be created. 'size' is in GB. 'count' specify over how many storage volumes the file system will be striped. 'tier' specifies the storage tier in PowerVS workspace. 'mount' specifies the target mount point on OS. | <pre>object({<br>    instance_count = number<br>    name           = string<br>    processors     = string<br>    memory         = string<br>    proc_type      = string<br>    storage_config = list(object({<br>      name  = string<br>      size  = string<br>      count = string<br>      tier  = string<br>      mount = string<br>      pool  = optional(string)<br>    }))<br>  })</pre> | <pre>{<br>  "instance_count": 1,<br>  "memory": "32",<br>  "name": "nw",<br>  "proc_type": "shared",<br>  "processors": "3",<br>  "storage_config": [<br>    {<br>      "count": "1",<br>      "mount": "/usr/sap",<br>      "name": "usrsap",<br>      "size": "50",<br>      "tier": "tier3"<br>    }<br>  ]<br>}</pre> | no |
| <a name="input_powervs_netweaver_instance_image_id"></a> [powervs\_netweaver\_instance\_image\_id](#input\_powervs\_netweaver\_instance\_image\_id) | Image ID to be used for PowerVS NetWeaver instance. Run 'ibmcloud pi images' to list available images. | `string` | n/a | yes |
| <a name="input_powervs_networks"></a> [powervs\_networks](#input\_powervs\_networks) | Existing list of subnets to be attached to PowerVS instances. The first element will become the primary interface. Run 'ibmcloud pi networks' to list available private subnets. | <pre>list(<br>    object({<br>      name = string<br>      id   = string<br>      cidr = optional(string)<br>    })<br>  )</pre> | n/a | yes |
| <a name="input_powervs_sap_network_cidr"></a> [powervs\_sap\_network\_cidr](#input\_powervs\_sap\_network\_cidr) | Network range for dedicated SAP network. Used for communication between SAP Application servers with SAP HANA Database. E.g., '10.53.0.0/24' | `string` | n/a | yes |
| <a name="input_powervs_sharefs_instance"></a> [powervs\_sharefs\_instance](#input\_powervs\_sharefs\_instance) | Deploy separate IBM PowerVS instance as central file system share. All filesystems defined in 'powervs\_sharefs\_instance\_storage\_config' variable will be NFS exported and mounted on NetWeaver PowerVS instances if enabled. 'size' is in GB. 'count' specify over how many storage volumes the file system will be striped. 'tier' specifies the storage tier in PowerVS workspace. 'mount' specifies the target mount point on OS. | <pre>object({<br>    name       = string<br>    processors = string<br>    memory     = string<br>    proc_type  = string<br>    storage_config = list(object({<br>      name  = string<br>      size  = string<br>      count = string<br>      tier  = string<br>      mount = string<br>      pool  = optional(string)<br>    }))<br>  })</pre> | <pre>{<br>  "memory": "2",<br>  "name": "share",<br>  "proc_type": "shared",<br>  "processors": "0.5",<br>  "storage_config": [<br>    {<br>      "count": "1",<br>      "mount": "/sapmnt",<br>      "name": "sapmnt",<br>      "size": "300",<br>      "tier": "tier3"<br>    },<br>    {<br>      "count": "1",<br>      "mount": "/usr/trans",<br>      "name": "trans",<br>      "size": "50",<br>      "tier": "tier3"<br>    }<br>  ]<br>}</pre> | no |
| <a name="input_powervs_ssh_public_key_name"></a> [powervs\_ssh\_public\_key\_name](#input\_powervs\_ssh\_public\_key\_name) | Existing PowerVS SSH Public Key Name. | `string` | n/a | yes |
| <a name="input_powervs_workspace_guid"></a> [powervs\_workspace\_guid](#input\_powervs\_workspace\_guid) | PowerVS infrastructure workspace guid. The GUID of the resource instance. | `string` | n/a | yes |
| <a name="input_powervs_zone"></a> [powervs\_zone](#input\_powervs\_zone) | IBM Cloud data center location where IBM PowerVS Workspace exists. | `string` | n/a | yes |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | Unique prefix for resources to be created (e.g., SAP system name). Max length must be less than or equal to 6. | `string` | n/a | yes |
| <a name="input_sap_domain"></a> [sap\_domain](#input\_sap\_domain) | SAP network domain name. | `string` | `"sap.com"` | no |
| <a name="input_sap_network_services_config"></a> [sap\_network\_services\_config](#input\_sap\_network\_services\_config) | Configures network services NTP, NFS and DNS on PowerVS instance. Requires 'pi\_instance\_init\_linux' to be specified. | <pre>object(<br>    {<br>      squid = object({ enable = bool, squid_server_ip_port = string, no_proxy_hosts = string })<br>      nfs   = object({ enable = bool, nfs_server_path = string, nfs_client_path = string, opts = string, fstype = string })<br>      dns   = object({ enable = bool, dns_server_ip = string })<br>      ntp   = object({ enable = bool, ntp_server_ip = string })<br>    }<br>  )</pre> | <pre>{<br>  "dns": {<br>    "dns_server_ip": "",<br>    "enable": false<br>  },<br>  "nfs": {<br>    "enable": false,<br>    "fstype": "",<br>    "nfs_client_path": "",<br>    "nfs_server_path": "",<br>    "opts": ""<br>  },<br>  "ntp": {<br>    "enable": false,<br>    "ntp_server_ip": ""<br>  },<br>  "squid": {<br>    "enable": false,<br>    "no_proxy_hosts": "",<br>    "squid_server_ip_port": ""<br>  }<br>}</pre> | no |

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
