# AFT-2: Splitting / Stratifiability — primary-source verification

**Primary source retrieved and read in full.**

Joost Vennekens, David Gilis, Marc Denecker, *Splitting an operator: Algebraic modularity
results for logics with fixpoint semantics*. arXiv **cs/0405002v2** (cs.LO), 37 pp.,
typeset as the ACM TOCL author version ("ACM Transactions on Computational Logic, Vol. V,
No. N"). Published as ACM TOCL 7(4):765–797, 2006.

- PDF: `https://arxiv.org/pdf/cs/0405002v2`
- Local copy: `C:\Users\charl\AppData\Local\Temp\claude\C--Users-charl\71f0563d-35a5-4bc4-bfaa-d173c0767a3c\scratchpad\papers\splitting.pdf`
- Page images (200 dpi PNG): `...\scratchpad\papers\img\`

**Method note.** All formulas below were read from **200 dpi page renderings** (poppler
`pdftoppm` via WSL), not from text extraction. `pdftotext` mangles every restriction bar and
subscript in this paper (`x|⪯i` extracts as `x| i`, and `O_i^{x|≺i}` loses its superscript
entirely). Every quoted formula was transcribed off the rendered image. Page numbers cited
are the paper's own page numbers, which coincide with the PDF page numbers.

**Numbering matches the request exactly.** Def 3.3 and Thm 3.5 in this arXiv v2 are the
stratifiability definition and the fixpoint iff, as stated in the brief.

---

## 1. The setup: index set, order, restriction, and what the lattice must be

From §3.1 "Product lattices" (p. 6) and §3.2 (p. 7).

> **Definition 3.1.** Let *I* be a set, which we will call the *index set* of the product
> set, and for each *i* ∈ *I*, let *S_i* be a set. The *product set* ⊗_{i∈I} S_i is the
> following set of functions:
>
> ⊗_{i∈I} S_i = { f | f : I → ⋃_{i∈I} S_i such that ∀i ∈ I : f(i) ∈ S_i }.

> **Definition 3.2.** Let *I* be a set and for each *i* ∈ *I*, let ⟨S_i, ≤_i⟩ be a partially
> ordered set. The *product order* ≤_⊗ on the set ⊗_{i∈I} S_i is defined by
> ∀x, y ∈ ⊗_{i∈I} S_i :
>
> x ≤_⊗ y   *iff*   ∀i ∈ I : x(i) ≤_i y(i).

Immediately after Def 3.2 (p. 6), the structural requirements:

> It can easily be shown that if all of the partially ordered sets *S_i* are (complete)
> lattices, the product set ⊗_{i∈I}S_i, together with its product order ≤_⊗, is also a
> (complete) lattice. We therefore refer to the pair ⟨⊗_{i∈I}S_i, ≤_⊗⟩ as the *product
> lattice* of lattices *S_i*.
>
> From now on, we will only consider product lattices with a *well-founded* index set, i.e.
> index sets *I* with a partial order ⪯ such that each non-empty subset of *I* has a
> ⪯-minimal element. This will allow us to use inductive arguments in dealing with elements
> of product lattices. **Most of our results, however, also hold for index sets with an
> arbitrary partial order; if a certain proof depends on the well-foundedness of *I*, we
> will always explicitly mention this.** (emphasis mine)

That last sentence matters for the hypothesis audit in §3 below.

**Answers to "what is the index set / what is ⪯ / what is x|⪯i".**

- **Index set** `I`: an arbitrary set carrying a **partial order** `⪯`, assumed
  **well-founded** by standing convention from §3.1 onward. `⪯` is a parameter of the
  splitting, *not* derived from the lattice. It is the "which stratum may see which"
  order — the abstract counterpart of a dependency/stratification order.
- **The lattice must be a product lattice** `L = ⊗_{i∈I} L_i` — i.e. it must already be
  presented as (or be isomorphic to) an indexed product of lattices. This is the real
  admissibility condition: *an operator can only be split if its lattice factors.* §3.4
  exists precisely because not every lattice does (see §5 below).
- **Restriction.** From p. 6, bottom:

  > For a function *f* : *A* → *B* and a subset *A'* of *A*, we denote by *f*|_{A'} the
  > restriction of *f* to *A'* [...]. For an element *x* of a product lattice ⊗_{i∈I}L_i
  > and an *i* ∈ *I*, we abbreviate x|_{ {j∈I | j⪯i} } by x|_⪯i. We also use similar
  > abbreviations x|_≺i, x|_i and x|_⋠i. If *i* is a minimal element of the well-founded
  > set *I*, x|_≺i is defined as the empty function.

  So `x|⪯i` is literally *x* restricted to the down-set of *i* **including** *i*; `x|≺i` is
  the **strict** down-set, excluding *i*. Both are used, and the distinction is
  load-bearing — Def 3.3 uses the non-strict `⪯i`, the component operators are indexed by
  the strict `≺i`.
- **Sublattices.** From p. 7, top:

  > For each index *i*, the set { x|_⪯i | x ∈ L }, ordered by the appropriate restriction
  > ≤_⊗|_⪯i of the product order, is also a lattice. Clearly, this sublattice of *L* is
  > isomorphic to the product lattice ⊗_{j⪯i}L_i. We denote this sublattice by L|_⪯i and
  > use a similar notation L|_≺i for ⊗_{j≺i}L_i.

- **Notational convention** (p. 7): `x, y` range over the whole product lattice `L`;
  `a, b` over a single level `L_i`; `u, v` over `L|≺i`.

---

## 2. The theorems, verbatim

### Definition 3.3 (p. 7) — CONFIRMED, matches the brief exactly

Preceded by the intuition (p. 7):

> Let ⟨I, ⪯⟩ be a well-founded index set and let L = ⊗_{i∈I}L_i be the product lattice of
> lattices ⟨L_i, ≤_i⟩_{i∈I}. Intuitively, an operator *O* on *L* is stratifiable over the
> order ⪯, if the value (O(x))(i) of O(x) in the *i*th stratum only depends on values x(j)
> for which j ⪯ i. This is formalized in the following definition.

> **Definition 3.3.** An operator *O* on a product lattice *L* is *stratifiable* iff
> ∀x, y ∈ L, ∀i ∈ I : if x|_⪯i = y|_⪯i then O(x)|_⪯i = O(y)|_⪯i.

This is **verbatim identical** to the form in the brief:
`∀x,y, ∀i: x|⪯i = y|⪯i ⟹ O(x)|⪯i = O(y)|⪯i`. Confirmed.

### Proposition 3.4 (p. 7) — the constructive characterisation, also an iff

> It is also possible to characterize stratifiablity in a more constructive manner. The
> following theorem shows that stratifiablity of an operator *O* on a product lattice *L*
> is equivalent to the existence of a family of operators on each lattice *L_i* (one for
> each partial element *u* of L|_≺i), which mimics the behaviour of *O* on this lattice.

> **Proposition 3.4.** *Let O be an operator on a product lattice L. O is stratifiable iff
> for each i ∈ I and u ∈ L|_≺i there exists a unique operator O_i^u on L_i, such that for
> all x ∈ L:*
>
> *If x|_≺i = u then (O(x))(i) = O_i^u(x(i)).*

The proof (p. 7) defines `O_i^u : L_i → L_i : a ↦ (O(y))(i)` with *y* any element of *L*
extending `u ⊔ a`; stratifiability is exactly what makes this well-defined. The `O_i^u` are
named the **components** of *O*.

### Theorem 3.5 (p. 8) — CONFIRMED, and it IS a genuine iff

> **Theorem 3.5.** *Let O be a stratifiable operator on a product lattice L. Then for each
> x ∈ L:*
>
> *x is a fixpoint of O   iff   ∀i ∈ I : x(i) is a fixpoint of O_i^{x|_≺i}.*
>
> **Proof.** Follows immediately from proposition 3.4. ∎

**Yes — it is an iff, stated as `iff` in the theorem, and both directions are carried by
Prop 3.4, which is itself an iff.** Note the superscript is the **strict** restriction
`x|_≺i`, matching the brief.

**Hypotheses of Thm 3.5, exhaustively:**

1. `L` is a **product lattice** `⊗_{i∈I} L_i`.
2. `O` is an operator on `L` that is **stratifiable** (Def 3.3) w.r.t. `⪯`.
3. Nothing else. **No monotonicity. No continuity. No exactness. No completeness of the
   lattices.**
4. Well-foundedness of `⪯` is a standing convention of §3.1, but Thm 3.5's proof "follows
   immediately from proposition 3.4", and Prop 3.4's proof uses no induction over `⪯`. Per
   the authors' own convention quoted above ("if a certain proof depends on the
   well-foundedness of *I*, we will always explicitly mention this"), and since they *do*
   explicitly flag it for Prop 3.7 (p. 9), **Thm 3.5 does not depend on well-foundedness.**
   The results that *do* need it are the least-fixpoint ones.

This is a hypothesis-light theorem. That is the good news for us.

### Proposition 3.6, 3.7 (p. 8) — least fixpoints, and here monotonicity enters

> **Proposition 3.6.** *Let O be a stratifiable operator on a product lattice L, which is
> monotone w.r.t. the product order ≤_⊗. Then for each i ∈ I and u ∈ L|_≺i, the component
> O_i^u : L_i → L_i is monotone w.r.t. to the order ≤_i of the ith lattice L_i of L.*

> **Proposition 3.7.** *Let O be a monotone operator on a complete product lattice L and
> let for each i ∈ I, u ∈ L|_≺i, P_i^u be a monotone operator on L_i (not necessarily a
> component of O), such that:*
>
> *x is a fixpoint of O   iff   ∀i ∈ I : x(i) is a fixpoint of P_i^{x|_≺i}.*
>
> *Then the following equivalence also holds:*
>
> *x is the least fixpoint of O   iff   ∀i ∈ I : x(i) is the least fixpoint of P_i^{x|_≺i}.*

Summarised on p. 9:

> Together with theorem 3.5 and proposition 3.6, this proposition of course implies that for
> each stratifiable operator *O* on a product lattice *L*, an element x ∈ L is the least
> fixpoint of *O* iff ∀i ∈ I, x(i) is the least fixpoint of O_i^{x|_≺i}. In other words, the
> least fixpoint of a stratifiable operator can also be incrementally constructed.

### Theorem 3.11 and Corollary 3.12 (p. 11) — stable and well-founded

> **Theorem 3.11.** *Let L be a product lattice and let A : L² → L² be a stratifiable
> approximation. Then for each element (x, y) of L²:*
>
> *(x, y) is a fixpoint of C_A   iff   ∀i ∈ I : (x, y)(i) is a fixpoint of C_{A_i^{(x,y)|_≺i}}.*

> **Corollary 3.12.** *Let L be a product lattice and let A : L² → L² be a stratifiable
> approximation. Then for each element (x, y) of L²:*
>
> *(x, y) = lfp(C_A)   iff   ∀i ∈ I : (x, y)(i) = lfp(C_{A_i^{(x,y)|_≺i}}).*

`C_A` is the **partial stable operator**; its fixpoints are the stable fixpoints and its
least fixpoint is the well-founded fixpoint (definitions recalled on p. 6).

---

## 3. Which semantics are covered — ALL FOUR, and this is stated explicitly

This is the decisive paragraph, p. 11, immediately after Cor 3.12. Quoted verbatim:

> Putting all of this together, the main results of this section can be summarized as
> follows. If *A* is a stratifiable approximation on a product lattice *L*, then a pair
> (x, y) is a fixpoint, Kripke-Kleene fixpoint, stable fixpoint or well-founded fixpoint of
> *A* iff for each i ∈ I, (x(i), y(i)) is a fixpoint, Kripke-Kleene fixpoint, stable fixpoint
> or well-founded fixpoint of the component A_i^{(x,y)|_≺i} of *A*. Moreover, if *A* is exact
> then an element x ∈ L is a fixpoint of the unique operator *O* approximated by *A* iff for
> each i ∈ I, (x(i), x(i)) is a fixpoint of the component A_i^{(x,x)|_≺i} of *A*. These
> characterizations give us a way of incrementally constructing each of these fixpoints.

**So: splitting is NOT limited to immediate-consequence fixpoints.** The modularity results
cover, as *iff*s:

| Semantics | Result | Extra hypotheses beyond stratifiability |
|---|---|---|
| Fixpoints of `O` (supported models) | Thm 3.5 | none |
| Least fixpoint of `O` | Prop 3.6 + 3.7 | `O` monotone, `L` complete, `⪯` well-founded |
| Kripke-Kleene (`lfp` of `A`) | via Prop 3.7 applied to `A` | `A` an approximation (hence monotone in ≤_p), `⪯` well-founded |
| **Stable fixpoints** (fixpoints of `C_A`) | **Thm 3.11** | `A` a stratifiable approximation |
| **Well-founded fixpoint** (`lfp(C_A)`) | **Cor 3.12** | as Thm 3.11, plus Prop 3.7's well-foundedness of `⪯` |

Confirmed again in the logic-programming instantiation (p. 17, after Thm 4.5):

> By theorem 3.11, this theorem implies that, for a stratifiable program *P*, it is possible
> to stratify the operators T_P, 𝒯_P and 𝒢ℒ. In other words, it is possible to split logic
> programs w.r.t. the supported model, Kripke-Kleene, stable model and well-founded
> semantics.

And the paper's own positioning against Lifschitz & Turner (p. 20):

> In another respect, our results are more general than those of Lifschitz and Turner. When
> considering only programs in the syntax described here, our results generalize their
> results to include the supported model, Kripke-Kleene and well-founded semantics as well.

### One trap worth flagging (p. 11, just before Thm 3.11)

The components of the stable operator are **not** the stable operators of the components:

> It should be noted that the components (C_A)_i^{(u,v)} of the partial stable operator of a
> stratifiable approximation *A* are (in general) **not equal** to the partial stable
> operators C_{A_i^{(u,v)}} of the components of *A*. Indeed,
> (C_A)_i^{(u,v)} = ((C_A^↓)_i^v, (C_A^↑)_i^u), whereas
> C_{A_i^{(u,v)}} = (C^↓_{A_i^{(u,v)}}, C^↑_{A_i^{(u,v)}}). Clearly, these two pairs are, in
> general, not equal, as (C_A^↓)_i^v ignores the argument *u*, which does appear in
> C^↓_{A_i^{(u,v)}}.

Thm 3.11 is stated in terms of `C_{A_i^{(x,y)|≺i}}` — the stable operator *of* the component
— so the theorem is fine, but any implementation that assumes the two coincide is wrong.

---

## 4. Worked examples in the paper

### 4.1 The logic-programming instantiation (§4.1, pp. 16–18)

> **Definition 4.3.** Let *P* be a logic program with alphabet Σ. The *dependency order*
> ≤_dep on Σ is defined as: for all p, q ∈ Σ:
>
> p ≤_dep q  *iff*  ∃r ∈ P : q = head(r), p ∈ body(r).

Worked example (p. 17), with the dependency graph drawn in the paper:

> E = { p ← ¬q, ¬r.  ;  q ← ¬p, ¬r.  ;  s ← p, q. }
>
> In other words, r ≤_dep p, r ≤_dep q, p ≤_dep q, q ≤_dep p, s ≤_dep p and s ≤_dep q.

> **Definition 4.4.** Let *P* be a logic program with alphabet Σ. A *splitting* of *P* is a
> partition (Σ_i)_{i∈I} of Σ, such that the well-founded order ⪯ on *I* agrees with the
> dependency order ≤_dep of *P*, i.e. if p ≤_dep q, p ∈ Σ_i and q ∈ Σ_j, then i ⪯ j.

> For instance, the following partition is a splitting of the program *E*: Σ_0 = {r},
> Σ_1 = {p, q} and Σ_2 = {s} (with the index set *I* being the totally ordered set {0,1,2}).

> **Theorem 4.5.** *Let P be a logic program and let (Σ_i)_{i∈I} be a splitting of this
> program. Then the operator 𝒯_P on the bilattice of the product lattice ⊗_{i∈I} 2^{Σ_i} is
> stratifiable.*

Note `p` and `q` depend on each other (`p ≤_dep q` and `q ≤_dep p`), which forces them into
the *same* stratum. That is the mutual-recursion obstruction, and it is what makes the
strata SCC-like — see §6 below.

### 4.2 The failure example the paper actually gives (p. 9)

**Important: this is a counterexample to Prop 3.7 under a non-well-founded index order, not
a counterexample to stratifiability.** Verbatim:

> It is worth noting that the condition that the order ⪯ on *I* should be well-founded is
> necessary for this proposition to hold. Indeed, consider for example the product lattice
> L = ⊗_{z∈ℤ}{0,1}, with ℤ the integers ordered by their usual, non-well-founded order. Let
> *O* be the operator mapping each x ∈ L to the element y : ℤ → {0,1} of *L*, which maps
> each z ∈ ℤ to 0 if x(z−1) = 0 and to 1 otherwize. This operator is stratifiable over the
> order ≤ of ℤ and its components are the family of operators O_z^u, with z ∈ ℤ and
> u ∈ L|_{≤z}, which are defined as mapping both 0 and 1 to 0 if u(z−1) = 0 and to 1
> otherwize. Clearly, the bottom element ⊥_L of *L*, which maps each z ∈ ℤ to 0, is the least
> fixpoint of *O*. However, the element x ∈ L which maps each z ∈ ℤ to 1 satisfies the
> condition that for each z ∈ ℤ, x(z) is the least fixpoint of P_z^{x|_{<z}}, but is clearly
> not the least fixpoint of *O*.

The moral: **stratifiability alone gives you Thm 3.5 (fixpoints), but the *least*-fixpoint
transfer additionally needs the stratification order to be well-founded.** An infinite
descending chain of strata breaks least-fixpoint modularity even when every local piece is
correct. If our composition graph can have infinite descending dependency chains (or is
being treated as such), this is a live failure mode.

### 4.3 What the paper does NOT contain

**There is no worked example of a non-stratifiable operator, and no witness showing what
breaks when Def 3.3 fails.** I searched the full extracted text for `Example`, and the paper
contains **no numbered examples at all**. Section 3 is definition/proposition/proof
throughout. The only failure witness in the whole paper is the ℤ counterexample above, which
is about well-foundedness, not stratifiability. If we want "here is a non-stratifiable
operator and here is the fixpoint it loses", we have to build it ourselves — the literature
does not hand it to us. (Our own two-protocol composition witness may in fact *be* that
example, which would be a contribution, not a lookup.)

---

## 5. The limits

**(a) The lattice must factor.** §3.4 (p. 11) opens:

> The theory developed in the previous sections allows us to incrementally construct
> fixpoints of operators on product lattices. However, not every operator is (isomorphic to)
> an operator on a (non-trivial) product lattice. For instance, as we will see in Section
> 4.2, the 𝒟_T-operator of auto-epistemic logic is not.

This is a genuine, named limitation with a real instance. The workaround is §3.4's
**k-mimicking** machinery:

> **Definition 3.16.** Let L̃ and L be lattices. If there exists a function *k* from L̃ to L,
> such that each non-empty set k⁻¹(x), with x ∈ L, has a central element and *k* is
> chain-continuous, then L̃ is *k-similar* to L. This is denoted by L̃ ⊵_k L.

> **Definition 3.17.** Let L̃ and L be lattices, Õ an operator on L̃ and O an operator on L.
> If there exists a function *k* from L̃ to L, such that k ∘ Õ = O ∘ k and O(L) ⊆ k(L̃), Õ
> *k-mimics* O. This is denoted by Õ ⊵_k O.

> **Proposition 3.18.** *Let L̃ and L be complete lattices, Õ an operator on L̃ and O an
> operator on L, such that L̃ ⊵_k L, Õ ⊵_k O and Õ is monotone. Then k(fp(Õ)) = fp(O).*

> **Proposition 3.19.** *Let ⟨L̃, ≤⟩ and ⟨L, ≤⟩ be complete lattices, such that L̃ ⊵_k L. Let
> Õ be a monotone operator on L̃ and O a monotone operator on L, such that Õ ⊵_k O. Then
> k(lfp(Õ)) = lfp(O).*

> **Proposition 3.20.** *Let L̃, L be complete lattices, such that L̃ ⊵_k L. Let k be the
> function from L̃² to L² which maps each pair (x̃, ỹ) to (k(x̃), k(ỹ)). Let Ã be an
> approximation on L̃² and A an approximation on L², such that Ã ⊵_k A. Then C_Ã ⊵_k C_A,
> C^↓_Ã ⊵_k C^↓_A and C^↑_Ã ⊵_k C^↑_A.*

**Note the hypothesis inflation.** Thm 3.5 needs no monotonicity; the mimicking route
(Props 3.18/3.19) **requires Õ monotone**, plus chain-continuity of *k* and existence of
central elements in every fibre `k⁻¹(x)`. Escaping the product-lattice requirement is not
free.

Prop 3.13/3.14 (p. 12) additionally show that the naive condition `k ∘ Õ = O ∘ k` alone gives
only `k(fp(Õ)) ⊆ fp(O)`, with two explicit two-and-three-element-lattice counterexamples for
why the reverse inclusion can fail (empty fibre; fibre containing no fixpoint because Õ
oscillates). These are the paper's only other concrete failure witnesses.

**(b) Decidability and cost of checking stratifiability: NOT ADDRESSED.** I searched the
full text for `decidab*`, `complexity`, `NP`, `polynomial`, `tractab*`. The only two hits are
(i) a rhetorical use of "complexity of a domain" in the introduction and (ii) a bibliography
entry, Niemelä & Rintanen 1994, *On the impact of stratification on the complexity of
nonmonotonic reasoning* — cited but never discussed in the body. **The paper offers no
decidability result and no complexity bound for checking Def 3.3.** At the abstract level
Def 3.3 is a universally quantified condition over all pairs `x, y ∈ L` and all `i ∈ I`, so
it is not finitely checkable in general; Prop 3.4 restates it as an existence-of-components
condition, which is equally infinitary. What *is* cheap is the **syntactic sufficient
condition** in the instantiations — Def 4.4 for logic programs is a graph condition on the
dependency order, checkable by inspecting rule heads and bodies. That is the practical
route: don't check Def 3.3, check a syntactic condition that implies it.

**(c) Disjunction.** Extending to disjunctive heads is flagged as open/future work (p. 19).

**(d) Propositional only.** Compared with Denecker & Ternovska 2004 (p. 20): "these results
are aimed at supporting syntactical transformations on a *predicate* level, whereas we have
considered propositional progams."

---

## 6. Is there a maximal / coarsest stratification?

**The paper contains no notion of a maximal, coarsest, finest or optimal stratification, and
no construction for one.** I searched the extracted text for `maximal`, `coarsest`, `finest`,
`largest`, `optimal`, `most refined`. The single hit for `maximal` is the definition of the
top element of a lattice (p. 4). Def 4.4 defines *a* splitting; the paper never asks which
splitting is best, never orders splittings, and never proves that a canonical one exists.

However — and this is the most important passage in the paper for our question — the authors
**explicitly address the tightest-stratification question and explain why it is not usable**.
From §4.1.3 "Related work", p. 20, verbatim:

> In order to further motivate and explain the well-founded model semantics, Przymusinski
> [1998] defined the *dynamic stratification* of a program. The level of an atom in this
> stratificiation is based on the number of iterations it takes the Gelfond-Lifschitz
> operator to determine the truth-value of this atom.¹ As such, this stratification precisely
> mimics the computation of the well-founded model and is, therefore, **the tightest possible
> stratification of a program under the well-founded semantics. However, as there exist no
> syntactic criteria which can be used to determine whether a certain stratification is the
> dynamic stratification of a program – in fact, the only way of deciding this is by actually
> constructing the well-founded model of the program – this concept cannot be used to perform
> the kind of static, upfront splitting which is our goal.**

> ¹ To be a bit more precise, *p* belongs to level Σ_i iff *i* is the minimal *j* for which
> 𝒢ℒ ↑ j = (I, J) and either p ∈ I or p ∉ J.

(Emphasis mine.) This is a direct, on-point negative result for the "give me the maximal safe
fragment" question: **the optimal stratification exists, is characterised, and is
semantically circular — computing it requires computing the very semantics that splitting was
supposed to compute cheaply.**

The one place where something like a canonical construction is *implicit* rather than stated:
in the logic-programming instantiation, `≤_dep` is a preorder (Def 4.3 allows `p ≤_dep q` and
`q ≤_dep p` simultaneously, as in the example program `E`), so the finest admissible splitting
under Def 4.4 is the **strongly-connected-component condensation of the dependency graph**.
That is standard folklore and computable in linear time — **but the paper never states it,
never names SCCs, and proves nothing about it.** Do not cite the paper for it.

---

## 7. Stratifiability vs. union-closure

**The literature surveyed here does not state a relationship, because it never mentions
union-closure at all.** I searched the full text for `union`, `closed under`, `closure`,
`join-clos`, `lub-clos`, `intersect`. Every hit is unrelated: four are about `k⁻¹(x)` being
closed under application of `Õ` in §3.4's mimicking machinery (pp. 12–14), and two are
incidental uses in the auto-epistemic section (pp. 24–25) about intersecting/unioning
interpretations. **There is no notion of union-closure, join-closure, or any closure property
of the fixpoint set anywhere in this paper.** So there is no citable statement of their
relationship to be had from this source.

That said, the paper does supply the material to settle the direction we care about, and the
answer confirms the computational witness.

### Stratifiability does NOT imply union-closure — and the paper's own example shows it

The paper's worked example (p. 17) is:

> E = { p ← ¬q, ¬r.  ;  q ← ¬p, ¬r.  ;  s ← p, q. }

and the paper explicitly certifies that this program **is** splittable (p. 17):

> For instance, the following partition is a splitting of the program *E*: Σ_0 = {r},
> Σ_1 = {p, q} and Σ_2 = {s} (with the index set *I* being the totally ordered set {0,1,2}).

By Thm 4.5, `𝒯_E` is therefore **stratifiable**. Now the stable models (this computation is
**mine**, not quoted from the paper — it is routine, but flag it as derived):

- `r` has no rule, so `r` is false throughout.
- Candidate `{p}`: reduct is `{ p ←. ; s ← p, q. }`, least model `{p}`. **Stable.**
- Candidate `{q}`: symmetric. **Stable.**
- Candidate `{p, q}`: reduct is `{ s ← p, q. }`, least model `∅ ≠ {p,q}`. **Not stable.**
  Indeed `𝒯_E({p,q}) = {s}`, so `{p,q}` is not even a supported model.

So `E` is stratifiable, has stable models `{p}` and `{q}`, and their union `{p,q}` is not a
stable model — not even a fixpoint. **Stratifiability is strictly weaker than union-closure
on the fixpoint set; it does not imply it.**

### Why this exactly explains the `Pl ∧ Of → Ct` witness

The clause that does the damage in `E` is `s ← p, q` — a **conjunctive body drawing on two
independent lower atoms**. That is structurally identical to the reported witness
`Pl ∧ Of → Ct`. And note where it sits: `s` is in `Σ_2`, the **top** stratum, and the clause
is perfectly well-stratified (both `p` and `q` are strictly below `s` in `≤_dep`). There is no
stratification defect. The union of two solutions activates a conjunction that neither
solution activated alone, and stratifiability says nothing whatsoever about that.

This is the structural reason the two properties come apart, and it is worth stating
precisely because it is easy to conflate them:

- **Stratifiability is a locality property of the *operator*** — a statement that
  `O(x)|⪯i` depends only on `x|⪯i` (Def 3.3). It quantifies over pairs `x, y` that already
  *agree* on a down-set. It constrains *information flow between strata*.
- **Union-closure is a lattice-closure property of the *solution set*** — a statement that
  `fp(O)` is closed under `⊔`. It quantifies over pairs of fixpoints that in general
  **disagree**, and asks about their join.

Def 3.3 has no content at all about the join of two disagreeing elements. There is no
mechanism by which it could imply union-closure, and `E` witnesses that it does not.

**The converse direction I did not establish and do not assert.** I have no witness of a
union-closed but non-stratifiable operator, and the paper offers none. Treat
stratifiability and union-closure as **incomparable-or-weaker, with only the
`stratifiable ⇏ union-closed` direction confirmed.** Do not write "strictly weaker" without
also settling the converse.

**Bottom line for the coordinator:** the computational finding "stratifiability ≠
union-closure" is **correct**, is reproducible on the canonical example from the primary
source, and is not a defect in our data. But it is *our* observation — the literature does not
state it, so it is not citable as such. What *is* citable is that `E` is a splittable program
(Vennekens et al., p. 17), from which the non-union-closure follows by a one-line stable-model
computation anyone can check.

---

## 8. Re-examination: does the "AFT gate came back no" actually close off Thm 3.5?

The reported computational result is that `Γ` and `Δ` are both monotone, so neither fills
AFT's antitone slot, and any approximator built from them collapses to a componentwise
product. **Taking that as given, it kills less than it appears to.** I am flagging this
plainly, as invited, because the paper's hypotheses are stratified in a way that matters here.

From §2.2 (p. 5), the approximation machinery is what needs the bilattice:

> Approximation theory is based on the study of operators on bilattices L² which are monotone
> w.r.t. the precision order ≤_p. Such operators are called *approximations*.

and

> Because the lower and upper partial stable operators C_A^↓ and C_A^↑ are anti-monotone, the
> partial stable operator C_A is monotone.

So the antitone structure is exactly what `C_A` is built out of. **If there is no genuine
approximator, then `C_A` does not exist, and Thm 3.11 / Cor 3.12 are unavailable.** That much
of the computational conclusion stands, and it costs us the stable and well-founded tier.

**But two results survive untouched, because they never mention approximations at all:**

1. **Theorem 3.5 needs no approximator, no bilattice, and no monotonicity.** Its hypotheses,
   in full, are: `L` is a product lattice, and `O` is stratifiable. That is the entire
   antecedent. It is a statement about `fp(O)` on the plain lattice `L`. A composed operator
   built from `Γ` and `Δ` on a product lattice is eligible for Thm 3.5 the moment it is
   stratifiable — the AFT gate is simply not in the way.
2. **Prop 3.6 + Prop 3.7 give least-fixpoint modularity, and their extra hypothesis is
   *monotonicity* — which is precisely what the computational side reports we *have*.**
   Prop 3.7's antecedent is "`O` a monotone operator on a complete product lattice"; Prop 3.6
   needs `O` stratifiable and monotone w.r.t. `≤_⊗`. Both operators being monotone is an
   *enabler* here, not a blocker. Per the summary on p. 9, this yields: `x = lfp(O)` iff
   `∀i, x(i) = lfp(O_i^{x|≺i})`.

**So the correct statement of what the AFT gate closed off is narrower than "splitting may not
be available to us at all".** It closed off the *stable and well-founded* tier, which is the
tier that requires a bilattice approximation. It did **not** close off the fixpoint tier
(Thm 3.5) or the least-fixpoint tier (Prop 3.6/3.7), both of which live entirely on `L`,
require no antitone slot, and — for the least-fixpoint tier — actively require the
monotonicity we are reported to have.

Whether that reopens anything depends on a question I cannot answer from the literature and
that belongs to the computational lane: **does our composed operator's meaningful semantics
live at its plain fixpoints / least fixpoint, or does it live at stable/well-founded
fixpoints?** If the protocols' validity notion is a least-fixpoint notion, the surviving tier
may be exactly the one we need, and the gate result is not fatal. If validity is genuinely a
stable-model notion, the gate stands and Thm 3.11/3.12 are out of reach.

I want to be careful not to overclaim: I am **not** saying splitting transfers. I am saying
the specific reason given for rejecting it (no antitone slot) is a reason that bites only
Thm 3.11 and Cor 3.12, and that Thm 3.5 and Prop 3.7 have disjoint, weaker hypotheses that the
reported findings do not violate. That is worth a second look before the framework is written
off.

---

## Does this answer our T2?

**Partly — and the part it answers, it answers cleanly. The part we most wanted, it closes
off rather than solves.**

What is genuinely settled by the primary source:

1. **Thm 3.5 is a real biconditional.** Verified verbatim off the page image. Both directions
   come from Prop 3.4, itself an iff. Confirmed.
2. **Def 3.3 is exactly as stated in the brief.** Confirmed character-for-character, including
   the non-strict `⪯i` on both sides.
3. **The modularity results cover stable and well-founded semantics, not just
   immediate-consequence fixpoints.** Thm 3.11 (stable) and Cor 3.12 (well-founded) are both
   iffs, and p. 11 states the four-semantics summary explicitly. This was the biggest open
   risk in the brief and it resolves in our favour.
4. **Thm 3.5's hypotheses are light** — product lattice + stratifiability, no monotonicity,
   no continuity, and (by the authors' stated convention) not even well-foundedness of `⪯`.
   Well-foundedness is only needed once you want *least* fixpoints (Prop 3.7, Cor 3.12), and
   the paper gives an explicit ℤ-indexed counterexample showing it is necessary there.

What is **not** settled, and where I must not overclaim:

5. **"Composition-preserves-validity ⟺ stratifiability" is our conjecture, not the paper's
   theorem.** The paper proves an iff between *fixpoints of `O`* and *fixpoints of the
   components*, given stratifiability. It does **not** prove that stratifiability is
   necessary for any modularity property — it is a sufficient condition throughout. Thm 3.5's
   "iff" is *inside* the scope of the hypothesis "let `O` be a stratifiable operator"; it is
   **not** an iff between stratifiability and fixpoint-decomposability. Reading it as the
   latter would be a quantifier error, and it is the single most likely way for this lane to
   mislead the programme. Prop 3.4 *is* an iff with stratifiability on one side, but its other
   side is "the components exist and are unique", which is a restatement, not an independent
   modularity property.
6. **The decisive question — construction or check?** The answer is **only a check, no
   construction.** Def 4.4 is a *verification* condition on a partition you already have.
   Def 3.3 is a *verification* condition on an order you already have. The paper never
   constructs a stratification, never orders stratifications by coarseness, and never proves
   existence of a best one. Moreover, it *explains why* the tightest one is out of reach
   statically (the Przymusinski dynamic-stratification passage, p. 20): the optimal
   stratification is definable but computing it means computing the well-founded model
   first. So "find the largest fragment on which composition is safe" is **not** solved by
   citation. It is at best reduced to "find the coarsest partition respecting a dependency
   relation", which in the logic-programming instance is SCC condensation — cheap, but a
   folklore step the paper does not take, and only valid once you have a syntactic dependency
   relation that soundly over-approximates semantic dependence.
7. **No decidability or complexity result for stratifiability anywhere in the paper.** The
   practical discipline is: never test Def 3.3 directly (it quantifies over the whole
   lattice); define a syntactic dependency relation for our protocol composition language,
   prove the Def-4.4-analogue implies Def 3.3 (a Thm-4.5-analogue), and then check the graph.
   That proof obligation is ours.
8. **No non-stratifiable worked example exists in the paper.** Our measured
   composition-breaks-validity witness has no counterpart in this literature. If it is a
   stratifiability failure, we would be supplying the missing example rather than reusing one.

9. **Stratifiability ≠ union-closure is confirmed, but is not a citable fact.** The
   literature never mentions union-closure. The paper's own splittable example `E` (p. 17)
   is stratifiable with stable models `{p}`, `{q}` whose union is not a fixpoint, so the
   computational witness is correct and canonical. The `s ← p, q` clause in `E` has exactly
   the shape of our `Pl ∧ Of → Ct`. See §7. Only the `stratifiable ⇏ union-closed` direction
   is established; the converse is open and must not be asserted.
10. **The AFT gate closes off less than reported.** The absence of an antitone slot blocks
    the bilattice approximation, hence `C_A`, hence Thm 3.11 and Cor 3.12 — the stable and
    well-founded tier. It does **not** touch Thm 3.5 (no monotonicity, no approximator, no
    bilattice) or Prop 3.6/3.7 (which *require* the monotonicity we reportedly have). See
    §8. Before writing the framework off, the computational lane should settle whether our
    validity notion is a least-fixpoint notion or a stable-model notion.

**Net for the programme.** This converts one sub-problem into a citation (splitting is sound
for stable and well-founded semantics, as an iff, under light hypotheses — Vennekens, Gilis &
Denecker, TOCL 2006, Thm 3.5 / Thm 3.11 / Cor 3.12). It does **not** convert the open problem
"construct the largest safe fragment" into a solved one. On the contrary, the paper contains
the strongest available evidence that the *tightest* such fragment is not statically
constructible. Our realistic target is therefore the SCC-condensation-style coarsest split
w.r.t. a syntactic dependency relation we define and prove sound — a construction we build,
citing this paper only for the transfer theorems it licenses.

---

## What I could not retrieve

- **The published ACM TOCL 7(4):765–797 (2006) version.** I read the arXiv v2 author
  manuscript, which is typeset in the ACM TOCL style with the placeholder header "Vol. V,
  No. N". Its internal numbering matches the brief exactly (Def 3.3, Thm 3.5), so I am
  confident it is the same numbering as the published paper, but I did **not** verify against
  the ACM Digital Library copy. Journal page numbers for individual results are therefore not
  confirmed. I did not attempt an ACM DL fetch: per the recorded site pattern, the correct
  first step is an Unpaywall check rather than a stealth fetch, and the arXiv version was
  already in hand and complete.
- **Lifschitz & Turner, *Splitting a logic program* (ICLP 1994).** Not retrieved. I report it
  only as characterised *by* Vennekens et al. (pp. 19–20): it proves splitting for logic
  programs **under the stable model semantics only**, extends to disjunctive heads and two
  negations (which Vennekens et al. do not cover), and is generalised by Vennekens et al. to
  supported/Kripke-Kleene/well-founded for the non-disjunctive syntax. I have **not** read
  L&T's splitting-set theorem statement first-hand and do not quote it.
- **Later AFT work extending splitting.** I queried the arXiv API for
  `au:Bogaerts AND all:"approximation fixpoint theory"` (8 hits) and
  `all:"approximation fixpoint theory" AND all:modularity` (**0 hits**). None of the Bogaerts
  or Denecker AFT papers on arXiv is a splitting/modularity paper — the hits are refined
  approximation spaces (2506.16294), category-theoretic higher-order AFT (2408.11712),
  non-deterministic AFT (2211.17262, 2305.10846), knowledge compilation (1507.06554),
  distributed autoepistemic logic (2306.02774), SHACL (2109.08285), higher-order LP
  (2408.10563). **I therefore could not confirm or rule out a later paper that supplies the
  maximal-stratification construction.** My search was arXiv-only: the session's WebSearch
  budget (200/200) was exhausted before my first query, so I had no general web search. A
  targeted follow-up through Google Scholar or the KU Leuven DTAI publication pages
  (Vennekens, Denecker, Bogaerts) is the obvious next step and is **not** covered by this
  report.
- **Any source relating stratifiability to union-closure.** Not found, and I could not search
  for one properly: the paper itself is silent (verified by full-text search, §7), and with
  the WebSearch budget exhausted I had no way to survey the wider literature — e.g. Dix's
  classification of LP semantics properties, or the model-theoretic literature on
  closure-under-union of answer sets, either of which might state the relationship
  explicitly. **The §7 conclusion is my own derivation from the paper's example `E`, not a
  retrieved citation.** Treat it as sound but uncited until someone runs the literature
  search.
- **Przymusinski 1998 (dynamic stratification).** Not retrieved. Reported only as
  characterised by Vennekens et al. on p. 20, quoted above.
- **Turner 1996** (splitting for default logic, cited at §4.3.3) and **Eiter et al. 1997**:
  not retrieved.

No formula in this report was paraphrased from mangled text. Every quoted theorem was read
off a 200 dpi rendering of the page. Where I could not read or did not retrieve a source, it
is listed above rather than reconstructed.
