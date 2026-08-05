# Stage 1 research — category 03, CDP / collateral-backed stablecoins

Lane: Sky (Sky Lending, ex-MakerDAO) · Ethena (USDe / sUSDe) · USDD · Lista CDP · Liquity (V1 + V2).
Researcher: stage-1 lane agent. All access dates **2026-08-04** unless a line says otherwise;
GitHub API reads were taken 2026-08-04/05 UTC and some `pushed_at` values therefore read 2026-08-05.

**Source quality for this category is unusually good at one end and unusually bad at the other, and
the split is not where you would expect it.** Four of the five publish a per-contract technical
documentation site *and* a live on-chain registry or address list, so the mechanism can be read at
the level of parameter names (`buf`, `tail`, `cusp`, `chip`, `tip`, `chost`, `hop`, `bump`, `hump`)
rather than at the level of marketing prose. Sky is the best-documented protocol in the entire
corpus: `developers.skyeco.com` (the redirect target of the old `docs.makerdao.com`) documents Vat,
Jug, Vow, OSM, Chief, Pause and Liquidations 2.0 to the function level, and the on-chain ChainLog
publishes 513 live keys, so *every* claim about which modules exist is checkable against the chain
rather than against a blog. Liquity's `liquity/bold` README is effectively a specification, including
a 26-item known-issues register. Against that, three specific holes are load-bearing and are marked
UNKNOWN below: (1) **USDD's CDP core has no locatable public repository** — the only Solidity repo
under its GitHub org is the PSM, and the vat/dog/clip/jug/spot/median/osm fork is unpublished, so
"open-source code" as the docs claim it could not be confirmed; (2) **Ethena's economically decisive
components are not code at all** — the hedging system, the price service, the order router and the
custodial mirroring are off-chain and closed, and the only public snapshot of even the on-chain
contracts is an *archived* 2023 audit-contest repo; (3) **Lista's live $324M CDP is served by an
archived, unlicensed repository** named after a discontinued product (Helio), while all current
engineering happens in other repos that do not contain the CDP core. One access note: `docs.sky.money`
returns 403 to plain fetches and its `robots.txt` carries `User-agent: ClaudeBot / Disallow: /` with
`Content-Signal: ai-train=no, use=reference`; it also turns out to be Sky's *legal* documentation, not
its protocol documentation. Everything below for Sky comes from `developers.skyeco.com`
(`robots.txt`: `User-agent: * / Allow: /`), from AGPL-3.0 source in `github.com/sky-ecosystem`, and
from live chain reads. Numeric rate values marked "read on-chain" were obtained by `eth_call` against
a public RPC and are stated with the raw per-second ray so a later stage can recompute them.

---

## Sky (Sky Lending, ex-MakerDAO)

### 1. WHAT IT DOES

A user locks an approved collateral asset into a Vault (an `urn` under a collateral type, `ilk`) and
draws USDS — or the legacy DAI — as a debt liability against it, subject to a per-ilk debt ceiling
(`line`), a global ceiling (`Line`), a per-vault debt floor (`dust`) and a price-with-safety-margin
(`spot`) that fixes the maximum debt per unit of collateral. The debt is not a fixed sum: it accrues
a Stability Fee continuously, implemented as a per-second compounding `rate` accumulator that the Jug
advances and the Vat folds across every vault of that ilk at once. The peg is defended from four
directions simultaneously — the Stability Fee contracts supply by making debt expensive; the Sky
Savings Rate paid on sUSDS creates demand by making the liability attractive to hold; the LitePSM
offers a 1:1, currently fee-free swap between USDC and USDS/DAI so the market can arbitrage either
side of par; and liquidation removes vaults whose collateral no longer covers their debt. Settlement
of an unsafe vault is a Dutch auction: any keeper calls `Dog.bark`, which confiscates the collateral,
books the debt to the Vow and kicks a Clipper auction that starts above the oracle price and descends
along an Abacus curve until someone takes it, with the keeper paid a flat `tip` plus a proportional
`chip` and the vault owner charged a `chop` penalty. A position ends one of two ways: the borrower
repays principal plus accrued fee and frees the collateral, or the auction clears and any surplus
collateral returns to them. The system itself ends through Emergency Shutdown (`MCD_END`), a global
settlement that fixes prices and lets every holder claim collateral directly — a path Sky's own docs
now file under "archive". Two adjacent products share the same core: the Staking Engine, where SKY is
locked as collateral to borrow USDS while retaining delegable voting power, and stUSDS, an "Expert"
token whose holders take a larger share of system risk to fund that SKY-backed borrowing.

### 2. DESIGN

**Core accounting.** `Vat` (`MCD_VAT` 0x35D1b3F3D7966A1DFe207aa4514C12a259A0492B) holds `ilks`
(`Art`, `rate`, `spot`, `line`, `dust`), `urns` (`ink`, `art`), `gem`, `dai`, `sin`, and the globals
`debt`, `vice`, `Line`. Its operations are `frob` (adjust a vault), `fork` (split/merge), `grab`
(liquidate), `heal`/`suck` (cancel/create unbacked dai), `fold` (advance the rate accumulator),
`slip`/`flux`/`move`. The documented central invariant is "Dai cannot exist without collateral", with
total `debt` equal to `vice` plus the sum over ilks of `Art × rate`. Collateral enters through Join
adapters; `Spot` reads the OSM and writes `ilk.spot`.

**Truth.** One `OSM` per collateral, `hop` = one hour, `peek()` (current), `peep()` (next), `poke()`
(advance and fetch), a `wards` mapping for admin and a `buds` whitelist for readers, with `stop()` and
`void()` as kill switches. The docs disclose a known timing weakness: `poke()` becomes callable when
`block.timestamp / hop` increments, not a full `hop` after the last call. Feeds are the `PIP_*` keys
in the ChainLog (`PIP_ETH`, `PIP_WSTETH`, `PIP_WBTC`, `PIP_SKY`, `PIP_ALLOCATOR`, the RWA pips).

**Rate policy — and this is the part the corpus record does not have.** `Jug` (`MCD_JUG`) accrues
`base + duty` per ilk via `drip(ilk)` → `Vat.fold`, with the documented warning that
`rate(base + duty) ≠ rate(base) + rate(duty)`. `Pot` (`MCD_POT`) pays the DSR on DAI via `chi`.
sUSDS pays the SSR via its own `chi` and is ERC-4626 with real-time share/asset conversion even
between `drip`s, no fees, and fees that "cannot be enabled on this route in the future"; it is an
ERC-1822 UUPS proxy over ERC-1967 storage. **On top of all three sits `MCD_SPBEAM`
(0x36B072ed8AFE665E3Aa6DaBa79Decbec63752b22), the Stability Parameter Bounded External Access
Module** — a deployed contract whose sole purpose is to let a *facilitator* set `duty`, `dsr` and
`ssr` directly, in batches, without an executive spell, bounded by governance-configured per-id
`min`, `max` and `step` (max change per update) and a `tau` timelock, with `SPBEAM_MOM`
(0xf0C6e6…) able to disable it without the GSM delay and `EMSP_SPBEAM_HALT` as a pre-deployed
circuit breaker. Rates read live on-chain 2026-08-04: `Pot.dsr` = 1000000000393915525145987602 ray
(≈1.25%/yr), `sUSDS.ssr` = 1000000001096988989836188433 ray (≈3.52%/yr), `Jug.base` = 0 (the whole
fee is per-ilk `duty`), `stUSDS` rate = 1000000001940295800728849590 ray (≈6.31%/yr).

**Liquidation (Liquidations 2.0).** `Dog` (`MCD_DOG` 0x1359…) with `bark()`, a global `Hole` and
per-ilk `hole` capping simultaneous auction exposure, running totals `Dirt`/`dirt`, and the penalty
`chop`. One `Clipper` per ilk: `kick()` starts at OSM price × `buf`; `take()` buys atomically at the
current descending price with an optional `clipperCallee` callback (so bidders need no capital);
`redo()` resets an auction that has run past `tail` or fallen below `cusp`. `chost` = `ilk.dust ×
ilk.chop` prevents dust remainders. Price descent is an Abacus contract: `LinearDecrease`,
`StairstepExponentialDecrease` or `ExponentialDecrease`. Keeper incentives are the flat `tip` plus
proportional `chip`, paid from the Vow, and the docs explicitly warn that mis-calibration enables
farming attacks. A four-stage circuit breaker (`CLIPPER_MOM`, `EMSP_GLOBAL_CLIP_BREAKER`) escalates
from "all enabled" to "no new liquidations" to "no resets" to "complete freeze". Stated invariants:
Σ per-ilk `dirt` = global `Dirt`; auction collateral ≤ Vat `gem` balances.

**Balance sheet.** `Vow` (`MCD_VOW` 0xA950…) queues bad debt as `sin[timestamp]` for `wait` seconds,
released by `flog`; `heal` and `kiss` cancel surplus against debt; `bump` is the surplus-auction lot,
`hump` the surplus buffer that must be exceeded first, `sump` the debt-auction lot and `dump` the
starting governance-token offer. Both auction paths are still deployed: `MCD_FLAP`
(0x374D9c3d5134052Bc558F432Afa1df6575f07407) and **`MCD_FLOP`
(0xA41B6EF151E06da0e34B009B86E828308986736D)**.

**Smart Burn Engine.** `MCD_SPLIT` (0xBF7111…) is the Splitter: every `hop` seconds it withdraws
`vow.bump` of USDS and divides it — a `burn` fraction to the underlying flapper, the remainder to a
farm/rewards contract. `FlapperUniV2` swaps USDS for the gem on Uniswap v2 and then deposits *both*
sides back as LP to a receiver; `FlapperUniV2SwapOnly` just buys and forwards. `want` bounds
acceptable slippage against a reference oracle `pip` (`FLAP_SKY_ORACLE` 0xc2ffbb…). `SPLITTER_MOM`
(0xF51a07…) and `EMSP_SPLITTER_STOP` can stop it without governance delay.

**Peg-swap.** `MCD_LITE_PSM_USDC_A` (0xf6e72Db5454dd049d0788e411b06CfAF16853042) with its `POCKET`
(0x3730…), `JAR`, `IN_CDT_JAR`, `WRAPPER_USDS_LITE_PSM_USDC_A` and `LITE_PSM_MOM`; swaps run against
a pool of pre-minted DAI/USDS so a swap is two ERC-20 transfers rather than a Vat interaction. `tin`
and `tout` are **not activated** for either DAI↔USDC or USDS↔USDC, but "could change in the future".
Legacy `MCD_PSM_USDC_A`, `MCD_PSM_PAX_A`, `MCD_PSM_GUSD_A` remain in the ChainLog.

**Allocators / Sky Stars.** Each Star gets a unique `ilk` in the Vat backed by `AllocatorOracle`,
which returns a **fixed 1:1 price** so that a huge nominal collateral balance makes the debt ceiling
reachable. `AllocatorVault` lets operators `draw`/`wipe` USDS to and from an `AllocatorBuffer`;
`AllocatorRoles` is a ds-roles-style per-action permission registry; `AllocatorRegistry` indexes them.
Four actor tiers: Pause Proxy (spells, GSM delay), AllocatorDAO Proxy (sub-spells, delay), Operator
(no spell, no delay, whitelisted per action, rate-limited), Keeper (triggers automation). Live in the
ChainLog: `ALLOCATOR_{SPARK,GROVE,BLOOM,INTERVAL,NOVA,OBEX,PATTERN,PRYSM}_A_{VAULT,BUFFER}` — eight
Stars — plus `SPARK_SUBPROXY`, `SPARK_STARGUARD`, `GROVE_SUBPROXY`, `GROVE_STARGUARD`, `GROVE`.

**D3M.** `DIRECT_HUB` (0x12F36c…) with `DIRECT_SPARK_DAI_{POOL,PLAN,ORACLE}`,
`DIRECT_SPARK_MORPHO_DAI_*`, `DIRECT_SPK_AAVE_LIDO_USDS_*`, legacy `DIRECT_AAVEV2_DAI_*` and
`DIRECT_COMPV2_DAI_*`; `DIRECT_MOM` and `EMSP_DDM_DISABLE_FAB` are the kill paths.

