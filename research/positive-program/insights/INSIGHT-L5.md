# Insight Ledger — L5 (Tokenised real-world assets, Options and structured products)

## 1. Protocols modelled

| protocol | category | repo path | spec file | typechecks | invariant run | verdict |
|---|---|---|---|---|---|---|
| Ondo USDY | rwa | `protocol-repos/rwa/ondoprotocol_usdy/` | `quint-models/L5/ondo.qnt` | yes | `mintAccounting`, `balancesNonNeg` ok (200×20) | modelled |
| Centrifuge | rwa | `protocol-repos/rwa/centrifuge_protocol/` | `quint-models/L5/centrifuge.qnt` | yes | `shareConservation` ok (200×20) | modelled |
| Hegic | opt | `protocol-repos/opt/hegic_contracts/` | `quint-models/L5/hegic.qnt` | yes | `writeSolvency`, `lockAccounting` ok (200×20) | modelled |
| Derive | opt | `protocol-repos/opt/derivexyz_v2-core/` | `quint-models/L5/derive.qnt` | yes | `settlementCorrect`, `cashNonNeg` ok (200×20) | modelled |
| Panoptic | opt | `protocol-repos/opt/panoptic-labs_panoptic-v2-core/` | `quint-models/L5/panoptic.qnt` | yes | `assetShareConsistency` ok (200×20) | modelled |
| BlackRock BUIDL | rwa | *(not cloned)* | — | — | — | profile-only |
| Circle USYC | rwa | *(not cloned)* | — | — | — | profile-only |
| Maple | rwa | *(not cloned)* | — | — | — | profile-only |
| Rysk | opt | *(not cloned)* | — | — | — | profile-only |
| Aevo | opt | *(not cloned)* | — | — | — | profile-only |

Shared module: `quint-models/L5/common.qnt` (typechecks).

Difficulties worth recording:
- **Ondo** redemption payout is not conserved against on-chain escrow: `claimRedemption` pulls from an off-chain `assetSender` inventory (`RWAHub.sol:287–291`). The model must invent `assetSenderBal`; without it there is no on-chain conservation invariant tying rwa supply to collateral.
- **Centrifuge** fulfillment price is issuer-chosen and may diverge from the posted `nav` (`fulfillDepositRequest` sets `depositPrice` independently of `spoke.pricePoolPerShare`). Share conservation holds; NAV fidelity does not.
- **Derive** matching is off-chain; only settlement, cash, and liquidation are on-chain. The model’s `openOption` is a stand-in for a CLOB fill that never appears in `src/`.
- **Panoptic** true solvency is a cross-collateral, multi-oracle-tick check (`RiskEngine.isAccountSolvent`); the model collapses it to share-value ≥ util-scaled requirement. Force-exercise fee math (exponential decay) is abstracted to a constant fee.

## 2. State shapes

| shape | fields | protocols instantiating | differs by |
|---|---|---|---|
| `AsyncRequest` | `owner, amount, price, phase ∈ {Empty,Pending,Priced,Claimed}` | Ondo deposits+redemptions; Centrifuge depReq+redReq | Ondo burns shares at redeem *request*; Centrifuge burns at *fulfill*. Ondo prices by discrete priceId; Centrifuge by batch execution price. |
| `PostedPrice` | `value, updatedAt` | Centrifuge nav; Ondo via Pricer priceIds (modelled as price field on request); USYC/BUIDL profiles | Who may write (role vs hub message); BUIDL has *no* on-chain price (par assumed). |
| `ReservedBook` | `totalLocked, lockedPremium, balance, coverAvailable` | Hegic OperationalTreasury; Rysk profile (per-position escrow, cover=0) | Hegic: pool-level aggregate gate. Rysk: per-trade full escrow, no shared book. |
| `MarginAccount` | `cash, mtm, maintenance` | Derive CashAsset+PMRM; Aevo profile | Scenario families (PMRM_2 vs Aevo 15-scenario); SM vs insurance+ADL. |
| `ShareSupplyLedger` | `totalSupply` / `shares: user→int` | Ondo rwaSupply; Centrifuge shareSupply+shares; Panoptic totalShares+shares; Maple/USYC profiles | NAV-priced mint (Ondo/Centrifuge) vs ERC4626 totalAssets (Panoptic) vs yield-via-mint (BUIDL profile). |
| `OptionPos` (European) | `isCall, strike, size, isLong, phase, settledPayout` | Derive OptionAsset; Aevo profile; Hegic position as locked max-loss (no strike in treasury) | Derive/Aevo: explicit strike+cash settle. Hegic: strategy-opaque negativePNL. Panoptic: *no* strike/expiry — tick range. |
| `ChunkPosition` (AMM-range) | `side ∈ {Long,Short,Flat}, notional` | Panoptic only among modelled set | Manufactures option-like payoff from Uniswap CL; no European fixing. |

