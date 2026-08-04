# AFT Lane 1 — Core Theory Foundations

Retrieval date: 2026-08-04. All formal statements below marked **[QUOTE]** are transcribed
from page images rendered at 150–160 dpi from the source PDFs (not from text extraction),
so subscripts, superscripts and order symbols are as printed. Anything marked
**[DERIVED]** is my own reasoning from those quoted definitions, not something I found
stated in a paper.

## Sources actually read

| Tag | Source | How obtained |
|---|---|---|
| **KR02** | Denecker, Marek, Truszczyński, *Ultimate approximations in nonmonotonic knowledge representation systems*, KR2002. Preliminary version of the Information & Computation 2004 paper. | arXiv `cs/0205014`, PDF → page images |
| **KR00** | Denecker, Marek, Truszczyński, *Uniform semantic treatment of default and autoepistemic logics*, KR2000. Preliminary version of the AIJ 2003 paper. | arXiv `cs/0002002` |
| **CRS18** | Charalambidis, Rondogiannis, Symeonidou, *Approximation Fixpoint Theory and the Well-Founded Semantics of Higher-Order Logic Programs*, TPLP. | arXiv `1804.08335` |
| **HAB22** | Heyninck, Arieli, Bogaerts, *Non-Deterministic Approximation Fixpoint Theory and Its Application in Disjunctive Logic Programming*. | arXiv `2211.17262` |
| **VBD25** | Vanbesien, Bogaerts, Denecker, *Approximation Fixpoint Theory with Refined Approximation Spaces*, 2025. **This is the most general current AFT.** | arXiv `2506.16294`, PDF → page images |
| **VBD-d** | Bogaerts et al., *Distributed Autoepistemic Logic*. | arXiv `2306.02774` |
| **Pol25** | Pollaci, *A Category-Theoretic Perspective on AFT*, ICLP 2024 doctoral. | arXiv `2502.09234` |

---

## 1. The bilattice `L²` and the precision order `≤_p`

**[QUOTE — KR02 §2]**

> Let ⟨L, ≤⟩ be a complete lattice. By the *product bilattice* [Gin88] of ⟨L, ≤⟩ we mean
> the set L² = L × L with the following two orderings ≤_p and ≤:
>
>   1. (x, y) ≤_p (x′, y′)  if  x ≤ x′ and y′ ≤ y
>   2. (x, y) ≤ (x′, y′)  if  x ≤ x′ and y ≤ y′.
>
> Both orderings are complete lattice orderings for L². However, in this paper we are
> mostly concerned with the ordering ≤_p.
>
> An element (x, y) ∈ L² is *consistent* if x ≤ y. We can think of a consistent element
> (x, y) ∈ L² as an *approximation* to every z ∈ L such that x ≤ z ≤ y. With this
> interpretation in mind, the ordering ≤_p, when restricted to consistent elements, can be
> viewed as a *precision* ordering. Consistent pairs that are "higher" in the ordering ≤_p
> provide tighter approximations. Maximal consistent elements with respect to ≤_p are pairs
> of the form (x, x). We call approximations of the form (x, x) — *exact*.
>
> We denote the set of all consistent pairs in L² by L^c. The set ⟨L^c, ≤_p⟩ is not a
> lattice. It is, however, chain-complete. Indeed, the element (⊥, ⊤) is the least element
> in L^c and the following result shows that every chain in L^c has (in L^c) the least upper
> bound.

**Note the asymmetry in `≤_p`:** the *second* coordinate is ordered *dually*. Precision
increases as the lower bound rises and the upper bound falls. This is the single most
load-bearing fact in everything below.

Equivalent modern statement **[QUOTE — HAB22 Def. 4]**, which names the orders `≤_i`
(information/precision) and `≤_t` (truth):

> Given a lattice L = ⟨L, ≤⟩, a bilattice is the structure L² = ⟨L², ≤_i, ≤_t⟩, in which
> L² = L × L, and for every x₁, y₁, x₂, y₂ ∈ L,
> • (x₁, y₁) ≤_i (x₂, y₂) if x₁ ≤ x₂ and y₁ ≥ y₂,
> • (x₁, y₁) ≤_t (x₂, y₂) if x₁ ≤ x₂ and y₁ ≤ y₂.

**Why pairs at all** **[QUOTE — Pol25 §1]**:

> The core ideas of AFT are relatively simple: we are interested in fixpoints of an operator
> O on a given lattice ⟨L, ≤⟩. For monotonic operators, Tarski's theory guarantees the
> existence of a least fixpoint... For non-monotonic operators, the existence of fixpoints is
> not guaranteed; and even if fixpoints exist, it is not clear which would be "good"
> fixpoints. AFT generalizes Tarski's theory for monotonic operators by making use of a
> so-called approximating operator...

The pair is an **interval**. `(x,y)` stands for `[x,y] = {z | x ≤ z ≤ y}`. `≤_p` is
reverse interval inclusion on consistent pairs. **[QUOTE — VBD-d §3.3]**: "If (u, v) is
consistent, the latter means that (x, y) approximates all elements approximated by (u, v),
or in other words that [u, v] ⊆ [x, y]."

---

## 2. What an approximating operator IS

There are **three distinct, non-equivalent conditions** in the literature and they are
routinely conflated. Getting them apart is essential.

### 2a. DMT's original (strictest) — "partial approximation operator"

