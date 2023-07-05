terraform {
  required_version = ">= 0.14.0"
  required_providers {
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = "1.49.0"
    }
  }
}

provider "openstack" {
  cloud = "arif-home"
}

resource "openstack_compute_keypair_v2" "arif-key" {
  name       = "arif-key"
  public_key = file("/home/arif/.ssh/aarsa4096canonical.pub")
}

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

resource "openstack_images_image_v2" "cirros" {
  name             = "cirros"
  local_file_path  = "/home/arif/images/cirros-0.5.1-x86_64-disk.img"
  container_format = "bare"
  disk_format      = "qcow2"
  visibility       = "public"
}
