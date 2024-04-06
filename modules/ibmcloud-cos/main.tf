#####################################################
# 1. Download objects from IBMCLOUD COS
#####################################################

locals {
  scr_scripts_dir = "${path.module}/templates"
  dst_files_dir   = "/root/terraform_files"
  date            = formatdate("DD-MM-YYYY-hh-mm", timestamp())

  src_script_ibmcloud_cos_tfpl_path = "${local.scr_scripts_dir}/ibmcloud_cos.sh.tfpl"
  dst_script_ibmcloud_cos_sh_path   = "${local.dst_files_dir}/ibmcloud_cos_download_${local.date}.sh"
  log_file                          = "${local.dst_files_dir}/ibmcloud_cos_download_${local.date}_status.log"

}

#####################################################
# 1. Download objects from IBMCLOUD COS
#####################################################

resource "terraform_data" "trigger_cos_configuration" {
  input = var.ibmcloud_cos_configuration
}

resource "terraform_data" "download_objects" {

  connection {
    type         = "ssh"
    user         = "root"
    bastion_host = var.access_host_or_ip
    host         = var.target_server_ip
    private_key  = var.ssh_private_key
    agent        = false
    timeout      = "10m"
  }

  triggers_replace = terraform_data.trigger_cos_configuration

  provisioner "remote-exec" {
    inline = ["mkdir -p ${local.dst_files_dir}", "chmod 777 ${local.dst_files_dir}", ]
  }

  ####### Copy Template file to target host ############
  provisioner "file" {
    destination = local.dst_script_ibmcloud_cos_sh_path
    content = templatefile(
      local.src_script_ibmcloud_cos_tfpl_path,
      {
        "cos_region" : var.ibmcloud_cos_configuration.cos_region
        "cos_resource_instance_id" : var.ibmcloud_cos_configuration.cos_resource_instance_id
        "cos_bucket_name" : var.ibmcloud_cos_configuration.cos_bucket_name
        "cos_dir_name" : var.ibmcloud_cos_configuration.cos_dir_name
        "download_dir_path" : var.ibmcloud_cos_configuration.download_dir_path
      }
    )
  }

  ####  Execute shell script to download objects from COS  ####
  provisioner "remote-exec" {
    inline = [
      "chmod +x ${local.dst_script_ibmcloud_cos_sh_path}",
      "${local.dst_script_ibmcloud_cos_sh_path} -i ${var.ibmcloud_cos_configuration.cos_apikey} &> ${local.log_file} || { exit 1; } ",
      "chmod 777 -R ${var.ibmcloud_cos_configuration.download_dir_path}"
    ]
  }

  provisioner "remote-exec" {
    inline = [
      "cat ${local.log_file}"
    ]
  }
}
