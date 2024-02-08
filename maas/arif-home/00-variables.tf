variable "spaces" {
  type = list(object({
    space   = string
    vid     = number
    cidr    = string
    mtu     = number
    managed = bool
    ip_range = list(object({
      type = string
      start_ip = string
      end_ip = string
      comment = string
    }))
  }))
}

variable "asrock_machines" {
  type = list(object({
    host_name = string
    power_type = string
    mac_addr = string
  }))
}
