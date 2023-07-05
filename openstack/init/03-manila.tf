resource "openstack_images_image_v2" "manila-service-image" {
  name             = "manila-service-image"
  local_file_path  = "/home/arif/images/manila-service-image-master.qcow2"
  container_format = "bare"
  disk_format      = "qcow2"
  visibility       = "public"
}

resource "openstack_compute_flavor_v2" "manila-service-flavor" {
  name      = "manila-service-flavor"
  ram       = "256"
  vcpus     = "1"
  disk      = "0"
  flavor_id = "100"
  is_public = true
}

resource "openstack_compute_keypair_v2" "manila-service" {
  name       = "manila-service"
  public_key = file("/home/arif/.ssh/aarsa4096canonical.pub")
}
