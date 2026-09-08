#!/usr/bin/env python3
"""Structural checks for uncompiled Nary fixture drafts. Does not run Lean."""
from __future__ import annotations

import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[5]


def main() -> int:
    ex = (ROOT / "lean/DefiKernel/Nary/Examples.lean").read_text()
    te = (ROOT / "lean/DefiKernel/Nary/Tests.lean").read_text()
    au = (ROOT / "lean/DefiKernel/Nary/Audit.lean").read_text()
    fx = json.loads(
        (ROOT / "openspec/changes/finite-participant-causal-composition/fixtures.json").read_text()
    )
    mut = json.loads(
        (
            ROOT / "openspec/changes/finite-participant-causal-composition/planned-mutations.json"
        ).read_text()
    )
    errors: list[str] = []
    for i in range(1, 20):
        fid = f"F{i:02d}"
        if fid not in ex:
            errors.append(f"missing {fid} in Examples")
    lean_rows = re.findall(
        r"⟨\[([0-9, ]+)\], ([0-9]), ([0-9]), ([0-9]+), \[([0-9, ]+)\], \[([0-9, ]+)\], "
        r"(true|false), \.(awaiting|ready6|consumed), \[([0-9, ]+)\]⟩",
        ex,
    )
    phase_map = {"Awaiting": "awaiting", "Ready6": "ready6", "Consumed": "consumed"}
    json_rows = []
    f10 = next(f for f in fx["fixtures"] if f["id"] == "F10")
    for s in f10["twelve_literal_schedule_oracles"]:
        for px in s["independent_prefix_expectations"]:
            json_rows.append(
                (
                    s["schedule"],
                    px["participant"],
                    px["own_index"],
                    px["operation"],
                    px["before_main_usd"],
                    px["after_main_usd"],
                    bool(px.get("outputs")),
                    phase_map[px["monitor"]],
                    px["locals_nextIndex_and_consumed"],
                )
            )
    if len(lean_rows) != 48 or len(json_rows) != 48:
        errors.append(f"F10 row counts lean={len(lean_rows)} json={len(json_rows)}")
    mism = 0
    for lr, jr in zip(lean_rows, json_rows, strict=True):
        sched = [int(x) for x in lr[0].split(",") if x.strip() != ""]
        before = [int(x) for x in lr[4].split(",") if x.strip() != ""]
        after = [int(x) for x in lr[5].split(",") if x.strip() != ""]
        loc = [int(x) for x in lr[8].split(",") if x.strip() != ""]
        got = (
            sched,
            int(lr[1]),
            int(lr[2]),
            int(lr[3]),
            before,
            after,
            lr[6] == "true",
            lr[7],
            loc,
        )
        if got != jr:
            mism += 1
    if mism:
        errors.append(f"F10 mismatches {mism}")
    static = re.findall(r'\("(nary\.[^"]+)"', te)
    if len(static) != len(set(static)):
        errors.append("duplicate static check names")
    for m in mut["mutations"]:
        if m["oracle_label"] not in te:
            errors.append(f"missing false label {m['oracle_label']}")
        if m["expected_protected_check"] not in te:
            errors.append(f"missing protected {m['expected_protected_check']}")
    for name, txt in ("Examples", ex), ("Tests", te), ("Audit", au):
        for bad in (
            "Interface.Tests",
            "Interface.Fixtures",
            "Interface.Accounting",
            "Interface.Preservation",
            "sorry",
            "native_decide",
        ):
            if bad in txt:
                errors.append(f"{name} contains {bad}")
        if "-- BEGIN PROOFS" not in txt:
            errors.append(f"{name} missing BEGIN PROOFS")
    if "runtimeComparisons" not in au or "#eval main" not in au:
        errors.append("Audit missing production #eval runtimeComparisons")
    if "opIface 18" not in ex or ex.count("opIface 18") != 1:
        errors.append("F05 must declare exactly one producer interface")
    if errors:
        print("FAILED")
        for e in errors:
            print(" ", e)
        return 1
    print("OK structural")
    print(f" static_checks={len(static)} f10_rows={len(lean_rows)}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
