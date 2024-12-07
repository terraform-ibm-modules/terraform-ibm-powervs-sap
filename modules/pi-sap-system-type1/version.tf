#####################################################
# PowerVs SAP System Module
#####################################################

terraform {
  required_version = ">= 1.9.0"
  required_providers {
    # tflint-ignore: terraform_unused_required_providers
    ibm = {
      source  = "IBM-Cloud/ibm"
      version = ">= 1.71.3"
    }
    time = {
      source  = "hashicorp/time"
      version = ">= 0.9.1"
    }

  }
}
