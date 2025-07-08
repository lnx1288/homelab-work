#!/bin/bash

#set -ax

. functions.sh
check_juju_version
get_juju_status

do_ovn_resync
