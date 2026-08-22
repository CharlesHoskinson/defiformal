# The economics of adversarial review

**Claim.** Two adversarial reviewers instructed to attack will always find
something. A loop that terminates only when they find nothing does not
terminate. This one ran 21 rounds; the last ten answered a threat model nobody
had.

Written after the fact, from the commit record, so the next person budgets it
properly.

## What the record shows

| rounds | files each commit touched |
|---|---|
| 1–6 | `build.sh`, `gate.sh`, `loop2gate.sh`, `totalgate.mjs`, `validate.mjs`, `gate33_cert_check.py`, `verify_final.py`, `tables.mjs` |
| 7–15 | narrowing toward `totalgate.mjs` + the harness |
| 16–21 | **`totalgate.mjs`, `negtest-reporting.sh`, `GATE-REGISTER.md`. Every single commit.** |

Ten consecutive commits touching the same two or three files. That is a
mechanical, checkable diminishing-returns signal, available from round 12, and
it was never computed.

## What the rounds bought

**Rounds 1–11 were worth it.** They found the published lie alive in four more
places, the first silent PASS, two gates that cannot fail at all
(`gate12_deletion_ir.py`, `gate11a_census_v1.py` — both still cited as
verification commands in `AGENDA-COMPLETE.md`), a harness that mutated the tree
it audited, and 202 scripts that could not run outside one machine.

**Rounds 12–21 answered the wrong question.** Every defect from round 12 onward
required an attacker who could edit `atlas.tex` — plant a comment, wrap a
conditional, insert a decoy row. But if someone can arbitrarily edit the
manuscript, this gate was never the boundary.

The real risk is **accidental drift**: a collaborator regenerates one figure and
misses another. That is what rounds 1–11 fixed. The later rounds hardened
against an adversary who does not exist in this workflow.

They produced exactly one durable result — the mechanism-level argument in
[matching claims in LaTeX](latex-claim-matching.md) for why source-matching
cannot work, which is what justifies the macro recommendation. That was
obtainable in two rounds by asking the right question, not ten by attrition.

## Root causes

1. **The stop condition could not terminate.** "Repeat until no severe findings
   from *either* reviewer", with two adversaries under orders to attack. No
   budget, no guarantee of termination.
2. **The threat model was never stated.** Not in the brief, not in my head. The
   reviewers optimised for constructibility because nothing told them not to.
3. **The reviewers were allowed to define "blocks shipping."** They labelled
   findings that way and it was accepted. They do not know the threat model or
   the cost; that judgement belonged to the operator.
4. **The signal was noticed and not acted on.** Around round 15 the concern was
   written down explicitly — then six more rounds ran. Noticing without acting is
   worse than not noticing: it proves the judgement was available.
5. **Marginal cost felt free.** The machinery existed; each round was one
   dispatch. In fact ~10 rounds × 2 reviewers × ~25 minutes, plus triage.

## Rules

- **Budget rounds up front.** Three, then report. Extension is an explicit
  decision with a stated reason.
- **State the threat model in the brief**, and tell reviewers to rank by
  *realistic likelihood*, not constructibility. That one line would have ended
  this at round 11.
- **The operator triages.** A finding requiring adversarial write access to the
  artifact under test is a note, not a blocker.
- **Tripwire:** N consecutive rounds touching the same files → stop and
  reassess instead of dispatching again.
- **Decline findings.** Across 21 rounds, not one was declined. That is not
  rigour; it is the absence of judgement.

## The one thing worth keeping

The reviewer with **no ability to execute anything** found the sharper defect in
several rounds — including the published lie still being alive at round 8, by
reading `totalgate.mjs` line by line while the executing reviewer's fixtures all
passed.

A fixture only probes the paths someone thought to build. When a review round
stops producing findings, the productive move is not another fixture sweep but
an **enumeration**: every point where control proceeds without the data it was
about to use. That exercise produced three defects on first application.

## Related

[Assertions that cannot fail](assertions-that-cannot-fail.md) ·
[Matching claims in LaTeX](latex-claim-matching.md)
