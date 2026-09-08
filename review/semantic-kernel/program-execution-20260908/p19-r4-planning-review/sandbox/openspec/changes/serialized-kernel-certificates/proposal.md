## Why

Package 8 and roadmap §5 still require a serialized module/transition format and a checker that recomputes typing, footprint, authority, accounting and composition judgments. Delivered Typed and sequential Composition already expose those executable entrypoints, but no frozen certificate package exists; keyword tagging and arbitrary `ComponentContract` propositions are not certificates.

## What Changes

- Add a new `DefiKernel.Certificates` namespace with a JSON Module/Transition envelope over delivered Typed templates/registries/requests/state/capabilities/environments and sequential Composition catalogs/steps.
- Implement a recomputing checker that calls actual `Typed.execute`, `Composition.executeStep`/`run`, `validateCatalog`, `checkAccess`, `Args.check`, `issueCapability` and `revokeCapability`; claimed judgment tags are inputs, never evidence.
- Establish encode/decode correspondence for accepted and refused observations, with exact rational, identifier, enumeration, duplicate, order, canonicalization and error-precedence contracts.
- Classify assumptions, Lean proof obligations and trust boundaries separately from executable judgments; reject unsupported Claims/Tree/Nary/parallel/atomic/Quint/crypto/Prop-as-check forms instead of quietly accepting them.
- Add independent positive/negative fixtures, planned source mutations, declared audit-root coverage and a dedicated mutation-runner adaptation. Existing arithmetic and Atomic cases remain prior work, not new certificate acceptance.

This is an official planning package only. Implementation waits for independent GPT-6 gate acceptance. No historical theorem statement, old plan byte, corpus payload or `gate33_cert_check.py` PASS is reused.

## Capabilities

### New Capabilities

- `serialized-module-format`: Finite JSON Module/Transition schema, exact rationals, identifiers, enumerations, catalogs, sequential steps, source maps and canonicalization/error-precedence.
- `recomputing-certificate-checker`: Recomputed typing/footprint/authority/accounting/execution/composition judgments and exact refusal constructors; rejection of tags, theorem names and unsupported forms.
- `representation-correspondence`: Faithful encode/decode and checker-to-Lean entrypoint correspondence for accepted and refused behavior.
- `runtime-proof-boundary`: Distinguishes executable judgments, registry/context/observation/environment trust, declared assumptions and Lean proof obligations with actual object identity.
- `certificate-regression-evidence`: Independent fixtures, planned mutants, malformed/empty/missing/unsupported/stale/changed-judgment controls, declared audit roots and runner protocol mapping.

### Modified Capabilities

None. Historical Typed, Composition, Arithmetic and Atomic requirement text is unchanged. This increment does not rewrite those specs to claim certificate coverage.

## Impact

Future modules under `lean/DefiKernel/Certificates/`, parent-owned root import after planning acceptance, `scripts/run_certificate_mutations.py` plus harness adapted from the inherited Interface mutation protocol with Typed/Composition proof-tail projection, and evidence under `review/semantic-kernel/certificates/planning/grok-gpt6-official-r4/`. Historical r1/r2/r3 packages remain unchanged. Source D `a12b7cac05a818cc8d35c2ca440b7170a2807e92`. Worker native Grok 4.6; independent checker GPT-6 / gpt-6-astra; no Foreman. Official r1 archive `a845bc2b5d6a055252152c47c700adfd3dd89aeb3a7c25c0f1e792d7ccbba3ed` and root launch failure remain historical with no authorship credit.

Roadmap §5 lines 230–235 and agenda package 8 are the bounded coverage of this increment; library instantiation, Quint, Claims/Tree/Nary/parallel/atomic certificates, fidelity, async, observation truth and unimported-module audits remain named later obligations. Do not check those global boxes in this planning revision.
