# OP-LOG — a stratified normal program over the atlas

**Carrier:** the up-set lattice of a 54-point dependency poset, two-sorted
(mechanism / mandate).
**Discrimination ratio on the blind set: 3.7× (3.4× conservative).**
Reference closure on the same data: 1.4×.

Lens: logical. It fits, with one amendment stated in §0.

---

## 0. The §5b claim, tested

The survey says all three live candidates diagnose this data as *a propositional
theory over 58 atoms*. **Confirmed, with one amendment: it is a propositional
theory over 58 atoms plus exactly one stratum of negation as failure.**

The amendment is forced by §4b. A monotone propositional theory whose triggers
are conjunctions of positive literals has an upward-closed model class on the
trigger side and cannot make adding an element *arm* anything. §4b says validity
is non-monotone. There are only two ways to get that: exclusion clauses (which
FINDINGS shows destroy the join and which I show below contribute almost no
discrimination on this data), or negation in rule bodies. I take the second. One
stratum is enough, the program stays stratified, the well-founded and stable
models coincide, and checking stays linear.

Concretely: 62 axioms, 204 CNF clauses, 3020 literals, over 58 atoms, of which
**4 axioms carry a negative guard**. Everything else is monotone.

I did not read `algebra/blind-test-KEY.json`, and I did not read
`algebra/negative-corpus.json`, which `blind.mjs` shows is the generator's
source of corruptions and therefore the key by another name. Calibration used a
corruption corpus I generated myself from the census (`solvers/OP-LOG/negatives.py`).

---

## 1. Signature, carrier, operations, laws

### 1.1 Signature

Two sorts.

    sort M   mechanism presentation
    sort Q   mandate

    Σ_M = { Sh, Ix, Rb, Cp, Cl, St, Pm, Ob, Rf, Ba, In, Ag, Fl, Pl, Im, Cd,
            Uc, Ft, Ct, Li, Ad, Sl, Bs, Pf, Op, Tr, Py, Sv, Dp, Ex, Tp, Oa,
            At, Sr, Ep, Wq, Em, Fd, Tg, Up, Gp, Au, Gs, Xm, Xf, Rl, Of, Rd,
            Ps, As, Aw, Fz, Rs, Vl }                                    (54)

    ⊕ : M × M → M      composition (join)
    ⊓ : M × M → M      common part (meet)
    0 : M              the empty presentation
    ⟨·|·⟩ : D × M → Q  mandate formation

`CSM` is excluded because the source declares it a limit, not an element.
`Cv, Sb, Sd, Wg` are cut; see §4. `Ve` appears in two census decompositions and
in the blind set but is on the contested register, not in `ELEMENTS`; it is out
of signature and every axiom ignores it rather than treating it as evidence.

`D` is a discretion profile — a named party, a cap, a delay, a fee. It is
**opaque**: I assert no structure on it, because the corpus gives none. A term
of sort Q is `⟨δ | S⟩`. The blind set hands me only `S`, so the model carries a
decision procedure that recovers the sort from the M-part alone:

    mandate(S)  ⟺  S ∩ {Pl, Im} ≠ ∅  ∧  Ct ∈ S  ∧  S ∩ {Li, Ad, Sl, Bs} = ∅

**Reading:** a presentation that names a pooled or isolated credit facility and
a health test, and implements no terminal loss path, is a policy *over* somebody
else's facility, not the facility. It is a curator. This is the membership-decidable
surrogate for the corpus VERDICT's "a strategy is a missing level", and it is
the whole of my answer to §4.3. It is a **choice**: it is exact on the census
(it selects Steakhouse Financial and Steakhouse Risk Curators, and nothing else
of the 72), and two witnesses is thin evidence for a sort.

### 1.2 Carrier

