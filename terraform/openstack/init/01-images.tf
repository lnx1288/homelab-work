resource "openstack_images_image_v2" "cirros" {
  name             = "cirros"
  local_file_path  = "/root/cirros-0.6.3-x86_64-disk.img"
  container_format = "bare"
  disk_format      = "qcow2"
  visibility       = "public"
}

resource "openstack_images_image_v2" "bionic-raw" {
  name             = "bionic-raw"
  local_file_path  = "/root/bionic-server-cloudimg-amd64.img"
  container_format = "bare"
  disk_format      = "raw"
  visibility       = "public"
}

resource "openstack_images_image_v2" "focal-raw" {
  name             = "focal-raw"
  local_file_path  = "/root/focal-server-cloudimg-amd64.img"
  container_format = "bare"
  disk_format      = "raw"
  visibility       = "public"
}

resource "openstack_images_image_v2" "jammy-raw" {
  name             = "jammy-raw"
  local_file_path  = "/root/jammy-server-cloudimg-amd64.img"
  container_format = "bare"
  disk_format      = "raw"
  visibility       = "public"
}

resource "openstack_images_image_v2" "noble-raw" {
  name             = "noble-raw"
  local_file_path  = "/root/noble-server-cloudimg-amd64.img"
  container_format = "bare"
  disk_format      = "raw"
  visibility       = "public"
}

#resource "openstack_images_image_v2" "win2k12-r2-raw" {
#  name             = "win2k12-r12-raw"
#  local_file_path  = "/home/alejandro/images/windows_server_2012_r2_standard_eval_kvm_20170321.img"
#  container_format = "bare"
#  disk_format      = "raw"
#  visibility       = "public"
#  properties = {
#    "hypervisor_type" = "QEMU"
#    "os_type" = "windows"
#  }
#}
