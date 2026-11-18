# AMM library capability addendum — 2026-11-17

This source/proof record supplements the [historical competitive report](defiformal-competition-tech-strategy.html).
Its HTML, original source revision, cell labels, benchmark provenance and measured
results remain unchanged. Exact review/delivery revisions are established by the
separate repository evidence; this document gives no outside-reproduction credit.

| Historical cell | Historical status | New source evidence and scope |
| --- | --- | --- |
| `cell:amm:conservation` | unknown | `Settlement.run_correspondence` and `WordSettlement.run_correspondence` connect actual native quotes to actual Typed ledger execution, conserve each transferred asset, and prove actual pool post-reserves. |
| `cell:amm:no_arbitrage` | unknown | `Rational.round_trip_contract` and `CheckedRoundTrip.two_success_no_profit` bound native returned input in the immediate same-pool full-output reversal described below. This is separate from Typed settlement. |
| `primitive:amm` | partial: token0 arithmetic | Reusable fee-retaining exact-input rational and checked Word pool operations, actual Typed settlement, native round-trip bounds, and a fresh full-contract R2 library relation. This does not cover a complete deployed AMM protocol. |

The [rational pool](../../../lean/DefiKernel/AMM/Rational.lean) retains the full input
in its actual reserve, applies fee fraction `0 ≤ f < 1` only to the quote, and
proves constructive success, strict bounds and exact product increment. The
[checked pool](../../../lean/DefiKernel/AMM/Checked.lean) has256-bit inputs/reserves
and fee numerator/denominator, proved512/513/768-bit intermediates and one final
output floor. Its full arithmetic success/refusal domain and rational floor
correspondence are proved; these are mathematical Word semantics, not EVM refinement.

The native round-trip claims concern one pool, no intervening operation, the same
fee, and the entire first output reversed against the **actual first post-pool**.
The rational contract constructs both successes and bounds returnedX by inputX.
The [Word theorem](../../../lean/DefiKernel/AMM/CheckedRoundTrip.lean) bounds any actual
two successes, restores originalY, and constructs the reverse when the first
floored output is positive. A zero first output instead yields explicit reverse
`badAmount`; no rollback follows. There is no claim about external prices, multiple
pools, arbitrary programs/schedules, adversaries or market-wide arbitrage.

The [rational settlement](../../../lean/DefiKernel/AMM/Settlement.lean) reads pool
reserves directly from the same pre-ledger passed to actual `Typed.execute`.
The [Word settlement](../../../lean/DefiKernel/AMM/WordSettlement.lean) first checks
exact equality between Word reserve casts and those ledger cells. Both use four
asset-distinct trader/pool deltas, empty supply changes, actual authority/funding
checks, native post-reserve correspondence and per-asset total conservation.
Word actual trader gain satisfies the native rational floor interval. Pool reserves
are Word-bounded; trader wallets are nonnegative rationals without Word wallet bounds.
Zero Word output still settles the full input; its Y-debit right can be absent.
The generic funded-success theorem's three rights are stronger sufficient conditions,
while exact execution characterization retains the exact actual Typed checks.

These settlement theorems prove **single-swap** ledger correspondence/conservation;
they do not prove a Typed two-swap round-trip program executes. The no-profit claims
above are native pool theorems. Fixed trader/pool, X/Y and one-domain universes,
authentication/registry truth, initial capability assumptions and aggregate net
funding remain explicit. Errors contain no post-world and establish no rollback,
transactional atomicity, intermediate debit order, allowances or reentrancy result.

The [new R2 record](../../../benchmarks/competitive-landscape/library-replays/r2-20261117/README.md)
calls the rational library at zero fee and preserves every original unbounded
signed-rational/Number-constructor success/refusal case. Its original-contract
relation is machine checked. The old imported swap retains `new_model` provenance;
no historical timing/search campaign is replaced. Constructor-malformed tests give
no JSON/raw-parser credit. Token0 source/EVM refinement remains a separate obligation.

The new rational/Word settlement audits execute15/22 exact comparisons. Their
source-mutation runtime observations, unchanged-proof rejections, named axiom
audits and kernel replays are distinct evidence. Compiled coverage comes from
each artifact's target manifest; kernel replay trusts imports and does not rerun
`#eval`. None of this records a real outside developer's reproduction, historical
per-component authoring effort, corroborated adoption or completion of lending,
liquidation or the wider roadmap.
