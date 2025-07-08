#!/bin/bash

model_name="cpe-jammy"
model=" -m ${model_name}"
LMA_SERVERS="on"

get_juju_status()
{
    juju_status_out=$(mktemp)
    ${juju_status} --format json > "${juju_status_out}"
}

check_juju_version()
{
    juju_version=$(juju version | cut -d'-' -f1 | cut -d'.' -f1)

    juju_timeout="30s"

    juju_run="juju run --timeout ${juju_timeout}"
    juju_run_action="juju run-action --wait"
    juju_status="juju status"
    juju_ssh="juju ssh"
    juju_scp="juju scp"
    juju_config="juju config"

    if [[ ${juju_version} -ge 3 ]] ; then
        juju_run="juju exec --wait=${juju_timeout}"
        juju_run_action="juju run"
    fi

    if [[ -n ${model} ]] ; then
        juju_run+=${model}
        juju_run_action+=${model}
        juju_status+=${model}
        juju_ssh+=${model}
        juju_scp+=${model}
        juju_config+=${model}
    fi
}

do_vault()
{
    arg=${1}
    vault_file="vault-secrets.txt"

    if [[ ${arg} == "restart" ]] ; then
        ${juju_run} -a vault -- sudo systemctl restart vault
    fi

    vault_vip=$(${juju_config} vault vip)
    echo export VAULT_ADDR="http://${vault_vip}:8200"
    export VAULT_ADDR="http://${vault_vip}:8200"

    echo " "

    IPS=$(jq -r '.applications.vault.units | to_entries[].value."public-address"' "${juju_status_out}")

    for ip in $IPS;do
      echo export VAULT_ADDR=http://"${ip}":8200;
      export VAULT_ADDR=http://"${ip}":8200;
      for vault_key in $(head -n3 vault-secrets.txt | awk '{print $4}');do
        echo vault operator unseal -tls-skip-verify "$vault_key"
        vault operator unseal -tls-skip-verify "$vault_key"
      done;
    done;
}

do_ceph()
{
    ceph_osd_apps=$(jq -rc ".applications | to_entries[] | select(.value[\"charm-name\"] == \"ceph-osd\") | .key" "${juju_status_out}")

    for apps in ${ceph_osd_apps}
    do
        ${juju_run} -a "${apps}" -- 'sudo systemctl kill --all --type=service vaultlocker-decrypt@*'
        ${juju_run} -a "${apps}" -- 'sudo systemctl start --all --type=service vaultlocker-decrypt@*'
        ${juju_run} -a "${apps}" -- 'sudo systemctl start --all --type=service ceph-volume@*' &
    done

    wait
}

check_unit_status()
{

    app_name=$1
    status_check="$2"

    unit_status=$(${juju_status} --format json | jq -rc ".applications.${app_name}.units | to_entries[] | {sub:.key,status:.value[\"workload-status\"].message}")

    app_units=$(echo "${unit_status}" | jq -r .sub)

    num=0
    for unit in ${app_units} ; do
      this_unit_status=$(echo "$unit_status" | jq -rc . | grep "${unit}" | jq -r .status)
      if [[ "${this_unit_status}" == "${status_check}" ]] ; then
        (( num++ ))
      fi
    done

    if [[ $num -ge 3 ]] ; then echo 1
    else echo 0
    fi
}

get_lead()
{
    app_name=$1

    jq -rc '.applications.${app_name}.units | to_entries[] | select(.value.leader == "true") | .key' "${juju_status_out}"
}

do_mysql_innodb_cluster()
{
  mysql_status=$(jq -rc ".applications.\"mysql-innodb-cluster\".units | to_entries[] | {sub:.key,status:.value[\"workload-status\"].message}" "${juju_status_out}")

  is_ready=$(echo "$mysql_status" | jq -rc . | grep "Mode: R/W, Cluster is ONLINE" | jq -r .sub)

  if [[ -z "${is_ready}" ]] ; then
    reboot_status=$(${juju_run_action} mysql-innodb-cluster/leader reboot-cluster-from-complete-outage --format json)

    outcome=$(echo "$reboot_status" | jq .[].results.outcome)

    if [[ ${outcome} == null ]] ; then

      output=$(echo "$reboot_status" | jq .[].results.output)

      mysql_ip=$(echo "$output" | sed -e 's/\\n/\n/g' 2>&1| grep Please | sed -e "s|.*Please use the most up to date instance: '\(.*\):.*|\1|")

      bootstrap_unit=$(jq -r ".applications.\"mysql-innodb-cluster\".units | to_entries[] | select(.value.\"public-address\" == \"${mysql_ip}\") | .key" "${juju_status_out}")

      ${juju_run_action} "${bootstrap_unit}" reboot-cluster-from-complete-outage

    fi
  fi
}

