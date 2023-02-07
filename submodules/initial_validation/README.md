# Submodule initial-validation

This submodule checks the right combination of variables and validates them

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.0 |

## Modules

No modules.

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_configure_os_validate"></a> [configure\_os\_validate](#input\_configure\_os\_validate) | Verify configure\_os variable with access\_host\_or\_ip, ssh\_private\_key and proxy\_host\_or\_ip\_port | <pre>object({<br>    configure_os          = bool<br>    access_host_or_ip     = string<br>    ssh_private_key       = string<br>    proxy_host_or_ip_port = string<br>  })</pre> | n/a | yes |

## Outputs

No outputs.
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
