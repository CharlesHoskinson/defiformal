#!/usr/bin/env python3
"""Vault deploy, observe, and fixture execution on the shared engine."""
from __future__ import annotations

import json
import re
from pathlib import Path
from typing import Any

import common
from abi import calldata, decode_uint, encode_address, encode_address_bytes, encode_word, strip0x
from common import (
    OBSERVED_CELLS,
    VAULT_FIXTURE_IDS,
    ROOT,
    blocked,
    load_json,
    record_cmd,
    validate_model_receipt,
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
FIXTURES = ROOT / "openspec/changes/vault-platform-reuse-p17/fixtures.json"

GETH_LOG_RE = re.compile(r"^(INFO|DEBUG|WARN|ERROR)\s*\[")

CELL_KEY_MAP = {
    "initialized": "initialized",
    "chi": "chi",
    "ssr": "ssr",
    "rho": "rho",
    "timestamp": "timestamp",
    "susds_totalSupply": "susds.totalSupply",
    "susds_balance_S": "susds.balance.S",
    "susds_balance_R": "susds.balance.R",
    "susds_balance_O": "susds.balance.O",
    "susds_balance_P": "susds.balance.P",
    "susds_allowance_O_P": "susds.allowance.O.P",
    "usds_totalSupply": "usds.totalSupply",
    "usds_balance_S": "usds.balance.S",
    "usds_balance_R": "usds.balance.R",
    "usds_balance_O": "usds.balance.O",
    "usds_balance_P": "usds.balance.P",
    "usds_balance_vault": "usds.balance.vault",
    "usds_allowance_S_vault": "usds.allowance.S.vault",
    "usds_allowance_O_vault": "usds.allowance.O.vault",
}


VAULT_ERROR_CONTEXT_MAP = {
    # deposit delegates transfer to external USDS token contract, so transfer failures have Usds/ prefix
    ("deposit", "SUsds/insufficient-balance"): "Usds/insufficient-balance",
    ("deposit", "SUsds/insufficient-allowance"): "Usds/insufficient-allowance",
    # deposit receiver validation happens in SUsds
    ("deposit", "SUsds/invalid-address"): "SUsds/invalid-address",
    # checked arithmetic panic
    ("deposit", "Panic(0x11)"): "Panic(0x11)",
    ("mint", "Panic(0x11)"): "Panic(0x11)",
    ("withdraw", "Panic(0x11)"): "Panic(0x11)",
    ("redeem", "Panic(0x11)"): "Panic(0x11)",
    # mint delegates transfer to USDS
    ("mint", "SUsds/insufficient-balance"): "Usds/insufficient-balance",
    ("mint", "SUsds/insufficient-allowance"): "Usds/insufficient-allowance",
    ("mint", "SUsds/invalid-address"): "SUsds/invalid-address",
    # redeem/withdraw burns SUsds internal shares, so failures have SUsds/ prefix
    ("redeem", "SUsds/insufficient-balance"): "SUsds/insufficient-balance",
    ("redeem", "SUsds/insufficient-allowance"): "SUsds/insufficient-allowance",
    ("redeem", "SUsds/invalid-address"): "SUsds/invalid-address",
    ("withdraw", "SUsds/insufficient-balance"): "SUsds/insufficient-balance",
    ("withdraw", "SUsds/insufficient-allowance"): "SUsds/insufficient-allowance",
    ("withdraw", "SUsds/invalid-address"): "SUsds/invalid-address",
}


def check_refusal_correspondence(operation: str, lean_failure: str, evm_error: str) -> tuple[str, str]:
    """Map Lean refusal label to expected EVM error via declared origin/context mapping.
    Returns (gate, reason). Gate is 'ok', 'fail', or 'blocked'.
    """
    key = (operation, lean_failure)
    if key not in VAULT_ERROR_CONTEXT_MAP:
        return ("blocked", f"unmapped refusal label ({operation}, {lean_failure})")
    expected_evm = VAULT_ERROR_CONTEXT_MAP[key]
    if expected_evm == evm_error:
        return ("ok", "")
    return ("fail", f"refusal mismatch: expected {expected_evm}, got {evm_error}")



def _hex(code: str) -> str:
    return strip0x(code)


def compile_artifact_path(evidence_dir: Path | None = None) -> Path:
    ev = evidence_dir or common.EVIDENCE
    return ev / "evm" / "compile" / "compile.json"


def _artifacts(compile_path: Path | None = None) -> dict:
    cp = compile_path or compile_artifact_path()
    data = load_json(cp)
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


def _call(name: str, out: Path, genesis: Path, sender: str, receiver: str, data: bytes, dump: bool, trace: bool = False) -> dict:
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
        trace=trace,
    )


