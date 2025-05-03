resource "juju_application" "ceilometer-agent" {
  name = "ceilometer-agent"

  model = juju_model.openstack.name

  charm {
    name     = "ceilometer-agent"
    channel  = var.openstack-channel
  }

  units = 0

  config = {
    use-internal-endpoints = "true"
  }
}

resource "juju_integration" "compute-ceilometer" {

  model = juju_model.openstack.name

  application {
    name     = juju_application.nova-compute-kvm.name
    endpoint = "nova-ceilometer"
  }

  application {
    name     = juju_application.ceilometer-agent.name
    endpoint = "nova-ceilometer"
  }
}

resource "juju_integration" "ceilometer-agent-rmq" {

  model = juju_model.openstack.name

  application {
    name     = juju_application.ceilometer-agent.name
    endpoint = "amqp"
  }

  application {
    name     = juju_application.rabbitmq-server.name
    endpoint = "amqp"
  }
}
