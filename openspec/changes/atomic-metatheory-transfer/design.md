## Context

Provisional M6/Sprint14 author draft. Existing accepted `Atomic` executes two invocation streams using `Interleaving.advance`. It has an immutable `entryWorld`, speculative machine, signed `Outstanding`, global consumed-token `position` and optional first abort. Public `Result.publicWorld`, `committedHistory` and `committedSupply` publish speculation only on commit. `finish` commits exactly when there is no prior abort and the ordered residual list is empty. These actual source files are bound in author evidence; reading them is not a fresh build.

M3 finite dispatch, M4 actual tree simulation and M5 protected active projection remain proposed. Their observed source-plan snapshots are retained as provisional context. No prospective symbol below is asserted to exist. Accepted S10/M3/M4/M5, full actual API refresh and same-candidate nonauthor GPT-6/native Fable5.1 medium approval are blocking prerequisites to official freeze.

## Goals / Non-Goals

Lift the accepted atomic wrapper to actual finite and tree execution, prove exact binary and same-boundary tree correspondence, then prove a deliberately restricted active extension. Carry receipt-derived settlement and first-abort diagnostics through the actual step relation. Preserve nonempty transient examples and the difference between tentative and published evidence.

No nested savepoint, callback, dynamic configuration, issue/revoke, store growth, new ledger identity universe, principal renaming, moved commit boundary, arbitrary schedule permutation, arbitrary causal-monitor equivalence, new-lane settlement interaction or deployed Balancer fidelity is included. This work does not reinterpret empty lanes as transient accounting. Every engine uses invocation-only streams and one fixed configuration/boundary family during a run.

## Decisions

### D1. Generalize the wrapper, preserve the policy

A new `AtomicNary` namespace reuses the actual `Atomic.Lane`, `Policy`, `Outstanding`, `Residual`, `receiptEffect`, `updateOutstanding`, `residuals` and `checkSupply`. Those definitions are independent of execution stream IDs. Lane uniqueness is by **(domain,asset)**, not (domain,asset,vault). Changing the vault does not avoid a duplicate-key error. Policy participant entries are authenticated principals P, not stream IDs U. Preserve list order because duplicate and residual/first-supply diagnostics are ordered.

Generalize only branch-indexed coverage/admission errors and their traversal. Admission order is catalog validation; every full branch structural analysis in the accepted global roster order; policy lane duplicates, principal duplicates, then coverage of every static invocation principal in roster/index order; finally schedule counts. Preserve malformed unreachable suffix detection. No group-local policy or participant-table reconstruction is allowed. Typed roster assumptions are inherited from accepted M3, not silently replaced with a new runtime roster parser.

New `Machine U` holds `entryWorld`, actual `Nary.Machine U` speculation, the same pointwise outstanding table, position and a generalized abort reason. Kernel and lane-supply aborts retain participant, successful local index, global pre-step position, exact invocation and exact kernel reason or ordered lane/amount. Unsettled abort retains the full ordered residual list. A global position counts consumed tokens before the abort, including any pre-abort skips; it is not a successful-event count or branch index.

### D2. Actual atomic step and settlement monitor

When already aborted, `advance` returns the **entire machine unchanged**, including position, speculation and owed table. Otherwise call actual Nary advance exactly once, increment position once, and inspect only the newly appended attempt at the old attempt-list length. No attempt means a skip and no settlement update. A kernel error records the first global abort with no receipt update. A success updates outstanding from that exact receipt and `(boundaries participant localIndex).ctx.principal`, then checks lane supply; a supply rejection retains the updated speculative world and owed table diagnostically. This update-before-supply-abort order matches accepted Atomic.

`continueRun` folds the atomic step. `runPrefix` starts one fresh zero-owed atomic machine. `finish` checks existing abort before residuals. `runAtomicNary` performs admission once, runs the supplied complete schedule, and finishes once. Admission refusal has no speculative execution. Aborted and refused public worlds are exactly entry world/store, published events are empty and published supply is zero. Commit publishes exactly one outer event, even for an admitted empty batch. The event retains label, supplied schedule and chronological successful inner receipt/output observations.

