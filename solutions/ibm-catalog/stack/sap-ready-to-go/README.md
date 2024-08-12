# IBM Cloud Catalog - Power Virtual Server for SAP HANA: 'SAP Ready PowerVS Stack'

The 'SAP Ready PowerVS Stack' is designed to simplify the deployment of an end-to-end SAP ERP software landscape on the IBM Power Virtual Server infrastructure into IBM Cloud. It combines the deployment of two [deployable architectures](https://cloud.ibm.com/docs/secure-enterprise?topic=secure-enterprise-understand-module-da#what-is-da) into one configuration and helps to deploy the SAP landscape via IBM Cloud [projects](https://cloud.ibm.com/docs/secure-enterprise?topic=secure-enterprise-understanding-projects).

# Summary
## Stack Deployment Outcome:
The 'SAP Ready PowerVS Stack' solution offers two [deployable architectures](https://cloud.ibm.com/docs/secure-enterprise?topic=secure-enterprise-understand-module-da#what-is-da):
1. [Power Virtual Server with VPC landing zone](https://cloud.ibm.com/catalog/architecture/deploy-arch-ibm-pvs-inf-2dd486c7-b317-4aaa-907b-42671485ad96-global?kind=terraform&format=terraform&version=7cee3b92-c691-4394-aed5-b090cbffb403-global) - Standard variant: This architecture establishes an IBM Cloud® Power Virtual Server Infrastructure (PowerVS) that adheres to IBM Cloud's best practices and requirements. The infrastructure has following components:
    - A **VPC** with the following components:
        - One VSI for one management (jump/bastion) VSI,
        - One VSI for network-services configured as squid proxy, NTP and DNS servers(using Ansible Galaxy collection roles [ibm.power_linux_sap collection](https://galaxy.ansible.com/ui/repo/published/ibm/power_linux_sap/)). This VSI also acts as central ansible execution node.
        - Optional [Client to site VPN server](https://cloud.ibm.com/docs/vpc?topic=vpc-vpn-client-to-site-overview)
        - Optional [File storage share](https://cloud.ibm.com/docs/vpc?topic=vpc-file-storage-create&interface=ui)
        - Optional [Application load balancer](https://cloud.ibm.com/docs/vpc?topic=vpc-load-balancers&interface=ui)
        - IBM Cloud Object storage(COS) Virtual Private endpoint gateway(VPE)
        - IBM Cloud Object storage(COS) Instance and buckets
        - VPC flow logs
        - KMS keys
        - Activity tracker
        - Optional Secrets Manager Instance Instance with private certificate.
    - A local **transit gateway**
    - A **Power Virtual Server** workspace with the following network topology:
        - Creates two private networks: a management network and a backup network.
        - Attaches the PowerVS workspace to transit gateway.
        - Creates an SSH key.
        - Imports catalog stock images.
2. Power Virtual Server for SAP HANA - SAP Ready PowerVS variant: This architecture provisions IBM PowerVS hosts on the Power Virtual Server Infrastructure. The virtual server instances are optimized for SAP, supporting SAP HANA and NetWeaver configurations. The deployment of results adds the following components into the infrastructure deployed by the first solution:
    - Creates a new private subnet for SAP communication for the entire landscape
    - Creates and configures one PowerVS instance for SAP HANA based on best practices.
    - Creates and configures multiple PowerVS instances for SAP NetWeaver based on best practices.
    - Creates and configures one optional PowerVS instance that can be used for sharing SAP files between other system instances.
    - Connects all created PowerVS instances to a proxy server specified by IP address or hostname.
    - Optionally connects all created PowerVS instances to an NTP server and DNS forwarder specified by IP address or hostname.
    - Optionally configures a shared NFS directory on all created PowerVS instances.
    - Post-instance provisioning, Ansible Galaxy collection roles from [IBM](https://galaxy.ansible.com/ui/repo/published/ibm/power_linux_sap/) are executed: `power_linux_sap`.

## Notes
- **Does not install any SAP software or solutions.**
- Filesystem sizes for HANA data and HANA log are **calculated automatically** based on the **memory size**.
- Custom storage configuration by providing custom volume size, **iops**(tier0, tier1, tier3, tier5k), counts and mount points is supported.
- If **sharefs instance is enabled**, then all filesystems provisioned for sharefs instance will be **NFS exported and mounted** on all NetWeaver Instances.
- **Do not specify** a filesystem `/sapmnt` explicitly for NetWeaver instance as, it is created internally when sharefs instance is not enabled.
- Tested with RHEL8.4,/8.6/8.8/9.2, SLES15-SP3/SP5 images.

| Variation                   | Available on IBM Catalog  | Creates VPC Landing Zone          | Performs VPC VSI OS Config        | Creates PowerVS Infrastructure    | Creates PowerVS HANA Instance     | Creates PowerVS NW Instances      | Performs PowerVS OS Config        | Performs PowerVS SAP Tuning       | Install SAP software              |
|-----------------------------|------------|------------|------------|------------|------------|------------|------------|------------|------------|
| **SAP Ready PowerVS Stack** | yes | ✅             | ✅             | ✅             | 1              | 0 to N         | ✅             | ✅             | ❌             |


## Architecture Diagram
![sap-ready-to-go](https://github.com/terraform-ibm-modules/terraform-ibm-powervs-sap/blob/main/reference-architectures/sap-ready-to-go/deploy-arch-ibm-pvs-sap-ready-to-go.svg)

### Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3 |
| <a name="requirement_ibm"></a> [ibm](#requirement\_ibm) | 1.68.0 |

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_ibmcloud_api_key"></a> [ibmcloud\_api\_key](#input\_ibmcloud\_api\_key) | IBM Cloud platform API key needed to deploy IAM enabled resources. | `string` | n/a | yes |
| <a name="input_powervs_zone"></a> [powervs\_zone](#input\_powervs\_zone) | IBM Cloud data center location corresponding to the location used in 'Power Virtual Server with VPC landing zone' pre-requisite deployment. | `string` | n/a | yes |
| <a name="input_powervs_resource_group_name"></a> [powervs\_resource\_group\_name](#input\_powervs\_resource\_group\_name) | Existing IBM Cloud resource group name. | `string` | n/a | yes |
| <a name="input_prefix"></a> [power_infrastructure_prefix](#input\_power\_infrastructure\_prefix) | A unique identifier for resources. Must begin with a lowercase letter and end with a lowercase letter or number. This prefix will be prepended to any resources provisioned by this template. Prefixes must be 16 or fewer characters. | `string` | n/a | yes |
| <a name="input_external_access_ip"></a> [external\_access\_ip](#input\_external\_access\_ip) | Specify the source IP address or CIDR for login through SSH to the environment after deployment. Access to the environment will be allowed only from this IP address. Can be set to 'null' if you choose to use client to site vpn. | `string` | n/a | yes |
| <a name="input_client_to_site_vpn"></a> [client\_to\_site\_vpn](#input\_client\_to\_site\_vpn) | VPN configuration - the client ip pool and list of users email ids to access the environment. If enabled, then a Secret Manager instance is also provisioned with certificates generated. See optional parameters to reuse existing certificate from secrets manager instance. | <pre>object({<br>    enable                        = bool<br>    client_ip_pool                = string<br>    vpn_client_access_group_users = list(string)<br>  })</pre> | <pre>{<br>  "client_ip_pool": "192.168.0.0/16",<br>  "enable": true,<br>  "vpn_client_access_group_users": []<br>}</pre> | no |
| <a name="input_ssh_private_key"></a> [ssh\_private\_key](#input\_ssh\_private\_key) | Private SSH key (RSA format) to login to Intel VSIs to configure network management services (SQUID, NTP, NFS, DNS and ansible). Should match to public SSH key referenced by 'ssh\_public\_key'. The key is not uploaded or stored. For more information about SSH keys, see [SSH keys](https://cloud.ibm.com/docs/vpc?topic=vpc-ssh-keys). | `string` | n/a | yes |
| <a name="input_ssh_public_key"></a> [ssh\_public\_key](#input\_ssh\_public\_key) | Public SSH Key for VSI creation. Must be an RSA key with a key size of either 2048 bits or 4096 bits (recommended). Must be a valid SSH key that does not already exist in the deployment region. | `string` | n/a | yes |
| <a name="input_powervs_management_network"></a> [powervs\_management\_network](#input\_powervs\_management\_network) | Name of the IBM Cloud PowerVS management subnet and CIDR to create. | <pre>object({<br>    name = string<br>    cidr = string<br>  })</pre> | <pre>{<br>  "cidr": "10.51.0.0/24",<br>  "name": "mgmt_net"<br>}</pre> | no |
| <a name="input_powervs_backup_network"></a> [powervs\_backup\_network](#input\_powervs\_backup\_network) | Name of the IBM Cloud PowerVS backup network and CIDR to create. | <pre>object({<br>    name = string<br>    cidr = string<br>  })</pre> | <pre>{<br>  "cidr": "10.52.0.0/24",<br>  "name": "bkp_net"<br>}</pre> | no |
| <a name="input_powervs_image_names"></a> [powervs\_image\_names](#input\_powervs\_image\_names) | List of Images to be imported into cloud account from catalog images. Supported values can be found [here](https://github.com/terraform-ibm-modules/terraform-ibm-powervs-workspace/blob/main/docs/catalog_images_list.md) | `list(string)` | <pre>[<br>  "IBMi-75-03-2924-2",<br>  "IBMi-74-09-2984-1",<br>  "7200-05-07",<br>  "7300-02-01",<br>  "SLES15-SP5-SAP",<br>  "SLES15-SP5-SAP-NETWEAVER",<br>  "RHEL9-SP2-SAP",<br>  "RHEL9-SP2-SAP-NETWEAVER"<br>]</pre> | no |
| <a name="input_tags"></a> [tags](#input\_tags) | List of tag names for the IBM Cloud PowerVS workspace | `list(string)` | `[]` | no |
| <a name="input_sm_service_plan"></a> [sm\_service\_plan](#input\_sm\_service\_plan) | The service/pricing plan to use when provisioning a new Secrets Manager instance. Allowed values: `standard` and `trial`. Only used if `existing_sm_instance_guid` is set to null. | `string` | `"standard"` | no |
| <a name="input_sap_system_prefix"></a> [sap_system_prefix](#input\_sap\_system\_prefix) | Unique prefix for resources to be created (e.g., SAP system name). Max length must be less than or equal to 6. | `string` | n/a | yes |
| <a name="input_powervs_sap_network_cidr"></a> [powervs\_sap\_network\_cidr](#input\_powervs\_sap\_network\_cidr) | Network range for dedicated SAP network. Used for communication between SAP Application servers with SAP HANA Database. E.g., '10.53.0.0/24' | `string` | `"10.53.0.0/24"` | no |
| <a name="input_powervs_hana_instance_name"></a> [powervs\_hana\_instance\_name](#input\_powervs\_hana\_instance\_name) | PowerVS SAP HANA instance hostname (non FQDN). Will get the form of <var.prefix>-<var.powervs\_hana\_instance\_name>. Max length of final hostname must be <= 13 characters. | `string` | `"hana"` | no |
| <a name="input_powervs_hana_instance_sap_profile_id"></a> [powervs\_hana\_instance\_sap\_profile\_id](#input\_powervs\_hana\_instance\_sap\_profile\_id) | PowerVS SAP HANA instance profile to use. Must be one of the supported profiles. See [here](https://cloud.ibm.com/docs/sap?topic=sap-hana-iaas-offerings-profiles-power-vs). File system sizes are automatically calculated. Override automatic calculation by setting values in optional parameter 'powervs\_hana\_instance\_custom\_storage\_config'. | `string` | `"ush1-4x256"` | no |
| <a name="input_powervs_netweaver_cpu_number"></a> [powervs\_netweaver\_cpu\_number](#input\_powervs\_netweaver\_cpu\_number) | Number of CPUs for each PowerVS SAP NetWeaver instance. | `string` | `"3"` | no |
| <a name="input_powervs_netweaver_instance_count"></a> [powervs\_netweaver\_instance\_count](#input\_powervs\_netweaver\_instance\_count) | Number of PowerVS SAP NetWeaver instances that should be created. | `number` | `1` | no |
| <a name="input_powervs_netweaver_instance_name"></a> [powervs\_netweaver\_instance\_name](#input\_powervs\_netweaver\_instance\_name) | PowerVS SAP NetWeaver instance hostname (non FQDN). Will get the form of <var.prefix>-<var.powervs\_netweaver\_instance\_name>-<number>. Max length of final hostname must be <= 13 characters. | `string` | `"nw"` | no |
| <a name="input_powervs_netweaver_memory_size"></a> [powervs\_netweaver\_memory\_size](#input\_powervs\_netweaver\_memory\_size) | Memory size for each PowerVS SAP NetWeaver instance. | `string` | `"32"` | no |
| <a name="input_sap_domain"></a> [sap\_domain](#input\_sap\_domain) | SAP network domain name. | `string` | `"sap.com"` | no |
| <a name="input_os_image_distro"></a> [os\_image\_distro](#input\_os\_image\_distro) | Image distribution to use for all instances(Shared, HANA, NetWeaver). OS release versions may be specified in 'powervs\_sap\_default\_images' optional parameters below. | `string` | n/a | yes |
| <a name="input_powervs_create_separate_sharefs_instance"></a> [powervs\_create\_separate\_sharefs\_instance](#input\_powervs\_create\_separate\_sharefs\_instance) | Deploy separate IBM PowerVS instance as central file system share. All filesystems defined in 'powervs\_sharefs\_instance\_storage\_config' variable will be NFS exported and mounted on SAP NetWeaver PowerVS instances if enabled. Optional parameter 'powervs\_share\_fs\_instance' can be configured if enabled. | `bool` | n/a | yes |
| <a name="input_powervs_default_sap_images"></a> [powervs\_default\_sap\_images](#input\_powervs\_default\_sap\_images) | Default SUSE and Red Hat Linux images to use for PowerVS SAP HANA and SAP NetWeaver instances. | <pre>object({<br>    sles_hana_image = string<br>    sles_nw_image   = string<br>    rhel_hana_image = string<br>    rhel_nw_image   = string<br>  })</pre> | <pre>{<br>  "rhel_hana_image": "RHEL9-SP2-SAP",<br>  "rhel_nw_image": "RHEL9-SP2-SAP-NETWEAVER",<br>  "sles_hana_image": "SLES15-SP5-SAP",<br>  "sles_nw_image": "SLES15-SP5-SAP-NETWEAVER"<br>}</pre> | no |
| <a name="input_powervs_hana_instance_additional_storage_config"></a> [powervs\_hana\_instance\_additional\_storage\_config](#input\_powervs\_hana\_instance\_additional\_storage\_config) | Additional File systems to be created and attached to PowerVS SAP HANA instance. 'size' is in GB. 'count' specify over how many storage volumes the file system will be striped. 'tier' specifies the storage tier in PowerVS workspace. 'mount' specifies the target mount point on OS. | <pre>list(object({<br>    name  = string<br>    size  = string<br>    count = string<br>    tier  = string<br>    mount = string<br>  }))</pre> | <pre>[<br>  {<br>    "count": "1",<br>    "mount": "/usr/sap",<br>    "name": "usrsap",<br>    "size": "50",<br>    "tier": "tier3"<br>  }<br>]</pre> | no |
| <a name="input_powervs_hana_instance_custom_storage_config"></a> [powervs\_hana\_instance\_custom\_storage\_config](#input\_powervs\_hana\_instance\_custom\_storage\_config) | Custom file systems to be created and attached to PowerVS SAP HANA instance. 'size' is in GB. 'count' specify over how many storage volumes the file system will be striped. 'tier' specifies the storage tier in PowerVS workspace. 'mount' specifies the target mount point on OS. | <pre>list(object({<br>    name  = string<br>    size  = string<br>    count = string<br>    tier  = string<br>    mount = string<br>    pool  = optional(string)<br>  }))</pre> | <pre>[<br>  {<br>    "count": "",<br>    "mount": "",<br>    "name": "",<br>    "size": "",<br>    "tier": ""<br>  }<br>]</pre> | no |
| <a name="input_nfs_directory"></a> [nfs\_directory](#input\_nfs\_directory) | Target directory on which the file storage share from VPC will be mounted. | `string` | `"/nfs"` | no |
| <a name="input_powervs_netweaver_instance_storage_config"></a> [powervs\_netweaver\_instance\_storage\_config](#input\_powervs\_netweaver\_instance\_storage\_config) | File systems to be created and attached to PowerVS SAP NetWeaver instance. 'size' is in GB. 'count' specify over how many storage volumes the file system will be striped. 'tier' specifies the storage tier in PowerVS workspace. 'mount' specifies the target mount point on OS. Do not specify volume for 'sapmnt' as this will be created internally if 'powervs\_create\_separate\_sharefs\_instance' is false, else 'sapmnt' be will mounted from sharefs instance. | <pre>list(object({<br>    name  = string<br>    size  = string<br>    count = string<br>    tier  = string<br>    mount = string<br>    pool  = optional(string)<br>  }))</pre> | <pre>[<br>  {<br>    "count": "1",<br>    "mount": "/usr/sap",<br>    "name": "usrsap",<br>    "size": "50",<br>    "tier": "tier3"<br>  }<br>]</pre> | no |
| <a name="input_powervs_sharefs_instance"></a> [powervs\_sharefs\_instance](#input\_powervs\_sharefs\_instance) | Share fs instance. This parameter is effective if 'powervs\_create\_separate\_sharefs\_instance' is set to true. size' is in GB. 'count' specify over how many storage volumes the file system will be striped. 'tier' specifies the storage tier in PowerVS workspace. 'mount' specifies the target mount point on OS. | <pre>object({<br>    name       = string<br>    processors = string<br>    memory     = string<br>    proc_type  = string<br>    storage_config = list(object({<br>      name  = string<br>      size  = string<br>      count = string<br>      tier  = string<br>      mount = string<br>      pool  = optional(string)<br>    }))<br>  })</pre> | <pre>{<br>  "memory": "2",<br>  "name": "share",<br>  "proc_type": "shared",<br>  "processors": "0.5",<br>  "storage_config": [<br>    {<br>      "count": "1",<br>      "mount": "/sapmnt",<br>      "name": "sapmnt",<br>      "size": "300",<br>      "tier": "tier3"<br>    },<br>    {<br>      "count": "1",<br>      "mount": "/usr/trans",<br>      "name": "trans",<br>      "size": "50",<br>      "tier": "tier3"<br>    }<br>  ]<br>}</pre> | no |
