# Council proposal — experimental design and pre-registration

## 0. Verdict in one paragraph

I recomputed the failure population from `expansion/*/specs/*.json` before designing.
The 60 specs contain **59 distinct construction sets** (duplicate: *World Liberty
Financial USD1*), giving C(59,2) = **1711** — the brief's denominator, confirmed. Of
the flat failures, **92 arise from the single element pair `(Fl, Xf)`, 4 from
`(Fl, Rl)`, 0 from `(Fl, Of)`**; only **5 protocols carry `Fl`**. So the 82.4%
headline is not 119 observations. It is **one binary decision — is `ℓ(Fl) ∩ ℓ(Xf)`
empty?** — multiplied by corpus combinatorics. Under a uniform-random-subset null,
that decision goes the theory's way with probability **0.187**; under an
interval-shaped null, **0.311**. Therefore *the ≥70% confirm threshold cannot yield a
significant result no matter how the blind run comes out*: its p-value floor is ~0.19.
The threshold is not reverse-engineered from 82.4% — it is worse than that, it is
**inert**, because the attainable outcome space has about four points and 70% merely
names which side of the one live decision we are on. My design keeps the blind run
(it is cheap and it is the right instinct) but moves the confirmatory weight onto two
statistics that have real n and real nulls, adds three negative controls, and replaces
the inequality with a conjunctive point prediction whose null probability is 0.039.

## 1. Design

### 1.1 The information barrier, file by file

The barrier is **not file-level**. `paper/formal-data.tex` (186 lines) holds the
element table *with the stratum column*, the 29 requirement rows (= the arity answer),
the warrants relation, and the 20 prohibitions — all four targets in one file. Worse,
`docs/UNIFIED-DEFI-ELEMENT-TABLE.md` §15 states the conclusion in prose: *"`Fl` is the
only async-impossible element… no cross-chain flash liquidity exists."* Its §4 tables
carry `str` and `atom` columns; `atom = I` for `Fl` alone. And
`consolidated/STRUCTURE-DEFINITIONS.md` Def. 4 says outright that stratum *is* read as
`H`. Any assigner who reads any of these is reading the answer key.

**Quarantine list (assigners see none of these):**
`paper/formal-data.tex`, `paper/atlas.tex`, `paper/atlas.pdf`, `paper/supplement.tex`,
`docs/UNIFIED-DEFI-ELEMENT-TABLE.md`, `docs/unified-v0.1.md`, `council/*`,
`expansion/*/specs/*.json`, `expansion/*/FINDINGS-*.md`,
`research/positive-program/requirements/*`, `.../consolidated/*`, `.../insights/*`,
`algebra/**`, `quint-models/**`, `protocol-repos/**`, and **every `graphify-out/`
directory** (`graph.json` re-serialises the lot).

**Permitted stimulus — one generated file, `STIMULUS-{ar,ell}.md`**, built by the
architect from `UNIFIED-DEFI-ELEMENT-TABLE.md` §4 by projecting **exactly three
columns: opaque ID, Name, Definition**. Stripped: `str`, `atom`, `layer`, group ID,
group role-boundary heading, isotope/discriminator prose, all §5–§20 text. Symbols are
replaced by opaque IDs `Z01…Z58` in a seeded random order, because a DeFi-literate
assigner recognises `Fl` and `Xf` and imports the folklore. The architect holds
`KEY.json` (ID → symbol) and does not open it until step 7.

Disclose in advance, in the pre-registration: `Fl`'s definition text — *"Borrow and
repay within one settlement scope or revert"* — **forces** `ℓ(Fl) = {h₀}`. That is not
a flaw; it is proof obligation PO-SHF-1 being true. It does mean **the entire
experimental risk sits in one cell: `ℓ(Xf)`**, whose definition — *"Create a
destination claim against an explicit source debit"* — does not obviously exclude
`h₀`. Say this before the run, or a referee will say it after.

### 1.2 Live-set shape constraint (must be fixed before assignment)

Pre-register the admissible family. If live-sets are required to be **up-closed** or
**down-closed** intervals, two of them *always* intersect and dissolution is
**a priori impossible** — the theory is refuted by the coding manual, not by data. I
computed this: P(disjoint) = 0 for both. Fix the family as **arbitrary non-empty
subsets of H** (|F| = 31). This maximises attainable evidence and defines the null.

### 1.3 Assigners and reliability

Three independent assigners, **full overlap on all 58 rows** (58 is too small to
subsample), no communication, each producing both tables. Statistics:
- `ℓ` (set-valued): **Krippendorff's α with the MASI distance** (Passonneau 2006).
- `ar` (nominal, 9 colours, per port): **Fleiss' κ**; plus exact port-sequence match.

**Discard threshold: α or κ < 0.667** (Krippendorff's own floor for tentative
conclusions). Below it the instrument is unreliable and *no verdict on C1/P1 is
issued* — this is the defect the prior effort admitted to and must not repeat.

Consensus table: **per-horizon-bit majority of 3** for `ℓ`, **per-port-position
majority of 3** for `ar`. Three raters make majority deterministic; there is **no
adjudication step**, because adjudication-while-seeing-the-outcome is precisely what
moved coverage 16.3 points last time. Ties in `ar` port *count* (raters disagree on
arity length) resolve to the **median count**, then pad with `⊥`.

