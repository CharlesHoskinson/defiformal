# Insight Ledger — L1 (Spot exchange, Lending)

## 1. Protocols modelled

| protocol | category | repo path | spec file | typechecks | invariant run | verdict |
|---|---|---|---|---|---|---|
| Uniswap V2 | dex | `protocol-repos/dex/Uniswap_v2-core/` | `quint-models/L1/uniswap_v2.qnt` | yes | `lpConservation` ok (200×20) | solid — CPAMM + fungible LP |
| Uniswap V3 | dex | `protocol-repos/dex/Uniswap_v3-core/` | `quint-models/L1/uniswap_v3.qnt` | yes | `activeBounded` ok | solid — active-range abstraction; tick bitmap omitted |
| Uniswap V4 | dex | `protocol-repos/dex/Uniswap_v4-core/` | `quint-models/L1/uniswap_v4.qnt` | yes | `lockedImpliesSettled` ok | solid — deferred net settlement core |
| Raydium CPMM | dex | `protocol-repos/dex/raydium-io_raydium-cp-swap/` | `quint-models/L1/raydium_cp.qnt` | yes | `lpConservation` ok | solid — CP + multi-leg fee vaults |
| Curve Stableswap | dex | `protocol-repos/dex/curvefi_curve-contract/` | `quint-models/L1/curve.qnt` | yes | `lpConservation` ok | partial — `approxD` stands in for Newton `get_D`; Cryptoswap/repeg not modelled |
| PancakeSwap Infinity | dex | `protocol-repos/dex/pancakeswap_infinity-core/` | `quint-models/L1/pancakeswap.qnt` | yes | `lockedImpliesSettled` ok | solid for vault+delta path; LBAMM bins and CL positions not separate |
| Fluid | dex | `protocol-repos/dex/Instadapp_fluid-contracts-public/` | `quint-models/L1/fluid.qnt` | yes | `layerSolvency` ok | partial — liquidity layer + DEX inventory; slot liquidation and expand-limits abstracted |
| Aave V3 | lend | `protocol-repos/lend/aave-dao_aave-v3-origin/` | `quint-models/L1/aave_v3.qnt` | yes | `reserveSolvency`, `supplyConservation` ok | solid — single-reserve dual-index; e-mode/caps omitted |
| Morpho Blue | lend | `protocol-repos/lend/morpho-org_morpho-blue/` | `quint-models/L1/morpho_blue.qnt` | yes | `liquidityInvariant`, `shareConservation` ok | solid — isolated market share accounting |
| Compound V3 | lend | `protocol-repos/lend/compound-finance_comet/` | `quint-models/L1/compound_v3.qnt` | yes | `indicesPositive`, `borrowBounded` ok | solid for signed principal + absorb; multi-collateral reduced to one |
| JustLend V1 | lend | `protocol-repos/lend/justlend_justlend-protocol/` | `quint-models/L1/justlend.qnt` | yes | `cTokenConservation`, `cashIdentity` ok | solid — CToken exchange-rate market |
| SparkLend | lend | `protocol-repos/lend/sparkdotfi_sparklend-v1-core/` | `quint-models/L1/sparklend.qnt` | yes | `reserveSolvency` ok | solid — Aave shape + external SSR rate; rate-strategy contract not in this core repo |
| Maple V2 | lend | `protocol-repos/lend/maple-labs_maple-core-v2/` | `quint-models/L1/maple.qnt` | yes | `shareConservation`, `poolNonNeg` ok | partial — single bilateral loan + queue + cover; multi-loan managers omitted |

Shared module: `quint-models/L1/common.qnt` (typechecks).

## 2. State shapes

