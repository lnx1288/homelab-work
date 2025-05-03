resource "openstack_compute_flavor_v2" "canonical_m1_xlarge_fio" {
  name      = "canonical.m1.xlarge.fio"
  ram       = "16384"
  vcpus     = "8"
  disk      = "160"
  is_public = true

  extra_specs = {
    "hw:cpu_policy"        = "dedicated",
    "hw:cpu_thread_policy" = "prefer"
    "hw:numa_nodes"        = "1"
  }
}
