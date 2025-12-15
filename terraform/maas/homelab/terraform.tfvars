spaces = [
  {
    space="external",
    vid=1,
    cidr="192.168.2.0/24",
    mtu=1500,
    managed=false
    ip_range = [{
      type = "reserved"
      start_ip = "192.168.2.241"
      end_ip = "192.168.2.254"
      comment = "Servers"
    }]
  },
  {
    space="oam",
    vid=300,
    cidr="10.0.1.0/24",
    mtu=1500,
    managed=true,
    ip_range = [
      {
        type = "dynamic"
        start_ip = "10.0.1.1"
        end_ip = "10.0.1.99"
        comment = "Dynamic"
      },
      {
        type = "reserved"
        start_ip = "10.0.1.241"
        end_ip = "10.0.1.254"
        comment = "Servers"
      },
      {
        type = "reserved"
        start_ip = "10.0.1.211"
        end_ip = "10.0.1.225"
        comment = "OpenStack VIPs"
      }
    ]
  },
  {
    space="ceph-access",
    vid=301,
    cidr="10.0.2.0/24",
    mtu=1500,
    managed=true,
    ip_range = [
      {
        type = "dynamic"
        start_ip = "10.0.2.1"
        end_ip = "10.0.2.99"
        comment = "Dynamic"
      },
      {
        type = "reserved"
        start_ip = "10.0.2.241"
        end_ip = "10.0.2.254"
        comment = "Servers"
      }
    ]
  },
  {
    space="ceph-replica",
    vid=302,
    cidr="10.0.3.0/24",
    mtu=1500,
    managed=true,
    ip_range = [
      {
        type = "dynamic"
        start_ip = "10.0.3.1"
        end_ip = "10.0.3.99"
        comment = "Dynamic"
      },
      {
        type = "reserved"
        start_ip = "10.0.3.241"
        end_ip = "10.0.3.254"
        comment = "Servers"
      }
    ]
  },
  {
    space="overlay",
    vid=303,
    cidr="10.0.4.0/24",
    mtu=1500,
    managed=true,
    ip_range = [
      {
        type = "dynamic"
        start_ip = "10.0.4.1"
        end_ip = "10.0.4.99"
        comment = "Dynamic"
      },
      {
        type = "reserved"
        start_ip = "10.0.4.241"
        end_ip = "10.0.4.254"
        comment = "Servers"
      }
    ]
  },
  {
    space="admin",
    vid=304,
    cidr="10.0.5.0/24",
    mtu=1500,
    managed=true,
    ip_range = [
      {
        type = "dynamic"
        start_ip = "10.0.5.1"
        end_ip = "10.0.5.99"
        comment = "Dynamic"
      },
      {
        type = "reserved"
        start_ip = "10.0.5.241"
        end_ip = "10.0.5.254"
        comment = "Servers"
      }
    ]
  },
  {
    space="internal",
    vid=305,
    cidr="10.0.6.0/24",
    mtu=1500,
    managed=true,
    ip_range = [
      {
        type = "dynamic"
        start_ip = "10.0.6.1"
        end_ip = "10.0.6.99"
        comment = "Dynamic"
      },
      {
        type = "reserved"
        start_ip = "10.0.6.241"
        end_ip = "10.0.6.254"
        comment = "Servers"
      }
    ]
  },
  {
    space="add-new-test",
    vid=306,
    cidr="10.0.7.0/24",
    mtu=1500,
    managed=true,
    ip_range = []
  }
]

minipc_machines = [
  {
     host_name = "mini01",
     power_type = "manual",
     mac_addr = "c8:ff:bf:04:09:fe"
  },
  {
     host_name = "mini02",
     power_type = "manual",
     mac_addr = "c8:ff:bf:04:0f:00"
  },
  {
     host_name = "mini03",
     power_type = "manual",
     mac_addr = "c8:ff:bf:05:9d:f3"
  }
  #{
  #   host_name = "asusrog",
  #   power_type = "manual",
  #   mac_addr = "70:4d:7b:3e:40:dd"
  #}
]
