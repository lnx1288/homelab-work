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
             "100", "101", "102"]
}

variable compute_ids {
  type    = list(string)
  default = ["1000", "1001", "1002"]
}

variable sdn_ids {
  type    = list(string)
  default = ["400", "401", "402"]
}

variable k8s_ids {
  type    = list(string)
  default = ["300", "301", "302"]
}

variable "all_services" {
  type    = list(string)
  default = [
    "easyrsa",
    "etcd",
#    "ceilometer",
    "ceph-mon",
#    "ceph-osd",
    "ceph-radosgw",
    "cinder",
    "glance",
#    "gnocchi",
    "heat",
    "keystone",
    "memcached",
    "mysql-innodb-cluster",
    "neutron-api",
#    "neutron-gateway",
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
    base = optional(string)
  }))
}

variable "lma-machines" {
  type = list(object({
    machine_id = number
    constraints = string
    base = optional(string)
  }))
}

variable "microk8s-machines" {
  type = list(object({
    machine_id = number
    constraints = string
    base = optional(string)
  }))
}

variable "cinder-lvm-machines" {
  type = list(object({
    machine_id = number
    constraints = string
    base = optional(string)
  }))
}
variable infra-machines {
  type    = list(string)
  default = []
}

variable model-name {
    type = string
    default = "openstack"
}

variable infra-model-name {
    type = string
    default = "infra"
}

variable lma-model-name {
    type = string
    default = "lma"
}

variable microk8s-model-name {
    type = string
    default = "microk8s"
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
    default = "yoga/stable"
}

variable ovn-channel {
    type = string
    default = "22.03/stable"
}

variable default-base {
    type = string
    default = "ubuntu@22.04"
}

variable default-series {
    type = string
    default = "jammy"
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
    default = "2.4/stable"
}

variable rabbitmq-server-channel {
    type = string
    default = "3.9/stable"
}

variable ceph-channel {
    type = string
    default = "quincy/stable"
}

variable lxd-snap-channel {
    type = string
    default = "5.21/stable"
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
    default = "1.8/stable"
}

variable "etcd_channel" {
    type = string
    default = "1.29/stable"
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

variable nagios-context {
    type = string
    default = ""
}

variable mysql-connections {
    type = string
    default = "4000"
}

variable mysql-tuning-level {
    type = string
    default = "safest"
}

variable vips {
    type = map(string)
    default = {}
}

variable domain {
    type = string
    default = "openstack.local"
}

variable fqdn-int {
    type = map(string)
    default = {}
}

variable fqdn-admin {
    type = map(string)
    default = {}
}

variable fqdn-pub {
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
    type = string
    default = "16.0"
}

variable ram-allocation-ratio {
    type = string
    default = "2.0"
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
    type = string
    default = "0"
}

variable expected-mon-count {
    type = string
    default = "3"
}
