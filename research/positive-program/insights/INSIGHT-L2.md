# Insight Ledger — L2 (Collateralised-debt stablecoins, Liquid staking and restaking)

## 1. Protocols modelled

| protocol | category | repo path | spec file | typechecks | invariant run | verdict |
|---|---|---|---|---|---|---|
| Liquity (BOLD V2) | cdp | `protocol-repos/cdp/liquity_bold/` | `quint-models/L2/liquity.qnt` | yes | `safety` ok (500 samples, 20 steps); also `debtConservation`, `boldPartition`, `collConservation` | modelled — SP-offset liquidation + redemption; redistribution tier omitted |
| crvUSD | cdp | `protocol-repos/cdp/curvefi_curve-stablecoin/` | `quint-models/L2/crvusd.qnt` | yes | `safety` ok; `collConservation` ok | modelled — LLAMMA bands collapsed to health gate; rate_mul interest kept |
| Sky (sDAI + USDS) | cdp | `protocol-repos/cdp/sky-ecosystem_sdai/`, `…/sky-ecosystem_usds/` | `quint-models/L2/sky.qnt` | yes | `safety` ok; `shareConservation` ok | partial — vat/urn/clip CDP core **not in cloned repos**; only savings share + Dai↔USDS 1:1 |
| USDD (PSM only) | cdp | `protocol-repos/cdp/decentralized-usd_psm/` | `quint-models/L2/usdd_psm.qnt` | yes | `safety` ok; `reserveCoversSupplyWhenTinZero` ok | partial — only PSM present; vault/auction core absent (matches profile UNKNOWN) |
| Ethena | cdp | *(not cloned)* | — | — | — | profile-only |
| Lista | cdp | *(not cloned)* | — | — | — | profile-only |
| Lido | lsd | `protocol-repos/lsd/lidofinance_core/` | `quint-models/L2/lido.qnt` | yes | `safety` ok | modelled — share ledger + rebase + WQ; modules/DSM/exits omitted |
| EigenLayer | lsd | `protocol-repos/lsd/Layr-Labs_eigenlayer-contracts/` | `quint-models/L2/eigenlayer.qnt` | yes | `safety` ok; `magnitudeBudget` ok | modelled — deposit shares + magnitude budget + slash; EigenPod omitted |
| ether.fi | lsd | `protocol-repos/lsd/etherfi-protocol_smart-contracts/` | `quint-models/L2/etherfi.qnt` | yes | `safety` ok | modelled — dual value counters + weETH wrap; auction/restaking leg omitted |
| Babylon | lsd | `protocol-repos/lsd/babylonlabs-io_babylon/` | `quint-models/L2/babylon.qnt` | yes | `safety` ok; `activeSatsConsistent` ok | modelled — delegation SM; covenant/EOTS/BTC proofs abstracted |
| Binance staked ETH (WBETH) | lsd | *(not cloned)* | — | — | — | profile-only |

Shared module: `quint-models/L2/common.qnt` (typechecks).

## 2. State shapes

One row per distinct state shape found. A "shape" is a named tuple of state variables that recurs.

