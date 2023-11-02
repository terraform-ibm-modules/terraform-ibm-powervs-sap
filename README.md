<!-- BEGIN MODULE HOOK -->

# IBM Power Virtual Server for SAP HANA solutions

<!-- UPDATE BADGE: Update the link for the badge below-->
[![Graduated (Supported)](https://img.shields.io/badge/status-Graduated%20(Supported)-brightgreen?style=plastic)](https://terraform-ibm-modules.github.io/documentation/#/badge-status)
[![semantic-release](https://img.shields.io/badge/%20%20%F0%9F%93%A6%F0%9F%9A%80-semantic--release-e10079.svg)](https://github.com/semantic-release/semantic-release)
[![pre-commit](https://img.shields.io/badge/pre--commit-enabled-brightgreen?logo=pre-commit&logoColor=white)](https://github.com/pre-commit/pre-commit)
[![latest release](https://img.shields.io/github/v/release/terraform-ibm-modules/terraform-ibm-powervs-sap?logo=GitHub&sort=semver)](https://github.com/terraform-ibm-modules/terraform-ibm-powervs-sap/releases/latest)
[![Renovate enabled](https://img.shields.io/badge/renovate-enabled-brightgreen.svg)](https://renovatebot.com/)

## Summary
This repository contains deployable architecture solutions which helps in Power Virtual Server for SAP HANA solutions. The solutions are available in IBM Cloud Catalog and also can be deployed without catalog as well except few solutions.

Three solutions are offered:
1. [IBM catalog PowerVS sap-ready-to-go variation](https://github.com/terraform-ibm-modules/terraform-ibm-powervs-sap/tree/main/solutions/ibm-catalog/sap-ready-to-go)
    - Creates and configures 1 HANA instance, 0 to N Netweaver Instances and 1 Optional ShareFS with RHEL or SLES Os distribution. Creates a new private subnet for SAP communication for entire landscape and attaches it to cloud connections(in Non PER DC).
    - Optionally configures os network management services(NTP, NFS, and DNS services) using ansible galaxy collection roles [ibm.power_linux_sap collection](https://galaxy.ansible.com/ui/repo/published/ibm/power_linux_sap/).
    - Additionally tunes the instances according to SAPs best practices which is fully ready for hosting SAP applications.
2. [PowerVS sap-ready-to-go variation](https://github.com/terraform-ibm-modules/terraform-ibm-powervs-sap/tree/main/solutions/sap-ready-to-go)
   - Creates and configures 1 HANA instance, 0 to N Netweaver Instances and 1 Optional ShareFS with RHEL or SLES Os distribution. Creates a new private subnet for SAP communication for entire landscape and attaches it to cloud connections(in Non PER DC).
   - Optionally configures os network management services(NTP, NFS, and DNS services) using ansible galaxy collection roles [ibm.power_linux_sap collection](https://galaxy.ansible.com/ui/repo/published/ibm/power_linux_sap/).
   - Additionally tunes the instances according to SAPs best practices which is fully ready for hosting SAP applications.
3. [End to End Solution](https://github.com/terraform-ibm-modules/terraform-ibm-powervs-sap/tree/main/solutions/e2e)
    - Creates a [Power Virtual Server with vpc landing zone](https://github.com/terraform-ibm-modules/terraform-ibm-powervs-infrastructure/tree/main/modules/powervs-vpc-landing-zone) which creates a VPC Infrastructure and PowerVS infrastructure. Installs and configures the Squid Proxy, DNS Forwarder, NTP forwarder and NFS on hosts, and sets the host as the server for the NTP, NFS, and DNS services by using ansible galaxy collection roles [ibm.power_linux_sap collection](https://galaxy.ansible.com/ui/repo/published/ibm/power_linux_sap/).
    - Creates and configures 1 HANA instance, 0 to N Netweaver Instances and 1 Optional ShareFS with RHEL or SLES Os distribution. Creates a new private subnet for SAP communication for entire landscape and attaches it to cloud connections(in Non PER DC).
    - Optionally configures os network management services(NTP, NFS, and DNS services) using ansible galaxy collection roles [ibm.power_linux_sap collection](https://galaxy.ansible.com/ui/repo/published/ibm/power_linux_sap/).
    - Additionally tunes the instances according to SAPs best practices which is fully ready for hosting SAP applications.

## Reference architectures
- [IBM catalog PowerVS sap-ready-to-go variation](https://github.com/terraform-ibm-modules/terraform-ibm-powervs-sap/blob/main/reference-architectures/sap-ready-to-go/deploy-arch-ibm-pvs-sap-ready-to-go.svg)
- [Power Virtual Server with vpc landing zone](https://github.com/terraform-ibm-modules/terraform-ibm-powervs-infrastructure/blob/main/reference-architectures/full-stack/deploy-arch-ibm-pvs-inf-full-stack.svg)


## Solutions
| Variation  | Available on IBM Catalog | Requires Schematics Workspace ID |  Creates PowerVS with VPC landing zone | Creates PowerVS HANA Instance | Creates PowerVS NW Instances |  Performs PowerVS OS Config | Performs PowerVS SAP Tuning | Install SAP software |
| ------------- | ------------- | ------------- | ------------- | ------------- | ------------- | ------------- | ------------- | ------------- |
| [IBM Catalog sap-ready-to-go](./solutions/ibm-catalog/sap-ready-to-go/)  | :heavy_check_mark:  | :heavy_check_mark: | N/A  | 1  | 0 to N  | :heavy_check_mark:  |  :heavy_check_mark: |   N/A |
| [sap-ready-to-go](./solutions/sap-ready-to-go/)  | N/A  | N/A  | N/A  | 1  | 0 to N  | :heavy_check_mark:  |  :heavy_check_mark: |   N/A |
| [End-to-End](./solutions/e2e/)  | N/A  | N/A  | :heavy_check_mark:  | 1  | 0 to N  | :heavy_check_mark:  |  :heavy_check_mark: |   N/A |


<!-- BEGIN OVERVIEW HOOK -->
## Overview
* [terraform-ibm-powervs-sap](#terraform-ibm-powervs-sap)
* [Submodules](./modules)
    * [pi-sap-system-type1](./modules/pi-sap-system-type1)
* [Contributing](#contributing)
<!-- END OVERVIEW HOOK -->


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
        - **Direct Link** service
            - `Editor` platform access

<!-- END MODULE HOOK -->


<!-- BEGIN CONTRIBUTING HOOK -->
## Contributing

You can report issues and request features for this module in GitHub issues in the module repo. See [Report an issue or request a feature](https://github.com/terraform-ibm-modules/.github/blob/main/.github/SUPPORT.md).

To set up your local development environment, see [Local development setup](https://terraform-ibm-modules.github.io/documentation/#/local-dev-setup) in the project documentation.
<!-- END CONTRIBUTING HOOK -->
