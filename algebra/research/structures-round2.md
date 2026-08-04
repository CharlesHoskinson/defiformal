# Structures, round 2 — matched against the measured six-point profile

Scope: structures the first survey (feature models, assume-guarantee contracts, FCA, open games, decorated cospans, institutions, semirings) missed. Judged against the measured profile, not against "DeFi".

**Method note / honesty caveat.** The session's WebSearch budget was exhausted at the outset, so every source below was reached by direct WebFetch of primary URLs, with DuckDuckGo's HTML endpoint used as a search proxy until it began returning 403. Several primary PDFs (O'Hearn–Pym 1999, Pawlak 1982, Calcagno–O'Hearn–Yang, the AFT lecture notes) could not be text-extracted. Everything unconfirmed is flagged inline and collected in the final section. No theorem below is stated from memory without a flag.

Recurring shorthand: **Γ** = the requirement closure operator, **Δ** = the "what is this element for" kernel/interior operator, **P1–P6** = the six profile points.

---

## 0. The finding that reframes P1 — your system is probably bijunctive, and the object you are missing is a median algebra

This is not one of the candidates you listed. It is the thing I would act on first, and it is cheap to check.

**Verified.** Schaefer's dichotomy gives six tractable polymorphisms; the relevant three are: Horn ⟺ closed under binary **min** (∧), dual-Horn ⟺ closed under binary **max** (∨), bijunctive (2-SAT-definable) ⟺ closed under the ternary **majority** operation `maj(x,y,z) = (x∧y)∨(x∧z)∨(y∧z)`. (Schaefer, "The complexity of satisfiability problems", STOC 1978; polymorphism restatement confirmed at <https://en.wikipedia.org/wiki/Schaefer%27s_dichotomy_theorem>.)

Now look at your two clause shapes:

- A requirement "X needs Y" over a **binary** requirement relation is `¬X ∨ Y` — a 2-clause.
- A prohibition "X and Y must never co-occur" is `¬X ∨ ¬Y` — a 2-clause.

If both are binary, the entire constraint system is **2-SAT**, i.e. bijunctive. You told me the requirement relation is a DAG — a *binary* relation. So the requirement side is binary by your own construction.

