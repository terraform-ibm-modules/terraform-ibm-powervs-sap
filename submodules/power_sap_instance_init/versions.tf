#####################################################
# powervs instance initialization SLES Module
# Copyright 2022 IBM
#####################################################

terraform {
  required_version = ">=1.1"
  required_providers {
    null = {
      source  = "hashicorp/null"
      version = ">= 3.1.1"
    }
  }
}
