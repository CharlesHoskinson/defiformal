# Corpus disagreement triage

Reconciled **29 disputed facets, 24 units, 32 label claims and 17 distinct labels** against raw A/B annotations and generated decisions. All 29 remain unaccepted. One has a source-grounded draft (Liquity V1 redemption); the other 28 have no relevant retained primary behavior evidence in the declared local catalog.

This is a read-only research queue. No remote requests, corpus edits, rule acceptance or changes to either Liquity package occurred. Proposed predicates come from the exact current design bytes recorded in the JSON. Raw agreement and a URL do not establish a label. Missing evidence does not establish refutation.

Input HEAD: `2b1957b8be01c7435bd5b1928c20e92e6c598be6`; final observed HEAD: `2b1957b8be01c7435bd5b1928c20e92e6c598be6`. All 57 protected underlying files and 30 bound inputs remained identical during this pass. 304 offline checks passed. These checks verify records and bytes, not protocol semantics.

Full exact paths, JSON pointers, A/B values and rationale, generated records, source locators, input hashes and rule predicates: [disagreement-triage.json](disagreement-triage.json), SHA-256 `9847a76b980849b0373d4767b2515c82c6d1c7e40214f2d3ccce044c8484cdd4`.

## Evidence already available

The Liquity V1 redemption draft reuses pinned TroveManager and BorrowerOperations bodies and retains a V1 redemption FAQ and LiquityBase body. Its 21 exact source spans and original retrieval records are linked in the JSON. The proposed supported disposition still needs independent review. Bootstrap, collateral-ratio, balance, fee, hint, minimum-debt and last-trove conditions qualify the claim. This source revision is not a deployment identity or historical-state proof.

The earlier Liquity liquidation challenge is separate from the 29 disagreements and remains separately proposed. Original V1/V2/Ondo naming excerpts are retained as naming context only; their old full HTTP bodies are not retained in that excerpt package. V2 and Ondo material does not support these other disputed product behaviors.

## Retrieval queue grouped by unit

Each entry preserves A-only and B-only label differences. Next actions below are questions to resolve using official, appropriately scoped source; they assert no protocol behavior and invent no retrieved URL. Multi-facet units should share a source packet while keeping label decisions separate.

### JustLend V1 — `unit:lane1:c1:p3`

**dispute-01 / mechanisms** — A-only: collateralization. Proposed rules: R-collateralization.
Pointers: A `/annotations/8/facets/mechanisms`; B `/annotations/8/facets/mechanisms`; generated `/adjudications/42` (files bound in JSON).

Retrieve official JustLend V1 lending contracts or versioned collateral documentation showing which pledged assets secure borrowing, the collateral check and release conditions. Resolve the version and source revision before importing fork behavior.

### Maple — `unit:lane1:c1:p4`

**dispute-02 / mechanisms** — A-only: allocation. Proposed rules: R-allocation.
Pointers: A `/annotations/9/facets/mechanisms`; B `/annotations/9/facets/mechanisms`; generated `/adjudications/47` (files bound in JSON).

Retrieve the scoped Maple pool/delegate documentation and contracts identifying authority to distribute investor capital among named borrowers or loans. Separate allocation from underwriting, custody and an underlying fund held by Maple.

### Lista CDP — `unit:lane1:c2:p3`

**dispute-03 / trust** — B-only: issuer, keeper. Proposed rules: R-issuer, R-keeper.
Pointers: A `/annotations/14/facets/trust`; B `/annotations/14/facets/trust`; generated `/adjudications/74` (files bound in JSON).

Retrieve Lista CDP issuance permissions and liquidation/auction actor documentation for the same version: identify who can issue lisUSD and which external actor is relied on to initiate or maintain liquidation. Callable methods and gas rebates alone do not settle either role.

### Liquity V1 — `unit:lane1:c2:p4:v1`

**dispute-04 / mechanisms** — B-only: redemption. Proposed rules: R-redemption.
Pointers: A `/annotations/15/facets/mechanisms`; B `/annotations/15/facets/mechanisms`; generated `/adjudications/77` (files bound in JSON).

First independently review the retained V1 redemption package and its contract/FAQ qualifications. No additional retrieval is necessary for the proposed scoped source claim unless review identifies a missing premise; any historical deployment claim requires a separate address/revision/time binding.

### Lido — `unit:lane1:c3:p0`

**dispute-05 / trust** — B-only: curator. Proposed rules: R-curator.
Pointers: A `/annotations/18/facets/trust`; B `/annotations/18/facets/trust`; generated `/adjudications/94` (files bound in JSON).

