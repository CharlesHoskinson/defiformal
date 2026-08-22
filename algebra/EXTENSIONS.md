# Stage 4 — improving the formalism where the constructions failed

Input: the **385 residue items** emitted by `node formal/v3/residue.mjs
/root/defiformal/expansion` over 35 machine-checked constructions in 7 categories
(712 obligations, 327 discharged, 45.9% coverage; 26 PARTIAL, 9 INADMISSIBLE, 0
COMPLETE).

**Provenance of every number below.** Each of the 385 items carries one
hand-assigned group code in `stage4/classify.mjs`, keyed to the item's position in
`RESIDUE.json`; the file asserts its own length against 385 and throws on any
under- or over-run. All counts, category spreads and repair-kind totals are
printed by `node stage4/classify.mjs` and `node stage4/part2.mjs`; the tagged
corpus is `stage4/tagged.json`. Nothing here is counted by impression. Two claims
are machine-checked rather than argued: `lean/Defialgebra/Discharge.lean` (builds
against mathlib, 735 jobs, no `sorry`, axioms `propext / Classical.choice /
Quot.sound` only) and `formal/v3/mandate.qnt` (`quint test` green on
`presenceUnionClosedTest`, `magnitudeNotUnionClosedTest` and
`granularityIsTheChoiceTest`). The digraph facts cited in Part 2 were re-run: `node
formal/v2/digraph.mjs` → 15 distinct arcs, 58 trivial SCCs, acyclic.

---

## Summary

Repair kinds: **(a)** new element · **(b)** new constraint form · **(c)** new sort
in the carrier · **(d)** new level. Results at risk: **R1** clause polarity and the
dual-Horn/Horn split (`lem:polarity`) · **R2** union-closure of `ℛ` and `𝒲` and the
complete lattice (`thm:closure`, `cor:lattice`) · **R3** the convex geometry of the
definite fragment and uniqueness of minimal generators (`thm:convex`, `cor:ex`) ·
**R4** linear composition on canonical forms (`thm:excomp`) · **R5** the
compatibility graph and the perfection conjecture (`prop:clique`, `prop:trace`,
`conj:perfect`).

| rank | group — what the vocabulary cannot say | items | cats | apps | repair | cost | device |
|---|---|---|---|---|---|---|---|
| **1** | **who holds it, and how many of them** | **54** (+16, +25) | 7 | 26 | **c** party sort | R5 only, and R5's supporting measurement is already degenerate | 7 |
| **2** | **an agent may move X within these bounds** | **27** | 6 | 13 | **a** (+c prereq) | none; *moves* X16 from the Horn half to the dual-Horn half | 12 |
| **3** | **the obligation cannot arise** | **11** | 4 | 6 | **b** (+a) | R3/R4, bounded: deletes `Op→Ct`, 1 of 15 arcs; acyclicity survives | 2.67 |
| 4 | where the state transition happens, who orders it, how a user leaves | 33 | 5 | 13 | a | none structurally; costs 3–4 fitted warrant rows | 5 |
| 5 | the order in which capital is destroyed, and who can be called on afterwards | 17 | 6 | 12 | a | none structurally; same warrant cost | 6 |
| 6 | who is paid, by whom, and on what rule | 25 | 5 | 16 | c (party sort) | folds into rank 1; R5 | 5 |
| 7 | a party decides, and its decision is final | 13 | **2** | 8 | a (+c prereq) | R5; evidence is two categories only | 2 |
| 8 | one pool of value, several claims on it | 20 | 7 | 16 | c asset/domain sort | R3/R4/R5 | 3.5 |
| 9 | one protocol consumes another | 28 | 6 | 15 | **d** | R2/R3/R4/R5 — four of five | 2.4 |
| 10 | the fact lives off the ledger | 35 (16A/19B) | 5 | 12 | c ×2 | A-half → rank 1; B-half breaks R2–R5 and is unbounded | 2 |
| 11 | whether the named mechanism can be checked at all | 17 | 4 | **7** | b | R2 | 4 |
| 12 | how much | 23 | 6 | 16 | b | **R1, R2, R3, R4, R5 — all five** | 2 |
| 13 | the mechanism itself has no symbol | **82** | 7 | 26 | a | none structurally; ~82 fitted warrant rows and no new theorem | 7 |

"device" is the mechanical score of Part 3, retained so the places where I
override it are visible. Ranks 1–3 are recommended for the paper; 9, 10B, 12 and
13 are recorded as open problems or declined.

**Repair-kind distribution over the 385:**

| kind | items | share |
|---|---|---|
| (a) new element | **172** | 44.7% |
| (b) new constraint form | **51** | 13.2% |
| (c) new sort in the carrier | **134** | 34.8% |
| (d) new level | **28** | 7.3% |

**The single load-bearing recount.** Group the items by the *sort they presuppose*
rather than by the kind of edit: 54 (holder) + 25 (payee) + 16 (the custodial half
of the off-ledger group) = **95 items are directly about a party**, and a further
40 — the mandate's named agent and the adjudicator's determining party — cannot be
stated without one. **135 of 385 residue items, 35.1%, turn on a party sort.** No
other single addition reaches half of that.

---

# Part 1 — the residue, grouped

Thirteen groups. Counts are `node stage4/classify.mjs`; category codes are the lane
prefixes (04 liquid staking, 05 perpetuals, 06 yield vaults, 07 bridges, 08
intents, 10 options, 12 prediction).

### 1. "who holds it, and how many of them" — 54 items · 7 categories · 26 applications · repair (c)