**Verified consequence.** The solution set of a 2-SAT instance is closed under coordinatewise majority and carries the structure of a **median graph**: "The set of all solutions to a 2-satisfiability instance has the structure of a median graph… The median of any three solutions is formed by setting each variable to the value it holds in the majority of the three solutions. This median always forms another solution to the instance." (<https://en.wikipedia.org/wiki/2-satisfiability>, "The set of all solutions", citing Bandelt & Chepoi 2008 and Chung, Graham & Saks 1989. I reached the primaries only through this citation — see final section.)

**Why this matters more than anything else in this document.** Your P1 says validity is "a lattice under neither" polarity. That is correct and it is also *only the negative half of the statement*. The positive half is that a family closed under neither min nor max can still be closed under **majority** — and majority-closed subsets of the Boolean cube are exactly **median algebras**, a genuinely rich structure (Isbell; Bandelt–Hedlíková; equivalent to CAT(0) cube complexes; retracts of hypercubes) with canonical representation theory, a convexity theory, and linear-time algorithmics. You have been looking for a weakening of "lattice" in the direction of category theory. The weakening you actually need is one step sideways in universal algebra: **lattice → median algebra**. A distributive lattice is a median algebra (with `maj(x,y,z) = (x∧y)∨(x∧z)∨(y∧z)`); median algebras are what survives when you drop the two binary operations and keep only the ternary one. That is *precisely* the "closed under neither ∧ nor ∨" situation.

**The sharp dichotomy this creates, and the one question you must answer.** It turns entirely on the **arity of the consequent** — i.e. on Δ, and on whether a requirement can be satisfied by *any one of several* alternatives.

- **Arity 1 (single-valued purpose).** Each element serves one designated thing, so Δ is `¬x ∨ y` and Γ is `¬x ∨ y`; prohibitions are `¬x ∨ ¬y`. Every clause is a 2-clause, so the system is **bijunctive**. Validity is a **median algebra**; satisfiability and structure enumeration are **linear time**. Note this is bijunctive, *not* the smaller class `IM2` discussed below: `(¬x ∨ ¬y)` has two negative literals so it is not an implication, and prohibitions therefore sit in `ID2 ∖ IM2`.
- **Arity ≥ 2 (disjunctive purpose).** "Element x is allowed only if *any one of* y₁…y_k is present" is `¬x ∨ y₁ ∨ … ∨ y_k` with `k ≥ 2`. **Verified**: this relation is dual-Horn but **not bijunctive** — witness `(1,0,1), (1,1,0), (0,0,0)` are all models of `¬x ∨ y₁ ∨ y₂` but their coordinatewise majority `(1,0,0)` is not, so `maj` is not a polymorphism. Combined with prohibitions `(¬x ∨ ¬y)`, which are Horn and bijunctive but **not** dual-Horn, the language lies in none of Schaefer's tractable cases (not Horn, not dual-Horn, not bijunctive, not affine), so **SAT is NP-complete**. The direct witness is stark: **graph k-colourability is exactly your profile** — variables `x_{v,c}`, requirement clauses `⋁_c x_{v,c}` (all-positive, dual-Horn), prohibition clauses `¬x_{u,c} ∨ ¬x_{v,c}` per edge (Horn). "Can I extend this to a valid configuration" *is* graph colouring. (Schaefer, STOC 1978, <https://dl.acm.org/doi/10.1145/800133.804350>.)

So: **is an element's purpose single-valued or disjunctive?** That one modelling decision determines whether your object is a median algebra with linear-time algorithms or an NP-complete constraint system with no structure theory at all. Nothing else in this document is as consequential.

Note that P3 (non-monotonicity) is *entirely consistent* with bijunctivity — 2-SAT solution sets are not upward closed, and majority-closure says nothing about monotonicity. **P1 and P3 together are the signature of a median algebra, not an obstruction to one.**

### The related trap: two different objects you may be conflating

This came out of the clone-theoretic lane and is worth stating separately, because the distinction is easy to lose and one half of it is tractable.

- **A family closed under both ∪ and ∩** is a sublattice of `2^E`, hence *distributive*, hence Birkhoff-representable. **Verified**: the co-clone `Inv({∧,∨})` is `IM2`, whose **plain base is exactly `{(x), (¬x), (¬x ∨ y)}`** — unit clauses and implications, nothing else (Creignou, Kolaitis & Zanuttini, "Structure identification of Boolean relations and plain bases for co-clones", *JCSS* 74(7) 2008, Table 2; <https://users.soe.ucsc.edu/~kolaitis/bio11/papers11/jcss08-creignou.pdf>). Equivalently: such a family is the family of **up-sets of a quasi-order on the elements**, restricted by fixed literals. That is the Birkhoff picture in logical clothing. Note `IM2 ⊊ ID2 = bijunctive`, since `maj` is built from `∧` and `∨` — Horn-∧-dual-Horn is *strictly stronger* than 2-SAT.
- **The intersection of a ∪-closed family with a ∩-closed family** — which is what you actually have — is `Mod(dual-Horn ∧ Horn)`, closed under **neither**, carrying **no polymorphism and therefore no structure theory**. There is **no name for this in the literature**, and the lane searched for one. The reason there is no name is that in clone theory the object is degenerate: `Inv(∅)`.

Your P1 is therefore right but understated. It is not merely "not a lattice"; with disjunctive requirements it is the *structureless* case. Your escape hatch — and it is the only lattice-theoretic one — is to give up multi-consequent requirements and land in `IM2`, where everything is distributive, poly-time and Birkhoff-representable. The middle road is arity-1 requirements *with* prohibitions, which lands in bijunctive/median. **Three regimes, and you get to choose which one you model in.**

---

## 1. Approximation Fixpoint Theory (Denecker–Marek–Truszczyński) — the strongest single candidate

Not on your list. It is the algebraic theory that sits underneath three of the things you *did* list (bilattices, ASP, default logic) and it was built to solve exactly your P2 and P3.

**Definition (verified).** AFT works on the bilattice `L²` of *approximations* — pairs `(x, y)` read as lower and upper bounds — ordered by the **precision order** `(a₁,a₂) ≤_p (b₁,b₂)` iff `a₁ ≤ b₁` and `a₂ ≥ b₂`. An **approximator** `A : L² → L²` approximates an operator `O` on `L`; it is *exact* when `A(a,a) = (O(a), O(a))`, and *consistent* when it maps consistent pairs (`a ≤ b`) to consistent pairs. (Definitions confirmed from the restatement in "A Category-Theoretic Perspective on Approximation Fixpoint Theory", <https://arxiv.org/pdf/2502.09234>; I could not text-extract the DMT originals — see final section.)

**The property that makes this the candidate.** *A is required to be monotone with respect to ≤_p even when the underlying operator O on L is non-monotone.* That is the whole trick: AFT does not tolerate non-monotonicity, it **converts** it — a non-monotone operator on `L` is replaced by a monotone operator on `L²`, so Knaster–Tarski applies and you get a canonical least fixpoint back. From one approximator you get three semantics uniformly: the **Kripke–Kleene** fixpoint (least fixpoint of `A` under `≤_p`), the **stable** operator, and the **well-founded** fixpoint.

**Verified theorem (abstract quoted verbatim).** Denecker, Marek & Truszczyński, "Ultimate approximations in nonmonotonic knowledge representation systems", <https://arxiv.org/abs/cs/0205014> (journal version: *Information and Computation* 192(1), 2004):

> "We study fixpoints of operators on lattices. To this end we introduce the notion of an approximation of an operator. We order approximations by means of a precision ordering. We show that each lattice operator O has a unique most precise or ultimate approximation. We demonstrate that fixpoints of this ultimate approximation provide useful insights into fixpoints of the operator O. We apply our theory to logic programming and introduce the ultimate Kripke-Kleene, well-founded and stable semantics. We show that the ultimate Kripke-Kleene and well-founded semantics are more precise then their standard counterparts We argue that ultimate semantics for logic programming have attractive epistemological properties and that, while in general they are computationally more complex than the standard semantics, for many classes of theories, their complexity is no worse."

The **ultimate approximation** result is the one to lean on: you do not have to invent an approximator for your Γ/Δ system: *every* lattice operator has a canonical most-precise one.

**Composition — and this is the part that speaks directly to P4.** Vennekens, Gilis & Denecker, "Splitting an operator: Algebraic modularity results for logics with fixpoint semantics", <https://arxiv.org/abs/cs/0405002> (ACM TOCL, 2006). Verified from the abstract page: it presents "a general, algebraic splitting theory for logics with a fixpoint semantics", dividing programs "into distinct computational levels" so that "models of the entire program can be constructed by incrementally constructing models for each level", and it generalises the splitting results for logic programming, autoepistemic logic and default logic under a single approximation-theoretic roof.

**The formal statements are now verified from the v2 PDF, and they are stronger than the abstract suggests:**

> **Definition 3.3.** An operator `O` on a product lattice `L` is **stratifiable** iff `∀x,y ∈ L, ∀i ∈ I`: if `x|⪯i = y|⪯i` then `O(x)|⪯i = O(y)|⪯i`.
>
> **Proposition 3.4.** Stratifiability is equivalent to the existence, for each `i` and each `u ∈ L|≺i`, of a unique component operator `O_i^u` on `L_i` with `(O(x))(i) = O_i^u(x(i))` whenever `x|≺i = u`.
>
> **Theorem 3.5.** `x` is a fixpoint of `O` **iff** `∀i ∈ I`: `x(i)` is a fixpoint of `O_i^{x|≺i}`.

Propositions 3.6/3.7 lift this to least fixpoints for monotone `O`. §4.1.3 states explicitly that Lifschitz & Turner (1994) proved a splitting theorem for logic programs under stable model semantics, that Eiter et al. (1997) obtained similar results independently, and that VGD are more general in also covering supported, Kripke–Kleene and well-founded semantics.

**This is your P4 and P5 in one theorem, and it is a characterisation rather than an obstacle.** Theorem 3.5 is an **iff**: fixpoints decompose across a split **exactly when** the operator is stratifiable, and Definition 3.3 says stratifiability means lower strata do not depend on higher ones — i.e. **no cyclic dependency across the interface**. So P4 (composition does not preserve validity) is neither a defect of the framework nor a brute empirical fact: **it is the failure of Definition 3.3, and your witnesses are precisely the non-stratifiable compositions.** P5 explains *why* they are non-stratifiable — the `backs` relation cycles at the instance level, invisibly to the type-level DAG. One citable algebraic account of both points, and no other candidate in this document produces one.

**Where it stands on the six points.**
- **P1** — partial. AFT does not itself supply two opposite-polarity closure operators; it supplies the bilattice `L²` in which a lower and an upper operator live *independently* (unlike rough sets, where they are forced duals). Your Γ and Δ are naturally the two components of an approximator.
- **P2** — strong. "Common fixed points of a closure and a kernel" is literally a fixpoint of an operator on `L²`. This is the native object.
- **P3** — strong, and uniquely so. This is the only candidate that handles non-monotonicity by construction rather than by accident.
- **P4** — strong, as an *explanation*: the splitting theorem tells you precisely when composition preserves and why yours does not.
- **P5** — neutral. AFT is agnostic about the carrier lattice; put `(element, asset)` instances in `L` and it does not object, but it contributes nothing to detecting the cycle.
- **P6** — fails. No sort structure.

**Decidability & tooling.** Stable-model reasoning for normal programs is NP-complete territory; DMT note ultimate semantics are "in general computationally more complex than the standard semantics" though "for many classes of theories, their complexity is no worse" (quoted above). Tooling is real and maintained: **IDP-Z3**, a KU Leuven knowledge-base engine implementing **FO(·)/FO-dot**, extending first-order logic with "types, aggregates, inductive definitions, bounded arithmetic, partial functions" (<https://www.idp-z3.be/>, docs at <https://docs.idp-z3.be/>), plus clingo/Potassco on the ASP side. The inductive-definition semantics of FO(ID) is the AFT well-founded fixpoint — *I did not confirm that link on the pages I fetched*.

**Verdict: AFT fits P2, P3 and P4 better than anything else surveyed in either round, is neutral on P1 and P5, and fails P6. It is the only candidate whose central theorem explains your measured non-preservation rather than contradicting it.**

---

## 2. Abstract Dialectical Frameworks (Brewka & Woltran) — AFT with your two polarities already built in

Also not on your list, and it is the concrete instance of AFT you want.

**Definition (verified).** An ADF is `D = (S, L, C)` with `S` statements, `L ⊆ S × S` links, and `C` assigning each statement `s` an **acceptance condition** `C_s`, a Boolean function over the parents of `s`. (Brewka, Ellmauthaler, Strass, Wallner & Woltran, "Abstract Dialectical Frameworks Revisited", IJCAI 2013, <https://www.ijcai.org/Proceedings/13/Papers/125.pdf>.)

**The two polarities are native and independent.** In bipolar ADFs links are classified into four kinds — **attacking**, **supporting**, **redundant**, and **dependent** — and a single link may be attacking, supporting, both, or neither, depending on how the acceptance condition uses that parent. This is exactly your requirement/prohibition split, not forced into a de Morgan duality (contrast rough sets, §5) and not collapsed into a single polarity (contrast Petri nets, §7). "X needs Y" and "X and Y never co-occur" are both just clauses in `C_X`.

**Non-monotonicity is native, by the AFT mechanism.** Verified from the IJCAI paper: the characteristic operator `Γ_D` on three-valued interpretations "is monotone with respect to the information order even though acceptance" conditions are arbitrary Boolean functions and hence individually non-monotone. Semantics: complete = fixpoints of `Γ_D`, grounded = least complete, preferred = maximal complete, plus admissible and stable.

**The AFT link is a published theorem, not my inference.** Strass, "Approximating operators and semantics for abstract dialectical frameworks", *Artificial Intelligence* (2013), <https://doi.org/10.1016/j.artint.2013.09.004> — verified as giving "a principled and uniform reconstruction of the semantics of abstract dialectical frameworks by embedding them into the approximation operator framework of Denecker, Marek and Truszczynski", and showing many Dung-AF and ADF semantics arise as "direct applications" of AFT.

**Six points.** P1 ✔ (native, independent). P2 ✔ (via AFT). P3 ✔ (native). P4 — no composition theorem found; ADFs inherit AFT's splitting, *unverified*. P5 ✘ (flat statement set; you would index by hand). P6 ✘ (no sorts).

**Decidability & tooling.** ADF reasoning is "one level up in the polynomial hierarchy compared to AFs" (verified phrasing; exact per-semantics bounds *unverified* — an earlier fetch returned a "PSPACE-complete" claim I believe to be a summariser artefact and am discarding). Solvers exist (DIAMOND, YADF, k++ADF, QADF) — *I did not verify their current maintenance status*.

**Verdict: ADFs fit P1, P2 and P3 natively and fail P5 and P6. If you want a running implementation of the closure+kernel model tomorrow, this is the shortest path; it is AFT with the bipolarity pre-installed.**

---

## 2b. Answer set programming — passes P1, P2, P3, P5; and its P4 story is AFT's

**The reduct (verbatim,** Lifschitz, *Twelve Definitions of a Stable Model*, <https://www.cs.utexas.edu/~vl/papers/12defs.pdf>, §5 "Definition C"**).** The reduct of Π relative to a set `M` of atoms is obtained from Π by grounding, then *(i) dropping each rule containing a term `not A_i` with `A_i ∈ M`, and (ii) dropping the negative parts `not A_{m+1},…,not A_n` from the bodies of the remaining rules.* `M` is a stable model iff the minimal model of the reduct w.r.t. `M` equals `M`. Attributed to Gelfond & Lifschitz 1988, independently invented by Fine 1989.

**Correct your framing of the two polarities — this matters.** You wrote that requirements are rules and prohibitions are constraints. Half right. `a :- b` is a **definite Horn** rule: it *derives* `a`; it is not dual-Horn. Integrity constraints `:- a, b.` are exactly your prohibitions. But if "X needs Y" is a *constraint on admissible sets* rather than a derivation, its ASP form is `:- x, not y.` — also a constraint. The union-closed/generative half of your profile is carried by **choice rules** `{a} :- b.`, not by `a :- b`. So ASP does hold both polarities in one program, but the mapping is **choice rules + constraints**, not rules + constraints. Anyone who tells you "requirements are rules, prohibitions are constraints" has conflated derivation with admissibility, and will build the wrong encoding.

**Non-monotonicity (P3): native and exact.** Adding `a` to a candidate `M` changes the reduct — clause (i) deletes rules — so the minimal model of the reduct is not monotone in `M`. "Adding an element satisfies a requirement and arms a prohibition simultaneously" is the textbook shape of this.

**Stratification.** Same source, §2.2, verbatim: stratified = programs in which "recursion and negation *don't mix*"; the semantics is the **iterated least fixpoint**, and "to prove the soundness of this definition one needs to show that this fixpoint doesn't depend on the choice of a stratification." Stable model semantics is presented as a generalisation and simplification of that. The standard corollary — every stratified normal program has exactly one stable model, its perfect model — is *standard but was not quoted from a primary source this session*.

**P5 comes for free.** First-order ASP with variables grounds over instances, so `backs(E,A)` plus a recursive reachability predicate detects cycles over `(element, asset)` pairs even though the type-level requirement relation is a DAG. The cycle detector is a *positive* recursive definition, hence stratified below the negation layer — no semantic cost.

**P6 is the weak spot.** ASP is many-sorted only by convention. A "policy over mechanisms" requires **reification**: naming mechanisms as terms and writing meta-rules over those names (clingo's meta-programming / `--output=reify`). Workable, ugly, not native.

**Tooling** is the most mature of any candidate here: clingo/gringo/clasp (Potassco) and DLV. Complexity (NP-complete for normal, Σ₂ᵖ-complete for disjunctive) is standard but *was not verified from a primary source this session*.

**Verdict: ASP handles P1, P2, P3 and P5 natively, needs reification for P6, and its P4 behaviour is exactly AFT's — composition preserves stable models only under the stratifiability side condition of VGD Definition 3.3, which is what your witnesses violate. This is the pragmatic implementation route; AFT is the theory of why it behaves as it does.**

---

## 2c. Bilattices — refuted by the representation theorem you hoped would help

You thought the two independent axes might fit. The theorem that makes bilattices tractable is the same theorem that disqualifies them.

**Definition (verified,** Avron, *The Structure of Interlaced Bilattices*, <https://www.cs.tau.ac.il/~aa/articles/interlaced.pdf>, Def. 1.1**).** An interlaced bilattice is `B = ⟨B, ≤_t, ≤_k, ∧, ∨, ⊗, ⊕, t, f, ⊤, ⊥⟩` where `⟨B,≤_t,∧,∨,t,f⟩` and `⟨B,≤_k,⊗,⊕,⊤,⊥⟩` are bounded lattices and **all four operations are order-preserving with respect to both orders**. Def. 1.3: negation is `≤_k`-order-preserving and a `≤_t`-involution.

**The product construction (Def. 1.4).** `L⊙R` has carrier `L×R` with `(a₁,b₁) ≤_k (a₂,b₂) ⟺ a₁≤_L a₂ ∧ b₁≤_R b₂` and `(a₁,b₁) ≤_t (a₂,b₂) ⟺ a₁≤_L a₂ ∧ b₂≤_R b₁`.

**Theorem 3.3 (verified).** *If `B` is an interlaced bilattice then there are bounded lattices `L, R` such that `B ≅ L⊙R`, and these are unique up to isomorphism.* The witnesses are canonical: `L_B = {x | x ≥_t ⊥}`, `R_B = {x | x ≤_t ⊥}`, with isomorphism `g(x) = (x∨⊥, x∧⊥)`. **Proposition 3.7**: with negation, `⟨B,¬⟩ ≅ L⊙L` under `¬(x,y) = (y,x)`. Avron's abstract: *"every interlaced bilattice is isomorphic to the Ginsberg-Fitting product of two bounded lattices."*

**Why this kills it.** Your Γ and Δ act on **one** powerset `2^E`, and validity is `Fix(Γ) ∩ Fix(Δ)`. Set `L = Fix(Γ)` and `R = Fix(Δ)`; `L⊙R` is a legitimate interlaced bilattice — but its elements are **pairs** `(closed set, open set)` with **no constraint that the two coordinates be the same set**, and both orders are computed componentwise. The object you care about is the **diagonal** of that product, and the representation theorem guarantees the structure is componentwise and therefore blind to it. Worse: your P1 says validity is a lattice under *neither* order; a bilattice makes it a lattice under **both**. That is not modelling your problem, it is assuming it away.

**And the non-monotonicity argument you were counting on belongs to AFT, not here.** Bilattices per se handle nothing non-monotone. What does the work is an operator theory built *on* a bilattice — Fitting's `Φ_P` being `≤_k`-monotone despite negation. That construction is exactly what AFT abstracts (§1); `L²` under `≤_p` *is* an interlaced bilattice by Avron's Def. 1.4, which is the only real link between the two candidates. Fitting's own wording could not be retrieved (melvinfitting.org serves a mismatched TLS certificate) — *unverified*, and confirmed only indirectly through AFT.

**Composition:** the product constructs *bilattices*, not compositions of models. No theorem of the form "validity of `B₁` and `B₂` implies validity of `B₁∘B₂`". Nothing for P4. **Tooling:** Arieli–Avron bilattice logics have proof systems; no mainstream solver. Effectively zero.

**Verdict: fails P1 (the representation theorem forces a componentwise product, erasing the non-lattice diagonal that is your validity set), P4 and P6, and supplies P3 only by borrowing AFT. Drop it — and take the carrier `L²` with you, since that is the part that was doing the work.**

---

## 3. Formal topology, specifically Sambin's *positive topologies* — the only framework where Γ and Δ are independent primitive data

You listed this as an afterthought alongside Chu spaces. It is the serious half of that pairing.

**Definition (verified).** A formal topology is a cover relation `a ◁ U` between basic opens and subsets, satisfying reflexivity, transitivity, left/right meet and top (Coquand, Sambin, Smith & Valentini, "Inductively generated formal topologies", *APAL* 124 (2003); PDF at <https://www.math.unipd.it/~sambin/txt/tig000615.pdf> — could not text-extract; definition taken from <https://ncatlab.org/nlab/show/formal+topology>).

The companion is the **binary positivity relation** `a ⋉ V`: "there is a point in the basic open `a` whose basic neighbourhoods are all in `V`". A **positive topology** carries *both* an **inductively generated** cover and a **coinductively generated** positivity, linked by the compatibility axiom

> `a ⋉ V`, `a ◁ U` ⟹ `∃x ∈ A (x ⋉ V and x ε U)`

with **fixpoints of ◁ = formal opens (a closure operator)** and **fixpoints of ⋉ = formal closeds (an interior/kernel operator)**. (Maietti, Maschio & Rathjen, <https://arxiv.org/abs/2103.16592>, text extracted via ar5iv. Book-length primary: Sambin, *Positive Topology: A New Practice in Constructive Mathematics*, OUP, <https://global.oup.com/academic/product/positive-topology-9780199232888> — described there as "a set equipped with two particular relations between elements and subsets of that set: a convergent cover relation and a positivity relation".)

This is P2 stated as a definition rather than derived: common fixed points of an inductively generated closure and a coinductively generated kernel, with a compatibility law relating them. And the generation modes map onto your semantics without strain — Γ is *inductively* generated from your requirement DAG (an axiom-set), Δ is *coinductively* generated from your "serves" relation. That is the right polarity for each.

**The caveat that decides whether you can use it.** Verified verbatim from Maietti–Maschio–Rathjen: *"Classically, a positivity relation can be associated to any basic cover in the form `a ⋉ V ≡ ¬ a ◁ ¬V` but constructively one needs to add a primitive operator."* So **classically, positivity collapses into the de Morgan dual of cover** — the exact failure mode that kills rough sets. Formal topology gives you two genuinely independent operators **only if you work constructively/predicatively**, taking `⋉` as primitive data linked to `◁` by compatibility alone. That is not a technicality; it is the entire reason to choose this framework, and it commits you to intuitionistic logic.

**Bonus for P5.** A **basic pair** `(X, ⊩, S)` (Maschio & Sambin, <https://arxiv.org/abs/1611.03078>) is two-sorted by definition — concrete points `X`, formal indices `S`, relation `⊩` — and its induced operators `◇D = {a ∈ S | ext a ≬ D}`, `□D = {a ∈ S | ext a ⊆ D}` are *literally* Yao's generalised rough approximations relativised to a relation between two different sets. So rough set theory turns out to be a degenerate special case sitting **inside the basic-pair layer of formal topology, one level below where the independent Γ/Δ pair lives**. That is the cleanest available argument for preferring this over rough sets, and it answers your rough-set question by subsumption.

**Six points.** P1 ✔ (constructively). P2 ✔ (definitional). P3 ✘ — both `◁` and `⋉` are monotone in the subset argument by axiom; nothing models "one addition satisfies a requirement and arms a prohibition". P4 ✘/unverified — no source found on whether positivity is preserved by products; point-free products are locale products, which *do* preserve frame structure, i.e. the wrong direction for you. P5 ✔ (two-sorted natively). P6 ✘ (two sorts only). Tooling: type-theoretic formalisations exist in the Minimalist-Foundation / Martin-Löf line; **no decision procedure or checker found**.

**Verdict: the only framework surveyed in which your Γ and Δ are independent primitive data with a compatibility law, matching P1, P2 and P5 — and it fails P3, P4 and P6, and charges you intuitionistic logic as the price of admission.**

---

## 4. Displayed categories + coloured operads — the light answer to P5 and P6

You asked for a lighter fibration account than institutions. Here it is, in two pieces.

**P5 — displayed categories, and the name for your forgetful functor.** A Grothendieck fibration requires cartesian lifts (Grothendieck, SGA1 Exp. VI; <https://ncatlab.org/nlab/show/Grothendieck+fibration>). You almost certainly cannot produce them — there is no canonical way to restrict a mechanism along an arbitrary asset map — and a fibration you cannot cleave buys nothing. Take instead **displayed categories** (Ahrens & Lumsdaine, "Displayed Categories", *LMCS* 15(1), 2019, <https://arxiv.org/abs/1705.04296>), which index objects and morphisms of `D` *directly by* those of `C` with no lifting obligation, and — from the abstract — avoid the equality-on-objects that the functorial definition of a fibration smuggles in. Formalised in Coq/UniMath.

More useful still, **your P5 has a standard name.** A **concrete category** is one equipped with a *faithful* functor `U : C → Set`; a category admitting none is **not concretizable** (verified, <https://ncatlab.org/nlab/show/concrete+category>). The canonical precedent is **Freyd, "Homotopy is not concrete", in *The Steenrod Algebra and its Applications*, LNM 168, Springer (1970)** — verified — showing `Ho(Top)` admits no faithful functor to `Set` even though it is a quotient of the concretizable `Top`. That is structurally *identical* to your situation: flat sets are a quotient of the indexed structure, and the quotient destroys the cycle. The companion notion is an **amnestic** functor; your two near-identical assets are precisely an amnesticity failure. So the sentence you want is: *"the category of protocol configurations is not concretizable over Set; the forgetful functor to flat element sets is neither faithful nor amnestic, and both the backing cycle and the USDT/USD1 identification lie in its kernel."*

**P6 — a curator is an n-ary morphism of a coloured operad.** Spivak, "The operad of wiring diagrams", <https://arxiv.org/abs/1305.0297>. Warning 2.1.1 states he means "a symmetric colored operad or a symmetric multicategory"; Example 2.1.7 gives morphisms `X₁,…,Xₙ → Y` as cospans `X₁+⋯+Xₙ → C ← Y` with `C` the set of *cables*; Example 4.1.1 gives the **typed** version, objects being pairs `(X, τ : X → Ob(Set))` with type-matching at solder points. Definition 2.2.5: "An algebra on O is an operad functor `R : O → Sets`".

A vault taking `n` protocols and yielding a composite **is** an `n`-ary morphism `φ : (M₁,…,Mₙ) → V`. Mechanisms are colours; policies are multi-morphisms. The sort stratification you are missing is built into the operad's own type discipline — objects versus multi-morphisms — with no 2-categorical or institutional apparatus. Lighter than a double category, far lighter than an institution.

**The trap, and the fix.** An operad algebra is a *strict* functor, with an identity law and a composition law. If you make validity membership in the algebra's value set, wiring valid mechanisms together **forces** the composite valid — exactly what your P4 disproves. The fix is clean and you should adopt it: **model observational behaviour as the algebra, and validity as a non-algebraic predicate over it.** Spivak's `Rel_A` (Example 2.2.10) assigns each star the set of relations of that type and composes them along wiring diagrams — which is precisely your "composition preserves observational equivalence". Put validity in the algebra and the operad contradicts your measurements; keep it outside and the operad models the half of P4 that *is* true. (Lax algebras would relax the strictness, but I found no usable primary treatment over the WD operad — *unverified*.)

**Verdict: displayed categories name and formalise P5 (with "not concretizable over Set" as the precise, citable diagnosis), and a typed coloured operad gives P6 cleanly and lightly. Both are silent on P1–P3. Neither competes with AFT; they compose with it.**

---

## 5. Rough set theory — refuted, at the definition

Your hypothesis was that lower/upper approximation is "literally a kernel/closure pair on the same set". It is, and that is the problem: it is *one* operator presented twice.

**Definition and the disqualifying axiom (verified).** `R̲X = ⋃{[x]_R : [x]_R ⊆ X}`, `R̄X = ⋃{[x]_R : [x]_R ∩ X ≠ ∅}` (Pawlak 1982 is paywalled; definitions taken from the open-access restatement in "On twelve types of covering-based rough sets", <https://pmc.ncbi.nlm.nih.gov/articles/PMC4937015/>). That same paper lists **duality — `R̲(¬X) = ¬R̄(X)` — as an axiom (8_LH) of the classical theory**, not an incidental fact. Yao's generalisation to an arbitrary binary relation (<https://www2.cs.uregina.ca/~yyao/PAPERS/approximation_ks.pdf>) keeps the shape: lower = "all R-successors inside X", upper = "some R-successor in X". These are `□` and `◇` of a Kripke frame.

**So: knowing Γ determines Δ completely.** There is only one relation in an approximation space. You cannot encode "what a set requires" and "what an element is for" as two independent relations. **P1 and P2 fail outright.**

**Does the covering generalisation decouple them? Only by breaking them.** Huang & Zhu, <https://arxiv.org/abs/1210.0074>, enumerate five covering operators and state explicitly that "SH and SL, and XL and XH … are dual, respectively"; only `XL` is an interior operator and only `XH` a closure operator. The operators that lose duality lose idempotence or extensivity instead — you get a badly-behaved non-closure, not a second independent closure. Li & Zhu (<https://arxiv.org/abs/1209.5569>) show fixed-point sets of a single lower approximation form complete distributive lattices or Boolean algebras — lattice-structured, which P1 says yours provably is not.

**Boundary region ≠ your residue.** `BN(X) = R̄X \ R̲X` is *epistemic uncertainty about membership* — objects the granularity cannot classify. Nothing in the theory says a nonempty boundary is **invalid**; it says the set is *rough*, and quantifies it with accuracy `|R̲X|/|R̄X|`. You need a validity predicate; rough sets give a vagueness measure.

**Non-monotonicity: no.** Both approximations are monotone in `X` by standard axiom. (Tellingly, Çaksu Güler, <https://arxiv.org/abs/2411.04133>, advertises "preserve the monotonic property" as a *selling point* of a new model.) **P3 fails.**

**Composition: nothing found.** arXiv sweeps on covering-based rough sets and approximation operators (45 hits across two queries) returned matroid structures, lattice structures, boolean-matrix axiomatisations, attribute reduction and fuzzy variants — **zero** papers on products of approximation spaces. Treat as *unverified absence*, but this is a data-analysis tradition, not a compositional one. **P4 fails by having nothing to say.** P5, P6 fail — one universe, one relation, no sorts.

**Tooling** is mature but aimed elsewhere: ROSETTA (<https://bioinf.icm.uu.se/rosetta/>), R.ROSETTA, RSES (<https://www.mimuw.edu.pl/~szczuka/rses/start.html>). These compute reducts and decision rules from data tables. No model checker, no validity prover.

**Verdict: fails P1, P2, P3, P4, P5 and P6. Its two operators are de Morgan conjugates of a single relation by construction; the generalisations that break duality break the operator instead. And it is subsumed — see §3, where rough approximations reappear as the basic-pair layer of formal topology, one level below where independent Γ/Δ lives. Drop it.**

---

## 6. Bunched implication / separation logic — refuted, and the mismatch runs the opposite way from what you expected

You asked me to assess this seriously. I did, and it is the most confidently negative result in this document.

**(a) Additive/multiplicative is not your union-closed/intersection-closed split.** Your P1 is about **closure polarity of a model class**. BI's split is about **whether a resource is shared or partitioned**. Different axes. `m ⊨ P ∧ Q` iff `m ⊨ P` and `m ⊨ Q` on the same `m`; `m ⊨ P ∗ Q` iff `∃m₁,m₂. m₁·m₂ = m` with `m₁ ⊨ P`, `m₂ ⊨ Q`. Both are *positive* conjunctions, neither is a closure operator, neither is idempotent (`P ∗ P ⇏ P`), neither corresponds to closure under union or intersection of models.

Critically — and this confirms your own suspicion — **`∗` is a positive assertion of separation, not a prohibition on sharing.** Reynolds derives non-aliasing as a *consequence*: `e₁↦e₁' ∗ e₂↦e₂' ⇒ e₁ ≠ e₂` ("Separation Logic: A Logic for Shared Mutable Data Structures", LICS 2002, <https://www.cs.cmu.edu/~jcr/seplogic.pdf>). That is "these do in fact live in disjoint parts", not "these must never overlap". To say "X and Y never co-occur", BI offers only ordinary negation — `¬(X ∧ Y)` in Boolean BI, `X ∧ Y → ⊥` intuitionistically — and the resource structure drops out entirely, leaving a plain Horn clause you already had.

Reynolds *does* have your concept, and pointedly it is **not a connective**. Verbatim: "we say that two assertions are *immiscible* if they cannot both hold for overlapping heaps." He presents immiscibility as a meta-level property of assertion *pairs* and speculates it "may be a fertile source of new inference rules" — i.e. as of 2002 an open direction, not machinery. **BI does not internalise the one concept your prohibitions need.**

**(b) Non-monotonicity — intuitionistic SL fails P3 outright.** Reynolds, verbatim: "We say that an assertion p is *intuitionistic* iff, for all stores s and heaps h and h′: h ⊆ h′ and ⟦p⟧(s,h) implies ⟦p⟧(s,h′)"; and historically, "The intuitionistic character of this logic implied a monotonicity property: that an assertion true for some portion of the addressable storage would remain true for any extension of that portion… Ishtiaq and O'Hearn also presented a classical version of the logic that does not impose this monotonicity property". So intuitionistic SL assertions are **monotone under heap extension by construction**. Classical BBI is non-monotone but *uniformly and degenerately* so — precise assertions like `x ↦ 3` are false on any strict extension because they describe the heap exactly. That is anti-monotone across the board, not your interleaving where one addition simultaneously satisfies a requirement and arms a prohibition. BBI clears the bar while doing none of the work.

**(c) The frame rule is the fatal mismatch, and it runs the other way.** `{p} c {q} ⊢ {p ∗ r} c {q ∗ r}` (Reynolds, verbatim, side condition: no free variable of `r` is modified by `c`). Its purpose in his words: "the frame rule is the key to 'local reasoning' about the heap… to infer from a local specification of a command the more global specification appropriate to the larger footprint". Yang proved it complete in a precise sense. **The frame rule *is* "composition preserves validity", and it is the load-bearing beam of the entire edifice.** Your P4 asserts the opposite, with witnesses. Adopting SL for a system that fails frame means importing the notation while discarding the only theorem that justified inventing it; without frame, separation logic degenerates to Hoare logic with a fancy conjunction.

**(d) Decidability — the decidable fragments are precisely the ones that cannot state prohibitions.** Intuitionistic propositional BI is decidable (Galmiche, Méry & Pym, *MSCS* 15 (2005) 1033–1088). **Boolean BI is undecidable** (Larchey-Wendling & Galmiche, LICS 2010, <https://members.loria.fr/DLarchey/files/papers/lics10_larchey_galmiche_full.pdf>). Brotherston & Kanovich, *JACM* (<https://www0.cs.ucl.ac.uk/staff/J.Brotherston/JACM/brotherston_kanovich_JACM.pdf>), Corollary 5.1: provability and validity are undecidable "even when restricted to the language (∧, →, I, ∗, −∗) of Minimal BBI", across all separation models and the concrete heap models; Corollary 5.2: "Neither Minimal BBI nor BBI nor BBI+eW has the **finite model property**" — so **no finite countermodels**, hence no model-enumeration debugging of a failed constraint. Remark 6.1 notes undecidability arises *purely from combining* ∧/→ with ∗/−∗, not from negation, "notwithstanding the fact that both its components are decidable". The decidable fragments — Berdine–Calcagno–O'Hearn symbolic heaps (FSTTCS 2004), Iosif–Rogalewicz–Šimáček bounded tree width (<https://arxiv.org/abs/1301.5139>) — are **negation-free positive** fragments. Your prohibitions are negations of co-occurrence. Adding them exits the decidable fragment.

**(e) Tooling is aimed at programs you do not have.** Only **cvc5** is a general checker not requiring a program (quantifier-free `SL(T)`, <https://cvc5.github.io/docs/cvc5-1.0.2/theories/separation-logic.html>) — but it allows **one `declare-heap` per context**, no quantifiers, no mixed Loc/Data sorts, which collides directly with P5 and P6. Infer, VeriFast, Viper, Cyclist and Iris all consume *programs*. You have a static structural-validity question.

**(f) Iris resource algebras: a real hit on double-counting, but a backing cycle is not a double-count.** Iris RAs are `(M, V, |−|, ·)` with **RA-VALID-OP: `∀a,b. V(a·b) ⇒ V(a)`**, motivated verbatim by ruling out the case where "multiple threads claim to have ownership of an exclusive resource" (Jung et al., "Iris from the ground up", *JFP* 28 (2018) e20, <https://people.mpi-sws.org/~dreyer/papers/iris-ground-up/paper.pdf>). If Terra were *the same asset counted twice*, cameras would be the right object. **But A→B→C→A can be perfectly disjoint at every hop** — each mechanism holds a distinct token, `V(a·b·c)` holds, the RA is content. What is wrong is that the transitive closure of `backs` has no exogenous grounding: a **reachability/well-foundedness** property of a directed graph. Separation algebras have no notion of reachability, and RA-VALID-OP is anti-monotone — a purely Horn-shaped property that cannot express your dual-Horn requirements. SL gets acyclicity for free only in the narrow `ls x nil` case, where nodes *are* the resources; that trick would reject legitimate asset sharing along with the pathological cycle. Too blunt.

**Verdict: fails P1, P3 and P4; a too-blunt partial hit on P5; clears P6 only by borrowing generic higher-order logic in Coq. P4 is fatal — the frame rule is the assumption that composition preserves validity, which is exactly what your system disproves, and BI's decidable fragments are precisely the negation-free ones that cannot express your prohibitions. Drop it.**

---

## 7. Petri nets, siphons and traps — my own best hunch, honestly refuted on polarity

I went in expecting siphons/traps to be an exact Γ/Δ pair. They are not, and the reason is worth recording.

**Definitions (verified, Murata, "Petri Nets: Properties, Analysis and Applications", *Proc. IEEE* 77(4):541–580, 1989, <https://www.dsc.ufcg.edu.br/~abrantes/CursosAnteriores/MVSRP/murata89.pdf>).** A **siphon** is a nonempty `S` with `•S ⊆ S•` — "every transition having an *output* place in S has an *input* place in S". A **trap** is a nonempty `Q` with `Q• ⊆ •Q`. Behaviourally, verified: "a siphon has a behavioral property that if it is token-free under some marking, then it remains token-free under each successor marking"; dually a marked trap stays marked. Desel & Esparza call these **stable predicates**, which is the right vocabulary for your Γ/Δ (*Free Choice Petri Nets*, CUP, <https://www7.in.tum.de/~esparza/bookfc.html>).

**Commoner/Hack (verified, Murata Thm 12 / Thm 15).** "A free-choice net (N, M₀) is live **iff** every siphon in N contains a marked trap." For asymmetric-choice nets the condition is sufficient but not necessary. Structurally: "a free-choice net is structurally live iff every siphon has a trap." That is a beautifully profile-shaped theorem — and it is not the shape you have.

**The refutation.** **Siphons and traps are BOTH closed under union; neither is closed under intersection.** `•(S₁∪S₂) = •S₁ ∪ •S₂ ⊆ S₁• ∪ S₂• = (S₁∪S₂)•`, and dually for traps; intersection fails for both because pre-/post-sets of an intersection are only *contained in* the intersection of the pre-/post-sets. (Definitions are Murata's; **this derivation is the lane's, not quoted from a source**.) Consequently each family has a maximal element inside any place set, giving **two interior/kernel operators of the *same* polarity** — "largest siphon inside X" and "largest trap inside X". You do not get an opposite-polarity Γ/Δ pair. **P1 is not matched, and the Murata §VII duality — "a set of places is a trap (siphon) in N⁻¹ iff it is a siphon (trap) in N" — is *arrow reversal*, not lattice polarity.** Do not force this analogy.

**Where it does earn its keep: P5.** Coloured Petri nets (Jensen) put `(element, asset)` instance data on the token, so "asset A backs mechanism M mints asset B backs N backs A" is a directed circuit at the *token* level, structurally detectable, even though the type-level net is a DAG. **Collapsing colours is exactly your non-faithful forgetful functor.** P6 fails outright: two sorts (places, transitions); CPN substitution transitions are modular nesting, not a policy sort.

**Decidability & tooling.** Reachability is decidable (Mayr 1981, Kosaraju 1982 — standard attribution, not re-verified) and **Ackermann-complete**, proved independently in 2021 by Leroux (FOCS 2021, <https://ieee-focs.org/FOCS-2021-Papers/pdfs/FOCS2021-5stbVHiOp5jRHWlSl41FkR/205500b241/205500b241.pdf>) and Czerwiński & Orlikowski (FOCS 2021, <https://ieee-focs.org/FOCS-2021-Papers/pdfs/FOCS2021-5stbVHiOp5jRHWlSl41FkR/205500b229/205500b229.pdf>). Computing the *maximal* siphon inside a place set is polynomial (greedy removal, justified by union-closure); complete siphon enumeration is exponential and minimal-siphon extraction is NP-complete in identified cases. Tools: LoLA, TINA, CPN Tools, Snoopy, TAPAAL.

**Verdict: fails P1 (both operators union-closed — same polarity) and P6 entirely; excellent on P5. Steal siphon/trap computation as an *analysis technique* for backing-cycle detection. Do not adopt Petri nets as the ambient formalism.**

---

## 8. Chu spaces — a stretch; drop

Objects of `Chu(Set,2)` are `(A, X; r : A × X → 2)`, points versus states, with a contravariant self-duality swapping the components; it is a genuine \*-autonomous category and **does model linear logic** (confirmed by Papadopoulos & Syropoulos, <https://arxiv.org/abs/1101.2999>: "the logic of Chu spaces is linear logic"; construction per <https://ncatlab.org/nlab/show/Chu+construction>).

**But the two sorts in Chu are each other's dual by construction.** Your `(element, asset)` sorts are not: assets are *indices*, not the dual space of elements. Writing `r : Element × Asset → 2` for `backs` is syntactically possible and semantically empty — you get one bipartite relation and neither Γ nor Δ. Worse for P4: Chu is a category, morphisms compose, and object/morphism properties are preserved by composition — the opposite of your measurement.

**Verdict: fails P1, P2, P3 and P4. Self-duality is exactly the wrong shape: you need two *independent* operators, and Chu gives you one structure and its mirror. The genuine partial match on P5 is available more cheaply from displayed categories (§4). Drop.**

---

## 9. Hyperdoctrines — rejected in one line

A hyperdoctrine is `P : Tᵒᵖ → C` with each substitution `P(f)` having both adjoints `∃_f ⊣ P(f) ⊣ ∀_f`, subject to Beck–Chevalley and Frobenius (Lawvere, "Adjointness in Foundations", *Dialectica* 23 (1969), TAC reprint <http://www.tac.mta.ca/tac/reprints/articles/16/tr16abs.html>; "Equality in hyperdoctrines…", <https://ncatlab.org/nlab/files/LawvereComprehension.pdf>; Seely, *ZML* 29 (1983), <https://www.math.mcgill.ca/seely/ZML/ZML.PDF>). It is genuinely "predicates indexed over contexts" and genuinely much lighter than an institution, and it delivers P5.

**But the fibres are lattices/Heyting algebras by definition, and your P1 says validity is a lattice under neither polarity.** The core assumption is violated at the fibre. Comprehension nominally offers P6, but to state it you must already have the mechanism-object in the base — the extra sort is a precondition, not a dividend.

**Verdict: fails P1 at the fibre; does not deliver P6 for free. Reject.**

---

## 10. Antimatroids, greedoids, convex geometries, convexity spaces — refuted, and one of your premises is backwards

**Correction first, because it would have poisoned everything downstream.** You wrote: "Convex geometries are the dual of matroids and are exactly union-closed families." **That is backwards.** A convex geometry's *closed (convex) sets* form a Moore family and are **intersection-closed**. It is the **antimatroid's *feasible* sets** that are **union-closed**. The two are complementary — feasible sets of the antimatroid are the complements of the closed sets of the convex geometry — so of course they carry opposite polarity.

**Definitions (verified** from Kempner & Levit, "Cospanning characterizations of antimatroids and convex geometries", <https://arxiv.org/abs/2107.08556>, attributing to Korte, Lovász & Schrader, *Greedoids*, Springer 1991**).** A **greedoid** is `(E,F)` with `∅ ∈ F` and the exchange axiom `X,Y ∈ F, |X| > |Y| ⇒ ∃x ∈ X∖Y . Y∪x ∈ F`. An **antimatroid** is "a greedoid closed under union"; for an accessible system, antimatroid ⟺ `F` closed under union ⟺ (`A, A∪x, A∪y ∈ F ⇒ A∪{x,y} ∈ F`). **Accessibility**: every nonempty closed `X` contains `x` with `X−x` closed. **Anti-exchange**: `p,q ∉ τ(X) ∧ p ∈ τ(X∪q) ⇒ q ∉ τ(X∪p)`. A **convex geometry** is "a closure space with anti-exchange property". Closure lattices of convex geometries are meet-distributive/locally distributive (Adaricheva & Nation, <https://arxiv.org/abs/1205.3236>; Dilworth 1940 lineage **not fetched**).

**Your "seating order" intuition is genuinely accessibility** — and accessibility is a shellability/removal axiom, not monotonicity, so it does *not* by itself clash with P3. That much of your hunch was right.

**But union-closure is the kill shot.** In an antimatroid, if `{x}` is feasible and `{y}` is feasible then `{x,y}` is feasible. Your prohibitions say precisely that `{x,y}` is *not*. Worse, `E = ⋃F` is always feasible in an antimatroid — the "everything at once" configuration is always valid, which is the exact negation of having any prohibition at all. **An antimatroid cannot express a single prohibition.** Full stop.

**Greedoids are worse.** The exchange axiom forces all maximal feasible sets to be **equicardinal** (immediate: a smaller maximal set could be augmented). Your maximal valid configurations differ in size. Dead on arrival.

**Convexity spaces (van de Vel) — the hope I had for this cluster, and it collapses.** Verified axioms (via <https://arxiv.org/abs/2412.01445>, citing van de Vel, *Theory of Convex Structures*, North-Holland Math. Library 50, 1993): **(C1)** `∅, X ∈ C`; **(C2)** closed under intersections; **(C3)** closed under **nested** unions. I hoped C2/C3 was the opposite-polarity pair. It is not: **in a finite carrier C3 is vacuous**, since every finite chain contains its own maximum and its union is already a member. Over a finite `E`, a convexity space is *nothing but* a Moore family containing `∅` and `E`. C3 only earns its keep over infinite carriers (algebraic/finitary closure). **Only revisit this if your `(element, asset)` instance carrier is genuinely unbounded.**

**Products/composition: unverified.** KLS 1991 has chapters on interval greedoids, lattices associated with greedoids, and local poset greedoids, but the lane could not confirm a direct-sum/free-product construction or that antimatroid-hood is preserved. Do not cite products here. **Optimisation** is the one genuine strength: greedy is optimal for R-compatible linear objectives over a greedoid (Korte & Lovász, *SIAM J. Alg. Disc. Meth.* 5 (1984), <https://epubs.siam.org/doi/abs/10.1137/0605024>). **No software found** (SageMath has matroids, not antimatroids) — unverified negative.

**Verdicts.**
- **Antimatroid** — fails P1 outright (union-closure makes prohibitions inexpressible and forces `E` valid); also fails P4, P5, P6.
- **Convex geometry** — fails P1 from the other side: intersection-closed only, so it expresses prohibitions but not disjunctive requirements; also fails P3 (closure lattices are monotone by construction), P5, P6.
- **Greedoid** — fails P1 *and* forces equicardinal maximal valid sets. Worst fit of the four.
- **Union-closed set families / Frankl's conjecture** — irrelevant; Frankl is a frequency lower bound, not a structure theory.
- **Convexity spaces** — fails P1 in the finite case, where C3 is vacuous and the structure degenerates to a Moore family.

---

## Ranked verdict

**Nothing here replaces the closure+kernel model. Two things genuinely extend it, and one thing reframes it.** Ranked by what I would act on:

**1. The bijunctive/median reframing (§0) — not a framework, a measurement.** Highest value per unit of effort, and it is a *decision*, not a survey result. Your P1 and P3 are jointly the signature of a **median algebra** if and only if requirements are single-consequent. Answer the arity question first: arity-1 buys you a median algebra with linear-time algorithms and a real representation theory; arity-≥2 puts you in the provably structureless NP-complete regime whose canonical instance is graph colouring. Every other choice in this document is downstream of that answer. Fails nothing, because it is not competing — it tells you which regime you are in.

**2. Approximation Fixpoint Theory (§1), with ADFs (§2) and ASP (§2b) as its runnable instances.** The strongest *framework* candidate, and the only one whose central machinery is built for P3 rather than tripped up by it: a non-monotone operator on `L` becomes a `≤_p`-monotone operator on `L²`, and Knaster–Tarski applies again. It is also the only candidate that *explains* P4 instead of contradicting it, and this is now verified at theorem level rather than inferred: **VGD Theorem 3.5 is an iff** — fixpoints decompose across a split exactly when the operator satisfies the stratifiability condition of Definition 3.3 — so "composition does not preserve validity" is not a brute fact but the failure of a named, citable side condition, with Terra's instance-level cycle as the reason it fails. ADFs give you P1 natively (attacking/supporting/redundant/dependent links, independent, not de Morgan duals); ASP gives you P1, P2, P3, P5 plus the most mature solvers of anything here, at the cost of reification for P6. **Fails P5 and P6 at the AFT level** (carrier-agnostic by construction: it takes the lattice as given and will never tell you the carrier must be indexed by `(element, asset)`); neutral on P1. This is what I would build on.

*One honest test before committing:* AFT's two components are the lower and upper bound of **one** operator, whereas your Γ and Δ are two **different** operators on the same lattice. The shapes coincide; the meanings do not. The concrete go/no-go is: **can you define `A(x,y)` from Γ and Δ such that `A` is `≤_p`-monotone?** If yes, you inherit all three semantics and the splitting theorem for free. If no, AFT gives you nothing.

**3. Displayed categories + typed coloured operads (§4) — the cheap answers to P5 and P6.** Not competitors; bolt-ons. Displayed categories give the `(element, asset)` indexing with no cartesian-lift obligation, and — more useful — your P5 has a **name**: the configuration category is **not concretizable over Set**, the forgetful functor being neither faithful nor amnestic, with Freyd's "Homotopy is not concrete" (1970) as the exact structural precedent. A typed coloured operad makes a curator an `n`-ary multi-morphism `(M₁,…,Mₙ) → V`, which *is* P6, lighter than a double category and far lighter than an institution — **provided you keep validity out of the algebra**, putting only observational behaviour in it, which is precisely the half of P4 that holds. **Silent on P1–P3.**

**4. Formal topology / Sambin positive topologies (§3) — the honourable near-miss.** The only framework where Γ and Δ are *independent primitive data* with a compatibility law, and where the generation modes (inductive cover, coinductive positivity) match your semantics exactly. It also subsumes rough sets as its basic-pair layer. **But it fails P3 and P4 — both operators are monotone by axiom — and it charges intuitionistic logic as the entry fee, since classically positivity collapses to `¬ a ◁ ¬V` and you are back to de Morgan duals.** Read it for vocabulary and for the compatibility axiom; do not rebuild on it.

**5. Petri net siphons/traps (§7) — demoted to a tool.** My own best hunch going in, and honestly refuted: **siphons and traps are both union-closed**, so they are two kernel operators of the *same* polarity, not your Γ/Δ pair. Commoner's theorem ("a free-choice net is live iff every siphon contains a marked trap") is profile-shaped but is not your shape. Keep coloured Petri nets and siphon computation as an **analysis technique for backing-cycle detection** — they are strong on P5 — and drop them as an ambient formalism (P6 fails outright).

**Refuted, in descending order of how confidently:**

**6. Bunched implication / separation logic (§6).** The most confident rejection. `∗` asserts separation positively; it cannot say "must not share" — Reynolds's own word for your concept, *immiscibility*, is explicitly a meta-level property of assertion pairs and not a connective. Intuitionistic SL is monotone under extension by construction (P3 dead); the **frame rule *is* the claim that composition preserves validity**, which your P4 disproves with witnesses, so the load-bearing theorem is exactly the one you cannot have. Boolean BI is undecidable **with no finite model property** (so no countermodels to debug with), and every decidable fragment is negation-free — i.e. cannot express a prohibition. Iris cameras genuinely detect double-counting but a backing cycle is a *reachability* property, and separation algebras have no notion of reachability. **Fails P1, P3, P4; blunt on P5; clears P6 only via generic higher-order logic.**

**7. Antimatroids / greedoids / convex geometries / convexity spaces (§10).** An antimatroid cannot express a single prohibition (union-closure forces `E` valid); a greedoid additionally forces equicardinal maximal sets; a convex geometry is intersection-closed and so cannot express disjunctive requirements; a finite convexity space degenerates to a Moore family because C3 is vacuous. And your premise that convex geometries are union-closed is backwards. **All fail P1.**

**8. Rough set theory (§5).** Fails at the definition: lower and upper are de Morgan conjugates of a *single* relation — duality is an axiom, not an accident — so Γ determines Δ and you cannot have two independent operators. The covering generalisations that break duality break the operator instead. The boundary region is a vagueness measure, not your residue. **Fails all six**, and is subsumed by §3 anyway.

**9. Bilattices (§2c).** Refuted by the very theorem that makes them tractable: Avron's Theorem 3.3 forces every interlaced bilattice to be a componentwise product `L⊙R`, so your validity set — the *diagonal* of `Fix(Γ) × Fix(Δ)` — is exactly what the structure cannot see. And a bilattice makes validity a lattice under *both* orders, where P1 says it is a lattice under neither. The non-monotonicity argument you were counting on is AFT's, not the bilattice's. **Keep the carrier `L²`, drop the framework.**

**10. Chu spaces (§8) and hyperdoctrines (§9).** Chu's two sorts are each other's dual by construction, which is the wrong shape for two *independent* operators, and everything in a category is preserved by composition. Hyperdoctrines are genuinely lighter than institutions and do deliver P5, but their fibres are Heyting algebras **by definition**, contradicting P1 at the fibre.

**Bottom line.** Keep the closure+kernel model. Ask the arity question, because it decides whether you are in the median-algebra regime or the NP-complete one. Then take AFT/ADFs as the semantic engine for P1–P4, bolt on a displayed category for P5 and a coloured operad for P6, and steal siphon/trap computation as a cycle detector. Nothing on your list beats what you have; three things extend it in directions it does not currently reach.

---

## What I could not verify

**Tooling constraint that shaped everything.** The session's WebSearch budget was exhausted (200/200) before research began. All sources were reached by direct WebFetch of primary URLs, with DuckDuckGo's HTML endpoint as a search proxy until it began returning HTTP 403. Several primary PDFs would not text-extract. One guessed arXiv ID returned a completely unrelated paper, so **no arXiv identifier below was used unless it was resolved through a search result, never guessed**.

**Claims I could not confirm from a primary source:**

- **The median-algebra structure of 2-SAT solution sets (§0)** — I confirmed the statement and its attributions (Bandelt & Chepoi 2008; Chung, Graham & Saks 1989) only through <https://en.wikipedia.org/wiki/2-satisfiability>. I did **not** read either primary. The claim is standard, but treat the citation as second-hand until checked.
- **Schaefer 1978 itself** was never fetched. The polymorphism characterisations (Horn↔min, dual-Horn↔max, bijunctive↔majority, affine↔minority) were confirmed via the Wikipedia article on the dichotomy theorem and via the CKZ 2008 paper's §2.2 restatement. The **NP-completeness of the mixed Horn/dual-Horn case is a derivation** from the dichotomy plus the non-membership witnesses, not a quoted theorem — though the graph-colouring encoding makes it concrete and I regard it as safe.
- **The DMT originals on AFT** — "Approximations, stable operators, well-founded fixpoints…" (2000) and the *Information and Computation* 2004 version — could not be text-extracted. AFT's core definitions come from the restatement in <https://arxiv.org/pdf/2502.09234>; only the **ultimate approximation** abstract is quoted verbatim from a primary (<https://arxiv.org/abs/cs/0205014>).
- **The AFT splitting theorem's precise side condition — NOW VERIFIED, upgrade from the earlier draft.** Definitions 3.3, Proposition 3.4 and Theorem 3.5 were subsequently read from the v2 PDF of <https://arxiv.org/abs/cs/0405002> and are quoted in §1. This was flagged as the single most load-bearing *inference* in an earlier draft; it is now a quoted theorem, and the P4 story stands on it. What remains unverified is the **exact Lifschitz–Turner 1994 splitting-set theorem statement** (`vl/papers/splitting.pdf` serves a different paper — Harrison & Lifschitz on infinitary formulas — and every other URL 404'd), and the **Oikarinen–Janhunen module theorem** (ECAI'06/TPLP'08 unreachable; all engines 403, Semantic Scholar API rate-limited). The commonly-reported side condition for the latter — *no positive recursion through the module input/output interface* — **could not be confirmed from a primary source and must not be cited as confirmed.**
- **Bilattice and ASP items.** Avron's Definitions 1.1–1.4 and Theorems 3.3/3.7 are quoted from the primary PDF and are solid. **Fitting's own wording** on `Φ_P` being `≤_k`-monotone is **unverified** — melvinfitting.org serves a mismatched TLS certificate (`*.securedata.net`) and the Lehman mirror 404s; the claim is confirmed only indirectly, in generalised form, via AFT. Also unverified: **uniqueness of the stable model of a stratified normal program** (standard, but not quoted here), and the **NP-complete / Σ₂ᵖ-complete** complexity statements for normal/disjunctive ASP (standard, not verified this session).
- **That FO(ID)/IDP-Z3's inductive-definition semantics is the AFT well-founded fixpoint.** Widely stated in the KU Leuven literature; not confirmed on the pages I fetched.
- **ADF complexity.** I have only the verified phrasing "one level up in the polynomial hierarchy compared to AFs". Exact per-semantics bounds are unverified; an earlier fetch returned "PSPACE-complete", which I believe is a summariser artefact and have discarded rather than reported. Solver maintenance status (DIAMOND, YADF, k++ADF, QADF) unchecked.
- **Formal topology composition.** No source found on whether the positivity relation is preserved by products of formal topologies, and none on completeness/cocompleteness of the category. The general risk (point-free products are locale products, which preserve frame structure) is my inference. Coquand–Sambin–Smith–Valentini would not text-extract.
- **O'Hearn & Pym 1999**, the actual BI primary, was never obtained — the Cambridge link served an unrelated paper. BI content is quoted via Reynolds (a co-developer) and via Larchey-Wendling & Galmiche. **Calcagno–O'Hearn–Yang** (separation algebras, safety monotonicity, frame property) also could not be fetched, so those precise definitions are unverified. Mayr/Kosaraju attributions for Petri reachability decidability were not re-verified.
- **The siphon/trap union-closure derivation (§7)** is the lane's own one-line proof from Murata's definitions, not a quoted result — though it is elementary and I am confident in it. That adding tokens can destroy liveness in general nets, and that place/transition-fusion composition does not preserve liveness, are both standard folklore that **could not be sourced this session**.
- **Edelman & Jamison 1985** (paywalled), **Dilworth 1940**, and **Monjardet 1985** (paywalled) were never read; antimatroid/convex-geometry definitions come from Kempner & Levit's restatement of Korte–Lovász–Schrader. **Products of antimatroids/greedoids: entirely unverified — do not cite.** No antimatroid software found, which is an unverified negative.
- **Lax algebras over the wiring-diagram operad** — the construction that would let validity live in the algebra without forcing preservation under composition — could not be sourced. If the operad route is pursued, this is the gap to close.
- **Freyd's "Homotopy is not concrete"** and the *amnestic* definition come from nLab; the TAC reprint and Adámek–Herrlich–Strecker both failed to fetch (ECONNRESET / TLS mismatch). Attribution is secondary-confirmed only.
- **No literature name exists for "the intersection of a union-closed and an intersection-closed family."** The lane searched and found none, and gives a principled reason (the object is `Inv(∅)` and carries no polymorphism). Reported as *searched-for and not found*, **not** as a proven gap in the literature.
- **Sequencing note.** The bilattice/ASP lane returned *after* the first complete draft was written; §2b, §2c and the upgraded §1 splitting statements were folded in afterwards, and the ranked verdict was revised accordingly. An earlier partial fetch indicated Oikarinen & Janhunen's module theorem "properly strengthens Lifschitz and Turner's splitting set theorem" and permits "recursion between modules" — the exact side condition was never recoverable, and ASP-specific composition remains the obvious next thing to check.
