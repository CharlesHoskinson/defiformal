# Category 11 — Reserve-backed / fiat stablecoin issuers: Stage-1 research

**Lane:** Stage 1 (research only). **Compiled:** 2026-08-04. **Access date for every URL below is 2026-08-04 unless a different date is stated inline.**

**Note on source quality for this category.** This is the best-sourced category in the project and also the most misleading one to source. Four of the five issuers publish a signed third-party examination report every month or quarter, two are inside SEC-reporting public companies (Circle Internet Group, PayPal Holdings), one files a regulator-submitted offering document (Tether's El Salvador CNAD *Relevant Information Document*), and one publishes a MiCA-mandated Article 51 white paper (Paxos Issuance Europe Oy). All five have verified, readable contract bytecode on Ethereum. So the *documentary* record is excellent — I was able to pull the BDO ISAE 3000R report on Tether's reserve, the KPMG examination of USD1, Circle's Deloitte-audited 10-K and its monthly USDC Reserve Report, and Paxos's MiCA white paper, and to read every deployed implementation contract's source and every privileged role holder directly off-chain. The trap is that the documents describe a **legal** machine and the contracts describe a **control** machine, and the two barely touch: no attestation report names a bank, no contract knows what a T-bill is, and the only artifact that connects them is a PDF. Where a claim below is not in a primary document or on-chain, it is marked **UNKNOWN**; I have not repaired gaps with press or aggregators. Two things I could not confirm at a primary source and therefore did not assert: (a) the named banking counterparties of any of the five, and (b) a machine-counted total of blacklisted addresses (a full `eth_getLogs` sweep of USDT's `AddedBlackList` was rate-limited off by public RPC; I report Tether's own published figures instead and label them as issuer claims).

---

## Tether USDT

### 1. WHAT IT DOES

USDT is a transferable receipt for an unsecured, on-demand claim against a single private company. As of 2026, the customer-facing issuer of fiat-denominated Tether tokens is **Tether International, S.A. de C.V.**, a company incorporated under the laws of El Salvador and authorised as a stablecoin issuer by El Salvador's Comisión Nacional de Activos Digitales (CNAD), DASP registration PSAD-0028. The claim is a claim on the *face value* only: the RID states that "Holders of Tether Tokens are not entitled to any increases in value of the Reserves in excess of the face value of the Tether Tokens (less fees)" — the reserve surplus belongs to Tether, not to holders. The right to present that claim is not a property of holding the token; it is a property of being one of **819 KYC Verified Customers** (as of 2026-02-16). Everyone else holds a bearer instrument whose only exit is the secondary market. For those 819, the minimum redemption is **US$100,000**, the fee is **the greater of US$1,000 or 0.1%**, and redemption settles by fiat wire to the customer's bank account. There is no published settlement-time commitment — the RID gives a six-step lifecycle with no SLA, so **redemption latency is UNKNOWN as a contractual matter**. Tether may delay or suspend redemption if it determines a Prohibited Use, if directed by any government, if the account is under investigation, or on suspicion of fraud, and it "maintains the sole discretion to approve or reject" applications to become a customer at all. If the issuer cannot pay, the token is a *refund liability* under IFRS 9 (the attestation's own words) — an unsecured contractual obligation of an El Salvadoran company, with disputes routed to confidential BVI-law arbitration seated in London before a sole arbitrator. There is no deposit insurance, no trust, no stated security interest, and no segregation covenant; the RID says only that Tether "primarily holds the Reserves with various third parties including banks and licensed financial institutions."

### 2. DESIGN

**Token contract (Ethereum).** `TetherToken` at `0xdAC17F958D2ee523a2206206994597C13D831ec7`, Solidity `v0.4.18`, verified (partial match) on Blockscout since 2019-04-18, **no license declared**. Ethereum supply read on-chain 2026-08-04: `92,056,579,574.486405` USDT (6 decimals). Inheritance is `TetherToken is Pausable, StandardToken, BlackList`, all rooted in a single `Ownable` — there is **no role separation whatsoever**. Every privileged function is `onlyOwner`:
- `issue(uint amount)` / `redeem(uint amount)` — mint to and burn from the owner's own balance. Mint/redeem are treasury operations, not user-facing.
- `addBlackList(address)` / `removeBlackList(address)` / `destroyBlackFunds(address)` — freeze, unfreeze, and **irreversibly destroy** a blacklisted balance (`DestroyedBlackFunds` event). There is no forced *transfer*, only destruction.
- `pause()` / `unpause()` — global transfer halt.
- `deprecate(address _upgradedAddress)` — the upgrade path. It is not a proxy: it sets `deprecated = true` and forwards `transfer`, `transferFrom`, `balanceOf`, `approve`, `allowance` to a new contract implementing `UpgradedStandardToken`. Read on-chain: `deprecated() == false`.
- `setParams(uint newBasisPoints, uint newMaxFee)` — an **owner-settable per-transfer fee**, capped by `maximumFee`. Read on-chain: `basisPointsRate == 0`, `maximumFee == 0`. Dormant, not absent.

**Key custody.** `owner()` is `0xC6CDE7C39eB2f0F0095F41570af89eFC2C1Ea828`, a contract named `MultiSigWallet` (Solidity 0.4.16). Read on-chain: **6 owners, `required() == 3`** — a 3-of-6 multisig with **no timelock**. So the freeze key, the burn key, the mint key, the pause key, the fee key and the upgrade key are the same 3-of-6 key.

**Multi-chain.** USDT exists on Tron, Ethereum, Solana, Avalanche, TON and others; the RID says the set is "as determined by Tether." Supply moves between chains by Tether burning on one and issuing on another under off-chain authorisation. There is **no message verification and no bridge contract** in this path — it is an operator action.

**Attestation regime.** Quarterly. The Q2 2026 report is an **ISAE 3000 (Revised) reasonable-assurance** engagement by **BDO Advisory Services S.r.l., Milan** (partner Lelio Bigogno), dated 2026-07-31, engaged by Tether Global Investments Fund SICAF SA, on the *Financial Figures and Reserves Report* of Tether International S.A. de C.V. as of 2026-06-30 23:59 UTC. Procedures included bank/depositary confirmation letters, third-party inventory and assay testing of precious metals on a sample basis, blockchain-to-ledger reconciliation, and collateral verification for a sample of secured loans. Explicit scope limits: point-in-time only; the Notes are outside the engagement; **no assurance is given on the going-concern assessment**; valuations "do not reflect unexpected and extraordinary market conditions, or the case of key custodians or counterparties experiencing substantial illiquidity."

**Reserve composition at 2026-06-30 (US$, from the attested report).** Total assets **187,751,426,411**; total liabilities **183,641,897,215**, of which **183,622,105,630** is digital tokens issued; surplus **4,109,529,196**. Gross contractual redemption value of all tokens issued: **184,588,527,295** (this figure is net of the 10 bp redemption fee, by definition). Tokens held by the company outside its treasury wallet: 808,077,231.

| Category | US$ |
|---|---|
| U.S. Treasury Bills (WAM < 90d) | 114,960,963,604 |
| Overnight reverse repo (1d, UST-collateralised, issuer/guarantor ≥ A-3) | 18,625,552,412 |
| Term reverse repo (residual WAM < 90d) | 6,993,428,950 |
| Non-US Treasury Bills (WAM < 360d) | 22,374,689 |
| Cash & bank deposits | 40,307,440 |
| **Subtotal cash equivalents** | **140,642,627,095** |
| Corporate bonds (residual WAM > 360d) | 8,711,171 |
| Precious metals (LBMA gold bars @ XAU 4,008.02/oz) | 18,838,357,171 |
| Bitcoin (on-chain, company-controlled wallets @ 58,642.15/BTC) | 5,801,630,681 |
| Public equities (indirect gold/bitcoin/other exposure) | 3,761,438,892 |
| Other investments | 5,244,911,675 |
| Secured loans (over-collateralised, margin-call/liquidation) | 13,453,749,726 |
| **Total** | **187,751,426,411** |

Cash and bank deposits are **0.02% of reserve**. Roughly **$23.6B (12.6%) is gold, bitcoin, equities, "other investments" and secured loans** — assets whose realisable value in a redemption run is a judgement, and the auditor expressly declines to assure the going-concern judgement that supports them.

**Custody and banking.** The report names no custodian and no bank. The RID says only "various third parties including banks and licensed financial institutions." **Named banking and custody relationships: UNKNOWN from primary sources.**

**Freeze regime.** The RID reserves the right to "freeze the Tether Tokens held in external wallets for which Tether does not hold private keys" at the behest of law enforcement, regulatory or government agencies. Tether's own newsroom claims cooperation with "more than 340 law enforcement agencies in 65 countries" and more than $4.4bn in assets frozen since launch; on 2026-04-23 it announced a single freeze of more than $344M across two addresses in coordination with OFAC. These are **issuer claims**, not independently attested. A machine-counted address total is **UNKNOWN** (see the note on source quality).

**Adjacent structure worth recording.** On 2026-01-27 Tether launched **USAT**, a separate US token issued by **Anchorage Digital Bank** (OCC-supervised) with Cantor Fitzgerald as reserve custodian, under the GENIUS Act. USAT and USDT have separate reserves, separate issuance and separate redemption rails. USAT is *not* USDT and is not part of this record beyond noting that USDT's answer to US regulation was to create a different token with a different obligor.

### 3. REPO

**There is no canonical public source repository for the USDT ERC-20 contract.** Tether does not publish one. `github.com/tethercoin/USDT` (README + `TetherToken.sol`, 3 commits, 17 stars, no license stated) is an unofficial mirror that itself points back to Etherscan as the authority; `github.com/tetherto/Tether-Near` is a chain-specific port under the real `tetherto` org. The source of truth for USDT-on-Ethereum is the **verified bytecode**, not a repo.

- Inspected artifact: verified source served by Blockscout for `0xdAC17F958D2ee523a2206206994597C13D831ec7`, contract `TetherToken`, compiler `v0.4.18+commit.9cf6e910`, verified 2019-04-18, `license_type: none`, partial (metadata-hash) match, 14,888 chars in a single flattened file.
- Layout: one file, six contracts — `SafeMath`, `Ownable`, `ERC20Basic`/`ERC20`, `BasicToken`/`StandardToken`, `Pausable`, `BlackList`, `UpgradedStandardToken`, `TetherToken`.
- **On-chain vs legal promise.** On-chain: transfer accounting, a blacklist, a destroy, a pause, a fee dial, a forwarding upgrade, and a 3-of-6 key. Legal promise: everything else — that the token is worth a dollar, that there is a reserve, that the reserve is liquid, that you may redeem, that the issuer will still exist. The contract cannot observe a single one of those and contains no reference to a reserve.

### 4. EVIDENCE

- Relevant Information Document, Tether International S.A. de C.V., dated 2026-02-20 (issuer, CNAD authorisation PSAD-0028, 819 KYC Verified Customers as of 2026-02-16, US$100,000 minimum, greater-of-$1,000-or-0.1% redemption fee, 0.1% purchase fee, face-value-only claim, suspension grounds, freeze of external wallets, six-step lifecycle, BVI-law arbitration seated in London, certifier TR Capital S.A. de C.V., counsel Dentons El Salvador): https://tether.to/public/Relevant_Information_Document_-_Tether_International,_S.A._de_C.V..pdf
- BDO Advisory Services S.r.l., *Assurance Report according to ISAE 3000R on the Financial Figures and Reserves Report*, Tether International S.A. de C.V. as of 2026-06-30, signed Milan 2026-07-31 (all figures in the table above, procedures, emphasis-of-matter and scope limitations, IFRS 9 refund-liability classification, New York class action disclosure): https://assets.ctfassets.net/vyse88cgwfbl/2kYf7r64h3tzwiu6F0CbUB/2997abd2f11ecea74a21528048b50707/Opinion___Report_-_Tether_International_Financial_Figure_30-06-2026.pdf
- Tether announcement of Q2 2026 results (attestation firm, headline figures, publication date 2026-07-31): https://tether.io/news/tether-posts-strong-q2-performance-generates-1-5b-net-operating-profit-maintains-4-11b-reserve-buffer-and-expands-gold-holdings-to-more-than-146-tons/
- Verified contract source and metadata, Blockscout API: https://eth.blockscout.com/api/v2/smart-contracts/0xdAC17F958D2ee523a2206206994597C13D831ec7
- On-chain reads (Ethereum JSON-RPC, 2026-08-04): `owner()=0xC6CDE7C39eB2f0F0095F41570af89eFC2C1Ea828`; `MultiSigWallet.getOwners()` = 6 addresses; `required()=3`; `deprecated()=false`; `basisPointsRate()=0`; `maximumFee()=0`; `paused()=false`; `totalSupply()=92056579574486405`.
- Tether freeze announcement, 2026-04-23: https://tether.io/news/tether-supports-freeze-of-more-than-344-million-in-usdt-in-coordination-with-ofac-and-u-s-law-enforcement/
- Tether USAT launch (separate issuer Anchorage Digital Bank, GENIUS Act): https://tether.io/news/tether-announces-the-launch-of-usat-the-federally-regulated-dollar-backed-stablecoin-made-in-america/
- Unofficial mirror repo (checked to establish that it is *not* canonical): https://github.com/tethercoin/USDT

### 5. WHAT LOOKS UNNAMEABLE

Confirmed, item by item, against the corpus's residue list — and then extended:

1. **The reserve portfolio.** CONFIRMED unnameable. `At` names the BDO PDF. Nothing in the 58 distinguishes $114.96bn of <90-day T-bills from $18.84bn of gold bars from $13.45bn of secured loans, and the difference is the entire instrument.
2. **The obligor.** CONFIRMED. There is no symbol for "an El Salvadoran S.A. de C.V. owes you," and none for creditor priority against it. The attestation's own classification — *refund liability under IFRS 9* — is the single most decision-relevant fact about USDT and has no name.
3. **Redemption as a gated contractual facility.** CONFIRMED and sharper than the corpus states. `Rd` ("direct redemption right") is not merely a poor fit — 819 named counterparties can redeem and roughly half a billion holders cannot. `Rd` asserts a universal right the system denies.
4. **Banking and correspondent relationships.** CONFIRMED unnameable, and now unobservable too: the primary documents no longer name any bank at all.
5. **The equity buffer.** CONFIRMED. "Holders are not entitled to any increases in value of the Reserves in excess of face value" is a seniority statement — a one-line tranche waterfall with the holders senior at par and the shareholder taking all residual. `Tr` exists in the vocabulary and is not used here because the waterfall is off-chain; that is exactly the gap.
6. **Chain-swap by operator fiat.** CONFIRMED not `Xf`. There is no verifier, no message, no lock, no proof: an employee burns here and issues there.
7. **Attestation vs audit; jurisdiction; regime.** CONFIRMED. Note the vocabulary cannot express the difference between *limited* and *reasonable* assurance, nor between an examination and an audit, nor that the going-concern assumption is carved out of the opinion.
8. **The law-enforcement trigger for `Fz`.** CONFIRMED. Law `L28` demands "named authority + enumerated triggers + appeal path + holder disclosure"; USDT satisfies none of the four in a machine-checkable way, and nothing in the model records that.

**New items the corpus did not list:**

9. **A dormant owner-settable transfer fee.** `setParams(basisPointsRate, maximumFee)` lets the owner impose a fee on every transfer of a $92bn (Ethereum-side) instrument. It reads zero today. No symbol names a *latent* mechanism, and the distinction between "absent" and "set to zero by a 3-of-6 key" is the whole risk.
10. **`destroyBlackFunds` is not `Fz`.** Freeze, seize-and-destroy, and forced-transfer are three different powers with three different consequences for a holder. USDT has freeze and destroy and no forced transfer; USD1 has all three. `Fz` collapses them.
11. **The upgrade is a forwarding deprecation, not a proxy.** `Up` says "mutable implementation proxy." USDT's `deprecate()` leaves storage behind and forwards five ERC-20 entry points to a new contract — a different failure surface (partial forwarding, stale views) that `Up` does not distinguish.
12. **Assurance carve-outs as a first-class object.** The auditor assures the arithmetic and explicitly declines the solvency judgement. `At` has no place to record what the attester refused to say.

**Verdict on the corpus's central claim, for USDT:** upheld without qualification. Every symbol assigned is control-plane (`Fz`, `Up`, plus the unassigned-but-present `Gp`) or attestation (`At`), and the two forced symbols (`Ps`, `Rd`) name mechanisms that do not exist.

### 6. DELTA

- **`Gp` is missing and should be present.** `pause()`/`unpause()` are live `onlyOwner` functions on the USDT contract. The corpus assigns `Gp` to USDC only. This is a coding inconsistency, not a design difference (see the cross-cutting note under PYUSD §6).
- **`Aw` is missing on the same argument the corpus used to assign it to USDC.** The corpus assigns USDC `Aw` for "the gate on Circle Mint access." Tether's identical gate (KYC Verified Customers, 819 of them, sole discretion to reject) is not coded.
- **The issuer is stale.** The corpus says "Tether Limited" and "jurisdiction (El Salvador)" loosely. As of the 2026-02-20 RID the customer-facing issuer of USD₮ is **Tether International, S.A. de C.V.**, an El Salvador company wholly owned by Tether Global Investment Fund SICAF S.A. and Tether Operations S.A. de C.V., authorised by CNAD. The BDO opinion is addressed to that entity and to no other.
- **The attestation is stronger than the corpus implies.** The corpus treats `At` as naming "the quarterly BDO report" and flags "attestation vs audit as a distinction." The Q2 2026 engagement is **ISAE 3000 (Revised) *reasonable* assurance**, which is the same assurance level as an audit opinion, on a non-GAAP subject matter. The interesting gap is not limited-vs-reasonable; it is that reasonable assurance on a schedule of assets says nothing about whether the entity can pay, and the auditor says so in terms.
- **Reserve composition has moved.** The corpus's residue text lists "T-bills, reverse repo, gold, bitcoin, secured loans, and corporate equity holdings." That remains right in kind. New at 2026-06-30: the surplus has halved from US$6.338bn (2025-12-31) to US$4.110bn, driven by a US$3.171bn negative financial result in H1 2026 offset by US$943m of net capital movements; bitcoin is marked at $58,642.15/BTC and gold at $4,008.02/oz.
- **A `Tr`-shaped fact is uncoded.** "Holders are not entitled to increases in Reserves above face value" is a declared seniority, and the corpus records it only as prose residue.

---

## Circle USDC

### 1. WHAT IT DOES

USDC is a transferable receipt for a claim that Circle asserts is a *property* claim rather than a contractual one. It is issued and redeemed by **Circle Internet Financial, LLC** (US) and **Circle Internet Financial Europe SAS** (EEA holders). Circle's position, stated in its 10-K, is that it holds "only bare legal title" to the reserve and "no beneficial interest or property rights," so the reserve "should not be considered property of our bankruptcy estate" — while conceding in the same paragraph that no court has ever tested this, that holders could face automatic-stay delays even if it holds, and that a US or French court could decide otherwise. Redemption is available only to **Circle Mint** account holders: institutional customers who pass entity KYC, sanctions screening and a suitability check on business type and anticipated minting volume. The USDC Terms make the two-tier structure explicit — "Users Type B are not customers of Circle" and hold only a contingent right conditional on opening an account. For account holders, minting is free, **basic redemption is initiated within two business days and is free**, and **standard redemption is initiated nearly instantly for a nominal fee**; there is no stated minimum. Circle may "decline to process any issuance or redemption without prior notice," may block addresses and freeze the USDC "temporarily or permanently," and warns that a blocked holder "may forfeit any rights associated with your USDC, including the ability to redeem." If Circle cannot pay, the holder's position depends entirely on an untested legal theory about bare legal title; there is no deposit insurance and, until Circle National Trust is fully approved, no perfected security interest.

### 2. DESIGN

**Token contract (Ethereum).** `FiatTokenProxy` at `0xA0b86991c6218b36c1d19D4a2E9Eb0cE3606eB48`. It is a **ZeppelinOS-style transparent proxy**, not EIP-1967: the implementation and admin live in `keccak256("org.zeppelinos.proxy.implementation")` and `...proxy.admin`. Read on-chain 2026-08-04: implementation `0x43506849D7C04F9138D1A2050bbF3A0c054402dd` (23,464 bytes), proxy admin `0x807a96288A1a408dBC13DE2b1d087d10356395d2` (EOA, no code). `version()` returns `"2"`, `currency()` returns `"USD"`, decimals 6, Ethereum supply `49,536,777,415.220915` USDC.

**Role separation** — this is the one genuinely multi-role design in the group. Read on-chain:
- `owner()` `0xFcb19e6a322b27c06842A71e8c725399f049AE3a` (EOA)
- `masterMinter()` `0xE982615d461DD5cD06575BbeA87624fda4e3de17` — a **contract** named `MinterAdmin` (7,667 bytes), which in turn controls per-minter allowances rather than granting mint power to a key
- `blacklister()` `0x0a06be16275b95a7d2567FbdaE118b36c7Da78f9` (EOA)
- `pauser()` `0x4914F61D25e5c567143774B76eDbF4d5109A8566` (EOA)
- `rescuer()` — present in the ABI family; not resolved to a non-zero address in this read
- `paused() == false`

**Attestation regime.** Monthly examination under **AICPA attestation standards**, on management's assertion that the fair value of assets in the USDC Reserve is ≥ USDC in circulation, at two report dates per month. The June 2026 report covers 2026-06-02 and 2026-06-30 and is signed 2026-07-29 by Tamara Schulz, Chief Accounting Officer. The engaging accountant's signature block on page 1 is a rendered image and its firm name is not in the PDF text layer; **the identity of the monthly examiner is therefore UNKNOWN from the report itself.** Circle's transparency page says a "Big Four accounting firm"; the 10-K identifies **Deloitte & Touche LLP** as the company's *financial-statement* auditor since 2023 (opinion signed New York, 2026-03-09) and as auditor of the BlackRock-managed Circle Reserve Fund. Circle's 2022 blog post naming Grant Thornton is stale and should not be cited.

**Reserve composition at 2026-06-30 (US$, from the Reserve Report).** USDC in circulation **73,268,560,097**; total reserve assets **73,344,909,176**.

| | US$ |
|---|---|
| Circle Reserve Fund — U.S. Treasury securities (9 CUSIPs, all maturing 2026-07-02 to 2026-08-20) | 8,524,064,231 |
| Circle Reserve Fund — U.S. Treasury repurchase agreements (overnight lending to global financial institutions, over-collateralised by USTs) | 52,527,000,000 |
| Circle Reserve Fund — cash | 1,003,971,544 |
| Circle Reserve Fund — timing/settlement, net | (137,687,880) |
| **Circle Reserve Fund total** | **61,917,347,895** |
| Cash held at regulated financial institutions | 11,382,256,398 |
| Timing/settlement, net | 45,304,883 |
| **Total** | **73,344,909,176** |

The Circle Reserve Fund is a Rule 2a-7 government money market fund managed by **BlackRock Advisors, LLC**, custodied at **BNY**, available only to Circle, with Circle Internet Financial, LLC holding 100% of the equity interests "on behalf of USDC holders." The 10-K states approximately **88% of reserves** sit in the Fund, the remainder as cash in FBO accounts "primarily with banks designated by the Financial Stability Board" as G-SIBs. **Individual bank names: UNKNOWN** — the reserve report does not list them.

**Circulation accounting — mechanisms with no name.** The Reserve Report defines circulation as total supply on 36 named "USDC Approved Blockchains" *less* three deductions: **Tokens Allowed But Not Issued** (1,380,790,392 at 2026-06-30; an artefact of how USDC is implemented on Algorand, Hedera, Polkadot Asset Hub and Solana), **Access Denied Tokens** (123,219,920), and **Circle Gateway pending burns** (94,358). Plus a footnote: 993,225 USDC is permanently frozen on the deprecated FLOW deployment. The 10-K adds the crucial mechanic: an access denial **does not extinguish the liability** until the segregated reserve funds are transferred to the relevant law enforcement agency, or until the denial is reversed and a redemption is made.

**Cross-chain.** Two distinct mechanisms, both real: **CCTP** (burn on source, attested mint on destination), with **CCTP V2** launched March 2025 adding a fee-generating fast-transfer path; and **Gateway**, launched July 2025, an on-chain utility providing "a unified USDC balance that is instantly accessible across supported blockchains." Gateway holds balances in Circle smart contracts and produces the "pending burns" line above.

**Entities and regulators.** Circle Internet Financial, LLC holds a NYDFS BitLicense and state money-transmitter licences and is a FinCEN-registered MSB; Circle Internet Financial Europe SAS holds a French DASP registration (AMF) and an EMI licence (ACPR); Circle Internet MEA Ltd holds an ADGM FSRA licence; Circle International Bermuda Limited holds a BMA DABA licence and issues USYC. In **December 2025 Circle received OCC conditional approval to establish Circle National Trust**, which is to manage the USDC reserve and "hold a first-priority perfected security interest in the USDC reserve as collateral trustee for the benefit of USDC holders." That is a *future* protection; it is not in force.

**Float economics.** FY2025: reserve income **$2,636,822 thousand**; distribution and transaction costs **$1,661,549 thousand** — i.e. Circle paid out **63%** of the reserve yield to distribution partners, principally Coinbase under the Collaboration Agreement (initial three-year term, auto-renewing). Holders receive nothing.

### 3. REPO

- **`github.com/circlefin/stablecoin-evm`** — the source repository for Circle's EVM stablecoin contracts. **License: Apache-2.0.** Language: Solidity, with Hardhat + Foundry and a TypeScript toolchain (Node 20.9.0, Yarn 1.22.19). Top level: `contracts/`, `test/`, `scripts/`, `doc/`, `lib/`, plus `hardhat.config.ts` and `foundry.toml`. The main implementation is `FiatTokenV2_2.sol`; `doc/` carries upgrade guides and design specs.
- **Deployed-vs-repo:** the repo does **not** map versions to deployed addresses. I resolved the mapping myself from chain state: the mainnet proxy's ZeppelinOS implementation slot points at `0x43506849D7C04F9138D1A2050bbF3A0c054402dd` and the proxy reports `version() == "2"`, consistent with the `FiatTokenV2_2` family. I did **not** byte-compare repo output against deployed bytecode — that is a Stage-2/3 verification task and is marked **UNKNOWN** here.
- **On-chain vs legal promise.** On-chain: ERC-20 accounting, a minter-allowance system, a blacklist, a pause, a rescuer, an upgradeable implementation, and CCTP/Gateway messaging. Legal promise: the Circle Reserve Fund, the BlackRock mandate, the BNY custody, the FBO bank accounts, the bare-legal-title theory, the two-business-day redemption, the Coinbase revenue share, and the OCC charter. The only thing that crosses from one column to the other is a monthly PDF.

### 4. EVIDENCE

- USDC Reserve Report, June 2026, with Independent Accountants' Report (report dates 2026-06-02 and 2026-06-30; circulation, reserve composition, CUSIP-level Treasury holdings, definitions of USDC in Circulation / Tokens Allowed But Not Issued / Access Denied Tokens / Circle Gateway pending burns; the 36 Approved Blockchains; issuers Circle Internet Financial, LLC and Circle Internet Financial Europe SAS; signed 2026-07-29): https://6778953.fs1.hubspotusercontent-na1.net/hubfs/6778953/USDCAttestationReports/2026/2026%20USDC_Examination%20Report%20June%2026.pdf
- Circle Internet Group, Inc. Form 10-K for FY2025, filed 2026-03-09 (Deloitte & Touche LLP audit opinion and "auditor since 2023"; ~88% of reserves in the Circle Reserve Fund; BlackRock manager, BNY custodian; FSB-designated G-SIBs for FBO cash; Circle National Trust conditional approval December 2025 and first-priority perfected security interest; Circle Mint onboarding, free minting, two-business-day free basic redemption and near-instant standard redemption for a nominal fee; bare-legal-title / bankruptcy-estate discussion; NYDFS BitLicense, FinCEN MSB, ADGM, Bermuda, France DASP + EMI; CCTP and CCTP V2 (March 2025) and Gateway (July 2025); access-denied tokens $116.8M at 2025-12-31 and the liability-extinguishment rule; reserve income $2,636,822k and distribution and transaction costs $1,661,549k): https://www.sec.gov/Archives/edgar/data/1876042/000187604226000062/crcl-20251231.htm
- Circle transparency page (monthly third-party assurance by "a Big Four accounting firm"; Circle Reserve Fund / bank cash split): https://www.circle.com/transparency
- USDC Terms (Users Type A vs Users Type B; redemption conditional on registering a Circle Mint account; Circle may decline any issuance or redemption without prior notice; blocking and freezing, temporary or permanent; forfeiture language; no deposit insurance): https://www.circle.com/legal/usdc-terms
- Verified contract metadata, Blockscout API: https://eth.blockscout.com/api/v2/smart-contracts/0xA0b86991c6218b36c1d19D4a2E9Eb0cE3606eB48
- On-chain reads (2026-08-04): ZeppelinOS implementation slot → `0x43506849D7C04F9138D1A2050bbF3A0c054402dd`; admin slot → `0x807a96288A1a408dBC13DE2b1d087d10356395d2` (EOA); `owner()`, `masterMinter()` (contract `MinterAdmin`), `blacklister()`, `pauser()` as listed; `paused()=false`; `totalSupply()=49536777415220915`.
- Repository: https://github.com/circlefin/stablecoin-evm (Apache-2.0)
- **Stale source, recorded so it is not reused:** https://www.circle.com/blog/new-levels-of-detail-in-the-monthly-usdc-attestation (2022-08-25, names Grant Thornton).

### 5. WHAT LOOKS UNNAMEABLE

1. **The reserve, the manager, the custodian.** CONFIRMED unnameable. "A 2a-7 government MMF managed by BlackRock and custodied at BNY, of which the issuer owns 100% of the equity on behalf of holders" is a four-party legal structure; `At` names the PDF that describes it.
2. **The SVB depeg was a bank failure.** CONFIRMED. The only time USDC has broken par, the cause lay entirely outside anything the 58 symbols can express, and the 10-K still lists "credit risks in respect of counterparties, including banks" as a live risk factor with no on-chain correlate.
3. **Circle Mint as a business relationship.** CONFIRMED. `Aw` names an on-chain gate; this gate is an application, a suitability check on "anticipated minting volume," and a wire relationship.
4. **Reserve-composition mandates (GENIUS Act, MiCA).** CONFIRMED. A rule that *forbids* the issuer from holding certain assets is a constraint on the reserve, and the reserve has no representation.
5. **Who captures the float.** CONFIRMED and now quantified: $2.637bn earned, $1.662bn paid away, $0 to holders. The vocabulary has `Fd` (surplus & fee distribution) and `Em` (protocol-funded emissions) and neither can express "the issuer keeps the interest and buys distribution with 63% of it."

**New items:**

6. **Access-denied tokens that remain liabilities.** A frozen USDC is still counted against the reserve until the money is handed to a government. That is a *three-state* object — live, denied-but-still-owed, extinguished-into-forfeiture — and `Fz` is a boolean.
7. **Tokens Allowed But Not Issued.** 1.38bn units that exist on-chain, are excluded from circulation, and exist only because of how the token is implemented on four specific chains. No symbol distinguishes "supply" from "issued supply" from "circulating supply," and the difference here is 1.9%.
8. **`Gateway` is a unified cross-chain balance.** Not `Xf` (no asset moves), not `Xm` (no message is the point). It is closest to the *contested* `Ua` — unified-balance ledger — which is in the contested register and therefore unusable. This is a live, shipped mechanism in the largest regulated stablecoin and the vocabulary's only word for it is one it has disallowed.
9. **`masterMinter` is a minter-allowance market, not a role.** Mint authority is a *quantity* delegated per minter and consumed by minting, administered by a separate contract. `Aw` names identity; nothing names a rate-or-quantity-limited delegated authority.
10. **The bankruptcy theory itself.** Circle's own filing says the outcome is untested and could go either way, in two jurisdictions, with different answers for EEA and non-EEA holders. The single most important fact about what a USDC is worth in the bad state is a legal conjecture, and the model has no epistemic slot for it — which is ironic given that the project's own labels (`theorem`/`measurement`/`conjecture`) are exactly the missing vocabulary.

**Verdict on the corpus's central claim, for USDC:** upheld for the backing, **partially refuted for the mechanism**. `Xf` and `Xm` are correctly assigned and they are genuine mechanism, not control-plane: CCTP is a real burn-and-attested-mint protocol with a fee tier. So the claim "every symbol these five use is control-plane or attestation" is **false as stated for USDC**.

### 6. DELTA

- **The corpus's residue text says "`At` names the monthly Deloitte report."** The June 2026 examination report does not name its firm in the text layer, and Circle's own transparency page says only "a Big Four accounting firm." Deloitte & Touche LLP is confirmed as Circle's *financial-statement* auditor from the 10-K. Treat "Deloitte performs the monthly USDC attestation" as **plausible but unconfirmed**, and do not cite the 2022 Grant Thornton blog post, which is stale.
- **`Tg` is absent and correctly so, but the corpus should record why.** USDC's proxy admin is a plain EOA with no code. There is no timelock. Law `L15` (`Up` → `Tg` | bounded emergency process) is **not satisfied** by USDC, and prohibition `X9` ("`Up` with immediate single-key control") arguably **fires** — the corpus records `armedProhibitions: []`. This deserves a hard look in Stage 2.
- **Gateway is new since the corpus was built** (launched July 2025, appearing as a deduction line in the June 2026 reserve report). It is not covered by `Xf`/`Xm`.
- **Figures move.** Circulation at 2026-06-30 is 73,268,560,097 (attested), against the corpus's $72.20B DefiLlama figure for 2026-08-04 — consistent, but the attested number is the citable one.
- **Circle National Trust** (OCC conditional approval, December 2025) will introduce a first-priority perfected security interest for holders. When it takes effect, USDC's holder claim changes category. Nothing in the corpus anticipates that a stablecoin's *creditor position* can be upgraded by a charter.

---

## World Liberty Financial USD1

### 1. WHAT IT DOES

USD1 is a transferable receipt for a **contractual** redemption claim against a US national trust bank — and, contrary to the token's branding, World Liberty Financial does not issue it. The June 2026 KPMG examination states plainly: "USD1 is issued and redeemed by the Company" — **BitGo Bank & Trust, N.A., a national trust bank chartered and supervised by the Office of the Comptroller of the Currency** — while "the USD1 brand and certain associated trademarks are owned and controlled by World Liberty Financial, Inc. and SC Financial Technologies, LLC." Minting and redemption rights belong only to registered BitGo customers in "Good Standing" under the BitGo Coin Minting & Redemption Services Terms — identity verification, AML and sanctions clearance. Everyone else is a "User": "Persons who hold USD1 without a Company account ('Users') may transfer USD1 on supported networks but **do not have direct redemption rights with the Company**." No minimum and no fee schedule appears in the attestation; the terms govern "submission through the Company's platform, compliance review, and settlement timing," so **the stated minimum, fee and latency are UNKNOWN from the primary documents I could reach**. The nature of the claim is stated more bluntly here than anywhere else in this category: "**USD1 holders' redemption rights are contractual and do not constitute a security interest in, or direct property interest in, any specific reserve asset.**" That is the opposite of Circle's bare-legal-title position and the opposite of Paxos's segregated-trust position. Against that, the assets are held in segregated accounts at regulated US financial institutions titled to BitGo for the benefit of USD1 holders, and the eligible-asset list is contractually constrained. If the issuer cannot pay, holders are contract creditors of an OCC-supervised trust bank whose segregated FBO accounts were established for their benefit — a materially better position than USDT and a materially worse one than the property claim Circle asserts.

### 2. DESIGN

**Token contract (Ethereum).** EIP-1967 transparent proxy at `0x8d0D000Ee44948FC98c9B98A4FA4921476f08B0d` (same address on BNB Smart Chain). Read on-chain 2026-08-04: implementation `0x694aA534BdeF8Ed63244eb902E7914e527891F08`, contract **`StablecoinV2`**, Solidity `0.8.24`, fully verified on Blockscout 2026-04-05, no license declared; proxy admin `0xa032Fe6C496732bdfc0d235066F55f171FA4aecE`, contract **`ProxyAdmin`** (Solidity 0.8.14). **Decimals: 18** (not 6). Ethereum supply `1,529,515,526.739243049392059492` USD1.

**Contract powers.** `StablecoinV2 is Stablecoin, IERC3009`, where `Stablecoin is ERC20PermitUpgradeable, Ownable2StepUpgradeable, PausableUpgradeable`. All privileged functions are `onlyOwner` at the token layer:
- `mint(uint)` / `burn(uint)` — to and from the owner's own balance
- `freeze(address)` / `unfreeze(address)` — a `frozen` mapping enforced in `_transfer` and `_approve` on **from, to and `msg.sender`**
- `pause()` / `unpause()`
- `drain(address)` — requires the account to be frozen, then moves its **entire** balance to `owner()` (`FrozenAccountDrained`)
- `reallocate(address _from, address _to, uint256 _amount)` — requires `_from` frozen, then **forcibly transfers** to a replacement account (`FrozenFundsReallocated`)
- `recoverERC20(...)`, plus EIP-3009 `transferWithAuthorization` / `receiveWithAuthorization` / `cancelAuthorization` / `batchCancelAuthorization` and EIP-2612 `permit`
- `renounceOwnership()` reverts — ownership cannot be dropped

**Key custody — the real governance graph, read on-chain.** `owner()` of the token is `0xEE9b1a09aEdaCED9dCDa74964EA447FEB93861c2`, a verified contract named **`TokenGovernor`** (Solidity 0.8.24, `AccessControlDefaultAdminRules`). It exposes nine roles: `MINTER_ROLE`, `BRIDGE_MINTER_OR_BURNER_ROLE`, `BURNER_ROLE`, `FREEZER_ROLE`, `UNFREEZER_ROLE`, `PAUSER_ROLE`, `UNPAUSER_ROLE`, `RECOVERY_ROLE`, `CHECKER_ADMIN_ROLE`, plus `DEFAULT_ADMIN_ROLE` for `drainFrozenAccount` / `batchDrainFrozenAccounts` and `executeTokenFunction`. Current holders (2026-08-04):

| Role | Holders |
|---|---|
| `getAdmins()` | `0x0d190b74308669e8f4fe7dbce3466169b285289d` |
| `getMinters()` | the admin Safe, `0x0f33afb00334ea05f6f0e64fc919920ecd4bd16c`, `0x87e0017503560a655309c470666645472c66246e` |
| `getBurners()` | same three |
| `getFreezers()` | the admin Safe, `0x6802744c90ffb2045de9790527b446d663f1ee66` |
| `getPausers()` | the admin Safe, `0x0f33afb00334ea05f6f0e64fc919920ecd4bd16c` |
| `getBridgeMintersOrBurners()` | `0xf9e47d3720d5142930444ae6773c7f6d05696228`, `0x36a72ed0096b414521c45e3ddc9ed657d1d9c141` |
| `getChecker()` | `0x0000000000000000000000000000000000000000` — **no compliance checker is installed** |

`0x0d190b74…` is a **Gnosis Safe proxy** (runtime 171 bytes, singleton `0x41675C099F32341bf84BFc5382aF534df5C7461a`) with **`getThreshold() == 3` and 6 owners**. The `ProxyAdmin`'s owner is a *different* Safe, `0x6a8dc6dbf909f542f2536edf8676d52630cf59e1`, with **`getThreshold() == 3` and 5 owners**. So upgrade authority and token authority are held by two separate 3-of-N Safes. There is **no timelock** on either.

**Multi-chain.** Native minting on **Ethereum, BNB Smart Chain, Solana, Tron, Aptos and Tempo** (per the attestation), and the docs list eleven deployments including Plume, AB Core, Monad, Mantle, Morph and X Layer at the shared address `0x111111d2bf19e43c34263401e0cad979ed1cdb61`. Cross-chain movement is by **Chainlink CCIP** — and this is corroborated on-chain by the dedicated `BRIDGE_MINTER_OR_BURNER_ROLE` held by two addresses, i.e. burn-and-mint token pools.

**Attestation regime.** Monthly, at two report dates. The June 2026 report is an examination by **KPMG LLP (San Francisco)**, signed 2026-07-31, under **AICPA attestation standards** against the **AICPA 2025 Criteria for Stablecoin Reporting: Specific to Asset-Backed Fiat-Pegged Tokens, Part I**. Prior reports are published back to April 2025.

**Reserves at 2026-06-30 (US$).** Redeemable tokens outstanding **4,634,410,387** (ETH 1,789,274,694 / BNB 1,802,654,137 / Other 1,042,481,556); redemption assets **4,634,586,966**; surplus **176,579**. Composition:

| | 2026-06-16 | 2026-06-30 |
|---|---|---|
| Cash & equivalents (BitGo Bank & Trust account) | 3,998,200 | 0 |
| Cash & equivalents (demand deposit accounts) | 682,022,558 | 1,178,613,044 |
| Government money market funds, at NAV (CUSIP 31607A703) | 3,864,794,493 | 3,455,973,922 |
| **Total** | **4,550,815,251** | **4,634,586,966** |

Cash sits in demand-deposit and money-market-deposit accounts at US commercial banks regulated by the Federal Reserve, "in segregated accounts titled to BitGo Bank & Trust, N.A. for the benefit of USD1 stablecoin holders," with the attestation noting balances "at times may exceed the FDIC limit of $250,000." Eligible assets are contractually limited to cash, cash equivalents, short-term USTs, fully UST-collateralised reverse repo, and government MMFs. **Individual bank names: UNKNOWN.** CUSIP 31607A703 corresponds to the Fidelity Investments Money Market Government Portfolio (ISIN US31607A7037) per securities-reference data; **the fund is not named in the attestation** and this identification is from a third-party source, not the issuer.

Notably, the June 2026 report records **zero** temporary access-restricted, time-locked and permanent access-restricted tokens: "With respect to USD1, there are no time-locked tokens, test tokens, or access-restricted tokens in this reporting period." The freeze machinery is armed and, at that date, unused.

### 3. REPO

**No public source repository.** I found none for `StablecoinV2` or `TokenGovernor` under World Liberty Financial or BitGo, and neither contract declares a license (`license_type: none` on Blockscout for both). The canonical artifact is the **fully verified** implementation source at `0x694aA534BdeF8Ed63244eb902E7914e527891F08` (Blockscout full match, verified 2026-04-05), which resolves to two first-party files — `contracts/Stablecoin.sol` and `contracts/interfaces/IERC3009.sol` — plus vendored OpenZeppelin upgradeable v4.x. The `TokenGovernor` at `0xEE9b1a09aEdaCED9dCDa74964EA447FEB93861c2` is likewise fully verified (2025-05-22) with first-party files `contracts/interfaces/{IChecker,IExternalMinter,IGovernedToken,ITokenGovernor}.sol` and OpenZeppelin v5 `AccessControlDefaultAdminRules`.

- **Deployed matches source:** yes, by Blockscout full (metadata-hash) match for both implementation and governor. Deployed matches *a repo*: not applicable — there is no repo.
- **On-chain vs legal promise.** On-chain: mint, burn, freeze, drain, reallocate, pause, EIP-3009/2612 authorisations, a nine-role governor, two 3-of-N Safes, and CCIP bridge roles. Legal promise: the reserve, the segregated FBO accounts, the OCC charter, the eligible-asset list, and the fact — stated in the attestation, nowhere in the code — that your redemption right is contractual and confers **no interest in any asset**.

### 4. EVIDENCE

- USD1 Reserve Attestation Report, June 2026, KPMG LLP examination of BitGo Bank & Trust, N.A. management's assertion, signed San Francisco 2026-07-31 (issuer identity and OCC charter; WLF as brand owner only; Clients vs Users and the absence of Users' redemption rights; the AICPA 2025 stablecoin criteria; per-chain token counts and the six minting networks; the six deployed addresses; reserve composition table; segregated FBO accounts at Fed-regulated US commercial banks; FDIC-limit caveat; the eligible-asset constraint; "redemption rights are contractual and do not constitute a security interest in, or direct property interest in, any specific reserve asset"; zero access-restricted and time-locked tokens): https://landing.bitgo.com/rs/552-OGK-141/images/USD1%5FReserve%5FAttestation%5FReport%5FJune%5F2026.pdf?version=0
- USD1 attestation index (monthly cadence, reports from April 2025): https://www.bitgo.com/usd1-attestations/ and https://docs.worldlibertyfinancial.com/usd1-token/attestation-reports
- USD1 contract addresses and the Chainlink CCIP statement: https://docs.worldlibertyfinancial.com/usd1-token/contract-addresses
- "What is USD1" (BitGo issues and mints; BitGo holds reserves; cash + government MMFs + cash equivalents; minting/redemption subject to issuer onboarding; BitGo customers redeem directly, others exit via exchanges/custodians): https://docs.worldlibertyfinancial.com/usd1-token/what-is-usd1
- BitGo Coin Minting & Redemption Services Terms (referenced by the attestation as the governing document): https://www.bitgo.com/legal/bitgo-coin-minting-services-terms/
- Verified implementation source: https://eth.blockscout.com/api/v2/smart-contracts/0x694aa534bdef8ed63244eb902e7914e527891f08 — `StablecoinV2`, solc 0.8.24, full match, verified 2026-04-05
- Verified governor source: https://eth.blockscout.com/api/v2/smart-contracts/0xee9b1a09aedaced9dcda74964ea447feb93861c2 — `TokenGovernor`, solc 0.8.24, full match, verified 2025-05-22
- On-chain reads (2026-08-04): EIP-1967 implementation and admin slots; `owner()`; all nine role-member lists; `getChecker() == 0x0`; both Safes' `getThreshold()` and `getOwners()`; `totalSupply()=1529515526739243049392059492`; `paused()=false`
- CUSIP 31607A703 → Fidelity Investments Money Market Government Portfolio (ISIN US31607A7037), third-party securities reference: https://fintel.io/so/us/31607a703

### 5. WHAT LOOKS UNNAMEABLE

1. **The reserve.** CONFIRMED unnameable — although note that USD1's reserve is *nameable in prose in one line* (cash in DDAs plus one government MMF) where Tether's takes a table. The vocabulary cannot express that difference, which is the difference between a boring instrument and an interesting one.
2. **Custody as a distinct risk layer.** CONFIRMED, and the corpus's framing needs correcting: the issuer *is* the custodian here (BitGo Bank & Trust is both), so the corpus's "issuer holds reserves vs custodian holds reserves for issuer" distinction collapses in this case in a way no symbol can record either.
3. **Governance/ownership concentration and related-party dealing.** CONFIRMED unnameable. Also now partially moot: the brand-owner and the obligor are different entities, and that separation is itself a fact with no symbol.
4. **Native multi-chain issuance.** PARTIALLY REFUTED — see DELTA.

**New items:**

5. **`drain` and `reallocate` are not `Fz`.** `drain` seizes a frozen balance to the owner. `reallocate` forcibly moves a frozen balance to a *replacement account* — the intended use is key-loss recovery, i.e. re-issuing a holder's position to a new address. That is a **forced transfer with a benign purpose** and it is indistinguishable, in the vocabulary, from confiscation. `Fz` names both and neither.
6. **The freeze predicate covers `msg.sender`.** `_transfer` requires `notFrozen(from)`, `notFrozen(to)` **and** `notFrozen(_msgSender())`. Freezing an address therefore disables it as a *spender* of others' allowances, not just as a holder. No symbol distinguishes freezing a balance from freezing an actor.
7. **An installable, currently-null compliance checker.** `TokenGovernor.setChecker()` can install an `IChecker` at any time. The gate is *absent but one transaction away*. Same problem as USDT's dormant fee: the vocabulary is a vocabulary of what is, not of what is armed.
8. **A dedicated bridge mint/burn role.** `BRIDGE_MINTER_OR_BURNER_ROLE` is separate from `MINTER_ROLE` — an explicit acknowledgement in the code that bridge-driven supply is a different authority from treasury-driven supply. `Xf` does not distinguish them.
9. **"Contractual, not a property interest."** The single most important sentence in the USD1 record. It is the answer to "what happens if the issuer cannot pay," and it differs from Circle's answer and from Paxos's answer, and all three are `At` in the model.

**Verdict on the corpus's central claim, for USD1:** upheld for backing; **refuted for cross-domain** (CCIP burn-and-mint is real mechanism) and **strained for `Fz`** (three distinct on-chain powers under one symbol).

### 6. DELTA

- **The issuer is wrong in the corpus.** The corpus treats World Liberty Financial as the issuer with "reserves custodied at BitGo." The attested position at 2026-06-30 is that **BitGo Bank & Trust, N.A. issues and redeems USD1** and WLF owns the brand. Every residue item that begins "the issuer as obligor" must be re-pointed at an OCC-supervised national trust bank. This changes the instrument's category.
- **`Xf` and `Xm` are missing and should be present.** The corpus says explicitly: "The token is deployed natively on multiple chains by the issuer, again not `Xf`." That is now wrong on both the docs and the chain: USD1 documents Chainlink CCIP for cross-chain transfer, and the deployed `TokenGovernor` carries a `BRIDGE_MINTER_OR_BURNER_ROLE` with two live holders. Burn-and-mint over a message-verifying protocol is `Xf` + `Xm`.
- **`Gp` is missing.** `pause()`/`unpause()` exist at the token and are held by `PAUSER_ROLE`/`UNPAUSER_ROLE`.
- **`Aw` is missing on the corpus's own USDC reasoning** (BitGo Clients vs Users).
- **`Rd` marker text needs revision.** The corpus says "institutional-only, contractual, discretionary." Correct on contractual and discretionary; "institutional-only" is not stated — the terms say *registered customers in Good Standing*, which is a KYC test, not an institutional test. No minimum is published. Mark the minimum **UNKNOWN** rather than asserting one.
- **Supply.** Attested 4,634,410,387 at 2026-06-30 across six chains, against the corpus's $4.00B DefiLlama figure at 2026-08-04. Ethereum alone is 1.53bn; BNB is the larger leg. If a later lane uses a single-chain figure it will understate by ~3x.
- **The reserve is materially *narrower* than the corpus implies.** "Reserve portfolio (custodied at BitGo)" suggests a portfolio. It is bank deposits plus one government money market fund. There are no Treasuries held directly, no repo, no gold, no loans.

---

## Global Dollar USDG (Paxos)

### 1. WHAT IT DOES

USDG is a transferable receipt for an **e-money** claim under two separate regulatory regimes with two separate obligors. For holders resident in the EEA, the issuer is **Paxos Issuance Europe Oy** ("Paxos EU"), a Finnish electronic money institution supervised by the Finnish Financial Supervisory Authority (FIN-FSA), LEI 743700KYSSTKZYGEUF50, Finnish Business ID 3236886-2, established 2021-10-18. For everyone else the issuer is **Paxos Digital Singapore Pte. Ltd.**, a Major Payments Institution supervised by the Monetary Authority of Singapore. The MiCA white paper states the redemption right in the regulator's own prescribed language: "The holders of this e-money token have a right of redemption at any time and at par value" — "1 USDG = 1 USD," "**without incurring fees**," with tokens burned on redemption and redemption "on a one-for-one basis, notwithstanding any change in the market value of stablecoins or reserve assets." Minting, by contrast, "is available exclusively on the Paxos Platform for institutions that have successfully completed the requisite onboarding procedures." All redemptions are subject to compliance review and may be delayed. Applicable law is the **law of Finland**; the competent court is the **District Court of Helsinki**. If the issuer cannot pay, the white paper's answer is the strongest of the five: reserves sit in segregated, bankruptcy-remote "trust accounts" at regulated custodians, authorised by FIN-FSA, legally segregated from Paxos EU's own funds and from the custodian's funds; in insolvency "holders of USDG are entitled to a proportionate share of the segregated reserve assets, with their claims taking precedence over unsecured creditors," distributed under Finnish insolvency law and overseen by the insolvency administrator and FIN-FSA. USDG itself is **not** covered by Directive 97/9/EC investor compensation or Directive 2014/49/EU deposit guarantee schemes (white paper field D.11 = `false`), though the underlying segregated accounts are.

The economically distinguishing feature is that USDG **pays the reserve yield out to distribution partners**: "Other stablecoin issuers keep reserve revenue for themselves. USDG passes rewards directly back to Global Dollar Network partners based on minting, custody, and acceptance activity."

### 2. DESIGN

**Token contract (Ethereum).** EIP-1967 proxy at `0xe343167631d89b6FFc58B88d6b7fB0228795491D`, 708 bytes. Read on-chain 2026-08-04: implementation `0xfaCd5Ff359aDF87822374275699DD518aaf9A65f` (18,644 bytes), contract **`USDG`**, Solidity `v0.8.28`, **fully verified** on Blockscout 2026-02-27, no license declared. Decimals 6; Ethereum supply `500,509,895.398634` USDG. Note: total USDG across all chains is several times the Ethereum leg.

**Contract architecture — the most elaborate of the five.** `contract USDG is PaxosTokenClaimableRewards, UUPSUpgradeable`. Three things distinguish it:

1. **A UUPS upgrade** (`upgradeTo` / `upgradeToAndCall`, `proxiableUUID`) — the upgrade logic lives in the implementation, not the proxy.
2. **A facet router inside the token**: `setFacet(bytes4 selector, address facetAddress)` and `batchSetFacet(FacetCut[])`, both `onlyRole(DEFAULT_ADMIN_ROLE)`, with `getFacet(bytes4)`. That is a diamond-style dispatch layer *in addition to* the proxy — a second, finer-grained mutability surface. The verified sources include `ClaimableRewardsFacet` and `TokenAdminFacet`.
3. **An on-chain rewards system.** `ClaimableRewardsBase` / `ClaimableRewardsStorageV3` implement payout groups, per-wallet shares, period accounting (`getCurrentPeriodNum`, `calculatePeriodsCrossed`, `projectMultiplier`), `_claimIndividualRewardsWithData`, `_transferWithDifferentPayouts`, `_updateWalletWithPayoutGroup`, `updateSharesWithRewardPreservation` and share-rebalancing on transfer. **The reserve-yield distribution is implemented, at least in part, as on-chain accrual-and-claim state on the token itself.**

Plus a separate **`SupplyControl`** contract (`0x9a7164112029b81c07636ab7b59fa813e0883bbf`, reached via `supplyControl()`), an `AccessControlDefaultAdminRulesUpgradeable` + UUPS contract with `SUPPLY_CONTROLLER_MANAGER_ROLE`, `SUPPLY_CONTROLLER_ROLE`, `TOKEN_CONTRACT_ROLE`, per-controller **rate limits** (`contracts/lib/RateLimit.sol`, `updateLimitConfig`, `getRemainingMintAmount`), a mint-address whitelist (`addMintAddressToWhitelist` / `removeMintAddressFromWhitelist` / `updateAllowAnyMintAndBurnAddress`) and `canMintToAddress` / `canBurnFromAddress` predicates. Mint authority is thus **quantity- and destination-constrained on-chain**, not merely role-gated. Base roles from `PaxosBaseAbstract`: `PAUSE_ROLE` and `ASSET_PROTECTION_ROLE`.

**Key custody.** `owner() == defaultAdmin() == 0x9036566EAa5f83e0b9E1161C6C602B0aDF997654`, a verified **`TimelockController`** (Solidity 0.8.20). Read on-chain: **`getMinDelay() == 86400`** — a 24-hour delay on admin actions. Separately, `defaultAdminDelay() == 10800` (3 hours) governs transfer of the default-admin role itself. **USDG is the only one of the five with a real timelock.**

**Attestation regime.** Monthly. Reports posted on or after **2026-02-27** are issued by **KPMG LLP** under standards established by the **Institute of Singapore Chartered Accountants (ISCA)** — Singapore standards, because the primary issuer is Paxos Digital Singapore. Reports before that date were issued by **Enrome LLP**, also under ISCA standards. Reports are indexed monthly for 2024, 2025 and Jan–Jun 2026. **The individual report PDFs are served through a JavaScript viewer that I could not resolve to direct URLs even under a rendered browser fetch; the per-month reserve figures and composition for USDG are therefore UNKNOWN in this record.** The on-chain Ethereum supply above and the MiCA white paper's asset constraints are what I can assert.

**Reserve.** Per the white paper: at least 100% of outstanding EU-attributed USDG in "high-quality, low-risk assets like cash and short-term government debt," legally segregated from Paxos EU's own funds, held with qualified custodians and structured for bankruptcy remoteness. MiCA additionally requires Paxos EU to hold a portion of USDG reserve assets with European banking partners. **Named custodians and banks: UNKNOWN.**

**Chains.** The white paper lists **Ethereum (ERC-20), Solana (SPL Token-2022), Ink (ERC-20), X Layer (ERC-20), Robinhood Chain (ERC-20, Arbitrum Orbit/Nitro)**; globaldollar.com adds that the set is growing. Field E.7 confirms the DLT is not operated by the issuer. **Cross-chain transfer mechanism between USDG deployments: UNKNOWN** — the white paper describes per-chain issuance and does not describe a bridge.

**Economics.** Global Dollar Network partners are paid out of reserve revenue "based on minting, custody, and acceptance activity." Paxos's own earnings calculator takes *USDG average balance held*, *net USDG minted* and *USDG transaction volume* as inputs — three distinct payout bases — and carries an explicit disclaimer that nothing displayed "should be construed as a commitment or obligation by Paxos, the Global Dollar Network, or any of their affiliates to pay any particular amount." **The specific revenue-share percentage is UNKNOWN from primary sources**; figures of "97%" and "over 90%" circulate in secondary coverage and I did not confirm them at Paxos.

### 3. REPO

- **`github.com/paxosglobal/usdg-contract`** — **MIT** licensed, Solidity + TypeScript/Hardhat. Top level: `contracts/` (a submodule), `USDG.abi`, `hardhat.config.ts`, `tsconfig.json`, README, LICENSE; 6 commits on `master`. The README states interaction is at the proxy address and points to Paxos docs for per-network deployments (Ethereum, Ink, X Layer), and states that audits were performed by **Zellic and Trail of Bits**, with the reports held in the `paxos-token-contracts` repository.
- **`github.com/paxosglobal/paxos-token-contracts`** — **MIT**, the shared implementation base. Contains `PaxosTokenV2`, `PaxosTokenClaimableRewards`, `ClaimableRewardsBase`, `ClaimableRewardsFacet`, `TokenAdminFacet`, `SupplyControl`, `RateLimit`, `PAXG.sol`, and an `audits/` directory holding **Halborn — PaxosTokenV2**, **Zellic — USDG Rewards** and **Zellic — PAXG V2**.
- **Deployed matches source:** the deployed implementation is **fully verified** on Blockscout (full metadata match, 2026-02-27) and its file paths (`contracts/SupplyControl.sol`, `contracts/ClaimableRewardsBase.sol`, `contracts/lib/PaxosBaseAbstract.sol`, `contracts/lib/RateLimit.sol`, `contracts/BaseStorageV3.sol`) correspond directly to the repo layout, including the rewards module. I did **not** perform a byte-for-byte repo-build comparison; that is **UNKNOWN**. Note that the deployed sources include `hardhat/console.sol` among the compiled units.
- **Exact tag/commit inspected:** none — neither repo surfaced a release tag. I inspected the **deployed** verified source at `0xfaCd5Ff359aDF87822374275699DD518aaf9A65f`, which is the citable artifact.
- **On-chain vs legal promise.** USDG has the *most* on-chain and it is still the smaller half. On-chain: transfers, freeze/wipe under `ASSET_PROTECTION_ROLE`, pause, rate-limited whitelisted minting, a facet router, a UUPS upgrade behind a 24-hour timelock, and a rewards accrual-and-claim ledger. Legal promise: the segregated Finnish trust accounts, the FIN-FSA authorisation, the MAS licence, the priority over unsecured creditors, the European banking partners, and the partner agreements that decide what the on-chain rewards ledger is actually paid *from*.

### 4. EVIDENCE

- USDG MiCA / EU crypto-asset white paper, Paxos Issuance Europe Oy (issuer identity, LEI, business ID, EMI status and FIN-FSA supervision; field I.07 right of redemption at any time and at par, no fees, tokens burned; EEA vs non-EEA obligor split with Paxos Digital Singapore; minting restricted to onboarded institutions on the Paxos Platform; 100% reserve in high-quality low-risk assets, segregated, bankruptcy-remote, qualified custodians; insolvency priority over unsecured creditors under Finnish law; D.11 compensation scheme = false; D.13 law of Finland; D.14 District Court of Helsinki; E.6/E.7 chain and fee statements; the five chains and their standards): https://www.paxos.com/terms-and-conditions/usdg-eu-whitepaper
- Paxos MiCA landing page: https://www.paxos.com/eu
- Paxos USDG transparency page (monthly cadence; KPMG LLP for reports posted on or after 2026-02-27 under ISCA standards; Enrome LLP before that date, also ISCA; monthly index for 2024, 2025 and Jan–Jun 2026) — content read via a rendered browser fetch on 2026-08-04: https://www.paxos.com/usdg-transparency
- About USDG (issuers Paxos Digital Singapore under MAS and Paxos Issuance Europe under FIN-FSA/MiCA; monthly reserve reports; chain list including Robinhood Chain): https://globaldollar.com/about-usdg
- Global Dollar Network earnings page (reward basis = average balance held, net minted, transaction volume; explicit no-commitment disclaimer; issuer footnote): https://globaldollar.com/earn-with-usdg
- Verified implementation source: https://eth.blockscout.com/api/v2/smart-contracts/0xfacd5ff359adf87822374275699dd518aaf9a65f — `USDG`, solc 0.8.28, full match, verified 2026-02-27
- On-chain reads (2026-08-04): EIP-1967 implementation slot; `owner()=defaultAdmin()=0x9036566EAa5f83e0b9E1161C6C602B0aDF997654` (`TimelockController`, solc 0.8.20, verified); `getMinDelay()=86400`; `defaultAdminDelay()=10800`; `supplyControl()=0x9a7164112029b81c07636ab7b59fa813e0883bbf`; `totalSupply()=500509895398634`; `paused()=false`
- Repositories: https://github.com/paxosglobal/usdg-contract (MIT) and https://github.com/paxosglobal/paxos-token-contracts (MIT, audits by Halborn, Zellic, Trail of Bits)

### 5. WHAT LOOKS UNNAMEABLE

1. **The reserve-yield sharing agreement.** **PARTIALLY REFUTED** — the most important finding in this category. The corpus says `Fd` is "forced" because "the surplus distribution is a legal agreement executed by wire, not an on-chain fee flow." The deployed USDG implementation contains a rewards ledger: payout groups, per-wallet shares, period accounting, share preservation across transfers, and an individual claim function, audited by Zellic as "USDG Rewards." The *source* of the money is off-chain reserve income; the *distribution* is on-chain accrual against balances. `Fd` is not forced. Whether the right symbol set is `Fd` alone or `Fd` + `Sh` + `Ix` + `Ep` is a Stage-2 question, but the premise of the corpus's marker note is factually wrong.
2. **The trust charter and segregated-reserve requirements.** CONFIRMED unnameable — and the corpus names the wrong charter (see DELTA).
3. **Reserve/obligor/banking residue.** CONFIRMED, with an addition: USDG has **two obligors selected by the holder's residency**, and no symbol can express an obligor that varies by who is asking.
4. **Consortium as an issuer governance form.** CONFIRMED unnameable, though note that GDN is a distribution-and-payout network, not a governance body over issuance — the white paper gives issuance authority to Paxos EU and PDS alone.

**New items:**

5. **Rate-limited, whitelist-constrained mint authority.** `SupplyControl` caps how much each supply controller can mint per period and to which addresses. This is a genuine on-chain safety mechanism, closest in spirit to a `Ct` (a threshold test) but on issuance rather than collateral, and there is no symbol for it. It is also exactly the mitigation `X9`-style single-key-mint concerns would demand, and the vocabulary cannot record that the mitigation exists.
6. **A facet router *inside* an upgradeable implementation.** `setFacet` gives per-selector mutability under `DEFAULT_ADMIN_ROLE`, layered under a UUPS proxy, layered under a 24-hour timelock. `Up` is one bit. Here there are three nested mutability surfaces with different delays.
7. **The timelock is real and the corpus does not see it.** `getMinDelay() == 86400`. `Tg` exists in the vocabulary. USDG is the only member of this category that satisfies law `L15`.
8. **Rewards that survive transfer.** `updateSharesWithRewardPreservation` and `_transferWithDifferentPayouts` mean a transfer re-attributes reward shares between payout groups. That is a real accounting mechanism attached to an ERC-20 transfer, and it is neither `Rb` (balances do not change) nor plain `Sh`.
9. **A jurisdiction-selected obligor and a named competent court.** "District Court of Helsinki" is the answer to "who do you sue." There is no symbol for a forum.

**Verdict on the corpus's central claim, for USDG:** **refuted in part.** The rewards ledger, the supply rate-limiter and the timelock are mechanism, on-chain, and consequential. The backing residue stands.

### 6. DELTA

- **The regulator is wrong.** The corpus says "The NYDFS trust charter and the segregated-reserve requirements that make USDG legally different from USDT." USDG is **not** issued under a NYDFS trust charter. It is issued by **Paxos Digital Singapore Pte. Ltd.** (MAS Major Payments Institution) and **Paxos Issuance Europe Oy** (Finnish EMI, FIN-FSA, MiCA). The residue item is right that a charter distinction exists and wrong about which charter.
- **`Fd` is not forced.** See §5 item 1. The deployed contract implements the distribution. This is the single most consequential correction in this record for Stage 2, because the corpus uses "`Fd` forced, distribution is off-chain" as evidence for the category's central thesis.
- **`Tg` is missing and should be present.** 24-hour `TimelockController` as `owner`/`defaultAdmin`, verified on-chain.
- **`Gp` is missing.** `PAUSE_ROLE` and `pause()` exist.
- **`Aw` is missing** on the corpus's own USDC reasoning (Paxos Platform onboarding), and there is a second, stronger candidate: `SupplyControl`'s mint-address whitelist is an on-chain permission gate on *issuance destination*.
- **`Xf`/`Xm`: correctly absent, but for an undocumented reason.** I could not find a primary statement of how USDG supply moves between Ethereum, Solana, Ink, X Layer and Robinhood Chain. Mark **UNKNOWN**; do not assume it is the same as USD1's CCIP.
- **Attestation firm and standard.** KPMG LLP from 2026-02-27, previously Enrome LLP, both under **ISCA** (Singapore) standards — not AICPA. USDG is the only member of this category attested under a non-US, non-ISAE standard. The corpus does not record this and it matters for `At`.
- **Supply.** Ethereum-only is $500.5M at 2026-08-04 against the corpus's $3.42B all-chain figure. Any later lane reading a single chain will be off by ~7x.

---

## PayPal USD (PYUSD)

### 1. WHAT IT DOES

PYUSD is a transferable receipt for a claim against **Paxos Trust Company, N.A.** — a national trust bank supervised by the **OCC** — that most of its users never exercise and mostly never touch on-chain. PayPal is not the issuer: "PayPal USD is issued by Paxos, not PayPal or Venmo." PayPal's own 10-Q describes Paxos as "a third-party issuer (the 'PYUSD Issuer')" and states the claim precisely: "**Each token of PYUSD held by PayPal represents a contractual right to redeem with the third-party issuer of PYUSD for one U.S. dollar.**" PayPal itself holds PYUSD on its balance sheet and classifies it alongside cash and cash equivalents. For a US consumer, PYUSD lives inside PayPal's or Venmo's ledger and converts 1:1 to a PayPal balance; on-chain movement requires being "provisioned for external transfers and subject to our sanctions and anti-money laundering controls." Direct redemption with Paxos is available to institutional customers who complete Paxos Platform onboarding — "The PYUSD Issuer may also allow institutional users to directly purchase PYUSD from the PYUSD Issuer (as per the PYUSD Issuer's stablecoin terms and conditions)." **Minimums, fees and settlement times for direct Paxos redemption: UNKNOWN** from the sources I could reach. Reserves are "US dollar deposits, US treasuries and cash equivalents" held in "segregated, bankruptcy remote accounts," so if the issuer cannot pay, the holder is a beneficiary of a trust-bank segregation rather than an unsecured creditor — but the operative document for a PayPal consumer is PayPal's user agreement, not Paxos's, and that consumer's counterparty is PayPal, not Paxos.

