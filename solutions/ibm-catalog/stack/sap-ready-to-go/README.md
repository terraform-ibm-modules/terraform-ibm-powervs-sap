# IBM Cloud Catalog - Power Virtual Server for SAP HANA: 'SAP Ready PowerVS Fullstack'

The 'SAP Ready PowerVS Fullstack' is designed to simplify the deployment of an end-to-end SAP ERP software landscape on the IBM Power Virtual Server infrastructure into IBM Cloud. It combines the deployment of two [deployable architectures](https://cloud.ibm.com/docs/secure-enterprise?topic=secure-enterprise-understand-module-da#what-is-da) into one configuration and helps to deploy the SAP landscape via IBM Cloud [projects](https://cloud.ibm.com/docs/secure-enterprise?topic=secure-enterprise-understanding-projects).

# Summary
## Stack Deployment Outcome:
The 'SAP Ready PowerVS with VPC' solution offers two [deployable architectures](https://cloud.ibm.com/docs/secure-enterprise?topic=secure-enterprise-understand-module-da#what-is-da):
1. [Power Virtual Server with VPC landing zone](https://cloud.ibm.com/catalog/architecture/deploy-arch-ibm-pvs-inf-2dd486c7-b317-4aaa-907b-42671485ad96-global?kind=terraform&format=terraform&version=7cee3b92-c691-4394-aed5-b090cbffb403-global) - Standard variant:

    This architecture establishes an IBM Cloud® Power Virtual Server Infrastructure (PowerVS) that adheres to IBM Cloud's best practices and requirements. The infrastructure has following components:
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
2. **Power Virtual Server for SAP HANA - SAP Ready PowerVS variant**:

    This architecture provisions IBM PowerVS hosts on the Power Virtual Server Infrastructure. The virtual server instances are optimized for SAP, supporting SAP HANA and NetWeaver configurations. The deployment of results adds the following components into the infrastructure deployed by the first solution:

    - Creates a new private subnet for SAP communication for the entire landscape
    - Creates and configures one PowerVS instance for SAP HANA based on best practices.
    - Creates and configures multiple PowerVS instances for SAP NetWeaver based on best practices.
    - Creates and configures one optional PowerVS instance that can be used for sharing SAP files between other system instances.
    - Connects all created PowerVS instances to a proxy server specified by IP address or hostname.
    - Post-instance provisioning, Ansible Galaxy collection roles from [IBM](https://galaxy.ansible.com/ui/repo/published/ibm/power_linux_sap/) are executed: `power_linux_sap` to tune the OS according to best practices for SAP.

## Notes
- **Does not install any SAP software or solutions.**
- Filesystem sizes for HANA data and HANA log are **calculated automatically** based on the **memory size**.
- Custom storage configuration by providing custom volume size, **iops**(tier0, tier1, tier3, tier5k), counts and mount points is supported.
- If **sharefs instance is enabled**, then all filesystems provisioned for sharefs instance will be **NFS exported and mounted** on all NetWeaver Instances.
- **Do not specify** a filesystem `/sapmnt` explicitly for NetWeaver instance as, it is created internally when sharefs instance is not enabled.
- Tested with RHEL8.4,/8.6/8.8/9.2, SLES15-SP3/SP5 images.

| Variation                   | Available on IBM Catalog  | Creates VPC Landing Zone          | Performs VPC VSI OS Config        | Creates PowerVS Infrastructure    | Creates PowerVS HANA Instance     | Creates PowerVS NW Instances      | Performs PowerVS OS Config        | Performs PowerVS SAP Tuning       | Install SAP software              |
|-----------------------------|------------|------------|------------|------------|------------|------------|------------|------------|------------|
| **SAP Ready PowerVS** | ✅ | ✅             | ✅             | ✅             | 1              | 0 to N         | ✅             | ✅             | ❌             |


## Architecture Diagram
![sap-ready-to-go](https://github.com/terraform-ibm-modules/terraform-ibm-powervs-sap/blob/main/reference-architectures/sap-ready-to-go-stack/deploy-arch-ibm-pvs-sap-ready-to-go-stack.svg)
