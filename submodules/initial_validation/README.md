# Submodule initial-validation

This submodule checks the right combination of variables and validates them

## Usage
```hcl
provider "ibm" {
region           = "sao"
zone             = "sao01"
ibmcloud_api_key = "your api key" != null ? "your api key" : null
}

module "initial_validation" {
source = "./submodules/initial_validation"
cloud_connection_validate = var.cloud_connection_validate
}

```
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >=1.1 |

## Modules

No modules.

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_configure_os_validate"></a> [configure\_os\_validate](#input\_configure\_os\_validate) | Verify congifure\_os variable with access\_host\_or\_ip, ssh\_private\_key and proxy\_host\_or\_ip\_port | <pre>object({<br>    configure_os          = bool<br>    access_host_or_ip     = string<br>    ssh_private_key       = string<br>    proxy_host_or_ip_port = string<br>  })</pre> | n/a | yes |

## Outputs

No outputs.
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
