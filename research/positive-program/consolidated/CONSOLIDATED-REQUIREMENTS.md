# Consolidated Requirements — seven schools, one structure

Seven mathematicians were briefed identically and in isolation. None saw another's
work. This document records where they converged, where they conflict, and what
we should do first.

Source documents: `../requirements/REQ-{clone,category,type,order,model,sheaf,synthesis}-theory.md`
82 named proof obligations across the seven.

---

## 1. The convergence

Each school was asked, independently: *if you can afford one enrichment of the
carrier this quarter, which one?*

| School | Top pick | Its name for it | Stated cost |
|---|---|---|---|
| Clone theory | typed arity profile per element | **arity** | 58 rows × 4 fields, one pass |
| Category theory | colour per term, output colour per element | **ports & colours** | one table, no new fieldwork |
| Type theory | input/output colour signature over G01–G16 + atomic region | **ports & linear scopes** | 58-row table, days |
| Order theory | sort the signature by the existing group column | **sorts by group** | *nearly zero* — column exists, 23/24 terms comply |
| Sheaf theory | live-set map into a 5-chain of settlement horizons | **horizon sort** | one column of 58 rows |
| Model theory | `Party` sort with counting (`Scope` ranked 2nd) | **Party + Scope sorts** | one sort, one relation, no arithmetic |
| Synthesis | `Mag` as a 5-valued interval abstraction | **magnitude sort** | d: 2→5 on a few variables |

**Four of seven independently chose the same thing**: give the 58 elements a typed
signature. They differ only in what they call it. Three of the four separately note
the data is *already largely present* in the existing tables — order theory measures
that 23 of 24 non-empty requirement terms already lie inside a single `G01–G16`
group, and category theory observes that a row like `L4: Pf (Ex)(Ct)(Li|Ad|Sl|Bs)`
**is already an arity assignment** — three typed input ports, misread as a clause.

The remaining three chose the two enrichments that everybody else ranked second or
third. Nobody chose anything outside this set.

---

## 2. The four independent cross-confirmations

These matter more than any single document, because they are agreements between
schools that had no contact and used different methods.

**2.1 — `Gs(3) → Au(4)` is the unique stratum violation.**
Order theory analysed the 18 singleton-subject arcs it derived from the requirement
table: 11 level, 6 descending, exactly **one ascending**. Synthesis analysed all 68
requirement arcs: 41 level, 26 descending, exactly **one ascending**. Different
units, different methods, **same single arc**, and both propose the same one-edit
repair (`σ(Gs) := 4`). After it, `σ` is a genuine filtration `E_0 ⊆ … ⊆ E_4` with
`Cn(E_k) ⊆ E_k`, induction on stratum becomes available in Lean, and `height(≼) ≤ 4`
becomes a theorem rather than a measurement. **This is the cheapest confirmed repair
in the programme: one table cell.**

**2.2 — `X21` is a scope artifact, not a fact about DeFi.**
Type theory, from the paper's own triage: ≥79% of composition failures. Sheaf theory,
by recomputing the compatibility graph on the 60-construction corpus under scoped
semantics: **119 failing pairs → 21**, i.e. **82.4% dissolve**, because
`live(Fl) ∩ live(Xf) = ∅` so `X21` can never fire. Both cite the paper's own
admission that the flash path and the burn path "never meet" while an element set
cannot say so. Two schools, two methods, 79.5% and 82.4%.

**2.3 — The perfection conjecture is unnecessary, per three schools.**
Clone theory: it reduces to "does `Adm` admit a majority polymorphism?", decidable,
and by Baker–Pixley that *is* 2-decomposability — no perfect-graph result needed.
Synthesis: clique ≤ tw+1 falls out of the same DP, so the conjecture is retired.
Sheaf theory: `ω = 55` both before *and* after removing 82% of the obstruction
volume, which is the argument that the extremal question was never the right one.
The paper's open problem #2 should be closed as *malformed*, not solved.

**2.4 — The published arc count is wrong or under-specified.**
Order theory counts **18** distinct arcs from the published table; the paper states
**15**. Category theory independently predicts `D′ ⊇ D` under a colouring and treats
any contradicted arc as a refutation. This discrepancy must be closed before any
density figure is trusted. It is itself a row-completeness failure.

---

## 3. The enrichment stack

Synthesising the seven rankings into one ordered programme.

