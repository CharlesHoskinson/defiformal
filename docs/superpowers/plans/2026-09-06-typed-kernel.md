# Typed Kernel and Capability Authority Implementation Plan

> Use superpowers:subagent-driven-development with GPT-6 implementation and
> direct native Grok/Fable review. The user authorized autonomous completion.

**Goal:** Complete the approved Sprint4 checklist with a Lean-native typed IR,
capability lifecycle, three reference libraries and executed preservation evidence.

**Architecture:** New `DefiKernel.Typed` modules, parametric finite identity types,
first-order dimension-indexed expressions and registered generic transition
bodies. Authenticated context, registry and domain administrators are explicit
trusted boundary inputs. Existing pilot and corpus files remain preserved.

**Tech Stack:** Repository-pinned Lean/mathlib; Python orchestration and isolated
mutation fixtures; stock GPT6 collaboration; direct Grok/Fable CLIs.

## Global constraints

Read `../specs/2026-09-06-typed-kernel-design.md`, root AGENTS.md, the Lean skill,
defi-footguns and gate register. No `sorry`, custom axioms or `native_decide` in
accepted proofs. No protocol-specific operation constructors, unrestricted host
callback in public expression/operation IR, or untracked expression reads.
Numerics are exact mathematical rationals; no machine-rounding or deployed
fidelity claim. All examples are development cases. No Foreman. Parent owns
commits/integration/review artifacts. Agents edit only their named files.
User approval is already present; routine implementation choices do not reopen it.

## Task 1: Typed identities and expression evaluation

Owner: GPT6 foundation implementer. Create only
`lean/DefiKernel/Typed/Types.lean`, `lean/DefiKernel/Typed/Expr.lean`, and
`lean/DefiKernel/Typed/ExprTests.lean`.

- [ ] Define reusable parametric Party/Asset/Domain types, distinct opaque IDs,
  dimension-indexed amounts/prices/scalars/booleans and nonnegative ledger state.
- [ ] Define a closed first-order expression AST, checked typed arguments,
  party references and typed environment observations. Reject missing/wrong-unit
  input and undefined division; timestamps/current time are explicit inputs.
- [ ] Derive state/environment read sets including both conditional branches;
  prove evaluation agrees when the required reads/arguments agree, including
  refusal behavior. Intrinsic expression typing is distinct from state invariants.
- [ ] Compile positive exact conversion, zero-divisor/missing-input refusals and
  read-dependence examples. Record actual commands/results and exported API in
  `/tmp/defiformal-sprint4-task1-report.md` before handing off. No commits.

The design's expression constructors define the acceptance interface; choose
Lean signatures that avoid unnecessary dependent casts, then freeze and document
those exact signatures for dependent tasks. No proof-free API placeholder counts
as task completion. Run from lean: `lake env lean DefiKernel/Typed/ExprTests.lean`.
Build intermediate modules through Lake before dependent imports.

## Task 2: Capability administration and live authority

Owner: GPT6 authority implementer after Task1 API freeze. Create only
`lean/DefiKernel/Typed/Authority.lean` and `AuthorityTests.lean`.

- [ ] Implement separate authenticated actor/domain context and immutable domain
  admin configuration; requests cannot replace the context.
- [ ] Implement generic invoke/debit/changeSupply rights with exact scope; issue
  only under the authenticated administrator and validate resource/operation
  domains. Allocate fresh IDs or reject reuse, retaining revoked tombstones.
- [ ] Implement revocation and use checks: live status, holder, domain, operation
  and resource. Duplicate request IDs confer no additional rights.
- [ ] Prove accepted grant/revoke authority, unrelated-capability preservation,
  fresh-ID behavior and inability to use the revoked ID; ordinary spending must
  preserve capability state. Do not claim cryptographic authentication.
- [ ] Execute unauthorized issuer/revoker, wrong-holder, wrong-domain, revoked,
  unknown and wrong-operation cases with successful siblings. Save API, commands
  and results in `/tmp/defiformal-sprint4-task2-report.md`. No commits.

