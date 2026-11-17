# IOG benchmark adapter sources

This directory contributes the DeFiFormal adapters from the IOG Technical
Intelligence assessment, source revision
`1ced5fe1e0a83d665184bb496bea01bcb9940449`. `PROVENANCE.json` records the
original path, byte count and SHA-256 of each of the 168 imported files.
`upstream/` preserves those Git object bytes. It includes only DeFiFormal
adapter sources, their contract files, correspondence and attribution records.
The competitor corpus, assessment results, compiled artifacts and dependency
archives are excluded.

The four adapters cover 13 abstract workloads: four INT64 transfer/swap/list
cases, rational transfer and swap, and seven rational composition, refusal,
revocation, atomicity, netting and reuse cases. They use DeFiFormal source
`2b60322cdc8c98f0e0c27cab3b2d6dcc824c3eda`, Lean `4.33.0-rc2` and mathlib
`51e6992efd06126df61a496bebf8f49482a4e129`. The original origin classifications remain separate: workflow and transfer
are `adapted_library` workloads (with separate source/correspondence records);
the rational swap is a `new_model` built using the native generic expression
interpreter. INT64 composes new benchmark ledger/AMM models from native checked
arithmetic. Replaying these abstract workloads does not establish deployed-contract
refinement or validate the assessment's measurements. Automatic attempts may fail while the assisted
canonical proof succeeds. Such a result is retained in the detailed records.

## Reproduce

Python 3.11 or later, the pinned Lean compiler and sibling `leanchecker`, and a
prepared pinned DeFiFormal `lean/` directory with its `.lake` dependencies are
required. The wrapper uses Python's standard library. It installs nothing and
fetches nothing. Dependency state is an explicit input. Outputs must be fresh,
empty and outside this source tree and the dependency tree.

From the repository root:

```sh
python3 benchmarks/competitive-landscape/reproduce.py verify-sources
python3 benchmarks/competitive-landscape/test_reproduce.py
python3 benchmarks/competitive-landscape/reproduce.py check \
  --lean-bin /path/to/lean-4.33.0-rc2/bin/lean \
  --dependency-root /path/to/pinned-defiformal/lean \
  --output /tmp/adapter-results
```

The default command checks all 13 cases. For a focused first replay, add
`--adapter transfer --case R1-TRANSFER --kind canonical`. Adapter names are
`int64`, `transfer`, `swap` and `workflow`. Available checks are `canonical`,
`witnesses` (rational only), `mutants`, `parser`, `cache` and `proof`.
`proof` freshly elaborates the complete assisted dependency chain, checks the
canonical theorem's disclosed axioms, then invokes `leanchecker` for every new
module. Accepted target axioms are `propext`, `Classical.choice` and `Quot.sound`.
The checker uses the same Lean kernel and trusts imported dependencies; it is
not an independent kernel implementation or a full dependency rebuild.

For a publicly reproducible dependency setup, obtain a separate source copy at
the pinned DeFiFormal revision. Its existing `lean-toolchain` and
`lake-manifest.json` pin Lean and mathlib. Provision dependencies using that
copy's Lake setup, then build `DefiKernel.Core`, `DefiKernel.Examples`,
`DefiKernel.Typed.Expr`, `DefiKernel.Arithmetic.Operations` and
`DefiKernel.Arithmetic.Rounding`. Point the command above at the resulting
`lean/` directory and the matching compiler. `dependency-sources.json` records
the seven native source files in the actual transitive import closure; the
wrapper verifies those bytes, mathlib's manifest revision and required native
compiled modules. It records the compiler and checker hashes. The compiled
mathlib/native cache remains trusted input: source checks alone do not prove
that an arbitrary cache was compiled from those bytes.

The upstream `setup.py` files assume a private assessment workspace. The wrapper
redirects their path, compiler and environment functions in memory. It executes
the preserved acceptance scripts; it does not edit imported files. Each check
runs in a separate process. Completed checks retain stdout/stderr; timeouts record
failure without partial output. The wrapper writes a summary and refuses Python
optimization that would disable upstream assertions. The source inventory
is checked before and after a complete run. Exit 0 means all selected nonempty
checks passed, 1 means a check failed, and 3 means reproduction was blocked.
An argparse usage error exits 2. `summary.json` reports the actual denominator.

## Exact historical artifact checks

The imported rational `native-lock.json` files bind exact Darwin arm64 compiler,
checker and `.olean` bytes. Other platforms and fresh source builds cannot
claim those historical artifact identities. Ordinary portable checks omit the
original `trust` check; `proof` supplies fresh target elaboration and kernel
replay with its explicit trusted-cache boundary.

If the original checksummed archives are available, extract them into a separate
writable runtime and pass `--historical-runtime /path/to/runtime`, with matching
`--lean-bin` and `--dependency-root` paths inside it. The default run then also
executes original `trust` checks. This optional mode may write INT64 benchmark
outputs inside that explicitly selected runtime. The archives are not distributed
here. Their hashes remain in the preserved dependency locks. The archive cache
predates the rational swap workload, so `Typed/Types.olean` and
`Typed/Expr.olean` must first be built from its pinned sources as the original
swap setup documents.

INT64 `mutants` elaborates retained counterexample lemmas; the rational mutant
checks modify real adapter transition sources in temporary copies and execute
counterexample controls. These are distinct kinds of evidence. Neither changes
the imported source or establishes a new kernel theorem.

## Attribution

Original benchmark adapter work is attributed to the IOG Technical Intelligence
assessment and its retained AI-assistance/effort records. Underlying DeFiFormal
and mathlib files retain their original provenance. No external license has been
inferred for the assessment repository; repository-owner license selection is
recorded separately. Import authorization does not convert measurement evidence
into proof or accept any wider library, release, or third-party onboarding gate.
