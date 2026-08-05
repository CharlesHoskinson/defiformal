# 02 · Lending — stage-1 research

**Targets:** Aave V3 · Morpho · SparkLend · JustLend V1 · Maple
**Lane:** replacement run, 2026-08-04. All access dates **2026-08-04** unless stated.

**Method note, stated up front because it bounds every claim below.** This
session's WebSearch budget was exhausted (200/200) before this lane began. Every
citation here is therefore a **direct fetch of a primary artefact** — raw source
from the canonical repository, the GitHub repository API, or the protocol's own
documentation host — with no aggregator in the path. That is a stronger evidence
base than a search-driven lane would have produced, but it is *narrower*: claims
that live only in forum posts, governance votes, dashboards or block explorers
could not be reached and are marked **UNKNOWN**. In particular, **no claim in
this file about a deployed address, a live parameter value, a multisig signer
set, or a TVL figure has been verified on-chain.** Where the corpus asserts such
a thing I say so rather than confirming it.

---

## 1 · Aave V3

### 1.1 WHAT IT DOES

A supplier deposits an ERC-20 into a single shared `Pool` and receives an
**aToken** one-for-one, which is a claim on the reserve that grows in nominal
balance as interest accrues. A borrower first marks one or more supplied
reserves as collateral (`setUserUseReserveAsCollateral`), then calls `borrow`,
receiving the borrowed asset itself plus a **variable debt token** recording the
obligation. There is no maturity and no fixed schedule: the loan is open until
repaid (`repay`) or liquidated. Pricing is continuous and utilisation-driven —
the borrow rate is recomputed on every state-changing interaction from the
reserve's own utilisation, and interest is capitalised into a per-reserve index
rather than billed. Monitoring is a single scalar, the **health factor**, derived
from the oracle value of collateral times each asset's liquidation threshold
against the oracle value of debt; the position is liquidatable when it falls
below the liquidation threshold constant. Closing happens one of two ways: the
borrower repays, or a third party calls `liquidationCall`, repaying part of the
debt and seizing collateral at a bonus. Two facilities sit alongside the core
loan: `flashLoan`, which lends and requires repayment inside one transaction,
and `setUserEMode`, which raises borrowing power for a governance-declared
category of correlated assets.
*Source: `https://aave.com/docs/developers/smart-contracts/pool`, accessed 2026-08-04.*

### 1.2 DESIGN

**Interest-rate model — complete, from source.**
`DefaultReserveInterestRateStrategyV2`
(`aave-v3-origin`, `src/contracts/misc/DefaultReserveInterestRateStrategyV2.sol`,
branch `main`, fetched 2026-08-04) holds a per-reserve struct
`{optimalUsageRatio, baseVariableBorrowRate, variableRateSlope1, variableRateSlope2}`
in basis points and computes, in `calculateInterestRates`:

```
U_b = totalDebt / (availableLiquidity + totalDebt)               // borrow usage
U_s = totalDebt / (availableLiquidity + totalDebt + unbacked)    // supply usage

if totalDebt == 0:  borrowRate = base ;                     liquidityRate = 0
if U_b <= U*:       borrowRate = base + slope1 · (U_b / U*)
if U_b >  U*:       borrowRate = base + slope1 + slope2 · ((U_b − U*) / (1 − U*))

liquidityRate = borrowRate · U_s · (1 − reserveFactor)
```

This is the **classic two-slope kinked curve**. Three properties matter for the
rate question and all three are enforced in `_setInterestRateParams`:

| bound | value | effect |
|---|---|---|
| `MAX_BORROW_RATE` | `1000_00` bps | `base + slope1 + slope2 ≤ 1000%` |
| `MIN_OPTIMAL_POINT` / `MAX_OPTIMAL_POINT` | `1_00` / `99_00` | kink confined to [1%, 99%] |
| shape constraint | `variableRateSlope1 <= variableRateSlope2` | the curve cannot be made concave |

Writes are `onlyPoolConfigurator`. **Inside this contract there is no delay and
no rate-of-change limit** — a permitted caller moves the entire curve in one
transaction, subject only to the level bounds above. The delay and the step
limit live one layer up, in the Risk Steward (§1.2 control plane).

Note the architectural shift the corpus record predates: in V2 of the strategy
the parameters are **stored per reserve inside one strategy contract** and
mutated in place. Earlier Aave V3 deployed *one strategy contract per reserve*
with `immutable` parameters, so a rate change meant deploying and repointing a
contract. SparkLend still runs the older shape (§3.2) — which is why the two
protocols' rate instruments are **not** the same instrument even though the
formula is the same.

**Liquidation path — from source.** `LiquidationLogic.sol` (`aave-v3-origin`,
`src/contracts/protocol/libraries/logic/LiquidationLogic.sol`, `main`, fetched
2026-08-04) defines:

- `DEFAULT_LIQUIDATION_CLOSE_FACTOR = 0.5e4` (50%);
- `CLOSE_FACTOR_HF_THRESHOLD = 0.95e18`;
- `MIN_BASE_MAX_CLOSE_FACTOR_THRESHOLD = 2000e8` (2000 units of base currency);
- `MIN_LEFTOVER_BASE = MIN_BASE_MAX_CLOSE_FACTOR_THRESHOLD / 2`.

The close factor is **dynamic**, not fixed: a liquidator may take only 50% of
the debt when the borrower's collateral *and* debt in that reserve are both at
or above 2000 base units **and** the health factor is above 0.95; otherwise the
full position is liquidatable. A further rule forbids leaving a dust remainder —
the liquidation must leave more than `MIN_LEFTOVER_BASE` of both collateral and
debt, or take everything. This is a materially more elaborate design than the
Compound-family single `closeFactorMantissa`, and it bears directly on a corpus
claim (see §1.6).

**Control plane.** The `PoolConfigurator` is the sole writer of reserve
configuration and of rate parameters; roles are held through an `ACLManager`
(`POOL_ADMIN`, `RISK_ADMIN`, `EMERGENCY_ADMIN`, and others). Above that sits
governance V3 (`aave-dao/aave-governance-v3`) and, for bounded changes, the
**Risk Steward** (§Finding 2). *Who holds each key and how many of them there
are is* **UNKNOWN** *from source alone* — the `aave-dao/aave-permissions-book`
repository (MIT, last push 2026-08-05T00:26:09Z) exists precisely to enumerate
this and was not fetched in this run; it is the right next artefact for a
stage-2 lane. This is the same gap the bridges lane reported: the source proves
*what* a role may do and is silent on *who is* the role.

**Price sources.** `AaveOracle` with per-asset Chainlink-style feeds, plus the
`aave-dao/aave-price-feeds` repository and the capped-adapter family
(`IPriceCapAdapter`, referenced from `IRiskSteward.sol`) which imposes a
**maximum yearly growth rate** on LST exchange-rate feeds — e.g. the shipped
Ethereum example sets `maxYearlyRatioGrowthPercent: 10_64` (10.64%) for the
wstETH oracle. So the oracle is not merely read; its permitted *drift* is a
governed parameter. *Source:
`https://raw.githubusercontent.com/aave-dao/aave-v3-risk-stewards/main/src/contracts/examples/EthereumExample.sol`,
accessed 2026-08-04.* Whether these adapters are live on every reserve is
UNKNOWN.

**Invariants asserted.** The repository ships a `certora/` directory of formal
specifications (present in the SparkLend fork tree and in `aave-v3-origin`). The
specific invariants proved were not read in this run — **UNKNOWN**.

### 1.3 REPO

`https://github.com/aave-dao/aave-v3-origin` — default branch `main`, last push
`2026-07-29T10:12:35Z`, language Solidity, licence reported by the GitHub API as
**`NOASSERTION`** (a custom licence file, not an SPDX identifier — the repo does
carry a `LICENSE` file, 6211 bytes, fetched 2026-08-04). Top level: `src/contracts/`
splits into `protocol/` (pool, configuration, libraries, tokenization),
`misc/` (rate strategy, oracles), `extensions/` (config engine, static aTokens),
`helpers/`, plus `certora/` specs.

The Risk Steward layer is a **separate repository**,
`https://github.com/aave-dao/aave-v3-risk-stewards` (`main`, last push
`2026-07-10T13:07:25Z`, licence `NOASSERTION`) — this matters because the
bounded-mandate mechanism is not in the core repo and a lane reading only
`aave-v3-origin` would not find it.

**Correspondence between repository and deployed contracts is asserted, not
proved, in this run.** I did not fetch bytecode from any chain and did not
compare a deployed implementation hash to a build of this tree. The commit
inspected is `main` as of 2026-08-04; I did not pin a tag, so **this citation
has the same defect the spot-exchange lane found at Curve** — a mutable branch
reference is an ambiguous artefact. A stage-2 lane should re-pin to a commit SHA.

### 1.4 EVIDENCE

| claim | source | accessed |
|---|---|---|
| rate formula, bounds, `onlyPoolConfigurator` | `https://raw.githubusercontent.com/aave-dao/aave-v3-origin/main/src/contracts/misc/DefaultReserveInterestRateStrategyV2.sol` | 2026-08-04 |
| close factor, HF threshold, dust rule | `https://raw.githubusercontent.com/aave-dao/aave-v3-origin/main/src/contracts/protocol/libraries/logic/LiquidationLogic.sol` | 2026-08-04 |
| user-facing Pool functions, aTokens, debt tokens | `https://aave.com/docs/developers/smart-contracts/pool` | 2026-08-04 |
| repo metadata, licence, branch, push date | `https://api.github.com/repos/aave-dao/aave-v3-origin` | 2026-08-04 |
| Risk Steward contract, roles, validation | `https://raw.githubusercontent.com/aave-dao/aave-v3-risk-stewards/main/src/contracts/RiskSteward.sol` | 2026-08-04 |
| `RiskParamConfig{minDelay, maxPercentChange}` | `https://raw.githubusercontent.com/aave-dao/aave-v3-risk-stewards/main/src/interfaces/IRiskSteward.sol` | 2026-08-04 |
| steward repo metadata | `https://api.github.com/repos/aave-dao/aave-v3-risk-stewards` | 2026-08-04 |
| LST oracle growth cap example | `https://raw.githubusercontent.com/aave-dao/aave-v3-risk-stewards/main/src/contracts/examples/EthereumExample.sol` | 2026-08-04 |
| org repo inventory (permissions-book, price-feeds, risk-agents) | `https://api.github.com/orgs/aave-dao/repos?per_page=100&sort=pushed` | 2026-08-04 |

**Not verified:** every deployed address, every live parameter value, the
identity and size of any key-holding multisig, TVL, and the Certora invariants.

### 1.5 WHAT LOOKS UNNAMEABLE

1. **The rate curve itself.** `Ix` says an index accrues; nothing says at what
   rate, and the rate is the product. Confirms the corpus.
2. **Bounds on a delegated parameter change.** `Tg` names a delay. There is no
   symbol for "a named party may move this parameter by at most X% and not more
   often than every T seconds" — see Finding 2.
3. **A dynamic close factor.** Not merely "no element for the close factor" but
   no element for *a liquidation allowance that is a function of how underwater
   the position is*. `Li` names the incentive; the allowance is a separate
   quantity with its own state.
4. **A dust floor.** `MIN_LEFTOVER_BASE` forbids a liquidation that would leave
   an uneconomic remainder. This is a constraint on the *shape of a permitted
   partial close*, not on the incentive to perform it.
5. **A rate-of-change cap on an oracle.** `Ex` names the feed. A capped adapter
   that rejects a feed value implying more than 10.64%/yr growth is a
   *predicate on the feed's derivative*, and neither `Ex` nor `Tp` reaches it.
