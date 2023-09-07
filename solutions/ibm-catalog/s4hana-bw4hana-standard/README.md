# Power Virtual Server for SAP HANA solution to create SAP S4HANA or BW4HANA standard installation on PowerVS instances from IBM Cloud Catalog

The Power Virtual Server for SAP HANA example automates the following tasks:

- Creates and configures one PowerVS instance for SAP HANA that is based on best practices.
- Creates and configures One PowerVS instance for SAP NetWeaver that is based on best practices.
- Creates and configures one optional PowerVS instance that can be used for sharing SAP files between other system instances.
- Connects all created PowerVS instances to a proxy server that is specified by IP address or hostname.
- Optionally connects all created PowerVS instances to an NTP server and DNS forwarder that are specified by IP address or hostname.
- Optionally configures a shared NFS directory on all created PowerVS instances.
- Supports installation of **S4HANA2022, S4HANA2021, S4HANA2020, BW4HANA2021.**
- Supports installation using **Maintainance planner** as well.

### Notes:
**This solution does not download any binaries from SAP portal. It is ones duty to have the binaries before hand and have it stored in Cloud object storage bucket as defined [here](#2-sap-binaries-required-for-installation-and-folder-structure-in-cos).

## Before you begin
Note: **This solution requires a schematics workspace id as an input.**
If you do not have a PowerVS infrastructure that is the full stack solution for a PowerVS Workspace that includes the full stack solution for Secure Landing Zone, create it first.

| Variation                       | Available on IBM Catalog | Requires Schematics Workspace ID | Creates PowerVS HANA Instance | Creates PowerVS NW Instances | Creates ShareFS Instance | Performs PowerVS OS Config | Performs PowerVS SAP Tuning | Install SAP software |
|---------------------------------|--------------------------|----------------------------------|-------------------------------|------------------------------|--------------------------|----------------------------|-----------------------------|----------------------|
| s4hana-bw4hana-standard ]( ./ ) | :heavy_check_mark:       | :heavy_check_mark:               | 1                             | 1                            | 0 or 1                   | :heavy_check_mark:         | :heavy_check_mark:          | :heavy_check_mark:   |

## Architecture Diagram
![s4hana-bw4hana-standard](../../../reference-architectures/s4hana-bw4hana-standard/deploy-arch-ibm-pvs-s4hana-bw4hana-standard.svg)


## Prerequisites

