#!/bin/bash

. functions.sh
check_juju_version

get_juju_status

vault_file="vault-secrets.txt"
vault_token_file="vault-token.txt"
vault_vip=$(${juju_config} vault vip)

export VAULT_ADDR="http://${vault_vip}:8200"

vault operator init -key-shares=5 -key-threshold=3 | tee ${vault_file}

if [[ -z "$(cat ${vault_file})" ]] ; then
  echo "Vault was not initialised, exiting ..."
  exit 1
fi

do_vault

initial_token=$(grep Initial ${vault_file} | awk '{print $4}')

export VAULT_TOKEN=${initial_token}

vault token create -ttl=10m | tee ${vault_token_file}

token=$(grep token ${vault_token_file} | head -n 1 | awk '{print $2}')

${juju_run_action} vault/leader authorize-charm token=${token}