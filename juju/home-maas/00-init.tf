terraform {
  required_providers {
    juju = {
      version = "~> 0.12.0"
      #source  = "juju/juju"
      source = "terraform.local/juju/juju"
    }
  }
}
