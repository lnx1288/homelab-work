######## vars to change as per env
variable cloud {
    type = string
    default = "home-maas"
}

variable num_units {
    type = number
    default = 3
}

variable controller_ids {
  type    = list(string)
  default = ["100", "101", "102",
             "103", "104", "105"]
}

variable compute_ids {
  type    = list(string)
  default = ["1000", "1001", "1002", "1003",
             "1004", "1005", "1006", "1007"]
}

variable sdn_ids {
  type    = list(string)
  default = ["400", "401", "402"]
}

variable apt_mirror {
    type = string
    default = "192.168.1.12"
}

variable "all_services" {
  type    = list(string)
  default = [
    "easyrsa",
    "etcd",
    "ceilometer",
    "ceph-mon",
#    "ceph-osd",
    "ceph-radosgw",
    "cinder",
    "glance",
    "gnocchi",
    "heat",
    "keystone",
    "memcached",
    "mysql-innodb-cluster",
    "neutron-api",
    "neutron-gateway",
    "nova-compute-kvm",
    "nova-cloud-controller",
    "openstack-dashboard",
    "placement",
    "rabbitmq-server",
    "vault",
  ]
}

######## vars unlikely to be changed
variable "machines" {
  type = list(object({
    machine_id = number
    constraints = string
  }))
}

variable model-name {
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

variable mysql-router-channel {
    type = string
    default = "8.0/stable"
}

variable hacluster-channel {
    type = string
    default = "2.0.3/stable"
}

variable rabbitmq-server-channel {
    type = string
    default = "3.8/stable"
}

variable ceph-channel {
    type = string
    default = "octopus/stable"
}

variable lxd-snap-channel {
    type = string
    default = "5.0/stable"
}

variable "sysconfig_channel" {
    type = string
    default = "latest/stable"
}

variable "sysconfig_revision" {
    type = string
    default = "22"
}

variable "ubuntu_channel" {
    type = string
    default = "latest/stable"
}

variable "ubuntu_revision" {
    type = string
    default = "24"
}

variable "vault_channel" {
    type = string
    default = "1.7/stable"
}

variable "etcd_channel" {
    type = string
    default = "latest/stable"
}

variable "etcd_revision" {
    type = string
    default = "583"
}

variable "easyrsa_channel" {
    type = string
    default = "latest/stable"
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
