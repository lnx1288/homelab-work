#!/bin/bash

NODE=$1

usage() { 
    echo "Usage: ${0} [node-name]" 1>&2
    exit 0
}

get_pci(){
    RO_MYSQL_UNIT=$(juju status --format json | jq -r '[.applications."mysql-innodb-cluster".units | to_entries[]|  select(.value."workload-status".message | contains("R/O")) | .key] | .[0]')
    PASSWORD=$(juju run --unit mysql-innodb-cluster/leader leader-get mysql.passwd)

    juju ssh $RO_MYSQL_UNIT "sudo mysql -u root -p$PASSWORD -e \"select pci_stats,hypervisor_hostname from nova.compute_nodes where hypervisor_hostname like '%$NODE%' and deleted_at is NULL\G;\""
}

if [ $# -ne 1 ]; then
    usage
else
    get_pci
fi
