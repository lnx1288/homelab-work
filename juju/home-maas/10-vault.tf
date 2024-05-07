resource "juju_machine" "vault-1" {
  model = var.model-name
  placement = join(":",["lxd",juju_machine.all_machines["400"].machine_id])
  constraints = "spaces=oam"
}
resource "juju_machine" "vault-2" {
  model = var.model-name
  placement = join(":",["lxd",juju_machine.all_machines["401"].machine_id])
  constraints = "spaces=oam"
}
resource "juju_machine" "vault-3" {
  model = var.model-name
  placement = join(":",["lxd",juju_machine.all_machines["402"].machine_id])
  constraints = "spaces=oam"
}

resource "juju_application" "vault" {
  name = "vault"

  model = var.model-name

  charm {
    name     = "vault"
    channel  = "1.7/stable"
    base     = "ubuntu@20.04"
  }

  units = 3

  placement = "${join(",",sort([
    juju_machine.vault-1.machine_id,
    juju_machine.vault-2.machine_id,
    juju_machine.vault-3.machine_id,
  ]))}"

  config = {
    vip = "10.0.1.222"
    nagios_context = var.nagios-context
  }

}

resource "juju_application" "vault-mysql-router" {
  name = "vault-mysql-router"

  model = var.model-name

  charm {
    name = "mysql-router"
    channel = "8.0/stable"
  }

  units = 0

  endpoint_bindings = [
    {
      space = "oam"
    },{
      endpoint = "shared-db"
      space    = "oam"
    },{
      endpoint = "db-router"
      space    = "oam"
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
    channel  = "2.0.3/stable"
  }

  units = 0

}


resource "juju_machine" "etcd-1" {
  model = var.model-name
  placement = join(":",["lxd",juju_machine.all_machines["400"].machine_id])
  constraints = "spaces=oam"
}
resource "juju_machine" "etcd-2" {
  model = var.model-name
  placement = join(":",["lxd",juju_machine.all_machines["401"].machine_id])
  constraints = "spaces=oam"
}
resource "juju_machine" "etcd-3" {
  model = var.model-name
  placement = join(":",["lxd",juju_machine.all_machines["402"].machine_id])
  constraints = "spaces=oam"
}

resource "juju_application" "etcd" {
  name = "etcd"

  model = var.model-name

  charm {
    name     = "etcd"
    channel  = "latest/stable"
    base     = "ubuntu@20.04"
    revision = 583
  }

  placement = "${join(",",sort([
    juju_machine.etcd-1.machine_id,
    juju_machine.etcd-2.machine_id,
    juju_machine.etcd-3.machine_id,
  ]))}"

  endpoint_bindings = [{
    space = "oam"
  },{
    space = "oam"
    endpoint = "cluster"
  },{
    space = "oam"
    endpoint = "db"
  }]

  units = 3

  config = {
    channel = "3.2/stable"
  }
}

resource "juju_machine" "easyrsa" {
  model = var.model-name
  placement = join(":",["lxd",juju_machine.all_machines["402"].machine_id])
  constraints = "spaces=oam"
}

resource "juju_application" "easyrsa" {
  name = "easyrsa"

  model = var.model-name

  charm {
    name     = "easyrsa"
    channel  = "latest/stable"
    base     = "ubuntu@20.04"
  }

  placement = "${juju_machine.easyrsa.machine_id}"

  endpoint_bindings = [{space = "oam"}]

  units = 1
}

resource "juju_integration" "vault-etcd" {

  model = var.model-name

  application {
    name = juju_application.vault.name
    endpoint = "etcd"
  }

  application {
    name = juju_application.etcd.name
    endpoint = "db"
  }
}

resource "juju_integration" "etcd-easyrsa" {

  model = var.model-name

  application {
    name = juju_application.etcd.name
    endpoint = "certificates"
  }

  application {
    name = juju_application.easyrsa.name
    endpoint = "client"
  }
}

resource "juju_integration" "vault-ha" {

  model = var.model-name

  application {
    name = juju_application.vault.name
    endpoint = "ha"
  }

  application {
    name = juju_application.hacluster-vault.name
    endpoint = "ha"
  }
}

resource "juju_integration" "vault-mysql" {

  model = var.model-name

  application {
    name = juju_application.vault.name
    endpoint = "shared-db"
  }

  application {
    name = juju_application.vault-mysql-router.name
    endpoint = "shared-db"
  }
}

resource "juju_integration" "vault-ceph" {

  model = var.model-name

  application {
    name = juju_application.vault.name
    endpoint = "secrets"
  }

  application {
    name = juju_application.ceph-osd.name
    endpoint = "secrets-storage"
  }
}

resource "juju_integration" "vault-db" {

  model = var.model-name

  application {
    name = juju_application.vault-mysql-router.name
    endpoint = "db-router"
  }

  application {
    name = juju_application.mysql-innodb-cluster.name
    endpoint = "db-router"
  }
}
