# Proof obligations

> **Note.** Identity claims between protocol decompositions are false against the arrays in corpus50/lanes. Of 10 claimed identical groups only 3 hold: USDT/USD1, LiquidMesh/KyberSwap, Binance Wallet/OKX DEX. Use containment (80 strict pairs, computed by viz/scripts/check-collisions.py) rather than identity.


> **Status of every obligation below is tracked in [`THEOREM-LEDGER.md`](THEOREM-LEDGER.md).** Do not resolve a contested entry silently.

What a candidate algebra must discharge before we say it exhibits completeness
and composability. Stated schematically over any model `M = (G, A, ⊕, ⊨)`:

- `G` the generating signature (our 58 elements, plus whatever is added)
- `A` the carrier — what a protocol *is* in the model
- `⊕` the composition operation
- `⊨` the validity predicate
- `⟦·⟧` the observation map, **fixed in BRIEF §2 and not negotiable**: reachable
  net-payoff outcomes per agent class under adversarial environment
- `≃` observational equivalence induced by `⟦·⟧`, contexts restricted to terms
  over `G`

A theorem is discharged by a proof or refuted by a counterexample. **A refutation
is a discharge.** What is not acceptable is leaving one open.

---

## S. Was "already settled". Three of five have since fallen.

> **Correction, and it is a root cause.** The reference parser treated a mixed
> term — an element beside a prose alternative, e.g. `L15: "Tg | bounded
> emergency process"` — as a **hard requirement on the element**, silently
> dropping the prose disjunct. Five terms did this. `L15` alone rejected 25 of
> 72 live protocols. Fixed: a term with any prose alternative is undecidable
> from membership and becomes residue, exactly as a fully-prose term does.
>
> Closure went from 6/12 to 9/12. **Lido, Centrifuge and Euler now close.** The
> only survivors are CCTP and the two genuine deaths, Terra and Mango.
>
> The Quint model was built from the same spec and reproduced the same error, so
> "two independent implementations agree" meant two implementations sharing a
> spec bug — not confirmation. Everything below inherited from closure results
> is now suspect, and the entries are marked accordingly.

These are established by Apalache plus exhaustive enumeration over the full
58-element vocabulary. A model that violates one is wrong unless it explicitly
overturns the result.

| | Result |
|---|---|
| **S1** | Closed sets are union-closed, contain ⊥ and ⊤, and form a complete lattice. |
| **S2** | ~~Meet is not intersection.~~ **CONTESTED.** OP-LOG splits the laws into 8 definite Horn productions plus constraints, finds the definite fragment has height 1, and recovers `⊓ = intersection` on a completely distributive lattice of 3,140 closed sets. The failure is a fact about disjunction, not about the lattice. |
| **S3** | Validity is **non-monotone**: `{Xm,Xf} ∪ {Aw}` arms X19. Closure is lattice-structured; validity is not. |
| **S4** | **CONTESTED.** Not derivable *as rank over the law graph* — agreement on 3 of 58, all trivial; FCA independently confirms concept lattices are not graded. **This is narrower than "stratum must stay asserted", and OP-CAT has already found the loophole legitimately**: derived as the maximal sort of a typing functor it agrees 57/58. S4 constrains one derivation basis, not all of them. |
| **S5** | **HOLDS — three independent confirmations.** The requirement relation is a DAG with no self-loops, so no subset of elements can contain a cycle. OP-CAT expresses Terra only by moving to element *instances* with asset and party sorts; GP-ORD confirms inexpressibility over element sets directly. |

---

## X. Composability

**X1 — Closure of the carrier.** `∀ a,b ∈ A. a ⊕ b ∈ A`.
*Mandatory.* If `⊕` can leave the carrier, nothing below is well-posed.

**X2 — The equational laws.** For each of associativity, commutativity,
idempotence, identity, absorption: prove it holds or exhibit a counterexample.
*Mandatory, all five, no abstentions.* Partial structures are acceptable
results — "a commutative idempotent monoid, not a semilattice, because absorption
fails at ⟨witness⟩" is a discharge. "We did not investigate absorption" is not.

**X3 — Congruence.**
> `a₁ ≃ a₂  ⟹  a₁ ⊕ b ≃ a₂ ⊕ b`  for all `b`.

*Mandatory, and the load-bearing one.* Without it `≃` supports no equational
reasoning and the model is a classifier wearing algebraic notation. If it fails,
the failure is a major result: exhibit the discriminating context.

**X4 — Compositionality of validity.** This is what the brief means by
composable, stated precisely:
> There is a finite abstraction `ι : A → I` and a function
> `f : I × I → {0,1}` with `⊨(a ⊕ b) = f(ι(a), ι(b))` for all `a, b`,
> and `|I|` bounded independently of protocol size.

*Mandatory.* You must not have to re-analyse the whole system to validate a
composite. **A proof that no such `ι` exists — that DeFi composition is not
compositional in this sense — is a major negative result and fully discharges
this obligation.** Note S3 makes the naive `ι = identity on element sets` fail;
that is a starting point, not the answer.

**X5 — Non-monotonicity, characterised.** S3 says validity is non-monotone.
Do not restate it — **bound it**:
> Characterise `{(a, g) : ⊨a ∧ ¬⊨(a ⊕ g)}` — every way adding a single
> generator can destroy validity — and prove the characterisation complete.

