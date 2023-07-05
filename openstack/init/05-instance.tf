resource "openstack_compute_instance_v2" "test_server_01" {
  name            = "test_server_01"
  flavor_id       = "2" # m1.small
  key_pair        = openstack_compute_keypair_v2.arif-key.name
  security_groups = ["default"]

  block_device {
    uuid                  = "6058341e-2fa5-457b-b1ab-870930202e04" # bionic-raw
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