**[QUOTE — KR02 §3]**

> For an operator A : L^c → L^c, we denote by A¹ and A² its projections to the first and
> second coordinates, respectively. Thus, for every (x, y) ∈ L^c, we have
> A(x, y) = (A¹(x, y), A²(x, y)). An operator A : L^c → L^c is a *partial approximation
> operator* if it is ≤_p-monotone and if for every x ∈ L, A¹(x, x) = A²(x, x). We denote the
> set of all partial approximation operators on L^c by Appx(L^c).
>
> [...] If A ∈ Appx(L^c) and O : L → L is an operator on L such that A(x, x) = (O(x), O(x))
> then we say that A is a *partial approximation of O*. We denote the set of all partial
> approximations of O by Appx(O). If A is a partial approximation of O then x ∈ L is a
> fixpoint of O if and only if (x, x) is a fixpoint of A.

So under DMT: **`≤_p`-monotonicity is *part of* the definition, not a separate condition**,
and it is joined by a second, independent condition — **exactness on the diagonal**,
`A¹(x,x) = A²(x,x)`.

KR02 also flags that this differs from the L²-wide version of DMT00a (the 2000 chapter)
**[QUOTE — KR02 §3 end]**:

> We need to emphasize that the concept of a partial approximation introduced here is
> different from the concept of *approximation* introduced in [DMT00a]. The latter notion is
> defined as an operator of the whole bilattice L². That choice was motivated by our search
> for generality and potential applications of inconsistent fixpoints in situations when we
> admit a possibility of some statements being overdefined. While different, both approaches
> are very closely related.

### 2b. The canonical restatement (interval-containment form)

**[QUOTE — VBD-d §3.3]**

> An operator A : L² → L² is an *approximator of O* if it is ≤_p-monotone, and has the
> property that for all x, O(x) ∈ [x′, y′], where (x′, y′) = A(x, x). Approximators map L^c
> into L^c. As usual, we restrict our attention to *symmetric* approximators: approximators
> A such that for all x and y, A(x, y)₁ = A(y, x)₂.

**[QUOTE — VBD25 Def. 3 prose]**

> An approximator A *approximates* an operator O : C → C if for every (x₁, x₂) ∈ B^c and
> y ∈ C, O(y) is approximated by A(x₁, x₂) whenever y is approximated by (x₁, x₂).

This is strictly **weaker** than 2a: it demands `A¹(x,x) ≤ O(x) ≤ A²(x,x)`, not equality.

### 2c. The modern minimal definition — monotonicity ONLY

**[QUOTE — VBD25 Def. 3]**

> **Definition 3** (Approximating Operator (Approximator)). An operator A : B^c → B^c is an
> approximating operator if A is ≤_p-monotone. We denote the set of approximating operators
> on B^c by Appr(B^c). We will often use the shorted term *approximator* instead of
> *approximating operator*.

**[QUOTE — VBD25 Def. 11]**

> **Definition 11** (Approximating Operator (Approximator)). Let 𝒜 = ⟨ℒ, 𝒰, ℬ, ⪯⟩ be an
> approximation framework. We say that A : ℬ → ℬ is an approximating operator of
> approximator if A is ≤_p-monotone. We use Appr(ℬ) to denote the set of approximators for 𝒜.

**[QUOTE — CRS18 Def. 22]**

> A function A : L₁ ⊗ L₂ → L₁ ⊗ L₂ is called a *consistent approximating operator* if it is
> ⪯-monotonic.

**Answer to the brief's question:** `≤_p`-monotonicity is **always** required and is never
a separate optional condition — in the modern formulation it is the *entire* definition of
an approximator. What varies across the literature is the *additional* diagonal condition
(exactness `A¹(x,x)=A²(x,x)`, or interval-containment of `O(x)`), and that additional
condition is what ties `A` to a specific approximated operator `O`. Both CRS18 and VBD25
**drop the diagonal condition entirely**.

**[DERIVED] Unpacking `≤_p`-monotonicity componentwise.** From the quoted `≤_p`
definition, `A` is `≤_p`-monotone iff:

- `A¹` is `≤`-monotone in its first argument and `≤`-**anti**monotone in its second;
- `A²` is `≤`-**anti**monotone in its first argument and `≤`-monotone in its second.

CRS18 uses exactly this vocabulary **[QUOTE — CRS18 §1]**: "the first member of the pair is
monotone-antimonotone and the second member is antimonotone-monotone."

**Symmetric approximators.** **[QUOTE — HAB22 fn. 8]**

> In some papers (e.g., [22]), an approximation operator is defined as a symmetric
> ≤_i-monotonic operator, i.e. a ≤_i-monotonic operator s.t. for every x, y ∈ L,
> O(x, y) = (O^l(x, y), O^l(y, x)) for some O^l : L² → L. However, the weaker condition we
> take here (taken from [21]) is actually sufficient for most results on AFT.

So the mainstream convention is that the *upper* component is **the same function as the
lower one with its arguments swapped**. Non-symmetric approximators are legal and are
studied (HAB22 constructs one), but symmetry is the default.

---

## 3. The fixpoint hierarchy

### Kripke-Kleene fixpoint

**[QUOTE — KR02 §3]**

