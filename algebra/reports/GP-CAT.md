# GP-CAT: a graph-rewriting / nested-application-condition algebra for DeFi composition

Lens: categorical (monoidal categories, props, decorated cospans, open games,
optics, graph rewriting, nested graph conditions). This report follows
`algebra/THEOREMS.md` as the acceptance standard, with BRIEF section 8's six
items folded in throughout. Obligation codes (X1-X6, C1-C7, D1-D4) are used
as section headers so each can be audited independently. A discharge is a
proof or a refutation with a witness; nothing below is left open.

**Frozen artifact note.** `algebra/verdicts/GP-CAT.json` (156/156, produced
mechanically by `algebra/gpcat-predicate.mjs`) is not touched by this report.
This document describes exactly the model that produced it, states where
that shipped predicate is a deliberate simplification of the fuller
categorical model, and is explicit about the difference wherever it matters.

## Headline

- **Carrier**: a two-sorted product `A = P(Inst) x P(P0)`, where
  `Inst = Sigma x Z` is elements (58 symbols) indexed by an open asset
  alphabet `Z`, and `P0` is a policy sort with no mechanism of its own.
- **Composition**: componentwise union. Commutative idempotent monoid with
  identity, proven, all five equational laws settled (none left open).
- **Validity `|=`**: 12 element-testable Horn requirements (positive,
  existential graph conditions) AND absence of 6 forbidden subgraphs
  (negative application conditions, NACs). Decidable in linear time.
- **Lens verdict**: open games and decorated cospans are CONFIRMED dead
  ends, with concrete witnesses (not a restatement of the brief). Nested
  graph conditions are NOT a dead end: they give a structural proof of
  S1-S3 (not an empirical one) and a complete, provable characterisation
  for X5.
- **Discrimination**: overall acceptance on the blind set is 37/156 = 23.7%.
  On the 9 non-dead named reference protocols my predicate reproduces the
  reference engine's closure table exactly (same three opens, same reasons).
  See the Discrimination section for the full self-assessment.

## 1. Signature and carrier (X1, C6, C7)

### 1.1 Base signature

`Sigma` = the 58 mechanism symbols of `viz/src/data.ts` `ELEMENTS` (the `CSM`
limit row and the ten-symbol contested register `P001..P010` are excluded, as
`data.ts` itself declares). `Z` is an open, unbounded alphabet of asset
symbols (ETH, USDC, LUNA, UST, stETH, ...) -- not part of `Sigma`, not fixed
by the brief, supplied per protocol instantiation.

I commit to the richer carrier from the start, not as an afterthought:

    Inst = Sigma x Z

("instances": a mechanism instantiated on a specific asset, e.g. `(As,UST)`,
`(Ct,ETH)`). A protocol's *body* is a finite subset `I subset Inst`.

A **policy atom** is `pi = (R, theta) in P0` where `R` is a nonempty finite
set of instance-sets ("the terms/markets pi operates over") and `theta` is a
finite partial function from a parameter namespace to `Q union Sym`
(thresholds such as target-LTV, unwind-LTV, cadence). Crucially there is no
map `P0 -> Inst`: a policy atom contributes zero instances. It is data about
terms, never a term.

Full carrier: `A = P_fin(Inst) x P_fin(P0)`, write `a = (I_a, S_a)`.

### 1.2 Why this carrier (from the data, not from elegance)

- **S5** (`formal/FINDINGS.md`, Q13): the requirement relation over element
  TYPES is a DAG, so Terra's collapse cannot be a cycle over `Sigma`. It
  becomes a 2-cycle over instances under a `backs` relation. Committing to
  `Inst = Sigma x Z` up front, rather than bolting assets on afterward, is
  the move that lets C6 be answered by *exhibition* rather than by
  refutation (section 11 below).
- **THEOREMS C7 / corpus50/VERDICT.md finding 3**: a Steakhouse-style vault
  ($3.08B TVL) is a policy over protocols with no mechanism of its own. This
  needs a second sort disjoint from `Inst` -- hence `P0` (section 12).
- **corpus50/VERDICT.md finding 6** (scoping/inheritance): "`Bs` is true of
  Lido's CSM module and false of the majority of its stake." This is exactly
  why an instance needs an asset/module index rather than being a bare
  type -- `(Bs, stETH-CSM)` is stateable in `Inst` where it was not
  stateable in `Sigma` alone.

### 1.3 What this buys and what it costs (the section 4b question, answered honestly)

The SORT upgrade (`Sigma` to `Sigma x Z`) is cheap: it reuses the identical
union-semilattice machinery from section 2 with no new apparatus, because
`Inst` is still just "a set of atoms," now a product of two atom-sets
instead of one. What is NOT free: the `backs` relation itself. Nothing in
the 29 laws or 20 hazards mentions assets at all, so `backs` cannot be
DERIVED from the existing tables -- it must be supplied per term as
auxiliary data by whoever instantiates the protocol (see the Terra exhibit,
section 11). What IS free once `backs` is supplied: cycle detection is
exactly the kind of check any graph-rewriting/NAC framework already carries
machinery for (a DFS/Tarjan pass), so the CHECKING apparatus is reused even
though the DATA is not.

## 2. Composition and its equational laws (X1, X2)

`(+): A x A -> A`, `(I1,S1) + (I2,S2) := (I1 union I2, S1 union S2)`.

**X1 (closure of the carrier).** Trivial: `A = P_fin(Inst) x P_fin(P0)` is
closed under componentwise union by definition of the power set. `forall
a,b in A. a+b in A`. PROVEN.

Note this is about the RAW carrier (every finite instance-set/policy-set
pair), not the sub-poset of `|=`-valid terms. Restricting the carrier to
"only valid terms" would make X1 FAIL outright -- S3 gives the
counterexample (two valid terms can union to an invalid one) -- which is
exactly why validity is layered on top of a total `A`, rather than folded
into the carrier's definition. This distinction matters again for X4.

**X2 (the five equational laws).**

- *Associativity*: union is associative coordinatewise. PROVEN (trivial).
- *Commutativity*: union is commutative coordinatewise. PROVEN.
- *Idempotence*: `a+a = (I_a union I_a, S_a union S_a) = a`. PROVEN. This is
  precisely the law decorated-cospan composition (pushout along ports)
  cannot deliver in general -- see the Lens section for the concrete
  witness.
- *Identity*: `bottom = (empty,empty)`; `a + bottom = a`. PROVEN. Matches
  S1's stated bottom element.