def deploy(out: Path, compile_path: Path | None = None) -> dict:
    arts = _artifacts(compile_path)
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


def parse_logs_from_trace(stderr: str, addrs: dict[str, str]) -> list[dict[str, Any]]:
    logs = []
    inv_alias = {addr.lower(): label for label, addr in ALIAS.items()}
    for k, v in addrs.items():
        if isinstance(v, str) and v.startswith("0x"):
            inv_alias[v.lower()] = k

    TOPIC_DRIP = "0xad1e8a53178522eb68a9d94d862bf30c841f709d2115f743eb6b34528751c79f"
    TOPIC_TRANSFER = "0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef"
    TOPIC_DEPOSIT = "0xdcbc1c05240f31ff3ad067ef1ee35ce4997762752e3a095284754544f4c709d7"
    TOPIC_WITHDRAW = "0xfbde797d201c681b91056529119e0b02407c7bb96a4a2c75c01fc9667232c8db"
    TOPIC_APPROVAL = "0x8c5be1e5ebec7d5bd14f71427d1e84f3dd0314c0f7b2291e5b200ac8c7c3b925"

    vault_addr = addrs["vault"].lower()
    frames = [vault_addr]
    next_frame_contract = None

    for line in stderr.splitlines():
        line_str = line.strip()
        if not line_str:
            continue
        if GETH_LOG_RE.match(line_str):
            continue
        try:
            entry = json.loads(line_str)
        except Exception as exc:
            raise ValueError(f"malformed trace json: {line_str}") from exc

        op = entry.get("opName")
        if op is None and "output" in entry:
            continue

        depth = entry.get("depth", 1)
        stack = entry.get("stack") or []

        if depth < 1:
            raise ValueError(f"invalid depth {depth}")
        if depth > len(frames) + 1:
            raise ValueError(f"impossible depth jump: depth {depth} exceeds frames {len(frames)}")
        if depth > len(frames):
            if next_frame_contract is None:
                raise ValueError(f"depth increased to {depth} without prior call opcode")
            frames.append(next_frame_contract)
            next_frame_contract = None
        while len(frames) > depth:
            frames.pop()

        current_this = frames[-1] if frames else vault_addr
        emitter_lbl = inv_alias.get(current_this, current_this)

        if op in ("CALL", "STATICCALL"):
            if len(stack) >= 2:
                target = "0x" + strip0x(stack[-2]).zfill(40)[-40:].lower()
                next_frame_contract = target
        elif op in ("DELEGATECALL", "CALLCODE"):
            next_frame_contract = current_this

        if op and op.startswith("LOG"):
            if len(stack) < 2:
                logs.append({"emitter": emitter_lbl, "name": "MALFORMED_LOG_STACK"})
                continue
            offset = int(stack[-1], 16)
            size = int(stack[-2], 16)
            mem_hex = strip0x(entry.get("memory") or "")
            if len(mem_hex) < (offset + size) * 2:
                raise ValueError(
                    f"truncated memory for {op}: available {len(mem_hex)//2} bytes, need {offset + size} bytes"
                )
            data = bytes.fromhex(mem_hex[offset * 2 : (offset + size) * 2])

            if op == "LOG0":
                logs.append({"emitter": emitter_lbl, "name": "LOG0", "data": data.hex()})
            elif op == "LOG1":
                topic0 = stack[-3].lower()
                if topic0 == TOPIC_DRIP:
                    chi = int.from_bytes(data[:32], "big")
                    diff = int.from_bytes(data[32:64], "big")
                    logs.append({"emitter": emitter_lbl, "name": "Drip", "chi": str(chi), "diff": str(diff)})
                else:
                    logs.append({"emitter": emitter_lbl, "name": f"Unknown_LOG1_{topic0}", "data": data.hex()})
            elif op == "LOG2":
                topic0 = stack[-3].lower()
                logs.append({"emitter": emitter_lbl, "name": f"Unknown_LOG2_{topic0}", "data": data.hex()})
            elif op == "LOG3":
                topic0 = stack[-3].lower()
                if topic0 == TOPIC_TRANSFER:
                    from_raw = "0x" + strip0x(stack[-4]).zfill(40)[-40:].lower()
                    to_raw = "0x" + strip0x(stack[-5]).zfill(40)[-40:].lower()
                    from_lbl = inv_alias.get(from_raw, from_raw)
                    to_lbl = inv_alias.get(to_raw, to_raw)
                    if from_lbl == "0x0000000000000000000000000000000000000000":
                        from_lbl = "ZERO"
                    if to_lbl == "0x0000000000000000000000000000000000000000":
                        to_lbl = "ZERO"
                    val = int.from_bytes(data[:32], "big")
                    logs.append({"emitter": emitter_lbl, "name": "Transfer", "from": from_lbl, "to": to_lbl, "value": str(val)})
                elif topic0 == TOPIC_APPROVAL:
                    owner_raw = "0x" + strip0x(stack[-4]).zfill(40)[-40:].lower()
                    spender_raw = "0x" + strip0x(stack[-5]).zfill(40)[-40:].lower()
                    owner_lbl = inv_alias.get(owner_raw, owner_raw)
                    spender_lbl = inv_alias.get(spender_raw, spender_raw)
                    val = int.from_bytes(data[:32], "big")
                    logs.append({"emitter": emitter_lbl, "name": "Approval", "owner": owner_lbl, "spender": spender_lbl, "value": str(val)})
                elif topic0 == TOPIC_DEPOSIT:
                    sender_raw = "0x" + strip0x(stack[-4]).zfill(40)[-40:].lower()
                    owner_raw = "0x" + strip0x(stack[-5]).zfill(40)[-40:].lower()
                    assets = int.from_bytes(data[:32], "big")
                    shares = int.from_bytes(data[32:64], "big")
                    logs.append({
                        "emitter": emitter_lbl,
                        "name": "Deposit",
                        "sender": inv_alias.get(sender_raw, sender_raw),
                        "owner": inv_alias.get(owner_raw, owner_raw),
                        "assets": str(assets),
                        "shares": str(shares),
                    })
                else:
                    logs.append({"emitter": emitter_lbl, "name": f"Unknown_LOG3_{topic0}", "data": data.hex()})
            elif op == "LOG4":
                topic0 = stack[-3].lower()
                if topic0 == TOPIC_WITHDRAW:
                    sender_raw = "0x" + strip0x(stack[-4]).zfill(40)[-40:].lower()
                    recv_raw = "0x" + strip0x(stack[-5]).zfill(40)[-40:].lower()
                    owner_raw = "0x" + strip0x(stack[-6]).zfill(40)[-40:].lower()
                    assets = int.from_bytes(data[:32], "big")
                    shares = int.from_bytes(data[32:64], "big")
                    logs.append({
                        "emitter": emitter_lbl,
                        "name": "Withdraw",
                        "sender": inv_alias.get(sender_raw, sender_raw),
                        "receiver": inv_alias.get(recv_raw, recv_raw),
                        "owner": inv_alias.get(owner_raw, owner_raw),
                        "assets": str(assets),
                        "shares": str(shares),
                    })
                else:
                    logs.append({"emitter": emitter_lbl, "name": f"Unknown_LOG4_{topic0}", "data": data.hex()})

    return logs


