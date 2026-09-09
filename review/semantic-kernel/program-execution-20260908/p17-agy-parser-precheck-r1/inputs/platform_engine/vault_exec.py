#!/usr/bin/env python3
"""Vault deploy, observe, and fixture execution on the shared engine."""
from __future__ import annotations

import json
from pathlib import Path
from typing import Any

from abi import calldata, decode_uint, encode_address, encode_address_bytes, encode_word, strip0x
from common import (
    EVIDENCE,
    OBSERVED_CELLS,
    VAULT_FIXTURE_IDS,
    ROOT,
    blocked,
    load_json,
    write_json,
)
from evm import run_tx, write_genesis
from score import score_rows

S = "0x1111111111111111111111111111111111110001"
R = "0x1111111111111111111111111111111111110002"
O = "0x1111111111111111111111111111111111110003"
P = "0x1111111111111111111111111111111111110004"
VOW = "0x1111111111111111111111111111111111110005"
ZERO = "0x0000000000000000000000000000000000000000"
ALIAS = {"S": S, "R": R, "O": O, "P": P, "ZERO": ZERO}
RAY = 10**27
WAD = 10**18
TS = 1700000000
COMPILE = EVIDENCE / "evm" / "compile" / "compile.json"
FIXTURES = ROOT / "openspec/changes/vault-platform-reuse-p17/fixtures.json"


def _hex(code: str) -> str:
    return strip0x(code)


def _artifacts() -> dict:
    data = load_json(COMPILE)
    if data.get("status") != "ok":
        raise RuntimeError("vault compile is not ok")
    return data["artifacts"]


def _created(alloc: dict, prev: dict) -> str | None:
    for addr, acc in alloc.items():
        code = (acc.get("code") or "").replace("0x", "")
        if code and addr.lower() not in {a.lower() for a in prev}:
            return addr
    # fallback: any new code-bearing account
    for addr, acc in alloc.items():
        code = (acc.get("code") or "").replace("0x", "")
        if len(code) > 2:
            if addr.lower() not in {a.lower() for a in prev}:
                return addr
    return None


def _create(name: str, out: Path, genesis: Path, sender: str, creation: str, ctor: str, prev_alloc: dict) -> tuple[str, dict, Path]:
    step = out / name
    res = run_tx(
        name,
        out_dir=step,
        genesis_path=genesis,
        sender=sender,
        receiver=None,
        code_hex=_hex(creation),
        input_hex=_hex(ctor) if ctor else "",
        create=True,
        dump=True,
        purpose="create",
    )
    if res.get("status") != "ok":
        raise RuntimeError(f"{name} create blocked: {res.get('reason')}")
    alloc = res["alloc"]
    addr = _created(alloc, prev_alloc)
    if not addr:
        raise RuntimeError(f"{name} created address missing")
    gen = step / "genesis.json"
    write_genesis(gen, fork="shanghai", alloc=alloc, timestamp=TS)
    return addr, alloc, gen


def _call(name: str, out: Path, genesis: Path, sender: str, receiver: str, data: bytes, dump: bool) -> dict:
    return run_tx(
        name,
        out_dir=out / name,
        genesis_path=genesis,
        sender=sender,
        receiver=receiver,
        code_hex=None,
        input_hex=data.hex(),
        create=False,
        dump=dump,
        purpose="call" if not dump else "create",
    )