6. **Two views of one balance.** aTokens are scaled balances times an index, so
   `Ix` and `Rb` are charged separately for one mechanism, and nothing states
   they are the same object viewed twice. Confirms the corpus marker.

### 1.6 DELTA

- **The corpus residue "no element for the close factor … every Compound
  descendant has it" (filed under JustLend) implies Aave has no close factor.
  It has one, and a more complex one than the Compound family.**
  `DEFAULT_LIQUIDATION_CLOSE_FACTOR = 0.5e4`, made conditional on
  `CLOSE_FACTOR_HF_THRESHOLD = 0.95e18` and on a `2000e8` position-size floor,
  plus a `MIN_LEFTOVER_BASE` dust rule. The gap is therefore **category-wide,
  not JustLend-specific**, and it is larger than recorded: two protocols in this
  lane implement *different* close-factor policies and the vocabulary
  distinguishes neither. *Source: `LiquidationLogic.sol`, accessed 2026-08-04.*
- **The corpus records Aave's rate model as an unnamed residue but does not
  record that the rate parameters are themselves bounded in code.**
  `MAX_BORROW_RATE`, `MIN_OPTIMAL_POINT`, `MAX_OPTIMAL_POINT` and
  `slope1 <= slope2` are hard `require`s. The residue is not just "no element
  for the rate" but "no element for a *bounded* rate" — and the bounding is
  exactly the structure Finding 2 is about.
- **The corpus lists `Bs` for Aave on the Safety Module / Umbrella.** Not
  verified in this run — the Umbrella contracts were not fetched. Recorded as
  **UNCONFIRMED**, not refuted.
- **Stale-artefact risk.** The corpus does not pin a commit for Aave. Neither
  does this file (branch `main`). Flagged, not fixed.

---

## 2 · Morpho

### 2.1 WHAT IT DOES

Morpho is two layers and they must not be conflated. **Morpho Blue** is a
singleton contract holding many *isolated markets*, each defined by five
parameters fixed at creation: `{loanToken, collateralToken, oracle, irm, lltv}`.
Anyone may call `createMarket` with any combination whose `irm` and `lltv` are
on governance's enabled lists. A lender calls `supply` on a chosen market and
receives *shares of that market only*; a borrower posts `collateralToken`, calls
`borrow`, and is checked against `_isHealthy` at that market's fixed `lltv`.
There is no maturity. There is no cross-market netting: a bad debt in one market
cannot touch another. A liquidator calls `liquidate` and seizes collateral at an
incentive derived from the market's own LLTV. **Morpho Vaults** (MetaMorpho) is
the second layer: an ERC-4626 vault denominated in one asset, into which a
passive depositor deposits once and receives vault shares, while a **curator**
decides which Blue markets that deposit may enter and at what size, and an
**allocator** moves the money between them. Most depositor capital reaches Blue
through a vault rather than directly, which is why the curator is the economic
centre of the protocol even though it is not part of the base primitive.
*Sources: `morpho-blue/README.md` and `src/Morpho.sol`, accessed 2026-08-04;
`metamorpho/src/MetaMorpho.sol`, accessed 2026-08-04.*

### 2.2 DESIGN

**Interest-rate model — complete, from source, and it is a controller.**
`AdaptiveCurveIrm` (`morpho-blue-irm`, `src/adaptive-curve-irm/`, `main`,
fetched 2026-08-04). Constants from `libraries/ConstantsLib.sol`, quoted exactly:

| constant | source value | meaning |
|---|---|---|
| `CURVE_STEEPNESS` | `4 ether` | 4 |
| `TARGET_UTILIZATION` | `0.9 ether` | 90% |
| `ADJUSTMENT_SPEED` | `50 ether / 365 days` | 50 per year |
| `INITIAL_RATE_AT_TARGET` | `0.04 ether / 365 days` | 4%/yr |
| `MIN_RATE_AT_TARGET` | `0.001 ether / 365 days` | 0.1%/yr |
| `MAX_RATE_AT_TARGET` | `2.0 ether / 365 days` | 200%/yr |

The design is a **two-timescale closed-loop controller on utilisation error**.
Fast loop: a static curve of steepness 4 around the current `rateAtTarget`.
Slow loop: `rateAtTarget` itself *drifts*, continuously compounding at
`ADJUSTMENT_SPEED · err` per second, where `err` is the normalised distance of
utilisation from 90%, clamped into `[MIN_RATE_AT_TARGET, MAX_RATE_AT_TARGET]`.
The source comments record the implied instantaneous band: rate at target
between 0.1% and 200%/yr, hence realised borrow rate between 0.025% and 800%/yr.

The governance property is the sharp one: **these are `constant`s in a contract
with no setter and no admin.** No party — not Morpho's owner, not the market
creator, not the curator — can change the steepness, the target, the adjustment
speed or the bounds. The only choice anyone exercises is *which* IRM address a
market is created with, and that address is then frozen in the market's
identity forever. Rate policy at Morpho is therefore not a governance action at
all; it is a deployment choice made once, per market, by whoever created it,
from a set governance pre-approved via `enableIrm`.

**Solvency and liquidation — from source.** `morpho-blue/src/libraries/ConstantsLib.sol`
(fetched 2026-08-04): `MAX_FEE = 0.25e18` (25%), `ORACLE_PRICE_SCALE = 1e36`,
`LIQUIDATION_CURSOR = 0.3e18`, `MAX_LIQUIDATION_INCENTIVE_FACTOR = 1.15e18`.
The liquidation incentive is thus **derived from the market's LLTV** through the
cursor and hard-capped at 1.15×, rather than being a free per-market parameter.
Borrow and withdraw both additionally require
`totalBorrowAssets <= totalSupplyAssets`.

**Control plane — and the corpus is wrong here, see §2.6.** `Morpho.sol` has an
`owner` with exactly five powers: `setOwner`, `enableIrm`, `enableLltv`
(requiring `lltv < WAD`), `setFee(marketParams, newFee)` bounded by
`MAX_FEE = 25%`, and `setFeeRecipient`. There is **no proxy, no upgrade path,
no pause, and no function that can alter an existing market's oracle, IRM or
LLTV.** Enabling is monotonic — `enableIrm` and `enableLltv` set a flag true and
there is no disable — so governance can widen the permitted set but never narrow
it, and can never retract a market already created. That is a much more precise
and much more interesting claim than "no admin".

**Price sources.** Each market's `oracle` is an arbitrary address chosen by the
market creator, validated by nothing at the protocol level, and immutable
thereafter. Morpho Blue is explicitly "oracle agnostic" (README).

**Curator mandate.** See Finding 2 — all five parts, proven from code.

### 2.3 REPO

- `https://github.com/morpho-org/morpho-blue` — `main`, last push
  `2026-07-31T18:20:34Z`, Solidity, **GPL-2.0**. Layout: `src/Morpho.sol`
  singleton, `src/libraries/` (internal only), `src/libraries/periphery/`
  (integrator helpers, not used by the core), `src/mocks/`, `src/interfaces/`,
  `audits/`, and `morpho-blue-whitepaper.pdf`.
  **Licence history is itself a finding:** the README states the repository was
  previously **BUSL-1.1** and links the old licence at commit
  `1bcfbfdfa284597ae526d082dd34bcd182d15d27`. A citation of "Morpho Blue,
  GPL-2.0" is only true after that relicensing.
- `https://github.com/morpho-org/metamorpho` — `main`, last push
  `2026-08-01T12:47:39Z`, Solidity, **GPL-2.0**.
- `https://github.com/morpho-org/morpho-blue-irm` — holds `AdaptiveCurveIrm`;
  the file header declares `SPDX-License-Identifier: MIT`, repository-level
  licence **UNKNOWN** (metadata not fetched).

**Correspondence: asserted, not proved.** No bytecode comparison was performed.
Morpho is the one target in this lane where correspondence is *checkable in
principle to a stronger standard* than the others, because the core is
non-upgradeable — a deployed Blue instance cannot have drifted from its
deployment. That argument still requires a bytecode fetch, which was not done.

### 2.4 EVIDENCE

| claim | source | accessed |
|---|---|---|
| IRM constants, controller semantics | `https://raw.githubusercontent.com/morpho-org/morpho-blue-irm/main/src/adaptive-curve-irm/libraries/ConstantsLib.sol` | 2026-08-04 |
| IRM implementation | `https://raw.githubusercontent.com/morpho-org/morpho-blue-irm/main/src/adaptive-curve-irm/AdaptiveCurveIrm.sol` | 2026-08-04 |
| owner powers, `createMarket`, `enableIrm`/`enableLltv`, health/liquidity requires | `https://raw.githubusercontent.com/morpho-org/morpho-blue/main/src/Morpho.sol` | 2026-08-04 |
| `MAX_FEE`, `LIQUIDATION_CURSOR`, `MAX_LIQUIDATION_INCENTIVE_FACTOR` | `https://raw.githubusercontent.com/morpho-org/morpho-blue/main/src/libraries/ConstantsLib.sol` | 2026-08-04 |
| immutability claim, licence history, repo layout | `https://raw.githubusercontent.com/morpho-org/morpho-blue/main/README.md` | 2026-08-04 |
| curator/allocator/guardian roles, caps, timelock, fee | `https://raw.githubusercontent.com/morpho-org/metamorpho/main/src/MetaMorpho.sol` | 2026-08-04 |
| `MAX_TIMELOCK`, `MIN_TIMELOCK`, `MAX_QUEUE_LENGTH`, `MAX_FEE` | `https://raw.githubusercontent.com/morpho-org/metamorpho/main/src/libraries/ConstantsLib.sol` | 2026-08-04 |
| repo metadata and licences | `https://api.github.com/repos/morpho-org/morpho-blue`, `.../metamorpho` | 2026-08-04 |

**Not verified:** the DefiLlama "Risk Curators" $8,760M figure and its
per-curator split (the corpus's own figure, not re-checked here — WebSearch
budget exhausted); any deployed vault's actual curator address; whether any live
market uses an IRM other than `AdaptiveCurveIrm`.

### 2.5 WHAT LOOKS UNNAMEABLE

1. **A rate that is a controller, not a function.** Aave's rate is a pure
   function of current utilisation. Morpho's depends on the *history* of
   utilisation through a drifting state variable. `Ix` cannot distinguish a
   memoryless price from a stateful one, and the difference is the whole
   design.
2. **Immutability as a positive commitment.** Confirms the corpus, but the
   corpus overstates it (§2.6). The real unnameable is subtler: *governance may
   widen a permitted set and may never narrow it*. Monotonic authority has no
   symbol.
3. **A permissionless market factory over a frozen template.** Anyone may
   instantiate `{collateral, loan, LLTV, oracle, IRM}`; nobody may edit one
   afterwards. `Im` names the fence and says nothing about who may build one.
4. **An unvalidated oracle slot.** `Ex` names a feed. It cannot say "the feed is
   whatever the market creator wrote, and the protocol never checks it".
5. **Delegated risk curation** — the corpus's headline, confirmed, and see
   Finding 2 for its exact shape.
6. **A derived liquidation incentive.** `LIQUIDATION_CURSOR` makes the bonus a
   *function of the LLTV* rather than an independent parameter. `Li` treats the
   incentive as given.
7. **The vault/market containment relation.** A MetaMorpho vault is a depositor
   in markets it does not control, and is itself the thing depositors hold.
   This is the intents/yield lanes' containment gap, exhibited a third time.

### 2.6 DELTA

