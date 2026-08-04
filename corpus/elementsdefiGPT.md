# A Periodic Table of Decentralized Finance

This report proposes a **closed core of 48 DeFi mechanism elements**, organized into 12 substitutability groups and five dependency-depth periods. It also identifies eight provisional candidates that do not yet satisfy the evidence threshold for element status. The closure claim is empirical rather than universal: every recurring financial mechanism observed in a corpus of **101 protocol-version units** can be represented by the 48 core elements, typed bonds, parameters, environmental conditions, or explicitly reported residue. The table is not guaranteed to classify mechanisms that have not yet been designed.

The central finding is that the chemistry metaphor is useful only after three corrections. First, DeFi “elements” are designed state-transition mechanisms, not immutable natural substances. Second, DeFi bonds come in three irreducible types—**interface, economic, and trust bonds**—which can succeed or fail independently. Third, protocols often contain off-chain institutions, execution-environment behavior, and implementation-specific logic that cannot be reduced to financial primitives. Those omissions are not defects to conceal; they define the explanatory boundary of the table.

## Executive verdict and metaphor audit

### What the metaphor earns

| Chemistry term | Verdict | DeFi interpretation |
|---|---|---|
| **Element** | Retain | An independently recurring, role-substitutable state-transition mechanism with a distinct failure signature. |
| **Atomic number** | Replace the literal analogy | A stable element ID ordered by minimum dependency depth, then functional family. Discovery date and TVL are rejected. |
| **Group** | Retain | A family of mechanisms that can occupy the same role boundary while leaving the protocol recognizably the same kind of system. |
| **Period** | Retain, but redefine | Minimum dependency depth: ledger-local accounting, deterministic transformation, measured/time-conditioned state, contingent solvency, or multi-agent/cross-domain coordination. |
| **Valence** | Retain as a typed vector | The number and kinds of required interface, economic, and trust counterparties—not a single integer. |
| **Molecule** | Retain | A deployed protocol-version represented as elements, parameters, and typed bonds. |
| **Isotope** | Retain | A continuous parameter or implementation variant that preserves the state-transition semantics and failure family of an element. |
| **Catalyst** | Retain under a strict test | A mechanism that expands the reachable transaction path but leaves no enduring financial claim after the reaction. Flash liquidity is the clearest example. |
| **Alloy or mixture** | Retain | A routing, aggregation, or strategy system whose component balance sheets remain separable. |
| **Radioactivity** | Retain only as an overlay | A mechanism whose viability tends to decay because of reflexivity, disappearing liquidity, obsolete trust assumptions, or abandonment. No literal half-life is implied. |
| **Noble gas** | Discard as a group | Deployed DeFi contracts are generally callable or transferable even when immutable. “Low-valence endpoint” is a more accurate description than noble gas. |
| **Toxic compound** | Retain | A combination of individually valid elements whose bond is empirically unsafe. |
| **Chemical reaction** | Retain conditionally | A transaction or sequence of state changes, provided execution conditions and bond types are stated explicitly. |

A **true compound** has a shared state machine, balance sheet, settlement rule, or solvency invariant. A **mixture** merely routes among components that remain independently redeemable and independently insolvent. An aggregator such as 1inch is therefore normally a mixture; a Balancer Vault plus a weighted pool is a compound because custody, accounting, and settlement are jointly coordinated. Balancer’s own documentation illustrates why this distinction matters: the Vault separates accounting from pool math and imposes token-compatibility restrictions, including restrictions around balance-changing tokens. citeturn3search2turn3search17

A **catalyst** must satisfy two conditions: it materially enlarges the reachable transaction states, and its claim is extinguished before the final state. Flash loans and flash swaps meet this test because they supply atomic liquidity that must be repaid within the transaction; routing and cross-domain messaging are weaker catalysts because they may leave persistent trust exposure even when they leave no financial balance. citeturn14search0turn15search1

### The period axis and the rejected alternatives

| Candidate row axis | Strength | Fatal weakness | Verdict |
|---|---|---|---|
| **Application-stack layer** | Intuitive separation of token, protocol, oracle, and governance layers | Many mechanisms span layers; a proxy, oracle, or vault can be infrastructure in one protocol and integral finance in another | Rejected |
| **Trust assumption** | Directly relevant to risk | Trust is multivariate rather than ordinal: an element may simultaneously depend on governance, reporters, legal recourse, and validators | Retain as an attribute, not a row |
| **Composability class** | Highlights synchronous versus asynchronous composition | Depends on chain execution, gas, bridges, and deployment context; strongly risks EVM bias | Retain as an environmental attribute |
| **Minimum dependency depth** | Orders mechanisms by what they minimally require to exist | Some mechanisms could be assigned to adjacent periods | Selected because it is comparatively stable under implementation changes |

The five periods are:

| Period | Meaning | Typical examples |
|---|---|---|
| **P0** | Ledger-local claims and accounting | Shares, indexes, rebases |
| **P1** | Deterministic transformation within one execution domain | AMM invariants, order books, routing, flash liquidity |
| **P2** | Externally measured or time-conditioned state | Oracles, TWAPs, epochs, queues, emissions |
| **P3** | Contingent obligation, risk transfer, and solvency | Lending, liquidations, options, tranches, stablecoin redemption |
| **P4** | Multi-agent, cross-domain, or mutable-control coordination | Solvers, governance delays, upgrades, guardians, messaging |

The “atomic number” is therefore a **stable identifier**, not a scientific magnitude. Core IDs `E001–E048` are sorted first by period, then by family and mechanism. Unlike ordering by first deployment, this avoids permanently privileging uncertain priority claims. Unlike ordering by trust surface, it does not need to change when a protocol replaces a multisig with governance or an oracle committee with proofs.

### The three bond types

An interface bond answers: **Can these components exchange the required calls, tokens, messages, or proofs?** An economic bond answers: **Do the combined incentives, liquidity, valuation, and loss allocation remain solvent?** A trust bond answers: **Which actors can attest, censor, upgrade, pause, mint, or otherwise alter the result?**

These must not be conflated. A bridge can have a correct token interface but an unsafe validator trust bond. A lender can consume a syntactically correct oracle price while having an economically invalid bond to a thin market. A permissioned RWA pool can be economically solvent while violating its legal trust model if its claims transfer to ineligible holders.

### Atomicity as a formal test

For a candidate mechanism \(m\), element status requires:

\[
A(m)=F(m)\land R(m)\land S(m)\land D(m)\land B(m)\land P(m)\land O(m)
\]

where:

| Test | Formalized requirement |
|---|---|
| **Functional irreducibility, \(F\)** | No decomposition into two independently recurring mechanisms reproduces the function without losing its defining state transition. |
| **Independent recurrence, \(R\)** | At least three unrelated teams and at least two independent code lineages implement the mechanism. Forks and superficial renamings count once. |
| **Role-preserving substitutability, \(S\)** | A sibling mechanism can replace it at the same role boundary while the application remains recognizably the same protocol class. |
| **Distinct failure signature, \(D\)** | It creates at least one failure mode not fully attributable to another element. |
| **State-transition boundary, \(B\)** | It changes claims, obligations, allocation, valuation, or settlement—not merely an API or user interface. |
| **Execution-model portability, \(P\)** | Its semantics can be stated without assuming EVM calls, storage, or transaction ordering; chain-specific candidates must be flagged. |
| **Implementation observability, \(O\)** | The mechanism is identifiable in documentation, interfaces, state variables, events, or auditable execution behavior. |

A parameterized family remains one element where implementations are connected by a continuous change in parameters and retain the same state space and failure family. A new element is warranted where the state representation changes discretely, counterpart requirements change, or a new failure family appears.

The refined test resolves the most important borderline cases as follows:

| Borderline case | Naive result | Amendment-driven resolution |
|---|---|---|
| **Fee tiers and dynamic fee values** | Could be called separate pricing elements | Isotopes of the pricing mechanism unless fee logic adds an independently stateful controller |
| **Health factor** | Appears repeatedly and has failure relevance | A derived observation of `Ct`, not a state-transition element |
| **Hooks** | Highly substitutable and recurrent | An interface grammar or bond scaffold; the mechanism implemented by a hook is the element |
| **ERC-4626 or ERC-7540** | Widely recurring standards | Interface notation for `Sh` and `Wq`, not the financial state transition itself |
| **Concentrated liquidity** | Could be a parameterized constant-product pool | Separate element because it introduces range-specific position state, tick activation, range exhaustion, and distinct accounting failures |
| **Rebasing versus exchange-rate shares** | Both represent accrued value | Separate elements because one changes nominal balances and the other changes claim value; integration failures differ |
| **Partial liquidation** | Looks like a separate solvency mechanism | An isotope of `Li`, parameterized by close factor or amount |
| **Utilization kink** | Recurrent in lenders | A rate-model parameter of `Pl` or `Im`, not a standalone obligation |
| **Flash loan** | Could be described as ordinary uncollateralized credit | A catalyst because repayment is transaction-atomic and no enduring borrower obligation remains |
| **Proxy upgradeability** | Looks like generic software infrastructure | A control element because it changes the reachable state machine and introduces storage, initialization, and malicious-upgrade failures |
| **Withdrawal queue and ERC-7540** | Easy to collapse into one | `Wq` is the financial mechanism; ERC-7540 is an interface isotope/bond for request-and-claim interaction |
| **Insurance fund** | Seems obviously distinct | Provisional: a passive reserve may be only a balance-sheet parameter unless its accumulation, depletion, and payout rule form a distinct recurring state machine |

