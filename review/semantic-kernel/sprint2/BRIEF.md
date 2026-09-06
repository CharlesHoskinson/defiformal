# Sprint 2 native review brief

Review trusted operation contracts and an automatic Lean environment axiom audit
against `docs/superpowers/specs/2026-09-06-operation-contracts-design.md`.
Implementation is GPT-6 through stock Codex agents. Grok and Fable's native CLIs
perform source review; no Foreman and no claim of independent reviewer builds.

## Threat model

An untrusted transition may change any proposed effects, supply, actor, write
footprint or guard. Trusted application code selects a contract and its operation
parameters. The environment fields are declared inputs. Determine whether a
successful wrapper execution establishes the selected contract and preserves
base checks, and whether a forged guard can bypass the trusted borrow rules.
There is no claim of caller authentication or safe arbitrary contract selection.
A reviewer should not require a protocol-kind kernel primitive or full capability
lifecycle, general identities, composition, solvency or deployed fidelity here.

For the audit gate, realistic failures are a developer adding a theorem without
updating a list, accidentally importing a custom axiom/sorry proof, or running
audit over empty/incomplete intended scope. The check must inspect elaborated
declarations, reject forbidden transitive axioms, and disclose imported-module
scope. Testing helpers may intentionally construct bad temporary fixtures; they
must not enter accepted production imports.

## Evidence and verdicts

A frozen candidate manifest will identify source bytes, commit, toolchain and
observed tests. Source review does not verify the parent's subprocess claims.
Give separate spec and implementation verdicts, concrete severity-ranked findings
with file/declaration references and plausible failure examples, then limits.
Rank by realistic likelihood. Distinguish current bugs from larger migration work.
One initial review and one targeted remediation review are budgeted. An invocation
failure is no verdict; preserve it and retry if necessary.