**Control plane.** `MCD_ADM` (0x929d9A1435662357F54AdcF64DcEE4d6b867a6f9) is DSChief V3 — approval
voting, `lock`/`free` against IOU tokens, `vote(address[])`/`vote(bytes32)`/`etch`, and `lift` to
promote the "hat". **The voting token is SKY, not MKR**; MKR converts one-way at **1 MKR → 24,000
SKY** through the MKR-SKY One Way Converter V2 (0xA1Ea1bA18E88C381C724a75F23a130420C403f9a), and
"converting SKY back to MKR requires executing a swap on an external exchange". `MCD_PAUSE`
(0xbE28…) is DSPause: a plan is `{usr, tag, fax, eta}`, `plot` schedules with `eta ≥ now + delay`,
`exec` executes after `eta` and checks the target's code hash against `tag`, `drop` cancels; the
delegatecall runs in `MCD_PAUSE_PROXY` (0xBE8E3e…) whose isolated storage protects the pause. Changing
the delay itself must be plotted, so the delay cannot be shortened faster than the delay. Ten "Mom"
contracts sit outside the delay for defensive actions only: `CLIPPER_MOM`, `OSM_MOM`, `LINE_MOM`,
`LITE_PSM_MOM`, `DIRECT_MOM`, `SPLITTER_MOM`, `SPBEAM_MOM`, `STUSDS_MOM`, `STARKNET_ESCROW_MOM`.
Thirteen `EMSP_*` emergency-spell contracts and factories are pre-deployed. The registry itself is
the ChainLog (`CHANGELOG` 0xdA0Ab1e0017DEbCd72Be8599041a2aa3bA7e740F), 513 active keys.

**Tokens.** `USDS` 0xdC035D…, `SUSDS` 0xa3931d… + `SUSDS_IMP` + `SUSDS_OFT`, `STUSDS`
0x99CD4Ec3f88A45940936F469E4bB72A2A701EEB9 + `STUSDS_IMP` + `STUSDS_RATE_SETTER` (0x307846…) +
`STUSDS_MOM`, `SKY` 0x56072C…, `MKR` 0x9f8F72…, `DAI_USDS` converter 0x3225737a…. `LOCKSTAKE_ENGINE`
0xCe01C9… with `LOCKSTAKE_SKY`, `LOCKSTAKE_CLIP`, `LOCKSTAKE_ORACLE`, `LOCKSTAKE_MIGRATOR`.

### 3. REPO

- **Org:** `github.com/sky-ecosystem`. `github.com/makerdao/*` **redirects**: an API read of
  `repos/makerdao/dss` returns `full_name: sky-ecosystem/dss`. Old links still work; the org moved.
- **`sky-ecosystem/dss`** — "Dai Stablecoin System", Solidity, **AGPL-3.0**, default branch `master`,
  created 2018-05-28, last push 2023-10-01, not archived. `src/`: `abaci.sol cat.sol clip.sol
  cure.sol dai.sol dog.sol end.sol flap.sol flip.sol flop.sol join.sol jug.sol pot.sol spot.sol
  vat.sol vow.sol` + `test/`. The core has not changed since 2023; all evolution is in satellites.
- Satellites, all Solidity: `sky-ecosystem/usds` (AGPL-3.0, pushed 2024-10-07 — a permissionless
  1:1 DAI↔USDS converter over `UsdsJoin`/`DaiJoin`, ERC-20 + permit + EIP-1271, UUPS/ERC-1822);
  `sky-ecosystem/sdai` branch **`susds`** (AGPL-3.0, "a tokenized wrapper around the DSR", the SSR
  implementation); `sky-ecosystem/stusds` (AGPL-3.0, `master`, created 2025-05-05, pushed
  2026-05-26); `sky-ecosystem/dss-allocator` (AGPL-3.0, default branch **`dev`**, pushed 2024-09-09;
  `src/`: AllocatorBuffer, AllocatorOracle, AllocatorRegistry, AllocatorRoles, AllocatorVault,
  IAllocatorConduit, `funnels/`; README warns the bundled funnels are "for illustrative purposes
  only"); `sky-ecosystem/dss-flappers` (branch `dev`); **`sky-ecosystem/sp-beam`** ("Direct Stability
  Parameters Change Module", created 2025-02-04, pushed 2025-08-04, `src/SPBEAM.sol`, Certora specs
  in `certora/`; GitHub reports no licence but the README declares **AGPL-3.0-or-later**);
  `sky-ecosystem/dss-emergency-spells` (AGPL-3.0, incl. `src/spbeam-halt/SPBEAMHaltSpell.sol`);
  `sky-ecosystem/spells-mainnet` (AGPL-3.0, the weekly executive spells, with
  `archive/2025-04-17-DssSpell/dependencies/sp-beam/SPBEAMInit.sol` recording the SP-BEAM
  activation spell); `sky-ecosystem/star-guard` ("whitelisting-based execution of payloads from Sky
  Stars", no licence); `sky-ecosystem/dss-exec-lib`, `dss-blow2`, `chainlog-ui`, `xchain-helpers`,
  `sky-oapp-oft`, `pas`, `diamond-pau` (Spark Liquidity Layer), `community` (governance polls/votes).
- **Deployed ↔ repo.** Sky publishes its own on-chain registry rather than a static address list: the
  ChainLog at 0xdA0Ab1e0017DEbCd72Be8599041a2aa3bA7e740F, served as JSON at
  `chainlog.skyeco.com/api/mainnet/active.json`, held **513 active keys** on 2026-08-04 and names
  exactly the modules present in the repositories (`MCD_VAT`, `MCD_JUG`, `MCD_POT`, `MCD_DOG`,
  `MCD_VOW`, `MCD_SPOT`, `MCD_END`, `MCD_FLAP`, `MCD_FLOP`, `MCD_SPLIT`, `MCD_SPBEAM`,
  `MCD_LITE_PSM_USDC_A`, 96 `CLIP_*` keys, 19 `ALLOCATOR_*` keys, 17 `DIRECT_*` keys). Four of those
  addresses answered live `eth_call`s with well-formed ray rates, so they are live contracts, not
  stale entries. **I did not diff deployed bytecode against any repo tag** — correspondence is
  asserted by the registry and by the spell archive, not verified here.

### 4. EVIDENCE

| Claim | Source | Accessed |
|---|---|---|
| Module list, Vat state/functions/invariant | https://developers.skyeco.com/protocol/core/vat/ | 2026-08-04 |
| Liquidations 2.0: Dog/Clipper/Abacus, buf/tail/cusp/chip/tip/chost/Hole/Dirt/chop, circuit breaker, invariants | https://developers.skyeco.com/protocol/vaults/collateral-liquidation/ | 2026-08-04 |
| Jug: base+duty, drip→fold, non-additivity, governance-only `file` | https://developers.skyeco.com/protocol/rates/jug/ | 2026-08-04 |
| Vow: sin queue, wait/flog/heal/kiss, sump/dump/bump/hump, flap/flop | https://developers.skyeco.com/protocol/core/vow/ | 2026-08-04 |
| OSM: 1-hour hop, peek/peep/poke, wards/buds, timing weakness | https://developers.skyeco.com/protocol/core/osm/ | 2026-08-04 |
| DSChief: approval voting, lock/free/vote/etch/lift, hat, **SKY is the voting token** | https://developers.skyeco.com/protocol/governance/chief/ | 2026-08-04 |
| DSPause: plan{usr,tag,fax,eta}, plot/exec/drop, proxy storage isolation, delay cannot be bypassed | https://developers.skyeco.com/protocol/governance/pause/ | 2026-08-04 |
| Rate mechanism: wad/ray/rad, normalized balances, accumulators, SF vs DSR | https://developers.skyeco.com/deep-dives/rate-mechanism/ | 2026-08-04 |
| sUSDS: ERC-4626, no fees and fees cannot be enabled, UUPS/ERC-1967 | https://developers.skyeco.com/protocol/tokens/susds/ | 2026-08-04 |
| stUSDS: "first Expert token", funds SKY-backed borrowing, "greater share of system risk" | https://developers.skyeco.com/protocol/tokens/stusds/ | 2026-08-04 |
| LitePSM: pre-minted pool, two ERC-20 transfers, no slippage, tin/tout not activated | https://developers.skyeco.com/protocol/liquidity/litepsm/ | 2026-08-04 |
| Staking Engine: lock SKY, borrow USDS, LSSKY non-transferable, delegate voting, urn non-transferable | https://developers.skyeco.com/protocol/rewards/staking-engine/ | 2026-08-04 |
| MKR→SKY = 1:24,000, one-way, `mkrToSky` | https://developers.skyeco.com/guides/sky/token-governance-upgrade/token-holders/ | 2026-08-04 |
| Chief V3 (SKY) 0x929d…, MKR-SKY One Way Converter V2 0xA1Ea… | https://developers.skyeco.com/guides/sky/token-governance-upgrade/key-info/ | 2026-08-04 |
| Splitter/FlapperUniV2/FlapperUniV2SwapOnly, hop/burn/want/pip, SplitterMom | https://github.com/sky-ecosystem/dss-flappers/blob/dev/README.md (raw) | 2026-08-04 |
| Allocator layers, actors, AllocatorOracle fixed 1:1, Vault/Buffer/Roles | `gh api repos/sky-ecosystem/dss-allocator/readme` | 2026-08-05 |
| SP-BEAM: duty/dsr/ssr, min/max/step, tau, facilitators, SPBEAMMom bypasses GSM, AGPL-3.0-or-later | `gh api repos/sky-ecosystem/sp-beam/readme`; https://github.com/sky-ecosystem/sp-beam | 2026-08-05 |
| `makerdao/dss` → `sky-ecosystem/dss`, AGPL-3.0, src file list | `gh api repos/makerdao/dss`, `.../contents/src` | 2026-08-05 |
| ChainLog 513 keys and all addresses quoted above | https://chainlog.skyeco.com/api/mainnet/active.json | 2026-08-04 |
| `Pot.dsr`, `sUSDS.ssr`, `Jug.base`, `stUSDS` rate raw ray values | `eth_call` via https://ethereum-rpc.publicnode.com against the ChainLog addresses | 2026-08-04 |
| TVL $5,674.4M, category CDP, rank 1 | https://api.llama.fi/protocols | 2026-08-04 |
| `docs.sky.money` is the *legal* site; robots disallows ClaudeBot | https://docs.sky.money/robots.txt, https://docs.sky.money/llms.txt | 2026-08-04 |

### 5. WHAT LOOKS UNNAMEABLE

- **The price of credit — confirmed, and worse than the corpus states.** Sky does not merely lack a
  symbol for "raise the fee to contract supply". It has a *bounded delegated rate authority*:
  SP-BEAM lets a named facilitator move `duty`, `dsr` and `ssr` inside governance-set `min`/`max`/`step`
  windows after a `tau` delay, killable by a Mom without the GSM delay. `Au` (delegated execution
  scope) is the nearest symbol and is about who may send a transaction, not about who may move a
  *parameter* within a band. The object here is "monetary policy delegated under a bounded mandate",
  which is the central institutional form in real central banking and has no symbol at all.
- **Directionally asymmetric governance delay.** Ten Mom contracts and thirteen emergency spells exist
  so that *making the system safer* is instant while *making it riskier* takes the GSM delay. `Tg`
  names a delay; `Gp` names a pause. Neither names a delay whose length depends on the sign of the
  change. This is a structural property of the whole control plane, not an accessory.
- **Recapitalisation by governance-token dilution — confirmed.** `MCD_FLOP` is deployed. `Sl` assigns
  a loss to a class; `Bs` pre-stakes capital to be slashed; neither says "new equity is issued against
  the loss after the fact".
- **A surplus buffer with a high-water mark (`hump`) and a fixed lot (`bump`) that mechanically trigger
  auctions — confirmed.**
- **The Star credit line — confirmed and larger than recorded.** Eight allocator vault/buffer pairs are
  live, each a sub-DAO with its own governance proxy, its own operators who act without delay inside
  rate limits, and a minting facility against synthetic collateral.
- **A deliberately uninformative oracle used as plumbing.** `AllocatorOracle` returns a constant 1:1
  purely so that a huge nominal collateral balance makes the debt ceiling reachable. `Ex`, `Tp`, `Oa`
  and `At` all presume the oracle carries information about the world.
- **Fee routing that is neither burn nor distribution.** The Splitter sends a `burn` fraction to a
  flapper and the rest to a farm; `FlapperUniV2` then converts the "burn" leg into *protocol-owned
  liquidity* rather than destroying it, bounded by an oracle `want`. `Fd` cannot distinguish burn,
  distribute, and become-an-LP.
- **Two liabilities of the same issuer with a permissionless 1:1 converter and two different savings
  rates.** DAI at 1.25% and USDS at 3.52%, converted 1:1 at will. `Ps` names a 1:1 swap backed by a
  *reserve*; here the swap is between two of the issuer's own obligations and the rate spread is the
  migration incentive.
- **stUSDS as a junior class inside the issuer.** Closest to `Tr`, but there are no attachment points
  and the seniority is documented rather than settled by a waterfall contract.
- **A standing library of pre-deployed, pre-audited single-purpose governance transactions** (`EMSP_*`
  and their factories). Not `Tg`, not `Gp`.

### 6. DELTA

1. **The corpus ranking basis is confirmed, not stale.** Live `api.llama.fi/protocols` on 2026-08-04
   gives Sky Lending **$5,674.4M**, category `CDP`, rank 1 (corpus: $5,665.3M) — same-day drift only.
2. **The `Ix` marker is now only half true.** The corpus says "the index moves because governance
   voted a number, not because yield was earned". Since the 2025-04-17 executive spell, `MCD_SPBEAM`
   is deployed and a facilitator can move `duty`/`dsr`/`ssr` inside bounds *without* an executive
   vote. The marker should read "the index moves because a bounded delegate set a number".
3. **The Star/allocator residue understates the scale.** The corpus calls it "the other half of the
   Spark D3M gap". Eight allocator vault/buffer pairs are live (SPARK, GROVE, BLOOM, INTERVAL, NOVA,
   OBEX, PATTERN, PRYSM), with StarGuard payload whitelisting and per-Star sub-proxies.
