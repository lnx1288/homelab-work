#!/bin/bash

applications=$(juju status --format json  | jq -r ".applications | to_entries[].key")

for app in ${applications}
do
    vip=$(juju config $app --format json | jq -r ".settings.vip.value")
    if [[ $vip != "null" ]] ; then
	echo "${app}: ${vip}"
    fi
done

