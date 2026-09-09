# P17 AGY r2 — Opus consumer diagnostic

**Reviewer:** native Claude Opus (`claude-opus-5`), independent.
**Author under review:** AGY Gemini 3.8 Flash High (still running; its worktree was not read or written).
**Date:** 2026-09-09.
**This is not P17 acceptance.** `acceptance: false`. Full frozen-candidate Opus review remains pending.

## Answers

| # | Question | Answer |
|---|---|---|
| Q1 | Does the actual `run_fixtures` consumer + scorer block unavailable/missing Lean rows with **exit 3** rather than semantic **fail 1**? | **No.** A missing row becomes `gate: "fail"` → `exit 1`, `blocked: 0`. |
| Q2 | Does it compare specific Lean refusal and success Ledger/poststate observations, or merely a scalar/status label against fixture literals? | **No.** Refusals are matched on the bare label `"error"`; successes on a single scalar compared to the *fixture literal*. No Lean poststate is compared — none is exported. |
| Q3 | Does the model-output parser reject duplicate/malformed/missing rows and nonzero process receipts? | **No.** The receipt's exit/classification/valid are never read; duplicates silently last-wins; the parser's own verdict is computed, written to disk, and then discarded. |

Six of eight permitted invocations were used. The diagnostic stopped because the three questions were answered, not because the budget ran out.

## Inputs and how they were bound

All 24 snapshot files verified against `inputs.json` sha256 (0 mismatches). The deployment archive `p17-agy-r2-first-campaign-failure/execution.tar.gz` hashes to `f0d5146…d70390`, equal to its `observation.json` `archive_sha256`; `addresses.json` and `create-proxy/genesis.json` were verified against the 2613-entry per-file `manifest.json` **before** extraction, and only those two files were extracted, into `work/setup/`.

A useful cross-check fell out of this: the archive's `engine-after-failure/*.py` hashes are **identical** to the snapshot engine hashes. The code I tested is the code that produced the observed r2 failure.

`common.ROOT` resolves to the snapshot directory, so the frozen engine imported and ran against the frozen `fixtures.json` and the pinned recorder with no path patching. Only the output directory and the public `lean_rows` argument varied between attempts. Nothing in `work/driver.py` reimplements consumer logic — every attempt records `run_fixtures.__code__.co_filename` to prove the real function ran.

## Q1 — unavailable Lean evidence is scored as a semantic failure

`run_fixtures` line 627-636 wraps the Lean bindings call in a bare `except Exception: lean_rows = {}`. Downstream, at :709 (success) and :759 (revert), a `None` row makes `lean_model_ok` false, which sets `gate = "fail"` at :727 / :761. `score_rows` then sees `blocked == 0` and returns `exit 1`.

**A5 (production default path, `lean_rows` omitted, Lean bindings blocked):**

```
scored: {status: "fail", exit: 1, fail: 3, ok: 0, blocked: 0,
         reason: "bound observation disagrees with independent expected"}
ROW P17-DEP-D0       gate=fail  semantic_ok=true  lean_model=null
ROW P17-DEP-BAD-RECV gate=fail  semantic_ok=true  refusal_match=true  lean_model=null
ROW P17-RED-BAL      gate=fail  semantic_ok=true  refusal_match=true  lean_model=null
```

Every EVM observation agreed with the expected result. The consumer nonetheless reported that the bound observation *disagrees*. This is the repo's canonical footgun — a blocked check reported as a false property — and it is the exact failure recorded in `p17-agy-r2-first-campaign-failure/observation.json` ("17/17 vault cases reported semantic fail while Lean bindings command could not find relative source path"). I reproduced it from the frozen functions rather than taking that report's word for it.

**A2** isolates the cause: with `P17-DEP-D0`'s row present and the two revert rows absent, the intact row stayed `ok` and only the two absent rows turned `fail`. The trigger is row *availability*, not disagreement.

→ **F2**, blocker.

## Q2 — the Lean refusal contents are never read

The frozen Lean export *does* emit the specific failure. `generate_vault_bindings_lean` at vault_exec.py:462 prints `status=error failure={sourceLabel e}`, and the parser stores it as `row["failure"]`. Line 759 then tests only `lean_row.get("status") == "error"`.

**A3** puts the falsifier and its control in one run:

```
ROW P17-DEP-D0       lean value 424242 (wrong)                        → gate=fail
ROW P17-DEP-BAD-RECV lean failure "SUsds/insufficient-balance",
                     source refused "SUsds/invalid-address"           → gate=OK
ROW P17-RED-BAL      lean failure "Panic(0x12)" (division by zero),
                     source refused "SUsds/insufficient-balance"      → gate=OK
```

