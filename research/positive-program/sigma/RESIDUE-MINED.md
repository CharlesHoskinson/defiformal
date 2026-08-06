# The residue, mined

Artifact: `sigma/residue-index.json` — 324 residue entries across 72 protocol
entries, each tagged with a bucket. Scripts: `sigma/residue_mine.py`,
`sigma/residue_mandate.py`.

---

## 1. The 72-vs-68 discrepancy is resolved

`ROADMAP` says 72 named applications; `GATE-2.2-WORKLIST.md` measured 68. Both
are right. The lane JSONs carry **72 protocol entries**; four are the same
application appearing in two lanes (Steakhouse Financial is filed under both
*Yield / vaults* and *Prediction markets & other*). 68 is the distinct count.

**2.2 precondition 1 is settled.** No applications are missing; the work-list of
19 stands.

## 2. Bucket counts

| bucket | entries | applications |
|---|---|---|
| UNCLASSIFIED | 131 | 59 |
| **authority/discretion** | **69** | **40** |
| off-chain/legal | 43 | 23 |
| settlement/matching | 28 | 24 |
| rate/price-of-credit | 21 | 18 |
| strategy/policy | 11 | 10 |
| risk-budget/cap | 8 | 7 |
| liveness/keeper | 8 | 7 |
| scoping/inheritance | 5 | 5 |

**Authority/discretion is the largest classified bucket — 40 of 72 applications
have at least one entry in it.**

Caveat: the buckets are keyword-based and mine, not the corpus's, and **131
entries are unclassified across 59 applications** — more than any single bucket.
The classification is a first cut for navigation, not a result. Every assignment
is in the JSON so it can be checked.

## 3. The refuter is not a singleton — and it is the best-witnessed object in the corpus

Narrowing the authority bucket to entries naming *a party exercising discretion
over assets it does not own* gives **4 distinct protocols across 4 categories**:

| protocol | category | the mechanism |
|---|---|---|
| **Morpho** | Lending | "a MetaMorpho curator chooses which isolated markets a depositor's funds enter, sets per-market caps, and takes a performance fee — an allocation mandate over other people's capital" |
| **Liquity (V1+V2)** | CDP | "delegating a risk parameter to a third-party manager — V2 batch managers set interest rates on borrowers' behalf for a fee" |
| **Steakhouse Financial** | Yield / Risk Curators | "a named firm decides which isolated markets a depositor's capital enters, at what supply cap, and rebalances at will, for a performance fee. **This is the entire protocol.**" |
| **Grove Finance** | uncategorized | allocates on-chain capital (largely Sky/Spark) into off-chain credit, with "manager discretion" |

**Liquity's own residue notes the shape-identity, unprompted:** *"This is the
same shape as Morpho's curator gap, appearing in a completely different
category."* Two lanes, independently.

### Why this matters more than the count

`GATE-1.1A-RECOUNT.md` established that **every** candidate primitive reaching
>= 2 witnesses did so through shared-`common.qnt` reuse — 28 of 28, zero
independent re-implementations. These four are the opposite: different protocols,
different categories, different lanes, no shared code, converging on the same
mechanism.

**So the one object in the corpus with genuinely independent multi-witness
support is the one the basis cannot express.** Under gate 1.1's own condition 1
it is better evidenced than any family the basis contains.

## 4. Also confirmed: the liveness cluster

`liveness/keeper` is small (8 entries, 7 applications) but coherent — CIAN
(keeper must call rebalance or the vault liquidates), Yearn and Beefy (harvest,
and the harvest-caller incentive), Jupiter (scheduled/time-sliced execution).
That is pair 4's autonomy property, named by four protocols before Phase 1 tested
it.

## What to do with this

1. **Treat the delegated mandate as a candidate primitive, not only a refuter.**
   It has four independent witnesses and a law candidate (owner-locality
   violation). It clears condition 1 in a way nothing else does.
2. **The unclassified 131 are unmined.** More than any bucket. Worth a second
   pass with better classification before the residue is called read.
3. **Do not quote the bucket counts as findings.** They are navigation.

## Reproduce

    python3 sigma/residue_mine.py
    python3 sigma/residue_mandate.py
