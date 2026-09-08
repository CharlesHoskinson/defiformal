# DeFi Kernel

DeFi Kernel is a library for modeling decentralized finance (DeFi): financial
services implemented by smart contracts. It uses Lean, a programming language
and proof assistant, to describe financial operations, execute examples, and
check proofs about how those operations work together.

Financial operations have rules about who may act, what they may spend, and
what must balance. A deposit followed by a withdrawal must carry balances
forward and specify what happens if the withdrawal fails. The kernel gives
these operations a common model so developers and auditors can examine which
properties survive when operations are combined.

Use it to write an executable specification of a protocol in Lean. Connecting
a Solidity or Rust contract to that specification requires a separate argument
that the contract implements the model.

## How it works

The ledger records a nonnegative balance for each **domain, account, and asset**.
A domain identifies an execution context, such as a modeled chain. Amounts and
prices have asset-specific types: a share amount and a dollar amount cannot be
interchanged without an explicit conversion. Calculations use exact rational
numbers.

An operation is a registered **template**: its arguments, execution conditions,
balance changes, and minting or burning of asset units. It declares which
ledger entries it may read and write and which external data it uses. A vault
deposit, for example, moves assets into a vault and issues shares representing
the depositor's claim at a specified rate.

A request selects a template and supplies arguments and **capability IDs**.
Capabilities grant permission to invoke an operation, debit a particular
balance, or change an asset's supply. They can be issued and revoked. The
caller's identity comes from the execution context.

Execution checks permissions, access, and the operation's conditions. Resulting
balances must stay nonnegative. For each asset in each domain, the total balance
change must equal declared minting minus burning. Success produces a new state;
refusal returns a reason, such as insufficient funds or missing permission.

Components declare private and shared state, along with named, typed inputs and
outputs called **ports**. A workflow can feed a recorded output into another
call. Its trace records successful steps and any refusal.

## Combining operations

The library provides four execution modes, each with explicit failure behavior.

| Mode | Behavior |
| --- | --- |
| Sequential | Steps pass balances and capabilities forward. A refusal stops execution; preceding successful steps remain committed. |
| Disjoint parallel | Two branches run from a common state after access compatibility checks. Their results are joined, retaining each branch’s successful steps and any refusal. |
| Shared-state interleaving | A supplied schedule chooses the next step from two branches sharing state. A refused branch stops; the other can continue. |
| Atomic | A scheduled batch publishes one commit after successful execution and settlement. Refusal or abort leaves the publicly visible state unchanged. |

An atomic settlement policy names the vault accounts and participants to track.
The batch records each caller's net obligations from movements at those accounts
and commits only when every tracked obligation is zero and the policy's supply
checks pass. The schedule is an input: running one schedule does not explore
all possible orderings.

Successful calls enforce the modeled permissions and access rules. The
[preservation theorems](lean/DefiKernel/Composition/Preservation.lean) state what
follows: `run_accounting` relates total balances to recorded supply changes;
`run_frame` preserves properties that depend only on untouched ledger entries.
Workflow-specific invariants require proofs of their initial conditions and
preservation by the steps.

## Run an example

