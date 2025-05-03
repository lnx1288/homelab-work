data "openstack_compute_flavor_v2" "m1_small" {
    name = "m1.small"
}

resource "openstack_compute_instance_v2" "test_server_01" {
  name            = "test_server_01"
  flavor_id       = data.openstack_compute_flavor_v2.m1_small.id
  key_pair        = openstack_compute_keypair_v2.alejandro-key.name
  security_groups = [
    "default",
    openstack_compute_secgroup_v2.allow_ssh.name,
    openstack_compute_secgroup_v2.allow_ping.name,
  ]

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

  user_data = file("user-data.yaml")
}

resource "openstack_networking_floatingip_v2" "fip" {
  pool = "ext_net"
}

resource "openstack_compute_floatingip_associate_v2" "fip" {
  floating_ip = openstack_networking_floatingip_v2.fip.address
  instance_id = openstack_compute_instance_v2.test_server_01.id
}

