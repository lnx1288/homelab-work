resource "juju_machine" "rmq-1" {
  model       = var.model-name
  placement   = join(":",["lxd",juju_machine.all_machines["103"].machine_id])
  constraints = "spaces=oam"
}
resource "juju_machine" "rmq-2" {
  model       = var.model-name
  placement   = join(":",["lxd",juju_machine.all_machines["104"].machine_id])
  constraints = "spaces=oam"
}
resource "juju_machine" "rmq-3" {
  model       = var.model-name
  placement   = join(":",["lxd",juju_machine.all_machines["105"].machine_id])
  constraints = "spaces=oam"
}


resource "juju_application" "rabbitmq-server" {
  name = "rabbitmq-server"

  model = var.model-name

  charm {
    name     = "rabbitmq-server"
    channel  = "3.8/stable"
  }

  units = 3

  placement = "${join(",",sort([
    juju_machine.rmq-1.machine_id,
    juju_machine.rmq-2.machine_id,
    juju_machine.rmq-3.machine_id,
  ]))}"

  endpoint_bindings = [{
    space    = var.oam-space
  },{
    endpoint = "amqp"
    space    = var.internal-space
  },{
    endpoint = "cluster"
    space    = var.internal-space
  }]

  config = {
      source           = var.openstack-origin
      min-cluster-size = "3"
      cluster-partition-handling = "pause_minority"
  }
}