| shape | fields | protocols instantiating | differs by |
|---|---|---|---|
| `SharePool` | `shares: User→int`, `totalShares`, `totalAssets` | Lido (`totalPooledEther`), ether.fi (`totalValueInLp+totalValueOutOfLp`), EigenLayer StrategyBase (`underlying`+virtual offsets), Sky sDAI (`potDai` via `chi`) | bootstrap (Lido stone=1; EigenLayer virtual offsets; ether.fi zero-ok); who moves `totalAssets` (oracle rebase vs deposit-only vs admin index write) |
| `IndexAccrual` | `principal`, `index` (chi / rate_mul), optional `lastUpdate` | Sky (`pot.chi`), crvUSD (`loan.rate_mul` / global `rateMul`), (profile) WBETH exchange rate | writer: protocol drip (Sky), continuous MP (crvUSD), whitelisted assert (WBETH profile) |
| `CDPPosition` | `coll`, `debt`, `active`; system `totalColl`, `totalDebt`, `price` | Liquity trove, crvUSD loan, (profile) Sky urn / USDD vault / Lista | liquidation path (hard SP offset vs LLAMMA soft bands vs descending auction); rate ownership (borrower-chosen vs MP vs admin) |
| `StabilityBackstop` | `spDeposits`, `spColl` (or equivalent) | Liquity StabilityPool | Liquity-specific offset-before-redistribution; no analogue in crvUSD (AMM absorbs) |
| `WithdrawalQueue` | `id→{owner, shares, assetsAtRequest, finalized, claimed}`, `nextId`, `lastFinalized` | Lido WQ, ether.fi WithdrawRequestNFT | rate freeze timing (Lido at finalize; ether.fi shares burned at request with amount snapshot); funding obligation (Lido ethBuffered vs operator top-up in WBETH profile) |
| `MagnitudeBudget` | `maxMagnitude: Op→int`, `encumbered: Op→int`, allocations | EigenLayer AllocationManager | unique in corpus; bounds slashability not principal |
| `DelegationRegistry` | `id→{staker, provider, sats, heights, status}`, `btcHeight`, `providerPower` | Babylon btcstaking | **protocol holds no principal**; sats are off-ledger facts about Bitcoin UTXOs |
| `PegSwap` | `gemReserve`, `unitSupply`, `tin`/`tout`, enable flags | USDD PSM, (profile) Sky PSM / Lista peg-swap | fee asymmetry; direction taxes; daily caps (Lista profile) |
| `NonRebasingWrapper` | `wrapperShares: User→int` over underlying share units | ether.fi weETH, (profile) Lido wstETH | same math: wrap moves share units off rebasing balance |

## 3. Actions

| action | signature | protocols | preconditions | element symbol (or NONE) |
|---|---|---|---|---|
| `openTrove` / `createLoan` | `(user, coll, debt[, rate\|N])` | Liquity, crvUSD | ICR/health ≥ threshold; system TCR ≥ CCR (Liquity); no existing position | `Cd`, `Ct` |
| `closeTrove` / `repay` | `(user[, amt])` | Liquity, crvUSD | free stable ≥ debt; post-TCR ≥ CCR (Liquity) | `Cd` |
| `liquidateViaSP` | `(user)` | Liquity | ICR < MCR; SP deposits ≥ debt | `Li`, `Bs` |
| `liquidate` (health) | `(user)` | crvUSD | health < 0 | `Li` (path differs — no SP) |
| `redeem` | `(user, boldAmt)` | Liquity | free BOLD ≥ amt; coll covers at oracle price | `Rd` |
| `provideToSP` | `(amt)` | Liquity | free BOLD ≥ amt | `Bs` |
| `deposit` (share mint) | `(user, assets)` | Lido, ether.fi, EigenLayer, Sky | assets > 0; free assets available | `Sh` (Sky also `Ix`) |
| `redeem` / `queueWithdraw` | `(user, shares\|assets)` | Sky, Lido, ether.fi, EigenLayer | share balance; (queue) capacity | `Sh`, `Wq` |
| `rebase` | `(delta)` | Lido, ether.fi | bound on |delta| / bps cap (ether.fi) | `Rb` |
| `finalize` / `claim` | `(requestId)` | Lido | sequential finalize; buffered ETH | `Wq` |
| `wrap` / `unwrap` | `(user, amount)` | ether.fi weETH | share balance | `Ix` (adapter), not `Rb` |
| `drip` / `accrueInterest` | `(delta)` | Sky chi, crvUSD rate_mul | delta > 0 | `Ix` |
| `sellGem` / `buyGem` | `(user, gemAmt)` | USDD PSM | enabled; balances; reserve | `Ps` |
| `daiToUsds` / `usdsToDai` | `(user, wad)` | Sky | 1:1; free float | NONE (liability conversion) |
| `delegate` | `(user, operator)` | EigenLayer | shares > 0 | NONE (liability transfer ≠ `Au`) |
| `allocate` | `(operator, magnitude)` | EigenLayer | encumbered + mag ≤ maxMagnitude | NONE — **slashability budget** |
| `slash` | `(operator, proportion)` or `(delId)` | EigenLayer, Babylon | magnitude/status Active | `Rs` + partial `Sl`; Babylon slash is Bitcoin-side |
| `createDelegation` / `activate` / `undelegate` / `expire` | per-delegation SM | Babylon | status guards; height bounds | partial `Vl`; no `Sh` |
| `setPrice` | `(p)` | Liquity, crvUSD | external | `Ex` |

## 4. Invariants

The most important table. One row per invariant actually stated in Quint.

