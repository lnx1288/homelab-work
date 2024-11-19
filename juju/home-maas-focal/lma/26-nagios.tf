resource "juju_machine" "nagios" {
  model       = juju_model.lma.name
  placement   = join(":", ["lxd", juju_machine.lma_machines["202"].machine_id])
  constraints = "spaces=oam"
  base        = "ubuntu@18.04"
}

resource "juju_application" "nagios" {
  name = "nagios"

  model = juju_model.lma.name

  charm {
    name     = "nagios"
    channel  = "latest/stable"
    base     = "ubuntu@18.04"
  }

  units = 1

  placement = juju_machine.nagios.machine_id

   endpoint_bindings = [{
     space    = var.oam-space
   }]

  config = {
      enable_livestatus = "true"
      check_timeout = 50
  }
}

resource "juju_offer" "nagios" {
  model            = juju_model.lma.name
  application_name = juju_application.nagios.name
  endpoint         = "monitors"
}
