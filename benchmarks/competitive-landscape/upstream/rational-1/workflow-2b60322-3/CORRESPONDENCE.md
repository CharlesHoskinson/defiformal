# Exact-rational workflow correspondence

This candidate covers `R3-COMPOSE-N4`, `R3-COMPOSE-N16`, `R4-REFUSAL`,
`R5-REVOKE`, `R6-ATOMIC`, `R7-NET`, and `R8-REUSE` in `rational-1` /
`EXACT_RATIONAL`. Its origin is **adapted_library**, at the **abstract_model**
boundary. It combines actual DeFiFormal financial execution with newly authored
canonical operation and workflow wrappers. These notes describe source and proof
correspondence; they do not record admission or scored performance results.
R1, R2, and the separate INT64 suite are outside this candidate's coverage.

The upstream repository is `CharlesHoskinson/defiformal`, pinned at
`2b60322cdc8c98f0e0c27cab3b2d6dcc824c3eda`. Lean is `4.33.0-rc2`; mathlib is
`51e6992efd06126df61a496bebf8f49482a4e129`. [native-lock.json](native-lock.json)
binds the native source snapshots and binaries; [dependency-lock.json](dependency-lock.json)
binds the offline dependencies. [case-plan.json](case-plan.json) lists each exact
target and its model, automatic, assisted, and witness module dependencies.
The governing contracts are repository-root
`specifications/rational_performance.md`,
`specifications/rational_performance_measurement.md`, and
`specifications/rational_performance_reviewer.md`.

## Native execution and added work

[Core.lean](upstream/DefiKernel/Core.lean) supplies `DefiKernel.State`, exact
rational balances, `Policy`, `Transition`, `check`, `execute`, `applyEffect`,
`total`, and the checked results `execute_ok_iff`, `execute_accounting`, and
`execute_locality`. [Examples.lean](upstream/DefiKernel/Examples.lean) supplies
the actual signed financial effect functions `Examples.move` and
`Examples.pulse`. `move` adds both signed occurrences, so coincident source and
target cells cancel correctly.

[WorkflowModel.lean](WorkflowModel.lean), declarations `effect`, `transition`,
`policy`, and `execute`, construct a native transition and actually invoke
`DefiKernel.execute` for every successful single call, including administrative
calls with zero financial effect. Deposits and withdrawals generalize the
upstream move/pulse financial patterns to both users, both vaults, every actor,
and independent positive rational rates. They do not call the upstream fixed
Alice/vault/rate-two `Examples.deposit` or `Examples.withdraw` unchanged.

[LocalContracts.lean](LocalContracts.lean), declarations `native_valid`,
`publish_claims`, `execute_success`, `execute_success_iff`, and `execute_local`,
prove that the canonical input guards suffice for native execution and derive
the exact update, accounting, and frame from its checked results. Native
`execute_ok_iff` identifies the actual `applyEffect` result; native
`execute_accounting` and `execute_locality` supply their respective conclusions.
The generalized effect-accounting, local success, surplus, and composition
proofs are new adapter work. The imported native example-specific deposit and
withdrawal accounting theorems are not being presented as these new proofs.

The canonical invoke capability, gross debit guards, raw input decoding,
administrator set updates, public history, sequential control, atomic rollback,
and net request validation are newly authored. Native Core checks net negative
effects and nonnegative final balances. Single-call wrappers additionally check
the canonical gross source debit and invoke right, even for zero or self
transfers. R7 instead uses native negative-effect authority on the aggregate.
In each case successful financial output is the native executor's output.

This is not a measurement of `DefiKernel.Typed.Authority`,
`DefiKernel.Composition.executeStep`, or `DefiKernel.Atomic.runAtomic`. Those
upstream systems have different public interfaces: permanent capability IDs
and tombstones, registered component interfaces and receipts, and an atomic
request with a grouped committed event. The canonical set-idempotent
administration, arbitrary raw calls, and ordered four-call atomic history use
the added wrappers. No refinement theorem to those native control systems is
claimed. Their inspected upstream locations are
`lean/DefiKernel/Typed/Authority.lean`,
`lean/DefiKernel/Composition/Execution.lean`, and
`lean/DefiKernel/Atomic/Execution.lean` at the same pinned revision.

## Complete public-state and input mapping

All definitions in this section are in [WorkflowModel.lean](WorkflowModel.lean).

