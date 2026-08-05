# BASIS — the primitive set `P`

Derived from the 57 typechecked specs in `quint-models/L1..L6`, the six `common.qnt`
factorings, and `research/positive-program/sigma/extraction.json`
(2694 defs, 388 state variables, 32 record types).

---

## 1. Sorts

Quint gives every carrier `int`, `bool`, `str`, or a map/record over these. Those are
not sorts of the algebra. A sort is a class of values closed under the operations that
act on it; two Quint `int`s belong to different sorts when no definition in the corpus
mixes them without an explicit conversion. Six sorts fall out.

| sort | what it holds | witnesses (extraction `statevars`) |
|---|---|---|
| `Q` | **quantity** — owned, conserved, non-negative | `balances`(7), `totalShares`(7), `totalSupply`(6), `shares`(6), `reserve0/1`, `cash`, `collateral`, `syLocked`, `escrowBalance` |
| `Σ` | **scalar** — a ratio against a declared unit | `price`(4), `oraclePrice`(3), `collPrice`, `markPrice`, `liquidityIndex`, `variableBorrowIndex`, `borrowIndex`, `syRate`; units `INDEX_BASE`, `WAD`, `RAY`, `BPS`, `ODDS_BASE` |
| `T` | **time** — ordinal, appears only in differences | `time`(7), `clock`(3), `lastTime`, `lastUpdated`, `updatedAt`, `readyAt`, `startHeight` |
| `Φ` | **phase** — finite, written by the protocol | `ReqStatus`, `ReqPhase`, `FillStatus`, `IntentStatus`, `Side`, `condState`, `OptionPos.phase` |
| `N` | **name** — equality only, never arithmetic, never written | `USERS`(40 specs), `owner`, `maker`, `requester`, `minter`, `srcDomain`, `nonce` |
| `B` | **truth** | 1062 of 2694 defs have `out_type: bool` |

**Six, not nine.** The load-bearing split is `Q`/`Σ`. Both are `int` in every spec, and
`mulDivDown(a,b,d)` takes arguments from both indiscriminately
(`mulDivDown(assets, totalShares, totalAssets)` — all `Q`;
`mulDivDown(scaled, index, INDEX_BASE)` — `Q,Σ,Σ`). They are nevertheless distinct
sorts because **different operations are legal on them**: a `Σ` may be overwritten by
an external writer (`applyPostPrice`, L5/common.qnt:109; `shockPrice` in
L1/morpho_blue.qnt), a `Q` never is. Across all 57 specs no state variable of sort `Q`
is ever assigned a value that is not an arithmetic term over prior `Q`s — even USDT's
off-chain reserve moves only in lockstep (`reserve' = reserve + amount`,
L6/usdt.qnt:51,68). That asymmetry is what stops the basis being degenerate (§5).

`T` is not `Q`: nothing transfers time between names, and every spec advances it
monotonically by fiat. `Φ` is not `N`: `Φ` is written, `N` is a fixed index set.

---

## 2. The primitives

### P1 · `Led` — the ledger

**Carrier** `(N ⇀ Q) × Q` — a balance map and a declared total.
**Operations**
- `credit : N × Q → Led`, `debit : N × Q ⇀ Led` (partial), `move : N × N × Q ⇀ Led`.

**Laws.** With `bal` the map, `sup` the total, and `‖bal‖ = Σ_{n∈N} bal(n)`:
1. *Conservation.* `‖bal‖ = sup` is preserved by all three operations
   (`move` changes neither; `credit`/`debit` change both by the same `q`).
2. *Non-negativity.* `debit(n,q)` and `move(n,n',q)` are defined only when
   `bal(n) ≥ q`; `sup ≥ 0` always.
3. *Additivity.* `credit(n,q₁) ∘ credit(n,q₂) = credit(n,q₁+q₂)`; likewise `debit`.
4. *Locality.* `move(n,n',q)` is the identity on `bal(m)` for `m ∉ {n,n'}`.
5. *No forgery.* `Q` is closed under `Led`: there is no operation `X → Q` for `X ≠ Q`.

**Instantiated by** L6/common.qnt `canTransfer`/`applyTransfer`/`applyMint`/`applyBurn`/
`supplyConserved`; L5/common.qnt `canMintSupply`/`applyMintSupply`/`canBurnSupply`/
`applyBurnSupply`; L4/common.qnt `canMintWrap`/`applyBurnWrap`, `applyEscrowDeposit`/
`applyEscrowWithdraw`, `applyBurnOnSrc`/`applyMintOnDst`; L3/common.qnt `applyDeposit`/
`applyRedeem`; L2/common.qnt `mapSum`/`nonNegMap`.

