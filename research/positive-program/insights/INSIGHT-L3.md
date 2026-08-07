# Insight Ledger — L3 (Perpetual futures, Yield vaults and aggregators)

## 1. Protocols modelled

| protocol | category | repo path | spec file | typechecks | invariant run | verdict |
|---|---|---|---|---|---|---|
| ApeX | perp | `protocol-repos/perp/ApeX-Protocol_apex-protocol/` | `quint-models/L3/apex.qnt` | yes | `marginSolvent` ok (200×20) | modelled — AMM margin machine from Margin.sol/Amm.sol |
| GMX v2 | perp | `protocol-repos/perp/gmx-io_gmx-synthetics/` | `quint-models/L3/gmx.qnt` | yes | `oiMatchesPositions` ok; `oiCovered` ok | modelled — pool-backed OI from Position/MarketUtils |
| Lighter | perp | `protocol-repos/perp/elliottech_lighter-contracts/` | `quint-models/L3/lighter.qnt` | yes | `fundsNonNeg` ok; `depositedCovers` ok | modelled — L1 surface only (deposit/priority/desert); matching is off-chain+circuits |
| Hyperliquid | perp | `protocol-repos/perp/hyperliquid-dex_contracts/` | `quint-models/L3/hyperliquid.qnt` | yes | `bridgeNonNeg` ok; `bridgeCoversPending` **violates** | partial — only Bridge2 open-sourced; perp engine absent from repo |
| Yearn v3 | yield | `protocol-repos/yield/yearn_yearn-vaults-v3/` | `quint-models/L3/yearn.qnt` | yes | `solvent` ok; `sharesMatch` ok | modelled — multi-strategy idle/debt share vault |
| Beefy | yield | `protocol-repos/yield/beefyfinance_beefy-contracts/` | `quint-models/L3/beefy.qnt` | yes | `solvent` ok (after harvest guard) | modelled — single-strategy share vault (VaultV6) |
| Convex | yield | `protocol-repos/yield/convex-eth_platform/` | `quint-models/L3/convex.qnt` | yes | `escrowConserved` ok; `stakeConserved` ok | modelled — dual machine: 1:1 gauge stake + permanent CRV escrow |
| Pendle | yield | `protocol-repos/yield/pendle-finance_pendle-core-v2-public/` | `quint-models/L3/pendle.qnt` | yes | `ptYtParity` ok; `supplyMatch` ok | modelled — PT/YT split + HWM pyIndex |
| Huma v2 | yield | `protocol-repos/yield/00labs_huma-contracts-v2/` | `quint-models/L3/huma.qnt` | yes | `trancheNonNeg` ok | modelled — senior/junior + epoch redeem waterfall |
| Spark ALM | yield | `protocol-repos/yield/sparkdotfi_spark-alm-controller/` | `quint-models/L3/spark.qnt` | yes | `capitalConserved` ok | modelled — rate-limit envelope; sUSDS savings token **not** in this repo |
| Aster | perp | *(not cloned)* | — | — | — | profile-only |
| edgeX | perp | *(not cloned)* | — | — | — | profile-only |
| Jupiter Perpetual Exchange | perp | *(not cloned)* | — | — | — | profile-only |
| CIAN | yield | *(not cloned)* | — | — | — | profile-only |
| Steakhouse | yield | *(not cloned)* | — | — | — | profile-only |

Shared module: `quint-models/L3/common.qnt` (typechecks).

## 2. State shapes

