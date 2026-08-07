# Non-degeneracy, Independence, and the Failure List

Sources: GOAL.md (the eight families); `consolidated/STRUCTURE-DEFINITIONS.md`
(Definitions 1–8, the signature `Σ = (E, C, λ, ar, H, ℓ, Π)`); the 57 specs in
`quint-models/L*/`; `sigma/extraction.json` (2694 defs, 388 state vars).

---

## 1. Non-degeneracy

**The failure mode to exclude.** If a family may be instantiated at an *arbitrary*
function, the basis is Post's `{⊤}`. Two slots are exposed. F8 `(P) → (A)`, read as
"some payoff", makes `F1 ⊗ F8` — state plus arbitrary update — generate every state
machine. F5 `(K, K*, P) → (V)`, read as "some predicate", supplies arbitrary guards;
arbitrary guard plus arbitrary update *is* a universal machine.

**Definition (ND).** A basis `P` is *non-degenerate* iff:

- **ND1 (first-order).** No family takes a function, predicate, or operator as an
  argument. Every parameter is a scalar of a colour in `C`.
- **ND2 (closed-form arithmetic).** Every value term lies in the *mul-div-floor
  fragment* `MDF`: integers closed under `+ − · ⌊/⌋ min max` and bounded
  conditionals. No recursion, no unbounded iteration, no fixpoint, no root
  extraction.
- **ND3 (half-space verdicts).** Every term of colour `V` is a single comparison
  `t₁ ≥ t₂` with `t₁, t₂ ∈ MDF` — a half-space test, not an arbitrary predicate.
- **ND4 (no fresh state).** `⊗` (Def. 8) adds no state variable and no guard beyond
  the ports of its operands. State of `X ⊗ Y` is the disjoint union.

ND2–ND4 are what make the class generated a *proper* subclass of state machines,
hence what makes the theorem refutable at all.

**Check against the eight-family basis.**

- **ND1 — holds, measured.** Of 2694 extracted definitions, **zero** have a
  higher-order input type. The corpus is first-order throughout. F8's actual
  instances are concrete: `europeanPayoff = max(S−K,0)` / `max(K−S,0)`
  (`L5/common.qnt:196–207`), `redeemPayout = yes·p_yes + no·p_no`
  (`L6/common.qnt:181`), `betPayout = ⌊amt·odds/10⁴⌋`. F8 is a *finite* set of
  piecewise-linear maps, not a slot.
- **ND3 — holds, by inspection of every F5 instance.** `isHealthy: c·ltvBps ≥ d·10⁴`
  (L1); `collateralRatio ≥ threshold` (L2); `maintainsMargin: equity·10⁴ ≥ size·price·maint`
  (L3); `isMarginSolvent: cash + mtm ≥ maintenance` (L5); `canReserve`, `canBook`
  (L5, L6). All are linear inequalities over value aggregates with non-negative
  integer coefficients. F5 is a half-space family.
- **ND2 — FAILS, twice, and the spec authors recorded both failures.**
  `L1/common.qnt:78–92` `geometricMint` cannot compute Uniswap V2's initial mint
  `√(a₀a₁)`: the comment says *"integer sqrt via linear search bound … Unrolled for
  quint purity without loops"* and the body returns `min(a₀,a₁)`. `L1/curve.qnt:22–30`
  `approxD` cannot compute Curve's StableSwap invariant: *"Newton's method collapsed
  to one stable step … Weighted blend."* Both are substitutions, not models.

**Verdict.** The basis is **not degenerate** — ND1 and ND3 hold on the corpus and `MDF`
is a strictly proper fragment, so the theorem has content. But the same fact already
refutes it as stated: `√` and Newton iteration lie outside `MDF`, so Uniswap V2's first
mint and Curve's invariant are **not generated**. Either `MDF` is widened by an explicit
root/fixpoint family, or these are two exhibited counterexamples — flagged in the
corpus's own comments.

**PO-IND-1.** Decide whether `√` and one-step Newton are *derived* in `MDF` up to the
integer rounding tolerance the protocols themselves accept, or genuinely outside it.
If outside, `P` gains a ninth family and the arity table gains a row.

---

## 2. Independence

### 2.1 F7 (index accrual) from F1 (pro-rata shares) and F6 (valuation source)?

**No.** The suspicion is that an index is a share price observed over time. It is not,
and the reason is that F1 has no share price to observe.

**Lemma 1 (F1 is ratio-invariant).** Let `ρ = totalAssets / totalShares`. Over exact
rationals, every F1 operation preserves `ρ`.
*Proof.* `applyDeposit(v,a)`: `A′ = A + a`, `S′ = S + aS/A`, so
`A′/S′ = (A+a) / (S(A+a)/A) = A/S`. `applyRedeem(v,s)`: `A′ = A − sA/S`, `S′ = S − s`,
so `A′/S′ = (A(S−s)/S)/(S−s) = A/S`. ∎ (Under floor division `ρ` is weakly
non-decreasing by at most one dust unit per operation, and **exactly constant when no
operation occurs**.)

