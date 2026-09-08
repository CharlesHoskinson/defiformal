# Honest-gate clean closeout r2 — native Grok 4.6

**Role.** Native Grok 4.6 author. Independent GPT-6 checker pending. No Foreman.
**Whole-package acceptance: false.** This is a validation supplement on a private detached unaccepted candidate. Root reviews r1 source fix plus this clean execution before any delivery or archive.

r1 is preserved, not rewritten: archive SHA-256 `892cb802cdb738ca1aeaf9b43a0c3d56b96461d4d07b7ea6f1bffdc5fe691ce2` (native-worker stage tar, 106877 bytes). Attempt 1 **206/1** and repaired **209/1** remain historical exit-1 runs; they are not clean acceptance.

## Private candidate

| Field | Value |
|---|---|
| Checkout | `/home/charl/.cache/defiformal-program/honest-gate-clean-r2/candidate` |
| Commit | `89486bae7b4a99d6d3881fd2fb50ab61dea1fc43` (detached, unpublished, unaccepted) |
| Tree | `1c23668035d6925cc1b585b9a659ea1a141fe9df` |
| Parent | `a12b7cac05a818cc8d35c2ca440b7170a2807e92` |
| Sole source delta | `formal/v3/negtest-reporting.sh` SHA-256 `36c7c7b03fdb9f68d51f277ee6daa621f9a6d599b573babe7ccc1037be4e98b9` |
| `git status --porcelain -uall` before | empty |
| Same after harness and after independent restore | empty |

Root Git administration only. Validation ran only in this checkout. The main honest worktree was not used as the harness tree and live orchestration bytes were not quarantined there.

## Command that closed the previous dirty-tree failure

Standalone `formal/v3/negtest-reporting.sh` — the command that previously exited 1 on 209/1.

```
argv: /usr/bin/bash …/candidate/formal/v3/negtest-reporting.sh
cwd:  /home/charl/.cache/defiformal-program/honest-gate-clean-r2/candidate
DEFIFORMAL_ROOT: unset
GEN_IR: unset
uid: 1000
start: 2026-09-08T10:10:18.580507139Z
end:   2026-09-08T10:11:28.920823275Z
exit:  0
result: 210 caught, 0 missed
```

`/tmp/negtest-reporting` was absent before invocation (not deleted as unknown state) and absent after the EXIT trap. chmod 000 is actually unreadable for this uid (`PermissionError`). Sixteen tracked rewrite candidates (GATE-3.3 JSON, merged/domain graphs, twelve briefs, `atlas.bbl`) were snapshotted, independently restored, and read back equal. Primary and main-worktree GATE-3.3 hashes were unchanged (`318cf8e9…db669f`). The JSON `ir` field still names a primary path as provenance text; writes resolved from candidate `__file__`.

`smoke.sh` was **not** run. Its last step nests this same harness (a second full reporting/TeX pass) without a new reason. r1 sibling-exit-9 (eight scripts, all exit 9) and r1 smoke CLI except reporting are reused: those files are byte-identical to parent `a12b7ca`. Paper was not run separately; the harness already executed `paper/build.sh`. Private PDFs from that build: atlas 40 pages, supplement 120 pages — not a scientific-paper claim.

## Polarities (this run)

| Control | Exit | Class |
|---|---:|---|
| totalgate real corpus | 0 | nonempty pass |
| totalgate `$1{,}259$`→`$1{,}260$` | 1 | evaluated disagreement |
| totalgate chmod 000 expansion | 3 | blocked |
| totalgate empty expansion | 3 | vacuous blocked |
| build.sh blocked fixture | 3 | `were NOT checked` |
| build.sh violated fixture | 1 | `a headline total disagrees` |
| build.sh real tree | 0 | `OK  atlas.pdf` |
| validate.mjs empty dir | 3 | later unblock, not restored as blocked |
| gate33 real IR / empty IR | 0 / 3 | no PASS artefact on empty |
| verify_final empty | 3 | |
| harness dirty check | CAUGHT | tree clean |

210 assertion identities: `execution/harness/parse.json`. Zero missed.

## `want()` rc=0 discrimination

r1’s attrib-order probe showed `want: command not found` because `fns.sh` did not exist. That is the placement vacuity, not the rc=0 guard. It is bound, not reused as rc=0 evidence.

New external sandbox (candidate source untouched): lift `blocked_out`/`want` from intact `loop2gate.sh`, and from a copy with the rc=0 conjunct removed.

| Branch | Genuine output | Designated repaired checks |
|---|---|---|
| Intact sibling | `FAIL died but printed the needle (pairs exit 7; wanted /pairs: 1830/)` | PASS |
| Mutated lift (no rc=0) | `ok   died but printed the needle` | FAILS_AS_REQUIRED |

No command-not-found or setup-failure credit.

## 7 / 18 / 37

`scenario-disposition.json`: 16 observed on this 210/0 log, 1 preserved sibling-exit-9 exception, 1 register CANNOT FAIL bound. 37 historical task boxes retained; not a new current completion; not archived.

Not closed by this run: GATE-REGISTER CANNOT FAIL rows, eight sibling exit-9 shells, loop2gate citations BLOCKED (no citation checker), sum-preserving identity swap, 12/60 constants, source-text vs typeset PDF, constructed keyword tautology.

## Pending

Independent GPT-6 review of r1 source fix plus this clean execution. Author did not commit, push, archive, or self-accept. External logs: `/home/charl/.cache/defiformal-program/honest-gate-clean-r2/execution/`.
