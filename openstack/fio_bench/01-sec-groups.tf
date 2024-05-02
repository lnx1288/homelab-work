resource "openstack_networking_secgroup_v2" "server_secgroup_test" {
    name        = "server_secgroup_test"
    description = "Allow ssh and ping"
}

resource "openstack_networking_secgroup_rule_v2" "server_secgroup_test_ping" {
    direction        = "ingress"
    ethertype        = "IPv4"
    protocol         = "icmp"
    port_range_min   = -1
    port_range_max   = -1
    remote_ip_prefix = "0.0.0.0/0"
    security_group_id = openstack_networking_secgroup_v2.server_secgroup_test.id
}

resource "openstack_networking_secgroup_rule_v2" "server_secgroup_test_ssh" {
    direction        = "ingress"
    ethertype        = "IPv4"
    protocol          = "tcp"
    port_range_min    = 22
    port_range_max    = 22
    remote_ip_prefix  = "0.0.0.0/0"
    security_group_id = openstack_networking_secgroup_v2.server_secgroup_test.id
}
