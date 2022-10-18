#### Exisiting power workspace parmeters from sap infra output ####
ibmcloud_api_key            = "<value>"
access_host_or_ip           = "<value>"
cloud_connection_count      = 2
dns_host_or_ip              = "<value>"
nfs_path                    = "<value>" # "10.20.10.4:/nfs"
ntp_host_or_ip              = "<value>"
powervs_resource_group_name = "<value>"
powervs_sshkey_name         = "<value>"
powervs_workspace_name      = "<value>"
powervs_zone                = "<value>"
proxy_host_or_ip_port       = "<value>" # "10.30.10.4:3128"

################
additional_networks      = ["mgmt_net", "bkp_net"]
prefix                   = "<value>"
os_image_distro          = "SLES"
powervs_sap_network_cidr = "<value>" # "10.116.1.0/24"

##### Share instance parameters ###
create_separate_fs_share = false

#### HANA Instance Parameters ####
sap_hana_hostname = "hana"
sap_hana_profile  = "cnp-2x64"
sap_hana_additional_storage_config = {
  names      = "usrsap"
  disks_size = "50"
  counts     = "1"
  tiers      = "tier3"
  paths      = "/usr/sap"
}

#### Netweaver Instance Parameters ####
sap_netweaver_hostname        = "nw"
sap_netweaver_instance_number = 1
sap_netweaver_cpu_number      = "0.5"
sap_netweaver_memory_size     = "4"

##### OS initilization parameters #####
configure_os = true
sap_domain   = "sap.com"

ssh_private_key = <<-EOF
EOF

#Optional Parameters
default_hana_sles_image      = "SLES15-SP3-SAP"
default_netweaver_sles_image = "SLES15-SP3-SAP-NETWEAVER"
default_shared_fs_sles_image = "SLES15-SP3-SAP-NETWEAVER"
default_hana_rhel_image      = "RHEL8-SP4-SAP"
default_netweaver_rhel_image = "RHEL8-SP4-SAP-NETWEAVER"
default_shared_fs_rhel_image = "RHEL8-SP4-SAP-NETWEAVER"
nfs_client_directory         = "/nfs"
sap_share_instance_config = {
  os_image_name        = ""
  number_of_processors = "0.5"
  memory_size          = "4"
  cpu_proc_type        = "shared"
  server_type          = "s922"
}
sap_share_storage_config = {
  names      = "share"
  disks_size = "1000"
  counts     = "1"
  tiers      = "tier3"
  paths      = "/share"
}
sap_hana_instance_config = {
  os_image_name  = ""
  sap_profile_id = ""
}
sap_hana_custom_storage_config = {
  names      = ""
  disks_size = ""
  counts     = ""
  tiers      = ""
  paths      = ""
}
sap_netweaver_instance_config = {
  number_of_instances  = ""
  os_image_name        = ""
  number_of_processors = ""
  memory_size          = ""
  cpu_proc_type        = "shared"
  server_type          = "s922"
}
sap_netweaver_storage_config = {
  names      = "usrsap,usrtrans"
  disks_size = "50,50"
  counts     = "1,1"
  tiers      = "tier3,tier3"
  paths      = "/usr/sap,/usr/sap/trans"
}
