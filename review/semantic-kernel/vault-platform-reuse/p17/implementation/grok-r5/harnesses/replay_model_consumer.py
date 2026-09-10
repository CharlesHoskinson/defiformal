#!/usr/bin/env python3
"""Candidate-local retarget of Opus C6 / R3 model-consumer boundary suite.

Provenance: p17-implementation-opus-review-r1/work/checks/replay_r4_model_consumer.py
(reviewer-authored copy of the R3 boundary checks). Imports candidate
scripts/platform_engine. Exits nonzero on classification mismatch.
"""
from __future__ import annotations

import copy
import json
import os
import sys
from pathlib import Path


def find_root(start: Path) -> Path:
    for p in [start, *start.parents]:
        if (p / "scripts/platform_engine").is_dir() and (p / "lean").is_dir():
            return p
    raise RuntimeError(f"worktree root not found from {start}")


ROOT = find_root(Path(__file__).resolve())
ENGINE = ROOT / "scripts/platform_engine"
sys.dont_write_bytecode = True
sys.path.insert(0, str(ENGINE))
import vault_exec  # noqa: E402
import token0_campaign  # noqa: E402

EV = Path(os.environ.get(
    "DEFIFORMAL_EVIDENCE_DIR",
    str(ROOT / "review/semantic-kernel/vault-platform-reuse/p17/implementation/grok-r5"),
))
RUN = EV / os.environ.get("DEFIFORMAL_RUN_DIR", "attempt-1")
OUT = RUN / "harness-model-consumer"
addresses = json.loads((RUN / "evm/execute/deploy/addresses.json").read_text())
genesis = RUN / "evm/execute/deploy/create-proxy/genesis.json"
intact = json.loads((RUN / "lean/vault/bindings-summary.json").read_text())["parsed"]


def main() -> int:
    OUT.mkdir(parents=True, exist_ok=True)
    results = []
    model_cases = [
        ("intact", lambda x: x, 0),
        ("missing-all-cells", lambda x: (x["P17-DEP-D0"].pop("cells"), x)[1], 3),
        ("missing-one-cell", lambda x: (x["P17-DEP-D0"]["cells"].pop("susds.totalSupply"), x)[1], 3),
        ("missing-model-row", lambda x: {}, 3),
    ]
    for name, modify, expected in model_cases:
        rows = modify(copy.deepcopy(intact))
        got = vault_exec.run_fixtures(
            OUT / "execution" / name, addresses, genesis, fixture_ids=["P17-DEP-D0"], lean_rows=rows
        )
        results.append({
            "id": name,
            "expected_consumer_exit": expected,
            "actual_exit": got.get("exit"),
            "matched": got.get("exit") == expected,
        })

    receipt_cases = [
        ("intact-receipt", {}, False),
        ("nonzero-receipt", {"exit": 1, "classification": "nonzero"}, True),
        ("blocked-receipt-zero-exit", {"exit": 0, "classification": "timeout_blocked", "valid": False, "timeout": True}, True),
    ]
    for module, prefix in [(vault_exec, "vault"), (token0_campaign, "token0")]:
        summary = json.loads((RUN / f"lean/{prefix}/bindings-summary.json").read_text())
        stdout_path = RUN / f"lean/{prefix}/bindings/stdout.bin"
        orig_record_cmd = module.record_cmd
        for name, changes, expect_block in receipt_cases:
            receipt = copy.deepcopy(summary["receipt"])
            receipt.update(changes)
            receipt.setdefault("_wrapper", {})["stdout_path"] = str(stdout_path)
            module.record_cmd = lambda *a, _rec=receipt, **k: copy.deepcopy(_rec)
            error, parsed = None, {}
            try:
                func = module.run_lean_vault_bindings if prefix == "vault" else module.run_lean_token0_bindings
                parsed = func(OUT / "parser-execution" / f"{prefix}-{name}")
            except Exception as exc:
                error = f"{type(exc).__name__}: {exc}"
            blocked = error is not None or not parsed
            results.append({
                "id": f"{prefix}-{name}",
                "expected_blocked": expect_block,
                "actual_blocked": blocked,
                "matched": blocked == expect_block,
                "exception": error,
            })
        module.record_cmd = orig_record_cmd

    matched = sum(r["matched"] for r in results)
    report = {
        "engine": str(ENGINE),
        "vault_run": str(RUN),
        "provenance": "Opus reviewer C6 retargeted at candidate engine",
        "review_authorship": "claude-opus-5 session a1e40b81-7427-45e5-8b00-b2492cd46156",
        "checks": len(results),
        "matched": matched,
        "results": results,
        "exit": 0 if matched == len(results) else 1,
    }
    (OUT / "results.json").write_text(json.dumps(report, indent=2) + "\n")
    print(json.dumps({
        "checks": report["checks"],
        "matched": report["matched"],
        "exit": report["exit"],
        "failed_ids": [r["id"] for r in results if not r["matched"]],
        "consumer_exits": {r["id"]: r.get("actual_exit", r.get("actual_blocked")) for r in results},
    }))
    return int(report["exit"])


if __name__ == "__main__":
    raise SystemExit(main())