Prove the actual reachable trace and first-abort absorption. Prove outstanding equals an independent fold of the actual successful attempts, including the success that triggers a supply abort. Kernel failures and skips contribute nothing. Derive per-lane cash plus the complete signed principal sum from actual receipt/cell balance correspondence; do not collapse principals, assets or domains into scalar netting. Negative outstanding is an over-return credit, not cleared debt; exact zero is required at finish. Off-policy entries are zero for runs initialized at zero. Arbitrary-entry correspondence assumes full pointwise table equality, not just equality of listed residuals.

A commit characterization uses actual underlying Nary attempts that all succeed and pass supply checks plus clearance of their independently folded obligations. This is the finite analogue of `Atomic.GoodAttempts`/`runAtomic_commit_of_interleaving`; it does not assume an atomic commit or the desired wrapper correspondence. Concrete enabledness and settlement premises require separate proofs. Mere absence of currently recorded abort is not a proof that a future added step succeeds.

### D3. Exact binary and fixed-schedule tree correspondence

For U=`Parallel.BranchId`, roster[left,right], identical cfg/boundaries/policy/entry/label/schedule, give complete conversions of finite machine/results/errors to accepted Atomic. Prove admission and start/advance/arbitrary-entry continuation/finish/run correspondence, retaining raw speculative before/result worlds, all attempts/locals, full owed table, global position, first abort and public fields. If accepted M3's schedule error stores only the first mismatch, reconstruct the binary full mismatch using original streams and schedule; do not attempt an information-losing error-only conversion.

The tree atomic executor wraps actual M4 `advanceTree`, not a flattened rerun. Its machine contains the same outer entry, owed table, position and abort plus the tree speculative machine. Use actual tree-to-flat conversion only to inspect the appended attempt and state the relation. M4's step simulation then gives the identical attempted outcome and authenticated principal for each fixed token. Prove the settlement update and supply decision correspond, and only then induct over the schedule. Existing abort cases are exact identities on both machines.

Tree regrouping changes only routing shape. It keeps the same global roster, leaf streams, cfg, boundaries, outer label, initial world, entire ordered policy, update rule, schedule and **single** finish boundary. Prove full speculative/owed/position/abort correspondence at every prefix and equality of final public observations. Run complete finite Atomic admission, including policy before schedule counts, before tree validation; within tree validation retain accepted M4 shape/path order. A tree admission error is separately tagged from a finite Atomic admission error, with no flat/binary counterpart claimed for invalid trees. The same-boundary tree equality theorem requires valid related trees. Resolve the exact inherited error types at API refresh. A malformed tree never silently executes a fallback flat program. No tree subtree calls finish or restarts entry/owed state.

Changing schedules is outside this equality: two disjoint refusing streams can produce different first-abort identities/positions, even though both roll back to the same balances. M4's reduced schedule-independent endpoint observer is insufficient for Atomic's global failure and publication contract. An arbitrary M3 monitor can count attempts or inspect raw worlds; only the fixed settlement monitor described here is transported automatically. Other monitors need their own actual-input correspondence and premises.

### D4. Restricted successful active extension

Reuse accepted M5's fixed P/A/D universe, old-subtype roster inclusion, schedule restriction, full-store equality, old configuration support/admin/boundary agreement and protected old read/write/snapshot region S. Keep the **same outer label and same entire ordered Policy** on both sides; include all new principals in that fixed policy before either run. Both atomic admissions must succeed, with an independently proved restriction/admission corollary where applicable. Adding policy entries or grants only on the extended side is not covered.

For the first theorem, require **every policy lane cell belongs to S** and every new analyzed write avoids S. Thus actual new successful receipts have zero effect on all listed lane cells, and their outstanding updates are identities for every principal. Additionally require every actually selected new invocation before abort to succeed and its actual receipt to satisfy `checkSupply policy receipt = none`. The latter is necessary even with zero lane-cell effect: minting the lane asset/domain into another cell still violates the existing policy's supply rule.

