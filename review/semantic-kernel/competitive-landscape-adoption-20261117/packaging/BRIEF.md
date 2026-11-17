# Compiled evidence package implementation brief

Implement the engineering part of III.1 and III.2 from the accepted change. An agent replay does not satisfy the actual third-party reproduction criterion. Keep that criterion open until a real outside record exists.

First experiment: produce a relocatable package for the current macOS arm64 environment that replays `DefiKernel.Composition.VaultQuoteWorkflow`, `DefiKernel.Vault.ConversionDomain`, `DefiKernel.Vault.ComputedDeposit`, and `DefiKernel.ConcentratedLiquidity.Token0Proofs` using the pinned `leanchecker`. Include `ShareQuote` explicitly. Run it from an unrelated directory with ambient Lean/Lake search paths cleared. Do not depend on the repository, author cache, or a preinstalled Lean toolchain.

Include compiled targets and their actual import closure, the checker and required runtime, original licenses/notices, source revision and hashes, checker version and hashes, platform requirements, checksums, and an explicit trusted-import inventory. Bind the corresponding accepted source, review decisions and runtime/control evidence. Preserve the distinction between target declaration replay, trusted imports, axiom inspection, finite execution, historical EVM observations and the open source-refinement obligation. No uncorroborated adoption claim.

Use a focused reusable packaging script, not a new orchestration framework. Read dependencies from Lean or compiled module metadata; do not approximate an import closure with regex alone. Review bundled runtime library dependencies. Fail on an empty target set, missing required artifacts, or checksum mismatch. Exercise at least missing-target and altered-byte failures. Do not claim a cached build reruns runtime controls.

The installed `LeanChecker.lean` documents default replay of target declarations using their imported environment; it is the same Lean kernel, not an external verifier. Unknown flags are ignored: `--help` is not a supported help mode. The root exploratory invocation was cancelled and provides no evidence.

Store the generated archive outside Git; commit the builder, manifest, instructions and verification record. After exact-candidate independent Astra review, root will publish the artifact under a new source-bound tag/release. Do not change the existing v0.1.0 tag or attach later compiled code to it as if it matched that release. Verify package extraction and replay before publication. Record the actual third-party check as still absent.
