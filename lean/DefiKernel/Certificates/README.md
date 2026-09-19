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
