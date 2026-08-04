# Requirements on the mathematical foundation

Written **before** the council so the candidates are judged against a fixed
standard rather than the standard being fitted to whichever candidate wins.
Every requirement is a measured fact about our data, with the measurement named.

A foundation that fails **R1, R2 or R5** is out regardless of elegance.

---

## R1 — Validity is a diagonal, not a product *(hard)*
`Γ` is a closure (**inflationary**, `x ≤ Γ(x)`); `Δ` is a kernel
(**deflationary**, `Δ(x) ≤ x`). Admissible = `Fix(Γ) ∩ Fix(Δ)`. They point in
opposite directions *relative to the identity*.
**This has now killed three frameworks.** Bilattices: Avron's representation
theorem makes every interlaced bilattice a componentwise product, blind to a
diagonal. AFT: consistency forces `lower ≤ upper`, which chains to `Γ = Δ = id`.
Any framework whose objects are componentwise fails here.

## R2 — Mixed clause polarity *(hard)*
Requirements are **dual-Horn** (union-closed); prohibitions are **Horn**
(intersection-closed). Their conjunction is provably a lattice under neither
(Schaefer/Post). Measured: 34 element-expressible clauses, 31 requirement /
3 hazard, **exactly 17 bijunctive**, widest 5 literals (`L1: Pl → Li|Ad|Sl|Bs`).
So median algebras are out for the whole system and available on half of it.

## R3 — Non-monotone validity *(hard)*
Adding an element can satisfy a requirement and arm a prohibition at once.
Derived, not asserted: `{Ct,Im,Sh}` is a valid mandate; adding `Li` makes it a
mechanism, which must then supply a truth source, and it fails.

## R4 — A carrier richer than element sets *(hard)*
The requirement relation is a DAG with no self-loops, so **no set of element
types can contain a cycle** — yet the canonical failure is a cycle. Terra is a
2-cycle only over `(element, asset)` under `backs`; crvUSD, comparable element
set, has none. USDT/USD1 need a **party** sort. One forgetful functor has both
failures in its kernel. A policy/mandate sort is also required — a curator is a
policy *over* protocols, not a mechanism.

## R5 — Composition, with an honest boundary *(hard)*
`⊕` preserves observational equivalence (true by construction) and **does not
preserve validity** (witnesses on all four closures). We already have a
**union-closed fragment covering 47.8% of admissible sets that certifies 59% of
live protocol pairs with zero errors** — a join-semilattice, not a sublattice;
maximality open in [11026, 23055).
**The foundation must beat 59%, or explain why 59% is the ceiling.**

## R6 — Decidable at our scale, with stated complexity *(hard)*
58 atoms, 156 blind cases, 72 protocols. Membership is linear; completion is
NP-complete. 58 atoms is *below* the median (80) of the standard ADF benchmark
suite, so decision is not the risk — **enumeration** is. Any framework costing a
polynomial-hierarchy level must justify it.

## R7 — Explain the fragment pattern *(strong preference)*
Three independent measurements, same shape: definite fragment distributive while
the whole is not; union-closed fragment certifies 59% while the whole cannot;
half the clauses bijunctive while the whole is not. **Disjunctive width is always
what breaks it.** A foundation that predicts this rather than merely tolerating
it is worth substantially more.

## R8 — Actionable output *(strong preference)*
Three questions a user actually asks: *what am I missing* (closure), *what am I
carrying that nothing justifies* (kernel), *what is the minimal repair*. The
third we cannot currently answer at all.

## R9 — Prohibitions as first-class *(practical)*
Hazards must be global constraints, not conditions hand-pushed into per-element
formulas. Measured cost of getting this wrong: ADFs have no global constraint
construct, so every prohibition must be duplicated into acceptance formulas,
which can silently destroy bipolarity — and **bipolarity is worth a whole PH
level** (grounded/stable verification Σ₂ᵖ → P).

## R10 — Live tooling *(practical)*
Verified 2026-08-04: **clingo v5.8.0, repo committed today**; clasp 2026-07-31.
Every dedicated ADF solver is stale — k++adf last commit 2022-01, YADF v0.1.1
from 2018, goDIAMOND's URL 404s, BAss has zero releases. If a foundation has no
maintained implementation, we are writing the solver too, and that must be
priced in.

---

## Deliberately NOT required

- **A single unifying structure.** Three failures say the object is layered.
  A foundation may be a *pair* of structures plus a compatibility condition.
- **Total formalisation.** 52 of 77 requirement terms are prose. A foundation
  that only works once everything is formalised is modelling a system we do not
  have.
- **Covering off-chain reality.** Obligor, custody, register of record and legal
  recourse are out of scope by declaration, not by oversight.