| invariant | formal statement | protocols it holds for | verified how | hidden assumption |
|---|---|---|---|---|
| `debtConservation` | `Σ trove.debt = boldSupply` | Liquity | `quint run --invariant=debtConservation` ok | interest not modelled per-trove between touches (V2 compounds on touch — abstracted away) |
| `boldPartition` | `freeBold + spDeposits = boldSupply` | Liquity | run ok | SP is the only non-user BOLD sink; no gas-pool / interest batch residuals |
| `collConservation` | `Σ position.coll = totalColl` | Liquity, crvUSD | run ok | full-redeem residual coll exits ActivePool (CollSurplusPool elided) |
| `spBounded` (subsumed) | initially failed as `spDeposits ≤ boldSupply` without free/SP split | Liquity | **failed then fixed** — modelling error, not protocol bug | must track free vs SP BOLD separately |
| `shareConservation` | `Σ userShares = totalShares` | Sky | run ok | pot funds redeem at current chi without vat surplus injection |
| `parWhenNoAccrual` | `chi = SCALE ⇒ potDai = assets(totalShares)` | Sky | stated; implied by deposit/redeem | after `drip`, claimable assets can exceed `potDai` — DSR funded off-module |
| `supplyConservation` | `Σ userUsdd = usddSupply` | USDD PSM | run ok | no external mint outside PSM |
| `reserveCoversSupplyWhenTinZero` | `tin = 0 ⇒ gemReserve ≥ usddSupply` | USDD PSM | run ok | with `tout > 0`, buys burn more USDD than gem paid — surplus extraction |
| `rateDefined` | `totalShares ≥ 1 ∧ totalPooledEther ≥ 1` | Lido | run ok (in `safety`) | stone share never burned |
| `shareBound` | `Σ user shares ≤ totalShares` | Lido, ether.fi | run ok | stone / wrapper-held shares |
| `queueConsistent` | `claimed ⇒ finalized` | Lido | run ok | admin cannot claim unfinalized |
| `magnitudeBudget` | `∀op. encumbered(op) ≤ maxMagnitude(op)` | EigenLayer | run ok | single abstract operator-set; pending diffs applied immediately |
| `magnitudeBounded` | `0 ≤ maxMagnitude(op) ≤ INITIAL` | EigenLayer | run ok | only slash decreases max; no recharge |
| `pooledNonNeg` | `totalValueInLp ≥ 0 ∧ totalValueOutOfLp ≥ 0` | ether.fi | run ok | rebase/stakeOut/withdraw maintain dual counters |
| `activeSatsConsistent` | `Σ_{status=Active} sats = totalActiveSats` | Babylon | run ok | activate/undelegate/expire/slash update aggregates |
| `powerConsistent` | `Σ providerPower = totalActiveSats` | Babylon | run ok | provider fixed at creation |
| `safety` (composite non-neg + above) | conjunction of per-module safeties | all 8 specs | run ok each | see per-row assumptions |

**Finding from a failed run:** Liquity `safety` initially violated when `redeem` zeroed a fully-redeemed trove but only subtracted `collOut` from `totalColl`, orphaning residual coll. Real system routes residual to `CollSurplusPool` (`liquity_bold/.../CollSurplusPool.sol`). Model fixed by removing all trove coll from ActivePool on full redeem — documents a **surplus-exit** sub-path that `Rd` alone does not name.

## 5. Recurrences — candidate primitives

Things factored into `common.qnt`, with the evidence.

| candidate primitive | quint definition | instantiated by (n) | why it is primitive |
|---|---|---|---|
| Share↔asset conversion | `assetsToShares`, `sharesToAssets`, `assetsToSharesCeil` | Lido, ether.fi, EigenLayer, Sky (4+) | identical floor/ceil ratio math; only scale/bootstrap differ |
| Index accrual | `accrueByIndex`, `sharesFromIndex`, `assetsFromIndex` | Sky chi, crvUSD rate_mul (2+; WBETH profile) | principal·index₂/index₁ is the shared state transition; writer policy is a parameter |
| Collateral ratio / health | `collateralRatio`, `isHealthy`, `collValue` | Liquity ICR, crvUSD health (2+; Sky/USDD/Lista profile) | same predicate; threshold and liquidation continuation differ |
| Map sum / non-neg | `mapSum`, `nonNegMap` | all multi-user specs | accounting hygiene, not economic — still shared |
| Withdrawal queue entry | `QueueEntry` type | Lido, ether.fi (2+; WBETH profile) | same record shape; finalisation/funding obligation differs |
| (not in common — EigenLayer only) Magnitude budget | `maxMagnitude`, `encumbered` in `eigenlayer.qnt` | EigenLayer (1 in lane; restaking category centre) | first-class conserved resource **orthogonal to shares** |
| (not in common — Babylon only) Custody-free delegation SM | status enum + sats + provider | Babylon (1) | actively refutes "protocol holds stake" assumption behind `Vl`/`Rs` |

