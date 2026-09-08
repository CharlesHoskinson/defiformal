#!/usr/bin/env python3
"""Write a self-excluding freeze manifest. Does not include this run's output files until after they exist; those outputs are listed as excluded."""
from __future__ import annotations

import datetime
import hashlib
import json
from pathlib import Path

REPO = Path(__file__).resolve().parents[5]
R1 = Path(__file__).resolve().parent
CHANGE = REPO / "openspec/changes/concentrated-liquidity-library"
EXCLUDE_NAMES = {"manifest.json", "artifact-manifest.json"}
EXCLUDE_DIR_PARTS = {"__pycache__"}


def sha(b: bytes) -> str:
    return hashlib.sha256(b).hexdigest()


def walk(root: Path):
    for p in sorted(root.rglob("*")):
        if not p.is_file():
            continue
        if any(part in EXCLUDE_DIR_PARTS for part in p.parts):
            continue
        if p.name in EXCLUDE_NAMES:
            continue
        yield p


def main() -> None:
    files = []
    h = hashlib.sha256()
    for p in list(walk(CHANGE)) + list(walk(R1)):
        rel = str(p.relative_to(REPO))
        b = p.read_bytes()
        rec = {
            "path": rel,
            "sha256": sha(b),
            "bytes": len(b),
            "representation": "verbatim_utf8" if not rel.endswith(".pyc") else "binary",
        }
        files.append(rec)
        h.update(rel.encode() + b"\n" + rec["sha256"].encode() + b"\n")
    manifest = {
        "kind": "openspec-planning-concentrated-liquidity-library",
        "self_excluding": True,
        "excludes": sorted(EXCLUDE_NAMES),
        "head": "a12b7cac05a818cc8d35c2ca440b7170a2807e92",
        "utc": datetime.datetime.now(datetime.timezone.utc).isoformat(),
        "author": "native Grok 4.6",
        "checker_required": "independent GPT-6",
        "gate_accepted": False,
        "implementation_authorized": False,
        "input_count": len(files),
        "bundle_sha256": h.hexdigest(),
        "scope": {
            "capabilities": 5,
            "requirements": 18,
            "scenarios": 40,
            "unchecked_tasks": 24,
            "fixtures": 45,
            "mutations": 12,
        },
        "files": files,
    }
    (R1 / "manifest.json").write_text(json.dumps(manifest, indent=2) + "\n")
    print(json.dumps({"input_count": len(files), "bundle_sha256": h.hexdigest(), "self_in_list": any(f["path"].endswith("manifest.json") for f in files)}, indent=2))


if __name__ == "__main__":
    main()