## Prior art, corpus, and extraction method

### What previous taxonomies solved

| Prior work | Contribution | Where it stops |
|---|---|---|
| **Werner et al., DeFi SoK** | Separates major DeFi protocol types and technical versus economic security; establishes primitives as a useful level of analysis | Does not derive a closed element set, substitution groups, typed bonds, or a protocol formula grammar citeturn0search0 |
| **Later DeFi SoKs** | Organize systems around liquidity pools, pegged or synthetic assets, and aggregators | Categories remain too coarse: an entire lending market or stablecoin is a category rather than a molecule citeturn0search24 |
| **Attack and exploit taxonomies** | Supply failure classes and incident evidence; one major SoK assembled 181 incidents and emphasized unsafe protocol dependencies | Usually classify attack vectors or software layers, not the normal mechanisms whose combinations created the exposure citeturn11search11 |
| **AMM design-space research** | Provides mathematical families of constant-function market makers and optimization-based analyses | Deep within pricing, but does not integrate credit, governance, bridges, access, accounting, or off-chain claims citeturn0search2turn0search6 |
| **Formal lending models** | Formalize pool accounting, deposits, borrowing, interest, collateral, and liquidation | Usually model one protocol class and hold oracle, governance, and cross-protocol composition largely exogenous citeturn0search7turn0search3 |
| **Formal composability work** | Demonstrates that protocol behavior can be composed algebraically or process-theoretically | Lacks a stable empirical vocabulary of recurring deployed mechanisms citeturn0search23 |
| **MEV and order-flow literature** | Shows that transaction ordering, private order flow, auctions, and solver competition are part of protocol economics, not incidental plumbing | Does not cover the full financial state machine or loss-allocation system citeturn13search0turn13search33turn13search13 |
| **“Money legos”** | Popularized permissionless protocol-level composability | The blocks are whole brands or applications, are not irreducible, and provide no closed vocabulary or forbidden-bond rules citeturn1search0turn1search8 |
| **ACTUS** | Defines financial contract types through algorithmic cash-flow patterns, offering the strongest TradFi precedent for molecular decomposition | Does not model permissionless calls, endogenous oracle state, MEV, governance upgrades, flash atomicity, or cross-chain verification citeturn1search2turn1search26 |
| **FIBO** | Supplies a machine-readable ontology of financial entities, contracts, roles, and relations | Primarily semantic rather than an irreducible state-transition catalogue citeturn1search3turn1search7 |
| **ISO 20022** | Provides standardized financial messages and a shared data dictionary | Standardizes communication, not economic mechanisms or solvency bonds citeturn13search3turn13search7turn13search31 |
| **Payoff replication** | Demonstrates that complex derivative payoffs can be decomposed into simpler claims, options, and dynamic trading strategies | Decomposes terminal cash flows, not necessarily custody, governance, execution ordering, oracle dependence, or insolvency handling citeturn13search22turn13search26 |
| **Token standards** | ERC-4626 expresses tokenized vault shares; ERC-7540 adds asynchronous request-and-claim flows; ERC-7575 generalizes multi-asset vault relationships | Standards are predominantly interface bonds and notation. The underlying share or queue state transition remains the element citeturn2search1turn2search5turn2search13 |
| **Risk-parameter frameworks** | Encode implicit taxonomies through LTVs, liquidation thresholds, caps, debt ceilings, oracle choice, interest-rate models, and market isolation | Optimize or audit known protocol structures rather than deriving a closed primitive set citeturn8search0turn8search12turn8search7turn8search23turn8search1 |

**Closest prior taxonomy:** ACTUS is closest in formal spirit because it represents financial products as algorithmic contract types; Werner et al. is the closest DeFi-native foundation. Neither supplies all four features required here: an empirically closed element vocabulary, role-substitution groups, typed bonding laws, and explicit residue.

Traditional finance has therefore solved part of the problem. It has mature theories of cash-flow types, payoff replication, contract semantics, and messaging. DeFi adds mechanisms with no close TradFi analogue at the same abstraction level: transaction-atomic uncollateralized liquidity, permissionless synchronous calls, endogenous on-chain price formation used by other contracts, public transaction-order competition, tokenized governance over executable code, cryptographic cross-domain message verification, and composability with no bilateral integration agreement. MEV research and intent-market literature show why execution ordering and order-flow allocation must be represented alongside ordinary financial payoffs. citeturn13search0turn13search33turn15search0turn15search2

The “protocol sink” phrase did not resolve in this sweep to a stable canonical paper or specification comparable to the money-legos literature. It is therefore treated as an informal observation that some protocols absorb liquidity or dependencies, not as prior taxonomic authority.

### Corpus construction

The corpus contains **101 protocol-version units**, rather than 101 brands. Version units are counted separately because version changes often provide the best quasi-experimental evidence for element boundaries. It contains 72 EVM units, 21 explicitly non-EVM units—six Solana, seven Cosmos-family, three Move, three Cardano eUTxO, and two Bitcoin-related—and eight multi-environment units.

The non-EVM subset includes Orca, Raydium, OpenBook, Drift, Mango and Solend on Solana; Osmosis, Mars and Kujira in Cosmos environments; Cetus, NAVI and Thala in Move environments; Minswap, Liqwid and Indigo on Cardano; and Sovryn and ALEX in Bitcoin-linked environments. Their documentation demonstrates that concentrated liquidity, lending, collateralized synthetic assets, order books, and liquidation queues can be implemented under account-based, object-based, app-chain, and eUTxO execution models. This supports treating those mechanisms as execution-model-independent, while atomicity, sequencing, and interface details remain reaction conditions. citeturn12search25turn12search2turn12search15turn12search28turn12search22turn12search33

The corpus deliberately includes retired and failed systems: Maker Single-Collateral Dai, Yield Protocol, Euler v1, Rari Fuse, bZx, Terra/Anchor, Iron Finance, Beanstalk, Mango v3, Nomad, Ronin and Poly Network. It also includes permissioned credit, RWA, and privacy systems because those are where off-chain truth, legal transfer restrictions, asynchronous redemption, and selective disclosure test the table’s boundary.

Evidence was graded implicitly as follows: primary protocol documentation, specifications, whitepapers, interfaces, and repositories were preferred; audits and official postmortems were used for implementation and failure claims; academic and incident databases were used for normalization and cross-protocol comparison. A historical version was not allowed to create a new element where its mechanism could not be verified beyond a marketing description. Documentation is strongest for canonical AMMs, lenders, oracles, cross-chain standards, and liquid staking; it is thinner for early undercollateralized credit, privacy-compliance hybrids, and some discontinued option vaults.

Several documentation–implementation tensions materially affected classification. Uniswap v4 documentation describes hooks as supporting dynamic fees, TWAMMs, customized accounting, and other extensions; that breadth is evidence that a hook is a mechanism container rather than one atomic financial primitive. Compound III’s single-base-asset architecture changes the lending molecule even though the brand and broad category remain “Compound.” Lido’s withdrawal system separates request from later claim and represents queue positions as NFTs. LayerZero’s OFT specification distinguishes message verification from debit/credit forms such as burn/mint and lock/unlock. citeturn4search0turn5search1turn6search10turn15search1turn15search3

### Changes to the seed vocabulary