def deploy(out: Path) -> dict:
    arts = _artifacts()
    sender = S
    alloc = {
        S: {"balance": hex(10**21), "nonce": "0x0"},
        R: {"balance": hex(10**18), "nonce": "0x0"},
        O: {"balance": hex(10**18), "nonce": "0x0"},
        P: {"balance": hex(10**18), "nonce": "0x0"},
        VOW: {"balance": hex(10**18), "nonce": "0x0"},
    }
    gen = out / "genesis0.json"
    write_genesis(gen, fork="shanghai", alloc=alloc, timestamp=TS)
    vat, alloc, gen = _create("create-vat", out, gen, sender, arts["test/mocks/VatMock.sol:VatMock"]["creation"], "", alloc)
    usds, alloc, gen = _create("create-usds", out, gen, sender, arts["test/mocks/UsdsMock.sol:UsdsMock"]["creation"], "", alloc)
    join_ctor = (encode_address(vat) + encode_address(usds)).hex()
    join, alloc, gen = _create(
        "create-join", out, gen, sender, arts["test/mocks/UsdsJoinMock.sol:UsdsJoinMock"]["creation"], join_ctor, alloc
    )
    susds_ctor = (encode_address(join) + encode_address(VOW)).hex()
    impl, alloc, gen = _create("create-susds-impl", out, gen, sender, arts["src/SUsds.sol:SUsds"]["creation"], susds_ctor, alloc)
    init = bytes.fromhex("8129fc1c")
    proxy_ctor = encode_address_bytes(impl, init).hex()
    vault, alloc, gen = _create(
        "create-proxy",
        out,
        gen,
        sender,
        arts["@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol:ERC1967Proxy"]["creation"],
        proxy_ctor,
        alloc,
    )
    addrs = {"S": S, "R": R, "O": O, "P": P, "vow": VOW, "vat": vat, "usds": usds, "join": join, "impl": impl, "vault": vault}
    write_json(out / "addresses.json", addrs)
    return {"addresses": addrs, "alloc": alloc, "genesis": str(gen)}


def view_uint(out: Path, genesis: Path, sender: str, receiver: str, data: bytes, name: str) -> int | None:
    res = _call(name, out, genesis, sender, receiver, data, dump=False)
    if res.get("status") != "ok":
        return None
    return decode_uint(res.get("returndata") or "")


def observe(out: Path, genesis: Path, addrs: dict) -> dict:
    vault, usds = addrs["vault"], addrs["usds"]
    cells: dict[str, Any] = {}
    cells["timestamp"] = str(TS)
    chi = view_uint(out, genesis, S, vault, calldata("c92aecc4"), "view-chi")
    rho = view_uint(out, genesis, S, vault, calldata("20aba08b"), "view-rho")
    ssr = view_uint(out, genesis, S, vault, calldata("03607ceb"), "view-ssr")
    cells["chi"] = None if chi is None else str(chi)
    cells["rho"] = None if rho is None else str(rho)
    cells["ssr"] = None if ssr is None else str(ssr)
    cells["initialized"] = chi is not None and chi > 0
    cells["susds.totalSupply"] = str(view_uint(out, genesis, S, vault, calldata("18160ddd"), "view-sts") or 0)
    for label, addr in [("S", S), ("R", R), ("O", O), ("P", P)]:
        v = view_uint(out, genesis, S, vault, calldata("70a08231", addr), f"view-sbal-{label}")
        cells[f"susds.balance.{label}"] = str(v or 0)
    cells["susds.allowance.O.P"] = str(view_uint(out, genesis, S, vault, calldata("dd62ed3e", O, P), "view-sallow") or 0)
    cells["usds.totalSupply"] = str(view_uint(out, genesis, S, usds, calldata("18160ddd"), "view-uts") or 0)
    for label, addr in [("S", S), ("R", R), ("O", O), ("P", P), ("vault", vault)]:
        v = view_uint(out, genesis, S, usds, calldata("70a08231", addr), f"view-ubal-{label}")
        cells[f"usds.balance.{label}"] = str(v or 0)
    cells["usds.allowance.S.vault"] = str(view_uint(out, genesis, S, usds, calldata("dd62ed3e", S, vault), "view-uallow-S") or 0)
    cells["usds.allowance.O.vault"] = str(view_uint(out, genesis, S, usds, calldata("dd62ed3e", O, vault), "view-uallow-O") or 0)
    missing = [k for k in OBSERVED_CELLS if k not in cells or cells[k] is None]
    if missing:
        return {"status": "blocked", "reason": "incomplete 19-cell observation", "missing": missing, "cells": cells}
    return {"status": "ok", "cells": cells}


