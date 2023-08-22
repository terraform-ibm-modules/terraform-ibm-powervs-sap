#############################################
# Locals file for sap configuration
#############################################

locals {

  scr_scripts_dir = "${path.module}/templates"
  dst_scripts_dir = "/root/terraform_scripts"

  ## for every solution always use 6 attributes as defined for s4b4 solution
  ansible_sap_solutions = {
    "s4b4_hana" = {
      "src_ansible_variable_path"             = "${local.scr_scripts_dir}/hanadb/sap-hana-install-vars-for-s4hana-bw4hana.yml.tfpl",
      "dst_ansible_variable_path"             = "${local.dst_scripts_dir}/sap-hana-install-vars.yml"
      "src_ansible_playbook_path"             = "${local.scr_scripts_dir}/hanadb/sap-hana-install.yml",
      "dst_ansible_playbook_path"             = "${local.dst_scripts_dir}/sap-hana-install.yml",
      "src_script_install_solution_tfpl_path" = "${local.scr_scripts_dir}/hanadb/install_hana.sh.tfpl",
      "dst_script_install_solution_tfpl_path" = "${local.dst_scripts_dir}/install_hana.sh"
    }

    "s4b4_solution" = {
      "src_ansible_variable_path"             = "${local.scr_scripts_dir}/s4hanab4hana_solution/sap-swpm-install-vars-s4hana-bw4hana.yml.tfpl",
      "dst_ansible_variable_path"             = "${local.dst_scripts_dir}/sap-swpm-install-vars.yml"
      "src_ansible_playbook_path"             = "${local.scr_scripts_dir}/s4hanab4hana_solution/sap-swpm-install.yml",
      "dst_ansible_playbook_path"             = "${local.dst_scripts_dir}/sap-swpm-install.yml",
      "src_script_install_solution_tfpl_path" = "${local.scr_scripts_dir}/s4hanab4hana_solution/install_swpm.sh.tfpl",
      "dst_script_install_solution_tfpl_path" = "${local.dst_scripts_dir}/install_swpm.sh"
    }

  }
}