`07:22 08:10 04:8 05:4 06:4 12:4 10:2`. The control elements `Tg`, `Up`, `Gp`,
`Au` are unary predicates on a protocol naming a *facility*. Every item here says
the risk is a property of the *holder*: an externally-owned account, an n-of-m,
a foreign DAO, an off-chain committee, a role partition, a party standing on two
sides at once.

> [07-bridges] LayerZero V2: The Endpoint's code cannot be replaced -- 24,005 bytes of direct non-proxy bytecode, documented as immutable and permissionless -- and it is nevertheless owned: owner() = 0xbe010a7e3686fdf65e93344ab664d065a0b02478, a custom multisig with threshold() = 3 and nonce() = 611, carrying no secondsTimeLocked and no getMinDelay.

> [07-bridges] Coinbase Bridge (cbBTC and other wrapped assets): The custodian of the underlying is also the largest venue on which the underlying trades, so the party whose failure would break the peg is the same party whose order book would price the break.

> [12-prediction] Steakhouse Financial (Risk Curators): authority is split four ways — an appointer, a strategy-setter who sets caps and fees, bounded executors who may only move funds within the strategy-setter's limits, and sentinels who may only reduce.

**Repair (c).** A party sort. No set of mechanism symbols will name it: `Up` is
present in all three protocols above and distinguishes none of them.

### 2. "an agent may move X within these bounds" — 27 items · 6 categories · 13 applications · repair (a), presupposing (c)

`06:15 12:5 04:3 10:2 07:1 08:1`. Stage 1 found the five-part schema in two
categories (06 yield, 03 CDP). The stage-3 residue puts it in six more
applications across four further categories, always bounding a different quantity:
a savings rate, a leverage target, an exchange rate, a mint allowance, a credit
limit, a per-slice slippage, an implied-volatility scalar, a magnitude of
restaked stake, a supply cap and queue order.

> [06-yield-vaults] Spark Savings (sUSDS / Sky Savings Rate): a single update may move the rate by at most a governance-set step, live four percentage points, and no update may occur within a cooldown of the previous one, live sixteen hours; the update then takes effect immediately.

> [04-liquid-staking] EigenCloud (EigenLayer): [Vl sub-mechanism 2 of 5: stake allocation and scheduling] An operator allocates a magnitude, a proportion of its delegated stake in a given strategy, to a named operator set; allocations are held per (operator, strategy, operator set) with a current magnitude, a pending diff and an effect block, and deallocations are processed through a per-(operator, strategy) queue in order.

> [06-yield-vaults] CIAN Yield Layer: that agent supplies the leverage amount, the swap route, the slippage floor and the flash-loan source as call arguments; nothing in the contracts computes them, schedules a rebalance, defines when a target has been missed, or compels the agent to act at all.

**A result inside the group.** Counting envelope parts across the 27 (regex pass in
`stage4/part2.mjs`, criteria printed there): 15 name a cap, 9 a domain, 7 a
rate-of-change limit or delay, **6 name no envelope part at all** — an agent with
unbounded discretion — and **0 name revocation**. Revocation appears four times in
the whole residue and never inside a mandate item: it sits in the *party* group
(Hyperliquid Bridge's lockers, Grove's cancelling security multisig, Steakhouse's
depositor-guardians). **The fifth part of the schema is held by a different party
from the first four.** That is why this repair cannot be completed without the
party sort, and it is a finding stage 1 could not have had.

**Repair (a)**, with (c) as prerequisite. The mechanism deserves a symbol; the
agent and the revoker do not fit inside one.

### 3. "the obligation cannot arise" — 11 items · 4 categories · 6 applications · repair (b), plus one (a)

`10:5 04:4 07:1 08:1`. Stage 1 saw it in options; stage 3 corroborated it in
liquid staking; the full residue puts it in bridges and intents too.

> [10-options] Rysk V12: DISCHARGED BY CONSTRUCTION: there is no insurance fund, no backstop, no socialised loss and no auto-deleveraging, because the protocol has no loss channel for them to absorb.

> [04-liquid-staking] EigenCloud (EigenLayer): [Vl sub-mechanism 3 of 5: deposit front-running defence] There is none, and none is needed: the pod is deployed at an address deterministic in the staker's own address, and the same party that supplies the 32 ETH also owns the withdrawal credentials it is deposited against, so the adversary Lido's DepositSecurityModule exists to defeat [...] has no counterpart here.

> [07-bridges] Hyperliquid Bridge: No reserve attestation exists or is needed: the escrow is a contract balance that anyone can read directly, and the issuer publishes nothing about it.

**Repair (b).** `Definition (Requirements)` admits one discharge: `T_j ∩ X ≠ ∅`.
It needs a second — a term may carry voiding witnesses `V_j`, and the row is
satisfied when `(T_j ∪ V_j) ∩ X ≠ ∅`. One (a) is needed alongside: an atom for the
voiding construction itself (full-payoff escrow at inception, self-custodial
deposit, on-chain-readable reserve). Formalised and machine-checked in Part 2.

### 4. "where the state transition happens, who orders it, and how a user leaves" — 33 · 5 cats · 13 apps · repair (a)

`05:25 08:4 07:2 04:1 10:1`. Every one of perpetuals' trust-model obligations, plus
the intents lane's transaction-propagation layer. The vocabulary demoted `Zk`
(verifiable state proof) and `Sq` (shared ordering commitment) to the contested
register and has nothing for data availability, execution locus or forced exit.

