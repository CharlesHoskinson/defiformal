# CAKE and the DeFi Periodic Table: A Reconciled Unification

## Executive verdict

- **Verdict: Table B survives as the base model, but only after seven explicit amendments.** Its minimum-dependency-depth periods, seven-part atomicity test, version-unit corpus, `Xm`/`Xf` split, typed notation, and epistemic restraint are more auditable than Table A’s trust-surface ordering and looser element boundaries. CAKE then contributes **six genuinely new elements**, one new bond type, and an orthogonal request-pipeline annotation—not a replacement periodic table. fileciteturn0file0 fileciteturn0file1
- **The winning topology is a hybrid of H4, H6, and H7.** Most of CAKE is already a region of B: `In`, `Ba`, `Rf`, `Ag`, `Ob`, `Xm`, `Xf`, `Wq`, and `Aw` cover much of the Application–Solver–Settlement path. CAKE’s Permission layer mostly fails element status and should be modeled as an authority instrument joined through trust and informational bonds. The deepest unifier is a generalized conservation rule: a remote value credit must correspond to a verified debit or an explicitly underwritten advance, while authorization and information provenance may be hidden or delayed but may not be silently altered. citeturn9view0
- **The apparent “one-third residue” agreement between A and B is spurious.** A placed Wormhole and Nomad outside the table; B’s `Xm` absorbed them as defective verification instances and filled the similarly sized residual category with operational/control-plane cases such as Ronin, BadgerDAO, and Multichain. Under the unified mechanism-plus-authority model, the conservative residual in B’s 24-incident sample falls from `7/24` to no more than `4/24`, but the exact count and dollar share cannot be audited because B does not disclose all 24 row-level assignments or their contemporaneous loss values. fileciteturn0file0 fileciteturn0file1

The machine-readable release contains **55 elements, 12 bonding rules, 18 molecular decompositions, 29 amendments, the notation map, the atomicity spectrum, the failure overlay, and 14 empty-cell predictions**:

- [Download the unified JSON](sandbox:/mnt/data/cake_defi_unified/cake_defi_unified.json)
- [Download the complete package with JSON and CSV tables](sandbox:/mnt/data/cake_defi_unified_package.zip)

## Reconciliation ledger

Table A proposes approximately 46 elements, ten groups, four periods ordered by trust surface, a five-part atomicity test, and a large operational residue. Table B proposes 48 core elements, twelve groups, five periods ordered by minimum dependency depth, a seven-part test, a 101-version corpus, and first-class cross-domain verification and transfer elements. These are rival derivations, not complementary halves. fileciteturn0file0 fileciteturn0file1

| Disputed row | Classification | Resolution | Reason and amendment |
|---|---|---|---|
| Row axis | Genuine contradiction | **B wins: minimum dependency depth, P0–P4.** Trust becomes a non-ordinal `trust_domain` attribute. | A single “trust surface” number conflates governance, reporter, validator, custodian, legal, and market-depth dependencies. The same mechanism can replace a multisig with a light client without changing its state-transition role or minimum dependencies. |
| Atomicity test | Genuine contradiction | **B’s seven criteria survive verbatim.** | State-transition boundary, execution-model portability, and implementation observability are essential to stop standards, callbacks, UI abstractions, and EVM-specific artifacts from being promoted to elements. |
| Bridging | Genuine contradiction | **B’s `Xm`/`Xf` split survives.** | Message validity and asset movement own different state, impose different conservation requirements, and fail differently. A verifier bug can authorize an invalid message; an asset-transfer bug can violate mint, burn, lock, release, cap, or accounting rules despite valid messaging. |
| Atomic composability | Modeling convention | **`ATOM` is a spectrum-valued reaction condition, not an element or catalyst.** | Atomicity changes with deployment environment and settlement path. `Fl`, atomic flash liquidity, remains an element because its atomic repayment condition is part of its financial state transition. |
| Conservation law | Genuine contradiction | **B wins, then CAKE generalizes it.** | `Xf` must preserve a global claim invariant. Optimistic systems may advance destination value before source finality, but that advance is credit and therefore needs an explicit underwriter and loss allocator. |
| Reflexivity | Genuine epistemic contradiction | **B wins: hypothesis, not theorem.** | Terra and Mango are strong examples, but neither attachment supplies longitudinal exposure coding, matched controls, or a test of false positives. |
| Wormhole and Nomad | Genuine contradiction | **B wins: category (a), defective `Xm` instances.** | Once message verification is first-class, signature-verification and message-root defects are no longer outside-table operational residue. |
| Failure distribution | Empirical corpus mismatch | **Neither aggregate supersedes the other. Membership must be published.** | A’s and B’s category-(d) totals are close, but they describe different incidents. Count and dollars must be separated. |
| Notation | Modeling convention | **B notation survives, with a published A→B map.** | B’s `+`, `||`, `*`, `{}`, `?`, `|`, typed arrows, and `↺` are easier to parse and serialize. The only extension is informational arrow `—n→`; no third formula grammar is invented. |
| Corpus | Modeling convention | **B’s protocol-version-unit method survives.** | Version deltas expose actual element substitution and bond changes; explicit non-EVM units test portability more rigorously than brand counts. |
| Concentrated liquidity | Genuine contradiction | **B wins: `Cl` is an element.** | Range ownership, active-liquidity state, tick transitions, range exhaustion, and position-specific accounting are discontinuous from global constant-product shares. |
| Constant sum | Modeling convention | **B wins: limiting isotope of `St`.** | Pure constant sum has weak safe standalone recurrence and is better represented as the near-parity limit of a stable-hybrid invariant. |
| Weighted pools | Genuine contradiction | **B wins: `Wg` is an element.** | Persistent weights, multi-asset state, and weight-transition arbitrage create a separate failure family. |
| Oracle carve | Modeling convention with substantive consequences | **Hybrid B carve: `Ex` has push/pull/medianizer isotopes; `Tp`, `Oa`, and `At` remain separate.** | Push versus pull primarily changes latency and transport trust. Optimistic dispute games, on-chain time averaging, and reserve/NAV attestations alter the state machine and counterpart requirements. |
| Health factor | Modeling convention | **B wins: derived observation of `Ct`.** | A health factor reports the result of a collateral-threshold computation; it does not independently change a claim, obligation, allocation, valuation, or settlement. |
| Peg-arbitrage mint/burn | Genuine contradiction | **B wins: not an element.** | Arbitrage is a reaction. Terra is represented by `As+Rd` with a reflexive economic cycle and supporting market/liquidity conditions. |
| Restaking | Genuine contradiction by omission | **A is restored as E049 `Rs`, at medium confidence.** | By 2026, security reuse and correlated slashing are no longer just a narrative. Multiple independent systems reuse slashable security, and attribution/correlated-loss failures are not fully captured by ordinary staking or `Bs`. |
| Vote escrow | Modeling convention | **Remain provisional and decomposable.** | Present designs can usually be decomposed into epoch locking, checkpointing, emissions allocation, and governance rights. Evidence has not yet isolated a unique state transition. |
| PSM | Genuine contradiction | **B wins: `Ps` is core.** | A reserve-backed peg swap can recur independently of a CDP and has distinctive reserve concentration, freeze, and mint-authority failures. |
| Hooks | Modeling convention | **B wins: interface grammar, not element.** | A callback socket does not itself change financial state; the mechanism implemented by the hook is the element. |
| Intents and solvers | Genuine contradiction | **B wins: `In` is core, with `Rf`, `Ba`, and `Ob` as execution siblings.** | Outcome-constrained delegation has enforceable authorization and settlement boundaries, independent recurrence, and solver-specific censorship, replay, and concentration risks. |
| Privacy | Genuine contradiction | **B wins: `Sb` and `Sd` remain separate.** | Hidden ownership state requires commitments and nullifiers; selective disclosure requires credential provenance, policy verification, expiry, and revocation. |
| Group count | Modeling convention | **B’s substitutability principle survives; group taxonomy is explicitly refined.** | Group count has no natural periodic-law significance. The machine release uses finer role IDs for stability, privacy, security reuse, and authority, while preserving B’s functional grouping logic. |

