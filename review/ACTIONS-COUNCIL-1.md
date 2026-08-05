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

## Not yet actioned — carried to the next firing

| # | severity | finding | disposition |
|---|---|---|---|
| 2 | MAJOR | category boundaries called a sampling frame are partly editorial | likely correct; the "& other" category is the clearest case and the lead-in should concede it |
| 3 | MAJOR | protocol-behaviour claims in the atlas carry no claim-level citations | correct as stated; the citations exist in `expansion/*/01-research.md` and enter the paper with the subsections at stage 6 |
| 4 | MAJOR | `prop:neither` contains a non sequitur about monotone search | needs adjudication: the proposition's *witnesses* verify, but the inference drawn from them may overreach |
| 5 | MAJOR | the proof confuses a clutter with its downward-closed model class | needs care; this is a genuine distinction and the parenthetical may be sloppy |
| 6 | MAJOR | `cor:notthe` generalises from one restricted finite instance | probably correct — the corollary should be scoped to the instance or restated as a conjecture |
| 7 | MAJOR | the capital-versus-resolution relationship is asserted, never measured | correct; either measure it or demote it to a remark, and it appears in the conclusion too |
| 8 | MAJOR | `validate.mjs` admits evidence-defective specs | actionable directly in the checker |
| 9 | MAJOR | the Lean development is weaker than the prose describing it | highest-value remaining item; check declaration by declaration against `sec:lean` |
| 12 | MINOR | no sensitivity analysis for candidate-status elements | cheap to run and worth doing |

**Next mechanical step:** pin both predicate counts as assertions in
`formal/v3/selftest.mjs`, so the fork cannot move silently again.