> [05-perpetuals] Hyperliquid: a trader has no unilateral exit: there is no forced-inclusion transaction, no censorship deadline and no escape hatch, so leaving the venue requires the validator set to sign.

> [05-perpetuals] edgeX: V1 is a validium: proof construction relies fully on data that is not published on chain, held by a data-availability committee with a threshold of 2 of 6 whose members are not publicly known and who have no on-chain assets at risk of being slashed in a data-withholding attack; V2's data-availability regime is not stated.

> [08-intents] LiquidMesh: the signed transaction may be handed back to the operator for broadcast through private channels rather than the public mempool, at one of two privacy grades on EVM (public, private) or three on Solana (off, reduced, secure).

**Repair (a).** Three or four elements: execution locus and ordering authority;
state-validity proof; data-availability sufficiency; forced-exit right.

### 5. "the order in which capital is destroyed, and who can be called on afterwards" — 17 · 6 cats · 12 apps · repair (a)

`10:5 12:4 04:3 05:3 06:1 07:1`. `Li`, `Ad`, `Sl`, `Bs`, `Tr`, `Cv` name
loss-absorbers but no *order* over them, and nothing for capital that is not
prefunded.

> [12-prediction] Kalshi: when the fund is exhausted the clearing house may call assessments on every surviving member, pro rata to their deposit requirement over the preceding three months, capped at 200% for one default and 550% for multiple defaults in six months, and refundable pro rata out of later recoveries.

> [10-options] Aevo (Ribbon Finance lineage): The three loss-absorption venues escalate in a fixed order — book workout, then insurance fund, then auto-deleveraging — and each transfers the position on a different price basis: limit orders, then a markup, then mark price.

> [07-bridges] Hyperliquid Bridge: Validator stake is not slashable: the documentation states that there is currently no automatic slashing implemented, so the only consequences for a validator are jailing by peer vote and the seven-day queue, and no path exists from a bridge failure to a loss of stake.

**Repair (a).** One element for callable (post-loss, uncommitted) capital, and one
element for owner-funded first loss that is neither staked nor mutualised — `Bs`
is wrong for both, as the options lane already found for Derive.

### 6. "who is paid, by whom, and on what rule" — 25 · 5 cats · 16 apps · repair (c)

`08:14 06:4 12:3 04:2 05:2`. `Fd` and `Em` name that value moves; every item here
turns on *which named party receives it* and *who sets the lever*.

> [08-intents] KyberSwap: the operator's commercial asset is the venue rather than the user: it charges its users nothing, buys exclusivity over pools it did not build, pays the liquidity providers 70 percent of the arbitrage that exclusivity captures, and takes its own revenue from surplus at settlement.

> [12-prediction] Steakhouse Financial (Risk Curators): the fee is paid by minting new vault shares to the fee recipients, so it is borne as dilution of every other holder rather than as a transfer of assets.

> [06-yield-vaults] Convex Finance: half a per cent of that revenue is paid to whichever anonymous address calls the harvest function.

**Repair (c).** The same party sort as group 1, carrying a value-flow relation.
This group is the reason the party sort is not merely a control-plane fix.

### 7. "a party decides, and its decision is final" — 13 · **2 categories** · 8 apps · repair (a), presupposing (c)

`12:8 08:5`. `Sv` (servicing & determination discretion) exists as a candidate and
is doing none of this work.

> [12-prediction] Kalshi: the outcome of a contract is determined by an internal committee of the exchange with full discretion, within 24 hours, and its determination is final and not subject to review.

> [08-intents] OKX DEX: the system, not the user, decides which of two incompatible execution regimes runs, on trade size, token classification and a user-chosen speed mode, and which party bears price risk between signature and fill changes with that decision.

**Repair (a)** — promote and split `Sv` — but the evidence is **two categories**,
and that is the whole reason it ranks where it does.

### 8. "one pool of value, several claims on it" — 20 · 7 cats · 16 apps · repair (c)

`07:9 04:3 05:3 08:2 06:1 10:1 12:1`. The carrier is `2^E`; there is no asset or
domain index, so a protocol that backs two claims with one balance is
indistinguishable from one that backs one.

> [07-bridges] Hyperliquid Bridge: Two supplies of the same asset coexist on the destination chain with different trust models and are fungible to the user: $421.9m that came through this escrow and $5.48b issued natively on Hyperliquid via CCTP.

> [04-liquid-staking] ether.fi (eETH / weETH): [Whether the same collateral can be committed twice] Yes: the same principal is committed to Ethereum consensus and to EigenLayer operator sets at once. [...] across venues nothing in ether.fi bounds or discloses the aggregate exposure.

> [10-options] Panoptic V2: The protocol lends against, and prices with, the same Uniswap pool its instruments are written on [...]

**Repair (c).** This is the paper's own `(element, asset)` sort (`prop:dag`'s
corollary), exhibited on 16 applications rather than on Terra and crvUSD.

### 9. "one protocol consumes another" — 28 · 6 cats · 15 apps · repair (d)

`06:7 08:7 07:6 05:3 12:3 10:2`. Composition is union between peers. Every item
here is a *directed* relation: routing to routers, curating over markets,
governing a foreign protocol, licensing the right to deploy inside oneself,
setting the security parameter of the layer below.

> [07-bridges] LayerZero V2: Verification security is a per-application parameter rather than a protocol property: two applications on the same endpoint pair can run entirely different verifier sets and thresholds, and one of them may be a single company.

