data "juju_machine" "c0" {
    model      = data.juju_model.controller.name
    machine_id = "0"
}
data "juju_machine" "c1" {
    model      = data.juju_model.controller.name
    machine_id = "1"
}
data "juju_machine" "c2" {
    model      = data.juju_model.controller.name
    machine_id = "2"
}