The value check fires; the refusal check does not exist. The asymmetry is specific to refusals, so this is not an always-on gate. A6 reconfirmed it on the production default path.

This is a **regression against code already in the same engine**: `token0_campaign.py:622-625` already does `lean_row.get("error") == exp["error"]`. A repair should not be a naive string equality, though — `Types.lean:77-84` emits `SUsds/…` and `Panic(0x11)/0x12`, while `fixtures.json` expects `Usds/insufficient-balance` and `Usds/insufficient-allowance` for the two mock-token reverts. An explicit declared mapping is needed, blocking on an unmapped label.

On the success side the Lean scalar is compared against `fx["expected"]["ok_shares"/"ok_assets"]` — the fixture literal — and the EVM returndata is compared against the same literal. Lean is never compared against the observation. And no Lean poststate exists to compare: `formatRow` at :461 destructures `.ok (_, w)`, discarding the `Ledger` entirely. The poststate agreement in this gate is EVM-vs-fixture-literal only (**F6**). It should not be described as a Lean/source state correspondence.

Separately, the revert branch never re-observes state yet writes `"pre_retained": True` as a literal into the row (**F7**).

→ **F3** blocker, **F6** and **F7**.

## Q3 — the parser accepts a failed run

`run_lean_vault_bindings` (:513-551) reads `_wrapper.stdout_path` and parses whatever is there. It computes `summary["status"] = "ok" if len(parsed) == 17 else "blocked"`, writes it to `bindings-summary.json`, and then **returns `parsed` alone**. The caller cannot see the verdict, and `receipt["exit"]`, `receipt["classification"]` and `receipt["valid"]` are never read.

Eight sub-probes (`A4`, disclosed recorder stub):

| Probe | Input | Result |
|---|---|---|
| P1 control | 17 rows, exit 0 | 17 rows, summary ok — baseline holds |
| P2 truncated | 9 rows, exit 0 | 9 rows returned; summary said `blocked` but the caller never sees it |
| P3 **nonzero receipt** | 17 rows, **exit 1**, `classification: nonzero` | 17 rows returned, summary `ok` |
| P4 **timeout** | 5 rows, exit 124, `valid: false` | 5 rows returned, no error |
| P5 **duplicate** | 17 rows + a second `P17-DEP-D0 value=999` | count still 17, summary `ok`, **value silently became 999** |
| P6 malformed | `value=NaN` | uncaught `ValueError` from vault_exec.py:540 |
| P7 foreign line | a `P17-`prefixed non-`formatRow` line | accepted as a row |
| P8 blocked receipt | `record_cmd` returned a blocked report | `{}` returned silently |

**A6** carries P3 end to end on the production default path. The Lean bindings process exited **1**, and the consumer reported:

```
scored: {status: "ok", exit: 0, ok: 3, fail: 0, blocked: 0}
bindings-summary.json: status="ok" count=17  alongside  receipt.exit=1 classification="nonzero"
```

A failed model run earned full source credit. This is the dangerous direction, and it is the one finding here that produces a confident wrong *pass* rather than a wrong *fail*.

P6 compounds with F2: one malformed character raises out of the parser, the bare `except` at :635 converts it to `lean_rows = {}`, and all seventeen fixtures become semantic failures.

→ **F1** blocker (rank 1), **F4**, **F5**.

## Ranked findings

1. **F1** *(blocker)* — Lean process receipt never consulted; a failed run scores `exit 0`. `vault_exec.py:513-551`; same defect in `token0_campaign.py:298-341`.
2. **F2** *(blocker)* — unavailable Lean rows → `exit 1` instead of `exit 3`. `:627-636`, `:709-715`, `:726-727`, `:759-761`.
3. **F3** *(blocker)* — Lean refusal contents ignored; any error matches any revert. `:759`. Regression against `token0_campaign.py:622-625`.
4. **F4** *(major)* — duplicate rows last-wins and still pass the count check. `:543`.
5. **F5** *(major)* — partial stdout accepted, malformed value raises, admission by `startswith("P17-")` instead of the id set. `:528-543`.
6. **F6** *(major)* — no Lean poststate is compared, and none is exported. `:459-462`.
7. **F7** *(moderate)* — `pre_retained: True` is a hardcoded literal, never observed. `:775-776`.
8. **F8** *(moderate)* — the scorer's required-id set is derived from the same filter, so a subset selection scores an unqualified `ok`. `:789`.

