# Certificate codec proofs

`DefiKernel.Certificates.Lexical` provides the independently reviewed encoding-depth,
lexical-scanner, and encode/decode roundtrip proofs for the existing supported IR.
Import that module directly, or build it with:

```sh
lake build DefiKernel.Certificates.Lexical
```

These source files are the exact frozen Grok R3 candidate reviewed by Astra.
The source bindings and integration record are in
`review/semantic-kernel/program-execution-20260919/R3-SOURCE-INTEGRATION.json`.

`Check` and the other runtime definitions in this dependency closure remain an
**unqualified candidate**. The codec proofs establish their stated relationships
over these definitions. They do not establish every required semantic checker
gate. In particular, a `checkBytes`/`checkIR` equality is not whole-checker acceptance.

This contribution is not exported by the default `DefiKernel` entry point and
provides no qualified certificate delivery route. P19/P20 and the remaining
program gates remain open. Ongoing checker repairs are reviewed separately.

`LibraryInstantiation` adds reviewed Arithmetic extraction and executable checking
helpers with their stated Lean theorems. `TrustedHost` supplies static identity
constants. These two modules have separate scoped R5 acceptance, recorded in
`GROK-R5-SCOPED-ACCEPTANCE.json` alongside the R3 integration record. They do not
establish complete certificate-library discharge or validate external host records.
The R5 helper acceptance did not accept its delivery route or CLI. The scoped
compatibility repair below has a separate review.

## Scoped compatibility repair

`Delivered.checkRun` and the direct `RunFixtures` checker now refuse an
overlapping run when its required compatibility judgment is false. The report
retains the actual sequential world and receipt. A disjoint USD/share transfer
control remains accepted. Required invariant discharge failures identify the
invariant obligation separately from library discharge failures.

`KernelCorrespondence` includes accepted-implies-no-false-required-judgment
theorems for typed, step and run reports. Astra independently reviewed this
exact contribution; run its focused regression from `lean/` with:

```sh
lake env lean --run DefiKernel/Certificates/CompatibilityStatusRegression.lean
```

This is scoped acceptance of the compatibility repair and its source
dependencies. It does not qualify the whole certificate checker, validate the
external host inventory, or close the remaining P19/P20 gates. The default
`DefiKernel` import remains unchanged. See
`review/semantic-kernel/program-execution-20260919/astra-focused-compatibility-review/REVIEW-DIAGNOSTIC.md`.

## P19 host inventory validation

From the repository root, build the pinned host module and validate the supplied
host inventory:

```sh
(cd lean && lake build DefiKernel.Certificates.TrustedHost)
python3 scripts/verify_certificate_host.py
```

The validator checks source dependency bytes, Arithmetic compiler records, and
identity constants evaluated from the reviewed `TrustedHost.olean`. It rejects
missing or substituted records, source drift, changed compiled identity, and
malformed exporter output. It invokes the absolute, digest-checked Lean and Lake
binaries, so a local `lean` executable cannot impersonate the exporter.

This scoped implementation requires the recorded Linux binaries for
Lean 4.33.0-rc2 under `~/.elan/toolchains/`. The installed toolchain and transitive
compiled dependencies remain trusted; this is not a general build attestation.
Astra accepted the exact three-file repair in
`review/semantic-kernel/program-execution-20260919/astra-p19-host-review/REVIEW-ARTIFACT.md`.
Whole P19/P20 checker qualification remains open.
