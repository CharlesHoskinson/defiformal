Reviewing the inline candidate as data, without running anything.

**Spec compliance: PASS.**
**Implementation quality: PASS** (advisory findings below, none blocking).

## Spec compliance

- **Contract wrapper.** `Contracts.run` checks the trusted predicate before delegating to the unchanged `execute`. `run_ok_iff` and `run_valid_update` give exactly the spec's entailment: success implies the contract held and the original `Valid` conjunction and exact `applyEffect` update. `run_always` recovers base execution definitionally. `Failure.contract` vs `Failure.base r` keeps refusals distinguishable. Failed contract yields `.error .contract` with no post-state.
- **Library contracts.** `ContractExamples.Shape` compares actor, every cell of the effect, and every asset of the supply change extensionally over the `Fintype` domain. No constructor names or proposal labels are consulted. `BorrowConditions` is evaluated on pre-state and oracle only and is conjoined by `&&` with Shape, so a proposal guard replaced with `true` cannot remove it. `borrow_accepts_conditions` states this generally for any accepted proposal.
- **Acceptance.** The three legacy counterexamples each have a `*_base_accepted` (old checker accepts) and `*_refused` (`.error .contract`) pair. Wrong recipient, wrong source, unrelated cell, wrong amount, wrong actor, wrong supply, and six forged-guard cases are present with observed post-state lists via `Contracts.observe`. Base propagation covers all six `Refusal` constructors. Threat-model check: since Shape pins every cell and supply entry, an untrusted transition's only remaining freedom is `guard` and `writes`, and both are still subject to base checks.
- **Audit.** `AxiomAudit.importedTheorems` discovers `.thmInfo` constants by module provenance, not source text. It rejects empty scope and any axiom outside the three-name allowlist (so `sorryAx` and `Lean.ofReduceBool` from `native_decide` both fail). `DefiKernel.lean` imports `VerifyAxioms`, so the default `lake build` runs it; README gives the fresh command. The Python replay tests new-theorem discovery, custom axiom, sorry, empty scope, missing prefix, and a clean control, in a directory required to be outside the repository. Imported-module scope and current-module exclusion are documented in both the helper docstring and README.
- **Sensitivity.** The mutation script demands exactly one comparison-failure error line and specific false comparisons, so a compile-only failure is rejected as required. The 15 false comparisons under `contract-bypass` match the 15 `.error .contract` checks in `ContractAudit.runtimeChecks`.

## Findings, ranked by likelihood

1. **Medium. Audit inspects only theorem constants, so an unused `sorry` or custom `axiom` inside a scoped module passes.** `AxiomAudit.importedTheorems` filters on `.thmInfo`. A developer scaffolding `def repayContract ... := sorry` in `ContractExamples.lean`, or declaring `axiom oracleHonest : ...` and not yet using it, produces no forbidden report because no theorem depends on it. AGENTS.md forbids these in accepted sources, not only in theorem closures. Suggested fix: additionally enumerate `.axiomInfo` constants whose module matches the prefix and fail on any not in the allowlist, and optionally run `collectAxioms` over `.defnInfo` constants in scope too. This is a current gap, not migration work.
2. **Low. No repayment contract exists, so debt erasure is refused by `borrowContract .alice .pool (Quantity.ofNat 0)`.** Any non-borrow shape trivially fails that contract, so `debt_erasure_refused` shows less than the spec's "corresponding trusted contract" phrasing suggests. A `repayContract` whose Shape requires a matching USD debit would make the refusal meaningful. Spec-level judgment call; the spec lists only four operations, so this is advisory.
3. **Low. Contracts do not constrain `writes`, so `run_locality` is proposal-relative.** A proposal can declare `writes = Finset.univ`, making `Local` vacuous. Shape already pins effects, so no unintended cell can change, but there is no lemma stating that directly. Suggest a contract-level locality lemma: under `run` success with a Shape contract, cells where the trusted effect is zero are unchanged.
4. **Low. Mutation coverage does not include a Shape-weakening mutant.** Dropping the `∀ a, t.supplyChange a = supply a` conjunct or the actor equality would be a realistic regression; only wrapper bypass and borrow-condition bypass are replayed. The spec required exactly those two, so this is beyond scope but cheap to add.
5. **Trivial.** `check-contract-mutations.py` docstring names the script `replay_contract_mutations.py`.

## Implementation notes

- Proofs are short and reuse core lemmas; `borrow_run_collateral_bound` correctly extracts the effect equality from `hc.1.2.1` and the collateral conjunct from `hc.2.2.2.2.2`.
- `Name.isPrefixOf` is component-wise, so `DefiKernel` does not match a hypothetical `DefiKernelX` module. Correct.
- The audit ordering by `Name.lt` gives stable output for diffing across runs.
- Both Python scripts bind input hashes before and after execution and refuse to write evidence inside the repository. Good hygiene.

## Scope limits

- I did not build or run anything. The 994-job build, 43/43 and 33/33 runtime results, 57 replay assertions, and mutation outcomes are the parent's reported evidence.
- `DefiKernel/Audit.lean` is imported by `VerifyAxioms` but was not in the reviewed file set; I assume it is unchanged from base.
- I did not verify Lean 4.33.0-rc2 API details (`env.header.moduleNames`, `getModuleIdxFor?`) beyond the reported successful build.
- No judgment on caller authentication, contract-selection safety, composition, solvency, or deployed fidelity, per the brief.
