# Sprint 4: typed transition IR and capability authority

Implementation design, 2026-09-06. User authorized the Sprint4 checklist and
autonomous completion loop. Base `77462b61f5f537eb29b2cf162ead6567e7151ace`.
Proceed on semantic-kernel-pivot; stock GPT6 harness, native Grok/Fable review,
no Foreman. Sources: repository `AGENTS.md`, approved
semantic-kernel design, current migration progress, `DefiKernel/Core.lean`,
`DefiKernel/Contracts.lean`, defi-footguns skill and gate register. The existing
graphify query returned legacy ontology content; current source governs this
design. This file specifies work; baseline evidence is separate. New implementation
and proofs must pass the acceptance checks before being reported complete.

## Scope and module split

Add namespace `DefiKernel.Typed` without rewriting the original pilot:

| Module | Public boundary |
| --- | --- |
| `Typed/Types.lean` | Parametric identities, units, ledger, typed values, refusal vocabulary |
| `Typed/Expr.lean` | Closed expression AST, arguments, observations, evaluation, read dependence |
| `Typed/Authority.lean` | Capability table, issue/revoke semantics, actor context, authorization predicates |
| `Typed/Transition.lean` | Generic effect templates, immutable registry, invocation and checked executor |
| `Typed/Examples.lean` | Registered reference operations and nondegenerate success/refusal examples |
| `Typed/Audit.lean` | Executed checks and proof/audit import root |

Keep proofs adjacent to their definitions until file size justifies splitting.
Avoid a public operation-specific inductive or a public `State → Env → Bool`.

## Identities, units, and expression interface

Parameterize all new declarations by types `Party Asset Domain` with
`[Fintype Party] [Fintype Asset] [Fintype Domain]` and decidable equality. Keep
`ClaimId`, `CapabilityId`, `OperationId`, and `ObservationId` as distinct Nat
wrappers. A claim ID reserves vocabulary; it does not claim a claim lifecycle.

Use `Cell := Domain × Party × Asset`, a total rational balance function, and a
proof of nonnegativity as in the existing state. Define totals per domain and
asset. Require domain-local effects in this increment; cross-domain movement
belongs to later operational composition. Finite carriers are executable and
do not encode fixed Alice/Bob/vault parties into the semantics.

The following is an API sketch, not compilable implementation:

```lean
inductive Unit (Asset : Type)
  | amount : Asset → Unit Asset
  | price : Asset → Asset → Unit Asset -- quote units per one base unit
  | scalar : Unit Asset
  | bool : Unit Asset

Value : Unit Asset → Type -- Bool for bool; exact ℚ otherwise
Quantity (a : Asset) := { q : ℚ // 0 ≤ q }
Expr (signature : List (Unit Asset)) : Unit Asset → Type
eval : Expr signature u → EvalContext → Except EvalFailure (Value u)
```

Supply first-order constructors for typed literals, typed argument variables,
ledger reads, observation reads, same-unit add/subtract/negation, scalar scaling,
same-unit comparison, booleans, conditional, same-unit ratio to scalar, and
`amount base × price base quote → amount quote`. Add guarded division by a
nonzero scalar and `amount quote / price base quote → amount base` if the vault
example requires it. No unrestricted multiplication, cast, arbitrary callback,
or catch-all host expression. Reject division by zero; Lean's total rational
division must not silently turn an undefined financial expression into zero.

Signed amount expressions are dimensional rational expressions, not automatically
nonnegative quantities. Literal input quantities can use the `Quantity` wrapper;
debit signs belong to effects. Positive price and freshness requirements are
explicit operation guards, not consequences of dimension typing.

For runtime invocation, use data `List (Σ u, Value u)` and check against the
registered signature to obtain typed arguments. A small typed `Var signature u`
avoids dependent casts throughout evaluation. This is an in-Lean checked ingress,
not a serialized external parser/certificate claim.

Party selection needs only `PartyRef := caller | literal Party | argument Nat`
and a list of party arguments whose indices are checked. `CellRef` contains a
fixed domain and asset plus `PartyRef`. Resolve these references once before
expression evaluation. This permits reusable transfer/vault templates while
keeping identity selection independent of ledger or oracle values. Asset and
domain polymorphism can be handled by trusted template factory definitions;
runtime existential asset parameters are unnecessary for this sprint.

