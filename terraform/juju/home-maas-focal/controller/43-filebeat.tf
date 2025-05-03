resource "juju_application" "filebeat-ctrl" {
  name = "filebeat"

  model = data.juju_model.controller.name

  charm {
    name     = "filebeat"
    channel  = "latest/stable"
    base     = var.default-base
  }

  units = 0

  endpoint_bindings = [{
    space    = var.oam-space
  }]

  config = {
      logpath = "/var/log/*.log /var/log/*/*.log /var/log/syslog"
      install_sources = <<-EOF
        - 'deb http://192.168.1.12/artifacts.elastic.co/packages/6.x/apt stable main'
        EOF
      install_keys = <<-EOF
        - |
          -----BEGIN PGP PUBLIC KEY BLOCK-----
          Version: SKS 1.1.6
          Comment: Hostname: keyserver.ubuntu.com
          mQENBFI3HsoBCADXDtbNJnxbPqB1vDNtCsqhe49vFYsZN9IOZsZXgp7aHjh6CJBDA+bGFOwy
          hbd7at35jQjWAw1O3cfYsKAmFy+Ar3LHCMkV3oZspJACTIgCrwnkic/9CUliQe324qvObU2Q
          RtP4Fl0zWcfb/S8UYzWXWIFuJqMvE9MaRY1bwUBvzoqavLGZj3SF1SPO+TB5QrHkrQHBsmX+
          Jda6d4Ylt8/t6CvMwgQNlrlzIO9WT+YN6zS+sqHd1YK/aY5qhoLNhp9G/HxhcSVCkLq8SStj
          1ZZ1S9juBPoXV1ZWNbxFNGwOh/NYGldD2kmBf3YgCqeLzHahsAEpvAm8TBa7Q9W21C8vABEB
          AAG0RUVsYXN0aWNzZWFyY2ggKEVsYXN0aWNzZWFyY2ggU2lnbmluZyBLZXkpIDxkZXZfb3Bz
          QGVsYXN0aWNzZWFyY2gub3JnPokBOAQTAQIAIgUCUjceygIbAwYLCQgHAwIGFQgCCQoLBBYC
          AwECHgECF4AACgkQ0n1mbNiOQrRzjAgAlTUQ1mgo3nK6BGXbj4XAJvuZDG0HILiUt+pPnz75
          nsf0NWhqR4yGFlmpuctgCmTD+HzYtV9fp9qW/bwVuJCNtKXk3sdzYABY+Yl0Cez/7C2GuGCO
          lbn0luCNT9BxJnh4mC9h/cKI3y5jvZ7wavwe41teqG14V+EoFSn3NPKmTxcDTFrV7SmVPxCB
          cQze00cJhprKxkuZMPPVqpBS+JfDQtzUQD/LSFfhHj9eD+Xe8d7sw+XvxB2aN4gnTlRzjL1n
          TRp0h2/IOGkqYfIG9rWmSLNlxhB2t+c0RsjdGM4/eRlPWylFbVMc5pmDpItrkWSnzBfkmXL3
          vO2X3WvwmSFiQbkBDQRSNx7KAQgA5JUlzcMW5/cuyZR8alSacKqhSbvoSqqbzHKcUQZmlzNM
          KGTABFG1yRx9r+wa/fvqP6OTRzRDvVS/cycws8YX7Ddum7x8uI95b9ye1/Xy5noPEm8cD+hp
          lnpU+PBQZJ5XJ2I+1l9Nixx47wPGXeClLqcdn0ayd+v+Rwf3/XUJrvccG2YZUiQ4jWZkoxsA
          07xx7Bj+Lt8/FKG7sHRFvePFU0ZS6JFx9GJqjSBbHRRkam+4emW3uWgVfZxuwcUCn1ayNgRt
          KiFv9jQrg2TIWEvzYx9tywTCxc+FFMWAlbCzi+m4WD+QUWWfDQ009U/WM0ks0KwwEwSk/UDu
          ToxGnKU2dQARAQABiQEfBBgBAgAJBQJSNx7KAhsMAAoJENJ9ZmzYjkK0c3MIAIE9hAR20mqJ
          WLcsxLtrRs6uNF1VrpB+4n/55QU7oxA1iVBO6IFu4qgsF12JTavnJ5MLaETlggXY+zDef9sy
          TPXoQctpzcaNVDmedwo1SiL03uMoblOvWpMR/Y0j6rm7IgrMWUDXDPvoPGjMl2q1iTeyHkMZ
          EyUJ8SKsaHh4jV9wp9KmC8C+9CwMukL7vM5w8cgvJoAwsp3Fn59AxWthN3XJYcnMfStkIuWg
          R7U2r+a210W6vnUxU4oN0PmMcursYPyeV0NX/KQeUeNMwGTFB6QHS/anRaGQewijkrYYoTNt
          fllxIu9XYmiBERQ/qPDlGRlOgVTd9xUfHFkzB52c70E=
          =92oX
          -----END PGP PUBLIC KEY BLOCK-----
        EOF
  }
}

resource "juju_integration" "filebeat-ctrl-integration" {

  model = data.juju_model.controller.name

  application {
    name     = juju_application.filebeat-ctrl.name
    endpoint = "beats-host"
  }

  application {
    name     = juju_application.juju-server.name
    endpoint = "juju-info"
  }
}

resource "juju_integration" "filebeat-ctrl-graylog" {

  model = data.juju_model.controller.name

  application {
    name     = juju_application.filebeat-ctrl.name
    endpoint = "logstash"
  }

  application {
    offer_url = juju_offer.graylog.url
  }
}
