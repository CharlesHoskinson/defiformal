# CFP-2 — Clutters, blockers, and the minimal repair

Lane brief: clutter/blocker duality, hypergraph dualization, minimal hitting sets and
model-based diagnosis, ideal clutters/MFMC, the union-closed pairing, and antimatroids —
judged against `REQUIREMENTS.md` R1–R10 (including the newly added **R1b**).

Discovery was **API-only** (arXiv Atom API, Crossref REST, DBLP REST, direct page fetch via
`scrapling extract get --ai-targeted`). No WebSearch was used. DBLP intermittently returned
HTTP 500; Semantic Scholar returned HTTP 429 on every call. All bibliographic facts below
were resolved through Crossref DOIs or a primary source that names the reference explicitly.

Everything labelled **MEASURED** was computed this session against
`/root/DefiElements/algebra/solvers/GP-LOG/model.mjs` by two probe scripts
(`clutter_probe.mjs`, `clutter_probe2.mjs`, in this scratchpad). Nothing is asserted from
memory that could be run.

---

## 0. Executive answer

**Yes — blocker duality gives us the minimal repair, exactly and by definition, and it is the
first thing in this whole programme that answers R8's third question.** It also survives R1b
intact, because the blocker is defined on a ground set with no reference to `⊥` or to any
lattice at all.

But three things must be said first, and they are not comfortable.

1. **Our 20 hazard rows are not a clutter over elements.** They are 20 English sentences.
   In the executable model, exactly **one** (X2) is a positive element-set condition; the
   model then hard-codes two more from `FINDINGS.md` (XL1, XL2). Nine of the twenty name
   *zero* elements. Five name one. One pair (`X11a ⊃ X11b`) violates the antichain condition
   in its named-symbol projection. Several — `X11a`, `X19` — are not prohibitions at all once
   you read the polarity: "`Uc` with no `Aw`, `At`, …" is the *requirement*
   `Uc → Aw ∨ At ∨ …`. **The enforced positive hazard clutter has three members, not twenty.**
2. On those three members the machinery is exact, cheap and verified end to end.
3. The two repair questions R1b splits out (removal vs addition) are **not two objects.**
   They are the two clutter minors of the same clutter, exchanged by the blocker. That is a
   theorem (Seymour 1976), and I confirmed it computationally on our own data. **One
   algorithm, two queries.**

---

## 1. Clutter / blocker duality — the exact statement

### 1.1 Definitions (primary wording)

Taken verbatim in substance from the preliminaries of Abdi, Cornuéjols & Superdock,
*Clean tangled clutters, simplices, and projective geometries* (arXiv:1908.10629), read via
ar5iv HTML so the notation survived extraction:

> A **clutter** is a family `𝒞` of subsets of a finite set `V` where no set contains another
> one [Edmonds–Fulkerson 1970]. We refer to `V` as the **ground set**, to the elements in `V`
> simply as **elements**, and to the sets in `𝒞` as **members**. A **transversal** is any
> subset of `V` that intersects every member *exactly once*, whereas a **cover** is any subset
> of `V` that intersects every member *at least once*. A cover is **minimal** if it does not
> contain another cover. The family of the minimal covers of `𝒞` forms another clutter over
> ground set `V`; this clutter is called the **blocker of `𝒞`** and is denoted `b(𝒞)`.

⚠ **Terminology trap, flag it in any write-up.** In this (polyhedral / combinatorial-optimization)
tradition a *transversal* meets each member **exactly once**; the object we want is a **cover**.
In the AI / hypergraph-dualization tradition (Eiter–Gottlob, Berge) "transversal" means
*hitting set* = **at least once**, i.e. what Abdi et al. call a cover. The two literatures use
the same word for different things. Our blocker is built from **covers**, i.e. hitting sets.

### 1.2 The duality theorem

> **Theorem (Edmonds–Fulkerson / Isbell).** For every clutter `𝒞`, `b(b(𝒞)) = 𝒞`.

**Attribution, corrected.** The popular attribution is Edmonds & Fulkerson alone. Abdi–Cornuéjols–
Superdock cite it to **two** sources jointly:

- J. Edmonds and D. R. Fulkerson, *Bottleneck extrema*, **J. Combinatorial Theory 8 (1970)
  299–306**. DOI `10.1016/S0021-9800(70)80083-7`. (Crossref-confirmed. There is an earlier RAND
  memorandum of the same title, 1968, DOI `10.7249/rm5375`.)
- J. R. Isbell, *A class of simple games*, **Duke Math. J. 25 (1958) 423–439** — the same
  involution discovered in the theory of simple games, where `b(𝒞)` is the family of minimal
  blocking coalitions.

The polyhedral form is **D. R. Fulkerson, *Blocking polyhedra*** (Graph Theory and its
Applications, Academic Press, 1970, pp. 93–112). Seymour's contribution is *not* the duality
theorem — it is the **minor theory** (§1.3) and the MFMC characterisation (§4). Getting that
right matters: citing Seymour for `b(b(𝒞)) = 𝒞` is wrong.

### 1.3 Minors, and the identity that does all our work

