#!/bin/bash

machine=${1:-0}
model=${2:-controller}

read -d '' -r cmds <<'EOF'
sudo apt -y install python3-pymongo > /dev/null 2>&1
sudo python3 /home/ubuntu/check_mongo.py
EOF

juju scp -m ${model} check_mongo.py ${machine}:.
juju ssh -m ${model} ${machine} "${cmds}"
