# M4I — Cross-carrier invariant to obligation map

Generated: 2026-08-07T18:12:35Z
Scanner: basis/cross_invariants.py
Count: 61 invariants across 35 specs

## Obligation classes

| Class | Meaning | Lean/Quint anchor |
|-------|---------|-------------------|
| M1-Cons | conservation / solvency / covers | Interface.cons_of_portConfined, sup_not_port |
| M2-Polarity | index/share/rate directed flow | FlowPolarity.antiCaller_settle, DirectedEdge |
| M3-Binding | multi-component agreement | Nary.Agrees, Binding.union |
| M4P-FIXED | Pendle stale-index (patched) | pendle.qnt backing at true syRate |
| UNCLASSIFIED | needs hand review | — |

## Summary counts

- **M1-Cons:** 60
- **M2-Polarity:** 5
- **M3-Binding:** 4
- **M4P-FIXED:** 1
- **UNCLASSIFIED:** 1

## Adequacy note

M1-M3 are constraint/discipline models. Tags are candidates for derivation after
port/binding annotation. Sol M3 APPROVE: do not treat union_assoc as operational bowtie.

## Full table

| Lane | Spec | Invariant | Vars | Obligations |
|------|------|-----------|------|-------------|
| L1 | aave_v3 | reserveSolvency | liquidityIndex, totalBorrowScaled, totalSupplyScaled, variableBorrowIndex | M1-Cons |
| L1 | aave_v3 | supplyConservation | totalSupplyScaled, userSupplyScaled | M1-Cons |
| L1 | aave_v3 | borrowConservation | totalBorrowScaled, userBorrowScaled | M1-Cons |
| L1 | compound_v3 | borrowBounded | totalBorrowBase, totalSupplyBase | M1-Cons |
| L1 | curve | lpConservation | lpBal, lpSupply | M1-Cons |
| L1 | fluid | layerSolvency | borrowIndex, supplyIndex, totalBorrowScaled, totalSupplyScaled | M1-Cons |
| L1 | justlend | cTokenConservation | cTokenBal, totalSupply | M1-Cons |
| L1 | maple | shareConservation | queueShares, shares, totalShares | M1-Cons, M2-Polarity |
| L1 | maple | queueBounded | queueTotal, totalShares | M1-Cons |
| L1 | morpho_blue | shareConservation | borrowShares, supplyShares, totalBorrowShares, totalSupplyShares | M1-Cons, M2-Polarity |
| L1 | raydium_cp | lpConservation | lpBal, lpSupply | M1-Cons |
| L1 | sparklend | reserveSolvency | liquidityIndex, totalBorrowScaled, totalSupplyScaled, variableBorrowIndex | M1-Cons |
| L1 | sparklend | supplyConservation | totalSupplyScaled, userSupplyScaled | M1-Cons |
| L1 | uniswap_v2 | lpConservation | lpBalance, totalSupply | M1-Cons |
| L1 | uniswap_v3 | activeBounded | activeL, posL | M1-Cons |
| L1 | uniswap_v4 | token0Conservation | delta0, reserve0, user0 | M1-Cons |
| L2 | crvusd | collConservation | loans, totalColl | M1-Cons |
| L2 | liquity | debtConservation | boldSupply, troves | M1-Cons |
| L2 | liquity | collConservation | totalColl, troves | M1-Cons |
| L2 | sky | shareConservation | shares, totalShares | M1-Cons, M2-Polarity |
| L2 | usdd_psm | supplyConservation | usddSupply, userUsdd | M1-Cons |
| L2 | usdd_psm | reserveCoversSupplyWhenTin | gemReserve, tin, usddSupply | M1-Cons |
| L3 | apex | marginConserved | marginPool, traders | M1-Cons |
| L3 | apex | marginSolvent | marginPool, reserveBase, reserveQuote, traders | M1-Cons |
| L3 | convex | stakeConserved | staked, totalStaked | M1-Cons |
| L3 | convex | escrowConserved | crvEscrow, cvxCrvOf, cvxCrvSupply | M1-Cons |
| L3 | convex | rewardsBounded | rewardBudget, rewardIndex | M1-Cons |
| L3 | huma | cashBounded | availableCash, tranches | M1-Cons |
| L3 | hyperliquid | bridgeCoversPending | bridgeBalance, withdrawals | M1-Cons, M3-Binding |
| L3 | lighter | depositedCovers | l2Balances, priorityQueue, totalDeposited | M1-Cons |
| L3 | pendle | wit_staleIndexBacking | index, ptSupply, syLocked, syRate, ytSupply | M1-Cons, M4P-FIXED |
| L3 | spark | capitalConserved | deployed, totalMinted, usdsBalance | M1-Cons |
| L4 | cctp | globalSupplyConserved | messages, supply, usedNonces | M1-Cons, M3-Binding |
| L4 | cow | token0Conserved | bal0, feeSurplus0 | M1-Cons |
| L4 | cow | token1Conserved | bal1, feeSurplus1 | M1-Cons |
| L4 | kyber | tokenAConserved | balA, routerA | M1-Cons |
| L4 | layerzero | oftSupplyConserved | packets, supplyDst, supplySrc | M1-Cons, M3-Binding |
| L5 | centrifuge | shareConservation | assetEscrow, maxMint, maxWithdraw, redReq, shareSupply 1) | M1-Cons, M2-Polarity |
| L6 | azuro | inv_global_cash | condState, freeLiquidity, fund, lockedLiquidity, reinforcement 1) | M3-Binding, M1-Cons |
| L6 | azuro | inv_nonneg | freeLiquidity, lockedLiquidity, lpShares, userCash | M1-Cons |
| L6 | azuro | inv_claims_covered | condState, freeLiquidity | UNCLASSIFIED |
| L6 | grove | inv_usds_debt_covers_proxy | proxyBal, usdsDebt | M1-Cons |
| L6 | grove | inv_nonneg | proxyBal, usdsDebt | M1-Cons |
| L6 | grove | inv_rate_limits_bounded | mintLimit, transferLimit | M1-Cons, M2-Polarity |
| L6 | polymarket | inv_complementary_lock | lockedCollateral, phase, totalNo, totalYes | M1-Cons |
| L6 | polymarket | inv_collateral_conserved | collateral, lockedCollateral | M1-Cons |
| L6 | polymarket | inv_nonneg | collateral, lockedCollateral, noBal, yesBal | M1-Cons |
| L6 | polymarket | inv_locked_covers_payouts | lockedCollateral, phase | M1-Cons |
| L6 | pyusd | inv_supply_conserved | balances, totalSupply | M1-Cons |
| L6 | pyusd | inv_nonneg | balances, totalSupply | M1-Cons |
| L6 | pyusd | inv_reserve_covers | reserve, totalSupply | M1-Cons |
| L6 | usdc | inv_supply_conserved | balances, totalSupply | M1-Cons |
| L6 | usdc | inv_nonneg | balances, minterAllowed, totalSupply | M1-Cons |
| L6 | usdc | inv_reserve_covers | reserve, totalSupply | M1-Cons |
| L6 | usdg | inv_supply_conserved | balances, totalSupply | M1-Cons |
| L6 | usdg | inv_nonneg | balances, totalSupply | M1-Cons |
| L6 | usdg | inv_reserve_covers | reserve, totalSupply | M1-Cons |
| L6 | usdt | inv_supply_conserved | balances, totalSupply | M1-Cons |
| L6 | usdt | inv_nonneg | balances, totalSupply | M1-Cons |
| L6 | usdt | inv_reserve_covers | reserve, totalSupply | M1-Cons |
| L6 | usdt | inv_onchain_only | balances, totalSupply | M1-Cons |

