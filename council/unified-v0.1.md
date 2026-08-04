# The Unified DeFi Element Table — v0.1 (pre-council draft)

**Object:** a typed state-transition atlas for decentralized finance — 53 core
elements, 14 substitutability groups, 5 dependency-depth periods, 4 typed bond
classes, a graduated atomicity spectrum, and an authority overlay.

**Provenance:** reconciled from four source reports — Table A
(`elementsdefi.md`, ~46 elements, trust-surface periods), Table B
(`elementsdefiGPT.md`, 48 elements, dependency-depth periods), and two
independent CAKE unifications (`CAKEClaude.md`, `CAKEGPT.md`).

---

## 1. Adjudication summary

Where the four sources agreed, the agreed position is adopted silently. This
section records only the **contested** calls and how v0.1 resolves them.

| # | Dispute | Sources | v0.1 ruling | Basis |
|---|---|---|---|---|
| D1 | Period axis: trust surface vs dependency depth | A vs B; both CAKE docs back B | **Dependency depth (P0–P4).** Trust becomes a non-ordinal `trust_domain` attribute | Trust is multivariate; a scalar forces a total order on a partial order |
| D2 | Atomicity test: 5 criteria vs 7 | A vs B | **B's 7 criteria** (F, R, S, D, B, P, O) | The extra three (state-transition boundary, execution-model portability, implementation observability) are what keep standards and UI artifacts out |
| D3 | Constant sum: element or isotope | A + CAKEClaude say element; B + CAKEGPT say isotope | **Isotope of `St`**, carrying a mandatory `drain_regime` flag | Criterion R (independent recurrence) is a hard gate and pure constant-sum standalone pools fail it. The failure signature is real, so it is preserved as a flag, not discarded |
| D4 | Informational bond: fourth type? | CAKEClaude rejects; CAKEGPT accepts | **Accept `—n→`, with a naming clause**: every informational edge must name the economic consequence it enables | Auditability is the entire reason bonds are typed at all. The naming clause prevents it becoming a free-floating label |
| D5 | Split `Xm` by trust domain? | CAKEClaude splits 3 ways; CAKEGPT keeps one | **One element `Xm` with a MANDATORY, non-defaultable `trust_domain` discriminator.** A formula writing bare `Xm` is ill-formed | Criterion S: a light client and a validator set occupy the same role boundary and are substitutable. That is an isotope, not a new element. The mandatory discriminator preserves the failure-signature distinction |
| D6 | Solver bonding `Sk` as an element | CAKEClaude yes; CAKEGPT says reuse `Bs` | **Rejected as an element**; expressed as `Bs{trigger=non-fill}` | Criterion F: bonded slashable capital is exactly `Bs`; only the trigger differs |
| D7 | Optimistic fill `Of` | CAKEGPT only | **Adopted as core** | The advance creates a reimbursement claim owned by neither `Xm` nor `Xf`; CCTP v2 Standard vs Fast is the clean discriminator |
| D8 | Unified balance `Ua` | CAKEGPT medium; CAKEClaude rejects as marketing | **Provisional**, admitted only under an enforceability gate | Both positions are right about different objects: a dashboard total fails, a non-double-spendable reconcilable claim passes |
| D9 | Shared ordering `Sq` / `Xm-ss` | CAKEGPT element; CAKEClaude an `Xm` split | **Provisional element `Sq`** | An ordering commitment is made before and independently of verification — a different state transition |
| D10 | Delegated scope: `Dx` vs `Au` | Same mechanism, two symbols | **`Au`** | Higher-confidence rating and the more standard term |
| D11 | Residue size | A ~1/3 by count; CAKEClaude inverts by dollar; CAKEGPT 0–4/24 | **Report both axes, never one number**: 0–4 of 24 by count (conservative 16.7%); loss-weighted majority remains operational | The two findings measure different things and are compatible |
| D12 | Is it still a "periodic table"? | All four: qualified yes | **"Periodic table" is retained as the name of the index only.** The whole object is a typed state-transition atlas with a coupled atomicity phase diagram and an authority overlay | There is no periodic law, no natural atomic number, and no closure by nature |

**Carried unanimously** (no dissent in any source): `Xm`/`Xf` split; concentrated
liquidity is an element; weighted pools are an element; health factor is a
derived observation of `Ct`; hooks are interface grammar; `In` is core; `Sb`/`Sd`
stay split; `Ps` is core; peg-arbitrage is a market reaction, not an element;
reflexivity is a hypothesis, not a theorem; Wormhole and Nomad are category (a)
`Xm` defects; restaking is restored as `Rs`; atomic composability is
spectrum-valued; the cross-chain trilemma is a soft tradeoff, not a law.

---

## 2. The object model

Nine constructs. Everything else in this document is one of these.