Of the **23 ledger rows**, **13 are genuine substantive contradictions, nine are modeling or naming conventions, and one is an empirical corpus-composition mismatch**.

The notation conversion is therefore:

| Table A | Table B | Unified | Meaning |
|---|---|---|---|
| `A·B` | `A+B` | `A+B` | Shared state machine, balance sheet, or settlement invariant |
| `A⊕B` | `A||B` | `A||B` | Mixture, router, or separable component balance sheets |
| `⊗X` | `X*` | `X*` | Catalyst absent from the terminal balance sheet |
| `E[isotope]` | `E{k=v}` | `E{k=v}` | Isotope or parameterization |
| `E(opt)` | `E?` | `E?` | Optional element |
| Not explicit | `A|B` | `A|B` | Alternative at one role boundary |
| Prose only | `A↺` | `A↺` | Reflexive feedback cycle |
| Superscript `ⁱ` | `A —i→ B` | `A —i→ B` | Interface bond |
| Superscript `ᴱ` | `A —e→ B` | `A —e→ B` | Economic bond |
| Superscript `ᵀ` | `A —t→ B` | `A —t→ B` | Trust bond |
| None | None | `A —n→ B` | Informational or observational leakage bond |

## CAKE audit and present-day currency

CAKE is a February 15, 2024 Frontier Research position paper organized around four request-pipeline stages—Application, Permission, Solver, and Settlement—and five decision boundaries: key custody, information sharing, solver access, cross-chain oracle design, and token bridging. It also distinguishes `EV_ordering` from `EV_signal`, treats information as lossless and value transfer as potentially lossy, proposes a cross-chain trilemma, and gives six canonical designs. These are pipeline and market-design concepts, not automatically atomic financial mechanisms. citeturn9view0

**The four layers are admissible as an orthogonal `layer` annotation, not as periods.** B rejected layer-based row ordering because mechanisms span components and deployments. That rejection does not fully dispose of H1: CAKE’s layers are temporal or logical request-pipeline stages rather than software-stack strata. An element may therefore be annotated with the stage where it primarily operates while retaining B’s dependency-depth period. `In` belongs chiefly to Solver; `Au` to Permission; `Xm` and `Xf` to Settlement; `Pl` to Application. A mechanism may span several layers in a molecule, so layer is not a mutually exclusive row axis. fileciteturn0file1 citeturn9view0

| CAKE object | Unified category | Atomicity-test result |
|---|---|---|
| Application layer | Axis annotation / region | Not an element; it contains many state-transition mechanisms |
| Permission layer | Mostly trust bonds; partly `Au`, `Gs`, `Aw`, `Gp`, `Tg`, `Up` | Ordinary key custody fails; enforceable delegation and fee liability can pass |
| Solver layer | Axis annotation / region containing `In`, `Rf`, `Ba`, `Ob`, `Ag`, `Of` | Layer fails; its recurring mechanisms pass individually |
| Settlement layer | Axis annotation / region containing `Xm`, `Xf`, `Rl`, `Of`, `Sq`, `Wq` | Layer fails; its mechanisms pass individually |
| EOA custody | Custody isotope / trust-domain attribute | Fails state-transition boundary |
| Smart-account custody | Account architecture plus possible `Au` policies | Architecture alone fails; enforceable policy state passes |
| Policy-based agent | `Au` if scope is enforceable; otherwise marketing | Conditional pass |
| Public information sharing | Information-disclosure parameter | Fails element status |
| Partial disclosure | Information-disclosure parameter or `Sd` where cryptographically enforced | Usually fails; may invoke existing `Sd` |
| Private disclosure | Information-disclosure parameter and informational bond | Fails element status |
| Open solver list | Access parameter/group option | Not an element |
| Gated solver list | `Aw` plus market parameter | Existing element/bond |
| Exclusive solver | Access parameter plus informational/economic condition | Not an element; creates strong bonding constraints |
| Out-of-protocol cross-chain oracle | `Xm{external-validator/DVN}` isotope | No new element |
| In-protocol oracle | `Xm{native/light-client}` isotope | No new element |
| Shared sequencer | E055 `Sq`, provisionally | Passes where it creates durable ordering commitments |
| Lock-and-mint bridge | `Xf{lock-mint}` isotope | Existing element |
| Burn-and-mint bridge | `Xf{burn-mint}` isotope | Existing element |
| Liquidity bridge | Usually `Of+Xf`, not merely an `Xf` isotope | The advance/reimbursement obligation is distinct |
| Cross-chain trilemma | Reaction-condition tradeoff | Not an element or law as presently stated |
| `EV_ordering` | Ordering-value parameter on `Ob`, `Ba`, `Sq`, and execution environment | Not an element |
| `EV_signal` | Informational bond flow | Establishes the need for a fourth bond type |
| Lossless information / lossy value | Invariant pair / axis | Not an element |
| Six canonical designs | Molecules | Promoting them to elements would repeat the money-legos error |

