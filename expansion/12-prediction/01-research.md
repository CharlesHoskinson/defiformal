# Category 12 — Prediction markets & other: Stage-1 research

**Lane:** Kalshi · Polymarket · Azuro · Steakhouse Financial · Grove Finance.
**Access date for every citation below: 2026-08-04** (unless a document's own effective date is given).

**Note on source quality for this category.** This is the most heterogeneous evidence base in the
project, and the quality splits cleanly in two. The three prediction venues are documented to an
unusually *high* standard, but not on-chain: Kalshi and Polymarket US are both CFTC-regulated
entities whose exchange rulebooks and clearing rulebooks are public filings, so the settlement
mechanism, the novation clause and the default waterfall can be quoted verbatim from a primary
regulatory document — which is far better evidence than most DeFi docs sites provide, and which
is also the reason almost none of it is verifiable in a repository. The two allocators are the
opposite: Steakhouse publishes a detailed public risk methodology but writes no protocol code of
its own (its substrate is `morpho-org/metamorpho`), and Grove publishes a real AGPL repository
and canonical addresses but keeps its actual mandate in Sky governance forum threads. Azuro is
the weakest: its docs site (`gem.azuro.org`) is good on mechanism and gives closed-form odds
formulas, but the public contract repository `Azuro-v2-public` covers V2 only and has not been
touched since January 2025, while the live deployments are V3 — so for Azuro alone, **the
deployed code has no public source I could locate**. Where I could not confirm something at a
primary source I have written UNKNOWN rather than inferring it. Two PDFs (Kalshi Klear DCO
Rulebook v1.4, Polymarket US Rulebook) were extracted locally with PyMuPDF because they defeat
plain HTTP fetchers; kalshi.com rate-limits ordinary fetchers and was retrieved with `scrapling`.

---

## Kalshi

### 1. WHAT IT DOES

A user opens an account with a US-regulated broker-exchange (KYC, geographic eligibility) and buys
a *contract* on a stated future fact — "will X happen by date Y" — at a price between $0.01 and
$0.99 that reads directly as a probability. Each contract is either a **Binary Contract**, which
pays a Settlement Value (canonically $1.00) to the long side if the Expiration Value of the
Underlying falls within the contract's **Payout Criterion** and to the short side if it does not,
or a **Scalar Contract**, where the Payout Criterion apportions the $1.00 between long and short.
Positions are always fully cash-collateralised: a user's maximum downside is escrowed at trade
time and no event contract position can lose more than the cash posted. The outcome is determined
by **Kalshi itself**, not by an oracle and not by a vote: Kalshi has "sole discretion to interpret
a Contract's Terms and Conditions," and where the Expiration Value is indeterminable it may settle
at the last traded price or refer the contract to an **Outcome Review Committee** whose
determinations "are final and not subject to review." There is no dispute path for a user beyond
exchange arbitration; disagreement about an outcome is not adjudicated, it is decided. The
position ends by (a) selling it back into the order book at any time before expiration, (b)
expiring worthless, or (c) expiring in the money, at which point the clearing house debits its
settlement account and credits the member's account. Kalshi also now lists **perpetual futures** on
crypto prices — leveraged, non-expiring, with a funding rate — which is a materially different
product from an event contract and is *not* fully collateralised. (Launch date for the perpetuals
product: UNKNOWN; the explainer page carries no date and I found no primary announcement.)

### 2. DESIGN

**Two entities, one product.** `KalshiEX LLC` is the Designated Contract Market (DCM) — it lists
contracts, runs the matching engine, and determines outcomes. `Kalshi Klear LLC` is a separate
CFTC-registered Derivatives Clearing Organization (DCO) — it is the central counterparty. The DCM
rulebook is explicit that the two are layered and that the clearing rules win on conflict: "In the
event of any conflict or inconsistency between these Rules and the Clearing House Rules … the
Clearing House Rules shall prevail" (KalshiEX Rulebook v1.18, Rule 6.1(e)).

**Position representation.** There is no token and no split/merge primitive. A position is a row in
Kalshi's system: "Kalshi will maintain, on its system, a record of Member balances and Contracts"
(Rule 6.2). The YES/NO complementarity that Polymarket implements as a collateral partition is on
Kalshi purely a *quoting convention*: the public order book API returns **only bids**, in two
arrays `yes_dollars` and `no_dollars`, because "A YES BID at price X is equivalent to a NO ASK at
price ($1.00 - X)". The complementary pair is an identity in the price domain, not an object.

**Matching engine.** A conventional central limit order book operated by the exchange, off-chain,
accessed over a REST/WebSocket API with RSA-signed requests. Price increments are sub-penny
(prices are returned as dollar strings "to support subpenny precision").

**Collateral.** United States dollars only — "United States dollars is the sole form of acceptable
collateral" (Klear DCO Rule 7.6(A)). Each participant grants Klear "a continuing first priority
security interest in, lien on, right of setoff against and collateral assignment of" its deposited
property, and agrees Klear has control under UCC §9-106(a) and §8-106(e) and a perfected security
interest under §9-314(a) (Rule 7.6(B)–(C)). Customer funds are segregated under CFTC Reg. 1.20
(Futures Customer Collateral) or Part 22 (Cleared Swaps Customer Collateral) (Rule 7.7(D)–(E)),
and may be invested only in US Treasuries, agency securities, reverse repo on those, and US
government money-market funds, max 2-year maturity; "Klear will retain all profit from investment
of Participant funds not paid to Members" (Rule 7.9). This last clause is the exchange's float
business and has no analogue in the vocabulary.

**The clearing arrangement — the CCP.** This is the part the corpus says has no symbol, so it is
worth setting out exactly. On acceptance of a matched trade, Klear **novates**:

> "The Transaction, if a Transaction in futures contracts, shall be novated and the Company shall
> immediately be substituted as and assume, the position of seller to the Participant buying and
> buyer to the Participant selling the relevant Contract. Upon Novation, the original Contract is
> extinguished and the buying and selling Participants shall be released from their Obligations to
> each other … Such substitution shall be effective in law for all purposes."
> (Klear DCO Rule 6.1(E)(1))

Consent is constructive on both sides — participants consent "by entering the applicable Orders on
a Platform" and Klear consents "by accepting the Transactions for clearing." The DCM rulebook
mirrors this at Rule 6.1(c). Two clearing regimes coexist:

- **Fully Collateralized Contracts** (the event contracts). Klear pre-checks the account before
  accepting the trade: "If such Member Account … does not have the necessary funds and/or
  collateral to fully collateralize the Transaction, the Company will not accept the Transaction"
  (Rule 6.1(A)); "The Company will not clear a position in a Fully Collateralized Contract that is
  not fully collateralized" (Rule 7.5(A)). Collateral is committed against **Maximum Downside
  Exposure** (Rule 6.2(D)).
- **Margined Contracts.** (That the perpetuals clear in this tier rather than the fully-collateralised
  one is an inference from the existence of leverage, not a documented mapping — mark UNKNOWN.)
  Initial Margin under CFTC Reg. 39.13(g), gross per
  member, no netting across FCM customers, computed over a liquidation horizon of ≥1 day for
  futures and ≥5 days for swaps, with explicit anti-procyclicality measures (Rule 7.3). Variation
  Margin is paid in cash at least daily, with unscheduled intra-day calls available (Rules 7.2,
  7.4). Settlement occurs "at least once each Business Day" (Rule 6.2(A)).

**The default waterfall** (Klear DCO Rules 12.4–12.5). A **Guaranty Fund** sized so the DCO can
survive "a Default by the Member creating the largest financial exposure … in extreme but plausible
market conditions" (Rule 12.4(A)); each member's Guaranty Fund Deposit Requirement is the sum of a
Base Uncovered Stress Loss Amount, a Base Open Interest Amount and a Base Volume Amount, cash only,
minimum $1,000,000 for a new member (Rule 12.4(B)–(D)). On a Default, the defaulter's own resources
go first (customer-account margin, then that account class's excess, then the defaulter's guaranty
fund deposit — with a hard ring-fence that "neither the Cleared Swaps Customer Collateral of
non-defaulting Cleared Swaps Customers nor the Futures Customer Collateral of non-defaulting
Futures Customers shall be applied to cover the Defaulted Obligations of a Defaulting Member",
Rule 12.5(C)(1)(a)). Any residue is then met "in the following order of priority, each of which
shall be fully utilized before the next following source is applied":

1. **First Tranche Company Contribution** — Klear's own skin in the game, capped at the greater of
   $20 million or 10% of the Guaranty Fund;
2. **the Guaranty Fund** — the segment-allocated slice first, then the whole, pro rata;
3. **Second Tranche Company Contribution** — same cap;
4. **Assessments** on all surviving members, pro rata to their Guaranty Fund Deposit Requirement
   over the preceding three months, capped at 200% of that requirement for one default and 550%
   for multiple defaults within six months (Rule 12.5(C)(2)–(5)).

If that is still insufficient, Rule 12.5(D) **Variation Margin Gains Haircutting** and Rule
12.5(E) **Tear-Ups** apply — and the rulebook is explicit that these "are not Assessments and are
therefore not subject to the Assessment limits" (Rule 12.5(C)(10)). Uncollected amounts remain a
liability of the defaulter; recoveries are refunded pro rata to assessed members (Rule 12.5(C)(9)).

**Resolution / listing authority.** New contracts are listed by **self-certification** under CEA
§5c(c) and CFTC Reg. 40.2(a): Kalshi files the contract's terms with the Commission and may list
it unless the Commission objects. The filings are templated ("Will \<team\> win \<title\>?").
Post-listing, Rule 7.2 lets Kalshi "designate a new Source Agency and Underlying for that Contract
and to change any associated contract specifications after the first day of trading" — the
settlement source itself is mutable by the venue.

**Fee flow.** Taker fee = `round up(M × 0.07 × C × P × (1−P))`; maker fee =
`round up(M × 0.0175 × C × P × (1−P))`, where P is the contract price in dollars, C the contract
count and M a per-contract multiplier. No settlement fee, no membership fee, no ACH fee; card
deposits up to 2%; crypto deposit/withdrawal fees are charged by the third-party processor
(fee schedule effective July 7, 2026). Fees are debited from Member Accounts into a Klear
proprietary account (Klear Rule 7.7(C)).

**Control plane.** A corporate board, a Regulatory Oversight Committee, a Risk Management
Committee (which may recalculate every member's Guaranty Fund obligation "at any time"), a
Membership Committee, Disciplinary Panels, and an Outcome Review Committee. Emergency Rules
(Klear Rule 2.12; KalshiEX Rule 2.8) are the analogue of a pause. All of it is off-chain and
human.

**On-chain surface.** Crypto deposits (BTC, USDC, SOL, WLD) are processed by Zero Hash and
converted to USD on arrival. Since 2025-12-01 Kalshi markets are also tradeable as tokens on
Solana through Jupiter and DFlow, described by Kalshi as "a hybrid RFQ system [that] atomically
executes trades onchain," with "Kalshi Builder Codes" for permissionless monetisation of apps
built on the liquidity pool. **Who mints those tokens, under what custody, and how they redeem
against a Klear position is UNKNOWN** — Kalshi's own announcement does not say, and I found no
primary technical documentation.

### 3. REPO

**There is no canonical source repository.** Kalshi is a regulated off-exchange venue; the exchange,
the matching engine and the clearing house are proprietary and off-chain. `github.com/Kalshi` holds
8 public repositories, none of which is product code: `appsflyer-flutter-plugin` (Dart, MIT),
`goconvey` (Go, fork), `opentelemetry-rust` (Rust, Apache-2.0, fork), `tracing` (Rust, MIT, fork),
`valuable` (Rust, MIT, fork), `kalshi-starter-code-python` (Python, API sample, last updated
2025-03-07), `stable.co` (HTML), `tools-and-analysis` (Jupyter, MIT, last updated 2023-06-15).

**What is verifiable instead:** the two rulebooks are public regulatory filings and are the
authoritative specification of the mechanism —
`KalshiEX LLC Rulebook v1.18` (CFTC filing, 2025) and
`Kalshi Klear LLC DCO Rules v1.4` (108 pp., hosted by Kalshi and filed with the CFTC). Product
listings are individually certified on the CFTC portal under Reg. 40.2(a). Kalshi Klear's DCO
registration order was issued 2024-08-28. Deployed contracts: **none** — there are no Kalshi
contracts on any chain that I could verify; the Solana surface is operated by third parties
(Jupiter, DFlow, Phantom).

### 4. EVIDENCE

| Claim | Source | Accessed |
|---|---|---|
| Klear DCO rulebook v1.4 — novation, guaranty fund, waterfall, margin, segregation, investment of funds | https://kalshi-public-docs.s3.amazonaws.com/regulatory/rulebook/Kalshi%20DCO%20Rulebook%201.4.pdf (Rules 4.1–4.4, 6.1–6.2, 7.2–7.10, 12.4–12.5) | 2026-08-04 |
| Klear DCO rulebook v1.3 (CFTC-filed copy, corroborating) | https://www.cftc.gov/filings/orgrules/rules07042525566.pdf | 2026-08-04 |
| KalshiEX LLC Rulebook v1.18 — Rules 5.17, 6.1–6.4, 7.1–7.2, 8.1 | https://www.cftc.gov/filings/orgrules/rules07012525155.pdf | 2026-08-04 |
| CFTC grants Kalshi Klear LLC DCO registration (order dated 2024-08-28) | https://www.cftc.gov/PressRoom/PressReleases/8957-24 ; https://www.cftc.gov/media/11166/Kalshi%20Klear%20LLC%20Order%20of%20Registration%20as%20a%20DCO%20/download | 2026-08-04 |
| KalshiEX DCM designation order (2020) | https://www.cftc.gov/sites/default/files/filings/documents/2020/orgkexkalshidesignation201103.pdf | 2026-08-04 |
| Product self-certifications under Reg. 40.2(a) | https://www.cftc.gov/filings/ptc/ptc11142532444.pdf ; https://www.cftc.gov/filings/ptc/ptc12112534310.pdf ; https://www.cftc.gov/sites/default/files/filings/ptc/26/03/ptc03232641667.pdf | 2026-08-04 |
| Order book: bids-only, YES bid ≡ NO ask at $1−X, sub-penny prices | https://docs.kalshi.com/getting_started/orderbook_responses | 2026-08-04 |
| Fee schedule (taker 0.07, maker 0.0175, no settlement fee), effective 2026-07-07 | https://kalshi.com/docs/kalshi-fee-schedule.pdf (retrieved via scrapling; kalshi.com 429s plain fetchers) | 2026-08-04 |
| Perpetual futures: leverage per asset (BTC 5.8×, ETH 4.4×, LINK 3.4×, XRP 2.7×, SOL 2.6×, HYPE 2.1×), funding rate rebalanced 3×/day on an 8-hour cycle, "First US Company to offer Perpetuals" | https://kalshi.com/perpetuals/learn (via scrapling) | 2026-08-04 |
| Tokenized Kalshi predictions live on Solana via Jupiter + DFlow, hybrid RFQ, Builder Codes; published 2025-12-01 | https://news.kalshi.com/p/kalshi-solana-tokenized-predictions | 2026-08-04 |
| Public GitHub org contents | https://github.com/orgs/Kalshi/repositories | 2026-08-04 |
| 30-day volume $10.795B, 24h $338.1M, category "Prediction Market" | https://api.llama.fi/summary/dexs/kalshi | 2026-08-04 |

### 5. WHAT LOOKS UNNAMEABLE

- **Novation / substitution itself.** Rule 6.1(E)(1) destroys a bilateral obligation and creates two
  new ones against an institution. Nothing in the 58 is a *counterparty-substitution* operator.
  `Rd` (direct redemption right) names the $1 payoff but not the identity of the obligor, and the
  obligor here is the whole point.
- **The clearinghouse as an institution.** Corpus claim (b) **CONFIRMED, and sharper than stated.**
  The vocabulary does contain the three loss-absorption *layers* — `Bs` (staked backstop) maps to
  the Guaranty Fund, `Sl` (socialized-loss allocation) maps to Variation Margin Gains Haircutting,
  `Ad` (auto-deleveraging) maps to Tear-Ups. But there are two further pieces with no symbol at
  all: (i) the **Company Contributions**, two capped tranches of the operator's *own* capital
  sandwiching the mutualised fund — a first-loss commitment by the venue, structurally unlike `Bs`
  because it is not staked by a third party and not slashable by a rule, it is a contractual
  obligation of a specific firm; and (ii) **Assessments** — a *callable* obligation on surviving
  members, levied after the fund is exhausted, capped at 200%/550% of their prior deposit, and
  refundable pro rata on recovery. Callable capital is neither pre-posted collateral (`Bs`) nor
  loss socialisation (`Sl`); it is a contingent claim the CCP holds *against its members*. Nothing
  names it.
- **Two clearing regimes under one CCP.** Fully-collateralized and margined contracts clear side by
  side, under different rules, with a Contract Segment mechanism that partitions the guaranty fund
  between them. The vocabulary has `Im` for isolated *lending* markets; there is no symbol for
  segmenting a mutualised default fund by product class.
- **Exchange-rule outcome determination.** Rule 6.3(c)/7.1: an internal committee decides the fact,
  within 24 hours, with "full discretion," and its determination is "final and not subject to
  review." `Oa` is structurally wrong (no assertion, no bond, no dispute), `Ex` is wrong (no data
  feed, no medianizer), `Sv` is wrong (servicing a loan, not adjudicating a fact). This is a
  *tribunal*, and there is no symbol for one.
- **Settling to last traded price.** Rule 6.3(c)(a): when the fact is indeterminable, the market's
  own final price becomes the payout. That is a self-referential settlement — the oracle is the
  order book. `Tp` (on-chain TWAP) is the nearest shape and is not it.
- **Source Agency substitution.** Rule 7.2(a): the venue may replace the named settlement source
  mid-contract. A mutable oracle *designation*, distinct from `Up` (mutable implementation) and
  from `Ex`.
- **The contract rulebook.** The natural-language Payout Criterion plus named Source Agency is the
  product. No symbol. (Corpus already flags this; confirmed.)
- **Self-certification as listing authority.** A market exists because a firm filed a form and a
  regulator did not object within a window. `Aw` is a transfer/access gate on *users*; this is an
  authority gate on *instruments*.
- **Segregation and the float.** Customer collateral is legally segregated but its investment yield
  accrues to the operator (Rule 7.9(E)). There is no symbol for "assets held for a claimant whose
  income belongs to the custodian."
- **Perpetual funding on an off-chain venue.** `Pf` exists in the vocabulary and describes the shape
  correctly, but Kalshi's funding is an exchange-computed rebalancing on an 8-hour cycle against a
  reference price the exchange selects, with exchange-set leverage caps — none of which `Pf`'s
  on-chain framing carries.

### 6. DELTA

1. **Kalshi is no longer a purely binary, purely fully-collateralised venue.** The corpus records
   elements `[Aw, Ct, Rd]` and a marker note that "margin exists for multi-leg and short positions."
   As of 2026-08-04 Kalshi lists **CFTC-regulated perpetual futures** with leverage up to 5.8× and
   an 8-hourly funding rate. That is a Margined Contract regime under Klear DCO Chapter 7 (initial
   margin, variation margin, intra-day calls), and it makes `Pf` a live candidate that the corpus
   does not record, and `Li`/`Ad` live questions that the corpus does not ask.
   Source: https://kalshi.com/perpetuals/learn ; Klear DCO Rules 7.2–7.4.
2. **The corpus residue line "the order book is a conventional off-exchange matching engine"
   mis-describes it.** It is an on-exchange central limit order book operated by the DCM, with a
   documented public API. The point the corpus wanted to make — that `Ob` is not honestly available
   because nothing is on-chain — survives; the description does not.
   Source: https://docs.kalshi.com/getting_started/orderbook_responses.
3. **The corpus's `Rd` marker says settlement is "a clearinghouse bookkeeping entry against a
   segregated account."** Confirmed verbatim, and it can now be cited: Klear Rule 6.2(C) and
   KalshiEX Rule 6.3(d)(b) describe exactly a debit of the settlement account and a credit to
   Member Accounts. No change; the corpus was right and can be upgraded from assertion to citation.
4. **Volume figure is reproducible.** Corpus: $10.89B/30d. `api.llama.fi/summary/dexs/kalshi` at
   time of check: **$10,795,003,258** /30d, $338,074,899 /24h. Same-day drift only; the ranking
   basis stands.
5. **The corpus's claim that "essentially the whole protocol is residue" understates the
   *positive* finding available here.** The Klear rulebook is the most precise specification of a
   default waterfall in the entire corpus, and it names structures (Company Contributions,
   Assessments, Contract Segments, VM gains haircutting, tear-ups) that DeFi has only partially
   re-invented. That is not residue in the sense of "nothing to say"; it is residue in the sense of
   "a fully-specified mechanism the vocabulary cannot hold."

---

## Polymarket

### 1. WHAT IT DOES

A user deposits stablecoin and buys **outcome shares** — YES or NO on a market whose resolution
criteria are written in prose and posted under the order book ("Markets are resolved according to
the market's pre-defined rules"). Each share pays $1 if its outcome occurs and $0 otherwise, so the
price is a probability. The user can also *create* the pair directly: $1 of collateral splits into
one YES and one NO, and returning both merges back into $1, which is what makes the whole system
fully collateralised without a counterparty. Outcomes are proposed by a bonded proposer to UMA's
Optimistic Oracle; if nobody disputes within a ~2-hour challenge window the proposal stands, and a
proposer who proposes too early or wrongly forfeits the bond ($750). A first dispute automatically
resets the market and re-requests a price; a second dispute escalates to UMA's Data Verification
Mechanism, a token-holder vote, which takes 48–72 hours. On resolution, winning shares redeem for
$1 each, losing shares become worthless, and trading stops. Positions therefore end in one of four
ways: sold on the book, merged back into collateral, converted through the negative-risk adapter,
or redeemed at resolution. Since July 2025 there is also a **second, separate Polymarket**: QCX LLC
d/b/a Polymarket US, a CFTC-designated contract market cleared by QC Clearing LLC, which is
off-chain, has no oracle at all, and settles by exchange-officer determination.

### 2. DESIGN

**Conditional-token representation.** Gnosis **Conditional Tokens Framework** (ERC-1155). A
condition is created by `prepareCondition(address oracle, bytes32 questionId, uint
outcomeSlotCount)`; the oracle later calls `reportPayouts(bytes32 questionId, uint[] payouts)`.
Positions are derived, not stored: a *collection id* is `getCollectionId(parentCollectionId,
conditionId, indexSet)` and a *position id* is `getPositionId(collateralToken, collectionId)`,
"used as the ERC-1155 ID." For a Polymarket binary market the index sets are 1 (YES) and 2 (NO)
over an outcomeSlotCount of 2, and the oracle address is the UMA CTF Adapter.

**The split/merge primitive.**
`splitPosition(IERC20 collateralToken, bytes32 parentCollectionId, bytes32 conditionId, uint[]
partition, uint amount)` "splits a position, burning stake from parent position and minting stake
in split target positions"; `mergePositions(...)` is its inverse; `redeemPositions(IERC20
collateralToken, bytes32 parentCollectionId, bytes32 conditionId, uint[] indexSets)` pays out
against the reported payout numerators and denominator. The invariants that make it a *state
partition* are enforced in code: the partition must have length > 1, must be pairwise disjoint
("partition not disjoint"), and every index set must satisfy `indexSet > 0 && indexSet <
fullIndexSet` — i.e. no element may be empty and none may be the whole state space. Polymarket's
own documentation restates the three operations as Split ("converts pUSD collateral into matched
YES and NO token pairs … locks exactly $1 of collateral per pair"), Merge, and Redeem.

**Matching engine.** Off-chain order book, on-chain settlement. Orders are signed by users and
matched by a Polymarket-operated **operator** which calls `matchOrders()` on the **CTF Exchange
V2** with a taker order and an array of maker orders; the contract validates signatures and
determines the match type by cross-price validation. Crucially, settlement has **three modes**, and
two of them *are* the split/merge primitive: **Complementary** (BUY vs SELL — direct transfer),
**Mint** (both sides BUY — collateral is split into the complementary outcome tokens), and
**Merge** (both sides SELL — outcome tokens are recombined into collateral). The matching engine
and the conditional-token partition are the same machine.

**Collateral.** Since **2026-04-28**, `pUSD` — "a standard ERC-20 token on Polygon, backed 1:1 by
USDC," with the backing "enforced onchain by the smart contract — no algorithmic peg, no
fractional reserve," convertible 1:1 with no fee. It replaced bridged USDC.e. The exchange wraps it
again as PMCT (PolyMarket Collateral Token) with a `CtfCollateralAdapter` bridging PMCT to CTF
mechanics and dedicated onramp/offramp contracts.

**Negative-risk adapter.** For a family of binary markets "of which one and only one will resolve
true," the `NegRiskAdapter` lets a holder convert NO positions into collateral plus the residual
YES: a position of "1 NO A and 1 NO B" is exchanged for "1 USDC and 1 YES C." To release collateral
before resolution the adapter holds its own `WrappedCollateral`, giving it control over liquidity
independent of the underlying CTF. A `NegRiskOperator` prepares questions and must have "its oracle
set to the address of the UmaCtfAdapter." The documented failure mode is a *constraint violation*:
"once one question is resolved as Yes/True, all other questions must be resolved as No/False" —
otherwise the market cannot fully resolve and funds are frozen.

**Resolution oracle and its dispute wrapper.** `UmaCtfAdapter`:
`initialize()` stores the market parameters (ancillary data ≤ 8139 bytes, reward token, reward,
proposal bond), prepares the condition on the CTF, and requests a price from UMA's Optimistic
Oracle; `ready()` reports whether a price is available and the question is unpaused and unresolved;
`resolve()` pulls the price, builds the payout array and calls `ctf.reportPayouts()`;
`priceDisputed()` is the OO callback that resets the question and re-requests, or refunds if
already resolved. Liveness defaults to ~2 hours. Since UMA's MOOV2 upgrade (UMIP-189), **proposals
are permissioned by a per-request proposer whitelist** set by the integration, while **disputes
remain permissionless**.

**Admin override.** Not a governance action — a contract function. `flag()` is admin-only, sets
`manualResolutionTimestamp = block.timestamp + SAFETY_PERIOD` (1 hour) and pauses the market;
`unflag()` cancels it inside the window; `resolveManually()` then writes the payout directly.
`reset()` re-issues a price request if the callback failed; `pause()`/`unpause()` gate resolution.
So the escalation ladder is: proposer → disputer → UMA DVM vote → **and, orthogonally at any point,
a 1-hour-delayed admin write.**

**Fee flow.** V2 charges an admin-settable maximum fee rate in basis points, default 500 (5%),
enforced per order, collected during settlement and validated before execution. Fees are now
"charged in USDC (not shares) and calculated at match time rather than placement time."

**Control plane.** An off-chain operator with exclusive matching rights; an admin role on the
adapter with pause/flag/manual-resolve; upgradeable collateral proxy. Audits: Cantina and
Quantstamp on the V2 exchange; OpenZeppelin on the UMA CTF adapter.

**The Polymarket US leg (entirely separate).** `QCX LLC d/b/a Polymarket US` is a Designated
Contract Market (designated 2025-07-09) with an NFA regulatory services agreement; `QC Clearing
LLC` is its DCO. Trades novate exactly as at Kalshi: "the Clearinghouse shall immediately, through
the process of Novation, be substituted as and assume the position of Seller and Purchaser"
(Polymarket US Rulebook, 2026-07-02, Rule 6.1(d)), preceded by a pre-trade collateral check (Rule
6.1(c)). The clearing house states publicly that it "clears only fully collateralized positions"
and "does not employ a margin-setting methodology or maintain a financial resource package." There
is **no oracle**: Rule 10.4 gives the CEO/CCO/COO/Head of Markets or a designate sole discretion to
run a Contract Outcome Review Process, to "determine the final outcome of a Contract," and even to
"reverse the final outcome of a Contract in the case of obvious error" — "The Company has full
discretion in reviewing markets. Determinations made by the Company are final." Minimum quote
increment $0.001; contracts tradeable in fractional units (Rule 10.1). Company liability to any one
participant is capped at $2,500/day, $5,000/month, $50,000/year (Chapter 11).

### 3. REPO

Multi-repo, all under `github.com/Polymarket`, all Solidity + Foundry:

- **`Polymarket/ctf-exchange-v2`** — the live exchange. **MIT.** Solidity 0.8.30. 78 commits on
  `main` (no tags surfaced). Layout: `src/exchange/` (matching and order processing),
  `src/adapters/` (CTF and collateral bridges), `src/collateral/` (wrapping, onramp/offramp),
  `lib/`, `test/`, `deploy/scripts/`. Deployed (Polygon): `CTFExchangeV2`
  `0xE111180000d2663C0091e4f400237545B87B996B`; `CollateralToken` proxy (pUSD)
  `0xC011a7E12a19f7B1f670d46F03B03f3342E82DFB`; `CollateralOnramp`
  `0x93070a847efEf7F70739046A929D47a521F5B8ee`.
- **`Polymarket/uma-ctf-adapter`** — MIT, Solidity/Foundry; `src/`, `audit/` (OpenZeppelin),
  `deploy/scripts/`, `docs/`, `lib/`, `test/`. Addresses are published per release rather than in
  the README.
- **`Polymarket/neg-risk-ctf-adapter`** — Solidity; `src/`, `docs/`, `audit/`, `addresses.json`.
  Polygon (chain 137): `NegRiskAdapter 0xd91E80cF2E7be2e162c6513ceD06f1dD0dA35296`,
  `NegRiskCtfExchange 0xC5d563A36AE78145C45a50134d48A1215220f80a`,
  `NegRiskOperator 0x71523d0f655B41E805Cec45b17163f528B59B820`,
  `NegRiskUmaCtfAdapter 0x2F5e3684cb1F318ec51b00Edba38d79Ac2c0aA9d`,
  `NegRiskVault 0x7f67327E88c258932D7d8f72950bE0d46975E11D`,
  `NegRiskWrappedCollateral 0x3A3BD7bb9528E159577F7C2e685CC81A765002E2`,
  `NegRiskFeeModule 0x78769D50Be1763ed1CA0D5E878D93f05aabff29e`. (Amoy testnet set also listed.)
- **Substrate, not Polymarket's:** `gnosis/conditional-tokens-contracts` — **LGPL-3.0**; the
  canonical CTF is `0x4d97dcd97ec945f40cf65f87097ace5ea0476045` on Polygon (the repo README also
  lists Ethereum mainnet `0xC59b0e4De5F1248C1140964E0fF287B192407E0C` and xDai
  `0xCeAfDD6bc0bEF976fdCd1112955828E00543c0Ce`).

**Do deployed contracts match the repo?** The exchange V2 addresses come from the repository's own
deployment section, and the neg-risk addresses from a committed `addresses.json`, so the mapping is
self-declared and consistent. I did **not** perform bytecode verification; treat "deployed matches
repo" as UNKNOWN at the level of on-chain verification.

**Polymarket US:** a regulated off-chain exchange and clearing house. Nothing is in a repository.
What is verifiable is the **Polymarket US Rulebook dated July 2, 2026** (80 pp.), the CFTC DCM
designation record for QCX LLC (2025-07-09), and the public clearing disclosures.

### 4. EVIDENCE

| Claim | Source | Accessed |
|---|---|---|
| CTF: split/merge/redeem semantics, position id derivation, ERC-1155, pUSD, index sets 1/2 | https://docs.polymarket.com/developers/CTF/overview | 2026-08-04 |
| CTF function signatures, partition-disjointness and indexSet bounds, prepareCondition/reportPayouts | https://raw.githubusercontent.com/gnosis/conditional-tokens-contracts/master/contracts/ConditionalTokens.sol | 2026-08-04 |
| CTF licence LGPL-3.0 and deployment addresses | https://github.com/gnosis/conditional-tokens-contracts | 2026-08-04 |
| CTF Exchange V2: MIT, Solidity 0.8.30, layout, `matchOrders()`, Complementary/Mint/Merge settlement, 500 bps max fee, addresses | https://github.com/Polymarket/ctf-exchange-v2 | 2026-08-04 |
| pUSD backed 1:1 by USDC, enforced on-chain; V2 cutover 2026-04-28 ~11:00 UTC; audits Cantina + Quantstamp; fees in USDC at match time | https://help.polymarket.com/en/articles/14762452-polymarket-exchange-upgrade-april-28-2026 | 2026-08-04 |
| UMA adapter flow, ~2h liveness, first dispute resets, second escalates to DVM 48–72h, OpenZeppelin audit | https://github.com/Polymarket/uma-ctf-adapter ; https://raw.githubusercontent.com/Polymarket/uma-ctf-adapter/main/README.md | 2026-08-04 |
| `flag()` → `SAFETY_PERIOD` (1 hour) → `resolveManually()`, `reset()`, `pause/unpause`, ancillaryData ≤ 8139 bytes | https://raw.githubusercontent.com/Polymarket/uma-ctf-adapter/main/src/UmaCtfAdapter.sol | 2026-08-04 |
| $750 proposer bond, 2-hour challenge period, rules under the order book, $1 per winning share | https://help.polymarket.com/en/articles/13364518-how-are-prediction-markets-resolved | 2026-08-04 |
| UMA MOOV2 managed proposers / per-request whitelist, permissionless disputes, UMIP-189 | https://blog.uma.xyz/articles/managed-proposers ; https://blog.uma.xyz/articles/managed-proposers-update | 2026-08-04 |
| Neg-risk conversion semantics, WrappedCollateral, NegRiskOperator oracle wiring, mutual-exclusivity requirement | https://github.com/polymarket/neg-risk-ctf-adapter | 2026-08-04 |
| Neg-risk deployed addresses (chains 137 and 80001) | https://raw.githubusercontent.com/Polymarket/neg-risk-ctf-adapter/main/addresses.json | 2026-08-04 |
| Polymarket US Rulebook (2026-07-02): Rule 6.1(c)-(d) novation, Rule 10.1–10.4 product specs and Contract Outcome Review, Chapter 11 liability caps | https://www.polymarketexchange.com/files/legal/latest/rulebook | 2026-08-04 |
| QC Clearing LLC is a registered DCO; "clears only fully collateralized positions"; "does not employ a margin-setting methodology or maintain a financial resource package" | https://www.polymarketexchange.com/clearing/ | 2026-08-04 |
| QCX LLC d/b/a Polymarket US designated DCM, 2025-07-09 | https://www.cftc.gov/IndustryOversight/IndustryFilings/TradingOrganizations/49571 | 2026-08-04 |
| Acquisition of QCEX (QCX LLC + QC Clearing LLC) for $112M | https://www.prnewswire.com/news-releases/polymarket-acquires-cftc-licensed-exchange-and-clearinghouse-qcex-for-112-million-302509626.html | 2026-08-04 |
| TVL $329,082,174; 30d volume $3,084,599,447 | https://api.llama.fi/protocol/polymarket ; https://api.llama.fi/summary/dexs/polymarket | 2026-08-04 |

### 5. WHAT LOOKS UNNAMEABLE

- **CONDITIONAL-TOKEN SPLIT / MERGE.** Corpus claim (a) **CONFIRMED, and stronger than stated.**
  `splitPosition` partitions collateral along the *state space* of a condition, under an enforced
  disjointness-and-coverage invariant; `Py` partitions a claim along *time* and has no partition
  argument at all. Two additional facts the corpus does not record make the gap worse: (i) the CTF
  is *recursive* — a position can be split again against a second condition via
  `parentCollectionId`, so the primitive builds a lattice of joint-state claims, not just a pair;
  and (ii) split and merge are not merely user operations, they are **two of the three settlement
  modes of the matching engine** (two crossing BUYs mint a pair from collateral; two crossing SELLs
  merge a pair back). A vocabulary with no state-partition symbol cannot name Polymarket's order
  matching either.
- **The negative-risk conversion.** Not just "a constraint-imposing wrapper": it converts a bundle
  of N−1 complementary claims into collateral *plus a claim on the residual outcome*, using a
  privately-held wrapped-collateral buffer to release liquidity before resolution. It is an
  arbitrage-free-completion operator over a family of conditions. No symbol, and no symbol for the
  mutual-exclusivity *constraint* it enforces either.
- **The market rulebook.** Confirmed as corpus states. What `Oa` names is the wrapper; the product
  is the prose.
- **The admin manual-resolution path with a 1-hour safety period.** A time-delayed unilateral write
  of the payout vector. `Tg` names a delay on governance execution; this is a delay on an
  *operator's factual determination*, and the delay is one hour, not a governance cycle.
- **A permissioned proposer set inside an "optimistic" oracle.** `Oa`'s whole shape is
  permissionless assertion. Once proposals are whitelisted per-request while disputes remain open,
  the mechanism is *asymmetrically permissioned*, and `Oa` cannot express the asymmetry.
- **A second, off-chain resolution regime for the same brand.** Polymarket US Rule 10.4 is the same
  unnameable tribunal identified for Kalshi. The same market question resolves by bonded assertion
  on Polygon and by officer discretion in New York.
- **Novation and the CCP** (Polymarket US leg) — as for Kalshi, with a twist that *weakens* the
  corpus's framing: QC Clearing has **no guaranty fund and no financial resource package at all**.
  So the vocabulary's `Bs`/`Sl`/`Ad` trio does not reconstruct *this* clearing house; a
  fully-collateralised CCP is a pure novation-and-custody institution with no loss-mutualisation
  layer whatsoever, and the vocabulary has even less to say about it.
- **A 1:1 reserve-backed collateral wrapper (pUSD), then wrapped again (PMCT).** `Ps` (peg-swap
  module, 1:1 reserve-backed) is a genuine fit for pUSD and is *absent* from the corpus record.
  The second wrap (PMCT) — a collateral token that exists so an adapter can hold liquidity outside
  the CTF's accounting — has no symbol.

### 6. DELTA

1. **Collateral is pUSD, not USDC.** Since 2026-04-28 the collateral token is `pUSD`, an ERC-20 on
   Polygon backed 1:1 by USDC with on-chain enforcement, replacing bridged USDC.e. The corpus
   record does not mention it, and it arms `Ps` (peg-swap module, 1:1 reserve-backed), which the
   corpus's canonical form `[Aw, Gp, Gs, Oa, Ob, Rd, Up]` omits.
   Source: https://help.polymarket.com/en/articles/14762452-polymarket-exchange-upgrade-april-28-2026.
2. **The live exchange is CTF Exchange V2, and its settlement types make split/merge part of
   matching.** The corpus's `Ob` marker ("off-chain signed-order matching with on-chain
   settlement") is still true but incomplete: two crossing BUYs *mint* a complementary pair and two
   crossing SELLs *merge* one. Source: https://github.com/Polymarket/ctf-exchange-v2.
3. **Polymarket now operates a central counterparty of its own.** The corpus attributes the CCP gap
   exclusively to Kalshi ("what the #1 protocol by volume in this category actually is"). Since
   2025-07-09, QCX LLC d/b/a Polymarket US is a DCM and QC Clearing LLC is a DCO that novates every
   trade (Rulebook Rule 6.1(d)). The gap is now shared by two of the five.
   Sources: https://www.polymarketexchange.com/files/legal/latest/rulebook ;
   https://www.cftc.gov/IndustryOversight/IndustryFilings/TradingOrganizations/49571.
4. **The category residue sentence "Two of the three prediction markets have no expressible
   resolution mechanism whatsoever" is now understated.** Polymarket US resolves by Rule 10.4
   officer discretion with no oracle. Counting venues rather than brands: Kalshi, Azuro and
   Polymarket US have no expressible resolution mechanism; only Polymarket-on-Polygon has `Oa`.
5. **The admin override is more concrete than the corpus records.** The corpus calls it "the
   admin/UMIP-level resolution OVERRIDE path." It is `flag()` → `SAFETY_PERIOD` = 1 hour →
   `resolveManually()`, admin-role-gated, in `UmaCtfAdapter.sol`. This is a checkable constant, not
   a governance narrative. Source:
   https://raw.githubusercontent.com/Polymarket/uma-ctf-adapter/main/src/UmaCtfAdapter.sol.
6. **The whitelist claim is confirmed but the asymmetry should be recorded.** The corpus says
   "proposals are now restricted to a WHITELIST, making it a permissioned assertion." True — via
   UMA's MOOV2 / UMIP-189 per-request proposer whitelist — but **disputes remain permissionless**,
   which is the structurally interesting half. Sources:
   https://blog.uma.xyz/articles/managed-proposers ; https://blog.uma.xyz/articles/managed-proposers-update.
7. **The WSJ voter-conflict statistics in the corpus marker for `Oa` were not re-verified in this
   lane. UNKNOWN.** I did not reach the May 2026 WSJ piece at a primary source and am not
   restating its numbers.
8. **`identicalClaimedByLane` (Predict Fun / OPINION / InsightX as CTF+CLOB+UMA clones) was not
   verified in this lane. UNKNOWN.**
9. **TVL/volume reproduce.** Corpus $330.8M TVL / $3.14B 30d; measured $329.08M / $3.0846B. Drift
   only. Note that `api.llama.fi/protocol/polymarket` returns an **empty** `category` field, so the
   corpus's category attribution for Polymarket does not come from that endpoint.

---

## Azuro

### 1. WHAT IT DOES

A bettor picks an outcome in an event ("Condition") and stakes collateral at **fixed odds quoted at
the moment of the bet**. There is no counterparty on the other side of the trade: a single
protocol-wide liquidity pool underwrites every bet, so the bettor is always trading against the
pool. Odds are seeded by a permissioned **Data Provider** and then move automatically against
incoming flow — the more money arrives on an outcome, the worse that outcome's price becomes for
the next bettor — but the odds already struck are locked in, so the payout is fixed at bet time.
The bettor holds an `AzuroBet` NFT representing the position. The same Data Provider that priced the
event also **resolves** it: it declares the winning outcome, and Azuro's docs state that Data
Providers "currently resolve conditions in good faith," citing Pinnacle's published settlement
rules, with **AzuroDAO "acting as the arbiter of last resort in case of disputes."** A Condition can
also be *Canceled*, in which case bettors are refunded rather than losing. The position ends by
claiming the payout after resolution, by refund after cancellation, or — in V3 — by **Cashout**,
selling the open bet back to the pool at a quoted price before the event concludes. On the other
side, a liquidity provider deposits into the pool, is locked for 7 days, and thereafter shares the
pool's profit or loss.

### 2. DESIGN

**Pool architecture.** A *Pool* is a set of contracts deployed by a `Factory` (ERC-721 + OpenZeppelin
BeaconProxy for upgradeability): an `LP` contract as the entry point for liquidity, bets, payouts
and fee accumulation; an `Access` contract that tokenises roles; a `Vault` built on the
`LiquidityTree`; one or more **Betting Engines** (`PrematchCore`, `LiveCore`, `BetExpress` for
combos) that create Conditions, accept bets, compute payouts and calculate app rewards; a `Relayer`
that is "the execution entry point for all protocol bets," taking signed orders and pulling
sponsored fees and freebet amounts from a `PayMaster`; and `AzuroBet`, the bet NFT. V3 also has a
`Cashout` contract.

**Odds — the closed form.** For virtual funds `F_0 … F_n`:

```
o_i = (F_0 + … + F_n) / F_i          (net odds for outcome i)
p_i = 1 / o_i = F_i / Σ F            (implied probability)
s_i = 1 − p_i · o_i                  (spread / juice on outcome i)
∀ j ≠ i :  s_i / s_j = p_j / p_i     (spread allocation rule)
1 − 1 / Σ (1/o_i) = margin           (total margin constraint)
payout = o_i × (1 − s_i) × a         (fixed payout, a = bet amount)
```

The spread is "proportional to margin size and inversely proportional to outcome probability" —
i.e. long-shots carry more juice.

**vAMM.** Each Condition carries a **Virtual Fund** per outcome. On a bet of size `a` on outcome `i`:

```
F_i  ←  F_i − a
F_j  ←  F_j − (payout − a) · F_j / Σ F      for all j ≠ i
```

Because `F_i` shrinks, `o_i` rises and `p_i` falls: odds move against flow automatically. The
virtual funds are *parameters*, not the pool's real balance; the vAMM "does not require
bootstrapping and instead inherits liquidity from Azuro's singleton liquidity pool."

**Reinforcement — the capital reservation.** "Reinforcement is the initial liquidity amount that is
distributed among outcomes of a Condition in accordance with the betting odds." It is set at
Condition creation, immutable thereafter, and it *bounds the pool's loss*: "the overall loss for the
Condition in the worst-case scenario cannot exceed the size of the Reinforcement." This is what
lets many simultaneous Conditions share one pool without oversubscribing it.

**LiquidityTree — the accounting.** A segment tree over LP deposits. "Each deposit is represented as
a separate 'leaf' element"; K elements are stored in an array of size 2K+1 with the root at index 1
and leaves beginning at K; left child of X is 2X, right is 2X+1. `nodeAddLiquidity()` initialises
the next leaf and propagates up to the root; `nodeWithdraw()` finds the most recently updated
parent, actualises the leaf, then removes liquidity and updates ancestors; `addLimit()` distributes
a Condition's P&L across a leaf *range*. Updates are **lazy**: P&L is annotated at parent nodes and
only pushed down when an LP withdraws, "saving the need to update individual LP balances on every
block." Consequence: an LP's claim is not a fungible pro-rata share of a single pot; it is a leaf
with an entry position in the tree, and P&L attribution depends on *when* the deposit entered.

**Data Provider — pricing and truth in one party.** "The Data Provider is an entity connected to the
protocol with the responsibility to create and cancel events, as well as update (or reprice)
sell-side odds," sets reinforcements and margins, and resolves outcomes. Data Providers "must put up
collateral up to the total Reinforcement amount that they expect to use for the pricing of sell-side
odds across all of their active markets." The role is permissioned "due to the critical nature of
the role," with permissionless provision "elected by AzuroDAO" as a future goal. Pinnacle is named
as an active provider.

**Condition lifecycle.** States: Created, Resolved, Canceled, Paused. A Condition carries game and
outcome data, virtual funds, total net bets, reinforcement and margin, and potential payouts per
outcome. Cancellation refunds bettors.

**Fee flow.** Four claimants on pool revenue. After each Condition completes, "the profit or loss of
the pool is multiplied by the reward rate (20% and 10% respectively)" for **LPs** and **Data
Providers**. **Apps** (frontends) receive the *lesser* of `70% × AppRevenue` and a monthly
`SpreadRewardCap` of `50% × Spread × BetSize` summed per bet. **AzuroDAO** takes the residual —
"calculated by deducting all other rewards from the total monthly Pool Revenue." LP, Data-Provider
and DAO rewards "can happen to be negative in the event of Pool losses"; app rewards "can be only
positive or zero." The split is not fixed: it "may be subject to further changes if deemed necessary
by AzuroDAO."

**LP terms.** A 7-day lock, then withdrawal at will. Azuro's own documentation warns that "liquidity
positions held under a week will most likely be in the red."

**Control plane.** `Factory` + beacon proxies (upgradeable), `Access` contract tokenising roles, pool
owner able to attach Betting Engines, AzuroDAO as parameter-setter and dispute arbiter of last
resort, and Data Provider ability to Pause and Cancel Conditions.

### 3. REPO

**This is the weakest repo story in the category.** The `Azuro-protocol` GitHub org has 31 public
repositories, but the only protocol-contract repository is:

- **`Azuro-protocol/Azuro-v2-public`** — **GPL-3.0**, Solidity + Hardhat (JavaScript tooling).
  Layout: `contracts/`, `docs/`, `scripts/`, `test/`, `utils/`, plus `hardhat.config.js`. Contracts
  present: `AzuroBet`, `Core`, `Factory`, `LP`, `FreeBet`. Beacon-proxy upgrades; deployment scripts
  expect `FACTORY_ADDRESS` and beacon addresses. **15 commits; last updated 2025-01-29.** It
  documents **V2**.
- **`Azuro-protocol/LiquidityTree`** — the segment-tree library, last updated 2025-04-17.
- **`Azuro-protocol/Access`** — the role-token contract, last updated 2026-05-19.
- Everything else in the org is SDK/tooling/docs: `sdk`, `toolkit`, `gem-docs` (MDX, "V2
  Documentation"), `public-config` (ABIs under `abis/eth/`, 294 commits), `dictionaries`,
  `example-app`, `Azuro-subgraphs`, `RewardPool` ("Azuro staking and reward distribution", last
  updated 2025-06-19), `Bug-Bounty`, `OpenRandom`, `PoolBetting`.

**Do deployed contracts match the repo?** **No — and this is a finding, not an omission.** The live
deployments are **Protocol V3** (Polygon, Gnosis, Base, Chiliz), with V2 kept as legacy (Gnosis,
Polygon, Chiliz, Base, Arbitrum, Linea). The V3 contract set includes `LiveCore`, `Cashout`,
`Relayer` and `PayMaster`, **none of which appear in `Azuro-v2-public`**, and I could locate no
public V3 contracts repository in the org. The V3 ABIs are distributed through `public-config` and
the docs list V3 deployment addresses, but the *source* for the live system is, as far as I can
verify, **not public**. Mark: source for deployed V3 contracts = UNKNOWN / not located.

**Audits:** UNKNOWN for V3. `Azuro-v2-public` surfaces no audit directory; the only assessment I
found is a third-party review dated December 2023, which predates V3.

### 4. EVIDENCE

| Claim | Source | Accessed |
|---|---|---|
| Pool composition: Factory, LP, Vault, Access, LiveCore, Relayer, PayMaster; BeaconProxy upgradeability | https://gem.azuro.org/hub/blockchains/architecture | 2026-08-04 |
| Betting Engines definition; PrematchCore inherits CoreBase; BetExpress for combos | https://gem.azuro.org/knowledge-hub/how-azuro-works/components/betting-engines | 2026-08-04 |
| Pool definition and Factory deployment | https://gem.azuro.org/knowledge-hub/how-azuro-works/components/pools | 2026-08-04 |
| Odds formulas `o_i`, `p_i`, `s_i`, margin constraint, `payout = o_i × (1−s_i) × a`, fixed at bet time | https://gem.azuro.org/knowledge-hub/how-azuro-works/components/odds | 2026-08-04 |
| vAMM update rules for virtual funds; worst-case loss bounded by Reinforcement | https://gem.azuro.org/knowledge-hub/how-azuro-works/components/vAMM | 2026-08-04 |
| Reinforcement: set at creation, immutable, caps pool exposure | https://gem.azuro.org/knowledge-hub/how-azuro-works/components/reinforcement | 2026-08-04 |
| LiquidityTree: 2K+1 array, root at 1, children 2X/2X+1, `nodeAddLiquidity`/`nodeWithdraw`/`addLimit`, lazy updates | https://gem.azuro.org/knowledge-hub/how-azuro-works/liquidity-tree ; https://github.com/Azuro-protocol/LiquidityTree | 2026-08-04 |
| Data Provider: creates/cancels/reprices, resolves in good faith, posts collateral up to total Reinforcement, permissioned, **AzuroDAO arbiter of last resort** | https://gem.azuro.org/knowledge-hub/how-azuro-works/protocol-actors/data-providers | 2026-08-04 |
| Condition states Created/Resolved/Canceled/Paused; refunds on cancel | https://gem.azuro.org/knowledge-hub/how-azuro-works/components/conditions | 2026-08-04 |
| Reward split: LP 20%, DP 10% of pool P&L; Apps min(70%×AppRevenue, 50%×Spread×BetSize monthly); DAO residual; LP/DP/DAO can be negative | https://gem.azuro.org/knowledge-hub/how-azuro-works/reward-distribution | 2026-08-04 |
| LP 7-day lock; sub-week positions likely negative | https://gem.azuro.org/knowledge-hub/how-azuro-works/protocol-actors/liquidity-providers | 2026-08-04 |
| V3 chains (Polygon, Gnosis, Base, Chiliz) and V2 legacy chains; contract list incl. AzuroBet NFT, Cashout | https://gem.azuro.org/hub/blockchains/deployment-addresses | 2026-08-04 |
| Cashout released in V3 | https://gem.azuro.org/hub/releases/29-cashouts | 2026-08-04 |
| `Azuro-v2-public`: GPL-3.0, contracts list, 15 commits | https://github.com/Azuro-protocol/Azuro-v2-public | 2026-08-04 |
| Org repository inventory and last-updated dates | https://github.com/orgs/Azuro-protocol/repositories?type=all | 2026-08-04 |
| TVL $1,592,162; category "Prediction Market"; 30d volume $623,251 | https://api.llama.fi/protocol/azuro ; https://api.llama.fi/summary/dexs/azuro | 2026-08-04 |

### 5. WHAT LOOKS UNNAMEABLE

- **Peer-to-pool payoff underwriting.** One pool is the counterparty to every bet, writing a
  non-linear, event-contingent payoff. `Pl` is lending; `Cv` requires adjudicated claims against
  pooled premium; `Op` is a strike/expiry option. Confirmed as corpus states.
- **Odds as a function of pool inventory (the vAMM).** The update rule prices a *probability against
  the pool's own exposure*, and the pricing state (virtual funds) is deliberately decoupled from the
  real balance. `Cp`, `Wg`, `St`, `Cl`, `Pm` all price an asset against another asset or against an
  external oracle. None of them prices a state against inventory. Confirmed.
- **Reinforcement as a per-event loss bound.** `Rl` (resource lock / reservation) is the closest fit
  and the corpus's marker is right to register it, but note the difference: `Rl` reserves a
  *resource*; Reinforcement reserves a *worst-case loss*, computed across a whole outcome vector,
  fixed at creation, and used as the pricing seed as well as the exposure cap. It is a risk budget
  and a price prior at once.
- **Fixed odds struck at bet time, priced by a moving curve.** The bettor's payoff is locked at the
  instant of trade while the curve keeps moving for everyone after. There is no symbol for a
  *quoted-and-locked* payoff drawn from a continuously repriced pool.
- **Parlay / combo correlation risk (`BetExpress`).** Legs multiply the payout but the pool's
  exposure is not the product of the legs' exposures. Confirmed as corpus states.
- **Cashout — early buy-back of an unresolved position by the pool.** *Not in the corpus record at
  all.* The pool quotes a price to extinguish a live contingent claim before the event settles. It
  is neither `Rd` (no resolved payout to redeem against) nor `Ob` (no counterparty) nor `Op`. New
  residue.
- **A single party that both prices and adjudicates.** `Ex` misrepresents it as an oracle (no
  medianizer, no aggregation, no feed); `Sv` is written for loan servicing. Confirmed.
- **Data-Provider collateral.** The DP must post collateral up to the total Reinforcement it expects
  to use. That is a bond against *mispricing*, not against insolvency or against a false report —
  `Bs` is the nearest shape and does not fit, because nothing in the docs describes slashing it.
- **Per-deposit, entry-indexed P&L with lazy propagation.** `Sh` (pro-rata share accounting) does not
  describe the LiquidityTree. A leaf's claim depends on its position in the tree and on which
  Conditions resolved during its residence; there is no single global index (`Ix`) and no rebase
  (`Rb`). The tree is a third accounting form the vocabulary does not have.
- **App/frontend revenue sharing with a per-bet spread cap.** Apps take `min(70% × AppRevenue,
  Σ 50% × Spread × BetSize)`. `Fd` (surplus & fee distribution) covers the fact of distribution but
  not a *capped-by-a-different-quantity* rule, and the notion of a frontend as a first-class
  revenue claimant has no symbol.

### 6. DELTA

1. **"No dispute path" is contradicted by Azuro's own documentation.** The corpus residue says the
   Data Provider "supplies both the initial odds AND the outcome resolution, with no dispute path."
   Azuro's Data Providers page states that the protocol incorporates a safeguard "with AzuroDAO
   acting as the arbiter of last resort in case of disputes." The *mechanism* of that arbitration is
   not specified on-chain anywhere I could find (mark: mechanism UNKNOWN), but the flat claim of "no
   dispute path" is wrong as documented.
   Source: https://gem.azuro.org/knowledge-hub/how-azuro-works/protocol-actors/data-providers.
2. **Data Providers post collateral.** The same page: DPs "must put up collateral up to the total
   Reinforcement amount that they expect to use." The corpus records no bond for Azuro at all, and
   this is the one place a `Bs`-shaped candidate arises.
3. **`Em` (protocol-funded emissions) in the corpus element set is questionable.** The reward
   distribution I could verify is a *share of pool P&L and spread revenue*, not protocol-funded
   emissions — and LP/DP/DAO rewards can be **negative**. An `Azuro-protocol/RewardPool` repo
   ("Azuro staking and reward distribution") exists, last updated 2025-06-19, but I could not
   confirm at a primary source that protocol-funded emissions are currently paid. Mark: UNKNOWN,
   and flag `Em` for re-checking in Stage 2.
   Source: https://gem.azuro.org/knowledge-hub/how-azuro-works/reward-distribution.
4. **`Sh` in the corpus element set does not match the LiquidityTree.** LP claims are per-deposit
   leaves with entry-dependent P&L and lazy propagation, not a global pro-rata share. The LP
   position's token standard is UNKNOWN (the docs do not state whether it is fungible, an NFT, or a
   bare accounting entry). This is a distinct finding from the corpus's (correct) `Rl` marker.
5. **Cashout (V3) is missing from the corpus.** Early buy-back of an open bet by the pool.
   Source: https://gem.azuro.org/hub/releases/29-cashouts.
6. **The corpus does not record that the deployed system is V3 while the only public contract repo
   is V2 and 18 months stale.** For a formalism project this matters: any construction checked
   against `Azuro-v2-public` is being checked against a superseded system.
   Sources: https://github.com/Azuro-protocol/Azuro-v2-public ;
   https://gem.azuro.org/hub/blockchains/deployment-addresses ;
   https://gem.azuro.org/hub/protocol-v3/v3-migration-guide.
7. **Ranking basis reproduces.** Corpus $1.59M TVL; measured $1,592,162. Additionally, Azuro's 30-day
   volume is $623,251 — four orders of magnitude below Kalshi and Polymarket, which supports the
   corpus's decision to rank it by *architecture* rather than by size, but should be stated
   explicitly rather than left implicit.

---

## Steakhouse Financial (Risk Curators)

### 1. WHAT IT DOES

A depositor puts a stablecoin (usually USDC) into an ERC-4626 vault and receives vault shares. The
vault does not itself lend; it **allocates** the deposit across a set of isolated lending markets on
a base protocol — Morpho on Ethereum and Base, Kamino on Solana — chosen by Steakhouse. What the
depositor is buying, therefore, is a *manager*: Steakhouse decides which collateral types the
capital may be lent against, at what supply cap per market, and in what order deposits fill and
withdrawals drain. The depositor's yield is the blended interest of those markets minus Steakhouse's
fee, and the depositor's risk is the credit and oracle risk of markets they did not choose.
Steakhouse is paid a performance fee on generated interest (protocol maximum 50%; Steakhouse's High
Yield line is "typically 10%") and, on Morpho Vaults V2, may also charge a management fee on assets
(protocol maximum 5%/yr). The depositor's recourse is threefold and all of it is *ex ante*, not
compensatory: (i) exit at any time, subject to available market liquidity and the withdraw queue;
(ii) a timelock — Steakhouse imposes 7 days on new-market onboarding for its Prime line, above the
protocol minimum — during which capital cannot enter a newly-approved market; and (iii) an Aragon
DAO guardian in which "vault users become vault guardians proportionally to the size of their
deposit," able to veto critical curator actions. What the depositor does **not** get is any claim
against Steakhouse: the terms state "WE ARE NOT A BROKER, INTERMEDIARY, AGENT, CUSTODIAN, OR
ADVISOR" and "NO FIDUCIARY RELATIONSHIP OR OBLIGATION TO YOU," with total liability capped at
$1,000 and disputes routed to Cayman Islands arbitration with a class-action waiver.

### 2. DESIGN

**Position representation.** ERC-4626 vault shares (with ERC-2612 permit on Morpho V1). One vault per
loan asset. Fees are taken by minting *new shares* to the fee recipients rather than by skimming
assets: "New vault shares corresponding to the fee amounts are minted directly to the
`performanceFeeRecipient` and `managementFeeRecipient` addresses."

**Allocation substrate.** Morpho Blue isolated markets (V1 vaults, `MetaMorpho`) and Morpho Vaults V2
adapters, plus Kamino on Solana. Morpho V1: maximum 30 enabled markets per vault; deposits fill
along a `supplyQueue` up to per-market caps; withdrawals drain along a `withdrawQueue`; "idle
supply" is held in a market with null oracle and collateral addresses; supply caps default to 0 so a
market is unusable until explicitly capped up; a forced-market-removal path exists for faulty
markets. Vaults V2 replaces markets with **adapters** and an adapter registry.

**Role model.** Morpho V1: `Owner` (single; inherits curator, allocator and guardian powers; sets
fees and timelock), `Curator` (single; raises caps under timelock, lowers them immediately, revokes
pending actions), `Allocator` (many; reallocates between markets within curator bounds, manages the
supply and withdraw queues), `Guardian` (0 or 1; revokes pending timelocked actions — but **cannot**
revoke fee changes). Morpho Vaults V2 splits this properly: `Owner` (appoints roles only, no
inherited powers), `Curator` (allocation strategy, adapters, caps, fees — timelocked for adapter
changes, cap *increases* and fee settings; cap *decreases* immediate), `Allocator` (many; deploy
within curator bounds), `Sentinel` (many; deallocate, decrease caps instantly, revoke pending
timelocked actions). Minimum timelock on risky actions in V1 is 24 hours.

**Steakhouse's own configuration on top of that.** `Owner` is a Safe multisig with a **5-of-5**
quorum. `Guardian` is an **Aragon DAO** in which depositors hold veto weight proportional to deposit
size. New-market onboarding carries a **7-day** action timelock (Prime; High Yield uses 3 days),
explicitly "to provide depositors time to withdraw or exercise veto rights before capital
deployment." Allocation itself is executed by an automated engine. Before a market is listed, "at
least two members of the Steakhouse risk management team perform an asset and market configuration
quality control process" across six risk vectors — credit, counterparty, liquidity, oracle, smart
contract, and liquidity trap — and each vault passes a "Vault DDQ process" requiring at least two
internal and one external reviewer.

**Risk methodology (the actual intellectual product).** A three-layer rating: Layer 1 **Asset
Rating** decomposed into three pillars (Issuer, Credit Risk, Operational Risk); Layer 2 **Platform
Rating**; Layer 3 **Market Rating** with sub-criteria for Oracle, Liquidity, Price Fluctuation,
LLTV, and Credit Enhancement; then an Adjusted Asset Rating and a Final Market Rating. This
methodology is published, versioned documentation — and it is the thing that determines where the
money goes, while being entirely off-chain.

**Product lines.** *Prime Instant* and *Prime Term* — blue-chip collateral only (ETH, wstETH,
tokenized BTC, wUSDM, USYC), 7-day timelock, Aragon guardian veto, Morpho Sentinel enabled. *High
Yield Instant* and *High Yield Term* — exotic collateral, fee "typically 10% with some temporary
waivers," 3-day timelock. *Turbo* — Morpho Vaults V2 with a custom adapter registry, running
leveraged looping and carry. Plus partnership vaults, legacy vaults, and a Coinbase DeFi Lend
integration ("Steakhouse USDC on Coinbase", "Steakhouse High Yield USDC Edition on Coinbase"). Own
infrastructure includes a **MetaOracle (Deviation Timelock)**, **Box Vaults**, and a **Supervisor
v2**.

**Fee flow.** Performance fee ≤ 50% of generated interest; management fee ≤ 5%/yr on assets (V2).
The `Curator` sets both the rate and the recipient; on V2 all fee changes are timelocked, whereas on
V1 the `Owner` could change them immediately. Fee accrual triggers on interaction (deposit,
withdraw), and a fee recipient that never transacts cannot actually receive underlying assets.

**Control plane.** Off-chain: a Cayman company, a risk committee, a published methodology, an
allocation bot. On-chain: a 5-of-5 Safe as Owner, a curator address, allocator addresses, an Aragon
DAO as Guardian, and Morpho's own timelock and cap machinery.

### 3. REPO

**Steakhouse has no protocol repository. It is a mandate, not a protocol.** The code its vaults run
on is Morpho's:

- **`morpho-org/metamorpho`** (Vault V1) — **GPL-2.0-or-later**, Solidity/Foundry. Layout:
  `src/`, `test/`, `audits/`, `certora/` (formal verification specs), `lib/`, `.github/workflows/`,
  `foundry.toml`. ERC-4626 + ERC-2612; immutable deployment via `MetaMorphoFactory`; ≤30 markets per
  vault; supply/withdraw queues; ≥24h timelock; performance fee ≤50%. The README states V1 "has been
  superseded by Morpho Vault V2" (`morpho-org/vault-v2`).
- A representative deployed vault: **Steakhouse USDC (`STEAKUSDC`)**
  `0xBEEF01735c132Ada46AA9aA4c54623cAA92A64CB` on Ethereum.

**Off-chain mandate — say so explicitly.** The allocation decision, the risk ratings, the DDQ, the
6-vector QC and the 5-of-5 signing are all off-chain and unverifiable. What *is* verifiable on-chain
is the vault's role assignments, its enabled markets and caps, its supply/withdraw queue ordering,
its timelock value, and its fee rate and recipient. What is **not** verifiable is why any of those
values were chosen. Legal entity: **Steakhouse Financial Ltd**, Cayman Islands. (Morpho's own UI
attributes the vaults to an operating entity "Carniceria Tropical SA"; I could not confirm that name
at a Steakhouse primary source — mark UNKNOWN.)

### 4. EVIDENCE

| Claim | Source | Accessed |
|---|---|---|
| Morpho fees: performance ≤50% of interest, management ≤5%/yr, curator sets rate and recipient, V2 fee changes timelocked (V1 owner immediate), fee shares minted to recipients | https://docs.morpho.org/curate/concepts/fee/ | 2026-08-04 |
| Role model V1 (Owner/Curator/Allocator/Guardian) and V2 (Owner/Curator/Allocator/Sentinel), powers, timelock behaviour, multiplicity | https://docs.morpho.org/curate/concepts/roles/ | 2026-08-04 |
| MetaMorpho: GPL-2.0-or-later, ERC-4626/2612, ≤30 markets, supplyQueue/withdrawQueue, idle supply, ≥24h timelock, forced market removal, factory, `audits/` and `certora/` | https://github.com/morpho-org/metamorpho | 2026-08-04 |
| Steakhouse doc index (risk framework, monitoring, products, markets, documents) | https://steakhouse.financial/docs/llms.txt | 2026-08-04 |
| "$4 billion in stablecoin deposits across Ethereum, Base, and Solana"; doc sections | https://steakhouse.financial/docs | 2026-08-04 |
| Owner = Safe 5-of-5; Guardian = Aragon DAO with depositor-proportional veto; 7-day onboarding timelock vs 3-day protocol minimum; Vault DDQ ≥2 internal + 1 external | https://steakhouse.financial/docs/risk-management/monitoring/vault-setup-and-controls.md | 2026-08-04 |
| Allocation QC: ≥2 risk-team members; six risk vectors; second-mover posture; minimum target borrow rates | https://steakhouse.financial/docs/risk-management/monitoring/allocation-process.md | 2026-08-04 |
| Product lines: Prime (blue-chip list, 7-day timelock), High Yield (~10% fee, 3-day timelock), Turbo (Vaults v2 + adapter registry) | https://steakhouse.financial/docs/products/vault-products/current.md | 2026-08-04 |
| Vault principles: onchain NAV accounting, automated rule-based strategy, strict noncustodiality; platforms Morpho and Kamino | https://steakhouse.financial/docs/products/stablecoin-products/vaults.md | 2026-08-04 |
| "NOT A BROKER … NO FIDUCIARY RELATIONSHIP OR OBLIGATION TO YOU"; $1,000 liability cap; no custody; Cayman arbitration; class-action waiver | https://steakhouse.financial/docs/documents/disclaimers/vaults.md | 2026-08-04 |
| Operating entity Steakhouse Financial Ltd (Cayman); Cayman governing law | https://steakhouse.financial/docs/documents/general/tcs.md | 2026-08-04 |
| Steakhouse as an original Morpho curator; largest stablecoin risk curator on Morpho | https://morpho.org/stories/steakhouse | 2026-08-04 |
| STEAKUSDC vault address | https://app.morpho.org/ethereum/vault/0xBEEF01735c132Ada46AA9aA4c54623cAA92A64CB/steakhouse-usdc | 2026-08-04 |
| TVL $3,098,416,467; DefiLlama category "Risk Curators" | https://api.llama.fi/protocol/steakhouse-financial | 2026-08-04 |

### 5. WHAT LOOKS UNNAMEABLE

- **The delegated discretionary allocation mandate.** Corpus claim (c) **CONFIRMED.** A named firm
  selects the exposures, sets the per-market budget, rebalances at will, takes a cut of the yield,
  and owes the depositor nothing. `Sv` (servicing & determination discretion) is written for loan
  servicing and does not reach exposure *selection*; `Im` describes the substrate the mandate
  allocates across, not the mandate. Nothing names the delegation itself.
- **The supply cap as a risk budget.** A per-market ceiling on how much of the pooled capital may
  enter, defaulting to zero, raised only under timelock, lowered instantly. `Ct` (collateral-threshold
  test) is a per-position solvency test; a supply cap is a portfolio-construction limit on a
  *manager*. Different object, different subject.
- **Queue-ordered fill and drain.** `supplyQueue` and `withdrawQueue` are *ordered* lists that
  determine which market receives the next dollar and which is drained first. `Wq` names a
  withdrawal queue of *claimants waiting*; this is a queue of *venues in priority order*. The corpus
  records `Wq` for Steakhouse; the fit is partial at best.
- **Depositor-weighted veto over a manager's act.** Steakhouse's Aragon guardian gives each depositor
  veto weight proportional to deposit size, exercisable inside the timelock window. This is neither
  `Tg` (the delay), nor `Gp` (a designated pauser), nor `Ve` (vote-escrow, and contested anyway):
  it is *governance weight derived from an economic exposure inside a single vault*. No symbol.
- **Absence of liability as a designed feature.** The disclaimer is not boilerplate here; it is the
  economic structure. The manager takes a performance fee on upside and disclaims fiduciary duty on
  downside, with a $1,000 cap. There is no symbol for the absence of recourse, and the vocabulary
  has no way to distinguish a mandate with recourse from one without — which is the single most
  important fact about the instrument.
- **Fee-as-share-dilution.** Fees are minted as new shares to a recipient address, so the fee is paid
  by dilution of every other holder rather than by a transfer. `Fd` (surplus & fee distribution)
  names the distribution, not the dilution mechanism, and dilution has a different failure mode.
- **A published, versioned risk methodology as the actual governing object.** Layer 1/2/3 ratings,
  pillars, LLTV and credit-enhancement criteria. The allocation is a *function of a document*. Same
  shape as the prediction-market rulebook problem, in a different sector — and worth noting that the
  two halves of this category share it.
- **A curator layer that is a client of a market rather than a market.** Confirmed as corpus states;
  no symbol for the client relation.

### 6. DELTA

1. **"No on-chain recourse" is too strong.** The corpus residue says depositors "bear losses from the
   curator's choices with no on-chain recourse and no fiduciary encoding." The second half is right
   and quotable. The first half is wrong: Steakhouse runs an **Aragon DAO guardian in which "vault
   users become vault guardians proportionally to the size of their deposit,"** with veto power over
   critical curator actions, behind a **7-day** onboarding timelock explicitly sized "to provide
   depositors time to withdraw or exercise veto rights before capital deployment." That is on-chain
   recourse — ex-ante and preventive, not compensatory. The distinction between *preventive* and
   *compensatory* recourse is the sharper residue.
   Source: https://steakhouse.financial/docs/risk-management/monitoring/vault-setup-and-controls.md.
2. **The substrate is broader than "Morpho/Euler."** The corpus residue names Morpho and Euler.
   Steakhouse's documented platforms are **Morpho (V1 and Vaults V2) and Kamino (Solana)**, plus a
   Coinbase DeFi Lend distribution channel. I found no Steakhouse documentation naming Euler.
   Source: https://steakhouse.financial/docs/products/stablecoin-products/vaults.md.
3. **The corpus's `Fd` marker ("performance and management fees are taken on-chain") should record
   *how*.** Fees are taken by **minting new vault shares** to the fee recipients — dilution, not
   transfer — and on Morpho V1 the `Guardian` explicitly **cannot revoke a fee change**, while on V2
   fee changes became timelocked. Source: https://docs.morpho.org/curate/concepts/fee/ ;
   https://docs.morpho.org/curate/concepts/roles/.
4. **Self-reported AUM exceeds the aggregator by ~30%.** Steakhouse's own docs state "$4 billion in
   stablecoin deposits across Ethereum, Base, and Solana"; `api.llama.fi/protocol/steakhouse-financial`
   returns **$3,098,416,467** on the same day. The corpus's $3.08B matches DefiLlama. The gap is
   plausibly Solana/Kamino and Coinbase-routed deposits attributed elsewhere, but it is unreconciled.
   Mark: the true AUM is UNKNOWN between $3.10B and $4.0B depending on perimeter.
5. **The category-level TVL figures in `laneSource` do not reproduce.** Summing per-protocol TVL over
   `api.llama.fi/v2/protocols` by DefiLlama category on 2026-08-04 gives **Risk Curators =
   $5,937,031,671 (rank 13 of all categories, n=24)** and **Onchain Capital Allocator =
   $12,037,015,764 (rank 9, n=34)**. The corpus states Risk Curators $8.76B at #9 and Onchain Capital
   Allocator $7.74B at #12 — i.e. the two categories' magnitudes and ranks are effectively swapped
   relative to my recomputation. **Caveat:** DefiLlama's own category pages may aggregate parents
   rather than children, so this may be a methodology difference rather than a factual conflict; but
   the corpus figures are not reproducible from the protocols endpoint and should not be carried
   into the paper as computed numbers without re-derivation. The corpus's qualitative point (the
   combined $16.5–18B of curator + allocator TVL has zero vocabulary coverage) survives either way.
   Source: `https://api.llama.fi/v2/protocols`, grouped and summed 2026-08-04.
6. **The corpus's `Ct` entry ("inherited from the underlying markets, not computed by the vault") is
   confirmed and can be tightened:** the vault's own risk instrument is the **supply cap**, which is
   a different object from a health factor and is not `Ct`.

---

## Grove Finance (Onchain Capital Allocator)

### 1. WHAT IT DOES

Grove is two things wearing one name, and conflating them is the main risk for a later lane.
(i) **The allocator.** Sky (formerly MakerDAO) approves a mandate; Grove draws USDS against a Sky
allocation vault and deploys it into credit — most visibly the tokenised **Janus Henderson Anemoy
AAA CLO Strategy (JAAA)** issued via Centrifuge, at an initially approved size of $1 billion, and
subsequently JTRSY, plus on-chain venues (Aave V3, Morpho, Curve, Uniswap V3, Ethena, Pendle) across
Ethereum, Avalanche and Plume. The capital is Sky's, the discretion is Grove's, and the approvals
run through Sky governance ("Proposals are discussed and voted on through the Atlas Edit weekly
cycle"), so the *depositor* in the economically meaningful sense is a DAO, not a retail user.
(ii) **The retail surface.** A user supplies USDS or USDC to **Grove Savings** and receives
**sUSDS**, an ERC-4626 share whose exchange rate "updates according to the Sky Savings Rate, a
parameter set by Sky governance," with no lock-ups — plus **Grove Points**, which are
"non-transferable," have "no monetary value," and carry no claims or entitlements. That user is
**not** buying Grove's credit book; they are buying the Sky Savings Rate through Grove's front end.
(iii) A third product, **Grove Basin** (launched 2026-05-14), sells *other people's* problem: up to
$1 billion of committed daily liquidity so that eligible holders of tokenised funds (BlackRock's
BUIDL, Janus Henderson's JTRSY) can exit into stablecoins immediately instead of waiting the
customary two to three business days. Recourse: for the Sky-sourced capital, recourse is Sky
governance and the Freezer role; for a Grove Savings user, recourse is redeeming sUSDS; for Basin
counterparties, Basin explicitly "does not purchase or take ownership of underlying assets."

### 2. DESIGN

**The allocator's on-chain architecture** (a fork of Spark's):

- **`ALMProxy`** — "a minimal, stateless contract that holds custody of all funds," executing
  instructions from authorised controllers via `doCall`, `doCallWithValue` and `doDelegateCall`.
  Funds never leave it.
- **`MainnetController`** (Ethereum) and **`ForeignController`** (spoke chains) — business logic:
  validate the operation, enforce rate limits, route the call to `ALMProxy`. Only `RELAYER_ROLE`
  may invoke fund-moving functions.
- **`RateLimits`** — the risk control. Configurable, time-based limits on *every* controller
  operation, refilling linearly:
  `currentRateLimit = min(slope × (block.timestamp − lastUpdated) + lastAmount, maxAmount)`,
  keyed by composite `bytes32` keys for per-asset, per-destination or per-domain constraints.
- **Roles:** `RELAYER_ROLE` (an off-chain relayer operated by the ALM Planner submits the
  transactions), `FREEZER_ROLE` (can revoke `RELAYER_ROLE` and thereby halt all automated
  operations), `CONTROLLER`.

**Capital entry.** USDS mint/burn against Sky's allocation vault; DAI↔USDS and USDS↔USDC conversion
through the mainnet PSM. So the "deposit" is a governance-authorised credit line, not a user
transfer.

**Allocation targets.** ERC-4626 vaults and **ERC-7540 async vaults**, Centrifuge V3 RWA vaults,
Aave V3, Curve and Uniswap V3, Ethena (USDe/sUSDe), Pendle principal-token redemption, and
cross-chain bridging via CCTP and LayerZero. The ERC-7540 async-vault integration is the technically
important one: it is the standard for a vault whose deposits and redemptions *do not settle
synchronously*, which is precisely the off-chain-fund shape.

**Governance.** Grove proposes; **Sky** approves through the Atlas Edit weekly cycle, after a public
forum round in which "Grove addresses voter questions and remarks"; "only approved strategies move
to onchain deployment." The GROVE token is deployed with the Sky Endgame Toolkit `SDAO` contract
(ERC-20 + EIP-2612 permit + role-based admin), 10,000,000,000 minted at genesis, split Sky Ecosystem
70% / Grove team and contributors 25% / Grove Foundation 5%, distributed over ten years, with
2,100,000,000 (21%) still to be assigned "through future Sky governance decisions." Holders stake
GROVE, mint **stGROVE**, and vote directly or by delegate. But the token contract "has only
`MCD_PAUSE_PROXY` as its authorized admin, meaning only Sky governance can authorize administrative
actions on the token contract" — GROVE governance is *nested inside* Sky governance, and I found no
evidence that GROVE holders can veto an allocation.

**Grove Basin.** Non-custodial infrastructure giving eligible tokenholders instant onchain stablecoin
liquidity during an issuer's existing redemption workflow. Its control plane is an OpenZeppelin
`TimelockController` with a three-party split: the **issuer proposes** an administrative change,
**Grove Governance executes** it after a mandatory delay, and a **security multisig can cancel** the
proposal. Fee accrual happens on-chain and is immediately claimable by authorised issuers — "the
only function exempt from timelock delays." Basin "does not purchase or take ownership of underlying
assets," and its "instant" liquidity does not "imply any change to the redemption procedures,
settlement cycles, transfer restrictions" of the underlying fund: the fund's own T+2/T+3 workflow
continues unchanged behind the scenes. Launch partners: BlackRock and Janus Henderson (asset
managers), Securitize and Centrifuge (tokenisation), Anchorage Digital, Galaxy Digital and FalconX
(institutional access).

**Deployed contracts (Ethereum mainnet).**
`ALMProxy 0x491EDFB0B8b608044e227225C715981a30F3A44E`;
`MainnetController 0xfd9dEA9a8D5B955649579Af482DB7198A392A9F5`;
`RateLimits 0x5F5cfCB8a463868E37Ab27B5eFF3ba02112dF19a`;
`GROVE token 0xB30FE1Cf884B48a22a50D22a9282004F2c5E9406` (proxy
`0x1369f7b2b38c76B6478c0f0E66D94923421891Ba`);
`USDS 0xdC035D45d973E3EC169d2276DDab16f1e407384F`;
`sUSDS 0xa3931d71877C0E7a3148CB7Eb4463524FEc27fbD`;
`GROVE_PSM_VARIANT_1_ACTIONS 0x5c40dc1ccaa8ce64133d157ab838fa0c0f0d946f`.

**Fee flow.** UNKNOWN at the protocol level — Grove's docs describe Basin fee accrual to issuers but
I found no published schedule for what Grove earns on the Sky mandate. Do not guess.

### 3. REPO

- **`grove-labs/grove-alm-controller`** — "Onchain components for the Grove Liquidity Layer (GLL)."
  **AGPL-3.0** ("modifications to the code must be made available under the same license"). Solidity,
  Foundry-based CI. **169 commits on the `dev` branch** (2 stars, 5 forks). Contracts: `ALMProxy`,
  `MainnetController`, `ForeignController`, `RateLimits`. It is an explicit **fork of
  `sparkdotfi/spark-alm-controller`**; the first ChainSecurity audit scoped exactly "functionality
  added since Spark ALM Controller v1.5.0, in particular the CentrifugeV3 integration."
  Directories include an `audits/` folder and `.gitmodules` pointing at the upstream libraries.
- **Audits.** ChainSecurity (two engagements — the second found an ineffective `maxSlippage` check
  in `UniswapV3Lib`, governance tick bounds not revalidated when adding liquidity to an existing
  position, and a pool/tokenId mismatch allowing incorrect rate-limit accounting; all reported
  issues resolved after the intermediate report), plus Spearbit, Certora and a Cantina engagement.
- **Deployed vs repo.** Grove publishes canonical mainnet addresses in its docs and states that a
  **Grove Address Registry on GitHub** is the authoritative source, with additional chain
  deployments tracked in the protocol changelog. I did not bytecode-verify; treat the match as
  self-declared. Mark: UNKNOWN at the level of on-chain verification.
- **Off-chain mandate — say so explicitly.** The economically decisive object is not in any
  repository: it is a Sky governance approval authorising Grove to deploy a stated amount into a
  stated strategy. Grove Basin's contracts are likewise not in `grove-alm-controller` as far as I
  could establish (mark UNKNOWN), and the JAAA/JTRSY funds themselves are Cayman/Luxembourg fund
  vehicles whose registers of record are off-chain. What is verifiable on-chain: the ALMProxy's
  balances and calls, the rate-limit configuration, the role holders, and the token contract's
  admin.

### 4. EVIDENCE

| Claim | Source | Accessed |
|---|---|---|
| ALMProxy/MainnetController/ForeignController/RateLimits, `doCall`/`doCallWithValue`/`doDelegateCall`, rate-limit refill formula, RELAYER/FREEZER roles, USDS mint/burn + PSM entry, integration list (ERC-4626, ERC-7540, Centrifuge, Aave V3, Curve, Uniswap V3, Ethena, Pendle, CCTP, LayerZero) | https://docs.grove.finance/grove-allocator | 2026-08-04 |
| Canonical mainnet addresses | https://docs.grove.finance/deployed-contracts | 2026-08-04 |
| Repo: AGPL-3.0, fork of spark-alm-controller, contracts, 169 commits on `dev`, audits folder | https://github.com/grove-labs/grove-alm-controller | 2026-08-04 |
| ChainSecurity audits (Centrifuge V3 scope; UniswapV3Lib maxSlippage, tick bounds, pool/tokenId rate-limit findings, all resolved) | https://www.chainsecurity.com/security-audit/grove-alm-controller ; https://www.chainsecurity.com/security-audit/grove-alm-controller-2 | 2026-08-04 |
| Grove Savings: supply USDS/USDC → sUSDS at the **Sky Savings Rate**, ERC-4626, no lock-ups; Grove Points non-transferable, no monetary value | https://docs.grove.finance/grove-app ; https://docs.grove.finance/faqs | 2026-08-04 |
| GROVE token: SDAO contract, 10B genesis supply, 70/25/5 split, 10-year distribution, 21% undetermined, stGROVE staking/voting, `MCD_PAUSE_PROXY` sole admin | https://docs.grove.finance/grove-token | 2026-08-04 |
| Sky approval via Atlas Edit weekly cycle; only approved strategies deploy; managers Janus Henderson, Apollo, BlackRock; tokenisers Centrifuge, Securitize | https://www.grove.finance/blog/inside-grove-onchain-allocation-framework | 2026-08-04 |
| $1B Sky allocation into JAAA (Janus Henderson Anemoy AAA CLO Strategy) via Centrifuge; Grove incubated by Steakhouse Financial | https://www.businesswire.com/news/home/20250624393365/en/Grove-Announces-Launch-of-Institutional-Grade-Credit-Infrastructure-DeFi-Protocol-with-$1-Billion-Allocation-to-Tokenized-Janus-Henderson-Anemoy-AAA-CLO-Strategy | 2026-08-04 |
| Avalanche deployment target up to $250M into JAAA and JTRSY on Centrifuge | https://centrifuge.io/blog/grove-avalanche-centrifuge-jaaa ; https://www.grove.finance/blog/grove-launches-on-avalanche-with-usd250-million-deployment-target | 2026-08-04 |
| Grove Basin launch 2026-05-14: up to $1B committed daily liquidity; BlackRock + Janus Henderson; Securitize + Centrifuge; Anchorage/Galaxy/FalconX | https://www.businesswire.com/news/home/20260514501285/en/Grove-Launches-Basin-with-up-to-$1-Billion-in-Daily-Liquidity-Enabling-Instant-Onchain-Stablecoin-Liquidity-for-Tokenized-Real-World-Assets | 2026-08-04 |
| Basin control plane: OpenZeppelin TimelockController, issuer proposes / Grove Governance executes / security multisig cancels; fee accrual exempt from timelock; "does not purchase or take ownership of underlying assets"; "instant" does not change redemption procedures or settlement cycles | https://docs.grove.finance/grove-basin | 2026-08-04 |
| Homepage: $2.80B TVL, 16 active allocations, product set (Basin, Allocator, Financing, Savings) | https://grove.finance/ | 2026-08-04 |
| TVL $2,429,264,164; DefiLlama category "Onchain Capital Allocator" | https://api.llama.fi/protocol/grove-finance | 2026-08-04 |

### 5. WHAT LOOKS UNNAMEABLE

- **The mandate: an allocation policy approved by one DAO governing capital sourced from that DAO
  and exercised by another organisation.** Corpus claim (c) **CONFIRMED**, and Grove is the harder
  case than Steakhouse because the discretion and the capital sit in different governance domains.
  Nothing names the authorisation, its size limit, its revocability, or the standing of the
  authorising body.
- **Nested governance.** GROVE holders stake and vote, but the token's only admin is Sky's
  `MCD_PAUSE_PROXY`. A governance system whose root of authority is another governance system is a
  distinct object. `Tg` names a delay; nothing names *subordination*.
- **The rate limit.** `RateLimits` — a linearly-refilling per-key throughput cap on every controller
  operation — is the single most load-bearing risk control in the Grove Allocator, and it is neither
  a delay (`Tg`), nor a pause (`Gp`), nor an epoch (`Ep`), nor a cap on a position. It is a *flow*
  constraint on a privileged actor. The vocabulary has no flow limiter at all, and this is a general
  gap: Spark, Grove and several bridges all use one.
- **The relayer/freezer split.** An off-chain planner submits transactions under `RELAYER_ROLE`; a
  `FREEZER_ROLE` can revoke the relayer and halt everything. `Au` (delegated execution scope) is the
  nearest and is written for user-configured session policy, not for an institution's operations
  bot. `Gp` names a pause of the system; this is a *revocation of an actor*.
- **Grove Basin: a committed liquidity facility against a slow off-chain claim.** *Entirely absent
  from the corpus.* Basin commits up to $1B/day to give a third party immediate stablecoins against
  a fund position whose real redemption cycle is unchanged and still takes days. That is maturity
  transformation sold as a service to counterparties who are not the protocol's depositors, priced
  and fee-bearing, with the risk warehoused by the facility. `Wq` names a queue of claimants;
  `Fl` names atomic borrow-and-repay inside one settlement scope; neither is this. This is the
  single most interesting unnameable object I found in the whole category.
- **Basin's three-party timelock.** Issuer proposes, protocol governance executes after a delay,
  security multisig cancels — with fee claims explicitly carved out of the delay. `Tg` names a
  timelock; it does not name a *proposal right held by an external commercial counterparty*.
- **Async redemption as a first-class primitive (ERC-7540).** The vocabulary assumes settlement is
  synchronous or queued; an async vault is a *request/claim* protocol with an off-chain fulfilment
  step. No symbol.
- **Chain-to-bank transfer.** Confirmed as corpus states: `Xf` describes cross-domain asset
  movement between chains; the economically important hop is from a chain into a fund
  administrator's books, and no symbol reaches it.
- **Non-transferable, non-claim points.** Grove Points accrue proportionally, are non-transferable,
  have no monetary value and carry no entitlement. `Em` (protocol-funded emissions) presupposes the
  emitted thing has value. A pure record-of-contribution with no claim is not `Em`.
- **The CLO tranche behind the NAV.** Confirmed as corpus states: `Tr` would name the waterfall if
  the waterfall were visible; from the allocator's position JAAA is a single opaque NAV.

### 6. DELTA

1. **Grove Basin did not exist when the corpus record was written, and it directly addresses the
   corpus's own residue item.** The corpus lists as residue "the redemption LAG between an on-chain
   instant-liquidity promise and an off-chain fund's monthly redemption window — a structural
   maturity transformation." Basin (launched **2026-05-14**) is a purpose-built facility of up to
   $1B/day that *sells* exactly that transformation to third parties, while its own documentation
   insists the underlying fund's "redemption procedures, settlement cycles, transfer restrictions"
   are unchanged. The corpus's diagnosis is right and its residue list is now missing the mechanism
   built to exploit it. Sources: businesswire 2026-05-14 ; https://docs.grove.finance/grove-basin.
2. **"What a depositor gets" is not what the corpus implies.** A Grove Savings user receives
   **sUSDS at the Sky Savings Rate** plus non-transferable Grove Points — *not* exposure to Grove's
   credit allocations. Grove's $2.43B TVL is Sky-sourced allocated capital, not retail deposits.
   Any construction that treats Grove as a deposit-taking vault will be wrong.
   Source: https://docs.grove.finance/grove-app.
3. **The corpus's `Sh` (pro-rata share accounting) for Grove needs re-siting.** The only share token
   in sight is sUSDS, which is a share of the **Sky Savings Rate**, issued by Sky, not a share of
   Grove's book. Flag for Stage 2.
4. **Grove is not purely an off-chain-credit allocator.** The corpus says Grove "allocates it into
   OFF-CHAIN credit — most visibly a Janus Henderson CLO fund." The documented integration set also
   includes Aave V3, Morpho, Curve, Uniswap V3, Ethena (USDe/sUSDe) and Pendle, across Ethereum,
   Avalanche and Plume. The RWA leg is real but it is one of several.
   Source: https://docs.grove.finance/grove-allocator.
5. **Terminology has moved.** Grove's FAQ now describes it as "a credit infrastructure protocol that
   operates as a **Sky Prime Agent** within the Sky Ecosystem"; the June-2025 launch material and the
   Sky announcement called it a **Star**. Both terms are in circulation.
   Source: https://docs.grove.finance/faqs.
6. **The corpus's `At` marker ("the NAV of the off-chain allocation is a manager report, not a
   protocol-verifiable attestation") is confirmed and now has a mechanism to point at:** the
   ERC-7540 async-vault integration is precisely the interface across which an unverifiable NAV
   enters the on-chain accounting.
7. **The single most load-bearing on-chain control has no symbol in the corpus record.** Grove's
   element set is `[At, Aw, Gp, Sh, Tg, Xf]`. `RateLimits` — with an explicit refill formula and
   per-key granularity — is the actual risk control, and neither the corpus nor the vocabulary has
   anything for it. Add to residue.
8. **Self-reported TVL exceeds the aggregator.** grove.finance reports **$2.80B** TVL and 16 active
   allocations; `api.llama.fi/protocol/grove-finance` returns **$2,429,264,164** on the same day.
   The corpus's $2.43B matches DefiLlama. Perimeter difference unexplained; mark UNKNOWN.
9. **Incubation lineage is worth recording for the paper.** Grove was incubated by **Steakhouse
   Financial** — i.e. two of this category's five entries are the same firm's output, which is
   relevant to any claim that they represent independent instances of the delegated-mandate form.
   Source: businesswire 2025-06-24.

---

## Summary of the three corpus claims under test

| Claim | Verdict | Basis |
|---|---|---|
| (a) No element for **conditional-token split/merge**; `Py` splits along time, nothing splits along state | **CONFIRMED, and understated** | `splitPosition`/`mergePositions` enforce a disjoint, non-degenerate partition of the state space, are *recursive* via `parentCollectionId`, and are two of the three settlement modes of Polymarket's matching engine (`ctf-exchange-v2`). A vocabulary with no state-partition symbol cannot name the order matching either. |
| (b) No element for a **central counterparty**; `Sl`, `Bs`, `Ad` reconstruct the waterfall but not the institution | **CONFIRMED, and two further gaps found** | Kalshi Klear Rule 6.1(E)(1) novation; guaranty fund (`Bs`), VM gains haircutting (`Sl`), tear-ups (`Ad`) all map — but the **Company Contributions** (two capped tranches of operator first-loss) and **Assessments** (capped, refundable *callable capital* on surviving members) have no symbol. Separately, QC Clearing LLC is a CCP with **no** guaranty fund and **no** financial resource package at all, so the trio does not reconstruct every CCP — a fully-collateralised CCP is pure novation plus custody. |
| (c) The **delegated allocation mandate** has no symbol | **CONFIRMED for both allocators** | Steakhouse: named firm picks exposures and per-market caps for a performance fee with no fiduciary duty and a $1,000 liability cap. Grove: discretion and capital sit in *different governance domains*, with GROVE governance subordinate to Sky's `MCD_PAUSE_PROXY`. The gap is real; the corpus's claim that there is *no* on-chain recourse is the one part that needs correcting (Steakhouse's depositor-weighted Aragon veto). |

**Additional residue found in this lane and not in the corpus record:** exchange-tribunal outcome
determination with finality (Kalshi Rule 7.1, Polymarket US Rule 10.4); settlement to last traded
price; Source Agency substitution mid-contract; assessments/callable capital; Contract Segments
partitioning a mutualised default fund; a 1:1 reserve-backed collateral wrapper wrapped again
(pUSD → PMCT); Azuro **Cashout**; Azuro's entry-indexed LiquidityTree accounting (not `Sh`); a
depositor-weighted veto over a manager's act; fee-as-share-dilution; **rate limits as a flow
control**; async (ERC-7540) redemption; a three-party timelock in which an external commercial
counterparty holds the proposal right; and **Grove Basin** — a committed daily liquidity facility
that sells maturity transformation to non-depositors.
