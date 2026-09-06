The full prompt was truncated; I’ll load the offloaded request so the review uses the complete inline source, then judge only the contract-semantics scope.**Scope:** contract wrapper, `Shape`, borrow conditions, inherited success/refusal proofs. No Lean re-run. `ContractAcceptance.lean` and regression scripts are not in this packet.

## Verdict

| Gate | Result |
|---|---|
| Spec (this scope) | **PASS** |
| Implementation (this scope) | **PASS** |

The design matches the sprint boundary: a generic, decidable wrapper over an unchanged finite kernel; the proposal cannot carry its own contract; trusted selection and parameters are assumptions. Library contracts match complete effects and supply on the finite domain, not constructor tags. Borrow environment checks are a separate conjunct from `t.guard`. Parent report: full build 0, contract runtime 43/43. That is recorded evidence, not an independent execution by this review.

## Spec vs sources

`Contracts.lean` gives `Contract.accepts : State → E → Transition E → Bool`, `Failure.contract` vs `Failure.base`, and `run` that refuses before `execute`. `run_ok_iff` / `run_valid_update` tie success to the contract Bool, `Valid`, and `applyEffect`. `run_always` is definitional recovery of base execution. `run_contract_refused` yields no `.ok` post-state. `run_base_refused` preserves the kernel reason. `run_accounting`, `run_locality`, and `run_authority` are conditional on wrapper success.

`Shape` is actor plus pointwise effect and supply over all cells/assets. `transferContract` / `depositContract` / `withdrawContract` / `borrowContract` instantiate that with trusted actor, amount, and endpoints. Guard and write-set equality are omitted on purpose; `Local` and `t.guard` remain kernel checks.

`BorrowConditions` reads only `s` and `oracle` (feed 7, positive price, age window, 200% declared collateral). `borrowContract` is `Shape && BorrowConditions`. `borrow_accepts_conditions` holds for an arbitrary `t`, including `forgedBorrow`. `borrow_constructor_accepts_iff` reduces constructor acceptance to those conditions. `borrow_run_collateral_bound` rewrites the post-state with the trusted effect and the independent pre-state bound.

Fixtures `unrelatedEffect`, `wrongSupply`, and `forgedBorrow` encode extra-cell, supply mismatch, and forged-true guard. No `sorry`, custom axioms, or `native_decide` in these files.

## Ranked findings

1. **Advisory — trusted transfer params can describe the vault drain.** `policyVaultDrain` is `transfer .alice .vault .alice 20`. `transferContract` with those same parameters accepts it. Unbacked issue and debt burn do not match any of the four library shapes. This is the stated selection assumption, not a wrapper hole.

2. **Advisory — `Shape` does not constrain `guard` or `writes`.** Documented. A forged-true guard still needs `BorrowConditions`. A bad footprint still fails `execute` after a true contract.

3. **Limit — live post-states and hostile `run` theorems are not in this packet.** Constructor/`Shape` facts and wrapper inheritance are here. Exact drain/issue/burn/`unrelatedEffect`/`wrongSupply`/stale/zero-price execution observations belong to `ContractAcceptance` / the regression scope. Parent `43/43` is not a substitute for reading those proofs.

## Limits

No production fidelity, solvency, composition, capability lifecycle, or authentication claim. Policy counterexamples remain kernel evidence under `always`. Audit, mutations, and output-path guards are out of scope. This is the missing-review retry, not a new design round.
