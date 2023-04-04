# Module ansible_default_hana_install

This module calls ansible collection and installs SAP HANA, S4HANA/BW4HANA on target system.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.0 |
| <a name="requirement_null"></a> [null](#requirement\_null) | >= 3.2.1 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [null_resource.sap_hana_install](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [null_resource.sap_nw_install](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_access_host_or_ip"></a> [access\_host\_or\_ip](#input\_access\_host\_or\_ip) | Public IP of Bastion Host | `string` | n/a | yes |
| <a name="input_ansible_parameters"></a> [ansible\_parameters](#input\_ansible\_parameters) | HANA and S4HANA/BW4HANA Installation parameters | <pre>object(<br>    {<br>      enable                      = bool<br>      solution                    = string<br>      hana_ansible_vars           = map(any)<br>      netweaver_ansible_vars      = map(any)<br>      hana_instance_sap_ip        = string<br>      hana_instance_hostname      = string<br>      netweaver_instance_hostname = string<br><br>    }<br>  )</pre> | n/a | yes |
| <a name="input_ssh_private_key"></a> [ssh\_private\_key](#input\_ssh\_private\_key) | Private Key to configure Instance, Will not be uploaded to server. | `string` | n/a | yes |
| <a name="input_target_server_hana_ip"></a> [target\_server\_hana\_ip](#input\_target\_server\_hana\_ip) | HANA Private IP of PowerVS instance reachable from the access host. | `string` | n/a | yes |
| <a name="input_target_server_nw_ip"></a> [target\_server\_nw\_ip](#input\_target\_server\_nw\_ip) | Netweaver Private IP of PowerVS instance reachable from the access host. | `string` | n/a | yes |

## Outputs

No outputs.
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
