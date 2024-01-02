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