| shape | fields | protocols instantiating | differs by |
|---|---|---|---|
| ShareVault | `totalAssets`, `totalShares` | Yearn, Beefy, Huma (per tranche), Convex pool receipt (degenerate 1:1) | Yearn splits assets into `idle+Σdebt`; Beefy into `wantInVault+wantInStrategy`; Huma has two ShareVaults (senior/junior); Convex stake is 1:1 so shares≡assets |
| MarginPosition | `posSize`, `collateral`, `side`, `entryNotional` | ApeX, GMX | ApeX size is quote units vs AMM; GMX size is USD notional vs pool; ApeX `baseSize` folds funding+uPnL into one signed field (IMargin.sol:5–8), GMX keeps collateral separate from sizeInTokens |
| FundingState | `cumulative`, `lastTime` | ApeX (CPF), GMX (fundingFeeAmountPerSize) | ApeX global CPF checkpointed per trader (`traderCPF`); GMX per-size cumulative on market + position snapshot |
| AccrualIndex | `stored`, `lastTime` | Pendle (`pyIndex`), Convex (`rewardPerTokenStored`) | Pendle is **ratchet HWM** of SY rate (never falls); Convex is **streaming** `rate*dt/supply` |
| PriorityQueue | list of `{owner, amount, readyAt, kind}` | Lighter (priority requests), Hyperliquid (pending withdrawals — time-gated), Huma (epoch redemption summaries) | Lighter: 14-day censorship deadline then desert; HL: dispute period then finalize/invalidate; Huma: epoch batch, senior-first fill, roll shortfall |
| RateLimit envelope | `maxAmount`, `slope`, `lastAmount`, `lastUpdated` | Spark ALM | Unique in lane as pure capacity-regeneration control plane; no yield index inside |
| Tranches | `senior`, `junior` | Huma | Loss hits junior first (`Pool._distLossToTranches`); profit split by policy bps; senior/junior cap ratio on deposit |
| PT/YT split | `syLocked`, `ptSupply`, `ytSupply`, `index`, `expired` | Pendle | Only protocol with claim that **shrinks** (YT life) and HWM index pushing drawdown onto PT |
| Bridge custody | `bridgeBalance`, validator epoch, pending withdrawals | Hyperliquid Bridge2 | No order book / margin in repo — custody + quorum + dispute only |
| Idle/debt multi-strategy | `idle`, `debt: strat → int`, `maxDebt` | Yearn | Beefy has no debt map (single strategy balance); Yearn withdraw walks strategy queue |

## 3. Actions

| action | signature | protocols | preconditions | element symbol (or NONE) |
|---|---|---|---|---|
| deposit / addMargin | `(user, amount)` | Yearn, Beefy, Convex, Huma, ApeX, GMX, Lighter, HL, Spark(mint) | amount>0; often not paused | `Sh` (share), or NONE for pure margin post |
| redeem / withdraw | `(user, shares\|amount)` | Yearn, Beefy, Convex LP, Pendle, Huma(queued), Lighter, HL | shares owned; liquidity available | `Rd` (direct) vs `Wq`/`Ep` (queued/epoch) |
| open/increase position | `(trader, size, side)` | ApeX, GMX | margin posted; OI/pool caps | `Pf` family (perp) + NONE for AMM vs pool counterparty |
| close/decrease position | `(trader, size?)` | ApeX, GMX | open position | same |
| liquidate | `(trader)` | ApeX, GMX | fails maintenance margin | NONE (vocab has `Li` only as derived in profiles) |
| advance funding | `(rate)` | ApeX, GMX | time advances | `Pf` |
| mintPY / redeemPY | `(user, sy\|py)` | Pendle | not expired (mint); equal PT+YT (redeem) | `Py` |
| lock permanently | `(user, amount)` | Convex CRV→cvxCRV | amount>0; **no redeem action exists** | NONE |
| earmark / harvest rewards | `(reward)` | Convex, Beefy | reward>0 | `Sr` / `Fd` |
| allocate debt to strategy | `(strat, amount)` | Yearn | idle≥amount; under maxDebt | NONE (discretion envelope) |
| enqueue priority / withdrawal | `(user, amount)` | Lighter, HL, Huma | balance owned | `Wq` (partial fit — see §6) |
| activate desert / emergency lock | `()` | Lighter, HL | deadline missed / locker threshold | `Gp` (weak fit) |
| process epoch waterfall | `()` | Huma | requests queued | `Ep` + `Tr` |
| mint/burn USDS + deploy under limit | `(key, amount)` | Spark | `canConsume(limit)`; not frozen | NONE (envelope) |
| set administered rate | profile-only for sUSDS | Spark profile | not in ALM repo | NONE |

## 4. Invariants

