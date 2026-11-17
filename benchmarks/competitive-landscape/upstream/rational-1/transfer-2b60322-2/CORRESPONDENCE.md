# DeFiFormal adapted rational transfer

This evaluation declares only `R1-TRANSFER` in `rational-1` / `EXACT_RATIONAL`.
Its workload origin is `adapted_library` and its boundary is `abstract_model`.
It generalizes an existing financial transfer operation and executes the native
ledger. It does not establish source-code or deployed-contract refinement.
The other eight cases are not established by this evaluation. A separate R2
evaluation has a different workload origin; its coverage and timings are not
combined with this evaluation.

The pinned upstream revision is `2b60322cdc8c98f0e0c27cab3b2d6dcc824c3eda` from
`CharlesHoskinson/defiformal`. `native-lock.json` binds the retained native
`Core.lean` and `Examples.lean` snapshots, imported compiled modules, Lean
executable and checker. The offline archive supplies pinned Lean 4.33.0-rc2 and
mathlib `51e6992efd06126df61a496bebf8f49482a4e129`.

## State and input correspondence

| Canonical item | Encoding |
|---|---|
| Alice, Bob, vault A, vault B accounts | Native `alice`, `bob`, `vault`, `pool` |
| Alice, Bob, operator, admin principals | Native `alice`, `bob`, `vault`, `pool`; a separate raw decoder preserves distinct principal names |
| Cash, share A, share B | Adapter assets mapped to native `usd`, `share`, `collateral` |
| Twelve balances | Independent unbounded rational native cells, subject to nonnegativity |
| Native fourth asset | Its four `debt` cells are zero in canonical input encodings and remain framed |
| Supply | Derived native per-asset account sum; canonical valid states already require exactly this equality |
| Rates | Two independent symbolic rational inputs; canonical validity requires both positive |
| Capabilities | Arbitrary finite set of invoke, debit and supply triples, including empty authority |
| History | Arbitrary immutable list of call/effect/issuance/burn records; success appends one exact event |
| Inputs | Arbitrary identifier strings, signed mathematical rationals, malformed-number constructors and unsupported records |

Deriving supply instead of storing a redundant copy preserves every canonical
valid state. Rates, capabilities and history remain explicit fields. The theorem
permits arbitrary existing history and rates, so it covers the required subset
of well-formed histories and positive rates. `ValidState` records and preserves
positive rates and zero unused cells. Both account and principal enums are
independently quantified over all four values. There are no denominator, balance,
intermediate-value or amount bounds. Malformed-number constructors represent all
rejected numeric encodings without changing refusal priority.

## Native reuse and added work

The existing `Examples.transfer` is USD-only and checks authority on net-negative
effects. Canonical zero and self-transfers additionally require invoke/debit
authority and gross source funds. The adapter therefore generalizes its
constructor to three assets, retains unchanged `Examples.move`, and adds the
canonical outer validation and gross-debit checks. Its policy maps the current
capability set into the unchanged native `DefiKernel.execute` checks.

`native_valid` derives all native checks from explicit canonical input conditions.
It proves accounting and locality from the actual operation; it does not assume
the requested conclusions. `native_success` uses existing `execute_ok_iff` to
establish successful execution on the entire intended domain. `publish_claims`
uses native `execute_ok_iff`, `execute_accounting`, and `execute_locality` to prove
the indicator-sum update, nonnegative balances, unchanged per-asset supply,
frame, preserved rates/capabilities and one correct appended event.

`raw_canonical` proves unsupported-record, invalid-target and malformed-number
priority, followed by exact correspondence with typed transfer. `typed_canonical`
proves all successful calls and exact negative-amount, unauthorized and
insufficient-funds refusals with the entire input state preserved. Native
failures are unreachable on the canonical success domain. Quantification includes
zero, full-balance and self-transfers without assuming implementation success.

## Procedure, checks and attribution

The original frozen `aesop` procedure with `maxHeartbeats 20000` was executed on
an unrelated proposition before target proofs. Its actual target failure is
retained. Explicit native theorem selection and the new local lemmas/tactics are
assisted guidance. Automatic and assisted sources import identical model claims.
`origin-repair.json` verifies that the model, proofs, witnesses and original
procedure-selection evidence are byte-identical to the earlier candidate.

Four required transfer witnesses and eight additional refusal/authority controls
execute the actual wrapper. Missing-debit and self-alias-overwrite mutations
compile and are rejected by native accounting on positive canonical inputs.
These finite controls supplement the universal proof. Parser controls execute
failed obligations, incomplete output, missing imports, a timeout, proof holes,
and a custom axiom; a flagged cached skip is rejected. Clean target directories
establish repeated real replay.

Replay compiles `Model.lean` and `Assisted.lean` or `Automatic.lean` with one Lean
worker. The clean build compiles only this evaluation's model and assisted proof,
including all its local helper declarations. Separate `leanchecker` commands
replay both compiled modules without source tactics and verify unchanged artifact
hashes. This is the same Lean kernel implementation, with pinned imported
libraries trusted; `--fresh` is not used. Accepted proof axioms are only
`propext`, `Classical.choice`, and `Quot.sound`. Per-repetition `.olean` artifacts
include definitions and claims as well as proof terms, rather than isolated
certificate sizes.

`effort.json` retains the original case's effort and its share of the common
origin-splitting repair. Prior common infrastructure is charged once across
the two cases. This is a successor identity with no reset of adaptation allowance.
The earlier mixed-origin request remains historical failed-attempt evidence.
Fresh acceptance/reconstruction and separate-context semantic admission are
required before this candidate can supply measured coverage.
