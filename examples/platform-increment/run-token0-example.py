#!/usr/bin/env python3
"""Run the P18 token0 Lean library example using a bound environment.

Requires bind-environment.py output. Does not treat Python as Lean execution.
Missing binding or empty output exits 3.
"""
from __future__ import annotations

import argparse
import json
import os
import subprocess
import sys
from pathlib import Path

REQUIRED_VERSION_SUB = "4.33.0-rc2"
EXAMPLE_REL = "examples/platform-increment/lean/Token0ReleaseExample.lean"


def repo_root_from_script() -> Path:
    return Path(__file__).resolve().parents[2]


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--binding", required=True, help="environment.bound.json from bind-environment.py")
    args = parser.parse_args()
    root = repo_root_from_script()
    binding_path = Path(args.binding)
    if not binding_path.is_file():
        print(f"missing binding {binding_path}; run bind-environment.py first", file=sys.stderr)
        return 3
    binding = json.loads(binding_path.read_text())
    if binding.get("status") != "bound":
        print("binding status is not bound", file=sys.stderr)
        return 3
    version = binding.get("lake_env_lean_version") or ""
    if REQUIRED_VERSION_SUB not in version:
        print(f"binding lean version is not {REQUIRED_VERSION_SUB}: {version}", file=sys.stderr)
        return 3
    lake = (binding.get("tools") or {}).get("lake") or {}
    lake_path = lake.get("path")
    if not lake_path or not Path(lake_path).is_file():
        print("binding lake path missing", file=sys.stderr)
        return 3
    example = root / EXAMPLE_REL
    if not example.is_file() or example.stat().st_size == 0:
        print(f"missing example {example}", file=sys.stderr)
        return 3
    lean_dir = root / "lean"
    rel_example = os.path.relpath(str(example), str(lean_dir))
    cmd = [lake_path, "env", "lean", rel_example]
    proc = subprocess.run(cmd, cwd=str(lean_dir), capture_output=True, text=True, check=False)
    sys.stdout.write(proc.stdout)
    sys.stderr.write(proc.stderr)
    if proc.returncode != 0:
        return proc.returncode if proc.returncode in (1, 3) else 1
    if "denominator=12" not in proc.stdout or "status=ok" not in proc.stdout:
        print("Lean example stdout missing nonempty denominator or status=ok", file=sys.stderr)
        return 1
    if "P16-WRAP" not in proc.stdout or "P16-REQ" not in proc.stdout:
        print("Lean example stdout missing overflow/removal rows", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
