#!/bin/bash

juju_status=$(mktemp)

juju status --format json > $juju_status

# old method
#cat ${juju_status} | jq -rc '.machines | to_entries[] |[.key,.value.hostname,.value."ip-addresses"]'
#cat ${juju_status} | jq -rc '.machines | to_entries[] | select(.value.containers != null ) | .value.containers | to_entries[] | [.key,.value.hostname,.value."ip-addresses"]'

# new method
jq -rc '.machines | to_entries[] |[.key,.value.hostname,.value."ip-addresses", [(.value.containers//empty | to_entries[] | [.key,.value.hostname,.value."ip-addresses"])]]' ${juju_status}