## 3. Actions

| action | signature | protocols | preconditions | element symbol (or NONE) |
|---|---|---|---|---|
| `requestSubscription` / `requestDeposit` | `(user, assets)` | Ondo, Centrifuge | amount > min; not paused; identity gate (Aw, out of model) | Rd (partial), Aw (gate) |
| `setPrice` / `fulfillDeposit` | `(id, price)` | Ondo, Centrifuge | request Pending; price > 0 | Sv (issuer determination), At (weak) |
| `claimMint` / `claimDeposit` | `(id)` / `(user, shares)` | Ondo, Centrifuge | Priced / maxMint ≥ shares | Sh, Rd |
| `requestRedemption` / `requestRedeem` | `(user, shares)` | Ondo, Centrifuge | shares ≥ min; balance | Rd |
| `claimRedemption` / `claimRedeem` | `(id)` / `(user, assets)` | Ondo, Centrifuge | Priced + inventory; maxWithdraw | Rd |
| `postNav` | `(price, t)` | Centrifuge | price > 0 | At / Sv |
| `buy` / `openOption` | lock max-loss or open margin position | Hegic, Derive, Rysk profile | Hegic: capacity gate; Derive: margin solvent | Op, Ct (Derive), NONE for Hegic Ct |
| `payOff` / `settle` | exercise or cash-settle | Hegic, Derive | before expiry (Hegic) / after TWAP lock (Derive) | Op |
| `unlock` | release reservation post-expiry | Hegic | now > expiration | Op lifecycle |
| `deposit` / `withdraw` cash or shares | `(user, amt)` | Derive CashAsset; Panoptic CollateralTracker | post-withdraw solvent | Sh (Panoptic), NONE (cash ledger) |
| `mintShort` / `mintLong` | open CL chunk | Panoptic | util ≤ cap; collateral ≥ util req | Cl, Op, Ct |
| `burn` | close chunk | Panoptic | open position | Op |
| `liquidate` | close insolvent | Derive (DutchAuction), Panoptic (dispatchFrom) | margin/share insolvent | Li |
| `forceExercise` | seller forces long | Panoptic | target long; fee paid | NONE (no symbol for force-exercise) |
| `socialize` | haircut cash supply | Derive CashAsset temp fee | SM empty | Sl |
| `lockPool` | guardian halt | Panoptic | admin | Gp |

## 4. Invariants

