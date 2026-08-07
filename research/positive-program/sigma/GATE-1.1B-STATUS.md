# Gate 1.1b — status after pair-4 retest (2026-08-07)

## Verdict

| sub-item | status |
|---|---|
| pair 1 (PRO_RATA vs INDEX) | **collapsed** (prior) — no separating law survives audit |
| pairs 2–3 | **collapsed** (prior) — artifact taxonomy |
| pair 4 (deferred-claim cluster) | **SEPARATES via autonomy** — now testable under 6h |
| full "law per family" | **OPEN** — remaining basis families still need laws or honest collapses |

## Pair 4 evidence

1. `quint-models-v2/wbtc.qnt` — 6h custodian guards; typecheck OK
2. `quint-models-v2/deferred_claim_cluster.qnt` — L1/L3/L5/L4 shapes; `law_separates_2_2`
3. Write-up: `GATE-1.1B-PAIR4-RETEST.md`

Autonomy: `{L1, L3}` yes, `{L4, L5}` no.

## Why 1.1b is not closed yet

"A law per family" requires every remaining family in `BASIS.md` either:

- a separating law against its nearest neighbour, or
- an audited collapse (as pairs 1–3).

Pair 4 unblocking removes the Phase-2 dependency that froze the gate. It does not
by itself certify Prop/Post/Led/Cmp/… independence — that is still 1.2 after laws
exist.

## Next actions (ordered)

1. Enumerate live families post-collapse from `BASIS.md` § current list.
2. For each adjacent pair, state one candidate law *before* testing (gate11b discipline).
3. Only then open 1.2 pairwise independence.
