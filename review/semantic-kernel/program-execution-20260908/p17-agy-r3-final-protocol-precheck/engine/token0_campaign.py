#!/usr/bin/env python3
"""Token0 campaign executing full P16r6 scope on the shared platform engine.

Executes:
1. Compilation of Token0Probe.sol + 6 captured libraries with Solc 0.7.6 Istanbul.
2. Ephemeral Lean model export (P16SourceBindings.lean) via lake env lean.
3. 12 baseline fixtures on Istanbul genesis prestate with returndata vs Lean model comparison.
4. 6 compiled production mutants with designated false detection and unaffected controls.
5. Ordinary-add probe matching Token0Bridge theorem 2^95.
6. Fail-closed P16r6 scoring.
"""
from __future__ import annotations

import difflib
import json
import sys
from pathlib import Path
from typing import Any

ENGINE_DIR = Path(__file__).resolve().parent
sys.path.insert(0, str(ENGINE_DIR))

import common
from common import (  # noqa: E402
    EVIDENCE,
    FROZEN_PROBE,
    FROZEN_PROBE_SHA256,
    SOLC_TOKEN0,
    SOLC_TOKEN0_SHA256,
    TOKEN0_CAPTURE,
    ROOT,
    blocked,
    load_json,
    record_cmd,
    refuse_nonempty_dir,
    sha256_file,
    sha256_text,
    utc_now,
    write_json,
)
from compile import compile_sources, compiler_settings  # noqa: E402
from evm import write_genesis, run_tx  # noqa: E402
from keccak import keccak256  # noqa: E402
from abi import calldata, decode_uint  # noqa: E402
from score import score_rows  # noqa: E402

LIB_NAMES = [
    "FullMath.sol",
    "UnsafeMath.sol",
    "LowGasSafeMath.sol",
    "SafeCast.sol",
    "FixedPoint96.sol",
    "SqrtPriceMath.sol",
]

REQUIRED_P16_IDS = [
    "P16-I-ADD",
    "P16-I-REM",
    "P16-I-ZERO-LIQ",
    "P16-ADD",
    "P16-ADD-ROUND",
    "P16-REQ",
    "P16-REQ-STRICT",
    "P16-REM",
    "P16-SAFECAST",
    "P16-ADD-DEN0",
    "P16-PROD",
    "P16-WRAP",
]

