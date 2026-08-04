# Visualization TODO — everything that must appear on screen

Status key: **[✓] built** · **[~] partial** · **[ ] not built** · **[?] undecided**

The organising rule for this whole list: **the failures are the content.** The
corpus benchmark did not find a tidy table with a few gaps — it found that the
vocabulary collides on the largest objects in DeFi. A visualization that renders
only the clean part is a lie by omission. Every "residue" and "forced fit" item
below is a thing to *draw*, not a caveat to footnote.

---

## A. Core atlas objects

| # | Object | Count | Status | Note |
|---|---|---|---|---|
| A1 | Elements | 58 core (+10 candidate, +10 contested) | [✓] | packed five-row form |
| A2 | Families | 16 | [✓] | family view |
| A3 | Strata S0–S4 | 5 | [✓] | but see A11 — may not be derivable |
| A4 | Composition laws | 29 | [~] | parsed and evaluated; **not drawn** |
| A5 | Hazard rules | 20 rows / 19 families | [~] | listed; only 1 is decidable |
| A6 | Bond types | 4 | [ ] | never rendered |
| A7 | Candidate register | 10 | [~] | marked, not differentiated |
| A8 | Contested register | 10 | [~] | **corpus now rules on 7 of them — §E4** |
| A9 | Asynchrony property | 3 values | [ ] | exactly one element is "impossible" — never shown |
| A10 | Element status | — | [~] | |
| A11 | Derived vs asserted stratum | — | [ ] | blocked on Quint Q10 |

## B. The 12 categories and 60 protocols

Ranked live from DefiLlama / rwa.xyz on 2026-08-04. **None of these 60 are in
the viz yet** — `protocols.ts` still holds only the original 12. That is the
single largest gap between what we know and what we show.

Per-protocol we now hold: element set · order-known flag · residue list ·
forced-fit list with markers · rank basis with figure and date.

| # | Category | Top 5 | Status |
|---|---|---|---|
| B1 | **Spot DEX / AMM** | Uniswap · PancakeSwap · Curve · Raydium · Fluid | [ ] |
| B2 | **Lending** | Aave V3 · Morpho · SparkLend · JustLend V1 · Maple | [ ] |
| B3 | **CDP stablecoins** | Sky · USDD · Lista CDP · Liquity · crvUSD | [ ] |
| B4 | **Liquid staking & restaking** | Lido · Binance staked ETH · EigenCloud · ether.fi · Babylon | [ ] |
| B5 | **Perpetuals** | Hyperliquid · ApeX · Aster · Lighter · edgeX | [ ] |
| B6 | **Yield & vaults** | Pendle · Spark Savings · Convex · CIAN · Huma | [ ] |
| B7 | **Bridges** | WBTC · LayerZero V2 · Coinbase Bridge · Hyperliquid Bridge · Binance BTC | [ ] |
| B8 | **Intents & aggregation** | LiquidMesh · Binance Wallet · OKX DEX · Jupiter · KyberSwap | [ ] |
| B9 | **RWA & private credit** | Ondo · USYC · BUIDL · Maple · Centrifuge | [ ] |
| B10 | **Options & structured** | Derive · Rysk · Hegic · Aevo · Panoptic | [ ] |
| B11 | **Fiat stablecoin issuers** | USDT · USDC · USD1 · USDG · PYUSD | [ ] |
| B12 | **Prediction markets & other** | Kalshi · Polymarket · Azuro · Steakhouse · Grove | [ ] |

### B13 — Controls (deliberately outside the top 5) [ ]
Added by lanes to test specific claims, and they must be visually distinguishable
from the ranked 60 or the ranking is a lie:
Compound V3 (does it differ from Aave?) · Ethena (does `Dp` cover delta-neutral?) ·
Jupiter Perps + GMX V2 (pool venues — *no oracle-pool venue is in the volume top 5*) ·
Yearn · Beefy · Steakhouse (is a strategy an element?) · CCTP (unrankable by TVL —
burn-and-mint locks nothing) · Across (the one bridge the vocabulary fits) ·
DFlow · 1inch · CoW Swap.

### B14 — Protocols occupying two slots [ ]
**Maple is top-5 in both Lending and RWA**, and the two lanes decomposed it
differently. **Steakhouse is top-5 in Prediction/other and a control in Yield.**
**Jupiter is top-5 in Intents and a control in Perps.** So the 60 slots hold 59
distinct protocols. This is not a bookkeeping error to clean up — it is evidence
that *category is a property of the observer, not of the protocol*, and it
should be visible.

## C. Engine results — computed, mostly undrawn

| # | Result | Status | Note |
|---|---|---|---|
| C1 | Closure per protocol | [~] | computed; 6 of 12 close |
| C2 | Seating order | [~] | computed, never rendered |
| C3 | Requirement cycles | [~] | **there are none** — that absence must be shown, not hidden |
| C4 | In-degree / "Weight" | [~] | max 4, nearly flat — weak channel, say so |
| C5 | Closure-of / shadow | [~] | |
| C6 | Unfireable laws (L14, L23, L25, L26) | [ ] | prose subjects — can never fire |
| C7 | 52 of 77 terms are prose | [ ] | **two thirds of the law content is natural language** |
| C8 | Inevaluable hazards (19 of 20) | [ ] | |
| C9 | Quint cross-check | [~] | 7 tests pass; model checking pending |

