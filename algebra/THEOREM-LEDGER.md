# Theorem ledger

**The authoritative record.** Everything proved, refuted, contested or open across
the nine-model council and our own model checking. `MODEL.md` explains the model;
`THEOREMS.md` states the acceptance obligations; **this file is the running score
and nothing may be dropped from it.**

Rules: a refutation with a witness is a *result*, not a failure. Every entry
carries who established it and what the evidence was. Contested entries stay
contested until adjudicated — no silent resolution.

---

## PROVED

| # | Statement | By | Evidence |
|---|---|---|---|
| **P1** | **Requirement clauses are dual-Horn (≤1 negative literal) so their model class is union-closed; hazard exclusions are pure-negative Horn so theirs is intersection-closed; `ADMISSIBLE` mixes the polarities and is provably a lattice under neither.** | GR-LOG | Schaefer/Post duality. Derivable from the law language without execution. |
| **P2** | The definite fragment (8 laws) has height 1 — bodies and heads disjoint — so `Cn` is a one-pass Galois closure and closed sets are exactly the up-sets of a 54-point poset: a completely distributive lattice with `⊔ = Cn(∪)`, `⊓ = ∩`. | OP-LOG | machine-checked over 3,140 closed sets; assoc/comm/idem/absorption/distributivity all hold |
| **P3** | **DOWNGRADED — the construction holds, the claim about it does not.** Requirements and warrants do form an adjoint pair and the 27 warrant rows are real. But `Γ ∧ Δ` scores **4.46×**, *below* the 5.79× independence predicts — they are sub-multiplicative — and over half of the headline 10.83× comes from Ban+Cond and Ground, blocks never credited. Warrant is worth ~1.8× over closure, not 4.4×. **And `Δ` is not idempotent, so it is not a kernel operator.** | OP-ORD (numbers), Quint v2 (refutation) | every ablation cell reproduced to the digit; the causal story did not |
| **P4** | The requirement relation over all 58 elements is a DAG with no self-loops, so **no set of element types can contain a cycle**. | Quint + OP-CAT + GP-ORD + GR-CAT | four independent confirmations |
| **P5** | Terra's collapse *is* a 2-cycle over `(element, asset)` under `backs := reads ; over⁻¹` — and crvUSD, comparable element set, has none. | OP-CAT | computed, with control |
| **P6** | USDT and USD1 separate under a party sort: their `attests-to` edges point at different `Prt` nodes. | OP-CAT | constructive |
| **P7** | Under scope bounded to on-chain state machines, **`USDT ≡ USD1` is a theorem**. | OP-LOG | derived under the fixed observation map |
| **P8** | The forgetful functor `U : DecProt → Sub(E)` has **both** the non-injectivity and the reflexivity-invisibility in its kernel — one phenomenon, not two. | GR-CAT | unifies P5–P7 |
| **P9** | The full closed-set family is union-closed but **not a Moore family**, so no single-valued Galois closure operator exists over it. Terra has four incomparable minimal completions. | GR-CAT | consistent with P1/P2 — the Horn core is well-behaved, the mixture is not |
| **P10** | **`⊕` is not a congruence for validity** — refuted on all four closures with witnesses. (Discharges obligation X3 by refutation.) | OP-LOG | explicit witnesses |
| **P11** | Stratum **is** derivable — not as law-graph rank (3/58) but as the maximal sort of the typing functor (**57/58**, `Pm` the sole exception). | OP-CAT | the `Gs→Au` inversion dissolves; sort powerset is not linearly ordered |
| **P12** | `X11a`'s polarity is inverted, and `Uc` is **realizable** — subsumed by L3 under closure. Our "zero hazard-free completion" was a projection bug. | OP-CAT, OP-LOG, GP-ORD, GR-LOG, GR-CAT | five of nine, unanimous among those who ruled |
| **P13** | HYBRID acceptance is a **structural consequence of union-closure**, not a contamination signal: a union-closed model class must accept splices. | GR-LOG | corrects our own benchmark design |
| **P14** | The reference parser treated mixed terms (`Tg \| bounded emergency process`) as hard element requirements, dropping the prose disjunct. Five terms; `L15` alone rejected 25 of 72 live protocols. Closure **6/12 → 9/12**. | OP-ORD, OP-LOG; verified in our own code | Lido, Centrifuge, Euler all close once fixed |

## REFUTED / DEAD