**The Permission-layer boundary resolves the `Up` objection.** Possession of a key, or use of an MPC or TEE to produce a signature, ordinarily selects who may invoke transitions already defined by another state machine. It therefore fails B’s boundary test. `Up`, by contrast, changes executable implementation and hence the reachable state machine; `Gp` suppresses reachable transitions; `Tg` changes when an authorized transition becomes executable. Those three pass for principled reasons. `Au` also passes when a persistent policy changes the set of calls, assets, destinations, values, chains, or time windows a delegate may reach. The correct line is **authority-as-key possession fails; authority-as-enforceable transition policy passes**. This narrows rather than overturns B’s control group.

Applying the same test yields six CAKE-derived elements:

| ID | Symbol | Element | Why it passes B’s seven criteria | Confidence |
|---|---|---|---|---|
| E050 | `Au` | Delegated execution scope | Persistent policy state bounds reachable calls and introduces scope-escalation, replay, revocation, and cross-domain failures | High |
| E051 | `Gs` | Gas sponsorship obligation | Creates a conditional fee liability, metering state, reimbursement rule, and sponsor-solvency failure family | High |
| E052 | `Ua` | Enforceable unified-balance ledger | Passes only when balances form a non-double-spendable, reconcilable claim; a dashboard total or marketing abstraction fails | Medium |
| E053 | `Rl` | Resource lock or reservation | Creates exclusivity, expiry, fulfillment, and release state; has deadlock, stale-lock, and double-reservation failures | Medium-high |
| E054 | `Of` | Optimistic fill and reimbursement | A filler advances value before finality and receives a distinct contingent reimbursement claim | High |
| E055 | `Sq` | Shared ordering commitment | Constrains reachable cross-domain ordering before settlement and introduces equivocation, availability, and settlement-divergence failures | Medium |

Key custody itself, session keys, MPC, and TEE signing do **not** become separate elements. Session keys are common `Au` parameterizations; MPC and TEE are custody or trust-domain implementations. Solver bonding and slashing are parameterizations of `Bs`. Solver access uses `Aw` and auction parameters. Order-flow disclosure is an axis and informational edge. Cross-domain oracle designs are `Xm` trust-domain isotopes.

**The 2024 CAKE axes remain useful but are no longer current enough to stand alone.** EIP-7702 makes an EOA able to set executable delegation code and supports batching and sponsorship-like flows, but it does not erase the EOA/smart-account distinction: the root authentication and recovery model can remain ECDSA-based even while account behavior becomes programmable. EIP-5792 standardizes wallet call batches and lets callers request atomic execution capabilities; ERC-6900 and ERC-7579 develop modular smart-account architectures; ERC-7710 develops scoped delegations. Together they compress CAKE’s EOA/AA axis into a more continuous account-authority spectrum rather than collapsing it completely. citeturn9view2turn10search0turn10search1turn10search2turn10search8

ERC-7683 did arrive, but its evolving draft is better understood as a solver-facing cross-chain order and settlement interface than a canonical intent market. Its current design supports escrow-first and fill-first patterns, resource locking, dependency declaration, and multiple auction arrangements, while leaving solver concentration, economic security, and finality assumptions to implementations. CAIP-2 and CAIP-10 supply chain and account identifiers; ERC-3770 addresses chain-qualified address display; ERC-7802 standardizes cross-chain mint/burn interfaces and explicitly expects aggregate circulating supply to remain conserved subject to authorized mint/burn control. citeturn12view2turn12view3turn12view0turn12view1turn11search1turn11search0

Settlement has also moved materially beyond CAKE’s early-2024 snapshot. CCTP v2 introduced standard and fast transfer paths, with Fast Transfer explicitly advancing destination usability through an allowance before ordinary finality; IBC Eureka applies light-client semantics and ZK proof generation to Ethereum interoperability, albeit with launch-stage relayer and governance controls; AggLayer documentation distinguishes unified-bridge operation, pessimistic proofs, and state-transition proofs. These systems confirm that verification, value transfer, optimistic credit, and ordering must remain separate elements. citeturn13search0turn13search1turn13search2turn13search3turn13search4turn13search8

CAKE also requires a neutrality discount. Its authors subsequently founded or spun out OneBalance, whose public material advances credible accounts, resource locks, and unified-balance settlement. Those mechanisms deserve evaluation, but the framework’s preferred design region overlaps the founders’ product thesis. Documentation-versus-implementation divergence is material: OneBalance’s public design material is useful evidence for `Rl` and `Ua`, while the consumer-facing OneApp announced a shutdown and withdrawal deadline of June 30, 2026. The classification therefore treats OneBalance as strong design evidence but not proof that every documented behavior is broadly deployed. citeturn17search0turn17search2turn17search3turn17search4turn18search0turn18search4

Solver markets also make CAKE’s “open/gated/exclusive” choice more than a cosmetic parameter. Formal intent-market work finds that entry restrictions, inventory, latency, and fixed costs can sustain concentrated or oligopolistic resolver markets; more recent empirical work likewise reports concentration and delayed-settlement exposure in large intent datasets. This does not create a new “solver concentration element,” but it grounds economic and informational bonding rules around exclusivity and claimed price improvement. citeturn19search16turn21search1

## Unified object and element table

The survivor contains **55 elements**:

\[
48\text{ from B}
+1\text{ restored from A}
+6\text{ extracted from CAKE/current systems}
=55
\]

The complete object preserves B’s IDs `E001–E048`, adds `E049 Rs`, and continues with `E050–E055`. Every machine-readable element includes the requested fields:

```json
{
  "id": "E053",
  "symbol": "Rl",
  "name": "Resource lock or reservation",
  "group_id": "G12 Cross-domain",
  "period_id": "P4",
  "layer": "Settlement",
  "trust_domain": "remote solver/settlement trust",
  "atom_dependency": "async-native",
  "repair_bonds": ["explicit finality/timeout assumptions where cross-domain"],
  "definition": "...",
  "trust_assumptions": "...",
  "required_counterparts": ["Au", "settlement verifier"],
  "incompatible_or_unstable_with": ["locks without expiry/recovery", "cross-domain double-spend"],
  "common_parameterization": "...",
  "canonical_implementations": ["OneBalance resource locks", "ERC-7683 escrow-first orders"],
  "known_failure_modes": ["deadlock", "lock theft", "stale reservation"],
  "maturity_decay_status": "emerging",
  "source_table": "CAKE",
  "confidence": "medium-high"
}
```

The human-readable index is:

| Period | Elements |
|---|---|
| **P0 — ledger-local claims** | `E001 Sh` pro-rata shares; `E002 Ix` index accrual; `E003 Rb` rebasing |
| **P1 — deterministic same-domain transformation** | `E004 Cp`, `E005 Wg`, `E006 St`, `E007 Cl`, `E008 Pm`, `E009 Ob`, `E010 Rf`, `E039 Ag`, `E040 Fl` |
| **P2 — measured or time-conditioned state** | `E011 Ba`, `E028 Ex`, `E029 Tp`, `E030 Oa`, `E031 At`, `E032 Sr`, `E033 Ep`, `E034 Wq`, `E035 Em`, `E046 Aw`, `E047 Sb`, `E048 Sd` |
| **P3 — obligations, solvency, risk transfer, and stability** | `E013 Pl`, `E014 Im`, `E015 Cd`, `E016 Uc`, `E017 Ft`, `E018 Ct`, `E019 Li`, `E020 Ad`, `E021 Sl`, `E022 Bs`, `E023 Pf`, `E024 Op`, `E025 Tr`, `E026 Cv`, `E027 Py`, `E043 Rd`, `E044 Ps`, `E045 As`, `E051 Gs` |
| **P4 — multi-agent, mutable-control, and cross-domain coordination** | `E012 In`, `E036 Tg`, `E037 Up`, `E038 Gp`, `E041 Xm`, `E042 Xf`, `E049 Rs`, `E050 Au`, `E052 Ua`, `E053 Rl`, `E054 Of`, `E055 Sq` |

The seven changed or added rows are:

| ID | Symbol | Group | Period | CAKE layer | Trust domain | Async classification | Source |
|---|---|---|---|---|---|---|---|
| E049 | `Rs` | Security reuse | P4 | Settlement | Operator, validator, and slashing governance | Async-native | A |
| E050 | `Au` | Authority | P4 | Permission | Root signer, account policy, or governance | Async-native | CAKE |
| E051 | `Gs` | Authority/obligation | P3 | Permission | Sponsor or paymaster solvency | Async-native | CAKE |
| E052 | `Ua` | Claims | P4 | Application | Multi-domain accounting and canonicality | Repairable | CAKE |
| E053 | `Rl` | Cross-domain | P4 | Settlement | Remote reservation and fulfillment | Async-native | CAKE |
| E054 | `Of` | Cross-domain | P4 | Settlement | Filler, reimbursement verifier, and loss allocator | Async-native | CAKE |
| E055 | `Sq` | Execution | P4 | Solver | Shared sequencer or preconfirmation provider | Async-native | New, prompted by CAKE |

**Why six rather than eleven or twelve new CAKE elements:**

- `Au` absorbs delegated scope and session-policy state.
- `Gs` captures gas sponsorship as a real obligation rather than a wallet feature.
- `Ua` is admitted only when enforceable; “unified balance” as a user experience is rejected.
- `Rl` captures reservations.
- `Of` captures optimistic fill and reimbursement.
- `Sq` captures shared ordering commitments.
- Key custody, MPC, and TEE remain trust or implementation attributes.
- Order-flow disclosure becomes an axis and informational bond.
- Solver access policy reuses `Aw` and market parameters.
- Solver bonding reuses `Bs`.
- Cross-domain oracle types remain `Xm` isotopes.

**`Xm` should not split into separate element IDs by trust domain yet.** Light-client, native-consensus, external-validator/DVN, optimistic, ZK-assisted, and shared-sequencer verification all implement the same role boundary: determine whether a source-domain assertion is acceptable on the destination. Their security and finality differ radically, but those differences currently fit `trust_domain`, parameterization, and required-bond fields. A future split would require evidence that one variant owns a non-substitutable state transition rather than merely a different verifier and failure probability.

**`Xf` lock-mint, burn-mint, and custodial-release forms are isotopes.** They all create a destination claim against an explicit source debit, burn, lock, or custodian obligation. A liquidity transfer is different: when a filler advances destination funds before canonical settlement, the correct formula is `Of+Xf`, because an interim credit and reimbursement obligation exists. CCTP v2’s distinction between standard and fast transfer provides a clear real-world example. citeturn13search1turn13search2turn13search3

**The information-disclosure axis is orthogonal rather than collinear with periods or layers.** Public, partial, and private information can appear at every dependency depth: an AMM trade can be public or private; a lending liquidation can be privately routed; a cross-chain intent can reveal its full route or only settlement constraints. It therefore cannot replace the period axis and should be recorded per molecule or per bond.

## Asynchrony, bonding rules, and molecules

Atomicity is not binary. The unified object uses the following spectrum:

| Atomicity level | Meaning | Typical repair |
|---|---|---|
| Same transaction | All state changes commit or roll back together | None |
| Same block | Separate transactions share a block but may be adversarially ordered | Batch clearing, commit-reveal, or preconfirmation |
| Shared sequencer | Several domains accept a common ordering commitment | `Sq`, accountability/slashing, and later settlement verification |
| Same-ecosystem finality | Domains share or closely coordinate security/finality | Ecosystem-aligned `Xm` and explicit timeout |
| Cross-ecosystem | Independent consensus and finality domains | `Xm+Xf+Rl|Of`, reservations, haircuts, and loss allocation |
| Optimistic | Destination value is advanced before canonical finality | `Of+Bs|Sl`, challenge/finality proof, and reimbursement timeout |

