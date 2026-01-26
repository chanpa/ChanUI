import asyncio
import logging
import re
from collections import defaultdict
from datetime import timedelta, datetime
from functools import partial
from itertools import chain

import aiometer
import httpx

logger = logging.getLogger(__name__)
logger.setLevel(logging.DEBUG)
ch = logging.StreamHandler()
ch.setLevel(logging.DEBUG)
logger.addHandler(ch)

BASE_URL = "https://{}.api.blizzard.com"
REALM_ENDPOINT = "/data/wow/search/realm"
REGIONS = ("eu", "us")
NAMESPACES = ("dynamic-classic-{}", "dynamic-classic1x-{}")


def _create_realm_file(realm_info):
    region_strings = []
    for region, realms in realm_info.items():
        region_string = f"    {region} = {{\n"
        realm_strings = []
        for realm in realms:
            realm_names = ", ".join(f"{locale} = \"{name}\"" for locale, name in realm.get("names").items())
            realm_strings.append(
                f"        [{realm.get("id")}] = {{names = {{{realm_names}}}}},"
            )
        end_string = "\n    },"
        region_strings.append(region_string + "\n".join(realm_strings) + end_string)

    with open("ChanUI/realms.lua", "w+") as f:
        f.writelines(
            "local CUI = CUI\n"
            "\n"
            "local regions = {\n"
            "    [1] = \"us\",\n"
            "    [3] = \"eu\",\n"
            "}\n"
            "local realms = {\n"
            f"{'\n'.join(region_strings)}\n"
            "}\n"
            "\n"
            "function CUI:GetRealmName(gameAccountInfo, locale)\n"
            "    if locale == nil then locale = \"en_GB\" end\n"
            "    local realmID = gameAccountInfo.realmID\n"
            "    local region = regions[gameAccountInfo.regionID]\n"
            "    local realmInfo = realms[region][realmID]\n"
            "    if realmInfo and realmInfo.names then\n"
            "        return realmInfo.names[locale]\n"
            "    end\n"
            "\n"
            "    self:Print(\"realmid: \"..realmID)\n"
            "    self:Print(\"region: \".. region)\n"
            "    self:Print(\"locale: \"..locale)\n"
            "    DevTools_Dump(realmInfo)\n"
            "    return \"Unknown\"\n"
            "end"
        )


def _parse(realms):
    realm_info = defaultdict(list)
    for region_realms in realms:
        logger.info(
            f"{region_realms.get('pageSize')} from {region_realms.get('region')}"
        )

        region = region_realms.get("region")
        for realm in region_realms.get("results", []):
            realm_data = realm.get("data", {})
            realm_info[region].append(
                {
                    "id": realm_data.get("id"),
                    "slug": realm_data.get("slug"),
                    "region": realm_data.get("region"),
                    "names": realm_data.get("name"),
                }
            )

    return realm_info


async def _fetch_realms(client, region, namespace, page=1):
    url = f"{BASE_URL.format(region)}{REALM_ENDPOINT}?namespace={namespace.format(region)}&orderby=id&_page={page}"
    logger.info(f"Fetching realms from: {url}")
    resp = await client.get(url)
    return resp.json() | {"region": region, "namespace": namespace}


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
        realm_info = await asyncio.gather(
            *[
                _fetch_realms(client, region, namespace)
                for region in REGIONS
                for namespace in NAMESPACES
            ]
        )
    return _parse(realm_info)


if __name__ == "__main__":
    realm_info = asyncio.run(_get_realm_info())
    _create_realm_file(realm_info)
