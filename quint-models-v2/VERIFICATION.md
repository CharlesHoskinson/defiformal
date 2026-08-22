# quint-models-v2 — verification block

What each model asserts, and what running it reports. Reproduce from
`quint-models-v2/`. quint 0.32.0.

## The check

    quint run <model>.qnt --invariant=inv_all --max-samples=4000 --max-steps=14 --seed=0x7

Not `quint typecheck`. Typecheck is a type check, and the difference is not
academic: `usd1.qnt` minted tokens on a self-transfer --

    balances' = balances
      .put(caller, balances.get(caller) - amt)
      .put(recipient, balances.get(recipient) + amt)

where both `get`s read the original map, so with `caller == recipient` the
credit overwrote the debit and `owner` went from 10 to 20 with `totalSupply`
unchanged at 10. `quint typecheck` passed. `quint run --invariant=inv_all`
found it in 20ms at 2350 traces/second. The model is fixed; the point is which
command was capable of noticing.

## What `[ok]` is worth

`quint run` is randomised simulation. `[ok]` means no violation was found in
4000 samples of at most 14 steps from one seed. It is evidence, not a proof,
and it is not evidence at all for a state the random walk never reaches. Read
every row below as *not falsified at this budget*.

`quint verify` (Apalache) is bounded model checking and does prove the
invariant up to its step bound. A sweep of it is recorded in
`VERIFY-SWEEP.md` where it completed inside a five-minute per-model budget.

## Models

| model | `inv_all` | named component invariants |
|---|---|---|
| `apex.qnt` | ok | `inv_conservation`, `inv_bounds`, `inv_permanentLock`, `inv_positionTotals`, `inv_kMonotone`, `inv_vaultSolvent` |
| `cian.qnt` | ok | `inv_nonneg`, `inv_execute_auth` |
| `compound_v3.qnt` | ok | `inv_conservation`, `inv_bounds`, `inv_inventoryBacked`, `inv_storeFrontMargin`, `inv_noUncollateralizedBorrow`, `inv_factorOrder` |
| `curve.qnt` | ok | `inv_conservation`, `inv_bounds`, `inv_dConverged`, `inv_newtonResidual`, `inv_dSandwich`, `inv_virtualPriceGe1` |
| `deferred_claim_cluster.qnt` | ok | `inv_l5_price_auth`, `inv_l4_confirm_auth` |
| `derive.qnt` | ok | `inv_conservation`, `inv_baseConservation`, `inv_perpZeroSum`, `inv_bounds`, `inv_marginIsMin`, `inv_worstIsFirst`, `inv_auctionUnderwater` |
| `ethena.qnt` | ok | `inv_usde_accounting`, `inv_mint_authority`, `inv_reward_authority` |
| `gmx.qnt` | ok | `inv_conservation`, `inv_bounds`, `inv_impactPoolBacked`, `inv_oiMatchesPositions`, `inv_reserveFactorLive`, `inv_impactConvex` |
| `huma.qnt` | ok | `inv_conservation`, `inv_bounds`, `inv_subordination`, `inv_capWellFormed`, `inv_juniorFirstLoss` |
| `jupiter_perps.qnt` | ok | `inv_open_has_size`, `inv_liq_auth` |
| `liquity.qnt` | ok | `inv_conservation`, `inv_bounds`, `inv_listCanonical`, `inv_walkStartsAtLast`, `inv_redeemPrefix`, `inv_liquidationCovered` |
| `lista.qnt` | ok | `inv_safe_positions`, `inv_nonneg` |
| `metamorpho.qnt` | ok | `inv_conservation`, `inv_capsRespected`, `inv_nonNegative`, `inv_sharesSum`, `inv_separation`, `inv_T0` |
| `morpho_blue.qnt` | ok | `inv_conservation`, `inv_bounds`, `inv_collateralConserved`, `inv_liquidity`, `inv_incentiveDerived`, `inv_noUnbackedDebt` |
| `okx_dex.qnt` | ok | `inv_reserves_pos` |
| `polymarket.qnt` | ok | `inv_conservation`, `inv_adminNonEmpty`, `inv_bounds`, `inv_ctfBalanced`, `inv_claimsCovered`, `inv_bookWellFormed`, `inv_matchConserves` |
| `uniswap_v2.qnt` | ok | `inv_conservation`, `inv_bounds`, `inv_sqrtExact`, `inv_permanentLock`, `inv_kLastMeaning`, `inv_supplyBelowGeometric` |
| `usd1.qnt` | ok | `inv_supply`, `inv_owner_only_mint_ghost` |
| `wbtc.qnt` | ok | `inv_confirm_auth`, `inv_reject_auth`, `inv_supply_nonneg` |

19 models define `inv_all`; 19 of 19 report `[ok]`. They name 84 component
invariants between them, and 188 reachability witnesses (`wit_...`), for which
`[violation]` is the required outcome: a witness that holds is a witness that
never fired.

## The ghost authorisation invariants are not vacuous

Six invariants have the shape

    val inv_<x>_auth: bool = lastAction != "<X>" or lastActor == ROLE

restating a guard `caller == ROLE` that the same file writes a few lines above
in action `<X>`. That reads like an invariant which cannot fail, and the
obvious move is to retire it as apparatus inflating the count.

Measured instead of assumed: delete the guard each one restates and run
`inv_all`, with a control on the intact model first, because a mutation that
leaves an already-red invariant red proves nothing.

| model | invariant | control | guard deleted |
|---|---|---|---|
| `usd1.qnt` | `inv_owner_only_mint_ghost` | ok | VIOLATED |
| `ethena.qnt` | `inv_mint_authority` | ok | VIOLATED |
| `ethena.qnt` | `inv_reward_authority` | ok | VIOLATED |
| `jupiter_perps.qnt` | `inv_liq_auth` | ok | VIOLATED |
| `wbtc.qnt` | `inv_confirm_auth` | ok | VIOLATED |
| `cian.qnt` | `inv_execute_auth` | ok | VIOLATED |

All six fire. They catch the regression that deletes an authorisation guard,
which is a real check, so they stay. What they do *not* do is establish
anything about the protocol independently of the model: they assert the guard
the model itself writes. That is a limit worth stating, and it is a different
statement from "cannot fail".

## What was retired

Six definitions of the form `pure val t0_<name>: bool = true` — compile-time
constants, true by inspection, counted alongside 296 `t0_` vectors that assert
an actual computed equality. Removed from `ethena.qnt` (two),
`jupiter_perps.qnt`, `lista.qnt`, `usd1.qnt` and `wbtc.qnt`.

`lista.qnt`'s neighbouring `t0_price_2` was kept: `(100 * 2 * 100) / 80 == 250`
is a real arithmetic assertion that would fail if the rounding convention
changed, and it sits next to the removed ones only by position.