P16_FIXTURES: list[dict[str, Any]] = [
    {
        "id": "P16-I-ADD",
        "inputs": {"sqrtPX96": 79228162514264337593543950336, "liquidity": 1, "amount": 0, "add": True},
        "expected": {"status": "ok", "value": 79228162514264337593543950336},
    },
    {
        "id": "P16-I-REM",
        "inputs": {"sqrtPX96": 79228162514264337593543950336, "liquidity": 1, "amount": 0, "add": False},
        "expected": {"status": "ok", "value": 79228162514264337593543950336},
    },
    {
        "id": "P16-I-ZERO-LIQ",
        "inputs": {"sqrtPX96": 79228162514264337593543950336, "liquidity": 0, "amount": 0, "add": False},
        "expected": {"status": "ok", "value": 79228162514264337593543950336},
    },
    {
        "id": "P16-ADD",
        "inputs": {"sqrtPX96": 79228162514264337593543950336, "liquidity": 1, "amount": 1, "add": True},
        "expected": {"status": "ok", "value": 39614081257132168796771975168},
    },
    {
        "id": "P16-ADD-ROUND",
        "inputs": {"sqrtPX96": 79228162514264337593543950336, "liquidity": 1, "amount": 2, "add": True},
        "expected": {"status": "ok", "value": 26409387504754779197847983446},
    },
    {
        "id": "P16-REQ",
        "inputs": {"sqrtPX96": 79228162514264337593543950336, "liquidity": 1, "amount": 1, "add": False},
        "expected": {"status": "revert", "error": "subUnderflow"},
    },
    {
        "id": "P16-REQ-STRICT",
        "inputs": {"sqrtPX96": 79228162514264337593543950336, "liquidity": 1, "amount": 2, "add": False},
        "expected": {"status": "revert", "error": "subUnderflow"},
    },
    {
        "id": "P16-REM",
        "inputs": {"sqrtPX96": 79228162514264337593543950336, "liquidity": 2, "amount": 1, "add": False},
        "expected": {"status": "ok", "value": 158456325028528675187087900672},
    },
    {
        "id": "P16-SAFECAST",
        "inputs": {"sqrtPX96": 730750818665451459101842416358141509827966271488, "liquidity": 9223372036854775809, "amount": 1, "add": False},
        "expected": {"status": "revert", "error": "uint160Overflow"},
    },
    {
        "id": "P16-ADD-DEN0",
        "inputs": {"sqrtPX96": 0, "liquidity": 0, "amount": 1, "add": True},
        "expected": {"status": "revert", "error": "divisionByZero"},
    },
    {
        "id": "P16-PROD",
        "inputs": {"sqrtPX96": 79228162514264337593543950336, "liquidity": 79228162514264337593543950336, "amount": 1461501637330902918203684832716283019655932542976, "add": True},
        "expected": {"status": "ok", "value": 4294967296},
    },
    {
        "id": "P16-WRAP",
        "inputs": {"sqrtPX96": 1461446703485210103287273052203988822378723970341, "liquidity": 340282366920938463463374607431768211455, "amount": 79231140577496994670249413376, "add": True},
        "expected": {"status": "ok", "value": 340269576638287423012608907232989748562},
    },
]

P16_MUTANTS: list[dict[str, Any]] = [
    {
        "id": "T0-ID-SKIP",
        "class": "identity",
        "find": "        if (amount == 0) return sqrtPX96;\n",
        "replace": "",
        "designated_false": "P16-I-ADD",
        "unaffected_positive": "P16-ADD",
        "planned_designated": {"status": "revert"},
    },
    {
        "id": "T0-WRAP-SKIP",
        "class": "overflow",
        "find": "                if (denominator >= numerator1)\n",
        "replace": "                if (true)\n",
        "designated_false": "P16-WRAP",
        "unaffected_positive": "P16-ADD",
        "planned_designated": {"status": "ok", "value": 1430089493431239948923811608424801982436782118539},
    },
    {
        "id": "T0-PROD-SKIP",
        "class": "overflow",
        "find": "            if ((product = amount * sqrtPX96) / amount == sqrtPX96) {\n                uint256 denominator = numerator1 + product;\n",
        "replace": "            product = amount * sqrtPX96;\n            if (true) {\n                uint256 denominator = numerator1 + product;\n",
        "designated_false": "P16-PROD",
        "unaffected_positive": "P16-ADD",
        "planned_designated": {"status": "ok", "value": 79228162514264337593543950336},
    },
    {
        "id": "T0-REQ-SKIP",
        "class": "boundary",
        "find": "            require((product = amount * sqrtPX96) / amount == sqrtPX96 && numerator1 > product);\n",
        "replace": "            require((product = amount * sqrtPX96) / amount == sqrtPX96);\n",
        "designated_false": "P16-REQ-STRICT",
        "equality_control": "P16-REQ",
        "unaffected_positive": "P16-ADD",
        "planned_designated": {"status": "ok", "value": 1},
    },
    {
        "id": "T0-FLOOR",
        "class": "rounding",
        "find": "                    return uint160(FullMath.mulDivRoundingUp(numerator1, sqrtPX96, denominator));\n",
        "replace": "                    return uint160(FullMath.mulDiv(numerator1, sqrtPX96, denominator));\n",
        "designated_false": "P16-ADD-ROUND",
        "unaffected_positive": "P16-ADD",
        "planned_designated": {"status": "ok", "value": 26409387504754779197847983445},
    },
    {
        "id": "T0-CHECKED-ADD",
        "class": "overflow",
        "find": "                uint256 denominator = numerator1 + product;\n",
        "replace": "                uint256 denominator = numerator1.add(product);\n",
        "designated_false": "P16-WRAP",
        "unaffected_positive": "P16-ADD",
        "planned_designated": {"status": "revert"},
    },
]