| Construct | Definition | Test |
|---|---|---|
| **Element** | An independently recurring, role-substitutable financial state-transition mechanism with a distinct failure signature | The seven-criterion atomicity test (§3) |
| **Group** | A family of elements that can occupy the same role boundary and leave the protocol recognizably the same kind of system | Substitutability |
| **Period** | Minimum dependency depth — what must already exist for the element to exist at all | P0–P4 (§5) |
| **Isotope** | A parameter or implementation variant that preserves the state-transition semantics and failure family | Continuous parameter change, same state space |
| **Bond** | A typed required relationship between elements: interface, economic, trust, informational | §7 |
| **Valence** | The typed vector of bonds an element requires: `V(e) = {Vi, Ve, Vt, Vn}` | §8 |
| **Molecule** | A deployed protocol-version expressed as elements + parameters + typed bonds + reaction conditions + residue | §10 |
| **Catalyst** | A mechanism that enlarges the reachable transaction states but leaves no enduring claim | Two-part test (§12) |
| **Residue** | What a decomposition leaves unexplained — reported, never hidden | §15 |

Three **attributes** are carried on every element and are *not* rows:
`trust_domain` (who can attest, censor, upgrade, pause, mint), `layer` (the CAKE
request-pipeline stage: Application / Permission / Solver / Settlement), and
`atom_dependency` (position on the atomicity spectrum, §13).

---

## 3. The atomicity test

An entity is an element if and only if all seven hold:

| Test | Requirement |
|---|---|
| **F** — functional irreducibility | No decomposition into two independently recurring mechanisms reproduces the function without losing its defining state transition |
| **R** — independent recurrence | At least three unrelated teams and at least two independent code lineages. Forks count once |
| **S** — role-preserving substitutability | A sibling can replace it at the same role boundary and the application stays the same protocol class |
| **D** — distinct failure signature | It creates at least one failure mode not fully attributable to another element |
| **B** — state-transition boundary | It changes claims, obligations, allocation, valuation or settlement — not merely an API or a user interface |
| **P** — execution-model portability | Its semantics can be stated without assuming EVM calls, storage or transaction ordering |
| **O** — implementation observability | Identifiable in documentation, interfaces, state variables, events or auditable execution |

**The four standing rejections** this test produces, which are the most common
modelling errors:

- **Standards are not elements.** ERC-4626, ERC-7540, ERC-7683 and ERC-7802 are
  interface bonds. The standard is the socket; the mechanism is the appliance.
- **Hooks and callbacks are not elements.** A Uniswap v4 hook is a bonding site.
  Classify a deployed hook by the mechanism it instantiates.
- **Narratives are not elements.** "Points", "real yield", "restaking narrative",
  "intent-centric", "unified balance as UX" all fail B.
- **Derived observations are not elements.** A health factor reports the result
  of `Ct`; it changes nothing.

---

## 4. The 53 core elements

`atom` column: **N** async-native · **R** async-repairable · **I** async-impossible.

### G01 — Claims and accounting (P0)

| ID | Sym | Name | Period | atom | Definition |
|---|---|---|---|---|---|
| E001 | `Sh` | Pro-rata share accounting | P0 | R | Shares represent a proportional pool claim |
| E002 | `Ix` | Index-based accrual | P0 | R | A global exchange-rate or debt index changes claim value |
| E003 | `Rb` | Rebasing accounting | P0 | R | Nominal balances change through global scaling |

### G02 — Pool pricing (P1)

| ID | Sym | Name | Period | atom | Definition |
|---|---|---|---|---|---|
| E004 | `Cp` | Constant-product invariant | P1 | R | `x·y = k` |
| E005 | `Wg` | Weighted-geometric invariant | P1 | R | Multi-asset weighted pricing |
| E006 | `St` | Stable-hybrid invariant | P1 | R | Constant-sum near parity, constant-product away from it. **Isotopes:** `{A}` amplification; `{constant-sum}` limiting case, carries `drain_regime` |
| E007 | `Cl` | Concentrated liquidity | P1 | R | Range-specific position state and tick activation |
| E008 | `Pm` | Oracle-priced inventory curve | P1 | R | Proactive market making against an external reference |

### G03 — Execution and routing (P1–P4)

| ID | Sym | Name | Period | atom | Definition |
|---|---|---|---|---|---|
| E009 | `Ob` | On-chain order book | P1 | R | Limit orders, sequencing, cancellation, settlement |
| E010 | `Rf` | Request for quote | P1 | N | Signed maker quote against inventory |
| E011 | `Ba` | Batch-auction clearing | P2 | N | Uniform clearing over a batch |
| E012 | `In` | Intent and solver execution | P4 | N | Signed outcome constraints delegated to competing solvers |
| E039 | `Ag` | Aggregation and routing | P1 | R | Multi-venue route construction |
| E040 | `Fl` | Atomic flash liquidity | P1 | **I** | Borrow and repay within one transaction or revert |

### G04 — Credit (P3)

| ID | Sym | Name | atom | Definition |
|---|---|---|---|---|
| E013 | `Pl` | Pooled lending | R | Shared liquidity pool, many lenders and borrowers |
| E014 | `Im` | Isolated lending market | R | Per-market risk isolation with its own oracle, LLTV, rate model |
| E015 | `Cd` | Collateralized-debt minting | R | Mint a liability against locked collateral |
| E016 | `Uc` | Undercollateralized credit | N | Credit extended on identity, underwriting and recourse |
| E017 | `Ft` | Fixed-term debt | N | Maturity-dated claim with a discount factor |

### G05 — Solvency (P3)

