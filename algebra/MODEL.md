# The model

> **The running score lives in [`THEOREM-LEDGER.md`](THEOREM-LEDGER.md)** — proved, refuted, contested and open. Plain-English companion: [`PLAIN-ENGLISH.md`](PLAIN-ENGLISH.md).

Nine mathematicians, three schools, one problem. The useful model is not any one
of their answers — it is three of them stacked, and they stack cleanly because
each solves what the one below it cannot express.

---

## 1. The central idea: the atlas is half a specification

This is OP-ORD's finding and it reframes everything.

The 29 laws state what a mechanism **requires**. Nothing anywhere states what a
mechanism is **for**. Compute the Galois adjoint of the requirement relation and
you get 27 **warrant** rows — `Li → Ct`, `Tp → (Cp|Cl|St|Wg|Pm|Ob)`,
`As → (Ex|Tp|Oa|At)`. A liquidation mechanism is *for* a collateral test. A
time-weighted price is *for* a pool that needs one.

The ablation reproduces to the digit under independent re-implementation. **The
story I told about it does not.**

| | discrimination |
|---|---|
| closure `Γ` alone | 2.45× |
| warrant `Δ` alone | 2.37× |
| **`Γ ∧ Δ` — the two adjoints together** | **4.46×** |
| independence would predict | 5.79× |
| all four blocks (adds Ban+Cond, Ground) | **10.83×** |

**Correction, and it is mine.** I reported 10.83× as what the two adjoints
achieve together. It is not. `Γ ∧ Δ` is **4.46×**, which is *below* the 5.79×
independence would give — the two adjoints are **sub-multiplicative**, rejecting
35 of the same 84 negatives where independence predicts 31. More than half of
the 10.83× comes from **Ban+Cond and Ground**, two blocks this document never
mentioned.

So warrant is worth about **1.8× on top of closure**, not 4.4×. That is still a
real and useful contribution, and it is the single largest *conceptual* addition
— but "the product of two adjoints produces the number" is false, and the
half-specified framing oversells what the second adjoint buys.

**And `Δ` is not idempotent**, so it is not literally a kernel operator. The
closure/kernel pairing is the right intuition and the wrong algebra; state it as
a pair of monotone operators whose common fixed points we want, and stop calling
`Δ` a kernel until it is repaired.

One more, and it is uncomfortable: **the parser bug was doing discriminating
work.** Reference closure falls from 2.33× to 1.98× once the mixed terms are
fixed. Treating five disjunctions as hard requirements was accidentally encoding
constraints that are really there — which is why the corrected engine accepts
more junk. The fix was still correct; it just cost us discrimination we had not
earned.

## 2. The validity predicate

> **A protocol is admissible iff it is a fixed point of both a closure operator
> and a kernel operator.**
>
> `ADMISSIBLE(X) ⟺ γ(X) = X ∧ Δ(X) = X`
>
> where `γ` is requirement-closure (everything you need is present) and `Δ` is
> warrant-interior (everything present has something to be for).

`γ` is a closure operator: extensive, monotone, idempotent. `Δ` is its order
dual — a kernel/interior operator: contractive, monotone, idempotent. Admissible
sets are the common fixed points.

**Why this is prescriptive and the old predicate was not.** Closure alone answers
one question — *what am I missing?* The kernel answers the question no one was
asking: *what am I carrying that I cannot justify?* An unwarranted mechanism is a
mechanism present with nothing to serve. In security terms that is attack surface
with no compensating function, and it is exactly the shape of a protocol that
accreted features. The atlas could never say this before because it had no
vocabulary for purpose.

## 3. The carrier: three layers, each earning its keep

Do not pick one. Each layer exists because the one below it provably cannot
express something we need.

**Layer 1 — mechanism sets, as up-sets of a poset.** OP-LOG's result: split the
laws into 8 definite Horn *productions* and everything else as *constraints*. The
definite fragment has **height 1** — bodies and heads are disjoint — so `Cn` is a
one-pass Galois closure and the closed sets are exactly the up-sets of a
54-point dependency poset.

