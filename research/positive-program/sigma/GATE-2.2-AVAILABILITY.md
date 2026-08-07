# Gate 2.2 precondition 2 — contract availability, and what the residue already knew

**Two results. First: 0 of the 19 unspecced applications have contracts in
`protocol-repos/`. Second, and larger: the corpus's own residue notes already
name all three findings this session produced, and nobody had connected them to
Phase 1's blockage.**

Script: `sigma/gate22_availability.py`.

---

## 1. Contract availability: 0 of 19

`protocol-repos/` holds 56 repository directories, and **every one corresponds to
an already-specced protocol.** Not one of the 19 is present — not Ethena, Lista,
Aevo, Rysk, Aster, edgeX, Kalshi, BUIDL, USYC, WLFI USD1, CIAN, Steakhouse, DFlow,
LiquidMesh, or any Binance/OKX/Jupiter product.

The collection was assembled to support the protocols that got specs. It offers
nothing toward the ones that did not.

**This says "absent here", not "has no public contracts."** Several of the 19 are
Solana-native (Jupiter), CEX-adjacent or off-chain (Kalshi, the Binance
products), or permissioned issuances (BUIDL, USYC) where the interesting
mechanism may not be on-chain at all. Each needs a per-application decision, and
**each decision must be written down** — an application skipped silently is
indistinguishable from one that was specced and found to generate.

So 2.2's real cost is not 19 specs. It is ~19 contract acquisitions, then 19
specs, and an explicit declaration for every application where the mechanism is
not in a contract.

### The matcher, again

A first cut matched on any token of length >= 3 and returned **six matches, all
false**: "Binance staked ETH" -> `tethercoin_USDT` ("eth" inside "tether"),
"CIAN Yield Layer" -> `LayerZero-v2` ("layer"), "OKX DEX" ->
`hyperliquid-dex_contracts` ("dex"), "Jupiter Perpetual Exchange" ->
`Polymarket_ctf-exchange` ("exchange"), and so on. Short generic tokens identify
the *category*, never the protocol. **Fourth detector this session to produce
false positives on first run**, and the fourth caught by reading the output
rather than the total.

---

## 2. Steakhouse cannot be specced as a protocol, and does not need to be

The lane JSON's own `rank_basis` for Steakhouse Financial:

> "the LARGEST vault operator in DeFi by TVL at $3,084.0m … DefiLlama files it
> under 'Risk Curators' … **the biggest 'vaults' in DeFi are curated Morpho/Euler
> vaults**"

**Steakhouse is a firm, not a protocol.** It has no contracts of its own; it holds
a role in someone else's. That is precisely why it never got a spec, and why
`TODO` could record it as a refuter without anyone noticing the refutation had
never been exhibited — there was no artifact to exhibit.

**Its mechanism is MetaMorpho, which is on disk and is now specced.**
`quint-models-v2/metamorpho.qnt` models the owner/curator/allocator role split
and `reallocate`. So the correct treatment of Steakhouse under 2.2 is: **not a
missing spec.** It is a principal exercising a mechanism that now has one.

That removes one from the 19 and replaces it with a stated position, which is
better than a spec would have been.

---

## 3. The residue already named all three findings

This is the part worth sitting with. Reading the lane JSON's `residue` fields for
these two applications:

**Steakhouse — the refuter, verbatim:**

> "No element for the CURATOR: a named, reputationally-accountable third party
> with **discretionary authority to allocate other people's deposits** across
> markets, bounded by supply caps, subject to a timelock, and paid a performance
> fee. This is the defining object of the largest capital pool in my lane and
> there is no symbol within an order of magnitude of it."

That is `REFUTER-DELEGATED-ALLOCATION.md`, written before this session and
independently.

**Steakhouse — convention 6h, verbatim:**

> "No element for the **role SPLIT** that makes curated vaults safe (owner /
> curator / allocator …)"

That is the four-role structure `metamorpho.qnt` models, and the reason 6h exists.

**CIAN — the autonomy law from pair 4, verbatim:**

> "No element for keeper/automation dependency. These vaults do not maintain
> themselves; **an off-chain agent must call rebalance, and if it stops, the
> vault drifts into liquidation. Nothing in the vocabulary records that a
> mechanism requires an external caller to be alive.**"

That is exactly the property the deferred-claim cluster turned on — can the
holder reach their outcome without another party's cooperation — and the corpus
identified it as a gap long before pair 4 was tested.

### What that means

Three of this session's results were already written down in the corpus residue.
They were recorded as *vocabulary gaps* — things the 58 symbols could not name —
and never carried forward into the basis work, where they are not gaps in a
naming scheme but **the reason Phase 1 cannot proceed**.

The residue is not a list of things the vocabulary missed. It is a list of
mechanisms that need caller identity to state, and the corpus said so three times
in three lanes.

**Practical consequence:** the residue fields across all 68 applications should be
re-read as a source of basis candidates and refuters, not as a post-mortem on the
58 symbols. That has never been done. It is cheap — the data is on disk — and on
this sample it has a high hit rate.

## Reproduce

    python3 sigma/gate22_availability.py
    python3 -c "import json;d=json.load(open('corpus50/lanes/lane3-rwa-options-stables-prediction.json'));..."
