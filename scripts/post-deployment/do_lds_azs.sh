#!/bin/bash

juju_status=$(mktemp)
juju_models=$(mktemp)

juju models --format json > "${juju_models}"

models=$(jq -r .models[].\"short-name\" "${juju_models}")

for model in ${models} ; do

    juju status -m "${model}" --format json > "${juju_status}"

    for phys_mach in $(jq -rc  ".machines | keys[]" "${juju_status}") ; do

        az=$(jq -rc ".machines.\"${phys_mach}\".hardware" "${juju_status}" | sed 's/.*availability-zone=//g')
        hostname=$(jq -r ".machines.\"${phys_mach}\".hostname" "${juju_status}")

        landscape-api add-tags-to-computers title:"${hostname}" "${az}"
        landscape-api add-tags-to-computers title:"${hostname}" "${model}-model"

        containers=$(jq -rc ".machines.\"${phys_mach}\" | (select(.containers != null ) | .containers | to_entries[] | .value.hostname)" "${juju_status}")

        for container in ${containers}
        do

            landscape-api add-tags-to-computers title:"${container}" "${az}"
            landscape-api add-tags-to-computers title:"${container}" "${model}-model"
            if [[ "${container}" == *"lxd"* ]] ; then
                landscape-api add-tags-to-computers title:"${container}" lxd
            fi
            if [[ "${container}" == *"kvm"* ]] ; then
                landscape-api add-tags-to-computers title:"${container}" kvm
            fi

        done

        # Tags that have been grabbed from MAAS
        tags=$(jq .machines.\""${phys_mach}"\".hardware "${juju_status}" | sed 's/.*tags=\(.*\)\ .*/\1/g' | tr "," " ")

        for tag in ${tags} ; do
            landscape-api add-tags-to-computers title:"${hostname}" "${tag}"
        done

    done
done