| invariant | formal statement | protocols it holds for | verified how | hidden assumption |
|---|---|---|---|---|
| `marginSolvent` | Σ trader collateral ≤ marginPool ∧ reserves ≥ 0 | ApeX | `quint run --invariant=marginSolvent` 200×20 ok | No fee skim; liquidated collateral not redistributed in model |
| `oiMatchesPositions` | Σ long sizes = longOI ∧ Σ short = shortOI | GMX | run ok | Positions closed atomically (no partial fill intermediate) |
| `oiCovered` | longOI+shortOI ≤ poolAmount×mark + impact×mark | GMX | run ok | Impact pool counts as cover; no pending borrows |
| `fundsNonNeg` | totalDeposited ≥ 0 ∧ all balances ≥ 0 | Lighter | run ok | — |
| `depositedCovers` | totalDeposited = Σ L2 + qDeposit + qWithdraw | Lighter | run ok | Deposit and withdraw priority kinds distinguished |
| `bridgeNonNeg` | bridgeBalance ≥ 0 | Hyperliquid | run ok | — |
| `bridgeCoversPending` | bridgeBalance ≥ Σ pending withdrawals | Hyperliquid | **violates** (1000 samples) | **Would require** validators never co-sign overlapping withdrawals; code only checks per-request and per-finalize (`Bridge2.sol` requestWithdrawal / finalizeWithdrawal) |
| `solvent` (share) | shareSolvency ∧ assets = idle+debt ∧ Σ user shares = totalShares | Yearn | run ok | Strategy losses reported before withdraw; no concurrent report race |
| `solvent` (beefy) | shareSolvency ∧ assets = vault+strategy ∧ share match | Beefy | run ok **after** guarding harvest on totalShares>0 | Empty vault cannot harvest (else assets with 0 shares breaks `totalShares=0 ⇒ assets=0`) |
| `escrowConserved` | crvEscrow = cvxCrvSupply = Σ user cvxCRV | Convex | run ok | Permanent lock: no unlock transition in code (`CrvDepositor`) |
| `stakeConserved` | totalStaked = Σ user staked | Convex | run ok | 1:1 receipt |
| `ptYtParity` | expired ∨ ptSupply = ytSupply | Pendle | run ok | mint/redeem always paired pre-expiry |
| `supplyMatch` | Σ ptOf = ptSupply ∧ Σ ytOf = ytSupply | Pendle | run ok | — |
| `backing` (stated) | pyBackingHolds(sy, pt, yt, index) | Pendle | structural; relies on HWM index | Index never falls below prior; SY rate external |
| `trancheNonNeg` | senior≥0 ∧ junior≥0 ∧ cash≥0 | Huma | run ok | Loss ≤ total tranche assets |
| `capitalConserved` | totalMinted = usdsBalance + Σ deployed | Spark | run ok | Venues return capital 1:1 (no yield/loss in ALM model) |

## 5. Recurrences — candidate primitives

| candidate primitive | quint definition | instantiated by (n) | why it is primitive |
|---|---|---|---|
| ShareVault pro-rata | `common.assetsToShares` / `applyDeposit` / `applyRedeem` | Yearn, Beefy, Huma×2, (Convex 1:1 edge) — n≥4 | Same mint/burn identity `shares * assets / supply`; every aggregator vault reimplements it |
| MarginPosition + maintenance | `common.MarginPosition`, `maintainsMargin`, `canLiquidate` | ApeX, GMX — n=2 | Same (size, collateral, side, equity vs threshold) despite different counterparties |
| Funding cumulative | `common.FundingState`, `advanceFunding` | ApeX CPF, GMX funding — n=2 | Continuous long↔short transfer via cumulative index checkpoint |
| AccrualIndex (two modes) | `ratchetIndex` vs `streamIndex` | Pendle HWM vs Convex rewardPerToken — n=2 | Same stored index state; **update law differs** (max vs integrate) |
| DelayedExit queue | `QueueItem` / priority list | Lighter, Hyperliquid, Huma — n=3 | Request → time/epoch gate → claim; semantic of gate differs (censorship vs dispute vs batch) |
| RateLimit envelope | `RateLimit`, `currentLimit`, `consume` | Spark — n=1 in lane but structural | Capacity = min(max, last+slope·Δt); control plane without economic index |
| Tranche waterfall | `applyLoss`, `applyProfit`, `seniorFirstRedeem` | Huma — n=1 here | Junior first-loss + senior-first redeem is a closed algebra |
| Principal/yield split | `mintPyAmount`, `redeemSyFromPy`, `pyBackingHolds` | Pendle — n=1 | Equal PT+YT mint; SY covers PT notional at index |
| Permanent lock (one-way claim) | Convex `lockCrv` (no inverse) | Convex — n=1 | Produces transferable wrapper with **no** redemption — not `Sh`+`Rd` |
| Desert / escape hatch | Lighter `activateDesert`+`desertExit` | Lighter (HL has emergency lock, different) — n=1–2 | Censorship deadline → freeze → proof exit; not a withdrawal queue |

## 6. Distinctions the 58-symbol vocabulary collapses