*Mandatory.* This is the set the visualization has to draw and the set a
composition checker has to test. An enumeration with a completeness proof is
the deliverable.

**X6 — Decidability and complexity.** `⊨` is decidable; state the complexity
class and the algorithm. *Mandatory.* Our enumeration touched 5,038,954 subsets
at size ≤5; anything worse than that at realistic sizes needs justification.

**X7 — Quotient / residual.** Given `a` and target `c`, does
`a ⊕ x ⊑ c` have a greatest solution `x`? *Optional but high value.*
Assume-guarantee contracts have a true residual; if yours does, you can answer
"what must I add to make this safe", which is the question the atlas exists to
answer.

---

## C. Completeness

**C1 — Corpus adequacy.**
> For every protocol `p` in the 72-entry corpus there is a term `t` over `G`
> with `⟦t⟧ = ⟦p⟧`.

*Mandatory.* Adequacy is relative to `⟦·⟧` and to the corpus, and both are
declared. This is ACTUS-with-teeth, not a completeness theorem, and it must be
labelled as such.

**C2 — Separation on the negative corpus.**
> `⊨` accepts the REAL cases and rejects KNOCKOUT, ARMED, INVERTED.

*Mandatory, and quantified:* the knockouts differ from a working protocol by
exactly one symbol — the sole satisfier of a fired requirement — so any model
scoring below 100% on KNOCKOUT is not reading the laws at all. RANDOM and HYBRID
are graded, not pass/fail. **Discrimination ratio must exceed 3.3×**, the
baseline set by our own closure predicate.

**C3 — Independence of generators.**
> For each `g ∈ G`, exhibit `t₁, t₂` over `G∖{g}` with `t₁ ≃_{G∖{g}} t₂` and
> `t₁ ≄_G t₂`.

Any `g` failing this is **not a generator** and must be demoted to a derived
operator with a definitional equation. *Mandatory in aggregate* — we require the
minimal generating set and the list of demotions, not 58 separate write-ups.
This is the obligation that attacks the encoding bias directly: five pricing-curve
generators against one option generator is a claim that the five are independent,
and it is probably false.

**C4 — Conservativity of extension.** Every generator added during the work
gives a conservative extension: **no junk** (no new inhabitants of existing
sorts) and **no confusion** (no new identifications of previously distinct
terms). *Mandatory.* The corpus named ~57 missing mechanisms; adding them
carelessly collapses the model.

**C5 — Fibre separation.** The decomposition map is not injective and the
fibres are not semantically homogeneous — USDT ≡ USD1, USDC ≡ PYUSD, USYC ≡
BUIDL, and the top three bridges by TVL share five symbols.
> Either `⟦USDT⟧ ≠ ⟦USD1⟧` in the model — then name the separating generator —
> or prove that **no function of element sets separates them.**

*Mandatory.* Both discharge it. The second is the more important theorem and we
expect it to be the true one: it would establish that solvency is not a function
of mechanism inventory, which is the strongest claim this project could make.

**C6 — Carrier adequacy for reflexivity.** By S5 the killing loop is not
expressible over element types; it becomes a 2-cycle over `(element, asset)`
pairs under `backs`.
> Either the carrier expresses Terra's loop — exhibit it — or prove the carrier
> cannot, and state the minimal enrichment that would.

*Mandatory.* "Our carrier is element sets" plus S5 is already a refutation; say
so explicitly rather than passing over it.

**C7 — Sortedness for the strategy level.** A Yearn or Steakhouse vault is a
policy *over* protocols, with no mechanism of its own.
> Either the carrier is many-sorted and holds a policy — give the sort and its
> formation rules — or prove a one-sorted carrier cannot, and say what is lost.

*Mandatory.* $3.08B sits in the largest such object and no symbol names it.

---

## D. Where we expect impossibility, and want it proved

These are not required. Any one of them, proved, is worth more than a working
model, and they should be attempted only after the mandatory obligations are
discharged.

**D1.** No `ι` witnesses X4 — DeFi composition is not compositional at any
finite abstraction.

**D2.** No function of element sets separates the C5 fibres. *(We think this
one is true.)*

**D3.** There is no semantic class `C`, specified independently of `G`, with
`⟦Term(G)⟧ = C` — i.e. no expressive-completeness theorem of Kamp's kind is
available for DeFi, and here is the obstruction.

**D4.** `⊨` and monotone closure cannot be reconciled: any predicate agreeing
with the hazard rules on the corpus is non-monotone. *(S3 gives the instance;
the theorem is the general statement.)*

---

## Acceptance

A model **exhibits composability** iff it discharges X1–X6.
A model **exhibits completeness** iff it discharges C1–C7.

A discharge is a proof *or* a refutation with a witness. A model that refutes
X4 and C5 and proves everything else is a better outcome than one that quietly
assumes both — it tells us what DeFi is actually like.

One more constraint, from the negative corpus: **`Uc` currently has zero
hazard-free completion.** The hazard table forbids every way of building one of
our own elements. Any model that validates the corpus must either drop `Uc` or
repair the table, and must say which.