**Not definable from the others.** It is the only operation whose result sort is `Q` and
whose effect is a state change. Remove it and the reachable `Q`-values of any machine
are exactly the initial ones: `Prop` computes but does not store, `Cmp` returns `B`,
`Post` cannot write `Q` by law 5.

---

### P2 · `Prop` — fused proportion

**Signature** `π : Q × Q × Q → Q`, `π(a,b,c) = ⌊a·b/c⌋` for `c > 0`, `0` otherwise;
dual `π̄(a,b,c) = ⌈a·b/c⌉`. `Q` carries an ordered commutative monoid `(+,0)`;
`Prop` supplies multiplication and floored division.

**Laws.**
1. *Unit.* `π(a,c,c) = a`.
2. *Round-down.* `π(π(a,b,c),c,b) ≤ a` — the round-trip never returns more than it took.
   Stated in code as L5/common.qnt:47 `navRoundTripLeq`.
3. *Dual bound.* `π(a,b,c) ≤ π̄(a,b,c) ≤ π(a,b,c) + 1`.
4. *Sub-additivity.* `π(a₁,b,c) + π(a₂,b,c) ≤ π(a₁+a₂,b,c)` — the dust of a split
   deposit accrues to the pool, never to the depositor.
5. *Monotonicity.* `a ≤ a′ ⟹ π(a,b,c) ≤ π(a′,b,c)`.
6. *Fusion.* `π(a,b,c) ≥ ⌊a·⌊b/c⌋⌋` and the inequality is strict in general — staged
   rounding is not the same operation, which is why every spec uses a fused form.

**Instantiated by** `mulDivDown` (37 specs, L1/L4/L5/L6), `mulDivUp` (20), `divFloor`
(11), `ceilDiv` (L2); and on top of them: L1 `sharesFromAssets`/`assetsFromShares`,
`presentFromScaled`/`scaledFromPresent`, `cpAmountOut`, `seizeCollateral`, `utilization`,
`twoSlopeRate`; L2 `assetsToShares`/`sharesToAssets`/`assetsToSharesCeil`,
`accrueByIndex`, `collateralRatio`; L3 `assetsToShares`/`sharesToAssets`, `syToAsset`/
`assetToSy`, `applyProfit`; L5 `sharesFromNav`/`assetsFromNav`, `utilCollateralReq`;
L6 `betPayout`, `redeemPayout`.

**Not definable from the others.** Without `Prop` the reachable `Q`-values lie in the
ℕ-span of the initial values, since `Led`'s arguments would be sums of existing
balances. `cpAmountOut(r₀,r₁,δ,997,1000)` is not in that span for generic reserves, and
neither is any share count against a non-unit ratio.

---

### P3 · `Cmp` — comparison

**Signature** `≤ : X × X → B` for `X ∈ {Q, Σ, T}`; `= : X × X → B` for `X ∈ {Φ, N}`.
`B` carries its Boolean algebra. `Cmp` is the only operation whose result sort is `B`.

**Laws.** Total order on `Q`, `Σ`, `T`; equivalence on `Φ`, `N`; compatibility with the
monoid, `a ≤ b ⟹ a + c ≤ b + c`; compatibility with `Prop`, law P2.5.