**Tier 1 — buy now. Near-zero cost, data mostly already present.**
1. **Typed signature over the 58 elements.** Each element gets an input/output sort
   profile; sorts drawn from the existing `G01–G16` groups. Simultaneously satisfies
   clone theory's arity, category theory's colours, order theory's sorting, and the
   port half of type theory. Converts every disjunctive term into an implication,
   roughly doubles `D` *from the existing table*, and breaks the `|A| = 2` Boolean
   trap that clone theory proves is the actual source of the composition obstruction.
2. **Stratum repair — one cell** (§2.1). Licenses induction on stratum.
3. **Horizon / scope column.** One column of 58 rows over a 5-chain, most entries
   forced by the element's own definition. Buys ~80% of the composition failures.

**Tier 2 — buy next.**
4. **`Party` sort, existentially encoded.** Model theory's position is the strongest
   argument in the whole set: without it, completeness clause (C2) *separation* is
   false, so `P` is complete for **no** reference class at all — it is a necessary
   condition of the theorem, not a coverage improvement. Order theory notes the prior
   work already proved the existential encoding preserves every structural result,
   provided it records *that* a holder shape exists and not *which*.
5. **Vacuity / void witnesses.** Lean proof already exists
   (`lean/Defialgebra/Discharge.lean`). See the conflict in §4.

**Tier 3 — expensive, deferred, but universally wanted.**
6. **Magnitude.** Every school wants it; six rank it last on cost. Synthesis is the
   only one that can *bound the cost in advance* (`5^{k+1}`, `k ≤ 12`), which is a
   real argument for moving it earlier.

**Tier 4 — free once Tier 1 lands.**
7. **Level above the protocol** (curators, aggregators-of-aggregators). Category
   theory: the operad-of-wiring-diagrams level. Model theory: near zero, CASL
   parameterized specs give it. Type theory: "requires 1 and 2 first; then free."

---

## 4. Where they conflict — decisions we owe them

**4.1 — Do ports subsume scope, or does scope subsume ports?**
Sheaf theory says explicitly: *"Do not buy ported interfaces yet: with `𝒪` in place,
the nerve overlaps **are** the ports."* Category and type theory say ports first and
derive scope as an annotation on them. Both cannot be first. **This is the single
open design decision blocking Tier 1**, and it is cheap to settle empirically —
run both the colouring test and the blind live-set test and see which explains more
of `D` and more of the failure dissolution.

**4.2 — Void terms shrink `D`; order theory wants `D` to grow.**
Synthesis ranks void witnesses first and states the price exactly: widened heads
leave the definite fragment, so the 15-arc digraph shrinks — "D is thin already;
trade it." Order theory's entire programme is *increasing* arc density (target
`ι ≥ 0.10`, `height ≥ 4`). Direct tension. Likely resolution: void witnesses belong
in the *certificate* layer (where synthesis puts them) rather than in the requirement
head (where they cost definiteness) — but this needs adjudication.

**4.3 — Magnitude: last or second?**
Six schools defer it on cost; synthesis argues it is the only enrichment whose
complexity is boundable before paying. Not urgent, but the argument is good and
should not be lost.

---

## 5. The test battery — seven falsifiable tests, all days-scale

Every school was required to name one computation over the existing corpus that
would confirm or refute its structure within days. All seven complied, and several
made advance predictions specifically so they can fail.

| # | Test | Input | Confirms | Refutes |
|---|---|---|---|---|
| T1 | **Single-group rate** `ρ` (order) | 29-row table, `g : E → G` | `ρ ≥ 0.85` and sorted `D` ≥ 28 arcs, height ≥ 3 | `ρ < 0.6`; or `ι < 0.05` after completion — *this would refute the whole programme* |
| T2 | **`Pol(Adm)` to arity 3** (clone) | 72 seeds + blind-test set | some non-projection preserves `Adm` → composition operator exists on present carrier | only projections → enrichment forced *by proof* |
| T3 | **Blind live-set labelling** (sheaf) | 58 elements labelled blind into 5-chain | ≥70% dissolution, GYO residue ≤ 5 | <40% dissolution, or residue grows |
| T4 | **Scope test on X21** (type) | the 147 `X21`-arming pairs | ≥90% in disjoint atomic regions | <60% |
| T5 | **Beth redundancy scan** (model) | 60 decompositions, `O(60²·58)` | four known collisions split, none merge | any `e` with a separating pair that should not have one |
| T6 | **Colouring retrodiction** (category) | 58 elements + 29 rows + `D` | `D′ ⊇ D` acyclic; ≥80% of 72 sets wire totally | any arc of `D` contradicted |
| T7 | **Treewidth + DP** (synthesis) | `formal/v2/tables.mjs`, 60 ledgers | DP returns exactly **3,930** covers / **60** minimal; tw ≤ 12 | disagreement with 3,930/60, or tw > 20 after `[ext]` rows filled |

