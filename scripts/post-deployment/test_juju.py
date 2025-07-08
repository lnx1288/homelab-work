#!/usr/bin/env python3

import asyncio

from juju.controller import Controller
from juju.client.connection import Connection
from juju.client.client import ClientFacade

async def _this_get_model():
    controller = Controller()
    endpoint="10.0.1.226:17070"
    cacert_path="/home/arif/gitRepos/useful_scripts/controller_cert.crt"
    cacert=open(cacert_path,'r').read()
    model_uuid="8d65d934-7527-4a72-8774-941bf2be4cc2"
    password="hello123"
    username="admin"
    #max_frame_size=8388608
    max_frame_size=4194304

    conn = await Connection.connect(endpoint=endpoint, uuid=model_uuid,
                        cacert=cacert, username=username,
                        password=password, max_frame_size=max_frame_size)

    client = ClientFacade.from_connection(conn)
    patterns = None
    status = await client.FullStatus(patterns)

    print(status)

    await conn.close()

async def main():
    await _this_get_model()

if __name__ == '__main__':
    asyncio.run(main())