def load_sources() -> tuple[dict[str, str], dict[str, str]]:
    sources: dict[str, str] = {}
    roles: dict[str, str] = {}
    if not FROZEN_PROBE.is_file():
        raise FileNotFoundError(f"missing Token0Probe.sol: {FROZEN_PROBE}")
    sources["Token0Probe.sol"] = FROZEN_PROBE.read_text()
    roles["Token0Probe.sol"] = "frozen_probe"
    lib_root = TOKEN0_CAPTURE / "contracts/libraries"
    for name in LIB_NAMES:
        path = lib_root / name
        sources[name] = path.read_text()
        roles[name] = "captured_token0_library"
    return sources, roles


def generate_p16_bindings_lean(path: Path) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    body = []
    for fx in P16_FIXTURES:
        inp = fx["inputs"]
        exp = fx["expected"]
        ok_str = f"some {exp['value']}" if exp["status"] == "ok" else "none"
        err_str = f"some .{exp['error']}" if exp["status"] == "revert" else "none"
        add_str = "true" if inp["add"] else "false"
        fid = fx["id"]
        sqrtP = inp["sqrtPX96"]
        L = inp["liquidity"]
        amount = inp["amount"]
        body.append(
            f'  , {{ id := "{fid}"\n'
            f'      sqrtP := w160 {sqrtP}\n'
            f'      L := w128 {L}\n'
            f'      amount := w256 {amount}\n'
            f'      add := {add_str}\n'
            f'      expectedOk := {ok_str}\n'
            f'      expectedErr := {err_str} }}'
        )
    joined_rows = "\n".join(body)
    code = f"""import DefiKernel.ConcentratedLiquidity.SqrtPriceMath

open DefiKernel.ConcentratedLiquidity
open DefiKernel.ConcentratedLiquidity.SqrtPriceMath

def w128 (n : Nat) (h : n < 2 ^ 128 := by decide) : U128 := ⟨n, h⟩
def w160 (n : Nat) (h : n < 2 ^ 160 := by decide) : U160 := ⟨n, h⟩
def w256 (n : Nat) (h : n < 2 ^ 256 := by decide) : U256 := ⟨n, h⟩

structure Row where
  id : String
  sqrtP : U160
  L : U128
  amount : U256
  add : Bool
  expectedOk : Option Nat
  expectedErr : Option Failure

def showF : Failure → String
  | .divisionByZero => "divisionByZero"
  | .quotientOverflow => "quotientOverflow"
  | .subUnderflow => "subUnderflow"
  | .addOverflow => "addOverflow"
  | .uint160Overflow => "uint160Overflow"

def runRow (r : Row) : IO Bool := do
  let got := getNextSqrtPriceFromAmount0RoundingUp r.sqrtP r.L r.amount r.add
  let actual :=
    match got with
    | .ok q => s!"ok:{{q.value}}"
    | .error e => s!"error:{{showF e}}"
  let agrees :=
    match got, r.expectedOk, r.expectedErr with
    | .ok q, some n, none => decide (q.value = n)
    | .error e, none, some f => decide (e = f)
    | _, _, _ => false
  IO.println s!"{{r.id}} sqrtP={{r.sqrtP.value}} L={{r.L.value}} amount={{r.amount.value}} add={{r.add}} model={{actual}} match={{agrees}}"
  pure agrees

def rows : List Row :=
  [ {{ id := "FIRST_PLACEHOLDER", sqrtP := w160 0, L := w128 0, amount := w256 0, add := false, expectedOk := none, expectedErr := none }}
{joined_rows}
  ].drop 1

def main : IO UInt32 := do
  if rows.isEmpty then
    IO.eprintln "P16 source-binding rows empty"
    return 3
  let ids := rows.map (·.id)
  if !ids.Nodup then
    IO.eprintln "P16 source-binding ids duplicated"
    return 3
  let mut all := true
  for r in rows do
    let m ← runRow r
    all := all && m
  if all then
    IO.println s!"P16 source-binding comparisons: {{rows.length}} of {{rows.length}}"
    return 0
  IO.eprintln "P16 source-binding comparison failed"
  return 1

#eval main
"""
    path.write_text(code)


