# P2 — carry-forwards 1 and 2, closed

Binding on the pilot and W1–W4. Where this conflicts with `P2-SCOPE.md` §3 convention 8 or
`P2-CONTRACT.md` §C, this wins.

---

## CF1 — convention 8 replaced

**Diagnosis.** Convention 8 wrote one number, `≤200`, for two unrelated things: how *large*
values may be, and how *many* branches a step may have. Runtime is set by branching, not by
magnitude — a `nondet` over 8 enumerated values costs 8 branches whether the values are
`1..8` or `10^3..10^7`. Capping magnitude bought no speed and made six of the ten protocols'
mechanisms literally unreachable.

**Convention 8 (revised).** `BOUNDS:` is per protocol and states three clauses separately.

- **8a Branching.** Every `nondet` ranges over an explicitly enumerated set of ≤8 values (or
  an interval of ≤8 integers); ≤3 users; ≤5 list entries. This clause alone bounds runtime.
- **8b Magnitude.** The peak intermediate is stated and is `< 9.22×10^18`. Magnitude is
  otherwise unconstrained.
- **8c Constant-crossing (new, and what CF1 found).** For every protocol constant `C` the
  spec names, the declared domain must contain values on **both sides** of `C` at every site
  where `C` appears in a comparison, a subtraction, or a `min`/`max`. A constant that the
  domain can never cross is a deleted branch wearing a `pure val`.

**What the old cap did.** Applying 8c retroactively to `≤200`:

| protocol | blocking constant | under `≤200` | verdict |
|---|---|---|---|
| `uniswap_v2` | `MINIMUM_LIQUIDITY = 1000` | `isqrt(200·200) − 1000 = −800` | **dead** (underflow) |
| `apex` | `MINIMUM_LIQUIDITY = 1000` (`Amm.sol:96`) | same | **dead** |
| `gmx` | `FLOAT_PRECISION` cliff (`Precision.sol:93`) | `d ≤ 200 < 10^4` ⇒ impact `≡ 0` | **dead** |
| `liquity` | `MIN_DEBT = 2000` | no trove can be opened | **dead** |
| `morpho_blue` | `VIRTUAL_SHARES = 10^6` | a share balance cannot be represented | **dead** |
| `derive` | `spot = 10^4`, shocks `80…120 %` | spot unrepresentable | **dead** |
| `curve` | — | converges everywhere; witness absent (CF3) | degraded |
| `compound_v3` | `liquidationFactor` | residue 11 instead of 53 | degraded |
| `huma` | ratio `4` | binds at `(200, 50)` | survives |
| `polymarket` | — | — | survives |

Six dead, two degraded, two survive. `P2-CONTRACT.md` §C already fixed four of these
piecemeal; 8c is the general statement.

### The pilot's domain

`UniswapV2Pair.mint` first branch: `liquidity = sqrt(a0·a1) − 1000`, with `1000` minted to
`address(0)` — permanent — and `require(liquidity > 0)`.

- Mint amounts `∈ {1000, 2000, 4000, 8000, 9000, 12000, 20000}` (7 values, clause 8a).
- `(1000, 1000)`: `isqrt(10^6) − 1000 = 0` ⇒ **the revert branch**, `INSUFFICIENT_LIQUIDITY_MINTED`.
- `(4000, 9000)`: `isqrt(36×10^6) − 1000 = 6000 − 1000 = 5000` ⇒ minter LP **5000 > 0**,
  1000 locked, `totalSupply = 6000`. Lock reachable *and* exercised. This is the `T0-LIVE:` vector.
- `(2000, 8000)`: `4000 − 1000 = 3000`, v1's `min` gives `2000`. Discrimination witness inside.
- Peak: reserves `≤ 40000`; `a0·a1 ≤ 4×10^8`; `isqrtBits(n,16)` candidate² `≤ 4.30×10^9`;
  swap `in·997·rOut ≤ 20000·997·40000 = 7.98×10^11`; `mintFee` numerator
  `ts·(rootK−rootKLast) ≤ 1.6×10^9`. **Peak `8.0×10^11`.**
