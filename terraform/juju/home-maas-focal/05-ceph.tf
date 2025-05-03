resource "juju_application" "ceph-osd" {
  name = "ceph-osd"

  model = juju_model.openstack.name

  charm {
    name    = "ceph-osd"
    channel = var.ceph-channel
  }

  units = length(var.compute_ids)

  placement = "${join(",", sort([
    for index in var.compute_ids :
      juju_machine.all_machines[index].machine_id
  ]))}"

  config = {
    osd-devices     = var.osd-devices
    source          = var.openstack-origin
    aa-profile-mode = "complain"
    customize-failure-domain = "true"
    autotune        = "false"
    bluestore       = "true"
    #osd-encrypt     = "true"
    #osd-encrypt-keymanager = "vault"
  }
}

resource "juju_machine" "ceph-mon" {
  count       = var.num_units
  model       = juju_model.openstack.name
  placement   = join(":", ["lxd", juju_machine.all_machines[var.controller_ids[count.index]].machine_id])
  constraints = "spaces=oam,ceph-access,ceph-replica"
}

resource "juju_application" "ceph-mon" {
  name = "ceph-mon"

  model = juju_model.openstack.name

  charm {
    name     = "ceph-mon"
    channel  = var.ceph-channel
  }

  units = var.num_units

  placement = "${join(",", sort([
    for res in juju_machine.ceph-mon :
        res.machine_id
  ]))}"

  endpoint_bindings = [{
    space    = var.oam-space
  },{
    endpoint = "public"
    space    = var.ceph-public-space
  },{
    endpoint = "osd"
    space    = var.ceph-public-space
  },{
    endpoint = "client"
    space    = var.ceph-public-space
  },{
    endpoint = "admin"
    space    = var.ceph-public-space
  },{
    endpoint = "cluster"
    space    = var.ceph-cluster-space
  }]

  config = {
      expected-osd-count = var.expected-osd-count
      source             = var.openstack-origin
      monitor-count      = var.expected-mon-count
      customize-failure-domain = true
  }
}

resource "juju_machine" "ceph-rgw" {
  count       = var.num_units
  model       = juju_model.openstack.name
  placement   = join(":", ["lxd", juju_machine.all_machines[var.controller_ids[count.index]].machine_id])
  constraints = "spaces=oam,ceph-access"
}

resource "juju_application" "ceph-radosgw" {
  name = "ceph-radosgw"

  model = juju_model.openstack.name

  charm {
    name     = "ceph-radosgw"
    channel  = var.ceph-channel
  }

  units = var.num_units

  placement = "${join(",", sort([
    for res in juju_machine.ceph-rgw :
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
    space    = var.ceph-public-space
    endpoint = "mon"
  }]

  config = {
      source               = var.openstack-origin
      vip                  = var.vips["radosgw"]
      operator-roles       = "Member,admin"
      region               = var.openstack-region
      os-admin-hostname    = "swift-internal.example.com"
      os-internal-hostname = "swift-internal.example.com"
      os-public-hostname   = "swift.example.com"
  }
}

resource "juju_application" "hacluster-radosgw" {
  name = "hacluster-radosgw"

  model = juju_model.openstack.name

  charm {
    name     = "hacluster"
    channel  = var.hacluster-channel
  }

  units = 0
}

resource "juju_integration" "osd-mon" {

  model = juju_model.openstack.name

  application {
    name     = juju_application.ceph-osd.name
    endpoint = "mon"
  }

  application {
    name     = juju_application.ceph-mon.name
    endpoint = "osd"
  }
}

resource "juju_integration" "rgw-mon" {

  model = juju_model.openstack.name

  application {
    name     = juju_application.ceph-radosgw.name
    endpoint = "mon"
  }

  application {
    name     = juju_application.ceph-mon.name
    endpoint = "radosgw"
  }
}

resource "juju_integration" "rgw-ha" {

  model = juju_model.openstack.name

  application {
    name     = juju_application.ceph-radosgw.name
    endpoint = "ha"
  }

  application {
    name     = juju_application.hacluster-radosgw.name
    endpoint = "ha"
  }
}

resource "juju_integration" "rgw-keystone" {

  model = juju_model.openstack.name

  application {
    name     = juju_application.ceph-radosgw.name
    endpoint = "identity-service"
  }

  application {
    name     = juju_application.keystone.name
    endpoint = "identity-service"
  }
}