- **The corpus claim "Morpho Blue has no admin and cannot be upgraded" is half
  wrong and should be re-sited.** It *cannot be upgraded* — confirmed, no proxy,
  no pause. But it **does have an admin**: `Morpho.sol` declares `owner`, an
  `onlyOwner` modifier, and five owner functions (`setOwner`, `enableIrm`,
  `enableLltv`, `setFee` ≤ 25%, `setFeeRecipient`). The accurate statement is
  *governance-minimised and non-upgradeable, with a live owner whose authority
  is monotonic and cannot reach an existing market's parameters.* The corpus's
  own reasoning — "absence of a symbol means 'I did not observe it', not 'it
  cannot exist'" — is right about the vocabulary and wrong about the facts here.
  *Source: `https://raw.githubusercontent.com/morpho-org/morpho-blue/main/src/Morpho.sol`, accessed 2026-08-04.*
- **The corpus element set for Morpho omits `Gp`-adjacent nuance and includes
  `Gp`.** The corpus lists `Gp` (emergency guardian or pause) among Morpho's
  elements. Morpho **Blue** has no pause function. MetaMorpho *does* have a
  `guardian` role, but its powers are strictly *revocatory* — `revokePendingTimelock`,
  `revokePendingGuardian`, `revokePendingCap`, `revokePendingMarketRemoval` — a
  veto over queued changes, not an emergency stop on user funds. `Gp` is
  defensible at the vault layer and unsupported at the core layer, and the
  corpus record does not separate the layers. **This is the same
  preventive-versus-compensatory distinction the prediction lane drew**: a
  guardian who can only cancel a pending change is a preventive power.
- **Licence.** The corpus does not record a licence. It is GPL-2.0-or-later
  *now* and was BUSL-1.1 before commit `1bcfbfdfa28…`; any reproduction of
  Morpho source in the paper must cite the post-relicensing state.
- **`Sv` marker.** The corpus marks `Sv` as "CANDIDATE + FORCED … the discretion
  is over allocation and caps, exercised before anything goes wrong." Confirmed
  from code and sharpened: the curator's cap authority is *asymmetric in time*
  (see Finding 2), which no reading of `Sv` predicts.

---

## 3 · SparkLend

### 3.1 WHAT IT DOES

From the user's side SparkLend is Aave V3: supply an asset, receive an
interest-bearing spToken, mark collateral, borrow against it with no maturity,
be monitored by a health factor, be closed by repayment or by a third-party
`liquidationCall`. The fork is confirmed structurally — the repository tree
carries `contracts/protocol/pool/DefaultReserveInterestRateStrategy.sol`,
`Comptroller`-free Aave-V3 `PoolConfigurator`/`ACLManager` layout,
`AToken`/`StableDebtToken`/`VariableDebtToken`, `flashloan/`, and the Aave
`certora/` harness set. What differs is *where the price of credit comes from*
and *who supplies the liquidity*: the borrow rate on the stablecoin markets is
pinned to Sky's savings rate by construction rather than voted, and the lender
of last resort is Sky itself rather than a depositor.
*Source: `https://api.github.com/repos/sparkdotfi/sparklend-v1-core/git/trees/dev?recursive=1`, accessed 2026-08-04.*

### 3.2 DESIGN

**Interest-rate model — complete, from source, and it is a different instrument
from Aave's.** The base fork ships Aave's `DefaultReserveInterestRateStrategy`
(the **V1** shape: one strategy contract per reserve, parameters `immutable`).
On top of it, `sparkdotfi/sparklend-advanced` (AGPL-3.0) ships three contracts
that replace the constant parts of the curve with a **live read of an external
rate**:

- `VariableBorrowInterestRateStrategy` — the base class, Aave's two-slope curve
  with `_getBaseVariableBorrowRate()` and `_getVariableRateSlope1()` made
  `virtual`.
- `RateTargetBaseInterestRateStrategy` — "sets the base interest rate as a fixed
  spread from a rate source":
  `_getBaseVariableBorrowRate() = RATE_SOURCE.getAPR()·10^(27−dec) + _baseVariableBorrowRateSpread`.
- `RateTargetKinkInterestRateStrategy` — "sets the kink interest rate as a fixed
  spread from a rate source":
  `_getVariableRateSlope1() = max(0, RATE_SOURCE.getAPR()·10^(27−dec) + _variableRateSlope1Spread − _baseVariableBorrowRate)`.

The rate sources are Sky's own accumulators, read directly:
`PotRateSource.getAPR() = (pot.dsr() − 1e27) · 365 days` and
`SSRRateSource.getAPR() = (susds.ssr() − 1e27) · 365 days`. There is also a
`CappedFallbackRateSource`.

Three consequences, all load-bearing for Finding 1:

1. **The rate is not administered; it is mechanically pegged.** Nobody votes a
   SparkLend borrow rate. When Sky changes the SSR, SparkLend's kink rate moves
   on the next interaction, with no transaction on SparkLend at all. This is
   *not* the CDP lane's "administered rate keyed to external benchmarks" — it is
   a live functional dependency on another protocol's state variable.
2. **The spread is `immutable`.** `_baseVariableBorrowRateSpread` and
   `_variableRateSlope1Spread` are set in the constructor. Changing the spread
   requires **deploying a new strategy contract and repointing the reserve** —
   a governance spell (`sparkdotfi/spark-spells`, AGPL-3.0, last push
   `2026-08-04T08:18:54Z`). So the parameter that *is* discretionary is changed
   by code deployment, not by a setter.
3. **The slope-1 spread is `int256`, signed.** SparkLend can price its kink
   *below* the SSR.

**The protocol-to-protocol liquidity line — confirmed, and it is a bounded
delegate mandate.** The corpus's headline residue for SparkLend is a real,
separately-engineered subsystem: `sparkdotfi/spark-alm-controller` (AGPL-3.0,
last push `2026-06-19T14:15:58Z`), holding `ALMProxy.sol`, `ALMProxyFreezable.sol`,
`MainnetController.sol`, `ForeignController.sol`, `OTCBuffer.sol`, `RateLimits.sol`,
`RateLimitHelpers.sol`, and venue libraries for Aave, Curve, Uniswap V4, CCTP,
LayerZero, ERC-4626 and the PSM. So the "liquidity layer" is an **operator that
moves Sky-issued liquidity across a whitelisted set of external venues**, of
which SparkLend is one — and its authority is bounded by a dedicated
`RateLimits` module (§Finding 2.5 for the five parts). The D3M's *rate-targeting*
objective, and which venues are live, remain **UNKNOWN** (`MainnetController.sol`
not read).

**Control plane.** Aave V3's `ACLManager` roles, plus a purpose-built and
unusually explicit control-plane estate, all AGPL-3.0, all in the `sparkdotfi`
org (metadata accessed 2026-08-04):
`sparklend-freezer`, `sparklend-kill-switch`, `sparklend-cap-automator`,
`sparklend-health-checker`, `spark-gov-relay` (cross-chain governance),
`spark-spells` (executable governance payloads), `upgradeable-proxy`,
`mainnet-invariants`. Governance is Sky's; **who holds each key and how many of
them there are is UNKNOWN** (not fetched on-chain).

**The cap automator is a bounded delegate over caps** — see Finding 2.

**Price sources.** `sparklend-advanced/src/` also holds the oracle estate:
`WSTETHExchangeRateOracle`, `RETHExchangeRateOracle`, `WEETHExchangeRateOracle`,
`EZETHExchangeRateOracle`, `RSETHExchangeRateOracle`, `SPETHExchangeRateOracle`,
`CBBTCRatioOracle`, `FixedPriceOracle`, `CappedOracle`, `MorphoUpgradableOracle`.
Note `MorphoUpgradableOracle` — Spark supplies oracles *into Morpho markets*,
which is a containment relation between two targets in this same lane.

### 3.3 REPO

- Core fork: `https://github.com/sparkdotfi/sparklend-v1-core` — **default
  branch `dev`, not `main`**; last push `2026-07-28T02:19:46Z`; language
  reported by GitHub as **TypeScript** (the test-suite dominates by bytes;
  the contracts are Solidity under `contracts/`); licence `NOASSERTION`.
  Layout: `contracts/{protocol,interfaces,flashloan,misc,mocks,dependencies,deployments}`,
  `certora/`, `test-suites/`.
- Rate + oracle layer: `https://github.com/sparkdotfi/sparklend-advanced` —
  **AGPL-3.0**, last push `2026-03-02T14:13:32Z`.
- Cap automation: `https://github.com/sparkdotfi/sparklend-cap-automator` —
  **AGPL-3.0**, last push `2026-04-20T12:42:13Z`.
- Liquidity layer: `https://github.com/sparkdotfi/spark-alm-controller` and
  `https://github.com/sparkdotfi/spark-alm-rate-limits` — both **AGPL-3.0**.

**Organisation note, and a DELTA:** the org is **`sparkdotfi`**. The corpus-era
`marsfoundation` org path is not where this code lives now.

**Correspondence: asserted, not proved.** Not checked against bytecode. The
`sparklend-deployments` repo (AGPL-3.0) exists and was not read.

### 3.4 EVIDENCE

| claim | source | accessed |
|---|---|---|
| fork structure, Aave-V3 file layout, `DefaultReserveInterestRateStrategy` (V1 shape) | `https://api.github.com/repos/sparkdotfi/sparklend-v1-core/git/trees/dev?recursive=1` | 2026-08-04 |
| rate pegged to a rate source, immutable spread, signed slope-1 spread | `https://raw.githubusercontent.com/sparkdotfi/sparklend-advanced/master/src/RateTargetBaseInterestRateStrategy.sol` and `.../RateTargetKinkInterestRateStrategy.sol` | 2026-08-04 |
| DSR and SSR read directly from Sky accumulators | `https://raw.githubusercontent.com/sparkdotfi/sparklend-advanced/master/src/PotRateSource.sol` and `.../SSRRateSource.sol` | 2026-08-04 |
| cap automator roles, bounds, cooldown | `https://raw.githubusercontent.com/sparkdotfi/sparklend-cap-automator/master/src/CapAutomator.sol` | 2026-08-04 |
| org inventory: freezer, kill-switch, ALM controller, ALM rate limits, spells, licences, push dates | `https://api.github.com/orgs/sparkdotfi/repos?per_page=100` | 2026-08-04 |
| core repo metadata, default branch `dev` | `https://api.github.com/repos/sparkdotfi/sparklend-v1-core` | 2026-08-04 |
| ALM controller file inventory (proxy, controllers, OTC buffer, rate limits, venue libraries) | `https://api.github.com/repos/sparkdotfi/spark-alm-controller/git/trees/master?recursive=1` | 2026-08-04 |
| token-bucket rate limiter: `maxAmount`/`slope`, `CONTROLLER` role, `setUnlimitedRateLimitData` | `https://raw.githubusercontent.com/sparkdotfi/spark-alm-controller/master/src/RateLimits.sol` | 2026-08-04 |

**Not verified:** the D3M's rate-targeting objective and which venues are live
(`MainnetController.sol` not read); any deployed address; the live SSR value;
whether the rate-target strategies are actually attached to the live USDS/DAI
reserves.

### 3.5 WHAT LOOKS UNNAMEABLE

1. **A rate defined as a spread over another protocol's state variable.** This
   is not `Ex` — no oracle, no feed, no medianizer; it is a direct `staticcall`
   into Sky's `Pot`/`sUSDS`. It is not `Ix` either. The vocabulary has no way to
   say "this protocol's price is a function of that protocol's price".
2. **A parameter whose only mutation path is redeployment.** `immutable` spreads
   mean the *changeable* thing is the contract address in a reserve's config.
   `Up` names a mutable implementation; this is the opposite — an immutable
   implementation behind a mutable pointer, which is a different risk object.
