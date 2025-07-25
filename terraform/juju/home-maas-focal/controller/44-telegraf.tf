resource "juju_application" "telegraf-ctrl" {
  name = "telegraf"

  model = data.juju_model.controller.name

  charm {
    name     = "telegraf"
    channel  = "latest/stable"
    base     = var.default-base
  }

  units = 0

  endpoint_bindings = [{
    space    = var.oam-space
  },{
    endpoint = "prometheus-client"
    space    = var.oam-space
  }]

  config = {
      socket_listener_port = "8095"
      install_sources = <<-EOF
        - 'deb http://ppa.launchpad.net/telegraf-devs/ppa/ubuntu focal main'
        EOF
      install_keys = <<-EOF
        - |
          -----BEGIN PGP PUBLIC KEY BLOCK-----
          Version: SKS 1.1.6
          Comment: Hostname: keyserver.ubuntu.com
          mQINBFcVSuIBEAC80aj0tAQ6+NhGV/bkSwu6Oj+BpDR50Be3uBv7ttdtvChL5zHTnaxjdK3h
          LKSyrDLlmSOkffQ2uO7CxvqeF09MsHhyvrDDx0EY54//xxoAB++PoB2OQqmqldg3Al5Hp4Dz
          rllV5CIX5PD8NGX8UpO3HXk5wEwn9G81l8cia3vPveU82EIkHMiJGpk6+L86OMlwXzxkSI3M
          xXgNFKQc+ELDYLvGSseYC9vPN3kdmFoo/UjznPPE4fxr4bXit3N8Abl1jYjBa0x6SWkK1BAb
          s8w3BXtvyk90z9Oyme69wPD4zAYfFp+kN2nDmTDBMtNCyMu9oatdI5SukMNK4Lcm8eAE6VNs
          04j7BKvGk9+17M8WP9Pw8nIisOwScS9gUlJlLUpnBaJ+sxoOvGQ4mzZxYMKzJh0E58aEX3bS
          AyzQfsae8bZLNOTcgotyzzIDJFF9npzu3wmKjeOt/706p4LiDqKUbQK6cI+QcJ/y80ZUK8pB
          M043ttSHWLmTBFX2drp6zQGae9+02fX89ZD+5c+MPlubJMYCCKkvQT4OssHfC+dVDQ66rwUy
          OObrzsVgikdpIxQVitL3J+Dms56xAkdFfoo+qdxxdv9S/eakc5mfavc/4WVvmFDaJiqJnJRR
          Ryw1zApRtuweEEdVn8niy1mahoKpWaw1pTI4AazjWI6xJH1JyQARAQABtB9MYXVuY2hwYWQg
          UFBBIGZvciBUZWxlZ3JhZiBEZXZziQI4BBMBAgAiBQJXFUriAhsDBgsJCAcDAgYVCAIJCgsE
          FgIDAQIeAQIXgAAKCRDxDL4ByUQG9UgbEACa4IzdeYxH/S5I6MrZfvWNo/JTZ/MZWDD+QlMW
          60ThAemCUSE+NJvZZ1q7ovGFpYnHJT9GQXOwJAX1quDUqyM1uXNmLlOyIVNnmjUTINoLhw2V
          iC8E7dMWC9w4Na2fKezmNHH00kNl43ncstIjjZ3pLnDGYm1y0ItiCUcTRgHhx2cUZ/vStz1S
          Pdqj4P3i8vuspoYJ2T3VPlM/0G+u9Yjuy3Uzu9RugOyO3UJPoi3+4O2VTNosSBy5MILVCp49
          eigyFVGpq5sT/c86qd1zqmsNWEubrlzDfETS4LMj9epr46ZKPXGQkeryt1m2Oe0HkIdNZ+IQ
          5p+i9fnEy7/1uKTXWQYsg2UWsLA2PvTvwY8JxxMhUFgv12q2w7STntqJyi9PLItYNtbtKoS3
          XZCCMqQLCWMXHY+2ol6rRSfs06H/wzlR8LjDaEXkDVuDmqMtcbgTboZYblsGxst7I/Y4Wgfi
          J52uiIyobQ69uJbG0XeRTLZ3WyrBkopEsTX/+sQjVqbADXYU4hBVDgnCf2uN/5dcwSEvDj8/
          +WsToAfEJkscRBsQjTLVzf+eFqHLrbqz/yoYIqBc//IJMBSbxIf5mrOHHLdbOuMCB6PVwpTI
          vLFOSDNPuVDX+S1goA8KJTnXpm8jWDynn3XaXx3AlYw4iZ0ETSgQLQLRd6JuPOEGXsGdBA==
          =ufaX
          -----END PGP PUBLIC KEY BLOCK-----
        EOF
      extra_plugins = <<-EOF
        [[inputs.exec]]
           commands = [ "/usr/bin/awk '{print int($1)}' /proc/uptime" ]
           name_override = "exec_uptime"
           data_format = "value"
        EOF
  }
}


resource "juju_integration" "telegraf-ctrl-integration" {

  model = data.juju_model.controller.name

  application {
    name     = juju_application.telegraf-ctrl.name
    endpoint = "juju-info"
  }

  application {
    name     = juju_application.juju-server.name
    endpoint = "juju-info"
  }
}

resource "juju_integration" "telegraf-ctrl-grafana" {

  model = data.juju_model.controller.name

  application {
    name     = juju_application.telegraf-ctrl.name
    endpoint = "dashboards"
  }

  application {
    offer_url = juju_offer.grafana.url
  }
}

resource "juju_integration" "telegraf-ctrl-prometheus" {

  model = data.juju_model.controller.name

  application {
    name     = juju_application.telegraf-ctrl.name
    endpoint = "prometheus-client"
  }

  application {
    offer_url = juju_offer.prometheus.url
  }
}