| element symbol | protocols | how their state machines differ | proposed split |
|---|---|---|---|
| `Ob` (on-chain order book) | ApeX (profile: off-chain/zkLink), Lighter (sequencer+circuits), Hyperliquid (consensus book, closed source), GMX (**no book** — pool) | GMX has no book at all; ApeX open repo is AMM not CLOB; Lighter proves book; HL book not in repo | Split: `Ob-AMM`, `Ob-CLOB-proven`, `Ob-CLOB-consensus`, `Ob-none-pool` |
| `Pf` (perpetual funding) | ApeX, GMX, (HL profile) | Same transfer idea; ApeX CPF is global int256 boost-capped; GMX is per-size token funding with claimable sides | Keep `Pf` but parameterize checkpoint domain (global vs per-market per-size) |
| `Sh` (pro-rata share) | Yearn, Beefy, Convex LP, Huma tranche, Pendle LP (not modelled deep) | Convex LP is 1:1 redeemable anytime; Yearn/Beefy PPS moves; Huma shares redeem only via epoch; cvxCRV is share-like but **irredeemable** | Split: `Sh-nav` (PPS), `Sh-par` (1:1), `Sh-irredeemable` (permanent wrap) |
| `Wq` (withdrawal queue) | Lighter priority, HL dispute withdrawal, Huma epoch redeem, (Pendle stake cooldown in profile) | Lighter bounds **operator** (desert if missed); HL is validator-signed delay with invalidate; Huma rations liquidity senior-first | Split: `Wq-censorship-deadline`, `Wq-dispute`, `Wq-epoch-waterfall` |
| `Ix` (index accrual) | Pendle pyIndex, Convex rewardPerToken, (Yearn implicit PPS) | Pendle HWM never falls (drawdown → PT); Convex streams rewards; Yearn has no stored index (ratio of totals) | Split: `Ix-hwm`, `Ix-stream`, `Ix-implicit-ratio` |
| `Rd` (direct redemption) | Beefy/Yearn/Convex LP vs Huma/Lighter | Same symbol in profiles for instant burn and for epoch-gated burn | Gate kind is not optional decoration — it is the machine |
| `Bs` vs `Sl` / vault backstop | HL profile uses HLP vault as loss allocation (`Sl`/`Sh`), not staked bond (`Bs`) | Vocabulary forced a choice; code for HLP is not in open repo to confirm | Need unbonded depositor backstop as first-class, distinct from slashable stake |

## 7. Mechanisms with no symbol

| mechanism | protocols | what it does | why no existing symbol fits |
|---|---|---|---|
| Permanent escrow / one-way wrap | Convex `CrvDepositor._lockCurve` | CRV locked forever; cvxCRV transferable; exit only by secondary sale | Not `Rd` (no redeem); not `Wq` (no queue); not `Sh` alone (no claim on underlying) |
| Boost multiplier from foreign escrow | Convex (veCRV) | Reward rate on pool A multiplied by protocol's share of escrowed token B | Cross-protocol state coupling; no element names "borrowed governance weight" |
| Position impact pool | GMX `MarketUtils` impact pool | Price impact paid to/from pool; caps positive impact; can "lend" from pool | Neither funding (`Pf`) nor fee (`Fd`) nor insurance (`Bs`) |
| Rate-limit capacity envelope | Spark `RateLimits.sol` | max+slope·time capacity per enumerated action | `Gp`/`Aw` name who may act, not regenerating quantitative envelope |
| Administered savings rate funded by minting debt | Spark profile (sUSDS; not in ALM repo) | Rate is a written number; interest minted as protocol debt unconditionally | Not utilisation curve; not `Ix` from revenue; creates deficit by design |
| Desert mode (freeze + proof exit) | Lighter `activateDesertMode`/`performDesert` | After priority expiry, state freezes; exits against root with desert verifier | Not pause (`Gp`); not queue drain; irreversible mode bit |
| Hot/cold validator sets + dispute invalidate | Hyperliquid Bridge2 | Withdrawals need hot quorum; cold can invalidate in dispute window | Not `Ob`; not simple multisig `Aw` |
| Multi-strategy debt map + report PnL | Yearn `total_idle`/`total_debt`/strategy.report | Capital allocation is explicit debt accounting, not just PPS | Strategy allocation envelope has no symbol (CIAN profile same gap) |
| Senior:junior hard ratio on deposit | Huma | senior ≤ 4× junior enforced at deposit and redeem order | `Tr` names waterfall, not leverage bound between tranches |
| PY index high-water + YT notional decay | Pendle | Index never falls; YT value → 0 at expiry by construction | `Py` names the split, not HWM or time-decay of one leg |
| AMM as sole perp counterparty | ApeX Amm.sol | Positions open via constant-product swap; LP is counterparty | `Ob` is wrong; pool-as-counterparty needs its own name (shared with GMX-style) |

