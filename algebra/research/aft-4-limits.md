# Lane 4 — AFT: where it breaks, and what has happened to it (2018–2026)

Retrieval note: this session's WebSearch budget was already exhausted before I started, so
everything below comes from structured queries against the **arXiv API** and **DBLP**, plus
full-text retrieval of arXiv HTML (which carries LaTeX in MathML `alttext`, so notation
survives intact) and `pdftotext` for PDF-only sources. Where extraction mangled a formula
I say so rather than paraphrasing. No formula below is reconstructed.

---

## 0. The decision, answered first

> *Can we define `A(x,y)` from a closure operator `Γ` and a kernel operator `Δ` that is
> `≤_p`-monotone?*

**Yes, and the existence question is not even close.** Non-monotonicity of your validity
predicate is the *premise* of AFT, not an obstacle to it. Three independent results:

**(a) `Appx(O)` is never empty, for any operator whatsoever.** Denecker, Marek &
Truszczyński give the trivial witness verbatim (arXiv cs/0205014, §4):

> "Let us note that the set `Appx(O)` is not empty. Indeed, let us define
> `A_O(x, y) = (O(x), O(x))`, if `x = y`, and `A_O(x, y) = (⊥, ⊤)`, otherwise. It is easy
> to see that `A_O ∈ Appx(O)` and that it is the least precise element in `Appx(O)`."

No hypothesis on `O`. Not monotone, not continuous, not anything.

**(b) There is always a *best* one.** Same paper:

> "we observe that `Appx(O)` with the ordering `≤_p` is a complete lattice, as the set
> `Appx(O)` is closed under the operations of taking greatest lower bounds and least upper
> bounds. It follows that `Appx(O)` has a greatest element (most precise approximation). We
> call this partial approximation the ultimate approximation of `O` and denote it by `U_O`."

**(c) It has a closed form.** DMT **Theorem 4.5**, verbatim:

> "Let `O` be an operator on a complete lattice `L`. Then, for every `(x, y) ∈ L^c`,
> `U_O(x, y) = (glb(O([x, y])), lub(O([x, y])))`."

with `O([x,y]) = {O(z) : z ∈ [x,y]}`. The proof shows directly that this operator is
`≤_p`-monotone and exact for arbitrary `O`.

So *"is AFT a false lead because our predicate is non-monotone"* has the answer **no, on
that ground specifically**. The live risks are entirely downstream: **precision**
(is `A` tight enough to say anything?) and **cost** (can you compute it?). Sections 4 and 6
are where the real case against lives.

---

## 1. The closure/kernel structure is already what an approximator *is*

This matters for target 5 and for the decision, so state it precisely.

`≤_p` on the bilattice is (Vanbesien/Bogaerts/Denecker 2025, §2, verbatim):

> `(x₁, x₂) ≤_p (y₁, y₂)` iff `x₁ ≤ y₁` and `y₂ ≤ x₂`

Unfolding "`A` is `≤_p`-monotone" against that definition: `A¹` must be **monotone in its
first argument and antitone in its second**; `A²` must be **antitone in its first and
monotone in its second**. An approximator is *definitionally* a coupled pair of
opposite-polarity operators. You are not fighting the framework by wanting `Γ` and `Δ` of
opposite polarity — that is the shape it asks for.

Three concrete construction recipes appear in the literature:

**Symmetry** — collapse the pair to one function. Kettmann/Heyninck/Strass 2025
(arXiv 2507.11961, §2, verbatim):

> "An approximator `𝒜` is symmetric iff for all `(x,y) ∈ V²`, we have
> `𝒜(x,y)₂ = 𝒜(y,x)₁`; thus symmetry allows to specify `𝒜` by giving only `𝒜(·,·)₁`."

Their Definition 4 in the paraconsistent sequel instantiates it literally as
`𝒯_P(L,U) := (𝒯_P(L,U)₁, 𝒯_P(U,L)₁)` — one function, argument-swapped. Heyninck/Arieli/
Bogaerts use the same device in the non-deterministic setting (Remark 6: `O` is symmetric if
`O^l(x,y) = O^u(y,x)`), and note "symmetric operators are exact."

