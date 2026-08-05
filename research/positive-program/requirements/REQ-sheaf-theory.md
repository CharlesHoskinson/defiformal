# Requirements from sheaf theory and obstruction theory

## 0. Position in one paragraph

"Uniswap ∪ Aave arms a prohibition neither arms alone" is not a fact about composition. It is
the signature of a **local section that does not extend**, and in the Abramsky–Brandenburger
form (Abramsky & Brandenburger, *New J. Phys.* 13 (2011) 113036) that phenomenon has a name,
a cohomological obstruction, and an exact quantitative measure. The prior model is the
degenerate case of the construction below in which the outcome set is a single point: a
protocol records *which* mechanisms it carries and nothing about the value each one takes.
Over a one-point outcome set every compatible family glues trivially, so the sheaf cannot
distinguish "these two mechanisms co-occur" from "these two mechanisms co-occur *in the same
settlement scope*" — and every recorded composition failure is an instance of exactly that
conflation. The paper says so itself about its own counterexample: the flash path "lives
inside a pool's settlement scope and the burn path on a bridge days later, and an element set
has no way to say that the two never meet." My requirement is that the carrier be able to say
it. The obstruction is then an input: enlarge the outcome set from `1` to the finite poset of
settlement horizons, and 82.4% of the corpus's composition failures are provably spurious —
measured below, not conjectured. What survives is a single triangle in the nerve, which is
precisely the row (`X2`) whose statement carries a magnitude.

## 1. Carrier and signature

**Sorts.** `El` (the 58 mechanisms), `Hor` (settlement horizons), `Ctx` (protocols).

`Hor` is the finite chain `H = {0 < 1 < 2 < 3 < 4}`: 0 intra-transaction (atomic), 1
intra-block, 2 intra-epoch, 3 cross-domain / challenge-window, 4 governance-timelock. This is
not invented; it is the brief's own stratum grading read as a *time* grading, and it is
forced on the arms of the prohibitions by their definitions — `Fl` is *atomic* flash
liquidity, so its state is live only at horizon 0; `Xf` is *cross-domain* transfer, whose
destination effect provably cannot land inside the source transaction, so it is live only at
horizons ≥ 3.

