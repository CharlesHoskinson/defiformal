# Stage 1 research — Spot DEX / AMM (category `01-spot-exchange`)

Lane: Uniswap · PancakeSwap · Curve · Raydium · Fluid. All access dates below are
**2026-08-04** unless stated otherwise.

**Source quality for this category.** This is the best-documented category in DeFi and
almost everything load-bearing is verifiable at a primary source. Four of the five ship
their core contracts on GitHub under a named licence (Uniswap BUSL-1.1/MIT, PancakeSwap
GPL-2.0, Curve MIT/Apache-ish per repo, Fluid BUSL-1.1); Raydium's programs are Rust/Anchor
on GitHub. Where a docs site blocked plain fetching (`developer.pancakeswap.finance`
returns 403 to a bare client) the pages were retrieved with `scrapling`; where a docs
site publishes an `llms.txt` / `.md` mirror (`developers.uniswap.org`,
`fluid.guides.instadapp.io`) the markdown mirror was used and is quoted directly.
Repository facts (licence, language, tag, HEAD sha, tree) were read from the GitHub REST
API rather than from rendered pages, because the rendered pages routinely omit or stale
the tag. Three systematic weaknesses remain and are flagged inline: (a) *docs lag code* —
Uniswap's protocol-fee docs and PancakeSwap's fee tables are both behind their own
repositories, and Fluid's user docs still describe DEX v1 while DEX v2 is deployed;
(b) *deployment↔repo correspondence is asserted, not proved*, for every protocol here
except where an explorer-verified address is given, so it is recorded as such rather than
as fact; (c) *the aggregator ranking is a snapshot* — the DefiLlama figures in the corpus
were re-derived live today and reproduce, but they are a same-day number, not a stable
one.

---

## Uniswap

### 1. WHAT IT DOES

A user brings two ERC-20 tokens (or native ETH, in v4) and deposits them into a pool
identified by the ordered token pair plus a fee parameter; in return they receive a claim
on that pool's inventory. In v2 the claim is a fungible ERC-20 LP token representing a
pro-rata share of the whole reserve; in v3 and v4 the claim is a *position* bounded by a
lower and upper tick, non-fungible, carrying its own fee-growth checkpoint, so two LPs in
the same pool with different ranges hold economically different instruments. A swapper
sends one token in and receives the other out; the price is not quoted by a counterparty
but is read off the pool's invariant — `x·y=k` in v2, and the same constant-product curve
applied to *virtual* reserves within the active tick range in v3/v4 — so the marginal price
moves monotonically against the swapper as size grows, and the LP fee is skimmed from the
input. Settlement is atomic and in-transaction: v2 and v3 transfer tokens at each pool,
whereas v4 records signed *deltas* in transient storage across an unlocked scope and
transfers only the net at the end. A position ends when the owner burns it and collects
principal plus accrued fees; there is no maturity, no margin call and no liquidation, because
no one is ever short. Since December 2025 a protocol fee is skimmed from the LP fee on v2,
v3 and v4 and accumulates in a per-chain `TokenJar`; the only way to get it out is to pay a
fixed quantity of UNI to a `Firepit`, which burns the UNI — so the protocol's value-return
channel is a supply destruction triggered by an arbitrageur, not a distribution.

### 2. DESIGN

**v2.** `UniswapV2Factory` holds `feeTo`, `feeToSetter` and the pair registry; it
CREATE2-deploys `UniswapV2Pair` per token pair with a deterministic salt
(`keccak256(token0, token1)`). Each pair holds `reserve0`, `reserve1`,
`blockTimestampLast`, `price0CumulativeLast`, `price1CumulativeLast`, `kLast`. The
invariant asserted is that `k` is non-decreasing across a swap after fees. The oracle is an
*accumulator*, not a price: the pair stores "a sum of the Uniswap price for every second in
the entire history of the contract", and a consumer must read it at two times, difference,
and divide by elapsed time to get a TWAP. Flash swaps are native: the pair optimistically
transfers out and calls back before checking `k`. Protocol fee is minted as LP tokens to
`feeTo`, fixed at `1/6` of the swap fee (0.05% of the 0.30%).

**v3.** `UniswapV3Factory` holds `owner`, `feeAmountTickSpacing` (the fee-tier registry,
seeded 500/3000/10000 with tick spacings 10/60/200) and `getPool`. Pool parameters are
immutable in the pool; the pool is not upgradeable and there is no proxy. But the factory
owner is *not* powerless: it can call `setOwner`, `enableFeeAmount` (add a fee tier — tiers
cannot be removed) and, through the pool, `setFeeProtocol`. State per pool: `slot0`
(`sqrtPriceX96`, `tick`, observation cursor, `feeProtocol`, `unlocked`), `liquidity`,
`feeGrowthGlobal0X128/1X128`, `protocolFees`, `ticks`, `tickBitmap`, `positions`,
`observations` (the ring buffer backing the built-in oracle). Positions are wrapped by the
periphery `NonfungiblePositionManager` into ERC-721s.

**v4.** One singleton, `PoolManager.sol`, inherits `ProtocolFees`, `NoDelegateCall`,
`ERC6909Claims`, `Extsload`, `Exttload`. Creating a pool is a state write, not a
deployment. The external surface is `unlock` → integrator's `unlockCallback` → any of
`swap`, `modifyLiquidity`, `donate`, `take`, `settle`, `settleFor`, `clear`, `mint`,
`burn`, `sync`, `updateDynamicLPFee`; all except `initialize` carry `onlyWhenUnlocked`.
The asserted invariant, in the repo's own words: "Any number of actions can be run on the
pools, as long as the deltas accumulated during the unlock reach 0 by the unlock's
release." Deltas live in EIP-1153 transient storage. `PoolKey` is
`(currency0, currency1, fee, tickSpacing, hooks)`.

*Hooks.* A pool may name a hook contract at initialization. `Hooks.sol` encodes **fourteen**
permission bits in the low bits of the hook's address (`ALL_HOOK_MASK = (1<<14)-1`):
`BEFORE_INITIALIZE (1<<13)`, `AFTER_INITIALIZE (1<<12)`, `BEFORE_ADD_LIQUIDITY (1<<11)`,
`AFTER_ADD_LIQUIDITY (1<<10)`, `BEFORE_REMOVE_LIQUIDITY (1<<9)`,
`AFTER_REMOVE_LIQUIDITY (1<<8)`, `BEFORE_SWAP (1<<7)`, `AFTER_SWAP (1<<6)`,
`BEFORE_DONATE (1<<5)`, `AFTER_DONATE (1<<4)`, `BEFORE_SWAP_RETURNS_DELTA (1<<3)`,
`AFTER_SWAP_RETURNS_DELTA (1<<2)`, `AFTER_ADD_LIQUIDITY_RETURNS_DELTA (1<<1)`,
`AFTER_REMOVE_LIQUIDITY_RETURNS_DELTA (1<<0)`. The permission set is therefore chosen by
address mining, and the README states the binding invariant: "*which* callbacks are executed
on a pool cannot change after pool initialization." The four `RETURNS_DELTA` bits are the
sharp ones: they let a hook alter the accounting outcome of the operation, i.e. supply a
custom curve, not merely observe.

*Price sources.* v2 and v3 expose cumulative-price observations from which a consumer
computes a TWAP. v4 ships **no** built-in oracle; a TWAP is a hook.

*Failure / liquidation path.* None. There is no debt, so no liquidation. The only
adversarial paths are LP impermanent loss, hook misbehaviour (Uniswap ships
`docs/security/Known_Effects_of_Hook_Permissions.pdf` precisely because a hook is
untrusted code in the settlement path), and oracle manipulation for downstream consumers.

*Control plane.* UNI `0x1f9840a85d5aF5bf1D1762F925BDADdC4201F984`; GovernorBravo
`0x408ED6354d4973f66138C91495F2f2FCbd8724C3`; Timelock
`0x1a9C8182C09F50C8318d769245beA52c32BE35BC`. Parameters: 1M UNI proposal threshold,
2-day voting delay, 7-day voting period, 40M UNI quorum, 2-day timelock. Reach: the
Timelock is v2's `feeToSetter`, is (via the fee adapter) v3's factory `owner`, and is
`Owned.owner` on v4's `PoolManager` — where its single power is `setProtocolFeeController`.
There is **no pause** anywhere in v4-core: grepping `PoolManager.sol` and `ProtocolFees.sol`
at tag `v4.0.0` finds no occurrence of "pause".

*Value return (UNIfication).* Proposal executed 2025-12-28 17:55 with 125,342,017 FOR /
742 AGAINST, in eight on-chain actions including burning 100M UNI, handing v3 factory
ownership to the fee controller, setting v2 `feeToSetter` to the Timelock and `feeTo` on,
approving 40M UNI into `UNIVester`, and anchoring three legal agreements via
`AgreementAnchor`. The resulting machine is three layers, per `Uniswap/protocol-fees`:
(i) **TokenJar** — "an immutable smart contract that serves as the collection point for all
fees on that chain", exposing exactly one role, the `releaser`, which "can atomically
transfer the full balance of specified assets to a recipient"; (ii) **fee sources /
adapters** — push for v2 (LP tokens minted straight to the Jar, 1/6 of swap fees), pull for
v3 (`V3FeeAdapter` owns factory privileges, permissionless collection) and v4
(`V4FeeAdapter` registered as the PoolManager's `protocolFeeController`, with fee resolution
delegated to a *replaceable* `V4FeePolicy` so governance can change fee strategy without
re-handing PoolManager privileges); (iii) **releasers** — `Firepit` on mainnet, where a
searcher pays a fixed UNI amount, the Jar's contents are released to the searcher's
recipient, and the UNI goes to `0xdead`. On OP-Stack L2s `OptimismBridgedResourceFirepit`
runs a two-stage burn: pay bridged UNI on L2 (threshold 2000 UNI), release, then a bridge
withdrawal that after the 7-day challenge period sends L1 UNI to `0xdead`. Mainnet
addresses: TokenJar `0xf38521f130fcCF29dB1961597bc5d2B60F995f85`, Firepit
`0x0D5Cd355e2aBEB8fb1552F56c965B867346d6721`, V3FeeAdapter
`0x5E74C9f42EEd283bFf3744fBD1889d398d40867d`, V4FeeAdapter
`0x89A5D5bF00a27D55c02951E49078a5C5771051dB`, V4FeePolicy
`0x1cd822b70a0591420F65E94b9B3A0D0b0fB3a314`, UNIVesting
`0xCa046A83EDB78F74aE338bb5A291bF6FdAc9e1D2`.

The `V4FeePolicy` resolution rule is itself a small language: the adapter checks a per-pool
override, else calls `policy.computeFee(key)`, which resolves a *family* — `hookFamilyId[hook]`,
else static pool → 255 ("native math"), else `protocolFeeFlags` + `flagRules`, else 0
(unclassified) — and applies `pairClassFees[pair][family]` → `familyDefaults[family]` →
`defaultFee`. Native-math pools get a piecewise-linear bucket schedule
`alpha + beta × (lpFee − floor)/1_000_000`, max 16 buckets. Two roles: `owner` (swap the
policy, set the fee-setter) and `feeSetter` (everything else).

### 3. REPO

| Repo | URL | Ref inspected | Licence | Language |
|---|---|---|---|---|
| v4-core | https://github.com/Uniswap/v4-core | tag **`v4.0.0`** = `e50237c43811bd9b526eff40f26772152a42daba` (published 2025-01-23) | dual BUSL-1.1 / MIT, per-file header; `licenses/BUSL_LICENSE` + `licenses/MIT_LICENSE` | Solidity |
| v4-periphery | https://github.com/Uniswap/v4-periphery | `main` (no tags) | MIT | Solidity |
| v3-core | https://github.com/Uniswap/v3-core | `main` | `NOASSERTION` per API; source headers are `BUSL-1.1` | Solidity (repo language reported TypeScript) |
| v3-periphery | https://github.com/Uniswap/v3-periphery | `main` | GPL-2.0 | Solidity |
| v2-core | https://github.com/Uniswap/v2-core | `master` | GPL-3.0 | Solidity |
| protocol-fees | https://github.com/Uniswap/protocol-fees | `main` HEAD `0c071d199dc32556365c78e03ec3f4d09b9fbf37` (2026-07-23); tags `v0.1.0`, `unification-proposal` (`8604e4b9…`), `audit-fix-review` (`31aa2a0b…`) | **AGPL-3.0-only** (stated in README) | Solidity |

`v4-core` top level at `v4.0.0`: `.github/ docs/ lib/ licenses/ snapshots/ src/ test/` plus
`foundry.toml`, `echidna.config.yml`, `justfile`, `remappings.txt`. `src/` =
`PoolManager.sol ProtocolFees.sol ERC6909.sol ERC6909Claims.sol Extsload.sol Exttload.sol
NoDelegateCall.sol interfaces/ libraries/ types/ test/`. `docs/` holds `whitepaper/` and
`security/`, the latter containing `Known_Effects_of_Hook_Permissions.pdf` and
`audits/{OpenZeppelin,TrailOfBits,DRAFT_ABDK,DRAFT_Certora,DRAFT_Spearbit}_audit_core.pdf`.

`protocol-fees` top level: `src/ script/{deployers,proposal-1..4} audit/ docs/ merkle-generator/
proposals/unification.md .records/ lib/ test/`. `src/` = `TokenJar.sol UNIVesting.sol
CrossChainAccount.sol base/{Nonce,ResourceManager}.sol
feeAdapters/{V3FeeAdapter,V3OpenFeeAdapter,V4FeeAdapter,V4FeePolicy}.sol
releasers/{Firepit,ExchangeReleaser,OptimismBridgedResourceFirepit,
ArbitrumBridgedResourceFirepit,ArbitrumOrbitResourceFirepit,WormholeReleaser}.sol
wormhole/SyntheticNttUni.sol libraries/ArrayLib.sol interfaces/`. Audits are committed as
PDFs in `audit/` (Cantina, seven OpenZeppelin reports); the README names OpenZeppelin and
Spearbit.

**Deployed↔repo correspondence.** For `protocol-fees` the README publishes explorer links
per chain (13 chains including Ethereum, Unichain, Arbitrum, Base, OP, Polygon, BNB, Celo,
Zora, Soneium, World Chain, X Layer, **Robinhood Chain** id 4663), so the addresses are
attributable to the repo by the maintainer's own statement; independent bytecode
verification was **not** performed by this lane → treat as *stated by the docs*, not proved.
For v2/v3/v4 core, correspondence is likewise asserted by the docs and is **UNKNOWN** as a
verified fact from this lane.

### 4. EVIDENCE

1. https://github.com/Uniswap/v4-core — repo, licences, tree (via GitHub REST API), 2026-08-04.
2. https://api.github.com/repos/Uniswap/v4-core/releases/latest — tag `v4.0.0`, published 2025-01-23, 2026-08-04.
3. https://raw.githubusercontent.com/Uniswap/v4-core/v4.0.0/src/libraries/Hooks.sol — the 14 permission flags and the address-encoding comment: "V4 decides whether to invoke specific hooks by inspecting the least significant bits of the address that the hooks contract is deployed to", 2026-08-04.
4. https://github.com/Uniswap/v4-core/blob/v4.0.0/README.md — architecture, delta-zero invariant, "*which* callbacks are executed on a pool cannot change after pool initialization", 2026-08-04.
5. https://raw.githubusercontent.com/Uniswap/v4-core/v4.0.0/src/PoolManager.sol and `src/ProtocolFees.sol` — function surface; `ProtocolFees is IProtocolFees, Owned`; no `pause`, 2026-08-04.
6. https://developers.uniswap.org/llms.mdx/docs/protocols/v4/concepts/flash-accounting — unlock/settle, transient storage, "all deltas must resolve to zero", 2026-08-04.
7. https://developers.uniswap.org/llms.mdx/docs/protocols/v4/concepts/hooks — the ten lifecycle callbacks; "encoded in the address of the contract", 2026-08-04.
8. https://developers.uniswap.org/llms.mdx/docs/protocols/v2/concepts/oracles — "a sum of the Uniswap price for every second in the entire history of the contract"; consumer computes the TWAP, 2026-08-04.
9. https://raw.githubusercontent.com/Uniswap/v3-core/main/contracts/UniswapV3Factory.sol — `owner`, `feeAmountTickSpacing`, `setOwner`, `enableFeeAmount`, seeded tiers 500/3000/10000, 2026-08-04.
10. https://raw.githubusercontent.com/Uniswap/v2-core/master/contracts/UniswapV2Factory.sol — `feeTo`, `feeToSetter`, CREATE2 salt, 2026-08-04.
11. https://blog.uniswap.org/unification — TokenJar/Firepit, 100M UNI retroactive burn, v2 LP 0.30%→0.25% with 0.05% protocol fee, v3 protocol fee 1/4 or 1/6 of LP fee, Unichain sequencer revenue, PFDA, 20M UNI/yr growth budget, 2026-08-04.
12. https://vote.uniswapfoundation.org/proposals/93 — FOR 125,342,017 / AGAINST 742; executed 2025-12-28 17:55; the eight on-chain actions, 2026-08-04.
13. https://github.com/Uniswap/protocol-fees (README, via GitHub REST API) — TokenJar/adapter/releaser architecture, V4FeePolicy resolution waterfall, OP-Stack two-stage burn with THRESHOLD 2000 UNI and `L1_RESOURCE_RECIPIENT 0xdead`, deployed addresses per chain, AGPL-3.0-only, 2026-08-04.
14. https://developers.uniswap.org/llms.mdx/docs/protocols/protocol-fee/overview and `/concepts/fees` — Firepit threshold mechanism; v2 fee "fixed in pair contracts at `1/6` of the swap fee (`0.05%` of the `0.30%` total)"; v3 tier rates 0.0025%–0.1666%, 2026-08-04.
15. https://developers.uniswap.org/llms.mdx/docs/ecosystem/governance/technical-reference and `/governance-process` — UNI/GovernorBravo/Timelock addresses; 1M threshold, 2d delay, 7d vote, 40M quorum, 2d timelock, 2026-08-04.
16. https://api.llama.fi/protocols (filtered locally to `category == "Dexs"`, aggregated by `parentProtocol`) — Uniswap $3,052.4M (V3 1447.1 / V4 825.4 / V2 776.8 / V1 3.1), rank 1, 2026-08-04.

