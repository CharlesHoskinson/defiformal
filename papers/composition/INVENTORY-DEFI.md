# INVENTORY-DEFI.md

Literature negative-result check: **has interface/contract theory (interface automata,
assume-guarantee contract algebra, architectural mismatch) been applied to DeFi or smart
contract composition?**

Compiled 2026-08-04. Retrieval was **API-only**: arXiv Atom API (~35 queries) and
Semantic Scholar Graph API (intermittently rate-limited; `total=None` on several calls).
**DBLP was unavailable** for the whole session — every `dblp.org/search/publ/api` request
returned HTTP 500 regardless of query or format. No WebSearch, no Google Scholar, no
publisher-site scraping was used. PDFs downloaded to `papers/composition/defi/` with
`pdftotext -layout` extractions alongside.

Classification: does the item constitute **an application of interface/contract theory**
(de Alfaro–Henzinger interface automata; Benveniste / Sangiovanni-Vincentelli / Incer
assume-guarantee contract algebra; refinement, quotient, residual) **to DeFi**?

---

## A. DeFi composition and security-of-composition (the MEV-adjacent cluster)

### A1. Bartoletti, Marchesin, Zunino — "DeFi composability as MEV non-interference"
arXiv:2309.10781v2 (2023-09-19, rev. 2024-01-08). PDF: `defi/bartoletti-mev-noninterference.pdf`.

**What it does.** Defines *secure composability* of smart contracts: a compound contract C
built over dependencies D is secure if an adversary cannot economically damage C by
interacting with D. The definition is cast as a **non-interference** property over MEV
(maximal extractable value): composing new contracts with pre-existing state must not
increase extractable value against the victims. Gives an operational contract model,
adversarial models, and worked DeFi compositions.

**Interface/contract theory applied to DeFi?** **PARTIAL.** Genuinely a *composition-safety*
theory for DeFi, and the single closest relative of the atlas programme. But the security
notion is information-flow / economic (non-interference over a value functional), *not*
interface-theoretic: no assume/guarantee pair, no refinement preorder, no composition
operator with a compatibility side condition, no quotient. The paper contains **zero**
references to interface automata, de Alfaro–Henzinger, assume-guarantee contracts, or
contract algebra (verified by grep over the full extracted text).

### A2. Bartoletti, Marchesin, Zunino — "A formal framework for the economic security of DeFi compositions"
arXiv:2606.05418v1 (2026-06-03). PDF: `defi/bartoletti-econsec-defi-compositions.pdf`.

**What it does.** The journal-scale successor to A1. Introduces *local MEV* (loss localized to
a designated victim set), studies bounded- and unbounded-wealth adversaries, and — the part
that matters here — establishes **sufficient conditions and "locality principles" that enable
modular reasoning about secure composability**. Applied to exchanges, AMMs, options, lending
pools, routers, and arbitrage contracts.

**Interface/contract theory applied to DeFi?** **PARTIAL — the closest counterexample overall.**
"Locality principles enabling modular reasoning" is functionally the same *ambition* as an
interface theory: derive safety of the whole from checks on the parts. But the machinery is
economic/game-theoretic, the composition side-condition is an MEV inequality rather than a
compatibility or refinement relation, and again the interface-theory and contract-algebra
literatures are not cited at all. It is a *rival* modular framework, not an instance of one.

### A3. Priyadarshini, Bartoletti — "A quantitative notion of economic security for smart contract compositions"
arXiv:2505.19006v1 (2025-05-25). PDF: `defi/priyadarshini-quantitative-econsec.pdf`.

**What it does.** Quantifies rather than merely detects composition attacks: measures how an
attack on one component *amplifies* into losses for the composed system, then applies the
measure to standard DeFi compositions (tokens, DEXs, lending).

**Interface/contract theory applied to DeFi?** **NO** — quantitative economic security, same
lineage as A1/A2, one step further from interface theory.

### A4. Babel, Daian, Kelkar, Juels — "Clockwork Finance: Automated Analysis of Economic Security in Smart Contracts"
arXiv:2109.04347v2 (2021, rev. 2023); Cornell Tech / IC3. PDF: `defi/babel-clockwork-finance.pdf`.

**What it does.** The Clockwork Finance Framework (CFF): a K-framework-based, *contract-complete*,
*attack-exhaustive* formal model that mechanically extracts all economic attacks (extractable
value) across a modeled set of contracts. Explicitly advertises **composability** — one can
reason over any chosen set of interacting contract models — and instantiates on real Ethereum
DeFi.

**Interface/contract theory applied to DeFi?** **NO.** "Composable" here means the *model* is
modular and the solver ranges over a chosen contract set; there is no interface, no
assume/guarantee obligation, no compatibility check, no refinement. This is the canonical
MEV-focused composition work the atlas authors already have in mind.

