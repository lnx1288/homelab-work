resource "openstack_networking_network_v2" "ext_net" {
  name           = "ext_net"
  admin_state_up = "true"
  shared         = true
  external       = true

  segments {

    physical_network = "physnet1"
    network_type = "flat"

  }
}

resource "openstack_networking_subnet_v2" "ext_net_subnet" {
  name       = "ext_net_subnet"
  network_id = openstack_networking_network_v2.ext_net.id
  cidr       = "192.168.1.0/24"
  gateway_ip = "192.168.1.254"
  enable_dhcp = false
  ip_version = 4
  dns_nameservers = ["192.168.1.9","192.168.1.13"]

  allocation_pool {
    start = "192.168.1.42"
    end = "192.168.1.79"
  }
}


resource "openstack_networking_router_v2" "provider-router" {
  name                = "provider-router"
  admin_state_up      = true
  external_network_id = openstack_networking_network_v2.ext_net.id
}

resource "openstack_networking_network_v2" "private" {
  name           = "private"
  admin_state_up = "true"
}

resource "openstack_networking_subnet_v2" "private_subnet" {
  name       = "private_subnet"
  network_id = openstack_networking_network_v2.private.id
  cidr       = "192.168.21.0/24"

  allocation_pool {
    start = "192.168.21.2"
    end = "192.168.21.254"
  }

}

resource "openstack_networking_router_interface_v2" "private_ext_route" {
  router_id = openstack_networking_router_v2.provider-router.id
  subnet_id = openstack_networking_subnet_v2.private_subnet.id
}
