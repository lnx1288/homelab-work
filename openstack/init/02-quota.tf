data "openstack_identity_project_v3" "admin" {
  name = "admin"
  domain_id = var.domain_id
}

resource "openstack_networking_quota_v2" "network_quota_1" {
  project_id          = data.openstack_identity_project_v3.admin.id
  floatingip          = 100
  network             = 100
  port                = 100
  security_group      = 500
  security_group_rule = 500
  subnet              = 100
}

resource "openstack_compute_quotaset_v2" "compute_quota_1" {
  project_id           = data.openstack_identity_project_v3.admin.id
  cores                = 100
  instances            = 100
}

resource "openstack_blockstorage_quotaset_v3" "block_quota_1" {
  project_id           = data.openstack_identity_project_v3.admin.id
  volumes              = 100
}
