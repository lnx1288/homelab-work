resource "juju_machine" "heat-1" {
  model       = var.model-name
  placement   = join(":",["lxd",juju_machine.all_machines["100"].machine_id])
  constraints = "spaces=oam"
}
resource "juju_machine" "heat-2" {
  model       = var.model-name
  placement   = join(":",["lxd",juju_machine.all_machines["101"].machine_id])
  constraints = "spaces=oam"
}
resource "juju_machine" "heat-3" {
  model       = var.model-name
  placement   = join(":",["lxd",juju_machine.all_machines["102"].machine_id])
  constraints = "spaces=oam"
}

resource "juju_application" "heat" {
  name = "heat"

  model = var.model-name

  charm {
    name     = "heat"
    channel  = var.openstack-channel
  }

  units = 3

  placement = "${join(",",sort([
    juju_machine.heat-1.machine_id,
    juju_machine.heat-2.machine_id,
    juju_machine.heat-3.machine_id,
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
  },{
    endpoint = "shared-db"
    space    = var.internal-space
  }]

  config = {
      worker-multiplier = var.worker-multiplier
      openstack-origin  = var.openstack-origin
      region            = var.openstack-region
      vip               = var.vips["heat"]
      use-internal-endpoints = "true"
      config-flags      = "max_nested_stack_depth=20"
  }
}

resource "juju_application" "heat-mysql-router" {
  name = "heat-mysql-router"

  model = var.model-name

  charm {
    name    = "mysql-router"
    channel = "8.0/stable"
  }

  units = 0

  endpoint_bindings = [{
    space    = var.oam-space
  },{
    space    = var.internal-space
    endpoint = "shared-db"
  },{
    space    = var.internal-space
    endpoint = "db-router"
  }]

  config = {
    source = var.openstack-origin
  }
}

resource "juju_application" "hacluster-heat" {
  name = "hacluster-heat"

  model = var.model-name

  charm {
    name     = "hacluster"
    channel  = "2.0.3/stable"
  }

  units = 0
}

resource "juju_integration" "heat-ha" {

  model = var.model-name

  application {
    name     = juju_application.heat.name
    endpoint = "ha"
  }

  application {
    name     = juju_application.hacluster-heat.name
    endpoint = "ha"
  }
}

resource "juju_integration" "heat-mysql" {

  model = var.model-name

  application {
    name     = juju_application.heat.name
    endpoint = "shared-db"
  }

  application {
    name     = juju_application.heat-mysql-router.name
    endpoint = "shared-db"
  }
}

resource "juju_integration" "heat-db" {

  model = var.model-name

  application {
    name     = juju_application.heat-mysql-router.name
    endpoint = "db-router"
  }

  application {
    name     = juju_application.mysql-innodb-cluster.name
    endpoint = "db-router"
  }
}

resource "juju_integration" "heat-rmq" {

  model = var.model-name

  application {
    name     = juju_application.heat.name
    endpoint = "amqp"
  }

  application {
    name     = juju_application.rabbitmq-server.name
    endpoint = "amqp"
  }
}

resource "juju_integration" "heat-keystone" {

  model = var.model-name

  application {
    name     = juju_application.heat.name
    endpoint = "identity-service"
  }

  application {
    name     = juju_application.keystone.name
    endpoint = "identity-service"
  }
}
