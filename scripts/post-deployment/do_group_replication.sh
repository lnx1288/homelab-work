#!/bin/bash

NODE=$1

usage() { 
    echo "Usage: ${0} [node-name]" 1>&2
    exit 0
}

do_gr(){
    MYSQL_UNIT=${NODE}
    PASSWORD=$(juju run --unit mysql-innodb-cluster/leader leader-get mysql.passwd)

    juju ssh $MYSQL_UNIT "sudo mysql -u root -p$PASSWORD -e \"stop group_replication;\""
    sleep 5
    juju ssh $MYSQL_UNIT "sudo mysql -u root -p$PASSWORD -e \"start group_replication;\""
}

if [ $# -ne 1 ]; then
    usage
else
    do_gr
fi
