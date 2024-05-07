resource "juju_machine" "ceilometer-1" {
  model = juju_model.cpe-focal.name
  placement = join(":",["lxd",juju_machine.all_machines["103"].machine_id])
  constraints = "spaces=oam"
}
resource "juju_machine" "ceilometer-2" {
  model = juju_model.cpe-focal.name
  placement = join(":",["lxd",juju_machine.all_machines["104"].machine_id])
  constraints = "spaces=oam"
}
resource "juju_machine" "ceilometer-3" {
  model = juju_model.cpe-focal.name
  placement = join(":",["lxd",juju_machine.all_machines["105"].machine_id])
  constraints = "spaces=oam"
}


resource "juju_application" "ceilometer" {
  name = "ceilometer"

  model = juju_model.cpe-focal.name

  charm {
    name     = "ceilometer"
    channel  = "ussuri/stable"
  }

  units = 3

  placement = "${join(",",sort([
    juju_machine.ceilometer-1.machine_id,
    juju_machine.ceilometer-2.machine_id,
    juju_machine.ceilometer-3.machine_id,
  ]))}"

  endpoint_bindings = [{
    space = "oam"
  },{
    endpoint = "public"
    space = "oam"
  },{
    endpoint = "admin"
    space = "oam"
  },{
    endpoint = "internal"
    space = "oam"
  }]

  config = {
      openstack-origin = var.openstack-origin
      region = var.openstack-region
      use-internal-endpoints = "true"
  }
}

resource "juju_integration" "ceilometer-rmq" {

  model = juju_model.cpe-focal.name

  application {
    name = juju_application.ceilometer.name
    endpoint = "amqp"
  }

  application {
    name = juju_application.rabbitmq-server.name
    endpoint = "amqp"
  }
}

resource "juju_integration" "ceilometer-keystone" {

  model = juju_model.cpe-focal.name

  application {
    name = juju_application.ceilometer.name
    endpoint = "identity-credentials"
  }

  application {
    name = juju_application.keystone.name
    endpoint = "identity-credentials"
  }
}

resource "juju_integration" "ceilometer-ceil-agent" {

  model = juju_model.cpe-focal.name

  application {
    name = juju_application.ceilometer.name
    endpoint = "ceilometer-service"
  }

  application {
    name = juju_application.ceilometer-agent.name
    endpoint = "ceilometer-service"
  }
}