Install Lean using the [Lean installation guide](https://lean-lang.org/install/).
You will need Git and Lean's `elan` toolchain manager, which supplies Lean and
its build tool, Lake. The repository pins its Lean and mathlib versions.

```bash
git clone --branch semantic-kernel-pivot https://github.com/CharlesHoskinson/defiformal.git
cd defiformal/lean
lake exe cache get
lake build DefiKernel
```

The cache command downloads compiled mathlib dependencies. Keep the following
commands in the `lean/` directory.

Create `TryKernel.lean` there with:

```lean
import DefiKernel.Typed.Examples

open DefiKernel.Typed.Examples

-- Alice starts with 10 USD; Bob starts with 0.
#eval (run (transferRequest 3)).map fun result =>
  (result.state.balance (.main, .alice, .usd),
   result.state.balance (.main, .bob, .usd))

-- A separate request from the same initial state exceeds Alice's balance.
#eval (run (transferRequest 11)).map fun result =>
  result.state.balance (.main, .alice, .usd)
```

Run it:

```bash
lake env lean TryKernel.lean
```

The first evaluation returns balances of **7 and 3**. The second returns an
`insufficientFunds` execution refusal. The example helper provisions the
required grants and supplies a fixed caller and environment. Each `run` starts
from the fixture's initial state; sequential workflows carry state forward.

<details>
<summary>Run the operation and workflow checks</summary>

From the `lean/` directory:

```bash
lake env lean DefiKernel/Typed/Audit.lean
lake env lean DefiKernel/Composition/Audit.lean
lake env lean DefiKernel/Parallel/Audit.lean
lake env lean DefiKernel/Interleaving/Audit.lean
lake env lean DefiKernel/Atomic/Audit.lean
```

These commands print named comparisons and fail on a false comparison or an
empty inventory. The build checks proofs and runs axiom audits; see the
[composition verification module](lean/DefiKernel/Composition/Verify.lean).

</details>

## Model a financial component

Change the example's transfer amount to `10` to get balances of `0` and `10`.
Then follow the [typed examples](lean/DefiKernel/Typed/Examples.lean): define your
finite account, asset, and domain types; a nonnegative initial ledger; a `Template`;
its registry entry and grants; and a request. `transfer`, `registry`, `grants`,
and `runWith` show the pieces together.

To connect calls, follow `catalog`, `cfg`, `boundary`, `initialWorld`, and
`workflow` in the [composition examples](lean/DefiKernel/Composition/Examples.lean).
The [interface definitions](lean/DefiKernel/Composition/Interfaces.lean) describe
ports and shared resources. Choose the execution mode that matches the intended
ordering and rollback behavior.

Write successful and refused examples with expected balances and failure
reasons. To prove a property, state its initial conditions and show each step
preserves it. `collateralContract` in the composition examples and `run_contract`
in the preservation module illustrate the contract and workflow proof structure.
Registering a template alone does not establish its economic correctness.

## Scope of the guarantees

The financial examples model transfers, fixed-rate vault deposits and
withdrawals, and borrowing against declared collateral and an oracle price.

Caller contexts, registries, administrators, and initial capability stores are
trusted model inputs. Grants express administrator authority, which does not
by itself establish an account owner's consent. An oracle supplies external
data such as a price; checking its type, sign, and age does not establish its
truth. Applying a proof to a real system requires justifying these inputs.

A template describes a net balance change. Calls needing separate intermediate
states must be modeled as separate steps. Integer overflow, rounding, fees,
transaction replay, network finality, and asynchronous delivery need additional
models and proofs. Accounting preservation does not establish market solvency
or guarantee eventual execution.

A Lean proof establishes its statement under its premises and reported axioms.
Tests check particular inputs; mutation tests check whether the tools detect
deliberately broken behavior. The [verification records](review/semantic-kernel/)
keep this evidence distinct. The [roadmap](roadmap.md) lists the remaining work.

## Find your way around

| Path | Contents |
| --- | --- |
| [`lean/DefiKernel/Typed/`](lean/DefiKernel/Typed/) | Typed expressions, operation templates, capabilities, and financial examples. |
| [`lean/DefiKernel/Composition/`](lean/DefiKernel/Composition/) | Component interfaces, sequential execution, contracts, and preservation proofs. |
| [`lean/DefiKernel/Parallel/`](lean/DefiKernel/Parallel/), [`Interleaving/`](lean/DefiKernel/Interleaving/), [`Atomic/`](lean/DefiKernel/Atomic/) | Branch execution, schedules, settlement, and their proofs and tests. |
| [`scripts/`](scripts/) | Mutation runners, verification controls, and corpus tooling. |
| [`openspec/`](openspec/) | Behavioral requirements and acceptance scenarios. |
| [`corpus/normalized/`](corpus/normalized/) | Protocol identities, mechanism annotations, and source provenance. |
| [`graphify-out/strategy-audit-20260908/`](graphify-out/strategy-audit-20260908/) | Current source dependency map, including isolated candidates. Open `graph.html`; see the scope limits in `GRAPH_REPORT.md`. |
| [`graphify-out/codebase/`](graphify-out/codebase/) | Historical source-graph snapshot. |
