# Referee report — *An Algebra of Mechanism Composition*

**Referee A** (order theory, lattice theory, correctness of proofs)
Manuscript: `paper/atlas.tex`, 15 pp. Supporting material inspected: `lean/Defialgebra/*.lean`,
`formal/v2/`, `formal/v3/VERIFICATION.md`, `formal/v3/LEAN-REPORT.md`, `paper/refs.bib`,
`paper/atlas.bbl`, `paper/atlas.blg`.

**Recommendation: major revision.**

Numbering is continuous; severity is marked on each item. "Location" cites the label as it
appears in the source.

---

## A. Definitions and well-formedness

### 1. `\Gamma` is used in eight statements and never defined — **major**

**Location.** First occurrence `atlas.tex:385` (`thm:bilattice`, as `\Fix(\Gamma)`); thereafter
`thm:aft` (l.400–412), the completion-lattice section (l.465, 471, 477, 484, 489),
`\oplus` (l.567), `cor:residual` (l.653), and the compatibility-graph definition (l.1022).

**Problem.** There is no definition of $\Gamma$ anywhere in the paper. I grepped: every
occurrence is a *use*. This is not a typographical slip, because §\ref{sec:models}
("Model classes, not operators") *argues that no such operator exists*:

> "For disjunctive requirements no such operator exists: a term with several alternatives
> determines no unique addition, so there is no canonical map $L \to L$ whose fixed points are the
> models of $\Law$. We therefore work with model classes throughout, and reserve operator language
> for the definite fragment of §\ref{sec:convex}, where it is available."

The paper then uses operator language for $\Gamma$ outside the definite fragment on every page.
This is precisely the residue of the operator/model-class conflation the paper's own history
records, and it is not confined to prose: it is load-bearing in theorem *statements*.

Concretely, the following are not well-formed as written:
* `thm:bilattice` — quantifies over bilattices on $\Fix(\Gamma)\times\Fix(\Delta)$;
* `thm:aft` — the hypothesis "$\Gamma$ is inflationary" has no referent;
* Definition of $\oplus$ (`$X\oplus Y := \Gamma(X\cup Y)$`) — and therefore `thm:noncong`,
  `cor:oplusclosed`, `meas:frag`, `meas:width`, `prop:clique`, `cor:nomax`, `conj:perfect`,
  `meas:pairs`, `ex:uniaave`, and the entire §\ref{sec:cfp};
* Definition of the compatibility graph, whose self-compatibility argument is
  "$A\oplus A=\Gamma(A)=A$ for $A\in\Adm$", i.e. it silently asserts $\Adm\subseteq\Fix(\Gamma)$.

**Fix.** Either (a) define $\Gamma$ explicitly and prove it is well defined — which by the
paper's own §\ref{sec:models} argument requires either restricting to the definite fragment or
making a choice function explicit and admitting the resulting non-canonicity; or (b) eliminate
$\Gamma$ in favour of model classes: define $X\oplus Y := X\cup Y$ and state
`thm:noncong` as "$\Adm$ is not closed under union". Option (b) costs nothing that I can see,
since `meas:whereitfails` and `cor:oplusclosed` show the closure step never fires on the
$\mathcal{R}\cap\mathcal{W}$ side anyway. Do not leave a defined-nowhere operator in eight
statements.

### 2. `\Law`/`\mathcal{R}`, `\War`/`\mathcal{W}`, `\Haz`/`\mathcal{H}` are the same glyphs — **major**

**Location.** Preamble l.24–28 (`\newcommand{\Law}{\mathcal{R}}`, `\newcommand{\War}{\mathcal{W}}`,
`\newcommand{\Haz}{\mathcal{H}}`) against §\ref{sec:models}
(`$\mathcal{R} = \mathcal{M}(\Law)$, $\mathcal{W} = \mathcal{M}(\War)$,
$\mathcal{H} = \mathcal{M}(\Haz)$`).

**Problem.** As typeset, the definition of the model classes reads
$\mathcal{R} = \mathcal{M}(\mathcal{R})$, $\mathcal{W} = \mathcal{M}(\mathcal{W})$,
$\mathcal{H} = \mathcal{M}(\mathcal{H})$. The same symbol denotes both the *syntactic* constraint
set and its *model class*. Given that the whole point of §\ref{sec:models} is to separate
syntax from semantics, this is not a cosmetic defect: `thm:closure` ("$\mathcal{R}$ and
$\mathcal{W}$ are closed under union") and `prop:noinvariance` ("$\Delta$ does not preserve
$\mathcal{R}$") are ambiguous on their face, and `prop:twoeffects` has to write
$\mathcal{M}(\Law)$ out longhand to escape the collision — which is a symptom, not a fix.

**Fix.** Rename the syntactic sets: $R$, $W$, $H$ (roman) for the clause sets, calligraphic
$\mathcal{R},\mathcal{W},\mathcal{H}$ for the model classes, and say so once, explicitly.

### 3. The object theorised is not the object measured — **major**

**Location.** Definition of $\Adm = \mathcal{R}\cap\mathcal{W}\cap\mathcal{H}$ (§\ref{sec:models})
against `prop:mixed`, `meas:whereitfails`, `meas:ablation58`, `meas:pairs`.

**Problem.** Three constraint families appear in the measurements that are *not* in the
definition of $\Adm$:
1. **Grounding.** `meas:ablation58` counts "93 clauses transcribing admissibility (31 closure, 27
   warrant, 21 grounding, 14 negative)". *Grounding is never defined in the paper.* Twenty-one
   of ninety-three clauses — 23% of the constraint set — belong to a family with no definition,
   no polarity classification, and no appearance in $\Adm$.
2. **Mixed-polarity clauses.** `prop:mixed` states that "some recorded conditions are clauses with
   two or more negative literals together with a positive one". These are not requirements
   (one negative literal), not warrants (ditto), and not prohibitions (purely negative). They
   are therefore outside $\mathcal{R}\cap\mathcal{W}\cap\mathcal{H}$ entirely, yet
   `meas:whereitfails` attributes 23% of composition failures to them.
