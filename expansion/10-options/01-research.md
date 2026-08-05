# Stage 1 research — Options / structured products

**Lane:** `10-options` · **Date of all accesses: 2026-08-04** (every URL below was fetched or
queried on this date unless a second date is given).
**Applications:** Derive (formerly Lyra V2) · Rysk V12 · Hegic · Aevo (Ribbon lineage) · Panoptic V2.

**Source quality for this category is bimodal and the split is not where you would expect.**
Two of the five — Derive and Panoptic V2 — are exceptionally well sourced: both publish
complete, current, parameterised protocol documentation *and* an open core-contract repository
whose deployed addresses can be cross-checked against a live public API (Derive) or against
in-repo deployment tooling and audit-freeze tags (Panoptic). For those two, essentially every
mechanism claim below is traceable to either a `.md` docs page with named constants or to
Solidity in the canonical repo. The other three are documented much worse, in three different
ways. **Rysk V12 has good prose docs and no core repository at all** — the deployed contracts
are only inspectable through on-chain verification, and one of the two chains' key contract is
a verified `OwnedUpgradeabilityProxy` compiled from Opyn GammaProtocol sources, which is how
the "Lean Gamma" lineage was confirmed rather than assumed. **Aevo has good docs and no code**:
`github.com/aevoxyz` contains exactly two public repositories, neither of them the exchange;
the only open Aevo-lineage code is the *decommissioned* Ribbon vault stack. **Hegic has the
opposite problem**: a complete GPL-3.0 monorepo with the live Arbitrum addresses committed, but
its last commit is 2022-12-26 and its public gitbook still documents the 2020-era V1 design,
so the docs are three protocol generations behind the code and the code is three and a half
years behind the calendar. Consequently, all Hegic mechanism claims below are read from source,
not from docs. Aggregators were used only where the corpus itself uses them (DefiLlama, for the
ranking basis), and are labelled as such; every design claim has a docs, GitHub, on-chain
verification, or live-API citation. Where a fact could not be reached at a primary source it is
marked **UNKNOWN** rather than guessed.

---

## Derive (formerly Lyra V2)

### 1. WHAT IT DOES

A buyer sends USDC into a self-custodial subaccount on Derive Chain and buys a European,
cash-settled option on one of ~57 supported currencies, paying the premium upfront through
either a central limit order book or an RFQ. A writer holds the opposite side in the same
subaccount system, posting USDC and/or accepted base assets (ETH, wBTC, HYPE and others) as
collateral; the writer's obligation is not pre-funded but margined, either per-position
(Standard Margin) or as a worst case over a shock grid (Portfolio Margin / PM2). The payoff is
determined at expiry by a 30-minute TWAP of the index price — `SETTLEMENT_TWAP_PERIOD = 30`
minutes, sampled once per minute — and is paid in USDC with no exercise action required; in the
final 30 minutes the option's mark itself blends from the forward price into the running TWAP,
so the fixing is a gradual convergence rather than a point observation. If a writer's account
falls below maintenance margin, a two-stage Dutch auction opens: a *solvent* auction where
liquidators bid at a discount rising linearly from `INITIAL_DISCOUNT = 5%` to
`FAST_DISCOUNT = 30%` over `FAST_LIQUIDATION_TIME = 15 minutes`, and, if that reaches 100%
without clearing, an *insolvent* auction whose offers start at portfolio mark-to-market and rise
to maintenance margin over `INSOLVENT_DURATION = 60 minutes`. If the account is still short, the
Security Module pays the deficit; if the Security Module cannot, the loss is socialised as a
**temporary withdrawal fee** = `Unpaid Insolvent Debt / (Unpaid Insolvent Debt + Deposited
USDC)` levied on all USDC depositors, and `SM_FEE = 100%` of interest payments is routed to the
Security Module until it is whole. Users retain a permissionless escape hatch to withdraw via
block explorer if the off-chain matching engine or interface fails.

### 2. DESIGN

Derive is three layers: **Derive Chain**, "an Optimistic rollup built on the OP Stack, secured
by Ethereum mainnet"; **Derive Protocol**, "a settlement protocol that enables permissionless,
self-custodial margin trading of perpetuals, options and spot"; and **Derive Exchange**, "an
orderbook that efficiently matches orders and settles them to the Derive Protocol", which the
docs describe as "a centralized limit order book, but remains self-custodial, and settles trades
and liquidations in a trustless manner". On-chain, the unit of account is a **subaccount**
(`SubAccounts.sol`) whose positions are valued by a pluggable **risk manager**
(`StandardManager.sol`, `PMRM.sol`, `PMRM_2.sol`, `PMRM_2_1.sol`).

**(a) Exercise style — European.** "Users can mint and trade European options for any expiry and
strike price." Longest tenor `MAX_EXPIRY = 400 days`.

**(b) Settlement — cash, in USDC**, against `S_avg(30)`, the 30-minute one-minute-sampled TWAP
of the index. The pre-expiry mark blends:
`S_mark = (SETTLEMENT_TWAP_LENGTH − n)/SETTLEMENT_TWAP_LENGTH × Forward Price + n/SETTLEMENT_TWAP_LENGTH × S_avg(n)`.
Perps settle continuously.

**(c) Underwriting — peer-to-peer.** Orders are matched off-chain by the Derive Exchange and
only then settled on-chain. RFQ is a first-class parallel rail with its own private API surface
(`private/send_rfq`, `send_quote`, `execute_quote`, `rfq_get_best_quote`) and its own fee
schedule. Order-book matching is pro-rata with a FIFO floor (`pro_rata_fraction: 0.8`,
`fifo_min_allocation: 10`, from `public/get_instruments`).

**(d) Premium — upfront.**

**(e) Margin — both isolated and scenario-based, selectable.** Standard Margin is per-position.
**PM2** computes `Maintenance Margin = Portfolio MtM + maxLoss + Contingencies` and
`Initial Margin = Portfolio MtM + (im_factor + depeg_factor) × maxLoss + Contingencies + Oracle
Contingency`, with `im_factor` 0.8 (MM) / 1.0 (IM). `maxLoss` is the minimum over four scenario
families: **Regular Loss** — "the maximum PNL loss the portfolio will endure under 23 scenarios
comprised of various forward and volatility shocks" (spot −18%…+18% in 4.5% steps; vol shocks
up/down/static within ±13.5%; only up-vol at the ±18% wings); **Tail Loss** (~±20–25% spot with
vol increases, damped per scenario); **Skew Loss** (two scenarios, linear and absolute-value, for
surface asymmetry); **Forward Loss** (basis across expiries at ±4.5%). Contingencies: collateral
haircut 10% MM / 15% IM, perp factor 0.03 MM / 0.04 IM, option factor 0.005 × short notional,
plus an oracle contingency driven by feed confidence. **A PM account may hold derivatives on
only one base asset**; the live API exposes one manager address per currency per margin type
(`"margin_type": "PM2", "currency": "ETH"` → `0xc755DAe3fd295A687adf3e192387163f813F0598`).
Open-interest caps: ETH 750 base / 2M options / 250K perps; BTC 15 base / 100K options / 12K
perps. The legacy PM1 formula is
`Initial Margin = Portfolio MtM + (mfactor + Depeg Contingency) × (min(maxLoss, Forward
Contingency) + Asset Contingency) + Oracle Contingency`, `mfactor = 1.25`,
`mfactor += max(0, 0.99 − USDC Price) × PEG_FACTOR`, `PEG_FACTOR = 4.0`; IV shock
`Shocked IV_jk = IV Shock_k × IV_j` with `VOL_RANGE = −0.275` (down) / `0.5` (up) and
`VEGA_POWER = 0.3` (<30d) / `0.13` (>30d).

**(f) Pricing — order-book priced for execution, model-priced for margin and mark.** Five
oracle inputs per market: Spot Price, Forward Price, Perp Price, Implied Volatility, Risk Free
Rate. Implied volatility comes from a **Stochastic Volatility Inspired (SVI) curve with five
parameters**, with log-moneyness bounded at 4 standard deviations, total implied volatility
capped at 24.0 and total variance at 144.0. "Associated with each feed is a confidence score
which ranges between 0 (low confidence) and 1 (high confidence)." The data "is provided by
**Block Scholes**" and "is posted onchain for transparency".

**Collateral and liquidation path.** `CashAsset.sol` + `InterestRateModel.sol` for USDC,
`WrappedERC20Asset.sol` / `WLWrappedERC20Asset.sol` for base collateral, `OptionAsset.sol`,
`PerpAsset.sol`. Liquidation is `liquidation/DutchAuction.sol`. Bidder cap:
`Max Percentage = Buffer Margin / (Buffer Margin − (1 − Discount) × MtM Value − Discount ×
Reserved Funds)`; insolvent auctions permit 100%. Then `SecurityModule.sol`, then the temporary
withdrawal fee.

**Oracle.** Feeds are signed off-chain and submitted on-chain: `src/feeds/BaseLyraFeed.sol`,
`LyraSpotFeed.sol`, `LyraForwardFeed.sol`, `LyraVolFeed.sol`, `LyraRateFeed.sol`,
`LyraSpotDiffFeed.sol`, `SFPSpotFeed.sol`, with a `dataSubmitter` at
`0xd8d46a044f62d97733707176D6791b0a73cd7f6C` in the committed mainnet deployment.

**Control plane.** Derive Chain is an OP-Stack optimistic rollup; `src/l2/` holds the L2 pieces
and the core deployment records `Xf`/`Xm` counterparts. "The Derive Protocol contracts have been
audited by Tier 1 firm Sigma Prime"; "smart contracts are currently managed by the Derive DAO
multi-sig, with plans to transition to a fully on-chain governance system". The PM2 manager sits
behind a proxy: `ETH_2.json` records `pmrm2`, `pmrm2Imp` and a `proxyAdmin`
(`0x6ecce6823743c5F40505dB287bB77190E83b0916`), and the repo contains
`BaseManagerUpgradeable.sol`. Instrument listing is rules-based: "2 Daily expiries, 3 Weekly
expiries, 3 Monthly expiries", auto-replaced on expiry, with strike increments that "depend on
the delta and the time left to expiry" (ETH, 40–60 delta: $25 at ≤1 day rising to $200 at >35
days). Fee schedule: options taker `$0.5 + min(0.03% × notional, 12.5% × premium)`, maker
`min(0.01% × notional, 12.5% × premium)`; RFQ multi-leg discounts (cheapest leg 100% off, second
and third 50% off, most expensive full); box spreads `notional × 0.5% × years_to_expiry + $0.50`.
DRV staking (stDRV, 1:1, 28-day unlock or instant exit at −20%, ~250,000 stDRV/week rewards) is a
rewards programme; **no slashing or insolvency-backstop role is documented for it.**

### 3. REPO

- **URL:** `https://github.com/derivexyz/v2-core` (mirror `https://github.com/lyra-finance/v2-core`).
- **Commit inspected:** `96796a61dcb1dc852e25518b00cc1a79fb3caeeb`, branch `master`, commit date
  2026-02-16 ("chore: docs"); repository `pushed_at` 2026-03-05. **No tags and no releases exist.**
- **License:** Business Source License 1.1. Licensor "Lyra Foundation"; Licensed Work "Lyra V2
  Core … (c) 2023-2025 Lyra Foundation"; Additional Use Grant "Any uses listed and defined at
  v2-core-license-grants.lyra.eth"; Change Date split by release date (before/after 2025-02-17).
  The GitHub API reports the license as `NOASSERTION`.
