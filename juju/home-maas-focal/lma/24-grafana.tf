resource "juju_machine" "grafana" {
  model       = juju_model.lma.name
  placement   = join(":", ["lxd", juju_machine.lma_machines["201"].machine_id])
  constraints = "spaces=oam"
}

resource "juju_application" "grafana" {
  name = "grafana"

  model = juju_model.lma.name

  charm {
    name     = "grafana"
    channel  = "latest/stable"
    base     = "ubuntu@20.04"
  }

  units = 1

  placement = juju_machine.grafana.machine_id

   endpoint_bindings = [{
     space    = var.oam-space
   }]

  config = {
      port           = "3000"
      install_method = "snap"
  }
}

resource "juju_offer" "grafana" {
  model            = juju_model.lma.name
  application_name = juju_application.grafana.name
  endpoint         = "dashboards"
}
