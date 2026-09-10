# Gate register

**See also:** `docs/wiki/` for why these rules exist, and
`.claude/skills/defi-footguns/SKILL.md` for the symptom-first version that fires
while you work.

Every gate, what it claims, and whether it has been *observed* failing on a
known-bad input. A checker never seen to fail is not evidence, and a row marked
`CANNOT FAIL` contributes none to any claim in the paper.

Verdicts:

| Verdict | Meaning |
|---|---|
| `DISCRIMINATES` | Made to fail on bad **content**, and to pass on good content. Both polarities observed. |
| `CANNOT FAIL` | No perturbation of input content produces a failure verdict. |
| `VACUOUS` | Passes over an empty corpus, or a conjunct that is constant by construction. |
| `BLOCKED` | Cannot run in this tree; no verdict either way. |

Exit-code contract: `0` property holds over a non-empty corpus · `1` property is
false · `3` check could not be performed. Exit 3 follows the pre-existing
`negtest-*.sh` convention (`PERTURBATION DID NOT APPLY`, `sys.exit(3)`).

## Registered gates

| Gate | Claims | Observed failure | Perturbation | Verdict |
|---|---|---|---|---|
| `formal/v3/totalgate.mjs` | Headline totals in `atlas.tex` equal the verdict sums; four stale round-2 values absent | Yes, both polarities | `$1{,}259$` → `$1{,}260$` in a fixture tex (exit 1); `chmod 000` expansion root (exit 3); empty root (exit 3) | `DISCRIMINATES` |
| `paper/build.sh` totals branch | Distinguishes a false total from a gate that could not run | Yes, both polarities | Fixture tex perturbation vs real `EACCES` | `DISCRIMINATES` |
| `formal/v3/gate.sh` | LOOP-2 integrity over build, harnesses, claims, graphs | Yes | Run from a directory that is not a defiformal tree — now exits 3 instead of printing `FAIL 61 of 72` | `DISCRIMINATES` |
| `research/positive-program/sigma/gate33_cert_check.py` | Keyword certificate over `gen-ir-v2ten`: every file has ≥1 tagged name; tags ⊆ {Led,Prop,Cmp,Post,OTHER} | Partial | Empty-of-names JSON → `FAIL: empty file`, exit 1. Empty IR → exit 3 (was `PASS 0 files`) | `DISCRIMINATES` emptiness only — the **tag-subset invariant CANNOT FAIL**: `tag_name` returns only members of `allowed` by construction, so `FAIL: bad tag` is unreachable |
| `research/positive-program/sigma/verify_final.py` | X21-armed pair counts over expansion specs | Yes | Empty corpus → exit 3. **Before this change the glob matched zero files on any tree but the author's and printed `X21-armed pairs (60-app basis): 0 of 0`, exit 0** — a live pass on an empty denominator. It now measures 60 specs | `DISCRIMINATES` |
| `research/positive-program/sigma/gate12_deletion_ir.py` | "IR deletion": how much of the IR surface disappears if a family is deleted | **No** — no failure path exists. Empty and missing IR both exit 0 and still write `MEASURED` | — | `CANNOT FAIL`. The residual counts are a rewrite of tag base rates (Post/Cmp = 3279/39 = 84.08×); nothing is actually deleted |
| `research/positive-program/sigma/gate11a_census_v1.py` | Independent-witness census; N3 printed `indep=0 shared=6` | **No** — no failure path; empty corpus still exits 0 and writes `MEASURED` | Classification does change on constructed input, but the script cannot report failure | `CANNOT FAIL`. N3 `indep=0` is `VACUOUS` — the local-def markers match zero definitions in the tree. The maple `SHARED` hit matches a **comment**, not a call |
| `formal/v3/claims.mjs` | 109 category claims recomputed from the corpus | **Yes, in-tree** | Control: `109 claims verified, 0 failed`. Drop one protocol from `corpus50/lanes`: `93 claims verified, 16 failed`, exit 1, naming `FAIL [intent] CoW 23, DFlow 1, rest 0` | `DISCRIMINATES` the corpus. **Still CANNOT FAIL on `atlas.tex` errors — it never opens the paper** |
| `formal/v3/selftest.mjs` | 22 self-tests of `construct.mjs`, incl. an inadmissible X2 fixture | **Yes, in-tree** | Control: `22 passed, 0 failed`. Same mutation: `FAIL corpus size: got 71 want 72`, `17 passed, 5 failed`, exit 1 | `DISCRIMINATES` its frozen goldens |
| `formal/v3/verify-measurements.mjs` | `meas:pairs` / `meas:whereitfails` numerals must appear | Not in-tree | Copy: `$147$`→`$148$` VIOLATED. **`Twenty of the`→`Nineteen of the` still VERIFIED** | `BLOCKED` in-tree; `CANNOT FAIL` on the duplicate word-form |
| `formal/v3/verify-graphs.py` | GRAPHS.md figures vs the merged/domain/lane graphs | **Yes, in-tree** | Control: `GRAPH CLAIMS VERIFIED`. 777→9999 in GRAPHS.md: `GRAPH CLAIMS VIOLATED`, exit 1 | `DISCRIMINATES` |
| `formal/v3/validate.mjs` | Rejects malformed construction specs | Yes, both polarities | Real spec dir → exit 0; empty dir → exit 3. Unblocked by the `formal/v2` root fix; the guard the previous change could only *record* is now demonstrated | `DISCRIMINATES` |
| `research/positive-program/basis/denominators.py` | Ten-protocol generation rate (`v2 119/716 = 16.6%`) | Yes | Missing IR → exit 1; `UNGEN_V1/V2` mismatch → exit 1 | `DISCRIMINATES` those two. **The 16.6% figure itself is not a threshold** — any rate prints and exits 0 |