| invariant | formal statement | protocols it holds for | verified how | hidden assumption |
|---|---|---|---|---|
| `mintAccounting` | `rwaSupply = Σ sharesFromNav(claimed deposits) − Σ burned redeem amounts` | Ondo | `quint run --invariant=mintAccounting` | Redeem burn is immediate at request (`RWAHub.sol:248`); deposit mint only at claim. Price IDs once set are final. |
| `balancesNonNeg` | `rwaSupply ≥ 0 ∧ collateralEscrow ≥ 0 ∧ assetSenderBal ≥ 0` | Ondo | `quint run` | `assetSenderBal` is off-chain inventory — not an on-chain variable. |
| `shareConservation` | `shareSupply = Σ userShares + Σ pendingRedeem.shares ∧ all non-neg` | Centrifuge | `quint run` | Fulfill burns exactly request amount; no partial fulfill in model (code allows partial). |
| `navPositive` | `nav.value > 0` | Centrifuge | stated; always true under `canPostPrice` | Admin never posts zero (code may allow invalid price with `checkValidity=false`). |
| `writeSolvency` | `totalLocked + lockedPremium ≤ balance + coverAvailable` | Hegic | `quint run` | Holds after every transition because writes are gated and unlock/payOff release before paying. **This is the L1:Ct discharge-by-construction.** |
| `lockAccounting` | `totalLocked = Σ locked.maxLoss ∧ lockedPremium = Σ locked.premium` | Hegic | `quint run` | Single book; no per-strategy invariant checked. |
| `settlementCorrect` | settled payout = ±`europeanPayoff(isCall, S, K, qty)` | Derive | `quint run` | Settlement price locked before settle; matches `OptionAsset._getSettlementValue`. |
| `cashNonNeg` | `account.cash ≥ 0 ∧ securityModule ≥ 0 ∧ cashSupply ≥ 0` | Derive | `quint run` | Model floors cash at 0 and diverts deficit to SM; real code allows temporary negative cash with socialized exchange rate. |
| `assetShareConsistency` | `totalShares = 1 + Σ userShares ∧ deposited≥0 ∧ inAmm≥0 ∧ deposited+inAmm ≥ 1` | Panoptic | `quint run` | Ignores interest (`unrealizedGlobalInterest`) and `s_creditedShares` from long credit — full invariant in `invariants.md` is stronger. |
| *(profile)* escrow ≥ max payoff at write | Rysk | not run | no repo | Max-loss fully posted; no maintenance path exists. |
| *(profile)* share = cash at par; yield via mint | BUIDL | not run | no repo | Par assumption is off-chain policy, not an invariant the chain can check. |

## 5. Recurrences — candidate primitives

| candidate primitive | quint definition | instantiated by (n) | why it is primitive |
|---|---|---|---|
| `NAV_PRICE_EXCHANGE` | `sharesFromNav` / `assetsFromNav` in `common.qnt` | Ondo, Centrifuge, USYC profile, Maple share value (3+ code/profile) | Same pure map `(assets, price) ↔ shares` recurs; protocols differ only in who writes `price` and whether mint is sync or async. |
| `ASYNC_REQUEST_CLAIM` | `AsyncRequest` + `applyRequest/Price/Claim` | Ondo, Centrifuge (2 code); Maple queue is different (Wq) | Two-phase (or three-phase) invest flow with issuer pricing is the RWA mint/redeem core, not a special case of `Wq`. |
| `ADMIN_POSTED_PRICE` | `PostedPrice` + `applyPostPrice` | Centrifuge, Ondo priceIds, USYC profile | Single writer, no challenge bond, no deviation bound — distinct from `Ex` (external oracle) and `Oa` (optimistic assert). |
| `FULLY_RESERVED_WRITE` | `ReservedBook` + `canReserve`/`applyReserve` | Hegic, Rysk profile (2) | Solvency discharged at write by locking max loss; eliminates `Ct`/`Li` paths. Vocabulary has no symbol for “reservation gate replaces margin”. |
| `CASH_SETTLED_EUROPEAN` | `europeanPayoff` / `signedSettlement` | Derive, Aevo profile, Hegic cash payoff (3) | Unit payoff formula is shared; underwriting and margin differ. `Op` names the payoff but not the settlement style (cash vs physical). |
| `PORTFOLIO_CASH_MARGIN` | `MarginAccount` + `isMarginSolvent` | Derive, Aevo profile (2) | Cash + MTM ≥ maintenance is the shared hinge; scenario engines are interchangeable plugs. |
| `UTILIZATION_COLLATERAL` | `utilCollateralReq` / `utilization` | Panoptic (strong), Hegic capacity gate (weak) | Collateral (or write admission) scales with pool util. Panoptic re-prices open margin; Hegic only gates new writes. |
| `SHARE_SUPPLY_LEDGER` | `canMintSupply`/`applyBurnSupply` | Ondo, Centrifuge, Panoptic, all RWA profiles | Universal mint/burn conservation substrate under every share-claim protocol. |