### 5. WHAT LOOKS UNNAMEABLE

- **The hook, as a typed permission set fixed at pool creation.** Not merely "third-party
  code runs in the settlement path", but: a 14-bit capability vector, chosen by mining the
  hook's address, frozen at initialization, of which four bits (`*_RETURNS_DELTA`) convert
  the hook from observer to *pricer*. A vocabulary that names hooks at all will still miss
  the distinction between an observing hook and a delta-returning hook, and that distinction
  is exactly the boundary between "v4 pool" and "arbitrary AMM wearing a v4 costume".
- **Deferred net settlement over an unlocked scope.** `Fl` names borrow-and-repay in one
  scope. Flash accounting is not a loan: nothing is borrowed, a signed ledger is kept in
  transient storage and only the net moves. The invariant "the delta vector is zero at
  release" is a *conservation law over a transaction*, and it is what makes the singleton
  safe; no symbol states a conservation law.
- **Fee-tier / pool-parameter registry as a permission on which curves may exist.**
  `enableFeeAmount` is monotone — a tier can be added, never removed — so the registry is a
  ratchet on the space of admissible pools.
- **Supply destruction as the value-return channel, and specifically the *shape* of it.**
  This is worse than the corpus records. It is not a buyback. It is a standing, immutable,
  fixed-price *call option on the fee inventory*, written by the protocol, exercisable by
  anyone, whose premium is paid in the governance token and then destroyed. Three separable
  things need naming: the sink (an immutable jar with exactly one privileged role), the
  exercise (fixed-quantity resource-for-inventory swap), and the destruction.
- **Non-fungible per-range position accounting with its own fee-growth checkpoint.**
  `Cl` names the curve shape; `Sh` names a pro-rata pool claim; neither names an individually
  owned position that accrues against a global index snapshotted at open.
- **A cross-domain value sink with an asynchronous two-stage settlement.** The L2 Firepit
  burns bridged UNI locally *and* queues an L1 message whose effect lands 7 days later. `Xf`
  names asset transfer; nothing names "the economic act completes on another domain after a
  challenge window".
- **A replaceable policy object behind a non-replaceable adapter.** `V4FeeAdapter` holds the
  PoolManager privilege permanently; `V4FeePolicy` is swappable by an owner. That is neither
  `Up` (no proxy, no delegatecall) nor `Tg` (the swap is not the delay); it is a deliberate
  split of *privilege* from *policy*.

### 6. DELTA vs the corpus record

- **Rank basis reproduces.** Re-derived live today from `api.llama.fi/protocols`, aggregating
  category `Dexs` by `parentProtocol`: Uniswap $3,052.4M (corpus $3,058.0M). Component drift
  only (V4 825.4 vs 821.9; V2 776.8 vs 784.1). No correction needed. The corpus's rank-7
  Aerodrome figure ($247.5M) also reproduces at $247.8M.
- **The corpus's `Fd` marker under-describes the mechanism.** It says UNIfication "routes
  protocol fees into a UNI buy-and-burn". No buying happens on-protocol. `Firepit.release()`
  takes a *fixed* quantity of UNI from a searcher and hands over the Jar's full balance of
  the named assets; the searcher does the buying, off-protocol, and only if it is profitable.
  The protocol never holds a market order. This matters for decomposition: the symbol needed
  is closer to a fixed-price redemption/auction than to any distribution. (Ev. 13.)
- **`Tg` marker: "the core pool contracts are immutable … the mechanism is beyond authority"
  is too strong.** The v3 factory `owner` can `enableFeeAmount` (mint new admissible curves)
  and set the per-pool protocol-fee fraction; the v2 factory `feeToSetter` can switch the
  protocol fee on and redirect it — and both were exercised on 2025-12-28. v4's `PoolManager`
  is `Owned` and the owner sets the `protocolFeeController`. Immutability holds for *code*,
  not for *parameters*. The accurate statement is: no upgrade path, no pause, but a live
  owner-gated parameter surface. (Ev. 5, 9, 10, 12.)
- **v4 protocol fees are now live, not pending.** `V4FeeAdapter` and `V4FeePolicy` are deployed
  on Ethereum, Arbitrum, OP, Base, Polygon, BNB, Celo and Robinhood Chain, and the adapter is
  registered as the PoolManager's `protocolFeeController`. The corpus's residue list and the
  `Fd` note both read as though only v2/v3 were switched on. (Ev. 13.)
- **New residue the corpus does not carry:** the `V4FeePolicy` *family classifier* — a
  governance-maintained map from hook address to a fee family, with a piecewise-linear bucket
  schedule for unhooked pools. That is a taxonomy of third-party code maintained on-chain by
  governance, and nothing in the vocabulary is close.
- **Chain surface is wider than the corpus implies**, including a Robinhood-operated chain
  (id 4663) and a Wormhole NTT path for non-OP chains. Not an error in the corpus, but the
  "Uniswap = Ethereum + L2s" reading is now wrong. (Ev. 13.)
- The 100M UNI burn date in the corpus (2025-12-28) is **confirmed** by the execution record.
  (Ev. 12.)

---

## PancakeSwap

### 1. WHAT IT DOES

Functionally PancakeSwap is Uniswap's product line re-implemented on BNB Chain and then
multi-chain, with an emission and a burn bolted on. A user deposits a token pair into a v2
pair (fungible LP token, `x·y=k`), a v3 pool (tick-bounded NFT position), a StableSwap pool,
or — since March 2025 — an Infinity pool, which is either a CLAMM pool (concentrated
liquidity, NFT position, constant product) or an LBAMM/"Liquidity Book" pool (discrete price
bins, constant sum *within* a bin, and the per-bin claim is a fungible ERC-20). Pricing and
settlement are the same story as Uniswap: the invariant quotes the marginal price, the LP fee
is skimmed from the input, settlement is atomic, and there is no liquidation because there is
no debt. The two divergences from Uniswap are on the incentive and control planes. First,
LPs can stake positions into farms and receive CAKE emissions on a governance-set allocation.
Second, the swap fee is split three ways at the protocol level — LPs, treasury, and a CAKE
burn — so the burn is a *first-class term in the fee split*, not a downstream act. Positions
end by burning the LP token or NFT and collecting principal plus fees. Since 23 April 2025
there is no vote-escrow layer and no revenue share: veCAKE, gauge voting, farm boosting and
the 5% revenue share were all retired, and the revenue-share allocation was redirected into
the burn.

### 2. DESIGN

**v2.** A Uniswap-v2 fork. Total swap fee 0.25%, of which "0.17% is added back to the
Liquidity Pool" per the docs; the remaining 0.08% is documented on the docs' own liquidity
page only as non-LP. The commonly cited 0.03% treasury / 0.05% CAKE-buyback split is
**UNKNOWN** at a primary source from this lane — the current docs page states the 0.25%/0.17%
figures and does not state the residual split.

**v3.** A Uniswap-v3 fork: `PancakeV3Factory` `0x0BFbCF9fa4f9C56B0F40a671Ad40E0805A091865`
(BSC/ETH/ARB/Linea/Base/opBNB/Monad/Robinhood), `PancakeV3PoolDeployer`
`0x41ff9AA7e16B8B1a8a8dc4f0eFacd93D02d071c9`, `NonfungiblePositionManager`
`0x46A15B0b27311cedF172AB29E4f4766fbE7F4364`, `SwapRouter`
`0x1b81D678ffb9C0263b24A97847620C99d213eB14`, `SmartRouter`
`0x13f4EA83D0bd40E75C8222255bc855a974568Dd4` ("Able to route to v3, v2 and stable pool"),
`MasterChefV3` `0x556B9306565093C855AEA9AE92A594704c2Cd59e`. Fee split is per tier and is
*documented as a three-way percentage of the fee*, which is the structural difference from
Uniswap: 0.01% tier → LP 67 / burn 15 / treasury 18; 0.05% → 66 / 15 / 19; 0.25% →
68 / 23 / 9; 1% → 68 / 23 / 9. On Solana the split is uniform: LP 84 / burn 8 / treasury 8.

**Infinity** (audited and deployed on BNB mainnet, March 2025). Three tiers, and the
separation is the headline: "PancakeSwap Infinity, recognizing the need for adaptability and
scalability, separates Accounting logic from AMM logic, implements a three-tiered modular
architecture … that consists of the Vault, Pool Managers, and Hooks."
  - **Vault** (`src/Vault.sol`) — "an immutable accounting layer". Lock discipline:
    `vault.lock()` → `lockAcquired(data)` → operate on a pool manager → the manager calls
    `vault.accountAppBalanceDelta(...)` → reconcile via `take() / settle() / mint() / burn()`
    (plus `clear()` for dust and the three-step `sync → transfer → settle`). Unsettled deltas
    are counted in transient storage by `SettlementGuard` (`UNSETTLED_DELTAS_COUNT`,
    `CURRENCY_DELTA`).
  - **Pool managers** — `src/pool-cl/CLPoolManager.sol` and `src/pool-bin/BinPoolManager.sol`,
    each an independent singleton. `initialize(PoolKey, uint160 sqrtPriceX96)` for CL,
    `initialize(PoolKey, uint24 activeId)` for Bin.
  - **PoolKey** = `(currency0, currency1, IHooks hooks, IPoolManager poolManager, uint24 fee,
    bytes32 parameters)`. `PoolId = keccak256(abi.encode(poolKey))`. **Hook permissions live
    in `parameters`, not in the hook address**: first 16 bits are the hook registration
    bitmap, the next field is tick spacing (CL) or bin step (Bin). The docs give a worked
    example — parameters `0x…0a00c2` decodes to permission bits `0000 0000 1100 0010`
    (afterInitialize, beforeSwap, afterSwap) and tick spacing 10.
  - Other core files: `ProtocolFees.sol`, `ProtocolFeeController.sol`, `Owner.sol`,
    `VaultToken.sol`, `Extsload.sol`, and per-manager `CLPoolManagerOwner.sol` /
    `BinPoolManagerOwner.sol`.

*Price sources.* No protocol-level oracle in Infinity; a custom oracle is an advertised hook
use case. v3 inherits Uniswap v3's observation ring buffer. Not independently verified here.

*Failure path.* None — spot only. Hook risk is explicitly acknowledged (CertiK published
"PancakeSwap Infinity: Hooks Security Considerations").

*Control plane — this is where PancakeSwap genuinely differs from Uniswap.*
`CLPoolManagerOwner is IPoolManagerOwner, PoolManagerOwnable2Step, PausableRole` and exposes
`pausePoolManager() onlyPausableRoleOrOwner`, `unpausePoolManager() onlyOwner`,
`setProtocolFeeController(...) onlyOwner`, plus 2-step ownership transfer. So a live pause
authority sits over the AMM layer, delegated to a role narrower than the owner.
`ProtocolFeeController is Ownable2Step` with `protocolFeeSplitRatio = 33 * 1e4` (i.e. 33% of
the total fee, in hundredths of a bip), `defaultProtocolFeeForDynamicFeePool = 300`, a stated
cap that the dynamic-pool default is invalid "if greater than 0.4%", and owner-only
`setProtocolFeeSplitRatio`, `setDefaultProtocolFeeForDynamicFeePool`, `setProtocolFee(key, …)`
per pool, and `collectProtocolFee`. The Vault is stated to be immutable; the pool managers
are not upgradeable but *are* pausable and their fee policy is owner-mutable.
The identity of the owner/pauser (multisig? timelock? delay?) is **UNKNOWN** from primary
sources reached by this lane.

*Emissions and burn.* CAKE has "a hard cap set at 400M", lowered from 450M by a proposal that
passed 2026-01-16, with a stated target of "an annual deflation rate of at least ~4% per year
and a total CAKE supply reduction of ~20% by 2030". Burn sources, per the tokenomics page:
spot trading 15–23% of trading fees; perpetual trading 20% of all profits; CAKE.PADs 100% of
fees; Prediction 3% of each round; Lottery 20% of CAKE played. Emissions are directed to
"multichain farms, lottery, and ecosystem growth"; the docs do not name the authority that
sets the allocation, only "the Chefs" — **UNKNOWN**.

*veCAKE sunset.* Retired from 2025-04-23 (final gauge vote = Epoch 37); Epoch 38 executed
2025-04-25→05-06; gauge reward accrual and the 5% revenue share both ended 2025-05-07; a
6-month redemption window for directly staked CAKE closed 2025-10-23; third-party locker
protocols were handled by whitelisting delegator addresses for 1:1 redemption. The freed
revenue-share allocation was "redirected to the CAKE burn mechanism, increasing the burn rate
for these pools from 10% to 15%."

### 3. REPO

| Repo | URL | Ref inspected | Licence | Language |
|---|---|---|---|---|
| infinity-core | https://github.com/pancakeswap/infinity-core | `main` HEAD `7c04695faeab8b06570cf6c277d9a9717136fb26` (2025-06-30); **no tags** | GPL-2.0 | Solidity |
| infinity-periphery | https://github.com/pancakeswap/infinity-periphery | `main` (pushed 2026-07-31) | GPL-2.0 | Solidity |
| infinity-universal-router | https://github.com/pancakeswap/infinity-universal-router | `main` (pushed 2026-07-22) | none declared | Solidity |
| infinity-hooks / infinity-hooks-template / infinity-dynamic-fee-hook | https://github.com/pancakeswap/… | `main` | none / MIT / none | Solidity |
| pancake-v3-contracts | https://github.com/pancakeswap/pancake-v3-contracts | `main` HEAD `986847948755cba528324d41be19480731c36c2a` (2026-05-14) | **none declared** | TypeScript (repo), Solidity (contracts) |
| pancake-smart-contracts (v2 era, MasterChef etc.) | https://github.com/pancakeswap/pancake-smart-contracts | `master` (last push 2024-03-18) | **none declared** | Solidity |
| cake-token | https://github.com/pancakeswap/cake-token | `main` (2026-06-03) | none declared | Solidity |

`infinity-core/src` layout: `Vault.sol VaultToken.sol ProtocolFees.sol
ProtocolFeeController.sol Owner.sol Extsload.sol`, `pool-cl/{CLPoolManager.sol,
CLPoolManagerOwner.sol, interfaces/, libraries/, types/}`,
`pool-bin/{BinPoolManager.sol, BinPoolManagerOwner.sol, interfaces/, libraries/, types/}`,
plus `base/ interfaces/ libraries/ types/ test/`.

**Note the licence asymmetry**: the Infinity generation is GPL-2.0 (Uniswap's v4 is
BUSL-1.1), which is why a v4-shaped protocol could be shipped on BNB in March 2025 without
waiting out Uniswap's BUSL change date. Whether that is legally clean is out of scope here,
but it is a fact about the repos worth recording.

