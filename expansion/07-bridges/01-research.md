# Stage 1 research — Bridges / cross-domain (top five)

**Category:** `07-bridges` · **texLabel:** `sec:cat:bridge` · **Lane:** Stage-1 research only.
**All access dates in this file are 2026-08-04** unless stated otherwise. No decomposition, no
construction, no repo/paper edits — those are later stages.

**Note on source quality for this category.** This is the worst-sourced category in the atlas and
the reason is structural: three of the five top applications are *companies holding an asset*, so
there is no protocol specification to read, no whitepaper that binds anyone, and the only
machine-checkable facts are (a) the token contract, (b) the admin role addresses, and (c) whatever
reserve list the issuer chooses to publish. Marketing pages are abundant and worthless; docs sites
are thin; two of the five have no meaningful repository at all (BTCB has none; Hyperliquid's is two
Solidity files with no README and no licence). I therefore treated **on-chain state as the primary
source wherever a claim could be reduced to a call**, and every such reading in this file was made
directly against a public RPC (`ethereum-rpc.publicnode.com`, `bsc-rpc.publicnode.com`,
`arbitrum-one-rpc.publicnode.com`) on 2026-08-04; those readings are labelled `[on-chain]` and are
reproducible. Where only an issuer's own web page exists, it is cited as the issuer's *claim*, not
as a fact. `coinbase.com`, `help.coinbase.com`, `binance.com`, `etherscan.io` and `arbiscan.io` all
refuse plain fetchers and were retrieved via the `scrapling` StealthyFetcher; `bscscan.com` and the
GitHub raw/API endpoints did not. Two items are marked **UNKNOWN** rather than guessed: whether
Binance publishes any BTCB-specific reserve *attestation* (as opposed to a self-published address
listing), and whether the deployed Hyperliquid `Bridge2` bytecode is byte-identical to the
repository HEAD. One live event landed *on the access date itself* — BitGo announcing a move of
WBTC cross-chain operations from LayerZero to Chainlink CCIP — and is reported with its press-only
provenance flagged, because I could not reach a first-party BitGo or Chainlink page for it.

---

## WBTC

### 1. WHAT IT DOES

A holder gives up native bitcoin on the Bitcoin chain by sending it to a deposit address controlled
by the WBTC custodian, and receives WBTC — an 8-decimal ERC-20 — on Ethereum (or one of six other
chains). The transfer is not initiated by the holder directly: a *merchant*, one of a permissioned
set of firms registered on-chain, performs KYC/AML on the requester, submits an on-chain mint
request naming the BTC txid and the custodian deposit address, and the custodian confirms it
on-chain after six Bitcoin confirmations, at which point WBTC is minted to the merchant, who
delivers it to the user. Redemption runs the same path in reverse: a merchant approves the Factory
for its WBTC, calls `burn()` on the Factory, the custodian waits 25 Ethereum confirmations, and
sends BTC to that merchant's registered BTC address. **The redemption right is a merchant's, not a
holder's** — an ordinary WBTC holder has no contract-enforced way to obtain BTC and exits by selling
into a secondary market. What must be trusted for one WBTC to remain worth one BTC is entirely
off-chain and legal: that the custodian (BitGo, transitioning to BiT Global) actually holds the
bitcoin, that the bitcoin is unencumbered, that the custodian will keep honouring merchant
redemptions, and that the three multisigs that own the Controller and Members contracts do not
change the mint authority. There is no cryptographic link of any kind between the Bitcoin chain and
the Ethereum chain; the custodian's confirmation transaction *is* the bridge.

### 2. DESIGN

**Supply topology — custodial wrap.** Not lock-and-mint escrow: nothing is locked in a contract.
The "escrow" is a set of 20 Bitcoin addresses held by a legal custodian and published by the issuer.
The on-chain artefact is a mint, not a claim on a contract balance.

**Verification model — none. Single-company attestation.** There is no message, no proof, no light
client, no verifier set, no threshold. `Factory.confirmMintRequest()` is gated by
`onlyCustodian`, which resolves through `Controller.isCustodian()` to the single custodian address
`0xb0f42d187145911c2ad1755831aded125619bd27` `[on-chain: Members.custodian()]`. The custodian is
trusted to have observed the Bitcoin transaction; nothing on Ethereum checks it. Bitcoin cannot
execute verification code, so no other design is available on this pair.

**Mint / burn authority.** `WBTC.owner() = 0xca06411bd7a7296d7dbdd0050dfc846e95febeb7` (the
Controller) `[on-chain]`. `Controller.mint()` is callable only by the Factory
(`Controller.factory() = 0xe5a5f138005e19a3e6d0fe68b039397eeef2322b`, and
`Factory.owner() = Controller`) `[on-chain]`. Merchants may request; only the custodian may confirm.
There are **47 merchants** registered on-chain today (`Members.getMerchants()` returns 47 addresses)
`[on-chain]`.

**Attestation / proof-of-reserve regime.** A live on-chain proof-of-reserve dashboard at
`wbtc.network/transparency`, reporting 116,499.20 WBTC circulating against 116,514.34 BTC across 20
listed custodian addresses, plus a mint/burn ledger. DefiLlama's TVL for WBTC is literally the sum
of the balances of those published addresses — its adapter comment reads
`// WALLETS FROM HERE https://wbtc.network/dashboard/audit`. On-chain Ethereum supply is
**116,132.18273272 WBTC** `[on-chain: totalSupply/1e8]`, consistent with the dashboard's per-chain
split. This is a real-time address listing, not a periodic auditor's attestation with recourse.

**Freeze / blacklist powers — none.** The token is `PausableToken`, so the Controller's owner can
`pause()`/`unpause()` all transfers; `paused()` is currently `false` `[on-chain]`. There is **no
blacklist and no forced transfer**: `blacklister()` and `isBlacklisted(address)` both revert
`[on-chain]`, and the contract source inherits only
`StandardToken, DetailedERC20, MintableToken, BurnableToken, PausableToken, OwnableContract`.

**Control plane — three plain multisigs, no timelock, no proxy.**
The token is a non-upgradeable Solidity 0.4.24 contract; `renounceOwnership()` is deliberately
reverted. Ownership as of the access date `[all on-chain]`:

| contract | owner | quorum |
|---|---|---|
| WBTC token `0x2260fac5…c2c599` | Controller `0xca06411b…febeb7` | — |
| Factory `0xe5a5f138…f2322b` | Controller | — |
| Controller `0xca06411b…febeb7` | `0x972eed35781f09987a5c40f761f6a24623c570de` | **6 of 10** |
| Members `0x3e864057…107ac5` | `0x4dbbbfb0e68be9d8f5a377a4654604a62e851e80` | **5 of 9** |
| ("WBTC DAO" per repo) `0xB33f8879…8A37c5` | — | 8 of 13, **owns neither** |

All three are the classic Consensys `MultiSigWallet` (`MAX_OWNER_COUNT() = 50`); on all three,
`secondsTimeLocked()`, `delay()` and `getMinDelay()` are absent, i.e. **execution is immediate on
quorum — there is no timelock anywhere in the WBTC control plane** `[on-chain]`. `Controller` also
exposes `setFactory()` and `setMembers()`, so the 6-of-10 can swap the mint-authorising contract and
the merchant/custodian registry without touching the token.

**Custody.** BitGo multi-sig cold storage, migrating to a multi-jurisdictional structure: BiT Global
holds the user key and the backup key (Hong Kong and Singapore), BitGo retains one of the three
keys through its US entity; announced 2026-03-01 with completion expected 2026-05-01. Minting and
redemption continue on BitGo infrastructure.

**Live change on the access date (press-only provenance).** On 2026-08-04, BitGo was reported to
have selected Chainlink CCIP and the Cross-Chain Token standard as its exclusive cross-chain
provider for WBTC (~$7.3–7.7b), replacing LayerZero, and for all future BitGo-issued assets. I could
not reach a first-party BitGo or Chainlink page for this; treat as **press-confirmed, not
issuer-confirmed**. If true it materially changes the multi-chain leg of WBTC's design.

### 3. REPO

- **Contracts:** `https://github.com/WrappedBTC/bitcoin-token-smart-contracts` — **MIT**, Solidity
  (GitHub reports the repo language as JavaScript because of the Truffle harness). Default branch
  `master`, HEAD **`41dc747a4649b524b583e93f734351a331e766d4`** (2023-12-27).
  Top level `[gh api]`: `.gitignore, LICENSE, README.md, base/, docs/, ethereum/,
  evm-base-contracts/, kava/, tron/, wbtc_coverage_f8ea168.zip`.
  `ethereum/contracts/{controller,factory,mock,token,utils}` plus `Migrations.sol`.
  **Repo defect:** `ethereum/README.md` states these contracts are "NOT deployed" and directs the
  reader to `ethereumV2/README.md` for the deployed set — **`ethereumV2/` does not exist in the
  repository**. The deployed Ethereum contracts therefore have no in-repo canonical directory.