> [08-intents] Jupiter: the router owns venues on the other side of its own routing: a perpetuals exchange, a lending market with flash loans, a liquid-staking token, a launchpad with bonding curves, a prediction market and a validator, so it can internalise the flow it receives.

> [06-yield-vaults] Convex Finance: the protocol acquires and exercises governance rights inside four foreign protocols that it does not control.

**Repair (d).** A level over protocols.

### 10. "the fact lives off the ledger" — 35 · 5 cats · 12 apps · repair (c), twice

`07:13 12:10 04:6 08:4 06:2`. Hand-split in `stage4/part2.mjs` into **16 (A)** —
dependence on a *named off-chain party* whose act the chain consumes — and **19
(B)** — a legal instrument, register of record, jurisdiction or contract term.

> (A) [07-bridges] WBTC: Nothing on Ethereum verifies that the Bitcoin deposit occurred: Factory.confirmMintRequest() is gated by onlyCustodian, resolving through Controller.isCustodian() to the single address 0xb0f42d187145911c2ad1755831aded125619bd27, and the custodian's confirmation transaction is itself the bridge.

> (B) [12-prediction] Grove Finance (Onchain Capital Allocator): the economically decisive transfer is not between chains but from a chain into a fund administrator's register of record, where the subscription becomes an entry in a Cayman or Luxembourg vehicle's books.

> (B) [12-prediction] Kalshi: customer funds are held in United States dollars only, segregated by account class under CFTC Reg. 1.20 or Part 22 with the clearing house holding a continuing first-priority security interest and UCC control over them, investable only in US Treasuries [...]

**Repair (c) for A** — the same party sort, with a custodian/obligor/attester role.
**Repair (c) for B** — a legal-instrument sort, and I argue in Part 3 against
adding it.

### 11. "whether the named mechanism can be checked at all" — 17 · 4 cats · **7 applications** · repair (b)

`08:12 07:2 10:2 05:1`. The carrier records that an element is present. It cannot
record how that is known — from source, from bytecode, from a claim.

> [08-intents] OKX DEX: the splitting algorithm, the private-market-maker set, the solver allowlist and the auction's conduct are all unverifiable from outside, and the canonical settlement repository the operator once published has been withdrawn.

> [07-bridges] Coinbase Bridge (cbBTC and other wrapped assets): Third parties treat the issuer's own reserve JSON as ground truth for the protocol's size: DefiLlama's adapter calls getConfig('coinbase-cbbtc-proof-of-reserves', ...) and sums the declared addresses.

**Repair (b).** An epistemic index on element presence. Note the spread: 12 of 17
in one lane and 7 applications total — the narrowest evidence base of any group
except the adjudication one.

### 12. "how much" — 23 · 6 cats · 16 apps · repair (b)

`04:6 10:6 06:5 05:3 07:2 12:1`. Caps, haircuts, tiers, ratios, thresholds,
schedules. The carrier has no numbers anywhere.

> [05-perpetuals] Aster: Shield Mode liquidation triggers on last price against a liquidation price derived from margin, leverage, entry, funding and a liquidation loss rate that varies by pair and leverage band (BTC/ETH 75% at 1-200x, 70% at 201-500x, 65% at 501-1001x) [...]

> [06-yield-vaults] Huma Finance V2: the senior claim may not exceed four times the junior claim, enforced on deposit and again in the ordering of redemptions.

**Repair (b).** Parametric side-conditions. Priced in Part 2 and declined in Part 3.

### 13. "the mechanism itself has no symbol" — 82 · 7 cats · 26 apps · repair (a)

`10:25 12:16 04:12 06:12 08:12 05:3 07:2`. The long tail: 82 distinct mechanisms,
each named by one or two protocols. Pendle's logit curve in implied-rate space;
Panoptic's strike-less streamia; Polymarket's partition/merge primitive; Azuro's
segment-tree liquidity; Convex's permanent escrow; Lido's three exit doors.

> [12-prediction] Polymarket: for a family of binary markets of which exactly one resolves true, a holder may exchange a bundle of NO positions for collateral plus the residual YES, financed before resolution out of a wrapped-collateral buffer the adapter holds itself; if the family's mutual-exclusivity constraint is violated the family cannot fully resolve and funds are frozen.

> [06-yield-vaults] Pendle: the principal claim is priced against the wrapper by a pool whose invariant is a logit curve in implied-rate space, whose stiffness parameter grows without bound and whose intercept decays as time-to-expiry shrinks, so identical pool state prices differently on a different day.

> [05-perpetuals] Aster: a hidden order reveals neither size nor presence to the public book while sharing the book's liquidity [...]

**Repair (a)**, eighty-two times over. Declined in Part 3, with reasons.

---

# Part 2 — what each repair costs the algebra

Two general costs first, because they apply to every proposal and are easy to
hide.

**The warrant tax on every (a).** `𝒲` is not independent data: it is fitted. The
paper's own `meas:tradeoff` shows the alternative — taking `C` to be the true
residual of `R` — rejects 82% of deployed protocols and is anti-correlated with
reality, and `sec:tradeoff` concludes the warrant relation is *under-determined*.
So each new element costs one warrant row that nothing in the vocabulary
adjudicates, and invalidates the F1 ablation until it is re-run. **172 items call
for (a); their honest joint price is 172 fitted parameters.** This is the reason
the largest group is the one I decline.

**The (b)/(c) escape from vacuity.** `meas:ablation58` reports that the 79 positive
clauses exclude *zero* elements across all 72 seeds, and `meas:clutter` reports
that 1 of 20 prohibition rows is enforceable by membership. Any repair that makes
an unenforceable row enforceable buys content — and pays for it in R5, because
`prop:trace`'s "9 distinct traces, perfection holds trivially" rests on there
being exactly one enforceable row.

