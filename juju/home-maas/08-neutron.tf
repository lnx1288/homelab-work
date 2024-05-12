resource "juju_application" "neutron-gateway" {
  name = "neutron-gateway"

  model = var.model-name

  charm {
    name     = "neutron-gateway"
    channel  = var.openstack-channel
  }

  units = var.num_units

  placement = "${join(",", sort([
    for index, _ in slice(var.controller_ids, 0, var.num_units+1) :
        juju_machine.all_machines[index].machine_id
  ]))}"


  config = {
       worker-multiplier        = var.worker-multiplier
       openstack-origin         = var.openstack-origin
       bridge-mappings          = var.bridge-mappings
       data-port                = var.data-port
       aa-profile-mode          = "enforce"
       dns-servers              = var.dns-servers
       customize-failure-domain = var.customize-failure-domain
  }
}

resource "juju_machine" "neutron-api" {
  count       = var.num_units
  model       = var.model-name
  placement   = join(":", ["lxd", juju_machine.all_machines[var.controller_ids[count.index]].machine_id])
  constraints = "spaces=oam"
}

resource "juju_application" "neutron-api" {
  name = "neutron-api"

  model = var.model-name

  charm {
    name     = "neutron-api"
    channel  = var.openstack-channel
  }

  units = var.num_units

  placement = "${join(",", sort([
    for res in juju_machine.neutron-api :
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
    region            = var.openstack-region
    vip               = var.vips["neutron-api"]
    neutron-security-groups  = "true"
    #overlay-network-type     = "vxlan gre"
    overlay-network-type     = "vxlan"
    use-internal-endpoints   = "true"
    enable-l3ha              = "true"
    dhcp-agents-per-network  = "2"
    enable-ml2-port-security = "true"
    l2-population            = "true"
    #global-physnet-mtu       = "9000"
    vlan-ranges              = "physnet1:350:599"
    flat-network-providers   = "physnet1"
    enable-vlan-trunking     = "true"
    default-tenant-network-type = "vxlan"
    manage-neutron-plugin-legacy-mode = "true"
  }
}

resource "juju_application" "neutron-mysql-router" {
  name = "neutron-mysql-router"

  model = var.model-name

  charm {
    name     = "mysql-router"
    channel  = var.mysql-router-channel
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

resource "juju_application" "hacluster-neutron" {
  name = "hacluster-neutron"

  model = var.model-name

  charm {
    name     = "hacluster"
    channel  = var.hacluster-channel
  }

  units = 0
}

resource "juju_integration" "neutron-ha" {

  model = var.model-name

  application {
    name     = juju_application.neutron-api.name
    endpoint = "ha"
  }

  application {
    name     = juju_application.hacluster-neutron.name
    endpoint = "ha"
  }
}

resource "juju_integration" "neutron-mysql" {

  model = var.model-name

  application {
    name     = juju_application.neutron-api.name
    endpoint = "shared-db"
  }

  application {
    name     = juju_application.neutron-mysql-router.name
    endpoint = "shared-db"
  }
}

resource "juju_integration" "neutron-db" {

  model = var.model-name

  application {
    name     = juju_application.neutron-mysql-router.name
    endpoint = "db-router"
  }

  application {
    name     = juju_application.mysql-innodb-cluster.name
    endpoint = "db-router"
  }
}

resource "juju_integration" "neutron-keystone" {

  model = var.model-name

  application {
    name     = juju_application.neutron-api.name
    endpoint = "identity-service"
  }

  application {
    name     = juju_application.keystone.name
    endpoint = "identity-service"
  }
}

resource "juju_integration" "neutron-api-rmq" {

  model = var.model-name

  application {
    name     = juju_application.neutron-api.name
    endpoint = "amqp"
  }

  application {
    name     = juju_application.rabbitmq-server.name
    endpoint = "amqp"
  }
}

resource "juju_integration" "neutron-gw-rmq" {

  model = var.model-name

  application {
    name     = juju_application.neutron-gateway.name
    endpoint = "amqp"
  }

  application {
    name     = juju_application.rabbitmq-server.name
    endpoint = "amqp"
  }
}
