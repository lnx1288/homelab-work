resource "juju_machine" "placement" {
  count       = var.num_units
  model       = juju_model.openstack.name
  placement   = join(":", ["lxd", juju_machine.all_machines[var.controller_ids[count.index+var.num_units]].machine_id])
  constraints = "spaces=oam"
}

resource "juju_application" "placement" {
  name = "placement"

  model = juju_model.openstack.name

  charm {
    name     = "placement"
    channel  = var.openstack-channel
  }

  units = var.num_units

  placement = "${join(",", sort([
    for res in juju_machine.placement :
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
      vip               = var.vips["placement"]
  }
}

resource "juju_application" "placement-mysql-router" {
  name = "placement-mysql-router"

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

resource "juju_application" "hacluster-placement" {
  name = "hacluster-placement"

  model = juju_model.openstack.name

  charm {
    name     = "hacluster"
    channel  = var.hacluster-channel
  }

  units = 0
}

resource "juju_integration" "placement-ha" {

  model = juju_model.openstack.name

  application {
    name     = juju_application.placement.name
    endpoint = "ha"
  }

  application {
    name     = juju_application.hacluster-placement.name
    endpoint = "ha"
  }
}

resource "juju_integration" "placement-mysql" {

  model = juju_model.openstack.name

  application {
    name     = juju_application.placement.name
    endpoint = "shared-db"
  }

  application {
    name     = juju_application.placement-mysql-router.name
    endpoint = "shared-db"
  }
}

resource "juju_integration" "placement-db" {

  model = juju_model.openstack.name

  application {
    name     = juju_application.placement-mysql-router.name
    endpoint = "db-router"
  }

  application {
    name     = juju_application.mysql-innodb-cluster.name
    endpoint = "db-router"
  }
}

resource "juju_integration" "placement-keystone" {

  model = juju_model.openstack.name

  application {
    name     = juju_application.placement.name
    endpoint = "identity-service"
  }

  application {
    name     = juju_application.keystone.name
    endpoint = "identity-service"
  }
}

resource "juju_integration" "placement-nova" {

  model = juju_model.openstack.name

  application {
    name     = juju_application.placement.name
    endpoint = "placement"
  }

  application {
    name     = juju_application.nova-cloud-controller.name
    endpoint = "placement"
  }
}