def run_lean_token0_bindings(ev_dir: Path) -> dict[str, dict]:
    ev_dir.mkdir(parents=True, exist_ok=True)
    lean_file = (ev_dir / "P16SourceBindings.lean").resolve()
    generate_p16_bindings_lean(lean_file)
    logs = ev_dir / "bindings"
    receipt = record_cmd(
        "lean-token0-bindings",
        ["lake", "env", "lean", str(lean_file)],
        ROOT / "lean",
        logs,
        timeout=180,
    )
    stdout_path = Path((receipt.get("_wrapper") or {}).get("stdout_path") or "")
    text = stdout_path.read_text(errors="replace") if stdout_path.is_file() else ""
    parsed: dict[str, dict] = {}
    for line in text.splitlines():
        line = line.strip()
        if not line:
            continue
        parts = line.split()
        if parts and parts[0] in REQUIRED_P16_IDS:
            fid = parts[0]
            row_data: dict[str, Any] = {"id": fid}
            for p in parts[1:]:
                if "=" in p:
                    k, v = p.split("=", 1)
                    if k == "model":
                        if v.startswith("ok:"):
                            row_data["status"] = "ok"
                            row_data["value"] = int(v[3:])
                        elif v.startswith("error:"):
                            row_data["status"] = "error"
                            row_data["error"] = v[6:]
                    elif k == "match":
                        row_data["match"] = (v.lower() == "true")
            parsed[fid] = row_data
    summary = {
        "status": "ok" if len(parsed) == len(REQUIRED_P16_IDS) and all(r.get("match") for r in parsed.values()) else "blocked",
        "receipt": receipt,
        "parsed": parsed,
        "count": len(parsed),
    }
    write_json(ev_dir / "bindings-summary.json", summary)
    return parsed


def execute_probe_tx(
    name: str,
    out_dir: Path,
    probe_addr: str,
    genesis_path: Path,
    sqrtPX96: int,
    liquidity: int,
    amount: int,
    add: bool,
) -> dict[str, Any]:
    sel = keccak256(b"probe(uint160,uint128,uint256,bool)")[:4].hex()
    cd = calldata(sel, sqrtPX96, liquidity, amount, 1 if add else 0)
    return run_tx(
        name,
        out_dir=out_dir,
        genesis_path=genesis_path,
        sender="0x2000000000000000000000000000000000000001",
        receiver=probe_addr,
        code_hex=None,
        input_hex=cd.hex(),
        create=False,
        dump=False,
    )