| Canonical object | Lean representation and observable interpretation |
|---|---|
| Accounts `alice,bob,vaultA,vaultB` | Native `Account.alice,bob,vault,pool`; all four are independently available to transfers. |
| Principals `alice,bob,operator,admin` | The same four native constructors in a separate role mapping; `operator` maps to `.vault` and `admin` to `.pool`. Sharing the carrier grants no implicit authority. |
| Assets `cash,shareA,shareB` | `Asset.cash,shareA,shareB`, mapped by `Asset.native` to native `.usd,.share,.collateral`. |
| Users and vaults | `Bool`: users false/true are Alice/Bob; vaults false/true are A/B. `shareAsset` preserves the declared vault/share association. |
| Twelve balances | Native `State.balance` restricted to the four accounts and three mapped assets. Native `State.nonneg` proves nonnegativity. The fourth native asset, `.debt`, is zero in every account under `ValidState`. |
| Supply `S` | `PublicState.supply` is native `total`, separately per mapped asset. It is derived rather than independently stored. Every canonical state satisfying the required supply equality has this representation. |
| Rates `r` | `Vault → ℚ`; `ValidState` requires both to be positive. They remain independent symbolic values, including equality, with no fixed denomination or bound. |
| Capabilities `C` | Any `Finset Capability`; constructors cover each principal's three invoke rights, twelve debit rights, and two share-supply rights. Empty and partial sets are included. |
| History `H` | Arbitrary finite `List Event`; each event contains its typed calls, all signed cell deltas, and separate asset-indexed issuance and burn quantities. Initial history is preserved as a prefix. Theorems allow even a larger initial history domain than well-formed canonical history. |
| Exact amounts | Lean `ℚ`, including negative values for total execution. No numerator/denominator cap, scale, rounding, or machine overflow is imposed. |
| Raw call envelope | `RawCall` carries arbitrary strings for identifiers and `Number.exact q` or `Number.malformed description`. It models exact versus malformed input; it is not a verified implementation of a production serialization parser. |

`PublicState` has no independent supply storage to become inconsistent; balance
equality implies derived supply equality. Equality of the complete structure
includes ledger, rates, capabilities, and history. Its extra proof fields carry
no public control output. Invalid initial ledger states and nonpositive rates
are outside the canonical valid-state domain. Negative initial surplus remains
in scope; nonnegative final surplus is conditional on nonnegative entry surplus.

`effect` computes transfer `-q` at source plus `q` at target; deposit moves cash
from user to vault and issues `q/r[v]` shares; withdrawal moves `q*r[v]` cash
from vault to user and burns `q` shares. `issued`, `burned`, and `writes` specify
the exact receipts and footprint. `LocalClaims` requires actual native
execution, all balance equations, nonnegativity, per-asset accounting, fixed
rates, the exact capability update, one exact appended event, and the frame.
`deposit_surplus` and `withdraw_surplus` derive the fixed-rate surplus equations.

`rawExecute` and the separately specified `decodeRaw`/`expectedRefusal` use
`BAD_OPERATION`, then `BAD_TARGET`, `BAD_NUMBER`, `BAD_AMOUNT`, `UNAUTHORIZED`,
and `INSUFFICIENT_FUNDS`. The numeric and target checks precede authority;
authority precedes gross funds. `execute_success_iff` proves success on exactly
the declared typed domain for valid states. `nativeFailure` is a defensive
result constructor; the admissible-success and first-refusal proofs rule it
out on this domain. Refusal preserves the entire input state.

## Canonical target statements

| Case | Canonical statement | Assisted theorem |
|---|---|---|
| R3-COMPOSE-N4 | `RationalWorkflow.ComposeCanonical false 4` | `RationalComposeN4.canonical` |
| R3-COMPOSE-N16 | `RationalWorkflow.ComposeCanonical false 16` | `RationalComposeN16.canonical` |
| R4-REFUSAL | `RationalWorkflow.R4Canonical` | `RationalWorkflow.r4_canonical` |
| R5-REVOKE | `RationalWorkflow.R5Canonical` | `RationalWorkflow.r5_canonical` |
| R6-ATOMIC | `RationalWorkflow.R6Canonical` | `RationalWorkflow.r6_canonical` |
| R7-NET | `RationalWorkflow.Net.Canonical` | `RationalWorkflow.Net.canonical` |
| R8-REUSE | `RationalReuse.Canonical` = `RationalWorkflow.ComposeCanonical true 4` | `RationalReuse.canonical` |