def generate_vault_bindings_lean(path: Path) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    code = """import DefiKernel.Vault.Examples

open DefiKernel.Vault
open DefiKernel.Vault.Examples

def formatRow (id : String) (res : Except DefiKernel.Vault.Failure (Ledger × DefiKernel.Arithmetic.Word 256)) : String :=
  match res with
  | .ok (st, w) =>
    s!"{id} status=ok value={w.value} initialized=true chi={st.chi.value} ssr={st.ssr.value} rho={st.rho} timestamp={st.timestamp} susds_totalSupply={st.totalSupply.value} susds_balance_S={st.susds .S} susds_balance_R={st.susds .R} susds_balance_O={st.susds .O} susds_balance_P={st.susds .P} susds_allowance_O_P={st.susdsAllow .O .P} usds_totalSupply={st.usdsSupply} usds_balance_S={st.usds .S} usds_balance_R={st.usds .R} usds_balance_O={st.usds .O} usds_balance_P={st.usds .P} usds_balance_vault={st.usds .vault} usds_allowance_S_vault={st.usdsAllow .S .vault} usds_allowance_O_vault={st.usdsAllow .O .vault}"
  | .error e => s!"{id} status=error failure={DefiKernel.Vault.sourceLabel e}"

def main : IO UInt32 := do
  let dep0 := deposit fundedDeposit wad .R .S
  let mint0 := mint fundedDeposit wad .R .S
  let red0 := redeem fundedRedeem wad .R .O .O
  let wd0 := withdraw fundedRedeem wad .R .O .O
  let dep1 := deposit fundedDepositD1 wad .R .S
  let mint1 := mint fundedMintD1 wad .R .S
  let red1 := redeem fundedRedeemD1 wad .R .O .O
  let wd1 := withdraw fundedRedeemD1 wad .R .O .O
  let zero := deposit emptyLedger ⟨0, Nat.succ_pos _⟩ .R .S
  let bad := deposit fundedDeposit wad .zero .S
  let self := deposit fundedDeposit wad .vault .S
  let tfBal := deposit emptyLedger wad .R .S
  let tfAllow := deposit { emptyLedger with
    usds := fun a => if a = .S then WAD else 0
    usdsSupply := WAD } wad .R .S
  let redBal := redeem emptyLedger ⟨1, by decide⟩ .R .O .O
  let redAllow := redeem fundedRedeem wad .R .O .P
  let ovf := deposit emptyLedger ovfAssets .R .S
  let del := redeem fundedDelegated wad .R .O .P

  let rows := [
    formatRow "P17-DEP-D0" dep0,
    formatRow "P17-MINT-D0" mint0,
    formatRow "P17-RED-D0" red0,
    formatRow "P17-WD-D0" wd0,
    formatRow "P17-DEP-D1" dep1,
    formatRow "P17-MINT-D1" mint1,
    formatRow "P17-RED-D1" red1,
    formatRow "P17-WD-D1" wd1,
    formatRow "P17-DEP-ZERO" zero,
    formatRow "P17-DEP-BAD-RECV" bad,
    formatRow "P17-DEP-SELF" self,
    formatRow "P17-DEP-TF-BAL" tfBal,
    formatRow "P17-DEP-TF-ALLOW" tfAllow,
    formatRow "P17-RED-BAL" redBal,
    formatRow "P17-RED-ALLOW" redAllow,
    formatRow "P17-DEP-MUL-OVF" ovf,
    formatRow "P17-RED-DELEGATED" del
  ]
  for line in rows do
    IO.println line
  return 0

#eval main
"""
    path.write_text(code)


