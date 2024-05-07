resource "juju_model" "openstack" {
  name = var.model-name

  cloud {
    name = "home-maas"
  }

  config = {
    cloudinit-userdata = file("user-data.yaml")

    apt-mirror = "http://192.168.1.12/archive.ubuntu.com/ubuntu"
    lxd-snap-channel = "5.0/stable"

    container-image-metadata-url = "http://192.168.1.12/lxd/"
    container-image-stream = "released"

    agent-metadata-url = "http://192.168.1.12/juju/tools/"
    agent-stream = "released"
  }
}
