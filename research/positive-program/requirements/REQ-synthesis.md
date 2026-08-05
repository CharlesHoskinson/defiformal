# Requirements from program synthesis, decidability and structural complexity

## 0. Position in one paragraph

Synthesis is a decision problem, and a decision problem is tractable or not because of
the *width of the interaction* among its variables, not because of the size of its
vocabulary. The prior work never posed construction as a decision problem, so it never
measured the only parameter that governs it. I measured it. Over the corpus's own
machine-readable tables, the constraint system on the 58 elements has a primal graph on
**35 non-isolated vertices and 88 edges, with maximum clique 6 (so treewidth ≥ 5) and a
min-fill elimination order of width 8 (so treewidth ≤ 8)**; adding the obligation ledger
of any one of the 60 applications leaves that upper bound at 8, unchanged, for all 60.
Maximum term width is 4 (mean 1.94); maximum |S_o| is 4 (mean 1.22, with 454 of 570
non-empty obligation terms singletons). At treewidth 8 over 58 Boolean variables,
synthesis, minimisation, counting and polynomial-delay enumeration are all a
2^9 · n · m dynamic program — roughly 3·10^5 machine operations. **Construction on this
subject matter is not hard. It was posed in a form that hid its own tractability.** My
requirements are therefore not about making synthesis possible; they are about keeping
the specification language inside the fragment where it stays this cheap while the
missing sorts (party, magnitude) are added, and about emitting a certificate that makes
"this construction discharges this specification" checkable by `decide` in the existing
Lean development.

## 1. Carrier and signature

**Requirement SYN-A (the specification language is a bounded-arity finite-domain CSP,
and nothing else).** A *specification* is a structure Σ = (V, D, C) where

- V is a finite set of variables, sorted. Sort `El` carries the 58 Boolean variables
  x_e ∈ {0,1}, one per element ("is e in the construction"). Every enrichment adds a
  sort with a **finite, fixed, small domain** — never an unbounded one.
- D assigns each variable its finite domain; write d = max|D(v)|. Currently d = 2.
- C is a finite set of constraints, each a pair (σ(c), R_c) with σ(c) ⊆ V its *scope*
  and R_c ⊆ ∏_{v∈σ(c)} D(v) its relation. Write ω = max_c |σ(c)| (the arity).

The three constraint families are: obligations o ↦ ⋁_{e∈S_o} x_e (scope S_o);
requirement rows (s, T_j) ↦ ¬x_s ∨ ⋁_{e∈T_j} x_e (scope {s} ∪ T_j); prohibitions
H_i ↦ ⋁_{e∈H_i} ¬x_e (scope H_i). Warrants are requirement-shaped.

**Requirement SYN-B (formalization discipline is a typing rule, not a convention).** A
constraint with an empty scope is the constant `true` and is *not a constraint*. The
`[ext]` rows are therefore not weak constraints — they are absent. A specification is
**well-formed** iff every declared row has σ(c) ≠ ∅ and R_c ≠ ∏D. Report
`|C_wellformed| / |C_declared|`; today that ratio is 38 usable law clauses out of 29
declared rows' terms, 11 of 20 prohibitions naming any symbol, and 570 of 1,259
obligations. Prose rows are counted in a *deficiency register*, never in C.

**Why not "a subset of E".** A subset is the *output*. The carrier of the synthesis
problem is the specification, and specifications must form a category with a
conjunction; subsets do not.

**Sorts to be added (all finite, on pain of leaving the fragment):**

| sort | domain | size | why |
|---|---|---|---|
| `Party` | {eoa, quorum, delegate, obligor, protocol, none} | 6 | 135/385 residue obligations turn on who |
| `Mag` | interval abstraction {≪, <, ≈, >, ≫} of a threshold ratio | 5 | 9/20 prohibition rows are prose only because of magnitudes |
| `Rate` | {none, fixed, utilisation-curve, auction} | 4 | the missing interest-rate symbol |

**Requirement SYN-C (finite-domain closure).** No enrichment may introduce arithmetic
over an infinite domain, quantification over an unbounded party set, or a recursive
type. Each of the three above is an abstraction of an infinite object onto a fixed
finite lattice; the abstraction must be *sound* (Cousot–Cousot) — a concrete violation
must map to an abstract violation. This is the price of decidability and it is cheap:
with d = 6 the DP cost below goes from 2^9 to 6^9 ≈ 10^7, still seconds.

## 2. Composition