def run_lean_vault_bindings(ev_dir: Path) -> dict[str, dict]:
    ev_dir.mkdir(parents=True, exist_ok=True)
    lean_file = (ev_dir / "P17VaultBindings.lean").resolve()
    generate_vault_bindings_lean(lean_file)
    logs = ev_dir / "bindings"
    receipt = record_cmd(
        "lean-vault-bindings",
        ["lake", "env", "lean", str(lean_file)],
        ROOT / "lean",
        logs,
        timeout=180,
    )
    validate_model_receipt(receipt, "lean-vault-bindings")
    stdout_path = Path((receipt.get("_wrapper") or {}).get("stdout_path") or receipt.get("stdout_path") or "")
    if not stdout_path.is_file():
        raise RuntimeError(f"lean-vault-bindings stdout file missing: {stdout_path}")
    text = stdout_path.read_text(errors="replace")
    parsed = {}
    for line in text.splitlines():
        line = line.strip()
        if not line:
            continue
        parts = line.split()
        if len(parts) >= 2 and parts[0].startswith("P17-"):
            fid = parts[0]
            if fid not in VAULT_FIXTURE_IDS:
                raise RuntimeError(f"unexpected fixture id from Lean output: {fid}")
            if fid in parsed:
                raise RuntimeError(f"duplicate fixture id from Lean output: {fid}")
            row_data = {"id": fid}
            cells = {}
            for p in parts[1:]:
                if "=" in p:
                    k, v = p.split("=", 1)
                    if k == "value":
                        row_data[k] = int(v)
                    elif k == "status":
                        row_data[k] = v
                    elif k == "failure":
                        row_data[k] = v
                    elif k in CELL_KEY_MAP:
                        cell_name = CELL_KEY_MAP[k]
                        if k == "initialized":
                            cells[cell_name] = (v.lower() == "true")
                        else:
                            cells[cell_name] = str(int(v))
            if cells:
                row_data["cells"] = cells
            parsed[fid] = row_data

    missing_ids = [fid for fid in VAULT_FIXTURE_IDS if fid not in parsed]
    if missing_ids:
        raise RuntimeError(f"missing Lean model output for fixtures: {missing_ids}")

    for fid, row_data in parsed.items():
        st = row_data.get("status")
        if st == "ok":
            row_cells = row_data.get("cells")
            if not isinstance(row_cells, dict):
                raise RuntimeError(f"Lean row {fid} status ok but missing cells dict")
            missing_cells = [c for c in OBSERVED_CELLS if c not in row_cells]
            if missing_cells:
                raise RuntimeError(f"Lean row {fid} missing observed cells: {missing_cells}")
        elif st == "error":
            if not row_data.get("failure"):
                raise RuntimeError(f"Lean row {fid} status error but missing failure label")
        else:
            raise RuntimeError(f"Lean row {fid} invalid status: {st!r}")

    summary = {
        "status": "ok" if len(parsed) == len(VAULT_FIXTURE_IDS) else "blocked",
        "receipt": receipt,
        "parsed": parsed,
        "count": len(parsed),
    }
    write_json(ev_dir / "bindings-summary.json", summary)
    return parsed