3. **Conditional prohibitions.** `meas:whereitfails` says "all [failures] arise from the
   conditional prohibitions". The paper's Definition of a prohibition is an *unconditional*
   set $H\subseteq\El$. The supporting material (`formal/v3/VERIFICATION.md` §8) confirms these
   are hand-written predicates (`X21`, `X19*`, `X18`, `X11a*`), *not* rows of $\Haz$.

Consequently every theorem in the paper is about a constraint system that is strictly smaller
than the one every measurement is about. `cor:lattice` is proved for
$\mathcal{R}\cap\mathcal{W}$ and does not cover the grounding clauses; if any grounding clause is
not dual-Horn, the lattice claim does not apply to the positive theory as actually implemented.

**Fix.** Define grounding formally, classify its polarity, and either fold it into
$\mathcal{R}\cap\mathcal{W}$ (with proof) or state $\Adm$ as a four-way intersection and re-derive
`cor:lattice`. Generalise the Definition of prohibition to conditional form, or introduce a fourth
family with its own name and polarity. This is the single change that would do most for the
paper's credibility.

### 4. Anti-exchange, observational equivalence, and five other terms are used but never defined — **major** (as a class)

**Location.** Throughout §\ref{sec:convex}, `thm:noncong`, `thm:bilattice`, §Repair.