- **Governance:** `https://github.com/WrappedBTC/DAO` — MIT, HEAD `c843f51d70a898dfd720f3316921f0bf903333ab`
  (2023-02-01). Carries the address book, `MerchantGuide.md` and `DeploymentVerification.md`.
  **Stale against chain:** it lists 24 merchants (on-chain: 47) and names `0xB33f8879…8A37c5` as
  "the WBTC DAO" multisig, but that multisig owns neither the Controller nor the Members contract
  today; `DeploymentVerification.md` still instructs readers to check that both are owned by "the
  WBTC DAO address."
- **Deployed vs repo:** the token, Controller, Factory and Members addresses in the DAO repo match
  what the chain returns, and the role wiring matches the source. The *ownership* documented in the
  repo does not match the chain. Byte-for-byte source verification was not performed.
- **This bridge is a company holding an asset.** Say it plainly: WBTC exists because BitGo (moving
  to BiT Global) holds bitcoin and says so.
  - *Verifiable on-chain:* WBTC supply; every mint request, confirmation, rejection and burn; the
    merchant and custodian registries; the multisig owners and quorums; the absence of a timelock,
    a proxy and a blacklist; the BTC balances of the 20 addresses the issuer publishes.
  - *Legal promise only:* that those 20 addresses are the custodian's; that the bitcoin in them is
    unencumbered and not rehypothecated; that redemption will be honoured; the merchant fee, which
    the merchant guide states is set "off-chain by agreement"; and any recourse whatsoever if the
    custodian fails. Note the custodian's key material now sits across Hong Kong, Singapore and the
    United States, so recourse is a three-jurisdiction question.

### 4. EVIDENCE

| claim | source | accessed |
|---|---|---|
| Mint/burn flow, merchant + custodian roles, 6 BTC confs / 25 ETH confs | https://docs.wbtc.network/how-wbtc-works/mint-burn-mechanism | 2026-08-04 |
| Contract addresses on 7 chains, 8 decimals | https://docs.wbtc.network/resources/contract-addresses | 2026-08-04 |
| Custody: cold storage, geographically distributed keys, BiT Global + BitGo alliance | https://docs.wbtc.network/how-wbtc-works/custody-and-security | 2026-08-04 |
| PoR: 116,499.20 WBTC vs 116,514.34 BTC, 20 custodian addresses, per-chain split | https://www.wbtc.network/transparency | 2026-08-04 |
| Merchant list (Galaxy, Amber, BitGo, Wintermute, CoinList, Cobo), "DAO-approved" | https://www.wbtc.network/ | 2026-08-04 |
| Token source (Pausable/Mintable/Burnable/Ownable, no blacklist) | https://raw.githubusercontent.com/WrappedBTC/bitcoin-token-smart-contracts/master/ethereum/contracts/token/WBTC.sol | 2026-08-04 |
| Controller: pause/unpause onlyOwner, mint/burn onlyFactory, setMembers | https://raw.githubusercontent.com/WrappedBTC/bitcoin-token-smart-contracts/master/ethereum/contracts/controller/Controller.sol | 2026-08-04 |
| Factory: addMintRequest / confirmMintRequest / rejectMintRequest, onlyMerchant / onlyCustodian | https://raw.githubusercontent.com/WrappedBTC/bitcoin-token-smart-contracts/master/ethereum/contracts/factory/Factory.sol | 2026-08-04 |
| Address book, merchant list, DAO member list | https://raw.githubusercontent.com/WrappedBTC/DAO/master/README.md | 2026-08-04 |
| Merchant mint/burn procedure; fee "off-chain agreement"; no minimum stated | https://raw.githubusercontent.com/WrappedBTC/DAO/master/MerchantGuide.md | 2026-08-04 |
| "Controller owner and members owner should be the WBTC DAO address" | https://raw.githubusercontent.com/WrappedBTC/DAO/master/DeploymentVerification.md | 2026-08-04 |
| BiT Global custody transition, key split HK/SG/US, completion 2026-05-01 | https://wbtc-network.medium.com/bit-global-to-complete-next-phase-of-wbtc-custody-transition-ac4049691210 (pub. 2026-03-01) | 2026-08-04 |
| Multi-jurisdictional custody rationale | https://www.bitgo.com/resources/blog/bitgo-to-move-wbtc-to-multi-jurisdictional-custody-to-accelerate-global/ | 2026-08-04 |
| BitGo → Chainlink CCIP for WBTC cross-chain (**press only**) | https://www.coindesk.com/business/2026/08/04/bitgo-s-wbtc-move-pushes-layerzero-to-chainlink-tally-near-usd15-billion · https://www.cryptotimes.io/2026/08/04/bitgo-selects-chainlink-ccip-for-7-7b-wbtc-cross-chain-migration/ | 2026-08-04 |
| DefiLlama methodology + TVL $7,314,780,495 | https://api.llama.fi/protocol/wbtc · https://api.llama.fi/tvl/wbtc · https://raw.githubusercontent.com/DefiLlama/DefiLlama-Adapters/main/projects/wbtc.js | 2026-08-04 |
| Repo metadata, HEAD, tree | https://api.github.com/repos/WrappedBTC/bitcoin-token-smart-contracts · /contents/ | 2026-08-04 |
| **All `[on-chain]` readings** | `eth_call` against `https://ethereum-rpc.publicnode.com` | 2026-08-04 |

### 5. WHAT LOOKS UNNAMEABLE

- **Custody by an off-chain legal entity.** The whole mechanism. No symbol names "a company holds
  the asset in a jurisdiction and its promise is the peg."
- **The merchant role.** A permissioned intermediary that (i) performs KYC on the requester, (ii)
  is the only party who may request mint or execute burn, and (iii) charges a bilaterally negotiated
  off-chain fee. `Aw` names a gate; it does not name an intermediating principal.
- **Redemption held by a different party than the token holder.** `Rd` asserts a right exists and is
  silent on who holds it. Here the right belongs to 47 firms and to nobody else.
- **A live address-listing PoR versus a periodic audited attestation.** `At` cannot distinguish
  "here are 20 addresses, go check them yourself" from "an auditor signed a report last quarter,"
  and the difference is the entire epistemic content.
- **A pause that reaches every holder's transfers** as distinct from a pause that stops new issuance.
  `Gp` covers both and they are different powers.
- **Multisig quorum without delay** as a distinct control-plane object from a timelock. The
  vocabulary has `Tg` (delayed execution) and nothing for "k-of-n, immediate."
- **The swappable authority contract.** `Controller.setFactory()` changes who may mint without
  changing any implementation code. It is neither `Up` (no proxy) nor `Tg`.
- **A source domain that cannot execute code.** Bitcoin cannot verify anything; the vocabulary's
  cross-domain group implicitly assumes two programmable domains.

### 6. DELTA

1. **`Tg` is wrong.** The corpus gives WBTC `Tg` (delayed-governance execution) and this is the one
   symbol that distinguishes it from the Coinbase entry. There is no timelock anywhere in the WBTC
   control plane: all three governing contracts are Consensys `MultiSigWallet` instances
   (`MAX_OWNER_COUNT() = 50`) with `secondsTimeLocked()` / `delay()` / `getMinDelay()` absent, and
   execution is immediate once the 6-of-10 or 5-of-9 quorum is reached `[on-chain, 2026-08-04]`.
2. **The `Fz` marker is wrong.** The corpus marker says the custodian "can pause minting and
   blacklist addresses." Pause: true. Blacklist: **false** — `blacklister()` and
   `isBlacklisted(address)` revert, and the source has no such function `[on-chain + source]`. WBTC
   has no freeze and no forced transfer.
3. **`Up` is arguably missing, in substance.** The token is non-upgradeable, but
   `Controller.setFactory()` / `setMembers()` let a 6-of-10 replace the mint-authorising contract.
   That is mutable authority without a proxy — the corpus records neither.
4. **Governance is not where the corpus and the repo say it is.** The WBTC DAO multisig named in
   the repository (`0xB33f8879…`, 8-of-13) owns neither the Controller nor Members. The Controller
   is owned by a 6-of-10 at `0x972eed35…` and Members by a 5-of-9 at `0x4dbbbfb0…`. Six of the
   6-of-10's signers do not appear in the repo's DAO member table at all.
5. **Custody has moved since the ranking basis was captured.** The corpus's residue says "BitGo
   holds bitcoin." As of 2026-05-01 the custodian of record is BiT Global (HK/SG), with BitGo
   holding one of three keys via a US entity.
6. **A same-day structural change is unrecorded:** BitGo replacing LayerZero with Chainlink CCIP for
   WBTC's cross-chain leg (press-only). If confirmed, WBTC's multi-chain design changes and its
   relationship to entry #2 in this very category inverts.
7. **Ranking basis holds.** DefiLlama `wbtc` = $7,314,780,495 on 2026-08-04 vs the corpus's
   $7,300.5m — same figure, hours apart. Rank #1 stands.

