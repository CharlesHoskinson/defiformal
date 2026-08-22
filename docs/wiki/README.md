# The verification wiki

What was learned building an honest gate for this repository, written for
whoever — human or model — has to change these scripts next.

One page per idea. Each page states the claim, the evidence that produced it,
and what it costs you if you forget it. Pages cross-link; follow them rather
than reading top to bottom.

**Operational counterpart:** `.claude/skills/defi-footguns/SKILL.md` is the
terse, symptom-first version that fires while you work. This wiki is the
reasoning behind it. If the two disagree, the wiki is stale — the skill is
maintained against what actually fires.

## Origin

`./paper/build.sh` printed `BUILD FAILED: a headline total disagrees with the
verdicts`. The totals were correct. The gate had never run — it died on a
hardcoded path and the diagnosis was discarded by `>/dev/null 2>&1`. That single
line generated everything in this wiki.

## Pages

| Page | The one-sentence version |
|---|---|
| [Blocked is not failed](blocked-is-not-failed.md) | A check that could not run and a property that is false are different facts and must never share an exit code. |
| [Vacuity](vacuity.md) | A checker that examined nothing reports success unless you stop it, and zero-denominator passes are invisible because green invites no investigation. |
| [Assertions that cannot fail](assertions-that-cannot-fail.md) | Four measured ways a test stayed green against reverted code, and why every guard needs two controls. |
| [Matching claims in LaTeX](latex-claim-matching.md) | Why a source-text gate cannot bound what TeX typesets, with the measurement, and the two remedies. |
| [Cross-source invariants](cross-source-invariants.md) | The fix that finally closed the corpus walk: stop guarding each walk, make two independent readings check each other. |
| [Portability and dead roots](portability-and-roots.md) | 202 scripts could not run outside one machine, and the count that looked like 160. |
| [The economics of adversarial review](adversarial-review-economics.md) | Twenty-one rounds; the last ten answered a threat model nobody had. |
| [What this gate still cannot do](remaining-bounds.md) | The guarantees, stated narrowly enough to be useful. |

## The through-line

Every defect in this repository was the same shape: **a confident statement
about something unmeasured.**

`build.sh` said the totals disagreed without reading them. `quint typecheck` was
cited as verification while checking no invariant. Two gates write a document
headed `MEASURED` regardless of input. The gate printed *all headline totals
agree* while comparing two of four cells. The register overstated its own limits
twice. A harness asserted the repo was read-only while rewriting a tracked file.

The pattern does not respect the boundary between the code and the people
writing it. It showed up in the gates, in the tests for the gates, in the
document describing the tests, and in the judgement about when to stop. Assume
it is present in whatever you add next, and design the check that would catch it
before you need it.
