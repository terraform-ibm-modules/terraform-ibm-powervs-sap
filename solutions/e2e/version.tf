terraform {
  required_version = ">= 1.3, < 1.6"
  required_providers {
    ibm = {
      source  = "IBM-Cloud/ibm"
      version = ">=1.61.0"
    }
    time = {
      source  = "hashicorp/time"
      version = ">= 0.9.1"
    }
  }
}
