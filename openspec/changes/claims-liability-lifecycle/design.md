## Context

This author draft uses the currently present Typed, Composition and Atomic APIs. `Typed.ClaimId` is only a Nat wrapper; `Quantity asset` carries a nonnegative rational; `World` abbreviates state plus CapabilityStore. `Right` has invoke/debit/changeSupply only. `Composition.executeStep cfg boundary index history step pre` returns actual world/receipt/outputs or Failure. Its invoke branch runs Typed.execute and re-evaluates the receipt against the same pre-world. `Composition.Cursor` includes world, events, outputs, nextIndex and sticky failure. `Atomic.Result.publicWorld` restores entry on refusal/abort, but Atomic machines do not carry claims.

Source requirements are roadmap §3 and `docs/research/2026-09-06-defi-source-plan.md`'s obligation tuple and reserved semantic effects. The debt asset in Typed.Examples remains a different representation, with no newly assumed claim/token equivalence. Accepted S9 supplies fixed-type sequential execution; pending S10/M3/M4 and provenance/integer drafts supply no assumed APIs. This package needs only accepted Typed/Composition concepts. The exact accepted revision, runnable baseline and dependency closure must be refreshed before its official gate.

## Goals / Non-Goals

Provide one coherent synchronous lifecycle: a debtor requests a zero-interest fixed-principal loan that actually transfers the creditor's funds, and later pays the current creditor, defaults without losing liability, or receives an explicitly recorded waiver. Transfers change the creditor, not the debtor or asset. Modification means due-date extension only. These restrictions make authority and accounting reviewable without adding a legal adjudicator or consent-signature system.

Do not modify legacy World/Right/theorems or insert claims into the existing Atomic machine. No variable/indexed payoff, condition oracle, interest, fees, currency conversion, collateral, partial waiver, debtor novation, claim splitting/merging, cure-to-active, concurrent claims scheduler, cross-domain settlement, messages/finality/replay protocol, or deployed solvency theorem is included. Successful default records a modeled status; it does not establish a legal event or predict recovery.

## Decisions

### 1. Separate augmented state and finite record invariants

Create proposed namespace `DefiKernel.Claims`; the following are design contracts, not existing declarations. `State` contains `world : Composition.World`, `entries : List Claim`, and `lastLifecycleTime : Nat`. A claim stores domain, immutable debtor, current creditor, asset, positive original face amount, remaining/paid/waived amounts, createdAt, due, condition, status, defaultAt and revision. IDs are existing `Typed.ClaimId` values equal to permanent list positions; creation appends and never accepts a requested ID.

Amounts are raw rationals in the executable record, always denominated by its asset. `Claim.Valid` requires face>0; remaining/paid/waived≥0; face=remaining+paid+waived; debtor≠creditor; createdAt≤due; and the status invariants below. Checked quantity views can reuse `Typed.Quantity asset`; do not put noncomputable validation in the runtime or demand proof-bearing caller certificates. The plain record permits meaningful malformed-input and source-mutation controls. Initial validation rejects the first malformed row in index order. A finite store is not a claim of a finite financial state space.

`Condition` has exactly one supported constructor, unconditional. No arbitrary Bool is accepted as evidence of an external condition. Status is active, defaulted, or discharged(reason), where reason is paid or forgiven. Active requires remaining>0, waived=0, defaultAt=none. Defaulted requires remaining>0, waived=0, defaultAt=some t with due<t. Discharged paid requires remaining=0, paid=face, waived=0; discharged forgiven requires remaining=0 and waived>0. A terminal record may retain a previous defaultAt, always with due<defaultAt. Revision increments exactly once on every successful existing-claim action. createdAt, face, debtor/domain/asset never change; lastLifecycleTime bounds every lifecycle event and every stored created/default time on admitted initial stores.

A terminal record is a tombstone, not a removed row. No command reactivates it. Initial nonempty valid stores are explicitly trusted imported obligations; funded-origin theorems start with an empty store. Validity alone is not proof that imported debt was funded.

