resource "juju_machine" "cinder-backup" {
  count       = var.num_units
  model       = var.model-name
  placement   = join(":", ["lxd", juju_machine.all_machines[var.controller_ids[count.index+var.num_units]].machine_id])
  constraints = "spaces=oam"
}

resource "juju_application" "cinder-backup" {
  name = "cinder-backup"

  model = var.model-name

  charm {
    name     = "cinder"
    channel  = var.openstack-channel
    base     = var.default-base
  }

  units = var.num_units

  placement = "${join(",", sort([
    for res in juju_machine.cinder-backup :
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
      worker-multiplier  = var.worker-multiplier
      openstack-origin   = var.openstack-origin
      region             = var.openstack-region
      use-internal-endpoints = "true"
      block-device       = "None"
      glance-api-version = "2"
      enabled-services   = "backup"
  }
}

resource "juju_application" "cinder-backup-mysql-router" {
  name = "cinder-backup-mysql-router"

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

resource "juju_integration" "cinder-backup-mysql" {

  model = var.model-name

  application {
    name     = juju_application.cinder-backup.name
    endpoint = "shared-db"
  }

  application {
    name     = juju_application.cinder-backup-mysql-router.name
    endpoint = "shared-db"
  }
}

resource "juju_integration" "cinder-backup-db" {

  model = var.model-name

  application {
    name     = juju_application.cinder-backup-mysql-router.name
    endpoint = "db-router"
  }

  application {
    name     = juju_application.mysql-innodb-cluster.name
    endpoint = "db-router"
  }
}

resource "juju_integration" "cinder-backup-rmq" {

  model = var.model-name

  application {
    name     = juju_application.cinder-backup.name
    endpoint = "amqp"
  }

  application {
    name     = juju_application.rabbitmq-server.name
    endpoint = "amqp"
  }
}

resource "juju_integration" "cinder-backup-keystone" {

  model = var.model-name

  application {
    name     = juju_application.cinder-backup.name
    endpoint = "identity-service"
  }

  application {
    name     = juju_application.keystone.name
    endpoint = "identity-service"
  }
}

resource "juju_integration" "cinder-backup-ceph" {

  model = var.model-name

  application {
    name     = juju_application.cinder-backup.name
    endpoint = "ceph"
  }

  application {
    name     = juju_application.ceph-mon.name
    endpoint = "client"
  }
}

resource "juju_integration" "cinder-ceph-cinder-backup" {

  model = var.model-name

  application {
    name     = juju_application.cinder-ceph.name
    endpoint = "storage-backend"
  }

  application {
    name     = juju_application.cinder-backup.name
    endpoint = "storage-backend"
  }
}
