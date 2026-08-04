# The DeFi State-Transition Atlas — v1.0

*Informally, and by provenance, "the periodic table of DeFi". The nickname is
kept because it is the term readers arrive with. The formal name is used
everywhere the difference matters, because there is no periodic law here — see
§19.*

**What it is:** a typed vocabulary for describing what a DeFi protocol
*mechanically does*, plus composition rules that say which combinations are
required, which are hazardous, and which have never been built.

**Contents:** 48 core elements · 10 candidates · 10 provisional · 16 groups ·
5 dependency strata · 4 typed bond classes · 29 required-bond laws · 19 hazard
rules · an atomicity phase diagram · four overlays.

**Status:** v1.0, revised after a blinded council review across eight lanes and
three provider families, in which every lane returned `changes_requested`
(84 findings). What changed and why is in Appendix C.
Unresolved dissent is preserved in §20.4, not averaged away.

---

## 1. Quickstart

If you read nothing else, read this page.

**The object.** A protocol is a *molecule*. It decomposes into *elements* —
recurring financial state transitions — joined by *bonds* of four types, valid
only inside stated *reaction conditions*, and leaving *residue* that the
vocabulary cannot express. Residue is reported, never hidden.

**One formula, read aloud:**

```
Across@2026
  elements:   In + Rf + Of + Xm{trust_domain=optimistic} + Xf{burn-mint}
  bonds:      In —n→ filler [enables: adverse_selection]
              Of —e→ Bs{trigger=non-fill}
              Xm —t→ external-validator-set
  conditions: cross-ecosystem atomicity; filler inventory depth; dispute window
  residue:    filler inventory economics; relayer concentration
```

Read: *users sign intents; fillers quote and advance destination value before
finality; an optimistic verifier settles the reimbursement; value moves
burn-and-mint. The filler sees the order before it settles, which is worth
money to them. The advance is underwritten by bonded capital.*

**What the table then tells you, mechanically:** `Of` requires a timeout and a
loss allocator (law L19). `Xm` cannot be written bare — a verifier's trust
domain changes which hazard rules apply (§8.2). `In` obliges you to declare who
observes the order (law L24). Miss any of these and the formula is ill-formed,
which is the point: ill-formedness is where the risk was hiding.

**Where to go next.** To describe a protocol → §18.1. To screen a design →
§18.2. To diagnose an incident → §18.3. To find gaps → §18.4. To learn the
notation → §12. A complete worked example, start to finish, is Appendix A.

**Three things this table will not do for you.** It will not catch an
implementation bug (§17.3). It will not predict a key compromise, and by 2025
dollars that is where the losses are (§17.4). It will not describe a legal
instrument to a regulator (§19).

---

## 2. The object model

Eight constructs, plus laws, conditions and overlays defined in §13–§17. (v0.1
claimed "nine constructs and everything else is one of these"; that was false,
and Catalyst has since been removed from the list — see §11.)

| Construct | Definition | Test |
|---|---|---|
| **Element** | An independently recurring, role-substitutable financial state-transition mechanism with a distinct failure signature | The admission test, §3 |
| **Group** | A family of elements that can occupy the same role boundary and leave the protocol recognizably the same kind of system | Substitution, §5 |
| **Stratum (period)** | The category of prerequisite an element minimally needs to exist | §6 |
| **Isotope** | A variant, continuous or discrete, that preserves the state-transition semantics **and the failure family** | §7 |
| **Discriminator** | A mandatory annotation whose values select different hazard rules | §8.2 |
| **Bond** | A typed required relationship: interface, economic, trust, informational | §9 |
| **Valence** | The typed vector of bonds an element requires | §10 |
| **Molecule** | A deployed protocol-version: elements + parameters + typed bonds + reaction conditions + residue | §12 |
| **Residue** | What a decomposition leaves unexpressed, per molecule | §12.4 |

**A note on the word "residue".** v0.1 used it for two different things. In
v1.0 *residue* is only the per-molecule remainder. The corpus-level statistic —
what share of incidents the table fails to explain — is called the
**unexplained-incident share** (§17.4).

---

## 3. The admission test

An entity is an **element** if all of the following hold. Where v0.1 stated a
seven-way conjunction and then admitted elements that failed it, v1.0 separates
what is *necessary* from what is *evidence of maturity*.

### 3.1 Necessary criteria

| Test | Requirement |
|---|---|
| **F** — functional irreducibility | No decomposition into two independently recurring mechanisms reproduces the function without losing its defining state transition |
| **R-struct** — structural separability | The mechanism is separable in principle: its state and transition can be stated without reference to the protocol that hosts it |
| **S** — role-preserving substitutability | A group sibling can replace it at the same role boundary and the application stays the same protocol class |
| **D** — distinct failure signature | It creates at least one failure mode not fully attributable to another element |
| **B** — state-transition boundary | It changes claims, obligations, allocation, valuation or settlement; **or** it changes which claim-changing transitions are reachable, and does so as persistent, independently parameterised policy state |
| **P** — model portability | Its semantics are statable over an abstract settlement scope, without reference to a specific VM's call, storage, gas or ordering model |
| **O** — observability | Identifiable in documentation, interfaces, state variables, events or auditable execution |

### 3.2 R-emp — a graded attribute, not a gate

**R-emp** records observed independent recurrence: named unrelated teams and
named independent code lineages. Forks count once.

R-emp determines *status*, not membership:

| Status | R-emp | Meaning |
|---|---|---|
| **core** | ≥ 3 unrelated teams and ≥ 2 lineages, named | Safe to rely on in analysis |
| **candidate** | R-struct met, R-emp short or a gate pending | Usable in formulas, flagged |
| **provisional** | A necessary criterion is genuinely contested | Not usable in a formula without a note |
| **degenerate limit** | A boundary case of another element whose **failure family differs** | Written as a limit, not an isotope |

**Why this changed.** v0.1 made recurrence necessary, which conflated atomicity
with diffusion and contradicted its own admission that a new primitive can ship
next week — under that rule a genuinely irreducible new mechanism could not be
an element until imitators arrived, and the whole P4 cohort carried an
uncorrected recency bias. It also produced a live contradiction: `Rs` sat in the
core set while the open register conceded its recurrence evidence was
outstanding, and `Of` was admitted on two instantiations, while the same
criterion was called a "hard gate" to demote constant sum. Splitting R fixes the
asymmetry in the direction of honesty: fewer confident claims, none withdrawn.

**Threshold sensitivity.** The 3-teams / 2-lineages line is a convention, not a
derivation. It is the single largest determinant of the headline count. At 2/1,
most current candidates promote and the count approaches 58. At 5/3, several
P4 elements demote and the count falls toward 42. **Quote the count with its
threshold or not at all.**

### 3.3 Standing rejections

Four categories are excluded by rule, not by enumeration.

- **Standards are interface bonds, not elements.** ERC-4626, ERC-7540,
  ERC-7683, ERC-7802 and the ERC-4337 account-abstraction family are sockets;
  the mechanism plugged into them is the element. This applies to 4337 exactly
  as it applies to 4626 — v0.1 drew two core elements from 4337 while rejecting
  4626 by name, and that asymmetry was unprincipled.
- **Hooks and callbacks are bonding sites.** A hook has no persistent policy
  state of its own; classify a deployed hook by the mechanism it instantiates.
  This is what criterion B's second clause discriminates: `Up`, `Gp` and `Tg`
  carry persistent, independently parameterised policy over reachability; a hook
  does not.
- **Narratives are not elements.** "Points", "real yield", "intent-centric",
  "unified balance as UX".
- **Derived observations are not elements.** A health factor reports the result
  of `Ct`. It changes nothing.

---

## 4. The elements

`str` = stratum. `atom` = position on the atomicity spectrum (§14):
**N** native · **R** repairable · **I** impossible. `layer` = CAKE pipeline stage
(§8.3): **A**pplication · **P**ermission · **S**olver · **T** settlement.

### G01 — Claims and accounting · role boundary: *how is a proportional claim recorded?*

| ID | Sym | Name | str | atom | layer | Definition |
|---|---|---|---|---|---|---|
| E001 | `Sh` | Pro-rata share accounting | S0 | R | A | Shares represent a proportional pool claim |
| E002 | `Ix` | Index-based accrual | S0 | R | A | A global exchange-rate or debt index changes claim value |
| E003 | `Rb` | Rebasing accounting | S0 | R | A | Nominal balances change through global scaling |

*Substitution:* swap `Sh` for `Ix` in a lending market and it is still a lending
market. Discriminator `record_authority` is **mandatory** where the claim is a
regulated instrument (§8.2).

### G02 — Pool pricing · role boundary: *how is a price derived from inventory?*

| ID | Sym | Name | str | atom | Definition |
|---|---|---|---|---|---|
| E004 | `Cp` | Constant-product invariant | S1 | R | `x·y = k` |
| E005 | `Wg` | Weighted-geometric invariant | S1 | R | Multi-asset weighted pricing |
| E006 | `St` | Stable-hybrid invariant | S1 | R | Constant-sum near parity, constant-product away from it |
| E007 | `Cl` | Concentrated liquidity | S1 | R | Range-specific position state and tick activation |
| E008 | `Pm` | Oracle-priced inventory curve | S1 | R | Proactive market making against an external reference |

*Substitution:* swap `Cp` for `Cl` in a DEX and it is still a DEX.