---

## LayerZero V2

### 1. WHAT IT DOES

LayerZero V2 is not a bridge; it is a message-passing protocol on which bridges are built, and its
functional contract is therefore conditional. For the token case: a holder gives up tokens on the
source domain either by having them **burned** (an OFT) or **locked into a lockbox contract** (an
OFT Adapter), and a message is emitted through an immutable Endpoint contract. That message is
verified on the destination by a set of Decentralized Verifier Networks (DVNs) **that the
application itself chose**, under an X-of-Y-of-N threshold, and then delivered by an Executor which
calls `lzReceive` on the destination contract and pays the destination gas; the destination
contract mints or releases the corresponding tokens. Redemption is symmetric — send the tokens back
the other way. What must be trusted for the two sides to remain equal is *not a property of
LayerZero*: it is the specific DVN set the application configured, the threshold it set, the
application owner or delegate who can change that configuration at any time, and the Endpoint
owner's registry of permitted message libraries. Two applications on the same endpoint pair can have
completely different security, and one of them can be a single company. On 2026-04-18 that exact
distinction cost KelpDAO $292m: rsETH was configured 1-of-1 with the LayerZero Labs DVN as the sole
verifier.

### 2. DESIGN

**Supply topology — both, chosen per token.** `OFT` is **burn-and-mint**: total supply is conserved
across chains, no escrow exists, and an exploit cannot exceed what was burned. `OFTAdapter` is
**lock-and-mint**: the original token sits in a lockbox on its home chain and a representation
circulates elsewhere, concentrating value in an escrow. These have opposite attack surfaces.
DefiLlama's $6,669,281,380 "LayerZero" TVL is the adapter/escrow side, of which **$6,374,017,781
is on Ethereum alone** — i.e. the measured TVL is almost entirely the lock-and-mint leg; the
burn-and-mint leg contributes no TVL by construction.

**Verification model — application-configured verifier sets.** Each OApp configures, per remote
endpoint and per direction, a Message Library and a security stack: **required DVNs** (every one
must verify the `payloadHash`) plus **optional DVNs** with a threshold — the "X of Y of N" model.
Verification is a per-application parameter, not a protocol property. The documentation explicitly
warns that unset configurations fall back to placeholders which "may be Dead DVNs that prevent
message delivery"; a `LZ Dead DVN` is deployed on each chain
(`0x747c741496a507e4b404b50463e691a8d692f6ac` on Ethereum). **Empirically the default is dangerous
in the other direction too:** the 1-of-1 LayerZero-Labs-only configuration is what KelpDAO ran, and
Kelp's public position is that this was LayerZero's own documented default, with roughly 40% of
protocols on it; LayerZero later stated it "made a mistake" in allowing its own verifier network to
secure high-value assets in that configuration.

**Executor — a paid economic role distinct from the verifier.** An off-chain worker that watches for
sufficient verification, commits the nonce, calls `lzReceive` on the destination, and **fronts the
destination-chain gas** on the sender's behalf, recovering it from the source-chain fee quote. On
Ethereum: `LZ Executor 0x173272739bd7aa6e4e214714048a9fe699453059`, `lzExecutor
0xbf2e102fb382d6ec52823c8f81a45e9caa951320`. Executors are a liveness dependency, not a safety one.

**Mint/burn authority.** Not LayerZero's — it belongs to the OFT contract, owned by the application.

**Attestation / proof of reserve.** None, and none is meaningful: there is no reserve, only
per-message verification.

**Freeze / blacklist.** None at protocol level. The Endpoint has no pause: `paused()` and `pause()`
both revert `[on-chain]`.

**Control plane.** `EndpointV2` on Ethereum is `0x1a44076050125825900e736c501f859c50fe728c`,
`eid() = 30101` (`0x7595`), 24,005 bytes of non-proxy bytecode `[on-chain]`. It is documented as
"immutable, permissionless" — meaning the code cannot be replaced. **It is nevertheless owned**:
`owner() = 0xbe010a7e3686fdf65e93344ab664d065a0b02478` `[on-chain]`, a custom multisig
(`VERSION() = "0.0.1"`, `threshold() = 3`, `nonce() = 611`, 7,197 bytes, **no `secondsTimeLocked` or
`getMinDelay` — no timelock**) `[on-chain]`. The owner controls the registered-library set
(`getRegisteredLibraries()` returns 4 entries, including `blockedLibrary()
= 0x1ccbf0db9c192d969de57e25b3ff09a25bb1d862`) and the protocol defaults. `lzToken()` is
`address(0)` on Ethereum, i.e. ZRO fee payment is not enabled there `[on-chain]`. Application-side
control is the OApp `owner` plus an authorised `delegate` who may change the send/receive config.
The deployment metadata lists **180 mainnet v2 chain deployments**.

### 3. REPO

- `https://github.com/LayerZero-Labs/LayerZero-v2` — default branch `main`, HEAD
  **`9c741e7f9790639537b1710a203bcdfd73b0b9ac`** (2026-02-27; repo last pushed on another branch
  2026-06-29). **Dual-licensed**: `LICENSE-LZBL-1.2` (LayerZero Business License) **and**
  `LICENSE-MIT` at the repo root — GitHub reports the licence as `NOASSERTION` because of the pair.
  This matters: LZBL-1.2 is *not* an OSI licence and the two files do not obviously partition the
  tree.
  Top level: `.devcontainer, .github, .gitmodules, .prettierrc.js, .solhintrc.js, .yarn,
  LICENSE-LZBL-1.2, LICENSE-MIT, README.md, funding.json, lib, package.json, packages, yarn.lock`.
  `packages/layerzero-v2/{aptos, evm, initia, iota, solana, sui, ton}` — the EVM protocol,
  messagelib and oapp/OFT sources live under `packages/layerzero-v2/evm/`. GitHub reports the
  primary language as **Move** (the Aptos/Sui trees dominate by size), not Solidity.
- **Audits:** `https://github.com/LayerZero-Labs/Audits`, HEAD `ec69897…` (2026-07-17), 17 scope
  directories: `DVN, Endpoint V1 - EVM, Endpoint V2 - {Aptos, EVM, IOTA L1, Solana, Starknet,
  Stellar, Sui}, EndpointV2Alt Supports, HyperLiquid Composer, LZ Multicall, OApp, OFT, ONFT,
  Ovault, Stargate, ZRO`.
- **Deployed vs repo:** deployment addresses come from the first-party metadata API
  (`metadata.layerzero-api.com/v1/metadata/deployments`); I independently confirmed on Ethereum that
  the advertised `EndpointV2` address returns `eid 30101`, is not a proxy, and is owned by a 3-of-n
  multisig `[on-chain]`. I did **not** byte-compare deployed bytecode against the repo.
- Not a company holding an asset — but note that under an OFT **Adapter**, the lockbox is a contract
  whose owner is the *application*, not LayerZero, so the custody question moves to the app.

### 4. EVIDENCE

| claim | source | accessed |
|---|---|---|
| Endpoint immutable/permissionless; MessageLib; DVN payloadHash; X-of-Y-of-N; per-app channels | https://docs.layerzero.network/v2/home/protocol/protocol-overview · https://docs.layerzero.network/v2/concepts/protocol/layerzero-endpoint | 2026-08-04 |
| Required vs optional DVNs; "always set your DVN configuration explicitly. Defaults are placeholder configurations — they may be Dead DVNs" | https://docs.layerzero.network/v2/concepts/modular-security/security-stack-dvns | 2026-08-04 |
| Definitions: Endpoint, DVN, Executor, OApp, OFT, OFT Adapter, MessageLib, delegate, X of Y of N, nonce, lzReceive, lzCompose | https://docs.layerzero.network/v2/concepts/glossary | 2026-08-04 |
| OFT = burn-and-mint; OFT Adapter = lockbox lock-and-mint; supply conservation | https://docs.layerzero.network/v2/home/token-standards/oft-standard | 2026-08-04 |
| Ethereum mainnet V2 addresses (endpointV2, sendUln302, receiveUln302, executor, deadDVN, blockedMessageLib); eid 30101; 180 mainnet v2 chains | https://metadata.layerzero-api.com/v1/metadata/deployments | 2026-08-04 |
| KelpDAO exploit: 2026-04-18, ~$292m / 116,500 rsETH, "rsETH was configured with a single verifier: the LayerZero Labs DVN", two LayerZero-hosted RPC nodes compromised + DDoS on an external RPC, DPRK/Lazarus TraderTraitor attribution | https://www.chainalysis.com/blog/kelpdao-bridge-exploit-april-2026/ | 2026-08-04 |
| Kelp's counter-claim that 1-of-1 was LayerZero's documented default; LayerZero "made a mistake" | https://www.coindesk.com/tech/2026/04/20/kelp-dao-claims-layerzero-s-default-settings-are-what-actually-caused-the-usd290-million-disaster · https://www.coindesk.com/tech/2026/05/09/layerzero-says-it-made-a-mistake-in-usd292-million-kelp-exploit | 2026-08-04 |
| LayerZero's own post-mortem page **not locatable** on layerzero.network/blog (index lists "Ongoing Security Updates 7/10", "Support Update - July 24, 2026", no KelpDAO post-mortem) | https://layerzero.network/blog | 2026-08-04 |
| TVL $6,669,281,380; per-chain breakdown; "immutable smart contracts" description | https://api.llama.fi/tvl/layerzero · https://api.llama.fi/protocol/layerzero | 2026-08-04 |
| Repo metadata, HEAD, licences, tree | https://api.github.com/repos/LayerZero-Labs/LayerZero-v2 · /contents/ · /contents/packages/layerzero-v2 | 2026-08-04 |
| Audit scope directories | https://api.github.com/repos/LayerZero-Labs/Audits/contents/audits | 2026-08-04 |
| **All `[on-chain]` readings** | `eth_call` against `https://ethereum-rpc.publicnode.com` | 2026-08-04 |

