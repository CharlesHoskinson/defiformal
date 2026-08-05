# Stage 1 research — Liquid staking & restaking

Category slug `04-liquid-staking`. Five applications: Lido, Binance staked ETH (WBETH),
EigenCloud (EigenLayer), ether.fi (eETH / weETH), Babylon Protocol.
Researched 2026-08-04. All access dates below are **2026-08-04** unless stated otherwise.

**Source quality for this category is unusually uneven, and the unevenness is itself a
finding.** Four of the five protocols are open-source with first-party specification
documents: Lido publishes per-contract docs plus LIPs, EigenLayer ships its architecture
docs *inside* the contract repo (`docs/core/*.md`) alongside ELIPs, ether.fi's repo is
readable Solidity with in-file invariant natspec, and Babylon publishes both a Go
implementation with per-module `README.md` and a machine-readable mainnet parameter file.
For those four I was able to read primary artefacts — source, parameters, licences,
release tags — not marketing. The fifth, WBETH, has no protocol documentation at all: the
only first-party text is exchange help-centre copy and a research blurb, and the only hard
evidence is the deployed bytecode. I therefore reconstructed WBETH from verified on-chain
source via Blockscout/Sourcify, which turned out to be far more informative than the
corpus record assumes. Two hosts blocked automated fetch and forced workarounds:
`etherscan.io` (403) and `docs.eigencloud.xyz` (403); for both I substituted primary
equivalents (Blockscout/Sourcify verified source; the in-repo EigenLayer docs and the
`eigenfoundation/ELIPs` repo). One further caution: Lido, EigenLayer and ether.fi have all
shipped major releases *since* the corpus record was written, and several corpus claims are
now stale rather than wrong. Those are recorded under DELTA per app, not silently corrected.

---

## Lido

### 1. WHAT IT DOES

A user sends ETH to the Lido core pool and receives stETH at 1:1 on deposit. stETH is a
**rebasing** ERC-20: the holder's nominal balance is recomputed daily when an oracle
committee reports consensus-layer balances, so rewards arrive as an increase in balance
rather than in price; wstETH is the non-rebasing wrapper for integrations that cannot
tolerate a moving balance. The protocol pools the ETH, batches it into validator deposits,
and allocates those deposits across a registry of *staking modules*, each of which is a
different set of node operators under a different trust model. Rewards accrue net of a
protocol fee (currently 10% of rewards) and losses — penalties, slashings, missed
attestations — arrive the same way, as a **negative** rebase applied to the entire stETH
supply irrespective of which operator caused them. Exit is a two-stage affair: the user
burns stETH into a withdrawal queue and receives an ERC-721 (`unstETH`) representing a
place in that queue; separately, and invisibly to the user, the protocol must actually
exit validators on the beacon chain to raise the ETH, which is signalled by a second
oracle and executed by operators (or forced via EIP-7002 triggerable withdrawals). Once
the oracle finalises a batch, the request's redemption rate is frozen and the NFT holder
claims ETH. Since 2026-01-30 there is a second product surface, **stVaults**: a user or
institution can run an isolated staking position with a chosen node operator and
optionally mint stETH against it, over-collateralised rather than 1:1. Governance is
bicameral: LDO holders vote, but stETH holders can escrow their stETH to delay or, past a
threshold, block execution and exit ("rage quit").

### 2. DESIGN

**Core accounting.** `Lido` (stETH) at `0xae7ab96520DE3A18E5e111B5EaAb095312D7fE84` is a
proxy holding a share ledger; balances are shares × (totalPooledEther / totalShares).
`wstETH` (`0x7f39C581F595B53c5cb19bD0b3f8dA6c935E2Ca0`) wraps shares directly. An
`Accounting` path recomputes total pooled ether on each oracle report and mints fee shares.
A lever `setMaxExternalRatioBP()` caps the share of stETH that may be backed by external
(stVault) collateral rather than by the core pool.

**Module registry and allocation — `StakingRouter`** (`0xFdDf38947aFB03C621C71b06C9C70bce73f12999`,
proxy). This is the top-level controller over a registry of staking modules. Each module
carries a unique id, a **stake share limit** (relative hard cap), a **priority exit share
threshold**, a module fee and a treasury fee, deposit rate limits, and a withdrawal-credential
type (`0x01` or `0x02`). Module status is one of Active / DepositsPaused / Stopped.
Allocation of incoming ETH uses **`MinFirstAllocationStrategy`**: fill the least-allocated
modules first, in 32-ETH units, until the amount is exhausted or capacity is reached. Live
modules on mainnet: **Curated** (`NodeOperatorsRegistry`, `0x55032650b14df07b85bF18A3a3eC8E0Af2e028d5`)
— permissioned, professional operators, **no bond**; **Simple DVT**
(`0xaE7B191A31f627b4eB1d4DaC64eaB9976995b433`) — permissioned onboarding, distributed
validators over Obol and SSV, 36 Obol + 36 SSV clusters plus 5 + 5 "super clusters",
management by 5/7 SAFE multisig, stake share limit 4%; **CSM** (`CSModule`,
`0xdA7dE2ECdDfccC6c3AF10108Db212ACBBf9EA83F`) — permissionless, operators post a **stETH
bond** on a decreasing curve (portal states "from 2.4 to 1.3 ETH based on the Bond Curve"),
stake share limit 9%. Fee split is per-module: Curated 5% operators / 5% DAO; the
permissionless module 3.5% / 6.5%; CSM v2 blended; all modules leave 90% to stakers.

**Deposit front-running defence — `DepositSecurityModule`** (`0xF573E9E3de1f86B085417ab294f56E7920B4e9Be`).
This exists solely to defeat one attack: a malicious operator front-running
`depositBufferedEther` with a ≥1 ETH direct deposit using the same pubkey but *different*
withdrawal credentials, thereby capturing Lido's 32 ETH. A guardian committee runs an
off-chain daemon that vets on-chain state and signs (EIP-2098 short ECDSA) over
`(blockNumber, blockHash, depositRoot, stakingModuleId, nonce)`. Quorum is documented as
**4 of 6**. Guardians can also `unvetSigningKeys()` with a **single** signature (bounded by
`maxOperatorsPerUnvetting`) and `pauseDeposits()` unilaterally, with validity bounded by
`pauseIntentValidityPeriodBlocks`. `maxDepositsPerBlock` / `minDepositBlockDistance` are set
per-module on the StakingRouter.

**State reporting — `AccountingOracle`** (`0x852deD011285fe67063a08005c71a85690503Cee`) over a
`HashConsensus` committee (>half; documented as 5 of 9) on frames of **225 consensus-layer
epochs**. The report carries `clValidatorsBalanceGwei`, `clPendingBalanceGwei`,
`stakingModuleIdsWithNewlyExitedValidators` / `numExitedValidatorsByStakingModule`,
`stakingModuleIdsWithUpdatedBalance` / `validatorBalancesGweiByStakingModule`,
`withdrawalVaultBalance`, `elRewardsVaultBalance`, `sharesRequestedToBurn`,
`withdrawalFinalizationBatches`, `simulatedShareRate` (1e27), `isBunkerMode`, and — new in
V3 — `vaultsDataTreeRoot` / `vaultsDataTreeCid`. `submitReportData()` runs sanity checks via
`OracleReportSanityChecker`, updates exited counts and per-module balances, finalises the
withdrawal queue, performs the rebase and fee distribution, then updates vault data.
This is a **quorum-signed report of protocol state, not a price**.

**Exit signalling — `ValidatorsExitBusOracle` (VEBO)** (`0x0De4Ea0184c2ad0BacA7183356Aea5B8d5Bf5c6e`),
explicitly "an on-chain message bus between the protocol's off-chain oracle and off-chain
observers". Exit requests are packed 64-byte (`DATA_FORMAT_LIST`: moduleId 3B, nodeOpId 5B,
validatorIndex 8B, pubkey 48B) or 72-byte (`DATA_FORMAT_LIST_WITH_KEY_INDEX`, +8B key index,
required for oracle reports), sorted ascending by `(moduleId, nodeOpId, validatorIndex)`.
Two limits apply: a per-report cap (`setMaxValidatorsPerReport()`) and an ETH-denominated
frame limit restoring at 32 ETH per `0x01` validator and 2048 ETH per `0x02` validator.
`triggerExits()` submits EIP-7002 triggerable-withdrawal requests through a gateway with
`msg.value` covering the EIP-7002 fee. Operator compliance is governed by an off-chain
social norm, the "Lido on Ethereum Validator Exits SNOP 3.0".

**User withdrawal — `WithdrawalQueueERC721`** (`0x889edC2eDab5f40e902b864aD4d7AdE8E412F9B1`).
Request → finalise → claim. Minimum request **100 wei**, maximum **1000 ETH**. Finalisation
is performed by the accounting oracle path (`prefinalize()` then `finalize()`) at a maximum
share rate (1e27), which locks ether and burns stETH; checkpoints let `findCheckpointHints()`
resolve a claim cheaply. The NFT is ERC-721 + ERC-4906.

**stVaults (Lido V3, live on mainnet 2026-01-30).** `StakingVault` is an isolated position
with one owner and one node operator, and is itself the `0x02` withdrawal-credential target,
so the operator never custodies ETH. `VaultHub` (`0x1d201BE093d847f6446530Efb0E8Fb426d176709`)
is the registry and enforcer: per-vault **liability** (stETH shares minted), **reserve ratio
(RR)**, **force-rebalance threshold (FRT ≤ RR)**, **share limit**, **total value**, and
`locked = liability + max(calculatedReserveFromRR, max(connectDeposit, slashingReserve))`.
A **1 ETH connect deposit** is an anti-sybil bond locked for the connection's life. Vault
obligations are strictly ordered: health obligation → redemptions (to service Lido core
withdrawals) → Lido fees. `LazyOracle` (`0x5DB427080200c235F2Ae8Cd17A7be87921f7AD6c`) posts
Merkle-rooted vault state; a report is **fresh** only if it matches the latest checkpoint and
is under **two days** old, and staleness blocks withdrawals, minting, rebalancing, beacon
deposits and disconnection. It also runs a **quarantine**: value jumps above routine EL/CL
rewards sit in a timelocked buffer. `OperatorGrid`
(`0xC69685E89Cefc327b43B7234AC646451B27c544d`) groups vaults into operator groups and tiers
(share limit, RR, FRT, fees), requires dual confirmation from owner and operator for tier
changes, and gives the DAO a **jail** power that blocks minting while permitting burns.
`PredepositGuarantee` (`0xF4bF42c6D6A0E38825785048124DBAD6c9eaaac3`) is the vault-side
front-running defence: operator locks a 1 ETH guarantee, submits a 1 ETH predeposit, PDG
stages 31 ETH, and on validator appearance the withdrawal credentials are proved via
EIP-4788 (BLS12-381 verification per EIP-2537); wrong credentials mean PDG **seizes the
guarantee**. Policies are STRICT / ALLOW_PROVE / ALLOW_DEPOSIT_AND_PROVE. `Dashboard` is an
optional role-based owner layer that also does node-operator fee accounting on a high-water
mark: `growth = totalValue − inOutDelta`; `unsettled = max(growth − settledGrowth, 0)`;
`fee = unsettled × feeRate`, with fees above 1% of total value requiring admin verification.

**Asserted invariants (stVaults design doc).** (i) stETH solvency — "all existing stETH can
be converted into ETH at a 1:1 ratio"; (ii) stVault users do not depress core stETH APR;
(iii) slashing consequences are contained within the operator group; (iv) reserve ratio is
DAO-set only; (v) below FRT a vault is unhealthy — no minting, withdrawal, validator
deposit or full partial withdrawal, and permissionless force-rebalancing applies.

**Control plane — Dual Governance (LIP-28).** `DualGovernance` at
`0xC1db28B3301331277e307FDCfF8DE28242A4486E` is a dynamic timelock between DAO motions and
execution. stETH / wstETH / withdrawal NFTs are escrowed to signal dissent, with a minimum
**5-hour** lock. States: Normal → VetoSignalling → (VetoSignallingDeactivation) →
VetoCooldown, or → RageQuit. **First seal 1%** of stETH supply starts the timelock growing;
**second seal 10%** triggers rage quit, blocking all execution until escrowed stETH is fully
withdrawn to ETH. Parameters: min proposal execution timelock **3 days**; dynamic timelock
**5–45 days**; rage-quit extension **7 days**; ETH withdrawal delay **60–180 days**. Three
committees sit alongside: Reseal, Emergency (4/7 and 5/7), Tiebreaker (2/3).

**Loss path.** Penalties and slashings appear as a lower `clValidatorsBalanceGwei` in the
accounting report and are absorbed as a **negative rebase across the whole stETH supply**;
there is no attribution of the loss to the operator or module that caused it (CSM bonds are
a separate, module-local penalty instrument). Bunker mode (`isBunkerMode`) changes
withdrawal finalisation behaviour under mass-slashing conditions.

### 3. REPO

- **Canonical:** https://github.com/lidofinance/core — "Lido DAO smart contracts".
  **Licence GPL-3.0. Language Solidity** (Hardhat + Foundry + TypeScript).
  **Latest release `v4.0.0`, published 2026-07-24T16:04:56Z, target `master`**, implementing
  **LIP-35: Staking Router v3** and carrying a 07-2026 Certora Staking Router v3 audit.
  (The GitHub "latest release" widget also shows `v3.0.2` on the repo landing page; the API
  is authoritative — `v4.0.0`.) Top level: `contracts/` (versioned by compiler:
  `0.4.24/`, `0.6.11/`, `0.6.12/`, `0.8.9/`, `0.8.25/`, plus `common/`, `openzeppelin/`,
  `tooling/`, `upgrade/`, `COMPILERS.md`), `docs/`, `foundry/lib/`, `lib/`, `scripts/`,
  `tasks/`, `test/`, `.github/`, `.husky/`.
- **Satellite repos:** `lidofinance/community-staking-module` and the consolidated
  `lidofinance/staking-modules` (CSM v2 lives here); `lidofinance/lido-improvement-proposals`
  (LIP-28 Dual Governance, LIP-35 Staking Router v3); `lidofinance/docs`;
  `lidofinance/audits`.
- **Deployed vs repo:** deployed addresses are published first-party at
  `https://docs.lido.fi/deployed-contracts/` and the principal contracts are **proxies**
  (stETH, StakingRouter, AccountingOracle, VEBO, WithdrawalQueue, VaultHub, OperatorGrid,
  PredepositGuarantee, LazyOracle, LazyOracle, CSModule, both operator registries). I did
  **not** perform a byte-level source-vs-deployment diff. **UNKNOWN: exact deployed
  implementation ↔ repo commit correspondence.** What is verifiable is that the repo
  publishes deployment scripts and that audits are named per release.

### 4. EVIDENCE