**Degenerate limit — `CSM` constant sum.** Not an element (R-struct holds but
R-emp for standalone deployment is absent) and **not an isotope of `St`**,
because an isotope must preserve the failure family and constant sum's does not:
at parity break the pool is fully drainable on one side, which is a qualitative
change of state space, not a parameter move. It is written `St{→CSM}` and
carries `drain_regime` (§7.3). v0.1 classified it as an isotope with a mandatory
flag justified by its *different* failure signature — a self-contradiction.

### G03 — Execution · role boundary: *how is a trade matched and cleared?*

| ID | Sym | Name | str | atom | layer | Definition |
|---|---|---|---|---|---|---|
| E009 | `Ob` | On-chain order book | S1 | R | S | Limit orders, sequencing, cancellation, settlement |
| E010 | `Rf` | Request for quote | S1 | N | S | Signed maker quote against inventory |
| E011 | `Ba` | Batch-auction clearing | S2 | N | S | Uniform clearing over a batch |
| E012 | `In` | Intent and solver execution | S4 | N | S | Signed outcome constraints delegated to competing solvers |

**Mandatory discriminator `market_structure`** on all four:
`{open, gated, exclusive, vertically-integrated}`. v0.1 shelved solver
concentration as an environmental condition; that was a category error, because
solver-set size, exclusivity windows and vertical integration are *design*
choices, not weather, and they determine who captures the informational rent.

### G04 — Liquidity catalysis · role boundary: *how is transient liquidity sourced?*

| ID | Sym | Name | str | atom | Definition |
|---|---|---|---|---|---|
| E039 | `Ag` | Aggregation and routing | S1 | R | Multi-venue route construction |
| E040 | `Fl` | Atomic flash liquidity | S1 | **I** | Borrow and repay within one settlement scope or revert |

*Split from Execution in v1.0:* flash liquidity is not substitutable for an
order book at any role boundary, so it failed the group's own definition.

`Fl` and criterion P: `Fl` is stated over an **abstract atomic settlement
scope**, not over an EVM transaction, so it passes P. Its async-*impossibility*
(§14) is a deployment property, not a semantic one. v0.1 defined it as a
transaction-scope predicate, which did violate P as then written.

### G05 — Credit · role boundary: *how is an obligation created?*

| ID | Sym | Name | atom | Definition |
|---|---|---|---|---|
| E013 | `Pl` | Pooled lending | R | Shared liquidity pool, many lenders and borrowers |
| E014 | `Im` | Isolated lending market | R | Per-market risk isolation with its own oracle, LLTV and rate model |
| E015 | `Cd` | Collateralized-debt minting | R | Mint a liability against locked collateral |
| E016 | `Uc` | Undercollateralized credit | N | Credit extended on identity, underwriting and recourse |
| E017 | `Ft` | Fixed-term debt | N | Maturity-dated claim with a discount factor |

All at stratum S3. **Mandatory `obligor` discriminator** on `Uc`, `Ft` and on
`Cd` where backing is off-chain (§8.2).

### G06 — Solvency · role boundary: *how is insolvency detected and resolved?*

| ID | Sym | Name | atom | Definition |
|---|---|---|---|---|
| E018 | `Ct` | Collateral-threshold solvency test | R | The margin/LTV/health computation and its threshold |
| E019 | `Li` | Incentivized liquidation | R | Third parties repay unhealthy debt for discounted collateral |
| E020 | `Ad` | Auto-deleveraging | R | Rank-ordered forced close when buffers are exhausted |
| E021 | `Sl` | Socialized-loss allocation | N | Losses assigned to an explicit claim class |
| E022 | `Bs` | Staked backstop | R | Slashable first-loss capital |

All S3. `Bs` isotope `{trigger=...}` covers solver bonding — v0.1 briefly
proposed a separate element `Sk` for this; it fails F, since bonded slashable
capital *is* `Bs` and only the trigger differs.

### G07 — Risk transfer · role boundary: *how is exposure moved between parties?*

| ID | Sym | Name | atom | Definition |
|---|---|---|---|---|
| E023 | `Pf` | Perpetual funding transfer | R | Periodic payment tethering a perp to an index |
| E024 | `Op` | Option payoff | N | Strike, expiry, collateralized contingent settlement |
| E025 | `Tr` | Tranche waterfall | N | Declared seniority over a determined loss event |
| E026 | `Cv` | Mutual cover pool | N | Adjudicated claims against pooled premium capital |
| E027 | `Py` | Principal/yield separation | N | Split a yield-bearing claim into PT and YT |

All S3.

### G08 — Truth · role boundary: *where does external fact enter?*

| ID | Sym | Name | atom | Definition |
|---|---|---|---|---|
| E028 | `Ex` | External data oracle | N | Imported off-chain value |
| E029 | `Tp` | On-chain time-weighted price | R | Cumulative-price accumulator over a window |
| E030 | `Oa` | Optimistic assertion oracle | N | Assert-then-dispute escalation game |
| E031 | `At` | Reserve, NAV or financial attestation | N | A named party's statement about backing or value |

All S2. `Ex` carries **mandatory** `delivery={push,pull,medianizer}`. `At`
carries **mandatory** `subject={reserve,nav,borrower-financials}` and
`assurance={audit,review,agreed-upon-procedures,management-attestation}` — v0.1
gave `At` no bonding law at all while giving one to the far less consequential
`Ex`, and overloaded one symbol across three objects with different attesters
and different legal consequences.

### G09 — Time and queueing · role boundary: *how is a claim deferred?*

| ID | Sym | Name | atom | Definition |
|---|---|---|---|---|
| E032 | `Sr` | Streaming accrual | N | Continuous per-second transfer from escrow |
| E033 | `Ep` | Epoch-gated transition | N | Snapshot, cutoff, rollover |
| E034 | `Wq` | Asynchronous withdrawal queue | N | Request now, claim later, against future asset availability |

All S2.

### G10 — Incentives · role boundary: *how is participation paid for?*

| ID | Sym | Name | str | atom | Definition |
|---|---|---|---|---|---|
| E035 | `Em` | Protocol-funded emissions | S2 | N | Newly issued tokens paid for measured actions |

### G11 — Control and authority · role boundary: *who may change what, and when?*

| ID | Sym | Name | str | atom | layer | Definition |
|---|---|---|---|---|---|---|
| E036 | `Tg` | Delayed-governance execution | S4 | N | P | A timelock between authorization and executability |
| E037 | `Up` | Mutable implementation proxy | S4 | N | P | Code replacement changes the reachable state machine |
| E038 | `Gp` | Emergency guardian or pause | S4 | N | P | Bounded suppression of reachable transitions |
| E050 | `Au` | Delegated execution scope | S4 | N | P | Persistent policy bounding the calls, assets, destinations, values, chains and time windows a delegate may reach |

### G12 — Cross-domain · role boundary: *how does state or value cross a trust boundary?*

| ID | Sym | Name | str | atom | layer | Definition |
|---|---|---|---|---|---|---|
| E041 | `Xm` | Cross-domain message verification | S4 | N | T | Decide whether a source-domain assertion is acceptable at the destination |
| E042 | `Xf` | Cross-domain asset transfer | S4 | N | T | Create a destination claim against an explicit source debit |

`Xm` carries **mandatory** `trust_domain`; `Xf` carries **mandatory** `form`
(§8.2).

### G13 — Stability · role boundary: *how is a peg defended?*

| ID | Sym | Name | atom | Definition |
|---|---|---|---|---|
| E043 | `Rd` | Direct redemption right | R | Redeem a liability against backing at a defined rate |
| E044 | `Ps` | Peg-swap module | N | 1:1 reserve-backed swap with mint/burn authority |
| E045 | `As` | Algorithmic supply adjustment | N | Supply expansion/contraction driven by measured price |

All S3.

### G14 — Access and privacy · role boundary: *who may hold, and who may see?*

| ID | Sym | Name | str | atom | Definition |
|---|---|---|---|---|---|
| E046 | `Aw` | Permission or identity gate | S2 | N | Credential-checked eligibility |
| E047 | `Sb` | Shielded-balance state | S2 | R | Commitments and nullifiers hide ownership |

### G15 — Security reuse

Core: empty. Its sole occupant `Rs` is a candidate — see §4.1.

**Core total: 48.** By stratum: S0 3 · S1 12 · S2 12 · S3 17 · S4 8 → wait, see
the reconciliation table in §6. By group: 3+5+4+2+5+5+5+4+3+1+4+2+3+2 = 48.

### 4.1 Candidates (8) — usable in formulas, flagged

| ID | Sym | Name | Group | str | R-emp as evidenced | Promotion gate |
|---|---|---|---|---|---|---|
| E048 | `Sd` | Selective-disclosure proof | G14 | S2 | thin | Finance-specific proof semantics, applied symmetrically with `Zk` |
| E049 | `Rs` | Restaking / shared security | G15 | S4 | 1–2 lineages | 3 independent lineages with distinct slash-attribution behaviour |
| E051 | `Gs` | Sponsored-fee liability | G11 | S3 | thin | Named teams; also a restatement free of gas metering |
| E053 | `Rl` | Resource lock / reservation | G12 | S4 | 1–2 named | 3 unrelated teams |
| E054 | `Of` | Optimistic fill and reimbursement | G12 | S4 | 2 named | 3 unrelated teams, 2 lineages |
| E056 | `Fz` | Administrative freeze / forced transfer | G14 | S2 | recurs widely, uncoded | A coded corpus; mandatory `authority_source` |
| E057 | `Sv` | Servicing and determination discretion | G07 | S3 | recurs widely, uncoded | A coded corpus of workout behaviour |
| E058 | `Fd` | Surplus and fee distribution | G10 | S2 | recurs widely, uncoded | Evidence it is not reducible to `Em` plus parameters |
| E059 | `Vl` | Staking and validator lifecycle | G16 | S3 | recurs widely, uncoded | A coded corpus; separation from `Bs` and `Sl` |
| E060 | `Dp` | Directional position and hedge maintenance | G07 | S3 | recurs widely, uncoded | Evidence it is not `Pf` plus `Ct` plus parameters |

