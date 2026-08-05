# Stage-1 findings that bear on the formalism

Each lane returns a headline when it completes. These are the ones that change
what the algebra should be, not merely what a decomposition should say. Stage 4
consumes this file; stage 2 lanes are told the ones relevant to them.

Detail and citations live in `C:\defiformal-work\<slug>\01-research.md`.

---

## 06 · Yield vaults — the delegated allocation mandate has a *shape*

The corpus called this the most-confirmed gap in the project. Stage 1 sharpens
it from "a missing element" to a **five-part primitive with a fixed shape**,
found at four of five targets plus MetaMorpho:

> named agent → domain whitelist → magnitude cap → rate-of-change limit or
> delay → revocation

and always bounding a *different* quantity: leverage, savings rate, venue,
credit limit. The code proves the level claim — `reallocate` / `leverage`
accept an arbitrary target from a human and the contract checks only the
envelope. DefiLlama names the category twice, $16.55bn, 3.0× the yield
categories.

**Consequence for stage 4.** This is not one new element. It is a *schema* over
elements, parameterised by what is bounded. Whatever the repair is, it must
express "an agent may move X within these bounds", which the current language —
subject implies terms — cannot state at all.

## 10 · Options — the vocabulary cannot say "closed by construction"

The tables reject four of the five options venues. Stage 1's verdict:
**none of the four rejections is correct as stated, and they fail two different
ways.**

- **Aevo and Panoptic** are *decomposition artefacts*: both have a first-class
  threshold test and price source, demoted to derived.
- **Rysk and Hegic** are *mis-diagnoses of a different kind*. They escrow
  maximum loss at trade time, so no threshold test and no backstop **can**
  exist. The requirement is discharged by construction rather than by a
  mechanism, and the vocabulary has no way to say that — so it reads a closed
  obligation as an unspecified one.

**Consequence for stage 4.** The requirement language admits exactly one way to
discharge a term: name an element that satisfies it. It needs a second —
discharge by construction, where the obligation cannot arise. This is a change
to the constraint language, not to the vocabulary, and it is the sharpest
formalism finding of the run so far. It also qualifies the paper's options
measurement: the rejection rate is a true statement about the tables and a false
one about the protocols.

Also: `Bs` is wrong for Derive (the Security Module is an owner-funded treasury,
no stake, no slashing), and Derive and Aevo are not identical — different index
and loss-absorption topology, and only one has auto-deleveraging.

## 12 · Prediction — a clearinghouse without a waterfall

All three corpus claims confirm, but two need re-siting. Polymarket now runs a
central counterparty **with no guaranty fund at all**, so the three symbols that
were said to reconstruct a default waterfall do not reconstruct this one; two
further pieces — operator first-loss tranches and callable assessments — have no
symbol. Steakhouse's depositor-weighted veto refutes "no on-chain recourse": the
real distinction is **preventive versus compensatory** recourse. Polymarket's
collateral is now pUSD, which arms a peg-swap element the corpus record does not
carry.

## 05 · Perpetuals — two corpus records are stale on their central fact

Aster now runs **in-consensus order books on its own PoSA L1** (2026-03-16,
closed validator set, closed-source node), so it belongs with Hyperliquid rather
than the operator-run books. edgeX has **left StarkEx** for an Arbitrum-stack
rollup. Together these break the lane's own claimed identity of ApeX ≡ edgeX ≡
Lighter and invalidate the edgeX validium residues. Neither ApeX nor edgeX
documents an insurance fund, so the staked-backstop element is unsupported for
both. Lighter is the only venue in the category with source-to-deployment
correspondence.

## 04 · Liquid staking — three corpus claims are false, not stale

EigenLayer's Unique Stake **prevents** the same collateral backing mutually
unaware slashing laws; ether.fi's T-NFT/B-NFT tranche is in `src/archive/`; and
WBETH has a real on-chain permissionless mint and an on-chain withdrawal queue
with a rate-limited oracle contract, not an admin key. WBETH's record was
overturned from verified on-chain bytecode alone, there being no repo or spec.
`Vl` remains unusable for WBETH — confirmed.

## 08 · Intents — the category is nested, not flat

Jupiter's own docs list other routers, including two of the five corpus rows, as
competitors inside its meta-aggregator: **two corpus rows are components of a
third**. Both corpus identity claims fail. KyberSwap now holds *exclusive*
Uniswap-v4 and PancakeSwap-Infinity pools where it is the only permitted taker
on a 70/30 split; OKX runs a sealed batch auction with its own affiliated
solvers and a published conflict-of-interest policy conceding it may
default-display a non-best route. Volumes for both are self-reported and OKX's
has since been revised down 38%.

**Consequence for stage 4.** Composition in this corpus is modelled as union of
element sets between peers. A meta-aggregator that routes to routers is a
*containment* relation between protocols, which the carrier has no way to
express — the same gap the yield lane found one level down.