| shape | fields | protocols instantiating | differs by |
|---|---|---|---|
| `CPAMMPair` | `reserve0, reserve1, totalSupply/lpSupply, lpBalance` | Uniswap V2, Raydium CP | Raydium adds `protocolFees*, fundFees*, creatorFees*`; Uni V2 adds `kLast` for fee-on mint |
| `CLPool` | `price/tick, activeL, reserve0/1, posL/posLo/posHi, feeGrowth` | Uniswap V3, Pancake CL path | Pancake custody is external vault + deltas; Uni V3 holds inventory in pool |
| `DeltaSettlementScope` | `unlocked, delta0, delta1, (vault\|reserve)*` | Uniswap V4, Pancake Infinity | Uni V4 singleton PoolManager; Pancake splits Vault vs CLPoolManager |
| `StableswapPool` | `balances[], A, lpSupply, fee, adminFees` | Curve | amp A; D-invariant vs xy=k; admin fee leaves pool |
| `DualIndexReserve` | `liquidityIndex, variableBorrowIndex, totalSupplyScaled, totalBorrowScaled, userSupplyScaled, userBorrowScaled` | Aave V3, SparkLend | Spark adds `externalSSR`; Spark IRM reads SSR+spread |
| `ShareMarket` | `totalSupplyAssets, totalSupplyShares, totalBorrowAssets, totalBorrowShares, supplyShares, borrowShares, collateral` | Morpho Blue | no separate index var; interest mutates asset totals; market params immutable |
| `ExchangeRateMarket` | `cash, totalBorrows, totalReserves, totalSupply(cToken), borrowIndex, cTokenBal, borrowPrincipal, userBorrowIndex` | JustLend | one exchange rate `(cash+borrows-reserves)/supply` vs dual scaled balances |
| `SignedPrincipalComet` | `baseSupplyIndex, baseBorrowIndex, principal (signed), collateral, totalSupplyBase, totalBorrowBase, reserves` | Compound V3 | single base asset; supply and borrow are one signed field; absorb not seize-to-caller |
| `LiquidityLayerPlusDex` | `supplyIndex, borrowIndex, totalSupplyScaled, totalBorrowScaled, userCol, userDebt, dexReserve0/1` | Fluid | capital dual-uses as credit layer and AMM inventory |
| `PermissionedPoolLoan` | `cash, outstandingPrincipal, accruedInterest, totalShares, shares, queueShares, queueTotal, delegateCover, loanRateBps, loanActive` | Maple | fixed bilateral rate; no oracle in pool; exit is queue; default is delegate act |

## 3. Actions

| action | signature | protocols | preconditions | element symbol (or NONE) |
|---|---|---|---|---|
| `mint` / `deposit` (LP) | `(user, a0, a1) → shares` | Uni V2, Raydium, Curve, Uni V3 | amounts > 0; proportional (CP) or D-increase (Curve) | `Sh`, `Cp`/`St`/`Cl` |
| `burn` / `withdraw` (LP) | `(user, shares) → (a0,a1)` | Uni V2, Raydium, Curve, Uni V3 | shares ≤ bal; residual liquidity | `Sh` |
| `swap` (CP) | `(amountIn, dir) → amountOut` | Uni V2/V3/V4, Raydium, Pancake, Fluid DEX | k-hold after fee; reserves > out | `Cp` |
| `exchange` (stable) | `(dx) → dy` | Curve | fee on out; balances cover dy | `St` |
| `unlock` / `lock` | `() → scope` | Uni V4, Pancake | lock only if `deltasNetZero` | NONE (not `Fl`) |
| `settle` / `take` | `(currency) → Δ` | Uni V4, Pancake | unlocked; matching delta sign | NONE |
| `supply` / `mint` (lend) | `(user, assets) → scaled\|shares\|cTokens` | Aave, Morpho, JustLend, Spark, Comet, Fluid, Maple | assets > 0; Maple also permissioned | `Pl`/`Im`/`Sh`/`Ix` |
| `borrow` | `(user, assets)` | Aave, Morpho, JustLend, Spark, Comet, Fluid | healthy post-borrow; liquidity available | `Pl`/`Im`, `Ct` |
| `repay` | `(user, assets)` | Aave, Morpho, JustLend, Spark, Maple | debt > 0 | `Pl`/`Im` |
| `withdraw` (lend) | `(user, assets)` | Aave, Morpho, JustLend, Comet | healthy post; cash/liquidity | `Pl`/`Im`, `Ct` |
| `liquidate` | `(borrower, repay\|seize)` | Aave, Morpho, JustLend | not healthy; close-factor or seize bound | `Li`, `Ct` |
| `absorb` | `(account)` | Compound V3 | not collateralized at LF; debt written to reserves | NONE (distinct from `Li`) |
| `triggerDefault` | `()` | Maple | loan active; delegate authority | `Sv` (partial); not `Li` |
| `requestRedeem` / `processRedeem` | `(user, shares)` | Maple | queue then cash | `Wq` |
| `fundLoan` | `(principal, rateBps)` | Maple | cash ≥ principal; cover floor; not active | `Ft`, `Uc` (profile), `Aw` |
| `accrue` / `accrueBlock` | `(dt\|blocks, rate?)` | Aave, Morpho, JustLend, Spark, Comet, Fluid, Maple | dt > 0 | `Ix` / rate term |
| `externalRateUpdate` | `(ssr)` | SparkLend | ssr ≥ 0 | NONE |
| `deployToDex` | `(a0,a1)` | Fluid | free liquidity ≥ amounts | NONE |
| `shockPrice` | `(p)` | Aave, Morpho, JustLend, Comet | p > 0 | `Ex` (abstracted) |

