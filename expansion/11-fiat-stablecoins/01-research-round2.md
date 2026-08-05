# Category 11 — Reserve-backed / fiat stablecoin issuers: Stage-1 research, round 2

**Lane:** Stage 1, second pass. **Compiled:** 2026-08-04. **Supplement to `01-research.md`, not a replacement.**
**Access date for every URL below is 2026-08-04.** On-chain reads are at Ethereum mainnet block **25,686,224** unless stated; the USDT log sweep runs from the contract's first block **4,634,748** to block **25,686,100**.

---

## WHAT ROUND ONE LEFT OPEN, AND WHAT THIS PASS CLOSED

| # | Round-one gap | Status after round 2 |
|---|---|---|
| 1 | Named banks and custodians, all five | **CLOSED.** Named in full for USDC (custodian, adviser, ten repo counterparties, fund auditor) from the reserve fund's own SEC filing. Established as **primary-source non-disclosure**, with the declining sentence quoted, for USDT, USD1, USDG and PYUSD's examined reports. One additional, **discontinued** Paxos document names three banks for PYUSD. |
| 2 | USDG and PYUSD per-month attestation figures | **CLOSED.** Both June 2026 reports retrieved as PDFs and parsed. The JS viewer was defeated by capturing the network request the month button fires. |
| 3 | Redemption terms, exact, per issuer | **CLOSED for all five.** PYUSD's minimum and fee — round one's largest hole — are now exact on both of its two redemption paths. |
| 4 | Regulator and what it can compel | **CLOSED.** Statutory citations for all five. The PYUSD NYDFS→OCC transition is **resolved to a date and a charter number.** |
| 5 | Freeze and blacklist keys: holders, count, timelock, quorum | **CLOSED, and it overturns round one's headline.** Every privileged holder read on-chain and classified. |
| 6 | Machine-counted USDT blacklist total | **CLOSED.** Full-history sweep, zero provider failures, and every replayed address re-verified against contract state. |

**What still will not close, and why.** (a) The identities of the banks holding cash for Tether, USD1 and USDG: four primary documents describe the *category* of institution and decline to name one; that refusal is now quoted rather than merely reported. (b) Whether any of the externally-owned accounts below is backed by an MPC or HSM quorum off-chain: unobservable on-chain, and none of the five discloses it — **UNKNOWN**, and the point is that it is unobservable, which is itself the finding. (c) USDG's cross-chain supply mechanism: still undocumented at Paxos — **UNKNOWN**. (d) The NYDFS consent order against Paxos Trust Company, LLC referenced in the OCC's own approval letter is not dated or described there — **UNKNOWN**. (e) Full operative text of Singapore's Payment Services Act ss. 11/78/80/102 (section numbers and titles confirmed from the official statute's table of contents; body text not retrieved).

---

## Tether USDT

### The blacklist, machine-counted

Round one could not obtain this because a public RPC rate-limited the sweep. Resolved by moving to `https://rpc.mevblocker.io`, which serves `eth_getLogs` over 500,000-block ranges: the whole 21.05M-block history swept in **18 seconds with zero failures**.

Event topics computed, not assumed — `keccak256("AddedBlackList(address)")` = `0x42e160154868087d6bfdc0ca23d96a1c1cfa32f1b72ba9ba27b69b98a0d819dc`; `RemovedBlackList(address)` = `0xd7e9ec…470c`; `DestroyedBlackFunds(address,uint256)` = `0x61e6e6…98c6`.

| Measure | Count |
|---|---|
| `AddedBlackList` events | **3,059** |
| unique addresses ever blacklisted | **3,049** |
| `RemovedBlackList` events | **344** (340 unique net removals) |
| **currently blacklisted, replayed in event order** | **2,709** |
| `DestroyedBlackFunds` events | **1,270**, over **1,173** unique addresses |
| **USDT destroyed** | **853,538,431.155595** |
| destroyed addresses still blacklisted | 1,162 (so 11 were un-blacklisted *after* their balance was destroyed) |
| first / last `AddedBlackList` block | 4,638,805 / 25,681,821 |

**Verification, not just replay.** All 2,709 replayed addresses were re-read against the contract's own `getBlackListStatus(address)` through Multicall3 (`0xcA11bde05977b3631167028862bE2a173976CA11`): **2,709 of 2,709 confirmed, zero mismatches.** A 60-address sample of net-removed addresses returned false for all 60. The replay and the contract state agree exactly.

**The dormant mechanisms are empirically dormant.** Over the same full history the sweep returned **zero `Pause` events, zero `Unpause` events, zero `Deprecate` events and zero `Params` events**. In eight years and nine months, the owner has never paused USDT, never triggered the forwarding upgrade, and **never once turned the transfer-fee dial**. Round one flagged `setParams` as "a latent mechanism"; it is now measured — latent for the contract's entire life, on an instrument whose Ethereum leg alone is $92.06bn.

### The freeze key holder

`owner()` = `0xC6CDE7C39eB2f0F0095F41570af89eFC2C1Ea828`, `MultiSigWallet`. Read on-chain: **`required() == 3`, `getOwners()` returns 6 addresses, and all six have `eth_getCode` length 0 — every one is an externally-owned account.** No timelock, no contract signer, no delay. The freeze key, the destroy key, the mint key, the pause key, the fee key and the upgrade key are one 3-of-6 quorum of bare private keys.

Owners: `0xac3b242e…1fa0`, `0xee5207d3…fc8c`, `0x61d5a4d5…9fed`, `0x25bb6164…4155`, `0x4096a34e…85c1`, `0x4d915dd2…8973`.

### Banks and custodians — the non-disclosure, quoted

The BDO ISAE 3000R report as of 2026-06-30 names **no bank and no custodian**. Its only description of where the cash sits is footnote 7: *"The 'Cash & Bank Deposits' category comprises cash deposits at financial institutions."* Its procedures section refers to obtaining *"confirmation letters directly from banks and depositaries"* and its scope limitation to *"the case of key custodians or counterparties experiencing substantial illiquidity"* — the auditor confirms balances with institutions it does not identify, and warns about custodians it does not identify.

The Relevant Information Document, p.16: *"Tether primarily holds the Reserves with various third parties including banks and licensed financial institutions."*

Leads chased to exhaustion and **not** confirmed at any primary source: Cantor Fitzgerald (absent from both Tether documents, absent from tether.io newsroom, and EDGAR full-text search returns only Cantor Equity Partners / Twenty One Capital SPAC filings, which concern a bitcoin treasury and not USDT reserve custody); Deltec Bank & Trust and Britannia Bank & Trust (zero occurrences in either Tether document). **Named banking and custody relationships for USDT: UNKNOWN, and now demonstrably undisclosed rather than merely unfound.**

Worth recording as a control: Tether's *other* token USAT, issued by Anchorage Digital Bank, N.A., publishes its own June 2026 attestation which likewise tabulates reverse-repo counterparties only as **"Broker-Dealer in the United States"** (https://learn.anchorage.com/06.30.26_USAT-Stablecoin-Attestation-Report.pdf). The anonymisation is a house style across the Tether group, not an artifact of El Salvadoran law.

### Regulator and what it can compel

The governing statute is El Salvador's *Ley de Emisión de Activos Digitales*, **Decreto Legislativo N° 643** — approved 2023-01-11, published *Diario Oficial* N° 16, Tomo 438, 2023-01-24, in force ~2023-02-01 (Art. 47). Official text: https://cnad.gob.sv/wp-content/uploads/2024/08/1.-Ley-de-Emision-de-Activos-Digitales-DL-643.pdf

