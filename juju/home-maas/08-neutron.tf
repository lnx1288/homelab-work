resource "juju_application" "neutron-gateway" {
  name = "neutron-gateway"

  model = var.model-name

  charm {
    name     = "neutron-gateway"
    channel  = "ussuri/stable"
  }

  units = 3
  placement = "${join(",",sort([
    juju_machine.all_machines["100"].machine_id,
    juju_machine.all_machines["101"].machine_id,
    juju_machine.all_machines["102"].machine_id,
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

resource "juju_machine" "neutron-api-1" {
  model = var.model-name
  placement = join(":",["lxd",juju_machine.all_machines["100"].machine_id])
  constraints = "spaces=oam"
}
resource "juju_machine" "neutron-api-2" {
  model = var.model-name
  placement = join(":",["lxd",juju_machine.all_machines["101"].machine_id])
  constraints = "spaces=oam"
}
resource "juju_machine" "neutron-api-3" {
  model = var.model-name
  placement = join(":",["lxd",juju_machine.all_machines["102"].machine_id])
  constraints = "spaces=oam"
}

resource "juju_application" "neutron-api" {
  name = "neutron-api"

  model = var.model-name

  charm {
    name     = "neutron-api"
    channel  = "ussuri/stable"
  }

  units = 3

  placement = "${join(",",sort([
    juju_machine.neutron-api-1.machine_id,
    juju_machine.neutron-api-2.machine_id,
    juju_machine.neutron-api-3.machine_id,
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
    vip = "10.0.1.218"
    worker-multiplier: var.worker-multiplier
    openstack-origin: var.openstack-origin
    region: var.openstack-region
    neutron-security-groups = "true"
    #overlay-network-type = "vxlan gre"
    overlay-network-type = "vxlan"
    use-internal-endpoints = "true"
    enable-l3ha = "true"
    dhcp-agents-per-network = "2"
    enable-ml2-port-security = "true"
    default-tenant-network-type = "vxlan"
    l2-population = "true"
    #global-physnet-mtu = "9000"
    manage-neutron-plugin-legacy-mode = "true"
    vlan-ranges = "physnet1:350:599"
    flat-network-providers = "physnet1"
    enable-vlan-trunking = "true"
  }


}

resource "juju_application" "neutron-mysql-router" {
  name = "neutron-mysql-router"

  model = var.model-name

  charm {
    name     = "mysql-router"
    channel  = "8.0/stable"
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

resource "juju_application" "hacluster-neutron" {
  name = "hacluster-neutron"

  model = var.model-name

  charm {
    name     = "hacluster"
    channel  = "2.0.3/stable"
  }

  units = 0
}

resource "juju_integration" "neutron-ha" {

  model = var.model-name

  application {
    name = juju_application.neutron-api.name
    endpoint = "ha"
  }

  application {
    name = juju_application.hacluster-neutron.name
    endpoint = "ha"
  }
}

resource "juju_integration" "neutron-mysql" {

  model = var.model-name

  application {
    name = juju_application.neutron-api.name
    endpoint = "shared-db"
  }

  application {
    name = juju_application.neutron-mysql-router.name
    endpoint = "shared-db"
  }
}

resource "juju_integration" "neutron-db" {

  model = var.model-name

  application {
    name = juju_application.neutron-mysql-router.name
    endpoint = "db-router"
  }

  application {
    name = juju_application.mysql-innodb-cluster.name
    endpoint = "db-router"
  }
}

resource "juju_integration" "neutron-keystone" {

  model = var.model-name

  application {
    name = juju_application.neutron-api.name
    endpoint = "identity-service"
  }

  application {
    name = juju_application.keystone.name
    endpoint = "identity-service"
  }
}

resource "juju_integration" "neutron-api-rmq" {

  model = var.model-name

  application {
    name = juju_application.neutron-api.name
    endpoint = "amqp"
  }

  application {
    name = juju_application.rabbitmq-server.name
    endpoint = "amqp"
  }
}

resource "juju_integration" "neutron-gw-rmq" {

  model = var.model-name

  application {
    name = juju_application.neutron-gateway.name
    endpoint = "amqp"
  }

  application {
    name = juju_application.rabbitmq-server.name
    endpoint = "amqp"
  }
}
