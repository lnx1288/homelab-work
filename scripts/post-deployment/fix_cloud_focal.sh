#!/bin/bash

# Used for debugging
# set -ax

# This script is required after a reboot of the cloud after the cloud has been
# shut down

. functions.sh
check_juju_version

juju-wait -v ${model}

get_juju_status

# Check if we're using percona-cluster and/or mysql-innodb-cluster
percona_cluster=$(jq -r ".applications | to_entries[] | select(.value[\"charm-name\"] == \"percona-cluster\") | .key" "${juju_status_out}")
mysql_innodb_cluster=$(jq -r ".applications | to_entries[] | select(.value[\"charm-name\"] == \"mysql-innodb-cluster\") | .key" "${juju_status_out}")

if [[ -n "${percona_cluster}" ]] ; then
  do_percona_cluster
fi

if [[ -n "${mysql_innodb_cluster}" ]] ; then
  do_mysql_innodb_cluster
fi

${juju_run} -u elasticsearch/leader -- sudo systemctl restart elasticsearch &
${juju_run} -a heat -- sudo systemctl restart heat-engine &
${juju_run} -a ceph-radosgw -- 'sudo systemctl restart ceph-radosgw@*' &

wait

# cleanup all crm resources
jq -r ".applications | to_entries[] | select(.value[\"charm-name\"] == \"hacluster\") | .key" "${juju_status_out}" \
    | xargs -I{} ${juju_run} -u "{}"/leader -- 'sudo crm_resource -l | sed s/:.*//g | uniq | xargs -i sudo crm resource cleanup \"\{\}\"'

do_vault restart

# remove DNS entry for external network
${juju_run} --all -- "sudo sed -i -e s/192.168.1.13,//g -e s/192.168.1.9,//g /etc/netplan/99-juju.yaml"
${juju_run} --all -- "sudo netplan apply ; sudo systemctl restart systemd-resolved"

do_ceph

lds_servers=$(jq -rc ". | .applications[\"landscape-server\"].units | to_entries[] | .key" "${juju_status_out}")

cat > /tmp/restart-landscape.sh << EOF
#!/bin/bash

sudo systemctl restart landscape-*
EOF

for lds_server in ${lds_servers}
do
  ${juju_scp} /tmp/restart-landscape.sh "${lds_server}":.
  ${juju_ssh} "${lds_server}" chmod +x restart-landscape.sh
  ${juju_ssh} "${lds_server}" sudo ./restart-landscape.sh &
done

wait

[[ $LMA_SERVERS == "off" ]] && ${juju_run} -m lma --all -- sudo halt -p