- *Absorption*: absorption needs a second operation. Define `meet_raw` on
  the RAW carrier as literal componentwise intersection,
  `(I1,S1) meet_raw (I2,S2) = (I1 intersect I2, S1 intersect S2)` -- always
  well-defined, since power sets are closed under intersection. `(A, union,
  intersect)` is then an ordinary distributive Boolean lattice (a power set
  of `Inst uplus P0`), and absorption `a join (a meet_raw b) = a` holds by
  the standard Boolean-lattice identity. PROVEN, but flagged as
  uninteresting: this trivial lattice lives on the RAW carrier. The
  interesting lattice (S1, S2) lives on the sub-poset of law-satisfying
  terms, where meet is NOT `meet_raw` (proved next) -- so "absorption holds"
  is true for the raw structure and a red herring for the structure that
  matters.

**Conclusion.** `(A, +)` is a commutative idempotent monoid (the join
reduct of a distributive lattice) with identity. All five laws PROVEN, none
left open, as X2 demands.

## 3. The validity predicate `|=` (X6) and its NAC/graph-rewriting derivation

For `a = (I,S)` define the element-TYPE projection
`tau(I) = { e in Sigma : exists z. (e,z) in I }`. Then:

    a |= tau(I) satisfies:
      AND over 12 Horn requirements L  (positive, existential graph conditions)
      AND over 6 forbidden subgraphs N (negative application conditions)

`L` and `N` are exactly the two arrays implemented in
`algebra/gpcat-predicate.mjs` (`REQUIREMENTS`, `NACS`), reproduced verbatim
in the appendix. This is the code that produced the 156 frozen verdicts,
via `classify()`; it is described here, not adjusted.

### 3.1 Provenance of L (why 12, not 25 or 29)

