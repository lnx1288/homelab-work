resource "juju_machine" "cinder" {
  count       = var.num_units
  model       = var.model-name
  placement   = join(":", ["lxd", juju_machine.all_machines[var.controller_ids[count.index]].machine_id])
  constraints = "spaces=oam"
}

resource "juju_application" "cinder" {
  name = "cinder"

  model = var.model-name

  charm {
    name     = "cinder"
    channel  = var.openstack-channel
    base     = var.default-base
  }

  machines = [
    for res in juju_machine.cinder :
        res.machine_id
  ]

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
      worker-multiplier  = var.worker-multiplier
      openstack-origin   = var.openstack-origin
      region             = var.openstack-region
      vip                = var.vips["cinder"]
      use-internal-endpoints = "true"
      block-device       = "None"
      glance-api-version = "2"
      enabled-services   = "api,scheduler,volume"
  }
}

resource "juju_application" "cinder-ceph" {
  name = "cinder-ceph"

  model = var.model-name

  charm {
    name    = "cinder-ceph"
    channel = var.openstack-channel
  }

  config = {
    restrict-ceph-pools = "false"
  }
}


resource "juju_application" "cinder-mysql-router" {
  name = "cinder-mysql-router"

  model = var.model-name

  charm {
    name    = "mysql-router"
    channel = var.mysql-router-channel
  }

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

resource "juju_application" "hacluster-cinder" {
  name = "hacluster-cinder"

  model = var.model-name

  charm {
    name     = "hacluster"
    channel  = var.hacluster-channel
  }
}

resource "juju_integration" "cinder-ha" {

  model = var.model-name

  application {
    name     = juju_application.cinder.name
    endpoint = "ha"
  }

  application {
    name     = juju_application.hacluster-cinder.name
    endpoint = "ha"
  }
}

resource "juju_integration" "cinder-mysql" {

  model = var.model-name

  application {
    name     = juju_application.cinder.name
    endpoint = "shared-db"
  }

  application {
    name     = juju_application.cinder-mysql-router.name
    endpoint = "shared-db"
  }
}

resource "juju_integration" "cinder-db" {

  model = var.model-name

  application {
    name     = juju_application.cinder-mysql-router.name
    endpoint = "db-router"
  }

  application {
    name     = juju_application.mysql-innodb-cluster.name
    endpoint = "db-router"
  }
}

resource "juju_integration" "cinder-rmq" {

  model = var.model-name

  application {
    name     = juju_application.cinder.name
    endpoint = "amqp"
  }

  application {
    name     = juju_application.rabbitmq-server.name
    endpoint = "amqp"
  }
}

resource "juju_integration" "cinder-keystone" {

  model = var.model-name

  application {
    name     = juju_application.cinder.name
    endpoint = "identity-service"
  }

  application {
    name     = juju_application.keystone.name
    endpoint = "identity-service"
  }
}

resource "juju_integration" "cinder-ceph" {

  model = var.model-name

  application {
    name     = juju_application.cinder.name
    endpoint = "ceph"
  }

  application {
    name     = juju_application.ceph-mon.name
    endpoint = "client"
  }
}

resource "juju_integration" "cinder-ceph-mon" {

  model = var.model-name

  application {
    name     = juju_application.cinder-ceph.name
    endpoint = "ceph"
  }

  application {
    name     = juju_application.ceph-mon.name
    endpoint = "client"
  }
}

resource "juju_integration" "cinder-ceph-cinder" {

  model = var.model-name

  application {
    name     = juju_application.cinder-ceph.name
    endpoint = "storage-backend"
  }

  application {
    name     = juju_application.cinder.name
    endpoint = "storage-backend"
  }
}
