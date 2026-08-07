# Sub-gate 1.1b — the first law test, and it returns a negative

**Verdict: no law separates `PRO_RATA_SHARES` from `INDEX_ACCRUAL`. Eight
candidates were tested, three appeared to separate, and all three died under
audit. On the gate's own criterion — "a family with no law is a name" — these are
one family, not two.**

Scripts: `sigma/gate11b_laws.py` (the test), `sigma/gate11b_audit.py` (the audit).
Definitions transcribed verbatim from `quint-models/L1/common.qnt:14-105`.

This is the first gate condition in the programme that a harness cannot fake. A
witness count can be an artifact of where a definition sits; a law either
separates its neighbour or it does not.

---

## Why this pair

Both reduce to `mulDivDown(a, b, c)`. `BASIS.md` already merges their parents
(F1/F6 into `Prop` + `Post`) on that ground, and the corpus shows the same
observable implemented both ways — Morpho stores no index and accrues by mutating
`totalSupplyAssets`, Aave stores `liquidityIndex` and calls `accrueIndex`. If any
pair in the corpus needs a law to stay distinct, it is this one.

---

## The test

Eight laws, stated before testing, each run against both mechanisms over the same
domain. Laws that hold for both, or fail for both, are reported as such —
selecting only the separating ones afterwards is how a basis gets manufactured.

| candidate law | pro-rata | index | separates? |
|---|---|---|---|
| L1 ratio-pair scale invariance | true | false | apparently |
| L2 round-trip contraction | true | true | no |
| L3 zero preservation | true | true | no |
| L4 superadditivity | true | true | no |
| L5 operation preserves its ratio | false | true | apparently |
| L6 ratio non-decreasing | true | true | no |
| L7 some operation strictly increases the ratio | true | true | no |
| L8 conversion writes a ratio component | true | false | apparently |

Three apparent separators. None survives.

---

## The audit

**L5 is an integer-flooring artifact.** In exact arithmetic pro-rata deposit
preserves `A/S` identically: minting `s = aS/A` gives
`(A+a)/(S + aS/A) = (A+a)/(S(A+a)/A) = A/S`. Measured over the same domain, the
ratio is preserved in **every** case under `Fraction` arithmetic and in only some
under `mulDivDown`. The separation is a property of the fixed-point encoding, not
of the mechanism. **Rejected.**

**L1 is a signature difference wearing a law's clothes.** `assetsFromShares(x, A,
S)` takes both ratio components as parameters; `presentFromScaled(x, index)`
fixes its denominator as the module constant `INDEX_BASE`. Scale *both*
components of the index pair and invariance holds exactly —
`mulDivDown(999, 3i, 3·BASE) == mulDivDown(999, i, BASE)`, verified. L1 separates
the two *signatures*, and a signature difference is not a law. **Rejected.**

**L8 was asserted, not measured — and the measurement reverses it.** Pass one
hardcoded "pro-rata deposit writes both totals; index deposit writes neither
component", from a toy model rather than the corpus. Measured across the 51
protocol specs:

| family | call sites | also write a ratio component |
|---|---|---|
| pro-rata | 10 | 7 (**70%**) |
| index | 13 | 13 (**100%**) |

The claim is backwards. Every `aave_v3`, `compound_v3` and `fluid` action that
converts also writes its index, because real lending protocols accrue before they
act — `supply` calls `accrueIndex` then `presentFromScaled`. Meanwhile `beefy`'s
and `huma`'s pro-rata deposits write no total at all. **Rejected**, and rejected
by evidence pointing the opposite way from the assertion.

---

## What this establishes

1. **`PRO_RATA_SHARES` and `INDEX_ACCRUAL` are one family.** Eight laws, zero
   separations. This confirms `BASIS.md`'s F1/F6 merge, but now on tested grounds
   rather than by argument — and the argument and the test agreeing is worth
   something, since almost nothing else in this programme has survived being
   tested.
2. **The family count falls.** Two of the ~16 named families collapse into one.
   The same test must now be run on every remaining adjacent pair, and the
   collapse rate on the hardest pair is not encouraging for the estimate.
3. **The audit step is mandatory, not optional.** Three of eight candidates
   looked like separators. Three failure modes, all of which will recur:
   - **floor artifacts** — a separation that exists only in fixed-point
     arithmetic and vanishes in exact arithmetic;
   - **signature dressed as law** — a difference in what is a parameter versus a
     constant, which says nothing about the mechanism;
   - **asserted, not measured** — a row filled in from a mental model of the
     corpus rather than from the corpus. This one is the most dangerous, because
     it produced a confident table entry that the corpus contradicts outright.

---

## What to do next

- **Run this test on the remaining adjacent pairs**, hardest first. Every pair
  that fails to separate collapses two families into one.
- **Every proposed law carries its audit**: exact-arithmetic check, a statement
  of whether it is a law or a signature property, and a measurement against the
  51 specs rather than a mental model.
- **Do not report a separation count without the audit column.** Pass one's
  headline was "3 of 8 separate". The true figure is 0 of 8.

## Reproduce

    python3 sigma/gate11b_laws.py
    python3 sigma/gate11b_audit.py
