resource "juju_machine" "memcache-1" {
  model = juju_model.cpe-focal.name
  placement = join(":",["lxd",juju_machine.all_machines["100"].machine_id])
  constraints = "spaces=oam"
}
resource "juju_machine" "memcache-2" {
  model = juju_model.cpe-focal.name
  placement = join(":",["lxd",juju_machine.all_machines["101"].machine_id])
  constraints = "spaces=oam"
}
resource "juju_machine" "memcache-3" {
  model = juju_model.cpe-focal.name
  placement = join(":",["lxd",juju_machine.all_machines["102"].machine_id])
  constraints = "spaces=oam"
}

resource "juju_application" "memcached" {
  name = "memcached"

  model = juju_model.cpe-focal.name

  charm {
    name     = "memcached"
    channel  = "latest/stable"
    base     = "ubuntu@20.04"
  }

  units = 3

  placement = "${join(",",sort([
    juju_machine.memcache-1.machine_id,
    juju_machine.memcache-2.machine_id,
    juju_machine.memcache-3.machine_id,
  ]))}"

  endpoint_bindings = [{
    space = "oam"
  },{
    endpoint = "cache"
    space = "oam"
  }]

  config = {
      allow-ufw-ip6-softfail = "true"
  }
}

resource "juju_integration" "nova-cloud-controller-memcache" {


  model = juju_model.cpe-focal.name

  application {
    name = juju_application.nova-cloud-controller.name
    endpoint = "memcache"
  }

  application {
    name = juju_application.memcached.name
    endpoint = "cache"
  }
}

