# DeFi Kernel

DeFi Kernel is a Lean library for describing financial operations, running them
against an explicit model of balances and permissions, and proving properties
of the resulting workflows.

A transfer, a vault deposit, and a collateralized loan all change who holds
which assets. Each also has rules: who may act, what they may spend, which
prices they may use, and what must balance when the operation finishes. Those
rules become harder to reason about when one operation feeds another or two
operations touch the same funds.

The kernel gives these operations a common execution model. Its central
question is: **under what conditions do financial properties survive
composition?** A proof about one operation is useful only if its assumptions
still hold where that operation is used.

Protocol developers can use the library to build executable models and check
their designs. Auditors can inspect the assumptions behind a proof and run
examples that exercise both success and refusal. Researchers can state and
prove rules for combining financial components. Working with the library means
writing Lean definitions and proofs; Lean checks the mathematical arguments.

## How it works

The ledger records a nonnegative balance for each **domain, account, and asset**.
A domain identifies an execution context, such as a modeled chain. Amounts and
prices have asset-specific types: a share amount and a dollar amount cannot be
interchanged without an explicit conversion. Calculations use exact rational
numbers.

An operation is a registered template. It declares its typed arguments,
conditions for execution, balance changes, minting or burning, and the state
and external observations it reads. It also declares the cells it may write.
For example, a vault deposit moves an underlying asset into the vault and issues
shares according to a rate defined by the vault model.

A request selects an operation and supplies its arguments and capability IDs.
Capabilities are grants recorded in a store: permission to invoke an operation,
debit a particular balance, or change an asset's supply. The model includes
issuance and revocation. The caller's identity comes from the execution context.

Execution checks the request against the template and the available authority.
It checks declared access, evaluates the operation's conditions, and requires
that the resulting balances stay nonnegative. For each asset in each domain,
the total balance change must equal the declared minting minus burning.
A successful call produces a new state. A refused call returns a reason, such
as insufficient funds, a missing permission, or an invalid observation.

Components add typed input and output ports and declarations of private and
shared state. A workflow can pass a recorded output from one call into another.
Its trace records the successful steps and any refusal, making order and failure
part of the model.

## Combining operations

The library provides four execution modes, each with explicit failure behavior.

| Mode | Behavior |
| --- | --- |
| Sequential | Each step receives the preceding state and capability store. A refusal stops the sequence and retains the successful prefix. |
| Disjoint parallel | Two branches run from a common starting state after checks establish that their access does not conflict. Their results are joined; each branch retains its own successes and refusal. |
| Shared-state interleaving | A supplied schedule chooses which of two branches takes the next step against the shared state. A refused branch stops; the other can continue. |
| Atomic | A scheduled batch runs speculatively. It publishes one commit only if execution succeeds and the declared settlement obligations are cleared. Refusal or abort leaves the publicly visible state unchanged. |

The proofs connect execution to accounting, authority, and locality: operations
can change only the state their permissions and access declarations allow.
Composition results state the premises they need, including valid interfaces,
compatible access, and invariants that hold initially. A frame theorem lets a
property remain true when it depends only on state the workflow cannot change.

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

For executable checks of the typed operations and composition modes:

```bash
lake env lean DefiKernel/Typed/Audit.lean
lake env lean DefiKernel/Composition/Audit.lean
lake env lean DefiKernel/Parallel/Audit.lean
lake env lean DefiKernel/Interleaving/Audit.lean
lake env lean DefiKernel/Atomic/Audit.lean
```

These commands print named comparisons and fail if a comparison is false or
the inventory is empty. They exercise concrete examples. The Lean build checks
the proofs; the verification modules also audit the axioms used by imported
kernel declarations.

## Model a financial component

Start with the [transfer, vault, and borrowing examples](lean/DefiKernel/Typed/Examples.lean).
Define the operation's arguments, conditions, balance effects, supply effects,
and read/write access as a `Template`, then register it under an `OperationId`.
Supply the initial ledger, grants, caller context, and any external observations
needed to execute a request.

For a workflow, use the [component interfaces](lean/DefiKernel/Composition/Interfaces.lean)
to declare ports and shared resources, and follow the
[composition examples](lean/DefiKernel/Composition/Examples.lean) to connect calls.
Choose the execution mode whose ordering and rollback behavior matches the
system you want to model.

Write successful and refused examples with expected balances and failure
reasons. State the property you need to preserve, then prove its initial
conditions and the premises required by the relevant preservation theorem.
Registering a template alone does not establish its economic correctness.

## Scope of the guarantees

The reference models cover transfers, fixed-rate vault deposits and
withdrawals, and borrowing against declared collateral and an oracle price.
They are mathematical models. Applying their results to a deployed contract
requires a separate argument that the contract implements the model.

The execution model assumes authentic caller contexts, registries,
administrators, and capability stores. Grants express administrator authority;
they do not by themselves establish an account owner's consent. Oracle values
and timestamps are supplied inputs. Checking a price's type, sign, and age does
not establish that the price is true.

Balance effects are aggregate net changes, and arithmetic is exact. Integer
overflow, rounding, fees, transaction replay, network finality, and asynchronous
delivery need additional models and proofs. Accounting preservation does not
establish market solvency or guarantee that an operation will eventually run.

Lean proofs, executable tests, and mutation results answer different questions.
A proof establishes its statement under its premises. A test checks particular
inputs. Mutation tests check whether the verification tools detect deliberately
broken behavior. The [verification records](review/semantic-kernel/) retain
those distinctions. The [roadmap](roadmap.md) lists the remaining work.

## Find your way around

| Path | Contents |
| --- | --- |
| [`lean/DefiKernel/Typed/`](lean/DefiKernel/Typed/) | Typed expressions, operation templates, capabilities, and financial examples. |
| [`lean/DefiKernel/Composition/`](lean/DefiKernel/Composition/) | Component interfaces, sequential execution, contracts, and preservation proofs. |
| [`lean/DefiKernel/Parallel/`](lean/DefiKernel/Parallel/), [`Interleaving/`](lean/DefiKernel/Interleaving/), [`Atomic/`](lean/DefiKernel/Atomic/) | Branch execution, schedules, settlement, and their proofs and tests. |
| [`scripts/`](scripts/) | Mutation runners, verification controls, and corpus tooling. |
| [`openspec/`](openspec/) | Behavioral requirements and acceptance scenarios. |
| [`corpus/normalized/`](corpus/normalized/) | Protocol identities, mechanism annotations, and source provenance. |
| [`graphify-out/codebase/`](graphify-out/codebase/) | Source dependency graph, interactive map, and extraction report. |
