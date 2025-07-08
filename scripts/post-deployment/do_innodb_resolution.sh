#!/bin/bash

NODE=$1

set -ax

usage() { 
    echo "Usage: ${0} [node-name]" 1>&2
    exit 0
}

do_recovery() {
    juju_status=$(mktemp)
    juju status --format json > ${juju_status}

    MYSQL_UNIT=${NODE}
    RW_MYSQL_UNIT=$(jq -r '[.applications."mysql-innodb-cluster".units | to_entries[]|  select(.value."workload-status".message | contains("R/W")) | .key] | .[0]' ${juju_status})
    MYSQL_LEAD=$(jq -r '.applications."mysql-innodb-cluster".units | to_entries[] | select(.value.leader == true) | .key' ${juju_status})
    PASSWORD=$(juju run --unit mysql-innodb-cluster/leader leader-get mysql.passwd)

    MYSQL_UNIT_IP=$(jq -rc '.applications."mysql-innodb-cluster".units."'${NODE}'"."public-address"' ${juju_status})
    MYSQL_UNIT_IP_HYPHENS=$(echo ${MYSQL_UNIT_IP} | tr '.' '-')

    juju ssh ${MYSQL_UNIT} -- sudo systemctl stop mysql
    juju run-action --wait ${MYSQL_LEAD} remove-instance address=${MYSQL_UNIT_IP} force=true

    cat > init_mysql.sh << EOF
set -ax
systemctl stop mysql
cd /var/lib
mv mysql mysql.old.\$(date +%s)
mkdir mysql
chown mysql:mysql mysql
chmod 700 mysql
mysqld --initialize-insecure --user=mysql
systemctl restart mysql
EOF

    juju scp init_mysql.sh ${MYSQL_UNIT}:init_mysql.sh
    juju ssh ${MYSQL_UNIT} -- "chmod +x init_mysql.sh && sudo ./init_mysql.sh"

    #exit
    cat > set_password.sh << EOF
#!/bin/bash
set -ax

cat > /tmp/alter_command << EOF2
ALTER USER 'root'@'localhost' IDENTIFIED BY '${PASSWORD}';
EOF2

mysql -u root -e "source /tmp/alter_command"
EOF

    juju scp set_password.sh ${MYSQL_UNIT}:set_password.sh
    juju ssh ${MYSQL_UNIT} -- "chmod +x set_password.sh && sudo ./set_password.sh"

    juju run -u ${MYSQL_UNIT} -- charms.reactive clear_flag local.cluster.user-created
    juju run -u ${MYSQL_UNIT} -- charms.reactive clear_flag local.cluster.all-users-created
    juju run -u ${MYSQL_UNIT} -- ./hooks/update-status


    # just in case the remove-instance didn't unset these values
    juju run -u ${MYSQL_LEAD} leader-set cluster-instance-clustered-${MYSQL_UNIT_IP_HYPHENS}="" cluster-instance-configured-${MYSQL_UNIT_IP_HYPHENS}=""

    sleep 120

    juju run-action --wait ${MYSQL_LEAD} add-instance address=${MYSQL_UNIT_IP}
}

if [ $# -ne 1 ]; then
    usage
else
    do_recovery
fi
