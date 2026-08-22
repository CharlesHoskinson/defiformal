#!/usr/bin/env python3
"""CONVERSE CHECK + INDEPENDENCE.

(1) Every operator declared in a lane common.qnt is assigned to one of the eight
    proposed families F1..F8, to KERNEL (pure arithmetic, not a family), or to a
    NEW family that P does not contain.  Any op landing in NEW is a witness that
    P is not the basis: the lane commons themselves already use a mechanism
    outside the eight.

(2) Independence: for each family F, is every F-op's body a term over
    (ops of families other than F) U KERNEL U plumbing?  If yes, F adds no term
    content and is not independent as a generator.
"""
import json, os, collections
import os as _os
from pathlib import Path as _Path
# Resolved from this file's own location, the pattern gate33_cert_check.py uses.
# DEFIFORMAL_ROOT overrides and says so.
_SELF = _Path(__file__).resolve().parents[3]
_REPO = _Path(_os.environ.get("DEFIFORMAL_ROOT", _SELF))
if str(_REPO) != str(_SELF):
    import sys as _sys
    print("%s: NOTE - reading %s (DEFIFORMAL_ROOT), not %s"
          % (_Path(__file__).name, _REPO, _SELF), file=_sys.stderr)


IR = _os.environ.get("GEN_IR", str(_REPO / "research/positive-program/basis/gen-ir"))
HARD = {"imul", "idiv", "imod", "ipow"}

