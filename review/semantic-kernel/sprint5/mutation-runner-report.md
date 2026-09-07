# Sprint 5 composition mutation runner

Implemented `scripts/check_composition_mutations.py` and its real CLI control
harness. This report records bounded runner and actual workflow mutation evidence.
Composition theorem verification and independent native review are separate
integration obligations.

The final composition harness passed **36/36 actual CLI controls**. The accepted
case compiled fresh unchanged source and executed two true comparisons; its real
`n ≤ 4` → `n ≤ 5` mutant compiled and executed `runner_sensitivity: false` while
`runner_positive` remained true. A surviving `n ≤ 3` mutant returned exit 1.
Compiler-only and mixed compiler/runtime failures returned exit 3, never a
semantic detection. Empty inventories/observations, duplicates, missing checks,
partial execution, missing/nonunique needles, unchanged replacements, malformed
JSON/observations, reserved artifact names, and output misuse were rejected.

Dotted and hyphenated dotted comparison names have executed accepted siblings;
leading/trailing dots and empty dot segments are rejected in spec/output controls.
The earlier 30-control replay remains under `runner-controls/` as historical evidence.

The unchanged Sprint 4 runner harness passed **17/17 CLI controls**; both legacy
runner source files have zero Git diff. Python syntax checks passed for both new
files. These results do not establish correctness of arbitrary user-supplied
Lean checks or their expected values; source review supplies that trust boundary.

Commands (each exited 0):

```sh
python3 scripts/test_composition_mutation_runner.py --repo . --out /tmp/defiformal-sprint5-runner-controls-scoped-final
python3 scripts/test_typed_kernel_mutation_runner.py --repo . --out /tmp/defiformal-sprint5-legacy-runner-controls
```

[Composition summary](runner-controls-scoped/summary.json) and
[case records](runner-controls-scoped/cases.json) contain exact commands, tool/source
hashes, classification expectations, complete CLI output, observed Lean
comparisons, and log hashes. The `runner-controls-scoped/runs/` directories preserve
actual source projections, input snapshots, manifests, and subprocess logs.
[Legacy summary](legacy-runner-controls/summary.json) and the adjacent artifacts
preserve the unchanged runner replay. Absolute paths in records identify the
original scratch executions; evidence copies retain their original bytes.
The synthetic Git fixture repositories and dependency symlinks are not copied.

## Integration contract

Run from the repository root, selecting a new output path outside the repository:

```sh
python3 scripts/check_composition_mutations.py --repo . --spec review/semantic-kernel/sprint5/mutation-spec.json --out /tmp/composition-mutations-NEW
```

Schema version 1 has exactly these top-level fields:

```json
{
  "schema_version": 1,
  "modules": ["DefiKernel.Composition.RunnerInput", "DefiKernel.Composition.RunnerAudit"],
  "positive_checks": ["runner_positive"],
  "mutations": [{
    "name": "probe",
    "module": "DefiKernel.Composition.RunnerInput",
    "needle": "n ≤ 4",
    "replacement": "n ≤ 5",
    "required_false": ["runner_sensitivity"]
  }]
}
```

All inventories must be nonempty and unique. Each mutation applies exactly once
in its named executable projection. Names for comparisons use lowercase letters,
digits, underscores and hyphens in nonempty dot-separated segments, each starting
with a letter; variant names use lowercase
letters, digits and hyphens and cannot overwrite reserved tool/control logs.
Every required comparison must exist in the unchanged run, and every mutant must
execute the identical comparison set. Positive controls must remain true.
The runtime driver prints `name: true` or `name: false`, then throws exactly
`Composition runtime comparisons failed: N` when N comparisons fail. A detected
mutant must have that single diagnostic, a nonzero Lean exit, and every named
required false comparison. Additional compilation errors block acceptance.

Only Composition modules can be explicit mutation targets. All local DefiKernel
imports are recursively read, hashed, topologically ordered and concatenated
from current source; no project olean is imported. Imported Composition modules
must be listed explicitly. External Mathlib dependencies remain installed package
imports, identified by the recorded Lake manifest/toolchain. Composition proof
suffixes beginning at the unique `-- BEGIN PROOFS` marker are replaced by the
matching namespace closure. Unchanged dependency proof tails are retained.
A real Typed fixture theorem located after its proof marker is referenced from
Composition to exercise that distinction. No accepted source file is rewritten.

