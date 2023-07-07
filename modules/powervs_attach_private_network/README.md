# Module attach_sap_network
This module attaches the newly created sap private network to the cloud connections.

## Usage
```hcl
provider "ibm" {
  region           = var.powervs_region
  zone             = var.powervs_zone
  ibmcloud_api_key = var.ibmcloud_api_key != null ? var.ibmcloud_api_key : null
}

module "attach_sap_network" {

  powervs_zone                   = var.powervs_zone
  powervs_resource_group_name    = var.powervs_resource_group_name
  powervs_workspace_name         = var.powervs_workspace_name
  powervs_sap_network_name       = var.powervs_sap_network_name
  powervs_cloud_connection_count = var.powervs_cloud_connection_count
}
```
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3 |
| <a name="requirement_ibm"></a> [ibm](#requirement\_ibm) | >=1.49.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [ibm_pi_cloud_connection_network_attach.powervs_subnet_instance_nw_attach](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/pi_cloud_connection_network_attach) | resource |
| [ibm_pi_cloud_connection_network_attach.powervs_subnet_instance_nw_attach_backup](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/pi_cloud_connection_network_attach) | resource |
| [ibm_pi_cloud_connections.cloud_connection_ds](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/data-sources/pi_cloud_connections) | data source |
| [ibm_pi_network.additional_network_ds](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/data-sources/pi_network) | data source |
| [ibm_resource_group.resource_group_ds](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/data-sources/resource_group) | data source |
| [ibm_resource_instance.powervs_workspace_ds](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/data-sources/resource_instance) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_powervs_cloud_connection_count"></a> [powervs\_cloud\_connection\_count](#input\_powervs\_cloud\_connection\_count) | Number of existing Cloud connections to attach new private network | `string` | n/a | yes |
| <a name="input_powervs_resource_group_name"></a> [powervs\_resource\_group\_name](#input\_powervs\_resource\_group\_name) | Existing IBM Cloud resource group name. | `string` | n/a | yes |
| <a name="input_powervs_sap_network_name"></a> [powervs\_sap\_network\_name](#input\_powervs\_sap\_network\_name) | Name for new network for SAP system | `string` | n/a | yes |
| <a name="input_powervs_workspace_name"></a> [powervs\_workspace\_name](#input\_powervs\_workspace\_name) | Existing Name of the PowerVS workspace. | `string` | n/a | yes |
| <a name="input_powervs_zone"></a> [powervs\_zone](#input\_powervs\_zone) | IBM Cloud PowerVS zone. | `string` | n/a | yes |

## Outputs

No outputs.
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
