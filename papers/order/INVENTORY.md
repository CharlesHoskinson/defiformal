# Order-theoretic sources for `paper/atlas.tex`

Retrieval date 2026-08-04. **Discovery was API-only** (OpenAlex, arXiv Atom API, HAL Solr,
numdam, msp.org direct). WebSearch was not used. Every PDF below was downloaded and its
text extracted with `pdftotext -layout`; every quotation is transcribed from the extracted
text of the file named, not from memory. Where OCR mangled notation the fact is flagged and
no theorem is paraphrased from it.

Files in this directory:

| file | what it is |
|---|---|
| `tarski1955.pdf` / `.txt` | Tarski, Pacific J. Math. 5 (1955) 285-309 - full article scan |
| `schaefer1978.pdf` / `.txt` | Schaefer, STOC '78, 216-226 - full article scan (2-column OCR, jumbled reading order) |
| `geiger1968.pdf` / `.txt` | Geiger, Pacific J. Math. 27 (1968) 95-100 - the Pol/Inv Galois connection |
| `duquenne_guigues1986.pdf` / `.txt` | Guigues & Duquenne, Math. Sci. Hum. 95 (1986) 5-18 - original French, numdam scan |
| `armstrong2009_sortingorder.pdf` / `.txt` | Armstrong, JCTA 116 (2009) - carries verbatim restatements of Dilworth 1940 and Edelman 1980 |
| `muhle2019_meetdistributive.pdf` / `.txt` | Muhle, "Meet-distributive lattices have the intersection property", arXiv:1810.01528v4 |
| `cospanning_antimatroids.pdf` / `.txt` | "Cospanning characterizations of antimatroids and convex geometries", arXiv:2107.08556 |
| `bichoupan2022_implbases_convexgeom.pdf` / `.txt` | Bichoupan, "Complexity results for implication bases of convex geometries", arXiv:2211.08524 |
| `lincbo_dg_basis.pdf` / `.txt` | Janostik-Konecny-Krajca, "LinCbO", arXiv:2011.04928 - modern statement of the Duquenne-Guigues theorem |

**Not obtained (paywalled, no OA copy found via OpenAlex/HAL/CORE):** Edelman 1980
(Algebra Universalis), Dilworth 1940 (Annals), Caspard & Monjardet 2003 (Discrete Appl.
Math.), Birkhoff *Lattice Theory*, Ore 1943/1944, Post 1941. For each, a verbatim
restatement from an obtained source is given below and labelled as such.

---

## 1. Tarski 1955 - supports `cor:tarski`, but the corollary under-uses what is available

**Full citation.** Alfred Tarski, "A lattice-theoretical fixpoint theorem and its
applications", *Pacific Journal of Mathematics* **5** (1955), no. 2, 285-309.
Received June 29, 1953; the author notes "Most of the results contained in this paper were
obtained in 1939."

**Theorem 1, verbatim** (`tarski1955.txt` lines 65-80; the scan renders the fraktur carrier
as `?I`/`21`, transcribed here as `A`):

> THEOREM 1 (LATTICE-THEORETICAL FIXPOINT THEOREM). Let
>   (i) `A = <A, <=>` be a complete lattice,
>  (ii) `f` be an increasing function on `A` to `A`,
> (iii) `P` be the set of all fixpoints of `f`.
> Then the set `P` is not empty and the system `<P, <=>` is a complete lattice; in
> particular we have
>   `U P = U Ex[f(x) >= x]  in P`
> and
>   `n P = n Ex[f(x) <= x]  in P`.

"increasing" is defined on p. 286: "Such a function `f` is called increasing if, for any
elements `x, y` in `B`, `x <= y` implies `f(x) <= f(y)`." So the hypotheses are exactly:
complete lattice, *self-map*, monotone. **Idempotence is not required. Continuity is not
required. Nothing about joins being preserved is required or concluded.**

**The join in `Fix(f)` is not the ambient join.** This is explicit in Tarski's own proof
(`tarski1955.txt` lines 140-160):