- Fee visibility (8c on `997/1000`): at `(in=100, rIn=1000, rOut=1000)` both forms return
  `90` — invisible. At `(1000, 1000, 1000)`: `499` vs `500` — visible. Swap `amountIn` must
  reach `reserveIn`; `∈ {100, 500, 1000, 5000, 20000}` spans both sides.

### The ten domains

| # | protocol | domain (8a/8b) | peak intermediate | witness hosted | 8c constants crossed |
|---|---|---|---|---|---|
| 1 | `uniswap_v2` | amounts `{1000…20000}`, reserves ≤ 4×10^4, `in {100…20000}` | `8.0×10^11` | `geometricMint(4000,9000)=5000 ≠ 4000` | `MIN_LIQ` (0 / 5000), fee (90=90 / 499≠500) |
| 2 | `curve` | balances `{1, 10, 50, 100, 190, 199, 10^5, 10^6}`, `AMP=100`, `N=2`, `K=8` | `5.00×10^17` | non-convergence at `(10^6,1)` **and** `(10^5,1)` | break tol. `±1`; `Ann=amp·N=200` |
| 3 | `compound_v3` | `SCALE=10^4`, balances ≤ 2000, prices ≤ 10·SCALE | `2.0×10^12` | 53-unit store-front residue at seize 1000 | `liquidationFactor 9000`, `storeFront 5000` |
| 4 | `morpho_blue` | `SCALE=10^4`, assets ≤ 2000, shares ≤ 2×10^9, `VIRTUAL_SHARES=10^6` | `4.0×10^12` | cross-user `totalSupplyAssets 2000→1800`, `≥2` users | `MAX_LIF` — **see flag M** |
| 5 | `liquity` | debts `{2000, 3000, 6000}`, amounts `{1000…12000}`, ≤5 troves, price 1 | `1.2×10^4` | `touched = 3` at amount 6000 | `MIN_DEBT = 2000` — **see flag L** |
| 6 | `apex` | **one** range: amounts/reserves `{1000…40000}`, `in {100…20000}` | `8.0×10^11` | `ammOut(4000,4000,9000)=4497 ≠ 4500` | `MIN_LIQ` (bootstrap), `999/1000` |
| 7 | `gmx` | `SCALE=10^4`, `d ∈ {0, 5000, 10^4, 2×10^4, 3×10^4, 4×10^4}`, `impactFactor ≤ 100`, exponent 2 | `1.6×10^9` | `sameSide(30000,20000)=+250` vs `(20000,10000)=+150` | cliff at `d = SCALE` (0 / 50) |
| 8 | `huma` | `SCALE=10^4`, senior ≤ 800, junior ≤ 300, ratio 4 unscaled | `6.0×10^6` | `maxRedeemable(700,200)=25`; `(800,200)=0` early return | ratio 4: `3.5` / `4.0` / `>4` |
| 9 | `derive` | `UNIT=100`, spot `=perp= 10^4`, base `[0,3]·UNIT`, perp `[−3,3]·UNIT`, 5 shocks | `3.0×10^6` | `worstScenario = 4` then `= 0` | shocks straddle `100` |
| 10 | `polymarket` | order amounts ≤ 200, `makerAmount ≥ 10`, ≥2 makers per action | `4.0×10^4` | `totalMintAmount = 32` in one match | match-type on side agreement |

**Curve, in detail (this is the one that moves).** Faithful `get_D` replayed in Python with
`Ann = amp·N_COINS` (reproduces every `P2-CONTRACT` §A.2 vector exactly: `198, 196, 170`,
iters `1,1,2,2,2`). At extreme imbalance `y=1` the Newton numerator is `≈ X³/2`:

| `X` at `(X, 1)` | peak intermediate | converges at K=8 | i64 |
|---|---|---|---|
| `10^5` | `5.02×10^14` | **no** | ok |
| `10^6` | `5.00×10^17` | **no** | ok (18× margin) |
| `2×10^6` | `4.00×10^18` | no | ok (2.3× margin) |
| `10^7` | `5.00×10^20` | no | **OVERFLOW** |