3. **A protocol-to-protocol liquidity line.** Confirms the corpus verbatim: not
   `Pl` (no depositor), not `Em`, not `Ps`, not `Cd`. And now with a second half
   the corpus did not record — the line is **rate-limited**, i.e. it is itself a
   bounded delegate mandate (Finding 2).
4. **A fork's dependence on its upstream.** Confirms the corpus, and there is
   now a second dependence to name: SparkLend depends on *Aave* for its code and
   on *Sky* for its price. Two different containment relations, neither
   expressible.
5. **A cap that moves itself.** See Finding 2 — the cap automator is a control
   loop over a risk parameter.
6. **Supplying an oracle into a competitor.** `MorphoUpgradableOracle` in
   Spark's repo means one lane target is a price input to another.

### 3.6 DELTA

- **The corpus's `identicalClaimedByLane: [["Aave V3","SparkLend"]]` is
  refuted at the mechanism level, on the one axis the category residue says
  matters most.** The corpus itself argues the vocabulary's blind spot is the
  interest-rate model. Once you look at it: Aave V3 runs a *mutable-parameter,
  bounded, governed* kinked curve (`setInterestRateParams`, `MAX_BORROW_RATE`,
  Risk Steward step limits); SparkLend runs an *immutable-spread curve pegged
  live to an external protocol's savings rate*. Same functional form, entirely
  different instrument, different party in control, different change latency.
  The identity claim survives only because the vocabulary cannot see rates —
  which is precisely the corpus's own thesis, now demonstrated rather than
  asserted. *Sources: Aave `DefaultReserveInterestRateStrategyV2.sol` and Spark
  `RateTargetKinkInterestRateStrategy.sol` / `SSRRateSource.sol`, both accessed
  2026-08-04.*
- **The corpus says SparkLend's "element set is a strict subset of Aave V3's,
  containing no symbol Aave lacks."** Not contradicted symbol-by-symbol, but
  the corpus assigns SparkLend `Up` and not `Bs`/`Cd`/`Fd`/`Sl`/`Xm`, which is
  consistent. What the record misses is that SparkLend carries an *additional
  control-plane estate Aave does not have an analogue for* (kill switch,
  freezer, cap automator as separate audited repositories). Subset in symbols,
  superset in control machinery.
- **Repository location is stale.** Org is `sparkdotfi`; default branch of the
  core is `dev`.
- **The corpus records the D3M residue but not that the liquidity line is
  rate-limited by a dedicated module** (`spark-alm-rate-limits`). That converts
  the finding from "an unnameable facility" to "an unnameable facility governed
  by the same five-part shape found in three other lanes".

---

## 4 · JustLend V1

### 4.1 WHAT IT DOES

JustLend is a **Compound V2 fork on TRON**, confirmed file-by-file. A supplier
deposits into a per-asset market and receives a **jToken** (`CErc20` /
`CEther` / `CTokenERC777` in the source), a pro-rata claim whose redemption
value rises through a growing exchange rate rather than through a growing
balance. A borrower enters markets via the `Comptroller`, which computes
account liquidity from each collateral's `collateralFactorMantissa`, and calls
`borrow`. Loans have no maturity. Interest accrues **per block** into
`borrowIndex`. Monitoring is the Comptroller's shortfall computation; closing is
`liquidateBorrow`, in which a liquidator repays at most `closeFactorMantissa` of
the outstanding borrow and seizes collateral worth
`repayAmount · liquidationIncentive · priceBorrowed / priceCollateral`.
*Source: `https://api.github.com/repos/justlend/justlend-protocol/git/trees/main?recursive=1` and the contract sources below, accessed 2026-08-04.*

### 4.2 DESIGN

**Interest-rate model — complete, from source.** `BaseJumpRateModelV2.sol`
(`justlend/justlend-protocol`, `main`, fetched 2026-08-04) — Compound's
"JumpRateModel V2, modified by Dharma Labs, refactored by Arr00", per the file's
own header. State: `baseRatePerBlock`, `multiplierPerBlock`,
`jumpMultiplierPerBlock`, `kink`, `owner`.

```
util = borrows · 1e18 / (cash + borrows − reserves)

if util <= kink:  borrowRate = util·multiplierPerBlock/1e18 + baseRatePerBlock
else:             borrowRate = (util − kink)·jumpMultiplierPerBlock/1e18
                             + (kink·multiplierPerBlock/1e18 + baseRatePerBlock)

supplyRate = util · (borrowRate · (1 − reserveFactor)) / 1e18
```

`blocksPerYear = 10_512_000` — this is the TRON adaptation, matching 3-second
blocks (365·24·3600/3), against Compound's Ethereum value. Rates are quoted and
accrued **per block**, not per second, which makes the realised APR a function
of chain block time.

**The governance property is the opposite of Aave's, and this is the finding.**
`updateJumpRateModel(baseRatePerYear, multiplierPerYear, jumpMultiplierPerYear, kink_)`
is guarded by exactly one line —
`require(msg.sender == owner, "only the owner may call this function.")` —
and the header comments identify the owner as "the Timelock contract, which can
update parameters directly". There is **no bound of any kind**: no maximum rate,
no minimum or maximum kink, no requirement that the jump multiplier exceed the
normal multiplier, no step limit, no debounce. The only protection is the
Timelock's delay. Aave bounds the *values* and (via the steward) the *step*;
JustLend bounds only the *timing*.

**Solvency — from source.** `Comptroller.sol` (fetched 2026-08-04) declares:

| bound | value |
|---|---|
| `closeFactorMinMantissa` | `0.05e18` (5%) |
| `closeFactorMaxMantissa` | `0.9e18` (90%) |
| `collateralFactorMaxMantissa` | `0.9e18` (90%) |
| `liquidationIncentiveMinMantissa` | `1.0e18` |
| `liquidationIncentiveMaxMantissa` | `1.5e18` |

So the risk parameters *are* bounded in code while the rate parameters are not —
a split the corpus does not record. `maxClose = closeFactorMantissa ·
borrowBalance`; seize amount as quoted in §4.1.

**Control plane.** `Unitroller` (the storage/proxy pair Compound uses for the
Comptroller) plus `CErc20Delegator`/`CErc20Delegate` (per-market upgradeable
delegate), `Timelock.sol`, `Governance/Bravo/GovernorBravoDelegate.sol`,
`Governance/GovernorAlpha.sol`, `Governance/Comp.sol` (the JST/WJST governance
token, with `WJST.sol`), and a `pauseGuardian`. The `Comptroller` guards
`_setCloseFactor` and siblings with `msg.sender != admin` checks. The repository
also carries **committed governance proposals as Solidity contracts**
(`Governance/ProposalAddEthMarket.sol`, `ProposalAddUsdcMarket.sol`,
`ProposalOldSunCollaterFactor.sol`, `ProposalOldSunReserveFactor.sol`, and
others) — the executed policy history is in the repo.
**Who holds `admin`, and whether the Timelock is genuinely the owner of the rate
models on the live TRON deployment, is UNKNOWN** — not checked on chain.

**Price sources.** `PriceOracle.sol`, `PriceOracleProxy.sol`,
`PriceOracle/PriceOracleV1.sol`, `PriceOracle/DSValue.sol`, `SimplePriceOracle.sol`.
`DSValue` is a Maker-lineage single-writer push oracle. Which of these is live is
**UNKNOWN**.

**Not found in the repository: the TRX energy/bandwidth rental market.** The
corpus records it as JustLend residue. The 52 Solidity files in
`justlend/justlend-protocol` are Compound V2 and nothing else — no resource-rental
contract. It is either in a different repository or not open-sourced. Recorded
as **UNCONFIRMED IN-REPO**, not refuted.

### 4.3 REPO

`https://github.com/justlend/justlend-protocol` — default branch `main`, last
push `2026-03-24T03:09:53Z`, Solidity, 38 stars, **licence: none declared**
(GitHub API `license: null`). Solidity pragma `^0.5.12` — an old compiler line,
consistent with a 2020-era Compound V2 fork carried forward. 52 `.sol` files,
flat under `contracts/` with `Governance/`, `PriceOracle/`, `Lens/`
subdirectories.

**A licence finding worth carrying to the paper.** Compound V2's own code is
BSD-3-Clause; this fork **declares no licence at all**, which under default
copyright means no grant of reproduction rights. That is the same class of
constraint the spot-exchange lane found at Curve (all-rights-reserved), and it
constrains what may be reproduced in `atlas.tex`. *Source:
`https://api.github.com/repos/justlend/justlend-protocol`, accessed 2026-08-04.*

Related org repos (accessed 2026-08-04): `justlend/justlend-interface`
(Apache-2.0), `justlend/justlend-docs` (no licence, last push
`2026-08-04T08:02:46Z`), `justlend/mcp-server-justlend` (MIT),
`justlend/justlend-skills` (MIT).

**Correspondence: asserted, not proved, and weakest of the five.** JustLend is
deployed on TRON; nothing in this run compared the repository to on-chain TVM
bytecode, and TRON verification tooling was not exercised. The repository's last
push (2026-03-24) is also the oldest of the five targets.

### 4.4 EVIDENCE

| claim | source | accessed |
|---|---|---|
| Compound V2 fork: file inventory, `CToken`, `Comptroller`, `Unitroller`, `GovernorBravo`, `Timelock`, proposals | `https://api.github.com/repos/justlend/justlend-protocol/git/trees/main?recursive=1` | 2026-08-04 |
| jump-rate formula, `blocksPerYear = 10_512_000`, unbounded `updateJumpRateModel`, owner = Timelock | `https://raw.githubusercontent.com/justlend/justlend-protocol/main/contracts/BaseJumpRateModelV2.sol` | 2026-08-04 |
| close-factor / collateral-factor / liquidation-incentive bounds, seize formula, `admin` checks | `https://raw.githubusercontent.com/justlend/justlend-protocol/main/contracts/Comptroller.sol` | 2026-08-04 |
| repo metadata, **no declared licence**, branch, push date | `https://api.github.com/repos/justlend/justlend-protocol` | 2026-08-04 |
| org repo inventory | `https://api.github.com/search/repositories?q=justlend` | 2026-08-04 |

**Not verified:** every deployed TRON address; whether `main` corresponds to the
live deployment; the identity of `admin`; the energy-rental product; TVL.

### 4.5 WHAT LOOKS UNNAMEABLE

1. **A rate quoted per block.** Every other target quotes per second or per
   year. A rate denominated in blocks makes the realised APR depend on the
   chain's block production, which is a *consensus* property leaking into a
   *credit* parameter. No symbol in the vocabulary touches block time.
2. **An unbounded governed parameter.** The interesting fact is the *absence* of
   a bound where three sibling protocols have one. The vocabulary can record
   that `Tg` is present; it cannot record that the timelock is the **only**
   protection, which is the entire risk statement.
3. **The close factor**, confirming the corpus — and now with the added fact
   that JustLend's is a *constant* within `[5%, 90%]` while Aave's is a
   *function of health factor and position size*. One gap, two shapes.
4. **A liquidation incentive bounded in `[1.0, 1.5]`** — a multiplicative
   seize premium with an explicit permitted interval.
5. **Renting a chain resource** (energy/bandwidth) — corpus residue, not
   confirmed in-repo, but if real it is `Pl` over a non-fungible per-account
   execution allowance, which `Pl` cannot mean.
6. **Executed policy as committed code.** The `Governance/Proposal*.sol` files
   make the parameter history a repository artefact. Nothing names "the record
   of exercised authority" as distinct from the authority.