4. **The element set may be missing a first-loss class.** stUSDS is deployed (0x99CD4Ec3…) with its
   own rate setter, Mom and three emergency spells, and is documented as taking "a greater share of
   system risk" to fund SKY-backed borrowing. If that survives scrutiny it arms `Bs` or `Tr`, neither
   of which the corpus decomposition carries for Sky.
5. **`Rd` is correctly absent, and that is worth stating.** Sky has no direct redemption right for
   USDS against collateral; the PSM (`Ps`) is the only par exit. Law L7 (`Cd → Rd | Ps | liquidation
   capacity`) is satisfied through `Ps` alone, which is a stronger statement than the record makes.
6. **Which token a debt auction mints is UNKNOWN from documentation.** The Vow page on
   developers.skyeco.com still says `flop` mints **MKR** and that `Vow.dump` is "the starting amount
   of MKR offered". But `MCD_ADM` is Chief V3 on **SKY**, MKR→SKY is one-way at 1:24,000, and both
   tokens remain in the ChainLog. The corpus writes "mints MKR/SKY" and elides the question. A later
   stage must read `MCD_FLOP`/`MCD_VOW` on-chain before asserting either.

---

## Ethena (USDe / sUSDe)

### 1. WHAT IT DOES

A **whitelisted** counterparty delivers roughly $100 of an accepted asset — the docs' worked example
is USDT — to the minting contract and receives roughly 100 newly minted USDe atomically in return,
less gas and execution costs; slippage and execution fees are priced into the quote and "Ethena earns
no profit from the minting or redeeming of USDe". Redemption is the same trade reversed. What backs
the unit is not a vault of collateral but a *book*: liquid stablecoins and short-duration real-world
assets that hold value on their own, plus volatile holdings — spot crypto and tokenised securities —
each paired with a short futures position of approximately the same notional so that a move in the
spot leg is offset by the hedge. The backing never sits on the exchange: it is held by off-exchange
settlement providers and only *delegated* to derivatives venues as margin. The peg is defended purely
by primary-market arbitrage: whitelisted users mint at $1 when USDe trades above and redeem at $1 when
it trades below, with about 0.50% of backing kept as stablecoins inside the minting contract for
on-demand redemption and about 4% held across custodians to replenish it. Holding USDe pays nothing.
Staking it into `StakedUSDeV2` mints sUSDe, an ERC-4626 share whose price rises as a Rewarder
transfers realised USDe into the vault — rewards arrive periodically and vest linearly to stop
deposit-sandwiching, and sUSDe "can only accrue positive or flat rewards", with negative-revenue
periods absorbed by the Reserve Fund instead. Exit is by selling on the secondary market, by
unstaking through a cooldown that parks USDe in a `USDeSilo` contract for a period the admin may set
up to 90 days, or — if you are whitelisted — by redeeming at $1. There is no documented system-wide
shutdown; what exists is a set of ≥3 Gatekeeper keys that can disable mint and redeem outright and
strip the Minter and Redeemer roles.

### 2. DESIGN

**On-chain contracts.** `USDe.sol` (0x4c9edd5852cd905f086c759e8383e09bff1e68b3), `EthenaMinting.sol`
V1 (0x2cc440b721d2cafd6d64908d6d8c4acc57f8afc3) and V2
(0xe3490297a08d6fC8Da46Edb7B6142E4F461b62D3), `StakedUSDeV2.sol` = sUSDe
(0x9d39a5de30e57443bff2a8307a4256c8797a3497 — the staking contract *is* the sUSDe token),
`StakingRewardsDistributor.sol`, `USDeSilo`, `StakedENA.sol` (0x8bE3460A…), USDe Rewards Distributor
0xf2fa332b…. ENA 0x57e114B6….

**Mint/redeem V2** (shipped 2024-07-08) added: asset-specific **per-block** minting and redeeming
limits, distinguishing stablecoins from LSTs/assets, under a **global cap**, adjustable by the Ethena
Dev multisig; a **mandate delta limit** that blocks mint/redeem when USDe diverges unfavourably from
the stablecoin price beyond a configured threshold, explicitly aimed at "blackswan events like
stablecoin collateral de-pegging"; EIP-1271 support so contract wallets can sign (with a
`signature_type` field defaulting to EIP712); migration of the whitelist from off-chain to **on-chain**,
with benefactors whitelisting their own beneficiaries via a contract call; the RFQ id moved on-chain as
`order_id` inside the signature; struct and gas optimisations; AES cipher encryption replacing AWS
secrets management.

**Roles and keys** (from the multisig/timelock matrix): **Owner** — one Ethena multisig —
`transferOwnership`, add/remove supported collateral, add/remove custodian addresses. **Admin** — one
multisig — grant/revoke Minter, Redeemer, Gatekeeper. **Gatekeepers** — ≥3 EOAs, "includes external
trusted organizations" — disable mint/redeem, remove Minter and Redeemer roles. **Minter** — 20 EOAs —
`mint()` and `transferToCustody`. **Redeemer** — 20 EOAs — `redeem()`; deliberately the same address
set as Minter "for handling concurrent load". **The matrix page specifies no timelock delay for any
role.** Staking side: `DEFAULT_ADMIN_ROLE`, a Rewarder that transfers in USDe, a Blacklister;
`SOFT_RESTRICTED_STAKING_ROLE` (exists, never used) and `FULL_RESTRICTED_STAKING_ROLE` (used —
"Fully Restricted Stakers cannot receive sUSDe"); `setCooldownDuration` up to 90 days; `rescueTokens`
recovering any ERC-20 except USDe to an Ethena-controlled address; `redistributeLockedAmounts` moving
locked sUSDe from restricted addresses to segregated protocol wallets.

**Off-chain.** The hedging system is "offchain application services": it ingests market data from CeFi
exchanges (Binance, Bybit, OKX, Deribit, BitMEX, Bitget) plus Pyth and RedStone, normalises it,
computes and publishes the prices used to quote mints and redemptions, validates data integrity,
reconciles portfolio positions across exchanges, routes orders to venues, and monitors dependencies.
It "ingests & interacts directly with the protocol's onchain smart contracts" but is not itself a
contract. **No on-chain contract is documented as reading a price feed for solvency purposes.**

**Custody and settlement.** Named providers: **Copper** (Clearloop), **Ceffu**, **Fireblocks**, all
described as "non-US based & owned, well-regarded & institutionally focused". Assets sit with the
provider in bankruptcy-remote trusts or MPC wallets — "in the event of Copper's failure, users' funds
are not a part of the Copper estate" — and are delegated to and from exchanges without leaving
custody. Exchange collateral posting runs on "the typical rolling 4-hour settlement cycle frequency";
Copper settles PnL daily. Perp venue allocation is disclosed as Binance 50% / Bybit 25% / OKX 15% /
Deribit 5% / Bitget 5%. On exchange failure, positions are treated as closed with nothing further
owed, exposure is limited to outstanding PnL between settlement cycles, and the protocol "is reliant
upon the cooperation and legal behavior of our 'Off-Exchange Settlement' provider partners".

**Backing composition.** Six named families: crypto basis trade; **non-crypto basis trade**
("commodities and other non-crypto markets"); DeFi lending into overcollateralised on-chain markets;
institutional lending, overcollateralised, to institutional counterparties; tokenised real-world
assets including short-duration government debt and high-liquidity credit; liquid stablecoins. "The
allocation across categories is dynamic and is published on the Transparency dashboard."

**Reserve Fund.** Absorbs periods where "the cost of maintaining positions exceeds the revenue
earned" and "can also be deployed to address shortfalls in backing". Initially capitalised from
revenue during high-earning periods; the share of ongoing revenue directed to it is a governance
parameter, **currently 0%**, with all revenue instead going to incentive rewards and promotional
distributions. Balance published at app.ethena.fi/dashboards/transparency.

**Rewards.** "The protocol does not rehypothecate, lend out, or otherwise utilize deposited USDe for
any purpose." The Ethena Foundation, via a subsidiary, calculates APY weekly as part of internal
accounting when distributing to the StakingRewardsDistributor, and deliberately pays in multiple
smaller instalments through the week to deny arbitrage; the staking docs describe transfers every 8
hours vesting linearly over 8 hours.

**Governance.** ENA holders appoint rotating committee members; day-to-day decisions are delegated to
committees including a Risk Committee; the docs state plainly that "fully on-chain governance is not a
practical or viable option at present".

### 3. REPO

**There is no maintained public repository for Ethena's core protocol.** This is the most important
repo finding in the lane and it should be stated in the paper rather than papered over.

- `github.com/ethena-labs` holds 13 public repositories. The only one containing the core Solidity is
  **`ethena-labs/code4arena-contest`** — Solidity, **GPL-3.0**, created 2023-10-18, **last push
  2024-02-19, ARCHIVED**, 46 stars, ~4 MB, single tree `protocols/USDe/{contracts, audit, forge,
  test, script, lib}` with `foundry.toml`, `slither.config.json`, `solhint.json`. The same scope is
  mirrored publicly at `code-423n4/2023-10-ethena` (`contracts/EthenaMinting.sol`,
  `contracts/StakedUSDeV2.sol`, `scope.txt`, `4naly3er-report.md`).
- Maintained repos are tooling, not protocol: `ethena-labs/ethena-minting-client` (TypeScript, **no
  licence**, pushed 2026-08-02), `ethena-labs/usdm-minting-client` (Python, no licence, pushed
  2026-08-03), `ethena-labs/ethena_sats_adapters` (Python, no licence, pushed 2026-08-04, points
  accounting), `ethena-labs/suiusde-sdk` (MIT), `ethena-labs/role-verification` (Python, archived —
  "outputs who possesses what roles for all Ethena contracts"), `ethena-labs/ethena-usdtb-contest`
  (archived), `ethena-labs/bbp-public-assets` (archived).
