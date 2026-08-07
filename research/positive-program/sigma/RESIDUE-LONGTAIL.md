# The unclassified residue is a long tail — a negative result that matters

**Verdict: the 131 unclassified entries do not hide a second structural class.
They are protocol-specific one-offs. `authority/discretion` remains the only
refuter-sized cluster in the corpus.**

Script: `sigma/residue_unclassified.py`.

---

## Method, deliberately not the previous one

The first classifier used buckets invented before reading the data and left 131
of 324 entries unclassified — more than any bucket it found. Guessing a second
keyword set would repeat that. So: term frequency over the unclassified subset
first, then read the largest candidates in full.

**No dominant term.** The most frequent is `price` at **12 of 131 (9%)**,
followed by `claim` 11, `collateral` 11, `pool` 10, `liquidity` 9, `oracle` 8.
Compare `authority/discretion`, which reached 69 entries across 40 of 72
applications.

## The two largest candidates dissolve on reading

**`price`/`oracle` — 17 entries, 15 applications, 15 different mechanisms.**
Curve's CryptoSwap repegging invariant; Ethena's market-maker whitelist; crvUSD's
continuous soft liquidation; EigenLayer's intersubjective adjudication;
Hyperliquid's endogenous validator-median oracle; Aster running two
price-formation regimes at once; GMX's open-interest-imbalance price impact and
its bid/ask oracle spread; Yearn's profit-unlock drip; Centrifuge's NAV pushed as
an oracle update across chains. These share a word, not a mechanism.

**`claim` — 11 entries, 11 applications, 11 different mechanisms.** Uniswap's
non-fungible per-range LP accounting; Pendle's YT decaying notional; Convex's
liquid wrapper of a locked position; Spark's one savings claim across 8 chains;
Ondo's security interest; USYC's offering memorandum. Same.

### Two weak sub-themes, named but not promoted

Worth recording since they are the only recurrences at all:

- **execution-quality attribution** (~6 entries) — Jupiter's zero-slippage oracle
  execution and route-quality guarantees, GMX's bid/ask spread, KyberSwap's
  gas-aware routing, DFlow's order-flow segmentation, CoW's surplus attribution.
  All in DEX/intents, the category `VERDICT.md` already scores worst (~25%).
- **claim transformation** (~4 entries) — Pendle YT decay, Convex's liquid
  wrapper, Polymarket's conditional-token split/merge, Uniswap's NFT position.

Neither is close to a refuter. Both are candidates for a future pass, not
findings now.

## Why a negative result is worth the pass

`GATE-1.1A-RECOUNT.md` showed no basis family has independent multi-witness
support. `RESIDUE-MINED.md` showed the delegated mandate has four such witnesses
across four categories. The open question was whether the unmined 131 hid another
object of that size.

**They do not.** The corpus has *one* structural gap with independent
multi-protocol support, not several. That sharpens the paper: there is a single
large irreducible object to characterise, and a long tail of protocol
idiosyncrasy that no basis of any size was ever going to absorb.

## Honest limits

- Term frequency plus a full read of the two largest word-groups is **not** proof
  that no cluster exists. A structural class whose members share no vocabulary
  would be invisible to both. The claim is: no cluster is visible by the two
  cheapest methods, and the largest candidates dissolved.
- The residue is what the lane authors chose to write down. Absence here is
  absence from their notes.

## Reproduce

    python3 sigma/residue_unclassified.py
