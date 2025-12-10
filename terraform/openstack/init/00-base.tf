resource "openstack_compute_keypair_v2" "alejandro-key" {
  name       = "alejandro-key"
  public_key = file("/root/.ssh/id_rsa.pub")
}

resource "openstack_identity_role_v3" "tenantLead" {
  name = "tenantLead"
}