**Deployed↔repo correspondence.** The v3 addresses above come from PancakeSwap's own
developer docs. Infinity deployed addresses were **not** located: `developer.pancakeswap.finance`
returns 403 to a bare client (retrieved via scrapling), and the deployment page path is a 404
— the only Infinity address obtained is from a worked example in the FAQ
(`poolManager 0xa0FfB9c1CE1Fe56963B0321B32E7A0302114058b`, a CL pool manager on BSC, with
hook `0x32C59D556B16DB81DFc32525eFb3CB257f7e493d` for the BNB/CAKE dynamic-fee pool).
Bytecode verification against the repo: **UNKNOWN**, not performed.

### 4. EVIDENCE

1. https://developer.pancakeswap.finance/contracts/infinity/overview (via scrapling, HTTP 200) — "As of March 2025, PancakeSwap Infinity has completed audit"; the three-tier Vault / Pool Managers / Hooks separation; "The non-upgradeable core ensures stability"; independent singleton per AMM type, 2026-08-04.
2. https://developer.pancakeswap.finance/contracts/infinity/overview/accounting-layer-vault (scrapling) — "the Vault, which functions as an immutable accounting layer"; `lock()/lockAcquired()/accountAppBalanceDelta()`; `take/settle/mint/burn/clear`; `SettlementGuard` transient-storage snippet, 2026-08-04.
3. https://developer.pancakeswap.finance/contracts/infinity/overview/amm-layer-poolmanager (scrapling) — PoolKey struct incl. `poolManager` field and `bytes32 parameters`; `PoolId = keccak256(abi.encode(poolKey))`; CL vs Bin `initialize` signatures, 2026-08-04.
4. https://developer.pancakeswap.finance/contracts/infinity/faq/pancakeswap-infinity-vs-uniswap-v4 (scrapling) — hook permissions in the first 16 bits of `parameters` (not the address); worked decode of `0x…0a00c2`; the Vault-vs-PoolManager transfer-target difference, 2026-08-04.
5. https://raw.githubusercontent.com/pancakeswap/infinity-core/main/src/pool-cl/CLPoolManagerOwner.sol — `PausableRole`, `pausePoolManager() onlyPausableRoleOrOwner`, `unpausePoolManager() onlyOwner`, `setProtocolFeeController`, 2026-08-04.
6. https://raw.githubusercontent.com/pancakeswap/infinity-core/main/src/ProtocolFeeController.sol — `Ownable2Step`; `protocolFeeSplitRatio = 33 * 1e4`; `defaultProtocolFeeForDynamicFeePool = 300`; the >0.4% invalidity note; `setProtocolFee`, `collectProtocolFee`, 2026-08-04.
7. GitHub REST API on `pancakeswap/*` — licences, languages, HEAD shas, absence of tags on infinity-core, 2026-08-04.
8. https://docs.pancakeswap.finance/welcome-to-pancakeswap/vecake-sunset — the retirement dates 2025-04-23 / 04-25→05-06 / 05-07 / 10-23; 1:1 redemption; "redirected to the CAKE burn mechanism, increasing the burn rate for these pools from 10% to 15%", 2026-08-04.
9. https://docs.pancakeswap.finance/protocol/cake-tokenomics.md — 400M hard cap (reduced from 450M by a proposal passed 2026-01-16); "~4% per year"; "~20% by 2030"; the five burn sources and their rates, 2026-08-04.
10. https://docs.pancakeswap.finance/earn/pancakeswap-pools.md — v2 total 0.25% with 0.17% to the pool; the v3 EVM fee-split table (67/15/18, 66/15/19, 68/23/9, 68/23/9) and the Solana table (84/8/8), 2026-08-04.
11. https://docs.pancakeswap.finance/trade/pancakeswap-infinity/pool-types/infinity-clamm-and-lbamm.md — "CLAMM operates on the constant product formula (X * Y = K)"; "LBAMM follows the constant sum formula (X + Y = K)"; CL position is an NFT, bin liquidity is an ERC-20; "0 price impact trades within a bin", 2026-08-04.
12. https://docs.pancakeswap.finance/trade/pancakeswap-infinity/key-features.md — singleton, flash accounting via EIP-1153, native-token support, custom pricing curves via hooks, ERC-6909, `donate()`, 2026-08-04.
13. https://developer.pancakeswap.finance/contracts/v3/addresses (scrapling) — v3 core and periphery addresses, SmartRouter, MasterChefV3; the chain list incl. Monad and Robinhood, 2026-08-04.
14. https://api.llama.fi/protocols (filtered locally) — PancakeSwap $2,059.6M (AMM 1693.3 / AMM V3 289.4 / Infinity 73.2 / StableSwap 3.7), rank 2, 2026-08-04.

### 5. WHAT LOOKS UNNAMEABLE

- **The Vault/PoolManager split itself.** Uniswap v4 fuses custody and pricing in one
  contract; PancakeSwap Infinity separates them so that *pricing engines are pluggable at the
  contract level*, not merely at the hook level. Two AMM families (CL and Bin) share one
  ledger. Nothing names "a settlement ledger that several independent pricing engines
  register against" — and note this is structurally the same shape as Fluid's Liquidity Layer,
  which the corpus already flags as residue for Fluid. That coincidence is a signal: the
  missing symbol is one symbol, appearing twice in this lane.
- **Hook permissions carried in the pool's own key rather than mined into the hook's
  address.** Same semantics, different security and deployment model: Infinity hooks need no
  address mining, and one hook contract can be registered with different permission bitmaps
  by different pools. Any symbol that names "hook" must decide whether the permission set
  belongs to the code or to the pool; these two protocols answer differently.
- **A three-way fee split declared at the protocol level with a burn as one of the three
  legs.** `Fd` names distribution to a claim class. Here the split `LP / treasury / burn` is
  a *primitive of the fee accounting*, computed per tier, not a downstream policy.
- **A MasterChef allocation table.** `Em` says tokens are emitted; the allocation-point vector
  over pools, mutable by an admin, is unnamed. (The corpus already carries this; it stands.)
- **A pause role that is strictly weaker than ownership.** `Gp` names emergency
  guardian/pause, but here `pause` is delegable to a `PausableRole` while `unpause` is
  owner-only — an asymmetric, one-directional emergency authority. The one-way-ness is the
  design, and it has no name.
- **The retirement of a mechanism, with compensation of the holders of its derivative.** The
  corpus flags this and it is confirmed: veCAKE's sunset included whitelisting third-party
  locker delegators for 1:1 redemption. The vocabulary can record the presence or absence of
  `Ve`; it cannot record a transition, and it cannot record that the protocol assumed a
  liability to a *derivative built on its own mechanism by a third party*.
- **A supply hard cap that is itself governable.** 450M → 400M by vote. `Em` covers issuance;
  nothing covers a governance-mutable terminal bound on supply.

### 6. DELTA vs the corpus record

- **Rank basis reproduces**: $2,059.6M today vs corpus $2,049.0M; component drift only.
  Corpus lists AMM v2 $1,684.2M / v3 $288.0M / Infinity $73.1M against today's
  1693.3 / 289.4 / 73.2, and omits StableSwap ($3.7M) and AMM V1 ($0). Immaterial.
- **The corpus's `Up` element for PancakeSwap is under-justified as written, and the
  stronger claim is available.** The corpus assigns `Up` (mutable implementation proxy) on
  the strength of "a mutable admin". At the Infinity generation there is no proxy and the
  docs assert "The non-upgradeable core"; what actually exists is (i) an owner-mutable
  `ProtocolFeeController` (swappable wholesale via `setProtocolFeeController`) and (ii) a
  **pause authority**, which the corpus does not record at all. `Gp` is missing from
  PancakeSwap's element set and looks required. This is the single most consequential delta
  in this section. (Ev. 5, 6, 1.)
- **The corpus's framing "PancakeSwap decomposes as Uniswap with an emission schedule and a
  mutable admin" is falsified on architecture, not just on flavour.** Infinity is *not* a v4
  clone: it splits the singleton in two, supports a second AMM family (Liquidity Book /
  constant-sum bins) that Uniswap v4 has no equivalent of, carries hook permissions in the
  pool key instead of the hook address, and is GPL-2.0 rather than BUSL-1.1. If Uniswap and
  PancakeSwap still differ by exactly two symbols after decomposition, that is now a
  demonstrated failure of resolution, not a fair summary. (Ev. 1, 3, 4, 11.)
- **The corpus's Infinity residue note is right but incomplete**: it says "same hook residue
  as Uniswap (PancakeSwap Infinity is a hooks + singleton architecture)". It is a hooks +
  *split* singleton architecture, and the Bin/LBAMM curve — constant-sum within a discrete
  bin, fungible ERC-20 per bin — is a *pricing* mechanism the corpus's element list does not
  assign (PancakeSwap's element set has `Cp` and `Cl` but nothing for bins; `St` would be a
  bad fit since bins are exactly constant-sum, which vocab.md calls a degenerate limit `CSM`,
  "a limit of `St`, not an element"). Liquidity Book is a live, named, deployed pool type and
  its curve is unnamed.
- **PancakeSwap is deployed on Solana and on Monad and Robinhood Chain.** The docs publish a
  separate Solana fee split (84/8/8) and the v3 address table lists Monad and Robinhood. The
  corpus treats PancakeSwap as an EVM protocol. (Ev. 10, 13.)
- **The CAKE hard cap changed on 2026-01-16 (450M → 400M)** — after the corpus's stated
  verification pass. (Ev. 9.)
- **Correction to a widely repeated figure, flagged as UNKNOWN rather than asserted**: the
  v2 fee split "0.17% LP / 0.03% treasury / 0.05% CAKE burn" appears everywhere but this lane
  could not confirm the 0.03/0.05 legs at a PancakeSwap primary source; only 0.25% total and
  0.17% to LPs are documented on the current page. Do not carry the residual split into the
  paper without a better source.

---

## Curve

### 1. WHAT IT DOES

A user deposits one or more of a pool's coins — not necessarily balanced — and receives a
fungible LP token representing a pro-rata claim on the pool's whole reserve; they exit by
burning it, either balanced across all coins or imbalanced into one, paying a fee in the
imbalanced case so that "a swap between USDC and USDT would pay roughly the same amount of
fees as depositing USDC into the pool and then withdrawing USDT". Pricing depends on which
of two invariants the pool implements. **Stableswap** targets a *fixed* peg (1 USDC = 1
USDT), concentrating liquidity around it, with the amplification coefficient `A` setting how
imbalanced the pool may get before the price departs from parity. **Cryptoswap** ("Curve v2";
the docs deprecate that name) applies the same machinery but concentrates around a *moving*
internal price called `price_scale`, which the pool re-centres itself — passively, with no
external oracle and no action from the LP. Settlement is atomic. Beyond the pool there is a
second, larger machine: CRV emissions are minted weekly, and where they go is decided by
veCRV holders voting a weight vector over gauges, while an LP's own emission rate is
multiplied up to 2.5× by their veCRV balance. Half of every trading fee is an admin fee,
collected, converted through CowSwap into a single token, and distributed to veCRV lockers.
A position ends when the LP withdraws; there is no liquidation in the DEX, because there is
no debt. (Curve's crvUSD and Llamalend do have debt and liquidation — via LLAMMA — but those
are separate products and belong to other categories.)

### 2. DESIGN

**Stableswap — the invariant, from the whitepaper.** Egorov, *"StableSwap — efficient
mechanism for Stablecoin liquidity"*, 2019-11-10. The construction is explicit: take the
constant-sum and constant-product invariants generalised to `n` coins, `Σxᵢ = D` and
`Πxᵢ = (D/n)ⁿ`, where "the constant D has a meaning of total amount of coins when they have
an equal price"; scale the constant-sum leg by a leverage `χ` and add:

```
χ·D^(n−1)·Σxᵢ + Πxᵢ  =  χ·Dⁿ + (D/n)ⁿ
```

which is constant-product at `χ = 0` and constant-sum at `χ = ∞`. Then make `χ` *dynamic* so
that the curve degrades toward constant product as the pool goes out of balance:

```
χ = A·Πxᵢ / (D/n)ⁿ
```

Substituting gives the StableSwap invariant as published:

```
A·nⁿ·Σxᵢ + D  =  A·D·nⁿ + D^(n+1) / (nⁿ·Πxᵢ)
```

`D` and `xⱼ` are recovered by iterative convergence inside the contract, in integer
arithmetic. The paper's own simulation over DAI/USDC/USDT price feeds, May–Oct 2019, at
$30,000 liquidity, reports "Optimal 'amplification coefficient' ('leverage'): A = 85;
Optimal fee: 0.06% per trade".

In the docs: "Curve achieves extremely efficient stablecoin trades by implementing the
Stableswap invariant, which has significantly lower slippage for stablecoin trades than many
other prominent invariants (e.g., constant-product)." The controlling parameter is `A`, "the
amplification coefficient … determines a pool's tolerance for imbalance between the assets
within it. A higher value means that trades will incur slippage sooner as the assets within
the pool become imbalanced." Guidance in the docs: high `A` (1,000–20,000) concentrates
tightly around the peg with sharp drop-off if the peg breaks; low `A` (50–200) spreads more
evenly. `A` is stored scaled by `A_PRECISION = 100`, and is changed by `ramp_A` with a
minimum ramp time of 86,400 s — i.e. parameter changes are rate-limited, not instantaneous.
Pool flavours: plain pools, metapools (a coin paired against another pool's LP token, e.g.
`GUSD/3CRV`, tradeable through to the base coins but not depositable in them, because of the
contract size limit), and legacy lending pools. Pools expose `kill_me` / `is_killed`. Fee is
taken in the *output* token for stableswap.

**Cryptoswap — the invariant and the repeg condition, from the whitepaper.** Egorov,
*"Automatic market-making with dynamic peg"*, Curve Finance (Swiss Stake GmbH), 2021-06-09.
The paper states the thesis in one sentence: "We concentrate liquidity given by the current
'internal oracle' price but only move that price when the loss is smaller than part of the
profit which the system makes." Mechanically: balances are transformed by a price vector
`p` (called `price_scale` in the code), `b = T(b′,p) = (b′₀p₀, b′₁p₁, …)`, so the invariant is
always evaluated near equilibrium. The **CurveCrypto invariant** is stableswap's shape with a
different leverage term:

```
K·D^(N−1)·Σxᵢ + Πxᵢ  =  K·D^N + (D/N)^N
K₀ = Πxᵢ·N^N / D^N
K  = A·K₀·γ² / (γ + 1 − K₀)²
```

"where A is amplification coefficient and γ > 0 (but usually a small number) has a meaning of
distance between two dashed curve in Fig. 1. The invariant works approximately as a
superposition of constant-product and stableswap invariants." Solved as `F(x,D)=0` by Newton's
method, first for `D` then for `xⱼ`, "about 35k gas" per solve, with the paper giving the
required initial values and the fuzz-determined convergence limits
(`0.1 ≤ D ≤ 10¹⁵ [USD]`, `5·10⁻³ < xᵢ/D < 200`, `10⁻⁸ ≤ γ ≤ 10⁻²`).

The profit gate is defined against an explicit measure. The paper defines

```
X_cp = ( Π D/(N·pᵢ) )^(1/N)
```

as "a robust measure of profit … the value of constant-product invariant at equilibrium
point", and then: **"We allow the reduction in X_cp but only such that the loss of value of
X_cp doesn't exceed half the profit we've made (which we track by tracking the increase of
X_cp)."** That sentence is the whole mechanism: a state transition (moving the peg) gated on
a running ledger of the protocol's own realised profit. `X_cp` is `xcp_profit` in the code.

Two shape parameters, per the docs: "`A`: controls liquidity concentration in the center of
the bonding curve" and "`gamma`: controls whether liquidity drops off gradually or sharply
away from the center". Liquidity is centred on `price_scale`. The re-centring — the mechanism
the corpus correctly flags as unnamed — is stated by Curve as a two-condition gate:

> "Cryptoswap only rebalances when two conditions are met: 1. The internal price must move
> beyond a minimum threshold, known as the **adjustment step**. 2. The cost of rebalancing
> must be less than 50% of the trading fees earned by LPs. **This core safeguard ensures that
> impermanent loss is only realized when it is sufficiently offset by trading profits.**"