| # | Claim | Why it died |
|---|---|---|
| **R1** | `{Fl, Xm}` as a flat membership hazard — our model checker's "prize" | Flags **Aave v3**. Council split 3–3, but asymmetric: the three who promoted it followed our FINDINGS, the three who killed it *tested against the 72-protocol corpus*. Evidence beats provenance. The narrowing `Fl ∧ (Xf\|Rl\|Of)` survives. |
| **R2** | "Meet is not intersection" as a general fact | True only outside the definite fragment (P2). |
| **R3** | "Stratum is not derivable" as a general fact | True only for law-graph rank (P11). |
| **R4** | "Euler fails closure for a reason unrelated to why it died" | Our parser bug (P14). Euler had a bounded emergency process; L15 permits either. |
| ~~**R7**~~ | ~~AFT as our framework~~ | **WITHDRAWN.** See T0 — the refutation was of one construction, not the framework. The genuine risk is informativeness (`U_O` can return `(⊥,⊤)`), not applicability. Two independent obstructions (AFT, bilattices) with the same cause: validity is a diagonal, and componentwise structures cannot see diagonals. |
| **R8** | `{Fl, Xm}` dies because it fires on Aave v3 | It dies on **warrant** — neither element has anything to be *for*, so `Δ` would have killed it on day one. But the atomic-scope family is **sharpened, not killed**: 78 of 81 minimal witnesses are admissible, arm no listed hazard, and appear in **none of the 72 live protocols**, all of shape `{w_Fl, Fl, Xm, w_Xm}`. There IS an unlisted hazard family; it is not the flat pair. |
| **R9** | OP-LOG's definite fragment is 8 rules over 3,140 closed sets | It is **16 rules**, and two of OP-LOG's eight (`Rs→Vl`, `Ad→Li`) **appear in no law text**. The lattice has ~2.2×10¹⁵ elements; 3,140 was a corpus sample, not the lattice. Height-1 itself is independently confirmed. |
| **R6** | Bilattices as the home for two opposite polarities | Refuted by the theorem we hoped would help. Avron Thm 3.3: every interlaced bilattice is isomorphic to a componentwise product `L⊙R`, uniquely. Setting `L = Fix(Γ)`, `R = Fix(Δ)` gives pairs *(closed set, open set)* with no constraint that the coordinates agree — our validity set is the **diagonal**, and the representation theorem makes the structure componentwise and therefore blind to it. It would also make validity a lattice under *both* orders, where P1 says neither. **Keep the carrier `L²`; drop the framework.** |
| **R5** | "Two independent implementations agree" as verification of closure | Quint was built from the same spec and reproduced the same bug. Shared spec error, not confirmation. |

## OPEN — the work to do

Ordered by value. **T2 is the one that matters most.**

