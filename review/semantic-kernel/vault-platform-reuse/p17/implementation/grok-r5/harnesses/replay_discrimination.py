#!/usr/bin/env python3
"""Candidate-local retarget of Opus reviewer discrimination controls (C7).

Provenance: review/semantic-kernel/program-execution-20260908/p17-implementation-opus-review-r1/work/checks/replay_r4_opus_falsifiers.py
(reviewer-authored). Engine import is the candidate scripts/platform_engine.
Exits nonzero when expected classifications mismatch.
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

EV = Path(os.environ.get(
    "DEFIFORMAL_EVIDENCE_DIR",
    str(ROOT / "review/semantic-kernel/vault-platform-reuse/p17/implementation/grok-r5"),
))
RUN = EV / os.environ.get("DEFIFORMAL_RUN_DIR", "attempt-1")
OUT = RUN / "harness-discrimination"
addresses = json.loads((RUN / "evm/execute/deploy/addresses.json").read_text())
genesis = RUN / "evm/execute/deploy/create-proxy/genesis.json"
intact = json.loads((RUN / "lean/vault/bindings-summary.json").read_text())["parsed"]


def perturb_cell(rows):
    rows["P17-DEP-D0"]["cells"]["usds.balance.vault"] = "1"
    return rows


def perturb_value(rows):
    rows["P17-DEP-D0"]["value"] = 12345
    return rows


def wrong_refusal_label(rows):
    rows["P17-DEP-BAD-RECV"]["failure"] = "SUsds/insufficient-balance"
    return rows


def unmapped_refusal_label(rows):
    rows["P17-DEP-BAD-RECV"]["failure"] = "SUsds/not-a-real-error"
    return rows


def model_ok_where_source_reverts(rows):
    rows["P17-DEP-BAD-RECV"] = {
        "id": "P17-DEP-BAD-RECV",
        "status": "ok",
        "value": 0,
        "cells": copy.deepcopy(intact["P17-DEP-D0"]["cells"]),
    }
    return rows


def model_error_where_source_succeeds(rows):
    rows["P17-DEP-D0"] = {"id": "P17-DEP-D0", "status": "error", "failure": "SUsds/invalid-address"}
    return rows


CASES = [
    ("c1-intact-control", ["P17-DEP-D0", "P17-DEP-BAD-RECV"], lambda r: r, 0),
    ("c2-model-cell-perturbed", ["P17-DEP-D0"], perturb_cell, 1),
    ("c3-model-return-value-perturbed", ["P17-DEP-D0"], perturb_value, 1),
    ("c4-wrong-refusal-label", ["P17-DEP-BAD-RECV"], wrong_refusal_label, 1),
    ("c5-unmapped-refusal-label", ["P17-DEP-BAD-RECV"], unmapped_refusal_label, 3),
    ("c6-model-ok-where-source-reverts", ["P17-DEP-BAD-RECV"], model_ok_where_source_reverts, 1),
    ("c7-model-error-where-source-succeeds", ["P17-DEP-D0"], model_error_where_source_succeeds, 1),
]


def main() -> int:
    OUT.mkdir(parents=True, exist_ok=True)
    results = []
    for name, fids, fn, expected in CASES:
        rows = fn(copy.deepcopy(intact))
        got = vault_exec.run_fixtures(OUT / name, addresses, genesis, fixture_ids=fids, lean_rows=rows)
        results.append({
            "id": name,
            "expected_exit": expected,
            "actual_exit": got.get("exit"),
            "actual_status": got.get("status"),
            "counts": {k: got.get(k) for k in ("ok", "fail", "blocked", "denominator")},
            "matched": got.get("exit") == expected,
        })
    matched = sum(r["matched"] for r in results)
    report = {
        "engine": str(ENGINE),
        "vault_run": str(RUN),
        "provenance": "Opus reviewer C7 retargeted at candidate engine",
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
        "consumer_exits": {r["id"]: r["actual_exit"] for r in results},
    }))
    return int(report["exit"])


if __name__ == "__main__":
    raise SystemExit(main())