| ID | Sym | Name | atom | Definition |
|---|---|---|---|---|
| E018 | `Ct` | Collateral-threshold solvency test | R | The margin/LTV/health computation and its threshold |
| E019 | `Li` | Incentivized liquidation | R | Third parties repay unhealthy debt for discounted collateral |
| E020 | `Ad` | Auto-deleveraging | R | Rank-ordered forced close when buffers are exhausted |
| E021 | `Sl` | Socialized-loss allocation | N | Losses assigned to an explicit claim class |
| E022 | `Bs` | Staked backstop | R | Slashable first-loss capital. **Isotope:** `{trigger=non-fill}` = solver bonding |

### G06 — Risk transfer (P3)

| ID | Sym | Name | atom | Definition |
|---|---|---|---|---|
| E023 | `Pf` | Perpetual funding transfer | R | Periodic payment tethering a perp to an index |
| E024 | `Op` | Option payoff | N | Strike, expiry, collateralized contingent settlement |
| E025 | `Tr` | Tranche waterfall | N | Non-overlapping seniority over an explicit loss event |
| E026 | `Cv` | Mutual cover pool | N | Adjudicated claims against pooled premium capital |
| E027 | `Py` | Principal/yield separation | N | Split a yield-bearing claim into PT and YT |

### G07 — Truth (P2)

| ID | Sym | Name | atom | Definition |
|---|---|---|---|---|
| E028 | `Ex` | External data oracle | N | Imported off-chain value. **Isotopes:** `{push}`, `{pull}`, `{medianizer}` |
| E029 | `Tp` | On-chain time-weighted price | R | Cumulative-price accumulator over a window |
| E030 | `Oa` | Optimistic assertion oracle | N | Assert-then-dispute escalation game |
| E031 | `At` | Reserve or NAV attestation | N | Custodian/auditor statement of backing |

### G08 — Time and queueing (P2)

| ID | Sym | Name | atom | Definition |
|---|---|---|---|---|
| E032 | `Sr` | Streaming or dripping accrual | N | Continuous per-second transfer from escrow |
| E033 | `Ep` | Epoch-gated transition | N | Snapshot, cutoff, rollover |
| E034 | `Wq` | Asynchronous withdrawal queue | N | Request now, claim later, against future asset availability |

### G09 — Incentives (P2)

| ID | Sym | Name | atom | Definition |
|---|---|---|---|---|
| E035 | `Em` | Protocol-funded emissions | N | Newly issued tokens paid for measured actions |

### G10 — Control and authority (P3–P4)

| ID | Sym | Name | Period | atom | Definition |
|---|---|---|---|---|---|
| E036 | `Tg` | Delayed-governance execution | P4 | N | A timelock between authorization and executability |
| E037 | `Up` | Mutable implementation proxy | P4 | N | Code replacement changes the reachable state machine |
| E038 | `Gp` | Emergency guardian or pause | P4 | N | Bounded suppression of reachable transitions |
| E050 | `Au` | Delegated execution scope | P4 | N | Persistent policy bounding the calls, assets, destinations, values, chains and time windows a delegate may reach |
| E051 | `Gs` | Gas sponsorship obligation | P3 | N | Conditional fee liability with metering and reimbursement |

### G11 — Cross-domain (P4)

| ID | Sym | Name | atom | Definition |
|---|---|---|---|---|
| E041 | `Xm` | Cross-domain message verification | N | Decide whether a source-domain assertion is acceptable at the destination. **Mandatory** `trust_domain` ∈ {light-client, native-consensus, external-validator, optimistic, zk-assisted, shared-sequencer-assisted} |
| E042 | `Xf` | Cross-domain asset transfer | N | Create a destination claim against an explicit source debit. **Isotopes:** `{lock-mint}`, `{burn-mint}`, `{custodial-release}` |
| E053 | `Rl` | Resource lock or reservation | N | Enforceable pre-commitment with exclusivity, expiry, fulfillment and release |
| E054 | `Of` | Optimistic fill and reimbursement | N | A filler advances destination value before finality and holds a contingent reimbursement claim |

### G12 — Stability (P3)

| ID | Sym | Name | atom | Definition |
|---|---|---|---|---|
| E043 | `Rd` | Direct redemption right | R | Redeem a liability against backing at a defined rate |
| E044 | `Ps` | Peg-swap module | N | 1:1 reserve-backed swap with mint/burn authority |
| E045 | `As` | Algorithmic supply adjustment | N | Supply expansion/contraction driven by measured price |

### G13 — Access and privacy (P2)

| ID | Sym | Name | atom | Definition |
|---|---|---|---|---|
| E046 | `Aw` | Permission or identity gate | N | Credential-checked eligibility, enforced at transfer time where eligibility follows the holder |
| E047 | `Sb` | Shielded-balance state | R | Commitments and nullifiers hide ownership |
| E048 | `Sd` | Selective-disclosure proof | N | Prove a policy predicate without revealing the underlying credential |

### G14 — Security reuse (P4)

| ID | Sym | Name | atom | Definition |
|---|---|---|---|---|
| E049 | `Rs` | Restaking / shared security | N | Slashable capital reused to secure additional services |

### Provisional register (10 — not core)

