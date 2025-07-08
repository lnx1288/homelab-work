#!/usr/bin/env python3

from pymongo import MongoClient

import yaml
import os
import sys

host = "localhost"
port = "37017"


def _import_yaml():
    global password, username

    agent_dir = "/var/lib/juju/agents"

    entries = os.listdir(agent_dir)

    for file_name in entries:
        if "machine" in file_name:
            machine = file_name
            break

    with open(f'{agent_dir}/{machine}/agent.conf', 'r') as stream:
        agent = yaml.safe_load(stream)
        password = agent['statepassword']
        username = agent['tag']


def main():
    _import_yaml()
    client = MongoClient(f"{host}:{port}",
                         username=username,
                         password=password,
                         authSource='admin',
                         tls=True,
                         tlsAllowInvalidCertificates=True,
                         )
    rep_status = client.admin.command('replSetGetStatus')

    for member in rep_status['members']:
        print(f"Host: {member['name'].split(':')[0]}, State: {member['stateStr']}")


if __name__ == '__main__':
    sys.exit(main())
