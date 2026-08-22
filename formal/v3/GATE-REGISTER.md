# Gate register

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
| `formal/v3/claims.mjs` | 109 category claims recomputed from the corpus | Not in-tree | Against a mutated 71-protocol corpus a repointed copy gives 18 failures, exit 1 | `BLOCKED` in-tree by `formal/v3/construct.mjs:59` `loadCorpus(root = "/root/DefiElements")` — no longer by `tables.mjs`. **CANNOT FAIL on `atlas.tex` errors — it never opens the paper** |
| `formal/v3/selftest.mjs` | 22 self-tests of `construct.mjs`, incl. an inadmissible X2 fixture | Not in-tree | Repointed copy vs a 71-protocol corpus: `FAIL corpus size: got 71 want 72` | `BLOCKED` by `construct.mjs:59`; copy `DISCRIMINATES` its frozen goldens |
| `formal/v3/verify-measurements.mjs` | `meas:pairs` / `meas:whereitfails` numerals must appear | Not in-tree | Copy: `$147$`→`$148$` VIOLATED. **`Twenty of the`→`Nineteen of the` still VERIFIED** | `BLOCKED` in-tree; `CANNOT FAIL` on the duplicate word-form |
| `formal/v3/verify-graphs.py` | GRAPHS.md figures vs the merged/domain/lane graphs | Not in-tree | Copy: 777→9999 gives `GRAPH CLAIMS VIOLATED`, exit 1 | `BLOCKED` in-tree; copy `DISCRIMINATES` |
| `formal/v3/validate.mjs` | Rejects malformed construction specs | Yes, both polarities | Real spec dir → exit 0; empty dir → exit 3. Unblocked by the `formal/v2` root fix; the guard the previous change could only *record* is now demonstrated | `DISCRIMINATES` |
| `research/positive-program/basis/denominators.py` | Ten-protocol generation rate (`v2 119/716 = 16.6%`) | Yes | Missing IR → exit 1; `UNGEN_V1/V2` mismatch → exit 1 | `DISCRIMINATES` those two. **The 16.6% figure itself is not a threshold** — any rate prints and exits 0 |

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
