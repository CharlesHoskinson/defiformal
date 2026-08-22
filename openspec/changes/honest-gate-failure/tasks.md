## 1. Establish the baseline before changing anything

- [x] 1.1 Record the current false output verbatim — `formal/v3/evidence/BASELINE-build-lie.txt`: `BUILD FAILED: a headline total disagrees with the verdicts` beside atlas 39pp, supplement 120pp, `grep -c undefined atlas.log` = 0, and the discarded `EACCES: scandir '/root/defiformal/expansion'`
- [x] 1.2 Record that the totals actually agree — all eight predicates pass; `tot=1259 cov=570 res=689 inad=15 assigned=570 approx=205`, `pct=45.3`, `strict=29.0`
- [x] 1.3 Record the second shape — `gate.sh` emitting `FAIL 61 of 72 satisfy laws+warrants` after the unguarded `cd`
- [x] 1.4 Enumerate callers. Only two: `gate.sh:8` and `loop2gate.sh:17`, both capturing `build.sh` **output**, neither branching on its exit code. The new exit 3 breaks no caller
- [x] 1.5 Enumerate exit codes. **Correction to the plan:** `3` is not a collision to avoid but an existing precedent to follow — `negtest-composition.sh`, `negtest-footprints.sh` and `negtest-measurements.sh` already `sys.exit(3)` for `PERTURBATION DID NOT APPLY`, i.e. *the check could not be performed*. Adopted rather than re-chosen

## 2. The reporting contract

- [x] 2.1 `blocked()` added beside `die()` — `CHECK BLOCKED` in yellow versus `BUILD FAILED` in red, exit 3
- [x] 2.2 Line 49 replaced with a captured-output `case` on the gate's exit code; the gate's stderr is emitted on every non-zero branch
- [x] 2.3 `$?` captured on the assignment line — `gate_out=$(...); gate_rc=$?` at `build.sh:61`
- [x] 2.4 Both supplement `pdflatex` passes now surface their `!`/`l.NN` diagnosis instead of `>/dev/null 2>&1`. `bibtex` already warned rather than dying; `pdfinfo` is report-only
- [x] 2.5 `totalgate.mjs` exits 1 for a real disagreement, 3 for an unreadable root, and writes `totalgate: BLOCKED - <cause>` to stderr rather than throwing an unhandled `EACCES`

## 3. The `cd` guards

- [x] 3.1 `gate.sh:3` → `cd "$(dirname "$0")/../.." || exit 3`
- [x] 3.2 **Correction to the plan:** the twelve siblings did **not** need this. All twelve already carry `cd /root/defiformal || exit 9` and fail fast today; `gate.sh` was the sole unguarded script. They were left untouched rather than changed for tidiness
- [x] 3.3 Verified from an unrelated working directory
- [x] 3.4 `totalgate.mjs` resolves its root from `import.meta.url`, with a `DEFIFORMAL_ROOT` override so the harness can point it at a fixture
- [x] 3.5 **Discovered by the harness:** `|| exit` is necessary but not sufficient. A `cd` into a directory that merely *exists* succeeds — the orphan test landed in `/tmp` and `gate.sh` still printed `FAIL 61 of 72`. Added a repo sentinel (`paper/atlas.tex`, `expansion/`, `corpus50/` must all be present) that exits 3 otherwise
- [x] 3.6 **Discovered by the harness:** `chk` could not distinguish a blocked harness from a failing one, so a harness killed by `tables.mjs`'s hardcoded root still produced `FAIL 61 of 72`. `chk` is now blocked-aware and `gate.sh` returns a three-way verdict (0 / 1 / 3)
- [x] 3.7 **Discovered by the harness:** `gate.sh` truncated each harness's output with `head -2` / `grep` *before* judging it, discarding the very evidence that marks a blocked run — the same defect as line 49, one level down. Capture in full, truncate only for display. Ten checks moved from false `FAIL` to honest `BLOCKED`

## 4. The vacuity guards

- [x] 4.1 `verify_final.py` — resolves the corpus from `__file__`, exits 3 on an empty glob. **It previously printed `X21-armed pairs (60-app basis): 0 of 0` and exited 0 on every tree but the author's; it now measures 60 spec files**
- [x] 4.2 `validate.mjs` — guard added, exits 3 on an empty spec directory. **Not demonstrable in this tree**: blocked by `formal/v2/tables.mjs`'s hardcoded root, which is out of scope here. Recorded as such in the register, not claimed as verified
- [x] 4.3 `gate33_cert_check.py` — exits 3 on zero `*.json`, with the guard placed **before** `OUT.write_text` so an empty IR leaves no `PASS` artefact on disk. A `GEN_IR` override makes the guard exercisable
- [x] 4.4 Denominator added to `verify_final.py`'s spec-count line
- [x] 4.5 Real-corpus output confirmed unchanged: `gate33` still `PASS 10 files; totals {'OTHER': 57973, 'Post': 3290, 'Prop': 175, 'Led': 5024, 'Cmp': 27}`, and the committed result JSON differs only in its recorded `ir` provenance path

## 5. Audit — the harness that would have caught this

- [x] 5.1 `formal/v3/negtest-reporting.sh` written to the `negtest-*.sh` convention, `CAUGHT`/`MISSED`, fixtures torn down on `EXIT`
- [x] 5.2 Blocked polarity from a real fault — `chmod 000` on a fixture expansion root, a genuine `EACCES` at the real syscall. `build.sh` says "were NOT checked", surfaces `EACCES`, and does **not** say "a headline total disagrees"
- [x] 5.3 Violated polarity — `$1{,}259$` → `$1{,}260$` in a fixture tex. `build.sh` *does* say "a headline total disagrees" and does not say it was blocked. Both polarities observed
- [x] 5.4 Vacuous polarity for each guarded gate, plus a control on the real corpus
- [x] 5.5 `cd` polarity — `gate.sh` from a non-repo directory emits no `FAIL n of m`
- [x] 5.6 Measured outcomes recorded beside the harness and in `evidence/AFTER-honest-gate-failure.txt`
- [x] 5.7 Wired into `smoke.sh`

## 6. The audit register

- [x] 6.1 `formal/v3/GATE-REGISTER.md` created
- [x] 6.2 Seeded with the audited results
- [x] 6.3 `CANNOT FAIL` rows marked as contributing no evidence, with the `AGENDA-COMPLETE.md` citations that rest on them named
- [x] 6.4 `totalgate.mjs`'s unanchored `String.includes` matching and its unchecked `inad`/`assigned` recorded as unchanged and as the candidate for the next change

## 7. Land

- [x] 7.1 Full suite recorded verbatim in `formal/v3/evidence/AFTER-honest-gate-failure.txt`. **A correction:** the first run reported the eight pre-existing `negtest-*.sh` as `exit=0`. That was my own verification loop hitting the `$?`-clobber trap this change's `design.md` warns about — `printf '%s' "$(basename "$f")" "$?"` expands `$?` after the substitution runs. They exit 9, blocked and honest
- [x] 7.2 `./paper/build.sh` exits **0**: `OK atlas.pdf: 39 pages`, supplement 120 pages
- [x] 7.3 **Correction to the plan.** This task predicted the build would still fail honestly until the root-resolution change landed. It does not — `totalgate.mjs` was the only path blocking it, so the build now passes outright. `gate.sh` still reports `BLOCKED` because ten of its harnesses depend on `formal/v2/tables.mjs`; that is the honest verdict and the remaining work
- [x] 7.4 Modes verified — every touched file `100644` or `100755` as it was before; no drvfs `755` markdown