### 4.6 DELTA

- **The corpus's close-factor residue is filed as JustLend-specific
  ("every Compound descendant has it"). It is category-wide.** Aave V3 has a
  close factor too, dynamic rather than constant (§1.2). Re-site as a category
  residue with two distinct shapes.
- **The corpus does not record that JustLend's rate parameters are wholly
  unbounded while its risk parameters are bounded.** This is the sharpest
  contrast in Finding 1 and it is invisible in the corpus record, which assigns
  JustLend the same "same interest-rate-model residue" line as everyone else.
- **The corpus does not record the licence.** There is none. This is a
  reproduction constraint on the paper.
- **The TRX energy/bandwidth market is not in the protocol repository.**
  Corpus lists it as residue. Marked UNCONFIRMED IN-REPO pending a source.

---

## 5 · Maple

### 5.1 WHAT IT DOES

A lender deposits a single asset (USDC, or the relevant pool asset) into a
`MaplePool`, an **ERC-4626** vault, and receives pool shares; entry is gated by
a `PoolPermissionManager`, so the lender is not anonymous. The money is not lent
by a curve — a named **pool delegate** originates loans to named institutional
borrowers, and funds them by calling into a loan manager, which moves principal
out of the pool to the borrower. Loans are **maturity-dated** and come in two
kinds in the source, *fixed-term* (`maple-labs/fixed-term-loan`) and *open-term*
(`maple-labs/open-term-loan`). Pricing is per loan, written into the loan
contract at origination, not derived from utilisation. Monitoring is partly
on-chain (`impair`, `triggerDefault`) and partly off-chain — the delegate
watches collateral, which for the secured book sits with third-party
custodians. Closing is by repayment, by refinance (the repo carries a
`RefinanceScenario.t.sol` end-to-end test), or by the delegate calling
`triggerDefault`, which routes through a `LIQUIDATOR_FACTORY` instance and then
`finishCollateralLiquidation`. Losses hit the **pool delegate's cover** first
(`MaplePoolDelegateCover`), then the pool. Withdrawals are not immediate: a
`WithdrawalManager` — the org ships both a cyclical and a queue implementation —
governs exit.
*Sources: `maple-labs/pool-v2` tree and `MaplePoolManager.sol`; `maple-labs`
org inventory; all accessed 2026-08-04.*

### 5.2 DESIGN

**Named contracts and what each holds.** From the `maple-labs` org inventory and
the `pool-v2` tree (accessed 2026-08-04):

| contract / repo | holds |
|---|---|
| `MaplePool` (`pool-v2`) | ERC-4626 share accounting over the pool asset |
| `MaplePoolManager` (`pool-v2`) | the delegate, the strategy whitelist, `liquidityCap`, `delegateManagementFeeRate`, the loan-default entry points |
| `MaplePoolDelegateCover` (`pool-v2`) | the delegate's first-loss capital |
| `MaplePoolDeployer`, `MaplePoolManagerFactory` | instantiation |
| `globals-v2` (`MapleGlobals`) | protocol-wide registry: `governor`, `securityAdmin`, `operationalAdmin`, valid-instance registry, `minCoverAmount`, `maxCoverLiquidationPercent`, scheduled calls |
| `fixed-term-loan`, `open-term-loan` | the loan terms themselves |
| `fixed-term-loan-manager`, `open-term-loan-manager` | accrual and accounting of a loan set into the pool |
| `liquidations` | the liquidator instances |
| `pool-permission-manager` | who may deposit |
| `withdrawal-manager-queue`, `withdrawal-manager-cyclical` | exit |
| `maple-strategies` | pool capital deployed into external strategies |

**Interest-rate model — and this is the answer to Finding 1 for Maple: there is
no curve, there is a term sheet.** No utilisation curve exists anywhere in the
pool layer. `MaplePoolManager` contains no rate parameter at all; the only
rate-like quantity it holds is `delegateManagementFeeRate`, bounded by
`HUNDRED_PERCENT = 100_0000` (four decimal precision). The price of credit lives
in the loan contract. `MapleLoanStorage.sol` (`maple-labs/fixed-term-loan`,
`main`, fetched 2026-08-04) declares the loan's fields verbatim:

```
// Roles
_borrower, _lender, _pendingBorrower, _pendingLender
// Loan Term Parameters
_gracePeriod          // seconds a payment can be late
_paymentInterval      // seconds between payments
// Rates
_interestRate             // "The annualized interest rate of the loan."
_closingRate              // fee rate applied to principal to close the loan
_lateFeeRate              // fee rate for late payments
_lateInterestPremiumRate  // amount to increase the interest rate by for late payments
// Requested Amounts
_collateralRequired, _principalRequested, _endingPrincipal
// State
_nextPaymentDueDate, _paymentsRemaining, _principal, _collateral, _drawableFunds
// Refinance
_refinanceCommitment  // keccak256 of proposed refinance terms
_refinanceInterest
_loanTermsAccepted    // terms must be accepted before the loan is funded
```

So Maple's instrument is a **fixed annualised rate agreed bilaterally**, with a
payment schedule (`_paymentInterval`, `_paymentsRemaining`), a balloon
(`_endingPrincipal`), a grace period, and a **penalty rate that steps up on
delinquency** (`_lateFeeRate` plus `_lateInterestPremiumRate`). Both sides of
the loan are named and transferable (`_pendingBorrower` / `_pendingLender`), and
a change of terms is a `refinance` committed by hash. This is not a lending-pool
price; it is a bond indenture. Neither party is the protocol: the rate is set by
the delegate and the borrower and merely *stored* on-chain.

**Liquidation path — from source.** `MaplePoolManager.sol` (fetched 2026-08-04):
`triggerDefault(loan_, liquidatorFactory_)` requires
`IGlobalsLike(globals()).isInstanceOf("LIQUIDATOR_FACTORY", liquidatorFactory_)`
and is `onlyPoolDelegateOrProtocolAdmins`; it may return with
`liquidationComplete_ == false`, emitting `CollateralLiquidationTriggered` and
returning — i.e. **liquidation is a multi-transaction, possibly multi-day
process**, closed later by `finishCollateralLiquidation`, also
`onlyPoolDelegateOrProtocolAdmins`. Both paths end in `_handleCover(losses_,
platformFees_)`, which draws from `poolDelegateCover` up to
`balanceOf(poolDelegateCover) · maxCoverLiquidationPercent / HUNDRED_PERCENT`,
sending part to `mapleTreasury()` and part to the pool. There is **no
third-party liquidator incentive and no permissionless liquidation call** in
this contract: closing an underwater loan is an authorised act by a named party,
not a race.

**Funding.** `requestFunds` requires the caller be a registered `STRATEGY_FACTORY`
instance and `isStrategy[msg.sender]`, that pool supply be non-zero, and —
crucially — `_hasSufficientCover(globals, asset)`. **The delegate cannot
originate a loan unless its own first-loss cover is above the protocol's
`minCoverAmount`.** It also enforces `balanceOf(pool) >= lockedLiquidity_` after
the transfer, protecting queued withdrawals.

**Control plane, with the split stated exactly** (all from
`MaplePoolManager.sol`, 2026-08-04):

| power | who |
|---|---|
| `setIsStrategy`, `setPendingPoolDelegate` | `onlyPoolDelegateOrProtocolAdmins` |
| `triggerDefault`, `finishCollateralLiquidation` | `onlyPoolDelegateOrProtocolAdmins` |
| `withdrawCover` | `onlyPoolDelegate`, floored at `minCoverAmount` |
| **`setLiquidityCap`** | `onlyProtocolAdminsOrNotConfigured` |
| **`setDelegateManagementFeeRate`** | `onlyProtocolAdminsOrNotConfigured`, ≤ `HUNDRED_PERCENT` |
| `setPoolPermissionManager` | `onlyProtocolAdminsOrNotConfigured` |
| `setWithdrawalManager` | `onlyIfNotConfigured` |
| `setActive` | `msg.sender == globals()` |
| `upgrade` | delegate **only via** `globals_.isValidScheduledCall(…, "PM:UPGRADE", msg.data)`; otherwise `globals_.securityAdmin()` |
| `setImplementation` | `msg.sender == _factory()` |
| everything | `whenNotPaused` (protocol-wide pause in Globals) |

The two rows in bold are the finding: **after configuration the pool delegate
cannot raise its own cap and cannot set its own fee.** Both migrate to Maple's
protocol admins. The `governor()` is read from `MapleGlobals`. **How many keys,
and who holds `governor` / `securityAdmin` / `operationalAdmin`, is UNKNOWN** —
not checked on-chain.

**Price sources and custody.** Not established in this run. `MaplePoolManager`
holds no oracle. Where collateral valuation comes from for the secured book, and
which custodians hold it, are **UNKNOWN** — the corpus names BitGo/Anchorage/
Copper and I could not reach a primary source for that in this run.

**Invariants asserted.** `maple-core-v2` ships `tests/fuzz/` (including
`ClosePoolFuzz.t.sol`, `Impair.t.sol`, `HasPermission.t.sol`), `scenarios/`, and
`tests/e2e/` (`PoolLifecycle`, `RefinanceScenario`, `WithdrawManagerScenario`,
`MultiLoanManager`, `StrategyScenarios`, `DelayedWithdrawal`, `GlobalPermission`),
plus a `maple-labs/maple-v2-audits` repository. The specific invariants were not
read — **UNKNOWN**.

### 5.3 REPO

Maple is **not one repository**; `maple-core-v2` is the integration and test
harness (`contracts/ProtocolActions.sol`, `contracts/Runner.sol`,
`contracts/Contracts@7.sol`, `Contracts@25.sol`, plus `tests/`, `scenarios/`,
`scripts/`), while the product lives in ~15 sibling repositories.

| repo | licence | last push |
|---|---|---|
| `maple-labs/maple-core-v2` | `NOASSERTION` | 2026-05-28T12:29:52Z |
| `maple-labs/pool-v2` | `NOASSERTION` | 2025-05-25T09:21:09Z |
| `maple-labs/globals-v2` | `NOASSERTION` | 2025-09-25T06:46:02Z |
| `maple-labs/fixed-term-loan` | `NOASSERTION` | 2025-05-25T08:35:00Z |
| `maple-labs/open-term-loan` | `NOASSERTION` | 2025-05-25T09:02:00Z |
| `maple-labs/liquidations` | `NOASSERTION` | 2025-05-25T08:57:51Z |
| `maple-labs/pool-permission-manager` | `NOASSERTION` | 2025-05-25T08:18:05Z |
| `maple-labs/withdrawal-manager-queue` | `NOASSERTION` | 2025-11-27T14:20:22Z |
| `maple-labs/maple-strategies` | `NOASSERTION` | 2025-05-25T09:32:55Z |
| `maple-labs/syrup-utils` | `NOASSERTION` | 2026-07-31T07:18:55Z |

Note the shape: **the core lending modules have not been pushed since May 2025**,
while the periphery (`syrup-utils`, `maple-js`, `address-registry`) is current.
That is consistent with a frozen, audited core — but it is also exactly the
pattern that makes a `main`-branch citation risky in the other direction (the
deployed contracts may be *ahead* of, or behind, these trees).

