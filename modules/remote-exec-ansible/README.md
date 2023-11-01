# Module remote-exec-ansible

This module uses a terraform_data resource to perform following operations on a host behind a jump/bastion/access host_or_ip in following order:

- Executes a list of inline commands as the first remote-exec provisioner.
- Executes a first file provisioner to copy a file to remote host using a template file allowing to write content.
- Executes a second file provisioner to copy a file to remote host using a template file allowing to write content.
- Executes a list of inline commands as the last remote-exec provisioner.

## Usage
```hcl

module "configure_os" {
  source     = "terraform-ibm-modules/powervs-instance/ibm//modules//remote-exec-ansible"
  version    = "x.x.x" #replace x.x.x to lock to a specific version

  bastion_host_ip                       = var.bastion_host_ip
  host_ip                               = var.host_ip
  ssh_private_key                       = var.ssh_private_key
  provisioner_remote_exec_inline_pre_exec_commands  = var.provisioner_remote_exec_inline_pre_exec_commands
  provisioner_file_1        = var.provisioner_file_1
  provisioner_file_2        = var.provisioner_file_2
  provisioner_remote_exec_inline_post_exec_commands = var.provisioner_remote_exec_inline_post_exec_commands
}
```

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
### Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3 |

### Modules

No modules.

### Resources

| Name | Type |
|------|------|
| [terraform_data.remote_exec_ansible](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/resources/data) | resource |

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_bastion_host"></a> [bastion\_host](#input\_bastion\_host) | Public IP of bastion host. | `string` | n/a | yes |
| <a name="input_dst_playbook_file_name"></a> [dst\_playbook\_file\_name](#input\_dst\_playbook\_file\_name) | Playbook filename. | `string` | n/a | yes |
| <a name="input_dst_script_file_name"></a> [dst\_script\_file\_name](#input\_dst\_script\_file\_name) | Bash script filename. | `string` | n/a | yes |
| <a name="input_host"></a> [host](#input\_host) | Private IP of instance reachable from the bastion host. | `string` | n/a | yes |
| <a name="input_playbook_template_content"></a> [playbook\_template\_content](#input\_playbook\_template\_content) | Playbook template content. | `map(any)` | n/a | yes |
| <a name="input_src_playbook_template_name"></a> [src\_playbook\_template\_name](#input\_src\_playbook\_template\_name) | Playbook template filename. | `string` | n/a | yes |
| <a name="input_src_script_template_name"></a> [src\_script\_template\_name](#input\_src\_script\_template\_name) | Bash template script filename. | `string` | n/a | yes |
| <a name="input_ssh_private_key"></a> [ssh\_private\_key](#input\_ssh\_private\_key) | Private Key to configure Instance, will not be uploaded to server. | `string` | n/a | yes |

### Outputs

No outputs.
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
