resource "juju_machine" "lma_machines" {
  for_each    = {
  for index, machine in var.lma-machines:
  machine.machine_id => machine
  }
  model       = juju_model.lma.name
  name        = each.value.machine_id
  constraints = each.value.constraints
  base        = each.value.base
}
