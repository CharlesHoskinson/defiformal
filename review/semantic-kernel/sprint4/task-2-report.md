# Sprint4 Task2 capability lifecycle report

Task completed in the parent-selected shared workspace; no commits and no Foreman.
Owned repository files: `lean/DefiKernel/Typed/Authority.lean` and `AuthorityTests.lean` only.

## API freeze

Namespace `DefiKernel.Typed`; parametric order Party Asset Domain. These definitions import
Types only. Decidable equality is required where comparison is used; no Fintype is needed
by authority itself, which also works on the finite types used by the tests/executor.

- `Right Party Asset Domain`: `invoke | debit (Cell Party Asset Domain) | changeSupply Domain Asset`.
- `Right.inDomain right domain : Bool` validates exact resource locality.
- `Grant Party Asset Domain`: holder, domain, operation, right.
- `Capability Party Asset Domain extends Grant ...`: live : Bool.
- `AuthorityConfig Party Domain`: domainAdmin : Domain → Party;
  operationDomain : OperationId → Option Domain. Both are separate trusted immutable inputs.
- `CapabilityStore Party Asset Domain`: entries : List Capability. `.empty`, `.nextId`, `.lookup id`.
  nextId.value is entries.length. Permanent list positions avoid a separate counter invariant.
- `AuthorityFailure`: unauthorizedAdmin, operationDomain, resourceDomain, unknownCapability.
- `isDomainAdmin config ctx domain : Bool`: both ctx.domain and ctx.principal must match.
- `issueCapability config ctx store grant : Except AuthorityFailure (CapabilityId × Store)`.
  Refusal precedence: admin, registered operation domain, exact resource domain. Success appends live
  grant and returns old length as the new ID; requests never provide an allocation ID.
- `revokeCapability config ctx store id : Except AuthorityFailure Store`.
  Refusal precedence: unknown ID, admin. Success sets live=false at the same permanent position.
  Repeated revocation succeeds idempotently.
- `authorizesId store ctx operation right id : Bool`: lookup exists, live, holder, domain,
  operation, exact right and resource-locality checks.
- `hasAuthority store ids ctx operation right : Bool`: List.any of authorizesId.
- Tests: `DefiKernel.Typed.AuthorityTests.checks : List (String × Bool)`.

Named checks use globally prefixed `authority_*` snake_case labels. Standalone #eval drivers
are below the proof marker, with qualified AuthorityTests.checks references.

Executable declarations precede exactly `-- BEGIN PROOFS`. Both files can be projected by
retaining text before that marker and appending `end DefiKernel.Typed`.
No executable definition depends on a theorem below the marker.

## Lean evidence

15 generic theorems in Authority plus one closed kernel-checked test theorem:

- issueCapability_ok_iff: exact accepted grant witnesses and poststore.
- issueCapability_admin: accepted grant requires authenticated scope domain/admin.
- lookup_nextId: next ID has no existing entry in any list-backed store.
- issueCapability_fresh: issued ID was absent, gets the live grant, next ID increases by one.
- issueCapability_preserves_other: every other lookup remains equal, including unknown IDs.
- issueCapability_ne_existing: fresh ID differs from every existing live or tombstoned ID.
- revokeCapability_ok_iff: exact existing capability, admin and poststore witnesses.
- revokeCapability_admin: accepted revoke requires the capability domain administrator.
- revokeCapability_tombstone: original grant remains with live=false; next ID unchanged.
- revokeCapability_preserves_other: every other lookup remains equal.
- authorizesId_iff: exact live/holder/domain/operation/resource witness for accepted use.
- hasAuthority_iff: authority is witnessed by one supplied ID.
- hasAuthority_duplicate: repeating the same ID adds no right.
- revokeCapability_cannot_use: revoked ID authorizes no ctx/operation/right.
- issueCapability_keeps_revoked: issuing any new grant leaves an existing revoked ID unusable.
- authority_checks_pass: all 37 closed named comparisons are true, proved with `decide`.

No sorry, custom axioms or native_decide. `#print axioms` on all 16 theorem endpoints reports
only propext and Quot.sound (some depend only on propext).

## Executed comparisons

37/37 true through the live public functions. Coverage includes authorized/unauthorized issuance,
authenticated admin domain, unknown/wrong-domain operation, wrong-domain debit/supply resource,
invoke/debit/supply success, wrong holder/context domain/operation, unknown/empty request,
wrong exact debit owner/asset, wrong supply asset/right kind, duplicates, authorized/unauthorized
revocation, unknown revoke, idempotence and fresh allocation.

The same capability ID list and caller/op are used before and after revoking the debit right.
The invoke and supply capabilities remain valid positive siblings; an invoke failure does not mask
revoked debit behavior. Reissuing the same debit gets ID 3; ID 1 remains revoked. Separately issued
foreign-domain and different-operation grants have successful matching uses and refused local/original
uses. Tests construct capabilities through issue/revoke rather than forging poststores for use.
Expected successful output stores are literal comparison goldens.

Commands from `/home/charl/defiformal/lean`:

1. `lake build DefiKernel.Typed.Authority` — executable API freeze compiled.
2. `lake build DefiKernel.Typed.Authority DefiKernel.Typed.AuthorityTests` — final exit 0,
   705 jobs, no warnings; log `/tmp/defiformal-sprint4-task2-build.log`.
3. `lake env lean DefiKernel/Typed/AuthorityTests.lean` — exit 0, 37/37 true;
   log `/tmp/defiformal-sprint4-task2-tests.log`.
4. `lake env lean /tmp/defiformal-sprint4-task2-axioms.lean` — exit 0, all 16 endpoints;
   log `/tmp/defiformal-sprint4-task2-axioms.log`.
5. Lean LSP diagnostics on final Authority source: success=true, items=[].

Lean tool: 4.33.0-rc2, x86_64-unknown-linux-gnu,
commit d8b18978322de05a8f3dba51ef03cf5461676c17, Release.

## Integration boundaries and assumptions

Issue/revoke take and return only the capability store. They have no ledger input or output.
Task3 must prove the combined-state ledger preservation for administrative calls and capability-store
preservation for ordinary spending. No fake spending theorem is substituted in this module.

The trusted adapter supplies authenticated context, admins, initial store and operation lookup;
constructing a Lean value is not cryptographic authentication. Requests cannot replace these inputs.
The authorization checker binds to ctx.domain; Transition must ensure it equals the selected template
operation domain. Ordinary callers cannot replace trusted operation/config/store data.

No delegation, expiration, consumable allowance, ordered debit semantics or replay prevention claim.
Tombstone preservation theorems cover the supplied lifecycle operations, not adversarial replacement
of the trusted store value. Tests are finite development cases, not untouched holdouts or deployed
protocol fidelity evidence. Full-project audit, isolated mutations, native reviews and delivery are
parent-owned acceptance steps, not claimed completed here.

Mutation hooks: weaken each conjunction in authorizesId or isDomainAdmin; bypass issue operation
or resource domain checks; change revoke live=false to true; change append/fresh-ID allocation.
The parent should strip proofs in isolated copies and run checks to observe false comparisons.
No mutation was measured by this subtask; the parent owns the source-mutation runner.

## Source SHA-256

- `Authority.lean`: `dfd2c140f511144e9928ed4f5ed1db9ee2b56cada1342500d2e60c33ef9a0cdb`
- `AuthorityTests.lean`: `02c7028ade18e53815d436f57fc3c80cd79c06dc585a3e985b1be8dab544ae77`
