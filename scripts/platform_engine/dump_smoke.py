#!/usr/bin/env python3
"""Unscored evm --dump roundtrip smoke and missing-dump control (task 2.3).

Not a production fixture and not mutation detection. Missing/unusable dump is
blocked_missing_evm / exit 3.
"""
from __future__ import annotations

import sys
from pathlib import Path

ENGINE_DIR = Path(__file__).resolve().parent
sys.path.insert(0, str(ENGINE_DIR))

from common import EVIDENCE, blocked, choose_run_dir, refuse_nonempty_dir, write_json  # noqa: E402
from evm import parse_dump, run_tx, write_genesis  # noqa: E402
from prestate import dump_to_alloc  # noqa: E402
from compile import compile_sources  # noqa: E402
import json  # noqa: E402

SENDER = "0x1111111111111111111111111111111111110001"


def main() -> int:
    campaign = choose_run_dir(EVIDENCE)
    out = refuse_nonempty_dir(campaign / "dump-smoke")
    compile_json = EVIDENCE.parent / "agy-r4/attempt-1/evm/compile/compile.json"
    # Prefer this attempt's compile, then any grok-r5 attempt, else frozen R4 bytes.
    local = list((campaign / "evm" / "compile").glob("compile.json"))
    if not local:
        local = list(EVIDENCE.glob("attempt-*/evm/compile/compile.json"))
    if local:
        compile_json = local[0]
    if not compile_json.is_file():
        report = blocked(
            "no compile artifacts for dump smoke",
            {"class": "blocked_missing_evm", "missing_identity": "compile.json"},
        )
        write_json(out / "result.json", report)
        print(json.dumps(report))
        return 3
    arts = json.loads(compile_json.read_text())["artifacts"]
    vat = arts["test/mocks/VatMock.sol:VatMock"]["creation"]
    if vat.startswith("0x"):
        vat = vat[2:]
    alloc = {SENDER: {"balance": hex(10**18), "nonce": "0x0"}}
    gen = out / "genesis.json"
    write_genesis(gen, fork="shanghai", alloc=alloc, timestamp=1700000000)
    intact = run_tx(
        "dump-smoke-create",
        out_dir=out / "intact",
        genesis_path=gen,
        sender=SENDER,
        receiver=None,
        code_hex=vat,
        input_hex="",
        create=True,
        dump=True,
        purpose="create",
    )
    intact_ok = intact.get("status") == "ok" and bool(intact.get("alloc"))
    # Missing-dump control: empty stdout is unusable.
    missing = parse_dump("")
    missing_report = blocked(
        "missing or unusable evm dump JSON",
        {"class": "blocked_missing_evm", "missing_identity": "evm-dump"},
    )
    if missing is not None:
        missing_report = {
            "status": "fail",
            "exit": 1,
            "reason": "empty dump unexpectedly parsed",
        }
    result = {
        "intact_roundtrip": {
            "ok": intact_ok,
            "class": intact.get("class"),
            "n_accounts": len(intact.get("alloc") or {}),
            "root": intact.get("root"),
        },
        "missing_dump_control": missing_report,
        "status": "ok" if intact_ok and missing_report.get("exit") == 3 else "blocked",
        "exit": 0 if intact_ok and missing_report.get("exit") == 3 else 3,
    }
    write_json(out / "result.json", result)
    print(json.dumps({"status": result["status"], "exit": result["exit"],
                      "intact_ok": intact_ok, "missing_class": missing_report.get("class")}))
    return int(result["exit"])


if __name__ == "__main__":
    raise SystemExit(main())
