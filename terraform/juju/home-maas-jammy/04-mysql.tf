resource "juju_machine" "mysql" {
  count       = var.num_units
  model       = var.model-name
  placement   = join(":", ["lxd", juju_machine.all_machines[var.controller_ids[count.index]].machine_id])
  constraints = "spaces=oam"
}

resource "juju_application" "mysql-innodb-cluster" {
  name = "mysql-innodb-cluster"

  model = var.model-name

  charm {
    name     = "mysql-innodb-cluster"
    channel  = var.mysql-channel
    base     = var.default-base
  }

  machines = [
    for res in juju_machine.mysql :
        res.machine_id
  ]

  endpoint_bindings = [{
    space    = var.oam-space
  },{
    endpoint = "cluster"
    space    = var.internal-space
  },{
    endpoint = "db-router"
    space    = var.internal-space
  }]

  config = {
      source          = var.openstack-origin
      wait-timeout    = "3600"
      enable-binlogs  = "false"
      snapd_refresh   = "max"
      max-connections = var.mysql-connections
      tuning-level    = var.mysql-tuning-level
  }
}
