## Context

See `proposal.md` for motivation. Independent GPT-6 readiness recovery (`remaining-financial-async-readiness-gpt6-review.md`, SHA-256 `9173e34ce186104f9593831d0f8061682656ea2de4eb888dcc424fc22014d9c2`) is a dependency audit, not a scientific design or accepted plan. No dedicated certificate package existed in the recovered inventory.

Source D and delivered HEAD are `a12b7cac05a818cc8d35c2ca440b7170a2807e92`. Reusable executable APIs, read from source without a Lean build or private cache:

- `Typed.Args.check`, `Expr.eval`, `Template.evaluate`, `execute`, `applyEvaluated`, `issueCapability`, `revokeCapability`, `hasAuthority`, `authorizesId`
- `Composition.validateCatalog`, `checkAccess`, `resolveInputs`, `executeStep`, `extractReceipt`, `startCursor`, `advance`, `run`
- `ComponentContract` / `ContractObligations` are explicitly not executable certificates (`Composition/Contracts.lean`)
- `AxiomAudit.#audit_axioms` inspects imported modules under a prefix; it is not a serialized-certificate verifier and does not discover unimported files
- `gate33_cert_check.py` is a keyword-tag seed; its PASS is not inherited
- Accepted integer arithmetic `ddf1ac0e` / archive `6d73e6dc` and Atomic settlement are prior work, not this increment's acceptance

Original 53 readiness bindings remain historical evidence. This increment may expand the used-source closure with actual Certificates APIs and `Lean.Data.Json`; it does not silently drop those 53 rows.

Worker: native Grok 4.6. Independent checker: GPT-6 / gpt-6-astra. No Foreman. Original root launch failure is preserved at `review/semantic-kernel/program-loop-20260908/native-worker/certificates-official-planning-r1-attempt1/` with empty jsonl and no authorship credit.

Official r1 candidate archive SHA-256 `a845bc2b5d6a055252152c47c700adfd3dd89aeb3a7c25c0f1e792d7ccbba3ed` was independently reviewed NEEDS REVISION (`certificates-official-r1-gpt6-review.md` SHA-256 `6f46630cef8f0bef46577bb1c720726e81e33782a47205df63174ed0a4135fc9`). This revision repairs CERT-P1–P7 only. r1 bytes and author synthetic controls remain historical. Review package for this freeze is `review/semantic-kernel/certificates/planning/grok-gpt6-official-r2/`.

## Goals / Non-Goals

**Goals:**

- Frozen JSON Module/Transition envelope over delivered Typed + sequential Composition
- Recomputing checker whose observations equal actual current entrypoints on success and refusal
- Exact rational, identifier, enumeration, duplicate, order, canonicalization and error-precedence contracts
- Explicit classification of trust, assumptions, Lean proof obligations and unsupported future forms
- Independent fixtures, planned mutants (effect, capability, catalog, checker), declared audit roots

**Non-Goals:**

- Implementation in this revision
- Claims lifecycle operators, Tree regrouping, Nary/parallel/interleaving/atomic certificate families
- Quint correspondence, deployed fidelity, cryptographic truth, observation authenticity, replay protection
- Closing roadmap §5 boxes, agenda package 8 as a whole, or all certificate work by omitting hard forms
- Relabelling arithmetic/Atomic theorems as new certificate results
- Corpus, assessment, holdout or blind-payload reads

## Decisions

### D1. Lean checker is the authority; JSON is the external encoding

**Choice:** Implement `DefiKernel.Certificates` so `checkCertificate` decodes then calls actual `Typed.execute` / `Composition.executeStep` / `Composition.run` / `validateCatalog` / `checkAccess` / `Args.check` / `issueCapability` / `revokeCapability`. Python may lint JSON and drive mutations; it SHALL NOT reimplement those judgments.

**Rejected:** A Python clone of `execute` (copy-of-want footgun). S-expression-only IR (source plan requires an external serialized module). Accepting claimed judgment arrays.

Proposed templates remain unimplemented and unelaborated until a recorded compiler check exists.

### D2. Proposed namespace and files

Unimplemented layout:

| Module | Role | Runtime/proof |
| --- | --- | --- |
| `DefiKernel.Certificates.Schema` | Lean IR of the envelope, decode failures, unsupported forms | runtime |
| `DefiKernel.Certificates.Decode` | JSON → IR or `DecodeFailure` | runtime |
| `DefiKernel.Certificates.Encode` | IR → canonical JSON | runtime |
| `DefiKernel.Certificates.Check` | `checkCertificate` | runtime |
| `DefiKernel.Certificates.Observation` | `Report`, Boolean equality on full reports | runtime |
| `DefiKernel.Certificates.Examples` | Independent fixture constructors; no checker-generated oracles | runtime |
| `DefiKernel.Certificates.Tests` | Runtime comparisons | runtime |
| `DefiKernel.Certificates.Audit` | Named nonempty check IDs | runtime |
| `DefiKernel.Certificates.Correspondence` | encode/decode and entrypoint equations | proof |
| `DefiKernel.Certificates.Soundness` | report constructors match execute/executeStep | proof |
| `DefiKernel.Certificates.Verify` | imported axiom audit wrapper | proof |

Parent-owned `lean/DefiKernel.lean` import is an integration change after planning acceptance. `-- BEGIN PROOFS` remains the runtime/proof strip marker.

JSON codec uses proposed `import Lean.Data.Json` from the Lean toolchain package (not currently imported in DefiKernel). That import expands the used-source closure; it is not claimed elaborated.

### D3. Finite fixture universe and correspondence targets

Increment modules declare enumerations. Funded fixtures reuse the *names* of `Typed.Examples` `Party`/`Asset`/`Domain` and the transfer/deposit/withdraw templates as development correspondence targets. Those examples are not new financial-model acceptance and not untouched holdouts.

Independent transfer-3 arithmetic, not runner output:

- initial alice USD 10, bob USD 0, vault USD 20, alice share 4
- debit 3 / credit 3 / zero supply
- expected alice USD 7, bob USD 3, vault USD 20, share 4, store unchanged

`Composition.Examples.expectedStore` is already an independent table; certificate fixtures SHALL copy literal entries, not call `issueGrants`.

### D4. Full envelope; hard forms reject or stay named outstanding

The source-plan Module keys are all present. Treatment:

| Field | This increment |
| --- | --- |
| types, state, transitions, interfaces | executable, required |
| observations | executable lookup plus observation-truth assumption |
| assumptions | classified, not discharged |
| invariants | serialized only as named proof obligations; never executable pass |
| libraries | outstanding unless actual theorem identity *and* recorded compiler check |
| source_map | pin/development correspondence; not fidelity |
| obligations_created / obligations_discharged nonempty | **reject** unsupported Claims form |
| tree/nary/parallel/interleave/atomic step ctors | **reject** unsupported composition form |
| Quint modules | **reject** |
| cryptographic `valid: true` | **reject** as fidelity/crypto claim |
| empty arrays for later families | allowed; certificate completeness does not treat emptiness as those families passing |

Rejecting a hard form is not closing that work. Remainder obligations are listed in `remainder-obligations.json`.

### D5. Judgment families and completeness

Required executable families for a complete increment certificate: TypeCorrect, FootprintCorrect, AuthorityCorrect, AccountingCorrect, CompositionCompatible (sequential only), plus AssumptionsDeclared classification.

LibraryTheoremsInstantiated and SourceRefinementObligations are recorded. They do not become accepted by existing Arithmetic/Atomic/Typed lemmas unless this increment records a compiler check of an instantiation that the certificate actually uses. Default: outstanding, certificate may still be `complete_for_increment` when those families are explicitly scoped out of the required set and listed as later obligations.

`complete_for_increment` requires: decode ok, no unsupported forms, all required executable families recomputed, observations match, required assumption classes present, source pin equals D, declared audit roots present. It does not mean package 8 is done.

### D6. Exact rational contract

`RatEnc := { num : Int, den : Nat }` with `0 < den` and `Int.gcd num.natAbs den = 1`. JSON object keys `num`,`den`. Integers use `den = 1`. Sign on `num` only.

Decode refusals: missing keys, extra keys, non-integers, `den = 0`, negative `den`, unreduced pairs, JSON numbers, strings, arrays, `null`.

Canonicalization of a valid rational is unique. Checker and tests compare decoded `ℚ`, not raw UTF-8.

### D7. Identifier, enumeration, duplicate and order contracts

