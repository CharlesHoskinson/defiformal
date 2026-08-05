# Stage 1 research — Category 08: Intents / aggregation / order flow

**Lane:** LiquidMesh · Binance Wallet · OKX DEX · Jupiter · KyberSwap
**Author:** stage-1 research agent. **Session:** 2026-08-04 → 2026-08-05 UTC.
**Access dates below are given as `2026-08-05` for every source fetched in this session** (the session
crossed the UTC midnight boundary; the corpus snapshot it is compared against is dated 2026-08-04).

**Source quality for this category is the worst of any DeFi category, and the reason is structural: in
this category the product *is* the off-chain server.** For three of the five targets (LiquidMesh,
Binance Wallet, OKX DEX) the route is computed on a private machine, the quote is a non-binding
number returned over HTTPS, and the only thing that is publicly verifiable is a settlement router
contract and an event log. Grading of what I could obtain:

- **Tier 1 (verified on-chain / in a public repo):** KyberSwap's routing library, hook contracts and
  audits; OKX's `DexRouter` verified source and `CommissionLib`; Binance's `Binance: DEX Router`
  verified Diamond proxy; every DefiLlama measurement adapter (each names the exact contract, event
  or vendor API it reads); Jupiter's audit set.
- **Tier 2 (first-party documentation, unverifiable but authoritative):** all five docs sites. Notably
  OKX publishes a *conflict-of-interest policy* for its aggregator and intent products — the single
  most useful primary document in this category, because it is the only place any of these operators
  states in writing what it does with the order flow it controls.
- **Tier 3 (UNKNOWN):** LiquidMesh's operating entity, its router implementation source, and its
  customer list; Binance Wallet's current swap fee, its liquidity-provider set, and whether Binance
  or an affiliate is ever the maker; Jupiter's aggregator program source. Each is marked UNKNOWN in
  place rather than inferred.

Two cross-cutting facts that a later stage must not lose. First, **DefiLlama's aggregator
leaderboard is not a homogeneous measurement.** LiquidMesh, Binance Wallet and Jupiter are measured
by Dune queries against named contracts/programs; **OKX and KyberSwap self-report their volume
through their own APIs.** Second, **these five are not five peers — Jupiter's own documentation
lists OKX and DFlow as routers it aggregates.** The category contains a composition relation the
corpus models as a flat ranking.

---

## LiquidMesh

### 1. WHAT IT DOES

LiquidMesh has no users. It is a business-to-business execution API sold to the parties that do have
users: its own documentation describes it as "a multi-chain DEX aggregator and on-chain transaction
broadcasting infrastructure provider — purpose-built for Web3 wallets, trading platforms, and
professional traders." The person whose trade shows up in the volume figure is a customer of some
wallet or trading front-end that has integrated LiquidMesh; that front-end calls
`GET /v1/{networkId}/quote` and then `POST /v1/{networkId}/swap` (or the combined `POST
/v1/{networkId}/order`), and presents the returned transaction for signature. The user therefore
signs an ordinary chain-native transaction whose calldata was authored by LiquidMesh's server, not a
signed intent or an off-chain order. LiquidMesh picks the venue — entirely off-chain, in a private
engine, with no on-chain evidence of what alternatives were considered. Price risk between quote and
fill is borne by the user: the quote is advisory (LiquidMesh advertises ~12 ms response times
precisely because staleness is the failure mode) and the only enforced guarantee is the router's
minimum-return check, plus error code `40106` refusing to quote at excessive price impact. The user
is *not* guaranteed the best price, an audit trail, or a fill. Settlement is a single atomic
transaction through the per-chain LiquidMesh Router, which emits `OrderRecord(fromToken, toToken,
sender, fromAmount, returnAmount)`. Optionally the integrator hands the signed transaction back to
LiquidMesh's Boost API to be broadcast through private channels rather than the public mempool, in
which case LiquidMesh backruns the transaction itself and returns "the majority of the MEV profits
to users". Before any of this, LiquidMesh can refuse: it screens the caller's IP against a
restricted-territory list and screens the supplied `userAddress` against hack-associated and
high-risk address lists.

### 2. DESIGN

**Product surface.** Three APIs (`docs.liquidmesh.io`, accessed 2026-08-05):

- **Quote API** — `GET /v1/{networkId}/quote`. Two-step: quote, then build. Returns `routePlans`
  (swap paths and per-DEX allocations), `priceImpactPct`, `midPrice`, `estimatedGas`, `blockNumber`,
  and a `tradeType` enumerating `normal | fourmeme | input_fourmeme | output_fourmeme`.
- **Flash API** — `POST /v1/{networkId}/order`. Quote and transaction construction in one call,
  "for scenarios where execution speed is more important than route flexibility."
- **Boost API** — broadcasting with MEV protection.

**Route construction.** Off-chain and proprietary. The public surface exposes only `dexes` /
`excludeDexes` filters and a `routePlans` array in the response. There is no whitepaper, no
published algorithm, and no on-chain quoting. What is sold is latency and landing rate: claimed
<12 ms quote response, new-token quotes within 1 second, 99.99% SLA, >97% success rate, "0 block
on-chain confirmation", >100k QPS.

**Solver / filler set.** None. There is no solver, no auction, no RFQ tier documented. LiquidMesh is
a router, not a marketplace.

**Settlement contracts.** One router per chain, per the Smart Contracts page:

| Chain | Router |
|---|---|
| BSC / Base / Ethereum / Sonic / Plasma / Monad | `0x3d90f66B534Dd8482b181e24655A9e8265316BE9` |
| Solana | `HuTkmnrv4zPnArMqpbMbFhfwzTR7xfWQZHH1aQKzDKFZ` |
| Sui | `0xda25b9089d3c8a5a014ca00b707cd9466a92713dfa2827926fb75d67b4a4b5d3` |
| Tron | `TJpMjCCA1wAVKLp6T3eRoZiB8reVAdDvaQ` |

Plus an EVM token-approval contract `0x8157a9d65807521FBB8db8f37EEEcEfDD247E9B1`, a Tron approval
contract `TNKG4Mji5CjwaEZ8QXk5B4PaDDtax5pxQ5`, and — separately listed — a **Four.meme token manager
`0x5c952063c7fc8610FFDB798152D69F0B9550762b` on BSC**, i.e. a dedicated adapter for BNB Chain's
memecoin bonding-curve launchpad.

**Fee and rebate flow.** Two distinct flows, in opposite directions.

- *Integrator commission.* The Quote API takes `commissionRate` (integer basis points; "15 = 0.15%")
  and `commissionDirection` (boolean: true → charged from `inputToken`, false → from `outputToken`).
  The Quote API page states the "built-in fee parameter" exists to enable "revenue-sharing models for
  wallets, aggregators, and other apps." LiquidMesh does not charge the trader; it hands the wallet
  a lever to charge the trader, and the wallet keeps the proceeds.
- *MEV cashback.* Boost returns value to the end user. On EVM, LiquidMesh states it does not leak
  transactions "to any third-party searchers", prohibits builders from auctioning user transactions,
  itself extracts MEV by **backrunning**, and returns "the majority of the MEV profits to users". On
  Solana it uses SWQoS validator partnerships and Jito, returning "a portion of the saved tip fees".
  No percentages or formulas are published. Privacy is a graded setting: EVM `public` (broad partner
  broadcast) vs `private` (trusted builders only); Solana `off` / `reduced` (filters malicious
  validators) / `secure` (whitelist only).

**Who owns the order flow, and how the right to fill is sold.** LiquidMesh's position is the mirror
image of Binance Wallet's: **it owns no order flow at all and its entire commercial design is to be
the thing that the order-flow owner plugs in.** The commission parameter is the sale — LiquidMesh
gives away the monetization right to the integrator and keeps the routing and broadcasting business.
It then re-acquires a slice of the flow's *value* on the other side, by extracting MEV from the very
transactions it constructs (backrunning) and rebating most of it to the trader as a competitive
feature. There is no auction, no PFOF payment to LiquidMesh, and no exclusivity: this is white-label
distribution plus vertically-integrated MEV extraction.

**Order-flow gating.** Two mechanisms with no analogue elsewhere in this lane. (a) *Jurisdiction*:
access is denied to requests from a restricted-territory list (US and territories, Canada/Ontario,
Netherlands/EEA, UK, Japan, Iran, Cuba, North Korea, Crimea/Donetsk/Luhansk), and to requests using
VPN/proxy masking; error `42106`. (b) *Instrument class*: **"bStock" trading carries a second,
much larger prohibition list of 57 further jurisdictions** and its own error code `42107`. bStocks
are Binance's tokenized US equities on BNB Chain. LiquidMesh therefore applies per-instrument
securities-style geo-gating inside a swap-routing API. (c) *Counterparty*: `userAddress` became
required on Order and Swap after a security update, so that both the token and the end-user address
can be screened for hack association and third-party risk flags before a quote is issued.

**Where the volume actually is.** $752.4m of $776.5m (96.9%) of the 24h figure is on BNB Chain;
Ethereum $13.5m, Base $8.6m, Solana $2.0m, Sonic $5.4k, Tron $0. `change_1m` = **+962%**.

### 3. REPO

**This is a front-end/off-chain business and the substance is not verifiable.** Stated explicitly, as
the brief requires.

- **Canonical source repository: NONE FOUND.** No `liquidmesh` GitHub organisation, no SDK, no
  contract repository. Searches surfaced only unrelated namesakes: `samueldanso/liquidmesh-somnia-ai`
  ("LiquidMesh Finance", a liquidity-management protocol on Somnia) and `liquidmeshfi.xyz`
  ("LiquidMesh — Autonomous Trading Mesh on X Layer"). **Neither is this protocol.** A later lane
  must not conflate them.
- **License: UNKNOWN / none published. Language: UNKNOWN. Operating entity: UNKNOWN** — the docs
  identify no company, no team, and no jurisdiction of incorporation; the site footer says only
  "© 2026 LiquidMesh".
- **Do deployed contracts match a repo? There is no repo to match.** Partial on-chain verification:
  `0x3d90f66B534Dd8482b181e24655A9e8265316BE9` on BSC **is** verified as an OpenZeppelin
  `TransparentUpgradeableProxy` (solc v0.8.17), EIP-1967, pointing at implementation
  `0x16F8a2735160E6c4614343959f82a9E1512BD14B`, **which is NOT verified on BscScan.** So the router
  is upgradeable and its logic is unreadable.
- **Structural inference, flagged as inference, not fact:** LiquidMesh's router emits an event whose
  Dune-decoded signature is `OrderRecord(fromToken, toToken, sender, fromAmount, returnAmount)` —
  byte-for-byte the event declared in OKX's `contracts/8/libraries/CommonUtils.sol` and emitted by
  OKX's `DexRouter.sol` — and it uses the same separate-`TokenApprove`-contract architecture. OKX
  published that code under **Apache-2.0**, which permits derivation. Two independent structural
  matches make an OKX-SOR lineage the most likely explanation, but with the implementation
  unverified this **cannot be confirmed** and is recorded as an inference.
- **Verifiable, therefore, is exactly this:** the router addresses; that BSC's router is an
  upgradeable proxy with unverified logic; the `OrderRecord` event stream (which is what DefiLlama
  measures, via `liquidmesh_multichain.liquidmeshrouter_evt_orderrecord` and
  `liquidmesh_solana.liquid_mesh_router_evt_liquidmeshswapevent`); and the API's documented
  parameter surface. Everything about route quality, latency, landing rate, MEV rebate share and
  private-mempool behaviour is unfalsifiable from outside.

### 4. EVIDENCE

