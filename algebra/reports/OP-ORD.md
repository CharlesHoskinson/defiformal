# OP-ORD — Two adjoints and a simplicial complex

**Lens: order-theoretic. Kept.** The lens fits, but only after the object is
split in two. The atlas has been read as one closure operator. It is two: a
closure operator going up (everything required is present) and a *kernel*
operator going down (everything present is used). The reference engine computes
one of them. That is the whole of its 2.5×.

Carrier: **element sets with a derived generator/dependent typing**.
Measured discrimination ratio on the 156-case blind set: **10.83×**
(65/72 = 90.3% on real protocols, 7/84 = 8.3% on the rest).

---

## 1. Signature, carrier, operations, laws

### 1.1 Signature

Two sorts. The second is free, so the cost of many-sortedness is zero.

| | |
|---|---|
| `E` | 58 mechanism atoms (the atlas minus `CSM`, which declares itself a non-element) |
| `Ob` | obligation atoms: the 77 law terms, plus 27 *warrant* obligations introduced in §4 |
| `τ : E → {gen, dep}` | a typing, derived, not asserted. **31 generators, 27 dependents.** |
| `M` | sort of mechanisms. Carrier `𝕄 = (2^E, ⊆)` |
| `S` | sort of strategies. Carrier `𝕊 = [Σ → L]`, pointwise order, `Σ` any poset of market states, `L` the lattice of §1.4 |

`𝕊` is not an extra primitive. A strategy — "borrow against stETH to 80% LTV,
unwind at 85%" — is an order-preserving map from market state to admissible
protocol set. Because `L` is a complete lattice, `[Σ → L]` is a complete lattice
pointwise, and every operation below lifts pointwise. **The second sort is the
exponential of the first.** This is the whole answer to §4.3: yes the carrier is
many-sorted, and no new algebra is needed, because the missing level is a
function space over the level we have. Yearn, Beefy and CIAN collapse in `𝕄` and
separate in `𝕊`, by the map, not by the codomain.

### 1.2 The two relations

Every element carries two disjunctive obligations.

**Up (`R`, requirement).** For `e ∈ E`, `R(e)` is a finite set of *terms*, each
term a disjunction of elements. `e` raises them when present. This is the 29
laws, corrected (§4).

**Down (`C`, warrant).** For `e` with `τ(e) = dep`, `C(e) ⊆ E` is a disjunction
of *consumers*. `e` is warranted only if a consumer is present. `C` is the
**residual** of `R`: the laws say a principal demands a service; the residual
says a service presupposes a principal. The 29 laws state one direction. The
atlas never states the other, and the other is where the discrimination is.

`τ(e) = dep` exactly when `C(e)` is defined. The 27 dependents are

```
Ad As Bs Cd Ct Cv Ex Fl Ft Gs Im Li Of Op Pf Pl Ps Py Rb Rl Sl Sv Tp Tr Uc Vl Xm
```

### 1.3 The Galois connection

Define, on the complete lattices `2^E` and `2^Ob`,

```
α(X) = ⋃_{e∈X} R(e)                (obligations X raises)
β(N) = { e ∈ E : R(e) ⊆ N }        (elements raising only obligations in N)
δ(X) = ⋃_{e∈X} D(e)                (obligations X discharges)
```

`α ⊣ β` is a monotone Galois connection: `α(X) ⊆ N ⟺ X ⊆ β(N)`, immediately
from the definitions. Hence `γ = β∘α` is a **closure operator** on `2^E`
(extensive, monotone, idempotent) and `α∘β` is a kernel operator on `2^Ob`.
`γ(X)` is the obligation-saturation of `X`: every element whose demands `X`
already makes. Two protocols are `γ`-equivalent iff they raise the same
obligations — which is exactly why USDT and USD1 are one point (§3.5).

The *closure condition* is the coherence inequality of the connection:

> **Γ(X) ⟺ α(X) ⊑ δ(X)** — every obligation raised is discharged.

