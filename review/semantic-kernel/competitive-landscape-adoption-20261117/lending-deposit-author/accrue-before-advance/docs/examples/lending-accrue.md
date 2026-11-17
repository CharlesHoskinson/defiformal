# Unindexed exact-rational lending accrual

`DefiKernel.Lending.Accrue` executes a borrower-bound Typed operation that
increases the owner's debt and debt supply by `D * r * dt`. Debt is denominated
one-for-one in cash under the lending conventions; it is a liability, not cash.
The scalar rate `r` is per caller-supplied abstract time unit and `dt` uses that
unit. Both must be nonnegative. No fee, cash transfer or collateral transfer is
included. This is a reference operation, with no deployed-source equivalence claim.

The operation reads the actual owner's pre-ledger debt cell. Its evaluated
footprint contains the two reads needed by the balance and supply expressions;
the declared footprint covers that cell. The actual Typed executor checks the
claimed borrower against the invocation principal, invocation authority, the
parameter guard, supply authority and accounting. Positive increments require
debt-supply authority. An increment of zero needs only invocation authority;
negative parameters still refuse even when their product is nonnegative or zero.
There is no debit and no cash-funding premise. Capability provisioning uses the
real administrative API for both borrowers. Authentication remains an input
assumption of that API and invocation context.

`actual_effects` derives `D' = D * (1 + r * dt)` and the authenticated owner from
successful execution. `actual_frame` preserves every other ledger cell,
including all free and locked collateral and cash. `actual_accounting` conserves
cash and collateral totals while increasing aggregate debt by the explicit debt
supply delta. `enabled_success` constructs success from nonnegative parameters
and invocation/supply rights, without assuming a successful result or a Valid
certificate. `negative_parameter_refusal` gives the exact guard refusal after
owner binding and invocation authority have been established. Refusals return no
post-world; this does not constitute an observed rollback theorem.

Accrual has no health guard or oracle input. A control starts at debt 2, locked
collateral 2 and an illustrative price 2: the first call produces debt 4,
breaching `2D <= Cp` while leaving zero equity (`D = Cp`). Repeating the call
produces debt 8 and negative equity (`D > Cp`). Both succeed with unchanged cash
and collateral. Collateralization-threshold failure and negative equity are
different observations; no preservation of either is claimed.

Intervals are deliberately unindexed. No last-accrual timestamp, replay guard or
rate-authentication mechanism exists here. `repeated_interval` proves that two
actual successes with the same supplied parameters produce
`D'' = D * (1 + r * dt)^2`; `enabled_twice` constructs both successes. Repeating
the same interval is not idempotent and generally differs from one call with
`2 * dt`. The controls observe debt `2 -> 4 -> 8` versus one combined call's 6.
Authentic rates and distinct/nonoverlapping elapsed intervals are external
obligations for a lifecycle integration, not proved by this operation.

With the pinned Lean 4.33.0-rc2 toolchain and project dependencies installed:

```sh
python3 scripts/replay_lending_accrue.py --toolchain /path/to/lean-4.33.0-rc2
```

This builds the actual module and freshly executes 21 nonempty, fail-on-false
controls. The command reports input/tool hashes; exit 0 means those finite
comparisons passed, exit 1 means a contradiction/build failure, and exit 3 means
missing, empty, unreadable or unavailable inputs. Generic proofs, named axiom
disclosure and kernel replays are separate evidence. Kernel replay trusts the
import closure and is not an independent verifier or outside reproduction.
Mutation probes execute altered API-prefix bodies without importing the intact
Accrue cache, and separately reject the altered sources with unchanged proofs.

The hash-bound physical-line accounting is in
[the component record](../../benchmarks/component-accounting/lending-accrue.json).
It excludes shared support and records a wall interval, not active effort or
person-hours. Historical authoring effort and the separate-effort reuse scenario
remain unavailable. Collateral deposit and withdrawal, the complete IV.4 family,
outside reproduction and source refinement remain open. Existing Borrow, Repay,
Types and historical permissive debt-burn examples are unchanged.