**Licence, and this is a reproduction constraint on the paper.** The GitHub API
reports `NOASSERTION` across the product because the licence files are custom.
Reading the source resolves it: `MapleLoanStorage.sol` carries
`// SPDX-License-Identifier: BUSL-1.1` (accessed 2026-08-04). Maple's loan core
is **Business Source License 1.1**, not an open-source licence. Some sibling
repos (`erc20`, `maple-proxy-factory`, `stSyrup`) are AGPL-3.0. So the licence
is **per-module and mixed**, and any reproduction of loan-layer source in
`atlas.tex` must respect BUSL-1.1. This is the third licence trap in the run,
after Curve's all-rights-reserved (spot-exchange lane) and JustLend's absent
licence (§4.3).

Two org repos worth recording: `maple-labs/morpho-blue-reward-programs` (MIT)
and `maple-labs/DefiLlama-Adapters` — **Maple runs reward programmes on Morpho
Blue**, another containment relation between two targets in this lane.

**Correspondence: asserted, not proved.** `maple-labs/address-registry` exists
and was not read; no bytecode comparison performed.

### 5.4 EVIDENCE

| claim | source | accessed |
|---|---|---|
| pool-v2 contract inventory | `https://api.github.com/repos/maple-labs/pool-v2/git/trees/main?recursive=1` | 2026-08-04 |
| delegate powers, modifiers, `HUNDRED_PERCENT`, cover handling, `requestFunds` cover check, `triggerDefault`, upgrade-via-scheduled-call | `https://raw.githubusercontent.com/maple-labs/pool-v2/main/contracts/MaplePoolManager.sol` | 2026-08-04 |
| module repos, licences, push dates | `https://api.github.com/orgs/maple-labs/repos?per_page=100&sort=pushed` | 2026-08-04 |
| core-v2 layout, e2e/fuzz test inventory | `https://api.github.com/repos/maple-labs/maple-core-v2/git/trees/main?recursive=1` | 2026-08-04 |
| core-v2 metadata | `https://api.github.com/repos/maple-labs/maple-core-v2` | 2026-08-04 |
| loan term fields, rates, refinance commitment, **BUSL-1.1 SPDX header** | `https://raw.githubusercontent.com/maple-labs/fixed-term-loan/main/contracts/MapleLoanStorage.sol` | 2026-08-04 |
| fixed-term-loan module inventory (loan, factory, fee manager, refinancer, migrators) | `https://api.github.com/repos/maple-labs/fixed-term-loan/git/trees/main?recursive=1` | 2026-08-04 |

**Not verified:** who sets `_interestRate` in practice and under what process
(`MapleLoan.sol` / `MapleLoanInitializer.sol` not read); custodian identities;
the legal-recourse layer; any deployed address; TVL; the `globals-v2` timelock
durations for scheduled calls.

### 5.5 WHAT LOOKS UNNAMEABLE

1. **A price of credit that is not a protocol object at all.** Maple has no rate
   instrument. The rate is a term of a bilateral contract. Every other target in
   this lane has a curve; Maple has a negotiation. The vocabulary cannot record
   "this quantity is determined outside the protocol and merely stored".
2. **Bonded discretion.** `_hasSufficientCover` makes origination conditional on
   the delegate's own first-loss capital exceeding `minCoverAmount`. This is
   `Bs` and `Sv` *coupled* — authority whose precondition is stake. Neither
   symbol carries the coupling, and the coupling is the mechanism.
3. **A liquidation that is authorised rather than incentivised.**
   `triggerDefault` is `onlyPoolDelegateOrProtocolAdmins`, may complete over
   multiple transactions, and pays no caller bounty in this contract. `Li`
   ("third parties paid to close positions") is wrong in *both* clauses.
4. **A configuration epoch.** `onlyIfNotConfigured` /
   `onlyProtocolAdminsOrNotConfigured` mean several powers exist only *before*
   `completeConfiguration()` and then move to a different party or vanish. A
   permission that expires at a lifecycle boundary has no symbol; `Ep` names an
   epoch-gated *transition*, not an epoch-gated *authority*.
5. **A whitelist by type rather than by address.**
   `globals.isInstanceOf("LIQUIDATOR_FACTORY", x)` /
   `"STRATEGY_FACTORY"` / `"WITHDRAWAL_MANAGER_FACTORY"` gates by *registered
   kind*, not by enumerated address. `Aw` names an identity gate over users.
6. **Off-chain legal recourse, third-party custody, underwriting, delegate
   fees** — all four corpus residues stand; none reachable from source, which is
   itself the point: the mechanism is not in the code.
7. **A protocol with no permissionless action on the credit side at all.**
   Deposit is gated, origination is delegated, default is authorised. The only
   permissionless act is exit, and that is queued.

### 5.6 DELTA

- **The corpus says of the pool delegate: "accountable only reputationally" is
  the framing of the cross-lane finding, and at Maple that is false.** The
  delegate posts `poolDelegateCover`, cannot originate below `minCoverAmount`
  (`requestFunds` → `_hasSufficientCover`), cannot withdraw cover below it
  (`withdrawCover`), and its cover is drawn down **first** on a loss up to
  `maxCoverLiquidationPercent`. Maple's delegate is bonded, not merely
  reputable. *Source: `MaplePoolManager.sol`, accessed 2026-08-04.*
- **The corpus residue "no element for management and performance fees charged
  on a lending pool by its operator" needs a correction of fact:**
  `setDelegateManagementFeeRate` is **`onlyProtocolAdminsOrNotConfigured`**, so
  after configuration the operator does **not** set its own fee — Maple's
  protocol admins do. The residue (no symbol for the fee) stands; the implied
  agency does not.
- **Same for the cap.** `setLiquidityCap` is `onlyProtocolAdminsOrNotConfigured`.
  The delegate does not size its own pool.
- **`satisfiesRequirementsAndWarrants: false` for Maple.** Not evaluated here —
  outside this lane's scope (no decomposition, no tables) — but note that the
  reason offered in the corpus markers is that `Ct` and `Li` are FORCED. The
  source supports something stronger than "forced": `Li`'s definition, "third
  parties paid to close positions", is contradicted clause-by-clause by
  `triggerDefault`'s access control. This looks like the **options lane's
  "discharge by construction"** in mirror image — not an obligation closed by
  construction, but an element *asserted* where the mechanism is absent.
- **The corpus lists `Ft` (fixed-term debt) for Maple.** Confirmed and
  refined: there are **two** loan modules, `fixed-term-loan` and
  `open-term-loan`, i.e. part of the book is *not* maturity-dated. `Ft` covers
  half the product.
- **The corpus records Maple's collateral as at BitGo/Anchorage/Copper.**
  Not reachable from a primary source in this run. **UNCONFIRMED**, not refuted.

---

# FINDING 1 — THE PRICE OF CREDIT

**Verdict: the rate gap is several gaps, not one — and lending on its own
exhibits at least four distinct instruments among five protocols, one of which
is "no instrument at all".** The CDP lane found four among five. The two lanes
do **not** find the same four. Taken together the run has now seen at least six
distinguishable rate instruments across two categories, and the corpus's single
line — "no element for the utilization-indexed interest-rate curve" — collapses
all of them.

All five run *something* on the borrow side, but only three of the five run a
utilisation curve whose parameters any party may set, and no two of those three
are governed the same way.

| | functional form | who may change parameters | bounds on the value | delay / step limit |
|---|---|---|---|---|
| **Aave V3** | two-slope kinked, memoryless function of `U_b` | `PoolConfigurator` (`onlyPoolConfigurator` on the strategy); in practice `POOL_ADMIN`/`RISK_ADMIN`, **and the Risk Council within a bounded mandate** | **hard, in code**: `base+slope1+slope2 ≤ 1000%`; kink ∈ [1%,99%]; `slope1 ≤ slope2` | none in the strategy; **`minDelay` debounce + `maxPercentChange` step** in `RiskSteward` |
| **Morpho** | **closed-loop controller**: static curve of steepness 4 around a `rateAtTarget` that itself drifts at `ADJUSTMENT_SPEED · err` toward 90% utilisation | **nobody.** All parameters are `constant`; the contract has no setter and no admin | `rateAtTarget ∈ [0.1%, 200%]`/yr, realised ∈ [0.025%, 800%]/yr, in code | not applicable — the *rate* moves continuously by design; the *policy* never moves |
| **SparkLend** | two-slope kinked, but base and/or kink are **a live spread over Sky's DSR/SSR**, read on every call | nobody, in place. The spreads are `immutable`; change = deploy a new strategy and repoint the reserve via a governance spell | none on the spread; the level inherits whatever Sky sets | Sky's own governance delay on the SSR; SparkLend's spell process for the spread |
| **JustLend V1** | two-slope jump-rate, **per block** (`blocksPerYear = 10_512_000`) | `owner` — commented as the Timelock — via `updateJumpRateModel` | **none. No maximum rate, no kink bounds, no shape constraint** | the Timelock delay only |
| **Maple** | **no curve.** A fixed annualised `_interestRate` plus `_lateFeeRate` and `_lateInterestPremiumRate` on a `_paymentInterval` schedule with `_gracePeriod` and `_endingPrincipal` — a bond indenture | the pool delegate and the borrower, bilaterally, at origination; changed only by `refinance` (committed by hash, `_refinanceCommitment`) and only with `_loanTermsAccepted` | none in the loan contract | not applicable — the rate does not move until the parties agree a refinance |

**What separates them, stated so the paper can use it.** Four axes, and no two
protocols agree on all four:

1. **Memory.** Aave, SparkLend and JustLend price from *current* utilisation.
   Morpho prices from the *history* of utilisation through a stateful
   `rateAtTarget`. This is the difference between a function and a controller
   and no symbol distinguishes them.
2. **Locus of the setter.** Aave: a mutable parameter inside the protocol.
   Morpho: a compile-time constant. SparkLend: another protocol's state
   variable. JustLend: a mutable parameter inside the protocol. Maple: a
   counterparty. Five protocols, five different loci — and this axis alone
   defeats any single-element repair.
3. **Bounding.** Aave bounds levels in code *and* steps via a steward. Morpho
   bounds the controller's output in code. JustLend bounds nothing.
   SparkLend bounds nothing on its own side and inherits Sky's.
4. **Latency of a change.** Aave: one transaction, or `minDelay` under the
   steward. Morpho: never. SparkLend: instant and automatic when Sky moves;
   a deployment cycle when Spark moves. JustLend: a timelock. Maple: a
   refinance.

