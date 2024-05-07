resource "juju_machine" "cinder-1" {
  model = var.model-name
  placement = join(":",["lxd",juju_machine.all_machines["100"].machine_id])
  constraints = "spaces=oam"
}
resource "juju_machine" "cinder-2" {
  model = var.model-name
  placement = join(":",["lxd",juju_machine.all_machines["101"].machine_id])
  constraints = "spaces=oam"
}
resource "juju_machine" "cinder-3" {
  model = var.model-name
  placement = join(":",["lxd",juju_machine.all_machines["102"].machine_id])
  constraints = "spaces=oam"
}


resource "juju_application" "cinder" {
  name = "cinder"

  model = var.model-name

  charm {
    name     = "cinder"
    channel  = "ussuri/stable"
  }

  units = 3

  placement = "${join(",",sort([
    juju_machine.cinder-1.machine_id,
    juju_machine.cinder-2.machine_id,
    juju_machine.cinder-3.machine_id,
  ]))}"

  endpoint_bindings = [{
    space = "oam"
  },{
    endpoint = "public"
    space    = "oam"
  },{
    endpoint = "admin"
    space    = "oam"
  },{
    endpoint = "internal"
    space    = "oam"
  },{
    endpoint = "shared-db"
    space    = "oam"
  }]

  config = {
      worker-multiplier = var.worker-multiplier
      openstack-origin = var.openstack-origin
      region = var.openstack-region
      vip = "10.0.1.212"
      region = var.openstack-region
      use-internal-endpoints = "true"
      block-device = "None"
      glance-api-version = "2"
      enabled-services = "api,scheduler,volume"
  }
}

resource "juju_application" "cinder-ceph" {
  name = "cinder-ceph"

  model = var.model-name

  charm {
    name     = "cinder-ceph"
    channel  = "ussuri/stable"
  }

  units = 0

  config = {
    restrict-ceph-pools = "false"
  }
}


resource "juju_application" "cinder-mysql-router" {
  name = "cinder-mysql-router"

  model = var.model-name

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

resource "juju_application" "hacluster-cinder" {
  name = "hacluster-cinder"

  model = var.model-name

  charm {
    name     = "hacluster"
    channel  = "2.0.3/stable"
  }

  units = 0
}

resource "juju_integration" "cinder-ha" {


  model = var.model-name

  application {
    name = juju_application.cinder.name
    endpoint = "ha"
  }

  application {
    name = juju_application.hacluster-cinder.name
    endpoint = "ha"
  }
}

resource "juju_integration" "cinder-mysql" {

  model = var.model-name

  application {
    name = juju_application.cinder.name
    endpoint = "shared-db"
  }

  application {
    name = juju_application.cinder-mysql-router.name
    endpoint = "shared-db"
  }
}

resource "juju_integration" "cinder-db" {

  model = var.model-name

  application {
    name = juju_application.cinder-mysql-router.name
    endpoint = "db-router"
  }

  application {
    name = juju_application.mysql-innodb-cluster.name
    endpoint = "db-router"
  }
}

resource "juju_integration" "cinder-rmq" {

  model = var.model-name

  application {
    name = juju_application.cinder.name
    endpoint = "amqp"
  }

  application {
    name = juju_application.rabbitmq-server.name
    endpoint = "amqp"
  }
}

resource "juju_integration" "cinder-keystone" {

  model = var.model-name

  application {
    name = juju_application.cinder.name
    endpoint = "identity-service"
  }

  application {
    name = juju_application.keystone.name
    endpoint = "identity-service"
  }
}

resource "juju_integration" "cinder-ceph" {

  model = var.model-name

  application {
    name = juju_application.cinder.name
    endpoint = "ceph"
  }

  application {
    name = juju_application.ceph-mon.name
    endpoint = "client"
  }
}


resource "juju_integration" "cinder-ceph-mon" {

  model = var.model-name

  application {
    name = juju_application.cinder-ceph.name
    endpoint = "ceph"
  }

  application {
    name = juju_application.ceph-mon.name
    endpoint = "client"
  }
}

resource "juju_integration" "cinder-ceph-cinder" {

  model = var.model-name

  application {
    name = juju_application.cinder-ceph.name
    endpoint = "storage-backend"
  }

  application {
    name = juju_application.cinder.name
    endpoint = "storage-backend"
  }
}