> Given disjoint `I, J ⊆ V`, the **minor** of `𝒞` obtained after **deleting `I`** and
> **contracting `J`** is the clutter `𝒞 \ I / J` over ground set `V − (I ∪ J)` whose members
> are the inclusion-wise minimal sets in `{ C − J : C ∈ 𝒞, C ∩ I = ∅ }`.
>
> **Theorem (Seymour).** `b(𝒞 \ I / J) = b(𝒞) / I \ J`.

Seymour, *The forbidden minors of binary clutters*, **J. London Math. Soc. (2) 12 (1975/76)
356–360**, DOI `10.1112/jlms/s2-12.3.356`. Note the **swap**: blocking turns deletion into
contraction and back. This is the load-bearing fact for R1b, see §1.5.

### 1.4 What the blocker *is*, for us — MEASURED

The three positive element-level hazards actually enforced by `admissible()`:

```
XL1 = {Fl, Xm}
XL2 = {Fl, Au, Rl}
X2  = {Fl, Cp, Cl, Pl, Cd}
```

**These do form a genuine clutter** (antichain — verified). Ground set of the clutter: 8
elements. Computed by brute force:

```
b(H) = { {Fl},
         {Xm,Au,Cp}, {Xm,Au,Cl}, {Xm,Au,Pl}, {Xm,Au,Cd},
         {Xm,Rl,Cp}, {Xm,Rl,Cl}, {Xm,Rl,Pl}, {Xm,Rl,Cd} }      |b(H)| = 9
b(b(H)) = H                                                      ✅ verified
b(H \ e) = b(H) / e  and  b(H / e) = b(H) \ e   for all 8 e      ✅ verified
```

Read the answer in English: **either drop atomic flash liquidity `Fl` outright, or — if you
must keep it — drop the cross-domain mint `Xm` together with one of {`Au`, `Rl`} and one of
{`Cp`, `Cl`, `Pl`, `Cd`}.** That is a minimal repair menu, it is complete, and it is nine rows
long. We could not produce this before.

**A second thing falls out free, and it is arguably worth more.** MEASURED:

```
maximal hazard-free sets  =  { E \ B : B ∈ b(H) }        9 = 9, exact match ✅
```

The maximal hazard-free protocols *are* the complements of the minimal blockers. So the same
one computation answers both "what is the minimal thing I must give up" and "what is the
largest safe protocol containing what I have". This is the Stanley–Reisner / Alexander-duality
picture of §5 in concrete form.

### 1.5 R1b: is blocker duality sensitive to the ambient lattice?

**No. Not at all. This is the genuine advantage the coordinator suspected, and it is stronger
than suspected.**

`b(𝒞)` is defined by a ground set and an incidence condition. There is no `⊥`, no `⊤`, no
order-theoretic starting point, nothing to collapse. The R1b failure mode — KK pinned at
`(⊥, ⊤)` because `∅` is admissible and `Adm` spans the atoms — **cannot arise**, because the
blocker never evaluates anything at `∅`. `∅` is a member of no clutter (it would contain and be
contained by everything) and the algorithm never visits it.

Restricting attention to the interval `[S, ⊤]` is **exactly a minor operation**, and it is
*not even a sub-clutter problem* — it is cleaner than that:

| R1b query | clutter operation | what you compute |
|---|---|---|
| **(b) minimal removals** from `S` that clear all armed hazards | **deletion**: `H \ (E∖S)` (keep only members entirely inside `S`) | `b(H \ (E∖S))` = `b(H) / (E∖S)` |
| **(a) minimal forbidden additions** to `S` on `[S,⊤]` | **contraction**: `H / S` (strip `S` off every member, minimalize) | `H / S` **directly** — no blocker needed |

Both **MEASURED** against brute force:

```
S = {Fl,Xm,Au,Rl,Cp,Cl,Pl,Cd}
  minimal removals            = {Fl} | {Au,Cp,Xm} | {Cp,Rl,Xm} | {Au,Cl,Xm} | {Cl,Rl,Xm}
                                | {Au,Pl,Xm} | {Pl,Rl,Xm} | {Au,Cd,Xm} | {Cd,Rl,Xm}
  == b(deletion minor)?       ✅ true

seed {Fl}     : H/S = Xm | {Au,Rl} | {Cd,Cl,Cp,Pl}   == direct minimal forbidden additions ✅
seed {Fl,Xm}  : H/S = ∅  (already armed — nothing left to forbid)                          ✅
seed {Au,Fl}  : H/S = Xm | Rl | {Cd,Cl,Cp,Pl}                                              ✅
seed {Au,Xm}  : H/S = Fl                                                                    ✅
```

**Answer to the coordinator's question 2: they are one object, not two.** Removal-repair is the
blocker of a **deletion** minor; addition-exclusion is a **contraction** minor. Seymour's
identity `b(𝒞\I/J) = b(𝒞)/I\J` says these are the same clutter seen through the blocker
involution. **Ship one algorithm** — compute `b(H)` once, then take minors of `H` and `b(H)`
per query. Both minor operations are `O(|H| · |E|)`; only the initial `b(H)` is potentially
expensive, and it is computed once, offline, and cached.

