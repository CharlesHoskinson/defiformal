# Pol--Inv / clone-theory source inventory

Scope: sources behind `paper/atlas.tex` §"Model classes, not operators" (Lemma
`lem:polarity`, Theorem `thm:closure`, the Schaefer remark, Corollary
`cor:lattice`) and the positioning claim in §"The composable fragment problem".

Discovery for this lane was **API-only**: Crossref, Unpaywall, OpenAlex, arXiv
API, DBLP, archive.org metadata API, and direct publisher URL construction. No
WebSearch was used.

| file | status |
|---|---|
| `geiger1968.pdf` / `.txt` | primary, full text, clean |
| `schaefer1978.pdf` / `.txt`, `sch_p-05.png`, `sch_p-07.png` | primary, full text; theorem statements read as **page images** (the OCR text layer is column-interleaved and unreliable) |
| `jeavons1997.pdf` / `.txt` | primary, full text, clean |
| `barto_krokhin_willard2017.pdf` / `bkw2017.txt` | primary (modern Pol--Inv survey, open access) |
| `post1941.pdf` | primary, full scan (Annals of Math. Studies 5) |
| `bruhn_schaudt_ucsc_survey.pdf` / `bruhn.txt` | Frankl union-closed survey, checked for Q2 |
| BKKR 1969 | **NOT OBTAINED** -- see entry 2 |
| Pöschel 2004 | **NOT OBTAINED** -- see entry 3 |

---

## 1. Geiger 1968

**Citation.** David Geiger, "Closed systems of functions and predicates",
*Pacific Journal of Mathematics* 27(1):95--100, 1968.
DOI `10.2140/pjm.1968.27.95`. Received 28 September 1967. Obtained free from MSP:
`https://msp.org/pjm/1968/27-1/pjm-v27-n1-p08-s.pdf`.

**Closure conditions, verbatim (pp. 95--96).** A system `S` of functions is closed
if (i) it is closed under composition; (ii) if `f(x_1,...,x_n)` in `S` is associated
with `P ⊆ A^{n+1}` then any `g` associated with `Q ⊆ P` is in `S`; (iii) for any `n`,
`S` contains all functions `f` on `A^n` with `f(x_1,...,x_n) = x_i`.
A system `P` of predicates is closed if: "(i) If `P ∈ 𝒫` and `Q ∈ 𝒫` and `P` and `Q`
have the same order then `P ∩ Q ∈ 𝒫`. (ii) If `P ∈ 𝒫` then any predicate obtained
from `P` by permuting the variables is in `𝒫`. (iii) If `P ∈ 𝒫` then `ΔP` and `RP`
are contained in `𝒫`. (iv) `𝒫` contains the first order predicate `A`."

**Commutation, verbatim (p. 96).** "The predicate `P` commutes with the function `f`
if for every `M ⊆ P` the row matrix `f(M^T)^T` when defined is a sequence contained
in `P`." `S*` and `𝒫*` denote the systems of predicates / functions commuting with
`S`, `𝒫`.

**The theorems, verbatim (pp. 96--97).**

> **Theorem 1.** If `S` is a closed system of functions then `S = S**`.
>
> **Theorem 2.** If `𝒫` is a closed system of predicates then `𝒫 = 𝒫**`.

Abstract, verbatim: "we show that there is a one to one correspondence between
systems of functions defined on a finite set A and systems of predicates defined on
A. This result implies that a complete set of invariants for a universal algebra on
A is given by predicates defined on A. Conversely functions on A provide a complete
system of invariants for sets of predicates closed under conjunction, change of
variable and application of the existential quantifier."

**Two things Geiger does NOT say, and both matter here.**

* Existential quantification is **not** in the base closure (i)--(iv). It enters only
  at Theorem 3: "If `𝒫` is a closed system of predicates which is closed under the
  existential quantifier then every function in `𝒫*` can be extended to a function in
  `𝒫*` which is defined for all values of the arguments." Geiger's Galois-closed
  relation sets are therefore *weak systems*; the pp-definable (relational-clone)
  version needs `∃`.
* The words *Horn*, *dual-Horn*, *union*, *intersection*, *max*, *min* do not appear
  anywhere in the paper. Geiger gives the abstract Galois connection only. He does
  cite Post (p. 99): "In [2] Post has given a classification of two valued systems of
  functions. This gives a classification of two valued systems of predicates
  containing equality and closed under the existential quantifier."

