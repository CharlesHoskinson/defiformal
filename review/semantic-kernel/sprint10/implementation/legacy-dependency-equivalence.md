# Legacy regression dependency equivalence

PASS: thirteen suites retain actual execution candidate `c880acf62944746ff9a376afc0c0050702f037f7`. Their relevant
source closures and tool binaries are byte-identical at revised candidate `b165bc586080d668f689fbc18dfa09eb8739d688`.
This is a source-equivalence analysis, not thirteen new executions.

Of 163 baseline inputs, 159 are unchanged. The changed
files are lean/DefiKernel.lean, lean/DefiKernel/Metatheory/Examples.lean, lean/DefiKernel/Metatheory/SequentialGroups.lean, lean/DefiKernel/Metatheory/Tests.lean. None belongs to any retained suite's execution
closure. The changed Metatheory runtime fixtures retain their accepted Sprint 9 production
mutation evidence and receive fresh integration execution, recorded separately.

The JSON binds both Git objects and SHA-256 values for every baseline input and
per-suite closure. Mutation closures come from actual manifests; synthetic
runner, axiom, typing and corpus closures come from the recorded inputs and
inspected driver file reads. This author analysis is subject to native review.