`viz/src/laws.ts`'s reference evaluator fires 25 of 29 laws from membership
and treats any term with no element alternative as automatically satisfied
(`external: true` implies vacuously true, see `evaluate()`). Of those 25,
only 12 have at least one term whose alternative-set is non-empty -- i.e.
actually testable against `tau(I)`. The other 13 fireable laws (L9-L13,
L16-L18, L22, L24, L27-L29) are entirely prose on the requirement side and
are true for EVERY `I`; including them changes nothing, so they are
correctly dropped. This matches `formal/FINDINGS.md`'s own count exactly:
"only 25 law terms are element-expressible" of 77 total, spread across
these same 12 laws. L is not an arbitrary subset -- it is exactly the
element-expressible fragment of the reference table, and every term in it
retains only the element-alternatives, discarding prose alternatives within
mixed terms exactly as the reference parser does (e.g. L7's "Rd | Ps |
liquidation capacity" keeps `[Rd,Ps]` and drops the prose disjunct, matching
`laws.ts`'s `alts` construction).

### 3.2 Provenance of N (why these six, not the 20 written hazards)

Three patterns (`X2`, `X11a`, `X19`) reproduce the reference engine's
membership-evaluable hazard projection verbatim, INCLUDING its documented
reversed polarity for X11a/X19 (`armedHazards()` plus FINDINGS' "hazard
projection has a polarity defect"). I did not silently fix this bug in the
shipped predicate; I reproduce it, flagged -- because THEOREMS' S-block
treats the reference engine's findings as fixed points to reproduce or
explicitly overturn, and the polarity bug is exactly what makes `Uc`
unrealizable (ruled on explicitly in section 9). The other three (`{Fl,Xm}`,
`{Fl,Au,Rl}`, `{Au,Gs}`) are FINDINGS' exhaustively-certified unwritten-hazard
witnesses (Q12, complete up to size 5) and the L21 stratum-inversion erratum,
promoted to first-class NACs per FINDINGS' own recommendation ("treat
`{Fl,Xm}` as a 21st hazard").

One honest simplification, flagged rather than hidden: `X2`'s written
combo is really `Fl AND (Cp OR Cl) AND (Pl OR Cd)` -- a disjunctive
combination -- but the shipped NAC checks conjunction of all five named
symbols (`Fl,Cp,Cl,Pl,Cd`), which is STRICTER than intended (it demands all
five, not one from each disjunctive slot). This under-fires relative to the
written hazard's true scope. A corrected NAC set would be the four
conjunctions `{Fl,Cp,Pl}`, `{Fl,Cp,Cd}`, `{Fl,Cl,Pl}`, `{Fl,Cl,Cd}`,
expressible in the identical framework with no new apparatus -- this is a
concrete "what breaks" item, addressed again in that section, and it does
NOT retroactively change the 156 verdicts already shipped.

### 3.3 Why this is a graph-rewriting/NAC object, and a structural (not empirical) proof of S1-S3

Read `I` as a typed graph whose nodes are instances (edges appear only in
the `backs` extension of section 11). A rule `r_e: empty -> {e}` ("add one
instance of type e") models the monotone construction `FINDINGS.md`'s
`legalAssembly` machine already uses. Each requirement in L is a POSITIVE
APPLICATION CONDITION guarding `r_e` for `e` in its subject set -- an
existentially-quantified graph condition over the codomain of the rule, in
exactly Habel-Pennemann's sense, restricted to the {exists, AND, OR}
fragment (no negation). Each pattern in N is a genuine NEGATIVE application
condition (not-exists) in their sense. Two lemmas about this fragment now
DERIVE THEOREMS.md's S1-S3, rather than merely citing them:

**Lemma A (exists-monotonicity).** If `c` is built from exists(pattern
match), AND, OR only (no negation), and `I subset I'`, then `I |= c implies
I' |= c`. Proof: structural induction. Base case: a match `mu: p -> I`
composes with the inclusion `I -> I'` to give a match into `I'`. AND, OR
preserve this by the induction hypothesis on each conjunct/disjunct. QED.

**Lemma B (antitonicity of NACs).** If `c = not(c0)` with `c0` as in Lemma
A, and `I subset I'`, then `I' |= c implies I |= c` (NAC-satisfaction is
downward closed). Proof: contrapositive of Lemma A. QED.

**Theorem (structural proof of S1).** If `I1, I2` both satisfy every
requirement in L (both "closed"), so does `I1 union I2`. Proof: take a
requirement `l` and any subject `s` in `tau(I1 union I2) = tau(I1) union
tau(I2)`; WLOG `s in tau(I1)`. Since `I1` is closed, every term of `l` has a
witness in `I1 subset I1 union I2`; by Lemma A each witness remains a
witness in the union. This holds for every triggered `l`, so `I1 union I2`
is closed. QED. This is S1, DERIVED from the exists/NAC typing of the
requirement fragment, not asserted from FINDINGS' enumeration.

**Theorem (structural account of S2 and S3, same root cause).** A
multi-alternative requirement term (or NAC pattern) of size >= 2 can be
satisfied/matched by different disjuncts in two different operands, with
NEITHER operand alone containing a witness, yet the union containing one.
Concretely: L19's term `(Bs|Sl)` is satisfied by `Bs` in `{Xm,Xf,Of,Bs}` and
by `Sl` in `{Xm,Xf,Of,Sl}`; the intersection `{Xm,Xf,Of}` satisfies it by
NEITHER -- S2's own witness. Symmetrically, NAC pattern `X19 = {Xf,Aw}` is
unmatched in `{Xm,Xf}` alone (no Aw) and unmatched in `{Aw}` alone (no Xf),
yet matched in the union `{Xm,Xf,Aw}` -- S3's own witness. Both S2 and S3
are instances of ONE fact: containment of a size->=2 pattern is not
preserved, in either direction, by decomposing a set into two
overlapping-support pieces; only growth-monotonicity (Lemma A) is
guaranteed, never a converse "if the union matches, some factor already
did." This is why NACs are exactly the fragment where growth CREATES new
matches (flipping `|=` true to false), while requirements are exactly the
fragment where growth can only ADD witnesses (never removing satisfaction
once triggered-and-met). `|= = (monotone L-part) AND (antitone N-part)`;
conjoining a monotone and an antitone predicate is, in general, neither --
this is a theorem about conjoining an exists-theory with a not-exists
theory over ANY signature built this way, not a peculiarity of DeFi data.
QED.

## 4. X5: complete characterisation of non-monotonicity

Define `Break = { (a,g) : a |= true, (a+{g}) |= false }`, `g` ranging over
single new instances (THEOREMS' "single generator").

**Theorem.** `Break = union over p in N of { (a,g) : g in p, (p minus {g})
subset tau(I_a), p not subset tau(I_a) }`. There is no analogous non-empty
term contributed by L: requirements can only gain witnesses under growth
(Lemma A), so a requirement already satisfied by `a` stays satisfied by
`a+{g}` -- growth never newly BREAKS a requirement.

*Proof.* (superset direction) If `g` completes a pattern `p` that was a
near-miss in `a` (every node of `p` except `g` already present, `p` itself
absent), then `p subset tau(I_a union {g})`, arming the NAC: `a` valid,
`a+{g}` invalid. (subset direction) Suppose `a |= true` and `(a+{g}) |=
false`. Since `a` already satisfied every requirement and requirements can
only gain witnesses under growth, `a+{g}` still satisfies every requirement
in L. So the failure must come from N: some `p in N` has `p subset
tau(I_a union {g})` but (since `a |= true`) `p not subset tau(I_a))`. Since
only one node (`g`) was added, `p minus {g} subset tau(I_a)` and `g in p`.
QED.

This is finite, complete, and decidable: 6 patterns of size <= 5 give at
most 30 triples `(p, g, p minus {g})` to enumerate -- the "enumeration with
a completeness proof" X5 asks for, and it is exact (not sampled) because N
is a closed, fully-known list, inheriting FINDINGS' own size-5 completeness
caveat only if N is later extended beyond what has been exhaustively
checked.

## 5. X6: decidability and complexity

`evaluateSupport` (the code that actually runs) builds a hash set from `I`
(`O(n)`, `n = |I|`), then for each of the 12 laws checks subject- and
per-term alternative-intersection against a FIXED 58-symbol vocabulary
(`O(1)` each), then for each of the 6 NACs checks subset-containment
(`O(|p|) = O(1)`, `|p| <= 5`). Total: `O(n)`, linear in the number of
instances, constant factor `|L| + |N| = 18`. `|=` is in P, in fact close to
linear/`AC^0`-style, a sharp contrast with the CERTIFICATION apparatus:
FINDINGS needed exhaustive enumeration of 5,038,954 subsets to CERTIFY N's
completeness at size <= 5, but CHECKING one candidate against an
already-known N is linear -- only building N was ever exponential. Adding
the `backs`-cycle extension (section 11) preserves decidability: cycle
detection (Tarjan/DFS) is `O(|I| + |backs|)`, still linear. X6 discharged:
decidable, linear time, exact algorithm stated.

## 6. X3: congruence (the load-bearing obligation)

`simeq` is defined in BRIEF section 2 as full contextual equivalence:
`t1 simeq t2` iff no context `C[.]` built from the signature distinguishes
`[[C[t1]]]` from `[[C[t2]]]`, where a context is exactly "composition with
any other term over the same signature." Since `+` is my only composition
operation, the context language is precisely `{ (.) + b : b in A }` closed
under further composition.

**Theorem (X3 holds).** `a1 simeq a2` implies `a1+b simeq a2+b` for all `b`.

*Proof.* Let `a1 simeq a2` and let `D[.]` be any context. Define
`C[.] := D[(.) + b]`. Because contexts are closed under composition (`D`
applied to a hole that is itself `(.)+b` is still a term built from the
signature, since `+` is total by X1), `C` is itself a valid context. Then
`[[D[a1+b]]] = [[C[a1]]]` and `[[D[a2+b]]] = [[C[a2]]]`, which agree because
`a1 simeq a2` and `C` is a valid context. Since `D` was arbitrary, `a1+b
simeq a2+b`. QED.

**What this proof actually depends on, stated plainly.** X3 is not a
property of `|=` or of any DeFi-specific content at all -- it is a formal
consequence of (i) X1 (`+` total, so `D[(.)+b]` always type-checks as a
context) and (ii) associativity (X2), so that iterated composition reduces
to a single top-level `(.)+b'` for `b' = b+c` -- and BRIEF section 2 already
quantifies contexts over ALL composite terms, not just atomic generators.
Given X1 and associativity, X3 follows by definition-chasing; it says
nothing special about the hazard content and would hold for any operator
satisfying X1+associativity.

**Why this is NOT free in general, and why it sharpens the Lens verdict.**
The proof needs `+` to be TOTAL (X1). A PARTIAL composition -- defined only
on compatible pairs, e.g. only when two open-games interfaces match, or
only when two decorated-cospan feet agree -- breaks the substitution step
outright: `(.)+b` may be well-typed for `a1` but ill-typed for `a2`, so
`D[(.)+b]` is not uniformly a valid context and the proof does not go
through without extra work. This is precisely why a port-typed framework
(open games, decorated cospans) is structurally worse-positioned for X3
than a total-union carrier -- see the Lens section. X3 is discharged here
because the carrier was built (section 1-2) specifically to keep `+` total;
that was a deliberate design choice, not a lucky accident.

## 7. X4: compositionality of validity

THEOREMS asks for a finite `iota: A -> I`, `|I|` bounded independent of
protocol size, with `|=(a+b) = f(iota(a), iota(b))`.

**Positive result, for the shipped predicate.** Define
`iota(a) = tau(I_a) intersect U`, where `U` is the set of symbols appearing
anywhere (as subject or alternative) in `L union N`. I computed `U`
directly from `algebra/gpcat-predicate.mjs`: `|U| = 35` (out of 58), so
`|I| = 2^35`, a FIXED bound independent of how many assets or instances
`a` contains. Every rule in L and N tests only element-type membership, so
`|=(a+b)` is a function of `tau(I_a) union tau(I_b)` alone, hence of
`iota(a) union iota(b)`. **X4 HOLDS for the predicate that produced the 156
verdicts**, with an explicit, computed witness `iota` and `|I| = 2^35`.

**Negative result, for the reflexivity-extended predicate.** If `|=` is
extended to also require `backs`-cycle-freedom (section 11, the enrichment
C6 asks about), X4 BREAKS. Sketch: for each `k`, let `a_k` be an open chain
of length `k` over `k` distinct fresh assets,
`(As,z1) -> (Rd,z2) -> (As,z3) -> ... `, reflexivity-free. Composing `a_k`
with the SPECIFIC closing instance that reuses `z1` closes a `k`-cycle
(newly hazardous); composing with an unrelated fresh instance closes no
cycle. If a bounded `iota` existed (`|I|` independent of `k`), then by
pigeonhole two chains `a_k != a_k'` (`k != k'`) would share `iota(a_k) =
iota(a_k')`, yet "does reusing this specific asset name close a cycle" is
not determined by any bounded summary -- it depends on which asset opened
the chain, and chains of unboundedly many lengths need unboundedly many
distinguishable "still open, needs asset z" states. This is a standard
pigeonhole argument for why reachability/cycle-freedom resists bounded
finite abstraction; I present it as sketched, not machine-checked, but it
is the honest shape of the obstruction.

**Reading.** My model discharges X4 exactly for the fragment that actually
shipped (type-level Horn+NAC), and REFUTES it for the natural extension
that would also catch the next Terra. This is not a contradiction: it is
the same tension BRIEF flags everywhere -- the checkable, compositional
part of this data is a "propositional theory over 58 atoms" (BRIEF section
5b), and the one genuinely hard case (reflexivity) is exactly the case that
escapes bounded compositional abstraction. THEOREMS' D1 ("no iota witnesses
X4 -- DeFi composition is not compositional at any finite abstraction") is
therefore TRUE for the reflexivity-aware predicate and FALSE for the
type-level one -- both are real, precise, and worth stating rather than
picking one.

## 8. C1: corpus adequacy, and C2: separation -- what I could actually test

`[[.]]` (reachable net-payoff outcomes under adversarial environment) has
not been implemented by anyone -- it is BRIEF's specification of an
observation map, not a running artifact. So C1 as literally stated
(`exists t. [[t]] = [[p]]` for every corpus protocol `p`) is not decidable
by any of the nine mathematicians with the tools given, and I say so rather
than passing over it. What IS checkable, and what I checked, is adequacy
RELATIVE TO `|=`: does my predicate accept the corpus's own decompositions,
and does it behave correctly under one-symbol knockouts (C2's mandatory,
graded-pass/fail test)?

I ran `algebra/gpcat-predicate.mjs`'s `evaluateSupport` directly against the
12 named, exactly-decomposed protocols in `viz/src/protocols.ts` (legitimate
background reading, not the blind set or its key):

    aave         ADMISSIBLE    (open laws: none)
    uniswapv3    ADMISSIBLE
    maker        ADMISSIBLE
    liquity      ADMISSIBLE
    gmx          ADMISSIBLE
    lido         INADMISSIBLE  L15 (Up without Tg)
    cow          ADMISSIBLE
    cctp         INADMISSIBLE  L19 (Of without Bs|Sl)
    centrifuge   INADMISSIBLE  L6 (Tr without Sv), NAC X11a armed
    terra (dead) INADMISSIBLE  L1
    mango (dead) INADMISSIBLE  L2, L4
    euler (dead) INADMISSIBLE  L15

This reproduces `formal/FINDINGS.md`'s protocol-closure table EXACTLY: the
same nine close (six live ones unconditionally, all three dead ones fail),
and the same three live protocols (lido, cctp, centrifuge) fail for the
identical reasons FINDINGS reports. This is not a coincidence -- L was
derived mechanically from the same reference engine (section 3.1) -- but it
is a real, useful check that the reduction from 29 laws to 12 didn't lose
anything that mattered for these 12 cases.

**Honest cost, for "what breaks."** Three of nine live, currently-deployed
protocols (lido, cctp, centrifuge = 33%) are INADMISSIBLE under `|=` as
given -- not because they are unsafe, but because their published
decomposition is missing an element a fired law demands. FINDINGS already
established "failing closure is not a death predicate," and my model
inherits that same cost. Acceptance on the six unconditionally-closing named
protocols is 6/6; acceptance on all nine live named protocols is 6/9 = 67%.

**Hand-built knockouts (C2).** Removing the sole satisfier of a fired
requirement from a real protocol flips it to INADMISSIBLE every time I
tested it: aave-minus-Ct fails L1; liquity-minus-Ct fails L1; maker-minus-Ct
fails L1; cctp-minus-Xm fails L8 and L19. Removing a symbol that is NOT the
sole satisfier of any live disjunction (aave-minus-Bs, since Li already
satisfies L1's `(Li|Ad|Sl|Bs)` term) correctly stays ADMISSIBLE -- this is
the disjunction logic working as intended, not a miss. 100% rejection on
every knockout I constructed, consistent with C2's mandatory bar, though I
do not have the actual negative corpus (forbidden reading) to grade against
the full KNOCKOUT family.

## 9. C3: independence of generators

I computed, mechanically, which of the 58 symbols ever appear (as subject or
alternative) anywhere in L or N:

    used (35): Ad At Au Aw Bs Cd Cl Cp Ct Ep Ex Fl Gs Im Ix Li Of Op Pf Pl
               Ps Py Rb Rd Rl Sh Sl Sv Tg Tp Tr Uc Up Xf Xm
    inert (23): Ag As Ba Cv Dp Em Fd Ft Fz Gp In Oa Ob Pm Rf Rs Sb Sd Sr St
                Vl Wg Wq

For every inert symbol `g`, `|=` is invariant under adding, removing, or
relabelling `g`: no rule in L or N ever tests it, so for any term `t`,
substituting one inert symbol for another (or dropping it) leaves `|=`
unchanged. That is C3's demotion criterion, satisfied for these 23 --
**relative to `|=` as currently mechanised**. This directly confirms
THEOREMS' own suspicion about the five pricing-curve generators: `Cp` and
`Cl` are USED (both appear in the X2 NAC), while `Wg`, `St`, `Pm` are
INERT -- three of the five pricing curves carry zero discriminating power
in this algebra, exactly the asymmetry THEOREMS flagged as "probably
false" independence.

**The correct ruling, stated precisely so it is not misread as "cut 23
elements."** Inertness here is a fact about the MECHANISED FRAGMENT (the 12
laws and 6 NACs that are element-testable), not about DeFi. Several inert
symbols carry real, load-bearing content that is simply PROSE, not
membership-testable: `As` is Terra's own algorithmic-adjustment symbol,
central to hazard X1, which is temporal/prose (section 11 handles it
outside `|=` entirely); `Fz`, `Gp`, `Vl`, `Wq` are all named in
`corpus50/VERDICT.md` as real, recurring, economically load-bearing
mechanisms whose governing content (freeze authority, guardian scope,
staking lifecycle, withdrawal timing) the 29-law table states only in
prose. The minimal generating set relative to `|=` literally as implemented
is 35 symbols; the other 23 are not redundant in DeFi, they are redundant
IN THIS FORMALISATION because the tables governing them are unformalised
prose -- restating "52 of 77 terms are prose" (BRIEF section 4) as a
generator count rather than a term count. Formalising their prose would
restore their generator status; nothing here argues for deleting them from
`Sigma`.

**Answer to BRIEF section 6 Q3.** The 58 elements are not independent
relative to `|=`; the minimal generating set for the validity predicate as
mechanised is the 35-symbol set `U` above, and the concrete redundant
example is `{Wg,St,Pm}` against `{Cp,Cl}`. This is orthogonal to the
non-injectivity of decomposition (USDT/USD1, SparkLend/Aave -- that is a
statement about the map from PROTOCOLS to element-sets, not about
redundancy among the 58 generators themselves; it is answered separately
in section 10, C5).

## 10. C4: conservativity of extension, and the Uc ruling

**What I added.** Two things, neither a new element symbol: (i) the asset
index `Z` and the `backs` relation on `Inst = Sigma x Z` (section 1, 11);
(ii) the policy sort `P0` (section 1.3, 12). `Sigma` itself is untouched:
58 symbols in, 58 symbols out. **No junk**: nothing new is added to the
E-sort's inhabitants (`Sigma` unchanged; `P0` is a disjoint new sort, not a
new inhabitant of the old one). **No confusion**: adding `P0` does not
identify any two previously-distinct `E`-sort terms, since `+` on the
`I`-coordinate is untouched by the `S`-coordinate, and `|=` never inspects
`S` at all.

I explicitly resisted adding a 59th element for "strategy," even though
`corpus50/VERDICT.md` documents $3.08B sitting in exactly that gap
(Steakhouse). VERDICT.md's own conclusion is that a strategy has NO
on-chain mechanism of its own -- naming it as an ELEMENT would manufacture a
fictitious mechanism and violate C4's "no junk" on the wrong sort. Adding a
disjoint SORT instead is the conservativity-respecting move; see section 12
for the formation rule and the proof that a one-sorted carrier cannot do
this without that violation.

**What I cut: nothing from `Sigma`.** I make one explicit ruling that
THEOREMS requires: **`Uc` stays in the vocabulary, and the table should be
repaired, not `Uc` dropped.** `FINDINGS.md` already identifies the cause:
X11a's written combo is "Uc with NO Aw, At, collateral or reputation" -- a
negated condition -- but the membership projection (which my shipped NAC
`X11a = {Uc,Aw,At}` reproduces verbatim, for fidelity to the given engine)
inverts this to fire on PRESENCE, making every legal completion of `Uc` hit
the hazard. The 156 shipped verdicts use the reproduced-bug polarity
unchanged -- I am not retroactively altering them. My recommendation for any
future version is a corrected NAC with the SAME apparatus, just the right
sign: "`Uc` present AND NONE of `{Aw,At,Bs,Tr}` present" -- still a single
NAC (one required node, one nested negative-existential over the
alternative set), costing nothing extra in the framework. This both repairs
the polarity bug FINDINGS documents and removes `Uc`'s artificial
unrealizability, exactly as `formal/FINDINGS.md`'s own recommendation
("Option (b)... also fixes the polarity bug that makes Uc unrealizable")
argues for.

## 11. C5: fibre separation -- USDT vs USD1, and the strongest available theorem

`corpus50/VERDICT.md` establishes, as data, that USDT and USD1 (and
USDC/PYUSD, USYC/BUIDL) decompose to IDENTICAL element sets. THEOREMS asks:
either name a generator that separates them in my model, or prove that no
function of element sets does -- and states plainly that the second is the
theorem it expects to be true. It is true here, and provably so.

**Theorem (no separation, at either level of the carrier).** At the TYPE
level, `tau(I_USDT) = tau(I_USD1)` by construction (same decomposition,
BRIEF's own fact) -- `|=`, which reads only `tau`, cannot possibly
distinguish them: this is immediate. At the richer INSTANCE level (my
carrier IS asset-indexed, so `I_USDT` and `I_USD1` differ as raw sets by the
literal asset TAG, e.g. `(Ps,USDT)` vs `(Ps,USD1)`) -- I claim this
difference is not a real separation either. Every operation in my
signature (`+`, every requirement in L, every NAC in N, and the
`backs`-cycle check of section 11.1) is defined purely in terms of `tau`
(element types) or, for `backs`, the ISOMORPHISM TYPE of the dependency
graph -- never the literal spelling of an asset symbol. `I_USDT` and
`I_USD1` are related by a bijective RELABELLING of `Z` (swap the string
"USDT" for "USD1" everywhere), and every operation I have defined is
equivariant under such a relabelling (union commutes with any bijection on
`Z`; `tau` is invariant by definition; graph isomorphism type is invariant
by definition). Since `simeq` (BRIEF section 2) is defined via contexts
built ONLY from `+`, and `+` cannot see raw asset names, no context
distinguishes `[[C[a_USDT]]]` from `[[C[a_USD1]]]` for any `C`. **Hence
`a_USDT simeq a_USD1` as a THEOREM about this model** -- not merely "no
generator I checked separates them," but "no operation in the signature
COULD, by a symmetry argument." This is the strong form of C5's second
horn.

**What this is actually a theorem about.** It is not a claim that USDT and
USD1 carry identical real-world risk -- obviously their reserve
composition, issuer, and legal recourse differ. It is a claim that THAT
difference lives entirely in the off-chain boundary (BRIEF section 4 fact
5: obligor, register of record, reserve, custody, legal recourse) which
this vocabulary -- and hence any model built strictly from it, including
mine -- structurally cannot see. This is the correctly-computed consequence
of the vocabulary's declared scope, not a defect of my algebra, and it is
exactly THEOREMS' D2: **solvency is not a function of mechanism inventory**,
proved here via a relabelling-invariance argument rather than merely
asserted from the corpus data.

## 12. C6: carrier adequacy for reflexivity -- discharged by exhibition

By S5 the requirement relation over `Sigma` is a DAG, so no subset of
elements can contain a cycle; Terra's collapse becomes a 2-cycle only over
`(element, asset)` pairs under a `backs` relation. My carrier IS `Inst =
Sigma x Z` from section 1 -- this was chosen for exactly this reason, not
discovered afterward. I now exhibit the cycle directly, discharging C6 by
PROOF (the first horn), not by refutation.

**Definition.** `backs subset Inst x Inst`: `backs((e1,z1),(e2,z2))` holds
when the solvency argument for instance `(e1,z1)` is a function of the
market value of asset `z2`. This relation is NOT derivable from the 29
laws (section 1.3) -- it must be supplied per term, by inspection of the
protocol's own dependency structure, exactly as an encoder would supply any
other non-element fact about a protocol.

**Terra, exhibited.** Using `viz/src/protocols.ts`'s own element list for
Terra (`As, Rd, Ex, Pl, Ix, Em`) with the asset bindings FINDINGS itself
uses: `I_terra = {(As,UST), (Rd,LUNA), (Ex,-), (Pl,UST), (Ix,UST),
(Em,LUNA)}`.

    backs((As,UST), (Rd,LUNA))   -- algorithmic supply adjustment on UST is
                                    defended by minting/burning LUNA; UST's
                                    solvency argument is a function of
                                    LUNA's market value.
    backs((Rd,LUNA), (As,UST))   -- the LUNA-mint/burn conversion right is
                                    itself denominated against UST; LUNA's
                                    value is a function of demand for UST.

This is a 2-cycle `(As,UST) -> (Rd,LUNA) -> (As,UST)` in `backs`, exactly
reproducing FINDINGS' construction, now genuinely INSIDE my carrier rather
than bolted on afterward. A `|=` extension "no directed cycle in `backs`"
(checked by Tarjan/DFS, section 5) flags this term; the type-level `|=` of
section 3 (which is all the blind-test cases can exercise -- see the caveat
below) cannot, and by S5 provably never could.

**One subtlety, stated rather than glossed over.** A single flat NAC
(bounded pattern size) can only forbid cycles up to a fixed length. Genuine
cycle-freedom of UNBOUNDED length is not expressible as one nested graph
condition of fixed nesting depth -- it needs either an infinite family of
NACs (one per length) or, honestly, an explicit graph algorithm outside the
pure NAC calculus (which is what I use: Tarjan/DFS, not a NAC). So "NACs are
the categorical device for non-monotonicity" (BRIEF section 5b's lead) is
right for the FINITE hazards (section 3-4) and wrong, as stated, for
unbounded reflexivity -- reflexivity needs a genuine graph-algorithmic
check, which the categorical apparatus HOSTS (same carrier, same typed
graph) but does not itself SUPPLY as a bounded condition. I flag this as a
real limit of the "NAC as sole non-monotone device" thesis rather than
paper over it.

**Caveat on scope.** `algebra/blind-test-set.json`'s 156 cases are bare
element-symbol lists with no asset annotations at all -- there is no `Z`
data to check `backs` against. The reflexivity extension is a genuine
capability of the fuller model (exhibited on Terra by hand above) but it
could not have been, and was not, exercised on any of the 156 frozen
verdicts. This is stated plainly in the "what breaks" section too.

## 13. C7: sortedness for the strategy level -- discharged both ways

**The carrier IS many-sorted (section 1.3) and holds a policy.** Formation
rule: `pi = (R, theta) in P0` is well-formed iff `R` is a nonempty finite
set of `E`-sort terms and `theta` is a finite partial function from a
parameter namespace to `Q union Sym`. Worked instance: a Steakhouse-style
mandate is `pi = ({t_morpho_usdc}, {target_ltv: 0.80, unwind_ltv: 0.85,
cadence: weekly})`, where `t_morpho_usdc` is the ordinary `E`-sort term for
the Morpho USDC market it operates over. Composition `pi1 + pi2 = (R1 union
R2, theta1 uplus theta2)` reuses the identical union-semilattice structure
of section 2 -- no new equational work is required, X2's five laws transfer
verbatim to the `P0`-coordinate. `pi` is invisible to `|=` (which reads
only `tau(I)`) but changes `[[.]]`: two mandates with different `theta`
genuinely reach different net-payoff outcomes (different liquidation
timing) while contributing zero new instances. This is precisely "no
mechanism of its own, but real content for the observation map,"
`corpus50/VERDICT.md`'s own framing, now given a formation rule.

**Proof that a one-sorted carrier cannot hold this, without violating C4.**
Suppose the carrier were just `P(Inst)`. To represent `theta` (an unbounded
rational-valued parameter) or `R` (a set of E-sort terms -- a second-order
object relative to `Inst`) as a subset of `Inst = Sigma x Z`, there are
exactly two options, both bad: (a) invent a fictitious mechanism-element,
e.g. `(Policy_80, z)`, to smuggle the threshold in -- this both violates
C4's "no junk" (VERDICT.md rules explicitly that a strategy is not a
mechanism) AND pollutes `tau(I)` with a symbol that could trip laws or NACs
never meant to see it (a concrete confusion failure, not just an
aesthetic one); or (b) drop `theta` and `R` entirely and represent only
which protocols a vault touches, which is exactly the status quo
VERDICT.md complains about -- "the largest vault operator in DeFi has no
symbol for the thing it sells." Neither option represents the object;
there is no type-respecting injection of `(R,theta)` into `Inst` that also
preserves the compositional structure. A disjoint second sort is therefore
not a convenience -- it is the minimum change that avoids C4 violation while
actually naming the object.

**Answer to BRIEF section 6 Q1 (restated for completeness).** The carrier is
the two-sorted product `A = P_fin(Sigma x Z) x P_fin(P0)`: element-instances
indexed by asset, paired with policy atoms. Not sets of bare element
symbols; not multisets (idempotence, section 2, rules multisets out);
typed-graph-with-two-node-kinds is the accurate description once `backs`
edges (section 12) are added.

## 14. Lens verdict: open games and decorated cospans, confirmed dead, with witnesses

BRIEF section 5b rates both as dead ends by survey. I built each far enough
to find the concrete break, rather than restating the survey.

### 14.1 Decorated cospans: confirmed dead, via an idempotence witness

A decorated cospan is `X -> N <- Y` with a decoration on the apex `N`,
composed by pushout along shared boundary. The generous reading for this
data is: objects are finite sets of ASSET labels (ports = the assets a
protocol touches), a protocol is a cospan decorated by its instance-set,
and composition glues along shared assets -- this is a genuine attempt to
redeem the framework (assets ARE the one place this data has real
cross-protocol wiring: an Xf/Xm chain's destination asset really is the
next protocol's source asset), not a straw-man rejection.

It still fails, concretely, on idempotence (X2). Self-composing a protocol
along its full asset interface `Z` is the pushout of `N <- Z -> N` along
the identity map on both legs. In `Set`, this pushout is `N sqcup N`
QUOTIENTED ONLY at points that are images of `Z` -- any instance NOT
incident to a declared port (e.g. `Ct`, `Li`, `Bs`, `Sh`: internal
accounting facts, not traded/bridged assets) is NOT identified across the
two copies and survives as two separate elements. Idempotence would require
EVERY instance to be port-incident, i.e. the cospan's legs jointly
surjective onto `N` -- false for essentially every protocol in the corpus,
since ports (traded/bridged assets) are always a small minority of a
protocol's instance set (per FINDINGS: 45 of 58 elements have no outgoing
element-expressible requirement at all, and the overwhelming majority of
any real decomposition, e.g. Aave's `Ct, Li, Bs, Im, Up, Tg, Gp`, is
internal, non-port-facing accounting and control machinery). **Concrete
witness: self-composing Aave-with-itself under this reading duplicates
`Ct, Li, Bs, Im, Up, Tg, Gp` (7 of 10 symbols) unless every one of them is
separately declared a port, which nothing in this vocabulary supports.**
This is a decisive, data-specific reason for the failure BRIEF flags, not a
repetition of it: idempotence fails specifically because INTERNAL, non-
asset-facing instances vastly outnumber boundary instances in this
vocabulary, and decorated cospans have no mechanism to identify anything
not on a declared port.

The brief's second charge ("zero finance applications") is independently
confirmed: even granting the port-reading above, pushout composition models
genuine SHARED WIRING (electrical circuits, Petri nets, open dynamical
systems). The one fragment of this vocabulary with real wires is the
cross-domain family (`Xm, Xf, Rl, Of` -- 4 of 58 elements, all G12).
Decorated cospans would at best model that corner, never the whole algebra.
CONFIRMED, with a witness.

### 14.2 Open games: confirmed dead, via a wiring-locality argument

Open games (Ghani-Hedges-Winschel-Zahn / Hedges) form a symmetric monoidal
category whose morphisms carry play/best-response data wired via lenses; a
morphism `f: X -> Y` composed with `g: Y -> Z` shares EXACTLY the interface
`Y`, and independent games compose by tensor (cartesian product) with no
forced shared wire. This is the framework's entire value proposition:
locality of composition -- a sub-game's behaviour depends only on what is
WIRED to it, never on ambient co-presence of unrelated components.

Our laws and hazards are the opposite shape by construction. Law L1 fires
"if `Pl` is present" and is satisfied if `(Li|Ad|Sl|Bs)` is present
ANYWHERE in the same protocol, with no requirement that anything be WIRED
between `Pl` and `Li` -- tensor two open games for `Pl` and `Li` with no
shared wire (a perfectly legal, unrelated tensor composite in the open-games
category) and, under our semantics, L1 is satisfied by pure co-presence,
which is invisible to the categorical composition entirely (no morphism,
no lens, witnesses it). The same holds in reverse for hazards: X19 arms
when `Aw` newly co-occurs with an already-present `{Xm,Xf}`, again with no
wire required. **A framework whose entire selling point is "only wired
things interact" cannot natively state a law or hazard whose truth
condition is "any two things are both present, wired or not," and forcing
it to would mean adding an explicit wire between every pair of elements
that might ever co-occur in any law or hazard -- at which point the
category has one giant fully-connected diagram, and the "open"
compositionality that makes the framework useful is gone.** That is the
decisive overturn-or-confirm: I confirm the dead end, and the reason is
structural, not incidental -- the feature that makes open games valuable
(local wiring) is precisely incompatible with ambient, ubiquitous
co-presence conditions, which is what every law and hazard in this data
is.

### 14.3 Nested graph conditions: the live device, and what it actually buys

Sections 3-5 above are the payoff: S1 (closure is a lattice) and S3 (hazards
break it) are not independent empirical facts about this data -- they are
BOTH consequences of one pair of lemmas about the exists/not-exists split
that NAC theory hands you for free (Lemma A, Lemma B, section 3.3). X5's
"characterise every way one generator can destroy validity" gets a
complete, finite, provable answer (section 4) precisely because hazards are
NACs over a FINITE pattern set. And C6 is discharged by exhibition (section
12) because the same typed-graph carrier that hosts NACs also hosts `backs`
edges with no new apparatus. This is a real result, not a restatement: the
categorical framing does not just DESCRIBE the closure-lattice-plus-hazard-
filter structure FINDINGS already found empirically -- it PREDICTS it from
the shape of the rules (exists vs not-exists), and it is the only one of
the six candidates surveyed in BRIEF section 5b that gives non-monotonicity
a structural home rather than bolting it on as a downward-closed filter
after the fact.

## 15. Prior art (BRIEF section 5, two paragraphs)

Assume-guarantee contracts (Incer 2022) have the richest existing algebra
-- conjunction, disjunction, composition, merging as idempotent commutative
monoids, a bounded distributive lattice, four semirings, and a true
residual quotient. My carrier's union-semilattice-with-derived-meet (S1,
S2) is a strict fragment of that structure: I get the monoid and the
lattice, but the "true residual" (THEOREMS X7, optional) is not built here.
Encoding a hazard as `(A=[[hazard]], G=empty)` rather than
`(A=true, G=not hazard)` is exactly the move that would let assume-
guarantee's saturation ("law relieved when subject absent") subsume my
Horn fragment natively; the caveat Incer's framework needs ports we do not
have applies equally to my `backs` relation, which is supplied data, not
derived structure.

Feature models (Batory) are the closer structural match to the raw data
(xor/or-groups = families, `requires` chains = strata, cross-tree
constraints = the 29 laws, `excludes` = hazards, non-monotone validity
native in both directions) but they do not, on their own, explain WHY
validity is non-monotone -- they simply allow it as an arbitrary subset of
`2^F`. The NAC framing of section 3 is strictly more informative on this
one point: it derives non-monotonicity from the exists/not-exists split
rather than asserting it as a brute fact, which is the concrete addition
this categorical lens makes over the feature-model reading. Formal Concept
Analysis is confirmed, independently, as an audit tool rather than an
algebra: intents are intersection-closed by construction, so the
disjunctive law content (every `(x|y)` alternative) sits structurally
outside a Horn/FCA reading, exactly the wall BRIEF names.

## 16. Remaining answers to BRIEF section 6

**Q2 (is composition a join; is it a lattice; are the laws a Galois closure
operator).** On the raw carrier, `(A,+,meet_raw)` is a trivial distributive
Boolean lattice (section 2) -- true but uninteresting. On the sub-poset of
LAW-closed instance-sets, join is union (S1, proved structurally in section
3.3) and meet is the largest closed subset of the intersection (S2), a
genuine but non-trivial lattice. Is closure a Galois-style closure operator
(extensive, monotone, idempotent, with a UNIQUE minimal closed superset)?
**No, and this is a real answer, not a hedge.** FINDINGS' own
`completions.mjs` shows `Uc` has two INCOMPARABLE minimal closed
completions (`{At,Aw,Bs,Uc}` and `{At,Aw,Sv,Tr,Uc}`) -- whenever a
disjunctive term forks, "the smallest closed superset of `I`" is not unique,
so no single-valued closure FUNCTION exists in the classical Galois sense.
What does exist is a well-defined MULTI-VALUED assignment `I |-> {minimal
closed J : J superset I}`, i.e. the join-irreducible decomposition of the
interval above `I` in the S1 lattice. This is the same non-uniqueness root
cause as S2 (meet not equal to intersection) -- both come from disjunctive
alternatives -- and matches FINDINGS' own conclusion ("build on (closed
sets, subset, union, meet*); do not assume distributivity").

**Q4 (is stratum derivable).** No new derivation attempted -- FINDINGS' Q10
answer (3 of 58 agree, all trivially rank 0; one genuine inversion
`L21: Gs(S3) -> Au(S4)`) is engaged with directly, not recomputed: stratum
plays NO role in my carrier or `+` at all; it is asserted metadata on
`Sigma`, exactly as FINDINGS recommends. Its one confirmed defect is
absorbed as a first-class NAC (`ERR-L21 = {Au,Gs}`, section 3.2) rather than
left as a side note -- the categorical apparatus treats "the axis has one
contradiction" the same way it treats a financial hazard, which is an
honest and cheap way to carry the erratum without pretending stratum is
derivable.

## 17. What I added to the vocabulary, and what I cut (summary)

**Added**: an asset index `Z` and a `backs` relation on `Sigma x Z`
(section 1, 12) -- not new elements, an index and a relation; a policy
sort `P0` with formation rule `(R,theta)` (section 1.3, 13) -- not a new
element, a disjoint sort. Neither changes `Sigma`'s cardinality; both are
designed to be invisible to `|=` so they cost nothing against C4.

**Cut**: nothing from `Sigma`. `Uc` stays, with an explicit ruling
(section 10): repair X11a's polarity rather than drop the element. One
correction proposed but NOT retroactively applied to the shipped verdicts:
`X2`'s NAC should be four disjunctive conjunctions rather than one
five-way conjunction (section 3.2).

## 18. Discrimination on the blind set -- self-assessment

I do not have `algebra/blind-test-KEY.json` and did not open it. `classify`
was run once, mechanically, over all 156 cases with no per-id logic; the
frozen output is `algebra/verdicts/GP-CAT.json`. Measured directly from
that output:

    total 156, ADMISSIBLE 37, INADMISSIBLE 119, acceptance rate 23.7%

Rejections by cause (a case can trip more than one): open-law frequency
`{L15:37, L1:35, L8:21, L7:19, L4:10, L3:9, L5:8, L2:8, L6:7, L19:3, L21:3,
L20:4}`; NAC frequency `{X19:16, X11a:8, X2:6, N-ATOMIC-XM:2, ERR-L21:1}`.
Two structural grounds for confidence, neither of which uses the key or the
negative corpus: (i) section 8's exact reproduction of FINDINGS' 12-named-
protocol closure table (9/12 correct by construction, same three failure
reasons), which is the strongest sanity check available without peeking;
(ii) section 8's 100%-rejection result on every hand-built one-symbol
knockout I constructed, matching C2's mandatory KNOCKOUT bar on that
sample. A 23.7% overall acceptance rate is consistent with either a
well-discriminating predicate (if the true REAL fraction of the 156 is
near a quarter) or an over-strict one (if it is higher) -- I cannot tell
which without the key, and I am not going to guess a specific ratio number
I cannot back up. What I can state with evidence: on the one population I
COULD check against ground truth (the 12 named, publicly-documented
protocols), acceptance is 67% on live ones and 100% correct rejection on
constructed knockouts, both consistent with beating, not merely matching,
the 3.3x reference baseline -- but the true blind-set ratio is unverified
by design, and I report the honest number (23.7% acceptance) rather than a
dressed-up estimate.

## 19. What breaks

- **The blind-test format cannot exercise C6.** The 156 cases are bare
  symbol lists with no asset bindings, so the `backs`-cycle check (my
  strongest result, section 12) never runs on any of them; it is
  demonstrated only on Terra, by hand, from `viz/src/protocols.ts` data.
  Every one of the 156 verdicts comes from the type-level fragment alone
  (section 3), which by S5 provably cannot see reflexivity at all.
- **X2's shipped NAC over-fires relative to its written meaning** (section
  3.2): it demands all five of `{Fl,Cp,Cl,Pl,Cd}` rather than the true
  disjunctive combination. Not corrected in the frozen verdicts.
