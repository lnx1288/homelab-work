resource "juju_machine" "ncc" {
  count       = var.num_units
  model       = var.model-name
  placement   = join(":", ["lxd", juju_machine.all_machines[var.controller_ids[count.index+var.num_units]].machine_id])
  constraints = "spaces=oam"
}

resource "juju_application" "nova-cloud-controller" {
  name = "nova-cloud-controller"

  model = var.model-name

  charm {
    name     = "nova-cloud-controller"
    channel  = var.openstack-channel
    base     = var.default-base
  }

  units = var.num_units

  placement = "${join(",", sort([
    for res in juju_machine.ncc :
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
  },{
    endpoint = "memcache"
    space    = var.internal-space
  }]

  config = {
      worker-multiplier = var.worker-multiplier
      openstack-origin  = var.openstack-origin
      region            = var.openstack-region
      vip               = var.vips["nova-cc"]
      network-manager   = "Neutron"
      console-access-protocol = "novnc"
      console-proxy-ip       = "local"
      use-internal-endpoints = "true"
      ram-allocation-ratio   = var.ram-allocation-ratio
      cpu-allocation-ratio   = var.cpu-allocation-ratio
      config-flags           = "scheduler_max_attempts=20"
  }
}

resource "juju_application" "nova-cloud-controller-mysql-router" {
  name = "nova-cloud-controller-mysql-router"

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

resource "juju_application" "hacluster-nova" {
  name = "hacluster-nova"

  model = var.model-name

  charm {
    name     = "hacluster"
    channel  = var.hacluster-channel
  }

  units = 0
}

resource "juju_integration" "nova-cloud-controller-ha" {

  model = var.model-name

  application {
    name     = juju_application.nova-cloud-controller.name
    endpoint = "ha"
  }

  application {
    name     = juju_application.hacluster-nova.name
    endpoint = "ha"
  }
}

resource "juju_integration" "nova-cloud-controller-mysql" {

  model = var.model-name

  application {
    name     = juju_application.nova-cloud-controller.name
    endpoint = "shared-db"
  }

  application {
    name     = juju_application.nova-cloud-controller-mysql-router.name
    endpoint = "shared-db"
  }
}

resource "juju_integration" "nova-cloud-controller-db" {

  model = var.model-name

  application {
    name     = juju_application.nova-cloud-controller-mysql-router.name
    endpoint = "db-router"
  }

  application {
    name     = juju_application.mysql-innodb-cluster.name
    endpoint = "db-router"
  }
}

resource "juju_integration" "nova-cloud-controller-rmq" {

  model = var.model-name

  application {
    name     = juju_application.nova-cloud-controller.name
    endpoint = "amqp"
  }

  application {
    name     = juju_application.rabbitmq-server.name
    endpoint = "amqp"
  }
}

resource "juju_integration" "nova-cloud-controller-keystone" {

  model = var.model-name

  application {
    name     = juju_application.nova-cloud-controller.name
    endpoint = "identity-service"
  }

  application {
    name     = juju_application.keystone.name
    endpoint = "identity-service"
  }
}

resource "juju_integration" "nova-cloud-controller-neutron" {

  model = var.model-name

  application {
    name     = juju_application.nova-cloud-controller.name
    endpoint = "neutron-api"
  }

  application {
    name     = juju_application.neutron-api.name
    endpoint = "neutron-api"
  }
}

resource "juju_integration" "nova-cloud-controller-nova-compute" {

  model = var.model-name

  application {
    name     = juju_application.nova-cloud-controller.name
    endpoint = "cloud-compute"
  }

  application {
    name     = juju_application.nova-compute-kvm.name
    endpoint = "cloud-compute"
  }
}
resource "juju_integration" "nova-cloud-controller-glance" {

  model = var.model-name

  application {
    name     = juju_application.nova-cloud-controller.name
    endpoint = "image-service"
  }

  application {
    name     = juju_application.glance.name
    endpoint = "image-service"
  }
}
