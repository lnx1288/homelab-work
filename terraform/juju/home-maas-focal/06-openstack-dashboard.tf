resource "juju_machine" "openstack-dashboard" {
  count       = var.num_units
  model       = juju_model.openstack.name
  placement   = join(":", ["lxd", juju_machine.all_machines[var.controller_ids[count.index]].machine_id])
  constraints = "spaces=oam,ceph-access"
}

resource "juju_application" "openstack-dashboard" {
  name = "openstack-dashboard"

  model = juju_model.openstack.name

  charm {
    name     = "openstack-dashboard"
    channel  = var.openstack-channel
  }

  units = var.num_units

  placement = "${join(",", sort([
    for res in juju_machine.openstack-dashboard :
        res.machine_id
  ]))}"

  endpoint_bindings = [{
    space    = var.oam-space
  },{
    endpoint = "shared-db"
    space    = var.internal-space
  }]

  config = {
      openstack-origin  = var.openstack-origin
      vip               = var.vips["dashboard"]
      webroot           = "/"
      secret            = "encryptcookieswithme"
      cinder-backup     = "false"
      password-retrieve = "true"
      endpoint-type     = "publicURL"

      neutron-network-l3ha     = "true"
      neutron-network-lb       = "true"
      neutron-network-firewall = "false"
  }
}

resource "juju_application" "openstack-dashboard-mysql-router" {
  name = "openstack-dashboard-mysql-router"

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

resource "juju_application" "hacluster-openstack-dashboard" {
  name = "hacluster-openstack-dashboard"

  model = juju_model.openstack.name

  charm {
    name     = "hacluster"
    channel  = var.hacluster-channel
  }

  units = 0
}

resource "juju_integration" "openstack-dashboard-ha" {

  model = juju_model.openstack.name

  application {
    name     = juju_application.openstack-dashboard.name
    endpoint = "ha"
  }

  application {
    name     = juju_application.hacluster-openstack-dashboard.name
    endpoint = "ha"
  }
}

resource "juju_integration" "openstack-dashboard-mysql" {

  model = juju_model.openstack.name

  application {
    name     = juju_application.openstack-dashboard.name
    endpoint = "shared-db"
  }

  application {
    name     = juju_application.openstack-dashboard-mysql-router.name
    endpoint = "shared-db"
  }
}

resource "juju_integration" "openstack-dashboard-db" {

  model = juju_model.openstack.name

  application {
    name     = juju_application.openstack-dashboard-mysql-router.name
    endpoint = "db-router"
  }

  application {
    name     = juju_application.mysql-innodb-cluster.name
    endpoint = "db-router"
  }
}

resource "juju_integration" "openstack-dashboard-keystone" {

  model = juju_model.openstack.name

  application {
    name     = juju_application.openstack-dashboard.name
    endpoint = "identity-service"
  }

  application {
    name     = juju_application.keystone.name
    endpoint = "identity-service"
  }
}
