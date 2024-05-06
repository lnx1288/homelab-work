resource "juju_machine" "keystone-1" {
  model = juju_model.cpe-focal.name
  placement = join(":",["lxd",juju_machine.all_machines["103"].machine_id])
  constraints = "spaces=oam"
}
resource "juju_machine" "keystone-2" {
  model = juju_model.cpe-focal.name
  placement = join(":",["lxd",juju_machine.all_machines["104"].machine_id])
  constraints = "spaces=oam"
}
resource "juju_machine" "keystone-3" {
  model = juju_model.cpe-focal.name
  placement = join(":",["lxd",juju_machine.all_machines["105"].machine_id])
  constraints = "spaces=oam"
}


resource "juju_application" "keystone" {
  name = "keystone"

  model = juju_model.cpe-focal.name

  charm {
    name     = "keystone"
    channel  = "ussuri/stable"
  }

  units = 3

  placement = "${join(",",sort([
    juju_machine.keystone-1.machine_id,
    juju_machine.keystone-2.machine_id,
    juju_machine.keystone-3.machine_id,
  ]))}"

  endpoint_bindings = [{
    space = "oam"
  },{
    space = "oam"
    endpoint = "public"
  },{
    space = "oam"
    endpoint = "admin"
  },{
    space = "oam"
    endpoint = "internal"
  },{
    space = "oam"
    endpoint = "shared-db"
  }]

  config = {
      worker-multiplier = var.worker-multiplier
      openstack-origin = var.openstack-origin
      vip = "10.0.1.216"
      region = var.openstack-region
      preferred-api-version = "3"
      token-provider = "fernet"
  }
}

resource "juju_application" "keystone-mysql-router" {
  name = "keystone-mysql-router"

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

resource "juju_application" "hacluster-keystone" {
  name = "hacluster-keystone"

  model = juju_model.cpe-focal.name

  charm {
    name     = "hacluster"
    channel  = "2.0.3/stable"
  }

  units = 0
}

resource "juju_integration" "keystone-ha" {


  model = juju_model.cpe-focal.name

  application {
    name = juju_application.keystone.name
    endpoint = "ha"
  }

  application {
    name = juju_application.hacluster-keystone.name
    endpoint = "ha"
  }
}

resource "juju_integration" "keystone-mysql" {

  model = juju_model.cpe-focal.name

  application {
    name = juju_application.keystone.name
    endpoint = "shared-db"
  }

  application {
    name = juju_application.keystone-mysql-router.name
    endpoint = "shared-db"
  }
}

resource "juju_integration" "keystone-db" {

  model = juju_model.cpe-focal.name

  application {
    name = juju_application.keystone-mysql-router.name
    endpoint = "db-router"
  }

  application {
    name = juju_application.mysql-innodb-cluster.name
    endpoint = "db-router"
  }
}

