#####################################################
# IBM Cloud PowerVS workspace Module
#####################################################

terraform {
  required_version = ">= 1.3"
  required_providers {
    null = {
      source  = "hashicorp/null"
      version = ">= 3.2.1"
    }
  }
}
