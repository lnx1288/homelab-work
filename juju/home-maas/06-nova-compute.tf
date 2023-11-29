resource "juju_application" "nova-compute" {
  name = "nova-compute"

  model = juju_model.cpe-focal.name

  charm {
    name     = "nova-compute"
    channel  = "ussuri/stable"
  }

  units = 8
  placement = "${join(",",sort([
    juju_machine.all_machines["1000"].machine_id,
    juju_machine.all_machines["1001"].machine_id,
    juju_machine.all_machines["1002"].machine_id,
    juju_machine.all_machines["1003"].machine_id,
    juju_machine.all_machines["1004"].machine_id,
    juju_machine.all_machines["1005"].machine_id,
    juju_machine.all_machines["1006"].machine_id,
    juju_machine.all_machines["1007"].machine_id,
   ]))}"


  config = {
       openstack-origin = var.openstack-origin
       enable-live-migration = "true"
       enable-resize = "true"
       migration-auth-type = "ssh"
       use-internal-endpoints = "true"
       libvirt-image-backend = "rbd"
       restrict-ceph-pools = "false"
       aa-profile-mode = "complain"
       virt-type = "kvm"
       customize-failure-domain = var.customize-failure-domain
       reserved-host-memory = var.reserved-host-memory
       cpu-mode = "custom"
       cpu-model = "EPYC-IBPB"
       cpu-model-extra-flags = "svm,pcid"

  }
}

resource "juju_application" "ceilometer-agent" {
  name = "ceilometer-agent"

  model = juju_model.cpe-focal.name

  charm {
    name     = "ceilometer-agent"
    channel  = "ussuri/stable"
  }

}

resource "juju_application" "neutron-openvswitch" {
  name = "neutron-openvswitch"

  model = juju_model.cpe-focal.name

  charm {
    name     = "neutron-openvswitch"
    channel  = "ussuri/stable"
  }

  config = {
      data-port                      = "br-data:ens9"
      dns-servers                    = "192.168.1.13"
      enable-local-dhcp-and-metadata = "true"
      firewall-driver                = "openvswitch"
      worker-multiplier              = "0"
  }

}

resource "juju_integration" "compute-ceilometer" {

  model = juju_model.cpe-focal.name

  application {
    name = juju_application.nova-compute.name
    endpoint = "nova-ceilometer"
  }

  application {
    name = juju_application.ceilometer-agent.name
    endpoint = "nova-ceilometer"
  }
}

resource "juju_integration" "compute-ovs" {

  model = juju_model.cpe-focal.name

  application {
    name = juju_application.nova-compute.name
    endpoint = "neutron-plugin"
  }

  application {
    name = juju_application.neutron-openvswitch.name
    endpoint = "neutron-plugin"
  }
}