def compare_logs(observed_logs: list[dict], expected_logs: list[dict]) -> dict[str, Any]:
    if observed_logs == expected_logs:
        return {"gate": "ok"}
    return {
        "gate": "fail",
        "reason": "full_logs mismatch",
        "observed": observed_logs,
        "expected": expected_logs,
    }


def run_fixtures(
    out: Path,
    addrs: dict,
    init_genesis: Path,
    fixture_ids: list[str] | None = None,
    lean_rows: dict | None = None,
) -> dict:
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
            "full_logs": [
                {"emitter": "vault", "name": "Drip", "chi": str(RAY), "diff": "0"},
                {"emitter": "usds", "name": "Transfer", "from": "vault", "to": "R", "value": str(WAD)},
                {"emitter": "vault", "name": "Transfer", "from": "O", "to": "ZERO", "value": str(WAD)},
                {"emitter": "vault", "name": "Withdraw", "sender": "P", "receiver": "R", "owner": "O", "assets": str(WAD), "shares": str(WAD)},
            ],
        },
    }
    fixtures = fixtures + [delegated]
    if fixture_ids is not None:
        fixtures = [fx for fx in fixtures if fx["id"] in fixture_ids]

    lean_error = None
    if lean_rows is None:
        lean_dir = (
            out.parent.parent.parent / "lean" / "vault"
            if out.name == "fixtures" and out.parent.name == "execute" and out.parent.parent.name == "evm"
            else out.parent / "lean" / "vault"
        )
        try:
            lean_rows = run_lean_vault_bindings(lean_dir)
        except Exception as exc:
            lean_rows = None
            lean_error = str(exc)

    rows = []
    for fx in fixtures:
        fid = fx["id"]
        step = out / fid
        step.mkdir(parents=True, exist_ok=True)

        if lean_rows is None:
            r_entry = {
                "id": fid,
                "comparison": {
                    "gate": "blocked",
                    "reason": f"lean_model_bindings_failed: {lean_error}",
                },
            }
            rows.append(r_entry)
            write_json(step / "observation.json", r_entry)
            continue

        lean_row = lean_rows.get(fid)
        if lean_row is None:
            r_entry = {
                "id": fid,
                "comparison": {
                    "gate": "blocked",
                    "reason": f"missing model row for {fid}",
                },
            }
            rows.append(r_entry)
            write_json(step / "observation.json", r_entry)
            continue

        try:
            pre_gen = materialize_pre(step, init_genesis, addrs, fx["pre"])
            pre_obs = observe(step / "pre-obs", pre_gen, addrs)
            if pre_obs.get("status") != "ok":
                r_entry = {"id": fid, "comparison": {"gate": "blocked", "reason": pre_obs.get("reason")}}
                rows.append(r_entry)
                write_json(step / "observation.json", r_entry)
                continue
            pre_cmp = compare_cells(pre_obs["cells"], {k: fx["pre"][k] for k in OBSERVED_CELLS})
            if pre_cmp["gate"] != "ok":
                r_entry = {"id": fid, "comparison": {"gate": "blocked", "reason": "prestate mismatch", "diffs": pre_cmp.get("diffs")}}
                rows.append(r_entry)
                write_json(step / "observation.json", r_entry)
                continue
            sender, data = _op_calldata(fx, addrs)
            want = fx["expected"]["status"]
            lean_row = lean_rows.get(fid)

            if want == "success":
                call_res = _call("op", step, pre_gen, sender, addrs["vault"], data, dump=True)
                if call_res.get("status") == "blocked":
                    r_entry = {"id": fid, "comparison": {"gate": "blocked", "reason": call_res.get("reason"), "evm_status": "blocked"}}
                    rows.append(r_entry)
                    write_json(step / "observation.json", r_entry)
                    continue
                cls = _call("op-returndata", step, pre_gen, sender, addrs["vault"], data, dump=False, trace=True)
                if cls.get("status") == "blocked":
                    r_entry = {"id": fid, "comparison": {"gate": "blocked", "reason": cls.get("reason"), "evm_status": "blocked"}}
                    rows.append(r_entry)
                    write_json(step / "observation.json", r_entry)
                    continue
                post_gen = step / "op" / "genesis.json"
                write_genesis(post_gen, fork="shanghai", alloc=call_res["alloc"], timestamp=TS)
                post_obs = observe(step / "post-obs", post_gen, addrs)
                if post_obs.get("status") != "ok":
                    r_entry = {"id": fid, "comparison": {"gate": "blocked", "reason": post_obs.get("reason")}}
                    rows.append(r_entry)
                    write_json(step / "observation.json", r_entry)
                    continue
                status = cls.get("status")
                semantic = status == "ok"
                exp_cells = expected_cells(fx["pre"], fx["expected"])
                cell_cmp = compare_cells(post_obs["cells"], exp_cells)

                returndata_cmp = {"gate": "ok"}
                if "ok_shares" in fx["expected"]:
                    want_shares = str(fx["expected"]["ok_shares"])
                    got_shares = decode_uint(cls.get("returndata") or "")
                    if got_shares is None or str(got_shares) != want_shares:
                        returndata_cmp = {"gate": "fail", "reason": "ok_shares mismatch", "want": want_shares, "got": str(got_shares)}
                elif "ok_assets" in fx["expected"]:
                    want_assets = str(fx["expected"]["ok_assets"])
                    got_assets = decode_uint(cls.get("returndata") or "")
                    if got_assets is None or str(got_assets) != want_assets:
                        returndata_cmp = {"gate": "fail", "reason": "ok_assets mismatch", "want": want_assets, "got": str(got_assets)}

                try:
                    observed_logs = parse_logs_from_trace(cls.get("trace_stderr") or "", addrs)
                    if "full_logs" in fx["expected"]:
                        log_cmp = compare_logs(observed_logs, fx["expected"]["full_logs"])
                    else:
                        log_cmp = {"gate": "ok"}
                except Exception as exc:
                    observed_logs = []
                    log_cmp = {"gate": "blocked", "reason": f"log_parse_error: {exc}"}

                lean_model_ok = (lean_row is not None and lean_row.get("status") == "ok")
                lean_cells_cmp = {"gate": "ok"}
                if not lean_model_ok:
                    lean_cells_cmp = {"gate": "fail", "reason": "lean_model_status_not_ok"}
                elif "cells" not in lean_row:
                    lean_cells_cmp = {"gate": "blocked", "reason": "missing poststate cells in lean model row"}
                    lean_model_ok = False
                else:
                    lean_cells_cmp = compare_cells(post_obs["cells"], lean_row["cells"])
                    if lean_cells_cmp.get("gate") != "ok":
                        lean_model_ok = False
                    if "ok_shares" in fx["expected"]:
                        if lean_row.get("value") != int(fx["expected"]["ok_shares"]):
                            lean_model_ok = False
                    elif "ok_assets" in fx["expected"]:
                        if lean_row.get("value") != int(fx["expected"]["ok_assets"]):
                            lean_model_ok = False

                lean_model_match = bool(lean_model_ok and semantic and lean_cells_cmp.get("gate") == "ok")

                gate = "ok"
                if cell_cmp.get("gate") == "blocked":
                    gate = "blocked"
                elif log_cmp.get("gate") == "blocked":
                    gate = "blocked"
                elif lean_cells_cmp.get("gate") == "blocked":
                    gate = "blocked"
                elif not semantic:
                    gate = "fail"
                elif cell_cmp.get("gate") != "ok":
                    gate = cell_cmp.get("gate")
                elif returndata_cmp.get("gate") != "ok":
                    gate = returndata_cmp.get("gate")
                elif log_cmp.get("gate") != "ok":
                    gate = log_cmp.get("gate")
                elif lean_cells_cmp.get("gate") != "ok":
                    gate = lean_cells_cmp.get("gate")
                elif not lean_model_match:
                    gate = "fail"

                r_entry = {
                    "id": fid,
                    "comparison": {
                        "gate": gate,
                        "semantic_ok": semantic,
                        "cells": cell_cmp,
                        "returndata_cmp": returndata_cmp,
                        "log_cmp": log_cmp,
                        "lean_model": lean_row,
                        "lean_cells_cmp": lean_cells_cmp,
                        "lean_model_match": lean_model_match,
                        "evm_status": status,
                        "returndata": cls.get("returndata"),
                        "observed_logs": observed_logs,
                    },
                }
                rows.append(r_entry)
                write_json(step / "observation.json", r_entry)

            elif want == "revert":
                cls = _call("op-returndata", step, pre_gen, sender, addrs["vault"], data, dump=False)
                status = cls.get("status")
                if status == "blocked":
                    r_entry = {"id": fid, "comparison": {"gate": "blocked", "reason": cls.get("reason"), "evm_status": "blocked"}}
                    rows.append(r_entry)
                    write_json(step / "observation.json", r_entry)
                    continue
                semantic = status in ("revert", "exception")
                want_error = fx["expected"].get("error")
                got_error = cls.get("decoded_error")
                refusal_ok = (got_error == want_error) if want_error else True

                lean_status = lean_row.get("status") if lean_row else None
                lean_failure = lean_row.get("failure") if lean_row else None

                if lean_status != "error" or not lean_failure:
                    gate = "blocked" if not lean_failure else "fail"
                    lean_model_match = False
                else:
                    corr_gate, corr_reason = check_refusal_correspondence(fx["operation"], lean_failure, got_error or "")
                    if corr_gate == "blocked":
                        gate = "blocked"
                        lean_model_match = False
                    elif corr_gate == "ok" and semantic and refusal_ok:
                        gate = "ok"
                        lean_model_match = True
                    else:
                        gate = "fail"
                        lean_model_match = False
                r_entry = {
                    "id": fid,
                    "comparison": {
                        "gate": gate,
                        "semantic_ok": semantic,
                        "refusal_match": refusal_ok,
                        "lean_model": lean_row,
                        "lean_model_match": lean_model_match,
                        "evm_status": status,
                        "returndata": cls.get("returndata"),
                        "decoded_error": got_error,
                        "expected_error": want_error,
                        "selector": cls.get("selector"),
                        "pre_retained": True,
                        "rollback_verification": False,
                    },
                }
                rows.append(r_entry)
                write_json(step / "observation.json", r_entry)
            else:
                r_entry = {"id": fid, "comparison": {"gate": "blocked", "reason": f"unknown expected status {want}"}}
                rows.append(r_entry)
                write_json(step / "observation.json", r_entry)
        except Exception as exc:
            r_entry = {"id": fid, "comparison": {"gate": "blocked", "reason": str(exc)}}
            rows.append(r_entry)
            write_json(step / "observation.json", r_entry)
    scored = score_rows(rows, [fx["id"] for fx in fixtures])
    write_json(out / "rows.json", rows)
    write_json(out / "score.json", scored)
    return scored

