#!/bin/bash

#
# The purpose of this script is to grab the versions of the charms being used
# on a system that is controlled by juju. The script will output tht data in
# CSV format, which can easily be added to a spreadsheet ot other applications
# for undestanding of cuerrent revisions of charms.
#
# Authors:
#   - Arif ali <arif.ali@canonical.com>
#

apps=$(juju status --format json | jq -rc ".applications | to_entries[] | {charm_name:.value[\"charm-name\"],charm:.value.charm,version:.value[\"charm-rev\"]}")

for app in $apps
do
   # each line will look similar to the one below
   #
   # {"charm_name":"openstack-service-checks","charm":"cs:~canonical-bootstack/openstack-service-checks-30","version":30}

   app_name=$(echo $app | jq -r .charm_name)
   charm=$(echo $app | jq -r .charm)
   charm_version=$(echo $app | jq -r .version)

   echo -n "${app_name},"
   if [[ $charm =~ ^cs:~ ]] ; then
           echo -n $charm | sed "s/^cs:~\(.*\)\/${app_name}-.*/\1,/g"
   else
           echo -n ","
   fi
   echo ${charm_version}
done | sort | uniq
