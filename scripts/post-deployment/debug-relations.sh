#!/bin/bash
if [ $# -ne 2 ]; then
  echo "Usage: $0 unit/N relation-name (e.g. $0 ceph-mon/0 client)"
  exit 1
fi

source functions.sh
check_juju_version

relation_ids=$(${juju_run} -u $1 -- relation-ids $2)
echo $relation_ids

for relation_id in $relation_ids; do
  units=$(${juju_run} -u $1 -- relation-list -r $relation_id)
  for unit in $units; do
    echo -----
    echo from $1 get $relation_id $unit
    ${juju_run} -u $1 -- relation-get -r $relation_id - $unit
  done &
done

wait