do_percona_cluster()
{
  mysql_status=$(jq -rc ".applications.mysql.units | to_entries[] | {sub:.key,status:.value[\"workload-status\"].message}" "${juju_status_out}")

  #{"sub":"mysql/0","status":"MySQL is down. Sequence Number: 102921. Safe To Bootstrap: 1"}
  #{"sub":"mysql/1","status":"MySQL is down. Sequence Number: 102921. Safe To Bootstrap: 0"}
  #{"sub":"mysql/2","status":"MySQL is down. Sequence Number: 102921. Safe To Bootstrap: 0"}

  mysql_units=$(echo "${mysql_status}" | jq -r .sub)
  bootstrap_unit=""

  mysql_lead=$(get_lead mysql)

  safe_to_bootstrap=$(echo "$mysql_status" | jq -rc . | grep "Safe To Bootstrap: 1" | jq -r .sub)

  if [[ -n "$safe_to_bootstrap" ]]
  then

    bootstrap_unit=$safe_to_bootstrap

  else

    seq_number=$(echo "$mysql_status" | jq -rc . | grep "Sequence Number" )

    if [[ -n "${seq_number}" ]]
    then

      seqs=$(echo "$seq_number" | jq -rc ". | {sub:.sub,seq:(.status|split(\".\")[1]|split(\": \")[1])}")

      uniq_seqs=$(echo "$seqs" | jq -r .seq | sort -n | uniq)
      seq_count=$(echo "$uniq_seqs" | xargs | wc -w)

      highest_seq=$(echo "${seqs}" | jq -r .seq | sort -n | uniq | tail -n 1)

      if [[ ${seq_count} -eq 1 ]]
      then # same seq numbers all round
        if [[ ${highest_seq} -eq -1 ]]
        then # if all seq numbers are -1
          echo "The sequence number is -1 ... exiting"
          exit 1
        fi
        bootstrap_unit=${mysql_lead}
      else # we have different seq numbers

        unit_high_seq=$(echo "$seqs" | jq -rc . | grep "${highest_seq}" | jq -r .sub | tail -n 1)

        bootstrap_unit=${unit_high_seq}
      fi
    fi
  fi

  if [[ -n ${bootstrap_unit} ]]
  then
    ${juju_run_action} "${bootstrap_unit}" bootstrap-pxc
    ${juju_run} -a mysql "hooks/update-status"
    until [[ $(check_unit_status mysql "Unit waiting for cluster bootstrap") -eq 1 ]]
    do
      sleep 10
    done
    if [[ "${bootstrap_unit}" == "${mysql_lead}" ]] ; then
      for unit in ${mysql_units}; do
        if [[ "${unit}" != "${mysql_lead}" ]] ; then
            ${juju_run_action} "${unit}" notify-bootstrapped
            break
        fi
      done
    else
      ${juju_run_action} "${mysql_lead}" notify-bootstrapped
    fi
    ${juju_run} -a mysql "hooks/update-status"
    until [[ $(check_unit_status mysql "Unit is ready") -eq 1 ]]
    do
      sleep 10
    done
    # This is so that nagios doesn't report that the mysql daemon is down
    # although the process is running. juju will then automatically start
    # the mysqld process
    ${juju_ssh} "${bootstrap_unit}" -- sudo reboot
  fi

  ${juju_run} -a nova-cloud-controller -- sudo systemctl restart nova-api-os-compute nova-conductor nova-consoleauth &
}

