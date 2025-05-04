resource "juju_application" "landscape-client-bionic" {
  name = "landscape-client-bionic"

  model = var.model-name

  charm {
    name     = "landscape-client"
    channel  = "latest/stable"
    revision = 44
  }

  units = 0

  endpoint_bindings = [{
    space    = var.oam-space
  }]

  config = {
      account-name = "standalone"
      install_sources = <<-EOF
        - "deb http://ppa.launchpad.net/landscape/19.10/ubuntu bionic main"
        EOF
      install_keys = <<-EOF
        - |
          -----BEGIN PGP PUBLIC KEY BLOCK-----
          Version: SKS 1.1.6
          Comment: Hostname: keyserver.ubuntu.com
          mI0ESXN/egEEAOgRYISU9dnQm4BB5ZEEwKT+NKUDNd/DhMYdtBMw9Yk7S5cyoqpbtwoPJVzK
          AXxq+ng5e3yYypSv98pLMr5UF09FGaeyGlD4s1uaVFWkFCO4jsTg7pWIY6qzO/jMxB5+Yu/G
          0GjWQMNKxFk0oHMa0PhNBZtdPacVz65mOVmCsh/lABEBAAG0G0xhdW5jaHBhZCBQUEEgZm9y
          IExhbmRzY2FwZYi2BBMBAgAgBQJJc396AhsDBgsJCAcDAgQVAggDBBYCAwECHgECF4AACgkQ
          boWobkZStOb+rwP+ONKUWeX+MTIPqGWkknBPV7jm8nyyIUojC4IhS+9YR6GYnn0hMABSkEHm
          IV73feKmrT2GESYI1UdYeKiOkWsPN/JyBk+eTvKet0qsw5TluqiHSW+LEi/+zUyrS3dDMX3o
          yaLgYa+UkjIyxnaKLkQuCiS+D+fYwnJulIkhaKObtdE=
          =UwRd
          -----END PGP PUBLIC KEY BLOCK-----
        EOF
      # registration-key =  file(../secrets/landscape-registration.txt)
      disable-unattended-upgrades = "true"
      # the reason that this has to be done manually is because Landscape server needs an admin user to be
      # created first (manual step, see above). Once the user and registration key is set configure the clients' url and ping-url options.
      #ping-url = http://landscape.example.com/ping
      #url = https://landscape.example.com/message-system
  }
}

resource "juju_application" "landscape-client" {
  name = "landscape-client"

  model = var.model-name

  charm {
    name     = "landscape-client"
    channel  = "latest/stable"
    revision = 44
  }

  units = 0

  endpoint_bindings = [{
    space    = var.oam-space
  }]

  config = {
      account-name = "standalone"
      #registration-key =  file(../secrets/landscape-registration.txt)
      disable-unattended-upgrades = "true"
      # the reason that this has to be done manually is because Landscape server needs an admin user to be
      # created first (manual step, see above). Once the user and registration key is set configure the clients' url and ping-url options.
      #ping-url = http://landscape.example.com/ping
      #url = https://landscape.example.com/message-system
  }
}

resource "juju_integration" "landscape-client-integration" {
  for_each = toset(var.all_services)

  model = var.model-name

  application {
    name     = juju_application.landscape-client.name
    endpoint = "container"
  }

  application {
    name     = "${each.value}"
    endpoint = "juju-info"
  }
}