## 6. Distinctions the 58-symbol vocabulary collapses

| element symbol | protocols | how their state machines differ | proposed split |
|---|---|---|---|
| `Op` | Derive, Aevo, Hegic, Rysk, Panoptic | (1) European cash-settled with strike+expiry (Derive/Aevo); (2) strategy-opaque max-loss lock, exercise window, peer-to-pool (Hegic); (3) full physical/cash escrow bilateral (Rysk); (4) *no* strike/expiry — CL tick-range perpetual (Panoptic) | Split `Op` into `Op-EuroCash`, `Op-ReservedPool`, `Op-FullEscrow`, `Op-CLRange` (or make payoff construction a separate primitive from underwriting). |
| `Ct` | Derive/Aevo (scenario margin), Panoptic (util-scaled), Hegic/Rysk (absent — discharged by construction) | Threshold test on open positions vs write-time capacity inequality vs *no test exists* | `Ct` should not be required of `Op` subjects that carry `FULLY_RESERVED_WRITE`; L1’s `(Ct)` term is the source of Hegic/Rysk false rejections. |
| `Rd` | Ondo/Centrifuge (async priced claim), USYC (teller, operator-pushed liquidity), BUIDL (transfer-agent books authoritative), Maple (FIFO Wq) | Four different redemption machines share one symbol | Split: `Rd-AsyncNAV`, `Rd-Teller`, `Rd-TransferAgent`, keep `Wq` for Maple-style queue. |
| `At` | Centrifuge (hub-posted number, no attestation of holdings), USYC (daily NAV behind aggregator), BUIDL (none), Ondo (priceId from admin) | “Attestation” implies independent reserve statement; code shows admin price post | Split `At` (independent reserve attest) from `ADMIN_POSTED_PRICE` / `Sv` price determination. |
| `Sh` | Ondo debt-token mint count, Centrifuge fund share, Panoptic ERC4626, BUIDL yield-via-mint | Pro-rata pool claim vs debt token vs share that mints yield | `Sh-ProRataNAV` vs `Sh-DebtClaim` vs `Sh-YieldMint` — Ondo USDY is issuer debt, not pro-rata fund share (profile residue). |
| `Bs` | Hegic CoverPool (real first-loss), Derive SecurityModule (owner treasury, no slash), Rysk (none), Maple first-loss module (empty in profile) | Staked slashable bond vs owner wallet vs absent | `Bs` should require slash/stake; owner-funded SM is `Sl` support or a new `TreasuryBackstop`, not `Bs`. |

## 7. Mechanisms with no symbol

