# Visualization TODO — everything that must appear on screen

Status key: **[✓] built** · **[~] partial** · **[ ] not built** · **[?] undecided**

**DIRECTION CHOSEN: the argument.** Spine — *"Same parts. Different protocol."*
58 elements and 72 protocols → watch protocols collapse onto one tile set →
USDT/USD1 as a theorem, no on-chain observation separates them → watch Terra's
loop vanish when flattened to element types → **what kills protocols is what the
table forgets.** Payoff: the warrant half restores it, and the tool that falls
out answers *what can't I justify?* Everything below is now ranked by whether it
serves that spine.

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
| A11 | Derived vs asserted stratum | — | [ ] | **CONTESTED, and the disagreement is the drawing.** Not derivable *as law-graph rank*: Rank agrees with hand stratum on 3 of 58, all trivially 0=0; rank spans 0–2 against stratum 0–4. One real inversion, L21 `Gs`(S3)→`Au`(S4). FCA says the same independently — concept lattices are not graded. Draw the 55-element disagreement, not the agreement. **But OP-CAT derives it as the maximal sort of a typing functor and agrees 57/58**, with `Pm` the sole exception and the `Gs`→`Au` inversion dissolving because the sort powerset is not linearly ordered. Two derivations, opposite verdicts — show both bases side by side rather than picking one. |

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
| C1 | Closure per protocol | [~] | **9 of 12 close, not 6.** The old figure was a parser bug: mixed terms (`Tg | bounded emergency process`) were read as hard element requirements. Lido, Centrifuge and Euler close once fixed; only CCTP, Terra and Mango stay open. Draw the corrected result and the correction. |
| C2 | Seating order | [~] | computed, never rendered |
| C3 | Requirement cycles | [~] | **there are none, and now provably so** — the requirement relation over all 58 elements taking every alternative is a DAG with no self-loops, so *no subset can contain a cycle*. Terra is a 2-cycle only over (element, asset) pairs under `backs`: (As,UST)→(Rd,LUNA)→(As,UST). Draw the pair-level loop; the element-level graph cannot hold it. |
| C4 | In-degree / "Weight" | [~] | max 4, nearly flat — weak channel, say so |
| C5 | Closure-of / shadow | [~] | |
| C6 | Unfireable laws (L14, L23, L25, L26) | [ ] | prose subjects — can never fire |
| C7 | 52 of 77 terms are prose | [ ] | **two thirds of the law content is natural language** |
| C8 | Inevaluable hazards (19 of 20) | [ ] | |
| C10 | **Unlisted hazard `{Fl, Xm}`** | [ ] | closed under all 25 fireable laws, arms none of the 20 hazard rows, reachable. Flash atomicity — the vocabulary's ONLY async-impossible element — crossing a domain boundary. X2 covers flash-loan price manipulation and nothing covers this. Second witness `{Fl, Au, Rl}`. |
| C11 | **The exhaustive bound** | [ ] | all 5,038,954 subsets of size ≤5 enumerated; 1,458,840 closed and hazard-free; minimal witness list complete within that space. **Nothing claimed at size ≥6** — the bound is the drawing, not a footnote. |
| C12 | **Closure is a lattice, validity is not** | [ ] | closed sets are union-closed, contain ⊥ and ⊤, form a complete lattice — but **meet is not intersection** (`{Xm,Xf,Of,Bs} ∩ {Xm,Xf,Of,Sl}` is open) and **hazards destroy the join** (`{Xm,Xf} ∪ {Aw}` arms X19). |
| C13 | **`Uc` is unrealizable** | [ ] | **CONTESTED.** Our enumeration: zero hazard-free completion, so the hazard table forbids every way of building one of its own elements. OP-CAT rules it realizable and calls `X11a` a polarity bug. Draw the contested cell, not a verdict. |
| C14 | Minimal legal completions per protocol | [ ] | 1–6. Lido and Euler have exactly one, both `+Tg`; CCTP 2; Terra 4; Mango 6. |
| C9 | Quint cross-check | [✓] | 8 tests pass; **model checking complete** — Apalache + exhaustive enumeration, Q10/Q12/Q13/Q14 all answered |

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

### D1 detail — CORRECTED. Most of the claimed collisions are not real.

The lanes recorded 10 groups as `identical_decompositions`. Checked against the
actual element arrays by `viz/scripts/check-collisions.py`, **only 3 are
identical**. The lanes wrote "identical" where they meant "structurally alike",
and the earlier version of this log repeated several of the false ones — which
would have driven the viz to draw claims that are not true.

**Genuinely identical (computed, safe to draw):**
- **USDT ≡ USD1** at five symbols — the one the whole argument rests on
- LiquidMesh ≡ KyberSwap at **one** symbol (`Ag`)
- Binance Wallet ≡ OKX DEX at two — and three of the top five intents protocols
  by volume reduce to `Ag` alone

