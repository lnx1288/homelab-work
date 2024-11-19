resource "juju_application" "nrpe-host" {
  name = "nrpe-host"

  model = juju_model.openstack.name

  charm {
    name     = "nrpe"
    channel  = "latest/stable"
    base     = var.default-base
  }

  units = 0

  endpoint_bindings = [{
    space    = var.oam-space
  }]

  config = {
      nagios_hostname_type = "host"
      nagios_host_context = var.nagios-context
      xfs_errors = "30"
      netlinks = "- bond0 mtu:1500 speed:1000, - bond1 mtu:9000 speed:50000"
  }
}

resource "juju_application" "nrpe-cont" {
  name = "nrpe-container"

  model = juju_model.openstack.name

  charm {
    name     = "nrpe"
    channel  = "latest/stable"
    base     = var.default-base
  }

  units = 0

  endpoint_bindings = [{
    space    = var.oam-space
  }]

  config = {
      nagios_hostname_type = "unit"
      nagios_host_context = var.nagios-context
      disk_root = ""
      load = ""
      swap = ""
      swap_activity = ""
      mem = ""
  }
}

locals {
  cont_apps = [
    "vault",
    "etcd",
    "keystone",
    "glance",
    "cinder",
    "heat",
    "ceph-mon",
    "neutron-api",
    "rabbitmq-server",
    "openstack-dashboard",
    "nova-cloud-controller",
  ]
}

resource "juju_integration" "nrpe-cont-integration" {
  for_each = toset(local.cont_apps)

  model = juju_model.openstack.name

  application {
    name     = juju_application.nrpe-cont.name
    endpoint = "nrpe-external-master"
  }

  application {
    name     = "${each.value}"
    endpoint = "nrpe-external-master"
  }
}

locals {
  cont_apps_info = [
    "placement",
    "memcached",
  ]
}

resource "juju_integration" "nrpe-cont-info-integration" {
  for_each = toset(local.cont_apps_info)

  model = juju_model.openstack.name

  application {
    name     = juju_application.nrpe-cont.name
    endpoint = "general-info"
  }

  application {
    name     = "${each.value}"
    endpoint = "juju-info"
  }
}

locals {
  host_apps = [
    "nova-compute-kvm",
    "neutron-gateway",
  ]
}

resource "juju_integration" "nrpe-host-integration" {
  for_each = toset(local.host_apps)

  model = juju_model.openstack.name

  application {
    name     = juju_application.nrpe-host.name
    endpoint = "nrpe-external-master"
  }

  application {
    name     = "${each.value}"
    endpoint = "nrpe-external-master"
  }
}

resource "juju_integration" "nrpe-cont-nagios" {

  model = juju_model.openstack.name

  application {
    name     = juju_application.nrpe-cont.name
    endpoint = "monitors"
  }

  application {
    offer_url = juju_offer.nagios.url
  }
}

resource "juju_integration" "nrpe-host-nagios" {

  model = juju_model.openstack.name

  application {
    name     = juju_application.nrpe-host.name
    endpoint = "monitors"
  }

  application {
    offer_url = juju_offer.nagios.url
  }
}
