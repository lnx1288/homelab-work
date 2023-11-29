locals {
  spaces = ["external","oam","ceph-access","ceph-replica","overlay","admin","internal"]
}

resource "maas_space" "maas_spaces" {

  for_each = toset(local.spaces)
  name = each.value

}

resource "maas_fabric" "fabric-0" {

  name = "fabric-0"

}
