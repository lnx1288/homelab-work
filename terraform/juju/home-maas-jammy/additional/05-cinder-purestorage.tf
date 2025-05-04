resource "juju_application" "cinder-purestorage" {
  name = "cinder-purestorage"

  model = var.model-name

  charm {
    name    = "cinder-purestorage"
    channel = var.openstack-channel
  }

  units = 0

  config = {
    driver-source: "http://ppa.launchpadcontent.net/openstack-charmers/purestorage-stable/ubuntu jammy main"
    driver-key = <<-EOT
        -----BEGIN PGP PUBLIC KEY BLOCK-----

        mI0EUwTecAEEANePxwI2aWHW6cqp/uWMM9dHujQ76nbagdMQbTdpyV6khj6iJu5/
        2HJXnkxY/Y6AUIOFj1R4IAmkoKhY6Gu/4NatVmDyleKwkJv8PFv2UlRJuPMlRuwy
        PA/DpwCx0IPXR/co0vn1SeCEhdlJVckLTpxWzs2CSUDmoIox/8Mx3jV/ABEBAAG0
        JExhdW5jaHBhZCBQUEEgZm9yIE9wZW5TdGFjayBDaGFybWVyc4i4BBMBAgAiBQJT
        BN5wAhsDBgsJCAcDAgYVCAIJCgsEFgIDAQIeAQIXgAAKCRD+/WOfImcqefeXA/46
        mwC6Vgu5dMOn+OepZbx1fV9YtA0eni5GpcPgQbhPAkB5oUbSWSxNvlSece4HXAs1
        9K7Mz8ktH/gDDGarPjznjhbYT8mq0YynzzLt9t9fkdpxhxhx4SmraY8Qymzr5qvB
        Zek/Ak1B7Rx5cmZBRiG9I0ah5rFNB2jf4lEwWfV1ug==
        =h/5S
        -----END PGP PUBLIC KEY BLOCK-----
        EOT
  }
}

resource "juju_integration" "cinder-pure" {

  model = var.model-name

  application {
    name     = juju_application.cinder.name
    endpoint = "storage-backend"
  }

  application {
    name     = juju_application.cinder-purestorage.name
    endpoint = "storage-backend"
  }
}

