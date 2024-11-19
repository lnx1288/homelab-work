resource "juju_machine" "infra_machines" {
  for_each    = {
  for index, machine in var.infra-machines:
  machine.machine_id => machine
  }
  model       = juju_model.infra.name
  name        = each.value.machine_id
  ssh_address = join("@", ["ubuntu", each.value.name])
  private_key_file = "~/.local/share/juju/ssh/juju_id_rsa"
  public_key_file = "~/.local/share/juju/ssh/juju_id_rsa.pub"
}