| Seed area | Change |
|---|---|
| **Constant sum** | Not a core element. Pure constant sum did not meet recurrence and safe standalone-function tests; it survives as a limiting isotope within `St`. |
| **Weighted pools** | Added `Wg`; the seed omitted a repeatedly deployed invariant with a distinct weight-transition failure family. |
| **Concentrated liquidity** | Retained and promoted to a separate element rather than a constant-product isotope. |
| **Hooks** | Demoted to interface/bond grammar. A deployed hook is classified by the mechanism it instantiates. |
| **Dynamic fees and fee tiers** | Demoted to parameters unless the fee controller has independent state, recurrence, and failure semantics. |
| **Bonding curve** | Provisional `Bc`; primary-issuance semantics may justify separation from AMMs, but evidence is not yet sufficient for stable core status. |
| **TWAMM and Dutch auction** | Provisional `Tw` and `Da`; both may be execution-policy isotopes rather than elements. |
| **Kinked rates and utilization targeting** | Parameters of `Pl` or `Im`, not elements. |
| **Health factor** | Derived solvency metric inside `Ct`, not an element. |
| **Partial liquidation** | Isotope of `Li`. |
| **Auction liquidation** | `Li{auction}` in core formulas; Dutch-auction mechanics remain provisional `Da`. |
| **Insurance fund** | Provisional `Ir`; slashable or explicitly staked backstop capital is core `Bs`. |
| **Bad-debt accounting** | Represented by `Sl` where loss is allocated to a claim class; bookkeeping alone is not an element. |
| **Options vault** | A molecule—typically `Sh+Ep+Op+(Ba|Rf)`—not an element. |
| **Interest-rate swap** | Not promoted: current examples can be expressed through fixed-term claims, yield separation, and option-like contingent settlement; recurrence evidence for a unique state machine is thin. |
| **Push, pull, medianizer** | Merged as isotopes of external oracle `Ex`; delivery changes trust and latency attributes but not the core imported-truth transition. Chainlink and Pyth illustrate materially different push and pull implementations. citeturn7search1turn7search13 |
| **Proof of reserve** | Merged into `At`, which covers reserve and NAV attestations. |
| **ZK state proof** | Provisional `Zk`; often infrastructure or a trust/interface bond rather than a finance element. |
| **Cooldown, lockup, vesting, checkpointing** | Usually parameters or subroutines of `Ep`, `Sr`, `Em`, or governance, unless future evidence establishes independent recurrence and failure semantics. |
| **Vote escrow, gauges, bribes** | The allocation bundle is provisional `Ve`; emissions remain `Em`. |
| **Points and fee switch** | Accounting or distribution parameters, not atomic mechanisms. |
| **Parameter controller and veto** | Represented through `Tg`, `Up`, `Gp`, or a parameter isotope rather than separate core elements. |
| **MEV redistribution** | A payout rule attached to `Ba`, `In`, `Ag`, `Em`, or `Sl`; not independently atomic in the present corpus. |
| **Atomic composability** | Reaction condition, not an element. |
| **Bridging** | Split into message verification `Xm` and asset conservation/transfer `Xf`; their failures and trust assumptions differ. |
| **Peg arbitrage** | A market reaction, not a protocol state-transition element. |
| **Collateral-ratio and rate targeting** | Parameters or controllers attached to `Ct`, `Ix`, `Pl`, `Cd`, or `As`. |
| **Allowlists, KYC hooks, permissioned pools** | Merged as `Aw`; token-level persistent credential enforcement remains provisional `Kg`. |
| **Shielded balances and selective disclosure** | Split into `Sb` and `Sd` because ownership privacy and policy-proof disclosure require different states and fail differently. |

## Atomic element table

The table contains **48 core elements**:

\[
3+5+4+5+5+5+4+3+4+4+3+3=48
\]

The terms are not over-split because fee tiers, rate curves, close factors, hook interfaces, oracle delivery modes, and token standards remain parameters or bonds. They are not under-split because concentrated versus global liquidity, rebasing versus exchange-rate accounting, message verification versus asset conservation, and privacy versus selective disclosure have distinct state representations and failure signatures.

![Visual layout of the 48 core DeFi elements](sandbox:/mnt/data/defi_periodic_table_visual.png)

The “first verified” field means the earliest example established in this corpus, not an unqualified priority claim. Earlier obscure deployments may revise dates without changing IDs.

**Claims, pricing, and execution**

The pricing family is grounded in the constant-function literature and canonical Curve, Balancer, Uniswap and DODO-style designs. Curve’s stable invariant explicitly combines constant-sum-like behavior near parity with constant-product protection away from parity; Balancer exposes weighted and stable pool math; concentrated liquidity introduces position-specific ranges; CoW documents signed intents, solver competition, and combinatorial batch auctions. citeturn0search2turn3search11turn3search2turn4search0turn15search0turn15search2

| ID | Symbol and mechanism | Group / period | First verified and canonical implementations | Required counterparts and trust | Common parameters | Incompatibility, failure, maturity |
|---|---|---|---|---|---|---|
| E001 | **Sh — pro-rata share accounting:** shares represent a proportional pool claim | Claims / P0 | Uniswap v1; Yearn; ERC-4626 vaults | Asset custody and correct total-assets accounting | Virtual shares, initial offset, rounding direction | Donation/inflation attack, rounding extraction; mature |
| E002 | **Ix — index-based accrual:** global exchange-rate or debt index changes claim value | Claims / P0 | Compound cTokens; Aave liquidity and borrow indexes | Correct accrual timing and rate model | Per-block/second rate, reserve factor, precision | Stale index, desynchronization, rounding drift; mature |
| E003 | **Rb — rebasing accounting:** nominal balances change through global scaling | Claims / P0 | AMPL; Lido stETH | Supply controller, backing ledger, often oracle quorum | Cadence, scaling precision, oracle quorum | Breaks balance-invariance assumptions; integration-sensitive |
| E004 | **Cp — constant-product invariant** | Pool pricing / P1 | Uniswap v1/v2; SushiSwap; Minswap | Custody, LP claims, arbitrage and market depth | Fee commonly 1–100 bp | Sandwiching, reserve manipulation, toxic flow; mature |
| E005 | **Wg — weighted-geometric invariant** | Pool pricing / P1 | Balancer Weighted Pools; Beethoven X | Multi-asset custody and weight controller | Asset weights, swap fee | Weight-transition arbitrage, numerical edge cases; mature |
| E006 | **St — stable-hybrid invariant** | Pool pricing / P1 | Curve StableSwap; Balancer Stable; Astroport | Correlated assets, amplification governance | Amplification, fee, off-peg thresholds | Inventory concentration after depeg; mature |
| E007 | **Cl — concentrated liquidity** | Pool pricing / P1 | Uniswap v3; Orca Whirlpools; Cetus; Osmosis CL | Tick/range state, position claims, active-liquidity accounting | Tick spacing, range, fee tier | Range exhaustion, JIT/adverse selection, tick bugs; mature |
| E008 | **Pm — proactive or oracle-priced inventory curve** | Pool pricing / P1 | DODO PMM; related oracle-priced pools | External reference price and calibrated inventory response | Inventory coefficient, freshness, fee | Oracle manipulation and inventory imbalance; established |
| E009 | **Ob — on-chain order book** | Execution / P1 | EtherDelta; Serum/OpenBook; dYdX v4 | Sequencing, cancellation, settlement and keeper liveness | Tick, lot, maker/taker fee | Stale orders, priority manipulation, liveness; mature where execution permits |
| E010 | **Rf — request for quote** | Execution / P1 | 0x RFQ; Hashflow | Signatures, maker inventory and quote availability | Expiry, slippage, maker access | Replay/domain errors, maker censorship; established |
| E011 | **Ba — batch-auction clearing** | Execution / P2 | Gnosis Protocol; CoW Protocol | Commitments, solver liveness, clearing verification | Batch length, surplus rule, solver bond | Solver collusion, invalid clearing, liveness; established |
| E012 | **In — intent and solver execution** | Execution / P4 | CoW Protocol; 1inch Fusion; UniswapX | Signed outcome constraints, solver competition and fallback | Deadline, min-out, exclusivity, bond | Solver censorship/collusion, replay, weak fallback; emerging-mature |

**Credit, solvency, and risk transfer**

Compound documentation exposes exchange-rate claims, utilization-dependent interest and liquidation; Compound III changes the molecule to one borrowable base asset. Aave v3 adds isolation, while Morpho Blue parameterizes isolated markets by loan asset, collateral, oracle, interest model and LLTV. Maker separates debt creation, liquidation auctions and peg-swap operations. citeturn5search0turn5search24turn5search18turn5search1turn3search3turn8search7turn8search23turn8search25turn5search13turn5search2turn5search3

