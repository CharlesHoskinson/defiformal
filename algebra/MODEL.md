# The model

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

The ablation is the argument, and it is decisive:

| | discrimination |
|---|---|
| closure (requirements) alone | 2.45× |
| warrant (purpose) alone | 2.37× |
| **both** | **10.83×** |

Neither half works. The product does. The atlas was never under-specified — it
was **half-specified**, and we had been staring at one of the two halves.

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

## 5. Theorems worth proving

Ordered by what I would actually want to know.

**T1 — Do `γ` and `Δ` commute?**
`γΔ = Δγ`? If yes, the admissible sets form a lattice and composition is
well-behaved. If no, the failure is precisely the non-monotone pathology, and the
obstruction is a finite, computable set. **Either answer is a result**, and this
is the single highest-value open question the model raises.

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
