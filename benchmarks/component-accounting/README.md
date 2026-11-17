# Scoped adapter accounting baseline

This baseline measures the two complete Lean adapter files below at source
revision `18646e635a95a9890d45a58c8faca03945983d4e`. It is not a count of the
complete vault or token0 components. **Agenda I.3 remains unmet:** separate,
complete historical authoring effort for these components is unavailable.
Unknown effort is `null`, never measured zero.

| Selected adapter file | Model | Specification | Guidance | Excluded | Blank | Physical total |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| [Vault deposit](../../lean/DefiKernel/Vault/Adapter.lean) | 66 | 90 | 164 | 18 | 56 | 394 |
| [Token0 quote register](../../lean/DefiKernel/ConcentratedLiquidity/Token0Bridge.lean) | 49 | 87 | 133 | 17 | 65 | 351 |

## Counting method

[manifest.json](manifest.json) binds exact source bytes with SHA-256 and assigns
every physical line to one inclusive range and one role. Line numbers are
one-based; the checker uses Python `str.splitlines()`. Blank lines have their
own category. Nonblank lines have one primary role:

- **Model:** types, data, operation templates, registry, capabilities, requests,
  pre/post states, library inputs and quantity lifts.
- **Specification:** theorem declaration and statement lines, including the line
  that introduces the proof term. These are Lean statements, not counts of the
  project's OpenSpec requirements.
- **Guidance:** subsequent proof terms and tactic bodies, plus proof-valued
  fields that justify state validity. This counts supplied Lean proof source;
  it does not measure prompts, author reasoning or time.
- **Excluded:** comments, imports, namespace/open/end scaffolding.

A line that combines a statement or model definition with an inline proof term
keeps its primary specification or model role. For example, Vault's one-line
`scale1_pos` is specification; the token0 finite-type instances are model lines
although they contain proofs. No token-level split or double counting occurs.
Proof declarations are classified by their content and ranges, not by the
`BEGIN PROOFS` comment: token0's later `postWord`, `preQ` and `postQ` definitions
remain model lines. These conventions affect comparisons with other counting
methods and do not estimate the intrinsic cost of a proof.

The classification is explicit and manually reviewed. The checker establishes
hash identity, exhaustive/disjoint coverage and arithmetic consistency; it does
not automatically establish semantic correctness of the chosen roles.

## Supporting scope and exclusions

The manifest separately hashes 16 native imported support files and records
which adapter uses each. These inherited/shared files are **unallocated**, not
free or absent. Their physical lengths are context only and are excluded from
the role totals above. In particular:

- `Vault.Operations` also implements mint, withdraw and redeem; its entire 549
  lines must not be charged to the deposit adapter. `Vault.Types` and
  `Vault.Conversion` are inherited support.
- `SqrtPriceMath` and `FullMath` are inherited token0 library code, separate from
  the quote-register adapter. The register is not pool storage or cash settlement.
- Typed execution and arithmetic helpers are shared dependencies. Their code is
  listed once in the support inventory, without a per-component cost split.

Mathlib/Lean dependency source, vault/token0 examples and runtime/proof audit
modules, the shared Python platform engine, Solidity captures, campaign fixtures,
OpenSpec documents, review prose and model prompts are outside these adapter
line counts. A full-component accounting would need its own reviewed allocation
of these scopes; this baseline does not supply that total.

## Authorship and unavailable effort

The [historical case-two inventory](../../review/semantic-kernel/vault-platform-reuse/p17/implementation/grok-r5/case-two-inventory.json)
records AGY r1-r4 authoring and native Grok 4.6 R5 repairs across the vault,
token0 and shared engine/evidence work. The
[R6 summary](../../review/semantic-kernel/vault-platform-reuse/p17/implementation/grok-r6/R6-SUMMARY.md)
preserves that lineage and states that its repairs changed engine files, not
Lean theorem statements. This is candidate-level AI-assistance attribution;
there is no recovered per-line or per-component author split. Separate human
authoring contributions and time are not measured. These attributions make no
copyright ownership determination.

The [AGY process receipt](../../review/semantic-kernel/program-execution-20260908/p17-implementation-agy-r1-attempt2-process.json)
records requested model `gemini-3.8-flash-high`, effort `high`, and a result's
reported session duration of `1994.15471889` seconds. It covers both components
and shared work. That requested alias is not upgraded here to an independently
verified returned model identity. A session duration is not a complete
per-component authoring measurement.

The inventory's R5 `record_cmd` start/end intervals are command runtimes, not
authoring or person-hours. Its Opus session is reviewer effort, not author
effort. Failed attempts and cumulative/shared sessions are retained without
summing them or splitting them arbitrarily. The
[P17 acceptance](../../review/semantic-kernel/program-execution-20260908/P17-ACCEPTANCE.md)
is the later acceptance authority; the earlier inventory's self-assessment
remains historical. Seven source records supporting these statements are hashed
in the manifest. Neither these records nor the counts close I.3.

## Run the read-only check

From the repository root with Python 3.9 or later:

```sh
python3 scripts/check_component_accounting.py
python3 scripts/test_component_accounting.py
```

The checker prints JSON and does not regenerate its manifest or source files.
Exit 0 means nonempty accounting consistency; exit 1 means an inconsistent
classification or unsupported effort/completion claim; exit 3 means blocked
source/evidence identity or missing/empty scope. CLI usage errors exit 2. A pass
retains `agenda_I_3_status: unmet`.

Tests run the real checker against intact and deliberately altered inputs:
source drift/missing source, omitted and overlapping ranges, unknown roles,
incorrect blank labels, empty and partial two-component scopes, and promotion of
unknown effort to zero or task completion. No Lean proof build is needed because
this change measures existing bytes and changes no financial behavior.