`Sd`, `Rs`, `Gs`, `Rl` and `Of` were **core in v0.1** and are demoted here on the
evidence the sources actually supply. `Fz`, `Sv` and `Fd` are **new in v1.0**,
added because three lenses independently found the table could not express
freeze/clawback, workout discretion, or who gets paid.

`Vl` and `Dp` are also new, and they close the sharpest gap the review found.
An implementer lane decomposed three ordinary protocols and hit **central**
residue in all three: Lido reduces to `Sh+Rb+Ex+Wq+Sl+Tg+Gp+Up` and leaves
ordinary delegation, validator activation and exit, reward accrual and penalty
attribution unexplained; Ethena reduces to `Cd+Rd+Ex+Pf+Ct+Sh+At+…` but `Pf` is
a *funding transfer*, not the short perpetual position, hedge rebalancing, venue
margin or custody exposure; Pendle v2's time-to-expiry-dependent AMM fits none
of `Cp`/`Wg`/`St`/`Cl`/`Pm`. Residue at the centre of a protocol rather than its
periphery is exactly the promotion signal §12.4 describes. The third gap —
time-dependent pricing — is left with provisional `Tw`, whose gate is now
explicitly that it cannot be expressed as an AMM plus `Ep`.

**G16 — Staking**, role boundary: *how is consensus-securing capital committed
and returned?* Core: empty; `Vl` is its sole candidate.

**On E052:** reserved for `Ua` (unified balance), which remains provisional. v0.1
left the ID unallocated and unexplained.

### 4.2 Provisional (10) — not usable in a formula without a note

`Bc` bonding-curve issuance · `Tw` time-weighted AMM execution · `Da`
Dutch-auction descent · `Cg` credit delegation · `Ir` insurance reserve fund ·
`Zk` verifiable state proof · `Ve` vote-escrow allocation · `Kg`
credential-gated transfer · `Ua` enforceable unified-balance ledger (E052) ·
`Sq` shared ordering commitment.

Every gate is now stated strictly in terms of §3's criteria. v0.1 set `Da`'s bar
at "three unrelated lineages with unique behaviour" when the published criteria
ask for two lineages and *at least one* non-attributable failure mode — a
stricter bar for a candidate than for the core sibling `Ba` sitting at the same
role boundary.

---

## 5. Groups

A group answers: *what else could sit at this role boundary?* Each group in §4
now carries a role-boundary sentence and a substitution example, because in v0.1
the groups were taxonomic categories labelled as substitutability families —
`Fl` sat in Execution though it substitutes for no order book, and `Gs` sat in
Control though it is not a sibling of an emergency pause. Both are moved.

Group membership predicts nothing else. There is no periodic law: properties do
not recur down a column.

---

## 6. Strata (formerly "periods")

**Definition:** the *category of prerequisite* an element minimally needs.

| Stratum | Meaning | Members |
|---|---|---|
| **S0** | Ledger-local claims and accounting | `Sh` `Ix` `Rb` |
| **S1** | Deterministic transformation inside one settlement domain | `Cp` `Wg` `St` `Cl` `Pm` `Ob` `Rf` `Ag` `Fl` |
| **S2** | Externally measured or time-conditioned state | `Ba` `Ex` `Tp` `Oa` `At` `Sr` `Ep` `Wq` `Em` `Aw` `Sb` (+ candidates `Sd` `Fz` `Fd`) |
| **S3** | Contingent obligation, solvency, risk transfer, stability | `Pl` `Im` `Cd` `Uc` `Ft` `Ct` `Li` `Ad` `Sl` `Bs` `Pf` `Op` `Tr` `Cv` `Py` `Rd` `Ps` `As` (+ candidates `Gs` `Sv`) |
| **S4** | Multi-agent, cross-domain or mutable-control coordination | `In` `Tg` `Up` `Gp` `Xm` `Xf` (+ candidates `Rs` `Rl` `Of`) |

Core counts: 3 + 9 + 11 + 18 + 6 = 47, plus `Au` at S4 = 48.

**Honest correction.** v0.1 called this axis "minimum dependency depth" and
implied a graph computation. It is not one: `Ag` cannot exist without venues to
route between and `Fl` needs a pool to borrow from, yet both sit alongside those
venues; `Li` presupposes `Ct` within S3. Same-stratum dependency is permitted,
so this is a *stratum by category of prerequisite*, not a graph depth.
Publishing a computed dependency DAG — which would make the strata and the
bonding laws mutually checkable — is v1.1 work and is in the open register.

---

## 7. Isotopes

### 7.1 Definition and test

An isotope is a variant — continuous **or discrete** — that preserves both the
state-transition semantics and the **failure family**. v0.1's test ("continuous
parameter change") contradicted its own sanctioned instances, since lock-mint
versus burn-mint is a discrete alternative.

If the failure family differs, it is not an isotope. It is either a distinct
element or a **degenerate limit** (§4, G02).

### 7.2 The isotope register

Only these are legal. Anything else is free text and makes a formula ill-formed.

| Element | Key | Legal values | Failure difference preserved |
|---|---|---|---|
| `Ex` | `delivery` | push, pull, medianizer | staleness mode |
| `Xf` | `form` | lock-mint, burn-mint, custodial-release | where residual risk sits |
| `Xm` | `trust_domain` | light-client, native-consensus, external-validator, optimistic, zk-assisted, shared-sequencer | verifier compromise mode |
| `Li` | `mode` | auction, fixed-bonus, partial | bid-failure mode |
| `Bs` | `trigger` | shortfall, non-fill, slash | activation condition |
| `Cl` | `fee_tier`, `tick_spacing` | numeric | range-exhaustion granularity |
| `St` | `A` | numeric | depeg inventory concentration |
| `Cp` | `fee` | numeric | — |
| `Im` | `mode` | isolation, e-mode, single-base | contagion boundary |
| `Sh` | `offset` | numeric | first-depositor inflation |
| `At` | `subject`, `assurance` | see §4 G08 | who is lying, and about what |
| `In`,`Ba`,`Rf`,`Ob` | `market_structure` | open, gated, exclusive, vertically-integrated | rent capture and censorship |

### 7.3 `drain_regime`

Introduced in v0.1 as mandatory and defined nowhere. It applies to `St{→CSM}`
and to any pricing element operating at a degenerate limit. Values:
`{none, one-sided-drainable, fully-drainable}`. It is read by hazard rule X5 and
by screening step 4 (§18.2). Omitting it on a degenerate-limit element makes the
formula ill-formed.

---

## 8. Attributes and discriminators

### 8.1 Attributes (advisory, carried per element)

| Attribute | Values |
|---|---|
| `atom_dependency` | native · repairable · impossible (the `atom` column in §4) |
| `layer` | Application · Permission · Solver · Settlement |
| `claim_perfection` | none · contractual-unsecured · security-interest-unperfected · security-interest-perfected · bankruptcy-remote-SPV · custodial-trust |

`atom_dependency` values in §4 assume a **single-domain deployment**; a
cross-domain deployment reassigns them (§14).

**`layer`** comes from CAKE — a request-pipeline framing that splits a user
request into Application (what is wanted), Permission (who may authorize),
Solver (who finds the path) and Settlement (how it finalizes). It is an
orthogonal annotation, not a stratum: one element can span several in a
molecule. v0.1 asserted `layer` was carried on every element and carried it on
none; §4 now carries it wherever it is discriminating.

### 8.2 Discriminators (mandatory)

**The rule (new in v1.0):** *a discriminator is mandatory if and only if its
distinct values select different rows in the hazard table (§15).* Below that
bar, a variant is an optional isotope.

| Element | Discriminator | Why mandatory |
|---|---|---|
| `Xm` | `trust_domain` | X13 fires on external-validator and not on light-client |
| `Xf` | `form` | X12 fires on lock-mint and not on burn-mint |
| `At` | `subject`, `assurance` | L3 needs borrower-financials specifically; a reserve attestation is not evidence about a borrower |
| `Uc`,`Ft`,`Cd`(off-chain backing) | `obligor` | none · protocol-treasury · named-operating-entity · bankruptcy-remote-SPV · regulated-custodian · trust |
| `Sh`,`Ix`,`Rb` (regulated instrument) | `record_authority` | on-chain-dispositive · off-chain-register-dispositive · dual-with-reconciliation |
| `In`,`Ba`,`Rf`,`Ob` | `market_structure` | X14 fires on exclusive |
| `Fz` | `authority_source` | issuer-discretion · court-order · sanctions-list · protocol-governance |
| degenerate-limit pricing | `drain_regime` | X5 |