and, on the trigger: "rebalances are triggered not by the last price of the pool, but by an
**Exponential Moving Average** (EMA) of all recent prices. This internal price oracle helps
prevent manipulation of rebalances." The implementation names are `tweak_price`,
`price_scale`, `xcp_profit` / `xcp_profit_a`, and the deploy-time parameters are
`A, gamma, mid_fee, out_fee, fee_gamma, allowed_extra_profit, adjustment_step, ma_exp_time,
initial_prices` with bounds asserted in the factory (`0 < adjustment_step < 1e18 + 1`,
`allowed_extra_profit < 1e18 + 1`, `fee_max = 10 * 10^9`, `86 < ma_exp_time < 872542`).
Fee for cryptoswap pools is taken **in the LP token of the pool**, not in a coin.

The mechanism has a documented pathology that a construction must reproduce: **stale pools.**
"A Cryptoswap pool's main safety feature is its refusal to rebalance at a loss to LPs.
However, this can sometimes cause a pool to become **stuck** … As the market price moves away
from the pool's last rebalance price, the available liquidity for traders decreases. This
leads to fewer swaps and, consequently, lower fee generation. Without enough profit from
fees, the pool cannot afford to rebalance and follow the price, leaving its liquidity
stranded." The docs list the remedies, one of which is "**Wash Trade the Pool** … generating
high trading volume (often via flash loans) to create enough fee profit for the pool to
rebalance … performed at a loss with no guarantee of a lasting fix". That is a protocol whose
recovery procedure is an intentional loss-making trade by a third party.

**Dynamic fees.** "Cryptoswap and all new Stableswap pools feature **dynamic fees** that
adjust to increase returns for LPs when their liquidity is in high demand", governed by
`mid_fee`, `out_fee` and `fee_gamma`. Note this applies to Stableswap-NG too, so "Curve
charges a flat fee" is wrong for the current generation.

**Factories and registry.** Pools are deployed through per-generation factories —
`CurveStableSwapFactoryNG.vy`, `TwocryptoFactory.vy`, `CurveTricryptoFactory.vy` /
`CurveL2TricryptoFactory.vy` — each with `deploy_pool` / `deploy_metapool` taking the full
parameter vector, and each with a set of registered *implementations* that only the DAO can
add (`set_pool_implementation`). "Pools created through the Factory are 'owned' by the factory
`admin` (DAO)." Discovery across generations is unified by `MetaRegistry` (a separate repo)
behind an `AddressProvider`.

**veCRV, gauges, boost.** `VotingEscrow.vy` at
`0x5f3b5DfEb7B28CDbD7FAba78963EE202a494e2A2`, written in Vyper 0.2.4:
`MAXTIME = 4 * 365 * 86400` (four years), minimum one week, all unlock times rounded down to
whole weeks. "veCRV is a non-standard ERC-20 implementation"; locking "is **not reversible**
and veCRV tokens are **non-transferable**"; a user "cannot have multiple locks with different
expiry dates". Voting power decays linearly and is stored as a (bias, slope) piecewise-linear
function with scheduled `slope_changes`, so no user check-in is needed. 1 CRV locked 4 years
= 1 veCRV; n years = n/4.

The boost is a *separate* mechanism on the same lock, implemented in `LiquidityGaugeV6` by
`_update_liquidity_limit`:

```vyper
lim: uint256 = l * TOKENLESS_PRODUCTION / 100          # TOKENLESS_PRODUCTION = 40
if voting_total > 0:
    lim += L * voting_balance / voting_total * (100 - TOKENLESS_PRODUCTION) / 100
lim = min(l, lim)
self.working_balances[addr] = lim
```

"Provided liquidity is boosted by the veCRV balance of the user, allowing for boosts up to
2.5 times… If a user has no boost at all, their `working_balance` will be 40% of their LP
tokens. If the position is fully boosted (2.5x), their `working_balance` will be equal to
their LP tokens." So the "2.5×" is a ratio between the unboosted floor (0.4) and the cap
(1.0) — the emission rate is `working_balance / working_supply`, and *one LP's boost dilutes
every other LP*, because `working_supply` is shared. `GaugeController` holds the weight vote;
`Minter` mints CRV against gauge-reported integrals.

**Fees to lockers.** "50% of the fee is distributed to veCRV holders" (the factory's own
docstring on the `_fee` parameter, max 1% = 1e8 at 1e10 precision). Since June 2024 the
route is: `FeeCollector` (entry point, accepts any token) → `CowSwapBurner` (converts via
**CoW Protocol conditional orders** into the target token; deployed on Ethereum
`0xC0fC3dDfec95ca45A0D2393F518D3EA1ccF44f8b` and Gnosis
`0x566b9F24200A9B51b76792D4e81B569AF27eda83`) → `Hooker` → `FeeAllocator` (splits by
basis-point weights, "with a maximum total weight of 5,000 bps (50%). The remaining portion
(at least 50%) always flows to the `FeeDistributor`") → `FeeDistributor` → veCRV claimants.
`FeeSplitter` handles crvUSD-market fees separately. On chains without CoW, the *original*
architecture still runs: burn to MIM, bridge to mainnet, burn MIM to 3CRV.

**Control plane.** Aragon, with **two DAOs** and distinct thresholds:
`OWNERSHIP` — agent `0x40907540d8a6C65c637785e8f8B742ae6b0b9968`, voting
`0xE478de485ad2fe566d49342Cbd03E49ed7DB3356`, quorum 30%, support 51%; `PARAMETER` — agent
`0x4eeb3ba4f221ca16ed4a0cc7254e2e32df948c5f`, voting `0xbcff8b0b9419b9a88c44546519b1e909cf330399`,
quorum 15%, support 60%. Both use veCRV (`0x5f3b…`) as the voting token. Votes are Aragon EVM
scripts. Separately an **EmergencyDAO**, "a **5-of-9 multisig**", deployed at
`0x467947EE34aF926cF1DCac093870f613C96B1E0c` on Ethereum and `0x6d447e544D01a59cb0774763bf15526574CffFeD`
on every other chain; its scope was widened by proposal 1252 and is deliberately bounded —
"cannot move or withdraw any user funds", limited to pausing the Peg Stability Reserve,
*reducing but never increasing* debt ceilings, adjusting Llamalend AMM fees and monetary
policy "without triggering liquidation for any users", and setting lending-vault deposit
limits. Its nine members are named publicly in the docs. There is also cross-chain governance
(`x-gov`: agents, broadcaster, relayer, vault) and a veCRV oracle for L2s.

**The external vote market is visible inside Curve's own tooling.** Curve's `voting` library
creates DAO votes through "the Convex voter proxy
(`0x989AEB4D175E16225E39E87D0D97A3360524AD80`)" — i.e. the reference path for creating a
governance vote runs through a third-party protocol's veCRV position. This is direct
corroboration of the corpus's residue item about rented mechanisms.

**Price sources.** Cryptoswap's `price_oracle` is the internal EMA (`ma_exp_time` /
`ma_half_time`), used by the pool itself for rebalancing and exported for third parties.
Stableswap-NG exposes an EMA oracle with `_ma_exp_time` set as `time_in_seconds / ln(2)`.
No external oracle is consulted by the DEX.

**Failure path.** No liquidation. Pools have `kill_me`/`is_killed`, gauges can be killed by
the DAO (removing emissions without touching deposits), and the distinctive failure is the
stale-pool trap above.

### 3. REPO

**Load-bearing finding: Curve's current-generation pool code is source-available but NOT open
source.** `stableswap-ng`, `twocrypto-ng`, `tricrypto-ng`, `curve-core` and the legacy
`curve-contract` all ship a `LICENSE` reading:

> "(c) Swiss Stake AG, 2020-2026 … (a) all intellectual property (including all source code,
> designs and protocols) contained in this repository has been published for informational
> purposes only; (b) no license, right of reproduction or distribution or other right with
> respect thereto is granted or implied; and (c) all moral, intellectual property and other
> rights are hereby reserved by the copyright holder."

GitHub reports these as `NOASSERTION`. Only the DAO layer and tooling are MIT:
`curve-dao-contracts` (MIT, "Copyright (c) 2020 Curve Finance"), `metaregistry` (MIT),
`curve-js` (MIT).

| Repo | Ref inspected | Licence | Lang |
|---|---|---|---|
| curvefi/stableswap-ng | `main` HEAD `2abe778f40206a6c0fd108a0a53ad3266cbedeee` (2026-04-25); tags are **chain names** (`zksync`, `xlayer`, `mantle`, `fraxtal`, `fraxtal_deployment`), not versions | all-rights-reserved, Swiss Stake AG 2020-2026 | Vyper |
| curvefi/twocrypto-ng | `main` HEAD `5cbe558902402e8fcb331463089db65fc56c11f9` (2026-03-13); tags `zksync`, `yb-init`, `xlayer`, `mantle`, `lite-0.3.10` | all-rights-reserved, 2023-2026 | Vyper |
| curvefi/tricrypto-ng | `main` HEAD `ecaa8161c240f21dd7c3712eefc5637e1dac742b` (2026-03-20); tags `zksync`, `xlayer`, `mantle`, `fraxtal` | all-rights-reserved, 2024-2026 | Vyper |
| curvefi/curve-core | `main` HEAD `6222dda9959091db94d61f6d6378234a624cdd66` (2026-07-17); **no tags** | all-rights-reserved, 2025-2026 (`LICENSE.md`) | Vyper |
| curvefi/curve-dao-contracts | `master` HEAD `fa127b1cb7bf83e4f3d605f7244b7b4ed5ebe053` (2025-05-26); tags v1.0.0–**v1.3.0** | **MIT** | Python/Vyper |
| curvefi/curve-contract (v1 legacy) | `master`, last push 2025-05-29 | all-rights-reserved, "(c) Curve.Fi, 2020" | Python/Vyper |
| curvefi/curve-crypto-contract | `master`, pushed 2026-07-26 | **no LICENSE file at all** | Python/Vyper |
| curvefi/metaregistry | `main` | MIT | Vyper |

Directory layout, `stableswap-ng`: `contracts/{ProxyAdmin.vy, main/, mocks/} deployments/
scripts/ tests/ ape-config.yaml pyproject.toml LICENSE README.md`. `contracts/main/` =
`CurveStableSwapNG.vy CurveStableSwapMetaNG.vy CurveStableSwapNGMath.vy
CurveStableSwapNGViews.vy CurveStableSwapFactoryNG.vy CurveStableSwapFactoryNGHandler.vy
LiquidityGauge.vy MetaZapNG.vy`.
`twocrypto-ng/contracts/main/` = `Twocrypto.vy TwocryptoFactory.vy TwocryptoMath.vy
TwocryptoView.vy LiquidityGauge.vy lp_token.vy constants.vy params.vy packing_utils.vy`.
`tricrypto-ng/contracts/main/` = `CurveTricryptoOptimized.vy CurveTricryptoOptimizedWETH.vy
CurveCryptoMathOptimized3.vy CurveCryptoViews3Optimized.vy CurveTricryptoFactory.vy
CurveL2TricryptoFactory.vy CurveTricryptoFactoryHandler.vy LiquidityGauge.vy`, plus
`contracts/{old,reference,experimental,zksync}/`.

**Language: Vyper throughout**, which is a real difference from every other protocol in this
lane. The exact compiler version per contract is stated in the docs per page (e.g.
`VotingEscrow.vy` at Vyper 0.2.4, `CowSwapBurner.vy` at 0.3.10, `FeeAllocator.vy` at 0.4.1
using a Snekmate `ownable` module) — so Curve runs **at least four different Vyper major
lines in production simultaneously**.

**Deployed↔repo correspondence.** Each repo carries a `deployments/` directory and, for the
crypto pools, a `deployments.yaml`; the docs publish per-contract addresses with Etherscan
links. Independent bytecode verification was **not** performed by this lane → recorded as
*stated by the docs*, **UNKNOWN** as a verified fact. The chain-named tags
(`zksync`/`xlayer`/`mantle`/`fraxtal`) indicate that per-chain deployments are cut from
*divergent branches*, which is a correspondence hazard a later lane should note: there is no
single commit that describes all deployments.

### 4. EVIDENCE

All 2026-08-04. Note that Curve's documentation sites were **recently unified** — the old
`resources.curve.finance` paths now return 404 with the message "Curve docs were recently
unified—you may have followed an old link", and even `docs.curve.finance/llms.txt` publishes
some stale URLs. Working URLs below were taken from `docs.curve.finance/sitemap.xml`
(276 entries), and the page text was read from `docs.curve.finance/llms-full.txt`
(4,731,851 bytes, downloaded in full) to avoid summariser paraphrase.

1. https://docs.curve.finance/llms-full.txt — the complete docs corpus; source of every quote below unless another URL is given.
2. https://docs.curve.finance/sitemap.xml — 276 live URLs; used to recover the post-unification paths.
3. https://docs.curve.finance/developer/amm/cryptoswap-in-depth — "Cryptoswap only rebalances when two conditions are met… the **adjustment step**… less than 50% of the trading fees earned by LPs"; the internal EMA oracle note; `A` and `gamma`; dynamic fees "Cryptoswap and all new Stableswap pools"; the **stale pool** section and the wash-trade remedy.
4. https://docs.curve.finance/developer/amm/factory/tricrypto-ng/deployer-api — the full `deploy_pool` parameter vector and the asserted bounds (`allowed_extra_profit < 10**18+1`, `0 < adjustment_step < 10**18+1`, `fee_max = 10*10**9`, `86 < ma_exp_time < 872542`); "50% of the fee is distributed to veCRV holders"; `_ma_exp_time` "= time_in_seconds / ln(2)".
5. https://docs.curve.finance/developer/amm/legacy/stableswap-overview — "Curve achieves extremely efficient stablecoin trades by implementing the Stableswap invariant"; metapool semantics and the bytecode-size reason; the `A_PRECISION = 100` scaling; `ramp_A` minimum 86400 s; `kill_me`.
6. https://docs.curve.finance/developer/curve-dao/voting-escrow/ — `VotingEscrow.vy`, Vyper 0.2.4, `0x5f3b5DfEb7B28CDbD7FAba78963EE202a494e2A2`; `MAXTIME: constant(uint256) = 4 * 365 * 86400`; "maximum lock duration is four years and the minimum is one week"; non-transferable, non-reversible, one lock per user; the bias/slope/`slope_changes` design.
7. https://docs.curve.finance/developer/gauges/gauges/liquidity-gauge-v6 — the `_update_liquidity_limit` source with `TOKENLESS_PRODUCTION`; "boosts up to 2.5 times"; "If a user has no boost at all, their `working_balance` will be 40% of their LP tokens."
8. https://docs.curve.finance/developer/fees/overview — the FeeCollector → CowSwapBurner → Hooker → FeeDistributor flow; **"There are actually two `FeeDistributors` deployed, as rewards were distributed in `3CRV` tokens, before a DAO vote changed the reward token to `crvUSD`."**; the CoW-only chain limitation.
9. https://docs.curve.finance/developer/fees/fee-allocator — "a maximum total weight of 5,000 bps (50%). The remaining portion (at least 50%) always flows to the `FeeDistributor`"; crvUSD as the fee token.
10. https://docs.curve.finance/developer/fees/cow-swap-burner — CoW conditional orders; deployed on Ethereum `0xC0fC3dDfec95ca45A0D2393F518D3EA1ccF44f8b` and Gnosis `0x566b9F24200A9B51b76792D4e81B569AF27eda83`.
11. https://docs.curve.finance/developer/fees/original-architecture/overview and `/sidechains` — the superseded architecture, explicitly banner-flagged "PARTLY OUTDATED… In June 2024, Curve deployed a new system"; the MIM→3CRV sidechain route.
12. https://docs.curve.finance/developer/curve-dao/governance/overview and `/voting-library` — the two DAO types with quorum 30%/51% and 15%/60%, and their agent/voting/token addresses; Aragon EVM scripts; the Convex voter proxy `0x989AEB4D175E16225E39E87D0D97A3360524AD80` used by Curve's own vote tooling.
13. https://docs.curve.finance/governance (Emergency DAO section) — "a **5-of-9 multisig**"; proposal 1252; "cannot move or withdraw any user funds"; the four scope bullets; deployments `0x467947EE34aF926cF1DCac093870f613C96B1E0c` and `0x6d447e544D01a59cb0774763bf15526574CffFeD`; the nine named members.
14. https://docs.curve.finance/developer/amm/factory/stableswap-ng/deployer-api — factory ownership: "Pools created through the Factory are 'owned' by the factory `admin` (DAO)"; `commit_transfer_ownership`/`accept_transfer_ownership`.
15. GitHub REST API on `curvefi/{stableswap-ng, twocrypto-ng, tricrypto-ng, curve-core, curve-dao-contracts, curve-contract, curve-crypto-contract, metaregistry, curve-js}` — languages, licence fields, default branches, HEAD shas and dates, tag lists, and the `contracts/` trees. **All run by this lane.**
16. GitHub contents API on each repo's `LICENSE` / `LICENSE.md` — the Swiss Stake AG all-rights-reserved text quoted above; MIT for `curve-dao-contracts` and `metaregistry`; **no LICENSE file** in `curve-crypto-contract`. **All run by this lane.**
17. https://api.llama.fi/protocols (filtered locally) — Curve DEX $1,277.3M, rank 3.
18. https://docs.curve.finance/pdf/whitepapers/whitepaper_stableswap.pdf (byte-identical to https://curve.finance/files/stableswap-paper.pdf, 273,774 bytes, 6 pages) — Michael Egorov, "StableSwap - efficient mechanism for Stablecoin liquidity", 2019-11-10. The derivation `χD^(n−1)Σxᵢ + Πxᵢ = χDⁿ + (D/n)ⁿ`, `χ = A·Πxᵢ/(D/n)ⁿ`, and the published invariant `A·nⁿ·Σxᵢ + D = A·D·nⁿ + D^(n+1)/(nⁿ·Πxᵢ)`; "The constant D has a meaning of total amount of coins when they have an equal price"; the simulation result A = 85, fee 0.06%. **Downloaded and text-extracted by this lane.**
19. https://docs.curve.finance/pdf/whitepapers/whitepaper_cryptoswap.pdf (200,945 bytes, 5 pages) — Michael Egorov, Curve Finance (Swiss Stake GmbH), "Automatic market-making with dynamic peg", 2021-06-09. "We concentrate liquidity given by the current 'internal oracle' price but only move that price when the loss is smaller than part of the profit which the system makes"; the `price_scale` transform `b = T(b′,p)`; `X_cp = (Π D/(N·pᵢ))^(1/N)`; **"We allow the reduction in X_cp but only such that the loss of value of X_cp doesn't exceed half the profit we've made"**; the CurveCrypto invariant with `K₀ = Πxᵢ·N^N/D^N` and `K = A·K₀·γ²/(γ+1−K₀)²`; Newton solve "about 35k gas"; the convergence limits. **Downloaded and text-extracted by this lane.**
20. https://docs.curve.finance/user/reference/whitepapers — the canonical whitepaper index and publication dates (Stableswap 2019-11-10, Curve DAO 2020, Cryptoswap 2021-06-09, crvUSD 2022-10-09).