R3 uses [ComposeModel.lean](ComposeModel.lean), `workflowCalls`, `AlgebraDomain`,
`CompositionClaims`, and `WorkflowClaims`. For each length it quantifies every
valid state, every actor, and an arbitrary list of independent signed rational
amounts of that length. The fixed pattern is deposit Alice, transfer shares
Alice to Bob, withdraw Bob, transfer cash Bob to Alice, repeated for N16.
`AlgebraDomain` computes all intermediate balances from input deltas and checks
each call's nonnegative amount, capability, and gross funds requirements. It
contains no premise that execution succeeded. `ComposeCanonical` proves both
success on that domain and equivalence of complete sequential success to it,
with first-refusal behavior outside it.

[ComposeAssisted.lean](ComposeAssisted.lean), `compose_success`, inductively uses
`execute_success` and `LocalClaims` for each actual intermediate state.
`LocalTrace` retains those local checked contracts; the composition proof passes
the complete state and asset-indexed event receipts. It establishes exact
balances, all prefix states and nonnegativity, accounting, ordered N-event
history, unchanged rates/capabilities/cash supply, the specified share issuance
minus burn sum, surplus preservation, and the complete outside-footprint frame.
`workflow_trace_preserves` uses the local surplus results. Independent amounts
permit partial spending; no relation equating one step's amount to a preceding
receipt is assumed. This is asset-indexed state/effect composition, not a claim
that a source-language type checker rejects every mistaken numeric port use.

R4 uses [WorkflowControl.lean](WorkflowControl.lean), `runRaw`, `RawStepSpec`, and
`RawExecutionSpec`, with [WorkflowControlProofs.lean](WorkflowControlProofs.lean)
and [WorkflowSequenceProofs.lean](WorkflowSequenceProofs.lean). It quantifies all
valid states and all four-element raw lists, including malformed, unsupported,
administrative, zero, and aliased calls. The inductive specification fixes each
successful state/event and the first exact refusal. The theorem fixes committed
count and failure index, retains the successful prefix, and proves that every
appended suffix leaves a refused result identical. It does not roll back the
successful prefix.

R5 uses `R5Canonical`, `requiredCapabilities`, and `adminUpdate`, proved in
[R5Assisted.lean](R5Assisted.lean) using
[WorkflowRevokeProofs.lean](WorkflowRevokeProofs.lean). It quantifies every valid
state, every successful financial call, and every selected required capability.
The first call and trusted admin revocation succeed; the repeat call refuses
unauthorized with unchanged state, without assuming repeat-call funds. Exact
grant/revoke effects, nonadmin refusal, set idempotence, and regrant restoration
are quantified over every capability. Each successful administrative call still
appends its event, including an idempotent update. Regrant alone does not promise
that a later financial call has sufficient funds.

R6 uses `atomicRaw` and `R6Canonical`, proved in
[R6Assisted.lean](R6Assisted.lean). Its arbitrary four-raw-call domain is the same
as R4. It stages `runRaw`; on success the final state and ordered four events
are identical. On failure it returns the exact reason/index with count zero
and the complete entry `PublicState`. This restores staged authority changes,
issuance, burn, rates, balances, supply, and history. It is an abstract public
transaction boundary with no network, concurrency, crash, or external-effect
guarantee.

R7 uses [NetModel.lean](NetModel.lean), `aggregate`, `validateOne`, `validate`,
`executeNet`, and `settle`; [NetAssisted.lean](NetAssisted.lean) proves the
conjuncts of `Net.Canonical`. `AggregateCanonical` identifies the exact sum of
all signed indicator contributions, including every alias. Record validation
covers arbitrary raw records and actor/target/numeric errors in order, with an
indexed first refusal; invalid request actor has no index. `RawTotalCanonical`
proves a success iff relation to `RawSuccessDomain`, whose `RawMatches` relation
describes exact nonnegative records independently of execution. Missing net
authority is checked before final-balance insufficiency, both without an index.
The validation and aggregate theorems cover lists of any length, hence include
all four-record canonical requests.