### 5. WHAT LOOKS UNNAMEABLE

- **Configurable verification.** The product *is* that the application picks its verifier set and
  threshold. `Xm` asserts "messages are verified" and cannot express who, how many, chosen by whom,
  or that security is a per-application parameter. The #2 entry's defining feature is invisible.
- **The default configuration as an attack surface.** A protocol whose unset config is a live
  1-of-1 (or a Dead DVN that bricks delivery) has a mechanism — inherited security — with no symbol.
- **Burn-and-mint versus lock-and-mint.** Both are `Xf`, and they have opposite failure modes.
- **The Executor as a paid role distinct from the verifier**, including the fact that it prepays
  destination gas. `Gs` is written for account-abstraction paymasters, not cross-domain delivery.
- **The separation of safety from liveness across two role types** — DVNs are safety, Executors are
  liveness, and losing each has a different consequence.
- **An immutable contract that is nonetheless owned.** The Endpoint code cannot change; the library
  registry and defaults can. Neither `Up` nor `Tg` nor `Gp` names this.
- **Optional fee-token denomination** (`lzToken`, ZRO) as a protocol parameter that is off on some
  chains and on elsewhere.
- **`lzCompose` / horizontal composition** — a received message triggering further cross-domain
  calls — has no name.

### 6. DELTA

1. **`Up` looks wrong at the protocol layer.** The corpus assigns `Up` (mutable implementation
   proxy). `EndpointV2` is explicitly immutable and is not a proxy (24,005 bytes of direct bytecode,
   no implementation slot) `[on-chain + docs]`. What *is* mutable is the registered-library set and
   the default config, controlled by the Endpoint owner. If `Up` was meant to capture "the protocol
   can change under you," it is capturing the right worry with the wrong mechanism.
2. **`Gp` looks wrong at the protocol layer.** `EndpointV2` has no pause: `paused()` and `pause()`
   both revert `[on-chain]`. A guardian pause may exist per-OApp, but that is the application's, not
   LayerZero's.
3. **`Tg` looks wrong.** The Endpoint owner is a 3-of-n multisig with no `secondsTimeLocked` and no
   `getMinDelay` — immediate execution on quorum `[on-chain]`. Same error as the WBTC entry.
4. **The corpus has no record of the KelpDAO exploit.** On 2026-04-18, ~$292m was minted out of a
   LayerZero-powered bridge because the OApp ran a 1-of-1 DVN configuration and two LayerZero-hosted
   RPC nodes were compromised. This is the single strongest available empirical support for the
   corpus's own residue claim that `Xm` conflates verification models — and it should be cited when
   the claim is made, because it converts an argument into a measurement.
5. **The corpus has no record of the resulting migrations**, including WBTC's own announced move
   from LayerZero to Chainlink CCIP on the access date. The #1 and #2 entries in this category are
   currently changing their relationship to each other.
6. **The `Gs` candidate marker is well-placed** — the Executor genuinely prepays destination gas and
   recovers it in the source-chain quote — but `Gs` will not carry the DVN/Executor *separation*,
   which is the part that matters.
7. **Ranking basis holds.** DefiLlama `layerzero` = $6,669,281,380 vs the corpus's $6,666.7m. Rank
   #2 stands. Worth flagging for later stages that this TVL is *entirely the OFT-Adapter escrow
   side* — the burn-and-mint side of the same protocol is structurally invisible to a TVL ranking,
   which is the same blind spot that keeps CCTP off the list.

---

## Coinbase Bridge (cbBTC and other wrapped assets)

### 1. WHAT IT DOES

A Coinbase customer gives up nothing on the source chain in the usual sense: they initiate a
withdrawal of BTC (or DOGE, XRP, ADA, LTC, MEGA) from their Coinbase account to an address on a
supported network, and Coinbase, instead of sending the native asset, retains it in custody and
delivers a 1:1 wrapped ERC-20 — cbBTC on Base, Ethereum, Solana and Arbitrum; cbDOGE, cbXRP, cbADA,
cbLTC, cbMEGA on Base. What redeems it is depositing the wrapped token back into a Coinbase account,
which auto-unwraps it and credits the underlying asset; there is no contract-level redemption and
no order book or trading pair for the wrapped token on Coinbase. Redemption is therefore available
**only to Coinbase customers in good standing in eligible regions** — cbBTC is unavailable to
send/receive for accounts in Canada, Japan and Georgia, and the other five wrapped assets are
blocked in over a hundred jurisdictions including most of the EEA, the UK-adjacent markets, Japan,
Singapore, Hong Kong and New York State. Everyone else exits by selling on a DEX. What must be
trusted is that Coinbase holds the underlying asset, that it will keep unwrapping, and that the
single-key holders of the `owner`, `pauser`, `blacklister` and `masterMinter` roles — and the proxy
admin who can replace the token implementation outright — do not act adversely.

### 2. DESIGN

**Supply topology — custodial wrap.** Nothing is locked in a contract on the source chain. The
"debit" is a Coinbase ledger entry; the "credit" is a mint. Five of the six source assets live on
chains that cannot run a verification contract at all (Bitcoin, XRP, Doge, Cardano, Litecoin).

**Verification model — none. Single-company.** No message, no proof, no verifier set, no threshold.
Minting is an operational decision by Coinbase.

**Mint / burn authority.** The token is a CENTRE `FiatTokenV2_1`: an `owner` sets the `masterMinter`,
which grants per-minter allowances; a `MintForwarder` contract in Coinbase's repo adds *rate-limited
minting with programmatic allowance replenishment* ("continuously mint up to N tokens over M time"),
because the base fiat-token design requires a cold `masterMinter` key to top allowances back up.
Live roles on Ethereum `[on-chain]`: `owner 0xce56d20689d836ec7a728ceb94a15746696c16e6`,
`pauser 0x1ac78dfcae082e9fe286d1ccb12c17a3e906b906`,
`blacklister 0x5130bf38bf5342aa06cc79b8cc198cce832b01af`,
`masterMinter 0x1302dfb1f806398f48650c75ab0fda9a0186f47b`. **`owner` and `masterMinter` are EOAs**
(`eth_getCode` returns empty) — no multisig contract, no timelock.

**Attestation / proof-of-reserve regime.** Coinbase publishes a live cbBTC proof-of-reserves page
listing every reserve Bitcoin address and its balance: **96,065.18 BTC reserve against 96,054.41
cbBTC supply**, "data refreshed at 8/4/2026, 8:45 PM," split 48,338.78 / 44,528.809 / 3,108.551 /
78.272 across four networks. Ethereum-side supply reads **48,338.77958531 cbBTC** `[on-chain]`,
matching the first bucket exactly. DefiLlama consumes Coinbase's own JSON —
`getConfig('coinbase-cbbtc-proof-of-reserves', 'https://www.coinbase.com/cbbtc/proof-of-reserves.json')`
— and sums the declared addresses, plus hardcoded ADA/XRP/DOGE/LTC address lists. Coinbase is also
reported to use Chainlink Proof of Reserve to publish cbBTC reserve data on Base and Ethereum
(press/Chainlink social, not a first-party Coinbase page I could reach). Note the launch-day
position: on 2024-09-12 Coinbase said proof of reserves "has been part of our roadmap since the
conception of cbBTC and will follow" — the PoR page exists now; per-asset PoR pages also exist for
the other wrapped assets (e.g. `/cbltc/proof-of-reserves`).

**Freeze / blacklist powers — full.** `blacklist(address)` / `unBlacklist(address)` /
`isBlacklisted(address)` by the blacklister, and `pause()` / `unpause()` by the pauser. `paused()` is
`false` `[on-chain]`. This is the USDC control surface, applied to a wrapped bitcoin.

