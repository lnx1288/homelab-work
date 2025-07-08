#!/usr/bin/env python3

import argparse
import asyncio

from juju.model import Model


async def main(args):

    unit_name = args.unit_name
    if args.bind_check:
        bind_check = args.bind_check

    model = Model()
    await model.connect_current()

    try:
        app = unit_name.split('/')[0]

        juju_status = await model.get_status()

        units = model.applications[app].units

        bindings = juju_status.applications[app].endpoint_bindings

        for binding in bindings:
            if ((binding is not None and "bind_check" not in locals()) or
                    ("bind_check" in locals() and binding == bind_check)):
                for unit in units:
                    if unit.name == unit_name:
                        await _check_binding(unit, binding)

    finally:
        await model.disconnect()


async def _check_binding(unit, binding):
    rel_ids = await _get_rel_ids(unit, binding)

    seperator = "============================================================"

    for rel in rel_ids:

        rel_info = await unit.run('relation-get -r {} - {}'.format(
            rel, unit.name))
        await rel_info.fetch_output()
        if 'stdout' in rel_info.results:
            print(seperator)
            print('Relation info for {} - {}\n'.format(unit.name, rel))
            print(rel_info.results['stdout'])
            print(seperator)


async def _get_rel_ids(unit, binding):
    rel_ids = []

    relation_ids = await unit.run('relation-ids {}'.format(binding))
    await relation_ids.fetch_output()

    if 'stdout' in relation_ids.results:
        rel_ids = relation_ids.results['stdout'].split()

    return rel_ids


def _parse_args():
    parser = argparse.ArgumentParser()
    parser.add_argument('-u', '--unit', metavar="<unit>",
                        help="Unit to run against", dest="unit_name",
                        required=True)
    # parser.add_argument('-a', '--application', metavar="<application>",
    #                    help="Application to run against",
    #                    dest="app_name")
    parser.add_argument('-b', '--binding', metavar="<binding>",
                        help="Only check <binding> for the relational data",
                        dest="bind_check")
    return parser.parse_args()


if __name__ == '__main__':
    asyncio.run(main(_parse_args()))
