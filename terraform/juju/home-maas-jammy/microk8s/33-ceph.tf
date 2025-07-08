resource "juju_application" "mk8s-ceph-osd" {
  name = "ceph-osd"

  model = juju_model.microk8s.name

  charm {
    name    = "ceph-osd"
    channel = var.ceph-channel
    base    = var.default-base
  }

  machines = [
    for res in juju_machine.microk8s :
        res.machine_id
  ]

  config = {
    osd-devices     = var.osd-devices
  }
}

resource "juju_machine" "mk8s-ceph-mon" {
  count       = length(juju_machine.microk8s)
  model       = juju_model.microk8s.name
  placement   = join(":", ["lxd", juju_machine.microk8s[var.k8s_ids[count.index]].machine_id])
  constraints = "spaces=oam"
  base        = var.default-base
}

resource "juju_application" "mk8s-ceph-mon" {
  name = "ceph-mon"

  model = juju_model.microk8s.name

  charm {
    name     = "ceph-mon"
    channel  = var.ceph-channel
    base     = var.default-base
  }

  machines = [
    for res in juju_machine.mk8s-ceph-mon :
        res.machine_id
  ]

  endpoint_bindings = [{
    space    = var.oam-space
  }]

  config = {
      expected-osd-count = 6
      monitor-count      = 3
  }
}

resource "juju_application" "mk8s-ceph-csi" {
  name = "ceph-csi"

  model = juju_model.microk8s.name

  charm {
    name    = "ceph-csi"
    channel = "1.28/stable"
    base    = var.default-base
  }

  config = {
    provisioner-replicas = 1
    namespace = "kube-system"
  }
}

resource "juju_integration" "mk8s-osd-mon" {

  model = juju_model.microk8s.name

  application {
    name     = juju_application.mk8s-ceph-osd.name
    endpoint = "mon"
  }

  application {
    name     = juju_application.mk8s-ceph-mon.name
    endpoint = "osd"
  }
}

resource "juju_integration" "mk8s-csi-mon" {

  model = juju_model.microk8s.name

  application {
    name     = juju_application.mk8s-ceph-csi.name
    endpoint = "ceph-client"
  }

  application {
    name     = juju_application.mk8s-ceph-mon.name
    endpoint = "client"
  }
}

resource "juju_integration" "mk8s-csi-k8s" {

  model = juju_model.microk8s.name

  application {
    name     = juju_application.mk8s-ceph-csi.name
    endpoint = "kubernetes-info"
  }

  application {
    name     = juju_application.microk8s.name
    endpoint = "kubernetes-info"
  }
}