| `formal/v3/evidence.mjs` | cited by loop2gate §4 as a citation check | **No** — it is the supplement *emitter*, not a checker: no `process.exit`, no `throw`, and its stderr always contains the string a needle would match | — | `CANNOT FAIL` |
| `formal/v3/cites.mjs` | cited by loop2gate §4 as a citation check | **No** — no failure path; prints `<-- invariant 5 violation` and still exits 0. Never emits the needle it was matched on | — | `CANNOT FAIL` |

## The gate path runs

`formal/v3/construct.mjs:59` and `formal/v3/verify-graphs.py:10` were the last
two hardcoded roots on the integrity-gate path. With those resolved from their
own file locations, `formal/v3/gate.sh` reports **PASS** — ten checks, none
blocked, exit 0 — for the first time in this clone, and `smoke.sh` reports
`SMOKE OK`.

Three gates recorded above as `BLOCKED` are now recorded as `DISCRIMINATES`,
each with a control proving it is not always-red. Note what that means and does
not: they discriminate the **corpus**. `claims.mjs` still never opens
`paper/atlas.tex`, so it cannot fail on a manuscript error.

About 170 files elsewhere still carry a dead `/root/...` root. None is on the
gate path.

## Rows that carry no evidence

`gate12_deletion_ir.py` and `gate11a_census_v1.py` are `CANNOT FAIL`. Both write
a document headed `MEASURED` regardless of input, including empty input. Neither
supports a claim, and `AGENDA-COMPLETE.md` lists both among its verification
commands. Gate 1.1a is cited as MEASURED for the basis census and gate 1.2 for
the deletion experiment; those citations rest on scripts with no failure path.

## Not addressed by this change

`totalgate.mjs`'s content checks remain unanchored `String.includes` tests over
the whole `.tex`, so a dummy file containing the four tokens also passes. It
computes `inad` (15) and `assigned` (570) and checks neither. The stale-value
blacklist is a frozen round-2 fossil rather than a derived invariant. Widening a
check and fixing how failure is reported are separate changes and were kept
apart deliberately; this is the candidate for the next one.