def run_single_mutant(
    mdef: dict[str, Any],
    sources: dict[str, str],
    roles: dict[str, str],
    baseline_runtime_sha: str,
    out_dir: Path,
) -> dict[str, Any]:
    mid = mdef["id"]
    mout = out_dir / mid
    mout.mkdir(parents=True, exist_ok=True)
    orig_code = sources["SqrtPriceMath.sol"]
    find = mdef["find"]
    replace = mdef["replace"]
    if find not in orig_code:
        rep = blocked(f"mutant target string not found for {mid}")
        write_json(mout / "result.json", rep)
        return rep

    mut_code = orig_code.replace(find, replace, 1)
    mut_sources = dict(sources)
    mut_sources["SqrtPriceMath.sol"] = mut_code
    diff = "".join(
        difflib.unified_diff(
            orig_code.splitlines(keepends=True),
            mut_code.splitlines(keepends=True),
            fromfile="a/SqrtPriceMath.sol",
            tofile="b/SqrtPriceMath.sol",
        )
    )
    (mout / "patch.diff").write_text(diff)

    compile_out = mout / "compile"
    settings = compiler_settings(
        evm_version="istanbul",
        optimizer_runs=800,
        bytecode_hash="none",
    )
    comp_report = compile_sources(
        name=f"token0-mutant-{mid}",
        sources=mut_sources,
        source_roles=roles,
        solc=SOLC_TOKEN0,
        expected_solc_sha=SOLC_TOKEN0_SHA256,
        settings=settings,
        out_dir=compile_out,
        timeout=60.0,
        required=["Token0Probe.sol:Token0Probe"],
    )
    write_json(compile_out / "result.json", {k: comp_report[k] for k in comp_report if k != "artifacts"})
    if comp_report.get("status") != "ok" or comp_report.get("exit") != 0:
        res = blocked(f"mutant {mid} failed compilation", {"compile_report": comp_report})
        write_json(mout / "result.json", res)
        return res

    mut_rt = comp_report["artifacts"]["Token0Probe.sol:Token0Probe"]["runtime"]
    mut_rt_sha = sha256_text(mut_rt)
    runtime_changed = (mut_rt_sha != baseline_runtime_sha)

    probe_addr = "0x1000000000000000000000000000000000000010"
    alloc = {probe_addr: {"code": "0x" + mut_rt, "balance": "0x0"}}
    genesis_path = mout / "genesis.json"
    write_genesis(genesis_path, fork="istanbul", alloc=alloc)

    # Test designated false fixture
    by_id = {f["id"]: f for f in P16_FIXTURES}
    des_fix = by_id[mdef["designated_false"]]
    des_res = execute_probe_tx(
        "designated-false",
        mout / "designated",
        probe_addr,
        genesis_path,
        des_fix["inputs"]["sqrtPX96"],
        des_fix["inputs"]["liquidity"],
        des_fix["inputs"]["amount"],
        des_fix["inputs"]["add"],
    )
    des_status = des_res.get("status")
    des_ret_uint = decode_uint(des_res.get("returndata") or "")
    des_planned = mdef["planned_designated"]

    if des_planned["status"] == "ok":
        detected = (des_status == "ok" and des_ret_uint == des_planned["value"])
    else:
        detected = (des_status in ("revert", "exception"))

    # Test unaffected positive control (P16-ADD)
    ctrl_fix = by_id[mdef["unaffected_positive"]]
    ctrl_res = execute_probe_tx(
        "unaffected-control",
        mout / "unaffected",
        probe_addr,
        genesis_path,
        ctrl_fix["inputs"]["sqrtPX96"],
        ctrl_fix["inputs"]["liquidity"],
        ctrl_fix["inputs"]["amount"],
        ctrl_fix["inputs"]["add"],
    )
    ctrl_status = ctrl_res.get("status")
    ctrl_ret_uint = decode_uint(ctrl_res.get("returndata") or "")
    ctrl_ok = (ctrl_status == "ok" and ctrl_ret_uint == ctrl_fix["expected"]["value"])

    # Optional equality control (e.g. for T0-REQ-SKIP)
    eq_ok = True
    if "equality_control" in mdef:
        eq_fix = by_id[mdef["equality_control"]]
        eq_res = execute_probe_tx(
            "equality-control",
            mout / "equality",
            probe_addr,
            genesis_path,
            eq_fix["inputs"]["sqrtPX96"],
            eq_fix["inputs"]["liquidity"],
            eq_fix["inputs"]["amount"],
            eq_fix["inputs"]["add"],
        )
        eq_status = eq_res.get("status")
        eq_ok = (eq_status in ("revert", "exception"))

    gate = "ok" if (runtime_changed and detected and ctrl_ok and eq_ok) else "fail"
    summary = {
        "id": mid,
        "class": mdef["class"],
        "gate": gate,
        "runtime_changed": runtime_changed,
        "detected": detected,
        "designated_false": {
            "id": mdef["designated_false"],
            "evm_status": des_status,
            "returndata_uint": des_ret_uint,
            "planned": des_planned,
            "detected": detected,
        },
        "unaffected_control": {
            "id": mdef["unaffected_positive"],
            "evm_status": ctrl_status,
            "returndata_uint": ctrl_ret_uint,
            "expected_uint": ctrl_fix["expected"]["value"],
            "preserved": ctrl_ok,
        },
        "equality_control_preserved": eq_ok,
        "diff_sha256": sha256_text(diff),
    }
    write_json(mout / "result.json", summary)
    return summary


