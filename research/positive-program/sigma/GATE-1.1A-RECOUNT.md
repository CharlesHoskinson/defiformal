# Sub-gate 1.1a — the witness recount, and why condition 1 must be restated

**Verdict: the recount cannot close condition 1, and the attempt found something
worse. Every candidate primitive that reaches >= 2 witnesses does so because two
specs in the same lane call the same `common.qnt` helper. Not one is witnessed by
two protocols that implement it independently.**

Scripts: `sigma/gate11a_recount.py` (the count), `sigma/gate11a_provenance.py`
(the classification).

---

## 1. The method under-counts, and `layerzero` proves it

Each section-5 row names the Quint identifiers realising its candidate primitive.
Searching the 51 protocol specs for those names gives 28 of 50 searchable rows at
>= 2 witnesses, against 31 of 52 on the lane-local record.

That number is not trustworthy, and one case settles it. `ATTESTED_MESSAGE_ONCE`
is recorded as "CCTP, LayerZero (2)". Identifier search finds only `cctp`,
because it looks for `common.canDeliverOnce` / `markUsed`. But `layerzero.qnt`
**does** implement once-only delivery — `type PacketStatus = Sent | Verified |
Delivered`, keyed by nonce, with `verify` and delivery guarded on status. It
implements the same primitive under its own names.

So the ledger is right and the search is wrong. **Identifier reuse and mechanism
instantiation are different properties**, and searching for the first cannot
decide a question about the second.

A second probe was inconclusive in the other direction: `CASH_SETTLED_EUROPEAN`
is recorded n=3, search finds only `derive`, and `hegic`'s payoff is exercise
*before* expiry — which is precisely not European, so it may be a ledger
overclaim. **The two sources disagree in both directions and neither is reliable
for this gate.**

---

## 2. What the run does establish soundly, and it is the real finding

Classify every row reaching >= 2 witnesses by where its identifiers are *defined*:

| class | rows | meaning |
|---|---|---|
| **shared-only** | **28** | every identifier is defined in a lane `common.qnt` — ONE implementation, called k times |
| mixed | 0 | |
| **independent** | **0** | some witness defines the mechanism itself |

Zero. Not one candidate primitive in the corpus reaches two witnesses through two
independent implementations. Every count is a shared helper with callers.

The complement holds too: the protocol-local definitions that do exist —
`justlend`'s `exchangeRate`, `convex`'s `lockCrv`, `layerzero`'s `PacketStatus` —
all belong to rows scoring **under** 2. The two categories are nearly
complementary.

**So condition 1, as currently measurable, is a test of whether a definition sits
in a `common.qnt`. Nothing more.** The lane refactoring created the shared
helpers; the shared helpers then produced the witness counts. The measurement is
a function of the harness, not of DeFi — the same shape as the `init` scan that
sank gate 0.1 and the deleted mechanisms that motivated Phase 2.

---

## 3. What condition 1 should say instead

> Every family has >= 2 corpus witnesses

should become

> Every family has >= 2 **independent** corpus witnesses, where two specs calling
> the same `common.qnt` definition are **one** witness, not two.

The justification is evidential, not stylistic. Two protocols sharing a helper
show that one implementation was written once and imported twice — which is a
fact about the spec authors. Two protocols arriving at the same mechanism through
different code is evidence the mechanism is forced by the domain, which is the
claim a basis makes. `cctp` and `layerzero` are that evidence; the count cannot
see them.

**Under the restated condition the current evidence base supports approximately
nothing**, and that is the honest position. The real witnesses exist — layerzero
is one — but they must be found by reading the specs, not by grep.

---

## 4. Consequences

1. **1.1a stays open and gets a method, not a number.** Per-row semantic reads
   against the 51 protocol specs, asking "does this protocol instantiate the
   mechanism", not "does it call this name".
2. **Adopt the independence refinement into the gate** before any recount is run,
   or the recount will re-certify shared helpers.
3. **The `>= 2 witnesses` figures in `GATE-1.1-WITNESSES.md` (31/19/2) and in
   this recount (28/50) should not be quoted as evidence for or against any
   family.** Both measure identifier provenance. Recorded here so they are not
   re-derived and believed later.
4. **Still do not prune the singletons.** The reason has changed and strengthened:
   a row scoring 1 may have an independent second implementation that no search
   will surface.

## Reproduce

    python3 sigma/gate11a_recount.py
    python3 sigma/gate11a_provenance.py
    grep -n "PacketStatus\|nonce" quint-models/L4/layerzero.qnt
