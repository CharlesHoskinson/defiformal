# Gate 1.3 — measured disposition

**Status: MEASURED 2026-08-07**

## Non-degeneracy

| check | result | evidence |
|---|---|---|
| Q ≠ Σ | holds | BASIS §1: Post writes Σ; Q closed under Led no-forgery |
| T ≠ Q | holds | time only advances; never transfer |
| Φ ≠ N | holds | phases written; USERS fixed index |
| B only from Cmp | holds by design | BASIS / interface track |
| no pure rename of P_i | holds informally | IR deletion distinct mass (GATE-1.2-DELETION-IR) |

## Sufficiency

| check | result | evidence |
|---|---|---|
| P generates full corpus | **FAILS** | Gate 2.3 rates 16.7% / 16.6% |
| residual empty | **FAILS** | residue docs; 2.2 exclusions |

## Disposition

1.3 is **MEASURED**: non-degeneracy **PASS**; sufficiency **FAIL**.

Do not re-open generation claims via this gate.