**Caveat, and it is real.** This covers the *hazard* half only. A full repair must also
restore closure over the requirements, and adding a witness element can arm a new hazard (R3,
non-monotone). So `minimal repair = (R, A)` with `(S∖R) ∪ A` admissible, and only `R` is a
blocker computation. `A` is a completion problem (NP-complete, R6). The honest claim is:
**blocker duality solves the prohibition half of R8's third question exactly, and reduces the
requirement half to the completion problem we already have.**

---

## 2. Computation: dualization, hardness, and what actually runs

### 2.1 The problem and its aliases

Computing `b(𝒞)` is, under different names in different literatures, the *same* problem:
hypergraph transversal / **transversal hypergraph** generation, **minimal hitting set (MHS)
enumeration**, minimal set-cover enumeration, and **monotone dualization** (prime CNF ↔ prime
DNF for a monotone Boolean function). Eiter, Gottlob & Makino established that the decision,
enumeration and exact-learning formulations are **mutually polynomially reducible in combined
input+output size** — solve any one in polytime and you solve them all.

- T. Eiter, G. Gottlob, *Identifying the minimal transversals of a hypergraph and related
  problems*, **SIAM J. Comput. 24 (1995) 1278–1304**, DOI `10.1137/S0097539793250299`.
- T. Eiter, K. Makino, G. Gottlob, *Computational aspects of monotone dualization: a brief
  survey*, **Discrete Appl. Math. 156 (2008) 2035–2049**, DOI `10.1016/j.dam.2007.04.017`.
  **This is the survey to read.**
- T. Eiter, G. Gottlob, K. Makino, *New results on monotone dualization and generating
  hypergraph transversals*, **STOC 2002**, 14–22, DOI `10.1145/509907.509912`.

### 2.2 Fredman–Khachiyan

- M. L. Fredman, L. Khachiyan, *On the complexity of dualization of monotone disjunctive
  normal forms*, **J. Algorithms 21 (1996) 618–628** (DBLP-confirmed; J. Algorithms 21(3)).

They give **two** algorithms, both for the *decision* problem "are these two prime forms
dual?", both convertible to enumeration. Both clean the instance, then branch on a variable
guaranteed (by a counting argument: with `m` clauses, some clause has ≤ `log₂ m` variables, so
one of its variables occurs in ≥ a `1/log₂ m` fraction of the other side) to occur in many
clauses.

- **FK-A** runs in time exponential in `(log n)³`.
- **FK-B** runs in time exponential in `(log n)²` — i.e. roughly `n^{O(log n)}`,
  **quasi-polynomial** in combined input+output size.

⚠ The sharper published form of the FK-B bound is usually quoted as `N^{o(log N)}` (with the
exponent `4χ(N)+O(1)`, `χ(N)^{χ(N)} = N`). I could **not** read that exponent cleanly from a
primary source this session — extraction stripped the notation and I did not fall back to a
screenshot. Treat the `(log n)²`/`(log n)³` statement as the verified one and re-check the
`4χ(N)` form before printing it.

### 2.3 Hardness — the honest answer to "is it NP-hard?"

**No, and that is the famous part.**

- The **decision** problem (is `g` the dual of `f`?) is in **coNP**, and is solvable in
  quasi-polynomial time — so it is **not coNP-complete unless every problem in coNP has a
  quasi-polynomial algorithm**. It is one of the very few natural problems sitting in the gap
  between P and NP-complete without a known classification.
- The **enumeration** problem is not known to admit an output-polynomial algorithm, and not
  known not to.
- *Unsolved problem in computer science: is it possible to test whether two prime CNF
  expressions represent dual functions in polynomial time?* — still open as of the current
  Wikipedia survey article, which sources this to Eiter–Makino–Gottlob 2008.
- Output size is genuinely the enemy, independent of hardness: an `n`-vertex graph of
  `n/3` disjoint triangles has `3^{n/3}` transversal hyperedges.

**Known polynomial special cases that we plausibly land in:** bounded occurrence of each
variable in clauses; bounded-degree / *uniformly sparse* hypergraphs; bounded generalised
treewidth or degeneracy. Our hazard hypergraph is extremely sparse — measured
max member size 5, and `Fl` is the only high-degree element. If the promoted 20-row clutter
stays this sparse, we are in a tractable regime, not merely a small one.

### 2.4 What actually runs at our scale — and the honest cost

**Our scale is not "tiny" for the reason the brief assumes.** 20 rows over 58 elements is tiny
for *decision*, but blocker **output** is bounded above by `∏_{C∈H} |C|` (Berge). With 20 rows
of width ≤5 the pathological bound is `5²⁰ ≈ 9.5 × 10¹³`. What saves us is *overlap*, not size:
our three current rows all contain `Fl`, so `|b(H)| = 9`. **Do not promise "tiny" — promise
"measure it".** If a solver does not terminate in seconds, the answer set really is large and
that is information about the hazard model, not about the algorithm.

Recommended, in order:

1. **clingo v5.8.0** (R10-approved, already in the repo, verified live 2026-08-04). Encode the
   clutter as constraints and enumerate **subset-minimal** models. The standard clasp idiom is
   domain-heuristic enumeration (`--enum-mode=domRec` with `--heuristic=Domain
   --dom-mod=…`); an alternative is `asprin` with a subset-minimality preference.
   ⚠ I did **not** verify the exact flag spelling for 5.8.0 this session — check `clingo
   --help=3` before quoting it. This is the option that costs us zero new tooling and satisfies
   R10 outright.
