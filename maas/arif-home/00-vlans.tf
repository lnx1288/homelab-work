resource "maas_vlan" "maas_vlans" {
  for_each = {
    for index, spaces in var.spaces:
    spaces.space => spaces
  }

  space = maas_space.maas_spaces[each.value.space].name

  fabric = maas_fabric.fabric-0.id
  vid=each.value.vid
}

locals {
  ip_ranges = flatten([
    for space_key, space in var.spaces : [
      for ip_range_key, ip_range in space.ip_range : {
        space_key = space.space
        ip_range_key = ip_range_key
        type = ip_range.type
        start_ip = ip_range.start_ip
        end_ip = ip_range.end_ip
        comment = ip_range.comment
      }
    ]
  ])
}

resource "maas_subnet" "maas_subnets" {

  for_each = {
    for index, spaces in var.spaces:
    spaces.space => spaces
  }

  name = each.value.cidr

  cidr = each.value.cidr
  fabric = maas_fabric.fabric-0.id
  vlan = maas_vlan.maas_vlans[each.value.space].vid

  allow_dns = each.value.managed != false
}

resource "maas_subnet_ip_range" "dynamic_ip_ranges" {
    for_each = {
      for ip_range in local.ip_ranges:
      "${ip_range.space_key}.${ip_range.ip_range_key}" => ip_range
    }

    subnet = maas_subnet.maas_subnets[each.value.space_key].id
    type = each.value.type
    start_ip = each.value.start_ip
    end_ip = each.value.end_ip
    comment = each.value.comment == "Dynamic"?"":each.value.comment
}

