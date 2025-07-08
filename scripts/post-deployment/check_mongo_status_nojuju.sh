#!/bin/bash

machine=${1:-0}
model=${2:-foundation-maas}

#host=$(juju show-controller ${model} --format json | jq -rc '."'${model}'".details."api-endpoints"['$machine']' | awk -F: '{print $1}')
host=$(cat ~/.local/share/juju/controllers.yaml | yq '.controllers."'${model}'"."api-endpoints"['$machine']' | awk -F: '{print $1}')

read -d '' -r cmds <<'EOF'
user=$(sudo ls /var/lib/juju/agents/ | grep machine)
conf=/var/lib/juju/agents/${user}/agent.conf
password=$(sudo grep statepassword ${conf} | cut -d' ' -f2)
if [ -f /usr/lib/juju/mongo*/bin/mongo ]; then
  client=/usr/lib/juju/mongo*/bin/mongo
elif [ -f /usr/bin/mongo ]; then
  client=/usr/bin/mongo
else
  client=/snap/bin/juju-db.mongo
fi
${client} 127.0.0.1:37017/juju --authenticationDatabase admin --ssl --sslAllowInvalidCertificates --username "${user}" --password "${password}" --eval "rs.status()" | grep -P '(name|stateStr)'
EOF

ssh_key=$HOME/.local/share/juju/ssh/juju_id_rsa

ssh -o IdentityAgent=none -l ubuntu -i ${ssh_key} ${host} "${cmds}"
