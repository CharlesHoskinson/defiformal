# Compiled DeFiFormal evidence for macOS arm64

Current source coverage includes all five exact-rational lending operations, a finite lifecycle replay, native rounded-payment arithmetic, actual Typed reference payment and a source-stage reference funding operation. Actual liquidation and lifecycle solvency remain open. The refresh notes below describe earlier increments; their pending-work statements apply to those earlier slices. Release acceptance remains bound by the separate publication record.

This package replays the explicit modules in `targets.txt` using the bundled Lean `leanchecker`. It contains their actual compiled import closure, all associated Lean source files, dependency revision and license records, runtime libraries, checksums, and selected accepted evidence. `manifest.json` identifies the exact source revision, checker binaries, platform and scope of each check. The package archive has an external SHA-256 in its publication record; compare that before extraction. Internal checksums detect missing or altered payload bytes, not a maliciously replaced archive plus checksum.

Extract the archive, then run from any directory:

```sh
/bin/sh /absolute/path/defiformal-evidence/replay.sh /private/tmp/my-new-replay-results
```

The results directory must be new and outside the package. This command verifies `SHA256SUMS`, checks a nonempty target inventory, then runs the bundled checker separately for each target with an empty environment except a package-first system PATH and a temporary HOME. Its working directory is unrelated to the repository and package. No repository, author cache, Lean installation, network, Python, Lake, C compiler or dependency installer is required for this replay. Logs and a summary go into the results directory. Exit 0 means all selected modules replayed, exit 3 means required evidence is missing, empty or unreadable, or platform support is unavailable, and exit 1 means bytes or replay results contradict the record.

The supported runtime is macOS arm64. The manifest records the Mach-O minimum macOS version and the actual tested host; older or other platforms are unsupported. The operating system supplies `/bin/sh`, `/usr/bin/shasum` (and its system Perl runtime), `/usr/bin/env`, `/usr/bin/uname`, `/usr/bin/mktemp`, `/usr/bin/tr`, `/usr/bin/dirname`, `/bin/mkdir` and `/bin/rm`, plus `/usr/lib/libSystem.B.dylib` and `/usr/lib/libc++.dylib`. These OS facilities and the bundled Lean runtime are trusted. Availability is checked for the command-line tools. No host Lean binary is selected. Runtime dylib dependencies were inspected during assembly; the required `@rpath` libraries are bundled.

Default `leanchecker` replays the declarations of each selected target against its imported environment. It is the same Lean kernel, **not an external verifier**. The explicit import inventory is `manifest.json`'s `modules`: each entry records its direct metadata imports, artifact parts, source hash and provenance. Imports are trusted during each target replay, including another selected module when imported. The import closure is discovered with Lean `withImportModules` and `readModuleData`, not source-text import matching. No `--fresh` replay of every dependency is claimed. Independent rebuilds are not claimed to produce byte-identical artifacts: the original five-target package review found seven different `.olean` byte hashes while all 2449 source-file hashes matched. That is a historical review observation, not a byte-reproducibility measurement of this enlarged closure. The published checksums identify this particular assembled payload; kernel replay checks its selected declarations. Kernel replay alone permits axioms; the accepted named/full axiom audits are separate evidence.

The selected behavior is the fixed raw1 vault-to-hypothetical-token0-quote workflow and its share-conversion prerequisite, the generic checked-conversion domain, the generic computed Typed deposit correspondence, existing token0 model proofs, and the finite shared-liquidity ordering replay definitions. The ordering module has 12 accepted finite source assertions: both schedules preserve the full declared ledger/capability expectations and have distinct located insufficient-funds refusals. Both branches authenticate Alice; Bob is the right transfer recipient. This archive replays the module definitions and binds the prior source/runtime controls; it does not rerun those 12 source assertions. Historical runtime, refusal and mutation records retain their original dates and scopes. Reading or replaying cached proof artifacts does not execute their source `#eval` controls. The package includes the token0 three-artifact relation and all 101 bound files, including the original source campaign archive. Its 12 source invocations (8 successes, 4 coarse reverts) and 4 model invocations remain separate. The source-refinement obligation remains unproved; that token0 relation does not establish deployed equivalence or pool settlement.

Optional Python 3 checks are available when Python is installed:

```sh
python3 /absolute/path/defiformal-evidence/recheck.py --verify-only
python3 /absolute/path/defiformal-evidence/evidence/repository/docs/correspondence/token0/verify.py
```

The first additionally checks the exact payload file inventory and metadata closure consistency. The second checks the archived token0 record bindings and ABI/value observations; it does not run EVM. Python is not required by the shell proof replay. Some historical review/result records refer to raw logs not bundled here; those references remain source-revision evidence, not package-alone replay promises. The full token0 101-file binding set is bundled. Selected ordering and AMM control records include raw nonempty traces and error diagnostics; zero-byte ancillary streams remain identified by their hashes in the source-revision control records. The original v0.2.0, v0.2.1, v0.3.0, v0.4.0, v0.5.0 and v0.6.0 publication records are included; this refresh has its own source revision and artifact identity. The original P18 validator needs its separately pinned `jsonschema` dependency and is not promised by the bare package.

Assembly uses an already built checkout and pinned native Lean toolchain:

```sh
python3 tools/compiled-evidence/build.py --repo /absolute/checkout \
  --toolchain /absolute/lean-4.33.0-rc2-darwin_aarch64 \
  --output /private/tmp/new-package --archive /private/tmp/new-package.tar.gz
```

The builder does not install dependencies or rebuild/runtime-test source. Target modules are listed explicitly in `targets.json`; add a target there when a later integration needs evidence and regenerate/review the package. It fails on empty targets or missing required artifacts, copies only actual metadata imports, binds current original source bytes to the source revision, and preserves source headers and original licensing. Original repository code follows the scoped root Apache grant; Lean and dependency notices are retained separately. No ownership is inferred from file location.

A new source-bound tag/release establishes this artifact's publication identity; it does not modify `v0.1.0`. Author and reviewer relocations are engineering verification. A real outside developer's setup time and outcome have not been recorded, so the third-party reproduction criterion and corroborated adoption remain open.

The package also replays the rational AMM model and its audit definitions. Its constructive success, exact retained-fee product increment and same-pool full-output round-trip bound are proved under the declared positive-reserve/input and fee assumptions. Sixteen finite controls and separate model/proof mutations remain recorded executions. Kernel replay does not rerun them. Actual Typed single-swap settlement and conservation are included in this refresh. The checked Word two-success round-trip theorem and full R2 library relation are included as described below.

This refresh was assembled by root from the independently verified source/build copy at the recorded commit. Previously observed cache-byte differences are allowed; this archive does not promise unchanged compiled bytes relative to earlier releases. Its own source identities, checksums and replay results are authoritative.

The checked Word targets add generic constructive success and exact refusal conditions, proved 512/513/768-bit intermediates, correspondence to the rational quote with one final output floor, and actual post-reserve bounds and product nondecrease. Positive reserves/input, a proper fee pair and input-reserve headroom define the admissible domain. Zero output is permitted; reversing zero output refuses. This is a widened mathematical Word model, with no EVM256 or deployed-source equivalence claim. Fifteen finite controls, separate model/proof mutations and public CLI defect controls are recorded execution evidence. The archive replays compiled declarations and does not rerun those source controls.

Optional accepted R2 replay artifacts can be included with `--r2-replay DIR`.
The builder checks the exact three source recipes against the repository revision,
the recorded Lean identity and all nine command/log records, and bundles their
existing compiled artifacts. Selected `R2Replay` and `OriginalContractRelation`
replace production R2 targets to avoid duplicate declarations. `SwapModel` is a
trusted imported compatibility dependency. The effective target inventory and
original configuration are both retained, with transformations in `manifest.json`.
Only those two additional top-level module names are allowed by the shell; the
optional Python checker is unchanged. This reuse binds recorded execution and
artifact bytes, not a new reproducible-build or source-to-binary refinement proof.

This refresh selects twenty-one modules: the prior eighteen, plus `DefiKernel.Lending.Types`, `DefiKernel.Lending.Repay` and `DefiKernel.Lending.RepayAudit`. The Word theorem proves the actual two-success returned-input bound and reserve restoration; it separately proves zero-output reverse refusal and positive-output reverse headroom. Its nine recorded source controls are not rerun by compiled replay. The R2 relation covers every formal Number constructor and signed rational input of the unchanged original model; it gives no JSON parser credit. `manifest.r2_replay.target_recipe.removed` records the two excluded production module names as policy; the exact measured target change is given by `source_targets` and `effective_targets`. No compiled module is renamed. Source transformations and original execution logs are explicit provenance, not a source-to-binary refinement proof.

