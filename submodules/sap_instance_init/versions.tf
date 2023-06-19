#####################################################
# powervs sap instance initialization Module
#####################################################

terraform {
  required_version = ">= 1.3, < 1.5"
  required_providers {
    null = {
      source  = "hashicorp/null"
      version = ">= 3.2.1"
    }
  }
}
