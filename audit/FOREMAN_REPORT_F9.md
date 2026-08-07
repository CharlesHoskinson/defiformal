# Cold re-audit final: Gate 0.2 F9

**Audit date:** 2026-08-07

**Mode:** Read-only source audit, except for this report

**Verdict:** **APPROVE**

## Executive finding

The prior blocking statement is corrected. `Extremal.lean:31` now reports 52
`acc + ...` folds and one identity fold. No scoped file claims 53 of 53 folds
are `acc + ...` or that all folds are `acc + ...`.

Fresh scanner execution reports 53 total folds, 52 `acc_plus` folds, one
`acc_neutral` fold, and zero other folds. The sole neutral fold is in Apex.

The Lean package passes the build and trust checks. The formal separation still
proves its precise, documented claim. The remaining limitations are documented
out-of-scope items and do not block this gate.

## Gate summary

| Check | Result | Evidence |
|---|---|---|
| Prior census overclaim | **PASS** | No scoped 53/53 or all-folds-`acc+` claim remains. |
| Balanced fold census | **PASS** | 53 total, 52 `acc_plus`, 1 `acc_neutral`, 0 other. |
| Lean build | **PASS** | `lake build` completed successfully with 978 jobs. |
| Standard axioms | **PASS** | Headline F9 theorems use only `propext` and `Quot.sound`. |
| Formal separation | **PASS** | Equal local views force an accept-and-reject contradiction for claim A. |
| Scope honesty | **PASS** | Full F9, operational composition, and Quint-AST reduction remain out of scope. |

## 1. Prior blocker: cleared

The module documentation now gives the verified census at
`lean/Defialgebra/Extremal.lean:29-32`. It states 52 `acc + ...` folds and one
identity fold. It also states that the census only motivates the formal class.

A scoped search found no occurrence of these rejected claims:

- `53/53`
- `53 of 53`
- All folds are `acc + ...`

The other count statements agree with the module documentation:

- `GATE-0.2-F9.md:23-27` reports 52 of 53 plus one identity fold.
- `GATE-0.2-FOLD-CENSUS.md:7-10` reports 53 total, 52 sum folds, and one neutral fold.
- `ROADMAP.md:21-29` reports 52 of 53 plus one identity fold.
- `ROADMAP.md:118` summarizes the census as 52 plus one.

## 2. Fold census: pass

`fold_census.py:16-43` extracts each `.fold(` expression through its balanced
closing parenthesis. `fold_census.py:46-54` classifies only that extracted
expression.

Fresh read-only execution of the scanner logic produced:

```text
total=53 acc_plus=52 acc_neutral=1 other=0
```

The only neutral expression is in `quint-models/L3/apex.qnt`. Both branches
return `acc`. The following sum fold is outside the balanced expression and
does not affect its classification.

## 3. Build and trust basis: pass

Fresh verification ran from `lean/` with Lean 4.33.0-rc2 and Lake 5.0.0.

```text
lake build
Build completed successfully (978 jobs).
```

`lake env lean Defialgebra/Extremal.lean` exited 0 without diagnostics.

`lake env lean Axioms.lean` exited 0 and printed these headline results:

```text
'Defialgebra.Extremal.extremal_not_local' depends on axioms: [propext, Quot.sound]
'Defialgebra.Extremal.extremal_not_sumLocalProg' depends on axioms: [propext, Quot.sound]
'Defialgebra.Extremal.f9_irreducible_to_sum_local' depends on axioms: [propext, Quot.sound]
```

The scoped Lean module contains no `sorry`, `admit`, custom `axiom`, `opaque`,
`unsafe`, or `native_decide` declaration.

The full build emitted existing warnings from other modules. None invalidates
the scoped F9 theorem or its trust basis.

## 4. Formal separation: pass

`extremalFill` is a general priority sort followed by demand-bounded prefix fill
at `Extremal.lean:65-82`. It is not a witness-specific allocator.

`SumLocalProg` contains arbitrary atomic sum-local predicates and finite
conjunctions at `Extremal.lean:93-103`. `localSel_and` proves closure behavior at
`Extremal.lean:121-125`.

The witness populations have the same `SumAgg (2, 2, 1)` at
`Extremal.lean:138-141`. Claim A has the same fields in both populations.

The general allocator selects claim A in population AB and claim C in
population AC at `Extremal.lean:171-182`. A matching local predicate must accept
claim A in AB and reject it in AC. `sumAgg_eq` makes those local observations
equal, which gives the contradiction at `Extremal.lean:221-234`.

`extremal_not_sumLocalProg` applies the stronger predicate separation to every
program evaluation. `f9_irreducible_to_sum_local` exposes that theorem under the
roadmap name at `Extremal.lean:236-250`.

## 5. Scope and residuals

The Lean module and gate document explicitly exclude these claims:

- The full F9 record with settlement price, limit vectors, and conservation games
- Operational `⋈` composition of BASIS machines
- A mechanized reduction from all Quint programs to `LocalSel`
- The delegated-allocation mandate refuter

These are documented out-of-scope items. They do not weaken the proved
separation for the stated sum-local filter class.

No required in-scope action remains.

## Final decision

**APPROVE.** The sole prior blocker is gone. The census, build, axioms, formal
separation, and scope statements now agree.