## 6. Distinctions the 58-symbol vocabulary collapses

Cases where one element symbol covers protocols whose state machines differ materially.

| element symbol | protocols | how their state machines differ | proposed split |
|---|---|---|---|
| `Cd` Collateralized-debt minting | Liquity, crvUSD, Sky (profile), USDD (profile), Lista (profile) | Liquity: borrower sets rate + redemption queue priority; crvUSD: soft-liq bands in AMM, rate from monetary policy; Sky: continuous chi/duty via vat, auction liquidation; Ethena profile: **no CDP at all** (hedged mint) yet prior study put it in this category | Split `Cd-hard-liq` / `Cd-soft-band` / `Cd-auction`; exclude hedged synthetics from `Cd` |
| `Li` Incentivized liquidation | Liquity, crvUSD, Sky/USDD/Lista (profile) | Liquity: SP offset → JIT → redistribute (3 tiers, different payers); crvUSD: continuous LLAMMA conversion, no keeper SP; Sky: dog+clip descending auction with callback | Split `Li-offset-pool` / `Li-amm-convert` / `Li-descending-auction` |
| `Rd` Direct redemption | Liquity (yes), Sky (no — PSM only), crvUSD (no) | Liquity redeems against lowest-rate troves for coll; Sky profile explicitly has no coll redemption | Keep `Rd` only where coll is the redemption asset; do not treat `Ps` as substitute without recording the asset difference |
| `Sh` vs `Rb` vs `Ix` | Lido (shares+rebase of assets), ether.fi (same), Sky (shares+index, no rebase of balances), weETH/wstETH (wrapper) | Lido/eETH: balanceOf moves on rebase (`Rb`); sDAI/weETH: balance fixed, assets/share moves (`Ix`/`Sh`) | Enforce mutual exclusion: rebasing claim XOR index-priced share; wrapper is adapter not third claim |
| `Wq` Withdrawal queue | Lido, ether.fi, EigenLayer, WBETH (profile) | Lido: finalize locks protocol ETH; ether.fi: multi-door (instant/standard/priority); EigenLayer: delay for slash recourse; WBETH: burn on-chain, fulfilment optional operator decision | Split `Wq-funded-obligation` / `Wq-delay-only` / `Wq-best-effort-fulfilsig` |
| `Rs` Restaking | EigenLayer, ether.fi, Babylon | EigenLayer: open AVS slash predicates + magnitude exclusivity; ether.fi: principal double-committed (consensus + EL) with AVS choice outside repo; Babylon: no third-party predicate, self-custodial BTC | Split `Rs-open-predicate` / `Rs-fixed-fault` / `Rs-double-commit` |
| `Vl` Staking lifecycle | Lido, ether.fi, Babylon, EigenLayer pod | Lido: multi-module registry + DSM deposit defence + exit bus; Babylon: Bitcoin script paths, no validator registry on Babylon for BTC keys the same way; EigenLayer pod: credential proof | Do not use monolithic `Vl`; five sub-mechanisms in supplements are the right grain |
| `Ps` Peg-swap | USDD PSM, Sky PSM (profile), Lista (profile) | USDD: tin/tout fees both ways possible; Lista profile: free one way, taxed exit, daily cap, designed to push flow to third-party AMM | Split `Ps-par-bilateral` / `Ps-asymmetric-steer` |
| `Bs` Staked backstop | Liquity SP vs (profile) others | Liquity SP is voluntary BOLD deposited for liquidation rights; not the same as validator bond (Lido CSM) or auction bidder capital | Split `Bs-stable-offset-pool` / `Bs-operator-bond` |

## 7. Mechanisms with no symbol

Code-visible mechanisms the vocabulary cannot name.

