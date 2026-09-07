# Legacy regression dependency equivalence

PASS: thirteen suites retain actual execution candidate `c880acf62944746ff9a376afc0c0050702f037f7`. Their relevant
source closures and tool binaries are byte-identical at revised candidate `eec499d613688137a341f3556cd80ca461dd2ee9`.
This is a source-equivalence analysis, not thirteen new executions.

Of 163 baseline inputs, 160 are unchanged. The changed
files are lean/DefiKernel/Metatheory/Examples.lean, lean/DefiKernel/Metatheory/SequentialGroups.lean, lean/DefiKernel/Metatheory/Tests.lean. None belongs to any retained suite's execution
closure. The changed Metatheory runtime fixtures receive fresh integration and
production mutation execution, recorded separately.

The JSON binds both Git objects and SHA-256 values for every baseline input and
per-suite closure. Mutation closures come from actual manifests; synthetic
runner, axiom, typing and corpus closures come from the recorded inputs and
inspected driver file reads. This author analysis is subject to native review.