- **What is verifiable instead.** (a) The docs publish a Key Addresses page with mainnet and
  multi-chain deployments and describe every core contract as "Open Source (Etherscan linked)";
  most L2s share one address triple (ENA 0x58538e6A…, USDe 0x5d3a1Ff2…, sUSDe 0x211Cc4DD…) with
  distinct deployments on Solana, ZKSync, Zircuit, Aptos and TON. (b) Twelve audits are published:
  Zellic, Quantstamp (2023-10-18), Spearbit (2023-10-18), Pashov (2023-10-22, 2023-12-22 for ENA/LP
  staking, 2024-05-23 for v2, 2024-09-02 for sENA, 2024-10-20 for USDTB), Code4rena public contest
  (2023-11-13), Chaos Labs system design & economics (2024, 3 reports), Quantstamp USDTB
  (2024-10-25), Cyfrin USDTB (2024-10-31); all reported no critical or high findings. (c) The
  transparency dashboard and custodian attestations.
- **Explicitly closed / off-chain, with no code and no chain to inspect:** the hedging system, the
  price and quote service, the order router, the position reconciliation service, the GATEKEEPER
  monitoring systems (documented as running "in separate AWS accounts"), the custodial mirroring
  arrangements, and the perpetual positions themselves. For roughly $3.9B of TVL, the mechanism that
  makes the unit a dollar is a private program operated by a company.

### 4. EVIDENCE

| Claim | Source | Accessed |
|---|---|---|
| Mint/redeem flow, whitelisting, no profit on mint, backing categories, hedge pairing, custody delegation | https://docs.ethena.fi/overview/how-usde-works.md | 2026-08-04 |
| Peg arbitrage, whitelist-only, 0.50% in the minting contract, 4% across custodians | https://docs.ethena.fi/protocol-overview/peg-arbitrage-mechanism.md | 2026-08-04 |
| Reserve Fund purpose, deployment against shortfalls, **0% of revenue currently allocated** | https://docs.ethena.fi/protocol-overview/reserve-fund.md | 2026-08-04 |
| Six backing families incl. non-crypto basis, institutional lending, RWA; dynamic allocation | https://docs.ethena.fi/backing-assets/overview.md | 2026-08-04 |
| Copper/Ceffu/Fireblocks, 4-hour settlement cycle, reliance on provider cooperation | https://docs.ethena.fi/backing-custody-and-security/overview/off-exchange-settlement-in-detail.md | 2026-08-04 |
| Bankruptcy-remote trusts / MPC, daily Copper settlement | https://docs.ethena.fi/protocol-overview/risks/custodial-risk.md | 2026-08-04 |
| Exchange failure handling, venue split 50/25/15/5/5 | https://docs.ethena.fi/protocol-overview/risks/exchange-failure-risk.md | 2026-08-04 |
| Owner/Admin/Gatekeeper/Minter/Redeemer powers and counts; **no timelock delays listed** | https://docs.ethena.fi/technical-design/key-trust-assumptions/matrix-of-multisig-and-timelocks.md | 2026-08-04 |
| V2: per-block per-asset limits + global cap, mandate delta limit, EIP-1271, on-chain whitelist, order_id | https://docs.ethena.fi/technical-design/minting-usde/mint-and-redeem-contract-v2.md | 2026-08-04 |
| ERC-4626, USDeSilo cooldown, 8-hour transfers vesting over 8 hours, no rewards in some periods | https://docs.ethena.fi/technical-design/staking-usde.md | 2026-08-04 |
| Roles/functions: `FULL_RESTRICTED_STAKING_ROLE`, soft role unused, `setCooldownDuration` ≤90d, `rescueTokens`, `redistributeLockedAmounts` | https://docs.ethena.fi/technical-design/staking-usde/staking-key-functions.md | 2026-08-04 |
| Hedging system is off-chain; ingests CeFi + Pyth + RedStone; prices, reconciles, routes | https://docs.ethena.fi/technical-design/hedging-system.md ; https://docs.ethena.fi/technical-design/use-of-oracles.md | 2026-08-04 |
| No rehypothecation; Foundation subsidiary computes APY weekly; positive-or-flat only | https://docs.ethena.fi/protocol-overview/rewards-mechanism.md | 2026-08-04 |
| Committee governance; "fully on-chain governance is not a practical or viable option" | https://docs.ethena.fi/protocol-overview/governance.md | 2026-08-04 |
| Contract names, open-source status, GATEKEEPER in separate AWS accounts | https://docs.ethena.fi/technical-design/overview/github-overview.md | 2026-08-04 |
| Deployed addresses, all chains | https://docs.ethena.fi/technical-design/key-addresses.md | 2026-08-04 |
| Twelve audits with firms and dates | https://docs.ethena.fi/resources/audits.md | 2026-08-04 |
| `ethena-labs` repo inventory; code4arena-contest GPL-3.0 archived 2024-02-19; tree | `gh`/GitHub API `orgs/ethena-labs/repos`, `repos/ethena-labs/code4arena-contest` | 2026-08-04/05 |
| Public mirror of core contracts | `gh search code EthenaMinting` → `code-423n4/2023-10-ethena/contracts/EthenaMinting.sol` | 2026-08-05 |
| TVL $3,884.1M, DefiLlama category `Basis Trading` | https://api.llama.fi/protocols | 2026-08-04 |

### 5. WHAT LOOKS UNNAMEABLE

**All six corpus residues are confirmed against the current docs.** Off-exchange settlement and custody
mirroring; capturing another venue's funding as an external party; delta-neutrality as a continuously
maintained off-chain invariant; venue and counterparty concentration; whitelist-only mint/redeem; and
yield that can be switched off. Five further gaps that the corpus does not record:

- **A par right that voids itself in a price region.** The V2 mandate delta limit refuses to mint or
  redeem when USDe diverges from the stablecoin reference beyond a threshold. `Gp` names a pause and
  `Rd` names a right to redeem. Neither names "the right is suspended precisely when it would be
  exercised", which is the entire content of this control.
- **Per-block, per-asset issuance rate limits under a global cap.** A quantitative speed limit on
  *creating the unit*, distinguished by asset class. `As` is quantity adjustment toward a peg; this is
  a quantity ceiling per unit time for safety, and it is the main defence against a compromised minter.
- **Operational key plurality sized for throughput, plus a third-party veto key.** Twenty Minter EOAs
  and twenty Redeemer EOAs exist "for handling concurrent load"; ≥3 Gatekeeper EOAs include external
  organisations that are not governors and can kill mint/redeem unilaterally. `Aw` gates access. There
  is no symbol for "the number of keys is a capacity parameter", nor for "an outsider holds a
  destructive but not constructive power".
- **A standing administrative sweep.** `rescueTokens` lets the admin remove any ERC-20 except USDe to
  an Ethena-controlled address. `Fz` covers freeze and forced transfer of the *protocol's own unit*;
  this is a permanent claim on everything else that lands in the contract.
- **A reserve that is an actively managed book.** Six strategy families, dynamically reallocated by an
  operator, disclosed on a dashboard. `At` attests to a reserve's existence and value; nothing names
  "the reserve's composition is a discretionary investment decision taken continuously".

Borderline, flagged rather than claimed: the 8-hour linear vesting of rewards into the vault is
arguably `Sr`, but here streaming is an MEV defence rather than a product feature, which is a different
justification for the same shape.

### 6. DELTA

1. **The corpus describes the 2024 design, not the 2026 one.** The corpus record says Ethena is "long
   staked ETH and liquid restaking collateral, short an equivalent notional of ETH perpetual futures".
   The current backing-assets documentation lists **six** families of which the crypto basis trade is
   one, and explicitly includes non-crypto (commodity) basis, DeFi lending, institutional lending,
   tokenised RWAs and liquid stablecoins. Consequence for the `Dp` marker: the corpus scored `Dp` at
   "about 20% coverage of the mechanism"; measured against the actual current mechanism the coverage is
   **lower**, because most of the backing is now not a directional position with a hedge at all.
2. **The Reserve Fund's contribution rate is 0%.** The `Bs` marker says "the reserve fund absorbs
   negative funding before anyone else, so it is first-loss". Still the stated promise, but governance
   currently directs **0% of revenue** to it, with everything going to incentive rewards. A first-loss
   buffer with a zero accrual rate is a different object and the marker should say so.
3. **The `Ix` marker is confirmed and sharpened.** The index moves because "the Ethena Foundation, via
   a subsidiary, calculates APY weekly as part of internal accounting", paying in staggered
   instalments. Not an accrual computation; a bookkeeping decision executed as a transfer.
4. **Role name correction.** The corpus's `Fz` marker cites `FULL_RESTRICTED_STAKER_ROLE`; the docs
   name it `FULL_RESTRICTED_STAKING_ROLE`, and record that the soft variant has never been used. The
   marker calls `Fz` "an unusually exact fit" — that survives, but the fit is *tighter* than recorded,
   because `redistributeLockedAmounts` is a documented function, not an inferred capability.
5. **`Wq` is confirmed but is governable.** The cooldown/`USDeSilo` queue is real, and
   `setCooldownDuration` admits values up to 90 days at admin discretion. The symbol does not carry
   "the queue length is a lever the operator may pull to 90 days".
6. **`Xf` is confirmed.** USDe, sUSDe and ENA are deployed across many chains with a shared address
   scheme on most L2s and distinct deployments on Solana, ZKSync, Zircuit, Aptos and TON.
7. **`Pf` NOT USED is confirmed as correct** and the docs make the case stronger than the corpus does:
   Ethena's oracle page lists the six CeFi venues it *reads prices from*, and the exchange-failure page
   lists the venue allocation it *has positions on*. It operates no perpetual market anywhere.

---

## USDD

### 1. WHAT IT DOES

USDD 2.0 is an over-collateralised CDP stablecoin issued natively on TRON and also deployed on Ethereum
and BNB Chain. A user opens a Vault, deposits collateral — on TRON the live ilks are TRX-A, TRX-B,
TRX-C, sTRX-A, USDT-A, PSM-USDT and an undocumented SA001-A — and mints USDD against it, staying above
a minimum collateral ratio that the docs say varies by asset volatility. The debt accrues a Stability
Fee accumulated by a Jug contract. The peg is defended by a Peg Stability Module that swaps USDT (and,
on the EVM chains, USDC) for USDD at exactly 1:1 with **no service fee** — the user pays only gas — by
over-collateralisation of the CDP side, and by liquidation. If a vault's ratio falls below the minimum,
liquidation triggers automatically: the Dog seizes the position and a Clip contract runs a descending
Dutch auction, keepers are paid a fixed incentive plus a proportional one, auction proceeds repay the
USDD debt, and any excess collateral returns to the owner; the architecture also provides for debt
auctions selling governance tokens when the protocol runs a deficit. Separately, USDD Earn issues
sUSDD, an ERC-4626 vault whose exchange rate against USDD rises as returns accrue from the "Smart
Allocator" strategy, redeemable for USDD at any time with no lockup. The advertised APY is not the
realised yield of the collateral: it is set by a documented formula combining a 7-day moving average
of stablecoin yields, the Federal Reserve rate, a competitive market premium, and the protocol's own
underlying yield. The predecessor, USDDOLD, was minted by whitelisted TRON DAO Reserve institutions by
burning TRX against a TDR-held basket of BTC, USDT, USDC and TRX; a `Migrate` contract converts it.

### 2. DESIGN

**A near-verbatim Multi-Collateral Dai fork.** The documented core contracts are `Vat`, `Dog`, `Clip`,
`Spot`, `Jug`, `Median`, `OSM`, a `Proxy contract`, `PSM` and `Migrate`. `Vat` exposes
`slip(ilk,usr,wad)`, `frob(ilk,u,v,w,dink,dart)`, `grab(...)`, `fold(ilk,u,rate)` and `file(...)`.
`Jug` accrues the stability fee with a `duty` per ilk; the entry point is documented as `rip(ilk)`
rather than DSS's `drip(ilk)`, calling `Vat.fold` to update rate, debt and surplus. `Clip` exposes
`kick(tab,lot,usr,kpr)`, `take(id,amt,max,who,data)`, `redo(id,kpr)`, `yank(id)` and `file(what,data)`,
with a `tip` ("fixed incentive for starting an auction") and a `cut` ("price decay factor per second").

**Oracles.** Each collateral gets its own three-contract pipeline: `Median` computes a price from a
list of supported feeds; `OSM` holds a current and a next price; `Spot` reads the OSM and writes
`ilk.spot` into the Vat. The underlying feeds are **Chainlink and WinkLink**. The OSM delay length is
not stated in the docs — UNKNOWN.

