#!/usr/bin/env python3

import os
import requests
import yaml
import argparse

from keystoneclient.v3.client import Client as keystone_auth

headers = {}
headers['content-type'] = 'application/json'

endpoint_type = "public"


def get_credentials(site_id):
    home = os.environ['HOME']
    with open('{}/clouds.yaml'.format(home), 'r') as stream:
        clouds = yaml.safe_load(stream)['clouds']

        creds = clouds[site_id]['auth']
        creds['version'] = clouds[site_id]['identity_api_version']

    return creds


def get_keystoneclient(creds):
    return keystone_auth(**creds)


def get_servers(keystone):

    url = keystone.service_catalog.get_endpoints(
        service_name="nova",
        endpoint_type=endpoint_type,
    )['compute'][0]['url']

    request = "servers"

    r = requests.get("{}/{}".format(url, request), headers=headers)

    servers = r.json()[request]

    for server in servers:
        print("server_id: {}".format(server['id']))


def get_projects(keystone):

    url = keystone.service_catalog.get_endpoints(
        service_name="keystone",
        endpoint_type=endpoint_type,
    )['identity'][0]['url']

    request = "projects"

    r = requests.get("{}/{}".format(url, request), headers=headers)

    projects = r.json()[request]

    for project in projects:
        print("project_id: {}".format(project['id']))


def get_hosts(keystone):

    url = keystone.service_catalog.get_endpoints(
        service_name="nova",
        endpoint_type=endpoint_type,
    )['compute'][0]['url']

    request = "os-services"

    r = requests.get("{}/{}".format(url, request), headers=headers)

    services = r.json()['services']

    for service in services:
        if service['zone'] == 'nova':
            print("host: {}, updated_at: {}".format(
                service['host'],
                service['updated_at'],
            ))


def get_cores(keystone):

    url = keystone.service_catalog.get_endpoints(
        service_name="placement",
        endpoint_type=endpoint_type,
    )['placement'][0]['url']

    psc_request = "resource_providers"

    r = requests.get("{}/{}".format(url, psc_request), headers=headers)

    if psc_request in r.json():
        for res in r.json()[psc_request]:
            uuid = res['uuid']
            hostname = res['name']

            request = "/{}/{}/inventories".format(psc_request, uuid)

            r = requests.get("{}/{}".format(url, request), headers=headers)

            inventory = r.json()['inventories']

            cores = 0
            if 'VCPU' in inventory:
                cores += inventory['VCPU']['total']
            if 'PCPU' in inventory:
                cores += inventory['PCPU']['total']

            print("{}: {}".format(hostname, cores))


def get_networks(keystone):

    url = keystone.service_catalog.get_endpoints(
        service_name="neutron",
        endpoint_type=endpoint_type,
    )['network'][0]['url']

    request = "networks"

    r = requests.get("{}/v2.0/{}".format(url, request), headers=headers)

    networks = r.json()[request]

    for network in networks:
        print("network_id: {}".format(network['id']))


def _parse_args():
    parser = argparse.ArgumentParser()
    parser.add_argument('-s', '--site', metavar="<site-id>",
                        help="Site to run against", dest="site_id",
                        required=True)
    return parser.parse_args()


def main(args):
    creds = get_credentials(args.site_id)

    keystone = get_keystoneclient(creds)
    token = keystone.auth_token

    headers['x-auth-token'] = token

    get_servers(keystone)
    get_cores(keystone)
    get_networks(keystone)
    get_projects(keystone)
    get_hosts(keystone)


if __name__ == '__main__':
    main(_parse_args())
