# Unifying CAKE with the DeFi Periodic Table: A Three-Artifact Reconciliation

## TL;DR
- **Verdict: partial unification, not full synthesis** — CAKE is not a rival table but a fine-grained magnifier over one corner of the reconciled A∪B set (the cross-domain settlement/solver region), because Table B has *already* absorbed most of CAKE's Solver and Settlement layers (`In`, `Ba`, `Rf`, `Xm`, `Xf`, `Ag`, `Ob`, `Wq`, `Aw`), and CAKE contributes at most 3–4 genuinely new (all provisional, all authority-layer) elements.
- **The organizing principle is H7's conservation law, not the trilemma.** Table B's supply-conservation rule for `Xf` (`debit(source)=credit(destination)`) and CAKE's lossless-information / lossy-value distinction are the same invariant stated twice: *value may be lossy across a trust boundary; authorization and information may not.* The cross-chain trilemma is a soft engineering tradeoff being actively relaxed (CCTP v2, IBC Eureka, shared sequencing), not a law; the real law is Zamyatin et al.'s proven impossibility of trustless cross-chain communication.
- **Table B's row axis (minimum dependency depth) survives; trust becomes an attribute.** Of the 24 ledger rows, ~13 are genuine contradictions and ~11 are naming/convention differences. CAKE's Permission layer fails Table B's state-transition criterion *as elements* but passes *as a bond property* (authority) — the most elegant admissible outcome, and the one the evidence supports.

---

## Key Findings (each falsifiable)

1. **CAKE is contained by the reconciled table (H4), organized by the conservation law (H7); it is not a second axis (H1 dead) and not the Application layer's filing cabinet (H5 trivial).** Falsifier: exhibit a CAKE unit that decomposes into no combination of reconciled elements and is not itself admissible as one — none was found except the authority/custody cluster and the information-disclosure axis.

2. **Table B had already performed the cross-domain settlement carve before CAKE was consulted.** `Xm` (message verification) and `Xf` (asset transfer) exist in B as separate elements, so Wormhole and Nomad are category (a) verification defects in `Xm`, not category (d) residue. Corroborated by primary post-mortems: Wormhole (2 Feb 2022, $326M / 120k wETH) — per Halborn, "the attacker exploited the use of a deprecated, insecure function to bypass signature verification"; Nomad (1 Aug 2022, ~$190M) — per Immunefi and Paradigm's samczsun, "a routine upgrade marked the zero hash as a valid root, which had the effect of allowing messages to be spoofed." Both are `Xm` verification failures.

3. **CAKE's Permission layer fails Table B's state-transition-boundary criterion as elements but passes as bonds.** An EOA, an AA account, and a policy agent do not change claims/obligations/allocation/valuation/settlement; they change *who may act*. That is a trust-bond property, not a row. Falsifier: H6 (two instruments), which remains the fallback if authority proves to carry independent failure signatures that cannot be attached to element bonds.

4. **The `Up` precedent does not rescue Permission-layer elements, and B is not inconsistent.** `Up` (mutable proxy) changes the *protocol's own reachable state machine*; signing authority changes *who can drive it*. Different objects; the principled line is "changes reachable protocol state" (in) vs. "changes the actor set authorized to request state changes" (out).

5. **Only a handful of genuinely new elements survive CAKE, all in authority/custody, and none high-confidence.** Provisional passes: delegated-execution-scope/session-key policy (`Dx`), gas sponsorship/paymaster (`Gs`), resource-lock/credible-commitment (`Rl`), solver bonding/slashing (`Sk`). "Unified balance," "universal accounts," and "intent-centric" are marketing molecules, not elements (anti-pattern 9).

6. **`Xm` should be split by trust domain into light-client / external-validator-set / shared-sequencer**, because each has a distinct failure signature (Nomad = external-validator verification-logic; Ronin = external-validator key compromise; IBC light-client = liveness-not-safety). `Xf`'s lock-mint / burn-mint / liquidity forms are **isotopes** of one element: same function (value transfer), different failure surface.

7. **The failure residue shrinks by count under unification but its dollar composition inverts.** Table A's category (d) was bridge-dominated; after B's carve those move to (a). What is left in (d) by 2025 is loss-weighted-dominated by operational/key compromise: per TRM Labs' 2026 Crypto Crime Report (reported by The Block, 27 Jan 2026), "infrastructure attacks drove $2.2 billion in losses, representing 76% of the total stolen digital assets across 45 incidents" out of $2.87B; per Hacken's 2025 Yearly Security Report (via Cointelegraph, 30 Dec 2025), "access control failures and broader operational security breakdowns accounted for about $2.12 billion, or nearly 54% of all 2025 losses, compared with around $512 million from smart contract vulnerabilities." CAKE's Permission layer *names* this residue (authority/opsec) rather than converting it to zero.

8. **The trilemma is not a law; H7's conservation law is the better invariant.** The impossibility result that *is* a law is Zamyatin, Al-Bassam, Zindros, Kokoris-Kogias, Moreno-Sanchez, Kiayias & Knottenbelt, *SoK: Communication Across Distributed Ledgers* (FC 2021; ePrint 2019/1128): "we formalize the underlying problem of Correct Cross-Chain Communication (CCC) and show a reduction to the Fair Exchange problem, known to be impossible without a trusted third party." That grounds the conservation law directly; the trilemma's three poles are being relaxed by engineering (CCTP v2 fast transfer ~8–20s; IBC Eureka; shared sequencers).

9. **"Informational" is not a fourth bond type; it is a sub-case of the economic bond.** CAKE's `EV_signal` leaks value through observation, but the leakage matters only because it is *priced* (adverse selection, front-running discount). It is an economic bond conditioned on an information-disclosure parameter, not a new primitive.

