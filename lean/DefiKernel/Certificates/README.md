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
The rejected R5 delivery route and CLI are not included in this integration.
