# Sprint 7 existing Python regressions

PASS. All nine requested suites passed against frozen source commit `6de24fef77f8d6c98f4e8ec80ffe772e509e0a2c`. No implementation or runner source was edited. This rerun used the native stock GPT-6 harness, without Foreman. Independent model build telemetry was unavailable.

| Suite | Observed result |
| --- | --- |
| Typed mutations | 24/24 detected; 189 executed comparisons in each variant and unchanged control |
| Composition mutations | 12/12 detected; 93 comparisons each |
| Parallel mutations | 14/14 detected; 131 comparisons each |
| Composition runner controls | 36/36 actual CLI classifications |
| Typed runner controls | 17/17 actual CLI classifications |
| Parallel runner controls | 45/45 actual CLI classifications |
| Axiom audit controls | 99/99 behavioral assertions |
| Typing controls | 1 executed positive and 3 expected compiler type errors |
| Corpus normalizer | 20/20 tests; 76 actual CLI invocations |

The three mutation suites executed 7,899 named runtime comparisons across 50 source mutants and three unchanged controls. Every mutant retained the full comparison inventory, produced its designated false checks, preserved required positive checks, and failed only through the expected runtime-comparison diagnostic. Compiler errors received no mutation-detection credit. The three typing refusals are compiler controls, with zero financial-counterexample credit.

Execution ran from 2026-09-07T07:09:55.225211+00:00 through 2026-09-07T07:16:54.921850+00:00, using at most three concurrent suite subprocesses and fresh external output directories under `/tmp/defiformal-sprint7-regressions-tcn31xv2`. Python 3.14.4, Lean 4.33.0-rc2 (commit d8b18978322de05a8f3dba51ef03cf5461676c17), Lake 5.0.0-src+d8b1897, and Git 2.53.0 were observed; executable hashes are recorded in `../regression-runs.json`. All nine `--help` invocations passed before execution.

The 128 input files were bound to raw Git blob identities and SHA-256 hashes before and after the runs. Both source manifests have SHA-256 `f4baa0bed877a3be3f757f47f15670ff21d22bf6a4d005bbef6955372bd7ecce`; every byte matched the frozen candidate. The 1,336-entry raw artifact manifest has SHA-256 `330b4beb0c4bfd05b94c571cdbe8d13d2a4a4429d1f0348dc9e37fc8f22d6d4f`. Output copies preserve symlink targets. Three nested fixture Git metadata directories were retained as tar archives, with every archived file hash reconciled against its original; no embedded repositories were added.

`verify-results.py` independently reconciled the saved evidence with 1,617 passing assertions. Exact command arrays, UTC times, exit statuses, separate full stdout/stderr logs, source identities, generated Lean fixtures, runner case classifications, copy manifests, and archive hashes are retained here and in `../regression-runs.json`. `verified-outcomes.json` contains the individual evidence assertions. The raw artifact manifest was sealed before final verification metadata and this report; those later files have separate hashes in the run record.

This report covers the nine established regression suites. New Interleaving mutation/runner checks and full Lean integration are separate gate evidence. Corpus temporary fixtures follow the existing test harness cleanup behavior; their complete observed CLI/test logs are retained. Passing finite regression cases does not extend theorem scope or establish arbitrary shared-state commutation.