**Monotone envelopes** — build `Γ` and `Δ` mechanically from your non-monotone `f`.
Rasheed & Garg 2026 (arXiv 2605.06803, §4, verbatim):

> `f^u(x) = sup_{y ≤ x} f(y)` … "the pointwise least (the best) monotone function
> over-approximating `f`"
> `f^ℓ(x) = inf_{y ≥ x} f(y)` … "the greatest (the best) monotone under-approximation of `f`"
> "These envelopes `f^ℓ, f^u` correspond to the lower/upper borders of AFT's ultimate
> approximation."

That is your `Γ`/`Δ` pair, derived rather than guessed — and it is exactly `U_O` in
disguise. Note their example is a *game-theoretic best-response* operator (Nash equilibria),
not a logic program, which is useful evidence that the construction is not
logic-programming-specific.

**Stable revision runs the two independently and recombines.** Vanbesien et al. Definition 4,
verbatim:

> `St: ℬ^c → ℬ^c` maps `(x₁, x₂)` to `(lfp(A¹_{x₂}), lfp(A²_{x₁}))`, where `A¹_{x₂}(y₁)` is
> the projection of `A(y₁, x₂)` on its first component and `A²_{x₁}(y₂)` is the projection of
> `A(x₁, y₂)` on its second component.

Two least-fixpoint computations, each freezing the other's argument, then recombined. If you
were designing "two independent operators, one closure one kernel, iterated to mutual
fixpoint" from scratch, you would arrive at this.

**Honest gap on target 5:** I found *no paper* that takes two genuinely independent,
separately-specified operators of opposite polarity as primitives and builds AFT over them.
What exists is (i) the polarity-pair structure above, which is one operator viewed twice;
(ii) **stratification/splitting** — Bogaerts & Cruz-Filipe, *Stratification in AFT and Its
Application to Active Integrity Constraints*, ACM TOCL 22(1), 2021 (metadata only, see §8);
(iii) **algebraic conditional independence** — Heyninck & Bogaerts, arXiv 2412.13712 (2024),
which gives "a language-independent account of conditional independence" in AFT that "allows
to reduce global reasoning to parallel instances of local reasoning, leading to
fixed-parameter tractability results." (iii) is the closest thing to a two-independent-
operators calculus and is worth Lane 1's attention. I read only its abstract.

---

## 2. Non-deterministic AFT — the state of the art, and its scars

The line runs Pelov & Truszczyński (first idea) → Heyninck & Arieli (KR 2021) →
Heyninck, Arieli & Bogaerts (arXiv 2211.17262, 2022; **Artificial Intelligence** 338:104110,
2024) → Heyninck & Bogaerts (arXiv 2305.10846; TPLP 2023) → Killen, You & Heyninck
(AAAI 2025).

**Definition 11** (ndao), verbatim from 2211.17262 — note PDF extraction rendered the lifted
order `⪯^A_i` as a bare `A i`, and I have written it back as `⪯^A_i` only because the paper's
Table 2 defines that symbol unambiguously; the surrounding text is verbatim:

> "Let `L = ⟨L, ≤⟩` be a lattice. An operator `O : L² → ℘(L)\∅ × ℘(L)\∅` is called a
> nondeterministic approximating operator (ndao, for short), if satisfies the following
> properties: • `O` is `⪯^A_i`-monotonic. • `O` is exact, i.e., for every `x ∈ L`,
> `O(x, x) = O^l(x, x) × O^l(x, x)`."

So **ndAFT does not drop monotonicity** — it lifts the precision order to sets (Smyth `⪯^S_L`
and Hoare `⪯^H_L` orders) and demands monotonicity there. If you were hoping non-determinism
was the escape hatch from `≤_p`-monotonicity: it is not.

What ndAFT *costs*, all verbatim from the same paper:

- **Building minimality into the operator breaks monotonicity.** Remark 7 gives the
  counterexample `P = {a ∨ b ←; a ← c}` and concludes: *"Note that this is a counter-example
  to a wrong claim made in [37, Example 2]"* — i.e. the KR 2021 paper had this wrong and the
  journal version corrects it. The takeaway sentence: *"this example shows that requiring
  minimality in the non-deterministic approximation operator leads to undesirable behavior."*
