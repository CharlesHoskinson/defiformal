# Legacy regression dependency equivalence

PASS: all eleven suites retain their actual execution candidate `88aa4906102f2e304d1039d2e70942503ec9b341`. Their relevant source closures and tool binaries are byte-identical at revised candidate `a52fb748272fdc08f07d4ad8d2e2a06805b92dd6`; no suite rerun is required.

The 147-input baseline contains 143 unchanged inputs and four changed Atomic-only inputs: Audit, Tests, Soundness comments and the Atomic runner-control harness. None belongs to an old suite's actual dependency closure. This does not claim all 147 inputs are unchanged or relabel any old execution. The JSON records both candidate Git objects and SHA-256 values for every baseline input and every per-suite closure, exact original commands and evidence hashes. Mutation closures use actual manifests; synthetic runner, axiom, typing and corpus closures use their recorded inputs and inspected driver file reads.

This equivalence analysis was prepared by the original regression harness author. It is not an independent audit of those regressions. Reproduce with `python3 review/semantic-kernel/sprint8/implementation/legacy-dependency-equivalence.py`.
