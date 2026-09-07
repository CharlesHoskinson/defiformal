## Why

Sprint 4 checks one registered typed transition at a time, but cannot yet state
or execute a component workflow with checked interfaces and preservation across
its successful steps. Sprint 5 supplies that first operational composition layer
while preserving the existing kernel and historical negative results.

## What Changes

- Define stable typed value/resource ports, component ownership, explicit shared
  access, and proof-level initialization/assumption/guarantee contracts.
- Add explicit ledger-plus-capability worlds, trusted per-step adapter inputs,
  observable step receipts, and finite execution traces.
- Execute ordered invocation and administrative steps; stop at the first
  refusal, retaining the successful prefix and its state/capability updates.
- Bind downstream arguments to literal values or already-produced typed outputs.
- Prove step correspondence, initialization-based reachability, cumulative
  accounting, nonnegativity, authority, write locality, and a supported-predicate
  frame theorem for successful prefixes, including prefixes ending in refusal.
- Add composed reference workflows, discriminating source mutations, imported
  axiom coverage, and native Grok/Fable review with exact source/evidence binding.

## Capabilities

### New Capabilities

- `typed-component-interfaces`: Stable port identities, typed value bindings,
  private/shared resource boundaries, and explicit semantic contracts.
- `sequential-workflow-execution`: Initialization, step receipts, checked output
  routing, current-state/current-capability execution, and first-refusal traces.
- `sequential-preservation`: Correspondence and induction over successful
  prefixes, including accounting, authority, locality, and supported frames.
- `composition-regression-evidence`: Concrete workflow observations, independent
  negative controls, source mutations, proof audits, and delivery evidence.

### Modified Capabilities

None. Sprint 4 execution semantics remain intact. These are additive capabilities;
existing historical OpenSpec changes are not reactivated or archived here.

## Impact

New Lean modules are planned under `lean/DefiKernel/Composition/`, with one new
import in `lean/DefiKernel.lean`. They consume `DefiKernel.Typed` and reuse the
existing imported axiom auditor. A scoped workflow mutation runner and evidence
directory are added. `roadmap.md` is the consolidated remaining agenda.

No new dependency is required. Implementation remains GPT-6 through the stock
Codex harness, with independent native Grok/Fable review and no Foreman.
This change plans reference semantics, not deployed-contract fidelity.

## Non-goals

Parallel/shared-state interleaving, atomic rollback, asynchronous messaging,
claim lifecycle, arbitrary output expressions, automatic assumption discharge,
capability delegation/allowances, cryptographic authentication, serialized
certificates, and general operational associativity remain separate work.
List-append sequencing laws in this sprint do not establish those broader claims.
