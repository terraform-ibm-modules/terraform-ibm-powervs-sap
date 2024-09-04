# IBM Cloud Catalog - Power Virtual Server for SAP HANA: 'SAP S/4HANA or BW/4HANA PowerVS Fullstack'

The 'SAP S/4HANA or BW/4HANA PowerVS Fullstack' is designed to simplify the deployment of an end-to-end SAP ERP software landscape on the IBM Power Virtual Server infrastructure into IBM Cloud. It combines the deployment of two [deployable architectures](https://cloud.ibm.com/docs/secure-enterprise?topic=secure-enterprise-understand-module-da#what-is-da) into one configuration and helps to deploy the SAP landscape via IBM Cloud [projects](https://cloud.ibm.com/docs/secure-enterprise?topic=secure-enterprise-understanding-projects).

# Summary
## Stack Deployment Outcome:
The 'SAP S/4HANA or BW/4HANA PowerVS with VPC' solution offers two [deployable architectures](https://cloud.ibm.com/docs/secure-enterprise?topic=secure-enterprise-understand-module-da#what-is-da):
1. [Power Virtual Server with VPC landing zone](https://cloud.ibm.com/catalog/architecture/deploy-arch-ibm-pvs-inf-2dd486c7-b317-4aaa-907b-42671485ad96-global?kind=terraform&format=terraform&version=7cee3b92-c691-4394-aed5-b090cbffb403-global) - Standard variant: This architecture establishes an IBM Cloud® Power Virtual Server Infrastructure (PowerVS) that adheres to IBM Cloud's best practices and requirements. The infrastructure has following components:
    - A **VPC** with the following components:
        - One VSI for one management (jump/bastion) VSI,
        - One VSI for network-services configured as squid proxy, NTP and DNS servers(using Ansible Galaxy collection roles [ibm.power_linux_sap collection](https://galaxy.ansible.com/ui/repo/published/ibm/power_linux_sap/)). This VSI also acts as central ansible execution node.
        - Optional [Client to site VPN server](https://cloud.ibm.com/docs/vpc?topic=vpc-vpn-client-to-site-overview)
        - IBM Cloud Object storage(COS) Virtual Private endpoint gateway(VPE)
        - IBM Cloud Object storage(COS) Instance and buckets
        - VPC flow logs
        - KMS keys
        - Activity tracker
    - A local or global **transit gateway**
    - A **Power Virtual Server** workspace with the following network topology:
        - Creates two private networks: a management network and a backup network.
        - Attaches the PowerVS workspace to transit gateway.
        - Creates an SSH key.
        - Imports catalog stock images.
2. Power Virtual Server for SAP HANA - SAP S/4HANA or BW/4HANA variant: This architecture provisions IBM PowerVS hosts on the Power Virtual Server Infrastructure. The virtual server instances are optimized for SAP, supporting SAP HANA and NetWeaver configurations. The deployment of results adds the following components into the infrastructure deployed by the first solution:
    - Creates a new private subnet for SAP communication for the entire landscape
    - Creates and configures one PowerVS instance for SAP HANA based on best practices.
    - Creates and configures one PowerVS instance for SAP NetWeaver based on best practices.
    - Creates and configures one optional PowerVS instance that can be used for sharing SAP files between other system instances.
    - Connects all created PowerVS instances to a proxy server specified by IP address or hostname.
    - Connects all created PowerVS instances to an NTP server and DNS forwarder specified by IP address or hostname.
    - Configures a shared NFS directory on all created PowerVS instances.
    - Post-instance provisioning, Ansible Galaxy collection roles from [IBM](https://galaxy.ansible.com/ui/repo/published/ibm/power_linux_sap/) are executed: `power_linux_sap`.
    - Supports installation of S/4HANA2023, S/4HANA2022, S/4HANA2021, S/4HANA2020, BW/4HANA2021.
    - Supports installation using Maintenance Planner as well.



| Variation                   | Available on IBM Catalog  | Creates VPC Landing Zone          | Performs VPC VSI OS Config        | Creates PowerVS Infrastructure    | Creates PowerVS HANA Instance     | Creates PowerVS NW Instances      | Performs PowerVS OS Config        | Performs PowerVS SAP Tuning       | Install SAP software              |
|-----------------------------|------------|------------|------------|------------|------------|------------|------------|------------|------------|
| **SAP Ready PowerVS with VPC Landing Zone** | yes | ✅             | ✅             | ✅             | 1              | 1         | ✅             | ✅             | ✅              |


## Architecture Diagram
![sap-ready-to-go](https://github.com/terraform-ibm-modules/terraform-ibm-powervs-sap/blob/main/reference-architectures/sap-s4hana-bw4hana-stack/deploy-arch-ibm-pvs-sap-s4hana-bw4hana-stack.svg)

## Before you begin
**It is required to have an existing IBM Cloud Object Storage (COS) instance**. Within the instance, an Object Storage Bucket containing the **SAP Software installation media files is required in the correct folder structure as defined** [here](#2-sap-binaries-required-for-installation-and-folder-structure-in-ibm-cloud-object-storage-bucket).

## Notes
- **Does not install any SAP software or solutions.**
- Filesystem sizes for HANA data and HANA log are **calculated automatically** based on the **memory size**.
- Custom storage configuration by providing custom volume size, **iops**(tier0, tier1, tier3, tier5k), counts and mount points is supported.
- If **sharefs instance is enabled**, then all filesystems provisioned for sharefs instance will be **NFS exported and mounted** on all NetWeaver Instances.
- **Do not specify** a filesystem `/sapmnt` explicitly for NetWeaver instance as, it is created internally when sharefs instance is not enabled.

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
