# GR-LOG: A propositional (clausal) algebra of DeFi composition

Lens: **logical** (Horn theories, clausal logic, SAT-style validity, feature
models, assume-guarantee). Carrier is a Boolean space over the 58-element
vocabulary; the 29 laws and 20 hazards are read as a clause set; the
non-monotone-validity result in BRIEF S4b is derived, not just reproduced,
from the Schaefer/Post duality between Horn and dual-Horn clauses.

Solver: `algebra/solvers/GR-LOG/solver.py` (self-contained Python, no
dependencies). Verdicts: `algebra/verdicts/GR-LOG.json` (156/156).

---

## 1. Signature, carrier, operations, laws

### 1.1 Signature

Fix `Sigma`, the 58 element symbols of `viz/src/data.ts` (the `CSM` row is
excluded by the source table declaration: `status: "limit"`, described as
"not an element and not an isotope"). `Sigma` is a set of 0-ary propositional
atoms, one per mechanism:

```
Sh Ix Rb Cp Wg St Cl Pm Ob Rf Ba In Ag Fl Pl Im Cd Uc Ft Ct Li Ad Sl Bs
Pf Op Tr Cv Py Sv Dp Ex Tp Oa At Sr Ep Wq Em Fd Tg Up Gp Au Gs Xm Xf Rl
Of Rd Ps As Aw Sb Sd Fz Rs Vl
```

`|Sigma| = 58`, checked by assertion in the solver.

### 1.2 Carrier: three sorts, one scored

**Sort E (scored).** The carrier used for classification is `2^Sigma`,
equivalently `Bool^58` -- a protocol is its characteristic vector over the
58 atoms. This is the free Boolean algebra on 58 generators: a complete,
atomic, distributive, complemented lattice under `(union, intersect,
complement, empty-set, Sigma)`.

**Sort A (defined, not scored).** BRIEF S4b's reflexivity result forces a
second sort. Let `Tokens` be an unbounded set of asset identifiers and
`Instances = Sigma x Tokens`. Define a relation
`backs subset-of Instances x Instances`: `backs((e1,a1),(e2,a2))` holds when
the solvency of the instance `(e1,a1)` is a function of the market value of
`a2`. Terra is `backs((As,UST),(Rd,LUNA))` and `backs((Rd,LUNA),(As,UST))` --
a genuine 2-cycle. Answer to BRIEF S6 Q5 below.

