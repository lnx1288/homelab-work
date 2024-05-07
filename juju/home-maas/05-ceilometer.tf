resource "juju_machine" "ceilometer-1" {
  model       = var.model-name
  placement   = join(":",["lxd",juju_machine.all_machines["103"].machine_id])
  constraints = "spaces=oam"
}
resource "juju_machine" "ceilometer-2" {
  model       = var.model-name
  placement   = join(":",["lxd",juju_machine.all_machines["104"].machine_id])
  constraints = "spaces=oam"
}
resource "juju_machine" "ceilometer-3" {
  model       = var.model-name
  placement   = join(":",["lxd",juju_machine.all_machines["105"].machine_id])
  constraints = "spaces=oam"
}


resource "juju_application" "ceilometer" {
  name = "ceilometer"

  model = var.model-name

  charm {
    name     = "ceilometer"
    channel  = var.openstack-channel
  }

  units = 3

  placement = "${join(",",sort([
    juju_machine.ceilometer-1.machine_id,
    juju_machine.ceilometer-2.machine_id,
    juju_machine.ceilometer-3.machine_id,
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

  model = var.model-name

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

  model = var.model-name

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

  model = var.model-name

  application {
    name     = juju_application.ceilometer.name
    endpoint = "ceilometer-service"
  }

  application {
    name     = juju_application.ceilometer-agent.name
    endpoint = "ceilometer-service"
  }
}