| ID | Symbol and mechanism | Group / period | First verified and canonical implementations | Required counterparts and trust | Common parameters | Incompatibility, failure, maturity |
|---|---|---|---|---|---|---|
| E013 | **Pl — pooled lending** | Credit / P3 | Compound v2; Aave; Solend | Claims/index, truth, collateral threshold, liquidation and exit liquidity | LTV 0–90%; kink often 70–90%; reserve factor | Bad debt, run, rate mispricing; mature |
| E014 | **Im — isolated lending market** | Credit / P3 | Kashi; Rari Fuse; Morpho Blue; Euler v2 | Per-market oracle, LLTV, rate model and liquidation | LLTV, caps, oracle/IRM addresses | Thin-market insolvency, malicious configuration; mature |
| E015 | **Cd — collateralized-debt minting** | Credit / P3 | Maker SCD; Maker MCD; Liquity; Indigo | Debt ledger, truth, solvency and peg mechanism | Collateral ratio, ceiling, stability fee | Undercollateralization, peg loss, bad-debt failure; mature |
| E016 | **Uc — undercollateralized credit** | Credit / P3 | TrueFi; Maple; Goldfinch | Identity, underwriting, legal recourse, attestation, first-loss capital | Limit, tenor, covenant, first-loss share | Fraud, default, correlated underwriting; established, off-chain dependent |
| E017 | **Ft — fixed-term debt** | Credit / P3 | Yield Protocol; Notional; Term Finance | Maturity state, rollover liquidity, collateral where applicable | Maturity, discount factor, collateral ratio | Rollover cliff and maturity shortfall; established |
| E018 | **Ct — collateral-threshold solvency test** | Solvency / P3 | Maker; Compound; Aave; Morpho | Position ledger and sufficiently robust truth source | LTV, liquidation threshold, haircut, concentration cap | False solvency from stale prices or correlation; mature |
| E019 | **Li — incentivized liquidation** | Solvency / P3 | Maker; Compound; Aave | `Ct`, truth, liquidator access and executable collateral market | Bonus often 3–15%, close factor, auction duration | Cascade, zero/underpriced bids, griefing; mature |
| E020 | **Ad — auto-deleveraging** | Solvency / P3 | Perpetual DEX designs | Position ranking, mark price and exhausted buffers | Trigger, rank score, haircut | Unexpected winner haircut and ranking manipulation; established |
| E021 | **Sl — socialized-loss allocation** | Solvency / P3 | Derivatives and lending deficit systems | Explicit eligible claim class and bad-debt ledger | Haircut base, recovery waterfall | Contagion, runs, hidden seniority; hazardous but recurrent |
| E022 | **Bs — staked backstop** | Solvency / P3 | Aave Safety Module; first-loss staking variants | Trigger, liquid recapitalization asset, governance execution | Slash cap, cooldown, coverage target | Reflexive backstop collapse, slow activation; established |
| E023 | **Pf — perpetual funding transfer** | Risk transfer / P3 | Synthetix/Perpetual Protocol generation; dYdX; GMX | Index truth, position accounting and terminal loss path | Interval, clamp, skew coefficient | Funding divergence, index manipulation, one-sided skew; mature |
| E024 | **Op — option payoff** | Risk transfer / P3 | Opyn; Hegic; Lyra | Settlement truth, maturity and writer collateral | Strike, expiry, style, collateralization | Settlement error, undercollateralization, short-gamma loss; established |
| E025 | **Tr — tranche waterfall** | Risk transfer / P3 | BarnBridge; Centrifuge and credit pools | Claims accounting and unambiguous loss event | Attachment/detachment, senior ratio, hurdle | Junior exhaustion, correlation break, false seniority; established |
| E026 | **Cv — mutual cover pool** | Risk transfer / P3 | Nexus Mutual; InsurAce | Claim event, adjudication or oracle, capital pool | Limit, premium, deductible, voting period | Correlated insolvency, governance capture, exclusion ambiguity; established |
| E027 | **Py — principal/yield separation** | Risk transfer / P3 | Element; Pendle | Yield-bearing claim, maturity and redemption | Expiry, implied yield, yield index | Adapter failure, negative-yield edge cases, maturity liquidity; mature |

**Truth, time, incentives, and control**

Oracle delivery modes are kept as isotopes of `Ex`: Chainlink-style push feeds use heartbeat and deviation conditions, while Pyth uses signed pull updates delivered when needed. Optimistic assertions and reserve/NAV attestations remain separate because they introduce dispute games and off-chain institutional truth respectively. Lido’s rebase and withdrawal queue demonstrate why accounting and exit must also be separated. citeturn7search1turn7search13turn7search11turn6search7turn6search10turn6search22

| ID | Symbol and mechanism | Group / period | First verified and canonical implementations | Required counterparts and trust | Common parameters | Incompatibility, failure, maturity |
|---|---|---|---|---|---|---|
| E028 | **Ex — external data oracle** | Truth / P2 | Maker medianizer; Chainlink; Pyth | Reporter/signature set, transport and consumer freshness checks | Heartbeat, deviation, confidence interval | Stale report, signer compromise, decimal error, liveness; mature |
| E029 | **Tp — on-chain time-weighted price** | Truth / P2 | Uniswap v2/v3; Osmosis TWAP | Sufficient market depth and observations over time | Window, observation cardinality | Multi-block manipulation, stale observation, liquidity migration; mature |
| E030 | **Oa — optimistic assertion oracle** | Truth / P2 | UMA Optimistic Oracle | Bond, dispute window, challenger incentives and escalation | Bond, liveness period, dispute resolver | Unchallenged false assertion, griefing, governance capture; established |
| E031 | **At — reserve or NAV attestation** | Truth / P2 | Proof-of-reserve and tokenized-RWA systems | Custodian, auditor, legal ownership and update process | Cadence, coverage ratio, signer quorum | False/stale attestation, encumbrance, reserve mismatch; trust-heavy |
| E032 | **Sr — streaming or dripping accrual** | Time / P2 | Sablier and fee-streaming contracts | Escrowed balance and timestamp semantics | Start/end, cliff, cancelability | Boundary manipulation and cancellation ambiguity; mature |
| E033 | **Ep — epoch-gated transition** | Time / P2 | PoolTogether periods; option-vault and credit epochs | Snapshot correctness and rollover liveness | Duration, cutoff, keeper | Boundary gaming, stale rollover, stranded requests; mature |
| E034 | **Wq — asynchronous withdrawal queue** | Time / P2 | Lido WithdrawalQueue; ERC-7540 vaults | Pending-claim accounting, ordering and future asset availability | FIFO/priority, buffer, delay | Queue run, unfair ordering, stuck claims, NAV mismatch; emerging-mature |
| E035 | **Em — protocol-funded emissions** | Incentives / P2 | Synthetix; Compound; Curve gauges | Measurement, checkpointing and distribution ledger | Rate, cap, decay, allocation weights | Mercenary liquidity, governance capture, reflexive dilution; mature but often decaying |
| E036 | **Tg — delayed-governance execution** | Control / P4 | Compound Timelock; OpenZeppelin-derived systems | Authorization, monitoring and cancellation | Delay, proposal threshold | Queued malicious action, bypass, inadequate delay; mature |
| E037 | **Up — mutable implementation proxy** | Control / P4 | Compound Unitroller; transparent/UUPS patterns | Upgrade authority, storage compatibility and initialization | Admin model, delay, allowlist | Malicious upgrade, storage collision, initializer bug; trust-expanding |
| E038 | **Gp — emergency guardian or pause** | Control / P4 | Maker emergency controls; Compound Pause Guardian; Aave | Bounded guardian key and recovery path | Scope, expiry, threshold, unpause delay | Censorship, key compromise, incomplete coverage; mature |

Compound’s governance stack illustrates why `Tg`, `Up`, and `Gp` are not one “governance” element: a timelock delays action, a proxy changes code, and a guardian suppresses transitions. Each changes different reachable states and has a distinct failure signature. citeturn5search8

**Routing, cross-domain state, stability, and access**

LayerZero’s documentation explicitly separates message transport from token debit/credit behavior and permits burn/mint, lock/unlock, and adapter forms. That is direct evidence for splitting `Xm` from `Xf`. Privacy similarly splits ownership-obscuring state from selective proof disclosure. citeturn15search1turn15search3turn15search8turn10search24turn10search13

| ID | Symbol and mechanism | Group / period | First verified and canonical implementations | Required counterparts and trust | Common parameters | Incompatibility, failure, maturity |
|---|---|---|---|---|---|---|
| E039 | **Ag — aggregation and routing** | Routing / P1 | 1inch; Matcha; Paraswap | Standardized venue and asset interfaces | Route splits, gas objective, allowed venues | Malicious adapter, stale quote, approval loss; mature catalyst-like mechanism |
| E040 | **Fl — atomic flash liquidity** | Routing / P1 | Aave v1; Uniswap flash swaps; Balancer | Atomic rollback, callback authentication, source liquidity | Fee commonly 0–10 bp; pool limit | Amplifies oracle/governance attacks; callback defects; mature catalyst |
| E041 | **Xm — cross-domain message verification** | Cross-domain / P4 | IBC; LayerZero; Wormhole | Source finality, verifier/light-client or security-stack assumptions | Confirmations, quorum, timeout, replay domain | Forgery, replay, reorg, verifier compromise; heterogeneous risk |
| E042 | **Xf — cross-domain asset transfer** | Cross-domain / P4 | WBTC; canonical bridges; OFT; IBC assets | `Xm` or custodian plus supply accounting and mint authority | Caps, finality delay, mint authority, rate limit | Unbacked mint, stuck escrow, fragmented canonicality; high-risk |
| E043 | **Rd — direct redemption right** | Stability / P3 | Liquity; tokenized-fund redemption systems | Accessible backing ledger and settlement route | Fee curve, lot, delay, pro-rata/targeted form | Run, adverse collateral selection, redemption freeze; mature |
| E044 | **Ps — peg-swap module** | Stability / P3 | Maker PSM/LitePSM; related stability modules | Reserve custody and mint/burn authority | In/out fee, exposure ceiling | Reserve depeg, freeze, concentration; mature |
| E045 | **As — algorithmic supply adjustment** | Stability / P3 | Basis Cash/ESD generation; Terra-style systems | Price measurement, expectations and supply controller | Epoch, expansion/contraction, coupons | Death spiral, bank run, junior-token hyperinflation; radioactive |
| E046 | **Aw — permission or identity gate** | Access / P2 | Permissioned credit/RWA pools; Aave Arc | Credential registry, administrator and legal policy | Expiry, jurisdiction, role and admin threshold | Bypass, stale eligibility, censoring administrator; trust-expanding |
| E047 | **Sb — shielded-balance state** | Privacy / P2 | Tornado-style pools; Railgun | Commitment tree, nullifiers and proof verifier | Anonymity set, tree, denomination, proof system | Linkability, proof defect, relayer censorship; constrained |
| E048 | **Sd — selective-disclosure proof** | Privacy / P2 | ZK credential and privacy-compliance systems | Credential issuer, proof verifier and revocation semantics | Schema, expiry, revocation and policy | Metadata leakage, false policy assurance, revocation failure; emerging |

