# Gate 2.2 — the work-list, enumerated for the first time

**19 named applications have no spec. They are listed below. `ROADMAP` has said
"72 named, 51 specced, 21 unspecced" since it was written and never named one of
them, so the gate has had no work-list for its whole life.**

Script: `sigma/gate22_worklist.py`.

---

## The 19

| category | applications |
|---|---|
| Bridges / cross-domain | Binance Bitcoin (BTCB) |
| CDP / collateral-backed stables | Ethena (USDe / sUSDe), Lista CDP |
| **Intents / aggregation / order flow** | **Binance Wallet, DFlow, LiquidMesh, OKX DEX** |
| Liquid staking & restaking | Binance staked ETH (WBETH) |
| Options / structured products | Aevo (Ribbon lineage), Rysk V12 |
| Perpetuals / derivatives | Aster, Jupiter Perpetual Exchange, edgeX |
| Prediction markets | Kalshi |
| RWA / tokenised treasuries | BlackRock BUIDL, Circle USYC (Hashnote) |
| Reserve-backed / fiat stables | World Liberty Financial USD1 |
| **Yield / vaults / aggregators** | **CIAN Yield Layer, Steakhouse Financial** |

## Three things this list says

**1. The refuter's own protocol is on it.** `Steakhouse Financial` is unspecced,
which is exactly what `REFUTER-DELEGATED-ALLOCATION.md` argued: the programme
recorded it as "a known refuter … needs no further work" while never formalising
it. The work-list confirms it independently. `CIAN Yield Layer` sits beside it in
the same category, and `VERDICT.md` §1 groups Yearn, Beefy and CIAN as the
comparison Steakhouse dwarfs — so a second delegated-allocation instance is also
unspecced.

**2. Intents is the worst-covered category and it is four of the nineteen.**
`VERDICT.md` reports intents coverage at **~25%**, the lowest of any lane, and
four of its applications have no spec at all. The category where the vocabulary
already failed hardest is also the one with the least formalisation.

**3. The counts do not match `ROADMAP`, and are reported rather than
reconciled.**

| | ROADMAP | measured |
|---|---|---|
| named applications | 72 | **68** |
| protocol specs | 51 | **50** |
| unspecced | 21 | **19** |

`corpus50/lanes/*.json` holds 68 distinct named applications. Where 72 came from
is unknown — a different list, or a count including duplicates across lanes.
**Resolve this before commissioning 19 specs**, since the gap is four
applications nobody can currently name.

The single orphan spec is `metamorpho`, written this session and legitimately not
in the lane list.

## On the matcher, which needed three passes

Worth recording because two of the three failures were silent.

1. **First cut stripped `\bv\d+\b` before removing punctuation.** "Aave V3"
   became `aave`, `aave_v3` became `aavev3` — the underscore is a word character
   so there is no boundary before `v3`, and the version survived on one side
   only. Result: **48 unspecced, 28 orphan**, i.e. it matched almost nothing. A
   work-list built on that would have commissioned specs for protocols that
   already have them.
2. **Second cut** removed punctuation first and added a containment pass. Down to
   23 unspecced, 5 orphan — but four orphans were plainly the same protocol
   (`1inch`/`oneinch`, `GMX V2 Perps`/`gmx`, `EigenCloud`/`eigenlayer`,
   `PayPal USD`/`pyusd`).
3. **Third cut** added an explicit alias table rather than loosening the matcher,
   which would have started making matches nobody checked. One alias key was
   itself wrong — `GMX V2 Perps` normalises to `gmxv2`, not `gmxv2perps`, because
   the noise-word pass strips "perps" *after* the version pass has already run.

Every containment and alias match is printed by the script. A matcher this fiddly
has to show its work.

## Before any of the 19 is commissioned

1. **Resolve the 72-vs-68 discrepancy.** Four named applications are
   unaccounted for.
2. **Check contract availability per protocol.** `protocol-repos/` holds 47
   repos, and they skew heavily toward the *already specced* protocols. Several
   of the 19 — Kalshi, BUIDL, Binance products — may have no public contracts at
   all, in which case they cannot be specced to the Phase 2 standard and that
   must be declared, not quietly skipped.
3. **Adopt convention 6h first.** Otherwise 19 new specs inherit the defect that
   blocks Phase 1, and `Steakhouse`/`CIAN` in particular are delegated-allocation
   mechanisms that cannot be stated without callers.

## Reproduce

    python3 sigma/gate22_worklist.py
