resource "openstack_networking_network_v2" "network_test" {
  name           = "network_test"
  admin_state_up = "true"

  segments {
    physical_network = "physnet_sriov1"
    segmentation_id  = "1498"
    network_type     = "vlan"
  }
}

resource "openstack_networking_subnet_v2" "subnet_test" {
  network_id = openstack_networking_network_v2.network_test.id
  name       = "server_test_sn"
  cidr       = "10.0.9.0/24"

  enable_dhcp = "false"

  allocation_pool {
    start = "10.0.9.36"
    end   = "10.0.9.62"
  }

}