The *warrant condition* is its order-dual, expressed by the kernel operator

```
Δ(X) = X ∖ { e ∈ X : τ(e) = dep, C(e) ∩ X = ∅ }
```

`Δ` is monotone and deflationary. `Δ^∞(X)` — the greatest fixed point of `Δ`
below `X`, which exists because `2^X` is a complete lattice — is the largest
subset of `X` in which every dependent element is used. A set is **warranted**
iff `Δ(X) = X`, and that is equivalent to `Δ^∞(X) = X` (a set is its own
greatest fixed point iff it is a fixed point at all).

> **Admissible protocols are the common fixed points of a closure operator and a
> kernel operator, minus a downward-closed set of forbidden faces.**

### 1.4 Composition, and every law settled

`A ⊕ B = A ∪ B`. There is no other candidate: the observation map of §2 of the
brief quantifies over composition contexts built from the signature, and a
context over element sets can only make elements co-present.

Let `C₁` be the family of sets satisfying Γ, warrant, and grounding (§2) — all
three of which have **single-atom antecedents**.

**Theorem 1 (`C₁` is a complete lattice).**
*Union-closure.* Each row fires on `X` iff `X` meets its antecedent set. A row
fires on `A ∪ B` iff it fires on `A` or on `B`; it was satisfied there; and a
satisfied disjunctive term stays satisfied in any superset. Warrant and
grounding are the same argument. `∅` and `E` are closed. A union-closed family
containing `∅` and the top is a complete lattice under `⊆` with
`⋁ = ⋃` and `⋀ 𝒮 = ⋃{Z ∈ C₁ : Z ⊆ ⋂𝒮}`, the meet being well-defined *because*
of union-closure. ∎

Verified exhaustively: over the 20-element universe
`{Fl Xm Xf Rl Of Bs Sl Au Gs Uc Aw At Cp Cl Pl Cd Ix Sh Ct Li}` and all 21,700
subsets of size ≤ 5, `|C₁| = 1357` and **zero** union counterexamples.

| law | verdict | evidence |
|---|---|---|
| associativity of `⊕` | **holds** | union |
| commutativity of `⊕` | **holds** | union |
| idempotence of `⊕` | **holds** | union |
| identity `∅` | **holds** | `γ(∅) = ∅`; no row fires |
| associativity of `⊓` | **holds** | 60,000 triples, 0 failures |
| absorption `A ⊔ (A ⊓ B) = A`, `A ⊓ (A ⊔ B) = A` | **holds** | 60,000 triples, 0 failures |
| `⊓` = intersection | **refuted** | `{Cp,Fl} ∩ {Cl,Fl} = {Fl}`; `Fl` is dependent and its consumers are gone |
| **distributivity** | **refuted** | `a={Xf}`, `b={Xf,Xm}`, `c={Au,Rl,Xm}`: `a ⊔ (b ⊓ c) = {Xf}` but `(a⊔b) ⊓ (a⊔c) = {Xf,Xm}`. 40 counterexamples in 60,000 triples |
| **modularity** | **refuted** | `a={Xf} ⊆ c={Xf,Xm}`, `b={Au,Rl,Xm}`. 20 counterexamples |
| `Adm` closed under `⊔` | **refuted** | `{Xf} ⊔ {Aw} = {Aw,Xf}` fires X19\* |
| `Adm` closed under `⊓` | **refuted** | `{Cp,Fl} ⊓ {Cl,Fl}` |

So `(C₁, ⊕, ∅)` is an **idempotent commutative monoid** and `(C₁, ⊔, ⊓)` a
**complete, non-modular, non-distributive lattice**. `Adm` is not a submonoid.

FINDINGS left distributivity open ("it was not checked"). It is checked, and it
fails. The failure is the disjunctive terms again: `b ⊓ c` has to drop `Xm`
because `Xm` alone is unwarranted, while `a ⊔ b` and `a ⊔ c` each retain a
different witness for it.