## 01 · Spot exchange — an artefact can be ambiguous at its own version string

Two different Curve twocrypto implementations both report `version = "v2.1.0"`
and implement **mathematically different** repegging predicates: the deployed
one is linear in accumulated profit, the repository's is quadratic, the first
being the first-order expansion of the second. They agree near unit profit and
diverge as profit compounds. Any citation of "twocrypto v2.1.0" without a
bytecode hash is citing an ambiguous artefact. Curve's AMM repositories are also
**all-rights-reserved**, not open source, which constrains reproduction in the
paper.

---

## 07 · Bridges — the headline confirms, the control plane inverts

The corpus's sharpest bridge claim is **confirmed outright**: the top three
wrapped-asset bridges carry no verification element, because a company holds the
asset and there is nothing to verify.

But the control-plane symbols are wrong in a direction that inverts the reading.
On-chain at 2026-08-04: WBTC has **no timelock** (three plain multisigs) and no
blacklist; BTCB has **no pause function at all** and mints from a **single EOA**;
Coinbase alone has a real proxy and a real blacklist, held by EOAs. The axis
separating these three is therefore **quorum against single key**, not delay
against upgrade — and the vocabulary's control elements name the *facility*
(timelock, proxy, pause) without naming *who holds it or how many of them there
are*. Two ranking bases are also mis-attributed: 93% of one venue's headline
figure is native CCTP USDC rather than bridge escrow, and another's is a
different token from the one decomposed.

**Consequence for stage 4.** Control-plane elements are unary predicates on a
protocol where the risk is a property of the *holder*: an EOA, a 3-of-5, a DAO
with a delay. The carrier has no party sort, which is the same gap the paper
already conjectures under fibre separation — here it is exhibited on the three
largest bridges rather than conjectured.

## 03 · CDP stablecoins — the rate gap is four gaps, and one of them is the yield lane's primitive

The corpus records a single residue for this category: no price-of-credit
instrument. Stage 1 says that is **wrong in shape**. There are four distinct
rate instruments among five protocols, and the corpus files one of them under
the wrong heading:

1. a **deployed bounded-delegate rate setter** — an agent sets the borrow rate,
   the savings rate and the savings-reserve rate within min, max and step
   bounds, with no executive vote;
2. an administered rate keyed to **external benchmarks**, including a central
   bank policy rate;
3. a **closed-loop controller on peg error**;
4. **borrower-chosen** rates, priced by the borrower themselves.

**Consequence for stage 4, and it is the run's first cross-lane convergence.**
(1) is the yield lane's delegated allocation mandate in a different dress —
named agent, bounded quantity, cap, step limit, revocation — bounding a *rate*
rather than an allocation. Two independent lanes, on different categories, from
different evidence, arrived at the same five-part schema. That is much stronger
evidence for a *level* above the element than either lane alone, and it is what
stage 4 should build on. (4) is stranger still: a rate set per-position by the
borrower is not an instrument the protocol holds at all.

Also: the control-plane register is a bigger gap here than the rate one, and two
recorded residues for one protocol are refuted outright.

---

## 02 · Lending — the rate gap is eight instruments, and the delegate mandate is confirmed

**Both tiebreak questions resolve, from source, not from search** (this lane ran
after the WebSearch budget was exhausted, so every citation is a direct fetch of
raw repository source or the GitHub API — narrower than a search lane, and
harder evidence).

**The price of credit is not one gap.** Five protocols, five different loci for
the setter: a bounded mutable parameter (Aave V3, `MAX_BORROW_RATE = 1000%`,
kink ∈ [1%,99%], `slope1 ≤ slope2`); a **compile-time constant nobody can
change** (Morpho's `AdaptiveCurveIrm`, a closed-loop controller whose
`rateAtTarget` drifts at 50/yr toward 90% utilisation within [0.1%, 200%]); **a
live read of another protocol's state variable** (SparkLend's kink is an
`immutable` spread over Sky's `pot.dsr()`/`susds.ssr()`, so Sky moves the rate
with no SparkLend transaction at all); an **entirely unbounded** timelocked
parameter (JustLend's `updateJumpRateModel` has no maximum, no kink bounds, no
shape constraint); and **no protocol-level rate whatever** (Maple, where
`_interestRate` is a field of a bilaterally accepted loan indenture). Four axes
separate them — memory (function vs controller), setter locus, bounding, and
latency — and no two protocols agree on all four. **Combined with the CDP lane
the run has now distinguished eight rate instruments against one corpus residue
line.** A single new element would name three of five and name them identically.