### A5. Daian, Goldfeder, Kell, Li, Zhao, Bentov, Breidenbach, Juels — "Flash Boys 2.0: Frontrunning, Transaction Reordering, and Consensus Instability in Decentralized Exchanges"
arXiv:1904.05234; IEEE S&P 2020.
Originates MEV; shows frontrunning/reordering in DEXes and the consensus-layer instability it
induces. **NO** — empirical and game-theoretic, not compositional specification.

### A6. Qin, Zhou, Gervais — "Quantifying Blockchain Extractable Value: How dark is the forest?" (arXiv:2101.05511, IEEE S&P 2022); Qin, Zhou, Livshits, Gervais — "Attacking the DeFi Ecosystem with Flash Loans for Fun and Profit" (arXiv:2003.03810, FC 2021)
Measurement and attack synthesis for BEV / flash-loan attacks; the flash-loan paper is
essentially about *cross-protocol* exploitation. **NO** — attack-centric, no composition
calculus.

---

## B. Compositional verification of smart contracts (PL / formal-methods side)

### B1. Tolmach, Li, Lin, Liu — "Formal Analysis of Composable DeFi Protocols"
arXiv:2103.00540v2 (2021); FC 2021 Workshops (DeFi'21). PDF: `defi/tolmach-composable-defi.pdf`.

**What it does.** Models DeFi protocols in **CSP** and model-checks with PAT; the case study
composes **Curve × Compound** and finds property violations, confirmed on a locally deployed
Ethereum network. The only pre-existing paper found that verifies a *composition of two named
DeFi protocols* using process algebra.

**Interface/contract theory applied to DeFi?** **PARTIAL, and load-bearing for the atlas
related-work section.** CSP parallel composition is a composition operator, but there is no
interface synthesis and no compatibility/refinement reasoning. Critically, its own conclusion
states verbatim (p. 9):

> "To combat the state explosion problem, we consider utilizing techniques from the area of
> compositional verification, such as **assume-guarantee reasoning [23,24,25], which we leave
> for future work**."

Refs [23–25] are Lin / Liu / Sun / Dong / André on learning assumptions for compositional
verification — generic AG model checking, not DeFi. **This is a direct, citable admission from
inside the DeFi formal-methods community that assume-guarantee reasoning had not been applied
to DeFi composition as of 2021**, and no follow-up doing so surfaced in this search.

### B2. Wesley, Christakis, Navas, Trefler, Wüstholz, Gurfinkel — "Compositional Verification of Smart Contracts Through Communication Abstraction (Extended)"
arXiv:2107.08583v2 (2021); SAS 2021. PDF: `defi/wesley-compositional-verif-sc.pdf`.

**What it does.** "Local bundles": a parameterized-verification / symmetry-reduction technique
reducing a contract with up to 2^160 users to a sequential program over a few representative
users, computed by static analysis of communication patterns.

**Interface/contract theory applied to DeFi?** **NO.** Compositionality here is *over users of
a single contract* (parameterized verification), not over *protocols*. No DeFi composition, no
interfaces.

### B3. Ball, Bjørner, Chen, Chen, Guo et al. (Microsoft Research / NYU Shanghai) — "Theorem-Carrying Transactions: Runtime Verification to Ensure Interface Specifications for Smart Contract Safety"
arXiv:2408.06478v2 (2024). PDF: `defi/li-theorem-carrying-tx.pdf`.

**What it does.** Attaches machine-checked theorems to transactions so that **interface
specifications** of smart contracts are enforced at runtime rather than only at deploy time.
Closest lexical match to "interface" in the whole corpus.

**Interface/contract theory applied to DeFi?** **PARTIAL / borderline NO.** "Interface
specification" is used in the Design-by-Contract / Hoare-triple sense (pre- and postconditions
per function), not the de Alfaro–Henzinger sense (an automaton whose composition is optimistic
and whose compatibility is a game). No composition operator over interfaces, no refinement
lattice. Worth citing as the nearest terminological neighbour and explicitly distinguishing.

### B4. "Formal Verification of a Token Sale Launchpad: A Compositional Approach in Dafny"
arXiv:2510.24798v1 (2025).
Dafny verification of a single launchpad contract, decomposed into modules. **NO** —
"compositional" means modular proof engineering of one system.

### B5. Sergey, Nagaraj, Johannsen, Kumar, Trunov, Hao — "Safer Smart Contract Programming with Scilla" (OOPSLA 2019); "Scilla: a Smart Contract Intermediate-Level LAnguage" (arXiv:1801.00687)
Scilla models contracts as **communicating automata** with an explicit separation of
computation from effects/message passing, enabling per-contract reasoning. **PARTIAL.** The
automata-with-messages framing is architecturally adjacent to interface automata, but Scilla is
a language design; there is no interface composition/compatibility theory and no
DeFi-composition result.

