# P2 REVIEW — the routes by which this fails a second time

The plan is not sound as written. Its guards cover the *ordering* class of deletion
thoroughly and the *arithmetic* and *missing-state* classes barely at all — which is five
to six of the ten. Ranked changes below; charge 6 verification at the end.

---

## 1. (Charge 1) The fourth trap: **F3 parsimony is a deletion engine**

`P2-FIDELITY §3 step 3` instructs the worker to take each spec-side distinction `d`,
collapse it, and **delete it** if the collapsed spec still kills every mutant and preserves
every declared invariant — iterated to a fixed point. That has the exact shape of the other
three: the check passes because the stressing states were removed, except here the plan
*mandates* the removal, and does it after F2 has already fixed which states matter.

Two consequences. (i) The stopping condition is `𝔐`. A worker with a thin contrast set is
now under written instruction to strip the spec down to the skeleton that discriminates
against it. `Trove.rate` was deleted by accident in v1; F3 deletes its analogues on
purpose. (ii) It makes the headline measurement circular. If every spec is minimised to be
the coarsest thing separating a hand-written rival set, then "does `P` generate the corpus"
measures "does `P` cover the union of ten contrast sets". The corpus stops being an
independent witness and the 743/820-style number becomes a number about `𝔐`.

Worse, §3 step 3 **contradicts §2**. The §2 droppability rule is contract-facing — keep `f`
if any guard on a state-changing path reads it. F3 is `𝔐`-facing. They disagree on exactly
the features that matter.

**Fix:** delete F3 as a rewrite instruction. Keep parsimony as §2's rule only: a definition
may be dropped iff no contract guard reads it *and* no rival needs it. Never delete a
definition that carries a `contract:line` citation. Parsimony is a review lens, not a
minimiser.

Two further instances of the same shape, cheaper to fix:

**Dead actions and dead branches.** `quint run` samples `any { … }`; a disjunct whose guard
is never satisfiable is silently skipped and every invariant over it is vacuously true.
This is live in the corpus already: `apex.qnt:184` has a `lpShares == 0` bootstrap branch,
and `init` sets `lpShares' = 100` with no `burn` anywhere, so the branch is unreachable —
a re-spec could put an exact `isqrtFloor` there and satisfy any shape-level invariant while
executing it zero times. The plan's T3 requires one witness per protocol for the *named*
mechanism; every other action ships unaudited for enabledness. Require `wit_fired_<action>`
for every action, all violated.

**T2 is evidence of nothing.** `quint run --max-samples=500` finding no violation is a
random walk failing to hit a state. Violations found by sampling are sound; non-violations
are not. Exactly one of the three acceptance parts (the witness, which must be violated)
carries information. Say so in the plan so nobody reads a green T2 as a result.

---

## 2. (Charge 3) The acceptance test is cheatable, and eight of ten are cheatable the same way

Take `derive`. Define `scenarioMtM(p, s) = p.qty * MAINT_PER_SHORT * s.factor` — the deleted
constant, decorated with a per-scenario multiplier — and `margin = SCENARIOS.fold(MAX, (a,s)
=> min(a, scenarioMtM(p,s)))`. Then:

- T1 typechecks.
- T2 conservation runs clean (nothing moved).
- `inv_marginIsMin` (`forall s. mtm ≥ margin` and `exists s. mtm == margin`) holds **by
  construction** — it is a tautology about any fold-min, true for *any* `scenarioMtM`,
  including one that ignores the portfolio entirely.
- `wit_nonTrivialArgmin` ("worstScenario is always index 0") is violated as soon as two
  scenarios have different `factor` and longs and shorts carry opposite signs — three lines.
- The mutation half also passes: restoring `margin = qty*15` breaks `inv_marginIsMin`.

So all three pass and the actual mechanism — *what is being minimised*, i.e. the shock
applied to the portfolio — is still deleted. The argmin has been restored as a shape and
not as a function.

This generalises because `T3`'s `inv_<mechanism>` is a property of the *shape* of the
definition, not of its *value*. `inv_kMonotone` (apex) is satisfied by a fee of 1 part in
10⁶, or by `+1`. `wit_haircut` (compound) is satisfied by a haircut of one unit.
`inv_impactSign` (gmx) is satisfied by `impactUsd = ±1`. `inv_seniorRatio` (huma) is
satisfied by refusing all junior redemptions. Only `uniswap_v2` (`r² ≤ n < (r+1)²` pins
`isqrt` uniquely) and `curve` (residual ≤ 1 pins `D` uniquely) are safe.

