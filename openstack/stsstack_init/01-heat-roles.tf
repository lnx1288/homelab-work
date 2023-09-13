resource "openstack_identity_user_v3" "heat_domain_admin" {
  domain_id = var.heat_domain_id
  name = "heat_domain_admin"

  password = "Ht8NdKTGdpJjRsS4V33tsVW4mSztgZMs" # leader-get heat-domain-admin-passwd
}

resource "openstack_identity_role_assignment_v3" "heat_admin_role_assignment" {
  domain_id  = var.heat_domain_id
  user_id    = openstack_identity_user_v3.heat_domain_admin.id
  role_id    = data.openstack_identity_role_v3.admin.id
}

resource "openstack_identity_role_v3" "heat_stack_user" {
  name = "heat_stack_user"
}
