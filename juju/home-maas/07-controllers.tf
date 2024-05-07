resource "juju_application" "controller-server" {
  name = "controller-server"

  model = var.model-name

  charm {
    name     = "ubuntu"
    channel  = "latest/stable"
    revision = "24"
    base     = var.default-base
  }

  units = 6
  placement = "${join(",",sort([
    juju_machine.all_machines["100"].machine_id,
    juju_machine.all_machines["101"].machine_id,
    juju_machine.all_machines["102"].machine_id,
    juju_machine.all_machines["103"].machine_id,
    juju_machine.all_machines["104"].machine_id,
    juju_machine.all_machines["105"].machine_id,
   ]))}"
}

resource "juju_application" "sysconfig-control" {
  name = "sysconfig-control"

  model = var.model-name

  charm {
    name     = "sysconfig"
    channel  = "latest/stable"
    revision = "22"
  }

  units = 0

  config = {
      governor     = "performance"
      enable-pti   = "on"
      update-grub  = "true"
      enable-tsx   = "true"
  }
}

resource "juju_integration" "control-sysconfig" {

  model = var.model-name

  application {
    name     = juju_application.sysconfig-control.name
    endpoint = "juju-info"
  }

  application {
    name     = juju_application.controller-server.name
    endpoint = "juju-info"
  }
}
