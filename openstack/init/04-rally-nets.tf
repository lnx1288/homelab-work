resource "openstack_networking_network_v2" "private_network_rally" {
  name           = "private_network_rally"
  admin_state_up = "true"
  shared         = "true"
}

resource "openstack_networking_subnet_v2" "private_network_rally_sb" {
  name       = "private_network_rally_sb"
  network_id = openstack_networking_network_v2.private_network_rally.id
  cidr       = "10.0.123.0/24"
  ip_version = 4
  allocation_pool {
    start = "10.0.123.101"
    end = "10.0.123.199"
  }
}

resource "openstack_networking_network_v2" "ext_net_rally" {
  name           = "ext_net_rally"
  admin_state_up = true
  shared         = true
  external       = true
}

resource "openstack_networking_subnet_v2" "ext_net_rally_subnet" {
  name        = "ext_net_rally_subnet"
  network_id  = openstack_networking_network_v2.ext_net_rally.id
  cidr        = "192.168.0.0/24"
  gateway_ip  = "192.168.0.254"
  enable_dhcp = false
  ip_version  = 4

  dns_nameservers = [
    "192.168.1.9",
    "192.168.1.13"
  ]

  allocation_pool {
    start = "192.168.0.40"
    end   = "192.168.0.69"
  }
}