| ID | Sym | Candidate | Gate that would promote it |
|---|---|---|---|
| P001 | `Bc` | Bonding-curve issuance | Primary-issuance semantics that resist AMM decomposition |
| P002 | `Tw` | Time-weighted AMM execution | Evidence it is not AMM + `Ep` |
| P003 | `Da` | Dutch-auction descent | Three unrelated lineages with unique liveness/manipulation behaviour |
| P004 | `Cg` | Credit delegation | Delegated obligations not reconstructible from `Pl`/`Uc` + `Au` |
| P005 | `Ir` | Insurance reserve fund | An accumulation/depletion/payout state machine distinct from `Bs` and `Sl` |
| P006 | `Zk` | Verifiable state proof | Finance-specific proof semantics, not generic infrastructure |
| P007 | `Ve` | Vote-escrow allocation | A transition not decomposable into lock + checkpoint + `Em` + governance |
| P008 | `Kg` | Credential-gated transfer | Failure semantics distinct from `Aw` |
| P009 | `Ua` | Enforceable unified-balance ledger | **Enforceability gate:** a non-double-spendable, reconcilable multi-domain claim, not a dashboard total |
| P010 | `Sq` | Shared ordering commitment | Production systems with durable ordering commitments whose failures are not just consensus + `Xm` |

---

## 5. Periods — minimum dependency depth

| Period | Meaning | Count | Members |
|---|---|---|---|
| **P0** | Ledger-local claims and accounting | 3 | `Sh` `Ix` `Rb` |
| **P1** | Deterministic transformation inside one execution domain | 9 | `Cp` `Wg` `St` `Cl` `Pm` `Ob` `Rf` `Ag` `Fl` |
| **P2** | Externally measured or time-conditioned state | 12 | `Ba` `Ex` `Tp` `Oa` `At` `Sr` `Ep` `Wq` `Em` `Aw` `Sb` `Sd` |
| **P3** | Contingent obligation, solvency, risk transfer, stability | 19 | `Pl` `Im` `Cd` `Uc` `Ft` `Ct` `Li` `Ad` `Sl` `Bs` `Pf` `Op` `Tr` `Cv` `Py` `Rd` `Ps` `As` `Gs` |
| **P4** | Multi-agent, cross-domain or mutable-control coordination | 10 | `In` `Tg` `Up` `Gp` `Xm` `Xf` `Rs` `Au` `Rl` `Of` |

The period is a **stable identifier**, not a magnitude. It does not need to
change when a protocol swaps a multisig for a light client — that is a
`trust_domain` change.

---

## 6. Groups — substitutability families

A group answers: *what else could sit at this role boundary?* Fourteen groups,
listed in §4. The operational use is **substitution testing**: to check whether
two protocols are the same kind of system, replace each element with a group
sibling and ask whether the protocol is still recognizable.

Group membership carries no periodic law. It is a lookup table for "what are my
alternatives", not a prediction of shared properties.

---

## 7. The four bond types

A protocol formula is not valid merely because the contracts can call each
other. Each bond type must be satisfied **separately**.

| Bond | Arrow | Question it answers | Failure mode when unsatisfied |
|---|---|---|---|
| **Interface** | `—i→` | Can these components exchange the required calls, tokens, messages or proofs? | Integration breakage, silent accounting corruption |
| **Economic** | `—e→` | Do the combined incentives, liquidity, valuation and loss allocation stay solvent? | Bad debt, runs, unprofitable liquidation |
| **Trust** | `—t→` | Who can attest, censor, upgrade, pause, mint or otherwise alter the result? | Key compromise, malicious upgrade, false attestation |
| **Informational** | `—n→` | Who observes amount, urgency, route, constraints or wallet state before settlement? | Adverse selection, front-running, order-flow capture |

**The naming clause (v0.1 amendment).** An informational bond is only
well-formed if it names the economic consequence it enables. `In —n→ solver`
is incomplete; `In —n→ solver [enables: adverse selection on unfilled
constraints]` is well-formed. This keeps the fourth type auditable rather than
decorative, and answers the parsimony objection that it is merely an economic
bond in disguise.

**Why four and not three.** Observation requires no call, transfer, incentive or
attestation to pass between the observed order and the observer. Folding it into
the economic bond makes private-order-flow and solver-information analysis
unauditable — and the entire justification for typing bonds is auditability.

**Why four and not five.** No candidate fifth type survives: legal
enforceability is a `trust_domain` value, latency is a reaction condition, and
authority is a bond property, not a bond type.

---

## 8. Valence

`V(e) = {Vi(e), Ve(e), Vt(e), Vn(e)}` — the typed set of required counterparts.

Valence is a vector, never an integer. `Cp` has near-zero valence: custody and
arbitrage. `Pl` has high valence: claim accounting, truth, a solvency test,
liquidation, loss allocation, exit liquidity, and usually mutable risk
governance. Valence predicts integration cost and audit surface directly.

---

## 9. Attributes (not rows)

