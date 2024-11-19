resource "juju_machine" "prometheus" {
  model       = juju_model.lma.name
  placement   = join(":", ["lxd", juju_machine.lma_machines["201"].machine_id])
  constraints = "spaces=oam"
}

resource "juju_application" "prometheus" {
  name = "prometheus"

  model = juju_model.lma.name

  charm {
    name     = "prometheus2"
    channel  = "latest/stable"
    base     = "ubuntu@20.04"
  }

  units = 1

  placement = juju_machine.prometheus.machine_id

   endpoint_bindings = [{
     space    = var.oam-space
   }]
}

resource "juju_integration" "prometheus-grafana" {
  model = juju_model.lma.name

  application {
    name     = juju_application.prometheus.name
    endpoint = "grafana-source"
  }

  application {
    name     = juju_application.grafana.name
    endpoint = "grafana-source"
  }
}

resource "juju_integration" "ceph-mon-prometheus" {

  model = juju_model.openstack.name

  application {
    name     = juju_application.ceph-mon.name
    endpoint = "prometheus"
  }

  application {
    offer_url = juju_offer.prometheus.url
  }
}

resource "juju_offer" "prometheus" {
  model            = juju_model.lma.name
  application_name = juju_application.prometheus.name
  endpoint         = "target"
}

