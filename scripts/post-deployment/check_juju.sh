#!/bin/bash

check_controller()
{
    controller=$1
    model="cpe-jammy"

    juju status -m "${controller}":${model} --color | grep "Unit   " -A 999999 | grep -E -v "started.*ubuntu@|active.*idle"

}

if [[ -z "$1" ]] ; then
    check_controller "$(juju controllers --format json | jq -r .\"current-controller\")"
else
    check_controller "${1}"
fi