### 2. DESIGN

**Token contract (Ethereum).** ZeppelinOS-style proxy at `0x6c3ea9036406852006290770BEdFcAbA0e23A0e8` (1,506 bytes). Read on-chain 2026-08-04: implementation `0x8C35caA5FD5bDc64b6b11344ad57594A3676256a` (18,334 bytes), contract **`PYUSD`**, Solidity `v0.8.28`, **fully verified** on Blockscout 2026-02-09, no license declared; proxy admin `0xc94BcF6E1d8b3558e3b62E743630D50497e3851C` (EOA, no code). Decimals 6; Ethereum supply `1,832,790,045.376448` PYUSD.

**Contract powers.** `contract PYUSD is PaxosTokenV2`, itself `BaseStorage, EIP2612, EIP3009, AccessControlDefaultAdminRulesUpgradeable`. Roles:
- `DEFAULT_ADMIN_ROLE` — `reclaimToken()`, `setSupplyControl(...)`, and role administration. Read on-chain: `defaultAdmin() == owner() == 0x3aF3E85f4f97DE7Ad0F000B724fB77Fe5FFc024b`, an **EOA with no code**. `defaultAdminDelay() == 10800` (3 hours) on transferring that role.
- `PAUSE_ROLE` — `pause()` / `unpause()`
- `ASSET_PROTECTION_ROLE` — `freeze(address)`, `freezeBatch(address[])`, `unfreeze`, `unfreezeBatch`, and **`wipeFrozenAddress(address)`** (destroy a frozen balance). `isFrozen(address)` is a public view.
- Supply: `increaseSupply` / `increaseSupplyToAddress` / `decreaseSupply` / `decreaseSupplyFromAddress` / `mint` / `burn`, all mediated by a separate **`SupplyControl`** contract at `0x31d9BDeA6f104606c954f8FE6bA614F1bd347Ec3` (read via `supplyControl()`), the same rate-limited, whitelisted design as USDG's.
- EIP-3009 (`transferWithAuthorization` family) and EIP-2612 (`permit`); `transferFromBatch`.