### Group 1 + 6 + 10A — the party sort (95 items). Cost: R5, and only R5.

- **R1 survives, provably, on one condition.** Party facts must enter as *positive
  existential atoms* — "some authority in this protocol is a single key", "an
  attester is named" — not as exact descriptions. A requirement over the enlarged
  signature is still `¬s ∨ ⋁ e`: one negative literal, dual-Horn
  (`Polarity.dualHorn_reqClause`, already machine-checked). If instead the sort
  records *exactly* which holder shape is present, the mutual-exclusion clauses
  `¬quorum ∨ ¬singleKey` are purely negative, and `Polarity.pureNeg_not_union_closed`
  applies verbatim: union-closure dies. **The encoding is the whole cost, and it is
  a choice, not a consequence.**
- **R2 survives** under the existential encoding, by the same lemma. `⊕ = ∪`
  remains the right reading: if `A` has a single-key authority and `B` does not,
  the composite does, which is what the union of the atoms says.
- **R3/R4 are free** provided the new atoms appear only as *heads*. `D` currently
  has 15 arcs with sources `{Pl,Im,Cd,Uc,Pf,Op,Py,Gs,Rl,Of}` and targets
  `{Ct,Li,Ex,At,Ep,Au,Xm,Xf,Rd,Aw}`, disjoint, depth 1 (re-run above). Arcs of the
  form `Up → held-by-quorum` add targets only, so sources and targets stay
  disjoint, `D` stays acyclic, and `thm:convex`/`cor:ex`/`thm:excomp` hold
  unchanged. **This is a linear-time regression test, `node formal/v2/digraph.mjs`,
  not a proof obligation.**
- **R5 is damaged, and this is the real price.** `X9` — "`Up` with immediate
  single-key control" — is one of the nine rows that currently name no element. A
  party atom makes it a genuine purely-negative prohibition `{Up, singleKey}`,
  taking the enforceable clutter from 1 row to 2. The trace space of `prop:trace`
  grows, and the measurement "the quotient on those traces is complete, so on this
  sample perfection holds trivially" is destroyed. `conj:perfect` becomes a real
  conjecture instead of a vacuous one.

This is a repair whose only cost is to invalidate a measurement the paper itself
describes as trivial. That is not damage so much as the removal of a false
comfort — but it must be stated as damage, because a published measurement stops
being true.

### Group 2 — the bounded mandate (27 items). Cost: none. And it *improves* the polarity split.

Machine-checked in `formal/v3/mandate.qnt` by `quint test` -- three named
tests, 34.5 s. Typecheck is not the evidence and is not quoted as such: it is a
type check, and it passed on `usd1.qnt` while a self-transfer minted tokens
(`quint-models-v2/VERIFICATION.md`).

```
  mandate
    ok presenceUnionClosedTest       ok magnitudeNotUnionClosedTest
    ok granularityIsTheChoiceTest
```

- `presenceUnionClosedTest` verifies **exhaustively over the 2^12 subsets** of a
  12-atom universe that the mandate row `Md → agent + domain + cap + rate + revoke`
  is union-closed, and that the empty protocol satisfies it. R1 and R2 are
  untouched: it is one more dual-Horn row of exactly the shape `L3` already has.
- **The prohibition table gets smaller.** `X16` — "unbounded delegated authority,
  or unlimited token approvals" — is currently an unenforceable Horn row. Written
  against a mandate element it is `¬Md ∨ cap ∨ step ∨ …`: a **dual-Horn
  requirement written negatively**, precisely the case `meas:clutter` already
  notes ("several are requirements written in negative form"). So this repair does
  not add a Horn row; it *moves* one out of the Horn half, where `meas:whereitfails`
  attributes 100% of composition failures, into the dual-Horn half, where nothing
  fails. **A repair that strictly reduces the union-destroying part of the theory
  is the rarest thing in this document.**
- R3/R4 free by the head-only argument above. R5 untouched: no new enforceable
  prohibition.
- `magnitudeNotUnionClosedTest` prices the alternative and is why the repair must
  be taken at *presence* granularity: two mandates each at 30% of the whole are
  each inside a 50% cap and their composite is not, exhibited on four values. The
  finding survives at presence granularity because the discriminating fact in the
  residue is which of the five parts exists (15 cap / 9 domain / 7 rate / 6 none /
  0 revocation), not what the numbers are.

### Group 3 — discharge by construction (11 items). Cost: R3/R4, bounded to one arc.

Machine-checked in `lean/Defialgebra/Discharge.lean`, built against mathlib
(735 jobs, `EXIT=0`), no `sorry`, every declaration depending only on `propext`,
`Classical.choice`, `Quot.sound`.

```lean
def voidReq (s : E) (T V : Finset E) : Clause E := reqClause s (T ∪ V)

theorem dualHorn_voidReq  : DualHorn (voidReq s T V)               -- R1 survives
theorem voidReq_union_closed : Models X S → Models Y S → Models (X ∪ Y) S
                                                                    -- R2 survives
theorem sat_voidReq_of_sat  : Sat X (reqClause s T) → Sat X (voidReq s T V)
theorem sat_voidReq_of_void : v ∈ V → v ∈ X → Sat X (voidReq s T V)
theorem voidReq_strictly_larger : ∃ s T V X, ¬ Sat X (reqClause s T) ∧ Sat X (voidReq s T V)
theorem voidReq_not_definite : t ∈ T → v ∈ V → t ≠ v → ¬ Definite (voidReq s T V)
```

