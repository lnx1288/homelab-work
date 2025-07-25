resource "juju_machine" "glance" {
  count       = var.num_units
  model       = var.model-name
  placement   = join(":", ["lxd", juju_machine.all_machines[var.controller_ids[count.index]].machine_id])
  constraints = "cores=2 mem=2048M spaces=oam virt-type=virtual-machine"
}

resource "juju_application" "glance" {
  name = "glance"

  model = var.model-name

  charm {
    name     = "glance"
    channel  = var.openstack-channel
    base     = var.default-base
  }

  machines = [
    for res in juju_machine.glance :
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
      worker-multiplier = var.worker-multiplier
      openstack-origin  = var.openstack-origin
      region            = var.openstack-region
      vip               = var.vips["glance"]
      use-internal-endpoints = "true"
      restrict-ceph-pools    = "false"
  }
}

resource "juju_application" "glance-mysql-router" {
  name = "glance-mysql-router"

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

resource "juju_application" "hacluster-glance" {
  name = "hacluster-glance"

  model = var.model-name

  charm {
    name     = "hacluster"
    channel  = var.hacluster-channel
  }
}

resource "juju_integration" "glance-ha" {


  model = var.model-name

  application {
    name     = juju_application.glance.name
    endpoint = "ha"
  }

  application {
    name     = juju_application.hacluster-glance.name
    endpoint = "ha"
  }
}

resource "juju_integration" "glance-mysql" {

  model = var.model-name

  application {
    name     = juju_application.glance.name
    endpoint = "shared-db"
  }

  application {
    name     = juju_application.glance-mysql-router.name
    endpoint = "shared-db"
  }
}

resource "juju_integration" "glance-db" {

  model = var.model-name

  application {
    name     = juju_application.glance-mysql-router.name
    endpoint = "db-router"
  }

  application {
    name     = juju_application.mysql-innodb-cluster.name
    endpoint = "db-router"
  }
}

resource "juju_integration" "glance-rmq" {

  model = var.model-name

  application {
    name     = juju_application.glance.name
    endpoint = "amqp"
  }

  application {
    name     = juju_application.rabbitmq-server.name
    endpoint = "amqp"
  }
}

resource "juju_integration" "glance-keystone" {

  model = var.model-name

  application {
    name     = juju_application.glance.name
    endpoint = "identity-service"
  }

  application {
    name     = juju_application.keystone.name
    endpoint = "identity-service"
  }
}

resource "juju_integration" "glance-ceph" {

  model = var.model-name

  application {
    name     = juju_application.glance.name
    endpoint = "ceph"
  }

  application {
    name     = juju_application.ceph-mon.name
    endpoint = "client"
  }
}

#resource "juju_integration" "glance-cinder" {
#
#  model = var.model-name
#
#  application {
#    name     = juju_application.glance.name
#    endpoint = "image-service"
#  }
#
#  application {
#    name     = juju_application.cinder.name
#    endpoint = "image-service"
#  }
#}

resource "juju_integration" "glance-cinder-image" {

  model = var.model-name

  application {
    name     = juju_application.glance.name
    endpoint = "cinder-volume-service"
  }

  application {
    name     = juju_application.cinder.name
    endpoint = "cinder-volume-service"
  }
}
