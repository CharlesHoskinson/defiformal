The full review request was truncated, so I’ll load the offloaded prompt first and then review only that inline material.**Spec: PASS**
**Implementation: PASS**

Candidate `9e9a2bfe6a3c85785fd3fb845bba6c7765481e22` realizes the requested follow-ups on unchanged Core. No correctness regression is visible in the supplied diff. This is a source review of the inline bundle; parent verification is cited, not re-run.

### Corrections realized

**Overbroad grants (accepted counterexamples).** `Examples.lean` documents that the fixture policy is an input assumption and is not bound to transition shape. Three accepted effects make that concrete:

- `policyVaultDrain` — Alice `transfer` of 20 USD vault→Alice (`transfer .alice .vault .alice`).
- `policyUnbackedIssue` — `pulse` +100 shares with matching `supplyChange`, no USD.
- `policyDebtBurn` — `pulse` −2 debt with matching burn, no pool USD.

`Acceptance.lean` proves `check … = none` and post-states `[30,0,4]`, `[10,20,104]`, `[10,100,0]`. Those numbers match initial 10/20/4 USD/vault/share and debt 2: vault emptied with shares still 4; 100 shares with USD unchanged; debt 0 with pool still 100. Core still only checks net debit/supply/nonneg/accounting/locality, so these must succeed. That is the allowed minimal counterexample route, not a capability contract.

**Isolated zero-price refusal.** `zeroDebt` plus `borrow 0` separates `0 < oracle.price` from collateral arithmetic. `isolated_zero_price_refused` requires `some .guard` at `zeroPrice`; `zero_borrow_positive_price_accept` requires `none` at `fresh`. Existing `oracleCase zeroPrice 3` is unchanged. The mutation needle `oracle.feed = 7 ∧ 0 < oracle.price ∧` matches that isolation; parent report says the price-only mutant flips only `isolated_zero_price_refused`.

**Checker-test coverage and input binding.** `richShares` / `zeroDebt` / overgrant defs sit before the Examples lift marker so check theorems can typecheck in the recipe. `check-mutations.py` hashes Core/Examples/Acceptance plus HEAD and porcelain status (not HEAD alone), asserts those bytes unchanged after the run, lifts every `check` theorem before `transfer_post`, requires that set to equal all `check` theorems in Acceptance (`>= 22`), evals them, and rejects compile-only mutant “kills.” Execute/sequence stay out of scope, as stated.

**Docs.** `lean/README.md` points `lake env lean` at `Audit.lean`, states the three overgrants, says accounting/authority theorems still hold and the fixture is not a safe financial policy, and ties axiom-list completeness to the audited snapshot.

**Audit wiring.** Runtime checks and `#print axioms` cover the eleven new theorems. Parent: 33/33 checks, 51 named theorems, disclosure equality, axioms only `propext` / `Classical.choice` / `Quot.sound`.

### Core

`Core.lean` is unmodified: `check` order, `Valid`, `execute_ok_iff`, policy-relative authority. New examples are instances of that API, not kernel changes.

### Scope limits

Finite pilot only. Not production policy, capability binding, dimensioned IR, composition, contract fidelity, oracle provenance, or solvency. Mutation coverage is the 22 current `check` contracts, not `execute`/`observe`/`sequence`. Automated axiom-list and structural mutant extraction remain backlog. Stronger grant-to-shape contracts remain backlog.
