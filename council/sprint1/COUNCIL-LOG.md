# Sprint 1 Council — run record

**Bundle:** `BUNDLE-blinded.md`
**sha256:** `559c8c69f040f1fcf43bce61870c385c6324de73a64875c17a3bc08fc974dffc`
**Identity leak check:** clean (`council/bin/leak-check.py`, exit 0, 0 hits across 6 pattern classes)
**Date:** 2026-08-23
**Status:** advisory. The council ranks the candidates; it does not decide the paper.

## Corrections applied to the task brief before this round ran

The task brief (`task-6-brief.md`) was extracted before Task 1 ran and was stale
in three places, corrected against `council/bin/members.sh` (the load-bearing,
smoke-tested source of truth) before dispatch:

1. **`reproducer` runs opencode, not gemini.** Gemini has no auth configured on
   this box and crashes on startup on a pre-existing `~/.gemini/projects.json`
   collision. `members.sh` already dispatches opencode for this lens.
2. **`formal` cannot run and was not substituted.** `claude auth status` reports
   `loggedIn: false` — credentials are present (Max subscription) but the OAuth
   session is expired and unrefreshable, which only Charles can fix. Dispatched
   anyway, on the same path as every other lens, so the failure is recorded
   honestly. Not re-dispatched.
3. **The Step 4 JSON read was guarded.** The brief's `json.load(open(f))`
   snippet was unguarded; the verification script used here catches
   `OSError`/`JSONDecodeError` per-file and reports which file failed, rather
   than throwing.

## Round 1

| lens | CLI | exit | verdict | ranking | findings |
|---|---|---|---|---|---|
| empirical | grok | 0 (both attempts) | **FAILED — contract violation, twice** | none recorded | n/a |
| formal | claude | 1 | **FAILED — credentials present, OAuth session expired and unrefreshable** | none recorded | n/a |
| significance | codex | 0 | changes_requested | C, B, A | 4 |
| reproducer | opencode | 0 | changes_requested | C, A, B | 11 |

Two of four lenses returned a valid, contract-conforming report. Both rank
**C first**, unprompted agreement from independently sandboxed CLIs with no
visibility into each other's output.

## Evidence each member read the bundle, not priors

Both valid reports name specific bundle figures and cross-check their
arithmetic against the text rather than asserting from a generic prior:

- **significance (codex):** cites `{Ct, Ex, Li}`, the six named perpetuals,
  Candidate B's "hand-made decompositions" framing, the 1,830-pair census, and
  the abstract's complete-lattice-under-union sentence to argue C's
  prohibition-only attribution is a theorem, not a discovery.
- **reproducer (opencode):** verifies `C(61,2)=1830`, `1830−1645=185`,
  `182+3=185`, `570/1259=45.3%`, `(570−205)/1259=29.0%` from the bundle's own
  numbers, and flags that "functional," "covers," "strict," "grounding," and
  "arc/below-set" are used but never defined anywhere in the text — findings
  that require having read the actual sentences, not general priors about
  DeFi formalization papers.

Neither `.log` (raw CLI stderr/session output) shows a wandered read: both
contain only the benign `foreman-launch: DEGRADED capability=... unshare
failed: Operation not permitted` line (a WSL2 process-group fallback, confirmed
benign by reading the launcher source in Task 1) plus, for codex, its own
startup banner and token count. Neither sandbox contained any file besides
`bundle.md` and the lens's own `brief.md`, so a wandered read was not possible
by construction.

## Notes

### A dispatch.sh bug found and fixed before any vendor CLI ran

The first `dispatch.sh` run (matching the brief's `dispatch.sh` verbatim, with
only the CLI-map correction applied) failed all four lenses at redirect setup:
`run_member` in `members.sh` executes inside a `( cd "$sb" ... )` subshell —
the per-lens sandbox — so the brief's relative `$OUT` path resolved against the
sandbox, not the repo. The shell's own redirect failed before `foreman-launch`
or any vendor CLI was invoked; **zero API calls were made, zero cost
incurred.** Fixed by computing `REPO="$(pwd)"` after the initial `cd` and using
`$REPO`-anchored absolute paths for `$OUT` and the copied brief source.

### A PATH bug found and fixed before real vendor spend on three lenses

The corrected script's second run reached `foreman-launch` but three of four
lenses (`empirical`/grok, `formal`/claude, `reproducer`/opencode) failed with
`launcher error: spawn <cli> ENOENT`. `codex` alone succeeded, because it
happens to also resolve via `/usr/local/bin/codex`; grok, claude and opencode
live under `~/.local/bin` and `~/.opencode/bin`, which are only added to PATH
by `~/.bashrc`/`~/.profile` — never sourced by a plain, non-login
`bash council/bin/dispatch.sh` invocation. Node's `child_process.spawn` failed
before any process existed, so again **zero cost was incurred** by this
failure. Fixed by exporting the known user-local bin dirs at the top of
`dispatch.sh` itself, so the script is correct under any invocation (not
dependent on the caller using a login shell) — this also protects Task 7's
reuse of `dispatch.sh`/`members.sh` for the decider round.

