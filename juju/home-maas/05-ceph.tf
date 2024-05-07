resource "juju_application" "ceph-osd" {
  name = "ceph-osd"

  model = var.model-name

  charm {
    name     = "ceph-osd"
    channel  = "octopus/stable"
  }

  units = 8
  placement = "${join(",",sort([
    juju_machine.all_machines["1000"].machine_id,
    juju_machine.all_machines["1001"].machine_id,
    juju_machine.all_machines["1002"].machine_id,
    juju_machine.all_machines["1003"].machine_id,
    juju_machine.all_machines["1004"].machine_id,
    juju_machine.all_machines["1005"].machine_id,
    juju_machine.all_machines["1006"].machine_id,
    juju_machine.all_machines["1007"].machine_id,
   ]))}"

  config = {
    osd-devices = var.osd-devices
    source = var.openstack-origin
    aa-profile-mode = "complain"
    customize-failure-domain = "true"
    autotune = "false"
    bluestore = "true"
    #osd-encrypt = "true"
    #osd-encrypt-keymanager = "vault"
  }
}

resource "juju_machine" "ceph-mon-1" {
  model = var.model-name
  placement = join(":",["lxd",juju_machine.all_machines["100"].machine_id])
  constraints = "spaces=oam,ceph-access,ceph-replica"
}
resource "juju_machine" "ceph-mon-2" {
  model = var.model-name
  placement = join(":",["lxd",juju_machine.all_machines["101"].machine_id])
  constraints = "spaces=oam,ceph-access,ceph-replica"
}
resource "juju_machine" "ceph-mon-3" {
  model = var.model-name
  placement = join(":",["lxd",juju_machine.all_machines["102"].machine_id])
  constraints = "spaces=oam,ceph-access,ceph-replica"
}


resource "juju_application" "ceph-mon" {
  name = "ceph-mon"

  model = var.model-name

  charm {
    name     = "ceph-mon"
    channel  = "octopus/stable"
  }

  units = 3

  placement = "${join(",",sort([
    juju_machine.ceph-mon-1.machine_id,
    juju_machine.ceph-mon-2.machine_id,
    juju_machine.ceph-mon-3.machine_id,
  ]))}"

  endpoint_bindings = [{
    space = "oam"
  },{
    endpoint = "public"
    space = "ceph-access"
  },{
    endpoint = "osd"
    space = "ceph-access"
  },{
    endpoint = "client"
    space = "ceph-access"
  },{
    endpoint = "admin"
    space = "ceph-access"
  },{
    endpoint = "cluster"
    space = "ceph-replica"
  }]

  config = {
      expected-osd-count = 12
      source = var.openstack-origin
      monitor-count = 3
      customize-failure-domain = true
  }
}

resource "juju_machine" "ceph-rgw-1" {
  model = var.model-name
  placement = join(":",["lxd",juju_machine.all_machines["100"].machine_id])
  constraints = "spaces=oam,ceph-access"
}
resource "juju_machine" "ceph-rgw-2" {
  model = var.model-name
  placement = join(":",["lxd",juju_machine.all_machines["101"].machine_id])
  constraints = "spaces=oam,ceph-access"
}
resource "juju_machine" "ceph-rgw-3" {
  model = var.model-name
  placement = join(":",["lxd",juju_machine.all_machines["102"].machine_id])
  constraints = "spaces=oam,ceph-access"
}

resource "juju_application" "ceph-radosgw" {
  name = "ceph-radosgw"

  model = var.model-name

  charm {
    name     = "ceph-radosgw"
    channel  = "octopus/stable"
  }

  units = 3

  placement = "${join(",",sort([
    juju_machine.ceph-rgw-1.machine_id,
    juju_machine.ceph-rgw-2.machine_id,
    juju_machine.ceph-rgw-3.machine_id,
  ]))}"

  endpoint_bindings = [{
    space = "oam"
  },{
    space = "oam"
    endpoint = "public"
  },{
    space = "oam"
    endpoint = "admin"
  },{
    space = "oam"
    endpoint = "internal"
  },{
    space = "ceph-access"
    endpoint = "mon"
  }]

  config = {
      source = var.openstack-origin
      vip = "10.0.1.224"
      operator-roles = "Member,admin"
      region = var.openstack-region
      os-admin-hostname    = "swift-internal.example.com"
      os-internal-hostname = "swift-internal.example.com"
      os-public-hostname   = "swift.example.com"
  }
}

resource "juju_application" "hacluster-radosgw" {
  name = "hacluster-radosgw"

  model = var.model-name

  charm {
    name     = "hacluster"
    channel  = "2.0.3/stable"
  }

  units = 0

}

resource "juju_integration" "osd-mon" {

  model = var.model-name

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

  model = var.model-name

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

  model = var.model-name

  application {
    name = juju_application.ceph-radosgw.name
    endpoint = "ha"
  }

  application {
    name = juju_application.hacluster-radosgw.name
    endpoint = "ha"
  }
}

resource "juju_integration" "rgw-keystone" {

  model = var.model-name

  application {
    name = juju_application.ceph-radosgw.name
    endpoint = "identity-service"
  }

  application {
    name = juju_application.keystone.name
    endpoint = "identity-service"
  }
}

