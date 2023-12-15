resource "juju_application" "neutron-gateway" {
  name = "neutron-gateway"

  model = juju_model.cpe-focal.name

  charm {
    name     = "neutron-gateway"
    channel  = "ussuri/stable"
  }

  units = 3
  placement = "${join(",",sort([
    juju_machine.all_machines["100"].machine_id,
    juju_machine.all_machines["101"].machine_id,
    juju_machine.all_machines["102"].machine_id,
   ]))}"


  config = {
       worker-multiplier        = var.worker-multiplier
       openstack-origin         = var.openstack-origin
       bridge-mappings          = var.bridge-mappings
       data-port                = var.data-port
       aa-profile-mode          = "enforce"
       dns-servers              = var.dns-servers
       customize-failure-domain = var.customize-failure-domain
  }
}


