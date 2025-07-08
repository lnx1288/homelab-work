#!/bin/bash

machine=${1:-0}
model=${2:-foundation-maas}

#host=$(juju show-controller ${model} --format json | jq -rc '."'${model}'".details."api-endpoints"['$machine']' | awk -F: '{print $1}')
host=$(cat ~/.local/share/juju/controllers.yaml | yq '.controllers."'${model}'"."api-endpoints"['$machine']' | awk -F: '{print $1}')

cmds="sudo systemctl restart jujud-machine-\*"

ssh_key=$HOME/.local/share/juju/ssh/juju_id_rsa

ssh -o IdentityAgent=none -l ubuntu -i ${ssh_key} ${host} "${cmds}"
