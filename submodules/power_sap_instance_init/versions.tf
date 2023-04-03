#####################################################
# powervs instance initialization SLES Module
#####################################################

terraform {
  required_version = ">= 1.3, < 1.5"
  required_providers {
    null = {
      source  = "hashicorp/null"
      version = ">= 3.2.1"
    }
    time = {
      source  = "hashicorp/time"
      version = ">= 0.9.1"
    }
  }
}