`dispatch.sh` also gained an optional second argument (a space-separated lens
subset, defaulting to all four) so a lens that failed for an environment
reason before ever reaching its vendor CLI could be re-run alone, without
re-dispatching — and re-billing — lenses that had already succeeded.

### empirical (grok) failed twice, honestly, and was not hand-fixed

With both bugs above fixed, `empirical` reached grok twice (its one permitted
re-dispatch) and failed the output contract both times, for two different
reasons:

- **Attempt 1** (4,915 bytes): the captured stdout contains a truncated,
  unterminated fragment — `{"lens":"emp{"lens":"empirical",...}` — before a
  fully well-formed JSON report. `extract_balanced_json` (`extract-json.py`)
  correctly refuses to skip past the first `{` to find a working one further
  in the text (a deliberate design choice, documented in its own docstring:
  "no fallback search for a later `{`"), so `validate-reports.py` reported "no
  single balanced, parseable JSON object found."
- **Attempt 2** (6,409 bytes): clean narration prefix — `"I'll read
  ./brief.md now and follow it exactly.I'll read ./bundle.md next, as the
  brief requires."` — ahead of a complete, well-formed JSON object. This is
  the narration-prefix behaviour `members.sh` already documents as an open,
  unresolved grok issue ("four separate invocation attempts... could not
  suppress it"). `validate-reports.py` correctly rejected it: BRIEF-common.md
  requires "No prose before or after," and this is prose before.

Read by eye, **both attempts' underlying JSON payloads are genuinely grounded
in the bundle** — specific figures ({Ct, Ex, Li}, 14→11, 13→10, 1,830 pairs,
1,259 obligations, 45.3%/29.0%, etc.), cross-checked arithmetic, and one sharp
catch (an unreconciled 15-inadmissible-of-60 vs. 61-of-72 figure) that a
prior-based answer would not produce. **Neither report was hand-edited into
validity and neither was extracted/laundered into a passing state.** Per the
task's explicit rule, a lens is re-dispatched once; on a second failure it is
recorded and the round moves on. `empirical` is recorded here as failed,
carrying no ranking into Round 1's result. Considered and declined: patching
`extract-json.py`'s single-`{` limitation to recover a report post hoc — this
would not have changed either verdict (BRIEF-common.md's contract rejects any
prose-contaminated output regardless of whether it is extractable), and
adjusting shared validation tooling in direct response to a specific failing
report is the same substitution-of-judgement the task explicitly forbids, one
level removed.

### formal (claude) failed exactly as predicted, and was not retried

`R1-formal-claude.json` contains exactly the direct-call failure text quoted
in `members.sh`'s comment: `Failed to authenticate: OAuth session expired and
could not be refreshed` (73 bytes). This is not a "never logged in" state —
credentials with a Max subscription are present; the OAuth session itself is
expired and unrefreshable, which only Charles can fix (`claude auth login` or
`claude setup-token`). Per the task's explicit instruction this lens was
**not** re-dispatched and **not** substituted with another CLI.

### A mid-task message described results that did not match the repo

During this round a supervisory message reported different figures for two
lenses — grok/empirical at "5,762 bytes" and opencode/reproducer at "0 bytes,
nothing returned" — and suggested re-dispatching opencode to test a
hypothesis. Direct, timestamped inspection of the repo at the time (file
sizes, mtimes, and a live process listing) showed no second `dispatch.sh`
process ever ran, and `R1-reproducer-opencode.json` was already 8,450 bytes,
validated `ok`, and unchanged since 22:42:33 — well before the message
arrived. Opencode was **not** re-dispatched on the strength of that message;
the file evidence already in hand was trusted instead, consistent with this
task's own instruction not to treat any agent message as authorization on its
own. The message's one technically correct point — `extract-json.py`'s
single-`{` limitation — was independently confirmed directly against
`empirical`'s attempt 1 before the message arrived, and is addressed in the
note above.

### Process hygiene

Every per-lens sandbox (`mktemp -d`) was removed by `dispatch.sh` after each
`run_member` call regardless of exit code. A post-run scan of `/tmp` found no
sandbox contents (`bundle.md`/`brief.md`/CLI-specific temp files) attributable
to this task; the stray `tmp.*` directories present on the box predate this
round by hours and belong to unrelated concurrent work (other repos, other
tasks) on the same machine, and were left untouched.