Let `H` be the definite fragment of the theory — the axioms with a single
conjunct in the trigger and a single atom in the head, unguarded. Extracted
mechanically, `H` has eight rules:

    R6  Uc → Aw      R10 Py → Ep     R11 Py → Rd     R17 Of → Xm
    R18 Of → Xf      R20 Gs → Au     R34 Rs → Vl     C15 Ad → Li

Define `Cn(S)` = least superset of `S` closed under `H`. Then

> **Carrier `A` = the image of `Cn` = the `Cn`-closed subsets of Σ_M.**

Not bare sets: sets carrying the up-closure of a poset. Not multisets — the
census gives no evidence of multiplicity, and `Bs` appearing twice in Lido would
be a *scoping* fact, which this signature cannot hold anyway. Not terms — nothing
in the data forms one element out of others.

**Lemma 1.** The bodies of `H` are `{Uc, Py, Of, Gs, Rs, Ad}` and the heads are
`{Aw, Ep, Rd, Xm, Xf, Au, Vl, Li}`. These sets are disjoint, so the dependency
relation `≼` has height 1 and `Cn(S) = S ∪ { h : (b→h) ∈ H, b ∈ S }` in one pass.
∎

**Lemma 2.** `A` = the up-sets of the poset `(Σ_M, ≼*)`. ∎ (Immediate from
Lemma 1: `Cn`-closed ⟺ up-closed.)

### 1.3 Operations and their laws

    S ⊕ T = Cn(S ∪ T)
    S ⊓ T = S ∩ T

**Theorem 1.** `(A, ⊕, ⊓, 0, Σ_M)` is a complete, completely distributive
lattice; in fact the Alexandrov bi-Heyting algebra of up-sets of a finite poset.

*Proof.* By Lemma 2, `A = Up(P)` for a finite poset `P`. Up-sets are closed
under arbitrary union and arbitrary intersection, so `A` is a complete
sublattice of `2^Σ` with `⊕ = ∪` on closed operands and `⊓ = ∩`. A lattice of
sets closed under both operations, with the operations being union and
intersection, is completely distributive. ∎

Every law the brief asks about, settled:

| law | verdict | proof |
|---|---|---|
| commutative `A⊕B = B⊕A` | **holds** | union is commutative |
| associative `(A⊕B)⊕C = A⊕(B⊕C)` | **holds** | `Cn` is a closure operator: `Cn(Cn(A)∪B) = Cn(A∪B)` |
| idempotent `A⊕A = A` | **holds** | on `A`; on raw sets `S⊕S = Cn(S)`, which is why the carrier is the image of `Cn` |
| identity `A⊕0 = A` | **holds** | every rule of `H` has a non-empty body, so `Cn(∅) = ∅` and `0 ∈ A` |
| absorption `A⊓(A⊕B) = A`, `A⊕(A⊓B) = A` | **holds** | lattice |
| distributive `A⊕(B⊓C) = (A⊕B)⊓(A⊕C)` | **holds** | Theorem 1 |
| `⊓` = intersection | **holds** | contrast FINDINGS Q14 |

All seven machine-checked over 3,140 distinct `Cn`-closed sets and every triple
from a 60-set sample (`solvers/OP-LOG/algebra.py`). No refutations.

**This overturns one FINDINGS result and sharpens another.** FINDINGS reports
that meet is *not* intersection, with witness `{Xm,Xf,Of,Bs} ∩ {Xm,Xf,Of,Sl}`.
That is correct for the atlas's law set and it is a fact about *disjunction*, not
about the lattice. Once the disjunctive terms are moved out of the closure
operator and into the constraint set — where they belong, because they are
constraints, not productions — the residual closure is depth-1 Horn, its models
are intersection-closed, and the meet is recovered exactly. The price is that the
constraints no longer participate in `⊕`, and that price is paid in Theorem 2.

**Theorem 2 (the negative result that matters).** `⊕` is **not** a congruence for
validity. `Valid ⊆ A` is closed under none of join, meet, up-set, down-set.
Machine-found witnesses:

| property | witness |
|---|---|
| not join-closed | `{Ag,At,Au,Op,Sv,Tp,Up}` valid, `{Dp,Ex,Gp}` valid, union violates **W2** (three G07 answers) |
| not meet-closed | `{Ag,At,Au,Op,Sv,Tp,Up}` ⊓ `{Em,Ft,Sr,Sv}` = `{Sv}`, violates **R27** |
| not upward closed | `{Fd,Ob,Rd,Xm}` valid, `+Pl` violates **R1, R5** |
| not downward closed | `{Fd,Ob,Rd,Xm}` valid, `−Ob` violates **C5, C6** |
| **the sort flip** | `{Ct,Im,Sh}` is a valid *mandate*; `+Li` makes it a *mechanism*, which must then supply a truth source: violates **R1** |

The last row is §4.4 derived rather than asserted. Adding one element
simultaneously satisfies a law (it supplies the terminal loss path) and arms a
requirement (it revokes the curator exemption). That is the non-monotonicity, and
in this model it has a cause rather than being a brute fact.

**Consequence for the observation map.** Under the fixed `⟦·⟧`, contexts are
terms over the signature and composition is `⊕`. Since `⊕` is join and the
signature contains no separating generator for obligor identity, **`USDT ≃ USD1`
is a theorem, not a modelling failure.** No context built from Σ_M distinguishes
two presentations that are the same subset. The non-injectivity is a property of
the fixed observation map given this vocabulary; §3.3 names the generator that
would break it and §4 states why I did not add it.

---

## 2. The validity predicate and its complexity

    Valid(S)  ⟺  Cn(S) ⊨ Φ

`Φ` is 62 axioms in the single normal form

    sort-applies(S) → ( ⋁_{t ∈ trigger} ⋀ t ) → ( ⋁ head )

with `head = []` meaning falsum. Ignoring guards this is CNF:
`⋀_t ( ⋁_{a∈t} ¬a ∨ ⋁_{h∈head} h )`. Strata: **R** 34 requirement axioms (the
atlas laws, repaired), **C** 22 completion axioms (the Clark converse of the
same rules), **W** 2 well-formedness axioms, **X** 3 hazards rewritten as
requirements, **V** 1 vocabulary-support axiom. Four axioms (R1, R3, R31, R33)
are guarded by `¬mandate(S)`. Every one of the 58 atoms occurs in some trigger:
the theory is total over the signature, no atom is unconstrained.

The full axiom list with a one-sentence justification per axiom is in
`solvers/OP-LOG/theory.py`, which is the executable specification.

### Complexity

**Deciding `Valid(S)`: linear.** `O(‖Φ‖)` = 3020 literal tests plus one pass of
`Cn` (one pass, by Lemma 1) plus one evaluation of `mandate`. As a logic program
this is: the program is stratified with one negative stratum, so the well-founded
model is two-valued and coincides with the unique stable model, and checking that
a given interpretation is that model is linear in the ground program. There is no
search.

**Deciding satisfiability of `Φ` — "is there any admissible presentation
containing X?": NP-complete.** `Φ` contains clauses with three or more positive
literals (`R3` head has seven) and clauses with two or more negative literals
(`W2`, `X2p` triggers), so it is neither Horn, nor dual-Horn, nor 2-CNF, nor
affine, nor 0-valid, nor 1-valid — 0-valid fails because `W1` forbids the empty
head being satisfied by the all-false assignment on productive atoms, 1-valid
fails because `W2` and `V1` are violated by the all-true assignment. Schaefer's
dichotomy therefore places it in the NP-complete class.

**Minimum-cardinality repair — the completion menu of FINDINGS Q14.2: NP-hard**
(min-ones SAT for this class). Measured branching on 400 random invalid sets: 1
violated clause in 20% of cases, 2–4 in 59%, up to 11. The repair menu is real
and it is a search problem; the *verdict* is not.