2. **SHD v3.1** (Sparsity-based Hypergraph Dualization), Takeaki Uno, C. Live download at
   `https://research.nii.ac.jp/~uno/dualization.html` (fetched successfully this session).
   Reported fastest on most instances in the authors' own experiments. `0` command = RS
   algorithm, `D` = DFS. Companion paper: K. Murakami, T. Uno, *Efficient algorithms for
   dualizing large-scale hypergraphs*, **Discrete Appl. Math. 170 (2014) 83–94**
   (also ALENEX 2013; arXiv:1102.3813).
3. **BEGK** (Boros–Elbassioni–Gurvich–Khachiyan), C, on the same page — an actual implementation
   of the quasi-polynomial FK-type algorithm. Use it only if the output is huge.
4. **`agdmhs` / MHSGenerationAlgorithms** — A. Gainer-Dewar, P. Vera-Licona, *The minimal
   hitting set generation problem: algorithms and computation*, **SIAM J. Discrete Math. 31
   (2017) 63–100**, DOI `10.1137/15M1055024`. Benchmark suite + parallel implementations
   (MMCS, RS, …) with a common interface; repo exists at
   `github.com/VeraLiconaResearchGroup/MHSGenerationAlgorithms` (page loaded; I did not check
   last-commit date, so **do not claim it is maintained** — that is an R10 gap).
5. For a *single cheapest* repair rather than all of them: **MaxSAT/RC2 via PySAT**, or clingo
   `#minimize`. Cardinality-minimum, not subset-minimal — different question, much cheaper.

Also worth knowing: **BDD-based transversal computation** (Toda, SEA 2013, DOI
`10.1007/978-3-642-38527-8_10`) — relevant if the answer set is large but structured.

---

## 3. The MHS framing and Reiter's theory of diagnosis

### 3.1 The correspondence

- R. Reiter, *A theory of diagnosis from first principles*, **Artif. Intell. 32 (1987) 57–95**,
  DOI `10.1016/0004-3702(87)90062-2`.
- **The algorithm in that paper is wrong**, and the correction is a separate, equally citable
  paper: R. Greiner, B. A. Smith, R. W. Wilkerson, *A correction to the algorithm in Reiter's
  theory of diagnosis*, **Artif. Intell. 41 (1989) 79–88**, DOI `10.1016/0004-3702(89)90079-9`.
  Reiter's HS-tree pruning is incomplete; GSW's **HS-DAG** repairs it. **Cite both or you have
  cited a bug.** This is the single most common citation error in this area.
- J. de Kleer, B. C. Williams, *Diagnosing multiple faults*, **Artif. Intell. 32 (1987) 97–130**,
  DOI `10.1016/0004-3702(87)90063-4` — GDE, the ATMS-based, probability-ordered sibling.

Reiter's structure:
- A **conflict set** is a set of components whose *simultaneous correct behaviour* is
  inconsistent with the observations. Minimal conflict sets form a clutter.
- A **diagnosis** is a minimal set of components whose assumed abnormality restores
  consistency.
- **Theorem (Reiter 1987).** `Δ` is a diagnosis iff `Δ` is a **minimal hitting set** of the
  collection of conflict sets. Equivalently: `diagnoses = b(minimal conflicts)`.

### 3.2 Is our correspondence exact?

**For the prohibition half, yes — it is literally the same theorem.** Substitute:

| Reiter | ours |
|---|---|
| component | element type |
| observation | the protocol's element set `S` |
| minimal conflict set | armed minimal hazard `C ∈ H`, `C ⊆ S` |
| diagnosis | minimal removal repair |
| `b(conflicts)` | `b(H \ (E∖S))` |

The identification is exact and gives us Reiter's whole apparatus for free.

**For the requirement half, no.** Reiter is **consistency-based**: a diagnosis is anything that
restores consistency, and abnormality is *unconstrained* — you never have to say what the
component does instead. Our requirements are **generative**: removing `Fl` may open `L15`,
which must then be closed by *adding* something. That is **abductive** diagnosis (find a cause
that *entails* the observation), not consistency-based. The classical separation is exactly
this, and it is the reason §1.5's `(R, A)` pair does not collapse to a single hitting set.

### 3.3 What diagnosis theory gives us for free

- **Minimality is definitional, not bolted on.** Diagnoses are minimal hitting sets; there is no
  separate "now filter the redundant repairs" pass. This directly serves R8.
- **Incremental conflict discovery.** Reiter/GSW compute conflicts *lazily*, calling a theorem
  prover only when the current candidate is not a diagnosis. We do not need all 20 hazard rows
  formalised up front — a huge win given that 9 of 20 name no elements. **This is the single
  most practically valuable import from this literature** and it directly answers the
  "Deliberately NOT required: total formalisation" clause of REQUIREMENTS.
- **Preference orders.** de Kleer & Williams add fault probabilities and rank diagnoses; the
  MHS structure is unchanged, only the traversal order. So "cheapest repair", "least invasive
  repair", "repair preserving the most live protocols" are all reorderings of one enumeration,
  not new algorithms.