**PSM.** From the project's own Solidity: `UsddPsm` with `AuthGemJoin` adapters for USDT and USDC and a
`UsddJoin` for minting/burning USDD, all discovered through a **ChainLog** registry under the keys
`MCD_PSM_USDT_A` and `MCD_PSM_USDC_A`. Separate `tin` (sell) and `tout` (buy) fees under governance
control; pausable sell and buy; read-only quoter contracts; multi-decimal handling (USDT/USDC 6, USDD
18); Solidity ^0.6.12; deployed on TRON, Ethereum (chain 1) and BNB Smart Chain (chain 56). The
user-facing docs say the swap currently carries no service fee.

**Savings.** sUSDD is ERC-4626. Yield comes from the **Smart Allocator**, described as "USDD's new
fully on-chain, transparent, and risk-controlled investment strategy", deploying idle capital into
platforms "like Aave", with venue selection, caps and phasing decided jointly by "the USDD and JUST
DAO teams" after "careful review based on market conditions, liquidity amount, and amount of returns".
Execution is on-chain; allocation is discretionary. The Base APY formula is the four-input construction
described above.

**Control plane — thin at primary source.** The governance page says the framework is "community-driven
and decentralized" and that "critical protocol changes are subject to community review and approval".
It names **no** governable parameter list, **no** timelock, **no** multisig threshold and **no** admin
address. The security page repeats the same principles without implementation detail. Secondary
reporting describes a transition of USDD governance to the JST token under JUST DAO (and JustLend's own
docs describe a GovernorBravo + WJST + 48-hour Timelock stack for *JustLend*), but I could not confirm
at a USDD primary source that USDD's own parameters are under that timelock. **UNKNOWN.**

**Audits.** ChainSecurity — USDD v2 (Tron), PSM (Tron) and Exchange (Tron), all 2025-01-24; CertiK —
USDD on Ethereum, 2025-09-02; ChainSecurity — USDD on Ethereum and BSC, 2025-10-24.

### 3. REPO

**No canonical repository for the CDP core could be located. This is a finding, not a gap in effort.**

- The project's GitHub org is **`decentralized-usd`**. Its only Solidity repository is
  **`decentralized-usd/psm`** — created 2024-12-03, last push 2025-10-24, default branch `main`,
  **no LICENSE file**, 1 star, Foundry layout (`src/`, `lib/`, `.gitmodules`, `README.md`). Its README
  is the best technical description of the USDD PSM in existence and confirms the DSS lineage
  ("Built on proven DSS (Dai Stablecoin System) architecture"). The org's other repos are `docs`,
  `mcp-server-usdd` (TypeScript, MIT), `usdd-skills` (JavaScript, MIT) and `public-assets`.
- Searches of GitHub for the vat/dog/clip/jug/spot/median/osm fork under any USDD- or TRON-affiliated
  org returned nothing. `tronprotocol` carries the chain, not the stablecoin.
- **Deployed addresses published by the project** are token-level plus TRON ilk joins: USDD on TRON
  `TXDk8mbtRbXeYuMNS83CfKPaYYT8XWv9Hz`, Ethereum `0x4f8e5de400de08b164e7421b3ee387f461becd1a`, BNB
  `0x45e51bc23d592eb2dba86da3985299f7895d66ba`; collateral/ilk contracts on TRON — USDD
  `TCrEVahRbhDFB6uRXEWUg7wkptXvg47GKs`, TRX-A `TJ1VWPvFVq7sVsN7J7dWJVZz4SLT14qRUr`, TRX-B
  `TGQKnHDQNyc3QeHJ7YxH8wggdg89UVXyvX`, TRX-C `TPUPPLTYLdbW4jxwD5g2T7ystxsR9HL2mt`, sTRX-A
  `TKha7zcAXZMaaWzoVmUHtvVFqr9GeiChgJ`, USDT-A `TDUkQbjrXs6xUbxGCLknWwJHxVTdysXBhy`, PSM-USDT
  `TSUYvQ5tdd3DijCD1uGunGLpftHuSZ12sQ`, SA001-A `TXdYNjXaHn3c1whomRpzCkaFbjfCffMFGf`; plus USDT
  `0xce355440c00014a229bbec030a2b8f8eb45a2897` and USDC `0x12d0351f68035a41d13fc8324562e2d51b7a3b93`
  on Ethereum and USDT `0x939d3FB56cd12d68CaA1125cc57a8d2391F7Ee29` on BNB Chain.
- **Whether deployed bytecode matches published source: UNKNOWN.** The docs assert open-source code;
  I could not find the code. The verifiable substitutes are the five audit reports and whatever source
  verification exists on TronScan and Etherscan, which I did not check. Language: Solidity ^0.6.12 for
  the PSM. Licence: **none declared** on the one public Solidity repo.

### 4. EVIDENCE

| Claim | Source | Accessed |
|---|---|---|
| Documentation index (all page URLs used below) | https://docs.usdd.io/llms.txt | 2026-08-04 |
| Over-collateralised, multi-collateral, multichain, freeze-free, community governance | https://docs.usdd.io/introduction/readme.md ; https://docs.usdd.io/introduction/core-features.md | 2026-08-04 |
| Modules: collateral, liquidation, Dutch + debt auctions, PSM zero-slippage zero-fee | https://docs.usdd.io/system-architecture/system-architecture.md | 2026-08-04 |
| Core contract list (Vat, Dog, Clip, Spot, Jug, Median, OSM, Proxy, PSM, Migrate) | https://docs.usdd.io/developers/core-contracts.md | 2026-08-04 |
| Vat functions and invariants | https://docs.usdd.io/developers/core-contracts/vat.md | 2026-08-04 |
| Jug `duty`, `rip(ilk)` → `Vat.fold` | https://docs.usdd.io/developers/core-contracts/jug.md | 2026-08-04 |
| Clip kick/take/redo/yank/file, `tip`, `cut` | https://docs.usdd.io/developers/core-contracts/clip.md | 2026-08-04 |
| Median → OSM → Spot; Chainlink + WinkLink | https://docs.usdd.io/developers/oracle.md | 2026-08-04 |
| PSM 1:1, no service fee, availability cap | https://docs.usdd.io/user-guide/psm-peg-stability-module.md | 2026-08-04 |
| sUSDD is ERC-4626; rate rises via Smart Allocator; redeemable any time | https://docs.usdd.io/system-architecture/susdd-mechanism.md | 2026-08-04 |
| Smart Allocator: on-chain, Aave, run by USDD + JUST DAO teams, discretionary caps | https://docs.usdd.io/system-architecture/smart-allocator.md | 2026-08-04 |
| Base APY = f(7-day MA stablecoin yield, Fed rate, market premium, underlying yield) | https://docs.usdd.io/system-architecture/regarding-the-dynamic-apy-pricing-mechanism.md | 2026-08-04 |
| Governance page names no parameters, no timelock, no multisig | https://docs.usdd.io/governance/overview.md ; https://docs.usdd.io/security/secure-framework.md | 2026-08-04 |
| USDDOLD minted by whitelisted TDR institutions by burning TRX; TDR basket BTC/USDT/USDC/TRX | https://docs.usdd.io/introduction/what-is-usddold.md | 2026-08-04 |
| Five audits, firms and dates | https://docs.usdd.io/security/audits.md | 2026-08-04 |
| Token + ilk + PSM addresses | https://docs.usdd.io/developers/deployment-addresses.md ; https://docs.usdd.io/introduction/collateral-asset-contract-addresses.md | 2026-08-04 |
| `decentralized-usd/psm`: DSS lineage, UsddPsm/AuthGemJoin/UsddJoin, ChainLog keys, tin/tout, ^0.6.12, no licence | `gh api repos/decentralized-usd/psm` + readme; https://github.com/decentralized-usd/psm | 2026-08-05 |
| No USDD core repo found anywhere on GitHub | `gh search repos "usdd"`, `gh search repos "usdd tron stablecoin"`, `gh api orgs/decentralized-usd/repos` | 2026-08-05 |
| TVL $1,282.5M, category CDP, rank 2 | https://api.llama.fi/protocols | 2026-08-04 |

### 5. WHAT LOOKS UNNAMEABLE

- **A discretionary reserve manager behind a nominally permissionless CDP — confirmed.** The Smart
  Allocator is run by two named teams who choose venues and caps. Execution is on-chain; the decision
  is not.
- **The interest-rate-as-policy gap — confirmed.** `duty` is set by governance and there is no symbol
  for it.
- **The Dutch auction — confirmed reachable only through contested `Da`.**
- **An administered savings rate anchored to exogenous benchmarks — new, and it replaces the corpus's
  framing.** The Base APY formula takes three of its four inputs from *outside the protocol*: a 7-day
  moving average of competitor stablecoin yields, the Federal Reserve rate, and a competitive premium.
  Only the fourth is earned yield. This is not "protocol-funded emissions" (`Em`) and it is not an
  index tracking realised returns (`Ix`). It is a policy rate benchmarked to the outside world — the
  same species of instrument as Sky's SSR but justified by a *published reaction function*. Nothing in
  58 symbols names a rate whose level is a function of external market and central-bank rates.
- **A contract whose only job is to migrate holders off the issuer's own predecessor liability.**
  `Migrate` is a documented core contract. Two liabilities of one issuer, one deprecated, one
  successor, with a conversion path. No symbol.
- **One brand, one peg, three domains, three different collateral sets.** TRX and sTRX ilks on TRON,
  USDT/USDC on Ethereum, USDT on BNB Chain, with separate token contracts. `Xf` names moving an asset
  across domains and law L9 requires `debit(source) = credit(destination)`. Here nothing is bridged:
  the issuer *exists separately* in three domains and mints locally against local backing. That is a
  different object and L9 does not apply to it.
- **An undocumented ilk.** `SA001-A` appears in the published collateral address list with no
  explanation anywhere in the docs. Flagged as UNKNOWN; a later stage should identify it before
  claiming the collateral set is complete.

### 6. DELTA

1. **Ranking confirmed:** $1,282.5M live vs corpus $1,299.4M, category CDP rank 2.
2. **The subsidy residue is not supported at primary source.** The corpus asserts "USDD's headline
   yield is not fully earned by the collateral" and "the treasury tops up an interest rate in the
   stablecoin itself". What the docs actually say is that the Base APY is computed from four inputs,
   three of them external benchmarks. Whether the gap between the administered rate and the earned
   yield is funded from a reserve is **not stated anywhere I could find: UNKNOWN.** The residue should
   be restated as "an administered rate with a published external reaction function", which is a
   *different* unnameable thing and arguably a more interesting one.
3. **The `At` marker may be attached to the wrong era.** The marker reads "the TRON DAO Reserve
   publishes a transparency dashboard". USDD 2.0's own documentation places the TDR in the past — it
   issued **USDDOLD** — and the current governance and architecture pages do not mention it at all;
   the discretionary actor named today is "the USDD and JUST DAO teams" via the Smart Allocator.
   Whether the TDR still stands behind USDD 2.0 is UNKNOWN.
4. **The nesting claim survives.** The corpus says Lista ⊂ USDD ⊂ Sky differing only by `At`, `Xf`,
   `Fd`. Against the contracts: USDD's Clip documents `tip` and `cut` but never a `chip`, and I found
   no flapper/surplus-burn equivalent, consistent with `Fd` being absent. The DSS skeleton is
   otherwise identical down to function names.
5. **The savings product is under-decomposed.** The corpus carries `Ix` for USDD but not `Sh`. sUSDD
   is ERC-4626 — share accounting *and* a rising exchange rate — exactly as sUSDe is, where the corpus
   does carry `Sh`. Inconsistent treatment of the same shape.
6. **`Xf` is present in the element set but means something different here** — see the unnameable note
   above. If stage 2 keeps `Xf` it should record that L9 is not satisfied in the usual way.

---

## Lista CDP

### 1. WHAT IT DOES

