resource "openstack_images_image_v2" "cirros" {
  name             = "cirros"
  image_source_url  = "https://download.cirros-cloud.net/${var.cirros_version}/cirros-${var.cirros_version}-x86_64-disk.img"
  container_format = "bare"
  disk_format      = "qcow2"
  visibility       = "public"
  web_download     = true
}

resource "openstack_images_image_v2" "ubuntu_raw" {
  for_each = toset(var.ubuntu_releases)

  name             = "${each.key}-raw"
  image_source_url = "https://cloud-images.ubuntu.com/${each.key}/current/${each.key}-server-cloudimg-amd64.img"
  container_format = "bare"
  disk_format      = "raw"
  visibility       = "public"
  web_download     = true
}

#resource "openstack_images_image_v2" "win2k12-r2-raw" {
#  name             = "win2k12-r12-raw"
#  image_source_url  = "/home/alejandro/images/windows_server_2012_r2_standard_eval_kvm_20170321.img"
#  container_format = "bare"
#  disk_format      = "raw"
#  visibility       = "public"
#  properties = {
#    "hypervisor_type" = "QEMU"
#    "os_type" = "windows"
#  }
#}

