# Module attach_sap_network
This modules attaches the newly created sap private network to the cloud connections.

## Prerequisites
- Installation of 'Secure infrastructure on VPC for regulated industries' catalog provision of version v1.7.1 or above.
- Installation of 'Power infrastructure for regulated industries' catalog provision of version v4.0.0 or above.

## Usage
```hcl
provider "ibm" {
  region           = var.powervs_region
  zone             = var.powervs_zone
  ibmcloud_api_key = var.ibmcloud_api_key != null ? var.ibmcloud_api_key : null
}

module "create_sap_network" {
  powervs_zone = var.powervs_zone

  powervs_resource_group_name = var.powervs_resource_group_name
  powervs_service_name        = var.powervs_service_name
  powervs_sap_network_name    = var.powervs_sap_network_name
  powervs_sap_network_cidr    = var.powervs_sap_network_cidr
}
```
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >=1.1 |
| <a name="requirement_ibm"></a> [ibm](#requirement\_ibm) | >= 1.43.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [ibm_pi_network.additional_network](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/pi_network) | resource |
| [ibm_resource_group.resource_group_ds](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/data-sources/resource_group) | data source |
| [ibm_resource_instance.powervs_service_ds](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/data-sources/resource_instance) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_powervs_resource_group_name"></a> [powervs\_resource\_group\_name](#input\_powervs\_resource\_group\_name) | Existing IBM Cloud resource group name. | `string` | n/a | yes |
| <a name="input_powervs_sap_network_cidr"></a> [powervs\_sap\_network\_cidr](#input\_powervs\_sap\_network\_cidr) | CIDR for new network for SAP system | `string` | n/a | yes |
| <a name="input_powervs_sap_network_name"></a> [powervs\_sap\_network\_name](#input\_powervs\_sap\_network\_name) | Name for new network for SAP system | `string` | n/a | yes |
| <a name="input_powervs_service_name"></a> [powervs\_service\_name](#input\_powervs\_service\_name) | Existing Name of the PowerVS service. | `string` | n/a | yes |
| <a name="input_powervs_zone"></a> [powervs\_zone](#input\_powervs\_zone) | IBM Cloud PowerVS zone. | `string` | n/a | yes |

## Outputs

No outputs.
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
