#!/bin/bash

. functions.sh
check_juju_version
${juju_run_action} vault/leader get-root-ca --format json | jq -rc ".[].results.output" > root_ca.cert