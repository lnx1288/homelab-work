variable openstack-origin {
    type = string
    default = "distro"
}

variable osd-devices {
    type = string
    default = ""
}

variable customize-failure-domain {
    type = string
    default = "true"
}

variable reserved-host-memory {
    type = string
    default = "512"
}

variable worker-multiplier {
    type = string
    default = "0.25"
}

variable bridge-mappings {
    type = string
    default = ""

}
variable data-port {
    type = string
    default = ""
}

variable dns-servers {
    type = string
    default = ""
}
