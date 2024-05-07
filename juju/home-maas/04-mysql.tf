resource "juju_machine" "mysql-1" {
  model = var.model-name
  placement = join(":",["lxd",juju_machine.all_machines["100"].machine_id])
  constraints = "spaces=oam"
}
resource "juju_machine" "mysql-2" {
  model = var.model-name
  placement = join(":",["lxd",juju_machine.all_machines["101"].machine_id])
  constraints = "spaces=oam"
}
resource "juju_machine" "mysql-3" {
  model = var.model-name
  placement = join(":",["lxd",juju_machine.all_machines["102"].machine_id])
  constraints = "spaces=oam"
}


resource "juju_application" "mysql-innodb-cluster" {
  name = "mysql-innodb-cluster"

  model = var.model-name

  charm {
    name     = "mysql-innodb-cluster"
    channel  = "8.0/stable"
    base     = "ubuntu@20.04"
  }

  units = 3

  placement = "${join(",",sort([
    juju_machine.mysql-1.machine_id,
    juju_machine.mysql-2.machine_id,
    juju_machine.mysql-3.machine_id,
  ]))}"

  endpoint_bindings = [{
    space = "oam"
  },{
    endpoint = "cluster"
    space = "oam"
  },{
    endpoint = "db-router"
    space = "oam"
  }]

  config = {
      source = var.openstack-origin
      #innodb-buffer-pool-size = "16G"
      wait-timeout = "3600"
      enable-binlogs = "false"
      snapd_refresh = "max"
      max-connections = var.mysql-connections
      tuning-level = var.mysql-tuning-level
  }
}

