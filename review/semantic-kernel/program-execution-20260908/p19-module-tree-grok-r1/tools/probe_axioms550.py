#!/usr/bin/env python3
"""Run root-supplied complete 550 #print axioms probe after independent rebuild."""
from __future__ import annotations

import json
import re
from pathlib import Path

from record_cmd import OUT, run_cmd, sha256_file

TOOL = Path("/home/charl/.elan/toolchains/leanprover--lean4---v4.33.0-rc2/bin")
PRIVATE = OUT / "private-lean"
PROBE = OUT / "probes" / "axioms550" / "Axioms.lean"
STANDARD = {"propext", "Classical.choice", "Quot.sound"}


def parse_print_axioms(text: str) -> list[dict]:
    records = []
    current = None
    for line in text.splitlines():
        if line.startswith("'") and line.endswith("' depends on axioms:"):
            if current is not None:
                records.append(current)
            name = line[1 : line.index("' depends on axioms:")]
            current = {"name": name, "axioms": []}
        elif current is not None and line.startswith("  "):
            ax = line.strip()
            if ax:
                current["axioms"].append(ax)
        elif current is not None and line.startswith("'"):
            records.append(current)
            current = None
    if current is not None:
        records.append(current)
    return records


def classify(axioms: list[str]) -> str:
    s = set(axioms)
    if not s:
        return "none"
    if s <= STANDARD:
        return "standard"
    return "forbidden"


def parse_lake_modules(stdout: str) -> dict:
    built = []
    replayed = []
    for line in stdout.splitlines():
        m = re.search(r"\[(\d+)/(\d+)\] (Built|Replayed) (\S+)", line)
        if m:
            rec = {
                "job": int(m.group(1)),
                "total": int(m.group(2)),
                "kind": m.group(3),
                "module": m.group(4),
            }
            extra = line[m.end() :].strip()
            if extra.startswith("(") and extra.endswith(")"):
                rec["time"] = extra[1:-1]
            if rec["kind"] == "Built":
                built.append(rec)
            else:
                replayed.append(rec)
    jobs = None
    m = re.search(r"Build completed successfully \((\d+) jobs\)", stdout)
    if m:
        jobs = int(m.group(1))
    return {"built": built, "replayed": replayed, "jobs": jobs}


def main() -> int:
    rec = run_cmd(
        "probe-axioms550",
        [
            str(TOOL / "lake"),
            "env",
            str(TOOL / "lean"),
            str(PROBE),
        ],
        PRIVATE,
        timeout=600,
        source="reviewer-private-lean",
        tool=str(TOOL / "lake"),
        probe="root-supplied-550-Axioms.lean",
        note="Root-supplied complete 550 probe after independent Roundtrip/Verify rebuild. Not an incomplete inline helper.",
    )

    stdout = (OUT / "logs" / "probe-axioms550" / "stdout").read_text()
    records = parse_print_axioms(stdout)
    classes = {"none": 0, "standard": 0, "forbidden": 0}
    forbidden = []
    for r in records:
        c = classify(r["axioms"])
        r["class"] = c
        classes[c] += 1
        if c == "forbidden":
            forbidden.append(r)

    inv = json.loads((OUT / "probes" / "axioms550" / "inventory.json").read_text())
    names = [r["name"] for r in records]
    result = {
        "probe_sha256": sha256_file(PROBE),
        "probe_bytes": PROBE.stat().st_size,
        "exit": rec["exit"],
        "credit": rec["credit"],
        "print_count": len(records),
        "source_named_total": inv["named_total"],
        "names_equal_source_fq": names == inv["fq_names"],
        "names_equal_root_inventory": names == json.loads(
            (
                Path(
                    "/home/charl/.cache/defiformal-program/program-execution-20260908/p19-module-tree-grok-r1-sandbox/root-context/p19-r23-root-inventory/inventory.json"
                )
            ).read_text()
        ).get("names", []),
        "classes": classes,
        "forbidden": forbidden,
        "standard_plus_none": classes["standard"] + classes["none"],
        "root_stated": {"total": 550, "standard": 495, "none": 55, "forbidden": 0},
        "matches_root_counts": classes["standard"] == 495
        and classes["none"] == 55
        and classes["forbidden"] == 0
        and len(records) == 550,
    }
    (OUT / "probes" / "axioms550" / "parsed.json").write_text(json.dumps(result, indent=2) + "\n")
    (OUT / "probes" / "axioms550" / "records.json").write_text(
        json.dumps(records, indent=2) + "\n"
    )

    for cmd_id in ["lake-rebuild-roundtrip", "lake-rebuild-verify"]:
        stdout_path = OUT / "logs" / cmd_id / "stdout"
        parsed = parse_lake_modules(stdout_path.read_text())
        (OUT / "logs" / cmd_id / "modules.json").write_text(json.dumps(parsed, indent=2) + "\n")

    print(json.dumps({"probe": result, "roundtrip_modules": "logs/lake-rebuild-roundtrip/modules.json", "verify_modules": "logs/lake-rebuild-verify/modules.json"}, indent=2))
    return 0 if rec["exit"] == 0 else 1


if __name__ == "__main__":
    raise SystemExit(main())