The settlement targets connect native quotes to actual four-delta Typed transfers, empty supply changes and per-asset conservation. Rational quotes read the actual pre-ledger pool cells; the Word wrapper first checks exact raw-scale1 reserve compatibility. Word post-reserve casts and the rational floor interval constrain the actual trader gain. Zero Word output still transfers the full input and can succeed without a pool-Y debit right; the generic three-right funded-success theorem gives stronger sufficient conditions. Trader wallets are nonnegative rationals, without Word wallet bounds. These are single-swap settlement results; native same-pool round-trip bounds remain separate and no Typed two-swap execution theorem is claimed. Authentication/registry truth, initial capabilities and aggregate net funding are explicit framework assumptions. The fifteen rational and twenty-two Word runtime assertions and distinct model/proof mutations are recorded evidence, not rerun by compiled replay. The dated AMM capability addendum preserves the historical report and names the exact three cells and scope. A complete lending lifecycle and liquidation remain separate work; first repayment is described below.

The first lending operation performs capped cash repayment and matching debt/supply burn through actual Typed execution. It binds the selected borrower to the authenticated context, proves cash/collateral conservation and debt-total reconciliation, and preserves other custody cells. Quantified funded success derives actual validity from amount/debt bounds, cash funding and operation-scoped rights. Repayment has no oracle or health-restoration prerequisite; partial repayment of an unhealthy position is allowed. Over-repayment has a conditional exact guard-refusal theorem; insufficient cash has a generic non-success theorem and a separate finite exact-refusal observation. Native capability provisioning, seventeen source assertions and two actual wrong-ledger mutations are recorded evidence. Historical borrow/debt-burn examples remain unchanged. The reference universe has two borrowers, a shared cash pool and distinct same-asset custody accounts. Borrow, accrual and both collateral movements in this API remain unaccepted by this slice, so the full lending task remains open.

## Borrow evidence refresh

The next refresh adds `DefiKernel.Lending.Oracle`, `Support`, `Borrow` and
`BorrowAudit` to the selected modules. Actual borrower-bound execution transfers
pool cash and issues matching debt. Its post-debt health bound uses actual locked
custody and an explicit well-typed observed price; freshness, oracle authenticity
and clock assumptions remain documented in `docs/examples/lending-borrow.md`.
Constructive success discharges execution checks from explicit policy, pool
funding and operation-scoped rights. Twenty-five source controls and separate
wrong-health/wrong-cash mutation evidence are recorded, not rerun by compiled
replay. Repayment remains included. Accrual and collateral movement remain open,
so this refresh does not complete IV.4. Historical effort, outside reproduction
and deployed-source equivalence are not claimed.

## Accrual evidence refresh

The next refresh adds `DefiKernel.Lending.Accrue` and `AccrueAudit`. Actual
execution changes only borrower debt and its signed supply, using the per-call
formula `D*(1+r*dt)`. It has no health guard or persistent accrual timestamp.
Repeating the same interval compounds again; rate/interval authenticity, units
and nonoverlap remain assumptions. The first fixture crosses the collateral
ratio threshold at zero equity, while the repeated fixture has negative equity.
Twenty-one source controls and separate elapsed-time/negative-parameter mutants
are recorded, not rerun by compiled replay. Collateral deposit and withdrawal
and IV.4 remain open; see `docs/examples/lending-accrue.md` for exact scope.

## Collateral deposit evidence refresh

The next refresh adds `DefiKernel.Lending.DepositCollateral` and its audit.
Actual execution moves collateral from the bound borrower's free wallet into
that borrower's custody, with no supply, cash or debt change. Constructive
success uses nonnegative quantity, actual free funding and invocation/debit
rights. There is no oracle or health guard. Non-worsening health is an algebraic
result at an explicitly supplied nonnegative price. Eighteen source controls
and a real wrong-custody mutation are recorded, not rerun by compiled replay.
Withdrawal and final lending acceptance remain open; see
`docs/examples/lending-deposit-collateral.md` for exact scope.

## Complete scoped lending source refresh