- Party/asset/domain: strings from `module.types`; unknown → `unknownIdentifier`
- Nat ids: JSON integers `≥ 0`; capability ids are store indices
- `validateCatalog` duplicate rules unchanged
- Delta/supply lists: bag semantics, repetition adds
- `hasAuthority`: `List.any`; duplicates do not add rights
- History/steps/events: order-significant
- Canonical object key order is the array in `schema.json` `canonical_key_order`

### D8. Error precedence

Decode, first match:

1. empty document
2. bytes are not a JSON object
3. schema_version missing or ≠ 1
4. missing required envelope field
5. JSON type error (including float amounts)
6. unknown identifier / enum
7. uniqueness violation detected at decode (before catalog)
8. noncanonical or illegal rational
9. unknown executable field
10. unsupported form

Then sequential `executeStep`/`run`: `configuration` if catalog invalid (including at `startCursor` with `step = none`).

Then `execute` order as commented in `Typed/Transition.lean` (unknownOperation … writeFootprint).

`prepareInvocation`: lookup unknownOperation, resolveInputs (inputCount/inputUnit/unavailableOutput), registry unknownOperation, checkAccess (resolution/readAccess/writeAccess).

Issue/revoke: `AuthorityFailure` constructors unauthorizedAdmin, operationDomain, resourceDomain, unknownCapability.

A later failure SHALL NOT be reported when an earlier one already applies. Tests F29/F30 isolate precedence with dual defects.

### D9. Observation report

`Report` fields, all required:

- `status`: `accepted` | `refused` | `malformed` | `unsupported` | `incomplete`
- `decode` or kernel `failure` with exact constructor path, e.g. `kernel.insufficientFunds`, `interface.unavailableOutput`, `decode.emptyDocument`
- `judgments`: per-family `{family, recomputed, claimed, match}`
- `world` on accepted paths: every enumerated cell balance as RatEnc plus full capability list
- `receipt` on invoke success: guard, deltas, supplies, required/declared reads, writes
- `outputs`, `events`, `nextIndex`, `failure` for sequential runs
- `assumptions`, `outstanding`, `source_pin`, `audit_roots`
- `unsupported` reason when applicable

`reportEq` is true iff every field is equal. Tests compare checker report, independent fixture `expected`, and a separately constructed Lean entrypoint observation. No candidate-generated oracle.

### D10. Mutation runner adaptation

New driver `scripts/run_certificate_mutations.py` and harness `scripts/test_certificate_mutation_runner.py`, adapted from `scripts/run_interface_mutations.py` at D.

Inherited SPEC keys remain exactly `{schema_version, modules, mutations, positive_checks}` with `schema_version: 1`. Mutation object keys remain `{name, module, needle, replacement, required_false}`.

Production: one SPEC per mutant; `positive_checks` is that mutant's protected check only. Forbidden: one SPEC whose `positive_checks` unions checks that other mutants must falsify.

Timeouts: child 600s, harness 1500s. Evidence directory outside the repo. Timeout/empty/malformed/compiler error = blocked (exit 3). Outer invocation record required because the inherited runner writes child logs only after `subprocess.run` returns.

Grouping is seven future / nine existing, not M01–M12 future. Future: M01, M02, M07, M09, M10, M11, M16 on Certificates.Check/Decode/Observation. Existing: M03, M04, M05, M06, M08, M12, M13, M14, M15 on Typed.Transition/Authority/Expr and Composition.Interfaces. Projection is `mutation-projection.json`: strip `-- BEGIN PROOFS` on Typed/Composition/Certificates prefixes in the local closure. Interface-only stripping is insufficient. Do not implement those kernel mutations during planning.

### D11. Audit roots and import coverage

Declared roots after implementation:

- `DefiKernel.Certificates.{Schema,Decode,Encode,Check,Observation,Examples,Tests,Audit,Correspondence,Soundness,Verify}`
- used delivered: `Typed.{Types,Expr,Authority,Transition}`, `Composition.{Interfaces,Execution,Contracts,Sequence}`
- pins: `lean/lean-toolchain`, `lean/lakefile.toml`, `lean/lake-manifest.json`
- proposed: `Lean.Data.Json`

Actual audit commands (module-prefix filters, not transitive imports):

- `#audit_axioms DefiKernel.Certificates`
- `#audit_axioms DefiKernel.Typed`
- `#audit_axioms DefiKernel.Composition`