**Blocked/failed:** `resources.curve.finance/reward-gauges/boosting-your-crv-rewards/` and
`/crv-token/claiming-trading-fees/` return 403 to WebFetch and 404 via scrapling (docs
unification). `curve.fi/files/*` 301-redirects to `curve.finance/files/*`, which then returns
403 to WebFetch; the PDFs were retrieved with scrapling (which lands on `www.curve.finance`)
and parsed locally with PyMuPDF. `curve.finance/files/crypto-pools-paper.pdf` is **not** a PDF
— it returns a 3,655-byte HTML error page; the Cryptoswap whitepaper lives only at the
`docs.curve.finance/pdf/whitepapers/` path.

### 5. WHAT LOOKS UNNAMEABLE

- **A profit-gated re-centring.** The corpus names this and it is confirmed verbatim: the pool
  moves its own concentration centre only when (a) an EMA of its own price has moved past
  `adjustment_step` and (b) the drawdown in `X_cp` is under half the accumulated `X_cp` gain.
  Three separable things need naming, not one: the *self-referential price* (the pool's own
  EMA is its own oracle and the input to its own state transition); the *profit functional*
  (`X_cp`, a named scalar of the pool state that only ratchets up); and the *ratio-bounded
  state transition* conditioned on that functional. `St`, `Cl` and `Pm` miss all three.
- **A protocol whose safety property has a documented deadlock, and whose escape is a
  loss-making third-party trade.** The stale-pool trap is not a bug report; it is in the
  official docs with a remedy list. A formalism that reproduces Cryptoswap and cannot exhibit
  the stuck state has not reproduced Cryptoswap.
- **Gauge weight voting.** A vote that produces a *weight vector over pools* which then
  parameterises the emission function. `Em` says tokens are emitted and is silent on direction;
  `Ve` names the lock and is silent on the vote.
- **The boost, as a dilutive shared denominator.** `working_balance` is capped at the LP's own
  balance and floored at 40% of it, and the reward rate is `working_balance / working_supply`
  — so boosting is *rivalrous*: your boost lowers everyone else's yield. This is a third
  mechanism on the same lock and it is not a multiplier on an independent quantity.
- **A vote-rental market that the protocol's own tooling routes through.** Curve's reference
  vote-creation path goes through Convex's voter proxy. The vocabulary has no way to say that
  the effective controller of a mechanism is a third-party protocol.
- **Two governance bodies with different quorums over disjoint action sets**, plus a third
  emergency body whose powers are *directional* (may reduce a ceiling, may never raise it;
  may adjust fees but may not cause a liquidation). `Tg` names delay; `Gp` names pause.
  Neither names a monotone-restricted authority.
- **A permissionless pool factory with a DAO-gated implementation registry.** Anyone may
  deploy a pool; only the DAO may add the *implementation* it is deployed from. That is a
  two-level permission structure — free instantiation over a governed set of types — and the
  same shape recurs as Fluid's "governance can deploy infinite DEX types" and Uniswap's
  `enableFeeAmount`. Three appearances in this lane.
- **Fee conversion as an outsourced auction.** Admin fees in arbitrary tokens are converted by
  posting *CoW Protocol conditional orders*; the protocol does not price its own fee stream,
  it delegates that to another protocol's batch auction. `Ba` exists in the vocabulary but
  belongs to the other protocol; nothing names "this protocol's fee plumbing is a client of
  that protocol's clearing mechanism".
- **A rate-limited parameter change** (`ramp_A`, minimum 86,400 s): `A` moves along a ramp
  rather than jumping, so the invariant itself is time-varying by construction. No symbol
  names a continuously-interpolated invariant parameter.

### 6. DELTA vs the corpus record

- **Rank basis reproduces**: $1,277.3M today vs corpus $1,277.0M.
- **The repository licence is the biggest correction.** A reader of the corpus would assume
  Curve is open source. The current pool generation is **all-rights-reserved by Swiss Stake AG,
  "published for informational purposes only", with "no license, right of reproduction or
  distribution … granted or implied"**. Only `curve-dao-contracts` and `metaregistry` are MIT,
  and `curve-crypto-contract` has no LICENSE file at all. Any construction claiming to
  reimplement Curve's AMM must be built from the whitepapers, not the repos. (Ev. 15, 16.)
- **Fees to veCRV are distributed in crvUSD, not 3CRV.** Curve's own fee page states there are
  two FeeDistributors "as rewards were distributed in `3CRV` tokens, before a DAO vote changed
  the reward token to `crvUSD`", and the whole June-2024 architecture (FeeCollector →
  CowSwapBurner → Hooker → FeeAllocator → FeeDistributor) supersedes the 3CRV burner path,
  which the docs banner as "PARTLY OUTDATED". The corpus's `Fd` marker ("admin fees are
  converted and distributed to veCRV lockers") is still true, but a decomposition that assumes
  the 3CRV route will be describing a retired system — and the *conversion* now happens through
  a third-party batch auction, which is new residue. (Ev. 8, 9, 10, 11.)
- **The `St` FORCED marker is right, and the corpus's reason for it can be strengthened.** The
  corpus says `St` "covers the stableswap pools (the majority of TVL) but not the
  tricrypto/twocrypto pools". Correct — and additionally, **Stableswap-NG itself now has
  dynamic fees**, which `St` (constant-sum near parity) does not imply. "All new Stableswap
  pools feature dynamic fees." (Ev. 3.)
- **The corpus's `Ag` FORCED marker stands and is if anything understated.** Curve's own
  router is single-venue, but discovery is `MetaRegistry` behind an `AddressProvider` across
  *generations* of factory, which is a registry problem rather than a routing problem.
- **`Tp` is in the corpus's element set and is justified, but the object is unusual.** Curve's
  oracle is an *internal EMA that the protocol consumes itself* to decide when to re-centre —
  not a TWAP published for others (though others do read it). `Tp` names "on-chain
  time-weighted price"; the load-bearing part here is that the price feed is an input to the
  pool's own state transition. (Ev. 3.)
- **New: the Emergency DAO is a 5-of-9 multisig with directional powers, and the corpus records
  no `Gp` for Curve.** Curve's element set is `Ag, Em, Fd, Sh, St, Tg, Tp` (+`Ve`); there is a
  live emergency body that can pause contracts and reduce ceilings. `Gp` looks required. (Ev. 13.)
- **New: two DAOs with different quorums** (OWNERSHIP 30%/51%, PARAMETER 15%/60%). `Tg` treats
  governance as one delayed authority; Curve has two, over disjoint action sets, with different
  thresholds. (Ev. 12.)
- **The corpus's "external vote-rental market (Convex/Votium)" residue is confirmed from inside
  Curve's own repository tooling**, not merely from third-party reporting: Curve's `voting`
  library creates DAO votes via the Convex voter proxy. That upgrades the residue from an
  observation about the ecosystem to a fact about the protocol's own reference path. (Ev. 12.)
- **The permissionless-pool-factory residue is confirmed but is really two things**: deployment
  is permissionless, *implementation registration is not*. The corpus records only the first.
  (Ev. 14.)
- **Repo hygiene note for later lanes:** the NG repos' tags are **chain names**, not versions
  (`zksync`, `xlayer`, `mantle`, `fraxtal`), so per-chain deployments come off divergent
  branches and there is no single commit describing the deployed set. Curve also runs at least
  four Vyper major lines in production simultaneously (0.2.4, 0.3.10, 0.4.1, plus the NG pool
  compilers). (Ev. 15, 6, 9, 10.)
- **The corpus's headline Curve residue is now stated exactly, in the protocol's own algebra,
  and it is sharper than the corpus's paraphrase.** The corpus describes "a concentrated curve
  whose center is an internal EMA that ratchets only when the repeg is profitable". The
  whitepaper's condition is not "profitable" but a *specific bounded drawdown against a running
  profit ledger*: `X_cp = (Π D/(N·pᵢ))^(1/N)` is tracked, and a peg move is permitted only if
  the reduction in `X_cp` "doesn't exceed half the profit we've made". So the gate is (i) on a
  named scalar functional of the pool state, (ii) monotone-accumulating, and (iii) a *ratio*
  constraint, not a sign constraint. Any construction that models the gate as "repeg if
  profitable" will admit behaviours Curve forbids. (Ev. 19.)
- **`St` and the crypto invariant are the same equation with different `K`.** Stableswap is
  `χD^(n−1)Σxᵢ + Πxᵢ = χDⁿ + (D/n)ⁿ` with `χ = A·Πxᵢ/(D/n)ⁿ`; CurveCrypto is the identical form
  with `K = A·K₀·γ²/(γ+1−K₀)²`. This is a strong hint for the algebra: the two are one
  parameterised family, not two symbols, and the corpus's split (`St` for stableswap, residue
  for cryptoswap) may be the wrong cut. (Ev. 18, 19.)
- Remaining **UNKNOWN** for Curve: whether the deployed bytecode matches the repos (not checked
  by this lane, and complicated by the chain-named branch tags); the identity of the
  `FeeAllocator`'s current receiver set and weights; and whether the CowSwap fee system has
  since shipped on Arbitrum (the docs say "soon").

---

## Raydium

### 1. WHAT IT DOES

Raydium is several distinct Solana programs behind one interface. In **CPMM** (the
"standard" constant-product pool) and legacy **AMM v4**, a user deposits both sides of a
pair and receives a fungible **SPL LP token**; they exit by burning it for a pro-rata slice
of both vaults. There is no "collect fees" instruction on either program — fees remain in
the vaults and inflate `k`, so LP earnings are realised implicitly at exit. In **CLMM** the
user instead chooses a price range and receives a **position NFT** (a supply-1 mint whose
mint authority is the program); fees accrue per position and are claimed explicitly, and
closing means decreasing liquidity to zero, collecting, then burning the NFT. Swaps are
priced entirely off pool state — `x·y=k` on reserves for AMM v4/CPMM, sqrt-price/tick math
for CLMM — and **no external oracle is consulted during a swap, deposit or withdrawal**.
Settlement is atomic within one Solana instruction; the `AMM Routing` program can CPI
across up to two pools in a transaction. **LaunchLab** is the launchpad: a creator deploys
a token against a bonding curve quoted in SOL/USDC/RAY with no pre-seeded liquidity, buyers
mint from the curve, and once the quote vault crosses a threshold the launch *graduates* —
the program CPIs a CPMM pool seeded with the remaining reserves and revokes the base mint
authority. **Ecosystem farms** are a separate MasterChef-style staking program that escrows
an LP token against pre-funded emissions and never calls the pool. There is no liquidation
anywhere in the spot stack.

### 2. DESIGN

**Programs and mainnet IDs** (docs `/reference/program-addresses`, and each ID confirmed
on-chain via `getAccountInfo` against `api.mainnet-beta.solana.com` as owned by
`BPFLoaderUpgradeab1e11111111111111111111111`):
AMM v4 `675kPX9MHTjS2zt1qfr1NYHuzeLXfQM9H24wFSUt1Mp8` (last deploy 2026-07-22T13:29:55Z);
CPMM `CPMMoo8L3F4NbTegBCKVNunggL7H1ZpdTHKxQB5qKP1C` (2026-06-11);
CLMM `CAMMCzo5YL8w4VFF8KVHrK22GGUsp5VTaW7grrKgrWqK` (2026-07-30);
Stable AMM `5quBtoiQqxF9Jv6KYKctB59NT3gtJD2Y65kdnB1Uev3h`;
LaunchLab `LanMV9sAd7wArD4vJFi2qDdfnVhFxYSUg6eADduJ3uj`;
AMM Routing `routeUGWgWzqBWFcrCfv8tritsqukccJPu3q5GPP3xS`;
Burn&Earn / LP Lock `LockrWmn6K5twhz3y9w1dQERbmgSaRkfnTeTKbpofwE`;
Farm v6 `FarmqiPv5eAj3j1GMdMCMUGXqPUvmquZtMy86QH6rzhG` (Farm v3/v5 IDs published but not
queried → UNKNOWN on-chain).

