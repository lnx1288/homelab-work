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

data "openstack_compute_flavor_v2" "m1_small" {
    name = "m1.small"
}

data "openstack_images_image_v2" "bionic-raw" {
    name        = "bionic-raw"
    most_recent = true
}

resource "openstack_compute_instance_v2" "test_servers" {
  count           = 3
  name            = format("%s_%02d", "test_server", count.index+1)
  flavor_id       = data.openstack_compute_flavor_v2.m1_small.id
  key_pair        = "arif-key"
  security_groups = ["default"]

  block_device {
    uuid                  = data.openstack_images_image_v2.bionic-raw.id
    source_type           = "image"
    volume_size           = 10
    boot_index            = 0
    destination_type      = "volume"
    delete_on_termination = true
  }

  network {
    name = "private"
  }
}
