#!/bin/bash

args="$@"

. functions.sh
check_juju_version

get_juju_status

do_vault ${args}