FAM = {
 # ---- pure arithmetic / scale constants: NOT families ----
 "min":"KERNEL","max":"KERNEL","abs":"KERNEL","WAD":"KERNEL","RAY":"KERNEL","BPS":"KERNEL",
 "INDEX_BASE":"KERNEL","ODDS_BASE":"KERNEL",
 # mulDiv IS the pro-rata map a*b/d.  Calling it neutral arithmetic is the
 # degeneracy: it would hand F1's entire content to the plumbing.
 "mulDivDown":"F1","mulDivUp":"F1","ceilDiv":"F1","divFloor":"F1",
 # ---- F1 pro-rata share ledger ----
 "sharesFromAssets":"F1","assetsFromShares":"F1","assetsToShares":"F1","sharesToAssets":"F1",
 "assetsToSharesCeil":"F1","sharesFromNav":"F1","assetsFromNav":"F1","navRoundTripLeq":"F1",
 "emptyShareVault":"F1","canDeposit":"F1","applyDeposit":"F1","canRedeem":"F1","applyRedeem":"F1",
 "shareSolvency":"F1","geometricMint":"F1",
 # ---- F2 deferred claim / two-phase request ----
 "emptyQueueEntry":"F2","queueSum":"F2","canEnqueue":"F2","enqueue":"F2","headReady":"F2",
 "emptyAsyncReq":"F2","canRequest":"F2","applyRequest":"F2","canClaim":"F2","applyClaim":"F2",
 "canPrice":"F2","applyPrice":"F2","canConfirmMint":"F2","applyApprove":"F2","applyReject":"F2",
 "applyCancel":"F2","canFill":"F2","applyFill":"F2",
 # ---- F3 rate limit / flow envelope ----
 "currentLimit":"F3","canConsume":"F3","consume":"F3","consumeLimit":"F3","refundLimit":"F3",
 "replenish":"F3","canRateLimitedMint":"F3","applyRateLimitedMint":"F3","capacity":"F3",
 "canReserve":"F3","applyReserve":"F3","canRelease":"F3","applyRelease":"F3","emptyReserved":"F3",
 "canBook":"F3",
 # ---- F4 conservation law ----
 "mapSum":"F4","sumMap":"F4","nonNegMap":"F4","supplyConserved":"F4","burnMintConserved":"F4",
 "deltasNetZero":"F4","cpKHolds":"F4","pyBackingHolds":"F4","reservedSolvent":"F4",
 "reserveCovers":"F4","canSplit":"F4","canMerge":"F4","remainingBounded":"F4",
 # ---- F5 health / margin predicate ----
 "isHealthy":"F5","collateralRatio":"F5","seizeCollateral":"F5","maintainsMargin":"F5",
 "canLiquidate":"F5","isMarginSolvent":"F5","equity":"F5","utilCollateralReq":"F5",
 "unrealizedPnl":"F5",
 # ---- F6 valuation SOURCE  () -> P ----
 "canPostPrice":"F6","applyPostPrice":"F6","applyPayClaim":"F2",
 "Long":"CTOR","Short":"CTOR","Flat":"CTOR","Pending":"CTOR","Approved":"CTOR","Rejected":"CTOR","Canceled":"CTOR","Unfilled":"CTOR","Filled":"CTOR","SlowRequested":"CTOR","NotDelegated":"CTOR","Delegated":"CTOR","Executed":"CTOR","Revoked":"CTOR","Empty":"CTOR","Priced":"CTOR","Claimed":"CTOR",
 # ---- F7 index accrual ----
 "presentFromScaled":"F7","scaledFromPresent":"F7","accrueIndex":"F7","accrueByIndex":"F7",
 "sharesFromIndex":"F7","assetsFromIndex":"F7","initIndex":"F7","ratchetIndex":"F7",
 "streamIndex":"F7","indexMonotone":"F7","initFunding":"F7","advanceFunding":"F7",
 "fundingOwed":"F7","syToAsset":"F7","assetToSy":"F7","mintPyAmount":"F7","redeemSyFromPy":"F7",
 # ---- F8 payoff function ----
 "callPayoff":"F8","putPayoff":"F8","europeanPayoff":"F8","signedSettlement":"F8",
 "validBinaryPayout":"F8","redeemPayout":"F8","betPayout":"F8",

 # ================= OUTSIDE THE EIGHT =================
 # N1 trading function / bonding curve : (R,R,A) -> A determined by an invariant
 "cpAmountOut":"N1-swap","cpApplySwap":"N1-swap","cpProduct":"N1-swap",
 # N2 valuation APPLICATION (mark-to-market) : (A,P) -> V.  F6 supplies P; nothing
 #    in the eight turns (amount, price) into a value.
 "collValue":"N2-markToMarket","positionValue":"N2-markToMarket","emptyPosition":"N2-markToMarket",
 # N3 utilization-indexed rate curve : U -> r  (sets the price of capital)
 "utilization":"N3-rateCurve","twoSlopeRate":"N3-rateCurve",
 # N4 tranche subordination / loss waterfall
 "totalTranche":"N4-tranche","applyLoss":"N4-tranche","applyProfit":"N4-tranche",
 "seniorFirstRedeem":"N4-tranche",
 # N5 custody / escrow / wrap across a trust boundary
 "emptyWrap":"N5-custody","canMintWrap":"N5-custody","applyMintWrap":"N5-custody",
 "canBurnWrap":"N5-custody","applyBurnWrap":"N5-custody","canEscrowDeposit":"N5-custody",
 "applyEscrowDeposit":"N5-custody","canEscrowWithdraw":"N5-custody","applyEscrowWithdraw":"N5-custody",
 "canBurnMintSend":"N5-custody","applyBurnOnSrc":"N5-custody","applyMintOnDst":"N5-custody",
 # N6 once-only delivery / replay exclusion
 "canDeliverOnce":"N6-onceOnly","markUsed":"N6-onceOnly",
 # N7 limit order with partial fill
 "emptyOrder":"N7-limitOrder","canFillOrder":"N7-limitOrder","takingForFill":"N7-limitOrder",
 "applyFillOrder":"N7-limitOrder","applyCancelOrder":"N7-limitOrder","clearsAtLimit":"N7-limitOrder",
 # N8 delegated authority (the mandate)
 "canDelegate":"N8-delegation","canExecute":"N8-delegation","canRevoke":"N8-delegation",
 "applyDelegate":"N8-delegation","applyExecute":"N8-delegation","applyRevoke":"N8-delegation",
 # N9 the plain ledger: transfer / mint / burn of a named balance
 "canTransfer":"N9-ledger","applyTransfer":"N9-ledger","canMintTo":"N9-ledger","applyMint":"N9-ledger",
 "canBurnFrom":"N9-ledger","applyBurn":"N9-ledger","canMintSupply":"N9-ledger",
 "applyMintSupply":"N9-ledger","canBurnSupply":"N9-ledger","applyBurnSupply":"N9-ledger",
 "canDepositCash":"N9-ledger","applyDepositCash":"N9-ledger","canWithdrawCash":"N9-ledger",
 "applyWithdrawCash":"N9-ledger",
 # N10 authorization / permissioning
 "isRestricted":"N10-authz","setRestricted":"N10-authz","eitherRestricted":"N10-authz",
 "canMintWithAllowance":"N10-authz","consumeAllowance":"N10-authz",
}