**Fix — the single highest-value change: add T0, the conformance vector.** For every one of
the ten, pin ≥3 `(input, output)` pairs read off the contract source and assert them as a
`pure val` invariant in the spec, at least one outside the near-symmetric regime. E.g.
`apexAmountOut(10000, 1000, 100) == 999*1000/(10000*1000 + 999*100)` evaluated exactly;
`comet.absorbCredit(1000, 5, liqFactor)` against `mulFactor`; `humaMinJunior(700, 4) == 175`.
`pure def`s cost zero state. A conformance vector is falsified by every decoration and by
every "a fee, but not the fee". It converts eight of ten acceptance tests from shape to
identity.

---

## 3. (Charge 5) The driver convention covers 3 of 10

Tested against `P2-SCOPE §1`: convention 6 catches `liquity` (5), `derive` (9) — the
`nondet s = SCENARIOS.oneOf()` temptation — and `polymarket` (10), where both the maker
order and the crossing price are protocol-derived. It partially catches `huma` (8) if the
worker nondets which tranche is processed. It is **silent** on 1, 2, 3, 4, 6, 7: sqrt,
Newton, the absorb haircut and missing `buyCollateral` inventory, the bad-debt no-op, the
missing fee, and the absent impact function. None of these is a selection.

Note the alignment: convention 6 guards W3 and W4's territory and says nothing to W1
(`curve`, `apex`) or W2 (`compound_v3`, `morpho_blue`, `gmx`) — five protocols with no
convention-level guard and, per §2 above, decorative T3s. That is the plan's structural
hole.

**Fix — two more conventions, one per uncovered class:**

- **6b, arithmetic class:** every arithmetic mechanism is a named `pure def` pinned by a T0
  conformance vector. (Above.)
- **6c, missing-state/action class:** a written **coverage table** — every external
  state-changing function of the cited contract is either an action or a line under
  `ABSTRACTED:` with a reason; every contract storage slot read by a `require` is a `var` or
  an `ABSTRACTED:` line. This is derivable from the ABI and would have caught compound's
  absent `buyCollateral`, apex's absent `closePosition`/`burn`, and polymarket's absent
  dispute path mechanically.
- **Regression signal 8, missing from §6:** *the no-op branch* — any action branch in which
  every primed variable equals its unprimed counterpart. This is the exact form of the worst
  deletion in the corpus (`morpho_blue.qnt:156-159`) and of `apex.qnt:145-147`, and §6 does
  not list it. It is a one-line grep.

---

## 4. (Charge 2) The contrast-set mitigation is not sufficient

Admissibility ("deployed protocol or obvious lazy alternative") is satisfiable by rivals
that are *far* from `M₀`, and distant rivals are trivially killed. Curve's own blend kills
`M₁ = constant-sum` and `M₂ = constant-product` at 190/10 — so an `𝔐` of the two obvious
AMMs certifies the abstraction the programme exists to reject. What kills the blend is `M₃`
= the blend, i.e. the rival that must be present is *the thing the worker is tempted to
write*. The document knows this but offers it as one of two options rather than as a
requirement.

Second gap: `𝔐` is all substitutions, and the liquity failure was a *relaxation*. Nothing
in the admissibility rule forces the over-approximation direction into the set.

**Fix — three mandatory members in every `𝔐`, then the reviewer's job becomes checkable:**

1. **The v1 shortcut body itself.** Non-negotiable, and free.
2. **`M_chaos`** — the mechanism site replaced by nondeterministic choice over the type.
   This is the one mutant that catches "the spec takes as a parameter what the contract
   computes", uniformly, for all ten.
3. **A near neighbour**: a rival that agrees with `M₀` on ≥90% of `𝒟`. Measurable, and it
   is the operational content of "hard to kill". Sourcing rule that makes thinness visible:
   near neighbours are drawn from the sibling protocols already in the 60-protocol corpus,
   so `𝔐` is *derived* rather than invented and "you used 2 of the 5 siblings" is a visible
   defect. Pre-review of `𝔐` alone, against nothing, is not.

---

## 5. (Charge 4) i64 breaks three of the ten as specified

Overflow in Quint is loud (`QNT601`), so it does not corrupt results. The damage is
second-order and the plan does not name it: **the worker escapes QNT601 by shrinking the
domain, and a shrunk domain violates F4.** That is precisely how Curve ended up at
`bal0 = bal1 = 100`. Directive: any domain reduction taken to escape QNT601 must be
re-checked against F4 and recorded in the header.

Concrete breakages:

- **`morpho_blue` T3 item 4 cannot run.** It asks to evaluate `WAD²/(WAD − CURSOR·(WAD−LLTV)/WAD)`;
  `WAD² = 10³⁶` against an i64 ceiling of ~9.2×10¹⁸. Fix the scale up front — bps
  (`SCALE = 10⁴`, `SCALE² = 10⁸`) reproduces the formula exactly (LLTV 8600, cursor 3000 →
  9580 → 1.0438, under `MAX_LIF` 1.15). If the scale is not fixed in the plan the worker
  discovers this mid-flight and reaches for a literal — the original defect.
