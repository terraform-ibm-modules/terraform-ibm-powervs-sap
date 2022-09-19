#####################################################
# PowerVs SAP Instance Module
# Copyright 2022 IBM
#####################################################

terraform {
  required_version = ">=1.1"
  required_providers {
    ibm = {
      source  = "IBM-Cloud/ibm"
      version = ">=1.43.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "4.0.1"
    }
  }
}
