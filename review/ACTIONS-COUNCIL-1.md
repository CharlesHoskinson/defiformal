# Council pass 1 — what was actioned

GPT-5.6 Sol, cold read, read-only, with node, Quint, Lean 4 + mathlib, and an
instruction to demand evidence and to run rather than reason. Target: the
Constructions section and the twelve category sections. Report:
`review/COUNCIL-atlas-v1.md`. It returned 1 BLOCKING, 8 MAJOR, 3 MINOR, 0 NIT.

## Actioned

### BLOCKING 1 — two admissibility predicates, and the paper named neither

**The finding, and where it is right.** The repository contains two inequivalent
admissibility predicates: the $29$ recorded requirement rows under the corrected
parser, and a reduced system of $11$ rows over $10$ subjects exported as
`tables.mjs::admissible`. The construction checker uses the first. The auditor
recomputed the Constructions measurement under the second and got $4{,}545$
sound and $88$ minimal against the published $3{,}930$ and $60$. Its arithmetic
reproduces exactly.

**Where it is wrong.** The auditor called the reduced system "the repository's
exported corrected predicate" and concluded the published counts are for a
"private predicate". Checked: the paper's own thrice-refereed figures — $61$ of
$72$, $1{,}830$ pairs, $185$ failures — come from the recorded rows, and under
the reduced system they would read $65$, $2{,}080$ and $201$, contradicting the
published paper. The checker is consistent with the paper; the reduced system is
the outlier, and it is a *fragment*: its rows have subjects
$\{Cd,Gs,Im,Of,Op,Pf,Pl,Py,Rl,Uc\}$ only, so it is silent wherever a recorded
requirement has another subject. It is not a correction of the recorded rows.

**The real defect, which is still blocking, and the fix.** The paper never said
which predicate it meant, and the two disagree on $675$ of $65{,}536$ sets over
the declared universe. That ambiguity is load-bearing, because both readings are
correctly described as "computed". Actioned: `\label{rem:predicate}` now names
the predicate, and `\label{meas:predfork}` records the disagreement as a
measurement — $64{,}861$ agree, $657$ admitted only by the reduced system, $18$
only by the recorded rows — together with what the Constructions measurement
would read under the other choice. An ambiguity has been converted into a stated
result rather than silently resolved.

### MINOR 10 — "second smallest" was false for yield

Confirmed by computation. Ranked by mean element-set size the twelve run:
intents $2.75$, bridges $5.57$, fiat stablecoins $6.4$, prediction $6.4$, spot
exchange $7.4$, **yield $8.0$**, options $10$, liquid staking $10.6$, RWA
$11.6$, perpetuals $11.86$, CDP $12.17$, lending $13.33$. Yield is sixth, not
second. Corrected. The same sentence carried "the category that holds the third
largest capital", which was never measured; removed rather than defended. The
identical unmeasured capital clause was removed from the bridges footprint
measurement, where the *ranking* claim was correct.

### MINOR 11 — the lead-in overclaimed uniformity

It said every section reports four things including canonical-form behaviour.
Several report nothing there because there is nothing to report. The lead-in now
claims only what is uniform and says canonical form is reported where it does
something.

### MAJOR 9 — the Lean claim was an overclaim in two specific places

Checked against the development: 1,255 lines over six files, no `sorry`, no
`admit`, no custom `axiom` declaration, and the auditor independently ran
`lake build` (734 jobs) and the axiom audit, confirming every declaration
depends only on `propext`, `Classical.choice` and `Quot.sound`. Those parts of
the claim stand.

Two parts did not. `thm:excomp` asserts the composite is computable in time
linear in the size of the two generators; the Lean declaration is an equality of
finite sets, with no algorithm, no cost model and no complexity bound, so the
linear-time half was never formalised. And the negative halves of `thm:closure`
are witnessed *generically* in Lean — there exist dual-Horn and purely negative
classes lacking the opposite closure — not for this paper's own model classes,
whose failures rest on the explicit counterexamples in the text.

Actioned: the section now enumerates the formalised statements and all three
gaps, including that the atlas itself is not formalised, in labelled paragraphs.
A formalisation claim is worth exactly as much as its statement, and the
previous wording claimed five named results where it had parts of five.

### MAJOR 7 — the resolution claim is now measured, and the capital half demoted

The claim had two halves and only one is measurable from this corpus.

Measured: over the twelve categories, the Spearman rank correlation between the
number of distinct elements a category's five constructions use and the fraction
of their obligations those constructions discharge is **rho = 0.874**. Coverage
runs from 26.5% on intents, using ten distinct elements, to 59.1% on perpetuals,
using twenty-six. Resolution and coverage are not independent axes.

Not measured, and now said so: the relation to capital. Capital enters this
corpus only as a selection criterion and never as a quantity, so a correlation
computed against it would be a correlation against our own sampling rule. It is
recorded as an observation about the sample rather than a measurement.

Computed by `formal/v3/coverage.mjs`, committed with the claim.

## Not yet actioned — carried to the next firing

| # | severity | finding | disposition |
|---|---|---|---|
| 2 | MAJOR | category boundaries called a sampling frame are partly editorial | likely correct; the "& other" category is the clearest case and the lead-in should concede it |
| 3 | MAJOR | protocol-behaviour claims in the atlas carry no claim-level citations | correct as stated; the citations exist in `expansion/*/01-research.md` and enter the paper with the subsections at stage 6 |
| 4 | MAJOR | `prop:neither` contains a non sequitur about monotone search | needs adjudication: the proposition's *witnesses* verify, but the inference drawn from them may overreach |
| 5 | MAJOR | the proof confuses a clutter with its downward-closed model class | needs care; this is a genuine distinction and the parenthetical may be sloppy |
| 6 | MAJOR | `cor:notthe` generalises from one restricted finite instance | probably correct — the corollary should be scoped to the instance or restated as a conjecture |
| 8 | MAJOR | `validate.mjs` admits evidence-defective specs | actionable directly in the checker |
| 12 | MINOR | no sensitivity analysis for candidate-status elements | cheap to run and worth doing |

**Next mechanical step:** pin both predicate counts as assertions in
`formal/v3/selftest.mjs`, so the fork cannot move silently again.
