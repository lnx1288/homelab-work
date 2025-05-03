resource "openstack_blockstorage_volume_type_v3" "cinder-t1" {
  name        = "cinder-t1"
  description = "Cinder Ceph type"
  is_public   = true
  extra_specs = {
      volume_backend_name = "cinder-ceph"
  }
}

resource "openstack_blockstorage_volume_type_v3" "cinder-t2" {
  name        = "cinder-t2"
  description = "Cinder Ceph pool2 type"
  is_public   = true
  extra_specs = {
      volume_backend_name = "cinder-ceph-pool2"
  }
}
