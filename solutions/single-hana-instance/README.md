# Provisioning a single tuned Power Virtual Server for SAP HANA

This example deploys a single Power Virtual Server instance that is tuned and ready to host an SAP HANA database.

It provisions the following components in IBM Cloud:

* Creates an IBM® Power Virtual Server instance in an existing PowerVS workspace (which contains a public SSH key, a pre-existing subnet, and a pre-imported OS image).
* Creates and attaches volumes to the instance.
* Automatically creates the required file systems for SAP HANA.
* Provides an option for users to define a custom storage configuration if needed.
* (Optional) Initializes the instance by configuring proxy settings and network services (NTP, DNS, NFS).
* (Optional) Tunes the OS for SAP HANA.
* Supports bring-your-own-license (BYOL) for RHEL/SLES images.
* Does **not** install SAP HANA.



<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
### Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9.0 |
| <a name="requirement_ibm"></a> [ibm](#requirement\_ibm) | 1.86.1 |

### Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_configure_os_for_sap"></a> [configure\_os\_for\_sap](#module\_configure\_os\_for\_sap) | ../../modules/ansible | n/a |
| <a name="module_hana_storage_calculation"></a> [hana\_storage\_calculation](#module\_hana\_storage\_calculation) | ../../modules/pi-hana-storage-config | n/a |
| <a name="module_sap_hana_instance"></a> [sap\_hana\_instance](#module\_sap\_hana\_instance) | terraform-ibm-modules/powervs-instance/ibm | 2.8.5 |

### Resources

No resources.

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_ansible_vault_password"></a> [ansible\_vault\_password](#input\_ansible\_vault\_password) | Vault password to encrypt ansible playbooks that contain sensitive information. Required with customer provided linux subscription (powervs\_os\_registration). Password requirements: 15-100 characters and at least one uppercase letter, one lowercase letter, one number, and one special character. Allowed characters: A-Z, a-z, 0-9, !#$%&()*+-.:;<=>?@[]\_{\|}~. | `string` | `""` | no |
| <a name="input_ibmcloud_api_key"></a> [ibmcloud\_api\_key](#input\_ibmcloud\_api\_key) | The IBM Cloud platform API key needed to deploy IAM enabled resources. | `string` | n/a | yes |
| <a name="input_powervs_boot_image_storage_tier"></a> [powervs\_boot\_image\_storage\_tier](#input\_powervs\_boot\_image\_storage\_tier) | Storage type for server deployment. If storage type is not provided the storage type will default to tier3. Possible values tier0, tier1 and tier3 | `string` | `null` | no |
| <a name="input_powervs_deployment_target"></a> [powervs\_deployment\_target](#input\_powervs\_deployment\_target) | The deployment of a dedicated host. Max items: 1, id is the uuid of the host group or host. type is the deployment target type, supported values are host and hostGroup | <pre>list(object(<br/>    {<br/>      type = string<br/>      id   = string<br/>    }<br/>  ))</pre> | `null` | no |
| <a name="input_powervs_hana_instance_additional_storage_config"></a> [powervs\_hana\_instance\_additional\_storage\_config](#input\_powervs\_hana\_instance\_additional\_storage\_config) | Additional File systems to be created and attached to PowerVS SAP HANA instance. 'size' is in GB. 'count' specify over how many storage volumes the file system will be striped. 'tier' specifies the storage tier in PowerVS workspace. 'mount' specifies the target mount point on OS. | <pre>list(object({<br/>    name  = string<br/>    size  = string<br/>    count = string<br/>    tier  = string<br/>    mount = string<br/>  }))</pre> | <pre>[<br/>  {<br/>    "count": "1",<br/>    "mount": "/usr/sap",<br/>    "name": "usrsap",<br/>    "size": "50",<br/>    "tier": "tier3"<br/>  }<br/>]</pre> | no |
| <a name="input_powervs_hana_instance_custom_storage_config"></a> [powervs\_hana\_instance\_custom\_storage\_config](#input\_powervs\_hana\_instance\_custom\_storage\_config) | Custom file systems to be created and attached to PowerVS SAP HANA instance. 'size' is in GB. 'count' specify over how many storage volumes the file system will be striped. 'tier' specifies the storage tier in PowerVS workspace. 'mount' specifies the target mount point on OS. If not specified, volumes for '/hana/data', '/hana/log', '/hana/shared' are automatically calculated and created. | <pre>list(object({<br/>    name  = string<br/>    size  = string<br/>    count = string<br/>    tier  = string<br/>    mount = string<br/>    pool  = optional(string)<br/>  }))</pre> | <pre>[<br/>  {<br/>    "count": "",<br/>    "mount": "",<br/>    "name": "",<br/>    "size": "",<br/>    "tier": ""<br/>  }<br/>]</pre> | no |
| <a name="input_powervs_hana_instance_sap_profile_id"></a> [powervs\_hana\_instance\_sap\_profile\_id](#input\_powervs\_hana\_instance\_sap\_profile\_id) | PowerVS SAP HANA instance profile to use. Must be one of the supported profiles. See [here](https://cloud.ibm.com/docs/sap?topic=sap-hana-iaas-offerings-profiles-power-vs). File system sizes are automatically calculated. Override automatic calculation by setting values in optional parameter 'powervs\_hana\_instance\_custom\_storage\_config'. | `string` | `"sh2-4x256"` | no |
| <a name="input_powervs_image_name"></a> [powervs\_image\_name](#input\_powervs\_image\_name) | Image name used for PowerVS instance. Run 'ibmcloud pi images' to list available images. | `string` | n/a | yes |
| <a name="input_powervs_instance_init_linux"></a> [powervs\_instance\_init\_linux](#input\_powervs\_instance\_init\_linux) | Configures a PowerVS linux instance to have internet access by setting proxy on it, updates os and create filesystems using ansible collection [ibm.power\_linux\_sap collection](https://galaxy.ansible.com/ui/repo/published/ibm/power_linux_sap/). where 'proxy\_host\_or\_ip\_port' E.g., 10.10.10.4:3128 <ip:port>, 'bastion\_host\_ip' is public IP of bastion/jump host to access the private IP of created linux PowerVS instance. | <pre>object(<br/>    {<br/>      enable             = bool<br/>      bastion_host_ip    = string<br/>      ansible_host_or_ip = string<br/>    }<br/>  )</pre> | <pre>{<br/>  "ansible_host_or_ip": "",<br/>  "bastion_host_ip": "",<br/>  "enable": false<br/>}</pre> | no |
| <a name="input_powervs_instance_name"></a> [powervs\_instance\_name](#input\_powervs\_instance\_name) | Name of instance which will be created. Must be less than 13 characters. | `string` | n/a | yes |
| <a name="input_powervs_network_services_config"></a> [powervs\_network\_services\_config](#input\_powervs\_network\_services\_config) | Configures network services NTP, NFS and DNS on PowerVS instance. Requires 'powervs\_instance\_init\_linux' to be specified as internet access is required to download ansible collection [ibm.power\_linux\_sap collection](https://galaxy.ansible.com/ui/repo/published/ibm/power_linux_sap/) to configure these services. The 'opts' attribute can take in comma separated values. | <pre>object(<br/>    {<br/>      squid = object({ enable = bool, squid_server_ip_port = string, no_proxy_hosts = string })<br/>      nfs   = object({ enable = bool, nfs_server_path = string, nfs_client_path = string, opts = string, fstype = string })<br/>      dns   = object({ enable = bool, dns_server_ip = string })<br/>      ntp   = object({ enable = bool, ntp_server_ip = string })<br/>    }<br/>  )</pre> | <pre>{<br/>  "dns": {<br/>    "dns_server_ip": "",<br/>    "enable": false<br/>  },<br/>  "nfs": {<br/>    "enable": false,<br/>    "fstype": "",<br/>    "nfs_client_path": "",<br/>    "nfs_server_path": "",<br/>    "opts": ""<br/>  },<br/>  "ntp": {<br/>    "enable": false,<br/>    "ntp_server_ip": ""<br/>  },<br/>  "squid": {<br/>    "enable": false,<br/>    "no_proxy_hosts": "",<br/>    "squid_server_ip_port": ""<br/>  }<br/>}</pre> | no |
| <a name="input_powervs_networks"></a> [powervs\_networks](#input\_powervs\_networks) | Existing list of private subnet ids to be attached to an instance. The first element will become the primary interface. Run 'ibmcloud pi subnets' to list available subnets. | <pre>list(<br/>    object({<br/>      name = string<br/>      id   = string<br/>      cidr = optional(string)<br/>    })<br/>  )</pre> | n/a | yes |
| <a name="input_powervs_os_registration_password"></a> [powervs\_os\_registration\_password](#input\_powervs\_os\_registration\_password) | If you're using a byol or a custom RHEL/SLES image for SAP HANA and Netweaver you need to provide your OS registration credentials here. Leave empty if you're using an IBM provided subscription (FLS). | `string` | `null` | no |
| <a name="input_powervs_os_registration_username"></a> [powervs\_os\_registration\_username](#input\_powervs\_os\_registration\_username) | If you're using a byol or a custom RHEL/SLES image for SAP HANA and Netweaver you need to provide your OS registration credentials here. Leave empty if you're using an IBM provided subscription (FLS). | `string` | `null` | no |
| <a name="input_powervs_server_type"></a> [powervs\_server\_type](#input\_powervs\_server\_type) | By default SAP profile will be deployed on default system type. Override this to specify the type of system on which to create the VM. Supported values are s922/e980/s1022/e1050/e1080/s1122/e1150/e1180. Mandatory when using dedicated hosts. | `string` | `null` | no |
| <a name="input_powervs_ssh_public_key_name"></a> [powervs\_ssh\_public\_key\_name](#input\_powervs\_ssh\_public\_key\_name) | Name of the existing PowerVS SSH public key. | `string` | n/a | yes |
| <a name="input_powervs_workspace_guid"></a> [powervs\_workspace\_guid](#input\_powervs\_workspace\_guid) | Existing GUID of the PowerVS workspace. The GUID of the service instance associated with an account. | `string` | n/a | yes |
| <a name="input_powervs_zone"></a> [powervs\_zone](#input\_powervs\_zone) | IBM Cloud PowerVS zone. | `string` | n/a | yes |
| <a name="input_sap_domain"></a> [sap\_domain](#input\_sap\_domain) | SAP network domain name. | `string` | `"sap.com"` | no |
| <a name="input_ssh_private_key"></a> [ssh\_private\_key](#input\_ssh\_private\_key) | SSH private key to access the PowerVS instance via bastion host. | `string` | `""` | no |

### Outputs

| Name | Description |
|------|-------------|
| <a name="output_pi_instance_primary_ip"></a> [pi\_instance\_primary\_ip](#output\_pi\_instance\_primary\_ip) | IP address of the primary network interface of IBM PowerVS instance. |
| <a name="output_pi_instance_private_ips"></a> [pi\_instance\_private\_ips](#output\_pi\_instance\_private\_ips) | All private IP addresses (as a list) of IBM PowerVS instance. |
| <a name="output_pi_storage_configuration"></a> [pi\_storage\_configuration](#output\_pi\_storage\_configuration) | Storage configuration of PowerVS instance. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
