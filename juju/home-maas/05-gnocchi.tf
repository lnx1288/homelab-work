resource "juju_machine" "gnocchi-1" {
  model = juju_model.cpe-focal.name
  placement = join(":",["lxd",juju_machine.all_machines["103"].machine_id])
  constraints = "spaces=oam,ceph-access"
}
resource "juju_machine" "gnocchi-2" {
  model = juju_model.cpe-focal.name
  placement = join(":",["lxd",juju_machine.all_machines["104"].machine_id])
  constraints = "spaces=oam,ceph-access"
}
resource "juju_machine" "gnocchi-3" {
  model = juju_model.cpe-focal.name
  placement = join(":",["lxd",juju_machine.all_machines["105"].machine_id])
  constraints = "spaces=oam,ceph-access"
}


resource "juju_application" "gnocchi" {
  name = "gnocchi"

  model = juju_model.cpe-focal.name

  charm {
    name     = "gnocchi"
    channel  = "ussuri/stable"
  }

  units = 3

  placement = "${join(",",sort([
    juju_machine.gnocchi-1.machine_id,
    juju_machine.gnocchi-2.machine_id,
    juju_machine.gnocchi-3.machine_id,
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
  },{
    endpoint = "shared-db"
    space = "oam"
  },{
    endpoint = "storage-ceph"
    space = "ceph-access"
  },{
    endpoint = "coordinator-memcached"
    space = "oam"
  }]

  config = {
      worker-multiplier = var.worker-multiplier
      openstack-origin = var.openstack-origin
      vip = "10.0.1.220"
      region = var.openstack-region
      use-internal-endpoints = "true"
  }
}

resource "juju_application" "gnocchi-mysql-router" {
  name = "gnocchi-mysql-router"

  model = juju_model.cpe-focal.name

  charm {
    name = "mysql-router"
    channel = "8.0/stable"
  }

  units = 0

  endpoint_bindings = [{
    space = "oam"
  },{
    space = "oam"
    endpoint = "shared-db"
  },{
    space = "oam"
    endpoint = "db-router"
  }]

  config = {
    source = var.openstack-origin
  }
}

resource "juju_application" "hacluster-gnocchi" {
  name = "hacluster-gnocchi"

  model = juju_model.cpe-focal.name

  charm {
    name     = "hacluster"
    channel  = "2.0.3/stable"
  }

  units = 0
}

resource "juju_integration" "gnocchi-ha" {


  model = juju_model.cpe-focal.name

  application {
    name = juju_application.gnocchi.name
    endpoint = "ha"
  }

  application {
    name = juju_application.hacluster-gnocchi.name
    endpoint = "ha"
  }
}

resource "juju_integration" "gnocchi-mysql" {

  model = juju_model.cpe-focal.name

  application {
    name = juju_application.gnocchi.name
    endpoint = "shared-db"
  }

  application {
    name = juju_application.gnocchi-mysql-router.name
    endpoint = "shared-db"
  }
}

resource "juju_integration" "gnocchi-db" {

  model = juju_model.cpe-focal.name

  application {
    name = juju_application.gnocchi-mysql-router.name
    endpoint = "db-router"
  }

  application {
    name = juju_application.mysql-innodb-cluster.name
    endpoint = "db-router"
  }
}

resource "juju_integration" "gnocchi-rmq" {

  model = juju_model.cpe-focal.name

  application {
    name = juju_application.gnocchi.name
    endpoint = "amqp"
  }

  application {
    name = juju_application.rabbitmq-server.name
    endpoint = "amqp"
  }
}

resource "juju_integration" "gnocchi-keystone" {

  model = juju_model.cpe-focal.name

  application {
    name = juju_application.gnocchi.name
    endpoint = "identity-service"
  }

  application {
    name = juju_application.keystone.name
    endpoint = "identity-service"
  }
}

resource "juju_integration" "gnocchi-ceph" {

  model = juju_model.cpe-focal.name

  application {
    name = juju_application.gnocchi.name
    endpoint = "storage-ceph"
  }

  application {
    name = juju_application.ceph-mon.name
    endpoint = "client"
  }
}

resource "juju_integration" "gnocchi-memcache" {

  model = juju_model.cpe-focal.name

  application {
    name = juju_application.gnocchi.name
    endpoint = "coordinator-memcached"
  }

  application {
    name = juju_application.memcached.name
    endpoint = "cache"
  }
}

resource "juju_integration" "gnocchi-ceilometer" {

  model = juju_model.cpe-focal.name

  application {
    name = juju_application.gnocchi.name
    endpoint = "metric-service"
  }

  application {
    name = juju_application.ceilometer.name
    endpoint = "metric-service"
  }
}