def main(evidence_dir: Path | None = None) -> int:
    campaign = common.choose_run_dir(evidence_dir or common.EVIDENCE)

    compile_out = refuse_nonempty_dir(campaign / "evm" / "token0-compile")

    got = sha256_file(FROZEN_PROBE)
    if got != FROZEN_PROBE_SHA256:
        report = blocked(
            "Token0Probe.sol hash drifted",
            {"got": got, "expected": FROZEN_PROBE_SHA256},
        )
        write_json(compile_out / "compile.json", report)
        print(report["reason"])
        return 3

    try:
        sources, roles = load_sources()
    except FileNotFoundError as exc:
        report = blocked(str(exc))
        write_json(compile_out / "compile.json", report)
        print(report["reason"])
        return 3

    settings = compiler_settings(
        evm_version="istanbul",
        optimizer_runs=800,
        bytecode_hash="none",
    )
    compile_report = compile_sources(
        name="token0-solc-0.7.6-istanbul",
        sources=sources,
        source_roles=roles,
        solc=SOLC_TOKEN0,
        expected_solc_sha=SOLC_TOKEN0_SHA256,
        settings=settings,
        out_dir=compile_out,
        timeout=60.0,
        required=["Token0Probe.sol:Token0Probe"],
    )
    write_json(compile_out / "result.json", {k: compile_report[k] for k in compile_report if k != "artifacts"})
    print("token0 compile:", compile_report.get("status"), compile_report.get("exit"))
    if compile_report.get("status") != "ok" or compile_report.get("exit") != 0:
        return 3 if compile_report.get("exit") in (None, 0) else int(compile_report["exit"])

    rt_code = compile_report["artifacts"]["Token0Probe.sol:Token0Probe"]["runtime"]
    baseline_rt_sha = sha256_text(rt_code)

    # 2. Run Lean model bindings
    lean_dir = refuse_nonempty_dir(campaign / "lean" / "token0")
    lean_rows = run_lean_token0_bindings(lean_dir)
    print(f"token0 lean bindings: {len(lean_rows)} rows parsed")

    # 3. Execute 12 baseline fixtures
    exec_dir = refuse_nonempty_dir(campaign / "evm" / "token0-execute")
    probe_addr = "0x1000000000000000000000000000000000000010"
    alloc = {probe_addr: {"code": "0x" + rt_code, "balance": "0x0"}}
    genesis_path = exec_dir / "genesis.json"
    write_genesis(genesis_path, fork="istanbul", alloc=alloc)

    fixture_rows = []
    for fx in P16_FIXTURES:
        fid = fx["id"]
        f_dir = exec_dir / fid
        f_dir.mkdir(parents=True, exist_ok=True)
        inp = fx["inputs"]
        exp = fx["expected"]
        lean_row = lean_rows.get(fid)

        tx_res = execute_probe_tx(
            f"token0-{fid}",
            f_dir,
            probe_addr,
            genesis_path,
            inp["sqrtPX96"],
            inp["liquidity"],
            inp["amount"],
            inp["add"],
        )
        status = tx_res.get("status")

        if exp["status"] == "ok":
            semantic = (status == "ok")
            ret_uint = decode_uint(tx_res.get("returndata") or "")
            ret_match = (ret_uint == exp["value"])
            lean_match = (
                lean_row is not None
                and lean_row.get("status") == "ok"
                and lean_row.get("value") == exp["value"]
            )
            gate = "ok" if (semantic and ret_match and lean_match) else "fail"
            row_entry = {
                "id": fid,
                "comparison": {
                    "gate": gate,
                    "semantic_ok": semantic,
                    "returndata_match": ret_match,
                    "lean_model_match": lean_match,
                    "evm_status": status,
                    "returndata_uint": ret_uint,
                    "expected_uint": exp["value"],
                    "lean_model": lean_row,
                },
            }
        else:
            semantic = (status in ("revert", "exception"))
            lean_match = (
                lean_row is not None
                and lean_row.get("status") == "error"
                and lean_row.get("error") == exp["error"]
            )
            gate = "ok" if (semantic and lean_match) else "fail"
            row_entry = {
                "id": fid,
                "comparison": {
                    "gate": gate,
                    "semantic_ok": semantic,
                    "refusal_match": semantic,
                    "lean_model_match": lean_match,
                    "evm_status": status,
                    "expected_error": exp["error"],
                    "lean_model": lean_row,
                },
            }
        fixture_rows.append(row_entry)
        write_json(f_dir / "observation.json", row_entry)

    scored = score_rows(fixture_rows, REQUIRED_P16_IDS)
    write_json(exec_dir / "rows.json", fixture_rows)
    write_json(exec_dir / "score.json", scored)
    print("token0 baseline score:", scored.get("status"), scored.get("exit"), f"{scored.get('ok')}/{scored.get('denominator')}")

    # 4. Ordinary add probe (matching Token0Bridge theorem 2^95)
    ord_fix = next(f for f in P16_FIXTURES if f["id"] == "P16-ADD")
    ord_row = next(r for r in fixture_rows if r["id"] == "P16-ADD")
    ord_ret = ord_row["comparison"].get("returndata_uint")
    ord_match = (ord_ret == 2**95)
    ord_summary = {
        "status": "ok" if ord_match else "fail",
        "inputs": ord_fix["inputs"],
        "returndata_uint": ord_ret,
        "expected_uint": 2**95,
        "matches_lean_theorem": ord_match,
    }
    write_json(exec_dir / "ordinary-add-summary.json", ord_summary)
    print(f"token0 ordinary-add matches theorem 2^95: {ord_match}")

    # 5. Execute 6 compiled production mutants
    mutants_dir = refuse_nonempty_dir(campaign / "evm" / "token0-mutants")
    mutant_results: dict[str, Any] = {}
    mutants_ok = True
    for mdef in P16_MUTANTS:
        res = run_single_mutant(mdef, sources, roles, baseline_rt_sha, mutants_dir)
        mutant_results[mdef["id"]] = res
        print(f"Token0 mutant {mdef['id']}: gate={res.get('gate')} detected={res.get('detected')} controls_ok={res.get('unaffected_control', {}).get('preserved')}")
        if res.get("gate") != "ok":
            mutants_ok = False

    mutants_summary = {
        "status": "ok" if mutants_ok else "fail",
        "timestamp_utc": utc_now(),
        "mutants": mutant_results,
    }
    write_json(mutants_dir / "summary.json", mutants_summary)

    overall_ok = (scored.get("status") == "ok" and mutants_ok and ord_match)
    overall_summary = {
        "status": "ok" if overall_ok else "fail",
        "timestamp_utc": utc_now(),
        "baseline_score": scored,
        "ordinary_add": ord_summary,
        "mutants": mutants_summary,
    }
    write_json(exec_dir / "summary.json", overall_summary)
    return 0 if overall_ok else 1


if __name__ == "__main__":
    raise SystemExit(main())
