data "openstack_compute_flavor_v2" "m1_small" {
    name = "m1.small"
}

resource "openstack_compute_instance_v2" "test_server_01" {
  name            = "test_server_01"
  flavor_id       = data.openstack_compute_flavor_v2.m1_small.id
  key_pair        = openstack_compute_keypair_v2.arif-key.name
  security_groups = ["default"]

  block_device {
    uuid                  = openstack_images_image_v2.bionic-raw.id
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