`formal/v2/tables.mjs`'s root is **fixed** — it now resolves from
`import.meta.url`, and the six `formal/v2` scripts that re-read `corpus50/lanes`
by absolute path use the exported `ROOT`. All three README reproduce commands
run and all seven published figures reproduce (61/72, 1830, 185, 29/72, 20/61,
15 arcs, 0 violations). `gate.sh` went from **ten blocked checks to three**, with
seven now `ok`.

An earlier revision of this file said "four". That count came from an unanchored
`grep -c 'BLOCKED'` which also matched the `GATE RESULT: BLOCKED` summary line —
the same defect this register exists to catch, committed by its own author. Both
independent reviewers caught it. Anchored: `grep -cE '^  BLOCKED'` = 3, `^  ok `
= 7, and 7 + 3 = 10 reconciles.

The three that remain do **not** share one cause:

| Blocked check | Actual blocker |
|---|---|
| 109-claim checker (`claims.mjs`) | `formal/v3/construct.mjs:59`, `loadCorpus(root = "/root/DefiElements")` |
| smoke (via `selftest.mjs`) | the same line |
| graph claims (`verify-graphs.py`) | its **own** `ROOT = "/root/defiformal/expansion"` — not `construct.mjs` |

Fifty-two `formal/v3` scripts also still import by absolute ESM specifier.

## Adversarial review of this register's own change

Two independent reviewers (grok-4.6 at xhigh, claude-fable-5) were given the
diff and told to attack it. Confirmed findings, all now fixed:

- **The exit contract stopped at `readdir`.** Every `readFileSync` / `JSON.parse`
  of a verdict or spec was unguarded, so an `EACCES` or malformed JSON one
  directory deeper threw, node exited 1, and `build.sh` reported a totals
  disagreement — the original defect, alive, one syscall further in. Now every
  read and parse in the corpus walk is a blocked-check candidate.
- **The callers never learned the contract.** `gate.sh` and `loop2gate.sh` grepped
  `build.sh`'s stdout for `OK`, so a blocked build read as a failure at the
  integration layer. Both now branch on the exit code.
- **`blocked_out` was over-broad** — a bare `Traceback` or the word `BLOCKED` in
  ordinary output would reclassify a genuine content failure as blocked, hiding a
  real defect behind a reassuring word. Patterns narrowed, and the ordering
  inverted so that a harness which produced the expected answer is never called
  blocked however noisy its stderr.
- **The repo sentinel was a name check.** Three empty files of the right name
  walked past it. It now requires `corpus50/lanes/*.json` and a `measurement`
  environment in `atlas.tex`.
- **The harness locked one `chmod` and the editorial sentence**, but never
  asserted exit 3 *through* `build.sh`, never exercised `tot === 0`, and
  truncated the orphan `gate.sh` case with `head -20`. All three now asserted.
- Counting and attribution errors, above.

`negtest-reporting.sh` went from 25 assertions to **43**, all passing. The five
new sections exist because a reviewer found the gap, not because the author
predicted it.

## Second adversarial review — what the first round of fixes still got wrong

Commit `6f9786b` claimed to close every finding of the first review. A second
pass by the same two reviewers found it had not, and found a false statement in
its own commit message. Recorded here rather than quietly amended, because a
register that hides its author's errors is worth nothing.

- **`6f9786b`'s message says "Both now branch on the exit code."** That was false.
  The entire change to `loop2gate.sh` was a `printf`; the verdict still came from
  `case "$b" in *"OK"*)` and it still exited 1 on a blocked build. Only `gate.sh`
  had been fixed. Both reviewers caught it independently and claude rated it the
  most severe finding — not because the code was worst, but because the
  accounting asserted something untrue.
- **The contract stopped at the parse, not the type.** A verdict, spec or
  obligation that is valid JSON `null` is not a parse failure, so `readJson`
  returned it and the next property access threw a `TypeError` — exit 1, and
  `build.sh` announced a totals disagreement without comparing a total.
