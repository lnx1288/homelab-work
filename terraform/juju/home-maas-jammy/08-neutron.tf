resource "juju_machine" "ovn-central" {
  count       = var.num_units
  model       = var.model-name
  placement   = join(":", ["lxd", juju_machine.all_machines[var.controller_ids[count.index+var.num_units]].machine_id])
  constraints = "spaces=oam"
}

resource "juju_application" "ovn-central" {
  name = "ovn-central"

  model = var.model-name

  charm {
    name     = "ovn-central"
    channel  = var.ovn-channel
    base     = var.default-base
  }

  units = var.num_units

  placement = "${join(",", sort([
    for res in juju_machine.ovn-central :
        res.machine_id
  ]))}"

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
    base     = var.default-base
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
    use-internal-endpoints   = "true"
    enable-l3ha              = "true"
    dhcp-agents-per-network  = "2"
    enable-ml2-port-security = "true"
    l2-population            = "true"
    vlan-ranges              = "physnet1:350:599"
    flat-network-providers   = "physnet1"
    enable-vlan-trunking     = "false"
    manage-neutron-plugin-legacy-mode = "false"
    neutron-security-groups = "true"
    #default-tenant-network-type = "vxlan"
    overlay-network-type   = "gre"
  }
}

resource "juju_application" "neutron-api-plugin-ovn" {
  name = "neutron-api-plugin-ovn"

  model = var.model-name

  charm {
    name     = "neutron-api-plugin-ovn"
    channel  = var.openstack-channel
  }

  units = 0

  endpoint_bindings = [{
    space    = var.oam-space
  }]
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

resource "juju_integration" "neutron-api-plugin-ovn" {

  model = var.model-name

  application {
    name     = juju_application.neutron-api.name
    endpoint = "neutron-plugin-api-subordinate"
  }

  application {
    name     = juju_application.neutron-api-plugin-ovn.name
    endpoint = "neutron-plugin"
  }
}

resource "juju_integration" "neutron-api-plugin-ovn-central" {

  model = var.model-name

  application {
    name     = juju_application.ovn-central.name
    endpoint = "ovsdb-cms"
  }

  application {
    name     = juju_application.neutron-api-plugin-ovn.name
    endpoint = "ovsdb-cms"
  }
}

