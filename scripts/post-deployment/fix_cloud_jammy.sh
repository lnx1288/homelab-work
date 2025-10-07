#!/bin/bash

# Used for debugging
# set -ax

# This script is required after a reboot of the cloud after the cloud has been
# shut down

# ensure functions.sh is found even when script is executed from other dirs
SCRIPT_DIR=$(cd "$(dirname "$BASH_SOURCE")" && pwd)
. "${SCRIPT_DIR}/functions.sh"

check_juju_version

echo "Waiting for the env to settle..."
juju-wait -v ${model}
get_juju_status

# Check if we're using percona-cluster and/or mysql-innodb-cluster
percona_cluster=$(jq -r ".applications | to_entries[] | select(.value[\"charm-name\"] == \"percona-cluster\") | .key" "${juju_status_out}")
mysql_innodb_cluster=$(jq -r ".applications | to_entries[] | select(.value[\"charm-name\"] == \"mysql-innodb-cluster\") | .key" "${juju_status_out}")

echo "Fixing the DB (either percona or mysql-innodb)..."
if [[ -n "${percona_cluster}" ]] ; then
  do_percona_cluster
fi

if [[ -n "${mysql_innodb_cluster}" ]] ; then
  do_mysql_innodb_cluster
fi

# check if there's an elasticsearch app before fixing it
elasticsearch_app=$(jq -r '.applications | to_entries[] | select(.value["charm-name"] == "elasticsearch") | .key' "${juju_status_out}")

echo "Fixing Elasticsearch (if deployed, skipping otherwise)..."
if [[ -n "${elasticsearch_app}" && "${elasticsearch_app}" != "null" ]]; then
  ${juju_run} -u elasticsearch/leader -- sudo systemctl restart elasticsearch &
fi

echo "Fixing Heat and Ceph-radosgw..."
${juju_run} -a heat -- sudo systemctl restart heat-engine &
${juju_run} -a ceph-radosgw -- 'sudo systemctl restart ceph-radosgw@*' &

wait

# cleanup all crm resources
echo "Cleaning up CRM resources..."
jq -r ".applications | to_entries[] | select(.value[\"charm-name\"] == \"hacluster\") | .key" "${juju_status_out}" \
    | xargs -I{} ${juju_run} -u "{}"/leader -- 'sudo crm_resource -l | sed s/:.*//g | uniq | xargs -i sudo crm resource cleanup \"\{\}\"'

echo "Fixing vault..."
do_vault restart

# remove DNS entry for external network
#${juju_run} --all -- "sudo sed -i -e s/192.168.1.13,//g -e s/192.168.1.9,//g /etc/netplan/99-juju.yaml"
#${juju_run} --all -- "sudo netplan apply ; sudo systemctl restart systemd-resolved"

echo "Fixing Ceph..."
do_ceph

echo "Fixing Landscape..."
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