Undefined at point of use: **anti-exchange** (used in `thm:convex`, `cor:ourconvex`, the
`meas:access` remark — the paper's central geometric property is never stated);
**observational equivalence** (the subject of half of `thm:noncong`); **definable object**
(the conclusion of `thm:bilattice`); **downset alignment**, **union-stable**, **standard**
(closure system); **grounding**; **conditional prohibition**; **hazard row**;
**atomic-scope prohibition**. A referee cannot check `thm:convex` without the anti-exchange
axiom in front of him; I checked it against the standard form (for closed $C$ and distinct
$x,y\notin C$, $y\in Cn(C\cup\{x\})\Rightarrow x\notin Cn(C\cup\{y\})$) and the argument works,
but the paper must state it.

**Fix.** A short "Notation and definitions" subsection. Non-negotiable for anti-exchange.

### 5. $\Delta$ is used six items before it is defined, and there are two environments named "Warrant" — **minor**

**Location.** `prop:joinmeet` (l.~305) uses $\Delta$ and $\Delta^\omega$; Definition [Warrant]
defining $\Delta$ appears at l.~375, after `cor:oplusclosed`, `meas:latticeconf`,
`cor:admnotlattice`, `prop:mixed` and `meas:whereitfails`. Definition [Warrants]
(§Preliminaries) and Definition [Warrant] (§\ref{sec:models}) are two separately numbered
environments with nearly the same name and overlapping content.

**Fix.** Move the operator $\Delta$ into the Preliminaries alongside the warrant clause form, and
merge the two environments.

### 6. The warrant relation both is and is not the residual of the requirement relation — **major**

**Location.** Remark following Definition [Warrants] (§Preliminaries) versus the opening
sentence of §\ref{sec:tradeoff}.

> §Preliminaries: "$\War$ is not independent data. It is obtained as the residual
> (order-theoretic adjoint) of the requirement relation".

> §\ref{sec:tradeoff}: "The warrant relation is not the residual of the requirement relation,
> which suggests a repair: replace $C$ by the true residual of $R$."

These are contradictory, and `meas:repair` ("of the 57 (subject, term-alternative) pairs in the
residual of $R$, 32 are absent from $C$") settles it in favour of the second. The first remark is
false and must be struck; it also undercuts `prop:noinvariance`, whose proof turns on exactly the
gap between $C$ and the residual.

**Fix.** Delete the §Preliminaries claim; replace with "$\War$ was fitted to the corpus and is
*not* the residual of $R$; see §\ref{sec:tradeoff}."

---

## B. Proofs

### 7. `thm:convex` — the statement is missing the hypothesis $Cn(\emptyset)=\emptyset$; a counterexample exists — **minor** (the instance survives)

**Location.** `thm:convex`, and its proof sketch.

**Problem.** The theorem is stated for "a union-stable closure" in general: *"A union-stable
closure satisfies anti-exchange if and only if $\preceq$ is antisymmetric... In that case
$(\El,Cn)$ is the down-set geometry of the poset $(\El,\preceq)$."* Take
$Cn(X) = X\cup\{a\}$ on any $\El\ni a$. This is a union-stable closure. Its specialization
preorder is antisymmetric ($a\in Cn(\{x\})$ for all $x$, but $x\in Cn(\{a\})=\{a\}$ only for
$x=a$), and anti-exchange holds vacuously (the only candidate $y$ is $a$, which lies in every
closed set). But the closed sets are the supersets of $\{a\}$, *not* the down-sets of $\preceq$:
$\emptyset$ is a down-set and is not closed. So the second sentence of the theorem is false as
stated. A convex geometry requires $\emptyset$ closed and the theorem does not say so.

**Fix.** Add "with $Cn(\emptyset)=\emptyset$" to the hypotheses. The instance satisfies it
(every definite requirement has a nonempty subject), so nothing downstream changes — but the
theorem as printed is wrong.

### 8. `thm:convex` — the proof cites `lem:ej` in the wrong direction — **minor**

**Location.** Proof sketch of `thm:convex`: *"the down-sets of a poset form a convex geometry by
Lemma \ref{lem:ej}."*

**Problem.** `lem:ej` as stated (and as quoted in `refs.bib` from Edelman–Jamison 1985 Thm 3.2)
is: *a convex geometry is a downset alignment iff its closure system is union-closed.* That is a
statement **about convex geometries**. It presupposes what the proof wants to conclude. The
implication actually needed — down-sets of a finite poset satisfy anti-exchange — is not an
instance of it.

This does not break the result: the needed fact is genuinely routine (if $C$ is a down-set,
$x,y\notin C$ distinct and $y\in C\cup{\downarrow}x$ then $y\le x$; if also $x\in C\cup{\downarrow}y$
then $x\le y$, so $x=y$, contradiction — three lines). But this is exactly the class of citation
error the paper's own `refs.bib` notes are meant to catch, and it survived.

**Fix.** Replace the appeal to `lem:ej` with the three-line direct argument, and keep `lem:ej`
only as the remark that union-closedness pins down which convex geometries these are.

### 9. `lem:cm` is misquoted and is false as printed — **minor**

**Location.** `lem:cm` ("Singleton premises; Caspard–Monjardet 2004, §3").

**Problem.** As stated: *"For a single implication $A\to B$ the induced closure system is
union-stable if and only if $|A|=1$, or $A=\emptyset$ and $|B|=1$."* Take $A=\emptyset$,
$B=\{b,c\}$. The closed sets are exactly the supersets of $B$, which are closed under union.
So the system is union-stable while the stated condition fails. The clause "and $|B|=1$" is
spurious; the correct condition is $|A|\le 1$ (or the source states it under a normal form in
which $|B|=1$ throughout, in which case the paper must say so).

**Fix.** State it as $|A|\le1$, or quote the source's normalisation convention. Either way the
paper only uses $|A|=1$, so nothing downstream moves.

### 10. `cor:lattice` — hidden hypothesis: consumer sets must be nonempty — **minor**

**Location.** `cor:lattice`, proof: *"Both $\emptyset$ and $\El$ satisfy every clause with a
nonempty antecedent."*

**Problem.** The Definition of a warrant is "a pair $(e,C)$ with $e\in\El$ and $C\subseteq\El$ a
set of consumers", with **no nonemptiness requirement** (contrast the Definition of a requirement,
which does say each $T_j$ is nonempty). If some $C(e)=\emptyset$, the warrant clause is $\neg e$,
which is still dual-Horn — so `lem:polarity` and union-closure survive — but $\El\notin\mathcal{W}$
and the proof's claim that $\top$ is in the family fails. The complete-lattice conclusion then
needs a different top. Note that `prop:vacuous` *does* carry this hypothesis explicitly ("if every
dependent element has a consumer present in $\top$"), which shows the authors know it is needed
and simply omitted it here.

**Fix.** Require $C\neq\emptyset$ in the Definition of a warrant, or add the hypothesis to
`cor:lattice`. The supporting run (`formal/v3/m2.out`: "TOP in R n W : true") confirms the
instance satisfies it; the theorem should not depend on that.

### 11. `prop:joinmeet` — the corrected statement is right, but the meet value is asserted, not proved — **minor**

**Location.** `prop:joinmeet` and its proof.

I record first that the version I have has already been corrected relative to the authors' own
audit (`formal/v3/VERIFICATION.md` §7 records the earlier claim "the meet is $\Delta^\omega(A\cap B)$"
as **REFUTED**). The current statement — meet = join of all common lower bounds, and *not*
$\Delta$ applied to the intersection — is correct: $\mathcal{R}\cap\mathcal{W}$ is union-closed
and contains $\emptyset$, so $\bigcup\{C\in\mathcal{R}\cap\mathcal{W}: C\subseteq A\cap B\}$ is a
member and is the greatest lower bound. That part is sound.

**Remaining problem.** The proof ends "the meet is $\{Ix,Sh\}$" with no verification that
$\{Ix,Sh\}\in\mathcal{R}\cap\mathcal{W}$ and no argument that it is maximal among common lower
bounds. That is a computation, and by the paper's own status conventions it needs to be labelled
as one or discharged.

**Fix.** Either drop the specific value or add "(computed exhaustively over the subsets of
$A\cap B$; see `formal/v3/m3.out`)".

### 12. `cor:oplusclosed` is a measurement wearing a corollary's clothes — **major**

**Location.** `cor:oplusclosed`: *"$\mathcal{R}\cap\mathcal{W}$ is closed under $\oplus$:
verified on $96{,}720$ pairs with no failure."*

**Problem.** A Corollary whose entire content is "verified on 96,720 pairs" is a Measurement.
The paper's own status conventions say a Corollary is "proved, with the proof given or sketched"
and that a Measurement is "not proved in general, and *not* to be cited as if it were". This is
the paper's central claim to epistemic hygiene and it is broken in the very section that
establishes the lattice. Worse, the statement is not even well-formed, because $\oplus$ is defined
via the undefined $\Gamma$ (Finding 1). If $\oplus$ is union then closure is immediate from
`cor:lattice` and the item should be a one-line corollary with a real proof; if $\oplus$ is
$\Gamma(\cdot)$ then it is unproved.

**Fix.** Decide what $\oplus$ is. If union: prove it in one line and delete the pair count. If
not: relabel as `Measurement`.

### 13. `cor:admnotlattice` has no proof and no witness — **minor**

**Location.** `cor:admnotlattice`: *"$\Adm$ is not union-closed and so is not a sublattice."*

**Problem.** Stated with no proof. It does not follow from `thm:closure` alone: one needs a
witness pair $X,Y\in\Adm$ with $X\cup Y\notin\mathcal{H}$, i.e. that some prohibition is actually
*arm-able* by a union of admissible sets. Such a witness exists (`ex:uniaave`, eight pages later),
but the reader is not told.

**Fix.** Add "(witness: `ex:uniaave`)" or move a two-element witness up.

### 14. `thm:closure` — the negative halves are deferred to a witness that covers only one of three — **minor**

**Location.** `thm:closure`, proof: *"The negative halves are witnessed below."*

**Problem.** Three negative claims are made ($\mathcal{R}$ not $\cap$-closed, $\mathcal{W}$ not
$\cap$-closed, $\mathcal{H}$ not $\cup$-closed). The only witness "below" is
`meas:closureprops`, which witnesses the first. The other two are never witnessed in the paper.
(They are witnessed in `lean/Defialgebra/Polarity.lean` — `req_not_inter_closed`,
`proh_not_union_closed` — which the paper never mentions.)

**Fix.** Give all three witnesses inline (each is a two- or three-element example), or cite the
Lean file.

### 15. `thm:excomp` — acyclicity is used in the proof but is still not a hypothesis of the statement, and it is cited to the wrong result — **minor**

**Location.** `thm:excomp` statement and proof.

I note the known instance has been partly repaired: the proof now reads "acyclicity
(Theorem \ref{thm:convex}) makes $\preceq$ a partial order". The repair is half-done in two ways:

(a) The **statement** still reads "For closed $A,B$, ..." with no acyclicity hypothesis. Since
the authors' own counterexample (the remark immediately following, and
`formal/v3/m6-antisymm-needed.mjs`) shows the identity *fails* on a cyclic digraph with both
$A$ and $B$ closed, the hypothesis belongs in the statement, not only in the proof. The Lean
formalisation gets this right (`ex_reachCl_union_ex` carries antisymmetry as a hypothesis); the
paper does not.

