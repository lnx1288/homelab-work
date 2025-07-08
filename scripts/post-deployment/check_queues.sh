#!/bin/bash

check_controller()
{
    controller=$1
    model=$2

    [[ -z "${model}" ]] && model="$(juju controllers --format json | jq -rc ".controllers | to_entries[] | select(.key == \"$controller\") | .value[\"current-model\"]")"

    echo ${controller}:
    echo

    juju run -m ${controller}:${model} --unit rabbitmq-server/leader -- \
        sudo rabbitmqctl list_queues -p openstack pid | sed -e 's/<\([^.]*\).*>/\1/' | sort | uniq -c

}

if [[ -z "$1" ]] ; then

    controllers=$(juju controllers --format json | jq -rc ".controllers | to_entries[] | {controller:.key,model:.value[\"current-model\"]}")

    for controller_json in ${controllers}
    do
        controller=$(echo $controller_json | jq -r .controller)
        model=$(echo $controller_json | jq -r .model)
        check_controller ${controller} ${model}
    done

else

    model=""
    [[ -n "$2" ]] && model=$2

    check_controller $1 $model

fi
