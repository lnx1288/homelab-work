resource "juju_application" "juju-server" {
  name = "juju-server"

  model = data.juju_model.controller.name

  charm {
    name     = "ubuntu"
    channel  = var.ubuntu_channel
    revision = var.ubuntu_revision
    base     = var.default-base
  }

  units = 3

  placement = "${join(",", sort([
      data.juju_machine.c0.machine_id,
      data.juju_machine.c1.machine_id,
      data.juju_machine.c2.machine_id,
  ]))}"
}
