resource "maas_machine" "minipc_machines" {

  for_each = {
    for index, minipc_machines in var.minipc_machines:
    minipc_machines.host_name => minipc_machines
  }

  power_parameters = {}

  power_type = each.value.power_type
  pxe_mac_address = each.value.mac_addr
  hostname = each.value.host_name
  zone = each.value.host_name
}