A user deposits BNB, ETH, slisBNB (Lista's own liquid-staked BNB), wBETH, BTCB, wstETH, FDUSD or USDT
into the `Interaction` contract, which routes the asset through a GemJoin into the Vat and records the
position; the user then borrows lisUSD against it and can farm the borrowed lisUSD and claim LISTA
rewards for borrowing. The debt accrues interest at a rate that **no one votes on**: an Algorithmic
Market Operations module recomputes the borrow rate every 15 minutes (or on any user interaction) as an
exponential function of the deviation of the lisUSD price from $1, read from the Binance oracle,
parameterised by a per-collateral base `r0` and an amplification `Beta`, capped at 20%. The peg is
defended by that controller, by a PSM that mints lisUSD 1:1 against USDT and USDC with a **0% mint fee
and a 2% redeem fee** — deliberately asymmetric, with the stated purpose of pushing exit onto
PancakeSwap — by a D3M that mints lisUSD directly into Venus Core Pool and Aave to seed liquidity, and
by liquidation. Settlement of an unsafe position is a Dutch auction: the collateral goes to auction at
its unit price × 1.02 and declines linearly toward zero over `tau`; it pauses at `tail` or when the
price has fallen about 40% (`cusp`) and must be restarted by someone, who is paid for doing so; the
debt to be covered is grossed up by a **10% liquidation penalty**. Anyone can trigger a liquidation,
including the borrower. Savings are offered through the lisUSD Savings Rate: a fixed, manually adjusted
rate compounding per block, pool cap 30M lisUSD, withdrawals immediate if liquidity allows and within
14 days otherwise. A position ends when the borrower repays lisUSD plus interest and withdraws
collateral.

### 2. DESIGN

**A MakerDAO DSS fork wrapped in a Helio-era front contract, deployed on BSC.** Live core addresses:
`VAT` 0x33A34eAB3ee892D40420507B820347b1cA2201c4, `SPOT` 0x49bc2c4E5B035341b7d92Da4e6B267F7426F3038,
`JUG` 0x787BdEaa29A253e40feB35026c3d05C18CbCA7B3, `DOG` 0xd57E7b53a1572d27A04d9c1De2c4D423f1926d0B,
`CLIP` 0x2dcFb02CE33955b6Cc0aF34033189DE3ac4C0292, `VOW` 0x2078A1969Ea581D618FDBEa2C0Dc13Fc15CB9fa7,
`ABACI` 0xc1359eD77E6B0CBF9a8130a4C28FBbB87B9501b7 (plus a separate "CLASSIC" ABACI 0xbaf8b40a…),
`JAR` 0x0a1Fd12F73432928C190CAF0810b3B767A59717e, `lisUSD`
0x0782b6d8c4551B9760e74c0545a9bCD90bdc41E5. Per-collateral join/clipper/oracle modules exist for
slisBNB, wBETH, BTCB, ezETH, weETH, Stone, solvBTC, BBTC, wstETH, USDT and FDUSD.

**Front layer.** `Interaction` is "a proxy for MakerDAO contracts" exposing deposit/withdraw and
borrow/payback; `AuctionProxy` is the entrypoint for starting and bidding in auctions; `HayJoin` mints
and burns lisUSD; `GemJoin` is the collateral treasury; `ListaDistributor` snapshots debt for reward
accounting; `Jar` manages lisUSD staking and interest distribution. A Ceros layer (`CerosRouter`,
`CeToken`, `CeVault`, `HelioProvider`) wraps BNB into the collateral token.

**Rate policy — a controller, not a vote.** The AMO is explicitly modelled on Curve's MonetaryPolicy:
rate is an exponential function of (lisUSD price from the Binance oracle, per-ilk `r0`, `Beta`),
recomputed every 15 minutes or on interaction. The docs' worked example: at $0.98 with `r0` = 8% and
`Beta` = 2%, the borrow rate becomes ≈21.746%, then clipped by the **20% cap**; `r0` itself is capped
at 200%. Initial parameters are set by the core team with future changes routed to governance.

**Liquidation.** Dutch auction with `top` = unit price × 1.02, linear decline `top × ((tau − dur)/tau)`,
paused at `tail` or `cusp` (~40%), restartable by anyone for a reward. Keeper compensation is a fixed
`tip` of **5 lisUSD** plus a governance-set `chip`, paid both for the initial trigger and for restarts.
Liquidation penalty **10%** of debt; the docs' worked example grosses $13.2 of debt to a $14.52 auction
target.

**Peg-swap.** PSM against USDT and USDC at 1:1. Mint fee 0% "at launch", with the docs stating a mint
fee may be introduced in 0.01% increments if lisUSD trades at a premium. **Redeem fee 2%**, with the
stated rationale of encouraging users to exit into other stablecoins on PancakeSwap instead. Launch cap
5M lisUSD, pre-minted into the PSM contract; **daily redemption limit 500,000 lisUSD**.

**D3M.** Mints lisUSD directly — "credit-based minting", not collateral-backed — into **Venus (Core
Pool)** and **Aave**; returns flow to the Lista DAO treasury; the lending-market rates for lisUSD on
those venues are themselves managed through the AMO.

**Oracles.** A Resilient Oracle on BNB Chain (0xf3afD82A4071f272F403dC176916141f44E6c750) and Ethereum
(0xA64FE284EB8279B9b63946DD51813b0116099301) with a **three-tier main → pivot → fallback** hierarchy
per asset across Chainlink, RedStone (including OEV feeds), Atlas and the Binance Oracle — BNB, for
example, is RedStone OEV main / Atlas pivot / Chainlink fallback — plus a `BoundValidator` enforcing
per-asset upper and lower bounds, typically 1.01 and 0.99.

**Control plane.** Governance is **off-chain Snapshot** at `snapshot.org/#/listavote.eth`. **Only core
team members may submit proposals.** Voting runs 3 days; a proposal passes on >50% of LISTA cast;
implementation follows in 1–2 weeks. Governable: withdrawal and unlock fees, new collateral, collateral
rates and debt caps, protocol fee sharing for LISTA holders, LISTA emission allocation. **The core team
retains veto rights to pause contracts or reject unsafe gauges without a poll**, subject only to an
obligation to explain. No timelock is documented. Upgradeability/proxy structure of the CDP contracts
is not documented at the pages I could reach — UNKNOWN, though the archived repo contains an
`upgrade/` directory.

**Audits.** The CDP proper is covered by five 2022 audits — Veridise 2022-06-27, SlowMist 2022-05-24
and 2022-05-10, PeckShield 2022-05-25, CertiK 2022-05-30. The dense 2025–2026 audit stream (HashDit,
Bailsec, CertiK, Cantina, BlockSec, OpenZeppelin, PeckShield, Sherlock, Spearbit, Salus) is almost
entirely for Lista Lending, Moolah, Lista V3, credit loans, RWA and the yield vaults — **not the CDP**.

### 3. REPO

- **`lista-dao/lista-dao-contracts`** — Solidity, **no licence**, default branch `master`, created
  2023-05-05, last push 2026-05-19, **ARCHIVED**, 60 stars. This is the CDP source.
  `contracts/`: `vat.sol vow.sol jug.sol dog.sol clip.sol spot.sol abaci.sol join.sol jar.sol hay.sol
  LisUSD.sol Interaction.sol CDPLiquidator.sol FlashBuy.sol flash.sol hMath.sol es.sol lock.sol` plus
  directories `amo/ ceros/ psm/ oracle/ masterVault/ snbnb/ strategy/ upgrade/ libraries/ interfaces/
  old/ mock/`. Its README still opens "# HELIO" and describes borrowing DAI against a MakerDAO vault —
  documentation for a product that no longer exists.
- Maintained repos, none of which contain the CDP core: `lista-dao/lista-new-contracts` (MIT, Foundry,
  pushed 2026-08-05; `src/` is `oracle/ rwa/ lisaster/ token/ safe/ slisXAUE/ emergencySwitchHub/`
  plus reward distributors and `BeraChainVaultAdapter.sol`); `lista-dao/moolah` (MIT, the Lending
  product); `lista-dao/lista-v2` (GPL-3.0); `lista-dao/lista-v3` ("concentrated-liquidity DEX");
  `lista-dao/synclub-contracts`; `lista-dao/lista-token` (MIT);
  `lista-dao/AuctionBots-go` (Go, the liquidation bot); `lista-dao/lista-audit` (the audit PDFs);
  `lista-dao/gitbook` (the docs source).
- **The situation to record: a live $324M CDP whose canonical repository is archived, carries no
  licence, and is named after a discontinued product, while all current engineering happens in repos
  that do not contain it.**
- **Deployed ↔ repo: UNKNOWN.** The docs publish a full address table for the CDP; I did not diff
  bytecode against any commit of the archived repo, and the repo carries no release tags corresponding
  to deployments.

### 4. EVIDENCE

| Claim | Source | Accessed |
|---|---|---|
| Documentation index | https://docs.bsc.lista.org/llms.txt | 2026-08-04 |
| CDP overview, borrow/farm/repay/withdraw, LISTA rewards for borrowing | https://docs.bsc.lista.org/introduction/collateral-debt-position-lisusd.md | 2026-08-04 |
| Collateral set: BNB, ETH, slisBNB, wBETH, BTCB, FDUSD, wstETH, USDT | https://docs.bsc.lista.org/introduction/collateral-debt-position-lisusd/collateral/classic-collateral-options.md | 2026-08-04 |
| Contracts: Interaction, Vat, GemJoin, HayJoin, ListaDistributor, Jar; borrow/liquidation flow; auction `top` = ×1.02, `tail`, `cusp` ~40% | https://docs.bsc.lista.org/for-developer/collateral-debt-position/mechanics | 2026-08-04 |
| Deployed addresses (VAT/SPOT/JUG/DOG/CLIP/VOW/ABACI/JAR/lisUSD + per-collateral modules) | https://docs.bsc.lista.org/for-developer/collateral-debt-position/smart-contract.md | 2026-08-04 |
| Liquidation: `tip` = 5 lisUSD, `chip` governance-set, **10% penalty**, anyone may trigger, linear descent | https://docs.bsc.lista.org/introduction/collateral-debt-position-lisusd/collateral/loan-liquidation | 2026-08-04 |
| **AMO**: Curve MonetaryPolicy analogue, Binance oracle price, `r0`, `Beta`, 15-minute recompute, 20% cap, `r0` ≤ 200% | https://docs.bsc.lista.org/introduction/collateral-debt-position-lisusd/lisusd/algorithmic-market-operations-amo.md | 2026-08-04 |
| **D3M**: credit-based minting into Venus Core Pool and Aave; returns to treasury | https://docs.bsc.lista.org/introduction/collateral-debt-position-lisusd/lisusd/d3m-direct-deposit-module.md | 2026-08-04 |
| PSM: USDT/USDC, 0% mint, **2% redeem**, 5M cap pre-minted, 500k/day redemption limit, PancakeSwap rationale | https://docs.bsc.lista.org/introduction/collateral-debt-position-lisusd/lisusd/stable-pool-price-stability-module-psm | 2026-08-04 |
| LSR: fixed rate, manually adjusted, per-block compounding, 30M cap, ≤14-day withdrawal | https://docs.bsc.lista.org/introduction/collateral-debt-position-lisusd/lisusd/lisusd-saving-rate-lsr.md | 2026-08-04 |
| Resilient Oracle addresses, main/pivot/fallback, Chainlink/RedStone/Atlas/Binance, BoundValidator 0.99–1.01 | https://docs.bsc.lista.org/for-developer/multi-oracle/multi-oracle-standard.md | 2026-08-04 |
| Governance: Snapshot `listavote.eth`, core-team-only proposals, 3 days, >50%, **core team veto/pause** | https://docs.bsc.lista.org/governance/lista/governance.md | 2026-08-04 |
| Audits, incl. the five 2022 CDP audits | https://docs.bsc.lista.org/security/audit-reports.md | 2026-08-04 |
| Repo metadata and trees; `lista-dao-contracts` **archived**, no licence; README "# HELIO" | `gh api repos/lista-dao/lista-dao-contracts` (+ readme, contents), `orgs/lista-dao/repos` | 2026-08-05 |
| TVL $324.3M CDP rank 3; Lista Lending separately $620.7M under `Lending` | https://api.llama.fi/protocols | 2026-08-04 |

### 5. WHAT LOOKS UNNAMEABLE

- **Reflexive collateral — confirmed but narrower than recorded.** slisBNB, Lista's own LST, is one of
  eight accepted collaterals, not "the primary collateral". The reflexivity is real; its weight is not
  established by anything I found.
- **REFUTED: "the same interest-rate-as-policy gap".** Lista does not set its borrow rate by vote. The
  AMO is a closed-loop controller on the peg error. The gap Lista arms is the **crvUSD** gap — "no
  element for a rate controller that reads the peg and sets the borrow rate automatically" — not the
  Sky gap. This matters at category level: there are **three distinct rate mechanisms** in this
  category (governance/bounded-delegate in Sky, administered-with-external-benchmark in USDD,
  closed-loop controller in Lista and crvUSD, borrower-chosen in Liquity V2), and the corpus's
  category residue collapses them into one.
- **REFUTED: "gas-compensation-only liquidation incentives".** The docs specify a fixed `tip` of 5
  lisUSD **plus** a proportional `chip`, with a 10% penalty on the debt — the standard DSS chip/tip
  structure Sky uses. The claim that Lista's liquidator receives only a gas rebate, "which changes who
  shows up", is not supported.
- **An asymmetric, quota'd peg-swap — new.** 0% in, 2% out, 5M facility, 500k/day redemption ceiling,
  and an explicit stated intent to route exit to a third-party AMM. `Ps` names a 1:1 reserve-backed
  swap. A gate that is free one way, taxed the other, capped per day, and designed to externalise its
  own exit liquidity is a materially different instrument.
- **A fallback lattice with a validity band — new.** Main → pivot → fallback per asset across four
  providers plus a hard [0.99, 1.01] `BoundValidator`. `Ex` names "external data oracle (push/pull/
  medianizer)". Nothing names an *ordered* fallback chain, and nothing names a predicate that rejects
  a price outright rather than aggregating it.