- **An unreadable slug directory was silently skipped**, because `existsSync`
  returns false on `EACCES`. Its obligations vanished from the totals and the
  short total was then reported as a real disagreement.
- **The `blocked_out` ordering inversion reached `chk()` only.** The three inline
  sites — `claims`, `smoke`, `graph claims` — still tested the classifier first,
  and those are the only checks actually blocked today.
- Two fixes shipped with **no assertion behind them**, and the identical
  stale-root hazard sat note-free in `tables.mjs`, which feeds all seven figures.

A third defect was introduced while fixing the first: the new `loop2gate.sh`
result block was appended *after* the script's existing `exit`, so it was dead
code, and the assertion written to cover it was a source grep that passed anyway.
Replaced with a behavioural test.

`loop2gate.sh`'s other twenty checks had the same defect its build step did —
`brief-fresh.sh: cd: /root/defiformal: Permission denied` produced
`FAIL section briefs are stale`. Ten of them also truncated with `tail -1`
*before* judging, discarding the evidence of a blocked run, in a file whose own
header says every check greps the whole output. All now route through one
blocked-aware helper. `loop2gate.sh` reports **BLOCKED, fail=0** instead of ten
content verdicts about a corpus nothing read.

`negtest-reporting.sh`: 25 → 43 → **65** assertions.

## What this gate still cannot detect

Twelve rounds of adversarial review closed the skipped-walk class and the
needle-collision class. Both reviewers independently identified one that
remains, and it is recorded here rather than left implicit.

**Coordinated, sum-preserving corpus edits are invisible.** `totalgate.mjs`
aggregates without identity: it never joins a verdict record to the spec file
describing the same application, and never reads `app` or `category`. Two
consequences:

- **Correction.** An earlier version of this section said that deleting an app's
  verdict record and its spec file "is reported as agreement". That is false, and
  both reviewers caught it: the pair-delete is caught by `specFiles 59 != 60`,
  exit 3, and would be exit 1 even without the hardcoded constants. Recorded
  rather than silently amended, because a register that overstates a hole
  mis-sizes a reader's trust exactly as surely as one that hides it.
- What IS invisible is the **cardinality-preserving** variant: delete an app and
  duplicate another to keep the counts whole, or swap two applications with
  identical statistics. Those preserve every equality the gate checks and every
  count, and are reported as agreement with one application double-counted and
  another unmeasured.
- A coordinated edit that preserves the sums but changes what they describe is
  reported as `a headline total disagrees` — a corpus defect routed through the
  manuscript-is-wrong exit code, which is precisely the failure this branch
  exists to prevent, surviving in the one shape the cross-source check cannot
  see.

Closing it requires joining the two sources by application identity, which is a
larger change than this branch's contract and is not attempted here. Anyone
relying on this gate should know that its guarantee is *one-sided*: a short or
inconsistent walk is caught; a self-consistent but wrong corpus is not.

`EXPECT_CATEGORIES = 12` and `EXPECT_SPEC_FILES = 60` are hardcoded. A corpus
that legitimately grows will produce a false BLOCKED whose message asserts the
opposite ("the corpus is incomplete" on 13 categories). That is the safe
failure direction, but it is a maintenance obligation, not a check.

## Why the manuscript comparison cannot be finished this way

Seventeen rounds of adversarial review closed the corpus walk completely. The
manuscript comparison is not closed and, on the current design, cannot be.

Every headline figure is located by pattern-matching a number out of prose.
Rounds 13, 15 and 17 each found a claim site that hand enumeration had missed,
and round 17's fix was itself prompted by counting occurrences mechanically
rather than by reading. That count is the argument:

| figure | visible sites | lines |
|---|---:|---|
| obligations total 1259 | 3 | 217, 1297, 1536 |
| covered 570 | 2 | 1303, 1536 |
| residue 689 | 2 | 1536, 2334 |
| coverage 45.3% | 1 | 1297 |
| strict 29.0% | 2 | 1306, 1314 |
| **inadmissible 15** | **6** | 957, 1029, 1157, 1536, 1970, 2692 |

