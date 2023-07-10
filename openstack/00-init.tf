terraform {
  required_version = ">= 0.14.0"
  required_providers {
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = "1.49.0"
    }
  }
}

provider "openstack" {
  cloud = var.cloud
}

variable "domain_id" {
  type    = string
  default = ""
}

variable "cloud" {
  type    = string
  default = ""
}