### B6. Sergey, Hobor — "A Concurrent Perspective on Smart Contracts"
arXiv:1702.05511; FC 2017 Workshops (WTSC).
Position paper drawing the analogy contracts : accounts :: concurrent objects : shared memory,
suggesting linearizability and rely-guarantee-style tooling could transfer. **PARTIAL — a
proposal, not a result.** It gestures at exactly the transfer the atlas is making without
carrying it out. Good "the idea was floated but never developed" citation.

### B7. Obsidian (Coblenz et al., arXiv:1909.03523 and arXiv:2003.12209) and Flint (arXiv:1904.06534)
Typestate plus linear assets for blockchain languages. **NO** — intra-contract type discipline;
typestate is a per-object protocol, not an inter-protocol composition theory.

---

## C. DeFi theories, taxonomies, DSLs (the atlas's nearest genre)

### C1. Bartoletti, Chiang, Lluch-Lafuente — "A theory of Automated Market Makers in DeFi"
arXiv:2102.11350v7; **Logical Methods in Computer Science 18(4), 2022, 12:1–12:46** (conference
version COORDINATION 2021). PDF: `defi/bartoletti-theory-amm.pdf`.
Abstract small-step operational model of AMM interactions; proves structural and economic
properties (arbitrage, incentive consistency, determinacy of swap rates) independent of any
particular AMM implementation. The reference formal semantics of one DeFi element.
**NO** interface/contract theory — but the *methodological* precedent for defining a mechanism
abstractly and proving properties of it. Cite as the single-element analogue of the atlas's
58-element vocabulary.

### C2. Bartoletti, Chiang, Lluch-Lafuente — "SoK: Lending Pools in Decentralized Finance"
arXiv:2012.13230 (2020); FC 2021 Workshops. PDF: `defi/bartoletti-sok-lending-pools.pdf`.
Executable formal model plus systematization of lending-pool mechanisms and their parametric
incentive structures; identifies desirable properties and open problems. **NO** interface
theory. Same role as C1: per-element formalization.

*Note on C1 + C2:* the same group later composes AMMs, lending pools, and options **only inside
the MEV-non-interference framework** (A2). There is no separate interface-theoretic "composing
AMMs with lending" result.

### C3. Kitzler, Victor, Saggese, Haslhofer — "Disentangling Decentralized Finance (DeFi) Compositions"
arXiv:2111.11933 (2021); ACM TWEB.
Empirical measurement of 23 protocols and 10,663,881 accounts; decomposes protocol calls into a
network of DeFi building blocks; shows known community-detection methods cannot separate
protocols. **NO** — descriptive network science. Useful as evidence that composition is
pervasive and complexity-inducing, i.e. motivation.

### C4. Werner, Perez, Gudgeon, Klages-Mundt, Harz, Knottenbelt — "SoK: Decentralized Finance (DeFi)" (arXiv:2101.08778, AFT 2022); Auer, Haslhofer, Kitzler, Saggese, Victor — "SoK: Decentralized Finance (DeFi) — Fundamentals, Taxonomy and Risks"
Taxonomies of DeFi primitives and risks; both name composability ("money legos") as a
first-class risk source. **NO** formal composition treatment — the risk is asserted, never
modelled. Directly supports the atlas's motivating gap.

### C5. Xu, Paruch, Cousaert, Feng — "SoK: Decentralized Exchanges (DEX) with Automated Market Maker (AMM) Protocols"; Cousaert et al. — "SoK: Yield Aggregators in DeFi"; Zhou et al. — "SoK: Decentralized Finance (DeFi) Attacks" (arXiv:2208.13035)
Element-level systematizations; no composition algebra. **NO.**

---

## D. Contract theory itself — where it actually lives

Searches deliberately probed the intersection of the contract-theory corpus with blockchain:

- arXiv `all:"assume-guarantee" AND all:"blockchain"` — **0 hits**.
- arXiv `all:"smart contract" AND all:"assume-guarantee"` — **0 hits**.
- arXiv `all:"interface automata" AND all:"blockchain"` — **0 hits**.
- arXiv `all:"contract-based design" AND all:"blockchain"` — 1 hit, unrelated (a hierarchical
  on-chain asset-management tree structure).
- arXiv `all:"smart contract" AND all:"contract algebra"` — **0 hits**.
- arXiv `all:"de Alfaro" AND all:"smart contract"` — **0 hits**.
- arXiv `all:"process algebra" AND all:"smart contract"` — 1 hit = B1 (Tolmach).
- arXiv `all:"cross-protocol" AND all:"invariant" AND all:"DeFi"` — **0 hits**.
- arXiv `all:"money legos"` — **0 hits** (the term is informal only).
- Semantic Scholar `assume-guarantee contracts blockchain` — 3,389 results; the top 20 are
  entirely cyber-physical systems, control, and aerospace. The only blockchain-titled hit,
  "Drone-based Risk Management of Autonomous Systems Using Contracts and Blockchain" (SANER
  2021), uses a blockchain as a *ledger for storing* AG contracts, not contract theory for
  on-chain code.
