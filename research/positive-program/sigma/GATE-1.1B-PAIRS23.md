# 1.1b, pairs 2 and 3 — three pairs tested, three collapses

**Verdict: neither pair separates. With pair 1, three adjacent pairs have now
been tested and all three are single families. Six named families collapse to
three.**

Scripts: `sigma/gate11b_pairs23.py`, `sigma/gate11b_pair3_audit.py`.

---

## Pair 2 — L3 `RateLimit` vs L6 `RateLimit`

The "RateLimit envelope" (L3) and "LINEAR_REFILL_RATE_LIMIT" (L6) rows. Tested by
**extensional agreement** under the field mapping `maxAmount<->capacity`,
`lastAmount<->remaining`, `lastUpdated<->lastTime` — two definitions agreeing on
every well-formed state are the same primitive whatever they are named.

| domain | agree | differ |
|---|---|---|
| all states | 380 | 20 |
| **well-formed** (capacity > 0, slope > 0, 0 <= remaining <= capacity) | **165** | **0** |

Every disagreement sits at `capacity <= 0` or `slope <= 0`, where L6 adds guard
clauses returning `0` or `remaining` and L3 does not. That is defensiveness in
one transcription, not a different mechanism. **No separation — one family.**

---

## Pair 3 — L1 `isHealthy` vs L3 `maintainsMargin`

Five laws. Two appeared to separate, and the exact-arithmetic replay agreed with
integer arithmetic everywhere — so neither was a fixed-point artifact, the pass-1
failure mode. Both died anyway, to two artifact classes that were not on the
pass-1 list.

**P4 (monotone in price) — asymmetric test design.**

| | favourable argument | adverse argument |
|---|---|---|
| `isHealthy` | monotone up in `collPrice` — **true** | monotone up in `debtPrice` — **false** |
| `maintainsMargin` | monotone up, Long — **true** | monotone up, Short — **false** |

Pass one compared `isHealthy`'s *favourable* price against `maintainsMargin`'s
*adverse* side. Both predicates are monotone in their good argument and
anti-monotone in their bad one. The separation was a property of the test.
**Rejected.**

**P5 (surplus never negative) — a domain that never crossed the threshold.**
Pass one compared non-corresponding quantities: `isHealthy`'s *backing*
(collateral value, unsigned by construction) against `maintainsMargin`'s *equity*
(signed). The counterpart of equity is the health **surplus**. Recomputed, the
surplus was negative in 0 of 36 cases — but only because the chosen domain
contained no unhealthy states at all. Widened so it crosses the threshold:

    isHealthy surplus < 0 in 54 of 90 cases     (narrow domain: 0 of 36)
    e.g. (100, 5, 500, 20) -> collateral value 500, debt value 10000

Both mechanisms carry a signed health quantity that goes negative exactly when
the predicate fails. **Rejected.**

**This one is worth naming precisely: it is a violation of the programme's own
convention 8c** — the domain must hold values on both sides of every constant
appearing in a comparison — committed in a Phase 1 law test rather than a Phase 2
spec. The convention was written to stop a spec certifying a mechanism its domain
could not reach. Here it stopped a law test certifying a separation its domain
could not reach. Same failure, different phase.

---

## Running tally for 1.1b

| pair | laws tested | separating | verdict |
|---|---|---|---|
| `PRO_RATA_SHARES` vs `INDEX_ACCRUAL` | 8 | 0 | one family |
| L3 `RateLimit` vs L6 `RateLimit` | extensional | 0 | one family |
| `isHealthy` vs `maintainsMargin` | 5 | 0 | one family |

**Three pairs, three collapses, zero separating laws.** Every apparent separator
so far — five of them across the three pairs — has died under audit.

---

## The artifact taxonomy, now at five classes

Each was found by an apparent separator that did not survive. All five will
recur, and every future law must be checked against the list.

1. **Floor artifact** — the separation exists only in fixed-point arithmetic and
   vanishes under exact arithmetic. *(pair 1, L5)*
2. **Signature dressed as law** — a difference in what is a parameter versus a
   constant. *(pair 1, L1)*
3. **Asserted, not measured** — a cell filled in from a mental model of the
   corpus; the corpus reversed it. *(pair 1, L8)*
4. **Asymmetric test design** — the two mechanisms handed arguments that are not
   each other's counterparts. *(pair 3, P4)*
5. **Domain that never crosses the threshold** — convention 8c, violated in a law
   test. *(pair 3, P5)*

---

## What this means for the family estimate

The ~16-family estimate is under real pressure. Three of the adjacent pairs
chosen as *hardest* have each turned out to be one family, and the corpus offered
the merge argument in two of the three cases before the test was run (`BASIS.md`
already merges F1/F6; the two `RateLimit` definitions are a transcription of one
mechanism into two lanes).

**This is not yet evidence the basis is small.** It is evidence that the *naming*
was lane-local: the same mechanism, met in two lanes, was written down twice.
That is a bookkeeping fact about how the corpus was built, and it is the same
root cause as 1.1a's finding that every witness count was shared-`common.qnt`
reuse. The lane structure generated both the duplicate families and the witness
counts that appeared to support them.

**Next:** the remaining adjacent pairs, hardest first — the deferred-claim
cluster (`WITHDRAWAL_QUEUE` / `DelayedExit queue` / `ASYNC_REQUEST_CLAIM` /
`TWO_PHASE_CUSTODIAN_REQUEST`), which is four names for what may be one
two-phase-request mechanism.

## Reproduce

    python3 sigma/gate11b_pairs23.py
    python3 sigma/gate11b_pair3_audit.py