CNAD's enumerated powers, Art. 9 (*Facultades de la Comisión*):
- Art. 9(b) — *"autorizar, suspender o cancelar ofertas públicas que violen disposiciones de esta Ley y sus reglamentos"* — suspend or cancel a public offering.
- Art. 9(d) — *"Autorizar, suspender, revocar y cancelar el registro de los Proveedores de Servicios de Activos Digitales… así como suspender negociaciones y operaciones de activos digitales"* — suspend or revoke DASP registration and suspend trading in a digital asset.
- Art. 9(h) — *"En caso de incumplimiento por causa de algún emisor, podrá suspender la venta o comercialización de los activos digitales de dicho emisor"* — halt sale of a specific issuer's asset.
- Art. 9(k) examination and audit; Art. 9(n) sanctions, operationalised at Arts. 37–41 (fines up to 1,200 minimum wages for a material or wilful concealment by an issuer, Art. 38(d)).

**The decisive negative: no article of Decreto 643 gives CNAD power to order a token freeze, a seizure, or a redemption.** Its coercive toolkit reaches the issuer's *licence* and the issuer's *wallet*, never a holder's balance. USDT's freeze power therefore answers to no El Salvadoran legal trigger at all — it is exercised, on Tether's own account, at the request of foreign law-enforcement agencies that have no authority over the issuer's licence. The corpus's `Fz` symbol names a capability whose *legal* predicate, for the largest issuer in the category, is located in a jurisdiction that is not the one supervising it.

---

## Circle USDC

### Named banks and custodians — the one issuer where names exist

Round one could not name a bank. The reason names exist here at all is structural: 88% of the reserve sits in an **SEC-registered Rule 2a-7 fund**, and a registered fund must file a schedule of investments. It is the securities law, not the stablecoin disclosure, that produces the names.