## Task 3: Generic registered transitions and execution proofs

Owner: GPT6 kernel implementer after expression/authority interfaces freeze.
Create only `lean/DefiKernel/Typed/Transition.lean` and `TransitionTests.lean`.

- [ ] Define data templates with signatures, guards, typed cell/supply deltas,
  declared read/write footprints and domain. Repeated deltas aggregate by addition.
- [ ] Resolve templates from trusted registry by requested operation ID. The
  request carries arguments and capability IDs, never an executable body/guard.
- [ ] Evaluate checked arguments and actual expressions; require live invocation
  and resource rights, declared reads, nonnegative updates, per-domain/asset
  accounting and write locality. Cross-domain movement refuses in this increment.
- [ ] Prove success iff evaluated effects meet actual checks and exact update;
  derive state nonnegativity, accounting, write locality and live authority.
  Preserve registry/capability state on spending and expose explicit refusals.
- [ ] Exercise each refusal stage with a positive sibling reaching that stage,
  including undeclared guard/effect reads, insufficient balance, mismatched supply,
  wrong-asset accounting and missing writes. Save commands/results/API in
  `/tmp/defiformal-sprint4-task3-report.md`. No commits.

## Task 4: Reference libraries, observable checks and integration

Owner: GPT6 library implementer plus parent integration. Create
`lean/DefiKernel/Typed/Examples.lean`, `Acceptance.lean`, `Audit.lean`,
`Verify.lean`; parent may add its import to `lean/DefiKernel.lean`.

- [ ] Encode transfer, fixed-rate vault deposit/withdrawal and oracle-dependent
  borrow as ordinary registered templates. Use explicit 2 USD/share and 1
  USD/debt conversions and 2x collateral guard, positive price, feed binding,
  no future timestamp and age at most5. Preserve prior reference initial balances.
- [ ] Check corresponding posts: transfer3 gives Alice7/Bob3 USD; deposit4 gives
  Alice6 USD/6 shares and vault24 USD; withdraw2 shares gives Alice14 USD/2 shares
  and vault16 USD; borrow3 gives Alice13 USD/5 debt and pool97 USD. All unspecified
  balances remain unchanged. These are reference semantics, not deployed fidelity.
- [ ] Add capability issue/use/revoke and unchanged-request-after-revoke sequences;
  rejected forged/unknown operation and wrong actor cases; stale/zero/future/wrong
  feed; dimension mismatch; zero divisor; footprint/accounting/insufficient funds.
- [ ] Prove concrete accepted/refused outcomes and scoped preservation statements;
  keep executable comparison list separate from proof declarations for mutations.
- [ ] Parent extends the import root and audits every imported Typed module via
  existing axiom command. Capture full baseline and final build/audit logs.

## Task 5: Discriminating evidence, native review and delivery

Owner: parent. Own scripts, docs, progress and `review/semantic-kernel/sprint4/`.

- [ ] Add a real source mutation runner over isolated copies of changed Lean
  modules. Each mutant must build and execute checks; require actual false
  comparisons for bypassed capability, registry selection, read/write footprint,
  accounting and relevant evaluation checks. Preserve positive controls.
- [ ] Compile rejected typing fixtures using actual exported API; classify them
  as typing evidence, not executed financial counterexamples. Missing files or
  zero executed cases block verification. Keep all fixture writes outside repo.
- [ ] Run fresh full Lean build, new/old runtime checks and imported axiom audit.
  Record exact source/tool identities and confirm original corpus/proofs unchanged.
- [ ] Freeze a local candidate and obtain independent native Grok/Fable reviews
  on identical scoped bundles of exact source and evidence. Record requested and
  reported models, failures, findings and fixes. Fix substantive issues and run
  one focused re-review when necessary.
- [ ] Save final evidence and progress, commit, push semantic-kernel-pivot and
  verify remote head equals local clean HEAD. Only then complete the active goal.