- **`compound_v3`** chains two 1e18 factors (`mulPrice` then `mulFactor`). Same fix, same
  reason.
- **`gmx` is the real casualty.** USD is 30-decimal; even linearised, `diffUsd` alone is
  1e30. The plan permits dropping `exponent ≠ 1` — but convexity *is* the mechanism: with
  linear impact, splitting an order is exactly free and the impact pool's economics vanish.
  i64 does not force linearisation; a descaled domain (`d ≤ 10⁴ ⇒ d² = 10⁸`) hosts exponent
  2 comfortably. **Revoke the permission to linearise gmx.**
- **`curve`:** convention 8 ("integer ranges ≤ 200") and F4 are in direct tension — the
  separating region starts near 190/10 and non-convergence near ratio 999. F4 must win, and
  the header must state the reachable imbalance, not just the nondet input range.
- Also: descaling changes the *semantics of the tolerance*. Curve's `|D − D_prev| ≤ 1` is
  1 wei at WAD scale and one whole token unscaled, so the break fires far earlier. That is
  a real relaxation and belongs in `ABSTRACTED:`.

---

## 6. (Charge 6) `apex` — all three claims confirmed; three further losses

**(a) fee-free `swapOut`, `apex.qnt:47-49` — CONFIRMED.** `Amm._getAmountOut:467-478` is
`amountIn·999·reserveOut / (reserveIn·1000 + amountIn·999)`; the spec is `y·dx/(x+dx)`, the
exact zero-fee form. Not a query-only path: `Margin._addPositionWithAmm:399-409` and
`_minusPositionWithAmm:414-424` both call `IAmm.swap` → `_estimateSwap:440` → `_getAmountOut`.
Additional loss the scope row misses: `_getAmountIn:481-491` rounds *up* (`+1`), and §2
declares rounding direction never-droppable — and there is **no close path in the spec at
all** (`grep` finds no `closePos`, no `burn`, no `removeLiquidity`), so the exit side of the
fee is not merely fee-free, it is absent.

**(b) linearised LP mint, `apex.qnt:183-185` — CONFIRMED, and the branch is dead.**
`Amm.mint:91-96`: `liquidity = Math.sqrt(baseAmount·quoteAmount) − MINIMUM_LIQUIDITY` plus
`_mint(address(0), MINIMUM_LIQUIDITY)`. The spec is `if (lpShares == 0) baseIn else
baseIn·lpShares/reserveBase`. Two mechanisms lost, not one: the `√` bootstrap **and the
permanent one-way lock**, which is itself one of the twelve unmatched candidate primitives
in `GOAL.md` ("permanent one-way lock (L3)") — deleted from the L3 spec that instantiates
it. And `init` sets `lpShares' = 100` with no burn, so `lpShares == 0` is unreachable: the
branch cannot execute. Restoring `isqrtFloor` there without also making the branch reachable
would pass every acceptance test as written. Third omission: apex has the same
`kLast`/`_mintFee` sqrt-growth mechanism as Uniswap (`Amm.sol:35,119,369-374,497`), scoped
for row 1 and unscoped for row 6.

**(c) reserve-untouched `liquidate`, `apex.qnt:138-153` — CONFIRMED, and understated.**
`Margin.liquidate:253-299` → `_executeSettle:305-360` calls `IAmm.forceSwap` in every branch
except `isIndexPrice ∧ remain ≥ 0 ∧ treasury ≠ 0`; `Amm.forceSwap:239-265` writes reserves
through `_update` and refreshes `kLast`. Also `bonus` is paid out via `_withdraw(trader,to,bonus)`
at `:294`, so `marginPool' = marginPool` is wrong even on the pure-oracle path. The bigger
miss: the **trigger** is deleted too. `_calDebtRatio:608-636` prices the position by
simulating its close through `getMarkPriceAcc(amm, beta, quoteAmount, ·)` — an AMM-depth-
and size-dependent price with its own slippage guard (`PriceOracle.sol:280`) — so a large
position is liquidatable at a spot price where a small one is not. The spec uses an
exogenous scalar `markPrice` with flat `MAINT_BPS`, making liquidatability size-independent.
The scope row names the settlement half only; `inv_kMonotone` + `wit_ammClose` as written
do not reach the trigger. Add a witness that two positions of different size at the same
`markPrice` differ in liquidatability. Finally, `totalQuoteLong`/`totalQuoteShort` (open
interest, maintained at `:286-290`) have no spec counterpart, and `openShortPos:123` records
`posSize` in base units while `openLongPos` records it in quote — `common.qnt:120`
`canLiquidate` then applies one formula to both.