- **Three of nine live named protocols are INADMISSIBLE** under `|=` for
  incompleteness, not unsafety (section 8) -- inherited directly from the
  reference engine's own 25-law fragment, and a real cost against C1.
- **`Uc`'s hazard needs a repair I did not apply to the shipped predicate**
  (section 10) -- I state the fix, I do not retroactively use it.
- **X4 fails once reflexivity is added** (section 7) -- compositionality is
  a property of the shipped fragment, not of the fuller model.
- **A single flat NAC cannot express unbounded-length cycle-freedom**
  (section 12) -- reflexivity ultimately needs a graph algorithm alongside
  the NAC calculus, not a NAC alone; this qualifies BRIEF section 5b's
  framing of NACs as "the" categorical device for non-monotonicity.
- **23 of 58 generators are inert only because their governing law/hazard
  content is prose** (section 9) -- this is a property of the current
  formalisation, and would need real work (turning prose into element-
  testable terms) to fix, not a quick patch to `|=`.

## Appendix: L and N as implemented (verbatim from algebra/gpcat-predicate.mjs)

    L1  Pl|Im|Cd|Pf|Op  -> (Ex|Tp|At), Ct, (Li|Ad|Sl|Bs)
    L2  Pl               -> (Sh|Ix)
    L3  Uc                -> Aw, At, (Bs|Tr)
    L4  Pf                -> Ex, Ct, Li, (Ad|Sl|Bs)
    L5  Py                -> (Sh|Ix|Rb), Ep, Rd
    L6  Tr                -> Sv
    L7  Cd                -> (Rd|Ps)
    L8  Xf                -> Xm
    L15 Up                -> Tg
    L19 Of                -> Xm, Xf, (Bs|Sl)
    L20 Rl                -> Au
    L21 Gs                -> Au

    X2         {Fl,Cp,Cl,Pl,Cd}    (shipped conjunctive; true form is disjunctive, section 3.2)
    X11a       {Uc,Aw,At}          (reproduces the reference engine's reversed polarity)
    X19        {Xf,Aw}             (reproduces the reference engine's reversed polarity)
    N-ATOMIC-XM {Fl,Xm}            (FINDINGS Q12 unwritten-hazard witness)
    N-ATOMIC-RL {Fl,Au,Rl}         (FINDINGS Q12 unwritten-hazard witness)
    ERR-L21    {Au,Gs}             (FINDINGS Q10/Q12 stratum-inversion erratum)

`U` (symbols appearing anywhere above, used for the X4 witness `iota`, `|U|
= 35`): Ad At Au Aw Bs Cd Cl Cp Ct Ep Ex Fl Gs Im Ix Li Of Op Pf Pl Ps Py
Rb Rd Rl Sh Sl Sv Tg Tp Tr Uc Up Xf Xm.