- **Least fixpoints stop existing.** *"in contradistinction to deterministic AFT, a
  `≤_i`-minimal fixpoint of an ndao is neither guaranteed to be unique nor guaranteed to
  exist."*
- **Consistent fixpoints stop existing.** Example 12 exhibits an operator that *"is
  `⪯^A_i`-monotonic, yet it admits no consistent fixpoint."*
- The recovery is *state semantics* (pairs of *sets*), for which existence and uniqueness are
  restored (Theorems 3, 5). But you have left the interval world to get it.
- Killen, You & Heyninck, *An Alternative Theory of Stable Revision for Nondeterministic
  Approximation Fixpoint Theory and the Relationships*, AAAI 39(14), 2025 — the title alone
  says the ndAFT stable revision was not settled. **Metadata only; see §8.**

---

## 3. Recent AFT work, 2018–2026 (from DBLP + arXiv, 33 + 20 hits deduplicated)

| Year | Work | Relevance |
|---|---|---|
| 2018 | Charalambidis, Rondogiannis, Symeonidou — AFT & WFS of higher-order LPs (TPLP; arXiv 1804.08335) | first higher-order lift |
| 2019 | Bogaerts — Weighted ADFs through the lens of AFT (AAAI) | the wADF restriction later criticised in 2025 |
| 2021 | Bogaerts & Cruz-Filipe — Stratification in AFT (ACM TOCL 22(1)) | splitting |
| 2021 | Heyninck & Arieli — AFT for non-deterministic operators (KR) | superseded/corrected by 2024 AIJ |
| 2021/22 | Vanbesien, Bruynooghe, Denecker — aggregate ASP via AFT (TPLP; arXiv 2104.14789) | instance |
| 2021/24 | Marynissen, Bogaerts, Denecker — justification theory ↔ AFT (IJCAI 2021; **AIJ** 338:104112, 2024) | rival framework, embedded *into* AFT |
| 2023 | Heyninck & Bogaerts — ultimate nd operators, semi-equilibrium, aggregates (TPLP; arXiv 2305.10846) | ultimate ops in ndAFT |
| 2023 | Charalambidis & Rondogiannis — Categorical AFT (JELIA) | categorical reformulation |
| 2023 | Killen & You — Eliminating unintended stable fixpoints (arXiv 2307.11286) | criticism, see §4 |
| 2024 | **Heyninck, Arieli, Bogaerts — nd-AFT & disjunctive LP (AIJ 338:104110)** | the ndAFT reference |
| 2024 | Bogaerts & Cruz-Filipe — **AFT in Coq** (LNCS 14560) | mechanised |
| 2024 | Pollaci, Kostopoulos, Denecker, Bogaerts — Category-theoretic higher-order AFT (LPNMR; arXiv 2408.11712; TPLP under consideration) | categorical, see §4 |
| 2025 | Pollaci — A Category-Theoretic Perspective on AFT (ICLP, arXiv 2502.09234) | *"lifting of AFT into a more general framework for constructive knowledge"* |
| 2025 | Killen, You, Heyninck — Alternative stable revision for ndAFT (AAAI 39(14)) | ndAFT unsettled |
| 2025 | **Vanbesien, Bogaerts, Denecker — AFT with Refined Approximation Spaces (arXiv 2506.16294)** | the sharpest self-criticism, §4 |
| 2025 | Kettmann, Heyninck, Strass — AFT as unifying framework for fuzzy LP (IJCAI 2025; arXiv 2507.11961) | many-valued/weighted |
| 2025 | Killen & You — Eliminating unintended stable fixpoints in AFT (NMR 2025, CEUR Vol-4071) | criticism, §4 |
| 2026 | Kettmann, Strass, Heyninck, Spaans — Paraconsistent semantics for extended fuzzy LPs (arXiv 2605.05286) | consistency, §5 |
| 2026 | **Rasheed & Garg — Bounding Fixed Points of Non-Monotone Processes (arXiv 2605.06803, cs.PL)** | the practitioner's indictment, §4 |

Names you asked about that did **not** show up: **Vennekens** has nothing AFT-titled after the
2012 Denecker/Bruynooghe/Vennekens survey chapter. **Antić** has nothing AFT-titled after
Antić/Eiter/Fink, *Hex Semantics via AFT*, LPNMR 2013. **Eiter** likewise. Treat "Antić and
Eiter are active in AFT" as **not supported** by DBLP as of this search.

