resource "juju_machine" "placement-1" {
  model = juju_model.cpe-focal.name
  placement = join(":",["lxd",juju_machine.all_machines["103"].machine_id])
  constraints = "spaces=oam"
}
resource "juju_machine" "placement-2" {
  model = juju_model.cpe-focal.name
  placement = join(":",["lxd",juju_machine.all_machines["104"].machine_id])
  constraints = "spaces=oam"
}
resource "juju_machine" "placement-3" {
  model = juju_model.cpe-focal.name
  placement = join(":",["lxd",juju_machine.all_machines["105"].machine_id])
  constraints = "spaces=oam"
}

resource "juju_application" "placement" {
  name = "placement"

  model = juju_model.cpe-focal.name

  charm {
    name     = "placement"
    channel  = "ussuri/stable"
  }

  units = 3

  placement = "${join(",",sort([
    juju_machine.placement-1.machine_id,
    juju_machine.placement-2.machine_id,
    juju_machine.placement-3.machine_id,
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
      vip = "10.0.1.223"
  }
}

resource "juju_application" "placement-mysql-router" {
  name = "placement-mysql-router"

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

resource "juju_application" "hacluster-placement" {
  name = "hacluster-placement"

  model = juju_model.cpe-focal.name

  charm {
    name     = "hacluster"
    channel  = "2.0.3/stable"
  }

  units = 0
}



resource "juju_integration" "placement-ha" {


  model = juju_model.cpe-focal.name

  application {
    name = juju_application.placement.name
    endpoint = "ha"
  }

  application {
    name = juju_application.hacluster-placement.name
    endpoint = "ha"
  }
}

resource "juju_integration" "placement-mysql" {

  model = juju_model.cpe-focal.name

  application {
    name = juju_application.placement.name
    endpoint = "shared-db"
  }

  application {
    name = juju_application.placement-mysql-router.name
    endpoint = "shared-db"
  }
}

resource "juju_integration" "placement-db" {

  model = juju_model.cpe-focal.name

  application {
    name = juju_application.placement-mysql-router.name
    endpoint = "db-router"
  }

  application {
    name = juju_application.mysql-innodb-cluster.name
    endpoint = "db-router"
  }
}

resource "juju_integration" "placement-keystone" {

  model = juju_model.cpe-focal.name

  application {
    name = juju_application.placement.name
    endpoint = "identity-service"
  }

  application {
    name = juju_application.keystone.name
    endpoint = "identity-service"
  }
}

resource "juju_integration" "placement-nova" {

  model = juju_model.cpe-focal.name

  application {
    name = juju_application.placement.name
    endpoint = "placement"
  }

  application {
    name = juju_application.nova-cloud-controller.name
    endpoint = "placement"
  }
}
