#!/usr/bin/env python3
"""Write a nonrecursive r2 manifest. Does not hash itself into the file list after writing."""
from __future__ import annotations

import hashlib
import json
from datetime import datetime, timezone
from pathlib import Path

CHANGE_FILES = [
    "proposal.md",
    "design.md",
    "tasks.md",
    "source-pin.json",
    "compiler-harness-plan.json",
    "assumptions.json",
    "fixtures.json",
    "planned-mutations.json",
    "proof-obligations.json",
    "proposed-api.json",
    "remaining-gates.json",
    "reuse-design.json",
    "observation-contract.json",
    "scenario-map.json",
    "specs/vault-source-readiness/spec.md",
    "specs/vault-conversion-observation/spec.md",
    "specs/vault-harness-assumptions/spec.md",
    "specs/platform-reuse-experiment/spec.md",
    "specs/vault-planning-evidence/spec.md",
]

EVIDENCE_FILES = [
    "diagnose.py",
    "write_manifest.py",
    "REPORT.md",
    "STATUS.md",
    "INPUTS.md",
    "result.json",
    "gate-status.json",
    "commands.json",
    "scenario-map.json",
    "controls/README.txt",
    "failed-attempts/README.md",
    "logs/diagnose.json",
    "logs/empty-corpus.json",
    "logs/wrong-literal.json",
    "logs/unavailable.json",
    "logs/openspec-strict.stdout",
    "logs/openspec-strict.stderr",
    "logs/openspec-version.log",
    "logs/openspec-status.stdout",
    "logs/openspec-status.stderr",
    "logs/git-head.log",
    "logs/git-branch.log",
    "logs/python-version.log",
    "logs/utc.log",
]


def rows(root: Path, rels: list[str]) -> list[dict]:
    out = []
    for rel in rels:
        path = root / rel
        if not path.is_file():
            raise SystemExit(f"blocked: missing {path}")
        data = path.read_bytes()
        out.append({"path": rel, "sha256": hashlib.sha256(data).hexdigest(), "bytes": len(data)})
    return out


def main() -> int:
    here = Path(__file__).resolve().parent
    repo = here.parents[5]
    change = repo / "openspec/changes/vault-platform-reuse-p17"
    change_rows = rows(change, CHANGE_FILES)
    evidence_rows = rows(here, EVIDENCE_FILES)
    manifest = {
        "schema": "p17-vault-planning-manifest/v2",
        "utc": datetime.now(timezone.utc).isoformat(),
        "nonrecursive": True,
        "accepted": False,
        "gate_accepted": False,
        "p17_platform_reuse": False,
        "status": "pending_independent_gpt6_review",
        "repair": "r2",
        "repairs": ["R1", "R2", "R3"],
        "r1_evidence_rewritten": False,
        "worktree": str(repo),
        "head": (here / "logs/git-head.log").read_text().strip(),
        "change": "openspec/changes/vault-platform-reuse-p17",
        "evidence": "review/semantic-kernel/vault-platform-reuse/p17/planning/grok-r2",
        "r1_evidence": "review/semantic-kernel/vault-platform-reuse/p17/planning/grok-r1",
        "counts": {
            "change_files": len(change_rows),
            "evidence_files": len(evidence_rows),
            "files": len(change_rows) + len(evidence_rows),
            "change_bytes": sum(r["bytes"] for r in change_rows),
            "evidence_bytes": sum(r["bytes"] for r in evidence_rows),
        },
        "change_files": change_rows,
        "evidence_files": evidence_rows,
        "note": "manifest.json is written after this list and is not a member of evidence_files",
    }
    text = json.dumps(manifest, indent=2) + "\n"
    (here / "manifest.json").write_text(text)
    print(
        json.dumps(
            {
                "wrote": str(here / "manifest.json"),
                "sha256": hashlib.sha256(text.encode()).hexdigest(),
                "files": manifest["counts"]["files"],
            },
            indent=2,
        )
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