> Let A ∈ Appx(L^c). Since A is ≤_p-monotone and L^c is chain-complete, A has a least
> fixpoint, called the *Kripke-Kleene fixpoint* of A (KK(A), in symbols). Directly from the
> definition, it follows that KK(A) approximates all fixpoints of A.
> [...] If A is a partial approximation of O then x ∈ L is a fixpoint of O if and only if
> (x, x) is a fixpoint of A. Thus, for every fixpoint x of O, we have KK(A) ≤_p (x, x) or,
> equivalently, KK¹(A) ≤ x ≤ KK²(A).

Existence rests only on chain-completeness of `⟨L^c, ≤_p⟩` + `≤_p`-monotonicity
**[QUOTE — KR02 Prop. 2.1 corollary]**: "It follows that every ≤_p-monotone operator on L^c
has a least fixpoint."

### Reliability and prudence (the preconditions)

**[QUOTE — KR02 §3]**

> Let A be an operator on L^c. We call an approximation (a, b) *A-reliable* if
> (a, b) ≤_p A(a, b).

**[QUOTE — KR02 §3]**

> An A-reliable approximation (a, b) is *A-prudent* if a ≤ b^↓.

### Stable revision operator

**[QUOTE — KR02 §3, following Prop. 3.1]**

> This proposition implies that for every A-reliable pair (a, b), the restrictions of
> A¹(·, b) to [⊥, b] and A²(a, ·) to [a, ⊤] are in fact operators on [⊥, b] and [a, ⊤],
> respectively. Moreover, they are ≤-monotone operators on the posets ⟨[⊥, b], ≤⟩ and
> ⟨[a, ⊤], ≤⟩. Since ⟨[⊥, b], ≤⟩ and ⟨[a, ⊤], ≤⟩ are complete lattices, the operators
> A¹(·, b) and A²(a, ·) have least fixpoints in the lattices ⟨[⊥, b], ≤⟩ and ⟨[a, ⊤], ≤⟩,
> respectively. We define:
>
>   b^{A↓} = lfp(A¹(·, b))   and   a^{A↑} = lfp(A²(a, ·)).
>
> We call the mapping (a, b) ↦ (b^{A↓}, a^{A↑}), defined on the set of A-reliable elements
> of L^c, the *stable revision operator for A*.

Modern equivalent **[QUOTE — HAB22 Def. 6]**:

> The stable operator for O is: S(O)(x, y) = (lfp(O^l(., y)), lfp(O^u(x, .)).

**[QUOTE — VBD25 Def. 4]**

> Let A be an approximator, then the stable revision operator is given by St : B^c → B^c
> which maps any (x₁, x₂) ∈ B^c to (lfp(A¹_{x₂}), lfp(A²_{x₁})), where A¹_{x₂}(y₁) is the
> projection of A(y₁, x₂) on its first component and A²_{x₁}(y₂) is the projection of
> A(x₁, y₂) on its second component.

**Note the argument-crossing.** `St¹` freezes the *upper* bound and takes a least fixpoint
in the *lower* coordinate; `St²` freezes the *lower* bound and takes a least fixpoint in
the *upper*. **This crossing is where AFT's whole content lives** — see §7.

### Stable fixpoints

**[QUOTE — KR02 §3]**

> Let L be a complete lattice and let A ∈ Appx(L^c). We say that (x, y) ∈ L^c is a *stable
> fixpoint* of A if (x, y) is A-reliable and is a fixpoint of the stable revision operator
> (that is, x = y^↓ and y = x^↑). By the A-reliability of (x, y), the second requirement is
> well defined.
>
> Stable fixpoints of an operator are, in particular, its fixpoints.

**[QUOTE — KR02 Prop. 3.2]**

> Let L be a complete lattice and let A ∈ Appx(L^c). If (x, y) is a stable fixpoint of A
> then (x, y) is a fixpoint of A.

**[QUOTE — KR02 §3]**

> Let O be an operator on a complete lattice L and let A ∈ Appx(O). We say that x is an
> *A-stable* fixpoint of O if (x, x) is a stable fixpoint of A.

### Well-founded fixpoint

**[QUOTE — KR02 §3, construction]**

> we define a sequence {(a^α, b^α)}_α of elements of L^c by transfinite induction:
>
>  1. (a⁰, b⁰) = (⊥, ⊤)
>  2. If α = β + 1, we define a^α = b^{β↓} and b^α = a^{β↑}
>  3. If α is a limit ordinal, we define (a^α, b^α) = lub({(a^β, b^β) : β < α}).

**[QUOTE — KR02 Thm. 3.7]**

> The sequence {(a^α, b^α)}_α is well defined, ≤_p-monotone and its limit is the least
> stable fixpoint of a partial approximation operator A.

**[QUOTE — KR02 §3]**

> We call this least stable fixpoint the *well-founded fixpoint* of A and denote it by
> WF(A). The well-founded fixpoint approximates all stable fixpoints of A. In particular,
> it approximates all A-stable fixpoints of the operator O. That is, for every A-stable
> fixpoint x of O, WF(A) ≤_p (x, x) or, equivalently, WF¹(A) ≤ x ≤ WF²(A), where WF¹(A) and
> WF²(A) are the two components of the pair WF(A). Moreover, the well-founded fixpoint is
> more precise than the Kripke-Kleene fixpoint: for A ∈ Appx(O), KK(A) ≤_p WF(A).

**Hierarchy summary:** `KK(A) ≤_p WF(A) ≤_p` every stable fixpoint `≤_p` every exact stable
fixpoint. Fixpoints of `A` ⊇ stable fixpoints of `A` ⊇ well-founded fixpoint. Exact
fixpoints of `A` ↔ fixpoints of `O`.

### Supported fixpoints

**[QUOTE — VBD25 §2]**

> The set of *supported fixpoints* of A, denoted by SUP(A), is defined as
> {x ∈ 𝒞 | A(x, x) = (x, x)}, i.e., the exact fixpoints of A.

---

## 4. Why the stable revision operator is the interesting one

**[QUOTE — KR02 §3]**

> The stable revision operator for A ∈ Appx(L^c) is crucial. It allows us to distinguish an
> important subclass of the class of all fixpoints of A.

**[QUOTE — KR02 §3, after Prop. 3.4]**

> Let us observe that an A-reliable pair (a, b) is revised by an operator A into a more
> accurate approximation A(a, b). An A-prudent pair (a, b) can be revised "even more".
> Namely, it is easy to see that A¹(a, b) ≤ A¹(b^↓, b) = b^↓ and a^↑ = A²(a, a^↑) ≤ A²(a, b).
> Thus, A(a, b) ≤_p (b^↓, a^↑). In other words, (b^↓, a^↑) is indeed at least as precise
> revision of (a, b) as A(a, b) is.

**[QUOTE — HAB22 §, after Def. 6]**

> Stable operators capture the idea of minimizing truth, since for any ≤_i-monotonic operator
> O on L², the fixpoints of the stable operator S(O) are ≤_t-minimal fixpoints of O.

So: stable revision is (i) *always at least as precise* as one application of `A`, and
(ii) it internalises minimality — it is what turns "supported model" into "stable model".

**Well-definedness conditions** **[QUOTE — VBD25 Thm. 2, attributed to DMT 2004 Thm 3.11]**:

> Let ℬ^c = ⟨𝒞^c, ≤_p⟩ be a consistent approximation space with approximator A. The set of
> A-reliable and A-prudent elements of ℬ^c is a cpo under the precision order ≤_p with least
> element (⊥, ⊤). The stable revision operator is a well-defined, increasing and monotone
> operator in this poset.

---

## 5. Ultimate approximation

**[QUOTE — KR02 §4]**

> Partial approximations in Appx(L^c) can be ordered. Let A, B ∈ Appx(L^c). We say that A is
> *less precise* than B (A ≤_p B, in symbols) if for each pair (x, y) ∈ L^c,
> A(x, y) ≤_p B(x, y). It is easy to see that if A ≤_p B then there is an operator O on the
> lattice L such that A, B ∈ Appx(O).

**[QUOTE — KR02 Thm. 4.2]**

> Let O be an operator on a complete lattice L. Let A, B ∈ Appx(O). If A ≤_p B then
> KK(A) ≤_p KK(B) and WF(A) ≤_p WF(B).

**[QUOTE — KR02 Thm. 4.3]**

> Let O be an operator on a complete lattice L. Let A, B ∈ Appx(O). If A ≤_p B then every
> exact fixpoint of A is an exact fixpoint of B, and every exact stable fixpoint of A (that
> is, an A-stable fixpoint of O) is also an exact stable fixpoint of B (that is, a B-stable
> fixpoint of O).

**Existence** **[QUOTE — KR02 §4]**

> We start by providing a non-constructive argument for the existence of ultimate
> approximations. Let us note that the set Appx(O) is not empty. Indeed, let us define
> A_O(x, y) = (O(x), O(x)), if x = y, and A_O(x, y) = (⊥, ⊤), otherwise. It is easy to see
> that A_O ∈ Appx(O) and that it is the least precise element in Appx(O). Next, we observe
> that Appx(O) with the ordering ≤_p is a complete lattice, as the set Appx(O) is closed
> under the operations of taking greatest lower bounds and least upper bounds. It follows
> that Appx(O) has a greatest element (most precise approximation). We call this partial
> approximation the *ultimate approximation* of O and denote it by U_O.

**Explicit characterisation** **[QUOTE — KR02 Thm. 4.5]**

> Let O be an operator on a complete lattice L. Then, for every (x, y) ∈ L^c,
> U_O(x, y) = (glb(O([x, y])), lub(O([x, y]))).
>
> where for every x, y ∈ L such that x ≤ y, we define O([x, y]) = {O(z) : z ∈ [x, y]}.

**What it buys** **[QUOTE — KR02 Cor. 4.4]**

> Let O be an operator on a complete lattice L. For every A ∈ Appx(O), KK(A) ≤_p KK(U_O),
> WF(A) ≤_p WF(U_O) and every A-stable fixpoint of O is an ultimate stable fixpoint of O.

**[QUOTE — KR02 Cor. 4.6]**

> Let L be a complete lattice. An element x ∈ L is an ultimate stable fixpoint of an operator
> O : L → L if and only if x is the least fixpoint of the operator glb(O([·, x])) regarded as
> an operator on [⊥, x].

**The cost** **[QUOTE — KR02 §1]**: "This better accuracy comes, however, at a cost. We show
that ultimate semantics are in general computationally more complex."

**The polarity result — most relevant to our question** **[QUOTE — KR02 Prop. 4.7]**

> If O is a monotone operator on a complete lattice L then for every (x, y) ∈ L^c,
> U_O(x, y) = (O(x), O(y)). If O is antimonotone then for every (x, y) ∈ L^c,
> U_O(x, y) = (O(y), O(x)).

**[QUOTE — KR02 Cor. 4.8]**

> Let O be an operator on a complete lattice L. If O is monotone, then the least fixpoint of
> O is the ultimate well-founded fixpoint of O and the unique ultimate stable fixpoint of O.
> If O is antimonotone, then KK(O) = WF(O) and every fixpoint of O is an ultimate stable
> fixpoint of O.

Read Prop. 4.7 carefully. **When `O` is monotone, its ultimate approximator is literally the
componentwise product `(O(x), O(y))`.** That is the entire theory for a monotone `O` — and
Cor. 4.8 says the whole AFT apparatus then degenerates to "the least fixpoint of `O`".
This is the literature stating, for the single-operator case, exactly the degeneracy we are
about to derive for the two-operator case.

---

## 6. Exact conditions and their cost

| Result | Needs `≤_p`-monotone `A`? | Needs consistency (`L^c`)? | Lattice requirement |
|---|---|---|---|
| Existence of KK(A) | **Yes** (essential — it is Tarski/Markowsky on `⟨L^c, ≤_p⟩`) | Chain-completeness of `⟨L^c,≤_p⟩` is what is used; KR02 Prop. 2.1 | Complete lattice `L` ⟹ `⟨L^c,≤_p⟩` chain-complete with least element `(⊥,⊤)` |
| `A¹(·,b)`, `A²(a,·)` well defined as operators on `[⊥,b]`, `[a,⊤]` | **Yes** (proof of KR02 Prop. 3.1 is one line of `≤_p`-monotonicity) | **Yes** — requires `(a,b)` *A-reliable* | `[⊥,b]` and `[a,⊤]` must be complete lattices, which holds when `L` is complete |
| Stable revision well defined | Yes | Yes — defined only on **A-reliable** pairs | Complete lattice |
| `(b^↓,a^↑)` consistent, reliable, prudent (KR02 Prop. 3.3) | Yes | Requires **A-prudent**, strictly stronger than A-reliable | Complete lattice |
| Stable revision `≤_p`-monotone (KR02 Prop. 3.4) | Yes | `(a,b)` reliable **and** `(c,d)` prudent | Complete lattice |
| Existence + uniqueness of WF(A) (KR02 Thm. 3.7) | Yes | Yes, via the reliable+prudent cpo | Complete lattice |
| Ultimate approximation exists (KR02 §4) | Yes | Yes | **Complete lattice required** — the argument is that `Appx(O)` is closed under arbitrary glb/lub |
| Modern general version (VBD25 Thm. 3) | **Yes, and this is the ONLY condition on `A`** | Built into the approximation space | `⟨ℒ,⪯⟩` a **bounded-complete cpo**, `⟨𝒰,⪯⟩` a **complete lattice**, plus 4 interlattice properties |

**[QUOTE — KR02 §3, on why prudence]**

> The notion of A-reliability is not strong enough to guarantee desirable properties of the
> stable revision operator. In particular, if (a, b) ∈ L^c is A-reliable, it is not true in
> general that (b^↓, a^↑) is consistent nor that (a, b) ≤_p (b^↓, a^↑). There is, however, a
> class of A-reliable pairs for which both properties hold.

**The chain-complete-poset vs complete-lattice split.** KR02 works on `⟨L^c, ≤_p⟩` which
is **not a lattice** but is chain-complete; that is enough for KK and WF. The *complete
lattice* assumption on `L` is needed (a) to make `[⊥,b]` and `[a,⊤]` complete lattices so
the stable revision `lfp`s exist, and (b) for the ultimate approximation to exist. VBD25
relaxes this to: lower space a bounded-complete cpo, upper space a complete lattice.

---

## Can AFT take two different operators?

### Short answer

**No — not as a pair of independent operators occupying the two coordinates.**
The bilattice's two coordinates are structurally a *lower and an upper bound on one thing*,
and every "approximates `O`" relation in the literature is defined against a single `O`.
But **the coordinator's stated reason is not the correct reason**, and one of the three
sub-claims is wrong. Details below, then the escape hatches, which are real but do not
rescue the `(Γ, Δ)` construction.

### Q1. "Does AFT genuinely require an antitone ingredient?" — **No. This claim is false.**

The exact condition is `≤_p`-monotonicity, quoted verbatim in §2. Unpacked componentwise
**[DERIVED from the quoted `≤_p`]**: `A¹` must be monotone in argument 1 and *antitone in
argument 2*; `A²` must be *antitone in argument 1* and monotone in argument 2.

Antitonicity in an argument is **satisfied vacuously by constancy in that argument.** So:

> **[DERIVED]** Let `Γ, Δ : L → L` both be `≤`-monotone. Then `A(x,y) = (Γ(x), Δ(y))` **is**
> `≤_p`-monotone.
> *Proof.* Let `(x,y) ≤_p (x′,y′)`, i.e. `x ≤ x′` and `y′ ≤ y`. Monotonicity of `Γ` gives
> `Γ(x) ≤ Γ(x′)`; monotonicity of `Δ` gives `Δ(y′) ≤ Δ(y)`. Together these are exactly
> `(Γ(x), Δ(y)) ≤_p (Γ(x′), Δ(y′))`. ∎

There is no antitone ingredient anywhere and the condition holds. Two same-polarity
monotone operators **can** be assembled into a `≤_p`-monotone `A`. The literature agrees
implicitly: KR02 Prop. 4.7 says the ultimate approximator of a *monotone* `O` **is** the
product `(O(x), O(y))` — a legitimate approximator with no antitone ingredient at all.

So: if the Quint result was justified by "neither operator can fill AFT's antitone slot",
that justification does not survive contact with the definition. **The obstruction is
elsewhere, and it is stronger.**

### Q2. "Is the collapse-to-componentwise claim right?" — **Yes in substance, for two independent reasons, and the second one is fatal.**

That `A(x,y) = (Γ(x), Δ(y))` is a product with no cross-coordinate interaction is true by
construction. But `A` need not be of product form just because it is built from `Γ` and
`Δ`. The real obstructions are:

**(i) The consistency obstruction — this is the decisive one, and it does not depend on
exactness at all.** Every version of AFT — DMT's `Appx(L^c)`, CRS18's `L₁ ⊗ L₂`, VBD25's
approximation space `ℬ` — requires `A` to map the *consistent* space into itself: the
lower component must stay `≤` the upper component.

> **[DERIVED] Theorem (polarity obstruction).** Let `Γ` be a closure operator
> (`x ≤ Γ(x)`, monotone, idempotent) and `Δ` a kernel/interior operator (`Δ(x) ≤ x`,
> monotone, idempotent) on `L`. Suppose `A : L^c → L^c` is any approximator whose diagonal
> carries `Γ` in the lower coordinate and `Δ` in the upper, i.e. `A(x,x) = (Γ(x), Δ(x))`.
> Then `Γ = Δ = id_L`.
> *Proof.* `A` maps into `L^c`, so `A¹(x,x) ≤ A²(x,x)`, i.e. `Γ(x) ≤ Δ(x)` for all `x`.
> But `Δ(x) ≤ x ≤ Γ(x)` by the defining inequalities. Hence `Δ(x) = x = Γ(x)`. ∎

This holds for **any** `A`, product-form or not, and needs *neither* exactness *nor*
`≤_p`-monotonicity. It is purely the polarity clash: **AFT's lower slot must
under-approximate and its upper slot must over-approximate, while a closure operator
over-approximates and a kernel under-approximates.** The intended assignment is backwards.

The obvious fix — swap them — is consistent but empty:

> **[DERIVED]** `A(x,y) = (Δ(x), Γ(y))` *is* a legal approximator: it maps `L^c` into `L^c`
> (`x ≤ y` ⟹ `Δ(x) ≤ x ≤ y ≤ Γ(y)`) and it is `≤_p`-monotone by Q1. But every AFT invariant
> it produces is trivial. Because `A¹` ignores `y` and `A²` ignores `x`:
> - `St¹(x,y) = lfp(A¹(·,y)) = lfp(Δ) = ⊥` (a kernel satisfies `Δ(⊥) ≤ ⊥`, so `⊥` is its
>   least fixpoint), for every `(x,y)`.
> - `St²(x,y) = lfp(A²(x,·)) = lfp(Γ) = Γ(⊥)`, the least `Γ`-closed element, for every `(x,y)`.
>
> So the stable revision operator is the **constant map** `(x,y) ↦ (⊥, Γ(⊥))`. It has
> exactly one fixpoint, so `WF(A) = (⊥, Γ(⊥))` and there is exactly one stable fixpoint,
> which is not exact unless `Γ(⊥) = ⊥`. `Δ` never appears in the answer. Similarly
> `KK(A) = (⊥, ⊤)` (since `Δ(⊥)=⊥` and `Γ(⊤)=⊤`), reached at step one.

**(ii) The exactness obstruction (classical DMT only).** Under KR02's `Appx(L^c)`
(`A¹(x,x) = A²(x,x)`), a product `A(x,y) = (Γ(x), Δ(y))` forces `Γ(x) = Δ(x)` for all `x`,
i.e. `Γ = Δ`; and a map that is simultaneously a closure and a kernel is `id`. **[DERIVED]**

**Is this a known observation?** Not stated as such — I found no paper that discusses the
`(Γ, Δ)` product case explicitly. The **closest published statement** is KR02 Prop. 4.7 +
Cor. 4.8 (quoted in §5): for a monotone `O`, the ultimate approximator is exactly the
product `(O(x), O(y))` and the entire AFT hierarchy collapses to `lfp(O)`. That is the
literature saying, in the one-operator case, that product-form approximators carry no
information beyond ordinary Tarski. The general principle behind it — **AFT's content is
the cross-dependence `A¹(·, y)` and `A²(x, ·)`** — is visible directly in the stable
revision definition (§3): the whole point is that the lower bound is computed *relative to
an assumed upper bound*. A product operator has no such dependence, so stable revision is
constant, so KK = WF = the unique stable fixpoint and nothing has been computed.

### Q3. Escape hatches — searched honestly. Three exist; none rescues `(Γ, Δ)`.

**Hatch A — drop exactness. REAL, and stronger than the brief assumed.**
CRS18 (2018) hit precisely the "the two coordinates live in different structures" problem
and solved it. **[QUOTE — CRS18 §, introducing Def. 22]**:

> In our work, the immediate consequence operator T_P is not an approximating operator in
> the sense of (Denecker et al. 2004). More specifically, T_P is a function in
> (H_P^ma ⊗ H_P^am) → (H_P^ma ⊗ H_P^am). In other words, there is not just a single lattice L
> involved in the definition of T_P, but instead two lattices, namely H_P^ma and H_P^am.
> Moreover, the condition "for every x ∈ L, A(x, x)₁ = A(x, x)₂" required in (Denecker et al.
> 2004), does not hold in our case, because the two arguments of T_P range over two different
> sets. We therefore need to define an extension of the material in Section 3 of (Denecker
> et al. 2004), that suits our purposes.

Their replacement conditions **[QUOTE — CRS18]**:

> 1. Interlattice Lub Property: Let b ∈ L₂ and S ⊆ L₁ such that for every x ∈ S, x ≤ b.
>    Then, ⋁_{L₁} S ≤ b.
> 2. Interlattice Glb Property: Let a ∈ L₁ and S ⊆ L₂ such that for every x ∈ S, x ≥ a.
>    Then, ⋀_{L₂} S ≥ a.
>
> Given (x, y), (x′, y′) ∈ L₁ × L₂, we will write (x, y) ⪯ (x′, y′) if x ≤ x′ and y′ ≤ y.
> We will write: L₁ ⊗ L₂ = {(x, y) | x ∈ L₁, y ∈ L₂, x ≤ y}

VBD25 generalises this **[QUOTE — VBD25 Def. 9]**:

> **Definition 9** (Approximation framework). Assume that ℒ and 𝒰 are sets and that ⪯ is a
> partial order over ℒ ∪ 𝒰 such that ⟨ℒ ∪ 𝒰, ⪯⟩ has a least element ⊥ ∈ ℒ and a greatest
> element ⊤ ∈ 𝒰, ⟨ℒ, ⪯⟩ is a bounded-complete cpo and ⟨𝒰, ⪯⟩ is a complete lattice. An
> approximation framework 𝒜 is a tuple ⟨ℒ, 𝒰, ℬ, ⪯⟩ such that
>  1. ⟨ℬ, ≤_p⟩ is a composition poset of ⟨ℒ ∪ 𝒰, ⪯⟩.
>  2. it satisfies the Chain Interlattice Lub Property: [...]
>  3. it satisfies the Weak Interlattice Lub Property: [...]
>  4. it satisfies the Abstract Interlattice Lub Property: [...]
>  5. it satisfies the Interlattice Glb Property: Let l ∈ ℒ and S ⊆ 𝒰. If for every u ∈ S,
>     l ⪯ u, then l ⪯ glb_𝒰(S).

with **[QUOTE — VBD25 Thm. 3]**:

> Let 𝒜 = ⟨ℒ, 𝒰, ℬ, ⪯⟩ be an approximation framework with approximator A. The set of
> A-reliable and A-prudent elements of ℬ is a cpo under the precision order ≤_p with least
> element (⊥, ⊤). The stable revision operator is a well-defined, increasing and monotone
> operator in this poset.

VBD25 footnote 4 **[QUOTE]**: "Note that interval-AFT, as well as the generalization of AFT
proposed by Charalambidis, Rondogiannis, and Symeonidou (2018), are special instances of
this general notion, but neither captures flowers."

**Assessment:** this is genuinely two-structure AFT with *no* diagonal condition, and the
full hierarchy (reliable, prudent, stable revision, KK, WF) survives on
`≤_p`-monotonicity alone. **But** condition 5 and the composition-poset requirement still
force `X^ℒ ⪯ X^𝒰` — the lower object still bounds the upper object. So the polarity
obstruction of Q2(i) applies unchanged, and the product degeneracy of Q2 applies unchanged.
Hatch A removes the *exactness* barrier but not the *polarity* or *cross-dependence*
barriers.

**Hatch B — opposite-polarity operators.** The only place AFT handles opposite polarity is
KR02 Prop. 4.7 (quoted §5): for antimonotone `O`, `U_O(x,y) = (O(y), O(x))` — one operator
with its arguments swapped, not two operators. Likewise the mainstream *symmetric
approximator* convention `A(x,y)₁ = A(y,x)₂` (VBD-d; HAB22 fn. 8) is one function used
twice. Non-symmetric approximators are legal and are constructed (HAB22 Def. 14 builds one)
— so **the two components need not be the same function** — but they remain the two bounds
of one intended `O`.

**Hatch C — non-monotone AFT.** I found none. `≤_p`-monotonicity is load-bearing in every
existence proof (it is what lets Knaster-Tarski apply to the reliable/prudent cpo).
VBD25, the 2025 state of the art, *reduces* the definition to monotonicity alone rather
than weakening it.

**"Consistent approximation" does not cover this.** `L^c = {(x,y) : x ≤ y}` is just the
restriction to intervals; it is the *source* of the polarity obstruction, not a way around it.

**Multi-operator settings I checked and ruled out:**
- Distributed autoepistemic logic (arXiv 2306.02774): several *agents*, but a single
  operator on a product lattice indexed by agents. Still one `O`, one `A`.
- Non-deterministic AFT (HAB22): one operator, set-valued. `O : L → ℘(L)\{∅}`.
- Category-theoretic AFT (Pol25): a *research programme*, not results. Its stated axis of
  generalisation is "general approximation spaces" and "general processes" — not multiple
  operators.

### What this means for `Γ` (closure) / `Δ` (kernel), validity = common fixpoints

**[DERIVED]** AFT is the wrong instrument, and specifically:

1. AFT is built to find good fixpoints of **one non-monotone operator**. Both `Γ` and `Δ`
   are monotone; each already has a complete Tarski theory of its own. AFT for a monotone
   `O` degenerates to `lfp(O)` (KR02 Cor. 4.8, quoted). There is nothing for AFT to add.
2. The two coordinates of `L²` are a *lower* and an *upper* bound. `Γ` is inflationary and
   `Δ` deflationary, so the natural assignment is polarity-backwards; the consistency-
   preserving assignment `(Δ, Γ)` is legal but produces `lfp Δ = ⊥` and never mentions `Δ`
   again.
3. Common fixed points of a closure and a kernel operator is a classical lattice-theory
   question (the `Γ`-fixpoints form a closure system, closed under meets; the `Δ`-fixpoints
   are closed under joins; their intersection is the clopen elements). Galois-connection /
   adjunction machinery is the natural tool, not AFT.

**Where I would push back on the coordinator's framing:** the failure is *not* "both are
monotone so neither is antitone". It is that AFT's bilattice encodes **one object bracketed
from two sides**, whereas `(Γ, Δ)` is **two objects with no bracketing relation** — and
because a product approximator has no cross-coordinate dependence, stable revision (the one
construct that makes AFT more than Tarski) becomes constant. Any writeup should say that,
because the "no antitone ingredient" version is refutable in one line by KR02 Prop. 4.7.

**On stratifiability ≠ union-closure / the splitting theorem:** I did not retrieve
Vennekens, Gilis & Denecker, *Splitting an operator: Algebraic modularity results for logics
with fixpoint semantics* (ACM TOCL 7(4), 2006), so I cannot confirm or refute the transfer
claim from primary text. I note only that the splitting results in that line of work split
**one** operator along a product decomposition of the lattice, not a pair of operators —
which is consistent with your finding but is not verification of it.

---

## What I could not retrieve

1. **Denecker, Marek & Truszczyński (2000), *Approximations, stable operators, well-founded
   fixpoints and applications in nonmonotonic reasoning*, in Logic-Based AI (Kluwer).**
   The PDF link on Truszczyński's own publications page
   (`http://www.cs.uky.edu/ai/papers.dir/approx-operators.pdf`) returns **404**; all
   `papers.dir` paths and the `papers.dir/` directory itself 404. Not on arXiv. Not read.
   **Consequence:** the `L²`-wide (possibly-inconsistent) version of the approximation
   definition — the one KR02 explicitly says is *different* from its own `L^c` version — is
   quoted only via KR02's own description of it and via secondary restatements (VBD-d,
   HAB22). If your model needs to reason about *inconsistent* pairs (`x ≰ y`), get this
   chapter before relying on anything here.

