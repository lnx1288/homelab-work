resource "openstack_compute_keypair_v2" "arif-key" {
  name       = "arif-key"
  public_key = file("/home/arif/.ssh/aarsa4096canonical.pub")
}

resource "openstack_identity_role_v3" "tenantLead" {
  name = "tenantLead"
}
