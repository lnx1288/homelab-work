variable "num_networks" {
  description = "The number of networks to create"
  default = 5
}

resource "openstack_networking_network_v2" "private_networks" {
  count          = var.num_networks
  name           = format("private_network_%s", count.index+1)
  admin_state_up = "true"
}

resource "openstack_networking_subnet_v2" "private_networks_sb" {
  count      = var.num_networks
  name       = format("private_network_%s_sb", count.index+1)
  network_id = element(openstack_networking_network_v2.private_networks.*.id, count.index)
  cidr       = format("10.0.%s.0/24", count.index+1)
  ip_version = 4
  allocation_pool {
    start = format("10.0.%s.101", count.index+1)
    end = format("10.0.%s.199", count.index+1)
  }
}
