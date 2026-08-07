#!/usr/bin/env python3
"""Compare generation on the SAME ten protocols: v1 IR vs v2 IR (repo-local)."""
import os
import re
import subprocess
import sys
from pathlib import Path

HERE = Path(__file__).resolve().parent
SIGMA = HERE.parent / "sigma"
IR1 = Path(os.environ.get("GEN_IR_V1", SIGMA / "gen-ir-v1ten"))
IR2 = Path(os.environ.get("GEN_IR_V2", SIGMA / "gen-ir-v2ten"))
GEN = HERE / "generate.py"

APPARATUS = re.compile(
    r"^(t0_|T0_|wit_|inv_|check[A-Z]|h\d\d$|sqrtOk$|kernel[A-Z]|kernelOk$)"
)
KERNEL = re.compile(
    r"^(isqrt|newton|geometricMintExact|mulDivDown$|mulDivUp$|ceilDiv$|"
    r"checkBoundary$|checkDecades$|checkSmall$|checkSquares$)"
)


def run(ir: Path):
    env = os.environ.copy()
    env["GEN_IR"] = str(ir)
    env["GEN_RESULT"] = str(HERE / f"RESULT-{ir.name}.json")
    proc = subprocess.run(
        [sys.executable, str(GEN)],
        capture_output=True,
        text=True,
        cwd=str(HERE),
        env=env,
    )
    if proc.returncode != 0:
        sys.stderr.write(proc.stderr)
        raise SystemExit(f"generate.py failed for {ir} exit={proc.returncode}")
    out = proc.stdout
    tested = gen = notgen = None
    per = {}
    for line in out.splitlines():
        m = re.search(r"definitions tested\s*:\s*(\d+)", line)
        if m:
            tested = int(m.group(1))
        m = re.search(r"definitions P-generated\s*:\s*(\d+)", line)
        if m:
            gen = int(m.group(1))
        m = re.search(r"definitions NOT generated\s*:\s*(\d+)", line)
        if m:
            notgen = int(m.group(1))
        m = re.match(r"\s+(L\d/\w+): \d+ ungenerated def\(s\): (.+)$", line)
        if m:
            per[m.group(1)] = [x.strip() for x in m.group(2).split(",")]
    if tested is None or gen is None or notgen is None:
        sys.stderr.write(out[-2000:])
        raise SystemExit(f"could not parse generate.py output for {ir}")
    return tested, gen, notgen, per


def classify(names):
    prot, app, kern = [], [], []
    for n in names:
        if KERNEL.match(n):
            kern.append(n)
        elif APPARATUS.match(n):
            app.append(n)
        else:
            prot.append(n)
    return prot, app, kern


def main():
    if not IR1.is_dir() or not IR2.is_dir():
        raise SystemExit(f"missing IR dirs:\n  {IR1}\n  {IR2}")
    t1, g1, n1, p1 = run(IR1)
    t2, g2, n2, p2 = run(IR2)

    print("RAW (not comparable -- v2 carries apparatus v1 never had)")
    print(f"  v1 ten  tested {t1:>5}   generated {g1:>5}   ungenerated {n1:>5}")
    print(f"  v2 ten  tested {t2:>5}   generated {g2:>5}   ungenerated {n2:>5}\n")

    print("UNGENERATED, split by what the definition IS")
    print(
        f"{'spec':<18} {'v1 protocol':>12} {'v2 protocol':>12}   "
        f"{'v2 apparatus':>13} {'v2 kernel':>10}"
    )
    print("-" * 74)
    tot = [0, 0, 0, 0]
    rows = []
    for spec in sorted(set(p1) | set(p2)):
        a1, _, _ = classify(p1.get(spec, []))
        a2, ap2, k2 = classify(p2.get(spec, []))
        rows.append((spec, len(a1), len(a2), len(ap2), len(k2), a1, a2))
        tot[0] += len(a1)
        tot[1] += len(a2)
        tot[2] += len(ap2)
        tot[3] += len(k2)
        print(f"{spec:<18} {len(a1):>12} {len(a2):>12}   {len(ap2):>13} {len(k2):>10}")
    print("-" * 74)
    print(f"{'TOTAL':<18} {tot[0]:>12} {tot[1]:>12}   {tot[2]:>13} {tot[3]:>10}")

    # protocol denominators: count protocol defs from IR directly
    # use ungenerated protocol totals
    u1, u2 = tot[0], tot[1]
    print("\nPROTOCOL ungenerated totals derived this run:")
    print(f"  v1 protocol ungenerated: {u1}")
    print(f"  v2 protocol ungenerated: {u2}")

    print("\nPROTOCOL definitions that are ungenerated in v2 but NOT in v1")
    for spec, _, _, _, _, a1, a2 in rows:
        new = sorted(set(a2) - set(a1))
        if new:
            print(
                f"  {spec:<18} {', '.join(new[:9])}"
                + (f"  (+{len(new)-9} more)" if len(new) > 9 else "")
            )

    print("\nPROTOCOL definitions ungenerated in v1 but generated in v2")
    for spec, _, _, _, _, a1, a2 in rows:
        gone = sorted(set(a1) - set(a2))
        if gone:
            print(f"  {spec:<18} {', '.join(gone)}")


if __name__ == "__main__":
    main()
