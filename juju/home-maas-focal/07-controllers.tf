resource "juju_application" "controller-server" {
  name = "controller-server"

  model = juju_model.openstack.name

  charm {
    name     = "ubuntu"
    channel  = var.ubuntu_channel
    revision = var.ubuntu_revision
    base     = var.default-base
  }

  units = length(var.controller_ids)

  placement = "${join(",", sort([
    for index in var.controller_ids :
      juju_machine.all_machines[index].machine_id
  ]))}"
}

resource "juju_application" "sysconfig-control" {
  name = "sysconfig-control"

  model = juju_model.openstack.name

  charm {
    name     = "sysconfig"
    channel  = var.sysconfig_channel
    revision = var.sysconfig_revision
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

  model = juju_model.openstack.name

  application {
    name     = juju_application.sysconfig-control.name
    endpoint = "juju-info"
  }

  application {
    name     = juju_application.controller-server.name
    endpoint = "juju-info"
  }
}