**Control plane — a real upgradeable proxy, single-key admins, no timelock.** cbBTC is a
`FiatTokenProxy` (ZeppelinOS/unstructured storage — the implementation sits in the legacy slot
`0x7050c9e0…`, **not** the EIP-1967 slot, which reads zero) pointing to
**`0x7458bfDC30034EB860B265E6068121D18Fa5Aa72`**, verified as `FiatTokenV2_1`, solc 0.6.12
`[on-chain + BaseScan]`. Same implementation address on Base and Ethereum. The proxy exposes
`upgradeTo` / `upgradeToAndCall` / `changeAdmin`. The repo notes the `owner` can change `owner`,
`pauser`, `blacklister`, `masterMinter` and `oracle`, but **cannot** change the `proxyOwner` —
i.e. upgrade authority is a separate key again.

### 3. REPO

- `https://github.com/coinbase/wrapped-tokens-os` — default branch `main`, HEAD
  **`5697a90f4c47e8d801cedce81444a8464019fe08`** (2023-05-12). **No `LICENSE` file at the repo
  root**; `package.json` declares `"license": "MIT"`. TypeScript tooling (Hardhat) around Solidity
  contracts.
  Top level: `@types/, README.md, cbETH Logo Kit/, contracts/, doc/, hardhat.config.ts,
  package.json, slither.config.json, test/, tsconfig.json, yarn.lock`.
  `contracts/wrapped-tokens/` contains only `FiatTokenProxy.sol, MintForwarder.sol, MintUtil.sol,
  RateLimit.sol, staking/`.
- **The token implementation is not in the repo.** The README states the token contract "will be an
  exact duplicate of centre-tokens [`FiatTokenV2_1`]" and the proxy "an exact duplicate of the
  proxy contract used by centre-tokens." So the canonical source for the thing that actually holds
  the balances is `centrehq/centre-tokens` v2.1.0, a third-party repo.
- **Deployed vs repo:** the deployed implementation is verified on BaseScan under the name
  `FiatTokenV2_1`, consistent with the README's claim; the proxy is `FiatTokenProxy`, consistent
  with the repo's copy. I did not byte-compare against `centre-tokens` v2.1.0. The repo has not been
  touched since 2023-05 while cbXRP/cbDOGE/cbADA/cbLTC/cbMEGA all launched afterwards — **the repo
  never mentions cbBTC or any of the newer wrapped assets by name**.
- **This bridge is a company holding an asset.** Coinbase holds the bitcoin.
  - *Verifiable on-chain:* cbBTC supply per chain; the proxy implementation address; the four admin
    role addresses and that two of them are single EOAs; every mint, burn, blacklist and pause;
    the balances of whatever Bitcoin addresses one chooses to watch.
  - *Legal promise only:* that the addresses on Coinbase's PoR page are Coinbase's and unencumbered
    (the address→Coinbase mapping is an assertion, not a proof); that unwrapping will be honoured;
    that a blacklisting is reversible. Redemption is an account action governed by the Coinbase User
    Agreement and gated by region and account standing, not a contract right. Non-customers have no
    redemption path at all.

### 4. EVIDENCE

| claim | source | accessed |
|---|---|---|
| cbBTC "backed 1:1 by Bitcoin (BTC) held by Coinbase"; launch 2024-09-12; addresses on Base/Ethereum/Solana/Arbitrum; no separate order book; PoR "will follow" (footnote updated 2024-09-23) | https://www.coinbase.com/blog/coinbase-wrapped-btc-cbbtc-is-now-live | 2026-08-04 |
| Full asset/network table (cbBTC, cbDOGE, cbXRP, cbADA, cbLTC, cbMEGA); auto-unwrap on receipt; per-asset regional restriction lists | https://help.coinbase.com/en/coinbase/trading-and-funding/sending-or-receiving-cryptocurrency/coinbase-wrapped-btc | 2026-08-04 |
| "backed 1:1 and held in custody by Coinbase"; auto-convert on send to Base | https://www.coinbase.com/cbbtc | 2026-08-04 |
| PoR: 96,065.18 BTC reserve / 96,054.41 cbBTC supply, per-network split, 20 reserve addresses, refreshed 8/4/2026 8:45 PM | https://www.coinbase.com/cbbtc/proof-of-reserves | 2026-08-04 |
| Architecture: FiatTokenProxy + FiatTokenV2_1 + MinterForwarder + ExchangeRateUpdater; owner/pauser/blacklister/masterMinter/oracle; owner cannot change proxyOwner; rate-limited minting rationale | https://raw.githubusercontent.com/coinbase/wrapped-tokens-os/master/README.md | 2026-08-04 |
| Proxy → implementation `0x7458bfDC30034EB860B265E6068121D18Fa5Aa72`; `FiatTokenV2_1`, solc 0.6.12; blacklist/pause/mint/configureMinter functions | https://basescan.org/address/0xcbb7c0000ab88b473b1f5afd9ef808440eed33bf · https://basescan.org/address/0x7458bfDC30034EB860B265E6068121D18Fa5Aa72#code | 2026-08-04 |
| Chainlink Proof of Reserve used for cbBTC on Base and Ethereum (**third-party**) | https://x.com/chainlink/status/1928121157334503437 | 2026-08-04 |
| DefiLlama reads Coinbase's own PoR JSON; per-chain TVL Bitcoin $6,158,097,002 + ADA/LTC/XRP/DOGE; total $6,162,585,917 | https://raw.githubusercontent.com/DefiLlama/DefiLlama-Adapters/main/projects/coinbase-btc/index.js · https://api.llama.fi/protocol/coinbase-bridge · https://api.llama.fi/tvl/coinbase-bridge | 2026-08-04 |
| Repo metadata, HEAD, tree, package.json licence | https://api.github.com/repos/coinbase/wrapped-tokens-os · /contents/ · /contents/contracts/wrapped-tokens · https://raw.githubusercontent.com/coinbase/wrapped-tokens-os/master/package.json | 2026-08-04 |
| **All `[on-chain]` readings** | `eth_call` / `eth_getCode` / `eth_getStorageAt` against `https://ethereum-rpc.publicnode.com` | 2026-08-04 |

### 5. WHAT LOOKS UNNAMEABLE

- **Custody by an off-chain legal entity**, again, and here with the added property that the
  custodian is also the largest venue where the underlying trades.
- **The single-key admin.** `owner` and `masterMinter` are EOAs. The vocabulary's control group
  assumes governance objects (timelock, proxy, guardian) and has nothing for "one private key can
  replace the token implementation."
- **Rate-limited minting with programmatic allowance replenishment** (`MintForwarder` / `RateLimit`).
  It is a real safety mechanism — a bounded issuance rate — and nothing names it.
- **Region-conditional redemption.** The redemption right exists in the US-minus-New-York, and not
  in Canada; it exists for cbBTC and not for cbXRP in the same country. `Rd` cannot carry a
  jurisdiction vector, and `Aw` gates access, not redemption.
- **Auto-wrap on withdrawal.** The user asked to withdraw BTC; the system delivered cbBTC. The
  conversion is a side effect of a transfer, not a transaction the user submits.
- **An implementation borrowed wholesale from a third-party repository** — the security-relevant
  source is not the issuer's.
- **A live issuer-published reserve feed consumed by third parties as ground truth.** DefiLlama's
  number for a $6.16b protocol is the issuer's own JSON. `At` names an attestation; it does not name
  the circularity.

### 6. DELTA

1. **`Up` is right and is the load-bearing difference.** cbBTC is a genuine upgradeable proxy —
   `FiatTokenProxy` with `upgradeTo` / `upgradeToAndCall`, implementation
   `0x7458bfDC…Fa5Aa72` in the legacy ZeppelinOS slot `[on-chain]`. Nothing in the WBTC or BTCB
   entries is comparable.
2. **`Fz` should be a firm assignment, not a marker.** `blacklist` / `unBlacklist` /
   `isBlacklisted` are live functions with a named `blacklister` role at
   `0x5130bf38…` `[on-chain]`. Coinbase is the *only* one of the three custodial wrappers with an
   on-chain freeze.
3. **`At` has strengthened since the ranking basis.** The corpus marker says reserve reporting is
   "periodic and issuer-published, not a protocol mechanism." It is now a live per-address feed with
   a machine-readable JSON endpoint, plus a reported Chainlink PoR feed on Base and Ethereum. Still
   issuer-published — but "periodic" is no longer accurate.
4. **The corpus residue undercounts the asset set.** It names Bitcoin, XRP, Doge, Cardano and
   Litecoin. There is a sixth, **cbMEGA (MegaETH)**, and MegaETH *is* a programmable chain — so the
   claim "this bridges five non-smart-contract source chains" is now five of six.
5. **The control plane is weaker than the corpus implies.** `owner` and `masterMinter` are plain
   EOAs `[on-chain]`. There is no timelock and no multisig contract anywhere in the cbBTC admin
   surface. A corpus record that gives Coinbase `Up` but not `Tg` gets the direction right for the
   wrong reason — it is not that Coinbase chose upgradeability over delay, it is that there is no
   delay and no quorum at all.
