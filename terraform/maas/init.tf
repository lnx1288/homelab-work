terraform {
  required_providers {
    maas = {
      source  = "maas/maas"
      version = "~>1.0"
    }
  }
}

provider "maas" {
  api_version = "2.0"
  api_key = "maas-key-here"
  api_url = "http://10.0.1.253:5240/MAAS"
}
