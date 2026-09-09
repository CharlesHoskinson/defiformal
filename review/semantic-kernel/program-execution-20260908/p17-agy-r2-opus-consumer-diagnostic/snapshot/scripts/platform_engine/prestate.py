#!/usr/bin/env python3
"""Genesis prestate helpers. Dump JSON is not genesis; convert accounts to alloc.

Missing/unusable dump is blocked, never a semantic observation.
"""
from __future__ import annotations

from typing import Any

from common import blocked


SHANGHAI_GENESIS_TEMPLATE = {
    "config": {
        "chainId": 1,
        "homesteadBlock": 0,
        "eip150Block": 0,
        "eip155Block": 0,
        "eip158Block": 0,
        "byzantiumBlock": 0,
        "constantinopleBlock": 0,
        "petersburgBlock": 0,
        "istanbulBlock": 0,
        "muirGlacierBlock": 0,
        "berlinBlock": 0,
        "londonBlock": 0,
        "arrowGlacierBlock": 0,
        "grayGlacierBlock": 0,
        "mergeNetsplitBlock": 0,
        "shanghaiTime": 0,
    },
    "nonce": "0x0",
    "timestamp": "0x0",
    "extraData": "0x",
    "gasLimit": hex(10_000_000_000),
    "difficulty": "0x1",
    "mixHash": "0x0000000000000000000000000000000000000000000000000000000000000000",
    "coinbase": "0x0000000000000000000000000000000000000000",
    "alloc": {},
    "number": "0x0",
    "gasUsed": "0x0",
    "parentHash": "0x0000000000000000000000000000000000000000000000000000000000000000",
}

ISTANBUL_GENESIS_TEMPLATE = {
    "config": {
        "chainId": 1,
        "homesteadBlock": 0,
        "eip150Block": 0,
        "eip155Block": 0,
        "eip158Block": 0,
        "byzantiumBlock": 0,
        "constantinopleBlock": 0,
        "petersburgBlock": 0,
        "istanbulBlock": 0,
    },
    "nonce": "0x0",
    "timestamp": "0x0",
    "extraData": "0x",
    "gasLimit": hex(10_000_000_000),
    "difficulty": "0x1",
    "mixHash": "0x0000000000000000000000000000000000000000000000000000000000000000",
    "coinbase": "0x0000000000000000000000000000000000000000",
    "alloc": {},
    "number": "0x0",
    "gasUsed": "0x0",
    "parentHash": "0x0000000000000000000000000000000000000000000000000000000000000000",
}


def dump_to_alloc(dump: dict[str, Any]) -> dict:
    """Convert geth evm --dump JSON {root,accounts} into genesis alloc."""
    if not isinstance(dump, dict):
        raise ValueError("dump is not an object")
    accounts = dump.get("accounts")
    if not isinstance(accounts, dict) or not accounts:
        raise ValueError("dump missing accounts")
    alloc: dict[str, Any] = {}
    for addr, acc in accounts.items():
        if not isinstance(acc, dict):
            raise ValueError(f"account {addr} is not an object")
        entry: dict[str, Any] = {}
        if "balance" in acc:
            entry["balance"] = acc["balance"]
        if "nonce" in acc:
            nonce = acc["nonce"]
            entry["nonce"] = hex(nonce) if isinstance(nonce, int) else nonce
        if acc.get("code"):
            entry["code"] = acc["code"]
        if acc.get("storage"):
            entry["storage"] = acc["storage"]
        alloc[addr.lower()] = entry
    return alloc


def genesis_from_dump(template: dict, dump: dict[str, Any]) -> dict:
    alloc = dump_to_alloc(dump)
    genesis = dict(template)
    genesis["alloc"] = alloc
    return genesis


def blocked_missing_dump(reason: str) -> dict:
    return blocked(reason, {"class": "blocked_missing_evm"})