Underdetermined rows: the manual requires the assigner to mark `UNDET` and still give
a best guess. `UNDET` rate is reported; rows `UNDET` by ≥2 of 3 raters are excluded
from the confirmatory analysis and reported separately as a **pre-registered
sensitivity arm**, never as a post-hoc exclusion.

### 1.4 Negative controls — the part I insist on

Three, all cheap, all run **before** the real analysis is unblinded:

**N1 — decoy stimulus.** A fourth assigner receives the same 58 definitions
**permuted onto the wrong IDs** (seeded). If the instrument still produces the
predicted pattern, the instrument is reading its own prior, not the definitions.

**N2 — permutation null on `ℓ`.** Shuffle the consensus live-sets across the 53
corpus-realised elements, 10⁵ draws, recompute dissolution. Exact p = fraction of
permutations reaching the observed statistic. This is the number that decides the
scope claim, not the raw percentage.

**N3 — sham grading.** Rerun the whole pipeline with `H` replaced by the atlas's
irrelevant `layer` (CAKE A/P/S/T) column, embedded as a 5-chain. If a sham grading
also dissolves ≥70%, the effect is corpus sparsity, not horizons, and the finding is
void regardless of the main result.

Analytic baselines, already computed, to be recorded in the pre-registration so they
cannot drift: P(`ℓ(Fl)` ⌒ `ℓ(Xf)` disjoint) = **0.187** (arbitrary subsets),
**0.311** (intervals); P(X21 fully dissolves **and** X2 survives) = **0.039**
(subsets), **0.072** (intervals).

## 2. Pre-registered hypotheses and thresholds

Frozen, in this order, **before any assigner is briefed**, committed as
`PREREG.md` + `git tag prereg-v1` + SHA-256 of `STIMULUS-*.md`, `KEY.json`,
`CLAUSES.json`, `POPULATION.json`.

| # | Hypothesis | Direction | Confirm | Refute |
|---|---|---|---|---|
| **H1** *(co-primary, high-n)* | Colour homogeneity: each non-empty requirement term's alternatives share one colour under blind `ar` | ρ ≥ 0.958 predicted | ρ ≥ 20/24 **and** exact-binomial p < 0.01 vs. colour-marginal null | ρ ≤ 17/24 |
| **H2** *(co-primary, n≈2)* | Conjunctive scope: `ℓ(Fl)∩ℓ(Xf)=∅` **and** `ℓ(Fl)∩ℓ(Rl)=∅` **and** X2's arms remain co-live | point prediction | both disjointnesses hold, X2 survives, permutation p ≤ 0.05 | either disjointness fails |
| **H3** *(secondary)* | 6 order-book perps venues drop exactly `{Ct,Ex,Li}`; Jupiter drops none | point | ≥5/6 exact + Jupiter 0 | ≤3/6 |
| **H4** *(secondary)* | GYO residue of the trigger sub-cover ≤ 5 hyperedges, residual locus ⊆ `Star(Fl)` | point | both hold | residue grows above flat |
| **H0-rel** | Instrument reliability | — | α, κ ≥ 0.667 | < 0.667 ⇒ **run discarded** |

**On the ≥70% figure.** Keep it, demote it. It is reported as a *descriptive effect
size with a permutation p attached*, never as the verdict. My audit of the 70/40 band:
it is not fitted to 82.4%, but the attainable outcome space is ~4 points
(0%, ~16%, ~72–82%, 100%) and the 40–70% "refute-or-nothing" band is essentially
**empty of attainable values** — a dead band that can never be observed. Worse, under
my recount dissolving only `(Fl,Xf)` yields **71.9%**, clearing 70% by 1.9 points; the
verdict is therefore hostage to the 119-vs-128 population definition, which is
currently unfrozen. **Pre-register the full outcome lattice instead**: the architect
can enumerate every attainable dissolution value *before any assigner works*, because
it depends only on the corpus and the two clauses, and map each cell to a verdict.

**Note H4's over-prediction trap:** 100% dissolution is a **refutation**, not a
triumph. The theory predicts a *named residue* (X2, one triangle). A blind `ℓ` that
dissolves everything falsifies the residue claim.

## 3. Analysis procedure

Executed strictly in this order; each step's output is hashed and committed before the
next begins.

1. **Close the D discrepancy** (15 vs 18 arcs) by a person who will not assign, and
   freeze `D` in `PREREG.md`. Freeze the formal statement of **X21** (it appears in no
   published table) and X2 into `CLAUSES.json`.
2. **Freeze the population**: 59 deduplicated constructions, 1711 pairs, "new-arming"
   semantics (union arms; neither side arms alone) — `POPULATION.json`. Primary =
   60-construction; the 72-decomposition is a pre-registered replication, reported
   whatever it says. Which is primary is fixed **here**, not later.
