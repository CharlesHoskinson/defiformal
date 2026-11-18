# Conditional source branch observations

The final adapter is P27BranchProbe.sol; compile-r2.py/standard-input-r2.json and
standard-output-r2.json bind its fresh solc0.8.29 Cancun compile. All 91 original
source strings match the accepted prior compiler input byte-for-byte. The new
wrapper has empty creation/runtime linkReferences. P27BranchProbe-r1.sol and
compile-r1 records preserve the earlier successful adapter before adding route
flags and observable priority reasons. They are not the final runtime.

The wrapper contains exact excerpts bound in excerpt-bindings.json. Explicit
upstream stubs provide already-computed collateral value inputs, marked PnL,
capped impact, health fee tokens, minimum-collateral/leverage thresholds and
configured holding address. It does not calculate source oracle/market health
inputs. P27ObservedStore is a pure observation stub, not the original DataStore.
The selected liquidation order predicate uses actual Order helpers; ADL does not
bypass a liquidation guard. The early-return method is reached conditionally with
positive residual after admission; it does not itself perform admission or payment.

getFundingAmount, payForCost and getEmptyFees are actual unchanged internal GMX
calls. Holding claim increments and warning flags are projected expected branch
metadata; source storage updates/events are not executed. The allowed early-return
projection skips source event emissions and returns the actual getEmptyFees
projection. It is not full original handleEarlyReturn/processCollateral execution.
No full handler, later caller/output work, source simulation or deployed identity
is claimed. The frozen Lean funding API supplies three fresh six-value comparison
pairs; owner/holding ledger effects remain reference-model proofs, not EVM storage
refinement. Admission/close model comparisons beyond these are still pending.

The 23 actual EVM invocations are 16 successful values, six exact financial reverts
and one arithmetic-domain Panic. Financial bytes preserve source error selectors
and complete canonical ABI arguments; zero VM process exit is not semantic success.
All calldata/raw stdout/stderr and tool/runtime/genesis hashes are retained. Native
negative/timeout/infrastructure/malformed observations cannot enter these counts.
The unsigned factor-underflow Panic is outside the successful comparison domain.
Each source uint/int intermediate must fit; no unbounded arithmetic equivalence
is inferred.

The runtime is the newly compiled wrapper runtime, never the prior helper runtime.
The source error signature selectors are independently exposed by the compiler's
P27ErrorSignatures interface and matched against actual source error ABI entries.
The Solidity source and copied source excerpts retain BUSL-1.1/upstream terms;
root Apache licensing does not relicense these derived source-evidence bytes.
Original dependency notices remain unchanged in the standard compiler input.

Recompile by passing standard-input-r2.json to the exact pinned solc --standard-json
and compare the selected P27BranchProbe output/empty links. run.py records the
explicit pinned EVM binary, Cancun genesis, newly compiled runtime and every
invocation. Existing invocation directories intentionally prevent overwriting old
campaigns; use an isolated copy/new output location for reproduction. Native
replay requires the accepted Funding module and pinned Lean/dependency cache.
This is author/reviewer evidence, not outside reproduction.
