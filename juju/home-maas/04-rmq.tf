resource "juju_machine" "rmq" {
  count       = var.num_units
  model       = var.model-name
  placement   = join(":", ["lxd", juju_machine.all_machines[var.controller_ids_high[count.index+var.num_units]].machine_id])
  constraints = "spaces=oam"
}

resource "juju_application" "rabbitmq-server" {
  name = "rabbitmq-server"

  model = var.model-name

  charm {
    name     = "rabbitmq-server"
    channel  = var.rabbitmq-server-channel
  }

  units = 3

  placement = "${join(",", sort([
    for res in juju_machine.rmq :
        res.machine_id
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