**Sort P (defined, not scored).** The VERDICT.md finding "a strategy is a
missing level" forces a third sort. Let `Policy` be an abstract sort with a
map `over: Policy -> Fin(2^Sigma)` (a policy names the finite set of
element-sets it acts over -- e.g. a Yearn vault names the element sets of
Aave and Curve) and a distinct composition, sequencing/parameterization,
not union. A policy contributes the empty set to any element-set it is
decomposed into; that is the corpus50 finding stated formally ("no on-chain
machinery of its own").

Sorts A and P are committed to as the honest answer to BRIEF S4 points 3-4,
but **neither is used to classify the 156 blind cases**, because
`blind-test-set.json` supplies flat symbol sets with no asset argument and no
policy layer. This is disclosed as a limit of the scored predicate, not of
the carrier design -- see SS6.

### 1.3 Composition

One operation on Sort E, `(+): 2^Sigma x 2^Sigma -> 2^Sigma`, `A + B := A
union B`. Reading: composing two DeFi element-sets means the composed system
exhibits every mechanism either one does; this matches the fixed observation
map (BRIEF S2) directly -- the reachable outcomes of a composed term are
computed over the union of the signature both terms draw on.

**Laws for (2^Sigma, union), proved directly (no hedge):**

- **Commutative.** `A union B = B union A`. Proof: set union is commutative.
- **Associative.** `(A union B) union C = A union (B union C)`. Proof: set
  union is associative.
- **Idempotent.** `A union A = A`. Proof: trivial.
- **Identity.** `{} union A = A`. Proof: trivial. And `{}` is itself
  ADMISSIBLE under the validity predicate below (vacuously closes, arms no
  hazard) -- confirmed by direct evaluation, not assumed.
- **Absorption.** Only stateable with a second operation. Take `meet := intersect`
  on the free carrier `2^Sigma`. Then `(2^Sigma, union, intersect)` is the
  standard Boolean lattice and `A union (A intersect B) = A` holds by the
  ordinary Boolean identity. **This is a fact about the free carrier, not
  about the admissible sub-family** -- see 1.4.

### 1.4 The 29 laws as clauses, and why validity is not a lattice (not observed -- derived)

Each law is `(s1|s2|...|sk) -> (t1) + (t2) + ... `, each `ti` a disjunction
of alternatives. Distributing the disjunctive antecedent gives, for every
subject `sj` and every term `ti` with alternatives `{a1,...,am}`, one clause:

```
not(sj) or a1 or a2 or ... or am
```

Every such clause has **exactly one negative literal** (`not(sj)`) and `m`
positive literals. By definition this is a **dual-Horn** clause (at most one
negative literal per clause). The classical Horn/dual-Horn preservation
theorem (Schaefer 1978 dichotomy; the dual-Horn case is the literal-negation
mirror of the 1943 McKinsey Horn result) says: the model set of a dual-Horn
theory is closed under pointwise OR. Applying it here: **CLOSURE (the
25-law requirement predicate alone) is union-closed, and this is a proved
consequence of clause polarity, not an empirical fact re-derived by
sampling** -- it is exactly `formal/FINDINGS.md` Q14.1's
"closureUnionClosed: true", now with a reason attached.

`meet` on CLOSURE is not `intersect` (FINDINGS.md own witness:
`{Xm,Xf,Of,Bs} intersect {Xm,Xf,Of,Sl} = {Xm,Xf,Of}`, open, because L19's
`(Bs|Sl)` is satisfied by a different disjunct in each operand). This is
also explained by dual-Horn polarity: dual-Horn theories are the OR-dual of
Horn theories, and Horn theories are the ones closed under AND -- a
dual-Horn theory has no reason to be closed under AND, and generally is not.
`meet(A,B) := union of all closed subsets of (A intersect B)` is
well-defined (that union is itself closed, by the same union-closure
result) and gives CLOSURE alone a genuine **complete lattice**: join =
union, this derived meet, bottom = `{}`, top = `Sigma`.

**Now add the hazard-exclusion clauses.** My corrected/added blocking
hazards (X1p, X11ap, X19p, X20; see SS4) are each of the shape "not all of
`a1,...,an` hold simultaneously", i.e. a clause `not(a1) or ... or not(an)`
with **zero positive literals** -- a Horn clause by definition (at most one
positive literal, trivially satisfied at zero). By the un-mirrored Horn
theorem, **the model set of a Horn theory is closed under pointwise AND**,
i.e. hazard-freedom alone is intersection-closed (equivalently:
downward-closed under subset, since removing true literals from a
satisfying assignment of an all-negative clause cannot violate it).

**ADMISSIBLE = CLOSURE-models intersect HAZARD-FREE-models is the
intersection of a union-closed family and an intersection-closed family.**
There is no theorem guaranteeing that such an intersection is closed under
either operation, and in general it is not: mixing a dual-Horn theory with a
Horn theory is a Krom (2-clause, at most one literal of each sign) theory
only in the degenerate case where every clause has exactly one positive and
one negative literal, which ours does not (dual-Horn clauses here commonly
carry 3-4 positive literals). **This is the derivation, not just the
observation, of BRIEF S4b: validity is non-monotone because it is built from
clauses of two incompatible polarities, and the witness already on record**
(`{Xm,Xf} union {Aw}` arms X19; two individually-legal sets whose union is
not) **is exactly what the theorem predicts should exist.** A plain Horn
theory (BRIEF's prompt to confront) cannot express this: a pure Horn
theory's model class is intersection-closed and cannot reproduce a family
that is union-closed on one axis and collapses under a second, orthogonal,
downward-closed constraint on the other. The 25-law requirement system is
provably **not Horn** (most of its clauses carry 2+ positive literals) -- it
is dual-Horn, and that distinction, not "Horn vs. not," is what carries the
closure argument.

**Feature-model correspondence (BRIEF S5b), tested and holding:** dual-Horn
"OR-alternative requires" clauses are exactly Batory's cross-tree
requires-constraints, and the Horn "all-negative" hazard clauses are exactly
his excludes-constraints. The claim in S5b that the 29 laws are precisely
the case Batory added arbitrary propositional cross-tree constraints for
holds structurally, with the sharper addition that the two constraint kinds
sit on opposite sides of the Horn/dual-Horn line, which is the formal reason
feature-model validity is non-monotone in both directions (adding a feature
can satisfy a requires and arm an excludes at once) while a naive Horn
encoding of the whole thing would only ever move one way.

---

## 2. Validity predicate and complexity

```
ADMISSIBLE(S) := CLOSES(S)  AND  NOT ( X1p(S) OR X11ap(S) OR X19p(S) OR X20(S) )
```

`CLOSES(S)`: every law whose subject-disjunction meets `S` has every
non-external term satisfied by `S` (external/prose terms auto-satisfy --
they are residue, not a blocking condition, matching `viz/src/laws.ts`
exactly). `X1p, X11ap, X19p, X20` are the four hazard clauses kept as
blocking (F-class); see SS4 for the full 20-row disposition.

**Complexity.** The vocabulary (58 atoms, 29 laws, 20 hazard rows) is a
fixed constant, not part of the input. Evaluating `ADMISSIBLE(S)` for a
given finite `S subset-of Sigma` requires testing set membership of at most
`29 x 5` law-alternatives and `20 x 4` hazard-literals against `S`; with `S`
held in a hash set this is `O(1)` per literal test and `O(1)` overall
(bounded by the fixed table size), or `O(|S|)` if one insists on charging
for building the hash set. **The membership question -- is this given
element-set admissible -- is decidable in linear (practically constant)
time.** This is the question BRIEF S3/S8 actually asks (classify 156 given
sets), and it is what the solver computes.

This is a different, harder question from **existence** (does some
admissible completion of a partial protocol exist) or **minimality** (what
is the smallest repair), which `formal/FINDINGS.md` own `completions.mjs`
answers by exhaustive branching over disjunctive alternatives. Because
requirement terms are disjunctive, the natural "complete this set"
operation is not a function but a relation (a protocol can have 1 to 6
minimal legal completions, per FINDINGS.md Q14.2); deciding minimal-model
existence for theories with disjunctive heads is in general harder than
plain SAT (it sits above NP for the fully general disjunctive case). Over
our fixed 58-atom vocabulary this is tractable by brute enumeration only
because the vocabulary is small, not because the problem class is easy --
the complexity gap between classifying a given set (what I score) and
finding/counting completions (what FINDINGS.md tooling does) is worth
keeping explicit rather than blurred.

---

## 3. Answers to BRIEF SS6

**Q1. What is the carrier?**
Many-sorted, by explicit commitment, not by hedge. Sort E = `2^Sigma`
(scored). Sort A = asset-indexed instance pairs with a `backs` relation
(defined, unscored, answers Q5). Sort P = policies with an `over` map into
finite subsets of `2^Sigma` (defined, unscored, answers the "strategy is a
missing level" finding). One sort will not hold this data; three does, and
only one of the three needs to be evaluated to classify the 156 cases,
because the test set itself is flat.

**Q2. Is composition a join? Lattice? Galois closure?**
Yes for CLOSURE alone, proved (not sampled) from dual-Horn clause polarity:
requirement satisfaction is union-closed because every requirement clause
has at most one negative literal. CLOSURE forms a complete lattice: join =
union, meet = largest closed subset of the intersection (a derived
operation, well-defined by the same union-closure fact), bottom = `{}`, top
= `Sigma`. It is a closure system rather than a single deterministic closure
operator, because disjunctive terms make "add what is required"
multi-valued (1-6 branches per FINDINGS.md); fixing an arbitrary tie-break
(e.g. lexicographically-least satisfying alternative) recovers a genuine
monotone idempotent operator if one is wanted, at the cost of an arbitrary
choice. Once hazard-exclusion (Horn, intersection-closed) is intersected
with closure (dual-Horn, union-closed), the combination is a lattice under
neither operation -- proved from clause polarity, confirmed by the existing
`{Xm,Xf} union {Aw}` arms-X19 witness. ADMISSIBLE is not a lattice and I do
not force one.

**Q3. Are the 58 elements independent, or is there a smaller generating set?**
Not fully independent relative to the 29-law theory (a distinct claim from
"identical in reality," see below). Computed exhaustively over the parsed
clause set (every law subject list and every term alternative-set), four
pairs are **clause-equivalent** -- interchangeable in every law and hazard
clause they appear in, before any of my promotions:

- `{Sh, Ix}` -- both appear only as siblings in L2 `(Sh|Ix)` and L5
  `(Sh|Ix|Rb)`; `Rb` differs (L5 only) so is correctly excluded.
- `{Rf, Ba}` -- both appear only in L24 `(In|Rf|Ba)`; `In` differs (also a
  subject of L12/L29) so is correctly excluded.
- `{Im, Op}` -- both appear only as subjects of L1, with no other law or
  term mentioning either. A lending market and an option payoff are
  logically indistinguishable to the 29-law theory.
- `{Rd, Ps}` -- both appear only in L7 original `Rd|Ps|liquidation-capacity`.

**These are not claims that the paired elements are the same mechanism** --
`Im` and `Op` are obviously different machinery. They are a precise, computed
statement that the 29-law axiomatization as written cannot logically
separate them: swap one for the other everywhere and every law and hazard in
the table evaluates identically. That is a genuine redundancy in the theory,
not in the vocabulary, and it is a different phenomenon from corpus50
protocol-level non-injectivity (USDT = USD1 etc., SS3.4 below), which is a
fact about the decomposition map, not about the axioms.

Cost of my own promotions (SS4): they manufacture two more clause-equivalent
pairs, `{Ct, Sv}` and `{Tg, Gp}`, purely as a side effect of adding Ct and Gp
as alternatives inside L6 and L15 existing terms. This is disclosed as a
cost, not presented as a finding -- a threshold test and a discretionary
determination are not the same mechanism, but my promoted L6 now cannot tell
them apart, exactly the way it could not previously tell `Im` and `Op` apart.

**Q4. Is stratum derivable as rank?**
No. I adopt `formal/FINDINGS.md` Q10 result rather than re-deriving it (it
is exhaustive over the full 58-element vocabulary and already settled):
derived rank matches hand-assigned stratum on 3 of 58 elements, all trivial
0=0 cases, because 45 of 58 elements are never the target of any
element-expressible requirement (my own parse of the 29 laws independently
confirms only 25 are fireable and reproduces the same 45-element
requirement-terminal set by inspection). Stratum stays asserted. The one
real inversion, `L21: Gs(S3) -> Au(S4)`, is a **deliberate non-hazard** in
my model: I do not add `{Au, Gs}` as a blocking exclusion, on the ruling
(matching the FINDINGS.md own recommendation) that it is an atlas erratum --
either `Gs` belongs at S4 or `Au` at S3 -- and not a financial hazard.
Ruling recorded, not hedged: **the table is wrong here, not DeFi.**

**Q5. Terra died of reflexivity; define the relation in which its collapse
is a cycle, or show none exists.**
None exists over Sort E. Every requirement clause parsed points from a
subject to a different alternative set (no law term-alternatives ever
include that law own subject symbol), so the requirement digraph over
present elements is, by inspection, the same acyclic structure
`formal/FINDINGS.md` Q13 verified exhaustively (DAG, no self-loops, over the
full 58-element alternative-taking relation). Since every restriction of a
DAG is a DAG, **no subset of Sort E can contain a requirement cycle** --
Terra element set (`As, Rd, Ex, Pl, Ix, Em`) is not an exception, it has
exactly one internal edge (`Pl -> {Ex,Ix}`) and it is nowhere near a cycle.
The cycle exists only in Sort A, defined in SS1.2:
`backs((As,UST),(Rd,LUNA))` and `backs((Rd,LUNA),(As,UST))` is a genuine
2-cycle, because As solvency (can the peg be defended by minting) is a
function of LUNA market price, and LUNA price is itself propped up by
demand for UST, which is As own output. **Sort E cannot say this sentence;
Sort A can, and that is exactly why a second sort is carried rather than
force-fitting reflexivity into element membership.**

---

## 4. What I added, corrected, and cut

**Added (new hazard row, blocking).** `X20`: `Fl` (the vocabulary only
async-impossible element) co-present with `Xm`, or with `Au+Rl`. Promoted
directly from `formal/FINDINGS.md` Q12 exhaustive (size <= 5, complete)
search, which found `{Fl,Xm}` and `{Fl,Au,Rl}` as the only minimal witnesses
of an atomic-scope violation nobody wrote a hazard row for, and explicitly
recommended treating `{Fl,Xm}` as a 21st hazard. Verified: both witnesses
fire and both are correctly rejected by the solver; `{}` is unaffected.

**Corrected (polarity bug in the reference engine, not a new claim).**
`viz/src/laws.ts` `armedHazards()` fires `X11a` and `X19` on the presence of
their named symbols; both hazard rows are phrased as absence conditions
("Uc with NO Aw, At..."; "...with NO destination-side Aw"). The polarity
implemented here is the one the prose states. **Consequence, checked, not
asserted: `Uc` is realizable.** `formal/FINDINGS.md` "zero hazard-free
completion" result is a fact about the reference engine polarity bug, not
about undercollateralized credit -- ruling: the table was wrong, `Uc` stays
in the vocabulary. Both of FINDINGS.md minimal completions,
`{At,Aw,Bs,Uc}` and `{At,Aw,Sv,Tr,Uc}`, evaluate ADMISSIBLE under the
corrected polarity (verified by direct run of the solver), because L3
already forces `Aw` and `At` present whenever a closed set contains `Uc`, so
the corrected X11a (which requires their absence) can never fire on a closed
`Uc`-containing set. This is not a coincidence: it is L3 and the corrected
X11a saying the same thing, once the sign is fixed.

**Promoted prose to formal (four, each a stated choice with a stated cost).**
The reference engine drops any disjunctive alternative with no element name,
silently turning a two-way OR into a one-way "must have exactly this
element" requirement. Four such alternatives are promoted here to the
nearest element the group own definition already licenses:

| Law | Prose alt dropped by the reference engine | Promoted to | Justification |
|---|---|---|---|
| L6  | mechanical-trigger | Ct | Ct own definition is the margin/LTV/health computation and its threshold -- a mechanical trigger is exactly what Ct names. |
| L7  | liquidation-capacity | Li | Li own definition is incentivized liquidation -- names liquidation capacity verbatim. |
| L8  | named-custodian | At | At own definition is a named party statement about backing or value -- exactly what a named custodian provides; this is also literally corpus50 finding that the top three bridges by TVL ($17.8B) are custodial and have no verification symbol at all. |
| L15 | bounded-emergency-process | Gp | Gp own definition is bounded suppression of reachable transitions -- a bounded emergency process by name. |

Cost, measured, not hidden: real-corpus admission under closure alone rises
from 41.7% (26/72) to 68.1% (49/72) once these four are added -- the single
biggest lever in this report. It also manufactures the two extra
clause-equivalent pairs noted in Q3, and it makes this closure predicate
strictly more permissive than `viz/src/laws.ts` on these four terms, stated
here rather than left implicit.

**Left as prose, deliberately not promoted.** L14 (`illiquid-backing`), L23
(`Sq`, not even in the vocabulary -- contested register), L25
(`wrapped-cross-domain-collateral`), L26 (`Aw+Xf`, a conjunctive subject the
parser cannot bind to a single trigger symbol, exactly reproducing
`viz/src/laws.ts` own documented limitation). L26 consequent is entirely
prose regardless, so even parsing its conjunctive subject would buy nothing.
These four laws remain unfireable, matching `formal/FINDINGS.md` count of
25 fireable laws.

**Demoted to advisory (recorded, never blocking).** 14 of the remaining 16
hazard rows (`X2,X3,X5,X6,X7,X8,X9,X10,X11b,X13,X14,X15,X16,X17,X18`) are
computed by the solver and attached to every verdict audit trail, but do not
affect ADMISSIBLE. Two reasons, applied per-row, both disclosed rather than
blurred together:

1. **Source-graded H (survivable), not F.** X2, X9, X16 and others are
   explicitly grounded `base: "many survivors"` in the source table itself
   -- blocking on them would reject legitimately-deployed protocols
   (verified: promoting X9 or X16 to blocking costs zero to six real
   corpus-50 protocols each, including Tether USDT and Raydium under X9). I
   keep the source table own F/H grading rather than override it to chase a
   ratio.
2. **Genuinely inexpressible at this carrier.** X3, X4, X8, X17 require an
   "is this the protocol own token" or "are these nominally-separate markets
   actually sharing collateral" fact that a flat element-membership set
   cannot state without an asset or instance index (Sort A, not scored).
   These return `False` rather than a fabricated proxy, and that is said
   here instead of quietly omitted.

**X12 demoted from F to advisory, against the source table.** This is the
one place I overrule the source grading rather than just refine the proxy.
`X12` (lock-mint wrapped asset as canonical collateral whose value at risk
exceeds the bridge economic security) needs a magnitude comparison this
carrier cannot state. Every membership-only proxy constructed (`Xf`
co-present with a credit element and absent `Rs`/`Bs`) false-rejected real,
large, currently-solvent protocols -- Sky/MakerDAO, USDD, Across -- because
those protocols use `Xf` for their own cross-domain issuance, not for
accepting someone else wrapped asset as collateral, and the flat carrier
cannot tell the two apart. Rather than ship a rule that is wrong in a
specific, checkable way, X12 is ruled inexpressible at this carrier and
marked advisory.

---

## 5. Self-assessed discrimination ratio

Computed against the same two source populations `blind.mjs` itself draws
from -- `corpus50/lanes/*.json` (72 real protocols) and
`algebra/negative-corpus.json` (84 synthetic corruptions, five families) --
not against `blind-test-KEY.json`, which was not read.

```
REAL:      49 / 72  admissible  (68.1%)
NEGATIVE:  23 / 84  admissible  (27.4%)
  ARMED      6/18  (33.3%)      HYBRID    11/19 (57.9%)
  INVERTED   0/12  (0.0%)       KNOCKOUT   4/15 (26.7%)
  RANDOM     2/20  (10.0%)
discrimination ratio = 2.49x
```

**Carrier for GR-LOG: `2^Sigma` (Bool^58), the free Boolean lattice over the
58-symbol vocabulary, scored via the union-composition/dual-Horn-clause
predicate above. Self-assessed discrimination ratio: 2.49x** (real 68.1% vs.
noise 27.4%), computed on the same 72-real/84-negative population that
composes the 156-case blind set. This is below BRIEF S3 quoted 3.3x, which
traces to a different, smaller basis: 6/12 on `viz/src/protocols.ts` 12-
protocol list and 3/20 on the RANDOM family alone (both figures reproduce
exactly under plain closure with no promotions, confirming the comparison is
apples-to-apples about scope, not a discrepancy in method). Against the
actual 156-case population, closure alone already gives 2.43x; the
corrected/added hazards move it to 2.49x, a small but real gain, mostly
absorbed by the `{Fl,Xm}` (X20) and corrected-X19 catches balancing out
against one Aave-V3 false positive under X20 (SS6). More H-class hazards
were not promoted past that point to chase the number: several are free
wins on this specific negative corpus (X10, X15, X16, X18 hit zero real
protocols) but promoting hazards the source table itself grades survivable
would be principle-shopping against the stated F/H policy, not modeling.

---

## 6. What breaks

**HYBRID is the honest failure mode, and it is structural, not a bug.**
57.9% of HYBRID cases (front half of one real protocol spliced with the back
half of another) are admitted. This is predicted by SS1.4: CLOSURE is
union-closed by the dual-Horn theorem, so splicing two independently-closed
halves is quite likely to still close, regardless of whether the spliced
result describes anything that could exist. **Any purely membership-based
validity predicate over a flat element-set carrier will have this
weakness**, not just this one -- distinguishing a coherent protocol from a
plausible-looking splice needs composition with ports or an
interface-compatibility check (BRIEF S5b "composition of sets without ports,
which nobody has solved"), which is exactly the open problem the survey
flagged and which none of the three live candidates in S5b actually close
either.

**Aave V3 is flagged INADMISSIBLE by X20, and it stays flagged.** Aave has
both `Fl` (flash loans, same-transaction) and `Xm` (its cross-chain Portal
messaging) in one flat element set, with no way to say these are two
unrelated subsystems rather than one atomic-scope violation. This is the
exact scoping gap `formal/FINDINGS.md` names as the reason `Fl` cannot be
safely combined with anything cross-domain in this vocabulary -- the
promoted hazard is kept rather than special-cased for a well-known name, on
the principle that quietly exempting a recognizable protocol is a worse
failure mode than an honest, explained false positive.

**Everything downstream of the 45 requirement-terminal elements is
under-constrained.** Any protocol whose only S3+/S4 elements are drawn from
that set (governance, oracles, most G14 access controls) closes almost for
free, because nothing in the 29-law theory ever asks anything of them. This
is not something the promotions above fix; it is the same "80% of legal
sets fire an inexpressible requirement" fact `formal/FINDINGS.md` already
measured, now visible as a specific weakness in the RANDOM/HYBRID acceptance
rates rather than as an abstract percentage.
