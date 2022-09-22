ibmcloud_api_key            = ""
powervs_zone                = "sao01"
powervs_resource_group_name = "Automation"
powervs_service_name        = "sprint-sao01-power-service"
powervs_sshkey_name         = "sprint-sao01-ssh-pvs-key"

prefix                   = "sap"
additional_networks      = ["mgmt_net", "bkp_net"]
cloud_connection_count   = "2"
powervs_sap_network_cidr = "10.116.1.0/24"
os_image_distro          = "SLES"

sap_hana_hostname             = "hana"
sap_hana_profile              = "cnp-2x64"
sap_netweaver_hostname        = "nw"
sap_netweaver_instance_number = 1
sap_netweaver_cpu_number      = "0.5"
sap_netweaver_memory_size     = "4"
create_separate_fs_share      = false

configure_os      = true
access_host_or_ip = "13.116.81.120"
proxy_host_or_ip  = "10.30.10.4"
dns_host_or_ip    = "10.20.10.4"
ntp_host_or_ip    = "10.20.10.4"
nfs_path          = "10.20.10.4:/nfs"

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
sap_hana_instance_config = {
  hostname       = ""
  domain         = ""
  host_ip        = ""
  sap_profile_id = ""
  os_image_name  = ""
}
sap_hana_additional_storage_config = {
  names      = "data,log,shared,usrsap"
  disks_size = "250,150,1000,50"
  counts     = "4,4,1,1"
  tiers      = "tier1,tier1,tier3,tier3"
  paths      = "/hana/data,/hana/log,/hana/shared,/usr/sap"
}
sap_share_instance_config = {
  hostname             = ""
  domain               = ""
  host_ip              = ""
  os_image_name        = ""
  cpu_proc_type        = "shared"
  number_of_processors = "0.5"
  memory_size          = "4"
  server_type          = "s922"
}
sap_share_storage_config = {
  names      = "share"
  disks_size = "1000"
  counts     = "1"
  tiers      = "tier3"
  paths      = "/share"
}
sap_netweaver_instance_config = {
  number_of_instances  = ""
  hostname             = ""
  domain               = ""
  host_ips             = ""
  os_image_name        = ""
  cpu_proc_type        = "shared"
  number_of_processors = ""
  memory_size          = ""
  server_type          = "s922"
}
sap_netweaver_storage_config = {
  names      = "usrsap,usrtrans"
  disks_size = "50,50"
  counts     = "1,1"
  tiers      = "tier3,tier3"
  paths      = "/usr/sap,/usr/sap/trans"
}