i64 ceiling is `X ≤ 2,642,245`. **Finding: the ROADMAP's own CF3 resolution — "adopt
10^5..10^7, it stays inside i64 because `10^7·10^7 = 10^14`" — is wrong.** That check bounded
`x·y` and not the Newton intermediate, which is cubic. `10^7` overflows the default backend.
Corrected cap: **`10^6`**, which hosts the divergence witness with 18× headroom. Side benefit:
at balances `10^6` the `≤1` break tolerance is `10^-6` relative rather than one whole token,
so raising the cap makes the tolerance *more* faithful, not less.

### Three protocols where the conditions collide — flagged, not solved

- **Flag L — `liquity`.** `MIN_DEBT = 2000` is a protocol constant of the `MINIMUM_LIQUIDITY`
  class. `P2-CONTRACT` §C row 5 (debts ≤ 300, amounts ≤ 600) is a **second live instance of
  CF1**: no trove can be opened. Hosting it costs nothing (peak `1.2×10^4`), so host it.
  But `MIN_DEBT` exists to create *zombie troves* when a redemption leaves debt below it, and
  `P2-SCOPE` row 5 lists the zombie path as droppable. Executor decision: host `MIN_DEBT`,
  and add `ABSTRACTED: zombie trove — a redemption may leave debt < MIN_DEBT; the trove stays
  in the sorted list.` Dropping the constant instead is not permitted (8c).
- **Flag M — `morpho_blue`.** `MAX_LIF = 11500` binds only at `lltv = 5000` and not at
  `8600`, so 8c requires `lltv` to take ≥2 values straddling the cap. `P2-SCOPE` row 4 drops
  multi-market. Executor decision: make `LLTV` a `nondet`-at-`init` parameter over
  `{5000, 7700, 8600, 9000}` — one market, four instances. This is a scope amendment, not a
  domain choice, and it is the only way to reach the other side of the `min`.
- **Flag A — `apex`.** `P2-CONTRACT` §C row 6 declares **two** ranges (swap reserves
  `[100,2000]`, mint amounts `[1000,20000]`). They are mutually unreachable: once the
  `sqrt` bootstrap runs, reserves are ≥ 4000 and never re-enter `[100,2000]`, while the fee
  witness needs `amountIn ≳ reserveIn`, i.e. ≈ 4000, not ≤ 200. Collapsed to one range above
  — which is correct, since `apex` is the same CPMM with the same `MINIMUM_LIQUIDITY` as the
  pilot.

**Verdict CF1 — CLOSED.** Convention 8 split into 8a/8b/8c; ten domains re-derived; pilot
lock reachable and exercised at `(4000, 9000)`. Three collisions flagged with decisions.

---

## CF2 — convention 6g, dependency parity

**The rule.** For every quantity `q` the spec supplies by `nondet` or by a literal, identify
the contract expression `Q` that produces the same quantity in the `SOURCE:`-cited function.
Compute `foot(Q)` = the set of **contract storage variables** `Q`'s value depends on,
transitively through internal calls. Then:

> **6g.** `q` must read every member of `foot(Q)` that the spec models as a `var`. A member of
> `foot(Q)` that the spec models but `q` does not read is a **dropped dependency** and a
> defect. Declaration: a header `INPUTS:` table, one row per `nondet` and per substituted
> literal — `name | contract expression | file:line | foot(Q) | spec vars read`.

Note what `foot(Q)` measures: *storage*, not "outside-ness". An oracle price's contract
expression is `IOracle(...).price()` — an external call, `foot = ∅`. A `nondet` price has
spec footprint `∅` too. **Parity holds; oracles are not banned.** Apex's `markPrice` traces
`_calDebtRatio → getMarkPriceAcc(amm, β, quoteSize, baseSize) → Amm.getReserves()`, so
`foot = {reserveBase, reserveQuote, position size}` — all modelled — against a `nondet`
footprint of `∅`. Three dropped dependencies. The decisive property: **inside apex, 6g
permits the oracle price and forbids the mark price**, which is exactly the distinction
convention 6 could not make.

### Tested against all ten deletions

