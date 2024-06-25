resource "juju_machine" "all_machines" {
  for_each    = {
  for index, machine in var.machines:
  machine.machine_id => machine
  }
  model       = var.model-name
  name        = each.value.machine_id
  constraints = each.value.constraints
}