**On `Xm`'s count.** Because its discriminator is mandatory and
non-defaultable, `Xm` never appears bare in a well-formed formula — only its six
discriminated forms do. That is operationally close to a six-way split reported
as one element, and the honest presentation is both numbers: **one element, six
instantiable forms.** The reason it is not six elements is criterion S: a
protocol can replace a validator set with a light client and remain the same
kind of system. The reason the discriminator is mandatory is that the swap moves
the molecule between hazard rows.

### 8.3 The legal surface (canonical)

One enumeration, referenced everywhere else: **`Uc`, `Ft`, `Tr`, `At`, `Aw`,
`Fz`, `Sv`**, plus the `obligor`, `claim_perfection` and `record_authority`
discriminators. v0.1 gave three different, non-identical enumerations, one of
which ("RWA") was not a defined term anywhere.

---

## 9. Bond types

Each must be satisfied **separately**. A protocol is not valid because its
contracts can call each other.

| Bond | Arrow | Question | Failure when unsatisfied |
|---|---|---|---|
| **Interface** | `—i→` | Can these exchange the required calls, tokens, messages, proofs? | Integration breakage, silent accounting corruption |
| **Economic** | `—e→` | Do combined incentives, liquidity, valuation and loss allocation stay solvent? | Bad debt, runs, unprofitable liquidation |
| **Trust** | `—t→` | Who can attest, censor, upgrade, pause, mint, freeze? | Key compromise, malicious upgrade, false attestation |
| **Informational** | `—n→` | Who observes amount, urgency, route, constraints or wallet state before settlement? | Adverse selection, order-flow capture |

### 9.1 The informational bond, restated

**Retained.** The observation graph is not the incentive graph: an observer
needs no call, transfer, incentive or attestation to see an order, and folding
that into the economic bond makes order-flow analysis unauditable.

**Overclaim removed.** v0.1 said it was "irreducible to a priced externality".
That is wrong — adverse selection is routinely capitalized into spreads and
exclusivity premia. The correct claim is narrower: pricing may absorb the rent
*ex post*, but the channel must still be named *ex ante*.

**Consequence catalog (closed).** A `—n→` edge must carry one of:
`adverse_selection` · `frontrunning` · `orderflow_capture` · `last_look` ·
`exclusivity_rent` · `sandwich` · `liquidation_targeting` · `deanonymization`.
Free text may follow, but the enum is what a checker validates. v0.1's naming
clause required "the economic consequence" in prose, which any string satisfies.

**Settling test, made symmetric.** v0.1 asked challengers to reduce *every*
observation edge to the other three — an unbounded burden on objectors and none
on the proponent. v1.0 assigns it to the proponent: *if every `—n→` edge in the
corpus can be reduced to an `—e→` plus a `—t→` edge, the type is dropped.* That
test is owed by this document and has not been run. It is in the open register.

### 9.2 Why not a fifth type

Latency is a reaction condition; authority is a bond property carried by `—t→`.

**Legal enforceability is the contested case.** One council lane argued for a
fifth `—l→` bond: enforceability is a *relation* between an on-chain claim and
an off-chain estate — exactly a bond's shape — and two elements can be
interface-valid, economically solvent, trust-sound and informationally clean
while the holder still has no cognizable claim. v1.0 declines, handling the
legal surface through mandatory discriminators (§8.2–8.3) instead, on parsimony
grounds. **This is unresolved dissent, not a settled question** (§20.4).

---

## 10. Valence

`V(e) = {Vᵢ, Vₑ, Vₜ, Vₙ}` — the typed set of required counterparts. A vector,
never an integer.

**Derivation rule (new):** `Vₓ(e)` is the set of `—x→` counterparts named on the
right-hand side of every law in §13 that names `e` on the left. Valence is
therefore *computed from the laws*, not asserted.

| Element | Vᵢ | Vₑ | Vₜ | Vₙ | Integration cost |
|---|---|---|---|---|---|
| `Cp` | token interface | arbitrage depth | — | mempool visibility | low |
| `Sh` | token interface | — | — | — | low |
| `Ct` | position ledger | — | truth source | — | medium |
| `Pl` | `Sh`\|`Ix`, exit path | `Li`\|`Ad`\|`Sl`\|`Bs` | `Ex`\|`Tp`\|`At` | — | high |
| `Xf` | `Xm`\|custodian | supply ledger | verifier set | — | high |
| `Of` | `Xm`, `Xf` | `Bs`\|`Sl`, timeout | filler solvency | order visibility | high |
| `In` | settlement verifier | solver/fallback | solver set | **required** | high |
| `Uc` | `Aw`, `At` | `Bs`\|`Tr` | obligor, legal forum | — | very high |

*(The economic-valence component is written `Vₑ` to avoid collision with the
provisional element symbol `Ve`, vote-escrow — a clash present in v0.1.)*

Valence is consumed by screening step 2 (§18.2): an element whose valence is
unsatisfied is a finding, not a stylistic gap.

---

## 11. Catalysis

**Catalyst is not a construct.** v0.1 listed it as one of nine, but three of its
four members (`Fl`, `Ag`, `Xm`) are also elements, so the class was not disjoint
from Element — a category error. And its fourth member, "solver competition",
is market structure, which §4 G03 now carries as a discriminator.

**`*` is an occurrence annotation**, evaluated per formula: mark an element `X*`
when, *in this molecule*, it leaves no post-settlement claim. `Fl` is almost
always marked; `Ag` and `Xm` sometimes are.

**Restated honestly:** "a catalyst is never itself the vulnerability, the
vulnerability is the bond it catalyzes" is a *definitional convention*, not an
empirical finding — any `Fl`-involving exploit is assigned to a bond by
stipulation. Stated as a finding it encourages reviewers to under-weight
enabling mechanisms, which is why §18.2 now has an explicit catalyst re-pricing
step.

---

## 12. Notation

### 12.1 Grammar

```
molecule    := name "@" version NEWLINE
               "elements:"   term ( ("+" | "||") term )*
               "bonds:"      ( bond )*
               "conditions:" text
               "residue:"    ( text | "none" )

term        := symbol [ "{" iso ( "," iso )* "}" ] [ "*" ] [ "?" ]
iso         := key "=" value
bond        := endpoint arrow endpoint [ "[" tag "]" ]
arrow       := "—i→" | "—e→" | "—t→" | "—n→"
endpoint    := symbol | quoted-external
alt         := term "|" term          -- alternatives at one role boundary
```

- `+` binds tighter than `||`. `|` binds tightest and may appear only inside a
  parenthesised role slot.
- `→` (bare) is the **requires** relation, used only in the laws of §13, never
  inside a molecule. v0.1 used it 25 times without defining it.
- `?` means *conditionally present in this deployment*, never *analyst unsure*.
  An analyst's uncertainty belongs in `residue`. **A `?` term does not satisfy a
  law**: `Bs?` does not discharge L4's `(Ad|Sl|Bs)` requirement.
- One canonical isotope syntax: `key=value`. `Ex{push}` is deprecated; write
  `Ex{delivery=push}`.
- Non-element endpoints (`"filler"`, `"exit-liquidity"`, `"timeout"`) are legal
  in bonds but must be quoted, so a checker can tell them from symbols.
- **Provisional symbols may not appear** in a formula without an inline note.
  Candidates may, and are flagged by status.

### 12.2 Instances, not just classes

A symbol names an element **class**. A protocol with several markets, collateral
policies, oracle feeds, proxies or liquidation paths collapses all of them into
one symbol — so two formulas can compare equal while requiring wholly
incompatible integrations. That makes the near-isomer procedure (§18.5) unsound
at deployment granularity.

**Instance syntax:** `symbol#label` with optional cardinality `×n`.

```
Aave v3 ≈ Pl + Ix + Ct#core + Ex#chainlink{delivery=push} ×27 + Li{mode=partial}
```

Repeated elements are legal and must carry either distinct labels or an explicit
cardinality. A **deployment anchor** — chain, address, implementation version —
belongs in the molecule header when the formula describes a specific deployment
rather than a protocol design:

```
Aave v3 @ethereum:0x87870B…:v3.2
```

Formula equality is only an isomerism claim at the granularity you wrote it. A
class-level match says the two systems are the same *kind*; it says nothing
about whether an integration written against one works against the other.

### 12.3 Ill-formedness

A formula is ill-formed if it: omits a mandatory discriminator (§8.2); carries a
`—n→` edge without a catalog tag (§9.1); uses an unregistered isotope key
(§7.2); uses a provisional symbol unnoted; or omits the `conditions` or
`residue` lines.

### 12.3 Worked formulas (conformance-checked)

v0.1's formulas violated its own rules — bare `Xm`, `Of` with no timeout or
loss allocator, `In` with no `—n→` — and none showed the four-term schema.
Re-derived:

**Uniswap v3**
```
elements:   Sh + Cl{fee_tier=3000,tick_spacing=60} + Tp + Fl*
bonds:      Cl —n→ mempool [sandwich]
conditions: same-transaction atomicity; MEV regime; pool depth vs position size
residue:    NFT position-manager behaviour; exact tick math
```

**Aave v3**
```
elements:   Pl + Ix + Ct + Ex{delivery=push} + Li{mode=partial} + Bs{trigger=shortfall}
            + Gp + Up + Tg + Im{mode=isolation}
bonds:      Pl —e→ Li ; Ct —t→ Ex ; Up —t→ Tg ; Li —e→ "exit-liquidity"
conditions: oracle heartbeat vs volatility; executable depth at liquidation size; gas
residue:    e-mode correlation assumptions; portals; asset adapters
```