| Claim | Source | Accessed |
|---|---|---|
| Self-description; target customers; three APIs; SLA/latency claims | https://docs.liquidmesh.io/docs/getting-started.md | 2026-08-05 |
| Security Engine: pre-trade risk checks on token and user address; `userAddress` required | https://docs.liquidmesh.io/docs/overview.md ; https://docs.liquidmesh.io/changelog/liquidmesh-security-update.md | 2026-08-05 |
| Quote API endpoint, `commissionRate`, `commissionDirection`, `dexes`/`excludeDexes`, `routePlans`, `tradeType` incl. `fourmeme`, error codes | https://docs.liquidmesh.io/reference/quote-1.md | 2026-08-05 |
| "built-in fee parameter" → "revenue-sharing models for wallets, aggregators, and other apps" | https://docs.liquidmesh.io/docs/quote-api.md | 2026-08-05 |
| Flash API = single-call quote+build; speed over route flexibility | https://docs.liquidmesh.io/docs/flash-api.md | 2026-08-05 |
| Boost API: no leakage to third-party searchers; builders may not auction user txs; backrun MEV with majority returned to users; Solana SWQoS + Jito with tip savings returned; public/private and off/reduced/secure modes | https://docs.liquidmesh.io/docs/boost-api.md | 2026-08-05 |
| Router addresses per chain; approval contracts; Four.meme token manager | https://docs.liquidmesh.io/docs/smart-contracts.md | 2026-08-05 |
| Supported networks and `networkId`s (incl. `robinhood`, `plasma`, `monad`, `stable`) | https://docs.liquidmesh.io/docs/supported-chains.md | 2026-08-05 |
| Restricted territories; VPN/proxy denial; separate 57-jurisdiction bStock list; errors 42106/42107 | https://docs.liquidmesh.io/docs/access-eligibility-and-ip-screening.md | 2026-08-05 |
| Ed25519-signed JWT + `LM-API-KEY`; portal vs enterprise onboarding; **no published pricing or revenue-share terms** | https://docs.liquidmesh.io/docs/api-access-and-usage.md | 2026-08-05 |
| Site performance/marketing claims incl. "MEV Cashback", "Private Mempool", 7 chains | https://liquidmesh.io/ | 2026-08-05 |
| BSC router is a verified `TransparentUpgradeableProxy`, impl `0x16F8a273…`; impl **unverified** | https://bscscan.com/address/0x3d90f66B534Dd8482b181e24655A9e8265316BE9#code ; https://bscscan.com/address/0x16F8a2735160E6c4614343959f82a9E1512BD14B#code | 2026-08-05 |
| Volume methodology: Dune tables named above; chains ETH/Base/BSC/Sonic/Tron + Solana; adapter `start: '2025-08-01'`; BSC uses a token *whitelist* | https://github.com/DefiLlama/dimension-adapters/blob/master/aggregators/liquidmesh/index.ts (via GitHub API, HEAD of `master`) | 2026-08-05 |
| 24h/7d/30d volume, per-chain split, `change_1m` +962.33% | `https://api.llama.fi/overview/aggregators` (JSON, `defillamaId` 6843) | 2026-08-05 |
| `OrderRecord` event declaration in OKX's published router (lineage inference) | https://github.com/Julian-dev28/WEB3-DEX-OPENSOURCE `contracts/8/libraries/CommonUtils.sol:70`, `contracts/8/DexRouter.sol:367` (Apache-2.0; fork of the now-404 `okx/WEB3-DEX-OPENSOURCE`) | 2026-08-05 |
| bStocks = BEP-20 1:1 tokenized US shares on BNB Chain | https://www.binance.com/en/academy/articles/what-are-bstocks-a-guide-to-tokenized-stocks-on-binance | 2026-08-05 |

### 5. WHAT LOOKS UNNAMEABLE

1. **Routing as a purchased service.** `Ag` reads as an on-chain route-construction mechanism. Here
   there is no mechanism to name — there is a company, a server and a latency number. The vocabulary
   cannot distinguish "the protocol computes a route" from "a vendor's private process computes a
   route and the chain merely executes it."
2. **Selling the monetization right rather than exercising it.** `commissionRate` /
   `commissionDirection` is a first-class API parameter whose entire purpose is to let *someone else*
   tax the trade. No symbol names a fee that the protocol defines but does not collect.
