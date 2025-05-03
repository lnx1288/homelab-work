resource "juju_application" "infra-server" {
  name = "infra-server"

  model = juju_model.infra.name

  charm {
    name     = "ubuntu"
    channel  = var.ubuntu_channel
    revision = var.ubuntu_revision
    base     = "ubuntu@22.04"
  }

  units = length(var.infra-machines)

  placement = "${join(",", sort([
    for res in juju_machine.infra_machines :
        res.machine_id
  ]))}"
}
