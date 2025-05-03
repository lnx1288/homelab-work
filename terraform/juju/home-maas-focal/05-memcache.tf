resource "juju_machine" "memcache" {
  count       = var.num_units
  model       = juju_model.openstack.name
  placement   = join(":", ["lxd", juju_machine.all_machines[var.controller_ids[count.index]].machine_id])
  constraints = "spaces=oam"
}

resource "juju_application" "memcached" {
  name = "memcached"

  model = juju_model.openstack.name

  charm {
    name    = "memcached"
    channel = "latest/stable"
    base    = var.default-base
  }

  units = var.num_units

  placement = "${join(",", sort([
    for res in juju_machine.memcache :
        res.machine_id
  ]))}"


  endpoint_bindings = [{
    space    = var.internal-space
  },{
    endpoint = "cache"
    space    = var.internal-space
  }]

  config = {
      allow-ufw-ip6-softfail = "true"
  }
}

resource "juju_integration" "nova-cloud-controller-memcache" {

  model = juju_model.openstack.name

  application {
    name     = juju_application.nova-cloud-controller.name
    endpoint = "memcache"
  }

  application {
    name     = juju_application.memcached.name
    endpoint = "cache"
  }
}