- **A D3M into two third-party lending markets the protocol does not control — new for this
  protocol.** The corpus records this gap only for Sky/Spark. It appears here too, in a smaller
  protocol, against venues (Venus, Aave) that Lista neither operates nor governs.
- **Governance with a veto and without a chain — new.** Off-chain Snapshot voting, core-team-only
  proposal rights, and a core-team veto to pause contracts. In the 58 symbols this decomposes to `Gp`
  and nothing else, and is therefore indistinguishable from a timelocked on-chain DAO with an
  emergency pause. The absence of `Tg` reads as "no timelock found" rather than "governance is not
  on-chain at all".

### 6. DELTA

1. **Ranking confirmed:** $324.3M live vs corpus $320.7M, rank 3 of CDP.
2. **The rate residue is assigned to the wrong protocol** — see above. Lista arms the crvUSD-shaped
   controller gap, not the Sky-shaped policy gap.
3. **The liquidation-incentive residue is factually wrong** — `tip` 5 lisUSD **+** `chip` **+** 10%
   penalty, identical in shape to Sky's.
4. **The reflexivity residue overstates slisBNB's role** — eight collaterals are accepted, and
   per-collateral modules exist for eleven assets.
5. **`As` may be missing from the element set.** The D3M mints lisUSD **unbacked** into Venus and Aave.
   That is closer to `As` (algorithmic supply adjustment) than to `Cd`, and the corpus decomposition
   carries neither for this behaviour.
6. **`Rd` is correctly absent** — the PSM is the only par exit and it is fee-gated at 2% with a daily
   quota, which stresses law L7 harder than the record suggests.
7. **`Em` is confirmed** — "Claim rewards in LISTA for borrowing lisUSD".
8. **A repo-status finding the corpus has no field for:** the CDP's source repository is archived and
   unlicensed while the protocol is live at $324M, and Lista's own product gravity has moved to Lista
   Lending ($620.7M, DefiLlama category `Lending`), which is nearly twice the CDP. If the category is
   defined by TVL, Lista's *CDP* ranking is stable but its institutional attention is not.

---

## Liquity (V1 + V2)

### 1. WHAT IT DOES

**V1.** Deposit ETH into a Trove and draw LUSD at a **one-time** borrowing fee — dynamic in redemption
activity, floored at 0.5% and capped at 5% — with **no interest at all**, down to a 110% minimum
collateral ratio, plus a refundable 200 LUSD Liquidation Reserve. The peg floor is a direct redemption
right: anyone may exchange LUSD for ETH at face value at any time, taken from the riskiest Troves
first. The ceiling is arbitrage against the 110% MCR. If a Trove falls below 110% it is liquidated:
the Stability Pool burns LUSD equal to the debt and receives all the collateral, so depositors
generally *profit* — the docs' worked example gives a depositor $21,800 of ETH against $20,000 of debt
cancelled. The liquidator is paid the 200 LUSD reserve plus 0.5% of the collateral. If the Stability
Pool is empty, the debt and the collateral are **redistributed pro rata to every remaining Trove**,
who never opted in. If the system-wide Total Collateral Ratio falls below 150%, Recovery Mode
activates: Troves under 150% become liquidatable, transactions that worsen the TCR are blocked, and the
borrowing fee drops to 0% to pull collateral in. There is no admin key, no governance and no upgrade
path.

**V2.** Deposit WETH, wstETH or rETH into a Trove on the matching branch (max LTV 90.91% / 83.33% /
83.33%), borrow at least 2,000 BOLD, post a refundable 0.0375 ETH gas reserve, and **choose your own
annual interest rate**, changeable whenever you like. That rate is simultaneously your cost and your
place in a queue: redemptions consume the lowest-rate Troves in a branch first, ties broken
last-in-first-redeemed, and volume is split across branches in proportion to each branch's "outside
debt" — its debt minus its own Stability Pool deposits — so redemption pressure lands on the least
self-insured market. The redemption fee is min(0.5% + baseRate, 100%) with baseRate decaying on a
6-hour half-life, and, unlike V1, **the fee stays with the redeemed borrower's collateral rather than
going to stakers**. Liquidation has three tiers tried in order: Stability Pool offset (5% penalty),
just-in-time liquidation where a liquidator supplies BOLD for 105% of collateral value, and
redistribution (up to 9.09% loss on ETH, 16.67% on LSTs). Below the Critical Collateral Ratio (150%
ETH / 160% LST) the branch enters Safety Mode and blocks withdrawals, new debt and premature rate
adjustments; below the Shutdown Collateral Ratio (110% ETH / 120% LST) the branch shuts down
permanently to new borrowing and switches to zero-fee "urgent" redemptions that pay a **2% collateral
bonus**. Redemptions no longer close Troves — a Trove redeemed to dust becomes an unredeemable
"Zombie". Troves are transferable ERC-721s. Interest revenue is split between the Stability Pool and a
router that funds Protocol Incentivized Liquidity.

### 2. DESIGN

**V2 contract architecture.** Top level: `CollateralRegistry` (maps collaterals to TroveManagers,
routes redemptions) and `BoldToken` (ERC-20 + EIP-2612). Per branch: `AddressesRegistry`,
`BorrowerOperations`, `TroveManager`, `TroveNFT`, `StabilityPool`, `SortedTroves`, `ActivePool`,
`DefaultPool`, `CollSurplusPool`, `GasPool`, and a branch `PriceFeed`. Helpers: `HintHelpers`,
`MultiTroveGetter`, `DebtInFrontHelper`, `RedemptionHelper`. Price feeds: `WETHPriceFeed`,
`WSTETHPriceFeed`, `RETHPriceFeed`, over `CompositePriceFeed` / `MainnetPriceFeedBase`. Plus
`Dependencies/`, `Interfaces/`, `NFTMetadata/`, `Types/`, `Zappers/`.

**Interest accounting.** Per-Trove interest is *simple*: `accrued = recorded_debt × annual_rate ×
elapsed`, compounded discretely whenever the Trove is touched. Branch-level aggregates
`weightedRecordedDebtSum` and `aggRecordedDebt` let pending interest be computed without iterating
Troves. Stated invariant: **"Aggregate total debt of a branch always equals the sum of individual
entire Trove debts."**

**Batch delegation.** A batch manager registers a min/max interest-rate band and an annual management
fee that **can be lowered but never raised**. The batch is modelled as a virtual shared Trove for
interest and fee accrual; when the manager changes the rate the whole slice is reinserted into
`SortedTroves` in one operation. A Buffer Collateral Ratio (BCR) adds margin above MCR for batch
members. Delegates can "do nothing else but set the interest rate in a predetermined range". Live
delegates named in the docs: Summerstone, Trove Zero
(0xe707784292289be3aa0fb6f9d33d420291f98695), Bolder Cash. Switching delegates incurs an upfront fee to
prevent batch hopping.

**Fees.** Opening or adjusting a rate charges an upfront fee equal to **7 days of average interest**,
plus a premature-adjustment fee if the rate is changed inside 7 days.

**Governance (V2 only).** LQTY staking with **voting power = LQTY staked × staking age**; new LQTY
added to an existing stake starts at zero power (flash-loan defence) and withdrawal destroys power
immediately. Weekly Thursday–Wednesday epochs; in the last 24 hours only downvoting is allowed; votes
carry forward. **25% of protocol revenue** is routed to initiatives; registering an initiative costs
0.01% of total voting power plus a **100 BOLD** fee; an initiative must clear **2% of votes** to
receive anything; incentives must be claimed in the same week or they roll forward. Voters may receive
bribes from initiatives. Contracts: `Governance.sol`, `BribeInitiative.sol`, `CurveV2GaugeRewards.sol`,
`UniV4MerklRewards.sol`, `UserProxy.sol`, `UserProxyFactory.sol`. The docs state flatly:
**"Governance has no other functions or powers, as Liquity V2's smart contracts are immutable and not
upgradeable."**

**V1 contract architecture.** `packages/contracts/contracts/`: `ActivePool.sol`,
`BorrowerOperations.sol`, `CollSurplusPool.sol`, `DefaultPool.sol`, `GasPool.sol`, `HintHelpers.sol`,
`LUSDToken.sol`, `MultiTroveGetter.sol`, `PriceFeed.sol`, `SortedTroves.sol`, `StabilityPool.sol`,
`TroveManager.sol`, plus `LQTY/`, `LPRewards/`, `Proxy/`, `Integrations/`, `Dependencies/`.

**Known issues.** The V2 README carries a register of 26+ known issues with documented mitigations,
including oracle frontrunning, redemption-routing bypasses and stale-price scenarios, with branch
shutdown as the ultimate failsafe.

### 3. REPO

- **V2 core: `github.com/liquity/bold`** — "Liquity v2 monorepo containing the contracts, subgraph and
  frontend", Solidity, created 2021-06-25, default branch `main`, **latest `main` commit
  `c8a5a4ee2e9dc024905856b6698a77d849c68c7e`, 2026-07-13T11:20:02Z**, 135 stars, not archived. Root:
  `contracts/`, `frontend/`, `subgraph/`, `INSTRUCTIONS.md`, `LICENSE`, `README.md`, `package.json`,
  `pnpm-workspace.yaml`, `dprint.json`, `vercel.json`, `.github/`. Tags are frontend releases only
  (`@liquity2/app-v1.11.0` = `3fcaf602eb36541dd298c73710e067dcad42d8ae`); **there is no contracts
  version tag**, so "the tag I inspected" is the commit above.
- **Licence: Business Source License 1.1.** Licensor **Liquity AG**; Licensed Work "Liquity V2
  Contracts (core protocol logic), (c) 2024 Liquity AG"; Additional Use Grant at
  `github.com/liquity/additional-use-grant`; **Change Date 2027-09-01**; Change License **GPL-2.0-or-later**.
  GitHub's API reports the licence as `NOASSERTION`. Non-production use is granted; production use
  requires the Additional Use Grant or a commercial licence. **Liquity V2 is source-available, not open
  source, until 2027-09-01.**
- **V2 governance: `github.com/liquity/V2-gov`** — Solidity, **MIT**, `main`, pushed 2026-06-17.
- **V1: `github.com/liquity/dev`** — "Liquity v1 monorepo containing the contracts, SDK and Dev UI
  frontend", JavaScript, **GPL-3.0**, created 2019-12-02, pushed 2025-11-26, 358 stars, not archived.
  `packages/{contracts, dev-frontend, examples, fuzzer, lib-base, lib-ethers, lib-react, lib-subgraph,
  providers, subgraph}`.
