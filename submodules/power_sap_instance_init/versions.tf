#####################################################
# powervs instance initialization SLES Module
#####################################################

terraform {
  required_version = ">=1.1"
  required_providers {
    null = {
      source  = "hashicorp/null"
      version = ">= 3.2.1"
    }
  }
}