| Attribute | Values | Why it is not a row |
|---|---|---|
| `trust_domain` | code-only · counterparty · reporter/publisher · custodian · validator-set · light-client · governance · legal | Multivariate — an element can depend on governance *and* reporters *and* legal recourse simultaneously |
| `layer` | Application · Permission · Solver · Settlement | A request-pipeline stage, not a component-type stratum; one element can span several in a molecule |
| `atom_dependency` | async-native · async-repairable · async-impossible | Graduated, and it changes with the deployment environment |

The `layer` attribute is where CAKE's contribution lives structurally. CAKE is
**not a rival table**: it is a fine-grained magnifier over the
Permission / Solver / Settlement region of this one.

---

## 10. Molecules and notation

`Protocol@version = {elements and parameters} + {typed bonds} + {reaction conditions} + {residue}`

| Operator | Meaning |
|---|---|
| `A+B` | Shared state machine, balance sheet or settlement invariant |
| `A\|\|B` | Mixture — separable component balance sheets (aggregators, meta-protocols) |
| `A*` | Catalyst, absent from the terminal balance sheet |
| `A{k=v}` | Isotope or parameterization |
| `A?` | Optional element |
| `A\|B` | Alternative at one role boundary |
| `A↺` | Reflexive economic feedback |
| `—i→ —e→ —t→ —n→` | Typed bonds |

A formula is **ill-formed** if it writes bare `Xm` without a `trust_domain`, or
an `—n→` edge without a named consequence.

**Worked formulas:**

| Protocol | Formula |
|---|---|
| Uniswap v3 | `Sh+Cl{feeTier,tickSpacing}+Tp+Fl*` |
| Aave v3 | `Pl+Ix+Ct+Ex{push}+Li+Bs+Gp+Up+Tg+Im{isolation}` |
| Maker/Sky MCD | `Cd+Ix+Ct+Ex+Li{auction}+Ps+Sh{DSR}+Tg+Gp+Up` |
| Liquity v1 | `Cd+Ct+Ex+Li+Rd+Bs{stability-pool}+Sl?` |
| GMX v2 | `Sh+Pm+Ex+Pf+Ct+Li+Bs?+Sl?` |
| CoW Protocol | `In+Ba+Ag+Rf? —n→ solvers [enables: adverse selection]` |
| CCTP v2 Standard | `Au{issuer-mint}+Xm{native-consensus}+Xf{burn-mint}` |
| CCTP v2 Fast | `Au+Xm{native-consensus}+Xf{burn-mint}+Of` |
| Across | `In+Rf+Of+Xm{optimistic}+Xf` |
| Centrifuge RWA | `Uc+Ft+Tr+Sh+At+Aw+Wq+Xm?` |
| Terra/Anchor (dead) | `As+Rd{LUNA-conversion}+Ex+Pl+Ix+Em↺` |

---

## 11. Bonding laws

### Required bonds

| Rule | Statement | Async-safe? |
|---|---|---|
| **L1 Leveraged obligation** | `(Pl\|Im\|Cd\|Pf\|Op) → (Ex\|Tp\|At) + Ct + (Li\|Ad\|Sl\|Bs)` | **No** — cross-domain it additionally requires an explicit `finality_assumption` and a liquidation-latency bound |
| **L2 Pooled claim** | `Pl → (Sh\|Ix) + exit-liquidity` | Yes |
| **L3 Undercollateralized credit** | `Uc → Aw + At + (Bs\|Tr)` | Yes |
| **L4 Perpetual** | `Pf → Ex + Ct + Li + (Ad\|Sl\|Bs)` | No |
| **L5 Yield separation** | `Py → (Sh\|Ix\|Rb) + Ep + Rd` | Yes |
| **L6 Tranche** | `Tr → explicit loss event + non-overlapping seniority` | Yes |
| **L7 Stable liability** | `Cd → Rd \| Ps \| liquidation capacity` | Yes |
| **L8 Cross-domain asset** | `Xf → Xm \| named custodian` + global claim ledger | Yes |
| **L9 Supply conservation** | `Xf → debit(source) = credit(destination)` | Yes |
| **L10 Shielded state** | `Sb → proof verifier + nullifier set` | Yes |
| **L11 Selective disclosure** | `Sd → credential source + verifier + revocation` | Yes |
| **L12 Intent** | `In → signed constraints + settlement verifier + solver/fallback + timeout` | Yes |
| **L13 External truth** | `Ex → freshness validation`; `Gp` strongly preferred for high-value obligations | Yes |
| **L14 Asynchronous asset** | `illiquid backing → Wq \| bounded liquidity reserve` | Yes |
| **L15 Upgradeable value** | `Up → Tg \| bounded emergency process` | Yes |
| **L16 Permission persistence** | `Aw → transfer-time enforcement` where eligibility follows the holder | Yes |
| **L17 Bounded authority** | `Au → bounded scope + revocation + expiry + nonce/domain separation` | Yes |
| **L18 Message verification** | `Xm → explicit finality + chain/domain binding + replay protection` | Yes |
| **L19 Optimistic fill** | `Of → Xm + Xf + (Bs\|Sl) + timeout` | Yes |
| **L20 Resource lock** | `Rl → Au + single-spend + expiry + fulfillment proof + release` | Yes |
| **L21 Sponsorship** | `Gs → Au + metering + fee settlement` | Yes |
| **L22 Security reuse** | `Rs → attributed slash condition + non-reflexive capital + loss waterfall` | Yes |
| **L23 Ordering commitment** | `Sq → Xm + independent settlement finality` | Yes |
| **L24 Disclosure** | `(In\|Rf\|Ba) → an explicit —n→ edge naming who observes what` | Yes |
| **L25 Wrapped collateral** | wrapped cross-domain collateral → bridge-specific haircut + cap + independent exit | Yes |