**Cross-check against the CDP lane's four.** The CDP lane found (1) a bounded
delegate rate setter, (2) a rate keyed to external benchmarks, (3) a closed-loop
controller on **peg error**, (4) borrower-chosen rates. Lending returns:
(1) **again**, at Aave, in a more developed form — the `RiskSteward` is a
deployed bounded-delegate rate setter with a per-parameter step cap and debounce;
(2) **in a materially different variant** — SparkLend does not *administer* a
rate keyed to a benchmark, it *reads the benchmark as a function call every
time*, which is a functional dependency rather than an administrative one;
(3) **in a different variable** — Morpho is a closed-loop controller on
*utilisation* error, not peg error, which shows the controller shape is not
specific to stablecoins; (4) **in a two-sided variant** — Maple's rate is not
*borrower-chosen*, it is **bilaterally negotiated and then frozen into a loan
contract**, requiring `_loanTermsAccepted` before funding and a hash-committed
`refinance` to change. A rate one party posts and a rate two parties agree are
different instruments: the first is a unilateral offer, the second is a
contract. Lending then adds two the CDP lane did not see at all: **no
protocol-level instrument** (Maple's pool layer holds no rate at all), and **an
unbounded governed parameter** (JustLend), which differs from a bounded one in
exactly the way that matters for risk.

**So the count is not "four, again".** Taking the two lanes together the run has
now distinguished, at minimum: bounded-delegate setter; live functional
dependency on an external protocol's rate; administered benchmark peg;
closed-loop controller on peg error; closed-loop controller on utilisation
error; unbounded timelocked parameter; unilateral borrower-posted rate;
bilaterally contracted rate. **Eight instruments, and the corpus records one
residue line.**

**Consequence for stage 4.** A single new element "utilisation-indexed rate"
would name only three of these five and would name all three identically. What
the formalism needs is a *rate instrument* with at least: a form (function vs
controller), a setter locus (in-protocol constant, in-protocol variable,
external protocol, counterparty), a bound (present/absent, on level, on step),
and a latency. Note that three of those four are the same fields Finding 2
needs. **They are the same schema.**

---

# FINDING 2 — THE DELEGATED ALLOCATION MANDATE

**Verdict: found, three times independently inside this one lane, and the third
lane-level confirmation the run was waiting for.** Combined with the yield lane
(over allocations) and the CDP lane (over rates), the five-part shape

> named agent → domain whitelist → magnitude cap → rate-of-change limit or delay → revocation

now has **five independent sightings across three categories**, and in lending
the first four parts are enforced by **code**, not reputation, at every site.

## 2.1 Aave V3 — `RiskSteward`, over rates, caps, collateral parameters, e-modes and oracle caps

The cleanest instance in the run: the five parts are not merely present, they
are *factored into one reusable validator*.

```solidity
struct RiskParamConfig { uint40 minDelay; uint256 maxPercentChange; }

function _validateParamUpdate(ParamUpdateValidationInput memory validationParam) internal view {
    if (validationParam.newValue == EngineFlags.KEEP_CURRENT) return;
    if (block.timestamp - validationParam.lastUpdated < validationParam.riskConfig.minDelay)
      revert DebounceNotRespected();
    if (!_updateWithinAllowedRange(
          validationParam.currentValue, validationParam.newValue,
          validationParam.riskConfig.maxPercentChange, validationParam.isChangeRelative))
      revert UpdateNotInRange();
}
```

| part | mechanism | enforced by |
|---|---|---|
| **named agent** | `address public immutable RISK_COUNCIL`; `modifier onlyRiskCouncil { if (RISK_COUNCIL != msg.sender) revert InvalidCaller(); }` | **code** |
| **domain whitelist** | two layers. (a) A fixed enumerated set of updatable domains — `updateCaps`, `updateRates`, `updateCollateralSide`, `updateEModeCategories`, `updateLstPriceCaps`, `updateStablePriceCaps`, `updatePendleDiscountRates` — and nothing else exists. (b) Per-asset and per-e-mode exclusion: `_restrictedAddresses[asset]` → `revert AssetIsRestricted()`, `_restrictedEModes[id]` → `revert EModeIsRestricted()`, both written `onlyOwner`. (c) The `EdgeRiskStewardRates` / `…Caps` / `…EMode` / `…DiscountRate` variants exist so a deployment can expose **only one domain** | **code** |
| **magnitude cap** | `riskConfig.maxPercentChange` per parameter, via `_updateWithinAllowedRange`, with an `isChangeRelative` flag so the cap can be relative or absolute. Separate configs for collateral, e-mode, rate, cap and price-cap families (`Config{CollateralConfig, EmodeConfig, RateConfig, CapConfig, PriceCapConfig}`) | **code** |
| **rate-of-change limit / delay** | `riskConfig.minDelay`, checked against a **per-(asset, parameter)** `lastUpdated` — the contract keeps separate timestamps for `supplyCapLastUpdated`, `borrowCapLastUpdated`, `optimalUsageRatioLastUpdated`, `baseVariableRateLastUpdated`, `variableRateSlope1LastUpdated`, `variableRateSlope2LastUpdated`, `ltvLastUpdated`, `liquidationThresholdLastUpdated`, `liquidationBonusLastUpdated`, and e-mode equivalents | **code** |
| **revocation** | `setRiskConfig`, `setAddressRestricted`, `setEModeCategoryRestricted` are all `onlyOwner` (the DAO executor). The owner can zero the envelope or fence any asset without touching the council | **code** |
| **performance fee** | **absent.** The Risk Council is not paid by this contract | — |

A further step the other sightings do not have: `AaveStewardInjectorRates`,
`…Caps`, `…EMode`, `…DiscountRate` plus `RiskOracle.sol` and Chainlink/Gelato
automation wrappers. **The named agent can be a robot** that reads a
recommendation from a risk oracle and injects it inside the same envelope. The
mandate's holder need not be a person.

*Sources:
`https://raw.githubusercontent.com/aave-dao/aave-v3-risk-stewards/main/src/contracts/RiskSteward.sol`,
`https://raw.githubusercontent.com/aave-dao/aave-v3-risk-stewards/main/src/interfaces/IRiskSteward.sol`,
`https://api.github.com/repos/aave-dao/aave-v3-risk-stewards/git/trees/main?recursive=1`,
all accessed 2026-08-04.*

## 2.2 Morpho — MetaMorpho curator/allocator, over allocations

| part | mechanism | enforced by |
|---|---|---|
| **named agent** | `curator` (`setCurator`, `onlyOwner`) and `allocator` (`setIsAllocator`, `onlyOwner`) — **two agents with different powers**: the curator sets the envelope, the allocator moves inside it | **code** |
| **domain whitelist** | `reallocate` reverts `UnauthorizedMarket(id)` when `config[id].cap == 0`; `submitCap` rejects any market with `loanToken != asset()` or not yet created on Blue; `MAX_QUEUE_LENGTH = 30` | **code** |
| **magnitude cap** | `if (supplyAssets + suppliedAssets > supplyCap) revert SupplyCapExceeded(id)` | **code** |
| **rate-of-change limit / delay** | **asymmetric timelock — the sharpest detail in this finding.** A cap *decrease* executes immediately (`_setCap` called inline); a cap *increase* is queued (`pendingCap[id].update(newSupplyCap, timelock)`) and requires `acceptCap` after `timelock`, with `MIN_TIMELOCK = 1 days`, `MAX_TIMELOCK = 2 weeks`. Market *removal* is likewise queued (`removableAt = block.timestamp + timelock`) | **code** |
| **revocation** | `revokePendingCap` and `revokePendingMarketRemoval` (curator **or** guardian), `revokePendingTimelock`, `revokePendingGuardian` (guardian); `setCurator(address(0))` / `setIsAllocator(x,false)` by the owner | **code** |
| **performance fee** | `setFee` is **`onlyOwner`, not the curator**; `MAX_FEE = 0.5e18` (50%) | **code** |

Conservation constraint the other sightings lack: `reallocate` ends with
`if (totalWithdrawn != totalSupplied) revert InconsistentReallocation();` — the
allocator may permute the deposit across whitelisted markets and cannot move
value out of the vault in the same call.

**What is reputational at Morpho, precisely.** Not the caps and not the moves.
What no code checks is the *judgement*: whether a market the curator proposes
has a sound oracle, a sane LLTV, and a collateral asset with real liquidity.
Morpho Blue validates neither the oracle nor the collateral (§2.2), so the
curator's whitelist is the *only* risk filter, and its quality is unverifiable
on-chain. **The five parts bound the magnitude of a mistake; nothing bounds its
direction.**

*Sources: `MetaMorpho.sol` and `metamorpho/src/libraries/ConstantsLib.sol`, accessed 2026-08-04.*

## 2.3 SparkLend — `CapAutomator`, over supply and borrow caps

The third sighting, and it independently reproduces MetaMorpho's *asymmetry*.

| part | mechanism | enforced by |
|---|---|---|
| **named agent** | OpenZeppelin `AccessControlEnumerable`: `UPDATE_ROLE` (the operator/keeper) and `DEFAULT_ADMIN_ROLE` (governance, which sets the envelope). Both required non-zero at construction | **code** |
| **domain whitelist** | per-asset `supplyCapConfigs` / `borrowCapConfigs`; `_calculateNewCap` returns the current cap unchanged when `max == 0`, so an unconfigured asset is inert. `removeSupplyCapConfig` / `removeBorrowCapConfig` are `DEFAULT_ADMIN_ROLE` | **code** |
| **magnitude cap** | `max`, further bounded by `ReserveConfiguration.MAX_VALID_SUPPLY_CAP` / `MAX_VALID_BORROW_CAP`; and `gap <= max` — `gap` is the headroom the automator maintains above current usage, so `newCap = min(currentValue + gap, max)` | **code** |
| **rate-of-change limit / delay** | `increaseCooldown` seconds, tracked in `lastIncreaseTime`, **applied to increases only**: *"Cap cannot be increased before cooldown passes, but can be decreased"*. Plus a one-update-per-block guard via `lastUpdateBlock == block.number` | **code** |
| **revocation** | `removeSupplyCapConfig` / `removeBorrowCapConfig`, and `revokeRole(UPDATE_ROLE, …)` from `AccessControlEnumerable` | **code** |
| **performance fee** | **absent** | — |

Note this instance has **no discretion left at all**: the target is a pure
function of observed usage (`currentValue + gap`), so the `UPDATE_ROLE` holder
chooses only *when* to call. The mandate has been narrowed until the agent is a
crank. That is the limit case of the shape and worth recording as such.

*Source: `https://raw.githubusercontent.com/sparkdotfi/sparklend-cap-automator/master/src/CapAutomator.sol`, accessed 2026-08-04.*

## 2.4 Maple — pool delegate, over origination. Four parts, and one refutation

| part | mechanism | enforced by |
|---|---|---|
| **named agent** | `poolDelegate`, with `onlyPoolDelegate` and `onlyPoolDelegateOrProtocolAdmins`; succession via `setPendingPoolDelegate` → `acceptPoolDelegate` | **code** |
| **domain whitelist** | by *registered kind*, not address: `isStrategy[msg.sender]` plus `globals.isInstanceOf("STRATEGY_FACTORY" / "LIQUIDATOR_FACTORY" / "WITHDRAWAL_MANAGER_FACTORY" / "POOL_PERMISSION_MANAGER", …)`. Depositor side gated by `PoolPermissionManager` | **code** |
| **magnitude cap** | `liquidityCap` — **but `setLiquidityCap` is `onlyProtocolAdminsOrNotConfigured`. The delegate does not set its own cap.** Plus a hard precondition on origination: `requestFunds` requires `_hasSufficientCover(globals, asset)`, i.e. cover ≥ `minCoverAmount` | **code** |
| **rate-of-change limit / delay** | **partial.** There is no debounce or step limit on origination — the delegate may fund up to the cap at will. A delay exists only for *upgrades*: the delegate may call `upgrade` solely through `globals.isValidScheduledCall(sender, this, "PM:UPGRADE", msg.data)`. Withdrawals are separately queued by the `WithdrawalManager` | **code, but narrower than the schema** |
| **revocation** | `setPendingPoolDelegate` is `onlyPoolDelegateOrProtocolAdmins` (so admins can replace the delegate); `setActive` is callable only by `globals()`; every function carries `whenNotPaused` against a protocol-wide pause; `securityAdmin` can force an upgrade | **code** |
| **performance fee** | `delegateManagementFeeRate`, bounded by `HUNDRED_PERCENT`, but **`setDelegateManagementFeeRate` is `onlyProtocolAdminsOrNotConfigured`** — the delegate does not set its own fee either | **code** |

**And the refutation, which is the most useful thing this lane can send to stage 4.**
The cross-lane finding characterises the agent as *"accountable only
reputationally"*. **At Maple that clause is false, and it is false in code.**
The delegate posts first-loss capital into `MaplePoolDelegateCover`; it **cannot
originate** while cover is below `minCoverAmount` (`requestFunds` →
`_hasSufficientCover`); it **cannot withdraw** cover below that floor
(`withdrawCover` asserts
`balanceOf(poolDelegateCover) >= globals.minCoverAmount(this)`); and on a loss
`_handleCover` draws the cover down **before** the pool takes anything, capped
at `maxCoverLiquidationPercent`, splitting the proceeds between
`mapleTreasury()` and the pool.

So across the five sightings the accountability term is **not constant**: at
Aave, Morpho and SparkLend the agent is unbonded and the only sanction is
revocation; at Maple the agent is bonded and the sanction is financial and
automatic. The schema needs a **sixth slot — the agent's stake — which may be
empty**, and "reputational" should be read as the *default* value of that slot
rather than as part of the definition.

*Source: `https://raw.githubusercontent.com/maple-labs/pool-v2/main/contracts/MaplePoolManager.sol`, accessed 2026-08-04.*

## 2.5 SparkLend — ALM `RateLimits`, over movements of Sky liquidity

A **fifth sighting inside this lane**, and the reason it earns its own section
is that it implements the schema's fourth slot by a **fourth distinct
mechanism**. Aave uses a debounce, MetaMorpho a queue-and-accept timelock,
the CapAutomator a cooldown; this is a **continuously refilling token bucket.**

```solidity
struct RateLimitData { uint256 maxAmount; uint256 slope; uint256 lastAmount; uint256 lastUpdated; }

function getCurrentRateLimit(bytes32 key) public view returns (uint256) {
    ...
    return _min(d.slope * (block.timestamp - d.lastUpdated) + d.lastAmount, d.maxAmount);
}

function triggerRateLimitDecrease(bytes32 key, uint256 amountToDecrease)
    external onlyRole(CONTROLLER) returns (uint256 newLimit)
{
    ...
    require(amountToDecrease <= currentRateLimit, "RateLimits/rate-limit-exceeded");
    d.lastAmount  = newLimit = currentRateLimit - amountToDecrease;
    d.lastUpdated = block.timestamp;
}
```

| part | mechanism | enforced by |
|---|---|---|
| **named agent** | `CONTROLLER` role (the `MainnetController` / `ForeignController`, driven by an off-chain relayer); `DEFAULT_ADMIN_ROLE` sets the envelope | **code** |
| **domain whitelist** | limits are keyed by `bytes32 key` — one budget per (action, venue) pair, with `RateLimitHelpers.sol` constructing the keys, and venue libraries (`AaveLib`, `CurveLib`, `UniswapV4Lib`, `PSMLib`, `CCTPLib`, `LayerZeroLib`, `ERC4626Lib`) enumerating what may be done at all. A key with `maxAmount == 0` reverts `RateLimits/zero-maxAmount` | **code** |
| **magnitude cap** | `maxAmount` — the bucket's ceiling, and the most the agent can ever move in one action | **code** |
| **rate-of-change limit** | `slope` — refill per second. Available budget is `min(slope·Δt + lastAmount, maxAmount)`, consumed by `triggerRateLimitDecrease` and restored by `triggerRateLimitIncrease`. **This is a true flow limit, not a delay**: it bounds *throughput* rather than *frequency*, which none of the other four sightings does | **code** |
| **revocation** | `setRateLimitData(key, 0, 0)` zeroes a budget; `revokeRole(CONTROLLER, …)`; and `ALMProxyFreezable.sol` plus the org's `sparklend-freezer` / `sparklend-kill-switch` give a separate stop | **code** |
| **performance fee** | **absent** | — |

**One caveat, and it is the sharpest control-plane detail in the lane.**
`setUnlimitedRateLimitData(bytes32 key)` sets `maxAmount = type(uint256).max`,
and both trigger functions then short-circuit — `if (maxAmount == type(uint256).max) return type(uint256).max;`.
The admin can therefore **switch the mandate off entirely, per key, in one
transaction, with no delay**, converting a bounded agent into an unbounded one.
The bound is real but it is *revocable upward as well as downward*, which is a
property none of the other four sightings has and which the five-part schema, as
currently stated, cannot express: it has a slot for revoking the agent and no
slot for **revoking the bound**.

*Sources: `https://raw.githubusercontent.com/sparkdotfi/spark-alm-controller/master/src/RateLimits.sol`
and `https://api.github.com/repos/sparkdotfi/spark-alm-controller/git/trees/master?recursive=1`,
both accessed 2026-08-04.*

## 2.6 JustLend V1 — absent, and the absence is informative

No curator, no steward, no keeper, no bounded operator. Every risk and rate
parameter is set by `admin` / `owner`, identified in comments as the Timelock,
with no step limit, no debounce beyond the timelock's own delay, and no
per-parameter envelope. JustLend is the **control** in this lane: a
Compound-V2-era protocol with a plain timelocked admin and nothing resembling a
bounded delegate.

This matters for stage 4 because it dates the primitive. Compound V2's design
(2019–2020, and JustLend's `pragma ^0.5.12` fork of it) has no such object;
Aave's steward, MetaMorpho's curator and Spark's automator are all *later*
additions in *separate repositories* from the core. **The bounded delegate
mandate is not a lending primitive — it is a layer that grew on top of lending
primitives, and its absence from the vocabulary is a vintage problem.**

## 2.7 Summary of the finding

| protocol | agent | bounded quantity | agent | whitelist | cap | delay / rate limit | revocation | stake |
|---|---|---|---|---|---|---|---|---|
| Aave V3 | Risk Council, or a robot via `RiskOracle` + Chainlink/Gelato | rates, caps, LTV / LT / bonus, e-modes, oracle growth caps | code | code | code (`maxPercentChange`) | **code — debounce (`minDelay`), per parameter per asset** | code | none |
| Morpho | curator **+** allocator (two agents) | market set, per-market supply cap, allocation | code | code | code (`cap`) | **code — asymmetric queue timelock, 1 day–2 weeks** | code | none |
| SparkLend (a) | `UPDATE_ROLE` keeper on `CapAutomator` | supply / borrow caps | code | code | code (`max`, `gap`) | **code — asymmetric cooldown (`increaseCooldown`)** | code | none |
| SparkLend (b) | `CONTROLLER` on ALM `RateLimits` | movement of Sky liquidity across venues | code | code (per `bytes32` key) | code (`maxAmount`) | **code — token bucket (`slope` per second): a *flow* limit** | code (**but the bound itself is revocable upward, instantly**) | none |
| Maple | pool delegate | origination, default, servicing, refinance | code | code (by registered *kind*) | code — **but set by protocol admins, not the delegate** | partial (upgrades only) | code | **bonded — first-loss cover, enforced at origination** |
| JustLend V1 | — | — | — | — | — | — | — | — |

**Four of five protocols carry the shape; SparkLend carries it twice, so there
are five instances in this lane. In every instance the first four parts are
enforced by code, not reputation.**

What *is* reputational is uniformly the same thing at every site, and it is not
any of the five parts: it is the **quality of the judgement inside the
envelope**. The parts bound the magnitude of a mistake; nothing bounds its
direction. Morpho makes this vivid — Blue validates neither oracle nor
collateral, so the curator's whitelist is the only risk filter in the system and
its soundness is unverifiable on-chain.

**Five variations the earlier two lanes did not see, all of which the schema
must accommodate:**

1. **The agent may be an automaton.** Aave's `AaveStewardInjector*` contracts
   read a recommendation from a `RiskOracle` and inject it inside the envelope,
   driven by Chainlink or Gelato automation. "Named agent" must admit a machine.
2. **The delay may be asymmetric** — instant to tighten, slow to loosen.
   Morpho and SparkLend arrived at this independently, in different
   organisations, over different quantities (`submitCap` decreases apply inline
   while increases queue; `_calculateNewCap` comments *"Cap cannot be increased
   before cooldown passes, but can be decreased"*). Two independent
   rediscoveries of the same asymmetry is itself evidence that it is structural.
3. **The fourth slot is not one mechanism but four.** Debounce (frequency),
   queue-timelock (latency), cooldown (frequency, one-sided), token bucket
   (throughput). A formalism that writes "rate-of-change limit" as a single
   field will conflate a limit on *how often* with a limit on *how much per
   unit time*, and those are different guarantees.
4. **The agent may be bonded.** Maple's delegate posts first-loss capital and
   cannot originate below `minCoverAmount`. The schema needs a **sixth slot,
   the agent's stake, which may be empty** — and "accountable only
   reputationally" is the *default value* of that slot, not part of the
   definition.
5. **The bound may itself be revocable.** `setUnlimitedRateLimitData` removes
   the cap and the flow limit in one admin transaction with no delay. The schema
   has a slot for revoking the *agent* and none for revoking the *bound*, which
   is the more dangerous of the two.

**Consequence for stage 4.** With yield (allocations), CDP (rates) and now
lending (rates, caps, collateral parameters, market sets, liquidity movements,
origination), this is the run's best-evidenced finding, and lending settles that
it is a **schema over elements** rather than an element: the same five parts
appear over six different bounded quantities in one category.

Note finally that **Finding 1 and Finding 2 have converged onto the same field
list** — setter locus, bound, latency, and now stake. The "price of credit" gap
and the "delegated mandate" gap may be one gap, stated twice: **the formalism
cannot say who may move a quantity, how far, how fast, with what at risk, and
who may lift the limit.** Aave is the proof that they are one gap and not two —
`RiskSteward.updateRates` is *literally the rate instrument implemented as a
bounded mandate*, using the same `_validateParamUpdate` that bounds its caps and
its LTVs.

---

# GAPS IN THIS FILE (honest inventory)

| what | where | why |
|---|---|---|
| Spark D3M's rate-*targeting* objective, and which venues are live | §3.2 | `MainnetController.sol` not read (the `RateLimits` mandate **was** read — §Finding 2.5) |
| Maple's origination *process* — who proposes `_interestRate` and how it is accepted | §5.2 | `MapleLoan.sol` / `MapleLoanInitializer.sol` not read (the loan's **fields** were read — §5.2) |
| Key holders and quorums for all five | §1.2, §3.2, §4.2, §5.2 | no on-chain reads performed; `aave-permissions-book` not fetched. **This is the bridges lane's gap, unresolved here too** |
| Repo↔deployment correspondence for all five | all §3 | no bytecode comparison; no pinned commit SHAs |
| Certora / fuzz invariants actually proved | §1.2, §5.2 | spec files not read |
| Aave Umbrella / Safety Module (`Bs`) | §1.6 | not fetched |
| JustLend energy-rental market | §4.2 | not present in the protocol repo |
| Maple custody arrangements | §5.2 | no primary source reachable without search |
| All TVL and ranking figures | throughout | WebSearch budget exhausted; corpus figures neither confirmed nor challenged |

**Two structural cautions for whoever consumes this file.**

1. **Every repository citation here is to a mutable branch** (`main`, `master`,
   `dev`), not a commit SHA. The spot-exchange lane proved this is not a
   pedantic point: two Curve artefacts shared a version string and differed
   mathematically. Before any of this reaches `atlas.tex`, the fetches should be
   re-pinned to SHAs. The push dates recorded in each §3 are the partial
   mitigation.
2. **Licence status is per-module and three of the five targets carry a trap:**
   JustLend declares **no licence at all** (§4.3), Maple's loan core is
   **BUSL-1.1** despite `NOASSERTION` repo metadata (§5.3), and Aave and
   SparkLend's core both report `NOASSERTION`. Only Morpho (GPL-2.0, and only
   after relicensing from BUSL-1.1) is unambiguously reproducible. Reading repo
   metadata alone gets this wrong for Maple — the SPDX header in the source is
   the authority.
