# GP-LOG: a propositional (SAT) algebra of DeFi composition

Lens: logical. Carrier tested against the propositional-theory claim in
BRIEF.md section 5b; confronted the non-monotone-validity fact in section 4b
directly (section 1.4 below). Solver: algebra/solvers/GP-LOG/. Verdicts:
algebra/verdicts/GP-LOG.json (156/156).

## 0. The claim I was asked to test

BRIEF.md 5b: all three live candidates independently diagnose this data as
*a propositional theory over 58 atoms*. True, but incomplete as usually
read. I built the actual CNF and checked: of the 23 non-external,
element-expressible law terms across the 25 fireable laws, only 13 are Horn
clauses (at most one positive literal after negating the trigger). The other
10 have two or more alternatives in a single term - L1 twice, L2, L3, L4,
L5, L7, L8, L15, L19 (the last two after my own promotions in section 4;
before them the count was 8/15). A clause with three positive literals
(L1's (Ex|Tp|At), or my own L15's (Tg|Gp)) is not Horn. So: propositional,
yes; decidable by direct evaluation, yes; Horn theory, no - refuted, by
direct construction, not by citation. This is exactly what feature-model
compilation to SAT looks like (BRIEF 5b candidate 1), and exactly why FCA's
Duquenne-Guigues base cannot be the target structure (candidate 3's own
stated wall: disjunctive conclusions are outside Horn because intents are
intersection-closed). Numbers from
algebra/solvers/GP-LOG/calibration-results.json, hornClassification:
Horn 13, non-Horn 10, full list of the 10 given there.

## 1. Signature, carrier, operations, laws

### 1.1 Carrier

Two sorts, committed:

- **M** (mechanism sets): the carrier is 2^Sigma, Sigma the 58-element
  vocabulary (BRIEF's data table; the 59th ELEMENTS row, CSM, is excluded -
  it is declared "not an element" in viz/src/data.ts). A term t is a total
  Boolean assignment over 58 propositional atoms present(e). This is the
  scored carrier - every case in blind-test-set.json is a point of 2^Sigma.
- **Pi** (policy/strategy sort): a policy is a pair (scope, label) where
  scope is a finite set of M-terms it allocates into and label is
  uninterpreted. Satisfaction: pi |= t iff t is in scope(pi). Pi carries NO
  composition operator and NO laws of its own - a Yearn or Steakhouse vault
  (corpus50/VERDICT.md, "a strategy is a missing level") lives in Pi, not
  M, and this algebra makes no admissibility claim about it. This is a
  direct, stated answer to BRIEF 4.3: the carrier is many-sorted, and the
  second sort is deliberately inert (no scoring machinery), because giving
  it real laws would require ports (see section 6).

I do not add a third (Instance = element x asset) sort to the scored
algebra. I use it only once, informally, in section 3 Q5, to answer the
reflexivity question - it never touches admissible().

### 1.2 Composition

t1 (+) t2 := t1 union t2. Two protocols compose by union of their mechanism
sets. This is the only composition operation and it is total on M.

**Proposition 1 (monoid).** (2^Sigma, (+), empty set) is a commutative
idempotent monoid: t1(+)t2 = t2(+)t1, (t1(+)t2)(+)t3 = t1(+)(t2(+)t3),
t(+)t = t, t(+)empty = t. Proof: these are the axioms of union on any
powerset; nothing about validity is used. Absorption t (+) (t (^) s) = t
holds for the same reason, taking (^) = intersection as the ambient meet of
the Boolean lattice 2^Sigma (not the validity-lattice meet of 1.3). All five
required properties (associativity, commutativity, idempotence, identity,
absorption) hold unconditionally, proved, none left open.

### 1.3 The validity lattice (closure alone)

Define, for S subset-of Sigma: **Closed(S)** iff every fireable law that
fires in S (i.e. some subject present) has every non-external term
satisfied (some alternative present); external (prose) terms are treated as
satisfied unconditionally - a stated choice, not an oversight (cost
discussed in section 4 and 6).

**Theorem 1 (union-closure).** If Closed(A) and Closed(B) then Closed(A
union B).
Proof. Let L be any fireable law that fires in A union B: some subject s of
L lies in A union B, so s is in A or in B; say s is in A (symmetric
otherwise). Since Closed(A) and L fires in A (via s), every non-external
term t of L has A intersect alts(t) nonempty. Because A subset-of A union
B, (A union B) intersect alts(t) is also nonempty. So L is satisfied in A
union B. This holds for every fired law, so Closed(A union B). QED.

