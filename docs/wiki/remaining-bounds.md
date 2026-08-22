# What this gate still cannot do

Stated narrowly, because a guarantee that overstates itself is the defect this
work exists to remove. `GATE-REGISTER.md` overstated its own bounds **twice** and
a reviewer caught it both times — once in the pessimistic direction (calling
figures uncheckable that occur exactly once), once in the optimistic
(understating what a pair-delete would do).

## What it does guarantee

**The corpus walk is closed.** No path remains by which a short or inconsistent
walk reaches the manuscript comparison, or stays silent about a check that did
not run. Two reviewers confirmed this independently across the final rounds, and
every single-side mutation is caught with the correct exit code.

## What it does not

**1. Cardinality-preserving corpus edits.** `totalgate.mjs` aggregates without
identity — it never joins a verdict record to the spec file for the same
application, and never reads `app`. Delete an application and duplicate another,
or swap two with identical statistics: every equality and every count holds, and
it reports agreement with one application double-counted and another unmeasured.
Closing it needs an identity join.

**2. Anything about what TeX actually typesets.** The comparison reads the LaTeX
source. An uninvoked `\newcommand` body, or a claim inside a conditional whose
branch the gate cannot resolve, carries text the reader never sees. See
[matching claims in LaTeX](latex-claim-matching.md).

**3. The figure `inad` = 15.** The digits occur six times in visible text and
most are unrelated counts, so it is checked at its table cell only.

**4. Hardcoded corpus size.** `EXPECT_CATEGORIES = 12` and
`EXPECT_SPEC_FILES = 60`. A corpus that legitimately grows produces a false
BLOCKED whose message asserts the opposite ("the corpus is incomplete" on 13
categories). Safe failure direction, but a maintenance obligation, not a check.

## The sentence, precisely

> `all headline totals agree with the verdicts`

means: *the figures agree at the claim sites the gate knows about, in the LaTeX
source, assuming those sites are macro- and conditional-transparent, over a
corpus whose two independent readings are mutually consistent and complete at
the file and item level.*

That is a real and useful guarantee. It is **not** "the paper the reader sees is
consistent with the corpus", and the difference is this page.

## Gates that cannot fail at all

`formal/v3/GATE-REGISTER.md` records, per gate, whether it has been *observed*
failing. Two are marked `CANNOT FAIL` — `gate12_deletion_ir.py` and
`gate11a_census_v1.py` have no failure path, and empty input still writes a
document headed `MEASURED`. Both are cited as verification commands in
`research/positive-program/AGENDA-COMPLETE.md`.

Those citations rest on scripts that cannot report a problem.

## Related

[Cross-source invariants](cross-source-invariants.md) ·
[Matching claims in LaTeX](latex-claim-matching.md)