This resolves the A/B `ATOM` conflict. Atomicity is a **spectrum-valued reaction condition**. `Fl` remains a financial element because “borrow and repay before transaction completion or revert” is its defining obligation. It is the only element classified **async-impossible**. A cross-chain system may imitate the user experience of flash liquidity by using a prefunded solver, credit line, resource lock, or optimistic fill, but its molecule is then `Of+Rl+Bs|Sl`, not `Fl`.

The element-level overlay is:

- **Async-impossible:** `Fl`.
- **Async-repairable:** `Sh`, `Ix`, `Rb`, `Cp`, `Wg`, `St`, `Cl`, `Pm`, `Ob`, `Pl`, `Im`, `Cd`, `Ct`, `Li`, `Ad`, `Bs`, `Pf`, `Tp`, `Sb`, and `Ua`.
- **Async-native:** the remaining 34 elements, including quotes, auctions, intents, maturity claims, external attestations, epochs, queues, governance delays, message verification, asset transfer, restaking, delegation, locks, optimistic fills, and shared ordering.

The sanity check follows immediately:

\[
\boxed{\text{No cross-chain flash liquidity exists without an intermediary,
precommitted credit, or shared rollback domain.}}
\]

Calling prefunded or underwritten cross-chain liquidity “flash” hides its lender, reservation, loss allocator, or finality assumption.

The required-bond rules become:

| Rule | Async-safe | Grounding | Confidence |
|---|---:|---|---|
| `(Pl|Im|Cd|Pf|Op) → truth + Ct + (Li|Ad|Sl|Bs)` | **No**, unless price and collateral share a finality snapshot or are locked/haircut through the delay | Mango; Maker Black Thursday; B’s leveraged-obligation rule | High |
| `Xf → Xm|named custodian + global claim ledger` | Yes, conditionally | Wormhole; Nomad; CCTP; ERC-7802 | High |
| `Au → bounded scope + revocation + nonce/domain separation` | Yes | Ronin, BadgerDAO, Safe modules, EIP-7702/7710 | High |
| `Xm → explicit finality + chain/domain binding + replay protection` | Yes | Nomad and Wormhole verification failures | High |
| Wrapped cross-domain collateral → bridge-specific haircut + cap + independent exit | Yes | Wormhole-wrapped assets, Harmony, Multichain | Medium |
| `In+Ba{exclusive}` cannot imply competitive price improvement without a benchmark | Yes | CAKE solver-list tradeoff and solver-market literature | Medium-high |
| `Of → Xm+Xf+(Bs|Sl)+timeout` | Yes | Across and CCTP Fast Transfer | High |
| `Rl → Au + single-spend + expiry + fulfillment proof + release` | Yes | OneBalance resource-lock design; ERC-7683 escrow-first flows | Medium-high |
| `In|Rf|Ba → explicit order-flow disclosure edge` | Yes | CAKE’s `EV_signal` distinction | High |
| `Sq → Xm + independent settlement finality` | Yes | Shared-sequencer design boundary | Medium |
| `Rs → attributed slash condition + non-reflexive capital + loss waterfall` | Yes | Restaking security-reuse designs | Medium |
| `Gs → Au + metering + fee settlement` | Yes | Paymaster and sponsored-batch designs | High |

Wormhole’s approximately $320 million 2022 loss is best coded as a defective `Xm` verification instance; Nomad’s approximately $190 million loss likewise followed a message-verification initialization condition that made invalid messages acceptable. Ronin’s roughly $625 million loss is different: the bridge’s financial and messaging roles existed, but validator-key control defeated the trust bond. These incidents ground the split between element defects and authority failures rather than a generic “bridge” category. citeturn20search4turn20search6turn20search8turn20search17

**Informational is a fourth bond type.** An interface bond requires a call, token, message, or proof. An economic bond allocates payment, incentive, inventory, or loss. A trust bond grants authority or relies on an attestor. `EV_signal` can leak merely because an actor observes amount, urgency, route, constraints, or wallet state. No call, transfer, incentive, or attestation need pass between the observed order and the observer. Economic harm may be the consequence, but observation is the causal relationship. Folding it into “economic” would make private-order-flow and solver-information analyses unauditable.

The strong H4 test succeeds: all six CAKE designs decompose as molecules.

| CAKE design | Unified formula | Implementation or near-fit | Residue |
|---|---|---|---|
| Token-anointed bridge | `Au{issuer-mint}+Xm{issuer attestation}+Xf{burn-mint}` | CCTP v2 Standard | Issuer governance, attestation operations, per-chain finality |
| Token-anointed bridge | `Au+Xm+Xf{ERC-7802 burn-mint}` | Superchain-style ERC-7802 transfers | Deployment-specific bridge authority and rollout status |
| Ecosystem-aligned bridge | `Xm{ZK/light-client}+Xf?+Ag` | IBC Eureka | Launch relayer permissioning and security-council controls |
| Ecosystem-aligned bridge | `Xm{proof-based}+Xf{unified bridge}+Sq?` | AggLayer | Deployed proof path, upgrade controls, and exit semantics |
| Solver price competition | `In+Rf|Ba+Ag+Of+Xf` | Across | Optimistic verifier/governance and relayer concentration |
| Solver price competition | `In+Ag+Rf|Ba+Xm+Xf+Of?` | LI.FI/OIF and ERC-7683 fillers | Heterogeneous adapters and route-specific finality |
| Wallet-coordinated messages | `Ua+Au+Gs+In+Ag+Xm+Xf` | Particle Universal Accounts | Canonical asset mapping and solver dependency |
| Wallet-coordinated messages | `Au{MPC chain signatures}+In+Rf|Ba+Ag+Xm+Xf` | NEAR Intents with Chain Signatures | MPC operator/governance and adapter trust |
| Solver speed competition | `In+Rf+Of+Gs+Xf` | Relay | Filler inventory and settlement-backend heterogeneity |
| Solver speed competition | `In+Rf+Of+Xm+Xf` | deBridge DLN | Maker access and messaging-validator assumptions |
| Exclusive batch auction | `In+Ba{restricted resolvers}+Aw+Ag` | 1inch Fusion as a near-fit | Resolver admission and absence of a clean competitive counterfactual |
| Exclusive batch auction | `Ua+Au+Rl+In+Ba{exclusive}+Xm+Xf` | OneBalance design as a near-fit | Independently verified production behavior remains thinner than design documentation |

