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
