resource "juju_machine" "glance-1" {
  model = juju_model.cpe-focal.name
  placement = join(":",["lxd",juju_machine.all_machines["100"].machine_id])
  constraints = "spaces=oam"
}
resource "juju_machine" "glance-2" {
  model = juju_model.cpe-focal.name
  placement = join(":",["lxd",juju_machine.all_machines["101"].machine_id])
  constraints = "spaces=oam"
}
resource "juju_machine" "glance-3" {
  model = juju_model.cpe-focal.name
  placement = join(":",["lxd",juju_machine.all_machines["102"].machine_id])
  constraints = "spaces=oam"
}


resource "juju_application" "glance" {
  name = "glance"

  model = juju_model.cpe-focal.name

  charm {
    name     = "glance"
    channel  = "ussuri/stable"
  }

  units = 3

  placement = "${join(",",sort([
    juju_machine.glance-1.machine_id,
    juju_machine.glance-2.machine_id,
    juju_machine.glance-3.machine_id,
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
  }]

  config = {
      worker-multiplier = var.worker-multiplier
      openstack-origin = var.openstack-origin
      vip = "10.0.1.214"
      region = var.openstack-region
      use-internal-endpoints = "true"
      restrict-ceph-pools = "false"
      region = var.openstack-region
  }
}

resource "juju_application" "glance-mysql-router" {
  name = "glance-mysql-router"

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

resource "juju_application" "hacluster-glance" {
  name = "hacluster-glance"

  model = juju_model.cpe-focal.name

  charm {
    name     = "hacluster"
    channel  = "2.0.3/stable"
  }

  units = 0
}

resource "juju_integration" "glance-ha" {


  model = juju_model.cpe-focal.name

  application {
    name = juju_application.glance.name
    endpoint = "ha"
  }

  application {
    name = juju_application.hacluster-glance.name
    endpoint = "ha"
  }
}

resource "juju_integration" "glance-mysql" {

  model = juju_model.cpe-focal.name

  application {
    name = juju_application.glance.name
    endpoint = "shared-db"
  }

  application {
    name = juju_application.glance-mysql-router.name
    endpoint = "shared-db"
  }
}

resource "juju_integration" "glance-db" {

  model = juju_model.cpe-focal.name

  application {
    name = juju_application.glance-mysql-router.name
    endpoint = "db-router"
  }

  application {
    name = juju_application.mysql-innodb-cluster.name
    endpoint = "db-router"
  }
}

resource "juju_integration" "glance-rmq" {

  model = juju_model.cpe-focal.name

  application {
    name = juju_application.glance.name
    endpoint = "amqp"
  }

  application {
    name = juju_application.rabbitmq-server.name
    endpoint = "amqp"
  }
}

resource "juju_integration" "glance-keystone" {

  model = juju_model.cpe-focal.name

  application {
    name = juju_application.glance.name
    endpoint = "identity-service"
  }

  application {
    name = juju_application.keystone.name
    endpoint = "identity-service"
  }
}

resource "juju_integration" "glance-ceph" {

  model = juju_model.cpe-focal.name

  application {
    name = juju_application.glance.name
    endpoint = "ceph"
  }

  application {
    name = juju_application.ceph-mon.name
    endpoint = "client"
  }
}

resource "juju_integration" "glance-cinder" {

  model = juju_model.cpe-focal.name

  application {
    name = juju_application.glance.name
    endpoint = "image-service"
  }

  application {
    name = juju_application.cinder.name
    endpoint = "image-service"
  }
}
