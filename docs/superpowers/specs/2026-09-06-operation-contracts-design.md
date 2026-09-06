# Sprint 2: trusted operation contracts and automatic axiom coverage

This sprint executes packages 2 and 4 of the approved migration. User authorized
starting the next sprint after publishing the first increment on 2026-09-06.
Base: `4c25efc41c4c2b6d6ad3c9fd68d081e71043f387`; continue on
`semantic-kernel-pivot`. GPT-6 implements through native Codex agents; native
Grok and Fable independently review. No Foreman.

## Decision

Add a trusted contract wrapper over the unchanged finite kernel. A contract
checks the actor and complete financial effect of an operation against trusted
parameters and independently checks its required environment conditions. The
caller-supplied transition cannot choose its own contract. The existing broad
policy and its accepted counterexamples remain evidence.

Alternatives considered: tightening only the debit/supply booleans cannot
express the exchange between cash, shares and debt; introducing protocol-kind
primitives would hard-code libraries into the kernel. A generic contract check
with library instances supplies the missing boundary without either change.
General identities and dimensioned expressions remain separate increments.

## Behavior and trust boundary

`Contracts.lean` adds a decidable, state/environment/transition-dependent
contract with an execution wrapper. Contract refusal is distinguishable from
base-kernel refusal. A successful execution entails both the contract predicate
and the existing exact update/check premises. An always-true contract recovers
base execution. A failed contract exposes no successful post-state.

`ContractExamples.lean` supplies contracts for transfer, deposit, withdrawal and
borrow using explicit trusted actor, amount and source/destination parameters
where applicable. Check complete effects and supply change extensionally across
the finite domain, including unrelated cells; do not inspect constructor names
or trust a label supplied with the proposal. Borrow must check its required
oracle and collateral conditions independently of a replaceable proposal guard.
A trusted operation selection is an assumption, not authentication, issuance,
revocation, serialization or a general claim lifecycle.

`ContractAcceptance.lean` proves and executes successful reference operations
and refused hostile proposals. The original vault drain, unbacked issue and
debt erasure must still pass the old checker and be refused by the corresponding
trusted contracts. Include a wrong recipient/unrelated-cell effect, wrong
amount or supply, and a forged-true borrow guard with stale or zero-price data.
Show execution post-states and base refusal propagation, not only predicate
truth. Prove useful general constructor acceptance/shape facts and inherited
accounting/locality conditional on actual wrapper success.

## Automatic audit coverage

Replace the manual-only disclosure boundary with inspection of Lean's elaborated
environment. Discover theorem declarations in loaded pilot modules, report the
exact names and axiom dependencies, and fail on `sorryAx` or nonstandard axioms.
Avoid source-regex theorem discovery. The scope is imported pilot modules;
unimported files are not automatically covered and that must be explicit.
An empty scope must fail. Standard allowed axioms are `propext`,
`Classical.choice`, and `Quot.sound`.

Wire the check into the normal kernel build and provide an explicit fresh-run
command. Test the actual audit mechanism with a newly introduced theorem, a
custom-axiom-dependent theorem, an empty scope, and a clean positive control.
Keep historical manual disclosures as historical evidence; current audit is
computed from the environment rather than depending on that list's maintenance.

## Acceptance and review

- Existing pilot and algebra results remain unchanged and build.
- Wrapper proofs and live positive/negative cases are checked by Lean, without
  `sorry`, custom axioms or `native_decide` in accepted sources.
- Demonstrate sensitivity by disabling the contract check and the independent
  borrow environmental condition in temporary copies: the relevant explicit
  acceptance comparison must fail. A compilation error alone is insufficient.
- Automatic audit rejects a forbidden axiom and empty scope and includes a new
  declaration without editing a disclosure list; record exact output.
- Full build, fresh runtime audits, source-bound input hashes and mutations are
  recorded. Reviewers analyze exact candidate files and observed evidence;
  their judgments do not constitute independent Lean execution.
- One initial native review round and one focused remediation round if needed.
  A failed invocation may be retried with its failure retained.

This is a finite operation-contract increment. It establishes no deployed
contract fidelity, general solvency, composition rule, authenticated authority,
full capability lifecycle, dimensioned IR or serialized certificate checking.
Corpus normalization remains the next independent work package.
