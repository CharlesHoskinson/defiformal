#!/usr/bin/env python3
"""Explicit P18 environment-binding step.

Discovers or records lake/python paths, then verifies that
`lake env lean --version` from the repository lean/ directory is 4.33.0-rc2.
Does not bake private cache paths into the API files. Missing tools exit 3.
"""
from __future__ import annotations

import argparse
import hashlib
import json
import os
import shutil
import subprocess
import sys
from datetime import datetime, timezone
from pathlib import Path

REQUIRED_TOOLCHAIN = "leanprover/lean4:v4.33.0-rc2"
REQUIRED_VERSION_SUB = "4.33.0-rc2"
EXAMPLE_REL = "examples/platform-increment/lean/Token0ReleaseExample.lean"


def sha256_file(path: Path) -> str | None:
    if not path.is_file():
        return None
    h = hashlib.sha256()
    with path.open("rb") as handle:
        for chunk in iter(lambda: handle.read(1024 * 1024), b""):
            h.update(chunk)
    return h.hexdigest()


def repo_root_from_script() -> Path:
    return Path(__file__).resolve().parents[2]


def resolve_exe(value: str | None, default_names: list[str]) -> Path | None:
    if value:
        path = Path(value).expanduser()
        if path.is_file():
            return path.resolve()
        found = shutil.which(value)
        return Path(found).resolve() if found else None
    for name in default_names:
        found = shutil.which(name)
        if found:
            return Path(found).resolve()
    return None


def tool_record(path: Path | None, name: str) -> dict:
    if path is None:
        return {
            "name": name,
            "status": "not_established",
            "path": None,
            "version": None,
            "sha256": None,
        }
    return {
        "name": name,
        "status": "recorded",
        "path": str(path),
        "version": None,
        "sha256": sha256_file(path),
        "mode": oct(path.stat().st_mode),
    }


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--config", default=None, help="Optional environment.json")
    parser.add_argument("--out", required=True, help="Binding receipt JSON")
    args = parser.parse_args()

    root = repo_root_from_script()
    lean_dir = root / "lean"
    toolchain_file = lean_dir / "lean-toolchain"
    example = root / EXAMPLE_REL
    config: dict = {}
    if args.config:
        cfg_path = Path(args.config)
        if not cfg_path.is_file():
            print(f"missing config {cfg_path}", file=sys.stderr)
            return 3
        config = json.loads(cfg_path.read_text())

    if not lean_dir.is_dir() or not toolchain_file.is_file():
        print("lean/ or lean-toolchain missing", file=sys.stderr)
        return 3
    toolchain_text = toolchain_file.read_text().strip()
    if toolchain_text != REQUIRED_TOOLCHAIN:
        print(
            f"toolchain mismatch: {toolchain_text} != {REQUIRED_TOOLCHAIN}",
            file=sys.stderr,
        )
        return 3
    if not example.is_file() or example.stat().st_size == 0:
        print(f"missing example {example}", file=sys.stderr)
        return 3

    lake = resolve_exe(config.get("lake"), ["lake"])
    python3 = resolve_exe(config.get("python3"), ["python3"])
    solc = resolve_exe(config.get("solc"), [])
    evm = resolve_exe(config.get("evm"), [])

    if lake is None:
        print("lake not found; set lake in environment.json", file=sys.stderr)
        return 3
    if python3 is None:
        print("python3 not found", file=sys.stderr)
        return 3

    proc = subprocess.run(
        [str(lake), "env", "lean", "--version"],
        cwd=str(lean_dir),
        capture_output=True,
        text=True,
        check=False,
    )
    version_text = (proc.stdout or "") + (proc.stderr or "")
    if proc.returncode != 0 or REQUIRED_VERSION_SUB not in version_text:
        print(
            {
                "reason": "lake env lean is not 4.33.0-rc2",
                "exit": proc.returncode,
                "stdout": proc.stdout,
                "stderr": proc.stderr,
            },
            file=sys.stderr,
        )
        return 3

    receipt = {
        "schema": "defiformal-p18-environment-binding/v1",
        "status": "bound",
        "utc": datetime.now(timezone.utc).isoformat(),
        "repository_root_recorded_locally": str(root),
        "repository_root_is_not_an_api_constant": True,
        "lean_dir": "lean",
        "lean_toolchain_file": "lean/lean-toolchain",
        "lean_toolchain": toolchain_text,
        "lean_toolchain_sha256": sha256_file(toolchain_file),
        "lake_env_lean_version": proc.stdout.strip(),
        "lake_env_lean_exit": proc.returncode,
        "example_lean": EXAMPLE_REL,
        "example_sha256": sha256_file(example),
        "tools": {
            "lake": tool_record(lake, "lake"),
            "python3": tool_record(python3, "python3"),
            "solc": tool_record(solc, "solc"),
            "evm": tool_record(evm, "evm"),
        },
        "solc_evm_required_for_lean_example": False,
        "argv": sys.argv,
        "cwd": os.getcwd(),
        "note": "This receipt is machine-local. Do not copy its absolute paths into the published API templates.",
    }
    out = Path(args.out)
    out.parent.mkdir(parents=True, exist_ok=True)
    out.write_text(json.dumps(receipt, indent=2) + "\n")
    print(json.dumps({"status": "bound", "out": str(out), "lean": proc.stdout.strip()}))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
