resource "juju_machine" "vault" {
  count       = var.num_units
  model       = juju_model.openstack.name
  placement   = join(":",["lxd",juju_machine.all_machines[var.sdn_ids[count.index]].machine_id])
  constraints = "spaces=oam"
}

resource "juju_application" "vault" {
  name = "vault"

  model = juju_model.openstack.name

  charm {
    name    = "vault"
    channel = var.vault_channel
    base    = var.default-base
  }

  units = var.num_units

  placement = "${join(",",sort([
    for res in juju_machine.vault :
      res.machine_id
  ]))}"

  config = {
    vip            = var.vips["vault"]
    nagios_context = var.nagios-context
  }

}

resource "juju_application" "vault-mysql-router" {
  name = "vault-mysql-router"

  model = juju_model.openstack.name

  charm {
    name    = "mysql-router"
    channel = var.mysql-router-channel
  }

  units = 0

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

  model = juju_model.openstack.name

  charm {
    name     = "hacluster"
    channel  = var.hacluster-channel
  }

  units = 0
}


resource "juju_machine" "etcd" {
  count       = var.num_units
  model       = juju_model.openstack.name
  placement   = join(":",["lxd",juju_machine.all_machines[var.sdn_ids[count.index]].machine_id])
  constraints = "spaces=oam"
}

resource "juju_application" "etcd" {
  name = "etcd"

  model = juju_model.openstack.name

  charm {
    name     = "etcd"
    channel  = var.etcd_channel
    #revision = var.etcd_revision
    base     = var.default-base
  }

  placement = "${join(",",sort([
    for res in juju_machine.etcd :
      res.machine_id
  ]))}"

  endpoint_bindings = [{
    space    = var.oam-space
  },{
    space    = var.internal-space
    endpoint = "cluster"
  },{
    space    = var.internal-space
    endpoint = "db"
  }]

  units = var.num_units

  config = {
    channel = "3.2/stable"
  }
}

resource "juju_machine" "easyrsa" {
  model       = juju_model.openstack.name
  placement   = join(":",["lxd",juju_machine.all_machines["402"].machine_id])
  constraints = "spaces=oam"
}

resource "juju_application" "easyrsa" {
  name = "easyrsa"

  model = juju_model.openstack.name

  charm {
    name    = "easyrsa"
    channel = var.easyrsa_channel
    base    = var.default-base
  }

  placement = "${juju_machine.easyrsa.machine_id}"

  endpoint_bindings = [{space = var.oam-space}]

  units = 1
}

resource "juju_integration" "vault-etcd" {

  model = juju_model.openstack.name

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

  model = juju_model.openstack.name

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

  model = juju_model.openstack.name

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

  model = juju_model.openstack.name

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

  model = juju_model.openstack.name

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

  model = juju_model.openstack.name

  application {
    name     = juju_application.vault-mysql-router.name
    endpoint = "db-router"
  }

  application {
    name     = juju_application.mysql-innodb-cluster.name
    endpoint = "db-router"
  }
}