**CCTP v2 Fast**
```
elements:   Au{scope=issuer-mint} + Xm{trust_domain=native-consensus} + Xf{form=burn-mint} + Of
bonds:      Xf —i→ Xm ; Of —e→ "issuer balance sheet" ; Xm —t→ "attester"
conditions: source finality horizon; fast-transfer allowance depth
residue:    allowance pricing; issuer governance
```

Abbreviated one-line forms are permitted for comparison work and are written
without the `conditions`/`residue` lines, marked `≈`: `Liquity v1 ≈ Cd + Ct +
Ex + Li + Rd + Bs{trigger=shortfall}`.

### 12.4 Residue

Per molecule, and always present. Residue is a *finding*: it is what the
vocabulary could not express about this protocol. Recurring residue across three
unrelated protocols is the primary evidence for a new element.

---

## 13. Required-bond laws

| # | Law | Async-safe |
|---|---|---|
| L1 | `(Pl\|Im\|Cd\|Pf\|Op) → (Ex\|Tp\|At) + Ct + (Li\|Ad\|Sl\|Bs)` | **No** — cross-domain also needs a named finality assumption and a liquidation-latency bound |
| L2 | `Pl → (Sh\|Ix) + "exit-liquidity"` | Yes |
| L3 | `Uc → Aw + At{subject=borrower-financials} + (Bs\|Tr) + obligor` | Yes |
| L4 | `Pf → Ex + Ct + Li + (Ad\|Sl\|Bs)` | No |
| L5 | `Py → (Sh\|Ix\|Rb) + Ep + Rd` | Yes |
| L6 | `Tr → (Sv \| mechanical trigger) + declared seniority + dispute forum + recovery-timing assumption` | **No** |
| L7 | `Cd → Rd \| Ps \| liquidation capacity` | Yes |
| L8 | `Xf → Xm \| named custodian` + global claim ledger | Yes |
| L9 | `Xf → debit(source) = credit(destination)` | Yes |
| L10 | `Sb → proof verifier + nullifier set` | Yes |
| L11 | `Sd → credential source + verifier + revocation` | Yes |
| L12 | `In → signed constraints + settlement verifier + (solver\|fallback) + timeout` | Yes |
| L13 | `Ex → freshness validation`; `Gp` strongly preferred for high-value obligations | Yes |
| L14 | illiquid backing `→ Wq \| bounded liquidity reserve` | Yes |
| L15 | `Up → Tg \| bounded emergency process` | Yes |
| L16 | `Aw → transfer-time enforcement` where eligibility follows the holder | **No** — see L26 |
| L17 | `Au → bounded scope + revocation + expiry + nonce/domain separation` | Yes |
| L18 | `Xm → explicit finality + chain/domain binding + replay protection` | Yes |
| L19 | `Of → Xm + Xf + (Bs\|Sl) + timeout` | Yes |
| L20 | `Rl → Au + single-spend + expiry + fulfillment proof + release` | Yes |
| L21 | `Gs → Au + metering + fee settlement` | Yes |
| L22 | `Rs → attributed slash condition + non-reflexive capital + loss waterfall` | Yes |
| L23 | `Sq → Xm + independent settlement finality` | Yes |
| L24 | `(In\|Rf\|Ba) →` an explicit `—n→` edge with a catalog tag | Yes |
| L25 | wrapped cross-domain collateral `→` bridge-specific haircut + cap + independent exit | Yes |
| **L26** | `Aw + Xf →` destination-enforced eligibility + revocation propagation with a staleness bound + jurisdictional binding + issuer anointing of the destination representation | **No** |
| **L27** | `At → ` named attester + independence from the obligor + stated scope and assurance + periodicity and staleness bound + recourse against the attester | Yes |
| **L28** | `Fz →` named authority + enumerated triggers + appeal/reversal path + holder disclosure | Yes |
| **L29** | `(In\|Ba\|Rf\|Of) →` a declared surplus-allocation rule naming the residual claimant | Yes |

L6, L16, L26–L29 are new or materially rewritten in v1.0.

---

## 14. Hazard rules

**Renamed from "forbidden bonds".** Every row below reports failures. None
reports survivors. The table has **no denominator**: X2, for instance, is
instantiated by a large number of live protocols, most of which have not been
drained, and the rule as stated cannot say why. This document applies a
false-positive-rate standard to reflexivity (§16.1) and then exempts these rows
from it; that is a double standard, named here rather than hidden.

Classes: **F** forbidden (a logical or conservation contradiction) ·
**H** elevated hazard (known survivors exist) · **U** unverifiable as claimed.

| # | Combination | Class | base rate | Grounding |
|---|---|---|---|---|
| X1 | `As` + reflexive junior token, no hard redemption or exogenous capital | F | unknown | Terra/UST 2022 |
| X2 | `Fl*` + manipulable `Cp`/`Cl` price + `Pl`/`Cd`, **where manipulation cost < position value** | H | unknown, many survivors | bZx; Mango; Cream |
| X3 | Protocol token as collateral **and** oracle market **and** backstop | H | unknown | one shock impairs three defences |
| X4 | `Rb` into a balance-invariant ledger without an adapter | F | — | interface contradiction |
| X5 | Illiquid backing + uncapped instant par redemption; or `drain_regime=fully-drainable` with unbounded inventory | H | unknown | settlement-speed mismatch |
| X6 | Borrowable voting power + immediate execution (flash **or** slow accumulation) | H | unknown | Beanstalk 2022 |
| X7 | Cross-domain mint whose verifier is **present but unproven correct**, or without an independent supply invariant | H | unknown | Wormhole; Nomad |
| X8 | Shared collateral across nominally isolated markets | H | unknown | contagion escapes the boundary |
| X9 | `Up` with immediate single-key control | H | many survivors | — |
| X10 | `Pm` with stale reference and unrestricted inventory | H | unknown | — |
| X11a | `Uc` with **no** `Aw`/`At`/collateral/reputation | F | — | structural |
| X11b | `Uc` with all of them and weak underwriting | H | unknown | Maple 2022 — paperwork is not underwriting |
| X12 | `Xf{form=lock-mint}` wrapped asset as canonical collateral **whose value at risk exceeds the bridge's economic security, or with no independent exit** | F | — | Wormhole-wrapped; Multichain |
| X13 | `Xm{trust_domain=external-validator}` securing value **exceeding slashable stake** | H | unknown | Ronin; Nomad |
| X14 | `market_structure=exclusive` **plus a price-improvement claim with no named benchmark or commitment device** | **U** | — | see below |
| X15 | `Rs` securing a bridge mostly with assets issued by that bridge | H | unknown | — |
| X16 | Unbounded delegated authority — `Au` without scope bounds, **or unlimited token approvals** | H | many survivors | BadgerDAO |
| X17 | Passive protocol-token reserve backing protocol-token collateral | H | unknown | — |
| X18 | `Oa` as sole truth for high-frequency liquidation | H | — | dispute latency vs closeout |
| **X19** | Permissioned or transfer-restricted claim bridged via `Xf` into a representation with no destination-side `Aw` | F | — | permission laundering, see L26 |

**X14 was "impossible" in v0.1 and that was economically false.** Exclusivity
removes contemporaneous multi-solver rivalry on that order; it does not remove
all competitive content. Price improvement stays definable and enforceable
against an external benchmark, franchise bidding, contestable entry, or a bonded
improvement obligation. The defensible claim is *unverifiable without a named
counterfactual* — so the rule now requires the formula to name one.

Several rows were tightened from presence-tests to predicates, because a
protocol with a defective verifier still *claims* independent verification and
would have passed X7 as v0.1 wrote it (Wormhole did); and a compromised
threshold validator set still empties the bridge whether or not it is bonded
(Ronin did).

**Issuer anointing removed as a safety condition.** v0.1's X12 treated an
issuer's endorsement of a wrapped representation as curative. It is not:
endorsement is a statement about canonicality, not about the bridge's economic
security, and no amount of it stops a verifier compromise. X12 now tests value
at risk against economic security and the presence of an independent exit.

**Thresholds are still missing.** X1, X3, X5, X9, X10, X13, X15 and X18 contain
undefined terms — *hard* redemption, *exogenous* capital, *dominates*,
*illiquid*, *stale*, *unrestricted*, *mostly*, *high-frequency*. A real design
can satisfy the words and remain economically unsecured; X9 as written passes a
correlated low-threshold multisig. Converting each row into a measurable
predicate (redemption capacity under stress, manipulation cost versus position
size, signer threshold *and administrative-domain independence*, slash
collectability, dispute latency versus closeout time) is registered work in
§20.3, not something this revision completed.

---

## 15. The atomicity spectrum

| Level | Meaning | Repair |
|---|---|---|
| Same transaction | All state changes commit or revert together | none |
| Same block | Separate transactions, adversarially orderable | batch clearing, commit-reveal, preconfirmation |
| Shared sequencer | Several domains accept a common ordering commitment | `Sq` + accountability + later verification |
| Same-ecosystem finality | Domains share or coordinate finality | ecosystem-aligned `Xm` + timeout |
| Cross-ecosystem | Independent consensus and finality | `Xm+Xf+(Rl\|Of)` + haircuts + loss allocation |
| Optimistic | Destination value advanced before finality | `Of+(Bs\|Sl)` + challenge + reimbursement timeout |

