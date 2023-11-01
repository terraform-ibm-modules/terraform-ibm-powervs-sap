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
| <a name="module_ansible_sap_instance_init"></a> [ansible\_sap\_instance\_init](#module\_ansible\_sap\_instance\_init) | ../remote-exec-ansible | n/a |
| <a name="module_ansible_sharefs_instance_init"></a> [ansible\_sharefs\_instance\_init](#module\_ansible\_sharefs\_instance\_init) | ../remote-exec-ansible | n/a |
| <a name="module_pi_attach_sap_network"></a> [pi\_attach\_sap\_network](#module\_pi\_attach\_sap\_network) | terraform-ibm-modules/powervs-workspace/ibm//modules/pi-cloudconnection-attach | 1.1.3 |
| <a name="module_pi_hana_instance"></a> [pi\_hana\_instance](#module\_pi\_hana\_instance) | terraform-ibm-modules/powervs-instance/ibm | 1.0.2 |
| <a name="module_pi_hana_storage_calculation"></a> [pi\_hana\_storage\_calculation](#module\_pi\_hana\_storage\_calculation) | ../pi-hana-storage-config | n/a |
| <a name="module_pi_netweaver_instance"></a> [pi\_netweaver\_instance](#module\_pi\_netweaver\_instance) | terraform-ibm-modules/powervs-instance/ibm | 1.0.2 |
| <a name="module_pi_sharefs_instance"></a> [pi\_sharefs\_instance](#module\_pi\_sharefs\_instance) | terraform-ibm-modules/powervs-instance/ibm | 1.0.2 |

### Resources

| Name | Type |
|------|------|
| [ibm_pi_network.sap_network](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/pi_network) | resource |

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cloud_connection_count"></a> [cloud\_connection\_count](#input\_cloud\_connection\_count) | Existing number of Cloud connections to which new subnet must be attached. Will be ignored in case of PER enabled DC. | `string` | `2` | no |
| <a name="input_pi_hana_instance"></a> [pi\_hana\_instance](#input\_pi\_hana\_instance) | SAP HANA hostname (non FQDN) will get the form of <var.prefix>-<var.pi\_hana\_instance\_name>. SAP HANA profile to use. Must be one of the supported profiles. See [here](https://cloud.ibm.com/docs/sap?topic=sap-hana-iaas-offerings-profiles-power-vs). File system sizes are automatically calculated. Override automatic calculation by setting values in optional 'pi\_hana\_instance\_custom\_storage\_config' parameter. Additional File systems to be created and attached to PowerVS instance for SAP HANA. 'size' is in GB. 'count' specify over how many storage volumes the file system will be striped. 'tier' specifies the storage tier in PowerVS workspace. 'mount' specifies the target mount point on OS. | <pre>object({<br>    name           = string<br>    image_id       = string<br>    sap_profile_id = string<br>    additional_storage_config = list(object({<br>      name  = string<br>      size  = string<br>      count = string<br>      tier  = string<br>      mount = string<br>    }))<br>  })</pre> | <pre>{<br>  "additional_storage_config": [<br>    {<br>      "count": "1",<br>      "mount": "/usr/sap",<br>      "name": "usrsap",<br>      "size": "50",<br>      "tier": "tier3"<br>    }<br>  ],<br>  "image_id": "insert_value_here",<br>  "name": "hana",<br>  "sap_profile_id": "ush1-4x256"<br>}</pre> | no |
| <a name="input_pi_hana_instance_custom_storage_config"></a> [pi\_hana\_instance\_custom\_storage\_config](#input\_pi\_hana\_instance\_custom\_storage\_config) | Custom File systems to be created and attached to PowerVS instance for SAP HANA. 'size' is in GB. 'count' specify over how many storage volumes the file system will be striped. 'tier' specifies the storage tier in PowerVS workspace. 'mount' specifies the target mount point on OS. | <pre>list(object({<br>    name  = string<br>    size  = string<br>    count = string<br>    tier  = string<br>    mount = string<br>  }))</pre> | <pre>[<br>  {<br>    "count": "",<br>    "mount": "",<br>    "name": "",<br>    "size": "",<br>    "tier": ""<br>  }<br>]</pre> | no |
| <a name="input_pi_instance_init_linux"></a> [pi\_instance\_init\_linux](#input\_pi\_instance\_init\_linux) | Configures a PowerVS linux instance to have internet access by setting proxy on it, updates os and create filesystems using ansible collection [ibm.power\_linux\_sap collection](https://galaxy.ansible.com/ui/repo/published/ibm/power_linux_sap/). where 'proxy\_host\_or\_ip\_port' E.g., 10.10.10.4:3128 <ip:port>, 'bastion\_host\_ip' is public IP of bastion/jump host to access the private IP of created linux PowerVS instance. | <pre>object(<br>    {<br>      enable                = bool<br>      bastion_host_ip       = string<br>      ssh_private_key       = string<br>      proxy_host_or_ip_port = string<br>      no_proxy_hosts        = string<br>    }<br>  )</pre> | n/a | yes |
| <a name="input_pi_netweaver_instance"></a> [pi\_netweaver\_instance](#input\_pi\_netweaver\_instance) | 'instance\_count' is number of SAP NetWeaver instances that should be created. 'size' is in GB. 'count' specify over how many storage volumes the file system will be striped. 'tier' specifies the storage tier in PowerVS workspace. 'mount' specifies the target mount point on OS. | <pre>object({<br>    instance_count = number<br>    name           = string<br>    image_id       = string<br>    processors     = string<br>    memory         = string<br>    proc_type      = string<br>    storage_config = list(object({<br>      name  = string<br>      size  = string<br>      count = string<br>      tier  = string<br>      mount = string<br>    }))<br>  })</pre> | <pre>{<br>  "image_id": null,<br>  "instance_count": 1,<br>  "memory": "2",<br>  "name": "nw",<br>  "proc_type": "shared",<br>  "processors": "0.5",<br>  "storage_config": [<br>    {<br>      "count": "1",<br>      "mount": "/usr/sap",<br>      "name": "usrsap",<br>      "size": "50",<br>      "tier": "tier3"<br>    }<br>  ]<br>}</pre> | no |
| <a name="input_pi_networks"></a> [pi\_networks](#input\_pi\_networks) | Existing list of subnets to be attached to PowerVS instances. The first element will become the primary interface. Run 'ibmcloud pi networks' to list available private subnets. | <pre>list(<br>    object({<br>      name = string<br>      id   = string<br>      cidr = optional(string)<br>    })<br>  )</pre> | n/a | yes |
| <a name="input_pi_sap_network_cidr"></a> [pi\_sap\_network\_cidr](#input\_pi\_sap\_network\_cidr) | Additional private subnet for SAP communication which will be created. CIDR for SAP network. E.g., '10.53.1.0/24' | `string` | `"10.53.1.0/24"` | no |
| <a name="input_pi_sharefs_instance"></a> [pi\_sharefs\_instance](#input\_pi\_sharefs\_instance) | Deploy separate IBM PowerVS instance as central file system share. All filesystems defined in 'pi\_sharefs\_instance\_storage\_config' variable will be NFS exported and mounted on Netweaver PowerVS instances if enabled. 'size' is in GB. 'count' specify over how many storage volumes the file system will be striped. 'tier' specifies the storage tier in PowerVS workspace. 'mount' specifies the target mount point on OS. | <pre>object({<br>    enable     = bool<br>    name       = string<br>    image_id   = string<br>    processors = string<br>    memory     = string<br>    proc_type  = string<br>    storage_config = list(object({<br>      name  = string<br>      size  = string<br>      count = string<br>      tier  = string<br>      mount = string<br>    }))<br>  })</pre> | <pre>{<br>  "enable": false,<br>  "image_id": "insert_value_here",<br>  "memory": "2",<br>  "name": "share",<br>  "proc_type": "shared",<br>  "processors": "0.5",<br>  "storage_config": [<br>    {<br>      "count": "1",<br>      "mount": "/sapmnt",<br>      "name": "sapmnt",<br>      "size": "300",<br>      "tier": "tier3"<br>    },<br>    {<br>      "count": "1",<br>      "mount": "/usr/trans",<br>      "name": "trans",<br>      "size": "50",<br>      "tier": "tier3"<br>    }<br>  ]<br>}</pre> | no |
| <a name="input_pi_ssh_public_key_name"></a> [pi\_ssh\_public\_key\_name](#input\_pi\_ssh\_public\_key\_name) | Existing PowerVS SSH Public Key Name. | `string` | n/a | yes |
| <a name="input_pi_workspace_guid"></a> [pi\_workspace\_guid](#input\_pi\_workspace\_guid) | PowerVS infrastructure workspace guid. The GUID of the resource instance. | `string` | n/a | yes |
| <a name="input_pi_zone"></a> [pi\_zone](#input\_pi\_zone) | IBM Cloud data center location where IBM PowerVS Workspace exists. | `string` | n/a | yes |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | Unique prefix for resources to be created (e.g., SAP system name). Max length must be less than or equal to 6. | `string` | n/a | yes |
| <a name="input_sap_domain"></a> [sap\_domain](#input\_sap\_domain) | SAP domain to be set for entire landscape. | `string` | `"sap.com"` | no |
| <a name="input_sap_network_services_config"></a> [sap\_network\_services\_config](#input\_sap\_network\_services\_config) | Configures network services NTP, NFS and DNS on PowerVS instance. Requires 'pi\_instance\_init\_linux' to be specified as internet access is required to download ansible collection [ibm.power\_linux\_sap collection](https://galaxy.ansible.com/ui/repo/published/ibm/power_linux_sap/) to configure these services. | <pre>object(<br>    {<br>      nfs = object({ enable = bool, nfs_server_path = string, nfs_client_path = string })<br>      dns = object({ enable = bool, dns_server_ip = string })<br>      ntp = object({ enable = bool, ntp_server_ip = string })<br>    }<br>  )</pre> | <pre>{<br>  "dns": {<br>    "dns_server_ip": "",<br>    "enable": false<br>  },<br>  "nfs": {<br>    "enable": false,<br>    "nfs_client_path": "",<br>    "nfs_server_path": ""<br>  },<br>  "ntp": {<br>    "enable": false,<br>    "ntp_server_ip": ""<br>  }<br>}</pre> | no |

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
| <a name="output_pi_sharefs_ips"></a> [pi\_sharefs\_ips](#output\_pi\_sharefs\_ips) | Private IPs of the Share FS instance. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