## 4. Invariants

| invariant | formal statement | protocols it holds for | verified how | hidden assumption |
|---|---|---|---|---|
| `lpConservation` | `Σ lpBalance(u) = totalSupply` | Uni V2, Raydium, Curve | `quint run --invariant=lpConservation --max-steps=20 --max-samples=200` | no external fee mint mid-step (Uni `kLast` fee-to not modelled as minting) |
| `activeBounded` | `activeL ≤ Σ posL(u)` | Uni V3 | run ok | recomputeActive is explicit; real pool updates on tick cross inside swap |
| `lockedImpliesSettled` | `¬unlocked ⇒ delta0=0 ∧ delta1=0` | Uni V4, Pancake | run ok | model forbids lock unless settled; real code reverts unlock end if nonzero |
| `reserveSolvency` / `layerSolvency` / `liquidityInvariant` | `totalSupplyAssets ≥ totalBorrowAssets` (present value) | Aave, Spark, Fluid, Morpho | run ok | single asset; no bad-debt socialization path firing in sample (Morpho liquidate can leave residual) |
| `supplyConservation` / `borrowConservation` | `Σ userScaled = totalScaled` | Aave | run ok | no treasury aToken accrual branch |
| `shareConservation` (Morpho) | `Σ supplyShares = totalSupplyShares` (and borrow side) | Morpho | run ok | fee recipient share mint on accrue omitted |
| `cTokenConservation` | `Σ cTokenBal = totalSupply` | JustLend | run ok | no interest-during-transfer quirks |
| `cashIdentity` | `cash + totalBorrows ≥ totalReserves` | JustLend | run ok | reserves only grow via accrue reserve factor |
| `indicesPositive` | `baseSupplyIndex > 0 ∧ baseBorrowIndex > 0` | Compound V3 | run ok | — |
| `borrowBounded` | `totalSupplyBase ≥ 0 ∧ totalBorrowBase ≥ 0` | Compound V3 | run ok | **does not** assert reserves ≥ 0; absorb can model negative reserves |
| `shareConservation` (Maple) | `Σ (shares+queueShares) = totalShares` | Maple | run ok | single loan book; no share inflation from fees |
| `poolNonNeg` | cash, principal, interest, cover ≥ 0 | Maple | run ok | default writes off principal without forcing cash ≥ assets for queued exit |
| `positiveLiquidity` | `totalSupply ≥ MIN ⇒ reserves > 0` | Uni V2 | run ok | MIN abstracted to 1 |
| `vaultsNonNeg` / `nonNeg` / `balancesNonNeg` | non-negative vaults/reserves | Raydium, Fluid, Curve, Uni V4 | run ok | integer domains; no fee-on-transfer tokens |

**Invariant that required model repair during build:** early drafts of Uni V2 nested `val` bindings inside `all` failed to typecheck (scoping) — not an economic failure. Morpho's `totalBorrowAssets ≤ totalSupplyAssets` is a **code-enforced** precondition on withdraw/borrow (`Morpho.sol` insufficient liquidity), elevated to invariant in the model; it is not free-floating solvency after bad debt without the socialize branch.

## 5. Recurrences — candidate primitives

