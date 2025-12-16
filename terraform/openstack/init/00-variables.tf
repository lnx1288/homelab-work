######## vars to change as per env
variable ubuntu_releases {
    type = list
    default = ["bionic", "focal", "jammy", "noble"]
}

variable cirros_version {
    type = string
    default = "0.6.3"
}