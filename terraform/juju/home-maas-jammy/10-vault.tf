resource "juju_machine" "vault" {
  count       = var.num_units
  model       = var.model-name
  placement   = join(":",["lxd",juju_machine.all_machines[var.sdn_ids[count.index]].machine_id])
  constraints = "spaces=oam"
}

resource "juju_application" "vault" {
  name = "vault"

  model = var.model-name

  charm {
    name    = "vault"
    channel = var.vault_channel
    base    = var.default-base
    revision = 319
  }

  machines = [
    for res in juju_machine.vault :
      res.machine_id
  ]

  config = {
    vip            = var.vips["vault"]
    nagios_context = var.nagios-context
    auto-generate-root-ca-cert = "true"
  }

}

resource "juju_application" "vault-mysql-router" {
  name = "vault-mysql-router"

  model = var.model-name

  charm {
    name    = "mysql-router"
    channel = var.mysql-router-channel
  }

  endpoint_bindings = [
    {
      space    = var.oam-space
    },{
      endpoint = "shared-db"
      space    = var.internal-space
    },{
      endpoint = "db-router"
      space    = var.internal-space
    },
  ]

  config = {
    source = var.openstack-origin
  }
}

resource "juju_application" "hacluster-vault" {
  name = "hacluster-vault"

  model = var.model-name

  charm {
    name     = "hacluster"
    channel  = var.hacluster-channel
  }
}


resource "juju_machine" "etcd" {
  count       = var.num_units
  model       = var.model-name
  placement   = join(":",["lxd",juju_machine.all_machines[var.sdn_ids[count.index]].machine_id])
  constraints = "spaces=oam"
}

resource "juju_application" "etcd" {
  name = "etcd"

  model = var.model-name

  charm {
    name     = "etcd"
    channel  = var.etcd_channel
    base     = var.default-base
    #revision = var.etcd_revision
  }

  machines = [
    for res in juju_machine.etcd :
      res.machine_id
  ]

  endpoint_bindings = [{
    space    = var.oam-space
  },{
    space    = var.internal-space
    endpoint = "cluster"
  },{
    space    = var.internal-space
    endpoint = "db"
  }]

  config = {
    channel = "3.2/stable"
  }
}

resource "juju_machine" "easyrsa" {
  model       = var.model-name
  placement   = join(":",["lxd",juju_machine.all_machines["402"].machine_id])
  constraints = "spaces=oam"
}

resource "juju_application" "easyrsa" {
  name = "easyrsa"

  model = var.model-name

  charm {
    name    = "easyrsa"
    channel = var.easyrsa_channel
    base    = var.default-base
  }

  machines = [ juju_machine.easyrsa.machine_id ]

  endpoint_bindings = [{space = var.oam-space}]
}

resource "juju_integration" "vault-etcd" {

  model = var.model-name

  application {
    name     = juju_application.vault.name
    endpoint = "etcd"
  }

  application {
    name     = juju_application.etcd.name
    endpoint = "db"
  }
}

resource "juju_integration" "etcd-easyrsa" {

  model = var.model-name

  application {
    name     = juju_application.etcd.name
    endpoint = "certificates"
  }

  application {
    name     = juju_application.easyrsa.name
    endpoint = "client"
  }
}

resource "juju_integration" "vault-ha" {

  model = var.model-name

  application {
    name     = juju_application.vault.name
    endpoint = "ha"
  }

  application {
    name     = juju_application.hacluster-vault.name
    endpoint = "ha"
  }
}

resource "juju_integration" "vault-mysql" {

  model = var.model-name

  application {
    name     = juju_application.vault.name
    endpoint = "shared-db"
  }

  application {
    name     = juju_application.vault-mysql-router.name
    endpoint = "shared-db"
  }
}

resource "juju_integration" "vault-ceph" {

  model = var.model-name

  application {
    name     = juju_application.vault.name
    endpoint = "secrets"
  }

  application {
    name     = juju_application.ceph-osd.name
    endpoint = "secrets-storage"
  }
}

resource "juju_integration" "vault-db" {

  model = var.model-name

  application {
    name     = juju_application.vault-mysql-router.name
    endpoint = "db-router"
  }

  application {
    name     = juju_application.mysql-innodb-cluster.name
    endpoint = "db-router"
  }
}

locals {
  cert_apps = [
    "ceph-radosgw",
    "cinder",
    "glance",
    "heat",
    "keystone",
    "mysql-innodb-cluster",
    "neutron-api",
    "neutron-api-plugin-ovn",
    "nova-cloud-controller",
    "openstack-dashboard",
    "ovn-central",
    "ovn-chassis",
    "placement",
  ]

}

resource "juju_integration" "vault-cert" {
  for_each = toset(local.cert_apps)

  model = var.model-name

  application {
    name     = juju_application.vault.name
    endpoint = "certificates"
  }

  application {
    name     = each.value
    endpoint = "certificates"
  }
}