| candidate primitive | quint definition | instantiated by (n) | why it is primitive |
|---|---|---|---|
| `CONSTANT_PRODUCT_SWAP` | `common.cpAmountOut`, `cpApplySwap`, `cpKHolds` | Uni V2, Uni V3 (active), Uni V4, Raydium, Pancake, Fluid DEX (6) | same algebraic step `(x+Δin_f)·(y-Δout) ≥ x·y` with fee-on-input; only fee numerators differ |
| `PRO_RATA_SHARES` | `sharesFromAssets`, `assetsFromShares` | Morpho, Maple, Uni V2/Raydium mint, Curve mint (5+) | assets↔shares via `assets * totalShares / totalAssets` (empty-pool bootstrap) |
| `INDEX_ACCRUAL` | `presentFromScaled`, `scaledFromPresent`, `accrueIndex` | Aave, Spark, Fluid, JustLend (borrowIndex), Comet (2) (5) | `present = scaled * index / BASE`; index monotone in time×rate |
| `COLLATERALIZED_HEALTH` | `isHealthy`, `seizeCollateral` | Aave, Morpho, JustLend, Comet, Fluid (5) | `coll·price·ltv ≥ debt·price`; liquidation seizes at incentive bps |
| `UTILIZATION_TWO_SLOPE` | `utilization`, `twoSlopeRate` | Aave, Spark, Fluid, Comet (4) | util = borrow/supply; kinked base+slope1/slope2 — **rate source** differs (Spark) |
| `NET_DELTA_SETTLEMENT` | `deltasNetZero` | Uni V4, Pancake Infinity (2) | unlock scope; signed currency deltas must cancel before release — **not** flash borrow |
| `DUAL_INDEX_RESERVE` | state shape in aave/spark modules | Aave, Spark (2) | paired supply/borrow indices + scaled balances |
| `EXCHANGE_RATE_CTOKEN` | `exchangeRate` in justlend | JustLend (1; Compound V2 family) | single rate from cash+borrows-reserves — distinct bookkeeping from dual-index |
| `WITHDRAWAL_QUEUE` | Maple `queueShares`/`requestRedeem`/`processRedeem` | Maple (1 in lane; appears in other categories) | shares exit inventory without instant cash |
| `FIRST_LOSS_COVER` | Maple `delegateCover` + `triggerDefault` | Maple (1) | cover absorbs loss before pool share value |

## 6. Distinctions the 58-symbol vocabulary collapses

| element symbol | protocols | how their state machines differ | proposed split |
|---|---|---|---|
| `Cp` | Uni V2 vs Uni V3 active range vs Raydium CP | V2: full-range reserves + fungible LP. V3: `activeL` and out-of-range idle inventory; positions non-fungible by `[lo,hi]`. Raydium: same CP math but fee legs to separate protocol/fund/creator accounts (`pool.rs` fee fields), not `kLast` mint | `Cp-full-range` vs `Cp-virtual-in-range` (composition with `Cl`); fee-sink as separate parameter |
| `Cl` | Uni V3 vs Uni V4 vs Pancake CL vs Fluid ranges | V3 per-pool inventory; V4 singleton + hooks in address bits; Pancake vault split + hook bits in pool key; Fluid slot/bucket liquidation unit | split by **custody** (per-pool vs vault vs liquidity-layer) and **permission binding** (address-mined vs pool-key vs controller) |
| `Li` | Aave vs Morpho vs JustLend vs Comet `absorb` vs Maple `triggerDefault` | Aave: close-factor function of HF band + aToken seize. Morpho: incentive from LLTV formula; bad debt socialized to market suppliers. JustLend: fixed close factor. Comet: protocol absorb to reserves, not third-party race. Maple: authorised default, no bounty, cover-first | `Li-race-seize` vs `Li-protocol-absorb` vs `Li-authorised-default` |
| `Ix` | Aave dual index vs JustLend exchange rate vs Morpho asset totals vs Comet signed principal indices | Four different state machines all “accrue interest” | `Ix-dual-scaled` vs `Ix-exchange-rate` vs `Ix-mutate-totals` vs `Ix-signed-principal` |
| `Pl` | Aave shared multi-reserve risk vs Spark (same) vs Fluid layer | Aave: many reserves, cross-collateral HF. Fluid: supply is also DEX inventory. Vocabulary also has `Im` for Morpho — good split, but `Pl` still overloads shared-risk vs productive-inventory | keep `Pl`/`Im`; add `Pl-inventory-coupled` for Fluid |
| `Fl` | Uni V3 flash vs Uni V4 deltas | V3 flash is borrow-and-repay in callback. V4 unlock is **net conservation of deltas with no borrow** | do not file V4 settlement under `Fl`; new symbol (below) |
| `St` | Curve stableswap vs (unmodelled) Pancake LB constant-sum bins | Curve: hybrid amp curve continuous. LB: discrete bins, zero impact inside bin | `St-hybrid-amp` vs `St-bin-constant-sum` |
| `Ft` / `Uc` / `Sv` | Maple alone in this lane | One protocol needs fixed term **and** undercollateralised **and** servicing discretion **and** queue **and** cover; packing into a flat set loses the state machine (loan object + delegate + queue) | composite construction type, not a single symbol |

