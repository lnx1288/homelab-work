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
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDHuq15h5hmPijTuICx4tO9DFYro++XDigw9Jh1osYrYJxTU4jwhRVvJGqrLOfTG8tl1VMAs4xQ6RGDVsWmbOpSfjtQ93D2Ovz6AnNQx+cEJwOA7DzE3MhDWHijKu5ev5oq/tWkW9wEV0NTzsPyOsqUd8bQIRn86bb7X9/bPKzXJ4r4+vdtF3bRhqEi7gdFGedUiQ/OEGVBfKxxt++jejs6vwcU7ljiZnvECXA6myo5e+nJLxNND2wF1zhjncYwJLX6EdU07K3ZRihcDKmqFb4KE/5W2Ot7RiDcnkrANBqjl6nU8N2UiY5pTHMaCBWSDfS+kWIXiX7arqHFB9uYBCd5r8XoX6ajSn2rFlsnvHwOKQK4uZ1GcDjwImXMrFzUJ6rnmFB3kl+VVpjzyMQiviA5AOZcC4X3PonjQHYweTs6wF89YXO0pD2vzBnU/HTmsrgE22yFFq7s63oq+wlTHPlXfAxLpF3cMPaG1hrEaAwvE1BiKQ6bUT1cxg7qtK73i59YiiTNQI2Ka3mp8oxASwk7Cgr/X+NWgpbXsBQODKM6750JAt1YRlsR71jxmehCrwj16ojWlxNghF9T5hePlgWEMueJ8pPkSGKv6s07Hmf/Hgs6oBSNcr7LiTvirAyVAGV3gQCAteP9YmN7BmNGFGz4CGpBUL1/nJlADteS2IOuNQ=="
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

  properties = {
    key = "value"
  }
}
