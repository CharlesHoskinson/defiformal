# Sprint11 runner-r1: Nary defensive mutation runner adaptation

This is the bounded runner-r1 implementation record. It is not implementation acceptance, not a production mutation result, and not a GPT-6 checker verdict.

## Model identity

| Field | Value |
|---|---|
| Requested worker | `grok-4.6` (`execution-contract.json`) |
| Reported worker | `Grok 4.6` (session system identity: "You are Grok 4.6 released by xAI.") |
| Grok CLI | `grok 1.0.13 (5e9a58528b76)` at `/home/charl/.local/bin/grok` |
| Session | `01a07ed4-abaf-7330-a48c-722fb1ccd200` |
| Assigned checker | `gpt-6-astra` |
| Checker run in this task | no |
| Foreman | not used |
| Commits / push / archive / self-acceptance | none |

No `grok-4.6-build` runtime string was observed in this process environment. That earlier planning-session label is not reused here.

## Commands actually run

Help was read before selecting harness arguments.

```
/usr/bin/python3 scripts/test_nary_mutation_runner.py --help
# exit 0; recorded in help/harness.stdout
/usr/bin/python3 scripts/run_nary_mutations.py --help
# exit 0; recorded in help/runner.stdout
```

Harness help required `--repo` and `--out`. Optional `--case` runs a named subset. Optional `--runner` overrides the default `repo/scripts/run_nary_mutations.py`. `--timeout-seconds` is a driver flag, not a harness flag.

Selected full-suite arguments after that help text:

```
/usr/bin/python3 /home/charl/defiformal-wt-sprint11-grok-gpt6-20260907/scripts/test_nary_mutation_runner.py \
  --repo /home/charl/defiformal-wt-sprint11-grok-gpt6-20260907 \
  --out /tmp/sprint11-nary-controls-r1/run
```

| Record | Value |
|---|---|
| Outer started_utc | `2026-09-08T02:29:40.032634+00:00` |
| Outer finished_utc | `2026-09-08T02:30:54.146947+00:00` |
| Outer elapsed_seconds | `74.099613` |
| Outer actual_exit | `0` |
| Outer status | `FINISHED` |
| TimeoutOccurred | `False` |
| stdout sha256 | `d35e01029392b8e59b74e2316ab1467ff1c668ff7122d38b8457849ecd3daf02` (3582 bytes) |
| stderr sha256 | `e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855` (0 bytes, empty) |
| Harness summary | `65/65 passed` |

`--case` was omitted so all 65 inherited controls ran. `--runner` was omitted so the harness default successor path was used.

## Adaptation comparison

Predecessor files at HEAD `ed94e6050d092e67f945df7b9762d3096ab0feda` matched the planned sha256 values from `runner-adaptation.json` (accepted predecessor `b165bc586080d668f689fbc18dfa09eb8739d688`). Edits were applied uniquely to the listed 1-indexed lines. Line count did not change. No new parser behavior was added.

### `scripts/run_interface_mutations.py` → `scripts/run_nary_mutations.py`

| Field | Value |
|---|---|
| Predecessor sha256 expected | `48c53785f17b6d63ca8a8e883de2feeb65cd546b4e9b9c93f9db1a672651e1e8` |
| Predecessor sha256 actual | `48c53785f17b6d63ca8a8e883de2feeb65cd546b4e9b9c93f9db1a672651e1e8` |
| Match | `True` |
| Predecessor bytes | `20692` |
| Successor sha256 | `4528dde870fdb3e4c408e4646f70dcc5f8d31a84623e488103eee528a2e020be` |
| Successor bytes | `20637` |
| Total lines | `371` |
| Edited lines | `10` |
| Unchanged lines | `361` |
| New parser behavior | `False` |

| Line | Predecessor occurrences of that exact line | Applied uniquely to listed line |
|---|---|---|
| 2 | 1 (2) | `True` |
| 139 | 1 (139) | `True` |
| 159 | 1 (159) | `True` |
| 186 | 1 (186) | `True` |
| 198 | 1 (198) | `True` |
| 212 | 1 (212) | `True` |
| 282 | 1 (282) | `True` |
| 286 | 1 (286) | `True` |
| 337 | 2 (337,347) | `True` |
| 347 | 2 (337,347) | `True` |

