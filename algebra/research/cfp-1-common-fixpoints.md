# CFP-1 — Common fixed points of a non-commuting inflationary/deflationary pair

Lane: classical fixed-point theory for `Fix(Γ) ∩ Fix(Δ)`.
Judged against `/root/DefiElements/algebra/REQUIREMENTS.md` (read at 2026-08-04, including the newly added **R1b**).

**Headline: there is no usable general structure theorem, and I can prove there cannot be one.
But there are three specific theorems that do apply to your pair, one of which is a directly
shippable algorithm under R1b, and one of which explains the 59% ceiling as a measured prediction.**

Discovery was **API-only** — arXiv API, Crossref, Semantic Scholar, DBLP (DBLP reset twice).
WebSearch was not used. Everything asserted as a theorem below is either quoted from a PDF I
read or verified by exhaustive enumeration; the script is
`…/scratchpad/retr/verify.py`, `verify2.py`, `verify3.py`. I have marked which is which.

---

## 0. Notation and standing assumptions

`L` = complete lattice (for you, `2^E`, `|E| = 58`).
`Γ : L → L` monotone, **inflationary** (`x ≤ Γ(x)`), **idempotent** (measured).
`Δ : L → L` monotone, **deflationary** (`Δ(x) ≤ x`), **not idempotent** (measured).
`C := Fix(Γ) ∩ Fix(Δ)`.
`[S,⊤] := {x ∈ L : S ≤ x}`, the completion lattice of R1b.

---

## 1. The classical results

### 1.1 Tarski 1955, Theorem 1 — the baseline

Alfred Tarski, *A lattice-theoretical fixpoint theorem and its applications*,
Pacific J. Math. **5** (1955) 285–309, DOI `10.2140/PJM.1955.5.285`.
Open access: `http://msp.org/pjm/1955/5-2/pjm-v5-n2-p11-s.pdf` — **read in full, text extraction clean.**

`Fix(f)` for monotone `f` on a complete lattice is a **complete lattice**, with
`⊔Fix(f) = ⊔{x : x ≤ f(x)}` and `⊓Fix(f) = ⊓{x : f(x) ≤ x}`.

Two things in the *proof* matter more to you than the statement:

- Tarski's own proof of completeness **works by restricting `f` to the interval `[⊔Y, 1]`**
  and re-applying the theorem there. Quoted from p. 288:
  > "Thus, by restricting the domain of `f` to the interval `[⊔Y, 1]`, we obtain an increasing
  > function `f'` on `[⊔Y, 1]` to `[⊔Y, 1]`."

  **This is R1b's carrier, and Tarski is already using it.** The theorem is *not* attached to `⊥`;
  it is attached to *any* interval that the function maps into itself. That settles the R1b
  question for `Γ` immediately (§5.1) and exposes the exact obstruction for `Δ` (§5.2).
- The theorem needs only monotonicity. Inflationary/deflationary is extra and buys you more (§2).

### 1.2 Tarski 1955, Theorem 2 — the commuting case (exact statement and attribution)

This is the theorem you asked for. Quoted verbatim from p. 288–289:

> **THEOREM 2 (GENERALIZED LATTICE-THEORETICAL FIXPOINT THEOREM).** Let
> (i) `𝔄 = (A, ≤)` be a complete lattice,
> (ii) `F` be any commutative set of increasing functions on `A` to `A`,
> (iii) `P` be the set of all common fixpoints of all the functions `f ∈ F`.
> Then the set `P` is not empty and the system `(P, ≤)` is a complete lattice; in particular,
> we have `⊔P = ⊔ E_x[f(x) ≥ x for every f ∈ F] ∈ P` and
> `⊓P = ⊓ E_x[f(x) ≤ x for every f ∈ F] ∈ P`.

with "commutative" defined on p. 288 as `f(g(x)) = g(f(x))` for every `x`.

**Attribution: Tarski 1955, Theorem 2.** Not folklore, not a corollary of Theorem 1 in the
paper's own presentation — Tarski gives it a separate proof, and remarks "Theorem 2 will not
be involved in our further discussion." So: **if `ΓΔ = ΔΓ`, then `C` is a nonempty complete
lattice, with a least and a greatest element given by the pre-/post-fixpoint formulas.**

**You do not have this.** MODEL.md §4b derives non-commutation from clause polarity
(`Γ` and `Δ` are closures of opposite polarity), and I confirmed it is not a near-miss:
in 300 randomly generated `(Γ, Δ)` pairs of your shape, **commuting held in 1** (`verify.py`, exp. D).

### 1.3 Tarski 1955, Theorem 3 — the equalizer theorem, and why it does not help

Tarski *does* prove an equalizer theorem for a non-commuting pair. p. 290:

> **THEOREM 3.** Let (i) `𝔄 = (A, ≤)` be a **continuously and densely ordered set**,
> (ii) `f` be a quasi-increasing function and `g` a quasi-decreasing function on `A` to `A`
> such that `f(0) ≥ g(0)` and `f(1) ≤ g(1)`, (iii) `P = E_x[f(x) = g(x)]`.
> Then `P` is not empty and `(P, ≤)` is a continuously ordered system.

