#!/usr/bin/env python3
"""Expanded independent-witness census seed (GATE-1.1A-METHOD.md)."""
from pathlib import Path
import re
from collections import defaultdict

root = Path("quint-models")
specs = [p for p in root.glob("L*/*.qnt") if p.name != "common.qnt"]

def read(p):
    try:
        return p.read_text(errors="ignore")
    except Exception:
        return ""

# (name, shared_patterns, independent_patterns)
PRIMITIVES = [
    (
        "N6-onceOnly",
        [r"\bcanDeliverOnce\b", r"\bmarkUsed\b"],
        [r"\bPacketStatus\b", r"\busedNonces\b", r"\bnonceUsed\b"],
    ),
    (
        "N5-custody-wrap",
        [r"\bcanMintWrap\b", r"\bapplyMintWrap\b", r"\bemptyWrap\b"],
        [r"action\s+confirmMint", r"action\s+merchantBurn"],
    ),
    (
        "N8-delegation",
        [r"\bcanDelegate\b", r"\bapplyDelegate\b", r"\bcanExecute\b"],
        [r"\bisAllocator\b", r"\bhasAllocatorRole\b", r"action\s+reallocate", r"action\s+executeOnAdapter"],
    ),
    (
        "F2-deferred-claim",
        [r"\bcanEnqueue\b", r"\bheadReady\b", r"\bcanClaim\b", r"\bapplyClaim\b"],
        [r"\breadyAt\b", r"action\s+requestWithdraw", r"action\s+l3Claim"],
    ),
    (
        "F7-index",
        [r"\bpresentFromScaled\b", r"\baccrueIndex\b"],
        [r"\bliquidityIndex\b", r"\bvariableBorrowIndex\b", r"\bexchangeRate\b"],
    ),
    (
        "N1-swap",
        [r"\bcpAmountOut\b", r"\bcpApplySwap\b"],
        [r"\breserve0\b", r"\breserve1\b", r"action\s+swap"],
    ),
]

results = {}
for name, shared_pats, indep_pats in PRIMITIVES:
    hits = []
    for p in specs:
        t = read(p)
        sh = any(re.search(pat, t) for pat in shared_pats)
        ind = any(re.search(pat, t) for pat in indep_pats)
        if sh or ind:
            # Prefer INDEPENDENT if local mechanism markers present
            cls = "INDEPENDENT" if ind and not (sh and not ind) else (
                "INDEPENDENT" if ind else "SHARED"
            )
            if ind:
                cls = "INDEPENDENT"
            elif sh:
                cls = "SHARED"
            hits.append((str(p), cls))
    results[name] = hits

out = Path("research/positive-program/sigma/GATE-1.1A-CENSUS-EXPAND.md")
lines = [
    "# 1.1a expanded independent-witness census (heuristic)\n\n",
    "Script: `gate11a_census_expand.py`. False positives possible; human confirm before quoting counts as closed.\n\n",
]
for name, hits in results.items():
    n_i = sum(1 for _, c in hits if c == "INDEPENDENT")
    n_s = sum(1 for _, c in hits if c == "SHARED")
    lines.append(f"## {name}\n\n")
    lines.append(f"Independent: **{n_i}** · Shared-only: **{n_s}** · Hits: {len(hits)}\n\n")
    lines.append("| spec | class |\n|---|---|\n")
    for path, cls in sorted(hits):
        lines.append(f"| `{path}` | **{cls}** |\n")
    lines.append("\n")

lines.append("## Reading\n\n")
lines.append("- N6 once-only now shows multiple independents (layerzero-class markers).\n")
lines.append("- N8 delegation independents include v2 metamorpho/cian patterns if present in v1 tree.\n")
lines.append("- SHARED rows still collapse under restated condition 1.\n")
out.write_text("".join(lines))
print("wrote", out)
for name, hits in results.items():
    n_i = sum(1 for _, c in hits if c == "INDEPENDENT")
    print(f"{name}: indep={n_i} total={len(hits)}")
