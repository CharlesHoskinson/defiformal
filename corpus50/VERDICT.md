# The completeness benchmark: what 69 protocols did to the vocabulary

Three lanes, briefed identically, run independently, never shown each other's
work. Rankings pulled live from DefiLlama and rwa.xyz on 2026-08-04 — none from
memory. Each lane was told that a finding of FAILURE was worth more than a
forced fit, and each was required to record residue and mark every approximate
symbol use.

**Verdict: the vocabulary is a good vocabulary of on-chain state machines and
it is not a basis for DeFi.** Not one of the 69 protocols was fully
expressible.

## Coverage

| Lane | Categories | Coverage |
|---|---|---|
| 1 | DEX · lending · CDP · liquid staking | ~73% clean, 13% forced, 13% none |
| 2 | perps · yield · bridges · intents | 60–70% perps/bridges · ~45% yield · **~25% intents** |
| 3 | RWA · options · fiat stables · prediction | 39% · 63% · **25%** · 44% |

Every lane volunteered, unprompted, that its own percentage **flatters the
vocabulary**, for the same reason: the unnamed part is the part protocols
compete on.

## Six findings that all three lanes reached independently

### 1. The delegated allocation mandate — the most-confirmed gap in the project

A named party with discretionary authority over other people's deposits,
bounded by caps and a timelock, paid a performance fee, accountable only
reputationally. Found separately by all three lanes:

- Lane 1: Morpho curators, Maple pool delegates, Liquity V2 batch managers
- Lane 2: Steakhouse at $3.08B — *more TVL than Yearn, Beefy and CIAN combined
  by a factor of eight*
- Lane 3: DefiLlama's #9 and #12 categories, $16.5B combined

`Sv` is the only nearby symbol and all three lanes rejected it in the same
words: it names discretion over a **loan**, not over an **allocation**. A
curator never touches a loan; the discretion is exercised before anything goes
wrong.

### 2. Decomposition collides on the largest objects

Not obscure pairs — the biggest things in each category:

- **The top three bridges by TVL** — WBTC, Coinbase, Binance BTC, **$17.8B
  combined** — decompose to an identical five symbols, and that set contains
  **no verification symbol at all**, because there is nothing to verify: a
  company holds the asset.
- USDT ≡ USD1 · USDC ≡ PYUSD · USYC ≡ BUIDL (lane 3)
- **SparkLend's element set is a strict subset of Aave V3's** (lane 1)
- ApeX ≡ edgeX ≡ Lighter · Yearn ≡ Beefy ≡ CIAN · Binance Wallet ≡ OKX DEX (lane 2)

### 3. Resolution tracks implementation history, not economic consequence

Five symbols for variants of a scalar function on a two-asset pool. One (`Op`)
for the entire options universe. One (`Ob`) for three incompatible
matching-engine trust models. One (`Xm`) for five verification models. `Vl`
standing for at least five separable mechanisms at Lido and **unusable at all**
at Binance staked ETH, $6.9B of liquid staking with no on-chain validator
lifecycle to name.

### 4. There is no price of credit

No symbol for a rate: not the utilization curve every lending protocol runs,
not Sky's Stability Fee, not crvUSD's automatic controller, not Liquity V2's
borrower-chosen rates, not an administered rate set by vote. The Stability
register offers a redemption right, a 1:1 swap, and **quantity** adjustment —
and every protocol reaches for a **price** instrument instead.

### 5. Coverage degrades monotonically across the off-chain boundary

And the off-chain fraction is inversely correlated with capital held. Missing
throughout: obligor and recourse · register of record · reserve composition and
custody · bankruptcy remoteness · legal enforceability · off-exchange custody
and venue mirroring · central counterparty and novation.

### 6. Symbols cannot be scoped or marked as inherited

Two distinct defects, found in different lanes, with the same root:

- **No scoping.** `Bs` is true of Lido's CSM module and false of the majority of
  its stake. `St` covers Curve's stableswap pools and not tricrypto. `Ob` is in
  Raydium's bytecode and switched off.
- **No inheritance marking.** No way to say a protocol *consumes* an element its
  dependency implements rather than implementing it — `Ct` for CIAN and
  Steakhouse, `Ps` for Spark Savings, `Im` for Steakhouse, `Pf` for Ethena
  (which receives Binance's funding transfer and implements none).

## The finding that changes the shape of the algebra

Lane 2, on yield:

> A **strategy** is not an element and not a protocol. It is a policy expressed
> *over* protocols — "borrow USDC on Morpho against stETH up to 80% LTV, unwind
> above 85%, harvest weekly". It has no on-chain mechanism of its own; it is a
> rule for consuming other people's mechanisms. **The model has no such level.**

This is why Yearn, Beefy and CIAN collapse onto each other, and why the largest
vault operator in DeFi has no symbol for the thing it sells. The lane's own
conclusion — that adding "strategy" as an *element* would be wrong, because it
is not a mechanism — is the right one, and it lands directly on the algebra:

> **the carrier may not be one-sorted.** If a strategy is a policy over terms
> rather than a term, an algebra whose carrier is "sets of elements" cannot
> express the object that holds the most capital in the yield category.

## Empirical rulings on the contested and candidate registers

These were arguments the earlier councils could not settle. The corpus settles
them:

| Symbol | Ruling | Evidence |
|---|---|---|
| `Da` | **promote** | 3 of top 5 CDPs; all of Sky's liquidation system; 1inch Fusion |
| `Of` | **promote** | near-definitional for Across |
| `Sv` | **promote, then narrow** | exact for Huma's Evaluation Agent; wrong for every curator |
| `Ve` | **split, do not promote** | load-bearing where used (without it Convex is 100% residue) but Curve runs four separable mechanisms on one lock, and only 1 of the top 5 DEXs still has one — PancakeSwap retired veCAKE in April 2025 |
| `Vl` | **split, do not promote** | required by 4 of 5, adequate in none, unusable in the second-largest |
| `Tw` | **reject** | offered twice, refused twice — does not cover Pendle's maturity-aware curve or Jupiter's DCA |
| `Zk` | **insufficient** | proves state validity; cannot express Lighter's proof that the *matching rule* was followed |

## What this hands the mathematicians

The residue is not noise to be tidied away — it is the specification of where
the algebra has to do work. Concretely it hands them:

1. A **carrier question with an empirical answer attached** — one sort will not
   hold a strategy.
2. A **non-injectivity result with named fibres**, and the fact that those
   fibres are not semantically homogeneous.
3. A **boundary** that is real, monotone, and inversely correlated with capital.
4. Two **structural primitives with no symbol**: state-partition of collateral
   (prediction markets) and delegated mandate (the fastest-growing form in DeFi,
   and possibly not a term at all — an agent with discretion).
5. **Scoping and inheritance** as operations the algebra probably needs and the
   taxonomy does not have.