Provide a narrow executable `newReceiptSafe policy receipt` check for zero effect on every listed lane cell and `checkSupply = none`, with a proof that its Boolean result matches precisely those receipt conditions. This helper consumes an actual successful receipt; it does not predict enabledness, admit a transaction or certify future success.

State new enabledness as an independently discharged local obligation over actual reachable nonaborted prefixes with the selected invocation/index/history and explicit present state/boundary premises. A fixed old initialized invariant plus new-local balances can establish it in a concrete family. Do not use the desired extended commit or whole-run observation equality as an assumption. Successful ordinary Nary replay is usable evidence only with its actual trace and the policy checks; M5 alone never supplies this enabledness premise.

Induct over extended atomic tokens. An old token has the exact old receipt/output/refusal or lane-supply abort under M5 dependency correspondence and the same owed table/policy. A new successful token preserves protected speculation, the complete store and the whole owed table, but may publish additional tentative non-lane receipts and change unprotected state. After an old abort, both wrappers stop globally; no later new token is executed. This is atomic absorption, not M5's continued consumption of failed-peer suffix slots.

At finish, the unchanged owed table yields exactly the same ordered residuals, so old commit versus unsettled abort is preserved. If the old run fails, exact rollback on protected entry balances and full store is preserved. This is a sufficient conservative theorem; peers that create and later repay separate new-lane obligations are excluded, not proved unsafe.

### D5. Explicit old Atomic observation projection

Raw Atomic observations cannot be equal after adding tokens/inner receipts. Define a new protected old observation retaining label; stable restricted schedule; public balances on S and full store; outcome; and exactly one outer event on commit whose inner observations are filtered to old IDs in order. All old receipts and complete frozen output metadata are retained. Old committed supply is the sum of retained old successful receipts, not extended total supply. Aborted/refused histories and supply remain empty/zero.

For an abort at old participant with extended global position p, project its position to `length(restrict K (schedule.take p))`, retaining local index/invocation/kernel reason or lane/amount. Global pre-step position counts tokens, including skips, not attempts. For the speculative machine's processed position q use the corresponding restricted prefix length; prove the schedule-prefix binding from actual reachability. Same-roster tree/binary comparison keeps positions literally equal and does not use this normalization.

Unsettled residuals remain the entire same-policy ordered list, without principal filtering or erasing amounts. New-participant abort/admission reasons are represented as explicit `foreignAbort`/`foreignAdmission` with original identity/position/reason; a projection never converts them into success or silently discards them. The extension theorem proves those foreign cases absent from independently established premises. Outside those premises, the production observer still reports them.

Comparator correctness states equality of exactly these fields, including projected failure positions and all residual components. A diagnostic comparator separately covers full speculation, entry world, owed function at every finite lane/principal combination, position and abort; it is not substituted for public equality. Synthetic off-policy owed differences must be detected by this full comparator, even though reachable zero-start runs cannot create them.

### D6. Financial fixtures and false stronger laws

Twenty fixture contracts in `fixtures.json` use literal complete worlds/stores/receipts/outputs/positions/residuals, separately specified from candidate runners/projections. Base vaultUSD10, AliceUSD0; draw7 gives cash3,Alice7,owed(lane,Alice)=7; return7 restores10/0 and clears. Under-return6 gives diagnostic cash9/Alice1/owed1 and aborts to entry. Funded over-return8 produces signed credit−1; a later draw1 clears it. Cross-principal repayment leaves Alice+7/Bob−7 even when scalar sum0. Same authenticated principal across different streams may legitimately clear; stream IDs are not the obligation partition. Cross-asset/domain/lane-vault errors remain distinct and ordered.