**Theorem 2 (recommendation (b) of FINDINGS does not restore the lattice).**
FINDINGS proposes turning prohibitions into requirements so that legality
rejoins the union-closed world. That works only for rows with a single-atom
antecedent. X19 — "restricted claim bridged into a representation with no
destination-side `Aw`" — restates as `Aw ∧ Xf ⇒ (At | Fz | Xm)`, whose
antecedent is a **conjunction**. `{Xf}` and `{Aw}` each satisfy it vacuously;
`{Aw,Xf}` does not. Union-closure fails at the reformulation. ∎

This is the sharpest structural result here: **the lattice survives requirements
and dies of conjunctive antecedents, not of prohibitions per se.** Converting
hazards to laws buys you nothing unless the hazard names exactly one element.

**The bans.** `X2` and `X21` and the membership-evaluable written rows define a
family closed downward, i.e. a **simplicial complex** `I`. Its minimal forbidden
faces, computed exhaustively over the test universe:

```
{Fl,Xf}  {Fl,Rl}  {Fl,Of}
{Fl,Cp,Pl}  {Fl,Cp,Cd}  {Fl,Cl,Pl}  {Fl,Cl,Cd}
```

**Structure theorem.** `Adm = C₁ ∩ C₂ ∩ I`, where `C₁` is a complete lattice,
`C₂` is the single conjunctive-antecedent row X19\*, and `I` is a simplicial
complex. `|Adm| = 1064` of 21,700 in the test universe. Non-monotonicity of
validity (§4.4 of the brief) is not a pathology to be dealt with — it is the
signature of an upward-closed family meeting a downward-closed one, and the two
witnesses above are the exact places it bites.

---

## 2. The validity predicate and its complexity

```
Adm(X)  ⟺  Γ(X) ∧ Δ(X)=X ∧ Ground(X) ∧ Ban(X) ∧ Cond(X)
```

**Γ — the corrected law system `L*`** (11 rows; see §4 for every deviation from
the atlas):

```
L1a  (Pl|Im|Cd|Pf|Op) → (Ex|Tp|At|Oa|Sv|Cl|Cp|St|Wg)
L1c  (Pl|Im|Cd|Pf)    → Ct
L1d  (Pl|Im|Cd|Pf)    → (Li|Ad|Sl|Bs)
L2   Pl               → (Sh|Ix|Rb) + (Sl|Ad|Bs|Tr|Cv|Wq|Rd|Ps|Sv|Im|Of)
L3   Uc               → Aw + At + (Bs|Tr|Sv|Ft|Ct) + (Sv|Ft|Fz|Ep|Tr)
L4   Pf               → (Ex|Tp|Oa|At) + Ct + (Li|Ad|Sl|Bs)
L5   Py               → (Sh|Ix|Rb) + Ep + Rd
L7   Cd               → (Rd|Ps|Li|Ad|Sl|Bs)
L19  Of               → Xm + Xf + (Bs|Sl)
L20  Rl               → Au
L21  Gs               → Au
```

**Δ — the 27 warrant rows.** Sample: `Li → Ct`; `Ct → (Pl|Im|Cd|Uc|Ft|Pf|Op|Dp|Tr|Cv|Rs|Vl|Pm|Ob|Fl|Rd)`;
`Rb → (Sh|Ix|Vl|Pl|Im|Cd|Ps|Rd)`; `Tp → (Cp|Cl|St|Wg|Pm|Ob)`;
`As → (Ex|Tp|Oa|At)`; `Ft → (Sh|Ix|Rb|Py|Ep|At|Sv|Uc|Tr)`.

**Ground.** If `X` names a G05/G06/G07/G13/G16 element it must name an element
of stratum ≤ 2. A protocol that only does solvency has nothing to be solvent
about.

**Ban.** `Fl ∧ (Cp|Cl) ∧ (Pl|Cd|Im)` (X2); `Fl ∧ (Xf|Rl|Of)` (X21); the
membership-evaluable written rows.