- **Cardinality-bounded search.** Both HS-DAG and GDE cut off at `|Δ| ≤ k`. For us `k = 1, 2, 3`
  covers essentially every repair a user would act on, and bounded-`k` MHS is polynomial
  (`O(n^k · |H|)`) — no dualization hardness at all.
- **A ready algorithm with a published correction.** HS-DAG is ~200 lines and has been
  debugged in public for 37 years.

---

## 4. Ideal clutters and the MFMC property — elegant, and it gives us nothing

### 4.1 Definitions and results (all primary-anchored)

- **Ideal.** `𝒞` is **ideal** if the set covering polyhedron
  `{ x ∈ ℝ^V_+ : Σ_{v∈C} x_v ≥ 1 ∀ C ∈ 𝒞 }` is **integral**.
  (Cornuéjols & Novick, *Ideal 0,1 matrices*, JCTB 60 (1994) 145–157.)
- **`𝒞` is ideal ⟺ `b(𝒞)` is ideal.** (Fulkerson, *Blocking polyhedra*, 1970; Lehman, *On the
  width–length inequality*, **Math. Programming 16 (1979) 245–259**, DOI `10.1007/BF01582111`.
  There is a second Lehman paper of near-identical title, Math. Prog. 17 (1979) 403–417, DOI
  `10.1007/BF01588263` — check which you mean.)
- **Idealness is minor-closed.** (Seymour, *The matroids with the max-flow min-cut property*,
  **JCTB 23 (1977) 189–222**, DOI `10.1016/0095-8956(77)90031-4`.)
- **MFMC / packing property.** MFMC is the stronger, integer-programming-level property
  (`τ = ν` for all non-negative integer capacities). Seymour 1977 characterises the binary
  matroids with it. Cornuéjols, Guenin, Margot, *The packing property*, **Math. Program. 89
  (2000) 113–126**, separate the packing property from MFMC. Idealness ⊋ packing ⊋ MFMC in the
  usual containment direction; `τ = ν` fails for ideal clutters in general (Abdi, Pashkovich,
  Cornuéjols, *Ideal clutters that do not pack*, Math. OR 43 (2017) 533–553).
- **Excluded minors.** Lehman's theorem characterises minimally non-ideal clutters. The
  deltas and `𝕃₇` (the lines of the Fano plane) are the canonical non-ideal examples; `𝕃₇` is
  the only minimally non-ideal *binary* clutter with a member of size three. Seymour's
  **Flowing Conjecture** and the **`τ = 2` Conjecture** are the open problems here.
- **Survey:** Cornuéjols & Guenin, *Ideal clutters*, **Discrete Appl. Math. 123 (2002) 303–338**,
  DOI `10.1016/S0166-218X(01)00344-4`. Book: G. Cornuéjols, *Combinatorial Optimization:
  Packing and Covering*, SIAM CBMS-NSF vol. 74, 2001.

### 4.2 Is our hazard clutter ideal, and would it matter?

**It would not matter, so I did not spend the budget determining it.** Blunt assessment:

Idealness buys **LP relaxation integrality**. It says: solve `min Σ c_v x_v` over the covering
polyhedron as a *linear* program and the optimum is an integral minimum cover. That is worth
enormous amounts when your ground set has 10⁶ elements and you need one weighted-minimum cover
fast. We have **58 elements and a three-row clutter**. We compute the *entire* blocker by brute
force in milliseconds. **An LP we will never solve does not need to be integral.**

Two secondary observations, since they are cheap:

- Our `H` is trivially ideal on inspection: `Fl` lies in every member, so `τ(H) = 1`, and a
  clutter with a member of size one (`{Fl} ∈ b(H)`, so `Fl` covers everything) has the trivial
  covering polyhedron. Any clutter with `τ = 1` is ideal. This will stop being true the moment
  the other 17 hazards are formalised and stop all containing `Fl`.
- Idealness *is* minor-closed and blocker-invariant, which means it is the right property to
  **check once and then forget**. If the promoted 20-row clutter is ideal, every deletion and
  contraction minor we take in §1.5 is too, for free.