The centre of gravity 2022–2026 is Bogaerts + Heyninck + Denecker (Brussels/Leuven/Hagen),
with a distinct Alberta strand (Killen & You) that is consistently the most critical.

---

## 4. Where AFT has been shown inadequate

### 4.1 Intervals are too coarse — and the founders say so

This is the strongest source, because it is Denecker himself. Vanbesien, Bogaerts & Denecker,
arXiv 2506.16294 (2025), abstract, verbatim:

> "While AFT has been applied successfully across a broad range of non-monotonic reasoning
> formalisms, **it is confronted by its limitations in other, relatively simple, examples.**"

Two named failures:

**Example 1 (autoepistemic).** The theory `𝒯 = { q ⇔ ¬Kp. , r ⇔ ¬Kq. }`. The intended belief
state is: nothing known about `p`, and `q`, `¬r` known. AFT gets nothing. Verbatim:

> "It is easy to verify that the ultimate approximator in interval-AFT for this operator
> derives as fixpoints `KK(U) = WF(U) = (⊥, ⊤)`."

i.e. **the most precise approximator that exists returns the least precise possible answer.**
The diagnosis is worth quoting because it is the general failure mode, not an artefact:

> "The problem is that among those there are incompatible pairs of belief states, i.e., their
> intersection is empty… The only approximant that approximates all these belief states is
> `(⊥, ⊤)`. In other words, intervals are not sufficiently precise to represent the upper
> bound we had in our mind, therefore we lose all the acquired information."

They also record that earlier authors concluded *"AFT is not strong enough for some
auto-epistemic theories"* and went outside AFT (well-founded sets) to fix it.

**Example 2 (weighted ADFs).** Verbatim:

> "Due to the fact that AFT uses intervals as approximations, [Bogaerts 2019] had to pose
> restrictions on the acceptance order… **interval-AFT requires the exact space to be a
> complete lattice, whereas not every problem naturally satisfies this constraint.**"

With acceptance values `{accept, borderline, reject, tendency accept, tendency reject,
indifferent}` there is no greatest element, so *"AFT is not able to correctly represent the
least precise approximation."*

Their fix (**flowers** = closed convex sets containing their own glb, ordered by reverse
inclusion) is a genuine generalisation, but it imports a new problem, verbatim:

> "Whereas, given a problem in an exact space, the approximation space used to be a fixed
> entity derivable from the exact space, now an exact space may lead to multiple suitable
> approximation spaces. This brings up the question of how to select an appropriate
> approximation space."

and: *"more precise approximation spaces in general introduce higher computational
complexity."*

**Direct read-across to you:** if your "validity" carries mutually incompatible witnesses
whose only common interval bound is `(⊥,⊤)`, interval-AFT will hand you a vacuous answer with
a straight face. Test this on a small instance *before* committing. This is the single
cheapest falsification experiment available.

### 4.2 The ultimate approximation can be vacuous

Rasheed & Garg 2026 (arXiv 2605.06803), Related Work, verbatim:

> "In [Denecker et al. 2004], the notion of an 'ultimate approximation' is introduced as a
> necessarily existing unique and most precise (partial) approximation. **Despite being the
> best approximation, it may still a coarse one (possibly even spanning the entire lattice.)**"

and from the abstract:

> "In practice, however, **even the best approximations obtained through AFT can be coarse and
> computationally expensive.**"

Their remedy is telling: they *"carefully introduce controlled unsoundness"* to tighten
beyond `U_O`. A 2026 PL paper concluding that the right move is to deliberately break
soundness is the most damning practical verdict in this file. They also flag that the
envelopes are *"computationally infeasible"* at face value — `sup`/`inf` over a large
subset, *"just as expensive to compute as a brute force search"* — and are only saved when
closed forms exist.

### 4.3 Precision is bought with a complexity level

DMT quantify it for logic programming (arXiv cs/0205014, §5), verbatim:

