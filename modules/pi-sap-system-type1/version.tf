#####################################################
# PowerVs SAP System Module
#####################################################

terraform {
  required_version = ">= 1.3"
  required_providers {
    # tflint-ignore: terraform_unused_required_providers
    ibm = {
      source  = "IBM-Cloud/ibm"
      version = ">= 1.58.1"
    }
    # tflint-ignore: terraform_unused_required_providers
    null = {
      source  = "hashicorp/null"
      version = ">= 3.2.1"
    }

  }
}