### Provisional candidates outside the 48-element closure

| ID | Symbol | Candidate | Why it is not yet core |
|---|---|---|---|
| P001 | **Bc** | Bonding-curve issuance | May be a primary-issuance semantic distinct from AMMs, but independent recurrence and boundary evidence remain incomplete |
| P002 | **Tw** | Time-weighted AMM execution | May decompose into an AMM plus time/epoch execution policy |
| P003 | **Da** | Dutch-auction descent | May be an auction isotope; Maker’s Liquidation 2.0 is canonical evidence but not alone sufficient for core status citeturn5search2 |
| P004 | **Cg** | Credit delegation | May be a permission edge attached to `Pl` rather than a distinct obligation |
| P005 | **Ir** | Insurance reserve fund | A passive reserve may lack a distinct state transition; needs separation from `Bs` and `Sl` |
| P006 | **Zk** | Verifiable state proof | Often generic infrastructure or a trust/interface bond |
| P007 | **Ve** | Vote-escrow allocation | Appears decomposable into lock/epoch, checkpoint, emissions and governance |
| P008 | **Kg** | Credential-gated transfer | May be a token-level isotope of `Aw`; evidence for distinct failure semantics is still thin |

## Bonding laws and reaction conditions

### Valence

Valence is represented as a typed required-edge set:

\[
V(e)=\{V_i(e),V_e(e),V_t(e)\}
\]

where \(V_i\) contains required interfaces, \(V_e\) contains required economic counterpart mechanisms, and \(V_t\) contains required trust relations. A pooled lender has higher valence than a constant-product pool because it requires claim accounting, truth, collateral testing, liquidation, loss allocation, exit liquidity, and usually mutable risk governance.

A protocol formula is not valid merely because all listed contracts can call one another. Every required interface, economic, and trust edge must be satisfied separately.

### Required bonds

| Rule | Implication | Reason |
|---|---|---|
| **Leveraged obligation rule** | `(Pl | Im | Cd | Pf | Op) → (Ex | Tp | At) + Ct + (Li | Ad | Sl | Bs)` | Any obligation whose value can fall below debt needs truth, a solvency test, and a terminal loss path |
| **Pooled-claim rule** | `Pl → (Sh | Ix) + exit-liquidity` | Lenders need a measurable claim and a withdrawal or queue path |
| **Undercollateralized-credit rule** | `Uc → Aw + At + (Bs | Tr)` | Without excess collateral, identity, underwriting information, legal recourse and first loss become constitutive |
| **Perpetual rule** | `Pf → Ex + Ct + Li + (Ad | Sl | Bs)` | Funding alone cannot terminate insolvency |
| **Yield-separation rule** | `Py → (Sh | Ix | Rb) + Ep + Rd` | Principal and yield cannot be split without an underlying accrual index, maturity and settlement |
| **Tranche rule** | `Tr → explicit loss event + non-overlapping seniority` | A tranche without an enforceable waterfall is merely a label |
| **Stable-liability rule** | `Cd → Rd | Ps | collateral-liquidation-capacity` | A minted stable liability needs a credible contraction or redemption route |
| **Cross-domain asset rule** | `Xf → Xm | named-custodian` | Remote mint or release must be authorized either cryptographically or institutionally |
| **Supply-conservation rule** | `Xf → debit(source)=credit(destination)` | Lock/mint and burn/mint isotopes must preserve the relevant global claim invariant; OFT documentation makes this debit/credit separation explicit citeturn15search1turn15search8 |
| **Shielded-state rule** | `Sb → proof-verifier + nullifier-set` | Privacy without anti-double-spend state is not transferable value |
| **Selective-disclosure rule** | `Sd → credential/commitment source + verifier + revocation semantics` | The proof must bind to an authoritative, current policy statement |
| **Intent rule** | `In → signed constraints + settlement verifier + solver/fallback` | An intent without enforceable bounds is discretionary delegation |
| **External-truth rule** | `Ex → freshness validation`, with `Gp` strongly preferred for high-value obligations | Oracle delivery does not itself guarantee that consumers reject stale or invalid values |
| **Asynchronous-asset rule** | `illiquid backing → Wq | bounded liquidity reserve` | Delayed underlying settlement cannot safely support unlimited synchronous exit |
| **Upgradeable-value rule** | `Up → Tg | bounded emergency process` | High-value code mutation should be observable before execution or tightly limited during emergencies |
| **Permission-persistence rule** | `Aw → transfer-time enforcement` when eligibility follows the holder | Entry gating alone is insufficient where legal restrictions must survive transfer |

### Forbidden or empirically unstable bonds

| Combination | Classification | Evidence and mechanism |
|---|---|---|
| `Fl + manipulable Cp/Cl price + Pl/Cd` | Unstable to forbidden | Atomic liquidity can move a thin spot price and immediately borrow against the distorted value. Oracle-manipulation studies and the Mango case show that protocols can behave as coded while accepting economically invalid truth. citeturn14search1turn14search9 |
| `As + reflexive junior token`, without hard redemption or exogenous capital | Structurally unstable | The stable liability’s contraction capacity disappears when the junior token falls, creating a run and dilution loop. Terra’s May 2022 collapse is the canonical large-scale example. citeturn14search15turn14search27 |
| Protocol-issued token used as collateral, oracle market, and backstop | Highly reflexive | The same confidence shock simultaneously reduces collateral, market depth and recapitalization capacity |
| `Rb → ledger assuming balance invariance` | Interface-forbidden without an adapter | Unrecorded balance changes invalidate internal accounting; Balancer explicitly restricts incompatible token forms in its Vault model. citeturn3search17 |
| Illiquid backing plus uncapped instant par redemption | Economically unstable | The liability promises a settlement speed the assets cannot provide |
| High leverage plus thin liquidation market plus slow truth/finality | Environmentally unstable | Positions can gap beyond executable liquidation depth before the protocol reacts |
| `Aw` at entry plus unrestricted bearer transfer | Trust-invalid | Ineligible parties can acquire claims after the initial check |
| Flash-borrowed voting power plus immediate governance execution | Trust-forbidden | Governance power can be acquired and exercised within one atomic transaction, as the Beanstalk pattern demonstrated |
| Cross-domain mint without independent verification and supply accounting | Catastrophic | A forged or accepted-invalid message produces an unbacked remote claim; bridge incidents repeatedly exhibit this failure family |
| Short-volatility option vault without caps, collateral and robust auction settlement | Tail-unstable | The vault combines convex liabilities with potentially discontinuous collateral needs |
| Oracle-priced pool with stale reference price and unrestricted inventory | Unstable | Traders can exhaust mispriced inventory before reference updates |
| Shared collateral across otherwise “isolated” markets | Invalid isolation bond | Contagion escapes the advertised market boundary |
| Upgrade proxy with immediate single-key control | Trust-unstable | Correct financial elements remain exposed to arbitrary code replacement |
| Passive protocol-token insurance reserve backing protocol-token collateral | Reflexive backstop | The reserve loses value precisely when needed |

The distinction between defective elements and invalid bonds is crucial. Euler v1’s 2023 exploit arose from a missing health/liquidity check in a newly introduced donation transition, making it principally a defective implementation instance. Mango’s loss instead arose from a valid oracle, margin and borrowing system connected to a manipulable thin market, making it principally an invalid economic bond. citeturn14search20turn14search4turn14search1

### Catalysts

