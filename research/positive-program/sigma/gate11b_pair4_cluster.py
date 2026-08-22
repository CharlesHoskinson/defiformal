"""1.1b pair 4: the deferred-claim cluster. Four names, one skeleton?

  L1  WITHDRAWAL_QUEUE            maple  queueShares: str -> int
  L3  DelayedExit queue           QueueItem {owner, amount, readyAt}
  L5  ASYNC_REQUEST_CLAIM         AsyncRequest {owner, amount, price, phase}
  L4  TWO_PHASE_CUSTODIAN_REQUEST CustodianRequest {requester, amount, status}

All four are: record a request, wait for a gate to open, then claim. They differ
only in WHAT OPENS THE GATE --

  L1  nothing        claimable once the pool has liquidity
  L3  time           readyAt
  L5  a posted price phase Pending -> Priced
  L4  an authority   status Pending -> Approved  ("onlyCustodian")

The obvious candidate law is AUTONOMY: can the holder reach `claimable` without
another party's cooperation? Time passes on its own; a custodian may refuse. That
would split the cluster 2-2 rather than 4-way, and it would be the first
separating law in the programme.

It is only a law if the specs actually MODEL the restriction. `confirmMint`'s
comment says "onlyCustodian" but the action takes `(id: int)` and no caller. So
this script measures, per unblocking action, whether any caller/authority guard
is present -- rather than reading the comment and believing it, which is artifact
class 3 (asserted, not measured).
"""
import glob
import os
import re
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


ROOT = str(_REPO / "quint-models")
HEAD = re.compile(r"^\s*(?:pure\s+)?(action|def)\s+([A-Za-z_][A-Za-z0-9_]*)"
                  r"\s*(\(([^)]*)\))?", re.M)

# the action in each spec that OPENS the gate, per mechanism
TARGETS = {
    "L1 WITHDRAWAL_QUEUE": [("L1/maple.qnt", "processRedeem")],
    "L3 DelayedExit": [("L3/lighter.qnt", None), ("L3/hyperliquid.qnt", None),
                       ("L3/huma.qnt", None)],
    "L5 ASYNC_REQUEST_CLAIM": [("L5/centrifuge.qnt", None), ("L5/ondo.qnt", None)],
    "L4 TWO_PHASE_CUSTODIAN": [("L4/wbtc.qnt", "confirmMint")],
}
# Names indicating an access-control guard on the CALLER.
#
# `owner` is deliberately absent and the lookbehind for `.` is deliberately
# present. `owner` is a FIELD of QueueItem / AsyncRequest / CustodianRequest, so
# a body reading `r.owner` or `hd.owner` is accessing the request record, not
# checking who called. A first cut of this detector included `owner` with a plain
# `\b` and reported 3 guards -- every one of them a field read
# (`l2Balances.put(hd.owner, ...)`, `maxMint.put(r.owner, ...)`).
AUTHORITY = re.compile(
    r"(?<![.\w])(caller|sender|msgSender|admin|custodian|operator|issuer|"
    r"guardian|manager|keeper|onlyOwner|isAdmin|AUTHORITY|ADMIN|OWNER)\b")
# actions that plausibly open a deferred-claim gate
GATE_HINT = re.compile(
    r"(process|claim|fulfil|fulfill|confirm|approve|price|settle|redeem|"
    r"tick|advance|unlock|release|execute)", re.I)


def actions_of(path):
    src = re.sub(r"//[^\n]*", "",
                 open(path, encoding="utf-8", errors="replace").read())
    heads = list(HEAD.finditer(src))
    out = []
    for i, h in enumerate(heads):
        if h.group(1) != "action":
            continue
        end = heads[i + 1].start() if i + 1 < len(heads) else len(src)
        out.append((h.group(2), h.group(4) or "", src[h.end():end]))
    return out


print(__doc__)
print("=" * 76)
print(f"{'mechanism':<24} {'spec':<14} {'gate action':<18} {'params':<14} auth?")
print("-" * 76)
rows = []
for mech, specs in TARGETS.items():
    for rel, want in specs:
        path = os.path.join(ROOT, rel)
        if not os.path.exists(path):
            print(f"{mech:<24} {rel:<14} MISSING")
            continue
        for name, params, body in actions_of(path):
            if want and name != want:
                continue
            if not want and not GATE_HINT.search(name):
                continue
            guarded = bool(AUTHORITY.search(params) or AUTHORITY.search(body))
            rows.append((mech, os.path.basename(rel)[:-4], name, params, guarded))
            print(f"{mech:<24} {os.path.basename(rel)[:-4]:<14} {name[:18]:<18}"
                  f" {params[:14]:<14} {'YES' if guarded else 'no'}")

print("\n" + "=" * 76)
by_mech = {}
for mech, spec, name, params, guarded in rows:
    by_mech.setdefault(mech, []).append(guarded)
print(f"{'mechanism':<26} {'gate actions':>13} {'with an authority guard':>25}")
for mech, gs in by_mech.items():
    print(f"{mech:<26} {len(gs):>13} {sum(gs):>25}")

total = sum(len(v) for v in by_mech.values())
guarded_total = sum(sum(v) for v in by_mech.values())
print(f"\n  {guarded_total} of {total} gate-opening actions carry any"
      f" caller/authority guard.")
print()
if guarded_total == 0:
    print("  VERDICT: the AUTONOMY law cannot be tested on this corpus. Not one")
    print("  spec models who may open the gate, so in every one of the four")
    print("  mechanisms the gate is opened by an unguarded action any step may")
    print("  fire. The distinction the law would rest on -- a custodian who may")
    print("  refuse versus a clock that cannot -- was DELETED from the specs.")
    print()
    print("  wbtc's `confirmMint` is the clean witness: its comment reads")
    print("  'onlyCustodian', and its signature is (id: int).")
else:
    print("  VERDICT: some gates are guarded; the law is testable. Inspect above.")
