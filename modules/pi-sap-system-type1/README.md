# Module pi-sap-system-type1

The Power Virtual Server for SAP module automates the following tasks:

- Creates a private subnet for SAP communication for the entire landscape.
- Creates and configures one PowerVS instance for SAP HANA based on best practices.
- Creates and configures multiple PowerVS instances for SAP NetWeaver based on best practices.
- Creates and configures one optional PowerVS instance (sharefs) that can be used for sharing SAP files between other system instances.
- Connects all created PowerVS instances to a proxy server specified by IP address or hostname.
- Optionally connects all created PowerVS instances to an NTP server and DNS forwarder specified by IP address or hostname.
- Optionally configures a shared NFS directory on all created PowerVS instances.
- Post-instance provisioning, Ansible Galaxy collection roles from [IBM](https://galaxy.ansible.com/ui/repo/published/ibm/power_linux_sap/) are executed: `power_linux_sap`.
- Tested with RHEL8.4,/8.6/8.8/9.2, SLES15-SP3/SP5 images.

## Notes:
- **Does not install any SAP softwares or solutions.**
- Filesystem sizes for HANA data and HANA log are **calculated automatically** based on the **memory size**. Custom storage configuration is also supported.
- If **sharefs instance is enabled**, then all filesystems provisioned for sharefs instance will be **NFS exported and mounted** on all NetWeaver Instances.
- **Do not specify** a filesystem `/sapmnt` explicitly for NetWeaver instance as, it is created internally when sharefs instance is not enabled.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
### Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9.0 |
| <a name="requirement_ibm"></a> [ibm](#requirement\_ibm) | >= 1.71.3 |
| <a name="requirement_time"></a> [time](#requirement\_time) | >= 0.9.1 |

### Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_ansible_netweaver_sapmnt_mount"></a> [ansible\_netweaver\_sapmnt\_mount](#module\_ansible\_netweaver\_sapmnt\_mount) | ../ansible | n/a |
| <a name="module_ansible_sap_instance_init"></a> [ansible\_sap\_instance\_init](#module\_ansible\_sap\_instance\_init) | ../ansible | n/a |
| <a name="module_ansible_sharefs_instance_exportfs"></a> [ansible\_sharefs\_instance\_exportfs](#module\_ansible\_sharefs\_instance\_exportfs) | ../ansible | n/a |
| <a name="module_configure_scc_wp_agent"></a> [configure\_scc\_wp\_agent](#module\_configure\_scc\_wp\_agent) | ..//ansible | n/a |
| <a name="module_pi_hana_instance"></a> [pi\_hana\_instance](#module\_pi\_hana\_instance) | terraform-ibm-modules/powervs-instance/ibm | 2.4.1 |
| <a name="module_pi_hana_storage_calculation"></a> [pi\_hana\_storage\_calculation](#module\_pi\_hana\_storage\_calculation) | ../pi-hana-storage-config | n/a |
| <a name="module_pi_netweaver_instance"></a> [pi\_netweaver\_instance](#module\_pi\_netweaver\_instance) | terraform-ibm-modules/powervs-instance/ibm | 2.4.1 |
| <a name="module_pi_sharefs_instance"></a> [pi\_sharefs\_instance](#module\_pi\_sharefs\_instance) | terraform-ibm-modules/powervs-instance/ibm | 2.4.1 |

### Resources

| Name | Type |
|------|------|
| [ibm_pi_network.sap_network](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/pi_network) | resource |
| [time_sleep.wait_1_min](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/sleep) | resource |

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_ansible_vault_password"></a> [ansible\_vault\_password](#input\_ansible\_vault\_password) | Vault password to encrypt OS registration parameters. Only required with customer provided linux subscription (pi\_os\_registration). Password requirements: 15-100 characters and at least one uppercase letter, one lowercase letter, one number, and one special character. Allowed characters: A-Z, a-z, 0-9, !#$%&()*+-.:;<=>?@[]\_{\|}~. | `string` | `null` | no |
| <a name="input_pi_hana_instance"></a> [pi\_hana\_instance](#input\_pi\_hana\_instance) | PowerVS SAP HANA instance hostname (non FQDN). Will get the form of <var.prefix>-<var.powervs\_hana\_instance\_name>. Max length of final hostname must be <= 13 characters.'sap\_profile\_id' Must be one of the supported profiles. See [here](https://cloud.ibm.com/docs/sap?topic=sap-hana-iaas-offerings-profiles-power-vs). File system sizes are automatically calculated. Override automatic calculation by setting values in optional 'pi\_hana\_instance\_custom\_storage\_config' parameter. 'additional\_storage\_config' additional File systems to be created and attached to PowerVS SAP HANA instance. 'size' is in GB. 'count' specify over how many storage volumes the file system will be striped. 'tier' specifies the storage tier in PowerVS workspace. 'mount' specifies the target mount point on OS. | <pre>object({<br/>    name           = string<br/>    image_id       = string<br/>    sap_profile_id = string<br/>    additional_storage_config = list(object({<br/>      name  = string<br/>      size  = string<br/>      count = string<br/>      tier  = string<br/>      mount = string<br/>    }))<br/>  })</pre> | <pre>{<br/>  "additional_storage_config": [<br/>    {<br/>      "count": "1",<br/>      "mount": "/usr/sap",<br/>      "name": "usrsap",<br/>      "size": "50",<br/>      "tier": "tier3"<br/>    }<br/>  ],<br/>  "image_id": "insert_value_here",<br/>  "name": "hana",<br/>  "sap_profile_id": "ush1-4x256"<br/>}</pre> | no |
| <a name="input_pi_hana_instance_custom_storage_config"></a> [pi\_hana\_instance\_custom\_storage\_config](#input\_pi\_hana\_instance\_custom\_storage\_config) | Custom file systems to be created and attached to PowerVS SAP HANA instance. 'size' is in GB. 'count' specify over how many storage volumes the file system will be striped. 'tier' specifies the storage tier in PowerVS workspace. 'mount' specifies the target mount point on OS. | <pre>list(object({<br/>    name  = string<br/>    size  = string<br/>    count = string<br/>    tier  = string<br/>    mount = string<br/>  }))</pre> | <pre>[<br/>  {<br/>    "count": "",<br/>    "mount": "",<br/>    "name": "",<br/>    "size": "",<br/>    "tier": ""<br/>  }<br/>]</pre> | no |
| <a name="input_pi_instance_init_linux"></a> [pi\_instance\_init\_linux](#input\_pi\_instance\_init\_linux) | Configures a PowerVS linux instance to have internet access by setting proxy on it, updates os and create filesystems using ansible collection [ibm.power\_linux\_sap collection](https://galaxy.ansible.com/ui/repo/published/ibm/power_linux_sap/) where 'bastion\_host\_ip' is public IP of bastion/jump host to access the 'ansible\_host\_or\_ip' private IP of ansible node. This ansible host must have access to the power virtual server instance and ansible host OS must be RHEL distribution. | <pre>object(<br/>    {<br/>      enable             = bool<br/>      bastion_host_ip    = string<br/>      ansible_host_or_ip = string<br/>      ssh_private_key    = string<br/>      custom_os_registration = optional(object({<br/>        username = string<br/>        password = string<br/>      }))<br/>    }<br/>  )</pre> | n/a | yes |
| <a name="input_pi_netweaver_instance"></a> [pi\_netweaver\_instance](#input\_pi\_netweaver\_instance) | PowerVS SAP NetWeaver instance hostname (non FQDN). Will get the form of <var.prefix>-<var.powervs\_netweaver\_instance\_name>-<number>. Max length of final hostname must be <= 13 characters. 'instance\_count' is number of SAP NetWeaver instances that should be created. 'size' is in GB. 'count' specify over how many storage volumes the file system will be striped. 'tier' specifies the storage tier in PowerVS workspace. 'mount' specifies the target mount point on OS. | <pre>object({<br/>    instance_count = number<br/>    name           = string<br/>    image_id       = string<br/>    processors     = string<br/>    memory         = string<br/>    proc_type      = string<br/>    storage_config = list(object({<br/>      name  = string<br/>      size  = string<br/>      count = string<br/>      tier  = string<br/>      mount = string<br/>    }))<br/>  })</pre> | <pre>{<br/>  "image_id": "insert_value_here",<br/>  "instance_count": 1,<br/>  "memory": "32",<br/>  "name": "nw",<br/>  "proc_type": "shared",<br/>  "processors": "3",<br/>  "storage_config": [<br/>    {<br/>      "count": "1",<br/>      "mount": "/usr/sap",<br/>      "name": "usrsap",<br/>      "size": "50",<br/>      "tier": "tier3"<br/>    }<br/>  ]<br/>}</pre> | no |
| <a name="input_pi_networks"></a> [pi\_networks](#input\_pi\_networks) | Existing list of subnets to be attached to PowerVS instances. The first element will become the primary interface. Run 'ibmcloud pi networks' to list available private subnets. | <pre>list(<br/>    object({<br/>      name = string<br/>      id   = string<br/>      cidr = optional(string)<br/>    })<br/>  )</pre> | n/a | yes |
| <a name="input_pi_sap_network_cidr"></a> [pi\_sap\_network\_cidr](#input\_pi\_sap\_network\_cidr) | Additional private subnet for SAP communication which will be created. CIDR for SAP network. E.g., '10.53.0.0/24' | `string` | `"10.53.0.0/24"` | no |
| <a name="input_pi_sharefs_instance"></a> [pi\_sharefs\_instance](#input\_pi\_sharefs\_instance) | Deploy separate IBM PowerVS instance as central file system share. All filesystems defined in 'pi\_sharefs\_instance\_storage\_config' variable will be NFS exported and mounted on NetWeaver PowerVS instances if enabled. 'size' is in GB. 'count' specify over how many storage volumes the file system will be striped. 'tier' specifies the storage tier in PowerVS workspace. 'mount' specifies the target mount point on OS. | <pre>object({<br/>    enable     = bool<br/>    name       = string<br/>    image_id   = string<br/>    processors = string<br/>    memory     = string<br/>    proc_type  = string<br/>    storage_config = list(object({<br/>      name  = string<br/>      size  = string<br/>      count = string<br/>      tier  = string<br/>      mount = string<br/>    }))<br/>  })</pre> | <pre>{<br/>  "enable": false,<br/>  "image_id": "insert_value_here",<br/>  "memory": "2",<br/>  "name": "share",<br/>  "proc_type": "shared",<br/>  "processors": "0.5",<br/>  "storage_config": [<br/>    {<br/>      "count": "1",<br/>      "mount": "/sapmnt",<br/>      "name": "sapmnt",<br/>      "size": "300",<br/>      "tier": "tier3"<br/>    },<br/>    {<br/>      "count": "1",<br/>      "mount": "/usr/trans",<br/>      "name": "trans",<br/>      "size": "50",<br/>      "tier": "tier3"<br/>    }<br/>  ]<br/>}</pre> | no |
| <a name="input_pi_ssh_public_key_name"></a> [pi\_ssh\_public\_key\_name](#input\_pi\_ssh\_public\_key\_name) | Existing PowerVS SSH Public Key Name. | `string` | n/a | yes |
| <a name="input_pi_workspace_guid"></a> [pi\_workspace\_guid](#input\_pi\_workspace\_guid) | PowerVS infrastructure workspace guid. The GUID of the resource instance. | `string` | n/a | yes |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | Unique prefix for resources to be created (e.g., SAP system name). | `string` | n/a | yes |
| <a name="input_sap_domain"></a> [sap\_domain](#input\_sap\_domain) | SAP network domain name. | `string` | `"sap.com"` | no |
| <a name="input_sap_network_services_config"></a> [sap\_network\_services\_config](#input\_sap\_network\_services\_config) | Configures network services NTP, NFS and DNS on PowerVS instance. Requires 'pi\_instance\_init\_linux' to be specified. | <pre>object(<br/>    {<br/>      squid = object({ enable = bool, squid_server_ip_port = string, no_proxy_hosts = string })<br/>      nfs   = object({ enable = bool, nfs_server_path = string, nfs_client_path = string, opts = string, fstype = string })<br/>      dns   = object({ enable = bool, dns_server_ip = string })<br/>      ntp   = object({ enable = bool, ntp_server_ip = string })<br/>    }<br/>  )</pre> | <pre>{<br/>  "dns": {<br/>    "dns_server_ip": "",<br/>    "enable": false<br/>  },<br/>  "nfs": {<br/>    "enable": false,<br/>    "fstype": "",<br/>    "nfs_client_path": "",<br/>    "nfs_server_path": "",<br/>    "opts": ""<br/>  },<br/>  "ntp": {<br/>    "enable": false,<br/>    "ntp_server_ip": ""<br/>  },<br/>  "squid": {<br/>    "enable": false,<br/>    "no_proxy_hosts": "",<br/>    "squid_server_ip_port": ""<br/>  }<br/>}</pre> | no |
| <a name="input_scc_wp_instance"></a> [scc\_wp\_instance](#input\_scc\_wp\_instance) | SCC Workload Protection instance to connect to. Leave empty to not use it. | `any` | `null` | no |

### Outputs

| Name | Description |
|------|-------------|
| <a name="output_access_host_or_ip"></a> [access\_host\_or\_ip](#output\_access\_host\_or\_ip) | Public IP of Provided Bastion/JumpServer Host |
| <a name="output_pi_hana_instance_ips"></a> [pi\_hana\_instance\_ips](#output\_pi\_hana\_instance\_ips) | All private IPS of HANA instance |
| <a name="output_pi_hana_instance_management_ip"></a> [pi\_hana\_instance\_management\_ip](#output\_pi\_hana\_instance\_management\_ip) | Management IP of HANA Instance |
| <a name="output_pi_hana_instance_sap_ip"></a> [pi\_hana\_instance\_sap\_ip](#output\_pi\_hana\_instance\_sap\_ip) | SAP IP of PowerVS HANA Instance |
| <a name="output_pi_lpars_data"></a> [pi\_lpars\_data](#output\_pi\_lpars\_data) | All private IPS of PowerVS instances and Jump IP to access the host. |
| <a name="output_pi_netweaver_instance_ips"></a> [pi\_netweaver\_instance\_ips](#output\_pi\_netweaver\_instance\_ips) | All private IPS of NetWeaver instances |
| <a name="output_pi_netweaver_instance_management_ips"></a> [pi\_netweaver\_instance\_management\_ips](#output\_pi\_netweaver\_instance\_management\_ips) | Management IPS of NetWeaver instances |
| <a name="output_pi_sharefs_instance_ips"></a> [pi\_sharefs\_instance\_ips](#output\_pi\_sharefs\_instance\_ips) | Private IPs of the Share FS instance. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