Retrieve official Lido Staking Router/module role documentation and pinned selection/configuration code identifying who chooses validator operators or allocations. Keep curated, DVT and CSM module scopes distinct rather than attributing one module role to all Lido.

### Binance staked ETH (WBETH) — `unit:lane1:c3:p1`

**dispute-06 / economic_functions** — A-only: offchain_claims. Proposed rules: R-offchain_claims.
Pointers: A `/annotations/19/facets/economic_functions`; B `/annotations/19/facets/economic_functions`; generated `/adjudications/95` (files bound in JSON).

Retrieve versioned official WBETH holder and redemption terms identifying the promised performance/assets, account restrictions and whether settlement or enforcement occurs outside the on-chain machine. Exchange operation alone does not prove the direct offchain-claims service.

### Babylon Protocol — `unit:lane1:c3:p4`

**dispute-07 / instruments** — B-only: spot_asset. Proposed rules: R-spot_asset.
Pointers: A `/annotations/22/facets/instruments`; B `/annotations/22/facets/instruments`; generated `/adjudications/111` (files bound in JSON).

Retrieve official Babylon BTC staking instrument and ownership/control documentation plus the relevant script specification. Determine whether the exposed product instrument itself transfers current asset control, or BTC is only its underlying; do not invent a transferable receipt.

### Hyperliquid — `unit:lane2:c0:p0`

**dispute-08 / mechanisms** — A-only: allocation. Proposed rules: R-allocation.
Pointers: A `/annotations/23/facets/mechanisms`; B `/annotations/23/facets/mechanisms`; generated `/adjudications/117` (files bound in JSON).

Retrieve official Hyperliquid HLP and leader-vault mandates, capital-distribution rules and operator permissions within the bundled venue context. Identify destinations and authority instead of inferring allocation from margin balances or chain staking.

### ApeX Protocol (ApeX Omni) — `unit:lane2:c0:p1`

**dispute-09 / trust** — A-only: attester. Proposed rules: R-attester.
Pointers: A `/annotations/24/facets/trust`; B `/annotations/24/facets/trust`; generated `/adjudications/124` (files bound in JSON).

Retrieve official ApeX Omni data-availability committee specification and the pinned settlement verifier interfaces. Identify an actual attestation accepted for a financial transition, its signers and acceptance conditions; distinguish data availability, validity proofs and ordinary authorization.

### Lighter — `unit:lane2:c0:p3`

**dispute-10 / execution** — A-only: appchain. Proposed rules: R-appchain.
Pointers: A `/annotations/26/facets/execution`; B `/annotations/26/facets/execution`; generated `/adjudications/133` (files bound in JSON).

Retrieve official Lighter architecture and pinned rollup settlement documentation stating the dedicated execution domain and settlement role. Apply the proposed appchain predicate explicitly to an application-specific rollup; do not infer it from the venue name.

### edgeX — `unit:lane2:c0:p4`

**dispute-11 / trust** — A-only: attester. Proposed rules: R-attester.
Pointers: A `/annotations/27/facets/trust`; B `/annotations/27/facets/trust`; generated `/adjudications/139` (files bound in JSON).

Retrieve official edgeX deployment/version architecture and the applicable StarkEx data-availability certificate acceptance interface. Identify the committee role and the financial transition it gates, without inheriting a generic StarkEx configuration.

### Jupiter Perpetual Exchange — `unit:lane2:c0:p5`

**dispute-12 / economic_functions** — A-only: asset_management. Proposed rules: R-asset_management.
Pointers: A `/annotations/28/facets/economic_functions`; B `/annotations/28/facets/economic_functions`; generated `/adjudications/140` (files bound in JSON).

Retrieve official Jupiter Perpetual Exchange/JLP product rights and management rules identifying the direct service to pool depositors, the pool assets and management authority. Distinguish direct capital management from incidental exchange inventory.

**dispute-13 / mechanisms** — A-only: allocation, redemption. Proposed rules: R-allocation, R-redemption.
Pointers: A `/annotations/28/facets/mechanisms`; B `/annotations/28/facets/mechanisms`; generated `/adjudications/142` (files bound in JSON).

In the same Jupiter/JLP evidence packet, retrieve target-weight capital distribution rules and holder mint/redeem settlement paths, including fees and conditions. Evaluate allocation and redemption separately; one supported label does not resolve the other.

### Pendle — `unit:lane2:c1:p0`

