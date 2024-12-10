resource "juju_machine" "microk8s" {
  for_each    = {
  for index, machine in var.microk8s-machines:
  machine.machine_id => machine
  }
  model       = juju_model.microk8s.name
  name        = each.value.machine_id
  constraints = each.value.constraints
  base        = each.value.base
}
