#####################################################
# PowerVs SAP Instance Module
# Copyright 2022 IBM
#####################################################

terraform {
  required_version = ">= 1.3.0"
  required_providers {
    ibm = {
      source  = "IBM-Cloud/ibm"
      version = ">=1.49.0"
    }
  }
}