Alternatives rejected: changing legacy World/Right would disturb accepted statements; storing debt as another balance loses creditor/due/status and confuses burning with repayment; a general payoff/consent language adds unresolved oracle and legal semantics. Fixed records over an augmented state make the first theorem's limits explicit.

### 2. Authority and exact lifecycle commands

The trusted boundary remains `Composition.Boundary`, including authenticated principal/domain and supplied now. It is external authentication, not a caller's claimedActor or a signature verifier. Lifecycle ownership is checked against the current claim row; it is not inferred from a debit/invoke grant or domainAdmin role. Monetary invocations separately pass the unchanged capability checks. A debtor's capability to debit a lender is trusted permission in the existing store, not proof of a negotiated credit agreement.

Proposed commands:

| Command | Preconditions after common admission | Exact change |
|---|---|---|
| createLoan(creditor, asset, amount, due, fundingInvocation) | actor is debtor; actor≠creditor; amount>0; due≥now; domain from boundary; actual funding checks below | append fresh active claim with face=remaining=amount, paid=waived=0, revision0, createdAt=now; publish funding result |
| transfer(id, expectedRevision, newCreditor) | row active/defaulted; actor=current creditor; newCreditor differs from debtor and current creditor | only creditor and revision change; no cash, default history retained |
| extendDue(id, expectedRevision, newDue) | row active; actor=current creditor; newDue>due and newDue≥now | only due and revision change; no new principal or automatic cure |
| repay(id, expectedRevision, amount, paymentInvocation) | row active/defaulted; actor=debtor; 0<amount≤remaining | actual debtor→current-creditor payment; remaining-=amount; paid+=amount; revision++; terminal paid iff remaining becomes0; defaultAt retained |
| discharge(id, expectedRevision) | row active/defaulted; actor=current creditor | forgive entire remaining amount: waived+=remaining, remaining=0, terminal forgiven, revision++; no cash |
| markDefault(id, expectedRevision) | row active; actor=current creditor; now>due | status defaulted; defaultAt=some now; revision++; all monetary amounts unchanged |
| legacy(step) | unchanged Composition authority/execution requirements | exact existing Step result; claims and lastLifecycleTime unchanged |

A due-date extension is creditor forbearance, not arbitrary amendment; existing terms explicitly allow early/late partial payment and assignment to another nondebtor. These are model assumptions about this instrument. Any increase in face, new debtor, contingent payoff, transfer restriction or borrower consent workflow is separate specification work. A waiver is an authorized loss/forgiveness event, never a repayment receipt. No third-party repayment is accepted in this increment.

Default is an explicit action, not an automatic tick: at now=due it refuses; at now>due it can succeed. A defaulted claim remains payable and transferable, can be forgiven, and cannot be extended or cured to active. Paid/forgiven tombstones preserve defaultAt. Repeated default/discharge/repayment on a terminal row refuses. ExpectedRevision rejects stale row updates; this local freshness rule is not network replay prevention, and replaying createLoan can create another separately funded loan.

### 3. Actual payment and one publication boundary

createLoan/repay invoke `Composition.executeStep cfg boundary index history (.invoke inv) pre.world` once, with the actual current output history and absolute lifecycle cursor index. No caller-supplied Receipt or prevalidated payment proof substitutes for this equation. The invoke request's claimedActor check remains active. The result must have an invoked receipt; existing invoke execution already preserves capabilities.

The runtime payment validator compares **every cell** of the actual evaluated net effect and every domain/asset supply value over the existing finite universe. For q>0 and distinct parties, exact movement means effect(source)=-q, effect(destination)=q, all other cells0, and supply(d,a)=0 everywhere. Funding source is (domain,creditor,asset), destination (domain,debtor,asset). Repayment reverses that using the current creditor. Compare amounts to the lifecycle request, not the invocation's label, declared footprint, output values, or a caller assertion. The checked post-world must be the actual executeStep result; derive its balance equation from actual success soundness.