| mechanism | protocols | what it does | why no existing symbol fits |
|---|---|---|---|
| **Slashability magnitude budget** | EigenLayer (`AllocationManager`: maxMagnitude starts at WAD, encumbered ≤ max; slash reduces max) | Conserves exclusive slash exposure across operator sets while deposit principal is shared | `Rs` names shared security not a conserved budget; `Sh` is deposit shares; nothing is "allocation of liability units" |
| **Borrower-chosen interest = redemption priority** | Liquity V2 (`annualInterestRate` on trove; redemptions hit lowest rate first) | Rate is a queue key, not a protocol credit instrument | No symbol for user-set parameters that order systemic rights; `Cd` does not mention rate ownership |
| **Soft-liquidation band AMM (LLAMMA)** | crvUSD (`AMM.vy` deposit_range / bands; controller health) | Collateral converts continuously along price bands inside the loan | Neither `Li` (event liquidation) nor `Cl`/`Pm` (DEX curves) capture debt-coupled inventory bands |
| **Custody-free Bitcoin covenant stake** | Babylon (`CreateBTCDelegation`; Taproot paths; protocol holds nothing) | Stake is a UTXO the staker still controls; slash is pre-signed broadcast | `Vl`/`Rs`/`Wq` all presume protocol-held or bridged capital |
| **Pre-signed conditional Bitcoin txs** | Babylon (unbonding/slashing txs exist before justifying events) | Enforcement is adaptor-signature completion, not an on-protocol state write of balances | Not `Ep`, not `Wq`, not `Rl` |
| **Dual pool-value counters** | ether.fi (`totalValueInLp`, `totalValueOutOfLp`; sum = totalPooledEther) | Separates liquid buffer from validator/restaked capital inside one share rate | `Sh`/`Rb` see one asset total; the split is operational state that gates instant redeem |
| **Liability 1:1 converter (two stable liabilities)** | Sky `DaiUsds.sol` daiToUsds/usdsToDai | Permissionless conversion between two issuer liabilities | Not `Ps` (no external reserve gem); not `Xf`; not mint/burn of a single unit |
| **DSR/chi-funded share vault without holding the surplus** | Sky `SavingsDai.sol` | Shares redeem at chi; chi growth funded by vat, not by vault balance alone | `Sh`+`Ix` miss the **external surplus backer** obligation |
| **Hedged synthetic dollar (no debt position)** | Ethena (profile-only; no repo) | Mint against signed quotes; backing is basis book off-chain | Category `Cd` is wrong; needs non-debt stable primitive |
| **Operator primary auction for validator slots** | ether.fi `AuctionManager` | Operators bid for assignment rights; bid → treasury | Not `Em`, not `Fd`, not `Aw` |
| **Refilling rate-limit bucket on state transitions** | ether.fi (unrestaking/exit/instant redeem), Lido exit budget | Meters privileged actions over time | Not `Ep` (epochs); not `Gp` (pause) |

## 8. Cross-protocol connections

Places where one protocol's state is another protocol's input — the real composition surface.

| from | to | what flows | shared state | composition hazard |
|---|---|---|---|---|
| Lido stETH/wstETH | EigenLayer strategies | ERC-20 LST deposit → strategy shares | stETH rebase vs strategy share accounting | `X4`-class: rebasing token into balance-invariant strategy without wrapper |
| Lido stETH | Liquity (wstETH branch, price feed) | LST as CDP collateral | oracle for LST/ETH + ETH/USD | LST negative rebase → ICR drop → liquidation cascade; correlated collateral |
| ether.fi eETH/weETH | EigenLayer (via pods/nodes) | same ETH principal restaked | dual commitment: consensus + AVS | holder cannot see AVS slash predicates on ether.fi ledger |
| EigenLayer magnitude | ether.fi / LRT holders | slash proportion → share burn → LRT rebase down | restaked shares backing LRT | socialized LRT loss (`Sl`) from third-party AVS fault (`Rs-open-predicate`) |
| Sky USDS/sDAI | (external) lending/PSM venues | stable unit as gem or savings share | chi accrual vs peg modules | savings rate vs borrow rate set by different processes (admin vs none in sDAI repo) |
| crvUSD | PegKeeper / Curve pools (in same monorepo, not fully modelled) | crvUSD ↔ stableswap inventory | peg defence without CDP redeem | controller debt and pool inventory couple through peg keepers |
| Babylon BTC stake | Babylon finality / BABY costaking | active sats → voting power | BTC height light client | slash does not move ETH/BABY custody; power drop is the main sanction |
| WBETH (profile) | (CEX + on-chain) | exchange rate assert | off-chain reserve | rate write is the only loss channel — composes poorly with anything assuming attested reserves (`At`) |