# ---------------- load basis bodies ----------------
basis = {}
for fn in sorted(f for f in os.listdir(IR) if "__" in f and f.endswith(".json")):
    lane, spec = fn[:-5].split("__")
    if spec != "common": continue
    d = json.load(open(os.path.join(IR, fn)))
    m = [x for x in d["modules"] if x["name"] == "common"][0]
    ops = {}
    for de in m["declarations"]:
        if de["kind"] == "def":
            b = de.get("expr", {})
            if b.get("kind") == "lambda": b = b["expr"]
            ops[de["name"]] = b
    basis[lane] = ops

allops = {}
for lane, ops in basis.items():
    for n, b in ops.items(): allops.setdefault(n, (lane, b))

unassigned = [n for n in allops if n not in FAM]
print("lane primitives total (distinct names):", len(allops))
print("unassigned:", unassigned)

byfam = collections.Counter(FAM.get(n, "??") for n in allops)
print("\n--- family census over the lane commons ---")
for f, c in sorted(byfam.items()): print(f"   {f:20s} {c}")
inside = sum(c for f, c in byfam.items() if f.startswith("F"))
kern   = byfam.get("KERNEL", 0)
outside= sum(c for f, c in byfam.items() if f.startswith("N"))
print(f"\n   in F1..F8 : {inside}")
print(f"   KERNEL    : {kern}")
print(f"   OUTSIDE P : {outside}   ({len(set(f for f in byfam if f.startswith('N')))} new families)")

# ---------------- independence ----------------
def used(e, out):
    if not isinstance(e, dict): return
    k = e.get("kind")
    if k == "app":
        out.add(e["opcode"])
        for a in e.get("args", []): used(a, out)
    elif k == "name": out.add(e["name"])
    elif k == "lambda": used(e.get("expr"), out)
    elif k == "let":
        d = e.get("opdef")
        if d: used(d.get("expr"), out)
        used(e.get("expr"), out)

print("\n--- INDEPENDENCE: is F definable from the OTHER families? ---")
print("    F is DEPENDENT iff every F-op body is a term over")
print("    (ops of families != F) U KERNEL U plumbing, with hard arithmetic banned.")
for F in ["F1","F2","F3","F4","F5","F6","F7","F8"]:
    irreducible = []
    members = 0
    for lane, ops in basis.items():
        for n, b in ops.items():
            if FAM.get(n) != F: continue
            members += 1
            u = set(); used(b, u)
            needs_F   = [x for x in u if x in allops and FAM.get(x) == F and x != n]
            needs_raw = [x for x in u if x in HARD]
            if needs_F or needs_raw:
                irreducible.append((f"{lane}.{n}", needs_F, needs_raw))
    if not irreducible:
        print(f"  {F}: {members:3d} ops | DEPENDENT -- every op reduces to other families "
              f"+ kernel + plumbing.  NOT a primitive.")
    else:
        print(f"  {F}: {members:3d} ops | INDEPENDENT -- {len(irreducible)} op(s) "
              f"irreducible outside {F}. e.g.:")
        for a, nf, nr in irreducible[:3]:
            why = (f"needs {F} op {nf}" if nf else "") + (f" needs raw {nr}" if nr else "")
            print(f"        {a}: {why.strip()}")