| mechanism | protocols | what it does | why no existing symbol fits |
|---|---|---|---|
| Write-time max-loss reservation gate | Hegic (`_lockLiquidity` L113–117), Rysk profile | Admits a write iff `totalLocked+premium ≤ capacity`; no later margin call | Not `Ct` (no ongoing threshold), not `Rl` (resource lock is cross-domain), not `Bs` (not a stake). |
| Force-exercise of out-of-range long | Panoptic `dispatchFrom` force-exercise path | Seller pays decaying fee to reclaim liquidity from buyer’s long chunk | Not `Li` (target need not be insolvent); not exercise in the European sense. |
| Issuer-set batch execution price ≠ published NAV | Centrifuge `fulfillDepositRequest` / `fulfillRedeemRequest` | Execution price chosen at fulfill, weighted into `depositPrice`/`redeemPrice` | `Sv` is closest but too broad; no symbol for “fulfillment price independence from oracle”. |
| Off-chain inventory paymaster (`assetSender`) | Ondo `claimRedemption` | Redemption USDC is `transferFrom(assetSender, user)` — hub holds no reserve | Not `Rd` alone; redemption solvency is an off-chain credit line. Closest miss: `Of` (optimistic fill) is cross-domain. |
| Register-of-record duality | BUIDL, USYC profiles; Centrifuge “prima facie evidence” | Token is mirror or evidence; transfer agent / fund books are authoritative | Nothing in G13–G14 names dual ledgers or legal register supremacy. |
| CL-range-as-option construction | Panoptic SFPM long/short chunks | Option payoff assembled by adding/removing Uniswap CL liquidity | `Cl` + `Op` listed separately; no constructor “Op := f(Cl)”. |
| Settlement TWAP lock window | Derive `SETTLEMENT_TWAP_DURATION = 30 min` | Settlement price is time-average locked at expiry | `Tp` is generic TWAP; the *binding settlement lock* with mark migration is specific and unnamed. |
| Partial global pause (messaging only) | Centrifuge profile / Root | Halts cross-chain messages; local deposit/redeem continue | `Gp` is monolithic pause; no partial-domain pause. |

## 8. Cross-protocol connections

| from | to | what flows | shared state | composition hazard |
|---|---|---|---|---|
| Ondo/USYC/BUIDL RWA token | Derive/Aevo margin (CashAsset / aeUSD) | RWA as collateral | price feed for RWA NAV inside margin engine | NAV is admin-posted and stale; margin `Ct` trusts `At`/`Sv` that has no dispute window. |
| Centrifuge share token | secondary AMM / wrapper | freely transferable wrapper over restricted share | identity gate on mint/redeem only | Bearer economic exposure with gated exit — holder of wrapper cannot force redeem (profile residue). |
| Panoptic | Uniswap V3/V4 pool | liquidity add/remove | same pool price for payoff *and* oracle | Manipulation channel: protocol mitigates with EMA/median/TWAP-delta; composing with external LP of same pool couples risks. |
| Hegic CoverPool | OperationalTreasury | `availableForPayment` capacity | cover drawable on payOff replenish | Cover is first-loss for option book; treating CoverPool LP shares as isolated from `Op` understates shared solvency. |
| Maple loans (profile) | pool share NAV | declared losses reduce exit value | manager-declared impairment | Loss recognition is `Sv`, not an on-chain default state — composing with automated liquidators fails. |
| Rysk full escrow (profile) | stablecoin inventory | locked strike*size or underlying | none shared with venue book | Composition-safe underwriting: no portfolio netting, no cross-margin with other venues. |

## 9. Code vs prior profile disagreements

| protocol | prior profile claims | code shows | which is right |
|---|---|---|---|
| Centrifuge | element set includes mechanisms read as tranche seniority | no seniority/waterfall in `src/`; share classes are permission/price configs only (matches profile *remark* that drops Tr) | Code + witness remark: no `Tr` on chain. |
| Centrifuge | epoch-gated exit (`Ep`) in some corpus readings | async request/fulfill/claim is *not* a global epoch; per-request issuer batch | Code: `ASYNC_REQUEST_CLAIM`, not `Ep`/`Wq`. Profile remark agrees (drops queue, uses request cycle). |
| Hegic | not admissible — open `L1:Ct` | write-time `totalLocked+lockedPremium ≤ balance+cover` *is* the solvency mechanism; no `Ct` state machine exists | Code: discharged by construction. Constraint language defect, not missing element. |
| Derive | Security Module as staked backstop (`Bs` in some readings) | `SecurityModule` is owner-funded subaccount; `withdraw` onlyOwner; no slash | Code: not `Bs`. Profile witness correctly uses socialised loss / treasury. |
| Ondo | mixed product bag (debt USDY, fund, equities) under one element set | repo modelled is USDY `RWAHub` only — pure async NAV mint/redeem; no rebase, no on-chain yield index | Code for this repo: `NAV_PRICE_EXCHANGE` + `ASYNC_REQUEST_CLAIM`. Other Ondo products need separate models. |
| Panoptic | “oracle-free” in marketing | `RiskEngine` maintains EMA/median/TWAP; solvency checked at oracle ticks; `MAX_TWAP_DELTA_DISPATCH` | Code: has `Tp`-class internal oracle. Profile witness correctly restores price source. |
| Aevo vs Derive | corpus treated as identical element sets | profile prose: Aevo has ADL, Derive does not; different scenario margin; Aevo insurance path | Profile right that they differ; vocabulary still collapses both under same `Op`+`Ct`+`Li` bag. |

