## Why

Current capability lemmas establish individual issue/use/revoke behavior, while sequential traces already record actual administration. The remaining composition work needs initialized provenance across those traces and explicit state/store support for component observations. Denying writes alone cannot establish confidentiality.

## What Changes

- Prove that every capability entry in an actual sequential prefix has its original grant scope from an explicitly trusted initial entry or a causally preceding authorized issue, with exact fresh-ID counts and permanent tombstones.
- Connect accepted invocation, debit and supply authority to the current pre-step store and that entry's provenance; preserve exact rejection behavior and halted prefixes.
- Define explicit observation support over finite ledger cells, selected capability IDs and optional allocation length, then prove conditional component frames from actual ledger/admin effects.
- Prove direct peer-private read/write exclusion for a validated catalog while recording published output snapshots as disclosure. Provide negative companions for untrusted roots, unsupported observations, read-only information flow and store-sensitive frames.
- Add read-only queries over actual sequential execution, complete independent financial observations, scoped mutation sensitivity, source-bound audits and separate planning/implementation acceptance gates.

## Capabilities

### New Capabilities

- `initialized-capability-provenance`: Causal origins, current-store authorization and tombstone/nonreuse induction over actual sequential prefixes.
- `supported-component-isolation`: Explicit ledger/store/allocation support and conditional frames, with direct-read and disclosure boundaries.
- `capability-provenance-evidence`: Independent observations, finite mutations, defensive controls, immutable source evidence and review gates.

### Modified Capabilities

None. Existing authority, sequential, parallel, interleaving and atomic semantics remain unchanged.

## Impact

Author draft only. Intended additions belong in `lean/DefiKernel/CapabilityProvenance/` plus a dedicated audit/root import and new runner/spec files after approval. No implementation is authorized by this draft. Accepted dependency is Sprint9 source `eec499d613688137a341f3556cd80ca461dd2ee9`, delivered and archived at `9908d9b56be2d5ed2b58a16fa8d28b23f33733ff`; exact current source hashes are captured separately. Sprint10 and corpus planning candidates remain pending their own gates and are not dependencies on nonexistent implementation. This package requires its own frozen nonauthor GPT-6 plus native Fable 5.1 medium planning gate. Concurrent allocation, delegation, atomic administration and general confidentiality remain later work.
