terraform {
  required_version = ">= 1.9.0"
  required_providers {
    ibm = {
      source  = "IBM-Cloud/ibm"
      version = "1.80.4"
    }
    time = {
      source  = "hashicorp/time"
      version = "0.13.1"
    }

    restapi = {
      source  = "Mastercard/restapi"
      version = "2.0.1"
    }
  }
}