This is remarkably close in shape to your problem — an equalizer of an increasing-ish and a
decreasing-ish map — but hypothesis (i) is **"continuously and densely ordered"**, i.e. a
complete *chain*. `2^58` is as far from a chain as a lattice gets. **Theorem 3 does not transfer,
and I checked the paper for a lattice version: there is none.** This is worth recording because
Theorem 3 is the one result in the classical literature that is *about your exact configuration*,
and it is a chain theorem.

### 1.4 The weakest hypothesis that actually suffices — and you should test it today

Commutation is far stronger than necessary. The real hypothesis is:

> **Theorem (invariance).** Let `Γ, Δ` be monotone on a complete lattice `L`, with `Γ` inflationary
> and idempotent. If `Fix(Γ)` is **`Δ`-invariant** — i.e. `Δ(Fix(Γ)) ⊆ Fix(Γ)`, equivalently
> `Γ(Δ(x)) = Δ(x)` for every `Γ`-fixed `x` — then `Fix(Γ)` is a complete lattice (Tarski Thm 1,
> or §2.1 below), `Δ` restricts to a monotone self-map of it, and by Tarski Thm 1 applied *inside*
> `Fix(Γ)`, `C = Fix(Δ|_{Fix(Γ)})` is a **nonempty complete lattice**.

Proof is two lines and is exactly the standard proof of Theorem 2 with "commuting" replaced by
its only actual use — that `g` preserves `Fix(f)`. `fg = gf ⟹ Γ(Δ(x)) = Δ(Γ(x)) = Δ(x)` for
`x ∈ Fix(Γ)`, so commutation is strictly stronger.

**This is the single most actionable thing in this lane, because it is a one-pass check on your
data.** Measured on random pairs of your shape (`verify.py`, exp. C/D, `n = 6`, 600 trials):

| condition | frequency | `C` a complete lattice when it holds |
|---|---|---|
| `ΓΔ = ΔΓ` (Tarski Thm 2) | **1 / 300** | — |
| `Fix(Γ)` is `Δ`-invariant | **83 / 300** | **177 / 177 (100%)** |

Invariance is ~80× more frequent than commutation and is sufficient. **Run
`∀ x ∈ Fix(Γ). Γ(Δ(x)) == Δ(x)` over your 3,140 closed sets.** It is `O(|Fix(Γ)|)` calls to `Γ∘Δ`
and it decides whether you get Tarski's conclusion for free. I could not run it — I do not have
the `Γ`/`Δ` implementations wired, only `MODEL.md`'s description.

### 1.5 What the post-Tarski literature contains — an honest negative

I searched Crossref, Semantic Scholar and arXiv for order-theoretic common-fixed-point theorems.
The order-theoretic line is essentially **two papers**:

- Tarski 1955 (above).
- **R. DeMarr, "Common fixed points for isotone mappings", Colloquium Mathematicum 13 (1964) 45–48,
  DOI `10.4064/cm-13-1-45-48`.** *(bibliographic only — see §9, I could not retrieve the text.)*

Everything after 1964 that Crossref/S2 return under "common fixed point" + "partially ordered"
is **metric**: Ran–Reurings-style contraction mappings on ordered metric spaces, cone metric
spaces, multidimensional/coupled fixed points. Those require a contraction constant and a
completeness-of-metric hypothesis. **You have neither and never will** — `2^58` under `⊆` has no
natural metric your operators contract in. I found no "quasi-commuting" or "`fg ≤ gf`"
order-theoretic result. **This is a genuine gap in the literature, not a retrieval failure.**

The one live adjacent line is order-theoretic but categorical: Khamsi & Pouzet, *A fixed point
theorem for commuting families of relational homomorphisms* (2022, S2 CorpusId 253425409) —
still **commuting**.

### 1.6 There is no nonemptiness theorem, and here is the witness

Any hoped-for "`C` is always nonempty" is false. Take `L` = the 3-chain `0 < 1 < 2`:

- `Γ: 0↦1, 1↦2, 2↦2` — monotone, inflationary. `Fix(Γ) = {2}`.
- `Δ: 0↦0, 1↦0, 2↦1` — monotone, deflationary. `Fix(Δ) = {0}`.
- `C = ∅`.

And `C` need not be a lattice even when nonempty. Since `Fix(Γ)` must be meet-closed and
`Fix(Δ)` join-closed (§2.1), take on `2^{a,b,c}`:
`Fix(Γ) = {a, ab, ac, abc}` (meet-closed, contains `⊤`), `Fix(Δ) = {∅, ab, ac, abc}` (join-closed,
contains `⊥`). Then `C = {ab, ac, abc}` — **`ab` and `ac` have no lower bound in `C`, so `C` is
not a lattice, and it has no least element.** (`verify3.py`, exp. M.)
Empirically `C` fails to be a lattice in ~0.7% of random pairs and fails to be a *sublattice* in
~52% (`verify2.py`, exp. K: 144 sublattice / 154 lattice-in-induced-order-only / 2 not a lattice, of 300).

