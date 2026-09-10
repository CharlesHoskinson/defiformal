# P24 two-supplier rounding counterexample

A local EVM execution of unchanged Morpho Blue `8e26ca6a8dbc5089edcd67fb576248810fd2870a` produced a market loss of 1 base unit while two suppliers' rounded `expectedSupplyAssets` getters each decreased by 1. Their summed getter decrease is 2. This strengthens the earlier standalone arithmetic diagnostic with actual production state transitions and the pinned integrator getter.

The harness supplies 1 unit to each of two distinct supplier positions, posts 10 collateral units, and borrows 2 units through public calls at oracle price 1e36 and LLTV 0.75e18. It then sets a strictly positive oracle price of 1e10 and liquidates all 10 collateral units. The call repays 1 unit, clears remaining borrow assets and collateral, and reduces total supply assets from 2 to 1. Each supplier retains exactly 1000000 stored supply shares. The pinned `MorphoBalancesLib.expectedSupplyAssets` getter returns [1,1] before and [0,0] after. It uses the actual contract storage accessor and virtual-share rounding.

This disproves equality between market loss and the sum of these rounded before/after getter decreases for this source case. It does not prescribe an allocation policy or show how sequential withdrawals distribute the remaining asset. P24 must define its financial claims and rounding remainder explicitly; no loss-conservation theorem follows merely by summing these rounded getter differences.

Production creation/runtime bytecode matches the earlier pinned compilation. `results.json` binds the compiler, EVM executable, compiler input, runtime, and genesis. `upstream/` binds six additional files by Git blob and SHA. The execution uses the same Paris configuration as the four-case diagnostic: block 0, timestamp 1, zero IRM, no elapsed interest or fees, and upstream token/oracle mocks. Two supplier positions are distinct; the harness funds both and remains the borrower/liquidator. No supplier withdrawal was executed.

This is root diagnostic evidence awaiting independent review. It does not accept P24, its planning gate, a general loss model, or a Lean correspondence claim.