**Standing prediction:** *no cross-chain flash liquidity exists without an
intermediary, precommitted credit, or a shared rollback domain.* `Fl` is the only
async-impossible element. Anything marketed as "cross-chain flash" is
`Of+Rl+(Bs|Sl)` — which has a lender, a reservation, a loss allocator and a
finality assumption that the word "flash" conceals.

---

## 16. Overlays

### 16.1 Reflexivity — two statuses, kept apart

v0.1 demoted reflexivity to "a hypothesis" and then made it the first,
stop-the-line check. That is an epistemic demotion and an operational promotion
at once, and it trains reviewers to treat reflexivity clearance as the main gate.

| Claim | Status |
|---|---|
| **Mechanism class** — reflexive collateral, leverage cycles, fire-sale externalities and liquidity spirals amplify shocks | **Established.** Standard economics, not folklore. Design against it. |
| **Table-level scored screen** — reflexivity is the best available predictor of catastrophic failure | **Uncalibrated hypothesis.** No longitudinal coding, no matched controls, no false-positive rate. |

The triple loop — protocol token as collateral value, market depth *and*
insurance capital simultaneously — is a concrete amplification channel and the
highest-value thing to look for. Its **cross-domain analogue** is a trust-domain
cycle: chain X depends on bridge B while B's verifier capital depends on assets
issued through B.

Operationally: reflexivity is a cheap **non-gating parallel screen** (§18.2), not
the first gate.

### 16.2 Implementation integrity — new in v1.0

The largest gap the council found: v0.1 had no representation anywhere — not in
elements, bonds, conditions or residue — of smart-contract control-flow safety.
A design could pass every rule in this document and still ship a
reentrancy-class or share-inflation-class loss.

This overlay is **not** a set of elements. It is a mandatory companion program:

| Pattern | Check |
|---|---|
| Reentrancy / read-only reentrancy | No external call with unfinalized accounting; no callback into privileged state |
| Callback tokens (ERC-777-class) | Transfer hooks cannot re-enter claim math |
| Arbitrary external call / `delegatecall` | Target set bounded and non-upgradable by a caller |
| Share inflation / first-depositor | Empty-pool mint invariant; `Sh{offset}` set |
| Rounding and precision | Direction of rounding always favours the pool |
| Initialization and storage layout | Initializers single-shot; proxy layout checked across upgrades |
| Signature and message parsing | Malleability, domain separation, replay, length assumptions |
| **Compiler and build provenance** | Compiler version pinned and its known defects checked; reproducible build; deployed bytecode matches source |
| Access control | Every privileged entrypoint enumerated and tested |

The compiler row is not hypothetical: a whole class of losses has come from a
language-level codegen defect in contracts whose financial design was sound.
Nothing in the element vocabulary can see that.

**Verification presence is not verification correctness.** `Xm` being present
says nothing about whether its signature check is right. Wormhole had a
verifier; Nomad had a Merkle root check.

### 16.3 Decay

Half-life is measured in support variables, not calendar time: reflexive decay
(`As`, token backstops) · liquidity migration (old AMM versions) · governance
abandonment (`Up`, `Gp`, `Tg`) · oracle obsolescence (`Ex`, `Tp`) · bridge trust
decay (`Xm`, `Xf`) · emission decay (`Em`) · integration decay (`Rb`) · legal
decay (`At`, `Aw`, the legal surface of §8.3).

### 16.4 Failure overlay

Five root categories. Category (e) is new in v1.0.

| | Category | Discriminating question |
|---|---|---|
| (a) | Defective element instance | Would a correct implementation of every element have survived? |
| (b) | Invalid bond between valid elements | Did every element work as coded, in a combination that was unsafe? |
| (c) | Environment outside stability range | Were the reaction conditions violated? |
| (d) | Outside the table — operational | Key compromise, phishing, front-end injection, coerced signer |
| **(e)** | **Counterparty and legal** | Obligor default, misappropriation, servicer default, custodian insolvency, sanctions/forced unwind, true-sale re-characterisation |

---

## 17. Reaction conditions

| Condition | Elements affected | Question |
|---|---|---|
| Block time and finality | `Ob` `Li` `Xm` `Xf` `In` | Can settlement finish before value moves? |
| Mempool and MEV regime | `Cp` `Cl` `Ob` `Ba` `In` `Fl` | Is extractable value beyond tolerated bounds? |
| Oracle latency and confidence | `Pl` `Cd` `Pf` `Pm` `Ct` | Is the value current relative to volatility and closeout time? |
| Executable market depth | `Li` `Rd` `Ps` `Ct` | Can collateral sell near its marked value? |
| Gas and congestion | `Li` `Oa` `Ep` `Wq` | Can required actors afford to act? |
| Withdrawal settlement cycle | `Wq`, staking, RWA | Does queue duration match backing liquidity? |
| Validator/operator concentration | staking, app-chains, `Xm` | Can one group censor, reorder, attest or halt? |
| Governance reaction speed | `Tg` `Gp` `Up` | Fast enough for emergencies, slow enough for oversight? |
| Legal enforceability | the legal surface (§8.3) | Does the on-chain claim correspond to an enforceable priority? |

*Solver market structure was listed here in v0.1 and has been promoted to a
mandatory discriminator (§8.2) — it is a design choice, not weather.*

---

## 18. How to use it

### 18.1 Decompose a protocol

Four passes, each with an exit criterion. v0.1's version terminated only by
analyst fatigue.

| Pass | Input | Output | Exit criterion |
|---|---|---|---|
| **1 Elements** | Docs, interfaces, state variables | Symbol list with isotopes and mandatory discriminators | Every state-changing entrypoint maps to a symbol or to a residue line |
| **2 Bonds** | Pass 1 + §13 | Typed bond list | Every law naming a present element on its left is discharged or recorded as violated |
| **3 Conditions** | Pass 2 + §17 | Bounded operating range | Every row of §17 touching a present element has a stated bound or an explicit "unbounded" |
| **4 Residue** | All above | Residue list | Every entrypoint not mapped in pass 1 appears here |

Then run pass 1 again if pass 4 changed your element list. Two iterations
without change is the fixed point.

**System boundary — declare it before pass 1.** Following required counterparts
recursively expands without limit into consensus, validators, relays, governance
and external infrastructure, and that, not analyst fatigue, is what actually
stops the procedure. Declare four things up front:

1. **Scope:** the protocol-version and, if deployment-specific, the chain and
   address anchor (§12.2).
2. **Expansion policy:** how many hops of required counterparts you follow
   before an entity becomes an *attribute* rather than a node. Default: one hop.
3. **Externalization rule:** which external actors become nodes, which become
   `trust_domain` values, and which become reaction conditions. Default —
   anything you do not control and cannot substitute is a condition, not a node.
4. **Cycle rule:** an element already expanded is not expanded again; record the
   back-edge instead.

**Deciding contested boundaries.** These are the pairs where two competent
engineers disagree. Use the observable, not the vibe:

| Contested | Rule |
|---|---|
| `Sh` vs `Ix` vs `Rb` | Does the *balance* change (`Rb`), the *exchange rate* (`Ix`), or the *share count on deposit* (`Sh`)? All three may be present. |
| `Pl` vs `Im` | Is risk pooled across assets (`Pl`) or fenced per market (`Im`)? Both if a pooled protocol has isolation modes. |
| `In` vs `Rf` vs `Ba` vs `Ag` | Signed *outcome* constraint = `In`; signed *price* from a maker = `Rf`; uniform clearing over a set = `Ba`; route across venues = `Ag`. |
| `Au` vs `Up` vs `Gp` | Changes *who may act* = `Au`; changes *what code runs* = `Up`; *suppresses* transitions = `Gp`. |
| Embedded vs standalone `Fl` | Write `Fl*` if any entrypoint permits borrow-and-repay within one settlement scope, even if it is a side-feature. |
| `Bs` vs `Sl` | Is capital posted *in advance* (`Bs`) or is loss assigned *after* (`Sl`)? |

### 18.2 The financial-architecture pre-screen

**Not "the screen".** The name is deliberate: this checks *financial
architecture*, and it cannot support a launch decision or a risk acceptance on
its own. Two lanes independently found that calling it a pre-audit screen
invites exactly the standalone adoption the scope statement warns against.

**Reordered in v1.0 by expected loss, not by cheapness.** v0.1 put an
uncalibrated heuristic first and buried authority and conservation — the paths
that dominate actual loss.

**Every row is mandatory and non-short-circuiting.** v0.1 let a reflexivity hit
stop the review. That is unsafe: removing the reflexive feature then produces a
design that *appears* remediated while an independent key, mint, accounting or
cross-domain defect goes unrecorded. Run every row, record every result, and
re-run the whole screen after any redesign.

**Step −1 — frame it.** Before row 0: what assets are at stake, what are the
trust boundaries, and what is the maximum loss if every trust assumption fails
at once? Rows 0–8 are only meaningful against that number.