10. **A cross-domain reflexivity analogue exists but must be held to hypothesis status.** A trust-domain cycle (chain X's security depends on a bridge whose security depends on assets bridged from X) is real and structurally predicts wrapped-collateral cascades, but B is right that reflexivity is a hypothesis, not a theorem — and the analogue inherits that status and, in fact, did *not* predict the actual bridge failures (those were verification/key defects, not reflexive cascades).

---

## Deliverable 1 — Reconciliation Ledger (§1, all 24 rows)

Default rule applied: adopt B's numbering, 7-criterion atomicity test, and 101-version-unit corpus unless A is demonstrably right on a specific row. "GC" = genuine contradiction; "NC" = naming/convention difference.

| # | Question | Resolution | Type | Rationale |
|---|---|---|---|---|
| 1 | Row axis | **B wins: dependency depth is the row; trust is an attribute.** | GC | Trust is multivariate (custodial, consensus, oracle, upgrade). Ordering periods by a scalar "trust surface" forces a total order on a partial order. Dependency depth (what must already exist for X) is a genuine partial order with a clean minimum. CAKE's trust-heavy decisions become the `trust_domain` attribute, not a period. |
| 2 | Group count | **B's 12 groups**, plus a new Control/Authority group absorbing CAKE Permission bond-properties. | NC | 10 vs 12 is a lumping choice; B's finer split localizes solver/permission elements better. |
| 3 | Atomicity test | **B's 7 criteria**, with criterion B (state-transition boundary) applied to *elements only*, not bonds. | GC | The extra criteria (state-transition boundary, execution-model portability, implementation observability) are what let the table survive non-EVM entries; A's 5 cannot. |
| 4 | Concentrated liquidity | **B wins: `Cl` is an element.** | GC | Distinct failure signature (JIT liquidity, inactive-range insolvency, tick rounding) not shared with `x*y=k`. Failure-signature precedence beats substitutability. |
| 5 | Constant sum | **A wins: `CSM` is an element** (B's "limiting isotope inside `St`" understates it). | GC | Constant-sum has a categorical failure mode (full one-sided drain at peg break) absent from stable-swap curves. |
| 6 | Weighted pools | **B wins: `Wg` is an element.** | GC | Weighted invariants generate LVR/rebalancing signatures distinct from 50/50 AMMs. |
| 7 | Oracle carve | **Hybrid: B's 4-element carve (`Ex`,`Tp`,`Oa`,`At`) as the mechanism axis; CAKE's trust-domain carve as the `trust_domain` attribute.** | GC | Orthogonal carves: B splits by *what is read*; CAKE by *who attests*. Neither subsumes the other. |
| 8 | Bridging | **B wins decisively: split `Xm` (message verification) vs `Xf` (asset transfer).** The load-bearing row. | GC | The split reclassifies Wormhole/Nomad and makes CAKE's settlement layer decomposable. |
| 9 | Solvency test | **B wins: health factor is a derived observation of `Ct`, not element `HF`.** | NC | A threshold read of a state variable is a parameter, not a mechanism. |
| 10 | Atomic composability | **Resolved as spectrum-valued attribute (`atom_dependency`)** — A's instinct that it deserves first-class status, but B's refusal to make it a discrete element. | GC | Neither "catalyst element" (A) nor "environmental attribute to be dismissed" (B) is right; it is a graduated attribute (Phase 5). |
| 11 | Peg-arbitrage mint/burn | **B wins: market reaction, not an element; Terra = `As + Rd{LUNA-conversion}`.** | GC | The May 2022 death spiral (~$40B UST+LUNA erased in under a week) was the arbitrage *reaction* to the `As` mechanism under `Rd`, not a separate mechanism. |
| 12 | Restaking | **A wins: `RS` exists and B's omission is a real gap.** | GC | EigenLayer slashing went live 17 Apr 2025 (ELIP-002; The Defiant confirms "feature-complete status"); novel failure signature (correlated cross-AVS slashing, rehypothecation cascades). |
| 13 | Vote-escrow | **B wins: provisional `Ve`, "appears decomposable"** into lock + governance-weight. | NC | B's decomposition is cleaner and testable. |
| 14 | PSM | **B wins: core element `Ps`.** | NC | Version-unit method resolves it as a distinct 1:1-collateralized swap, distinct from CDP mint. |
| 15 | Hooks | **B wins: interface grammar, not an element.** Sets the precedent for CAKE's standards. | GC | Uniswap v4 / CCTP v2 hooks change *composition surface*, not financial state. Precedent applied to ERC-7683, xERC20: standards are notation, not elements. |
| 16 | Intents / solvers | **B wins: `In` core at P4, plus `Ba`,`Rf`,`Ob`,provisional `Da`.** | GC | Why CAKE's Solver layer is largely pre-absorbed. |
| 17 | Privacy | **B wins: split `Sb`/`Sd`.** Order-flow privacy is a *parameter of the solver bond*, not a third privacy element. | GC | Disclosure is a bond condition (consistent with rejecting "informational" as a bond type). |
| 18 | Conservation law | **B wins: there IS a conservation law, and it is cross-domain.** Directly contradicts A. | GC | This is H7. A's "no conservation law" was true *within* a single domain and false *across* domains — the territory CAKE opened. |
| 19 | Reflexivity | **B wins: hypothesis, not theorem.** | GC | A's "master predictor" overreaches; same discipline for the cross-chain analogue. |
| 20 | Wormhole coding | **B wins: category (a), verification defect in `Xm`.** | GC | Signature-verification bypass; a mechanism failure, not residue. |
| 21 | Nomad coding | **B wins: category (a), verification defect in `Xm`.** | GC | Merkle-root init-to-zero; a mechanism failure. |
| 22 | Failure distribution | **Both locally right; report composition not totals.** A's (d)≈30% is bridge-dominated; B's (d)=29.2% is operational-dominated. | GC | See Phase 8; 2025 data confirms B's direction. |
| 23 | Notation | **Adopt B's (`+ || * { } ? |` + typed arrows `—i→ —e→ —t→` + `↺`); publish conversion table.** | NC | B's typed arrows encode the three bond types natively; A's superscripts are lossy. No third notation. |
| 24 | Corpus | **B wins: 101 version-units (21 non-EVM) is stronger boundary evidence.** | NC | Version-unit method distinguishes Uniswap v2/v3/v4 as separate evidence. |

**Count: ~13 genuine contradictions, ~11 naming/convention differences** (adjudicated tally in Question 2).

---

## Deliverable 2 — Phase Detail (rejected options shown)

### Phase 0 — Reconciled element set
Survivor = **Table B's skeleton** (48 core + 8 provisional, 12 groups, periods P0–P4 by dependency depth, 7-criterion atomicity, version-unit corpus) with forced amendments: (i) add `RS` restaking (from A); (ii) add `CSM` constant-sum as element (from A); (iii) promote `atom_dependency` to a spectrum attribute (row 10 synthesis); (iv) add a Control/Authority group carrying custody/authority bond-properties plus the 3–4 new CAKE elements; (v) add `trust_domain` attribute carrying CAKE's oracle-by-attestation carve. **Rejected:** unioning A and B (anti-pattern 1) — would yield a table with no axis.

### Phase 1 — Category audit of CAKE (every unit classified)
- **4 layers:** Application = **not-a-thing** (placeholder). Permission = **bond-property axis** (authority), not a row. Solver = **group** (≈ B's Execution/Access groups). Settlement = **group** (≈ B's Cross-domain group).
- **Key custody (EOA / AA / policy agent):** the three options are **parameters** of an authority bond; the axis is a **bond property**. As elements they **fail** criterion B.
- **Information sharing (public / partial / private mempool):** **parameter** of the solver economic bond (disclosure level).
- **Solver list (open / gated / exclusive):** **parameter** of the solver access bond.
- **Cross-chain oracle (out-of-protocol / in-protocol / shared sequencer):** **`trust_domain` attribute** values on `Xm`.
- **Token bridging (lock-mint / burn-mint / liquidity):** **isotopes** of `Xf`.
- **6 canonical designs:** **molecules** (anti-pattern 4).
- **Trilemma:** **reaction condition / soft tradeoff surface**, not a law.
- **`EV_ordering` / `EV_signal`:** **parameters / payout rule** of the economic bond (MEV split), not elements.
- **Lossless/lossy:** **the conservation law** (an axiom/invariant) = B's `Xf` rule.

### Phase 2 — Currency and neutrality audit (through mid-2026)
CAKE is a 15 Feb 2024 position paper by the founders of OneBalance (Chiplunkar & Gosselin), to be cited/audited/corrected, not treated as canonical (anti-pattern 7).

- **EIP-7702 (Pectra, mainnet 7 May 2025) partially collapses CAKE's EOA/AA axis.** CAKE treats EOA vs AA as a fundamental fork. 7702 lets an existing EOA temporarily set code (0x04 SetCode tx) and gain batching, gas sponsorship, and session keys without migration — dissolving the binary. CAKE itself cited EIP-4337's minimal adoption as why wallet-migration designs stall; 7702 is the industry's answer. This *strengthens* the finding that custody is an attribute (a spectrum EOA→7702-smart-EOA→4337-SCA→policy-agent), not a discrete element set.
- **Intent standard: converged, not failed.** ERC-7683 (Toda/Rice/Pai, Uniswap Labs/Across) reached production at Across, UniswapX, CoW Protocol, and Eco by early 2026, with the Open Intents Framework (30+ teams; Arbitrum, Optimism, Base, Polygon) built on it. EIP-5792 (`wallet_sendCalls`) reached Last Call (deadline 5 May 2025) but wallet adoption lags (Safe was an early integrator via WalletConnect; legacy `eth_sendTransaction` still dominates). ERC-7579 is the dominant modular-account standard. Net: CAKE's plea for a common intent standard was substantially answered — validating `In` as a real element with a now-standardized interface bond.
- **Settlement: the trilemma is being relaxed.** CCTP v2 (11 Mar 2025) added Fast Transfer (~8–20s vs 13–19 min V1) and Hooks — burn-and-mint value transfer at near-speed, directly attacking the speed/guarantee corner; V1 became legacy with phase-out from 31 Jul 2026. IBC Eureka (10 Apr 2025) connected Ethereum to Cosmos via light-client verification. Shared sequencing remains immature: Espresso launched permissionless mainnet (April 2025) and leads after Astria shut down (Dec 2025); every major L2 still runs a centralized sequencer as of mid-2026, decentralization not expected before late-2026–2027.
- **Solver market:** concentrating. Across (UMA Optimistic Oracle settlement, $14B+ cumulative volume through Q1 2026), deBridge DLN, Mayan, CoW batch auctions. An academic study of 3.5M cross-chain intents ($9.24B, Jun–Nov 2025 across Mayan/Across/deBridge) documents solver liquidity concentration and "liquidity exhaustion attacks" — empirical grounding for a solver-bonding rule.
- **MPC/TEE custody:** widely deployed institutionally (Fireblocks, Turnkey-class), validating MPC/TEE signing as a real `trust_domain` value.
- **Restaking (absent from B):** EigenLayer slashing live 17 Apr 2025 (ELIP-002; opt-in; ~$7B+ restaked across ~39 AVSs at launch) — must be added as `RS`.
- **Carve comparison** vs Particle/Omni/LI.FI year-in-review, NEAR (chain signatures/intents), Anoma (mainnet Phase 1 live 29 Sep 2025; intent-matching still largely testnet), ERC-7683 SoKs: these carve at the *pipeline* (Permission/Solver/Settlement) as CAKE does; none carves *mechanisms* the way B does. **B's mechanism carve is right for a periodic table; CAKE's pipeline carve is right for a request-lifecycle diagram.** Different objects (see H1).

### Phase 3 — Element extraction (continuing B's IDs)
- **Key custody / signing authority:** **bond property** (fails as element).
- **Delegated execution scope (session keys, policies, spend caps):** **`E049 Dx`** — provisional (changes the authorized action set over time; borderline claim/obligation change). Confidence: low.
- **MPC/TEE signing:** **`trust_domain` attribute value**, not an element.
- **Gas sponsorship / paymaster:** **`E050 Gs`** — provisional (changes who bears settlement cost = allocation change). Confidence: low–medium.
- **Unified balance accounting:** **not-a-thing** (accounting view / molecule) — anti-pattern 9.
- **Resource locks / credible commitments:** **`E051 Rl`** — passes (a lock is an enforceable obligation; ERC-6909/compact-style). Confidence: medium.
- **Order-flow information disclosure:** **parameter** of solver bond.
- **Solver access policy:** **parameter** (open/gated/exclusive).
- **Solver bonding / slashing:** **`E052 Sk`** — passes (bonded stake subject to slashing = claim/obligation with distinct failure signature). Confidence: medium.
- **Optimistic fill + reimbursement:** ≈ B's `Aw`/`Rf`; **isotope/refinement**, not new.
- **Cross-domain oracle by trust domain:** `trust_domain` attribute on `Xm`.
- **Shared-sequencer ordering:** `trust_domain` value on `Xm` + reaction condition enabling synchronous cross-rollup atomicity.

**Reverse pass (does CAKE force B to under-split?):**
- **`Xm` → three elements** (`Xm-lc` light-client, `Xm-ev` external-validator-set, `Xm-ss` shared-sequencer). **Yes, split.** Distinct signatures: Ronin ($625M, 23 Mar 2022, 5-of-9 validator key compromise; $540M at time-of-theft per Elliptic) and Nomad ($190M, verification-logic) are both external-validator-set failures of different sub-types; IBC light clients fail on liveness not safety; shared sequencers fail on liveness/censorship. Three trust domains, three signatures → three elements (or one element with a mandatory `trust_domain` discriminator — a modelling convention, but the split is the more honest representation).
- **`Xf` forms → isotopes.** Lock-mint, burn-mint, and liquidity bridging share the value-transfer function and the conservation law; they differ only in *where the liquidity cost and residual risk sit* (wrapped-token de-peg vs pool drain).

### Phase 4 — Axis and bond-type resolution
- **Row axis:** dependency depth (B); trust is an attribute. **Collinearity check:** depth and trust surface are *not* collinear — a lending market (`Ct`) is deep-dependency but medium-trust; a custodial bridge (`Xm-ev`) is shallow-dependency but maximal-trust. The distribution is genuinely two-dimensional, which is why A's collapse of trust into row order failed.
- **Bond types:** exactly three survive — **interface, economic, trust.** "Informational" **rejected** (Question 8). Drop `informational?` from the schema.

### Phase 5 — Asynchrony overlay
Graduated **atomicity spectrum** (the resolution satisfying both tables):
`same-transaction → same-block → shared-sequencer bundle → same-ecosystem finality (IBC/AggLayer/Superchain) → cross-ecosystem finality (optimistic/ZK light client) → optimistic-with-challenge`.

Per-element `atom_dependency`:
- **async-native:** `Xf`, `Xm`, `In`, `Ba`, `Rf`, `Ob`, `Sk`, `Rl` — defined by asynchrony; CAKE's home region.
- **async-repairable:** `Ct` (leverage/lending), `Am`/`Cl`/`St`/`Wg` (AMMs), `Lq` (liquidation), `Fl` (flash loan).
- **async-impossible (without trusted intermediary):** synchronous cross-domain atomic composition of a price read + liquidation across two finality domains. Sanity check passes: **the unified table immediately predicts "no cross-chain flash liquidity without a trusted intermediary"** — exactly Zamyatin et al.'s impossibility result.

**Required-bond rules restated under asynchrony:**
- **A's R1 (leverage ⇒ truth + solvency):** same-domain, price read and liquidation are atomic. **Cross-domain, R1 becomes:** leverage ⇒ truth + solvency **+ a finality-assumption bond on the oracle's trust domain + a liquidation-latency bound.** If the price is read on domain X and liquidation executes on domain Y, the position is under-collateralized for the finality gap; the repair bond is either an over-collateralization buffer sized to the gap or a shared-sequencer atomic bundle collapsing the gap to zero.
- **B's leveraged-obligation rule** becomes identical: it must add an explicit `finality_assumption` on the cross-domain read. The flash-loan atomicity that makes same-domain liquidations safe *does not exist cross-domain* — hence async-impossible without an intermediary.

### Phase 10 — Is the trilemma a law?
**No — a soft tradeoff being relaxed by engineering.** The genuine impossibility result is Zamyatin et al. (2019/2021): correct cross-chain communication is provably impossible without a trusted third party (reduction to fair exchange; Herlihy's atomic-cross-chain-swap lineage). That grounds **H7's conservation law**, not the trilemma. Apparent counterexamples (CCTP v2 fast transfer: near-speed + guarantee + low fee) are really *paying for the third pole with a trust assumption* (a trusted attester, Circle); shared sequencers buy speed + atomicity by adding a trusted ordering layer. **The invariant: you cannot move value across a trust boundary losslessly, trustlessly, and instantly; you must pay in one of {loss, trust, latency}.** That is H7 generalized, and it is the real law.

---

## Deliverable 5 — Unified Element Table (CAKE-affected region; schema-complete)

Schema: `id | symbol | name | group | period | layer | trust_domain | atom_dependency | source_table | confidence`

- `E-Xf | Xf | cross-domain asset transfer | Cross-domain | P4 | Settlement | {out-of-protocol,in-protocol,shared-seq} | native | B | high`
- `E-Xm-lc | Xm-lc | light-client message verification | Cross-domain | P4 | Settlement | in-protocol | native | B(split by CAKE) | high`
- `E-Xm-ev | Xm-ev | external-validator message verification | Cross-domain | P4 | Settlement | out-of-protocol | native | B(split by CAKE) | high`
- `E-Xm-ss | Xm-ss | shared-sequencer ordering/verification | Cross-domain | P4 | Settlement | shared-sequencer | native | new(CAKE) | low`
- `E-In | In | intent | Execution | P4 | Solver | n/a | native | B | high`
- `E-Ba | Ba | batch auction | Execution | P4 | Solver | n/a | native | B | high`
- `E-Rf | Rf | RFQ/solver fill | Execution | P4 | Solver | n/a | native | B | high`
- `E-Sk | Sk | solver bonding/slashing | Access | P4 | Solver | n/a | native | new(CAKE) | medium`
- `E-Rl | Rl | resource lock / credible commitment | Control | P3 | Permission | n/a | repairable | new(CAKE) | medium`
- `E-Dx | Dx | delegated execution scope | Control/Authority | P2 | Permission | n/a | repairable | new(CAKE) | low`
- `E-Gs | Gs | gas sponsorship/paymaster | Control/Authority | P2 | Permission | n/a | repairable | new(CAKE) | low`
- `E-RS | RS | restaking / shared security | Control | P3 | — | n/a | repairable | A(missing from B) | medium`
- `E-CSM | CSM | constant-sum market maker | AMM | P1 | Application | n/a | repairable | A | medium`

(Authority/custody itself is NOT a row: it is a `trust_domain`/bond property spanning every element.)

---

## Deliverable 6 — Unified Bonding Rules (grounding incident + `async_safe`)

**Required (R):**
- **R1′ (leverage ⇒ truth + solvency + finality assumption):** cross-domain leverage requires an explicit finality-assumption bond. Grounding: cross-chain lending against bridged collateral. `async_safe` = **only-with-repair-bond**.
- **R2 (cross-trust-domain settlement ⇒ explicit finality assumption):** Grounding: Wormhole ($326M) minted before adequate confirmation logic held. `async_safe` = yes (it IS the async rule).
- **R3 (intent ⇒ enforceable bounds + fallback):** B has this; it **survives cross-domain** but must add a timeout/refund path. Grounding: ERC-7683 dispute window; the liquidity-exhaustion-attack study (3.5M intents, $9.24B). `async_safe` = yes.
- **R4 (delegated authority ⇒ bounded scope):** session keys/policies must carry spend caps + expiry. Grounding: BadgerDAO ($120M, Dec 2021) — unbounded approvals harvested via a compromised Cloudflare-hosted front-end. `async_safe` = yes.
- **R5 (lock-mint wrapped asset used as canonical collateral ⇒ prohibited unless issuer-anointed):** Grounding: Wormhole-wrapped assets; Harmony Horizon; Multichain ($126M, Jul 2023). `async_safe` = n/a.

**Forbidden / unstable (F):**
- **F1 (solver exclusivity × price-improvement claim = impossible):** CAKE proves it — exclusive access captures EV but yields no price improvement (only execution). Grounding: DFlow/Robinhood-style exclusive auctions. `async_safe` = n/a.
- **F2 (algorithmic-stablecoin `As` × reflexive-collateral `Rd` = radioactive):** Grounding: Terra/UST (~$40B, May 2022). `async_safe` = n/a.
- **F3 (external-validator-set `Xm-ev` × high-value canonical settlement without bonded slashing = unstable):** Grounding: Ronin ($625M), Nomad ($190M). `async_safe` = n/a.

---

## Deliverable 7 — Asynchrony overlay
See Phase 5: full survives-`ATOM`-removal classification, the graduated atomicity spectrum, and the restatement of every required-bond rule under asynchrony.

---

## Deliverable 8 — Molecules (Phase 7)

**Six CAKE designs, two implementations each, in B notation, with residue:**
1. **Token-anointed bridge** = `Xf{burn-mint} —t→ Xm-ev{issuer-anointed}` — CCTP v2, xERC20/CCIP. Residue: attester trust (Circle); fast-transfer liquidity fronting.
2. **Ecosystem-aligned bridge** = `Xm-lc || Xf{in-protocol}` — IBC Eureka, AggLayer/Superchain. Residue: finality latency; cross-ecosystem still slow.
3. **Solver price competition** = `In —e→ Ba{gated}` — UniswapX, Bungee/Jumper. Residue: non-execution risk; adverse selection.
4. **Wallet-coordinated messaging** = `Dx —i→ (In ? *)` — NEAR account aggregator / chain signatures, Avocado. Residue: wallet stickiness; policy-agent trust.
5. **Solver speed competition** = `In —e→ Rf{race}` — Across, Orbiter. Residue: centralization to well-capitalized solvers; liquidity-exhaustion attacks.
6. **Exclusive batch auction** = `In —e→ Ba{exclusive}` — (no pure production example; DFlow-adjacent). Residue: backstop-price dependence; no price improvement (F1).

**≥12 live chain-abstraction products** (each decomposes into the elements above; none forces a new element beyond the authority cluster, confirming H4): Across, Relay (Reservoir), deBridge DLN, Everclear (clearing/netting), CCTP v2 flows, ERC-7683 fillers (Eco Routes), LI.FI/Bungee, NEAR intents + chain signatures, Particle Universal Accounts, OneBalance, Safe + 7579 modules, Circle Gateway-class unified balances, IBC Eureka, AggLayer.

**≥4 near-isomer contrasts:** Across (`Rf{race}`, out-of-protocol oracle) vs CCTP v2 (`Xf{burn-mint}`, in-protocol attester); UniswapX (`Ba{gated}`) vs CoW (`Ba{batch}`); IBC Eureka (`Xm-lc`) vs LayerZero (`Xm-ev`); OneBalance (policy-agent `Dx`) vs Safe+7702 (smart-EOA `Dx`).

**≥6 cross-domain failure decompositions:** Wormhole = `Xm-ev` verification-signature-bypass defect ($326M); Nomad = `Xm-ev` init/logic defect ($190M); Ronin = `Xm-ev` key compromise ($625M); Multichain = `Xm-ev` MPC/operator failure ($126M); Harmony Horizon = `Xm-ev` key compromise; BadgerDAO = `Dx` unbounded-authority via compromised front-end ($120M — an authority-bond failure, not a mechanism failure — the key point for §3).

---

## Deliverable 9 — Recomputed Failure Overlay (three stages, count and dollar, membership shown)

**Categories:** (a) mechanism-verification/logic defect; (b) economic/design (oracle manipulation, reflexivity); (c) governance; (d) residue — now *named* (operational/key/opsec), not residual.

- **Before A's carve:** (d) ≈ 30% by count and *plurality by dollar*, because bridge exploits (Wormhole $326M, Ronin $625M, Nomad $190M, Multichain $126M) sat in (d) as "outside the table."
- **After B's carve:** those bridge cases move to (a) as `Xm` verification/key defects. B's coded set: (a) 37.5%, (b) 29.2%, (c) 4.2%, (d) 29.2%. B's (d) is now operational (BadgerDAO front-end, Multichain operator, key theft). **Membership differs even though the ~30% (d) total coincides with A — the row-22 trap; do not report agreement.**
- **After CAKE unification:** CAKE's Permission layer *names* the operational residue as authority-bond failures (`Dx`/`Gs`/custody trust). Category (d) does not shrink to zero; it becomes a labeled authority/opsec instrument joined by explicit bond. **2025 loss-weighted data confirms operational dominance:** TRM Labs (2026 Crypto Crime Report, via The Block, 27 Jan 2026) — "infrastructure attacks drove $2.2 billion in losses, representing 76% of the total stolen digital assets across 45 incidents" out of $2.87B; "adversaries moved up the stack, targeting operational infrastructure — keys, wallets, and control planes — over smart contract code." Hacken (2025 Yearly Security Report, via Cointelegraph, 30 Dec 2025) — "access control failures and broader operational security breakdowns accounted for about $2.12 billion, or nearly 54% of all 2025 losses, compared with around $512 million from smart contract vulnerabilities." Chainalysis ("2025 Crypto Theft Reaches $3.4 Billion," 18 Dec 2025) — total theft over $3.4B; the Bybit compromise alone $1.5B (a signing/opsec failure via a compromised Safe{Wallet} front-end, 21 Feb 2025); personal-wallet compromise $713M (20% of value, 158,000 incidents, 80,000 victims); DeFi protocol-exploit losses explicitly *"suppressed"/declining as a share* despite recovered TVL.

**New honest bound:** after unification, mechanism-explained failure (a+b+c) covers the *majority of incidents by count* but a *minority of 2025 dollars*; the dollar plurality is authority/opsec (the CAKE Permission layer's territory). Bridges — the dominant 2022 loss category (~$2B, ~69% of hacks per Chainalysis) — are materially reduced by 2025 and no longer a top standalone loss category (a genuine data gap: no primary firm published a clean 2025 bridge-only dollar figure precisely because bridges fell out of the top categories). **Unification converts A's bridge-residue into signal (a); it does NOT convert the operational residue into mechanism signal — it renames it as a bonded authority instrument (H6-lite inside H4).**

**Cross-chain reflexivity analogue:** a trust-domain cycle (chain X secured by a bridge secured by assets bridged from X) is structurally real and predicts wrapped-collateral cascades ex ante. But held to B's standard, it is a **hypothesis until a coded longitudinal dataset supports it**, not a theorem — and it did *not* ex-ante predict the specific bridge failures, which were verification/key defects (a), not reflexive cascades (b). The analogue is real but has weaker explanatory reach than A's within-domain reflexivity claim implied.

---

## Deliverable 10 — Empty Cells (≥12, with verdicts)

1. Cross-chain flash loan atomic across two finality domains — **infrastructure-blocked** (Zamyatin impossibility; shared-sequencer-repairable).
2. Trustless lock-mint bridge with canonical-collateral status — **bonding-rule-blocked** (R5).
3. Exclusive-auction solver with price improvement — **bonding-rule-blocked** (F1; CAKE-proven impossible).
4. Restaking-secured bridge validator set with slashing = trust-minimized `Xm-ev` — **viable-unbuilt** (EigenLayer AVS + bridge; nascent).
5. Private-mempool intent with full EV_signal capture — **reaction-condition-blocked** (private mempool cannot capture EV_signal per CAKE; latency race).
6. Same-block cross-rollup atomic DEX arbitrage — **infrastructure-blocked** (needs shared sequencer at scale; Espresso immature, Astria dead).
7. Policy-agent custody with on-chain-enforced spend caps across ecosystems — **viable-unbuilt** (7702 + 7579 modules; partially shipped).
8. Algorithmic stablecoin without reflexive collateral cycle — **economically-unattractive / bonding-blocked** (F2).
9. Cross-domain governance vote with lossless information + lossy value in one intent — **viable-unbuilt** (conservation law permits; CAKE lossless/lossy split enables).
10. Burn-mint bridge at shared-sequencer speed — **infrastructure-blocked** (shared sequencing immature).
11. Unified balance with MPC/TEE signing + optimistic reimbursement — **viable-unbuilt** (OneBalance/Circle Gateway direction).
12. Solver-bonding market with slashing for non-fill — **viable-unbuilt** (liquidity-exhaustion study shows the need; not yet standardized).
13. Light-client `Xm-lc` for Ethereum↔Solana (non-EVM) — **infrastructure-blocked → partially-unblocking** (IBC Eureka to Cosmos live; Solana light clients hard).
14. Gas sponsorship as first-class cross-chain paymaster settling in stablecoin — **viable-unbuilt/shipping** (CCTP v2 hooks + 7702 enable it).

---

## Deliverable 11 — Machine-Readable Package (abridged; extends B's JSON)

```json
{
  "elements": [
    {"id":"E-Xm-ev","symbol":"Xm-ev","name":"external-validator message verification","group_id":"cross-domain","period_id":"P4","layer":"settlement","trust_domain":"out-of-protocol","atom_dependency":"native","definition":"verifies a message/state from a source chain via an external validator set","trust_assumptions":["honest-majority of external set","key security"],"required_counterparts":["Xf"],"incompatible_or_unstable_with":["canonical-collateral without bonded slashing"],"common_parameterization":{"validator_n":"5..21"},"canonical_implementations":["LayerZero","Wormhole","Axelar"],"known_failure_modes":["key compromise (Ronin $625M)","verification logic (Nomad $190M)","signature bypass (Wormhole $326M)","operator/MPC (Multichain $126M)"],"maturity_decay_status":"mature","source_table":"B(split by CAKE)"},
    {"id":"E-Rl","symbol":"Rl","name":"resource lock / credible commitment","group_id":"control","period_id":"P3","layer":"permission","trust_domain":"n/a","atom_dependency":"repairable","definition":"an enforceable pre-commitment of assets/actions enabling cross-domain intent settlement","trust_assumptions":["lock honored by settlement contract"],"required_counterparts":["In"],"canonical_implementations":["ERC-6909 compacts","Across settlement"],"known_failure_modes":["stuck locks","liquidity exhaustion"],"source_table":"new(CAKE)","confidence":"medium"}
  ],
  "bonds":[
    {"source":"leverage","target":"oracle","bond_type":"trust","rule":"R1' cross-domain leverage requires explicit finality assumption","conditions":"cross_trust_domain","async_safe":"only-with-repair-bond","evidence":"Zamyatin 2019/2021 impossibility"},
    {"source":"In","target":"Ba","bond_type":"economic","rule":"F1 exclusivity XOR price-improvement","conditions":"exclusive access","async_safe":"n/a","evidence":"CAKE 2024; DFlow/Robinhood auctions"}
  ],
  "molecules":[
    {"protocol":"CCTP","version":"v2","formula":"Xf{burn-mint} —t→ Xm-ev{issuer-anointed}","reading":"token-anointed bridge","layer_span":["settlement"],"residue":"attester trust (Circle); fast-transfer liquidity fronting"}
  ],
  "amendments":[
    {"target":"element:RS","source_table":"A","change":"add restaking element absent from B","rationale":"EigenLayer slashing live 2025-04-17 (ELIP-002); distinct failure signature"},
    {"target":"element:Xm","source_table":"B","change":"split into Xm-lc/Xm-ev/Xm-ss by trust_domain","rationale":"distinct failure signatures per CAKE oracle typology"},
    {"target":"axis:period","source_table":"A","change":"reject trust-surface ordering; adopt dependency depth","rationale":"trust is multivariate, non-collinear with depth"},
    {"target":"bond_type:informational","source_table":"CAKE","change":"reject as fourth type","rationale":"EV_signal is economic bond conditioned on disclosure parameter"}
  ],
  "notation_map":[
    {"table_a_operator":"·","table_b_operator":"+","unified_operator":"+","meaning":"composition/co-presence"},
    {"table_a_operator":"⊕","table_b_operator":"||","unified_operator":"||","meaning":"alternative/parallel path"},
    {"table_a_operator":"⊗","table_b_operator":"*","unified_operator":"*","meaning":"parameterized combination"},
    {"table_a_operator":"ᵀ superscript","table_b_operator":"—t→","unified_operator":"—t→","meaning":"trust bond"},
    {"table_a_operator":"ᴱ superscript","table_b_operator":"—e→","unified_operator":"—e→","meaning":"economic bond"},
    {"table_a_operator":"ⁱ superscript","table_b_operator":"—i→","unified_operator":"—i→","meaning":"interface bond"},
    {"table_a_operator":"(none)","table_b_operator":"↺","unified_operator":"↺","meaning":"reflexive/self-referential dependency"}
  ]
}
```
`informational` dropped from the `bond_type` enum per Phase 4.

---

## Deliverable 12 — Amendment Register (change, source, forcing framework)
1. **Period axis:** reject A's trust-surface ordering → dependency depth. Source: A. Forcing: collinearity failure (Phase 4).
2. **Add `RS` restaking.** Source: A (B omission). Forcing: EigenLayer 2025 slashing.
3. **Add `CSM` constant-sum as element.** Source: A. Forcing: categorical failure signature.
4. **Split `Xm` → `Xm-lc`/`Xm-ev`/`Xm-ss`.** Source: B, forced by CAKE oracle typology. Forcing: distinct failure signatures.
5. **`Xf` forms = isotopes.** Source: B/CAKE. Forcing: shared function + conservation law.
6. **`atom_dependency` promoted to spectrum attribute.** Source: synthesis of A (`ATOM` catalyst) + B (environmental attribute). Forcing: row 10.
7. **Add Control/Authority group + provisional `Dx`,`Gs`,`Rl`,`Sk`.** Source: CAKE. Forcing: Phase 3.
8. **Add `trust_domain` attribute.** Source: CAKE oracle carve. Forcing: row 7.
9. **Reject `informational` bond type.** Source: CAKE. Forcing: Phase 4.
10. **Notation = B's; publish conversion map.** Source: B. Forcing: row 23.

---

## Deliverable 13 — Open Questions (B's instability-register format)
- **`Dx`/`Gs` element status (arbitrary call).** Currently provisional. *Settles when:* a coded corpus shows delegated-scope/paymaster failures with a signature distinct from generic authority-bond failures. If none, demote to bond properties (H6).
- **`Xm` one-element-with-attribute vs three-elements (convention).** *Settles when:* the failure dataset is large enough to show whether the three trust domains share enough mechanism to lump.
- **Cross-domain reflexivity analogue (hypothesis).** *Settles when:* a longitudinal trust-domain-cycle dataset either does or does not predict cascades ex ante.
- **Shared-sequencer atomicity (`Xm-ss`).** *Settles when:* a production shared sequencer sustains synchronous cross-rollup atomic settlement (not before late 2026 on current trajectory).

---

## Deliverable 14 — Caveats
- **Both source tables were read via the brief's own verbatim reproductions of their load-bearing claims (§0 and §1), not the raw uploaded files** — the file paths were not machine-accessible in this environment. Every element ID and claim attributed to A or B traces to the brief's ledger; where the brief did not specify an internal detail (e.g., B's exact symbol for constant-sum), I reasoned from the stated mechanism. This is the single largest caveat and should be resolved by re-running against the raw files.
- **No clean standalone 2025 bridge-exploit dollar figure** was published by Chainalysis/TRM/Hacken — bridges fell out of the top loss categories, which is itself the finding, but the precise 2025 bridge total is a genuine data gap.
- **2025 loss totals differ by publisher** (Chainalysis $3.4B, TRM $2.87B, Hacken ~$3.95B, CertiK $3.35B, SlowMist $2.935B, PeckShield $4.04B) — scope differences, not contradictions; the *directional* finding (operational dominates loss-weighted) is consistent across all.
- **Ronin dollar figure is contested** ($540M at time-of-theft per Elliptic; ~$625M at announcement prices) — most-cited is $625M.
- **CAKE is a Feb 2024 position paper**; several framings (EOA/AA binary, trilemma-as-fundamental) are already partly obsolete post-Pectra and post-CCTP v2. Treated as audited, not canonical.
- **Provisional elements (`Dx`,`Gs`,`Rl`,`Sk`,`Xm-ss`) carry low–medium confidence** and may collapse to bond properties.

---

## The Twelve Explicit Answers

1. **Row axis:** **Table B's minimum dependency depth survives**; trust becomes a multivariate attribute, not a row. Strongest argument against: CAKE's entire value proposition is trust-domain tradeoffs, so a reader focused on cross-domain security loses the at-a-glance trust ordering A offered — mitigated by the `trust_domain` attribute but not fully replaced.

2. **Genuine contradictions vs naming/convention:** of 24 rows, **~13 genuine contradictions** (1, 3, 4, 5, 6, 7, 8, 10, 11, 12, 18, 19, 20/21-as-a-pair, 22) and **~11 naming/convention differences** (2, 9, 13, 14, 15-soft, 16-soft, 17-soft, 23, 24, and the softer halves). The most consequential genuine contradiction is row 18 (conservation law), because it is H7.

3. **Does CAKE's Permission layer pass B's state-transition criterion?** **No — it fails as elements.** But `Up` is **not** inconsistently admitted: `Up` changes the protocol's reachable state machine; custody changes the authorized actor set. The honest output is **outcome 3 (authority is a bond property)**, with a small **H6-lite** residue: `Dx`/`Gs`/`Rl`/`Sk` provisionally admitted as authority-group elements pending failure-signature evidence.

4. **Which topology won?** **H4 (forward containment) as the structure, H7 (conservation law) as the organizing principle** — jointly. H1 is dead (CAKE's pipeline layers are request-lifecycle stages, not B's component-type stratification, and still are not a substitutability/dependency axis, so cannot be a *row*). H3 resolved as a spectrum attribute. H5 trivial. H6 survives only as the "authority instrument" caveat inside H4. Strongest case against H7: it may be *too* general — "you pay in loss, trust, or latency" risks unfalsifiability unless the three costs are independently measurable, which cross-domain they mostly are.

5. **Genuinely new CAKE elements:** **at most 3–4, all provisional** — delegated execution scope (`Dx`), gas sponsorship (`Gs`), resource lock (`Rl`), plus solver bonding (`Sk`). Custody/authority itself is a bond property (zero new elements). Shared-sequencer ordering (`Xm-ss`) is a *split* of an existing element, not new. Net: **CAKE contributed 3–4 provisional elements over B, none high-confidence.**

6. **Split `Xm` by trust domain?** **Yes** — light-client / external-validator / shared-sequencer, each with a distinct failure signature. **`Xf` forms?** **Isotopes**, not elements.

7. **Is `ATOM`...?** **A spectrum-valued attribute** (`atom_dependency`), not a discrete element (contra A) and not a dismissible environmental condition (contra B). The graduated atomicity spectrum is the synthesis.

8. **Is "informational" a fourth bond type?** **No.** `EV_signal` is an economic bond conditioned on an information-disclosure parameter; drop it from the schema.

9. **Residue after unification:** **by count**, mechanism-explained failure now covers the majority of incidents (bridges converted from (d) to (a)); **by dollar**, the residue is *larger* than A's or B's implied ~30%, because 2025 is dominated by operational/opsec loss (TRM: 76% / ~$2.2B infrastructure; Hacken: ~54% / ~$2.12B access-control; Chainalysis: Bybit $1.5B alone, personal-wallet $713M). What remains in the residue is **authority/operational-security failure** — key compromise, front-end injection, IT-worker infiltration, multisig/MPC compromise — which CAKE's Permission layer *names* but does not convert to mechanism signal.

10. **Cross-domain reflexivity analogue?** **Yes, structurally** (trust-domain cycles predict wrapped-collateral cascades), but it **did not predict the actual bridge failures ex ante** (those were verification/key defects, not reflexive cascades). Held to B's standard: a hypothesis, not a theorem.

11. **Trilemma?** **A soft tradeoff / artifact of 2024 engineering**, being relaxed (CCTP v2, IBC Eureka, shared sequencing). **H7's conservation law is the better invariant**, grounded in Zamyatin et al.'s proven impossibility of trustless cross-chain communication.

12. **Still a "periodic table"?** **Mostly yes, with an asterisk.** The core (mechanism elements, groups by substitutability, periods by dependency depth, bonds, isotopes, molecules) remains genuinely periodic-table-like. But the CAKE integration forces two additions that strain the metaphor: a *bond-property axis* (authority) that is not a row, and a *spectrum attribute* (atomicity) that behaves like a phase diagram, not a discrete cell. The honest name for the unified object is **a periodic table with a coupled phase diagram and an authority overlay** — still a table at its core, but no longer only a table.