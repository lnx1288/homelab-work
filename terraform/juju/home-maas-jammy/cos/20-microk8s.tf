resource "juju_model" "microk8s" {
  name = var.mk8s-model-name

  cloud {
    name = var.cloud
  }

  config = {
    apt-mirror = "http://archive.ubuntu.com/ubuntu"
    lxd-snap-channel = var.lxd-snap-channel

    container-image-metadata-url = "http://lxd/"
    container-image-stream = "released"

    agent-metadata-url = "http://juju/tools/"
    agent-stream = "released"
  }
}


resource "juju_machine" "mk8s" {
  for_each    = {
  for index, machine in var.mk8s-machines:
  machine.machine_id => machine
  }
  model       = juju_model.microk8s.name
  name        = each.value.machine_id
  constraints = each.value.constraints
  #base        = each.value.base
}

resource "juju_application" "microk8s" {
  name = "microk8s"

  model = juju_model.microk8s.name

  charm {
    name     = "microk8s"
    channel  = "1.28/stable"
    base     = var.default-base
  }

  units = 4

  placement = "${join(",", sort([
    for res in juju_machine.mk8s :
        res.machine_id
  ]))}"

  config = {
    hostpath_storage = "true"
  }
}

resource "juju_application" "microceph" {
  name = "microceph"

  model = juju_model.microk8s.name

  endpoint_bindings = [{
    "space"  = var.oam-space
  }]

  charm {
    name     = "microceph"
    channel  = "latest/edge"
    base     = var.default-base
  }

  units = 4

  placement = "${join(",", sort([
    for res in juju_machine.mk8s :
        res.machine_id
  ]))}"

  config = {
    snap-channel = "latest/stable"
  }
}

resource "juju_machine" "cos-proxy" {
  model       = juju_model.microk8s.name
  placement = "${join(":",["lxd", tolist(sort([
     for res in juju_machine.mk8s :
         res.machine_id
  ]))[0]])}"
  constraints = "spaces=oam"
}

resource "juju_application" "cos-proxy" {
  name = "cos-proxy"

  model = juju_model.microk8s.name

  charm {
    name     = "cos-proxy"
    channel  = "latest/edge"
    base     = var.default-base
  }

  units = 1

  placement = juju_machine.cos-proxy.machine_id
}

resource "juju_application" "ntp" {
  name = "ntp"

  model = juju_model.microk8s.name

  charm {
    name     = "ntp"
    channel  = "latest/stable"
    base     = var.default-base
  }

  units = 0

  config = {
    pools              = "ntp.canonical.com"
    verify_ntp_servers = "true"
  }
}

resource "juju_integration" "ntp-k8s" {

  model = juju_model.microk8s.name

  application {
    name     = juju_application.microk8s.name
    endpoint = "juju-info"
  }

  application {
    name     = juju_application.ntp.name
    endpoint = "juju-info"
  }
}
