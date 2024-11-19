resource "juju_machine" "heat" {
  count       = var.num_units
  model       = juju_model.openstack.name
  placement   = join(":", ["lxd", juju_machine.all_machines[var.controller_ids[count.index]].machine_id])
  constraints = "spaces=oam"
}

resource "juju_application" "heat" {
  name = "heat"

  model = juju_model.openstack.name

  charm {
    name     = "heat"
    channel  = var.openstack-channel
  }

  units = var.num_units

  placement = "${join(",", sort([
    for res in juju_machine.heat :
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

  model = juju_model.openstack.name

  charm {
    name    = "mysql-router"
    channel = var.mysql-router-channel
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

  model = juju_model.openstack.name

  charm {
    name     = "hacluster"
    channel  = var.hacluster-channel
  }

  units = 0
}

resource "juju_integration" "heat-ha" {

  model = juju_model.openstack.name

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

  model = juju_model.openstack.name

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

  model = juju_model.openstack.name

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

  model = juju_model.openstack.name

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

  model = juju_model.openstack.name

  application {
    name     = juju_application.heat.name
    endpoint = "identity-service"
  }

  application {
    name     = juju_application.keystone.name
    endpoint = "identity-service"
  }
}
