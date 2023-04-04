# Module cos_sap_download

This module copies files from Cloud object storage to target system

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.0 |
| <a name="requirement_null"></a> [null](#requirement\_null) | >= 3.1.1 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [null_resource.cos_config_download_sap](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_access_host_or_ip"></a> [access\_host\_or\_ip](#input\_access\_host\_or\_ip) | Public IP of Jump/Bastion Host | `string` | n/a | yes |
| <a name="input_cos_config"></a> [cos\_config](#input\_cos\_config) | COS bucket access information to copy the software to LOCAL DISK | <pre>object(<br>    {<br>      cos_bucket_name          = string<br>      cos_access_key           = string<br>      cos_secret_access_key    = string<br>      cos_endpoint_url         = string<br>      cos_source_folders_paths = list(string)<br>      target_folder_path_local = string<br>    }<br>  )</pre> | n/a | yes |
| <a name="input_host_ip"></a> [host\_ip](#input\_host\_ip) | Host Private IP reachable from the access host where software will be downloaded. | `string` | n/a | yes |
| <a name="input_ssh_private_key"></a> [ssh\_private\_key](#input\_ssh\_private\_key) | Private Key to confgure Instance, Will not be uploaded to server | `string` | n/a | yes |

## Outputs

No outputs.
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