- **R1 and R2 are free, proved not measured.** Widening the head does not touch the
  negative literal, so the row is still dual-Horn and the model class is still
  union-closed. `cor:lattice` survives verbatim.
- **The model class only grows** (`sat_voidReq_of_sat`): no protocol that was
  admissible becomes inadmissible. The repair cannot break any published
  admissibility verdict in the positive direction.
- **The repair is not vacuous** (`voidReq_strictly_larger`): there is an explicit
  `Fin 3` witness with the subject present, no satisfying mechanism, and the
  obligation closed anyway — the Rysk/Hegic shape.
- **R3/R4 pay, and the payment is countable.** `voidReq_not_definite` says a
  widened singleton head is no longer a singleton, so the row leaves the definite
  fragment and its arc leaves `D`. On the stage-3 evidence exactly one of the 15
  arcs is voided: **`Op→Ct`** — an options writer that escrows maximum payoff at
  inception cannot fail a threshold test. `D` goes 15 arcs → 14; `Ct`'s in-degree
  goes 5 → 4. Acyclicity is *not* at risk, because widening only ever deletes arcs
  and deleting arcs from an acyclic digraph leaves it acyclic — so `cor:ourconvex`
  (convex geometry on all `2^58`) and `thm:excomp` both stand, on a fragment one
  arc thinner. The paper already records that fragment as thin
  (`Remark [Honest scale]`); this makes it marginally thinner and, in exchange,
  corrects the two INADMISSIBLE verdicts that stage 3 established survive a
  corrected decomposition — Rysk and Hegic, 5 of this group's 11 items — and with
  them the options rejection rate, which stage 3 called "a true statement about
  the tables and a false one about the protocols".
- R5 untouched: no new prohibition, no new trace.

### Group 4 and 5 — trust model (33) and loss ordering (17). Cost: warrant tax only.

Every theorem in the paper is stated for an arbitrary finite `El`. Adding four
elements for execution locus / validity proof / data availability / forced exit,
and two for callable capital and owner-funded first loss, changes `|El|` from 58
to 64 and no theorem's proof. R1–R5 all survive. The price is six fitted warrant
rows and a re-run of the F1 ablation, whose 10.83× is calibrated on the 58-element
table. Recommendation: worth doing, but as vocabulary maintenance rather than as a
formalism improvement — it changes coverage, not structure.

### Group 7 — adjudication (13). Cost: R5. Evidence: two categories.