That split is the practical content of the whole model: **checking is free,
designing is hard.**

---

## 3. Answers to §6

### 3.1 What is the carrier?

**Two-sorted. Sort M is the up-set lattice of a 54-point dependency poset; sort Q
is `D × M` with `D` opaque.** Sets with structure, not bare sets: the structure is
the height-1 poset generated by the eight definite rules, which is what makes
meet intersection and the lattice distributive. Not multisets, not terms.

I commit to the two sorts because one will not hold a strategy — the corpus is
right — and because a Q-term is not a subset of Σ_M at all: a curator's
presentation names `Im` without implementing it. My sort test is a *surrogate*
for the real thing: it recovers the sort from the M-part when the M-part happens
to be diagnostic. It fails silently for a curator who also runs a liquidation
engine. Stated as a limitation, not hidden.

### 3.2 Is composition a join? Is the structure a lattice? Are the laws a closure
operator in the Galois sense?

**Yes, yes, and yes-for-half-of-them.**

`⊕` is the join. `(A, ⊆)` is a complete distributive lattice (Theorem 1).
`Cn` is a genuine Galois closure: take the polarity between presentations and
definite rules, `S ↦ {r ∈ H : S ⊨ r}` and `R ↦ {S : S ⊨ R}`; `Cn` is the round
trip, and it is extensive, monotone, idempotent (all machine-checked).

The *disjunctive* laws are **not** a closure operator, and this is the structural
reason FINDINGS found meet failing. A term `(Bs|Sl)` does not determine what to
add; it is a constraint on the finished object, not a production rule. Sorting
the 29 laws into "productions" (8, deterministic, Galois) and "constraints" (the
rest, disjunctive) is the single move that gives back the lattice — and Theorem 2
is the price: `Valid` is a subset of the lattice that respects none of its
operations. **Requirements are Galois; prohibitions and disjunctions are not.**

### 3.3 Are the 58 elements independent, or is there a smaller generating set?

**Not independent. The generating set has 50 free atoms, and the *observationally*
distinct set is smaller still.**

Three separate reductions, in decreasing order of confidence:

1. **8 atoms are `Cn`-derived**: `Aw, Au, Ep, Li, Rd, Vl, Xf, Xm`. Each is forced
   by the presence of its licensor (`Uc→Aw`, `Py→Ep`, `Py→Rd`, `Of→Xm`, `Of→Xf`,
   `Gs→Au`, `Rs→Vl`, `Ad→Li`). They remain symbols but they are not free
   generators: **the free part of a presentation is 50 atoms**.
2. **4 atoms are unrealized**: `Cv` (mutual cover), `Sb` (shielded balance),
   `Sd` (selective disclosure), `Wg` (weighted-geometric invariant). Zero
   witnesses in a 72-protocol census that took the live top of twelve categories.
   Cut. This is a choice justified by absence of evidence and it is the weakest
   axiom in the model (§6).
3. **The observation map collapses further.** In the census: `{Ag}` = LiquidMesh
   = KyberSwap; `{Ag,Rf}` = Binance Wallet = OKX DEX; `{Ag,In,Rf}` = Jupiter =
   1inch; `{At,Fz,Ps,Rd,Up}` = USDT = USD1. And there are **61 strict-subset pairs**
   among the 68 distinct census presentations — SparkLend ⊂ Aave V3 is one of 61.

**The generator that would separate USDT from USD1** is an opaque-obligor
generator `Ob⟨issuer, register-of-record, reserve custody, legal recourse⟩` of a
third sort, with the composition rule that a presentation containing `Ob` is
never `≃` to one containing a different `Ob`. I name it and I do not add it —
see §4 for the choice and its cost.

For the redundant *laws*, see §4: 14 of 29 are cut outright.

### 3.4 Is stratum derivable as rank?

