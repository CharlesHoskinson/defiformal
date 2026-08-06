# Gate 1.1 — first scoring, and why the gate is not answerable yet

**Verdict: gate 1.1 cannot be scored on the current evidence base. Condition 2 is
unmet corpus-wide, and condition 1 is unanswerable because the ledgers count
witnesses per lane while the gate asks corpus-wide.**

Script: `sigma/gate11_witnesses.py`. It scores the 52 recorded section-5 rows
rather than inventing a syntactic predicate per family — whoever writes such a
predicate already knows which answer they want.

---

## What the gate asks

> Every family has >= 2 corpus witnesses and a law that fails for its neighbours.
> A family with no law is a name.

Two conditions. They are scored separately below, and both are in trouble.

---

## Condition 1 — witnesses

| | rows |
|---|---|
| >= 2 witnesses recorded | 31 |
| exactly 1 witness recorded | **19** |
| no count recorded (prose) | 2 |
| total | 52 |

Per lane: L1 7/3/0, L2 4/2/1, L3 5/5/0, L4 5/5/0, L5 6/1/1, L6 4/3/0.

**But this cannot be read as "19 families fail."** The ledgers are lane-scoped,
and their own cells say so: `WITHDRAWAL_QUEUE` is "Maple (1 **in lane**; appears
in other categories)", EigenLayer's magnitude budget is "(1 **in lane**;
restaking category)", `COMPLEMENTARY_OUTCOME_SPLIT` is "Polymarket (1 **in
lane**; CTF family)", `RateLimit envelope` is "Spark — n=1 **in lane** but
structural". A row with one witness in L3 may have three more in L1.

So 19 is an upper bound on the failures and a lower bound on nothing. **The
recorded evidence cannot answer the question the gate asks.** Closing condition 1
requires re-counting witnesses across all 57 specs, not within lanes — which is
work that has not been done and was not visible as missing until the gate was
scored.

### The names most at risk

`ROADMAP` 1.1 estimates ~16 families and names them. Several map onto rows that
are singletons even before the cross-lane question is settled:

| named family | backing row | recorded n |
|---|---|---|
| tranche subordination | `Tranche waterfall` (L3) | 1 |
| delegation | `DELEGATED_INTENT_STATUS` (L4) | 1 |
| | custody-free delegation SM (L2) | 1 |
| limit orders | `BATCH_CLEARING` (L4) | 1 |
| | `SIGNED_ORDER_REMAINING` (L4) | 2 |
| custody | `TWO_PHASE_CUSTODIAN_REQUEST` (L4) | 1 |
| | `CUSTODIAL_WRAPPED_SUPPLY` (L4) | 3 |
| rate curves | `RateLimit envelope` (L3) | 1 |
| | `UTILIZATION_TWO_SLOPE` (L1) | 4 |
| once-only delivery | `ATTESTED_MESSAGE_ONCE` (L4) | 2 |
| trading function | `CONSTANT_PRODUCT_SWAP` (L1) | 6 |

The strong end (trading function, rate curves via utilisation, custody via
wrapped supply) is well witnessed. The weak end — tranche subordination,
delegation, batch clearing — currently rests on one protocol each.

---

## Condition 2 — laws

**Unmet corpus-wide, and this is the harder half.** The ledgers carry a
`why it is primitive` column. It is a rationale, not a law:

    CONSTANT_PRODUCT_SWAP  ->  same algebraic step (x+din_f)(y-dout) >= xy with ...
    PRO_RATA_SHARES        ->  assets<->shares via assets * totalShares / totalAssets
    INDEX_ACCRUAL          ->  present = scaled * index / BASE; index monotone in ...

Four of 52 rationales contain an equation at all. None states **a law that fails
for its neighbours**, which is what the gate demands and what makes a family a
family rather than a name. `PRO_RATA_SHARES` and `INDEX_ACCRUAL` above are the
sharpest case: both reduce to `mulDivDown(a, b, c)`, and the quoted rationales do
not separate them — which is exactly the merge `BASIS.md` §F1/F6 already
performs.

**Condition 2 is unmet for all 52 rows regardless of condition 1.** No amount of
witness re-counting closes it. Laws must be written.

---

## What this changes

1. **Gate 1.1 stays open, with its blocker restated.** It was "not started,
   blocked on 0.1". 0.1 is resolved, so it is now blocked on two concrete pieces
   of work rather than on a withdrawn claim.
2. **New sub-gate 1.1a — recount witnesses corpus-wide.** The 52 rows carry
   lane-local counts. The gate asks a corpus question. Until the recount exists,
   no family can be said to pass or fail condition 1.
3. **New sub-gate 1.1b — write one law per surviving family.** A law that its
   nearest neighbour violates. Start with the pair the corpus already shows is
   hard: `PRO_RATA_SHARES` vs `INDEX_ACCRUAL`, which share an arithmetic form
   and must be separated by something other than it.
4. **Do not prune the singletons yet.** Nineteen rows look like singletons and
   the evidence cannot yet distinguish "one witness in the corpus" from "one
   witness in this lane". Pruning now would delete families for a bookkeeping
   artifact — the same error `qsigma2` made with `init`.

## Reproduce

    python3 sigma/gate11_witnesses.py
