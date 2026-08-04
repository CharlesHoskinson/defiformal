# Composition / related-work corpus — INVENTORY

Scope: this file covers **Group A (compositionality proper)** and **Group C (the
composable-fragment question)**. Financial-contract formalisms are in
`INVENTORY-B.md`; the DeFi/smart-contract application check is in
`INVENTORY-DEFI.md` (+ `defi/`).

Target paper: `/root/DefiElements/paper/atlas.tex` ("An Algebra of Mechanism
Composition"). Claim labels below refer to that file.

Discovery note: **WebSearch was not used.** Discovery was API-only — OpenAlex
(`api.openalex.org`), arXiv Atom API, and direct author/repository URLs. DBLP
returned HTTP 500 throughout the session; Semantic Scholar rate-limited (429).
Page-level extraction used `scrapling` 0.4.11 (`extract get`, and
`stealthy-fetch --solve-cloudflare` against `dl.acm.org`).

---

## HEADLINE FINDING (Group C)

**The clique reformulation of `Prop:clique` is not novel as a technique; it is
novel in this setting.** Precisely:

* Recasting a compatibility/consistency relation as a graph and reading solutions
  off as cliques is **standard in constraint satisfaction**, under the name
  *microstructure* (Jégou, AAAI 1993).
* Conjecturing that graph is **perfect** in order to get polynomial-time maximum
  clique via Grötschel–Lovász–Schrijver is likewise **already a named move**:
  Salamon & Jeavons, *Perfect Constraints Are Tractable* (CP 2008).
* **BUT** in that literature the vertices are *variable–value assignments* and an
  `n`-clique is *one solution*. In `atlas.tex` the vertices are *entire admissible
  sets* and a clique is a *pairwise-composable family of solutions*. That graph —
  a compatibility graph **on the solution set**, under a composition operator —
  does not appear in the CSP microstructure literature, and no perfection result
  for it exists.
* No paper was found that asks for the **maximum** pairwise-compatible family in
  an interface theory or a contract algebra. Interface theories *postulate*
  reduction-to-pairwise (the incremental-design axiom, see A1b) rather than
  studying the resulting graph.

**Verdict: the open problem stands.** Conjecture `conj:perfect` should be stated
as open, positioned against the microstructure/perfect-CSP line as the nearest
precedent — and that positioning is a strength, because it supplies a proof
template (find odd holes/antiholes) and a payoff (GLS) rather than a competitor.

---

## A. Compositionality proper

### A1. de Alfaro & Henzinger, "Interface Automata"
Luca de Alfaro and Thomas A. Henzinger. *Interface automata.* In ESEC/FSE 2001
(Proc. 8th European Software Engineering Conf. / 9th ACM SIGSOFT FSE),
pages 109–120, ACM Press, 2001. DOI 10.1145/503271.503226.
Files: `dealfaro2001-interface-automata.pdf` / `.txt`.

**CAUTION — the 2001 PDF has a broken font encoding; `pdftotext` output is
garbage. Do not quote definitions from `dealfaro2001-interface-automata.txt`.**
Use instead the clean companion:

### A1b. de Alfaro & Henzinger, "Interface-based Design" (the citable statement)
Luca de Alfaro and Thomas A. Henzinger. *Interface-based design.* In Engineering
Theories of Software-Intensive Systems, NATO Science Series, Springer, 2005
(Marktoberdorf lectures; surveys the ESEC/FSE 2001 and EMSOFT 2001 results).
Files: `dealfaro2005-interface-based-design.pdf` / `.txt` — extracts cleanly.

Results, quoted verbatim:

* Optimistic (existential) compatibility:
  > "the interfaces in an open set G of interfaces (i.e., a set with free inputs)
  > are compatible if there exists an interface E (representing an environment
  > that provides all free inputs to the interfaces in G) such that the interfaces
  > in the closed set G ∪ {E} (without free inputs) are compatible."
  > "for interfaces, the environment is helpful, not adversarial."
* Compatibility is explicitly a **symmetric binary relation**:
  > "Incremental design suggests that we model compatibility as a symmetric
  > binary relation ∼ between interfaces, and composition as a binary partial
  > function ‖ on interfaces."
* **Incremental design** (the axiom that licenses reduction to pairwise):
  > "For all interfaces F, G, H, and I, if F ∼ G and H ∼ I and F‖G ∼ H‖I, then
  > F ∼ H and G ∼ I and F‖H ∼ G‖I."
  with the motivating requirement
  > "if the interfaces in a set F (representing the complete, closed design) are
  > compatible, then the interfaces in every subset G ⊆ F (representing a
  > partial, open design) are compatible."
* **Independent implementability** (their compositionality property), with the
  refinement preorder `F ⪯ F'` ("F' refines F"):
  > "For all interfaces F, F', G, and G', if F ∼ G and F ⪯ F' and G ⪯ G', then
  > F' ∼ G' and F‖G ⪯ F'‖G'."
  Footnote 4 records the direction: "the 'direction' of interface
  compositionality is top-down, from more abstract to more refined interfaces".
* Induced equivalence (footnote 2): "two interfaces F and G are equivalent if
  they are compatible with same interfaces, that is, if for all interfaces H, we
  have F ∼ H iff G ∼ H" — i.e. *twin vertices in the compatibility graph*.

**Relation to atlas.tex.**
* SUPPORTS `Prop:clique` and `Cor:nomax`. Downward closure of compatible sets is
  exactly de Alfaro–Henzinger's incremental-design requirement, and their
  compatibility relation is exactly `G_⊕`'s edge relation. Cite this as the
  precedent for *modelling compatibility as a binary relation*, then state the
  clique / `ω(G_⊕)` step as ours.
* MUST BE POSITIONED AGAINST on one point: interface theories obtain
  reduction-to-pairwise by **design** (they build languages satisfying incremental
  design). `atlas.tex` gets it for free because `⊕`-safety is *defined*
  pairwise; but `⊕`-**closure** (the subalgebra notion) is the stronger
  property, and the atlas already distinguishes the two. Say so explicitly — a
  referee from this community will otherwise read `Prop:clique` as trivial.
* CONTRASTS with `thm:noncong`: interface composition is a *partial* operation
  defined only on compatible pairs, so "composition does not preserve
  admissibility" has no analogue there — they make it a type error instead. This
  is the cleanest way to explain what `⊕` does differently.

### A2. Benveniste et al., "Contracts for System Design"
Albert Benveniste, Benoît Caillaud, Dejan Ničković, Roberto Passerone,
Jean-Baptiste Raclet, Philipp Reinkemeier, Alberto Sangiovanni-Vincentelli,
Werner Damm, Thomas A. Henzinger, Kim G. Larsen. *Contracts for System Design.*
Foundations and Trends in Electronic Design Automation 12(2–3):124–400, 2018.
(Text obtained from the INRIA research-report version, RR-8147, hal-00757488.)
File: `benveniste2018-contracts-system-design.pdf` / `.txt` (2.4 MB, full text).

Result: a meta-theory of contracts `C = (A, G)` (assumption / guarantee) with
refinement, **conjunction** (greatest lower bound, "shared refinement"),
**parallel composition**, and **quotient/residuation** (the adjoint of
composition: the contract a missing component must satisfy so that the whole
meets the spec).

**Relation to atlas.tex.** The **quotient/residual** is the declared analogue of
the atlas's repair section. Note the atlas already uses "residual" twice in a
different, order-theoretic sense (`𝒲` as the residual of the requirement
relation; the remark after Def. Warrants). Disambiguate in the related-work text.
Also relevant to `Cor:tarski`: the contract-algebra line is where "conjunction and
composition on the same carrier" is worked out lattice-theoretically.

### A3. Incer, "The Algebra of Contracts" (thesis)
Íñigo Incer. *The Algebra of Contracts.* PhD thesis, EECS Department, University
of California, Berkeley, Technical Report UCB/EECS-2022-99, May 2022.
File: `incer2022-contract-algebra-thesis.pdf` / `.txt` (full text).

Result: an algebraic treatment of assume–guarantee contracts. Operations:
refinement (partial order), **composition**, **quotient** (the adjoint / residual
of composition), **conjunction** (meet), **disjunction** (join), **merging**, and
**separation** (the adjoint of merging). Establishes which operations form
idempotent commutative monoids and which are adjoint pairs, and gives the
resulting lattice/quantale-flavoured structure.

**Relation to atlas.tex.**
* SUPPORTS the framing of the Repair section — quotient is the standard name for
  "the minimal thing to add", and `b(ℋ)` restricted to `X` is its
  clutter-theoretic analogue for the prohibition half.
* WOULD NEED POSITIONING AGAINST `Cor:tarski`. Incer gets a complete lattice
  *with* meet = conjunction, computed. `atlas.tex` gets a complete lattice from
  Tarski but explicitly flags that "Tarski also gives a lattice, not that meet is
  intersection", and lists that as open problem 1. A reader who knows Incer will
  ask why the meet is not computed the same way; answer it in one sentence.
* CAVEAT: verify the exact monoid/idempotence claims against the thesis text
  before citing them as such. I confirmed the operation set and the adjunctions,
  not a per-operation idempotence table.

### A4. Garlan, Allen & Ockerbloom, "Architectural Mismatch"
David Garlan, Robert Allen, John Ockerbloom. *Architectural mismatch, or, Why it
is hard to build systems out of existing parts.* In ICSE-17 (17th Int. Conf. on
Software Engineering), pages 179–185, ACM, 1995. DOI 10.1145/225014.225031.
Journal version: IEEE Software 12(6):17–26, 1995.
Restatement: David Garlan, Robert Allen, John Ockerbloom, *Architectural
Mismatch: Why Reuse Is Still So Hard*, IEEE Software 26(4):66–69, 2009,
DOI 10.1109/MS.2009.86.
File: `garlan2009-architectural-mismatch-icse17.pdf` / `.txt`
(this is the **ICSE-17 1995** paper despite the filename; the 2009 IEEE Software
restatement is paywalled and was not obtained — cite by DOI).

Result: the Aesop case study. Reuse of four off-the-shelf components cost roughly
five person-years against an estimated six months. The diagnosis is
*architectural mismatch*: conflicting **implicit assumptions** components make
about the structure of the system they will live in — assumptions about the
nature of components, the nature of connectors, the global architecture, and the
construction process. The core claim is that these assumptions are not written
down anywhere in the component's interface.

**Relation to atlas.tex.** SUPPORTS the corpus finding that 52 of 77 requirement
terms are prose. This is the canonical citation for "component assumptions are
almost always implicit", and it is 30 years old, which is the point: the atlas's
requirement/prohibition tables are an attempt to make exactly these assumptions
explicit for on-chain mechanisms. It also supports the Consequence remark
indirectly — Garlan et al. found the mismatches were *prohibitive* (pairwise
conflicts), not *generative*, which mirrors `meas:ablation58` (all 61 exclusions
come from prohibitions, none from the 79 positive clauses).

---

## C. The composable-fragment question

### C1. Jégou — the microstructure (the origin of "solutions are cliques")
Philippe Jégou. *Decomposition of domains based on the micro-structure of finite
constraint-satisfaction problems.* In AAAI-93, pages 731–736, AAAI Press, 1993.
(Not obtained as PDF — pre-web AAAI proceedings; cited via Cooper & Živný below,
whose reference list I read directly. Metadata verified, PDF not retrieved.)

Result: the microstructure of a binary CSP is the graph on variable–value pairs
`(X_i, a)` with an edge when the pair of assignments is jointly allowed.

### C2. Cooper & Živný — the survey that states the perfect-graph result
Martin C. Cooper and Stanislav Živný. *Hybrid Tractable Classes of Constraint
Problems.* In The Constraint Satisfaction Problem: Complexity and Approximability,
Dagstuhl Follow-Ups Vol. 7, pages 113–135, Schloss Dagstuhl, 2017.
DOI 10.4230/DFU.Vol7.15301.113. Open access.
File: `cooper2017-hybrid-tractable-classes.pdf` / `.txt` (full text).

Result, quoted verbatim from Section 5 (p. 128 of the PDF):
> "Solutions to I are in one-to-one correspondence with the n-cliques of the
> microstructure of I and with the size-n independent sets of the microstructure
> complement of I."
> "A graph G is perfect if for every induced subgraph H of G, the chromatic
> number of H is equal to the size of the largest clique contained in H. Since a
> maximum clique in a perfect graph can be found in polynomial time [33], the
> class of binary CSP instances with a perfect microstructure is tractable as a
> direct consequence, as observed in [50]. Perfect graphs can also be recognized
> in polynomial time [3]."
> "An alternative definition of perfect graphs is that a graph is perfect if and
> only if it is (odd-hole,odd-antihole)-free [4]."

with [50] = Salamon & Jeavons (C3), [33] = Grötschel–Lovász–Schrijver (C5),
[3] = Chudnovsky–Cornuéjols–Liu–Seymour–Vušković, *Recognizing Berge graphs*,
Combinatorica 25(2):143–186, 2005, [4] = the Strong Perfect Graph Theorem (C4).

**Relation to atlas.tex.** This is the single most important citation for the
composable-fragment-problem section. It shows that the *whole move* — graph,
clique, perfection, GLS — is an established route to tractability in constraint
satisfaction, which makes `conj:perfect` a well-motivated conjecture rather than
an ad-hoc one; and it shows that the move has been made on a *different graph*
(assignments, not solutions), which is what leaves the atlas's version open. Cite
it in exactly that two-part form.

Bonus: the survey also lists "instances which are arc consistent and **max-closed**
after independent (and possibly unknown) permutations of each domain" as a
perfect-microstructure class. `max-closed` is the ordered-domain name for the
polymorphism that on Boolean domains is union / dual-Horn — the atlas's
`Thm:polarity` fragment. This is a concrete hint about where perfection might come
from in `G_⊕`.

### C3. Salamon & Jeavons — the named result
András Z. Salamon and Peter G. Jeavons. *Perfect constraints are tractable.* In
P. J. Stuckey (ed.), CP 2008, LNCS 5202, pages 524–528, Springer, 2008.
DOI 10.1007/978-3-540-85958-1_35.
**PDF NOT OBTAINED** — Springer paywalled, no author-hosted copy found
(cs.st-andrews.ac.uk/~andras, azs.me.uk, and Oxford ORA all failed). Bibliographic
record verified via OpenAlex (25 citations); the result is quoted in C2 above.
Cite via C2 unless a copy is obtained.

### C4. Chudnovsky, Robertson, Seymour & Thomas — Strong Perfect Graph Theorem
Maria Chudnovsky, Neil Robertson, Paul Seymour, Robin Thomas. *The Strong Perfect
Graph Theorem.* Annals of Mathematics 164(1):51–229, 2006.
File: `chudnovsky2006-strong-perfect-graph-theorem.pdf` / `.txt` (150 pp, author
copy from web.math.princeton.edu/~mchudnov/perfect.pdf).

Result: a graph is perfect iff it contains no odd hole and no odd antihole as an
induced subgraph (Berge's conjecture).

**Relation to atlas.tex.** SUPPORTS the falsifiability claim in the remark after
`conj:perfect` — "falsifiable by exhibiting an odd hole or odd antihole in
`G_⊕`, which is a finite search at our scale" is exactly SPGT. Also cite
Chudnovsky–Cornuéjols–Liu–Seymour–Vušković 2005 (Berge-graph recognition in
`O(n^9)`) if you want to claim the test is polynomial rather than merely finite.

### C5. Grötschel, Lovász & Schrijver — clique in polytime on perfect graphs
Martin Grötschel, László Lovász, Alexander Schrijver. *The ellipsoid method and
its consequences in combinatorial optimization.* Combinatorica 1(2):169–197, 1981
(corrigendum Combinatorica 4:291–295, 1984).
Companion obtained: M. Grötschel, L. Lovász, A. Schrijver, *Geometric Methods in
Combinatorial Optimization*, in Progress in Combinatorial Optimization,
pp. 167–183, Academic Press, 1984 — file
`grotschel1984-geometric-methods-combinatorial-opt.pdf` (CWI open copy).
The 1981 Combinatorica paper itself was not obtained (Springer paywall); cite by
reference, it is uncontroversial.

Result: via the Lovász theta function and the ellipsoid method, maximum clique
(and maximum stable set, and chromatic number) is computable in polynomial time
on perfect graphs.

**Relation to atlas.tex.** SUPPORTS the payoff clause of the remark after
`conj:perfect`. Standard reference; also see Grötschel–Lovász–Schrijver,
*Geometric Algorithms and Combinatorial Optimization*, Springer 1988, Ch. 9.

### C6. Jeavons, Cohen & Gyssens — closure properties / the Pol–Inv Galois connection
Peter Jeavons, David Cohen, Marc Gyssens. *Closure properties of constraints.*
Journal of the ACM 44(4):527–548, 1997. DOI 10.1145/263867.263489.
**PDF NOT OBTAINED** (ACM DL served a Cloudflare interstitial to curl; the
scrapling stealthy path reached the landing page but not the PDF).

Result: the complexity of a constraint language is determined by its polymorphisms;
`Inv(Pol(Γ))` is the largest constraint language with the same tractability, via a
Galois connection.

**Relation to atlas.tex.** This is the *one place where a maximality result of the
right shape does exist*, and it is worth saying so precisely, because it sharpens
what is open. For a set of **relations**, the largest set preserved by a given
operation is unique and canonically described: `Inv(f)`. For union (Boolean `max`)
that largest set is exactly the dual-Horn relations — which is `Thm:polarity`.
So: *maximality is settled at the level of the constraint language, and open at
the level of the model set.* That contrast is the cleanest way to state open
problem 2, and it explains why `Cor:nomax` (no unique maximum) is not a
contradiction of Schaefer / Pol–Inv — different objects.
Related and citable: P. Jeavons, D. Cohen, M. Cooper, *Constraints, consistency
and closure*, Artificial Intelligence 101(1–2):251–265, 1998; A. Bulatov,
*Complexity of conservative constraint satisfaction problems*, ACM TOCL 12(4):24,
2011 (the "conservative constraint languages" dichotomy — searched for and
verified, but it classifies *languages*, not fragments of a model set, so it does
not answer the atlas's question).

### C7. Gopalan, Kolaitis, Maneva & Papadimitriou — graphs on solution sets
Parikshit Gopalan, Phokion G. Kolaitis, Elitza Maneva, Christos H. Papadimitriou.
*The Connectivity of Boolean Satisfiability: Computational and Structural
Dichotomies.* SIAM Journal on Computing 38(6):2330–2355, 2009 (ICALP 2006).
DOI 10.1137/07070440X. **PDF not obtained** (SIAM paywall); record verified.

Result: a Schaefer-style dichotomy for the *solution graph* of a Boolean CSP —
vertices are satisfying assignments, edges join assignments at Hamming distance 1
— covering connectivity, diameter and st-connectivity.

**Relation to atlas.tex.** The closest published precedent for *defining a graph
on the solution set of a Boolean constraint system and studying its structure*.
Different adjacency (Hamming-1, not `⊕`-compatibility) and different question
(connectivity, not clique), so it does **not** pre-empt `Prop:clique` — but it is
the right paper to cite for "graphs on solution sets of Schaefer-classified
systems are a studied object", and its dichotomy-by-polymorphism method is the
obvious first attack on `conj:perfect`.

### C8. Assume–guarantee decomposition (compositional verification)
Searched; **no maximality result of the required shape exists in this literature.**
The relevant line is automated *assumption generation*, not fragment maximality:
* Jamieson M. Cobleigh, Dimitra Giannakopoulou, Corina S. Păsăreanu, *Learning
  assumptions for compositional verification*, TACAS 2003, LNCS 2619:331–346.
* Jamieson M. Cobleigh, George S. Avrunin, Lori A. Clarke, *Breaking up is hard
  to do: an evaluation of automated assume-guarantee reasoning*, ISSTA 2006 /
  ACM TOSEM 17(2):7, 2008 — the negative result: on their benchmarks two-way
  assume-guarantee decomposition rarely beat monolithic verification.
* Mihaela Gheorghiu Bobaru, Corina S. Păsăreanu, Dimitra Giannakopoulou,
  *Automated assume-guarantee reasoning by abstraction refinement*, CAV 2008,
  LNCS 5123:135–148.
* Thomas A. Henzinger, Shaz Qadeer, Sriram K. Rajamani, *You assume, we
  guarantee: methodology and case studies*, CAV 1998, LNCS 1427:440–451.
(PDFs not downloaded — cited for framing, not for a technical result.)

**Relation to atlas.tex.** POSITIONING ONLY. This community asks "find *an*
assumption that makes the decomposition go through", never "find the *largest*
set of components that are pairwise compatible". Cobleigh–Avrunin–Clarke is
useful as an honest precedent for a measured negative result about decomposition,
which is the register `meas:frag` and `meas:width` are written in.

---

## A structural lead on conj:perfect (unverified — flagged, not claimed)

`Prop:twoeffects` says prohibitions are the only obstruction to ∪-closure. If, on
`Fix(Γ) ∩ Fix(Δ)`, `Γ(A ∪ B) = A ∪ B` (which needs checking — `Fix(Γ)` is stated
to be a Moore family, while the *models of* `ℛ` are stated to be union-closed, and
these are not the same set), then

  `A ∼ B  ⟺  for every H ∈ ℋ, H ⊄ A ∪ B`,

so non-adjacency for a single `H` depends only on the traces `t_H(A) = H ∩ A`:
`A ≁_H B ⟺ t_H(A) ∪ t_H(B) = H`. With `|ℋ| = 3` and the eight elements named in
`meas:clutter`, the complement of `G_⊕` would then be the union of three pullbacks
of a fixed graph on `2^H` (the "union covers `H`" graph), i.e. `G_⊕` is a
common-refinement of three blow-ups of very small graphs. Blow-ups preserve
perfection; a union of three such graphs need not. **This is a proof sketch to
test, not a result** — it identifies a finite check (perfection of the union-covers
graph on `2^H` for `|H| ≤ 5`, plus the interaction of the three) that would settle
`conj:perfect` without enumerating `|Adm|` vertices. Verify the `Γ(A ∪ B) = A ∪ B`
premise first; if it fails the sketch collapses.

---

## Negative findings, stated for the record

1. No paper found that **reformulates a compositionality/compatibility question
   as maximum clique** and studies the resulting graph class. arXiv full-text
   search for `maximum clique` AND `compositionality` returned zero results;
   OpenAlex searches for `compatibility graph maximum clique component
   composition` returned nothing on topic.
2. No **perfection result for a compatibility graph arising from a constraint
   system** was found. Perfection results in CSP are all about the
   *microstructure* (assignments), never a graph on the solution set.
3. No complexity result found for **"largest union-closed subfamily of a given
   family"** or **"largest sublattice of a given lattice"**, which would be the
   `⊕`-closed analogue of the `⊕`-safe clique question. Searched; nothing on
   topic. If the atlas wants a second open problem, this is a clean one.
4. `Cor:nomax` (safe sets closed downward, not under union) has an exact published
   analogue in de Alfaro–Henzinger's incremental-design requirement (A1b). Cite it;
   do not present downward closure as new.

## Files not obtained (paywalled), cite by DOI
* Salamon & Jeavons, CP 2008 (10.1007/978-3-540-85958-1_35)
* Jeavons, Cohen & Gyssens, JACM 1997 (10.1145/263867.263489)
* Gopalan et al., SICOMP 2009 (10.1137/07070440X)
* Bulatov, ACM TOCL 2011 (10.1145/1970398.1970400)
* Garlan et al., IEEE Software 2009 (10.1109/MS.2009.86)
* Grötschel, Lovász & Schrijver, Combinatorica 1981

---

## ADDENDUM — Salamon & Jeavons abstract (verbatim, obtained after C3 was written)

Retrieved from the SpringerLink landing page via `scrapling extract stealthy-fetch`
(the PDF remains paywalled; extraction saved as `salamon2008-perfect-constraints.md`).
Full abstract, verbatim:

> "By using recent results from graph theory, including the Strong Perfect Graph
> Theorem, we obtain a unifying framework for a number of tractable classes of
> constraint problems. These include problems with chordal microstructure;
> problems with chordal microstructure complement; problems with tree structure;
> and the "all-different" constraint. In each of these cases we show that the
> associated microstructure of the problem is a perfect graph, and hence they are
> all part of the same larger family of tractable problems."

This confirms the C2 characterisation and tightens the positioning for
`conj:perfect`: Salamon & Jeavons's contribution is precisely *"conjecture/prove
the graph is perfect, and several known tractable classes fall out as one
family"*. The atlas's `conj:perfect` is the same **move** on a different
**graph** (compatibility of admissible sets under `⊕`, not consistency of
variable–value assignments). State the analogy openly and claim only the transfer.

Note also their reference list points at S. Hougardy, *Classes of perfect graphs*,
Discrete Mathematics 306:2529–2571, 2006 — the standard catalogue to check
`G_⊕` against once it is computed, and the practical way to look for a *named*
perfect class rather than proving perfection from scratch.