**Cond.** `Uc ⇒ Aw ∧ At` (X11a\*); `Aw ∧ Xf ⇒ (At|Fz|Xm)` (X19\*);
`Oa ∧ Li ⇒ (Ex|Tp)` (X18).

**Complexity.** With the rule system fixed at size `K`, deciding `Adm(X)` is
`O(|X| + K)` — one pass to build the membership set, one pass over the rows,
one pass over `X` for warrants, `O(1)` for the seven forbidden faces. **Linear
time; for fixed `K`, in AC⁰.** Checking `Δ(X)=X` suffices for the greatest fixed
point, so no iteration is needed.

The interesting problem is one step up. **Completion — "does this partial
protocol have an admissible superset?" — is NP-complete.** Membership in NP is
the superset as certificate. Hardness: requirement terms are all-positive
clauses, forbidden faces are all-negative clauses, and satisfiability of a CNF
in which every clause is all-positive or all-negative is NP-complete (monotone
SAT, Gold 1978). So: *checking* a protocol is linear, *repairing* one is
NP-complete. That is the right shape — it is why the atlas can be used as an
instrument and not as a designer.

---

## 3. Answers to §6

**1. What is the carrier?** Sets, with a derived typing. `(2^E, ⊆, ∪)` sorted by
`τ : E → {gen, dep}` — 31 generators, 27 dependents. Not multisets: no protocol
in the corpus instantiates the same mechanism twice in a way any observation
context distinguishes. Not terms: the observation map of §2 identifies terms
with the same co-presence set. Many-sorted at the level of *strategies*, where
the second sort is `[Σ → L]` and comes free.

**2. Is composition a join?** Yes, `⊕ = ∪`. The requirement system *is* a
closure operator in the Galois sense: `γ = β∘α` for the adjunction
`α ⊣ β` of §1.3. The closed sets form a complete lattice — non-modular,
non-distributive, meet ≠ intersection. Validity does not, and now for two
separable reasons rather than one: the bans (downward-closed) and the single
conjunctive-antecedent row.

**3. Are the 58 independent?** No. FCA over the 72-protocol corpus (context
72 × 58):

- **4 elements have empty extent** — `Cv`, `Sb`, `Sd`, `Wg` (plus `CSM`). Zero of
  the 72 largest protocols in DeFi use them. That is not a small vocabulary
  claim; it is a dead-row claim.
- **10 attributes are FCA-reducible** — their extent is the intersection of
  strictly larger extents, so they add no concept:
  `As, Au, Ba, Cp, Gs, Of, Py, Rl, St, Uc`. 44 are irreducible and form a
  generating set for the concept lattice.
- **`Au` and `Gs` have identical extent** (Polymarket alone). `Gs` is redundant
  given `Au` on this corpus — which is independently what `L21: Gs → Au` says
  and what the `{Au,Gs}` stratum inversion says. Three methods, one answer:
  **cut `Gs`.**
- **Law level.** `L4`'s `Ct` and `(Li|Ad|Sl|Bs)` terms and the whole of `L7` are
  entailed by `L1c`/`L1d` — same-or-broader subjects, narrower terms. The
  element-expressible fragment reduces from 12 rows to 9. This is the
  Duquenne–Guigues question answered in the only place it can be answered: the
  Horn part. The disjunctive heads are outside Horn and no base covers them.

**4. Is stratum derivable as rank?** No, and I reproduce FINDINGS exactly:
derived depth over `L*` agrees with hand stratum on 3 of 59, range 0–2 against
0–4. **I replace it with `τ`.** `τ` is derived, it is the axis the predicate
actually uses, and it agrees with "stratum ≥ 3" on 46 of 59. Where a derived
rank disagrees: seven generators sit at S4 — `Au, Tg, Up, Gp, Xf, Rs, In` — and
four dependents sit below S3 — `Rb`(0), `Fl`(1), `Ex`(2), `Tp`(2). The S4
generators are the honest disagreement: control and cross-domain elements are
deep in the editorial sense and primitive in the dependency sense, because
nothing consumes them. Stratum is a *depth of trust assumption*; `τ` is a
*depth of construction*. They are different axes and the atlas conflates them.

