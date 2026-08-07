#!/usr/bin/env python3
"""Seed independent-witness census (GATE-1.1A-METHOD.md). Heuristic, not final."""
from pathlib import Path
import re

root = Path("quint-models")
specs = [p for p in root.glob("L*/*.qnt") if p.name != "common.qnt"]

def read(p):
    try:
        return p.read_text(errors="ignore")
    except Exception:
        return ""

rows = []
for p in specs:
    t = read(p)
    shared = bool(re.search(r"\b(canDeliverOnce|markUsed)\b", t))
    independent = bool(re.search(r"\b(PacketStatus|Delivered|Verified|nonceUsed|usedNonces)\b", t))
    if shared or independent:
        cls = "INDEPENDENT" if independent else "SHARED"
        rows.append((str(p), cls))

rows2 = []
for p in specs:
    t = read(p)
    if re.search(r"confirmMint|CustodianRequest|applyApprove", t):
        indep = bool(re.search(r"action\s+confirmMint", t))
        rows2.append((str(p), "INDEPENDENT" if indep else "SHARED-or-type"))

out = Path("research/positive-program/sigma/GATE-1.1A-CENSUS-SEED.md")
lines = [
    "# 1.1a independent-witness census — seed run\n\n",
    "Method: GATE-1.1A-METHOD.md. Heuristic regex, not final.\n\n",
    "## N6 once-only delivery\n\n",
    "| spec | class |\n|---|---|\n",
]
for path, cls in rows:
    lines.append(f"| `{path}` | **{cls}** |\n")
lines.append("\n## Two-phase custodian mint\n\n| spec | class |\n|---|---|\n")
for path, cls in rows2:
    lines.append(f"| `{path}` | **{cls}** |\n")
n_ind = sum(1 for _, c in rows if c == "INDEPENDENT")
n_sh = sum(1 for _, c in rows if c == "SHARED")
n2 = sum(1 for _, c in rows2 if c == "INDEPENDENT")
lines.append("\n## Seed conclusion\n\n")
lines.append(f"- once-only: {n_ind} independent, {n_sh} shared-only\n")
lines.append(f"- two-phase mint: {n2} independent local confirmMint\n")
lines.append("\nFull census requires expanding the primitive list and human confirmation.\n")
out.write_text("".join(lines))
print("wrote", out)
for r in rows:
    print("once", r)
for r in rows2:
    print("mint", r)