Additional live or current-product decompositions include:

| Product | Formula | Principal residue |
|---|---|---|
| Everclear | `In+Ba{netting}+Xm+Xf+Wq?` | Clearing-cycle liveness and solver inventory |
| Bungee | `Ag+In?+Xm+Xf+Gs?` | Underlying bridge risk remains route-specific |
| Safe with modules and guards | `Au+Gp+Tg?+Gs?+In?` | Module code, signer setup, and social recovery |
| CCTP v2 Fast | `Au+Xm+Xf+Of` | Fast-transfer allowance pricing and issuer balance sheet |
| ERC-7683 filler market | `In+Rl{escrow-first|fill-first}+Rf|Ba+Xm+Xf+Of?` | Standard defines an interface, not market security |
| Wormhole bridge | `Xm{external validator set}+Xf{lock-mint}` | Guardian operations and verification implementation |

Across uses intent-like orders, destination fillers, and optimistic reimbursement; Relay emphasizes fast filling and gas abstraction; deBridge DLN uses makers to fulfill cross-chain orders; Everclear adds netting before settlement; LI.FI combines routing with an intent/filler marketplace; NEAR Chain Signatures use MPC to authorize transactions on external chains; Particle’s Universal Accounts add unified-balance and gas abstractions; Safe exposes modular account authority through modules and guards. citeturn14search1turn14search4turn14search7turn14search12turn14search16turn14search17turn15search0turn15search1turn15search3turn15search7turn15search13turn16search1turn16search2turn16search4turn16search9turn16search18turn16search20

The most useful near-isomer contrasts are:

| Near-isomers | Same core role | Discriminating elements or isotopes |
|---|---|---|
| CCTP Standard vs CCTP Fast | Issuer-authorized burn/mint transfer | Fast adds `Of`, an underwritten advance before ordinary finality |
| IBC Eureka vs Wormhole | `Xm+Xf` | ZK/light-client trust domain versus external guardian/validator trust domain |
| Across vs Relay | Solver-filled cross-chain execution | Optimistic pooled reimbursement and dispute path versus route-specific fast filler/gas abstraction |
| Particle vs NEAR Chain Signatures | Wallet-coordinated multi-chain execution | `Ua+Gs` smart-account abstraction versus MPC cross-chain signature authority |
| Safe modules vs EIP-7702 delegation | Programmable account authority | Persistent smart-account module registry versus EOA code delegation rooted in EOA authentication |
| Everclear vs Across | Intent settlement | Netting/clearing cycle versus direct optimistic fill and reimbursement |

## Failure overlay, empty cells, and invariants

The three-stage failure comparison is:

| Stage | Count result | Category-(d) composition | Dollar interpretation |
|---|---|---|---|
| A, published | `(a) 25–30%`, `(b) 30–35%`, `(c) ~10%`, `(d) 30–35%` | Wormhole, Nomad, Ronin, BadgerDAO and other bridge/control-plane events were treated broadly as outside the table | A reports category (d) as the dollar plurality, substantially because large bridge losses remain in residue |
| B, published | `a=9/24`, `b=7/24`, `c=1/24`, `d=7/24` | Wormhole and Nomad move to defective `Xm`; named residue includes Ronin, BadgerDAO, and Multichain | No complete row-level dollar table is supplied; B warns that operational compromise can dominate loss-weighted data even when not dominant by count |
| Unified, conservative | **Residual `d=0–4/24`; conservative observable value `4/24=16.7%`** | Ronin becomes an `Xm/Xf —t→ Au` failure; BadgerDAO becomes an informational plus delegated-approval failure; Multichain becomes an operator/authority trust-bond failure | Exact percentage is not auditable. In a 2022 bridge-heavy subset, much of A’s residue moves into `Xm` defects or authority bonds; in a 2025-inclusive sample, very large custody/control-plane events can still dominate dollars |

The unified range is not presented as a false point estimate. B supplies seven category-(d) incidents but names only three in the attachment. Moving those three leaves a conservative four; any of the four undisclosed cases may also be representable through `Au`, informational bonds, or explicit institutional trust. Therefore the post-unification residual is **between zero and four incidents, or zero to 16.7% of the 24-case corpus**, unless the full incident ledger reveals otherwise. fileciteturn0file1

The dollar result is even less identifiable. Wormhole and Nomad alone move roughly half a billion dollars from A’s residue into defective `Xm`. Ronin moves another roughly $600–625 million from generic residue into a validator-authority trust-bond failure under the unified model. Conversely, loss reporting for 2025 was heavily dominated by operational compromise and the approximately $1.5 billion Bybit event. A mechanism table can model the authority and informational paths through which such a loss propagates, but it does not thereby predict phishing, compromised developer infrastructure, coerced signers, or malicious frontends. citeturn20search4turn20search6turn20search8turn21search0turn21search5

The appropriate scope statement is thus:

\[
\text{Unified coverage}
=
\text{financial state transitions}
+
\text{typed bonds}
+
\text{authority policy}
+
\text{information exposure}
+
\text{reaction conditions}
\]

It still excludes the initiating causes of many compromises: malware, personnel coercion, fraudulent legal documents, physical key theft, compromised build systems, and unauditable off-chain collusion.

The newly opened region produces the following empty cells:

| Candidate cell | Verdict | Blocking reason |
|---|---|---|
| `Fl+Xm+Xf` across independent chains with no intermediary | Reaction-condition-blocked | Independent finality domains cannot share rollback; prefunded credit changes the formula to `Of` |
| Open solvers + zero pre-fill disclosure + best-price guarantee | Bonding-blocked | Solvers cannot price fully hidden constraints without secure computation or a commitment design |
| Exclusive solver + verifiable competitive price improvement | Bonding-blocked | Exclusivity removes the live counterfactual unless an external benchmark or auditable commitment is added |
| Light-client `Xm` + instant finality for a probabilistic source | Infrastructure-blocked | Verification cannot erase the source chain’s own finality horizon |
| Permissionless `Sq` + rollback-free execution across heterogeneous L1s | Infrastructure-blocked | Shared ordering does not control independent settlement reorgs |
| Burn-mint `Xf` with no issuer, bridge authority, or verifier root | Bonding-blocked | Mint authorization and global supply accounting still require an accountable root |
| `Ua` without canonical asset mapping or reservations | Bonding-blocked | An aggregate view is not a spendable claim and permits double counting |
| `Rl` on a plain EOA with no delegated code | Infrastructure-blocked | The account cannot enforce reservation, expiry, or release |
| Private order flow with full user capture of `EV_signal` and no trusted proof system | Bonding-blocked | The intermediary necessarily observes or infers part of the signal |
| Async lending with stale cross-chain truth and immediate liquidation | Reaction-condition-blocked | Price and collateral refer to different finality snapshots |
| `Rs` securing a bridge mostly with assets issued by that bridge | Economically unattractive/toxic | Verifier security and asset backing fail together |
| Universal low-cost, low-latency ZK light clients for every chain | Infrastructure-blocked | Proof cost, data availability, and consensus semantics remain heterogeneous |
| Uniform session-key policy across EVM, Solana, Move, Cosmos, and Bitcoin | Viable but standards-blocked | Account and authorization models remain materially different |
| Optimistic-oracle high-frequency perp liquidation | Reaction-condition-blocked | Dispute latency is incompatible with rapid margin closeout absent another truth source |

**The cross-domain reflexivity analogue is a trust-domain cycle.** It occurs when chain or protocol X relies on bridge B for critical state or asset value, while B’s verifier capital, governance power, fee revenue, or operational security depends materially on claims issued through B or on assets whose value depends on X. One especially dangerous form is:

\[
Xf\text{-issued asset}
\rightarrow
Rs/Bs\text{ verifier capital}
\rightarrow
Xm\text{ security}
\rightarrow
Xf\text{ backing}
\]

A shock to the wrapped asset then weakens the verifier or backstop that protects the wrapped asset. This is a useful ex-ante graph warning, but it is not a theorem and does not predict pure implementation defects such as Nomad’s invalid-root acceptance. It should be tested with longitudinal dependency graphs and matched non-failing bridges, at B’s evidentiary standard.

**The CAKE trilemma is a soft tradeoff, not a law.** Zamyatin and co-authors formalize strong limitations on cross-chain communication without a trusted third party under specified models; Herlihy’s atomic-swap work shows that atomic exchange is possible under particular asset, graph, timelock, and participant conditions. These results do not directly prove that fast execution, low fees, and guaranteed execution form a universal three-way impossibility. Resource locks, prefunded solver inventory, fast-finality domains, ZK light clients, shared sequencing, and optimistic advances can improve one corner, but they pay in capital, waiting time, proof cost, trust, liquidity, censorship risk, or loss allocation. citeturn19search0turn19academia51

H7 is the better invariant:

\[
\boxed{
\text{destination credit}
=
\text{verified source debit}
+
\text{explicitly underwritten advance}
-
\text{fees}
-
\text{realized allocated loss}
}
\]

For authorization:

\[
\boxed{
\text{executed authority}
\subseteq
\text{valid, domain-bound, unexpired delegated scope}
}
\]

For information:

\[
\boxed{
\text{a claim may be withheld or delayed, but its provenance and meaning
must not be silently mutated across a trust boundary}
}
\]

B’s `Xf` supply-conservation rule and CAKE’s lossless-information/lossy-value distinction are therefore **related but not identical**. B states a value-claim invariant. CAKE identifies an integrity asymmetry: information must preserve meaning, while value delivery may sacrifice amount, timing, or certainty. The generalization is not “value may disappear”; it is “any loss, fee, slippage, delay, or advance must be assigned to an explicit claim class or underwriter.”

## Amendment register, open questions, and explicit answers

The principal amendments, all present in the machine-readable register, are:

| Target | Change | Source and rationale |
|---|---|---|
| Periods | Adopt B’s P0–P4 dependency depth | Trust is retained as `trust_domain`, not ordinal |
| Atomicity | Adopt B’s seven tests | Prevents interface, UI, and execution-model artifacts from becoming elements |
| Bridging | Adopt `Xm`/`Xf` | Separates verification from asset claims |
| `ATOM` | Demote to spectrum-valued reaction condition | Atomicity is deployment-dependent |
| Conservation | Retain B’s debit/credit law and extend for optimistic credit | CAKE’s lossy-value insight requires explicit underwriter/loss allocation |
| Reflexivity | Downgrade to hypothesis | Longitudinal validation is missing |
| Failure coding | Move Wormhole/Nomad to defective `Xm`; add authority and informational bonds | Membership, not aggregate percentage, is decisive |
| Notation | Adopt B notation plus `—n→` | No third formula grammar |
| Corpus | Adopt version units and non-EVM portability test | Version deltas are stronger evidence than brand counts |
| `Cl`, `Wg`, `Ps` | Retain as core | Distinct state and failure families |
| Constant sum, health factor, PAB, hooks | Demote to isotope, observation, reaction, and interface grammar | Fail one or more atomicity criteria |
| Restaking | Add E049 `Rs` at medium confidence | Security reuse and correlated slashing now recur independently |
| Permission | Add only enforceable `Au` and `Gs` | Key custody and signing technology alone fail the boundary |
| Unified balances | Add E052 only when enforceable | UI-level abstraction is rejected |
| Resource locks | Add E053 | Persistent reservation and release state |
| Optimistic fills | Add E054 | Distinct advance/reimbursement obligation |
| Shared sequencing | Add E055 provisionally | Ordering commitment is distinct from settlement verification |
| Bond ontology | Add informational bond | `EV_signal` can leak through observation alone |

The instability register remains:

| Arbitrary call | Evidence that would settle it |
|---|---|
| `Ua` is an element only when the aggregate balance is enforceable | Audited production systems showing independent multi-domain claim state and failures not reducible to `Xm+Xf+Rl` |
| `Rs` is admitted at medium confidence | Three or more independent production lineages plus evidence of distinct slash-attribution and correlated-loss behavior |
| `Au` is an element; MPC and TEE are implementations | Evidence that custody technology alone changes financial or reachable execution state without an enforceable scope policy |
| `Xm` trust models are isotopes | Evidence that light-client, validator-set, and shared-sequencer forms create non-substitutable state transitions |
| Informational is a fourth bond | A lossless reduction of every observation-only edge to interface, economic, or trust bonds |
| `Sq` is provisionally an element | Multiple production systems with durable ordering commitments and failures not reducible to generic consensus plus `Xm` |
| Unified residual is at most `4/24` | Publication of B’s complete 24-row incident membership and contemporaneous dollar values |
| CAKE’s trilemma is a soft tradeoff | A formal impossibility theorem under explicit trust, synchrony, liquidity, and finality assumptions—or a counterexample satisfying all three without hidden cost |
| Cross-domain reflexivity is predictive | Pre-failure dependency coding, matched controls, and severity testing |
| OneBalance is design evidence rather than full deployment evidence | Audited contracts, route telemetry, and independently verifiable active usage after the OneApp shutdown notice |

**Explicit answers**

1. **Which row axis survives, and the strongest argument against it?**  
   Minimum dependency depth survives: P0 ledger-local claims, P1 deterministic transformation, P2 measured/time-conditioned state, P3 obligations and solvency, and P4 multi-agent/cross-domain coordination. The strongest objection is that “minimum dependency” can still be context-sensitive: an oracle-priced AMM or isolated lender may move conceptually depending on which counterpart requirements are regarded as constitutive. Stable IDs and explicit required-counterpart fields limit, but do not eliminate, that arbitrariness.

2. **How many ledger rows were genuine contradictions versus naming conventions?**  
   Of 23 logged rows, **13 are genuine substantive contradictions, nine are modeling or naming conventions, and one is an empirical corpus-composition mismatch**.

3. **Does CAKE’s Permission layer pass B’s state-transition-boundary criterion? If not—H6, or is `Up` inconsistently admitted?**  
   The Permission layer as a whole does not pass. Ordinary custody, MPC, TEE signing, and key possession are trust-domain properties. Enforceable delegated execution scope and gas sponsorship do pass as `Au` and `Gs`. `Up` is not inconsistently admitted: it changes executable code and the reachable state machine; `Gp` suppresses transitions; `Tg` delays executability. The result is **H6 for ordinary custody, with narrowly admitted authority elements where persistent policy or obligation state exists**.

4. **Which topology won, and what is the strongest case against it?**  
   **H4 wins structurally, joined to H6 at the Permission interface and governed by H7’s invariant.** CAKE is mostly a region of the reconciled table, not a second table. The strongest objection is that adding authority and informational bonds can make the system an all-purpose sociotechnical ontology rather than a periodic table of financial mechanisms. The defense is to keep custody operations, organizations, malware, and legal institutions outside the element set unless they pass the seven-part atomicity test.

5. **How many genuinely new elements did CAKE contribute beyond what B already had?**  
   **Six:** `Au`, `Gs`, `Ua`, `Rl`, `Of`, and `Sq`. `Rs` is a seventh addition beyond B, but it is restored from A rather than contributed by CAKE.

6. **Should `Xm` split by trust domain? Are `Xf` forms elements or isotopes?**  
   `Xm` should carry trust-domain isotopes—native/light-client, external validator or DVN, optimistic, ZK-assisted, and shared-sequencer-assisted—but should not split into new IDs yet. `Xf` lock-mint, burn-mint, and custodial-release are isotopes. Liquidity advance is a molecule `Of+Xf`, because it creates an interim credit and reimbursement obligation.

7. **Is `ATOM` an element, catalyst, reaction condition, or spectrum-valued attribute?**  
   **A spectrum-valued reaction condition.** Same-transaction, same-block, shared-sequencer, ecosystem-final, cross-ecosystem, and optimistic execution are distinct operating regimes. `Fl` is the financial element whose semantics require same-transaction atomicity.

8. **Is informational a fourth bond type?**  
   **Yes.** Observation can leak `EV_signal` without a call, payment, incentive, attestation, or authority relation. Economic loss is a possible effect, not the definition of the edge.

9. **What is the residue after unification, by count and dollar, versus A’s approximately one-third and B’s 29.2%?**  
   By count, the defensible result is **zero to four of B’s 24 incidents, or zero to 16.7%**, with `4/24` the conservative value obtained by moving only the three named operational cases. An exact point estimate is impossible without B’s four undisclosed category-(d) members. By dollars, no auditable percentage can be computed from the attachments. The composition changes decisively: Wormhole and Nomad move into defective `Xm`; Ronin, BadgerDAO, and Multichain move into authority, trust, and informational-bond failures. What remains is primarily malware, compromised development or user interfaces, coercion, insider fraud, false legal/off-chain representations, and other initiating causes not represented by financial state transitions.

10. **Is there a cross-domain reflexivity analogue, and does it predict bridge failures ex ante?**  
    **Yes, as a trust-domain-cycle hypothesis.** It warns when a bridge’s security, backstop, or governance depends on assets or revenues whose validity depends on that same bridge. It can flag structurally circular bridge designs ex ante, but it does not predict implementation defects such as invalid signature checks or zero-root initialization by itself.

11. **Is the trilemma a law, a soft tradeoff, or a 2024 engineering artifact—and is H7 better?**  
    **A soft tradeoff framed by real impossibility results, not itself a proven law.** Locks, proofs, shared sequencing, fast finality, and prefunded solvers relax the visible tradeoff by paying elsewhere in capital, delay, proof cost, trust, censorship exposure, or loss allocation. H7’s generalized conservation and provenance invariant is the stronger and more durable structural rule.

12. **Does the unified object still deserve the name “periodic table”?**  
    **Only in the qualified sense of a versioned table of recurring state-transition elements, substitutability groups, typed bonds, and reaction conditions.** It has no Mendeleev-style periodic law, natural atomic number, or immutable closure. “Periodic table” remains useful shorthand for the indexed element vocabulary; “mechanism grammar” or “typed state-transition atlas” is scientifically more precise.