| Claim | Source | Accessed |
|---|---|---|
| StakingRouter role, module registry, MinFirstAllocationStrategy, 0x01/0x02 WC types, fee equality constraint | https://docs.lido.fi/contracts/staking-router | 2026-08-04 |
| DSM attack description, 4/6 quorum, EIP-2098 signature payload, unvetSigningKeys, pauseIntentValidityPeriodBlocks | https://docs.lido.fi/contracts/deposit-security-module/ | 2026-08-04 |
| Front-running vulnerability history and guardian council origin | https://research.lido.fi/t/mitigations-for-deposit-front-running-vulnerability/1239 ; https://github.com/lidofinance/lido-improvement-proposals/blob/develop/LIPS/lip-5.md | 2026-08-04 |
| AccountingOracle report fields, 225-epoch frame, 5-of-9 consensus, processing order, vaultsDataTreeRoot | https://docs.lido.fi/contracts/accounting-oracle | 2026-08-04 |
| VEBO formats, sort key, 32/2048 ETH frame limits, `triggerExits()` EIP-7002, SNOP 3.0 | https://docs.lido.fi/contracts/validators-exit-bus-oracle | 2026-08-04 |
| WithdrawalQueue min 100 wei / max 1000 ETH, finalize/prefinalize, checkpoints, ERC-721+4906 | https://docs.lido.fi/contracts/withdrawal-queue-erc721 | 2026-08-04 |
| stVaults architecture, RR/FRT, locked formula, 1 ETH connect deposit, obligation ordering, LazyOracle 2-day freshness + quarantine, OperatorGrid tiers + jail, PDG 1 ETH guarantee / 31 ETH staged / EIP-4788 / EIP-2537, Dashboard fee high-water mark, the five invariants | https://hackmd.io/@lido/stVaults-design | 2026-08-04 |
| Lido V3 mainnet launch 2026-01-30; 1%→0% infra fee to 2026-03-31 for identified vaults >250 ETH | https://blog.lido.fi/lido-v3-is-live-modular-infrastructure-for-a-new-paradigm-of-ethereum-staking/ | 2026-08-04 |
| Lido V3 technical paper exists, Dec 2025 release; names VaultHub, StakingVault, PDG, LazyOracle, Dashboard, OperatorGrid | https://docs.lido.fi/lido-v3-whitepaper/ | 2026-08-04 |
| LIP-28 Dual Governance: states, 1% / 10% seals, 3d execution timelock, 5–45d dynamic, 7d rage-quit extension, 60–180d ETH withdrawal delay, 5h min lock, Reseal/Emergency/Tiebreaker committees | https://github.com/lidofinance/lido-improvement-proposals/blob/develop/LIPS/lip-28.md (raw) | 2026-08-04 |
| LIP-35 Staking Router v3: clValidatorsBalance/clPendingBalance, 0x01 vs 0x02 (2048 ETH), TopUpGateway, ConsolidationGateway/Bus/Migrator, balance-proportional module rewards, deposit reserve, 1.25 ETH top-up margin, 2 ETH min top-up, 19,200 ETH VEBO exit limit | https://github.com/lidofinance/lido-improvement-proposals/blob/develop/LIPS/lip-35.md (raw); https://research.lido.fi/t/staking-router-v3-design-implementation-proposal-lip-35/11621 | 2026-08-04 |
| Repo licence GPL-3.0, Solidity, top-level layout | https://github.com/lidofinance/core ; https://api.github.com/repos/lidofinance/core/contents/contracts | 2026-08-04 |
| Release v4.0.0 tag/date/target and LIP-35 body | https://api.github.com/repos/lidofinance/core/releases/latest | 2026-08-04 |
| Mainnet addresses (stETH, wstETH, StakingRouter, DSM, AccountingOracle, VEBO, LazyOracle, WithdrawalQueue, NOR, SimpleDVT, CSModule, VaultHub, OperatorGrid, PDG, DualGovernance) | https://docs.lido.fi/deployed-contracts/ | 2026-08-04 |
| Protocol fee 10%; per-module split Curated 5/5, permissionless 3.5/6.5, CSM v2 blended; 90% to stakers; DAO sets the rate | https://lido.fi/how-lido-works/protocol-fee | 2026-08-04 |
| Fee 10% split between node operators and DAO treasury (help-centre article, last updated 2023-11-22) | https://help.lido.fi/en/articles/5230596-what-fee-is-applied-by-lido-what-is-this-used-for | 2026-08-04 |
| CSM: bond concept, FIFO stake-allocation queue + priority queues, bond "from 2.4 to 1.3 ETH", 9% stake limit, 10% rewards share (4–8% treasury / 2–6% module), EIP-7002 ejection on excessive strikes | https://docs.lido.fi/staking-modules/csm/intro ; https://operatorportal.lido.fi/modules/community-staking-module | 2026-08-04 |
| Simple DVT: Obol + SSV, 36+36 clusters + 5+5 super clusters, 5/7 SAFE multisig, 4% stake share limit, 10% rewards share (treasury 2%/4%, module 8%/6%), permissioned onboarding, onboarding closed | https://operatorportal.lido.fi/modules/simple-dvt-module ; https://blog.lido.fi/a-year-with-simple-dvt-strengthening-ethereum-staking-through-diversity-and-resilience/ | 2026-08-04 |
| Three-module trust model; only CSM requires a bond | https://lido.fi/how-lido-works/lido-node-operators-set-overview | 2026-08-04 |
| stVaults audits (Consensys Diligence Jun–Aug 2025 + Oct–Nov 2025 fix review; Certora 01-2026) | https://diligence.security/audits/2025/08/lido-v3/ ; https://www.certora.com/reports/lido-v3-audit-01-2026 ; https://docs.lido.fi/security/audits/ | 2026-08-04 |
| Protocol levers exist (`setStakingLimit`, `setMaxExternalRatioBP`, `setStakingModuleFees`) but the page carries no current numeric values | https://docs.lido.fi/guides/protocol-levers/ | 2026-08-04 |

### 5. WHAT LOOKS UNNAMEABLE

Confirming the corpus claim about `Vl`, mechanism by mechanism, against the code and docs.
`Vl` ("staking & validator lifecycle") is standing for **six** separable mechanisms in Lido,
not five, and each has its own contract, its own state and its own distinct failure mode:

1. **Operator-set curation.** Who may run validators, under what cap, with what onboarding
   and what removal. Three parallel and *incompatible* answers coexist — Curated
   (permissioned, unbonded), Simple DVT (permissioned, cluster-managed by 5/7 multisig),
   CSM (permissionless, bonded). Confirmed: three registries, three trust models, one symbol.
2. **Stake allocation and scheduling.** `StakingRouter.MinFirstAllocationStrategy` is a
   *scheduler* over heterogeneous counterparties with per-module hard caps and per-module
   deposit rate limits. This is a distinct algorithmic object; nothing in the vocabulary
   names a scheduler. Confirmed.
3. **Deposit front-running defence.** `DepositSecurityModule` — and now, separately, the
   vault-side `PredepositGuarantee` — exist for one adversary and one attack. This is not a
   permission gate: the guardians do not decide *who* may deposit, they attest that a
   specific block's `depositRoot` has not been poisoned. Confirmed, and the corpus
   *understates* it: V3 added a **second, structurally different** anti-front-running
   mechanism (predeposit + EIP-4788 credential proof + guarantee seizure) that the
   committee-signature framing does not cover at all.
4. **Exit signalling and the validator-side exit queue.** VEBO's message bus, the
   ETH-denominated frame limits, operator compliance under an off-chain norm (SNOP 3.0),
   and EIP-7002 forced exits are a full mechanism that must complete *before* the user's
   withdrawal queue can pay. Confirmed.
5. **Penalty attribution.** Losses socialise across the whole stETH supply, and CSM's bond
   is a *separate*, module-local penalty rail with strikes and EIP-7002 ejection. One
   protocol runs two loss regimes simultaneously. Confirmed.
6. **Validator sizing and consolidation** (new, not in the corpus). LIP-35 introduces
   `0x01` (32 ETH) vs `0x02` (up to 2048 ETH) credentials, `TopUpGateway` for adding stake
   to a live validator, and a three-contract consolidation pipeline
   (`ConsolidationMigrator` → `ConsolidationBus` → `ConsolidationGateway`) for migrating
   stake between operators. Merging existing validators and topping up a live one are
   neither "registration" nor "exit"; `Vl` has no place to put them.

Further mechanisms with no plausible name in the 58:

- **Bicameral governance with an exit-based veto.** Dual Governance's escrow is not a
  timelock and not a vote: it is a *second chamber whose ballot is a redemption*, with a
  state machine, two thresholds, and a rage-quit that converts dissent into an actual
  15-vault-deep withdrawal. Nothing names a governance body whose dissent instrument is
  leaving.
- **Distributed validator technology.** One key split across a 7-member cluster with a
  signing threshold, over two different implementations (Obol, SSV). Confirmed unnameable.
- **Over-collateralised minting of the pool token against an isolated external position.**
  stVaults' RR / FRT / share-limit / force-rebalance machinery is a full CDP-shaped system
  whose collateral is *a validator set*, and whose liquidation is a permissionless
  rebalance rather than a sale. The corpus record contains no trace of it.
- **A freshness-gated Merkle state oracle with a value quarantine.** LazyOracle's two-day
  freshness gate and its timelocked buffer for anomalous value increases is an
  anti-manipulation device on an *oracle*, not on a price.
- **Vault "jail"** — a DAO power to block minting on a specific vault while permitting
  burns and administrative operations. Neither a pause nor a permission gate.
- **Bunker mode** — a protocol-wide mode switch that changes withdrawal finalisation
  semantics under mass slashing.

### 6. DELTA

- **The corpus record predates Lido V3 entirely.** stVaults went live on Ethereum mainnet
  **2026-01-30** (blog.lido.fi, accessed 2026-08-04), adding VaultHub, StakingVault,
  OperatorGrid, LazyOracle, PredepositGuarantee and Dashboard, and with them an
  over-collateralised minting path, a per-vault reserve-ratio/force-rebalance system, a
  vault jail, a value quarantine and a second anti-front-running mechanism. The 13-symbol
  decomposition and the five residue entries in `04-liquid-staking.json` describe Lido V2.
- **The corpus record predates Staking Router v3.** `lidofinance/core` **v4.0.0** shipped
  **2026-07-24** implementing LIP-35: balance-based accounting (`clValidatorsBalance` /
  `clPendingBalance` replacing validator counts), `0x02` credentials up to 2048 ETH,
  `TopUpGateway`, and a consolidation pipeline. Module reward shares are now
  `moduleActiveBalance / totalActiveBalance`, i.e. **balance-weighted, not validator-count
  weighted**. Any residue entry phrased in terms of "the next 32 ETH" is now approximate.
