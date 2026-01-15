import asyncio
import logging
from datetime import timedelta, datetime
from itertools import chain

import httpx
import re

logger = logging.getLogger(__name__)
logger.setLevel(logging.DEBUG)
ch = logging.StreamHandler()
ch.setLevel(logging.DEBUG)
logger.addHandler(ch)

BASE_URL_EU = "https://eu.api.blizzard.com"
BASE_URL_US = "https://us.api.blizzard.com"
REALM_ENDPOINT = "/data/wow/realm/index"
NAMESPACES = ("dynamic-classic-eu", "dynamic-classic1x-eu")


def _create_realm_file(realm_info):
    value_string = "\n".join(
        f'        [{realm.get("id")}] = "{realm.get("name")}",' for realm in realm_info
    )
    with open("ChanUI/realms.lua", "w+") as f:
        f.writelines(
            "local CUI = CUI\n"
            "\n"
            "function CUI:GetRealms()\n"
            "    return {\n"
            f"{value_string}\n"
            "    }\n"
            "end"
        )


def _parse_realms(realms):
    return [
        {
            "id": realm.get("id"),
            "region": realm.get("region", {}).get("name", {}).get("en_GB"),
            "name": realm.get("name", {}).get("en_GB"),
            "category": realm.get("category", {}).get("en_GB"),
            "slug": realm.get("slug"),
        }
        for realm in realms
    ]


async def _fetch_realm(client, url):
    logger.info(f"Fetching {url}")
    realm_info = await client.get(url)
    return realm_info.json()


def _parse_url_result(resp):
    return [realm.get("key", {}).get("href") for realm in resp["realms"]]


async def _fetch_realm_urls(client, url):
    logger.info(f"Fetching realms from: {url}")
    resp = await client.get(url)
    return _parse_url_result(resp.json())


def _load_env():
    with open(".env", "r") as f:
        return re.findall(r"client_\w+=(.+)", f.read())


def _get_access_token():
    with open(".token", "r") as f:
        access_token, expires_at = re.findall(r"token_\w+=(.+)", f.read())

    if float(expires_at) > datetime.now().timestamp():
        logger.info("Using last token")
        return access_token

    logger.info("Requesting new token")
    client_id, client_secret = _load_env()
    resp = httpx.post(
        "https://oauth.battle.net/token",
        data={"grant_type": "client_credentials"},
        auth=(client_id, client_secret),
    ).json()

    with open(".token", "w+") as f:
        token_last = resp.get("access_token")
        token_expires_at = datetime.now() + timedelta(seconds=resp.get("expires_in"))
        f.write(f"token_last={token_last}\n")
        f.write(f"token_expires_at={token_expires_at.timestamp()}")

    return resp["access_token"]


async def _get_realm_info():
    access_token = _get_access_token()
    async with httpx.AsyncClient(
        headers={"Authorization": f"Bearer {access_token}"}
    ) as client:
        realm_info = []
        realm_urls = chain.from_iterable(
            await asyncio.gather(
                *[
                    _fetch_realm_urls(
                        client, f"{BASE_URL_EU + REALM_ENDPOINT}?namespace={namespace}"
                    )
                    for namespace in NAMESPACES
                ]
            )
        )

        realms = await asyncio.gather(
            *[_fetch_realm(client, url) for url in realm_urls]
        )
        realm_info += _parse_realms(realms)

    return realm_info


if __name__ == "__main__":
    realm_info = asyncio.run(_get_realm_info())
    _create_realm_file(realm_info)