do_ovn_resync()
{
  ovn_app=$(jq -rc ".applications | to_entries[] | select(.value[\"charm-name\"] == \"ovn-central\") | .key" "${juju_status_out}")

  ovn_ips=$(jq -r '.applications.${ovn_app}.units | to_entries[].value."public-address"' "${juju_status_out}")
  neutron_ips=$(jq -r '.applications."neutron-api".units | to_entries[].value."public-address"' "${juju_status_out}")

  ovn_names=$(jq -r '.applications.${ovn_app}.units | keys[]' "${juju_status_out}")
  ovn_lead=$(get_lead "${ovn_app}")
  ovn_lead_ip=$(jq -r '.applications.${ovn_app}.units."'${ovn_lead}'"."public-address"' "${juju_status_out}")

  for unit in $ovn_names
  do
      ${juju_run_action} $unit pause
  done

  ${juju_run} -a ovn-central -- mv /var/lib/ovn/ovnnb_db.db /var/lib/ovn/ovnnb_db.db.old -v
  ${juju_run} -a ovn-central -- mv /var/lib/ovn/ovnsb_db.db /var/lib/ovn/ovnsb_db.db.old -v
  ${juju_run} -u ${ovn_lead} -- rm -rf /tmp/standalone_ovnnb_db.db
  ${juju_run} -u ${ovn_lead} -- rm -rf /tmp/standalone_ovnsb_db.db
  ${juju_run} -u ${ovn_lead} -- ovsdb-tool create /tmp/standalone_ovnnb_db.db /usr/share/ovn/ovn-nb.ovsschema
  ${juju_run} -u ${ovn_lead} -- ovsdb-tool create /tmp/standalone_ovnsb_db.db /usr/share/ovn/ovn-sb.ovsschema
  ${juju_run} -u ${ovn_lead} -- ovsdb-tool create-cluster /var/lib/ovn/ovnnb_db.db /tmp/standalone_ovnnb_db.db ssl:${ovn_lead_ip}:6643
  ${juju_run} -u ${ovn_lead} -- ovsdb-tool create-cluster /var/lib/ovn/ovnsb_db.db /tmp/standalone_ovnsb_db.db ssl:${ovn_lead_ip}:6644

  ${juju_run_action} ${ovn_lead} resume

  ovn_nb_uuid=$(${juju_run} -u ${ovn_lead} -- "ovn-appctl -t /var/run/ovn/ovnnb_db.ctl cluster/status OVN_Northbound | grep ^Cluster | awk '{print \$4}' | sed -e s/\(//g -e s/\)//g")
  ovn_sb_uuid=$(${juju_run} -u ${ovn_lead} -- "ovn-appctl -t /var/run/ovn/ovnsb_db.ctl cluster/status OVN_Southbound | grep ^Cluster | awk '{print \$4}' | sed -e s/\(//g -e s/\)//g")

  ovn_hosts_nb="ssl:${ovn_lead_ip}:6643"
  ovn_hosts_sb="ssl:${ovn_lead_ip}:6644"

  for unit in $ovn_names
  do
      [[ "$unit" == "$ovn_lead" ]] && continue

      ovn_unit_ip=$(jq -r '.applications."ovn-central".units."'${unit}'"."public-address"' "${juju_status_out}")

      ovn_hosts_nb="ssl:${ovn_unit_ip}:6643 ${ovn_hosts_nb}"
      ovn_hosts_sb="ssl:${ovn_unit_ip}:6644 ${ovn_hosts_sb}"

      ${juju_run} -u ${unit} -- ovsdb-tool --cid=${ovn_nb_uuid} join-cluster /var/lib/ovn/ovnnb_db.db OVN_Northbound ${ovn_hosts_nb}
      ${juju_run} -u ${unit} -- ovsdb-tool --cid=${ovn_sb_uuid} join-cluster /var/lib/ovn/ovnsb_db.db OVN_Southbound ${ovn_hosts_sb}

      ${juju_run_action} ${unit} resume
  done

  ${juju_run} -a ovn-central -- hooks/update-status
  ${juju_run} -a ovn-central -- hooks/config-changed

  ${juju_run} -u neutron-api/leader -- cp -v /etc/neutron/neutron.conf /etc/neutron/neutron.conf.copy
  ${juju_run} -u neutron-api/leader -- sed -i "s@auth_section = .*@#auth_section = keystone_authtoken@g" /etc/neutron/neutron.conf.copy
  ${juju_run} -u neutron-api/leader -- neutron-ovn-db-sync-util --config-file /etc/neutron/neutron.conf.copy --config-file /etc/neutron/plugins/ml2/ml2_conf.ini --ovn-neutron_sync_mode repair
  ${juju_run} -u neutron-api/leader -- rm -v /etc/neutron/neutron.conf.copy

  ${juju_run} -a ovn-chassis -- sudo systemctl restart ovn-controller
  ${juju_run} -a neutron-api -- sudo systemctl restart neutron-api
}
