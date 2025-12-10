data "openstack_compute_flavor_v2" "m1_small" {
    name = "m1.small"
}

data "openstack_images_image_v2" "bionic-raw" {
    name        = "bionic-raw"
    most_recent = true
}

resource "openstack_compute_instance_v2" "test_servers" {
  count           = 7
  name            = format("%s_%02d", "test_server", count.index+1)
  flavor_id       = data.openstack_compute_flavor_v2.m1_small.id
  key_pair        = "alejandro-key"
  security_groups = ["default"]

  block_device {
    uuid                  = data.openstack_images_image_v2.cirros.id
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
