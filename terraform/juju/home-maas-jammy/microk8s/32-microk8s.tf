resource "juju_application" "microk8s" {
  name = "microk8s"

  model = juju_model.microk8s.name

  charm {
    name     = "microk8s"
    channel  = "1.28/stable"
    base     = "ubuntu@22.04"
  }

  machines = [
    for res in juju_machine.microk8s :
        res.machine_id
  ]


   endpoint_bindings = [{
     space    = var.oam-space
   }]
}