- Adjacent: `liquity/bold-ir-management` (Rust, MIT) — the Autonomous Interest Rate Manager, running on
  the Internet Computer; `liquity/docs-v1`, `liquity/docs-v2`; the archived `liquity/liquity` and
  `liquity/beta`.
- **Deployed ↔ repo.** The docs' Technical Docs and Audits page publishes the whitepaper (IPFS CID
  `bafybeihjijrgmytiwb4t7mqgogyyupbn342rregwff7fprlqjytko242ma`), both repository links, and full
  mainnet addresses for the core shared contracts, the ETH/wstETH/rETH branches and governance, each
  with a block-explorer link. BOLD is deployed on Mainnet, Base, Arbitrum, HyperEVM, Optimism, Scroll,
  Avalanche, Sonic, Berachain and Swell. **I did not diff bytecode**; correspondence is stated by the
  docs, not verified here.
- **Audits (V2):** ChainSecurity (multiple, Aug 2024 – May 2025), Dedaub Report I (Aug 2024), Dedaub
  Report II (Nov 2024), **Certora formal verification (Dec 2024)**, Coinspect Bold Core (Dec 2024),
  Recon (Oct 2024), Dedaub Cantina fixes review (May 2025), Cantina competition (Mar–Apr 2025),
  Coinspect Redemption Helper (Oct 2025). Governance: Coinspect (Jan 2025), ChainSecurity (Jan 2025),
  Dedaub ×3 (Aug/Nov/Dec 2024). Economics: Chaos Labs mechanism design review (Oct 2024).

### 4. EVIDENCE

| Claim | Source | Accessed |
|---|---|---|
| V2 architecture, interest accounting, invariant, batches/BCR, redemption routing formula, zombie Troves, branch shutdown, known-issues register, contract list | https://github.com/liquity/bold (README, `main`) | 2026-08-04 |
| Repo metadata, `main` commit `c8a5a4ee…` 2026-07-13, tag list, root and `contracts/src` trees | `gh api repos/liquity/bold`, `.../commits/main`, `.../tags`, `.../contents/...` | 2026-08-05 |
| **BUSL-1.1**, Licensor Liquity AG, Change Date 2027-09-01 → GPL-2.0-or-later, Additional Use Grant | `gh api repos/liquity/bold/contents/LICENSE` | 2026-08-05 |
| V1 repo GPL-3.0, package/contract layout | `gh api repos/liquity/dev`, `.../contents/packages/contracts/contracts` | 2026-08-05 |
| V2-gov MIT, `src/` contract list | `gh api repos/liquity/V2-gov`, `.../contents/src` | 2026-08-05 |
| V2 collateral set, max LTVs, 2,000 BOLD minimum, 0.0375 ETH gas reserve, 7-day upfront fee, 3-tier liquidation with 5%/9.09%/16.67%, CCR/SCR, shutdown +2% bonus | https://docs.liquity.org/v2-faq/borrowing-and-liquidations.md | 2026-08-04 |
| Redemption ordering by rate, last-in-first-redeemed ties, outside-debt split, fee = min(0.5%+baseRate,100%) with 6h half-life, **fee stays with the user**, delegate types and named delegates, debt-in-front | https://docs.liquity.org/v2-faq/redemptions-and-delegation | 2026-08-04 |
| LQTY voting power = stake × age, weekly epochs, 25% of revenue, 2% threshold, 100 BOLD registration, claim-same-week, bribes | https://docs.liquity.org/v2-faq/lqty-staking.md | 2026-08-04 |
| "Immutability, Decentralization, Rigorous security, No TradFi exposure"; "Governance has no other functions or powers… immutable and not upgradeable" | https://docs.liquity.org/v2-faq/general.md | 2026-08-04 |
| V1: interest-free, 110% MCR, one-off fee 0.5–5%, "no admin key… non-custodial, immutable, and governance-free" | https://docs.liquity.org/liquity-v1/faq/general.md | 2026-08-04 |
| V1 Stability Pool, 200 LUSD + 0.5% ETH gas compensation, worked example, redistribution when the pool empties | https://docs.liquity.org/liquity-v1/faq/stability-pool-and-liquidations.md | 2026-08-04 |
| V1 Recovery Mode at 150% TCR, sub-150% Troves liquidatable, TCR-worsening txs blocked, borrowing fee 0% | https://docs.liquity.org/liquity-v1/faq/recovery-mode.md | 2026-08-04 |
| Whitepaper CID, repo links, address tables, full audit list | https://docs.liquity.org/v2-documentation/technical-docs-and-audits.md | 2026-08-04 |
| TVL: Liquity V1 $137.6M, Liquity V2 $70.6M, both category CDP | https://api.llama.fi/protocols | 2026-08-04 |

### 5. WHAT LOOKS UNNAMEABLE

**All five corpus residues are confirmed.** Borrower-set rates as redemption ordering; delegation of a
risk parameter to a third-party manager; immutability as a positive commitment; revenue-to-liquidity by
stake-weighted vote with no vote-escrow; and V1's dynamic MCR regime switch. Three sharpenings and
seven additions:

- **Sharpening the queue residue.** It is not only that the rate buys queue position *within* a market.
  Redemption volume is allocated *across* markets by a solvency statistic — branch debt minus that
  branch's own Stability Pool deposits — so the least self-insured branch absorbs the most redemption
  pressure. That is a cross-market risk-allocation rule computed from insurance coverage, and nothing
  in 58 symbols reaches it.
- **Sharpening the immutability residue.** V2 is not ungoverned. It has governance with a **strictly
  bounded mandate**: direct PIL and nothing else, over immutable contracts. That is a third state
  between "governed" and "ungovernable", and recording it as "absence of `Up`, `Tg`, `Gp`" erases the
  distinction between it and V1's genuine ungovernability.
- **Sharpening the `Bs` mis-fit.** The corpus notes that the Stability Pool is first-loss capital that
  is *paid* rather than slashed. V2 goes further: the SP now also receives a share of interest revenue,
  so it earns a running yield on top of the liquidation discount. A paid, yielding, opt-in first-loss
  class.
- **Zombie Troves — new.** A position redeemed below the minimum debt enters a state where it can no
  longer be redeemed but still exists and still accrues interest. No symbol admits a
  terminal-but-not-closed position.
- **Three ordered liquidation tiers with different payers and different penalties — new.** SP offset at
  5%, then just-in-time liquidation at 105% of collateral value, then redistribution at up to 9.09% /
  16.67%. `Li` presumes one path paid to a third party.
- **The debt position as a transferable NFT — new.** Troves are ERC-721. Nothing says a liability is
  itself a tradable object, or that one address may hold many of them.
- **A fee that is not distributed to anyone — new.** The V2 redemption fee is retained inside the
  redeemed borrower's collateral. `Fd` names surplus and fee *distribution*. Here the fee exists purely
  to make redemption unprofitable at the margin and has no residual claimant at all.
- **An upfront fee equal to seven days of the borrower's own chosen rate, plus a premature-adjustment
  fee — new.** A commitment device that prices the option to re-price yourself, denominated in the
  parameter being priced.
- **Shutdown as a per-market event that *improves* the redeemer's terms — new.** Sky's `End` is a
  global settlement that freezes. Liquity V2's shutdown is per branch and switches redemption to zero
  fee plus a 2% collateral bonus, i.e. it pays people to unwind the branch.
- **A monotone delegated parameter — new.** A batch manager's fee can be lowered but never raised. `Au`
  bounds a delegated scope; nothing names one-way ratchets on delegated authority.
- **A source-available licence on a protocol whose identity is permissionlessness — new, and it is a
  control-plane fact, not a mechanism.** V2's core contracts are BUSL-1.1 under Liquity AG with a
  Change Date of 2027-09-01. If any construction in the paper asserts permissionless forkability as a
  property of this category, this is the counterexample.

### 6. DELTA

1. **Ranking confirmed:** V1 $137.6M + V2 $70.6M = $208.2M vs corpus $207.9M, rank 4 of CDP.
2. **`Ex` is correctly present, and the oracle layer is richer than one symbol suggests.** (Checked:
   the corpus carries `Ex` in both `elements` and `canonicalForm` for Liquity, so law L1a is
   satisfied.) But V2 ships **five** price-feed contracts — `WETHPriceFeed`, `WSTETHPriceFeed`,
   `RETHPriceFeed` over `CompositePriceFeed` and `MainnetPriceFeedBase` — one per branch, with
   composite feeds for the LST branches (an ETH/USD feed composed with an LST/ETH exchange rate), and
   the known-issues register devotes several entries to oracle frontrunning and stale prices with
   branch shutdown as the terminal mitigation. A single `Ex` cannot distinguish a direct feed from a
   composed one, and composition is exactly where the LST branches' risk lives.
3. **`Em` is questionable for V2.** V1 emitted LQTY. V2's analogue is PIL, funded from **protocol
   revenue**, not from token issuance — which is `Fd`-shaped, and the corpus already carries `Fd` for
   the V2 split. Carrying `Em` for the combined V1+V2 entity blurs a real change of funding source.
4. **Treating V1 and V2 as one protocol under one `Rd` hides the most interesting fact in the lane.**
   The corpus marks `Rd` "EXACT, noted for contrast… which suggests the symbol was written from it" —
   true of **V1**. V2's redemption is ordered by a price the borrower chose, split across branches by an
   insurance-coverage statistic, and charges a fee that is retained by the person redeemed against.
   Same symbol, different instrument. This is precisely the collapse the vocabulary is meant to detect,
   and it is happening *inside* one corpus entry.
5. **The immutability residue needs a third value.** V1: no admin, no governance, no upgrade — confirmed
   verbatim. V2: immutable and non-upgradeable contracts **plus** a governance system with exactly one
   power. The corpus treats the residue as binary.
6. **A licence fact the corpus has no field for:** V2 is BUSL-1.1 until 2027-09-01 (then GPL-2.0+),
   V1 is GPL-3.0, V2-gov is MIT. Three different licences inside one "protocol".
7. **Confirmed against the code, not just the docs:** `SortedTroves`, `CollateralRegistry`,
   `StabilityPool`, `TroveNFT`, `RedemptionHelper`, `DebtInFrontHelper` all exist in
   `contracts/src` at `c8a5a4ee…`, so the FAQ's mechanism descriptions correspond to shipped contracts.

---

## Cross-lane note for the next stage

Three findings cut across the five and should not be lost when this file is decomposed:

1. **There is no single "interest-rate" gap in this category — there are four distinct instruments.**
   Sky: governance-set `duty`/`ssr`, *plus* a deployed bounded-delegate rate setter (SP-BEAM). USDD:
   an administered savings rate with a published reaction function over external benchmarks (7-day MA
   of competitor yields, the Fed rate, a market premium). Lista: a closed-loop controller on the peg
   error, recomputed every 15 minutes and capped at 20%. Liquity V2: a rate chosen by each borrower,
   which also determines their redemption priority. The corpus's category residue treats these as one
   missing symbol. They are four different objects and at least three of them need separate names.
2. **The Dutch auction is used by three of the five, and by the same code.** Sky, USDD and Lista all
   run DSS Liquidations 2.0 with the same parameter names — `buf`, `tail`, `cusp`, `chip`, `tip`,
   `chost`, `chop`, `hole`/`dirt` — and the same `kick`/`take`/`redo` interface, verified against three
   independent documentation sites and two source trees. Liquity uses no auction at all (Stability
   Pool offset → just-in-time liquidation → redistribution). The corpus called contested `Da` "the
   strongest promotion candidate" on 3-of-5 usage; the finding here is stronger than a usage count —
   it is the *same implementation* three times, which means promoting `Da` would let the algebra see
   that Sky, USDD and Lista share a settlement engine rather than merely a settlement style.
3. **The control plane is where the vocabulary is thinnest.** Sky has ten Mom contracts whose only
   purpose is to make the timelock directional. Lista has no timelock and no on-chain vote at all, plus
   a core-team veto. Ethena has 43 privileged EOAs and no stated timelock anywhere. Liquity V2 has
   immutable contracts and a governance system with exactly one power. USDD's control plane is
   undocumented. In the 58 symbols, all five of these decompose to some subset of {`Tg`, `Up`, `Gp`},
   and four of the five are indistinguishable from one another. That is a larger residue than the
   monetary-policy one and the corpus does not record it at all.
