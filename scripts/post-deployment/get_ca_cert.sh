#!/bin/bash

juju run vault/leader get-root-ca --format json | jq -rc ".[].results.output" > root_ca.cert
