# Ondo Finance — USDY, OUSG, Ondo Global Markets (Ondo Stocks)

**Research lane:** primary-source. **Access date for every URL below: 2026-08-04.**
All on-chain reads were made against Ethereum mainnet via the public JSON-RPC endpoint
`https://ethereum-rpc.publicnode.com` on 2026-08-04 (`eth_call` / `eth_getStorageAt` at `latest`).
Contract source was read from Blockscout's verified-source API (`https://eth.blockscout.com/api/v2/smart-contracts/<addr>`)
and from GitHub raw at a pinned commit.

> **STRUCTURAL WARNING FOR THE PAPER — read this first.**
> Ondo restructured USDY on **2025-12-15**. Ondo's own live documentation is now
> **internally inconsistent about who the USDY obligor is**: one page says Ondo USDY LLC (a Delaware
> SPV), another says Ondo Global Markets (BVI) Limited (a BVI SPV). Both pages are live and
> undated. Any decomposition of USDY that names a single obligor is asserting more than Ondo's
> published record supports. This is documented and quoted in §1 and §5(a).

---

## 1. WHAT IT DOES

### 1.1 USDY

**What is subscribed.** A holder sends USDC (or, for ≥$100,000, a USD bank wire) and receives USDY,
an ERC-20 whose per-token redemption price rises daily. A rebasing sibling, rUSDY, holds the price at
$1.00 and increases token count instead. Ondo: *"USDY (**US** **D**ollar **Y**ield Token) is a tokenized
note formerly issued by Ondo USDY LLC, which as of December 15, 2025 has been folded into the Ondo
Stocks umbrella."* — <https://docs.ondo.finance/general-access-products/usdy/basics.md>

**Legal claim held.** A **note** — a debt claim, not a fund share and not a security entitlement.
Ondo's archived structural description: *"Ondo USDY LLC (the "USDY entity") is structured as a special
purpose vehicle whose activities are limited to (1) borrowing funds from prospective lenders, (2) issuing
USDY tokens to evidence the LLC's debt obligations to those lenders"* —
<https://docs.ondo.finance/trust-and-security.md>. Note Ondo calls holders **"lenders"**, not investors.

**Who owes the money — CONTESTED IN ONDO'S OWN LIVE DOCS.**
- *"USDY tokens are issued by Ondo Global Markets (BVI) Limited, a British Virgin Islands business
  company."* — <https://docs.ondo.finance/general-access-products/usdy/important-notes.md>
- *"Ondo USDY LLC (the "USDY entity") is structured as a special purpose vehicle…"* and *"USDY is
  offered and sold by the USDY entity in reliance on Regulation S"* —
  <https://docs.ondo.finance/trust-and-security.md>
