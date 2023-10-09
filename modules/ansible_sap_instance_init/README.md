# Module power_sap_instance_init

This module configures the PVS instance and prepares the system for SAP installation.
- Run ansible galaxy roles to prepare OS for SAP

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
### Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3, <1.6.0 |
| <a name="requirement_null"></a> [null](#requirement\_null) | >= 3.2.1 |

### Modules

No modules.

### Resources

| Name | Type |
|------|------|
| [null_resource.configure_os_for_sap](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_access_host_or_ip"></a> [access\_host\_or\_ip](#input\_access\_host\_or\_ip) | Public IP of Bastion Host | `string` | n/a | yes |
| <a name="input_sap_domain"></a> [sap\_domain](#input\_sap\_domain) | Domain name to be set. | `string` | `""` | no |
| <a name="input_sap_solutions"></a> [sap\_solutions](#input\_sap\_solutions) | List of SAP solution configurations to be executed on the PowerVS instances defined in 'target\_server\_ips'. The order should match to 'target\_server\_ips'. Possible values are 'HANA', 'NETWEAVER', 'NONE'. | `list(string)` | n/a | yes |
| <a name="input_ssh_private_key"></a> [ssh\_private\_key](#input\_ssh\_private\_key) | Private Key to configure Instance, Will not be uploaded to server. | `string` | n/a | yes |
| <a name="input_target_server_ips"></a> [target\_server\_ips](#input\_target\_server\_ips) | List of private IPs of PowerVS instances reachable from the access host. | `list(string)` | n/a | yes |

### Outputs

No outputs.
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
