# IBM Power Virtual Server for SAP HANA Solutions

[![Graduated (Supported)](https://img.shields.io/badge/status-Graduated%20(Supported)-brightgreen?style=plastic)](https://terraform-ibm-modules.github.io/documentation/#/badge-status)
[![semantic-release](https://img.shields.io/badge/%20%20%F0%9F%93%A6%F0%9F%9A%80-semantic--release-e10079.svg)](https://github.com/semantic-release/semantic-release)
[![pre-commit](https://img.shields.io/badge/pre--commit-enabled-brightgreen?logo=pre-commit&logoColor=white)](https://github.com/pre-commit/pre-commit)
[![latest release](https://img.shields.io/github/v/release/terraform-ibm-modules/terraform-ibm-powervs-sap?logo=GitHub&sort=semver)](https://github.com/terraform-ibm-modules/terraform-ibm-powervs-sap/releases/latest)
[![Renovate enabled](https://img.shields.io/badge/renovate-enabled-brightgreen.svg)](https://renovatebot.com/)

## Summary
This repository contains deployable architecture solutions that help in deploying VPC landing zones, Power Virtual Server workspaces, and SAP HANA solutions. The solutions are available in the IBM Cloud Catalog and can also be deployed without the catalog.


### Solutions

1. [IBM catalog PowerVS SAP Ready variation](https://github.com/terraform-ibm-modules/terraform-ibm-powervs-sap/tree/main/solutions/ibm-catalog/sap-ready-to-go)
    - Creates a VPC and Power Virtual Server workspace, interconnects them, and configures OS network management services (SQUID proxy, NTP, NFS, and DNS) using Ansible Galaxy collection roles from the ibm.power_linux_sap collection.
    - Creates and configures **one HANA instance and zero to several NetWeaver instances** with **RHEL or SLES OS** distribution. Creates a private subnet for SAP communication for the entire landscape.
    - Optionally configures OS network management services (NTP, NFS, and DNS services) using Ansible Galaxy Collection from [IBM](https://galaxy.ansible.com/ui/repo/published/ibm/power_linux_sap/): `power_linux_sap`
    - Additionally tunes the instances according to SAP's best practices, which are fully ready for hosting SAP applications.

1. [IBM catalog PowerVS S/4HANA or BW/4HANA variation](https://github.com/terraform-ibm-modules/terraform-ibm-powervs-sap/tree/main/solutions/ibm-catalog/sap-s4hana-bw4hana)
    - Creates a VPC and Power Virtual Server workspace, interconnects them, and configures OS network management services (SQUID proxy, NTP, NFS, and DNS) using Ansible Galaxy collection roles from the ibm.power_linux_sap collection.
    - Creates and configures **one HANA instance and one NetWeaver instance** with **RHEL** OS distribution. Creates a private subnet for SAP communication for the entire landscape.
    - Optionally configures OS network management services (NTP, NFS, and DNS services) using Ansible Galaxy Collection from [IBM](https://galaxy.ansible.com/ui/repo/published/ibm/power_linux_sap/): `power_linux_sap`
    - Tunes the instances according to SAP's best practices.
    - Downloads user-provided preloaded SAP Installation binaries from IBM Cloud Object Storage Bucket.
    - Installs and configures **SAP applications** (SAP HANA DB, SAP S4/HANA, SAP BW4/HANA) using [RHEL System Roles](https://access.redhat.com/articles/4488731): `sap_hana_install`, `sap_swpm`,`sap_general_preconfigure`, `sap_hana_preconfigure`, `sap_netweaver_preconfigure`

1. [Single HANA Instance](https://github.com/terraform-ibm-modules/terraform-ibm-powervs-sap/tree/main/solutions/single-hana-instance)
   - Creates a single HANA instance based on HANA certified profiles along with right storage config.
   - Optionally configures OS network management services (NTP, NFS, and DNS services) using Ansible Galaxy Collection from [IBM](https://galaxy.ansible.com/ui/repo/published/ibm/power_linux_sap/): `power_linux_sap`
   - Tunes the instances according to SAP's best practices.

1. [Single Netweaver Instance](https://github.com/terraform-ibm-modules/terraform-ibm-powervs-sap/tree/main/solutions/single-netweaver-instance)
   - Creates a single Netweaver instance along with right storage config.
   - Optionally configures OS network management services (NTP, NFS, and DNS services) using Ansible Galaxy Collection from [IBM](https://galaxy.ansible.com/ui/repo/published/ibm/power_linux_sap/): `power_linux_sap`
   - Tunes the instances according to SAP's best practices.



## Reference architectures
- [IBM catalog PowerVS SAP Ready variation](https://github.com/terraform-ibm-modules/terraform-ibm-powervs-sap/blob/main/reference-architectures/sap-ready-to-go/deploy-arch-ibm-pvs-sap-ready-to-go.svg)
- [IBM catalog PowerVS SAP S/4HANA or BW/4HANA variation](https://github.com/terraform-ibm-modules/terraform-ibm-powervs-sap/blob/main/reference-architectures/sap-s4hana-bw4hana/deploy-arch-ibm-pvs-sap-s4hana-bw4hana.svg)



## Solutions

|                                  Variation                                  | Available on IBM Catalog | Creates PowerVS with VPC landing zone | Creates PowerVS HANA Instance | Creates PowerVS NW Instances | Performs PowerVS OS Config | Performs PowerVS SAP Tuning | Install SAP software |
|:---------------------------------------------------------------------------:|:------------------------:|:-------------------------------------:|:-----------------------------:|:----------------------------:|:--------------------------:|:---------------------------:|:--------------------:|
| [IBM catalog PowerVS SAP Ready]( ./solutions/ibm-catalog/sap-ready-to-go/ ) |    :heavy_check_mark:    |    :heavy_check_mark:    |    :heavy_check_mark:    |               1               |            0 to N            |     :heavy_check_mark:     |      :heavy_check_mark:     |          N/A         |
| [IBM catalog SAP S/4HANA or BW/4HANA variation]( ./solutions/ibm-catalog/sap-s4hana-bw4hana ) |    :heavy_check_mark:    |    :heavy_check_mark:    |    :heavy_check_mark:    |               1               |            1            |     :heavy_check_mark:     |      :heavy_check_mark:     |          :heavy_check_mark:         |



## Required IAM access policies

You need the following permissions to run this module.

- Account Management
    - **Resource Group** service
        - `Viewer` platform access
    - IAM Services
        - **Workspace for Power Systems Virtual Server** service
        - **Power Systems Virtual Server** service
            - `Editor` platform access
        - **VPC Infrastructure Services** service
            - `Editor` platform access
        - **Transit Gateway** service
            - `Editor` platform access

## Contributing

You can report issues and request features for this module in GitHub issues in the module repository. See [Report an issue or request a feature](https://github.com/terraform-ibm-modules/.github/blob/main/.github/SUPPORT.md).

To set up your local development environment, see [Local development setup](https://terraform-ibm-modules.github.io/documentation/#/local-dev-setup) in the project documentation.
<!-- END CONTRIBUTING HOOK -->
