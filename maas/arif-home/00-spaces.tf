resource "maas_space" "maas_spaces" {

  for_each = {
    for index, spaces in var.spaces:
    spaces.space => spaces
  }

  name = each.value.space

}

resource "maas_fabric" "fabric-0" {

  name = "fabric-0"

}
