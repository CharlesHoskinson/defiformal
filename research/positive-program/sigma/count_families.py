"""Mechanically recount which lanes evidence each candidate primitive family.
GOAL.md ranks the eight families by lane count; those counts were tabulated by
hand. This recomputes them from the ledger section 5 tables."""
import glob
import re
from collections import defaultdict

LEDGERS = sorted(glob.glob(
    "/root/DefiElements/research/positive-program/insights/INSIGHT-L*.md"))

# family -> regexes matching a section-5 row that evidences it
FAMILIES = {
    "F1 share ledger": r"share|pro.?rata|SHARE_SUPPLY|BALANCE_LEDGER|ShareVault|assetsToShares|sharesFromAssets",
    "F2 deferred claim": r"queue|QueueEntry|QueueItem|DelayedExit|ASYNC_REQUEST|WITHDRAWAL_QUEUE|TWO_PHASE|request.*claim",
    "F3 rate limit": r"RATE_LIMIT|RateLimit|rate.?limit|refill|envelope",
    "F4 conservation": r"conserv|supplyConserved|NetZero|deltasNetZero|burnMintConserved|pyBackingHolds|validBinaryPayout",
    "F5 health predicate": r"health|isHealthy|margin|maintainsMargin|COLLATERALIZED_HEALTH|collateralRatio|isMarginSolvent|canLiquidate",
    "F6 valuation source": r"NAV|PostedPrice|ADMIN_POSTED|price|oracle|reserveCovers",
    "F7 index accrual": r"index|Index|accrue|accrual|exchangeRate|rewardPerToken",
    "F8 payoff": r"payoff|europeanPayoff|betPayout|redeemPayout|signedSettlement",
}

rows_by_lane = defaultdict(list)
for path in LEDGERS:
    lane = re.search(r"INSIGHT-(L\d)", path).group(1)
    txt = open(path, encoding="utf-8", errors="replace").read()
    m = re.search(r"^## 5\.(.*?)^## 6\.", txt, re.S | re.M)
    if not m:
        print(f"!! {lane}: no section 5 found")
        continue
    for line in m.group(1).splitlines():
        s = line.strip()
        if s.startswith("|") and s.count("|") >= 3 and "---" not in s:
            cells = [c.strip() for c in s.strip("|").split("|")]
            if cells and cells[0].lower() not in ("candidate primitive", ""):
                rows_by_lane[lane].append(s)

print("section-5 rows per lane:")
for lane in sorted(rows_by_lane):
    print(f"   {lane}: {len(rows_by_lane[lane])}")
print(f"   TOTAL: {sum(len(v) for v in rows_by_lane.values())}\n")

print(f"{'family':<22} {'lanes':<7} which")
print("-" * 60)
for fam, pat in FAMILIES.items():
    rx = re.compile(pat, re.I)
    hits = sorted(l for l, rows in rows_by_lane.items()
                  if any(rx.search(r) for r in rows))
    print(f"{fam:<22} {len(hits)}/6    {','.join(hits)}")

print("\n--- rows matching NO family (candidate missing primitives) ---")
allrx = [re.compile(p, re.I) for p in FAMILIES.values()]
unmatched = 0
for lane in sorted(rows_by_lane):
    for r in rows_by_lane[lane]:
        if not any(rx.search(r) for rx in allrx):
            name = r.strip("|").split("|")[0].strip()
            print(f"   {lane}: {name[:70]}")
            unmatched += 1
print(f"   unmatched rows: {unmatched}")
