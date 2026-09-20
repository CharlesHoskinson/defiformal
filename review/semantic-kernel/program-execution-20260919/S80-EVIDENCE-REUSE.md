# S80 planning-control evidence reuse

**YES — S80 is discharged by correctly attributed, preserved planning-CLI evidence.** This is a read-only provenance reassessment on 2026-09-19, not a new historical-control execution. No build, harness, historical checker replay or source mutation was performed.

Let `R` be `review/semantic-kernel/program-execution-20260908/p19-r4-planning-review/`, and `P` be `R/sandbox/review/semantic-kernel/certificates/planning/grok-gpt6-official-r4/` (paths relative to `/home/charl/defiformal`).

The current main **and active author** `openspec/changes/serialized-kernel-certificates/specs/certificate-regression-evidence/spec.md` match the accepted frozen file: SHA-256 `cc65b932ddd84953f035b2d22c7ca850748813b8f90e71b4e854c085edefd17f`. S80 requires an isolated empty fixtures array to make actual `package.py --check` exit 3 with an empty-selection message, with an intact sibling exiting 0. This is a planning-control scenario; F01 codec evidence is the wrong evidence class.

The independent official-r4 review ran the actual frozen CLI with explicit `--root`, `--plan` and `--package` against reviewer-owned isolated copies on **2026-09-08, 21:14 UTC**. Its recorded results are:

| Record under `R/logs/` | Exit | Observed diagnostic/result |
|---|---:|---|
| `intact.stdout` | 0 | PASS_SEALED_PLANNING_PACKAGE; 71 manifest entries |
| `empty-fixtures.stderr` | 3 | `BLOCKED: fixtures: empty (0 of 0)` |
| `restored.stdout` | 0 | Same intact package result |
| `missing-bound.stderr` | 3 | manifest missing |
| `changed-bound.stderr` | 1 | manifest mismatch |
| `changed-requirement.stderr` | 1 | requirement map identity |

`R/commands.json` binds argv, cwd, UTC, duration, exits, diagnostic expectations, environment and raw log hashes for all ten commands. `R/run_controls.py` shows the actual empty-array perturbation, exact restoration, and suite failure on any wrong exit/diagnostic. I verified all 20 command stdout/stderr hashes and exits, all **252** review-manifest files, all **165** accepted-overlay files and all **71** final package-manifest entries. All match. The preserved review verdict is ACCEPT_WITH_LIMITATIONS for planning only; frozen `gate_accepted=false` remains untouched.

Key SHA-256 bindings:

| Path | SHA-256 |
|---|---|
| `R/commands.json` | `a45190dea83c5a2f7abb1d30fe3695c1fcd73c06a6aa70fcdede8619c884e4c7` |
| `R/logs/empty-fixtures.stderr` | `005ea5b09bd66d226a7e00f140d287da1dea63ed6454ee331d8b1129153e01bd` |
| `R/logs/intact.stdout` and `restored.stdout` | `4dd638004b2ee3c2b2bd91dc3ba63df3a40760f6de389df440acf437374e07e0` |
| `P/package.py` | `f2b1f334ae04abdd8ce85038a3d3f7c64e853d7ee930c6c635e23a97509eb2b2` |
| `P/MANIFEST.json` | `fd49b2ec4c629a0ba3fb91d896e64cd56ee8996b7f5111f72003161f20379449` |
| `R/evidence-manifest.json` | `1ab3002c090ede24659b31a96e25c23e9ab30884e37c0373f3f1ab99f97c7eab` |
| `R/verdict.json` | `56b0d0fdd977ea65c1f3cbfd4a37dc011b28b82c45723f43fe70275eef36cdf6` |

`P/tools.json` records Python `/usr/bin/python3` SHA-256 `b8d8288faefdd300201f43fcf00f6f539a27218eeed3a3dff5ab10b9c4c99700`. Tool and dependency identity remain historical; no assertion is made that today's binaries, HEAD or consolidated branch are those inputs. A current HEAD/branch rejection does not invalidate these recorded executions.

For **task 8.6**, S80 alone is insufficient. The separate author evidence in `P/control-runs/summary.json` (SHA-256 `1fb18c8fed9592a95cffd1c862cadea48e2948602b6df2afe621eb5b33c52b5d`) contains eight real, log-hash-verified author controls, including the required six outcomes, on the **43-entry seal**. The broken-suite requirement also has an observed failure: preserved native `p19-planning-author-r4.jsonl.gz`, under `R/inputs/primary/review/semantic-kernel/program-execution-20260908/`, SHA-256 `5d91e2b29300fc51719a42b95381860c4f492c0512e1a15edcdde6b0ea3b618b`, decompressed line **962**, completed tool call `call-e1c75071-1fc2-489b-a30a-22e966eef69f-245`, records outer exit **1** and `control restored-intact-sibling: expected pass got failed exit 1` on the **68-entry reseal**. This proves an actual broken control stopped the suite; it is not a successful campaign. The preceding in-progress record's exit 0 is not the terminal exit.

Remaining task-8.6 accounting is to map these distinct author/suite-failure/reviewer records explicitly, preserve r1 synthetic records as historical, and avoid claiming a successful author `--controls` run against the final 71-entry seal. That latter claim is not established by the ten reviewer commands and, if separately required, remains open. This reassessment supports S80 closure and reuse of the observed task-8.6 subclaims; it does not silently mark the entire task complete or change its frozen checkbox.

No codec/runtime result, current R6 package qualification, full EV04 implementation acceptance, P19/P20 completion or broader program closure follows from this mapping.