| # | Statement to prove | Why |
|---|---|---|
| **T2** | **PARTIAL ANSWER, and it is usable.** A union-closed fragment `F` covering **47.8% of admissible sets certifies 59% of live protocol pairs with zero errors** — compositional checking is sound there. Caveat: `F` is a **join-semilattice, not a sublattice**, and maximality is open in [11026, 23055). *Original:* **Find the largest sublattice on which `⊕` IS a congruence.** **CANDIDATE ANSWER: the stratifiable fragment.** Vennekens–Gilis–Denecker, Def. 3.3 / Thm. 3.5: an operator `O` is *stratifiable* iff `∀x,y,i: x|⪯i = y|⪯i ⟹ O(x)|⪯i = O(y)|⪯i`, and then `x` is a fixpoint of `O` **iff** each `x(i)` is a fixpoint of `O_i^{x|≺i}`. It is an **iff**, so composition-preserves-validity is exactly stratifiability, and our counterexamples should be exactly the non-stratifiable compositions. **Verify this.** | P10 refuted congruence in general. This turns the negative into the practically useful positive: it names exactly which protocols compose without re-analysis, which is the entire promise of composability. |
| **T0** | **REOPENED — I closed this too early.** Building `A` from `Γ` and `Δ` collapses componentwise, but that kills one construction, not the framework: `U_O` exists for *any* operator in closed form with no hypotheses, the antitone slot is definitional to approximators rather than demanded of ingredients, and splitting needs no approximator at all. **New decisive test: brute-force `U_O` on the smallest known-answer instance — if `WF ≠ (⊥,⊤)`, AFT is live.** *Superseded text:* ANSWERED: NO. `Γ` and `Δ` are both monotone, so neither fills AFT's antitone slot and any `A` collapses to a componentwise product — the same obstruction that killed bilattices. Stratifiability ≠ union-closure (`Pl ∧ Of → Ct`). AFT does not transfer. *Original text:* **The AFT go/no-go, and do it before committing.** AFT's two components are the lower and upper bound of **one** operator; our `Γ` and `Δ` are two **different** operators. The shapes coincide, the meanings may not. Concretely: **can we define `A(x,y)` from `Γ` and `Δ` that is `≤_p`-monotone?** Yes → we inherit three semantics plus the splitting theorem, and T2 falls out. No → AFT gives us nothing and the resemblance was cosmetic. This is a decidable check and it gates everything above. |
| **T1′** | Enumerate the `γ`/`Δ` non-commutation obstruction. P1 proves they do not commute; the obstruction is finite and computable. | Converts a structural impossibility into a bounded exception list. |
| **T3** | **Birkhoff reduction:** prove the 29 laws are redundant and the real object is the 54-point poset; exhibit its Hasse diagram. | Would replace the law list with a partial order — and a partial order is *drawable*, which the law list never was. |
| **T4** | Warrant completeness: are the elements with **no** warrant exactly the primitive generators? (P3 gives 27 warrants; OP-LOG's typing gives 31 generators / 27 dependents.) | If the partitions coincide, independence (C3) falls out for free instead of needing 58 proofs. |
| **T5** | Prove the non-monotone part is exactly the conjunctive-antecedent fragment (X19 the witness) and everything else is union-closed. | Quarantines non-monotonicity instead of letting it be pervasive. OP-CAT measured 4 of 44 conjuncts. |
| **T6** | **The scope dichotomy:** any algebra over on-chain mechanism sets satisfies `USDT ≡ USD1`; any algebra separating them contains a party sort; no middle position exists. | Formalises P6+P7 into one statement. The most consequential claim available: **mechanism inventory does not determine credit.** |
| **T7** | Is `El × Ast` the *minimal* enrichment expressing reflexivity? | P5 shows it suffices. Minimality is unproven. |
| **T8** | Does "definite-fragment lattice + outer filter" yield a decidable composability check with stated complexity? | The engineering payoff of P1/P2/P9. |

## CONTESTED — do not resolve silently

| # | Question | Positions |
|---|---|---|
| **K1** | **The minimal generating set.** | OP-CAT: 56, `St`/`Wg` collapse. GR-ORD: **zero** type-level redundancy over 83 protocols; only 4 ungrounded symbols (`Wg,Cv,Sb,Sd`). GR-LOG: 4 clause-redundant pairs (`{Sh,Ix},{Rf,Ba},{Im,Op},{Rd,Ps}`). OP-ORD: 10 reducible attributes, cut `Gs`. **Unresolved — these use different equivalences and must be compared on a common one.** |
| **K2** | Is there a single-valued closure operator over the full family? | OP-ORD constructs one via the Galois adjoint; GR-CAT proves the family is not Moore. Likely different families — needs stating precisely. |
| **K3** | Promote `X19` (`Xf → Aw`) to a positive law? | GR-ORD yes (restores union-closure). GR-CAT no — flags 14 of 72 live protocols. GP-ORD declines on cost. |
| **K4** | **Is `⊕` a congruence?** GP-CAT *proves* it; OP-LOG *refutes* it with witnesses on all four closures. | Almost certainly two different statements, and the distinction matters more than either result. BRIEF §2 defines `≃` by quantifying over **all** contexts, which makes `≃`-congruence true by construction — GP-CAT derives exactly that from `⊕` being total plus associativity. OP-LOG's refutation is about **validity**: `⊨a` and `⊨b` do not give `⊨(a ⊕ b)`. So observational equivalence is preserved by composition and *admissibility is not*. **Resolve by stating both separately in T2, and never write "congruence" unqualified again.** |

---

## Provenance note

Two entrants disclosed things that cost them score, and both disclosures were
correct and load-bearing: OP-ORD reported the blind-set leak unprompted and gave
its uncalibrated 6.88× beside its calibrated 10.83×; OP-LOG declined a cheap
67.7% rejection rate because it was "a lookup table with no sentence attached to
any clause." GR-CAT withdrew all four of its own hazard promotions after testing
them. Record this — it is why P12, P13 and R1 are trustworthy.