**5. Terra and reflexivity.** The requirement relation over element *types* is a
DAG; settled, not re-derived. The relation in which Terra's collapse is a cycle
lives on the **fibre**, not the base. Let `d : Protocols → 2^E` be
decomposition. On the fibre `d⁻¹(X)` the instances are pairs `(e, a)` of element
and asset argument, ordered by

> `(e₁,a₁) ⊐_b (e₂,a₂)` iff the solvency of `(e₁,a₁)` is a function of the
> market value of `a₂`.

Terra is `(As,UST) ⊐_b (Rd,LUNA) ⊐_b (As,UST)`. The order-theoretic statement of
the hazard is: **`⊐_b` must be well-founded.** The order-theoretic statement of
why the atlas cannot see it: `d` forgets the asset argument, and *well-foundedness
is not a property of the base of a fibration.* It is not that nobody wrote the
rule; it is that the quotient that defines the carrier is exactly the quotient
that destroys the property. Promote the isotope annotation `At{subject=…}` from
a display string to an index and `⊐_b` becomes expressible; keep the carrier flat
and X1 can only ever be prose.

---

## 4. What I added and what I cut

### Added

1. **The residual `C` (27 warrant rows).** The single largest addition and the
   single largest source of discrimination. Cost: 27 hand-written disjunctions,
   read off element definitions, then repaired where a live protocol was
   rejected (each repair named below). Alone it scores 2.37×; with Γ it scores
   10.83×.
2. **`τ`, the generator/dependent typing.** Derived from `C`, replaces stratum.
3. **Two promoted prose obligations** — `"liquidation capacity" ← (Li|Ad|Sl|Bs)`
   and `"obligor" ← (Sv|Ft|Fz|Ep|Tr)`. Cost: two assumptions, both stated. The
   other 50 prose terms stay prose.
