data "openstack_images_image_v2" "image" {
  name        = var.image
  most_recent = true
}


resource "openstack_blockstorage_volume_v3" "volume_data" {
  name        = "volume_data"
  size        = 200
  volume_type = var.volume_type
}

resource "openstack_blockstorage_volume_v3" "volume_boot" {
  name        = "volume_boot"
  size        = 10
  image_id    = data.openstack_images_image_v2.image.id
  volume_type = var.volume_type
}

resource "openstack_networking_port_v2" "server_port" {
  name           = "server_eth0"
  network_id     = openstack_networking_network_v2.network_test.id
  admin_state_up = "true"
  security_group_ids = [openstack_networking_secgroup_v2.server_secgroup_test.id]
  binding {
    vnic_type = "direct"
  }
}

resource "openstack_compute_instance_v2" "server_test" {
  name            = "fio_test_server"
  image_id        = data.openstack_images_image_v2.image.id
  flavor_id       = openstack_compute_flavor_v2.canonical_m1_xlarge_fio.id
  config_drive    = "true"

  block_device {
    uuid                  = openstack_blockstorage_volume_v3.volume_boot.id
    source_type           = "volume"
    boot_index            = 0
    destination_type      = "volume"
  }

  block_device {
    uuid                  = openstack_blockstorage_volume_v3.volume_data.id
    source_type           = "volume"
    boot_index            = 1
    destination_type      = "volume"
  }

  network {
    port = openstack_networking_port_v2.server_port.id
  }

  user_data = file("user-data.yaml")
}
