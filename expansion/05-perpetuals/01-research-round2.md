# Stage 1 research, round 2 — Perpetuals / derivatives (05-perpetuals)

Lane: Hyperliquid · ApeX Protocol (ApeX Omni) · Aster · Lighter · edgeX. **Supplement to `01-research.md`, not a replacement.** Documentation access date **2026-08-04** throughout. On-chain reads were taken at Ethereum block **25,686,150** (2026-08-05 03:50 UTC), Arbitrum block **491,233,403**, BNB block **114,091,558**, and are each stated with the value read, so any auditor can re-run them.

**What round one left open, and what this round closed.** Round one marked five things UNKNOWN and stage 3 then found that all twenty-five trust-model obligations across the five venues came back as residue, so five plainly different objects emitted the same six elements. That could have been a real property of the vocabulary or an artefact of thin sourcing. It was partly the latter, and the thin sourcing was concentrated in exactly the places round one flagged. This round closes: **ApeX's matching locus** (a primary statement exists — at zkLink, not at ApeX), its **data-availability configuration** (on-chain state diffs on Arbitrum One, not a committee), its **exit-window deadline** (2,592,000 blocks, which is a different number of days on every chain), and its **auditor** (ABDK ×4 on zkLink X in 2023; none on ApeX Omni, none on any matching engine); **edgeX's live custody stack** (StarkEx, today, holding $69.2M against EDGE Chain's $58.5K), its **proof regime** (interactive fraud proofs with a whitelisted validator set and a 2-of-5 DA committee — a *downgrade* from V1's validity proofs), and its **loss-absorption layer** (ADL, bankruptcy price and a liquidation-fee schedule all exist, as machine-readable API fields, and are stated as policy nowhere); and **Aster's** validator-set size (nine, all named), admission rule (published but contradicted), and escape hatch (there is none — a confirmed negative over the complete corpus). It also closes the funding question for all five, where one venue turns out not to run a long/short transfer at all.

Two findings were produced by measurement rather than reading, and both are decisive. **ApeX's escape hatch cannot execute on four of the five chains it publishes for that purpose**, because the deployed exit-proof verifier on those chains rejects every proof unconditionally; I reproduced this independently of the source that first suggested it. And **the custody quorum is smaller than the consensus set at Aster** — nine validators secure the chain, two signatures move a withdrawal, and $264.4M sits behind the latter.

The stage-3 verdict survives, and is now better evidenced than before: the five venues are sharply distinguishable on evidence, and the vocabulary still cannot tell them apart. Where round one recorded UNKNOWN because a venue was silent, this round in several cases shows the venue is silent *while the fact is publicly determinable* — which is a stronger form of the same finding, because it removes the excuse that the information does not exist.

