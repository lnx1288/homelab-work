variable cloud {
    type = string
    default = "home-maas"
}

variable "mk8s-machines" {
  type = list(object({
    machine_id = number
    constraints = string
  }))
}

variable mk8s-model-name {
    type = string
    default = "microk8s"
}

variable default-base {
    type = string
    default = "ubuntu@22.04"
}

variable oam-space {
    type = string
    default = "oam"
}

variable apt_mirror {
    type = string
    default = "192.168.1.12"
}

variable lxd-snap-channel {
    type = string
    default = "5.21/stable"
}