**NOT identical — do not draw as collisions:** the three big bridges (Coinbase
differs by `Tg`,`Up`; Binance BTC by `Tg`) · ApeX vs edgeX (`Gp`,`Tg`) · Yearn vs
Beefy (3 symbols) · USDC vs PYUSD (`Aw`,`Gp`) · ApeX vs Lighter (5 symbols).

### D1b — the containment lattice is the stronger object [ ]
**80 strict subset pairs**, computed. SparkLend ⊂ Aave v3 (+5) · Compound V3 ⊂
Aave v3 (+5) · USDD ⊂ Sky (+1) · Lista CDP ⊂ Sky (+3) · Raydium ⊂ PancakeSwap
(+2). Containment survives where identity does not, it is a partial order rather
than a list, and it is drawable as one. **Prefer this to the collision map.**

### D8 — the negative corpus and the discrimination baseline [ ]
84 synthetic negatives in five families (knockout, armed, inverted, hybrid,
random) plus 72 real. Our own closure predicate accepts **50% of real protocols
and 15% of random noise — 3.3×** — and **42% of hybrid protocols that do not
exist**, which says it is reading shape rather than coherence. This is the
single most honest number about the framework and nothing on screen says it.

### D9 — blind test set, 156 cases [ ]
Real and corrupted, shuffled, unlabelled; key held separately. The nine
mathematicians classify, we score. Their verdict spread per case is itself a
visual object — cases where all nine agree vs cases that split them.

## E. Structural findings that change the drawing, not just its contents