### `scripts/test_interface_mutation_runner.py` → `scripts/test_nary_mutation_runner.py`

| Field | Value |
|---|---|
| Predecessor sha256 expected | `c0339642ee44f6bad616398c7bce461df1a496f53f76ecc7227078f2be0ba19c` |
| Predecessor sha256 actual | `c0339642ee44f6bad616398c7bce461df1a496f53f76ecc7227078f2be0ba19c` |
| Match | `True` |
| Predecessor bytes | `32743` |
| Successor sha256 | `5adcb1cbe1a701f8807893da83d014689b17265c56f9476bf2e74c4c78c02f68` |
| Successor bytes | `32613` |
| Total lines | `542` |
| Edited lines | `26` |
| Unchanged lines | `516` |
| New parser behavior | `False` |

| Line | Predecessor occurrences of that exact line | Applied uniquely to listed line |
|---|---|---|
| 21 | 1 (21) | `True` |
| 22 | 1 (22) | `True` |
| 32 | 2 (32,48) | `True` |
| 44 | 2 (44,59) | `True` |
| 46 | 1 (46) | `True` |
| 48 | 2 (32,48) | `True` |
| 57 | 1 (57) | `True` |
| 59 | 2 (44,59) | `True` |
| 61 | 1 (61) | `True` |
| 62 | 1 (62) | `True` |
| 65 | 1 (65) | `True` |
| 67 | 1 (67) | `True` |
| 71 | 1 (71) | `True` |
| 76 | 1 (76) | `True` |
| 221 | 1 (221) | `True` |
| 227 | 1 (227) | `True` |
| 233 | 1 (233) | `True` |
| 298 | 1 (298) | `True` |
| 323 | 1 (323) | `True` |
| 361 | 1 (361) | `True` |
| 365 | 1 (365) | `True` |
| 368 | 1 (368) | `True` |
| 448 | 1 (448) | `True` |
| 471 | 1 (471) | `True` |
| 481 | 1 (481) | `True` |
| 483 | 1 (483) | `True` |

Exact old/new strings are in `adaptation-comparison.json`. Duplicate predecessor lines (runner 337/347; harness 32/48 and 44/59) were each replaced only at the listed line, with the same planned successor text.

## Inherited 65-control results

These are synthetic CLI/compiler controls against a temporary fixture repository. They are not production Nary financial mutation evidence.

| Metric | Value |
|---|---|
| Total | `65` |
| Passed | `65` |
| Failed | `0` |
| Exit 0 / 1 / 3 | `10` / `5` / `50` |
| Timeouts | `0` |
| Runner sha256 | `4528dde870fdb3e4c408e4646f70dcc5f8d31a84623e488103eee528a2e020be` |
| Harness sha256 | `5adcb1cbe1a701f8807893da83d014689b17265c56f9476bf2e74c4c78c02f68` |
| Lean | `Lean (version 4.33.0-rc2, x86_64-unknown-linux-gnu, commit d8b18978322de05a8f3dba51ef03cf5461676c17, Release)` |
| Lean executable sha256 | `e8baaa71855a616dc351028f3ad2200051b0671f423a1696a100e809302d5550` |
| Fixture git HEAD (source repo) | `ed94e6050d092e67f945df7b9762d3096ab0feda` |
| Lake cache in source repo | unchanged (1120 build files; newest still `DefiHistorical.trace`) |
| Lean git status | empty before and after |

Final harness line: `CONTROLS: 65/65 passed`.

