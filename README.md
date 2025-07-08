## Network diagram

```
                             Internet
                                |
                  +---------------------------+
                  |     Wi-Fi Access Point    |
                  +------------+--------------+
                                |.1
                                |
                    ** WiFi ** ... 192.168.68.0/24 (wlp2s0)
                                |
                                |.63
                         +------+-------+
                         | orchestrator |  NAT (from internal to public for Internet access)
                         +------+-------+
                                |.63 (enp1s0) 
                                |
                                | port 8
     +--------------------------+------------------------+
     |            Gigabit Switch 10.0.1.0/24             |
     +---------------------------------------------------+
      |port 7         |port 5        |port 3           |port 1
      |               |              |                 |
      |               |              |                 |
      |               |              |                 |
      |               |              |                 |
      |               |              |                 |
      |.241           |.242          |.243             |.244
     +---+---+       +---+---+      +---+---+     +----+----+
     | mini1 |       | mini2 |      | mini3 |     | asusrog |
     +---+---+       +---+---+      +---+---+     +----+----+
```

```
                               Internet
                                   |
             192.168.68.63 (wlp2s0)|
    +------------------------------+----------+
    |     (static forwarding rule) |          | 
    | +----------------+     +-----+-----+    |
    | | maas container |     |    br0    |    |
    | |   10.0.1.253   |-----| 10.0.1.63 |    |
    | +----------------+     +-----+-----+    |
    | orchestrator                 |enp1s0    |
    +------------------------------+----------+
                                   |
                               Internal
```

On my machine, I had to add `sudo ip route add 10.0.1.0/24 via 192.168.68.63` so that I could reach my containers.

### Subnets/VLANs

  * OAM: 10.0.1.0/24 (vlan 300, untagged) -> PXE boot network
  * Ceph-access: 10.0.2.0/24 (vlan 301, tagged)
  * Ceph-replica: 10.0.3.0/24 (vlan 302, tagged)
  * Overlay: 10.0.4.0/24 (vlan 303, tagged)
  * Admin: 10.0.5.0/24 (vlan 304, tagged)
  * Internal: 10.0.6.0/24 (vlan 305, tagged)


## Prep Hardware

* Ensure:

  * BIOS on all nodes:
    * Boot order: PXE first, disk second
    * Secure Boot: OFF
    * UEFI: Enabled

## Deploy the lab

### Scenario 1: everything from scratch

    * Change the Ansible var file as needed
    * Run:

        ```
        sudo apt update; sudo apt install ansible -y
        cd ansible
        ansible-playbook -i inventory/hosts.yaml playbooks/init_config.yaml --ask-become-pass
        lxc exec maas -- bash -c "ansible-playbook -i inventory/hosts.yaml playbooks/maas.yaml"
        lxc exec maas -- bash -c "chmod +x scripts/bootstrap-maas.sh; ./scripts/bootstrap-maas.sh -b"
        lxc exec maas -- bash -x ./bootstrap-maas.sh -j home-maas
        ```
    * Copy the API key to the Tf init.tf file

#### Playbooks explained

  * __`init_config.yaml`__:
    * Install the tooling in the orchestrator node
    * Configures the orchestrator networking
    * Sets up LXD and creates the MAAS container
    * Copies all scripts and configs to the MAAS container

  * __`maas.yaml`__:
    * Installs MAAS, PostgreSQL and some other packages in the MAAS container


## Known Issues

  * __MAAS/LXD race condition__: Because of [LP#1995194](https://bugs.launchpad.net/ubuntu/+source/lxd/+bug/1995194), for the time being we need to stop the `maas` snap services to be able to initialize LXD, hence why it's better to start by creating the mirror container. __NOTE__: This is only needed if there's a local mirror to be set up via `mirror.yaml` and if MAAS is being installed via `maas.yaml`.