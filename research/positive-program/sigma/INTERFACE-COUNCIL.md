# The interface discipline — council synthesis and work plan

Four mathematicians were asked to design, independently, from different frames:
separation logic, category theory, process algebra, and Lean formalisation. None
saw another's answer.

**They converged on the same fix, and two of them independently found a second
defect nobody had noticed. One of them found a live bug in the corpus while
checking whether its design would reject it.**

---

## 1. The fix, four ways

The defect: `κ` identifies carriers **by sort**, and `Led`'s declared total `sup`
is merely sort `Q`, so `κ` may glue it to an unrelated `Q` whose transitions then
write it while the balance map is untouched. Conservation dies under plain
interleaving, no fusion required.

| frame | the fix |
|---|---|
| separation logic | `sup = ●bal` — an **authoritative view**, not an independent carrier; not splittable |
| Lean | `sup ∉ ports` — a **well-formedness field** on `Ledger` |
| category theory | **there is no `Q` state port**; `Q` crosses a boundary only as a signed flow |
| process algebra | `sup` is a **derived output port** with defining equation `sup = ‖bal‖` — "κ cannot target `sup`, because `sup` no longer exists to be glued" |

One statement in four dialects: **the declared total is not a shareable thing, and
`Q` is not shared state — it moves.**

## 2. A second defect, found independently by two frames

**`κ` is attached to a pair, not to an object.** `κ₁₂` and `κ₂₃` do not compose to
a `κ₁₃`, so in `(M₁ ⋈ M₂) ⋈ M₃` a binding between 1 and 3 cannot be written down at
all: `κ` ranges over quotient classes of `(S₁×S₂)/κ₁₂`.

> **Associativity is not false. It is unstatable.**

For a theory whose entire claim is composition, this is arguably worse than the
conservation bug. Both frames give the same remedy — **stable port names plus
n-ary composition over a global binding set**; binary-with-per-pair-`κ` cannot be
repaired. The process-algebra design adds that per-pair alphabetised parallel
`‖_A` is *itself* non-associative, so the alphabet must be fixed by port footprint,
not per pair.

## 3. What each invariant costs

Aggregating the four verdicts, which agree:

| invariant | after the fix |
|---|---|
| **(iv)** no `Q` changes except by `Led` | **free** — stops being an invariant at all; it is well-formedness of objects (the write algebra), preserved by every morphism |
| **(i)** `‖bal‖ = sup` | **free**, and in a better form: open systems get *conservation with flux*, `‖bal‖ − sup =` net inflow at open `Q` legs. BASIS.md's awkward "except across declared mint/burn" is exactly "except at unplugged `Q` legs" |
| **(ii)** `T` monotone | **free per clock**; the composite has two clocks unless bound. Side condition wherever a `Prop` term mixes factors with a `T`-difference |
| **(iii)** rounding never favours the caller | **NOT free, and all four agree why.** "The caller" is not a state predicate — it is the **polarity** of a `Q` flow. Given polarity it is statable (`π̄` on inbound, `π` on outbound) but preserved only along orientation-consistent composition. It lives in the directed subcategory |

## 4. `Q` is the exception, and that is structural

Every frame reached it separately. Separation logic: `Q` *values* are freely
duplicable — `Prop` copies and discards them — but a `Q` **position under a
conservation law** is not; linearity refines the *role*, not the sort. Category
theory: `⋈` must be **two-tier** — hypergraph (freely shareable) on
`{Σ, T, Φ, N, B}`, plain monoidal (linear, plug-once) on `Q`. Process algebra:
claims are linear, one claimant per `(ledger, name)`.

The categorical note is the one to keep: *the category theory did not invent this
constraint; it located where BASIS.md had already stopped enforcing it.*

## 5. What the discipline would reject — and a live bug it found

The process-algebra design was asked what its rules forbid. Two answers:

**Convex-over-Curve needs re-annotation, not rejection.** `totalStaked` is a claim
on Curve's LP ledger, but `depositLP` (`convex.qnt:47`) mutates it as a *private*
transition. That is outlawed; it must become a rendezvous with Curve's `move`.
"Roughly every L3 spec owns a `total*` that is an undeclared claim on an unmodelled
ledger." A corpus-wide re-annotation, no semantic loss.

