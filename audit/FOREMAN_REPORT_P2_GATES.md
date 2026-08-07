# Cold re-audit #3: Phase 2 gates

**Verdict: REVISE**

**Audit date:** 2026-08-07

**Audited commit:** `5594b5800ced7f9a55f7d2b64ef9b38ca09ac942`

**Mode:** Read-only audit. This report is the only intended repository change.

## Executive decision

The exact Gate 2.3 command sequence now passes from an exported committed tree.
It derives `28/119`, counts denominators `168/716`, and reports `16.7%/16.6%`.

Four prior blockers are closed. The invalid repository path is fixed. Both IR
trees are tracked. The W2 evidence is tracked. The ROADMAP names Gate 2.2 as the
active gate.

One prior blocker remains. `denominators.py` still has hard-coded numerator paths.
These paths return exit code 0 without validating the numerators against the IR.
The report therefore remains `REVISE`.

## Blocking finding

### F1 — `denominators.py` still accepts unverified numerators

`denominators.py:78-80` accepts `UNGEN_V1` and `UNGEN_V2` as authoritative values.
The script does not compare these values with `compare_v1_v2.py` output.

A clean committed export accepted deliberately incorrect values:

```text
UNGEN_V1=1 UNGEN_V2=2 python3 denominators.py
Numerators from UNGEN_V1/UNGEN_V2 env.
v1 1 / 168 = 0.6%
v2 2 / 716 = 0.3%
EXIT 0
```

`denominators.py:39-49` also converts a skipped or failed comparison into
`None, None`. Lines 87-88 then substitute the hard-coded values `28` and `119`.

The committed `SKIP_COMPARE` path reproduced this behavior:

```text
SKIP_COMPARE=1 python3 denominators.py
WARNING: compare unavailable; using last measured 28/119.
v1 28 / 168 = 16.7%
v2 119 / 716 = 16.6%
EXIT 0
```

Thus, a failed comparison can produce a successful stale-rate report. This is
the same numerator-integrity defect from the prior audit.

Remove the fallback and make comparison failure fatal. Remove the numerator
overrides, or validate them against values derived from the selected IR trees.

## Clean-checkout reproduction

I exported commit `5594b58` with `git archive` into a new temporary directory.
This excluded all untracked result files and Python caches from the working tree.

I then ran the documented commands from `research/positive-program/basis`:

```bash
python3 compare_v1_v2.py
python3 denominators.py
```

Both commands returned exit code 0.

| measurement | v1 | v2 |
|---|---:|---:|
| raw definitions tested | 172 | 1605 |
| raw definitions ungenerated | 28 | 681 |
| protocol definitions ungenerated | 28 | 119 |
| protocol definition denominator | 168 | 716 |
| protocol ungenerated rate | 16.7% | 16.6% |

The successful denominator path reported: `Numerators derived from
compare_v1_v2.py this run.` This closes the prior path and default-data-flow
failures for the documented command sequence.

## Prior finding disposition

| prior item | result | evidence |
|---|---|---|
| denominator invalid path | **CLOSED** | Both documented commands pass in the committed export. |
| IR untracked | **CLOSED** | Git tracks ten v1 IR files and ten v2 IR files. |
| hard-coded numerators | **OPEN** | Lines 78-88 retain unvalidated overrides and the `28/119` fallback. |
| ROADMAP next gate 2.0f | **CLOSED** | `ROADMAP.md:135` names Gate 2.2 as active. |
| W2 evidence not in Git | **CLOSED** | Git tracks `GATE-2.1b-W2.md` and all four cited mutants. |

## Gate assessments

### Gate 2.1b W2 evidence

**PASS for the audited durability issue.**

Git tracks `GATE-2.1b-W2.md`. Its mutant tables match the result comments in
`compound_v3.qnt`, `morpho_blue.qnt`, and `gmx.qnt`. Git also tracks the four
cited mutant models.

### Gate 2.2 count honesty

**PASS.**

`GATE-2.2-STATUS.md:3-10` separates the original 19 applications from the
remaining 18. It identifies Steakhouse Financial as the one reclassified item.

### Gate order

**PASS.**

`ROADMAP.md:132-135` marks Gate 2.2 active and Gate 2.3 measured. It no longer
directs work to closed Gate 2.0f.

### Gate 2.3 repository reproduction

**PASS for the documented default commands. FAIL for numerator integrity.**

The committed IR and repository-relative paths reproduce the published values.
The unvalidated success paths prevent approval of the measurement tool.

## Approval condition

Make `denominators.py` fail when it cannot derive numerators from the selected
IR. Validate or remove caller-supplied numerators. Then rerun both documented
commands from a clean committed tree.
