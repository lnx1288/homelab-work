resource "juju_machine" "ncc-1" {
  model = juju_model.cpe-focal.name
  placement = join(":",["lxd",juju_machine.all_machines["103"].machine_id])
  constraints = "spaces=oam"
}
resource "juju_machine" "ncc-2" {
  model = juju_model.cpe-focal.name
  placement = join(":",["lxd",juju_machine.all_machines["104"].machine_id])
  constraints = "spaces=oam"
}
resource "juju_machine" "ncc-3" {
  model = juju_model.cpe-focal.name
  placement = join(":",["lxd",juju_machine.all_machines["105"].machine_id])
  constraints = "spaces=oam"
}


resource "juju_application" "nova-cloud-controller" {
  name = "nova-cloud-controller"

  model = juju_model.cpe-focal.name

  charm {
    name     = "nova-cloud-controller"
    channel  = "ussuri/stable"
  }

  units = 3

  placement = "${join(",",sort([
    juju_machine.ncc-1.machine_id,
    juju_machine.ncc-2.machine_id,
    juju_machine.ncc-3.machine_id,
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
    endpoint = "memcache"
    space = "oam"
  }]

  config = {
      worker-multiplier = var.worker-multiplier
      openstack-origin = var.openstack-origin
      region = var.openstack-region
      vip = "10.0.1.219"
      network-manager = "Neutron"
      console-access-protocol = "novnc"
      console-proxy-ip = "local"
      use-internal-endpoints = "true"
      ram-allocation-ratio: "1.0"
      cpu-allocation-ratio: "2.0"
      config-flags = "scheduler_max_attempts=20"
  }
}

resource "juju_application" "nova-cloud-controller-mysql-router" {
  name = "nova-cloud-controller-mysql-router"

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

resource "juju_application" "hacluster-nova" {
  name = "hacluster-nova"

  model = juju_model.cpe-focal.name

  charm {
    name     = "hacluster"
    channel  = "2.0.3/stable"
  }

  units = 0
}

resource "juju_integration" "nova-cloud-controller-ha" {


  model = juju_model.cpe-focal.name

  application {
    name = juju_application.nova-cloud-controller.name
    endpoint = "ha"
  }

  application {
    name = juju_application.hacluster-nova.name
    endpoint = "ha"
  }
}

resource "juju_integration" "nova-cloud-controller-mysql" {

  model = juju_model.cpe-focal.name

  application {
    name = juju_application.nova-cloud-controller.name
    endpoint = "shared-db"
  }

  application {
    name = juju_application.nova-cloud-controller-mysql-router.name
    endpoint = "shared-db"
  }
}

resource "juju_integration" "nova-cloud-controller-db" {

  model = juju_model.cpe-focal.name

  application {
    name = juju_application.nova-cloud-controller-mysql-router.name
    endpoint = "db-router"
  }

  application {
    name = juju_application.mysql-innodb-cluster.name
    endpoint = "db-router"
  }
}

resource "juju_integration" "nova-cloud-controller-rmq" {

  model = juju_model.cpe-focal.name

  application {
    name = juju_application.nova-cloud-controller.name
    endpoint = "amqp"
  }

  application {
    name = juju_application.rabbitmq-server.name
    endpoint = "amqp"
  }
}

resource "juju_integration" "nova-cloud-controller-keystone" {

  model = juju_model.cpe-focal.name

  application {
    name = juju_application.nova-cloud-controller.name
    endpoint = "identity-service"
  }

  application {
    name = juju_application.keystone.name
    endpoint = "identity-service"
  }
}

resource "juju_integration" "nova-cloud-controller-neutron" {

  model = juju_model.cpe-focal.name

  application {
    name = juju_application.nova-cloud-controller.name
    endpoint = "neutron-api"
  }

  application {
    name = juju_application.neutron-api.name
    endpoint = "neutron-api"
  }
}

resource "juju_integration" "nova-cloud-controller-nova-compute" {

  model = juju_model.cpe-focal.name

  application {
    name = juju_application.nova-cloud-controller.name
    endpoint = "cloud-compute"
  }

  application {
    name = juju_application.nova-compute-kvm.name
    endpoint = "cloud-compute"
  }
}
resource "juju_integration" "nova-cloud-controller-glance" {

  model = juju_model.cpe-focal.name

  application {
    name = juju_application.nova-cloud-controller.name
    endpoint = "image-service"
  }

  application {
    name = juju_application.glance.name
    endpoint = "image-service"
  }
}