- **The fee marker is wrong as stated.** The corpus `Fd` marker says "the 10% fee splits 5%
  to node operators and 5% to treasury". First-party source says the split is **per-module**:
  Curated 5/5, permissionless module 3.5/6.5, CSM v2 blended, Simple DVT 8%/2% for normal
  clusters and 6%/4% for super clusters (https://lido.fi/how-lido-works/protocol-fee ;
  https://operatorportal.lido.fi/modules/simple-dvt-module, accessed 2026-08-04). A single
  global fee split is not a fact about Lido.
- **The `Bs` marker is right in spirit but the scope is now sharper.** CSM's bond is on a
  declining curve ("from 2.4 to 1.3 ETH"), and CSM carries a **strikes → EIP-7002 ejection**
  path with a `badPerformancePenalty` that the corpus does not mention. Curated remains
  unbonded, so the corpus's "true of one module, false of the majority of the stake"
  observation stands.
- **The Dual Governance residue entry is correct but under-specified.** LIP-28 gives exact
  parameters (1% / 10% seals, 3d / 5–45d / 7d / 60–180d, 5h min lock) and a five-state
  machine, plus three named committees. The corpus records only "delay or escape".
- **DSM quorum.** The corpus does not state one; first-party docs say **4 of 6**.
- **Not a discrepancy, but load-bearing for stage 2:** every principal Lido contract is a
  proxy, and the DAO's lever set includes `setMaxExternalRatioBP()` — a cap on how much
  stETH may be backed by stVault collateral rather than the core pool. That cap is the
  seam between the two products.

---

## Binance staked ETH (WBETH)

### 1. WHAT IT DOES

Two doors lead to the same token, and they behave very differently. **Through Binance**: a
user with a Binance account stakes ETH on the ETH Staking page and receives WBETH (or wraps
existing BETH into WBETH), at zero fee; WBETH is a value-accruing receipt where 1 WBETH
represents 1 staked ETH plus all rewards accrued since the rate was initialised 1:1 on
2023-04-27 08:00 UTC. The BETH/WBETH conversion rate is updated **daily at 00:00 UTC**, and
staking and redemption are suspended each day from 23:45 to 00:15 UTC while that happens.
Redemption through the exchange is at the prevailing rate, at zero fee, subject to Binance's
terms. **Through the contract**: `deposit(address referral)` is `payable` and
**permissionless** — anyone can send ETH to the WBETH contract on Ethereum and be minted
`msg.value × 1e18 / exchangeRate()` WBETH with no account, no KYC and no allowlist. Exit
through the contract is also on-chain: `requestWithdrawEth(uint256)` burns the caller's
WBETH and registers a request in a separate unwrap contract; an operator must then
`allocate` ETH against that request, after which the user calls `claimWithdraw(index)` to
receive ETH. A minimum lock (`MIN_LOCK_TIME = 2 days`, with a settable `lockTime`) applies.
The claim path is blacklistable. Everything behind the token — validators, keys, slashing
exposure, reward computation, the reserve — is inside Binance and is not observable on chain.

### 2. DESIGN

**Token.** `0xa2E3356610840701BDf5611a53974510Ae27E2e1` on both Ethereum and BNB Smart
Chain (same address). Verified via Sourcify. It is a **`FiatTokenProxy`** — Centre/Coinbase
lineage — EIP-1967, compiler `0.6.12+commit.27d51765`, with `admin()`, `changeAdmin()`,
`upgradeTo()`, `upgradeToAndCall()`. Implementation: **`WrapTokenV3ETH`** at
`0x9E021c9607bD3ADB7424D3b25a2D35763ff180BB`, verified, `0.6.12`, **licence UNLICENSED**.

**State-changing surface of the implementation** (from the verified ABI):
`deposit(address referral)` payable; `requestWithdrawEth(uint256 wbethAmount)`;
`supplyEth()`, `moveToStakingAddress(uint256)`, `moveToUnwrapAddress(uint256)` — all
operator-gated; `exchangeRate()` (1e18-scaled) and `updateExchangeRate(uint256)`;
`mint(address,uint256)` / `burn(uint256)`; `pause()` / `unpause()`;
`addBlacklist(address)` / `removeBlacklist(address)` / `isBlacklisted(address)`;
`owner()` / `transferOwnership()`; `permit()` / `permitWithAmount()` / `nonces()`.

Verbatim, from the verified source:

```solidity
function deposit(address referral) external payable {
    require(msg.value > 0, "zero ETH amount");
    uint256 wBETHAmount = msg.value.mul(_EXCHANGE_RATE_UNIT).div(exchangeRate());
    _mint(msg.sender, wBETHAmount);
    emit DepositEth(msg.sender, msg.value, wBETHAmount, referral);
}

function requestWithdrawEth(uint256 wbethAmount) external {
    require(wbethAmount > 0, "zero wBETH amount");
    uint256 ethAmount = wbethAmount.mul(exchangeRate()).div(_EXCHANGE_RATE_UNIT);
    _burn(wbethAmount);
    IUnwrapTokenV1(_UNWRAP_ETH_ADDRESS).requestWithdraw(
        msg.sender, wbethAmount, ethAmount);
    emit RequestWithdrawEth(msg.sender, wbethAmount, ethAmount);
}

address public constant _UNWRAP_ETH_ADDRESS = 0x79973d557CD9dd87eb61e250cc2572c990e20196;
```

**On-chain withdrawal queue.** `_UNWRAP_ETH_ADDRESS` is an `UnwrapTokenProxy` (EIP-1967
`AdminUpgradeabilityProxy`, Solidity 0.6.12, **licence header "MIT (Coinbase, 2022)"`)
delegating to **`UnwrapTokenV1ETH`** at `0x542059d658624DF6452b22B10302A15a6AB59f10`
(verified, 41 ABI functions). Its queue object is, verbatim:

```solidity
struct WithdrawRequest {
    address recipient;
    uint256 wbethAmount;
    uint256 ethAmount;
    uint256 triggerTime;
    uint256 claimTime;
    bool allocated;
}
uint256 public constant MIN_LOCK_TIME = 2 days;
function requestWithdraw(address _recipient, uint256 _wbethAmount, uint256 _ethAmount)
    external onlyWrapTokenAddress;
function claimWithdraw(uint256 _index) external whenNotPaused
    notBlacklisted(msg.sender) returns (uint256);
```

plus operator machinery: `allocate`, `rechargeFromRechargeAddress`,
`moveFromWrapContract`, `moveToBackAddress`, `setEthBackAddress`, `setRechargeAddress`,
`setLockTime`, `setNewEthStaked`, `setNewOperator`, `pause`/`unpause`,
`blacklist`/`unBlacklister`/`updateBlacklister`, `updatePauser`, `transferOwnership`.
Events `RequestWithdraw`, `ClaimWithdraw`, `Allocate`.

The shape is therefore: request is *permissionless and unconditional*; **fulfilment is
not**. An operator must `allocate` and must have recharged the contract with ETH from an
off-chain balance. Solvency of the queue is an off-chain fact.

**Exchange rate.** The rate is written, not derived. In the Coinbase `StakedTokenV1`
lineage this contract descends from, the pattern is exactly:

```solidity
modifier onlyOracle() {
    require(msg.sender == oracle(), "StakedTokenV1: caller is not the oracle");
    _;
}
function updateExchangeRate(uint256 newExchangeRate) external onlyOracle {
    require(newExchangeRate > 0, "StakedTokenV1: new exchange rate cannot be 0");
    ...
}
function updateOracle(address newOracle) external onlyOwner { ... }
```

For WBETH the oracle role was assigned not to an EOA but to a **contract**:
`ExchangeRateUpdater` at `0x81720695e43A39C52557Ce6386feB3FAAC215f06` (verified, MIT),
which is a **rate limiter**. Its ABI: `configureCaller(address, uint256, uint256)`,
`callers(address)`, `allowances(address)`, `allowancesLastSet(address)`,
`maxAllowances(address)`, `intervals(address)`, `currentAllowance(address)`,
`estimatedAllowance(address)`, `removeCaller`, `tokenContract()`, `owner()`,
`updateExchangeRate(uint256)`. Its guards: `onlyCallers` ("RateLimit: caller is not
whitelisted"), `"ExchangeRateUpdater: new exchange rate must be greater than 0"`,
`"ExchangeRateUpdater: exchange rate update exceeds allowance"`, `"ExchangeRateUpdater:
exchange rate isn't new"`. So the rate is asserted by a whitelisted caller, but the size of
each assertion is capped by a per-caller allowance that refills on a per-caller interval.

**Roles and who holds them.** LlamaRisk's 2023-10-09 assessment mapped: admin (upgrades)
`0xA3eE6926edcce93BacF05F4222c243c4d9F6d853` (Binance EOA); owner / masterMinter / pauser /
blacklister all the *same* EOA `0x099d699C07Bbc8eE6eB5703746063E04B2aA62A7`, described as
having "no transaction history"; oracle `0x81720695e43A39C52557Ce6386feB3FAAC215f06`
(the ExchangeRateUpdater contract); operator `0x2B59215778e99035CF38663454eF1240a7AE70F5`
(Binance EOA). **UNKNOWN: whether these assignments still hold in 2026** — the implementation
has since moved from `WrappedTokenV1ETH` (the version LlamaRisk reviewed) to
`WrapTokenV3ETH`, and I could not re-read live role values (Etherscan 403; Blockscout
`methods-read-proxy` 404; no `eth_call` available through the fetch tool).

**Validator lifecycle: absent.** There is no on-chain validator registry, no key
registration, no withdrawal-credential proof, no exit signalling, no slashing accounting,
no operator set, and no reward computation. `moveToStakingAddress(uint256)` moves ETH
*out* of the contract to a Binance-controlled address and the trail ends there.

**What is verifiable instead.** (a) That minting is permissionless on-chain and priced by
a single stored scalar; (b) that the withdrawal *request* is enforced by code while
withdrawal *fulfilment* is operator-discretionary and depends on off-chain recharge;
(c) that the rate can only move within a rate-limited allowance; (d) that the operator can
pause the claim path and blacklist individual addresses; (e) that the token is upgradeable
by an EOA-held proxy admin; (f) the total supply and the historical `exchangeRate()` series
on chain. What is **not** verifiable on-chain: the existence, size, composition or health
of the backing stake. Binance publishes a Proof-of-Reserves page describing a Merkle-tree
and zk-SNARK user-inclusion methodology, but that page does not enumerate WBETH or BETH
among covered assets, names no auditor and states no frequency (accessed 2026-08-04).

### 3. REPO

**There is no canonical public repository for WBETH.** The protocol is not open source.
`https://github.com/binance` hosts no WBETH contract repository that I could locate.
The verified on-chain source *is* the artefact, and it is retrievable:

- Token proxy `FiatTokenProxy` — `0xa2E3356610840701BDf5611a53974510Ae27E2e1`
- Token implementation `WrapTokenV3ETH` — `0x9E021c9607bD3ADB7424D3b25a2D35763ff180BB`, licence **UNLICENSED**
- Unwrap proxy `UnwrapTokenProxy` — `0x79973d557CD9dd87eb61e250cc2572c990e20196`, header licence **MIT (Coinbase, 2022)**
- Unwrap implementation `UnwrapTokenV1ETH` — `0x542059d658624DF6452b22B10302A15a6AB59f10`
- Rate limiter `ExchangeRateUpdater` — `0x81720695e43A39C52557Ce6386feB3FAAC215f06`, licence **MIT**
- Language Solidity, compiler `0.6.12+commit.27d51765`. Verification via **Sourcify**, surfaced through Blockscout.
- **Upstream lineage (open source):** https://github.com/coinbase/wrapped-tokens-os —
  `contracts/wrapped-tokens/staking/StakedTokenV1.sol`, MIT. WBETH's implementation is a
  descendant of this cbETH design; the proxy is Centre's `FiatTokenProxy`.

**Deployed matches repo?** Not applicable in the usual sense: there is no Binance repo to
match. The deployed bytecode *is* verified against submitted source on Sourcify, which is
the strongest available assurance. **This is the case the task flags: a custodial receipt
with no on-chain validator lifecycle.** But it is *not* the case the corpus describes —
see DELTA.

### 4. EVIDENCE

| Claim | Source | Accessed |
|---|---|---|
| WBETH definition, wrap/unwrap at zero fee, daily 00:00 UTC rate update, 23:45–00:15 UTC suspension, redemption via ETH Staking page, risk disclaimer | https://www.binance.com/en/support/faq/what-is-wbeth-e252366155174ba6887f6b32e3798273 | 2026-08-04 |
| Launch 2023-04-27 08:00 UTC, rate initialised 1:1, first daily update 2023-04-28 00:00 UTC, same address on Ethereum and BSC, BETH withdrawals ceased 2023-04-26 08:00 UTC | https://www.binance.com/en/support/announcement/binance-introduces-wrapped-beacon-eth-wbeth-on-eth-staking-a1197f34d832445db41654ad01f56b4d | 2026-08-04 |
| "users can stake ETH directly via smart contract"; reward-bearing LST framing | https://www.binance.com/en/research/projects/wrapped-beacon-eth-wbeth | 2026-08-04 |
| Proxy is `FiatTokenProxy`, EIP-1967, compiler 0.6.12, implementation `WrapTokenV3ETH`, Sourcify-verified | https://eth.blockscout.com/api/v2/smart-contracts/0xa2E3356610840701BDf5611a53974510Ae27E2e1 | 2026-08-04 |
| `WrapTokenV3ETH` full ABI; verbatim `deposit`, `requestWithdrawEth`, `_UNWRAP_ETH_ADDRESS`; licence UNLICENSED | https://eth.blockscout.com/api/v2/smart-contracts/0x9E021c9607bD3ADB7424D3b25a2D35763ff180BB | 2026-08-04 |
| Unwrap proxy identity, MIT (Coinbase 2022) header, implementation address | https://eth.blockscout.com/api/v2/smart-contracts/0x79973d557CD9dd87eb61e250cc2572c990e20196 | 2026-08-04 |
| `UnwrapTokenV1ETH`: `WithdrawRequest` struct, `MIN_LOCK_TIME = 2 days`, `requestWithdraw` onlyWrapTokenAddress, `claimWithdraw` whenNotPaused notBlacklisted, `allocate`, `rechargeFromRechargeAddress`, `setLockTime`, events | https://eth.blockscout.com/api/v2/smart-contracts/0x542059d658624DF6452b22B10302A15a6AB59f10 | 2026-08-04 |
| `ExchangeRateUpdater` name, MIT, ABI, `onlyCallers`, allowance/interval requires | https://eth.blockscout.com/api/v2/smart-contracts/0x81720695e43A39C52557Ce6386feB3FAAC215f06 | 2026-08-04 |
| `onlyOracle` / `updateExchangeRate` / `updateOracle` verbatim in the upstream cbETH design | https://github.com/coinbase/wrapped-tokens-os/blob/main/contracts/wrapped-tokens/staking/StakedTokenV1.sol (raw) | 2026-08-04 |
| Role→address map, "no transaction history" EOA, daily operator rate update, discretionary redemption, no PoR, report date 2023-10-09 | https://llamarisk.com/research/risk-collateral-risk-assessment-binance-wrapped-beacon-eth-wbeth | 2026-08-04 |
| PoR methodology (Merkle + zk-SNARK); WBETH/BETH not enumerated; no auditor or frequency stated on the page | https://www.binance.com/en/proof-of-reserves | 2026-08-04 |

### 5. WHAT LOOKS UNNAMEABLE

`Vl` — **confirmed unusable, and for exactly the stated reason**. There is no on-chain
validator registry, key registration, credential proof, exit request, slashing record or
operator set anywhere in the WBETH contract set. The three write functions that touch the
staking side (`moveToStakingAddress`, `supplyEth`, `setNewEthStaked`) move value and
assert numbers; they do not model a validator. The corpus is right that the second-largest
liquid-staking position in DeFi contains no `Vl` at all.

Genuinely unnamed mechanisms:

- **A written index.** `exchangeRate()` is a stored scalar that a whitelisted caller
  overwrites. `Ix` presumes an index derived from observable state. Here the state is not
  observable and the index is a claim. The gap is not "index vs share" — it is *asserted*
  vs *derived*, and the vocabulary has no way to mark which.
- **A rate-limited assertion.** `ExchangeRateUpdater` bounds how far the asserted number
  may move per interval. This is a *governor on an oracle's discretion* — neither a
  timelock (no delay, no queue), nor a guardian (it cannot stop anything), nor an
  attestation. It is the only thing standing between a compromised oracle key and
  arbitrary repricing of $6.9B, and nothing names it.
- **A queue whose fulfilment is discretionary.** The request leg is code; the `allocate`
  leg is an operator decision funded from an off-chain balance. `Wq` names a queue that the
  protocol is obliged to clear. This one is a *petition*, not an obligation, and the
  distinction is the whole risk.
- **Custodial backing with no attestation object.** `At` requires a named attester,
  independence, a stated assurance level and a staleness bound. Binance's PoR page supplies
  a methodology and no attester, and does not name WBETH. There is no symbol for "backed by
  an off-chain balance sheet you cannot inspect".
- **Blacklist on the claim path.** `claimWithdraw` carries `notBlacklisted(msg.sender)`.
  The issuer can permanently strand a specific holder's redemption while leaving the token
  transferable to everyone else. This is closer to a selective freeze on redemption than to
  a permission gate.
- **A two-door instrument.** The same ERC-20 is simultaneously (i) a permissionless on-chain
  claim minted by anyone at a posted rate, and (ii) an exchange product gated by an account
  and terms of service. The vocabulary has one gate symbol and no way to say that one door
  is code and the other is a login, with different rights behind each.

### 6. DELTA

This is the largest set of discrepancies in the category, and they all run the same way:
**the corpus understates how much of WBETH is on chain.**

- **"What exists on-chain is an ERC-20 whose exchange rate an admin key increments on a
  schedule" — materially wrong on two counts.** (a) The oracle role is held by a
  **contract** (`ExchangeRateUpdater`, `0x8172…f06`, MIT, verified) that enforces a
  per-caller allowance and interval, not by a bare admin key; the source strings are
  `"RateLimit: caller is not whitelisted"` and `"ExchangeRateUpdater: exchange rate update
  exceeds allowance"`. (b) The on-chain surface is much larger than an ERC-20: it includes a
  permissionless `payable deposit()`, an on-chain withdrawal-request function, a separate
  upgradeable unwrap contract with a `WithdrawRequest` struct and a `MIN_LOCK_TIME = 2 days`,
  a pause, and a blacklist. (Blockscout/Sourcify, all accessed 2026-08-04.)
- **"No on-chain redemption guarantee" — half right, and the right half needs restating.**
  There *is* an on-chain redemption path (`requestWithdrawEth` → `allocate` → `claimWithdraw`).
  What is absent is not the path but the **obligation to fund it**: `allocate` is
  operator-gated and the contract is topped up by `rechargeFromRechargeAddress`. The precise
  finding is "an enforced request against a discretionary fulfilment", which is a sharper
  and more useful statement than "no redemption".
- **The `Rd` marker's justification is wrong.** The corpus says redemption "is an exchange
  feature governed by exchange terms and KYC, not a right the contract enforces". The
  contract enforces the *burn* and the *queue entry* unconditionally for any holder, with no
  KYC. It does not enforce payment. The overstatement the corpus warns about is real, but it
  is located in a different place than the corpus puts it.
- **The `Aw` marker's justification is wrong.** "Minting and redeeming require a Binance
  account… this gate is a login." On-chain minting via `deposit(address referral)` requires
  no account and no allowlist; on-chain redemption requires only not being blacklisted.
  The real access mechanism is a **blacklist on claim**, which is a different object from a
  permission gate.
- **Missing from the residue list: upgradeability and pause.** The token is an EIP-1967
  proxy whose admin was (2023) a Binance EOA, and both the token and the unwrap contract
  expose `pause()`. The corpus's `canonicalForm` for WBETH omits any control-plane symbol
  beyond `Up`, and does not record the blacklist at all.
- **Stale role data.** LlamaRisk's role map is from **2023-10-09** and describes
  `WrappedTokenV1ETH`; the live implementation is `WrapTokenV3ETH`. **UNKNOWN: current
  owner / oracle / operator / blacklister addresses and whether the oracle is still the
  rate limiter.** Stage 2 should not assume the 2023 map.

---

## EigenCloud (EigenLayer)

### 1. WHAT IT DOES

A restaker brings capital that is already earning elsewhere and rents its slashability to
third parties. Two deposit routes: **native ETH**, by deploying an `EigenPod` and pointing
Ethereum validators' withdrawal credentials at it, then proving those credentials on chain;
or **ERC-20s (including LSTs)**, by `depositIntoStrategy` on the `StrategyManager`. Either
way the depositor receives **deposit shares** — an internal, non-transferable accounting
claim, not a token. The staker then **delegates** the whole position to an **operator**;
delegation transfers no custody, only slashing exposure and the right to be counted as that
operator's weight. The operator opts in to **operator sets** run by **AVSs** (services), and
for each set allocates a **magnitude** — a proportion of its delegated stake per strategy —
which becomes *uniquely* slashable by that set. Rewards do not accrue to the share; they are
distributed by AVSs into the `RewardsCoordinator` and claimed against posted Merkle roots.
Losses arrive when an AVS calls `slashOperator` with a proportion, which reduces the
operator's magnitudes and burns or **redistributes** the corresponding stake. Exit is a
queue: `undelegate` or `queueWithdrawals`, wait `MIN_WITHDRAWAL_DELAY_BLOCKS` (100,800
blocks ≈ 14 days), then `completeQueuedWithdrawal` as shares or as tokens; for native ETH
the beacon-chain exit queue sits underneath that. Nothing in this ends: a position persists
until withdrawn, and its risk profile changes whenever the operator changes its allocations —
which is why allocations only take effect after a long delay.

### 2. DESIGN

**Core contracts** (`src/contracts/core/`): `AllocationManager.sol`,
`AllocationManagerView.sol`, `DelegationManager.sol`, `StrategyManager.sol`,
`RewardsCoordinator.sol`, `AVSDirectory.sol` (legacy, deprecated), plus — new, and absent
from the published system README — `EmissionsController.sol`, `ProtocolRegistry.sol`,
`ReleaseManager.sol`. Other trees: `src/contracts/pods/` (EigenPodManager, EigenPod),
`strategies/`, `permissions/` (PermissionController), `multichain/`, `avs/`, `token/`,
`mixins/`, `libraries/`, `interfaces/`.

**Deposit and shares — `StrategyManager`.** `depositIntoStrategy(strategy, token, amount)`
and `depositIntoStrategyWithSignature(...)`; a **Strategy Whitelister** (currently the
`StrategyFactory`) controls eligibility via `addStrategiesToDepositWhitelist` /
`removeStrategiesFromDepositWhitelist`. Both deposit paths call
`DelegationManager.increaseDelegatedShares`. The slashed-stake rail lives here:
`increaseBurnOrRedistributableShares` (called by DelegationManager on a slash) marks shares,
and a **permissionless** `clearBurnOrRedistributableShares` / `…ByStrategy` either burns to
`DEFAULT_BURN_ADDRESS = 0x00000000000000000000000000000000000E16E4` or transfers to the
redistribution recipient. Clearing reverts with `SlashResolutionDelayNotElapsed` until
`block.number` passes the slash's resolution block (`SLASH_RESOLUTION_DELAY_BLOCKS`) — a
mandatory delay introduced in release **v1.13.0**.

**Native restaking — `EigenPodManager` / `EigenPod`.** `createPod()` deploys a pod via
CREATE2 salted on the staker address; `stake()` deposits 32 ETH with the pod as withdrawal
credentials. Two accounting objects: `podOwnerDepositShares` — "When an EigenPod registers
a balance increase, deposit shares are increased. When registering a balance decrease,
however, deposit shares are NOT decreased" — and `beaconChainSlashingFactor`, a proportional
value starting at WAD (1e18) that is *reduced* on balance decreases.
`recordBeaconChainETHBalanceUpdate()` routes positive deltas into shares and negative
deltas into the slashing factor, which is how the protocol avoids share deficits.
Validator state enters via `verifyWithdrawalCredentials` and periodic checkpoints
(`startCheckpoint` / `verifyCheckpointProofs`).

**Delegation — `DelegationManager`.** State: `_operatorDetails` (the `delegationApprover`),
`delegatedTo`, `_depositScalingFactor` (normalises new deposits against the current slashing
factor), `operatorShares` per operator per strategy, `queuedWithdrawals` and
`_stakerQueuedWithdrawalRoots`. Functions: `registerAsOperator` (sets delegation approver and
allocation delay), `modifyOperatorDetails`, `delegateTo`, `undelegate`, `redelegate`,
`queueWithdrawals`, `completeQueuedWithdrawal(s)`, `slashOperatorShares`,
`increaseDelegatedShares` / `decreaseDelegatedShares`.
**`MIN_WITHDRAWAL_DELAY_BLOCKS` = 100,800 blocks mainnet (~14 days)**, 50 on testnet.

**Operator sets, unique stake and slashing — `AllocationManager` (ELIP-002).** State:
(1) **operator sets**, keyed by `(avs, id)`, holding the slashable strategies and the
membership roster; (2) **magnitudes** per operator per strategy — `maxMagnitude`, starting at
`INITIAL_TOTAL_MAGNITUDE = 1e18` (1 WAD) and reduced only by slashing, and
`encumberedMagnitude`, the sum currently allocated; (3) **allocations** per
(operator, strategy, operator set) with `currentMagnitude`, `pendingDiff`, `effectBlock`;
(4) a per-(operator, strategy) **deallocation queue** processed in order. Functions:
`modifyAllocations`, `registerForOperatorSets`, `deregisterFromOperatorSets`,
`setAllocationDelay`, `slashOperator`. Constants: **`ALLOCATION_CONFIGURATION_DELAY` =
126,000 blocks (17.5 days)** mainnet / 75 blocks testnet; **`DEALLOCATION_DELAY` = 100,800
blocks (14 days)** mainnet / 50 testnet. Deregistration does not end exposure — allocations
stay slashable for `DEALLOCATION_DELAY`. `slashOperator(wadsToSlash)` reduces
`currentMagnitude`, `maxMagnitude` and `encumberedMagnitude` proportionally, processes
pending deallocations pro rata, and hands the loss to `DelegationManager` for burn or
redistribution.

**The safety property.** "The sum of all of an Operator's Magnitudes cannot exceed the
INITIAL_TOTAL_MAGNITUDE… ensures that **no two Operator Sets can slash the same stake**."
This is the definition of Unique Stake and it is enforced by arithmetic, not by convention.

**Redistribution (ELIP-006, mainnet).** An AVS may create a **redistributing operator set**
with a `redistributionRecipient` that **cannot be changed later**, so stakers can price the
risk at opt-in. Excluded: **native ETH** (because paying the recipient would require beacon
exits whose queue "can range in length from hours to weeks") and **EIGEN** (which "requires a
delay on token protocol outflow" for its intersubjective machinery). Named security concerns:
precision loss, deposit-scaling-factor manipulation, and — stated plainly — "an attacker that
gains access to AVS keys… can drain the entirety of Operator and Staker allocated stake."

**Rewards — `RewardsCoordinator`.** `createAVSRewardsSubmission` (weighted across strategies,
distribution computed off-chain) and `createOperatorDirectedOperatorSetRewardsSubmission`
(per-operator, scoped to an operator set, operators must have been registered during the
period), plus v1 / v2.1 / v2.2 submission types. A **singleton `rewardsUpdater`** posts
`DistributionRoot`s via `submitRoot`; roots become claimable after `activationDelay`;
earners call `processClaim` with Merkle proofs and may nominate a claimer via `setClaimerFor`.
`defaultOperatorSplitBips` is "a flat 10% rate for the initial rewards release… 1000".
`CALCULATION_INTERVAL_SECONDS` and `MAX_REWARDS_DURATION` exist; **UNKNOWN: their mainnet
values** (the doc names them without stating numbers).

**Multichain (`docs/multichain/`).** `CrossChainRegistry` on the source chain lets an AVS
register an operator-table calculator and global config per operator set;
`OperatorTableUpdater` on destination chains accepts a signed **GlobalTableRoot** and Merkle
proofs of individual operator tables; `KeyRegistrar` holds the key type. Two off-chain roles:
a **Generator** ("an EigenLabs-operated entity") that calculates and signs the GlobalTableRoot,
and a permissionless **Transporter** that distributes it. **UNKNOWN: roles of
`ReleaseManager`, `ProtocolRegistry`, `EmissionsController`** — these files exist in
`src/contracts/core/` but are not covered in `docs/` at the commit I read.

**Intersubjective layer.** EIGEN is designed as a "universal intersubjective work token":
for faults that are obvious to human observers but not provable in the EVM, the fallback is
**forking the token** — a challenger creates a fork in which the malicious stakers are
slashed, and AVSs and users choose which fork to respect. **UNKNOWN: whether intersubjective
slashing / forking is implemented on mainnet.** The token whitepaper is at
`docs.eigencloud.xyz/assets/files/EIGEN_Token_Whitepaper-…pdf`; I could not fetch it
(host 403) or `blog.eigencloud.xyz/eigen/` (TLS certificate mismatch), so the design is
sourced but the deployment status is not.

**Product framing.** Since a mid-2025 rebrand the platform is **EigenCloud**: EigenDA (data
availability), EigenCompute (verifiable off-chain execution in containers), EigenVerify
(dispute resolution), EigenAI. EigenLayer is the security/restaking layer underneath.
This is sourced from secondary coverage only — **the first-party blog and docs both blocked
automated fetch** — so treat the product taxonomy as lower-confidence than the contract facts.

### 3. REPO

- **Canonical:** https://github.com/Layr-Labs/eigenlayer-contracts — "Contracts of
  EigenLayer". **Language Solidity.** Default branch `main`, 721 stars,
  `pushed_at` 2026-07-16T16:13:43Z.
- **Licence: Business Source License 1.1.** Licensor **Layr Labs, Inc.**; Licensed Work
  "EigenLayer Core Contracts (c) 2023 Layr Labs, Inc."; **Change Date 2025-05-01 for earlier
  commits and 2027-02-06 for later ones**; **Change Licence MIT**. Production use is
  restricted to uses connected to the EigenLayer Protocol or EigenDA. (GitHub's API reports
  the licence as `NOASSERTION` / "Other"; the LICENSE file is authoritative.)
  **This is a live prohibition-relevant fact for the paper: the reference implementation is
  not open source under an OSI licence until the change date.**
- **Release inspected: `v1.13.0` "Slash Resolution Delay", published 2026-06-25T19:44:35Z,
  target `main`.** It "introduces a mandatory slash resolution delay before
  burnable/redistributable shares can be cleared, adds a dedicated pause flag for the
  burn-and-redistribution flow, and replaces the duration vault's deposit-time token
  blacklist check with a narrower restriction", plus a catch-up path for environments that
  missed **v1.12.0 (Incentive Council)**.
- **Top level:** `src/` (with `avs/ core/ interfaces/ libraries/ mixins/ multichain/
  permissions/ pods/ strategies/ token/`), `docs/` (`avs/ core/ experimental/ images/
  multichain/ permissions/` + README), `audits/`, `certora/`, `script/`, `pkg/`, `bin/`,
  `lib/`, `CHANGELOG/`, `MAINTENANCE.md`, `CONTRIBUTING.md`, `Makefile`, `foundry.toml`,
  `go.mod`/`go.sum`, `slither.config.json`, `mythril.config.json`, `Dockerfile`, `.zeus`,
  `CLAUDE.md`, `.devcontainer/`.
- **Governance spec repo:** https://github.com/eigenfoundation/ELIPs — ELIP-002 (slashing via
  unique stake and operator sets), ELIP-006 (redistributable slashing).
- **Deployed vs repo:** the repo carries `.zeus` and `script/` deployment tooling and an
  `audits/` directory, and releases are versioned and dated. I did **not** verify deployed
  implementation addresses against this tag. **UNKNOWN: deployed ↔ v1.13.0 correspondence.**
- **Docs README version skew (worth recording):** `docs/README.md` still announces
  **"EigenLayer v1.3.0"** while the repo's latest release is **v1.13.0**. The per-contract
  docs under `docs/core/` are current (they document redistribution and the resolution
  delay); the index is not.

### 4. EVIDENCE

| Claim | Source | Accessed |
|---|---|---|
| AllocationManager state (operator sets, max/encumbered magnitude, allocations with pendingDiff/effectBlock, deallocation queue), functions, `ALLOCATION_CONFIGURATION_DELAY` 126,000 blocks / 17.5 days, `DEALLOCATION_DELAY` 100,800 blocks / 14 days, slashing math | https://github.com/Layr-Labs/eigenlayer-contracts/blob/main/docs/core/AllocationManager.md (raw) | 2026-08-04 |
| Unique Stake, `INITIAL_TOTAL_MAGNITUDE` 1e18, "no two Operator Sets can slash the same stake", AllocationManager as sole AVS registration path | https://github.com/eigenfoundation/ELIPs/blob/main/ELIPs/ELIP-002.md ; https://docs.eigencloud.xyz/eigenlayer/concepts/operator-sets/strategies-and-magnitudes | 2026-08-04 |
| DelegationManager state, functions, `MIN_WITHDRAWAL_DELAY_BLOCKS` = 100,800 mainnet / 50 testnet | https://github.com/Layr-Labs/eigenlayer-contracts/blob/main/docs/core/DelegationManager.md (raw) | 2026-08-04 |
| StrategyManager deposit paths, StrategyFactory as whitelister, burn/redistribute share accounting, `SlashResolutionDelayNotElapsed`, `DEFAULT_BURN_ADDRESS = 0x…0E16E4` | https://github.com/Layr-Labs/eigenlayer-contracts/blob/main/docs/core/StrategyManager.md (raw) | 2026-08-04 |
| EigenPodManager/EigenPod: createPod CREATE2, stake(), `podOwnerDepositShares` asymmetry quote, `beaconChainSlashingFactor` starting at WAD, `recordBeaconChainETHBalanceUpdate` | https://github.com/Layr-Labs/eigenlayer-contracts/blob/main/docs/core/EigenPodManager.md (raw) | 2026-08-04 |
| RewardsCoordinator submissions, singleton `rewardsUpdater`, `submitRoot`, `activationDelay`, `processClaim`, `setClaimerFor`, `defaultOperatorSplitBips` = 1000 (10%) | https://github.com/Layr-Labs/eigenlayer-contracts/blob/main/docs/core/RewardsCoordinator.md (raw) | 2026-08-04 |
| System contract list and the v1.3.0 doc version stamp | https://github.com/Layr-Labs/eigenlayer-contracts/blob/main/docs/README.md (raw) | 2026-08-04 |
| Multichain: CrossChainRegistry, OperatorTableUpdater, KeyRegistrar, Generator (EigenLabs-operated), Transporter (permissionless) | https://github.com/Layr-Labs/eigenlayer-contracts/blob/main/docs/multichain/README.md (raw) | 2026-08-04 |
| ELIP-006: immutable `redistributionRecipient`, ETH and EIGEN excluded with reasons, burn address, AVS-key-compromise risk quote | https://github.com/eigenfoundation/ELIPs/blob/main/ELIPs/ELIP-006.md (raw) | 2026-08-04 |
| Release v1.13.0 tag, date, body (slash resolution delay, burn/redistribution pause flag, duration vault, v1.12.0 Incentive Council) | https://api.github.com/repos/Layr-Labs/eigenlayer-contracts/releases/latest | 2026-08-04 |
| Repo metadata: description, language, default branch, pushed_at, licence NOASSERTION | https://api.github.com/repos/Layr-Labs/eigenlayer-contracts | 2026-08-04 |
| LICENSE is BUSL-1.1, Licensor Layr Labs Inc., Change Dates 2025-05-01 / 2027-02-06, Change Licence MIT, production-use carve-out | https://github.com/Layr-Labs/eigenlayer-contracts/blob/main/LICENSE (raw) | 2026-08-04 |
| Top-level and `src/contracts/core/` file listings incl. EmissionsController, ProtocolRegistry, ReleaseManager | https://api.github.com/repos/Layr-Labs/eigenlayer-contracts/contents/ ; …/contents/src/contracts ; …/contents/src/contracts/core ; …/contents/docs | 2026-08-04 |
| EIGEN intersubjective faults, token forking as court of last resort | https://docs.eigencloud.xyz/assets/files/EIGEN_Token_Whitepaper-0df8e17b7efa052fd2a22e1ade9c6f69.pdf (referenced; **host blocked automated fetch — content sourced via search summaries, treat as UNCONFIRMED**) | 2026-08-04 |
| EigenCloud rebrand and product set (EigenDA / EigenCompute / EigenVerify / EigenAI) | secondary coverage only; **first-party blog.eigencloud.xyz and docs.eigencloud.xyz both blocked (403 / TLS mismatch) — UNCONFIRMED at primary source** | 2026-08-04 |

### 5. WHAT LOOKS UNNAMEABLE

`Vl` — **confirmed equivocal, and the reason is sharper than the corpus states**. An
EigenLayer operator does have a registration/duty/slashing arc. But: it registers in
`DelegationManager` (identity + approver) and separately in `AllocationManager` (per-set
membership); it holds no key in any consensus protocol; the "duty" is defined entirely by
a third party the core protocol does not model; and its slashable weight is a *set of
magnitudes*, not a set of validators. Using one symbol for this and for a Lido node
operator running BLS keys against a beacon chain asserts a sameness that the code refutes.
Note also that `EigenPod` **does** contain a real validator lifecycle (credential proofs,
checkpoints, exits) — so EigenLayer contains *both* a genuine `Vl` (in `pods/`) and a
thing that only rhymes with it (in `core/`), and one symbol cannot hold both.

Unnamed mechanisms:

- **Unique stake / magnitude arithmetic.** A conserved quantity (`maxMagnitude`, monotone
  decreasing, only by slashing) partitioned across counterparties such that no two can
  claim the same unit. This is the central object of the protocol and there is no symbol
  for a *slashability budget*. `Bs` names slashable first-loss capital; it does not name
  the allocation algebra over it.
- **Renting security to an arbitrary external service.** `Rs` asserts restaking is present.
  It does not name the operator-set contract, the AVS's right to author its own slashing
  law, or the fact that the core protocol does not know what the law says.
- **Delegation of slashing exposure without custody.** `delegateTo` transfers no assets and
  no transaction authority — only the right to be counted, and the corresponding liability.
  `Au` is about transaction authority; this is about liability. Confirmed unnameable.
- **Redistributive slashing.** `Sl` assigns a loss to a claim class. ELIP-006 assigns it to
  a *named counterparty as restitution*, at an address fixed immutably at set creation.
  That is a remedy, not an allocation, and the vocabulary cannot express the difference.
- **A layered delay lattice as a security parameter.** Five distinct delays with distinct
  purposes: allocation configuration (17.5 d, so stakers can leave before new risk binds),
  operator-set allocation delay (operator-chosen), deallocation (14 d, so an AVS keeps
  recourse after deregistration), withdrawal (14 d), and slash resolution (new in v1.13.0,
  so a slash can be contested before funds move). `Ep` names an epoch and `Wq` a queue;
  neither names a delay that exists to give a *third party* time to react.
- **Intersubjective adjudication by token fork.** `Oa` is an on-chain dispute game with a
  bonded challenger. A social fork of a token is not a game; it has no on-chain verifier and
  its outcome is which asset the market prices. Confirmed unnameable. (Status: design
  sourced, deployment UNKNOWN.)
- **Cross-chain transport of a stake table.** GlobalTableRoot signed by an
  EigenLabs-operated Generator, relayed permissionlessly, verified by Merkle proof on the
  destination. `Xm` names message verification, but this is *exporting the security state
  itself* to a place where it will be relied upon.
- **A permissionless clearing function on a slash.** Anyone may call
  `clearBurnOrRedistributableShares`. A loss that has been *recorded* but not yet *effected*,
  awaiting a permissionless poke after a delay, is a state nothing in the vocabulary marks.

### 6. DELTA

- **The residue claim "the same collateral is simultaneously bonded to mutually-unaware
  slashing laws" is refuted by the current protocol.** ELIP-002's Unique Stake exists
  precisely to prevent it: "The sum of all magnitude allocations never being greater than
  the Total Magnitude ensures the property of Unique Stake… ensures that no two Operator
  Sets can slash the same stake." The same *deposit* backs many sets, but each unit of
  slashability is exclusively allocated. Stage 2 should not carry the old framing.
  (ELIP-002; `docs/core/AllocationManager.md`, accessed 2026-08-04.)
- **Redistributive slashing is no longer prospective — it is on mainnet**, with the
  additional facts that the recipient address is **immutable at set creation** and that
  **native ETH and EIGEN are excluded** from it for stated structural reasons (beacon exit
  latency; EIGEN's outflow delay). The corpus records the mechanism but not the exclusions,
  and the exclusions are the interesting part: the protocol's *own* two native assets cannot
  be redistributed.
- **A sixth delay now exists.** `SLASH_RESOLUTION_DELAY_BLOCKS` was introduced in v1.13.0
  (2026-06-25) as a mandatory wait before burnable/redistributable shares can be cleared,
  with a dedicated pause flag for the burn-and-redistribution flow. The corpus residue lists
  "the allocation/deallocation delay as a security parameter distinct from the withdrawal
  escrow" — that is now three parameters, not one.
- **Three core contracts exist that no published doc covers:** `EmissionsController.sol`,
  `ProtocolRegistry.sol`, `ReleaseManager.sol` in `src/contracts/core/`, plus a
  **"duration vault"** and an **"Incentive Council"** (v1.12.0) named only in release notes.
  **UNKNOWN: what these do.** If `EmissionsController` is what its name suggests, the `Em`
  symbol in the corpus decomposition may now be load-bearing in a way it was not.
- **Licence.** The corpus record does not note it. The reference implementation is
  **BUSL-1.1** with change dates of 2025-05-01 / 2027-02-06 to MIT and a production-use
  restriction. For a paper that reconstructs functionality from published code, this is a
  material fact.
- **`AVSDirectory` is deprecated**, superseded by `AllocationManager` as the sole AVS
  registration path. Any decomposition anchored on AVSDirectory is stale.
- **Doc/release skew to be aware of:** `docs/README.md` says v1.3.0; the release is v1.13.0.
- **Naming.** "EigenCloud" is now the platform brand and "EigenLayer" the restaking layer
  within it. I could not confirm the product taxonomy at a first-party source (both
  eigencloud.xyz hosts blocked automated fetch); flagged UNCONFIRMED rather than asserted.

---

## ether.fi (eETH / weETH)

### 1. WHAT IT DOES

A user deposits ETH (or, via `Liquifier`, certain LSTs) into the ether.fi `LiquidityPool` and
receives **eETH**, a rebasing share-based token; **weETH** is the non-rebasing wrapper and is
the form most integrations and every cross-chain deployment use. The pool's ETH is used to
spin up validators, and — this is the differentiating claim — those validators' withdrawal
credentials point at ether.fi-controlled `EtherFiNode` contracts which are also **EigenPods**,
so the same principal is natively restaked on EigenLayer without the user taking a second
action or a second lockup. Rewards from both layers accrue into the pool's total value and
show up as an eETH rebase; restaking rewards additionally route through a rewards router and
a cumulative-Merkle distributor (and, since 2026, the KING distributor). Node operators do
not self-select: they **bid in an on-chain auction** for the right to be assigned a validator,
and the winning bid is forwarded to the treasury. Exit has three doors: an **instant
redemption** through `EtherFiRedemptionManager` for an exit fee, rate-limited by a token
bucket and floored by a low-watermark on pool TVL; a **standard queue** via
`WithdrawRequestNFT`, where a request becomes claimable once an admin finalises a batch and —
importantly — the claim rate is **frozen at finalisation**, not floating to the claim block;
and a **priority queue** (`PriorityWithdrawalQueue`) for whitelisted addresses with a minimum
delay. It ends when the NFT is burned for ETH.

### 2. DESIGN

**Repository layout is the architecture** (`src/`): `core/` (`EETH.sol`, `WeETH.sol`,
`LiquidityPool.sol`), `staking/` (`StakingManager.sol`, `AuctionManager.sol`,
`NodeOperatorManager.sol`, `EtherFiNodesManager.sol`, `EtherFiNode.sol`), `withdrawals/`
(`WithdrawRequestNFT.sol`, `EtherFiRedemptionManager.sol`, `PriorityWithdrawalQueue.sol`,
`WeETHWithdrawAdapter.sol`), `oracle/` (`EtherFiOracle.sol`, `EtherFiAdmin.sol`),
`restaking/` (`EtherFiRestaker.sol`, `RestakingRewardsRouter.sol`), `rewards/`
(`EtherFiRewardsRouter.sol`, `CumulativeMerkleRewardsDistributor.sol`), `deposits/`
(`DepositAdapter.sol`, `Liquifier.sol`, `LiquidRefer.sol`), `governance/`
(`RoleRegistry.sol`, `EtherFiTimelock.sol`, `Blacklister.sol`, `RevokeAdmin.sol`,
`rate-limiting/EtherFiRateLimiter.sol`), `utils/`, `helpers/`, `interfaces/`, and
**`archive/`**.

**Accounting.** `EETH` holds `totalShares` and `shares[address]`; balance is a function of
the pool's total value, so it rebases. `LiquidityPool` holds `totalValueInLp` /
`totalValueOutOfLp` (uint128 each), `validatorSizeWei`, `minWithdrawAmount`,
`maxWithdrawAmount`, `feeRecipient`, `validatorSpawner` (a mapping of who may create
validators), `escrowMigrationCompleted`, `SHARE_UNIT = 1e18`, and a **hard cap in basis
points on how far a single rebase may increase TVL** — an anti-oracle-error rail.

**Operator lifecycle — four separable pieces, all present.**
1. *Registration/vetting*: `NodeOperatorManager` — `addressToOperatorData` (KeyData),
   `whitelistedAddresses`, `registered`, and `operatorApprovedTags` mapping an operator to
   the `ILiquidityPool.SourceOfFunds` categories it may serve.
2. *Market for the slot*: `AuctionManager` — `bids` mapping, `numberOfBids`,
   `numberOfActiveBids`, `minBidAmount`, `maxBidAmount`, `whitelistBidAmount`,
   `whitelistEnabled`, events `BidCreated` / `BidCancelled` / `BidRevenueForwarded(bidId,
   treasury, amount)`. **Bid revenue is forwarded to the treasury.** Errors include
   `InvalidBidSize`, `NotWhitelisted`, `IncorrectBidValue`, `InsufficientPublicKeys`,
   `BidNotActive`.
3. *Deposit and key path*: `StakingManager` — beacon-proxy factory for `EtherFiNode`s
   (`UpgradeableBeacon`, `deployedEtherFiNodes`), `validatorCreationStatus` keyed by hash,
   immutables to `liquidityPool`, `etherFiNodesManager`, `depositContractEth2`,
   `auctionManager`, `etherFiNodeBeacon`. Constants: **`INITIAL_DEPOSIT_AMOUNT = 1 ether`**
   (the predeposit that pins withdrawal credentials before the balance goes in),
   **`MIN_VALIDATOR_SIZE_WEI = 32 ether`**, **`MAX_VALIDATOR_SIZE_WEI = 2048 ether`**,
   `VALIDATOR_PUBKEY_LENGTH = 48`.
4. *Exit and forwarding*: `EtherFiNodesManager` — `etherFiNodeFromPubkeyHash`, plus two
   call-forwarding allowlists, `allowedForwardedEigenpodCalls[user][selector]` and
   `allowedForwardedExternalCalls[user][selector][target]`, i.e. a **generic authority to
   forward arbitrary calls from the node into the EigenPod or elsewhere, gated per selector
   and per target**. Constants: `BEACON_ETH_STRATEGY_ADDRESS =
   0xbeaC0eeEeeeeEEeEeEEEEeeEEeEeeeEeeEEBEaC0`, `FULL_EXIT_GWEI = 2_048_000_000_000`, and
   three rate-limit ids — `UNRESTAKING_LIMIT_ID`, `EXIT_REQUEST_LIMIT_ID`,
   `CONSOLIDATION_REQUEST_LIMIT_ID` — enforced through `IEtherFiRateLimiter`.

**Oracle.** `EtherFiOracle` is a committee contract: `committeeMemberStates`,
`consensusStates` keyed by report hash, `consensusVersion`, `quorumSize` (with an immutable
`minQuorumSize`), `reportPeriodSlot`, `reportStartSlot`, `lastPublishedReportRefSlot/Block`,
`numCommitteeMembers` / `numActiveCommitteeMembers`. Events `ReportSubmitted`,
`ReportPublished`, `ReportUnpublished`. Errors `ConsensusAlreadyReached`, `ReportNotNeeded`,
`EpochNotFinalized`, `ReportSlotNotStarted`, `LastReportNotHandled`. `EtherFiAdmin`
consumes the published report. Same shape as Lido: a quorum-signed report of protocol
state, not a price feed.

**Withdrawals — three mechanisms.**
- `WithdrawRequestNFT` (ERC-721). State: `_requests`, `nextRequestId`,
  `lastFinalizedRequestId`, `ethAmountLockedForWithdrawal`, and
  `Checkpoints.Trace224 _finalizationRates` mapping requestId upper-bound → the
  `amountPerShareCeil(1e18)` snapshotted at finalisation. **The contract states its own
  invariants in natspec** — worth quoting because it is unusually explicit:
  *I1* finalisation-rate keys strictly increasing; *I2* `lowerLookup(tokenId)` returns the
  smallest finalise batch covering the id, with 0 as a legacy sentinel that falls back to
  the live rate; *I3* "For any finalized `tokenId`, `getClaimableAmount(tokenId)` is
  invariant under `LP.rebase()` after the finalize block" — property-tested; *I4* the rate
  snapshot uses ceiling rounding so the burn stays inside the request's own share
  allocation. The header records this as "the H-02 fix", i.e. an audit finding.
- `EtherFiRedemptionManager`: "allows instant redemption of eETH and weETH tokens to ETH or
  stETH with an exit fee… has a rate limiter to limit the total amount that can be redeemed
  in a given time period." Immutables include `maxExitFeeInBps`,
  `maxExitFeeSplitToTreasuryInBps`, `maxLowWatermarkInBpsOfTvl`, `stalePriceWindow`,
  `maxPriceThreshold`, an `AggregatorV3Interface stEthPriceFeed`, and links to
  `etherFiRestaker`, `lido`, `priorityWithdrawalQueue`, `blacklister`. Uses
  `BucketLimiter` (token bucket) with `BUCKET_UNIT_SCALE = 1e12`.
- `PriorityWithdrawalQueue`: `isWhitelisted` mapping, `_withdrawRequests` and
  `_finalizedRequests` as `EnumerableSet.Bytes32Set`, `ethAmountLockedForPriorityWithdrawal`,
  immutable `minDelay`, `MIN_AMOUNT = 0.01 ether`, `MAX_AMOUNT = 1000 ether`.

**Restaking.** `EtherFiRestaker` holds `tokenInfos` and a `withdrawalRootsSet`, and imports
EigenLayer's `IStrategyManager`, `IDelegationManager` and `IRewardsCoordinator` directly;
it is rate-limited by `IEtherFiRateLimiter`. AVS participation is *not* in this repo: the
README states restaking and AVS management are "strictly controlled by the Protocol via
ether.fi's AVS operator contracts" (`etherfi-protocol/etherfi-avs-operator`), with
restaking rewards distributed via **KING** (`King-Protocol` org). `EtherFiAvsOperatorsManager`
is deployed at `0x2093Bbb221f1d8C7c932c32ee28Be6dEe4a37A6a`.

**Control plane.** `RoleRegistry` (`0x62247D29B4B9BECf4BB73E0c722cf6445cfC7cE9`) is the
central authority object, consumed via a `RolesLibrary` mixin by nearly every contract. Two
timelocks are deployed — an **Upgrade Timelock** (`0x9f26d4C9…`) and an **Operating
Timelock** (`0xcD425f44…`). Everything is UUPS-upgradeable. A `PausableUntil` mixin gives
time-bounded pauses. A protocol-wide `Blacklister` is wired into eETH, the LiquidityPool,
the AuctionManager, both withdrawal queues and the redemption manager.

**Fees and loss path.** Whitepaper: "The sum of all staking rewards is split out between
stakers, node operators and the protocol, 90%, 5%, 5%, respectively." Permissioned
operators "are required to submit bids through the protocol auction mechanism, however they
are **not required to post a bond as collateral**." Solo stakers receive "initially 96ETH to
stake, of which, they receive 5% of staking rewards" and run nodes "without posting any
collateral" using DVT. Losses therefore reach eETH holders as a reduced rebase; there is no
operator-posted first-loss capital in the current design.

### 3. REPO

- **Canonical:** https://github.com/etherfi-protocol/smart-contracts — "ether.fi protocol
  smart contracts". **Default branch `master`.** Language **Solidity**, 138 stars.
  **Commit inspected: `b4a0968087b178bc346cdf6bee6c0597bf4c42c7`, dated 2026-07-15T19:48:12Z**
  ("Merge pull request #484 … test: fix fork test post upgrade"). **No git tags** — the repo
  is untagged, so a commit hash is the only pin available.
- **Licence: MIT.** The README states "ether.fi is open-source and licensed under the MIT
  License" and every source file inspected carries `// SPDX-License-Identifier: MIT`.
  Note: GitHub's licence field is `null` and I could not retrieve a top-level `LICENSE`
  file via the API. **UNKNOWN: whether a LICENSE file exists at the repo root**; the SPDX
  headers and README are the evidence.
- **Top level:** `src/`, `test/`, `script/`, `lib/`, `audits/`, `certora/`, `deployment/`,
  `docs/`, `documentation/`, `operations/`, `proposals/`, `foundry.toml`, `remappings.txt`,
  `CLAUDE.md`, `README.md`, `.example.env`, `.gitmodules`.
- **`src/` (the architecture, verbatim):** `archive/`, `core/`, `deposits/`, `governance/`,
  `helpers/`, `interfaces/`, `oracle/`, `restaking/`, `rewards/`, `staking/`, `utils/`,
  `withdrawals/`.
- **`src/archive/` (deprecated, retained for storage-layout continuity):** `TNFT.sol`,
  `BNFT.sol`, `EarlyAdopterPool.sol`, `LoyaltyPointsMarketSafe.sol`, `NFTExchange.sol`,
  `ProtocolRevenueManager.sol`, `RegulationsManager.sol`, `RegulationsManagerV2.sol`,
  `TVLOracle.sol`, `Treasury.sol`, `BucketRateLimiter.sol`, `membership/`.
- **Sister repos:** `etherfi-protocol/etherfi-avs-operator` (AVS control),
  `etherfi-protocol/avs-smart-contracts`, `etherfi-protocol/weETH-cross-chain` (LayerZero),
  `etherfi-protocol/cash-v3`, `etherfi-protocol/beHYPE`, `etherfi-protocol/postmortems`.
- **Audits (in-repo `audits/`, 31 files, 2023-02 → 2026-06):** Certora dominates the recent
  record — `2025.08.01 Certora EtherFi V3.Prelude 1 & 2`, `2025.09.09 Pectra Features
  Upgrade`, `2025.10.06 Pectra, stETH wds, weETH adapter`, `2025.10.20 WeETH withdrawal
  adapter`, `2025.11.12 Safe Key Gen, Cons. Role, Restaker bugFix`, `2026.01.20 Liquid-Refer,
  KING, Cross Pod Approval`, `2026.01.29 Reaudit Core Contracts`, `2026.03.05 Priority
  Queue`, `2026.06.28 26Q2 Security Upgrade`. Earlier: CertiK, Omniscia, Nethermind,
  Solidified, Hats, Zellic ×2, Decurity, Halborn ×2, Paladin, Nethermind NM-0217 ×2.
- **Deployed vs repo:** ether.fi publishes mainnet addresses first-party
  (`etherfi.gitbook.io/.../deployed-contracts`) and every listed contract is upgradeable
  (UUPS or beacon). Contract names in the address list match the repo file names one-for-one
  (LiquidityPool, StakingManager, EtherFiNodesManager, NodeOperatorManager, AuctionManager,
  EtherFiRestaker, RestakingRewardsRouter, DepositAdapter, Liquifier, WithdrawRequestNFT,
  EtherFiRedemptionManager, PriorityWithdrawalQueue, EtherFiRateLimiter,
  WeETHWithdrawAdapter, EtherFiRewardsRouter, CumulativeMerkleRewardsDistributor,
  EtherFiOracle, EtherFiAdmin, RoleRegistry). **UNKNOWN: bytecode-level correspondence to
  commit `b4a0968`.**

Key mainnet addresses: eETH `0x35fA164735182de50811E8e2E824cFb9B6118ac2`; weETH
`0xCd5fE23C85820F7B72D0926FC9b05b43E359b7ee`; ETHFI `0xFe0c30065B384F05761f15d0CC899D4F9F9Cc0eB`;
LiquidityPool `0x308861A430be4cce5502d0A12724771Fc6DaF216`; StakingManager
`0x25e821b7197B146F7713C3b89B6A4D83516B912d`; EtherFiNodesManager
`0x8B71140AD2e5d1E7018d2a7f8a288BD3CD38916F`; EtherFiNode beacon
`0x3c55986Cfee455E2533F4D29006634EcF9B7c03F`; NodeOperatorManager
`0xd5edf7730ABAd812247F6F54D7bd31a52554e35E`; AuctionManager
`0x00C452aFFee3a17d9Cecc1Bcd2B8d5C7635C4CB9`; EtherFiRestaker
`0x1B7a4C3797236A1C37f8741c0Be35c2c72736fFf`; WithdrawRequestNFT
`0x7d5706f6ef3F89B3951E23e557CDFBC3239D4E2c`; EtherFiRedemptionManager
`0xDadEf1fFBFeaAB4f68A9fD181395F68b4e4E7Ae0`; PriorityWithdrawalQueue
`0x35e7D6feF6f72aDd3c3e39dEc6d9CCc29e3345FA`; EtherFiRateLimiter
`0x6C7c54cfC2225fA985cD25F04d923B93c60a02F8`; EtherFiOracle
`0x57AaF0004C716388B21795431CD7D5f9D3Bb6a41`; RoleRegistry
`0x62247D29B4B9BECf4BB73E0c722cf6445cfC7cE9`; Upgrade Timelock
`0x9f26d4C958fD811A1F59B01B86Be7dFFc9d20761`; Operating Timelock
`0xcD425f44758a08BaAB3C4908f3e3dE5776e45d7a`.

### 4. EVIDENCE

| Claim | Source | Accessed |
|---|---|---|
| Repo metadata: description, master branch, Solidity, HEAD commit `b4a0968…` dated 2026-07-15, no tags | GitHub API `repos/etherfi-protocol/smart-contracts`, `/tags`, `/commits/master` | 2026-08-04 |
| README: MIT licence, native restaking "strictly controlled by the Protocol via ether.fi's AVS operator contracts", KING rewards, weETH cross-chain, Certora formal verification | https://github.com/etherfi-protocol/smart-contracts/blob/master/README.md | 2026-08-04 |
| `src/` and `src/archive/` file listings (TNFT.sol and BNFT.sol under `archive/`) | GitHub API `contents/src`, `contents/src/archive` | 2026-08-04 |
| StakingManager constants `INITIAL_DEPOSIT_AMOUNT = 1 ether`, `MIN_VALIDATOR_SIZE_WEI = 32 ether`, `MAX_VALIDATOR_SIZE_WEI = 2048 ether`, beacon-proxy factory, immutables | `src/staking/StakingManager.sol` | 2026-08-04 |
| AuctionManager state (`bids`, `minBidAmount`, `maxBidAmount`, `whitelistBidAmount`, `whitelistEnabled`), `BidRevenueForwarded(bidId, treasury, amount)`, errors | `src/staking/AuctionManager.sol` | 2026-08-04 |
| NodeOperatorManager: `addressToOperatorData`, `whitelistedAddresses`, `registered`, `operatorApprovedTags[operator][SourceOfFunds]` | `src/staking/NodeOperatorManager.sol` | 2026-08-04 |
| EtherFiNodesManager: `etherFiNodeFromPubkeyHash`, call-forwarding allowlists, `BEACON_ETH_STRATEGY_ADDRESS`, `FULL_EXIT_GWEI = 2_048_000_000_000`, three rate-limit ids | `src/staking/EtherFiNodesManager.sol` | 2026-08-04 |
| LiquidityPool: `totalValueInLp`/`totalValueOutOfLp`, `validatorSpawner`, `validatorSizeWei`, `min/maxWithdrawAmount`, `SHARE_UNIT = 1e18`, rebase increase cap in bps, wiring to all three withdrawal paths + Blacklister | `src/core/LiquidityPool.sol` | 2026-08-04 |
| EETH share ledger (`totalShares`, `shares`), blacklister + rate-limiter imports | `src/core/EETH.sol` | 2026-08-04 |
| WithdrawRequestNFT invariants I1–I4 verbatim, `_finalizationRates` Checkpoints.Trace224, "the H-02 fix", `ethAmountLockedForWithdrawal` | `src/withdrawals/WithdrawRequestNFT.sol` | 2026-08-04 |
| EtherFiRedemptionManager purpose comment, exit fee + bucket rate limiter, `maxExitFeeInBps`, `maxLowWatermarkInBpsOfTvl`, `stalePriceWindow`, `maxPriceThreshold`, stETH price feed | `src/withdrawals/EtherFiRedemptionManager.sol` | 2026-08-04 |
| PriorityWithdrawalQueue: whitelist, `minDelay`, `MIN_AMOUNT = 0.01 ether`, `MAX_AMOUNT = 1000 ether`, finalized/active request sets | `src/withdrawals/PriorityWithdrawalQueue.sol` | 2026-08-04 |
| EtherFiOracle committee/quorum/consensus state and events | `src/oracle/EtherFiOracle.sol` | 2026-08-04 |
| EtherFiRestaker imports EigenLayer StrategyManager/DelegationManager/RewardsCoordinator, `withdrawalRootsSet`, rate limiter | `src/restaking/EtherFiRestaker.sol` | 2026-08-04 |
| Audit file list (Certora V3.Prelude 2025.08, Priority Queue 2026.03, 26Q2 Security Upgrade 2026.06, etc.) | GitHub API `contents/audits` | 2026-08-04 |
| Mainnet deployed addresses | https://etherfi.gitbook.io/etherfi/developers/contracts-and-integrations/deployed-contracts | 2026-08-04 |
| Fee split 90/5/5; permissioned operators bid and are **not** required to post a bond; solo stakers 96 ETH, 5%, no collateral, DVT | https://etherfi.gitbook.io/etherfi/resources/ether.fi-whitepaper/ether.fi-staking | 2026-08-04 |
| Native restaking framing; eETH/weETH transferable and DeFi-usable; redemption without the 14-day wait when liquid ETH is available | https://etherfi.gitbook.io/etherfi/resources/ether.fi-whitepaper/ether.fi-re-staking | 2026-08-04 |
| Doc index incl. Veda/Midas Liquid vault architecture pages and node-operator pages | https://etherfi.gitbook.io/etherfi/llms.txt | 2026-08-04 |
| Obol/Charon usage: key split into keyshares, cluster configured with a **3/4 threshold** | https://etherfi.gitbook.io/etherfi/solo-stakers/operation-solo-staker/obol-dvt-explained (page returned 404 on direct fetch; content sourced via search index — **treat threshold as UNCONFIRMED at primary source**) | 2026-08-04 |
| Org repo inventory (weETH-cross-chain, avs-smart-contracts, etherfi-avs-operator, cash-v3, beHYPE, postmortems) | GitHub search API `org:etherfi-protocol` | 2026-08-04 |

### 5. WHAT LOOKS UNNAMEABLE

`Vl` — **confirmed to compress at least five mechanisms here, and they are visibly separate
files**: `NodeOperatorManager` (registration + per-source-of-funds approval),
`AuctionManager` (a market for the slot), `StakingManager` (predeposit + key + beacon
deposit), `EtherFiNodesManager` (exit, consolidation, call forwarding, rate limits), and
`EtherFiRestaker` (the EigenLayer leg). The corpus's "same compression problem as Lido plus
two extra layers" is right, and the repo layout is the proof: the protocol itself does not
model these as one thing.

Unnamed mechanisms:

- **A node-operator auction.** `AuctionManager` clears a priced market for the *right to
  operate*, with min/max bid bounds, a whitelist tier at a distinct price, and bid revenue
  forwarded to the treasury. Confirmed unnameable — it is not an emission, not a fee, not a
  gate. It is closer to a primary auction for a licence.
- **Per-selector, per-target call forwarding into a foreign protocol.**
  `allowedForwardedEigenpodCalls[user][selector]` and
  `allowedForwardedExternalCalls[user][selector][target]` grant a bounded right to execute
  arbitrary calls from the validator's own node contract into EigenLayer or elsewhere.
  This is the closest thing in the whole category to `Au` (delegated execution scope) — but
  it is delegated *by the protocol to itself*, gated by a role registry, and its purpose is
  to let one protocol drive another's state machine. Nothing names "an adapter with a
  selector allowlist for driving a foreign protocol".
- **A three-door exit with different prices and different rights.** Instant (fee + token
  bucket + TVL low-watermark), standard (queue + admin finalisation + frozen rate), priority
  (whitelist + min delay). `Wq` names one queue. Here the *choice among queues* is itself the
  mechanism, and one of the doors is priced.
- **Rate freezing at finalisation.** Invariant I3 — the claim amount is invariant under
  subsequent rebases — is a deliberate severing of a claim from the accounting index at a
  named block. `Rb` and `Wq` together cannot say this; it is the difference between a queue
  position and a fixed-price forward.
- **A token-bucket rate limiter as a solvency instrument.** `EtherFiRateLimiter` +
  `BucketLimiter` gate unrestaking, exit requests and consolidations, and cap instant
  redemptions. This is not a pause and not a cap; it is a refilling budget on a state
  transition, and it appears three times in this one protocol.
- **A hard cap on positive rebase.** LiquidityPool's bps ceiling on how far one rebase may
  raise TVL is an oracle-error containment device on the accounting itself.
- **DVT.** One key split across a cluster with a signing threshold. Confirmed unnameable —
  though see DELTA on where ether.fi actually uses it.
- **Off-chain points converted to a token.** ether.fi's loyalty points → ETHFI is the
  canonical instance. The corpus is right that nothing names a discretionary, revocable,
  off-chain promissory ledger. Note that the on-chain residue of the early programme
  (`EarlyAdopterPool`, `LoyaltyPointsMarketSafe`, `membership/`) now sits in `archive/`,
  which is itself evidence: the instrument lived and died off-ledger.

### 6. DELTA

- **The `Tr` marker is stale. `TNFT.sol` and `BNFT.sol` are in `src/archive/`.** The
  T-NFT/B-NFT two-tier structure the corpus describes as "a bond, described in tranche
  language" is no longer part of the live protocol; the files are retained only for storage
  continuity. Any decomposition carrying `Tr` for ether.fi is decomposing a dead mechanism.
  (GitHub API `contents/src/archive`, accessed 2026-08-04.)
- **`Bs` is now doubtful for ether.fi.** The whitepaper states permissioned operators are
  "**not required to post a bond as collateral**" and solo stakers run "without posting any
  collateral". With B-NFTs archived, **UNKNOWN: whether any operator-posted first-loss
  capital exists in the current design at all.** The corpus lists `Bs` in ether.fi's
  canonical form; that needs re-testing, not inheriting.
- **The withdrawal architecture has tripled.** The corpus knows one withdrawal queue. The
  live protocol has `WithdrawRequestNFT` (with rate freezing, an audit-driven H-02 fix),
  `EtherFiRedemptionManager` (instant, fee-bearing, bucket-limited, low-watermarked) and
  `PriorityWithdrawalQueue` (whitelisted, min-delay) — the last audited only in **2026-03**.
- **A protocol-wide `Blacklister` exists** and is wired into eETH, the LiquidityPool, the
  AuctionManager and all three withdrawal paths. The corpus's element list for ether.fi
  contains no freeze/permission symbol at all.
- **Validator sizing changed.** `MAX_VALIDATOR_SIZE_WEI = 2048 ether` and
  `FULL_EXIT_GWEI = 2_048_000_000_000` — ether.fi is on Pectra-era 0x02 validators with
  consolidation, matching Lido's LIP-35 move. Any "32 ETH unit" framing is stale.
- **The DVT claim needs narrowing.** The corpus asserts DVT "is used by ether.fi". The
  first-party evidence I could obtain places Obol/Charon in the **Operation Solo Staker**
  programme (cluster with a 3/4 threshold), not demonstrably in the main permissioned
  operator set, and the primary page 404'd on direct fetch. **UNKNOWN: what fraction of
  ether.fi's validator set is distributed.** The category-level residue point about DVT
  being the largest unnamed mechanism by TVL stands on Lido Simple DVT + SSV + Obol
  regardless; the ether.fi leg of it is weaker than the corpus states.
- **Restaking is no longer just EigenLayer-shaped in this repo.** AVS registration and
  operator management moved out to `etherfi-avs-operator` / `avs-smart-contracts`, and
  restaking rewards now route through **KING** (a separate protocol org). The corpus's
  "EigenLayer, Symbiotic, Karak" framing is not contradicted, but the *control* of AVS
  participation is now an out-of-repo, permissioned object. **UNKNOWN: which AVSs and which
  restaking venues are live as of 2026-08.**
- **`RoleRegistry` + two timelocks + `PausableUntil`** is a materially more structured
  control plane than the corpus's `Tg`/`Up`/`Gp` triple suggests: authority is centralised
  in one registry contract that almost every other contract reads, which makes the registry
  a single point of governance failure worth naming.

---

## Babylon Protocol

### 1. WHAT IT DOES

A Bitcoin holder locks BTC **on Bitcoin**, in a Taproot output they construct themselves,
and never gives up custody or bridges the coin. The output has three spending paths: a pure
timelock back to the staker, an unbonding path co-signed by a covenant committee, and a
slashing path. The staker names a **finality provider** in that output and registers the
staking transaction on **Babylon Genesis**, a Cosmos-SDK chain that watches Bitcoin through
a light client. Once a quorum of the covenant committee submits its pre-signatures, the
delegation becomes ACTIVE and its satoshis count toward the chosen finality provider's
voting power. The finality provider then runs a second, EOTS-based voting round on top of
the chain's ordinary consensus; a block is final once providers holding more than 2/3 of
voting power have voted. Rewards accrue in BABY (and are shared with the provider net of a
commission of at least 3%); since the co-staking module a user who *also* stakes BABY to a
CometBFT validator earns an additional score-weighted reward. Exit has two shapes: wait out
the timelock, or unbond on demand by broadcasting a pre-signed unbonding transaction that
the covenant has already authorised, then wait a further unbonding timelock. Loss is
peculiar: if the finality provider signs two conflicting blocks at the same height, the
double signature **mathematically reveals its private key**, and anyone can then assemble
the slashing transaction that sends a fraction of the delegated BTC to an unspendable
output. The provider's voting power goes to zero permanently (tombstoning).

### 2. DESIGN

**The Bitcoin side — the staking script.** A Taproot output with the **NUMS point** as
internal key, disabling key-path spending:
`H = lift_x(0x50929b74c1a04954b78b4b6035e97a5e078a5a0f28ec96d547bfee9ace803ac0)`.
Three tapleaves, verbatim from the spec:

```
# timelock path
<StakerPK> OP_CHECKSIGVERIFY  <TimelockBlocks> OP_CHECKSEQUENCEVERIFY

# unbonding path
<StakerPk> OP_CHECKSIGVERIFY
<CovenantPk1> OP_CHECKSIG <CovenantPk2> OP_CHECKSIGADD ... <CovenantPkN> OP_CHECKSIGADD
<CovenantThreshold> OP_NUMEQUAL

# slashing path
<StakerPk> OP_CHECKSIGVERIFY
<FinalityProviderPk> OP_CHECKSIGVERIFY
<CovenantPk1> OP_CHECKSIG <CovenantPk2> OP_CHECKSIGADD ... <CovenantPkN> OP_CHECKSIGADD
<CovenantThreshold> OP_NUMEQUAL
```

Timelock maximum 65,534 blocks. Covenant keys lexicographically sorted; all pubkeys unique
within a stake. The slashing timelock equals the unbonding time parameter.

**The covenant emulation committee.** Bitcoin has no covenant opcode, so a threshold signer
set stands in for one. Mainnet (`bbn-1`): **9 seats, quorum 6**. Seat allocation is published:
**Babylon Labs 3**, CoinSummer Labs 1, RockX 1, AltLayer 1, Zellic 1, Informal Systems 1,
Cubist 1. In Phase-2 the members run `covenant-emulator`, a daemon that watches Babylon
Genesis for pending registrations and submits signatures for the unbonding, slashing and
unbonding-slashing transactions; in Phase-1 they ran `covenant-signer`, which signed
unbonding only. Babylon's own docs warn that the published key list "might be outdated" and
that the node parameters are the source of truth — the committee is mutable by governance.

**Mainnet parameters, live** (`babylon/btcstaking/v1/params`, bbn-1):
`covenant_pks` 9, `covenant_quorum` **6**, `min_staking_value_sat` **500,000**,
`max_staking_value_sat` **500,000,000,000**, `min_staking_time_blocks` **64,000**,
`max_staking_time_blocks` **64,000**, `min_slashing_tx_fee_sat` **150,000**,
**`slashing_rate` 0.001 (0.1%)**, `unbonding_time_blocks` **301**, `unbonding_fee_sat`
**9,600**, `min_commission_rate` **0.03 (3%)**, `allow_list_expiration_height` **139,920**,
`btc_activation_height` **905,634**. `slashing_pk_script` is base64 `agdiYWJ5bG9u`, which
decodes to hex `6a 07 62 61 62 79 6c 6f 6e` — i.e. **`OP_RETURN <push 7> "babylon"`**. Slashed
BTC is provably burned to an unspendable OP_RETURN output tagged with the protocol name.
(The Phase-1 `global-params.json` records the earlier regime: staking cap 1,000 BTC at
version 0, `unbonding_time` 1,008 blocks, `confirmation_depth` 10, activation height 857,910.)

**Finality parameters, live** (`babylon/finality/v1/params`): `max_active_finality_providers`
**60**, `signed_blocks_window` **10,000**, `min_signed_per_window` **0.2**, `min_pub_rand`
**8,192**, `finality_sig_timeout` **3**, `jail_duration` **600s**,
`finality_activation_height` **27,600**.

**Chain modules** (`x/`): `btcstaking`, `finality`, `btclightclient`, `btccheckpoint`,
`checkpointing`, `epoching`, `incentive`, `costaking`, `mint`, `monitor`.

- **`x/btcstaking`** stores finality providers keyed by BIP-340 pubkey (address, description,
  commission rate, slashed flag), BTC delegations keyed by staking-tx hash (delegator,
  finality-provider list, staking details, slashing and unbonding transactions, covenant
  signatures), and a delegator→delegation index. Lifecycle states PENDING → VERIFIED →
  ACTIVE → UNBONDED / EXPIRED. Messages: `MsgCreateFinalityProvider`,
  `MsgEditFinalityProvider`, `MsgCreateBTCDelegation`, `MsgAddBTCDelegationInclusionProof`,
  `MsgAddCovenantSigs`, `MsgBTCUndelegate`, `MsgSelectiveSlashingEvidence`, `MsgUpdateParams`.
  An optional **allow-list** restricts which staking transactions may register (mainnet
  `allow_list_expiration_height` 139,920).
- **`x/finality`**: providers commit Merkle-tree **public randomness** for future heights,
  and those commitments take effect **only after they have been BTC-timestamped**. Voting
  power goes to the top *N* providers that have timestamped randomness for that height,
  ranked by delegated value. On a conflicting vote at one height the module "save[s] the
  equivocation evidence, such that anyone can extract the finality provider's secret key".
  The EndBlocker marks a provider **sluggish** once missed blocks exceed the window
  threshold. Finalisation requires >2/3 voting power.
- **`x/incentive`**: two gauge types — `Gauge` (rewards pending distribution) and
  `RewardGauge` (per-stakeholder ledger with `withdrawn_coins`). At BeginBlocker the module
  intercepts the fee collector and creates a BTC-staking gauge; `x/finality`'s EndBlocker
  calls `HandleRewarding` → `RewardBTCStaking` to split by voting power net of provider
  commission. The split lever is **`btc_staking_portion`**, and "sum of the portions should
  be strictly less than 1 so that the rest will go to Comet validators/delegations".
  **UNKNOWN: the live mainnet value of `btc_staking_portion`.**
- **`x/costaking`** (new): tracks users who hold *both* an active BTC delegation to an
  active finality provider *and* a BABY delegation to a CometBFT validator.
  `CostakerRewardsTracker { StartPeriodCumulativeReward, ActiveSatoshis, ActiveBaby,
  TotalScore }`, maintained by hooks from `x/finality`, `x/staking` and `x/incentive`.
- **`x/btccheckpoint` + `x/btclightclient` + `x/checkpointing` + `x/epoching`**: the
  timestamping half. Babylon aggregates its own state into succinct checkpoints written to
  Bitcoin, and runs a Bitcoin light client so the chain can read Bitcoin's headers and
  verify staking transaction inclusion. Bitcoin is entirely unaware of Babylon.

**Security model, stated plainly.** The BTC never leaves Bitcoin. Enforcement rests on
(a) Bitcoin script for the timelock, (b) a 6-of-9 human committee for unbonding and slashing
signatures, and (c) EOTS key extraction for the slashing *trigger*. The committee is a
trusted party inside the model: it must exist and cooperate for on-demand unbonding to work
at all, and it must have pre-signed for slashing to be executable.

**Beyond staking (2026).** Babylon is building **Trustless Bitcoin Vault (TBV)** — BTC locked
on Bitcoin under pre-signed transactions with cryptographic spending conditions, usable as
collateral in Ethereum DeFi, with withdrawal gated on submitting a zero-knowledge proof
matching smart-contract logic; a public testnet was announced for late May 2026, with peg-in
around three hours. Docs describe it as "Native Bitcoin collateral for Ethereum DeFi, with
BTC remaining locked on Bitcoin". Related work: `aave-v4-bots` ("Bitcoin-collateralized
positions through Babylon's Trustless Vault protocol"). **This is not the staking protocol
and should not be folded into it.**

### 3. REPO

- **Canonical:** https://github.com/babylonlabs-io/babylon — **Go**, default branch `main`,
  101 stars, `pushed_at` 2026-08-04T18:14:36Z (same day as this research).
  **Latest release `v4.3.1`, published 2026-07-21T16:36:45Z, target `main`.**
- **Licence: Business Source License 1.1**, Licensor **Babylon Labs Limited**. (GitHub
  reports `NOASSERTION`; the LICENSE file header is authoritative. **UNKNOWN: the Change
  Date and Change Licence** — I read only the first 12 lines.) **Like EigenLayer, this is
  not an OSI-open licence today.**
- **Top level:** `app/`, `x/`, `btcstaking/`, `btctxformatter/`, `client/`, `cmd/`,
  `crypto/`, `contrib/`, `docs/`, `proto/`, `scripts/`, `test/`, `testutil/`, `types/`,
  `wasmbinding/`, plus `CHANGELOG.md`, `CONTRIBUTING.md`, `RELEASE_PROCESS.md`,
  `SECURITY.md`, `Makefile`, `go.mod`/`go.sum`, `.goreleaser.yml`, `gosec.json`. Builds to
  `babylond` with Go 1.25.
- **`docs/`:** `architecture.md`, `staking-script.md`, `register-bitcoin-stake.md`,
  `bitcoin-stake-extension.md`, `transaction-impl-spec.md`, `bls_key_password_management.md`,
  `ibc-relayer.md`, `static/`. Each `x/` module additionally carries its own `README.md`.
- **Mainnet parameters repo:** https://github.com/babylonlabs-io/networks —
  `bbn-1/parameters/global-params.json`, `bbn-1/covenant-committee/covenant-committee.json`
  and `README.md`, `bbn-1/finality-providers/`, `bbn-1/babylon-validators/`,
  `bbn-1/babylon-node/`, `bbn-1/network-artifacts/`, plus `bbn-test-5/`, `bbn-test-6/`.
- **Off-chain components, each its own repo:** `covenant-emulator` (Phase-2 committee
  daemon), `covenant-signer` (Phase-1), `finality-provider`, `btc-staker`, `vigilante`
  (BTC↔Babylon relaying/monitoring), `staking-indexer` and `babylon-staking-indexer`,
  `staking-api-service`, `staking-expiry-checker`, `staking-queue-client`,
  `rollup-finality-gadget`, `btc-staking-ts`, `cli-tools`, `babylon-sdk` (MIT),
  `storage-contract` (Apache-2.0), `babylon-toolkit`.
- **Deployed vs repo:** this is the one case where "deployed contracts match the repo" is
  the wrong question — there are no contracts. What is verifiable: the running chain's
  parameters can be read from any public node and compared to the repo
  (I did: `babylon-api.polkachu.com` matched the module schema exactly), and the covenant
  key set is published in `networks/` *and* readable on chain. **Note the mismatch I found:
  `networks/bbn-1/parameters/global-params.json` records `unbonding_time` 1,008 while the
  live chain reports `unbonding_time_blocks` 301** — these are Phase-1 vs Phase-2 regimes,
  not a contradiction, but a stage-2 reader could easily take the wrong number.

### 4. EVIDENCE

| Claim | Source | Accessed |
|---|---|---|
| Repo metadata (Go, main, pushed 2026-08-04), release v4.3.1 dated 2026-07-21, top-level and `x/` listings, docs listing, Go 1.25, `babylond` | GitHub API `repos/babylonlabs-io/babylon` + `/releases/latest` + `/contents` + `/contents/x` + `/contents/docs`; `README.md` | 2026-08-04 |
| LICENSE is Business Source License 1.1, Licensor Babylon Labs Limited | https://github.com/babylonlabs-io/babylon/blob/main/LICENSE | 2026-08-04 |
| Two protocols (timestamping + staking); litepaper and arXiv timestamping paper links | https://github.com/babylonlabs-io/babylon/blob/main/README.md ; https://arxiv.org/abs/2207.08392 | 2026-08-04 |
| Staking script: NUMS internal key and its hex, three tapleaf scripts verbatim, 65,534-block timelock max, covenant threshold, sorted keys, slashing timelock = unbonding time, burn address from genesis params | https://github.com/babylonlabs-io/babylon/blob/main/docs/staking-script.md (raw) | 2026-08-04 |
| btcstaking module state, lifecycle states, message set, parameter names, allow-list, slashing_rate as a two-decimal proportion | https://github.com/babylonlabs-io/babylon/blob/main/x/btcstaking/README.md (raw) | 2026-08-04 |
| finality module: pub-rand commitments effective only after BTC timestamping, EOTS votes, >2/3 finalisation, equivocation evidence enabling anyone to extract the secret key, sluggish detection, top-N voting power | https://github.com/babylonlabs-io/babylon/blob/main/x/finality/README.md (raw) | 2026-08-04 |
| incentive module: Gauge/RewardGauge, BeginBlocker fee interception, HandleRewarding/RewardBTCStaking, `btc_staking_portion` and the <1 constraint, MsgWithdrawReward | https://github.com/babylonlabs-io/babylon/blob/main/x/incentive/README.md (raw) | 2026-08-04 |
| costaking module: definition of a costaker, `CostakerRewardsTracker` fields, hooks from x/finality, x/staking, x/incentive | https://github.com/babylonlabs-io/babylon/blob/main/x/costaking/README.md (raw) | 2026-08-04 |
| Live mainnet btcstaking params: 9 covenant pks, quorum 6, 500,000–500,000,000,000 sat, 64,000-block staking time, min slashing fee 150,000, **slashing_rate 0.001**, unbonding_time_blocks 301, unbonding_fee 9,600, min_commission 0.03, allow_list_expiration 139,920, btc_activation_height 905,634, slashing_pk_script `agdiYWJ5bG9u` | https://babylon-api.polkachu.com/babylon/btcstaking/v1/params | 2026-08-04 |
| `agdiYWJ5bG9u` decodes to `6a 07 62 61 62 79 6c 6f 6e` = OP_RETURN "babylon" | local base64/xxd decode of the value above | 2026-08-04 |
| Live mainnet finality params: 60 active FPs, 10,000-block window, 0.2 min signed, 8,192 min pub rand, 3-block sig timeout, 600s jail, activation height 27,600 | https://babylon-api.polkachu.com/babylon/finality/v1/params | 2026-08-04 |
| Phase-1 global params (covenant quorum 6, unbonding_time 1008, staking cap 1,000 BTC at v0, confirmation_depth 10, activation 857,910; caps raised at v1/v2) | https://github.com/babylonlabs-io/networks/blob/main/bbn-1/parameters/global-params.json | 2026-08-04 |
| Covenant committee: 9 seats, Babylon Labs 3 + CoinSummer/RockX/AltLayer/Zellic/Informal/Cubist 1 each; Phase-1 covenant-signer vs Phase-2 covenant-emulator; node params are the source of truth | https://github.com/babylonlabs-io/networks/blob/main/bbn-1/covenant-committee/README.md | 2026-08-04 |
| Babylon Genesis as "control plane for Bitcoin staking security and liquidity orchestration"; BABY 10bn supply, 6 decimals; dual staking BTC + BABY; Phase-1 57,000 BTC | https://docs.babylonlabs.io/guides/overview/babylon_genesis/ | 2026-08-04 |
| Bitcoin staking overview: self-custodial script with holder signature / timelock / covenant consensus; EOTS + covenant enable slashing; "Liquidity Assurance: Secure, efficient unbonding without social consensus" | https://docs.babylonlabs.io/guides/overview/bitcoin_staking/ | 2026-08-04 |
| Docs landing page names Bitcoin Staking, Trustless Bitcoin Vault ("Native Bitcoin collateral for Ethereum DeFi, with BTC remaining locked on Bitcoin"), Finality Providers, Babylon Genesis | https://docs.babylonlabs.io/ | 2026-08-04 |
| TBV paper and research page | https://docs.babylonlabs.io/papers/trustless-bitcoin-vaults.pdf ; https://docs.babylonlabs.io/trustless-bitcoin-vault/research/btc_trustless_vault/ | 2026-08-04 (referenced, **not fetched — UNCONFIRMED contents**) |
| TBV testnet timing (late May 2026), ~3h peg-in, ZK-gated withdrawal | secondary coverage (Blockonomi, Bitget) — **UNCONFIRMED at primary source** | 2026-08-04 |
| Aave-v4 bots repo describing "Bitcoin-collateralized positions through Babylon's Trustless Vault protocol" | GitHub search API `org:babylonlabs-io` | 2026-08-04 |
| Tombstoning / permanent loss of voting power after double-sign | secondary (docs.kiln.fi, figment.io summaries) — **UNCONFIRMED at a Babylon-first-party source**; the first-party `x/finality` README confirms voting-power removal and evidence recording but I did not confirm the permanence | 2026-08-04 |

### 5. WHAT LOOKS UNNAMEABLE

`Vl` — **confirmed equivocal, third time, and for a different reason than EigenLayer.** A
finality provider registers (`MsgCreateFinalityProvider`), is delegated to, has voting power,
can be jailed (600s) and can be slashed — a lifecycle shape. But: it validates nothing on
Bitcoin; it does not necessarily produce blocks on the chain it finalises (Babylon Genesis
has a *separate* CometBFT validator set staked in BABY); its "key" is a per-height EOTS
one-time key, not a persistent consensus key; and its duty is to vote in a **second** round
after consensus has already concluded. Using `Vl` for this, for an EigenLayer operator, and
for a Lido node operator asserts a threefold sameness that none of the three codebases
supports. Note also the structural oddity: Babylon Genesis has **two** validator-like
populations — finality providers (BTC-weighted) and CometBFT validators (BABY-weighted) —
and `Vl` cannot distinguish them.

Unnamed mechanisms:

- **Stake that never enters the system that slashes it.** The BTC sits in a UTXO on Bitcoin,
  under a script the staker wrote. Babylon holds nothing. Every other protocol in this
  category custodies the stake, and `Bs` presumes it. Confirmed unnameable — and the sharper
  statement is that the *securing relationship* is a set of pre-signatures held by third
  parties, not a balance.
- **Extractable-one-time-signature slashing.** The enforcement primitive is that
  equivocation *leaks the key*, after which anyone can finish the job. `Sl` names a loss
  being assigned; here nothing is assigned — a secret becomes public and a pre-authorised
  transaction becomes broadcastable by the public. Confirmed unnameable, and I found no
  analogue anywhere else in the 12 categories' vocabulary.
- **Covenant emulation.** A 6-of-9 threshold committee standing in for a script opcode
  Bitcoin does not have. `Aw` calls this a permission gate, which is a serious
  understatement: the committee's signatures are *load-bearing for both exit and
  enforcement*, and its absence breaks on-demand unbonding while its collusion is a live
  risk. Add the concentration fact — 3 of 9 seats held by Babylon Labs against a quorum of
  6 — which no gate symbol can express.
- **Pre-signed transactions as a security primitive.** The unbonding and slashing
  transactions exist, fully signed, *before* the event that would justify them. A
  conditional obligation that has already been executed and is merely waiting to be
  broadcast is not a queue, not an escrow and not an option.
- **Randomness that must be timestamped before it counts.** Public-randomness commitments
  take effect only after being BTC-timestamped. A protocol whose votes are only valid if a
  *foreign chain* has already witnessed the commitment is unlike anything `Ex` or `Xm` names.
- **Bitcoin timestamping as a clock.** Checkpointing PoS state into Bitcoin to bound
  long-range attacks. `Xm` names verifying a delivered message; nothing is delivered,
  nothing is sent, and Bitcoin does not know Babylon exists. Confirmed unnameable.
- **Unbonding as a race between a pre-signed transaction and a timelock**, with an explicit
  post-unbonding slashing window (slashing timelock = unbonding time) during which the coin
  is out of the staking output but still slashable. Confirmed unnameable.
- **Co-staking as a scored product of two unrelated stakes.** `x/costaking` pays a bonus
  computed from `min`-like scoring over `ActiveSatoshis` and `ActiveBaby`. A reward keyed on
  holding two *different* positions in two *different* consensus systems is not an emission
  and not a fee.
- **An allow-list with an expiry height.** `allow_list_expiration_height` 139,920 — a
  permission gate that turns itself off at a scheduled block. `Aw` has no temporal dimension.

### 6. DELTA

- **`slashing_rate` is 0.001 — one tenth of one percent.** The corpus treats Babylon's
  slashing as a first-order loss mechanism ("the BTC is slashable first-loss capital"). On
  mainnet, a double-sign burns **0.1%** of the delegation. The dominant consequence for the
  staker is not the burn; it is that the provider is zeroed and the position stops earning.
  Any construction that models Babylon slashing as materially loss-bearing is modelling the
  wrong magnitude. (Live chain params, accessed 2026-08-04.)
- **The burn is an OP_RETURN, and it is legible.** `slashing_pk_script` decodes to
  `OP_RETURN "babylon"`. Slashed BTC is provably destroyed and tagged. The corpus says
  slashing "burns the delegated BTC" without recording that the burn is a *self-identifying
  provable* destruction on the securing chain — which is arguably the most interesting fact
  about it.
- **The covenant committee is 6-of-9 with 3 seats to one entity.** The corpus records the
  committee as a residue item but no numbers. Babylon Labs holds one third of the seats
  against a quorum of six; the committee is also mutable by governance and the docs
  explicitly warn that the published key list may be stale.
- **`x/costaking` did not exist when the corpus was written.** BTC + BABY dual-position
  scored rewards is a new mechanism with a new state object, and it links the BTC staking
  system to the chain's own PoS system in a way the corpus's model does not contain.
- **Two unbonding regimes, two different numbers.** `networks/bbn-1/parameters/global-params.json`
  (Phase-1) says `unbonding_time` **1,008**; the live chain says `unbonding_time_blocks`
  **301**. Stage 2 must use the on-chain value and must know the file is Phase-1.
- **The finality set is capped at 60** (`max_active_finality_providers`) with a 600-second
  jail and a 10,000-block liveness window at 20% minimum. None of these appear in the corpus,
  and the cap in particular makes the finality-provider population a *bounded, competitive*
  set rather than an open one.
- **Licence.** BUSL-1.1 (Babylon Labs Limited). Not recorded in the corpus. Same caution as
  EigenLayer.
- **Scope creep the corpus does not cover: TBV.** Babylon's own docs landing page now leads
  with the Trustless Bitcoin Vault — native BTC collateral for Ethereum DeFi, ZK-gated
  withdrawal — alongside staking. If TBV ships, Babylon stops being purely a
  security-sharing protocol and becomes a Bitcoin collateral rail, which would change which
  category it belongs to. **UNKNOWN: mainnet status as of 2026-08-04** (testnet was
  announced for late May 2026 in secondary coverage only).
- **"Bitcoin Supercharged Networks" (BSNs) is the current first-party term** for what the
  corpus calls consumer zones / secured chains (docs.babylonlabs.io/bsns/ — the section
  exists; the page 404'd on direct fetch). **UNKNOWN: multi-staking semantics — whether one
  BTC delegation can secure several BSNs simultaneously and how slashing is scoped across
  them.** This is the single most important open question for stage 2 on Babylon, because if
  the answer is "yes, with per-BSN slashing conditions", Babylon inherits exactly the
  unique-stake problem EigenLayer solved with magnitudes — and it is the difference between
  `Rs` being adequate and being empty.

---

## Cross-cutting notes for stage 2

1. **`Vl` should not be promoted.** Confirmed at the code level in all five: it is unusable
   for WBETH (no on-chain validator lifecycle exists), compresses six mechanisms in Lido,
   compresses five in ether.fi, is equivocal for an EigenLayer operator (while a *genuine*
   validator lifecycle simultaneously exists in `EigenPod`), and is equivocal again for a
   Babylon finality provider (which is one of *two* validator-like populations on that
   chain). The corpus's proposed split — (a) key registration/vetting, (b) allocation/
   scheduling, (c) exit/unbonding coordination, (d) operator-selection market, plus threshold
   key committees — is supported by the evidence, and I would add (e) **validator sizing,
   top-up and consolidation** (Lido LIP-35, ether.fi `MAX_VALIDATOR_SIZE_WEI`), which is
   neither entry nor exit.
2. **Two of five reference implementations are BUSL-1.1**, not open source (EigenLayer core
   contracts, Babylon). A third (WBETH) is UNLICENSED closed source with only verified
   bytecode. Only Lido (GPL-3.0) and ether.fi (MIT) are unambiguously open.
3. **Three of five have a rate limiter or bucket on a state transition** (ether.fi's
   `EtherFiRateLimiter`/`BucketLimiter`, WBETH's `ExchangeRateUpdater` allowance, Lido's
   per-module deposit rate limits and LazyOracle quarantine). Nothing in the 58 names a
   refilling budget on a transition, and it recurs.
4. **Anti-front-running of the deposit path is a category-universal mechanism with three
   incompatible implementations** — Lido's guardian signature quorum (DSM), Lido V3's
   predeposit + EIP-4788 credential proof with guarantee seizure (PDG), and ether.fi's
   1 ETH `INITIAL_DEPOSIT_AMOUNT`. WBETH and Babylon do not have the problem, for opposite
   reasons. This is a strong candidate for a new element.
5. **The oracle in this category never reports a price.** Lido's AccountingOracle,
   ether.fi's EtherFiOracle and Lido's LazyOracle are all *quorum-signed state reports* with
   sanity checks, freshness gates and, in one case, a value quarantine. Forcing `Ex` here
   loses the failure mode, which is not staleness or manipulation of a market price but
   collusion on a balance.
