resource "openstack_networking_network_v2" "private_network_1" {
  name           = "private_network_1"
  admin_state_up = "true"
}

resource "openstack_networking_subnet_v2" "private_network_1_sb" {
  name       = "private_network_1_sb"
  network_id = openstack_networking_network_v2.private_network_1.id
  cidr       = "10.0.1.0/24"
  ip_version = 4
  allocation_pool {
    start = "10.0.1.101"
    end = "10.0.1.199"
  }
}

resource "openstack_networking_network_v2" "private_network_2" {
  name           = "private_network_2"
  admin_state_up = "true"
}

resource "openstack_networking_subnet_v2" "private_network_2_sb" {
  name       = "private_network_1_sb"
  network_id = openstack_networking_network_v2.private_network_2.id
  cidr       = "10.0.2.0/24"
  ip_version = 4
  allocation_pool {
    start = "10.0.2.101"
    end = "10.0.2.199"
  }
}

resource "openstack_networking_network_v2" "private_network_3" {
  name           = "private_network_3"
  admin_state_up = "true"
}

resource "openstack_networking_subnet_v2" "private_network_3_sb" {
  name       = "private_network_1_sb"
  network_id = openstack_networking_network_v2.private_network_3.id
  cidr       = "10.0.3.0/24"
  ip_version = 4
  allocation_pool {
    start = "10.0.3.101"
    end = "10.0.3.199"
  }
}

resource "openstack_networking_network_v2" "private_network_4" {
  name           = "private_network_4"
  admin_state_up = "true"
}

resource "openstack_networking_subnet_v2" "private_network_4_sb" {
  name       = "private_network_4_sb"
  network_id = openstack_networking_network_v2.private_network_4.id
  cidr       = "10.0.4.0/24"
  ip_version = 4
  allocation_pool {
    start = "10.0.4.101"
    end = "10.0.4.199"
  }
}

resource "openstack_networking_network_v2" "private_network_5" {
  name           = "private_network_5"
  admin_state_up = "true"
}

resource "openstack_networking_subnet_v2" "private_network_5_sb" {
  name       = "private_network_5_sb"
  network_id = openstack_networking_network_v2.private_network_5.id
  cidr       = "10.0.5.0/24"
  ip_version = 4
  allocation_pool {
    start = "10.0.5.101"
    end = "10.0.5.199"
  }
}