Consequence: (Closed sets, subset-of) is a complete lattice with join =
union, bottom = empty set, top = Sigma (Closed(Sigma) holds because every
alternative that exists anywhere is present). Meet is NOT intersection -
the standard counterexample from formal/FINDINGS.md Q14 still applies
verbatim under my parse: {Xm,Xf,Of,Bs} and {Xm,Xf,Of,Sl} both satisfy L19's
(Bs|Sl) term by a different disjunct, and their intersection {Xm,Xf,Of}
satisfies it by neither. Meet(A,B) := the union of every Closed subset of A
intersect B (well-defined, and itself Closed by Theorem 1 applied
repeatedly to that union). I build on this lattice; I do not re-derive it.

### 1.4 Non-monotonicity - confronted, not assumed away

BRIEF 4b: validity is non-monotone. Closed(.) is monotone (Theorem 1
extends to: A subset-of B and Closed(A) does not imply Closed(B) in
general, but the *fired-and-satisfied* status of any law present in A
survives into any superset - this is what Theorem 1 actually uses).
Hazard-freedom is the opposite shape: a hazard clause is a pure
prohibition (0 positive literals after negating the trigger, i.e. a goal
clause), so HazardFree(.) is downward-closed - every subset of a
hazard-free set is hazard-free, but a superset need not be.
Admissible = Closed AND HazardFree is the conjunction of an up-set-shaped
predicate and a down-set-shaped predicate. That conjunction is neither up-
nor down-closed in general, which is exactly the non-monotonicity BRIEF
names, and it is why Admissible is not a sublattice of the Closed lattice -
it is a filter cut out of it by clauses running the other way.

**Witness (built from my own final predicate, not asserted abstractly).**
Let BASE = {Pl, Ex, Ct, Li, Ix, Rd, Cp, Cl, Fl}.
- Pl fires L1: (Ex|Tp|At) has Ex present, Ct present, (Li|Ad|Sl|Bs) has Li
  present - satisfied. Pl fires L2: (Sh|Ix) has Ix present - satisfied.
- Cd is absent, so L1/L7 do not fire from Cd. Fl, Cp, Cl, Rd are all
  requirement-terminal (never a law subject) so they add no obligation.
- X2 needs {Fl,Cp,Cl,Pl,Cd} all present; Cd is missing, so X2 does not arm.
  XL1/XL2/LN1 are all vacuous (no Xm, Au, Rl, Fz present).
So BASE is Closed, hazard-free, and Admissible.

Now add exactly one element, Cd: BASE' = BASE union {Cd}.
- Cd is now a subject of L1 (already satisfied, no new obligation) and of
  L7: Cd -> Rd|Ps|liquidation capacity. L7 newly *fires* (it could not fire
  without Cd) and is *immediately satisfied*, because Rd was already
  present in BASE. This is a law becoming satisfied by the addition.
- Simultaneously, {Fl,Cp,Cl,Pl,Cd} are now all five present - X2 *arms*, by
  the same single addition.

