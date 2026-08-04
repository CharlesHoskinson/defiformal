# Literature wave 2 — planned from what we must prove

Wave 1 gave us positioning. This wave is targeted at four specific proof
obligations. Each lane exists because a named claim in `paper/atlas.tex` is
currently unproved, mis-attributed, or trivially true in a way we have not
admitted.

---

## What we now know, which determines what to review

**Proved from clause polarity** (no measurement needed): requirements and
warrants are dual-Horn, prohibitions Horn; $\mathcal{R} \cap \mathcal{W}$ is
union-closed, hence a complete lattice with $\bigvee = \bigcup$; meet is not
intersection; prohibitions are the sole obstruction to admissibility inheriting
it.

**Just verified**: compatibility is *trace-determined*. Because
$\mathcal{R}\cap\mathcal{W}$ is union-closed, $A \oplus B$ can only fail by a
prohibition covered by $A \cup B$ and by neither alone. So compatibility depends
only on the traces $H \cap A$. Measured: 0 inconsistencies in 1,936 checks,
9 distinct traces over 4,000 sampled models. The compatibility graph is a
**blow-up of a 9-vertex quotient**, and blow-ups of perfect graphs are perfect.

**The caveat that must go in the paper**: that quotient is *complete* — density
1.000. Only one prohibition row ($X2 = \{Fl,Cp,Cl,Pl,Cd\}$) is an enforceable
positive element set, and no union of sampled models covers all five. So
perfection holds, but trivially, and the composition failures we measured must
originate in the non-membership conditions (grounding, conditional bans) rather
than in the prohibition clutter. **We have been attributing composition failure
to the wrong constraints.**

---

## Lane 1 — Clone theory and the Pol–Inv Galois connection

*Why:* wave 1 reported that maximality **is** settled one level down — the
largest union-preserved constraint *language* is exactly dual-Horn, by Pol–Inv —
while our question is about the largest union-closed *subfamily of a model set*.
That is the single most important positioning claim in the paper and it is
currently second-hand.

Get: Geiger 1968 and Bodnarchuk–Kaluzhnin–Kotov–Romov 1969 (the Galois
connection); Post's lattice with the dual-Horn/$\max$ clone identified exactly;
Pöschel's survey. Establish precisely **what is settled for languages and why it
does not settle the model-set question**, with a citable statement of each.
Also: is "largest union-closed subfamily of a given family" studied anywhere
under another name?

## Lane 2 — Convex geometry: the proof, not the measurement

*Why:* the audit asserts that `conj:convex` is a two-line theorem — bodies and
heads disjoint (height 1) implies anti-exchange — and that our 1,697-set
measurement is the same truncation defect we diagnosed elsewhere, since there are
$\approx 10^{15}$ closed sets. If it is a theorem we should prove it and delete
the measurement.

Get: Edelman–Jamison 1985 with the anti-exchange definition verbatim and the
equivalence theorem numbering; Korte–Lovász–Schrader on antimatroids; the
**meet-distributive lattice** equivalence (Dilworth 1940, Edelman) — we measured
distributivity and anti-exchange separately and they may be one fact reported
twice. Settle whether reachability closures of single-consequent rule systems are
known to be anti-exchange.

## Lane 3 — Perfect graphs, blow-ups, and the CSP precedent

*Why:* our clique reformulation needs both an honest precedent citation and a
rigorous blow-up argument.

Get: Jégou 1993 microstructure and Salamon–Jeavons *Perfect Constraints Are
Tractable* (CP 2008) — establish exactly what they prove (clique on the
**assignment** graph, where an $n$-clique is one solution) so we can claim only
the transfer to a compatibility graph on the **solution set**. Get the
Strong Perfect Graph Theorem and Grötschel–Lovász–Schrijver. And get the
**blow-up/substitution lemma** for perfect graphs (Lovász 1972 replication) with
a precise statement, since our reduction depends on it.

## Lane 4 — Completeness that survives review

*Why:* we cannot cite ACTUS as a completeness result — wave 1 found it hedges
verbatim ("vast majority", "about 32", grown from 18). We need a defensible
notion.

Get: the Kondratiuk–Lamela Seijas–Nemish–Thompson FC 2021 WTSC paper in full —
it is the census-drives-extension loop, published, including coverage failures,
and it is the precedent our completeness definition rests on. Then: conservative
extension in algebraic specification; Felleisen expressiveness with the exact
macro-eliminability statement; and Grüninger–Fox competency questions. Deliver
**one paragraph of publishable text** defining completeness for this paper, with
citations, that a reviewer cannot dismiss as coverage-by-assertion.

---

## What each lane must return

- PDFs and extractions under `papers/<lane>/`
- `INVENTORY.md`: per source — citation, the theorem verbatim, and the specific
  claim in `atlas.tex` it supports, contradicts, or should replace
- **A one-paragraph draft of the paper text it enables**, so the review converts
  directly into the document rather than into notes about the document