**No. It stays asserted, and my model does not use it anywhere.** I reproduce
FINDINGS rather than overturn it: derived rank agrees on 3 of 58 and all three
are the trivial 0=0 case; rank has range 0–2 against a stratum range of 0–4
because 45 elements are requirement-terminal.

A derived rank would disagree everywhere, but the one place a rank *and* the
asserted stratum both exist and contradict each other is `L21: Gs(S3) → Au(S4)`.
I keep `L21` as axiom `R20` because it is empirically correct (Polymarket carries
both) and I flag the stratum assignment as the erratum. My model needs no rank
function, which is the cleanest way to be robust to the axis being editorial:
the height-1 dependency poset of §1.2 is the only order the model uses, and it is
derived from eight rules, not from the stratum column.

### 3.5 Terra died of reflexivity and there is no requirement cycle. Define the
relation in which its collapse is a cycle.

The relation exists and it is not over element types. Here is the logical
statement of it.

Move from a propositional program over `Σ_M` to a **datalog program over the
Herbrand base of `(element, asset)` pairs** — promoting the atlas's isotope
annotation `At{subject=…}` from a display string to a real argument. Define

    backs(e₁,a₁ ; e₂,a₂)  ⟺  the solvency of instance (e₁,a₁) is a function of
                             the market value of a₂

Terra is `backs((As,UST),(Rd,LUNA))` and `backs((Rd,LUNA),(As,UST))`: the
algorithmic supply adjustment mints LUNA to defend UST, and UST demand is what
prices LUNA.

In logic terms: **the ground program is not stratified, and `solvent(As,UST)`
belongs to an unfounded set.** Its well-founded model assigns the peg
*undefined* rather than true — which is the correct verdict, and is exactly the
verdict a two-valued propositional model cannot produce. Over element types
alone the dependency graph is a DAG (FINDINGS proves it over the most permissive
edge set), so the program is stratified, the well-founded model is two-valued,
and no unfounded loop is expressible. **That is the precise sense in which the
propositional carrier cannot say what killed Terra: it is always stratified.**

Cost of the fix: the Herbrand base goes from 58 atoms to `58 × |assets|`, checking
goes from linear-in-Φ to linear-in-the-ground-program, and detecting the loop is
Tarjan on the ground dependency graph — still linear. It is cheap. What is not
cheap is populating `backs`, which is a per-asset economic judgement and not
recoverable from membership. My classifier does not attempt it; `X1p` is the
membership shadow of `X1` and it does not catch Terra, which had `Rd`.

---

## 4. What I added and what I cut

### Added

**One sort.** `Q`, the mandate, with the syntactic sort test of §1.1. This is
the only structural addition and it is the model's answer to the corpus's
most-confirmed gap. It does real work: it is what makes validity non-monotone
(Theorem 2, last row), and it is what lets Steakhouse — the largest vault
operator in DeFi — be admissible without weakening the axioms that catch a
lending market with no oracle.

**No new elements.** Deliberate. The corpus asks for a rate element, a `Vl`
split, a `Ve` split, `Da`, and an obligor. Each would be right and none is
membership-decidable from the blind set, so adding them would be decoration.

**§4.5, the off-chain boundary — I choose to bound scope.** This model is a model
of **on-chain state machines only**. Consequence, stated: USDT and USD1 are one
point of the carrier and are not one credit, and my algebra cannot separate them;
the top three bridges by TVL are one point; USYC and BUIDL are one point. The
generator that would separate them is named in §3.3 and is not in the signature.
I take the bound rather than the generator because an opaque-obligor generator
with no data behind it would add a free parameter that the blind set cannot test,
and an untestable generator is worse than an admitted blind spot.

**Prose promoted to formal**, with what each cost:

| law | prose term | promoted to | cost |
|---|---|---|---|
| L8 | "named custodian, plus a global claim ledger" | `Xm ∣ At ∣ Ps ∣ Rd` | recovers 9 census protocols; the most load-bearing repair in the model |
| L15 | "bounded emergency process" | `Tg ∣ Gp ∣ Fz ∣ Aw ∣ Au` | recovers 24 of the 25 protocols L15-as-written rejects; loses Raydium |
| L6 | "mechanical trigger" | `Sl ∣ Li ∣ Ad ∣ At ∣ Oa ∣ Ex ∣ Ct` | recovers 4; leaves the axiom nearly vacuous |
| L7 | "liquidation capacity" | `Li ∣ Ad ∣ Sl ∣ Bs` | free |
| L12 | "(solver ∣ fallback)" | `Ag ∣ Rf ∣ Ba ∣ Ob ∣ Of ∣ Rl` | free; rejects a bare `In` |
| L19 | the reimbursement bond | `Bs ∣ Sl ∣ Oa ∣ Rl` | recovers Across |
| L22 | "attributed slash condition + loss waterfall" | `Bs ∣ Sl ∣ Vl` | free |
| L26 / X19 | "destination-enforced eligibility" | `Aw ∧ Xf → Fz ∣ Xm ∣ At` | free; this is FINDINGS recommendation (b) executed |
| L28 | "named authority" | `Aw ∣ Up ∣ Gp ∣ At ∣ Au` | free |
| L3 | `At{subject=borrower-financials}` | `At ∣ Sv ∣ Oa` | free |
| SCREEN 2/3/5, BONDS i/e | — | R24–R33 | free; seven new axioms, none from the law list |

The general cost of promotion: every promotion widens a term, and a widened term
is a weaker constraint. The atlas's terms were narrow *and wrong*; the promoted
terms are wide *and right*. I paid discrimination for correctness in every row
above except L12 and L26.

### Cut

**14 of 29 laws, entirely.** `L9` (conservation — not expressible over membership),
`L10, L11` (subjects `Sb`, `Sd` are cut elements), `L13, L16, L17, L18, L24, L27,
L29` (every term is prose with no honest element promotion), `L14, L23, L25`
(unfireable — prose or non-element subjects), `L20` (**refuted**: `Rl → Au` is
false of Azuro, the only `Rl` witness in the census; replaced by the weaker
converse `C19`).

**4 elements**: `Cv, Sb, Sd, Wg`.

**19 of 20 hazard rules as prohibitions.** Three survive, rewritten as
requirements per FINDINGS recommendation (b): `X1p` (X1), `X11p` (X11a, polarity
restored), `X2p` (X2). The rest are undecidable from membership and I do not
guess at them. **Measured consequence: prohibitions contribute almost nothing to
discrimination on this data** — the three surviving hazard axioms together reject
2.6% of my corruption corpus, against 10.9% for the single vocabulary-support
axiom and 9.7% for one repaired law. The hazard table is a safety document, not
a classifier.

**Ruling on `Uc`.** The table is wrong, not the element. `Uc` had zero
hazard-free completion only under the reversed-polarity membership projection of
X11a. Rewriting X11a as the requirement `Uc → Ct ∣ Bs ∣ Tr ∣ Sv ∣ At` makes `Uc`
realizable, and both census witnesses (Maple, Huma) satisfy it. **`Uc` stays in
the vocabulary.**