def seed_slot(alloc: dict, addr: str, slot: int, value: int) -> None:
    acc = alloc.setdefault(addr.lower(), {})
    storage = acc.setdefault("storage", {})
    storage["0x" + slot.to_bytes(32, "big").hex()] = "0x" + value.to_bytes(32, "big").hex()


def map_slot(key: str, slot: int) -> int:
    from keccak import keccak256
    return int.from_bytes(keccak256(encode_address(key) + encode_word(slot)), "big")


def nested_map_slot(outer: str, inner: str, slot: int) -> int:
    from keccak import keccak256
    inner_slot = keccak256(encode_address(outer) + encode_word(slot))
    return int.from_bytes(keccak256(encode_address(inner) + inner_slot), "big")


def apply_funding(out: Path, genesis: Path, addrs: dict, usds_s: int, allow: int) -> Path:
    """Mint USDS to S and approve vault. Independent of vault deposit."""
    usds, vault = addrs["usds"], addrs["vault"]
    mint = calldata("40c10f19", S, usds_s)
    res = _call("mint-usds", out, genesis, S, usds, mint, dump=True)
    if res.get("status") != "ok":
        raise RuntimeError(f"mint usds blocked: {res.get('reason')}")
    gen = out / "mint-usds" / "genesis.json"
    write_genesis(gen, fork="shanghai", alloc=res["alloc"], timestamp=TS)
    if allow:
        appr = calldata("095ea7b3", vault, allow)
        res = _call("approve-usds", out, gen, S, usds, appr, dump=True)
        if res.get("status") != "ok":
            raise RuntimeError(f"approve blocked: {res.get('reason')}")
        gen = out / "approve-usds" / "genesis.json"
        write_genesis(gen, fork="shanghai", alloc=res["alloc"], timestamp=TS)
    return gen


def _resolve_addr(name: str, addrs: dict) -> str:
    if name in ALIAS:
        return ALIAS[name]
    if name == "vault":
        return addrs["vault"]
    return addrs.get(name, name)


def _op_calldata(fx: dict, addrs: dict) -> tuple[str, bytes]:
    op = fx["operation"]
    inp = fx["inputs"]
    sender = _resolve_addr(inp.get("msg.sender", "S"), addrs)
    if op == "deposit":
        data = calldata("6e553f65", int(inp["assets"]), _resolve_addr(inp["receiver"], addrs))
    elif op == "mint":
        data = calldata("94bf804d", int(inp["shares"]), _resolve_addr(inp["receiver"], addrs))
    elif op == "withdraw":
        data = calldata(
            "b460af94",
            int(inp["assets"]),
            _resolve_addr(inp["receiver"], addrs),
            _resolve_addr(inp["owner"], addrs),
        )
    elif op == "redeem":
        data = calldata(
            "ba087652",
            int(inp["shares"]),
            _resolve_addr(inp["receiver"], addrs),
            _resolve_addr(inp["owner"], addrs),
        )
    else:
        raise RuntimeError(f"unknown operation {op}")
    return sender, data