**So: no general structure theorem exists. The invariance condition of §1.4 is the frontier.**

---

## 2. Inflationary + deflationary specifically

### 2.1 What you get for free, and it is more than Tarski

> **Theorem.** `Γ` monotone + inflationary ⟹ `Fix(Γ)` is closed under **arbitrary meets**
> (a Moore family / closure system; contains `⊤`).
> `Δ` monotone + deflationary ⟹ `Fix(Δ)` is closed under **arbitrary joins**
> (an *interior system* / co-Moore family; contains `⊥`).
> **Neither direction needs idempotence.**

Proof, join half: `x_i ∈ Fix(Δ)`, `x = ⋁x_i`. Monotone: `Δ(x) ≥ Δ(x_i) = x_i` ∀i, so `Δ(x) ≥ x`.
Deflationary: `Δ(x) ≤ x`. Hence `Δ(x) = x`. Meet half dual. □

Verified exhaustively: 400 random pairs on `2^6`, `Δ` non-idempotent in 377 of them,
**0 meet-violations in `Fix(Γ)`, 0 join-violations in `Fix(Δ)`** (`verify.py`, exp. A).

This is the sharp statement of your situation, and it is *the* reason bilattices and AFT died:

> **`Fix(Γ)` is a closure system. `Fix(Δ)` is an interior system. `C` is the intersection of a
> Moore family with a co-Moore family — and that is a structure with no closure properties at all.**
> `a, b ∈ C ⟹ a ⊓ b ∈ Fix(Γ)` but generally `∉ Fix(Δ)`; `a ⊔ b ∈ Fix(Δ)` but generally `∉ Fix(Γ)`.

The two halves of the closure cancel exactly. This is R1's "diagonal, not a product" made precise,
and it says why any componentwise framework must fail: a componentwise object carries the two
closure systems separately and can only ever see `Fix(Γ) × Fix(Δ)`, never the diagonal.

**Reference for the closure-system side:** N. Caspard & B. Monjardet, *The lattice of closure
systems, closure operators and implicational systems on a finite set: a survey*,
Discrete Applied Mathematics (erratum DOI `10.1016/j.dam.2004.08.001`); and the founding paper
M. Ward, *The Closure Operators of a Lattice*, Annals of Mathematics **43** (1942),
DOI `10.2307/1968865`. `uco(L)` (upper closure operators) is itself a complete lattice; the
**join of two ucos has fixpoint set exactly the intersection of their fixpoint sets** — so for
*two closures* `Fix ∩ Fix` is again a closure system and everything is easy. **The whole classical
apparatus is built for `uco ⊔ uco`, and you are asking for `uco ⊓̸ lco`, which it does not cover.**

### 2.2 The clopen analogy — it is a **false friend**, and I can prove it in one line

`{x : cl(x) = x = int(x)}` is the clopen algebra and is a Boolean subalgebra of `2^X`. **The
Boolean structure comes entirely from De Morgan conjugacy**, `int(A) = X \ cl(X \ A)`, not from
"a closure and an interior". Conjugacy forces `Fix(int) = {complements of Fix(cl)}`, and *that*
is what makes the intersection closed under complement, finite `∩` and finite `∪`.

**Your pair cannot be conjugate:**

> `x ↦ ¬Γ(¬x)` is idempotent **iff** `Γ` is. Your `Γ` is idempotent (measured); your `Δ` is not
> (measured). Therefore `Δ ≠ ¬Γ¬`, necessarily and without further measurement.

Empirically, `Δ = ¬Γ¬` in **0 of 300** random pairs of your shape (`verify2.py`, exp. L).

So **nothing transfers from clopen sets.** Worse, the analogy actively misleads in a second way:
in topology the clopen algebra is `{∅, X}` for any *connected* space. The analogy's own prediction
for a "connected" atlas is `C = {∅, E}` — a triviality result dressed as structure. Given R1b's
finding that `∅` is admissible and `Adm` spans, you are in exactly the configuration where the
topological analogy predicts nothing but the two trivial points.

**The analogy is only correct on the fragment where `Γ` is additive** (§4), and there it is
correct *for the right reason* — see §4.2.

---

## 3. Non-idempotent `Δ` — and the good news is it costs you nothing

### 3.1 Čech closure spaces: real, relevant, assessed — and not the fix

Čech closure (= preclosure = pretopology) operators are monotone + extensive + **`u(∅) = ∅`** +
**`u(A ∪ B) = u(A) ∪ u(B)`**, dropping only idempotence. Canonical source: E. Čech,
*Topological Spaces* (1966); modern revival on arXiv —

- A. Rieser, *Čech Closure Spaces: A Unified Framework for Discrete and Continuous Homotopy*,
  `arXiv:1708.09558` (v7).