**Correction, one round later.** The paragraph below generalised from `inad`
to "the method cannot be finished", and a reviewer showed that is false.
`$205$`, `$36.0\%$` and `$16.3$` each occur exactly ONCE in visible text, so
the every-site rule applies to them cleanly; they were unregistered, not
unregisterable. Two of the three are now checked. This is the second time this
register has overstated a limitation, and both times a reviewer caught it --
recorded rather than amended, for the same reason as before.

What remains true is narrower: `inad` alone cannot be located by this method.
The last row is the one that shows why. The digits `15` occur six times and most
are unrelated counts, so the rule that fixed every other figure — *every site
stating this number must agree* — would fail on a correct paper. Pattern
matching cannot separate a claim about a quantity from an unrelated number that
happens to equal it, and no further enumeration changes that. The gate checks
`inad` at its table cell only, and that is the honest bound.

**The structural answer, not attempted here.** Emit the figures into the
manuscript from one source — `\newcommand{\obligationsTotal}{1259}` generated by
the gate, with the prose using the macro — so every figure has exactly one
definition site by construction and the comparison becomes an identity rather
than a search. That changes how the paper is authored and is the author's call,
not a gate change. It is the same recommendation the reviewer made in round 12.

Until then: a figure that drifts at a registered site is caught; one that drifts
at an unregistered site is not, and `inad` has five unregistered sites by
necessity.

## The real bound on the manuscript comparison

Twenty-one rounds. The corpus walk is closed. The manuscript comparison is not,
and this section states why with the evidence, replacing two earlier attempts
that were each wrong in a different direction.

**What was tried.** Rounds 12-21 located each headline figure by matching a
number out of the LaTeX source, and every round found a new way to make the
source say one thing and the typeset paper another: a whole-document search, a
second claim site, a comment, a comment behind the wrong backslash parity, an
`\iffalse` block, an `\iftrue \else` dual, and finally -- from both reviewers
independently -- a conditional WRAPPING the claim region and a conditional whose
`\else` sits outside the inspected window. Each fix was correct about the shape
in front of it. None generalised.

**Why it cannot generalise.** A conditional can be defeated by position as
easily as by form, and conditionals are not the only gap: a
`\newcommand{\x}{... $689$ ...}` that is never invoked carries the claim phrase
in text TeX never typesets, with no conditional token anywhere. Deciding what
TeX typesets requires running TeX. A source-text gate cannot bound it, and every
further round of this shape buys one more position rather than the class.

**Two remedies, both feasible, both the author's call.**

1. *Compare against the typeset output.* `paper/build.sh` already produces
   `atlas.pdf` before running the gate, and `pdftotext` is installed. Measured:
   `pdftotext -layout` preserves the total row as a row --
   `total  —  1259  570  689  15` -- so the cell-identity guarantee of round 18
   survives the move, and four of the five claim phrases appear verbatim in the
   typeset text. The fifth (`Pooling all`) does not, almost certainly line
   wrapping or hyphenation, which is the new failure class this approach would
   have to shake out. It closes conditionals of every form and position,
   uninvoked macro bodies, and comments at once, because it reads what the
   reader reads.

2. *Emit the figures from one source.* `\newcommand{\obligationsTotal}{1259}`
   generated by the gate, with the prose using the macro. Every figure then has
   exactly one definition site by construction, the comparison becomes an
   identity rather than a search, and the `inad` collision problem disappears
   because the gate never has to find `15` in prose again. This is the stronger
   remedy and the one a reviewer recommended in round 12.

**Until one is adopted**, the gate's "all headline totals agree with the
verdicts" means: *the figures agree at the claim sites the gate knows about, in
the LaTeX source, assuming those sites are macro- and conditional-transparent.*
That is a real and useful guarantee. It is not the same sentence as "the paper
the reader sees is consistent with the corpus", and the difference is this
section.