**Lemma 2 (F6 is portless).** `ar(F6) = (; P)`. F6 has no input port, hence reads no
`A`/`K` state and cannot be driven by it.

**Theorem 1.** `F7 ∉ Cl({F1, F6})`.
*Proof.* Suppose `I = t(σ_F1, p)` for a term `t` over F1 and F6. Consider the trace:
no F1 operation is performed, and the F6 source posts a constant `p`. By Lemma 1 `σ_F1`
is fixed; by Lemma 2 `p` is fixed; therefore `t(σ_F1, p)` is constant on the trace. But
F7 admits the same trace with `I` strictly increasing: `accrueIndex(index, rateBps, dt)`
`= ⌊index·(BASE + rateBps·dt)/BASE⌋ > index` for `dt > 0, rateBps > 0`
(`L1/common.qnt:112`), and `streamIndex` likewise (`L3/common.qnt:88–95`). Constant ≠
strictly increasing, so no such `t` exists. ∎

The witness is the **interest-only trace**: no deposit, no redemption, no price move,
claims still grow. That trace distinguishes a lending market from a locker, and F1 + F6
cannot produce it. Pendle's `ratchetIndex = max(stored, newRate)` looks like the
definability case, but its content is the high-water ratchet — it needs the stored state
`ix.stored` that neither F1 nor F6 carries, and that state is exactly what makes
`indexMonotone` hold when the underlying rate does not. **F7 stays.**

### 2.2 Is F4 (conservation) a primitive at all?

**No. It is a law, and it should be dropped from the basis.**

Three arguments, in increasing strength.

1. **Type.** F4 has no arity. GOAL.md itself records its signature as "boundary
   condition on `A`, `K`" — not `in → out`. Every other family is a wiring node; F4 is a
   predicate on wirings. They are not the same kind of object.

2. **Use.** Of the F4-predicate occurrences in protocol specs (as opposed to their
   `common.qnt` definitions), all but one are `val inv_*` declarations —
   `usdc.qnt:165,174`, `usdt.qnt:179,195,199`, `usdg.qnt:160,172`, `pyusd.qnt:142,151`,
   `yearn.qnt:156`, `beefy.qnt:153`, `cow.qnt:121`, `oneinch.qnt:94`. They are asserted
   about reachable states; they never gate a transition. The sole apparent counterexample
   is `cpKHolds` inside `swap0for1`'s guard (`uniswap_v2.qnt:83,100`) — but that
   post-state is already fixed by `cpAmountOut`, whose floor division makes the product
   non-decreasing unconditionally. It is an assert, not a constraint: deleting it does
   not change the reachable set.

3. **Derivation.** `STRUCTURE-DEFINITIONS.md` P2 marks conservation **[imm from Def. 2]**
   — immediate from polarity. In a complete construction, linear colours are matched
   exactly once (Def. 7 clause 2), so `c`-outputs equal `c`-inputs for every `c` with
   `λ(c) = lin`. F4 is a *metatheorem of the carrier*. Listing it as a basis element is
   like listing "truth-preservation" among the Boolean connectives.

F4 does split. Internal conservation (`supplyConserved`, `burnMintConserved`,
`shareSolvency`) is P2. External conservation (`reserveCovers`: off-chain reserve ≥
on-chain supply) is **not** derivable, because the reserve is not an on-chain linear
resource — it is Def. 7 clause 4, a boundary declaration on an unmatched linear port.
Either way F4 is not an operation. **The basis has seven operations and one law.**

**PO-IND-2.** Prove `cpKHolds` is entailed by `cpApplySwap` for all non-negative
integer arguments, discharging the one guard-use of F4.
**PO-IND-3.** Prove P2 formally from Def. 2 + Def. 7(2), so that F4-internal is a
theorem with a proof and not an assertion.

### 2.3 The remaining six

| pair | separating property | verdict |
|---|---|---|
| F3 ⊥ F7 | `λ(Q) = lin`, `λ(I) = cls`; there is no rule `A ⊸ !A`. F3's envelope *decreases on use* (`consume`), F7's index is read by unboundedly many consumers and never decreases (`indexMonotone`). | independent, by polarity alone |
| F2 ⊥ all | F2 is the only family whose output port is live at a strictly later horizon (`(K) → (K@h₂)`). Every other family's ports are co-live with their inputs. Without F2 no `ℓ(e) ∩ ℓ(e′)` ever crosses a horizon. | independent, by Def. 4 |
| F6 ⊥ F1 | An AMM's reserve ratio is an endogenous price, so one direction is tempting. But F6 can post a `P` that no reachable F1 state entails — that unsoundness *is* oracle manipulation as a hazard class. F1 cannot produce an unentailed `P`. | independent |
| F5 ⊥ F6 | F5 outputs `V`, F6 outputs `P`; `V` is a comparison of two `MDF` terms and `P` is a term. No `MDF` term is a comparison and vice versa. | independent, by sort |
| F8 ⊥ F5 | F8's `max(S−K,0)` is convex and non-affine in `P`; F5 outputs `V` not `A`. Convexity in price is F8's whole content — it is optionality. | independent |
| F1 ⊥ F8 | Lemma 1: F1 preserves `ρ`; F8 pays out against `P` with no `ρ` constraint. | independent |

