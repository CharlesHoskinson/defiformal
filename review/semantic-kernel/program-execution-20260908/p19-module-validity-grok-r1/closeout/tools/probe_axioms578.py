#!/usr/bin/env python3
"""Closeout 578-axiom probe. Writes only under closeout/. Reads original probe/inventory."""
from __future__ import annotations

import json
import re
from pathlib import Path

from record_cmd import OUT, run_cmd, sha256_file

TOOL = Path("/home/charl/.elan/toolchains/leanprover--lean4---v4.33.0-rc2/bin")
PRIVATE = Path(
    "/home/charl/defiformal/review/semantic-kernel/program-execution-20260908/p19-module-validity-grok-r1/private-lean"
)
PARENT = Path(
    "/home/charl/defiformal/review/semantic-kernel/program-execution-20260908/p19-module-validity-grok-r1"
)
ORIGINAL = PARENT / "original-terminal"
PROBE = ORIGINAL / "probes" / "axioms578" / "Axioms.lean"
INVENTORY = ORIGINAL / "probes" / "axioms578" / "inventory.json"
PARENT_PROBE = PARENT / "probes" / "axioms578" / "Axioms.lean"
ROOT_STDOUT = Path(
    "/home/charl/.cache/defiformal-program/program-execution-20260908/p19-module-validity-grok-r1-sandbox/root-context/p19-r24-root-inventory/axioms.stdout"
)
STANDARD = {"propext", "Classical.choice", "Quot.sound"}


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
    return {
        "built": built,
        "replayed": replayed,
        "jobs": jobs,
        "built_modules": [b["module"] for b in built],
        "replayed_modules": [r["module"] for r in replayed],
    }


def main() -> int:
    (OUT / "logs").mkdir(parents=True, exist_ok=True)
    (OUT / "probes" / "axioms578").mkdir(parents=True, exist_ok=True)
    (OUT / "failed-probes").mkdir(parents=True, exist_ok=True)

    probe_sha = sha256_file(PROBE)
    parent_probe_sha = sha256_file(PARENT_PROBE)
    inv = json.loads(INVENTORY.read_text())

    rec = run_cmd(
        "probe-axioms578",
        [
            str(TOOL / "lake"),
            "env",
            str(TOOL / "lean"),
            str(PROBE),
        ],
        PRIVATE,
        timeout=600,
        source="reviewer-private-lean-closeout",
        tool=str(TOOL / "lake"),
        probe=str(PROBE),
        note=(
            "Fresh closeout reviewer execution of original-terminal 578 Axioms.lean "
            "against completed reviewer private-lean. Probe file not modified. "
            "Not a root inventory replay relabelled as reviewer."
        ),
    )

    stdout_path = OUT / "logs" / "probe-axioms578" / "stdout"
    stderr_path = OUT / "logs" / "probe-axioms578" / "stderr"
    stdout = stdout_path.read_text(errors="replace")
    records = parse_print_axioms(stdout)
    classes = {"none": 0, "standard": 0, "forbidden": 0}
    forbidden = []
    for r in records:
        c = classify(r["axioms"])
        r["class"] = c
        classes[c] += 1
        if c == "forbidden":
            forbidden.append(r)

    names = [r["name"] for r in records]
    root_stdout_sha = sha256_file(ROOT_STDOUT) if ROOT_STDOUT.exists() else None
    result = {
        "probe_path": str(PROBE),
        "probe_sha256": probe_sha,
        "parent_probe_sha256": parent_probe_sha,
        "probe_equals_parent_probe": probe_sha == parent_probe_sha,
        "probe_bytes": PROBE.stat().st_size,
        "inventory_sha256": sha256_file(INVENTORY),
        "exit": rec["exit"],
        "credit": rec["credit"],
        "timed_out": rec["timed_out"],
        "print_count": len(records),
        "source_named_total": inv["named_total"],
        "names_equal_source_fq": names == inv["fq_names"],
        "source_minus_parsed": [n for n in inv["fq_names"] if n not in names],
        "parsed_minus_source": [n for n in names if n not in inv["fq_names"]],
        "stdout_sha256": rec["rawstdout_sha256"],
        "stderr_sha256": rec["rawstderr_sha256"],
        "root_axioms_stdout_sha256": root_stdout_sha,
        "stdout_equals_root_author_terminal": rec["rawstdout_sha256"] == root_stdout_sha,
        "root_inventory_is_author_terminal_not_this_build": True,
        "this_run_is_fresh_reviewer_execution": True,
        "classes": classes,
        "forbidden": forbidden,
        "standard_plus_none": classes["standard"] + classes["none"],
        "root_stated": {"total": 578, "standard": 520, "none": 58, "forbidden": 0},
        "matches_root_counts": classes["standard"] == 520
        and classes["none"] == 58
        and classes["forbidden"] == 0
        and len(records) == 578,
        "named_breakdown": {
            "CanonicalJson": inv["CanonicalJson_named"],
            "Correspondence": inv["Correspondence_named"],
            "Roundtrip": inv["Roundtrip_named"],
        },
        "original_probe_unmodified": True,
        "parent_logs_written": False,
    }
    parsed_path = OUT / "probes" / "axioms578" / "parsed.json"
    records_path = OUT / "probes" / "axioms578" / "records.json"
    parsed_path.write_text(json.dumps(result, indent=2) + "\n")
    records_path.write_text(json.dumps(records, indent=2) + "\n")

    if rec["exit"] != 0 or not result["matches_root_counts"] or forbidden:
        fail = OUT / "failed-probes" / "probe-axioms578.json"
        fail.write_text(
            json.dumps(
                {
                    "exit": rec["exit"],
                    "result": result,
                    "stderr_bytes": rec["stderr_bytes"],
                },
                indent=2,
            )
            + "\n"
        )

    for cmd_id in ["lake-rebuild-roundtrip", "lake-rebuild-verify"]:
        src = ORIGINAL / "logs" / cmd_id / "stdout"
        parsed = parse_lake_modules(src.read_text())
        dest = OUT / "logs" / cmd_id / "modules.json"
        dest.parent.mkdir(parents=True, exist_ok=True)
        dest.write_text(json.dumps(parsed, indent=2) + "\n")

    print(json.dumps({"probe": result}, indent=2))
    return 0 if rec["exit"] == 0 else 1


if __name__ == "__main__":
    raise SystemExit(main())