2. **Denecker, Marek & Truszczyński (2004), *Ultimate approximation and its application in
   nonmonotonic knowledge representation systems*, Information and Computation 192(1).**
   Elsevier, not open access; the Unpaywall lookup I attempted resolved the wrong DOI, and I
   did not attempt a paywall bypass. **I used the KR2002 preliminary version (arXiv
   `cs/0205014`) instead**, which contains §2 Preliminaries, §3 Partial Approximations and §4
   Ultimate Approximations in full — every definition in §§1–5 above marked KR02 is from it.
   Numbering in the journal version differs (VBD25 cites "DMT 2004 Theorem 3.11" for what
   KR02 presents as Thm. 3.7 + Prop. 3.4); **do not cite theorem numbers as if from the 2004
   paper based on this document.**

3. **Denecker, Marek & Truszczyński (2003), *Uniform semantic treatment of default and
   autoepistemic logics*, AIJ 143.** I retrieved the KR2000 preliminary version (arXiv
   `cs/0002002`) but it is an *applications* paper — it develops `D_T` for autoepistemic
   theories and `E_Δ` for default theories and does not restate the general algebra. I did
   not read it in depth; it contributes nothing to the questions above. The AIJ version
   itself is paywalled.

4. **Bogaerts' PhD thesis (*Groundedness in logics with a fixpoint semantics*, KU Leuven
   2015).** Semantic Scholar returned zero results for it; I did not locate a PDF. Not read.
   The "cleaner canonical restatement" role is filled instead by VBD-d §3.3, HAB22 Defs. 4–7
   and VBD25 Defs. 3–4, all of which I did read and quote.

5. **Vennekens, Gilis & Denecker, *Splitting an operator* (TOCL 2006).** Not retrieved. See
   the caveat at the end of the previous section.

6. **Web search was unavailable** — this session's WebSearch budget (200 calls) was already
   exhausted before my first query. All discovery was done via the arXiv API, Semantic
   Scholar (which rate-limited at 429 on one of two calls), and direct fetches of authors'
   pages. **I therefore cannot claim an exhaustive survey.** In particular, a paper
   explicitly titled around "AFT for a pair of operators" could exist and have escaped an
   arXiv-metadata-only search. What I can say is that the four generalisation papers that
   *should* cite such work if it existed — CRS18, HAB22, VBD25 and the Pollaci research
   programme — describe the open frontier as *general approximation spaces* and *general
   processes*, and none of them mentions a multi-operator variant.
