# Module pvs-instance-sap-init-sles

This module configures the PVS instance and prepares the system for SAP installation.
- Configure Forward Proxy
- SUSE Registration
- Install Packages
- Run ansible galaxy roles

Note: prerequisite The bastion host must be running SQUID proxy server with 3128 port open. If squid server is not on bastion host, then pass the squid server public and private ips to variables `input_bastion_public_ip` and `input_bastion_private_ip`

## Example Usage
```
```

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >=1.1 |
| <a name="requirement_null"></a> [null](#requirement\_null) | >= 3.1.1 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [null_resource.configure_proxy](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [null_resource.execute_ansible_role](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [null_resource.install_packages](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [null_resource.suse_register](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_bastion_public_ip"></a> [bastion\_public\_ip](#input\_bastion\_public\_ip) | Public IP of Bastion Host | `string` | n/a | yes |
| <a name="input_host_private_ip"></a> [host\_private\_ip](#input\_host\_private\_ip) | Private IP of NetWeaver/HANA Host reachable from bastion | `string` | n/a | yes |
| <a name="input_os_activation"></a> [os\_activation](#input\_os\_activation) | SuSe activation username, password and Os release to register Os. Release value should be in for x.x. For example SLES15 SP3, value would be 15.3 | `map(any)` | <pre>{<br>  "activation_password": "",<br>  "activation_username": "",<br>  "os_release": "15.3",<br>  "required": false<br>}</pre> | no |
| <a name="input_pvs_instance_storage_config"></a> [pvs\_instance\_storage\_config](#input\_pvs\_instance\_storage\_config) | Disks properties to create filesystems | `map(any)` | <pre>{<br>  "counts": "",<br>  "disks_size": "",<br>  "names": "",<br>  "paths": "",<br>  "wwns": ""<br>}</pre> | no |
| <a name="input_sap_solution"></a> [sap\_solution](#input\_sap\_solution) | To Execute Playbooks for Hana or NetWeaver. Value can be either HANA OR NETWEAVER | `string` | n/a | yes |
| <a name="input_ssh_private_key"></a> [ssh\_private\_key](#input\_ssh\_private\_key) | Private Key to configure Instance, Will not be uploaded to server | `string` | n/a | yes |
| <a name="input_vpc_bastion_proxy_config"></a> [vpc\_bastion\_proxy\_config](#input\_vpc\_bastion\_proxy\_config) | SQUID configuration if required on HANA/nw node to reach public internet via the Bastion host on VSI running SQUID server | `map(any)` | <pre>{<br>  "no_proxy_ips": "",<br>  "required": false,<br>  "vpc_bastion_private_ip": ""<br>}</pre> | no |

## Outputs

No outputs.
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
