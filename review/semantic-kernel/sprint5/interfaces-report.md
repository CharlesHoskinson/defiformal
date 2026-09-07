# Sprint 5 interface implementation

Implemented additive `Composition/Interfaces.lean` and focused `InterfaceTests.lean`
for tasks 2.1–2.4. No historical Lean sources, root imports, commits or task boxes
were changed by this worker. Baseline permission came from the parent after its
successful build/drivers at `86b77b7`.

The public API follows the parent coordination message: typed component/port
wrappers; catalog ownership and exact shared resources; `validateCatalog`,
`lookupOperation`, `checkAccess`, `resolveInputs`, and `snapshots`. Resource
imports identify an exported qualified port directly; no alias mechanism exists.
Component-local input, output and export IDs share one uniqueness namespace.
Private cells cannot also be shared exports. Read-only imports may reduce export
rights. Every concrete delta target is checked even when absent from declared
writes. Required reads include both branches, guards, effects and supplies;
declared reads/writes are checked separately. Output reads are checked during
catalog validation.

Verification:

- LSP diagnostics on Interfaces: success, no errors or warnings.
- Dependency-aware `lake lean DefiKernel/Composition/InterfaceTests.lean`: exit 0.
- Fresh `lake env lean DefiKernel/Composition/InterfaceTests.lean`: exit 0;
  44/44 named runtime comparisons true in `interfaces-runtime.log`.
- `git diff --check`: no output. Source search: no forbidden proof constructs.
- Four generic theorems: `snapshots_length`, `snapshot_of_selected`,
  `resolveSource_literal`, `resolveSource_not_prior`. These concern list snapshots
  and routing; they do not establish general catalog soundness or confidentiality.

The funded interference control executes the real typed kernel with its actually
provisioned live capability store and proves the bounded execution result by
comparing Alice's 7 USD and the vault's 23 USD. The sibling interface checker
refuses that same target with `writeAccess`; adding an exact writable import
permits it. Adapter tests must separately cover whole-world unchanged refusal,
sequence histories and stale-snapshot stability. `resolveInputs` trusts the
runner's successful-history invariant; it does not authenticate arbitrary
external history lists. No financial authority is added by value routing.

Source SHA-256:

- Interfaces.lean: `0f85b76f3066423ead95a3973a4721b7fdf7a5a2552d34d59950a0d26a21c5de`
- InterfaceTests.lean: `38d512c55cab3278b5eaaf06fa6b5545937166947386be555813a6b67cc1f17a`

Full integrated axiom audit, source mutation evidence and independent native
Grok/Fable review remain parent integration obligations; this report claims none
of those completed.
