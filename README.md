<!-- BEGIN MODULE HOOK -->

# SAP on secure Power Virtual Servers module

<!-- UPDATE BADGE: Update the link for the badge below-->
[![Graduated (Supported)](https://img.shields.io/badge/status-Graduated%20(Supported)-brightgreen?style=plastic)](https://terraform-ibm-modules.github.io/documentation/#/badge-status)
[![semantic-release](https://img.shields.io/badge/%20%20%F0%9F%93%A6%F0%9F%9A%80-semantic--release-e10079.svg)](https://github.com/semantic-release/semantic-release)
[![pre-commit](https://img.shields.io/badge/pre--commit-enabled-brightgreen?logo=pre-commit&logoColor=white)](https://github.com/pre-commit/pre-commit)
[![latest release](https://img.shields.io/github/v/release/terraform-ibm-modules/terraform-ibm-powervs-sap?logo=GitHub&sort=semver)](https://github.com/terraform-ibm-modules/terraform-ibm-powervs-sap/releases/latest)
[![Renovate enabled](https://img.shields.io/badge/renovate-enabled-brightgreen.svg)](https://renovatebot.com/)

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

## Reference architectures

- [SAP Ready to go PowerVS](reference-architectures/sap-ready-to-go/deploy-arch-ibm-pvs-sap-ready-to-go.md)

<!-- BEGIN EXAMPLES HOOK -->
## Solutions

### Requires Schematics Workspace ID from Power Virtual Server with VPC landing zone solution from IBM catalog
| Variation  | Requires Schematics Workspace ID | PVS HANA Instance | PVS NW Instances |  PVS OS Config | PVS prepare for SAP | Install SAP software |
| ------------- | ------------- | ------------- | ------------- | ------------- | ------------- | ------------- |
| [sap-ready-to-go](solutions/ibm-catalog/sap-ready-to-go)  | :white_check_mark:  | 1  | 0 to N  | :white_check_mark:  |  :white_check_mark: |   :x: |


### Without Schematics Workspace ID
| Variation   | PVS HANA Instance | PVS NW Instances |  PVS OS Config | PVS prepare for SAP | Install SAP software |
| ------------- | ------------- | ------------- | ------------- | ------------- | ------------- |
| [sap-ready-to-go](solutions/sap-ready-to-go)   | 1  | 0 to N  | :white_check_mark:  |  :white_check_mark: |   :x: |

<!-- END EXAMPLES HOOK -->

<!-- BEGIN CONTRIBUTING HOOK -->
## Contributing

You can report issues and request features for this module in GitHub issues in the module repo. See [Report an issue or request a feature](https://github.com/terraform-ibm-modules/.github/blob/main/.github/SUPPORT.md).

To set up your local development environment, see [Local development setup](https://terraform-ibm-modules.github.io/documentation/#/local-dev-setup) in the project documentation.
<!-- END CONTRIBUTING HOOK -->
