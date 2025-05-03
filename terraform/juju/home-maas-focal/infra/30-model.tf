resource "juju_model" "infra" {
  name = var.infra-model-name

  cloud {
    name = var.cloud
  }

  config = {
    apt-mirror = "http://${var.apt_mirror}/archive.ubuntu.com/ubuntu"
    lxd-snap-channel = var.lxd-snap-channel

    container-image-metadata-url = "http://${var.apt_mirror}/lxd/"
    container-image-stream = "released"

    agent-metadata-url = "http://${var.apt_mirror}/juju/tools/"
    agent-stream = "released"
  }
}