| # | Finding | Implication | Status |
|---|---|---|---|
| E1 | **A strategy is a missing LEVEL** | element / protocol / **policy-over-protocols**. Yearn, Beefy, CIAN collapse because the third level does not exist. Needs its own visual register, not a badge. | [ ] |
| E2 | **No scoping** | `Bs` is true of one Lido module and false of most of its stake; `St` covers Curve stableswap and not tricrypto; `Ob` is in Raydium's bytecode and switched off. Symbols assert protocol-wide facts about module-local mechanisms. | [ ] |
| E3 | **No inheritance marking** | no way to say a protocol *consumes* an element rather than implementing it — `Ct` for CIAN/Steakhouse, `Ps` for Spark, `Pf` for Ethena (receives Binance's funding transfer, implements none). Needs a distinct edge/stroke. | [ ] |
| E4 | **Register rulings from evidence** | promote `Da`, `Of`, `Sv`(narrowed); split `Ve`, `Vl`; reject `Tw`; `Zk` insufficient. Show the *evidence*, not the verdict. | [ ] |
| E5 | **Non-injective decomposition** | fibres are not semantically homogeneous — USDT and USD1 are one point and not one credit | [ ] |

## E6-E9. The model, and it changes what the atlas is for

| # | Object | Status |
|---|---|---|
| **E6** | **The warrant half — the single biggest addition.** The 29 laws say what each element *requires*; nothing says what it is *for*. The Galois adjoint yields **27 warrant rows** (`Li → Ct`, `As → (Ex\|Tp\|Oa\|At)`). Every element needs a second edge type drawn in the opposite direction. Ablation: closure alone 2.45×, warrant alone 2.37×, **together 10.83×**. | [ ] |
| **E7** | **Unwarranted mechanism — the new diagnostic.** Validity is now *two* fixed points: requirement-closure (what am I missing) **and** warrant-interior (what am I carrying that nothing justifies). The second has never been drawable because the atlas had no vocabulary for purpose. An unwarranted element is attack surface with no compensating function — it should read as a defect on the tile, not a neutral state. | [ ] |
| **E8** | **The polarity split.** Requirements are dual-Horn (union-closed); prohibitions are Horn (intersection-closed); their mixture is provably neither. Requirements and hazards are not two flavours of rule — they pull in **opposite directions**, and that is why validity is non-monotone. They must not share a visual register. | [ ] |
| **E9** | **The 54-point poset (T3).** If the definite fragment's closed sets are up-sets of a poset, the law list should be redrawn as a **Hasse diagram** — orderable, layerable, and an honest replacement for the stratum column that two methods now say was never a rank. **This may supersede F7's DSM**: a partial order is drawable in a way 29 disjunctive laws never were. Decide between them before building either. | [ ] |

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
| F13 | Algebra council results | [ ] — **council launched**, 9 mathematicians, 3 vendors × 3 schools |
| F14 | **The discharge matrix** | [ ] — 20 proof obligations × 9 models. Each cell is one of three states, *not two*: **proved** · **refuted with witness** · **left open**. A refutation is a discharge; only the third column is a failure. This is the honest ranking and it is mechanical rather than a matter of taste — and it is a matrix, so it goes where F7's DSM goes. |
| F15 | **The settled band** | [ ] — S1–S5 are results, not obligations: closure is a complete lattice, meet is not intersection, validity is non-monotone, stratum is not derivable, reflexivity is not expressible over element types. Draw them as a fixed floor the nine models sit on, so a model that contradicts one reads as an anomaly rather than an opinion. |
| F17 | **Strict-vs-broad: the model trade-off** | [ ] — the scoreboard is **not a ranking, it is a 2D scatter**, and every entrant so far sits at one extreme. GP-CAT/GP-ORD reject every knockout, armed hazard and inversion — and throw away ~60% of the real corpus. OP-CAT accepts 96% of real protocols and no random noise at all — and misses 27% of knockouts, cases that differ from a working protocol by one symbol. Plot recall against knockout rejection; the empty top-right corner is the finding. A one-number ranking would hide it entirely. |
| F18 | **The ratio diverges** | [ ] — accept(REAL)/accept(RANDOM) goes to infinity at zero random acceptance, so a merely-very-strict model looks infinitely good. Never render the headline number alone; the knockout gate is the binding constraint and must sit beside it. |
| F24 | **Validity is the diagonal** | [ ] — the cleanest geometric statement of the model, and it arrived via a refutation. Plot `Fix(Γ)` against `Fix(Δ)`: closure fixpoints on one axis, warrant fixpoints on the other. **Admissible = the diagonal**, where the coordinates agree. This is exactly why bilattices fail us — Avron's representation theorem makes every interlaced bilattice a componentwise product, and a componentwise structure is blind to the diagonal. Two axes, one line through them; a protocol is valid only where it is both closed and warranted. |
| F25 | **The safe-composition region** | [ ] — the user-facing payoff, if the AFT result verifies. Composition preserves validity exactly on the **stratifiable** fragment (Vennekens-Gilis-Denecker Thm 3.5, an iff). That turns "can I compose these?" from unanswerable into a region you can be inside or outside. Draw the boundary, not a verdict — an integrator needs to see *how far* from safe a given pair is. **Gated on T0**: our `Γ` and `Δ` are two different operators where AFT has one, so this may not apply at all. |
| F20 | **The council convergence graph** | [ ] — 162 nodes, 655 edges, 10 communities over the nine reports; the communities *are* the disputes. Three hyperedges worth drawing directly: unanimous 9/9 that Terra sits outside element types, unanimous 9/9 that X11a's polarity is the defect, and **Aave v3 as the shared falsifying witness** against `{Fl,Xm}` — three reports overturn it, a fourth keeps it while conceding the same false positive. Built at `algebra/graphify-out/graph.html`. |
| F21 | **Where the lone dissenter was right** | [ ] — the vote split 8–1 twice, with a *different* dissenter each time, and both times the minority was correct: OP-CAT alone derived stratum from a typing functor, OP-LOG alone recovered meet as intersection. This is the argument for nine over three and it belongs on screen — majority position is not evidence. |
| F22 | **Inert tiles — elements the predicate cannot see** | [ ] — three entrants converge from different directions: GP-LOG finds **14 elements structurally invisible** to its validity predicate, GR-ORD finds 4 ungrounded (`Wg, Cv, Sb, Sd` — no corpus evidence either way), OP-ORD finds 4 with empty extent over the 72 largest protocols (same four). So a quarter of the table may do no work at all. Draw inertness on the tile: an element that never affects validity is not the same object as one that does, and the packed form currently renders them identically. |
| F23 | **The mixed-term fork** | [ ] — five terms pair an element with a prose alternative (`Tg \| bounded emergency process`). We resolved them one way (undecidable → residue); **GP-LOG resolved them the other way**, promoting `Gp` for L15 and `At` for L8 into formal elements, evidence-driven from named corpus protocols. Both are defensible and they give different closure results. This is a fork in the data, not a bug — show which branch a given reading is on. |
| F19 | **Effective generating set: 56, not 58** | [ ] — OP-CAT reports `St`/`Wg` collapse under observational equivalence, plus one further pair. If it holds, two tiles in the table are not elements and the packed form is drawing a distinction that does not exist. Verify against the other order-theoretic entrants before redrawing. |
| F16 | **The four wanted impossibilities** | [ ] — D1–D4 are the outcomes we most want proved, not failures to hide. D2 especially: that no function of element sets separates USDT from USD1, i.e. **solvency is not a function of mechanism inventory**. If it lands it is the project's strongest claim and needs the loudest object on screen. |

## G. Known defects to fix

| # | Defect | Status |
|---|---|---|
| G1 | `protocols.ts` holds 12 protocols; we have 60 | [ ] |
| G2 | ~~Euler fails closure for an unrelated reason~~ — **RESOLVED, and worse than a coincidence: it was our bug.** Euler had a bounded emergency process, just not a timelock, and L15 permits either. Euler closes. The Lock-Up's climax must be rebuilt on something real. | [✓] diagnosed |
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