## 7. Mechanisms with no symbol

| mechanism | protocols | what it does | why no existing symbol fits |
|---|---|---|---|
| Net delta / flash accounting settlement | Uni V4 (`PoolManager.unlock`), Pancake Infinity (`SettlementGuard`) | Accrue signed per-currency deltas in transient storage; release iff all zero | `Fl` is borrow-repay; here nothing is borrowed — pure conservation law over a transaction scope |
| External rate tracking (live cross-protocol IRM input) | SparkLend | Borrow curve base/kink = spread over another protocol’s savings rate; updates without local governance tx | `Ix` is local accrual; `Ex` is price oracle, not a rate accumulator read by direct call |
| Smart collateral / smart debt (triple role capital) | Fluid | Same units: supplied to layer, posted as collateral, deployed as AMM inventory; debt side can be the inventory a swapper trades against | `Pl`+`Cp` side by side does not express identity of balances across roles |
| Multi-leg protocol fee vaults (accumulate, not burn) | Raydium CPMM | Fee split LP/protocol/fund/(creator); protocol leg accumulates in fee fields | `Fd` is distribution to a claim class; supply destruction is another residue; accumulation is a third channel |
| Hook permission locus variants | Uni V4, Pancake, Fluid | Which callbacks fire is bound in address bits (V4), pool-key bits (Pancake), or controller address (Fluid) | No hook/extension symbol at all; when added, locus must be a field |
| Expandable utilisation limits + withdrawal gap | Fluid liquidity layer | Caps relax on a schedule; gap reserved for liquidations | Not a static supply/borrow cap (`Im`/`Pl` residue in profiles) |
| Slot/bucket liquidation | Fluid | Liquidate equivalence class of positions by LTV slot, not individual NFT | `Li` assumes per-position seize |
| Permissioned pool + bilateral fixed rate + cover-ordered default | Maple | Credit terms are loan fields; default is authority; exit is queue | No single symbol; closest set `{Aw,Ft,Wq,Bs,Sv}` still misses “rate is not a function of state” |

## 8. Cross-protocol connections

| from | to | what flows | shared state | composition hazard |
|---|---|---|---|---|
| External SSR protocol (e.g. Sky/Maker savings) | SparkLend | savings rate (bps) | Spark `externalSSR` read into IRM | Spark risk freezes if upstream rate jumps; no local bound on level (profile residue; model: `externalRateUpdate` unconstrained) |
| Fluid Liquidity Layer | Fluid DEX | inventory amounts | `dexReserve*` funded from free supply | Withdrawal/borrow and swap compete for same solvency budget (`layerSolvency`) |
| Morpho Blue markets | MetaMorpho vaults (repo present, not fully modelled) | ERC4626 deposits → market supplyShares | vault is lender of record | User holds claim on vault, not on market; curator caps — composition is containment, not union of elements |
| Curve base pool LP | Curve metapool (profile; multi-pool in repo) | LP token as coin | metapool `balances` include LP | Nested invariants; virtual price dependency |
| Uni V2/V3/V4 pool price | Lending oracles (category boundary) | TWAP / spot | `Tp` consumers | Using pool as `Ex` creates oracle manipulation surface (classic composition hazard) |
| Maple pool cash | Fixed/open-term loan modules | principal out / repayment in | `cash` ↔ `outstandingPrincipal` | Illiquidity: queue cannot process if cash lent out |