def materialize_pre(out: Path, genesis: Path, addrs: dict, pre: dict) -> Path:
    """Build fixture prestate from initialized proxy. Storage seeds are labelled."""
    gen_dir = genesis.parent
    alloc_path = gen_dir / "alloc.json"
    if alloc_path.is_file():
        alloc = load_json(alloc_path)
    else:
        gen_obj = load_json(genesis)
        alloc = gen_obj.get("alloc")
        if not isinstance(alloc, dict):
            raise RuntimeError("missing alloc beside genesis")
    vault, usds = addrs["vault"].lower(), addrs["usds"].lower()
    chi = int(pre["chi"])
    rho = int(pre["rho"])
    packed = chi | (rho << 192)
    seed_slot(alloc, vault, 5, packed)
    seed_slot(alloc, vault, 6, int(pre["ssr"]))
    seed_slot(alloc, vault, 1, int(pre["susds.totalSupply"]))
    for label, addr in [("S", S), ("R", R), ("O", O), ("P", P)]:
        seed_slot(alloc, vault, map_slot(addr, 2), int(pre[f"susds.balance.{label}"]))
    seed_slot(alloc, vault, nested_map_slot(O, P, 3), int(pre["susds.allowance.O.P"]))
    # USDS token: mint via storage (independent of vault deposit).
    seed_slot(alloc, usds, 1, int(pre["usds.totalSupply"]))
    for label, addr in [("S", S), ("R", R), ("O", O), ("P", P), ("vault", addrs["vault"])]:
        seed_slot(alloc, usds, map_slot(addr, 2), int(pre[f"usds.balance.{label}"]))
    seed_slot(alloc, usds, nested_map_slot(S, addrs["vault"], 3), int(pre["usds.allowance.S.vault"]))
    seed_slot(alloc, usds, nested_map_slot(O, addrs["vault"], 3), int(pre["usds.allowance.O.vault"]))
    gen = out / "pre-genesis.json"
    write_genesis(gen, fork="shanghai", alloc=alloc, timestamp=TS)
    write_json(out / "pre-alloc.json", alloc)
    write_json(
        out / "pre-seed-roles.json",
        {
            "chi_setup": pre.get("chi_setup"),
            "chi_setup_protocol_reachable": pre.get("chi_setup_protocol_reachable"),
            "chi_setup_is_harness_assumption": pre.get("chi_setup_is_harness_assumption"),
            "susds_shares": "storage_seed_not_deposit",
            "usds_balances": "storage_seed_not_vault_transfer",
        },
    )
    return gen


def expected_cells(pre: dict, expected: dict) -> dict | None:
    if expected.get("post") == "omitted":
        return {k: pre[k] for k in OBSERVED_CELLS if k in pre}
    post = dict(pre)
    for k, v in (expected.get("post") or {}).items():
        post[k] = v if not isinstance(v, bool) else v
    return {k: post[k] for k in OBSERVED_CELLS if k in post}


def compare_cells(observed: dict, expected: dict) -> dict:
    diffs = []
    for k in OBSERVED_CELLS:
        if k not in expected:
            return {"gate": "blocked", "reason": f"expected missing cell {k}"}
        if k not in observed:
            return {"gate": "blocked", "reason": f"observed missing cell {k}"}
        ev, ov = expected[k], observed[k]
        if isinstance(ev, bool):
            ok = bool(ov) == ev
        else:
            ok = str(ov) == str(ev)
        if not ok:
            diffs.append({"cell": k, "expected": ev, "observed": ov})
    if diffs:
        return {"gate": "fail", "diffs": diffs}
    return {"gate": "ok"}


