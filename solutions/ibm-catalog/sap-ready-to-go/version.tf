#####################################################
# PowerVs SAP Instance Module
#####################################################

terraform {
  required_version = ">= 1.9.0"
  required_providers {
    ibm = {
      source  = "IBM-Cloud/ibm"
      version = "2.0.0"
    }
    restapi = {
      source  = "Mastercard/restapi"
      version = "3.0.0"
    }
  }
}
