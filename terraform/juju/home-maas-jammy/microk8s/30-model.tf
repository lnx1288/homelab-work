resource "juju_model" "microk8s" {
  name = var.microk8s-model-name

  cloud {
    name = var.cloud
  }

  config = {
    apt-mirror = "http://archive.ubuntu.com/ubuntu"
    lxd-snap-channel = var.lxd-snap-channel

    container-image-metadata-url = "http://lxd/"
    container-image-stream = "released"

    agent-metadata-url = "http://juju/tools/"
    agent-stream = "released"
  }
}
