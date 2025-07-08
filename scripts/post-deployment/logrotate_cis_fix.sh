#!/bin/bash

cat > /tmp/fix_logs.sh << EOF
#!/bin/bash
sudo chown syslog:adm /var/log/syslog /var/log/auth.log /var/log/dpkg.log /var/log/kern.log /var/log/mail.log /var/log/lastlog /var/log/ubuntu-advantage.log /var/log/haproxy.log
sudo sed -i 's/create 0640 root utmp/create 0640/g' /etc/logrotate.conf
sudo systemctl restart logrotate.timer
EOF

juju_status=$(mktemp)
juju status --format json > "${juju_status}"

timeout="--timeout 30s"

nova_compute_apps=$(jq -rc ".applications | to_entries[] | select(.value[\"charm-name\"] == \"nova-compute\") | .key" "${juju_status}")

for app in ${nova_compute_apps}
do

  nova_compute_units=$(jq -r '.applications."nova-compute".units | keys[]' "${juju_status}")

  for unit in ${nova_compute_units}
  do
    juju scp /tmp/fix_logs.sh ${unit}:fix_logs.sh
  done

  juju run ${timeout} -a ${app} -- 'bash fix_logs.sh'

done