- **Language:** Solidity, Foundry (`foundry.toml`, `forge install` into `./lib`, no git
  submodules), with Slither config and a committed `.gas-snapshot`.
- **Deployed contracts match the repo — verified.** `deployments/` holds `31337` (local), `901`
  (testnet) and `957` (Derive Chain mainnet). `deployments/957/core.json` records
  `srm: 0x28c9ddF9A3B29c2E6a561c1BC520954e5A33de5D`, `securityModule:
  0x8dC92fB0e1C1F1Def6e424E50aaA66dbB124eb54`, `auction: 0x141919f1FA90F99A3fbafFb0b111e4f84AB5aB52`,
  `cash: 0x57B03E14d409ADC7fAb6CFc44b5886CAD2D5f02b`, `subAccounts:
  0xE7603DF191D699d8BD9891b821347dbAb889E5a5`. Cross-check against the live public API
  (`POST public/get_all_currencies`, 2026-08-04): the SRM address and the repo's
  `ETH_2.json` `pmrm2` address `0xc755DAe3fd295A687adf3e192387163f813F0598` both appear as live
  manager addresses. **Caveat:** only the settlement/margin/liquidation half is open. The
  matching engine, the risk engine that gates order entry, and the SVI surface producer are
  closed-source.
- **Top-level layout:** `.github/`, `deployments/`, `docs/`, `lib/`, `scripts/`, `src/`, `test/`,
  plus `LICENSE`, `README.md`, `foundry.toml`, `foundry.lock`, `remappings.txt`,
  `slither.config.json`, `codecov.yaml`, `.gas-snapshot`, `.gitmodules`.
  `src/`: `Allowances.sol`, `SecurityModule.sol`, `SubAccounts.sol`, `assets/`, `feeds/`,
  `interfaces/`, `l2/`, `libraries/`, `liquidation/`, `periphery/`, `risk-managers/`.
- **Activity:** active. 884 live ETH option instruments and 57 currencies returned by the public
  API on 2026-08-04.

### 4. EVIDENCE

| Claim | Source | Accessed |
|---|---|---|
| Three-layer architecture; CLOB is centralized but self-custodial | https://docs.derive.xyz/reference/overview | 2026-08-04 |
| European; cash-settled in USDC; `MAX_EXPIRY = 400 days`; collateral set | https://docs.derive.xyz/docs/supported-products-1.md | 2026-08-04 |
| `SETTLEMENT_TWAP_PERIOD = 30`; blended pre-expiry mark formula | https://docs.derive.xyz/docs/settlements.md | 2026-08-04 |
| PM1 formulas, 23 scenarios, `mfactor`, `PEG_FACTOR`, `VOL_RANGE`, `VEGA_POWER` | https://docs.derive.xyz/docs/portfolio-margin-1.md | 2026-08-04 |
| PM2 formulas, `im_factor`, four maxLoss families, contingencies, one-base-asset rule, OI caps | https://docs.derive.xyz/docs/pm2.md | 2026-08-04 |
| Dutch auction constants; insolvent auction; socialized-loss withdrawal fee; `SM_FEE = 100%` | https://docs.derive.xyz/docs/liquidations-1.md | 2026-08-04 |
| Five feeds; SVI five-parameter surface; caps 24.0 / 144.0; confidence 0–1; Block Scholes | https://docs.derive.xyz/docs/oracles-1.md | 2026-08-04 |
| Listing calendar and delta-dependent strike increments | https://docs.derive.xyz/docs/how-are-strikes-and-expiries-selected.md | 2026-08-04 |
| Escape hatch; Sigma Prime audit; DAO multisig control | https://docs.derive.xyz/docs/self-custodial-withdrawals-escape-hatch.md · https://docs.derive.xyz/docs/how-do-i-know-my-funds-are-safe.md | 2026-08-04 |
| Fee schedule incl. RFQ leg discounts and box-spread fee | https://docs.derive.xyz/reference/fees-1.md | 2026-08-04 |
| stDRV staking is a rewards programme (28-day unlock / 20% instant penalty); no slashing documented | https://docs.derive.xyz/docs/staking-rewards-program.md | 2026-08-04 |
| Repo HEAD, license text, `src/` layout, `deployments/957`, `SecurityModule.sol` is `Ownable2Step` with whitelisted claimants | `gh api repos/derivexyz/v2-core/...` (contents, commits, license, readme) | 2026-08-04 |
| 884 live ETH options; 57 currencies; per-currency PM/PM2 managers; pro-rata + FIFO matching; maker 0.01% / taker 0.03% | `POST https://api.lyra.finance/public/get_instruments` and `public/get_all_currencies` | 2026-08-04 |
| $28.89M options notional / 30d = 86.2% of a $33.54M category (aggregator, ranking basis only) | `https://api.llama.fi/overview/options` | 2026-08-04 |
| Derive V2 TVL $114.9M, DefiLlama category "Derivatives" (aggregator) | `https://api.llama.fi/protocols` | 2026-08-04 |

### 5. WHAT LOOKS UNNAMEABLE

1. **Scenario-grid margin.** PM2's `maxLoss` is a *minimum over four families of maxima over
   grids*, not a scalar comparison. `Ct` names a threshold test. Confirms the corpus finding, and
   PM2 makes it worse than PM1 did: it is not one grid but a lattice of grids with different
   shock geometries, plus a "min(regular, tail, skew, forward)" composition rule.
2. **A volatility surface as a priced object.** Five parametric SVI coefficients per expiry with
   moneyness and variance caps. There is no symbol for a pricing model at all, and none for a
   *surface* — a function of two arguments (strike, tenor) that is itself an oracle output.
3. **Feed confidence as a margin input.** `Ex` names a feed; nothing names a scalar in [0,1]
   attached to a feed that increases a capital requirement when the feed is doubted.
4. **Instrument listing as a rolling calendar with delta-dependent strike granularity.** The
   strike grid is a function of delta and tenor, so the *set of tradeable instruments* changes as
   the market moves. Nothing in the vocabulary names a listing process, let alone a state-dependent
   one.
5. **Terminal fixing as a converging blend.** The mark migrates from forward to TWAP over the
   last 30 minutes. `Ex` names a price source; this is an irrevocable determination procedure with
   its own time structure.
6. **Off-chain matching with on-chain settlement, plus an escape hatch.** `Ob` asserts an
   on-chain book, which is false here. And the escape hatch is a distinct primitive — a
   unilateral, operator-independent exit from a system whose ordering is operator-controlled.
7. **A fee schedule as market-making policy.** Per-leg RFQ discounts (100%/50%/50%/0% by leg
   cost), a premium-capped notional fee, and an interest-rate-shaped box-spread fee.
8. **Socialised loss as a temporary withdrawal levy.** `Sl` says loss is assigned to a claim
   class. Here the loss is collected as a *flow* on exits until the deficit clears, which changes
   the incentive to run.
9. **The `Bs` misfit is deeper than the corpus recorded.** The corpus marker says the security
   module is "thinly capitalized relative to OI". Reading `src/SecurityModule.sol`: it is an
   `Ownable2Step` contract holding a subaccount funded in the stable asset, with an owner-managed
   `isWhitelisted` set of modules permitted to draw funds. **There is no staking and no slashing
   condition anywhere in it**, and the DRV staking programme is documented purely as an emissions
   scheme. So `Bs` ("slashable first-loss capital") does not merely overstate the size — it
   asserts a *kind* of capital that does not exist here. The correct object is a
   discretionary, owner-funded bailout treasury, which the vocabulary cannot name.

**On the corpus's claims.** `Op` under-resolution: confirmed, and Derive alone occupies a
distinct cell on five of the six axes. Missing mechanisms: all three named ones are present and
material here (pricing model/surface, listing, terminal fixing), and a fourth — the *identity and
fundedness of the loss absorber* — is also unnameable. The vocabulary **accepts** Derive; on the
evidence that acceptance is partly false, because it is purchased by `Bs`, and `Bs` is wrong
about Derive.

### 6. DELTA vs the corpus record

- **`markers[Bs]` understates the misfit.** Corpus: "thinly capitalized relative to OI". Source:
  `SecurityModule.sol` has no stake, no staker and no slash. Cite:
  `gh api repos/derivexyz/v2-core/contents/src/SecurityModule.sol`, 2026-08-04. The corpus also
  reports `satisfiesRequirementsAndWarrants: true` for Derive — an acceptance that rests on this
  symbol.
- **"27+ joint spot-and-volatility shock scenarios" is not what the docs say.** Both the PM and
  PM2 pages state **23** regular scenarios, with tail, skew and forward losses as *separate*
  families rather than additional grid points. Cite:
  https://docs.derive.xyz/docs/portfolio-margin-1.md and https://docs.derive.xyz/docs/pm2.md.
- **PM2 is not in the corpus record at all.** The production margin engine is a distinct
  contract (`PMRM_2.sol` / `PMRM_2_1.sol`, live at `0xc755DAe3…` for ETH) with a different
  formula, different contingencies, discounting/anti-discounting of option value by the risk-free
  rate, and a collateral-haircut term absent from PM1. The corpus describes PM1.
- **`Rf` is listed only in `elements`, not `canonicalForm`.** RFQ on Derive is a first-class rail
  with its own API namespace and its own fee schedule, not a derived consequence of `Ob`.
- **`identicalClaimedByLane: [["Derive","Aevo"]]` is wrong.** See the Aevo DELTA section: the two
  differ on scenario count and geometry, on margin floor construction, on index construction, and
  on loss-absorption topology (Derive has no ADL; Aevo does).
- **Ranking numbers drift, direction holds.** Corpus: $31.19M/30d, 87% of a $35.70M category.
  Live 2026-08-04: $28.89M/30d, 86.2% of $33.54M. Rolling-window difference, not a discrepancy.
- **Category assignment.** DefiLlama itself classifies "Derive V2" under **Derivatives**
  ($114.9M TVL), not Options; only the "Derive Options" volume line sits in the options overview.
  Worth recording because the corpus's own argument is that DefiLlama's taxonomy is evidence.

---

## Rysk V12

### 1. WHAT IT DOES

Rysk V12 inverts the usual buyer/writer framing: the *user* is the option seller. A user picks
asset, expiry, strike (called the "target price") and size; the protocol opens a request-for-quote
over WebSocket to integrated market makers, aggregates their signed quotes for a **2-second
window**, surfaces the best bid, and on acceptance settles on-chain. The user posts the full
collateral — the underlying asset for a covered call, stablecoins equal to strike × size for a
cash-secured put — and it is "locked in Rysk's settlement layer for the life of the trade and
never leaves the contract, with no rehypothecation, no shared portfolio risk, and no unsecured
bilateral counterparty credit risk." The maker pays the premium **upfront in USD** and is
credited oTokens; the maker must have pre-deposited USDT0 in the accounting contract before the
quote can be filled. Options are European, expire at **08:00 UTC**, and settle automatically
against the Stork price, with funds distributed within about two hours; **positions cannot be
closed early** — "Rysk is developing a secondary market that will allow users to buy back or
offset open positions before expiry." **A writer cannot fail to pay**: the maximum payoff is
escrowed at trade time, so there is no margin engine, no liquidation, and no backstop. Layered on
top, **Rysk Premium** is a curated pool: LPs deposit USDC, the pool writes options through the
same RFQ rail, epochs strike a deposit and a withdrawal price per share from NAV, withdrawals are
two-step and queue when collateral is locked in open positions, and the NAV itself "is calculated
off-chain using aggregated pricing from a committee of option desks."