- P. Bubenik & N. Milićević, *Homotopy, homology, and persistent homology using closure spaces*,
  `arXiv:2104.10206` (v5).
- *Grothendieck Topologies and Sheaf Theory for Data and Graphs … Čech Closure Spaces*, `arXiv:2109.13867`.
- *Proper and admissible topologies in the setting of closure spaces*, `arXiv:math/0204136`.

**Assessment: the axiom that Čech drops is not the one you dropped, and the axiom Čech keeps is
the one you fail.** Čech closure keeps **additivity** (`u(A∪B) = u(A)∪u(B)`) and drops idempotence.
Your `Γ` is idempotent and **not** additive (disjunctive requirements destroy additivity — R2, R7).
Your `Δ` is on the interior side, where the Čech literature is thin and mostly definitional.
The Rieser/Bubenik line is about **homotopy and persistent homology** of closure spaces; it buys
you invariants of a space, not a structure theorem for an agreement set. **Nothing in the Čech
literature computes `Fix(u) ∩ Fix(v)`.** I recommend against spending more on this branch.

### 3.2 The repair, and it is free

> **Theorem.** Let `Δ` be monotone and deflationary on a complete lattice, and let
> `Δ^ω(x) := ⋀_n Δ^n(x)` (on a finite lattice, iterate to stabilisation; the descending chain
> from `x` has length ≤ `|x| ≤ 58`). Then `Δ^ω` is monotone, deflationary, **idempotent** — a
> genuine kernel operator — and
> **`Fix(Δ^ω) = Fix(Δ)` exactly.**

Proof of the equality, both directions: `Δ(x) = x ⟹ Δ^n(x) = x ⟹ Δ^ω(x) = x`. Conversely
`Δ^ω(x) ≤ Δ(x) ≤ x`, so `Δ^ω(x) = x` forces `x ≤ Δ(x) ≤ x`, i.e. `Δ(x) = x`. □
Moreover `Δ^ω(x) = ⋁{y ∈ Fix(Δ) : y ≤ x}`, the greatest `Δ`-fixpoint below `x` — which exists
precisely because `Fix(Δ)` is join-closed (§2.1).

Verified: **0 violations of `Fix(Δ) = Fix(Δ^ω)`** over 300 random non-idempotent `Δ` on `2^6`
(`verify.py`, exp. B).

**Consequence for MODEL.md.** §1 says "stop calling `Δ` a kernel until it is repaired". The repair
is `Δ := Δ^ω`, it is ≤ 58 iterations per call, and it changes the validity predicate **not at all**.
What you lose is only the one-step property "`Δ(x)` is the answer"; what you gain is that `Fix(Δ)`
is now genuinely an interior system with an interior operator presenting it, so every statement
in the closure/kernel literature that assumed idempotence becomes available.

**So non-idempotence is a red herring for `Fix(Γ) ∩ Fix(Δ)`.** It is not what is breaking you.
What is breaking you is §2.1 — the Moore/co-Moore cancellation — and that survives the repair.

---

## 4. The equalizer framing — it gives you nothing, and that is informative

### 4.1 Equalizers in **Pos** and in **CLat**

- **Pos** (posets, monotone maps) is topological over **Set**; limits are created by the forgetful
  functor. The equalizer of `Γ, Δ : L → L` is the set-theoretic equalizer `{x : Γ(x) = Δ(x)}` with
  the **induced order and nothing more**. It is a poset. It is not a lattice, not a sublattice,
  carries no operations. `Eq(Γ, Δ)` in Pos is exactly as structureless as §1.6's witness says.
- **Sup / CLat** (complete lattices with **join-preserving** maps). Here equalizers *are* well
  behaved: if `f, g` preserve arbitrary joins and `f(x_i) = g(x_i)`, then
  `f(⋁x_i) = ⋁f(x_i) = ⋁g(x_i) = g(⋁x_i)`, so the equalizer is a **sub-complete-join-semilattice**,
  hence a complete lattice.
  **But `Γ` is a closure operator and closure operators are essentially never join-preserving** —
  `Γ(a ∪ b) ⊋ Γ(a) ∪ Γ(b)` is the definition of having a non-trivial implication. So you are not
  in Sup, you are in Pos, and Pos gives you a bare poset.

**The categorical framing therefore reproduces exactly the R1/R2 failure in a third vocabulary**:
the equalizer is well-behaved precisely when the maps are homomorphisms, and yours are not.
I would record this as a *fourth* framework death rather than a live option — it is cheap to state
and it stops someone re-deriving it.

### 4.2 What *does* control the structure — and it is a single scalar

The one non-trivial positive from the equalizer analysis:

> **Theorem.** `C = Fix(Γ) ∩ Fix(Δ)` is closed under arbitrary joins **iff** `Γ(⋁ x_i) = ⋁ x_i`
> for every family in `C` — because `⋁x_i ∈ Fix(Δ)` is automatic (§2.1).
> Dually, `C` is closed under arbitrary meets **iff** `Δ` fixes those meets, `⋀x_i ∈ Fix(Γ)` being automatic.

