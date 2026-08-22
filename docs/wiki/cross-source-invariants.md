# Cross-source invariants

**Claim.** Guarding each walk individually never converged. Making two
independent readings check *each other* did, and needs no hardcoded corpus size.

This is the one structural fix on the corpus side, and the shape worth copying.

## The problem it replaced

Nine rounds of guards, each closing the shape that round's reviewer had built:
a missing `verdicts.json`, an empty `specs/`, an empty array, a truncated array,
an all-residue obligations set, a file occupying a category name, a renamed
category directory. Each fix was correct. Each left a neighbour open.

## The invariant

The gate was already reading the same two quantities from two independent
sources and never comparing them:

```
tot (sum of obligationsTotal, from verdicts/)  ==  obligation items (from specs/)
cov (sum of obligationsCovered, from verdicts/) == assigned          (from specs/)
```

Measured live: **1259 == 1259** and **570 == 570**.

Truncate a verdicts array and the left side moves. Make every obligation residue
and the right side moves. Either way the two sources disagree **with each
other**, the gate cannot know which is right, and it blocks — with no hardcoded
corpus size to go stale, and a corpus defect never routed through the
manuscript-is-wrong exit code.

## Why this shape generalises

A guard answers *"is this particular thing wrong?"*. An invariant answers
*"is what I read self-consistent?"* — and it holds against mutations nobody
enumerated, which is exactly what nine rounds of guards could not do.

When a fix is about a shape a reviewer constructed, ask what quantity the system
already computes twice. That is usually the fix.

## What it still cannot see

Sum-preserving edits. Delete an application and duplicate another, or swap two
with identical statistics: every equality and every count holds, one application
is double-counted and another unmeasured. Closing that needs an identity join —
`totalgate.mjs` never joins a verdict record to the spec file for the same
application, and never reads `app`.

See [what this gate still cannot do](remaining-bounds.md).

## Related

[Vacuity](vacuity.md) · [What this gate still cannot do](remaining-bounds.md)