By Birkhoff duality that lattice is completely determined by the poset. **We do
not need 29 laws; we need a partial order on 54 points.** It is completely
distributive, `⊔ = Cn(∪)`, `⊓ = intersection`, verified over 3,140 closed sets.
This recovers the meet I had recorded as permanently lost — that failure was a
fact about disjunction, not about the lattice.

**Layer 2 — mandates.** OP-LOG's second sort. A curator, a vault, a strategy is a
*policy over* mechanisms, not a mechanism. This is what makes non-monotonicity
**derived rather than asserted**: `{Ct,Im,Sh}` is a valid mandate; add `Li` and
it becomes a mechanism, which must then supply a truth source, and it fails. The
sort test explains the pathology instead of stipulating it.

**Layer 3 — instances.** OP-CAT's typed graph over sorts `El, Ast, Dom, Prt, Mnd`.
Needed for exactly two things, both of which Layer 1 provably cannot do:
Terra's reflexive cycle, and the USDT/USD1 fibre.

## 4. Two impossibility results that are actually true

These are the interesting ones, because two entrants proved *opposite* things and
both are right — the difference is exactly the scope decision the brief forced
them to make.

**Reflexivity needs asset indexing.** S5 survives three independent
confirmations: the requirement relation is a DAG with no self-loops, so no set
of element *types* can contain a cycle. Over `El × Ast` under `backs := reads ; over⁻¹`,
Terra is a 2-cycle — and crvUSD, with a comparable element set, has none. The
control is what makes it a result rather than a construction.

**Solvency is not a function of on-chain mechanism.** OP-LOG bounded scope to
on-chain state machines and derived `USDT ≡ USD1` as a **theorem**. OP-CAT
enriched the carrier with a party sort and separated them. Both are correct.
Together they give the sharp statement:

> No observation over on-chain mechanism sets separates USDT from USD1. The
> minimal enrichment that does is a party sort carrying obligor, attester and
> jurisdiction.

That is D2, refined and true. It is also the most consequential thing this
project can say: the fibre is not a modelling sloppiness to be tidied — it is a
theorem that mechanism inventory does not determine credit.

---

## 4b. Why validity is non-monotone: a proof, not an observation

GR-LOG's result, and it is the deepest thing the council produced. Read the laws
as clauses and the polarities are opposite:

| | clause shape | model class |
|---|---|---|
| requirement (`subject → alternatives`) | at most one negative literal — **dual-Horn** | **union**-closed |
| hazard (exclusion) | pure negative — **Horn** | **intersection**-closed |

`ADMISSIBLE = CLOSURE ∩ HAZARD-FREE` mixes the two, so by Schaefer/Post duality
it is provably a lattice under **neither** operation.

This is the reason, not the symptom. I had recorded non-monotonicity as an
empirical fact from the model checker and asked the council to "deal with it";
it is a theorem about clause polarity, and it was derivable from the shape of the
law language without running anything. It also settles T1 below: `γ` and `Δ` do
not commute, because they are closure operators of opposite polarity.

It sharpens §5b too. Feature models were rated a near-exact structural fit —
`requires` constraints are dual-Horn, `excludes` constraints are Horn, and that
split is precisely why feature-model validity moves in both directions at once.
The fit was closer than the survey knew.

**Encoding note, so nobody builds this wrong.** The clause classification above is right — `subject → (a|b|c)` is `¬subject ∨ a ∨ b ∨ c`, one negative literal, hence dual-Horn. But the obvious ASP encoding is *not*: `a :- b` is a **definite Horn** rule that derives `a`, and is Horn, not dual-Horn. The union-closed half of the profile is carried by **choice rules** `{a} :- b.`, not by definite rules. Encode as choice rules plus constraints.

