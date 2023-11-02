ibmcloud_api_key            = ""
powervs_zone                = "" #syd04
prefix                      = ""
powervs_workspace_guid      = ""
powervs_ssh_public_key_name = ""
powervs_networks            = "" #[{ "cidr" : "10.61.0.0/24", "id" : "c39dadb6-830c-4567-8b36-d176f8fe3aab", "name" : "mgmt_net" }, { "cidr" : "10.62.0.0/24", "id" : "340bde12-5e32-48ee-8624-058d0b80d990", "name" : "bkp_net" }]
powervs_sap_network_cidr    = "" #10.78.0.1/24
powervs_create_sharefs_instance = {
  enable   = "" #true or false
  image_id = ""
}
powervs_hana_instance_image_id      = ""
powervs_netweaver_instance_image_id = ""
powervs_instance_init_linux = {
  enable                = "" #true or false
  bastion_host_ip       = ""
  proxy_host_or_ip_port = "" #10.30.10.4:3128
  no_proxy_hosts        = "161.0.0.0/8,10.0.0.0/8"
  ssh_private_key       = <<-EOF
EOF
}