## Observations and footprints

Use typed observation keys, such as `price domain observationId base quote`,
`scalar domain observationId`, and `flag domain observationId`. An environment
contains optional values and observation timestamps for each requested key.
Missing values refuse explicitly. Timestamp reads and the current-time input
are tracked reads; freshness guards must not use an untracked external clock.
Input observations and actor identity remain adapter-supplied assumptions.

Compute required state and environment reads recursively over the complete AST:
guard, every effect expression, and every supply-change expression. Resolve
party references before producing concrete state footprints. Templates also
carry declared footprints. Check required reads are included in declarations;
extra declarations are conservative and allowed. Include both conditional
branches syntactically even when one is inactive. Write footprint checks remain
checks of actual aggregate net effects, as in the existing pilot.

Prove evaluation agreement when contexts agree on computed reads and typed
arguments. This lemma includes equal failure behavior, not just equal successful
values. Do not call it full operation noninterference: authorization also reads
registry and capability state, and those must be held fixed or tracked separately.

## Generic templates and authenticated operation selection

`Template` contains argument signature, operation domain, party-argument arity,
typed boolean guard, lists of dimensioned cell deltas and supply deltas, and
declared reads/writes. A cell delta ties `Expr signature (.amount asset)` to a
cell reference with that same asset. A supply delta uses the same asset index.
Repeated entries sum; there is no last-write-wins update. Accounting checks
aggregate effect per domain/asset against aggregate declared supply change.

`Registry := OperationId → Option Template` is trusted immutable configuration.
It may be implemented by data lookup. Request data contains operation ID, party
arguments, typed numeric arguments and capability IDs, never a template or guard.
The executor obtains the template only from registry lookup. Even a caller with
broad debit rights cannot replace the selected financial formula. Public
operation data has no arbitrary host closure. Trusted interpreter definitions
and internal total ledger functions are not an IR escape hatch.

Provide `InvocationContext` carrying the adapter's authenticated principal.
The request does not supply the authoritative actor. If request data contains a
claimed actor, require equality with the context principal before any authority
check. State plainly that this
models an authenticated boundary condition: a Lean constructor is not a digital
signature, and no theorem establishes real-world identity authentication.

## Capability issuance, revocation and use

Use a table `CapabilityId → Option Capability`, or a finite association map,
plus monotonically increasing `nextId`. Each capability has holder, scope domain,
scope operation ID, right and live/revoked state. Every capability used by an
invocation must match its registered operation ID. Rights are generic: `invoke`,
`debit cell`, and `changeSupply domain asset`. Validate that the right's resource
belongs to its scope domain and that the scope operation exists in that domain.
Exact resources keep the first authority proof small.

Use trusted immutable `domainAdmin : Domain → Party` for a deliberately
nondelegating issuance/revocation lifecycle. Only the authenticated domain admin
may issue or revoke in that domain. Grants allocate fresh IDs; revocation never
reactivates or removes an ID for reuse. Ordinary invocation does not mutate the
capability table. Do not add recursive delegation, expiration or consumable
allowances without dedicated invariants. In particular, a revoked capability
does not regain authority through reissuing the same ID.

Invocation first resolves the registered operation and checked arguments, then
requires a live capability held by the authenticated actor for that exact
operation. It evaluates the template, checks resource authority for each actual
net debit and nonzero supply change, nonnegative resulting balances, accounting,
and footprints. Only then does it construct the new state. Unknown/foreign/
revoked capability IDs cannot satisfy authority. Refusal returns no post-state.

Small lifecycle commands can be a separate generic `AuthorityCommand := issue |
revoke`; these are administrative semantics, not protocol-specific constructors.
Duplicate supplied capability IDs confer no additional right. Operation replay
is allowed; this increment does not claim nonce or transaction replay protection.

## Required proof endpoints and executed tests

Start from an `execute_ok_iff` witness connecting actual execution to evaluated
effects, all checks and the exact update. Derive:

1. Success preserves nonnegative balances and domain/asset total accounting.
2. Success preserves balances outside the declared write footprint.
3. Success selects the registered template for the requested operation and has
   a live invocation right held by the authenticated principal; each actual net
   debit/supply change has a corresponding live resource capability.
4. Successful issue/revoke preserves all balances and every unrelated capability;
   issue allocates fresh authority only under the domain admin; revoke prevents
   subsequent use of that ID. Spending preserves capability state.
5. Expression evaluation depends only on its computed reads and arguments.

Exercise successful transfer, fixed-rate vault and price-dependent borrow as
registered definitions. Refusal tests must invoke the real executor: unknown
operation; wrong actor despite request data; missing/wrong-operation/revoked or
foreign-domain capability; unauthorized grant/revoke; revoke-then-use; bad
argument unit/index; missing observation; stale/nonpositive price; zero divisor;
undeclared guard read and undeclared effect read; insufficient balance; unbalanced
effects; wrong-asset accounting; undeclared write. Typed wrong-unit expression
construction also needs a Lean compile-failure fixture; it is not a runtime case.

Each branch needs a positive sibling reaching the same stage. For example, test
revocation with unchanged principal, operation, amounts and balances; avoid a
missing invoke right masking the revoked resource capability. Mutate actual
checker/evaluator branches and require observed false comparisons, not source
string checks or copied evaluators. Keep Lean proofs, executed examples, mutation
measurements and adapter assumptions separately labeled in the audit manifest.

## Tradeoffs and proof risks

- Finite carriers simplify decidable quantification and exact totals. They model
  arbitrary finite deployments, not an infinite global ledger or dynamic party
  allocation. Opaque ID maps need freshness invariants even though IDs are Nat.
- Dependent signature lookup and typed environment keys can dominate proof work.
  Keep the constructor set small; do not introduce a general dependent DSL or
  runtime asset unification. Freeze refusal precedence before acceptance tests.
- Registry selection plus an invoke capability is modeled authenticated
  authorization, conditional on the trusted actor/registry/admin boundary.
  Describing it as cryptographic authentication would overclaim.
- Net-effect authorization retains the original pilot's limitation: cancelling
  intermediate debits are invisible. There is no ordered execution semantics or
  allowance consumption claim. This must remain explicit.
- Domain-wise accounting is a deliberate stronger restriction that excludes
  bridges. If domains are only metadata instead, choose and document global
  accounting; do not silently mix those meanings in examples or proofs.
- Read dependence is delicate around conditions, failed lookup, timestamps and
  authorization. Proving only `eval` locality is useful but does not establish
  composition or operation-wide frame independence.
- Rational financial formulas do not establish rounding, deployed fidelity,
  market truth or solvency. Three reference definitions remain development cases.
  Adding USD holdings and debt tokens is ill-typed: the borrowing library must
  supply an explicit dimensioned price of one USD per debt token when that is its
  reference valuation assumption. A scalar coefficient cannot change asset units.
- Preserve the original imported audit roots and extend automatic audit coverage
  to all new modules; fresh source-bound builds and independent native Grok/Fable
  review are parent acceptance work, not accomplished by this proposal.

## Delivery and scope decisions

This design chooses an intrinsically typed first-order IR with parametric finite
carriers. Extending only the old net-effect wrapper would leave expression units
and read dependencies hidden; a serialized untyped external language would add
parser/certificate obligations before the semantics is established. The selected
Lean-native IR makes these checks reviewable within Sprint4. External parsing,
full composition, dynamic population growth and machine arithmetic are later work.

Accept only after a fresh full Lean build, imported new-module axiom audit, all
nonempty executed checks, meaningful typing failures and source mutations, plus
independent native Grok and Fable review. Preserve all old Lean statements and
corpus bytes. Initial review and one focused remediation review are planned;
another round requires a concrete unresolved finding. Review threats are ordinary
caller requests against trusted registry/context/admin inputs, implementation
errors, omitted checks and misleading evidence claims. No grant of adversarial
write access to the trusted registry is assumed.

Record exact files/tool identities/review models and all refused/blocked results.
Commit reviewed code and evidence, push semantic-kernel-pivot, read remote head
back and require equality. Mark the stock harness goal complete only afterward.