(b) The proof cites `thm:convex` for acyclicity. `thm:convex` does not *establish* acyclicity —
it is the equivalence "anti-exchange $\iff$ acyclic". Acyclicity of our $D$ is established in
`cor:ourconvex`, by computation. The citation is to the wrong item and disguises a measured
hypothesis as a proved one.

Modulo those two, I checked the mathematics and it is correct: for a finite poset and down-sets
$A,B$, $\max(A\cup B) = \max(\mathrm{ex}(A)\cup\mathrm{ex}(B))$ in both directions (⊇ because any
$m$ below some $a\in A\cup B$ is below a maximal element of that side; ⊆ because a maximal element
of $A\cup B$ lying in $A$ is maximal in $A$). Genuinely routine.

**Fix.** Add "assume $D$ acyclic" to the statement; cite `cor:ourconvex`.

### 16. `thm:excomp` — "linear time" is unsupported — **minor**

**Location.** `thm:excomp`: *"computable in time linear in $|\mathrm{ex}(A)|+|\mathrm{ex}(B)|$."*

**Problem.** Computing $\max_\preceq$ of a $k$-element set requires $\Theta(k^2)$ comparability
tests in the worst case, and each test is a reachability query in $D$ unless $\preceq$ is
precomputed. No model of computation is stated. The claim is repeated ("in linear time") in the
remark that follows and in `ex:comp`.

**Fix.** State the model: "linear in $|\mathrm{ex}(A)|+|\mathrm{ex}(B)|$ given the transitive
closure of $D$ as a precomputed bit-matrix", or say $O(k^2)$ comparisons.

### 17. `thm:excomp` is stated for $\oplus$ but proved for $Cn$ — **major**

