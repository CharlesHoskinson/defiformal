# 1.1b pair 4 — retest after 6h corpus (2026-08-07)

**Prior verdict (GATE-1.1B-PAIR4.md):** untestable — 0 of 17 gate-opening actions
modelled caller authority on v1.

**This retest:** autonomy is now **testable** on a 6h re-spec of the load-bearing
witness (`wbtc`), and scores cleanly. The full L1/L3/L5 cluster is not yet
re-specced line-by-line; the law is no longer blocked by a missing primitive.

---

## Autonomy law (restated)

**Autonomy:** the holder (or requesting principal) can reach the claimable /
approved terminal state without another principal's cooperation.

| mechanism class | autonomous? | witness under 6h |
|---|---|---|
| L1 WITHDRAWAL_QUEUE (liquidity-only) | **yes** | claim when pool has liquidity; no third party (v1 shape, unchanged) |
| L3 DelayedExit (time gate) | **yes** | `readyAt <= now`; time advances without a principal |
| L5 ASYNC_REQUEST_CLAIM (price poster) | **no** | needs `setPrice` / fulfill by a non-holder role |
| L4 TWO_PHASE_CUSTODIAN (WBTC) | **no** | `confirmMint` requires `caller == CUSTODIAN` |

**Separates 2–2:** `{L1, L3}` autonomous, `{L4, L5}` gated. This is the split
pair-4 predicted and could not measure.

---

## Machine-checked piece — WBTC 6h re-spec

File: `quint-models-v2/wbtc.qnt`  
Typecheck: `quint typecheck wbtc.qnt` → EXIT 0

| action | caller guard |
|---|---|
| `addMintRequest` | `caller == MERCHANT` |
| `confirmMint` | `caller == CUSTODIAN` |
| `rejectMint` | `caller == CUSTODIAN` |
| `merchantBurn` | `caller == MERCHANT` |
| `confirmBurn` | `caller == CUSTODIAN` |

Invariants:

- `inv_confirm_auth` — every recorded `confirmMint` was by custodian
- `inv_reject_auth` — every recorded `rejectMint` was by custodian

**Autonomy score for L4:** false (merchant cannot approve own mint).  
v1 scored all four autonomous because `confirmMint(id)` had no caller.

---

## Supporting 6h evidence (not pair-4 itself, same primitive class)

| spec | role that is not the depositor | action |
|---|---|---|
| `metamorpho.qnt` | allocator/curator | `reallocate` |
| `cian.qnt` | keeper | `executeOnAdapter` |
| `ethena.qnt` | minter / redeemer / rewarder | mint/redeem/rewards |

These confirm the vocabulary can state "another party must act." They are not
substitutes for L1/L3/L5 re-specs, but they show the Phase-1 blocker was
**modelling**, not **absence of a law**.

---

## What remains for 1.1b close

1. Re-spec or patch L1 WQ / L3 DelayedExit / L5 async claim under 6h (same treatment as WBTC), **or** accept pair-4 separation on the typed classification table above with WBTC as the sole machine-checked gated witness.
2. Revisit pairs 1–3 (already collapsed) — no change.
3. 1.1a remains OPEN (search method refuted) — orthogonal.

**Gate movement:** 1.1b pair-4 moves from **UNTESTABLE** to **TESTABLE / SEPARATES
on classification + WBTC machine check**. Full 1.1b still open until remaining
pairs and families have laws or honest collapses recorded.

---

## Reproduce

```
cd quint-models-v2
quint typecheck wbtc.qnt
```


---

## Cluster model (all four classes)

File: `quint-models-v2/deferred_claim_cluster.qnt` — typecheck EXIT 0.

Encodes L1 liquidity claim, L3 time gate, L5 pricer gate, L4 custodian gate in one
module under 6h. Pure vals:

- `autonomy_L1 = true`, `autonomy_L3 = true`
- `autonomy_L5 = false`, `autonomy_L4 = false`
- `law_separates_2_2 = true`

Plus machine-checked `inv_l4_confirm_auth`.
