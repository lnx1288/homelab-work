resource "juju_application" "nova-compute-kvm" {
  name = "nova-compute-kvm"

  model = var.model-name

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

   endpoint_bindings = [{
     space = "oam"
   },{
     space = "oam"
     endpoint = "internal"
   }]

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
       #cpu-mode = "custom"
       #cpu-model = "EPYC-IBPB"
       #cpu-model-extra-flags = "svm,pcid"
       pci-passthrough-whitelist = jsonencode([
         {vendor_id: "1af4", product_id: "1000", address: "00:08.0"},
         {vendor_id: "1af4", product_id: "1000", address: "00:07.0"},
         {vendor_id: "1af4", product_id: "1000", address: "00:06.0"},
       ])
       pci-alias = jsonencode({
         vendor_id: "1af4",
         product_id: "1000",
         device_type: "type-PCI",
         name: "arifpass",
         numa_policy: "preferred"
       })

  }
}

resource "juju_application" "ceilometer-agent" {
  name = "ceilometer-agent"

  model = var.model-name

  charm {
    name     = "ceilometer-agent"
    channel  = "ussuri/stable"
  }

  units = 0

  config = {
    use-internal-endpoints = "true"
  }
}

resource "juju_application" "neutron-openvswitch" {
  name = "neutron-openvswitch"

  model = var.model-name

  charm {
    name     = "neutron-openvswitch"
    channel  = "ussuri/stable"
  }

  units = 0

  endpoint_bindings = [{
    space = "oam"
  },{
    space = "oam"
    endpoint = "data"
  }]

  config = {
      data-port                      = "br-data:ens9"
      dns-servers                    = "192.168.1.13"
      enable-local-dhcp-and-metadata = "true"
      firewall-driver                = "openvswitch"
      worker-multiplier              = "0"
  }

}

resource "juju_application" "sysconfig-compute" {
  name = "sysconfig-compute"

  model = var.model-name

  charm {
    name     = "sysconfig"
    channel  = "latest/stable"
    revision = "19"
  }

  units = 0

  config = {
#      enable-iommu = "false"
      governor     = "performance"
      enable-pti   = "on"
      update-grub  = "true"
      enable-tsx   = "true"
  }
}

resource "juju_integration" "compute-ceilometer" {

  model = var.model-name

  application {
    name = juju_application.nova-compute-kvm.name
    endpoint = "nova-ceilometer"
  }

  application {
    name = juju_application.ceilometer-agent.name
    endpoint = "nova-ceilometer"
  }
}

resource "juju_integration" "compute-ovs" {

  model = var.model-name

  application {
    name = juju_application.neutron-openvswitch.name
    endpoint = "neutron-plugin"
  }

  application {
    name = juju_application.nova-compute-kvm.name
    endpoint = "neutron-plugin"
  }
}

resource "juju_integration" "compute-sysconfig" {

  model = var.model-name

  application {
    name = juju_application.nova-compute-kvm.name
    endpoint = "juju-info"
  }

  application {
    name = juju_application.sysconfig-compute.name
    endpoint = "juju-info"
  }
}

resource "juju_integration" "compute-ceph-mon" {

  model = var.model-name

  application {
    name = juju_application.nova-compute-kvm.name
    endpoint = "ceph"
  }

  application {
    name = juju_application.ceph-mon.name
    endpoint = "client"
  }
}

resource "juju_integration" "neutron-api-ovs" {

  model = var.model-name

  application {
    name = juju_application.neutron-openvswitch.name
    endpoint = "neutron-plugin-api"
  }

  application {
    name = juju_application.neutron-api.name
    endpoint = "neutron-plugin-api"
  }
}

resource "juju_integration" "nova-compute-rmq" {

  model = var.model-name

  application {
    name = juju_application.nova-compute-kvm.name
    endpoint = "amqp"
  }

  application {
    name = juju_application.rabbitmq-server.name
    endpoint = "amqp"
  }
}

resource "juju_integration" "neutron-ovs-rmq" {

  model = var.model-name

  application {
    name = juju_application.neutron-openvswitch.name
    endpoint = "amqp"
  }

  application {
    name = juju_application.rabbitmq-server.name
    endpoint = "amqp"
  }
}

resource "juju_integration" "ceilometer-agent-rmq" {

  model = var.model-name

  application {
    name = juju_application.ceilometer-agent.name
    endpoint = "amqp"
  }

  application {
    name = juju_application.rabbitmq-server.name
    endpoint = "amqp"
  }
}

resource "juju_integration" "nova-compute-glance" {

  model = var.model-name

  application {
    name = juju_application.nova-compute-kvm.name
    endpoint = "image-service"
  }

  application {
    name = juju_application.glance.name
    endpoint = "image-service"
  }
}

resource "juju_integration" "nova-compute-cinder-ceph" {

  model = var.model-name

  application {
    name = juju_application.nova-compute-kvm.name
    endpoint = "ceph-access"
  }

  application {
    name = juju_application.cinder-ceph.name
    endpoint = "ceph-access"
  }
}