## 9. Code vs prior profile disagreements

| protocol | prior profile claims | code shows | which is right |
|---|---|---|---|
| Uniswap | V4 residue: hooks + deferred settlement unnamed; arms X21 with `Fl` | `PoolManager.sol` unlock/settle is delta conservation, not flash loan; flash exists separately in V3 | Code: do not equate V4 settlement with `Fl` |
| PancakeSwap | corpus “Uniswap + emissions + mutable admin”; witness drops `Up`, adds `Gp` | Infinity: immutable vault, separate pool managers, pool-key hook bitmap (`SettlementGuard`, CLPoolManager) | Code/witness: architecture split is real; not a thin Uni fork |
| Raydium | fee channel grouped with buy-and-burn | CPMM stores `protocol_fees_*`, `fund_fees_*`, `creator_fees_*`; accumulation account in profile | Code+profile witness: accumulation ≠ burn |
| Morpho | admissible; vault curator residue | Blue: `Market` share totals; `totalBorrowAssets ≤ totalSupplyAssets` hard require; immutable `MarketParams` | Code confirms isolated market + liquidity require; vault is separate repo (MetaMorpho) |
| Maple | not admissible (truth term open); no permissionless liquidation | Modules: permission managers, loan managers, withdrawal managers; default is authorised; no pool oracle | Code confirms profile: open truth term is honest |
| SparkLend | rate tracks external SSR; element set near Aave | Core repo is Aave fork (`ReserveLogic`, `Pool`); SSR strategy lives in companion strategy contracts (not always this tree) | Profile right on mechanism; this core clone alone under-specifies IRM — model adds `externalSSR` from profile+design |
| JustLend | Compound fork; fixed close factor; unbounded rate curve write | `CToken.sol` exchange rate + `borrowIndex`; comptroller close factor | Code agrees |
| Fluid | smart debt/collateral; slot liquidation | `liquidity/common/variables.sol` packed supply/borrow×exchangePrice; operate supply/borrow | Code agrees on layer; DEX v2 singleton not fully expanded in our spec |
| Aave V3 | debt ceiling bits unused; steward residue | `ReserveLogic` indices; `GenericLogic` HF; liquidation close factor | Code agrees on core; caps/e-mode omitted in model deliberately |

## 10. Open questions for the mathematicians

1. **Settlement conservation as a primitive:** Is “signed deltas net to zero at scope close” (`NET_DELTA_SETTLEMENT`) a stratum-0 accounting primitive alongside `Sh`/`Ix`, or a composition operator over transfers? Uni V4 and Pancake share it without sharing custody layout.

2. **Identity of capital across roles:** Fluid requires a construction where one balance vector is simultaneously `Pl` supply, `Ct` collateral, and `Cp` inventory. Can the carrier express **equalizers** / pullbacks of state, or only disjoint unions of element sets?

3. **Rate as exogenous input:** Spark’s IRM is a pure function of local util **and** an external stream. Is “read foreign accumulator” a form of `Ex`, a new morphism in the category of protocols, or a parameter of `Ix`?

4. **Splitting `Li`:** Three observed state machines (race-seize, protocol-absorb, authorised-default) share “close unhealthy credit” in prose but not transitions. Should admissibility constraints quantify over the liquidation **automaton**, not the label?

5. **Interest bookkeeping variants:** Dual-index scaled balances, exchange-rate cTokens, and Morpho-style totalAssets/totalShares are interdefinable economically but generate different conservation statements. Is the primitive the **affine claim** (shares of a pool) with three presentations, or three primitives?

6. **Fee sink taxonomy:** LP-retained (k growth), admin fee leaving pool (Curve), multi-vault accrual (Raydium), burn, and distribution to lockers are five sinks. Does the model need a single “value-return” object with a sink enum?

7. **Maple as undercollateralised fixed-term:** The negative result on admissibility hinged on open truth terms. Should `At`/`Ex` be optional when credit is bilateral and off-chain enforced, and if so how does composition with on-chain `Ex` consumers work?