> Now let `Y` be any subset of `P`. ... For any `x in Y` we have `x <= UY` ... therefore
> `UY <= f(UY)`. ... Thus, by restricting the domain of `f` to the interval `[UY, 1]`, we
> obtain an increasing function `f'` on `[UY, 1]` to `[UY, 1]`. By applying formula (5)
> established above to the lattice `B` and to the function `f'`, we conclude that the
> greatest lower bound `v` of all fixpoints of `f'` is itself a fixpoint of `f'`.
> Obviously, `v` is a fixpoint of `f`, and in fact the least fixpoint of `f` which is an
> upper bound of all elements of `Y`; in other words, `v` is the least upper bound of `Y`
> in the system `<P, <=>`.

So the join in `P` is *the least fixpoint above the ambient join* - for a closure operator
`Gamma` that is `Gamma(union)`, exactly as the brief suspected. The order on `P` is the
induced order; the operations are not induced.

**Verdict on `cor:tarski`: the argument is complete and correct as written.** Detail:

1. `Fix(Gamma)` is a complete lattice. True, and true twice over: by Tarski (`Gamma`
   monotone on the complete lattice `L = 2^El`), and more informatively because `Gamma` is
   a closure operator, so `Fix(Gamma)` is a Moore family with `meet = intersection` and
   `join = Gamma(union)`.
2. `Delta` restricts to a self-map of `Fix(Gamma)`. This is exactly `thm:invariance`, and
   it is exactly Tarski hypothesis (ii)'s "on `A` to `A`" requirement. Correctly identified
   as the thing that needs proving.
3. **Monotonicity of the restricted map.** The brief's worry - "Tarski needs monotonicity
   of the restricted map with respect to the induced order" - **is not a gap.** The order
   on `Fix(Gamma)` *is* the restriction of `subseteq`, and `Delta` is monotone for
   `subseteq` on all of `L` (`prop:polarity`); the restriction of a monotone map to a
   subposet carrying the induced order is monotone for that order, with no side condition.
   The hypothesis is discharged automatically. This would only be a real question if the
   subposet carried a *different* order, which it does not.
4. `Fix(Gamma) cap Fix(Delta) = Fix(Delta restricted to Fix(Gamma))`, immediately.
5. Nonemptiness comes free from Tarski ("the set `P` is not empty").

Idempotence of `Delta` is not needed at any step, so `meas:notidem` really is immaterial
here, and `prop:repair` is not load-bearing for `cor:tarski` (it is load-bearing for the
"kernel operator" language and for `Fix(Delta)` being union-closed).

**What is understated, and is worth correcting in the paper.** The paper says (scope
remark, and Open Problem 1) "Tarski also gives a lattice, not that meet is intersection",
and lists as open "whether meet is intersection on `Fix(Gamma) cap Fix(Delta)`". Tarski
does not supply it, but the paper's own hypotheses do, and the answer is **no, with an
explicit formula**. Writing `D = Delta^omega` (kernel operator, `prop:repair`) and
`M = Fix(Gamma) cap Fix(Delta)`:

- **Join in `M` is `Gamma(union)` exactly - i.e. the paper's own `oplus`.** Let
  `X_i in M`. `Delta(Gamma(U X_i))` lies in `Fix(Gamma)` by `thm:invariance` and contains
  every `X_i = Delta(X_i)` by monotonicity of `Delta`, hence contains `Gamma(U X_i)`; and
  `Delta` is deflationary, so `Delta(Gamma(U X_i)) = Gamma(U X_i)`. Thus
  `Gamma(U X_i) in M` and it is plainly least in `M` above all `X_i`. (This is the same
  computation as the one inside Tarski's proof quoted above, specialised.) **Consequence:
  `M` is closed under `oplus`.** That does not contradict `thm:noncong`, which concerns
  `Adm = M cap Haz^c` - the prohibitions are what break it, consistent with
  `prop:twoeffects`.
- **Meet in `M` is `D(intersection)`, not intersection.** `n X_i in Fix(Gamma)` (Moore
  family); `D(n X_i) in Fix(Gamma)` by invariance and `in Fix(Delta)` by idempotence; it is
  below `n X_i`; and any `Y in M` with `Y subseteq n X_i` satisfies
  `Y = D(Y) subseteq D(n X_i)`. So it is the greatest lower bound. It equals `n X_i` iff
  the intersection is already `Delta`-fixed, which `algebra/reports/OP-ORD.md` already
  refutes with the witness `{Cp,Fl} cap {Cl,Fl} = {Fl}`, `Fl` dependent with all consumers
  gone.

Recommendation: replace Open Problem 1 with the two formulas above; they are three-line
proofs from `thm:invariance` plus `prop:repair`, and they say strictly more than
`cor:tarski` does.

**Second recommendation.** `cor:tarski` currently reads as though Tarski is doing the work
in step 1. It is cleaner and more honest to say `Fix(Gamma)` is a complete lattice *because
`Gamma` is a closure operator* (Moore family; item 2 below), and to invoke Tarski only for
the second application, where `Delta` is not a closure operator and the Moore-family route
is unavailable.

---

## 2. Moore families / closure systems - supports `prop:moore`

`prop:moore` is standard and correctly stated, including the parenthetical "Neither
conclusion requires idempotence of the generating operator" - for an inflationary monotone
`Gamma`, `X, Y` fixed implies `Gamma(X cap Y) subseteq Gamma(X) cap Gamma(Y) = X cap Y` and
`X cap Y subseteq Gamma(X cap Y)`, no idempotence used; dually for deflationary `Delta` and
union.

Standard citations, in the order a referee will expect them:

- E. H. Moore, *Introduction to a Form of General Analysis*, AMS Colloquium Publications
  vol. 2, Yale University Press, 1910 - origin of "Moore family" (a family of subsets of a
  set closed under arbitrary intersection and containing the whole set).
- Garrett Birkhoff, *Lattice Theory*, AMS Colloquium Publications vol. 25; 1st ed. 1940,
  3rd ed. 1967, Ch. V - the closure-operator / Moore-family bijection. **Not obtained**;
  cite by chapter, not by theorem number, unless a copy is checked.
- Oystein Ore, "Some studies on closure relations", *Duke Math. J.* **10** (1943) 761-785;
  "Combinations of closure relations", *Ann. of Math.* **44** (1943) 514-533; "Galois
  connexions", *Trans. Amer. Math. Soc.* **55** (1944) 493-513. **Not obtained.**
- Nathalie Caspard & Bernard Monjardet, "The lattices of closure systems, closure operators
  and implicational systems on a finite set: a survey", *Discrete Applied Mathematics*
  **127** (2003) 241-269, doi:10.1016/S0166-218X(02)00209-3 (+ Erratum, DAM **147** (2005),
  doi:10.1016/S0166-218X(04)00238-0). **Not obtained** - the record exists in HAL with no
  full text, and no OA copy was located. This is the right single citation for the whole
  Moore-family / interior-system / implicational-system package and is worth chasing.

For the *interior system* (dual) half, note the paper's term "co-Moore family" is
nonstandard; the literature says **interior system**, **kernel system**, or **dual closure
system**, and the operator is a **kernel operator** or **interior operator** (co-closure).
Recommend using "interior system" in the paper and glossing it once.

An obtained, quotable source for the closure-space definition is
`armstrong2009_sortingorder.txt` (Sec. 2.1.2):

> Conversely, every closure operator arises in this way. That is, if we are given a map
> `tau` satisfying the above properties, then `C` is the collection of sets satisfying
> `tau(A) = A` - called the `tau`-closed sets.

**Verdict: supports `prop:moore`.** No hypothesis problem. Only a terminology fix.

---

## 3. Meet-distributive lattices and convex geometries - **`conj:convex` is not a conjecture; it is a corollary of P2, and the distributivity and anti-exchange measurements are the same fact**

This is the highest-value item and the answer is sharper than the brief anticipated.

### The literature

**Dilworth 1940.** R. P. Dilworth, "Lattices with unique irreducible decompositions",
*Annals of Mathematics* **41** (1940) 771-777. **Not obtained (JSTOR).** Verbatim
restatement, from `armstrong2009_sortingorder.txt` (Theorem 2.7, attributed there to
Adaricheva-Gorbunov-Tumanov, *Adv. Math.* **173** (2003), Theorems 1.7 and 1.9):

> Theorem 2.7. Given a finite lattice `(P, <=)`, the following statements are equivalent.
>  1. Every atomic interval in `P` is boolean.
>  2. Every element of `P` has a unique irredundant decomposition as a meet of
>     meet-irreducible elements.
>  3. `P` is upper-semimodular and it satisfies the meet-semidistributive property: for all
>     `x, y, z in P`, we have `x ^ y = x ^ z  ==>  x ^ y = x ^ (y v z)`.
>
> These lattices were first considered by Dilworth [4], for whom condition 2 was the
> defining property.

**Edelman 1980.** Paul H. Edelman, "Meet-distributive lattices and the anti-exchange
closure", *Algebra Universalis* **10** (1980) 290-299, doi:10.1007/BF02482912. **Not
obtained (Springer paywall; OpenAlex reports no OA location).** Verbatim restatement, same
file, immediately after the above:

> Theorem 2.8. [5, Theorem 3.3] A finite lattice is join-distributive if and only if it
> occurs as the lattice of open sets of an anti-exchange closure.
>
> [footnote 1] Edelman [5] used the term meet-distributive for the lattice of closed sets.

Independent second witness, `muhle2019_meetdistributive.txt`:

> Theorem 2.2. A finite lattice is meet distributive if and only if it is join
> semidistributive and lower semimodular.
>
> Meet-distributive lattices are precisely the lattices that arise from a closure operator
> satisfying the so-called anti-exchange property.

And the anti-exchange axiom itself, verbatim from `armstrong2009_sortingorder.txt`:

> If `x, y not-in tau(A)` then `x in tau(A u {y})` implies `y not-in tau(A u {x})`,
> ... In this case we say that `tau` is a convex closure and that `(E, C, tau)` is an
> abstract convex geometry - or just a convex geometry.

This matches `atlas.tex`'s definition of anti-exchange exactly (the paper says "for every
closed `A` and distinct `x, y not-in A`"; Edelman/Armstrong say `x, y not-in tau(A)`, which
for closed `A` is the same condition - no discrepancy).