Admissible(BASE) = true, Admissible(BASE') = false, and the one element
that was added is exactly what both completed a law and armed a hazard.
This is not a corner case found by search; it is forced by the structure:
Cd is simultaneously an alternative-consumer (it needs Rd|Ps, satisfiable
by pre-existing inventory) and a hazard-name (X2), and the atlas's own
design puts credit-minting on both sides of that line. Non-monotonicity is
not a defect I patched around; it is the reason Admissible cannot be
presented as a sublattice, and I state that as a result rather than trying
to force one.

## 2. Validity predicate and complexity

**admissible(S) := Closed(S) AND NOT(X2 arms in S) AND NOT(XL1 in S) AND
NOT(XL2 in S) AND LN1(S)**, where X2, XL1, XL2, LN1 are defined in section
4. Implementation: algebra/solvers/GP-LOG/model.mjs, function admissible.

**Complexity of checking a given, fully-specified S** (this is what
run.mjs does 156 times): O(|Laws| + |Hazards|) = O(1) in the size of Sigma,
since S is a complete assignment (every element is present or absent) - no
search, just clause evaluation. This is linear in the fixed size of the
rule table (about 30 clauses), not in |S| or |Sigma|. It is not an
interesting complexity class; it is the whole point of a decidable
propositional theory.

**Complexity of the derived questions** (not asked per-case, but relevant
to sections 1.3/1.4 and to any future use of this algebra as a design
tool): "does a partial S have a Closed, hazard-free completion", "how many
minimal completions does it have", "is the Closed-and-hazard-free set
non-empty above S" are existential/counting problems over the unassigned
atoms of Sigma - SAT-existence and #SAT in general, both intractable in the
worst case (NP-complete / #P-complete respectively, standard results for
feature-model analysis operations, Benavides et al. 2010). They are
tractable *here* only because |Sigma| = 58 is small enough for bounded
exhaustive enumeration, which is exactly the method formal/FINDINGS.md used
(probe.mjs, all 5,038,954 subsets of size <= 5). I did not re-run that
search; I built on its results (section 1.3, section 3 Q4-Q5).

## 3. Answers to BRIEF section 6

**Q1. Carrier.** Sets - specifically 2^Sigma, a Boolean lattice, plus a
second, law-free sort Pi for policies. Not multisets (nothing in the data
counts repeated mechanism instances), not terms (no operad structure is
evidenced - see section 6 on why the categorical route was not mine to
take but the composition-without-ports gap is real).

**Q2. Is composition a join?** Yes for M: (+) = union is exactly the
lattice join of section 1.3, and Closed(.) is a closure operator in the
weak sense that it is monotone and idempotent under repeated
law-application (fixed point), though I did not verify extensivity in the
Galois sense (Closed(S) is not generally a superset of S - it is a
predicate on S, not a completion operator; the completion operator is a
different, partial function studied in FINDINGS.md Q14, not reproduced
here). The lattice is real (Theorem 1); it is a lattice of *validity*, not
of *elements* - Admissible itself is not a sublattice (section 1.4).

**Q3. Are the 58 elements independent, or is there a smaller generating
set?** Two distinct answers depending on what "redundant" means, both
computed in algebra/solvers/GP-LOG/calibration-results.json,
redundancyProfiles, and both worth stating precisely because the
automated group-by conflates them:
- *Genuine substitution groups* (elements that are disjunctive alternatives
  within the same term, hand-checked against the raw law text, not just
  co-mentioned in the same law): {Ad, Sl, Bs} in both L1 and L4's last
  term - the three ways to resolve insolvency (auto-deleverage, socialize,
  slash a backstop) are interchangeable wherever this vocabulary asks how
  insolvency is resolved. {Sh, Ix} in both L2 and L5 - two of the three
  accounting styles are interchangeable for exit-liquidity and for
  yield-splitting; {Rb, the third G01 style} joins only in L5, not L2, so
  Rb is *not* fully interchangeable with Sh/Ix - rebasing does not clear
  Pl's specific exit-liquidity requirement the way a share or index does.
  {Rd, Ps} in L7 - the two peg-defense primitives. {Tg, Gp} in L15 and
  {Xm, At} in L8 are substitution groups *I introduced* (section 4, P1/P2)
  - not present in the raw table.
- *Requirement-terminal (never a law subject or a law alternative, in
  either the base 29 laws or my 2 additions)*: 14 elements contribute
  nothing to admissible() at all - Wg, St, Pm, Ob, Ag, Ft, Cv, Dp, Oa, Sr,
  Em, Fd, As, Vl. This is not redundancy in the FCA sense (no two of them
  are interchangeable with each other); it is *invisibility* - the
  propositional theory is silent on whether they are present. Named
  explicitly because it matters for section 6 (what breaks).
- No two elements are shown to be *fully* interchangeable everywhere (same
  profile in every law with no exceptions) other than the pairs above
  restricted to the laws named. I did not find, and did not expect to
  find, a literal duplicate row in the 58 - the corpus50 non-injectivity
  finding (USDT = USD1, USDC = PYUSD) is a different phenomenon: those are
  not two atoms that are redundant with each other, they are two distinct
  off-chain issuers mapping to the *same* point of 2^Sigma. My carrier
  cannot separate them - see Q3-cont below and section 6.

**Q3-cont (BRIEF 4.2, explicitly required).** USDT and USD1 decompose (per
corpus50/lanes) to the identical set {Ps, Rd, At, Fz, Up}. Under my carrier
they are one point, and my algebra returns the identical verdict for both
(both INADMISSIBLE here, on L15 - neither Tg nor Gp is present in either
decomposition). This is provable, not a gap I noticed by luck: 2^Sigma has
no fibre structure, so any two protocols with the same decomposition are
literally the same term. The generator that would separate them is an
issuer/jurisdiction atom (obligor identity) - explicitly off-chain, and
explicitly out of scope by my Q5/section-6 boundary choice (BRIEF finding
5: bound to on-chain state machines). I am naming the missing generator,
not building it.

**Q4. Is stratum derivable as rank?** No, and I did not attempt to overturn
formal/FINDINGS.md Q10 (derived rank matches hand stratum on 3 of 58
elements, all trivially rank 0, range 0-2 against 0-4). I used this result
rather than re-deriving it: it is why I did not build stratum into
admissible() as a foundation-depth check. Concretely, I checked whether the
INVERTED family of negative-corpus.json (protocols built from only S3+
elements, "no foundation") needs a stratum axiom to reject - it does not.
All 12 INVERTED cases are already rejected by Closed(.) alone (verified:
algebra/solvers/GP-LOG/calibration-results.json shows 0/12 INVERTED
accepted), because the specific S3+ elements these cases pick (Py, Uc, Pl,
Im, Pf, Cd, Gs, Xf) each happen to be subjects of laws demanding a
lower-stratum companion that these hand-built cases omit. Stratum is
doing no independent work here - the 25 laws already encode the
foundational dependencies for every element that has one. Where would a
derived rank disagree with the hand axis? Exactly the one inversion
FINDINGS.md already found and I did not re-run: L21, Gs(S3) -> Au(S4). I
did not enforce {Au,Gs} as a hazard (section 4) because I read this as an
atlas erratum, not a real hazard - ruled, per BRIEF's instruction to rule
rather than hedge.

**Q5. Terra died of reflexivity; is there a cycle?** No cycle over Sigma -
I re-derive, not re-run, the FINDINGS.md Q13 argument, because it is a
clean structural fact worth restating in a logical register: every law of
this atlas has the shape *subject -> disjunction-of-alternatives*, i.e. an
edge from a subject symbol to each alternative symbol. The relation you get
by taking every such edge, over the entire 58-element vocabulary (not just
elements present in one protocol), is a DAG - checked directly on my own
parsed law set including P1/P2 (Gp and At are only ever targets, never
subjects requiring Fl/Xf back, so the promotions cannot introduce a cycle;
LN1's target Aw is also never itself a subject demanding Fz or Xf). Since
every subset of a DAG's edge relation is acyclic, *no* element of 2^Sigma
can contain a requirement cycle - not Terra's, not any hypothetical one.
Terra's own footprint has exactly one internal edge, Pl -> {Ex,Ix}, nowhere
near a cycle. To express Terra's actual collapse you need a relation over
*element instances indexed by an asset argument*: define backs(e1,a1,e2,a2)
to hold when the solvency of instance (e1,a1) is a function of the market
value of a2, on the Instance = Sigma x Asset sort mentioned in section 1.1.
Terra is (As,UST) -backs-> (Rd,LUNA) -backs-> (As,UST), a genuine 2-cycle,
but it lives over instances, not types, and my scored carrier (2^Sigma,
unindexed) provably cannot see it. This is a carrier limitation, stated as
one, not patched - promoting the isotope syntax already gestured at in
viz/src/data.ts (At{subject=...}) from a display string to a real index is
the concrete change this would need, and it is out of scope for a
solver that has to answer 156 bare element-sets with no asset annotations.

## 4. What I added to the vocabulary, and what I cut

**Added (promoted prose to formal, each named, each costed):**
- **P1** - L15's own prose alternative, "bounded emergency process", is
  formalized as Gp (Guardian or pause). Cost/evidence: formal/FINDINGS.md
  documents L15 as non-discriminating exactly as written - Lido (live) and
  Euler (dead) both fail it identically on Up-without-Tg, which the report
  itself calls disqualifying for a death predicate. A guardian/pause
  capability literally is a bounded emergency process; adding it as an
  alternative is a one-line formalization of the law's own text, not an
  invention. Cost: it also lets two KNOCKOUT cases (KO-aave-Tg,
  KO-maker-Tg - Aave/Maker with Tg deleted but Gp intact) pass, because
  removing Tg alone is genuinely no longer a gap once Gp covers the same
  function - I accept this as correct, not as leakage, since it follows
  from the same formalization.
- **P2** - L8's own prose alternative, "named custodian", is formalized as
  At (Reserve/NAV attestation). Cost/evidence: corpus50/VERDICT.md
  documents the top-3-bridges-by-TVL (7.8B, WBTC/Coinbase/Binance BTC)
  sharing an identical five-symbol decomposition with "no verification
  symbol at all... because there is nothing to verify: a company holds the
  asset" - a named custodian's trust anchor *is* an attestation, and At
  already exists for exactly that purpose (E031, "a named party's
  statement about backing or value"). Cost: any Xf-bearing set with At but
  no Xm now clears L8, which is the entire custodial-bridge category by
  design, and is exactly what the evidence asked for.
- **XL1, XL2** - the two minimal unwritten hazards from formal/FINDINGS.md
  Q12.1 ({Fl,Xm} and {Fl,Au,Rl}, exhaustively minimal up to size 5),
  enforced as forbidden co-presence. FINDINGS.md names these as real,
  reachable, closed, and unlisted; I promote them rather than re-derive
  them.
- **LN1** - a genuine new law, Fz AND Xf -> Aw, replacing hazard X19 ("a
  restricted claim bridged via Xf with no destination Aw") per
  FINDINGS.md's own recommendation ("reformulate hazards as requirements...
  turn X19 into a law"). This is the one addition that is Horn (exactly
  one positive literal) *and* still breaks union-closure under
  composition, because its trigger is a conjunction of two symbols rather
  than a single subject - see section 6, this is a real, provable defect
  I found while building it, not a hidden one.

**Not enforced, ruled on rather than hedged (BRIEF's own instruction on
Uc):**
- **{Au, Gs}** - the L21 stratum inversion (Q4 above) is an atlas erratum,
  not a financial hazard. Encoding it would reject any protocol
  legitimately combining delegated execution scope with sponsored-fee
  liability (a normal relayer/paymaster pattern), for a reason that is
  about the stratum table, not about risk.
- **X11a/X11b** - not separately enforced. Ruling: **Uc is realizable.**
  X11a ("Uc with no Aw, At, collateral or reputation"), read with its own
  stated polarity (arms only if ALL of Aw, At, collateral, reputation are
  absent), can never arm on a Closed set, because L3 already forces both
  Aw and At present whenever Uc is present and closed - X11a is logically
  subsumed by L3, not an independent constraint, and the disjunction it
  adds ("or collateral or reputation") is trivially already met once L3's
  own conjunction is met. formal/FINDINGS.md reports the opposite
  ("Uc has zero hazard-free legal completion") under what it calls a
  *reversed*-polarity projection - i.e. a different, non-literal reading
  that treats the hazard as "arm whenever Uc, Aw, At are ALL present",
  the mirror image of the law text. I do not adopt that reading. X11b
  additionally requires "weak underwriting", which is not
  membership-checkable under any polarity and is correctly left as
  residue.

## 5. Self-assessed discrimination ratio

Computed by algebra/solvers/GP-LOG/calibrate.mjs, running admissible()
(the exact predicate scored on the blind set) against corpus50/lanes/*.json
(72 REAL protocols, provenance public) and algebra/negative-corpus.json (84
synthetic corruptions, 5 families, provenance public) - not against
algebra/blind-test-KEY.json, which I did not read, open, or reference
anywhere.

- REAL accept rate: 48/72 = 0.667
- Synthetic accept rate: 15/84 = 0.179 (KNOCKOUT 2/15, ARMED 3/18,
  INVERTED 0/12, HYBRID 8/19, RANDOM 2/20)
- **Discrimination ratio: 0.667 / 0.179 = 3.73x** - above the stated 3.3x
  bar.

**A caveat I am obligated to state, because it was discovered mid-project
and changes how this number should be read.** The repo's shared git history
(commit bfbb4df, "the blind set leaked") documents that BRIEF.md itself
mandates reading corpus50/lanes/*.json, and the blind set's REAL half is
drawn verbatim from those exact files - so a pure set-matcher (no algebra
at all: ADMISSIBLE iff the element-set appears verbatim in a lane file)
recovers 72/72 REAL cases and 0 of every synthetic family, because deleting
even one symbol breaks the match. That set-matcher's ratio would be
undefined-large on this measure and would be worthless. My own accept rate
on REAL, 66.7%, is *far* below that oracle's 100% - meaning 24 of 72 real
protocols are rejected by my algebra for genuine structural reasons (open
laws: mostly L15 and L6, occasionally L1/L4/L7/L8/L19 - see calibrate.mjs
output), not carried by set membership. That is evidence the number is not
inflated by the leak in the strong (set-matching) sense. It is still
calibrated using knowledge of which sets are REAL (to compute a rate at
all), and my two promotions (P1, P2) were chosen with corpus50's own named
examples in view (Lido/Euler for P1, WBTC/Coinbase/Binance for P2) - a
softer form of the same exposure, which I am naming rather than
concealing. The honest summary: 3.73x is a real, reproducible number from a
predicate that does more than match sets (proof: it rejects 33% of REAL and
accepts 42% of HYBRID splices that are not deployed but are, by Theorem 1,
often genuinely Closed unions of two individually-Closed real protocols -
not a false accept relative to the algebra, only relative to a deployment
history the algebra was never given). It should not be read as a
deployment-detector; it is a structural-coherence detector, and the two
things are not the same question.

## 6. What breaks

- **LN1 breaks compositionality even though it is Horn.** Take
  A = {Fz} and B = {Xf, Xm}: each is Closed and Admissible in isolation (B
  needs Xm to clear L8; LN1 is vacuous in each since neither has both Fz
  and Xf). A (+) B = {Fz, Xf, Xm} is still Closed (L8 satisfied via Xm) but
  now LN1 fires (both Fz and Xf present) and fails (no Aw) - so composing
  two Admissible protocols by plain union produces an Inadmissible one.
  This is not the disjunctive-alternative non-monotonicity of section 1.4;
  it is a second, independent failure mode, specific to any law whose
  trigger is a conjunction of symbols from what may be two unrelated
  protocols. The real cause is that Fz-of-A and Xf-of-B are, in this
  carrier, indistinguishable from Fz-and-Xf-of-one-protocol - there are no
  ports to say they are unrelated. This is exactly BRIEF 5b's "composition
  of sets without ports, which nobody has solved" - I did not solve it
  either; I found a second, concrete instance of it inside my own smallest
  addition.
- **14 elements are structurally invisible to admissible().** Wg, St, Pm,
  Ob, Ag, Ft, Cv, Dp, Oa, Sr, Em, Fd, As, Vl never appear as a law subject,
  a law alternative, or a hazard name, in either the base 29 laws or my 3
  additions. Their presence or absence never changes a verdict. Several of
  these carry real, named risk in formal/FINDINGS.md's own hazard table
  (As is named in X1, the Terra hazard, which fails the 2-symbol
  evaluability threshold and so is never checked by anyone's closure
  predicate, mine included) - this is a vocabulary-coverage gap this
  algebra inherits and does not fix.
- **The carrier cannot separate USDT from USD1**, by construction (Q3-cont,
  section 3) - stated as a limitation, with the missing generator named
  (off-chain obligor identity), not built, per the section-5-of-BRIEF
  scope choice to bound this algebra to on-chain state machines.
- **Reflexivity is provably outside this carrier** (Q5) - Terra's collapse
  needs an asset-indexed Instance sort this solver never constructs.
- **80% prose remains prose.** I promoted exactly two alternatives (P1,
  P2) out of the 52 external law terms formal/FINDINGS.md counts; the other
  50, plus 19 of 20 hazard rows, remain unenforced residue. admissible(S)
  = true is therefore a necessary, not sufficient, real-world-soundness
  condition - consistent with, not stronger than, the base atlas's own
  scope.
- **Strategies (Pi) get no admissibility verdict at all.** By design
  (section 1.1) - not a bug, a scope boundary, but it means the single
  largest object by TVL in the yield category (corpus50/VERDICT.md) is
  simply outside what this report can classify.