| Control | expected | actual | result | elapsed_s |
|---|---:|---:|---|---:|
| `production-eval-discriminating-mutant` | 0 | 0 | PASS | 3.738254 |
| `production-eval-required-stays-true` | 1 | 1 | PASS | 2.523997 |
| `live-discriminating-mutant` | 0 | 0 | PASS | 2.50077 |
| `dotted-comparisons` | 0 | 0 | PASS | 2.501235 |
| `hyphenated-dotted-comparisons` | 0 | 0 | PASS | 2.51742 |
| `empty-dot-segment-spec` | 3 | 3 | PASS | 0.037859 |
| `trailing-dot-spec` | 3 | 3 | PASS | 0.037975 |
| `leading-dot-observation` | 3 | 3 | PASS | 1.676512 |
| `empty-dot-segment-observation` | 3 | 3 | PASS | 1.667897 |
| `unused-variable-warning` | 0 | 0 | PASS | 2.448204 |
| `uppercase-observation` | 3 | 3 | PASS | 1.690355 |
| `unknown-mutant-observation` | 3 | 3 | PASS | 2.495954 |
| `all-true-mutant` | 1 | 1 | PASS | 2.511767 |
| `required-observation-stays-true` | 1 | 1 | PASS | 2.420117 |
| `positive-control-flipped` | 1 | 1 | PASS | 2.491812 |
| `compilation-only-failure` | 3 | 3 | PASS | 2.611878 |
| `compiler-error-with-runtime-failure` | 3 | 3 | PASS | 2.539768 |
| `empty-observations` | 3 | 3 | PASS | 1.68521 |
| `duplicate-observations` | 3 | 3 | PASS | 1.647142 |
| `missing-positive-observation` | 3 | 3 | PASS | 1.689378 |
| `missing-required-observation` | 3 | 3 | PASS | 1.705116 |
| `partial-mutant-observations` | 3 | 3 | PASS | 2.491491 |
| `no-op-mutation` | 3 | 3 | PASS | 0.040859 |
| `missing-mutation-needle` | 3 | 3 | PASS | 0.041287 |
| `missing-source-setup` | 3 | 3 | PASS | 0.037269 |
| `missing-manifest-setup` | 3 | 3 | PASS | 0.038742 |
| `existing-output-setup` | 3 | 3 | PASS | 0.037577 |
| `reserved-mutation-name` | 3 | 3 | PASS | 0.038214 |
| `empty-module-inventory` | 3 | 3 | PASS | 0.036975 |
| `empty-positive-inventory` | 3 | 3 | PASS | 0.037226 |
| `duplicate-module-inventory` | 3 | 3 | PASS | 0.037966 |
| `duplicate-mutation-inventory` | 3 | 3 | PASS | 0.036958 |
| `duplicate-positive-check` | 3 | 3 | PASS | 0.038633 |
| `duplicate-required-check` | 3 | 3 | PASS | 0.036277 |
| `nonunique-mutation-needle` | 3 | 3 | PASS | 0.039099 |
| `malformed-observation` | 3 | 3 | PASS | 1.662309 |
| `malformed-json` | 3 | 3 | PASS | 0.039702 |
| `duplicate-json-key` | 3 | 3 | PASS | 0.035632 |
| `output-inside-repository` | 3 | 3 | PASS | 0.034798 |
| `output-symlink` | 3 | 3 | PASS | 0.036444 |
| `discovered-nary-dependency` | 0 | 0 | PASS | 2.446767 |
| `fresh-dependency-source-failure` | 3 | 3 | PASS | 1.732314 |
| `missing-audit-root` | 3 | 3 | PASS | 0.040648 |
| `foreign-module-root` | 3 | 3 | PASS | 0.038124 |
| `mutation-module-outside-inventory` | 3 | 3 | PASS | 0.038814 |
| `unchanged-control-failed` | 1 | 1 | PASS | 1.671401 |
| `nonkernel-local-dependency` | 0 | 0 | PASS | 2.577984 |
| `dirty-source-before-run` | 3 | 3 | PASS | 0.829529 |
| `staged-source-before-run` | 3 | 3 | PASS | 0.827998 |
| `source-drift-during-run` | 3 | 3 | PASS | 1.632162 |
| `source-drift-during-mutant` | 3 | 3 | PASS | 2.601029 |
| `specification-drift-during-run` | 3 | 3 | PASS | 1.701988 |
| `runtime-definition-after-proof-boundary` | 3 | 3 | PASS | 0.043046 |
| `attributed-runtime-after-proof-boundary` | 3 | 3 | PASS | 0.037737 |
| `comment-prefixed-runtime-after-proof-boundary` | 3 | 3 | PASS | 0.037959 |
| `macro-after-proof-boundary` | 3 | 3 | PASS | 0.038781 |
| `macro-rules-after-proof-boundary` | 3 | 3 | PASS | 0.037661 |
| `syntax-after-proof-boundary` | 3 | 3 | PASS | 0.039128 |
| `initialize-after-proof-boundary` | 3 | 3 | PASS | 0.041443 |
| `proof-comment-keywords-sibling` | 0 | 0 | PASS | 2.474686 |
| `proof-string-keywords-sibling` | 0 | 0 | PASS | 2.54059 |
| `raw-string-before-attributed-runtime` | 3 | 3 | PASS | 0.040067 |
| `character-before-attributed-runtime` | 3 | 3 | PASS | 0.040714 |
| `proof-raw-string-character-sibling` | 0 | 0 | PASS | 2.529817 |
| `empty-mutation-inventory` | 3 | 3 | PASS | 0.04098 |