**dispute-14 / instruments** — A-only: spot_asset. Proposed rules: R-spot_asset.
Pointers: A `/annotations/30/facets/instruments`; B `/annotations/30/facets/instruments`; generated `/adjudications/151` (files bound in JSON).

Retrieve official Pendle instrument definitions and pinned token/pool interfaces distinguishing SY, PT, YT and any directly traded spot instrument. Establish ownership/control rights of the scoped instrument rather than importing the spot underlying of a yield claim.

### Spark Savings (sUSDS / Sky Savings Rate) — `unit:lane2:c1:p1`

**dispute-15 / execution** — A-only: async_cross_domain. Proposed rules: R-async_cross_domain.
Pointers: A `/annotations/31/facets/execution`; B `/annotations/31/facets/execution`; generated `/adjudications/158` (files bound in JSON).

Retrieve official Spark Savings sUSDS cross-chain workflow and bridge/relay documentation for identified domains, tracing initiating state change, delivery/finality and destination change. Eight-chain availability or claim sameness alone does not establish causal cross-domain execution.

### Huma Finance V2 — `unit:lane2:c1:p4`

**dispute-16 / economic_functions** — A-only: asset_management. Proposed rules: R-asset_management.
Pointers: A `/annotations/34/facets/economic_functions`; B `/annotations/34/facets/economic_functions`; generated `/adjudications/170` (files bound in JSON).

Retrieve official Huma V2 pool/tranche product documents and management authority for investor capital, with the product version identified. Determine whether direct capital management is supplied to holders rather than only an underlying receivables service.

**dispute-17 / mechanisms** — A-only: allocation. Proposed rules: R-allocation.
Pointers: A `/annotations/34/facets/mechanisms`; B `/annotations/34/facets/mechanisms`; generated `/adjudications/172` (files bound in JSON).

In the same Huma V2 packet, retrieve Evaluation Agent drawdown/selection permissions and capital-distribution rules identifying destinations and the actor or rule controlling allocation. Do not treat legal recourse or holding receivables as the allocation operation.

**dispute-18 / trust** — B-only: attester. Proposed rules: R-attester.
Pointers: A `/annotations/34/facets/trust`; B `/annotations/34/facets/trust`; generated `/adjudications/174` (files bound in JSON).

In the same Huma V2 packet, retrieve the implemented claim-attestation schema and acceptance code or authoritative role specification. Identify who asserts what and which transition consumes it; distinguish a proposed evidentiary need from an implemented attester.

### WBTC — `unit:lane2:c2:p0`

**dispute-19 / execution** — A-only: async_cross_domain. Proposed rules: R-async_cross_domain.
Pointers: A `/annotations/38/facets/execution`; B `/annotations/38/facets/execution`; generated `/adjudications/193` (files bound in JSON).

Retrieve official WBTC merchant mint/burn and BTC custody workflow for the selected version, tracing distinct domains and the delivery/finality boundary. Determine whether the rule includes the documented custodial handoff; do not require a cryptographic message if the proposed predicate does not.

**dispute-20 / trust** — A-only: legal_obligor. Proposed rules: R-legal_obligor.
Pointers: A `/annotations/38/facets/trust`; B `/annotations/38/facets/trust`; generated `/adjudications/194` (files bound in JSON).

In the same WBTC packet, retrieve official applicable holder/merchant agreements naming the entity, beneficiary and enforceable redemption/payment obligation. Distinguish merchant rights from ordinary holder rights and legal obligation from a custody label.

### Coinbase Bridge (cbBTC and other wrapped assets) — `unit:lane2:c2:p2`

**dispute-21 / mechanisms** — A-only: mint_burn. Proposed rules: R-mint_burn.
Pointers: A `/annotations/40/facets/mechanisms`; B `/annotations/40/facets/mechanisms`; generated `/adjudications/202` (files bound in JSON).

First scope the bundled Coinbase Bridge row to cbBTC or another explicitly identified wrapped product without changing the corpus. Retrieve that product’s official issuance/destruction contracts and authorized roles; transfers out of custody are not mint/burn evidence.

**dispute-22 / execution** — A-only: async_cross_domain, offchain_legal_settlement. Proposed rules: R-async_cross_domain, R-offchain_legal_settlement.
Pointers: A `/annotations/40/facets/execution`; B `/annotations/40/facets/execution`; generated `/adjudications/203` (files bound in JSON).

For that same explicitly scoped Coinbase wrapped product, retrieve a causal source/destination settlement workflow and applicable legal terms identifying how the obligation is discharged or enforced. Evaluate async_cross_domain and offchain_legal_settlement separately; an account or custody promise alone settles neither.

