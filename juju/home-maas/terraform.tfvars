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

osd-devices = "/dev/sdb /dev/sdc"
data-port = "br-data:ens9"
bridge-mappings = "physnet1:br-data"
dns-servers = "192.168.1.13"
