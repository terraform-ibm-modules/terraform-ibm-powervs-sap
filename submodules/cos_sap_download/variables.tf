variable "cos_config" {
  description = "COS bucket access information to copy the software to LOCAL DISK"
  type = object(
    {
      cos_bucket_name          = string
      cos_access_key           = string
      cos_secret_access_key    = string
      cos_endpoint_url         = string
      cos_source_folders_paths = list(string)
      target_folder_path_local = string
    }
  )
}

variable "access_host_or_ip" {
  description = "Public IP of Jump/Bastion Host"
  type        = string
}

variable "host_ip" {
  description = "Host Private IP reachable from the access host where software will be downloaded."
  type        = string
}

variable "ssh_private_key" {
  description = "Private Key to confgure Instance, Will not be uploaded to server"
  type        = string
}
