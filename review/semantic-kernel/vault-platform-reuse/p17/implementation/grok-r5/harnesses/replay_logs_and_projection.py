#!/usr/bin/env python3
"""Candidate-local log falsifiers plus R-9 vault emitter projection.

Provenance of log falsifiers: Opus reviewer replay_logs_extended_opus.py.
Uses the current campaign P17-DEP-D0 trace, addresses and expected full_logs.
Exits nonzero on classification mismatch.
"""
from __future__ import annotations

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
from vault_exec import (  # noqa: E402
    compare_logs,
    parse_logs_from_trace,
    vault_emitter_projection,
)

EV = Path(os.environ.get(
    "DEFIFORMAL_EVIDENCE_DIR",
    str(ROOT / "review/semantic-kernel/vault-platform-reuse/p17/implementation/grok-r5"),
))
RUN = EV / os.environ.get("DEFIFORMAL_RUN_DIR", "attempt-1")
OUT = RUN / "harness-logs-projection"
FIXTURES = ROOT / "openspec/changes/vault-platform-reuse-p17/fixtures.json"


def main() -> int:
    OUT.mkdir(parents=True, exist_ok=True)
    addresses_path = RUN / "evm/execute/deploy/addresses.json"
    trace_path = RUN / "evm/execute/fixtures/P17-DEP-D0/op-returndata/record/stderr.bin"
    obs_path = RUN / "evm/execute/fixtures/P17-DEP-D0/observation.json"
    if not addresses_path.is_file() or not trace_path.is_file() or not obs_path.is_file():
        report = {
            "status": "blocked",
            "exit": 3,
            "reason": "missing current P17-DEP-D0 campaign trace/observation",
            "addresses": str(addresses_path),
            "trace": str(trace_path),
            "observation": str(obs_path),
        }
        (OUT / "result.json").write_text(json.dumps(report, indent=2) + "\n")
        print(json.dumps(report))
        return 3

    addresses = json.loads(addresses_path.read_text())
    trace = trace_path.read_text(errors="replace")
    fixtures = json.loads(FIXTURES.read_text())["fixtures"]
    expected = next(f["expected"]["full_logs"] for f in fixtures if f["id"] == "P17-DEP-D0")
    obs = json.loads(obs_path.read_text())

    extra = json.dumps(
        {"pc": 0, "op": 160, "opName": "LOG0", "stack": ["0x0", "0x0"],
         "depth": 2, "memory": "0x", "memSize": 0},
        separators=(",", ":"),
    )
    lines = trace.splitlines()
    shortened = list(lines)
    for i, line in enumerate(shortened):
        if '"opName":"LOG1"' in line:
            event = json.loads(line)
            offset = int(event["stack"][-1], 16)
            size = int(event["stack"][-2], 16)
            if size != 64:
                continue
            memory = event["memory"].removeprefix("0x")
            event["memory"] = "0x" + memory[:(offset + 32) * 2]
            shortened[i] = json.dumps(event, separators=(",", ":"))
            break
    else:
        report = {"status": "blocked", "exit": 3, "reason": "actual trace lacks Drip LOG1"}
        (OUT / "result.json").write_text(json.dumps(report, indent=2) + "\n")
        print(json.dumps(report))
        return 3

    changed_call = list(lines)
    for i, line in enumerate(changed_call):
        if not line.startswith("{"):
            continue
        entry = json.loads(line)
        if entry.get("opName") == "CALL" and int(entry["stack"][-2], 16) == int(addresses["usds"], 16):
            entry["stack"][-2] = "0x" + "5" * 40
            changed_call[i] = json.dumps(entry, separators=(",", ":"))
            break
    else:
        report = {"status": "blocked", "exit": 3, "reason": "actual trace lacks external USDS CALL"}
        (OUT / "result.json").write_text(json.dumps(report, indent=2) + "\n")
        print(json.dumps(report))
        return 3

    invalid_depth = list(lines)
    for i, line in enumerate(invalid_depth):
        if '"opName":"LOG1"' in line:
            event = json.loads(line)
            event["depth"] = 999
            invalid_depth[i] = json.dumps(event, separators=(",", ":"))
            break

    results = []
    for name, raw, should_pass in [
        ("actual-intact-deposit", trace, True),
        ("malformed-LOG-JSON", "\n".join(lines[:-1] + ['{"opName":"LOG3",broken'] + lines[-1:]), False),
        ("impossible-log-depth-jump", "\n".join(invalid_depth), False),
        ("changed-external-call-emitter", "\n".join(changed_call), False),
        ("extra-LOG0-record", "\n".join(lines[:-1] + [extra] + lines[-1:]), False),
        ("truncated-Drip-memory", "\n".join(shortened), False),
    ]:
        try:
            decoded = parse_logs_from_trace(raw, addresses)
            comparison = compare_logs(decoded, expected)
            passed = comparison.get("gate") == "ok"
        except Exception as exc:
            decoded, comparison, passed = None, {"exception": str(exc)}, False
        results.append({
            "id": name,
            "expected_acceptance": should_pass,
            "actual_comparison": comparison,
            "matches_required_behavior": passed == should_pass,
        })

    # R-9: emitter==vault projection on the actual deposit observation.
    full = obs.get("comparison", {}).get("observed_logs") or []
    recorded_proj = obs.get("comparison", {}).get("vault_projection")
    computed_proj = vault_emitter_projection(full)
    usds_full = [e for e in full if e.get("emitter") == "usds"]
    usds_proj = [e for e in computed_proj if e.get("emitter") == "usds"]
    expected_proj = vault_emitter_projection(expected)
    proj_cmp = compare_logs(computed_proj, expected_proj)
    recorded_matches = recorded_proj == computed_proj
    projection_ok = (
        bool(usds_full)
        and not usds_proj
        and proj_cmp.get("gate") == "ok"
        and recorded_matches
        and any(e.get("name") == "Transfer" for e in usds_full)
    )
    results.append({
        "id": "r9-deposit-usds-in-full-absent-from-vault-projection",
        "expected_acceptance": True,
        "usds_in_full_logs": usds_full,
        "usds_in_vault_projection": usds_proj,
        "projection_cmp": proj_cmp,
        "recorded_matches_computed": recorded_matches,
        "matches_required_behavior": projection_ok,
    })

    # Projection falsifiers: emitter, order, content.
    if computed_proj:
        emitter_false = [dict(computed_proj[0], emitter="usds")] + list(computed_proj[1:])
        order_false = list(reversed(computed_proj)) if len(computed_proj) > 1 else computed_proj + [{"emitter": "vault", "name": "Extra"}]
        content_false = [dict(computed_proj[0], name="NotDrip")] + list(computed_proj[1:])
    else:
        emitter_false, order_false, content_false = [], [], []
    for name, variant in [
        ("r9-projection-emitter-falsifier", emitter_false),
        ("r9-projection-order-falsifier", order_false),
        ("r9-projection-content-falsifier", content_false),
    ]:
        cmp = compare_logs(variant, expected_proj)
        results.append({
            "id": name,
            "expected_acceptance": False,
            "actual_comparison": cmp,
            "matches_required_behavior": cmp.get("gate") != "ok",
        })

    failed = [r["id"] for r in results if not r["matches_required_behavior"]]
    report = {
        "engine": str(ENGINE),
        "vault_run": str(RUN),
        "provenance": "Opus reviewer log falsifiers plus R-9 vault projection",
        "review_authorship": "claude-opus-5 session a1e40b81-7427-45e5-8b00-b2492cd46156",
        "checks": len(results),
        "matched": len(results) - len(failed),
        "failed_ids": failed,
        "exit": 1 if failed else 0,
        "results": results,
    }
    (OUT / "result.json").write_text(json.dumps(report, indent=2) + "\n")
    print(json.dumps({k: v for k, v in report.items() if k != "results"}))
    return int(report["exit"])


if __name__ == "__main__":
    raise SystemExit(main())
