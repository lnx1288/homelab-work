resource "juju_application" "nrpe" {
  name = "nrpe"

  model = juju_model.infra.name

  charm {
    name     = "nrpe"
    channel  = "latest/stable"
    base     = "ubuntu@22.04"
  }

  units = 0

  endpoint_bindings = [{
    space    = var.oam-space
  }]

  config = {
      nagios_hostname_type = "host"
      nagios_host_context = var.nagios-context
      xfs_errors = "30"
  }
}

resource "juju_integration" "nrpe-integration" {

  model = juju_model.infra.name

  application {
    name     = juju_application.nrpe.name
    endpoint = "general-info"
  }

  application {
    name     = juju_application.infra-server.name
    endpoint = "juju-info"
  }
}

resource "juju_integration" "nrpe-nagios" {

  model = juju_model.infra.name

  application {
    name     = juju_application.nrpe.name
    endpoint = "monitors"
  }

  application {
    offer_url = juju_offer.nagios.url
  }
}