## 10. Open questions for the mathematicians

1. **Discharge-by-construction:** How should the requirement language treat obligations that cannot arise because a stronger mechanism (full max-loss reservation) precludes them? Hegic/Rysk are rejected for missing `Ct`/`Li` when those tests are intentionally absent. Is the fix a new primitive, a dependent requirement, or a “vacuous discharge” rule?

2. **`Op` as a family:** Is “option payoff” one primitive with parameters (exercise style, settlement medium, underwriting, premium timing, margin, price source — six axes in the Aevo profile residue), or a construction from smaller carriers? Panoptic’s `Op := CL-range` suggests the latter.

3. **Admin price vs attestation:** Should `At` be reserved for independently attested reserves, with a separate primitive for single-writer NAV posts (`ADMIN_POSTED_PRICE` / determination under `Sv`)? Every RWA modelled posts prices without challenge bonds.

4. **Async request vs withdrawal queue:** Are `ASYNC_REQUEST_CLAIM` (issuer prices each batch) and `Wq` (FIFO, liquidity-gated, no per-request price) both instances of one “delayed exit” object, or distinct carriers? Maple (profile) vs Centrifuge (code) disagree in state shape.

5. **Dual register:** What is the mathematical status of a token that is *evidence of* an off-chain register rather than the register itself (BUIDL, USYC, Centrifuge BVI share certificate analogy)? Composition with DeFi assumes the token *is* the claim.

6. **Partial pause and domain-scoped control:** Centrifuge’s messaging-only pause breaks the assumption that `Gp` is a global boolean. Does the control plane need a product of domain flags?

7. **Cross-margin of admin-NAV collateral:** When an RWA with `ADMIN_POSTED_PRICE` is posted into Derive-style `PORTFOLIO_CASH_MARGIN`, which invariants of the composite are theorems and which require an oracle integrity assumption the RWA code does not provide?

8. **Force-exercise as a dual of liquidation:** Panoptic’s force-exercise is a liveness/liquidity-reclaim tool, not a solvency tool. Does the loss-absorption / position-close family need a third element beside `Li` and `Ad`?

---

## Spec ↔ source correspondence

| Quint module | Primary sources |
|---|---|
| `common.qnt` | factored from all five; see section 5 |
| `ondo.qnt` | `RWAHub.sol` L141–304, L355–395, L689–711; `USDY.sol` mint/burn |
| `centrifuge.qnt` | `AsyncRequestManager.sol` L84–170, L281–348, L361–429; `IVaultManagers.sol` `AsyncInvestmentState`; `Spoke.sol` pricePoolPerShare |
| `hegic.qnt` | `OperationalTreasury.sol` L76–176, L236–249; `IOperationalTreasury.sol` LockedLiquidity |
| `derive.qnt` | `CashAsset.sol` L155–244; `OptionAsset.sol` L124–158; `LyraForwardFeed.sol` L28; `DutchAuction.sol` L22–42; `SecurityModule.sol` |
| `panoptic.qnt` | `PanopticPool.sol` dispatch L697+; `CollateralTracker.sol` deposit/withdraw; `RiskEngine` solvency/util; `protocol-analysis/invariants.md` |