Only after both execution and payment validation succeed does one result publish the new world, changed claim row, actual receipt and outputs. Metadata is computed without observable publication before these checks. If underlying execution refuses, preserve its exact Composition.Failure. If it succeeds but the shape is wrong, return paymentMismatch with the actual tentative StepResult as diagnostic evidence; the public world, claims, outputs and accepted events stay at entry. A zero-effect invocation, unrelated donor payment, wrong creditor/asset/domain, extra balanced movement, minting, and an omitted cash update are not repayment.

This is a new single-command transaction with two validated components. Calling legacy Atomic.runAtomic over a World and updating a claim afterward cannot establish augmented-state atomicity and is not the implementation. Atomic's existing public/speculative distinction is a reference for observation design only. Legacy ordinary payments leave claims unchanged; they are donations or unrelated cash movement until an authorized lifecycle payment command links actual execution to a specific revision. The library does not infer repayment from matching later balances.

### 4. Refusal precedence and full cursor semantics

Proposed `executeCommand` returns Except Failure CommandResult. Common order is catalog validation, first invalid initial/current claim row (including clock consistency), then command branch. Lifecycle branches check nondecreasing now≥lastLifecycleTime before lookup; existing-row commands then check lookup, expectedRevision, terminal status, domain, actor, action-specific status/parameters, actual payment execution, and finally payment shape. createLoan uses domain from ctx and checks distinct creditor, positive amount, then due≥now before funding. Existing action parameter checks use amount positive before amount≤remaining; extension checks active before its date bounds; default checks active before now>due. Each failure retains the selected command/index/reason. Define first-invalid-row field precedence as face, nonnegative amounts, decomposition, parties, created/due, status/default consistency, then state clock bound. Concurrent invalid conditions have explicit fixtures.

Legacy commands use common state/catalog validation but skip lifecycle clock and role checks; legacy timestamp behavior remains unchanged. Successful lifecycle commands set lastLifecycleTime=now, including metadata actions. Legacy commands leave it alone. Time truth and authenticity remain assumptions; a monotone Nat comparison prevents recorded local time regression, not forged wall time.

Proposed Cursor carries augmented State, List Event, List OutputObservation, nextIndex, and optional located failure. Every successful command, including metadata actions, appends exactly one event with full pre-state and actual command result and increments nextIndex. Funding/repayment/legacy append exactly their actual Composition outputs; metadata appends none. Refusal changes only failure, retaining state, successful event/output history and index. A failed cursor makes every suffix inert. continueRun is an actual left fold; prove append from arbitrary entry cursors, not by resetting history.

Observation equality is pointwise on all ledger cells and exact on the capability list, every claim field/list position, clock, event command/index/pre/post states, inner receipts, outputs, nextIndex and failure including tentative payment diagnostics. Proof fields alone are ignored by proof irrelevance; financial state, failure distinctions and diagnostics are not omitted. Reference finite comparisons enumerate explicit cells/IDs; no Finset.toList runtime assumption.

### 5. Noncircular proof obligations

1. Unfold actual command success to obtain checked role, row/revision, amount, timing and actual underlying executor equations. Define reachable traces from start plus actual command results, never from desired preservation/equality assumptions.
2. From a validated initial store, inductively preserve Claim.Valid, positional identity, immutable fields, nondecreasing lifecycle clock, revision increments and permanent tombstones. Every pre-existing ID remains present. Other rows are exactly unchanged. Status transitions follow the table; default does not lower remaining.
3. For every reduction of a particular remaining amount, actual accepted execution is either debtor repayment with exact receipt movement or creditor forgiveness with explicit waived increment. Creation is the only append; no silent truncation, mutation by a legacy action, or default erasure. Transfers/extensions preserve all amounts. Prove face=remaining+paid+waived for every reachable row and distinguish this claim equation from aggregate cash supply.
4. Paid deltas equal actual per-event cash payments to the creditor at that event, even after transfers; summing all historical payments to the final creditor is false. Funding-origin theorem from empty store associates each row with its actual initial lender→debtor funding event. Cash totals stay unchanged for lifecycle money events, but legacy steps may legitimately change supply under their original authorities.
5. Local projection: successful payment world/receipt/outputs equal its actual Composition result; metadata stutters world; refusal publishes entry. Conservative extension: embed an arbitrary legacy Cursor with empty claims, map its legacy event/failure constructors, and execute a list of legacy commands to obtain exact projected Composition.continueRun, including existing failure and absolute history/index. Do not assert that a mixed lifecycle trace erases to an ordinary legacy sequence: metadata commands consume absolute indices, and payment-shape refusal is stricter than legacy execution.
6. Prove empty/success/refusal/append and full initial-run corollaries, terminal default retention, stale-version rejection, actual invalid-payment rollback, and closed/paid versus forgiven separation. No theorem assumes its target executor equality, no-disappearance property or a successful payment without linking the actual receipt.