### Forbidden and empirically unstable bonds

| # | Combination | Class | Grounding |
|---|---|---|---|
| **X1** | `As` + reflexive junior token, without hard redemption or exogenous capital | Radioactive | Terra/UST, May 2022 (~$40B) |
| **X2** | `Fl*` + manipulable `Cp`/`Cl` price + `Pl`/`Cd` | Unstable→forbidden | bZx 2020; Mango 2022 (~$116M); Cream 2021 |
| **X3** | Protocol-issued token as collateral **and** oracle market **and** backstop | Highly reflexive | One confidence shock impairs all three defences at once |
| **X4** | `Rb` into a ledger assuming balance invariance, without an adapter | Interface-forbidden | Rebasing/wrapper incompatibilities |
| **X5** | Illiquid backing + uncapped instant par redemption | Economically unstable | Promises a settlement speed the assets cannot provide |
| **X6** | Flash-borrowed voting power + immediate execution | Trust-forbidden | Beanstalk, Apr 2022 (~$182M) |
| **X7** | Cross-domain mint without independent verification and supply accounting | Catastrophic | Wormhole ($326M), Nomad ($190M) |
| **X8** | Shared collateral across nominally isolated markets | Invalid isolation bond | Contagion escapes the advertised boundary |
| **X9** | `Up` with immediate single-key control | Trust-unstable | Correct finance, arbitrary code replacement |
| **X10** | `Pm` with a stale reference price and unrestricted inventory | Unstable | Inventory exhausted before the reference updates |
| **X11** | `Uc` without `Aw`, `At`, collateral or enforceable reputation | Forbidden | Maple writedowns (~$36M, 2022) |
| **X12** | `Xf{lock-mint}` wrapped asset used as canonical collateral without issuer anointing | Forbidden | Wormhole-wrapped assets, Harmony Horizon, Multichain |
| **X13** | External-validator `Xm` securing high-value canonical settlement without bonded slashing | Unstable | Ronin ($625M), Nomad ($190M) |
| **X14** | Solver exclusivity + a claim of competitive price improvement | Impossible | Exclusivity removes the live counterfactual |
| **X15** | `Rs` securing a bridge mostly with assets issued by that bridge | Radioactive | Verifier security and asset backing fail together |
| **X16** | `Au` granted at entry + unrestricted bearer transfer of the authority | Trust-invalid | BadgerDAO (~$120M) — unbounded approvals harvested |
| **X17** | Passive protocol-token reserve backing protocol-token collateral | Reflexive backstop | The reserve loses value precisely when needed |
| **X18** | `Oa` as the sole truth element for high-frequency liquidation | Reaction-condition-blocked | Dispute latency vs margin closeout speed |

---

## 12. Catalysts

A catalyst must both **enlarge the reachable transaction states** and **leave no
enduring financial claim**.

| Catalyst | Enables | Safety effect |
|---|---|---|
| `Fl` | Atomic arbitrage, collateral swap, refinancing, self-liquidation, governance acquisition | Removes capital scarcity as an attack barrier — any bond that was "safe because manipulation is expensive" becomes unsafe |
| `Ag` | Multi-venue price discovery | Reduces slippage, expands adapter and approval surface |
| `Xm` | Remote state transitions | Enables cross-domain compounds, introduces finality and verifier trust |
| Solver competition on `In`/`Ba` | Route, inventory and coincidence-of-wants search | Can internalize MEV; creates liveness, collusion and concentration risk |

`Fl` is listed as both a P1 element and a catalyst: its atomic-repayment
obligation *is* a financial state transition, which is why it is an element, and
it leaves no terminal claim, which is why it acts as a catalyst.

**A catalyst is never itself the vulnerability.** The vulnerability is always
the bond it catalyzes.

---

## 13. The atomicity spectrum

Atomicity is not binary. This is the phase diagram coupled to the table.

| Level | Meaning | Repair |
|---|---|---|
| Same transaction | All state changes commit or revert together | None needed |
| Same block | Separate transactions, adversarially orderable | Batch clearing, commit-reveal, preconfirmation |
| Shared sequencer | Several domains accept a common ordering commitment | `Sq` + accountability/slashing + later verification |
| Same-ecosystem finality | Domains share or closely coordinate finality | Ecosystem-aligned `Xm` + explicit timeout |
| Cross-ecosystem | Independent consensus and finality domains | `Xm+Xf+(Rl\|Of)` + haircuts + loss allocation |
| Optimistic | Destination value advanced before canonical finality | `Of+(Bs\|Sl)` + challenge + reimbursement timeout |

**The standing prediction this produces:**

> No cross-chain flash liquidity exists without an intermediary, precommitted
> credit, or a shared rollback domain.

