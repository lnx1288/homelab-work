resource "openstack_compute_secgroup_v2" "allow_ssh" {
  name        = "allow_ssh"
  description = "Allow ssh"

  rule {
    from_port   = 22
    to_port     = 22
    ip_protocol = "tcp"
    cidr        = "0.0.0.0/0"
  }
}

resource "openstack_compute_secgroup_v2" "allow_ping" {
  name        = "allow_ping"
  description = "Allow ping"

  rule {
    from_port   = -1
    to_port     = -1
    ip_protocol = "icmp"
    cidr        = "0.0.0.0/0"
  }
}
