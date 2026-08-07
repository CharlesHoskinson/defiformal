# Gate 1.1a — method restatement (2026-08-07)

## Prior finding (unchanged)

Identifier search found **0 independent** multi-witness rows; all ≥2 counts were
shared-`common.qnt` reuse. `layerzero` vs `cctp` proves search under-counts real
independent instances (`GATE-1.1A-RECOUNT.md`).

## Restated condition 1

> Every family has ≥ 2 **independent** corpus witnesses.  
> Two specs calling the same `common.qnt` definition count as **one** witness.

## Method (to run, not a number)

Per candidate primitive / family:

1. List claiming specs from lane JSON + BASIS rows.
2. **Semantic read** each protocol `.qnt`: does it instantiate the mechanism
   under any names?
3. Classify each positive hit as:
   - `SHARED` — body is import of lane common helper only
   - `INDEPENDENT` — local definition of the mechanism
4. Independent count = number of INDEPENDENT hits (SHARED group collapses to 1
   only if no independent exists alongside; if both, independents alone count).

Do **not** quote old 28/50 or 31/19/2 figures as evidence.

## Seed example (manual, partial)

| primitive | independent witnesses | notes |
|---|---|---|
| attested once-only delivery | `cctp` (common helper), `layerzero` (local PacketStatus) | search missed layerzero |
| two-phase custodian mint | `wbtc` v1 + v2 | v2 adds authority |

Full semantic census of 50+ specs is the remaining 1.1a work — method is now
fixed; number not yet produced.

## Status

**OPEN — method fixed, census not complete.**
