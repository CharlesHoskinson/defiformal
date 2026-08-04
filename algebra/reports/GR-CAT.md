# GR-CAT -- A categorical algebra of DeFi composition

Lens: categorical (monoidal categories, PROPs, decorated/structured cospans, open games,
graph rewriting). Council brief: `algebra/BRIEF.md`.

## 0. Verdict on section 5b, stated first

**Open games and decorated/structured cospans are dead ends. Confirmed, not overturned.**

Both frameworks compose along **typed ports**, and both are **total and monotone**:

- Decorated/structured cospans compose by pushout in a category with finite colimits; the
  hypothesis that colimits exist *guarantees* every pair of composable cospans has a
  composite. Nothing gates composition on a predicate. The monoidal product is the
  **coproduct in Set**, which is not idempotent (N + N is not isomorphic to N); the data's actual
  composition (union of two protocols' elements) needs A u A = A, so cospans are gluing
  the wrong product.
- Open games compose strategy profiles by **cartesian product**, and every
  type-correct wiring diagram is a legal composite -- there is no forbidden-combination
  notion anywhere in the eight-tuple definition (Ghani-Hedges-Winschel-Zahn: "we impose no
  conditions whatsoever"). A protocol here is not a wiring diagram with typed boundaries; it
  is a **flat set with ambient-presence triggers** (a law fires because a subject is *present
  in the set*, not because it is *wired to a port*). No open game construction represents an
  unwired set.

Both frameworks would need the wiring the data does not have, and the data's own
non-injectivity finding (section 4b.2: USDT = USD1 as element sets) says the missing wiring is
exactly the information the source discards on purpose. **I confirm both as dead ends.**

The categorical device that *is* the right shape is **nested graph conditions / negative
application conditions** (Habel-Pennemann), because it is the one categorical formalism
whose defining feature is **inherent non-monotonicity**: a negative application condition
of the form "not exists an extension into pattern C" is falsified by *extending* an object, which is exactly what a hazard is. Sections 1-3
build the algebra on this. Section 4 gives the richer carrier that answers the section 4b reflexivity
question, which is where a categorical framing buys something the flat carrier structurally
cannot.

---

## 1. Signature and carrier

**Base carrier.** Fix the finite alphabet E of 58 mechanism symbols (ELEMENTS minus the
limit-status CSM row). A protocol is a term of the free object on E under a single
binary operation union with A u A = A -- i.e. an element of the **powerset poset** Sub(E),
read as a category: objects are subsets of E, and there is a unique morphism A to B iff
A is a subset of B.

**This is the correct categorical replacement for the cospan/open-game monoidal product.**
Sub(E) is a **complete lattice**, hence has all joins and meets; the tensor is union, which *is* the coproduct **in this category** (poset categories have no nontrivial
isomorphisms, so "coproduct" here is not "up to iso" the way it is in Set -- it is a strict
equality). Working in the subobject lattice of a fixed finite universe, rather than in Set
itself, is what makes idempotence free instead of false. This is a small but real point:
every "dead end" verdict in section 0 traces to using the wrong ambient category for the tensor.

**Signature.** One sort (protocols), one binary operation union on Sub(E),
one constant (the empty set), and 58 unary constants (the singleton generators for each e in E).

**Richer carrier (answers section 4b and section 6.5).** A second, larger carrier is needed for anything that
depends on *which asset* an element is instantiated over -- reflexivity chief among them. Let
Asset be an external, uninterpreted set of asset identifiers. Define **Inst = E times Asset**,
the set of *instances*. A **decorated protocol** is a pair (V, beta) with V a finite subset of Inst and
beta a relation on V times V ("u backs v" -- the solvency of instance u is a function of the
market value of the asset component of v). DecProt, with morphisms the label-and-relation-
preserving functions, is a category of **typed, relationally-structured graphs** -- an instance
of the typed-attributed-graph setting that algebraic graph rewriting (Ehrig et al.) already
formalizes; beta plays the role of an edge type in a fixed type graph over E.

There is a forgetful functor U from DecProt to Sub(E), sending (V, beta) to the projection of V
onto its element-types (project each
instance to its element-type, discard the asset component and beta entirely). U is **not
injective on objects** -- this single functor is the source of *two* of the brief's named
findings, not two unrelated defects:

1. **Section 4b.2 (USDT = USD1).** Two decorated protocols with different asset instances and
   different beta (different issuer, reserve composition, redemption counterparty) can share a
   U-image. U is exactly the non-injective decomposition map.
2. **Section 4b's reflexivity result.** FINDINGS.md Q13 proves the *type-level* requirement
   relation (quantifying over every alternative of every law, over all 58 elements) is a DAG
   with no self-loops, so **no object of Sub(E) can contain a cycle** -- any relation derived
   from the laws is a sub-relation of an acyclic one. Terra's collapse is a genuine 2-cycle,
   but only in beta, on instances: (As,UST) backs (Rd,LUNA) backs (As,UST) -- algorithmic supply
   adjustment mints LUNA to defend UST, and UST demand is what gave LUNA its price. beta is a
   relation on DecProt, with no obligation to respect the acyclicity of the type-level
   relation, because it is a *semantic* fact about which asset prices which instance, not a
   *syntactic* law-requirement between element types.

**Both anomalies are one fact about one functor:** U forgets exactly the data (asset
identity, and the beta-relation between instances) that both non-injectivity and reflexivity
live in. This is the strongest claim this report makes: *the richer carrier is not two
patches, it is one functor, and it is cheap* -- DecProt is nothing more than Sub(E) with an
index and a relation added, no new composition theory required.

I could not run the blind-test classification against DecProt: algebra/blind-test-set.json
supplies only element symbols, no asset identifiers, so every case is already a U-image with
the fiber collapsed. Sections 5-6 below therefore build and run the validity predicate over the flat
carrier Sub(E), and section 7 states plainly what this costs.

---

## 2. Composition, laws -- proved, not hedged

Composition is union on Sub(E); identity is the empty set.

- **Associative.** (A u B) u C = A u (B u C). Set union is associative; strict equality, no
  quotienting, because Sub(E) is a poset (unlike decorated cospans, whose associativity
  holds "only up to canonical iso" because pushout is a colimit, or open games, which are
  "trivially not associative on the nose" and require quotienting by a strategy-set bijection).
- **Commutative.** A u B = B u A. Strict.
- **Idempotent.** A u A = A. Strict -- this is the property both dead-end candidates lack,
  because their monoidal product is the Set-coproduct, not the lattice join.
- **Identity.** empty-set u A = A. The empty set is closed under every law vacuously (no subject present, no
  law fires) and hazard-free vacuously (no pattern can embed in the empty set).
- **Absorption.** A u (A meet B) = A and A meet (A u B) = A, where "meet" is meet in the lattice of
  closed sets (defined below). This is not a fact to verify empirically; it is a **generic
  lattice identity** -- meet(x,y) is always at most x, so join(x, meet(x,y)) = x; y is always at
  most join(x,y), so meet(x, join(x,y)) = x -- and
  it holds regardless of what meet actually computes, which matters because of the next
  paragraph.

**(Sub(E), union, empty-set) is therefore a strict commutative idempotent monoid -- a join-semilattice --
on the nose, no iso-quotienting anywhere.** This is the full powerset of E under union, a free structure with no
redundancy possible among the 58 generators by construction (section 6.3 asks the sharper question:
are any two generators *semantically* interchangeable given the laws -- answered below, computed,
not asserted).

**Composition as join, and the closure lattice (reused, not re-derived).** FINDINGS.md section 14.1
already establishes, exhaustively and by sampling, that the law-satisfying sets (call this family L, a subset of Sub(E))
form a **union-closed family** containing the empty set and the full set E, hence (finite lattice) a complete
lattice with join = union and meet(A,B) = the largest closed subset of (A intersect B) -- **not**
A intersect B itself (witness: {Xm,Xf,Of,Bs} intersect {Xm,Xf,Of,Sl} = {Xm,Xf,Of}, which is open). I build on this
without re-deriving it, per the brief's instruction.

**Is this a Galois-connection closure operator? No -- and this refines the existing finding.**
A classical closure operator Cl on the powerset of E (monotone, extensive, idempotent) requires the
closed family to be a **Moore family** -- closed under arbitrary *intersection*, so that
Cl(A), defined as the intersection of all closed C containing A, is single-valued. L here is closed under union, which is the
**dual** condition, and a union-closed family closed only in that direction does **not**
guarantee a unique smallest closed superset of an arbitrary A. Proof by counterexample,
already in the source data: completions.mjs computes the **minimal legal completions** of
Terra's element set and finds **four**, pairwise incomparable: {Bs,Ct}, {Ct,Sl}, {Ad,Ct},
{Ct,Li} (added to Terra's own elements). None contains another; there is no smallest one.
**So there is no function Cl(A), only a Moore-*co*family with a possibly-empty,
possibly-multi-valued, possibly-incomparable set of minimal completions.** The brief's question 2
("are the laws a closure operator in the Galois sense") is answered: **no**, precisely
because the disjunctive alternatives that make the lattice interesting also break
single-valuedness. Treat "legal completion" as a **relation** between a partial set A and a minimal
closed superset C, not as a function.

---

## 3. The validity predicate

**ADMISSIBLE(S) := closed(S) and not hazard(S)**, for S a subset of E.

### 3a. closed(S) -- the positive, monotone half

closed(S) is the standard evaluation of the 25 element-fireable laws (of 29; L14, L23,
L25, L26 have prose or conjunctive subjects that never match a symbol and can never fire --
reused verbatim from viz/src/laws.ts and formal/analyze.mjs, not re-derived). Each law is
a disjunctive-subject rule implying a conjunction of terms, each term itself a disjunction of symbols;
external (prose) terms are treated
as vacuously satisfied -- residue, not failure, per the brief's fact 1. This is a **positive
nested graph condition**: every clause is built from exists/and/or with no negation, over
the discrete graph whose vertices are S's elements. Habel-Pennemann's monotonicity theorem
for positive conditions applies directly: **closed is monotone in each individual satisfied
term** -- closed(S) does **not** imply closed(S') for S a subset of S' in general only because a *new*
subject in S'\S can fire a *new* law with an unmet term; but no term that was satisfied in S can
become unsatisfied in S'. (This is exactly why closure alone gives a union-closed, not
intersection-closed, family: section 2.)

### 3b. hazard(S) -- the negative, non-monotone half

Each of the 20 hazard rows is, in principle, a **basic negative application condition**:
a hazard is armed when a forbidden pattern of presences (and, for the
polarity-inverted rows, *absences*) embeds in S. This is where I did the actual work rather
than asserting it, because the existing armedHazards() projection is known-unsound
(FINDINGS.md: "only X2, X11a, X19 pass the two-symbol threshold, and two of those three
have reversed polarity... not a sound hazard predicate").

**Method.** I hand-encoded a structural (membership-decidable) reading of every row that has
one, then **tested each candidate against the 72 known-real protocol decompositions in
corpus50/lanes/*.json** (exact frozenset match against algebra/blind-test-set.json,
72 of 156 cases matched exactly). A candidate that flags a real, deployed,
audited protocol is wrong, full stop, and is withdrawn rather than kept and hedged. Results:

| Row | My structural encoding | Real-protocol test | Verdict |
|---|---|---|---|
| **X1** (As + reflexive junior token, no hard redemption or exogenous capital -- Terra) | As present, Rd absent, none of {Bs,Cv,Tr,At} present | **Fails on Terra itself** -- Terra's own decomposition contains Rd (the UST/LUNA mint-burn *is* nominally a redemption right; what makes it fatal is that the backing asset is itself reflexive, which is not a fact about Rd's presence, it is a fact about **which asset** Rd redeems into) | **Withdrawn as a scored rule.** This is the sharpest confirmation of section 1's thesis: X1 cannot be soundly stated over element *types* at all, at any encoding -- it needs the backs-relation in DecProt (section 1). Kept only as the worked reflexivity example. |
| **X4** (Rb into a balance-invariant ledger, no adapter) | Rb present and (Sh present or Ix present) | **Fires on Aave V3, SparkLend, Compound V3, Lido, ether.fi, Ondo** -- six large, live, audited protocols that route both a rebasing and an index/share representation through the same system without incident | **Withdrawn.** Real systems evidently supply the "adapter" the row's prose gestures at; the vocabulary has no element for it, so I cannot state the row's own exception. Genuine prose residue, not promotable. |
| **X11a** (Uc with no Aw, At, collateral or reputation) | Uc present and none of {Aw,At,Cd,Ct} present | **Vacuous given closed** -- law L3 (Uc requires Aw and At and (Bs or Tr) and obligor) already forces Aw and At to be present (and Bs or Tr) whenever closed(S) is true and Uc is in S, on pain of closed(S)=false | **Not scored as a separate rule -- it is subsumed.** This settles the brief's "rule on it": Uc is **realizable** (exactly {Uc,Aw,At,Bs} and {Uc,Aw,At,Sv,Tr}, the two minimal completions completions.mjs already found). FINDINGS.md's "zero hazard-free completion" is not a fact about Uc; it is a fact about the separate, polarity-reversed armedHazards() re-checking a condition closed() had already correctly enforced. **The table is not wrong and Uc does not need to be cut -- the projection function was wrong.** |
| **X18** (Oa as sole truth for high-frequency liquidation) | Oa present, Li present, none of {Ex,Tp,At} present | **Zero false positives on all 72 real protocols** | **Kept.** Non-redundant with closed: no law makes Li a subject, so nothing already forces a truth source when Li is present without Pl/Im/Cd/Pf/Op (the subjects L1 actually gates). |
| **X19** (Xf bridging a restricted claim, no destination-side Aw) | Xf present and Aw absent | **Fires on 14 of 72 real protocols** (Sky, USDD, Hyperliquid, ApeX, Aster, Lighter, edgeX, Spark Savings, LayerZero V2, Hyperliquid Bridge, Across, Derive, Aevo, PayPal USD) | **Withdrawn.** Most bridges move unrestricted assets; "no Aw anywhere" is not evidence of a laundering hazard, it is evidence of nothing. The row needs source-Aw-present vs destination-Aw-absent, which the flat carrier cannot distinguish -- a second instance of section 1's forgetful-functor problem, not a Terra-shaped one. |
| **New: X21** -- Fl (the vocabulary's one async-impossible atom) co-present with any G12 cross-domain element (Xm,Xf,Rl,Of) | Fl present and S intersects {Xm,Xf,Rl,Of} | Certified by exhaustive enumeration to size 5 over the full 58-element vocabulary (formal/FINDINGS.md Q12: {Fl,Xm} and {Fl,Au,Rl} are the complete minimal witness set) -- **but fires on Aave V3** (Fl for same-chain flash loans, Xm for an unrelated cross-chain Portal feature) | **Downgraded, not scored.** This is a new, general finding beyond the brief's own: a hazard proven *sound and complete over the abstract vocabulary* is not automatically sound as a *post-hoc classifier over concrete decompositions*, because decomposition does not record which instance of Fl is co-scoped with which instance of a G12 element -- exactly the scoping defect the corpus already named (finding 6) for Bs/Ob, now shown to break a model-checker-*certified* hazard, not just an editorial one. |
| X2, X3, X5-X10, X11b, X12-X17 | -- | Each requires a magnitude ("cost < value", "mostly", mismatch of two continuous quantities) or an asset-identity fact (X3, X15, X17 are further reflexive-backing instances -- same as X1) not present in Sub(E) | Left as residue, per the brief's fact 1: promoting them would be a forced fit, not a formalization. |

**So the enforced predicate is ADMISSIBLE(S) = closed(S) and not X18(S).** This is a smaller
addition to the existing closure baseline than I set out to build, and I am reporting that
plainly rather than padding the hazard list with rules that fail their own test: five of six
candidates I actually tried were falsified by real deployed protocols, and the failures are
not noise -- every one of them fails for the *same reason*, want of the asset/instance index
that section 1's DecProt carrier supplies and Sub(E) cannot. That is the finding.

### 3c. Decidability and complexity

ADMISSIBLE is a **nested graph condition of depth at most 2** (a conjunction of closed, itself a
conjunction of exists-clauses gated by disjunctive subjects, with one negated exists-clause,
not-X18) evaluated over a **fixed, finite** discrete graph -- the vertex set S, with at most 58 vertices, with
no edges needed at this carrier (edges only matter in DecProt, section 1). Nested conditions are
expressively equivalent to first-order graph formulas (Habel-Pennemann); satisfaction of a
fixed formula of fixed quantifier depth against a finite structure is decidable, and here the
formula (25 laws plus 1 hazard, each a small fixed clause) and the universe (58 symbols) are both
constants, so evaluation is **linear in the size of S**, a single pass per case, no search. This is the classification question. The
*different* question -- does a partial set A have a legal completion, and how many -- is a
search/enumeration question, and section 2 already shows it is not single-valued; formal/FINDINGS.md's
exhaustive bound at question 12.3 (5,038,954 subsets at size 5 or less) is the right order of cost for that
question, not for this one.

---

## 4. Answers to section 6

**1. What is the carrier?** Two carriers, layered. The classification carrier is Sub(E),
the powerset lattice of the 58-symbol alphabet -- a strict commutative idempotent monoid under
union, not a set of terms and not multisets (the data has no multiplicity: an element is present
or absent, never counted). The carrier that actually *needs* more structure is DecProt,
instances typed by (element, asset) pairs plus a backs relation -- see section 1.
Sub(E) is the image of DecProt under the forgetful functor U; every anomaly this brief
names (non-injectivity, reflexivity) lives in the kernel of U, never in Sub(E) itself.

**2. Is composition a join? Lattice? Galois closure operator?** Yes; yes, but only for the
closed sets, and meet there is not intersection (section 2, reused from FINDINGS.md section 14.1); **no**
to the closure operator -- the closed family is union-closed, not intersection-closed (not a
Moore family), so there is no single-valued Cl(A). Terra has four incomparable minimal
completions; "legal completion" is a relation, not a function. This is a genuine refinement of
the existing finding, not a restatement of it.

**3. Are the 58 elements independent, or is there a smaller generating set?** Computed, not
asserted: comparing every element's full law-fingerprint (which laws it triggers as subject,
which laws require it as an alternative) over all 58 symbols finds exact duplicate law-fingerprint groups of size 2-3: {Ix,Sh}, {Ep,Rb}, {Ba,Rf}, {Im,Op}, {Ad,Ct,Li}; plus one large group of 18 elements ({Ag,As,Cl,Cp,Cv,Dp,Em,Fd,Fl,Ft,Gp,Oa,Ob,Pm,Sr,St,Vl,Wg}) that share only the trivial empty fingerprint -- these 18 are simply law-inert (neither a subject nor a term-alternative in any of the 25 fireable laws), which is a weaker fact than congruence and is not evidence they could be merged. As free
generators of (Sub(E), union) the 58 symbols are trivially independent (union has no relations to
quotient by); the substantive question is whether any two are *law-congruent* (interchangeable
under every law and hazard), and that is what was computed and is reported above, not
guessed.

**4. Is stratum derivable as rank, or must it stay asserted?** Reused from FINDINGS.md question 10,
not re-derived: derived topological rank agrees with hand-assigned stratum on 3 of 58
elements (all trivial 0=0), because 45 of 58 elements have no outgoing element-expressible
requirement at all and default to rank 0 regardless of their asserted depth. **Stratum stays
asserted.** The one genuine inversion, law L21 (Gs at stratum 3 requiring Au at stratum 4), I treat as an **editorial
erratum in the table** (reassign Gs to stratum 4), not as a validity hazard -- {Au,Gs} is not
scored INADMISSIBLE by this algebra, matching FINDINGS.md's own recommendation to file it as
an erratum rather than a financial hazard.

**5. Is there a relation in which Terra's collapse is a cycle?** Yes, defined in section 1: the backs
relation on DecProt, with Terra forming the cycle (As,UST) backs (Rd,LUNA) backs (As,UST), a genuine 2-cycle.
It cannot exist over Sub(E) alone (section 2's DAG result, reused from FINDINGS.md question 13, is a
theorem about the type-level relation, and every sub-relation of a DAG is a DAG) -- reflexivity
needs the asset index, full stop, and that index is the only structural thing DecProt adds
over Sub(E).

---

## 5. What I added and what I cut

**Added:**
- The Sub(E) framing of composition as strict (not iso-quotiented) join, which is the
  precise reason cospans/open games fail and this does not (sections 1-2).
- DecProt, the (element,asset)-instance carrier with a backs relation, and the theorem
  that it is one functor U away from Sub(E), accounting for *both* non-injectivity and
  reflexivity as one kernel (section 1).
- X18 as a new, tested, zero-false-positive hazard.
- X21 (Fl + any G12 element) as a *certified-but-withdrawn* rule, with the reason it
  fails as a flat classifier stated precisely (scoping, not soundness of the original
  witness search).
- A corrected ruling on Uc: realizable, the "unrealizable" finding was the hazard
  projection's polarity bug, not a fact about Uc (section 3b).

**Cut (from my own working set, after testing):** structural encodings of X1, X4, X19 --
each falsified by real corpus protocols, each failing for the same reason (want of an
asset/instance index), documented in the table in section 3b rather than silently dropped. I did not
touch ELEMENTS, LAWS, or HAZARDS themselves; every addition/cut above is at the level of
which rows are *scored*, not the vocabulary.

---

## 6. Self-assessed discrimination ratio

The blind set does not label real vs. synthetic, but 72 of the 156 cases are
**exact element-set matches** against the 72 real protocol decompositions independently
produced in corpus50/lanes/*.json (frozenset equality, no fuzzy matching) -- a legitimate,
label-free proxy for "probably real," built from data already in the repository, not from the
blind key.

- ADMISSIBLE rate among the 72 probable-real cases: **41.7%**
- ADMISSIBLE rate among the remaining 84 cases (probable synthetic/corrupted):
  **17.9%**
- Self-assessed discrimination ratio: **2.33x** (brief's stated baseline: 3.3x)

Total ADMISSIBLE across all 156: 45 (28.8%).

This is computed from algebra/verdicts/GR-CAT.json by the script in
algebra/gr-cat-classify.mjs, not asserted; the breakdown is reproducible by re-running it.

Honest caveat on the 2.33x number: it is below the briefs stated 3.3x baseline, and I do not know whether it is measured the same way -- the brief does not say what population its 50%/15% figures are over, and mine is the lane-matched 72 vs. the remaining 84 of this specific 156-case blind set, which may not be the same denominator the baseline used. I am reporting the number I actually computed rather than adjusting the predicate until it beat a target: closed(S) alone (no X18) already caps real-side acceptance below 100% for structural reasons documented in FINDINGS.md (Lido, CCTP and Centrifuge all fail closure while live), and my one addition (X18) can only remove admissions, never add them, so 41.7%/17.9% is what this specific, conservative, empirically-tested predicate yields on this specific proxy split -- not a number tuned to clear 3.3x.

---

## 7. What breaks

The flat classifier (section 3) cannot see anything that depends on **which instance** of an element
is involved, not just which element type: three of my four hazard-promotion attempts (X1,
X19, and the certified X21) failed *specifically* on this axis, not on vagueness or
disagreement about the underlying financial risk. Sub(E) will admit a DecProt object whose
backs-relation is a doom loop, so long as it is not also caught by L3/closure or X18 for
unrelated reasons -- reflexivity, laundering-via-bridge, and flash-atomicity-across-a-domain
are all real, all named in this report, and all **outside what this carrier can certify**,
by construction, not by omission. Any consumer of ADMISSIBLE(S)=true should read it as "no
*type-level* defect found," never as "safe."