**OpenBook: removed, not dormant — and this is dated.** As of the 2026-07 upgrade AMM v4's
OpenBook/Serum dependency has been removed from the program. Four independent
confirmations: the docs changelog page `/reference/changelog/2026-07-22-amm-v4-openbook-removal`;
Raydium's own upgrade notes, which say the upgrade "removes the Serum/OpenBook dependency,
all related CPIs, and the dead instructions" and that it "does not change any live trading
behavior" because "there were no OpenBook orders left to stop placing"; the repo HEAD commit
`27f461dd439086c774055f771b253fb0fbc52008` (2026-07-23) titled **"Remove openbook dependency
(#69)"**; and a binary scan of the deployed ELF at ProgramData
`A7ZG7ByDi8DpzT9Ab7CiXhvgYTJQmaDPJkMDoPitaCQV` (1,406,384 bytes) finding zero occurrences of
the string `serum` and neither OpenBook program ID as a 32-byte constant, with the SPL Token
ID present as a positive control. Instructions removed or now reverting: `Initialize`(0),
`MonitorStep`(2), `MigrateToOpenBook`(5), `WithdrawSrm`(8), `PreInitialize`(10),
`SimulateInfo`(12), `AdminCancelOrders`(13). `AmmInfo`/`StateData` remain **byte-compatible**
— the struct still carries inline `open_orders` / `market` / `market_program` fields as inert
references, and v1 swaps still require 17–18 accounts of which several are dead placeholders
never validated. `SwapBaseInV2`/`SwapBaseOutV2` (tags 16/17, 8 accounts) are the recommended
path.

**State model.** AMM v4: `AmmInfo` (~752 bytes), `TargetOrders`, two vaults, LP mint whose
authority is `amm_authority`; LP supply must be read from the mint; **no observation account,
so no program-supported TWAP**. CPMM: `PoolState`, `AmmConfig`, LP mint, two vaults, and an
`Observation` PDA (seed `"observation"` + poolState) holding a 100-entry ring of
`(block_timestamp, cumulative price)`; pools and their PDAs are never closed even at zero
liquidity. CLMM: `PoolState` (`sqrt_price_x64`, current tick, fee-growth globals, inline
bitmap for ±1,024 tick arrays), `AmmConfig`, `TickArrayState` (60 ticks per array, lazily
initialised, **never closable — rent permanently locked**), `TickArrayBitmapExtension`,
`PersonalPositionState`, `ObservationState` (100 entries storing **cumulative tick**, not
cumulative price). `price(i) = 1.0001^i`, `MIN/MAX_TICK = ∓443636`;
`liquidity_gross`/`liquidity_net` accounting is Uniswap v3's.

**Fees, and the buyback question.** Canonical split, stated as a fraction *of the trading
fee*: CLMM and CPMM 84% LPs / 12% RAY buyback / 4% treasury; AMM v4 88% LPs / 12% buyback,
no treasury slice. This was verified against the live API rather than the docs:
`api-v3.raydium.io/main/cpmm-config` returns 19 live configs and `/clmm-config` returns 18,
and **every one** carries `protocolFeeRate: 120000` and `fundFeeRate: 40000` on a
1,000,000 denominator. `createPoolFee` = 150,000,000 lamports (0.15 SOL) on CPMM/AMM v4.
AMM v4 uses a 10,000 denominator (`25` = 0.25%) — an integration hazard. Fee collection
accounts: CLMM `projjosVCPQH49d5em7VYS7fJZzaqKixqKtus7yk416`, CPMM
`ProCXqRcXJjoUd1RNoo28bSizAA6EEqt9wURZYPDc5u`, AMM v4
`PNLCQcVCD26aC7ZWgRyr5ptfaR7bBrWdTFgRWwu2tvF`. CPMM additionally charges a **creator fee
that is not a slice of the trade fee**; live configs show `creatorFeeRate` from 500 to
14,950. CLMM supports single-sided fee accrual (`CollectFeeOn`: `FromInput` / `Token0Only` /
`Token1Only`, immutable after pool creation) and an optional dynamic (volatility-surcharge)
fee. `AmmConfig` is immutable at pool level — a pool can never change fee tier.

**Buyback is not burn.** The docs label the destination row "Bought-back RAY *accumulation*"
at `DdHDoz94o2WJmD9myRobHCwtx1bESpHTd4SSPe6VEZaz`, and the chain agrees: that owner holds
≈83.54M RAY across six token accounts, while RAY total supply is
**554,997,631.209468** against a 555,000,000 max — i.e. on the order of 2,400 RAY has ever
been destroyed. The 12% buys RAY and **holds it in a protocol-controlled account**.

**LaunchLab.** `curve_type` is chosen at `Initialize`: 0 = constant product on **virtual
reserves** (`(V_q + Δq)(V_b + b_rem − b_out) = V_q·V_b`), 1 = fixed price, 2 = linear price.
`base_supply_graduation` is typically 0.8 × `base_supply_max`, the remaining 20% seeding the
pool, so the pre-graduation invariant is literally the post-graduation CPMM invariant and
the handoff is price-continuous by construction. Graduation fires when
`quote_vault.balance ≥ quote_reserve_target` and **`Graduate` is permissionless** — anyone
may call it once the threshold is crossed. At graduation the program CPIs CPMM `CreatePool`,
revokes the base mint authority, and sets `LaunchState.status` to `Graduated`
(`Active`/`Graduated`/`Cancelled`). Token-2022 launches must graduate to CPMM. Pre-graduation
fee is 1% both sides, split `protocol_share`/`creator_share`/`lp_share`. Post-graduation LP is
split by `PlatformConfig` into `platform_scale + creator_scale + burn_scale = 1_000_000`
(strict equality, checked by `MigrateNftInfo::check`); the "burn" slice routes to the Lock
program with `is_burn = true`, and the docs concede: "Despite the name, the LP tokens /
position NFT are **locked** in a program-owned escrow, not destroyed." Burn&Earn mints a
transferable **Raydium Fee Key NFT** carrying the perpetual right to `collectFees`.

**Control plane.** All eight programs queried use BPF Loader Upgradeable and **share one
upgrade authority, `FytDrVzDybM1TwFQPGb8qaxZR7dBCzNeqT3vtQsceZQK`**; none is immutable, which
matches the docs' own statement that "Raydium has not set any program's upgrade authority to
null." The docs claim two Squads multisigs — a 3/4 with a 24-hour timelock for program
upgrades, and a 3/5 with **no** timelock for treasury, which also holds the program-admin
powers (creating `AmmConfig`s, sweeping protocol fees, toggling pool status) and is described
as "an interim arrangement". **The threshold and the timelock could not be verified on-chain**:
the authority address is a System-Program-owned, zero-data account (consistent with a Squads
vault PDA but not a multisig settings account), so 3/4 and 24h are docs-only → **UNKNOWN**.
There is no on-chain token voting. Pause/freeze surface: AMM v4 `SetParams(param=Status)`,
CPMM `UpdatePoolStatus`, and `disable_create_pool` on an `AmmConfig`.

**Oracles.** "Raydium's core products don't depend on external oracles for pricing — the pool
state *is* the oracle." CPMM and CLMM each expose an `ObservationState` TWAP ring that
*other* protocols consume; AMM v4 has none. Pyth and Jupiter are used only for USD display in
the frontend/API and never touch pool math.

**Failure path.** There is no liquidation in any Raydium spot AMM — no borrowing, no margin,
no collateral ratio, no keeper. (The docs never state this sentence; it is an inference from
the mechanism, and is labelled as such.) Nearest analogues: a CLMM position whose price
leaves `[tick_lower, tick_upper]` stops earning entirely and is converted 100% into one side
— idle, not seized; and a LaunchLab curve that never reaches its threshold, where "the curve
never graduates and buyers are stuck with tokens they can only sell back to the curve (at
worse prices)". **Raydium Perps is not a Raydium program** — it is a white-labelled Orderly
Network CLOB, and it is the only Raydium-branded surface where liquidation exists.

**Exploit history.** 2022-12-16: "The attacker compromised eight constant product liquidity
pools on Raydium, totaling approximately ~4.4m USD in funds stolen." Root cause was a
compromised pool-owner private key on a VM, not a program bug; the attacker "used the
SetParams instruction in conjunction with `AmmParams::SyncNeedTake` to inflate the balances
for `need_take_pc` and `need_take_coin`" and then drained vaults via `withdrawPNL` — the same
instruction that collects the 12% protocol fee. Raydium published the raw loss data as
`raydium-io/dec_16_exploit`; summing `Total Loss Per Vault.csv` gives **$4,417,202.04 across
nine pairs** (the postmortem says eight pools — unreconciled). Authority was moved to a
hardware wallet then to Squads, and `AmmParams::SyncNeedTake` was removed; `SetParams` now
accepts only `Status`, `State`, `Fees`, `SetOpenTime`.

### 3. REPO

Org: https://github.com/raydium-io. **Only three on-chain programs are open source**, and the
docs say so: "only `raydium-amm` (AMM v4), `raydium-cp-swap` (CPMM), and `raydium-clmm`
(CLMM) ship with public source repositories."

| Repo | Licence | Lang | HEAD (verified via API) |
|---|---|---|---|
| raydium-amm | **Apache-2.0** | Rust | `27f461dd439086c774055f771b253fb0fbc52008`, 2026-07-23, "Remove openbook dependency (#69)" |
| raydium-cp-swap | **Apache-2.0** | Rust | `78f254e1023751e706df7dc15c453fc3e046697c`, 2026-06-12 |
| raydium-clmm | **Apache-2.0** | Rust | `51fdba2cf614d66a2ece9c077f1e7bf86a2875f1`, 2026-07-30 |
| raydium-sdk-V2 | GPL-3.0 | TypeScript | `bf78fdd9…`, 2026-08-04; tag `v0.1.117-alpha` |
| raydium-idl | none | — | `e7e0c96f…`, 2026-05-18; tag `v0.29.0`; only CLMM/CPMM/Launchpad IDLs |
| raydium-docs | none | — | holds `audit/` |
| raydium-docs-v1 | MIT | MDX | source of docs.raydium.io |
| dec_16_exploit | none | — | 2022-12-17, exploit loss CSVs |

**All three program repos have ZERO tags and ZERO releases.** Top level of `raydium-amm`:
`Cargo.toml Cargo.lock LICENSE README.md SECURITY.md program/`. `raydium-cp-swap` and
`raydium-clmm`: `Anchor.toml Cargo.* LICENSE README.md SECURITY.md client/ client_config.ini
docker-compose.yml package.json programs/ tests/ tsconfig.json`.

**Closed source: Stable AMM, LaunchLab, AMM Routing, Burn&Earn/LP Lock, Farm v3/v5/v6.**
Of these only LaunchLab has a published IDL; Stable AMM, Routing, Lock and the Farms have
neither source nor IDL. Their mechanism descriptions rest entirely on Raydium's prose.

**Deployed↔repo correspondence: NOT VERIFIED, with a negative result on record.** The OtterSec
verified-builds registry returns `is_verified: false` for AMM v4, CPMM, CLMM and LaunchLab.
CPMM's record points at commit `cfdb70a8ca9ea62bb5c304d4492ac0fc371ae8ce` with on-chain hash
`4ef0bbeca5a410b0054527d68379c4060e6f45bec471eaeb5d5302e85904fe1a` and an **empty**
`executable_hash`; `is_frozen: false` on all. This is not proof of divergence — only that no
registry attests to a match, and that Raydium's own claimed evidence ("expected hashes per
deploy in the repo releases section") does not exist, because there are no releases.

**Audits** (file listing from `raydium-docs/audit/`): Kudelski Q2 2021; OtterSec Q3 2022
(CLMM, staking, updated order-book AMM); MadShield Q2 2023 (orderbook AMM + OpenBook
migration); MadShield Q1 2024 (`raydium-cp-swap-v-1.0.0`); Halborn Q4 2024 (liquidity
locking); Halborn Q2 2025 (launch); Sec3 Q3 2025 (`cp_swap_pr55`); Sec3 Q2 2026
(`clmm_limitorder_dynamicfee`). **No audit exists for the 2026-07 OpenBook-removal upgrade,
nor for AMM Routing or the Stable AMM.**

### 4. EVIDENCE

All 2026-08-04.

1. https://docs.raydium.io/reference/program-addresses — program IDs; the open-source scoping quote.
2. https://docs.raydium.io/llms-full.txt — 1,796,214-byte raw markdown of the whole docs site; used as the verbatim source for docs quotes (the HTML path paraphrased and once mangled an address).
3. https://docs.raydium.io/reference/changelog/2026-07-22-amm-v4-openbook-removal — dated removal; the seven dead instruction tags; `WithdrawPnl`/`SetParams` breaking changes.
4. https://docs.raydium.io/products/amm-v4/accounts — "As of the 2026-07 upgrade, AMM v4's OpenBook / Serum dependency has been removed"; the inert legacy account table.
5. https://github.com/raydium-io/raydium-docs-v1/blob/main/AMM-v4-OpenBook-Removal-Upgrade-Notes.md — "removes the Serum/OpenBook dependency, all related CPIs, and the dead instructions"; "This upgrade does not change any live trading behavior".
6. GitHub REST API `repos/raydium-io/raydium-amm/commits?per_page=1` — HEAD `27f461dd…`, 2026-07-23, "Remove openbook dependency (#69)". **Independently re-run by this lane.**
7. Solana RPC `api.mainnet-beta.solana.com` `getAccountInfo` on 8 program IDs + ProgramData accounts — shared upgrade authority `FytDrVzDybM1TwFQPGb8qaxZR7dBCzNeqT3vtQsceZQK`, none null; `getBlockTime` on each `lastDeploySlot`.
8. Same RPC, `getAccountInfo` on ProgramData `A7ZG7ByDi8DpzT9Ab7CiXhvgYTJQmaDPJkMDoPitaCQV` — 1,406,384-byte ELF; zero `serum` strings; no OpenBook program ID; SPL Token ID present (control).
9. https://docs.raydium.io/ray/protocol-fees and /ray/ray-buybacks — the 84/12/4 and 88/12 splits; "12% of Raydium trading fees are used to buy back RAY."
10. https://docs.raydium.io/ray/treasury — collection/treasury/pool-creation addresses; row label "Bought-back RAY accumulation".
11. Solana RPC `getTokenSupply` on RAY `4k3Dyjzvzp8eMZWUXbBCjEvwSkkk59S5iCNLY3QrkX6R` → **554,997,631.209468**; `getTokenAccountsByOwner` on `DdHDoz94…` → ≈83,543,672 RAY. **Supply figure independently re-run by this lane.**
12. https://api-v3.raydium.io/main/cpmm-config (19 configs) and /clmm-config (18) — every config `protocolFeeRate 120000`, `fundFeeRate 40000`; `createPoolFee 150000000`; tiers 0.005%–4% / 0.01%–4%; `creatorFeeRate` 500–14,950.
13. https://docs.raydium.io/security/admin-and-multisig — "The upgrade authority for all programs is the 3/4 Squads multisig."; "Raydium has not set any program's upgrade authority to null."; 24h timelock claim.
14. Solana RPC `getAccountInfo` on `FytDrVzDybM1TwFQPGb8qaxZR7dBCzNeqT3vtQsceZQK` and `GThUX1Atko4tqhN2NaiTazWSeFWMuiUvfFnyJyUghFMJ` — both System-owned, zero data ⇒ threshold/timelock unverifiable.
15. https://verify.osec.io/status/{675kPX9M…, CPMMoo8L…, CAMMCzo5…, LanMV9sA…} — `is_verified: false`, `is_frozen: false` for all four. **CPMM response independently re-run by this lane**, including the empty `executable_hash`.
16. GitHub REST API on `orgs/raydium-io/repos` and per-repo `/commits`, `/tags`, `/releases`, `/contents` — licences, HEADs, and the zero-tags/zero-releases fact. **Licences and HEADs independently re-run by this lane.**
17. https://api.github.com/repos/raydium-io/raydium-docs/contents/audit (+ subdirs) — the audit file list.
18. https://raydium.medium.com/detailed-post-mortem-and-next-steps-d6d6dd461c3e — "The attacker compromised eight constant product liquidity pools on Raydium, totaling approximately ~4.4m USD"; the `SetParams` + `AmmParams::SyncNeedTake` vector.
19. https://github.com/raydium-io/dec_16_exploit — `Total Loss Per Vault.csv`; summed to $4,417,202.04 over nine pairs.
20. https://docs.raydium.io/products/launchlab/{overview,bonding-curve,global-config,platform-config} — three curve types; the graduation gate; "Graduate is permissionless"; `platform_scale + creator_scale + burn_scale = 1_000_000`.
21. https://docs.raydium.io/products/clmm/{ticks-and-positions,fees,accounts} — tick math; `TickArrayState` non-closability; position NFTs; `CollectFeeOn`; dynamic fee; `ObservationState`.
22. https://docs.raydium.io/products/cpmm/fees — "The creator fee is not a slice of the trade fee".
23. https://docs.raydium.io/security/oracle-and-token-risks — "Raydium's core products don't depend on external oracles for pricing — the pool state is the oracle."
24. https://docs.raydium.io/products/perps/index — "Raydium Perps is a separate product from the spot AMMs", powered by Orderly Network.
25. https://docs.raydium.io/user-flows/burn-and-earn — "Despite the name, the LP tokens / position NFT are locked in a program-owned escrow, not destroyed."
26. https://docs.raydium.io/reference/fee-comparison — the contradictory table (see §6).
27. https://api.llama.fi/protocols (filtered locally) — Raydium AMM $821.0M, rank 4.

**Blocked/failed:** `docs.raydium.io/raydium/protocol/developers/addresses` and
`/raydium/build/resources/program-addresses` both 404 — stale URLs still ranking in search
after a site reorganisation. Note also that `docs.raydium.io` is an AI-tooled rebuild
(source repo `raydium-docs-v1`, first commit 2026-05-07, shipping `AGENTS.md`, `llms.txt`,
`llms-full.txt` and an MCP server) and **contains internal contradictions** — see §6. Chain
state and `api-v3.raydium.io` were treated as the oracle and the docs as a hypothesis.

### 5. WHAT LOOKS UNNAMEABLE

- **A fossilised account layout retained as a compatibility shim.** `AmmInfo` still declares
  `open_orders`, `market`, `market_program`; v1 swap instructions still demand 17–18 accounts
  of which several are never read. The on-chain *type* is provably wider than the on-chain
  *semantics*, and the width is load-bearing for integrators. The corpus already gestures at
  this ("a mechanism that exists in the bytecode but is switched off") but the true situation
  is stranger and now dated: the mechanism was **deleted** and the *interface* kept.
- **Solana program upgrade authority as a distinct control primitive.** `Up` names a proxy
  delegating to a swappable implementation. Here the bytecode is replaced wholesale at the
  same address by a named authority, with no delegatecall, no implementation slot, and no way
  for an integrator to diff what changed. The corpus marks this FORCED and is right to.
- **A monotonically growing, irreversible state footprint as a design commitment.** CLMM tick
  arrays cannot be closed and their rent cannot be recovered even at zero initialised ticks;
  CPMM pools are never closed. Nothing names "state that can only be created".
- **Fee accrual currency fixed at pool creation.** `CollectFeeOn: Token0Only` means the fee
  may be taken out of swap *output* rather than input, changing the quoting equation by
  direction, immutably. No symbol distinguishes which leg a fee is skimmed from.
- **Buyback-and-hold.** Not a burn, not a distribution: the protocol accumulates its own
  governance token in an account it controls. `Fd` names distribution to a claim class;
  destruction is absent from the vocabulary; *accumulation* is a third thing and the one that
  actually happens here.
- **Launchpad issuance with a price-continuous graduation into a pool, triggered
  permissionlessly.** Three separable pieces: the virtual-reserve bonding curve, the threshold
  gate, and the fact that the transition is a public good anyone may fire. Only the contested
  `Bc` is near the first, and nothing is near the other two.
- **A transferable perpetual claim on a locked position's fee stream** (the Fee Key NFT), and
  a three-integer LP split that must sum exactly to 1,000,000 with one leg named "burn" that
  is actually an escrow.
- **A program that is deployed but for which no registry attests bytecode-source
  correspondence.** Verifiability is a property of the deployment, not the code, and the
  vocabulary has no way to record its absence.

### 6. DELTA vs the corpus record

- **Rank basis reproduces**: $821.0M today vs corpus $819.1M.
- **The corpus's OpenBook residue is now factually superseded, and by a datable event.** The
  corpus says "the OpenBook CLOB integration in AMM v4 is deactivated as of 2025 — the wiring
  survives as inert state … a mechanism that exists in the bytecode but is switched off". As
  of the **2026-07-22** upgrade the wiring does **not** survive in the bytecode: the deployed
  ELF contains no `serum` string and neither OpenBook program ID. What survives is the
  *account layout* and the v1 instruction arity. The residue is still real but it has changed
  register — from "dead code" to "dead interface", which is a different and arguably harder
  thing to name. The corpus's decision not to use `Ob` remains correct and is now
  unambiguously correct. (Ev. 3, 4, 5, 6, 8.)
- **The corpus's `Fd` marker says "a share of trading fees buys RAY" and files it with the
  "burn/buyback ambiguity" shared with Uniswap and PancakeSwap. Raydium is not in that
  family.** Uniswap destroys UNI; PancakeSwap destroys CAKE; Raydium **buys and holds** —
  ≈83.5M RAY sits in a protocol account and total supply is still 554,997,631 of a 555M max.
  Grouping the three erases the only difference that matters to a supply model. (Ev. 9, 10, 11.)
- **`Cl` is correctly present but the corpus omits that Raydium runs an on-chain TWAP.** CPMM
  and CLMM both maintain `ObservationState` ring buffers (CLMM stores cumulative *tick*),
  consumed by third-party lending protocols. `Tp` is absent from Raydium's element set and
  looks required — with the nuance that AMM v4, which holds the largest share of the TVL, has
  no observation account at all, so the symbol would apply to two of three programs. (Ev. 21, 23.)
- **The corpus does not record that only three of Raydium's nine programs are open source.**
  Stable AMM, AMM Routing, Burn&Earn/LP Lock and the three Farm programs have no public
  source; four of those have no IDL either. Any construction that claims to reproduce
  "Raydium" is reproducing a description, not a codebase, for a substantial part of it.
- **New residue: no verified builds.** OtterSec reports `is_verified: false` for all four
  checked programs, and the docs' claimed mitigation (per-deploy hashes in GitHub releases)
  is false — the program repos have zero releases and zero tags. (Ev. 15, 16.)
- **The docs contradict the chain and themselves, and a later lane must not treat
  docs.raydium.io as authoritative.** Three concrete instances: (i) `/reference/fee-comparison`
  says CPMM is "100% LP (protocol share configurable per AmmConfig, currently 0%)" and that
  AMM v4/CLMM's 12% goes "100% to treasury" — refuted by all 37 live configs and by
  `/ray/protocol-fees` on the same site; (ii) `/security/admin-and-multisig` says AMM v4 has
  had "zero upgrades in 18 months" and is "effectively frozen" — the chain shows a deploy on
  2026-07-22; (iii) the docs' history page dates the CPMM audit to "September 2024 — MadShield
  + OtterSec" and LaunchLab's to "October 2024 — OtterSec", where the actual audit directory
  holds MadShield Q1 2024 and Halborn Q2 2025. (Ev. 26, 13, 17.)
- **Fee tiers are wider than commonly quoted**: 19 live CPMM tiers spanning 0.005%–4% and 18
  CLMM tiers spanning 0.01%–4%, not the "0.01/0.25/1%" triple in circulation. (Ev. 12.)
- **Raydium Perps is not Raydium.** It is an Orderly Network CLOB behind Raydium branding.
  Any category-level statement about Raydium and liquidation must exclude it. (Ev. 24.)

---

## Fluid

### 1. WHAT IT DOES

Fluid presents one deposit and three products. A lender deposits a single asset and receives
an ERC-4626 `fToken`; a borrower opens a **vault** position — represented as an **NFT** —
depositing collateral and drawing debt against it; and a swapper trades against the DEX. What
makes it one system rather than three is that all of them draw balances from a single
**Liquidity Layer**, and that a vault position's collateral and debt can themselves *be* the
DEX's inventory. **Smart Collateral** is "a single range order" that is simultaneously lent
(earning supply yield), borrowable against, and deployed as AMM liquidity — one unit of
capital occupying three roles. **Smart Debt** is the inverse and has no analogue anywhere
else: the borrowed principal is the AMM's inventory, so trades route *through the debt* and
the trading fees pay the debt down; the docs state borrowers can end up "getting paid to
borrow". A swap is priced off `x·y=k` contracted into a governance-set range around a
**center price** that the pool itself shifts when a bound is breached; settlement is atomic
on-chain. A position ends by repaying and withdrawing, or by liquidation: if the
debt-to-collateral ratio crosses the vault's liquidation threshold, the position is not
individually seized — it sits in a *slot* keyed by its ratio, and the protocol liquidates
every position in that slot in one transaction, taking only the minimum needed to restore
health, with the liquidatable collateral exposed to DEX aggregators so that an ordinary
trader executes the liquidation as a side effect of a normal swap.

### 2. DESIGN

**Liquidity Layer.** "The Liquidity Layer serves as the foundation of Fluid upon which
various protocols can be built. It acts as a singular layer that consolidates liquidity
across protocols built on Fluid, eliminating the need for each protocol to independently
attract liquidity." Its stated key features are capital efficiency, **automated ceilings**
("dynamically adjusting debt/collateral ceilings … These limits adjust in real-time based on
utilization rates"), slot-based liquidation with penalties "as low as 0.1%", and LTVs up to
95%. The named limit parameters are Fluid's own: on the borrow side **Base Limit** ("the
minimum limit for a Vault's borrowing. The further expansion happens on this base"),
**Current Limit**, **Max Limit**, **Expand Percentage** ("the rate at which Limits would
increase or decrease over the given duration"), **Expand Duration**, **Borrowable**; on the
withdraw side Base Limit, Current Limit ("if it is $0, that means 100% of the users can
withdraw"), Expand Percentage, Expand Duration, **Withdrawable**, and **Withdrawal Gap**
("safety non-withdrawable amount to guarantee liquidations"). In the repo the layer is
`contracts/liquidity/` with `adminModule/`, `userModule/`, `common/`, `proxy.sol` and
`interfaces/`; the admin module's abstracts are `GovernanceModule`, `GuardianModule`,
`AuthModule`, `AuthInternals`.

**DEX pool math (v1, `dexT1`).** "The architecture of the DEX pool is very similar to a
combination of Uniswap v2 & Uniswap v3, otherwise known as a single auto rebalancing range
order." The docs' own parameter glossary: **AMM Curve** — "The DEX uses the x\*y=k curve, but
the liquidity is contracted within a range that is set by governance upon pool creation";
**Center Price** — "the price at which the Pool rebalances itself once the Upper or Lower
bounds are breached by the pool price"; **Lower/Upper Range**; **Lower/Upper Bound Price** —
"the threshold that, when breached, triggers the rebalancing"; **Center Min/Max Price** — the
bounds on how far the center may move; **Shift Time** — "the time taken to complete the
rebalancing". The DexLite resolver structs corroborate the mechanism by name:
`CenterPriceShift`, `RangeShift`, `ThresholdShift`, `DexVariables`. So the recentering is a
*timed shift* between two configurations, not an instantaneous jump, and it is bounded by
governance-set min/max.

**DEX v2 — and this is the headline.** Announced 2026-05-09 and **deployed**. "At its core,
Fluid DEX v2 runs on a **singleton contract** built atop the Fluid Liquidity Layer … Governance
can deploy **infinite DEX types**, each with its own logic and math." Four types at launch:
Type 1 = DEX v1 Smart Collateral, Type 2 = DEX v1 Smart Debt, Type 3 = **Smart Collateral
Range Orders** ("Like Uniswap v3 range orders, but enhanced — the liquidity earns lending APR
by default and can be used as collateral"), Type 4 = **Smart Debt Range Orders** ("Create
range orders on the debt side by borrowing assets — a completely new primitive"). Advertised
features include **Hooks (inspired by Uniswap v4)**, **Flash Accounting (inspired by Uniswap
v4)**, on-chain dynamic fees, and on-chain limit orders that "earn lending APR while waiting
to be filled". The live integration docs make the shape concrete: `DexKey` is
`{token0, token1, fee, tickSpacing, controller}` — i.e. **ticks and a per-pool `controller`
address, which is Fluid's hook** — `dexType` 3 = D3 and 4 = D4, with bidirectional `getDexId`
/ `getDexKey`, and pool state exposing `currentTick`, `currentSqrtPriceX96`,
`activeLiquidity`, `lpFee`. Pool creation is currently **permissioned**: "DEX v2 operates with
pools that are permissioned and listed on the Fluid Money Market … Each pool has been approved
through Fluid governance", with `getD3PermissionedDexes()` / `getD4PermissionedDexes()` for
discovery and a stated future transition to permissionless pools discovered via
`LogInitialize(dexType, dexId, dexKey, sqrtPriceX96)`. A `FluidDexV2Router` is deployed on
Polygon at `0x713fD04a47Db41AB5684AEC2A2063d5278A53616` (given in the docs' own worked example).

**DEX Lite** exists as a distinct product (`contracts/protocols/dexLite/`, its own resolver
and integration page). Its precise differentiation from `dexT1` was **not** established from a
primary source by this lane → **UNKNOWN**.

**Vaults.** `contracts/protocols/vault/` with `vaultT1/ vaultT2/ vaultT3/ vaultT4/` plus
`vaultT1_not_for_prod/`, `factory/`, `rewards/`, `borrowRewards/`, `vaultTypesCommon/`. The
repo README states the taxonomy exactly: "Type 1: Normal Collateral & Normal Debt; Type 2:
Smart Collateral & Normal Debt; Type 3: Normal Collateral & Smart Debt; Type 4: Smart
Collateral & Smart Debt." Each position is an NFT that "can be moved freely if needed. Each
NFT comprises the Vault including its debt and collateral assets."

**Liquidation.** "When users initiate a position by opening a vault within the protocol, their
debt and collateral are calculated into a ratio, which is then assigned to a specific slot …
Drawing inspiration from Uniswap v3's slot-based liquidity". When the ratio crosses the
threshold "the protocol aggregates all vaults in that slot for liquidation in a single
transaction. Afterward, the system recalibrates the remaining vaults, adjusting their debt
ratio positions down to the next slot." Two further properties: **minimal-impact** — "the
Vault protocol only liquidates the minimum necessary to restore the account to a healthy
state"; and **trader-as-liquidator** — the liquidatable collateral is exposed in DEX
aggregator routes (1inch, Paraswap, 0x are named) at a natural discount, so "traders
participate in the liquidation process indirectly by completing normal swaps", and Fluid "is
less reliant on Keepers". The user-facing FAQ confirms the consequence: "your position is not
individually liquidated but instead a portion of all at risk positions is liquidated, all at
once in one transaction." There is also a **Max Liquidation Threshold**: "When a vault passes
the max liquidation threshold it is liquidated automatically." **Caveat on the 0.1% figure**:
the Liquidity Layer page says penalties "as low as 0.1%", while the user docs show the ETH/USDC
vault at **1%** — 0.1% is a floor claim, not a typical value.

**Oracles.** Two distinct things. (i) The DEX has its **own** oracle: "Fluid's DEX has an
inbuilt most optimized TWAP oracle. It allows you to fetch the last 5 min data in <15k gas;
Last 15 min data in <30k gas", and it "returns additional data like: maxima & minima during
that time frame". (ii) Vault pricing uses an external stack, evidenced by the contract tree:
`ChainlinkOracleImpl`, `RedstoneOracleImpl`, `UniV3OracleImpl`, `PegOracleImpl`,
`FallbackOracleImpl`, `UniV3CheckCLRSOracle` (a Uniswap-v3-checked Chainlink/Redstone
fallback), plus `fluidCappedRate*` and `fluidCenterPrice*` families
(`GenericCenterPrice`, `StaticCenterPrice`, `ChainlinkCenterPriceL2`,
`CappedRateInvertCenterPrice`) and DEX-specific oracles
(`DexSmartColCLOracle`, `DexSmartDebtCLOracle`, `DexSmartT4CLOracle`, and Peg/L2 variants).
Some vaults deliberately do not use a market price at all: "the weETH/wstETH Vault uses
Contract Backing for the liquidation oracle."

**Control plane.** Governance is a **Compound GovernorBravo fork**: `Instadapp/fluid-governance`
README states "Forked from Compound Governance", and `contracts/` holds
`GovernorBravoDelegate.sol`, `GovernorBravoDelegator.sol`, `Timelock.sol`, `TokenDelegate.sol`,
`TokenDelegator.sol` plus a `payloads/` directory. Upgradeability is explicit and pervasive:
`contracts/infiniteProxy/` implements an "InfiniteProxy" with `AdminInternals` and
`CoreInternals`, and the vault deployment recipe in the repo README routes configuration
through "the fallback which directs the call to adminModule". A guardian exists at the
liquidity layer (`GuardianModule`). Fine-grained authority is delegated to a fleet of named
**Auth/Config handler** contracts rather than one admin: `LimitsAuth`, `LimitsAuthDex`,
`WithdrawLimitAuth`, `WithdrawLimitAuthDex`, `RangeAuthDex`, `DexFeeAuth`, `RatesAuth`,
`LiquidityTokenAuth`, `CollectRevenueAuth`, `VaultFeeRewardsAuth`, plus auto-config handlers
(`ExpandPercentHandler`, `MaxBorrowHandler`, `BufferRateHandler`, `EthenaRateHandler`,
`DexFeeHandler` with a `DynamicFee` abstract). Exact thresholds, timelock delay and the
identity of any team multisig were **not** confirmed at a primary source by this lane →
**UNKNOWN**.

**Fees and value return.** "Trading fees — Pools on the DEX can be set to any trading fee by
governance voting." "Revenue Cut — Revenue Cuts can be turned on through governance voting and
could consist of a cut from trading fees and/or a fee from any Smart Vault." A **buyback is
implemented on-chain**: the periphery contains `Periphery/Buyback/` with `FluidBuyback`,
`FluidBuybackProxy`, `FluidBuybackCore` and a `ReentrancyGuard`. Whether the buyback is
currently *running* is **UNKNOWN** — secondary sources describe a 2026 pause following a
bad-debt event, but this lane did not reach a Fluid primary source for that and it must not
be asserted.

**Chains.** `deployments/` in the public repo contains `mainnet/`, `arbitrum/`, `base/`,
`bnb/`, `polygon/`, **`plasma/`**. There is additionally a separate
`Instadapp/fluid-solana-programs` (Rust) repo and a `jupiter-lend` repo, indicating a non-EVM
deployment surface.

### 3. REPO

**Canonical: https://github.com/Instadapp/fluid-contracts-public.**
Default branch `main`, HEAD **`a9949b48ba1247d4f478cd0acb40896b5c8bf3f8`, 2026-03-04**,
**no tags**. Language Solidity. Licence: GitHub reports `NOASSERTION`; the `LICENSE` file is
**Business Source License 1.1** — Licensor "Instadapp Labs", Licensed Work "Fluid Contracts
… (c) 2023 Instadapp Labs", Additional Use Grant "may be utilized for educational purposes
only … expressly prohibits production use", **Change Date 2027-12-19**, Change License
**GPL-2.0-or-later**.

Top level: `contracts/ deployments/ dexMath/ docs/ test/ lib/ Makefile foundry.toml
hardhat.config.ts remappings.txt funding.json package.json tsconfig.json`.
`contracts/` = `config/ deployer/ infiniteProxy/ libraries/ liquidity/ mocks/ oracle/
periphery/ protocols/ reserve/`.
`contracts/protocols/` = `dex/ dexLite/ lending/ steth/ vault/`;
`contracts/protocols/dex/` = `factory/ interfaces/ poolT1/ smartLending/ error.sol
errorTypes.sol`; `poolT1/` = `adminModule/ common/ coreModule/`;
`dexLite/` = `adminModule/ core/ other/`.

**A load-bearing repo finding: DEX v2 is not in the public repository.** At HEAD (2026-03-04)
`contracts/protocols/dex/` contains only `poolT1` and `smartLending`; there is no `dexV2`.
Yet the technical docs reference `contracts/periphery/dexV2/router/main.sol` and publish a
deployed `FluidDexV2Router`. So the public repo is **~5 months stale relative to the deployed
system**, and the protocol's current flagship is documented but not published. This is the
single most important repo fact for a later lane: a construction targeting "Fluid DEX" from
the public source is targeting v1.

Other repos: `Instadapp/fluid-governance` (Solidity, no licence declared, pushed 2026-08-03),
`Instadapp/fluid-solana-programs` (Rust, NOASSERTION, 2026-02-11),
`Instadapp/fluid-mintlify-docs` (MDX, MIT), `Instadapp/fluid-deployments` (JavaScript).
`Instadapp/fluid-contracts` does not exist (404).

**Deployed↔repo correspondence: UNKNOWN.** Not verified by this lane, and made harder by the
staleness above. Audit reports are published as docs pages: PeckShield (pre-launch),
Statemind (Fluid, and Liquidity Layer updates), MixBytes (Vault Protocol, Dex Protocol,
Liquidity Layer), Cantina (Dex Protocol).

### 4. EVIDENCE

All 2026-08-04.

1. https://fluid.guides.instadapp.io/llms.txt — the full documentation index (used to locate every `.md` below).
2. https://fluid.guides.instadapp.io/dex-protocol/dex-on-fluid.md — "introducing new primitives in **Smart Debt** and **Smart Collateral**"; "up to $39 in liquidity per $1 in TVL".
3. https://fluid.guides.instadapp.io/dex-protocol/smart-collateral.md — "Smart Collateral is a single range order"; lend / borrow-against / deploy-as-AMM-liquidity; "a combination of Uniswap v2 & Uniswap v3, otherwise known as a single auto rebalancing range order".
4. https://fluid.guides.instadapp.io/dex-protocol/smart-debt.md — "the first time debt can be transformed into a productive asset by using it as liquidity for the DEX"; "the trading fees are used to pay down the debt"; "even having the possibility of getting paid to borrow".
5. https://fluid.guides.instadapp.io/dex-protocol/protocol-details.md — the parameter glossary: AMM Curve ("x\*y=k … contracted within a range that is set by governance upon pool creation"), Center Price, Lower/Upper Range, Lower/Upper Bound Price, Center Min/Max Price, Shift Time; the borrow/withdraw limit parameters incl. Withdrawal Gap; the three vault appearances.
6. https://fluid.guides.instadapp.io/dex-protocol/oracles.md — "Fluid's DEX has an inbuilt most optimized TWAP oracle"; 5 min <15k gas, 15 min <30k gas; maxima & minima.
7. https://fluid.guides.instadapp.io/dex-protocol/fees.md — trading fee set by governance; Revenue Cut turned on by governance.
8. https://fluid.guides.instadapp.io/liquidity-layer/unifying-liquidity.md — the Liquidity Layer definition; "Automated Ceilings … adjust in real-time based on utilization rates"; "penalties as low as 0.1%"; "up to 95% LTV".
9. https://fluid.guides.instadapp.io/liquidity-layer/protocols-on-fluid.md — the three protocols; "An innovative protocol with a single dynamic range order".
10. https://fluid.guides.instadapp.io/vault-protocol/advanced-liquidation-mechanism.md — the slot-based mechanism; "aggregates all vaults in that slot for liquidation in a single transaction"; minimal-impact; trader-as-liquidator via 1inch/Paraswap/0x.
11. https://fluid.guides.instadapp.io/vault-protocol/advanced-liquidation-mechanism/vault-liquidation.md — ETH/USDC vault at **1%** penalty; "your position is not individually liquidated but instead a portion of all at risk positions is liquidated, all at once in one transaction"; Max Liquidation Threshold; "the weETH/wstETH Vault uses Contract Backing for the liquidation oracle".
12. https://fluid.io/blog/protocol-introducing-fluid-dex-v2 (dated 2026-05-09, authors DMH / Samyak Jain) — DEX v1 launched 2024-10-29; DEX v2 singleton; "Governance can deploy infinite DEX types"; the four launch types; Hooks and Flash Accounting "inspired by Uniswap v4"; on-chain limit orders; the permissionless-expansion tiers.
13. https://docs.fluid.instadapp.io/integrate/dex-v2-swaps.html — `DexKey {token0, token1, fee, tickSpacing, controller}`; `dexType` 3/4 = D3/D4; `FluidDexV2Router` at `0x713fD04a47Db41AB5684AEC2A2063d5278A53616` (Polygon); `currentTick`/`currentSqrtPriceX96`/`activeLiquidity`/`lpFee`; "pools that are permissioned and listed on the Fluid Money Market … approved through Fluid governance"; `getD3PermissionedDexes()`, `getD4PermissionedDexes()`, `LogInitialize` for future permissionless discovery. *(Retrieved with scrapling; the page is a VitePress SPA.)*
14. https://docs.fluid.instadapp.io/ — the contract index: `Config/{LimitsAuth, LimitsAuthDex, WithdrawLimitAuth, WithdrawLimitAuthDex, RangeAuthDex, DexFeeAuth, DexFeeHandler(+DynamicFee), RatesAuth, LiquidityTokenAuth, CollectRevenueAuth, VaultFeeRewardsAuth, ExpandPercentHandler, MaxBorrowHandler, BufferRateHandler, EthenaRateHandler}`; `InfiniteProxy`; `Liquidity/AdminModule/{GovernanceModule, GuardianModule, AuthModule}`; the oracle families; `Periphery/Buyback/{FluidBuyback, FluidBuybackProxy, FluidBuybackCore}`; `Resolvers/DexLite` structs `CenterPriceShift`, `RangeShift`, `ThresholdShift`.
15. GitHub REST API `repos/Instadapp/fluid-contracts-public` (+ `/commits`, `/tags`, `/license`, `/contents/...`) — HEAD `a9949b48…` 2026-03-04, no tags, Solidity; the full `contracts/` tree; the absence of a `dexV2` directory.
16. GitHub contents API `repos/Instadapp/fluid-contracts-public/contents/LICENSE` — BUSL-1.1, Licensor Instadapp Labs, "educational purposes only", Change Date **2027-12-19**, Change License GPL-2.0-or-later.
17. GitHub contents API `.../contents/contracts/protocols/vault/README.md` — the four vault types verbatim; the `adminModule` fallback deployment recipe.
18. GitHub contents API `repos/Instadapp/fluid-governance/contents/README.md` and `/contents/contracts` — "Forked from Compound Governance"; `GovernorBravoDelegate.sol`, `GovernorBravoDelegator.sol`, `Timelock.sol`, `TokenDelegate.sol`, `TokenDelegator.sol`, `payloads/`.
19. GitHub contents API `.../contents/deployments` — `mainnet/ arbitrum/ base/ bnb/ polygon/ plasma/`.
20. GitHub `orgs/Instadapp/repos` — `fluid-solana-programs` (Rust), `fluid-governance`, `jupiter-lend`, `fluid-mintlify-docs`; `Instadapp/fluid-contracts` returns 404.
21. https://fluid.guides.instadapp.io/ — the audit index: PeckShield, Statemind (×2), MixBytes (Vault, Dex, Liquidity Layer), Cantina (Dex).
22. https://api.llama.fi/protocols (filtered locally) — Fluid $282.8M in category `Dexs` (Fluid DEX 282.8 + Fluid DEX Lite 0.0), rank 5.

**Blocked/failed:** `blog.instadapp.io/fluid-dex/` returns HTTP 522 (origin down) — the DEX v1
announcement post is currently unreachable; the fluid.io mirror of the v2 post was used
instead. `docs.fluid.instadapp.io/contracts-addresses.html` and `/contracts/addresses.html`
are 404s; the deployed-address index was not located, so all addresses here come from worked
examples in the docs.

### 5. WHAT LOOKS UNNAMEABLE

- **One position occupying two registers at once.** The corpus already calls this out and it is
  confirmed and, if anything, understated: Smart Collateral is a lending deposit *and* AMM
  inventory *and* borrowing base; Smart Debt is borrowed principal *that is* AMM inventory. The
  vocabulary partitions "Pool pricing" and "Credit" into disjoint registers. But note the
  sharper form: with Smart Debt, **the swapper is a third party transacting against someone
  else's liability**, and the trade *reduces* that liability. There is no symbol for a trade
  whose counterparty inventory is a debt.
- **A shared liquidity layer several products register against.** Structurally identical to
  PancakeSwap Infinity's Vault. One missing symbol, two appearances in this lane.
- **A limit that expands on a schedule.** Expand Percentage × Expand Duration over a Base
  Limit, with a Current Limit that walks toward a Max Limit as utilisation changes. This is a
  *rate-limited capability*, not a cap. `Gp` is a switch, `Tg` is a delay; neither is a
  continuously-relaxing bound, and the Withdrawal Gap ("safety non-withdrawable amount to
  guarantee liquidations") is a reserved capacity for a *future* operation, which is also
  unnamed.
- **A profit-independent, governance-bounded, time-smeared recentering.** The center price
  shifts when a bound is breached, moves over Shift Time rather than instantly, and cannot
  leave `[Center Min Price, Center Max Price]`. `Cl` presumes user-chosen static ticks; `Pm`
  presumes an externally quoted price. This is a third thing — and note it is *not* Curve's
  profit-gated repeg either, which makes "recentering" a family with at least two members.
- **Liquidation of an equivalence class rather than a position.** Positions are bucketed by
  ratio into slots; a slot is liquidated whole; survivors are recalibrated into the next slot.
  `Li` names "third parties paid to close positions" — here the unit closed is not a position,
  the closer is not paid a bounty but takes a swap discount, and `Ad`'s "rank-ordered forced
  close" is close in spirit but wrong in mechanism (there is no ranking, there is a quantised
  key).
- **Liquidation as an externality of ordinary trading.** The liquidatable collateral is placed
  in aggregator routes so that a retail swapper liquidates without knowing it. No symbol
  expresses "the incentive is delivered as improved execution to an unaware third party".
- **A `controller` per pool in DEX v2** — Fluid's hook, named differently, sitting inside the
  pool key alongside `tickSpacing`. Third protocol in this lane with an extension point in the
  settlement path and a third naming convention (Uniswap: `hooks` in the address; PancakeSwap:
  bitmap in `parameters`; Fluid: `controller` in the `DexKey`).
- **Governance that can mint new pricing *engines***, not just new pools: "Governance can
  deploy infinite DEX types, each with its own logic and math."
- **A fee that nets against an interest expense inside one accounting unit** — the corpus's
  fourth residue item, confirmed by "the trading fees are used to pay down the debt".

### 6. DELTA vs the corpus record

- **Rank basis reproduces**: $282.8M today vs corpus $283.0M; DefiLlama also lists a
  `Fluid DEX Lite` line at $0.0M, which the corpus does not mention.
- **The corpus describes DEX v1 and Fluid is running DEX v2.** DEX v2 was announced
  2026-05-09 and is deployed (permissioned pools, a live `FluidDexV2Router`). Four of the
  corpus's Fluid claims move as a result:
  (i) the `Cl` FORCED marker — "Fluid's curve is a single self-rebalancing moderate-width
  range … Cl names user-owned static ticks, which Fluid does not have — there are no per-user
  ranges to name" — is **now wrong for v2**, whose D3/D4 types are explicitly "range orders …
  Like Uniswap v3 range orders" with `tickSpacing` in the pool key and `currentTick` in pool
  state;
  (ii) the residue item "no element for an auto-rebalancing range that recenters … Cl presumes
  a user-chosen static range" survives only for v1/Type-1/Type-2 pools;
  (iii) Fluid now shares the **hook** residue with Uniswap and PancakeSwap (the `controller`
  field), which the corpus does not record for Fluid at all;
  (iv) Fluid now shares the **flash-accounting** residue too. (Ev. 12, 13.)
- **`Tp` is missing from Fluid's element set and looks required.** The DEX ships its own
  inbuilt TWAP oracle — and one that returns *maxima and minima* over the window, which is
  strictly more than `Tp` names. (Ev. 6.)
- **The `Pl` FORCED marker is right but the corpus's justification can be sharpened.** The
  corpus says "a third party (the swapper) is transacting against that debt, which `Pl` cannot
  express" — the docs confirm the stronger fact that the trade *pays the debt down*, so the
  swapper is not merely transacting against the liability but amortising it. (Ev. 4.)
- **`Li` is present in the corpus's element set but the mechanism is not incentivised
  liquidation in the ordinary sense.** No keeper bounty; the reward is execution improvement to
  an aggregator user. And the unit liquidated is a *slot*, not a position. Both the payment
  channel and the unit differ from what `Li` names. (Ev. 10, 11.)
- **The 0.1% liquidation-penalty figure needs a qualifier.** The Liquidity Layer page says "as
  low as 0.1%"; the user docs show ETH/USDC — "the most common borrowing vault" — at **1%**.
  Any paper quoting 0.1% must quote it as a floor. (Ev. 8, 11.)
- **`Ex` is justified and should be strengthened, not weakened.** Fluid's oracle stack is a
  fallback lattice (`UniV3CheckCLRSOracle` = a Uniswap-v3-checked Chainlink/Redstone fallback,
  plus `FallbackOracleImpl`, `PegOracleImpl`, capped-rate and center-price families), and at
  least one vault uses contract-backed pricing with no market price at all. `Ex` names
  "push/pull/medianizer"; a *checked fallback lattice* is a different object. (Ev. 11, 14.)
- **`Up` is correct and under-stated**: the repo ships a contract literally named
  `infiniteProxy`, and vault configuration is performed *through* the proxy fallback into an
  admin module. `Gp` is likewise correct — `GuardianModule` exists by name. (Ev. 14, 15, 17.)
- **New: an on-chain buyback contract.** `Periphery/Buyback/{FluidBuyback, FluidBuybackProxy,
  FluidBuybackCore}` exists in the deployed contract index, which puts Fluid in the same
  value-return family as the other four — and the corpus records no value-return element for
  Fluid at all (no `Fd`, no `Em`). Whether the buyback is currently active is **UNKNOWN**. (Ev. 14.)
- **New: the public repo is stale by ~5 months and does not contain the flagship.** HEAD
  2026-03-04, no `dexV2` directory, while the docs reference
  `contracts/periphery/dexV2/router/main.sol`. (Ev. 15.)
- **Chain surface is wider than "Ethereum"**: `deployments/` covers mainnet, Arbitrum, Base,
  BNB, Polygon and **Plasma**, and a separate `fluid-solana-programs` repo exists. The one
  deployed DEX v2 address the docs expose is on **Polygon**, not mainnet. (Ev. 19, 20, 13.)
- **Licence is BUSL-1.1 with Change Date 2027-12-19**, not open source today, and the
  Additional Use Grant is *educational purposes only* — relevant to any claim that a
  construction "reimplements" Fluid. (Ev. 16.)

