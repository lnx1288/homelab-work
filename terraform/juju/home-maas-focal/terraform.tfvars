openstack-model-name = "cpe-focal"

machines = [
  {machine_id=100,constraints="tags=control,mini01"},
  {machine_id=101,constraints="tags=control,mini02"},
  {machine_id=102,constraints="tags=control,mini03"},
  {machine_id=103,constraints="tags=control,mini01"},
  {machine_id=104,constraints="tags=control,mini02"},
  {machine_id=105,constraints="tags=control,mini03"},
  {machine_id=400,constraints="tags=compute,mini01"},
  {machine_id=401,constraints="tags=compute,mini02"},
  {machine_id=402,constraints="tags=compute,mini03"},
  {machine_id=1000,constraints="tags=compute,mini01"},
  {machine_id=1001,constraints="tags=compute,mini01"},
  {machine_id=1002,constraints="tags=compute,mini02"},
  {machine_id=1003,constraints="tags=compute,mini02"},
  {machine_id=1004,constraints="tags=compute,mini03"},
  {machine_id=1005,constraints="tags=compute,mini03"},
  {machine_id=1006,constraints="tags=compute,mini04"},
  {machine_id=1007,constraints="tags=compute,mini04"},
]

lma-machines = [
  {machine_id=200,constraints="tags=compute,mini01"},
  {machine_id=201,constraints="tags=compute,mini04"},
  {machine_id=202,constraints="tags=compute,mini02"},
  {machine_id=300,constraints="tags=compute,mini04",base="ubuntu@18.04"},
  {machine_id=301,constraints="tags=compute,mini03",base="ubuntu@18.04"},
  {machine_id=302,constraints="tags=compute,mini01",base="ubuntu@18.04"},
]

infra-machines = [
  {machine_id=0,name="mini01"},
  {machine_id=1,name="mini02"},
  {machine_id=2,name="mini03"},
  {machine_id=3,name="mini04"},
]

osd-devices    = "/dev/sdb /dev/sdc"

nagios-context = "alejandro-nc01"

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

ntp-source               = "192.168.100.11"
external-network-cidr    = "192.168.100.0/24"
external-network-gateway = "192.168.100.249"
dns-servers              = "192.168.100.13"

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

etcd_channel = "1.29/stable"