| # | Check | Fails against |
|---|---|---|
| **0** | **Implementation integrity.** Run §16.2 in parallel. This document does not check code. | §16.2 |
| **1** | **Authority.** Every `Au`, `Up`, `Gp`, `Fz`: scope bounded, revocation, expiry, domain separation? Signing topology and key custody enumerated? | L17, L15, L28, X9, X16 |
| **2** | **Conservation and verification.** Every fee, slippage, delay, loss and advance assigned to a named claim class or underwriter. Every `Xm` verifier proven correct, not merely present. Every element's valence (§10) satisfied. | L8, L9, L18, L19, X7, X12, X13, X19 |
| **3** | **Leverage.** Anything controlling more value than posted needs truth **and** `Ct` **and** a terminal loss path. Cross-domain, a named finality assumption too. | L1, L4 |
| **4** | **Truth manipulability.** Price the manipulation against *pool depth*, not the attacker's balance. Include `drain_regime`. | X2, X5, X10, X18 |
| **5** | **Catalyst re-pricing.** Enumerate `*` occurrences and re-price every economic and trust bond under zero-cost temporary capital and adversarial ordering. | X2, X6 |
| **6** | **Atomicity.** Place every cross-domain step on §15. Anything marketed atomic below "same transaction" must name its repair bond. | §15, L19 |
| **7** | **Disclosure and surplus.** Who observes the order before settlement, with which catalog tag, and who is the residual claimant? | L24, L29, X14 |
| **8** | **Reflexivity (non-gating).** Does any element's price or solvency input read a market its own output dominates? Triple loop present? | X1, X3, X15, X17 |

Record each as pass / fail / not-applicable with the evidence that decided it.
A failed check is a **finding**, written into the molecule as a violation list:
`Across@2026 !violates L29`.

**This screen is necessary and not sufficient**, and the gap is large. Tested
against known incidents it would plausibly flag Terra (X1/X3/X17), bZx and Cream
(truth manipulability), Beanstalk (X6) and Mango (row 4, though not literal X2).
It would **miss**: Wormhole and Nomad, which nominally had verification and
supply accounting and failed in the implementation; Euler, where every required
element was present and one new transition omitted the health check; a
compiler-codegen reentrancy class, which no row inspects; Ronin, because row 1
enumerates `Au`/`Up`/`Gp` but signer quorum and key concentration on an `Xm`
verifier set are what actually failed; and BadgerDAO's initiating cause, a
compromised front-end.

**Mandatory companion reviews before any launch or risk acceptance:**
smart-contract assurance (§16.2) · key and signer operations, including quorum
and administrative-domain independence · front-end and supply-chain security ·
deployment verification · monitoring · incident response and recovery.

Row 1 is extended accordingly: enumerate the signer set and key concentration
of **every** trust-bearing party, including `Xm` verifier sets — not only the
protocol's own `Au`/`Up`/`Gp` roles.

### 18.3 Diagnose an incident

Ask in order: (a) defective element instance · (b) invalid bond · (c)
environment outside range · (d) operational/outside · (e) counterparty/legal.

The discriminating question between (a) and (b): *would a correct implementation
of every element still have failed in this combination?* If yes it is (b), and
the table predicted it. Euler is (a). Mango is (b) — every element worked as
coded against an economically invalid truth input.

### 18.4 Find gaps

**Bounded procedure** (v0.1's "enumerate permitted combinations" is
combinatorially intractable over 48 elements):

1. Take an existing molecule.
2. Substitute **one** element with each group sibling in turn.
3. Screen each result against §13 and §14.
4. Assign one verdict from the closed set: `viable-unbuilt` ·
   `infrastructure-blocked` · `law-blocked` · `condition-blocked` ·
   `economically-unattractive` · `standards-blocked` · `forbidden`.

*(v0.1 defined five verdicts and then used two more in its own examples.)*

**Warning on authority.** Mendeleev's gap predictions worked because periodicity
constrained the properties of the missing element. Nothing here does that. This
is combinatorial enumeration with expert-assigned verdicts, and its base rate is
unmeasured: no one has checked how many previously-labelled `viable-unbuilt`
cells were subsequently built. Until that is done the verdicts are informed
opinions in a table.

### 18.5 Compare near-isomers

Write both formulas, diff them, and the remaining symbols are the real
difference.

```
CCTP v2 Standard   Au{scope=issuer-mint} + Xm{trust_domain=native-consensus} + Xf{form=burn-mint}
CCTP v2 Fast       Au{scope=issuer-mint} + Xm{trust_domain=native-consensus} + Xf{form=burn-mint} + Of
                                                                                                  ^^^^
```

The delta is exactly `Of`: an underwritten advance before finality. Everything
that follows — the issuer balance-sheet exposure, the reimbursement timeout, the
loss allocator required by L19 — follows from that one symbol.

**Scope limit.** Formula identity is an isomerism claim *only within a fixed
`obligor` and `claim_perfection` assignment*. Two instruments with identical
formulas but different obligors are not the same instrument, and v0.1's
unqualified claim that they were the same kind of system was false for anything
with off-chain backing.

---

## 19. What this is not

- **Not closed by nature.** Elements are designed, not discovered.
- **No periodic law.** Properties do not recur down a group. The name is a
  nickname; the object is an atlas.
- **No natural atomic number.** IDs are stable identifiers.
- **Not a code audit.** See §16.2 and §18.2 step 0.
- **Not an operational-security framework.** By 2025 dollars, that is where the
  losses are.
- **Not a description of a legal instrument.** A molecule describes mechanism,
  not obligation. It is not a prospectus, an offering summary or a regulatory
  description, and presenting one as characterising an instrument's legal terms
  would misrepresent by omission. For institutional use, the RWA profile
  (§8.2–8.3: `obligor`, `claim_perfection`, `record_authority`, `At`
  discriminators, `Sv`, `Fz`, L26) must be populated before a formula is
  considered complete.

---

## 20. Open register

### 20.1 Promotion gates

Each candidate in §4.1 carries its gate. Provisional gates are stated strictly
in terms of §3's criteria.

### 20.2 Demotion gates — new in v1.0

v0.1 could only grow. A core element demotes if: its R-emp evidence is shown to
rest on related teams or a single lineage; or a proposed decomposition into two
independently recurring mechanisms is demonstrated (F fails); or three unrelated
protocols show its failure signature is fully attributable to another element
(D fails).

### 20.3 Unmeasured, and owed by this document

| # | Owed | Why it matters |
|---|---|---|
| 1 | **Out-of-sample unexplained-incident share.** Pre-register the classification of the next N incidents after the v1.0 freeze, then report category rates. | The current figure is in-sample by construction: the same incidents generated the hazard rules that then explain them. Reclassifying Wormhole from "outside the table" to "an `Xm` defect" is vocabulary, not prediction. |
| 2 | **Survivor counts for every X-row.** | Without a denominator the hazard table cannot discriminate. |
| 3 | **Pre-incident catch rate**, separate from post-hoc classify rate: would §18.2, applied only to public design docs before each incident, have failed the design? | This is the only number that measures the screen. |
| 4 | **The `—n→` reduction test** (§9.1), run by the proponent. | Settles whether the fourth bond type earns its place. |
| 5 | **A computed dependency DAG** (§6). | Would make strata and laws mutually checkable. |
| 6 | **A coded RWA/fund-failure corpus** for category (e). | The current corpus is a hack corpus; the institutional loss distribution is different in kind. |
| 7 | **An incident-by-incident validation matrix**: for each known incident, would §18.2 have produced a *mandatory finding* from the public design documents beforehand? | This is the honest form of item 3 and the only defensible basis for any coverage claim. |
| 8 | **Executable thresholds for every hazard row** (§14). | Eight rows currently turn on undefined adjectives that a real design can satisfy while remaining unsecured. |
| 9 | **A machine-readable package**: JSON Schema for the molecule AST, per-element parameter registries with units and bounds, canonical serialization, validation fixtures and conformance tests. | Without it, §12's grammar is a convention, not a checkable artifact, and "ill-formed" cannot be enforced. |
| 10 | **Per-element detection specifications**: required transition signatures, required and forbidden observables, precedence rules for overlapping classifications, and a multi-label policy. | §18.1's decision rules narrow the disagreement between two analysts; they do not close it. Catalog admission and deployment detection are different problems and only the first is specified. |

Until (1)–(3) exist, **the unexplained-incident share must not be quoted as a
coverage figure.** It is in-sample.

### 20.4 Preserved dissent

1. **A fifth `—l→` legal bond.** Argued: enforceability is a relation between an
   on-chain claim and an off-chain estate — a bond's shape — and the parsimony
   argument that killed the fifth type is the argument for keeping it, since
   legal recourse is what institutional diligence actually checks.
   *"A table that publishes an RWA molecule and an `At` element has already
   opted in, and half-opting-in is the unsafe position."* v1.0 declines and uses
   discriminators instead. **Unresolved.**
2. **Whether `—n→` should exist at all.** One lens holds the naming clause
   concedes it is parasitic on the economic bond; another holds the observation
   graph is a first-class object. Retained, with the settling test now owed by
   the proponent (§20.3 item 4). **Unresolved.**
3. **The nickname.** One lens holds that keeping "periodic table" borrows
   authority the model has not earned and that the authority is spent in §18.4.
   v1.0 keeps it as a nickname only and rewrites §18.4. **Partial rejection of a
   high-severity finding, flagged as such.**
4. **Weighting.** Whether notation and worked examples are primary or cosmetic
   relative to ontology. v1.0 treats both as primary. A judgment, not a
   derivation.

---

## Appendix A — Worked example, end to end