Splitting `Sv` and giving it a law naming the determining party, the window and
the appeal path is the same shape as the mandate repair, and rides on the same
party sort. It would make `X14` ("exclusive market structure plus a
price-improvement claim with no named benchmark") enforceable, which costs R5's
trace measurement a second time. Two categories out of seven is not convergence.

### Group 8 — the asset/domain sort (20). Cost: R3, R4, R5.

The paper already conjectures this (`conj:fibre`) and F5 exhibits it on Terra and
crvUSD. The cost of *promoting* it from a conjecture to the carrier:

- R1/R2 survive — clauses over `El × 𝒜` still have one negative literal.
- **R3/R4 do not survive as stated.** `Cn` is reachability in a digraph on `El`;
  `ex(A) = max_⪯(A)` and `ex(A ⊕ B) = max(ex A ∪ ex B)` are theorems about
  antichains of a *finite poset on 58 points*. Over `El × 𝒜` with `𝒜` unbounded the
  poset is no longer finite, `max_⪯` need not exist, and `thm:excomp`'s linear-time
  claim is false. It can be recovered by fixing `𝒜` finite per protocol, but then
  the canonical form is not protocol-intrinsic — which is exactly what `cor:ex` was
  for ("defined on the protocol itself rather than on any particular presentation
  of it").
- **R5 does not survive as stated.** `prop:trace` derives the blow-up structure
  from `ℛ ∩ 𝒲` being union-closed *on `2^El`*; over a two-sorted carrier the trace
  space is the prohibition traces on pairs, and the blow-up argument has to be
  redone.

### Group 9 — the level above (28). Cost: R2, R3, R4, R5 — four of five.

This is the most expensive proposal in the document and the cost is structural,
not incidental.

- **R2.** The carrier stops being `2^El`. A protocol becomes a term over protocols,
  and the model class is no longer a family of subsets of a fixed finite set.
  `thm:closure` and `cor:lattice` are not weakened; they are undefined.
- **R3/R4.** `thm:excomp` is proved *from* additivity of `Cn`, which is proved from
  `A ⊕ B = Cn(A ∪ B) = A ∪ B`. Containment is directed: "Jupiter routes to
  KyberSwap" is not "KyberSwap routes to Jupiter". Non-commutative and
  non-idempotent, so `compositionIsMonoidTest` fails and additivity goes with it.
- **R5.** `G_⊕` is defined as a *simple graph* and `⊕`-safety as a *clique*.
  A directed consumption relation makes it a digraph; "clique" and "perfect graph"
  do not apply, and `conj:perfect` is not open but ill-posed.

The evidence is strong (6 categories, 15 applications, both stage-1 lanes
corroborated) and the capital is the largest in the corpus. It is still the wrong
repair for *this* paper: it replaces the object the paper is about.

### Group 10B — the legal-instrument sort (19). Cost: R2–R5, and unbounded.

Every quantitative method in the paper depends on `|El|` being finite and small:
the 93-clause CNF and complete DPLL, the `2^20` exhaustive runs, the `5,038,954`
subset enumeration, the trace quotient. A sort ranging over registers of record,
jurisdictions, security interests and arbitration clauses has no finite
enumeration, so admissibility stops being decidable by the methods that produce
every measurement in the document. There is no encoding that avoids this, because
the content of these items *is* their open-endedness.

### Group 11 — the epistemic index (17). Cost: R2.

An index `present / attested / claimed` on element membership is not a set of
elements, so the model class stops being a subfamily of `2^El` and union-closure
has to be re-proved on a lattice of index-valued vectors. It probably survives
(the index is a chain and clauses stay one-negative), but it is unproved and the
evidence is 7 applications.

### Group 12 — magnitudes (23). Cost: all five results.

- **R1 fails.** A cap is not a clause. `alloc ≤ 5000` has no polarity, so the
  Horn/dual-Horn classification — the single fact from which R2 is proved — does
  not apply to it.
- **R2 fails**, exhibited: `magnitudeNotUnionClosedTest` in `formal/v3/mandate.qnt`
  shows two protocols each satisfying a cap whose composite does not, for four
  distinct values.
- **R3/R4 fail.** `Cn` is reachability on a finite vertex set; a numeric side
  condition is not an arc, and the closed sets are no longer the down-sets of a
  finite poset, so `cor:ex`'s unique minimal generator has no referent.
- **R5 fails.** `prop:trace` requires the compatibility relation to be determined
  by finitely many prohibition traces. Numeric thresholds give infinitely many, and
  `G_⊕` is no longer a blow-up of a finite quotient, which is the entire route by
  which `conj:perfect` was to be decided.

**Five for five. This is the most expensive repair per item in the residue.**

### Group 13 — the long tail (82). Cost: none structurally, 82 fitted warrant rows.

R1–R5 all survive: the theorems are stated for arbitrary finite `El`. The cost is
entirely the warrant tax, and at 82 rows it is the dominant term. It also buys no
theorem: coverage rises and structure does not move.

---

# Part 3 — rank, and what the paper should do

**Method.** Evidence strength is measured, not asserted: for each group,
`stage4/part2.mjs` prints the number of distinct categories (max 7) and
applications (max 35) it draws on, and a convergence flag — 1 where the group's
items describe *the same relation* seen independently, 0 where they are a family
of distinct gaps. The device is `score = (categories × convergence-flag×2 or ×1) /
(1 + number of the five named results damaged)`. Capital affected is **not
computed in this run**: the only capital figures on record are stage 1's DefiLlama
$16.55bn for the delegated-allocation category and stage 3's finding that intents
(26.5%) and bridges (31.5%) have the thinnest coverage and hold the most capital
per element. Capital therefore enters as an ordinal judgement and is labelled as
one.

The device's output, verbatim:

```
rk group     n  cats apps rep conv dmg  score  damaged
 1 MANDATE   27    6   13   a    1   0     12  -
 2 INSTR     82    7   26   a    0   0      7  -
 3 PARTY     54    7   26   c    1   1      7  R5
 4 LOSS      17    6   12   a    0   0      6  -
 5 TRUST     33    5   13   a    0   0      5  -
 6 FLOW      25    5   16   c    1   1      5  R5
 7 OPAQUE    17    4    7   b    1   1      4  R2
 8 DOMAIN    20    7   16   c    1   3    3.5  R3/R4/R5
 9 CONSTR    11    4    6   b    1   2   2.67  R3/R4
10 LEVEL     28    6   15   d    1   4    2.4  R2/R3/R4/R5
11 LEGAL     35    5   12   c    1   4      2  R2/R3/R4/R5
12 QUANT     23    6   16   b    1   5      2  R1/R2/R3/R4/R5
13 ADJUD     13    2    8   a    1   1      2  R5
```

**Three places the device is wrong, and why.**

1. **INSTR at rank 2 is the artefact the task warned about.** Seven categories and
   26 applications is the widest spread in the residue, and it is not convergence:
   it is 82 *different* mechanisms each seen once or twice. Breadth of unlike gaps
   measures incompleteness, not agreement. The device counts categories; it cannot
   see that Pendle's logit curve and Polymarket's partition primitive are not the
   same finding. Overridden to last.
2. **CONSTR at rank 9 over-weights its damage.** The device scores "damages R3/R4"
   as a binary. The Lean file makes the damage countable: one arc of fifteen, with
   acyclicity provably preserved. Promoted to 3.
3. **PARTY at rank 3 under-weights capital.** It is the only group drawing on all
   seven categories *with* convergence, it holds 22 of the 61 bridge items, and
   with its two dependents (payee, custodial) it accounts for 95 items directly and
   135 including the repairs that presuppose it. Promoted to 1.

### Recommended: the three repairs the paper should make

**1. The party sort (groups 1, 6, 10A — 95 items, 7 categories, 26 of 35
applications).** The widest-evidenced convergence in the run, on the categories
holding the most capital, and its only cost is one measurement the paper itself
calls trivial. Two conditions must be stated in the paper: party facts enter as
*positive existential* atoms (else `pureNeg_not_union_closed` kills R2), and the
new atoms appear only as heads of definite rules (else `digraph.mjs` must be
re-run to confirm acyclicity). It converts `conj:fibre` from a conjecture into a
construction, and it makes `X9` the second enforceable prohibition row in a table
that currently has one.

**2. The bounded delegate mandate (group 2 — 27 items, 6 categories, 13
applications).** Stage 1 called it the most-confirmed gap in the project on two
categories; stage 3 puts it in six. It is free — `presenceUnionClosedTest` verifies
union-closure exhaustively over `2^12`, and the row is the same dual-Horn shape as
`L3`. Better than free: it reclassifies `X16` from an unenforceable Horn row into a
dual-Horn requirement, *reducing* the half of the theory that
`meas:whereitfails` blames for 100% of composition failures. Take it at presence
granularity only: `magnitudeNotUnionClosedTest` exhibits the counterexample that
puts the magnitudes out of reach, and the residue shows the discriminating fact is
which parts exist (15 cap, 9 domain, 7 rate, 6 with no bound at all, **0 with
revocation**) rather than what the numbers are. Its fifth part lives in the party
sort, so recommendations 1 and 2 should ship together.

**3. Discharge by construction (group 3 — 11 items, 4 categories, 6
applications).** The smallest group of the three and the one with the sharpest
argument. It is a change to the *constraint language*, not the vocabulary: widen a
term's head with voiding witnesses. R1 and R2 survive with machine-checked proofs;
the model class only grows, so no published admissibility verdict flips the wrong
way; the cost is exactly one arc, `Op→Ct`, out of fifteen, with acyclicity
provably intact. In exchange it corrects a published claim that stage 3 has
already shown to be false about the protocols: the two options venues whose
rejection survives a corrected decomposition, Rysk and Hegic, discharge their
threshold, liquidator and backstop terms by construction and are read as
unspecified only because the language has no way to say so.

### Recorded as open problems, not repairs

**The level above (group 9, 28 items, 6 categories).** State it as the paper's
fifth open problem, in the form the residue supports: *what is the right carrier
for a directed consumption relation between protocols, and does anything survive
of `⊕` when it is non-commutative?* It destroys four of five results and replaces
the object of study. It is a second paper, and the evidence assembled here — 15
applications, both stage-1 lanes plus four more categories — is the argument for
writing it, not for bolting it on.

**Magnitudes (group 12, 23 items).** Declined outright and recorded as the
sharpest instance of the paper's own thesis that structure and content trade
against each other: it is the only repair in the residue that costs all five
results, and the counterexample is already in `formal/v3/mandate.qnt`. The right
form of the open problem is narrower — *is there a finite abstraction of the
magnitude conditions (present/absent, binding/slack) that is union-closed?* — and
the mandate repair is the first instance of an affirmative answer.

**The off-ledger half (group 10B, 19 items).** Not an open problem and not a
repair: it is the residue reported as a result, per invariant 3. A sort ranging
over registers of record and jurisdictions has no finite enumeration and every
measurement in the paper depends on one. The paper should say so explicitly rather
than leaving 19 items looking like future work.

**The epistemic index (group 11, 17 items) and adjudication (group 7, 13 items)**
are open problems on evidence grounds alone: 7 and 8 applications respectively,
and adjudication draws on only two categories.

### The group deliberately not repaired

**"The mechanism itself has no symbol" — 82 items, 21.3% of the residue, 7
categories, 26 of 35 applications: the largest and most widely spread group in the
run, and it should not be repaired.** Adding 82 elements takes `|El|` from 58 to
140, more than doubles a warrant table the paper has already shown to be
under-determined (`sec:tradeoff`: the only principled alternative rejects 82% of
deployed protocols), invalidates the F1 ablation, and proves no new theorem —
every result is already stated for arbitrary finite `El`. What it would move is
coverage, and coverage is not the paper's result. The deeper reason is the one the
device could not see: a gap seen in seven categories is strong evidence only when
it is *the same gap*. Here it is 82 different ones, and the correct conclusion is
the one the paper already draws and measures — the vocabulary is category-thin
where the finance is hardest — not 82 new symbols.

---

## Closing

The paper should make three repairs and leave the rest on the record.
**Add a party sort to the carrier**, taken as positive existential atoms and as
heads only: 95 residue items across all seven categories and 26 of 35 applications
turn on who holds a key, who is owed and who is paid, and the only published
result it costs is a perfection measurement that the paper itself calls trivially
true. **Add a bounded-delegate-mandate element at presence granularity**: the
run's strongest convergence, machine-checked union-closed over `2^12`, and the
only proposal in this document that makes the Horn half of the theory smaller.
**Widen the requirement head with voiding witnesses**, so an obligation that
cannot arise is discharged rather than left unspecified: proved in Lean to preserve
polarity and union-closure, costing exactly one arc of the fifteen-arc definite
digraph, and correcting the two INADMISSIBLE verdicts — Rysk and Hegic — that
stage 3 showed are right about the tables and wrong about the protocols.

Three things are recorded as open problems instead. **The level above** — routers
routing to routers, curators allocating over protocols, an application setting the
security parameter of the bridge beneath it — is 28 items on six categories and it
destroys four of the five results, because a directed consumption relation is not
a union and a digraph is not a graph; it is the next paper, and the residue is the
case for writing it. **Magnitudes** are declined with a witnessed counterexample:
23 items, and the only repair in the residue that costs all five results at once.
**The off-ledger instruments** — 19 items in Cayman registers, CFTC segregation
and arbitration clauses — are reported as residue and left there, because a sort
with no finite enumeration takes every measurement in the paper with it. And the
largest group of all, the 82 unnamed mechanisms spread across every category and
three quarters of the applications, is deliberately not repaired: it is not one
finding repeated, it is eighty-two findings each seen once, and answering it would
cost 82 fitted parameters to buy coverage the paper does not claim.