**Outcome assignment.** For each `e ∈ El` fix `𝒪(e) ⊆ 2^H \ {∅}`, the admissible *live-sets*:
the horizons at which `e`'s state can be mutated. `𝒪(Fl) = {{0}}`, `𝒪(Xf) = 𝒪(Rl) = 𝒪(Of) =
{{3,4}}`, `𝒪(Cp) = 𝒪(Cl) = 𝒪(Pl) = 𝒪(Cd) = {H}`.

**Event sheaf.** `ℰ : 𝒫(El)^op → Set`, `ℰ(U) = ∏_{e∈U} 𝒪(e)`, restriction = projection.
On the discrete space `El` this is flabby; it has no cohomology of its own. All content sits
in the sub-presheaf below.

**Carrier.** A protocol is a **context with a section**: a pair `P = (X_P, s_P)` with
`X_P ⊆ El` and `s_P ∈ ℰ(X_P)`. Not a subset of `El`. The subset is `s_P`'s domain, i.e. the
prior carrier is the image of mine under the terminal map `π : 𝒪(-) → 1`.

**Base space.** The nerve `N(𝒰)` of the cover `𝒰 = {X_P}`: vertices = protocols, a simplex
per family with non-empty common element-intersection. `ℰ` induces a **cellular sheaf**
(Shepard 1985; Curry, *Sheaves, Cosheaves and Applications*, 2014) `𝒮` on `N(𝒰)` by
`𝒮(σ) = ℰ(⋂_{P∈σ} X_P)`, restrictions = projections. Čech cohomology of the cover = cellular
sheaf cohomology of `N(𝒰)`.

**A section, financially.** A global section of `𝒮` over a family `F` is a single, corpus-wide
assignment of a settlement horizon to every mechanism — an agreement across all protocols in
`F` about *when* each shared mechanism's state can move. **Gluing means the protocols agree
on the atomicity of the mechanisms they share.**

**Formalization discipline.** A constraint row is *complete* iff it is a finite family of
**forbidden co-liveness patterns**: a tuple of elements plus the demand that their live-sets
have a common point. Nothing else counts. `X21` is complete: `live(Fl) ∩ live(x) ≠ ∅` for
`x ∈ {Xf, Rl, Of}`. `X2` is complete modulo one magnitude section (§6). Prose rows are not
constraints and are not counted; a row whose subject column is blank has empty support and is
deleted, not carried.

## 2. Composition

`⊕` is the **amalgamation (colimit) of local sections over the nerve**, not union of subsets:
`⊕F = colim_{σ ∈ N(F)} 𝒮(σ)` when the diagram is compatible.

It is total as a *diagram* — the colimit always exists in `Set` — and the question "is the
composite a protocol" becomes "does the diagram have a section restricting to each `s_P`".
Two facts make this closed **by construction** rather than by measurement:

1. **Vorob'ev's theorem (N. N. Vorob'ev, 1962).** Every compatible family on a cover `𝒰`
   glues iff `𝒰` is *acyclic* (running-intersection property; α-acyclicity). This is the
   design target: build the primitive cover α-acyclic and gluing is automatic, with no
   composition predicate to test.
2. **The failure is measurably tiny.** I ran GYO reduction on the corpus cover. The full
   60-protocol cover over 53 elements is **not** α-acyclic (residue: 45 hyperedges, 45
   vertices). Restricted to the eight prohibition-relevant elements the residue is **4
   hyperedges on 5 vertices**: `{Fl,Pl}, {Cl,Cp,Pl}, {Pl,Xf}, {Cl,Cp,Fl,Xf}`. After refining
   `Fl` by scope (so that `Fl@0` no longer co-occurs with `Xf/Rl/Of`) the residue is **3
   hyperedges on 4 vertices**: `{Fl@0,Pl}, {Cl,Cp,Pl}, {Cl,Cp,Fl@0}` — a single triangle.

So `⊕` is a partial commutative idempotent operation whose domain of definition is the
α-acyclic sub-covers, and the entire non-acyclic part of the 60-application corpus is **one
triangle: pool-pricing × credit × atomic liquidity**, which is `X2`.

## 3. Completeness theorem (formal statement)

> **Conjecture SHF-C (generation by stars).** Let `𝒮` be the scope sheaf over the primitive
> cover. Then for every application `A` in the corpus, `s_A` is a global section of `𝒮`
> restricted to the subcomplex generated by the stars `Star(e)`, `e ∈ X_A`; and every global
> section of `𝒮` over any `U ⊆ El` is a colimit of sections supported on primitive stars.

Functional completeness = **`𝒮` is generated under gluing by its star-sheaves.** Falsifier: a
functional obligation realizable in deployed code whose section is not in the image of the
gluing map — which is exactly the population of 689 residue obligations. The analogue of
Post's maximal clones is the lattice of **gluing-closed subsheaves**: a candidate primitive
set fails to be complete iff it is contained in a proper subsheaf closed under restriction and
gluing. Vorob'ev acyclicity is the check that no such subsheaf arises from the cover's
topology; residue-obligation coverage is the check that none arises from missing outcomes.

## 4. Construction / synthesis

**Synthesis is the section-extension problem.** Input: a specification as a partial section
`s₀ ∈ ℰ(U₀)`. Output: a global section `s ∈ ℰ(El)` with `s|_{U₀} = s₀` violating no forbidden
co-liveness pattern; or the obstruction.

**Certificate.** The pair `(s, ∅)` — the extension itself, plus the empty set of armed
patterns, both checkable in `O(|El| · |constraints|)`. The obstruction certificate is a
1-cocycle representative, which localizes to specific overlaps (§5).

**Complexity.** This is a CSP over 53 variables with domains of size ≤ 2^5. The `10^16`
admissible-set figure never appears: we never enumerate the powerset. Yannakakis' algorithm
solves α-acyclic CSPs in linear time; for bounded hypertree width `w` (Gottlob, Leone,
Scarcello 2002) it is `O(n · |O|^w)`. The measured residue has `w ≤ 2`, so synthesis over
this corpus is quadratic in the domain. The brute-force fallback on the eight relevant
variables is `5^8 = 390,625` assignments — milliseconds.

## 5. Disposition of the prior obstructions

**(a) "Composition does not preserve admissibility" → converted into a computable invariant,
and 82.4% of it is spurious.** Measured on the 60-application corpus (all specs read from
`/root/DefiElements/expansion/*/specs/*.json`), with `X21` and `X2` as the two machine-
checkable rows:

| semantics | failing pairs / 1711 | compatibility density |
|---|---|---|
| flat (`|O| = 1`) | 119 (100 `X21`, 21 `X2`) | 93.05% |
| scoped (`|O| = 5`) | **21** | **98.77%** |

`live(Fl) ∩ live(Xf) = ∅`, so `X21` never fires — it is a false positive of the terminal
pushforward `π : 𝒪 → 1`. The paper's own triage agrees independently: 147 of its 185 failures
arm `X21` (79.5%). The residual 21 failures all arm `X2`, whose common horizon is `{0}` —
a genuine same-transaction coincidence. The Uniswap ∪ Aave counterexample **dissolves**.

**(b) The maximum-clique reformulation → subsumed, and its hardness shown vacuous.** Three
things. First, `ω` is the 0-th invariant and it is *coarse*: I compute `ω = 55` both before
and after the refinement — it does not move even when 82% of the obstruction volume is
removed. A graded invariant is strictly more informative. Second, the NP-hardness is
inapplicable to this instance: the failure graph's vertex set is covered by the `Fl`-carriers
(4 in my corpus, 8 in the paper's 61), verified — *every* failing pair has an `Fl` endpoint —
so `ω` is certified in `2^4 = 16` subset checks (`2^8 = 256` at their scale). Clique
parameterized by the complement's vertex-cover number is FPT (Downey–Fellows). Third,
clique answers an extremal question; cohomology answers a *localization* question, which is
the actionable one.

**(c) The nerve, and what the 8-of-61 concentration means.** The nerve is large and nearly
complete: 92.23% of protocol pairs share at least one element, there is **no** global core
(the intersection of all 59 seeds is empty), and the most-shared element `Gp` reaches only
45/59. So the base space carries no interesting topology — **all obstruction lives in the
sheaf, not in the space.** The failure locus is contained in `Star(Fl)`, the star of a *single
vertex of the vocabulary*: the obstruction class lies in the image of the map from cohomology
with supports, `H¹_{Star(Fl)}(N; ℱ) → H¹(N; ℱ)`. Concentration on 8 protocols sharing one
element is therefore not a coincidence of the corpus; it is the statement that the cover is
α-acyclic away from `Star(Fl)`, which GYO confirms. The residual failure complex is a **union
of 4 stars**, 16 contexts, 21 edges, `b₀ = 1`, `b₁ = 6`.

**(d) The Kripke–Kleene collapse to `(⊥, ⊤)` → localized to the degenerate fragment.** It is a
theorem about `|O| = 1`. Over a 5-element outcome poset the co-liveness constraints prune, and
the corpus fact that the 79 positive clauses exclude zero elements is an artifact of the same
collapse: a membership demand over a one-point outcome set cannot bind, a co-liveness demand
can.

**The three invariants, and which to compute.**
- `γ(s) ∈ H¹` — the Čech obstruction of Abramsky, Barbosa, Kishida, Lal & Mansfield
  (*Contextuality, Cohomology and Paradox*, CSL 2015). Integral, cheap, **necessary but not
  sufficient**: false positives exist. Use it as a fast filter, never as a certificate.
- **Consistency radius** `c(s) = max_{P,Q} max_{e ∈ X_P ∩ X_Q} d(s_P(e), s_Q(e))` under the
  chain metric on `H` (Robinson, *Sheaves are the canonical data structure for sensor
  integration*, Information Fusion 36 (2017)). `O(n²|El|)`, graded, and its filtration names
  the exact overlap carrying the disagreement. **This is the deliverable measure.**
- **Contextual fraction** (Abramsky, Barbosa & Mansfield, *PRL* 119 (2017) 050504) — an LP,
  exact, monotone under simulation. 14 distinct trigger-contexts over 8 variables: the LP is
  trivially small. Use when an exact number is needed.

## 6. Minimal viable enrichment (ranked)

Ranked by structural payoff / formalization cost:

1. **The horizon sort `Hor` and the live-set map `𝒪`.** Cost: one column of 58 rows, each a
   subset of a 5-chain, most forced by the element's own definition. Payoff: 82.4% of measured
   composition failures dissolve; composition becomes checkable in linear time on the acyclic
   part; the positive clauses acquire binding power. **Buy this one.**
2. **A magnitude section** — a sheaf of ordered abelian groups over the same base, so `X2`'s
   "manipulation cost < position value" is a comparison of two sections. This also gives
   conservation laws for free: deferred net settlement is exactly the condition that a
   1-cochain of the value sheaf is a coboundary (`δ`-exactness = Kirchhoff), which is discrete
   Hodge theory on the nerve (Ghrist & Hansen, *Toward a spectral theory of cellular sheaves*,
   JACT 3 (2019)).
3. **A party sort** as a second outcome sheaf, closing `X19*` and the USDT/USD1 collision.

Do not buy ported interfaces yet: with `𝒪` in place, the nerve overlaps *are* the ports.

## 7. Falsifiable near-term test

**Input.** The 58 elements; one analyst-assigned live-set `𝒪(e) ⊆ H` per element, produced
blind — assigned from the element's definition alone, without seeing any protocol or any
prohibition row. Plus the 60 corpus constructions, unchanged.

**Procedure.** Recompute the compatibility graph under scoped semantics (a prohibition fires
iff its arms have a common live horizon). Compute the consistency radius and the GYO residue.

**Verdict condition.** The structure is **confirmed** if (i) ≥ 70% of flat failures dissolve,
(ii) the residual failure locus is contained in the star of the element set named by the
surviving rows, and (iii) the GYO residue of the trigger sub-cover has ≤ 5 hyperedges. It is
**refuted** if the blind live-sets dissolve < 40% of failures, or if the residue grows.
Reference run (my non-blind assignment): 82.4% dissolved, residual = `Star(Fl)`, residue 4
hyperedges → 3 after refinement. Runtime: seconds. Elapsed effort: one afternoon of labelling.

## 8. Named proof obligations

- **PO-SHF-1.** `live(Fl) ∩ live(Xf) = ∅` is a theorem of the element definitions, not a
  fitted parameter: no cross-domain transfer completes within the transaction that opens and
  closes an atomic flash loan.
- **PO-SHF-2.** For every family `F` of scoped protocols, `⊕F` is admissible iff the empirical
  model `{s_P}_{P∈F}` has a global section of `𝒮` violating no forbidden co-liveness pattern.
- **PO-SHF-3.** (Vorob'ev instance) The primitive cover restricted to `El ∖ Star(Fl)` is
  α-acyclic; hence `⊕` is total and associative there. GYO-verified on the corpus; prove it
  for the primitive cover, not just the corpus instance.
- **PO-SHF-4.** `γ(s) = 0` is necessary but not sufficient for extendability; exhibit or rule
  out a false positive in this corpus — i.e. a family with vanishing Čech class and no global
  section. Until discharged, `γ` may filter but never certify.
- **PO-SHF-5.** The consistency radius `c` is monotone under `⊕` and `c(s) = 0` iff `s` glues;
  and its filtration localizes the obstruction to a unique minimal overlap.
- **PO-SHF-6.** Clique on the compatibility graph is FPT in the complement's vertex-cover
  number, which the corpus bounds by `|{P : Fl ∈ X_P}| = 8`; hence `ω` is exactly computable
  in `2^8` checks and the NP-hardness remark carries no force for this instance.
- **PO-SHF-7.** The residual cyclic core is exactly the triangle `{Fl@0, {Cp,Cl}, {Pl,Cd}}`;
  adjoining a magnitude section makes it α-acyclic, hence `⊕` total on the whole corpus.
- **PO-SHF-8.** Deferred net settlement (Uniswap v4) is expressible as `δ`-exactness of the
  value 1-cochain over the nerve; conservation laws are coboundary conditions, not new
  elements.
- **PO-SHF-9.** The prior collapse results (`Kripke–Kleene = (⊥,⊤)`; positive clauses exclude
  zero elements) are theorems about `|O| = 1` and fail for `|O| ≥ 2`; exhibit the smallest
  outcome set that restores binding.
