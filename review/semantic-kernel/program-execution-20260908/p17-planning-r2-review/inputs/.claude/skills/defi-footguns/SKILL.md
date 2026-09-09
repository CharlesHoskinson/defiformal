---
name: defi-footguns
description: Use when touching anything in this repo that verifies, checks, gates, or reports a result - paper/build.sh, formal/v3/*gate*, totalgate.mjs, negtest-*.sh, the sigma gates, or any script that compares a figure against paper/atlas.tex. Also use when a checker reports success, when adding an assertion, or when deciding how many review rounds a change needs.
---

# DeFi footguns

Traps that have actually fired in this repository, with the evidence. Every
entry below was measured, not predicted.

**Core principle: this repo's gates exist to stop a confident wrong answer.
Every trap here is a gate that produced one — usually about something it had
not measured.**

Read `formal/v3/GATE-REGISTER.md` alongside this: it records, per gate, whether
it has ever been *observed* failing. Two gates are marked `CANNOT FAIL` and are
still cited as verification commands in `AGENDA-COMPLETE.md`.

## Quick reference

| Symptom | Cause | Fix |
|---|---|---|
| `BUILD FAILED: a headline total disagrees with the verdicts`, but the PDFs rendered and the totals are right | `paper/build.sh` discarded the gate's stderr with `>/dev/null 2>&1` and mapped **every** nonzero exit onto one editorial sentence | Branch on the exit code: `0` holds, `1` the property is false, `3` the check could not run. Never merge those |
| A gate reports `PASS` / `ok` / `agree` after examining nothing | Empty glob, empty directory, zero-iteration loop. `verify_final.py` printed `X21-armed pairs: 0 of 0` and exited 0 on every tree but the author's | A zero denominator is a **blocked** check, exit 3. Print the denominator in the result line |
| Running the verification suite leaves the repo dirty | Gate scripts write their result JSON back into the tree, so *verifying* and *regenerating* are the same action and a gate can never disagree with its own record | Snapshot `git status --porcelain -uall` before and after. If a gate rewrites its evidence, diff it — reproducing bit-for-bit except a recorded absolute path is genuine |
| `quint typecheck` cited as verification | It checks types and effects. It never evaluates `init`, never steps, never reads an invariant. **0 of 92 `.qnt` files declare an `invariant`, `temporal` or `run`** — `quint test` is an empty suite everywhere | Name the property: `quint run <f> --invariant=inv_all`. Expect `usd1.qnt` to go red — it ships violating `inv_supply` |
| A gate shell reports `FAIL 61 of 72` about a corpus it never read | Unguarded `cd`, or a harness truncated with `head`/`tail` **before** being judged, discarding the EACCES that marks a blocked run | `cd "$(dirname "$0")/../.." \|\| exit 3`, plus a sentinel checking real content. Capture output in full; truncate only for display |
| A `cd` guard is present and the script still lies | `cd` into a directory that merely **exists** succeeds. Landing in `/tmp` is not a failure | Sentinel on content: `corpus50/lanes/*.json` present, `begin{measurement}` in `atlas.tex` |
| A count of blocked checks is off by one | `grep -c 'BLOCKED'` also matches the `GATE RESULT: BLOCKED` summary line | Anchor: `grep -cE '^  BLOCKED'`. This is the repo's own canonical example — `grep -q "violation"` matches Quint's success string `[ok] No violation found` |
| A figure "agrees" with the paper but the paper is wrong | `has()` was `tex.includes()` over a 151 KB document. Strip the approx markers and `strict` becomes `45.3`, satisfied by the **coverage** literal eleven lines above | Anchor each figure to the block *and* the sentence that asserts it, and require every site that states it to agree |
| An anchored claim search finds the wrong text | A `\label` sits wherever the author put it — near the top of a `measurement`, but inside the **caption** of a `table`, *below* the tabular body. Slicing forward from the label misses the numbers | Bound the block by `\begin{env}`…`\end{env}`, not by the label's position |
| A comment or an unused macro satisfies a claim | A LaTeX comment is never typeset; nor is an uninvoked `\newcommand` body, nor the untaken branch of a conditional | Strip comments (see parity below). For conditionals, **refuse rather than resolve** — see the wiki. There is no complete fix short of reading the typeset PDF |
| Comment stripping misses `\\%` | LaTeX comment semantics are backslash **parity**: `\%` is a literal percent, `\\%` is a line break followed by a **live** comment. A single-preceding-character test keeps the second | `replace(/(^\|[^\\])((?:\\\\)*)%.*$/gm, "$1$2")` — consume the pairs |
| A conditional check blocks a correct paper | `\iff` (the math operator) matches a naive `\\if[a-zA-Z]*` | Match the real primitives: `ifnum ifdim ifodd ifx iftrue iffalse ifcase ifdefined ifcsname else fi` |
| Every fix is defeated by the symmetric case one step away | Four consecutive rounds closed a pole and left its dual: whole-document → block-scoped missing a second site; comment stripped → wrong parity; `\iffalse` stripped → `\iftrue` untouched | When a fix is about *which* form, ask what the other polarity is **before** shipping. Better: make the check refuse ambiguity rather than resolve it |
| A "guard" passes on an arithmetically impossible input | The total row `total & --- & 1259 & 570 & 689 & 15` was checked by testing each number occurred *somewhere* in the table. Permuting to `1259 & 689 & 570 & 15` passed | Cells carry meaning by **position**. Read the row as a row |
| A count-based guard misses a partial corpus | Zero-file guards say nothing about four files of five, and "is an array" says nothing about `[]` | Count what you visited and refuse to compare an incomplete corpus. Better: make two independent sources check **each other** — `tot` from verdicts vs obligation items from specs; `cov` vs `assigned` |

## The assertion traps — the most expensive class here

Four distinct ways an assertion stayed green against reverted code, all observed
in this repo:

1. **It tests a copy.** The probe re-implemented `want()` / `blocked_out()` in a
   heredoc, so reverting the real hunk left it exercising a private copy that
   still had the fix. Lift the function from source with a **bounded** extractor.
2. **It greps source instead of running behaviour.** A check for
   `case "$brc" in` passed against a block that was dead code after an `exit`.
3. **A parent guard already returns the same code.** The per-verdict
   `Number.isFinite` check sat under an existing `tot === 0` guard, so the
   fixture returned 3 either way. Lock by the specific **message**.
4. **The fixture is degenerate.** A one-slug corpus can't exhibit a
   silent-skip: the `tot === 0` guard fires first. **Two slugs minimum** for
   anything about a partial walk.

**Every guard needs a positive control** proving it fires on a defeating input,
**and** a negative one proving it isn't always-on. A dot-terminated sentence
window shipped that failed the *intact* corpus — its control was the only reason
it didn't ship red.

## A bounded function lift

`awk '/^fn\(\) \{/,/^\}/'` runs on to the **next** function's closing brace when
the definition is one-lined, so `tail -1 == "}"` passes on swallowed script body
(measured: 40 lines, 5 of them body, lift returned 0). Require: non-empty, ends
`}`, contains exactly one `^name() {`, and no line matching `^(echo|one |want "|===== )`.

## How many review rounds

**State the threat model in the brief.** This repo ran 21 adversarial rounds.
Rounds 1–11 found real defects — the published lie in four places, a silent
PASS, gates that could not fail. Rounds 12–21 found manuscript mutations that
require an adversary with **write access to `atlas.tex`**, which is not the
threat: the real risk is a collaborator regenerating one figure and missing
another.

- Budget rounds up front. Extension is an explicit decision, not a default.
- Tell reviewers to rank by **realistic likelihood**, not constructibility.
- **You** decide what blocks shipping. A finding needing adversarial write
  access to the artifact under test is a note, not a blocker.
- Tripwire: N consecutive rounds touching the same files → stop and reassess.
  Here, ten consecutive commits touched the same two files.

## Common mistakes

- **Trusting a gate's summary line.** `all headline totals agree with the
  verdicts` was printed while two of the four cells in the row it named were
  never compared.
- **Believing a stated limitation.** A limitation is a claim like any other.
  `GATE-REGISTER.md` overstated its own bound twice and a reviewer caught it
  both times.
- **Reading only the last line.** `one()` judged on `tail -1`, discarding the
  evidence that marks a blocked run — in a file whose own header says every
  check greps the whole output.

## Adding entries

Append only footguns that actually fired, symptom first — that is what a future
reader searches for. Keep the quick-reference table the primary surface. Record
the measurement, not the intuition.
