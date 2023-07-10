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
  cloud = "arif-home"
}

variable "domain_id" {
  type = string
  default = "3fd5a53e08e243b49ac3b171d57b4e4a"
}
