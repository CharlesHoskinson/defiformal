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
  52/52 named runtime comparisons true in `interfaces-runtime.log`.
- `git diff --check`: no output. Source search: no forbidden proof constructs.
- Seven generic theorems: `checkAccess_ok_iff`, `checkAccess_declaredWrites`,
  `validateCatalog_export_not_private`, `snapshots_length`, `snapshot_of_selected`,
  `resolveSource_literal`, `resolveSource_not_prior`. These concern list snapshots
  and routing plus exact access checks and private export exclusion; they do not
  establish confidentiality.

The funded interference control executes the real typed kernel with its actually
provisioned live capability store and checks the bounded execution result by
comparing Alice's 7 USD and the vault's 23 USD. The sibling interface checker
refuses that same target with `writeAccess`; adding an exact writable import
permits it. Adapter tests must separately cover whole-world unchanged refusal,
sequence histories and stale-snapshot stability. `resolveInputs` trusts the
runner's successful-history invariant; it does not authenticate arbitrary
external history lists. No financial authority is added by value routing.

Source SHA-256:

- Interfaces.lean: `4f2a32854b298ca5399eb0aa38bb16e892312517ae4f3a0e49e4bfead369f5fe`
- InterfaceTests.lean: `710777f2112979bbb4cd70624939901a7f1f25756d5cc08027722ca942ae51b3`

Full integrated axiom audit, source mutation evidence and independent native
Grok/Fable review remain parent integration obligations; this report claims none
of those completed.

## Native review remediation

Read the native Fable interface and execution responses reviewing `ba3661f`
(`interfaces-fable.json`, `execution-fable.json`). Added globally unique exported
cells to block competing providers with different rights, and required selected
output domains to equal the registered operation domain. Catalog authorship is
still trusted: validation checks internal consistency, not entitlement to create
a resource provider. Export rights constrain the exporter itself, and a component may not import a cell it also exports. Environment observations
remain under the typed kernel's declared environment checks.

Added eight executed siblings for provider collision, unknown source, wrong port,
self-import, read-only versus writable exporter access, and cross-domain outputs.
The three new generic theorems establish the complete successful access-precheck
characterization, writable declared cells, and private/export separation.
The explicit private/import exclusion check remains redundant with exact matching
plus export exclusion; its presence is not a separately discriminating claim.

Dependency-aware file validation and the fresh runtime driver both exit 0 on the
updated hashes above, with 52/52 comparisons. Interfaces LSP diagnostics are clean.
Native targeted re-review of these fixes remains pending parent integration.

Read native Grok execution review `execution-grok.json`, finding 1. The catalog
now rejects overlap between a component's own exported and imported cells,
including identical self-imports. This closes the remaining own writable export
plus own read-only import case after provider uniqueness. The existing self-import
comparison now expects rejection; an additional explicit read-only/writable sibling
also refuses. Dependency-aware file compilation and fresh execution both exit 0:
52/52 comparisons on the updated hashes above; Interfaces LSP remains clean.