## 8. Cross-protocol connections

| from | to | what flows | shared state | composition hazard |
|---|---|---|---|---|
| Curve gauges / veCRV | Convex | LP deposits, CRV emissions, boost | Convex holds permanent veCRV escrow; gauges see Convex as voter | Boost is a function of foreign total escrow — composing two Convex-likes double-counts governance power |
| SY / yield-bearing tokens (Lido, etc.) | Pendle | SY exchange rate → pyIndex | Pendle ratchets max(source rate, stored) | Source depeg: HWM freezes YT accrual; loss surfaces on PT redeem — composer's solvency view of PT is wrong if they treat PT as par early |
| Yearn / ERC4626 vaults | Spark ALM `depositERC4626` | USDS capital | Rate-limited deploy into vault shares | Vault PPS drop does not appear in ALM `capitalConserved` model — real composition loses the conservation we proved |
| Aave aTokens | Spark ALM `depositAave` | USDS/USDC | same envelope | same |
| Huma credit / receivables | Huma tranches | borrower draws, profit/loss | tranche assets vs cash | Loss recovery order vs epoch redeem race; senior ratio after loss may exceed 4× (deposit guard only) |
| Hyperliquid Bridge USDC | HyperCore (closed) | deposits/withdrawals | bridge balance vs off-chain margin | Bridge `bridgeCoversPending` fails without honest validators — L1 custody does not enforce global reservation |
| Lighter L1 contract | Off-chain sequencer + circuits | priority pubdata, state roots | L1 `totalDeposited` vs L2 tree | Conservation holds only if every L2 credit was deposited — circuits are the real machine, not in Solidity |
| Beefy strategy | external farms | want tokens | strategy.balanceOf() | Vault `balance()` trusts strategy reporting — malicious strategy breaks share solvency |
| Pendle PT | money markets / loopers (external) | PT as collateral | PT price ≠ par before expiry | Treating PT as `Sh` of SY overstates collateral value |

## 9. Code vs prior profile disagreements

| protocol | prior profile claims | code shows | which is right |
|---|---|---|---|
| Hyperliquid | Full perp construction: book in consensus, funding, ADL, HLP vault, OI caps (`supp-05`) | Open repo is **only** `Bridge2.sol` + `Signature.sol` — deposit/withdraw with validator quorum, dispute, emergency lock | Code wins for modelling scope: cannot ground book/ADL/HLP in this repo; profile may be true of closed HyperCore but is not code-evidence here |
| ApeX | Operator off-chain book + zkLink validity proofs, multi-chain omni account, no insurance fund | Open `apex-protocol` repo is an **on-chain AMM margin perpetual** (Margin/Amm/OrderBook) with CPF funding and liquidations | Code wins for this repo: it is AMM-perp, not the zkLink omni product the profile describes (likely product evolution / wrong repo pin) |
| Spark Savings | sUSDS: administered rate, drip accumulator, mint debt to pay interest, rate floor/ceiling/step/cooldown | Cloned repo is **spark-alm-controller** only: RateLimits + MainnetController venue actions — no sUSDS token | Code wins for this clone; profile describes a different package (savings token elsewhere). ALM envelope is real and unmodelled by vocabulary |
| Lighter | Full matching with price-time leaf indices, Plonky2 circuits, blob DA | Solidity is batch commit/verify, priority requests, desert exit; circuits not in this contracts repo | Both: L1 surface modelled; circuit book is profile-only relative to this tree |
| Convex | Immutable (no proxy), boost, permanent escrow, vote layer | Booster/CrvDepositor/BaseRewardPool match escrow+stream+1:1 stake; immutability is deployment practice not a state machine bit | Code confirms economic machine; "immutability as absence of Up" is a vocabulary meta-problem (profile is right that vocab cannot assert immutability) |
| Huma | Retail daily cap product + permissioned tranched pools; points class | Open contracts are tranched Pool/TrancheVault/EpochManager/Credit — matches permissioned product | Profile right that retail points product may live elsewhere; we modelled the open tranche machine |
| GMX | (not fully expanded in supp excerpt here) | Clear pool OI + impact pool + funding on positions | Code is authoritative for v2 synthetics |