### 2. DESIGN

**(a) Exercise style — European.** Expiry at 08:00 UTC; no early exercise and no early close.

**(b) Settlement — mixed, and the docs conflict.** The product pages say "cash-settled covered
calls earn without selling the asset; physically-settled cash-secured puts accumulate the asset
at the lower strike", while the V12 solution page says "All positions are physically settled,
fully collateralized, and executed end to end on-chain" and the mechanics page says "the
collateral is physically exchanged at the strike price". Recorded as: **puts physical,
calls documented both ways — treat call settlement as partially UNKNOWN.**

**(c) Underwriting — peer-to-peer via RFQ.** "Each trade is priced through an on-chain auction
between users selling volatility and counterparties buying it." Matching is off-chain during the
aggregation window; settlement is on-chain. Rysk Premium adds a *peer-to-pool* layer that rides
the same p2p rail: the pool is a taker in the RFQ.

**(d) Premium — upfront.** "Premiums are paid immediately upon execution", "in USD".

**(e) Margin — none.** Full per-position collateralisation, isolated in a MarginPool, locked to
expiry. There is no maintenance margin, no health factor and no liquidator. Makers are gated by a
pre-deposit check rather than margined.

**(f) Pricing — quote-driven, not model-driven.** "The RFQ model sources live bids for each
trade"; the protocol publishes no volatility surface and no pricing model. The one place a model
does appear is Rysk Premium's NAV, which is produced off-chain by a committee of desks — i.e. the
*share price* is modelled even though the *option price* is quoted.

**Collateral and liquidation path.** `MarginPool` stores collateral; `Rysk` is the transaction
processor; `MMarket` is the maker accounting contract that deducts the quoted premium from the
maker's balance and credits oTokens. **There is no liquidation path, by construction.** The
protocol closes the loss channel by pre-funding rather than by policing it. The Premium vault's
analogous mechanism is the withdrawal queue: "if the pool's free balance is insufficient …the
epoch will still advance but withdrawals will not be processed in that batch", with the executed
price being "the price from the first epoch where withdrawals were successfully processed".

**Oracle.** Stork is primary, cross-checked against Pyth: "In the event that the stork price and
Pyth price are not similar to a certain threshold …the system will stop all processes that require
an accurate price", with Stork as the fallback on divergence; Pendle assets are priced from the
Pendle API. At 08:00 the Stork price is used for settlement, and for collateral assets "a manual
check is conducted by the Rysk team at price fixing during a **5-minute smart contract enforced
dispute period**."

**Control plane.** The Ethereum-mainnet MarginPool is an `OwnedUpgradeabilityProxy` verified on
Sourcify (exact creation and runtime match, verified 2026-06-10) with the compiler metadata path
`/Users/metaverse/Documents/iv/GammaProtocol/contracts/packages/oz/upgradeability/OwnedUpgradeabilityProxy.sol`,
solc 0.6.10 — direct on-chain confirmation that the settlement layer is a fork of **Opyn
GammaProtocol**, which the audit index calls "Lean Gamma". Audits listed: Rysk V12 mk0/mk1/mk2/mk3
+ Lean Gamma, a Lean Gamma Upgrade Procedure Audit, and Rysk Premium mk0 — **auditor names and
dates are UNKNOWN from the index page.** Who operates the RFQ server is **UNKNOWN**. Whether the
proxy owner is a timelock or a multisig is **UNKNOWN**. Rysk Premium adds a **curator** who
selects instruments, and governance that sets epoch prices and can withdraw fees independently.

### 3. REPO

- **There is no public core-contract repository.** `https://github.com/rysk-finance` has 20
  public repos. The V12-era ones are client-side only: `ryskV12-cli` (Go, MIT, pushed 2026-07-08,
  "cli to interact with rysk v12 as a MM"), `ryskV12_py` (MIT, 2026-07-07), `ryskV12_ts`
  (MIT, 2026-07-07). `rysk-finance/dynamic-hedging` — the V1 Dynamic Hedging Vault core —
  returns **HTTP 404**: removed or made private. Surviving Gamma-lineage repos: `gamma-portal`
  ("Manage assets on Opyn V2 (Gamma)"), `Gamma-Bots` ("Bots used for Gamma Protocol"),
  `ciao-protocol` (Solidity, GPL-3.0, 2025-02-20).
- **Commit/tag inspected:** not applicable to the core. For the client, `ryskV12-cli` HEAD as of
  `pushed_at` 2026-07-08.
- **License:** clients MIT; **core license UNKNOWN** (no repo, no published license).
- **Language:** Solidity for the deployed contracts (inferred from Sourcify compilation metadata);
  Go / Python / TypeScript for clients.
- **Do deployed contracts match a repo?** **No repo exists to match.** Source is nonetheless
  partially recoverable from on-chain verification: Ethereum `MarginPool`
  `0x684404F2AEBAD87a6803F13741B1d638Bfe2C671` is a Sourcify exact match; Ethereum `Rysk`
  processor `0x7A3dDEac7A0AE6dfA9391C764499A3564F3c2AAd` has no Sourcify record but its Etherscan
  address page reports a verified contract ("Exact Match", ABI present); Ethereum `MMarket`
  `0xc01c9EF5de5862354adD9501a29e8765cFF01c32` has **no Sourcify record and its Etherscan status
  is UNKNOWN** (page fetch blocked). HyperEVM addresses: MarginPool
  `0x24a44f1dc25540c62c1196FfC297dFC951C91aB4`, Rysk `0x8C8bcb6D2c0E31c5789253EcC8431cA6209B4E35`,
  MMarket `0x691a5fc3a81a144e36c6C4fBCa1fC82843c80d0d`; verification status **UNKNOWN**.
- **Top-level layout:** n/a for the core. `ryskV12-cli` is a single Go module exposing
  `approve`, `balances`, `connect`, quote-signing over a Unix socket.
- **Activity:** live and growing. $1.13M options notional/30d and ~$30.15M TVL on 2026-08-04 make
  it the third-largest venue by notional and the largest by "Options Vault" TVL. Client repos
  updated within the last month.

### 4. EVIDENCE

| Claim | Source | Accessed |
|---|---|---|
| RFQ replaces vault execution; per-position collateral; premiums upfront in USD; "physically settled" | https://docs.rysk.finance/getting-started/solution-rysk-v12 (.md) | 2026-08-04 |
| European; collateral locked to expiry; no rehypothecation/liquidation; Stork fixing; physical exchange at strike | https://docs.rysk.finance/getting-started/protocol-and-product/how-it-works.md | 2026-08-04 |
| Covered calls cash-settled, cash-secured puts physically settled (conflict noted) | https://docs.rysk.finance/getting-started/protocol-and-product/products.md and the Premium explainer | 2026-08-04 |
| 2-second aggregation window; signed quote fields; off-chain matching → on-chain settlement; maker USDT0 pre-deposit; oToken crediting | https://docs.rysk.finance/getting-started/protocol-and-product/makers-how-to-integrate-in-the-rfq.md | 2026-08-04 |
| Epochs, NAV per share, two-step withdrawal queue, off-chain NAV by a committee of option desks, curator, fee split | https://docs.rysk.finance/rysk-premium/rysk-premium-explainer.md | 2026-08-04 |
| Stork primary + Pyth cross-check + halt on divergence; Pendle API; 08:00 fixing; 5-minute contract-enforced manual dispute window | https://docs.rysk.finance/resources/oracle.md | 2026-08-04 |
| No early close; secondary market in development; settlement automatic within ~2h of 08:00 UTC | https://docs.rysk.finance/getting-started/protocol-and-product/faq.md · .../how-to-use-rysk.md | 2026-08-04 |
| Contract addresses on HyperEVM and Ethereum | https://docs.rysk.finance/resources/important-contracts.md | 2026-08-04 |
| Audit list (V12 mk0–mk3, Lean Gamma, Lean Gamma Upgrade Procedure, Premium mk0) | https://docs.rysk.finance/resources/security.md | 2026-08-04 |
| MarginPool is `OwnedUpgradeabilityProxy` from GammaProtocol, solc 0.6.10, exact match verified 2026-06-10 | `https://sourcify.dev/server/v2/contract/1/0x684404F2AEBAD87a6803F13741B1d638Bfe2C671?fields=compilation` | 2026-08-04 |
| `Rysk` processor verified on Etherscan ("Exact Match"); no Sourcify record | `https://etherscan.io/address/0x7A3dDEac7A0AE6dfA9391C764499A3564F3c2AAd` (HTML) + Sourcify null response | 2026-08-04 |
| Repo inventory; `dynamic-hedging` 404; V12 clients MIT | `gh api users/rysk-finance/repos`, `gh api repos/rysk-finance/dynamic-hedging` | 2026-08-04 |
| DHV sunset — "no more options available to be traded from May 10th 2024" | https://www.gate.com/learn/articles/what-is-rysk-finance/9672 (secondary; corroborated by Rysk V1 TVL of $193k on DefiLlama) | 2026-08-04 |
| TVL $30.15M ("Options Vault"), notional $1.13M/30d; Rysk Premium listed separately (Yield, $1.15M TVL, $11.7k/30d) — aggregator | `api.llama.fi/protocols`, `api.llama.fi/overview/options` | 2026-08-04 |

### 5. WHAT LOOKS UNNAMEABLE

1. **Loss absorption closed by construction.** Rysk has no `Ct`, no `Li`, no `Ad`, no `Sl` and no
   `Bs` — not because it forgot them but because escrowing the maximum payoff makes them
   unnecessary. The vocabulary has no way to *say* "the loss channel is closed"; its laws are
   written so that a risk-transfer symbol must be discharged by naming a solvency mechanism, which
   forces either a bad fit or a false residue. This is the single most important expressiveness
   gap this protocol exposes.
2. **A timed competitive quote window.** `Rf` names "a signed maker quote". Rysk runs a 2-second
   sealed aggregation with live competitiveness feedback, nonces and validity timestamps, then
   selects one winner. That is closer to a repeated sealed-bid auction than to a quote, and `Ba`
   (uniform-price batch clearing) is the wrong shape too.
3. **Maker admission by pre-funding.** A quote is only executable if the maker's USDT0 balance in
   the accounting contract covers it. This is a capital gate on *participation*, not on a position.
4. **Operator discretion inside the settlement fixing.** A 5-minute, contract-enforced dispute
   window in which a named team manually validates the settlement price for collateral assets.
   `Sv` (candidate, "servicing & determination discretion") is the nearest fit and is exactly the
   sort of thing the corpus flagged as unnamed for terminal fixing.
5. **Off-chain NAV by a committee of desks.** Rysk Premium's share price is set by an off-chain
   quorum of market participants. `At` is reserve/NAV attestation by a named attester with a
   stated assurance level; this is a *mark* produced by interested parties, with no disclosed
   attester identity, assurance standard or staleness bound.
6. **Curatorial instrument selection with a fee split.** A named curator chooses which options the
   pool writes and takes a share of the option-sale fee. `Sv` again is the nearest and is about
   servicing, not selection.
7. **The protocol is partly another protocol.** The settlement layer is a fork of Opyn Gamma
   behind an owner-controlled proxy. Nothing in the vocabulary can express "this mechanism is a
   vendored third-party protocol with its own upgrade authority."
8. **A withdrawal queue whose price is set at the epoch in which it clears.** `Wq` names a queue;
   it does not name the fact that the *price* you receive is the price at an unknown future epoch,
   which is an option the LP has written without knowing it.

