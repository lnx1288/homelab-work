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
                                |.10 (enp1s0)
                                |
                                |
     +--------------------------+------------------------+
     |           Gigabit Switch 192.168.100.0/24         |
     +---------------------------------------------------+
      |     |         |     |        |      |           |
      |     |         | (enp3s0 & enp1s0)   |           |
      |     |         |     |        |      |           |
      |     |         |     |        |      |           |
      |     |         |     |        |      |           |
      |     |         |     |        |      |           |
      |.11  |.12      |.13  |.14     |.15   |.16        |.17
     +---+---+       +---+---+      +---+---+   +----+----+
     | mini1 |       | mini2 |      | mini3 |   | asusrog |
     +---+---+       +---+---+      +---+---+   +----+----+
```

### Subnets/VLANs

  * LAN: 192.168.100.0/24 (vlan 1, untagged)
  * OAM: 10.0.1.0/24 (vlan 300, tagged)
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

## Node config

### Orchestrator

#### Network config

```
                            Internet
                                |
                                |192.168.68.63
    +---------------------------+---------------------------+
    |                      orchestrator                     |
    |                                                       |
    |                  +--------+--------+                  |
    |                  |  maas container |                  |
    |                  +--------+--------+                  |
    |                           | 192.168.100.122           |
    |                           |                           |
    |                      +----+----+                      |
    |                      |  lxdbr0 |  (NAT = true)        |
    |                      +----+----+                      |
    |                           | 192.168.100.250           |
    +---------------------------+---------------------------+
                                |192.168.100.10 (enp1s0)
                                |
                            Internal
```

#### Tasks

  * Install OS (manual) ---> OK
  * Create Ubuntu mirror in LXD (Ansible) ---> OK
  * Hardening (Ansible)
  * Network config (Ansible) ---> OK
  * Install and initialize MAAS (Ansible) ---> OK
  * Generate API key (Ansible) ---> OK
  * Commission lab nodes (Manual)
    * Define networking layout (ask Arif since I have two NICs)
    * Define disk layout
    * virtualized or physical deployment? (MAAS autobuilder or custom deployment on my own)

### Nodes

#### Tasks

  * Provision OS via MAAS (Script)
  * If custom build:
    * Deploy MAAS + Juju + Openstack control plane in the 3 mini PCs (Terraform)
    * Deploy Nova in compute node (laptop) (Terraform)
  * If maas autobuilder:
    * Deploy all the infra in the 4 nodes (revisit the service to host mapping and remove unnecessary services)
  * Hardening

## Deploy the lab

### Scenario 1: everything from scratch

    * Change the Ansible var file as needed
    * Run:

        ```
        sudo apt update; sudo apt install ansible -y
        cd ansible
        ansible-playbook -i inventory/hosts.yaml playbooks/init_config.yaml --ask-become-pass
        ansible-playbook -i inventory/hosts.yaml playbooks/maas.yaml --ask-become-pass
        ```
    * Copy the API key to the Tf init.tf file

#### Playbooks explained

  * __`init_config.yaml`__:
    * Install the tooling in the orchestrator node
    * Configures the orchestrator networking
    * Sets up LXD and creates the MAAS container
    * Copies all scripts and configs to the MAAS container
    * Runs `scripts/bootstrap-maas.sh -b` to install MAAS, do initial MAAS configs and import images

## Known Issues

  * __MAAS/LXD race condition__: Because of [LP#1995194](https://bugs.launchpad.net/ubuntu/+source/lxd/+bug/1995194), for the time being we need to stop the `maas` snap services to be able to initialize LXD, hence why it's better to start by creating the mirror container. __NOTE__: This is only needed if there's a local mirror to be set up via `mirror.yaml` and if MAAS is being installed via `maas.yaml` (neither of these is true at the moment since I'm using `bootstrap-maas.sh`).