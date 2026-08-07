# Deletion class 11 (access control) — scanned, hand-audited, and bounded

**Verdict: 4 confirmed deletions across 3 specs, all outside `P2-SCOPE`'s ten.
But the method's ceiling is the real finding — a spec scan can only see access
control the author documented, and silent omission is the normal case. This class
cannot be sized without reading contracts.**

Script: `sigma/deletion11_scan.py`.

---

## The scan

An action whose **own comment** asserts an access restriction and whose code
models no caller. Deliberately calibrated to under-report: anything resembling
caller modelling — a caller-ish parameter, a membership test, a role guard —
counts as modelled.

    actions whose comment asserts an access restriction : 9
       of those, modelling a caller in any form         : 2
       of those, modelling nothing                      : 7

Seven is not the answer. All seven were hand-checked, because two detectors in
this programme have already produced false positives by trusting a regex.

## The hand audit

| spec | action | comment | verdict |
|---|---|---|---|
| `coinbase` | `mint` | "MintForwarder.mint — onlyCallers" | **DELETION** — signature `(dst, amt)`; guards are rate-limit and blacklist, no caller anywhere |
| `usdc` | `configureMinter` | "masterMinter configures minter allowance" | **DELETION** — the masterMinter role is absent; any step may configure any minter |
| `wbtc` | `confirmMint` | "onlyCustodian" | **DELETION** — signature `(id: int)` |
| `wbtc` | `rejectMint` | "onlyCustodian" | **DELETION** — signature `(id: int)` |
| `usdc` | `mint` | "onlyMinters" | **false positive** — takes `minter: str` and guards `canMintWithAllowance(isMinter, minterAllowed, minter, amount)`. It models the authority; my detector missed it because `minter` was lowercase and absent from the caller word list. |
| `wbtc` | `addMintRequest` | (module-level "onlyCustodian" text) | **arguable, not counted** — hardcodes `requester: MERCHANT`. One merchant instead of many is a scope restriction (E<=), not a deleted mechanism, and the claim came from the module comment rather than the action's own. |
| `coinbase` | `init` | — | **artifact** — an initialiser, matched by comment-block attribution |

**Confirmed: 4 deletions, in `coinbase`, `usdc` and `wbtc`. All three are outside
the ten protocols `P2-SCOPE` re-specced.**

---

## The ceiling, which matters more than the count

The scan finds an action only if **the spec author wrote the restriction down and
then did not implement it.** That is a narrow and slightly odd population — it
requires the author to have known about the access control at the moment of
writing the comment.

The normal deletion is silent. A spec that simply never mentions that
`setOracle` is `onlyGovernance` produces no comment for this scan to match, and
is indistinguishable from a function that genuinely has no access control. Nine
documented claims across 51 specs is implausibly few for a corpus of DeFi
protocols, where access control is close to universal.

**So 4 is a floor of a floor, and the gap cannot be closed by reading specs.** It
needs the contracts — which is precisely the method Phase 2's re-specs use and
that nothing else in the programme does.

---

## What this settles, and what it does not

**Settles:** deletion class 11 is real, it is not confined to `wbtc`, and it
occurs in protocols nobody re-specced. `P2-SCOPE`'s ten were the ten found by
looking at ten protocols; at minimum three more protocols carry the same class.

**Does not settle:** how large the class is. The honest answer is that this
question is not answerable from the specs, and any number produced by scanning
them — including the 4 above — is a lower bound of unknown tightness.

**Strengthens the pair-4 conclusion.** 1.1b's autonomy law needs caller authority
modelled. This scan shows the modelling is absent wherever it was documented, and
gives no reason to think it is present where it was not. Phase 1's dependency on
an honest corpus is not one awkward protocol; it is structural.

---

## Recommendation, unchanged in direction and firmer in support

1. **Caller authority becomes a Phase 2 convention.** Every re-spec must model who
   may call each state-changing action, or declare the omission as an explicit
   (E<=) restriction with the contract line it drops. `wbtc.addMintRequest`'s
   single `MERCHANT` is what a declared restriction looks like; `confirmMint`'s
   silence is what a deletion looks like, and the two are currently
   indistinguishable in review.
2. **2.2 before the rest of 1.1b**, since remaining pairs will hit this wall.
3. **Do not quote a size for this class.** Record the 4, record that the method
   cannot see the rest.

## Reproduce

    python3 sigma/deletion11_scan.py
    sed -n '35,60p'  quint-models/L6/usdc.qnt
    sed -n '28,42p'  quint-models/L4/coinbase.qnt