Compare USDG: PYUSD shares the Paxos base (`PaxosBaseAbstract`, `SupplyControl`, `RateLimit`) but **has no rewards module and no facet router**, and its `defaultAdmin` is a bare EOA rather than a timelock.

**Chains.** Paxos's developer documentation lists **five mainnets**: Ethereum `0x6c3ea9036406852006290770BEdFcAbA0e23A0e8`; Solana `2b1kV6DkPAnxd5ixfnxCpjxmKwqjjaYmCZfHsFu24GXo`; Arbitrum `0x46850aD61C2B7d64d08c9C754F45254596696984`; Polygon PoS `0x99aF3EeA856556646C98c8B9b2548Fe815240750`; X Layer `0x87b4a8176B3Df6b71e26CC095edcAf4Db07506B4` — each with its own Supply Control contract address. paxos.com/pyusd names Ethereum and Solana. **The mechanism by which supply moves between these deployments is UNKNOWN**; the Paxos mainnet page does not state one, and I did not find a primary Paxos statement of a LayerZero OFT path for PYUSD. Given each chain has its own Supply Control contract, native per-chain issuance is the documented picture.

**Attestation regime.** Monthly, plus a separate self-reported portfolio composition published 5 business days after month-end that is expressly "not subjected to independent review." Attestations posted on or after **2025-02-28** are issued by **KPMG LLP** under **AICPA** attestation standards; before that date, **WithumSmith+Brown, PC**, also under AICPA standards. **The per-month report PDFs are served through a JavaScript viewer that I could not resolve to direct URLs even under a rendered browser fetch; PYUSD's attested outstanding and reserve composition figures are therefore UNKNOWN in this record.** The Ethereum-leg supply above is what I can assert on-chain.