The runner records input hashes before/after replay, executable Lean identity,
Git revision and dirty-input status, spec/script hashes, and all subprocess
commands/log hashes, including blocked runs that reached subprocess execution.
Exit 0 means all specified nonempty mutations discriminate; exit 1 means an
executed semantic expectation failed; exit 3 means malformed or unavailable
evidence. Projection supports the documented simple one-module-per-import
syntax and matching namespace closure, and deliberately blocks unsupported input.

Runner-control source/tool binding:

- Runner SHA-256: `0c03c093df36cdf64e907ead230a73a25190bc50eccf6670d7259c6fbd64a031`.
- Harness SHA-256: `c1a873d376eac77bc0f2c8e4cf2b512c34333fa3c9a674780e70ab996c49e706`.
- Lean: `Lean (version 4.33.0-rc2, x86_64-unknown-linux-gnu, commit d8b18978322de05a8f3dba51ef03cf5461676c17, Release)`.
- Initial controls observed `86b77b7f658f57530cc3833c66812d26d9925018`; the final
  36-case scoped-name controls observed `ba3661f3e875ef6c48e71300fec339d333dab697`
  with new runner files uncommitted. Current committed bytes are verified against
  `28ba18c` in `commit-source-verification.json`.

## Source-change rejection during integration

The first real workflow replay compiled an unchanged control (85/85 true) and
all twelve altered implementations. Each mutant produced its designated false
comparisons. The runner nevertheless returned **exit 3** because accepted source
bytes changed during replay. This run is not accepted final mutation evidence.
The [rejection record](mutation-probe-rejected.json) preserves the command,
classification, captured/current input hashes and all measured outcomes; the
[probe artifacts](mutation-probe-artifacts/source-manifest.json) retain the exact
captured source closure, projections and compiler/runtime logs. This exercises
the source-unchanged guard on an actual concurrent source change.

## Accepted actual workflow mutations

The final source-bound CLI replay exited **0**, with **93/93**
unchanged comparisons true and **12/12** actual source mutants detected. Every
mutant compiled, executed the identical comparison inventory, failed all its
designated comparisons, and preserved all six positive controls. Inputs matched
before/after hashes and were rechecked against current source before evidence copy.

[Final summary](mutations/summary.json), [exact CLI command](mutations/command.json),
[CLI output](mutations/cli-output.log), [source manifest](mutations/source-manifest.json),
and [complete results](mutations/results.json) bind the source, spec, tool and
observations. [Mutation specification](mutation-spec.json) records every exact
needle/replacement and designated false comparison. Copied scratch paths retain
the original bytes; all actual projections, inputs and per-variant logs are adjacent.

Protected positives include three catalog checks plus an actual permitted
transfer with receipts/snapshots, a permitted shared write, and a funded kernel
execution. Each remained true in every mutant.

| Mutation | Designated executed failures |
| --- | --- |
| reverse-order | `workflows.transfer.deposit.withdraw`, `workflows.order.transfer.first` |
| drop-first-step | `workflows.consecutive` |
| continue-after-refusal | `workflows.first.refusal`, `workflows.resume.terminal` |
| reset-ledger | `workflows.consecutive` |
| reset-capability-store | `workflows.admin.live.repeat` |
| omit-revocation-propagation | `execution.revoke.ledger.receipt`, `workflows.admin.revocation` |
| interface-write-bypass | `interface.foreign-write`, `interface.readonly-write`, `workflows.isolation.private`, `workflows.isolation.readonly` |
| wrong-output-index | `workflows.output.index` |
| wrong-output-unit | `interface.wrong-output-unit`, `workflows.output.unit` |
| drop-supply-receipt | `workflows.order.deposit.first`, `workflows.transfer.deposit.withdraw` |
| reset-continuation-index | `workflows.resume.output`, `workflows.resume.time` |
| wrong-snapshot-index | `interface.snapshot-exact`, `workflows.output.index` |

The supplied mutations alter executable implementation behavior, including
receipt payload supplies; they do not edit expected workflow values or runtime
check definitions. The dropped supply mutation clears actual receipt `supplies`
after genuine kernel execution, and is detected by independent expected receipts.
These reference workflows do not establish deployed-contract fidelity, machine
arithmetic refinement, or general semantic correctness.
