#!/usr/bin/env python3
"""Generate evidence manifest with SHA-256 hashes for candidate directory."""
from __future__ import annotations

import hashlib
import json
import sys
from pathlib import Path

def sha256_file(path: Path) -> str:
    h = hashlib.sha256()
    with open(path, "rb") as f:
        while chunk := f.read(65536):
            h.update(chunk)
    return h.hexdigest()

def generate_manifest(candidate_dir: Path) -> dict:
    manifest = {
        "candidate_dir": str(candidate_dir),
        "files": {},
        "count": 0,
    }
    for p in sorted(candidate_dir.rglob("*")):
        if p.is_file() and p.name != "evidence-manifest.json":
            rel = str(p.relative_to(candidate_dir))
            manifest["files"][rel] = {
                "sha256": sha256_file(p),
                "size_bytes": p.stat().st_size,
            }
    manifest["count"] = len(manifest["files"])
    manifest_path = candidate_dir / "evidence-manifest.json"
    manifest_path.write_text(json.dumps(manifest, indent=2) + "\n")
    print(f"Generated manifest with {manifest['count']} files at {manifest_path}")
    return manifest

if __name__ == "__main__":
    target = Path(sys.argv[1]) if len(sys.argv) > 1 else Path("review/semantic-kernel/vault-platform-reuse/p17/implementation/agy-r2")
    generate_manifest(target)