**Location.** `thm:excomp` statement (uses $\oplus$) versus its proof (*"Union-stability gives
$A\oplus B = Cn(A\cup B) = A\cup B$"*) versus the Definition of $\oplus$
($X\oplus Y := \Gamma(X\cup Y)$).

**Problem.** The proof silently substitutes $Cn$ (the *definite-fragment* closure) for $\Gamma$
(the undefined global operator). If $\Gamma\ne Cn$ — and it must differ, since $\Gamma$ is meant
to handle disjunctive requirements — then `thm:excomp` says nothing about the $\oplus$ that
appears in `thm:noncong`, `meas:frag`, `prop:clique` and §\ref{sec:cfp}. The paper's headline
compositionality result and its headline non-compositionality result are about two different
operations sharing one symbol. Given the paper's documented history of conflating an operator
with a model class, this needs to be fixed explicitly, not quietly.

**Fix.** Introduce a separate symbol $\oplus_{\mathrm{def}} := Cn(\cdot\cup\cdot)$ for the definite
fragment, and state `thm:excomp` in terms of it.

### 18. `thm:bilattice` — the identification of $\Adm$ with the diagonal is false — **major**

**Location.** `thm:bilattice` and its proof sketch.

Three defects, one of them fatal to the statement as written:

(a) **The diagonal is not $\Adm$.** The proof says "$\Adm$ is precisely the diagonal
$\{(x,x)\}$" in $\Fix(\Gamma)\times\Fix(\Delta)$. The diagonal of that product is
$\Fix(\Gamma)\cap\Fix(\Delta)$, i.e. (at best) $\mathcal{R}\cap\mathcal{W}$. But
$\Adm = \mathcal{R}\cap\mathcal{W}\cap\mathcal{H}$, a *proper* subset — the paper spends a whole
section (§\ref{sec:cost}) on how proper. The theorem is therefore about
$\mathcal{R}\cap\mathcal{W}$, not about $\Adm$. Note that the Lean supporting file makes the same
substitution: `Obstruction.lean:96` defines `Adm Γ Δ : Set α := {x | Γ x = x ∧ Δ x = x}`, which is
the diagonal, *not* the paper's $\Adm$. The conflation is in the artifact as well as the prose.

(b) **Wrong cross-reference.** "contradicting Theorem \ref{lem:polarity}" — `lem:polarity` is the
polarity Lemma, which says nothing about $\Adm$ being or failing to be a lattice. The intended
reference is presumably `cor:admnotlattice`. As printed the final sentence of the proof cites a
result that does not support it.

(c) **"Definable object" is undefined.** The conclusion quantifies over a notion the paper never
introduces. Without it the theorem is unfalsifiable: I cannot check a proof of a statement whose
predicate has no definition.

I add that the argument, even repaired, is weaker than it sounds: Avron's representation theorem
says an interlaced bilattice *is* a componentwise product; "a componentwise structure cannot
distinguish [the diagonal]" is an assertion, not an argument — the diagonal is a perfectly good
*subset* of a product, and what fails is presumably its closure under the two orders. That step
needs writing out.

**Fix.** Restate for $\mathcal{R}\cap\mathcal{W}$; define "definable object" (I suggest:
"closed under both bilattice orders"); repair the cross-reference; expand the diagonal step.

### 19. `thm:aft` — the proof is valid; the framing is not — **minor**

**Location.** `thm:aft`.

The chain $\Gamma(x)\le\Delta(x)\le x\le\Gamma(x)$ is correct and the claim that it uses neither
exactness nor $\le_p$-monotonicity is correct. This is the cleanest proof in the paper and I have
no objection to it beyond Finding 1 ($\Gamma$ undefined). Two small points:

(a) The result is close to vacuous once one notes that DMT's approximators are *exact* on the
diagonal ($A(x,x)=(O(x),O(x))$), which already forces $\Gamma=\Delta$ before consistency is
invoked. The paper's stronger route is fine, but the reader should be told that the standard
definition rules this out even faster.

(b) The "trivial one with $\Gamma=\Delta=\mathrm{id}$" is not shown to be an approximator of
anything interesting; say so.

### 20. `prop:collapse` — valid, with one unstated hypothesis — **minor**

**Location.** `prop:collapse` and the remark following.

The proof is correct: $\emptyset\in\Adm=\Fix(O)$ gives $O(\emptyset)=\emptyset$ so the lower
component is $\bot$; $\Adm\subseteq O([\bot,\top])$ and $\bigcup\Adm=\El$ give the upper. Fine.

**Unstated hypothesis.** The remark justifies (i) by "every requirement is an implication with a
nonempty antecedent, so the empty protocol violates nothing". That covers $\mathcal{R}$ and
$\mathcal{W}$; for $\mathcal{H}$ one additionally needs $\emptyset\notin\Haz$. True for a clutter
of minimal *nonempty* forbidden sets, but the Definition does not require nonemptiness.

**Fix.** Require $\emptyset\notin\Haz$ in the Definition of prohibitions.

### 21. `prop:dag` and `prop:mixed` are empirical claims presented as propositions with no proof — **major** (as part of Finding 27)

**Location.** `prop:dag` ("The requirement relation on $\El$... is a directed acyclic graph
without self-loops"); `prop:mixed` ("Some recorded conditions are clauses with two or more
negative literals...").

Both are facts about a data table. Neither has a proof, a witness, or a measurement reference.
`prop:dag` in particular asserts acyclicity of the **full** requirement relation ("taking every
alternative of every term"), whereas the only acyclicity actually checked anywhere in the
supporting material is of the **definite** digraph $D$ (`formal/v3/m5.out`). I could not find a
check of the full relation. If `prop:dag` is false, its Corollary (reflexive failure modes not
expressible) is false too.

**Fix.** Demote to Measurements with the enumeration that establishes them, or supply proofs.

### 22. `thm:noncong` has no proof at all, and half of it concerns an undefined notion — **major**

**Location.** `thm:noncong`: *"$\oplus$ preserves observational equivalence but does not preserve
admissibility: there exist admissible $X,Y$ with $X\oplus Y\notin\Adm$."*

No proof environment follows — only a Remark asserting that preservation of observational
equivalence is "immediate" because the relation is "defined by quantification over all contexts".
Neither *context* nor *observational equivalence* is defined anywhere in the paper. The second
half (an existential) is discharged much later by `ex:uniaave`, unreferenced here.

**Fix.** Define observational equivalence and contexts, or delete that half of the theorem. Add
"Proof: `ex:uniaave`" for the second half.

---

## C. Attribution

### 23. The bibliography contains three items; roughly fifteen named theorems are cited by name only — **major**

**Location.** `atlas.bbl`, `atlas.blg`, and every attribution in the text.

**Problem.** BibTeX reports "You've used 3 entries". The only `\cite` commands in the source are
at l.271 (`geiger1968,bkkr1969`) and l.280 (`schaefer1978`). Every other attribution is made in
running prose with no citation and therefore no bibliography entry:

* "Avron's representation theorem" (`thm:bilattice`) — no cite.
* "Tarski's theorem" (`cor:residual`) — no cite.
* "Caspard–Monjardet 2004, §3" (`lem:cm`) — no cite.
* "Edelman–Jamison 1985, Thm. 3.2" (`lem:ej`) — no cite.
* "Edelman 1980, Thm. 3.3" (Remark [Distributivity]) — no cite.
* "Isbell 1958, Edmonds–Fulkerson 1970" (`thm:blocker`) — no cite.
* "Seymour's identity" (`prop:oneobject`) — no cite, and no `refs.bib` entry at all.
* "Grötschel–Lovász–Schrijver algorithm" (`conj:perfect` remark) — no cite, no entry.
* Perfect-graph tractability (`prop:clique` remark) — Chudnovsky et al. and Lovász are in
  `refs.bib` and never cited.

`refs.bib` is a careful, well-annotated file — the notes flagging the Schaefer and ACTUS traps are
exactly right — and almost none of it reaches the paper. The ACTUS trap in particular is dodged
by omission: the entry warns "NOT a completeness result", and the paper contains no reference to
ACTUS, Marlowe, or Peyton Jones–Eber–Seward at all. **There is no related-work discussion.** For a
paper whose §1.2 grounds itself in an empirical vocabulary, the absence of any comparison to
ACTUS, Marlowe or composing-contracts is a substantive gap, not just a bibliographic one.

**Fix.** Cite everything. Add a related-work section that positions the vocabulary against ACTUS
and Marlowe and states plainly that ACTUS's "vast majority" claim is not a completeness result.

### 24. The Pol–Inv attribution is over-precise in one direction and over-corrected in the other — **minor**

**Location.** `thm:closure` proof and the Remark following it.

**Problem.** (a) The proof cites Geiger/BKKR for "dual-Horn clause sets are those preserved by
coordinatewise maximum". Geiger and BKKR establish the Galois connection $\mathrm{Pol}$–$\mathrm{Inv}$;
they do not, by themselves, give the syntactic characterisation of max-closed relations. The
direction the paper actually *uses* (dual-Horn $\Rightarrow$ union-closed) is a two-line direct
verification needing no citation, and the converse (union-closed $\Rightarrow$ dual-Horn definable)
is the one that needs a real reference — conventionally Schaefer 1978 (weakly positive formulas) or
the standard Horn/dual-Horn characterisation.

(b) The Remark's disclaimer ("this is the Pol–Inv characterisation, not Schaefer's dichotomy...
[Schaefer] is the correct citation for `meas:arity` rather than for this theorem") over-corrects:
Schaefer's Lemma 3.1 is in fact a standard citation for the weakly-positive/weakly-negative
closure characterisation. I cannot verify the sub-lemma lettering without the primary, and I note
the paper's own `refs.bib` hedges on it ("Note after Lemma 3.1B") — but the disclaimer as written
asserts something about Schaefer's content that I do not believe is right.

**Fix.** Prove the used direction inline (two lines) and cite Schaefer for the converse, with a
verbatim quotation if the lettering is in doubt.

### 25. `thm:blocker`'s hypothesis fails on the paper's own data — **minor**

**Location.** Definition [Clutter and blocker] + `thm:blocker` versus `meas:clutter`.

The Definition stipulates $\Haz$ is an antichain; `meas:clutter` reports "one pair fails the
antichain condition by containment". So $b(b(\Haz))=\Haz$ does not hold for $\Haz$ as recorded.
The repair is trivial (pass to minimal members) but must be stated, because the paper then builds
`prop:oneobject` and the whole repair machinery on it.

I did verify `prop:oneobject`'s Seymour identity: from $b(\mathcal{C}/J)=b(\mathcal{C})\setminus J$
and $b(\mathcal{C}\setminus J)=b(\mathcal{C})/J$ one gets
$b(\mathcal{C}\setminus I/J)=b(\mathcal{C}\setminus I)\setminus J=(b(\mathcal{C})/I)\setminus J$,
as printed. Correct.

### 26. Corollary [Minimal repair] is stated imprecisely — **minor**

**Location.** unlabelled Corollary following `thm:blocker`: *"the minimal sets of elements whose
removal restores hazard-freedom are exactly the members of $b(\Haz)$ restricted to $X$."*

**Problem.** $b(\Haz)|_X$ contains covers of $\Haz|_X$ that need not be minimal (any $B\in b(\Haz)$
restricted to $X$ covers the armed rows, but may do so redundantly). The correct object is
$b(\Haz|_X)$ = the *minimal* members of $b(\Haz)|_X$ — which is exactly what `prop:oneobject`'s
deletion minor $b(\Haz\setminus(\El\setminus S))$ computes. The Corollary and the Proposition
disagree; the Proposition is right.

**Fix.** "the minimal members of $b(\Haz)$ restricted to $X$", or state it via the deletion minor.

---

## D. Overclaiming, measurement hygiene, truncated instances

### 27. Eight corpus computations are labelled Proposition or Corollary — **major**

**Location.** `cor:oplusclosed`, `prop:mixed`, `prop:dag`, `prop:perps`, `prop:ct`,
`prop:fibres`, `prop:crosscat`, `prop:hostile`.

Every one of these is a computation over the 72-protocol corpus or the shipped tables. None has a
proof. Under the paper's own Status conventions — which the abstract calls "load-bearing" and
which is the paper's principal claim to be trustworthy — each should be a **Measurement**. This is
measured-and-presented-as-proved, eight times, and it is the exact failure mode the conventions
exist to prevent. It is more damaging here than it would be in a paper that made no such promise.

**Fix.** Relabel all eight as Measurements, each with its instance and enumeration bound.

### 28. The abstract and introduction assert "prohibitions are the sole obstruction", which the body refutes — **major**

**Location.** Abstract ("prohibitions are Horn, destroy that closure, and are the sole obstruction
to admissibility inheriting it" — repeated verbatim in §1.3) versus `prop:mixed`,
`meas:whereitfails`, and the Remark following it.

The body says the opposite, in the authors' own words:

> "Composition failure is therefore not attributable to the prohibition clutter, which is nearly
> inert, but to conditional constraints that fall outside the Horn/dual-Horn classification on
> which Corollary \ref{cor:lattice} rests."

`meas:whereitfails` puts 23% of failures on mixed-polarity clauses that are neither Horn nor
dual-Horn. The authors' own verification file states the finding flatly:
*"`cor:admnotlattice`'s 'prohibitions are the sole obstruction' is **REFUTED**"*
(`formal/v3/VERIFICATION.md`, summary table and §8.2). The correction has been made in §Composition
and **not** propagated to the abstract or the introduction — which are the two places a reader will
quote from.

**Fix.** Abstract and §1.3: "non-dual-Horn clauses are the obstruction, of which prohibitions are
one species and mixed-polarity conditions another."

### 29. `meas:frag`'s "structural upper bound" is the trivial bound — **major**

**Location.** `meas:frag` ("maximality is open in $[11026,\,23055)$") and the Remark
[Consequences of Proposition \ref{prop:clique}] (i): *"those are clique bounds, a witnessed lower
bound and a structural upper bound, not a failure to finish a computation."*

**Problem.** $11026/23055 = 0.4783$, which is precisely the reported $|F|/|\Adm| = 0.478$. So the
upper endpoint of the interval **is $|\Adm|$** — the trivial bound "a clique has at most as many
vertices as the graph". Calling that "a structural upper bound" and contrasting it with "a failure
to finish a computation" inverts the truth: no non-trivial upper bound on $\omega(G_\oplus)$ has
been computed. This is the clearest instance of the paper dressing an absence as a result.

**Fix.** State it as "$\omega(G_\oplus)\ge 11026$; no non-trivial upper bound is known, the
interval's right endpoint being $|\Adm|$."

### 30. Five measurements do not state their instance, and the two most quotable are on truncated ground sets — **major**

**Location.** `meas:arity`, `meas:latticeconf`, `cor:oplusclosed`, `meas:whereitfails`,
`meas:frag` — none states the ground-set size or the pool from which pairs were drawn. The Status
conventions promise "with the instance and bound stated".

Two specific consequences:

(a) **`meas:access` is on 16-element ground sets** ("over four 16-element ground sets (4,580
admissible sets)"), and the Remark following it generalises without qualification: "Admissible sets
therefore cannot in general be built one element at a time, and $\Adm$ is not an antimatroid".
The named witness $\{Ex,Op\}$ may well survive at $|\El|=58$, but the paper does not say so and
does not check it.

(b) **`meas:frag` is evidently on a truncated instance** ($|\Adm|=23055$, which is not the
admissible count at $|\El|=58$), yet `conj:perfect` and §\ref{sec:cfp} discuss $G_\oplus$ on the
full $\Adm$, and the introduction claims perfection "is falsifiable by a finite search". Finite it
is; feasible at 58 elements it is not, and the paper should say which instance the conjecture is
being posed over.

Given the history of favourable results from truncated instances, every measurement needs
$|\El|$, pool size, sampling scheme and (if sampled) seed printed with it.

**Fix.** Add an instance column to every Measurement. Where a result was obtained on a truncated
ground set, say so *in the Measurement*, not only in the supporting material.

### 31. `meas:latticeconf`'s figure 51,917 is a seeded sample statistic reported as exact — **minor**

**Location.** `meas:latticeconf`.

The authors' own verification (`formal/v3/VERIFICATION.md` §6) reports 50,223 / 50,611 / 50,276
for seeds 1–3 and notes "51,917 is within ~3% of the seeded reruns — consistent, but it is a
sample statistic reported as if exact." The paper still prints it bare. Contrast
`meas:closureprops`, which *has* been converted to exhaustive figures (179,864,061 pairs / 68,058
failures) — the same treatment should be applied here.

**Fix.** Replace with the exhaustive figure (`|pool|=8023`, 32,188,276 pairs, 396,437 intersection
violations) or mark as sampled with the seed.

### 32. `cor:ourconvex` says the digraph has 15 arcs; `meas:compress` says 13 — **minor**

**Location.** `cor:ourconvex` and Remark [Honest scale] ("$D$ has 15 arcs") versus `meas:compress`
("The specialization poset has 13 arcs").

The supporting material resolves it and against the paper: `formal/v3/m5.out` gives 13 arcs
(12 distinct) for the corrected law system `L*`, and 16 arcs (15 distinct) for the raw `data.ts`
parse. `VERIFICATION.md` §9: *"'15 arcs' is the wrong table."* Nothing downstream changes (both
digraphs are acyclic), but two different numbers for the same object appear four pages apart.

**Fix.** Use 13 (or 12 distinct) throughout, and name the extraction.

### 33. `cor:ourconvex` supports a $2^{58}$ claim with a 21,712-seed check — **minor**

**Location.** `cor:ourconvex`: *"$Cn$ coincides with reachability in $D$ (checked on 21,712
seeds). Apply Theorem \ref{thm:convex}"*, concluding "on all $2^{58}$ subsets".

$Cn$ = reachability is immediate from the definition of the definite closure and should be
*proved*, in one line, not sampled. As it stands a Corollary claiming a property of all $2^{58}$
subsets rests visibly on 21,712 checks; a reader who does not notice that the check is
inessential will read it as a sampling argument for a universal claim.

**Fix.** Prove $Cn = $ reachability; keep the enumeration as corroboration.

### 34. `X21` is the dominant exclusion source but is not one of the recorded prohibition rows — **minor**

**Location.** `meas:ablation58` ("Every one of the 61 exclusions is attributable to two
hand-written prohibitions, $X21$ ($32/72$) and $X2$ ($8/72$)") versus `meas:clutter` ("Of the 20
recorded prohibition rows, exactly one — $X2$ — is a positive element set and hence enforceable by
membership").

If only $X2$ among the 20 rows is enforceable by membership, then $X21$ cannot be one of the 20
rows, and indeed `VERIFICATION.md` §8 says `X21`, `X19*`, `X18`, `X11a*` "are hand-written
predicates in the model, not table rows". The paper never tells the reader this. A reader will
take $X21$ for the twenty-first row of a twenty-row table.

Secondary: 37 of 72 seeds have upper bound exactly $\top$, so 35 seeds carry exclusions, but
$32+8=40$ seed-attributions are reported; the two are reconcilable only if 5 seeds are hit by both
rows. Say so.

**Fix.** Introduce the hand-written conditional rows as a named family, distinct from the 20-row
clutter, before using their labels.

### 35. 59% and 90% are both presented as the corpus pair-composition rate — **minor**

**Location.** `meas:frag` ("certifies 59% of live protocol pairs") + Remark
[Consequences] (iii) ("The reported 59% of live protocol pairs is the density of $G_\oplus$
restricted to the 72 corpus protocols") versus `meas:pairs` ("Of the 1,830 unordered pairs...
1,645 (90%) compose to an admissible set").

If 59% is the edge density of $G_\oplus$ on the corpus, it should be 90% (or 64% if all
$\binom{72}{2}=2556$ pairs are counted). The two numbers cannot both be what remark (iii) says
they are.

**Fix.** Reconcile, and state which vertex set each figure is over.

### 36. `cor:ex` is applied to 11 protocols to which it does not apply — **minor**

**Location.** §\ref{sec:apply} ("Computing it for the 72 decomposed protocols") versus `cor:ex`
("Every **closed** set $A$ has a unique minimal generator") versus `meas:pairs` ("Sixty-one of the
72 protocols satisfy the requirements and warrants").

Eleven protocols are not models, hence need not be $Cn$-closed, hence $\mathrm{ex}(A)=\max_\preceq(A)$
need not generate $A$ (if $x\to y$ is definite and $A=\{x\}$, then $Cn(\max A)=\{x,y\}\ne A$).
`meas:compress`, `prop:perps` and `prop:ct` all range over the 72.

**Fix.** Restrict §\ref{sec:apply} to the 61, or state that the canonical form is computed on
$Cn(A)$ rather than $A$ for the remainder.

### 37. `prop:crosscat` has no base-rate correction — **minor**

**Location.** `prop:crosscat`: "Of the 185 failing pairs, 182 join protocols from different
categories and 3 from the same. Composition within a category is essentially always safe."

With twelve categories, same-category pairs are roughly one twelfth of the 1,830, so the raw
counts 182 vs 3 conflate the effect with the base rate. The *rates* (roughly 11% vs 2%) still show
a real effect of about 5×, which is worth reporting — but the proposition as phrased invites the
reader to see a 60× effect.

**Fix.** Report per-stratum rates with denominators.

### 38. The abstract states measured results in the register of proved ones — **minor**

**Location.** Abstract: "...and that the positive theory does not constrain any completion of any
protocol in the corpus", introduced by "We show that...".

`meas:ablation58` is a Measurement, correctly labelled in the body and correctly caveated in its
Remark. The abstract presents it in the same breath and the same grammatical construction as
`thm:closure` and `cor:lattice`. Similarly, `prop:collapse`'s hypotheses (i) and (ii) are
empirical facts about the vocabulary, which the abstract's "reasoning over the full powerset
collapses for reasons intrinsic to the constraint set" does not signal.

For a paper that makes epistemic labelling its distinguishing virtue, the abstract should carry
the labels: "we prove... ; we measure...".

### 39. Smaller items — **editorial**

39a. `conj:fibre` is labelled a Conjecture, but its existential half is *measured*
(`prop:fibres` names the collision classes USDT/USD1, LiquidMesh/KyberSwap, Binance Wallet/OKX DEX,
Jupiter/1inch). Only "materially different solvency" is conjectural. Also "Hence no function of
$2^{\El}$ separates them" is a tautology (equal element sets have equal images under any function
of the element set) presented as a consequence.

39b. The compatibility graph is declared "simple" and then argued to have a loop at every vertex
(`prop:clique`'s proof: "self-loops are present for every vertex"). Simple graphs have no loops.
Say instead: $A\oplus A\in\Adm$ for every $A\in\Adm$, so singletons are cliques.

39c. `prop:ct` lists Rysk and Panoptic among "lending and collateralised-debt protocol[s]". Both
are options protocols. Either widen the class name or move them.

39d. `ex:comp`: $|\mathrm{ex}(\text{Aave})|=16$, $|\mathrm{ex}(\text{Uniswap})|=7$, "nothing
dropped", and "the remaining 38 elements". $58-38=20\ne 23$, so the two generator sets must share
exactly three elements. State that.

39e. Remark [Distributivity] uses "standard" (closure system) without definition.

39f. Several Corollaries are unlabelled (the one after `thm:aft`, the one after `prop:dag`, the
Minimal repair one), which makes them uncitable.

39g. The paper never mentions the Lean development. Given that `lean/Defialgebra/Polarity.lean`,
`Lattice.lean` and `ConvexGeometry.lean` machine-check `lem:polarity`, `thm:closure` (including
the negative halves the paper defers), `cor:lattice`, `thm:convex` and `thm:excomp` with no
`sorry`, no `axiom` and no `native_decide`, this is the strongest evidence the submission has and
it is invisible to a reader. Add a paragraph, with the axiom-dependency statement.

---

## Proof sketches: gap or routine?

The remit asks for a verdict on each.

| Item | Verdict |
|---|---|
| `thm:bilattice` ("Proof sketch") | **Conceals a gap.** Three defects (Finding 18): $\Adm$ is not the diagonal; "definable object" is undefined; the "componentwise structure cannot distinguish it" step is asserted, not argued. Not routine. |
| `thm:convex` ("Proof sketch") | **Routine in substance, two repairable defects.** The mathematics is standard and correct once $Cn(\emptyset)=\emptyset$ is added (Finding 7) and the misdirected appeal to `lem:ej` is replaced by three lines (Finding 8). |
| `thm:aft` (full proof) | **Genuinely routine and correct.** Best proof in the paper. |
| `prop:collapse` (full proof) | **Correct**, one unstated hypothesis $\emptyset\notin\Haz$ (Finding 20). |
| `thm:excomp` (full proof) | **Correct mathematics; the statement is missing its hypothesis** (Finding 15) and is about a different $\oplus$ than the rest of the paper (Finding 17). |
| `cor:lattice` (full proof) | **Correct**, one unstated hypothesis $C(e)\neq\emptyset$ (Finding 10). |
| `prop:joinmeet` (full proof) | **Correct as now stated**; the concrete meet value is asserted (Finding 11). |
| `thm:closure` (full proof) | **Positive halves fine** (though over-cited, Finding 24); negative halves deferred to a witness covering one of three (Finding 14). |
| `thm:noncong` | **No proof at all** (Finding 22). |
| `prop:twoeffects`, `prop:vacuous`, `prop:noinvariance` | **Fine.** `prop:vacuous` is the one place a nonemptiness hypothesis is correctly stated; `prop:noinvariance`'s witness checks out. |

## What I checked and did not find fault with

So that the negative findings are calibrated: I verified by hand the correctness of the
`thm:excomp` identity for finite posets (both inclusions), the `thm:aft` chain, the
`prop:collapse` fixpoint argument, the anti-exchange property of down-sets, Seymour's identity as
used in `prop:oneobject`, the arithmetic of `meas:closureprops` (a pool of ~18,970 $\mathcal{R}$-members
of size $\le3$ is consistent with 179,864,061 pairs and with $\binom{58}{\le3}=32{,}568$),
`meas:noinvariance` (224,025 $\le \binom{58}{\le4}=456{,}838$), `meas:ablation58`'s clause
partition ($31+27+21+14=93$, $31+27+21=79$), `prop:hostile` against $\binom{61}{2}=1830$, and the
`meas:frag` ratio $11026/23055=0.478$. I ran no code. The Lean tree builds clean per
`VERIFICATION.md` and I read `Obstruction.lean` directly; its `aft_obstruction` is correct and its
`Consistent Γ Δ` is assumed rather than derived, as the authors themselves record.

---

## Recommendation

**Major revision.**

The core order-theoretic content is sound and, where I could check it, correct: `lem:polarity`,
`thm:closure`, `cor:lattice`, `thm:aft`, `prop:collapse`, `thm:convex` and `thm:excomp` are true
statements with valid (if occasionally under-hypothesised) arguments, and the Lean development
backs the most important of them. The paper's instinct — separate what is proved from what is
measured, and report obstructions as results — is the right one and is unusual enough to be worth
publishing. But the manuscript does not yet live up to its own standard. Three problems are
disqualifying in their present form: an operator $\Gamma$ that appears in eight statements and is
defined nowhere, in a paper that elsewhere argues no such operator exists (Finding 1); an abstract
and introduction that assert "prohibitions are the sole obstruction" while the body, and the
authors' own verification file, refute it (Finding 28); and a systematic mismatch between the
object the theorems quantify over ($\mathcal{R}\cap\mathcal{W}\cap\mathcal{H}$) and the object the
measurements evaluate (which adds 21 undefined "grounding" clauses, mixed-polarity conditions, and
conditional prohibitions outside the stated definition) (Finding 3). Alongside these sit eight
corpus computations labelled as Propositions and Corollaries (Finding 27), an "upper bound" that is
the trivial bound (Finding 29), five measurements with no stated instance and two headline ones on
truncated ground sets (Finding 30), and a bibliography of three items supporting fifteen named
theorems (Finding 23). None of this requires new mathematics; all of it requires the authors to
apply to the manuscript the discipline they applied to `formal/v3/VERIFICATION.md`, which caught
several of these problems and whose corrections were only partly propagated back into the paper.
I would review a revision.
