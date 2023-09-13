resource "openstack_identity_project_v3" "heat_domain" {
    name          = "heat"
    description   = "(tf managed) Domain for heat"
    enabled       = true
    is_domain     = true
}

resource "openstack_identity_user_v3" "heat_domain_admin" {
  domain_id = openstack_identity_project_v3.heat_domain.id
  name = "heat_domain_admin"

  password = "Ht8NdKTGdpJjRsS4V33tsVW4mSztgZMs" # leader-get heat-domain-admin-passwd
}

resource "openstack_identity_role_assignment_v3" "heat_admin_role_assignment" {
  domain_id  = openstack_identity_project_v3.heat_domain.id
  user_id    = openstack_identity_user_v3.heat_domain_admin.id
  role_id    = data.openstack_identity_role_v3.admin.id
}

resource "openstack_identity_role_v3" "heat_stack_user" {
  name = "heat_stack_user"
}
