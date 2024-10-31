terraform {
  required_version = ">= 1.9.0.0"
  required_providers {
    tls = {
      source  = "hashicorp/tls"
      version = ">= 4.0.4"
    }
  }
}
