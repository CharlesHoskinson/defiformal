# RESUME — session checkpoint, 2026-08-06

Branch `positive-program/phase2-honest-corpus`, 33 commits ahead of `main`, pushed.
Read this first; it is the only file that says what is *live*.

---

## 1. The one-line state

The programme's central claim — that the basis nearly generates DeFi — is **weaker
than it was this morning**, and the reason is that several things which had been
believed were run for the first time. What replaced them is a concrete defect in the
composition operator, a fix for it, and a machine-checked proof that the fix is
load-bearing.

## 2. What is now settled

| | |
|---|---|
| **Gate 0.1** | RESOLVED. `\|P\| = 4` and the six-sort split are **withdrawn**. The `Q`/`Σ` invariant is false, and it had been recorded FAILED for seven passes on a harness bug — the "three operationalisations" were two, and both scanned `init`. `sigma/QSIGMA-VERDICT.md` |
| **Convention 6h** | ADOPTED into `P2-CONTRACT`, ten re-specs retrofitted. Every state-changing action resolves its caller to MODELLED / OMITTED / FROZEN / PERMISSIONLESS with a contract line. `phase2/CONVENTION-6H-AUTHORITY.md` |
| **Gate 2.3 (ten)** | MEASURED. Ungenerated protocol-definition rate **16.7% (v1) → 16.6% (v2)**. The roadmap's "743/820 is a floor" claim **does not hold**. `sigma/GATE-2.3-TEN.md` |
| **`P4.2`** | CORRECTED in `BASIS.md`. `R_Φ` is per-instance, not "the acyclic status DAG": 18 of 27 boolean `Φ` carriers cycle, across 14 of 51 specs |
| **The composition defect** | FOUND, DESIGNED, and M1 PROVED. See §4 |

## 3. What was retracted, and it was most of a session's output

Four adversarial referees refuted **four** claims of mine. `sigma/RETRACTION.md` has
the detail. In short: `Post` is *definitionally* authority-parameterised, so "every
basis family is permission-free" is false and `mandate = Perm ⋈ Led.move` is
withdrawn; the Yearn counterexample was a view function, not a carrier; and the
cyclicity obstruction died on P4.2 being descriptive.

**Nothing found this session refutes generation for `P`.** The mandate — the corpus's
most-confirmed gap — appears to be `Post(Φ) ⋈ Cmp ⋈ Led.move`, i.e. generated. Do not
re-derive any of those four claims without reading the retraction first.

## 4. The live thread — the interface discipline

**The defect.** `BASIS.md` §5 couples along a `κ` that "identifies only carriers of
the same sort". `Led`'s carrier is `(N ⇀ Q) × Q`, and its declared total `sup` is
merely sort `Q` — so `κ` may glue it to an unrelated `Q` whose transitions write it
while the balance map is untouched. **Conservation dies under plain interleaving.**
The invariant induction §5 relies on has no proof.

**The corroboration.** The corpus hand-writes **60 cross-carrier invariants across 34
of 51 specs** (`basis/cross_invariants.py`), and many are `‖bal‖ = sup` restated —
`lpConservation`, `supplyConservation`, `cTokenConservation`, `debtConservation`. If
the law were inherited, none would need to exist.

**The design.** Four mathematicians, four frames, one answer
(`sigma/INTERFACE-COUNCIL.md`): *the declared total is not a shareable thing, and `Q`
is not shared state — it moves.* Two of them independently found a second defect:
`κ` attaches to a pair, so **associativity is not false, it is unstatable**.

**M1 — DONE.** `lean/Defialgebra/Interface.lean`, `lake build` clean, sorry-free,
standard axioms. `sup_not_port` as a well-formedness field; `cons_of_portConfined`;
and the negative companion `cons_broken_if_sup_is_port` showing the discipline is
load-bearing rather than vacuous.

## 5. Next, in order

- **M2 — polarity.** Signed `Q` flows; restate invariant (iii). All four frames agree
  "never favours the caller" is not a state predicate but the *polarity* of a flow,
  and that it lives in the directed subcategory. Nobody said it was easy.
- **M3 — associativity.** Requires n-ary composition over a global binding set. **Do
  not try to patch binary `⋈`** — two frames independently say it cannot be.
- **M4 — the acceptance test.** Re-check the 60 cross-carrier invariants and count how
  many become derivable under the discipline. This is the number that says whether
  this is a theory of DeFi or of something adjacent to it.
- **Pendle bug** — `quint-models/L3/pendle.qnt` `wit_staleIndexBacking` reports
  `[violation]`: `backing` is evaluated at `max(index.stored, syRate)`, the ratcheted
  index, while `setSyRate` permits drawdowns. The invariant holds vacuously exactly
  where it matters. **Unfixed.**

## 6. Open decisions, for the human

1. **Does the discipline reject the corpus?** Three of four designers say the fix may
   be sound *and* reject real compositions (Convex-over-Curve needs re-annotation;
   Pendle-over-SY is rejected outright). M4 answers this.
2. **2.2 — nineteen unspecced applications.** `sigma/GATE-2.2-WORKLIST.md`. **0 of 19
   have contracts on disk**, so it is ~19 acquisitions before a line of spec. And
   after gate 2.3, it must be justified as *coverage*, not as *correction*.
3. **What the paper is.** `GOAL.md`'s second branch is better supported than the
   first, but the retraction removed the irreducibility argument that made it sharp.

## 7. Traps for whoever resumes

- **`/root/DefiElements` is the live checkout.** There is no Windows copy.
- **WSL heredocs eat apostrophes and backticks.** Quint primed variables (`x' =`) and
  Lean tactics break inside `bash -lc "..."`. Write scripts to a file and `cp` them.
- **Quint: `x' = a or b` parses as `(x' = a) or b`.** The left disjunct is a valid
  assignment, succeeds, and short-circuits — so the ghost is framed, never set, and
  the witness reports `[ok]`. This cost a false negative on the role-cycle witness.
  **Parenthesise every disjunctive assignment.**
- **A witness reporting `[ok]` may mean a broken harness, not a true claim.** The only
  defence that worked all session was a second observation contradicting the first.
- **Five of my own detectors produced false positives on first run** — `owner` matched
  as a caller check when it is a record field; "Binance staked ETH" matched
  `tethercoin_USDT` on "eth" inside "tether". Read the evidence column, never the
  total.
