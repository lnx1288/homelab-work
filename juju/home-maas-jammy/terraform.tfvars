model-name = "cpe-jammy"

machines = [
  {machine_id=100,constraints="tags=control,asrock01"},
  {machine_id=101,constraints="tags=control,asrock02"},
  {machine_id=102,constraints="tags=control,asrock03"},
  {machine_id=103,constraints="tags=control,asrock04"},
  {machine_id=104,constraints="tags=control,asrock02"},
  {machine_id=105,constraints="tags=control,asrock03"},
  {machine_id=400,constraints="tags=compute,asrock01"},
  {machine_id=401,constraints="tags=compute,asrock02"},
  {machine_id=402,constraints="tags=compute,asrock03"},
  {machine_id=1000,constraints="tags=compute,asrock01"},
  {machine_id=1001,constraints="tags=compute,asrock01"},
  {machine_id=1002,constraints="tags=compute,asrock02"},
  {machine_id=1003,constraints="tags=compute,asrock02"},
  {machine_id=1004,constraints="tags=compute,asrock03"},
  {machine_id=1005,constraints="tags=compute,asrock03"},
  {machine_id=1006,constraints="tags=compute,asrock04"},
  {machine_id=1007,constraints="tags=compute,asrock04"},
]

osd-devices    = "/dev/sdb /dev/sdc"

nagios-context = "arif-nc01"

ram-allocation-ratio = 1.0
cpu-allocation-ratio = 2.0

oam-space          = "oam"
admin-space        = "oam"
public-space       = "oam"
internal-space     = "oam"
ceph-public-space  = "ceph-access"
ceph-cluster-space = "ceph-replica"
overlay-space      = "overlay"

expected-osd-count = 12
expected-mon-count = 3

ntp-source               = "192.168.1.11"
external-network-cidr    = "192.168.1.0/24"
external-network-gateway = "192.168.1.249"
dns-servers              = "192.168.1.13"

data-port       = "br-data:ens9"
bridge-mappings = "physnet1:br-data"

vips = {
  aodh        = "10.0.1.211"
  cinder      = "10.0.1.212"
  dashboard   = "10.0.1.213"
  glance      = "10.0.1.214"
  heat        = "10.0.1.215"
  keystone    = "10.0.1.216"
  neutron-api = "10.0.1.218"
  nova-cc     = "10.0.1.219"
  gnocchi     = "10.0.1.220"
  contrail    = "10.0.1.221"
  vault       = "10.0.1.222"
  placement   = "10.0.1.223"
  radosgw     = "10.0.1.224"
}

fqdn-pub = {
  aodh        = "aodh"
  cinder      = "cinder"
  dashboard   = "dashboard"
  glance      = "glance"
  heat        = "heat"
  keystone    = "keystone"
  neutron-api = "neutron"
  nova-cc     = "nova"
  gnocchi     = "gnocchi"
  vault       = "vault"
  placement   = "placement"
  radosgw     = "swift"
}
fqdn-int = {
  aodh        = "aodh-int"
  cinder      = "cinder-int"
  dashboard   = "dashboard-int"
  glance      = "glance-int"
  heat        = "heat-int"
  keystone    = "keystone-int"
  neutron-api = "neutron-int"
  nova-cc     = "nova-int"
  gnocchi     = "gnocchi-int"
  vault       = "vault-int"
  placement   = "placement-int"
  radosgw     = "swift-int"
}

fqdn-admin = {
  aodh        = "aodh-int"
  cinder      = "cinder-int"
  dashboard   = "dashboard-int"
  glance      = "glance-int"
  heat        = "heat-int"
  keystone    = "keystone-int"
  neutron-api = "neutron-int"
  nova-cc     = "nova-int"
  gnocchi     = "gnocchi-int"
  vault       = "vault-int"
  placement   = "placement-int"
  radosgw     = "swift-int"
}