Per-case CLI output, spec hashes, Lean observations and runner records are in `controls/summary.json` and `controls/cases.json`. Suite stdout/stderr copies are `suite.stdout.log` and `suite.stderr.log`.

Discriminating production-form probe log contains `error: Nary runtime comparisons failed: 1` and does not contain `Interface runtime`.

## Timeout honesty

- Driver default per Lean/Git command timeout remains 600 seconds (unchanged except namespace strings).
- Harness per-case subprocess timeout remains 1500 seconds.
- Outer invocation record exists at `invocation.json` with `timeout_occurred: false` and `timeout_exception: null`.
- No `TimeoutExpired` occurred. No missing child partial logs are claimed.
- The inherited runner still writes child stdout/stderr only after `subprocess.run` returns. If a future TimeoutExpired happens, that child log will be absent; a BLOCKED summary line must not be treated as complete child bytes.
- Some exit-3 cases never launched Lean, so they have no `control.log`/`probe.log`. That is blocked-before-execution, not a timeout omission.

## Production SPECs generated, not executed

Sixteen separate one-mutant SPECs were generated from `planned-mutations.json` and `production_roots` into `specs/M01.json`–`specs/M16.json`. `executed` is `False`. Reason: `Actual production tests wait on later Lean fixtures.`

Each SPEC has exactly one mutation, that mutant’s `required_false`, and that mutant’s `expected_protected_check` as `positive_checks`. Positive checks were not unioned across mutants. Byte-identical to the sealed planning appendix D files.