Composition of specifications is **conjunction with variable identification**:
Σ₁ ⊗ Σ₂ = (V₁ ∪ V₂, D₁ ⊔ D₂, C₁ ∪ C₂), variables identified by element symbol. It is
**total by construction** — the union of two finite constraint sets is a finite
constraint set. What can fail is *satisfiability*, and that is a property of the
composite, computed, not a side condition on the operator. This is the whole
dissolution of the prior "composition is not preserved": the prior work made
composition an operation on *models* (union of subsets), where closure is a theorem one
can lose. Made an operation on *theories*, closure is definitional.

The question that then has content is whether composition preserves **tractability**,
and that is a width question. Treewidth is not preserved by conjunction in general.
Here it is measured to be: for all 60 applications, tw(G(Σ_global ⊗ Σ_app)) ≤ 8, the
same bound as Σ_global alone. Obligations are cheap because ω(obligations) ≤ 4 and 80%
are unary.

**Requirement SYN-D (width budget).** Every specification admitted to the corpus carries
a declared width certificate: a tree decomposition of its primal graph of width ≤ K,
with K = 12 as the standing budget. A specification exceeding K is rejected as a
specification, not accepted and then found intractable.

## 3. Completeness theorem (formal statement)

I state the completeness my school can actually prove — *realizability completeness*,
the Church/Büchi–Landweber shape, not a clone-theoretic one.

> **Theorem (target).** Let F be the fragment of §1 (finite domains, arity ≤ ω,
> primal treewidth ≤ K). There is an algorithm SYNTH which, on input Σ ∈ F, terminates
> and returns either
> (i) a construction X ⊆ E together with a certificate 𝒞 (§4) such that
>     `Check(Σ, X, 𝒞) = true`, and X is of minimum cardinality among all such; or
> (ii) a **residue certificate**: a non-empty set O_∅ ⊆ O of obligations with
>     S_o ∩ E = ∅, or a bag of the tree decomposition whose DP table is empty together
>     with the constraints that emptied it.
> SYNTH runs in time O(d^{K+1} · (K+1) · |C| + |V|).

Case (ii) is what makes the theorem a *completeness* statement about P: the algorithm
never fails silently, and every failure is attributed either to the vocabulary (an
unnameable obligation — a hole in P) or to the constraints (an over-constrained spec —
a hole in the tables). "P is functionally complete for the corpus" is then exactly
**O_∅ = ∅ across the 60 ledgers**, currently 689 of 1,259.

**The Post analogue.** For a Boolean CSP the correct analogue of Post's maximal clones
is **Schaefer's dichotomy (1978)**: the tractable co-clones are 0-valid, 1-valid, Horn,
dual-Horn, affine, bijunctive. Our language is Horn (prohibitions) *and* dual-Horn
(requirements) simultaneously, hence in no single Schaefer class, hence SAT for it is
NP-complete in general and MIN-ONES for it is NP-hard and — because obligations encode
SET COVER verbatim — inapproximable below (1−ε)ln n (Feige 1998; Dinur–Steurer 2014).
**So the escape cannot be a polarity restriction; the prior work's polarity analysis was
looking at the axis that has no tractable point on it.** The escape is structural.

**Grohe's theorem (2007)** settles which structural restriction: for classes of
bounded-arity CSP instances, CSP is in PTIME iff the cores of the left-hand structures
have bounded treewidth, under FPT ≠ W[1]. Our arity is 5. **Treewidth is therefore not
one parameter among several; it is the only one available, and we have it.**

## 4. Construction / synthesis

**The problem.** MIN-SOUND-COVER(Σ): minimise |{e : x_e = 1}| subject to all constraints
of C. NP-hard in general (above). FPT in treewidth.

**The parameter: k = tw(G_prim(Σ))**, the treewidth of the primal graph whose vertices
are the variables and whose edges join variables co-occurring in a constraint scope.
Measured on the corpus tables:

| quantity | value | how measured |
|---|---|---|
| non-isolated variables in Σ_global | 35 | laws + hazards from `formal/v2/tables.mjs` |
| edges | 88 | same |
| max clique (exact, Bron–Kerbosch) | 6 → **tw ≥ 5** | same |
| min-fill elimination width | **tw ≤ 8** | Bodlaender–Koster heuristic |
| chordal? | no | maximum-cardinality-search test |
| tw UB with any one app's obligations added | **8, all 60** | `expansion/*/specs/*.json` |
| max term width in requirement rows | 4 (mean 1.94, median 1) | parsed rows |
| max \|S_o\| | 4 (mean 1.22; 454/570 singletons) | 1,259 obligations |
| strata | 5 (sizes 3, 10, 14, 22, 10) | element table |