| Catalyst | What it enables | Safety effect |
|---|---|---|
| **Fl — flash liquidity** | Atomic arbitrage, collateral swap, refinancing, self-liquidation, governance acquisition and price movement | Improves capital efficiency but removes capital scarcity as an attack barrier |
| **Ag — routing** | Multi-venue price discovery and liquidity access | Reduces local slippage while expanding adapter, approval and dependency surface |
| **Xm — messaging** | Remote state transitions | Enables cross-domain compounds but introduces finality and verifier trust |
| **Solver competition attached to In/Ba** | Search over routes, inventory and coincidence of wants | Can internalize MEV and improve execution, but creates liveness, collusion and order-flow concentration risks; CoW’s system uses signed intents, batches and bonded competing solvers. citeturn15search0turn15search7turn15search13 |

### Reaction conditions

A molecule is stable only within an environmental operating range:

| Condition | Mechanisms most affected | Stability question |
|---|---|---|
| **Block time and finality** | `Ob`, `Li`, `Xm`, `Xf`, `In` | Can cancellation, liquidation or remote settlement finish before value changes materially? |
| **Mempool and MEV regime** | `Cp`, `Cl`, `Ob`, `Ba`, `In`, `Fl` | Can ordering or private flow create extractable value beyond tolerated bounds? |
| **Oracle latency and confidence** | `Pl`, `Cd`, `Pf`, `Pm`, `Ct` | Is the value current relative to volatility and liquidation time? |
| **Executable market depth** | `Li`, `Rd`, `Ps`, `Ct` | Can collateral actually be sold near its marked value? |
| **Gas and congestion** | `Li`, `Oa`, `Ep`, `Wq`, governance | Can required actors afford to challenge, settle or roll over? |
| **Withdrawal settlement cycle** | `Wq`, RWA, liquid staking | Does queue duration match backing-asset liquidity? |
| **Validator or operator concentration** | staking, app-chains, `Xm` | Can one group censor, reorder, attest or halt? |
| **Bridge verification latency** | `Xm`, `Xf`, cross-chain credit | Is remote state final before credit or minting becomes available? |
| **Governance reaction speed** | `Tg`, `Gp`, `Up` | Is control fast enough for emergencies but slow enough for oversight? |
| **Legal enforceability** | `Uc`, `At`, `Aw`, RWA claims | Does the on-chain claim correspond to an enforceable off-chain asset and priority? |

Maker’s Black Thursday illustrates an environmental excursion: congestion and gas-market conditions impaired liquidation participation even though the broad CDP and auction mechanisms were valid. That is a reaction-condition failure, though auction configuration and market design also contributed. The attack-taxonomy literature similarly finds that unsafe dependencies and environmental assumptions are not reducible to isolated coding bugs. citeturn11search11

### Reflexivity

A reflexive bond exists where a protocol’s output materially determines one of its own solvency inputs:

\[
\text{liability output}\rightarrow
\text{market price or collateral value}\rightarrow
\text{borrowing, redemption, or backing capacity}
\rightarrow\text{liability output}
\]

The most dangerous pattern is a triple loop in which the protocol-issued token supplies collateral value, market liquidity, and insurance capital simultaneously. A confidence shock then impairs all three defenses at once.

The table treats reflexivity as the strongest cross-family warning signal, but “primary predictor” remains a research hypothesis rather than an established universal theorem. Terra supports the hypothesis at system scale; Mango supports the narrower proposition that thin endogenous or closely connected markets are unsafe inputs to shared borrowing capacity. citeturn14search15turn14search1turn14search17

## Molecular decompositions and discriminative tests

### Notation specification

| Notation | Meaning |
|---|---|
| `Protocol@v` | Named protocol and version |
| `A+B` | Elements share a state machine, balance sheet, or settlement invariant |
| `A||B` | Mixture or meta-protocol with separable component balance sheets |
| `A*` | Catalyst; used in execution but absent from the terminal balance sheet |
| `A{k=v}` | Isotope or parameterization |
| `A?` | Optional element |
| `A|B` | Alternative mechanism at one role boundary |
| `A↺` | Reflexive economic feedback |
| `A —i→ B` | Interface bond |
| `A —e→ B` | Economic bond |
| `A —t→ B` | Trust bond |

A complete machine formula should include four layers:

\[
\text{Protocol@version}
=
\{\text{elements and parameters}\}
+
\{\text{typed bonds}\}
+
\{\text{reaction conditions}\}
+
\{\text{residue}\}
\]

The short formulas below omit obvious token-transfer interfaces for readability. The prose and residue fields restore the most material omitted information.

### Protocol formulas

| Protocol | Formula | Reading | Residue |
|---|---|---|---|
| **Uniswap v2** | `Sh+Cp{fee=30bp}+Tp+Fl*` | LP shares own a constant-product pool; cumulative prices support TWAPs; flash swaps are catalytic | Factory/pair topology, exact arithmetic and unusual-token behavior |
| **Uniswap v3** | `Sh+Cl{feeTier,tickSpacing}+Tp+Fl*` | LP claims occupy price ranges rather than the entire curve | NFT position-manager behavior and exact tick math |
| **Uniswap v4** | `Sh+Cl+Fl*+Gp? || hook-defined extensions` | Singleton concentrated-liquidity core with extension callbacks | Arbitrary hook behavior cannot be classified until the hook’s actual mechanism is known; hooks themselves are not an element citeturn4search0 |
| **Curve StableSwap** | `Sh+St{A,fee}+Tp?` | Shares back a hybrid invariant optimized for correlated assets | Metapool graph, admin-fee routing and pool-specific oracle choices citeturn3search11 |
| **Balancer v2** | `Sh+(Wg|St){weights,fee}+Ag+Fl*` | A common Vault supplies accounting, routing and flash liquidity while pools choose pricing math | Internal balances, netting and detailed token restrictions citeturn3search2turn3search17 |
| **Aave v3** | `Pl+Ix+Ct+Ex+Li+Bs+Gp+Up+Tg+Im{isolation}` | Indexed pooled credit with oracle collateral, liquidation, backstop and isolation mode | eMode, supply/borrow caps, portals and asset adapters citeturn3search3 |
| **Compound v2** | `Pl+Sh+Ix+Ct+Ex+Li+Tg+Up` | cTokens are interest-accruing pool claims; a Comptroller coordinates collateral and borrowing | Reward distribution and legacy per-market behavior citeturn5search0turn5search24turn5search8 |
| **Compound III** | `Pl+Ix+Ct+Ex+Li+Tg+Up+Im{single-base}` | One base asset is borrowable; collateral assets are not symmetric pooled borrowing markets | Base-tracking rewards and collateral-purchase implementation citeturn5search1turn5search18 |
| **Maker/Sky MCD** | `Cd+Ix+Ct+Ex+Li{auction}+Ps+Sh{DSR}+Tg+Gp+Up` | Collateralized debt mints the liability; auctions protect solvency; peg-swap and savings modules manage stability and demand | Surplus and bad-debt auctions, RWA legal structure and organizational controls citeturn5search13turn5search2turn5search3 |
| **Liquity v1** | `Cd+Ct+Ex+Li+Rd+Bs{stability-pool}+Sl?` | ETH-backed debt includes direct redemption and a depositor-funded liquidation absorber | Recovery mode, redistribution ordering and fee dynamics |
| **Morpho Blue** | `Im+Ix+Ct+Ex+Li+Sh{vaults}?` | Each immutable market binds one collateral, loan asset, oracle, LLTV and rate model; vaults optionally aggregate exposure | Market curation, adapters and curator trust citeturn8search7turn8search23turn8search25 |
| **GMX v2** | `Sh+Pm+Ex+Pf+Ct+Li+Bs?+Sl?` | Oracle-priced liquidity pools warehouse trader PnL and inventory while funding and liquidation constrain leverage | Price-impact curve, keeper network and market-specific accounting citeturn6search0 |
| **dYdX v4** | `Ob+Pf+Ex+Ct+Li+Ad+Sl+Tg` | App-chain order book and oracle-marked perpetual margin with terminal loss allocation | Validator sequencing, order propagation and chain governance |
| **Lido v2** | `Rb+Ex{oracle-quorum}+Wq+Gp+Up` | stETH rebases from oracle-reported staking balances; exits become queued claims | Beacon-chain penalties, node-operator selection and oracle committee topology citeturn6search7turn6search10turn6search22 |
| **Rocket Pool** | `Sh+Ix+Bs{operator-bond}+Ex+Wq?` | rETH appreciates through an exchange rate while node-operator capital absorbs part of validator risk | Minipool lifecycle, reward smoothing and operator social layer; current documentation describes rETH as a liquid claim that gains staking rewards over time citeturn17search4turn17search0 |
| **Pendle v2** | `Py+Ep+Rd+Sh+(St|Cl-like-yield-AMM)+Fl*` | Yield-bearing claims split into principal and yield claims and trade to maturity | Standardized-yield adapters and implied-yield curve math citeturn6search6turn6search2 |
| **Ribbon Theta Vault v2** | `Sh+Ep+Op{short-option}+(Ba|Rf)+Wq?` | Vault shares fund epochal option writing and auction/RFQ distribution | Strike selection, keeper process and strategy-specific collateral management |
| **CoW Protocol** | `In+Ba+Ag+Rf?` | Signed outcome constraints enter combinatorial batch auctions; competing solvers route or internally match orders | Solver scoring, off-chain order-flow policy and competition concentration citeturn15search0turn15search2turn15search7 |
| **UniswapX** | `In+Da?+Rf+Ag+Fl*?` | Users sign decaying-price intents and fillers source settlement liquidity | Filler exclusivity, filler reputation and cross-chain variants |
| **Radiant v2** | `Pl+Ix+Ct+Ex+Li+Xm+Xf+Em+Up+Gp` | Lending and incentive coordination rely on cross-domain messaging and OFT-style transfer assumptions | Liquidity is not truly atomic across chains; bridge, signer and governance details remain material. Radiant documentation identifies LayerZero/OFT integration. citeturn16search2turn16search9 |
| **Centrifuge RWA pool** | `Uc+Ft+Tr+Sh+At+Aw+Wq+Xm?` | Permissioned investors fund asset-backed term credit with senior/junior claims, reported NAV and asynchronous redemption | Legal ownership, servicing, bankruptcy remoteness, document covenants and court enforcement |
| **Maple pool** | `Uc+Ft+Sh+Aw+At+Bs{first-loss}+Wq` | Delegated underwriting creates institutional term loans with permissioning, information, first loss and delayed liquidity | Borrower agreements, servicing discretion, workouts and recourse; Maple interfaces explicitly expose pool-cover liquidation parameters. citeturn9search0turn16search5 |
| **Terra/Anchor before collapse** | `As+Rd{LUNA-conversion}+Ex+Pl+Ix+Em↺` | Reflexive mint/burn stability was coupled to subsidized pooled deposit demand | Confidence, exchange depth, cross-chain flows and validator halt decisions citeturn14search15turn14search27 |
| **Mango Markets v3 before exploit** | `Ob+Pf+Pl+Ct+Ex+Li+own-token-collateral↺` | Trading, perpetuals and lending shared portfolio margin while a thin MNGO market affected borrowing capacity | Cross-venue price formation, self-trading behavior and market-law constraints citeturn14search1turn14search9 |
| **Euler v1 before exploit** | `Pl+Ix+Ct+Ex+Li+Fl*+Up` | Indexed permissionless lending with collateral tests, liquidation and atomic leverage | The defective `donateToReserves` transition is implementation residue, not a valid recurring element citeturn14search20turn14search4 |

