# 02 · Lending — stage-1 research

**Targets:** Aave V3 · Morpho · SparkLend · JustLend V1 · Maple
**Lane:** replacement run, 2026-08-04. All access dates 2026-08-04 unless stated.
**Method note.** This session's WebSearch budget was exhausted before this lane
started, so every citation below is a **direct fetch of a primary artefact** —
raw source from the canonical repository, the GitHub repository API, or the
protocol's own documentation host. Where a claim could not be reached that way it
is marked **UNKNOWN**. Nothing here is from memory.

---

## 1 · Aave V3

### 1.1 WHAT IT DOES

UNKNOWN — pending fill.

### 1.2 DESIGN

**Interest-rate model — complete, from source.** `DefaultReserveInterestRateStrategyV2`
(`aave-v3-origin`, `src/contracts/misc/DefaultReserveInterestRateStrategyV2.sol`,
`main`, fetched 2026-08-04) holds a per-reserve struct
`{optimalUsageRatio, baseVariableBorrowRate, variableRateSlope1, variableRateSlope2}`
in basis points, and computes:

```
U_b = totalDebt / (availableLiquidity + totalDebt)
U_s = totalDebt / (availableLiquidity + totalDebt + unbacked)

if totalDebt == 0:   borrowRate = base ;  liquidityRate = 0
else if U_b <= U*:   borrowRate = base + slope1 · (U_b / U*)
else:                borrowRate = base + slope1 + slope2 · ((U_b − U*) / (1 − U*))

liquidityRate = borrowRate · U_s · (1 − reserveFactor)
```

Hard bounds enforced in `_setInterestRateParams`:
`MAX_BORROW_RATE = 1000_00` bps (base+slope1+slope2 ≤ 1000%),
`MIN_OPTIMAL_POINT = 1_00` (1%), `MAX_OPTIMAL_POINT = 99_00` (99%),
and `variableRateSlope1 <= variableRateSlope2`. Writes are
`onlyPoolConfigurator`. There is **no rate-of-change limit and no delay inside
the strategy contract** — a permitted caller moves the whole curve in one
transaction, subject only to the level bounds above.

Control plane, price sources, liquidation path — UNKNOWN, pending fill.

### 1.3 REPO

`https://github.com/aave-dao/aave-v3-origin` — default branch `main`, last push
2026-07-29T10:12:35Z, language Solidity, licence reported by the GitHub API as
`NOASSERTION` (a custom licence file, not an SPDX identifier). Correspondence to
deployed contracts: UNKNOWN, pending fill.

### 1.4 EVIDENCE

- `https://raw.githubusercontent.com/aave-dao/aave-v3-origin/main/src/contracts/misc/DefaultReserveInterestRateStrategyV2.sol` — accessed 2026-08-04.
- `https://api.github.com/repos/aave-dao/aave-v3-origin` — accessed 2026-08-04.

### 1.5 WHAT LOOKS UNNAMEABLE

Pending fill.

### 1.6 DELTA

Pending fill.

---

## 2 · Morpho

### 2.1 WHAT IT DOES

UNKNOWN — pending fill.

### 2.2 DESIGN

**Interest-rate model — complete, from source.** `AdaptiveCurveIrm`
(`morpho-blue-irm`, `src/adaptive-curve-irm/`, `main`, fetched 2026-08-04) is a
**closed-loop controller on utilisation error**, not a static curve. Constants
(`libraries/ConstantsLib.sol`):

| constant | value |
|---|---|
| `CURVE_STEEPNESS` | `4 ether` (= 4) |
| `TARGET_UTILIZATION` | `0.9 ether` (90%) |
| `ADJUSTMENT_SPEED` | `50 ether / 365 days` (50 / year) |
| `INITIAL_RATE_AT_TARGET` | `0.04 ether / 365 days` (4%/yr) |
| `MIN_RATE_AT_TARGET` | `0.001 ether / 365 days` (0.1%/yr) |
| `MAX_RATE_AT_TARGET` | `2.0 ether / 365 days` (200%/yr) |

The source comments record the implied instantaneous band: rate at target
between 0.1% and 200%, hence realised rate between 0.025% and 800%. These are
`constant`s in a contract with no setter — **no party can change them.**

**Curator mandate — see §Finding 2 below; all five parts proven from code.**

Rest — UNKNOWN, pending fill.

### 2.3 REPO

- `https://github.com/morpho-org/morpho-blue` — `main`, last push 2026-07-31T18:20:34Z, Solidity, **GPL-2.0**.
- `https://github.com/morpho-org/metamorpho` — `main`, last push 2026-08-01T12:47:39Z, Solidity, **GPL-2.0**.
- `https://github.com/morpho-org/morpho-blue-irm` — IRM lives here, licence UNKNOWN.