6. **Ranking basis holds.** DefiLlama `coinbase-bridge` = $6,162,585,917 vs the corpus's $6,150.9m;
   99.93% of it is cbBTC ($6,158.1m of $6,162.6m). Rank #3 stands, and the entry is
   *de facto* a cbBTC entry.

---

## Hyperliquid Bridge

### 1. WHAT IT DOES

A user gives up native USDC on Arbitrum by transferring it to the `Bridge2` contract (minimum 5
USDC; less is lost permanently), and receives a credit to their Hyperliquid L1 account — not a
token, a balance in HyperCore's ledger — once validators holding more than two-thirds of staking
power have signed the deposit, which takes about a minute. What redeems it is a withdrawal: the user
signs an EIP-712 `WithdrawAction3` on Hyperliquid, the L1 balance is deducted immediately,
validators sign the withdrawal, a request is posted to the Arbitrum contract, and after a
**200-second dispute period** a finalizer releases the USDC; funds arrive in 3–4 minutes and the
user never needs Arbitrum ETH, because a flat 1 USDC gas fee is charged on Hyperliquid instead. What
must be trusted is precisely the thing that already secures the destination chain: the stake-weighted
Hyperliquid validator set. That is the design's central virtue — bridge security equals chain
security rather than adding an independent assumption — and its central caveat is that the same set
also holds the emergency powers: `lockers` can vote to lock the bridge during a dispute, and a
cold-wallet quorum of two-thirds of stake can invalidate pending withdrawals and unlock with a new
validator set.

### 2. DESIGN

**Supply topology — lock-and-mint escrow, but with a destination that is a ledger, not a token, and
with most of the "bridged" asset no longer flowing through it.** `Bridge2.usdcToken()` is Arbitrum's
**native** USDC `0xaf88d065e77c8cC2239327C5EDb3A432268e5831` `[on-chain]`, and the contract holds
**$421,856,739.90 native USDC plus $5,026.03 of legacy USDC.e** `[on-chain]`. DefiLlama's
$5,906,458,452 for `hyperliquid-bridge` splits as **Arbitrum $421,919,062 / "Hyperliquid L1"
$5,484,539,389** — that second bucket is native USDC minted directly on Hyperliquid via Circle's
CCTP, which never touched this escrow. So **roughly 93% of the ranked TVL is canonical issuance, not
bridge escrow**, and two supplies of the same token with different trust models coexist on one
chain. DefiLlama's own description says as much: "Native USDC is minted on Hyperliquid via CCTP, and
USDC is bridged from Arbitrum."

**Verification model — endogenous consensus.** Deposits are credited when more than 2/3 of staking
power signs; withdrawals require the same. There is no external verifier, no oracle, no fraud proof
by a third party. **34 validators, 27 active, 436,005,726 HYPE staked** `[Hyperliquid info API]`.
Concentration matters for the 2/3 rule: **five "Hyper Foundation" validators hold 212,971,320 HYPE
= 48.85% of total stake**, so the Foundation alone is far above the >1/3 needed to veto any
withdrawal, and needs only one further sixth of stake to sign unilaterally.

**Mint / burn authority — none.** No token exists on the destination; there is nothing to mint.

**Attestation / proof of reserve — none needed.** The escrow is a contract balance anyone can read.
This is the only one of the five where the reserve is a first-class on-chain object.

**Freeze / emergency posture.** `lockers` vote to trigger an emergency lock, which pauses the
contract (`voteEmergencyLock` / `unvoteEmergencyLock`). `invalidateWithdrawals` cancels pending
withdrawals under a cold-wallet quorum. `emergencyUnlock` requires cold-wallet signatures of 2/3 of
stake and installs a new validator set. The hot/cold split is explicit in state:
`hotValidatorSetHash() = 0x1503ca1a…13fb7f`, `coldValidatorSetHash() = 0x55a3e95e…de0adc2d`,
`epoch() = 7`, `paused() = false` `[on-chain]`.

**Control plane.** `Bridge2` is `Pausable, ReentrancyGuard`, **not upgradeable and not owned** —
`implementation()`, `admin()` and `owner()` all revert `[on-chain]`. Every privileged action is
authorised by validator signatures, not by an admin key. Timing is on-chain and readable:
`disputePeriodSeconds() = 200`, `blockDurationMillis() = 350` `[on-chain]`. Validator-set updates
are themselves subject to the dispute period.

**Staking lifecycle — and the slashing gap.** HYPE is delegated to validators; each validator must
self-delegate 10k HYPE locked for a year; delegations have a 1-day lockup; transfers from the staking
account to the spot account go through a **7-day unstaking queue** with at most 5 pending
withdrawals. Unresponsive validators can be **jailed by peer vote**. But the docs state plainly:
**"There is currently no automatic slashing implemented."** So the validator stake is *not*
slashable first-loss capital for a bridge failure.

### 3. REPO

- `https://github.com/hyperliquid-dex/contracts` — default branch `master`, HEAD
  **`d7e66aa751ffbd19bfd2b90fd5d9a3d8f32d99ee`** (2023-11-28). **No `LICENSE` file and no README.**
  Entire contents: `Bridge2.sol`, `Signature.sol`, `tests/`. `Bridge2.sol` header is
  `// SPDX-License-Identifier: UNLICENSED`, `pragma solidity ^0.8.9`. GitHub reports the repo
  language as Rust (the `tests/` tree).
- **Deployed:** `0x2Df1c51E09aECF9cacB7bc98cB1742757f163dF7` on Arbitrum One. Arbiscan reports
  **"Source Code Verified — Exact Match"**, contract name `Bridge2`, compiler `v0.8.9+commit.e5eed63a`,
  optimizer enabled with 1,000,000 runs, source files `Bridge2.sol` + `Signature.sol`, creator
  `0x1D4c01E15a637cB3cbaF86ffBb02e5A260D01fbc`, deployed "2 yrs 247 days ago" (≈ 2023-12-01) —
  i.e. three days after the repository HEAD. Deployed bytecode is 19,394 bytes.
  **Licence contradiction:** Arbiscan's metadata labels the contract MIT; the repo's SPDX header says
  `UNLICENSED`. The Etherscan label is submitter-chosen; the SPDX header is the author's.
  **UNKNOWN:** whether the deployed bytecode is byte-identical to repo HEAD. The file set, name,
  compiler and deployment date are all consistent with it, but I did not recompile and compare.
- **Audits:** Zellic, two reports ("First report" and "Final report") linked from the docs; scope is
  "the bridge and its logic in relation to the L1 staking." Dates not stated on the page.
- Not a company holding an asset — the escrow is a contract with no owner. This is the only one of
  the five whose safety is not a legal promise.

### 4. EVIDENCE

| claim | source | accessed |
|---|---|---|
| ">2/3 of staking power" for deposits and withdrawals; dispute period during which the bridge can be locked; cold-wallet 2/3 to unlock; 1 USDC withdrawal gas fee; Zellic audit | https://hyperliquid.gitbook.io/hyperliquid-docs/hypercore/bridge.md | 2026-08-04 |
| Bridge2 address; 5 USDC minimum ("it will not be credited and be lost forever"); withdrawal handled entirely by validators, 3–4 min; EIP-712 `WithdrawAction3`; `batchedDepositWithPermit` | https://hyperliquid.gitbook.io/hyperliquid-docs/for-developers/api/bridge2 | 2026-08-04 |
| Contract structure: `Pausable, ReentrancyGuard`; hot/cold validator set hashes; lockers; finalizers; `disputePeriodSeconds`; `invalidateWithdrawals`; `voteEmergencyLock`; `emergencyUnlock`; no proxy | https://raw.githubusercontent.com/hyperliquid-dex/contracts/master/Bridge2.sol | 2026-08-04 |
| 10k HYPE self-delegation locked 1 year; 1-day delegation lockup; 7-day unstaking queue, max 5 pending; jailing by peer vote; **"There is currently no automatic slashing implemented"** | https://hyperliquid.gitbook.io/hyperliquid-docs/hypercore/staking.md | 2026-08-04 |
| Audits: Zellic, first + final report | https://hyperliquid.gitbook.io/hyperliquid-docs/audits | 2026-08-04 |
| Verified Exact Match, `Bridge2`, solc 0.8.9, 1e6 optimizer runs, creator, deploy age, licence label MIT | https://arbiscan.io/address/0x2df1c51e09aecf9cacb7bc98cb1742757f163df7 | 2026-08-04 |
| Validator set: 34 total / 27 active, 436,005,726 HYPE, Hyper Foundation 1–5 = 212,971,320 HYPE | `POST https://api.hyperliquid.xyz/info {"type":"validatorSummaries"}` | 2026-08-04 |
| TVL $5,906,458,452 split Arbitrum $421,919,062 / Hyperliquid L1 $5,484,539,389; description naming CCTP | https://api.llama.fi/protocol/hyperliquid-bridge · https://api.llama.fi/tvl/hyperliquid-bridge | 2026-08-04 |
| Native USDC + CCTP V2 on Hyperliquid | https://www.circle.com/blog/native-usdc-cctp-v2-are-coming-to-hyperliquid-what-you-need-to-know · https://www.circle.com/multi-chain-usdc/hyperevm | 2026-08-04 |
| Repo metadata, HEAD, tree | https://api.github.com/repos/hyperliquid-dex/contracts · /contents/ | 2026-08-04 |
| **All `[on-chain]` readings** | `eth_call` / `eth_getCode` against `https://arbitrum-one-rpc.publicnode.com` | 2026-08-04 |