- The Incer / Sangiovanni-Vincentelli / Nuzzo corpus retrieved by S2 — **Hypercontracts**;
  **Pacti: Assume-Guarantee Contracts for Efficient Compositional Analysis and Design** (ACM
  TCPS 2023); *Composition and Merging of Assume-Guarantee Contracts Are Tensor Products*;
  *Assume-guarantee contract algebras are dp-algebras*; *Some Algebraic Aspects of
  Assume-Guarantee Reasoning*; *Contract-Based Specification Refinement and Repair for Mission
  Planning*; *Library-based scalable refinement checking for contract-based design* — is
  **exclusively** CPS, robotics, control, aerospace, and EDA. Zero DeFi, zero blockchain, zero
  financial-mechanism applications.
- Foundational anchors with no DeFi descendant found: de Alfaro & Henzinger, *Interface
  Automata* (ESEC/FSE 2001) and *Interface Theories for Component-Based Design* (EMSOFT 2001);
  Benveniste et al., *Contracts for System Design* (Foundations and Trends in EDA, 2018);
  Garlan, Allen & Ockerbloom, *Architectural Mismatch, or Why It's Hard to Build Systems Out of
  Existing Parts* (ICSE 1995) — the last being the conceptual ancestor of "implicit component
  assumptions", never applied to DeFi in anything retrieved.

### D1. Adjacent but different: Universal Composability on blockchain
UC (Canetti) *has* been applied to blockchain (backbone protocols, payment channels, sidechains,
Hawk). **NO** for our purposes: UC composability is cryptographic, simulation-based security
under arbitrary environments — orthogonal to requirement/prohibition admissibility over a
mechanism vocabulary. Searches for `"universally composable" AND ("DeFi" OR "decentralized
finance")` returned **0 hits**; UC has not reached the DeFi-protocol-composition layer.

---

## VERDICT

**The authors' claim is essentially TRUE, with one qualification that must be stated explicitly
in the related-work section.**

No retrieved work applies interface automata, de Alfaro–Henzinger optimistic composition,
assume-guarantee contract algebra (Benveniste / Sangiovanni-Vincentelli / Nuzzo / Incer),
contract refinement, quotient/residual, or architectural-mismatch analysis to DeFi protocols or
smart contracts. The two literatures are disjoint at the level of citation: the contract-theory
corpus never mentions blockchain, and the DeFi formal-methods corpus never mentions interface
automata or contract algebras. The one explicit acknowledgement of the gap comes from *inside*
DeFi formal methods — Tolmach et al. (FC-DeFi 2021) list assume-guarantee reasoning as **future
work**, and five years on nothing found has done it.

The qualification: the claim as phrased ("beyond MEV-focused work") is accurate but slightly
undersells the nearest competitor. Bartoletti, Marchesin & Zunino's MEV-non-interference line
(arXiv:2309.10781 → arXiv:2606.05418) is not merely MEV *measurement* in the Daian/Qin sense —
it is a genuine **modular reasoning framework for DeFi composability**, with locality principles
that let one certify a composition from properties of its parts. It occupies the same
architectural slot an interface theory would occupy, using an economic (extractable-value)
side-condition where an interface theory would use compatibility or refinement. The atlas should
therefore *not* claim that no formal treatment of DeFi composition exists; it should claim the
sharper and defensible thing: **the existing formal treatments of DeFi composition are
economic-security-theoretic, and none is interface- or contract-theoretic; in particular, no one
has formulated DeFi composition as an admissibility problem over a finite mechanism vocabulary
with requirement and prohibition constraints.** Secondary nearest neighbours to acknowledge and
distinguish: Clockwork Finance (a composable *model*, not a composable *specification*), Tolmach
et al. (CSP composition of Curve × Compound, AG explicitly deferred), Theorem-Carrying
Transactions ("interface specifications" in the Design-by-Contract sense), and Sergey & Hobor
2017 (proposed the concurrency / rely-guarantee analogy, never developed it).

**Discovery caveat: this check was API-only.** arXiv and Semantic Scholar only; DBLP returned
HTTP 500 for every query; no WebSearch, Google Scholar, ACM DL, IEEE Xplore, or Springer
coverage. Venue-only publications with no arXiv preprint — plausibly some FMBC / WTSC /
FC-workshop and industrial (Certora, Runtime Verification, ChainSecurity) papers — are
systematically underrepresented. FMBC (Formal Methods for Blockchains) proceedings in particular
should be hand-checked before the claim is asserted unconditionally in print.