This refresh adds `WithdrawCollateral`, `WithdrawCollateralAudit` and
`LifecycleAudit`. Actual withdrawal checks owner, locked quantity, positive fresh
price and remaining-collateral health, with constructive success and exact
qualified policy refusal. The separate finite lifecycle executes all five public
operations on one ledger with thirteen actually issued noncolliding capability
IDs, checks exact stage/final ledgers and totals, and catches cross-operation
permission misuse. Its eight controls are finite evidence, not a universal
lifecycle theorem. Twenty-seven withdrawal controls and ten public CLI negatives
are recorded separately. Compiled replay does not rerun these source controls.

The dated lending addendum marks `primitive:lending` supported within this
exact-rational reference API. It does not claim market solvency, an indexed
accrual clock, oracle authenticity, deployed equivalence, historical author
effort, outside reproduction or adoption. The old report/proofs remain intact.
Final IV.4 closure additionally requires this package's verified publication.

## Native rounded-payment evidence refresh

This refresh adds `DefiKernel.Margin.Payment` and `PaymentAudit`. Generic
raw-natural payment proofs establish primary ceil and secondary floor bounds,
exact bucket reconciliation, two-dust accounting, a zero-source-residual
shortfall witness, and arithmetic coverage under sufficient primary funds.
They do not establish actual Typed payment execution or liquidation solvency.

Twelve native source controls and two meaningful mutations are recorded
separately. A thin wrapper calls the unchanged pinned GMX pure helpers: eleven
successful source values and five raw arithmetic Panics remain distinct. Nine
exact payment cases match six observed Native/source outputs. These finite
observations do not prove universal EVM256 or full-handler correspondence.
Source residual, rounding dust and economic shortfall remain separate.

The archive binds source/compiler inputs, raw observations and native tool
identities and licenses. External Solidity/EVM/Go payloads are not bundled;
the compiled proof replay does not rerun helper calls or source controls.
Original third-party terms, including GMX BUSL-1.1, are preserved. Actual
Typed custody/funding/realization, ordered liquidation, separate solvency,
historical effort and outside reproduction remain open.

## Actual reference payment evidence refresh

This refresh adds `DefiKernel.Margin.Types`, `PaymentSettlement` and
`PaymentSettlementAudit`. The primitive binds all three raw input buckets to
the same pre-ledger cells, derives available funding from native bounds, and
executes real permission-checked transfers to a declared reference recipient.
Generic proofs establish actual remainders, recipient gains, complete outside
frame, per-asset conservation, two-dust reconciliation and the positive-part
economic shortfall. Constructive sufficient-primary coverage proves actual
recipient gains cover this one cost using explicit invocation/debit rights.

Twenty-two source controls, two meaningful mutations and public runner negatives
are separately recorded; compiled replay does not execute them. Claim-counter
assets stay separate and cannot supply these physical payment buckets. A
successful partial payment may retain source residual or economic shortfall.
The reference recipient and mismatch guard are not GMX destination or selected
financial-refusal refinements. Funding, realized PnL, ordered close and separate
lifecycle solvency remain open. See `docs/examples/margin-payment-settlement.md`.

## Reference funding evidence refresh

This refresh adds `DefiKernel.Margin.Funding` and `FundingAudit`. Rounded fee
and pending owner claims derive from explicit position size, factor snapshots
and latest observations. Actual payment uses the same bound ledger buckets,
then separately records a holding collateral claim when secondary tokens paid.
The holding role key is distinct from the owner funding-claim keys; physical
tokens and claim counters remain separate. Owner claims and latest snapshots
remain pending until a separate caller commit. Real invocation, debit and
claim-counter issuance rights construct successful execution.

The actual effect, frame, conservation and two-dust theorems remain separate
from the restricted primary-paid marked-equity theorem, which charges the fee
once. Twenty-one source controls, three actual mutations, public CLI negatives
and seven fresh helper/native rounding comparisons are recorded separately.
The unchanged pinned Solidity wrapper/runtime was reused for those calls;
compiled replay reruns none of them and claims no new full-handler execution.
Primary collateral is selected as the long token, secondary as the short token.
Computed factors and PnL/impact remain upstream observations. Funded close-PnL
realization, ordered liquidation and separate lifecycle solvency remain open.
See `docs/examples/margin-funding.md` for the exact receipt and claim scope.