### 6. DELTA vs the corpus record — the largest in this category

- **The corpus decomposes a protocol that no longer exists.** Corpus elements
  `[Ct, Dp, Em, Ep, Ex, Gp, Op, Sh, Up, Wq]` with residue "the vault's entire economic content is
  a STRIKE-AND-TENOR SELECTION POLICY run each epoch" and a marker on `Dp` for "delta-hedge
  maintenance" describe the **Dynamic Hedging Vault of Rysk V1 / Rysk Beyond on Arbitrum**, which
  was sunset — no options tradeable after 2024-05-10 — and whose core repository has been removed
  from GitHub. Rysk V12 has **no delta hedge**, **no vault in the core protocol**, and the
  **taker** chooses strike and tenor. Cite:
  https://docs.rysk.finance/getting-started/solution-rysk-v12,
  `gh api repos/rysk-finance/dynamic-hedging` → 404, DefiLlama "Rysk V1" TVL $193k vs "Rysk V12"
  $30.15M.
- **`Dp` should not be present.** No hedging loop exists in V12.
- **`Rf` is missing and is the protocol's defining symbol.** The corpus residue says "no element
  for the counterparty side — the vault sells to market makers via an auction or RFQ". `Rf` is in
  the vocabulary and is the right symbol; this is a decomposition omission, not a residue.
- **`Ep` and `Wq` belong to Rysk Premium, not Rysk V12.** DefiLlama lists them as separate
  protocols. The corpus record fuses them.
- **Chain is wrong by implication.** V12 is on **HyperEVM and Ethereum**; the corpus's Arbitrum-era
  framing is inherited from V1.