`Fl` is the only **async-impossible** element. Any product marketed as
"cross-chain flash" is really `Of+Rl+(Bs|Sl)` — which has a lender, a
reservation, a loss allocator and a finality assumption that the word "flash"
hides.

---

## 14. Conservation laws

Three invariants replace the discarded cross-chain "trilemma". The trilemma is
a soft engineering tradeoff being actively relaxed; these are the durable rules.

**Value:**
> destination credit = verified source debit + explicitly underwritten advance − fees − realized allocated loss

**Authority:**
> executed authority ⊆ valid, domain-bound, unexpired delegated scope

**Information:**
> a claim may be withheld or delayed, but its provenance and meaning must not be silently mutated across a trust boundary

The generalization is *not* "value may disappear". It is: **any loss, fee,
slippage, delay or advance must be assigned to an explicit claim class or a
named underwriter.** An unassigned loss is a modelling error, and in production
it is someone's uncompensated risk.

The grounding impossibility result is Zamyatin et al., *SoK: Communication
Across Distributed Ledgers* — correct cross-chain communication reduces to fair
exchange and is impossible without a trusted third party. Apparent
counterexamples (fast transfers, shared sequencing) pay for the third pole with
a trust assumption.

---

## 15. Overlays

### Reflexivity (hypothesis, not theorem)

A reflexive bond exists where an element's output materially determines one of
its own solvency inputs. The dangerous form is the **triple loop**: the
protocol-issued token supplies collateral value, market depth *and* insurance
capital simultaneously.

The **cross-domain analogue** is a trust-domain cycle: chain X depends on
bridge B, while B's verifier capital or revenue depends on assets issued through
B or on X's value.

Status is deliberately downgraded from Table A's "master predictor". Terra
supports it at system scale; Mango supports the narrower claim that thin
endogenous markets are unsafe borrowing inputs. Neither supplies longitudinal
coding, matched controls, or a false-positive rate. **It is the strongest
available ex-ante screen and it is not proven.**

### Decay ("radioactivity")

Half-life is measured in support variables, not calendar time.

| Pattern | Elements | Observable |
|---|---|---|
| Reflexive decay | `As`, protocol-token backstops | Collateral quality, reserve value and exit depth fall together |
| Liquidity migration | Old AMM versions | Active depth and arbitrage participation decline |
| Governance abandonment | `Up`, `Gp`, `Tg` | Keys, delegates, keepers stop functioning |
| Oracle obsolescence | `Ex`, `Tp` | Data available but no longer tracks a liquid market |
| Bridge trust decay | `Xm`, `Xf` | Verifier set or operator availability deteriorates |
| Emission decay | `Em` | Rewards become pure dilution |
| Integration decay | `Rb`, unusual tokens | Downstream systems drop support |
| Legal decay | `At`, `Aw`, RWA | Documents or priority stop matching the token |

### Failure overlay and the honest bound

Four root categories: **(a)** defective element instance · **(b)** invalid bond
between valid elements · **(c)** environment outside stability range ·
**(d)** outside the table.

| Stage | Category (d) by count | Composition |
|---|---|---|
| Table A as published | ~30–35% | Bridge-dominated — Wormhole, Nomad, Ronin sat outside |
| Table B as published | 7/24 = 29.2% | Wormhole and Nomad moved to (a); residue is operational |
| **Unified** | **0–4 of 24 (conservative 16.7%)** | Ronin becomes `Xm —t→ Au`; BadgerDAO becomes `—n→` + unbounded `Au`; Multichain becomes an operator authority-trust failure |

**Report both axes. Never one number.** By count the unified table explains the
majority of incidents. By 2025 dollars it does not: loss-weighted reporting is
dominated by operational and key compromise (TRM: ~$2.2B / 76% infrastructure;
Hacken: ~$2.12B / ~54% access control; the Bybit signing compromise alone
~$1.5B). The table models the *propagation path* of such losses through `Au`
and `—n→`; it does not predict phishing, coerced signers, malicious front-ends,
compromised build systems or fraudulent legal documents.

That is the scope statement:

> coverage = financial state transitions + typed bonds + authority policy + information exposure + reaction conditions

---

## 16. Reaction conditions

A molecule is stable only inside an environmental operating range.

| Condition | Elements most affected | Question |
|---|---|---|
| Block time and finality | `Ob` `Li` `Xm` `Xf` `In` | Can cancellation, liquidation or remote settlement finish before value moves? |
| Mempool and MEV regime | `Cp` `Cl` `Ob` `Ba` `In` `Fl` | Is extractable value beyond tolerated bounds? |
| Oracle latency and confidence | `Pl` `Cd` `Pf` `Pm` `Ct` | Is the value current relative to volatility and liquidation time? |
| Executable market depth | `Li` `Rd` `Ps` `Ct` | Can collateral actually be sold near its marked value? |
| Gas and congestion | `Li` `Oa` `Ep` `Wq` | Can required actors afford to challenge, settle or roll over? |
| Withdrawal settlement cycle | `Wq`, RWA, staking | Does queue duration match backing liquidity? |
| Validator/operator concentration | staking, app-chains, `Xm` | Can one group censor, reorder, attest or halt? |
| Governance reaction speed | `Tg` `Gp` `Up` | Fast enough for emergencies, slow enough for oversight? |
| Legal enforceability | `Uc` `At` `Aw` | Does the on-chain claim correspond to an enforceable off-chain priority? |
| Solver market structure | `In` `Ba` `Rf` `Of` | Is the resolver set concentrated enough to sustain rents or exhaust liquidity? |