A three-stream nonempty transient family has old draw7/return7 and two independent new funded EUR transfers outside S, with all policy lane cells protected. The fixed policy lists all principals on both sides. Prove new success and supply/owed neutrality from exact grants, balances, templates and boundaries, independently of the final result. Execute all12 complete schedules of lengths2,1,1; old loan observations commit identically after restriction while raw full events/worlds differ. Compare actual tree shapes under each fixed schedule. A non-lane authorized mint supplies a separate nonzero-supply projection control.

Counterexamples must include:

- One event containing AliceUSD10→Bob7 followed by refused Alice→Carol6 rolls back to10/0/0; two separately committed events retain3/7/0 after the second abort. Their event/label structure also differs. This refutes moving the outer boundary, not ordinary list associativity.
- A whole draw7/return7 clears, while inserting an inner finish after draw yields residual7 and rollback. No empty-lane example counts as transient settlement evidence.
- An added disjoint peer's kernel refusal aborts the whole batch; ordinary M5 interleaving would preserve old committed-prefix behavior.
- A new mint of USD2 to an unprotected cell still triggers the home/USD lane-supply abort, although protected writes and lane-cell effect are unchanged.
- New lane effects, changed policy/principal partition, premature nested finish, stale speculative state, wrong boundary index, continued execution after abort, or publication of aborted snapshots/supply are distinguishable by exact diagnostics and public observations.

A public follow-up starts from the previous result's publicWorld and a fresh atomic boundary/history. It cannot consume a snapshot from an aborted batch. Labels are explicit; no silent globally unique transaction-ID allocator or replay protection is claimed.

### D7. Implementation/evidence boundaries

Runtime modules and the proposed18 mutations in `planned-mutations.json` remain unimplemented. All shared runtime/proposition definitions precede `-- BEGIN PROOFS`; proof-only fixtures do not enter Audit. Reuse actual policy computation without changing old files. A finite wrapper has new code requiring genuine source mutations; a proof-only simulation has proof/counterexample evidence, not invented runtime mutation credit.

Each compiled actual mutant must execute the complete inventory, fail its designated independent semantic comparison and retain global positive controls. Protected positives are a nonempty one-call old transfer under empty lanes and a nonempty equal observation; their actual survival must be measured before production freeze. Distinct dependencies use distinct fixture computations, and measured false-check overlap is reported without promising a diagonal classifier. Compiler errors, timeouts, malformed output or empty inventory are blocked, never mutation detection.

Adapt all accepted predecessor mutation-runner controls by literal source-root/namespace/proof-marker/error-count/CLI mapping. Current historical Atomic18 mutation and65-control records do not automatically cover this new wrapper. Runner600s/harness1500s are provisional conventions to confirm against actual inherited options. Every expected fixture/control remains pending until executed with exact source/tool/command/time/raw-output bindings. Preserve original runs and failed attempts. Dynamic proof inventory separates generic, instance, counterexample and generated declarations with full types/premises/axioms; no sorry, custom axiom or native_decide in accepted new proofs.

## Risks / Trade-offs

- Matching final balances can hide settlement/abort divergence → simulate each actual appended receipt and exact owed table before final observations.
- A looser M5 projection can erase transaction failure → explicit foreign-abort variants and independently proved new success/supply neutrality.
- Principal/stream confusion can allow repayment by the wrong party → fixed authenticated-principal partition, cross-principal negative and same-principal/different-stream positive.
- New supply can violate a lane without touching its vault → separate actual checkSupply premise and mutation companion.
- Provisional APIs can change → block official freeze until accepted S10/M3/M4/M5 refresh, with exact current-field and inherited-control mapping.

## Migration Plan

Seal this author draft only. Refresh accepted predecessor identities/APIs and baseline, revise any semantic differences, then obtain nonauthor GPT-6/native Fable5.1 medium planning verdicts on the same full frozen bundle. GPT-6 stock harness implements; native Grok/Fable review actual source/evidence. Request Fable `claude-fable-5-1[1m] --effort medium`, record returned identities/unknown telemetry and preserve unavailable attempts. No Foreman. Parent owns commits/delivery/archive. No implementation, native review or new acceptance is performed in this preparation; held S10/corpus and earlier plans remain unchanged.
