#!/bin/bash

. functions.sh
check_juju_version

check_controller()
{
    controller=$1
    model="${controller}:${model_name}"

    RW_MYSQL_UNIT=$(juju status -m ${model} --format json | jq -r '[.applications."mysql-innodb-cluster".units | to_entries[]|  select(.value."workload-status".message | contains("R/W")) | .key] | .[0]')
    ${juju_run_action} -m ${model} ${RW_MYSQL_UNIT} cluster-status --format json | jq -rc '.[].results."cluster-status"'  | jq

}

if [[ -z "$1" ]] ; then
    check_controller "$(juju controllers --format json | jq -r .\"current-controller\")"
else
    check_controller "${1}"
fi
