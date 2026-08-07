# Gate 2.3, restricted to the ten — the floor claim does not hold

**Result: restoring the deleted mechanisms left the generation RATE unchanged.
16.7% of protocol definitions ungenerated in v1, 16.6% in v2, on the same ten
protocols against the same basis. The roadmap has said since pass 3 that 743/820
was "a floor" because the difficulty had been deleted. On rate, it was not.**


**Reproduction (2026-08-07):** IR trees under `sigma/gen-ir-v1ten` and
`sigma/gen-ir-v2ten`. Re-run:

```bash
cd research/positive-program/basis
python3 compare_v1_v2.py    # protocol ungen totals 28 and 119
python3 denominators.py     # dens 168 / 716 -> 16.7% / 16.6%
```

Fresh re-run reproduced **v1 protocol ungenerated 28, v2 protocol ungenerated 119**.

**Execution-order note:** measurement was first recorded before the W2 delivery
write-up; W2 cold-read (`GATE-2.1b-W2.md`) is retrospective validation of the
same closed specs. Logical order is 2.1b before 2.3; historical write order was
2.3 then 2.1b record.

Scripts: `basis/compare_v1_v2.py`, `basis/denominators.py`, `basis/generate.py` (`GEN_IR`). IR is committed under `sigma/gen-ir-v*ten/`.

---

## Method

`quint parse` produced IR for the ten v2 re-specs. Each was rebuilt as a two-module
file: the **v1 lane's own `common`** as basis, and the protocol module as spec.
Same basis, same criterion, honest specs versus deleted ones.

**`kernel.qnt` counts as SPEC CONTENT, not basis.** `sqrt`, `kernel` and
`kernelCheck` declarations are merged into the spec module, so `isqrt`, `newtonD`
and the sorted walk are checked like any other definition and their `imul`/`idiv`
are tested against `Π_hard` rather than licensed. Admitting them as basis would
grow the basis to contain exactly what the protocols turned out to need — the
degeneracy `GENERATION.md` §1(a) already diagnoses.

## The numbers

Raw totals are not comparable: the v2 re-specs carry T0 vectors, `wit_*`
obligations, `inv_*` invariants and the kernel, none of which exist in v1.

| | v1 ten | v2 ten |
|---|---|---|
| definitions tested (raw) | 172 | 1605 |
| ungenerated (raw) | 28 | 681 |
| — of which apparatus (`t0_`/`wit_`/`inv_`) | 0 | 359 |
| — of which kernel | 0 | 203 |
| **— of which PROTOCOL** | **28** | **119** |
| protocol definitions total | 168 | 716 |
| **ungenerated protocol rate** | **16.7%** | **16.6%** |

The absolute count of ungenerated protocol definitions quadrupled. The **rate did
not move.**

## Both of these are true, and they are not the same claim

**The restored mechanisms ARE outside the basis.** The definitions ungenerated in
v2 but absent from v1's list are precisely what Phase 2 restored: `geometricMint`,
`ammAmountOut` and `mintFeeLiquidity` (uniswap's deleted sqrt and fee),
`exchangeDy` (curve's Newton), `markPriceAccBase` and `positionLiquidatable`
(apex's deleted size-dependent trigger), `impactUsd` and `applyExponentFactor`
(gmx's deleted price impact), `matchOrders` and `matchTakerAgainstMakers`
(polymarket's matching walk), and liquity's `redeemPrefix` family. Qualitatively,
`P2-SCOPE` was right about every one.

**And the rate is unchanged.** The re-specs also introduced many definitions that
*are* generated — the decomposition into named `pure def`s that convention 4 and
the T0 discipline require. The new ungenerated mechanisms and the new generated
plumbing arrived in the same proportion as before.

So the correct statement is: **the deletions changed WHICH definitions fail, not
HOW MANY as a fraction.** The roadmap's "true incompleteness is worse; that number
is a floor" is not supported by this measurement.

## Limits, and they matter

- **Ten protocols, not 51.** These ten were selected *because* they were the
  ungenerated ones, so 16.7% against the corpus-wide 9.4% is expected and the two
  figures are not comparable. Only the v1-vs-v2 column comparison is.
- **The apparatus/kernel filter is a heuristic** — prefixes `t0_`, `wit_`, `inv_`,
  `h\d\d`, and kernel names. Misclassification moves numerator and denominator
  together, but not necessarily equally. The rule is in
  `basis/compare_v1_v2.py` and can be re-run with a different one.
- **Denominator composition changed.** v2 has 4.3x the protocol definitions,
  because the re-spec conventions demand named intermediate defs. A rate over a
  differently-shaped population is a weaker comparison than a like-for-like one,
  and no like-for-like exists — the v1 specs simply do not contain the mechanisms.
- **`step` is reported "generated in v2, ungenerated in v1" for all ten**, and
  several others (`approxD`, `openLongPos`, `swapOut`, `tradeYes`) are renames
  rather than repairs. Those columns should not be read as fixes.

## What this does to the roadmap

`ROADMAP` gate 2.3 asked for "a number defensible under review". This is one, for
ten of the 51, and it does not say what the programme expected. The honest
consequence is that **the case for 2.2 no longer rests on "the corpus is worse
than measured"** — that has now been tested on the only ten protocols where it
could be, and the rate held. 2.2 has to be justified as coverage, not as
correction.