### Binance Bitcoin (BTCB) — `unit:lane2:c2:p4`

**dispute-23 / execution** — A-only: async_cross_domain. Proposed rules: R-async_cross_domain.
Pointers: A `/annotations/42/facets/execution`; B `/annotations/42/facets/execution`; generated `/adjudications/213` (files bound in JSON).

Retrieve official BTCB minting/redemption and exchange-withdrawal workflow linking BTC, the exchange ledger and BNB Chain with stated delivery/finality conditions. Distinguish an actual multi-domain causal process from branding or separate token availability.

### CoW Swap — `unit:lane2:c3:p7`

**dispute-24 / mechanisms** — A-only: collateralization. Proposed rules: R-collateralization.
Pointers: A `/annotations/52/facets/mechanisms`; B `/annotations/52/facets/mechanisms`; generated `/adjudications/262` (files bound in JSON).

Retrieve official CoW solver bonding/slashing rules and relevant contracts identifying encumbered assets, secured settlement obligations and enforcement/release conditions. Test solver performance collateral directly, without requiring a credit position or mistaking user trade custody for collateral.

### Rysk V12 — `unit:lane3:c1:p1`

**dispute-25 / trust** — A-only: curator. Proposed rules: R-curator.
Pointers: A `/annotations/61/facets/trust`; B `/annotations/61/facets/trust`; generated `/adjudications/309` (files bound in JSON).

Retrieve official Rysk V12 strategy and permission documentation identifying who selects strike/tenor, counterparties or hedging policy for depositor capital. Distinguish a named trusted chooser from a fully specified automatic policy and passive operation.

### Tether USDT — `unit:lane3:c2:p0`

**dispute-26 / execution** — A-only: async_cross_domain. Proposed rules: R-async_cross_domain.
Pointers: A `/annotations/65/facets/execution`; B `/annotations/65/facets/execution`; generated `/adjudications/328` (files bound in JSON).

Retrieve official Tether chain-swap process and source/destination issuance rules for an identified version/time, establishing initiating burn/lock, operator authorization and completion/finality conditions. Multiple native issuances alone do not prove a causally linked workflow.

### Kalshi — `unit:lane3:c3:p0`

**dispute-27 / economic_functions** — B-only: exchange. Proposed rules: R-exchange.
Pointers: A `/annotations/70/facets/economic_functions`; B `/annotations/70/facets/economic_functions`; generated `/adjudications/350` (files bound in JSON).

Retrieve official Kalshi trading and clearing rulebooks applicable to the scoped product/time, showing participant order matching and exchange of event contracts. Distinguish direct trading from initial claim issuance or event payout; deposit rails do not establish the execution model.

### Polymarket — `unit:lane3:c3:p1`

**dispute-28 / economic_functions** — B-only: exchange. Proposed rules: R-exchange.
Pointers: A `/annotations/71/facets/economic_functions`; B `/annotations/71/facets/economic_functions`; generated `/adjudications/355` (files bound in JSON).

Retrieve official Polymarket exchange documentation and pinned order-matching/settlement contract interfaces showing trades between participants or a pool. Keep trading distinct from conditional-token split/merge and event resolution, with the product/time scope explicit.

### Grove Finance (Onchain Capital Allocator) — `unit:lane3:c3:p4`

**dispute-29 / instruments** — B-only: fund_share. Proposed rules: R-fund_share.
Pointers: A `/annotations/74/facets/instruments`; B `/annotations/74/facets/instruments`; generated `/adjudications/371` (files bound in JSON).

Retrieve official Grove product/investor rights documents identifying the exact instrument exposed to its own users and any proportional managed-pool interest. Separate a Grove depositor claim from the underlying CLO fund share held by the allocator; record unresolved instrument scope if no direct share is established.

## Reconciliation limits

The 29-facet total is preserved even where Lista trust, Jupiter mechanisms and Coinbase execution each contain two disputed labels. Grove fund_share is B-only, as measured from raw bytes. Generated retained intersections are preserved rather than treated as independently verified truths.

The capture catalog inspection is bounded to the two existing Liquity packages and normalized primary excerpts. For the other units, identity/time applicability and positive source predicates remain missing. In particular, custodial cross-domain workflows must be judged against the proposed causal-transition predicate; absence of cryptographic messaging is not silently added as an exclusion. Likewise, solver performance collateral is not excluded merely because it does not secure a credit loan.

Author: GPT-6 through the stock Codex harness, also author of the two prior Liquity draft research packages. This triage is not their independent review.
