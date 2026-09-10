#!/usr/bin/env python3
"""Run root-supplied complete 581 #print axioms probe after independent rebuild."""
from __future__ import annotations

import json
import re
from pathlib import Path

from record_cmd import OUT, run_cmd, sha256_file

TOOL = Path("/home/charl/.elan/toolchains/leanprover--lean4---v4.33.0-rc2/bin")
PRIVATE = OUT / "private-lean"
PROBE = OUT / "probes" / "axioms581" / "Axioms.lean"
STANDARD = {"propext", "Classical.choice", "Quot.sound"}
ROOT_STDOUT = Path(
    "/home/charl/.cache/defiformal-program/program-execution-20260908/p19-typed-payload-grok-r1-sandbox/root-context/p19-r25-root-inventory/axioms.stdout"
)
NEW_THREE = [
    "DefiKernel.Certificates.qualifiedPortToTreeJson_toJson",
    "DefiKernel.Certificates.decodeOutputObservation_outputObservationToTreeJson",
    "DefiKernel.Certificates.decodeTypedExecutePayload_typedExecutePayloadToTreeJson",
]


def parse_print_axioms(text: str) -> list[dict]:
    """Parse #print axioms stdout in order. Join wrapped axiom lists (re.S)."""
    records: list[dict] = []
    pat = re.compile(
        r"'([^']+)' (?:depends on axioms: \[([^\]]*)\]|does not depend on any axioms)",
        re.S,
    )
    for m in pat.finditer(text):
        name = m.group(1)
        inner = m.group(2)
        axioms = [x.strip() for x in inner.split(",") if x.strip()] if inner is not None else []
        records.append({"name": name, "axioms": axioms})
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
        "probe-axioms581",
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
        probe="root-supplied-581-Axioms.lean",
        note="Root-supplied complete 581 probe after independent Roundtrip/Verify rebuild. Not an incomplete inline helper. Root inventory is imported author-terminal; this run is the independent review build. No Correspondence 4-minute redundant scan.",
    )

    stdout = (OUT / "logs" / "probe-axioms581" / "stdout").read_text()
    records = parse_print_axioms(stdout)
    classes = {"none": 0, "standard": 0, "forbidden": 0}
    forbidden = []
    for r in records:
        c = classify(r["axioms"])
        r["class"] = c
        classes[c] += 1
        if c == "forbidden":
            forbidden.append(r)

    inv = json.loads((OUT / "probes" / "axioms581" / "inventory.json").read_text())
    names = [r["name"] for r in records]
    root_stdout_sha = sha256_file(ROOT_STDOUT) if ROOT_STDOUT.exists() else None
    new_three = [r for r in records if r["name"] in NEW_THREE]
    result = {
        "probe_sha256": sha256_file(PROBE),
        "probe_bytes": PROBE.stat().st_size,
        "exit": rec["exit"],
        "credit": rec["credit"],
        "print_count": len(records),
        "source_named_total": inv["named_total"],
        "names_equal_source_fq": names == inv["fq_names"],
        "stdout_sha256": rec["rawstdout_sha256"],
        "root_axioms_stdout_sha256": root_stdout_sha,
        "stdout_equals_root_author_terminal": rec["rawstdout_sha256"] == root_stdout_sha,
        "root_inventory_is_author_terminal_not_this_build": True,
        "classes": classes,
        "forbidden": forbidden,
        "standard_plus_none": classes["standard"] + classes["none"],
        "root_stated": {"total": 581, "standard": 523, "none": 58, "forbidden": 0},
        "matches_root_counts": classes["standard"] == 523
        and classes["none"] == 58
        and classes["forbidden"] == 0
        and len(records) == 581,
        "new_three": new_three,
        "new_three_count": len(new_three),
        "incomplete_inline_helper": False,
        "redundant_correspondence_scan": False,
    }
    (OUT / "probes" / "axioms581" / "parsed.json").write_text(json.dumps(result, indent=2) + "\n")
    (OUT / "probes" / "axioms581" / "records.json").write_text(
        json.dumps(records, indent=2) + "\n"
    )

    for cmd_id in ["lake-rebuild-roundtrip", "lake-rebuild-verify"]:
        stdout_path = OUT / "logs" / cmd_id / "stdout"
        parsed = parse_lake_modules(stdout_path.read_text())
        (OUT / "logs" / cmd_id / "modules.json").write_text(json.dumps(parsed, indent=2) + "\n")

    print(json.dumps({"probe": result}, indent=2))
    return 0 if rec["exit"] == 0 else 1


if __name__ == "__main__":
    raise SystemExit(main())