def run_fixtures(out: Path, addrs: dict, init_genesis: Path) -> dict:
    data = load_json(FIXTURES)
    fixtures = [fx for fx in data["fixtures"] if fx.get("scored_source")]
    # RR-5 delegated-exit is required but not in the frozen 16-row file.
    delegated = {
        "id": "P17-RED-DELEGATED",
        "scored_source": True,
        "operation": "redeem",
        "domain": "D0",
        "inputs": {"shares": str(WAD), "receiver": "R", "owner": "O", "msg.sender": "P"},
        "pre": {
            "initialized": True,
            "chi": str(RAY),
            "ssr": str(RAY),
            "rho": str(TS),
            "timestamp": str(TS),
            "chi_setup": "initialize_sets_chi_RAY",
            "chi_setup_protocol_reachable": True,
            "chi_setup_is_harness_assumption": False,
            "susds.totalSupply": str(WAD),
            "susds.balance.S": "0",
            "susds.balance.R": "0",
            "susds.balance.O": str(WAD),
            "susds.balance.P": "0",
            "susds.allowance.O.P": str(WAD),
            "usds.totalSupply": str(WAD),
            "usds.balance.S": "0",
            "usds.balance.R": "0",
            "usds.balance.O": "0",
            "usds.balance.P": "0",
            "usds.balance.vault": str(WAD),
            "usds.allowance.S.vault": "0",
            "usds.allowance.O.vault": "0",
        },
        "expected": {
            "status": "success",
            "ok_assets": str(WAD),
            "post": {
                "susds.totalSupply": "0",
                "susds.balance.O": "0",
                "susds.allowance.O.P": "0",
                "usds.balance.R": str(WAD),
                "usds.balance.vault": "0",
            },
        },
    }
    fixtures = fixtures + [delegated]
    rows = []
    for fx in fixtures:
        fid = fx["id"]
        step = out / fid
        step.mkdir(parents=True, exist_ok=True)
        try:
            pre_gen = materialize_pre(step, init_genesis, addrs, fx["pre"])
            pre_obs = observe(step / "pre-obs", pre_gen, addrs)
            if pre_obs.get("status") != "ok":
                rows.append({"id": fid, "comparison": {"gate": "blocked", "reason": pre_obs.get("reason")}})
                continue
            pre_cmp = compare_cells(pre_obs["cells"], {k: fx["pre"][k] for k in OBSERVED_CELLS})
            if pre_cmp["gate"] != "ok":
                rows.append({"id": fid, "comparison": {"gate": "blocked", "reason": "prestate mismatch", **pre_cmp}})
                continue
            sender, data = _op_calldata(fx, addrs)
            call_res = _call("op", step, pre_gen, sender, addrs["vault"], data, dump=True)
            want = fx["expected"]["status"]
            if call_res.get("class") == "dump":
                # dump run stole returndata; classify from a second non-dump call
                cls = _call("op-returndata", step, pre_gen, sender, addrs["vault"], data, dump=False)
                post_gen = step / "op" / "genesis.json"
                write_genesis(post_gen, fork="shanghai", alloc=call_res["alloc"], timestamp=TS)
            else:
                cls = call_res
                post_gen = pre_gen
            post_obs = observe(step / "post-obs", post_gen, addrs)
            if post_obs.get("status") != "ok":
                rows.append({"id": fid, "comparison": {"gate": "blocked", "reason": post_obs.get("reason")}})
                continue
            status = cls.get("status")
            if want == "success":
                semantic = status == "ok"
            elif want == "revert":
                semantic = status in ("revert", "exception")
            else:
                rows.append({"id": fid, "comparison": {"gate": "blocked", "reason": f"unknown expected status {want}"}})
                continue
            exp_cells = expected_cells(fx["pre"], fx["expected"])
            cell_cmp = compare_cells(post_obs["cells"], exp_cells)
            if want == "revert":
                # refusal retains supplied prestate
                cell_cmp = compare_cells(post_obs["cells"], {k: fx["pre"][k] for k in OBSERVED_CELLS})
            gate = "ok" if semantic and cell_cmp.get("gate") == "ok" else "fail"
            if cell_cmp.get("gate") == "blocked":
                gate = "blocked"
            rows.append(
                {
                    "id": fid,
                    "comparison": {
                        "gate": gate,
                        "semantic_ok": semantic,
                        "cells": cell_cmp,
                        "evm_status": status,
                        "returndata": cls.get("returndata"),
                    },
                }
            )
        except Exception as exc:
            rows.append({"id": fid, "comparison": {"gate": "blocked", "reason": str(exc)}})
    scored = score_rows(rows, [fx["id"] for fx in fixtures])
    write_json(out / "rows.json", rows)
    write_json(out / "score.json", scored)
    return scored
