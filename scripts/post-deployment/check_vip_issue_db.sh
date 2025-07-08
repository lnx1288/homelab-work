#!/bin/bash

juju_status=$(mktemp)
juju_db=$(mktemp)

juju status --format json > ${juju_status}
JUJU_DEV_FEATURE_FLAGS=developer-mode juju dump-db --format json > ${juju_db}

#juju_status=/tmp/tmp.IG9jLOKBET
#juju_db=/tmp/tmp.1kg5IV5I3k

hacluster_apps=$(jq -r ".applications | to_entries[] | select(.value[\"charm-name\"] == \"hacluster\") | .key" ${juju_status})

for app in ${hacluster_apps}
do

  super_app=$(jq -r .applications.\"${app}\".relations.ha[] ${juju_status})
  units=$(jq -r ".applications.\"${super_app}\".units | keys[]" ${juju_status})

  #vips=$(juju config ${super_app} vip)
  vips=$(jq -r ".settings[] | select(._id | contains(\"a#${super_app}#cs\")) | .settings.vip" ${juju_db})

  bindings=$(jq -r ".applications.\"${super_app}\".\"endpoint-bindings\" | keys[]" ${juju_status})

  for r in ${bindings}
  do
     [[ ${r} != "cluster" ]] && [[ ${r} != "ha" ]] && continue
     for unit in ${units}
     do
        #relation_ids=$(juju run --unit ${unit} "relation-ids ${r}" | awk -F\: '{print $2}' | sort)
        relation_ids=$(jq ".relations[] | select(.endpoints[].relation.name == \"${r}\") | select(.endpoints[].applicationname == \"${super_app}\")| .id" ${juju_db})
        for i in ${relation_ids}
        do
              #relation_output=$(juju run --unit ${unit} "relation-get -r ${r}:${i} - ${unit}" | grep $vip)
              if [[ ${r} == "cluster" ]] ; then
                  relation_output=$(jq ".settings[] | select(._id | contains(\"r#${i}#peer#${unit}\"))" ${juju_db})
              else
                  relation_output=$(jq ".settings[] | select(._id | contains(\"r#${i}#${unit}#req\"))" ${juju_db})
              fi

              for vip in ${vips} ; do

                  #include_vip=$(echo $relation_output | grep ${vip})
                  include_vip=$(echo $relation_output | jq -rc ".settings | [.\"egress-subnets\", .\"private-address\", .\"ingress-address\"]" | grep ${vip})

                  if [[ -n "$relation_output" ]] && [[ -n "${include_vip}" ]] ; then

                      #echo $relation_output | jq -rc "._id"
                      echo ${unit}: {vip: ${vip}, binding: ${r}:${i}}
                      echo
                      echo $relation_output | jq -rc ".settings | [.\"egress-subnets\", .\"private-address\", .\"ingress-address\"]"
                      echo

                  fi
              done
        done
     done
  done
done