## D. Corpus findings — the strongest material, none of it drawn

| # | Finding | Status |
|---|---|---|
| D1 | **Collision map** — identical decompositions | [ ] |
| D2 | Residue per protocol (~150 distinct items) | [ ] |
| D3 | Forced fits with CANDIDATE/CONTESTED/FORCED/EXACT markers | [ ] |
| D4 | Explicit **rejections** (Tw ×2, Ba, Da, Dp, Ua) — findings, not gaps | [ ] |
| D5 | Coverage by category (25%–73%) | [ ] |
| D6 | The off-chain boundary | [ ] |
| D7 | Capital vs resolution — the inverse correlation | [ ] |

### D1 detail — the collisions to draw
- **Top 3 bridges by TVL, $17.8B combined**, identical five symbols containing
  *no verification symbol at all* — WBTC ≡ Coinbase ≡ Binance BTC
- USDT ≡ USD1 · USDC ≡ PYUSD · USYC ≡ BUIDL
- **SparkLend ⊂ Aave V3** — a strict subset, no distinguishing symbol
- ApeX ≡ edgeX ≡ Lighter · Yearn ≡ Beefy ≡ CIAN · Binance Wallet ≡ OKX DEX
- Polymarket ≡ three clones · Derive ≡ Aevo

## E. Structural findings that change the drawing, not just its contents

| # | Finding | Implication | Status |
|---|---|---|---|
| E1 | **A strategy is a missing LEVEL** | element / protocol / **policy-over-protocols**. Yearn, Beefy, CIAN collapse because the third level does not exist. Needs its own visual register, not a badge. | [ ] |
| E2 | **No scoping** | `Bs` is true of one Lido module and false of most of its stake; `St` covers Curve stableswap and not tricrypto; `Ob` is in Raydium's bytecode and switched off. Symbols assert protocol-wide facts about module-local mechanisms. | [ ] |
| E3 | **No inheritance marking** | no way to say a protocol *consumes* an element rather than implementing it — `Ct` for CIAN/Steakhouse, `Ps` for Spark, `Pf` for Ethena (receives Binance's funding transfer, implements none). Needs a distinct edge/stroke. | [ ] |
| E4 | **Register rulings from evidence** | promote `Da`, `Of`, `Sv`(narrowed); split `Ve`, `Vl`; reject `Tw`; `Zk` insufficient. Show the *evidence*, not the verdict. | [ ] |
| E5 | **Non-injective decomposition** | fibres are not semantically homogeneous — USDT and USD1 are one point and not one credit | [ ] |

## F. Views and mechanisms

| # | View | Status |
|---|---|---|
| F1 | Packed five-row table | [✓] |
| F2 | Family view | [✓] |
| F3 | 3D CSS3D scene, drag, focus, spiral | [✓] |
| F4 | Protocol overlay (12 protocols) | [✓] |
| F5 | Dark + light theme, conformance-gated | [✓] |
| F6 | **The Lock-Up** | [ ] — the spine the whole design was built around, still unbuilt |
| F7 | **Law matrix (DSM)** | [ ] — *two independent research lanes converged on this*: matrices beat node-link above ~20 nodes (Ghoniem/Fekete/Castagliola, InfoVis 2004), and a DSM was the only non-hairball rendering of ~48 relations over 59 nodes found in the wild. Solid diagonal, marks not edges, direction by side. |
| F8 | **Node-link trace — failure only** | [ ] — path-finding is the *one* task node-link wins; use it when closure fails, never at rest |
| F9 | **The void as live surface** | [ ] — ptable's move: legend when orienting → DSM when studying → drop-zone when composing. Same hole, three jobs, zero extra layout. |
| F10 | Coverage / residue view | [ ] |
| F11 | Collision view | [ ] |
| F12 | Corpus browser (60 protocols) | [ ] |
| F13 | Algebra council results | [ ] — blocked, council not launched |

## G. Known defects to fix

| # | Defect | Status |
|---|---|---|
| G1 | `protocols.ts` holds 12 protocols; we have 60 | [ ] |
| G2 | Three dead protocols shown; **Euler fails closure for a reason unrelated to why it died** (has `Up` without `Tg`, violating L15) — the Lock-Up's best moment is built on a coincidence | [ ] |
| G3 | Hazard layer renders as if decidable; only X2 is, and it fires on nothing | [ ] |
| G4 | Weight/in-degree channel has almost no dynamic range | [ ] |
| G5 | "Periodic table" disavowal — exactly one permitted instance, gated by conformance | [✓] |

## H. Ordering

1. **F7 + F9** — the law matrix in the void. Highest evidence, converged from
   two independent research lanes, and it unblocks F6.
2. **G1 + F12** — load the 60. Everything in D and E is unreachable without it.
3. **D1 collision view** — the strongest single finding, and cheap once G1 lands.
4. **F6 Lock-Up** — but re-derive its climax first; G2 says the current one is
   built on a coincidence.
5. **E1 strategy level** — needs a design decision before it needs code.
