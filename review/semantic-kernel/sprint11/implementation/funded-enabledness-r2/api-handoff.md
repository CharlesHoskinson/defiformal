# FundedCausal handoff API

Namespace: `DefiKernel.Nary.FundedEnabledness`  
Module: `lean/DefiKernel/Nary/FundedEnabledness.lean`  
SHA-256 `98eccaec1a755d5758d1b88fcb5e0f18e6a35d327ee990beb1094b22bc90f0b7` (34369 bytes).  
Do not import `FundedCausal`. Apply these lemmas from the FundedCausal side.

All four lemmas are actual `∃ result, executeStep … = .ok result`, constructed through catalog / prepare / Typed.execute / extractReceipt. They do not assume success, do not derive enabledness from `StepSound`, and do not quantify over a whole run.

## Extra current hypotheses (only those FundedK can maintain)

| Call | Store | Funding | Other |
| --- | --- | --- | --- |
| producer | `pre.capabilities = f10Store` | `pre.state.balance budgetC = 6` (output amount; identity effects are 0) | empty history |
| consumer | `pre.capabilities = f10Store` | `6 ≤ pre.state.balance vaultC` (Ready `vault ≥ 10` is stronger and not required here) | history `[budgetOut 0]` |
| deposit1 | `pre.capabilities = f10Store` | `1 ≤ pre.state.balance donor1C` | empty history |
| deposit2 | `pre.capabilities = f10Store` | `2 ≤ pre.state.balance donor2C` | empty history |

`pre` is an arbitrary `World`. It is not required to equal `f10Initial` or any other canonical world. Untouched cells stay the machine world.

## Four enabledness lemmas

```lean
theorem f10_producer_enabled (pre : W)
    (hstore : pre.capabilities = f10Store)
    (hbudget : pre.state.balance budgetC = 6) :
    ∃ result, executeStep f10Cfg (f10Bounds (0 : Fin 3) 0) 0 [] (.invoke inv200) pre =
        .ok result ∧
      result.receipt = rec200 ∧
      result.outputs = [budgetOut 0] ∧
      result.world.capabilities = f10Store ∧
      ∀ c, result.world.state.balance c = pre.state.balance c

theorem f10_consumer_enabled (pre : W)
    (hstore : pre.capabilities = f10Store)
    (hvault : 6 ≤ pre.state.balance vaultC) :
    ∃ result, executeStep f10Cfg (f10Bounds (0 : Fin 3) 1) 1 [budgetOut 0]
        (.invoke inv201) pre = .ok result ∧
      result.receipt = rec201 ∧
      result.outputs = [] ∧
      result.world.capabilities = f10Store ∧
      result.world.state.balance vaultC = pre.state.balance vaultC + (-6) ∧
      result.world.state.balance recipientC = pre.state.balance recipientC + 6 ∧
      ∀ c, c ≠ vaultC → c ≠ recipientC →
        result.world.state.balance c = pre.state.balance c

theorem f10_deposit1_enabled (pre : W)
    (hstore : pre.capabilities = f10Store)
    (hdonor : 1 ≤ pre.state.balance donor1C) :
    ∃ result, executeStep f10Cfg (f10Bounds (1 : Fin 3) 0) 0 [] (.invoke inv202) pre =
        .ok result ∧
      result.receipt = rec202 ∧
      result.outputs = [] ∧
      result.world.capabilities = f10Store ∧
      result.world.state.balance donor1C = pre.state.balance donor1C + (-1) ∧
      result.world.state.balance vaultC = pre.state.balance vaultC + 1 ∧
      ∀ c, c ≠ donor1C → c ≠ vaultC →
        result.world.state.balance c = pre.state.balance c

theorem f10_deposit2_enabled (pre : W)
    (hstore : pre.capabilities = f10Store)
    (hdonor : 2 ≤ pre.state.balance donor2C) :
    ∃ result, executeStep f10Cfg (f10Bounds (2 : Fin 3) 0) 0 [] (.invoke inv203) pre =
        .ok result ∧
      result.receipt = rec203 ∧
      result.outputs = [] ∧
      result.world.capabilities = f10Store ∧
      result.world.state.balance donor2C = pre.state.balance donor2C + (-2) ∧
      result.world.state.balance vaultC = pre.state.balance vaultC + 2 ∧
      ∀ c, c ≠ donor2C → c ≠ vaultC →
        result.world.state.balance c = pre.state.balance c
```

Call sites:

- producer: participant `0`, index `0`, `f10Bounds 0 0 = vaultBound`, history `[]`, `inv200`
- consumer: participant `0`, index `1`, `f10Bounds 0 1 = vaultBound`, history `[budgetOut 0]` (prior output name `0/7`, amount 6), `inv201`
- deposit1: participant `1`, index `0`, `f10Bounds 1 0 = donor1Bound`, history `[]`, `inv202`
- deposit2: participant `2`, index `0`, `f10Bounds 2 0 = donor2Bound`, history `[]`, `inv203`

Axioms of all four (`#print axioms` in the private proof cache): `propext`, `Classical.choice`, `Quot.sound`. No custom axioms.

## Glue the Funded author can reuse

- `f10_catalog_valid`
- `f10_bounds_producer` / `f10_bounds_deposit1` / `f10_bounds_deposit2`
- `prepare_producer` / `prepare_consumer` / `prepare_deposit1` / `prepare_deposit2`
- `executeStep_invoke_ok` (catalog + prepare + `Typed.execute` + `extractReceipt` ⇒ `executeStep = .ok`)
- `producer_execute` / `consumer_execute` / `deposit1_execute` / `deposit2_execute`
- `producer_extract` / `consumer_extract` / `deposit1_extract` / `deposit2_extract`

Normative reserve and complete-schedule proof remain the FundedCausal author's job. This module does not add a reserve conjunct to the consumer guard and does not rewrite `f10Cfg`.