**Supports in `atlas.tex`.** Theorem `thm:closure`, first sentence of the proof
("a constraint language is preserved by an operation exactly when its relations are
invariants of that operation"). **Corrects:** Geiger alone does *not* support the
second sentence ("Dual-Horn clause sets are those preserved by coordinatewise
maximum"). That identification needs source 6.

---

## 2. Bodnarchuk, Kaluzhnin, Kotov, Romov 1969 -- NOT OBTAINED

**Citation, verified via Crossref.** V. G. Bodnarchuk, L. A. Kaluzhnin, V. N. Kotov,
B. A. Romov, "Galois theory for Post algebras. I", *Cybernetics* 5(3):243--252,
DOI `10.1007/BF01070906`; "... II", *Cybernetics* 5(5):531--539,
DOI `10.1007/BF01267873`. (Translation of *Kibernetika* 5(3):1--10, 5(5):1--9, 1969.)

Unpaywall reports Part I as OA at
`https://link.springer.com/content/pdf/10.1007/BF01070906.pdf`, but Springer served
a bot-challenge HTML page (HTTP 200) and then HTTP 204 empty on retry; Part II is
`is_oa: false`. **Not read. Cite as VERIFIED-SECONDARY.**

**Secondary attribution, verbatim** (Barto--Krokhin--Willard 2017 §4.2 p. 14; their
[67] = Geiger, [26] = BKKR): "It is known that every concrete clone is the clone of
polymorphisms of some (possibly infinite) constraint language [67, 26]. The notions
of polymorphism and invariance form the basis of a well-known Galois correspondence
between sets of relations and operations on a finite set [67, 26]."

**Supports in `atlas.tex`.** The `\cite{bkkr1969}` half of Theorem `thm:closure`.
The `refs.bib` entry should gain `VERIFIED-SECONDARY` plus the issue/page data above.

---

## 3. Modern statement of Pol--Inv (open-access stand-in for the Pöschel survey)

**Citation.** Libor Barto, Andrei Krokhin, Ross Willard, "Polymorphisms, and How to
Use Them", in *The Constraint Satisfaction Problem: Complexity and Approximability*,
Dagstuhl Follow-Ups vol. 7, 2017, pp. 1--44. DOI `10.4230/DFU.Vol7.15301.1`.
Open access; obtained.

**Theorem, verbatim (Theorem 32, p. 14).**

> Let `Γ`, `Δ` be constraint languages with `dom(Γ) = dom(Δ)`. Then `Γ` pp-defines
> `Δ` if and only if `Pol(Γ) ⊆ Pol(Δ)`.

**Boolean specialisation, verbatim (§5.4, p. 30).** "As a non-trivial exercise, the
reader may verify a finer description of the polynomial cases: if `Γ` has min as a
polymorphism then `Γ` is pp-definable from `Γ_HornSAT` (and dually for max), if `Γ`
has the majority polymorphism then `Γ` is pp-definable from `Γ_2SAT`, and if `Γ` has
the minority polymorphism then `Γ` is pp-definable from `Γ_3LIN_2`."

**Lemma 62, verbatim (p. 29).** "Every idempotent clone on `D = {0,1}` that contains
a non-projection contains one of the following operations: the binary max, the binary
min, the ternary majority, or the ternary minority."

**Note on Pöschel.** R. Pöschel, "Galois Connections for Operations and Relations",
in *Galois Connections and Applications*, Springer 2004,
DOI `10.1007/978-1-4020-1898-5_5`, is the survey named in the brief. Springer book
chapter; TU Dresden's preprint host refused the connection (`Recv failure:
Connection was reset`) and Unpaywall/OpenAlex list no OA copy. **Not read.** BKW 2017
is an open-access substitute stating the same connection with the same attribution.

**Supports in `atlas.tex`.** The claim that the Galois connection settles preservation
*for languages*. Note that Theorem 32 is about **languages and pp-definability** --
about which *relations* are expressible -- one level up from any single model set.

---

## 4. Post 1941

**Citation.** Emil L. Post, *The Two-Valued Iterative Systems of Mathematical Logic*,
Annals of Mathematics Studies no. 5, Princeton University Press, 1941. Full scan from
archive.org (`post-the-two-valued-iterative-systems-of-mathematical-logic`).

**What Post settles.** The complete lattice of *clones* on `{0,1}`: every set of
Boolean **functions** closed under composition and containing the projections,
classified up to inclusion. Contemporary statement, BKW §5.4 p. 29, verbatim: "An old
result by Post [108] completely describes all clones on `{0,1}` and we can thus simply
use his classification."

**What Post does not settle.** Post's lattice is a lattice of *operation* clones. It
says nothing about which subfamilies of a *fixed* model set are closed under a given
operation. Passing from Post's lattice to a statement about relations requires exactly
the Galois connection of source 1 -- which is Geiger's own remark (p. 99, quoted
above).

**Supports in `atlas.tex`.** Justifies the paper's explicit disclaimer of Post. The
sharpest form of the disclaimer: Post classifies the operation side; Geiger/BKKR
transports the classification to the relation side; **neither side is a statement
about subfamilies of one model set.**

---

## 5. Schaefer 1978

**Citation.** Thomas J. Schaefer, "The complexity of satisfiability problems",
*STOC '78*, pp. 216--226. DOI `10.1145/800133.804350`. ACM open access; obtained.
Statements below read from rendered page images, not from the OCR layer.

**Lemma 3.1B, verbatim (p. 220).**

> **Lemma 3.1B.** Let R be a logical relation and let A := R(x_1,...). Then the
> following are equivalent:
> (a) R is bijunctive.
> (b) For every s ∈ Sat(A), if V_1 and V_2 are change sets for (A,s) then so is
> V_1 ∩ V_2.
> (c) For every s ∈ Sat(A) and every literal α which is consistent with A,
> s#Imp_A(α) ∈ Sat(A). (See Note on last page of this section.)

**The Note, verbatim (p. 222) -- this is the majority/median condition.**

> **Note.** Condition (b) of Lemma 3.1B can also be expressed in the following
> pleasantly symmetric form:
> (b') For all s_1, s_2, s_3 ∈ Sat(A), (s_1 ∨ s_2) ∧ (s_2 ∨ s_3) ∧ (s_3 ∨ s_1) ∈
> Sat(A).
> This is derived from condition (b) by setting s_1 = s, s_2 = s ⊕ K_{1,V_1},
> s_3 = s ⊕ K_{1,V_2} and observing that ((s_2 ⊕ s_1) ∧ (s_3 ⊕ s_1)) ⊕ s_1 is
> equivalent to (s_1 ∨ s_2) ∧ (s_2 ∨ s_3) ∧ (s_3 ∨ s_1).

**Lemma 3.1W, verbatim (p. 220) -- confirms the paper's disclaimer.**

> **Lemma 3.1W.** Let R be a logical relation and let A := R(x_1,...). Then (a) R is
> weakly positive if and only if whenever V ⊆ Var(A) is 0-consistent and 0-closed for
> A, K_{0,V} ∈ Sat(A); and (b) R is weakly negative if and only if whenever
> V ⊆ Var(A) is 1-consistent and 1-closed for A, K_{1,V} ∈ Sat(A).

**Supports in `atlas.tex`.** Measurement `meas:arity` (the majority / median-closure
condition). The Note above is the exact statement to cite; it sits on **p. 222**, the
last page of §3, not on the page carrying Lemma 3.1B. **Confirms** the paper's remark:
Schaefer's "weakly positive" *is* the dual-Horn class (proof of 3.1W, p. 220:
"logically equivalent to some CNF formula A' having at most one negated variable per
conjunct"), but 3.1W characterises it by a closure condition on *variable sets*, not
by componentwise `∨`-closure of the solution set. Schaefer is thus the wrong citation
for Theorem `thm:closure` and the right one for `meas:arity`. The current `refs.bib`
note is correct as written.

---

## 6. Jeavons, Cohen, Gyssens 1997

**Citation.** Peter Jeavons, David Cohen, Marc Gyssens, "Closure Properties of
Constraints", *Journal of the ACM* 44(4):527--548, July 1997.
DOI `10.1145/263867.263489`. ACM open access; obtained.

**Definition 3.3, verbatim (p. 533).** "Let f be a k-ary operation on D, and let R be
an n-ary relation over D. The relation R is closed under f if f(R) ⊆ R."

**Corollary 4.2, verbatim (p. 536).** "Assuming that P is not equal to NP, any
tractable set of reduced relations must be closed under either a constant operation,
or a majority operation, or an idempotent binary operation, or an affine operation, or
a semiprojection."

**Example 5.3.5, verbatim (p. 541) -- the statement the paper actually needs.**

> It is well known [Dechter and Pearl 1992; Jeavons and Cooper 1996; Papadimitriou
> 1994] that a Boolean relation is closed under AND if and only if it can be defined
> by a Horn sentence (i.e., a conjunction of clauses each of which contains at most
> one unnegated literal). [...] Similarly, a Boolean relation is closed under OR if
> and only if it can be defined by a conjunction of clauses each of which contains at
> most one negated literal, and this class of relations also gives rise to a tractable
> subproblem of the SATISFIABILITY problem [Schaefer 1978].

**Supports in `atlas.tex`.** This is the exact, citable, verbatim source for the second
sentence of the proof of Theorem `thm:closure`. Geiger and BKKR supply the Galois
connection; **JCG Example 5.3.5 supplies the Boolean instantiation**, an *iff* in both
directions. Recommend adding `\cite{jeavons1997}` to that sentence.

**Caveat on the brief's framing.** JCG 1997 proves the *necessary* direction
(Corollary 4.2): tractability implies a nontrivial polymorphism. The strong form
"tractability is determined by the polymorphisms" is Theorem 32 of source 3
(pp-definability iff polymorphism containment), later work. If `atlas.tex` ever states
the strong form, cite BKW 2017 alongside JCG 1997.

---

## Q2: is "largest union-closed subfamily of a given family" a named problem?

**Searched (API-only).** OpenAlex `title.search`: *union-closed subfamily*,
*union-closed subfamilies*, *maximal union-closed*, *largest sublattice*, *maximum
sublattice*, *sublattice extraction*, *closure under union subfamily*, *union-closed
families*. OpenAlex full-text `search`: *maximum sub-semilattice*, *largest subuniverse
finite algebra complexity*, *maximum union-closed subfamily NP-hard*, *maximum
subalgebra computation NP-hard*, *union-stable subfamily*. arXiv API full text:
`"union-closed subfamily"`, `"largest union-closed"`, `"maximum union-closed"`.
DBLP: *union-closed subfamily*, *maximum sublattice*, *subsemilattice maximum*.

**Result.** Zero hits for the phrase in any form. `union-closed subfamily`,
`union-closed subfamilies`, `maximal union-closed`: **0 works** in OpenAlex titles,
**0** in arXiv full text, **0** in DBLP. `union-closed families` returns 64 OpenAlex
titles, all Frankl-conjecture papers -- Frankl asks whether every finite union-closed
family has an element in at least half its members, an extremal statement *about* a
union-closed family, not about extracting one from a larger family. The
Bruhn--Schaudt survey *The journey of the union-closed sets conjecture*
(arXiv:1309.3297) uses "subfamily" only twice, both times for the subfamily of sets
containing a fixed element; it poses no extraction problem and offers no machinery
that transfers. `maximum sublattice` in DBLP returns one 2024 paper on the Maximum
Distance Sublattice Problem, which is lattices in R^n (CVP), unrelated.

**Conclusion.** The problem is unnamed. The nearest correctly-named framing is
*maximum subuniverse of a partial algebra*: a union-closed `F ⊆ 𝒜` is exactly a
subuniverse of `(𝒜, ∪)` where `∪` is the partial operation defined when
`A ∪ B ∈ 𝒜`. That framing does not appear in the union-closed-sets literature either.
The paper's own reformulation (Proposition `prop:clique`: `⊕`-safe fragments = cliques
of `G_⊕`) remains the only reduction to a named problem, and should be presented as
the paper's contribution rather than as a lookup.

---

## Draft paragraph for the positioning discussion

> It is worth being exact about what the Galois connection does and does not
> settle here, because the two statements differ by a quantifier. Geiger's
> Theorems 1 and 2 \cite{geiger1968}, discovered independently by Bodnarchuk et
> al.\ \cite{bkkr1969}, establish that on a finite set the operators
> $\mathscr{S}\mapsto\mathscr{S}^{*}$ and $\mathscr{P}\mapsto\mathscr{P}^{*}$ are
> mutually inverse on closed systems: $\mathscr{S}=\mathscr{S}^{**}$ and
> $\mathscr{P}=\mathscr{P}^{**}$. In modern form, $\Gamma$ pp-defines $\Delta$
> exactly when $\mathrm{Pol}(\Gamma)\subseteq\mathrm{Pol}(\Delta)$
> \cite[Thm.~32]{bkw2017}; instantiated at the Boolean domain, a relation is
> closed under coordinatewise $\vee$ if and only if it is definable by a CNF with
> at most one negated literal per clause \cite[Ex.~5.3.5]{jeavons1997}, and dually
> for $\wedge$ and Horn. That settles maximality one level below our problem: the
> largest \emph{constraint language} preserved by union is exactly the dual-Horn
> one, and there is nothing further to look for there. It does not settle, and
> does not bear on, the question we face. Pol--Inv quantifies over relations and
> asks which are invariant under a fixed operation; we hold one model set
> $\Adm=\mathcal{R}\cap\mathcal{W}\cap\mathcal{H}$ fixed --- and it is not
> union-closed, by Corollary~\ref{cor:admnotlattice} --- and ask for the largest
> subfamily $F\subseteq\Adm$ that is. A Galois connection on definable relation
> classes has no cardinality-extremal content about subfamilies of a single
> non-invariant family, and Post's lattice \cite{post1941}, being a classification
> of operation clones rather than of subfamilies, has none either. We searched for
> the subfamily question under its own name and did not find it: ``union-closed
> subfamily'' and its variants return nothing in the combinatorics literature, and
> the Frankl union-closed sets conjecture is an extremal statement about a family
> already assumed union-closed rather than a problem of extracting one. This is
> why Proposition~\ref{prop:clique} matters: rather than a lookup, the reduction
> to maximum clique on $G_\oplus$ is what puts the problem in contact with a named
> and studied one.