**And it corrects my own benchmark.** I built the HYBRID family as a
contamination probe, on the reasoning that spliced protocols cannot have been
memorised. It is also — and mostly — a **union-closure detector**: a union-closed
model class must accept splices, because a splice of closed sets is closed. GR-LOG
admits 57.9% of hybrids and correctly calls this "a structural consequence of
union-closure, not a fixable bug". So the hybrid column ranks models by how
union-closed they are, not by how honest they are. OP-CAT at 21% and OP-ORD at
16% are not less contaminated than GR-LOG at 58%; they are less union-closed.

## 4c. The fragments, reconciled — and one functor for two problems

Three entrants said things that sound contradictory and are not. Sorted by
fragment, they are one coherent picture:

| fragment | clause shape | closure behaviour |
|---|---|---|
| definite productions (8 laws) | Horn, height 1 | up-sets of a poset — union **and** intersection closed, completely distributive |
| disjunctive requirements | dual-Horn | union-closed only |
| hazard exclusions | Horn (pure negative) | intersection-closed only |
| all three together | mixed polarity | **neither** — and not a Moore family |

So OP-LOG's beautiful distributive lattice is real *on the definite fragment*,
and GR-CAT's finding that the full closed-set family is **not a Moore family** —
hence admits no single-valued Galois closure operator, with Terra exhibiting four
incomparable minimal completions — is also real, on the whole system. The
well-behaved algebra lives in the Horn core; the disjunctions and the
prohibitions are what break it, exactly as §4b's polarity argument predicts.

**Design consequence, and it is the prescriptive one.** If you want a composable
algebra, work in the definite fragment and treat disjunctive requirements and
hazards as an outer filter. You get a real lattice with `⊓ = intersection`
inside, and you pay for it precisely at the boundary — which is a bounded,
nameable cost rather than a diffuse one.

**One functor for two problems.** GR-CAT's cleanest result: the forgetful functor
`U : DecProt → Sub(E)`, from instances typed by `(element, asset)` pairs down to
flat element sets, has both of our headline failures **in its kernel**. USDT ≡
USD1, and Terra's cycle is invisible — not two defects but one, the same
information destroyed by the same forgetting. Anything you want to fix in either
is fixed by refusing to apply `U`.

