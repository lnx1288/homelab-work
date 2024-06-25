resource "juju_application" "graylog" {
  name = "graylog"

  model = var.lma-model-name

  charm {
    name     = "graylog"
    channel  = "latest/stable"
    base     = "ubuntu@20.04"
  }

  units = 1

  placement = juju_machine.lma_machines["200"].machine_id

   endpoint_bindings = [{
     space    = var.oam-space
   }]

  config = {
       channel               = "4/stable"
       jvm_heap_size         = "1G"
       rest_transport_uri    = "http://graylog.example.com:9001"
       index_rotation_period = "PT3H"
  }
}

resource "juju_machine" "graylog-mongodb" {
  model       = var.lma-model-name
  placement   = join(":", ["lxd", juju_machine.lma_machines["200"].machine_id])
  constraints = "spaces=oam"
}


resource "juju_application" "graylog-mongodb" {
  name = "graylog-mongodb"

  model = var.lma-model-name

  charm {
    name     = "mongodb"
    channel  = "3.6/stable"
    base     = "ubuntu@20.04"
  }

  units = 1

  placement = juju_machine.graylog-mongodb.machine_id

   endpoint_bindings = [{
     space    = var.oam-space
   }]

  config = {
       nagios_context  = var.nagios-context
  }
}

resource "juju_integration" "graylog-mongodb" {

  model = var.lma-model-name

  application {
    name     = juju_application.graylog.name
    endpoint = "mongodb"
  }

  application {
    name     = juju_application.graylog-mongodb.name
    endpoint = "database"
  }
}

resource "juju_offer" "graylog" {
  model            = var.lma-model-name
  application_name = juju_application.graylog.name
  endpoint         = "beats"
}