3. **Private/MEV-protected broadcast as a product,** including a graded privacy level
   (off / reduced / secure) and a negative constraint on the builder ("may not auction the user's
   transaction"). Nothing in the 58 names a transaction's path to inclusion.
4. **Deliberate self-backrunning with a rebate to the trader.** The router that builds your trade
   also extracts the MEV behind it and gives most of it back. This is simultaneously extraction and
   protection; the vocabulary has no name for either half.
5. **Landing rate / inclusion reliability as the product property being sold** (">97% success rate",
   "0 block confirmation"). Every symbol in the vocabulary presumes inclusion.
6. **Jurisdictional and instrument-class gating of the right to receive a quote.** `Aw` is a binary
   on-chain permission gate over a protocol. This is an off-chain refusal to *quote*, conditioned on
   IP geolocation, VPN detection, and which instrument class the trade touches (bStock vs everything
   else). The gate sits before the mechanism, not inside it.
7. **Pre-trade counterparty and asset risk screening** against third-party security vendors —
   honeypot/scam token detection and hack-associated address detection — as a precondition of
   service.
8. **Launchpad-native routing.** A dedicated `fourmeme` trade type and a Four.meme token-manager
   contract: the router transacts against a bonding curve as a first-class venue class.

**Verdict on the corpus's `{Ag}` ≡ `{Ag}` claim (LiquidMesh vs KyberSwap): they are NOT alike.**
See §5 under KyberSwap for the other half; the short form is that LiquidMesh owns no venue and no
user and monetizes by *giving away* the fee lever, while KyberSwap owns exclusive venues in which it
is the sole permitted taker and captures the arbitrage itself. Their economic positions are
opposites. They collide on `{Ag}` only because `Ag` names route construction and the vocabulary has
nothing else to say.

### 6. DELTA

- **`rank_basis` figures are stale and the ranking is unstable.** Corpus: "$657.73m 24h, $5.302b 7d,
  $13.426b 30d across 6 chains". Live API at access time: **$776,457,681 / $5,304,630,124 /
  $14,128,998,069**, 6 chains. The 7d figure matches to 0.06%, so this is the same snapshot revised —
  DefiLlama backfills these adapters (Dune has a ~10-hour indexing delay, which the adapter itself
  guards against). A later stage should treat the 24h column as provisional.
- **The corpus does not record that LiquidMesh is ~97% a single-chain phenomenon** (BNB Chain) with
  `change_1m` of +962%. The #1 protocol in the category by volume is one month old at this scale.
- **The corpus residue says "No element for white-label distribution."** Correct, but understated:
  the mechanism is a *named API parameter*, `commissionRate`, documented as enabling revenue sharing
  with wallets. This is a concrete, citable primitive, not an abstraction.
- **The corpus residue does not mention** jurisdictional/instrument gating, pre-trade address
  screening, launchpad-native routing, or the OKX-lineage structural match.
- **Namespace hazard the corpus does not flag:** three unrelated things are called LiquidMesh. The
  corpus entry is `liquidmesh.io` / DefiLlama slug `liquidmesh` / `defillamaId` 6843.

---

## Binance Wallet

### 1. WHAT IT DOES

Binance Wallet is a self-custodial MPC wallet embedded in the Binance app and browser extension,
whose Swap tab is the second-largest "DEX aggregator" in DeFi by volume. The user signs an ordinary
transaction to `Binance: DEX Router`; there is no signed intent, no off-chain order, and no auction.
Binance picks the venue: its FAQ says "Binance Wallet finds the most competitive price from
thousands of potential options on CeFi and DeFi exchanges" and that "third-party dApps provide
liquidity for swaps, and Binance chooses the best option from different providers to provide service
to users" — the user sees "a recommended provider", not a route. Price risk between signature and
fill is the user's: slippage tolerance is user-adjustable next to "Minimum Received", "all swaps are
final post-confirmation", and failed swaps still cost gas. The user is guaranteed almost nothing —
Binance explicitly disclaims being the counterparty ("Binance Wallet merely aggregates third-party
decentralized applications (dApps) and may not be associated with the possible risks these dApps
present"; "Binance does not hold responsibility for any risks or potential damage incurred from the
use of third-party dApps"). What the user *does* get, by default and without configuration, is MEV
protection: BNB Chain's February 2025 programme routes Binance Wallet transactions through private
RPCs so they are never exposed to the public mempool. Settlement is one atomic on-chain transaction.
The commercially distinctive part is upstream of all of this: through **Binance Alpha**, a user can
buy on-chain tokens using a Binance *exchange* Spot/Funding balance without holding a wallet at all,
and the resulting token is confined to the Alpha environment — non-withdrawable and
non-transferable until Binance lists it on Spot.

### 2. DESIGN

**Route construction.** UNKNOWN in mechanism. No public developer documentation, no published
algorithm, no route-plan surface, no whitepaper. What is verifiable is the settlement layer.

**Settlement contracts.** `0xb300000b72DEAEb607a12d5f54773D1C19c7028d`, publicly labelled
**"Binance: DEX Router"**, deployed at the *same* address on Ethereum, Arbitrum, Polygon, BSC,
Avalanche, Optimism and Base; different addresses on Linea (`0xe8B592a3…`), Sonic and Plasma
(`0x610776e6…`) and zkSync Era (`0x45a0B6ac…`); and a Solana program
`B3111yJCeHBcA1bizdJjUFPALfhAfSRnAbJzGUtnt56A`. The vanity prefixes (`0xb30000…` / `B3111…`) are
matched across VMs, which is a deliberate branding of the settlement layer. On BscScan the contract
is **verified (exact match)**, name `Diamond`, solc v0.8.23, EVM version Shanghai, optimizer 200
runs — an **EIP-2535 Diamond proxy**, i.e. per-selector upgradeable facets, owner
`0xEe7b429Ea01F76102f053213463D4e95D5D24AE8`. So Binance built and controls its own multi-chain
router rather than calling someone else's.

**Solver / filler set.** None documented. There is no auction and no RFQ tier in any public Binance
material I could find. UNKNOWN whether Binance or a Binance affiliate ever supplies the maker side.

**MEV.** Not built by Binance. BNB Chain's programme (published 2025-02-10) lists Binance Web3
Wallet among five wallets with *built-in, automatic* protection, implemented as private RPC
submission — "sends your transactions through a private network, making them invisible to MEV bots"
— with free providers PancakeSwap, 48 Club and Merkle, and paid providers BloxRoute, Blocksmith,
Nodereal, Blockrazor and Puissant offering atomic bundling. Binance consumes an ecosystem service
here; it does not operate one.

**Fee flow.** Binance ran a **zero-fee promotion from 2025-03-17 to 2025-11-26** waiving "trading
fees for all swaps" across Swap, Bridge and Binance Alpha Quick Buy, restricted to backed-up keyless
addresses (imported wallets excluded) and excluding third-party dApps; gas remained the user's.
Separately, Binance Alpha *limit order* fees on BSC were cut from **0.15% to 0.01% effective
2025-06-20**. **The current standing swap fee is UNKNOWN** — I could not find it stated at a Binance
primary source, and I decline to repeat the "0% Alpha / 0.5% other pairs" figure that circulates on
review sites because I could not confirm it.

**Who owns the order flow, and how the right to fill is sold.** Binance Wallet is the purest
order-flow *owner* in this lane and the only one that does not sell anything. It owns the user at
the exchange level (KYC'd account, Spot/Funding balance), owns the wallet, owns the router contract,
owns the token universe the user can see (Alpha listings), and owns the *exit* (an Alpha token
cannot be withdrawn until Binance lists it). The right to fill is not auctioned, not tendered and
not priced; it is allocated administratively by Binance's choice of "recommended provider," and the
identity of those providers is not published. **There is no public evidence of payment for order
flow in either direction, and equally no public evidence of its absence** — unlike OKX, Binance
publishes no conflict-of-interest policy for this product. Vertical integration is total in the
other direction too: BNB Chain is Binance's chain, Four.meme and bStocks are BNB Chain products, and
**98.3% of Binance Wallet's swap volume ($612.4m of $623.0m) is on BSC.**

### 3. REPO

**This is a wallet front-end whose substance is off-chain routing, and there is no repository at
all.** Stated explicitly, as the brief requires.

- **Canonical source repository: NONE EXISTS.** No repository for the Binance DEX Router or for
  Binance Wallet's routing engine in the `binance`, `bnb-chain` or `binance-chain` GitHub
  organisations, and none found by search. `bnb-chain` contains `legacy-extension-wallet` and
  `safe-wallet-web`, neither of which is this product.
- **License: N/A (no repo). BscScan reports the contract license as "Not Specified". Language:**
  Solidity (settlement) + UNKNOWN (routing service).
- **Do deployed contracts match a repo?** There is no repo, so the question is void. However — and
  this is the sharp point — **the contract is verified on BscScan while having no upstream source
  of record.** Verification here means "the bytecode matches a source blob Binance uploaded", not
  "the bytecode matches a public, versioned, reviewable codebase." The two are routinely conflated
  and a later stage must not conflate them.
- **What is verifiable:** the router addresses on 12 chains; that it is a Diamond proxy with
  per-selector upgradeability and a single owner EOA; the `DiamondCut` history; and the trade stream
  (DefiLlama measures it as `tx_to = 0xb300000b…` on EVM and `address = B3111yJ…` on Solana, taking
  the largest hop per `(tx_hash, taker)` to avoid double-counting multi-hop routes). **Not
  verifiable:** which venues were considered, who the "providers" are, what price improvement if any
  was passed on, and whether any consideration flows between Binance and a filler.

### 4. EVIDENCE

| Claim | Source | Accessed |
|---|---|---|
| Aggregates third-party dApps; "finds the most competitive price from thousands of potential options on CeFi and DeFi exchanges"; slippage editable at "Minimum Received"; swaps final; Binance disclaims counterparty status | https://www.binance.com/en/support/faq/what-is-binance-wallet-swap-7ebe19e8ff884cc09a9dbb064aff131f | 2026-08-05 |
| "Third-party dApps provide liquidity for swaps, and Binance chooses the best option from different providers"; "recommended provider" | https://www.binance.com/en-BH/support/faq/what-is-binance-web3-wallet-swap-7ebe19e8ff884cc09a9dbb064aff131f | 2026-08-05 |
| MPC custody, three key shares; no swap fee disclosed; no routing disclosure | https://www.binance.com/en/support/faq/frequently-asked-questions-on-binance-web3-wallet-5a3fc86a702b43e1a4a398ebd8853b77 | 2026-08-05 |
| MEV protection default-on via private RPC; wallet list; provider list; published 2025-02-10 | https://www.bnbchain.org/en/blog/protecting-users-from-sandwich-attacks-bnb-chain-introduces-mev-protection-with-several-wallets | 2026-08-05 |
| Zero trading fees on all swaps, 2025-03-17 → 2025-11-26; Swap/Bridge/Alpha Quick Buy only; keyless backed-up address required; gas still payable | https://www.binance.com/en/support/announcement/detail/4037408455264c02becd90b5873121c3 | 2026-08-05 |
| Alpha limit-order fee on BSC 0.15% → 0.01% effective 2025-06-20 06:00 UTC | https://www.binance.com/en/support/announcement/detail/c58cbaf282ac45819f470176bdc17f3b | 2026-08-05 |
| Alpha 2.0: trade on-chain tokens from Spot/Funding without an external wallet; orders execute on on-chain markets; auto-cancel if minimum received falls below the displayed value; Alpha tokens non-withdrawable until Spot-listed; BETA, region- and compliance-gated | https://academy.binance.com/en/articles/what-is-binance-alpha | 2026-08-05 |
| Router verified as `Diamond` (EIP-2535), solc 0.8.23, label "Binance: DEX Router", owner `0xEe7b429E…`, DiamondCut facet `0x57FE1CBB…` | https://bscscan.com/address/0xb300000b72deaeb607a12d5f54773d1c19c7028d | 2026-08-05 |
| Same address on Base / Optimism / Arbitrum / Polygon | https://basescan.org/address/0xb300000b72deaeb607a12d5f54773d1c19c7028d ; https://optimistic.etherscan.io/address/… ; https://arbiscan.io/address/… ; https://polygonscan.com/address/… | 2026-08-05 |
| Volume methodology: per-chain router addresses incl. Linea/Sonic/zkSync/Plasma variants and Solana program `B3111yJ…`; dedup by largest hop per `(tx_hash, taker)`; `start: 2025-01-01` | https://github.com/DefiLlama/dimension-adapters/blob/master/aggregators/binancewallet/index.ts | 2026-08-05 |
| 24h/7d/30d volume; 12 chains; per-chain split (BSC $612.44m of $623.02m); category recorded as **"Wallets"**; `change_1m` +830.96% | `https://api.llama.fi/overview/aggregators` (`defillamaId` 6935) | 2026-08-05 |
| Current standing swap fee | **UNKNOWN — no primary source found** | 2026-08-05 |
| Identity of liquidity "providers"; whether Binance/affiliate is ever the maker; existence of PFOF | **UNKNOWN — no primary source found** | 2026-08-05 |

### 5. WHAT LOOKS UNNAMEABLE

1. **Order-flow origination as a property right.** Binance's economic position is that it owns the
   demand. It does not need a matching mechanism, an auction or a solver set, and it has none. The
   four execution symbols (`In`, `Ba`, `Rf`, `Ag`) describe how a trade is matched; not one of them
   describes who was entitled to decide where it went.
2. **Administrative venue allocation with an undisclosed counterparty set.** "Binance chooses the
   best option from different providers" is neither an auction nor a route — it is discretion. There
   is no symbol for discretionary allocation of a fill without a stated rule.
3. **CEX-balance origination of an on-chain trade.** Alpha 2.0 lets a Spot/Funding balance become an
   on-chain swap with no wallet in the loop. The custody boundary is crossed inside the mechanism.
4. **A confined asset: bought on-chain, non-withdrawable and non-transferable until the venue
   operator lists it.** `Fz` (freeze/forced transfer) is a protocol-level control over an asset;
   this is a venue-level restriction on the *user's* claim, imposed by the party that also chose the
   venue. Different actor, different object.
5. **MEV protection consumed as a chain-level default rather than produced.** The wallet's guarantee
   is supplied by BNB Chain's private-RPC programme. The vocabulary has no way to say that a
   protocol's property is inherited from its host chain's infrastructure.
6. **A settlement contract as an upgradeable Diamond controlled by a single owner, verified but with
   no public codebase.** `Up` names a mutable implementation proxy; it does not name per-selector
   facet replacement, and it says nothing about the *evidentiary* status of the code.
7. **Fee waiver as a distribution weapon.** An eight-month, product-scoped, wallet-type-scoped zero
   fee promotion is a market-share instrument, not a fee schedule. Nothing names a temporary,
   conditional, strategically-timed price of zero.

**Verdict on the corpus's `{Ag, Rf}` ≡ `{Ag, Rf}` claim (Binance Wallet vs OKX DEX): they are NOT
alike, and the corpus has it backwards.** Binance Wallet is a pure demand-side owner with *no*
sell-side product, *no* solver set, *no* published policy and *no* API. OKX is a supply-side vendor
that also owns demand: it sells the same engine to MetaMask, sells it to Jupiter, runs a sealed
solver auction with its own affiliated solvers in it, and publishes a conflict-of-interest policy
about all of that. Moreover the `Rf` assignment to Binance Wallet is, as the corpus itself flags,
*inferred* — I found no primary source establishing that Binance Wallet sources firm maker quotes,
and I therefore record it as UNCONFIRMED rather than approximate.

### 6. DELTA

- **DefiLlama's category for Binance Wallet is `Wallets`, not `DEX Aggregator`.** It appears on the
  aggregator leaderboard nonetheless. The corpus treats it as an aggregator without noting that its
  own ranking source does not.
- **7d and 30d figures moved.** Corpus: $5.133b 7d / $12.511b 30d. Live: **$4,293,696,243 /
  $12,443,825,856**. The 24h figure ($623,021,139) is byte-identical to the corpus, with
  `change_1d = 0` — i.e. the adapter had not rolled to a new day at access time. Treat 7d as revised.
- **98.3% single-chain concentration and `change_1m` = +831% are not in the corpus.** As with
  LiquidMesh, the #2 protocol is a one-month-old BNB-Chain phenomenon.
- **The corpus marker on `Rf` says the symbol is "partly INFERRED".** My finding is stronger:
  **there is no primary evidence for RFQ at all.** The FAQ's phrase is "CeFi and DeFi exchanges",
  which is consistent with RFQ but equally consistent with routing to a CEX-operated on-chain pool.
  Downgrade from "approximate" to "unconfirmed".
- **The corpus residue item "No element for gasless/sponsored swap UX at this layer beyond the
  candidate `Gs`" is not supported by anything I found.** Binance's own announcement says the
  opposite — "users will still need to pay for network gas fees." Binance Wallet does not appear to
  offer gasless swaps. The `Gs` CANDIDATE-REGISTER marker on Binance Wallet looks unwarranted.

---

## OKX DEX

### 1. WHAT IT DOES

OKX DEX (branded **"OKX DEX Aggregator+"** in the wallet, **"OnchainOS" / "Trade API"** for
developers) is two different products behind one button, and the system — not the user — decides
which one runs. In *classic aggregator* mode the user signs an ordinary transaction to OKX's
`DexRouter` and bears price risk against a min-return bound, exactly like LiquidMesh or Binance
Wallet. In *Intent Swap* mode the user signs an **intent** — a declaration to swap A for B under
stated conditions — which is not broadcast to the public mempool but sent to an allowlisted set of
solvers who "compete in a batch auction to offer you the best execution price"; the auction takes
about two seconds, the winning solver executes on-chain through a settlement contract and **pays the
gas**, and the contract enforces that "you receive at least the minimum amount specified in your
intent order", reverting and returning the tokens otherwise. Selection between the two is automatic
and depends on trade size (≳$1,000 favours Intent), token type (RWA tokens route to Intent) and
speed mode (Meme mode and Quick Buy favour the aggregator). So *who bears price risk between
signature and fill* differs by path: in aggregator mode the user does; in Intent mode the winning
solver does, between its bid and its settlement. The user's guarantee is the min-return floor in
both cases, plus — in Intent mode only — non-exposure to the public mempool. Fees are stated to be
identical across both paths, with "no additional fees for using Intent Swap".

### 2. DESIGN

**Route construction (classic).** A "smart order splitting algorithm" evaluating quotes from DEXs
and PMMs (private market makers), selecting on price, slippage and cost; named sources include
Uniswap, Curve and Balancer. The developer workflow is `/supported/chain` → `/aggregator/all-tokens`
→ `/quote` → `/approve-transaction` → `/swap`, on `/api/v6/dex/aggregator/*`. Route computation is
off-chain and closed.

**Route construction (self-hosted).** OKX also ships **Pallas**, "an OKX-built DEX aggregator client
deployed on user infrastructure, providing on-chain AMM quoting and transaction building" for
Solana: real-time pool state over Geyser gRPC (Yellowstone/Richat) plus RPC polling, local multi-hop
optimal route computation, an HTTP `/swap` and `/swap-instruction` API, Prometheus metrics, and —
notably — **"Cyclic arbitrage routing — find the most profitable round-trip (same token in and out)
across a set of intermediate tokens."** It is distributed as a **binary only**, requires an OKX API
key/secret/passphrase and whitelist approval, and recommends 8 cores / 16 GB / 100 GB SSD.

**Solver / filler set (Intent).** "Allowlisted Solvers" in a "parallel batch auction". "Multiple
professional solvers — including OKX's in-house Solver and third-party solvers" receive the intent
and bid in a **sealed** auction. Solvers "can tap into diverse liquidity sources — including private
market makers, cross-DEX arbitrage, and proprietary strategies". OKX's conflict-of-interest policy
confirms in writing that "one or more Solvers operated by, or affiliated with, OKX or its affiliates
participate in the OKX Intent auction system as competing Solvers", subject to "identical onboarding
requirements, performance standards, anti-manipulation controls".

**Settlement contracts.** `DexRouter` per chain, plus a `TokenApprove` contract per EVM chain
(Solana and TON need no approval). Current documented routers include Ethereum
`0x8feab81d36e7576107d5de0758c1b839be31b4f6`, Arbitrum `0x09f94b5fc68e227c323a6fbae3bd98c97fd8c849`,
Base `0x67d03631fe51b741c0c00c4e16eb662ac80938ad`, BNB Chain
`0x5994814f2c4040b863a0125a45de152a8c2a4dec`, Polygon `0x3c4829196bfadff4394726b45159aeaac6fcd41c`;
Solana `proVF4pMXVaYqmy4NjniPh4pqKNfMmsihgd4wdkCX3u`; Sui
`0x4f1f29379f9fff73adb850ecf15513179d9b6a924e8c1d553d25582629778923`; Tron
`TTWd2hBKmEmYiCXtm4TiZ1FjzVQJaVm8N4`; TON `EQAgvOlWk7C0Pz3YgSaX-MA7UDDhE9n6eQgQRwJahOBm4VKr`. **OKX
warns these "may be subject to replacement due to contract upgrades" and instructs integrators to
use the address returned by the API rather than hardcoding it** — the settlement address is itself a
moving part. An older BSC deployment, `0x6015126d7D23648C2e4466693b8DeaB005ffaba8`, is verified on
BscScan as contract name `DexRouter` (solc 0.8.17, not a proxy), declaring events `OrderRecord`,
`CommissionFromTokenRecord` and `CommissionToTokenRecord`.

**Fee and rebate flow.** The referrer commission is a **router-level primitive**, not an API
convention. In the published `CommissionLib.sol`: `commissionRateLimit = 300` (3%), an
`event CommissionRecord(uint256 commissionAmount, address referrerAddress)`, and a `CommissionInfo`
struct read out of the **last words of calldata** via magic flags `FROM_TOKEN_COMMISSION` /
`TO_TOKEN_COMMISSION`; `_doCommissionFromToken` / `_doCommissionToToken` then take the cut before or
after the swap. The API surface mirrors it: `fromTokenReferrerWalletAddress`,
`toTokenReferrerWalletAddress`, `feePercent` (≤9 decimals), **max 10% on Solana and 3% elsewhere**,
one side only per transaction, fee deducted before execution, "currently the OKX DEX API charges no
fees". The recipient is the integrator, not OKX.

**MEV.** A Broadcast Transaction API with built-in MEV protection on Solana, Base, Ethereum and BSC,
**available to whitelisted customers only** (`dexapi@okx.com`). On Solana, Jito tips can be combined
for priority plus MEV protection (with `computeUnitPrice=0`). Separately, in the OKX Wallet itself,
MEV protection is supplied by **Consensys' SERVO** — OKX says it is "the first major external partner
to integrate" it.

**Who owns the order flow, and how the right to fill is sold.** OKX is the only participant in this
lane that operates on **both** sides of the order-flow market simultaneously, and the only one that
says so in writing.

- *It buys demand by owning users*: the OKX exchange app and OKX Wallet embed OKX DEX.
- *It sells its engine to other order-flow owners*: since 2025-06-19 the OKX DEX API powers swaps
  inside **MetaMask** ("500+ DEXs … under 100ms"), the same partnership under which Consensys
  supplies SERVO to OKX Wallet.
- *It sells its routing as a quote to a rival aggregator*: **Jupiter's own documentation lists
  "OKX — Third-party liquidity provider" as one of four engines competing inside Jupiter's
  meta-aggregator.**
- *It sells fill rights via a sealed auction* (Intent), in which it also competes.
- *It hands the monetization lever to integrators* via the on-chain referrer commission (≤3%, ≤10%
  Solana).
- *It owns a chain*: X Layer.

Its **conflict-of-interest policy** (published 2026-04-30, modified 2026-05-29) is the single most
important primary document in this category. It disclaims preferential routing to OKX-affiliated
liquidity sources, OKX Ventures portfolio projects, X Layer protocols, or sources with a
"commercial relationship, marketing arrangement, or revenue-sharing agreement" — the *denial* is
itself proof that such relationships exist and are known to be a conflict. And it concedes one:
"the OKX Aggregator's route may be presented as the default selection or may be visually emphasized
in the User Interface, including in cases where the OKX Aggregator's quoted received amount is not
the highest among the available providers."

### 3. REPO

**Partly a front-end whose substance is off-chain routing, but with the most open settlement layer
in the lane — formerly.**

- **Canonical repository: `github.com/okx/WEB3-DEX-OPENSOURCE` — NOW HTTP 404.** The GitHub API
  returns "Not Found" for the repo, its contents, its tags and its commits (checked 2026-08-05), and
  the `okx` organisation listing (100 repos) does not contain it. The code survives only in forks;
  I inspected `Julian-dev28/WEB3-DEX-OPENSOURCE` (Solidity, created 2024-12-05, HEAD pushed
  2024-12-06, not marked as a fork by the API — likely a re-upload), whose `README.md` still points
  installation instructions at `git clone https://github.com/okx/WEB3-DEX-OPENSOURCE.git`.
- **License: Apache-2.0** at the repo root (`LICENSE` begins "License: Apache2.0"); individual files
  carry `SPDX-License-Identifier: MIT` (e.g. `CommissionLib.sol`). Mixed and worth flagging.
- **Language:** Solidity, Hardhat. **Layout:** `contracts/8/{DexRouter.sol, TokenApprove.sol,
  TokenApproveProxy.sol, UnxswapRouter.sol, UnxswapV3Router.sol, adapter/, interfaces/, libraries/,
  mock/, storage/, utils/}`, plus `hardhat.config.js`, `.github`, `.env.sample`. Self-described as
  "SOR SmartContract … The primary contract in this repository is `DexRouter`", audited by "okx
  innter [sic] audit team" — **no external audit is claimed.**
- **Do deployed contracts match the repo?** Partially and no longer checkably. The BSC deployment
  `0x6015126d…` is verified with contract name `DexRouter` and the expected event set, which is
  consistent. But OKX's live documented routers are *different addresses* from the ones commented
  out in DefiLlama's adapter, and OKX states addresses rotate on upgrade. With the canonical repo
  gone there is no versioned source of record to diff against.
- **Other OKX repos (all live, checked 2026-08-05):** `okx/okx-dex-sdk` (TypeScript, **MIT**, 79★,
  tags v1.0.0–v1.0.2, HEAD `6be0a98a` 2026-07-14); `okx/dex-api-library` (TypeScript, 44★);
  `okx/dex-widget` (TypeScript, no license, 15★); `okx/onchainos-skills` (315★, pushed 2026-08-04);
  **`okx/dex-solana-binary`** (Dockerfile only, no license, 25★, created 2026-04-10, pushed
  2026-08-03) — this is Pallas, and it contains a `Dockerfile`, `docker-compose.yml`, `README.md`
  and `docs/`, **and no source code.** The Solana routing engine is a closed binary behind a
  whitelist form.
- **Verifiable:** the router source on chains where it is verified; the commission mechanism down to
  the calldata layout; the router addresses at any instant. **Not verifiable:** the splitting
  algorithm, the PMM quote set, the solver allowlist, the auction's conduct, and whether the
  affiliated solver wins more than it should.

### 4. EVIDENCE

| Claim | Source | Accessed |
|---|---|---|
| Intent Swap: signed intent, sealed ~2s batch auction, allowlisted + in-house solvers, solver pays gas, settlement contract enforces minimum or reverts, no mempool exposure; automatic Intent-vs-aggregator selection by size/token-type/speed mode; "no additional fees for using Intent Swap" | https://www.okx.com/en-eu/help/what-is-okx-dex-aggregator-plus | 2026-08-05 |
| **Conflict-of-interest policy**: affiliated solvers compete in the OKX Intent auction; no preferential routing to affiliates/OKX Ventures/X Layer/commercial partners; OKX's own route may be the default or visually emphasised even when not the best price; published 2026-04-30, modified 2026-05-29 | https://www.okx.com/en-us/help/dex-aggregator-and-intent-conflict-of-interest-policies | 2026-08-05 |
| Smart order splitting across DEXs and PMMs; Uniswap/Curve/Balancer; endpoint workflow | https://web3.okx.com/onchainos/dev-docs/trade/dex-swap-api-introduction | 2026-08-05 |
| Router + TokenApprove addresses per chain incl. Solana/Sui/Tron/TON; addresses may change on upgrade; use API-returned address | https://web3.okx.com/onchainos/dev-docs/trade/dex-smart-contract | 2026-08-05 |
| Referrer fee params `fromTokenReferrerWalletAddress` / `toTokenReferrerWalletAddress` / `feePercent`; 10% Solana, 3% elsewhere; one side per tx; deducted pre-execution; recipient is the integrator; OKX currently charges no API fee | https://web3.okx.com/onchainos/dev-docs/trade/dex-api-addfee | 2026-08-05 |
| `CommissionLib.sol`: `commissionRateLimit = 300`, `event CommissionRecord(uint256, address referrerAddress)`, calldata-tail encoding with `FROM_TOKEN_COMMISSION` / `TO_TOKEN_COMMISSION` flags | https://github.com/Julian-dev28/WEB3-DEX-OPENSOURCE `contracts/8/libraries/CommissionLib.sol` (Apache-2.0 repo; upstream `okx/WEB3-DEX-OPENSOURCE` now 404) | 2026-08-05 |
| `DexRouter.sol` emits `OrderRecord(...)` at line 367; `CommonUtils.sol:70` declares it | same repo | 2026-08-05 |
| BSC `0x6015126d…` verified, name `DexRouter`, solc 0.8.17, not a proxy, events `OrderRecord`, `CommissionFromTokenRecord`, `CommissionToTokenRecord` | https://bscscan.com/address/0x6015126d7d23648c2e4466693b8deab005ffaba8#code | 2026-08-05 |
| Pallas: OKX-built self-hosted Solana aggregator client, Geyser gRPC, local route computation, **cyclic arbitrage routing**, `/swap` + `/swap-instruction`, API key + whitelist form, binary distribution | https://github.com/okx/dex-solana-binary `README.md` | 2026-08-05 |
| MEV protection on the Broadcast API for SOL/ETH/BSC/BASE; whitelisted customers only via `dexapi@okx.com`; Jito tips + `computeUnitPrice=0` on Solana | https://web3.okx.com/onchainos/dev-docs/home/change-log and https://web3.okx.com/build/dev-docs/dex-api/dex-use-swap-solana-quick-start (via search index) | 2026-08-05 |
| OKX DEX API powers MetaMask (500+ DEXs, <100ms); Consensys SERVO supplies MEV protection to OKX Wallet; published 2025-06-19 | https://web3.okx.com/learn/okx-dex-api-consensys | 2026-08-05 |
| **OKX is a routing engine inside Jupiter's meta-aggregator** | https://developers.jup.ag/docs/swap/routing and https://developers.jup.ag/docs/blog/ultra-v3 | 2026-08-05 |
| Volume methodology: SwapRouter on-chain path is entirely **commented out**; all chains fall through to OKX's own `/api/v5/dex/aggregator/volume` endpoint, HMAC-authenticated with an OKX API key. 34 active chains. A hardcoded invalid-spike suppression exists for Tron 2026-06-24. | https://github.com/DefiLlama/dimension-adapters/blob/master/aggregators/okx/index.ts | 2026-08-05 |
| 24h/7d/30d volume; 35 chains; DefiLlama display name **"OKX Swap"** (`defillamaId` 5201, slug `okx-swap`, parent `parent#okx-dex`); `change_1d` −37.78% | `https://api.llama.fi/overview/aggregators` | 2026-08-05 |
| `okx/WEB3-DEX-OPENSOURCE` returns HTTP 404 from the GitHub API | `gh api repos/okx/WEB3-DEX-OPENSOURCE` | 2026-08-05 |

### 5. WHAT LOOKS UNNAMEABLE

1. **A published conflict-of-interest disclosure as part of the mechanism.** OKX states which of its
   own arms compete on its own order flow. No symbol names a self-declared conflict, and nothing in
   the vocabulary can express "the operator is also a bidder."
2. **UI default as an execution primitive.** OKX concedes its own route may be shown as the default
   or visually emphasised *even when it is not the best price*. Order flow is captured at the pixel
   layer. This is the purest case in the entire category of a mechanism the 58 symbols cannot see —
   because it is not on-chain at all, and yet it determines where a majority of trades go.
3. **Automatic path selection between two incompatible execution regimes** (aggregator vs sealed
   solver auction) based on trade size, token classification and a user-chosen "speed mode". `In`
   and `Ba` name the regimes; nothing names the *dispatcher* that chooses between them, or the fact
   that price risk changes hands depending on which one fires.
4. **The router as a product sold to competitors.** OKX's engine is simultaneously (a) the wallet's
   own aggregator, (b) MetaMask's aggregator, and (c) a quoting *participant inside Jupiter*. The
   vocabulary has no way to express that one `Ag` is nested inside another `Ag`.
5. **Cyclic arbitrage routing as a shipped feature.** Pallas will find profitable round-trips for
   you. The router is also a searcher, sold as such.
6. **A closed binary as the canonical routing artifact** (Pallas; and see Jupiter's `metis-binary`).
   "The mechanism" is a Docker image behind a whitelist form.
7. **Whitelisting as the gate on MEV protection.** The Broadcast API's protection is available to
   approved customers only — protection is a tier, not a property.
8. **Commission encoded in the calldata tail with a magic flag, enforced by the settlement contract
   at ≤3%/≤10%.** This is order-flow monetization compiled into the settlement layer. `Fd` (surplus
   & fee distribution) is a candidate symbol about *protocol* surplus; this is a third party's cut of
   someone else's user, and the router enforces its cap.
9. **Mutable settlement addresses as documented policy.** "Use the address returned by the API."
   The identity of the settlement contract is not a constant.

**Verdict (Binance Wallet vs OKX DEX): NOT alike.** See §5 under Binance Wallet.

### 6. DELTA

- **`{Ag, Rf}` is materially wrong as of this research date.** OKX operates **OKX Intent**: signed
  intents, a *sealed batch auction*, an allowlisted solver set including OKX's own solvers, solver-paid
  gas, and a settlement contract enforcing the minimum. That is `In` and, on OKX's own wording
  ("parallel batch auction"), arguably `Ba` — plus a competitive solver tournament. The corpus's
  claim that "the four intent symbols do not begin to differentiate anything until rank 6 and below"
  fails at rank 3.
- **Rank 3 is no longer rank 3.** Corpus: OKX #3 at $461.89m 24h. Live at access time: **$287,391,522**,
  which places it **behind Jupiter ($371,992,212)**. `change_1d` = −37.78%, and 287.39/461.89 = 0.622
  exactly, so the corpus's figure was the prior day and the leaderboard has since rolled. Ranks 3 and
  4 in the corpus are inverted relative to the live source.
- **OKX's volume is self-reported and should be labelled as such.** The DefiLlama adapter's on-chain
  `SwapRouters` block is entirely commented out; every chain hits
  `https://www.okx.com/api/v5/dex/aggregator/volume`, HMAC-signed with an OKX-issued key. Combined
  with a hardcoded suppression of an "invalid spike" on Tron, this is a vendor-attested number, not
  a measurement. The corpus's `laneSource` note about the HTTP-402 perps endpoint shows the lane was
  alert to this class of problem; it did not apply the same scrutiny here.
- **DefiLlama's display name is "OKX Swap"** (slug `okx-swap`), with "OKX DEX" only as a linked
  protocol under `parent#okx-dex`. The corpus uses "OKX DEX".
- **The corpus residue "No element for cross-chain swap routing as a distinct product"** stands, and
  is confirmed: OKX runs a separate cross-chain aggregator with its own
  `/api/v5/dex/cross-chain/supported/bridges` endpoint and deBridge integration, behind the same UI.
- **The canonical repo is gone.** Any later stage citing `github.com/okx/WEB3-DEX-OPENSOURCE` will
  hit a 404; cite a fork and say so.

---

## Jupiter

### 1. WHAT IT DOES

Jupiter is Solana's default trade router and, uniquely in this lane, a **meta-aggregator**: it does
not merely route to venues, it runs a competition between routing engines, of which two are its own
and three are other people's. A user calling `GET /swap/v2/order` receives a fully assembled
transaction — Jupiter has already compared Iris (its own router), JupiterZ (its own RFQ system) and
third-party routers **DFlow, OKX and Hashflow**, and has *simulated the candidate routes on-chain*
before choosing. The user signs that transaction and hands it back via `POST /execute`; Jupiter
lands it through its own infrastructure (Beam/ShadowLane, running on "one of the highest-staked
validators on Solana", `https://tx.jup.ag`, minimum 0.001 SOL tip). Price risk between signature and
fill is the user's, bounded by slippage, except on the JupiterZ path where a market maker has quoted
firm — but with **last look**, which is why Jupiter forbids modifying an RFQ transaction after
quoting and confines RFQ to the managed path. Jupiter claims the net effect is *positive* slippage
averaging +0.63 bps. Jupiter's other user-facing promise is the token-quality layer: an organic
score, Express Verification, and a 50 bps fee on tokens under 24 hours old. Its scheduled products
work differently and the difference matters: **Trigger V2 limit orders and DCA are held in a
Privy-managed custodial vault**, stored off-chain, private by default, fired by Jupiter's keepers
against Jupiter routing, and **the output amount is not guaranteed** because triggers are on USD
price rather than pool rate.

### 2. DESIGN

**Route construction.** Jupiter Swap API V2 exposes two mutually exclusive paths:

- **Meta-Aggregator** (`/order` + `/execute`) — "all routers compete (Metis, JupiterZ, Dflow, OKX)",
  returns an assembled transaction, Jupiter manages landing, charges a platform fee, supports RFQ
  and gasless.
- **Router** (`/build` + `/submit`) — raw instructions from **Metis only**, full transaction control
  for CPI and composability, **no Jupiter swap fee**, integrator monetizes via `platformFeeBps` or
  DIY. Metis is described as "an independent public good."

Jupiter states it runs "a self-learning mechanism that automatically sidelines underperforming
sources."

**Iris.** Introduced with **Ultra V3, published 2025-10-15**. Uses **golden-section search and
Brent's method** for split optimisation, supports "granular splitting, up to 0.01%", claimed 100×
performance improvement over Metis.

**Predictive Execution.** Candidate routes are *simulated on-chain before execution* and ranked on
predicted executed price rather than quoted price.

**Beam / ShadowLane.** In-house transaction landing on Jupiter's own validator and RPC; 0–1 block
(~50–400 ms) versus 1–3 blocks; Jupiter attributes a "34× better" volume-to-value-extracted ratio to
running its own landing rather than an external provider.

**JupiterZ (RFQ).** Native RFQ where market makers bid; ~$100m/day; zero slippage; gasless; **market
makers hold last-look execution rights**. Jupiter says RFQ makers "often beat onchain routing by
5–20 bps on major pairs." Makers integrate by running a webhook (`jup-ag/rfq-webhook-toolkit`, MIT).

**Fee and rebate flow.**

- *Jupiter platform fee* on `/order`, included in the quote and deducted automatically: **0 bps** for
  SOL/stable → JUP/JLP/jupSOL and for LST-LST and stable-stable; **2 bps** SOL↔stablecoin; **5 bps**
  LST↔stablecoin; **10 bps** everything else; **50 bps** for tokens listed within 24 hours. Fee is
  collected in a priority order: SOL → stablecoins → LSTs → large caps → other.
- *Integrator referral fee*: `referralAccount` + `referralFee`, **50–255 bps**, and **Jupiter takes
  20% of the integrator's fee.** If the integrator's referral token account is uninitialised the
  order still executes — without the integrator's fee. On the Router path there is no Jupiter fee
  and the integrator uses `platformFeeBps` instead.
- *Trigger V2 does not support integrator fees at all.*
- *Buyback*: Jupiter has publicly committed 50% of protocol fees to the **Litterbox Trust** for JUP
  buyback-and-lock, with a governance proposal to raise it to 70%. (Secondary sources only; the
  Litterbox mechanics are **UNCONFIRMED at a Jupiter primary source** in this research pass and are
  flagged as such.)

**Product surface beyond swap** (from the docs index): Tokens API with organic scoring and Express
Verification; Price API v3; **Lend** (Earn/Borrow/Flashloans, CPI-integrable); Trigger (limit/OCO/
OTOCO + DCA); **Prediction markets** (binary YES/NO, "Jupiter Forecast" 15-minute BTC rounds settled
via Chainlink); Perps; Portfolio; Send; Studio (token creation and bonding curves); Lock (vesting).

**Who owns the order flow, and how the right to fill is sold.** Jupiter owns Solana's default
front-end *and* sells the right to compete for its flow *and* buys other people's routing. Four
distinct positions at once:

- *It buys routing from rivals.* DFlow, OKX and Hashflow are quote sources inside Jupiter. DFlow, at
  category rank 6, is the only protocol in this category whose explicit product is the sale of order
  flow — and it sells into Jupiter.
- *It sells fill rights to market makers* through JupiterZ, including the last-look privilege.
- *It sells distribution to integrators* at 50–255 bps, keeping 20% — a stated revenue split on
  someone else's users.
- *It internalises everything downstream*: its own router, its own RFQ, its own landing engine, its
  own validator, its own lending market, its own perps, its own LST, its own launchpad, its own
  prediction market. There is no step of the lifecycle Jupiter does not also own a venue for.

**Slippage and MEV.** MEV protection is a consequence of owning the landing path rather than a
contracted service. Gasless support expanded in Ultra V3 to Token2022, memecoin-to-memecoin, and a
minimum trade size around $10.

### 3. REPO

**On-chain settlement, but the routing engine is closed.**

- **GitHub organisation: `github.com/jup-ag` — 200+ repositories** (enumerated via the GitHub API,
  2026-08-05). **There is no repository containing the aggregator program's source.** The org holds
  SDKs, integration adapters and vendored dependencies: `jupiter-swap-api-client` (Rust, **no
  license**, 199★, HEAD `fb95cfad` 2025-12-29), `jupiter-amm-interface` (Rust, no license, 79★),
  `rfq-webhook-toolkit` (Rust, **MIT**, 31★, HEAD `bd96bebf` 2026-08-04), `rfq-v2-sdk`,
  `jupiter-lend`, `UltraV3-Demo`, `docs`, plus dozens of third-party AMM integrations
  (`raydium-cp-swap`, `openbook-v2`, `phoenix-v1`, `manifest-amm`, `whirlpools`, …) with mixed
  Apache-2.0 / MIT / GPL-3.0 / NOASSERTION licenses.
- **`jup-ag/metis-binary` — "The Metis binary by Jupiter"** (Dockerfile, **no license**, 260★,
  created 2023-11-16, pushed 2026-07-08). Contains a `Dockerfile`, `.github` and `examples`. **The
  routing engine is distributed as a binary, not as source** — structurally identical to OKX's
  Pallas.
- **Deployed program:** the aggregator is `JUP6LkbZbjS1jKKwapdHNy74zcZ3tLUZoi5QNyVTaV4` ("Jupiter
  Aggregator v6"), the program DefiLlama measures via `dex_solana.trades` where
  `trade_source = 'JUP6…'`. **Whether deployed bytecode matches published source: N/A — no source is
  published.** Claims that "Jupiter is open source" appear only on third-party sites (an OKX Learn
  article, review blogs) and are **not supported** by the `jup-ag` org contents. Recorded as a
  contradiction, resolved against the marketing claim.
- **Audits are published** (`developers.jup.ag/docs/resources/audits`), which is the compensating
  control: Jupiter Swap v6 by Offside Labs (April 2024 and October 2025) and Sec3 (v3); Perpetuals by
  Offside Labs, OtterSec, Sec3; Lend by Certora (formal verification, two reports, the second
  covering 2026-01-07 → 2026-03-31), Code4rena (2026-02-12 → 2026-03-13), OtterSec ×2, Offside Labs
  ×3, Mixbytes, Zenith; Limit Order v2 by Offside Labs; Lock by OtterSec and Sec3; DAO by Offside
  Labs. Bug bounty at `security.jup.ag`.
- **Verifiable:** the program ID and its instruction stream; the audit reports; the fee schedule as
  applied on-chain; the AMM integration adapters. **Not verifiable:** Iris's algorithm as deployed,
  Predictive Execution's simulation, JupiterZ maker conduct and last-look rejections, Beam's landing
  behaviour, the +0.63 bps positive-slippage claim, and — most consequentially — the contents of the
  Privy-managed Trigger vault.

### 4. EVIDENCE

| Claim | Source | Accessed |
|---|---|---|
| Meta-Aggregator vs Router split; "all routers compete (Metis, JupiterZ, Dflow, OKX)"; `/build` is Metis-only and carries no Jupiter fee; RFQ confined to the managed path because "market makers have last-look execution rights" | https://developers.jup.ag/docs/swap/ | 2026-08-05 |
| Four routing engines (Metis, JupiterZ, Dflow, OKX); RFQ makers beat onchain routing by 5–20 bps; self-learning source sidelining; Metis as "an independent public good" | https://developers.jup.ag/docs/swap/routing | 2026-08-05 |
| Ultra V3, published **2025-10-15**: Iris (golden-section + Brent, 0.01% splitting, 100×), Jupiter Beam landing (0–1 block, 50–400 ms, own validator/RPC), Predictive Execution (+0.63 bps average positive slippage), 34× better volume-to-value-extracted vs competitors per sandwiched.me, JupiterZ ~$100m/day, meta-aggregation incl. **Hashflow**, gasless expansion to Token2022 and memecoin↔memecoin, ~$10 minimum | https://developers.jup.ag/docs/blog/ultra-v3 | 2026-08-05 |
| Platform fee schedule (0/2/5/10/50 bps); fee-token priority order; referral 50–255 bps with Jupiter taking 20%; uninitialised referral account → swap proceeds without integrator fee; `feeBps`/`feeMint`/`platformFee` response fields | https://developers.jup.ag/docs/swap/fees | 2026-08-05 |
| Trigger V2: single **Privy-managed custodial vault** per wallet; keeper-executed; USD price triggers not pool-rate; **output not guaranteed**; keeper sets DCA slippage per round; orders stored **off-chain and private by default**; **no integrator fees supported** | https://developers.jup.ag/docs/trigger/ | 2026-08-05 |
| Product index: Swap V2, Tokens v2 (organic score, Express Verification), Price v3, Lend (Earn/Borrow/Flashloans), Trigger (LO+DCA), Prediction (Jupiter Forecast, Chainlink), Perps, Portfolio, Send, Studio, Lock; API tiers 0.5–150 RPS; firewall with country/IP/header rules; `tx.jup.ag` landing with 0.001 SOL minimum tip and "one of the highest-staked validators on Solana"; auditors list | https://developers.jup.ag/docs/llms.txt | 2026-08-05 |
| Audit inventory with firms and dates | https://developers.jup.ag/docs/resources/audits | 2026-08-05 |
| `jup-ag` org contents; `metis-binary` is Dockerfile-only, no license, 260★; no aggregator source repo; SDK licenses | GitHub API over `orgs/jup-ag/repos` and `repos/jup-ag/*`, 2026-08-05 | 2026-08-05 |
| Volume methodology: `dex_solana.trades` filtered to `trade_source = 'JUP6LkbZbjS1jKKwapdHNy74zcZ3tLUZoi5QNyVTaV4'`, deduped per `(tx_id, trader_id, outer_instruction_index)`; `jupiter_solana.aggregator_swaps` used before 2025-09-01 and noted as having incomplete coverage after | https://github.com/DefiLlama/dimension-adapters/blob/master/aggregators/jupiter-aggregator/index.ts | 2026-08-05 |
| 24h/7d/30d volume; Solana only; `change_1m` −37.6%; `parentProtocol` `parent#jupiter` | `https://api.llama.fi/overview/aggregators` (`defillamaId` 2141) | 2026-08-05 |
| Litterbox Trust / 50% of protocol fees to JUP buyback; proposal to raise to 70% | Secondary only (The Block, discuss.jup.ag thread title). **UNCONFIRMED at a Jupiter primary source in this pass.** | 2026-08-05 |
| Jupiter aggregator program source availability | **UNKNOWN/closed — no source repository found in `jup-ag`; third-party "open source" claims not substantiated** | 2026-08-05 |

### 5. WHAT LOOKS UNNAMEABLE

1. **Meta-aggregation: an `Ag` whose leaves are other `Ag`s.** Jupiter's quote set includes DFlow,
   OKX and Hashflow — two of which are themselves ranked members of this very category. The
   vocabulary has no composition operator and therefore cannot distinguish "routes to venues" from
   "routes to routers," nor represent the fact that a corpus row is nested inside another corpus row.
2. **Simulate-before-choose.** Predictive Execution ranks routes by *simulated executed price* rather
   than quoted price. This is a distinct epistemic act — the mechanism does not trust its own quotes —
   and nothing in the 58 names it.
3. **Owning the landing path.** A protocol-operated validator and RPC as the terminal stage of its
   own trade lifecycle, with a tip floor. MEV protection is then not a service but a *consequence of
   vertical integration*. No symbol names the transaction's route to inclusion, and none names
   owning it.
4. **Last look.** A maker who may decline after quoting inverts the guarantee of `Rf` ("signed maker
   quote"). Jupiter's own API design concedes it: RFQ cannot be composed because the maker retains
   an option. `Rf` as written asserts a firm quote and is therefore *wrong* for JupiterZ, not merely
   approximate.
5. **Custodial off-chain order storage.** Trigger V2 orders live in a Privy-managed custodial vault,
   off-chain and private by default. This is not an intent (`In` presumes a signed outcome
   constraint enforceable by anyone), not an order book (`Ob` presumes on-chain), and not RFQ. A
   custodian holds the funds and a keeper fires the order with no output guarantee. **The vocabulary
   has no symbol for custody at all**, which is a gap worth escalating beyond this category.
6. **Privacy as MEV defence for resting orders.** V1's on-chain order accounts were visible and
   therefore exploitable; V2 hides them. Concealment of a *resting* order as a mechanism property.
7. **A fee that is a function of token age** (50 bps within 24 hours of listing) and a fee **collected
   in a priority-ordered choice of token**. Fee schedules conditioned on asset novelty and on which
   leg is more liquid.
8. **Organic score / Express Verification** — a protocol-assigned quality label on the asset,
   affecting what the router will show and price.
9. **Scheduled / time-sliced execution.** Confirmed as residue, and the corpus's rejection of the
   contested `Tw` is correct and now *stronger* than the corpus knew: under V2 the slices are fired
   by a keeper from a custodial vault against USD price triggers, which is even further from a TWAMM
   pool invariant than V1 was.
10. **A tiered, firewalled, geographically-filterable API as the access surface to the mechanism**
    (0.5 → 150 RPS tiers; deny/rate-limit rules by country, IP/CIDR and header). Who may query the
    router at what rate is itself an allocation of execution quality.

### 6. DELTA

- **`{Ag, In, Rf}` misses the meta-aggregation, and the `Rf` marker is wrong in kind.** The corpus
  marker on `In` says Jupiter has "no competitive solver auction". That is now half wrong: Jupiter
  runs a competition, but between *routers* rather than solvers, and one of the competitors is a
  rival protocol in the same corpus. And `Rf` should carry a marker that JupiterZ makers hold **last
  look**, which contradicts the symbol's definition of a firm signed quote.
- **The corpus residue on DCA is now understated.** It describes "an off-chain keeper firing discrete
  swaps against ordinary venues." Trigger V2 additionally introduces a **Privy custodial vault**,
  off-chain private order storage, USD-price rather than pool-rate triggers, and an explicit
  **no-output-guarantee**. The custody change is a category change, not a detail.
- **The corpus residue "No element for route-quality guarantees / price-improvement sharing"** is
  confirmed and sharpened: Jupiter publishes a measured positive-slippage figure (+0.63 bps) as a
  product claim.
- **The corpus residue "No element for the router also owning the venues it routes to"** is confirmed
  and now larger: since the corpus's list (perps, lending, LST, launchpad) Jupiter has added **Lend
  with flashloans**, **prediction markets** (Jupiter Forecast, Chainlink-settled), **Studio** with
  bonding curves, **Lock**, **Send**, and **its own validator**.
- **Rank.** Corpus: Jupiter #4 at $371.99m. Live at access time: **#3** — same $371,992,212 with
  `change_1d = 0` (adapter not yet rolled), now ahead of OKX's revised $287.39m. The corpus's own
  note that Jupiter has the highest 30d volume in the category is confirmed ($14.57b vs OKX $6.90b);
  its 30d figure has been revised from $15.163b to $14,566,671,290.
- **Coverage caveat the corpus does not carry:** DefiLlama measures **only** the v6 program
  `JUP6…`. If Ultra V3's Iris path or JupiterZ settle through a different program, that volume is
  invisible to the ranking. I could not determine whether they do — **UNKNOWN**, and it is the single
  most important open measurement question in this lane.

---

## KyberSwap

### 1. WHAT IT DOES

KyberSwap is a multi-chain aggregator that charges its users nothing and makes its money in three
places they do not see. A user calls `GET /routes` and `POST /route/build`, then signs an ordinary
transaction to `MetaAggregationRouterV2`, deployed at the *same* address on every supported chain.
KyberSwap picks the venue across 400+ DEXs on 25 networks, including AMMs, order books, its own
limit-order book, and off-chain PMM quotes settled on-chain only when they beat the alternatives.
Price risk between signature and fill is the user's, bounded by `slippageTolerance` (0–2000 bps) and
a deadline — but with an unusual twist: **Smart Settlement re-decides the venue on-chain, at
execution time**, comparing candidate pools per hop and switching if the originally chosen pool has
been sandwiched, front-run, spread-widened by a PropAMM, or drained by JIT liquidity removal. The
user's guarantee is therefore the min-received amount plus a best-efforts on-chain re-selection.
What the user is *not* told at the front end is that **surplus above the estimated output — positive
slippage — accrues to KyberSwap**, as do unconsumed dust amounts. Separately, KyberSwap routes into
pools that only KyberSwap may trade with: **FairFlow / Kyber Exclusive Market**, Uniswap v4 and
PancakeSwap Infinity hooks whose swaps are "restricted … to only the Kyberswap DEX Aggregator", where
the pool delivers a signed fair price to the trader and *absorbs the excess* as Equilibrium Gain,
70% of which is paid to LPs and 30% to Kyber as hook owner.

### 2. DESIGN

**Route construction.** Off-chain "dynamic trade routing" over four liquidity classes — AMM DEXs,
order-book DEXs, KyberSwap's own limit orders, and PMMs (off-chain quotes, settled only if better).
The off-chain engine is `kyberswap-dex-lib`, **which is public**: 129 packages under
`pkg/liquidity-source`, each implementing `PoolsListUpdater`, `PoolTracker` and `PoolSimulator`, and
the README explicitly solicits external DEX teams to add their own by pull request, with the on-chain
encoding contributed to `ks-dex-adapter-lib`. **KyberSwap is the only protocol in this lane whose
route-construction substance is inspectable.**

**Smart Settlement.** An on-chain decision layer that "compares multiple candidate pools in real time
and selects the one that delivers the highest token output for each swap hop", targeting small pools,
PropAMM spread-widening, same-block sandwiching/front-running, and JIT liquidity removal.

**Settlement contracts.** `MetaAggregationRouterV2` at `0x6131B5fae19EA4f9D964eAc0408E4408b66337b5`
and `InputScalingHelperV2` at `0x2f577A41BeC1BE1152AeEA12e73b7391d15f655D`, **the same addresses on
every chain** (20+ listed, including Robinhood Chain). A **`KSAggregationRouterV3.sol`** exists in the
public `ks-aggregation-router` repository (created 2025-08-04, pushed 2026-07-30) but is not yet in
the docs — a V3 in flight.

**FairFlow / Kyber Exclusive Market (KEM).** The mechanism, in KyberSwap's own words:

1. A trade request arrives at the aggregator, which computes the best route with FF pools and the
   best route without them; the difference is "additional value".
2. If FF pools win, the aggregator "asks FF pools signer for a signature of the fair market price"
   — an off-chain **quote signer** produces a signed reference price, which is carried in the
   transaction.
3. The Uniswap v4 / PancakeSwap Infinity hook validates the signed fair price against actual pool
   output. If the pool does better than the signed price, it "deliver[s] the fair price result to the
   taker" and **absorbs the surplus internally** as Equilibrium Gain. If it does worse, the taker
   gets the actual output and no EG is captured.
4. EG accrues over **7-day cycles**, passes a **48-hour validation window**, then goes to a
   distribution contract: **70% to the LP pool, 30% to Kyber as hook owner** (the user-facing page
   describes the 30% as going to "Partners (Token teams & Platforms), KyberSwap, KyberDAO or
   reserve"). Distribution is weekly, in the pair's native tokens, with **no LP staking required**,
   and only pools enrolled in the EG Sharing Program are eligible.
5. The whole thing works because "**KyberSwap Aggregator is the only taker for FF pools, blocking
   external arbitrageurs from fully extracting value.**"

Deployment is via Uniswap v4 hooks (salt-mined for `BEFORE_SWAP_FLAG`, `AFTER_SWAP_FLAG`,
`AFTER_SWAP_RETURNS_DELTA_FLAG`) and PancakeSwap Infinity hooks, with configurable owner, claimable
accounts, whitelisted accounts, quote signer and EG recipient per chain. The reward accounting is
also public: `fairflow-reward` (Go) carries cycle directories `cycle-13` … `cycle-51` and per-chain
files `1_EG_12.json`, `56_EG_12.json`, `56_LM_12.json`, `8453_EG_12.json`, `8453_LM_12.json` —
Ethereum, BSC and Base, EG and liquidity-mining tracks.

**Fee and rebate flow.**

- *Aggregator*: "KyberSwap does not charge fees to users who trade on KyberSwap.com or call directly
  from KyberSwap Aggregator API." Revenue is (a) **positive-slippage surplus** — "surplus of tokens
  above the estimated output amount (i.e. positive slippage)" accrues to KyberSwap, with the user
  protected only by the confirmed minimum; (b) a **dust collector** for unconsumed partial-fill
  amounts; (c) EG's 30% share.
- *Integrator*: `feeAmount`, `chargeFeeBy` (`currency_in` | `currency_out`), `isInBps`, `feeReceiver`
  — all **comma-separated lists**, i.e. **multiple fee recipients can be paid on one trade.**
- *Limit orders* (taker-paid, by token class): super stable 0.01%, stable 0.02%, normal 0.1%, exotic
  0.3%, high volatility 0.5%, super high volatility 1%, KNC 0.1% flat.
- *Zap/Earn*: 0.01% stable / 0.025% correlated / 0.1% common / 0.25% exotic, in input token;
  "Partners may add additional fees via API configuration."
- *Cross-chain*: EVM↔EVM 0.05–0.25%; Near/Solana↔EVM 0.1–0.2%; BTC↔EVM 0.25%; non-EVM↔non-EVM 0.25%.

**Address-conditioned pricing.** The `/routes` endpoint takes `origin` — the user wallet — documented
as being **"for exclusive pools/rates"**, and `/route/build` takes `origin` again "to avoid RFQ rate
limiting". Execution terms therefore depend on *who is asking*.

**Who owns the order flow, and how the right to fill is sold.** KyberSwap's answer is the exact
inverse of everyone else's in this lane: **it does not sell the right to fill — it buys the venue and
forbids anyone else from filling there.** KEM/FairFlow is exclusive routing made contractual: a hook
on someone else's AMM (Uniswap v4, PancakeSwap Infinity) that permits only KyberSwap's aggregator as
taker, so that the arbitrage which would ordinarily be won by a third-party searcher is captured
inside the pool and split 70/30 between the LPs who supplied the liquidity and Kyber who supplied
the exclusivity. LPs are paid to grant a monopsony. On the other side KyberSwap monetizes its own
flow through positive-slippage capture and lets integrators stack their own fees on top via
multi-recipient parameters — but its distinctive asset is the venue, not the user.

### 3. REPO

**The most open of the five, and the only one where the routing substance is in a repository.**

- **Organisation: `github.com/KyberNetwork`.** Key repositories, all inspected 2026-08-05:

| Repo | Language | License | Created | HEAD / pushed | Role |
|---|---|---|---|---|---|
| `kyberswap-dex-lib` | Go | **none (no LICENSE file)** | 2023-05-23 | `06c4a893` 2026-08-04 | the off-chain routing library; 129 `pkg/liquidity-source` packages |
| `ks-aggregation-router` | Solidity | **none** | 2025-08-04 | 2026-07-30 | `src/KSAggregationRouterV3.sol` |
| `smart-intent-sc` | Solidity | **GPL-3.0** | 2025-03-18 | 2026-07-29 | `KSSmartIntentRouter.sol`, `KSSmartIntentHasher.sol`, `…Accounting.sol`, `…Nonces.sol`, `…Storage.sol`, `hooks/`, `types/` |
| `kyber-exclusive-amm-sc` | Solidity | **MIT** | 2025-03-20 | 2026-07-30 | `UniswapV4KEMHook.sol`, `PancakeSwapInfinityKEMHook.sol`; `audits/` |
| `rfq-extension-sc` | Solidity | none | 2025-11-18 | 2026-07-14 | RFQ extension |
| `fairflow-reward` | Go | none | 2025-10-31 | 2026-07-31 | EG/LM reward cycles 13–51, chains 1/56/8453 |
| `ks-dex-adapter-lib` | Solidity | none | — | 2026-07-22 | on-chain encodings contributed by DEX teams |
| `kyberswap-interface` | TypeScript | **MIT** | 2021-03-01 | `6252cdb5` 2026-08-04, tag **v7.6.0** | front end |
| `kyberswap-documentation` | — | none | — | 2026-08-04 | docs source |
| `kyberswap-mcp`, `kyberswap-skills`, `elizaos-plugin-kyberswap` | TS/Shell | none | — | 2026-04/2026-05 | agent tooling |

- **License hazard for a later stage:** the two most important repositories — the routing library and
  the aggregation router — have **no LICENSE file at all**. Public visibility is not a grant. Only
  `kyber-exclusive-amm-sc` (MIT), `smart-intent-sc` (GPL-3.0) and `kyberswap-interface` (MIT) carry
  one.
- **Audits are in-repo:** `kyber-exclusive-amm-sc/audits/` holds
  `06_24_2025_KyberNetwork_Omniscia_SecurityReview_UniswapV4Hooks.pdf` and
  `Kyber-Hook-Uniswap-Foundation-Spearbit-Security-Review-October-2025.pdf`.
- **Do deployed contracts match the repo?** The docs' live router is `MetaAggregationRouterV2`
  (`0x6131B5fa…`), while the public repo contains `KSAggregationRouterV3`. **They are different
  versions**, so the public router repo does *not* correspond to what is deployed today. Recorded as
  a mismatch, not a match.
- **Verifiable:** the entire route-simulation logic (129 liquidity sources), the KEM hook logic, the
  intent router contracts, the reward cycles, the audits, the interface. **Not verifiable:** the
  route *search* on top of the simulators, the FairFlow quote signer's price, the exact composition
  of the "additional value" split between EG and taker competitiveness, and the PMM quote set.

### 4. EVIDENCE

| Claim | Source | Accessed |
|---|---|---|
| Aggregator over AMM DEXs, order-book DEXs, own limit orders, PMMs; PMM quotes off-chain, settled only if better; integrators may customise fees and fee token | https://docs.kyberswap.com/kyberswap-solutions/kyberswap-aggregator | 2026-08-05 |
| `/routes` params `feeAmount`/`chargeFeeBy`/`isInBps`/`feeReceiver` (comma-separated), `includedSources`/`excludedSources`, `excludeRFQSources`, `onlyScalableSources`/`onlyDirectPools`/`onlySinglePath`, `gasInclude`, **`origin` "for exclusive pools/rates"**, `x-client-id`; `/route/build` `slippageTolerance` 0–2000 bps, `ignoreCappedSlippage`, `deadline`, `permit`, `origin`; **positive slippage and dust accrue to KyberSwap** | https://docs.kyberswap.com/developer-guide/aggregator-api/aggregator-api-specification/evm-swaps.md | 2026-08-05 |
| `MetaAggregationRouterV2` `0x6131B5fae19EA4f9D964eAc0408E4408b66337b5`; `InputScalingHelperV2` `0x2f577A41BeC1BE1152AeEA12e73b7391d15f655D`; same address on all chains, 20+ networks incl. Robinhood | https://docs.kyberswap.com/developer-guide/aggregator-api/contracts.md | 2026-08-05 |
| Smart Settlement: on-chain per-hop pool re-selection; PropAMM spread-widening, same-block sandwich/front-run, JIT liquidity removal | https://docs.kyberswap.com/developer-guide/start-here/foundational-solutions/smart-settlement-better-swap-output-with-lower-slippage.md | 2026-08-05 |
| FairFlow: signed fair-market-price from the FF signer; EG definition; **70% EG Sharing / 30% platform**; "KyberSwap Aggregator is the only taker for FF pools"; weekly distribution in native tokens; no LP staking | https://docs.kyberswap.com/user-guide/kyberswap-fairflow/solution-fairflow.md | 2026-08-05 |
| FairFlow mechanics: off-chain "additional value" computation split between potential EG and taker competitiveness; hook validates signed fair price and absorbs surplus; **70% LP / 30% Kyber as hook owner**; 7-day cycles + 48-hour validation window; enrolled pools only | https://docs.kyberswap.com/user-guide/kyberswap-fairflow/fairflow-details.md | 2026-08-05 |
| KEM: "Restricts the swaps on the liquidity pools created with these hooks to only the Kyberswap DEX Aggregator"; EG absorption; Uniswap v4 + PancakeSwap Infinity hooks; hook flags; per-chain quote signer and EG recipient config | https://github.com/KyberNetwork/kyber-exclusive-amm-sc `README.md` | 2026-08-05 |
| Fee schedule: no aggregator fee to users; positive-slippage surplus collection; limit-order taker fees 0.01–1% by token class; Zap 0.01–0.25%; cross-chain 0.05–0.25% | https://docs.kyberswap.com/getting-started/fee-schedule.md | 2026-08-05 |
| 25 networks (23 EVM + NEAR, Bitcoin, Solana); "400+ DEXs"; **no KyberSwap Classic or Elastic** | https://docs.kyberswap.com/getting-started/supported-exchanges-and-networks.md | 2026-08-05 |
| Full product index (Swap, Limit Order, Cross-chain, Kyber Earn, Smart Exit, FairFlow, ZaaS, OnChain Price Service, KyberDAO, KNC) — **Classic and Elastic absent** | https://docs.kyberswap.com/llms.txt | 2026-08-05 |
| `kyberswap-dex-lib` purpose and contribution model; 129 `pkg/liquidity-source` packages | https://github.com/KyberNetwork/kyberswap-dex-lib `README.md` + GitHub API | 2026-08-05 |
| Repo inventory, licenses, HEADs, tags, audit PDFs, `KSAggregationRouterV3.sol`, `KSSmartIntentRouter.sol`, `fairflow-reward` cycle files | GitHub API over `orgs/KyberNetwork/repos` and `repos/KyberNetwork/*` | 2026-08-05 |
| Volume methodology: **self-reported** via `https://common-service.kyberswap.com/api/v1/aggregator/volume/daily?chainId=…`; per-chain start dates; Mantle and Etherlink marked `deadFrom: 2026-02-16`; Robinhood Chain (id 4663) added 2026-07-09 | https://github.com/DefiLlama/dimension-adapters/blob/master/aggregators/kyberswap/index.ts | 2026-08-05 |
| 24h/7d/30d volume; 24 chains; per-chain split; `change_1m` +129.6% | `https://api.llama.fi/overview/aggregators` (`defillamaId` 3982) | 2026-08-05 |

### 5. WHAT LOOKS UNNAMEABLE

1. **Exclusive routing — a venue that only one router may take from.** KEM hooks restrict swaps to
   the KyberSwap Aggregator. This is the single sharpest instance in the whole category of the axis
   the corpus says is missing, and it is *the opposite direction* from the one the corpus imagined:
   not "who owns the order", but "who is permitted to fill it, enforced in the pool's own code."
   `Aw` is a permission gate on a *user*; this gates the *taker* and does so to create an economic
   monopsony, not to satisfy a compliance rule.
2. **Signed off-chain reference price consumed by an on-chain hook as a settlement benchmark.** The
   FF quote signer is a trusted oracle-like role that exists only for one transaction and prices only
   one trade. `Ex` (external data oracle) and `At` (attestation) both miss it: this is a per-trade,
   per-route, aggregator-solicited signature.
3. **Surplus absorption above a benchmark, redistributed on a schedule.** EG is MEV captured *by the
   pool* rather than by a searcher, matured over a 7-day cycle with a 48-hour validation window, and
   split 70/30. `Fd` (candidate: surplus & fee distribution) is the closest and is still wrong —
   what is distributed is not fee revenue but foregone arbitrage.
4. **Positive-slippage capture as the protocol's actual revenue model** while advertising a zero fee.
   The user's minimum is honoured; everything above the *estimate* belongs to the router. Nothing in
   the vocabulary names the gap between "estimated output" and "minimum output" as an economic
   object, and it is where the money is.
5. **A dust collector** — unconsumed partial-fill amounts accruing to the router, explicitly framed
   as "execution artifacts, not fees."
6. **Re-deciding the venue on-chain at execution time.** Smart Settlement means the route in the
   calldata is a *proposal*. `Ag` presumes the route is the thing being executed.
7. **Address-conditioned execution terms** — `origin` "for exclusive pools/rates". Different wallets
   get different prices from the same endpoint. This is the graded segmentation that the corpus
   noted DFlow needs and `Aw` cannot express, and it is present at rank 5 as well.
8. **Multiple simultaneous fee recipients on one trade** (comma-separated `feeReceiver` /
   `feeAmount` / `chargeFeeBy`). The order-flow rent is divisible among a chain of intermediaries.
9. **A routing library that third parties contribute to by pull request.** The set of venues is
   maintained as an open-source commons by the venues themselves — a governance and supply
   arrangement with no symbol.
10. **Fee schedules keyed to a token-volatility classification** (super stable → super high
    volatility, six bands). The mechanism prices its own service by the riskiness of the asset.

**Verdict on the corpus's `{Ag}` ≡ `{Ag}` claim (KyberSwap vs LiquidMesh): they are NOT alike, and
the identity is an artefact of the vocabulary, not of the world.** KyberSwap owns venues and forbids
outsiders from filling in them, buys LP consent with 70% of the captured arbitrage, publishes its
route simulators, charges its users nothing and earns from positive slippage. LiquidMesh owns no
venue, owns no user, publishes nothing, charges its users nothing, hands the fee lever to whoever
owns the user, and earns from selling latency and from backrunning its own flow. The only thing they
share is that both construct multi-venue routes. `Ag` names that and stops, which is precisely the
corpus's thesis — but the corpus asserted the thesis about *who owns the order*, and the sharpest
counterexample turns out to be about *who owns the venue*.

### 6. DELTA

- **`{Ag}` is badly stale.** Since the corpus was written KyberSwap has shipped **FairFlow/KEM**
  (exclusive Uniswap-v4 and PancakeSwap-Infinity hooks with a signed reference price and 70/30 EG
  split; hook repo created 2025-03-20, two audits June and October 2025, `fairflow-reward` cycles up
  to 51), **`smart-intent-sc`** (GPL-3.0, `KSSmartIntentRouter`, created 2025-03-18), an
  **`rfq-extension-sc`** (created 2025-11-18), **Smart Exit** (intent-based liquidity withdrawal),
  **cross-chain swap** over 23 chains, and **ZaaS**. A single-symbol decomposition is no longer
  defensible.
- **The corpus residue "the aggregator's own pools being one of the routed venues (KyberSwap Classic
  and Elastic are separate protocols in the same brand)" is factually stale.** **Neither Classic nor
  Elastic appears anywhere in the current documentation** — not in `llms.txt`, not in the supported
  networks page, not in the product list. The correct modern statement is far stronger: KyberSwap's
  own venues are now *hooks on other people's AMMs* that only KyberSwap may trade with.
- **The corpus residue "No element for gas-aware route optimization" is confirmed** and has a name in
  the API: `gasInclude` / `gasPrice` on `/routes` and `enableGasEstimation` on `/route/build`.
- **KyberSwap's volume is self-reported.** The DefiLlama adapter calls
  `common-service.kyberswap.com` with an `origin` header spoofed to KyberSwap's own domain. Like
  OKX, this is a vendor-attested figure. The corpus does not distinguish it from the Dune-measured
  protocols it is ranked against.
- **Figures moved.** Corpus: $206.22m / $1.333b / $5.367b, 24 chains. Live: **$206,215,096
  (identical, `change_1d = 0`) / $1,093,021,082 / $5,277,287,271**, 24 chains. `change_1m` is
  **+129.6%** — KyberSwap more than doubled month-on-month, which the corpus does not note. Note also
  the concentration: Ethereum $88.9m and Base $77.7m are 81% of the total; BSC is only $10.2m.
- **DefiLlama display name is "KyberSwap Aggregator"** under `parent#kyberswap`.
- **Documentation lists 25 networks and "400+ DEXs"** against DefiLlama's 24 chains; the adapter
  marks Mantle and Etherlink `deadFrom: 2026-02-16` and added Robinhood Chain on 2026-07-09.

---

## Cross-cutting findings for stage 2

1. **The corpus's two identity claims both fail.** `LiquidMesh ≡ KyberSwap` and
   `Binance Wallet ≡ OKX DEX` are artefacts of a vocabulary that names route construction and
   nothing else. In each pair the two systems occupy *opposite* positions in the order-flow market:
   one owns the demand or the venue, the other sells the engine to whoever does.
2. **The corpus's diagnosis is right but aimed one axis short.** It says the vocabulary has no name
   for *who owns the order*. True. It also has no name for **who owns the venue and may forbid
   others from filling there** (KyberSwap KEM), **who owns the path to inclusion** (Jupiter Beam,
   LiquidMesh Boost, BNB Chain private RPC), or **who owns the default button** (OKX's disclosed UI
   emphasis). Four ownership axes, zero symbols.
3. **The category is not flat — it is nested.** Jupiter's meta-aggregator competes Metis/Iris,
   JupiterZ, **DFlow, OKX and Hashflow**. Two members of the corpus's own top-8 are components of a
   third. Any construction that treats these as independent rows will double-count and will
   mis-attribute.
4. **The engine is a binary, twice.** `okx/dex-solana-binary` (Pallas) and `jup-ag/metis-binary`
   both ship the routing engine as a Docker image with no source and no license. Two of the five
   have converged on the same answer to "how do you distribute a router without publishing it."
5. **Measurement heterogeneity must be carried into the paper.** LiquidMesh, Binance Wallet and
   Jupiter are measured on-chain via Dune against named contracts/programs. **OKX and KyberSwap
   self-report through their own authenticated APIs.** No figure in this category should enter
   `atlas.tex` without that distinction attached.
6. **The four commercial primitives that recur across all five, none of which the vocabulary names:**
   an integrator commission parameter (LiquidMesh `commissionRate`; OKX `feePercent` + on-chain
   `CommissionLib`; Jupiter `referralFee` with a 20% cut to Jupiter; KyberSwap `feeReceiver` lists);
   private/protected broadcast (all five, by four different mechanisms); address- or
   identity-conditioned pricing (KyberSwap `origin`, LiquidMesh `userAddress` screening, OKX/
   LiquidMesh IP screening); and surplus capture above the quote (KyberSwap positive slippage,
   KyberSwap EG, LiquidMesh backrun rebate, Jupiter's +0.63 bps claim).
