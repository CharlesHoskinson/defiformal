## Why

The accepted Atomic executor has two invocation streams and one publication boundary. General finite-participant execution and tree/active-extension laws need separate atomic simulations: ordinary interleaving peer refusal and projection do not preserve committed Atomic behavior.

This is provisional M6/Sprint14 author planning. Accepted S10/M3/M4/M5 and an exact API/runner refresh are required before the official nonauthor GPT-6/native Fable planning gate. No implementation is authorized by this draft.

## What Changes

- Lift the existing ordered clearing policy and first-abort semantics to the actual finite participant dispatcher, with exact binary correspondence.
- Wrap the actual tree dispatcher and prove same-transaction, same-policy, same-schedule speculative and committed observations equal through its real simulation.
- Prove a deliberately restricted active-extension theorem: added invocations succeed, avoid protected writes and all lane-cell effects, and pass lane-supply checks. Preserve old observations through a named projection while retaining foreign failures as observable failures outside the theorem.
- Keep one outer label, entry world, policy, settlement monitor and commit boundary throughout regrouping; prove receipt-derived monitor correspondence after each actual successful attempt.
- Add exact rollback, residual, global-position, first-supply, publication and boundary-reassociation counterexamples with independent financial expectations and real runtime mutations.

## Capabilities

### New Capabilities

- `finite-atomic-boundary`: Finite actual speculation with the accepted clearing and first-abort policy.
- `atomic-operational-transfer`: Exact binary/tree correspondence inside one fixed publication boundary.
- `atomic-active-extension`: Explicitly restricted preservation under successful settlement-neutral added participants.
- `atomic-transfer-evidence`: Independent fixtures, actual mutations/controls and frozen proof/review evidence.

### Modified Capabilities

None. Existing Atomic, M3/M4/M5 and corpus/evaluation contracts are dependencies and remain unchanged.

## Impact

Proposed new namespace `DefiKernel.AtomicNary`, with runtime `Policy`, `Execution`, `Observation`, `TreeExecution`, `ExtensionProjection`, `Examples`, `Tests`, `Audit`, and proof `Soundness`, `Settlement`, `BinaryCorrespondence`, `TreeSimulation`, `Extension`, `Fixtures`, `Verify`. These names require accepted-API refresh before freeze.

The first active-extension theorem intentionally protects every policy lane cell; added streams create no new settlement obligations. General interactions with new lanes, principal/policy changes, administrative identity renaming, nested savepoints, callbacks and moved transaction boundaries remain separate work. No existing source is modified by this draft.