- **`armedProhibitions: []` deserves re-examination.** The Ethereum MarginPool is an
  `OwnedUpgradeabilityProxy` and no timelock is documented, which is the shape of **X9** ("`Up`
  with immediate single-key control"). Whether the owner is a multisig or a timelock is
  **UNKNOWN**, so I do not assert the prohibition is armed — I record that the corpus's blanket
  "none" is unsupported.
- **`satisfiesRequirementsAndWarrants: false`.** On the design, this rejection is *diagnostically
  wrong*: nothing is "left open". Full pre-funding closes it. See §5.1.
- **Ranking numbers.** Corpus $29.86M TVL / $1.21M notional-30d / "#3 by volume"; live $30.15M /
  $1.13M / #3. Consistent.

---

## Hegic

### 1. WHAT IT DOES

A buyer picks one of a fixed catalogue of *deployed strategy contracts* — an ETH or BTC call
struck at 100/110/120/130% of spot, a put at 70/80/90/100%, or a spread, straddle, strangle,
strap, strip, inverse butterfly or inverse condor — and a holding period, and pays a USDC premium
computed on-chain by that instrument's own `PriceCalculator`. The buyer receives an ERC-721
position. There is no counterparty in the usual sense: the **Hegic Operational Treasury** is the
writer of every position. At purchase, `OperationalTreasury.buy` locks `negativePNL` — the maximum
possible payoff — out of the treasury's USDC and adds the premium to `lockedPremium`. The buyer
realises the payoff by calling `payOff`, which requires that the position is still unexpired
(`ll.expiration > block.timestamp`) and that the payoff is positive and the position is inside the
strategy's exercise window; the treasury then pays the net P&L in USDC. **An in-the-money position
that is never claimed before expiry pays nothing** — `unlock` simply returns the reserved
liquidity to the treasury. There is no per-position margin and no liquidation, because the pool's
obligation is pre-locked. The system's solvency is a *global* invariant enforced on every write:
`totalLocked + lockedPremium <= totalBalance() + coverPool.availableForPayment()`. If treasury
USDC is short of a payout, `_replenish` draws from the **Stake & Cover pool**, which is
capitalised in **HEGIC**, the protocol's own token, converted to USDC at an admin-set
`changingPrice`. Beyond that there is no backstop; the only thing preventing the pool from writing
itself insolvent is a per-strategy `lockedLimit` and a global `LimitController.limit()`.

### 2. DESIGN

**(a) Exercise style — early-exercisable inside a window, not European and not fully American.**
`OperationalTreasury.payOff` requires `ll.expiration > block.timestamp`; `HegicStrategy.
isPayoffAvailable` requires `positionExpiration[positionID] < block.timestamp +
exerciseWindowDuration`. Together: exercise is permitted only in the final `exerciseWindowDuration`
before expiry, and never after. (The earlier V8888 generation was documented as American,
exercisable any time; Herge narrowed it.)

**(b) Settlement — cash, in USDC.** The treasury pays `strategy.payOffAmount(positionID)`, a net
P&L, not a delivery.

**(c) Underwriting — peer-to-pool.** One treasury is the counterparty to every position. This is
the protocol's defining mechanism.

**(d) Premium — upfront**, transferred at `_lockLiquidity` time
(`token.safeTransferFrom(msg.sender, address(this), positivepnl)`).

**(e) Margin — neither isolated nor portfolio. Pre-funding plus notional caps.** The pool locks
max loss per position; the controls are `lockedLimit` per strategy contract and
`LimitController.limit()` globally, both admin-set.

**(f) Pricing — model-priced, but the "model" is a per-instrument on-chain calculator with
admin-set parameters.** `IVLPriceCalculator` carries a single `impliedVolRate` scalar changed by
`setImpliedVolRate` under `DEFAULT_ADMIN_ROLE`; `PolynomialPriceCalculator` carries five `int256`
coefficients over the period, set by `setCoefficients` under the same role; a `BlackScholes.sol`
library exists in the v8888 package. **There is no surface.** The deployment commits one
`PriceCalculator_*` contract per (payoff × strike bucket × asset) — 60+ of them on Arbitrum — so
what a surface would express as a function of two arguments is here expressed as a directory of
addresses each holding a scalar or a quartic in time.

**Collateral and liquidation path.** None in the margin sense. The loss waterfall is:
(1) Operational Treasury USDC; (2) Stake & Cover pool HEGIC, sold to the treasury at
`epoch[currentEpoch].changingPrice`; (3) refusal to write new risk (the `require` in
`_lockLiquidity`). Cover providers mint an ERC-721 `Hegic Herge Stake & Cover` (`HEGSC`); they may
only `provide` or `withdraw` within `windowSize = 5 days` of an epoch start; epochs run at least
`MINIMAL_EPOCH_DURATION = 7 days`; `fallbackEpochClose` is callable by anyone after 90 days; the
admin's `fixProfit` closes an epoch and distributes accumulated USDC.

**Oracle.** Chainlink, via `AggregatorV3Interface priceProvider` on each strategy. Committed
Arbitrum addresses: `PriceProviderETH 0x639Fe6ab55C921f74e7fac1ee960C0B6293ba612`,
`PriceProviderBTC 0x6ce185860a4963106506C203335A2910413708e9`. Strikes are *relative to spot at
purchase* (`ScaledStrikePriceCalculator` with a `priceCorrectionRate`), which is why the catalogue
is expressed in percentages rather than absolute strikes.

**Control plane.** OpenZeppelin `AccessControl`. `DEFAULT_ADMIN_ROLE` can:
`setImpliedVolRate`, `setCoefficients`, `setPeriodLimits`, `setBenchmark`,
`addStrategy` / `connectStrategy` (delayed by one or two cover-pool epochs),
`withdraw(address to, uint256 amount)` **directly from the Operational Treasury**, `replenish`,
`setNextEpochChangingPrice`, `setWindowSize`, `setPayoffPool`, `fixProfit`. **No timelock appears
in the code read.** There is **no proxy**: the Herge contracts are plain and immutable, with
mutability achieved through role-gated setters and by deploying and connecting new strategy
contracts. Who holds `DEFAULT_ADMIN_ROLE` on the live Arbitrum deployment is **UNKNOWN**.

### 3. REPO

- **URL:** `https://github.com/hegic/contracts`.
- **Commit inspected:** `54833086acc17d2a2bf90229040c456f2fda2624`, branch `main`, message
  "strategies", signed off by `0mllwntrmt3 <molly.wintermute@protonmail.com>`, **dated
  2022-12-26**. Repository `pushed_at` 2022-12-26. **No tags, no releases.**
- **License:** GPL-3.0 (repo-level), and the sources carry
  `SPDX-License-Identifier: GPL-3.0-or-later`, "Hegic Copyright (C) 2022 Hegic Protocol".
- **Language:** Solidity ^0.8.3 under a TypeScript/Hardhat Lerna monorepo.
- **Deployed contracts match the repo — yes, and the repo is the only current documentation.**
  `packages/herge/deployments/arbitrum/.addresses.json` commits the live set, including
  `OperationalTreasury 0xec096ea6eB9aa5ea689b0CF00882366E92377371`,
  `CoverPool 0xd47Ef934e301E0ee3b1cE0e3EEbCb64De8b231BE`,
  `PositionsManager 0x5Fe380D68fEe022d8acd42dc4D36FbfB249a76d5`,
  `LimitController 0xE0E331BACbe793F4216d3faBBac3192AddC1dC7c`,
  `ProfitCalculator 0x51b62c2620c6A62154C039547C014EBa00ce2665`,
  `HEGIC 0x431402e8b9de9aa016c743880e04e517074d8cec`,
  `USDC 0xff970a61a04b1ca14834a43f5de4533ebddb5cc8`, plus ~200 `HegicStrategy_*` and 60+
  `PriceCalculator_*` addresses. An in-repo audit PDF
  (`packages/herge/docs/PeckShield-Audit-Report-Hegic-Herge-Protocol-Upgrade-v1.0.pdf`) covers the
  Herge upgrade.
- **Top-level layout:** `packages/{hardcore-beta, herge, utils, v8888}` under `lerna.json`.
  `packages/herge/contracts/`: `CoverPool.sol`, `ICoverPool.sol`, `IOperationalTreasury.sol`,
  `MainPool.sol`, `OperationalTreasury.sol`, `ProfitDistributor.sol`, `ReinvestmentPool.sol`,
  `PositionsManager/`, `Strategies/` (14 payoff contracts + `LimitController.sol`,
  `ProfitCalculator.sol`). `packages/v8888/contracts/PriceCalculators/`:
  `AdaptivePriceCalculator`, `BasePriceCalculator`, `BlackScholes`, `CombinedPriceCalculator`,
  `IVLPriceCalculator`, `PolynomialPriceCalculator`, `ScaledPolynomialPriceCalculator`,
  `ScaledStrikePriceCalculator`.
- **Activity — dormant. Stated with evidence.** Core code frozen since **2022-12-26**. The
  front-end repo `hegic/herge-pages` shows `pushed_at` 2026-06-22 but its HEAD **commit** is dated
  2022-10-26, i.e. a re-push of a three-year-old tree. The public documentation at
  `hegic.gitbook.io/start` still describes **V1** — "ETH Liquidity Pool", "DAI Liquidity Pool",
  "How to Sell Call Options" — a design two generations behind the deployed Herge system, with a
  single developer page at `hegic.gitbook.io/developers/contracts`. DefiLlama on 2026-08-04
  reports **$14,842 of options notional over 30 days and $0 over 24 hours**, against $8.98M of
  TVL. The honest characterisation is: **capital parked, flow near zero, code and docs frozen.**

### 4. EVIDENCE

| Claim | Source | Accessed |
|---|---|---|
| Treasury is sole writer; `negativePNL` locked at purchase; global solvency `require`; `_replenish` from CoverPool; admin `withdraw`/`replenish`/`setBenchmark`; epoch-delayed strategy connection | `gh api repos/hegic/contracts/contents/packages/herge/contracts/OperationalTreasury.sol` | 2026-08-04 |
| Exercise window (`exerciseWindowDuration`, `isPayoffAvailable`); per-strategy `lockedLimit`; global `LimitController.limit()`; Chainlink `priceProvider`; `IPremiumCalculator pricer` | `.../packages/herge/contracts/Strategies/HegicStrategy.sol` | 2026-08-04 |
| CoverPool is `Hegic Herge Stake & Cover` ERC-721, `coverToken` = HEGIC, `profitToken` = USDC, `windowSize = 5 days`, `MINIMAL_EPOCH_DURATION = 7 days`, `fallbackEpochClose` after 90 days, admin `setNextEpochChangingPrice` / `fixProfit` / `setPayoffPool` | `.../packages/herge/contracts/CoverPool.sol` | 2026-08-04 |
| `impliedVolRate` admin scalar; `settlementFeeShare = 20`; strike scaled to spot | `.../packages/v8888/contracts/PriceCalculators/IVLPriceCalculator.sol` | 2026-08-04 |
| Five admin-set polynomial coefficients over period | `.../packages/v8888/contracts/PriceCalculators/PolynomialPriceCalculator.sol` | 2026-08-04 |
| Live Arbitrum addresses incl. treasury, cover pool, HEGIC, USDC, Chainlink providers, ~200 strategies | `.../packages/herge/deployments/arbitrum/.addresses.json` | 2026-08-04 |
| Repo license GPL-3.0; HEAD commit `5483308…` dated 2022-12-26; no tags | `gh api repos/hegic/contracts`, `/commits`, `/tags` | 2026-08-04 |
| `herge-pages` HEAD commit dated 2022-10-26 | `gh api repos/hegic/herge-pages/commits` | 2026-08-04 |
| Public docs still describe V1 (ETH/DAI pools) | https://hegic.gitbook.io/start/llms.txt | 2026-08-04 |
| Hegic described as "on-chain peer-to-pool options trading protocol" (org repo description) | `gh api orgs/hegic/repos` (`hegic-frontend` description) | 2026-08-04 |
| American, cash-settled ETH/WBTC options; Chainlink price + IV factor manually fetched; 50–100% collateralisation at V8888 launch (historical, secondary) | https://www.defisafety.com/app/pqrs/58 and https://medium.com/hegic/ (V8888-era) | 2026-08-04 |
| $8.98M TVL, largest in DefiLlama's "Options" category; $14,842/30d, $0/24h notional (aggregator) | `api.llama.fi/protocols`, `api.llama.fi/overview/options` | 2026-08-04 |

### 5. WHAT LOOKS UNNAMEABLE

1. **Peer-to-pool payoff underwriting.** Confirmed exactly as the corpus states: one treasury is
   the counterparty to every option. `Pl` is lending; `Cv` requires adjudication; neither fits.
2. **Pre-locked maximum loss as the solvency primitive, enforced as a global inequality.**
   `totalLocked + lockedPremium ≤ totalBalance() + coverPool.availableForPayment()` is a
   *balance-sheet* constraint checked at write time, not a per-position ratio checked continuously.
   `Ct` cannot express it and `Li` has nothing to do.
3. **Notional caps as the only utilisation control.** `lockedLimit` per strategy and
   `LimitController.limit()` globally. This is the thing that stops the pool selling itself
   insolvent, and it is an admin-set scalar, not a pricing response.
4. **Instrument identity as contract deployment.** The listing process is `addStrategy` +
   `connectStrategy` with a one- or two-epoch delay. There is no calendar, no expiry cycle and no
   strike grid; there is a directory of 200 addresses. Nothing names "listing is deployment".
5. **An administered implied volatility.** A single `impliedVolRate` scalar per instrument,
   settable by an admin transaction. This is the degenerate limit of a volatility surface, and the
   vocabulary has neither the general object nor the limit.
6. **A protocol-token backstop with an administered conversion price.** The Stake & Cover pool
   holds HEGIC and is drawn down at `changingPrice`, a value the admin sets for the next epoch.
   `Bs` says "slashable first-loss capital" and says nothing about denomination, about the epoch
   gating of entry and exit, or about the fact that the *price at which the backstop is worth
   anything is set by the entity it backstops*.
7. **Exercise discipline.** The buyer must actively claim inside a window; an unclaimed ITM
   position expires worthless and the reserve returns to the pool. This is a real transfer of value
   from inattentive holders to the pool that no symbol names.
8. **Composed payoffs as first-class instruments.** Straddles, strangles, straps, strips, spreads,
   inverse butterflies and condors are each their own deployed contract with its own pricer and
   its own limit — not compositions assembled by the user.

### 6. DELTA vs the corpus record

- **`Up` looks wrong.** Corpus canonical form is `[Ex, Gp, Op, Sh, Up]`. The Herge contracts read
  (`OperationalTreasury.sol`, `HegicStrategy.sol`, `CoverPool.sol`) are plain `AccessControl`
  contracts with immutable constructor arguments; there is no proxy, no initializer and no
  implementation slot. Mutability is by role-gated setter and by deploying new strategy contracts,
  which is a different mechanism from `Up` ("mutable implementation proxy"). Cite: the three source
  files above, 2026-08-04.
- **`armedProhibitions: []` is likely wrong.** The cover pool's `coverToken` is HEGIC and its
  USDC-equivalent value is fixed by `setNextEpochChangingPrice` under `DEFAULT_ADMIN_ROLE` — a
  protocol-token backstop whose price source is an admin, which is most of **X3** ("Protocol token
  as collateral AND oracle market AND backstop"). Separately, `OperationalTreasury.withdraw(address,
  uint256)` is `DEFAULT_ADMIN_ROLE` with no timelock in code, which is **X9**-shaped even without a
  proxy. Cite: `CoverPool.sol` lines around `nextEpochChangingPrice` / `payOut`;
  `OperationalTreasury.sol` `withdraw`.
- **`Bs` is absent from the corpus decomposition and arguably should not be.** The corpus residue
  says nothing in the vocabulary names the peer-to-pool writer — true — but the Stake & Cover pool
  *is* first-loss capital sitting behind the treasury, which is closer to `Bs` than to anything
  else. Whether the decomposer's omission is right depends on how literally "slashable" is read.
  Recording it as a discrepancy rather than an error.
- **Exercise style.** The corpus's `Op` marker treats Hegic as an instance of
  "strike/expiry/collateralized settlement". The exercise semantics are a *window before* expiry
  with forfeiture after, which is neither of the two styles the corpus's axis (a) offers.
- **The residue claim "premium pricing is a utilization-scaled IV formula" is not what the code
  says.** In Herge, the pricer takes no utilisation argument; utilisation is handled separately by
  `lockedLimit`/`LimitController` as a hard cap. The utilisation-scaled premium is a **V1-era**
  design. Cite: `HegicStrategy.sol` `calculateNegativepnlAndPositivepnl` and
  `IVLPriceCalculator.calculateTotalPremium`.
- **Dormancy should be recorded as a first-class finding, not a parenthesis.** Corpus says
  "functionally dormant by volume, noted". Stronger evidence available: core commits stopped
  2022-12-26, public docs describe a design two generations old, and 24h notional is $0.
- **Ranking numbers.** Corpus $9.00M TVL / $0.01M notional-30d; live $8.98M / $14,842. Consistent,
  and Hegic remains the largest TVL in DefiLlama's pure "Options" category.

---

## Aevo (Ribbon Finance lineage)

### 1. WHAT IT DOES

A buyer deposits USDC (or other accepted collateral) into a cross-margin account on the Aevo
rollup and buys a European, cash-settled option on the Aevo index, paying the premium upfront
through an off-chain order book, an RFQ/block-trade rail, or the OTC desk. A writer holds the
short side in the *same* account, which also carries their perpetual futures positions: options
and perps share one margin computation and one collateral pool. Orders are checked against
Standard or Portfolio margin by an **off-chain risk engine** before entering the book, and "once a
maker and taker order gets matched, only then do they get posted on Aevo's smart contracts". The
payoff is determined at 08:00 UTC expiry against the Aevo index and paid in USDC. If a writer's
account breaches `AB − OO − MM > 0` (account balance minus open orders minus maintenance margin),
the **Liquidation Engine** seizes the account: open orders are cancelled to free collateral, then
the engine works the position out with limit orders posted "every 2 seconds, for a maximum duration
of 30 seconds"; if the book cannot absorb it, the **insurance fund** takes the position at a
markup; if the insurance fund is insufficient, **auto-deleveraging** closes the most profitable
opposing traders at mark price. Liquidation fees are charged on both order-book and insurance-fund
fills. The Ribbon DeFi Options Vaults that gave the protocol its name — a peer-to-pool layer
selling weekly options into auctions — were **exploited on 2025-12-12 for ~$2.7M (≈32% of the
affected vault) following an oracle upgrade, and have been halted and are being decommissioned
with a compensation mechanism**; the L2 exchange was unaffected.

### 2. DESIGN

**(a) Exercise style — European.**

**(b) Settlement — cash, in USDC.** Expiries Daily, Weekly, Monthly and Quarterly at 08:00 UTC,
out to about three months. Live ETH instruments carry `quote_asset: "USDC"`, `price_step: "0.1"`,
`min_order_value: "0.01"`, `max_notional_value: "10000000"`, `price_band: "0.7"` and per-instrument
greeks including `iv`.

**(c) Underwriting — peer-to-peer.** CLOB plus RFQ/block trades (`/rfqs`, `/quotes`) plus a
separate OTC product with an `/otc/unwind` endpoint. The peer-to-pool layer (Ribbon DOVs) is gone.

**(d) Premium — upfront.**

**(e) Margin — both, and *cross* across instrument types.** Standard Margin "evaluates the margin
for every position on a user's portfolio individually, not holistically". Portfolio Margin is
**Scenario Margin + Floor Margin**. Scenario Margin evaluates **15 scenarios** — three spot
movement levels (up 100%, up 50%, unchanged, down 50%, down 100% of the maximum move) crossed with
five IV shift positions — under initial-ETH-phase parameters *Max. Spot Movement Up 20%*, *Down
20%*, *Max. IV Shift Up 50%*, *Down 25%*. Floor Margin = `Net Short Exposure(Option) × Unit Floor
Margin`, with Unit Floor Margin 0.01 ETH in the initial ETH phase. Initial margin is 1.25 ×
maintenance.

**(f) Pricing — order-book priced.** Aevo publishes no pricing model; the exchange computes mark
prices and greeks internally and exposes them via `/markets`. The IV shown per instrument is an
exchange output, not a published surface parameterisation.

**Collateral and liquidation path.** A cross-margin collateral framework with multiple accepted
assets, plus `aeUSD` (its own deposit/redemption/composition regime) and a spot-convert feature.
Loss absorption ordering: liquidation via the book → insurance fund at a markup → auto-deleveraging
against the most profitable opposing traders at mark price. "Auto-deleveraging distributes losses
among the most profitable traders rather than concentrating risk on a single counterparty."
Insurance fund size is **UNKNOWN**.

**Oracle.** "Aevo uses a custom internal oracle to report the value of the various asset prices to
the exchange." The ETH index is built by (i) excluding "the exchanges that are disconnected,
administratively turned off, and with detected invalid data"; (ii) taking the median across
remaining sources; (iii) discarding any source deviating more than **0.5%** from the median;
(iv) taking a simple **unweighted average** of the survivors. Venue set: Coinbase, Binance, OKX,
BitGet, ByBit, Huobi, GateIo, BitFinex, Kraken, BitStamp. **The settlement-price observation
window at expiry is not documented — UNKNOWN.**

**Control plane.** "An EVM-based Ethereum optimistic roll-up" built for the exchange, whose
sequencer is **operated with Conduit** and "posts batches of transactions to Ethereum Mainnet every
1 hour", with "the dispute period for transactions on the Aevo Rollup is 2 hours" and a 2–3 hour
total confirmation window. Deposits use the Optimism Standard Bridge (~10 minutes). **No forced
withdrawal or escape hatch is documented — UNKNOWN**, which is a substantive contrast with Derive.
Governance: AEVO token (RBN migrated 1:1), AGP proposals, a governance portal, a DAO treasury with
a Treasury and Revenues Management Committee and a Growth & Marketing Committee, and a
buyback-and-burn system.

### 3. REPO

- **There is no public repository for the deployed exchange.** `https://github.com/aevoxyz`
  contains exactly two public repos: `audit` (five PDFs — `Ribbon-report.pdf`, `VAR_Ribbon.pdf`,
  `VAR_Ribbon_230604.pdf`, `VAR-Ribbon230918.pdf`,
  `VAR_Ribbon_240116_aevo_governance_2-V1.pdf`; `pushed_at` 2024-04-17) and `aevo-sdk` (Python, no
  license, `pushed_at` 2024-03-12).
- **The open code is the Ribbon lineage, and it is the decommissioned part.**
  `https://github.com/ribbon-finance`: `ribbon-v2` ("Ribbon V2 for Theta Vaults", TypeScript +
  Solidity, **no license**, last push 2023-07-31, top level `contracts/`, `deployments/`,
  `constants/`, `scripts/`, `test/`, `hardhat.config.ts`); `GammaProtocol` (Unlicense, 2022-02-23);
  `GammaProtocol-OTC` (Unlicense, 2023-09-26); `core-cash` (MIT, 2023-09-15); `rvol`
  ("RVOL makes on-chain volatility data accessible", GPL-3.0, 2022-10-17); `ribbon-v1` (MIT, 2021).
  The only repos in that org updated recently are peripheral: `ribbon-frontend` (2026-07-21),
  `aevo-trading-skills` (2026-03-10), `aevo-mcp` (MIT, 2026-02-26).
- **Commit/tag inspected:** none for the exchange (nothing to inspect). For the lineage,
  `ribbon-finance/ribbon-v2` at its final push 2023-07-31.
- **License:** exchange **UNKNOWN / not published**; `ribbon-v2` has **no license file**;
  GammaProtocol is Unlicense.
- **Language:** Solidity + TypeScript for the lineage; exchange stack **UNKNOWN** beyond "EVM
  rollup" and a Python SDK.
- **Do deployed contracts match the repo?** **Unanswerable — there is no repo for the deployed
  system.** The matching engine, the off-chain risk engine, the L2 settlement contracts, the
  insurance fund and the index oracle are all closed-source.
- **Activity — the exchange is live; the vault lineage is dead.** `GET
  api.aevo.xyz/markets?asset=ETH&instrument_type=OPTION` returned **686 live ETH option
  instruments** on 2026-08-04. The docs index (llms.txt) has no options-vault section: under
  "Aevo Strategies" the only entry is "Aevo Basis Trade". Ribbon repos in the same org have not
  had a core commit since 2023.

### 4. EVIDENCE

| Claim | Source | Accessed |
|---|---|---|
| Off-chain book + off-chain risk engine; only matched orders posted on-chain | https://docs.aevo.xyz/aevo-products/aevo-exchange/technical-architecture/exchange-structure/off-chain-orderbook-and-risk-engine.md | 2026-08-04 |
| Liquidation trigger `AB − OO − MM > 0`; engine seizes account; 2-second limit orders for up to 30s; insurance fund at markup; ADL against most profitable traders; liquidation fees | https://docs.aevo.xyz/aevo-products/aevo-exchange/technical-architecture/liquidations.md | 2026-08-04 |
| Portfolio margin: 15 scenarios, ±20% spot, +50%/−25% IV, Floor Margin = net short exposure × unit floor margin (0.01 ETH), IM = 1.25 × MM | https://docs.aevo.xyz/aevo-products/aevo-exchange/technical-architecture/margin-framework/portfolio-margin.md | 2026-08-04 |
| Standard margin evaluates positions individually | https://docs.aevo.xyz/aevo-products/aevo-exchange/technical-architecture/margin-framework.md (via search snippet) and the standard-margin page | 2026-08-04 |
| Index construction: exclude invalid venues → median → drop >0.5% outliers → unweighted mean; 10 named venues | https://docs.aevo.xyz/aevo-products/aevo-exchange/technical-architecture/index-price.md | 2026-08-04 |
| ETH options: Aevo ETH Index underlying, USDC settlement, $0.01 tick, Daily/Weekly/Monthly/Quarterly at 08:00 UTC | https://docs.aevo.xyz/aevo-products/aevo-exchange/trading-on-aevo/options-specifications/eth-options.md | 2026-08-04 |
| Optimistic rollup, Conduit sequencer, hourly batches, 2-hour dispute period, Optimism Standard Bridge | https://docs.aevo.xyz/aevo-products/aevo-exchange/technical-architecture/exchange-structure/layer-2-architecture.md | 2026-08-04 |
| Full page index (no options-vault section; Strategies = Basis Trade only; RFQ/OTC endpoints exist) | https://docs.aevo.xyz/llms.txt | 2026-08-04 |
| 686 live ETH option instruments, per-instrument greeks/IV, price_band 0.7, max notional 10,000,000 | `GET https://api.aevo.xyz/markets?asset=ETH&instrument_type=OPTION` | 2026-08-04 |
| `aevoxyz` has only `audit` and `aevo-sdk`; Ribbon core repos last pushed 2022–2023 | `gh api orgs/aevoxyz/repos`, `gh api orgs/ribbon-finance/repos` | 2026-08-04 |
| Ribbon DOV exploit 2025-12-12, ~$2.7M ≈ 32% of the affected vault, following an oracle upgrade; vaults halted and being decommissioned; exchange unaffected | https://www.theblock.co/post/382461/aevos-legacy-ribbon-dov-vaults-exploited-for-2-7-million-following-oracle-upgrade (press; corroborated by the absence of any vault section in docs.aevo.xyz/llms.txt) | 2026-08-04 |
| Aevo Options $1.83M notional/30d, #2 by options volume; Aevo Perps $14.66M TVL; Ribbon $3.44M TVL (aggregator) | `api.llama.fi/overview/options`, `api.llama.fi/protocols` | 2026-08-04 |

### 5. WHAT LOOKS UNNAMEABLE

1. **The four Derive-shared gaps hold**: scenario margin as an object, a pricing/vol model,
   instrument listing, terminal fixing (and here the fixing is worse — the settlement window is
   not even documented).
2. **Floor Margin.** A per-unit charge on *net short option exposure*, added to the scenario
   result. Structurally it is a floor placed under a max-over-scenarios. The vocabulary has no way
   to compose a scalar floor with a grid.
3. **A liveness-filtered, outlier-trimmed, unweighted multi-venue index.** `Ex` says
   "push/pull/medianizer". Here the median is used only as a *filter*, the output is a mean, venues
   can be "administratively turned off", and the venue list is itself governed. That is three
   distinct decisions the symbol collapses.
4. **A third-party sequencer as the finality of a derivatives ledger.** Conduit runs the sequencer;
   batches land hourly; the dispute period is two hours. `Xm` names message verification; nothing
   names *who orders the transactions*, at what cadence, and what that implies for liquidation
   timeliness.
5. **Auto-deleveraging ranked by profitability.** `Ad` says "rank-ordered forced close" without
   saying what the rank is. Ranking by counterparty PnL makes ADL a levy on being right, which is a
   materially different risk than a rank by leverage or by time.
6. **Progressive loss absorption across three distinct venues** (book → insurance fund → ADL), each
   with its own price basis (limit orders → markup → mark price). `Li`, `Bs` and `Ad` name the
   pieces but not the ordering, the escalation triggers or the price-basis change at each step.
7. **A product-line decommissioning with compensation.** The DOV shutdown is an act of protocol
   governance that reassigns realised losses. Nothing names an orderly wind-down.
8. **An OTC desk with a protocol-level unwind primitive** (`/otc/create-request`, `/otc/unwind`) —
   bespoke bilateral instruments settled by the same margin system.

### 6. DELTA vs the corpus record

- **`identicalClaimedByLane: [["Derive","Aevo"]]` is wrong, and the corpus residue entry
  "Identical residue to Derive" inherits the error.** Differences that matter to any construction:
  *scenario geometry* — Aevo 15 scenarios (3 spot × 5 IV, ±20% spot, +50%/−25% IV) vs Derive 23
  scenarios (±18% in 4.5% steps) plus separate tail, skew and forward-loss families; *margin
  floor* — Aevo has a Floor Margin on net short exposure, Derive has contingency terms and an
  oracle contingency instead; *price source* — Aevo builds its own index from 10 CEX feeds with a
  0.5% trim, Derive consumes signed SVI/forward/rate feeds from Block Scholes with confidence
  scores; *loss absorption* — Aevo has an insurance fund **and auto-deleveraging**, Derive has a
  Dutch auction, a treasury security module and a socialised withdrawal fee and **no documented
  ADL**. Cites as in §4 above and in Derive §4.
- **`Ad` is missing from Aevo's element set and should be there.** Corpus elements are
  `[Ct, Em, Ex, Gp, Li, Ob, Op, Pf, Sh, Up, Xf, Xm]` with no `Ad`, despite the docs describing
  auto-deleveraging both in the liquidation page and as its own page. Cite:
  https://docs.aevo.xyz/aevo-products/aevo-exchange/technical-architecture/auto-deleveraging-adl.md
  (listed in llms.txt) and the liquidations page.
- **The Ribbon-auction residue is historical, not current.** Corpus: "The Ribbon DOV heritage
  (structured vaults selling into a weekly auction) adds: no element for a periodic sealed-bid
  AUCTION of a bespoke instrument." As of 2026-08-04 the DOVs are halted and being decommissioned
  after the 2025-12-12 exploit, and the docs carry no vault section. The observation about `Ba` and
  `Da` remains a valid *vocabulary* finding but is no longer a fact about the ranked protocol.
- **"No element for the migration of user balances between a rollup and L1 as an operational
  primitive distinct from bridging" is not evidenced in current docs.** What is documented is a
  standard Optimism-bridge deposit and a 2–3 hour withdrawal. If a migration primitive existed it
  was a Ribbon-era artefact. Marking the corpus residue item as **unsupported**.
- **`Ob` marker is right for the reason given, and there is a second problem.** Beyond off-chain
  matching, Aevo has **no documented escape hatch**, so the trust assumption is strictly stronger
  than Derive's — the same symbol is doing even more work here than there.
- **Ranking numbers.** Corpus $1.65M notional/30d, #2. Live $1.83M/30d, still #2. Consistent.

---

## Panoptic V2

### 1. WHAT IT DOES

Everyone begins by depositing token0 and/or token1 into two ERC-4626 `CollateralTracker` vaults
and becoming a Panoptic Liquidity Provider. An option **seller** borrows that pooled liquidity and
deploys it into a concentrated Uniswap V3 or V4 range; an option **buyer** borrows the seller's
chunk back *out* of Uniswap and holds the tokens. Removing the liquidity is what makes the option:
the seller's LP payoff becomes a short option and the buyer's becomes a long one. There is no
strike as a number — the position is a tick range, encoded with up to four legs in an ERC-1155
tokenId — and **no expiry**: "Panoptions are perpetual and never expire." The buyer pays **no
upfront premium**; instead they owe **streamia**, a per-block stream equal to the Uniswap swap fees
the removed liquidity would have generated, multiplied by a spread multiplier that grows with the
utilisation of that specific chunk (governed by `VEGOID = 8`, ν = 1/VEGOID). Streamia accrues only
while spot is inside the position's range. Sellers separately pay interest to PLPs on the borrowed
liquidity at a PID-controlled adaptive rate. Solvency is computed by a standalone `RiskEngine`
against one oracle tick in normal conditions and **four** (spot EMA, internal median, latest
observation, current tick) when the oracle disagrees with itself or safe mode is on. A liquidator
closes an insolvent account's positions and takes
`Bonus = min{Collateral Balance / 2, Collateral Requirement at TWAP − Collateral Balance at TWAP}`;
any residual is absorbed first by a haircut on unsettled premia and then as protocol loss borne by
the CollateralTracker, i.e. by PLPs. A seller can also **force-exercise** a buyer's out-of-range
long to reclaim their liquidity, paying the exercised user a fee that decays exponentially with
distance from strike (`FORCE_EXERCISE_COST = 30_000` scaled units, floored at `ONE_BPS = 1000`).

### 2. DESIGN

**(a) Exercise style — perpetual.** No expiry, no elected exercise. The only exercise-like event is
*force exercise*, initiated by the counterparty, not the holder.

**(b) Settlement — neither cash nor physical as normally meant.** The payoff is realised
continuously as the underlying Uniswap position's composition changes with price; closing a
position burns it and returns tokens. There is no terminal fixing to determine.

**(c) Underwriting — AMM-derived, over a pooled credit rail.** The counterparty is whoever's
liquidity chunk you removed; the liquidity itself is borrowed from a shared ERC-4626 pool. So this
is peer-to-peer in exposure, peer-to-pool in funding, and AMM-derived in payoff shape — three of
the corpus's axis-(c) categories at once.

**(d) Premium — streamed, and *generated* rather than quoted.** "Rather than paying a large premium
upfront, buyers pay smaller, continuous fees based on actual trading activity in Uniswap"; "Option
buyers pay streamia, while option sellers receive streamia"; streamia accrues per block and only
in-range. Plus a separate interest payment from sellers to PLPs.

**(e) Margin — utilisation-scaled, cross-collateralised, multi-price; per-pool isolated.** The
RiskEngine computes "required collateral for complex option strategies including spreads,
strangles, iron condors, and synthetic positions based on position composition and pool
utilization", verifies solvency via `isAccountSolvent` "accounting for cross-collateralization
between token0 and token1" (`CROSS_BUFFER_0`, `CROSS_BUFFER_1`), and scales requirements with
utilisation up to `SATURATED_POOL_UTIL = 9_000_000` (of `DECIMALS`). Documented example:
selling an OTM put starts at 20% collateralisation and rises as it moves ITM per
`Buying Power Requirement = notionalSize · (100% − S/K)`. Leverage up to 10× buying / 5× selling
"under normal market conditions", "dynamic and change in response to pool utilization". This is
*not* a scenario grid over shocks — it is a conjunction of solvency tests at several *prices*.

**(f) Pricing — a fourth regime the corpus's axis does not enumerate: realised-AMM-fee pricing.**
"The fees generated from the liquidity determine the base amount of streamia of an option", times a
spread multiplier set by how much of the chunk has been removed. No model, no surface, no book, no
quote.

**Collateral and liquidation path.** Two `CollateralTracker` ERC-4626 vaults per pool with a global
borrow index (`MarketState`) and compound interest; virtual-share delegation for active positions;
commissions split between protocol, builder (if a builder code is present) and PLPs; a
rehypothecation threshold above which long positions receive credited shares. Interest rate is a
PID controller with `MIN_RATE_AT_TARGET = 0.001 ether / 365 days`,
`MAX_RATE_AT_TARGET = 2.0 ether / 365 days`, `INITIAL_RATE_AT_TARGET = 0.04 ether / 365 days`.
Liquidation returns "the LeftRight-packed collateral remaining after liquidation costs and bonus;
negative slots represent protocol loss **before premia haircut**".

**Oracle — internal and ensemble-valued.** "Panoptic operates oracle-free by design", meaning no
external feed: the price source is the Uniswap pool itself, processed by the RiskEngine, which
"manag[es] the internal pricing oracle with volatility safeguards, exponential moving averages
(EMAs), and median filters to prevent price manipulation". Concretely: an 8-slot sorted ring buffer
of ticks giving `medianTick`; four EMAs at 60 s, 120 s, 240 s and 960 s packed into
`EMA_PERIODS = 60 + (120 << 24) + (240 << 48) + (960 << 72)`; `twapEMA = (6·fastEMA + 3·slowEMA +
eonsEMA)/10`; a clamp `MAX_CLAMP_DELTA` on how far a median observation may move; and
`MAX_TWAP_DELTA_DISPATCH = 513` ticks (≈5% down / 5.26% up) as the maximum permitted gap between
the current tick and the TWAP tick during a `dispatch`. **Safe mode** is the disjunction of three
tests — external shock `|currentTick − spotEMA| > MAX_TICKS_DELTA`; internal disagreement
`|spotEMA − fastEMA| > MAX_TICKS_DELTA/2`; high divergence `|medianTick − slowEMA| >
MAX_TICKS_DELTA/2` — plus a guardian-settable `lockMode`. When safe mode is on, or when the
Euclidean deviation of (spot, latest, current) from median exceeds `MAX_TICKS_DELTA`, solvency is
checked at **all four** ticks instead of one. Numeric values of `MAX_TICKS_DELTA`,
`MAX_CLAMP_DELTA` and `TARGET_POOL_UTIL` were not read — **UNKNOWN**.

**Control plane.** `PanopticFactoryV3` / `PanopticFactoryV4` deploy a market permissionlessly on
any Uniswap V3/V4 pool ("any ERC20 token"), so **listing is factory deployment**. `PanopticGuardian.
sol` plus RiskEngine "Guardian Controls: enabling an authorized guardian address to override safe
mode settings and lock/unlock pools in emergency situations". `Builder.sol` implements builder
codes routing a fee share to integrators. All user actions funnel through `dispatch()` /
`dispatchFrom()`. The repo carries `safe-txns-RiskEngine/` and `gen_safetx.py`, indicating
Gnosis-Safe-mediated administration.

### 3. REPO

- **URL:** `https://github.com/panoptic-labs/panoptic-v2-core` (V1 at `panoptic-v1-core`).
- **Commit inspected:** `d65310d6cfbaadb6910fa9446cc59c6541060749`, branch `main`, "Feat/launch
  risk engine (#265)", dated 2026-06-29; repository `pushed_at` 2026-06-30. Repo created
  2023-11-27.
- **Tags:** `2025-12-c4mr-freeze` (`26dc0a848b804def1c87fa2ec7063c0f83d8ba45`),
  `2024-09-c4mr-freeze-base`, `2024-09-c4mr-freeze`, `2024-06-c4mr-freeze` — all Code4rena audit
  freezes. The newest corresponds to the "Panoptic: Next Core" contest, 19 Dec 2025 – 7 Jan 2026,
  $56,000 USDC.
- **License:** Business Source License 1.1, Licensor **Axicon Labs Limited**, Licensed Work
  "Panoptic V2". GitHub API reports `NOASSERTION`.
- **Language:** Solidity, Foundry (`foundry.toml`, `lib/`, `remappings.txt`), with Python release
  tooling.
- **Do deployed contracts match the repo?** **Strong circumstantial yes, not directly verified.**
  The repo ships `script/verify_deployment.py`, `script/verify_etherscan.py`,
  `script/DeployProtocol.s.sol`, `script/CreatePool.s.sol`, `script/vanity-addresses.tsv`,
  `script/pool-address-miner/`, `script/builder-code-miner/`, `build-config{,-v3,-v4,-RiskEngine}.
  json`, `build_release.py` and a `safe-txns-RiskEngine/` directory of administration
  transactions — i.e. the deployment pipeline is in-repo. **However I found no committed
  address manifest, so the live mainnet addresses are UNKNOWN from the repo.** DefiLlama reports
  Panoptic V2 live on Ethereum with $2.05M TVL on 2026-08-04 (V1 $5.8k, V1.1 $2.4k — effectively
  migrated).
- **Top-level layout:** `contracts/`, `test/`, `script/`, `audits/`, `lib/`, `metadata/`,
  `assets/`, `protocol-analysis/`, `safe-txns-RiskEngine/`, `.github/`, `.husky/`, plus
  `foundry.toml`, `package.json`, `build_release.py`, `gen_safetx.py`, `commitlint.config.js`,
  `LICENSE`, `README.md`.
  `contracts/`: `Builder.sol`, `CollateralTracker.sol`, `PanopticFactoryV3.sol`,
  `PanopticFactoryV4.sol`, `PanopticGuardian.sol`, `PanopticPool.sol`, `RiskEngine.sol`
  (2,401 lines), `SemiFungiblePositionManagerV3.sol`, `SemiFungiblePositionManagerV4.sol`, and
  `base/` (FactoryNFT, MetadataStore, Multicall), `interfaces/` (IRiskEngine, ISFPM), `libraries/`,
  `tokens/` (ERC1155Minimal, ERC20Minimal), `types/` (LeftRight, LiquidityChunk, MarketState,
  **OraclePack**, Pointer, PoolData).
  `audits/`: `2025-10-panoptic-v2.pdf`, `NM0701-FINAL_PANOPTIC_V2.pdf`,
  `code4rena-panoptic-next-core.md`, `code4rena-panoptic-next-core-summary.md`.
- **Activity:** the most actively developed of the five. HEAD five weeks old; a Code4rena contest
  closed January 2026; a V2 SDK (`panoptic-sdk`, MIT) pushed 2026-07-30 and a hedger bot pushed
  2026-07-31.

### 4. EVIDENCE

| Claim | Source | Accessed |
|---|---|---|
| Contract roster and roles; RiskEngine responsibilities (collateral requirements, `isAccountSolvent`, `getLiquidationBonus`, `exerciseCost`, PID interest, internal oracle, guardian controls); CollateralTracker ERC-4626, borrow index, commissions, builder codes, rehypothecation threshold, premium settlement; five actor roles; `dispatch()`/`dispatchFrom()` | `gh api repos/panoptic-labs/panoptic-v2-core/readme` | 2026-08-04 |
| `VEGOID = 8`; `FORCE_EXERCISE_COST = 30_000`; `ONE_BPS = 1000`; `SATURATED_POOL_UTIL = 9_000_000`; `BP_DECREASE_BUFFER = 10_666_667`; `MAX_TWAP_DELTA_DISPATCH = 513`; `EMA_PERIODS` packing 60/120/240/960; `twapEMA = (6·fast + 3·slow + eons)/10`; 8-slot median ring buffer; three-condition `isSafeMode` + `lockMode`; `getSolvencyTicks` 1-vs-4 tick rule; rate bounds 0.001/2.0/0.04 ether per 365 days; "protocol loss before premia haircut" | `gh api repos/panoptic-labs/panoptic-v2-core/contents/contracts/RiskEngine.sol` (2,401 lines, read) | 2026-08-04 |
| Repo HEAD, tags, BUSL-1.1 / Axicon Labs, contracts and audits directory listings | `gh api repos/panoptic-labs/panoptic-v2-core` (+ `/tags`, `/releases`, `/contents/...`) | 2026-08-04 |
| Streamia definition, base fee from Uniswap swap fees, spread multiplier, in-range accrual, buyers pay sellers, liquidation risk from negative streamia | https://panoptic.xyz/docs/product/streamia | 2026-08-04 |
| Perpetual, no expiry; force exercise with compensation; oracle-free by design; 10× buy / 5× sell leverage; any ERC20; live on Ethereum mainnet; Aave/Compound-style liquidation network | https://panoptic.xyz/docs/faq/ | 2026-08-04 |
| BCR/SCR; `Buying Power Requirement = notionalSize · (100% − S/K)`; liquidation bonus formula | https://panoptic.xyz/docs/panoptic-protocol/liquidations | 2026-08-04 |
| V1→V2 changes: deposit-fee/commission model → interest-rate lending model; modular risk engines; closable positions; vault-based automation; mid-December mainnet relaunch | https://panoptic.xyz/blog/panoptic-v2-is-coming | 2026-08-04 |
| Contract overview incl. RiskEngine as V2-only, internalized oracles, builder codes, protocol fee capture | https://panoptic.xyz/docs/contracts/smart-contracts-overview | 2026-08-04 |
| Code4rena "Panoptic: Next Core" audit, 19 Dec 2025 – 7 Jan 2026, $56,000 USDC; `RiskEngine.sol` in scope | https://code4rena.com/audits/2025-12-panoptic-next-core · https://github.com/code-423n4/2025-12-panoptic | 2026-08-04 |
| Panoptic V2 $2.05M TVL on Ethereum; V1 $5.8k, V1.1 $2.4k (aggregator) | `api.llama.fi/protocols` | 2026-08-04 |

### 5. WHAT LOOKS UNNAMEABLE

1. **Perpetual, strike-free, expiry-free options.** Confirmed as the corpus states, and stronger:
   the "strike" is a tick range, so even the *type* of the strike parameter is different.
2. **Premium as a generated quantity, not a priced one.** Streamia is realised Uniswap fee flow
   times a utilisation multiplier. This is a fourth pricing regime beside model-priced,
   book-priced and quote-priced, and the corpus's axis (f) offers only the first two. `Sr` names
   accrual, not the generator.
3. **Lending an LP position as the underwriting primitive.** As the corpus states. Extend it: the
   SFPM's ability to mint *negative* liquidity — to burn Uniswap liquidity as a position — is what
   creates a long option. `Cl` names range positions; nothing names their removal as an instrument.
4. **An ensemble price with a state-dependent solvency conjunction.** The oracle is not a value but
   a set (spotEMA, medianTick, latestTick, currentTick) with a clamp and a disagreement detector,
   and the *number of prices at which solvency is tested* changes with market conditions. Neither
   `Ex` nor `Tp` can express "the risk test is a conjunction over an ensemble, and the ensemble
   size is a function of the ensemble's own dispersion".
5. **Safe mode as a self-diagnosing circuit breaker.** Three inequalities over the oracle's own
   internal state, OR-ed with a guardian lock. `Gp` names a pause switch; this is an automatic,
   graduated tightening triggered by the price source distrusting itself.
6. **Force exercise.** A third party compelling another user's *solvent* position to close, paying
   a fee that decays exponentially in distance from strike. It is not liquidation (the target is
   not insolvent) and not exercise (the holder does not elect it). Nothing names compulsion without
   distress.
7. **A PID-controlled interest rate with a persistent rate-at-target.** The rate is a controller
   state that moves between firings, bounded 0.1%–200% APR with a 4% initial target. `Pl` implies a
   rate exists; nothing names a controller with memory.
8. **Utilisation-scaled collateral requirements with a saturation point.** The requirement is a
   function of *pool state*, so a seller's margin can deteriorate because other people traded.
9. **A premia haircut ahead of protocol loss.** An unsettled-premium claim is subordinated before
   the pool eats the residual — a two-step waterfall whose first step is an accrued receivable.
   `Sl` and `Tr` between them cannot express "haircut the unpaid stream first".
10. **Builder codes.** A fee share routed to whoever's interface constructed the calldata.
11. **Permissionless market creation as listing.** `PanopticFactory` will open an options market on
    any Uniswap pool, so the instrument universe is unbounded and ungoverned — the exact opposite of
    the governed expiry calendars at Derive and Aevo, and equally unnameable.

### 6. DELTA vs the corpus record

- **The corpus's canonical form drops both a price source and the threshold test, and both are
  first-class in V2.** Corpus canonical `[Cl, Gp, Li, Op, Pl, Sh, Sr, Up]`, with `Ct` demoted to
  "derived". `RiskEngine.isAccountSolvent` is a standalone, audited, 2,401-line contract whose
  *entire purpose* is the threshold test; and the internal median/EMA oracle is a `Tp`-shaped
  on-chain time-weighted price that appears nowhere in the corpus element set. So the vocabulary's
  rejection of Panoptic is an **artefact of the decomposition**, not a fact about the protocol.
  Cite: `contracts/RiskEngine.sol`, README §RiskEngine.
- **`Ix` is missing.** `CollateralTracker` maintains "its own market state including a global
  borrow index for compound interest calculations" (`types/MarketState.sol`). Index-based accrual
  is present alongside `Sh`.
- **The corpus record predates the V1→V2 economic change.** V1's deposit-fee/commission model was
  replaced in V2 by an interest-rate lending market with a PID controller; that, plus modular risk
  engines and vault-based automation, is the substance of V2. The corpus residue does not mention
  interest at all.
- **`Up` is questionable in the same way as Hegic's.** The V2 contracts read are not proxies; the
  factory deploys fresh instances and administration runs through Gnosis-Safe transactions
  (`safe-txns-RiskEngine/`, `gen_safetx.py`). Whether any component sits behind a proxy is
  **UNKNOWN** from what I read; the corpus asserts `Up` without an evidenced mechanism.
- **`armedProhibitions: []` misses a structural observation.** X2 ("`Fl` + manipulable `Cp`/`Cl`
  price + `Pl`/`Cd`") is not armed — there is no flash liquidity — but the *failure mode it
  guards against is exactly Panoptic's central design problem*: a lending-backed system whose price
  source is the AMM it trades on. Panoptic's clamp, median ring buffer, four-EMA ensemble,
  `MAX_TWAP_DELTA_DISPATCH` and safe mode are a purpose-built mitigation for it. The vocabulary has
  no way to record "this prohibition's failure mode is present and explicitly mitigated" — a
  prohibition is armed or it is not.
- **The docs' "the pool will never incur a loss" is contradicted by the code.** `RiskEngine`
  returns "collateral remaining after liquidation costs and bonus; negative slots represent
  **protocol loss** before premia haircut". Protocol loss is a modelled outcome. Cite:
  `contracts/RiskEngine.sol` around the liquidation-bonus return docstring, vs
  https://panoptic.xyz/docs/panoptic-protocol/liquidations.
- **Ranking number matches exactly.** Corpus $2.05M TVL; live $2.05M.

---

## Cross-cutting findings for the next stage

**1. `Op` is under-resolved, and by more than the corpus estimated.** Resolving the six axes
across the five protocols gives five mutually distinct profiles, and no pair agrees on all six:

| | Derive | Rysk V12 | Hegic | Aevo | Panoptic V2 |
|---|---|---|---|---|---|
| (a) exercise | European | European | window before expiry, forfeit after | European | perpetual |
| (b) settlement | cash (30-min TWAP) | physical (puts); calls disputed | cash (net P&L) | cash | continuous realisation |
| (c) underwriting | p2p, off-chain matched | p2p RFQ, off-chain matched | peer-to-single-pool | p2p, off-chain matched | AMM payoff over pooled credit |
| (d) premium | upfront | upfront | upfront | upfront | streamed, per block |
| (e) margin | isolated **or** 23-scenario portfolio | none — full pre-funding | none — pre-locked max loss + caps | isolated **or** 15-scenario portfolio + floor | utilisation-scaled, multi-price |
| (f) pricing | book, marked on an SVI surface | RFQ quote | admin-set scalar/polynomial per instrument | book, internal IV | realised AMM fees × spread multiplier |

Two of the six axes need values the corpus's binary framing does not have: axis (e) needs **"none,
because maximum loss is pre-funded"** (Rysk, Hegic), and axis (f) needs **"priced by realised AMM
fee generation"** (Panoptic).

**2. The three named missing mechanisms are confirmed, and there is a fourth.** Pricing model /
volatility surface: present and material at Derive (SVI, Block Scholes, confidence-scored), Aevo
(internal IV) and Hegic (an admin scalar — the degenerate limit of a surface), and *deliberately
absent* at Rysk and Panoptic, which is itself a design fact no symbol records. Instrument listing:
five different regimes — rolling calendar with delta-dependent strike granularity (Derive), fixed
daily/weekly/monthly/quarterly (Aevo), one deployed contract per instrument (Hegic), continuous
taker-specified (Rysk), permissionless factory on any pool (Panoptic). Terminal settlement fixing:
a 30-minute converging TWAP (Derive), an 08:00 oracle print with a 5-minute manually-adjudicated
dispute window (Rysk), a Chainlink read at exercise (Hegic), **undocumented** (Aevo), and *not
applicable* (Panoptic). The **fourth** missing mechanism is **loss-absorption topology**: the five
protocols close the writer-default channel in four incompatible ways — auction → treasury module →
socialised withdrawal fee (Derive); book → insurance fund → ADL by counterparty profitability
(Aevo); liquidation → premia haircut → PLP loss (Panoptic); and *pre-funding, so the channel does
not exist* (Rysk, Hegic, with Hegic adding a protocol-token cover pool at an administered price).

**3. On the vocabulary's rejection of four of the five — none of the four rejections is correct as
stated, and they fail for two different reasons.** For **Aevo** and **Panoptic V2** the rejection
is a *decomposition artefact*: both protocols have a first-class collateral-threshold test
(Aevo's `AB − OO − MM > 0` risk engine; Panoptic's `RiskEngine.isAccountSolvent`) and a first-class
price source (Aevo's trimmed-mean index; Panoptic's internal median/EMA ensemble), and the corpus
demoted them to "derived" or omitted them. Fix the decomposition and the rejection disappears. For
**Rysk V12** and **Hegic** the rejection is a *mis-diagnosis*: nothing is left open, because both
escrow the maximum payoff at trade time, so a threshold test, a liquidator and a backstop would
have nothing to do. The vocabulary's laws force a risk-transfer symbol to be discharged by naming a
solvency mechanism, which makes "loss absorption is closed by construction" inexpressible and
therefore indistinguishable from "loss absorption is unspecified". **That is the single most
important thing the next stage needs**: the corpus's rejection signal is currently conflating a
protocol that forgot to say how losses are absorbed with a protocol that made losses impossible,
and those are opposite facts. And note the converse: the one protocol the vocabulary *accepts*,
Derive, is accepted partly on the strength of `Bs`, whose defining clause — slashable first-loss
capital — is not satisfied by Derive's owner-funded Security Module.
