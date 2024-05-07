variable "machines" {
  type = list(object({
    machine_id = number
    constraints = string
  }))
}

variable "model-name" {
    type = string
    default = "openstack"
}

variable openstack-origin {
    type = string
    default = "distro"
}

variable openstack-region {
    type = string
    default = "RegionOne"
}

variable openstack-channel {
    type = string
    default = "ussuri/stable"
}

variable default-base {
    type = string
    default = "ubuntu@20.04"
}

variable mysql-channel {
    type = string
    default = "8.0/stable"
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
    type = number
    default = 512
}

variable worker-multiplier {
    type = number
    default = 0.25
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

variable nagios-context {
    type = string
    default = ""
}

variable mysql-connections {
    type = number
    default = 4000
}

variable mysql-tuning-level {
    type = string
    default = "safest"
}

variable vips {
    type = map(string)
    default = {}
}

variable oam-space {
    type = string
    default = "oam"
}

variable admin-space {
    type = string
    default = "admin"
}

variable public-space {
    type = string
    default = "public"
}

variable internal-space {
    type = string
    default = "internal"
}

variable ceph-public-space {
    type = string
    default = "ceph-public"
}

variable ceph-cluster-space {
    type = string
    default = "ceph-cluster"
}

variable overlay-space {
    type = string
    default = "overlay"
}

variable external-network-gateway {
    type = string
    default = ""
}

variable cpu-allocation-ratio {
    type = number
    default = 16.0
}

variable ram-allocation-ratio {
    type = number
    default = 2.0
}

variable ntp-source {
    type = string
    default = ""
}

variable external-network-cidr {
    type = string
    default = ""
}

variable expected-osd-count {
    type = number
    default = 0
}

variable expected-mon-count {
    type = number
    default = 3
}