## 9. Code vs prior profile disagreements

| protocol | prior profile claims | code shows | which is right |
|---|---|---|---|
| Sky | Full CDP: urns, clip auctions, rate facilitator, governance slate | Cloned repos are **only** `SavingsDai`, `Usds`, `UsdsJoin`, `DaiUsds` — no vat/dog/clip | Code wins for this clone; full CDP lives elsewhere (dss). Profile describes production system; lane can only certify savings+converter. Ledger marks partial. |
| USDD | Full CDP + auction + savings share | Only `UsddPsm` (Maker-style PSM for USDT↔USDD) in clone; README/profile admit no public CDP core | Code wins: PSM model only. Profile correctly flagged UNKNOWN governance/CDP. |
| Ethena | In CDP category with mint/redeem + hedge book | No repo; profile itself says no credit element, no liquidation | Profile right that it is **not** a CDP; category placement is the error. |
| EigenLayer | Earlier residue: same collateral slashable by mutually unaware laws | `AllocationManager`: `encumberedMagnitude ≤ maxMagnitude`; max starts at WAD and only slash reduces it — exclusive slashability units | Code wins; profile remark already refutes the old residue. Magnitude budget is the real primitive. |
| Lido | Single fee split / monolithic validator element | Separate modules (Curated, DVT, CSM), DSM guardian deposit gate, WQ, oracle rebase — distinct contracts | Code wins; `Vl` as one symbol is refuted by file layout (matches profile remark). |
| ether.fi | Tranche/bond junior layer | AuctionManager bids, no operator bond in core path; archive retains old tranche layout | Code wins: no live junior bond under eETH; loss is socialized rebase. |
| Babylon | Withdrawal queue | Per-delegation Bitcoin timelock/unbonding — no shared exit queue | Code wins; profile correctly dropped `Wq`. |
| Liquity | V1 one-time fee / V2 borrower rate | BOLD repo is V2: `annualInterestRate`, SP, redeem, batch liquidate | Code is V2; model follows V2. |

## 10. Open questions for the mathematicians

1. **Is slashability a separate carrier from principal?** EigenLayer's magnitude budget is conserved and composed independently of deposit shares. Should the abstract structure have a 2-resource (principal × slash-budget) object, with `Rs` as a relation between them rather than a primitive token?

2. **What is the type of a "position" that the protocol does not hold?** Babylon's delegation is a pure status machine over externally verified Bitcoin state. Does composition require a `Held` vs `Referenced` modality on every capital-bearing primitive?

3. **How should redemption rights be typed by redeemed asset?** `Rd` against collateral (Liquity) and `Ps` against a fiat stable (Sky/USDD) both defend a peg but induce opposite balance-sheet moves. Is peg defence one construction with a parameter, or two constructors?

4. **Where does soft-liquidation live?** crvUSD's LLAMMA continuously transforms coll↔debt along bands without a discrete `Li` event. Is this a hybrid of `Cd` and a curve invariant (`Pm`/`Cl`), or a new constructor `Cd_soft`?

5. **Rate-as-queue-key vs rate-as-credit-price.** Liquity V2 makes the borrower-chosen rate the redemption ordering key. Does the structure need an explicit "priority parameter" distinct from interest?

6. **External surplus backers for index growth.** sDAI chi can make `convertToAssets(totalShares) > potDai`. The vault is solvent only relative to the wider Sky vat. How is an inter-module solvency obligation represented so composition does not silently drop it?

7. **Multi-door exits as a single primitive.** ether.fi's instant (fee+bucket) / standard (queue) / priority (whitelist+delay) doors price the same claim differently. Is "exit menu" a construction over `Wq`+`Rd`, or a primitive?

8. **Category membership for non-debt stables.** Ethena sits in the CDP supplement with no debt, no liquidation, no `Ct`. Should the positive model refuse category tags and only admit constructions that typecheck against observed state machines?

9. **Wrapper adapters and balance-invariant ledgers.** weETH/wstETH are pure share-unit transporters. Are they identities in the share category (hence invisible to composition), or obligatory when `Rb` meets a non-rebasing consumer (`X4`)?

10. **Failed invariant as modelling oracle.** Liquity's residual-coll bug showed that full redemption has a surplus-exit sub-path. Should every `Rd` constructor carry an explicit residual-coll channel, so omission is a type error rather than a simulation surprise?