**Instantiated by** — two distinct roles, both in the code.
*Guard mode* (blocks the actor's own transition): L1 `isHealthy`, `cpKHolds` used as a
precondition in L1/uniswap_v2.qnt:83,100; L2 `isHealthy`/`collateralRatio`;
L3 `maintainsMargin`, `canConsume`, `canRedeem`, `headReady`; L4 `canBurnMintSend`,
`canFillOrder`, `clearsAtLimit`, `canDeliverOnce`; L5 `canReserve`, `isMarginSolvent`,
`canWithdrawCash`; L6 `canConsume`, `canBook`, `canSplit`, `canMerge`.
*Enabler mode* (its **negation** opens a transition to a party other than the owner):
L3/common.qnt:120 `canLiquidate = … and not(maintainsMargin(…))`, used at
L3/apex.qnt:142 and L3/gmx.qnt:134; the same shape gates `liquidate` in
L1/morpho_blue.qnt and L2/liquity.qnt.

**Not definable from the others.** No composite of `Led`, `Prop`, `Post` has result sort
`B`. Delete `Cmp` and every guard becomes `true`: `debit` loses partiality, so
non-negativity (P1.2) fails on the first over-withdrawal, and no liquidation is ever
enabled.

---

### P4 · `Post` — exogenous write

**Signature** `post_X : N × X × X → X` for `X ∈ {Σ, Φ, T}`, parameterised by an
authority `n ∈ N` and a relation `R_X ⊆ X × X`; `post_X(n, x, x′)` is defined iff
`n` is the declared writer and `(x,x′) ∈ R_X`.

**Laws.**
1. *`Q`-exclusion.* `post_Q` does not exist. This is the non-degeneracy axiom.
2. *`R`-respect.* Every write lies in `R_X`; `R_T` is `<` (clocks advance),
   `R_Φ` is the acyclic status DAG, `R_Σ` is `Σ_{>0} × Σ_{>0}` (free).
3. *Irreversibility.* When `R_X` is acyclic the sequence of writes is a chain — this is
   the *once* law: `markUsed` (L4/common.qnt:108) grows monotonically, `applyClaim`
   reaches a terminal phase.
4. *Idempotence.* `(x,x) ∈ R_X ⟹ post(n,x,x) = x`.

**Instantiated by** *Σ-writes*: L5 `PostedPrice`/`canPostPrice`/`applyPostPrice`;
`shockPrice` in every L1/L2 lending spec; L3/pendle.qnt `syRate`; L6 UMA `payout`.
*Φ-writes*: L4 `applyApprove`/`applyReject`/`applyCancel`, `applyDelegate`/
`applyExecute`/`applyRevoke`, `applyFill`, `applyCancelOrder`, `canDeliverOnce`/
`markUsed`; L5 `applyRequest`/`applyPrice`/`applyClaim`.
*T-writes*: the `time' = time + 1` tick in all 51 `step` actions.

**Not definable from the others.** `Led` is conservative and `Prop` is a term former;
neither can produce a value on a carrier that has no additive structure (`Φ`) or that is
not derived from prior state (`Σ`). Without `Post`, prices are constant for all time —
no liquidation is ever triggered — and no two-phase request ever advances past `Pending`.

---

## 3. `|P| = 4`, sorts `= 6`

Four operations, six sorts. Four because each of the four independence witnesses above
exhibits a corpus protocol that the remaining three cannot express; six because each sort
is discriminated by an operation legal on it and illegal on another (`Q` vs `Σ` by
`Post`; `T` vs `Q` by `Led`; `Φ` vs `N` by `Post`; `B` by `Cmp`).

---

## 4. What was dropped or merged

**F4 (conservation) is not a primitive; it is a law on `Led`.** Decisive evidence: every
conservation definition in the corpus is `qualifier: val`, result `bool`, and appears
*only* on the right of an invariant declaration — `supplyConserved` and `reserveCovers`
in L6/{usdc,usdt,usdg,pyusd}.qnt:142–199, `shareSolvency` in L3/{yearn,beefy}.qnt:153–156,
`pyBackingHolds` in L3/pendle.qnt:196, `remainingBounded` in L4/{cow,oneinch}.qnt,
`shareConservation` in L1/morpho_blue.qnt. Not one of them is an argument to an update
or a precondition of an action. The single apparent exception, `cpKHolds` at
L1/uniswap_v2.qnt:83, is a *guard* — and a guard is `Cmp`, not a conservation operation.
F4 therefore splits cleanly: its guard occurrences are `Cmp`, its invariant occurrences
are laws P1.1–P1.2, and nothing remains.

**F7 (index accrual) is not a primitive.** It reduces to `Prop` + `Led`, not to F1 + F6.
The conversion half is literally `Prop`: `presentFromScaled(s,i) = mulDivDown(s,i,BASE)`
is `assetsFromShares(s, i, BASE)` with the ratio pair `(i, BASE)` supplied externally.
The accrual half is an unbacked `Led.credit`. The corpus proves the reduction by
exhibiting both implementations of the same observable: Morpho stores no index at all and
accrues by `totalSupplyAssets' = totalSupplyAssets + interest` with
`totalSupplyShares' = totalSupplyShares` (L1/morpho_blue.qnt:168–170), while Aave stores
`liquidityIndex`/`variableBorrowIndex` and calls `accrueIndex` (L1/aave_v3.qnt:196).
INSIGHT-L1 §2 records exactly this: Morpho has "no separate index var; interest mutates
asset totals." The index is `Prop`'s endogenous ratio hoisted into a `Σ` variable.
*One* variant needs more: Pendle's `ratchetIndex(ix,newRate,now) = max(stored,newRate)`
reads an external rate — that is `Post(Σ)` followed by `Cmp`, so it needs F6, i.e. `Post`.

**F1 and F6 merge into `Prop` + `Post`.** F1 is `Prop` with the ratio read off a pair of
`Q` totals; F6 is `Post(Σ)` supplying the same ratio exogenously. They are the same
arithmetic with different provenance for the denominator — compare
`assetsFromShares(s, A, S) = mulDivDown(s,A,S)` (L1) with
`assetsFromNav(s, price, scale) = mulDivDown(s,price,scale)` (L5). No spec distinguishes
them at the point of use.

**F3 (rate-limit envelope) drops.** `currentLimit = min(cap, last + slope·Δt)`
(L3/common.qnt:176, L6/common.qnt:119 — same formula, two lanes) is `Led.credit` of a
`Prop`-computed amount, clamped by a `Cmp` case split.

**F5 (health) becomes `Cmp`,** retaining its two modes (guard, and enabler under
negation). The enabler mode carries the authority content — `liquidate` is
`move(owner, liquidator, q)` guarded by `¬τ`, versus `withdraw` which is
`move(owner, owner, q)` guarded by `τ`. Because `Led` already names both endpoints, no
separate seize primitive is needed.

**F8 (payoff) drops.** `redeemPayout` and `betPayout` are `Prop` against a `Post`ed
scalar. `europeanPayoff`'s kink is a two-way `Cmp` case split.

**F2 (deferred claim) drops** to `Post(Φ)` for the status machine, `Cmp` on `T` for the
gate (`headReady`), and `Led` for the escrowed amount.

**One derived operation deserves a name** even though it is eliminable: truncated
difference `a ∸ b = max(0, a−b)`. It is the single most reused *derived* term —
`applyLoss` junior-first absorption, `europeanPayoff`, `currentLimit`'s cap,
`applyPayClaim`'s `min(balance, amount)`, `ratchetIndex`'s `max`, `seizeCollateral`'s
clamp. Limited liability, tranche subordination, option payoff and rate-limit saturation
are the same operation. It is not primitive because every occurrence is a finite case
split on `Cmp`, which the composition operation supplies for free.

---

## 5. Composition

A **construction** is `M = (S, s₀, →)` where `S` is a finite product of carriers of the
six sorts, `s₀ ∈ S`, and `→` is a finite set of **guarded updates** `g ⊳ u`: `g` a
`B`-term over `Cmp`, `u` a simultaneous assignment whose right-hand sides are terms over
`Led`, `Prop`, `Post`. This is exactly the corpus shape: `all { guard, assignments }`,
with every variable assigned including the untouched ones (see the ten echoed
assignments in `mintPY`, L3/pendle.qnt:60–74).

Given `M₁`, `M₂` and a **coupling** `κ`, a partial injection between their carriers that
identifies only carriers of the same sort:

> `M₁ ⋈_κ M₂ = ( (S₁ × S₂)/κ , (s₀¹, s₀²)/κ , →₁ ⊎ →₂ ⊎ →_κ )`

where `→₁`, `→₂` are lifted by identity on the other's private carriers, and
`→_κ = { (g₁ ∧ g₂) ⊳ (u₁ ∥ u₂) : u₁, u₂ agree on κ-shared carriers }` is the set of
**fused** transitions. The `any { … }` of all 51 `step` actions is `⊎`; shared `var`s
are `κ`; fused transitions are what makes Convex-over-Curve or Pendle-over-SY a single
atomic action rather than two.

`⋈` adds no expressive power on its own: a construction over the empty basis has no
transitions, and `⋈` of two such is still empty. Closure under `⋈` therefore means
exactly "reachable by fusing and interleaving the four primitives".

**Refutation condition.** Every machine in the closure satisfies, by induction on `→`:
(i) `‖bal‖ = sup` for each `Led` factor except across declared mint/burn;
(ii) `T` is monotone; (iii) rounding is never in the caller's favour (P2.2, P2.4);
(iv) no `Q` changes except by `Led`. Exhibit a DeFi application requiring the failure of
any one of these — a quantity that moves without a debit anywhere, or a conversion whose
round trip returns strictly more than it took — and completeness is refuted.
