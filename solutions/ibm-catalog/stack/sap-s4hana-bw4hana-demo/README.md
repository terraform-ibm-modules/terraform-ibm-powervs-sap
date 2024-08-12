# IBM Cloud Catalog - Power Virtual Server for SAP HANA: 'SAP S/4HANA or BW/4HANA Demo Stack'

The 'SAP S/4HANA or BW/4HANA Demo Stack' is designed to demonstrate an end-to-end SAP ERP software landscape on the IBM Power Virtual Server infrastructure into IBM Cloud. It combines the deployment of two [deployable architectures](https://cloud.ibm.com/docs/secure-enterprise?topic=secure-enterprise-understand-module-da#what-is-da) into one configuration and helps to deploy the SAP landscape via IBM Cloud [projects](https://cloud.ibm.com/docs/secure-enterprise?topic=secure-enterprise-understanding-projects).

# Summary
## Stack Deployment Outcome:
The 'SAP S/4HANA or BW/4HANA Stack' solution offers two [deployable architectures](https://cloud.ibm.com/docs/secure-enterprise?topic=secure-enterprise-understand-module-da#what-is-da):
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
2. Power Virtual Server for SAP HANA - SAP S/4HANA or BW/4HANA variant: This architecture provisions IBM PowerVS hosts on the Power Virtual Server Infrastructure. The virtual server instances are optimized for SAP, supporting SAP HANA and NetWeaver configurations. The deployment of results adds the following components into the infrastructure deployed by the first solution:
    - Creates a new private subnet for SAP communication for the entire landscape
    - Creates and configures one PowerVS instance for SAP HANA based on best practices.
    - Creates and configures multiple PowerVS instances for SAP NetWeaver based on best practices.
    - Creates and configures one optional PowerVS instance that can be used for sharing SAP files between other system instances.
    - Connects all created PowerVS instances to a proxy server specified by IP address or hostname.
    - Optionally connects all created PowerVS instances to an NTP server and DNS forwarder specified by IP address or hostname.
    - Optionally configures a shared NFS directory on all created PowerVS instances.
    - Post-instance provisioning, Ansible Galaxy collection roles from [IBM](https://galaxy.ansible.com/ui/repo/published/ibm/power_linux_sap/) are executed: `power_linux_sap`.
    - Supports installation of S/4HANA2023, S/4HANA2022, S/4HANA2021, S/4HANA2020, BW/4HANA2021.
    - Supports installation using Maintenance Planner as well.



| Variation                   | Available on IBM Catalog  | Creates VPC Landing Zone          | Performs VPC VSI OS Config        | Creates PowerVS Infrastructure    | Creates PowerVS HANA Instance     | Creates PowerVS NW Instances      | Performs PowerVS OS Config        | Performs PowerVS SAP Tuning       | Install SAP software              |
|-----------------------------|------------|------------|------------|------------|------------|------------|------------|------------|------------|
| **SAP Ready PowerVS Stack** | yes | ✅             | ✅             | ✅             | 1              | 0 to N         | ✅             | ✅             | ✅              |


## Architecture Diagram
![sap-ready-to-go](https://github.com/terraform-ibm-modules/terraform-ibm-powervs-sap/blob/main/reference-architectures/sap-ready-to-go/deploy-arch-ibm-pvs-sap-ready-to-go.svg)

## Before you begin
**It is required to have an existing IBM Cloud Object Storage (COS) instance**. Within the instance, an Object Storage Bucket containing the **SAP Software installation media files is required in the correct folder structure as defined** [here](#2-sap-binaries-required-for-installation-and-folder-structure-in-ibm-cloud-object-storage-bucket).

## Notes
- **Does not install any SAP software or solutions.**
- Filesystem sizes for HANA data and HANA log are **calculated automatically** based on the **memory size**.
- Custom storage configuration by providing custom volume size, **iops**(tier0, tier1, tier3, tier5k), counts and mount points is supported.
- If **sharefs instance is enabled**, then all filesystems provisioned for sharefs instance will be **NFS exported and mounted** on all NetWeaver Instances.
- **Do not specify** a filesystem `/sapmnt` explicitly for NetWeaver instance as, it is created internally when sharefs instance is not enabled.
- Tested with RHEL8.4,/8.6/8.8/9.2, SLES15-SP3/SP5 images.

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

## Ansible roles used
1. **[RHEL System Roles](https://access.redhat.com/articles/4488731):** `sap_hana_install, sap_swpm, sap_general_preconfigure, sap_hana_preconfigure, sap_netweaver_preconfigure`
2. **[IBM Role](https://galaxy.ansible.com/ui/repo/published/ibm/power_linux_sap/):** `power_linux_sap`

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
| <a name="input_prefix"></a> [power_infrastructure_prefix](#input\_power\_infrastructure\_prefix) | A unique identifier for resources. Must begin with a lowercase letter and end with a lowercase letter or number. This prefix will be prepended to any resources provisioned by this template. Prefixes must be 16 or fewer characters. | `string` | n/a | yes |
| <a name="input_external_access_ip"></a> [external\_access\_ip](#input\_external\_access\_ip) | Specify the source IP address or CIDR for login through SSH to the environment after deployment. Access to the environment will be allowed only from this IP address. Can be set to 'null' if you choose to use client to site vpn. | `string` | n/a | yes |
| <a name="input_client_to_site_vpn"></a> [client\_to\_site\_vpn](#input\_client\_to\_site\_vpn) | VPN configuration - the client ip pool and list of users email ids to access the environment. If enabled, then a Secret Manager instance is also provisioned with certificates generated. See optional parameters to reuse existing certificate from secrets manager instance. | <pre>object({<br>    enable                        = bool<br>    client_ip_pool                = string<br>    vpn_client_access_group_users = list(string)<br>  })</pre> | <pre>{<br>  "client_ip_pool": "192.168.0.0/16",<br>  "enable": true,<br>  "vpn_client_access_group_users": []<br>}</pre> | no |
| <a name="input_ssh_private_key"></a> [ssh\_private\_key](#input\_ssh\_private\_key) | Private SSH key (RSA format) to login to Intel VSIs to configure network management services (SQUID, NTP, NFS, DNS and ansible). Should match to public SSH key referenced by 'ssh\_public\_key'. The key is not uploaded or stored. For more information about SSH keys, see [SSH keys](https://cloud.ibm.com/docs/vpc?topic=vpc-ssh-keys). | `string` | n/a | yes |
| <a name="input_ssh_public_key"></a> [ssh\_public\_key](#input\_ssh\_public\_key) | Public SSH Key for VSI creation. Must be an RSA key with a key size of either 2048 bits or 4096 bits (recommended). Must be a valid SSH key that does not already exist in the deployment region. | `string` | n/a | yes |
| <a name="input_sap_system_prefix"></a> [sap_system_prefix](#input\_sap\_system\_prefix) | Unique prefix for resources to be created (e.g., SAP system name). Max length must be less than or equal to 6. | `string` | n/a | yes |
| <a name="input_powervs_hana_instance_sap_profile_id"></a> [powervs\_hana\_instance\_sap\_profile\_id](#input\_powervs\_hana\_instance\_sap\_profile\_id) | PowerVS SAP HANA instance profile to use. Must be one of the supported profiles. See [here](https://cloud.ibm.com/docs/sap?topic=sap-hana-iaas-offerings-profiles-power-vs). File system sizes are automatically calculated. Override automatic calculation by setting values in optional parameter 'powervs\_hana\_instance\_custom\_storage\_config'. | `string` | `"ush1-4x256"` | no |
| <a name="input_ibmcloud_cos_service_credentials"></a> [ibmcloud\_cos\_service\_credentials](#input\_ibmcloud\_cos\_service\_credentials) | IBM Cloud Object Storage instance service credentials to access the bucket in the instance.[json example of service credential](https://cloud.ibm.com/docs/cloud-object-storage?topic=cloud-object-storage-service-credentials) | `string` | n/a | yes |
| <a name="input_ibmcloud_cos_configuration"></a> [ibmcloud\_cos\_configuration](#input\_ibmcloud\_cos\_configuration) | Cloud Object Storage instance containing SAP installation files that will be downloaded to NFS share. 'cos\_hana\_software\_path' must contain only binaries required for HANA DB installation. 'cos\_solution\_software\_path' must contain only binaries required for S/4HANA or BW/4HANA installation and must not contain any IMDB files. If you have an optional stack xml file (maintenance planner), place it under the 'cos\_solution\_software\_path' directory. Avoid inserting '/' at the beginning for 'cos\_hana\_software\_path' and 'cos\_solution\_software\_path'. | <pre>object({<br>    cos_region                  = string<br>    cos_bucket_name             = string<br>    cos_hana_software_path      = string<br>    cos_solution_software_path  = string<br>    cos_swpm_mp_stack_file_name = string<br>  })</pre> | <pre>{<br>  "cos_bucket_name": "powervs-automation",<br>  "cos_hana_software_path": "HANA_DB/rev66",<br>  "cos_region": "eu-geo",<br>  "cos_solution_software_path": "S4HANA_2022",<br>  "cos_swpm_mp_stack_file_name": ""<br>}</pre> | no |
| <a name="input_sap_solution"></a> [sap\_solution](#input\_sap\_solution) | SAP Solution to be installed on Power Virtual Server. | `string` | n/a | yes |