**The algorithm.** Non-serial dynamic programming (Bertelè–Brioschi 1972) over a nice
tree decomposition, i.e. bucket elimination / Freuder's k-tree algorithm (Freuder 1990).
Each obligation, requirement term and prohibition is a *local* constraint of scope ≤ 5,
so it is absorbed into a bag — **there is no global bookkeeping**, which is the single
fact that makes this cheap. Minimum cardinality is carried as a cost in the min-sum
semiring; the number of solutions in the sum semiring, in the same pass.

- **Satisfiability / minimisation:** O(d^{k+1} · (k+1) · |C|). With d=2, k=8, |C|=93:
  2^9 · 9 · 93 ≈ **4.3 × 10^5** operations. Milliseconds.
- **Counting** all sound covers: identical bound, sum semiring. #P-hard in general;
  FPT here (Arnborg–Lagergren–Seese 1991 gives the MSO optimisation/counting extension
  of Courcelle's theorem, of which this is the concrete instance).
- **Enumerating** all minimal solutions with **polynomial delay** O(d^{k+1}·|V|) per
  solution, by backtracking through the DP tables (Read–Tarjan style). The prior work's
  60 minimal constructions come out of this in one run rather than 65,536 subset tests.
- **Obtaining the decomposition:** Bodlaender (1996), linear time for fixed k; in
  practice min-fill plus the clique lower bound already brackets tw ∈ [5, 8].
- With the three new sorts (d = 6): 6^9 · 9 · |C| ≈ **10^8**, seconds. The width budget
  K = 12 is what keeps this from exploding, hence Requirement SYN-D.

**The certificate.** A construction certificate is 𝒞 = (X, μ, ρ, δ, ν) where

- X ⊆ E,
- μ : O → E ∪ {⊥}, with μ(o) ∈ S_o ∩ X for every covered o (**positive witness**),
- ρ : {(s,j) : s ∈ X} → E, with ρ(s,j) ∈ T_j ∩ X (**requirement witness**),
- δ : H → E, with δ(H_i) ∈ H_i \ X (**negative witness**: a purely negative clause is
  discharged by exhibiting one *absent* literal),
- ν ⊆ O, the obligations discharged by *voiding* — closed by construction, so they
  cannot arise; ν(o) names the voiding element, exactly the `V` of
  `Defialgebra.Polarity.voidReq`.

`Check(Σ, X, 𝒞)` is a conjunction of |O| + Σ_j|L_j| + |H| membership tests:
**O(|C| · ω) time, linear in the specification**, no search. Every clause of the check is
a decidable membership fact over a `Finset (Fin 58)`, so in Lean 4 it is
`Decidable` by the instance already present at `Defialgebra.Polarity.Sat` and discharges
by `decide` with no classical axiom — the axiom-audit blocks in `Discharge.lean` show
the discipline is already in place. The theorem to add is one line:

```
theorem check_sound (Σ : Spec) (c : Cert) : c.Valid Σ → Models c.X Σ.clauses
```

**Minimality certificate.** For each e ∈ X, either (a) an obligation o with μ(o) = e and
S_o ∩ X = {e} (e is forced), or (b) a clause of C violated by X \ {e}. Checkable in
O(|X| · |C| · ω). This is the machine-checkable form of the prior work's element-by-
element removal test, and it removes the need to trust the checker.

**Optimality certificate** (no smaller X exists). Cook-style: ship the tree
decomposition T and the DP cost tables. Verification is (i) T is a valid decomposition
of G_prim(Σ) — O(k²|V|); (ii) each bag's table is locally consistent with its children's
— one pass, O(d^{k+1}·|V|). Size ≈ 2^9 · 58 ≈ 3 × 10^4 entries. Shippable and checkable.
This is the honest answer: minimum-cardinality has no short certificate in general, and
the tree decomposition *is* the short certificate at bounded width.

**Does the stratification give a dynamic program? Yes — and I measured that it is the
wrong one, by a factor of 4 to 512.**

- **Is stratum a grading?** Almost. Of 68 requirement arcs (subject → alternative),
  **26 point strictly down, 41 stay level, and exactly one points up**: L21, Gs(3) → Au(4).
  One arc. **Requirement SYN-E:** reassign `Au` (delegated execution scope) to stratum 3,
  or split `Gs`. Then E = ⊔_{i≤4} E_i is a genuine **filtration**: every requirement's
  consequent lies in ⋃_{j≤i} E_j, hence bottom-up synthesis by stratum is well-founded
  and induction on stratum is available for every theorem in the development.
- **Naive layered DP is bad.** The stratum-descending elimination order (eliminate all
  of stratum 4, then 3, …) has measured width **18** — because same-stratum edges (41 of
  68) all fall inside one layer. 2^19 vs 2^9 is a 512× loss.
- **Frontier DP is good.** Keep in state only the *boundary* B_k: variables below cut k
  with a neighbour above. Measured |B_k| = **3, 6, 11, 4** for cuts at stratum ≥ 1, 2, 3, 4.
  Cost Σ_k d^{|B_k|}·|C_k| ≤ 5 · 2^11 · 93 ≈ **10^6**. FPT with parameter
  β = max_k |B_k| = 11.
- **Verdict.** Stratified frontier DP is a correct O(d^{β}) algorithm with β = 11, worse
  than tree-decomposition DP at k = 8 but **canonical**: its decomposition is the
  element table itself, not a heuristic's output, so its certificate needs no
  decomposition shipped and no heuristic to trust. Use the tree decomposition for speed;
  use the stratification for the Lean proof, where induction on `Fin 5` is free and
  induction on an arbitrary tree decomposition is not.

## 5. Disposition of the prior obstructions

- **"Soundness is closed neither upward nor downward; forbids monotone greedy."**
  *Dissolved, and correctly stated as a fact about one algorithm.* Non-serial dynamic
  programming has never required monotonicity — it requires bounded width. The
  obstruction rules out greedy and rules out nothing else; naming it alongside the
  hardness of the problem conflated an algorithmic and a complexity-theoretic claim.
- **"Minimal constructions are not unique: 60 of them, all of size 6."**
  *Converted to a computable invariant.* The solution set of a bounded-treewidth CSP is
  the accepting language of a tree automaton with ≤ d^{k+1} states per bag; 3,930 and 60
  are two evaluations of that automaton in the sum semiring, obtained in one pass rather
  than 65,536. "Which construction, and why that one" becomes: add a preference weight
  (stratum-minimal, group-diverse, corpus-frequency) and re-run min-sum. Non-uniqueness
  is a *degree of freedom the synthesiser exposes*, not a defect.
- **"Composition safety is maximum clique; conjectured perfect, untested."**
  *Localized and made unnecessary.* I tested the graph the constraint system actually
  presents: it is **not chordal**, max clique 6, treewidth ∈ [5,8]. Perfection is
  therefore neither established nor needed — clique number is ≤ tw+1 and is computed by
  the same DP in O(2^{k+1}·|V|). Bounded treewidth subsumes the tractable-class
  programme here (Jégou's microstructure and Salamon–Jeavons buy tractability via GLS on
  perfect graphs; treewidth buys it unconditionally). The conjecture is retired, not
  refuted.
- **"The Kripke–Kleene fixpoint collapses to (⊥,⊤)."** *Dissolved.* That is bottom-up
  iteration over the powerset lattice, which has no decomposition. DP is bottom-up over
  a *tree of bags*; there is nothing for it to collapse to, because each bag's table is
  indexed by a total assignment, never by a three-valued approximation.
- **"689 obligations discharged by no element."** *Reclassified.* Under SYN-B these are
  not synthesis failures; they are the residue certificate of §3(ii), and they measure P,
  which is what we wanted measured.

## 6. Minimal viable enrichment (ranked by payoff / cost)

1. **Void witnesses ν in the certificate** (`voidReq`, already proved in
   `lean/Defialgebra/Discharge.lean`). *Cost:* one column in the requirement table; the
   Lean is done. *Payoff:* removes the "obligation cannot arise" expressiveness gap;
   reclassifies part of the 689. *Price, exactly as proved:* widened heads leave the
   definite fragment, so the 15-arc digraph D shrinks. D is thin already; trade it.
2. **The `Mag` sort as a 5-valued interval abstraction.** *Cost:* d goes 2 → 5 on a
   handful of variables; DP cost bounded in advance at ≤ 5^9 · |C| ≈ 10^8. *Payoff:* 9
   of 20 prohibition rows become machine-checkable, including the class that X21 belongs
   to — 79% of observed composition failures currently rest on an unpublished row.
3. **Stratum repair (SYN-E: one arc).** *Cost:* one table edit. *Payoff:* a genuine
   filtration, hence induction on stratum in Lean, hence the frontier DP's correctness
   proof.
4. **The `Party` sort, 6 constants.** *Cost:* re-reading 135 residue obligations.
   *Payoff:* separates USDT from USD1. Highest absolute payoff, highest cost; do it
   after 1–3.

**If we buy one thing this quarter: #2, the `Mag` sort.** It is the only enrichment
whose complexity cost I can bound *before* paying for it (5^{k+1} with k ≤ 12 budgeted),
and it converts the largest single block of prose into constraints.

## 7. Falsifiable near-term test

**Input.** `formal/v2/tables.mjs` (29 laws, 20 hazards, 58 elements) and the 60
`expansion/*/specs/*.json` obligation ledgers.

**Procedure (2 days).** (a) Build G_prim(Σ_global ⊗ Σ_app) for each app. (b) Compute
tw lower bound (max clique) and upper bound (min-fill + QuickBB). (c) Implement the
bucket-elimination DP in the min-sum and sum semirings. (d) Run it on the
pooled-lending instance of `formal/v3/fixtures/pooled-lending-market.json`. (e) Run it
on all 60. (f) Emit 𝒞 for each and check it with an independent 30-line checker.

**Verdict condition.** The test **confirms** the structure iff all three hold:
(i) the DP returns exactly **3,930** sound covers and exactly **60** minimal ones on the
lending instance, agreeing with the published exhaustive enumeration — this validates
the DP against a known answer; (ii) max over the 60 apps of the treewidth upper bound is
**≤ 12**; (iii) every emitted 𝒞 passes the independent checker in time linear in |C|.
It **refutes** the structure iff the DP disagrees with 3,930/60 (the CSP encoding is
wrong), or tw > 20 on any app after the 15 `[ext]` rows are formalized (the FPT claim
does not survive completing the tables — the one genuine risk, since filling in a
5-term row can add a 6-clique). Current evidence: tw ≤ 8 on the partially formalized
system, so (ii) has ~4 units of headroom per row filled.

## 8. Named proof obligations

- **PO-SYN-1.** tw(G_prim(Σ_global)) is exactly determined: the measured bracket
  5 ≤ tw ≤ 8 is closed by an exact solver (QuickBB / SAT-based) on the 35-vertex graph.
- **PO-SYN-2.** For every Σ in the fragment of §1 with tw ≤ k, MIN-SOUND-COVER is
  solved in O(d^{k+1}(k+1)|C| + |V|) — instantiate Freuder 1990 / Arnborg–Lagergren–Seese
  1991 for this constraint signature and formalize the correctness of the bucket
  elimination in Lean 4.
- **PO-SYN-3.** `check_sound : Cert.Valid Σ c → Models c.X Σ.clauses` and its converse
  `check_complete : Models X Σ.clauses → ∃ c, c.X = X ∧ c.Valid Σ`, both by `decide` on
  `Fin 58`, extending `Defialgebra.Polarity`.
- **PO-SYN-4.** The minimality certificate of §4 is sound and complete for
  `Definition (minimal)` of the paper: e is unremovable iff clause (a) or (b) holds.
- **PO-SYN-5 (SYN-E).** After reassigning `Au` to stratum 3, the requirement digraph is
  stratum-monotone (every arc weakly descends), hence E is a filtered set and induction
  on `Fin 5` proves termination of the frontier DP.
- **PO-SYN-6.** max_k |B_k| = 11 is exact, not merely an upper bound, and the frontier DP
  at width 11 returns the same solution set as the tree-decomposition DP at width 8 on
  all 60 instances.
- **PO-SYN-7 (Conjecture: width survives formalization).** Filling the 15 `[ext]`
  requirement rows with element terms of width ≤ 5 leaves tw(G_prim) ≤ 12. This is the
  single assumption on which every complexity bound above rests, and §7 tests it.
- **PO-SYN-8.** The `Mag` interval abstraction is sound: every concrete magnitude
  violation of a prohibition maps to an abstract violation (Cousot–Cousot Galois
  connection), so a construction certified sound abstractly is sound concretely.
- **PO-SYN-9.** Optimality certificates are checkable in O(d^{k+1}|V| + k²|V|), and the
  emitted tables for all 60 corpus instances fit in under 10^6 entries.
- **PO-SYN-10 (retirement).** The perfection conjecture on the compatibility graph is
  unnecessary: clique number ≤ tw+1 is computed by the same DP. Record that the graph is
  measured non-chordal with ω = 6, and close the conjecture as superseded rather than open.