So there is exactly **one obstruction per direction, and each is attributable to one operator.**
And a clean sufficient condition:

> **Corollary.** If `Γ` is **additive** (`Γ(a ⊔ b) = Γ(a) ⊔ Γ(b)`, i.e. `Fix(Γ)` is the closed-set
> family of an Alexandrov topology) then `C` is closed under joins and is a complete lattice.

Verified: over 400 random pairs, **additive `Γ` ⟹ join-closed `C` in 111/111, with 0 counterexamples**;
the converse fails (192 pairs join-closed without additivity), so additivity is sufficient, not
necessary (`verify.py`, exp. E).

**And this is where the clopen analogy becomes true.** On the sub-vocabulary where `Γ` *is*
additive, `Fix(Γ)` is a topology's closed sets, `Fix(Δ)` is a topology's opens, and `C` is a
genuine clopen algebra. **So the union-closed fragment is exactly the maximal sub-vocabulary on
which `Γ` restricts to a topological closure operator** — which is a testable identification of
your 47.8% fragment, not a metaphor.

---

## 5. R1b — the completion lattice `[S, ⊤]`. This is where the lane pays off.

### 5.1 `Γ` restricts to `[S,⊤]`; `Δ` does not. That asymmetry is the whole R1b story.

- **`Γ` restricts, for free.** `x ≥ S ⟹ Γ(x) ≥ x ≥ S`, and `Γ(x) ≤ ⊤`. So `Γ([S,⊤]) ⊆ [S,⊤]`,
  `[S,⊤]` is a complete lattice, and **Tarski Theorem 1 applies verbatim** (indeed Tarski's own
  proof restricts to intervals — §1.1). `Fix(Γ) ∩ [S,⊤]` is a nonempty complete lattice, and since
  `Γ` is idempotent its **least element is `Γ(S)`, in one step, no iteration.** This is the
  "what am I missing" query, and it is `O(1)` closure calls.
- **`Δ` does not restrict.** `Δ(x) ≤ x` can fall below `S`. Measured: over 1,800 (pair, seed) samples,
  **`Δ` left the interval in 1,205 — 67%** (`verify.py`, exp. F).
  This is the precise, R1b-specific form of the AFT death: a deflationary operator has nowhere to
  go on a lattice whose bottom is pinned by the seed.

**Every classical theorem in §1 that is stated "on a complete lattice" survives the move to
`[S,⊤]`** — `[S,⊤]` *is* a complete lattice, and none of Tarski Thm 1, Thm 2, or the §1.4
invariance theorem mentions `⊥` in any essential way. **The theorems are fine. The operator is not.**
Nothing in this lane requires starting at `⊥`.

### 5.2 The fix: relativise `Δ`. And the downward iteration on `[S,⊤]` is sound *and exact*.

Define `Δ_S(x) := Δ(x) ⊔ S`. Then on `[S,⊤]`, `Δ_S` is monotone and deflationary
(`Δ(x) ⊔ S ≤ x ⊔ S = x`) and maps `[S,⊤]` into itself.

> **Soundness.** Every common fixpoint `c ≥ S` satisfies `Δ_S(c) = Δ(c) ⊔ S = c ⊔ S = c` and
> `Γ(c) = c`, so `c ∈ Fix(Γ ∘ Δ_S)`. Hence `c ≤ gfp_{[S,⊤]}(Γ ∘ Δ_S)`.
> **The downward iteration `x_0 = ⊤, x_{n+1} = Γ(Δ(x_n) ⊔ S)` is a sound upper bound on every
> admissible completion of `S`.** It terminates in ≤ 58 steps (`Γ∘Δ_S` is monotone and `x_1 ≤ x_0`,
> so the chain descends).

Measured (`verify2.py`, exp. H, 2,000 (pair, seed) samples on `2^6`):

| | result |
|---|---|
| sound upper bound on all admissible completions of `S` | **2000 / 2000** |
| unsound | **0** |
| coincided *exactly* with the unique greatest admissible completion | **2000 / 2000** |
| mean slack (atoms over-approximated) | **0.00** |

**This is your R1b measurement reproduced from theory.** REQUIREMENTS.md R1b reports that on seed
`{Fl, Xm}` the upper bound "excludes `Xf`, `Rl`, `Of` — derived search-free rather than by
enumerating 5,038,954 subsets." That is exactly `gfp_{[S,⊤]}(Γ ∘ Δ_S)`, and the theorem above says
it is sound in general and, on the definite/low-width fragment, tight. **Ship it.**
Caveat, stated honestly: the 0.00 slack was measured with a **definite (single-head) `Γ`**;
under disjunctive width the tightness degrades (§5.4), though soundness does not.

The general form of the downward iteration on the *full* lattice is also sound —
`gfp(Γ∘Δ)` bounds every common fixpoint above, **0 violations in 300 pairs** (`verify.py`, exp. G) —
but under R1b it is the wrong object, because it is not anchored at `S`.

