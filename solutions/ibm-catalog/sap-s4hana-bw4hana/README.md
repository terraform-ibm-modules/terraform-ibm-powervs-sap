# IBM Cloud Catalog - Power Virtual Server for SAP HANA : 'SAP S/4HANA or SAP BW/4HANA'

# Summary
## Summary Outcome:
   SAP S/4HANA or SAP BW/4HANA installation configuration to IBM PowerVS hosts.

|                                  Variation                                  | Available on IBM Catalog | Requires Schematics Workspace ID | Creates PowerVS with VPC landing zone | Creates PowerVS HANA Instance | Creates PowerVS NW Instances | Performs PowerVS OS Config | Performs PowerVS SAP Tuning | Install SAP software |
|:---------------------------------------------------------------------------:|:------------------------:|:--------------------------------:|:-------------------------------------:|:-----------------------------:|:----------------------------:|:--------------------------:|:---------------------------:|:--------------------:|
| [ IBM catalog SAP S/4HANA or BW/4HANA variation ]( ./) |    :heavy_check_mark:    |        :heavy_check_mark:        |                  N/A                  |               1               |            1            |     :heavy_check_mark:     |      :heavy_check_mark:     |          :heavy_check_mark:         |

## Architecture Diagram
![sap-s4hana-bw4hana](https://github.com/terraform-ibm-modules/terraform-ibm-powervs-sap/blob/main/reference-architectures/sap-s4hana-bw4hana/deploy-arch-ibm-pvs-sap-s4hana-bw4hana.svg)

## Overview
1. [Summary Tasks](#summary-tasks)
2. [Before you begin](#before-you-begin)
3. [Notes](#notes)
4. [Prerequisites](#prerequisites)
5. [Post Deployment](#post-deployment)
6. [Storage setup](#storage-setup)
7. [Ansible roles used](#ansible-roles-used)

- Creates a new private subnet for SAP communication for the entire landscape.
- Creates and configures one PowerVS instance for SAP HANA based on best practices for HANA database.
- Creates and configures one PowerVS instance for SAP NetWeaver based on best practices, hosting the PAS and ASCS instances.
- Creates and configures one optional PowerVS instance for sharing SAP files between other system instances.
- Connects all created PowerVS instances to a proxy server specified by IP address or hostname.
- Optionally connects all created PowerVS instances to an NTP server and DNS forwarder specified by IP address or hostname.
- Optionally configures a shared NFS directory on all created PowerVS instances.
- Supports installation of **S/4HANA2023, S/4HANA2022, S/4HANA2021, S/4HANA2020, BW/4HANA2021**.
- Supports installation using **Maintenance Planner** as well.


## Before you begin
1. **It is required to have an existing IBM Cloud Object Storage (COS) instance**. Within the instance, an Object Storage Bucket containing the **SAP Software installation media files is required in the correct folder structure as defined** [here](#2-sap-binaries-required-for-installation-and-folder-structure-in-ibm-cloud-object-storage-bucket).

2. **This solution requires a schematics workspace id as an input.**
- If you do not have a [Power Virtual Server with VPC landing zone deployment](https://cloud.ibm.com/catalog/architecture/deploy-arch-ibm-pvs-inf-2dd486c7-b317-4aaa-907b-42671485ad96-global?catalog_query=aHR0cHM6Ly9jbG91ZC5pYm0uY29tL2NhdGFsb2c%2Fc2VhcmNoPXBvd2VyI3NlYXJjaF9yZXN1bHRz) that is the full stack solution for a PowerVS Workspace with Secure Landing Zone, create it first.


## Notes
- Filesystem sizes for HANA data and HANA log are **calculated automatically** based on the **memory size**.
- Custom storage configuration by providing custom volume size, **iops**(tier0, tier1, tier3, tier5k), counts and mount points is supported.
- If **sharefs instance is enabled**, then all filesystems provisioned for sharefs instance will be **NFS exported and mounted** on all NetWeaver Instances.
- **Do not specify** a filesystem `/sapmnt` explicitly for NetWeaver instance as it is created internally when sharefs instance is not enabled.

## Prerequisites
### 1. IBM Cloud Object Storage service credentials
1. Recommended to have a COS instance in the same region where the S/4HANA or BW/4HANA deployment is planned, as copying the files onto the LPAR will be faster.
2. The 'ibmcloud_cos_service_credentials' variable requires a value in JSON format. This can be obtained using the instructions [here](https://cloud.ibm.com/docs/cloud-object-storage?topic=cloud-object-storage-service-credentials)

### 2. SAP binaries required for installation and folder structure in IBM Cloud Object Storage bucket
1. All binaries for HANA database and SAP solution (S/4HANA or BW/4HANA) must be uploaded to the IBM Cloud Object Storage Instance bucket in IBM Cloud before starting this deployment.
2. For example the binaries required for S/4HANA 2023 and BW/4HANA 2021 are listed [here](./docs/s4hana23_bw4hana21_binaries.md).
3. Example folder structure :
```
S4HANA_2023
|
|_HANA_DB
| |_all IMDB* Files and SAPCAR files (all files similar to listed in point 2 above example file)
|
|_S4HANA_2023
  |_all files similar to listed in point 2 above example file
  |maintenance planner stack xml file (optional)
```
**Do not mix the HANA DB binaries with the S/4HANA or BW/4HANA solution binaries otherwise the ansible playbook execution will fail.**

4. If you have a **maintenance planner stack XML** file, place it under the **same folder as S4HANA_2023** and not under the HANA DB directory. Applies to all other versions as well. Mention only the name of this file in **'cos_swpm_mp_stack_file_name'**. Leave it **empty** if you do not have this stack XML file.

5. The **'ibmcloud_cos_configuration'** variable must be set correctly based on the folder structure created.

   `cos_region`: region of IBM Cloud Object Storage instance bucket. Example: **eu-gb**

   `cos_bucket_name`: cos bucket name

   `cos_hana_software_path`: folder path to HANA db binaries from the root of the bucket. Example from point 3, the value would be: **"s4hana2023/HANA_DB"**

   `cos_solution_software_path`: folder path to S/4HANA binaries from the root of the bucket. Example from point 3, the value would be: **"s4hana2023/S4HANA_2023"**

   `cos_swpm_mp_stack_file_name`: Stack XML file name. Value must be set to empty `''` if not available. If value is provided, then this file **must be present** in the same path as `'cos_solution_software_path'`.


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
/sapmnt  300GB (only if sharefs instance is not provisioned)
```

*Note: Supports custom storage configuration using provided optional variables.*

### 3. Sharefs Instance:
**Default values:**
```
/sapmnt    300GB
/usr/trans 50GB
```

*Note: Supports custom storage configuration using provided optional variables.*


## Ansible roles used
1. **[RHEL System Roles](https://access.redhat.com/articles/4488731):** `sap_hana_install, sap_swpm, sap_general_preconfigure, sap_hana_preconfigure, sap_netweaver_preconfigure`
2. **[IBM Role](https://galaxy.ansible.com/ui/repo/published/ibm/power_linux_sap/):** `power_linux_sap`



### Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3, < 1.6 |
| <a name="requirement_ibm"></a> [ibm](#requirement\_ibm) | =1.63.0 |

### Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_ansible_sap_install_hana"></a> [ansible\_sap\_install\_hana](#module\_ansible\_sap\_install\_hana) | ../../../modules/remote-exec-ansible-sap-install | n/a |
| <a name="module_ansible_sap_install_netweaver"></a> [ansible\_sap\_install\_netweaver](#module\_ansible\_sap\_install\_netweaver) | ../../../modules/remote-exec-ansible-sap-install | n/a |
| <a name="module_ibmcloud_cos_download_hana_binaries"></a> [ibmcloud\_cos\_download\_hana\_binaries](#module\_ibmcloud\_cos\_download\_hana\_binaries) | ../../../modules/ibmcloud-cos | n/a |
| <a name="module_ibmcloud_cos_download_netweaver_binaries"></a> [ibmcloud\_cos\_download\_netweaver\_binaries](#module\_ibmcloud\_cos\_download\_netweaver\_binaries) | ../../../modules/ibmcloud-cos | n/a |
| <a name="module_sap_system"></a> [sap\_system](#module\_sap\_system) | ../../../modules/pi-sap-system-type1 | n/a |

### Resources

| Name | Type |
|------|------|
| [ibm_schematics_output.schematics_output](https://registry.terraform.io/providers/IBM-Cloud/ibm/1.60.0/docs/data-sources/schematics_output) | data source |
| [ibm_schematics_workspace.schematics_workspace](https://registry.terraform.io/providers/IBM-Cloud/ibm/1.60.0/docs/data-sources/schematics_workspace) | data source |

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_ansible_vault_password"></a> [ansible\_vault\_password](#input\_ansible\_vault\_password) | Vault password to encrypt SAP installation parameters in the OS. | `string` | n/a | yes |
| <a name="input_ibmcloud_api_key"></a> [ibmcloud\_api\_key](#input\_ibmcloud\_api\_key) | IBM Cloud platform API key needed to deploy IAM enabled resources. | `string` | n/a | yes |
| <a name="input_ibmcloud_cos_configuration"></a> [ibmcloud\_cos\_configuration](#input\_ibmcloud\_cos\_configuration) | Cloud Object Storage instance containing SAP installation files that will be downloaded to NFS share. 'cos\_hana\_software\_path' must contain only binaries required for HANA DB installation. 'cos\_solution\_software\_path' must contain only binaries required for S/4HANA or BW/4HANA installation and must not contain any IMDB files. If you have an optional stack xml file (maintenance planner), place it under the 'cos\_solution\_software\_path' directory. Avoid inserting '/' at the beginning for 'cos\_hana\_software\_path' and 'cos\_solution\_software\_path'. | <pre>object({<br>    cos_region                  = string<br>    cos_bucket_name             = string<br>    cos_hana_software_path      = string<br>    cos_solution_software_path  = string<br>    cos_swpm_mp_stack_file_name = string<br>  })</pre> | <pre>{<br>  "cos_bucket_name": "powervs-automation",<br>  "cos_hana_software_path": "HANA_DB/rev66",<br>  "cos_region": "eu-geo",<br>  "cos_solution_software_path": "S4HANA_2022",<br>  "cos_swpm_mp_stack_file_name": ""<br>}</pre> | no |
| <a name="input_ibmcloud_cos_service_credentials"></a> [ibmcloud\_cos\_service\_credentials](#input\_ibmcloud\_cos\_service\_credentials) | IBM Cloud Object Storage instance service credentials to access the bucket in the instance.[json example of service credential](https://cloud.ibm.com/docs/cloud-object-storage?topic=cloud-object-storage-service-credentials) | `string` | n/a | yes |
| <a name="input_powervs_create_separate_sharefs_instance"></a> [powervs\_create\_separate\_sharefs\_instance](#input\_powervs\_create\_separate\_sharefs\_instance) | Deploy separate IBM PowerVS instance as central file system share. All filesystems defined in 'powervs\_sharefs\_instance\_storage\_config' variable will be NFS exported and mounted on SAP NetWeaver PowerVS instances if enabled. Optional parameter 'powervs\_share\_fs\_instance' can be configured if enabled. | `bool` | n/a | yes |
| <a name="input_powervs_default_sap_images"></a> [powervs\_default\_sap\_images](#input\_powervs\_default\_sap\_images) | Default Red Hat Linux images to use for PowerVS SAP HANA and SAP NetWeaver instances. | <pre>object({<br>    rhel_hana_image = string<br>    rhel_nw_image   = string<br>  })</pre> | <pre>{<br>  "rhel_hana_image": "RHEL9-SP2-SAP",<br>  "rhel_nw_image": "RHEL9-SP2-SAP-NETWEAVER"<br>}</pre> | no |
| <a name="input_powervs_hana_instance_additional_storage_config"></a> [powervs\_hana\_instance\_additional\_storage\_config](#input\_powervs\_hana\_instance\_additional\_storage\_config) | Additional File systems to be created and attached to PowerVS SAP HANA instance. 'size' is in GB. 'count' specify over how many storage volumes the file system will be striped. 'tier' specifies the storage tier in PowerVS workspace. 'mount' specifies the target mount point on OS. | <pre>list(object({<br>    name  = string<br>    size  = string<br>    count = string<br>    tier  = string<br>    mount = string<br>  }))</pre> | <pre>[<br>  {<br>    "count": "1",<br>    "mount": "/usr/sap",<br>    "name": "usrsap",<br>    "size": "50",<br>    "tier": "tier3"<br>  }<br>]</pre> | no |
| <a name="input_powervs_hana_instance_custom_storage_config"></a> [powervs\_hana\_instance\_custom\_storage\_config](#input\_powervs\_hana\_instance\_custom\_storage\_config) | Custom file systems to be created and attached to PowerVS SAP HANA instance. 'size' is in GB. 'count' specify over how many storage volumes the file system will be striped. 'tier' specifies the storage tier in PowerVS workspace. 'mount' specifies the target mount point on OS. | <pre>list(object({<br>    name  = string<br>    size  = string<br>    count = string<br>    tier  = string<br>    mount = string<br>  }))</pre> | <pre>[<br>  {<br>    "count": "",<br>    "mount": "",<br>    "name": "",<br>    "size": "",<br>    "tier": ""<br>  }<br>]</pre> | no |
| <a name="input_powervs_hana_instance_name"></a> [powervs\_hana\_instance\_name](#input\_powervs\_hana\_instance\_name) | PowerVS SAP HANA instance hostname (non FQDN). Will get the form of <var.prefix>-<var.powervs\_hana\_instance\_name>. Max length of final hostname must be <= 13 characters. | `string` | `"hana"` | no |
| <a name="input_powervs_hana_instance_sap_profile_id"></a> [powervs\_hana\_instance\_sap\_profile\_id](#input\_powervs\_hana\_instance\_sap\_profile\_id) | PowerVS SAP HANA instance profile to use. Must be one of the supported profiles. See [here](https://cloud.ibm.com/docs/sap?topic=sap-hana-iaas-offerings-profiles-power-vs). File system sizes are automatically calculated. Override automatic calculation by setting values in optional parameter 'powervs\_hana\_instance\_custom\_storage\_config'. | `string` | `"ush1-4x256"` | no |
| <a name="input_powervs_netweaver_cpu_number"></a> [powervs\_netweaver\_cpu\_number](#input\_powervs\_netweaver\_cpu\_number) | Number of CPUs for PowerVS SAP NetWeaver instance. | `string` | `"3"` | no |
| <a name="input_powervs_netweaver_instance_name"></a> [powervs\_netweaver\_instance\_name](#input\_powervs\_netweaver\_instance\_name) | PowerVS SAP NetWeaver instance hostname (non FQDN). Will get the form of <var.prefix>-<var.powervs\_netweaver\_instance\_name>-<number>. Max length of final hostname must be <= 13 characters. | `string` | `"nw"` | no |
| <a name="input_powervs_netweaver_instance_storage_config"></a> [powervs\_netweaver\_instance\_storage\_config](#input\_powervs\_netweaver\_instance\_storage\_config) | File systems to be created and attached to PowerVS SAP NetWeaver instance. 'size' is in GB. 'count' specify over how many storage volumes the file system will be striped. 'tier' specifies the storage tier in PowerVS workspace. 'mount' specifies the target mount point on OS. Do not specify volume for 'sapmnt' as this will be created internally if 'powervs\_create\_separate\_sharefs\_instance' is false, else 'sapmnt' will mounted from sharefs instance. | <pre>list(object({<br>    name  = string<br>    size  = string<br>    count = string<br>    tier  = string<br>    mount = string<br>  }))</pre> | <pre>[<br>  {<br>    "count": "1",<br>    "mount": "/usr/sap",<br>    "name": "usrsap",<br>    "size": "50",<br>    "tier": "tier3"<br>  }<br>]</pre> | no |
| <a name="input_powervs_netweaver_memory_size"></a> [powervs\_netweaver\_memory\_size](#input\_powervs\_netweaver\_memory\_size) | Memory size for PowerVS SAP NetWeaver instance. | `string` | `"32"` | no |
| <a name="input_powervs_sap_network_cidr"></a> [powervs\_sap\_network\_cidr](#input\_powervs\_sap\_network\_cidr) | Network range for dedicated SAP network. Used for communication between SAP Application servers with SAP HANA Database. E.g., '10.53.0.0/24' | `string` | `"10.53.0.0/24"` | no |
| <a name="input_powervs_sharefs_instance"></a> [powervs\_sharefs\_instance](#input\_powervs\_sharefs\_instance) | Share fs instance. This parameter is effective if 'powervs\_create\_separate\_sharefs\_instance' is set to true. size' is in GB. 'count' specify over how many storage volumes the file system will be striped. 'tier' specifies the storage tier in PowerVS workspace. 'mount' specifies the target mount point on OS. | <pre>object({<br>    name       = string<br>    processors = string<br>    memory     = string<br>    proc_type  = string<br>    storage_config = list(object({<br>      name  = string<br>      size  = string<br>      count = string<br>      tier  = string<br>      mount = string<br>    }))<br>  })</pre> | <pre>{<br>  "memory": "2",<br>  "name": "share",<br>  "proc_type": "shared",<br>  "processors": "0.5",<br>  "storage_config": [<br>    {<br>      "count": "1",<br>      "mount": "/sapmnt",<br>      "name": "sapmnt",<br>      "size": "300",<br>      "tier": "tier3"<br>    },<br>    {<br>      "count": "1",<br>      "mount": "/usr/trans",<br>      "name": "trans",<br>      "size": "50",<br>      "tier": "tier3"<br>    }<br>  ]<br>}</pre> | no |
| <a name="input_powervs_zone"></a> [powervs\_zone](#input\_powervs\_zone) | IBM Cloud data center location corresponding to the location used in 'Power Virtual Server with VPC landing zone' pre-requisite deployment. | `string` | n/a | yes |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | Unique prefix for resources to be created (e.g., SAP system name). Max length must be less than or equal to 6. | `string` | n/a | yes |
| <a name="input_prerequisite_workspace_id"></a> [prerequisite\_workspace\_id](#input\_prerequisite\_workspace\_id) | IBM Cloud Schematics workspace ID of an existing 'Power Virtual Server with VPC landing zone' catalog solution. If you do not yet have an existing deployment, click [here](https://cloud.ibm.com/catalog/architecture/deploy-arch-ibm-pvs-inf-2dd486c7-b317-4aaa-907b-42671485ad96-global?) to create one. | `string` | n/a | yes |
| <a name="input_sap_domain"></a> [sap\_domain](#input\_sap\_domain) | SAP network domain name. | `string` | `"sap.com"` | no |
| <a name="input_sap_hana_master_password"></a> [sap\_hana\_master\_password](#input\_sap\_hana\_master\_password) | SAP HANA master password. | `string` | n/a | yes |
| <a name="input_sap_hana_vars"></a> [sap\_hana\_vars](#input\_sap\_hana\_vars) | SAP HANA SID and instance number. | <pre>object({<br>    sap_hana_install_sid    = string<br>    sap_hana_install_number = string<br>  })</pre> | <pre>{<br>  "sap_hana_install_number": "02",<br>  "sap_hana_install_sid": "HDB"<br>}</pre> | no |
| <a name="input_sap_solution"></a> [sap\_solution](#input\_sap\_solution) | SAP Solution to be installed on Power Virtual Server. | `string` | n/a | yes |
| <a name="input_sap_solution_vars"></a> [sap\_solution\_vars](#input\_sap\_solution\_vars) | SAP SID, ASCS and PAS instance numbers. | <pre>object({<br>    sap_swpm_sid              = string<br>    sap_swpm_ascs_instance_nr = string<br>    sap_swpm_pas_instance_nr  = string<br><br>  })</pre> | <pre>{<br>  "sap_swpm_ascs_instance_nr": "00",<br>  "sap_swpm_pas_instance_nr": "01",<br>  "sap_swpm_sid": "S4H"<br>}</pre> | no |
| <a name="input_sap_swpm_master_password"></a> [sap\_swpm\_master\_password](#input\_sap\_swpm\_master\_password) | SAP SWPM master password. | `string` | n/a | yes |
| <a name="input_ssh_private_key"></a> [ssh\_private\_key](#input\_ssh\_private\_key) | Private SSH key (RSA format) used to login to IBM PowerVS instances. Should match to uploaded public SSH key referenced by 'ssh\_public\_key' which was created previously. Entered data must be in [heredoc strings format](https://www.terraform.io/language/expressions/strings#heredoc-strings). The key is not uploaded or stored. For more information about SSH keys, see [SSH keys](https://cloud.ibm.com/docs/vpc?topic=vpc-ssh-keys). | `string` | n/a | yes |

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
| <a name="output_powervs_sharefs_instance_ips"></a> [powervs\_sharefs\_instance\_ips](#output\_powervs\_sharefs\_instance\_ips) | Private IPs of the Share FS instance. |
| <a name="output_sap_hana_vars"></a> [sap\_hana\_vars](#output\_sap\_hana\_vars) | SAP HANA system details. |
| <a name="output_sap_solution_vars"></a> [sap\_solution\_vars](#output\_sap\_solution\_vars) | SAP NetWeaver system details. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
