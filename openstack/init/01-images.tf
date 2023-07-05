resource "openstack_images_image_v2" "cirros" {
  name             = "cirros"
  local_file_path  = "/home/arif/images/cirros-0.5.1-x86_64-disk.img"
  container_format = "bare"
  disk_format      = "qcow2"
  visibility       = "public"
}

resource "openstack_images_image_v2" "bionic-raw" {
  name             = "bionic-raw"
  local_file_path  = "/home/arif/images/bionic-server-cloudimg-amd64-raw.img"
  container_format = "bare"
  disk_format      = "raw"
  visibility       = "public"
}

resource "openstack_images_image_v2" "focal-raw" {
  name             = "focal-raw"
  local_file_path  = "/home/arif/images/focal-server-cloudimg-amd64-raw.img"
  container_format = "bare"
  disk_format      = "raw"
  visibility       = "public"
}