**A methodological note that bears on invariant 5.** Round one's absence claims were made against documentation corpora whose provenance was not recorded. When I re-downloaded all five `llms-full.txt` corpora I verified each file's provenance by cross-term census before quoting any absence from it (`hyperliquid.txt`: 343 hyperliquid / 0 apex / 0 lighter / 0 edgex; and analogously for the rest; edgeX's corpus is **514,932 bytes**, not the 414 KB round one reports). Two of round one's absence claims were wrong. An absence claim is a measurement and needs its instrument recorded.

---

## Hyperliquid

### Funding — stated exactly

Charged **hourly**, at one eighth of the eight-hour rate. `Funding Rate (F) = Average Premium Index (P) + clamp(interest rate − Premium Index (P), −0.0005, 0.0005)`, capped at 4%/hour. Longs pay shorts when positive. Two properties matter for reconstruction and round one has one of them:

- The notional is computed at the **spot oracle price**: *"The spot oracle price is used to convert the position size to notional value, **not the mark price**."*
- It is **conserved**: *"Funding is purely peer-to-peer and no fees are collected on the payments."*

Source: https://hyperliquid.gitbook.io/hyperliquid-docs/trading/funding.md (2026-08-04). This is a clean long/short transfer with no third party — the only one of the five for which that is stated in those words *and* true without qualification.

### Who may halt a market — the delisting vote

Round one recorded market delisting as one of four ways a position can end but did not record what delisting *is*. It is the sharpest documented instance of operator discretion in the lane, and it is a validator power:

> "Validators vote on whether to delist validator-operated perps. If validators vote to delist an asset, the perps will settle to the 1 hour time weighted spot oracle price before the scheduled delisting voting time. This is a settlement mechanism used by many centralized exchanges."
>
> "When an asset is delisted, all positions are settled and open orders are cancelled. Users who wish to avoid automatic settlement should close their positions beforehand. After settlement, no new orders will be accepted."

— https://hyperliquid.gitbook.io/hyperliquid-docs/llms-full.txt (2026-08-04), *Delisting*.

So a two-thirds-weighted vote can terminate every position in a market at a price of the protocol's choosing, and the only user defence named is to have closed first. `Ct`, `Li` and `Ad` all describe involuntary position closure; none describes closure by *vote*, and none describes a settlement price chosen by the closing party.

### The absence census, on a provenance-checked corpus

Over `llms-full.txt` (493,845 bytes, 343 hyperliquid / 0 apex / 0 lighter / 0 edgex), case-insensitive:

| term | count |
|---|---|
| `escape hatch` | **0** |
| `forced withdrawal` / `force withdraw` | **0** / **0** |
| `censorship` | **0** |
| `emergency` | **0** |
| `pause` | **0** |
| `insurance fund` | **0** |
| `socializ` | 1 — the ADL invariant, *"a user who has no open positions will not socialize any losses of the platform"* |

Hyperliquid documents no escape hatch, no forced-inclusion path, no pause authority and no emergency power, and it documents no insurance fund. The first four absences are the answer to "what can a user do unilaterally": nothing. The last confirms that HLP is the whole loss-absorption story.

### New material round one did not carry

**The Assistance Fund.** A fee sink at the system address `0xfefefefefefefefefefefefefefefefefefefefe`: *"It converts trading fees to HYPE in a fully automated manner as part of the L1 execution. HYPE in the assistance fund is burned, removing the tokens permanently from the circulating and total supply."* Fees not directed to HLP or deployers land here; fees in non-USDC quote tokens are sent here (https://hyperliquid.gitbook.io/hyperliquid-docs/llms-full.txt, 2026-08-04). Round one's residue counts five roles for HLP; the fee waterfall has a second, burn-terminated sink that the residue does not mention at all.

**AQAv2 is a two-sided slashable bond, not one.** Round one records "1M HYPE total". The corpus states a *treasury deployer* staking **500k HYPE**, slashable *"if the treasury address does not have sufficient balance for onchain revenue to be deducted"* at *"an interest rate of 2% per day"*, and a *technical deployer* staking **500k HYPE** for *"reliable mint, redemption, and cross-chain transfer infrastructure"*, with **6 months minimum notice before ceasing operation, during which their stake is slashable**, and a 9:1 holding ratio between treasury and technical deployer. Activation is by validator vote. This is a slashable bond securing *an off-venue operational commitment by a stablecoin issuer*, with a notice period, which is further from `Bs` than round one's version.

### Measured

The bridge is published — round one did not carry the address. Docs: *"The bridge between Hyperliquid and Arbitrum: https://arbiscan.io/address/0x2df1c51e09aecf9cacb7bc98cb1742757f163df7"* and *"The bridge code: https://github.com/hyperliquid-dex/contracts/blob/master/Bridge2.sol"* (https://hyperliquid.gitbook.io/hyperliquid-docs/llms-full.txt, 2026-08-04, *Bridge2*). Read on Arbitrum at block 491,233,403: contract, 19,394 bytes of code, holding **420,637,485.05 USDC** (`balanceOf` on `0xaf88d065e77c8cC2239327C5EDb3A432268e5831`).

So Hyperliquid is the largest custody position in the lane after Lighter, and the exit path for all of it is *"2/3 of the staking power must sign an EVM transaction"* with no user-side alternative.

---

## ApeX Protocol (ApeX Omni)

This venue accounts for most of round one's UNKNOWNs and most of this round's new evidence. Everything below is new.

### CORRECTS ROUND ONE

**1. The matching locus is documented — by zkLink, not by ApeX.** Round one concluded "UNKNOWN in primary sources, and that is itself the finding". Half of that survives: ApeX's own 435,823-byte corpus contains `matching engine` **0** times, `sequencer` **0** times, `on-chain matching` **0** times, and `LayerZero` **0** times (https://apex-pro.gitbook.io/apex-pro/llms-full.txt, 2026-08-04). But the primary statement exists one layer down:

> "Application Layer (Matching / DEX) → Protocol Layer (zkLink X Layer2) → Settlement Layer (Layer1 + ZK Proofs)"; applications "such as ApeX Omni, ZkEX and other DEXs… are responsible for: **Providing the trading interface, order placement, and matching**; Calling zkLink X APIs to execute trades on Layer2."
> — https://docs.zk.link/security/outline.md (2026-08-04)

> "The DApp (e.g., ApeX) is essentially a '**frontend interface**' and '**matching engine**' used to submit instructions (place orders, trade, etc.)."
> — https://docs.zk.link/security/outline/recovery.md (2026-08-04)

The settlement primitive is an `OrderMatching` L2 transaction carrying maker and taker orders plus a `submitterSignature`, whose `accountId` field is documented as *"Initiator's account id. **Only specific accounts can initiate this type of transaction on Layer3**"* (https://docs.zk.link/developer/api-and-sdk/transaction/order_matching.md, 2026-08-04). So: users sign orders, a privileged off-chain account pairs them, and the pairing is settled under proof. The proof attests that the two orders crossed — not that the maker was the highest-priority crossing order, which is precisely the distinction Lighter's whitepaper draws. zkLink's sequencing layer is described as *"a centralized sequencer model"* (https://docs.zk.link/architecture/sequencing-layer.md, 2026-08-04). The residue therefore changes from "the locus is undisclosed" to the sharper "**the venue does not disclose its own locus; its infrastructure provider does**" — a delegation of the disclosure obligation, which is a different unnameable thing and a better one.

**2. The data-availability configuration is not a committee, and the corpus's DAC guess was wrong for a second reason.** Round one dropped the corpus's DAC claim as inherited from the dead StarkEx product and replaced it with UNKNOWN. The answer is on-chain data:

> "**State differences are published on Arbitrum One.** The data needed to reconstruct the ApeX state is included in `commitBlocks` calldata on Arbitrum One. Secondary deployments additionally commit their local onchain operations and send synchronization hashes to the primary deployment."
> — https://l2beat.com/scaling/projects/apex-omni (2026-08-04)

Consistent with zkLink's own default: *"Both zkLink Nexus and zkLink Origin by default support the primary chain as the DA layer"*, with Celestia/EigenDA/Avail described as future validium options (https://docs.zk.link/architecture/da-layer.md, 2026-08-04). ApeX's corpus contains `Celestia` **0** and `EigenDA` **0**; its `DAC`/`validium`/`committee` hits are all in the retained ApeX **Pro** StarkEx section. Note the caveat, which is itself citable: L2BEAT rates ApeX Omni *"not even a Stage 0"* because *"There is no available node software that can reconstruct the state from L1 data, hence there is no way to verify that this system is a rollup."* The data is posted; its sufficiency is unverified — the exact predicate Lighter proves with two circuits and ApeX does not.

**3. Round one's own `Tg`/`Up` DROP was right for the wrong reason, and the fact is measurable.** Round one dropped both because "ApeX's documentation describes no timelock, no governance execution delay, and no upgrade authority". The documentation still describes none. The chain describes it exactly. ApeX's Force Withdrawal page embeds the full deployed contract ABI (https://apex-pro.gitbook.io/apex-pro/apex-omni/force-withdrawal.md, 2026-08-04) — 73 entries, including `activateExodusMode`, `performExodus`, `requestFullExit`, `setValidator`, `networkGovernor`, `getNoticePeriod` and `upgrade`. Reading the deployed contracts at the five addresses ApeX publishes:

| chain | contract | `exodusMode` | `getNoticePeriod` | `networkGovernor` | `totalBlocksCommitted` | `totalBlocksProven` | `totalBlocksSynchronized` |
|---|---|---|---|---|---|---|---|
| Ethereum | `0x35D173cdfE4d484BC5985fDa55FABad5892c7B82` | false | **0** | `0xf9f8794a…76b94` | 35,188 | **0** | 194,364 |
| BNB Chain | `0xb8d9f005654b7b127b34dae8f973ba729ca3a2d9` | false | **0** | `0xba3852ea…912ed` | 36,136 | **0** | 194,364 |
| Arbitrum One | `0x3169844a120c0f517b4eb4a750c08d8518c8466a` | false | **0** | `0xba3852ea…912ed` | 194,408 | **194,400** | 194,364 |
| Base | `0xee7981c4642de8d19aed11da3bac59277dfd59d7` | false | **0** | `0xba3852ea…912ed` | 23,336 | **0** | 194,364 |
| Mantle | `0x3c7c0ebfcd5786ef48df5ed127cddeb806db976c` | false | **0** | `0xba3852ea…912ed` | 6,283 | **0** | 194,364 |

(`eth_call` against public RPC endpoints, 2026-08-04/05; selectors derived from the ABI ApeX itself publishes.)

Three things follow. **(a)** The `networkGovernor` is a **4-of-6 Gnosis Safe** on every chain (`getThreshold()` = 4, `getOwners()` length = 6, code present). **(b)** The proxy's master is the UpgradeGatekeeper — `0xfbd68679…72753` on Ethereum, `0x2e8ad143…4a190` on Arbitrum — whose `mainContract()` matches the ApeX proxy, whose `getMaster()` is the same 4-of-6 Safe, and whose `upgradeStatus()` and `noticePeriodFinishTimestamp()` both read 0. Combined with `getNoticePeriod() == 0` on the target, **the upgrade path carries no delay**. L2BEAT states the consequence independently: *"There is no window for users to exit in case of an unwanted upgrade since contracts are instantly upgradable"* and *"Funds can be stolen if a contract receives a malicious code upgrade. There is no delay on code upgrades (CRITICAL)"* (https://l2beat.com/scaling/projects/apex-omni, 2026-08-04). This is the same control-plane fact round one identified as edgeX's headline risk — and it is equally true of ApeX, where round one recorded UNKNOWN.

**(c) The proof regime is not uniform across the chains that hold the money.** `totalBlocksProven` is **0** on Ethereum, BNB, Base and Mantle, and 194,400 on Arbitrum. Only the Arbitrum deployment verifies validity proofs; L2BEAT's discovery names it `apex-omni/ZkLink_main` and names the other four `apex-omni/ZkLink_LZEscrow` — *"A secondary cross-chain ZkLink rollup contract. It only escrows user deposits, and synchronizes deposit data with the main zkLink chain."* The synchronisation runs over LayerZero, and L2BEAT flags *"Funds can be lost if the 2/2 validator set or LayerZero bridge forges a non-existent deposit"* and *"ApeX's proof system does not authenticate deposits on external chains."* ApeX's documentation names LayerZero zero times. So for a user who deposits on Ethereum, the safety of the deposit does not rest on a proof verified where the money is; it rests on a 2-of-2 message.

**4. The exit-window deadline exists, is not published by anyone in human-readable form, and is a different number of days on every chain.** Round one: "No deadline or exit-window duration is documented — UNKNOWN, and materially so, since the deadline is the whole censorship-resistance argument." The mechanism is `requestFullExit` → a priority request with `expirationBlock = block.number + PRIORITY_EXPIRATION` (`ZkLink.sol` line 702, https://github.com/zkLinkProtocol/zklink-contracts/blob/main/contracts/ZkLink.sol, 2026-08-04) → anyone may then call `activateExodusMode()`, which sets `exodusMode = true` iff *"block.number >= priorityRequests[firstPriorityRequestId].expirationBlock"* (`ZkLinkPeriphery.sol` lines 22–30). The constant was recovered from a live `NewPriorityRequest` event on Base: submitted block 49,541,439, `expirationBlock` 52,133,439, delta **2,592,000 blocks exactly** — i.e. 30 days *only under zkLink's build assumption of one-second blocks* (`BLOCK_PERIOD: "1 seconds"`, https://github.com/zkLinkProtocol/zklink-contracts/blob/main/hardhat.base.config.js). Because it is a block *count*, the real deadline is:

| chain of deposit | measured block time | exit window |
|---|---|---|
| Ethereum | 12.03 s | **~361 days** |
| Arbitrum One (primary) | `block.number` returns L1 height → 12 s | **~360 days** |
| Base | 2.00 s | **~60 days** |
| Mantle | 2.00 s | **~60 days** |
| BNB Chain | 0.45 s | **~13.5 days** |

Exact on Base; consistent with 2,592,000 on the others, derived from open requests' `expirationBlock` minus current head. zkLink's prose offers only a non-normative *"for example, more than 3–5 days"* (https://docs.zk.link/security/outline/recovery.md, 2026-08-04), which matches no deployed value on any chain. **The censorship deadline is a coordinate on the chain you happened to deposit from**, varying by a factor of 27 across one account — and round one's residue about "an exit path with no stated deadline" should become "an exit path whose deadline is a function of an unrelated chain's block time".

**5. The escape hatch does not work on four of the five chains ApeX publishes it for.** This is the most consequential finding in the lane and I verified it twice, independently. `performExodus` requires the exit proof to verify: `bool proofCorrect = verifier.verifyExitProof(...); require(proofCorrect, "y2");` (`ZkLinkPeriphery.sol` lines 49–50). Reading `verifier()` off each live ApeX contract and calling `verifyExitProof` with a well-formed empty-proof calldata:

| chain | deployed `verifier()` | `verifyExitProof` |
|---|---|---|
| Ethereum | `0xe38f8bc093a1f76f0a444ba6b75f46d6dc686dba` | **returns false** |
| BNB Chain | `0x1202e0557a23531d09015c802e993d6423685ffb` | **returns false** |
| Base | `0x4c5629aea0b419d26c780dd78d5671e2ce27c563` | **returns false** |
| Mantle | `0x0c0f729c74c9ac41f9c702dad11011f40d4190b0` | **returns false** |
| Arbitrum One | `0x235118afb54b6d6c7b48f1b5434c25cd6eb6b68f` | reverts (a real PLONK verifier rejecting a malformed proof) |

The four are `EmptyVerifier`, whose published source is unconditional: *"/// @title An empty verifier, used to deploy to zkevm chain that does not support ecpair temporarily"* … `function verifyExitProof(bytes32, uint8, uint32, uint8, bytes32, uint16, uint16, uint128, uint256[] calldata) external override pure returns (bool) { return false; }` (https://github.com/zkLinkProtocol/zklink-contracts/blob/main/contracts/EmptyVerifier.sol, 2026-08-04). L2BEAT's discovery labels the same addresses *"Placeholder verifier for chains without pairing support. It rejects all block and exit proofs."*

Therefore: on Ethereum, BNB Chain, Base and Mantle — four of the five chains listed on ApeX's own Force Withdrawal page as the place to *"claim your funds on Layer 1"* — the last-resort Merkle-proof self-rescue reverts with `"y2"` and cannot be executed by anyone, ever, under the currently deployed code. L2BEAT reaches the same place from the other direction: *"Funds can be frozen if the centralized validator goes down. Users cannot produce blocks themselves and exiting the system requires new block production (CRITICAL)"*, with proposer failure recorded as *"Cannot withdraw"*.

Value currently behind that path, read at the same blocks: Ethereum **10,621,236.89 USDT + 2,573,803.04 USDC**; BNB Chain **2,923,181.40 USDT + 229,892.81 USDC**; Arbitrum One **3,970,374.12 USDC + 961,570.63 USDT**; Base **2,316,606.19 USDC**. L2BEAT reports TVS $26.14M. The great majority of it sits on chains whose exit verifier returns false.

**6. An auditor exists for the infrastructure and none for the venue.** Round one: "no auditor is named for ApeX Omni itself". Confirmed and now bounded. zkLink X carries **four ABDK reports**, all 2023 — v1.0 circuits (Feb 2023), v2.0 smart contract (Feb 2023), v4.0 circuits (Jul 2023), v6.0 circuits and contracts (Aug 2023) — listed at https://docs.zk.link/appendix/audits.md and mirrored at https://github.com/zkLinkProtocol/zklink-audit-report (folder `zkLink X/`) (2026-08-04). All four predate ApeX Omni's launch, and all four scope contracts and circuits only. **No audit covers a sequencer, an operator, or a matching engine** — which is the component zkLink's own documentation assigns to ApeX. ApeX's corpus contains `auditor` 0, `ABDK` 0, `Secure3` 0, `Certik` 0, `PeckShield` 0, `SlowMist` 0; github.com/ApeX-Protocol has no audits repository. Do not conflate the `zkLink Nova/` reports in the same repo (ABDK + Secure3, 2024): Nova is a different product from the zkLink X stack ApeX runs on.

### Funding — and ApeX is the exception

Settles **every hour on the hour UTC**. `Funding Rate (F) = P + clamp(I − P, +0.05%, −0.05%)`; `Funding Fee = Position Size × Index Price × F`; positive → longs pay shorts. And then:

> "ApeX Omni caps the hourly funding rate at ±0.05%. **Any amount beyond that band is absorbed by the platform - not passed on to users.**"

— https://apex-pro.gitbook.io/apex-pro/apex-omni/trading-and-funding-fees.md (2026-08-04).

**This is not a long/short transfer.** Under stress — exactly when the tether matters — the venue itself becomes a counterparty to the funding flow, paying the difference between the true premium and the capped rate out of its own balance sheet. `Pf` presumes a conserved transfer between position holders; here the transfer is conserved only inside a band, and outside it the protocol is a third leg. Round one recorded the cap and marked corpus flag 2 REFUTED for ApeX on the ground that `Pf` fits. It does not fit: the mechanism is a *capped* transfer with an *uncapped subsidy*, and nothing in the vocabulary composes "the venue is the residual counterparty to its own funding rate". No reserve, size, or funding source for that subsidy is documented anywhere in the corpus.

### Still UNKNOWN

- Whether ApeX itself, rather than zkLink, will state where its matching runs. It has not, in 435,823 bytes.
- The identity of the 4-of-6 Safe signers on either governor address.
- Whether ApeX or zkLink intends to replace the four `EmptyVerifier` deployments, and whether any user has ever attempted `performExodus` on them.
- The size and funding source of the balance sheet that absorbs out-of-band funding.

---

## Aster

### CORRECTS ROUND ONE

**1. Genesis is 2026-03-05, not 2026-03-16.** The RPC specification states block 1 genesis time `1772678119418` ms = **2026-03-05 02:35:19 UTC** (https://raw.githubusercontent.com/asterdex/api-docs/master/RPC/aster-chain-rpc.md, 2026-08-04). The 2026-03-16 date round one carried comes from the roadmap's citation of an X announcement, not from genesis. The 50 ms block claim verifies empirically: 13,201,753.6 s over 263,819,413 blocks = **50.041 ms** mean block time.

**2. AOS-1 and AOS-2 are being conflated, and the 20M figure is the wrong threshold for listing.** AOS-1 is *spot* listing (live 2026-06-25); **AOS-2 is perpetual listing and is labelled "Coming Soon"** in the docs body while the roadmap table dates it 2026-05-27 — the documentation is internally inconsistent. AOS-2 requires the *applicant* to *"Stake 1,000,000 $ASTER (locked for 4 years)"*. The 20M $ASTER figure is the *validator* eligibility threshold for voting, not the listing applicant's cost (https://docs.asterdex.com/aster-chain/governance.md, 2026-08-04).

**3. A public block explorer exists — round one implied none was found.** It is at **https://www.asterdex.com/en/explorer** (title "Aster Explorer", rendered 2026-08-04), and it is undocumented: it appears nowhere in `llms.txt`, has no dedicated subdomain, and the docs twice promise *"a dedicated blockchain explorer"* without giving the URL. Note that `asterscan.com` is a **domain-squatter sale page**, not an Aster property.

### Confirmed verbatim at the primary source

All three load-bearing sentences are present and unchanged at https://docs.asterdex.com/aster-chain/overview.md and in `llms-full.txt` (334,827 bytes, provenance-checked) (2026-08-04):

> "All order matching and trading logic are ultimately processed and stored **onchain**, aligning with the long-term goal of building a **fully decentralized derivatives infrastructure**."
> "The Clearinghouse is the core execution component of Aster Chain." / "Each perpetual market operates with an independent **order book**."
> "During Phase 1, external validator participation is not supported."
> "Core chain contracts and RPC infrastructure will not be open-sourced at the moment" — in order to "Protect proprietary matching engine algorithms".
> "Despite partial closed-source components, the ZK architecture ensures trust minimization and censorship resistance."

### The validator set: nine, named, closed — and it is not the set that holds the money

Round one could not establish the set size and inferred a small set from the bridge thresholds. Both halves of that inference were wrong in an interesting way. The live staking page (https://www.asterdex.com/en/staking, rendered 2026-08-04, epoch 2026/08/03–2026/08/10 UTC) shows **exactly nine validators** and **457,365,866.16 $ASTER** network stake, with no pagination:

Aster Validator 1 (56.47M) · Aster Validator 2 (53.52M) · WLFI (52.41M) · Pancake (51.94M) · Trust Wallet (51.79M) · Lista (51.38M) · BNB Chain (51.22M) · Binance Wallet (44.63M) · United Stables $U (44.02M). The nine sum to the stated network total. Block producers observed on the explorer match these addresses.

**The bridge signer set is a different, smaller object.** Verbatim: *"Cross-chain deposits are processed once **3 out of 4** validator nodes verify the transaction"* and *"A withdrawal is confirmed once **2 out of 3** validator nodes verify the request."* The consensus set is nine; the deposit quorum is 3-of-4 and the **withdrawal quorum is 2-of-3**. The docs never name these signers, never relate the 4-set and 3-set to the 9-set, and never explain why deposits and withdrawals have different denominators.

**Measured, 2026-08-04/05** — the stablecoins currently behind that 2-of-3, read via `balanceOf` on the deposit-bridge contracts round one lists:

| chain | bridge | USDT | USDC |
|---|---|---|---|
| BNB Chain | `0x128463A60784c4D3f46c23Af3f65Ed859Ba87974` | 121,652,779 | 2,689,071 |
| Ethereum | `0x604DD02d620633Ae427888d41bfd15e38483736E` | 79,560,540 | 13,635,228 |
| Arbitrum One | `0x9E36CB86a159d479cEd94Fa05036f235Ac40E1d5` | 24,392,846 | 22,419,653 |
| | | **$264,350,116 total** | |

**Concentration.** Aster operates validators 1 and 2 = 109.99M / 457.37M = **24.05% of stake, 2 of 9 by count**. The other seven are all BNB-ecosystem entities. Under the double-majority listing rule (>50% of stake *and* >50% of validators), stake is near-uniform (9.6%–12.3% each) so the **count** threshold binds first: any 5 of these 9 can pass any listing proposal. Aster plus three affiliates is 4 of 9.

### The admission rule is published and contradicted

> "### **Eligibility** — To become an active validator on Aster Chain and participate in Listing Vote: Stake a minimum of **20M $ASTER**; Maintain active validator status"
> FAQ: "**Q: How do I become a validator? A: Stake a minimum of 20M $ASTER and maintain active validator status.**"

— https://docs.asterdex.com/aster-chain/governance.md (2026-08-04)

That is the entire published rule, and it is not an entry path. It is flatly contradicted by *"During Phase 1, external validator participation is not supported"*; staking 20M today makes you a delegator to one of the nine. All nine already hold 44M–56M, more than double the stated minimum, so the threshold is not the binding constraint on membership either. There is no application procedure, no key-registration process, no hardware spec, and no admission vote anywhere in the docs. **Selection is discretionary and unpublished.** The term "Phase 2" does not occur in the documentation; the 2026 roadmap contains no validator-decentralisation item at all.

### The escape hatch: none — a confirmed negative over the complete corpus

Searched: the whole of `llms-full.txt` (334,827 bytes / 6,370 lines, which concatenates every docs page including bridge, withdrawal, staking, governance, FAQ, risk-disclosure and Terms), plus `aster-chain/overview.md`, `governance.md`, `staking.md`, `llms.txt` (the complete page index), and the api-docs RPC spec.

| term | hits |
|---|---|
| `escape` | **0** |
| `emergency` | **0** |
| `force withdraw` / `forced withdrawal` | **0** / **0** |
| `slash` / `misbehav` / `jail` / `downtime` / `liveness` | **0** each |
| `censorship` | 1 — the unsupported *"the ZK architecture ensures … censorship resistance"* claim |
| `halt` | 1 — *"Trading Halt and Settlement"*, the operator-run delisting procedure |

All 21 occurrences of "forced" are *forced liquidation*, a mechanism that operates against the user. There is no forced-inclusion path, no censorship deadline, no escape hatch and no unilateral withdrawal. Exit is a permissioned request cleared by 2 of 3 unnamed signers, and there is no L1 contract a user can call directly because the chain's contracts are not published. The Terms reserve the converse right: *"9.1 Suspension and Restriction: In the event of changes in laws or regulations, technical failures, data anomalies, or force majeure, we reserve the right to suspend or restrict the Services at any time without bearing liability for any resulting losses."* This is enforced in production — the rendered site showed a live banner, *"You're accessing ASTER from a restricted jurisdiction. Only withdrawals are available."*

**No slashing.** `slash`, `misbehav`, `jail`, `downtime`, `liveness` are all absent. The only penalty in the staking documentation punishes the *delegator*: `Penalty Amount = unlockAmount × max(N%, min(M%, lock_duration_left ÷ 4 years))`, up to 60% of principal for early exit (https://docs.asterdex.com/aster-chain/staking/early-exit-mechanism.md, 2026-08-04). A validator that censors, equivocates or produces invalid blocks loses nothing; the only consequence is reward dilution through `Validator Share = Validator Transactions ÷ Total Network Transactions`. The nine validators' stake is **not at risk from misbehaviour** — which makes "Proof of Staked Authority" accurate in a way the marketing does not intend.

### "Onchain" is currently unfalsifiable from outside

The RPC at `https://tapi.asterdex.com/info` exposes **exactly five methods, every one address-scoped**: `aster_getBalance`, `aster_openOrders`, `aster_userFills`, `aster_spotOpenOrders`, `aster_spotUserFills` (https://raw.githubusercontent.com/asterdex/api-docs/master/RPC/aster-chain-rpc.md, 2026-08-04). Live probes returned `-32601 Method not found` for `eth_blockNumber`, `aster_getBlock`, `aster_blockNumber`, `aster_getValidators`, `aster_orderBook`, `aster_l2Book`, `aster_getChainId`, `aster_meta`, `aster_allMids` (2026-08-04). There is no block retrieval, no state root, no proof endpoint, no validator query and **no order-book query** — for the one object the docs claim is on-chain. `blockTag` accepts only `"latest"`, so there is no historical state access either. Aster Chain has **no registered chain ID**: a search of `https://chainid.network/chains.json` (1,141,057 bytes, the registry behind chainlist.org, 2026-08-04) returns only the unrelated `aster Bank`, `asterbank.org`, `asterium.uz`. Running a node is impossible by stated policy. Everything an outsider can see is served by Aster's own web infrastructure.

So the claim *"All order matching and trading logic are ultimately processed and stored onchain"* is, at present, **not testable by any third party** — and it is the claim the paper is testing. That is a citable finding about the venue and a sharper one than "the node is closed source".

### Audits — the chain, the clearinghouse, the engine and the bridge are all uncovered

The audit page lists **exactly seven** reports: AsterVault (auditor not stated), AsterEarn (auditor not stated), asBNB (Salus), asBNB (PeckShield), USDF (PeckShield), USDF & asUSDF (HALBORN), asCAKE (Salus) (https://docs.asterdex.com/overview/audit-reports.md, 2026-08-04). Every one covers a collateral or vault token on BNB Chain. **None covers Aster Chain, its PoSA consensus, the Clearinghouse, the matching engine, the ZK/stealth-address privacy stack, or the cross-chain bridge** — despite the bridge holding $264.4M and the ZK stack being the sole cited basis for the censorship-resistance claim. Two of the seven do not name an auditor. All seven are opaque GitBook file blobs with no dates, versions or commit hashes.

### Funding — three venues, three different objects

**Aster Perpetuals (CLOB).** `F = [P + clamp(interest − P, 0.05%, −0.05%)] / (8/N)`, interest 0.01% (0% for BNBUSDT), premium index recomputed every 5 s, default 8-hour interval. Conserved, and stated so: *"**Aster does not charge or receive funding — it is a peer-to-peer transfer.**"* With an explicit discretion reservation: *"In the event of extreme market volatility, Aster reserves the right to adjust the funding rate floor, cap, and the funding interval for perpetual contracts."* (https://docs.asterdex.com/trading/perpetuals/fees-and-specs/funding-rate.md, 2026-08-04.)

**Shield Mode.** Not a premium-index transfer at all. The rate is computed from the **open-interest imbalance**: `Funding Rate = clamp{Floor, ABS[(Long OI − Short OI) × Funding Fee Per Hour / M%] / Max(LongOI, ShortOI), Cap}`, generated hourly, with *"The Funding Fee Rate Floor and cap threshold may be adjusted from time to time based on market performance."* The page says only *"Aster will collect a Funding fee rate to balance the Long and Short ratios"* and **never states who receives it** (https://docs.asterdex.com/trading/shield-mode/funding-fee-rate.md, 2026-08-04). Since the counterparty on Shield Mode is the ALP pool rather than another trader (https://docs.asterdex.com/earn/overview/aster-alp.md, 2026-08-04), this cannot be a long/short transfer between traders; it is an imbalance-indexed charge levied by the venue with an **undocumented recipient**. Round one marked corpus flag 2 REFUTED for Aster "on both venues" on the ground that Shield Mode "explicitly balances long/short open interest by transfer rather than charging a utilisation borrow fee". The formula is an imbalance charge, not a transfer, and the recipient is unstated — so the REFUTED verdict does not hold for Shield Mode.

**1001x.** The documentation corpus contains no 1001x funding page: `funding rate per block`, `borrow rate` and `Funding is calculated` return **0** hits in `llms-full.txt`. A rendered fetch of https://docs.asterdex.com/trading/1001x/fees-and-slippage.md reported a per-block funding charge (`contracts × price × funding rate per block`, accrued into unrealised PnL and affecting the liquidation price, driven by OI imbalance and a platform borrow rate), but that text is **not in the machine-readable corpus** and I could not corroborate it at a second source. **Recorded as UNKNOWN**, with the discrepancy itself noted: a venue offering 1001× leverage does not publish its holding cost in its own documentation corpus. Fees that *are* documented: 0.08% open and close at standard leverage; **no opening fee** at 500×/750×/1001× with a dynamic PnL-based closing fee floored at 0.03%; execution fee $0.50 on BNB Chain / $0.20 on Arbitrum.

---

## Lighter

### CORRECTS ROUND ONE

**The forceable set is narrower than round one states, and the correction matters because round one built a residue on it.** Round one, citing L2BEAT: "Forceable types per L2BEAT: deposits, withdrawals, **order creation, order cancellation**, and burning of pool shares — note that forcing an *order* is possible here"; and then the residue: "a censored trader can not merely exit but *trade*." Lighter's own documentation says otherwise:

> "To guarantee liveness and censorship resistance, Lighter Core introduces a **priority request queue** directly on Ethereum. Users can submit critical exit operations—such as **withdrawals, public pool exits, or reduce-only IOC orders**—on-chain, ensuring that the Sequencer must process them within a predefined timeframe."
>
> "If the Sequencer fails to process these priority requests in time, the system automatically triggers **Escape Hatch mode**. In this state, the Lighter Core smart contract freezes entirely. Users can then leverage Ethereum-posted data blobs to reconstruct their account state and generate succinct proofs of ownership (balances, positions, pool shares). These proofs allow users to withdraw the full value of their assets directly on Ethereum, with no reliance on off-chain coordination."

— https://docs.lighter.xyz/llms-full.txt (2026-08-04), *Escape Hatch*.

A **reduce-only IOC** is an exit instrument, not a trading right: it can only shrink an existing position and cannot rest. The forceable set is uniformly "get out", not "keep trading". Lighter's own framing — *"critical exit operations"* — is the accurate one. The residue should read: **the forceable set is closed under position reduction**, which is still stronger than every other venue in the lane (four of which have no forceable set at all) but is not the right to trade under censorship. This is the one place where round one's enthusiasm for Lighter over-claimed, and it should be corrected before the paper repeats it.

**A vocabulary note.** "Desert mode" is whitepaper vocabulary; `desert` appears **0** times in the 131,221-byte docs corpus, which calls the same mechanism **"Escape Hatch mode"**. The deployed contract exposes `desertMode()`, so all three names denote one object. Any citation should say which surface it is quoting.

### Measured

Read on Ethereum at block 25,686,150 (2026-08-05 03:50 UTC):

| contract | address | code | reading |
|---|---|---|---|
| ZKLighter | `0x3B4D794a66304F130a4Db8F2551B0070dfCf5ca7` | 1,367 B proxy | **496,566,117.00 USDC** held; `desertMode()` = **false**; `getMaster()` = the UpgradeGatekeeper |
| UpgradeGatekeeper | `0x94da8A995D0D82Ef0fE7E509C6D76c22603B6f67` | 4,116 B | `upgradeStatus()` = 0 (idle); `noticePeriodFinishTimestamp()` = 0; `getMaster()` = `0x97A90Ec9…C03a2` |
| Governance | `0xa464DA0B43f80EE3FfC4795cbbFC78472b5c81A1` | 1,367 B proxy | |
| ZkLighterVerifier | `0xac3Ce44B6ff4E402858C99D5699ff63131572BaA` | 1,367 B proxy | |
| DesertVerifier | `0x866418061d4C1168e1c8E8f6facE79675395E008` | **7,263 B** | a real verifier, not a placeholder |

The two multisigs round one lists, measured: `0x92b12c9d…32045` is **4-of-7**; `0x97A90Ec9…C03a2` — the gatekeeper's master, i.e. **the upgrade authority** — is **3-of-5**. No upgrade is pending.

The contrast with ApeX is exact and worth stating in those terms: both venues run a proxy behind an upgrade gatekeeper behind a multisig. Lighter's exit verifier is 7,263 bytes of deployed code and its exit path is live; ApeX's exit verifier on four of five chains returns `false` unconditionally. **The vocabulary emits the same `Up` for both.**

### Funding

Per-minute premium `premium_t = [max(0, ImpactBid_t − index_t) − max(0, index_t − ImpactAsk_t)] / index_t`, sampled at a random time each minute and time-weighted over 60 samples; `smallClampedPremium = premium + clamp(InterestRate − premium, ±0.05%)`; `fundingRate = clamp(smallClampedPremium, ±4%) / 8`; paid at each hour mark; per-account `funding = (−1) × position × index × fundingRate`. Conserved, and stated so: *"These payments are fully peer-to-peer with no fees taken by the exchange."* (https://docs.lighter.xyz/trading/funding.md, 2026-08-04.) Note that the payment notional uses the **index** price, as at Hyperliquid and edgeX, and unlike a mark-priced convention.

---

## edgeX

### CORRECTS ROUND ONE — the live custody stack is StarkEx, not the Arbitrum rollup

Round one: "the trading venue documented and served by the SDKs is the Arbitrum-stack V2 … Which contracts custody a *new* deposit today is UNKNOWN from public sources." It is not unknown; the live product publishes it in its own metadata, and the on-chain evidence is unambiguous.

**The live mainnet metadata still declares the StarkEx stack as the custody layer** (https://pro.edgex.exchange/api/v1/public/meta/getMetaData, HTTP 200, 773,677 bytes, `"appEnv":"mainnet"`, 2026-08-04): `starkExChainId` = `0x1` (Ethereum mainnet), `starkExContractAddress` = `0xfAaE2946e846133af314d1Df13684c89fA7d83DD`, `nativeChainId` = `3343`, `perpVaultAddress` = `0x48fc02c5bD34Af7086a5C70D4C59d18d10A557b5`, `spotVaultAddress` = `0x87E11A60e6FdDE29d86ce446aE06dDBc19D78E53`. Deposits enter through per-chain `MultiSigPoolV5WithPermit` contracts — Ethereum `0xC0a1a1e4AF873E9A37a0caC37F3aB81152432Cc5`, Arbitrum `0xceeED84620e5eb9ab1d6Dfc316867D2cdA332E41`, BNB `0x3EedB0d9C95263778a62081F2A62FC77a392116d`, Polygon `0xaD825544c91964A8d209F97fa360A7db718B77b8` — which are swept to near-zero (906.69 USDT, 0.95 USDT, 0.00 respectively, read 2026-08-04). Every risk tier in the live metadata still carries StarkEx-specific fields (`starkExRisk`, `starkExUpperBound`) and the collateral asset is a StarkEx asset ID.

**The StarkEx contract is live, not a husk.** Etherscan (via scrapling, 2026-08-04): 129,610 transactions; most recent `Update State` at **block 25,685,881, 2026-08-05 02:56:35 UTC**, 46 minutes before access; state updates arrive in pairs every ~1–2 h from EOA `0xCBe6fbf5e3c427013688E04D0fDE56705890c4bE`; a `Withdraw` at block 25,685,054 (2026-08-05 00:11:11 UTC). L2BEAT records average proof-submission interval 1 hour, average state-update interval 41 minutes, 100% uptime, no anomalies 2026-07-06 → 2026-08-05.

**It holds the money, and it is draining.** `balanceOf(USDT)` on `0xfAaE…83DD`, read against an archive endpoint:

| block | date | USDT held |
|---|---|---|
| 23,386,150 | 2025-09-17 | 68,889,125 |
| 23,786,150 | 2025-11-12 | 302,830,540 |
| 24,186,150 | 2026-01-07 | 144,037,842 |
| 24,486,150 | 2026-02-18 | 142,481,751 |
| 24,786,150 | 2026-04-01 | 124,963,901 |
| 24,986,150 | 2026-04-29 | 119,605,493 |
| 25,186,150 | 2026-05-27 | 118,612,807 |
| 25,386,150 | 2026-06-24 | 88,862,124 |
| 25,536,150 | 2026-07-15 | 86,354,176 |
| 25,636,150 | 2026-07-29 | 75,459,152 |
| 25,686,150 | 2026-08-05 | **69,241,423** |

Matching L2BEAT's TVS of $69,193,416 with `change7d` = −8.19%.

**EDGE Chain exists and is nearly empty.** Chain ID **3343** (`eth_chainId` → `0xd0f`), public RPC `https://edge-mainnet.g.alchemy.com/public`, explorer `https://pro.edgex.exchange/en-US/explorer`. **Genesis block 1 at 2025-10-26T20:45:38Z** — four and a half months *before* Arbitrum's 2026-03-10 announcement. Head at access: block 781,947 (2026-08-05T03:41:00Z). L2BEAT lists it as `{"id":"edgechain","name":"Edge Chain","type":"layer3","hostChain":"Arbitrum One","providers":["Arbitrum"],"purposes":["Exchange"],"stage":"Stage 0"}` with **TVS $58,529.29** and `change7d` **−98.18%**. Sampled blocks contain exactly two transactions each, one of which is the ArbOS internal system transaction; block intervals run 1–17 minutes and `gasUsed` is frequently 0. Arbitrum Nitro confirmed independently (ArbSys precompile at `0x…0064`, `arbOSVersion()` → `0x6a`, Nitro-only `sendRoot`/`sendCount`/`l1BlockNumber` header fields).

**The ratio is ~1,183 : 1.** $69.19M on the StarkEx validium against $58.5K on the chain the documentation presents as current. Round one's careful hedge — "the StarkEx validium contracts are live and hold funds; the trading venue documented and served by the SDKs is the Arbitrum-stack V2" — reads the situation backwards on the point that matters: the documented stack is the empty one.

### CORRECTS ROUND ONE — the proof regime of the current stack is *worse* than V1's

Round one: "the documentation never states whether V2 has validity proofs, fault proofs, or neither, which is the single most consequential unstated fact about the venue." The documentation still states neither — in the provenance-verified 514,932-byte corpus, `fraud proof` **0**, `validity proof` **0**, `anytrust` **0**, `orbit` **0** (https://edgex-1.gitbook.io/edgeX-documentation/llms-full.txt, 2026-08-04) — and the Arbitrum blog post names no proof system either (https://blog.arbitrum.io/edgex-announces-edge-chain-on-arbitrum/, 2026-03-10, accessed 2026-08-04). L2BEAT states it:

- **State validation: "Fraud proofs (INT)"** — interactive, **whitelisted validators only**, sentiment `bad`.
- **Data availability: "External (DAC)", threshold 2/5**, with *"the committee does not meet basic security standards"*.
- Stage 0; **Exit window: None**; *"Funds can be stolen if a contract receives a malicious code upgrade. There is no delay on code upgrades."*

— https://l2beat.com/scaling/projects/edgex and the EDGE Chain entry (2026-08-04).

So the migration edgeX describes as an advance replaces **STARK validity proofs verified on Ethereum** with **interactive fraud proofs adjudicated by a permissioned validator set**, and replaces a **2-of-6** DA committee with a **2-of-5** one. Both committees are named "DAC" and they are different committees — easy to conflate, and worth stating separately in the paper. This is the first case in the lane of a venue whose trust model got weaker while its product, account model and API stayed identical, which sharpens round one's "migration as a first-class event" residue into something with a direction: **the vocabulary cannot record that a venue's guarantee was downgraded.**

### CORRECTS ROUND ONE — the loss-absorption layer is not absent, it is undocumented-but-observable

Round one: "Searching edgeX's entire 414 KB documentation corpus returns **no occurrence of 'insurance fund,' no auto-deleveraging, no bankruptcy price, no socialised loss, and no liquidation-fee schedule.**" Against the provenance-verified 514,932-byte corpus, three of those five are wrong:

| term | round one | verified count | what it is |
|---|---|---|---|
| `insurance fund` | absent | **0** — correct | — |
| socialised loss / clawback | absent | **0** — correct | — |
| `auto-deleveraging` | absent | **2** — **wrong** | the phrase glosses the API field `isDeleverage`, *"Is Auto-Deleveraging"*, which itself occurs **9** times |
| `bankruptcy price` | absent | **1** as the phrase, **2** as `bankruptPrice` — **wrong** | API field `bankruptPrice`, live values e.g. `"81943.1"` |
| liquidation-fee schedule | absent | **22** occurrences of `liquidateFee` — **wrong** | `liquidateFeeRate`, `liquidateFee`, `cumLiquidateFee` |

And the schedule is published as live data: across all **292** contracts, `liquidateFeeRate` takes exactly two values — **0.01 (1%)** for BTCUSD/ETHUSD/SOLUSD and most pairs, and **0.0001**. BTCUSD carries 10 risk tiers with maintenance margin from 0.5% upward.

Meanwhile the entire prose page on liquidation remains two sentences: *"edgeX employs Oracle Price to prevent liquidations triggered by low liquidity or market manipulation. In cross margin mode, a position is liquidated when the available balance reaches zero and the position margin drops to the maintenance margin level."*

The nearest thing to a backstop is the **eLP vault** under eStrategy: *"Depositors assume a share of the AMM's positions, effectively acting as counterparties to other edgeX traders… The revenue of edgeX eLP is derived from passive market-making profits, **liquidation fees**, and a portion of the platform's trading fees."* So eLP depositors take the counterparty side and are paid the liquidation fees — the same *rent-first-loss-capital-with-a-fee-stream* shape as ApeX's Insurance Vault and Aster's ALP, and again with no statement that it absorbs bankruptcy losses.

**The corrected residue is stronger than round one's.** It is not "the loss-absorption layer is undocumented". It is: **the mechanism demonstrably exists and executes — the venue returns per-fill `isLiquidate`, `isDeleverage`, `bankruptPrice` and `liquidateFee` values to its own users — and no document anywhere states the rule under which it fires or who bears the residual.** A vocabulary that has symbols for each candidate answer (`Bs`, `Sl`, `Ad`) cannot record "the mechanism is observable in its outputs and unstated in its policy", which is a different epistemic status from either presence or absence.

### Audits — scope named, and one live contract outside it

Round one marked scopes and dates UNKNOWN. From the PDFs themselves (2026-08-04):

- **RigSec** — report dated **2 September 2024**, assessment 13–20 August 2024, 3 consultants. Scope: **only the three MultiSigPool addresses** (Ethereum `0xC0a1a1e4…`, BSC `0x0520b0A9…`, Arbitrum `0xceeED84…`). Contains finding "(RS-04) Deprecate testnet used in the contract." — https://static.edgex.exchange/audit-reports/rigsec-edgex-audit-report.pdf
- **SlowMist** — application received **2025-06-16**. Scope: StarkPerpetual proxy `0xfAaE…83DD` (implementation `0x8c43c9bec15d82d153c52518030e0a9590abd35d`) plus the same three MultiSigPools. — https://static.edgex.exchange/audit-reports/edgeX-SlowMist-Audit-Report.pdf

Neither covers EDGE Chain, the Arbitrum Orbit deployment, or the matching engine (`orbit` and `rollup` appear zero times in both). Both are silent on loss absorption: `deleverag`, `bankrupt`, `socialis` and even `liquidat` are absent from both. **And the BNB deposit contract audited (`0x0520b0A951658Db92b8A2dd9F146bB8223638740`) is not the one the live product uses (`0x3EedB0d9C95263778a62081F2A62FC77a392116d`).** Both have identical bytecode length (12,752 B), so it is a redeployment of audited code — but the live address was never itself in scope, and the **Polygon pool appears in no audit at all.**

### Funding

`Funding Fees = Position Value × **Index Price** × Funding Rate`; `F = P + clamp(I − P, 0.05%, −0.05%)` with `P = [max(0, ImpactBid − Index) − max(0, Index − ImpactAsk)] / Index`; *"Funding fees are exchanged every hour between holders of long and short positions"*, longs pay shorts when positive (https://edgex-1.gitbook.io/edgeX-documentation/trading/funding-fees.md, 2026-08-04). **Whether edgeX retains any share is UNKNOWN** — unlike Hyperliquid, Lighter and Aster's CLOB, all of which state peer-to-peer conservation explicitly, edgeX's page makes no such statement, and no other page in the corpus does either. Note that funding is driven by the **Index Price** while margin and liquidation are driven by the **Oracle Price** from Stork: two different price authorities inside one position, which round one records and which no element separates.

### One anomaly I could not resolve

L2BEAT reports **0 user operations in the past day** (past-day UOPS 0.00, Max UOPS 8.46 on 2025-11-25) for the StarkEx instance, while the same contract is provably posting state updates every ~41 minutes at 100% uptime. Either the state updates carry no user trades, or L2BEAT's StarkEx activity feed has diverged from the chain. Round one read the 0.00 UOPS figure as evidence that "trading has moved off it while collateral remains"; given the balance drawdown, the live metadata, and the 41-minute cadence, that reading is not safe. **Recorded as unresolved.**

---

## THE FIVE TRUST MODELS, SIDE BY SIDE

The four questions are: **who may censor an order**, **who may halt withdrawals**, **what a user can do unilaterally if the operator disappears**, and **whether the answer is enforced by code, by a proof, or by a promise**. No venue's documentation answers all four; three of the five answer none of them. The vocabulary has no symbol for any of the four.

| | **Who may censor an order** | **Who may halt withdrawals** | **Unilateral user recourse if the operator disappears** | **Enforced by** |
|---|---|---|---|---|
| **Hyperliquid** | The HyperBFT validator set as block proposer. Bounded, uniquely in the lane, by a consensus-layer ordering rule (no-order actions, then cancels, then GTC/IOC). Validators may additionally **vote to delist a market and settle every position at a 1-hour TWAP** they select the reference for. | ≥1/3 of staking power, by withholding signatures: a withdrawal needs 2/3 to sign the Arbitrum bridge transaction. The bridge can also be **locked** during the dispute period, and unlocking requires cold-wallet signatures from 2/3 of the stake-weighted set. | **Nothing.** `escape hatch`, `forced withdrawal`, `censorship`, `emergency`, `pause` = 0 hits in a 493,845-byte corpus. Exit requires the validator set to sign. $420.6M sits behind that. | **Promise** — a 2/3-honest BFT assumption over a validator set running an unpublished binary. No validity proof, no fraud proof, and *"no automatic slashing"* for consensus faults. |
| **ApeX Omni** | The off-chain matching engine ApeX operates. `OrderMatching` may be submitted only by privileged accounts; zkLink's sequencing is *"a centralized sequencer model"*. L2BEAT: *"Users can be censored if the operator refuses to include their transactions"* and the operator *"frontruns user transactions"*. | The sole block proposer, by stopping. Also the **4-of-6 Safe**, which can upgrade the custody contract with **zero notice** (`getNoticePeriod()` = 0, gatekeeper `noticePeriodFinishTimestamp()` = 0). | `requestFullExit` → wait `PRIORITY_EXPIRATION` = **2,592,000 blocks** (~13.5 d on BNB … ~361 d on Ethereum) → `activateExodusMode()` → `performExodus`. **On Ethereum, BNB, Base and Mantle the last step always reverts**, because the deployed `verifyExitProof` returns `false` unconditionally. Functional on Arbitrum only. | **A proof, on one chain out of five.** `totalBlocksProven` = 194,400 on Arbitrum and **0** on the other four, which execute blocks on a LayerZero sync message. For an Ethereum depositor the guarantee is a **promise** carried by a 2-of-2 bridge. |
| **Aster** | The 9 closed, named PoSA validators — Aster's own two plus seven BNB-ecosystem partners — running a closed-source node by stated policy, on a chain with no public block RPC. | An unnamed bridge signer set: **2 of 3** signatures confirm a withdrawal (3 of 4 for deposits). Neither set is the 9-validator consensus set. **$264.4M** sits behind the 2-of-3. The Terms reserve the right to *"suspend or restrict the Services at any time without bearing liability"*, already exercised by jurisdiction. | **Nothing.** `escape`, `emergency`, `force withdraw`, `forced withdrawal` = 0 hits across the complete 334,827-byte corpus. No forced inclusion, no deadline, no L1 contract to call — the contracts are unpublished. | **Promise**, and an unusually thin one: no validity proof, no fraud proof, **no slashing** (`slash`, `jail`, `downtime`, `liveness` = 0 hits), and no third-party way to check the chain — the RPC exposes 5 address-scoped read methods, no chain ID is registered, and no audit covers the chain, the engine or the bridge. |
| **Lighter** | The sequencer, whose *only* power is ordering: *"all valid state transitions can be deterministically inferred from the transaction order and oracle data."* It cannot choose *which* resting order fills — price–time priority is proven in-circuit as `crossingSize = 0` on the highest-priority crossing leaf. | The sequencer, by refusing priority requests — for at most the deadline. Beyond that, the **3-of-5 multisig** behind the UpgradeGatekeeper, whose 21-day delay a security council may reduce to zero. | **A real, funded escape hatch.** Force withdrawals, public-pool exits and **reduce-only IOC orders** through an Ethereum priority queue; on deadline expiry anyone triggers Escape Hatch mode, the contract freezes, and users withdraw against the frozen root using **Ethereum blob data alone**. `DesertVerifier` is 7,263 bytes of live code; `desertMode()` = false. $496.6M behind it. | **A proof, for the matching rule and for DA sufficiency** — the only venue in the lane where both are proven, with the deployed verifier regenerable from published circuits. **But the price input is a promise**: L2BEAT records *"External signatures are currently not verified and the sequencer must be trusted to truthfully report data."* |
| **edgeX** | The operator's Go matching engine — sole block proposer on the StarkEx instance; the Cairo program that executed V1 state transitions is marked *"Code unknown"*. The API exposes an operator-side rejection status (`FAILED_CENSOR_FAILURE`, `L2_REJECT`), i.e. censorship is a documented return value. | The operator, and — decisively — **an EOA**: *"Critical contracts can be upgraded by an EOA which could result in the loss of all funds"*, *"There is no delay on code upgrades"*, exit window **None**. | **On the StarkEx instance**, StarkEx's own hatch: force a request through L1; after **7 days** anyone may freeze and withdraw by Merkle proof — but a forced *trade* requires finding a counterparty out of band. **On EDGE Chain**, the docs assert *"trustless, permissionless withdrawals at any time"* and specify no mechanism, deadline or contract. | **Split, and downgrading.** The $69.2M is behind **STARK validity proofs** with a **2-of-6** anonymous, unslashed DA committee. The $58.5K is behind **interactive fraud proofs with whitelisted validators** and a **2-of-5** DA committee that *"does not meet basic security standards"*. Above both sits an **EOA with no delay** — so the binding constraint is a promise regardless of the proof. |

**What the table shows that no single venue's documentation can.** Five venues emit the same six elements. On the first question they differ by whether the censor is a validator set, a named operator, a nine-member cartel, or an ordering-only sequencer that cannot choose fills. On the second they differ by whether halting takes 1/3 of a stake-weighted set, two signatures out of three, four signatures out of six, three out of five, or one EOA. On the third, two venues have a working unilateral exit, one has an exit that reverts on four of the five chains it is advertised for, and two have none at all. On the fourth, exactly one venue proves the thing that actually decides trades, and even it trusts its own price feed. **The spread on question two alone runs from a 2-of-3 to a Byzantine supermajority, and the vocabulary emits `Ob` for all five.**

---

## THE FUNDING MECHANISM, SIDE BY SIDE

| venue | interval | rate | notional priced at | who pays whom | conserved? |
|---|---|---|---|---|---|
| **Hyperliquid** | hourly (1/8 of the 8h rate), 4%/h cap | `P + clamp(interest − P, ±0.05%)` | **spot oracle price**, explicitly not mark | long ↔ short | **Yes** — *"purely peer-to-peer and no fees are collected on the payments"* |
| **ApeX Omni** | hourly on the hour UTC | `P + clamp(I − P, ±0.05%)`, hourly rate capped at ±0.05% | index price | long ↔ short **inside the band**; **the platform outside it** | **No** — *"Any amount beyond that band is absorbed by the platform - not passed on to users."* The venue is the residual counterparty to its own funding rate, with no documented reserve. |
| **Aster** — Perpetuals | 8h default (`/(8/N)`), interest 0.01% (0% BNBUSDT) | `[P + clamp(interest − P, ±0.05%)]/(8/N)` | index price | long ↔ short | **Yes** — *"Aster does not charge or receive funding — it is a peer-to-peer transfer."* Floor, cap and interval adjustable at Aster's discretion under volatility. |
| **Aster** — Shield Mode | hourly | `clamp{Floor, ABS[(LongOI − ShortOI) × FeePerHour/M%] / Max(LongOI, ShortOI), Cap}` | — | **recipient not stated**; the counterparty on this venue is the ALP pool, not another trader | **No / UNKNOWN** — an open-interest-imbalance charge, not a premium transfer. Floor and cap *"may be adjusted from time to time"*. |
| **Aster** — 1001x | UNKNOWN | UNKNOWN | — | UNKNOWN | **UNKNOWN** — no funding page in the 334,827-byte corpus; `funding rate per block`, `borrow rate` = 0 hits. A 1001× venue that does not publish its holding cost. |
| **Lighter** | hourly, from 60 per-minute samples time-weighted | `clamp(premium + clamp(interest − premium, ±0.05%), ±4%)/8` | index price | long ↔ short | **Yes** — *"fully peer-to-peer with no fees taken by the exchange"* |
| **edgeX** | hourly | `P + clamp(I − P, ±0.05%)` | **Index Price** (while margin and liquidation use the **Oracle Price** from Stork) | long ↔ short | **UNKNOWN** — no conservation statement on the funding page or anywhere in the 514,932-byte corpus |

Round one marked the corpus's "perp tether" flag **REFUTED for all five** on the ground that `Pf` fits everywhere. It fits at Hyperliquid, at Lighter and on Aster's CLOB, where conservation is stated in terms. It does not fit at ApeX, where the venue absorbs the tail; it does not fit on Aster's Shield Mode, which is an imbalance charge with an unstated recipient; and it is unestablished at edgeX and on Aster's 1001x. **The flag is refuted for three of seven venue-products, not for five of five.**

---

## WHAT REMAINS UNKNOWN, AND WHERE I LOOKED

- **ApeX**: the signers behind either 4-of-6 Safe; whether the four `EmptyVerifier` deployments are intended to be replaced; the size and funding source of the balance sheet absorbing out-of-band funding. ApeX's own statement of its matching locus does not exist — searched `llms-full.txt` (435,823 B), the litepaper, both zkLink blog posts, and every SDK README.
- **Aster**: the identity of the bridge signers and their relation to the nine validators; any Phase-2 date (the term does not occur in the docs); the 1001x funding mechanism; whether any incident or halt has occurred since genesis — no status page, no post-mortems, and `incident`, `outage`, `post-mortem`, `exploit`, `chain halt` return no relevant hits. The announcement feed at `https://www.asterdex.com/en/announcement` returns **403**.
- **edgeX**: whether the venue retains any share of funding; the rule under which ADL fires and who bears the residual; the reconciliation of L2BEAT's 0.00 past-day UOPS against a contract posting state every 41 minutes; whether edgeX has stated anything about loss absorption outside its docs — the session's WebSearch budget (200/200) was exhausted before its blog and X could be checked.
- **Hyperliquid**: nothing new was opened. The four absences (escape hatch, forced withdrawal, pause, emergency) are confirmed negatives over a provenance-checked corpus, not gaps in the search.
- **Lighter**: the zkSecurity full report at `https://reports.zksecurity.xyz/report-zklighter` remains unretrieved, so the audited commit, findings and severities are still UNKNOWN — carried forward unchanged from round one.

**Dead ends worth recording**, since a negative result is part of the deliverable: `l2beat.com/scaling/projects/{apex, apexpro, zklink, zklink-x, zk-link}` all 404 (the live slugs are `apex-omni`, `apex-pro`, `edgex`, `lighter`); `scan.asterdex.com`, `chain.asterdex.com`, `rpc.asterdex.com` are NXDOMAIN and `explorer.asterdex.com` is 404, so Aster's only explorer is the undocumented in-app one; `asterscan.com` is a domain squatter and must not be cited as an Aster property; `rpc.edgex.exchange` returns `404 Route Not Found` (the live EDGE Chain RPC is `edge-mainnet.g.alchemy.com/public`); `eth.llamarpc.com` returned 521 throughout and `rpc.ankr.com/eth` now requires a key, so archive reads used `eth.drpc.org`.

**One correction to my own work, recorded rather than hidden.** An `eth_getLogs` sweep I ran for USDT transfers in and out of edgeX's StarkPerpetual over 81,000 blocks reported none, which would have been evidence of dormancy. It was wrong: the loop swallowed RPC range errors and reported them as empty results, and the archived balance series proves the balance moved inside that window. The dormancy claim was discarded and the balance trajectory used instead. Any absence claim in this document that rests on a search rests on a corpus whose provenance I verified and whose byte count I state.
