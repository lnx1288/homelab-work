resource "juju_application" "nova-compute-kvm" {
  name = "nova-compute-kvm"

  model = var.model-name

  charm {
    name     = "nova-compute"
    channel  = var.openstack-channel
    base     = var.default-base
  }

  machines = [
    for index in var.compute_ids :
      juju_machine.all_machines[index].machine_id
  ]

   endpoint_bindings = [{
     space    = var.oam-space
   },{
     space    = var.internal-space
     endpoint = "internal"
   }]

  config = {
       openstack-origin       = var.openstack-origin
       enable-live-migration  = "true"
       enable-resize          = "true"
       migration-auth-type    = "ssh"
       use-internal-endpoints = "true"
       libvirt-image-backend  = "rbd"
       restrict-ceph-pools    = "false"
       aa-profile-mode        = "complain"
       virt-type              = "kvm"
       customize-failure-domain = var.customize-failure-domain
       reserved-host-memory   = var.reserved-host-memory
       cpu-allocation-ratio   = var.cpu-allocation-ratio
       ram-allocation-ratio   = var.ram-allocation-ratio
  }
}

resource "juju_application" "ovn-chassis" {
  name = "ovn-chassis"

  model = var.model-name

  charm {
    name     = "ovn-chassis"
    channel  = var.ovn-channel
  }

  endpoint_bindings = [{
    space    = var.oam-space
  }]

  config = {
      bridge-interface-mappings      = var.data-port
      ovn-bridge-mappings            = var.bridge-mappings
  }
}

resource "juju_application" "sysconfig-compute" {
  name = "sysconfig-compute"

  model = var.model-name

  charm {
    name     = "sysconfig"
    channel  = var.sysconfig_channel
    revision = var.sysconfig_revision
  }

  config = {
#      enable-iommu = "false"
      governor     = "performance"
      enable-pti   = "on"
      update-grub  = "true"
      enable-tsx   = "true"
  }
}

resource "juju_integration" "compute-ovn" {

  model = var.model-name

  application {
    name     = juju_application.ovn-chassis.name
    endpoint = "nova-compute"
  }

  application {
    name     = juju_application.nova-compute-kvm.name
    endpoint = "neutron-plugin"
  }
}

resource "juju_integration" "compute-sysconfig" {

  model = var.model-name

  application {
    name     = juju_application.nova-compute-kvm.name
    endpoint = "juju-info"
  }

  application {
    name     = juju_application.sysconfig-compute.name
    endpoint = "juju-info"
  }
}

resource "juju_integration" "compute-ceph-mon" {

  model = var.model-name

  application {
    name     = juju_application.nova-compute-kvm.name
    endpoint = "ceph"
  }

  application {
    name     = juju_application.ceph-mon.name
    endpoint = "client"
  }
}

resource "juju_integration" "chassis-central" {

  model = var.model-name

  application {
    name     = juju_application.ovn-chassis.name
    endpoint = "ovsdb"
  }

  application {
    name     = juju_application.ovn-central.name
    endpoint = "ovsdb"
  }
}

resource "juju_integration" "nova-compute-rmq" {

  model = var.model-name

  application {
    name     = juju_application.nova-compute-kvm.name
    endpoint = "amqp"
  }

  application {
    name     = juju_application.rabbitmq-server.name
    endpoint = "amqp"
  }
}

resource "juju_integration" "nova-compute-glance" {

  model = var.model-name

  application {
    name     = juju_application.nova-compute-kvm.name
    endpoint = "image-service"
  }

  application {
    name     = juju_application.glance.name
    endpoint = "image-service"
  }
}

resource "juju_integration" "nova-compute-cinder-ceph" {

  model = var.model-name

  application {
    name     = juju_application.nova-compute-kvm.name
    endpoint = "ceph-access"
  }

  application {
    name     = juju_application.cinder-ceph.name
    endpoint = "ceph-access"
  }
}