**Terminology trap to record in the paper.** *Meet-distributive* is Edelman's term for the
lattice of **closed** sets; *join-distributive* is the same class read on the **open** sets
(the antimatroid's feasible sets). Armstrong states the theorem in the join-distributive /
open-set form and flags the clash in a footnote. If `atlas.tex` cites "Edelman 1980, Thm
3.3" it must say which side it means. The paper's objects are `Fix(Cn)` - **closed** sets -
so the correct word is **meet-distributive**.

**Edelman & Jamison 1985.** P. H. Edelman & R. E. Jamison, "The theory of convex
geometries", *Geometriae Dedicata* **19** (1985) 247-270. Not obtained; cited correctly in
`cospanning_antimatroids.txt` ref [2]. Use for the convex-geometry/antimatroid duality and
for extreme points; the duality is also stated verbatim in
`armstrong2009_sortingorder.txt` Lemma 2.5:

> Given an accessible set system `(E, F)` on finite ground set `E`, let
> `F^c = {E \ A : A in F}` ... Then `(E, F)` is an antimatroid if and only if `(E, F^c)` is
> a convex geometry.

### Are distributivity and anti-exchange the same fact here? **Yes - and both are already implied by a result the project has proved.**

In general they are *not* the same: distributive `==>` meet-distributive `==>` anti-exchange
closure, and the first implication is strict. A meet-distributive lattice need not be
distributive.

But on the fragment in question the two coincide, and both are consequences of
`algebra/THEOREM-LEDGER.md` **P2**:

> The definite fragment (8 laws) has height 1 - bodies and heads disjoint - so `Cn` is a
> one-pass Galois closure and closed sets are exactly the up-sets of a 54-point poset: a
> completely distributive lattice with `join = Cn(union)`, `meet = intersection`.

`atlas.tex` `meas:invariance` confirms the same operator ("the height-one definite closure
`Cn` over 58 elements").

1. *Distributivity is Birkhoff, not a measurement.* The up-sets of a finite poset form a
   distributive lattice, and every finite distributive lattice arises this way (Birkhoff's
   representation theorem, 1937). Once P2 says "closed sets are exactly the up-sets of a
   54-point poset", distributivity is not evidence about `Cn`, it is a restatement of P2.
   `formal/v2/FINDINGS-V2.md` line 129 already concedes this ("This was never in doubt:
   up-sets of *any* finite poset form a completely distributive lattice").

2. *Anti-exchange is a two-line theorem, not a conjecture.* Let `<=` be the partial order of
   P2 (a partial order because the requirement relation is a DAG - `THEOREM-LEDGER` P4), so
   `Cn(A) = up-closure of A`. Let `A` be closed and `x != y` with `x, y not-in A`. If
   `x in Cn(A u {y}) = A u up(y)` and `x not-in A`, then `y <= x`. If also
   `y in Cn(A u {x}) = A u up(x)`, then `x <= y`. Antisymmetry gives `x = y`, contradiction.
   Hence anti-exchange holds - at *every* instance, not just the 22,585 tested. So
   `conj:convex` should be promoted to a proposition with this proof, and
   `meas:antiexchange` ("Violations: zero") becomes a confirmation of P2 rather than
   independent evidence for a new structure.

3. *Unique minimal generators likewise.* `meas:unique` (1,696/1,696) is the standard
   `ex(A) =` minimal elements of the up-set `A`, again immediate from P2.

4. *So the two measurements are not independent.* Distributivity on this fragment and
   anti-exchange on this fragment are two readings of the same structural fact: the
   fragment is the **order / poset convex geometry** of a 54-point poset - the canonical
   example, sometimes called the *shelling* antimatroid of a poset. Presenting them as
   converging evidence overstates the case. What *is* genuinely informative is that this
   convex geometry is distributive, which by Birkhoff + Edelman pins it down completely:
   among convex geometries, the distributive ones are exactly the poset ones.

**Verdict: the literature supports the mathematics but undermines the framing.** The
convex-geometry section should be rewritten as a derivation from P2, not as a conjecture
supported by measurement. The one thing that *stays* a real open problem is the composition
question at the end of the section (`ex(A oplus B)` from `ex(A)`, `ex(B)`) - and note that
for the poset convex geometry it has an easy answer (`ex(A oplus B) =` the minimal elements
of `ex(A) u ex(B)` under `<=`), which is worth checking before it is advertised as open.

**Complexity caveat worth citing**, `bichoupan2022_implbases_convexgeom.txt`
(arXiv:2211.08524):

> The problem of finding an optimum basis for a convex geometry is shown to be NP-hard by
> establishing a reduction from the minimum cardinality generator problem for general
> closure systems. ... the problem of determining if an implication basis defines a convex
> geometry is shown to be co-NP-complete.

So "is this closure system a convex geometry" is co-NP-complete *in general*; the paper gets
it for free only because P2 hands it the poset representation.

---

## 4. Schaefer 1978 and Post's lattice - **`thm:polarity`'s mathematics is right; its attribution is wrong**

**Full citation.** Thomas J. Schaefer, "The complexity of satisfiability problems", *Proc.
10th ACM Symposium on Theory of Computing (STOC '78)*, pp. 216-226,
doi:10.1145/800133.804350.

**Schaefer's definitions, verbatim** (`schaefer1978.txt`, p. 217):

> The logical relation `R` is weakly positive (resp. weakly negative) if `R(x1, ...)` is
> logically equivalent to some CNF formula having at most one negated (resp. unnegated)
> variable in each conjunct.

So *weakly positive* = **dual-Horn** and *weakly negative* = **Horn**, matching the paper's
usage. Good.

**Schaefer's actual characterisation of these classes, verbatim** (Lemma 3.1W, p. 220):

> Lemma 3.1W. Let `R` be a logical relation and let `A := R(x1, ...)`. Then (a) `R` is
> weakly positive if and only if whenever `V subseteq Var(A)` is 0-consistent and 0-closed
> for `A`, `K_{0,V} in Sat(A)`; and (b) `R` is weakly negative if and only if whenever
> `V subseteq Var(A)` is 1-consistent and 1-closed for `A`, `K_{1,V} in Sat(A)`.

where (p. 220) `Cl_{i,A}(V)` is "the set of variables which are forced to be false (resp.
true) by all variables of `V` being false (resp. true)".

**This is not the union/intersection-closure characterisation.** Schaefer characterises
weakly positive / weakly negative relations by a *forced-closure* condition on variable
sets, not by closure of `Sat(A)` under componentwise `v` / `^`. The only place Schaefer
states a componentwise-operation closure condition is for the *bijunctive* case, in the Note
at the end of Sec. 3, verbatim:

> Note. Condition (b) of Lemma 3.1B can also be expressed in the following pleasantly
> symmetric form:
> (b') For all `s1, s2, s3 in Sat(A)`, `(s1 v s2) ^ (s2 v s3) ^ (s3 v s1) in Sat(A)`.

i.e. closure under the **majority** operation - the median/bijunctive fact, which is what
`meas:arity` in `atlas.tex` is actually about. Schaefer gives **no** "`R` weakly negative
iff `Sat(R)` closed under `^`" statement anywhere in the paper, nor does he derive it as a
corollary.

**Post 1941 is also the wrong citation.** Emil L. Post, *The Two-Valued Iterative Systems of
Mathematical Logic*, Annals of Mathematics Studies 5, Princeton, 1941, classifies clones of
Boolean **functions** under composition. It says nothing directly about closure properties
of **relations**. Schaefer himself is explicit about the relationship
(`schaefer1978.txt`, "Relation to Earlier Work", p. 217):

> The work presented here is similar in spirit to the classification by Post [P] of the sets
> of logical functions that are closed under functional composition. ... But the generating
> operations are quite different, and to the best of our knowledge, none of the particulars
> of Post's proof carry over to this work.

**Correct attribution for the algebraic half.** The bridge from Post's function clones to
closure properties of relation classes is the **Pol/Inv Galois connection**:

- David Geiger, "Closed systems of functions and predicates", *Pacific J. Math.* **27**
  (1968) 95-100 (obtained: `geiger1968.pdf`). Abstract, verbatim:
  > In this paper we show that there is a one to one correspondence between systems of
  > functions defined on a finite set `A` and systems of predicates defined on `A`. ...
  > functions on `A` provide a complete system of invariants for sets of predicates closed
  > under conjunction, change of variable and application of the existential quantifier.

  and from Sec. 1: "In Theorems 1 and 2 of Sec. 3 we show that the correspondence is a
  Galois connection."
- V. G. Bodnarchuk, L. A. Kaluzhnin, V. N. Kotov, B. A. Romov, "Galois theory for Post
  algebras I-II", *Kibernetika* **3** (1969) 1-10 and **5** (1969) 1-9 (English transl.
  *Cybernetics* **5**) - the independent discovery. **Not obtained.**
- For the Boolean case specialised and tabulated (the co-clone lattice: `Inv(^) =` Horn,
  `Inv(v) =` dual-Horn, `Inv(maj) =` bijunctive, `Inv(x+y+z) =` affine): E. Bohler,
  N. Creignou, S. Reith, H. Vollmer, "Playing with Boolean blocks, part II: constraint
  satisfaction problems", *SIGACT News* **35** (2004) 22-35; companion Part I, *SIGACT News*
  **34** (2003) 38-52. **Not obtained** - the copy at the Hannover URL is now an HTML stub.
- For the purely propositional statement "a set of models is closed under intersection iff
  it is the model set of a Horn formula", the standard credits are A. Horn, "On sentences
  which are true of direct unions of algebras", *J. Symbolic Logic* **16** (1951) 14-21 (the
  easy direction / preservation), with the finite converse usually cited to R. Dechter &
  J. Pearl, "Structure identification in relational data", *Artificial Intelligence* **58**
  (1992) 237-270.

**Verdict on `thm:polarity`: the theorem is true and its proof sketch is sound, but the
citation is wrong on both names.** Two recommended fixes, in increasing order of honesty:

1. Minimal: the paper only uses the **easy** direction (dual-Horn clauses have union-closed
   model sets; Horn clauses have intersection-closed model sets). That is a one-line
   verification per clause and needs no citation at all. Say so, and drop Schaefer/Post from
   the proof of `thm:polarity`.
2. Better: keep a citation but move it. Cite Schaefer 1978 where it actually applies - the
   **dichotomy** and the bijunctive/majority characterisation (`meas:arity`, "not
   median-closed, though a 50% fragment is", which *is* Schaefer's Note (b') and should cite
   it by name). Cite **Geiger 1968** (and BKKR 1969) plus Post 1941 for the *converse*
   direction, "union-closed implies dual-Horn definable", if the paper ever needs it.

Note that `algebra/THEOREM-LEDGER.md` P1 carries the same misattribution ("Schaefer/Post
duality") and should be corrected in the same pass.

---

## 5. Duquenne-Guigues basis and implicational systems

**Full citation.** J.-L. Guigues & V. Duquenne, "Familles minimales d'implications
informatives resultant d'un tableau de donnees binaires", *Mathematiques et Sciences
Humaines* **95** (1986) 5-18. Obtained from numdam (`duquenne_guigues1986.pdf`).

**Caveat: the numdam scan's OCR mangles the notation.** In the extracted text the closure
operator `A''`, the arrows, and the set names come through as `A"`, `-+`, `2013~`, `~`, and
the displayed formulas in Propositions 1-3 and the Theorem are partly lost. The *prose* of
the Theorem (p. 16) is legible - every minimal subfamily inferring the implication family is
of the form `{A -> A'' ; A in Aleph}` where `Aleph` is a system of representatives of the
equivalence classes of minimal nodes, and its cardinality equals `|N_0|` - but **the
displayed formulas are not presented here as verbatim**, per the read-cleanly rule.

**Clean, readable modern statement**, from `lincbo_dg_basis.txt` (arXiv:2011.04928, Sec.
2.3):

> A set `P subseteq Y` of attributes is called a pseudo-intent if it satisfies the following
> conditions:
>  (i) it is not an intent, i.e. `P^{down up} != P`;
>  (ii) for all smaller pseudo-intents `P_0 subset P`, we have `P_0^{down up} subset P`.
>
> Theorem 1. Let `P` be a set of all pseudo-intents of `<X, Y, I>`. The set
> `{P => P^{down up} | P in P}` is a basis of `<X, Y, I>`. Additionally, it is a minimal
> basis in terms of the number of attribute implications.

and the closure-system-theoretic form, from `bichoupan2022_implbases_convexgeom.txt`:

> Theorem 1. If `<X, phi>` is a finite closure system, `sigma` is the associated saturation
> operator, and `Sigma` is an associated implication basis, then for every critical set `C`
> of `<X, phi>`, there is an implication `(A -> B) in Sigma` such that `sigma(A) = C`.
> Furthermore, for every finite closure system `<X, phi>`, the set
> `Sigma_C = {C -> phi(C) : C is a critical set of <X, phi>}`, called the canonical basis of
> `<X, phi>`, is a valid implication basis of `<X, phi>` and has minimal cardinality among
> all implication bases of `<X, phi>`.
>
> J.L. Guigues and V. Duquenne proved the statements of Theorem 1 in [7], and D. Maier gave
> a similar result in the context of relational databases [9]. M. Wild later connected
> Guigues and Duquenne's work to Maier's and made their results significantly more
> accessible in [11].

Companion citations named there: D. Maier, "Minimum covers in the relational database
model", *J. ACM* **27** (1980) 664-674; M. Wild, "A theory of finite closure spaces based on
implications", *Adv. Math.* **108** (1994) 118-139.

**What minimality does and does not mean.** The Duquenne-Guigues basis is minimum in the
*number* of implications. It is **not** minimum in total size; a basis minimising the sum of
left- and right-hand-side cardinalities is an *optimum* basis, and
`bichoupan2022_implbases_convexgeom.txt` records both that optimum bases are shortenings of
the canonical basis and that finding one is NP-hard even for convex geometries:

> The problem of finding an optimum basis for a convex geometry is shown to be NP-hard by
> establishing a reduction from the minimum cardinality generator problem for general
> closure systems.

Further complexity references (not obtained, but correctly named): S. O. Kuznetsov, "On the
intractability of computing the Duquenne-Guigues base", *J. Universal Computer Science*
**10** (2004) 1265-1272; F. Distel & B. Sertkaya, "On the complexity of enumerating
pseudo-intents", *Discrete Applied Mathematics* **159** (2011) 450-466.

**Relevance to `atlas.tex`.** The paper does not currently cite this literature, but it
should: `meas:unique` (unique minimal generating sets) and the "canonical form for a
protocol" remark are exactly the FCA / implication-basis question, and on the definite
fragment `ex(A)` *is* a canonical basis in the strong sense. Conversely, the paper's Open
Problem 4 ("Is the generating set `El` minimal, and which elements are definable from the
rest?") is the minimum-basis problem, and the complexity results above say it is hard in
general.

---

## Summary of verdicts against `atlas.tex`

| claim in `atlas.tex` | verdict |
|---|---|
| `cor:tarski` | **Supported. Argument complete.** Monotonicity of the restricted map is automatic, not a gap. But the corollary is weaker than the paper's own hypotheses allow: join in `Fix(Gamma) cap Fix(Delta)` is `Gamma(union)` and meet is `Delta^omega(intersection)`, both provable in three lines. Open Problem 1 should be closed. |
| `thm:invariance` | Not a literature question; the proof in the paper is self-contained and reads correctly. It is what discharges Tarski hypothesis (ii). |
| `prop:moore` | **Supported.** Standard (Moore 1910 / Birkhoff / Ore). Terminology fix: "co-Moore family" -> **interior system**; `Delta^omega` is a **kernel / interior operator**. |
| `thm:polarity` | **Mathematics supported; attribution wrong.** Schaefer 1978 does not state the union/intersection-closure characterisation (his Lemma 3.1W uses 0/1-closed variable sets; his only componentwise-closure statement is the *majority* condition for bijunctive). Post 1941 is about function clones. Correct sources: **Geiger 1968** / BKKR 1969 Pol-Inv Galois connection, plus Post 1941 only via that bridge; or drop the citation, since only the trivial direction is used. `THEOREM-LEDGER` P1 has the same error. |
| `meas:arity` (bijunctive / median) | **This** is where Schaefer belongs - cite the Note after Lemma 3.1B, condition (b'). |
| `conj:convex` | **Undermined as a conjecture - it is a theorem.** Follows in two lines from `THEOREM-LEDGER` P2 (closed sets = up-sets of a 54-point poset) plus P4 (DAG, hence antisymmetry). Promote it. |
| `meas:antiexchange`, `meas:unique` | **Not independent evidence.** Both are consequences of P2. So is the distributivity of the fragment (Birkhoff representation). Distributivity and anti-exchange are the *same fact* here; in general distributive `=>` meet-distributive `=>` anti-exchange, strictly. |
| convex-geometry / antimatroid duality remark | **Supported** (Edelman-Jamison 1985; verbatim restatement in `armstrong2009_sortingorder.txt` Lemma 2.5). Terminology: the paper's objects are closed sets, so say **meet-distributive**, not join-distributive. |