**The delegated mandate: third lane confirmed, five instances, first four parts
in code at every one.** Aave `RiskSteward` (rates, caps, LTV, e-modes, oracle
caps — one reusable `_validateParamUpdate` carrying `minDelay` + `maxPercentChange`
per parameter per asset); MetaMorpho curator+allocator (asymmetric queue
timelock, 1 day–2 weeks); SparkLend `CapAutomator` (asymmetric cooldown);
SparkLend ALM `RateLimits` (token bucket); Maple pool delegate. JustLend has
none — and that dates the primitive: it is a **later layer in separate
repositories**, absent from the Compound-V2 vintage.

**Five things the yield and CDP lanes could not see, all of which change the
schema:**
1. the agent may be an **automaton** (Aave's `AaveStewardInjector*` + `RiskOracle`
   + Chainlink/Gelato);
2. the delay is **asymmetric** — instant to tighten, slow to loosen — rediscovered
   independently by Morpho and Spark;
3. the fourth slot is **four different mechanisms**, not one: debounce
   (frequency), queue-timelock (latency), cooldown (one-sided frequency), token
   bucket (**throughput**). "Rate-of-change limit" as a single field conflates
   *how often* with *how much per unit time*;
4. the agent may be **bonded**, not merely reputable — Maple's delegate posts
   first-loss cover and `requestFunds` blocks origination below `minCoverAmount`,
   so **"accountable only reputationally" is refuted in code** and must become an
   optional sixth slot (stake) whose default is empty;
5. **the bound itself may be revocable** — `setUnlimitedRateLimitData` lifts
   Spark's cap and flow limit in one admin transaction with no delay. The schema
   has a slot for revoking the *agent* and none for revoking the *bound*.

**Consequence for stage 4, and it is the run's structural result.** Findings 1
and 2 converge on **one field list** — setter locus, bound, latency, stake, and
who may lift the limit. Aave proves they are one gap rather than two:
`RiskSteward.updateRates` *is* the rate instrument implemented as a bounded
mandate, through the same validator that bounds its caps and its LTVs.

**Corpus deltas.** Morpho Blue **is not admin-less** — `Morpho.sol` has an
`owner` with `setOwner`/`enableIrm`/`enableLltv`/`setFee`(≤25%)/`setFeeRecipient`;
the true claim is *non-upgradeable, unpausable, and monotonic* (enabling can
never be undone, and no owner function reaches an existing market). The
Aave≡SparkLend identity claim is refuted on the one axis the corpus itself says
matters most. The close-factor residue is filed under JustLend but is
category-wide with two shapes — Aave's is *dynamic*
(`CLOSE_FACTOR_HF_THRESHOLD = 0.95`, a `2000e8` size floor, a dust rule),
JustLend's a constant in [5%,90%]. Spark's org moved to `sparkdotfi` and its
core default branch is `dev`. **Three licence traps:** JustLend declares **no
licence at all**, Maple's loan core is **BUSL-1.1** despite `NOASSERTION` repo
metadata, and only Morpho (GPL-2.0, post-relicensing from BUSL-1.1) is
unambiguously reproducible.

---

## Cross-lane convergence, so far

| finding | lanes | what it implies |
|---|---|---|
| a **bounded delegate mandate** — named agent, domain, cap, rate-of-change limit, revocation | 06 yield, 03 CDP, **02 lending (5 instances, 4 parts in code at each)** | **CONFIRMED — a schema over elements, not an element.** Needs a 6th slot (agent stake, default empty), a 4-way split of the rate-of-change slot (debounce / timelock / cooldown / token bucket), an automaton-valued agent, and a slot for revoking *the bound* |
| **the price of credit** — no element names a rate | 03 CDP (4 instruments), **02 lending (5 more, incl. two the CDP lane lacked)** | **eight distinguishable instruments against one corpus residue line.** Same field list as the mandate schema — Aave's `RiskSteward.updateRates` is the rate instrument *implemented as* a bounded mandate, so these are one gap, not two |
| **containment between protocols** — routers routing to routers, curators allocating over protocols | 08 intents, 06 yield, **02 lending** | composition is modelled as union between peers; there is no relation for one protocol consuming another. Lending exhibits it three more times: MetaMorpho vaults deposit into Blue markets; SparkLend's rate *is* Sky's rate; Spark ships oracles into Morpho and Maple runs reward programmes there |
| **the holder, not the facility** — who holds a key, and how many of them | 07 bridges, 03 CDP, **02 lending (unresolved)** | control elements are unary predicates where the risk is a property of a party; the carrier has no party sort. Lending could not close this either — source proves *what* a role may do and is silent on *who is* the role |
| **discharge by construction** | 10 options | a requirement term can be closed by making the obligation unable to arise; the language admits only satisfaction by a named element |

---

## Pending lanes

09-rwa · 11-fiat-stablecoins

*(02-lending landed 2026-08-04; research at `C:\defiformal-work\02-lending\01-research.md`, 1372 lines.)*