**Pendle-over-SY is rejected outright — and the rejection exposed a real defect.**
Verified by hand and then machine-checked:

- `pendle.qnt:104` — `setSyRate(r)` guards only `r > 0`. **Drawdowns are permitted.**
- `common.qnt:71` — `ratchetIndex = { stored: max(ix.stored, newRate) }`. The index
  only ever rises.
- `pendle.qnt:196` — `backing` evaluates `pyBackingHolds(…, max(index.stored,
  syRate), …)` — at the **ratcheted** index, not the true rate.

So when `syRate` falls, the invariant is evaluated at a rate better than reality.
Witness `wit_staleIndexBacking` asserts that no reachable state has the index stale,
`pyBackingHolds` failing at the **true** rate, and `backing` nevertheless holding.

**Result: `[violation]` — the state is reachable.**

The shipped invariant holds vacuously exactly where it matters, measured at the
same stale index that let `mintPY` over-mint. This is the programme's recurring
shape once more — *the check passes because it is measured in the units that
caused the error* — and it survived seven audit passes. **A design exercise found
it in one afternoon, by asking what the rules would forbid.**

---

## 6. The work plan

**M1 — the Lean milestone (~25 declarations). The whole fix in one theorem.**
Encoding is settled: a flat non-dependent value universe with sort-correctness as a
`Prop`, and — the single most important choice — `(S₁×S₂)/κ` encoded as a
**pullback**, not a quotient:

    GlueSt κ := { p : St Σ₁ × St Σ₂ // ∀ i j, κ i = some j → p.1 i = p.2 j }

No `Quot.lift`, no soundness obligations, fusion agreement becomes an ordinary side
goal. Model `bal : N ⇀ Q` as `N`-many `Q`-carriers, which is what makes the defect
*sayable*. `sup ∉ ports` is a field of `Ledger`, not a theorem.

**Theorem:** two `Led`s coupled along balance ports, `sup ∉ ports` both sides,
conservation on every reachable glued state. **Plus a negative companion** —
`¬ Cons` when `sup` is wrongly declared a port — because the junk-value totality of
`Val.toQ` could otherwise make conservation true for the wrong reason. That is the
`gated_not_permFree` discipline already in `Permission.lean`.

**M2 — polarity.** Add signed `Q` flows and restate (iii) in the directed
subcategory. All four frames say this is the shape; none says it is easy.

**M3 — associativity.** Requires n-ary composition over a global binding set. Do
not attempt to patch binary `⋈`; two frames independently say it cannot be.

**M4 — corpus adequacy.** Re-annotate the L3 `total*` claims. Fix the Pendle
backing invariant. Then re-check the 60 hand-written cross-carrier invariants
(`basis/cross_invariants.py`) and count how many become derivable — that is the
acceptance test, and it is checkable against code that already exists.

**Explicitly out of scope**, and all four agree: `Prop`'s rounding laws, `Post`'s
`R_Φ` correction, `Cmp`, `T` monotonicity, generic n-ary arithmetic. Orthogonal to
the coupling defect.

## 7. The risks, in each designer's own words

- **Separation logic:** if `sup` is `●bal`, reading it reads `●`, whose footprint is
  the whole map — so a mint that reprices shares has footprint `N`, and the
  no-double-write clause *forbids exactly the compositions the basis exists to
  license*. "The frame rule converts a missing induction into a stated atomicity
  assumption. That is progress, but it is not the same as a proof."
- **Category theory:** conservation wants linearity, free composition wants copying.
  Linear `Q` ports lack the diagonal, hence pushouts, hence the adjunction — "the
  associativity theorem evaporates for exactly the sort it was meant to protect."
- **Process algebra:** weakening claims to `c ≤ bal` to admit rebase means `Prop`
  computes against a lower bound; a redeemer is under-paid (safe), a depositor is
  over-issued shares (not safe). Repair needs a refresh event — "at which point I
  have reintroduced, as a proof obligation on every deposit path, precisely the
  synchronisation I claimed to have made structural."
- **Lean:** junk-value totality may make conservation vacuously true. Mitigated by
  the negative companion theorem.

Three of the four say the fix is sound and may nonetheless reject the corpus. That
is the thing to find out, and M1 is the cheapest way to find it out.
