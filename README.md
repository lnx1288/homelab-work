## Prep Hardware

* Plug all nodes (incl. orchestrator) into the physical switch.
* Ensure:

  * All nodes have their NICs connected
  * BIOS on all nodes:
    * Boot order: PXE first
    * Secure Boot: OFF
    * UEFI: Enabled

## Node config

### Orchestrator

  * Install OS ---> OK
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

  * Provision OS via MAAS (Manual)
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
        ansible-playbook -i inventory/hosts.yaml playbooks/mirror.yaml --ask-become-pass
        ansible-playbook -i inventory/hosts.yaml playbooks/maas.yaml --ask-become-pass
        ```
    * Copy the API key to the Tf init.tf file


## Known Issues

Because of [LP#1995194](https://bugs.launchpad.net/ubuntu/+source/lxd/+bug/1995194), for the time being we need to stop the `maas` snap services to be able to initialize LXD, hence why it's better to start by creating the mirror container.