# Adversarial mathematical audit — `paper/atlas.tex` and `lean/Defialgebra/Obstruction.lean`

Auditor brief: refute, do not confirm. All computational claims below were re-run against
the repository's own model (`formal/v2/tables.mjs`); scripts are in `audit/probe1.mjs` …
`audit/probe5.mjs` and are re-runnable with `node audit/probeN.mjs`.

**Moving target.** I began against `atlas.tex` @567 lines (with `thm:invariance` and
`cor:tarski` live). Commit `87bbec5` ("retract the structure theorem and accessibility — the
audit was right") landed mid-audit and the file is now 858 lines. I independently derived the
counterexample `X = {Ct, Op, Tp}` that now appears in `prop:noinvariance` before reading that
commit, and I reproduced `meas:noinvariance` exactly (116 / 224,025). Everything below is
scored against **current HEAD**.

---

## Severity 1 — invalidates a headline claim

### A1. `prop:moore` is FALSE, and it is the paper's self-declared "structural content"

> `\begin{proposition}\label{prop:moore}` "$\Fix(\Gamma)$ is a Moore family (closed under
> intersection)…"
> Remark: "Proposition~\ref{prop:moore} is the structural content of the whole paper."

**Counterexample.** X = {Op, Tp} and Y = {Ex, Op} are both Γ-closed; X ∩ Y = {Op} is not —
requirement `L1a` (`Ex|Tp|At|Oa|Sv|Cl|Cp|St|Wg`) is open in it. Rate at 58 elements:
**1,923 of 194,775 sampled Fix(Γ) pairs fail intersection-closure; 0 fail union-closure**
(`probe3c.mjs`). Exhaustively on a 14-element universe: 2,966,208 of 12,199,330 pairs fail.

This is not a new discovery for the project. `algebra/THEOREM-LEDGER.md` entry **P9**, listed
under PROVED, states: *"The full closed-set family is union-closed but **not a Moore family**,
so no single-valued Galois closure operator exists over it."* The paper asserts the negation
of its own authoritative record.

### A2. The root cause is unretracted: Γ is not an operator

`prop:polarity` asserts Γ is "inflationary, monotone and idempotent, hence a closure
operator", and the Definition writes Γ : L → L. **No such function exists** for a requirement
system with disjunctive terms, and none is implemented. `tables.mjs` has no Γ; it has
`gammaOpen(S)`, a *test*. `formal/v2/f11.mjs:52` says so in a comment:

> `// (c) the closure CONDITION actually scored (L*), which is a family, not an operator`

Two readings are silently interleaved throughout the document:

* **(A)** Γ(X) = X ∪ {unit-forced} — a genuine closure operator, Fix a Moore family — but its
  fixed points are *not* the requirement-satisfying sets, so it is not the Adm that every
  measurement scores.
* **(B)** Fix(Γ) = M(R), the models of the requirements — what `admissible()` actually
  computes — union-closed (`thm:polarity`), **not** intersection-closed.

`prop:moore` states (A)'s property about (B)'s object. `thm:polarity` and `prop:moore`
therefore contradict each other about the same set. `prop:noinvariance` is a *symptom* of the
same confusion (a disjunctive term has several witnesses, so a witness can be
warrant-removed); retracting the symptom while leaving `prop:polarity` and `prop:moore`
standing leaves the paper internally inconsistent.

### A3. The retraction over-corrects: Fix(Γ) ∩ Fix(Δ) *is* a nonempty complete lattice

> §`sec:retracted`: "**All three steps are false, and the claim is withdrawn.**"
> Remark: "**The structure of Adm is open.**" Open problem 1: "Is Adm a lattice under any order?"

The *route* (residual ⟹ invariance ⟹ Tarski) is dead — correctly. The *conclusion* is true,
and the paper already contains its proof:

1. A requirement clause is ¬s ∨ ⋁_{e ∈ T_j} e — dual-Horn (paper's own Definition).
2. A warrant clause is ¬e ∨ ⋁_{c ∈ C(e)} c — **also dual-Horn** (paper's own Definition).
3. By `thm:polarity`'s own Schaefer argument, the models of a dual-Horn theory are
   union-closed.
4. Fix(Γ) ∩ Fix(Δ) is exactly that model class, and ∅ is a member.
5. A union-closed family of subsets of a finite set containing ∅ is a **complete lattice**
   under ⊆: ⋁S = ⋃S, ⋀S = ⋃{Y ∈ F : Y ⊆ ⋂S}. No Tarski, no monotone self-map, no invariance
   required.

Measured (`probe4.mjs`): over 175,230 pairs drawn from Fix(Γ) ∩ Fix(Δ) at 58 elements,
**union violations 0**; ∅ and ⊤ are both members. Intersection violations 51,917 — so **meet
is not intersection**, which answers the remainder of the old open problem 1 negatively and
constructively.

Declaring the structure open is a second wrong answer to the same question. Note the scope:
Adm *with* prohibitions is genuinely not union-closed; the retracted theorem was about
Fix(Γ) ∩ Fix(Δ), and open problem 1 now conflates the two objects.

### A4. Abstract and Introduction still assert the retracted results

* Abstract: "a sound and empirically **exact** procedure exists on completion lattices [S,⊤]"
  — contradicted by `meas:vacuous` in the body: "exact in **0** of 18 seed-instances, slack
  1–58".
* Abstract: obstruction of "**equalizers in Pos**" — the phrase occurs once, in the abstract,
  and **nowhere in the body**. There is no such result in the document.
* §1.3: "Because the warrant relation is constructed as the residual of the requirement
  relation, Δ maps Γ-closed sets to Γ-closed sets, and the common fixed points form a complete
  lattice. That is a structure theorem" — verbatim the claim §`sec:retracted` withdraws and
  `prop:notresidual` calls false. It survived the retraction commit.
* §"convex geometry", Remark[Why this is the useful structure]: "Measurement~\ref{meas:access}
  recorded accessibility at 8,240/8,240 … two views of the same combinatorial object" —
  `meas:access` now reads "**Accessibility fails — retracted**. That figure is wrong and the
  claim is false." Both paragraphs are in HEAD.

---

## Severity 2 — weakens a claim

### B1. `conj:convex` is not a conjecture; it is a two-line theorem — and its measurement has the exact defect the paper just diagnosed

The definite fragment has **16 rules, 10 bodies, 10 heads, bodies ∩ heads = ∅, no cycles**
(`probe4.mjs (e)`). Hence for closed A and y ∉ A: Cn(A ∪ {y}) = A ∪ {y} ∪ H(y) where H(y) are
y's heads, and propagation stops because no head is a body. If x ∈ Cn(A ∪ {y}) with x ∉ A,
x ≠ y, then x ∈ H(y), so x is a head, so x is not a body, so H(x) = ∅ and
Cn(A ∪ {x}) = A ∪ {x} ∌ y. **Anti-exchange, proved.** Closed sets are intersection-closed
trivially. So (E, Cn) *is* a convex geometry — and, being also union-closed, is just the
up-set lattice of a height-1 poset. "Unique minimal generator" reduces to "delete every head
whose body is present".

`meas:antiexchange` tests only the **1,697 closed sets generated by singletons and pairs**.
The full closed-set family of 16 implications over 58 elements has order 10^15 (ledger R9
gives ≈ 2.2 × 10^15). Testing ≤2-generated closures is the same restricted-instance error
`rem:truncation` diagnoses two sections earlier — "accepting a 100% score without asking what
the instance could not contain". The result happens to be true; the evidence offered does not
establish it. I re-ran anti-exchange on randomly generated closed sets: 686 premise-satisfying
instances, 0 violations — consistent with the proof.

### B2. `conj:perfect` — "falsifiable by a finite search at our scale" is not true at 58 elements

G_⊕ has vertex set Adm. Monte-Carlo over uniform subsets of the 58 elements gives an
admissible density of 2.95 × 10^-2, i.e. |Adm| ≈ 8.5 × 10^15 (`probe5.mjs`). Perfection of a
graph with 10^16 vertices is not "decidable for our instance", and an odd-hole search over it
is not "a finite search at our scale". The claim is only defensible for the 20-element
instance from which `meas:frag`'s [11026, 23055) comes — which the text does not say.

### B3. `prop:notresidual`'s number is not reproducible

> "33 of the 63 (subject, term-alternative) pairs violate the residual condition."

I could not obtain 33/63 under any natural reading (`probe4.mjs (b)`):

| reading | result |
|---|---|
| `LSTAR`, (subject, term-alternative) with multiplicity | **23 / 69** |
| `LSTAR`, distinct (s,e) pairs | 18 / 51 |
| `PARSED_NEW` (data.ts law strings), with multiplicity | 17 / 47 |
| `PARSED_NEW`, distinct pairs | 16 / 41 |
| `LSTAR`, (subject, term) pairs | 15 / 31 |

The *qualitative* claim is right and stronger than stated: `CONSUME` is a **hand-written
literal** at `formal/v2/tables.mjs:94`, not computed from anything, and it disagrees with
R^-1 in both directions — **204 surplus entries** and 12 of 27 rows missing a genuine R^-1
member. But a Proposition asserting a specific count that cannot be reproduced is the same
class of defect the document is trying to purge.

### B4. `thm:aft` — "applies to any A, product-form or not" is false

The proof writes A(x,x) = (Γ(x), Δ(x)). That identification *is* a product-form assumption,
restricted to the diagonal; a general approximator's diagonal need not decompose that way. The
claim of full generality is unearned. Separately, the assignment the theorem refutes (Γ lower,
Δ upper) is one the paper's own Corollary calls "backwards", i.e. one no AFT practitioner
would attempt — and the *only* non-strawman assignment ("exchanging the roles is admissible
but vacuous, since lfp(Δ) = ⊥ identically, so the induced stable operator is constant") is
dispatched in a **one-sentence Corollary with no proof**. The load-bearing half of the AFT
section is the unproved half.

### B5. `thm:bilattice`

* "Adm is precisely the diagonal {(x,x)}" — false. The diagonal of Fix(Γ) × Fix(Δ) is
  Fix(Γ) ∩ Fix(Δ); Adm is that **intersected with H^c**. The two differ exactly where the
  paper's own composition results live.
* "a bilattice would make Adm a lattice under both orders, contradicting
  Theorem~\ref{thm:polarity}" — non sequitur. `thm:polarity` says the model class is not
  closed under ∪/∩; it says nothing about being a lattice under some *other* join. A3 above
  exhibits a complete-lattice structure on Fix(Γ) ∩ Fix(Δ) whose meet is not intersection,
  which is precisely the case this step assumes away.
* "definable object" is never defined, so the theorem has no formal statement.

### B6. `prop:twoeffects` — "exactly when" is wrong on both halves

> "M(R) fails ∩-closure exactly when some requirement has a term of width ≥ 2, and M(H) fails
> ∪-closure exactly when H ≠ ∅."

* Second half: take H = {{e}} — nonempty, and M(H) = {X : e ∉ X} **is** union-closed. The
  correct condition is: some H ∈ H with |H| ≥ 2.
* First half: a requirement (s, T_j) with s ∈ T_j and |T_j| ≥ 2 is a tautology and breaks
  nothing. The correct condition needs s ∉ T_j.

Stated with no proof.

---

## Severity 3 — cosmetic / bookkeeping

* `meas:notidem` ("Δ is not idempotent") contradicts the Definition of Δ, which says each
  operator is "iterated where necessary to a fixed point of its own defining step".
* Clause counts do not reconcile across the document: `meas:arity` "34 element-expressible
  clauses (31 requirement, **3** prohibition)"; `meas:ablation58` "93 clauses (31 closure, 27
  warrant, 21 grounding, **14** negative)"; `meas:clutter` "only **3** are enforced positive
  element sets, namely X2, X11a and X19". Meanwhile `meas:ablation58` attributes 100% of the
  61 exclusions to **X21 and X2** — and **X21 has no row in `viz/src/data.ts` at all**; it is
  invented at `formal/v2/tables.mjs:144` (`Fl ∧ (Xf|Rl|Of)`). So the repair theory
  (`thm:blocker`, `prop:oneobject`) is built on a 3-member clutter that **excludes the rule
  doing 32/72 of the actual exclusion work**.
* `cor:nomax`'s argument is sound for "⊆-greatest", but the sentence reads as ruling out a
  unique maximum-cardinality clique, which does not follow.
* `prop:dag` is `THEOREM-LEDGER` P4, "four independent confirmations" — a measurement,
  presented as a Proposition with no proof.

---

## T2 — the Lean file

`lake build` succeeds (Lean 4.33.0-rc2 + mathlib), 437 jobs, exit 0, three style-linter
warnings only. Axiom hygiene is **clean**:

```
'Defialgebra.aft_obstruction'          does not depend on any axioms
'Defialgebra.aft_obstruction_eq'       depends on axioms: [Quot.sound]
'Defialgebra.fix_iterate'              depends on axioms: [propext, Quot.sound]
'Defialgebra.adm_univ_of_consistent'   depends on axioms: [propext, Quot.sound]
```

No `sorry`, no custom `axiom`, no unused hypotheses (`hΓ`, `hΔ`, `hc` are all consumed). That
part I tried to break and could not.

**But the file does not machine-check what the paper claims.**

1. **`Consistent` assumes the entire mathematical content.** The file defines
   `Consistent Γ Δ : Prop := ∀ x, Γ x ≤ Δ x`, docstringed "Consistency, as required of every
   AFT approximator, read on the diagonal." Given `Inflationary Γ` and `Deflationary Δ`, that
   hypothesis *immediately* gives x ≤ Γx ≤ Δx ≤ x. The theorem is a one-line antisymmetry
   sandwich. Every non-trivial step of `thm:aft` — that an approximator must preserve
   consistency, and that A(x,x) = (Γx, Δx) — happens **outside Lean**, in prose, and is exactly
   what B4 says is unearned. There is no approximator, no L², no ≤_p, no bilattice anywhere in
   the file. The worry in the brief is justified: the hypothesis is not "what AFT requires", it
   is the conclusion one substitution away.
2. **`Consistent` is never instantiated.** Nothing in the repository proves it of the actual
   Γ, Δ. The hypothesis set has exactly one model, (id, id), and the file never connects it to
   the atlas.
3. **`adm_univ_of_consistent` is rhetorical.** Its proof is literally
   `exact aft_obstruction Γ Δ hΓ hΔ hc x` after `simp` unfolds `Adm`. `Adm` is *defined* as
   `{x | Γ x = x ∧ Δ x = x}`, so the statement is a re-wrapping of the previous theorem with
   zero added content. It is also **not the paper's Adm** — the paper's includes H^c — and it
   sits under a section header `## The diagonal (paper: prop:moore)` although nothing about
   Moore families or interior systems is formalized (and, per A1, `prop:moore` is false).
4. **`fix_iterate` proves strictly less than `prop:repair`.** It proves
   Δx = x ⟹ ∀n, Δ^[n]x = x — one inclusion. `prop:repair` claims Fix(Δ^ω) = Fix(Δ); the
   converse inclusion (which needs deflationarity) is not formalized. Nor are monotonicity,
   deflationarity or idempotence of Δ^ω, all of which `prop:repair` asserts.
5. **Coverage.** Of the paper's 21 theorem/proposition/corollary items, the Lean file touches
   **two** (`thm:aft`, half of `prop:repair`). No `.tex` or `.md` in the repository references
   `Defialgebra` at all, so the paper makes no machine-checked claim and the artifact is
   uncited.

**Verdict:** the file is honest Lean and it is sound. It is not evidence for the paper. Any
sentence of the form "the obstruction theorems are machine-checked" should read "the final
three-line inequality chain of `thm:aft` is machine-checked, from a hypothesis that encodes
the step being argued for."

---

## T3 — proof-status inflation

Counting environments in HEAD (`grep -nE "begin\{(theorem|proposition|corollary)\}"`):
**5 theorems + 12 propositions + 4 corollaries = 21 items**. `\begin{proof}` occurs **7 times**.

**14 of 21 carry no proof of any kind**, despite the Status Conventions stating that
Theorem/Proposition/Corollary means "proved, with the proof given or sketched":

| # | item | note |
|---|---|---|
| 1 | `prop:polarity` | no proof; and false under the reading that is measured (A2) |
| 2 | `prop:repair` | no proof; only half formalized in Lean |
| 3 | `prop:moore` | no proof; **false** (A1) |
| 4 | Corollary after `thm:aft` ("assignment is backwards") | no proof; carries the only non-strawman AFT argument (B4) |
| 5 | Proposition "Γ restricts to [S,⊤]" | no proof |
| 6 | `prop:dag` | no proof; is a measurement (ledger P4) |
| 7 | Corollary after `prop:dag` | no proof |
| 8 | `thm:noncong` | no proof; witnesses asserted, not exhibited |
| 9 | `prop:twoeffects` | no proof; **false as stated** (B6) |
| 10 | `prop:notresidual` | no proof; number not reproducible (B3) |
| 11 | `thm:blocker` | no proof — it is Isbell / Edmonds–Fulkerson, imported literature |
| 12 | Corollary "Minimal repair" | no proof |
| 13 | `prop:oneobject` | no proof; cites Seymour's identity |
| 14 | `cor:nomax` | no proof; prose argument, slightly overshoots |

Of the 7 that do carry a proof: `thm:polarity` and `thm:bilattice` are sketches deferring to
Schaefer and Avron (and `thm:bilattice`'s own sketch contains a non sequitur, B5);
`prop:clique`'s proof is "Immediate from the definitions"; `prop:vacuous`'s is a two-sentence
restatement of its hypothesis; `prop:noinvariance`'s is a verified computational witness
(legitimate, and reproduced here).

**Honest count: 5 items carry a self-contained argument** (`thm:aft`, `prop:collapse`,
`prop:vacuous`, `prop:noinvariance`, `prop:clique`), of which three are near-tautologies and
one is a counterexample rather than a theorem. **No original non-trivial theorem is proved in
this document.** The two genuinely non-trivial imported results (`thm:blocker`, Seymour
minors) are other people's.

---

## What I tried and could not break

* **Lean axiom hygiene.** No `sorry`, no custom axioms, no unused hypotheses, builds clean. I
  attacked the statements rather than the proofs because the proofs are correct.
* **`prop:noinvariance` / `meas:noinvariance`.** Reproduced exactly: 116 invariance failures
  among the 224,025 non-empty Γ-closed subsets of size ≤ 4. The minimal witness {Ct, Op, Tp}
  is correct and I derived it independently before reading the retraction commit.
* **`meas:access` retraction.** Verified: `admissible({Ex,Op}) = true`, `admissible({Ex}) =
  false`, `admissible({Op}) = false`. The accessibility retraction is correct.
* **Δ monotonicity** (`prop:polarity`, second half): 0 violations in 200,000 random X ⊆ Y; and
  Fix(Δ) union-closure: 0 violations in 21,572,596 exhaustive pairs on a 14-element universe.
  Both hold.
* **`prop:collapse`.** The proof is short and correct given its hypotheses, and both
  hypotheses hold on the data.
* **`thm:aft`'s inequality chain.** Valid. The objection is to its scope claim and to what the
  Lean file does and does not establish, not to the chain.
* **Anti-exchange.** I looked for a violation over randomly generated closed sets (not just
  ≤2-generated) and found none — consistent with the proof in B1. The conjecture is true; the
  objection is that it is a theorem being under-claimed on under-powered evidence.
* **The live corpus.** All 65 Γ-closed protocols among the 72 corpus lanes satisfy invariance.
  That is why the failure went unnoticed for so long, and it is a genuine mitigating fact.
