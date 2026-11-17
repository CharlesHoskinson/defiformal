# Source-bound native rounded payment

`DefiKernel.Margin.Payment` supplies raw-integer payment arithmetic for the
accepted GMX source-entry boundary, pinned to gmx-synthetics commit
`a85ea3491c19c93bb4b5a002d9b358fb769b7849`. Positive primary/secondary prices are
part of the input type. Amounts retain distinct raw primary/secondary token units;
amount times its supplied price gives raw source USD. This native mathematical
API uses unbounded naturals and is not an EVM256 refinement theorem.

For cost K, primary price pC and secondary price pS, it computes A=ceil(K/pC),
spends primary output first and then position collateral, leaving primary
requirement R. It computes B=floor(R*pC/pS), then spends available secondary
output. The source residual is (B-paidSecondary)*pS. Actual returned bucket
remainders, paid quantities, both rounding terms and exact economic shortfall
are separate fields; no implicit compensation or debt forgiveness occurs.

The nine named theorems establish constructive computed bucket bounds and
conservation, ceil/floor dust bounds, the full identity
`K + ceilDust = paidPrimary*pC + paidSecondary*pS + sourceResidual + floorDust`,
a zero-residual/positive-shortfall witness, and sufficient-primary computed payment
coverage. The latter concludes actual native computed payments cover K when the
actual input primary buckets cover A. It is an arithmetic result; actual Typed
custody/payment execution and the later conditional solvency theorem remain open.

Zero source residual does not imply exact payment. With K1,pC1,pS2 and no funds,
no token is paid, source residual is 0, floor dust is 1 and economic shortfall is 1.
Positive secondary payment can also leave exact shortfall: K5,pC3,pS4,S1 pays one
secondary token, with ceil/floor dust 1/2 and shortfall 1. A separate K6,pC3,pS2,S3
case pays all three secondary tokens and fully covers the cost.

The separately bound source-helper campaign imports all 91 unchanged selected
source/dependency strings from the sealed GMX compiler input and adds one thin
wrapper calling the original internal `payForCost` and `getFundingAmount`.
Solc0.8.29+ab55807c, optimizer enabled/runs10/constantOptimizer and explicit Cancun
produce a self-contained wrapper with empty own creation/runtime linkReferences.
Eleven actual successful helper calls comprise nine payments and two funding
rounding observations; the nine exact input/six-value outputs match fresh Lean
execution. Five additional raw arithmetic Panics are retained separately. These
finite observations prove neither universal correspondence nor handler execution.
The funding observations do not implement a funding API.

The comparison domain requires every checked source intermediate to fit:
`K+pC` must fit BEFORE subtraction of 1, the secondary-conversion product must fit,
funding snapshots must be nondecreasing and mulDiv/round-up output must fit.
Positive price denominators are required. The actual K=uint256MAX,pC1 probe
panics although mathematical K+pC-1 fits. A source arithmetic failure is not the
selected financial refusal. Positive PnL realization, custody, funding claims,
ordered close/exceptional bankruptcy and selected liquidation rejection are later
operations, not inferred from this helper result.

```sh
python3 scripts/replay_margin_payment.py --toolchain /path/to/lean-4.33.0-rc2
```

With pinned project dependencies available, this builds Payment and freshly runs
12 nonempty fail-on-false native controls. It records actual tool/source hashes;
exit 0 means those controls passed, 1 means contradiction/build failure, and 3
means missing, empty, unreadable or unavailable inputs. Generic proofs, named
axiom disclosure, kernel replay and source-runtime observations are separate.
Kernel replay trusts imports and does not rerun `#eval` or confer outside
reproduction. The source campaign's exact evidence freeze includes full compiler
input/output, ABI/method identifiers, runtime, genesis, calldata, raw outputs,
per-invocation identities and retained failed compiler/configuration attempts.
Recompile its self-contained `standard-input-r3.json` with the pinned compiler;
verify empty own links and extract the fresh deployed wrapper object before
replaying its recorded EVM calls with that code and the frozen Cancun config.

The meaningful mutations execute altered API-prefix bodies without importing the
intact Payment cache: floor replaces ceil and changes actual paid buckets; another
assigns sourceRemainingCostUsd to economicShortfallUsd, falsely reporting zero
shortfall. Runtime comparison rejection and unchanged-proof compiler rejection
are distinct evidence. The original source/helper bytes remain unchanged.

[Component accounting](../../benchmarks/component-accounting/margin-payment.json)
records exhaustive hash-bound physical ranges and an incomplete shared wall
interval, not active author effort or person-hours. Full Typed bindings, funding,
realization, ordered liquidation, actual conditional solvency, universal/deployed
source refinement, external reproduction and complete P27/IV.3 remain open.
Historical reports and earlier proofs are preserved.