- *"Ondo USDY LLC can only redeem USD via bank wire to non-US bank accounts… To redeem for USDC through
  Ondo Global Markets (BVI) Limited, please go here."* —
  <https://docs.ondo.finance/general-access-products/usdy/basics.md>

  Read together, the third quote implies **two live obligors with two redemption rails** (fiat via the
  Delaware LLC, stablecoin via the BVI company). Ondo's own USDY product page still reports
  **"Issuer Domicile: United States"** (<https://ondo.finance/usdy>). I could not resolve which entity
  owes a given token — see §5(a) UNKNOWN.

**How NAV / price is determined and by whom.** Not a NAV. USDY carries a *Reference Token Price* set by
Ondo and published on-chain by an `RWADynamicOracle`. Ondo: *"Rather than storing a single current price,
the oracle is configured with a series of *ranges* — each range has a start time, end time, and a daily
interest rate that compounds across the range."* —
<https://docs.ondo.finance/developer-guides/usdy-instant-manager-integration.md>. The price therefore
**accrues deterministically on-chain between administrative updates**; it is an interest-accrual index,
not a marked portfolio value. Verified live: `getPrice()` on the USDY oracle wrapper
`0x87b126e5518b6a1Bb8465779b4607C45C643DF90` returned `1.14179424` (18 dp) on 2026-08-04.
rUSDY rebases in the same block: *"rUSDY is rebased daily at the same time the USDY price is updated."*
— <https://docs.ondo.finance/general-access-products/usdy/rebasing.md>

**How redemption works.** Two paths. (i) **Instant/on-chain**: call `redeem(rwaAmount, receivingToken,
minimumTokenReceived)` on `USDY_InstantManager` (`0xa42613C243b67BF6194Ac327795b926B4b491f15`); atomic,
USDC out. The caller must be registered in the OndoIDRegistry — *"Transactions from an address that is not
registered in the OndoIDRegistry will revert with `UserNotRegistered`."*
(<https://docs.ondo.finance/developer-guides/usdy-instant-manager-integration.md>). (ii) **Off-chain
fiat**: USD wire to a **non-US** bank account only. Non-Ethereum chains (Sui, Aptos, Stellar, XRP, Noble)
carry a **$5,000 minimum** and require emailing support. Historic (archived) off-chain terms: cut-off
**8pm UTC each Business Day**, redemption *"processed within five Business Days"*, minimum **$500** —
<https://web.archive.org/web/20251013000000id_/https://docs.ondo.finance/general-access-products/usdy/faq/investing-and-redeeming>

**Default / insolvency.** Holders have a first-priority security interest in the collateral held via
control agreements, enforced by **Ankura Trust** on tokenholder vote (§2.7, §5(b)). Recourse is
**limited to that collateral**: *"All payments to be made by the Issuer under the Offering Documents shall
only be satisfied by recourse to the sums received or recovered by or on behalf of the Issuer in respect
of any collateral relating to the Tokens. Purchasers shall have no further recourse to the Issuer."*
— <https://docs.ondo.finance/ondo-stocks/secondary-market-restrictions.md>

### 1.2 OUSG

**What is subscribed.** USDC, PYUSD, RLUSD or USD wire, for OUSG tokens. Instant mint/redeem is
Ethereum-only. Minimums: **$5,000** instant; **$100K** subscribe / **$50K** redeem non-instant.
Management fee 0.15%, *"waived until January 1, 2027"* —
<https://docs.ondo.finance/qualified-access-products/ousg/overview.md>

**Legal claim held.** A **fund share** — specifically a unitized Delaware limited partnership interest.
*"Investors become limited partners in the Fund by acquiring OUSG tokens, each of which represents a
unitized limited partnership interest in the Fund."* — <https://docs.ondo.finance/trust-and-security.md>

**Who owes the money.** **Ondo I LP**, a Delaware limited partnership (SEC CIK 0001957431). GP is
**Ondo I GP LLC**; investment manager is **Ondo Capital Management LLC**; both are wholly-owned Ondo
Finance subsidiaries (same source). Confirmed independently in the Form D/A filed 2026-01-20:
`entityName: Ondo I LP`, `jurisdictionOfInc: DELAWARE`, `industryGroupType: Pooled Investment Fund`,
`investmentFundType: Hedge Fund`, `is40Act: false` —
<https://www.sec.gov/Archives/edgar/data/1957431/000195743126000001/primary_doc.xml>

**How NAV is determined and by whom.** Ondo calculates NAV; **NAV Consulting** is the fund administrator
with read-only account access. *"our fund administrator (NAV Consulting) has direct, read-only access to
all of the Fund's accounts daily. We independently calculate the Net Asset Value of the fund each day."*
— <https://docs.ondo.finance/qualified-access-products/ousg/trust-and-transparency.md>. NAV is pushed
on-chain: *"We typically update the price once every Business Day. We typically aim to do this sometime
between 4-6pm ET but, because this is a manual process, it may sometimes take longer."* —
<https://docs.ondo.finance/qualified-access-products/ousg/yield.md>. Daily NAV uses an **estimate**
trued-up the next day: *"each Business Day the Fund makes a conservative estimate of the Net Income it
expects to receive for the day… it makes an additional adjustment to its Net Income on the following
Business Day."* (same page). Verified live: `OndoOracle.getAssetPrice(OUSG)` =
**116.118574** on 2026-08-04 (`0x9Cad45a8BF0Ed41Ff33074449B357C7a1fAb4094`).

**Redemption.** Instant redemption is atomic in one transaction. Non-instant: *"provided that you sent us
your tokens for redemption prior to 4pm ET, you will typically receive your funds the next Business Day"*
— <https://docs.ondo.finance/qualified-access-products/ousg/redeeming.md>. Instant paths are capped:
**$50M global / $25M per investor per rolling 24h**, for mint and redeem separately —
<https://docs.ondo.finance/qualified-access-products/ousg/instant-limits.md>

**Default / insolvency.** No security agent, no collateral pledge, no overcollateralisation is documented
for OUSG. Holders are limited partners with a pro-rata claim on fund assets. This is a materially weaker
position than USDY/OGM holders and Ondo does not claim otherwise anywhere I read.

### 1.3 Ondo Global Markets / Ondo Stocks (OGM)

**What is subscribed.** USDon (Ondo's own dollar token) is exchanged for a tokenised equity/ETF tracker
(`TSLAon`, `NVDAon`, …). USDC↔USDon converts 1:1 atomically inside the same transaction.
Minimum **$1.00**; minting and burning are instant —
<https://docs.ondo.finance/ondo-stocks/investing-and-redeeming.md>

**Legal claim held.** A **structured note under Swiss law**, not a share and not a security entitlement.
*"An Ondo tokenized stock is a structured note: a debt instrument issued by Ondo Global Markets (BVI)
Limited (known as the "Issuer"), a bankruptcy-remote special purpose vehicle (SPV) organized in the
British Virgin Islands (BVI). Tokenholder rights and obligations are governed by Swiss law under the
Issuer's Sales Terms."* — <https://docs.ondo.finance/ondo-stocks/legal-and-regulatory.md>
Holders explicitly get **no** shareholder rights: *"you do not have shareholder voting rights, shareholder
information rights or other shareholder rights from the issuer of the underlying securities."* (same page)

**Who owes the money.** **Ondo Global Markets (BVI) Limited**, owned *"90.01% … by Flux Finance Inc.
(a wholly owned subsidiary of the Ondo Foundation) and 9.99% owned by Ondo Finance Inc."* (same page).

**How price is determined and by whom.** By Ondo, off-chain, proprietarily, per trade. Tokens are
**total-return trackers**, so token price ≠ share price: *"over time, a given token may provide economic
exposure to more than one share."* (<https://docs.ondo.finance/ondo-stocks/overview.md>). The
shares-per-token multiplier is published on-chain (`SyntheticSharesOracle`
`0x9BC39DB6fbB44B91a48b8D5A6C208B82B1741bE6`). Execution price is a signed quote: *"we provide you a quote
for a price that's guaranteed for some amount of time (currently about 30 seconds)… does a little bit of
(proprietary) math to figure out what an appropriate quote price should be"* and the spread is *"based upon
a number of factors, including quote size, target profit, and several other proprietary considerations."*
— <https://docs.ondo.finance/ondo-stocks/token-and-quote-pricing.md>

**Redemption.** Atomic on-chain against a signed EIP-712 quote (`redeemWithAttestation`), settling in
USDon and optionally swapping to USDC subject to inventory in the swapper. Redemption to USD by wire is
**not supported** — <https://docs.ondo.finance/ondo-stocks/investing-and-redeeming.md>. Redemption is
**conditional on KYC**: *"As a condition to redeeming any of its Tokens, a Token holder must satisfy the
Issuer's customer due diligence… there is a risk that a person acquiring Tokens on secondary markets will
not meet such due diligence requirements and therefore may not be able to redeem any or all of its Tokens."*
— <https://docs.ondo.finance/ondo-stocks/secondary-market-restrictions.md>

**Default / insolvency.** Same limited-recourse + non-petition + Ankura-security-agent architecture as
USDY (§1.1, §2.7). Disputes go to **arbitration in Zurich under the Swiss Rules**, English language, and
*"Token holders are entitled to damages only (if any) and are not entitled to the remedy of specific
performance in respect of any Token."* — same page.

---

## 2. DESIGN

Terminology below is Ondo's. Each item is tagged **[ON-CHAIN]** (enforced by deployed code) or
**[LEGAL]** (an instrument, agreement or operational policy with no on-chain enforcement).

### 2.1 Token contracts and transfer restrictions

**USDY — [ON-CHAIN]**, `USDY.sol`, allowlist **AND** blocklist **AND** sanctions list, enforced in
`_beforeTokenTransfer`, checked on `msg.sender` (for third-party `transferFrom`), `from`, and `to`:
```solidity
if (from != address(0)) {                     // If not minting
  require(!_isBlocked(from),    "USDY: 'from' address blocked");
  require(!_isSanctioned(from), "USDY: 'from' address sanctioned");
  require(_isAllowed(from),     "USDY: 'from' address not on allowlist");
}
```
— <https://github.com/ondoprotocol/usdy/blob/3912ca0698c2992e4db997d0855e62588c44e2c0/contracts/usdy/USDY.sol>

**The allowlist is currently a no-op stub.** Live on mainnet, `USDY.allowlist()` returns
`0x5cd9e3a4c9933133b512da1b6ba4672160e0c665`, whose verified source is:
```solidity
contract AllowlistStub is IAllowlistStub {
  function isAllowed(address) external pure returns (bool) {
    return true;
  }
}
```
(Blockscout verified name `AllowlistStub`, license header `BUSL-1.1`.) I confirmed behaviourally that
`isAllowed()` returns `true` for an address that has never transacted
(`0x0000000000000000000000000000000000001234`). **This is the mechanism behind Ondo's "permissionless
yieldcoin" marketing** (<https://ondo.finance/usdy>): the gate is installed and wired but disabled.
`setAllowlist(address)` is callable by `LIST_CONFIGURER_ROLE` (**1 holder** on-chain), so the gate can be
re-armed in a single transaction with no timelock.

**OUSG — [ON-CHAIN]**, `CashKYCSenderReceiver.sol` (impl `0x1ceb44b6e515abf009e0ccb6ddafd723886cf3ff`),
a genuine **allowlist**: every transfer requires all three parties to be KYC'd.
```solidity
require(_getKYCStatus(_msgSender()),
  "CashKYCSenderReceiver: must be KYC'd to initiate transfer");
```
Membership lives in `OndoIDRegistry` (`0xcf6958D69d535FD03BD6Df3F4fe6CDcd127D97df`), whose state is
`mapping(address /*rwaToken*/ => mapping(address /* user */ => bytes32 /* userID */))` — i.e. the registry
binds an on-chain address to an **off-chain user identity**, per RWA token.

**Ondo Stocks (GM tokens) — [ON-CHAIN], and materially different: DENYLIST ONLY, no allowlist.**
`GMToken._beforeTokenTransfer` calls `_checkIsCompliant`, which routes
`GMToken → OndoComplianceGMView (0x54a8757c2fef8649830b158a8c19d3a670e80318) → OndoCompliance
(0x156f73fc73197555e950743cb2b23f411c751002)`, whose check is:
```solidity
function checkIsCompliant(address rwaToken, address user) external view override {
  if (address(rwaTokenToBlocklist[rwaToken]) != address(0) &&
      rwaTokenToBlocklist[rwaToken].isBlocked(user)) revert UserBlocked();
  if (address(rwaTokenToSanctionsList[rwaToken]) != address(0) &&
      rwaTokenToSanctionsList[rwaToken].isSanctioned(user)) revert UserSanctioned();
}
```
**Consequence:** anyone not blocked or sanctioned can *receive and hold* a tokenised equity, but only a
KYC'd party can *mint or redeem* it with the issuer (§1.3). Holding is permissionless; the primary market
is gated. Sanctions screening is Chainalysis: *"We currently use Chainalysis sanctions oracle as the
sanctions list."* — <https://github.com/ondoprotocol/usdy> README.

### 2.2 Freeze / forced transfer

- **Blocklist — [ON-CHAIN].** `Blocklist` `0xd8c8174691d936E2C80114EC449037b13421B0a8` (Ethereum);
  separate deployments on BNB Chain and Mantle. Blocking an address freezes it in both directions.
- **Admin burn — [ON-CHAIN], present in code, currently unassigned.** Every Ondo token carries
  `function burn(address from, uint256 amount) external onlyRole(BURNER_ROLE)` with the comment
  *"This function can be considered an admin-burn"*. Live role census on 2026-08-04:
  `BURNER_ROLE` member count is **0** on USDY, **0** on OUSG, **0** on NVDAon. The power exists and is
  grantable by `DEFAULT_ADMIN_ROLE` at will; today nobody holds it.
- **Forced transfer — ABSENT.** No `forceTransfer` / `seize` / `recover` function exists in any Ondo
  contract I read. Ondo can destroy value (burn) and can immobilise it (block), but cannot move a holder's
  tokens to a chosen address.

### 2.3 Pause / guardian — [ON-CHAIN]

`PAUSER_ROLE` on USDY: **2** holders — the 4-of-7 admin Safe `0x1a694a09494e214a3be3652e4b343b7b81a73ad7`
and `0x2e55b738f5969eea10fb67e326bee5e2fa15a2cc`. The latter is a **Gnosis Safe with threshold 1 of 9
owners** — a hot guardian: any one of nine signers can halt USDY. The identical address holds `PAUSER_ROLE`
on OUSG and `EXECUTOR_ROLE`+`CANCELLER_ROLE` on the Ondo Stocks timelock. `paused()` returned `false` for
both USDY and OUSG on 2026-08-04. GM tokens have a separate per-token pause (`TokenPauseManager`
`0xfd48112e448417ca79305a518c4186df4b0a200a`, error `TokenPaused()`), used for market-hours and
corporate-action halts.

### 2.4 Price / NAV feed — [ON-CHAIN] publication of an [LEGAL]/operational determination

- **USDY**: `RWADynamicOracle` — range-based compounding accrual (§1.1). Reading interface is
  `USDYOracleWrapper` `0x87b126e5518b6a1Bb8465779b4607C45C643DF90`; Ondo calls it
  *"A stable entry point for reading the USDY price."* Cadence: rates set administratively, price accrues
  continuously between updates, rebase daily.
- **OUSG**: `OndoOracle` `0x9Cad45a8BF0Ed41Ff33074449B357C7a1fAb4094`, pushed once per Business Day,
  4–6pm ET, **manually**. A **legacy** oracle `0x0502c5ae08E7CD64fe1AEDA7D6e229413eCC6abe` was bounded —
  *"The price can only be set +/- 74 bps relative to the price movement of the BlackRock Short-term US
  Treasuries (SHV) ETF"* (<https://docs.ondo.finance/addresses.md>). **The current `OndoOracle` carries no
  such documented bound**; I found no sanity-band on the live OUSG price setter.
- **Ondo Stocks**: there is **no continuous on-chain price feed for execution**. Price arrives as an
  **off-chain EIP-712-signed `Quote`** consumed per trade, with `attestationId` replay protection and an
  `expiration`. The on-chain oracle (`SyntheticSharesOracle`) publishes only the shares-per-token
  multiplier. Quote struct and verification flow: <https://docs.ondo.finance/api-reference/smart-contracts.md>

### 2.5 Subscription / redemption path and cut-offs

| Product | Instant path | Non-instant path | Cut-off | Settlement |
|---|---|---|---|---|
| USDY | `USDY_InstantManager.subscribe/redeem`, atomic **[ON-CHAIN]** | USD wire to non-US bank **[LEGAL]** | 8pm UTC (archived terms) | within 5 Business Days |
| OUSG | `OUSG_InstantManager`, atomic, $5K min, $50M/$25M 24h caps **[ON-CHAIN]** | email support, $100K/$50K min | 4pm ET | next Business Day |
| OGM | `GMTokenManager.mintWithAttestation/redeemWithAttestation`, atomic, $1 min **[ON-CHAIN]** | n/a (no wire redemption) | 30-second quote validity | atomic |

Business Day is defined off-chain: *"any day that is not (a) a Saturday, (b) Sunday, (c) any other day on
which banks in Wilmington, Delaware, are authorized or obligated by law or executive order to be closed or
(d) any other day on which the Federal Reserve Bank of Philadelphia is closed."* —
<https://web.archive.org/web/20251013000000id_/https://docs.ondo.finance/general-access-products/usdy/faq/investing-and-redeeming>

### 2.6 The 40–50 day USDY lockup — [LEGAL] basis, [ON-CHAIN] enforcement, **currently dormant**

Ondo's own (now-removed) wording: *"you will not be able to claim your transferable Tokens until the
Restricted Period for your Certificate ends; this is usually between 40 and 50 days from the time you
deposited funds (depending upon exactly when we received your investment)."* — same archived URL.
Before issuance the lender holds a **Temporary Global Certificate**; USDYc
(`0xe86845788d6e3e5c2393ade1a051ae617d974c09`) is *"An onchain bookkeeping representation of the Temporary
Global Certificate representing a lender's rights to payment during the period before their USDY tokens
are issued"* (<https://docs.ondo.finance/addresses.md>).

The enforcement is **not** a hard-coded constant. In `USDYManager.sol` the gate is an arbitrary,
role-set timestamp:
```solidity
function setClaimableTimestamp(uint256 claimTimestamp, bytes32[] calldata depositIds)
  external onlyRole(TIMESTAMP_SETTER_ROLE) { ... }
...
if (depositIdToClaimableTimestamp[depositId] > block.timestamp) { revert MintNotYetClaimable(); }
```
— <https://github.com/ondoprotocol/usdy/blob/3912ca0698c2992e4db997d0855e62588c44e2c0/contracts/usdy/USDYManager.sol>
There is **no `40`, no `50`, no constant** anywhere. The 40–50 days is a policy value typed into a setter.
**Status today: dormant.** `USDYc.totalSupply()` = **0** on 2026-08-04, the language is absent from all
current docs, and the live `USDY_InstantManager` mints atomically with no claimable-timestamp gate. See
§5(f).

### 2.7 Collateral agent / security agreement — **CONFIRMED: Ankura Trust Company** — [LEGAL]

For USDY (archived): *"investors in USDY have what's known as a "first security interest" in USDY's
underlying bank deposits and Treasuries, with Ankura Trust acting as the collateral agent. As part of
maintaining these security interests, we have entered into control agreements with Ankura Trust and each
of the banks and custodians holding assets backing USDY."* —
<https://web.archive.org/web/20251013000000id_/https://docs.ondo.finance/general-access-products/usdy/faq/trust-and-transparency>

For Ondo Stocks (current): *"Ankura Trust Company serves as the Verification Agent and Security Agent for
Ondo Stocks… Holds a first-priority security interest in the underlying securities that serve as collateral
for Ondo Stocks' obligations to its tokenholders."* —
<https://docs.ondo.finance/ondo-stocks/trust-and-transparency.md>

Secondary-market buyers are bound automatically: *"Each person who acquires Tokens on the secondary market,
by acquiring such Tokens, appoints Ankura Trust Company, LLC as the Security Agent."* —
<https://docs.ondo.finance/ondo-stocks/secondary-market-restrictions.md>

**Enforcement requires a tokenholder vote** — this is the single most under-modelled feature:
*"These agreements give Ankura the legal right and obligation in its role as Collateral Agent, subject to
USDY Tokenholder approval, to take control of USDY's assets and repay Tokenholders upon the occurrence of
certain events of default and upon acceleration of the loans by the vote of USDY holders. The events that
trigger such an action include a failure to repay redemptions, a failure to keep USDY adequately
capitalized, or Ondo USDY LLC filing for bankruptcy."* (archived trust page).
Nothing on-chain implements this vote. It is a contractual governance right exercised off-chain.

### 2.8 Register of record / transfer agent — [LEGAL]

**No transfer agent is named for any product** in anything I fetched. NAV Consulting is the OUSG **fund
administrator**, not a transfer agent. Attestation/verification is Ankura Trust (daily). See §5(d) for the
per-product answer and the honest UNKNOWNs.

### 2.9 Control plane — [ON-CHAIN], verified addresses

All of USDY, rUSDY, OUSG, USDYc, OndoIDRegistry and USDon are **EIP-1967 upgradeable proxies**
(non-zero implementation slot `0x360894…`). GM tokens are **BeaconProxies**. Verified 2026-08-04:

| Contract | Address | Proxy? | ProxyAdmin | Admin owner | Timelock? |
|---|---|---|---|---|---|
| USDY | `0x96F6eF951840721AdBF46Ac996b59E0235CB985C` | EIP-1967 | `0x3ed61633057da0bc58f84b2b9002845e56f94c19` | Safe `0x1a694a09494e214a3be3652e4b343b7b81a73ad7` **4-of-7** | **NO** |
| rUSDY | `0xaf37c1167910ebC994e266949387d2c7C326b879` | EIP-1967 | `0xd037a4c1c6b7368cad2537c67e0dc75369d252e9` | same Safe **4-of-7** | **NO** |
| USDYc | `0xe86845788d6e3e5c2393ade1a051ae617d974c09` | EIP-1967 | `0x14f79cdfac1b10126d66788035e52fe77b70ca38` | same Safe **4-of-7** | **NO** |
| OUSG | `0x1B19C19393e2d034D8Ff31ff34c81252FcBbee92` | EIP-1967 | `0xba80aa44cc25e85cc30359150dfb1c7d041cf6d5` | Safe `0xaed4caf2e535d964165b4392342f71bac77e8367` **4-of-7** | **NO** |
| OndoIDRegistry | `0xcf6958D69d535FD03BD6Df3F4fe6CDcd127D97df` | EIP-1967 | `0x988d740a4365d9d8106fc71aa691ddd2527c07ff` | Safe `0x5ae21c99fc5f1584d8cb09a298cffd92b5d178ef` **3-of-5** | **NO** |
| USDon | `0xAcE8E719899F6E91831B18AE746C9A965c2119F1` | EIP-1967 | `0x5244a3d8e6534d253c11b9459a4c4c6d3b2361dd` | **TimelockController** `0x3715b2154d2ff4c5b027c7a1f734b53f27bc34f1` | **YES, 7200 s** |
| GM tokens (all 444 on Ethereum) | e.g. NVDAon `0x2D1F7226Bd1F780AF6B9A49DCC0aE00E8Df4bDEE` | **BeaconProxy** → beacon `0x985462c9aa4d6c3ad59ae6e1e9c0c11347ed1598` | beacon `owner()` | **same TimelockController** | **YES, 7200 s** |

Timelock composition (verified via `getRoleMemberCount`/`getRoleMember`):
`PROPOSER_ROLE` = 1 → Safe `0x71a4d411b5f7941dee020417fca30413712f1646` (**4-of-7**);
`EXECUTOR_ROLE` = 2 → `0x2e55b738…` (**1-of-9 Safe**) and `0xff1621ee754512b34a6bd62a941cc4d5e4d0b85b` (**EOA**);
`CANCELLER_ROLE` = same two; `TIMELOCK_ADMIN_ROLE` = **0** (renounced — good practice).
`getMinDelay()` = **7200 seconds = 2 hours**.

**Two consequences the vocabulary should capture.** (i) The Ondo Stocks timelock is **2 hours**, which is
an operational safety delay, not a governance review window. (ii) **One beacon upgrade changes the code of
all 444 Ethereum GM tokens simultaneously** — a fan-out that `Up` alone does not express.

USDY role census (2026-08-04): `DEFAULT_ADMIN_ROLE` = 1 (the 4-of-7 Safe); `MINTER_ROLE` = 4
(legacy `USDYManager` `0x25a103a1…`, LayerZero OFT adapter `0xa6275720…`, the admin Safe itself,
`USDY_InstantManager` `0xa42613c2…`); `PAUSER_ROLE` = 2; `BURNER_ROLE` = 0; `LIST_CONFIGURER_ROLE` = 1.
OUSG: `DEFAULT_ADMIN_ROLE` = 1 (Safe); `MINTER_ROLE` = 2; `PAUSER_ROLE` = 2; `BURNER_ROLE` = 0;
`KYC_CONFIGURER_ROLE` = 1. NVDAon: `DEFAULT_ADMIN_ROLE` = 1 (**the TimelockController itself**);
`MINTER_ROLE` = 2 (`GMTokenManager` + `0x66297414b401f8c5c33ad9b245c9f6e009c879b4`); `BURNER_ROLE` = 0.

### 2.10 Cross-chain — [ON-CHAIN] with a federated trust assumption

LayerZero V2 OFT (burn-and-mint), Ethereum adapter `0xa6275720b3fB1Efe3E6EF2b5BF2293148852307D`
(which holds `MINTER_ROLE` on USDY — bridging literally mints). Ondo: *"Ondo has employed LayerZero's OFT
(Omnichain Fungible Token) standard to allow users to burn and mint **native USDY and Ondo Stocks** on all
supported chains."* The DVN set is **Canary DVN, LayerZero Labs DVN, and Ondo DVN** — *"Our custom Ondo DVN
was built with unique validation specifically for bridging USDY and Ondo Stocks."* Rate limits are in the
contracts: USDY EVM↔EVM **450,000 out / 500,000 in per pathway per day**; Solana↔EVM 250,000/300,000;
Ondo Stocks ≈$450,000/day/asset/direction, HyperEVM ≈$180,000. —
<https://docs.ondo.finance/tools/ondo-bridge.md>. This is **attestation-quorum** security with one of three
attestors being Ondo itself; it is not proof-verified messaging.

### 2.11 Peg-swap module — [ON-CHAIN]. Ondo names it exactly.

`USDonManager` `0x05CCbB4b74854f8A067b83475E8c34f5a413D7e1` — Ondo's description:
*"The Ondo PSM (Peg Stability Module) smart contract for USDon, facilitating swaps between USDon and USDC."*
— <https://docs.ondo.finance/addresses.md>. Inventory-constrained, not algorithmic: *"the ability to
instantly swap USDC to/from USDon depends upon the stablecoin swapper having sufficient amounts of the
other token available."* Access-gated: *"by default, users are not whitelisted to swap between USDon and
USDC."* — <https://docs.ondo.finance/ondo-stocks/investing-and-redeeming.md>. Live `USDon.totalSupply()`
= **29,998,093.04** on 2026-08-04.

### 2.12 Fund / SPV structure and jurisdiction

| Product | Issuer | Jurisdiction | Exemption | Bankruptcy-remote claimed? |
|---|---|---|---|---|
| USDY | Ondo USDY LLC **and/or** Ondo Global Markets (BVI) Ltd — see §5(a) | Delaware / BVI | Regulation S | Yes |
| OUSG | Ondo I LP (GP: Ondo I GP LLC; IM: Ondo Capital Management LLC) | Delaware | Reg D Rule 506(c) + ICA §3(c)(7) | **No — not claimed** |
| OGM / Ondo Stocks | Ondo Global Markets (BVI) Limited | British Virgin Islands; Swiss governing law; Zurich arbitration | Regulation S | Yes |

Ondo USDY LLC is *"registered as a money services business with the Financial Crimes Enforcement Network"*
(FinCEN) — <https://docs.ondo.finance/trust-and-security.md>.

### 2.13 Ondo Chain — **CANCELLED. Replaced by "Ondo Network" on 2026-07-27.**

Ondo's own announcement (dated *"Jul 27, 2026"*): *"Today we're introducing the Ondo Network: the execution
layer for a new generation of financial markets — fast and private like a centralized exchange, verifiable
like a blockchain, and non-custodial in design."* and *"When we first announced Ondo Chain, we set out to
build a blockchain because that seemed like the best approach to reaching that goal… we came to the
realization that achieving our objectives doesn't require us to build a chain in the traditional sense at
all."* The architecture: *"speed and privacy provided by off-chain secure hardware enclaves, and
verifiability by a decentralized set of attestors who control which code the enclaves are allowed to run,
and who hold the keys the system needs to operate. Asset transfers settle on a public blockchain."*
— <https://ondo.finance/ondo-chain>
**There is no Ondo L1 mainnet.** The first application is Ondo Perps. Note the docs index at
<https://docs.ondo.finance/llms.txt> contains **no Ondo Chain section**, though a stale
`docs.ondo.finance/ondo-chain/faq` URL still surfaces in search.

### 2.14 Flux Finance — **no longer Ondo-operated**, but the entity name persists

*"A fork of Compound v2, Flux Finance is a protocol we developed as an onchain Treasury repo marketplace…
We have since sold the protocol to the Ondo Foundation."* — <https://docs.ondo.finance/protocols/flux.md>.
Per the paper's scope rule, **Flux is out of scope as a protocol**. But note the name recurs as a *legal*
entity: **Flux Finance Inc.** is the 90.01% owner of Ondo Global Markets (BVI) Limited and the vehicle
through which the Ondo Foundation *"has guaranteed funds to further collateralize Ondo Stocks' obligations
to tokenholders"* (<https://docs.ondo.finance/ondo-stocks/trust-and-transparency.md>). Do not conflate the
two.

---

## 3. REPO

**The substance of Ondo is a set of funds and legal wrappers plus a partially-open contract suite. Say so
explicitly in the paper.** The economically decisive machinery — who owes the money, the security
agreement, the control agreements, the offering documents, the NAV determination, the quote pricing — is
**legal and operational, not code**. Ondo states this directly: *"To comply with US laws and regulations,
we are only able to provide such materials to investors who successfully complete our onboarding process
to prove eligibility."* (<https://docs.ondo.finance/ondo-stocks/investing-and-redeeming.md>). **I could not
obtain a single offering document, PPM, note indenture, security agreement or control agreement. All are
KYC-gated. Every legal-structure claim in this file therefore rests on Ondo's own summary prose, not on the
instruments.**

### 3.1 GitHub

Org: **<https://github.com/ondoprotocol>** ("Ondo Finance", org id 79026118, **15 public repos**).
Most repos are forks of third-party infrastructure (DefiLlama adapters, Chainlink external adapters).
Ondo's own protocol repos:

| Repo | Language | License (GitHub metadata) | Default branch HEAD (2026-08-04) | Last push |
|---|---|---|---|---|
| `ondoprotocol/usdy` | Solidity | **none declared** (files carry `BUSL-1.1` headers) | `3912ca0698c2992e4db997d0855e62588c44e2c0` | 2024-06-12 |
| `ondoprotocol/global-markets-solana` | Rust | `NOASSERTION` (has `LICENSE.md`) | `d1d011ea3008afe6131ce69a46bc53e954503eb8` | 2026-07-15 |
| `ondoprotocol/ondo-global-markets-token-list` | JSON | none | `cf97552db394cc10bffab7ac942805a89a882039` | 2026-07-22 |
| `ondoprotocol/usdy-noble` | Go | `NOASSERTION` | — | 2024-11-07 |
| `ondoprotocol/usdy-aptos` | Move | `NOASSERTION` | — | 2024-08-30 |

`ondoprotocol/usdy` top level: `.env.example`, `.github`, `.gitignore`, `.gitmodules`, `.prettierrc.json`,
`README.md`, `contracts`, `deploy`, `forge-tests`, `foundry.toml`, `hardhat.config.ts`, `lib`,
`package.json`, `scripts`, `yarn.lock`. Under `contracts/`: `RWAHub.sol`,
`RWAHubOffChainRedemptions.sol`, `Pricer.sol`, `PricerWithOracle.sol`, `rwaOracles/`, `sanctions/`,
`usdy/{USDY.sol, USDYManager.sol, USDYFactory.sol, allowlist/, blocklist/}`.

**Gap — record this.** `docs.ondo.finance/addresses.md` links OUSG's source to
`https://github.com/ondoprotocol/tokenized-funds/blob/main/contracts/token/CashKYCSenderReceiver.sol`.
**That repository returns HTTP 404** (`gh api repos/ondoprotocol/tokenized-funds` → `{"message":"Not
Found","status":"404"}`). **The OUSG token has no public canonical repository.** No EVM repository exists
for the Ondo Stocks / GM contracts either — only the Solana program is open-sourced.

### 3.2 Do deployed contracts match the repo?

**Partially, and only for USDY.** The `USDY.sol` and `USDYManager.sol` I read at commit `3912ca06` match the
structure of the deployed logic (same roles, same `_beforeTokenTransfer` shape). But the repo has not been
pushed since **2024-06-12**, while `USDY_InstantManager`, `OndoIDRegistry`, `USDYOracleWrapper`,
`AllowlistStub`, the entire GM stack and the USDon PSM are all **live on mainnet and absent from the repo**.
The repo is a historical snapshot, not the deployed system. **What IS verifiable is on-chain**: every
address below returned `is_verified: true` from Blockscout with full Solidity source, compiler
`0.8.16+commit.07a793`:

| Contract | Address | Verified name |
|---|---|---|
| OUSG (proxy) | `0x1B19C19393e2d034D8Ff31ff34c81252FcBbee92` | `TokenProxy` (eip1967) |
| OUSG impl | `0x1ceb44b6e515abf009e0ccb6ddafd723886cf3ff` | `CashKYCSenderReceiver` |
| OndoIDRegistry impl | `0x136f28d64b658460abdd418da5c156be74d05213` | `OndoIDRegistry` |
| USDon impl | `0x267e11bb559f5d392e498cdd0e2342057031a2cf` | `USDon` |
| USDonManager (PSM) | `0x05CCbB4b74854f8A067b83475E8c34f5a413D7e1` | `USDonManager` |
| GMTokenManager | `0x2c158BC456e027b2AfFCCadF1BDBD9f5fC4c5C8c` | `GMTokenManager` |
| GM token impl (all 444) | `0xebbcb2cee51c2fee4062c9c1270dcb98b0b22250` | `GMToken` |
| GM compliance view | `0x54a8757c2fef8649830b158a8c19d3a670e80318` | `OndoComplianceGMView` |
| GM compliance root | `0x156f73fc73197555e950743cb2b23f411c751002` | `OndoCompliance` |
| USDY allowlist (live) | `0x5cd9e3a4c9933133b512da1b6ba4672160e0c665` | `AllowlistStub` |
| USDY blocklist | `0xd8c8174691d936E2C80114EC449037b13421B0a8` | `Blocklist` |
| GM pause manager | `0xfd48112e448417ca79305a518c4186df4b0a200a` | `TokenPauseManager` |

### 3.3 Live on-chain magnitudes (Ethereum mainnet, `totalSupply()`, 2026-08-04)

| Token | Address | Supply | Unit price | Ethereum-only value |
|---|---|---|---|---|
| USDY | `0x96F6eF951840721AdBF46Ac996b59E0235CB985C` | 971,769,422.46 | $1.14179424 | **≈$1.110B** |
| rUSDY | `0xaf37c1167910ebC994e266949387d2c7C326b879` | 11,862,015.98 | $1.00 | ≈$11.86M |
| USDYc | `0xe86845788d6e3e5c2393ade1a051ae617d974c09` | **0** | — | **$0 (dormant)** |
| OUSG | `0x1B19C19393e2d034D8Ff31ff34c81252FcBbee92` | 1,429,129.29 | $116.118574 | ≈$165.9M |
| USDon | `0xAcE8E719899F6E91831B18AE746C9A965c2119F1` | 29,998,093.04 | $1.00 | ≈$30.0M |
| NVDAon | `0x2D1F7226Bd1F780AF6B9A49DCC0aE00E8Df4bDEE` | 88,282.57 | — | — |
| AAPLon | `0x14c3abF95Cb9C93a8b82C1CdCB76D72Cb87b2d4c` | 15,097.03 | — | — |

Token universe: `ondo-global-markets-token-list` v11.0.0 lists **888 tokens — 444 on Ethereum (chainId 1)
and 444 on BNB Chain (chainId 56)**.

### 3.4 Audits

Ondo publishes 24 audit reports at <https://docs.ondo.finance/audits.md>: Ondo Stocks by Cantina (Feb 2026,
Dec 2025 ×2, Nov 2025, Oct 2025), Zellic (Dec 2025), FYEO (Nov 2025, Sep 2025), Cyfrin (Jul 2025), Spearbit
(Jun 2025); USDY/funds by Spearbit (Mar 2025), Halborn (Feb 2025), Code4rena (Apr 2024, Sep 2023, Jan 2023),
Cyfrin (Apr 2024), Zokyo (Aug 2023), Nethermind (Apr 2023). Note the PDFs are hosted on a **Vercel preview
domain** (`docs-v2-git-prod-ondo-docs.vercel.app`), not on an Ondo-controlled apex domain — a durability
weakness worth a footnote.

---

## 4. EVIDENCE

### Ondo documentation — `docs.ondo.finance` (all accessed 2026-08-04)

| Claim | URL |
|---|---|
| USDY is a tokenized note; folded into Ondo Stocks 2025-12-15; two redemption rails; $5,000 min on non-EVM chains; rUSDY wrapper mechanics | <https://docs.ondo.finance/general-access-products/usdy/basics.md> |
| USDY issued by Ondo Global Markets (BVI) Limited; Reg S; not a '40 Act company | <https://docs.ondo.finance/general-access-products/usdy/important-notes.md> |
| Daily rebase coincident with price update | <https://docs.ondo.finance/general-access-products/usdy/rebasing.md> |
| USDY vs rUSDY accrual comparison | <https://docs.ondo.finance/general-access-products/usdy/usdy-vs-rebasing-usdy.md> |
| Ondo USDY LLC SPV purpose clause; FinCEN MSB; Ondo I LP GP/LP structure; 506(c) + 3(c)(7); BUIDL named | <https://docs.ondo.finance/trust-and-security.md> |
| OUSG NAV mechanics, instant mint/redeem, minimums, fee waiver to 2027-01-01 | <https://docs.ondo.finance/qualified-access-products/ousg/overview.md> |
| NAV Consulting as administrator; annual audits; 3-day reporting lag | <https://docs.ondo.finance/qualified-access-products/ousg/trust-and-transparency.md> |
| Ondo I LP as OUSG issuer; 506(c); 3(c)(7) | <https://docs.ondo.finance/qualified-access-products/ousg/regulatory-compliance.md> |
| OUSG 4pm ET cut-off; T+1 | <https://docs.ondo.finance/qualified-access-products/ousg/redeeming.md> |
| $50M global / $25M individual 24h instant caps | <https://docs.ondo.finance/qualified-access-products/ousg/instant-limits.md> |
| Manual daily NAV push 4–6pm ET; estimate-then-adjust | <https://docs.ondo.finance/qualified-access-products/ousg/yield.md> |
| OGM issues structured notes; BVI SPV; Swiss law; Ankura security interest; ownership 90.01% Flux Finance Inc. / 9.99% Ondo Finance Inc.; Reg S only | <https://docs.ondo.finance/ondo-stocks/legal-and-regulatory.md> |
| Bankruptcy remoteness structure; independent director; Ankura roles; daily attestations; Foundation guarantee fund | <https://docs.ondo.finance/ondo-stocks/trust-and-transparency.md> |
| Limited recourse; non-petition covenant (1 year + 1 day); Ankura appointed by acquisition; Zurich arbitration; no specific performance | <https://docs.ondo.finance/ondo-stocks/secondary-market-restrictions.md> |
| Total-return tracker; 30-second quotes; proprietary spread; scaled UI | <https://docs.ondo.finance/ondo-stocks/token-and-quote-pricing.md> |
| $1 minimum; USDon as settlement token; swapper inventory constraint; swap whitelist; no USD wire redemption | <https://docs.ondo.finance/ondo-stocks/investing-and-redeeming.md> |
| GM tokens transferable across Ethereum/BNB/Solana/HyperEVM | <https://docs.ondo.finance/ondo-stocks/transferability.md>, <https://docs.ondo.finance/ondo-stocks/technical.md> |
| Full contract address register incl. USDYc description, PSM description, legacy 74bps oracle bound | <https://docs.ondo.finance/addresses.md> |
| EIP-712 `Quote` struct; `mintWithAttestation` / `redeemWithAttestation` | <https://docs.ondo.finance/api-reference/smart-contracts.md> |
| `RWADynamicOracle` range-compounding; OndoIDRegistry `UserNotRegistered` gate | <https://docs.ondo.finance/developer-guides/usdy-instant-manager-integration.md> |
| LayerZero V2 OFT; 3 DVNs incl. Ondo DVN; per-pathway daily rate limits | <https://docs.ondo.finance/tools/ondo-bridge.md> |
| Flux Finance sold to Ondo Foundation | <https://docs.ondo.finance/protocols/flux.md> |
| 24 audit reports | <https://docs.ondo.finance/audits.md> |
| Complete docs index (used to enumerate all pages; contains **no** Ondo Chain section) | <https://docs.ondo.finance/llms.txt> |

### Ondo archived documentation — Wayback Machine (snapshot 2025-10-13, accessed 2026-08-04)

| Claim | URL |
|---|---|
| **3% first-loss position**; Ankura as collateral agent; control agreements; default triggers; two US banks (G-SIB A+, and BBB+); 99%+ Treasuries target; board = Allman, Schmidt, Derivaux | <https://web.archive.org/web/20251013000000id_/https://docs.ondo.finance/general-access-products/usdy/faq/trust-and-transparency> |
| **"between 40 and 50 days"** Restricted Period; Temporary Global Certificate; **8pm UTC cut-off**; Business Day definition; $500 minimum; 5 Business Day redemption; bearer-instrument statement; USDC de-peg risk allocation | <https://web.archive.org/web/20251013000000id_/https://docs.ondo.finance/general-access-products/usdy/faq/investing-and-redeeming> |

### SEC EDGAR (accessed 2026-08-04)

| Claim | URL |
|---|---|
| Ondo I LP, CIK 0001957431, Delaware; Form D 2023-01-11; D/A 2024-01-19, 2025-01-21, **2026-01-20**; Pooled Investment Fund / Hedge Fund; `is40Act: false`; exemptions **06c, 3C, 3C.7**; security type "Limited Partnership Interests"; **minimum investment $5,000**; **total amount sold $1,857,726,909**; **84 investors**; first sale 2023-02-06; related persons Ondo I GP LLC, Ondo Capital Management LLC, Lee Zasadowski; Greenwich CT | <https://www.sec.gov/Archives/edgar/data/1957431/000195743126000001/primary_doc.xml> |
| Filing index for Ondo I LP | <https://data.sec.gov/submissions/CIK0001957431.json> |
| Ondo Finance Inc., CIK 0001949480, Delaware, single Form D 2022-10-05 (its own venture raise) | <https://data.sec.gov/submissions/CIK0001949480.json> |
| **NEGATIVE RESULT:** no EDGAR registrant exists for "Ondo USDY LLC" or "Ondo Global Markets". Company-name search for "ondo" returns only CIK 0001949480 (Ondo Finance Inc.), 0001957431 (Ondo I LP) and 0001605130 (Ondot Systems, unrelated). Full-text search for "Ondo Global Markets" returns only third-party press releases (Enlivex 6-K, Ether Machine 425). | <https://www.sec.gov/cgi-bin/browse-edgar?company=ondo&CIK=&type=&dateb=&owner=include&count=40&action=getcompany&output=atom> ; <https://efts.sec.gov/LATEST/search-index?q=%22Ondo%20Global%20Markets%22> |

### Ondo corporate site (accessed 2026-08-04)

| Claim | URL |
|---|---|
| **OUSG live portfolio, "As of August 4, 2026 4:00:00pm EDT"**: total $378,543,269 — SWEEP 39.75% ($150,467,352), BUIDL 26.75% ($101,261,051), BENJI 16.86% ($63,806,526), FYOXX 16.23% ($61,429,342), Coinbase USDC 0.37%, Other 0.03%, Silicon Valley Bank deposits 0.02%; 7-day yield 3.48%, 30-day 3.43% | <https://ondo.finance/ousg> |
| **USDY live portfolio, "As of August 3, 2026 7:59:59pm EDT"**: USDY outstanding **$2.14B**, underlying assets **$2.16B**, **collateralization ratio 104.20%**; 99.21% US Treasuries ($2,139,872,397, WAM 173.76d, YTM 3.78%), 0.68% "Ondo Stocks issued USDY" ($14,631,268), 0.11% Silicon Valley Bank deposits; WAM 172.39 days; "Legal Structure: Debt Issued by Bankruptcy-Remote Entity"; "Regulatory Compliance: Continuous Regulation S Offering"; **"Issuer Domicile: United States"**; "Transferability: Freely Transferrable" | <https://ondo.finance/usdy> |
| **Ondo Chain cancelled**; Ondo Network announced **Jul 27, 2026**; off-chain enclaves + attestor set + public-chain settlement; first app is Ondo Perps | <https://ondo.finance/ondo-chain> |

### GitHub (accessed 2026-08-04)

| Claim | URL |
|---|---|
| Org metadata, 15 public repos | <https://github.com/ondoprotocol> (via `gh api orgs/ondoprotocol`) |
| `USDY.sol` roles, `_beforeTokenTransfer`, admin burn | <https://github.com/ondoprotocol/usdy/blob/3912ca0698c2992e4db997d0855e62588c44e2c0/contracts/usdy/USDY.sol> |
| `USDYManager.sol` `TIMESTAMP_SETTER_ROLE`, `setClaimableTimestamp`, `MintNotYetClaimable` | <https://github.com/ondoprotocol/usdy/blob/3912ca0698c2992e4db997d0855e62588c44e2c0/contracts/usdy/USDYManager.sol> |
| `AllowlistUpgradeable.isAllowed` (real implementation, for contrast with the deployed stub) | <https://github.com/ondoprotocol/usdy/blob/3912ca0698c2992e4db997d0855e62588c44e2c0/contracts/usdy/allowlist/AllowlistUpgradeable.sol> |
| README: allowlist+blocklist gating for USDY; Chainalysis sanctions oracle; RWAHub subscription/redemption flow; `RELAYER_ROLE` off-chain deposit proofs | <https://github.com/ondoprotocol/usdy/blob/main/README.md> |
| Token list v11.0.0, 888 tokens | <https://github.com/ondoprotocol/ondo-global-markets-token-list/blob/cf97552db394cc10bffab7ac942805a89a882039/tokenlist.json> |
| **NEGATIVE RESULT:** `ondoprotocol/tokenized-funds` (linked from Ondo's own addresses page as OUSG's source) returns HTTP 404 | <https://github.com/ondoprotocol/tokenized-funds> |

### On-chain, Ethereum mainnet (all reads 2026-08-04)

Method: `eth_getStorageAt` at EIP-1967 slots
`0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc` (implementation),
`0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103` (admin),
`0xa3f0ad74e5423aebfd80d3ef4346578335a9a72aeaee59ff6cb3582b35133d50` (beacon); and `eth_call` for
`owner()`, `getThreshold()`, `getOwners()`, `VERSION()`, `getMinDelay()`, `getRoleMemberCount(bytes32)`,
`getRoleMember(bytes32,uint256)`, `totalSupply()`, `paused()`, `getPrice()`, `getAssetPrice(address)`,
`isAllowed(address)`, `isBlocked(address)`, `compliance()`, `tokenPauseManager()`, `implementation()`.
Endpoint: `https://ethereum-rpc.publicnode.com`. Verified source via
`https://eth.blockscout.com/api/v2/smart-contracts/<address>`. All addresses, thresholds, role counts,
supplies and prices are tabulated in §2.9 and §3.2–3.3 and were produced by these calls.

### Aggregators

**None used.** No claim in this document derives from DefiLlama, CoinGecko, Messari, RWA.xyz, CoinDesk or
The Block. The only third-party sources consulted were WebSearch result snippets, which were used **solely
to locate primary URLs** and were then replaced by the primary source before any claim was recorded. One
search snippet asserted the 40–50 day lockup; it is **not** relied on — the archived Ondo page is the
citation (§2.6). The corpus's own DefiLlama/rwa.xyz figures are addressed in §6 but are not endorsed here.

---

## 5. RESIDUE CHECK

### (a) "USDY is a secured note — a debt obligation of Ondo USDY LLC. Nothing in the vocabulary names the OBLIGOR or recourse."

**Note character: CONFIRMED. Obligor identity: REFUTED AS STATED / NOW INDETERMINATE. The
vocabulary-gap observation: CONFIRMED AND UNDERSTATED.**

The instrument is debt. Ondo's SPV purpose clause is explicit: *"(1) borrowing funds from prospective
lenders, (2) issuing USDY tokens to evidence the LLC's debt obligations to those lenders"*
(<https://docs.ondo.finance/trust-and-security.md>). Holders are **lenders**.

But "Ondo USDY LLC" is no longer a safe answer. Ondo's live docs say both of:
*"USDY tokens are issued by Ondo Global Markets (BVI) Limited"*
(<https://docs.ondo.finance/general-access-products/usdy/important-notes.md>) and
*"a tokenized note formerly issued by Ondo USDY LLC, which as of December 15, 2025 has been folded into
the Ondo Stocks umbrella"* (<https://docs.ondo.finance/general-access-products/usdy/basics.md>), while
`trust-and-security.md` still describes Ondo USDY LLC in the present tense and
<https://ondo.finance/usdy> still shows *"Issuer Domicile: United States"*.

**UNKNOWN — whether legacy USDY tokens remain obligations of Ondo USDY LLC (Delaware) while newly issued
USDY are obligations of Ondo Global Markets (BVI) Limited, or whether all outstanding USDY was novated to
the BVI issuer.** What I tried: read every USDY page in `llms.txt`; read `trust-and-security.md`; read the
USDY product page; searched EDGAR for a novation/assignment disclosure (Ondo USDY LLC is not an EDGAR
registrant, so none exists); attempted to reach the offering documents, which are KYC-gated
(*"we are only able to provide such materials to investors who successfully complete our onboarding
process"*). No public document resolves it.

**The recourse point is stronger than the prior claim states.** The vocabulary names neither the obligor
nor the fact that recourse is **contractually capped at the collateral**: *"any amounts due from the Issuer
to any purchaser shall be equal to the lesser of the principal amount of the Issuer's obligations under the
Offering Documents and the actual amount received or recovered by or for the account of the Issuer in
respect of any collateral… Purchasers shall have no further recourse to the Issuer."*
(<https://docs.ondo.finance/ondo-stocks/secondary-market-restrictions.md>). A limited-recourse note and a
full-recourse note are different instruments; no symbol distinguishes them.

### (b) Security interest, collateral agent identity, perfection mechanism

**CONFIRMED on collateral agent and priority. PARTIALLY UNKNOWN on perfection.**

Collateral/Security Agent is **Ankura Trust Company** (styled "Ankura Trust Company, LLC" in the
secondary-market terms) for **both** USDY and Ondo Stocks — quoted in full in §2.7. Ankura also serves as
**Verification Agent**, performing daily asset attestations. Priority is stated as *"first-priority,
perfected security interest"* (<https://docs.ondo.finance/ondo-stocks/trust-and-transparency.md>).

**Perfection mechanism: CONFIRMED as control agreements. UCC-1 filing: UNKNOWN.** Ondo names control
agreements explicitly — *"we have entered into control agreements with Ankura Trust and each of the banks
and custodians holding assets backing USDY"* (archived trust page) — and control is the correct perfection
route for deposit accounts and securities entitlements. But **no document I fetched mentions a UCC-1
financing statement.** What I tried: grepped every fetched Ondo page and the archived pages for "UCC",
"financing statement", "perfect"; searched EDGAR (no registrant, so no exhibits); the security agreement
itself is KYC-gated. I am not willing to assert a UCC-1 filing exists. **Also note the BVI problem:** Ondo
Global Markets (BVI) Limited is a BVI company, so UCC Article 9 would not govern perfection against it in
the ordinary way; the docs do not say what law governs the security interest, only that the Sales Terms are
Swiss-law. **UNKNOWN — the governing law of the security agreement and the perfection regime for the BVI
issuer.**

**One under-appreciated feature: enforcement is gated on a tokenholder vote** (§2.7). Ankura acts *"subject
to USDY Tokenholder approval… upon acceleration of the loans by the vote of USDY holders."* There is no
on-chain voting contract. The claim is only as good as an off-chain collective-action process among
pseudonymous bearer-token holders.

### (c) Bankruptcy remoteness — is it claimed, and by what structure?

**CONFIRMED, and the structure is more complete than a generic SPV claim.** Four distinct devices:

1. **Entity separation + independent director.** *"issuance from a special purpose vehicle managed by a
   distinct Board of Directors with an independent director, as well as segregation of assets, books and
   accounts from Ondo Finance Inc. and the Ondo Foundation group."*
   (<https://docs.ondo.finance/ondo-stocks/trust-and-transparency.md>)
2. **Restricted purpose clause.** The Ondo USDY LLC five-item activity limitation quoted in §1.1.
3. **Non-petition covenant.** *"No purchaser of Tokens may institute against, or join any person in
   instituting against, the Issuer any bankruptcy, winding-up, examination, re-organisation, arrangement,
   insolvency or liquidation proceedings… for so long as any Tokens are outstanding or until one year plus
   one day has elapsed since the last day on which the Tokens were outstanding"*
   (<https://docs.ondo.finance/ondo-stocks/secondary-market-restrictions.md>).
4. **Limited recourse + no recourse to persons.** *"No purchaser shall have any recourse to any director,
   officer or employee of the Issuer or any of its Affiliates or any of their respective assets."* (same)

Items 3 and 4 are the textbook securitisation pair and are **completely invisible in the 58-symbol
vocabulary**. Note also that Ondo hedges on efficacy: *"Ondo USDY has been structured in a manner to
**minimize the risk** of consolidating the Ondo USDY assets into an Ondo Finance bankruptcy"* (archived
trust page) — a risk-reduction claim, not a legal opinion. **UNKNOWN — whether a non-consolidation opinion
or true-sale opinion exists;** no document I fetched references one.

**Note: bankruptcy remoteness is NOT claimed for OUSG.** Ondo I LP is a plain Delaware LP with a
wholly-owned GP; nothing in `trust-and-security.md` or the Form D asserts remoteness.

### (d) REGISTER OF RECORD — is the chain authoritative, or a mirror? **[the load-bearing question]**

Answer differs per product, and in no case did I find a document that says the words "the blockchain is
the register of record."

**USDY — the chain is authoritative for issued tokens; the pre-issuance stage is an off-chain register
that USDYc merely mirrors.** The strongest available quote is Ondo's own bearer characterisation:
> *"Because USDY tokens designed to be a bearer instrument like a stablecoin, if you lose your Tokens there
> is not much we can do. If you lose your Temporary Global Certificate prior to claiming your Tokens,
> however, you can always re-download your certificate by logging into your Ondo account."*
> — <https://web.archive.org/web/20251013000000id_/https://docs.ondo.finance/general-access-products/usdy/faq/investing-and-redeeming>

That asymmetry **is** the answer: the token is a bearer instrument with no off-chain recovery (so the chain
controls), while the certificate is an entry in Ondo's account system that can be reissued (so the book
controls). Ondo confirms USDYc's subordinate status in its own words: USDYc is *"An onchain **bookkeeping
representation** of the *Temporary Global Certificate*"* (<https://docs.ondo.finance/addresses.md>,
emphasis mine) — explicitly a mirror, not the record.

**OUSG — UNKNOWN, and this is the most important gap in the whole file.** OUSG tokens are *"a unitized
limited partnership interest"* (<https://docs.ondo.finance/trust-and-security.md>). A Delaware LP must
maintain a partner register under its LP agreement. **No document I fetched states whether the LP register
or the token ledger controls, and no transfer agent is named for OUSG anywhere.** What I tried: read all 12
OUSG doc pages; read `trust-and-security.md`; read the 2026 Form D (which discloses **84 investors** but
says nothing about the register); searched EDGAR for a transfer-agent Form TA (none); the LP agreement is
KYC-gated. **A datum that sharpens the question: the Form D reports 84 investors, while the OUSG token is
freely transferable among all KYC'd parties.** If the chain were not authoritative, the LP register and the
token ledger could diverge — and nothing public says how that is reconciled.

**OGM / tokenised equities — the chain is authoritative for the claim; KYC is a separate gate on
redemption.** Three quotes, together decisive:
- *"you will not see your name on the share register for the underlying assets — they are held in the name
  of, or for the benefit of, the Issuer."* — <https://docs.ondo.finance/ondo-stocks/legal-and-regulatory.md>
  (So the **underlying** register is definitively not the holder's.)
- *"Each person who acquires Tokens on the secondary market, by acquiring such Tokens, appoints Ankura
  Trust Company, LLC as the Security Agent."* — secondary-market page. (Rights attach **by acquisition of
  the token**, with no issuer act — that is a bearer instrument, and the chain is the record of acquisition.)
- *"As a condition to redeeming any of its Tokens, a Token holder must satisfy the Issuer's customer due
  diligence… there is a risk that a person acquiring Tokens on secondary markets will not meet such due
  diligence requirements and therefore may not be able to redeem."* — same page.

On-chain this is exactly reflected: GM transfer compliance is **denylist-only** (§2.1), so the chain freely
records holders, while redemption runs through `redeemWithAttestation` requiring a signed quote bound to a
KYC'd `userId`. **The chain determines *who holds*; Ondo's KYC book determines *who can be paid*.** A
tokenholder who cannot pass KYC holds a real, transferable claim that is nonetheless **unredeemable**.
That divergence — record-of-ownership on-chain, record-of-entitlement-to-payment off-chain — has no name in
the vocabulary and is the single most interesting formal feature of the OGM design.

### (e) OUSG as a feeder routing into BUIDL and other MMFs — **CONFIRMED, with live allocations**

Ondo: *"the majority of the Fund's assets are currently invested in the BlackRock USD Institutional Digital
Liquidity Fund (BUIDL)"* (<https://docs.ondo.finance/trust-and-security.md> — note this sentence is now
**stale**, see below) and *"The OUSG portfolio is invested in funds issued by leading asset managers such as
BlackRock, Franklin Templeton, WisdomTree, Fidelity, and others"*
(<https://docs.ondo.finance/qualified-access-products/ousg/overview.md>).

Live allocation, **"As of August 4, 2026 4:00:00pm EDT"**, from <https://ondo.finance/ousg>:

| Position | Ticker | Weight | Value |
|---|---|---|---|
| State Street Galaxy Onchain Liquidity Sweep Fund | SWEEP | **39.75%** | $150,467,352 |
| BlackRock USD Institutional Digital Liquidity Fund | BUIDL | **26.75%** | $101,261,051 |
| Franklin OnChain U.S. Government Money Fund | BENJI | 16.86% | $63,806,526 |
| Fidelity Treasury Digital Fund | FYOXX | 16.23% | $61,429,342 |
| Coinbase — Cash Equivalents | USDC | 0.37% | $1,394,959 |
| Other Assets | USD | 0.03% | $105,116 |
| Silicon Valley Bank — Bank Deposits | USD | 0.02% | $78,924 |
| **Total** | | **100%** | **$378,543,269** |

**Refinement to the prior claim: BUIDL is no longer the majority holding.** SWEEP (State Street/Galaxy) has
overtaken it at 39.75% vs 26.75%. **Ondo's own `trust-and-security.md` is stale on this point.** Manager
discretion is explicit and unconstrained: *"The portfolio may, in the future, include other US Treasury
funds and/or direct investments in US Treasuries."* **No target allocations, bands, or concentration limits
are disclosed anywhere** — this is discretionary allocation, not a rules-based feeder. WisdomTree is named
in the prose but holds **0%** today. Note also that OUSG is a **fund-of-tokenised-funds**: every one of the
four fund positions is itself a tokenised MMF, so OUSG holders sit two tokenisation layers from the
Treasuries.

### (f) The 40–50 day transfer lockup and its legal basis — **CONFIRMED HISTORICALLY, APPEARS SUPERSEDED**

**Exact number, cited:** *"you will not be able to claim your transferable Tokens until the Restricted
Period for your Certificate ends; this is usually between **40 and 50 days** from the time you deposited
funds (depending upon exactly when we received your investment)."*
— <https://web.archive.org/web/20251013000000id_/https://docs.ondo.finance/general-access-products/usdy/faq/investing-and-redeeming>

Corroborated on the redemption side: *"you must wait until your Tokens are minted, which takes between
**40-50 days** from the time of your deposit"*, and the mint date is named the **"Restricted Period End
Date"**, printed on the Temporary Global Certificate (same page).

**Legal basis: PARTIALLY CONFIRMED, PARTIALLY INFERRED — do not overstate in the paper.** Ondo says only
*"To comply with applicable US regulations"* and separately that *"USDY is offered and sold by the USDY
entity in reliance on Regulation S"* (<https://docs.ondo.finance/trust-and-security.md>). **Ondo never uses
the phrase "distribution compliance period" or cites Rule 903 in any document I fetched.** The mapping
(40 days = the Reg S Category 2 distribution compliance period for debt securities) is a legally standard
inference, not an Ondo statement. **UNKNOWN — Ondo's own articulated legal basis for the 40–50 days.**
What I tried: grepped all 42 current doc pages and both archived pages for "Regulation S", "distribution
compliance", "Rule 903", "40 day", "seasoning", "Category 2"; only the general Reg S reliance statement
appears.

**Two important corrections to the prior claim's framing:**

1. **It was never a *transfer* lockup on minted tokens.** It was a *delay in minting*. Holders received an
   off-chain Temporary Global Certificate and accrued yield from day one; the ERC-20 simply did not exist
   yet. Nothing on-chain ever restricted an existing USDY balance for 40–50 days.
2. **It is not a constant anywhere.** The on-chain enforcement is
   `setClaimableTimestamp(uint256, bytes32[])` gated by `TIMESTAMP_SETTER_ROLE`, with a `MintNotYetClaimable`
   revert (§2.6). The role-holder types in any timestamp. 40–50 days is policy, not protocol.

**Current status: dormant.** `USDYc.totalSupply()` = **0** on 2026-08-04; the language is gone from all
current documentation; the live `USDY_InstantManager` mints atomically against USDC with no claimable-timestamp
check documented or implied. **UNKNOWN — whether the Restricted Period was formally retired or merely bypassed
for the instant-mint channel while remaining in force for wire subscriptions.** What I tried: read the current
basics/important-notes/eligibility pages and the instant-manager developer guide (none mention it); confirmed
zero USDYc supply on-chain; the offering documents that would say so are KYC-gated.

### (g) Off-chain cut-offs and T+n versus the atomic on-chain appearance — **CONFIRMED, and it is a genuine two-tier system**

There are literally two subscription/redemption regimes per product, and the on-chain atomicity of one does
not extend to the other (full table in §2.5).

- **Atomic tier.** OUSG: *"the redemption takes place as an atomic transaction so you will receive your USDC
  at the same time as you send in your OUSG"*. OGM: *"Minting and burning are instant… you get your tokens or
  stablecoins in a single atomic transaction."* USDY: `subscribe`/`redeem` return in one call.
- **Banking tier.** OUSG non-instant: 4pm ET cut-off, funds next Business Day. USDY fiat: 8pm UTC cut-off,
  five Business Days, non-US bank accounts only. Business Day is defined by **Wilmington, Delaware bank
  holidays and Federal Reserve Bank of Philadelphia closures** — a US banking calendar governing a product
  sold exclusively to non-US persons.

**Three additional frictions that break the atomic illusion and are not in the vocabulary:**
- **Instant capacity is capped and shared.** $50M global / $25M individual per 24h for OUSG, refreshing on
  a rolling window; *"Instant Redemptions may also be limited by the availability of USDC tokens for instant
  redemption that Circle supports."*
- **OGM atomicity is inventory-contingent.** Redemption to USDon is always instant; redemption to USDC is
  instant *"provided there is enough liquidity in the stablecoin swapper."* A holder can be forced to sit in
  USDon indefinitely.
- **The atomic path still consumes an off-chain artefact.** Every GM mint/redeem needs a **30-second signed
  EIP-712 quote** from Ondo's attestation service. If that service is down, the "atomic on-chain" path does
  not exist. The on-chain code is atomic; the *system* is not.

Yield timing is also discretised to the price update, not to the transaction: *"whoever holds the tokens at
the time of the price update gets the yield"*, and *"Friday's price update includes the estimated yield paid
out on the underlying assets for Friday and Saturday"*
(<https://docs.ondo.finance/qualified-access-products/ousg/redeeming.md>).

### Things Ondo does that the vocabulary appears to have no name for

1. **Limited recourse.** Claims capped at recovered collateral, with express waiver of further recourse
   against the issuer and its officers. No symbol distinguishes limited- from full-recourse debt.
2. **Non-petition covenant.** Holders contractually barred from filing against the issuer for one year and
   one day. A bankruptcy-remoteness *mechanism*, distinct from the SPV itself.
3. **Tokenholder-vote-gated enforcement.** The security agent may only act *"subject to USDY Tokenholder
   approval"* and *"upon acceleration of the loans by the vote of USDY holders."* An off-chain collective
   action requirement standing between default and remedy.
4. **The dormant gate (`AllowlistStub`).** A permission mechanism deployed, wired into the transfer hook,
   and deliberately set to a pass-through. Neither "permissioned" nor "permissionless" describes it; it is
   **re-armable in one transaction with no delay.** This deserves its own symbol.
5. **Bearer claim with gated redemption.** Ownership on-chain, entitlement-to-payment off-chain (§5(d)).
6. **Signed-quote pricing.** Price arrives as a per-trade EIP-712 message with `attestationId` replay
   protection and a 30-second `expiration` — an oracle delivered as a *capability grant*, not a feed. `Ex`
   assumes a readable external datum; this is an unforgeable, single-use, expiring authorisation.
7. **Beacon fan-out upgrade.** One `UpgradeableBeacon` controls the code of all 444 Ethereum GM tokens.
8. **Total-return synthetic shares.** A per-token share multiplier that ratchets on ex-dividend dates,
   published on-chain. Similar to `Ix`, but the accrual driver is a *corporate action on a referenced
   external security*, not an interest rate.
9. **Rate-limited bridging.** Per-pathway, per-direction, per-day caps with linear refill, enforced in the
   OFT contracts.
10. **Instant-channel capacity limits.** Global and per-user 24h caps that convert an atomic right into a
    queued one above a threshold — a *soft* withdrawal queue.
11. **Market-hours and corporate-action pauses.** Per-asset `TokenPauseManager` halts tied to the trading
    calendar of an off-chain venue.
12. **A jurisdictional geofence as a product boundary.** The docs are literally wrapped in
    `<div id="geofenced-content">`; eligibility is enforced at onboarding, not on-chain.
13. **Sponsor-funded overcollateralisation and an external guarantee.** The 3% first-loss is *sponsor
    equity*, and the Ondo Foundation *"has guaranteed funds to further collateralize"* OGM obligations —
    credit support from outside the structure.
14. **The USDon two-step.** All GM trades settle through an intermediate issuer-native dollar token rather
    than the user's stablecoin. `Ps` captures the swap; it does not capture the *mandatory intermediation*.

---

## 6. NOTES FOR THE DELTA SECTION

Corpus record (2026-08-04) decomposed Ondo as
`At, Aw, Ex, Fz, Gp, Ix, Rb, Rd, Sh, Tg, Tr, Up, Xf, Xm`. Assessment, symbol by symbol:

**`Tg` (timelock) — PRESENT BUT MISLEADING AS AN UNQUALIFIED TAG.** A `TimelockController`
(`0x3715b2154d2ff4c5b027c7a1f734b53f27bc34f1`) does exist, with `getMinDelay()` = **7200 seconds = 2 hours**.
It governs **only** the Ondo Stocks stack: the USDon ProxyAdmin and the GM token beacon
(`0x985462c9aa4d6c3ad59ae6e1e9c0c11347ed1598`). It governs **nothing** on USDY, rUSDY, USDYc, OUSG or
OndoIDRegistry — those upgrade through bare Gnosis Safes (4-of-7, 4-of-7, 3-of-5) with **zero delay**.
Since USDY + OUSG are ~87% of Ondo's yield-asset value, `Tg` describes the minority of the system. Two
hours is also short enough that it functions as a fat-finger guard, not a governance window; and
`EXECUTOR_ROLE` includes a **1-of-9 Safe** and a plain **EOA**. Recommend `Tg` be scoped or dropped.

**`Xm` (verified cross-domain message verification) — PRESENT BUT OVERSTATED; BRIDGING IS FEDERATED, NOT
PROOF-VERIFIED.** LayerZero V2 OFT with three DVNs: *"Canary DVN, LayerZero Labs DVN, Ondo DVN"*, where
*"Our custom Ondo DVN was built with unique validation specifically for bridging USDY and Ondo Stocks."*
This is an **attestation quorum in which Ondo is itself one attestor** — not light-client or ZK
verification. It is also **not custodial**: burn-and-mint of native tokens, with hard rate limits in the
contracts (450k/500k USDY per pathway per day). So the corpus is right that it is not custodial, but wrong
if `Xm` connotes cryptographic verification of source-chain state. Note the bridge adapter
`0xa6275720b3fB1Efe3E6EF2b5BF2293148852307D` holds `MINTER_ROLE` on USDY — a DVN quorum failure mints
unbacked USDY. Recommend qualifying `Xm` as attestation-quorum.

**`Tr` (tranche waterfall) — REFUTE. The 3% is confirmed as a number but is NOT a tranche.**
The 3% figure is real and citable: *"Ondo Finance has over-collateralized the USDY notes, providing a 3%
first-loss position that absorbs short-term fluctuations in US Treasuries prices"* and *"if we issue a
total of $100 worth of USDY, it will always be secured by at least $103 worth of bank deposits and Treasury
bills. This collateralization ratio will be monitored daily and must exceed this minimum threshold at the
end of every quarter."*
(<https://web.archive.org/web/20251013000000id_/https://docs.ondo.finance/general-access-products/usdy/faq/trust-and-transparency>)

But **3% is a floor, not the current level, and it is sponsor equity, not a junior note class.** Live:
USDY outstanding **$2.14B** against underlying assets **$2.16B**, **collateralization ratio 104.20%**
(<https://ondo.finance/usdy>, as of 2026-08-03 7:59:59pm EDT). So today the buffer is **4.20%**, and the
corpus's "3%" should be restated as *"a contractual minimum of 3%; 4.20% as at 2026-08-03."* There is **no
second class of tokens, no junior tranche, no subordinated holder, and no distribution waterfall in normal
operation** — only equity absorbing first loss. A priority ordering does appear, but **only on enforcement**:
*"less any sums which the Issuer is or may be obligated to pay to any person in priority to such Purchaser."*
`Tr` should be refuted for the capital structure and, if retained at all, scoped to enforcement priority.
Also note the compliance test is **quarter-end**, so intra-quarter breach is contemplated.

**`Sh` (pro-rata share accounting) — WRONG FOR USDY; RIGHT FOR OUSG AND FOR rUSDY'S INTERNALS.** USDY is a
note; the holder owns a debt claim of fixed principal plus accrued interest, not a pro-rata slice of a pool.
`Sh` is correct for **OUSG**, which is literally *"a unitized limited partnership interest"*, and correct
for the **rUSDY wrapper's internal accounting** (`NumTokens_User = NumTokens_Total * (NumShares_User /
NumShares_Total)`, <https://docs.ondo.finance/general-access-products/usdy/rebasing.md>). Applying `Sh` to
USDY conflates a creditor with an equity holder — precisely the distinction the security agreement exists
to preserve. Recommend `Sh` be scoped per-product.

**`Rd` (direct redemption right) — PRESENT BUT CONDITIONAL.** Redemption is contingent on KYC and the
issuer may refuse: *"the Issuer may refuse any redemption to a holder of any securities if the Issuer
suspects or is advised that the redemption may be non-compliant."* USDY fiat redemption is available
**only to non-US bank accounts**. OGM has **no** fiat redemption at all. A holder who fails KYC holds a
transferable but unredeemable claim.

**`Fz` (freeze/forced transfer) — HALF RIGHT.** Freeze: yes (blocklist + Chainalysis sanctions + pausable).
**Forced transfer: absent** — no `forceTransfer`/`seize` exists anywhere. What *does* exist is an
**admin-burn** (`burn(address from, uint256)` under `BURNER_ROLE`), and on 2026-08-04 the `BURNER_ROLE`
member count is **0 on USDY, 0 on OUSG, and 0 on NVDAon**. So the destructive power is latent but
unassigned. Freeze and confiscate-by-burn are different from forced transfer; the symbol should say which.

**`Aw` (permission/identity gate) — PRESENT BUT THREE DIFFERENT REGIMES, AND ONE IS SWITCHED OFF.**
OUSG = true allowlist (KYC required to hold). GM tokens = **denylist only** (anyone may hold). USDY = an
allowlist contract that is currently the pass-through `AllowlistStub` returning `true` unconditionally,
re-armable by a single `LIST_CONFIGURER_ROLE` holder with no delay. A single `Aw` flattens a permissioned
fund, a bearer instrument, and a dormant-gate hybrid into one symbol.

**`Ps` (peg-swap module) — MISSING FROM THE CORPUS DECOMPOSITION AND IT SHOULD BE THERE.** Ondo names it in
its own register: *"The Ondo PSM (Peg Stability Module) smart contract for USDon, facilitating swaps between
USDon and USDC"* (`USDonManager` `0x05CCbB4b74854f8A067b83475E8c34f5a413D7e1`,
<https://docs.ondo.finance/addresses.md>). USDon supply is $30.0M live. This is a clear omission.

**`Sv` (servicing & determination discretion) — MISSING FROM THE CORPUS DECOMPOSITION AND STRONGLY PRESENT.**
NAV is *"a manual process"* using *"a conservative estimate"* trued up the next day; GM quote prices come
from *"a little bit of (proprietary) math"* with spreads set by *"quote size, target profit, and several
other proprietary considerations"*; and the issuer disclaims determination liability outright: *"The Issuer
shall not have any responsibility… for any errors or omissions in the calculation of any amount or with
respect to any other determination or decisions required to be made under any Offering Document"* and
*"Any such extraordinary event may reduce the redemption amount owed to Token holders, as determined by the
Issuer."* This is the largest single omission in the record.

**`At`, `Ex`, `Gp`, `Ix`, `Rb`, `Up`, `Xf` — CONFIRMED.** `At`: Ankura daily attestations + NAV Consulting
+ published daily/monthly/annual reporting. `Ex`: on-chain oracles for USDY and OUSG (with the signed-quote
caveat for OGM). `Gp`: `PAUSER_ROLE`, including the 1-of-9 hot Safe. `Ix`: the `RWADynamicOracle` range
compounding is a textbook accrual index. `Rb`: rUSDY, daily, coincident with price update. `Up`: all six
core proxies are upgradeable (plus a beacon fan-out over 444 tokens — arguably needs its own marker).
`Xf`: LayerZero OFT burn-and-mint across 10+ chains.

**Rank basis — arithmetic checks out; the *taxonomy* is now wrong.** USDY $2.14B + OUSG $0.379B = $2.52B,
which matches "Ondo Yield Assets $2.53B" within rounding, and "rwa.xyz lists USDY alone at $2.15B" matches
Ondo's own $2.14B. **But the split between "Ondo Yield Assets" and "Ondo Global Markets" no longer tracks
any legal boundary:** as of **2025-12-15** USDY was *"folded into the Ondo Stocks umbrella"* and current
docs state USDY is issued by **Ondo Global Markets (BVI) Limited** — the same issuer as the tokenised
equities. Ondo's own USDY collateral report even carries a line item *"Ondo Stocks issued USDY — USD Value,
$14,631,268"* (<https://ondo.finance/usdy>), i.e. USDY issued under the OGM programme now sits **inside**
the USDY collateral pool. A category boundary that separates USDY from OGM is measuring a product-marketing
distinction, not an issuer, a fund, or a risk perimeter. Also note **OUSG has shrunk**: $378.5M today
against $1.858B cumulative subscriptions reported in the 2026 Form D.

**One further staleness flag.** The corpus should not carry any Ondo Chain / Ondo L1 attribution. Ondo
**cancelled** the chain and replaced it on **2026-07-27** with the off-chain-enclave "Ondo Network"
(<https://ondo.finance/ondo-chain>). There is no Ondo mainnet L1. Any `Xm`/`Xf` reasoning that assumed an
Ondo-operated settlement chain is void.

*(No corpus file was read or edited in producing this section; the decomposition above was supplied in the
task brief and is assessed against fetched primary sources only.)*
