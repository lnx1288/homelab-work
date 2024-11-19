resource "juju_application" "nova-compute-kvm" {
  name = "nova-compute-kvm"

  model = juju_model.openstack.name

  charm {
    name     = "nova-compute"
    channel  = var.openstack-channel
  }

  units = length(var.compute_ids)

  placement = "${join(",", sort([
    for index in var.compute_ids :
      juju_machine.all_machines[index].machine_id
  ]))}"

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
       #cpu-mode               = "custom"
       #cpu-model              = "EPYC-IBPB"
       #cpu-model-extra-flags  = "svm,pcid"
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

resource "juju_application" "neutron-openvswitch" {
  name = "neutron-openvswitch"

  model = juju_model.openstack.name

  charm {
    name     = "neutron-openvswitch"
    channel  = var.openstack-channel
  }

  units = 0

  endpoint_bindings = [{
    space    = var.oam-space
  },{
    space    = var.overlay-space
    endpoint = "data"
  }]

  config = {
      data-port                      = var.data-port
      dns-servers                    = var.dns-servers
      enable-local-dhcp-and-metadata = "true"
      firewall-driver                = "openvswitch"
      worker-multiplier              = var.worker-multiplier
  }
}

resource "juju_application" "sysconfig-compute" {
  name = "sysconfig-compute"

  model = juju_model.openstack.name

  charm {
    name     = "sysconfig"
    channel  = var.sysconfig_channel
    revision = var.sysconfig_revision
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

resource "juju_integration" "compute-ovs" {

  model = juju_model.openstack.name

  application {
    name     = juju_application.neutron-openvswitch.name
    endpoint = "neutron-plugin"
  }

  application {
    name     = juju_application.nova-compute-kvm.name
    endpoint = "neutron-plugin"
  }
}

resource "juju_integration" "compute-sysconfig" {

  model = juju_model.openstack.name

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

  model = juju_model.openstack.name

  application {
    name     = juju_application.nova-compute-kvm.name
    endpoint = "ceph"
  }

  application {
    name     = juju_application.ceph-mon.name
    endpoint = "client"
  }
}

resource "juju_integration" "neutron-api-ovs" {

  model = juju_model.openstack.name

  application {
    name     = juju_application.neutron-openvswitch.name
    endpoint = "neutron-plugin-api"
  }

  application {
    name     = juju_application.neutron-api.name
    endpoint = "neutron-plugin-api"
  }
}

resource "juju_integration" "nova-compute-rmq" {

  model = juju_model.openstack.name

  application {
    name     = juju_application.nova-compute-kvm.name
    endpoint = "amqp"
  }

  application {
    name     = juju_application.rabbitmq-server.name
    endpoint = "amqp"
  }
}

resource "juju_integration" "neutron-ovs-rmq" {

  model = juju_model.openstack.name

  application {
    name     = juju_application.neutron-openvswitch.name
    endpoint = "amqp"
  }

  application {
    name     = juju_application.rabbitmq-server.name
    endpoint = "amqp"
  }
}

resource "juju_integration" "nova-compute-glance" {

  model = juju_model.openstack.name

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

  model = juju_model.openstack.name

  application {
    name     = juju_application.nova-compute-kvm.name
    endpoint = "ceph-access"
  }

  application {
    name     = juju_application.cinder-ceph.name
    endpoint = "ceph-access"
  }
}
