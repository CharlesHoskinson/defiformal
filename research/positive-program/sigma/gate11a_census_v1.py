#!/usr/bin/env python3
"""Gate 1.1a independent-witness census v1. See GATE-1.1A-METHOD.md."""
from pathlib import Path
import re

root = Path("quint-models")
specs = sorted(p for p in root.glob("L*/*.qnt") if p.name != "common.qnt")
# also scan v2 for mandate (N8)
v2 = sorted(Path("quint-models-v2").glob("*.qnt")) if Path("quint-models-v2").exists() else []

def read(p: Path) -> str:
    try:
        return p.read_text(errors="ignore")
    except Exception:
        return ""

def is_local(t: str, def_pats: list[str]) -> bool:
    for d in def_pats:
        if re.search(rf"(?:action|pure def|def|type|var)\s+{d}\b", t):
            return True
    return False

def is_called(t: str, call_pats: list[str]) -> bool:
    return any(re.search(rf"\b{c}\b", t) for c in call_pats)

# (name, call patterns from common, local definition markers)
PRIM = [
    ("N6-onceOnly",
     ["canDeliverOnce", "markUsed"],
     ["PacketStatus", "usedNonces", "nonceUsed"]),
    ("N5-custody-wrap",
     ["canMintWrap", "applyMintWrap", "emptyWrap", "canBurnWrap"],
     ["confirmMint", "merchantBurn", "addMintRequest", "WrapSupply"]),
    ("N8-delegation",
     ["canDelegate", "applyDelegate", "canExecute", "applyExecute"],
     ["reallocate", "setIsAllocator", "executeOnAdapter", "isAllocator"]),
    ("F2-deferred-claim",
     ["canEnqueue", "headReady", "canClaim", "applyClaim", "emptyAsyncReq"],
     ["requestWithdraw", "readyAt", "priorityQueue", "claimMint", "claimRedemption"]),
    ("F7-index-accrual",
     ["presentFromScaled", "accrueIndex", "scaledFromPresent"],
     ["liquidityIndex", "variableBorrowIndex", "borrowIndex", "exchangeRate", "syRate"]),
    ("N1-cp-swap",
     ["cpAmountOut", "cpApplySwap", "cpProduct"],
     ["reserve0", "reserve1", "kLast"]),
    ("F5-health",
     ["isHealthy", "canLiquidate", "collateralRatio"],
     ["liquidate", "LLTV", "healthFactor"]),
    ("N3-rateCurve",
     ["utilization", "twoSlopeRate"],
     ["borrowRate", "supplyRate"]),  # local rate vars, not just calls
    ("N10-authz",
     ["isRestricted", "setRestricted", "canMintWithAllowance"],
     ["frozen", "blacklist", "isMinter"]),
]

# Hand overrides after semantic spot-check (path suffix -> class)
OVERRIDES = {
    # cctp implements flow but once-only core is common.canDeliverOnce/markUsed
    ("N6-onceOnly", "L4/cctp.qnt"): "SHARED",
    # layerzero local PacketStatus machine
    ("N6-onceOnly", "L4/layerzero.qnt"): "INDEPENDENT",
    # aave/compound call common utilization/twoSlope without local curve def
    ("N3-rateCurve", "L1/aave_v3.qnt"): "SHARED",
    ("N3-rateCurve", "L1/compound_v3.qnt"): "SHARED",
}

def classify(name, call_pats, def_pats, path, t):
    key = (name, "/".join(path.parts[-2:]))
    if key in OVERRIDES:
        return OVERRIDES[key]
    local = is_local(t, def_pats)
    called = is_called(t, call_pats)
    if local:
        return "INDEPENDENT"
    if called:
        return "SHARED"
    return None

def scan(paths, name, call_pats, def_pats):
    hits = []
    for p in paths:
        t = read(p)
        cls = classify(name, call_pats, def_pats, p, t)
        if cls:
            hits.append((str(p).replace("\\", "/"), cls))
    return hits

def main():
    results = {}
    for name, call_pats, def_pats in PRIM:
        hits = scan(specs, name, call_pats, def_pats)
        if name == "N8-delegation":
            hits += scan(v2, name, call_pats, def_pats)
        results[name] = hits

    lines = [
        "# Gate 1.1a — independent-witness census v1\n\n",
        "**Status: MEASURED (partial)** 2026-08-07\n\n",
        "Method: `GATE-1.1A-METHOD.md`. Script: `gate11a_census_v1.py`.\n\n",
        "INDEPENDENT = local action/var/type for the mechanism. SHARED = common helper call only.\n",
        "Hand overrides applied for N6 cctp and N3 aave/compound (see script OVERRIDES).\n\n",
        "Retired: pre-method identifier counts (28/50, 31/19).\n\n",
        "## Summary\n\n",
        "| primitive | independent | shared-only | ≥2 independent? |\n",
        "|---|---:|---:|---|\n",
    ]
    yes = no = 0
    for name, hits in results.items():
        n_i = sum(1 for _, c in hits if c == "INDEPENDENT")
        n_s = sum(1 for _, c in hits if c == "SHARED")
        meets = "YES" if n_i >= 2 else "NO"
        if n_i >= 2:
            yes += 1
        else:
            no += 1
        lines.append(f"| {name} | {n_i} | {n_s} | **{meets}** |\n")
    lines.append(f"\n**{yes} / {yes+no} primitives meet ≥2 independent witnesses.**\n\n")
    lines.append("## Detail\n\n")
    for name, hits in results.items():
        n_i = sum(1 for _, c in hits if c == "INDEPENDENT")
        n_s = sum(1 for _, c in hits if c == "SHARED")
        lines.append(f"### {name}\n\nIndependent **{n_i}**, shared-only **{n_s}**\n\n")
        if not hits:
            lines.append("_no hits_\n\n")
            continue
        lines.append("| spec | class |\n|---|---|\n")
        for path, cls in sorted(hits, key=lambda x: (0 if x[1] == "INDEPENDENT" else 1, x[0])):
            lines.append(f"| `{path}` | **{cls}** |\n")
        lines.append("\n")
    lines.append("## Disposition\n\n")
    lines.append("Gate 1.1a is **MEASURED** on a fixed 9-primitive sample under the independence method.\n")
    lines.append("Not a full BASIS family census. Extend PRIM + OVERRIDES to close remaining rows.\n")
    lines.append("Primitives failing ≥2 independent (N5, N3 as scored) must not be pruned solely on count.\n")
    out = Path("research/positive-program/sigma/GATE-1.1A-CENSUS-V1.md")
    out.write_text("".join(lines))
    print("wrote", out)
    for name, hits in results.items():
        n_i = sum(1 for _, c in hits if c == "INDEPENDENT")
        n_s = sum(1 for _, c in hits if c == "SHARED")
        print(f"{name}: indep={n_i} shared={n_s}")

if __name__ == "__main__":
    main()