## 10. Open questions for the mathematicians

1. **Is "share" a single primitive?** Code shows at least four laws: NAV pro-rata (Yearn/Beefy), par 1:1 (Convex stake), irredeemable wrap (cvxCRV), epoch-gated tranche share (Huma). Should the carrier index by redemption law?

2. **What is the type of a rate-limit envelope?** Spark's `(max, slope, last, t)` regenerates capacity without pricing risk. Is this a stratum-4 control primitive, or a general "budget coalgebra" that also covers CIAN deposit caps and Huma daily redemption caps?

3. **How does composition treat permanent escrow of a foreign governance token?** Convex's state includes a non-withdrawable position in Curve. Peer composition (side-by-side element sets) cannot express "protocol A is a locked creditor of protocol B's vote."

4. **Funding transfer vs impact pool vs insurance:** GMX has all three-ish (funding, impact pool, liquidations into fees). Which free algebra generators are needed so that ApeX (AMM PnL to LPs) and GMX (pool OI) are both constructible without fake `Ob`?

5. **Does `bridgeBalance ≥ Σ pending` belong in the solvency sort?** It fails for Hyperliquid Bridge under validator co-signing. Should admissibility require reservation, or is "quorum honesty" an external assumption on the party sort?

6. **High-water index vs streaming index:** Pendle and Convex share an `AccrualIndex` state shape but different monoids (max vs +). One symbol `Ix` erases the difference that allocates losses. Is the monoid part of the primitive?

7. **Desert mode as a modality:** Lighter's Normal→Desert is an irreversible global mode that changes the enabled action set (only proof exits). Is this a general "escape hatch" primitive parameterized by deadline and verifier, covering forced-inclusion systems?

8. **Where does strategy discretion live?** Yearn debt allocation, Beefy `proposeStrat`, Spark enumerated relayer actions, CIAN (profile) batched agent calls — all are "human chooses point inside envelope." The vocabulary names `Aw`/`Gp`/`Up` but not the envelope. What is the mathematical object?

9. **PT before expiry is not a share of SY.** Money-markets composing with Pendle PT need a time-dependent claim, not `Sh`. Is `Py` enough, or is a clock-indexed valuation functor required for composition?

10. **ApeX repo vs ApeX profile:** If the corpus pins product intent rather than a git tree, how should the positive program treat forked/legacy code that implements a different machine than the live venue?

---

### Modelling notes (traceability)

| spec | primary source files |
|---|---|
| `common.qnt` | factorings from all below |
| `apex.qnt` | `contracts/core/Margin.sol`, `Amm.sol`, `interfaces/IMargin.sol` |
| `gmx.qnt` | `contracts/position/Position.sol`, `market/MarketUtils.sol` |
| `lighter.qnt` | `contracts/ZkLighter.sol`, `Storage.sol`, `Config.sol` |
| `hyperliquid.qnt` | `Bridge2.sol` |
| `yearn.qnt` | `contracts/VaultV3.vy` |
| `beefy.qnt` | `contracts/archive/vaults/BeefyVaultV6.sol` |
| `convex.qnt` | `contracts/contracts/Booster.sol`, `CrvDepositor.sol`, `BaseRewardPool.sol` |
| `pendle.qnt` | `contracts/core/YieldContracts/PendleYieldToken.sol`, `PendlePrincipalToken.sol` |
| `huma.qnt` | `contracts/liquidity/Pool.sol`, `TrancheVault.sol`, `EpochManager.sol` |
| `spark.qnt` | `src/RateLimits.sol`, `src/MainnetController.sol` |

### Difficulties (credibility)

- **Hyperliquid:** cannot model the perp state machine from available source; bridge-only model is honest but thin relative to profile.
- **Lighter:** first `fundsNonNeg` violation was a model bug (deposit vs withdraw priority fused); fixed by `ReqKind`. Conservation now holds.
- **Beefy:** empty-vault harvest broke share solvency; real systems usually harvest only with TVL, but code path exists via strategy — recorded as guard.
- **Spark:** name collision between "Spark Savings" profile and ALM controller clone; modelled what is on disk.
- **ApeX:** profile describes zkLink omni; git tree is AMM margin — treated as code-authoritative for the clone.
- **Missing clones:** Aster, edgeX, Jupiter Perp, CIAN, Steakhouse left profile-only; no fabrication of specs without code.