- ultimate stable model existence is **`Σ^P_2`-complete** (standard stable: NP-complete);
- computing the ultimate well-founded and ultimate Kripke-Kleene fixpoints is in **`Δ^P_2`**
  (standard WFS: polynomial). The jump traces to *"The problem to decide whether a DNF formula
  is a tautology is co-NP-complete."*

They concede: *"These results might put in doubt the usefulness of ultimate semantics."* The
rescue is a syntactic class `E_k` (bounded clauses per head, or ≤2-element bodies, or ≤1
positive literal, or ≤1 negative literal per body) where it falls back to NP-complete /
polynomial. **Ask early whether your validity predicate lands in an `E_k`-like class.** If it
does not, you are paying a polynomial-hierarchy level for precision you may not need.

### 4.4 Stable revision structurally forgets falsity

Killen & You, NMR 2025 (CEUR Vol-4071 paper15), verbatim:

> "Using traditional AFT theory, **it is difficult to derive falsity from falsity.** However,
> this type of reasoning is essential for systems that incorporate classical negation into
> nonmonotonic reasoning."

> "The approximator embedded in the stable operator does not have access to the atoms that
> were false when the stable operator was invoked… As a result, stable revision applied to
> such semantics **will have additional unintended stable fixpoints.**"

> "in each iteration, the underlying approximator 'forgets' which atoms it assigned false.
> Thus, from the approximator's perspective, any atom may become true."

Their example: `{← a; a ← not b; b ← not a}` has the single answer set `({b},{b})`, but
`(∅,{a,b})` survives as an unintended stable fixpoint, and adding one level of indirection
(`← c; c ← a`) defeats the obvious patch. If your validity predicate ever needs to propagate
*invalidity forward* — an object is invalid *because* its dependency is invalid — this is
your bug report, pre-written.

Their fix is the architecturally interesting part: *"our extension does not require a new
theory. We simply modify the underlying bilattice on which the approximators operate."*
**Changing the lattice, not the theory, is the recurring escape hatch** (see also §5).

### 4.5 Higher-order definitions

Pollaci, Kostopoulos, Denecker & Bogaerts, arXiv 2408.11712, abstract, verbatim:

> "Despite its success, **AFT is not readily applicable to higher-order definitions.**"

Their repair uses Cartesian closed categories to build higher-order approximation spaces
inductively. Charalambidis & Rondogiannis (JELIA 2023) and Pollaci (ICLP 2025) are the
parallel categorical reformulations; Pollaci's stated goal is *"the lifting of AFT into a more
general framework for constructive knowledge."* **I read abstracts only for all three** — the
categorical machinery is not verified here.

### 4.6 The approximator is a modelling choice, not a derived object

DMT's own original complaint (arXiv cs/0205014, §1), verbatim:

> "when defining semantics of nonmonotonic formalisms, we select an approximation operator,
> rather then derive it in a principled way. The approximations used… are not algebraically
> determined by their corresponding lattice operators… Consequently, **some programs or
> theories with the same basic operators have different Kripke-Kleene, well-founded or stable
> fixpoints associated with them.**"

This is the deepest structural criticism and it has never gone away — `U_O` resolves it in
principle but at the complexity cost of §4.3, and Vanbesien et al. 2025 *reintroduce* the same
arbitrariness one level up (which approximation *space*?). Whatever you build, **the semantics
you get is a property of your `A`, not of your `Γ`/`Δ`.** Two defensible approximators of the
same operator will disagree, and AFT will not adjudicate.

---

## 5. Consistency: modelling failure, or information?

**In consistent AFT, an approximator cannot produce an inconsistent pair.** Kettmann et al.,
arXiv 2507.11961 §2, verbatim: *"any approximator maps consistent pairs to consistent pairs,
and the stable approximator `𝒜^st` maps consistent post-fixpoints of `𝒜` to consistent pairs.
Consequently, not only is `lfp(𝒜)` consistent (and called the Kripke-Kleene fixpoint of `𝒜`),
but so is `lfp(𝒜^st)`."* If you work in `ℬ^c` (`{(x₁,x₂) : x₁ ≤ x₂}`), inconsistency is
excluded by construction and can carry no information at all.

**But the stable machinery does brush against inconsistency, and AFT patches over it rather
than reading it.** DMT, verbatim:

> "The notion of `A`-reliability is not strong enough to guarantee desirable properties of the
> stable revision operator. In particular, if `(a, b) ∈ L^c` is `A`-reliable, it is not true in
> general that `(b↓, a↑)` is consistent nor that `(a, b) ≤_p (b↓, a↑)`. There is, however, a
> class of `A`-reliable pairs for which both properties hold. An `A`-reliable approximation
> `(a, b)` is **`A`-prudent** if `a ≤ b↓`."

So: stable revision *can* leave `ℬ^c` — `(b↓, a↑)` need not satisfy `b↓ ≤ a↑` — and AFT's
response is to restrict the domain to `A`-prudent pairs until it cannot. The inconsistency is
treated as a domain error to be excluded, not a signal to be read. Vanbesien et al. carry the
same restriction forward ("we also require that the ALB of a flower is smaller than its AUB").

**How the literature actually handles "inconsistency is the interesting state": it moves
inconsistency into the exact lattice.** This is the important finding for you. Kettmann,
Strass, Heyninck & Spaans (arXiv 2605.05286, 2026) build paraconsistent semantics for fuzzy
LPs with both weak and strong negation. They do *not* use inconsistent AFT pairs. They make
the *interpretations themselves* pairs — `I(p) ∈ V²` recording positive and negative evidence
separately — and then run ordinary consistent AFT on top, over what they call a
**tetralattice** (verbatim):

> "our approximator will operate on the bilattice based on `(ℐ, ≤_t)`, which we denote by
> `(ℐ², ≦_p)` and refer to as the (precision) tetralattice. …
> `(L, U) ≦_p (M, T) :⟺ L ≤_t M and T ≤_t U`."

They are explicit that "consistent" in the AFT sense and "consistent" in the logical sense are
different words, and separate them by fiat. Rasheed & Garg do the same thing, verbatim:
*"A pair `(x, y) ∈ V²` is called **ordered** iff `x ≤ y`… Ordered pairs are called
'consistent' in the AFT literature. In this paper, we will use 'consistent' in a logical sense
and want to avoid confusion."*

**Recommendation for your model:** if "inconsistent" is a state you want to *observe and
reason about*, do not encode it as `x ≰ y` in the approximation. That reading is a modelling
failure — it means your approximator escaped its domain, and every AFT theorem you want
(Knaster-Tarski on `ℬ^c`, existence of `KK`, existence of `WF`) is stated over the consistent
subspace and stops applying. Instead **promote inconsistency into the exact lattice** — make
your truth values `V²` (evidence-for, evidence-against) à la Belnap, so that
"contradictory" is an ordinary lattice element with an ordinary approximation. This is what
both 2026 papers do, and Killen & You's "modify the bilattice, not the theory" is the same
move a third time. The pattern is robust enough to treat as the standard answer.

(Full, non-consistent AFT over all of `L²` does exist in the original DMT formulation, and
Vanbesien et al. flag that they deliberately restrict — *"Since we focus on consistent AFT,
which is in general more natural and provides sufficient expressiveness"*. I did **not**
retrieve a paper developing the inconsistent region as a carrier of information; the trend is
uniformly the other way.)

---

## 6. The case against AFT

Stated as strongly as the evidence supports — which is: **not strong enough to abandon it,
but strong enough to demand one cheap experiment before committing.**

1. **AFT guarantees you an answer, not a useful one.** `U_O` always exists (DMT Thm 4.5), and
   can be `(⊥, ⊤)`. Denecker's own 2025 paper shows a **two-line autoepistemic theory** where
   the ultimate approximator yields `KK(U) = WF(U) = (⊥, ⊤)` — total information loss on a toy
   input. Rasheed & Garg 2026 confirm from the PL side that the best approximation may span
   the entire lattice. The framework's totality is precisely what makes it non-falsifiable in
   advance: you cannot tell from "an approximator exists" whether you have a theory or a
   tautology. **This is the real risk, and it is not the risk you asked about.**

2. **Precision costs a level of the polynomial hierarchy.** Ultimate stable: `Σ^P_2`-complete
   vs NP. Ultimate WF/KK: `Δ^P_2` vs P. DMT themselves say this "might put in doubt the
   usefulness of ultimate semantics." Escape only via restricted syntactic classes.

