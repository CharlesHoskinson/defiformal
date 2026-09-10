# P31 Compact addition boundary diagnostic

The exact captured Moriarty arithmetic.compact (source SHA256 b2969d0bc346fa93d88546578c9f9d29f1b74d7bc3f88f2e04709fa0932d9415) compiled with Compact0.31.1, language0.23.0, runtime0.16.0 and --skip-zk. The execve trace identifies the actual compactc.bin. This source exports pure circuits; the four generated files contain JavaScript, declarations, a source map and compiler metadata. No ZKIR, keys or proofs were generated.

The generated checkedAdd contains a guard rejecting sums above 2^128-1. Five direct calls to its exported pureCircuits.checkedAdd passed: 0+0, max+0 and (max-1)+1 returned exact results; max+1 and max+max threw CompactError at the narrowing cast. No arithmetic source or generated code was edited. This is bounded runtime evidence for the previously unobserved addition cast behavior at this compiler/runtime pin.

compile-receipt.json, execve.log, runtime-receipt.json, tool-inputs.json and the two manifests bind actual source, compiler, package, generated-code, probe and output bytes. Runtime packages were installed in a separate cache with lifecycle scripts disabled. The node_modules symlink is a local execution convenience and is excluded from delivery; runtime-package-lock.json and tool-inputs.json preserve dependency identities.

These five cases do not establish universal arithmetic correspondence, ZKIR constraints, ledger settlement or a DeFiKernel adapter. Independent review of this supplemental diagnostic is pending. The earlier source-readiness audit remains a review of its original source-only scope.
