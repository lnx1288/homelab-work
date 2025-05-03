resource "juju_application" "nrpe-ctrl" {
  name = "nrpe"

  model = data.juju_model.controller.name

  charm {
    name     = "nrpe"
    channel  = "latest/stable"
    base     = var.default-base
  }

  units = 0

  endpoint_bindings = [{
    space    = var.oam-space
  }]
}

resource "juju_integration" "nrpe-ctrl-integration" {

  model = data.juju_model.controller.name

  application {
    name     = juju_application.nrpe-ctrl.name
    endpoint = "general-info"
  }

  application {
    name     = juju_application.juju-server.name
    endpoint = "juju-info"
  }
}

resource "juju_integration" "nrpe-ctrl-nagios" {

  model = data.juju_model.controller.name

  application {
    name     = juju_application.nrpe-ctrl.name
    endpoint = "monitors"
  }

  application {
    offer_url = juju_offer.nagios.url
  }
}