**Subject:** a cross-chain intent bridge (Across-class). Chosen because it
exercises intents, optimistic settlement, cross-domain verification, the
informational bond and the atomicity spectrum in one object.

### Pass 1 — Elements

| Observed behaviour | Symbol | Discriminator/isotope |
|---|---|---|
| User signs a destination-outcome constraint | `In` | `market_structure=open` |
| Relayers quote and compete on speed | `Rf` | `market_structure=open` |
| Relayer advances destination funds before source finality | `Of` | — |
| An optimistic dispute game settles reimbursement | `Xm` | `trust_domain=optimistic` |
| Value moves by burn and mint | `Xf` | `form=burn-mint` |
| Relayer bond slashable on non-fill | `Bs` | `trigger=non-fill` |

`Of` is a **candidate** element — flagged, usable.

### Pass 2 — Bonds

```
In  —n→ "relayer"      [adverse_selection]     (L24 discharged)
In  —e→ "relayer"                              (L12: constraints + verifier + fallback + timeout)
Of  —e→ Bs{trigger=non-fill}                   (L19: loss allocator)
Of  —i→ Xm ; Of —i→ Xf                         (L19)
Xf  —i→ Xm                                     (L8)
Xm  —t→ "disputer set"                         (L18)
```

Law check: L12 ✓ · L18 ✓ · L19 ✓ · L24 ✓ · L8 ✓ · L9 ✓ · **L29 ✗** — no declared
surplus-allocation rule naming the residual claimant of the spread between the
user's limit and the relayer's fill.

### Pass 3 — Conditions

Cross-ecosystem atomicity (§15). Source finality horizon bounds the optimistic
window. Relayer inventory depth bounds fill size. Dispute-window gas cost bounds
who can challenge.

### Pass 4 — Residue

Relayer inventory economics; relayer concentration and its effect on quoted
spreads; the off-chain quoting path; governance of the dispute set.

### Screen (§18.2)

| # | Check | Result |
|---|---|---|
| 0 | Implementation integrity | **n/a here** — out of scope for this document; must be run separately |
| 1 | Authority | pass — no `Up` in the settlement path; dispute set enumerated |
| 2 | Conservation and verification | **fail** — X13: value in flight can exceed slashable relayer stake; verifier correctness unproven |
| 3 | Leverage | n/a — no leverage element |
| 4 | Truth manipulability | pass |
| 5 | Catalyst re-pricing | pass — no `Fl*` occurrence |
| 6 | Atomicity | pass — sits at "optimistic"; repair bond `Of+Bs` named |
| 7 | Disclosure and surplus | **fail** — L29 undischarged; relayer captures an unpriced information rent |
| 8 | Reflexivity | pass — no trust-domain cycle; bond capital is exogenous |

### Verdict

```
CrossChainIntentBridge@2026  !violates L29  !hazard X13
```

Two findings. **X13** is the material one: cap value-in-flight to slashable
stake, or add an independent exit. **L29** is a disclosure defect: the surplus
between limit and fill has no named residual claimant, which is exactly the
economic content the `—n→` edge flagged and the formula did not resolve.

### Blank template

```
<name>@<version>
  elements:   <symbol>{<key>=<value>}[*][?] ( + | || ) ...
  bonds:      <endpoint> (—i→|—e→|—t→|—n→) <endpoint> [<tag>]
  conditions: <one bound per applicable §17 row>
  residue:    <every unmapped entrypoint, or "none">
  laws:       <discharged> / <violated>
  screen:     0..8 pass|fail|n-a with evidence
  verdict:    <name>@<version> [!violates <law>] [!hazard <X>]
```

---

## Appendix B — Corpus provenance

**Stated plainly, because v1.0's predecessor did not state it at all** and every
quantitative claim is relative to it.

This atlas is a reconciliation of four prior reports, not of primary sources. It
inherits their corpora:

- **Source A:** ~70 protocols across pricing, credit, perps, staking,
  stablecoins, oracles, bridges and RWA, with ≥10 non-EVM.
- **Source B:** 101 protocol-**version** units — 72 EVM, 21 explicitly non-EVM
  (6 Solana, 7 Cosmos-family, 3 Move, 3 Cardano eUTxO, 2 Bitcoin-linked), 8
  multi-environment. Version units rather than brands, because version deltas
  are the strongest evidence of element boundaries.
- **Sources C and D:** cross-domain and chain-abstraction systems, plus a
  24-incident coded failure set.

**What is not recoverable.** The 24-incident register is referenced by all four
reports but only **12 incidents are named** in them (bZx, Black Thursday,
Harvest, Wormhole, Beanstalk, Terra, Mango, Euler, Nomad, Ronin, BadgerDAO,
Multichain). The remaining 12 are not enumerated in any source available here,
so the category counts cannot be independently audited, and the "0–4 of 24"
range in the source reports rests partly on incidents this document cannot see.
That is a real gap, stated rather than papered over.

**Dollar figures** (TRM ~$2.2B/76% infrastructure; Hacken ~$2.12B/~54%
access-control; Bybit ~$1.5B; and the per-incident figures in §14) are carried
from the source reports **unverified by this document** and were marked
unverified by more than one reviewer. Treat them as reported claims, not
findings.

---

## Appendix C — Provenance and what changed

### C.1 The four sources

| | Object | Position |
|---|---|---|
| **A** | ~46 elements, 10 groups, 4 periods by trust surface, 5-criterion test | Reflexivity as master predictor; no conservation law; residue ~1/3 |
| **B** | 48 elements, 12 groups, 5 periods by dependency depth, 7-criterion test | `Xm`/`Xf` split; reflexivity a hypothesis; supply conservation |
| **C** | CAKE unification | Splits `Xm` three ways; rejects the informational bond; 4 new provisional elements |
| **D** | CAKE unification | 55 elements; accepts the informational bond; keeps `Xm` unified; 6 new elements |

### C.2 Adjudication of the 12 contested calls

| # | Dispute | Ruling | Basis |
|---|---|---|---|
| D1 | Period axis | Dependency stratum (B), not trust surface | Trust is multivariate; a scalar forces a total order on a partial order |
| D2 | Atomicity test | B's criteria, restated per §3 | What B, P and O measure independently — not, as v0.1 argued, that they produce the exclusions already wanted |
| D3 | Constant sum | **Degenerate limit**, neither element nor isotope | An isotope must preserve the failure family; constant sum's differs |
| D4 | Informational bond | Accepted, with a closed catalog and a symmetric settling test | Observation graph ≠ incentive graph |
| D5 | Split `Xm`? | One element, mandatory discriminator, count reported both ways | S holds; the discriminator rule of §8.2 governs |
| D6 | Solver bonding `Sk` | Rejected — `Bs{trigger=non-fill}` | Fails F |
| D7 | `Of` | Candidate, not core | R-emp: 2 named instantiations |
| D8 | `Ua` | Provisional under an enforceability gate | A dashboard total fails; a reconcilable claim passes |
| D9 | `Sq` | Provisional | Ordering commitment precedes verification |
| D10 | `Dx` vs `Au` | `Au` | Restated in §3 terms; v0.1 appealed to an unpublished confidence scheme |
| D11 | Residue | Both axes, never one number; and now labelled in-sample | Count and dollars measure different things |
| D12 | The name | Atlas formally, periodic table as nickname | No periodic law, no atomic number, no closure |

### C.3 Council review

Six lenses — protocol engineer, security auditor, market-microstructure
economist, taxonomy methodologist, institutional/RWA/compliance, practitioner
usability — run blinded across three provider families, with the two
engineering lenses run twice on independent families for cross-vendor
confirmation. **Eight completed lanes; all eight returned `changes_requested`;
84 findings.** Two lanes first terminated on a provider quota limit — an
infrastructure failure, neither an abstention nor an approval — and were re-run.

Full register, per-finding dispositions and preserved dissent:
`COUNCIL-LOG.md`.

The twelve changes that most altered the object:

1. Criterion R split into R-struct (necessary) and R-emp (graded) — resolving a
   live contradiction in which `Rs` was core while its recurrence evidence was
   openly outstanding.
2. `Sd`, `Rs`, `Gs`, `Rl`, `Of` demoted from core to candidate on the evidence.
3. `Fz`, `Sv`, `Fd` added — freeze/clawback, workout discretion, and surplus
   distribution had no representation at all.
4. Conservation "laws" relabelled as accounting identities and design
   requirements, each typed analytic / normative / empirical.
5. Reflexivity split into an established mechanism class and an uncalibrated
   scored instrument, and moved out of first position in the screen.
6. Implementation-integrity overlay added; the screen reordered by expected loss.
7. Hazard table given a class column and a `base_rate` column marked unknown;
   X14 downgraded from "impossible" to "unverifiable".
8. The legal surface made explicit: `obligor`, `claim_perfection`,
   `record_authority`, `At` discriminators, L26–L28, hazard X19, category (e).
9. Notation given a grammar, an instance model, one canonical isotope syntax, a
   closed consequence catalog, and an ill-formedness rule; all worked formulas
   re-derived to conform.
10. Document reordered for a first-time reader; a complete worked example and a
    blank template added.
11. `Vl` and `Dp` added after an implementer lane found central — not
    peripheral — residue when decomposing Lido, Ethena and Pendle v2.
12. The screen renamed a *financial-architecture pre-screen*, made
    non-short-circuiting, and given mandatory companion reviews; the incidents
    it would miss are now named rather than implied.