### 5. WHAT LOOKS UNNAMEABLE

- **Endogenous verification.** The set that signs withdrawals is the set that secures the
  destination chain, so bridge security *is* chain security rather than an added assumption. This is
  the single most important property of a native L1 bridge and `Xm` cannot express it.
- **A dispute window as a safety parameter.** 200 seconds during which an honest locker can stop a
  fraudulent withdrawal. This is not `Wq` (rationing scarce exit liquidity) and not `Oa` (no
  assertion, no bond, no adjudicator) — it is a veto window.
- **A hot/cold key split within one authority.** The same validator set holds two distinct sets of
  keys with different powers: hot keys sign routine flow, cold keys invalidate withdrawals and
  re-seat the validator set. There is no vocabulary for "the same principals, two escalation tiers."
- **Named emergency roles (`lockers`, `finalizers`)** that are neither owners nor governance.
- **Stake that secures without being slashable.** Hyperliquid has jailing but no automatic slashing.
  `Bs` means "slashable first-loss capital," and there is nothing here to slash. A symbol for
  *reputational / control-value stake without a loss path* is missing.
- **Stake concentration as a live security parameter.** A 2/3 threshold means nothing without the
  distribution behind it; 48.85% in one operator family is the whole story and no symbol carries it.
- **Coexisting supplies of one asset with different trust models.** $421.9m via escrow, $5.48b via
  canonical CCTP issuance, both denominated USDC on the same chain, fungible to the user.
- **A destination "representation" that is a ledger balance, not a token.** `Xf` presumes a
  transferable representation.

### 6. DELTA

1. **The rank basis is 93% mis-attributed.** The corpus reads "#4 in 'Bridge' by TVL: $5,893.6m
   between Hyperliquid L1 and Arbitrum." The escrow contract holds **$421.86m**; the other
   **$5.48b** is native CCTP-issued USDC on Hyperliquid that never crossed this bridge
   `[on-chain + DefiLlama chain split]`. Any later stage that treats "$5.9b of bridge honeypot" as a
   fact will be wrong by an order of magnitude. The rank ordering itself is unaffected.
2. **`Bs` should be dropped or heavily qualified.** The corpus marker already says validator stake
   "is not posted specifically as bridge first-loss capital." It is worse than that: the docs state
   **"There is currently no automatic slashing implemented"** — there is no loss path at all, only
   jailing by peer vote and a 7-day unstaking queue. `Bs` as written (slashable first-loss capital)
   is simply not instantiated here.
3. **`Wq` is misapplied but there is a real queue nearby.** The corpus notes `Wq` misses the purpose
   of the 200-second dispute window. Separately, there *is* a genuine `Wq`-shaped object in this
   system — the 7-day HYPE unstaking queue with a cap of 5 pending withdrawals — but it belongs to
   staking, not to the bridge, and the corpus records neither.
4. **The dispute period is now a hard number.** `disputePeriodSeconds() = 200`,
   `blockDurationMillis() = 350`, `epoch() = 7` `[on-chain]`. These are measurable, not narrative.
5. **The corpus's third residue item is confirmed as fact, not conjecture.** "Native issuance
   coexisting with a legacy escrow bridge for the same asset" is now the dominant regime, at a 13:1
   ratio. Promote it from residue-observation to measurement.
6. **Stake concentration is unrecorded.** Five Hyper Foundation validators hold 48.85% of stake. A
   >2/3 threshold with a 48.85% bloc means one operator family can unilaterally block every
   withdrawal and every validator-set update.
7. **Repo provenance is weaker than "has a repo" suggests.** Two files, no README, no LICENSE, SPDX
   `UNLICENSED`, untouched since 2023-11-28, while the deployed contract carries an MIT label on
   Arbiscan. Byte-identity to HEAD is **UNKNOWN**.

---

## Binance Bitcoin (BTCB)

### 1. WHAT IT DOES

A holder gives up bitcoin by depositing it to Binance.com, where it becomes an exchange account
balance; they then withdraw "BTC" over the BSC network, and what arrives is BTCB — an 18-decimal
BEP-20 on BNB Chain. There is no on-chain source-side event at all: the debit is a row in Binance's
internal ledger, and the credit is a transfer of BTCB that Binance's owner key already minted or
mints. What redeems it is depositing BTCB back to Binance and withdrawing BTC over the Bitcoin
network. Binance's own description is a swap rather than a mint/burn — "their Bitcoin remains locked
and can be redeemed by depositing BTCB back." What must be trusted is Binance: that the bitcoin
exists, that the single externally-owned account holding the token's `owner` role does not mint
against nothing, that withdrawals stay open, and that the account is not frozen. This is the thinnest
of the five: the token contract contains no pause, no blacklist, no proxy, no multisig and no
verification of any kind, so the *only* on-chain constraint is that one key can mint arbitrarily.

### 2. DESIGN

**Supply topology — custodial wrap settled by an exchange-internal ledger entry.** Nothing is locked
in a contract on either side. Binance states the peg is achieved by holding an equivalent amount of
bitcoin in multi-signature cold storage, and warns that "the amount of locked BTC may not be
precisely the same as the wrapped BTC due to the delays caused by the extensive auditing process."

**Verification model — none. Single-company.** No message, no proof, no verifier, no threshold.

**Mint / burn authority — one externally-owned account.** The contract is Binance's standard
`BEP20Token` template (solc 0.5.16, Apache-2.0, verified Exact Match on BscScan, **not a proxy**).
`mint(uint256)` is `onlyOwner`; `burn(uint256)` burns the caller's balance; `transferOwnership` /
`renounceOwnership` exist. `owner() = getOwner() = 0xf68a4b64162906eff0ff6ae34e2bb1cd42fef62d`, and
**`eth_getCode` on that address returns empty — it is an EOA, not a multisig contract**
`[on-chain]`. `totalSupply() = 65,300.96996478 BTCB` at 18 decimals `[on-chain]`.

**Attestation / proof-of-reserve regime — two distinct things, and they are frequently confused.**
- `binance.com/en/proof-of-collateral` is the **B-token page** and carries an explicit disclaimer:
  "this page only refers to Binance Bridge pegged tokens. This is not the proof of reserve page for
  Binance.com." Its BTC row reports **100%**, with **Proof of Assets 68,200 BTC** at a single
  published Bitcoin address (`3lyjfcfhpxyjrem…2jkn69lweykzexb`), against wrapped supplies of
  **2,900 BTC on Ethereum** (`0x9be89d2a…c22541`), **128 on BEP2** (`bnb1akey87kt0r8…`) and
  **65,222 on BEP20** (`0x7130d2a1…3ead9c`), plus "Pioneer Burn 24 BTC" and "Token Recovered 49
  BTC." 97 tokens are covered in total.
- `binance.com/en/proof-of-reserves` is the **exchange's customer-liability** PoR: a monthly
  snapshot (latest 01/07/26 00:00 UTC, BTC block height 956,140) using a Merkle tree with a
  zk-SNARK circuit, reporting a BTC ratio of **100.08%** (net account balances 640,295.68 BTC;
  on-chain wallet balance 640,780.255). **This says nothing about BTCB.**
- **UNKNOWN:** whether any independent auditor attests specifically to the BTCB collateral. I found
  no such report. The Proof of Collateral page is a self-published address listing.

**Freeze / blacklist powers — none on-chain.** The contract has no `pause`, no `blacklist`, no
freeze and no forced transfer; BscScan's source view and the function list confirm mint/burn/
transfer/approve/owner only. Freezing happens at the exchange account layer, which is invisible to
the token.

**Control plane — a single key.** Non-upgradeable contract, no timelock, no multisig, no guardian.
`transferOwnership` and `renounceOwnership` are the entire governance surface.

### 3. REPO

- **There is no public source repository for BTCB.** Not a stale one — none. The canonical source is
  the verified contract on BscScan at `0x7130d2a12b9bcbfae4f2634d864a1ee1ce3ead9c`, contract name
  `BEP20Token`, compiler `v0.5.16+commit.9c3226ce`, optimization enabled (200 runs), declared
  licence **Apache-2.0**, "Source Code Verified — Exact Match," not a proxy.
- Deployed contracts trivially match "the repo" because the deployed contract *is* the only
  artefact. There is no specification, no whitepaper describing the mechanism, and no audit.
