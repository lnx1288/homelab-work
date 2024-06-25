resource "juju_machine" "keystone" {
  count       = var.num_units
  model       = var.model-name
  placement   = join(":", ["lxd", juju_machine.all_machines[var.controller_ids[count.index+var.num_units]].machine_id])
  constraints = "spaces=oam"
}

resource "juju_application" "keystone" {
  name = "keystone"

  model = var.model-name

  charm {
    name     = "keystone"
    channel  = var.openstack-channel
    base     = var.default-base
  }

  units = var.num_units

  placement = "${join(",", sort([
    for res in juju_machine.keystone :
        res.machine_id
  ]))}"

  endpoint_bindings = [{
    space    = var.oam-space
  },{
    space    = var.public-space
    endpoint = "public"
  },{
    space    = var.admin-space
    endpoint = "admin"
  },{
    space    = var.internal-space
    endpoint = "internal"
  },{
    space    = var.internal-space
    endpoint = "shared-db"
  }]

  config = {
      worker-multiplier     = var.worker-multiplier
      openstack-origin      = var.openstack-origin
      vip                   = var.vips["keystone"]
      region                = var.openstack-region
      preferred-api-version = "3"
      token-provider        = "fernet"
      admin-password        = "openstack"
  }
}

resource "juju_application" "keystone-mysql-router" {
  name = "keystone-mysql-router"

  model = var.model-name

  charm {
    name = "mysql-router"
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
    source   = var.openstack-origin
  }
}

resource "juju_application" "hacluster-keystone" {
  name = "hacluster-keystone"

  model = var.model-name

  charm {
    name    = "hacluster"
    channel = var.hacluster-channel
  }

  units = 0
}

resource "juju_integration" "keystone-ha" {

  model = var.model-name

  application {
    name     = juju_application.keystone.name
    endpoint = "ha"
  }

  application {
    name     = juju_application.hacluster-keystone.name
    endpoint = "ha"
  }
}

resource "juju_integration" "keystone-mysql" {

  model = var.model-name

  application {
    name     = juju_application.keystone.name
    endpoint = "shared-db"
  }

  application {
    name     = juju_application.keystone-mysql-router.name
    endpoint = "shared-db"
  }
}

resource "juju_integration" "keystone-db" {

  model = var.model-name

  application {
    name     = juju_application.keystone-mysql-router.name
    endpoint = "db-router"
  }

  application {
    name     = juju_application.mysql-innodb-cluster.name
    endpoint = "db-router"
  }
}