3. **Intervals are the wrong shape whenever your upper bounds are genuinely plural.** The
   moment two incompatible candidates must both be covered, the interval collapses to `(⊥,⊤)`.
   Interval-AFT also *requires a complete lattice* — a real constraint that already forced
   restrictions on weighted ADFs, on a value order with several maximal elements. The 2025
   flower fix works, but replaces "which approximator?" with "which approximation *space*?",
   at higher complexity, with no selection principle offered.

4. **The theory cannot propagate falsity through falsity.** Stable revision forgets what it
   assigned false; unintended stable fixpoints follow; the obvious patch fails at one level of
   indirection (Killen & You 2025). Anyone whose predicate has *invalid-because-dependency-
   invalid* structure hits this immediately.

5. **The semantics is a property of your approximator, not of your operator.** DMT flagged in
   2002 that same-operator/different-approximator gives different KK, WF and stable fixpoints;
   `U_O` fixes it only at the cost of (2); Vanbesien et al. 2025 reintroduce the arbitrariness
   at the level of spaces. **AFT will not tell you whether your `A` is the right `A`.** You are
   doing the modelling; AFT is doing bookkeeping.

6. **Non-determinism does not relax monotonicity, it relocates it — and things break.** ndAFT
   demands `⪯^A_i`-monotonicity on lifted set orders. Building minimality in destroys it (with
   a published counterexample, and a published erratum against the KR 2021 paper). Least
   fixpoints stop being unique *or existent*; consistent fixpoints stop being guaranteed
   (Example 12). Stable revision for ndAFT was still being re-founded at AAAI 2025.

