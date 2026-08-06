# 1.1b pair 4 — the deferred-claim cluster, and Phase 1's real blocker

**Verdict: the cluster cannot be separated on the v1 corpus, and the reason is
not that the mechanisms are the same. It is that the distinguishing mechanism was
deleted from every spec. Phase 1 is blocked on the honest corpus.**

Script: `sigma/gate11b_pair4_cluster.py`.

---

## The cluster

Four names, one skeleton — record a request, wait for a gate to open, claim:

| row | lane | shape |
|---|---|---|
| `WITHDRAWAL_QUEUE` | L1 | `queueShares: str -> int` |
| `DelayedExit queue` | L3 | `QueueItem {owner, amount, readyAt}` |
| `ASYNC_REQUEST_CLAIM` | L5 | `AsyncRequest {owner, amount, price, phase}` |
| `TWO_PHASE_CUSTODIAN_REQUEST` | L4 | `CustodianRequest {requester, amount, status}` |

They differ in exactly one place: **what opens the gate.**

| | gate |
|---|---|
| L1 | nothing — claimable once the pool has liquidity |
| L3 | **time** — `readyAt` |
| L5 | **a posted price** — `Pending -> Priced` |
| L4 | **an authority** — `Pending -> Approved`, "onlyCustodian" |

## The candidate law, and why it is the right one

**Autonomy.** Can the holder reach `claimable` without another party's
cooperation? Time passes on its own; a custodian may refuse. This would split the
cluster **2-2** — `{L1, L3}` autonomous, `{L4, L5}` gated by a principal — rather
than collapsing it, and it would be the first separating law in the programme.

It is a good law: it is a liveness property, it is not arithmetic (so no floor
artifact), and it is not a signature difference. It says something a user of the
protocol would care about — whether their exit can be blocked.

## It cannot be tested, because the specs deleted the mechanism

| mechanism | gate-opening actions | with any caller/authority guard |
|---|---|---|
| L1 `WITHDRAWAL_QUEUE` | 1 | **0** |
| L3 `DelayedExit` | 6 | **0** |
| L5 `ASYNC_REQUEST_CLAIM` | 9 | **0** |
| L4 `TWO_PHASE_CUSTODIAN` | 1 | **0** |
| **total** | **17** | **0** |

Not one spec models who may open the gate. In all four mechanisms the gate is
opened by an unguarded action that any step may fire, so all four score
*autonomous* and the law separates nothing.

**`wbtc.confirmMint` is the clean witness.** Its comment reads
*"Factory.confirmMintRequest — onlyCustodian; mints WBTC to merchant"*, and its
signature is `(id: int)`. The custodian's authority **is** the primitive —
`TWO_PHASE_CUSTODIAN_REQUEST` exists as a separate row precisely because "mint
authority is split merchant-request / custodian-confirm" — and it is not in the
spec. The name survives; the mechanism does not.

### A note on this script's own first cut

It reported **3 of 17** guards. All three were false positives: `owner` was in
the detector's word list, and `owner` is a *field* of `QueueItem`,
`AsyncRequest` and `CustodianRequest`, so `l2Balances.put(hd.owner, ...)` and
`maxMint.put(r.owner, ...)` matched. A record field read as an access-control
check. Artifact class 3 — asserted, not measured — caught by inspecting what
matched rather than trusting the count.

---

## This is an eleventh deletion, and it is outside Phase 2's ten

`P2-SCOPE` identified ten deleted mechanisms across ten protocols, all of them in
the Phase 2 re-spec list. **`wbtc` is not on that list**, and its deletion is the
same class: a mechanism named in a comment, absent from the code beneath it —
exactly the `morpho_blue.qnt:156` shape.

So the ten were not the whole population. They were the ten found by looking at
the ten protocols someone looked at. **Phase 1 found an eleventh by asking a
different question**, and there is no reason to think it is the last.

---

## The consequence, which reorders the roadmap

Phase 1 was recorded as blocked on gate 0.1 alone. 0.1 is withdrawn, so Phase 1
was thought to be free. It is not.

**1.1b needs laws. Laws need mechanisms. The v1 specs deleted the mechanisms.**

The three earlier pairs collapsed and it was possible to read that as lane-local
duplicate naming. This pair does not collapse — it is *untestable*, which is a
different and worse finding, because it means the corpus cannot answer the
question at all. The autonomy law is almost certainly real; nothing in the corpus
can confirm it.

**Therefore Phase 1 is blocked on Phase 2**, specifically on re-specs that keep
access control. Neither the ten v2 re-specs nor the 21 unspecced applications
currently carry a requirement to model who may call what.

### Recommendation

1. **Add access control to the Phase 2 fidelity criterion.** `P2-FIDELITY` and
   `P2-CONTRACT` govern what a faithful re-spec must retain. Caller authority is
   not among the conventions, and this pair shows it is load-bearing for Phase 1.
   It belongs alongside convention 6g.
2. **Re-order: 2.2 before the rest of 1.1b.** The remaining adjacent pairs will
   hit the same wall wherever their separating law depends on a deleted
   mechanism, and there is no way to know which those are without trying.
3. **Record `wbtc` as deletion 11** and re-scan the other 41 unre-specced protocol
   specs for the same class before trusting any Phase 1 result drawn from them.

## Reproduce

    python3 sigma/gate11b_pair4_cluster.py
    grep -n -B2 -A8 "action confirmMint" quint-models/L4/wbtc.qnt
