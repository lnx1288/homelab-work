#!/bin/bash

# Created: JP on Feb 11 2021
# Updated: AA on Oct 12 2021
# Usage: ./get_all_relations_info.sh <app_or_app/unit>
# Example: ./get_all_relations_info.sh mysql # This will default to "mysql/0"
# Example: ./get_all_relations_info.sh keystone/1

. functions.sh
check_juju_version

APP=`echo ${1} | awk -F\/+ '{print $1}'`
UNIT=`echo ${1} | awk -F\/+ '{print $2}'`

[ -z "$UNIT" ] && UNIT=0

for r in `juju show-application ${APP} | grep endpoint-bindings -A999 | tail -n +3 | awk -F\: '{print $1}' | sort`
do
	for i in `${juju_run} -u ${APP}/${UNIT} -- "relation-ids ${r}" | awk -F\: '{print $2}' | sort`
	do
		echo "==========================================="
		echo "RELATION INFO FOR ${APP}/${UNIT} - ${r}:${i}"
		echo ""
		${juju_run} -u ${APP}/${UNIT} -- "relation-get -r ${r}:${i} - ${APP}/${UNIT}"
		echo "==========================================="
	done
done

exit 0
