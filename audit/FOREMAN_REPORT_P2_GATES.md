# Cold re-audit: Phase 2 gates after REVISE fixes

**Verdict: REVISE**

**Audit date:** 2026-08-07

**Scope:** Gate 2.1b W2, Gate 2.2 status, Gate 2.3 ten-protocol measurement,
the ROADMAP gate rows, the three generation scripts, and both IR directories.

**Mode:** Read-only audit. This report is the only intended repository change.

## Executive decision

Two prior blockers are fixed in substance. The W2 mutant tables accurately
describe the model evidence. The Gate 2.2 table clearly distinguishes the
original 19 applications from the remaining 18.

The historical gate-order statement is also honest now. It says that Gate 2.3
ran before the W2 delivery record and received retrospective validation.

Gate 2.3 is still not reproducible from a clean checkout. The documented
denominator command fails. The IR trees are not tracked by Git. The denominator
script also retains hard-coded numerator defaults. The ROADMAP therefore cannot
call Gate 2.3 `repo-reproducible`.

## Blocking findings

### F1 — The documented denominator command fails

`GATE-2.3-TEN.md:13-16` gives these commands:

```bash
cd research/positive-program/basis
python3 compare_v1_v2.py
python3 denominators.py
```

The comparison command completed and derived these values from the current IR:

| value | v1 | v2 |
|---|---:|---:|
| raw definitions | 172 | 1605 |
| raw ungenerated | 28 | 681 |
| protocol ungenerated | 28 | 119 |

The denominator command failed with this path:

```text
/root/DefiElements/research/research/positive-program/sigma/gen-ir-v1ten
```

`denominators.py:8` uses `Path(__file__).resolve().parents[2]`. For that file,
this expression resolves to `/root/DefiElements/research`. The script then adds
another `research` component at lines 9-10.

Explicit IR overrides made the denominator calculation complete. It returned
`168` and `716`, followed by `16.7%` and `16.6%`. This workaround is not the
documented reproduction command.

### F2 — The claimed committed IR is untracked

Both IR directories exist and each contains ten valid JSON files. Their current
aggregate SHA-256 values are:

| tree | files | aggregate SHA-256 |
|---|---:|---|
| `sigma/gen-ir-v1ten` | 10 | `88ee8a6fd64f19c370623ffeb61b7d14a7b4e846dfe29f0005d7546e9fa0ea35` |
| `sigma/gen-ir-v2ten` | 10 | `7b431f29a2bd816983e2d12a8d342cbb4ef5340cde00f0d83f82fad9628b5bcd` |

However, `git ls-files` returned no files for either directory. `git status`
reported both directories as untracked. The generated `RESULT-gen-ir-*.json`
files are also untracked.

This contradicts `GATE-2.3-TEN.md:25` and `ROADMAP.md:133`, which call the IR
committed. A clean checkout does not contain these inputs.

### F3 — The denominator still accepts hard-coded numerators

`denominators.py:53-60` defaults to `28` and `119`. It does not read the output
from `compare_v1_v2.py`. Environment variables can replace both values without
any consistency check against the IR.

The comparison script now derives the correct numerators and treats subprocess
failures as fatal. Those repairs are valid. The denominator step does not consume
the derived results, so the prior hard-coded-numerator blocker remains.

## Criterion assessment

### 1. Gate 2.1b close adequacy with mutant evidence

**PASS in substance. PARTIAL for durability.**

`GATE-2.1b-W2.md:76-118` now has mutant-discrimination tables. The tables cite
the corresponding comment blocks in each target model. The stated outcomes
match those comment blocks.

Fresh runs used Quint `0.32.0` and the recorded sample bounds. They confirmed:

| mutant | non-discriminating checks | discriminating checks |
|---|---|---|
| `compound_v3_M1` | conservation and live residue witness stayed `ok` | `inv_T0` and `inv_storeFrontMargin` violated |
| `morpho_blue_M1a` | conservation, liquidity, T0, incentive, and live witness stayed `ok` | `inv_noUnbackedDebt` violated |
| `morpho_blue_M1b` | conservation, liquidity, and live witness stayed `ok` | T0, incentive, and no-unbacked-debt checks violated in focused runs |
| `gmx_M1` | conservation, bounds, backing, position matching, and live witness stayed `ok` | T0, convexity, and the usage witness violated |

The new tables are credible evidence, not unsupported conclusions. However, the
W2 file is itself untracked. It also records no exact invariant commands, Quint
version, seeds, or durable output log. Thus, the record is not durable across a
clean checkout and does not fully meet the prior approval condition.

### 2. Gate 2.3 reproducibility from clean repository paths

**FAIL.**

The comparison command is now repository-relative and reproducible in the
current workspace. The complete documented sequence is not reproducible. The
denominator path is wrong, the IR is untracked, and the rates use default
numerators that are not connected to the comparison run.

`generate.py` now accepts `GEN_IR` and `GEN_RESULT`. The comparison script uses
both variables correctly. Its legacy standalone defaults still point outside the
repository, but the comparison path does not use those defaults.

### 3. Gate-order honesty

**PASS for historical order. FAIL for the active-gate statement.**

`GATE-2.3-TEN.md:20-23` states the actual historical order. `ROADMAP.md:133`
also says the 2.3 measurement preceded the W2 write-up. This fixes the principal
order-honesty blocker.

`ROADMAP.md:135` still says that Gate 2.0f is the next gate. The gate table marks
2.0f closed, while `GATE-2.2-STATUS.md:12-18` identifies Gate 2.2 as active. This
stale instruction still misstates the current execution order.

### 4. Gate 2.2 count honesty

**PASS.**

`GATE-2.2-STATUS.md:3-10` separates all four quantities:

| quantity | result |
|---|---:|
| original work-list | 19 |
| original items with local contracts | 0 |
| Steakhouse reclassification | minus 1 |
| remaining items | 18 |

Fresh work-list and availability runs reproduced 19 unspecced applications and
0 of 19 with contracts in `protocol-repos`. The Steakhouse explanation supports
its removal as a firm rather than a distinct protocol. The ROADMAP row also says
`18 after Steakhouse reclass`, so its two denominators are understandable.

## Ranked residual actions

1. Fix the repository root in `denominators.py`. Run the exact documented command
   sequence from `research/positive-program/basis`.
2. Derive numerator and denominator values in one data flow. Remove the `28` and
   `119` defaults, or validate supplied values against generated result files.
3. Track both IR trees and all required evidence files. Verify their presence with
   `git ls-files` from a clean checkout.
4. Add exact mutant commands, Quint `0.32.0`, sample bounds, and replay seeds or
   durable logs to the W2 delivery record. Track that record.
5. Change the ROADMAP Gate 2.3 state until actions 1-3 pass. Replace the stale
   `Next gate: 2.0f` statement with Gate 2.2 acquisition work.
6. Record the IR construction recipe, source hashes, and tool versions. This action
   is not required to reproduce the stored-IR calculation, but it is required to
   audit how the IR was produced.

## Approval condition

Do not change the verdict to `APPROVE` until the exact documented Gate 2.3
sequence passes from a clean checkout and all evidence files are tracked.
