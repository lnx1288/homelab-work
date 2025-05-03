resource "juju_application" "ntp" {
  name = "ntp"

  model = juju_model.microk8s.name

  charm {
    name     = "ntp"
    channel  = "latest/stable"
    base     = "ubuntu@22.04"
  }

  units = 0
}

resource "juju_integration" "ntp-k8s" {

  model = juju_model.microk8s.name

  application {
    name     = juju_application.ntp.name
    endpoint = "juju-info"
  }

  application {
    name     = juju_application.microk8s.name
    endpoint = "juju-info"
  }
}

