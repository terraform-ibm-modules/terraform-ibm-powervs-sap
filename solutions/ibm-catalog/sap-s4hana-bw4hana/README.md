# IBM Cloud Catalog - Power Virtual Server for SAP HANA : 'SAP S/4HANA or SAP BW/4HANA'

# Summary

## Summary Outcome:
   SAP S/4HANA or SAP BW/4HANA installation configuration to IBM PowerVS hosts.

|                                  Variation                                  | Available on IBM Catalog | Requires Schematics Workspace ID | Creates PowerVS with VPC landing zone | Creates PowerVS HANA Instance | Creates PowerVS NW Instances | Performs PowerVS OS Config | Performs PowerVS SAP Tuning | Install SAP software |
|:---------------------------------------------------------------------------:|:------------------------:|:--------------------------------:|:-------------------------------------:|:-----------------------------:|:----------------------------:|:--------------------------:|:---------------------------:|:--------------------:|
| [IBM catalog SAP S/4HANA or BW/4HANA variation]( ./) |    :heavy_check_mark:    |        :heavy_check_mark:        |        :heavy_check_mark:        |               1               |            1            |     :heavy_check_mark:     |      :heavy_check_mark:     |          :heavy_check_mark:         |

## Architecture Diagram
![sap-s4hana-bw4hana](https://github.com/terraform-ibm-modules/terraform-ibm-powervs-sap/blob/main/reference-architectures/sap-s4hana-bw4hana/deploy-arch-ibm-pvs-sap-s4hana-bw4hana.svg)

## Overview
1. [Summary Tasks](#summary-tasks)
2. [Before you begin](#before-you-begin)
3. [Notes](#notes)
4. [Post Deployment](#post-deployment)
5. [Storage setup](#storage-setup)
6. [Ansible roles used](#ansible-roles-used)

- A **VPC Infrastructure** with the following components:
    - One VSI for management (jump/bastion)
    - One VSI for network-services configured as squid proxy, NTP and DNS servers(using Ansible Galaxy collection roles [ibm.power_linux_sap collection](https://galaxy.ansible.com/ui/repo/published/ibm/power_linux_sap/). This VSI also acts as central ansible execution node.
    - Optional VSI for Monitoring host
    - Optional [Client to site VPN server](https://cloud.ibm.com/docs/vpc?topic=vpc-vpn-client-to-site-overview)
    - Optional [File storage share](https://cloud.ibm.com/docs/vpc?topic=vpc-file-storage-create&interface=ui)
    - Optional [Network load balancer](https://cloud.ibm.com/docs/vpc?group=network-load-balancer)
    - Optional [IBM Cloud Security and Compliance Center Workload Protection](https://cloud.ibm.com/docs/workload-protection) and SCC Workload Protection agent configuration on the VSIs in the deployment
    - IBM Cloud Object storage(COS) Virtual Private endpoint gateway(VPE)
    - IBM Cloud Object storage(COS) Instance and buckets
    - VPC flow logs
    - KMS keys
    - Activity tracker
    - Optional Secrets Manager Instance Instance with private certificate.

- A local or global **transit gateway**
- An optional IBM Cloud Monitoring Instance

- A **Power Virtual Server** workspace with the following network topology:
    - Creates a new private subnet for SAP communication for the entire landscape.
    - Attaches the PowerVS workspace to transit gateway.
    - Creates an SSH key.
    - Optionally imports up to two custom images from Cloud Object Storage.
- Creates and configures one PowerVS instance for SAP HANA based on best practices for HANA database.
- Creates and configures one PowerVS instance for SAP NetWeaver based on best practices, hosting the PAS and ASCS instances.
- Optionally let's the user choose a byol or custom os image for the HANA and Netweaver PowerVS instances and activate it with user provided os registration credentials.
- Creates and configures one optional PowerVS instance for sharing SAP files between other system instances.
- Connects all created PowerVS instances to a proxy server specified by IP address or hostname.
- Optionally connects all created PowerVS instances to an NTP server and DNS forwarder specified by IP address or hostname.
- Optionally configures a shared NFS directory on all created PowerVS instances.
- Optionally configures the monitoring host to collect relevant information from the Database and application servers and send it to the IBM Cloud® Monitoring Instance
- Optionally installs Sysdig agent and configures connection to [IBM Cloud Security and Compliance Center Workload Protection](https://cloud.ibm.com/docs/workload-protection)
- Supports installation of **S/4HANA2023, S/4HANA2022, S/4HANA2021, S/4HANA2020, BW/4HANA2021**.
- Supports installation using **Maintenance Planner** as well.
- Optionally installs and configures SAP Monitoring host and dashboard, if monitoring instance was deployed as part of [Power Virtual Server with VPC landing zone deployment](https://cloud.ibm.com/catalog/architecture/deploy-arch-ibm-pvs-inf-2dd486c7-b317-4aaa-907b-42671485ad96-global?catalog_query=aHR0cHM6Ly9jbG91ZC5pYm0uY29tL2NhdGFsb2c%2Fc2VhcmNoPXBvd2VyI3NlYXJjaF9yZXN1bHRz).


## Before you begin
1. **It is required to have an existing IBM Cloud Object Storage (COS) instance**. Within the instance, an Object Storage Bucket containing the **SAP Software installation media files is required in the correct folder structure as defined** [here](#2-sap-binaries-required-for-installation-and-folder-structure-in-ibm-cloud-object-storage-bucket).


## Notes
- Filesystem sizes for HANA data and HANA log are **calculated automatically** based on the **memory size**.
- Custom storage configuration by providing custom volume size, **iops**(tier0, tier1, tier3, tier5k), counts and mount points is supported.



## Post Deployment
1. All the installation logs and Ansible playbook files will be under the directory `/root/terraform_files/`.
2. The **ansible vault password** will be used to encrypt the Ansible playbook file created during deployment. This playbook file will be placed under `/root/terraform_files/sap-hana-install.yml` on the **HANA instance** and `/root/terraform_files/sap-swpm-install-vars.yml` on the **NetWeaver Instance**.
3. This file can be decrypted using the same value passed to variable **'ansible_vault_password'** during deployment. Use the command `ansible-vault decrypt /root/terraform_files/sap-swpm-install-vars.yml` and enter the password when prompted.

## Storage setup

### 1. HANA Instance:
**Default values:**
```
/hana/shared (size auto calculated based on memory)
/hana/data   (size auto calculated based on memory)
/hana/log    (size auto calculated based on memory)
/usr/sap     50GB
```

*Note: Supports custom storage configuration using provided optional variables.*

### 2. Netweaver Instance:
**Default values:**
```
/usr/sap 50GB
/sapmnt  300GB
```

*Note: Supports custom storage configuration using provided optional variables.*


## Ansible roles used
1. **[RHEL System Roles](https://access.redhat.com/articles/4488731):** `sap_hana_install, sap_swpm, sap_general_preconfigure, sap_hana_preconfigure, sap_netweaver_preconfigure`
2. **[IBM Role](https://galaxy.ansible.com/ui/repo/published/ibm/power_linux_sap/):** `power_linux_sap`


<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
### Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9.0 |
| <a name="requirement_ibm"></a> [ibm](#requirement\_ibm) | 1.84.1 |
| <a name="requirement_restapi"></a> [restapi](#requirement\_restapi) | 2.0.1 |

### Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_ansible_monitoring_sap_install_solution"></a> [ansible\_monitoring\_sap\_install\_solution](#module\_ansible\_monitoring\_sap\_install\_solution) | ../../../modules/ansible | n/a |
| <a name="module_ansible_sap_install_hana"></a> [ansible\_sap\_install\_hana](#module\_ansible\_sap\_install\_hana) | ../../../modules/ansible | n/a |
| <a name="module_ansible_sap_install_solution"></a> [ansible\_sap\_install\_solution](#module\_ansible\_sap\_install\_solution) | ../../../modules/ansible | n/a |
| <a name="module_ibmcloud_cos_download_hana_binaries"></a> [ibmcloud\_cos\_download\_hana\_binaries](#module\_ibmcloud\_cos\_download\_hana\_binaries) | ../../../modules/ibmcloud-cos | n/a |
| <a name="module_ibmcloud_cos_download_monitoring_binaries"></a> [ibmcloud\_cos\_download\_monitoring\_binaries](#module\_ibmcloud\_cos\_download\_monitoring\_binaries) | ../../../modules/ibmcloud-cos | n/a |
| <a name="module_ibmcloud_cos_download_netweaver_binaries"></a> [ibmcloud\_cos\_download\_netweaver\_binaries](#module\_ibmcloud\_cos\_download\_netweaver\_binaries) | ../../../modules/ibmcloud-cos | n/a |
| <a name="module_sap_system"></a> [sap\_system](#module\_sap\_system) | ../../../modules/pi-sap-system-type1 | n/a |
| <a name="module_standard"></a> [standard](#module\_standard) | terraform-ibm-modules/powervs-infrastructure/ibm//modules/powervs-vpc-landing-zone | 10.2.0 |

### Resources

| Name | Type |
|------|------|
| [ibm_iam_auth_token.auth_token](https://registry.terraform.io/providers/IBM-Cloud/ibm/1.84.1/docs/data-sources/iam_auth_token) | data source |
| [ibm_pi_catalog_images.catalog_images_ds](https://registry.terraform.io/providers/IBM-Cloud/ibm/1.84.1/docs/data-sources/pi_catalog_images) | data source |
| [ibm_pi_image.custom_images](https://registry.terraform.io/providers/IBM-Cloud/ibm/1.84.1/docs/data-sources/pi_image) | data source |

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_ansible_vault_password"></a> [ansible\_vault\_password](#input\_ansible\_vault\_password) | Vault password to encrypt ansible playbooks that contain sensitive information. Required when SCC workload Protection is enabled. Password requirements: 15-100 characters and at least one uppercase letter, one lowercase letter, one number, and one special character. Allowed characters: A-Z, a-z, 0-9, !#$%&()*+-.:;<=>?@[]\_{\|}~. | `string` | n/a | yes |
| <a name="input_client_to_site_vpn"></a> [client\_to\_site\_vpn](#input\_client\_to\_site\_vpn) | VPN configuration - the client ip pool and list of users email ids to access the environment. If enabled, then a Secret Manager instance is also provisioned with certificates generated. See optional parameters to reuse an existing Secrets manager instance. | <pre>object({<br/>    enable                        = bool<br/>    client_ip_pool                = string<br/>    vpn_client_access_group_users = list(string)<br/>  })</pre> | <pre>{<br/>  "client_ip_pool": "192.168.0.0/16",<br/>  "enable": true,<br/>  "vpn_client_access_group_users": []<br/>}</pre> | no |
| <a name="input_enable_monitoring"></a> [enable\_monitoring](#input\_enable\_monitoring) | Specify whether Monitoring will be enabled. This includes the creation of an IBM Cloud Monitoring Instance and an Intel Monitoring Instance to host the services. | `bool` | n/a | yes |
| <a name="input_enable_scc_wp"></a> [enable\_scc\_wp](#input\_enable\_scc\_wp) | Set to true to enable SCC Workload Protection and install and configure the SCC Workload Protection agent on all VSIs and PowerVS instances in this deployment. | `bool` | n/a | yes |
| <a name="input_existing_sm_instance_guid"></a> [existing\_sm\_instance\_guid](#input\_existing\_sm\_instance\_guid) | An existing Secrets Manager GUID. If not provided a new instance will be provisioned. | `string` | `null` | no |
| <a name="input_existing_sm_instance_region"></a> [existing\_sm\_instance\_region](#input\_existing\_sm\_instance\_region) | Required if value is passed into `var.existing_sm_instance_guid`. | `string` | `null` | no |
| <a name="input_external_access_ip"></a> [external\_access\_ip](#input\_external\_access\_ip) | Specify the IP address or CIDR to login through SSH to the environment after deployment. Access to this environment will be allowed only from this IP address. | `string` | n/a | yes |
| <a name="input_ibmcloud_api_key"></a> [ibmcloud\_api\_key](#input\_ibmcloud\_api\_key) | IBM Cloud platform API key needed to deploy IAM enabled resources. | `string` | n/a | yes |
| <a name="input_ibmcloud_cos_configuration"></a> [ibmcloud\_cos\_configuration](#input\_ibmcloud\_cos\_configuration) | Cloud Object Storage instance containing SAP installation files that will be downloaded to NFS share. 'cos\_hana\_software\_path' must contain only binaries required for HANA DB installation. 'cos\_solution\_software\_path' must contain only binaries required for S/4HANA or BW/4HANA installation and must not contain any IMDB files. 'cos\_monitoring\_software\_path' is optional and must contain x86\_64 SAPCAR and SAP HANA client binaries required for configuring monitoring instance. The binaries required for installation can be found [here](https://github.com/terraform-ibm-modules/terraform-ibm-powervs-sap/blob/main/solutions/ibm-catalog/sap-s4hana-bw4hana/docs/s4hana23_bw4hana21_binaries.md) If you have an optional stack xml file (maintenance planner), place it under the 'cos\_solution\_software\_path' directory. Avoid inserting '/' at the beginning for 'cos\_hana\_software\_path', 'cos\_solution\_software\_path' and 'cos\_monitoring\_software\_path'. | <pre>object({<br/>    cos_region                   = string<br/>    cos_bucket_name              = string<br/>    cos_hana_software_path       = string<br/>    cos_solution_software_path   = string<br/>    cos_monitoring_software_path = optional(string)<br/>    cos_swpm_mp_stack_file_name  = string<br/>  })</pre> | <pre>{<br/>  "cos_bucket_name": "powervs-automation",<br/>  "cos_hana_software_path": "HANA_DB/rev87",<br/>  "cos_monitoring_software_path": "HANA_CLIENT/x86_64",<br/>  "cos_region": "eu-geo",<br/>  "cos_solution_software_path": "S4HANA_2023",<br/>  "cos_swpm_mp_stack_file_name": ""<br/>}</pre> | no |
| <a name="input_ibmcloud_cos_service_credentials"></a> [ibmcloud\_cos\_service\_credentials](#input\_ibmcloud\_cos\_service\_credentials) | IBM Cloud Object Storage instance service credentials to access the bucket in the instance.[json example of service credential](https://cloud.ibm.com/docs/cloud-object-storage?topic=cloud-object-storage-service-credentials) | `string` | n/a | yes |
| <a name="input_nfs_server_config"></a> [nfs\_server\_config](#input\_nfs\_server\_config) | Configuration for the NFS server. 'size' is in GB, 'iops' is maximum input/output operation performance bandwidth per second, 'mount\_path' defines the target mount point on os. Set 'configure\_nfs\_server' to false to ignore creating file storage share. | <pre>object({<br/>    size       = number<br/>    iops       = number<br/>    mount_path = string<br/>  })</pre> | <pre>{<br/>  "iops": 600,<br/>  "mount_path": "/nfs",<br/>  "size": 200<br/>}</pre> | no |
| <a name="input_powervs_custom_image_cos_configuration"></a> [powervs\_custom\_image\_cos\_configuration](#input\_powervs\_custom\_image\_cos\_configuration) | Cloud Object Storage bucket containing custom PowerVS images. bucket\_name: string, name of the COS bucket. bucket\_access: string, possible values: public, private (private requires powervs\_custom\_image\_cos\_service\_credentials). bucket\_region: string, COS bucket region | <pre>object({<br/>    bucket_name   = string<br/>    bucket_access = string<br/>    bucket_region = string<br/>  })</pre> | <pre>{<br/>  "bucket_access": "",<br/>  "bucket_name": "",<br/>  "bucket_region": ""<br/>}</pre> | no |
| <a name="input_powervs_custom_image_cos_service_credentials"></a> [powervs\_custom\_image\_cos\_service\_credentials](#input\_powervs\_custom\_image\_cos\_service\_credentials) | Service credentials for the Cloud Object Storage bucket containing the custom PowerVS images. The bucket must have HMAC credentials enabled. Click [here](https://cloud.ibm.com/docs/cloud-object-storage?topic=cloud-object-storage-service-credentials) for a json example of a service credential. | `string` | `null` | no |
| <a name="input_powervs_custom_images"></a> [powervs\_custom\_images](#input\_powervs\_custom\_images) | Optionally import up to three custom images from Cloud Object Storage into PowerVS workspace. Requires 'powervs\_custom\_image\_cos\_configuration' to be set. image\_name: string, must be unique. Name of image inside PowerVS workspace. file\_name: string, object key of image inside COS bucket. storage\_tier: string, storage tier which image will be stored in after import. Supported values: tier0, tier1, tier3, tier5k. sap\_type: optional string, Supported values: Hana and Netweaver | <pre>object({<br/>    powervs_custom_image1 = object({<br/>      image_name   = string<br/>      file_name    = string<br/>      storage_tier = string<br/>      sap_type     = optional(string)<br/>    }),<br/>    powervs_custom_image2 = object({<br/>      image_name   = string<br/>      file_name    = string<br/>      storage_tier = string<br/>      sap_type     = optional(string)<br/>    })<br/>  })</pre> | <pre>{<br/>  "powervs_custom_image1": {<br/>    "file_name": "",<br/>    "image_name": "",<br/>    "sap_type": "Hana",<br/>    "storage_tier": ""<br/>  },<br/>  "powervs_custom_image2": {<br/>    "file_name": "",<br/>    "image_name": "",<br/>    "sap_type": "Netweaver",<br/>    "storage_tier": ""<br/>  }<br/>}</pre> | no |
| <a name="input_powervs_default_sap_images"></a> [powervs\_default\_sap\_images](#input\_powervs\_default\_sap\_images) | Default Red Hat Linux Full Linux subscription images to use for PowerVS SAP HANA and SAP NetWeaver instances. If you're using a byol or a custom RHEL image, additionally specify the optional values for 'powervs\_os\_registration\_username', 'powervs\_os\_registration\_password' and 'ansible\_vault\_password' | <pre>object({<br/>    rhel_hana_image = string<br/>    rhel_nw_image   = string<br/>  })</pre> | <pre>{<br/>  "rhel_hana_image": "RHEL9-SP4-SAP",<br/>  "rhel_nw_image": "RHEL9-SP4-SAP-NETWEAVER"<br/>}</pre> | no |
| <a name="input_powervs_hana_instance_additional_storage_config"></a> [powervs\_hana\_instance\_additional\_storage\_config](#input\_powervs\_hana\_instance\_additional\_storage\_config) | Additional File systems to be created and attached to PowerVS SAP HANA instance. 'size' is in GB. 'count' specify over how many storage volumes the file system will be striped. 'tier' specifies the storage tier in PowerVS workspace. 'mount' specifies the target mount point on OS. | <pre>list(object({<br/>    name  = string<br/>    size  = string<br/>    count = string<br/>    tier  = string<br/>    mount = string<br/>  }))</pre> | <pre>[<br/>  {<br/>    "count": "1",<br/>    "mount": "/usr/sap",<br/>    "name": "usrsap",<br/>    "size": "50",<br/>    "tier": "tier3"<br/>  }<br/>]</pre> | no |
| <a name="input_powervs_hana_instance_custom_storage_config"></a> [powervs\_hana\_instance\_custom\_storage\_config](#input\_powervs\_hana\_instance\_custom\_storage\_config) | Custom file systems to be created and attached to PowerVS SAP HANA instance. 'size' is in GB. 'count' specify over how many storage volumes the file system will be striped. 'tier' specifies the storage tier in PowerVS workspace. 'mount' specifies the target mount point on OS. If not specified, volumes for '/hana/data', '/hana/log', '/hana/shared' are automatically calculated and created. | <pre>list(object({<br/>    name  = string<br/>    size  = string<br/>    count = string<br/>    tier  = string<br/>    mount = string<br/>    pool  = optional(string)<br/>  }))</pre> | <pre>[<br/>  {<br/>    "count": "",<br/>    "mount": "",<br/>    "name": "",<br/>    "size": "",<br/>    "tier": ""<br/>  }<br/>]</pre> | no |
| <a name="input_powervs_hana_instance_sap_profile_id"></a> [powervs\_hana\_instance\_sap\_profile\_id](#input\_powervs\_hana\_instance\_sap\_profile\_id) | PowerVS SAP HANA instance profile to use. Must be one of the supported profiles. See [here](https://cloud.ibm.com/docs/sap?topic=sap-hana-iaas-offerings-profiles-power-vs). File system sizes are automatically calculated. Override automatic calculation by setting values in optional parameter 'powervs\_hana\_instance\_custom\_storage\_config'. | `string` | `"sh2-4x256"` | no |
| <a name="input_powervs_netweaver_cpu_number"></a> [powervs\_netweaver\_cpu\_number](#input\_powervs\_netweaver\_cpu\_number) | Number of CPUs for PowerVS SAP NetWeaver instance. | `string` | `"3"` | no |
| <a name="input_powervs_netweaver_instance_storage_config"></a> [powervs\_netweaver\_instance\_storage\_config](#input\_powervs\_netweaver\_instance\_storage\_config) | File systems to be created and attached to PowerVS SAP NetWeaver instance. 'size' is in GB. 'count' specifies over how many storage volumes the file system will be striped. 'tier' specifies the storage tier in PowerVS workspace. 'mount' specifies the target mount point on OS. | <pre>list(object({<br/>    name  = string<br/>    size  = string<br/>    count = string<br/>    tier  = string<br/>    mount = string<br/>    pool  = optional(string)<br/>  }))</pre> | <pre>[<br/>  {<br/>    "count": "1",<br/>    "mount": "/usr/sap",<br/>    "name": "usrsap",<br/>    "size": "50",<br/>    "tier": "tier3"<br/>  }<br/>]</pre> | no |
| <a name="input_powervs_netweaver_memory_size"></a> [powervs\_netweaver\_memory\_size](#input\_powervs\_netweaver\_memory\_size) | Memory size for PowerVS SAP NetWeaver instance. | `string` | `"32"` | no |
| <a name="input_powervs_os_registration_password"></a> [powervs\_os\_registration\_password](#input\_powervs\_os\_registration\_password) | If you're using a byol or a custom RHEL image for SAP HANA and Netweaver you need to provide your OS registration credentials here. Leave empty if you're using an IBM provided subscription (FLS). | `string` | `""` | no |
| <a name="input_powervs_os_registration_username"></a> [powervs\_os\_registration\_username](#input\_powervs\_os\_registration\_username) | If you're using a byol or a custom RHEL image for SAP HANA and Netweaver you need to provide your OS registration credentials here. Leave empty if you're using an IBM provided subscription (FLS). | `string` | `""` | no |
| <a name="input_powervs_resource_group_name"></a> [powervs\_resource\_group\_name](#input\_powervs\_resource\_group\_name) | Existing IBM Cloud resource group name. | `string` | n/a | yes |
| <a name="input_powervs_sap_network_cidr"></a> [powervs\_sap\_network\_cidr](#input\_powervs\_sap\_network\_cidr) | Network range for dedicated SAP network. Used for communication between SAP Application servers with SAP HANA Database. E.g., '10.51.0.0/24' | `string` | `"10.51.0.0/24"` | no |
| <a name="input_powervs_zone"></a> [powervs\_zone](#input\_powervs\_zone) | IBM Cloud data center location where IBM PowerVS infrastructure will be created. | `string` | n/a | yes |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | Unique prefix for resources to be created (e.g., SAP system name). Must be an alphanumeric string with maximum length of 8 characters. | `string` | n/a | yes |
| <a name="input_sap_domain"></a> [sap\_domain](#input\_sap\_domain) | SAP network domain name. | `string` | `"sap.com"` | no |
| <a name="input_sap_hana_master_password"></a> [sap\_hana\_master\_password](#input\_sap\_hana\_master\_password) | SAP HANA master password. | `string` | n/a | yes |
| <a name="input_sap_hana_vars"></a> [sap\_hana\_vars](#input\_sap\_hana\_vars) | SAP HANA SID and instance number. | <pre>object({<br/>    sap_hana_install_sid    = string<br/>    sap_hana_install_number = string<br/>  })</pre> | <pre>{<br/>  "sap_hana_install_number": "02",<br/>  "sap_hana_install_sid": "HDB"<br/>}</pre> | no |
| <a name="input_sap_monitoring_vars"></a> [sap\_monitoring\_vars](#input\_sap\_monitoring\_vars) | Configuration details for SAP monitoring dashboard. Takes effect only when a monitoring instance was deployed as part of Power Virtual Server with VPC landing zone deployment. If 'config\_override' is true, an existing configuration will be overwritten, 'sap\_monitoring\_nr' Two-digit incremental number starting with 01 up to 99. This is not a existing SAP ID, but a pure virtual number and 'sap\_monitoring\_solution\_name' is a virtual arbitrary short name to recognize SAP System. | <pre>object({<br/>    config_override              = bool<br/>    sap_monitoring_nr            = string<br/>    sap_monitoring_solution_name = string<br/>  })</pre> | <pre>{<br/>  "config_override": false,<br/>  "sap_monitoring_nr": "01",<br/>  "sap_monitoring_solution_name": ""<br/>}</pre> | no |
| <a name="input_sap_solution"></a> [sap\_solution](#input\_sap\_solution) | SAP Solution to be installed on Power Virtual Server. | `string` | n/a | yes |
| <a name="input_sap_solution_vars"></a> [sap\_solution\_vars](#input\_sap\_solution\_vars) | SAP SID, ASCS and PAS instance numbers and service/protectedwebmethods parameters. | <pre>object({<br/>    sap_swpm_sid                         = string<br/>    sap_swpm_ascs_instance_nr            = string<br/>    sap_swpm_pas_instance_nr             = string<br/>    sap_swpm_service_protectedwebmethods = string<br/><br/>  })</pre> | <pre>{<br/>  "sap_swpm_ascs_instance_nr": "00",<br/>  "sap_swpm_pas_instance_nr": "01",<br/>  "sap_swpm_service_protectedwebmethods": "SDEFAULT -GetQueueStatistic -ABAPGetWPTable -EnqGetStatistic -GetProcessList -GetEnvironment -BAPGetSystemWPTable",<br/>  "sap_swpm_sid": "S4H"<br/>}</pre> | no |
| <a name="input_sap_swpm_master_password"></a> [sap\_swpm\_master\_password](#input\_sap\_swpm\_master\_password) | SAP SWPM master password. | `string` | n/a | yes |
| <a name="input_sm_service_plan"></a> [sm\_service\_plan](#input\_sm\_service\_plan) | The service/pricing plan to use when provisioning a new Secrets Manager instance. Allowed values: `standard` and `trial`. Only used if `existing_sm_instance_guid` is set to null. | `string` | `"standard"` | no |
| <a name="input_ssh_private_key"></a> [ssh\_private\_key](#input\_ssh\_private\_key) | Private SSH key (RSA format) used to login to IBM PowerVS instances. Should match to uploaded public SSH key referenced by 'ssh\_public\_key' which was created previously. The key is temporarily stored and deleted. For more information about SSH keys, see [SSH keys](https://cloud.ibm.com/docs/vpc?topic=vpc-ssh-keys). | `string` | n/a | yes |
| <a name="input_ssh_public_key"></a> [ssh\_public\_key](#input\_ssh\_public\_key) | Public SSH Key for VSI creation. Must be an RSA key with a key size of either 2048 bits or 4096 bits (recommended). Must be a valid SSH key that does not already exist in the deployment region. | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | List of tag names for the IBM Cloud resources created. | `list(string)` | `[]` | no |
| <a name="input_vpc_intel_images"></a> [vpc\_intel\_images](#input\_vpc\_intel\_images) | Stock OS image names for creating VPC landing zone VSI instances: RHEL (management and network services) and SLES (monitoring). | <pre>object({<br/>    rhel_image = string<br/>    sles_image = string<br/>  })</pre> | <pre>{<br/>  "rhel_image": "ibm-redhat-9-6-amd64-sap-applications-1",<br/>  "sles_image": "ibm-sles-15-7-amd64-sap-applications-1"<br/>}</pre> | no |
| <a name="input_vpc_subnet_cidrs"></a> [vpc\_subnet\_cidrs](#input\_vpc\_subnet\_cidrs) | CIDR values for the VPC subnets to be created. It's customer responsibility that none of the defined networks collide, including the PowerVS subnets and VPN client pool. | <pre>object({<br/>    vpn  = string<br/>    mgmt = string<br/>    vpe  = string<br/>    edge = string<br/>  })</pre> | <pre>{<br/>  "edge": "10.30.40.0/24",<br/>  "mgmt": "10.30.20.0/24",<br/>  "vpe": "10.30.30.0/24",<br/>  "vpn": "10.30.10.0/24"<br/>}</pre> | no |

### Outputs

| Name | Description |
|------|-------------|
| <a name="output_access_host_or_ip"></a> [access\_host\_or\_ip](#output\_access\_host\_or\_ip) | Public IP of Provided Bastion/JumpServer Host. |
| <a name="output_infrastructure_data"></a> [infrastructure\_data](#output\_infrastructure\_data) | PowerVS infrastructure details. |
| <a name="output_powervs_hana_instance_ips"></a> [powervs\_hana\_instance\_ips](#output\_powervs\_hana\_instance\_ips) | All private IPS of HANA instance. |
| <a name="output_powervs_hana_instance_management_ip"></a> [powervs\_hana\_instance\_management\_ip](#output\_powervs\_hana\_instance\_management\_ip) | Management IP of HANA Instance. |
| <a name="output_powervs_lpars_data"></a> [powervs\_lpars\_data](#output\_powervs\_lpars\_data) | All private IPS of PowerVS instances and Jump IP to access the host. |
| <a name="output_powervs_netweaver_instance_ips"></a> [powervs\_netweaver\_instance\_ips](#output\_powervs\_netweaver\_instance\_ips) | All private IPs of NetWeaver instance. |
| <a name="output_powervs_netweaver_instance_management_ip"></a> [powervs\_netweaver\_instance\_management\_ip](#output\_powervs\_netweaver\_instance\_management\_ip) | Management IP of NetWeaver instance. |
| <a name="output_sap_hana_vars"></a> [sap\_hana\_vars](#output\_sap\_hana\_vars) | SAP HANA system details. |
| <a name="output_sap_monitoring_vars"></a> [sap\_monitoring\_vars](#output\_sap\_monitoring\_vars) | SAP Monitoring Instance details. |
| <a name="output_sap_solution_vars"></a> [sap\_solution\_vars](#output\_sap\_solution\_vars) | SAP NetWeaver system details. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