### Near-isomers

**Aave v3 and Compound III** are both recognizable pooled lenders, but their formulas are not identical.

\[
\text{Aave v3}=
Pl+Ix+Ct+Ex+Li+Bs+Gp+Up+Tg+Im_{\text{optional isolation}}
\]

\[
\text{Compound III}=
Pl+Ix+Ct+Ex+Li+Up+Tg+Im_{\text{single base}}
\]

Aave retains a multi-reserve pooled architecture with explicit isolation modes and a staked safety backstop. Compound III centers each deployment on one borrowable base asset and treats other supplied assets as collateral rather than symmetric interest-bearing borrow markets. The table therefore expresses the structural distinction without inventing “Aave” and “Compound” elements. citeturn3search3turn5search1

### Version deltas

The Uniswap lineage demonstrates element-level version evidence:

| Delta | Formula change | Interpretation |
|---|---|---|
| v1 → v2 | `Cp` retained; token-pair generality and `Tp+Fl*` added or made explicit | The pricing element remains constant product |
| v2 → v3 | `Cp → Cl` | A genuine element substitution: global fungible LP shares become range-specific positions |
| v3 → v4 | `Cl` retained; architecture moves toward singleton settlement and open hook grammar | Mostly implementation and bond changes unless an individual hook instantiates an additional element |

This is why singleton architecture and hooks should not automatically become financial elements: v4 can preserve the same concentrated-liquidity role while altering interfaces, accounting pathways, and extension possibilities. citeturn4search0

### Identical formulas and practitioner disagreement

At core resolution, Orca Whirlpools, Cetus CLMM and many Uniswap-v3 descendants can all reduce to:

\[
Sh+Cl\{fee,tickSpacing,range\}+Tp?
\]

The table says these systems are molecularly equivalent at the financial-mechanism level. Practitioners may still distinguish them by account/object ownership, transaction scheduling, keeper requirements, incentive programs, token semantics and user interfaces. Those differences are isotopes, environmental conditions or residue unless they create a new recurring state transition and failure signature. Osmosis and Cetus documentation confirms that concentrated-liquidity semantics can recur across Cosmos and Move environments even though implementation and state-access models differ. citeturn12search25turn12search2

This is a feature rather than a defect. If two systems have identical formulas but different branding, the table correctly says that branding is not a financial primitive. If practitioners identify a structural difference that predicts distinct failures, that evidence should promote the difference from residue to an isotope or element in a later release.

## Failure overlay and predictive gaps

### Incident coding

A stratified, non-loss-weighted sample of 24 major incidents was coded using four categories:

| Root category | Count | Share | Meaning |
|---|---:|---:|---|
| **a — defective instance of an element** | 9 | 37.5% | Implementation, arithmetic, initialization, reentrancy or verification defect |
| **b — invalid bond between valid elements** | 7 | 29.2% | Oracle-market, governance, reflexivity or collateral-liquidity combination was unsafe |
| **c — environment outside stability range** | 1 | 4.2% | Congestion, gas or reaction-time condition overwhelmed an otherwise valid mechanism |
| **d — outside the table** | 7 | 29.2% | Key compromise, malicious frontend, off-chain fraud or operator failure |

The coding is intentionally conservative and assigns one primary cause per incident even where causes were mixed. Category `c` is therefore undercounted: environmental depth, congestion and market conditions often contribute to incidents coded as defective elements or invalid bonds.

Representative assignments include:

| Incident | Classification | Table diagnosis |
|---|---|---|
| bZx 2020 | b | Flash-accessible leverage bonded to manipulable spot pricing |
| Maker Black Thursday | c | Gas and congestion exceeded the liquidation reaction range |
| Harvest Finance | b | Same-transaction pool-value manipulation amplified by flash liquidity |
| Wormhole 2022 | a | Verification defect permitted an unbacked cross-domain claim |
| Beanstalk | b | Borrowable governance power plus immediate execution |
| Terra/UST | b | Reflexive algorithmic stability and subsidized demand |
| Mango Markets | b | Thin endogenous market bonded to shared borrowing capacity |
| Euler v1 | a | Missing health check in a newly added state transition |
| Nomad | a | Message-verification initialization defect |
| Ronin | d | Validator/private-key compromise |
| BadgerDAO | d | Compromised user-facing infrastructure and approvals |
| Multichain | d | Operator/control-plane failure outside ordinary financial primitives |

The exploit-taxonomy literature supports treating unsafe dependencies as distinct from isolated bugs, while the Euler and Mango records demonstrate the difference in concrete cases. citeturn11search11turn14search20turn14search1

Category `d` does **not** dominate incident count in this sample, but it is large enough to bound the table’s explanatory reach. Moreover, loss-weighted results can be very different from incident counts. Reporting on 2025 losses found operational compromise, key, wallet and control-plane failures to be dominant, meaning a mechanism table can explain the financial propagation of such incidents but not necessarily their initiating cause. citeturn11search32

The maximum plausible explanatory scope is therefore:

\[
\text{mechanism table coverage}
=
\text{financial state transition}
+
\text{bond stability}
+
\text{reaction conditions}
\]

It does not inherently explain phishing, coerced signers, insider fraud, malicious legal entities, compromised developer machines or fraudulent reserve documents.

### Decay and radioactivity

| Decay pattern | Elements or compounds | Observable half-life substitute |
|---|---|---|
| **Reflexive decay** | `As` bonded to endogenous junior capital; protocol-token backstops | Falling collateral quality, reserve value and exit depth reinforce one another |
| **Liquidity migration** | Old AMM versions, isolated markets and obsolete vaults | Active depth and arbitrage participation decline before contracts disappear |
| **Governance abandonment** | `Up`, `Gp`, `Tg` in inactive protocols | Keys, delegates, keepers or monitoring cease to function |
| **Oracle obsolescence** | `Ex`, `Tp` consumers | Data remains syntactically available but no longer tracks a liquid market |
| **Bridge trust decay** | `Xm`, `Xf` | Verifier set, validator economics or operator availability deteriorates |
| **Emission decay** | `Em` | Rewards cease to attract sticky liquidity and become pure dilution |
| **Integration decay** | `Rb`, unusual tokens and legacy vaults | Downstream systems stop supporting the accounting form |
| **Legal decay** | `At`, `Aw`, RWA claims | Documents, servicing or legal priority cease to match token representations |