| ID | runner_name | module | required_false | positive_checks | sha256 |
|---|---|---|---|---|---|
| `M01` | `m01-set-local-all-peers` | `DefiKernel.Nary.Execution` | `nary.routing.locals` | `nary.empty.exact` | `d5f37b6d3491914d7636b7d3d3eb24b56c238ff9e54a93b18ad72b399d4b80af` |
| `M02` | `m02-accept-pre-world` | `DefiKernel.Nary.Execution` | `nary.world.exact` | `nary.empty.exact` | `8b8d516359c0cbc9e10d9dc4141c0316a7c625233460921a98ae2d80e419e614` |
| `M03` | `m03-erase-store` | `DefiKernel.Nary.Execution` | `nary.store.exact` | `nary.empty.exact` | `ca69e8df1fd821d3ad8b6f2f8536502f8c48f5a169f7b7b23db81e017f35b1b5` |
| `M04` | `m04-drop-own-outputs` | `DefiKernel.Nary.Execution` | `nary.history.own_input` | `nary.routing.locals` | `4874828cab664a4984574a01485e8b3d85c7e8bd5bd690dafefac7a025aa2504` |
| `M05` | `m05-boundary-index-zero` | `DefiKernel.Nary.Execution` | `nary.boundary.index1` | `nary.routing.locals` | `a3d72e3428b04227a8cb4b68da61c1d7a35634dc2fcca8d4bea29ebfd60dd77c` |
| `M06` | `m06-skip-without-consume` | `DefiKernel.Nary.Execution` | `nary.skip.consumed` | `nary.routing.locals` | `b9849dbc18629aafdb984f1ba781ee25ca40d328f92fdd3b0bafd97d2533b79e` |
| `M07` | `m07-freeze-next-index` | `DefiKernel.Nary.Execution` | `nary.success.index` | `nary.empty.exact` | `15077be7b6879cab5316ed33377a65af7d11309449f9f6b22589a0b108813ba3` |
| `M08` | `m08-halt-peers-on-error` | `DefiKernel.Nary.Execution` | `nary.refusal.peer_continues` | `nary.no_failure.exact` | `1cdff67ce50bd9a88b9549978f21eba889a3b9a6bbd581ca292900a31dbb79b9` |
| `M09` | `m09-omit-error-attempt` | `DefiKernel.Nary.Execution` | `nary.refusal.attempt` | `nary.routing.locals` | `352b187a8085087aeade17a5e14748af354c0052bf718f0303259ba5428ebc86` |
| `M10` | `m10-falsify-event-guard` | `DefiKernel.Nary.Execution` | `nary.receipt.evaluated` | `nary.empty.exact` | `b30f8b52463b11c59163f5bbd1df98f158369d5cd9601938c7842c34bbf5cb81` |
| `M11` | `m11-counts-before-analyze` | `DefiKernel.Nary.Schedule` | `nary.admission.suffix_precedence` | `nary.routing.locals` | `6b66df9a77fe937046ccf532cc8f3cf218b8fd8b347c41a05dedadc8479f2ce6` |
| `M12` | `m12-drop-last-count` | `DefiKernel.Nary.Schedule` | `nary.schedule.final_participant` | `nary.routing.locals` | `c41ce80d1a2ca803b8f58b9b21a9500305d696b2d7530e2d62666592e2f0c4a2` |
| `M13` | `m13-stale-attempt-lookup` | `DefiKernel.Nary.CausalRuntime` | `nary.monitor.actual_producer` | `nary.empty.exact` | `ea9d0d41f9be7cc4f444a8257012705b1c8bf7859025dfb73759978d4352469d` |
| `M14` | `m14-drop-monitor-attempt` | `DefiKernel.Nary.CausalRuntime` | `nary.monitor.success_input` | `nary.empty.exact` | `85f02f74dbd805483cee73a796be5d6d4befaf71b68bf00593645608493ffb64` |
| `M15` | `m15-replay-last-on-skip` | `DefiKernel.Nary.CausalRuntime` | `nary.monitor.skip_no_replay` | `nary.monitor.actual_producer` | `a1320f05968bb80da8a1479ac0f629b5e4054dc1de6307053d3c16212490c422` |
| `M16` | `m16-reset-monitor-fold` | `DefiKernel.Nary.CausalRuntime` | `nary.monitor.retained_phase` | `nary.empty.exact` | `cb66b393184ca0bd7e387bb00175a67a419b6f3d9e4a881fd0f91f143a03d927` |

No `python3 scripts/run_nary_mutations.py --spec specs/Mxx.json` production invocation was run.

## Evidence copy

Complete external tree `/tmp/sprint11-nary-controls-r1` was copied into `controls/` (667 raw artifacts). Nested fixture `.git` archived as `controls/fixture-repo-.git.tar.gz`. Symlinks not followed: fixture `lean/.lake/packages` and the `output-symlink` control path.

## Remaining work

This task does not close Sprint11 implementation.

- Nary Lean modules, fixtures, proofs, Audit runtime, and root integration are owned by other workers / later tasks.
- Task 7.3 production one-mutant runs wait on later Lean fixtures. The sixteen SPECs exist and are marked not executed.
- Independent GPT-6 checker has not reviewed these bytes.
- No commit, push, archive, or self-acceptance was performed.
- `implementation_accepted` remains false in the execution contract.

