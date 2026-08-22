# quint-models-v2 — bounded verification sweep

    quint verify <model>.qnt --invariant=inv_all --max-steps=8

Five minutes per model, quint 0.32.0 with Apalache, run 2026-08-22.

`quint run` is randomised simulation: its `[ok]` means *not falsified at this
budget*. `quint verify` is bounded model checking: its result is a proof up to
the step bound. All 19 models report `[ok]` under `quint run` at 4000 samples
(`VERIFICATION.md`). This is what happens when they are actually checked.

| model | verdict | elapsed |
|---|---|---|
| `apex.qnt` | TIMEOUT | 301s |
| `cian.qnt` | TIMEOUT | 300s |
| `compound_v3.qnt` | TIMEOUT | 301s |
| `curve.qnt` | DIV-BY-ZERO | 7s |
| `deferred_claim_cluster.qnt` | VERIFIED | 6s |
| `derive.qnt` | TIMEOUT | 301s |
| `ethena.qnt` | TIMEOUT | 300s |
| `gmx.qnt` | TIMEOUT | 301s |
| `huma.qnt` | DIV-BY-ZERO | 7s |
| `jupiter_perps.qnt` | TIMEOUT | 301s |
| `liquity.qnt` | DIV-BY-ZERO | 10s |
| `lista.qnt` | TIMEOUT | 300s |
| `metamorpho.qnt` | TIMEOUT | 301s |
| `morpho_blue.qnt` | TIMEOUT | 300s |
| `okx_dex.qnt` | TIMEOUT | 301s |
| `polymarket.qnt` | UNSUPPORTED | 18s |
| `uniswap_v2.qnt` | TIMEOUT | 300s |
| `usd1.qnt` | TIMEOUT | 301s |
| `wbtc.qnt` | VERIFIED | 13s |

| outcome | models |
|---|---|
| verified to depth 8 | 2 |
| no verdict in five minutes | 13 |
| stopped on a division by zero | 3 |
| not encodable by this backend | 1 |

**2 of 19 carry a proof.** The other 17 carry a `quint run` sample and nothing
stronger.

## The division-by-zero rows are what the sweep was for

Three models stop within ten seconds on a state Apalache reaches immediately
and 4000 random samples never constructed:

    curve.qnt      Input error: Division by zero at 0 // 0
    huma.qnt       Input error: Division by zero at 699 // 0
    liquity.qnt    Input error: Division by zero at 8000000000 // 0

Each of those three reports `[ok]` under `quint run --invariant=inv_all`. The
gap between the two commands is not hypothetical, and this is it.

What this is *not*, yet, is a protocol finding. A denominator that can reach
zero in a model may be unreachable in the protocol, guarded by something the
model does not carry. Deciding which requires reading all three, and that is
not done here. The defensible statement is narrower: three models admit a
state their invariants have never been evaluated against.

## The timeouts are not passes

13 of 19 models gave no verdict in five minutes. A timeout is evidence in
neither direction, and reading one as reassurance is the vacuity this
repository's gates exist to refuse. They are counted separately from the 2
that verified, and they are not included in any claim of correctness.

`polymarket.qnt` is a third case again: Apalache cannot encode it, rejecting
a sequence length derived from a fold. That is a limitation of the backend,
not a statement about the model.

## A note on the classifier

The sweep first reported all four non-timeout, non-verified rows as `ERROR`,
because it grepped for the word. Apalache prints

    As of 2022/09/29 (release 21.7) makeExtensionsImmutable should be called

on every run, successful ones included. Re-read from the actual verdict lines,
those four rows are two distinct outcomes with different meanings. A checker
that greps for "error" finds one in every log that contains a warning --
which is the same defect class as a checker that greps for "agree" and finds
it in a filesystem path.