- **This bridge is a company holding an asset**, and it is the purest instance of the type.
  - *Verifiable on-chain:* BTCB total supply (65,300.96996478); the owner address and the fact that
    it is a single EOA; that the owner can mint without limit; every transfer; the balance of the
    Bitcoin address Binance publishes.
  - *Legal promise only:* that the published Bitcoin address is Binance's; that its 68,200 BTC is
    unencumbered and matched to pegged-token liabilities and not double-counted against the
    exchange's 640,780 BTC customer reserve; that BTC withdrawals will remain open; and that the
    single owner key is controlled by an internal process. The BNB Chain blog's own warning that
    locked BTC "may not be precisely the same as the wrapped BTC" is a disclosed peg tolerance with
    no stated bound.

### 4. EVIDENCE

| claim | source | accessed |
|---|---|---|
| "BTCB is a pegged bitcoin … issued by Binance.com with a 1:1 peg to BTC locked on the Bitcoin blockchain"; custodial issuance; multi-sig cold storage; Proof of Assets page; auditing-delay caveat; contract address | https://www.bnbchain.org/en/blog/btcb-on-binance-smart-chain-101 | 2026-08-04 |
| Contract: `BEP20Token`, solc 0.5.16, Apache-2.0, not a proxy, mint/burn present, **no pause / freeze / blacklist / upgrade**, 18 decimals | https://bscscan.com/token/0x7130d2a12b9bcbfae4f2634d864a1ee1ce3ead9c · https://bscscan.com/address/0x7130d2a12b9bcbfae4f2634d864a1ee1ce3ead9c#code | 2026-08-04 |
| Proof of Collateral: disclaimer that it is *not* the exchange PoR; BTC 100%; 68,200 BTC Proof of Assets address; wrapped 2,900 ETH-side / 128 BEP2 / 65,222 BEP20; Pioneer Burn 24; Token Recovered 49; 97 tokens | https://www.binance.com/en/proof-of-collateral (reached via https://www.binance.com/en/collateral-btokens) | 2026-08-04 |
| Exchange PoR: monthly snapshots, latest 01/07/26 UTC @ BTC block 956,140; Merkle tree + zk-SNARK; BTC ratio 100.08%; "we are specifically referring to those assets that we hold in custody for users" | https://www.binance.com/en/proof-of-reserves | 2026-08-04 |
| DefiLlama: category Bridge, chain Bitcoin, methodology "BTC on btc chain", url = the collateral page, TVL $4,371,846,939 | https://api.llama.fi/protocol/binance-bitcoin · https://api.llama.fi/tvl/binance-bitcoin | 2026-08-04 |
| **All `[on-chain]` readings** | `eth_call` / `eth_getCode` against `https://bsc-rpc.publicnode.com` | 2026-08-04 |
| Binance's own launch blog (`binance.com/en/blog/all/347360878904684544`) — **could not be retrieved**; returns HTTP 202 with an empty body to StealthyFetcher | — | 2026-08-04 |

### 5. WHAT LOOKS UNNAMEABLE

- **Exchange-internal ledger transfer as the settlement mechanism.** The "bridge" is a database row
  plus a token transfer. There is no source-domain transaction to point at.
- **A single externally-owned account as unbounded mint authority** for a $4.2b liability. The
  control-and-authority group has no symbol whose weakest reading is this weak.
- **A self-published reserve address listing with a disclosed but unbounded peg tolerance.** `At`
  cannot express "we publish an address, and by the way the numbers may not match."
- **Two reserve claims over the same custodian that must not be added together** — 68,200 BTC of
  pegged-token collateral and 640,780 BTC of exchange customer reserve, published on two pages with
  a disclaimer between them. Nothing names the risk that they are the same coins.
- **Off-chain freeze.** Binance can freeze an account and refuse redemption without any on-chain
  action; `Fz` names an on-chain power that does not exist here.
- **Redemption as an exchange withdrawal**, subject to account standing, KYC tier, network status
  and unilateral suspension.
- **One asset, three pegged representations** (Ethereum, BEP2, BEP20) drawn against one reserve pool.

### 6. DELTA

1. **`Gp` is wrong.** The corpus gives BTCB `Gp` (emergency guardian or pause). **The contract has
   no pause function.** BscScan's verified source and function list show mint, burn, transfer,
   approve, owner, transferOwnership, renounceOwnership and nothing else. Whatever emergency power
   Binance has is exercised at the exchange, not on the token.
2. **The `Fz` marker is wrong for the same reason.** "Issuer can freeze" is false on-chain — no
   blacklist, no forced transfer. The freeze exists at the account layer.
3. **`Aw` is at best off-chain.** There is no on-chain permission or identity gate of any kind; the
   only restriction is `onlyOwner` on `mint`, which is an issuer-side, not a user-side, gate.
4. **The mint authority is a single EOA.** `owner() = getOwner() = 0xf68a4b64162906eff0ff6ae34e2bb1cd42fef62d`,
   `eth_getCode` empty `[on-chain]`. Not a multisig, not a timelock, not a contract.
5. **The TVL is not BTCB.** DefiLlama's $4,371,846,939 tracks the **68,200 BTC** in Binance's
   published Proof-of-Assets address — i.e. *all* Binance-Peg BTC across BEP20, BEP2 and Ethereum —
   not the 65,301 BTCB on BNB Chain (≈$4.20b at the same BTC price). The corpus's "$4,363.3m"
   figure is right, but it is the reserve for a wider liability set than the named token.
6. **Ranking basis holds.** DefiLlama `binance-bitcoin` = $4,371,846,939 vs the corpus's $4,363.3m.
   Rank #5 stands.

---

## Cross-cutting DELTA: the "identical decomposition" claim

The corpus asserts, in `identicalClaimedByLane` and in `categoryResidue`, that WBTC, Coinbase Bridge
and BTCB "decompose to EXACTLY the same symbol set as each other." **Its own arrays contradict it:**

| | At | Aw | Gp | Rd | Xf | Tg | Up |
|---|---|---|---|---|---|---|---|
| WBTC | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | — |
| Coinbase | ✓ | ✓ | ✓ | ✓ | ✓ | — | ✓ |
| BTCB | ✓ | ✓ | ✓ | ✓ | ✓ | — | — |

BTCB is a proper subset of each of the other two; WBTC and Coinbase differ in exactly one
control-plane symbol, `Tg` versus `Up`. **The arrays are right that the three are not identical and
wrong about how they differ. The prose is simply wrong.** What the designs actually support, all
verified on-chain on 2026-08-04:

| control-plane fact | WBTC | Coinbase | BTCB |
|---|---|---|---|
| upgradeable proxy | **no** (non-upgradeable 0.4.24 token) | **yes** (`FiatTokenProxy` → `0x7458bfDC…`, `upgradeTo`) | **no** (non-proxy 0.5.16) |
| timelock | **no** (3× `MultiSigWallet`, no `secondsTimeLocked`) | **no** (`owner` is an EOA) | **no** (`owner` is an EOA) |
| multisig quorum on admin | **yes** (6-of-10 Controller, 5-of-9 Members) | **no** (single EOAs) | **no** (single EOA) |
| pause | **yes** (`PausableToken` via Controller) | **yes** (`pause()`, named `pauser`) | **no function exists** |
| blacklist / forced transfer | **no** | **yes** (`blacklist`/`unBlacklist`) | **no** |
| swappable mint-authority contract | **yes** (`setFactory`/`setMembers`) | n/a (minters via `masterMinter`) | no |
| on-chain permission registry | **yes** (Members: 47 merchants, 1 custodian) | no (minter allowances only) | no |

**The reading the evidence supports:** the correct ordering is not `BTCB ⊂ {WBTC, Coinbase}` with a
one-symbol split. It is that **BTCB has the weakest control plane of the three by a wide margin — one
EOA that can mint without limit, and no pause, freeze, proxy, timelock, quorum or registry** — while
**Coinbase has the strongest set of powers** (upgrade + freeze + pause) held by **the weakest
custody of those powers** (single EOAs), and **WBTC has the most distributed custody of powers**
(two independent multisig quorums and an on-chain merchant/custodian registry) with **the fewest
powers** (pause only, no freeze, no upgrade). Assigning `Tg` to WBTC and withholding it from the
other two inverts the one dimension on which WBTC is genuinely different — it is quorum, not delay.
Assigning `Gp` uniformly hides the fact that one of the three cannot pause at all. And the corpus's
headline claim — that the top three bridges carry **no verification element** because a company holds
the asset — is **confirmed without qualification**: none of the three contains any verification
mechanism, and for WBTC, BTCB and five of Coinbase's six source assets, no verification mechanism is
even constructible, because the source domain cannot execute code.

Evidence for every cell above is in the per-application EVIDENCE tables; the on-chain readings were
taken with `eth_call` / `eth_getCode` / `eth_getStorageAt` against
`ethereum-rpc.publicnode.com` and `bsc-rpc.publicnode.com` on 2026-08-04. **The corpus was not
edited.**
