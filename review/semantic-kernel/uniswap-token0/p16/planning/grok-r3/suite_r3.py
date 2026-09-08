#!/usr/bin/env python3
"""Parent suite for P16 r3 stored-field binding.

Launches bind_strict_underflow.py as children. Records actual child exits.
A retained negative test may expect failure but must not relabel the child
exit. Planning diagnostic credit only.
"""
from __future__ import annotations

import sys

sys.dont_write_bytecode = True

import hashlib
import json
import os
import subprocess
from datetime import datetime, timezone
from pathlib import Path

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[5]
BIND = HERE / "bind_strict_underflow.py"
CHANGE = ROOT / "openspec/changes/uniswap-token0-p16"
PRESERVED = HERE / "preserved-r2-inputs"
LOGS = HERE / "logs"

R2_FX_SHA = "3bd3b3c5977fc5b181e563ea6d4b294f850fe41f254ba4c4013d11aa21aaafa4"
R2_MU_SHA = "473e5b4e3e80c8d6c43c4c53426c93af7117d74104a3e8d63d04e1725d60320a"
R2_ARCH_SHA = "baaf21f02b8d2e78293763d1c2c41e8b65d3f1e1bbeb56f14d06d276da57aae5"


def sha256_file(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def run_child(name: str, extra: list[str], expect: str) -> dict:
    """expect: zero | nonzero | blocked. Never rewrite child.returncode."""
    argv = [sys.executable, "-B", str(BIND), *extra]
    env = dict(os.environ)
    env["PYTHONDONTWRITEBYTECODE"] = "1"
    env["PYTHONSAFEPATH"] = "1"
    started = datetime.now(timezone.utc).isoformat()
    proc = subprocess.run(
        argv,
        cwd=str(ROOT),
        env=env,
        capture_output=True,
        text=True,
    )
    ended = datetime.now(timezone.utc).isoformat()
    stdout_path = LOGS / f"{name}.stdout"
    stderr_path = LOGS / f"{name}.stderr"
    stdout_path.write_text(proc.stdout)
    stderr_path.write_text(proc.stderr)
    actual = proc.returncode
    if expect == "zero":
        parent_ok = actual == 0
        parent_reason = "child exit 0" if parent_ok else f"expected 0 got {actual}"
    elif expect == "blocked":
        parent_ok = actual == 3
        parent_reason = "child exit 3 BLOCKED" if parent_ok else f"expected blocked 3 got {actual}"
    elif expect == "nonzero":
        parent_ok = actual != 0
        parent_reason = f"child nonzero exit {actual} recorded" if parent_ok else "expected nonzero, child exited 0 (negative did not fire)"
    else:
        raise ValueError(expect)
    rec = {
        "name": name,
        "argv": argv,
        "cwd": str(ROOT),
        "started_utc": started,
        "ended_utc": ended,
        "child_exit": actual,
        "child_exit_recorded_unrelabeled": True,
        "expect": expect,
        "parent_ok": parent_ok,
        "parent_reason": parent_reason,
        "stdout": str(stdout_path.relative_to(ROOT)),
        "stderr": str(stderr_path.relative_to(ROOT)),
    }
    return rec


def main() -> int:
    utc = datetime.now(timezone.utc).isoformat()
    LOGS.mkdir(parents=True, exist_ok=True)

    fx = CHANGE / "fixtures.json"
    mu = CHANGE / "planned-mutations.json"
    pfx = PRESERVED / "fixtures.json"
    pmu = PRESERVED / "planned-mutations.json"
    malformed = LOGS / "malformed.json"
    malformed.write_text("{")

    preserved_fx_sha = sha256_file(pfx)
    preserved_mu_sha = sha256_file(pmu)
    if preserved_fx_sha != R2_FX_SHA or preserved_mu_sha != R2_MU_SHA:
        print("FAIL preserved r2 JSON bytes drifted", file=sys.stderr)
        print(f"fx {preserved_fx_sha} mu {preserved_mu_sha}", file=sys.stderr)
        return 1

    children = []
    children.append(
        run_child(
            "bind-repaired",
            ["--fixtures", str(fx), "--mutations", str(mu), "--out", str(LOGS / "bind-repaired.json")],
            "zero",
        )
    )
    children.append(
        run_child(
            "bind-preserved-r2",
            ["--fixtures", str(pfx), "--mutations", str(pmu), "--out", str(LOGS / "bind-preserved-r2.json")],
            "nonzero",
        )
    )
    children.append(run_child("empty-corpus", ["--empty-corpus"], "blocked"))
    children.append(
        run_child(
            "corrupt-fixtures-denom",
            [
                "--fixtures",
                str(fx),
                "--mutations",
                str(mu),
                "--corrupt-fixtures-denom",
                "--out",
                str(LOGS / "bind-corrupt-fixtures.json"),
            ],
            "nonzero",
        )
    )
    children.append(
        run_child(
            "corrupt-mutations-denom",
            [
                "--fixtures",
                str(fx),
                "--mutations",
                str(mu),
                "--corrupt-mutations-denom",
                "--out",
                str(LOGS / "bind-corrupt-mutations.json"),
            ],
            "nonzero",
        )
    )
    children.append(
        run_child(
            "malformed-json",
            ["--fixtures", str(malformed), "--mutations", str(mu), "--out", str(LOGS / "bind-malformed.json")],
            "nonzero",
        )
    )

    parent_failed = [c["name"] for c in children if not c["parent_ok"]]
    n = len(children)
    if n == 0:
        print("BLOCKED empty parent child denominator", file=sys.stderr)
        print("DENOMINATOR 0")
        return 3

    result = {
        "schema": "p16-token0-planning-r3-suite/v1",
        "utc": utc,
        "python": sys.version.split()[0],
        "cwd": str(ROOT),
        "bind_script": str(BIND.relative_to(ROOT)),
        "bind_script_sha256": sha256_file(BIND),
        "production_mutation_credit": 0,
        "gate_accepted": False,
        "preserved_r2": {
            "fixtures_sha256": preserved_fx_sha,
            "mutations_sha256": preserved_mu_sha,
            "archive_sha256_expected": R2_ARCH_SHA,
            "bytes_unmodified": True,
        },
        "live_after_repair": {
            "fixtures_sha256": sha256_file(fx),
            "mutations_sha256": sha256_file(mu),
        },
        "denominators": {
            "children": n,
            "parent_ok": n - len(parent_failed),
            "parent_failed": len(parent_failed),
        },
        "children": children,
        "parent_failed": parent_failed,
        "note": "Negative children (preserved r2, in-memory corrupt, malformed) record actual nonzero exits. Parent does not relabel them to 0.",
    }
    out = LOGS / "suite.json"
    out.write_text(json.dumps(result, indent=2) + "\n")
    print(f"UTC {utc}")
    print(f"CHILDREN {n} PARENT_OK {n - len(parent_failed)} PARENT_FAIL {len(parent_failed)}")
    for c in children:
        print(f"CHILD {c['name']} EXIT {c['child_exit']} EXPECT {c['expect']} PARENT_OK {c['parent_ok']}")
    print(f"LOG {out}")
    if parent_failed:
        print("PARENT_FAILED " + ",".join(parent_failed))
        return 1
    print("R3_SUITE_OK")
    return 0


if __name__ == "__main__":
    sys.exit(main())