Empty theorem scope blocked. Unimported Arithmetic/Atomic/Nary/Claims/Tree/Metatheory modules are not in this universe. Certificates.Examples copies independent literals and does not import `Composition.Examples`; therefore `Composition.Preservation` is not in the runtime closure. If that import is added later, Preservation becomes a listed local dependency.

Untrusted envelope `source_pin`/`audit_roots` strings are distinct from delivered dependency records, checker-candidate hashes, and compiler/audit records. Stale/missing/substituted records match by path+sha256.

Original 53-file readiness list is preserved and is not rewritten.

### D13. Constructible grammar and raw entrypoints (CERT-P1)

`grammar.json` serializes the full delivered first-order Typed Expr/Template language plus sequential Composition. Unsupported constructors are explicit. `decodeBytes` / `checkBytes` / `checkIR` are distinct. No ambient registry/env/config. Lexical scientific/float scan happens before JSON parse. Duplicate JSON keys refuse. Catalog component-id duplicates decode then fail `validateCatalog` (F08), distinct from registry uniqueness decode failures. Resource limits are blocked evidence.

### D14. Result algebra (CERT-P2)

`result-algebra.json` is authoritative. Codec and audit are not `Report`. Execution `Report` always has the 14 fields. Judgment outcomes include not_reached/not_applicable. Six assumption classes, including environment-authenticity. A correct refusal is complete_refused. Library/source-refinement are informational outstanding by default.

### D15. Literal baselines (CERT-P3)

`baseline.json` materializes 32 cells, 12 store entries, admin vault boundary, fresh id 12, and frame cells collateral/debt/pool/vault/share. Fixtures F01–F54 are independent literals from `materialize.py`, which does not call Lean or the checker. F47 is the forbidden-read companion. F48/F49 are producer→prior-output and prefix→refusal→inert. F50/F51 are admin issue/revoke.

### D16. Correspondence statements (CERT-P6)

`correspondence-theorems.json` states quantified encode/decode and accepted/refused entrypoint theorems. Finite fixture equality is bounded evidence and does not discharge universal RC01.

### D17. Real planning controls (CERT-P7)

r2 `package.py` isolates copies and invokes the actual `--check` CLI. r1 synthetic `if not []` controls remain historical under r1 and are not relabelled as CLI executions.

### D12. Approaches considered

1. **Recommended (this design):** Lean checker over actual entrypoints + JSON envelope + Python lint/mutations.
2. Python semantic clone of `execute`: faster to draft, fails the copy-of-want trap and correspondence.
3. Theorem-name registry that greps Lean: keyword certification again.

## Risks / Trade-offs

- [JSON codec unelaborated] → Keep `Lean.Data.Json` proposed; do not claim compiler success; tests may construct IR from Lean literals while JSON fixtures remain independent bytes.
- [Reimplementing execute in Certificates.Check] → Tasks require calling the named delivered functions; mutants M01/M02 detect tag-accept and skip-execute.
- [Quietly dropping Claims/Tree by omitting fields] → Envelope always contains the keys; nonempty unsupported operators reject; remainder file names the later work.
- [Using example runner output as expected] → Fixtures store literals; author checker forbids expected generated from execute.
- [Vacuous empty catalog pass] → Empty document is malformed; empty catalog with an invoke is `unknownOperation` or configuration as catalog rules dictate; empty theorem audit is blocked.
- [Stale source pin] → Completeness requires D; F37 refuses other SHAs.
- [Inherited runner timeout honesty] → Record outer invocation; do not claim missing child logs.

## Migration Plan

1. Freeze this OpenSpec package and review bundle; independent GPT-6 reviews; `STATUS.gate_accepted` stays false until that verdict.
2. After acceptance: implement Certificates modules against failing tests, then correspondence proofs, then mutations, then parent import, then axiom audit.
3. Do not merge to main; publish accepted work to `semantic-kernel-pivot` only after later implementation evidence review.
4. Rollback is deletion of the unimplemented namespace; delivered Typed/Composition bytes stay unchanged.

## Open Questions

None that affect specs, approach or task breakdown. Unresolved source-plan citation tokens remain unverified and unused. Claims/Tree export shapes wait for those packages' accepted APIs and are remainder, not guesses.
