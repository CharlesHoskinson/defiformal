# The surjectivity test applied — and a third verdict, FROZEN

**Three results. The five untested OMITTED entries are now sorted: two safe,
three unsafe. The criterion needed one refinement — surjectivity is a property of
the transition, not the caller. And huma exposed a verdict 6h does not have,
which also means the scan over-reports MODELLED.**

---

## 1. The five, sorted

| entry | gate | verdict |
|---|---|---|
| `uniswap_v2.setFeeTo` | `msg.sender == feeToSetter`; `setFeeToSetter` is itself `feeToSetter`-only | **NON-SURJECTIVE — unsafe** |
| `huma.distributeProfit` | `_onlyCreditOrCreditManager(msg.sender)` | surjective **via relay** — safe |
| `huma.distributeLoss` | `msg.sender != creditManager` reverts | surjective **via relay** — safe |
| `huma.disburse` | `@custom:access Only the lender`; `LENDER_ROLE` granted by `addApprovedLender`, `onlyPoolOperator` | **NON-SURJECTIVE — unsafe** |
| `huma.closePool` | `onlyPoolOwnerOrHumaOwner` | **NON-SURJECTIVE — unsafe** |

**`uniswap_v2.setFeeTo` is a closed cycle.** `setFeeTo` requires `feeToSetter`,
and `setFeeToSetter` requires `feeToSetter` too, so no user can ever enter the
role. The spec carries `action setFeeTo` unguarded, which lets any step flip the
protocol fee switch that gates `_mintFee`. **The spec permits transitions the
contract forbids.** The spec's own header notices the shape — *"Factory
`setFeeToSetter` (:45-48): authority over the authority"* — and abstracts it
anyway.

## 2. The refinement — surjectivity is about the transition, not the caller

`huma.distributeProfit` requires the caller to **be** the `Credit` contract. No
user can ever hold that address, so on the caller test it is maximally
non-surjective. But a borrower calling `makePayment` causes `Credit` to call it.
The transition is reachable by any user; only the direct call is not.

That is the same shape as apex: user → `Router` → `Margin.liquidate`.

> **Corrected test.** An omission is `(E<=)`-safe iff the *transition* is
> reachable by an arbitrary principal along some path — not iff the *function*
> is directly callable. Relay patterns (router, adapter, internal-caller) are
> surjective; role grants are not.

Stated the first way, the criterion would have marked apex safe and huma's
distributions unsafe, which is backwards.

## 3. FROZEN — a verdict 6h is missing

`huma.qnt:463` declares

    pure val LENDERS: Set[str] = Set("u1", "u2")

and guards `depositSenior`, `depositJunior` and `disburse` with
`LENDERS.contains(u)`. So the role **is** modelled — as a **constant**.

The contract mutates it: `addApprovedLender` (`onlyPoolOperator`) grants
`LENDER_ROLE`, `removeApprovedLender` revokes it. 6h says authority state must be
`var` wherever the contract lets it change, because freezing it deletes the
*granting* of authority — which is `Perm`'s first law, monotone delegation.

So huma is neither MODELLED nor OMITTED:

> **FROZEN** — the guard is present, but the authority is a constant where the
> contract mutates it. Sound as an `(E<=)` restriction on role configurations,
> and it deletes the grant mechanism.

`wbtc.addMintRequest`'s hardcoded `requester: MERCHANT` is the same verdict, and
`DELETION-11.md` called it "a declaration done accidentally". It now has a name.

**FROZEN is where the mandate hides.** A frozen role set cannot exhibit
`wit_operatorGranted` or `wit_mandateGranted`; the permission coordinate is
present but constant, so no witness can show that holding it is contingent. Every
FROZEN entry is a place where `Perm` was half-deleted.

## 4. Consequence — the scan over-reports MODELLED

`phase2/auth_scan.py` scores MODELLED when the action's first parameter is
caller-ish. That is not 6h's requirement, which is a guard **against mutable
authority state**. huma's four MODELLED entries are FROZEN, and the headline
figure of 13 MODELLED is inflated by at least that much.

The fix is a scan that checks whether the guarded identifier is compared against
a `var`, and reports FROZEN when it is compared against a `pure val`. Not done
here; recorded as the next tooling task rather than asserted as complete.

## 5. Where this leaves the retrofit

| | |
|---|---|
| OMITTED and safe | apex ×4 (router), huma `distributeProfit`, `distributeLoss` |
| **OMITTED and unsafe** | **`uniswap_v2.setFeeTo`, `huma.disburse`, `huma.closePool`** |
| FROZEN | huma ×4 lender-gated (and `wbtc.addMintRequest`, outside the ten) |

Three unsafe omissions are real relaxations: each lets the spec take a transition
the contract reserves. They are not blockers for Phase 1 — none is a mandate —
but they are unsoundness of exactly the kind Phase 2 exists to eliminate, and
they should be modelled rather than declared.

## Reproduce

    sed -n '40,48p'   protocol-repos/dex/Uniswap_v2-core/contracts/UniswapV2Factory.sol
    sed -n '183,200p' protocol-repos/yield/00labs_huma-contracts-v2/contracts/liquidity/TrancheVault.sol
    grep -n -A6 "_onlyCreditOrCreditManager" protocol-repos/yield/00labs_huma-contracts-v2/contracts/liquidity/Pool.sol
    grep -n "pure val LENDERS" quint-models-v2/huma.qnt
