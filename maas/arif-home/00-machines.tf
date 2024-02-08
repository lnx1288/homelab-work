resource "maas_machine" "asrock_machines" {

  for_each = {
    for index, asrock_machines in var.asrock_machines:
    asrock_machines.host_name => asrock_machines
  }

  power_parameters = {}

  power_type = each.value.power_type
  pxe_mac_address = each.value.mac_addr
  hostname = each.value.host_name
  zone = each.value.host_name
}
