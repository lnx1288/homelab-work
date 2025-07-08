#!/bin/bash

memcached_units="$(juju status --format json | jq -rc '.applications.memcached.units | keys[]')"
#prefix="/tmp"
prefix="."

cmd="/usr/share/memcached/scripts/memcached-tool"
host="127.0.0.1:11211"
mm_cmds="display stats settings dump"

for u in ${memcached_units}; do
    f=$(echo ${u//\//_})
    echo "Working on unit $u"
    location=${prefix}/${f}.txt
    rm -rf ${location}
    for mm_cmd in ${mm_cmds} ; do
        echo "${mm_cmd}:" >> ${location}
        juju ssh $u "${cmd} ${host} ${mm_cmd}" >> ${location}
    done
done
exit 0
