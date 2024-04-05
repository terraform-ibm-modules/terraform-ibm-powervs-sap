# End-to-end solution: Power Virtual Server with VPC landing zone including Power Virtual Server for SAP HANA instances

The end-to-end solution automates the following tasks:

- A **VPC Infrastructure** based on the value passed to `var.landing_zone_configuration` with the following components:
    -  **landing_zone_configuration = 3VPC_RHEL or 3VPC_SLES**

        - Provisions three VPCs with one VSI in each VPC: one management (jump/bastion) VSI, one inet-svs VSI configured as a squid proxy server, and one private-svs VSI (configured as NFS, NTP, DNS server) using [this preset](https://github.com/terraform-ibm-modules/terraform-ibm-powervs-infrastructure/blob/main/modules/powervs-vpc-landing-zone/presets/3vpc.preset.json.tftpl).
        - Installs and configures the Squid Proxy, DNS Forwarder, NTP forwarder, and NFS on hosts, and sets the host as the server for the NTP, NFS, and DNS services using Ansible Galaxy Collection Roles [ibm.power_linux_sap collection](https://galaxy.ansible.com/ui/repo/published/ibm/power_linux_sap/).

    -  **landing_zone_configuration = 1VPC_RHEL**

        - One VPC with one VSI for management (jump/bastion) using [this preset](https://github.com/terraform-ibm-modules/terraform-ibm-powervs-infrastructure/blob/main/modules/powervs-vpc-landing-zone/presets/1vpc.preset.json.tftpl).
        - Installation and configuration of Squid Proxy, DNS Forwarder, NTP forwarder, and NFS on the bastion host, and sets the host as the server for the NTP, NFS, and DNS services using Ansible Galaxy collection roles [ibm.power_linux_sap collection](https://galaxy.ansible.com/ui/repo/published/ibm/power_linux_sap/)

- **A Power Virtual Server workspace**  with the following network topology:
    - Creates two private networks: a management network and a backup network.
    - Creates one or two IBM Cloud connections in a non-PER environment.
    - Attaches the private networks to the IBM Cloud connections in a non-PER environment.
    - Attaches the IBM Cloud connections to a transit gateway in a non-PER environment.
    - Attaches the PowerVS workspace to Transit gateway in PER-enabled DC.
    - Creates an SSH key.

- Finally, interconnects both VPC and PowerVS infrastructure.

- **Power Virtual Server Instances**
    - Creates a new private subnet for SAP communication for the entire landscape and attaches it to cloud connections (in non-PER DC).
    - Creates and configures one PowerVS instance for SAP HANA based on best practices.
    - Creates and configures multiple PowerVS instances for SAP NetWeaver based on best practices.
    - Creates and configures one optional PowerVS instance for sharing SAP files between other system instances.
    - Connects all created PowerVS instances to a proxy server specified by IP address or hostname.
- Optionally connects all created PowerVS instances to an NTP server and DNS forwarder specified by IP address or hostname.
- Optionally configures a shared NFS directory on all created PowerVS instances.
- Post-instance provisioning, Ansible Galaxy collection roles from [IBM](https://galaxy.ansible.com/ui/repo/published/ibm/power_linux_sap/) are executed: `power_linux_sap`.
- Tested with RHEL8.4, RHEL 8.6, SLES15-SP4, and SLES15-SP6 images.

## Notes
- **Does not install any SAP softwares or solutions.**
- Filesystem sizes for HANA data and HANA log are **calculated automatically** based on the **memory size**. Custom storage configuration is also supported.
- If **sharefs instance is enabled**, then all filesystems provisioned for sharefs instance will be **NFS exported and mounted** on all NetWeaver Instances.
- **Do not specify** a filesystem `/sapmnt` explicitly for NetWeaver instance as, it is created internally when sharefs instance is not enabled.


|                                  Variation                                  | Available on IBM Catalog | Requires Schematics Workspace ID | Creates PowerVS with VPC landing zone | Creates PowerVS HANA Instance | Creates PowerVS NW Instances | Performs PowerVS OS Config | Performs PowerVS SAP Tuning | Install SAP software |
|:---------------------------------------------------------------------------:|:------------------------:|:--------------------------------:|:-------------------------------------:|:-----------------------------:|:----------------------------:|:--------------------------:|:---------------------------:|:--------------------:|
|                      [ End-to-End ](./)                     |            N/A           |                N/A               |           :heavy_check_mark:          |               1               |            0 to N            |     :heavy_check_mark:     |      :heavy_check_mark:     |          N/A         |

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
### Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3, < 1.7 |
| <a name="requirement_ibm"></a> [ibm](#requirement\_ibm) | >=1.64.0 |
| <a name="requirement_time"></a> [time](#requirement\_time) | >= 0.9.1 |

### Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_fullstack"></a> [fullstack](#module\_fullstack) | terraform-ibm-modules/powervs-infrastructure/ibm//modules/powervs-vpc-landing-zone | 4.9.0 |
| <a name="module_sap_system"></a> [sap\_system](#module\_sap\_system) | ../../modules/pi-sap-system-type1 | n/a |

### Resources

| Name | Type |
|------|------|
| [time_sleep.wait_10_mins](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/sleep) | resource |

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_configure_dns_forwarder"></a> [configure\_dns\_forwarder](#input\_configure\_dns\_forwarder) | Specify if DNS forwarder will be configured. This will allow you to use central DNS servers (e.g. IBM Cloud DNS servers) sitting outside of the created IBM PowerVS infrastructure. If yes, ensure 'dns\_forwarder\_config' optional variable is set properly. DNS forwarder will be installed on the private-svs vsi. | `bool` | `true` | no |
| <a name="input_configure_nfs_server"></a> [configure\_nfs\_server](#input\_configure\_nfs\_server) | Specify if NFS server will be configured. This will allow you easily to share files between PowerVS instances (e.g., SAP installation files). NFS server will be installed on the private-svs vsi. If yes, ensure 'nfs\_server\_config' optional variable is set properly below. Default value is 1TB which will be mounted on /nfs. | `bool` | `true` | no |
| <a name="input_configure_ntp_forwarder"></a> [configure\_ntp\_forwarder](#input\_configure\_ntp\_forwarder) | Specify if NTP forwarder will be configured. This will allow you to synchronize time between IBM PowerVS instances. NTP forwarder will be installed on the private-svs vsi. | `bool` | `true` | no |
| <a name="input_external_access_ip"></a> [external\_access\_ip](#input\_external\_access\_ip) | Specify the IP address or CIDR to login through SSH to the environment after deployment. Access to this environment will be allowed only from this IP address. | `string` | n/a | yes |
| <a name="input_ibmcloud_api_key"></a> [ibmcloud\_api\_key](#input\_ibmcloud\_api\_key) | The IBM Cloud platform API key needed to deploy IAM enabled resources. | `string` | n/a | yes |
| <a name="input_landing_zone_configuration"></a> [landing\_zone\_configuration](#input\_landing\_zone\_configuration) | VPC landing zone configuration. | `string` | n/a | yes |
| <a name="input_os_image_distro"></a> [os\_image\_distro](#input\_os\_image\_distro) | Image distribution to use for all instances(Shared, HANA, NetWeaver). OS release versions may be specified in 'var.powervs\_default\_images' optional parameters below. | `string` | n/a | yes |
| <a name="input_powervs_create_separate_sharefs_instance"></a> [powervs\_create\_separate\_sharefs\_instance](#input\_powervs\_create\_separate\_sharefs\_instance) | Deploy separate IBM PowerVS instance as central file system share. All filesystems defined in 'powervs\_sharefs\_instance\_storage\_config' variable will be NFS exported and mounted on NetWeaver PowerVS instances if enabled. Optional parameter 'powervs\_share\_fs\_instance' can be configured if enabled. | `bool` | n/a | yes |
| <a name="input_powervs_default_sap_images"></a> [powervs\_default\_sap\_images](#input\_powervs\_default\_sap\_images) | Default SUSE and Red Hat Linux images to use for SAP HANA and SAP NetWeaver PowerVS instances. | <pre>object({<br>    sles_hana_image = string<br>    sles_nw_image   = string<br>    rhel_hana_image = string<br>    rhel_nw_image   = string<br>  })</pre> | <pre>{<br>  "rhel_hana_image": "RHEL8-SP6-SAP",<br>  "rhel_nw_image": "RHEL8-SP6-SAP-NETWEAVER",<br>  "sles_hana_image": "SLES15-SP4-SAP",<br>  "sles_nw_image": "SLES15-SP4-SAP-NETWEAVER"<br>}</pre> | no |
| <a name="input_powervs_hana_instance"></a> [powervs\_hana\_instance](#input\_powervs\_hana\_instance) | SAP HANA hostname (non FQDN) will get the form of <var.prefix>-<var.pi\_hana\_instance\_name>. SAP HANA profile to use. Must be one of the supported profiles. See [here](https://cloud.ibm.com/docs/sap?topic=sap-hana-iaas-offerings-profiles-power-vs). File system sizes are automatically calculated. Override automatic calculation by setting values in optional 'pi\_hana\_instance\_custom\_storage\_config' parameter. 'additional\_storage\_config' additional file systems to be created and attached to PowerVS instance for SAP HANA. 'size' is in GB. 'count' specify over how many storage volumes the file system will be striped. 'tier' specifies the storage tier in PowerVS workspace. 'mount' specifies the target mount point on OS. | <pre>object({<br>    name           = string<br>    sap_profile_id = string<br>    additional_storage_config = list(object({<br>      name  = string<br>      size  = string<br>      count = string<br>      tier  = string<br>      mount = string<br>    }))<br>  })</pre> | <pre>{<br>  "additional_storage_config": [<br>    {<br>      "count": "1",<br>      "mount": "/usr/sap",<br>      "name": "usrsap",<br>      "size": "50",<br>      "tier": "tier3"<br>    }<br>  ],<br>  "name": "hana",<br>  "sap_profile_id": "ush1-4x256"<br>}</pre> | no |
| <a name="input_powervs_hana_instance_custom_storage_config"></a> [powervs\_hana\_instance\_custom\_storage\_config](#input\_powervs\_hana\_instance\_custom\_storage\_config) | Custom File systems to be created and attached to PowerVS instance for SAP HANA. 'size' is in GB. 'count' specify over how many storage volumes the file system will be striped. 'tier' specifies the storage tier in PowerVS workspace. 'mount' specifies the target mount point on OS. | <pre>list(object({<br>    name  = string<br>    size  = string<br>    count = string<br>    tier  = string<br>    mount = string<br>  }))</pre> | <pre>[<br>  {<br>    "count": "",<br>    "mount": "",<br>    "name": "",<br>    "size": "",<br>    "tier": ""<br>  }<br>]</pre> | no |
| <a name="input_powervs_netweaver_instance"></a> [powervs\_netweaver\_instance](#input\_powervs\_netweaver\_instance) | 'instance\_count' is number of SAP NetWeaver instances that should be created. 'size' is in GB. 'count' specify over how many storage volumes the file system will be striped. 'tier' specifies the storage tier in PowerVS workspace. 'mount' specifies the target mount point on OS. | <pre>object({<br>    instance_count = number<br>    name           = string<br>    processors     = string<br>    memory         = string<br>    proc_type      = string<br>    storage_config = list(object({<br>      name  = string<br>      size  = string<br>      count = string<br>      tier  = string<br>      mount = string<br>    }))<br>  })</pre> | <pre>{<br>  "instance_count": 1,<br>  "memory": "32",<br>  "name": "nw",<br>  "proc_type": "shared",<br>  "processors": "3",<br>  "storage_config": [<br>    {<br>      "count": "1",<br>      "mount": "/usr/sap",<br>      "name": "usrsap",<br>      "size": "50",<br>      "tier": "tier3"<br>    }<br>  ]<br>}</pre> | no |
| <a name="input_powervs_resource_group_name"></a> [powervs\_resource\_group\_name](#input\_powervs\_resource\_group\_name) | Existing IBM Cloud resource group name. | `string` | n/a | yes |
| <a name="input_powervs_sap_network_cidr"></a> [powervs\_sap\_network\_cidr](#input\_powervs\_sap\_network\_cidr) | Additional private subnet for SAP communication which will be created. CIDR for SAP network. E.g., '10.53.0.0/24' | `string` | `"10.53.0.0/24"` | no |
| <a name="input_powervs_sharefs_instance"></a> [powervs\_sharefs\_instance](#input\_powervs\_sharefs\_instance) | Share fs instance. This parameter is effective if 'powervs\_create\_separate\_sharefs\_instance' is set to true. size' is in GB. 'count' specify over how many storage volumes the file system will be striped. 'tier' specifies the storage tier in PowerVS workspace. 'mount' specifies the target mount point on OS. | <pre>object({<br>    name       = string<br>    processors = string<br>    memory     = string<br>    proc_type  = string<br>    storage_config = list(object({<br>      name  = string<br>      size  = string<br>      count = string<br>      tier  = string<br>      mount = string<br>    }))<br>  })</pre> | <pre>{<br>  "memory": "2",<br>  "name": "share",<br>  "proc_type": "shared",<br>  "processors": "0.5",<br>  "storage_config": [<br>    {<br>      "count": "1",<br>      "mount": "/sapmnt",<br>      "name": "sapmnt",<br>      "size": "300",<br>      "tier": "tier3"<br>    },<br>    {<br>      "count": "1",<br>      "mount": "/usr/trans",<br>      "name": "trans",<br>      "size": "50",<br>      "tier": "tier3"<br>    }<br>  ]<br>}</pre> | no |
| <a name="input_powervs_zone"></a> [powervs\_zone](#input\_powervs\_zone) | IBM Cloud data center location where IBM PowerVS infrastructure will be created. | `string` | n/a | yes |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | A unique identifier for resources. Must begin with a lowercase letter and end with a lowercase letter or number. This prefix will be prepended to any resources provisioned by this template. | `string` | n/a | yes |
| <a name="input_sap_domain"></a> [sap\_domain](#input\_sap\_domain) | SAP domain to be set for entire landscape. | `string` | `"sap.com"` | no |
| <a name="input_ssh_private_key"></a> [ssh\_private\_key](#input\_ssh\_private\_key) | Private SSH key (RSA format) used to login to IBM PowerVS instances. Should match to public SSH key referenced by 'ssh\_public\_key'. Entered data must be in [heredoc strings format](https://www.terraform.io/language/expressions/strings#heredoc-strings). The key is not uploaded or stored. For more information about SSH keys, see [SSH keys](https://cloud.ibm.com/docs/vpc?topic=vpc-ssh-keys). | `string` | n/a | yes |
| <a name="input_ssh_public_key"></a> [ssh\_public\_key](#input\_ssh\_public\_key) | Public SSH Key for VSI creation. Must be an RSA key with a key size of either 2048 bits or 4096 bits (recommended). Must be a valid SSH key that does not already exist in the deployment region. | `string` | n/a | yes |

### Outputs

| Name | Description |
|------|-------------|
| <a name="output_access_host_or_ip"></a> [access\_host\_or\_ip](#output\_access\_host\_or\_ip) | Access host(jump/bastion) for created PowerVS infrastructure. |
| <a name="output_cloud_connection_count"></a> [cloud\_connection\_count](#output\_cloud\_connection\_count) | Number of cloud connections configured in created PowerVS infrastructure. |
| <a name="output_dns_host_or_ip"></a> [dns\_host\_or\_ip](#output\_dns\_host\_or\_ip) | DNS forwarder host for created PowerVS infrastructure. |
| <a name="output_nfs_host_or_ip_path"></a> [nfs\_host\_or\_ip\_path](#output\_nfs\_host\_or\_ip\_path) | NFS host for created PowerVS infrastructure. |
| <a name="output_ntp_host_or_ip"></a> [ntp\_host\_or\_ip](#output\_ntp\_host\_or\_ip) | NTP host for created PowerVS infrastructure. |
| <a name="output_powervs_backup_subnet"></a> [powervs\_backup\_subnet](#output\_powervs\_backup\_subnet) | Name, ID and CIDR of backup private network in created PowerVS infrastructure. |
| <a name="output_powervs_hana_instance_ips"></a> [powervs\_hana\_instance\_ips](#output\_powervs\_hana\_instance\_ips) | All private IPS of HANA instance |
| <a name="output_powervs_hana_instance_management_ip"></a> [powervs\_hana\_instance\_management\_ip](#output\_powervs\_hana\_instance\_management\_ip) | Management IP of HANA Instance |
| <a name="output_powervs_images"></a> [powervs\_images](#output\_powervs\_images) | Object containing imported PowerVS image names and image ids. |
| <a name="output_powervs_lpars_data"></a> [powervs\_lpars\_data](#output\_powervs\_lpars\_data) | All private IPS of PowerVS instances and Jump IP to access the host. |
| <a name="output_powervs_management_subnet"></a> [powervs\_management\_subnet](#output\_powervs\_management\_subnet) | Name, ID and CIDR of management private network in created PowerVS infrastructure. |
| <a name="output_powervs_netweaver_instance_ips"></a> [powervs\_netweaver\_instance\_ips](#output\_powervs\_netweaver\_instance\_ips) | All private IPS of NetWeaver instances |
| <a name="output_powervs_netweaver_instance_management_ips"></a> [powervs\_netweaver\_instance\_management\_ips](#output\_powervs\_netweaver\_instance\_management\_ips) | Management IPS of NetWeaver instances |
| <a name="output_powervs_resource_group_name"></a> [powervs\_resource\_group\_name](#output\_powervs\_resource\_group\_name) | IBM Cloud resource group where PowerVS infrastructure is created. |
| <a name="output_powervs_share_fs_ips"></a> [powervs\_share\_fs\_ips](#output\_powervs\_share\_fs\_ips) | Private IPs of the Share FS instance. |
| <a name="output_powervs_ssh_public_key"></a> [powervs\_ssh\_public\_key](#output\_powervs\_ssh\_public\_key) | SSH public key name and value in created PowerVS infrastructure. |
| <a name="output_powervs_workspace_guid"></a> [powervs\_workspace\_guid](#output\_powervs\_workspace\_guid) | PowerVS infrastructure workspace guid. The GUID of the resource instance. |
| <a name="output_powervs_workspace_id"></a> [powervs\_workspace\_id](#output\_powervs\_workspace\_id) | PowerVS infrastructure workspace id. The unique identifier of the new resource instance. |
| <a name="output_powervs_workspace_name"></a> [powervs\_workspace\_name](#output\_powervs\_workspace\_name) | PowerVS infrastructure workspace name. |
| <a name="output_powervs_zone"></a> [powervs\_zone](#output\_powervs\_zone) | Zone where PowerVS infrastructure is created. |
| <a name="output_prefix"></a> [prefix](#output\_prefix) | The prefix that is associated with all resources |
| <a name="output_proxy_host_or_ip_port"></a> [proxy\_host\_or\_ip\_port](#output\_proxy\_host\_or\_ip\_port) | Proxy host:port for created PowerVS infrastructure. |
| <a name="output_ssh_public_key"></a> [ssh\_public\_key](#output\_ssh\_public\_key) | The string value of the ssh public key used when deploying VPC |
| <a name="output_transit_gateway_id"></a> [transit\_gateway\_id](#output\_transit\_gateway\_id) | The ID of transit gateway. |
| <a name="output_transit_gateway_name"></a> [transit\_gateway\_name](#output\_transit\_gateway\_name) | The name of the transit gateway. |
| <a name="output_vpc_names"></a> [vpc\_names](#output\_vpc\_names) | A list of the names of the VPC. |
| <a name="output_vsi_list"></a> [vsi\_list](#output\_vsi\_list) | A list of VSI with name, id, zone, and primary ipv4 address, VPC Name, and floating IP. |
| <a name="output_vsi_names"></a> [vsi\_names](#output\_vsi\_names) | A list of the vsis names provisioned within the VPCs. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