---

## 17. How to use the table

### 17.1 Decompose a protocol (four passes)

1. **Elements.** Name every recurring financial state transition. Reject
   standards, hooks, narratives and derived observations as you go.
2. **Typed bonds.** Draw `—i→ —e→ —t→ —n→` separately. Most exploits are
   interface-valid and economically or trustfully invalid.
3. **Reaction conditions.** State the operating range assumed.
4. **Residue.** Write down what did not decompose. Residue is a finding, not a
   defect to hide.

### 17.2 Screen a design (pre-audit checklist)

Run in this order; each is cheap and each has killed a real protocol.

1. **Reflexivity check.** Does any element's price or solvency input read a
   market its own output dominates? If yes → X1/X3/X17. Stop and redesign.
2. **Leverage check (L1).** Does anything let a position control more value
   than posted? If yes, it needs truth **and** `Ct` **and** a terminal loss
   path. Cross-domain, it also needs a named finality assumption.
3. **Truth-manipulability check (X2).** Is the truth element a market the
   attacker can move with borrowed capital? Price the manipulation against pool
   depth, not against the attacker's balance.
4. **Authority check (L17).** Every `Au`, `Up`, `Gp` — is scope bounded, is
   there revocation, expiry and domain separation?
5. **Conservation check.** For every fee, slippage, delay, loss and advance:
   name the claim class or the underwriter that absorbs it. Anything unassigned
   is an unpriced risk.
6. **Atomicity check.** Place every cross-domain step on the spectrum. Anything
   marketed as atomic but sitting below "same transaction" needs its repair
   bond named.
7. **Disclosure check (L24).** Who sees the order before it settles, and what
   does that let them do?

### 17.3 Diagnose an incident

Ask, in order: was a single element's implementation defective **(a)**; were
valid elements bonded invalidly **(b)**; was the environment outside the stated
range **(c)**; or was the initiating cause outside the table entirely **(d)**?

The discriminating question between (a) and (b) is: *would a correct
implementation of every element still have failed in this combination?* If yes,
it is (b) — a bond defect, and the table predicted it. Euler is (a): a missing
health check in a new transition. Mango is (b): every element worked as coded
against an economically invalid truth input.

### 17.4 Find gaps

Enumerate permitted combinations that no deployment occupies, then assign each
a verdict: **viable-unbuilt** · **infrastructure-blocked** ·
**bonding-rule-blocked** · **reaction-condition-blocked** ·
**economically-unattractive**. A bonding-rule-blocked cell is a prediction that
building it will fail; a viable-unbuilt cell is a product opportunity.

Representative open cells: proof-verified cross-chain isolated lending
(infrastructure-blocked); selectively-disclosed private pooled lending
(viable-unbuilt); batch-auction liquidations (viable-unbuilt); tranched perp-LP
risk (viable-unbuilt); restaking-secured bridge verifier sets (viable-unbuilt);
uniform session-key policy across VM families (standards-blocked); anonymous
undercollateralized credit (forbidden, X11).

### 17.5 Compare near-isomers

Write both formulas and diff them. The remaining symbols are the real
difference; everything else is branding. If two systems reduce to the same
formula, the table asserts they are the same *kind* of system and localizes the
practitioner-perceived difference to isotopes, reaction conditions or residue.

---

## 18. What this table is not

- It is not closed by nature. Elements are designed, not discovered; a new
  primitive can ship next week.
- There is no periodic law. Properties do not recur periodically down a group.
- There is no natural atomic number. IDs are stable identifiers, nothing more.
- It does not predict operational compromise, and by 2025 dollars that is where
  the losses are.
- It is a versioned scientific model: closed against a stated corpus,
  falsifiable through residue, amendable only through evidence.

---

## 19. Open questions (instability register)

| Question | Current call | What would settle it |
|---|---|---|
| Is `Ua` an element? | Provisional under an enforceability gate | Audited production systems with multi-domain claim state not reducible to `Xm+Xf+Rl` |
| Is `Sq` an element? | Provisional | Production shared sequencers with durable ordering commitments and non-consensus failure modes |
| Is the informational bond irreducible? | Accepted with a naming clause | A lossless reduction of every observation-only edge to the other three |
| Should `Xm` split by trust domain? | One element, mandatory discriminator | A trust domain that owns a non-substitutable state transition |
| Is constant sum an element? | Isotope of `St` with `drain_regime` | Three unrelated standalone deployments |
| Is `Rs` core? | Core at medium confidence | Three independent lineages with distinct slash-attribution behaviour |
| Is reflexivity predictive? | Hypothesis | Longitudinal dependency coding with matched controls and a false-positive rate |
| Is 53 the right count? | Closed for v0.1 against this corpus | Evidence passing the seven-criterion test |
| How much legal state belongs in the table? | `At` `Aw` `Uc` `Ft` `Tr`, with enforcement as residue | Machine-verifiable legal cash-flow and priority transitions |
