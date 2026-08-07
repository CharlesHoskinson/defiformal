#!/usr/bin/env python3
"""Denominators for the ten-protocol generation rate (repo-local IR)."""
import json
import os
import re
import subprocess
import sys
from pathlib import Path

BASIS = Path(__file__).resolve().parent
SIGMA = BASIS.parent / "sigma"
IR1 = Path(os.environ.get("GEN_IR_V1", SIGMA / "gen-ir-v1ten"))
IR2 = Path(os.environ.get("GEN_IR_V2", SIGMA / "gen-ir-v2ten"))

APPARATUS = re.compile(
    r"^(t0_|T0_|wit_|inv_|check[A-Z]|h\d\d$|sqrtOk$|kernel[A-Z]|kernelOk$)"
)
KERNEL = re.compile(
    r"^(isqrt|newton|geometricMintExact|mulDivDown$|mulDivUp$|ceilDiv$|"
    r"checkBoundary$|checkDecades$|checkSmall$|checkSquares$)"
)


def protocol_defs(d):
    n = 0
    for m in d["modules"]:
        if m["name"] == "common":
            continue
        for de in m["declarations"]:
            if de["kind"] != "def":
                continue
            nm = de.get("name", "")
            if APPARATUS.match(nm) or KERNEL.match(nm):
                continue
            n += 1
    return n


def ungen_from_compare():
    if os.environ.get("SKIP_COMPARE"):
        return None, None
    proc = subprocess.run(
        [sys.executable, str(BASIS / "compare_v1_v2.py")],
        capture_output=True,
        text=True,
        cwd=str(BASIS),
    )
    if proc.returncode != 0:
        return None, None
    u1 = u2 = None
    for line in proc.stdout.splitlines():
        m = re.search(r"v1 protocol ungenerated:\s*(\d+)", line)
        if m:
            u1 = int(m.group(1))
        m = re.search(r"v2 protocol ungenerated:\s*(\d+)", line)
        if m:
            u2 = int(m.group(1))
    return u1, u2


def main():
    if not IR1.is_dir() or not IR2.is_dir():
        raise SystemExit(f"missing IR:\n  {IR1}\n  {IR2}")
    print(f"{'spec':<18} {'v1 protocol defs':>17} {'v2 protocol defs':>17}")
    print("-" * 56)
    t1 = t2 = 0
    for fn in sorted(os.listdir(IR1)):
        if not fn.endswith(".json"):
            continue
        a = protocol_defs(json.load(open(IR1 / fn)))
        b = protocol_defs(json.load(open(IR2 / fn)))
        t1 += a
        t2 += b
        print(f"{fn[:-5].replace('__','/'):<18} {a:>17} {b:>17}")
    print("-" * 56)
    print(f"{'TOTAL':<18} {t1:>17} {t2:>17}")
    print()
    if "UNGEN_V1" in os.environ or "UNGEN_V2" in os.environ:
        if "UNGEN_V1" not in os.environ or "UNGEN_V2" not in os.environ:
            raise SystemExit("set both UNGEN_V1 and UNGEN_V2, or neither")
        u1, u2 = int(os.environ["UNGEN_V1"]), int(os.environ["UNGEN_V2"])
        # Validate against compare when available
        c1, c2 = ungen_from_compare()
        if c1 is not None and (c1, c2) != (u1, u2):
            raise SystemExit(
                f"UNGEN_V1/V2={(u1,u2)} disagree with compare_v1_v2={(c1,c2)}"
            )
        print("Numerators from UNGEN_V1/UNGEN_V2 env (validated against compare).")
    else:
        c1, c2 = ungen_from_compare()
        if c1 is None:
            raise SystemExit(
                "cannot derive numerators: compare_v1_v2.py failed; "
                "fix that or set validated UNGEN_V1/UNGEN_V2"
            )
        u1, u2 = c1, c2
        print("Numerators derived from compare_v1_v2.py this run.")
    print(f"ungenerated protocol defs   v1 {u1:>4} / {t1:<4} = {100 * u1 / t1:5.1f}%")
    print(f"                            v2 {u2:>4} / {t2:<4} = {100 * u2 / t2:5.1f}%")
    print(f"IR_V1={IR1}")
    print(f"IR_V2={IR2}")


if __name__ == "__main__":
    main()