**Where this literature could earn its keep, later.** `τ` (minimum cover size) is exactly
**the size of the smallest repair**, and `ν` (maximum packing of disjoint members) is exactly
**the number of independent hazards you must repair separately**. `ν ≤ τ` always; `ν = τ`
(MFMC) would mean *every hazard can be repaired by a disjoint, independent fix* — a genuinely
meaningful engineering statement about our system ("no repair does double duty; no repair is
forced to compromise"). Measuring `ν` vs `τ` on the full promoted clutter is a **cheap,
interpretable diagnostic** and I would run it. But it is a *report*, not a *capability*.

---

## 5. Combining with the union-closed side — and the R7 explanation

### 5.1 The name of the object

There is a name for the hazard side alone, and it is exact:

> **The hazard-free family is an independence system = an abstract simplicial complex `Δ`,
> and `H` is precisely its clutter of minimal non-faces.**

Because hazards are *positive* (upward-closed: superset of a hazard is a hazard), hazard-free
sets are **downward-closed**, contain `∅`, and are therefore an independence system in the
textbook sense (`∅ ∈ ℱ`; `S ∈ ℱ ∧ T ⊆ S ⟹ T ∈ ℱ`). Wikipedia's own summary of the containments:
`HYPERGRAPHS ⊃ INDEPENDENCE-SYSTEMS = ABSTRACT-SIMPLICIAL-COMPLEXES ⊃ MATROIDS`.

This gives the **commutative-algebra reading**, which is where the free lunch lives: `H`
generates the **Stanley–Reisner ideal** `I_Δ`, and `b(H)` generates its **Alexander dual**.
The classical consequence is exactly what I measured in §1.4: **the facets of `Δ` are the
complements of the members of `b(H)`**. That correspondence is why "minimal repair" and
"maximal safe protocol" are the same computation.

⚠ I state the Stanley–Reisner/Alexander-dual framing from background knowledge; I did **not**
retrieve a primary citation for it this session. The *combinatorial* content (facets =
complements of minimal covers) I verified computationally, so the claim is safe; the
*attribution* is not yet sourced.

### 5.2 The combined object

`ADMISSIBLE = CLOSURE ∩ HAZARD-FREE` is:

> the intersection of a **union-closed family** (the models of a dual-Horn theory) with an
> **independence system** (the faces of a simplicial complex).

**There is no standard single name for that.** I looked and did not find one; I am reporting a
negative result rather than inventing a term. The nearest honest descriptions are:

- **Feature models** (already noted in `MODEL.md` §4b) — `requires` = dual-Horn, `excludes` =
  Horn. The structural fit is exact and there is a live tool ecosystem. This is the closest
  thing to a name.
- **"Independence system with generative obligations"** — descriptive, not standard.
- Do **not** call it a matroid, a greedoid, or an antimatroid. It is none of them (§6).

### 5.3 R7 — this pairing *does* explain the fragment pattern, and I measured it

R7 asks the foundation to *predict* that good behaviour is always a fragment. This pairing does,
and the prediction is now measured rather than asserted. Four grounds, exhaustive enumeration:

| ground (16 elements) | \|Adm\| | `∅` adm | accessible | **union-closed** | **∩-closed** |
|---|---|---|---|---|---|
| `Pl Im Cd Pf Op Uc Py Tr Xf Sb Sd In Ex Up Aw Au` | 64 | ✅ | ✅ 0 fail | ✅ | ✅ |
| `Op Uc Py Tr Xf Sb Sd In Ex Up Aw Au Xm Of Rl Gs` | 480 | ✅ | ✅ 0 fail | ✅ | ✅ |
| `Fl Xm Au Rl Cp Cl Pl Cd Fz Xf Aw Im Pf Op Ex Tp` | 656 | ✅ | ✅ 0 fail | ❌ | ✅ |
| `Pl Li Ad Sl Bs Fl Xm Au Rl Ct Im Sh Oa Uc Aw At` | 7040 | ✅ | ✅ 0 fail | ❌ | ❌ |

Counterexamples, and they are diagnostic:

- **union-closure breaks only via a hazard**: `{Fl} ∪ {Xm} = {Fl,Xm}` = XL1.
- **intersection-closure breaks only via a disjunctive requirement**:
  `{Li,Ct,Im,At} ∩ {Ad,Ct,Im,At} = {Ct,Im,At}`, inadmissible — the two sets discharge the same
  disjunctive obligation with *different* witnesses, and the intersection keeps neither.
  (This is GR-CAT's "not a Moore family" result, reproduced independently.)

**So the fragment pattern has a two-line explanation.** Positive prohibitions destroy
union-closure and nothing else. Disjunctive requirements destroy intersection-closure and
nothing else. Definite Horn productions destroy neither, which is why OP-LOG's distributive
lattice is real on that fragment (Birkhoff: a family both union- and intersection-closed and
accessible is the lattice of order ideals of a poset). **"Disjunctive width is always what
breaks it" is only half true** — disjunctive width breaks the ∩ side; *prohibition* breaks the
∪ side. R7's three measurements all happen to be on the ∪ side, which is why they looked like
one phenomenon. They are two.

---

## 6. Antimatroids and convex geometries — and the one real find

### 6.1 Definitions

Sources: Wikipedia *Antimatroid* (fetched), sourced throughout to **Korte, Lovász & Schrader,
*Greedoids*, Springer, Algorithms and Combinatorics 4, 1991**; originating with **R. P. Dilworth,
*Lattices with unique irreducible decompositions*, Ann. of Math. 41 (1940) 771**, DOI
`10.2307/1968857`; convex-geometry duality from **P. H. Edelman & R. E. Jamison, *The theory of
convex geometries*, Geom. Dedicata 19 (1985) 247–270**, DOI `10.1007/BF00149365`.

> An **antimatroid** is a finite family `ℱ` of finite sets (*feasible sets*) such that
> 1. `ℱ` is closed under **union**;
> 2. `ℱ` is **accessible**: if `S ∈ ℱ` is non-empty, there is `x ∈ S` with `S ∖ {x} ∈ ℱ`.
>
> Equivalently, as a **formal language**: a normal, hereditary language over the alphabet in
> which, if `S` and `T` are words and `T` contains a symbol not in `S`, then some `x ∈ T ∖ S`
> extends `S` to another word.
>
> **Antimatroids are equivalent, by complementation, to convex geometries.**

### 6.2 Do we satisfy accessibility? — MEASURED: **YES, everywhere I looked**

**8,240 admissible sets across four independent 16-element grounds. Zero inaccessible.**

This is the strongest positive structural result in this lane and I did not expect it.
Accessibility means:

> **Every admissible protocol can be built one element at a time from `∅`, staying admissible
> at every single step.**

That is precisely the unused "seating order" the brief asked about, and it holds **without
needing an antimatroid**. Accessibility alone gives the ladder; by induction, `S` accessible
implies a chain `∅ ⊂ S₁ ⊂ … ⊂ S` of admissible sets. Combined with R1b's mandate to reason on
`[S, ⊤]`, this says: **the completion lattice is always reachable from below by admissible
steps**, so the R1b query "given what I have, what may I add" always has a well-founded history
behind it.

**Proof sketch (not verified — offered as a conjecture with a reason).** R4 records that the
requirement relation is a **DAG with no self-loops**, with edges `subject → witness`. Let `S`
be admissible and non-empty, and let `x` be a **source of the sub-DAG induced on `S`** (exists
by acyclicity). Removing `x`: (i) it can only *unfire* laws it was the subject of, which
removes obligations; (ii) it cannot be the witness of any fired law, because witnesses are
strictly downstream of their subjects and `x` has no incoming edge within `S`; (iii) hazards
are upward-closed, so removal never arms one. Hence `S ∖ {x}` is admissible. **This should be
checked against the actual DAG orientation and against laws with external (non-element) terms
before being claimed.**

### 6.3 Are we an antimatroid? — **No.** Are we a convex geometry? — **No.**

Union-closure fails (§5.3), by the hazards. Convex geometries want intersection-closure *plus*
the anti-exchange property *plus* the top element `E`; we have intersection-closure only on
hazard-free, disjunction-free fragments, and `E` (all 58 elements) is certainly not admissible.
**Do not claim antimatroid.** We have exactly one of its two axioms.

### 6.4 What we would gain, and what we actually gain

| what antimatroids give | do we get it |
|---|---|
| A **feasible construction order** for every feasible set | **YES** — from accessibility alone |
| The construction orders form a **language closed under the exchange property** (so any partial build can be extended toward any target) | **NO** — needs union-closure |
| **Unique/canonical** minimal build order; confluence of greedy construction | **NO** |
| **Greedy optimality** for the associated optimisation problem | **NO** |
| Convex-geometry duality (closure operator with anti-exchange) | **NO** — and R1's diagonal argument would kill it anyway |

Blunt: antimatroids are the elegant theory that *nearly* fits and does not. But the half we do
have — accessibility — is the half with the actionable content, and it was free. The half we
lack is exactly the half that R2 already proved impossible.

---

## Verdict against REQUIREMENTS

| result | meets | fails | net |
|---|---|---|---|
| **Blocker duality `b(b(𝒞)) = 𝒞`** (§1) | **R8** (the third question, answered exactly, for the first time). **R9** — the clutter *is* the global-constraint construct; prohibitions are first-class objects with their own algebra, never pushed into per-element formulas. **R6** — decision linear, blocker enumeration output-sensitive and quasi-polynomial. **R1b** — the blocker never evaluates `⊥`; total immunity to the collapse. | **R4** — a flat element-set clutter cannot express `{Fl,Xm}` at *instance* level, which is exactly why GR-CAT withdrew four hazard promotions. A clutter over `(element, asset)` pairs is the fix and nobody has built it. **R5** — says nothing about composition. | **The strongest single result in this lane.** Ship it. |
| **Removal ≡ deletion minor; addition ≡ contraction minor; Seymour's `b(𝒞\I/J) = b(𝒞)/I\J`** (§1.5) | **R1b** decisively — one algorithm, both queries, no ambient lattice. **R8**, **R6** (both minor ops are `O(\|H\|·\|E\|)`). | **R3** — the addition side is only the *hazard* exclusion; adding a witness can arm a hazard, so full repair is `(R, A)` and `A` is still the NP-complete completion problem. | Answers the coordinator's question 2 cleanly: **one object, two minors.** |
| **Maximal hazard-free = complements of `b(H)`** (§1.4, measured) | **R8** — answers "what may I keep" from the same computation. | — | Free rider. Take it. |
| **Fredman–Khachiyan + tooling** (§2) | **R6** — complexity stated, quasi-polynomial, not PH-level. **R10** — clingo v5.8.0 does this natively; SHD 3.1 downloadable today; Uno's page live. | **R10 partial** — `agdmhs` maintenance unverified; the clingo subset-minimal flag spelling unverified. | Good. **But do not say "tiny"**: the Berge bound is `5²⁰` and only overlap saves us. Measure. |
| **Reiter's diagnosis ≡ MHS** (§3) | **R8** (minimality definitional). **R6** (bounded-`k` MHS is polynomial). **R10** — HS-DAG is trivially implementable and 37 years debugged. Plus: **incremental conflict discovery** means we need not formalise all 20 hazards first, which serves the explicit "no total formalisation" clause. | **R2/R3** — Reiter is *consistency-based*; our requirements are *generative/abductive*. The correspondence is exact on the prohibition half **only**. | Import the algorithm and the laziness. Do not oversell the correspondence. |
| **Ideal clutters / MFMC** (§4) | **R6** nominally (LP integrality). | **R5**, **R7**, **R8** — gives us nothing we need. Our clutter has `τ = 1` and is ideal for a trivial reason that will not survive formalising the other 17 rows. | **Elegant and useless at our scale.** The one thing worth measuring is `ν` vs `τ` as a *report*: does every hazard need its own independent repair? |
| **Independence system / simplicial complex pairing** (§5) | **R7 — the best answer anyone has produced.** Measured: prohibitions break `∪`-closure and nothing else; disjunctive requirements break `∩`-closure and nothing else; definite Horn breaks neither. Predicts the fragment pattern instead of tolerating it. **R2** — this *is* the polarity theorem, geometrised. | **R5** — no composition content. And there is **no standard name** for the combined object; feature models are the closest, and that is a modelling tradition, not a theorem. | Adopt as the R7 explanation. Correct the received wisdom: it is **not** "disjunctive width always breaks it" — that is only the `∩` side. |
| **Accessibility measured true** (§6.2) | **R8**, **R1b** — every admissible set has an admissible construction history; the completion lattice is reachable from below. This is the "seating order", and we already have it. | **R2** — union-closure fails, so no antimatroid, no exchange property, no canonical order, no greedy optimality. | The one genuine surprise. 8,240/8,240 accessible on four grounds. **Worth a corpus-scale re-run and a proof.** |
| **Our 20 hazards are not yet a clutter** (§0) | — | **R9 hard fail as of today.** 3 of 20 enforced, 9 name zero elements, `X11a ⊃ X11b`, several are requirements wearing a prohibition's clothes. | **This is the prerequisite for everything above.** The machinery is ready; the data is not. |

**Bottom line.** Blocker duality is the first candidate in this programme that passes R1b *by
construction* rather than by repair, answers R8's unanswered question exactly, and satisfies R9
as a matter of definition rather than encoding discipline. It fails R4 in the same way
everything else does (flat element sets), and it says nothing at all about R5. The blocker of a
promoted 20-row hazard clutter is the deliverable; **formalising those 20 rows into positive
element-level minimal forbidden sets — over `(element, asset)` pairs, not flat elements — is the
whole of the remaining work.**

---

## What I could not retrieve or read cleanly

1. **WebSearch was not used** (budget presumed exhausted per brief). All discovery was via
   arXiv Atom API, Crossref REST, DBLP REST, and direct fetch. **Semantic Scholar returned
   HTTP 429 on every attempt** — zero results from it. **DBLP intermittently returned HTTP 500**;
   two of six planned DBLP queries never completed and were re-routed through Crossref.
2. **The sharp Fredman–Khachiyan exponent.** I have the verified `exp((log n)²)` / `exp((log n)³)`
   statement. The commonly quoted `N^{4χ(N)+O(1)}` with `χ(N)^{χ(N)} = N` form I could **not**
   confirm from a primary source — I did not obtain the J. Algorithms 21 (1996) 618–628 text.
   ScienceDirect returned a page whose extraction was pure base64 SVG chrome with no abstract.
   **I did not fall back to a screenshot read**, which the brief permits; that is a gap I chose
   not to spend budget on. Do not print the `4χ(N)` form without checking it.
3. **Cornuéjols, *Combinatorial Optimization: Packing and Covering*, SIAM 2001** — the canonical
   ideal-clutter reference. Not retrieved (not on arXiv, no open full text found). All idealness
   statements in §4 are sourced instead to Abdi–Cornuéjols–Superdock's preliminaries and to
   Crossref-confirmed journal articles, which is adequate but second-hand for the book-level
   framing (the exact statement of **Lehman's theorem on minimally non-ideal clutters** is
   therefore **not** reproduced here — I would not paraphrase a theorem I did not read).
4. **Stanley–Reisner / Alexander duality attribution** (§5.1). The combinatorial content is
   *measured* (facets = complements of `b(H)`, 9 = 9). The commutative-algebra framing is stated
   from background knowledge with no citation retrieved. Source it before publishing.
5. **The accessibility proof sketch** (§6.2) is a conjecture with a reason, not a proof. The
   measurement (8,240 sets, four grounds, zero failures) is solid; the general claim is not.
   It also does not account for laws with **external** (non-element-expressible) terms — 52 of
   77 requirement terms are prose, and those cannot be checked by the model at all.
6. **`agdmhs` maintenance status unverified.** The repo page loaded but I did not check the last
   commit date. Given R10's explicit finding that every dedicated ADF solver is stale, assume
   nothing.
7. **clingo subset-minimal enumeration flags unverified** for v5.8.0. The domain-heuristic idiom
   is standard; the exact spelling is not confirmed against the installed binary.
8. **Wikipedia extraction mangled all mathematical notation** on the Sperner-family, antimatroid,
   independence-system and monotone-dualization pages (`b(H)`, `ν`, `τ` all vanished). I worked
   around this by (a) re-fetching the wikitext via `action=raw` to recover `<math>` content, and
   (b) reading the clutter/blocker/minor definitions from **ar5iv HTML** of arXiv:1908.10629,
   where the LaTeX survived. **No theorem in this document is paraphrased from mangled text.**
9. **The other 17 hazards were not analysed for what their positive element-level form would be.**
   That is the actual next task and it is a modelling task, not a retrieval task.
