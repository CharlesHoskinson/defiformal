# Gate 1.2 — pairwise independence, formalized

**Status: CLOSED (syntactic non-definability)** 2026-08-07

## Claim

No primitive in `P = {Led, Prop, Cmp, Post}` is a term over the others
(BASIS §2 “not definable from the others”).

## Machine check

| artifact | role |
|---|---|
| `lean/Defialgebra/Independence.lean` | inductive term language + deleted languages |
| `pairwise_independence` | four non-definability theorems, sorry-free |
| `lake build Defialgebra.Independence` | **PASS** |

### Method

1. Full language: constructors for Led / Prop / Cmp / Post + constants.
2. For each primitive `X`, language `TermNoX` omits `X`’s constructors.
3. Embedding `toTerm : TermNoX → Term` preserves “does not use X”.
4. Target term for `X` has `usesX = true` and is well-typed.
5. Therefore no image of `TermNoX` can match the target’s `usesX` bit.

### Targets (linked to corpus)

| primitive | target | corpus witness |
|---|---|---|
| Led | `ledCredit (qConst 1)` | usd1.mint / L6 transfer |
| Prop | `prop 100 50 200` | sharesFromAssets |
| Cmp | `cmpLe 150 100` | morpho isHealthy / lista safe |
| Post | `postS (sConst 42)` | shockPrice |

See also `GATE-1.2-WITNESSES.md`, `GATE-1.2-DELETION-IR.md`.

## Scope honesty

This closes **syntactic** independence of the BASIS generators as term formers.
It does **not** rule out every possible *semantic encoding* that smuggles one
primitive into another (e.g. coding booleans as quantities). The interface
discipline (M1) and sort split Q/Σ block the main smuggling paths argued in
BASIS; full observational non-encodability is out of scope for this gate.

## Reproduce

```
cd lean && lake build Defialgebra.Independence
```