7. **Live areas are still moving.** Higher-order AFT is admittedly not ready ("not readily
   applicable"); three separate categorical reformulations landed 2023–2025 without one
   winning; ndAFT's stable revision was contested as of 2025. If you commit now, you commit to
   a framework whose foundations are being actively rewritten by the people who built it.

**What the case against does *not* establish.** It does not establish that non-monotone
validity is fatal. Every criticism above is about *precision, cost, shape of the approximation
space, or unsettledness* — none is about the operator failing to be monotone. On that
question the literature is unambiguous and in your favour, and the counter-evidence would have
to be an argument that no `Γ`/`Δ` pair tighter than `U_O` exists for your predicate *and* that
`U_O` is vacuous on it. **Both are cheaply testable.** The one-hour experiment: take the
smallest instance of your domain where you know the intended answer, compute
`U_O(x,y) = (glb(O([x,y])), lub(O([x,y])))` by brute force, and check whether `WF` is `(⊥,⊤)`.
If it is not vacuous there, AFT is not a false lead. If it is, you have Denecker's Example 1
and should look at flowers or at a richer exact lattice before abandoning the frame.

---

## 7. What this means for Lane 1 (two independent operators)

Approach from the extensions side, as asked. Findings, in descending confidence:

- An approximator **is** an opposite-polarity pair by definition of `≤_p`; a symmetric
  approximator lets you specify it with one function and an argument swap. **Verified
  verbatim, high confidence.**
- The `Γ`/`Δ` pair can be *derived* rather than chosen, via the monotone envelopes
  `f^u(x) = sup_{y≤x} f(y)` and `f^ℓ(x) = inf_{y≥x} f(y)`, which are exactly the borders of
  `U_O`. **Verified verbatim, high confidence.** Cost: generally infeasible to compute unless
  closed forms exist.
- Stable revision already treats the two components as independent least-fixpoint computations
  with the other argument frozen, then recombines. **Verified verbatim.**
- **No source found** for AFT built over two independently-given operators of opposite polarity
  as primitives. The nearest candidates are stratification (Bogaerts & Cruz-Filipe TOCL 2021)
  and algebraic conditional independence (Heyninck & Bogaerts, arXiv 2412.13712) — the latter
  explicitly *"reduce[s] global reasoning to parallel instances of local reasoning."* **Both
  abstract-only here.** Recommend Lane 1 read 2412.13712 in full.

---

## 8. What I could not retrieve or could not read cleanly

**Could not retrieve at all:**

- **WebSearch was unavailable for this entire task** — the session's 200-call budget was
  exhausted before my first query. All discovery ran through the arXiv API and DBLP. This is
  a real coverage gap for *criticism*: papers arguing against AFT that are not titled "AFT"
  would not surface in a title/abstract keyword search, and I could not do open-ended
  "critique of approximation fixpoint theory" searching. **Treat §4 as a lower bound on the
  case against.**
- **Killen, You & Heyninck, AAAI 39(14):15020ff, 2025** — *An Alternative Theory of Stable
  Revision for Nondeterministic AFT*. The AAAI OJS landing page returned a 4 KB stub with no
  discoverable PDF link and no arXiv preprint exists. **I have title and authors only.** Given
  it is the most recent word on whether ndAFT's stable revision is right, this is the most
  significant gap in this report.
- **Bogaerts & Cruz-Filipe, ACM TOCL 22(1), 2021** (stratification) — paywalled, no preprint
  found. Metadata only. Relevant to Lane 2.
- **Marynissen, Bogaerts & Denecker, AIJ 338:104112, 2024** (justification theory ↔ AFT) —
  Elsevier, not attempted (would have needed `stealthy-fetch --solve-cloudflare`; deprioritised
  against the 45-minute cap). Only the IJCAI 2021 title was seen.
- **Denecker, Bruynooghe & Vennekens 2012** survey chapter — Springer, not retrieved.
- **DMT 2000** (*Approximations, stable operators, well-founded fixpoints…*) — the founding
  paper. Not retrieved; I worked from the 2002 ultimate-approximation paper, which restates
  its definitions.
- **Pelov & Truszczyński** — the original non-deterministic-operator idea. Cited as [45]
  throughout Heyninck et al.; not retrieved.

**Retrieved but read only at abstract level** (so nothing in §3–§4 about them is verified
beyond the quoted abstract sentence): all three categorical papers (arXiv 2502.09234,
2408.11712, JELIA 2023); the conditional-independence paper (arXiv 2412.13712); the
aggregate-ASP papers; *AFT in Coq*.

**Notation that extraction damaged, and how I handled it:**

- `pdftotext` on the ndAFT paper (arXiv 2211.17262) **destroyed every super/subscripted
  lattice order.** `⪯^S_L`, `⪯^H_L` and `⪯^A_i` come out as bare, space-separated `S L`,
  `H L`, `A i` fragments, and Tables 1–3 lost all row structure. I recovered `⪯^A_i` only
  because the paper's own Table 2 pins the symbol; **I have not attempted to state the Smyth
  and Hoare order definitions**, because in the extracted text the quantifier direction of
  `⪯^S_L` versus `⪯^H_L` cannot be told apart from the column garbage with confidence. Lane 3
  or Lane 1 should read pages 4–5 of that PDF as an image if the exact lifted orders matter.
- Same paper, Remark 7: the chain of inequalities demonstrating non-monotonicity is broken
  across ~15 lines with the order symbols detached from their operands. I quoted the prose
  conclusion and the counterexample program `P = {a ∨ b ←; a ← c}`, both of which are
  unambiguous, and **did not reconstruct the inequality chain.**
- Theorem 2 of the same paper (`min_⊆` characterisation of supported models) came out with
  every character on its own line. The statement is legible but I did not quote it verbatim.
- The three arXiv-HTML sources (2506.16294, 2507.11961, 2605.05286) and 2605.06803 extracted
  **cleanly** — arXiv's HTML carries the original LaTeX in MathML `alttext`, so every formula
  quoted from those four is exact source LaTeX, not OCR. The DMT 2002 PDF extracted well
  enough that Theorem 4.5 and the `Appx(O)` argument are verbatim and trustworthy; its
  complexity section (§5) is heavily hyphenation-broken (`Σ P 2 - com plet e`) but the class
  names are unambiguous.
- I did not need to fall back to image rendering. Where PDF text was too damaged to trust, I
  declined to quote rather than rendering, given the time cap — flagged above at each point.

**Not investigated (out of lane / out of time):** whether flowers or refined approximation
spaces have a Coq/Lean mechanisation; complexity of flower-AFT beyond the authors' remark that
it is higher; whether ndAFT state semantics could serve a plural-validity model.