### 1. COS service credentials
1. Recommended to have a COS Instance in the same region where the s4hana/bw4hana deployment is planned as copying the files on to the lpar will be faster.
2. **'cos_service_credentials'** variable requires a value in **json format**. This can be obtained using the instructions [here](https://cloud.ibm.com/docs/cloud-object-storage?topic=cloud-object-storage-service-credentials)

### 2. SAP binaries required for installation and folder structure in COS
1. All binaries for HANA database and SAP solution (S4HANA or BW4HANA) must be uploaded to the Cloud object storage bucket in IBM cloud before starting this deployment.
2. For example the binaries required for S4HANA 2022 are listed [here](./docs/s4hana2022_binaries.md).
3. Example folder structure :
```
s4hana2022
|
|_HANA_DB
| |_all IMDB* Files and SAPCAR files (all files similar to listed in point 2 above example file)
|
|_S4HANA_2022
  |_all files similar to listed in point 2 above example file
  |_maintainance planner stack xml file (optional)
```
**Do not mix the HANA DB binaries with the S4HANA/BW4HANA solution binaries otherwise the ansible playbook execution will fail.**

4. If you have a **Maintainance planner stack xml** file, place it under the **same folder as S4HANA_2022** and not under the HANA DB directory. Applies to all other versions as well. Mention only the name of this file in variable **'ansible_sap_solution_vars.sap_swpm_mp_stack_file_name'**. Leave it **empty** if you do not have this stack xml file.
5. **'cos_configuration'** variable needs to be set correctly based on the folder structure created.

   `"cos_region":` region of cos bucket in IBM cloud. Example **eu-gb**\
   `"cos_bucket_name":`  cos bucket name\
   `"cos_hana_software_path":` folder path to hana db binaries from the root of bucket. Example from point 3 the value would be **"s4hana2022/HANA_DB"**\
   `"cos_solution_software_path":` folder path to s4hana binaries from the root of bucket. Example from point 3 the value would be **"s4hana2022/S4HANA_2022"**


## Post Deployment
1. All the installation logs, ansible playbook and variable files will be under the directory `/root/terraform_scripts/`.
2. The **ansible vault password** will be used to encrypt the ansible variable file which was created during deployment. This variable file will be placed under `/root/terraform_scripts/sap-hana-install.yml` on **HANA instance** and `/root/terraform_scripts/sap-swpm-install-vars.yml` on **Netweaver Instance**.
3. This file can be decrypted using the same value passed to variable **'ansible_vault_password'** during deployment. Use the command `ansible-vault decrypt /root/terraform_scripts/sap-swpm-install-vars.yml` and enter the password when prompted.





<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
### Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3, < 1.6 |
| <a name="requirement_ibm"></a> [ibm](#requirement\_ibm) | =1.56.1 |

### Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_ansible_sap_install_hana"></a> [ansible\_sap\_install\_hana](#module\_ansible\_sap\_install\_hana) | ../../../modules/ansible_sap_install_all | n/a |
| <a name="module_ansible_sap_install_netweaver"></a> [ansible\_sap\_install\_netweaver](#module\_ansible\_sap\_install\_netweaver) | ../../../modules/ansible_sap_install_all | n/a |
| <a name="module_cos_download_hana_binaries"></a> [cos\_download\_hana\_binaries](#module\_cos\_download\_hana\_binaries) | ../../../modules/ibmcloud_cos | n/a |
| <a name="module_cos_download_netweaver_binaries"></a> [cos\_download\_netweaver\_binaries](#module\_cos\_download\_netweaver\_binaries) | ../../../modules/ibmcloud_cos | n/a |
| <a name="module_sap_system"></a> [sap\_system](#module\_sap\_system) | ../../sap-ready-to-go/module | n/a |

### Resources

| Name | Type |
|------|------|
| [ibm_schematics_output.schematics_output](https://registry.terraform.io/providers/IBM-Cloud/ibm/1.56.1/docs/data-sources/schematics_output) | data source |
| [ibm_schematics_workspace.schematics_workspace](https://registry.terraform.io/providers/IBM-Cloud/ibm/1.56.1/docs/data-sources/schematics_workspace) | data source |

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_ansible_sap_hana_vars"></a> [ansible\_sap\_hana\_vars](#input\_ansible\_sap\_hana\_vars) | SAP HANA variables for HANA DB installation. | <pre>object({<br>    sap_hana_install_sid    = string<br>    sap_hana_install_number = string<br>  })</pre> | <pre>{<br>  "sap_hana_install_number": "02",<br>  "sap_hana_install_sid": "HDB"<br>}</pre> | no |
| <a name="input_ansible_sap_solution_vars"></a> [ansible\_sap\_solution\_vars](#input\_ansible\_sap\_solution\_vars) | SAP solution variables for SWPM installation. If sap\_swpm\_mp\_stack\_file\_name is empty, then installation will not use maintainance planner and tms will not be installed and configured. | <pre>object({<br>    sap_swpm_sid                = string<br>    sap_swpm_ascs_instance_nr   = string<br>    sap_swpm_pas_instance_nr    = string<br>    sap_swpm_mp_stack_file_name = string<br><br>  })</pre> | <pre>{<br>  "sap_swpm_ascs_instance_nr": "00",<br>  "sap_swpm_mp_stack_file_name": "",<br>  "sap_swpm_pas_instance_nr": "01",<br>  "sap_swpm_sid": "S4H"<br>}</pre> | no |
| <a name="input_ansible_vault_password"></a> [ansible\_vault\_password](#input\_ansible\_vault\_password) | Vault password to encrypt ansible variable file for SAP installation. | `string` | n/a | yes |
| <a name="input_cos_configuration"></a> [cos\_configuration](#input\_cos\_configuration) | Cloud object storage Instance details to download the files to the target host. 'cos\_hana\_software\_path' should contain only binaries required for HANA DB installation. 'cos\_solution\_software\_path' should contain only binaries required for S4HANA or BW4HANA installation. If you have a stack xml file (maintainance planner) also place it under the 'cos\_solution\_software\_path' dir and shouldn't contain any DB files as playbook will run into an error. Give the folder paths in Cloud object storage Instance. | <pre>object({<br>    cos_region                 = string<br>    cos_bucket_name            = string<br>    cos_hana_software_path     = string<br>    cos_solution_software_path = string<br>  })</pre> | <pre>{<br>  "cos_bucket_name": "powervs-automation",<br>  "cos_hana_software_path": "HANA_DB/rev66",<br>  "cos_region": "eu-geo",<br>  "cos_solution_software_path": "S4HANA_2022"<br>}</pre> | no |
| <a name="input_cos_service_credentials"></a> [cos\_service\_credentials](#input\_cos\_service\_credentials) | Cloud object storage Instance service credentials to access the cos bucket [json example of service credential](https://cloud.ibm.com/docs/cloud-object-storage?topic=cloud-object-storage-service-credentials) | `string` | n/a | yes |
| <a name="input_ibmcloud_api_key"></a> [ibmcloud\_api\_key](#input\_ibmcloud\_api\_key) | The IBM Cloud platform API key needed to deploy IAM enabled resources. | `string` | n/a | yes |
| <a name="input_powervs_create_separate_fs_share"></a> [powervs\_create\_separate\_fs\_share](#input\_powervs\_create\_separate\_fs\_share) | Deploy separate IBM PowerVS instance(0.5 cpus, 2 GB memory size, shared processor on s922.) as central file system share. All filesystems defined in 'powervs\_share\_storage\_config' optional variable will be NFS exported and mounted on Netweaver PowerVS instances. | `bool` | `true` | no |
| <a name="input_powervs_default_images"></a> [powervs\_default\_images](#input\_powervs\_default\_images) | Default Red Hat Linux images to use for SAP HANA and SAP NetWeaver PowerVS instances. | <pre>object({<br>    rhel_hana_image = string<br>    rhel_nw_image   = string<br>  })</pre> | <pre>{<br>  "rhel_hana_image": "RHEL8-SP6-SAP",<br>  "rhel_nw_image": "RHEL8-SP6-SAP-NETWEAVER"<br>}</pre> | no |
| <a name="input_powervs_hana_additional_storage_config"></a> [powervs\_hana\_additional\_storage\_config](#input\_powervs\_hana\_additional\_storage\_config) | Additional File systems to be created and attached to PowerVS instance for SAP HANA. 'size' is in GB. 'count' specify over how many storage volumes the file system will be striped. 'tier' specifies the storage tier in PowerVS workspace. 'mount' specifies the target mount point on OS. | <pre>list(object({<br>    name  = string<br>    size  = string<br>    count = string<br>    tier  = string<br>    mount = string<br>  }))</pre> | <pre>[<br>  {<br>    "count": "1",<br>    "mount": "/usr/sap",<br>    "name": "usrsap",<br>    "size": "50",<br>    "tier": "tier3"<br>  }<br>]</pre> | no |
| <a name="input_powervs_hana_custom_storage_config"></a> [powervs\_hana\_custom\_storage\_config](#input\_powervs\_hana\_custom\_storage\_config) | Custom File systems to be created and attached to PowerVS instance for SAP HANA. 'size' is in GB. 'count' specify over how many storage volumes the file system will be striped. 'tier' specifies the storage tier in PowerVS workspace. 'mount' specifies the target mount point on OS. | <pre>list(object({<br>    name  = string<br>    size  = string<br>    count = string<br>    tier  = string<br>    mount = string<br>  }))</pre> | <pre>[<br>  {<br>    "count": "",<br>    "mount": "",<br>    "name": "",<br>    "size": "",<br>    "tier": ""<br>  }<br>]</pre> | no |
| <a name="input_powervs_hana_instance_name"></a> [powervs\_hana\_instance\_name](#input\_powervs\_hana\_instance\_name) | SAP HANA hostname (non FQDN). Will get the form of <var.prefix>-<var.powervs\_hana\_instance\_name>. Max length of final hostname must be <= 13 characters. | `string` | `"hana"` | no |
| <a name="input_powervs_hana_sap_profile_id"></a> [powervs\_hana\_sap\_profile\_id](#input\_powervs\_hana\_sap\_profile\_id) | SAP HANA profile to use. Must be one of the supported profiles. See [here](https://cloud.ibm.com/docs/sap?topic=sap-hana-iaas-offerings-profiles-power-vs). File system sizes are automatically calculated. Override automatic calculation by setting values in optional sap\_hana\_custom\_storage\_config parameter. | `string` | `"ush1-4x256"` | no |
| <a name="input_powervs_netweaver_cpu_number"></a> [powervs\_netweaver\_cpu\_number](#input\_powervs\_netweaver\_cpu\_number) | Number of CPUs SAP NetWeaver instance. | `string` | `"3"` | no |
| <a name="input_powervs_netweaver_instance_name"></a> [powervs\_netweaver\_instance\_name](#input\_powervs\_netweaver\_instance\_name) | SAP Netweaver hostname (non FQDN). Will get the form of <var.prefix>-<var.powervs\_netweaver\_instance\_name>-<number>. Max length of final hostname must be <= 13 characters. | `string` | `"nw"` | no |
| <a name="input_powervs_netweaver_memory_size"></a> [powervs\_netweaver\_memory\_size](#input\_powervs\_netweaver\_memory\_size) | Memory size SAP NetWeaver instance. | `string` | `"32"` | no |
| <a name="input_powervs_netweaver_storage_config"></a> [powervs\_netweaver\_storage\_config](#input\_powervs\_netweaver\_storage\_config) | File systems to be created and attached to PowerVS instance for SAP NetWeaver. 'size' is in GB. 'count' specify over how many storage volumes the file system will be striped. 'tier' specifies the storage tier in PowerVS workspace. 'mount' specifies the target mount point on OS. | <pre>list(object({<br>    name  = string<br>    size  = string<br>    count = string<br>    tier  = string<br>    mount = string<br>  }))</pre> | <pre>[<br>  {<br>    "count": "1",<br>    "mount": "/usr/sap",<br>    "name": "usrsap",<br>    "size": "50",<br>    "tier": "tier3"<br>  }<br>]</pre> | no |
| <a name="input_powervs_sap_network_cidr"></a> [powervs\_sap\_network\_cidr](#input\_powervs\_sap\_network\_cidr) | Network range for separate SAP network. E.g., '10.53.1.0/24' | `string` | `"10.53.1.0/24"` | no |
| <a name="input_powervs_share_storage_config"></a> [powervs\_share\_storage\_config](#input\_powervs\_share\_storage\_config) | File systems to be created and attached to PowerVS instance for shared storage file systems. 'size' is in GB. 'count' specify over how many storage volumes the file system will be striped. 'tier' specifies the storage tier in PowerVS workspace. 'mount' specifies the target mount point on OS. | <pre>list(object({<br>    name  = string<br>    size  = string<br>    count = string<br>    tier  = string<br>    mount = string<br>  }))</pre> | <pre>[<br>  {<br>    "count": "1",<br>    "mount": "/sapmnt",<br>    "name": "sapmnt",<br>    "size": "300",<br>    "tier": "tier3"<br>  },<br>  {<br>    "count": "1",<br>    "mount": "/usr/trans",<br>    "name": "trans",<br>    "size": "50",<br>    "tier": "tier3"<br>  }<br>]</pre> | no |
| <a name="input_powervs_zone"></a> [powervs\_zone](#input\_powervs\_zone) | IBM Cloud data center location where IBM PowerVS Workspace exists. | `string` | n/a | yes |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | Unique prefix for resources to be created (e.g., SAP system name). Max length must be less than or equal to 6. | `string` | n/a | yes |
| <a name="input_prerequisite_workspace_id"></a> [prerequisite\_workspace\_id](#input\_prerequisite\_workspace\_id) | IBM Cloud Schematics workspace ID of an existing Power infrastructure for regulated industries deployment. If you do not yet have an existing deployment, click [here](https://cloud.ibm.com/catalog/) and search for 'Power Virtual Server with VPC landing zone' to create one. | `string` | n/a | yes |
| <a name="input_sap_domain"></a> [sap\_domain](#input\_sap\_domain) | SAP domain to be set for entire landscape. | `string` | `"sap.com"` | no |
| <a name="input_sap_hana_master_password"></a> [sap\_hana\_master\_password](#input\_sap\_hana\_master\_password) | SAP HANA master password | `string` | n/a | yes |
| <a name="input_sap_solution"></a> [sap\_solution](#input\_sap\_solution) | SAP Solution. | `string` | n/a | yes |
| <a name="input_sap_swpm_master_password"></a> [sap\_swpm\_master\_password](#input\_sap\_swpm\_master\_password) | SAP SWPM master password. | `string` | n/a | yes |
| <a name="input_ssh_private_key"></a> [ssh\_private\_key](#input\_ssh\_private\_key) | Private SSH key (RSA format) used to login to IBM PowerVS instances. Should match to uploaded public SSH key referenced by 'ssh\_public\_key' which was created previously. Entered data must be in [heredoc strings format](https://www.terraform.io/language/expressions/strings#heredoc-strings). The key is not uploaded or stored. For more information about SSH keys, see [SSH keys](https://cloud.ibm.com/docs/vpc?topic=vpc-ssh-keys). | `string` | n/a | yes |

### Outputs

| Name | Description |
|------|-------------|
| <a name="output_access_host_or_ip"></a> [access\_host\_or\_ip](#output\_access\_host\_or\_ip) | Public IP of Provided Bastion/JumpServer Host |
| <a name="output_ansible_sap_hana_vars"></a> [ansible\_sap\_hana\_vars](#output\_ansible\_sap\_hana\_vars) | HANA system details |
| <a name="output_ansible_sap_solution_vars"></a> [ansible\_sap\_solution\_vars](#output\_ansible\_sap\_solution\_vars) | Netweaver system details |
| <a name="output_infrastructure_data"></a> [infrastructure\_data](#output\_infrastructure\_data) | Data from PowerVS infrastructure layer |
| <a name="output_powervs_hana_instance_ips"></a> [powervs\_hana\_instance\_ips](#output\_powervs\_hana\_instance\_ips) | All private IPS of HANA instance |
| <a name="output_powervs_hana_instance_management_ip"></a> [powervs\_hana\_instance\_management\_ip](#output\_powervs\_hana\_instance\_management\_ip) | Management IP of HANA Instance |
| <a name="output_powervs_lpars_data"></a> [powervs\_lpars\_data](#output\_powervs\_lpars\_data) | All private IPS of PowerVS instances and Jump IP to access the host. |
| <a name="output_powervs_netweaver_instance_ips"></a> [powervs\_netweaver\_instance\_ips](#output\_powervs\_netweaver\_instance\_ips) | All private IPS of NetWeaver instances |
| <a name="output_powervs_netweaver_instance_management_ip"></a> [powervs\_netweaver\_instance\_management\_ip](#output\_powervs\_netweaver\_instance\_management\_ip) | Management IP of NetWeaver instance |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
