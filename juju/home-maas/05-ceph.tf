
resource "juju_application" "ceph-osd" {
  name = "ceph-osd"

  model = juju_model.cpe-focal.name

  charm {
    name     = "ceph-osd"
    channel  = "octopus/stable"
  }

  units = 8
  #placement = "1000,1002,1003,1004,1005,1006,1007"

  config = {
    osd-devices = var.osd-devices
    source = var.openstack-origin
    autotune = "false"
    aa-profile-mode = "complain"
    bluestore = "true"
    osd-encrypt = "true"
    osd-encrypt-keymanager = "vault"
  }
}


resource "juju_application" "ceph-mon" {
  name = "ceph-mon"

  model = juju_model.cpe-focal.name

  charm {
    name     = "ceph-mon"
    channel  = "octopus/stable"
  }

  units = 3

  config = {
      expected-osd-count = 12
      source = var.openstack-origin
      monitor-count = 3
      customize-failure-domain = true
  }
}

resource "juju_application" "ceph-radosgw" {
  name = "ceph-radosgw"

  model = juju_model.cpe-focal.name

  charm {
    name     = "ceph-radosgw"
    channel  = "octopus/stable"
  }

  units = 3

  config = {
      source: var.openstack-origin
      vip = "10.0.1.224"
      region = "RegionOne"
      operator-roles = "Member,admin" # Contrail requires admin and not Admin
  }
}

resource "juju_application" "hacluster-radosgw" {
  name = "hacluster-radosgw"

  model = juju_model.cpe-focal.name

  charm {
    name     = "hacluster"
    channel  = "2.0.3/stable"
  }

}

resource "juju_integration" "osd-mon" {

  model = juju_model.cpe-focal.name

  application {
    name = juju_application.ceph-osd.name
    endpoint = "mon"
  }

  application {
    name = juju_application.ceph-mon.name
    endpoint = "osd"
  }
}


resource "juju_integration" "rgw-mon" {

  model = juju_model.cpe-focal.name

  application {
    name = juju_application.ceph-radosgw.name
    endpoint = "mon"
  }

  application {
    name = juju_application.ceph-mon.name
    endpoint = "radosgw"
  }
}


resource "juju_integration" "rgw-ha" {

  model = juju_model.cpe-focal.name

  application {
    name = juju_application.ceph-radosgw.name
    endpoint = "ha"
  }

  application {
    name = juju_application.hacluster-radosgw.name
    endpoint = "ha"
  }
}