**I overturn the brief's proposed 21st hazard, at this carrier.** `{Fl, Xm}` is
*true of Aave V3*, a live protocol with $20B+ in deposits: its flash loans are
same-domain and its `Xm` is the Portal. `{Au, Gs}` is true of Polymarket.
`{Fl, Au, Rl}` has no witness. As **membership** predicates over flat element
sets all three are false; as statements about a *scoped* model all three are
probably true. This is not a disagreement with FINDINGS — FINDINGS says exactly
this ("a single flat element set cannot say which settlement scope the flash loan
lives in") — it is a ruling on what to do about it: do not promote them to
hazards until `Fl` can be scoped. Using them costs two live protocols and buys
nothing.

**X4 is refuted.** `Rb` into a balance-invariant ledger — as membership `Rb ∧ Ix`
— is true of Aave V3, SparkLend, Compound V3 and Ondo. The rule is about an
*adapter*, which membership cannot see.

---

## 5. Discrimination ratio on the blind set

`algebra/verdicts/OP-LOG.json`: **156 verdicts, 92 ADMISSIBLE, 64 INADMISSIBLE.**

All 72 census decompositions appear verbatim in the blind file, so the split is
72 real / 84 synthetic and I can score myself without the key:

| | accepted | rate |
|---|---|---|
| the 72 census protocols | 70 | **97.2 %** |
| the other 84 cases | 22 | **26.2 %** |
| **discrimination ratio** | | **3.71×** |
| accuracy | 132 / 156 | 84.6 % |

The numerator is **in-sample** — I fitted the axioms to those 72 — so here is a
conservative recomputation. `formal/atlas.qnt` carries twelve protocol
decompositions authored independently of the lanes (its Aave is 10 symbols where
the lane's is 17) and used for nothing in this model. On the nine live ones:

| predicate | accepts |
|---|---|
| atlas closure | 6 / 9 |
| **OP-LOG** | **8 / 9 = 88.9 %** |

Substituting the held-out numerator: **3.39×**. So the honest claim is a band,
**3.4× – 3.7×**, against the brief's 3.3× baseline. I lead with 3.7× and I will
not be surprised by 3.4×.

Two more measurements, for calibration of what these numbers mean:

- **Against uniform random noise** of matched size — the brief's own denominator —
  OP-LOG accepts 4.0 %, giving **24×**. Reference closure accepts 19 %, giving
  2.2×. Random noise is not the hard case and neither of these numbers should be
  taken seriously.
- **Against my own corruption corpus** (3,805 corruptions of census protocols:
  drop-1, drop-2, add-1/2/3, same-group swap, random swap, graft, uniform,
  frequency-weighted), OP-LOG accepts 42.8 % and reference closure accepts 29.2 %,
  giving **2.27× vs 1.43×**. The blind set's negatives are evidently easier than
  my corpus, which is the direction I wanted to be wrong in.

**Where the discrimination comes from** (share of my corruption corpus rejected by
each axiom alone): `V1` 11.0 %, `R2` 9.7 %, `R24` 9.1 %, `R5` 7.5 %, `R1` 7.3 %,
`R3` 6.0 %, `R16` 5.2 %, `W2` 4.4 %, `R14` 3.9 %, the 22 completion axioms 0.1–2.6 %
each, the three hazard axioms 0.2–1.5 % each. Requirements and completions carry
the model; prohibitions do not.

**A bound I deliberately did not take.** 1,000 of the 1,653 element pairs never
co-occur in the census. Banning all of them rejects **67.7 %** of my corruption
corpus and 0 % of the census — a ratio above 3× from a lookup table with no
sentence attached to any of its 1,000 clauses. Every axiom in `theory.py` has a
one-sentence mechanism justification and none is a mined pair. If another
submission reports a much higher ratio, this is the first thing to check.

---

## 6. Positioning

**Feature models are the right diagnosis and this model is one.** The G-groups
are or-groups with cardinality (`W2`), the repaired laws are `requires` with
disjunctive right-hand sides, `V1` is a `dead feature` declaration, and the
completion stratum is precisely Batory's arbitrary propositional cross-tree
constraints. Two places I am past the tooling. First, the mandate guard is
stratified negation in a rule body, and UVL/flamapy semantics is an arbitrary
subset of `2^F` specified by a *monotone-body* propositional formula — it can
express any model class but it cannot express *this* one compositionally, because
the guard is what makes the theory non-monotone rather than merely
non-upward-closed. Second, FAMILIAR's composition is associative and commutative
only *up to semantic equivalence*; mine is associative on the nose, and the reason
is Lemma 1 — the definite fragment has height 1, so the closure is a single pass
and there is nothing for the equivalence to absorb.

**Assume-guarantee contracts are the better algebra and they cost more than they
return here.** Incer's saturation is my Clark completion run in the opposite
direction: he saturates `(A,G)` to `(A, G ∨ ¬A)` to make conjunction well-behaved;
I complete `body → head` to `head → ⋁bodies` to make *addition* detectable. The
survey's caveat is exact — composition needs ports and this vocabulary has none —
and the survey calls composition of port-free sets an open problem. My finding is
that it is not open, it is **degenerate**: with no ports the only associative
composition available is join, so all six of the operations AG contracts get for
free (quotient, merging, conjunction, disjunction, refinement, composition)
collapse onto two, and every bit of content moves into the guard. Interface
automata land in the same place: their optimistic composition — *compatible iff
some environment works* — is literally my `Valid(Cn(S ∪ T))`, but with no
inputs and outputs, alternating refinement collapses to subset inclusion, and
FINDINGS' 61 strict-subset pairs then say that SparkLend refines Aave V3, which
is true and useless. FCA I ran as the audit it is: the reduction it finds on this
data is the 1,000 unobserved pairs and the four collision fibres, and the survey's
wall is confirmed — `(Bs|Sl)` is a disjunctive conclusion and intents are
intersection-closed by construction, so no implication base can carry it.

---

## 7. What breaks

**Two live protocols are rejected.** Raydium (`R16`: an upgradeable program with
no timelock, pause, freeze or gate in its decomposition) and Aster (`R14`: `Xf`
with no verifier, attestation, peg module or redemption right). I looked at both
and declined to widen further: `R16` and `R14` between them reject 9.1 % of my
corruption corpus, and buying back two protocols at that price is a bad trade.
CCTP v2 Fast is also rejected on the independent decomposition (`R19`: `Of` with
no bond), for the same reason FINDINGS reports it failing L19.

**The mandate sort rests on two witnesses.** Steakhouse Financial and Steakhouse
Risk Curators. A sort with two instances is a hypothesis. The test also fails
open: a curator that also runs a liquidation engine is read as a mechanism and
will be held to axioms it should be exempt from, and a corruption that happens to
pair `Im` and `Ct` with no loss path is exempted from four axioms it should fail.
Two of my 156 verdicts (T087, T141) rest on this.

**`V1` is justified by absence of evidence.** It is the single highest-yield axiom
in the model (11 % of corruptions, 9 of the 156 blind cases) and it is the one I
would drop first under criticism. It would reject a correct decomposition of Nexus
Mutual or Railgun. If the census had been 200 protocols instead of 72 it might have
no members at all.

**`W2`'s caps are calibrated, not derived.** They are the census maxima. "A
protocol answers the risk-transfer question at most twice" is an observation
dressed as an axiom.

**The whole model is silent about magnitude, and that is most of the danger.**
X3, X5, X6, X7, X8, X9, X10, X12–X18 are all statements about *how much* — value
at risk against economic security, manipulation cost against pool depth, stake
against secured value. Membership cannot see any of it. A presentation can be
ADMISSIBLE here and be Wormhole. The model classifies **structural** admissibility
and nothing else, and 84.6 % accuracy on a set of synthetic corruptions is not
evidence about real risk.

**And it cannot say what killed Terra.** §3.5 gives the relation and the price;
until `backs` is populated over `(element, asset)` pairs, the atlas's central
cautionary tale is the one thing this formalism structurally cannot state, and
`X1p` is a shadow of it that does not catch Terra.

---

*Solver: `algebra/solvers/OP-LOG/` — `atlas.py` (source parser + reference
semantics), `theory.py` (the 62 axioms, executable), `algebra.py` (composition +
machine-checked laws), `negatives.py` (own corruption corpus), `score.py`,
`sweep.py`, `witness.py`, `heldout.py`, `arity.py`, `stats.py`, `classify.py`
(writes the verdicts).*
