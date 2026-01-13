import asyncio
import json
import logging
from datetime import timedelta, datetime
import httpx
import re

logger = logging.getLogger(__name__)
logger.setLevel(logging.DEBUG)
ch = logging.StreamHandler()
ch.setLevel(logging.DEBUG)
logger.addHandler(ch)


async def _get_realm_info():
    client_id, client_secrets = _load_env()
    access_token = _get_access_token(client_id, client_secrets)
    async with httpx.AsyncClient(
        headers={"Authorization": f"Bearer {access_token}"}
    ) as client:
        logger.info("Fetching realm list")
        resp = await client.get("https://eu.api.blizzard.com/data/wow/realm/index?namespace=dynamic-classic-eu&locale=en_GB")
        resp.raise_for_status()
        realm_urls = _parse_url_result(resp.json())
        realms = await asyncio.gather(*[_fetch_realm(client, url) for url in realm_urls])
        realm_info = _parse_realms(realms)
    
    return realm_info

def _parse_url_result(resp):
    return [realm.get("key", {}).get("href") for realm in resp["realms"]]


async def _fetch_realm(client, url):
    logger.info(f"Fetching {url}")
    realm_info = await client.get(url)
    return realm_info.json()


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


def _create_realm_file(realm_info):
    value_string = "\n".join(
        f"        [{realm.get("id")}] = \"{realm.get("name")}\"," for realm in realm_info
    )
    with open("ChanUI/realms.lua", "w+") as f:
        f.writelines(
            "local CUI = CUI\n"
            "\n"
            "function CUI:LoadRealms()\n"
            "    CUI.realm_id_to_name = {\n"
            f"{value_string}\n"
            "    }\n"
            "end"
        )


def _get_access_token(cid, csec):
    access_token, expires_at = re.findall(r"token_\w+=(.+)", open(".token", "r").read())
    if float(expires_at) > datetime.now().timestamp():
        logger.info("Using last token")
        return access_token

    logger.info("Requesting new token")
    resp = httpx.post(
        "https://oauth.battle.net/token",
        data={"grant_type": "client_credentials"},
        auth=(cid, csec)
    ).json()
    with open(".token", "w+") as f:
        token_last = resp.get("access_token")
        token_expires_at = (datetime.now() + timedelta(seconds=resp.get("expires_in"))).timestamp()
        f.write(f"token_last={token_last}\n")
        f.write(f"{token_expires_at=}")

    return resp["access_token"]


def _load_env():
    return re.findall(r"client_\w+=(.+)", open(".env", "r").read())


if __name__ == "__main__":
    realm_info = asyncio.run(_get_realm_info())
    _create_realm_file(realm_info)