From **BlackRock Funds℠ Circle Reserve Fund**, Form N-CSR, Investment Company Act file no. **811-05742**, fiscal year ended 2026-04-30, filed 2026-07-02 (https://www.sec.gov/Archives/edgar/data/844779/000119312526293738/d52232dncsr.htm), Institutional Shares ticker **USDXX**:

- **Accounting Agent and Custodian: The Bank of New York Mellon**, New York, NY 10286
- **Investment Adviser and Administrator: BlackRock Advisors, LLC**, Wilmington, DE
- **Transfer Agent: BNY Mellon Investment Servicing (US) Inc.**
- **Independent Registered Public Accounting Firm: Deloitte & Touche LLP**, Boston, MA
- **Distributor:** BlackRock Investments, LLC · **Legal Counsel:** Ropes & Gray LLP

Net assets at 2026-04-30: **$66,367,042,789**, of which repurchase agreements **$46,998,000,000 (70.8%)** and U.S. Treasury obligations **$19,110,582,543 (28.8%)**. Fund-level interest income for the year: **$2,489,692,922**.

**The ten named repo counterparties** in the Schedule of Investments at 2026-04-30, every one over-collateralised by U.S. Treasury obligations, all overnight (purchase 04/30/26, maturity 05/01/26):

Barclays Capital, Inc. · BNP Paribas SA · Citibank N.A. · Citigroup Global Markets, Inc. · Crédit Agricole Corporate & Investment Bank SA · Deutsche Bank AG · Goldman Sachs & Co. LLC · J.P. Morgan Securities LLC · Nomura Securities International, Inc. · Wells Fargo Securities LLC

This is the single most consequential disclosure in the category: **the actual credit exposure behind 70.8% of the largest regulated stablecoin's reserve is to ten named dealers, overnight, and it is discoverable only from a mutual fund's annual report — not from any USDC document.**

**And the non-disclosure survives for the other 12%.** Circle's 10-K, verbatim: *"The remaining portion of USDC reserves (typically 10-20%) are held as cash in accounts that are titled FBO holders of USDC, primarily with banks designated by the Financial Stability Board as Global Systemically Important Banks ('GSIBs')… A small fraction of USDC reserves is held as cash within several additional banks, which facilitate the flow of funds from reserves to Circle Mint customers."* No individual bank is named anywhere in the 10-K; Customers Bancorp, Cross River Bank and Standard Chartered appear zero times. The concentration-of-credit-risk note says only "multiple financial institutions."

### Redemption terms, exact

Round one had "no minimum; basic free within two business days; standard near-instant for a nominal fee." The nominal fee is published and it is a tiered basis-point schedule, effective 2026-03-15:

| Tier | Fee | Free allowance | Processing |
|---|---|---|---|
| Basic | **None**, until net redemptions exceed $40M/month; then **2 bps** ($40–100M) and **5 bps** (above $100M) | — | **Up to two business days** |
| Standard | **5 bps on net redemption** | first **$2M/day** free; $10M gross daily limit | **Near-instant** |
| Institutional | **5 bps on gross redemption**, with a net-mint credit up to 100% | **$2M/day** free | **Near-instant** |

Source: Circle Help Center, "USDC/EURC redemption structure," KB0010644, https://help.circle.com/support/en/usdc-eurc-redemption-structure?id=kb_article_view&sysparm_article=KB0010644 — this is also the primary origin of the "two business days" figure round one carried.

**Minimum: none.** *"Is there a minimum withdrawal amount? No, there is no minimum withdrawal amount."* — KB0010757, https://help.circle.com/support/en/usd-withdrawals-faqs?id=kb_article_view&sysparm_article=KB0010757

**Not an SLA.** The same FAQ: *"Settlement timing may vary based on transaction method and banking rails,"* and USDC Terms §17 reserve the right to *"delay issuances or redemptions if we reasonably believe the transaction is suspicious."*

### Key holders

| Role | Address | Holder type |
|---|---|---|
| proxy admin (ZeppelinOS slot) | `0x807a96288A1a408dBC13DE2b1d087d10356395d2` | **EOA** |
| `owner()` | `0xFcb19e6a322b27c06842A71e8c725399f049AE3a` | **EOA** |
| `masterMinter()` | `0xE982615d461DD5cD06575BbeA87624fda4e3de17` | contract, 7,667 bytes (`MinterAdmin`) |
| **`blacklister()`** | `0x0a06be16275b95a7d2567FbdaE118b36c7Da78f9` | **EOA** |
| `pauser()` | `0x4914F61D25e5c567143774B76eDbF4d5109A8566` | **EOA** |
| `rescuer()` | `0x0000000000000000000000000000000000000000` | **unassigned** |

Confirmed: `paused() == false`; implementation `0x43506849D7C04F9138D1A2050bbF3A0c054402dd`. Ethereum supply at block 25,686,224: **49,505,930,328.489380**.

The blacklist key on a $49.5bn instrument is **one externally-owned account with no quorum and no delay**, and the upgrade key on the same instrument is a different single externally-owned account. `rescuer()` being the zero address is worth recording: a role exists in the ABI and is assigned to nobody, which is a third state the model has no way to hold alongside "present" and "absent."

### CORRECTS ROUND ONE — Circle National Trust has a different legal name, and the charter is *preliminary*

Round one wrote "In December 2025 Circle received OCC conditional approval to establish Circle National Trust." The 10-K's actual sentence is narrower and names a different entity:

> *"In December 2025, we received **preliminary** conditional approval from the Office of the Comptroller of the Currency ('OCC') to establish a national trust bank, **First National Digital Currency Bank, N.A.** ('Circle National Trust'). **Once fully approved**, Circle National Trust will operate as a federally regulated trust institution, subject to OCC oversight, and will oversee the management of the USDC reserve…"*

and on the security interest:

> *"Circle National Trust **will** hold a first-priority perfected security interest in the USDC reserve as collateral trustee for the benefit of USDC holders, and protect the interests of USDC holders in the event of insolvency."*

"Circle National Trust" is Circle's own defined term for a bank legally named **First National Digital Currency Bank, N.A.** This matters for citation because searching the OCC's registers for "Circle" returns nothing — a search under the real name locates it immediately, and it locates it in a place that turns out to be the sharpest cross-issuer fact in this record (see *Cross-issuer*, below).

### Regulator and what it can compel

- **NYDFS BitLicense, 23 NYCRR Part 200.** The suspension/revocation provision is **§200.6(c)**, not §200.20 (which is "Complaints"): *"The superintendent may suspend or revoke a license issued under this Part on any ground on which the superintendent might refuse to issue an original license, for a violation of any provision of this Part, for good cause shown… 'Good cause' shall exist when a Licensee has defaulted or is likely to default in performing its obligations or financial engagements…"*
- **NYDFS Stablecoin Guidance, 2022-06-08** (https://www.dfs.ny.gov/industry_guidance/industry_letters/il20220608_issuance_stablecoins): redemption *"in a timely fashion at par… not more than two full business days (T+2)"*; reserves limited to ≤3-month T-bills, Treasury reverse repo, capped government MMFs and FDIC-insured deposits, segregated, monthly CPA attestation. The compulsion clause: *"DFS may, at any time and in its sole discretion, prohibit or otherwise limit a stablecoin's issuance or use… and may require that any such Issuer delist, halt, or otherwise limit or curtail activity with respect to any stablecoin."*
- **GENIUS Act** — see the cross-issuer section.

---

## World Liberty Financial USD1

### CORRECTS ROUND ONE — the freeze key is not only the Safe; it is also a bare EOA that has never sent a transaction

Round one reported `getFreezers()` as "the admin Safe, `0x6802744c…`" without classifying the second holder. Read on-chain and swept over the `TokenGovernor`'s full `RoleGranted`/`RoleRevoked` history (23 events from block 21,500,000 to head):

| Role | Holders | Type |
|---|---|---|
| `DEFAULT_ADMIN_ROLE` | `0x0d190b74…289d` | **Safe, 3-of-6** |
| **`FREEZER_ROLE`** | `0x0d190b74…289d` · **`0x6802744c90ffb2045de9790527b446d663f1ee66`** | Safe 3-of-6 · **EOA** |
| **`UNFREEZER_ROLE`** | same two | Safe 3-of-6 · **EOA** |
| `MINTER_ROLE` | `0x0d190b74…289d` · `0x0f33afb0…db16c` · **`0x87e0017503560a655309c470666645472c66246e`** | Safe 3-of-6 · EIP-1167 clone · **EOA** |
| `BURNER_ROLE` | same three | Safe · clone · **EOA** |
| `PAUSER_ROLE` / `UNPAUSER_ROLE` | `0x0d190b74…289d` · `0x0f33afb0…db16c` | Safe 3-of-6 · clone |
| `BRIDGE_MINTER_OR_BURNER_ROLE` | `0xf9e47d37…6228` (18,424 bytes) · `0x36a72ed0…c141` (20,955 bytes) | both contracts (CCIP pools) |
| `RECOVERY_ROLE`, `CHECKER_ADMIN_ROLE` | `0x0d190b74…289d` | Safe 3-of-6 |
| `getChecker()` | `0x0000…0000` | **no compliance checker installed** |

**`0x6802744c…` is an externally-owned account with `eth_getTransactionCount` = 0** — it can freeze and unfreeze a $1.53bn instrument (Ethereum leg) and has never signed anything. **`0x87e00175…` is an externally-owned account with nonce 13 that can mint and burn USD1 outright.** Round one's picture — "two separate 3-of-N Safes, no timelock" — is right about the Safes and misses that single keys sit *beside* them on the three most consequential roles.

`0x0f33afb00334ea05f6f0e64fc919920ecd4bd16c` is 45 bytes of code and is an **EIP-1167 minimal proxy** (`0x363d3d373d3d3d363d73e5dcdc13b628c2df813db1080367e929c1507ca05af43d82803e903d91602b57fd5bf3`) delegating to `0xe5dcdc13b628c2df813db1080367e929c1507ca0`.

**Both Safes are quorums of bare keys.** `TokenGovernor` admin Safe `0x0d190b74…289d`: threshold 3, six owners, **all six EOAs** (`0xca09699c…`, `0x12f9facf…`, `0xb9019fd4…`, `0x99c9f601…`, `0x74c6551d…`, `0x03e798b4…`). `ProxyAdmin.owner()` Safe `0x6a8dc6db…59e1`: threshold 3, five owners, **all five EOAs**.

### Redemption terms, exact — round one's three UNKNOWNs, resolved

From the **BitGo Coin Minting & Redemption Services Terms**, https://www.bitgo.com/legal/bitgo-coin-minting-services-terms/ :

- **Who:** *"BitGo will only accept Client's requests to mint, redeem, or transfer the Coins if Client is in Good Standing"* (§II.2). Good Standing = no violation of Applicable Laws, no elevated legal-liability exposure to BitGo, compliance with the Agreement, AML/sanctions documentation on request, not a Restricted Person, and an active unsuspended Account.
- **Minimum:** **none is published.** Confirmed absent from §II.4.A/B, from the Additional Terms addendum, from bitgo.com/legal, and from every `docs.worldlibertyfinancial.com/usd1-token/*` page.
- **Fee — the governing clause, and why the number is unobtainable:** §II.6 — *"Applicable transaction fees can be accessed through the Additional Terms and will be displayed in the Platform when submitting a mint or redemption request."* The Additional Terms (last updated 2026-03-25, https://www.bitgo.com/legal/bitgo-additional-terms/) say, in their entirety for this token: *"Fiat Referenced Coins — USD1 — Issuer: BitGo Bank & Trust, N.A. — Fees: http://app.bitgo.com/my/mint/fees"* — and that URL is behind platform authentication. **The redemption fee on USD1 exists, is incorporated by reference into the contract, and is publishable only to people who already have an account.** That is a documented absence, not a search failure.
- **Latency — and an explicit disclaimer of it:** §§II.4.A–B — *"BitGo will use commercially reasonable efforts to initiate such transfers as soon as reasonably practicable, and typically within two business days after receipt of a compliant redemption request… **Any timing referenced in this subsection is a target estimate only, is not a service level agreement or commitment, and BitGo will have no liability for any delay.**"*

### Banks and the money market fund

KPMG's June 2026 attestation names **no bank**: *"Cash is held in demand deposit and money market deposit accounts at **U.S. commercial banks**… in segregated accounts titled to BitGo Bank & Trust, N.A."*, and even the fund is unnamed — *"The fund shares are held in an account at **a regulated U.S. financial institution**."*

Round one's CUSIP identification is **confirmed at a proper source**: CUSIP **31607A703** = **Fidelity Investments Money Market Government Portfolio – Institutional Class (FRGXX)**, per Fidelity's own fund page (fundresearch.fidelity.com/mutual-funds/summary/31607A703) and OpenFIGI symbology. Round one had this from fintel.io and correctly flagged it as third-party; it now stands on the fund company's own disclosure. The identification is still *ours*, not the issuer's — the attestation gives a nine-character string and no name.

### Regulator, charter, and what it can compel

**BitGo Bank & Trust, National Association — OCC Charter No. 25366**, Sioux Falls, SD, RSSD 6060819, **CERT 0 (uninsured)**, confirmed on the OCC's own active trust-bank register (https://www.occ.gov/topics/charters-and-licensing/financial-institution-lists/trust-by-name.pdf, file current as of 2026-06-30).

OCC powers over it, 12 U.S.C. § 1818: **(b)** cease-and-desist ordering affirmative correction, restitution, asset disposition, contract rescission; **(c)** *temporary* C&D effective immediately on service where the practice *"is likely to cause insolvency or significant dissipation of assets or earnings"*; **(e)** removal of officers and directors and an industry-wide participation bar; **(i)(2)** civil money penalties, tiered to $1,000,000 per day for knowing violations causing substantial loss. And **12 U.S.C. § 191** — receivership: the Comptroller *"may, without prior notice or hearings, appoint a receiver for any national bank."* Because BitGo Bank & Trust is **uninsured**, the clause routing receivership to the FDIC does not apply and **the Comptroller appoints the receiver directly.**

---

## Global Dollar USDG (Paxos)

### CORRECTS ROUND ONE — the 24-hour timelock does not govern the freeze, the pause, or anything operational, and its proposer, executor and canceller are one and the same externally-owned account

This is the most important correction in the record. Round one wrote: *"USDG is the only one of the five with a real timelock"* and *"USDG is the only member of this category that satisfies law `L15`."* Both statements survive only in a form so qualified that they invert.

Swept `RoleGranted`/`RoleRevoked` over the `TimelockController` at `0x9036566EAa5f83e0b9E1161C6C602B0aDF997654` — **4 events in its entire life**:

| Timelock role | Holder | Type |
|---|---|---|
| **`PROPOSER_ROLE`** | `0x3af3e85f4f97de7ad0f000b724fb77fe5ffc024b` | **EOA** |
| **`EXECUTOR_ROLE`** | `0x3af3e85f4f97de7ad0f000b724fb77fe5ffc024b` | **EOA** |
| **`CANCELLER_ROLE`** | `0x3af3e85f4f97de7ad0f000b724fb77fe5ffc024b` | **EOA** |
| `DEFAULT_ADMIN_ROLE` | the timelock itself | self-administered |

`getMinDelay() == 86400` is confirmed. But **one externally-owned account is the sole proposer, the sole executor and the sole canceller.** There is no second party. The timelock is a 24-hour delay that one key imposes on itself and can cancel by itself. It is a publication window, not a check — nobody else can propose, nobody else can veto, and nobody else can execute.

And it governs almost nothing. Swept the USDG token proxy's own role history (18 events, from block 20,900,000):

| USDG token role | Holder | Type |
|---|---|---|
| `DEFAULT_ADMIN_ROLE` | `0x9036566E…7654` | the 24h timelock |
| **`ASSET_PROTECTION_ROLE`** (freeze, wipe) | `0x3af3e85f…c024b` | **EOA, no delay** |
| **`PAUSE_ROLE`** | `0x3af3e85f…c024b` | **EOA, no delay** |
| `CLAIM_ADMIN_ROLE` | `0x3af3e85f…c024b` | EOA |
| `CLAIM_OPERATOR_ROLE` | `0x5fd949b0fd3a994a6d7e364c82e43be23de22e38` | EOA |
| `MULT_ADMIN_ROLE` | `0x3af3e85f…c024b` | EOA |
| `MULT_RATE_ROLE` | `0x4e4336d068df68000d6d6ab326feef9ad4faeef8` · `0x3af3e85f…c024b` | both EOAs |
| `PAYOUT_GROUP_ADMIN_ROLE` | `0x3af3e85f…c024b` | EOA |
| `PAYOUT_GROUP_REGISTRAR_ROLE` | `0x55f78e37adb9d1f6931c1da7314b374558ae9684` | EOA |

Role-name preimages were recovered by pulling the verified implementation source from Blockscout and hashing every `_ROLE` token found in it, rather than guessed.

So: **the freeze key on USDG is a bare externally-owned account acting instantly, and so is the pause key, and so are the keys that administer the rewards ledger, its payout groups and its rate multiplier.** The timelock delays upgrades and role administration. Round one's `Tg`-satisfies-`L15` finding must be restated as: *USDG has a timelock over its admin role, held by the same key it delays, and no delay at all over its seizure power.*

`SupplyControl` (`0x9a716411…3bbf`) is the same picture: `DEFAULT_ADMIN_ROLE` the timelock; `SUPPLY_CONTROLLER_MANAGER_ROLE` the same EOA `0x3af3e85f…`; `SUPPLY_CONTROLLER_ROLE` held by `0x2fb074fa59c9294c71246825c1c9a0c7782d41a4` (EOA, nonce 1,701), `0xf845a0a05cbd91ac15c3e59d126de5dfbc2aabb7` (EOA, nonce 3,173) and one contract `0x147bde4f…f9c4`.

### The June 2026 attestation figures — round one's UNKNOWN, closed

Retrieved by loading https://www.paxos.com/usdg-transparency in a real browser and capturing the network request the month button fires: the reports are Framer assets, not links in the DOM. **Direct PDF: https://framerusercontent.com/assets/SYphIxdrMrJDZbAUxvuXLHoW58.pdf** (verified 200, `application/pdf`, 505,162 bytes).

*"Report on Management's Assertion regarding the Global Dollar (USDG) Redeemable Tokens and Redemption Assets as of 17 June 2026 and 30 June 2026 at 5:00 PM United States Eastern Time."* Examiner **KPMG LLP, Singapore**, signed **2026-07-24**; management signatories Wee Siang Lee (Executive Director, Paxos Digital Singapore) and Tero Reuna (Head of EU, Paxos Issuance Europe). Criteria: **AICPA 2025 Criteria for Stablecoin Reporting Part I**, plus the MAS Letter of Undertaking reserve conditions and the MiCA/EBA RTS for the PIE portion.

| US$ | 2026-06-17 | 2026-06-30 |
|---|---|---|
| Redeemable tokens outstanding | 2,757,006,607 | **2,984,505,939** |
| Cash | 129,387,243 | 112,903,118 |
| Government money market funds, at NAV | 1,330,519,463 | 1,526,753,653 |
| Repurchase agreements | 0 | **0** |
| U.S. Treasury obligations, at fair value | 1,301,811,210 | 1,350,319,213 |
| **Total redemption assets** | 2,761,717,916 | **2,989,975,984** |
| Surplus | 4,711,309 | 5,470,045 |

### CORRECTS ROUND ONE — the EU obligor's cash is supervised in Luxembourg, not Finland

Round one, from the MiCA white paper, described reserves in *"segregated, bankruptcy-remote 'trust accounts' at regulated custodians, authorised by FIN-FSA"* under Finnish insolvency law. The attestation's cash schedule says something different: Paxos Digital Singapore's segregated stablecoin-reserve account is regulated by **MAS**, geography Singapore ($108,315,707 at 2026-06-30); **Paxos Issuance Europe's segregated stablecoin-reserve account is regulated by the Commission de Surveillance du Secteur Financier (CSSF), geography Luxembourg** ($4,587,411). PIE is a Finnish EMI supervised by FIN-FSA, but the account holding EU holders' reserve cash sits under a **different national supervisor in a different member state**. Nothing in the white paper says so. The obligor, the prudential supervisor of the obligor, and the supervisor of the account holding the money are three different answers.

### Banks — no name, anywhere

The USDG report identifies its Treasury custody/counterparty relationships only as **"PDS Bank 1 in Singapore"** and **"PDS Bank 2 in Singapore"**. Government MMF holdings appear as identifiers with no fund name: CUSIP `262006208` ($1,522,763,482 at 2026-06-30) for PDS; ISINs `IE00B14RXK43` and `IE0004WWOG99` for PIE. Ten Treasury bill CUSIPs are listed (912797TF4, 912797UN5, 912797RF6, 912797TN7, 912797US4, 912797UT2, 912797UU9, 912797TX5, 912797UG0, 912797RS8), maturities 2026-07-02 to 2026-09-17, each attributed to "Bank 1" or "Bank 2."

The MiCA white paper is no better: *"Ensure these assets are held with **qualified custodians**"*; *"the funds of **the financial institution** that acts as the custodian for the trust account"*; *"Paxos EU maintains a robust banking partner due diligence process to ensure that USDG reserves are held only with **custodians and partners** who would be deemed suitable."* Regulators are named throughout; no bank ever is.

### Regulator and what it can compel

**MiCA (Regulation (EU) 2023/1114).** Art. 49 — *"Upon request by a holder of an e-money token, the issuer… shall redeem it, at any time and at par value"* and redemption *"shall not be subject to a fee"* (49(6)). Art. 54 — at least **30%** of funds received deposited in separate accounts at credit institutions, remainder in secure low-risk highly liquid instruments per Art. 38(1). Art. 94 — competent-authority powers: suspend an offer for up to 30 working days (94(1)(l)); **prohibit** an offer (94(1)(m)); order immediate cessation of unauthorised issuance (94(1)(u)); require removal of a person from the management body (94(1)(y)); on-site inspection (94(1)(w)). Art. 105 — product intervention: prohibit or restrict marketing, distribution or sale, including urgently on 24 hours' notice for up to three months. Art. 56 in the enacted text is *classification as a significant e-money token*, which transfers supervision from FIN-FSA to the **EBA** — **not** a withdrawal-of-authorisation article; there is no free-standing MiCA withdrawal power for EMT issuers, because withdrawal runs through the underlying EMD2 licence under Finnish law.

**Singapore.** MAS Stablecoin Regulatory Framework, media release 2023-08-15: *"Redemption at Par: Issuers must return the par value of SCS to holders within **five business days** from a redemption request."* Payment Services Act 2019: **s.11** lapsing/surrender/revocation/suspension of a licence; **Part 5 (ss.77–83) Emergency Powers**, notably **s.78** (action where a payment entity is unable to meet obligations) and **s.80 assumption of control** — a conservatorship-equivalent; **s.102** general written-direction power. MAS exercises s.11 in practice (licence of Bsquared Technology Pte Ltd revoked effective 2026-05-14).

### Redemption terms, exact

- **EU (Paxos Issuance Europe):** *"holders of USDG tokens can redeem their USDG for USD at a 1:1 ratio at any time without incurring fees"*; *"Only verified institutional customers who have successfully passed Paxos EU's Know-Your-Customer (KYC) and Anti-Money Laundering (AML) onboarding process can redeem USDG"*; retail holders exit through GDN partners or a support ticket.
- **Non-EU (Paxos Digital Singapore), via the Paxos US Dollar-Backed Stablecoin Terms and Conditions** (https://paxos.com/stablecoin-terms-conditions/ — this document explicitly enumerates USDG, PYUSD and USDP as covered): §2.2.2 *"Absent a reasonable justification not to redeem USD Stablecoins, and provided that you are a fully verified Customer of Paxos, your USD Stablecoins are freely redeemable"*; §2.8.2.1 *"Paxos will not charge you fees for redeeming USD Stablecoins"*; §2.7.4 *"Paxos may require a minimum amount for redemption, which may be updated from time to time, **equal to the minimum wire fee charged by your bank for the transaction**"*; §2.7.3 *"commercially reasonable efforts to redeem your USD Stablecoins quickly… processed according to the redemption schedule."* Also §2.8.3.1: a **$2.00 monthly dormancy fee** on a non-zero balance with no purchase or redemption activity for twelve months.

The §2.7.4 minimum is worth its own note: it is the only redemption minimum in the category that is **not a number set by the issuer** but a function of the *holder's own bank's* wire fee. The obligation's threshold is defined by a third party the issuer does not name and does not control.

---

## PayPal USD (PYUSD)

### CORRECTS ROUND ONE — the NYDFS→OCC transition date is 2025-12-12, with a charter number

Round one: *"the exact effective date is UNKNOWN."* Resolved from the OCC's own conditional-approval decision letter, **CA1358, dated 2025-12-12** (https://www.occ.gov/topics/charters-and-licensing/interpretations-and-decisions/2026/ca1358.pdf):

> *"The OCC hereby conditionally approves the application filed by **Paxos Trust Company, LLC (PTC)**, New York, New York, a New York state trust company, to convert to a national trust bank… The converted bank will operate under the title of **Paxos Trust Company, National Association** (Bank) under **OCC Charter Number 25379**."*

Application filed 2025-08-12 (control numbers 2025-Conversion-342828, 2025-Waiver-344112, 2025-Capital&Div-344142); conversion authority 12 U.S.C. § 35 and 12 CFR 5.24/5.13(b); the resulting bank is **uninsured**; main office 71 Fifth Avenue, New York.

Corroborated four independent ways: Paxos's own release (*"…converted its New York Department of Financial Services (NYDFS) limited purpose trust charter to a national trust charter overseen by the U.S. Office of the Comptroller of the Currency (OCC) on December 12, 2025"*); OCC news release nr-occ-2025-125 of the same date; the OCC's live active-trust-bank register (Paxos Trust Company, N.A., Charter 25379, CERT 0); and the absence of "Paxos Trust Company" from the NYDFS list of licensed virtual currency businesses (https://www.dfs.ny.gov/virtual_currency_businesses). Round one was right that one Paxos page was stale; the stale page is the transparency page.

Two further facts from CA1358 worth carrying: the letter records that **NYDFS had previously issued a Consent Order against Paxos Trust Company, LLC** (*"the OCC has considered the effect of this enforcement action and is imposing conditions related to the Bank's compliance program"*) — undated and undescribed there, so **UNKNOWN**; and **Condition #2** requires the bank to *"conform, cease, or divest its proposed collateral trustee structure and any other activities to comply with the GENIUS Act… such compliance to be determined in the sole discretion of the OCC."*

### The June 2026 attestation figures — round one's UNKNOWN, closed

**Direct PDF: https://framerusercontent.com/assets/nnDmTwtYmO3HUZnwxNhQAyeFfjs.pdf** (verified 200, `application/pdf`, 376,609 bytes). Examiner **KPMG LLP, New York**, signed **2026-07-24**; management signatory Adam Ackermann, Head of Treasury and Portfolio Management. Criteria: AICPA attestation standards, AICPA 2025 Criteria for Stablecoin Reporting Part I, **and GENIUS Act §4(a)(1)(A)** — the reserve-composition mandate is now an attestation criterion, not merely a statute.

| US$ | 2026-06-17 | 2026-06-30 |
|---|---|---|
| Redeemable tokens outstanding | 2,735,941,155 | **2,686,586,963** |
| Cash | 75,642,752 | 79,676,918 |
| Government money market funds | 0 | **0** |
| **Repurchase agreements, at fair value** | **2,665,634,000** | **2,216,594,000** |
| U.S. Treasury obligations, at fair value | 0 | 397,486,420 |
| **Total redemption assets** | 2,741,276,752 | **2,693,757,338** |
| Surplus | 5,335,597 | 7,170,375 |

**PYUSD is 82.3% overnight repurchase agreements at 2026-06-30** — the most concentrated reserve shape in the category, and the one nobody could see in round one. Counterparties are labelled **"Bank 1 in United States"** and **"Bank 2 in United States"** (at 2026-06-17: $1,206,362,000 and $1,356,397,000 par respectively, 3.60% coupon, purchase 6/17 maturity 6/18, U.S. Treasury collateral).

**One named entity appears, and it is an affiliate:** the cash account carries *$50,000,000 of excess deposit insurance from **Paxos Insurance Company Ltd**, a captive insurer*. The only institution Paxos names in connection with the reserve is one it owns.

### CORRECTS ROUND ONE — the self-reported monthly composition report no longer exists

Round one recorded a live *"two-document regime"*: a KPMG attestation plus *"a separate self-reported portfolio composition published 5 business days after month-end that is expressly 'not subjected to independent review'"*, and noted *"one where the more detailed document is the un-reviewed one."* The self-report series has been **discontinued**. The "Paxos Reports" component on the PYUSD transparency page exposes year tabs for **2025, 2024 and 2023 only — there is no 2026 tab in the DOM** — and the 2025 tab contains exactly **two months, January and February**. The newest self-report reachable is **2026-02-28's coverage of February 2025**. The series stops in the same month KPMG's examinations began (2025-02-28). It is not a scraping failure: every accordion was expanded and every year-shaped element enumerated.

This matters more than a stale-link note, because **the discontinued document is the only one in the entire category that ever named a bank.** The January 2025 self-report (https://framerusercontent.com/assets/obziSaVRQrfDPkkafqcHoKSV1sQ.pdf, verified 200, 68,139 bytes) states:

> *"Cash Deposits may be held at **State Street Bank and Trust Company** (FDIC Certificate #14), **Western Alliance Bank** (FDIC Certificate #57512), and **Customers Bank** (FDIC Certificate #34444)."*

Total tokens outstanding at 2025-01-31: $482,747,103; weighted average maturity 3 days. At 2025-02-28: $751,638,595.

So the record shows a disclosure regime that **moved from named institutions to "Bank 1 / Bank 2" at the moment it moved from self-reporting to independent examination.** Round one's residue item 12 ("assurance carve-outs as a first-class object") has a companion: assurance and disclosure traded against each other here, and the model has no way to record that the audited document says less than the unaudited one it replaced.

### Key holders — and the same key as USDG

| PYUSD role | Holder | Type |
|---|---|---|
| proxy admin (ZeppelinOS slot) | `0xc94BcF6E1d8b3558e3b62E743630D50497e3851C` | **EOA** |
| `DEFAULT_ADMIN_ROLE` / `owner()` / `defaultAdmin()` | `0x3af3e85f4f97de7ad0f000b724fb77fe5ffc024b` | **EOA** |
| **`ASSET_PROTECTION_ROLE`** (freeze, `wipeFrozenAddress`) | `0x3af3e85f…c024b` | **EOA** |
| `PAUSE_ROLE` | `0x3af3e85f…c024b` | **EOA** |
| SupplyControl `DEFAULT_ADMIN_ROLE`, `SUPPLY_CONTROLLER_MANAGER_ROLE` | `0x3af3e85f…c024b` | **EOA** |
| SupplyControl `SUPPLY_CONTROLLER_ROLE` | `0x2fb074fa…41a4` · `0xf845a0a0…aabb7` · `0xa2c323fe…6444` | two EOAs, one contract |

`defaultAdminDelay() == 10800`; `paused() == false`; Ethereum supply at block 25,686,224: **1,832,190,626.011637**.

### Redemption terms, exact — round one's largest hole, closed on both paths

**(i) The PayPal/Venmo consumer path** (https://www.paypal.com/us/legalhub/paypal/cryptocurrencies-tnc, last updated 2026-05-19; the page is a client-rendered accordion and was read by expanding every panel in a headless browser):
- **Minimum: $1.00.** *"Minimum Crypto Asset sale amount: $1.00 U.S. dollar"* (PayPal-linked); *"Minimum sale amount: $1.00 U.S. dollar"* (Venmo-linked); *"Minimum amount to convert between PYUSD and another Crypto Asset: $2.00 U.S. dollars."*
- **Fee: zero to redeem.** The Consumer Fees page tabulates 1.50%–2.20% for buying/selling crypto and then states *"The fees above do not apply to buying and selling PYUSD"* (https://www.paypal.com/us/digital-wallet/paypal-consumer-fees). **But moving PYUSD out is charged: *"you will pay 1.5% on the USD value of the PYUSD that you transfer to your external wallet."*** Redeeming into PayPal's own ledger is free; leaving PayPal's ledger costs 150 bps.
- **Latency:** no figure stated; the ToS implies same-transaction execution (*"we will execute and settle your sale with our Service Provider"*) and notes the price *"will remain fixed at $1.00 U.S. dollar."* **No SLA — UNKNOWN as a contractual figure.**

**(ii) The direct-with-Paxos institutional path.** The consumer ToS routes here explicitly (*"PYUSD… is subject to the Paxos US Dollar-Backed Stablecoin Terms and Conditions"*), and paypal.com confirms *"You may also redeem PYUSD directly with Paxos for a price of $1.00 U.S. dollar, subject to the Paxos Terms."* Those terms are the **same document** that governs USDG's non-EU path and name PYUSD in the definitions: fully verified Paxos Customer with an Account (§§2.2.2, 2.7.1); **fee $0** (§2.8.2.1); **minimum = your bank's minimum wire fee** (§2.7.4); best-efforts latency (§2.7.3).

**The finding this produces:** PYUSD has **two redemption obligations with different obligors, different minimums, different fees and different counterparties for the same token** — $1.00 and free against PayPal, a bank-determined amount and free against Paxos, with a 1.5% toll to move between the two ledgers. Round one identified the shadow ledger; the exact terms show the two ledgers are also two *contracts*, and the model's single `Rd` names one instrument where there are two.

---

## Cross-issuer findings

### One externally-owned account is the freeze key for two of the five issuers

`0x3af3e85f4f97de7ad0f000b724fb77fe5ffc024b` — code size 0, nonce 295, balance 1.013 ETH — simultaneously holds, at block 25,686,224:

- **USDG:** `ASSET_PROTECTION_ROLE` (freeze and wipe), `PAUSE_ROLE`, `CLAIM_ADMIN_ROLE`, `MULT_ADMIN_ROLE`, `MULT_RATE_ROLE`, `PAYOUT_GROUP_ADMIN_ROLE`
- **USDG `SupplyControl`:** `SUPPLY_CONTROLLER_MANAGER_ROLE`
- **USDG `TimelockController`:** `PROPOSER_ROLE`, `EXECUTOR_ROLE` **and** `CANCELLER_ROLE` — all three, alone
- **PYUSD:** `DEFAULT_ADMIN_ROLE` (= `owner()` = `defaultAdmin()`), `ASSET_PROTECTION_ROLE`, `PAUSE_ROLE`
- **PYUSD `SupplyControl`:** `DEFAULT_ADMIN_ROLE`, `SUPPLY_CONTROLLER_MANAGER_ROLE`

And **the same two externally-owned accounts** — `0x2fb074fa…41a4` and `0xf845a0a0…aabb7` — hold `SUPPLY_CONTROLLER_ROLE` on **both** USDG's and PYUSD's `SupplyControl`. Two of the five tokens in this category, presented as separate products of separate issuers under separate regulators (MAS/FIN-FSA for USDG; OCC for PYUSD), are freezable by one private key and mintable by the same pair of private keys.

The corpus decomposes these as five independent systems. On the evidence they are **four key-domains, not five**, and the correlation is invisible to any per-protocol element set — exactly the gap the bridges lane recorded as *"the holder, not the facility"*, but sharper: here the holder is shared *across* protocols, so even a party sort attached to a single protocol would not catch it. This is a **cross-protocol identity of control**, and neither the vocabulary nor the composition operator can state it.

### Every privileged key in the category is a bare private key or a quorum of bare private keys

| Issuer | Freeze / seize authority | Quorum | Delay |
|---|---|---|---|
| USDT | `MultiSigWallet` 3-of-6 | 3 of 6, **all six EOAs** | none |
| USDC | `blacklister()` | **1 EOA** | none |
| USD1 | Safe 3-of-6 (all six owners EOAs) **and** a separate EOA (nonce 0) | 3-of-6 **or** 1 | none |
| USDG | `ASSET_PROTECTION_ROLE` | **1 EOA** | none (the timelock does not cover it) |
| PYUSD | `ASSET_PROTECTION_ROLE` | **1 EOA** | none |

Not one contract signer appears anywhere in this table. There are 17 distinct externally-owned accounts behind the seizure and upgrade powers of $147bn of Ethereum-side supply. Three of the five can be frozen by a single signature.

### Three of the five obligors were conditionally chartered by the OCC on the same day

OCC news release **nr-occ-2025-125, 2025-12-12**, announced conditional approvals for five national trust bank charters: **First National Digital Currency Bank, N.A.** (de novo — Circle's *"Circle National Trust"*), **Ripple National Trust Bank** (de novo), **BitGo Bank & Trust, N.A.** (conversion — USD1's issuer), **Fidelity Digital Assets, N.A.** (conversion), and **Paxos Trust Company, N.A.** (conversion — PYUSD's and, for the US, Paxos's issuer).

Three of this category's five obligors — Circle's future issuer, USD1's present issuer, and PYUSD's present issuer — are in that single list, approved on a single day by a single supervisor. The corpus treats the five as five independent regulatory regimes. **They are converging on one.** Only Tether (El Salvador, CNAD) and USDG's non-US leg (MAS/FIN-FSA) sit outside it, and Tether's answer to that convergence was to create a *different* token, USAT, issued by a *sixth* OCC-supervised national bank.

### The GENIUS Act makes the freeze key a licence condition

**Public Law 119-27**, S.1582, signed 2025-07-18 (enrolled text, govinfo.gov `BILLS-119s1582enr.pdf`):

- **Sec. 2(16)** defines a *"lawful order"* as one that *"(A) requires a person to seize, freeze, burn, or prevent the transfer of payment stablecoins issued by the person; (B) specifies the payment stablecoins or accounts subject to blocking with reasonable particularity; and (C) is subject to judicial or administrative review or appeal."*
- **Sec. 4(a)(6)(B):** *"A permitted payment stablecoin issuer may issue payment stablecoins **only if** the issuer has the technological capability to comply, and will comply, with the terms of any lawful order."*
- **Sec. 4(a)(5)(A)(iv)** separately requires *"technical capabilities, policies, and procedures to block, freeze, and reject specific or impermissible transactions."*
- **Sec. 4(a)(1)(A)** — reserve composition: coin/currency/Fed balances, insured demand deposits (with concentration limits), Treasuries ≤93-day maturity, overnight repo and reverse repo on Treasury collateral, registered government MMFs invested solely in the foregoing, or tokenized forms. **Sec. 4(a)(2)** prohibits rehypothecation with narrow carve-outs.
- **Sec. 4(a)(1)(B)** — a public redemption policy with *"clear and conspicuous procedures for timely redemption"*; discretionary limits on timely redemption may be imposed **only** by a State qualified regulator, the FDIC, the Comptroller or the Federal Reserve; fee changes need ≥7 days' notice.
- **Sec. 2(25)(D)** — for a Federal qualified payment stablecoin issuer, the primary Federal payment stablecoin regulator is **the Comptroller** (this is BitGo Bank & Trust N.A. and Paxos Trust Company N.A.).
- **Sec. 6(b)** — enforcement: suspension or revocation of registration for wilful or reckless violation; C&D and temporary C&D under 12 U.S.C. §1818(b)/(e) procedures; removal of institution-affiliated parties; penalties under §1818(i)(1).
- **Sec. 20** — effective on the earlier of 18 months after enactment (≈2027-01-18) or 120 days after final implementing regulations. **Sec. 3(b)(1)** imposes a separate, later clock: the ban on digital-asset service providers offering a non-permitted issuer's stablecoin begins three years after enactment (≈2028-07-18).

This is a first-order correction to how the category's `Fz` should be read. The corpus treats the freeze as an issuer's discretionary control-plane power. **Under Sec. 4(a)(6)(B) it is a condition precedent to issuing at all**: an issuer that removed its freeze function would cease to be permitted to issue. `Fz` is not something these systems *have*; for the US-regulated members it is something they are *required to have*, and the requirement is now written into the attestation criteria (PYUSD's June 2026 report is examined against GENIUS §4(a)(1)(A)). A prohibition on `Fz` would, for three of the five, be a prohibition on the instrument.

---

## WHAT DETERMINES THE DOLLAR, SIDE BY SIDE

Every cell is a fact none of the 58 symbols can express, and no single issuer's disclosure produces this row. On-chain figures at block 25,686,224 (2026-08-04); attested figures at 2026-06-30.

| | **Tether USDT** | **Circle USDC** | **WLF USD1** | **Global Dollar USDG** | **PayPal USD PYUSD** |
|---|---|---|---|---|---|
| **Obligor** | Tether International, S.A. de C.V. — El Salvadoran private company | Circle Internet Financial, LLC (US) / Circle Internet Financial Europe SAS (EEA) | **BitGo Bank & Trust, N.A.** — OCC national trust bank, Charter **25366**, uninsured | **Paxos Digital Singapore Pte. Ltd.** (non-EEA) / **Paxos Issuance Europe Oy** (EEA) — obligor selected by holder residency | **Paxos Trust Company, N.A.** — OCC, Charter **25379**, uninsured, converted **2025-12-12**. Consumer's counterparty is **PayPal**, not Paxos |
| **Nature of the claim** | IFRS 9 **refund liability**; unsecured; face value only; no share of surplus | Circle asserts **bare legal title**, no beneficial interest — untested in any court, by Circle's own admission | *"contractual and **do not constitute a security interest in, or direct property interest in, any specific reserve asset**"* | e-money claim; segregated bankruptcy-remote trust accounts; **priority over unsecured creditors** in Finnish insolvency | contractual right to redeem for $1.00 (PayPal 10-Q); reserves in segregated bankruptcy-remote accounts |
| **Custodian** | **NOT DISCLOSED.** *"cash deposits at financial institutions"* (BDO report fn.7) | **The Bank of New York Mellon** — accounting agent and custodian of the Circle Reserve Fund (N-CSR, file 811-05742) | issuer is its own custodian; MMF shares held at *"a regulated U.S. financial institution"* — unnamed | *"qualified custodians"*, *"the financial institution that acts as the custodian for the trust account"* — **unnamed** | **NOT DISCLOSED** in the examined report |
| **Banks** | **NONE NAMED.** *"various third parties including banks and licensed financial institutions"* (RID p.16) | **Ten named repo counterparties** (Barclays Capital · BNP Paribas · Citibank N.A. · Citigroup Global Markets · Crédit Agricole CIB · Deutsche Bank · Goldman Sachs · J.P. Morgan Securities · Nomura · Wells Fargo Securities) — **from the fund's SEC filing, not from any USDC document**. The 10–20% FBO cash: *"primarily with banks designated by the FSB as GSIBs"*, **none named** | **NONE NAMED.** *"U.S. commercial banks"*. MMF is CUSIP 31607A703 = Fidelity Investments MMkt Government Portfolio Instl (FRGXX) — identified by us, not by the issuer | **NONE NAMED.** *"PDS Bank 1 in Singapore"*, *"PDS Bank 2 in Singapore"*. PIE cash account supervised by **CSSF, Luxembourg**; PDS by **MAS** | **NONE NAMED** in the examined report (*"Bank 1 in United States"*, *"Bank 2 in United States"*). Only named party is the affiliate **Paxos Insurance Company Ltd** ($50M excess deposit insurance). The **discontinued** self-report named **State Street Bank and Trust · Western Alliance Bank · Customers Bank** (Jan 2025) |
| **Reserve at 2026-06-30** | $187.75bn total; **cash & bank deposits $40.3M = 0.02%**; ~$23.6bn (12.6%) gold, bitcoin, equities, other investments and secured loans | $73.34bn; **88% in the Circle Reserve Fund** (2a-7 govt MMF, 70.8% overnight repo at fund FY-end); 10–20% FBO bank cash | $4.635bn; **demand deposits $1.179bn + one government MMF $3.456bn**; zero Treasuries held directly, zero repo | $2.990bn; cash $112.9M · **govt MMFs $1.527bn** · USTs $1.350bn · **repo $0** | $2.694bn; cash $79.7M · **repo $2.217bn = 82.3%** · USTs $397.5M · **MMFs $0** |
| **Who may redeem** | **819** KYC Verified Customers (2026-02-16) | **Circle Mint** account holders only. *"Users Type B are not customers of Circle"* | BitGo **Clients in Good Standing**. *"Users… do not have direct redemption rights with the Company"* | verified institutional customers onboarded to the Paxos Platform (EU: Paxos EU KYC/AML) | (i) any PayPal/Venmo Crypto Account holder; (ii) fully verified Paxos Customers |
| **Minimum** | **US$100,000** | **none** | **not published**; absent from the terms | **the minimum wire fee charged by the holder's own bank** (§2.7.4) | **(i) $1.00**  ·  (ii) holder's bank wire fee |
| **Fee** | **greater of US$1,000 or 0.1%** | **0 / 2 bps / 5 bps by tier and volume**; $2M/day free on Standard and Institutional | **exists, incorporated by reference, published only behind platform login** (`app.bitgo.com/my/mint/fees`) | **zero** (MiCA Art. 49(6); Paxos T&C §2.8.2.1). $2/month dormancy fee | **(i) $0 to redeem, 1.5% to transfer out to an external wallet**  ·  (ii) $0 |
| **Latency** | *"can take several days to process"* — **no SLA** | up to 2 business days (Basic) / near-instant (Standard, Institutional) — *"may vary"*, **no SLA** | *"typically within two business days… **is not a service level agreement or commitment**"* | *"commercially reasonable efforts"*; MAS framework requires **5 business days** for SCS issuers | (i) same-transaction, no stated figure; (ii) *"commercially reasonable efforts"* |
| **Regulator** | **CNAD**, El Salvador — Decreto Legislativo 643 | **NYDFS** BitLicense 23 NYCRR Pt 200; ACPR/AMF (EEA); **OCC preliminary conditional approval** 2025-12-12 for First National Digital Currency Bank, N.A. — **not yet in force** | **OCC** | **FIN-FSA** (MiCA EMT) + **EBA** if significant; **MAS** (PS Act 2019 MPI) | **OCC** (Paxos); **NYDFS** over PayPal, Inc. as a virtual currency business |
| **What that regulator can compel** | Suspend/cancel a public offering (Art. 9(b)); suspend/revoke DASP registration and suspend trading (9(d)); halt sale of a specific issuer's asset (9(h)); fines to 1,200 minimum wages. **No power to order a freeze, seizure or redemption of a holder's balance** | *"DFS may… prohibit or otherwise limit a stablecoin's issuance or use… and may require that any such Issuer delist, halt, or otherwise limit or curtail activity"*; §200.6(c) suspend/revoke licence; T+2 redemption mandated | 12 U.S.C. §1818(b) C&D · (c) **immediate** temporary C&D · (e) removal and industry bar · (i)(2) penalties to $1M/day · **§191 receivership appointed by the Comptroller directly** (bank is uninsured) | MiCA Art. 94: suspend an offer 30 days, **prohibit** it, order cessation of issuance, remove management; Art. 105 product intervention (24-hour urgent, 3 months); Art. 49 **mandatory par redemption, no fee**. MAS: PS Act s.11 revoke licence, **s.80 assume control**, s.102 directions; **5-business-day redemption** | same §1818/§191 as USD1. GENIUS Sec. 6(b) suspension/revocation of the right to issue. NYDFS §200.6(c) over PayPal, Inc. |
| **Freeze authority — who holds it** | `MultiSigWallet` **3-of-6**, `0xC6CDE7C3…a828` — **all six owners are EOAs**; no timelock | **`blacklister()` = one EOA**, `0x0a06be16…78f9`; no timelock; `rescuer()` = zero address | Safe **3-of-6** (`0x0d190b74…289d`, all six owners EOAs) **plus a lone EOA** `0x6802744c…ee66` (**nonce 0** — never used); no timelock; `getChecker()` = zero | **one EOA**, `0x3af3e85f…c024b`, **not covered by the 24h timelock**; that same EOA is the timelock's **sole** proposer, executor **and** canceller | **the same EOA**, `0x3af3e85f…c024b`, also `DEFAULT_ADMIN_ROLE`; no timelock |
| **Freeze exercised, measured** | **2,709 addresses currently blacklisted** (3,049 ever, 340 net removed), **853,538,431.155595 USDT destroyed** over 1,270 events / 1,173 addresses — all 2,709 re-verified against `getBlackListStatus` | Access Denied Tokens **123,219,920** at 2026-06-30; a denied token **remains a liability** until the funds go to a law-enforcement agency | **zero** access-restricted and zero time-locked tokens in the June 2026 report — armed and unused | not reported in the June 2026 report | not reported in the June 2026 report |
| **Legal trigger for the freeze** | law enforcement request; **CNAD has no such power** — the authority supervising the issuer cannot order what the issuer does | NYDFS may compel a halt; GENIUS *lawful order* | GENIUS *lawful order*; OCC §1818 | MiCA/MAS supervisory powers over issuance, not over balances | GENIUS *lawful order*; OCC §1818 |

**The reading this table forces.** The rows above the freeze rows are the instrument; the freeze rows are the model. Every entry in the obligor, custodian, banks, reserve, minimum, fee, latency and regulator rows is off-chain, and eight of those thirteen rows contain at least one cell that no primary document will fill at all. Every entry in the two key-holder rows is on-chain and is a private key. So the corpus's claim — that everything determining whether the token is worth a dollar sits outside the model — is now supported cell by cell rather than asserted: the model can see, for all five, who may freeze; it can see for none of them who holds the money.

And the sharper form found in round one — *the mechanism these systems have is mechanism about moving and controlling the receipt, never about producing the dollar* — survives round two and gains a corollary. The one apparent counterexample, USDG's 24-hour timelock, is a single externally-owned account delaying itself and able to cancel its own proposal, and it does not reach the freeze at all. The category has no governance mechanism. It has key custody, and the key custody is shared across two of the five issuers.
