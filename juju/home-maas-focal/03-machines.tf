resource "juju_machine" "all_machines" {
  for_each    = {
  for index, machine in var.machines:
  machine.machine_id => machine
  }
  model       = juju_model.openstack.name
  name        = each.value.machine_id
  constraints = each.value.constraints
}