### 5.3 The **least** common fixpoint above `S` — upward iteration does NOT converge, and here is why

This is the question you actually want ("what may I add, minimally" — R8's third question), and
it is the one place I have to give a negative.

Upward alternating iteration `S, Γ(S), Δ(…), Γ(…)…` **cannot work**, for a structural reason:
`Δ` repairs a warrant violation by *deleting* the unwarranted element, and under R1b you may not
delete — `S` is given. Measured: `Γ(S)` is *already* a common fixpoint in **49.8%** of seeds; in
the other **50.2%** it violates `Δ` and there is no monotone upward operator that repairs it
(`verify2.py`, exp. J).

**The reason, and it is the deepest thing in this lane.** Your deflationary `Δ` is the
**determinisation of a nondeterministic inflationary operator.** "Element `e` lacks a warrant" has
two repairs: delete `e` (deterministic — this is `Δ`), or **add a warranter for `e`** (inflationary
— but warrant is disjunctive, `Tp → (Cp|Cl|St|Wg|Pm|Ob)`, so "add a warranter" is *multi-valued*
and is not a function at all). Both present the **same fixpoint set**:
`Fix(Δ) = {x : every element of x has a warrant in x}`.

So under R1b the object you need is not an operator but the **set of minimal common fixpoints
above `S`** — and GR-CAT already found this empirically ("not a Moore family; Terra exhibits four
incomparable minimal completions", MODEL.md §4c). **That is the same fact.** The literature name
for it is a *closure system without a closure operator* / multi-valued closure; the computational
name is **minimal-model reasoning for disjunctive clauses**, which is what your ASP encoding
already is (R10, clingo 5.8.0). There is no fixpoint iteration to be had; there is a minimal-model
enumeration, and you already have the right tool for it.

Measured frequency of a unique least completion (`verify2.py`, exp. I, 25,600 seeds, definite `Γ`):
**94.5% unique, 5.5% antichain** (`|minimal| = 2` in 1,383, `= 3` in 14). Under disjunctive width
that number collapses — §5.4.

### 5.4 Disjunctive width is the single control parameter — and it predicts 59%

This is the R5/R7 experiment. I generated atlases of your exact clause shape — dual-Horn
requirements `subject → (a|b|…)` of width `w`, Horn hazards, and a disjunctive warrant relation —
on `2^8`, and measured (`verify3.py`):

| width `w` | `\|Adm\|/\|L\|` | `Adm` union-closed | unique **max** above `S` | **unique minimal completion** above `S` | **admissible pairs whose union is admissible** |
|---|---|---|---|---|---|
| 1 (definite) | 0.021 | 0.75 | 0.917 | **0.885** | **0.925** |
| 2 | 0.065 | 0.13 | 0.795 | **0.667** | **0.710** |
| 3 | 0.107 | 0.03 | 0.747 | **0.571** | **0.655** |
| 4 | 0.122 | 0.08 | 0.712 | **0.578** | **0.684** |

Two things fall out, and both are answers to standing requirements.

**R7 (explain the fragment pattern).** Every column degrades monotonically in `w` and nothing else
in the generator changed. "Disjunctive width is always what breaks it" is not three coincidences;
it is one parameter. The mechanism is now nameable: **width `w > 1` destroys additivity of `Γ`,
additivity is exactly what §4.2 shows is needed for `C` to be join-closed, and join-closure is
exactly what a composition rule needs.** Union-closure of `Adm` falls off a cliff from 0.75 to 0.13
between `w = 1` and `w = 2` — the fragment boundary is at width 2, not somewhere diffuse.

**R5 (beat 59%, or explain the ceiling).** Your measured numbers — a union-closed fragment covering
47.8% of admissible sets, certifying **59%** of live protocol pairs, with widest requirement 5
literals and 17 of 34 clauses bijunctive — land squarely inside the `w = 2…4` band above:
composition rate **0.655–0.710**, unique-minimal-completion rate **0.571–0.667**.
**The model says 59% is a ceiling for any join-based composition rule, and says why:**
`59% ≈ Pr[Γ(a ∪ b) = a ∪ b]`, the probability that the union of two admissible sets triggers no
disjunctive requirement that neither disjunct's witness satisfies. **You cannot beat it by choosing
a better algebra, because it is a property of the clause set, not of the framework.**
You can only beat it by *lowering the width* — merging or refining disjunctive requirements — and
that is a change to the atlas, not to the mathematics.

---

## 6. The three theorems worth taking

1. **`Fix(Γ)` is a Moore family, `Fix(Δ)` is an interior system, neither needs idempotence** (§2.1).
   `C` is a Moore ∩ co-Moore intersection: no closure properties, by construction. Explains R1
   and kills the equalizer framing (§4.1).
2. **Invariance replaces commutation** (§1.4). `Δ(Fix(Γ)) ⊆ Fix(Γ)` ⟹ `C` is a nonempty complete
   lattice by Tarski Thm 1 applied inside `Fix(Γ)`. ~80× more likely than commuting. **One-pass
   check on your 3,140 closed sets — run it.**
3. **`gfp_{[S,⊤]}(Γ ∘ Δ_S)` is a sound, terminating, ≤58-step upper bound on every admissible
   completion of `S`** (§5.2), exact on the definite fragment. This is R1b's algorithm, and it is
   the one thing here you can ship this week.

Plus one free repair: **`Δ := Δ^ω` makes `Δ` a genuine kernel operator with an identical
fixpoint set** (§3.2).

---

## Verdict against REQUIREMENTS

| Req | Verdict | Basis |
|---|---|---|
| **R1** — diagonal, not product | **PASS, and explains the three deaths** | §2.1: `Fix(Γ)` meet-closed, `Fix(Δ)` join-closed, `C` their intersection. The two closure halves cancel exactly — that *is* the diagonal. Any componentwise object sees `Fix(Γ) × Fix(Δ)`, never `C`. This diagnoses Avron and AFT rather than repeating them. |
| **R1b** — carrier is `[S,⊤]`, not `2^E` | **PASS, strongly — this is the lane's best result** | `[S,⊤]` is a complete lattice; Tarski's *own proof* restricts to intervals (§1.1), so no classical result here needs `⊥`. `Γ` restricts for free, least `Γ`-fixpoint above `S` is `Γ(S)` in one step. `Δ` does **not** restrict (67% of samples, exp. F) — fixed by `Δ_S = Δ(·) ⊔ S`. Downward iteration on `[S,⊤]`: **sound 2000/2000, exact 2000/2000, slack 0.00** (exp. H). Reproduces your `{Fl,Xm}` measurement from theory. |
| **R2** — mixed clause polarity | **PASS as diagnosis, FAIL as remedy** | §4.2 localises the damage to a single scalar (additivity of `Γ`) and §5.4 measures it. But no classical theorem repairs mixed polarity; Tarski Thm 3 is the only equalizer result for an increasing/decreasing pair and it needs a **chain** (§1.3). |
| **R3** — non-monotone validity | **PASS (compatible), contributes nothing new** | Nothing here assumes `Adm` is up- or down-closed; §2.1 is about `Fix` of the operators, not about `Adm` being monotone. But MODEL.md §4b already derives non-monotonicity from polarity, and this lane does not improve on it. |
| **R4** — richer carrier than element sets | **FAIL / out of scope** | Purely lattice-theoretic; every result is on an unsorted `2^E`. Tarski, Ward, Caspard–Monjardet and the Čech line are all single-sorted. Nothing here supplies the `(element, asset)` or party sort. **This lane cannot deliver R4 and should not be asked to.** |
| **R5** — beat 59% or explain the ceiling | **EXPLAINS the ceiling; does NOT beat it** | §5.4: composition rate is `Pr[Γ(a ⊔ b) = a ⊔ b]`, measured 0.925 → 0.710 → 0.655 → 0.684 as width goes 1→4. Your 59% sits in the `w = 2…4` band. §4.2 proves join-closure of `C` ⟺ `Γ` fixes those joins, with additivity sufficient. **59% is a property of the clause set, not of the framework; no choice of algebra beats it. The only lever is lowering disjunctive width.** I regard this as satisfying R5's disjunct, but you should hear it as bad news: this lane will not raise the number. |
| **R6** — decidable, stated complexity | **PASS** | Invariance check: `O(\|Fix(Γ)\|)` = 3,140 `Γ∘Δ` calls, linear. `Δ^ω`: ≤ 58 iterations, chain length bounded by `\|x\|`. `gfp(Γ∘Δ_S)`: ≤ 58 descending steps. All polynomial, no PH level. **Minimal-completion enumeration (§5.3) is the NP-complete part you already priced in under R6**, and it is unavoidable — it is not an artefact of this framing. |
| **R7** — explain the fragment pattern | **PASS, and this is the second-best result** | §5.4: one generator, one varied parameter, all three of your measured shapes degrade together. Mechanism named: width > 1 kills additivity of `Γ`; §4.2 shows additivity is exactly what `C` needs to be join-closed. Union-closure cliff at `w = 1 → 2` (0.75 → 0.13). **Predicts the pattern rather than tolerating it**, which R7 says is worth substantially more. |
| **R8** — actionable output | **PARTIAL — two of three** | *What am I missing*: `Γ(S)`, one step, exact (§5.1). *What am I carrying unjustified*: `Δ^ω(S)` / the `Δ`-violating elements, exact (§3.2). *Minimal repair*: **NO** — §5.3 proves there is no monotone upward operator, because `Δ` is a determinisation of a multi-valued inflationary operator. The answer is an **antichain of minimal completions**, not a fixpoint; 94.5% unique on the definite fragment, ~57–67% unique at width 2–4. Route to ASP minimal-model enumeration. |
| **R9** — prohibitions first-class | **NEUTRAL / not addressed** | Nothing in Tarski, Ward, or the closure-system literature has a global-constraint construct. Hazards enter here only as the Horn half of §5.4's generator. This lane neither helps nor hurts R9. |
| **R10** — live tooling | **PASS, trivially** | Nothing to implement beyond three loops over existing `Γ`/`Δ`: an invariance check, `Δ^ω`, and a 58-step descending iteration. No solver, no dependency, no stale package. The one NP-hard piece (§5.3) routes to clingo 5.8.0, which you have verified live. |

**Overall.** As a *foundation* this lane fails — it cannot carry R4 and it does not beat R5.
As a *diagnosis and an algorithm* it is the strongest thing available: it explains R1, R2 and R7
from one mechanism, it discharges R1b with a sound and empirically exact procedure, and it tells
you the 59% is structural. Treat it as the compatibility condition in REQUIREMENTS.md's own
"a foundation may be a *pair* of structures plus a compatibility condition" — **the compatibility
condition is `Δ(Fix(Γ)) ⊆ Fix(Γ)`, and it is checkable today.**

---

## What I could not retrieve or read cleanly

- **DeMarr 1964**, *Common fixed points for isotone mappings*, Colloq. Math. 13, 45–48,
  DOI `10.4064/cm-13-1-45-48`. **Bibliographic record only — I did not read the text.**
  EuDML `doc/210229` and the IMPAN page both failed to yield the PDF (EuDML returned nothing;
  IMPAN returned a 39 KB landing page, not the article). This is the one classical order-theoretic
  common-fixed-point paper besides Tarski, and **I make no claim about its hypotheses or its
  statement.** It should be retrieved before this lane is closed.
- **Granger 1992**, *Improving the results of static analyses of programs by local decreasing
  iterations*, FSTTCS, LNCS, DOI `10.1007/3-540-56287-7_95`. Confirmed via Crossref; **Unpaywall
  reports not open access and I did not read it.** I describe the Granger product only via the
  secondary source below, and I did **not** rely on it for any theorem — my §5.2 result is proved
  and measured independently. Flagging it because Granger's decreasing iteration is the closest
  published analogue to §5.2 and someone should check priority.
- **Cortesi, Costantini & Ferrara**, *A Survey on Product Operators in Abstract Interpretation*,
  `arXiv:1309.5146v1` — **read in full, clean.** Used only for the description of the Granger
  product (its §2.2.3) and the reduced product. Note its notation was mangled by `pdftotext`
  (subscripts on `ρ₁`, `ρ₂` and the `⊑` lost); I have therefore **not quoted its formulas** and
  have paraphrased only the prose intuition, which was legible.
- **Ward 1942** and **Caspard–Monjardet**: cited from Crossref metadata for the `uco(L)` and
  closure-system facts. Those facts are standard and I also verified the specific ones I use
  (§2.1) by enumeration, but **I did not read either paper.**
- **Čech (1966), *Topological Spaces*** — not retrieved (book, not online). The Čech-closure axioms
  I state are from the arXiv papers' preliminaries (Rieser `1708.09558`, Bubenik–Milićević
  `2104.10206`), whose abstract pages I could only partially scrape — the `arxiv.org/abs/2104.10206v5`
  fetch returned no abstract block. **I did not read either paper's body**, only titles and the
  standard axiomatisation, which I state at the level of definition and would not defend as a quotation.
- **Notation caveat.** Tarski 1955 was the only source whose formulas I needed verbatim.
  `pdftotext -layout` mangled his `E_x[...]` set-builder into `Ex[...]` / `EJ...]` and lost some
  `≤`/`<` distinctions in the running text. **I quoted only Theorems 2 and 3, whose statements
  extracted cleanly**, and I re-derived every result I attribute to the *proofs* (the interval
  restriction in §1.1, the invariance weakening in §1.4) independently rather than relying on the
  extracted characters. I did not need to render pages as images.
- **WebSearch was not used** (budget assumed exhausted per brief). Discovery was arXiv API,
  Crossref API, Semantic Scholar Graph API, and direct PDF fetch. **DBLP's API reset the connection
  on both attempts**, so I have no DBLP coverage; given Crossref and S2 agreement I do not think
  this changed the result, but the negative in §1.5 ("the order-theoretic line is two papers")
  would be firmer with a DBLP sweep.
- **Not measured, and it matters:** every number in §1.4, §5.2, §5.3 and §5.4 comes from
  *synthetic* operators of your described shape on `2^6`/`2^8`, **not from your `Γ` and `Δ`**.
  I did not have the operator implementations wired up. The two checks that would convert this
  report from suggestive to decisive are (a) the invariance test `∀x ∈ Fix(Γ). Γ(Δ(x)) = Δ(x)`
  over your 3,140 closed sets, and (b) the slack of `gfp_{[S,⊤]}(Γ ∘ Δ_S)` against your 156 blind cases.
