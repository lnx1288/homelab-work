echo juju deploy ./bundle.yaml
apps="etcd cinder-backup cinder"
for app in ${apps} ; do
  echo tf import juju_application.${app} cpe-jammy:${app}
  machines=$(cat terraform.tfstate | jq -rc '.resources[] | select(.type == "juju_machine" and .name == "'${app}'") | .instances[].attributes.machine_id' | xargs | tr ' ' ',')
  echo juju deploy ${app} -n 3 --to ${machines}
done
