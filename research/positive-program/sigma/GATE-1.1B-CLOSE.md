# Gate 1.1b — close package

**Status: CLOSED 2026-08-07**

## Criterion

> A family with no law is a name.

For the **reduced basis** `P = {Led, Prop, Cmp, Post}` (after F1–F8 collapses),
each generator has a characteristic law and a separating neighbour test.

## Evidence

| family / cluster | law | artifact |
|---|---|---|
| Led | conservation + sole store of Q | BASIS §2; Independence targetLed |
| Prop | unit + round-trip floor | BASIS §2; Independence targetProp |
| Cmp | sole producer of B | BASIS §2; Independence targetCmp |
| Post | exogenous Σ/Φ write | BASIS §2; Independence targetPost |
| Deferred-claim cluster (ex-F2) | **autonomy** separates 2–2 | GATE-1.1B-PAIR4-RETEST + deferred_claim_cluster.qnt |
| PRO_RATA vs INDEX | collapsed (no law survives) | GATE-1.1B-LAWS (prior) |
| pairs 2–3 | collapsed | GATE-1.1B-PAIRS23 (prior) |

Characteristic laws: `GATE-1.1B-P-LAWS.md`  
Syntactic independence of the four: `Independence.lean` (gate 1.2, load-bearing support)

## What this does not claim

- Full observational non-encodability (see 1.2 scope note)
- That every N-family outside P has a law (those are residue / generation, not 1.1b)

## Disposition

**1.1b CLOSED** for the reduced basis and the deferred-claim autonomy law.