**Net: seven independent operations {F1, F2, F3, F5, F6, F7, F8}; F4 demoted to a law.**

---

## 3. The failure list

Post's list is finite because a Boolean clone is determined by which relations it
preserves, and there are five maximal such. The analogue here is derived from `Σ`, not
by analogy: a construction is a wiring over a **finite** colour set `C` (|C| = 9) and a
**finite** horizon chain `H` (|H| = 5).

**Theorem 2 (colour closure).** For each `c ∈ C`, let `Ω_c` = the class of
constructions with no *output* port of colour `c`. Then `Ω_c` is closed under `⊗`.
*Proof.* `⊗` (Def. 8) forms a disjoint union and matches existing ports. It creates no
port and no colour. If neither operand has a `c`-output, the composite has none. ∎

**Corollary.** If `P ⊆ Ω_c` then `Cl(P) ⊆ Ω_c`, and every application whose
specification requires a `c`-output is not generated. **This is the incompleteness
criterion, and it is checkable by reading the arity column.**

The same argument on horizons gives `Ω_h` (no port live at `h`), closed for the same
reason. The list is therefore finite, of size ≤ |C| + |H| + 1 = 15.

| # | class | escape witness in the eight |
|---|---|---|
| 1 | `Ω_A` no asset output | F1 `(K) → (A)`, F8 `(P) → (A)` |
| 2 | `Ω_K` no claim output | F1 `(A) → (K)` |
| 3 | **`Ω_K*` no liability output** | **none** |
| 4 | `Ω_P` no price output | F6 `() → (P)` |
| 5 | `Ω_V` no verdict output | F5 `(K,K*,P) → (V)` |
| 6 | **`Ω_U` no authority output** | **none** |
| 7 | `Ω_Q` no capacity output | F3 `(Q,A) → (A,Q)` |
| 8 | **`Ω_M` no message output** | **none** |
| 9 | `Ω_I` no index output | F7 `(I,P) → (I)` |
| 10 | `Ω_{h₀}` nothing atomic | F1, F5, F8 |
| 11–13 | `Ω_{h₁}`, `Ω_{h₂}`, `Ω_{h₃}` | F2 (the sole horizon-crossing family) |
| 14 | `Ω_{h₄}` nothing at timelock | none — governance is `U`, see #6 |
| 15 | `Aff_P`: asset outputs affine in `P` | F8 (`max(S−K,0)` is convex, not affine) |

**Item 15 is the genuine Post-`L` analogue** and it is the one item not forced by the
finiteness of `Σ`. Whether the "shape of dependence on `P`" axis has finitely many
closed classes (affine ⊂ convex piecewise-linear ⊂ …) is open; over `MDF` the shapes are
piecewise-linear with boundedly many pieces, which suggests finiteness but does not
prove it. **PO-IND-4.**

### The three unescaped containments

**The eight-family basis is contained in `Ω_{K*}`, `Ω_U`, and `Ω_M`. It is therefore
incomplete, provably, by Theorem 2.**

- `Ω_{K*}`: F5 *consumes* `K*`; nothing *produces* it. `L2/liquity.qnt:63` `openTrove`
  writes `debt: debtAmt` and `boldSupply' = boldSupply + debtAmt` — liability and asset
  issued together, guarded by F5's `canOpen`. F5 is the guard; the issuance is an
  unnamed operation. Every CDP, every borrow, every short position needs it.
- `Ω_U`: no family outputs `Authority`. Yet `Gp` (pause) and `Fz` (freeze) are two of
  the **six symbols that survived** the 58-symbol collapse, and `MINTER_ALLOWANCE`,
  `RESTRICTED_ADDRESS`, role checks and `setPaused` occur across L4 and L6 (279 matching
  lines corpus-wide). Every reserve-backed stablecoin — a whole category — is
  ungenerated.
- `Ω_M`: no family outputs `Message`. `ATTESTED_MESSAGE_ONCE` (`L4/common.qnt:112–118`,
  CCTP `usedNonces`, LayerZero payload clearing) is the safety hinge of the entire
  bridge category. CCTP is ungenerated.

**PO-IND-5.** Add three families — liability issuance `(A, V) → (K*, A)`, authority
grant/revoke `() → (U)` with `λ(U) = aff`, attested delivery `(M) → (V)` with
once-only consumption — and re-run the containment check. Basis size goes from 8 to
10 operations (7 surviving + 3) plus one law, or 11 if PO-IND-1 forces a root family.

**PO-IND-6.** Prove the criterion is *sufficient*, not merely necessary: that a basis
escaping all 15 classes generates everything. Theorem 2 gives one direction only.
Post's theorem is an *iff*; this is currently an *only-if*.

**PO-IND-7.** Verify `Ω_c` maximality — that each `Ω_c` is a maximal proper
`⊗`-closed class. Without maximality the list is a correct necessary condition but not
the minimal one.
