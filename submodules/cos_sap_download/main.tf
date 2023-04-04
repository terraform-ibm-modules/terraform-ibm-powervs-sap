#####################################################
# COS access
#####################################################

resource "null_resource" "cos_config_download_sap" {
  count = length(var.cos_config["cos_source_folders_paths"])

  connection {
    type         = "ssh"
    user         = "root"
    bastion_host = var.access_host_or_ip
    host         = var.host_ip
    private_key  = var.ssh_private_key
    agent        = false
    timeout      = "5m"
  }

  provisioner "remote-exec" {
    inline = [

      ##### CONFIGURE AWSCLI and COPY #####
      "aws configure set aws_access_key_id \"${var.cos_config["cos_access_key"]}\"",
      "aws configure set aws_secret_access_key \"${var.cos_config["cos_secret_access_key"]}\"",
      "aws  --endpoint-url ${var.cos_config["cos_endpoint_url"]} s3 cp s3://${var.cos_config["cos_bucket_name"]}${var.cos_config["cos_source_folders_paths"][count.index]} ${var.cos_config["target_folder_path_local"]}${var.cos_config["cos_source_folders_paths"][count.index]} --recursive ",
      "chmod 777 -R ${var.cos_config["target_folder_path_local"]}",

    ]
  }

}
