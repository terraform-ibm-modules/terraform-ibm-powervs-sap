# Module power_sap_instance_init

This module configures the PVS instance and prepares the system for SAP installation.
- Configure Forward Proxy
- SUSE/RHEL Registration
- Install Packages
- Run ansible galaxy roles

Note: prerequisite The bastion host must be running SQUID proxy server with 3128 port open. If squid server is not on bastion host, then pass the squid server public and private ips to variables `access_host_or_ip` and `target_server_ips`

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3, < 1.5 |
| <a name="requirement_null"></a> [null](#requirement\_null) | >= 3.2.1 |
| <a name="requirement_time"></a> [time](#requirement\_time) | >= 0.9.1 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [null_resource.configure_os_for_sap](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [null_resource.connect_to_mgmt_svs](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [null_resource.install_packages](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [null_resource.perform_proxy_client_setup](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [null_resource.update_os](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [time_sleep.wait_for_reboot](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/sleep) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_access_host_or_ip"></a> [access\_host\_or\_ip](#input\_access\_host\_or\_ip) | Public IP of Bastion Host | `string` | n/a | yes |
| <a name="input_os_image_distro"></a> [os\_image\_distro](#input\_os\_image\_distro) | Image distribution to use. Supported values are 'SLES' or 'RHEL'. OS release versions may be specified in optional parameters. | `string` | n/a | yes |
| <a name="input_perform_dns_client_setup"></a> [perform\_dns\_client\_setup](#input\_perform\_dns\_client\_setup) | Configures a PowerVS instance to use DNS server. | <pre>object(<br>    {<br>      enable    = bool<br>      server_ip = string<br>    }<br>  )</pre> | <pre>{<br>  "enable": false,<br>  "server_ip": ""<br>}</pre> | no |
| <a name="input_perform_nfs_client_setup"></a> [perform\_nfs\_client\_setup](#input\_perform\_nfs\_client\_setup) | Mounts NFS share on PowerVS instance. | <pre>object(<br>    {<br>      enable          = bool<br>      nfs_server_path = string<br>      nfs_client_path = string<br>    }<br>  )</pre> | <pre>{<br>  "enable": false,<br>  "nfs_client_path": "",<br>  "nfs_server_path": ""<br>}</pre> | no |
| <a name="input_perform_ntp_client_setup"></a> [perform\_ntp\_client\_setup](#input\_perform\_ntp\_client\_setup) | Configures a PowerVS instance to use NTP server. | <pre>object(<br>    {<br>      enable    = bool<br>      server_ip = string<br>    }<br>  )</pre> | <pre>{<br>  "enable": false,<br>  "server_ip": ""<br>}</pre> | no |
| <a name="input_perform_proxy_client_setup"></a> [perform\_proxy\_client\_setup](#input\_perform\_proxy\_client\_setup) | Configures a PowerVS instance to have internet access by setting proxy on it. E.g., 10.10.10.4:3128 <ip:port> | <pre>object(<br>    {<br>      enable         = bool<br>      server_ip_port = string<br>      no_proxy_hosts = string<br>    }<br>  )</pre> | <pre>{<br>  "enable": false,<br>  "no_proxy_hosts": "",<br>  "server_ip_port": ""<br>}</pre> | no |
| <a name="input_powervs_instance_storage_configs"></a> [powervs\_instance\_storage\_configs](#input\_powervs\_instance\_storage\_configs) | List of storage configurations for PowerVS instances defined in 'target\_server\_ips'. The order should match to 'target\_server\_ips'. Storage configurations have following form: '{names = "" disks\_size = "" counts = "" tiers = "" paths = "" wwns = ""}' | <pre>list(object(<br>    {<br>      names      = string<br>      disks_size = string<br>      counts     = string<br>      tiers      = string<br>      paths      = string<br>      wwns       = string<br>    }<br>    )<br>  )</pre> | n/a | yes |
| <a name="input_sap_domain"></a> [sap\_domain](#input\_sap\_domain) | Domain name to be set. | `string` | `""` | no |
| <a name="input_sap_solutions"></a> [sap\_solutions](#input\_sap\_solutions) | List of SAP solution configurations to be executed on the PowerVS instances defined in 'target\_server\_ips'. The order should match to 'target\_server\_ips'. Possible values are 'HANA', 'NETWEAVER', 'NONE'. | `list(string)` | n/a | yes |
| <a name="input_ssh_private_key"></a> [ssh\_private\_key](#input\_ssh\_private\_key) | Private Key to configure Instance, Will not be uploaded to server. | `string` | n/a | yes |
| <a name="input_target_server_ips"></a> [target\_server\_ips](#input\_target\_server\_ips) | List of private IPs of PowerVS instances reachable from the access host. | `list(string)` | n/a | yes |

## Outputs

No outputs.
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