### 6. Modules and finite evidence contract

New proposed runtime modules: Types (records/validation), Lifecycle (metadata/authority), Payment (actual receipt validator), Execution (command/cursor/continue), Observation (full comparator), Examples (literal runtime fixtures), Tests and Audit. Proof-only modules: PaymentSoundness, Preservation, Conservative, Fixtures and Verify. All executable definitions and proposition definitions needed by runtime precede exact `-- BEGIN PROOFS`; runtime Tests do not import proof-only Fixtures/Verify. Root integration after accepted gate adds imports/target without editing old source semantics.

The author fixture contract is `fixtures.json`: 24 IDs with full independently specified world/claim/event expectations, including dual-invalid precedence, same-branch failed suffix and fractional money. `planned-mutations.json` lists20 actual source mutations. Mutant credit requires a compiled actual executable candidate and a false named financial/full-state oracle; type errors, missing features, source-anchor failure and timeouts are blocked. Pin concrete snippets and invocation paths at implementation freeze, retaining each development attempt. Honest proof-scope/CLI controls are counted separately.

Future driver `python3 scripts/claims_gate.py --repo ROOT --out NEW_OUT` validates actual Audit IDs and runs named source mutants in isolated copies; `python3 scripts/test_claims_gate.py --repo ROOT --out NEW_OUT` exercises real CLI fixtures. NEW_OUT is outside the source repository and must not exist or be a symlink. Use runner timeout600s and harness1500s, record measured duration and partial output, do not count timeout as detection. Exact inherited CLI catalog and adapted namespaces/import roots/proof-tail regex/fixture/error mappings must be refreshed from the accepted runner at official freeze; no copied count is an execution result. Required CLI classes include production false Boolean/IO.userError despite exit0, missing/duplicate/empty IDs, malformed schema, dirty/wrong revision, path/symlink, timeouts, proof-tail leakage and source-drift checks. These are additional to20 semantic mutants.

Bind fresh baseline, full imported source/tool bytes, exact actual theorem/supplemental statements and axioms, runtime oracles, production mutations and all scenario IDs. Do not hardcode theorem counts. No sorry/custom axiom/native_decide. No deployed protocol labels or untouched-evaluation credit for these designed fixtures.

## Risks / Trade-offs

- A transferred claim can pay the old creditor if payment is keyed to creation data → use current row and expectedRevision; retain pre-event creditor in receipts.
- A default or waiver can look like repayment if only remaining is observed → preserve status, paid, waived, defaultAt, actual receipt and full cash state.
- Raw rational records permit malformed states → validate initial stores and prove all actual success branches preserve them; malformed-input fixtures remain executable.
- A matched cash balance can hide supply or unrelated transfers → compare exact evaluated effects and whole supply function, not a headline total.
- Trusted capabilities and boundary time can encode false external permissions/facts → state those assumptions; this package proves conditional internal execution only.

## Migration Plan

Author draft only. Refresh source/API and runner bindings, then obtain same-candidate nonauthor GPT-6 plus native Fable5.1 medium (`claude-fable-5-1[1m]`, `--effort medium`) before implementation. GPT-6 stock-harness implementation; no Foreman. Final substantive source/evidence review requires native Grok plus Fable and actual returned identities. Preserve failures and unavailable attempts; quota or transport completion is not a verdict. Parent owns commit/push/readback/archive. No hypothetical revision budget stops the authorized agenda. The author cannot supply the independent planning vote.
