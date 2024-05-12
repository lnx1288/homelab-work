resource "juju_machine" "gnocchi" {
  count       = var.num_units
  model       = var.model-name
  placement   = join(":", ["lxd", juju_machine.all_machines[var.controller_ids[count.index+var.num_units]].machine_id])
  constraints = "spaces=oam,ceph-access"
}

resource "juju_application" "gnocchi" {
  name = "gnocchi"

  model = var.model-name

  charm {
    name     = "gnocchi"
    channel  = var.openstack-channel
  }

  units = var.num_units

  placement = "${join(",", sort([
    for index, _ in slice(var.controller_ids, var.num_units, length(var.controller_ids)) : 
        juju_machine.gnocchi[index].machine_id
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
  },{
    endpoint = "storage-ceph"
    space    = var.ceph-public-space
  },{
    endpoint = "coordinator-memcached"
    space    = var.internal-space
  }]

  config = {
      worker-multiplier = var.worker-multiplier
      openstack-origin  = var.openstack-origin
      region            = var.openstack-region
      vip               = var.vips["gnocchi"]
      use-internal-endpoints = "true"
  }
}

resource "juju_application" "gnocchi-mysql-router" {
  name = "gnocchi-mysql-router"

  model = var.model-name

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

resource "juju_application" "hacluster-gnocchi" {
  name = "hacluster-gnocchi"

  model = var.model-name

  charm {
    name     = "hacluster"
    channel  = var.hacluster-channel
  }

  units = 0
}

resource "juju_integration" "gnocchi-ha" {


  model = var.model-name

  application {
    name     = juju_application.gnocchi.name
    endpoint = "ha"
  }

  application {
    name     = juju_application.hacluster-gnocchi.name
    endpoint = "ha"
  }
}

resource "juju_integration" "gnocchi-mysql" {

  model = var.model-name

  application {
    name     = juju_application.gnocchi.name
    endpoint = "shared-db"
  }

  application {
    name     = juju_application.gnocchi-mysql-router.name
    endpoint = "shared-db"
  }
}

resource "juju_integration" "gnocchi-db" {

  model = var.model-name

  application {
    name     = juju_application.gnocchi-mysql-router.name
    endpoint = "db-router"
  }

  application {
    name     = juju_application.mysql-innodb-cluster.name
    endpoint = "db-router"
  }
}

resource "juju_integration" "gnocchi-rmq" {

  model = var.model-name

  application {
    name     = juju_application.gnocchi.name
    endpoint = "amqp"
  }

  application {
    name     = juju_application.rabbitmq-server.name
    endpoint = "amqp"
  }
}

resource "juju_integration" "gnocchi-keystone" {

  model = var.model-name

  application {
    name     = juju_application.gnocchi.name
    endpoint = "identity-service"
  }

  application {
    name     = juju_application.keystone.name
    endpoint = "identity-service"
  }
}

resource "juju_integration" "gnocchi-ceph" {

  model = var.model-name

  application {
    name     = juju_application.gnocchi.name
    endpoint = "storage-ceph"
  }

  application {
    name     = juju_application.ceph-mon.name
    endpoint = "client"
  }
}

resource "juju_integration" "gnocchi-memcache" {

  model = var.model-name

  application {
    name     = juju_application.gnocchi.name
    endpoint = "coordinator-memcached"
  }

  application {
    name     = juju_application.memcached.name
    endpoint = "cache"
  }
}

resource "juju_integration" "gnocchi-ceilometer" {

  model = var.model-name

  application {
    name     = juju_application.gnocchi.name
    endpoint = "metric-service"
  }

  application {
    name     = juju_application.ceilometer.name
    endpoint = "metric-service"
  }
}