Net authority is invoke-transfer plus debit rights for exactly the negative
aggregate cells. `net_authority_exact` proves that correspondence with native
`DebitAuthorized`; there is no extra gross source requirement for net settlement.
`settle` actually executes one native aggregate transition and appends one event
containing the entire instruction list. `NetClaims` fixes exact output balances,
nonnegativity, unchanged supply/rates/capabilities, zero issuance/burn, and frame
at every zero-delta cell. `SequentialCanonical` separately quantifies all valid
states and four independent same-actor nonnegative instructions. It proves
sequential success iff `GrossAuthority` and `PrefixFunds`, where prefix balances
are input-derived algebraic updates. On that whole domain it proves net success
and equality of final balances, supply, rates, and capabilities. History equality
is intentionally absent: sequential execution emits four events, net one.
The zero-funded cycle witness discriminates the failure of the converse.

R8 imports the actual checked R3 foundation. [ReuseModel.lean](ReuseModel.lean)
defines `RationalReuse.Canonical`; [ReuseAssisted.lean](ReuseAssisted.lean)
imports `R3N4Assisted` and applies `RationalWorkflow.generic_compose true 4`.
There is no copied B-specific proof or new financial transition. The resulting
statement quantifies both independent positive rates and every valid input for
vault B/share B, including the full domain, refusal behavior, A frame, and B
surplus preservation. The use of an existing parameterized theorem is explicit
proof assistance, and establishes a second instance of this contract, not a
claim about arbitrary new protocols.

[reuse/foundation-source.json](reuse/foundation-source.json) fixes the checked
source checkpoint at `2026-11-06T09:47:51.298346+00:00`, including exact source
copies, declaration names, and hashes, before B-specific authoring.
[reuse/foundation-check.json](reuse/foundation-check.json) retains the actual
successful compilation outputs. [reuse/extension-source.json](reuse/extension-source.json)
and [reuse/extension-check.json](reuse/extension-check.json) bind the extension
delta, theorem application, distinct-rate witnesses, and its subsequent checks.
The checkpoint's generic theorem already quantifies both vaults. Foundation and
extension effort records describe separate phases; shared foundation work is
not added again as new R8 proof construction. Independent admission and scored
replay are separate from these preparation checks.

## Proof, witness, automation, and trust boundaries

The named canonical theorems are universal Lean propositions. Their validity
does not rest on enumerating rational samples. `ComposeWitnesses`,
`ControlWitnesses`, `NetWitnesses`, and `ReuseWitnesses`, plus the mutation probes,
execute finite concrete examples to check observables and expose deliberate
defects. Their printed outputs are diagnostics, not proof certificates and not
competitor performance results. `case-plan.json` keeps witness modules out of
canonical proof targets.

[procedure.json](procedure.json) retains the prior automatic procedure:
`aesop`, `maxHeartbeats 20000`, Lean `-j1`. The successful unrelated example in
[selection/result.json](selection/result.json) was executed before the target
adaptation. Each `*Automatic.lean` uses that unchanged tactic on the same
canonical type, importing only its model chain. New target lemmas, decomposition,
native theorem selection, algebraic tactics, and the R8 theorem application are
AI-authored assistance in the separate assisted modules. Native upstream proofs
already imported with the pinned library remain pre-existing dependencies.
Every new assisted helper required by a target is in its replay module chain;
successful assisted replay cannot erase an unsuccessful automatic observation.

Lean elaboration and tactic execution produce compiled `.olean` modules.
`driver.py` parses the exact target name and its reported axioms, allowing only
`propext`, `Classical.choice`, and `Quot.sound`. Proof holes, custom axioms,
missing targets, failed compilations, and nonproduced artifacts cannot establish
a target. This declaration audit is part of acceptance, not a source-to-machine
verification claim.

The separate checking job invokes `leanchecker -v` on every newly compiled
model/helper/target module in that case's assisted chain and checks their bytes
remain unchanged. It replays compiled declarations without rerunning source
tactics. It uses the **same Lean kernel**, trusts the pinned imported library
closure, and does not use `--fresh`; it is not a diverse implementation of a
kernel and does not independently rebuild all imported mathlib/native proofs.
Trusted components include the official compiler/checker and runtime, allowed
standard axioms, pinned imported Lean/mathlib/native artifacts, the host used to
run them, and the harness's source/artifact selection and output parsing. The
scoped results concern the executable abstract Lean model, not deployed source,
bytecode, authentication, dishonest-admin resistance, changing-price solvency,
or distributed settlement.