3. **Generate** `STIMULUS-ar.md`, `STIMULUS-ell.md`, `KEY.json`. Diff the stimulus
   against the quarantine list mechanically: grep it for `S0|S1|S2|S3|S4`, `atom`,
   `stratum`, `h₀`, `X1`–`X21`, `L1`–`L29`, and every protocol name in the corpus. Any
   hit aborts the run.
4. **Tag** `prereg-v1`. Everything above is now immutable.
5. **Assign.** 3 assigners × 2 tables, blind, no communication, no access to the repo.
   4th assigner runs N1 on the decoy stimulus.
6. **Reliability first.** Compute α and κ. If either < 0.667, stop and report
   `no verdict`. Reliability is computed **before** unblinding, on IDs, so a poor α
   cannot be rescued by looking at outcomes.
7. **Unblind IDs** via `KEY.json`. Build the consensus tables mechanically.
8. **Score** H1–H4, then run N2 and N3. Report every pre-registered arm including the
   ones that fail.

No step may be revisited. Any post-hoc change is recorded in a `DEVIATIONS.md` and the
affected hypothesis is demoted to exploratory.

## 4. Falsification conditions

The structure is killed by any one of: α or κ < 0.667 (instrument, not theory,
but no claim survives it); `ℓ(Fl) ∩ ℓ(Xf) ≠ ∅` under consensus; dissolution
permutation p > 0.05; ρ ≤ 17/24; N1 (decoy) reproducing the pattern; N3 (sham grading)
reaching ≥70%; GYO residue exceeding the flat baseline; or 100% dissolution, which
falsifies the named residue.

## 5. Threats to validity and mitigations

| Threat | Mitigation |
|---|---|
| **Effective n = 1.** 92/96 X21 failures are one element pair. | Disclose in the abstract. Move confirmatory weight to H1 (n = 24). Report H2 as a single-decision prediction with its exact p, never as "119 observations". |
| **Definitional entailment** — `Fl`'s definition contains its own live-set. | Declared in advance as PO-SHF-1; risk relocated to `ℓ(Xf)` and named. |
| **Stratum leakage** — stratum *is* the answer and sits in the same file as the names. | Column-level projection into a generated stimulus + mechanical grep gate (step 3). |
| **Symbol folklore** — assigners recognise `Fl`/`Xf`. | Opaque IDs `Z01…Z58`, shuffled; key held by architect. |
| **Population drift** (119 vs 128; 1770 vs 1711). | Frozen in step 2 with a duplicate-removal rule and the exact arming predicate. |
| **X21 is unpublished** — its arms could be edited to fit. | Frozen and hashed in `CLAUSES.json` before assignment. |
| **Adjudication leakage** — the prior 16.3-point move. | No adjudication exists; per-bit majority of 3 is deterministic. |
| **Assigner expectancy** (Rosenthal). | Assigners are told the task is table construction, not that a dissolution hypothesis exists; N1 decoy detects a prior-driven instrument. |
| **Multiplicity** across H1–H4 + 2 populations. | Two co-primaries declared; H3/H4 secondary; Holm correction within the secondary family. |

## 6. Interface requirements on other surfaces

- **Coding-manual surface:** must deliver decision rules that make `UNDET` a *usable*
  code, and must not reference stratum, atomicity, or any protocol.
- **Formal/semantics surface:** must supply the exact arming predicate for X21 and X2
  as executable code, and must state whether `ℓ` may be empty (I assume non-empty).
- **Corpus surface:** must adjudicate 15-vs-18 arcs on `D` and the 60-vs-59
  deduplication **before** step 4, by someone excluded from assignment.

## 7. What I would cut if we had one day instead of two

Cut H3 and H4. Cut the 72-decomposition replication. Cut the third assigner (use two,
report Cohen's κ / α on two raters, accept a weaker reliability claim). **Keep, in
priority order: the generated stimulus + grep gate; H1; H2 with N2; and N1.** The
permutation null (N2) is one hour of compute and is the difference between a finding
and a number. If only one thing survives, it is N2.

## DISSENT

**The sprint as scoped cannot deliver a decisive verdict on C1/P1 via the dissolution
statistic, and no amount of blinding fixes that.** The defect is arithmetic, not
procedural: the failure population collapses onto one element pair, so the confirmatory
statistic has an effective sample size of one, and its null probability floor is 0.187.
A perfect, faultlessly blinded run therefore cannot report p < 0.05 on the ≥70%
criterion. Blinding converts a fit into a prediction; it does not convert a prediction
with n = 1 into evidence. Presenting "82.4% of composition failures dissolve" as a
principal result — even blind — invites exactly the referee objection it was meant to
answer, in a stronger form: *you have one coin flip and a large denominator.*

What I would do instead, and what I have specified above: make **H1 (colour
homogeneity, n = 24, exact binomial against a colour-marginal null)** the principal
confirmatory test, because it is the only test in this sprint with genuine power and a
genuine chance of failing; report **H2 as a conjunctive point prediction with its exact
permutation p (floor 0.039)**, honestly labelled as a single structural decision; and
**refuse to publish any dissolution figure that is not accompanied by N2 and N3.**
If the council adopts the ≥70% inequality as the headline verdict, record this dissent
verbatim: the threshold is inert, its dead band is unattainable, and the number it
gates is one bit wide.