**Regulator — an unresolved inconsistency on Paxos's own site.** paxos.com/pyusd states PYUSD is "Issued by Paxos Trust Company, N.A." and "subject to strict regulatory oversight by the Office of the Comptroller of the Currency (OCC)." The PYUSD transparency page still describes "Paxos' prudential regulator, the New York State Department of Financial Services" and its Dollar-Backed Stablecoins guidance as the body approving KPMG's appointment. Paxos's newsroom records the OCC's approval of Paxos's application to convert from a New York trust company to a national trust bank; the OCC announced conditional approvals for five national trust bank charters, and Paxos said conversion would be completed "imminently." **The consistent reading is that PYUSD's issuer converted from NYDFS to OCC supervision during 2026 and one Paxos page is stale; I could not determine which from the primary sources, so the exact effective date is UNKNOWN.**

**Economics and the closed loop.** PayPal pays a variable-rate PYUSD reward to eligible US users who hold a PYUSD balance in the PayPal app, funded by PayPal as distributor rather than by Paxos as issuer or by any on-chain protocol. PayPal is separately regulated by NYDFS as a virtual currency business and is a "digital asset service provider under the GENIUS Act." **The specific reward rate at 2026-08-04 is UNKNOWN from primary sources** (PayPal's own product page states a rate that varies and I did not capture a dated primary quotation).

### 3. REPO

- **`github.com/paxosglobal/pyusd-contract`** — **MIT** licensed, Solidity. Top level: `contracts/`, `audit-reports/`, `assets/`, `paxos-token-contracts/` (submodule carrying the shared base implementations), plus Hardhat/`package.json`/`tsconfig.json`. The README names the deployed mainnet proxy `0x6c3ea9036406852006290770bedfcaba0e23a0e8`, describes the upgradeable-proxy pattern ("the proxy contract represents the token, while all calls are delegated to an implementation contract"), and references audits: **Trail of Bits** for v1, and **Zellic and Trail of Bits** for the v2 `PaxosTokenV2` implementation.
- **`github.com/paxosglobal/paxos-token-contracts`** — MIT, the shared base (`PaxosTokenV2`, `SupplyControl`, `RateLimit`, plus the `audits/` directory).
- **Deployed matches source:** the deployed implementation is **fully verified** (Blockscout full match, 2026-02-09) and its file paths map onto the repo layout. No byte-for-byte repo-build comparison performed — **UNKNOWN**. **Exact tag/commit inspected: none surfaced**; the citable artifact is the verified deployed source.
- **On-chain vs legal promise.** On-chain: ERC-20 accounting, freeze/wipe, pause, rate-limited mint, EIP-3009/2612, an upgrade behind an EOA admin. Legal promise: the reserve, the trust segregation, the OCC charter, the redemption terms — and, uniquely in this category, **an entire second ledger**: the PayPal/Venmo custodial database in which most PYUSD balances live and move without ever producing a transaction on any of the five chains.

### 4. EVIDENCE

- PayPal Holdings, Inc. Form 10-Q for the quarter ended 2026-06-30 (PYUSD carried at amortised cost alongside cash; "Each token of PYUSD held by PayPal represents a contractual right to redeem with the third-party issuer of PYUSD for one U.S. dollar"; "a third-party issuer (the 'PYUSD Issuer')"; PayPal and Venmo customers "provisioned for external transfers" may send PYUSD to external wallets; institutional users may purchase directly from the issuer; PayPal regulated by NYDFS as a virtual currency business and a digital asset service provider under the GENIUS Act): https://www.sec.gov/Archives/edgar/data/0001633917/000163391726000082/pypl-20260630.htm
- Paxos PYUSD product page (issued by Paxos Trust Company, N.A.; OCC oversight; reserves in US dollar deposits, US treasuries and cash equivalents; 1:1 redemption; segregated bankruptcy-remote accounts; Ethereum and Solana; "PayPal USD is issued by Paxos, not PayPal or Venmo"): https://www.paxos.com/pyusd
- Paxos PYUSD transparency page (monthly attestations; KPMG LLP from 2025-02-28 under AICPA standards; WithumSmith+Brown, PC before that; separate un-reviewed self-reported portfolio composition 5 business days after month-end; NYDFS-approval language for the examiner appointment) — content read via a rendered browser fetch on 2026-08-04: https://www.paxos.com/pyusd-transparency
- Paxos developer documentation, PYUSD mainnet deployments (five networks with token and supply-control addresses): https://docs.paxos.com/guides/stablecoin/pyusd/mainnet
- Paxos newsroom, OCC approval of Paxos's conversion to a national trust: https://www.paxos.com/newsroom/occ-approves-paxos-application-to-convert-to-occ-trust-paxos-to-complete-conversion-imminently-to-become-a-federally-regulated-blockchain-infrastructure-provider
- OCC news release, conditional approvals for five national trust bank charter applications: https://www.occ.gov/news-issuances/news-releases/2025/nr-occ-2025-125.html
- Verified implementation source: https://eth.blockscout.com/api/v2/smart-contracts/0x8c35caa5fd5bdc64b6b11344ad57594a3676256a — `PYUSD`, solc 0.8.28, full match, verified 2026-02-09
- On-chain reads (2026-08-04): ZeppelinOS implementation and admin slots; `owner()=defaultAdmin()=0x3aF3E85f4f97DE7Ad0F000B724fB77Fe5FFc024b` (EOA); `defaultAdminDelay()=10800`; `supplyControl()=0x31d9BDeA6f104606c954f8FE6bA614F1bd347Ec3`; `totalSupply()=1832790045376448`; `paused()=false`
- Repositories: https://github.com/paxosglobal/pyusd-contract (MIT) and https://github.com/paxosglobal/paxos-token-contracts (MIT)
- PayPal PYUSD consumer page (rewards program): https://www.paypal.com/us/digital-wallet/manage-money/crypto/pyusd

### 5. WHAT LOOKS UNNAMEABLE

1. **The custodial shadow ledger.** CONFIRMED and it is the sharpest instance in the whole category. Most PYUSD activity is a row change in PayPal's database. The token contract is a settlement layer for a payment network whose real ledger is invisible to it. There is no symbol for "an off-chain ledger that shadows the token," and the corpus is right to say so. Corroborated at a primary source: PayPal's 10-Q says on-chain sending requires being *provisioned*.
2. **Reserve/obligor/banking residue.** CONFIRMED.
3. **A consumer payment network as the demand source; chargeback semantics.** CONFIRMED unnameable. Add: the reversal primitive exists in PayPal's ledger and cannot exist in the token, so the *same instrument* is reversible on one side of the boundary and final on the other. Nothing in the model can express an instrument whose finality depends on which ledger you are looking at.
4. **Issuer-funded promotional yield.** CONFIRMED. It is not `Em` (not protocol emissions), not `Fd` (not a surplus distribution by the issuer — it is *marketing spend by the distributor*), and not `Ix`/`Sr` (the accrual is in PayPal's ledger). Note the contrast with USDG, where an economically similar payment **is** partly on-chain. Same economics, different observability, and the vocabulary sees one and not the other.

**New items:**

5. **The obligor is not the counterparty.** A PayPal consumer's counterparty is PayPal; the obligor of last resort is Paxos. Two hops, two contracts, one token. No symbol for an intermediated claim.
6. **`wipeFrozenAddress` vs USD1's `reallocate`.** PYUSD can freeze and destroy but cannot forcibly re-assign. USD1 can do all three. Same `Fz`.
7. **Rate-limited mint authority.** Same `SupplyControl`/`RateLimit` machinery as USDG; same absence of a name.
8. **`defaultAdminDelay` is not a timelock.** 10,800 seconds delays *handing over* the admin role; it delays nothing the admin does. `Up` cannot distinguish "the key can act instantly but changes hands slowly" from "the key acts slowly."
9. **The issuer's own regulator is ambiguous in its own publications.** A stablecoin whose supervising authority cannot be read consistently off two pages of the issuer's website is a fact about `At`'s environment that `At` cannot hold.

**Verdict on the corpus's central claim, for PYUSD:** upheld. Every mechanism I can name here is control-plane (`Fz`, `Gp`, `Up`, plus the unnamed supply rate-limiter) or attestation (`At`), and the two most important facts — the shadow ledger and the issuer-funded reward — are outside the model entirely. The corpus's assignment of `Xf`/`Xm` to PYUSD, however, is **not supported** by what I could verify (see DELTA).

### 6. DELTA

- **The issuer's charter has changed.** The corpus says "issued by Paxos Trust under NYDFS." Paxos's product page now says **Paxos Trust Company, N.A.**, supervised by the **OCC**, following OCC approval of Paxos's conversion from a New York trust company. Paxos's own transparency page still cites NYDFS. Record both and mark the effective date **UNKNOWN**.
- **`Xf`/`Xm` are asserted on a fact I could not verify.** The corpus's `Xm` marker says "the LayerZero OFT deployment to Solana/Arbitrum is genuine cross-domain messaging." Paxos's mainnet documentation lists five chains, each with its own token contract **and its own Supply Control contract**, which is the signature of independent native issuance, not of an OFT. I found **no primary Paxos statement of a LayerZero path for PYUSD**. Either the corpus is citing a product (`PYUSD0`) distinct from PYUSD, or the claim is stale. Mark **UNCONFIRMED** and re-verify before Stage 2 uses it — because if it falls, PYUSD's element set collapses to `{At, Fz, Ps, Rd, Up}`, i.e. **identical to USDT and USD1**, which makes the "identical set" problem worse rather than better.
- **`Gp` is missing.** `PAUSE_ROLE` and `pause()` exist in `PaxosTokenV2`.
- **`Aw` is missing** on the corpus's own USDC reasoning (Paxos Platform onboarding for institutional mint/redeem, PayPal provisioning for external transfer).
- **Chains.** Five documented mainnets (Ethereum, Solana, Arbitrum, Polygon PoS, X Layer), not two.
- **Supply.** Ethereum-only $1.833bn at 2026-08-04 against the corpus's $2.68B all-chain figure.
- **Attestation.** KPMG LLP under AICPA from 2025-02-28 (WithumSmith+Brown before), **plus** a separate monthly self-report that carries no independent review — a two-document regime the corpus does not record, and one where the more detailed document is the un-reviewed one.

---

## Cross-cutting delta: are these systems actually alike?

The corpus records two identity claims: **USDT ≡ USD1** (both `{At, Fz, Ps, Rd, Up}`) and **PYUSD ⊂ USDC** (`{At, Fz, Ps, Rd, Up, Xf, Xm}` ⊂ `{At, Aw, Fz, Gp, Ps, Rd, Up, Xf, Xm}`). My answer from the designs is: **the equalities are artifacts of inconsistent coding, and the systems they equate are not alike.**

**First, the coding is inconsistent in three checkable ways.**

- **`Gp` is present in all five and coded in one.** Every one of the five deployed contracts has a live global pause under a named authority: USDT `pause()` `onlyOwner`; USDC `pauser()` role (address read on-chain); USD1 `pause()` under `PAUSER_ROLE`; USDG and PYUSD `pause()` under `PAUSE_ROLE`. The corpus assigns `Gp` to USDC alone. Correcting this alone breaks USDT ≡ USD1's tie with USDC's set and changes four of the five decompositions.
- **`Aw` is present in all five on the corpus's own justification and coded in one.** The corpus assigns USDC `Aw` because "the gate is on Circle Mint access." The identical gate exists at Tether (819 KYC Verified Customers), BitGo (Clients in Good Standing vs Users with no redemption right), Paxos EU/PDS (Paxos Platform onboarding) and PayPal/Paxos. Either all five carry `Aw` or none does.
- **`Tg` is present in exactly one and coded in none.** USDG's `owner`/`defaultAdmin` is a `TimelockController` with a 24-hour minimum delay. USDT is a 3-of-6 multisig with no delay; USDC's proxy admin is a bare EOA; USD1's is a 3-of-5 Safe with no delay; PYUSD's is a bare EOA. This is the sharpest *governance* difference in the category and the model currently records it nowhere. It also determines whether `X9` ("`Up` with immediate single-key control") fires, and the corpus lists no armed prohibitions for any of the five.

**Second, on the designs, USDT and USD1 are not alike.** They agree on the shape of the receipt and disagree on every question that determines what the receipt is worth:

| | USDT | USD1 |
|---|---|---|
| Obligor | Tether International, S.A. de C.V. (El Salvador private company, CNAD) | BitGo Bank & Trust, N.A. (OCC national trust bank) |
| Holder's claim | IFRS 9 **refund liability** — unsecured, face value only, no share of surplus | **contractual** right; expressly "not a security interest in, or direct property interest in, any specific reserve asset" |
| Reserve | T-bills, repo, gold, bitcoin, public equities, other investments, secured loans; **12.6% non-cash-equivalent** | bank demand deposits + one government MMF; contractually limited eligible assets |
| Assurance | ISAE 3000R **reasonable assurance**, BDO Advisory Services S.r.l., quarterly, going concern **excluded** | AICPA examination against the **2025 AICPA stablecoin criteria**, KPMG LLP, monthly, two dates/month |
| Redemption | 819 named customers, **$100k minimum**, greater of $1,000 or 0.1% | registered Clients in Good Standing; no published minimum or fee |
| Dispute forum | confidential BVI-law arbitration, seat London | US courts (BitGo terms) — not restated in the attestation |
| On-chain seizure | freeze + **destroy** | freeze + **destroy** + **forced reallocation** |
| Upgrade | `deprecate()` forwarding, 3-of-6 multisig, no delay | EIP-1967 proxy + `ProxyAdmin`, 3-of-5 Safe, no delay |
| Cross-chain | operator burn/mint, no verifier | **Chainlink CCIP**, dedicated `BRIDGE_MINTER_OR_BURNER_ROLE` |
| Decimals | 6 | 18 |

The last three rows are element-level differences the corpus's set misses outright.

**Third, PYUSD ⊂ USDC is also an artifact.** Adding `Gp` and `Aw` to PYUSD makes the sets equal, not nested — and then the `Xf`/`Xm` question decides everything. USDC's `Xf`/`Xm` are solid (CCTP, CCTP V2, Gateway, all described in an SEC filing). PYUSD's are **unconfirmed** (§PYUSD DELTA). If PYUSD's fall, PYUSD becomes set-identical to USDT and USD1 — three systems with different obligors, different charters, different reserves, different creditor positions and different seizure powers sharing one five-symbol signature.

**So: is the corpus's central claim true?** Mostly yes, and the exceptions are precise. The claim that "everything determining whether the token is worth a dollar is outside the model" is **confirmed for all five**: reserve composition, custodian, banks, obligor, creditor priority, redemption eligibility and the ordering regulator are unrepresented, and the one symbol touching backing (`At`) names the report rather than the reserve. The claim that "every symbol these five use is control-plane or attestation rather than mechanism" is **false for three of the five**: USDC's CCTP and Gateway, USD1's CCIP burn-and-mint, and USDG's on-chain rewards ledger, supply rate-limiter and 24-hour timelock are all mechanism. The strongest form of the finding that survives is narrower and, I think, better: **the mechanism these systems do have is mechanism about moving and controlling the receipt, never about producing the dollar.** Every on-chain mechanism in this category operates on the token's own state; not one of them observes, values, constrains or is constrained by the asset that makes the token worth anything.