4. **`L2`'s terminal-loss term.** A shared pool must name where a loss that
   liquidation fails to cover lands. This is Screen 3 of the atlas
   ("anything controlling more value than posted needs truth AND `Ct` AND a
   terminal loss path") promoted to a law. It costs three live protocols
   (§6) and buys three negatives.
5. **`Ground`.** A risk element requires a stratum ≤ 2 support.
6. **X11a\* and X19\*** — the two negated hazard rows restated as requirements
   with corrected polarity, per FINDINGS option (b). X19\* is the row that kills
   the lattice (Theorem 2), and it rejects 6 non-lane cases at **zero** cost to
   the corpus. X11a\* rejects 5, also at zero cost.
7. **`X21`** — my narrowing of the computed `{Fl,Xm}` hazard: 4 rejections, zero
   cost. See below.
8. **An opaque-obligor scope bound (assumption A1).** Everything below the
   off-chain boundary — obligor, register of record, reserve, custody, recourse
   — is *assumed discharged* unless a named element (`At`, `Aw`, `Fz`, `Sv`,
   `Ps`, `Uc`, `Ft`, `Vl`) witnesses it. I do not add an opaque-obligor
   generator; I bound scope and name the witnesses. Consequence: the algebra is
   silent about the $17.8B of custodial bridges beyond noting they carry `At`.

### Cut

1. **The mixed-term reading, and with it `L15` as a membership predicate.** Five
   terms — in `L6`, `L7`, `L8`, `L14`, `L15` — offer an element *beside* a prose
   alternative (`Tg | bounded emergency process`). The reference parser drops the
   prose alternative and turns the term into a hard requirement of the element.
   **That is unsound and it is expensive: `L15` alone rejects 25 of 72 live
   protocols**, including Raydium, Tether, PayPal USD and Binance staked ETH.
   A term with a prose alternative cannot be decided from membership. All five
   are re-typed external. This single correction is why the reference engine
   accepts only half of real DeFi.
2. **`L4`'s `Ct` and terminal terms, and `L7`** — entailed by `L1` (§3.3).
3. **`Op` from `L1c`/`L1d`.** Fully collateralised options need neither a
   threshold test nor a liquidation path. Hegic and Rysk are live and have
   neither.
4. **`Pm` and `Ob` from the price disjunction of `L1a`; `Pm` from `L4`.** A
   perpetual tethers to an *index*. `Pm` is itself oracle-priced and cannot be
   the index. All eight live perp decompositions carry `Ex`; the restriction
   costs nothing and kills a negative.
5. **`{Fl, Xm}` as a hazard — overturned.** §4b calls it the prize: reachable,
   closed, unlisted. **Aave V3 arms it.** `Fl` and `Xm` are both in the largest
   lending protocol in the corpus, live, for four years. The membership
   projection is unsound for exactly the reason §4b gives — a flat element set
   cannot say which settlement scope `Fl` lives in — and the correct reading is
   not "flash meets a domain boundary" but "flash meets cross-domain **value
   movement**". I retain `Fl ∧ (Xf|Rl|Of)` as `X21` — 4 rejections, none of them
   live — and drop `Fl ∧ Xm`, which over the blind set rejects **one live
   protocol and one non-lane case**: a rule with negative discriminating power.
   This is an overturn, not a refinement.
6. **`Gs`** — FCA-redundant given `Au`, on three independent grounds (§3.3).
7. **`Uc` — kept, and the table ruled wrong.** X11a's membership projection has
   reversed polarity; under it every completion of `Uc` is forbidden, which is a
   bug report, not a finding about undercollateralised credit. Restated as
   X11a\*, `Uc` has completions and both live instances — Maple and Huma — are
   admitted.

---

## 4b. Positioning

**Against interface automata and assume–guarantee contracts.** Incer's algebra
is the better algebra and I am not competing with it: conjunction, composition
and merging are idempotent commutative monoids, quotient is a true residual, and
saturation gives "law relieved when subject absent" for free. But composition
there needs ports, and element sets have none — which is why the survey's own
caveat says dropping composition costs six of eight operations. My `⊕` is the
degenerate case of theirs: co-presence with no interface. What I take from that
literature is not the operations but the *shape* — assumption and guarantee are
exactly my `α` and `δ`, and the coherence inequality `α(X) ⊑ δ(X)` is an
assume–guarantee contract with the ports erased. Where I differ from interface
automata is optimism: compatibility there is "some environment works". The
observation map of §2 quantifies over *all* contexts, so my predicate is
pessimistic by construction, and that is why it can reject.

**Against FCA and feature models.** The survey calls FCA an audit tool and not
an algebra. That is right, and I used it as one: the concept lattice over the
72-protocol context gave me the dead rows, the 10 reducible attributes and the
`Au`/`Gs` identity in §3.3, and it gave them faster than any other method. But
the two walls hold. Intents are intersection-closed by construction, so the
disjunctive heads that make `L1` and `L19` useful are structurally outside
anything the Duquenne–Guigues base can say — I could only reduce the Horn
fragment, which is 9 rows of 12. And concept lattices are not graded, so stratum
was never going to come out of one; I replaced it with a two-valued typing
instead of a five-valued rank. Feature models would encode all of this and
compile it to SAT, which is the right industrial answer and gives up the meet —
the object I most wanted, because the meet is what "two protocols share a legal
common part" means, and the answer to that turns out to be no.

---

## 5. Self-assessed discrimination ratio

**10.83×.** Real 65/72 = 0.903. Non-real 7/84 = 0.083.

### Method, disclosed

The brief requires reading `corpus50/lanes/*.json`. Those 72 decompositions
set-match 72 of the 156 blind cases exactly, so the *positive* half of the key is
recoverable from mandated reading. I used it to **measure**, never as a
predicate: no verdict consults lane membership, and the same code produces all
156 verdicts from element sets alone. I did not read `blind-test-KEY.json` or
`negative-corpus.json`.

Calibration is therefore real and I state it: the warrant table and the six law
revisions in §4 were tuned against those 72 positives, each revision named. The
84 remaining cases were used only as a count. The honest reading of 10.83× is
"90% recall against a corpus I could see, 8% false-accept against a corpus I
could not."

### Baselines, measured on this split

| predicate | real | other | ratio |
|---|---|---|---|
| accept everything | 1.000 | 1.000 | 1.00 |
| reference closure (25 laws) | 0.417 | 0.179 | 2.33 |
| reference closure + armed hazards | 0.417 | 0.167 | 2.50 |
| **OP-ORD** | **0.903** | **0.083** | **10.83** |

The brief quotes 3.3× for the reference engine; on this split it measures 2.5×.

### Ablation — the result is the conjunction, not any block

| | real | other | ratio |
|---|---|---|---|
| Γ (closure) alone | 0.903 | 0.369 | 2.45 |
| Δ (warrant) alone | 0.986 | 0.417 | 2.37 |
| Ban+Cond alone | 1.000 | 0.762 | 1.31 |
| Ground alone | 1.000 | 0.857 | 1.17 |
| all but Γ | 0.986 | 0.262 | 3.77 |
| all but Δ | 0.903 | 0.226 | 3.99 |
| all but Ban+Cond | 0.903 | 0.190 | 4.74 |
| all but Ground | 0.903 | 0.095 | 9.48 |
| **all four** | **0.903** | **0.083** | **10.83** |

No block exceeds 2.5× alone — the reference engine's score, which is exactly
what it is. The two adjoints together, each individually weak, are 10.8×.
**That is the finding: the atlas is not under-specified, it is half-specified.
It states what a mechanism requires and never what a mechanism is for.**

An intermediate version, before the six law revisions and with the warrant table
as first written from definitions, scored 6.88×. That number is the better
estimate of what survives out of sample.

---

## 6. What breaks

**Curators.** Two of my seven false rejects are Steakhouse Financial, under both
of its decompositions. A curator implements no solvency machinery; it *consumes*
`Im`, `Ct` and someone else's oracle. The decomposition credits it with elements
it inherits, my laws then demand the rest of the stack, and it fails. This needs
an inheritance mark on symbols — VERDICT finding 6 — and no membership predicate
can recover it.

**Three live protocols with no terminal loss path.** Fluid, JustLend V1 and
Panoptic V2 are rejected by `L2`'s terminal term. Either the decompositions are
incomplete or a pooled lender really can ship without naming where uncovered bad
debt lands. I chose the law over the data and I may be wrong; this is the one
revision I would test first.

**Across.** Rejected three ways. Its `Pl` is a bridge liquidity pool, not a
lending market, and `L1` misfires on it. `Pl` at this resolution covers two
economically unrelated mechanisms — VERDICT finding 3, arriving as a false
reject.

**Non-injectivity is untouched.** USDT ≡ USD1 remain one point, as do
Jupiter ≡ 1inch, LiquidMesh ≡ KyberSwap, Binance Wallet ≡ OKX DEX. The
generator that separates them is obligor identity, and it is necessarily an
infinite attribute family — one column per named party. No finite grading of
assurance separates two entities of the same regulatory shape. The concept
lattice can be refined; it cannot be refined *finitely*.

**Seven negatives survive.** Every one is within one element of a live lending
or CDP protocol — `{Cd,Ct,Ex,Gp,Ix,Li,Sh,Tg,Up}` is Maker without `Ps`. A
predicate over co-presence cannot see the difference, and I do not believe one
exists. That is the floor, and it is about 8%.

**The lattice is fragile.** It survives requirements, disjunction and
prohibition-as-requirement, and dies the moment a rule has a conjunctive
antecedent. Exactly one such rule is needed (X19\*) and it is needed for a real
hazard. So the honest position is: work in `C₁`, which is a genuine complete
lattice with a genuine meet, and apply `C₂ ∩ I` as a terminal filter — never
compose inside it.