This also explains the hazard failures. GR-CAT attempted four hazard promotions
and **withdrew all four** after testing them against the 72 real decompositions:
`{Fl,Xm}` (our own model checker's prize) flags Aave v3; X19 flags 14 of 72 live
protocols. Every failure traces to the same root — a flat element-set carrier
cannot say *which instance* co-occurs with which. Only X18 survived, with zero
false positives.

**`{Fl, Xm}` is dead as a membership predicate.** The council split 3–3, but the
split is not symmetric: the three who promoted it did so because our FINDINGS
recommended it, and the three who killed it had *tested it against the corpus*.
Evidence beats provenance. The narrowing `Fl ∧ (Xf|Rl|Of)` survives; the flat
version does not.

## 4d. AFT is out — and my first two reasons were both wrong

Three passes. Worth keeping all three, because the final argument is the useful one.

**Pass 1 (wrong).** "Both operators are monotone, so neither fills AFT's antitone
slot." **Refutable in one line:** `≤_p`-monotonicity unpacks to `A¹` monotone in
arg 1 and antitone in arg 2, and antitonicity is satisfied **vacuously by
constancy** — so `A(x,y) = (Γ(x), Δ(y))` with both monotone *is* `≤_p`-monotone.
DMT (KR2002, Prop 4.7) states outright that for monotone `O` the ultimate
approximator **is** the product `(O(x), O(y))`.

**Pass 2 (right to reopen, wrong conclusion).** `U_O` exists for any operator
with no hypotheses, so the framework is not blocked by our operators' shape.

**Pass 3 — the real obstruction, and it is stronger and simpler than either.**
Every AFT variant requires `A` to preserve **consistency**: `lower ≤ upper`. Take
`A(x,x) = (Γ(x), Δ(x))`. Consistency forces `Γ(x) ≤ Δ(x)`. But `Γ` is a closure,
so `x ≤ Γ(x)`; and `Δ` is a kernel, so `Δ(x) ≤ x`. Chain them:

> `Γ(x) ≤ Δ(x) ≤ x ≤ Γ(x)`  ⟹  `Γ = Δ = id`.

This holds for **any** `A`, product-form or not, and needs neither exactness nor
monotonicity. **AFT's lower slot must *under*-approximate; a closure
*over*-approximates. The assignment is backwards.** Swapping to
`A(x,y) = (Δ(x), Γ(y))` is legal but empty: `lfp(Δ) = ⊥` always, so the stable
operator is a **constant map** and `Δ` never appears in the answer.

**And that is exactly why candidate 1 is the right next move.** The obstruction
names our structure precisely: `Γ` is *inflationary* (`x ≤ Γ(x)`) and `Δ` is
*deflationary* (`Δ(x) ≤ x`). They point in opposite directions **relative to the
identity**, which is the diagonal picture stated algebraically. The theory of
`Fix(Γ) ∩ Fix(Δ)` for an inflationary and a deflationary map is common
fixed-point theory — not approximation theory, which wants both bounds on *one*
operator.

One escape hatch exists and does not save it: Charalambidis/Rondogiannis/Symeonidou
2018 and Vanbesien/Bogaerts/Denecker 2025 drop exactness entirely, but their
interlattice conditions still force `lower ⪯ upper`, so the polarity obstruction
survives. No non-monotone AFT variant exists.

## 5. Theorems worth proving

Ordered by what I would actually want to know.

**T1 — ANSWERED, by GR-LOG. They do not commute, and the reason is polarity.**
See §4b above. What remains is the quantitative version: the obstruction is a
finite computable set, so *enumerate it*. Which admissible sets fail to be fixed
points of both operators, and how many are there? That converts a structural
impossibility into a bounded list of exceptions.

**T2 — The congruence fragment.**
OP-LOG refuted X3: `⊕` is not a congruence for validity, with witnesses on all
four closures. Turn it around: *find the largest sublattice on which it is.*
This is the practically useful theorem — it says exactly which protocols compose
without re-analysis, which is the entire promise of composability.

**T3 — Birkhoff reduction.**
If Layer 1's closed sets are the up-sets of a 54-point poset, then the 29 laws
are redundant and the real object is that poset. Prove the reduction and exhibit
the Hasse diagram. **This would replace the law list with a partial order** — and
a partial order is drawable, which the law list never was.

**T4 — Warrant completeness, and the generator split.**
Conjecture: the elements with **no** warrant are exactly the primitive
generators. 27 of 58 have derived warrants; OP-LOG's typing gives 31 generators
and 27 dependents. If those two partitions coincide, C3 (independence) falls out
of the warrant structure for free rather than needing 58 separate proofs.

**T5 — Bound the non-monotone damage.**
OP-CAT: 4 of 44 conjuncts are non-monotone, so 91% of the algebra survives
composition. Prove the non-monotone part is exactly the fragment with
*conjunctive antecedents* — X19 is the witness — and that everything else is
union-closed. Then non-monotonicity is quarantined rather than pervasive.

**T6 — The scope dichotomy, stated once.**
Formalise §4: any algebra over on-chain mechanism sets satisfies `USDT ≡ USD1`;
any algebra separating them contains a party sort. No middle position exists.

---

## 6. What this makes the visualization

The model finally gives the atlas something to *do*, which is what it has been
missing since the first build. Four questions, each with a computable answer:

1. **What am I missing?** — closure. Already have it.
2. **What can I not justify?** — warrant. New, and the interesting one.
3. **What can I safely compose with?** — the T2 congruence fragment.
4. **What is unbuildable?** — hazards, corrected.

And T3 says the law list should be redrawn as a **54-point poset**, which is a
Hasse diagram — orderable, layerable, and finally an honest replacement for the
stratum column that two independent methods now say was never a rank.