Correspondence to deployed contracts: UNKNOWN, pending fill.

### 2.4 EVIDENCE

- `https://raw.githubusercontent.com/morpho-org/morpho-blue-irm/main/src/adaptive-curve-irm/libraries/ConstantsLib.sol` — accessed 2026-08-04.
- `https://raw.githubusercontent.com/morpho-org/metamorpho/main/src/MetaMorpho.sol` — accessed 2026-08-04.
- `https://raw.githubusercontent.com/morpho-org/metamorpho/main/src/libraries/ConstantsLib.sol` — accessed 2026-08-04.
- `https://api.github.com/repos/morpho-org/morpho-blue`, `.../metamorpho` — accessed 2026-08-04.

### 2.5 WHAT LOOKS UNNAMEABLE

Pending fill.

### 2.6 DELTA

Pending fill.

---

## 3 · SparkLend

### 3.1 WHAT IT DOES
UNKNOWN — pending fill.
### 3.2 DESIGN
UNKNOWN — pending fill.
### 3.3 REPO
`https://github.com/sparkdotfi/sparklend-v1-core` — default branch **`dev`** (not
`main`), last push 2026-07-28T02:19:46Z, language reported as TypeScript, licence
`NOASSERTION`. Note the org is `sparkdotfi`, not the `marsfoundation` org the
corpus era used. Accessed 2026-08-04 via `https://api.github.com/repos/sparkdotfi/sparklend-v1-core`.
### 3.4 EVIDENCE
- `https://api.github.com/repos/sparkdotfi/sparklend-v1-core` — accessed 2026-08-04.
### 3.5 WHAT LOOKS UNNAMEABLE
Pending fill.
### 3.6 DELTA
Pending fill.

---

## 4 · JustLend V1

### 4.1 WHAT IT DOES
UNKNOWN — pending fill.
### 4.2 DESIGN
UNKNOWN — pending fill.
### 4.3 REPO
UNKNOWN — pending fill.
### 4.4 EVIDENCE
Pending fill.
### 4.5 WHAT LOOKS UNNAMEABLE
Pending fill.
### 4.6 DELTA
Pending fill.

---

## 5 · Maple

### 5.1 WHAT IT DOES
UNKNOWN — pending fill.
### 5.2 DESIGN
UNKNOWN — pending fill.
### 5.3 REPO
`https://github.com/maple-labs/maple-core-v2` — `main`, last push
2026-05-28T12:29:52Z, Solidity, licence `NOASSERTION`. Accessed 2026-08-04 via
`https://api.github.com/repos/maple-labs/maple-core-v2`.
### 5.4 EVIDENCE
- `https://api.github.com/repos/maple-labs/maple-core-v2` — accessed 2026-08-04.
### 5.5 WHAT LOOKS UNNAMEABLE
Pending fill.
### 5.6 DELTA
Pending fill.

---

# FINDING 1 — THE PRICE OF CREDIT

Status: 2 of 5 established from source (Aave V3, Morpho). Pending: SparkLend,
JustLend V1, Maple.

# FINDING 2 — THE DELEGATED ALLOCATION MANDATE

**Confirmed at Morpho (MetaMorpho / Morpho Vaults), all five parts, four of five
enforced by code.** Detail below; other four protocols pending.

| part | MetaMorpho mechanism | enforced by |
|---|---|---|
| named agent | `curator` (`setCurator`, `onlyOwner`), `allocator` (`setIsAllocator`, `onlyOwner`) | **code** |
| domain whitelist | `reallocate` reverts `UnauthorizedMarket(id)` when `config[id].cap == 0`; `submitCap` rejects a market whose `loanToken != asset()`; `MAX_QUEUE_LENGTH = 30` | **code** |
| magnitude cap | `if (supplyAssets + suppliedAssets > supplyCap) revert SupplyCapExceeded(id)` | **code** |
| rate-of-change limit / delay | **asymmetric timelock**: a cap *decrease* applies immediately, a cap *increase* is queued via `pendingCap[id].update(newSupplyCap, timelock)` and needs `acceptCap` after `timelock`; `MIN_TIMELOCK = 1 days`, `MAX_TIMELOCK = 2 weeks` | **code** |
| revocation | `revokePendingCap` (curator **or** guardian), `revokePendingMarketRemoval`, `revokePendingTimelock`, `revokePendingGuardian`; owner may `setCurator(address(0))` | **code** |
| performance fee | `setFee` is **`onlyOwner`, not curator**; `MAX_FEE = 0.5e18` (50%) | **code** |

`reallocate` additionally enforces `totalWithdrawn == totalSupplied` — the
allocator may move deposits between whitelisted markets but cannot move value
out of the vault. The choice of *which* markets get proposed, and the judgement
that a market's oracle and LLTV are sound, is reputational only.