**T7 is the keystone**, because it validates against a number the prior work already
published by exhaustive enumeration. If the DP reproduces 3,930 and 60 exactly, the
whole encoding is validated at once. Synthesis has already measured `5 ≤ tw ≤ 8` on
the partially formalized system, with ~4 units of headroom per row filled.

**T1 and T3 carry advance predictions** (`ρ = 23/24 = 0.958`; 82.4% dissolution),
made before the test is run, which is what makes them real predictions.

**T2 is decisive either way** — that is its virtue. Verdict B discharges the
quarter's central design decision by proof rather than by preference.

---

## 6. What happens to the prior negative results

| Prior result | Disposition | Which school |
|---|---|---|
| Composition doesn't preserve admissibility | Localized to `∪` on a flat carrier; dissolves under scope | sheaf, type, clone |
| Positive theory excludes nothing (79 clauses, 0 exclusions) | Artefact of 15 empty rows; sorting restores binding power | order, sheaf |
| Structure/content tension (residual vs fitted `C`) | Warrant cycle at the wrong granularity; SCC-condense | order |
| Diagonal obstruction (bilattice / bounding pair) | *Becomes* the conservation law they said they couldn't state | category, type |
| Powerset collapse (Kripke–Kleene = `(⊥,⊤)`) | Never arises — construction is DP over a tree decomposition, not iteration from `⊥` | synthesis |
| Non-accessibility of `Adm` | Warrant 2-cycle; accessible on SCC condensation (Korte–Lovász shelling) | order |
| Maximum clique / perfection conjecture | **Retired as malformed** | clone, synthesis, sheaf |
| Convex geometry is "thin" (15 arcs / 58 vertices) | Floor from an unfinished table, not a ceiling; sorting doubles it | order, category |
| USDT/USD1 indistinguishable | `U` not faithful; refutes present `P` today; fixed by `Party` | model |
| "Obligation cannot arise" mis-scored | Vacuity certificate `T ⊸ 0`; Lean proof already exists | type, synthesis |

**Not one of the ten survives as an obstruction to the positive programme.** Each is
either localized to the flat carrier, converted into a computable invariant, or
retired as a malformed question.

---

## 7. Recommended sequence

1. **Settle §4.1** (ports vs scope primacy) by running **T3 and T6** — both are
   afternoon-scale and directly compare the two hypotheses.
2. **Run T7** — the keystone validation against 3,930/60.
3. **Run T2** — decisive either way, and it discharges the design decision by proof.
4. **Run T1, T4, T5** in parallel; each has an advance prediction on record.
5. **Apply Tier 1** (typed signature + stratum cell + horizon column).
6. **Reconcile the 15-vs-18 arc discrepancy** before quoting any density figure.
7. Re-derive completeness against model theory's four clauses — coverage,
   separation, Beth independence, conservativity — not against coverage alone.

---

## 8. The completeness theorem, as the seven would have us state it

Model theory's four-clause form is the one to adopt, because it is the only one
under which `P = {⊤}` is not trivially complete:

- **(C1) Coverage** — every application in the reference class is constructible
  from `P`.
- **(C2) Separation** — non-isomorphic applications receive non-isomorphic
  constructions. *Currently false* (USDT/USD1), and false until the `Party` sort
  lands. This is why `Party` is a necessary condition and not an improvement.
- **(C3) Independence** — no primitive is implicitly definable from the rest
  (Beth). Decidable on the corpus by T5.
- **(C4) Conservativity** — enrichment along `σ : Σ → Σ'` invalidates no prior
  verdict.

And the reference class is `Ref := Cl_Ops(β[C₆₀])` — the closure of the 60-application
corpus under a declared finite operation list, adequate relative to an independently
computed trace semantics `β`. Model theory's defence of the relativisation is the
right one: **functional completeness is always relative to a closure operator** —
Post's is relative to superposition — so relativising is not a weakening, it is the
only legal form of the claim. The independence of `β` from the element table is
load-bearing; without it the theorem is circular.