8. **Hook capability vectors:** Extension points differ by binding site (address, pool key, controller). Is a hook a higher-order parameter of the pool constructor (a function space), and does mining address bits make the capability part of the object’s identity?

9. **Invariant `totalBorrow ≤ totalSupply`:** Morpho enforces it as a hard require on user actions; Aave enforces it operationally via available liquidity; Maple deliberately violates “on-demand exit.” Is this a law of `Pl`/`Im`, a local axiom, or a choice of exit modality (`Wq` vs instant)?

10. **Completeness test:** From the L1 empirical set, are `{PRO_RATA_SHARES, INDEX_ACCRUAL, CONSTANT_PRODUCT_SWAP, STABLE_INVARIANT, CONCENTRATED_RANGE, NET_DELTA_SETTLEMENT, COLLATERALIZED_HEALTH, UTILITY_IRM, ISOLATED_MARKET, SHARED_RESERVE, WITHDRAWAL_QUEUE, FIRST_LOSS_COVER, BILATERAL_LOAN}` sufficient to reconstruct all thirteen specs up to constants — and if not, what is the smallest missing generator for Fluid’s triple-role capital?

---

## Source-file correspondence (traceability)

| Spec | Primary sources |
|---|---|
| `uniswap_v2.qnt` | `Uniswap_v2-core/contracts/UniswapV2Pair.sol` (reserves, mint/burn/swap, kLast) |
| `uniswap_v3.qnt` | `Uniswap_v3-core/contracts/UniswapV3Pool.sol` (slot0, liquidity, positions, feeGrowth) |
| `uniswap_v4.qnt` | `Uniswap_v4-core/src/PoolManager.sol` (unlock, settle, take, modifyLiquidity/swap) |
| `raydium_cp.qnt` | `raydium-cp-swap/.../states/pool.rs`, `curve/constant_product.rs` |
| `curve.qnt` | `curve-contract/contracts/pools/3pool/StableSwap3Pool.vy` (`get_D`, balances, fee) |
| `pancakeswap.qnt` | `pancakeswap_infinity-core/src/libraries/SettlementGuard.sol`, vault delta settlement |
| `fluid.qnt` | `fluid-contracts-public/contracts/liquidity/common/variables.sol`, userModule operate |
| `aave_v3.qnt` | `aave-v3-origin/.../ReserveLogic.sol`, `GenericLogic.sol`, `LiquidationLogic.sol` |
| `morpho_blue.qnt` | `morpho-blue/src/Morpho.sol`, `interfaces/IMorpho.sol` (`Market`, `Position`) |
| `compound_v3.qnt` | `comet/contracts/CometCore.sol` (presentValue*, principal) |
| `justlend.qnt` | `justlend-protocol/contracts/CToken.sol` (exchangeRate, accrueInterest, liquidate) |
| `sparklend.qnt` | `sparklend-v1-core/.../ReserveLogic.sol` + profile SSR mechanism |
| `maple.qnt` | `maple-core-v2/modules/*` (pool, loans, withdrawal, cover) — abstracted |
| `common.qnt` | factoring of the above |

## Modelling difficulties (credibility)

- **Curve `get_D`:** full Newton iteration not reproduced; `approxD` is a monotone stand-in. Cryptoswap repeg gate (EMA + xcp_profit) not modelled — explicit gap.
- **Uni V3 ticks:** bitmap and cross-tick multi-step swaps collapsed to price±1 and `recomputeActive`.
- **Fluid:** packed BigMath storage and expand-limit schedules not bit-faithful; smart-debt fee→debt amortization is schematic.
- **Maple:** multi-loan managers, open-term vs fixed-term, and permission manager policies reduced to one loan and a boolean gate.
- **Spark IRM:** concrete strategy bytecode may live outside `sparklend-v1-core`; exogenous SSR is profile-aligned but not line-traced to a single strategy file in this clone.
- **Pancake LBAMM / Raydium CLMM / Uni multi-hop:** out of scope for depth; noted as distinct shapes without full specs.
- **Accidentally restored:** `UniswapV2Pair.sol` was briefly overwritten during tooling error and restored via `git checkout` — protocol-repos left clean.
