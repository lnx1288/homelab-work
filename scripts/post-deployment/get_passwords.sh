#!/bin/bash

. functions.sh
check_juju_version

keystone_passwd=$(${juju_run} -u keystone/leader 'leader-get admin_passwd')
nagios_passwd=$(${juju_run} -u nagios/leader 'sudo cat /var/lib/juju/nagios.passwd')
grafana_passwd=$(${juju_run_action} grafana/leader get-admin-password | grep password | awk '{print $2}')
graylog_passwd=$(${juju_run_action} graylog/leader show-admin-password | grep admin-password | awk '{print $2}')
mysql_passwd=$(${juju_run} -u mysql/leader 'leader-get root-password')
innodb_admin_passwd=$(${juju_run} -u mysql-innodb-cluster/leader 'leader-get mysql.passwd')
innodb_cluster_passwd=$(${juju_run} -u mysql-innodb-cluster/leader 'leader-get cluster-password')

echo "Keystone admin password: ... ${keystone_passwd}"
echo "nagios password: ... ${nagios_passwd}"
echo "grafana password: ... ${grafana_passwd}"
echo "graylog password: ... ${graylog_passwd}"
echo "percona admin password: ... ${mysql_passwd}"
echo "mysql admin password: ... ${innodb_admin_passwd}"
echo "mysql cluster password: ... ${innodb_cluster_passwd}"
