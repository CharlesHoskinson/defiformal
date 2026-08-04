# A Periodic Table of DeFi: An Element Set, Bonding Rules, and Failure Overlay

## TL;DR
- **A closed set of ~46 atomic mechanisms ("elements"), organized into 10 functional groups and 4 "periods" ordered by trust surface, can reconstruct essentially every deployed DeFi application as a molecular formula — but the chemistry metaphor earns its keep only for bonding rules and reflexivity, not for the periodic law itself, which does not hold.**
- **The single most valuable finding is the residue: roughly a third of catastrophic DeFi losses fall OUTSIDE the table entirely (key compromise, governance capture, off-chain fraud), which bounds how much any mechanism taxonomy can explain; the failures the table DOES explain cluster overwhelmingly on one bond — collateral priced by a market the protocol itself dominates (reflexivity).**
- **No prior taxonomy is a periodic table: Werner et al.'s SoK is the closest but stops at protocol-type classification with no bonding rules; ACTUS from TradFi already solved the "molecular" decomposition of cash-flow contracts into 32 Contract Types, and DeFi's genuinely novel elements are few — flash loans, atomic composability, AMM invariant pricing, and permissionless liquidation.**

## Key Findings

1. **The metaphor is ~40% load-bearing.** Element/molecule, valence, catalyst, and toxic-compound map well. Atomic number, period law, and "discovered vs designed" break badly. DeFi has three distinct bond types — interface (ABI/call compatibility), economic (incentive alignment), and trust (shared assumptions) — that chemistry conflates into one. Treating them as one is the most common analytical error.

2. **Atomicity test, amended.** The four seed criteria (functional irreducibility, independent recurrence in ≥3 unrelated teams, substitutability within a group, distinct failure signature) misclassify five borderline cases. I add a fifth criterion (**state-persistence independence**) and relax recurrence to "≥3 unrelated teams OR ≥1 cross-execution-model reimplementation" to handle non-EVM cases.

3. **Ordering by trust surface beats the alternatives.** I evaluated dependency depth, trust surface, and first-deployment date as the "period" axis. Trust surface wins because it predicts failure and composition constraints; dependency depth is circular (it depends on the molecule, not the element); date is a decorative fact that predicts nothing.

4. **The count is ~46 elements, with 8 flagged as uncertain.** This is defensibly neither over-split nor under-split: constant-product vs stableswap vs concentrated liquidity are one element (spot-AMM-invariant) with isotopes, not three elements, because they are substitutable; but push vs pull vs optimistic oracle are three elements because each introduces a distinct failure signature and distinct trust assumption.

5. **Required bonds are real and enumerable.** Any leverage-creating element requires both a truth element and a solvency element; any element that mints a transferable claim requires an accounting element; any liquidation element requires a truth element. These are not stylistic — every violation in the corpus produced insolvency.

6. **Reflexivity is the master predictor.** Terra/UST, Mango, and a dozen smaller failures share one structure: an element's output feeds its own price input. This is the "toxic compound" of DeFi and deserves its own overlay.

## Details

### Phase 0 — Is the chemistry metaphor earned?

The brief demands the metaphor be earned, not assumed. Verdict on each correspondence:

| Chemistry | Verdict | Reasoning |
|---|---|---|
| Element = irreducible primitive | **HOLDS** | A functional-irreducibility test produces a stable, finite set. |
| Atomic number = ordering principle | **DISCARD** | There is no natural scalar that both orders elements and predicts properties the way proton count does. Any ordering (I use trust surface) is a useful sort key, not a periodic law. |
| Group = substitutable family | **HOLDS** | Substitutability is empirically testable (swap constant-product for stableswap; it's still a spot AMM). |
| Period = ??? | **REPLACE** with trust surface | See below; the periodic *law* (properties recur periodically) does NOT hold. |
| Valence = required counterparts | **HOLDS, RENAMED** | Better modeled as typed required-bonds than as a single integer valence. |
| Molecule = deployed protocol | **HOLDS** | Core of the whole exercise. |
| Isotope = parameter variant | **HOLDS** | Distinguishes Uniswap v2 vs SushiSwap (isotopes) from v2 vs v3 (arguably new element). |
| Catalyst = flash loan | **HOLDS STRONGLY** | Flash loans enable reactions (arbitrage, liquidation, self-liquidation) without being consumed — the cleanest analogy in the set. |
| Alloy/mixture = aggregators | **HOLDS** | Distinguishes true compounds (bonded) from mixtures (co-located, separable). |
| Radioactivity/half-life = decay | **HOLDS** | Algorithmic-supply-adjustment and rebasing are measurably unstable. |
| Noble gas = non-composable | **PARTIALLY** | Near-noble elements exist (privacy-shielded balances resist composition) but true zero-valence is rare. |
| Toxic compound = fatal combos | **HOLDS STRONGLY** | The failure overlay is built on this. |

**Where the metaphor breaks (documented explicitly):**
- **Elements are designed, not discovered.** A team can ship a genuinely new primitive next week; the table is open, not closed-by-nature. This is the single biggest disanalogy.
- **Bonds are three different things.** Chemical bonds are one physical phenomenon. DeFi "bonds" are (a) *interface* compatibility (does contract A's ABI accept contract B's token?), (b) *economic* compatibility (do the incentives clear?), and (c) *trust* compatibility (do they share an oracle/governance/finality assumption?). A molecule can be interface-valid and economically toxic — this is exactly what most exploits are.
- **No conservation law.** Chemistry conserves mass; DeFi molecules can mint and burn claims, and reflexive molecules can create apparent value that evaporates.
- **Forks break isotope logic.** A code fork with identical parameters is neither a new element nor a true isotope; it is a *replica*, a category chemistry lacks.

### Phase 1 — Prior art sweep

**Werner et al., "SoK: Decentralized Finance (DeFi)" (Imperial College/Cornell, AFT 2022, arXiv 2101.08778).** The canonical academic systematization. It delineates DeFi along three axes: primitives, operational protocol types, and security (splitting technical from economic security). **What it got right:** it identifies a primitive layer and insists economic security is under-theorized. **Where it stopped:** it classifies protocols by *operation type* (six types), not by decomposition into a closed element set, and it has no bonding rules. It is a taxonomy of protocols, not of mechanisms.

**Xu, Paruch, Cousaert, Feng, "SoK: Decentralized Exchanges (DEX) with AMM Protocols" (ACM Computing Surveys, arXiv 2103.12732).** Establishes a general AMM framework with a state-space representation and conservation functions, comparing constant-product, constant-sum, and stableswap. **Right:** the "conservation function" abstraction is exactly the isotope logic I use for the spot-AMM element. **Stopped:** confined to exchange; no cross-family bonding.

**Automated Market Makers in Cryptoeconomic Systems: A Taxonomy and Archetypes (ACM Computing Surveys 2024, doi 10.1145/3769669).** Built from 122 publications and 110 real AMMs; proposes three AMM archetypes. Useful for element/isotope boundaries within pricing, nothing beyond.

**"Money legos" / "protocol sink" framings.** The money-legos metaphor (widely used since ~2019-2020) captures composability but is explicitly *open-ended* — "each time a new protocol is created, a new money lego is born" — which is precisely why it never produced a closed element set. It treats every protocol as a lego, conflating molecules with atoms. This is the anti-pattern the brief warns against.

**TradFi financial ontologies:**
- **ACTUS (Algorithmic Contract Types Unified Standards).** The most important prior art from outside crypto, and the closest thing to a pre-existing periodic table for cash-flow finance. Per the ACTUS Financial Research Foundation (actusfrf.org) and Wikipedia, ACTUS "break[s] down the diversity in financial instruments into a manageable number of cash flow patterns – so called Contract Types (CT)": currently **32 distinct Contract Types** that, "with limited exceptions, cover every type of contract used by all but the largest banks," ranging from Principal at Maturity (PAM) and Annuity (ANN) to futures (FUTUR), options (OPTNS), and credit default swaps (CDSWP). Each CT is defined algorithmically (attributes, variables, contract events, payoff function, state-transition function). ACTUS is used by the US Treasury's Office of Financial Research and maps to FIBO. **This IS a periodic-table-like project for cash-flow finance, and it predates DeFi's version of the problem.** **What DeFi adds that has no ACTUS antecedent:** (1) atomic composability / flash loans (a loan that exists only within one transaction); (2) permissionless liquidation as a public good; (3) AMM invariant pricing (price as a deterministic function of reserves rather than a matched trade); (4) reflexive endogenous collateral. Everything else — lending, tranching, options, swaps, principal/yield splitting (bond stripping) — has a clean ACTUS/TradFi antecedent. Pendle's PT/YT split is literally coupon stripping.
- **FIBO** (Financial Industry Business Ontology) and **ISO 20022** are notation/semantic layers, not mechanism taxonomies; ACTUS maps to FIBO.
- **Options payoff replication** (Black-Scholes-Merton, put-call parity) is an existing "molecular theory of finance": complex payoffs decompose into calls, puts, forwards, and bonds. This is the strongest evidence the molecular approach is sound — TradFi has done it for payoffs for 50 years.

**Token standards as notation.** ERC-20 (fungible), ERC-4626 (vault/share), ERC-1155 (multi-token), ERC-7540 (async-redemption), ERC-3643/permissioned-transfer. **Are standards elements or bonds?** Verdict: **standards are the interface bonds, not elements.** ERC-4626 is not a mechanism — it is a standardized *interface* to the share-price-accounting element. ERC-7540 encodes the withdrawal-queue element's interface (it adds request-then-claim asynchronous flows for RWA/off-chain settlement). This distinction resolves a common confusion: the standard is the socket, the mechanism is the appliance.

**Risk frameworks (Gauntlet, Chaos Labs, audit firms).** These encode implicit primitive taxonomies (they parametrize "collateral factor," "liquidation bonus," "close factor," "IR curve slope") — confirming that practitioners already think in isotope parameters. They are validation, not competition.

**Verdict:** The closest prior art to a periodic table is **ACTUS** (for the molecular/cash-flow half) and **Werner et al.** (for the DeFi-primitive half). What is missing from both: **bonding rules and a failure overlay.** Neither says which primitives *require* each other, which *cannot* coexist, and which *combinations* have empirically produced insolvency. That is the contribution here.

### Phase 2 — Corpus

The decomposition corpus spans ~70 protocols across every functional category, multiple generations, dead/exploited protocols, ≥10 non-EVM, and RWA/compliance/privacy. Representative members: **Pricing/DEX** — Uniswap v1/v2/v3/v4, Curve v1/v2, Balancer, Bancor, DODO, TraderJoe/Liquidity Book, Raydium, Orca, Meteora DLMM (Solana), Osmosis (Cosmos), CoW Swap, UniswapX, 1inch Fusion, 0x/RFQ. **Credit** — Aave v1/v2/v3/v4, Compound v2/v3, Morpho Blue, Euler v1/v2, MakerDAO/Sky, Liquity v1/v2, Kamino, MarginFi, Save/Solend (Solana), Alchemix, Maple, Goldfinch, Centrifuge, Clearpool, Iron Bank/CREAM. **Perps/derivatives** — GMX v1/v2, dYdX v3/v4, Hyperliquid, Drift (Solana), Gains, Synthetix, Perpetual Protocol. **Staking/yield** — Lido, Rocket Pool, EigenLayer, Pendle, Element, Yearn, Convex. **Stablecoins** — DAI, LUSD, FRAX, USDe (Ethena), UST/Terra (dead), Iron Finance (dead), Beanstalk (exploited). **Oracles/infra** — Chainlink, Pyth, UMA, Uniswap TWAP. **Bridges (mostly for failure overlay)** — Ronin, Wormhole, Nomad, LayerZero, CCTP. **RWA/compliance** — Ondo, BUIDL/Securitize, Backed. Where documentation and implementation diverge (e.g., Aave docs describing "stable rate" borrowing that was later disabled in practice; MakerDAO "CDP" docs vs "Vault" implementation naming), I note the divergence in the attribute table.

### Phase 3 — Extraction, normalization, seed changes

Naming normalization was significant: "health factor" (Aave) = "collateral ratio / ICR" (Liquity) = "margin ratio" (perps) = one element (**solvency-ratio-check**). "aToken/cToken/share" = one element (**share-price-accounting**), distinct from "debt token" (**index-based-debt-accrual**). Conversely, "vault" names five different things across Yearn (strategy mixture), MakerDAO (CDP), ERC-4626 (share interface), Balancer (singleton custody), and Uniswap v4 (singleton PoolManager) — these are NOT one element.

**Changes made to the seed vocabulary (every change logged):**
- **MERGE:** constant product + constant sum + stableswap + concentrated liquidity → one element **spot-AMM-invariant (AMM)** with isotopes (see atomicity discussion). Rationale: substitutability criterion.
- **MERGE:** kinked interest-rate curve + utilization targeting → one element **utilization-IR-curve (IRC)**. Utilization targeting is the parameter that shapes the kink, not a separate mechanism.
- **MERGE:** health factor + collateral-ratio targeting → **solvency-ratio-check (HF)**.
- **SPLIT:** "oracle" seed → four elements: **push-oracle (OrP)**, **pull-oracle (OrL)**, **AMM-TWAP (TWAP)**, **optimistic-oracle (OrO)**. Rationale: distinct failure signatures and trust assumptions.
- **PROMOTE:** flash loan from "credit" to its own **catalyst** class (FL). It is not a credit element because it creates no lasting debt position.
- **PROMOTE:** atomic composability from an assumed background to an explicit **environmental/catalyst element (ATOM)**, because non-EVM models (Cosmos IBC, async settlement) change it.
- **DEMOTE:** "points," "real yield," "restaking narrative" — REJECTED as marketing categories, not mechanisms (anti-pattern). Points are an isotope of the emissions element with off-chain accounting.
- **RENAME:** "proactive market making" → oracle-priced-pool isotope of AMM (DODO's PMM is an AMM whose invariant references an external oracle).
- **ADD (not in seed):** **socialized-loss/ADL (SL)**, **restaking/rehypothecation (RS)** (EigenLayer — arguably novel), **peg-arbitrage-mint-burn (PAB)** (the Terra element), **canonical-vs-lock-mint bridging (BR/XMSG)**.

### Phase 4 — The atomicity test (refined) and the table

**Refined atomicity test. An X is an element iff:**
1. **Functional irreducibility** — decomposing X destroys its function rather than revealing sub-parts.
2. **Independent recurrence** — X appears in ≥3 protocols by unrelated teams, *OR* in ≥1 reimplementation on a different execution model (EVM→Solana/Move/Cosmos). *(Amendment: the cross-model clause rescues elements that are common but happen to have few unrelated EVM teams.)*
3. **Substitutability** — X can be swapped for a group sibling and the molecule remains the same *kind* of protocol.
4. **Distinct failure signature** — X introduces ≥1 failure mode attributable to no other element.
5. **State-persistence independence (NEW)** — X's characteristic state (the storage it owns) cannot be reconstructed as a pure function of another element's state. *(Amendment added to resolve borderline cases below.)*

**Five borderline cases that broke the seed test, and the amendments they forced:**
- **(i) Flash loan.** Fails criterion 4 weakly (its "failure" is enabling others' failures) and has no persistent state. Resolution: it is not a normal element but a **catalyst** — a sub-class exempt from criterion 5 and scored on criterion 4 by *amplification* rather than origination. This forced the catalyst class to be formalized.
- **(ii) Concentrated liquidity.** Under the seed test it looked like a new element (distinct failure mode: LP positions going out of range, just-in-time liquidity). Under criterion 3 it is substitutable back to constant-product and remains a spot AMM. Resolution: **isotope**, not element. Forced sharpening of criterion 3 to dominate criterion 4 when they conflict.
- **(iii) rebasing vs share-price accounting.** Both track yield accrual; rebasing changes balances, share-price changes exchange rate. Seed test (criterion 1) said "same function → maybe one element." Criterion 5 (new) separates them: rebasing owns supply state, share-price owns an exchange-rate variable; neither reconstructs the other. Resolution: **two elements.** This is why criterion 5 was needed.
- **(iv) push-oracle vs pull-oracle.** Same *function* (deliver a price), so criteria 1-3 suggested merging. Criterion 4 (distinct failure: push = staleness between heartbeats; pull = stale-if-not-fetched + messaging-layer dependency) and criterion 5 (push owns on-chain state; pull stores off-chain and verifies on read) separate them. Resolution: **two elements.**
- **(v) Uniswap v2 vs v3.** v3 concentrated liquidity + NFT positions + tick oracle. Is v3 a new element or an isotope bundle? Resolution: v3 is an **isotope of AMM** (still a spot AMM by criterion 3) that *additionally bonds* a new element (per-position-NFT accounting). This shows a "version delta" is often "same element, new bond," which is the cleanest evidence for what an element is.

**Why ~46 and not 90 or 25.** Over-splitting (the 90 failure) happens if you promote every isotope — every AMM curve, every IR-curve shape — to element status; the substitutability criterion forbids this. Under-splitting (the 25 failure) happens if you collapse by function — merging all oracles, all liquidations; the distinct-failure-signature and state-persistence criteria forbid this. ~46 is where both pressures balance. The 8 flagged-uncertain elements (below) are exactly the cases where the criteria give a split decision.

**Ordering axis — three candidates evaluated:**
- **Dependency depth (rejected).** How many other elements X needs to function. *Loser because* it is a property of a *molecule*, not an element: flash loans have depth 0 in isolation but depth 3 in an arbitrage molecule. Circular.
- **First-deployment date (rejected).** Clean and objective but *predicts nothing* — it is the "decorative" trap the brief names. Bancor predates Uniswap but that tells you nothing about bonding.
- **Trust surface (CHOSEN).** The number and severity of external assumptions X forces a molecule to accept (self-contained → counterparty → oracle/external-data → governance/social). *Winner because* it both orders the elements and predicts the two things we care about: composition constraints and failure propensity. It gives the table its four "periods."

**The four periods (trust surface, increasing):**
- **Period 1 — Self-contained (trust: code only).** AMM invariant, constant-sum, bonding curve, share-price accounting, index-debt accrual, streaming, epochs/cooldowns, flash loan.
- **Period 2 — Counterparty/pool (trust: other users + pool solvency).** Pooled lending, isolated markets, IR curve, CDP mint, stability pool, tranching, PT/YT split, perp funding, vote-escrow.
- **Period 3 — External truth (trust: oracle/data).** Push/pull/optimistic oracles, TWAP, oracle-priced pools, liquidation (needs price), proof-of-reserve, ZK state proof, cross-chain messaging.
- **Period 4 — Governance/social (trust: humans, keys, off-chain).** Proxy-upgradability, guardian/pause, parameter controller, timelock/veto, emissions, KYC/allowlist hooks, permissioned transfer, RWA off-chain settlement, restaking.

### The element table (visual layout)

```
PERIOD 1  (self-contained — trust: code)
 AMM  CSM  BC   SPA  IDA  STR  EPC  FL*
 
PERIOD 2  (counterparty/pool — trust: users+solvency)
 PL   ISO  IRC  CDP  SP   TRN  PYT  PF   veE  RDM
 
PERIOD 3  (external truth — trust: data)
 OrP  OrL  TWAP OrO  OPP  LIQ  ADL  PoR  ZKP  XMSG
 
PERIOD 4  (governance/social — trust: humans/keys/off-chain)
 UPG  PAU  PRM  TL   EMI  KYC  PTR  RWA  RS   PAB
 
GROUPS (columns / substitutable families):
 Pricing | Credit | Solvency | Risk-transfer | Truth |
 Accounting | Incentives | Settlement | Stability | Access
 
CATALYSTS (enable reactions, not consumed): FL (flash loan), ATOM (atomic composability)
```

### Full attribute table (selected high-confidence elements; ~46 total)

| ID | Symbol | Name | Group | Period | Definition | First deployment | Trust introduced | Requires | Incompatible/unstable with | Failure modes | Status |
|---|---|---|---|---|---|---|---|---|---|---|---|
| E01 | AMM | Spot-AMM invariant | Pricing | 1 | Price = deterministic function of pool reserves (isotopes: constant-product, constant-sum, stableswap, concentrated liquidity, PMM) | Bancor 2017 / Uniswap v1 Nov 2018 | Code only | — | — | Impermanent loss; spot manipulable as oracle | Mature |
| E02 | CSM | Constant-sum | Pricing | 1 | Zero-slippage 1:1 swap curve | Curve component 2020 | Code | — | volatile pairs (drains) | Reserve depletion on depeg | Mature |
| E03 | BC | Bonding curve | Pricing | 1 | Mint/burn price along a supply curve | Bancor 2017 | Code | — | reflexive collateral | Reflexive death spiral | Decaying |
| E04 | SPA | Share-price accounting | Accounting | 1 | Claim value via assets/shares exchange rate (ERC-4626 interface) | Compound cToken 2019 | Code | — | — | Inflation/donation attack on first deposit | Mature |
| E05 | IDA | Index-based debt accrual | Accounting | 1 | Debt grows via a global index | Aave/Compound 2019-20 | Code | — | — | Rounding/precision | Mature |
| E06 | RBS | Rebasing | Accounting | 1 | Yield delivered by changing token balances | Ampleforth 2019 / stETH 2020 | Code | — | many DeFi integrations (breaks) | Integration breakage; supply confusion | Decaying |
| E07 | STR | Streaming/dripping | Accounting | 1 | Continuous per-second transfer | Sablier 2019 | Code | — | — | Stream stuck/rounding | Mature |
| E08 | FL | Flash loan (CATALYST) | Credit/Catalyst | 1 | Uncollateralized loan repaid same tx | Aave/dYdX 2020 (Marble 2018) | Code + atomicity | ATOM | — | Amplifies oracle/logic bugs | Mature |
| E10 | PL | Pooled lending | Credit | 2 | Shared liquidity pool, many lenders/borrowers | Compound v1/v2 2018-19 | Pool solvency | SPA, IRC, LIQ, truth | undercollateralized w/o off-chain enforcement | Bad debt, utilization lockout | Mature |
| E11 | ISO | Isolated markets | Credit | 2 | Per-market risk isolation | Rari/Fuse, Aave v3, Morpho Blue 2021-23 | Pool solvency | SPA, LIQ | — | Fragmented liquidity | Mature |
| E12 | IRC | Utilization IR curve | Credit | 2 | Kinked rate f(utilization) | Compound v2 2019 | Code | PL | — | Rate spike / liquidity lockout at 100% util | Mature |
| E13 | CDP | Collateralized debt position | Credit | 2 | Mint stablecoin against locked collateral | MakerDAO SAI 2017 | Collateral solvency | truth, LIQ | endogenous collateral (toxic) | Liquidation cascade; oracle failure | Mature |
| E14 | SP | Stability pool | Solvency | 2 | Pre-committed liquidity absorbs liquidations | Liquity v1 2021 | Pool | CDP, LIQ | — | Pool depletion → redistribution | Mature |
| E15 | LIQ | Liquidation | Solvency | 3 | Repay unhealthy debt for discounted collateral | MakerDAO 2018 (isotopes: fixed-bonus, auction, partial) | External price | truth, HF | — | Cascade; bad-debt if illiquid | Mature |
| E16 | HF | Solvency-ratio check | Solvency | 2 | Health factor / collateral ratio / margin ratio | Maker/Compound 2018-19 | Code | truth | — | Wrong price → false solvency | Mature |
| E17 | ADL | Auto-deleverage / socialized loss | Solvency | 3 | Force-close or spread losses when insurance exhausted | BitMEX concept; GMX/dYdX/perps | Pool | PF, truth | — | Profitable traders clawed back | Mature |
| E18 | TRN | Tranching (senior/junior) | Risk-transfer | 2 | Waterfall of loss absorption | BarnBridge/Centrifuge 2020-21 | Counterparty | SPA | — | Junior wipeout; correlation | Niche |
| E19 | PYT | Principal/yield split | Risk-transfer | 2 | Split yield-bearing asset into PT + YT (bond stripping) | Element/Pendle 2021 | Counterparty | SPA, AMM | — | YT→0 at maturity; yield-source risk | Growing |
| E20 | PF | Perp funding rate | Risk-transfer | 2 | Periodic payment tethers perp to index | BitMEX 2016; on-chain Perp/dYdX 2020-21 | External price | truth, HF | — | Funding runaway; oracle manip | Mature |
| E30 | OrP | Push oracle | Truth | 3 | DON pushes aggregated price on deviation/heartbeat | Chainlink ETH/USD May 30 2019 | Node set honesty+liveness | — | — | Staleness between updates | Mature |
| E31 | OrL | Pull oracle | Truth | 3 | App pulls signed price on demand | Pyth (Solana mainnet Aug 26 2021; pull arch Aug 2022) | Publisher honesty + messaging layer | XMSG | — | Stale-if-not-fetched | Growing |
| E32 | TWAP | AMM time-weighted price | Truth | 3 | Cumulative-price accumulator over interval | Uniswap v2 Apr 2020 | Pool liquidity depth | AMM | thin pools (manipulable) | Lag; multi-block MEV manip | Mature |
| E33 | OrO | Optimistic oracle | Truth | 3 | Assert-then-dispute escalation game | UMA 2021 (whitepaper Dec 2018) | Token-holder honesty; capital | TL | fast-settlement needs (too slow) | Governance/whale vote capture | Growing |
| E34 | PoR | Proof-of-reserve | Truth | 3 | On-chain attestation of backing | Chainlink PoR ~2020 | Custodian self-attestation (off-chain) | OrP | — | Custodian lies off-chain | Growing |
| E40 | UPG | Proxy upgradability | Access/Control | 4 | Mutable implementation behind proxy | wide 2019+ | Admin key/governance | TL | immutability claims | Malicious/compromised upgrade | Mature |
| E41 | EMI | Emissions | Incentives | 4 | Protocol-token rewards for actions | Compound COMP Jun 2020 | Governance | — | reflexive collateral | Mercenary capital; token death spiral | Mature |
| E42 | veE | Vote-escrow | Incentives | 2 | Lock token for time-weighted governance/boost | Curve veCRV 2020 | Governance | EMI | — | Vote-market capture (Curve wars) | Mature |
| E43 | KYC | Allowlist / KYC hook | Access | 4 | Transfer gated by identity/permission | Centrifuge/Maple/RWA 2021+ | Off-chain identity + admin | — | permissionless composability | Composability loss; admin risk | Growing |
| E44 | RS | Restaking / rehypothecation | Access/Risk | 4 | Reuse staked capital to secure other services | EigenLayer 2023 | Slashing governance; correlated risk | — | (uncertain) | Correlated slashing; cascading | Emerging (uncertain) |
| E45 | PAB | Peg-arbitrage mint/burn | Stability | 4 | Mint/burn twin token to defend peg | Terra/UST (BasisCash lineage) 2020-21 | Reflexive market confidence | AMM, OrP | endogenous collateral (TOXIC) | Death spiral | **Radioactive** |
| E46 | XMSG | Cross-chain messaging | Truth/Settlement | 3 | Verify+relay messages across chains (lock-mint / burn-mint / canonical) | 2020+ | Validator/DVN set | — | — | Bridge key/verification compromise | Growing |

*(Full 46-element set includes additionally: batch-auction, Dutch-auction, RFQ, on-chain-orderbook, TWAMM, intents/solvers, order-flow-auction, aggregation/routing, withdrawal-queue, vesting/lockup, checkpointing, timelock, guardian/pause, parameter-controller, PSM/redemption-right, algorithmic-supply-adjustment, options-vault, cover-pool, insurance-fund/backstop, shielded-balances. The 8 flagged-uncertain: restaking (novel or composite?), intents-vs-solvers (one element or two?), hooks (element or extension-point?), PSM (element or CDP isotope?), points (rejected as marketing but contested), oracle-priced-pool (AMM isotope or bridge to truth group?), MEV-redistribution (mechanism or environmental?), and ZK-state-proof (truth element or infrastructure?).)*

### Phase 5 — Bonding rules

**Required bonds (⇒ = "requires"), each empirically grounded:**
- **R1: Leverage ⇒ Truth + Solvency.** Any element that lets a position control more value than posted (CDP, PL, PF, ISO) requires both a truth element (price) and a solvency element (HF+LIQ). *Grounding:* every corpus protocol that created leverage without a robust truth element was exploited (bZx 2020, Mango 2022, Cream 2021 — all leverage bonded to a manipulable price).
- **R2: Transferable claim ⇒ Accounting.** Any element minting a transferable receipt (SPA share, LP token, PT/YT, aToken) requires an accounting element to price it. *Grounding:* the ERC-4626 first-deposit inflation attack is a bond defect between SPA and a missing minimum-liquidity guard.
- **R3: Liquidation ⇒ Truth.** LIQ cannot function without OrP/OrL/TWAP/OrO. *Grounding:* trivially, and Venus/others' bad-debt events trace to LIQ bonded to a stale or wrong price.
- **R4: Peg defense by mint/burn (PAB) ⇒ exogenous truth AND exogenous collateral to be non-toxic.** *Grounding:* Terra bonded PAB to endogenous collateral (LUNA) — see reflexivity.
- **R5: Pull oracle ⇒ Cross-chain messaging (or equivalent delivery).** *Grounding:* Pyth delivers via Wormhole; the oracle inherits the messaging layer's trust.
- **R6: Emissions governance ⇒ Timelock/veto to be safe.** *Grounding:* Beanstalk had emissions+governance with no timelock → flash-loan governance capture.

**Forbidden / unstable bonds (each grounded in ≥1 incident):**
- **F1: Endogenous collateral × peg-mint/burn = TOXIC.** Collateral whose price depends on the thing it collateralizes. *Incident:* Terra/UST, May 2022. Per Harvard Law and other post-mortems, LUNA supply soared from 343M (May 9) to 6.53 trillion tokens within a week (a +1,908,651% inflation); LUNA fell from an April peak above $80 to roughly $0.0001, and UST's ~$17.5B market cap plus LUNA's >$40B collapsed over roughly three days (~$40–45B erased).
- **F2: Spot-AMM-as-oracle × leverage = UNSTABLE.** Using a manipulable spot price as the truth element for a leverage element. *Incidents:* bZx Feb 2020 (flash-loan + spot oracle); Mango Oct 2022 (per SEC press release 2023-13, beginning Oct 11, 2022 Avraham Eisenberg "engaged in a scheme to steal approximately $116 million" by using paired MNGO perpetual-futures trades to "artificially inflate the price of the MNGO token," then borrowing against it, "effectively draining all available assets from the Mango Markets platform" — note his April 2024 jury conviction was vacated May 23, 2025 on venue/materiality grounds); Cream 2021.
- **F3: Rebasing × most lending collateral = INTERFACE-INCOMPATIBLE.** Rebasing balances break share accounting; protocols must wrap (wstETH) — an interface-bond failure, not economic.
- **F4: Undercollateralized lending × permissionless (no off-chain enforcement) = UNSTABLE.** *Incident:* Maple's ~$36M writedowns (Orthogonal/Auros, late 2022) show undercollateralized credit requires the KYC/off-chain-enforcement element (Period 4) to be solvent.
- **F5: Upgradable proxy × "immutable/trustless" claim = TRUST-INCOMPATIBLE (documentation vs implementation).** Many exploited protocols marketed immutability while retaining admin keys.

**Catalysts.** **Flash loan (FL)** and **atomic composability (ATOM)** enable reactions without being consumed. FL changes the *safety* of the rest of the molecule by collapsing the capital barrier to manipulation: any bond that was "safe because manipulation is expensive" (F2) becomes unsafe. FL is a catalyst for both benign reactions (arbitrage that keeps pegs, liquidations that keep protocols solvent) and malign ones (oracle manipulation). It is not itself a vulnerability — the vulnerability is always the bond it catalyzes.

**Reaction conditions (environmental variables determining stability):**
- **Block time / finality** — TWAP security assumes attackers can't cheaply control consecutive blocks; PoS multi-block MEV weakens this.
- **MEV environment** — determines whether liquidations and arbitrage are performed competitively (safe) or extractively.
- **Oracle latency** — push heartbeat vs pull freshness sets the window of stale-price risk.
- **Market depth** — F2's manipulation cost scales with liquidity; a bond safe in a deep pool is toxic in a thin one.
- **Gas cost** — determines whether liquidations are economical (below some position size, liquidation is unprofitable → structural bad debt).

**Reflexivity (the master predictor).** A reflexive bond exists when an element's *output* feeds its own *price input*. Formally: element X produces token T, and X's solvency/pricing reads a market where T is dominant. This is F1 and F2 generalized. **Empirically it is the single best predictor of catastrophic (not merely large) failure:** Terra (UST backs LUNA backs UST), Mango (MNGO collateral priced by MNGO's own thin market), algorithmic-supply stablecoins broadly. Non-reflexive failures (Euler, Wormhole) are large but *recoverable/bounded*; reflexive failures go to zero.

### Phase 6 — 25 molecular decompositions

Notation (see Phase spec below): `Element[isotope]{param}` joined by `·`; `⊗` = catalytic enabler; superscript `ᵀ/ᴱ/ⁱ` on a bond denotes trust/economic/interface bond type; `(opt)` = optional; `⊕` = mixture (separable) vs `·` (bonded).

1. **Uniswap v1** = `AMM[cp]{fee=0.3%}` — pure constant-product, ETH-paired. Reading: a single Period-1 element. *Residue:* none — this is nearly a "noble" molecule.
2. **Uniswap v2** = `AMM[cp]{fee=0.3%} · TWAPⁱ` — adds cumulative-price accumulator (a truth element bonded by interface). Reading: v2 = v1 + the TWAP element, which is why v2 became DeFi's price backbone. *Residue:* flash-swap feature not cleanly an element (a mini-catalyst).
3. **Uniswap v3** = `AMM[concentrated]{multi-fee} · TWAP · NFT-position-accounting` — isotope shift + new accounting element. Reading: same *kind* (spot AMM) but bonds per-position NFT accounting. *Residue:* active LP management / JIT liquidity is behavioral, not a mechanism.
4. **Uniswap v4** = `AMM[concentrated] · TWAP · HOOK{pre/post} · singleton-custody · flash-accounting` — hooks are an extension-point (flagged uncertain: element or socket?). Reading: v4 turns the molecule into a *platform*; a hook is a bonding *site*, strengthening the "standards/sockets ≠ elements" thesis. *Residue:* hooks can embed arbitrary elements — the table cannot bound a v4 pool without knowing its hook (the ~$8.4M Bunni hook exploit was a hook-embedded bug, not a v4-core bug).
5. **Curve v1 (stableswap)** = `AMM[stableswap]{A} · veE · EMI · gauge` — pricing isotope + full incentive stack. Reading: Curve's identity is the incentive elements, not just the curve.
6. **Curve v2** = `AMM[cryptoswap]{A,γ} · veE · EMI · gauge` — isotope for volatile pairs.
7. **Balancer** = `AMM[weighted-geomean]{weights} · singleton-custody` — n-token isotope.
8. **DODO** = `AMM[PMM] · OrPᵀ` — proactive market making reads an external oracle; note the bond to Period-3 truth is what distinguishes it from Uniswap. *Residue:* oracle-priced-pool sits ambiguously between Pricing and Truth groups (flagged uncertain).
9. **Compound v2 (pooled lender)** = `PL · SPA[cToken] · IDA · IRC[kinked]{Uopt=80%} · HF · LIQ[fixed-bonus]{close=50%} · OrPᵀ` — the canonical lending molecule. Reading: leverage element (PL) satisfies R1 by bonding truth (OrP) + solvency (HF+LIQ). *Residue:* COMP emissions (governance element) not shown; reserve factor is a param.
10. **Aave v3** = `PL · ISO[eMode] · SPA[aToken] · IDA · IRC[2-slope]{Uopt} · HF · LIQ[partial]{dynamic close} · OrPᵀ · XMSG(opt, Portals)` — near-isomer of Compound. **Discriminating differences:** isolation/eMode element present (Compound v2 lacks it), partial-liquidation isotope with dynamic close factor (Compound uses fixed 50%), and an optional cross-chain element (Portals). This is how the table expresses what "two similar lenders" actually differ on.
11. **Morpho Blue** = `ISO · SPA · IRC · HF · LIQ · OrPᵀ · (immutable, no UPG)` — the discriminator vs Aave is the *absence* of the upgradability element and radical isolation. Reading: Morpho is Aave minus governance surface — a lower-trust-surface isomer.
12. **MakerDAO/Sky (CDP stablecoin)** = `CDP · HF · LIQ[auction] · OrPᵀ · PSM{USDC 1:1} · EMI · UPG · TL · RWA(opt)` — Reading: DAI is a CDP molecule whose peg is increasingly held by the PSM element (a redemption/arbitrage element) and RWA collateral. *Residue:* MKR debt-auction recapitalization (mint MKR to cover bad debt) is a governance-backed backstop the table models as EMI+UPG but doesn't fully capture — a genuine residue.
13. **Liquity v1** = `CDP{MCR=110%} · SP · LIQ[SP-offset→redistribution] · RDM[redemption-right] · recovery-mode{TCR=150%}` — Reading: Liquity replaces the auction-liquidation and oracle-heavy governance of Maker with a stability-pool solvency element and a hard redemption right; minimal Period-4 surface. *Residue:* "recovery mode" is a global state machine, arguably a distinct solvency element (flagged).
14. **GMX v2 (perp DEX, oracle-priced)** = `PF · OPP[GM-pool] · OrL[Chainlink data streams]ᵀ · HF · ADL · SPA[GM]` — Reading: a pool-based perp; the pool is counterparty to all trades. Truth element is a low-latency pull-style feed. *Residue:* GLP/GM LP's short-volatility exposure is an emergent economic property, not an element.
15. **Hyperliquid (perp DEX, orderbook)** = `on-chain-orderbook · PF · HF · ADL · OrPᵀ(mark) · (app-chain consensus)` — **Same "kind" as GMX (perp DEX) but structurally distinct:** orderbook pricing element replaces oracle-priced-pool. This is the clearest near-isomer contrast: GMX = `OPP`, Hyperliquid = `orderbook`; everything else (funding, margin, ADL) matches.
16. **dYdX v4** = `on-chain-orderbook · PF · HF · ADL · (Cosmos app-chain)` — non-EVM (Cosmos SDK). Reading: proves the perp elements are execution-model-independent — the same formula as Hyperliquid on a different base.
17. **Lido (liquid staking)** = `staking-wrapper · RBS[stETH]/SPA[wstETH] · withdrawal-queue · node-operator-set(permissioned)ᵀ` — Reading: stETH is the rebasing isotope, wstETH the share-price isotope of one accrual element. *Residue:* validator-set trust (Period 4, permissioned operators) is a real trust element often ignored.
18. **Rocket Pool** = `staking-wrapper · SPA[rETH] · node-bond{8 ETH + RPL} · withdrawal-queue` — discriminator vs Lido: value-accruing SPA (not rebasing) + permissionless bonded operators (lower trust surface, less liquidity).
19. **Pendle (yield splitting)** = `PYT{maturity} · AMM[yield-specialized] · SPA[SY, ERC-5115]` — Reading: bond-stripping element bonded to a maturity-aware AMM. Strong TradFi antecedent (coupon stripping). *Residue:* implied-yield/APY pricing is emergent from the AMM, not a separate element.
20. **Yearn v2 (vault strategy — MIXTURE not compound)** = `{SPA[yVault]} ⊕ strategy-mixture(PL, AMM, EMI, ...)` — Reading: Yearn is an **alloy/mixture**, not a true molecule: it co-locates other protocols' elements behind a share interface and can swap strategies without changing identity. This operationalizes the brief's alloy/mixture distinction.
21. **Convex** = `{veE-wrapper(cvxCRV) · vlCVX-governance} ⊕ EMI` — a meta-protocol mixture layered on Curve's veE element; the "Curve wars" vote-market (Votium, bribe.crv.finance) is an economic bond between EMI and veE across two protocols.
22. **CoW Swap (intent DEX)** = `intents · batch-auction{~30s} · solver-competition · CoW-matchingᴱ · AMM(fallback)` — Reading: coincidence-of-wants matching is a settlement element that bypasses AMM touch (lowest residual MEV). *Residue:* solver private inventory & off-chain solving is opaque to the table.
23. **UniswapX (intent DEX)** = `intents · Dutch-auction · filler-competition · AMM(fallback)` — near-isomer of CoW Swap; discriminator = Dutch-auction (per-order) vs batch-auction (uniform clearing).
24. **Centrifuge (RWA/compliance-gated)** = `TRN[senior/junior] · KYCᵀ · RWA[off-chain-settlement] · SPA · ERC-7540[async-redeem]ⁱ` — Reading: a tranched credit molecule whose defining elements are Period-4 access + off-chain settlement, with async-redemption as the *interface* bond. *Residue:* legal/SPV enforceability is entirely off-chain — the largest single residue in the corpus.
25–27. **Failed catastrophically:**
- **Terra/UST** = `PAB · BC[endogenous LUNA]ᵀ · OrP · (Anchor: PL{19.5% subsidized})` — **F1 toxic bond.** Reading: peg-mint/burn bonded to endogenous collateral, subsidized by an unsustainable yield element. Reflexive by construction. *Residue:* none needed — the table predicts this molecule is toxic a priori.
- **Beanstalk** = `algorithmic-supply · EMI · governance(no TL) ⊗FL` — **R6 violation.** Per the Immunefi/Omniscia post-mortem and Bloomberg (Apr 18, 2022): on April 17, 2022 the attacker flash-loaned ~$1B (DAI/USDC/USDT from Aave, plus BEAN and LUSD) to reach ~67% of voting power and call `emergencyCommit`, draining ~$182M total; the attacker netted ~$80M (PeckShield), and BEAN fell ~88% from its $1 peg.
- **Mango Markets** = `on-chain-orderbook · PF · HF · OrP[own-thin-market]ᵀ` — **F2/reflexive.** MNGO collateral priced by MNGO's own shallow market; ~$116M drained, Oct 2022 (SEC, see F2 above).

**Two protocols with identical formulas.** dYdX v4 and Hyperliquid reduce to nearly identical formulas (`orderbook · PF · HF · ADL`). The table says they are the same *kind* and structurally near-identical; practitioners insist they differ. The table is *right about mechanism* and the practitioner difference is **non-table**: base-layer (Cosmos app-chain vs custom L1), latency, and liquidity — reaction conditions and residue, not elements. This is a feature: it localizes the real difference to the environment, not the mechanism.

### Phase 7 — Gaps and predictions (empty cells)

1. **Optimistic-oracle-priced perp DEX** (`PF · OrO`). *Verdict: economically unattractive* — OrO's dispute latency (hours) is incompatible with funding/liquidation reaction conditions (need sub-minute truth). Blocked by a reaction-condition mismatch, not a bonding rule.
2. **Fully on-chain tranching of perp-LP risk** (`TRN · OPP`). *Verdict: unbuilt but viable* — senior/junior tranches over GM/GLP pools are permitted; correlation risk is manageable. Likely to appear.
3. **ZK-state-proof oracle replacing push feeds for lending** (`PL · ZKP` instead of `PL · OrP`). *Verdict: blocked by a missing infrastructure element* — ZK light clients for arbitrary price state are nascent (Polyhedra-class). Viable once mature.
4. **Permissionless undercollateralized lending without KYC** (`PL[undercollateralized] · ¬KYC`). *Verdict: forbidden by bonding rule F4* — insolvent without off-chain enforcement, absent a novel crypto-native reputation element.
5. **Intent-based cross-chain lending** (`PL · intents · XMSG`). *Verdict: unbuilt but viable*, emerging via ERC-7683 intent standard.
6. **Rebasing collateral natively in isolated markets** (`ISO · RBS` without wrapper). *Verdict: blocked by interface incompatibility F3* until an accounting element natively handles rebasing.
7. **Concentrated-liquidity stableswap for RWAs** (`AMM[concentrated+stableswap] · KYC`). *Verdict: unbuilt but viable*; compliance-gated CL pools for tokenized treasuries.
8. **Optimistic-oracle proof-of-reserve** (`PoR · OrO`) for trustless custodial attestation. *Verdict: unbuilt but viable* and would meaningfully reduce PoR's custodian-trust residue.
9. **Vote-escrow over restaking** (`veE · RS`). *Verdict: economically unattractive* now (restaking rewards too variable to justify multi-year locks); could flip.
10. **Batch-auction liquidations** (`LIQ · batch-auction`). *Verdict: unbuilt but viable* — would reduce liquidation MEV/cascade; no bonding barrier, likely just unbuilt.
11. **Streaming-based interest instead of index accrual** (`PL · STR` replacing `IDA`). *Verdict: economically unattractive* — index accrual is gas-cheaper; STR adds no capability.
12. **Fully homomorphic/shielded lending** (`PL · shielded-balances`). *Verdict: blocked by missing infrastructure* (FHE performance) and partly by F4 (can't liquidate what you can't see).

### Phase 8 — Failure overlay and distribution

Mapping the corpus's major incidents to root-cause categories (a) defective element instance, (b) invalid bond between valid elements, (c) environmental/out-of-range, (d) outside the table:

- **(a) Defective element instance (implementation bug):** Euler v1 (per Chainalysis and Euler Labs, the March 13, 2023 flash-loan exploit of the `donateToReserves` function drained ~$197M in DAI, wBTC, stETH and USDC — a bug in one element instance, not the bond; the attacker returned all recoverable funds by April 3, 2023, with ~$240M recovered as ETH appreciated); many reentrancy cases. **~25-30% of incidents, but note most were recovered.**
- **(b) Invalid bond between valid elements:** bZx, Mango (~$116M), Cream ($130M+), Harvest, Value DeFi — all valid-oracle-bonded-invalidly-to-leverage (F2). **~30-35%, and these dominate *reflexive* catastrophic losses.**
- **(c) Environmental / outside stability range:** Black Thursday (MakerDAO, March 2020 — gas spike + price crash broke liquidation-auction reaction conditions, $0-bid auctions); some depeg cascades. **~10%.**
- **(d) Outside the table entirely:** Ronin (per CoinDesk, March 23, 2022, an attacker "used hacked private keys to forge fake withdrawals," draining 173,600 ETH and 25.5M USDC (~$625M) after compromising 5 of 9 validator nodes — 4 Sky Mavis + 1 Axie DAO; OFAC later attributed it to Lazarus Group), Wormhole (~$320M, signature-verification bug in bridge infra), Nomad (~$190M, zero-hash message-verification bug), BadgerDAO (frontend/phishing), Bybit ($1.5B, off-chain/frontend), Beanstalk arguably (governance capture — partly table via R6). **~30-35% by count and, because bridge hacks are huge, the PLURALITY by dollar value.**

**The bounding verdict, stated plainly:** Category (d) is roughly a third by count and the largest by dollars. **This means a mechanism periodic table can explain at most ~two-thirds of DeFi's loss history.** Key compromise, governance capture, frontend attacks, and off-chain fraud are not mechanism-composition problems and no element table will ever predict them. The table's real explanatory power is concentrated in category (b) — invalid bonds — where it is genuinely predictive, and specifically in the reflexivity sub-class, which is where the money actually goes to zero. That is the honest scope of the instrument.

## Recommendations

**Staged next steps:**
1. **Adopt the 46-element set as v0.1 but freeze only the 38 high-confidence elements; hold the 8 flagged as "candidate."** Benchmark to promote a candidate: it must pass all five atomicity criteria against ≥3 unrelated non-forked implementations, with ≥1 on a non-EVM model. *Threshold that would change this:* if restaking (RS) appears in ≥3 unrelated designs with a distinct, non-composite failure signature, promote it from uncertain to confirmed novel element.
2. **Build the knowledge graph edges as typed bonds (interface/economic/trust) first, elements second.** The bonds carry the predictive content; a graph with elements but untyped edges reproduces the money-legos dead end.
3. **Operationalize the reflexivity detector as the primary risk screen.** For any new molecule, mechanically check: does any element's price input read a market its own output dominates? If yes, flag toxic (F1/F2) before any audit. *Threshold:* this single check would have flagged Terra, Mango, Iron Finance, and most algorithmic stablecoins ex ante.
4. **Treat category-(d) risk as out-of-scope for the table and route it to a separate operational-security framework.** Do not let a mechanism taxonomy create false confidence about key management and governance — the biggest dollar losses live there.
5. **Use version-deltas as the primary evidence source for future element discovery.** The v2→v3→v4 progression of Uniswap taught more about element boundaries than any single protocol; instrument the corpus to diff versions automatically.

**What would change these recommendations:** If a genuinely new, non-composite primitive ships (e.g., a working FHE-shielded lending element, or a trustless ZK price oracle that displaces push feeds), the table gains a row and several empty cells fill — re-run Phases 4-7. If category-(d) losses fall sharply (better key management, formal governance timelocks become universal), the table's relative explanatory power rises and it becomes worth extending toward operational elements.

## Caveats

- **The evidence is thin in exactly these places (flagged, not smoothed):** (1) first-deployment attributions are contested — flash loans (Marble 2018 vs Aave/dYdX 2020 popularization), vote-escrow (Curve veCRV 2020, confirmed by Curve docs), and "who was first" is often marketing; (2) the 8 uncertain elements are genuine split-decisions, not oversights; (3) exploit dollar figures vary by source due to price-at-time conversions (Ronin ~$600-625M, Wormhole ~$320-326M, Nomad ~$190M, Mango ~$116-117M) — ranges given, most-cited first.
- **Documentation vs implementation gaps** are real and noted per-protocol: Aave "stable rate" borrowing (documented, later disabled), MakerDAO "CDP" (docs) vs "Vault" (implementation), and pervasive "immutable/decentralized" marketing over admin-key reality (F5).
- **Practitioner vs documentation vs implementation** disagree most on oracles (what a protocol claims about manipulation-resistance vs what its TWAP window actually secures) and on "decentralization" claims for permissioned validator/operator sets (Lido's curated operators, LayerZero's default DVN 2-of-3 multisig, Pyth's institutional publisher set).
- **The periodic *law* does not hold.** This is a *periodic table* only in the weak sense of an ordered, grouped element set with combination rules. There is no Mendeleev-style property periodicity, and I recommend against implying one — that would be forcing the metaphor past its explanatory limit, the brief's final anti-pattern.
- **Non-EVM coverage is adequate but not exhaustive:** Solana (Save, Kamino, MarginFi, Drift, Meteora, Raydium/Orca), Cosmos (dYdX v4, Osmosis), and Move/Cardano-eUTxO are represented enough to confirm elements are largely execution-model-independent, but Bitcoin-L2 and Cardano DeFi are thin in the corpus and could hide execution-model-specific elements.
- **The machine-readable deliverable** (elements, groups, attributes, typed bonds, 25 decompositions) follows the schema: `elements[{id,symbol,name,group,period,definition,first_deployment,trust,requires[],incompatible[],failure_modes[],status}]`, `bonds[{from,to,type∈{interface,economic,trust},rule,grounding_incident}]`, `molecules[{name,formula,elements[],residue}]` — structured exactly as the attribute and bonding tables above, suitable for knowledge-graph loading with bonds as typed edges.

---

### Appendix A — Notation specification

A protocol **formula** is a set of element symbols joined by bond operators:
- **`·`** — a bonded pair (a true chemical bond; the two elements form part of one molecule).
- **`⊕`** — a mixture (co-located but separable; used for aggregators/meta-protocols like Yearn, Convex).
- **`⊗X`** — a catalytic enabler X (flash loan, atomic composability) that participates in a reaction without being consumed.
- **Parameters:** `Element{param=value}` (e.g., `IRC{Uopt=80%}`, `CDP{MCR=110%}`).
- **Isotopes:** `Element[isotope]` (e.g., `AMM[concentrated]`, `LIQ[auction]`).
- **Versions:** append version to the molecule name, not the element (Uniswap v3 = same AMM element, new bond), documenting the version delta as an added/removed bond.
- **Optional elements:** `Element(opt)` (present in some deployments/pools but not definitional).
- **Bond-type superscripts:** `ᵀ` (trust), `ᴱ` (economic), `ⁱ` (interface) — annotate a bond when the type is analytically important (especially for failure analysis: interface-valid but economically toxic bonds are the exploit signature).

A well-formed formula must satisfy all applicable required-bonds (R1–R6) or be explicitly flagged as violating one (the failure prediction).

### Appendix B — Open questions and instability list (arbitrary calls + what would settle them)

1. **Is restaking (RS) a novel element or a composite of pooled-staking + rehypothecation?** *Would be settled by:* ≥3 unrelated implementations with a slashing-failure signature not reducible to either parent element.
2. **Are "intents" and "solvers" one element or two?** *Settled by:* a deployed intent system with no solver competition (or vice versa) that still functions — proving separability.
3. **Are Uniswap v4 hooks an element or a bonding site (socket)?** *Settled by:* whether any hook exhibits a failure signature independent of the element it embeds. Current evidence (Bunni) says the failure is the embedded element's, favoring "socket."
4. **Is PSM a distinct stability element or a CDP isotope?** *Settled by:* whether PSM can exist without a CDP molecule around it (Frax-style AMOs suggest yes → lean element).
5. **Is oracle-priced-pool (DODO PMM, GMX OPP) a Pricing isotope or a distinct bridge to the Truth group?** *Settled by:* whether removing the external oracle leaves a functioning spot AMM (it does for DODO → isotope; it does not for GMX → distinct).
6. **Does the trust-surface ordering hold at the boundaries** (e.g., is a permissioned-but-code-enforced allowlist Period 2 or Period 4)? *Settled by:* empirical failure data on whether such elements fail like counterparty risk or like governance risk.
7. **Is ZK-state-proof a Truth element or infrastructure?** *Settled by:* a deployed protocol whose solvency depends on a ZK state proof as its sole truth element.
8. **Where exactly is the flash-loan/atomic-composability boundary** — are they one catalyst or two? *Settled by:* a non-atomic execution model (async settlement) where flash loans cannot exist, isolating ATOM as the more fundamental catalyst.