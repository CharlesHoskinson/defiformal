# Gate 2.1b — W2 delivery record (compound_v3, morpho_blue, gmx)

**Status: CLOSED (2026-08-07)**
**Specs:** `quint-models-v2/{compound_v3,morpho_blue,gmx}.qnt`
**Mutants:** `quint-models-v2/mutants/{compound_v3_M1,morpho_blue_M1a,morpho_blue_M1b,gmx_M1}.qnt`

This section was missing from ROADMAP.md while W1/W3/W4 had delivery write-ups.
Pass 7 already measured that the three specs are present and substantive. This
file is the cold-read delivery record required before 2.1b may close.

## Re-verification (this close)

| claim | command | result |
|---|---|---|
| compound_v3 typechecks | quint typecheck compound_v3.qnt | EXIT 0 |
| morpho_blue typechecks | quint typecheck morpho_blue.qnt | EXIT 0 |
| gmx typechecks | quint typecheck gmx.qnt | EXIT 0 |
| respec_lint on all three | respec_lint.py | 0 findings each |
| M1 mutants typecheck | four mutants above | EXIT 0 each |

Counts:

| spec | T0-ish refs | wit_* | inv_* |
|---|---:|---:|---:|
| compound_v3 | 50 | 18 | 7 |
| morpho_blue | 41 | 19 | 7 |
| gmx | 48 | 16 | 7 |

## What v1 deleted (restored)

| protocol | restored mechanism | primary mutant |
|---|---|---|
| compound_v3 | store-front discounted absorb credit | compound_v3_M1 |
| morpho_blue | bad-debt socialisation + liquidation incentive | morpho_blue_M1a, M1b |
| gmx | non-linear price impact (convex exponent) | gmx_M1 linearisation |

## Load-bearing corrections

### Shared (all three)

inv_conservation and most mechanism invariants do not kill the primary deletion
mutant (still ok). Discrimination is by T0 vectors and live-state /
configuration-sensitive witnesses. Same meta-result as W1/W3/W4.

### compound_v3

1. Store-front residue is reachable under honest absorb; under M1 residue is 0.
2. T0 must pin the function, not only explicit arguments the mutant still takes.
3. Explicit non-use of kernel.isqrtFloor (not a silent sqrt drop).

### morpho_blue

1. Worst corpus deletion: identity assignments under a comment naming socialisation.
2. M1a vs M1b: two mutants, different kills; T0 not always tripped by M1a alone.
3. Multi-market drop is explicit (E<=) deviation D-a with LIF branch witnesses.
4. Conservation/liquidity hold on M1a — not discriminators.

### gmx

1. Linearisation revoked as droppable (P2-CONTRACT A.7); restored as M1 contrast.
2. wit_used_impactUsd dies on mutant too — usage witnesses insufficient;
   convexity / same-side T0 separates.
3. Same T0 lesson as compound_v3.

## Structural result

W2 independently reproduces: conservation does not detect restored mechanisms;
T0 and configuration-sensitive witnesses are load-bearing. Lint 0 on re-run.

## Gate consequence

All four delivery lanes (pilot, W1, W2, W3/W4) now have write-ups. 2.1b CLOSED.
2.3 unblocked — measurement remains sigma/GATE-2.3-TEN.md.


## Durable mutant-discrimination evidence

Recorded in each target spec's M1 comment block (measured when mutants were built).
Re-check mutants typecheck: `quint typecheck mutants/<name>.qnt` (EXIT 0 this close).

### compound_v3_M1

| obligation | on mutant | role |
|---|---|---|
| inv_conservation | ok | does not discriminate |
| inv_bounds / inv_inventoryBacked | ok | does not discriminate |
| inv_noUncollateralizedBorrow | ok | does not discriminate |
| inv_T0 | VIOLATION | t0_35/36/37 |
| inv_storeFrontMargin | VIOLATION | kill |
| wit_live_storeFrontResidue | ok | unreachable under M1 |

Source: compound_v3.qnt M1 comments ~L221-234.

### morpho_blue_M1a / M1b

| obligation | M1a | M1b | role |
|---|---|---|---|
| inv_conservation | ok | ok | not discriminator |
| inv_liquidity | ok | ok | not discriminator |
| inv_T0 | ok | VIOLATION | M1b kill |
| inv_noUnbackedDebt | VIOLATION | VIOLATION | M1a kill |
| inv_incentiveDerived | ok | VIOLATION | M1b |
| wit_live_socializeBadDebt | ok | ok | unreachable under deletion |

Source: morpho_blue.qnt M1 ~L221-240.

### gmx_M1

| obligation | on mutant | role |
|---|---|---|
| inv_conservation | ok | not discriminator |
| inv_bounds / inv_impactPoolBacked / inv_oiMatchesPositions | ok | not discriminator |
| inv_T0 | VIOLATION | t0_12/13 same-side |
| inv_impactConvex | VIOLATION | kill |
| wit_live_convexImpact | ok | unreachable under M1 |
| wit_used_impactUsd | VIOLATION | not separator alone |

Source: gmx.qnt M1 ~L228-242.
