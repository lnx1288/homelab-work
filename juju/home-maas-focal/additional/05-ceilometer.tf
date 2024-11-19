resource "juju_machine" "ceilometer" {
  count       = var.num_units
  model       = juju_model.openstack.name
  placement   = join(":", ["lxd", juju_machine.all_machines[var.controller_ids[count.index+var.num_units]].machine_id])
  constraints = "spaces=oam"
}

resource "juju_application" "ceilometer" {
  name = "ceilometer"

  model = juju_model.openstack.name

  charm {
    name     = "ceilometer"
    channel  = var.openstack-channel
  }

  units = 3

  placement = "${join(",", sort([
    for res in juju_machine.ceilometer :
        res.machine_id
  ]))}"

  endpoint_bindings = [{
    space    = var.oam-space
  },{
    endpoint = "public"
    space    = var.public-space
  },{
    endpoint = "admin"
    space    = var.admin-space
  },{
    endpoint = "internal"
    space    = var.internal-space
  }]

  config = {
      openstack-origin = var.openstack-origin
      region           = var.openstack-region
      use-internal-endpoints = "true"
  }
}

resource "juju_integration" "ceilometer-rmq" {

  model = juju_model.openstack.name

  application {
    name     = juju_application.ceilometer.name
    endpoint = "amqp"
  }

  application {
    name     = juju_application.rabbitmq-server.name
    endpoint = "amqp"
  }
}

resource "juju_integration" "ceilometer-keystone" {

  model = juju_model.openstack.name

  application {
    name     = juju_application.ceilometer.name
    endpoint = "identity-credentials"
  }

  application {
    name     = juju_application.keystone.name
    endpoint = "identity-credentials"
  }
}

resource "juju_integration" "ceilometer-ceil-agent" {

  model = juju_model.openstack.name

  application {
    name     = juju_application.ceilometer.name
    endpoint = "ceilometer-service"
  }

  application {
    name     = juju_application.ceilometer-agent.name
    endpoint = "ceilometer-service"
  }
}