Exact repairs for each are in `findings.json`. I did not modify any implementation file.

## Improvements already present — preserve these

- `common.score_rows` (`common.py:172-245`) is a sound fail-closed grammar: empty selection → blocked 3 with an explicit denominator; missing id, duplicate id, missing `comparison.gate`, unrecognized gate all → blocked 3; any blocked row dominates any fail. **Every finding above is about what is fed to it, not about the grammar.**
- `common.record_cmd` (`:260-339`) pins the recorder by sha256, refuses a missing/drifted recorder and a missing/malformed receipt, and correctly marks timeout and exit 124 as blocked with `valid: False`. The information needed to fix F1 is already computed there.
- `compare_cells` (`vault_exec.py:302-318`) reads all 19 `OBSERVED_CELLS` by name and **blocks** on a missing expected or observed cell rather than skipping it. It reads the row as a row.
- `compare_logs` (`:554-562`) requires exact ordered equality of the full log sequence; a parse exception becomes `fail`, not a swallow.
- `run_fixtures` blocks correctly on prestate mismatch and on blocked pre/post observation and unknown expected status.
- `vault_campaign.main` maps a failed compile to exit 3 and refuses non-empty evidence directories.
- `token0_campaign.py` already has the correct refusal comparison and the correct id-set admission. F3 and F5(c) are vault-side regressions against existing behaviour, not new work.

## Controls

- **A1** intact positive control: 3/3 `ok`, `exit 0`, real pinned EVM (`op`, `op-returndata`, 17 view calls per fixture, all receipts `classification: ok`). The gates are not always-red.
- **A3 / P17-DEP-D0**: a wrong Lean value gated `fail` in the same run where two wrong refusal labels gated `ok` — the refusal gap is specific, not a blanket pass.
- **A2 / P17-DEP-D0**: an intact row stayed `ok` beside two missing rows — the effect is row availability.
- **A4 / P1**: parser baseline, 17 rows, summary `ok`.

## Limits

- Consumer diagnostic only. No verdict on the Lean proofs, the Solidity capture, the compile closure, or the candidate as a whole.
- **No Lean was compiled.** Every Lean row is diagnostic input supplied through the public `lean_rows` argument or through a disclosed recorder stub. No fresh model execution is claimed.
- **Disclosure:** A4, A5 and A6 replaced `vault_exec.record_cmd` with a private stub for the `lean-vault-bindings` subprocess only. The parser and consumer bodies under test were the unmodified frozen functions, and EVM execution used the real frozen recorder and the pinned `evm` binary. No Solidity production-mutant credit and no fresh-model-execution credit is claimed from those attempts. `scripts/token0_p16/record_cmd.py` retains its pinned hash `31057e00…baaed1`.
- No Solidity mutant was executed, so this cannot say whether the cell/log comparison would catch a real source defect. `compare_cells` and `compare_logs` were exercised only against the intact deployment.
- Three of seventeen fixtures were exercised, to stay inside the invocation budget. F1–F5 are properties of the shared code path and are not fixture-specific, but fourteen fixtures were not run.
- Trace JSON / depth parser defects were out of scope and were not re-examined.
- The deployment and prestate came from the frozen archive, not a fresh compile+deploy.
- One setup attempt failed before any probe ran (output directory not pre-created). That is recorded as blocked setup, not as a result.
- Root's prior diagnostics were read as context. F2 independently reproduces the failure mode they describe; the other seven findings are asserted by neither document.

## Evidence layout

```
work/setup/evm/execute/deploy/     verified extraction (2 files)
work/driver.py                     imports the frozen engine; varies only out-dir and lean_rows
work/driver_default_path.py        production default path; disclosed recorder stub
work/parser_probe.py               8 parser sub-probes; disclosed recorder stub
work/attempts/A1…A6/               per-attempt provenance.json, result.json, driver.stdout/.stderr
work/work-manifest.json            sha256 + size of 1967 work files
```

Each attempt's `provenance.json` records argv, cwd, UTC bounds, `common.ROOT`, the resolved `FIXTURES` and `RECORDER` paths, the recorder sha256, source hashes for `vault_exec.py` / `common.py` / `score.py` / `evm.py` / `fixtures.json`, the addresses and genesis hashes, the `run_fixtures` and `score_rows` `co_filename`, and whether the recorder was substituted. Driver exits and consumer-reported status/exit are recorded separately throughout.