“Half-life” is therefore better represented by measurable support variables—liquidity, oracle coverage, governance participation, operator activity, legal validity and integration count—than by elapsed calendar time.

### Empty cells and predictions

| Permitted combination | Verdict | Why it remains empty or rare |
|---|---|---|
| `Im+Xm+Xf+Zk?`: proof-verified cross-chain isolated lending | Blocked by missing infrastructure | Requires cheap, timely remote-state proofs and liquidation finality without privileged bridge assumptions |
| `Pl+Sb+Sd+Aw`: selectively disclosed private pooled lending | Unbuilt but viable | Credentials and shielded accounting exist; private oracles and liquidations remain operationally difficult |
| `Sh+At+Aw+Sb+Sd+Wq`: shielded RWA vault | Unbuilt but viable | The mechanism is coherent, but legal identity, transfer restriction and privacy-policy reconciliation are unresolved |
| `In+Ba+Ft+Ct`: intent-cleared fixed-term credit auction | Unbuilt but viable | Adverse selection and enforceable collateral commitments constrain solver discretion |
| `Pf+Zk+Ct`: perpetual index backed by validity proofs of exchange state | Infrastructure-blocked | Proof-carrying market data currently faces latency, availability and canonical-market-definition problems |
| `Py+Xm+Xf+Ep`: cross-chain principal/yield claims | Infrastructure-blocked | Yield indexes, maturity and supply conservation must remain synchronized across domains |
| `Tw+Ba+Ag`: time-sliced batch execution with MEV-surplus rebates | Viable but not established | Clearing complexity and liveness may cost more than the timing leakage it removes |
| `Cl+Tr+Op`: tranche-insured concentrated-liquidity shares | Economically unattractive so far | Range risk, short-volatility pricing, rebalancing and adverse selection are expensive to package |
| `Cd+Rd+Ct` with automated collateral targeting and minimal governance | Viable but governance-hard | Oracle selection and emergency handling remain irreducibly social |
| `Cl+Sh` with atomic Bitcoin-L2 composability | Infrastructure-constrained | Persistent range state and synchronous settlement are uneven across Bitcoin-linked environments |
| `Uc` without `Aw`, `At`, collateral or enforceable reputation | Forbidden | Anonymous undercollateralized borrowers provide no durable recovery path |
| `As↺` without `Rd`, exogenous reserve or solvent backstop | Forbidden or radioactively unstable | Recreates the endogenous junior-capital run condition |
| `Sb+Oa+Cv`: private parametric cover with optimistic claims | Viable but difficult | Dispute evidence must be revealed enough to adjudicate without destroying claimant privacy |
| `Py+Tr+Wq` for RWA cash-flow strips | Viable but legally complex | Off-chain prepayment, delinquency and servicing discretion make yield claims non-deterministic |

These gaps are predictions about mechanism combinations, not investment recommendations. Several may already exist as prototypes or small deployments outside the corpus. Promotion from “gap” to “molecule” should require primary implementation evidence and a complete bond analysis.

## Machine-readable release, open questions, and conclusion

### Deliverable files

| Artifact | Contents |
|---|---|
| [Complete JSON knowledge-graph package](sandbox:/mnt/data/defi_periodic_table.json) | Groups, periods, 48 core elements, eight provisional candidates, typed bonds, molecules, corpus, incidents, notation and gaps |
| [Element attribute table](sandbox:/mnt/data/defi_elements.csv) | Definitions, IDs, symbols, groups, periods, trust assumptions, required and incompatible counterparts, parameters, implementations, failures and maturity |
| [Typed bonding rules](sandbox:/mnt/data/defi_bonding_rules.csv) | Required, forbidden, unstable and catalytic interface/economic/trust edges |
| [Molecular decompositions](sandbox:/mnt/data/defi_molecules.csv) | The 25 protocol formulas, readings and residue |
| [Protocol-version corpus](sandbox:/mnt/data/defi_corpus.csv) | The 101-unit extraction corpus with chain family, category and status tags |
| [Failure overlay](sandbox:/mnt/data/defi_failure_overlay.csv) | Incident coding under categories a–d |
| [Predicted gaps](sandbox:/mnt/data/defi_gaps.csv) | Empty combinations, verdicts and blocking conditions |
| [Visual table](sandbox:/mnt/data/defi_periodic_table_visual.png) | Five-period by 12-group layout |
| [Notation README](sandbox:/mnt/data/README_defi_periodic_table.md) | Formula operators and release notes |

The JSON represents bonds as typed edges rather than undifferentiated relationships. Its core structure is:

```json
{
  "elements": [
    {
      "id": "E013",
      "symbol": "Pl",
      "group_id": "G04",
      "period_id": "P3",
      "definition": "...",
      "trust_assumptions": "...",
      "required_counterparts": "...",
      "incompatible_or_unstable_with": "...",
      "common_parameterization": "...",
      "canonical_implementations": "...",
      "known_failure_modes": "...",
      "maturity_decay_status": "..."
    }
  ],
  "bonds": [
    {
      "source": "Pl|Im|Cd|Pf|Op",
      "target": "Ex|Tp|At",
      "bond_type": "economic",
      "rule": "required",
      "conditions": "...",
      "evidence": "..."
    }
  ],
  "molecules": [
    {
      "protocol": "Aave",
      "version": "v3",
      "formula": "Pl+Ix+Ct+Ex+Li+Bs+Gp+Up+Tg+Im{isolation}",
      "reading": "...",
      "residue": "..."
    }
  ]
}
```

### Open questions and instability register

| Open question | Current arbitrary call | Evidence that would settle it |
|---|---|---|
| Is Dutch-auction descent a distinct element? | Provisional `Da` | Three unrelated production lineages showing unique liveness, manipulation and substitution behavior |
| Is an insurance fund more than a balance-sheet parameter? | Provisional `Ir` | Recurring independent accumulation, depletion and payout state machines distinct from `Bs` and `Sl` |
| Is a ZK state proof an element or bond? | Provisional `Zk` | Finance-specific proof semantics that recur independently of generic bridge or rollup infrastructure |
| Is credit delegation distinct from access control? | Provisional `Cg` | Delegated obligations that cannot be reconstructed from `Pl/Uc+Aw` |
| Is vote escrow atomic? | Provisional `Ve` | A distinct state transition and failure signature not decomposable into epoch lock, checkpoint, emissions and governance |
| Is token-level credential enforcement distinct from pool gating? | Provisional `Kg` | Demonstrated portability and failure differences across multiple RWA lineages |
| Should auction be a broader core family? | Core has `Ba`; `Da` remains provisional | More evidence from liquidation, issuance, intent and credit auctions under a shared formal model |
| Should fixed and floating interest-rate swaps receive an element? | Decomposed into `Ft`, `Py`, `Op`, truth and settlement | Production contracts with independently recurring swap-specific state that resists payoff decomposition |
| Is atomic composability ever an element? | Environmental condition | A recurring financial state transition, rather than merely synchronous execution capability |
| How should app-chain consensus enter formulas? | Reaction condition and residue | Evidence that consensus design systematically changes financial role substitution rather than only execution stability |
| How much legal state belongs in the table? | `At`, `Aw`, `Uc`, `Ft`, `Tr`, with contracts and enforcement as residue | Standardized, machine-verifiable legal cash-flow and priority transitions |
| Can “first deployment” priority be stabilized? | Conservative corpus marker | Archived source code, deployment records and contemporaneous primary documentation |
| What level of residue should trigger a new element? | Recurrence plus distinct failure signature | Three unrelated implementations where the residue predicts behavior the existing formula cannot |
| Is reflexivity the best predictor of catastrophic failure? | Strong hypothesis, not proven theorem | A coded longitudinal dataset comparing reflexivity measures with failure incidence and severity |
| Is 48 the final count? | Closed for release 0.9 and its 101-unit corpus | New evidence can split, merge or promote mechanisms, but changes must pass the atomicity test rather than satisfy visual symmetry |

The final verdict is that a periodic table of DeFi is defensible **only as a periodic table of recurring financial state transitions**, not a table of protocols, brands, standards, contracts, narratives, or code modules. Its strongest contribution is not the 48-element grid but the separation of interface, economic and trust bonds; the required and forbidden composition rules; and the explicit residue left after real protocols are decomposed.

The chemistry metaphor breaks precisely where institutional and adversarial software systems differ from matter. DeFi elements are invented and revised; groups may change when new substitutes appear; bonds depend on liquidity, governance, finality and law; and the same molecule can be stable on one chain or market and insolvent on another. The table should therefore be treated as a versioned scientific model: closed against a stated corpus, falsifiable through residue, and amendable only through evidence.