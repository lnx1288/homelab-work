resource "openstack_images_image_v2" "manila-service-image" {
  name             = "manila-service-image"
  local_file_path  = "/home/arif/images/manila-service-image-master.qcow2"
  container_format = "bare"
  disk_format      = "qcow2"
  visibility       = "public"

  properties = {
    key = "value"
  }
}

resource "openstack_compute_flavor_v2" "manila-service-flavor" {
  name      = "manila-service-flavor"
  ram       = "256"
  vcpus     = "1"
  disk      = "0"
  flavor_id = "100"
}

resource "openstack_compute_keypair_v2" "manila-service" {
  name       = "manila-service"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDHuq15h5hmPijTuICx4tO9DFYro++XDigw9Jh1osYrYJxTU4jwhRVvJGqrLOfTG8tl1VMAs4xQ6RGDVsWmbOpSfjtQ93D2Ovz6AnNQx+cEJwOA7DzE3MhDWHijKu5ev5oq/tWkW9wEV0NTzsPyOsqUd8bQIRn86bb7X9/bPKzXJ4r4+vdtF3bRhqEi7gdFGedUiQ/OEGVBfKxxt++jejs6vwcU7ljiZnvECXA6myo5e+nJLxNND2wF1zhjncYwJLX6EdU07K3ZRihcDKmqFb4KE/5W2Ot7RiDcnkrANBqjl6nU8N2UiY5pTHMaCBWSDfS+kWIXiX7arqHFB9uYBCd5r8XoX6ajSn2rFlsnvHwOKQK4uZ1GcDjwImXMrFzUJ6rnmFB3kl+VVpjzyMQiviA5AOZcC4X3PonjQHYweTs6wF89YXO0pD2vzBnU/HTmsrgE22yFFq7s63oq+wlTHPlXfAxLpF3cMPaG1hrEaAwvE1BiKQ6bUT1cxg7qtK73i59YiiTNQI2Ka3mp8oxASwk7Cgr/X+NWgpbXsBQODKM6750JAt1YRlsR71jxmehCrwj16ojWlxNghF9T5hePlgWEMueJ8pPkSGKv6s07Hmf/Hgs6oBSNcr7LiTvirAyVAGV3gQCAteP9YmN7BmNGFGz4CGpBUL1/nJlADteS2IOuNQ=="
}