| # | deletion | 6g | why |
|---|---|---|---|
| 1 | `uniswap_v2` `geometricMint → min` | — | `foot = {a0,a1}` both sides. Parity. (6b) |
| 2 | `curve` `approxD` blend | — | `foot = {x,y}` both sides. Parity. (6b/6f) |
| 3 | `compound_v3` no haircut | **catches** | drops `liquidationFactor` from the credit. Already 6b+6c |
| 4 | `morpho_blue` bad-debt no-op | — | quantity absent, not demoted. (6d) |
| 5 | `liquity` trove as parameter | **catches** | `getLast()` `foot = {troves, rates}`; `nondet u` reads none. Already conv. 6 |
| 6 | **`apex` liquidation trigger (H1)** | **CATCHES — uniquely** | drops `{reserveBase, reserveQuote, size}`. No other convention reaches it |
| 7 | `gmx` absent impact | — | no spec quantity to compare. (6e / lint D2) |
| 8 | `huma` uncapped junior | **catches** | `minJuniorAmount` `foot = {seniorAssets}`; `min(req,cash)` reads neither. Already 6b+6f |
| 9 | `derive` `MAINT_PER_SHORT = 15` | **catches** | `minSPAN` `foot = {base, perp, spot}`; `qty·15` reads only `qty`. Already 6+6b |
| 10 | `polymarket` exogenous price | — | order `(makerAmount, takerAmount)` is calldata, `foot = ∅`. Parity holds; the deletion is structural. (6+6b) |

**Uniquely catches 1 (apex H1 — the target). Independently re-catches 4 already covered
(3, 5, 8, 9). Silent on 5. Zero false positives.** The re-catches are the evidence it is the
right generalisation: conventions 6, 6b and 6f were each catching a *different instance of
one shape*, and 6g names the shape. Convention 6 becomes 6g's identity-typed special case.

Interaction with Flag M: once `LLTV` is a modelled `nondet`, `LIQ_INCENTIVE_BPS = 11500` also
becomes a 6g violation (`foot = {lltv}`, literal reads nothing) rather than only a 6b one.

### Lintability — half mechanisable

A linter cannot read Solidity, so it cannot compute `foot(Q)`. It *can* enforce that the
worker declared it and that the spec honours the declaration. Two implementable detectors:

- **D5a — undeclared input.** Parse every `nondet <n> = <e>` and every action parameter fed by
  one; parse the header `INPUTS:` table. Finding if a `nondet` name has no row, or a row's
  `foot(Q)` column is non-empty (a nondet with a declared non-empty footprint is a defect by
  construction). Pure syntax; no semantics needed.
- **D5b — footprint under-read.** For each registry `pure def f` (convention 3) with a header
  `FOOTPRINT: f = {v1,…}` line: collect the identifiers occurring in `f`'s body plus the
  `var`s appearing in the argument expressions at every call site of `f`. Finding if
  `declared \ read ≠ ∅`. Catches "you declared mark price depends on the reserves and your
  `pure def` body never mentions `reserveBase`."

**Not mechanisable: the classification itself.** Any declaration-free heuristic
(e.g. flag `nondet` names matching `/price|rate|mark|factor/` inside actions that touch
reserves) fires on `compound_v3`'s absorb, `morpho`'s liquidate and `gmx`'s markPrice, all of
which are genuine oracle reads. Separating a pool price from an oracle price *requires reading
the contract*. Reviewer checklist, three questions per row of `INPUTS:`:

1. Name the contract expression and its `file:line`. If you cannot, the row fails.
2. Does evaluating it touch any `SLOAD` of a cited contract, directly or through an internal
   call? External-call returns, calldata and block context are `∅`.
3. Would its value change if **only the caller's own position size** changed, all external
   inputs fixed? A yes with a `nondet` is the H1 defect.

Retain H1's runtime obligation `wit_sizeDependentLiquidation` (two positions of different size
at the same `markPrice` differ in liquidatability) — 6g is the static half, the witness is the
dynamic half, and the witness is what proves the restored dependency is *live*.

**Verdict CF2 — CLOSED as a convention (6g stated, ten-way tested, no false positives);
OPEN as a linter until D5a and D5b are implemented in `respec_lint.py`.**

**Verdict CF3 — CLOSED with an amendment: its own prescribed domain (`10^5..10^7`) overflows
i64 at the divergence points; corrected cap is `10^6`.**
