
variable "access_host_or_ip" {
  description = "Public IP of Bastion Host."
  type        = string
}

variable "target_server_ip" {
  description = "Private IP of PowerVS instance reachable from the access host."
  type        = string
}

variable "ssh_private_key" {
  description = "Private Key to configure Instance, Will not be uploaded to server."
  type        = string
  sensitive   = true
}

variable "ibmcloud_cos_configuration" {
  description = "IBM Cloud Object Storage details to download the files to the target host."
  type = object({
    cos_apikey               = string
    cos_region               = string
    cos_resource_instance_id = string
    cos_bucket_name          = string
    cos_dir_name             = string
    download_dir_path        = string
  })
  sensitive = true
}
