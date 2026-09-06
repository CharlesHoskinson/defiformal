# Operation Contracts Implementation Plan

> For agentic workers: use superpowers:subagent-driven-development. User has
> authorized execution. GPT-6 implements; native Grok/Fable review; no Foreman.

**Goal:** Reject the pilot's demonstrated policy overgrants through trusted
operation contracts and automatically inspect all loaded pilot theorem axioms.

**Architecture:** Add a generic wrapper without changing Core or historical
examples. Financial contract instances live in a separate example library.
An independent Lean metaprogram discovers and audits elaborated declarations.

**Tech stack:** pinned Lean/mathlib, native Codex GPT-6 agents, Python standard
library for evidence and mutation replay, direct native review CLIs.

## Global constraints

Read `../specs/2026-09-06-operation-contracts-design.md`, root AGENTS.md,
`.claude/skills/defi-footguns/SKILL.md`, and `formal/v3/GATE-REGISTER.md`.
Preserve `Core.lean`, `Examples.lean`, `Acceptance.lean`, `Audit.lean`, and legacy
Defialgebra proofs. No dependency changes. No sorry/custom axioms/native_decide
in accepted proof sources. Temporary negative fixtures must remain outside
accepted library imports. Exact rational, finite-domain and trusted-selection
limits remain explicit. Do not claim the complete migration is finished.

## Task 1: Generic trusted contract and financial instances

Owner: GPT-6 contract implementer.
Create `lean/DefiKernel/Contracts.lean`, `ContractExamples.lean`,
`ContractAcceptance.lean`, and `ContractAudit.lean`.
Consumes the unchanged `Transition E`, `State`, `Policy`, `execute`, and example
constructors. Produces `DefiKernel.Contracts` wrapper APIs and a fresh runnable
`ContractAudit.lean`. Parent will import that module at integration.

- [ ] Write concrete wrapper acceptance/refusal targets first; capture failure
  before the missing wrapper exists using a temporary Lean fixture.
- [ ] Define a decidable trusted contract predicate and distinct wrapper refusal.
  Execution has the shape `if contract.accepts s env t then execute p env t s
  else contract refusal`; prove success entails contract satisfaction plus
  base success, and true-contract equivalence to the base executor.
- [ ] Define extensional transfer/deposit/withdraw/borrow contracts, independent
  borrow environment checks, and general constructor shape results.
- [ ] Prove and execute normal post-states, all three overgrant refusals,
  unrelated-cell/recipient and parameter mismatches, forged guard rejection,
  and base refusal propagation. Use `by decide +kernel` for finite proofs.
- [ ] Run `lake env lean DefiKernel/ContractAudit.lean` after building imports;
  all live comparisons must be true. Record theorem names and assumptions.
- [ ] Produce a portable source-bound mutation replay recipe in a temporary
  report directory, and run positive controls and the two required mutants.
  Require explicit false comparisons rather than compile-error-only results.
- [ ] Write `/tmp/defiformal-sprint2-contract-report.md` with files, exact commands,
  statuses, proof boundaries and mutation instructions. Do not commit or edit
  parent/other-agent files.

## Task 2: Automatic elaborated theorem and axiom audit

Owner: separate GPT-6 audit implementer.
Create `lean/DefiKernel/AxiomAudit.lean` and
`lean/DefiKernel/VerifyAxioms.lean`; optional bounded external test driver under
`scripts/` if necessary. Consumes Lean's loaded environment; generic audit
helper must not import contract modules. `VerifyAxioms.lean` initially imports
`DefiKernel.Audit`; parent adds `ContractAudit` once available.

- [ ] Inspect pinned Lean APIs for theorem constants, module provenance and
  transitive axiom collection. Scope discovery to pilot module declarations.
- [ ] Implement a command that reports every discovered theorem and its axiom
  set, rejects forbidden axioms, and fails on empty scope. Do not discover
  theorem declarations by scanning source text.
- [ ] Demonstrate the real command includes a freshly added theorem without a
  manual list edit; show a clean control, custom-axiom failure, and empty-scope
  failure in temporary Lean fixtures. Check diagnostic identity as well as exit.
- [ ] Make `VerifyAxioms.lean` run the audit command; retain no forbidden fixture
  in the default library imports. Record imported-module scope limitations.
- [ ] Write `/tmp/defiformal-sprint2-axiom-report.md` with exact test commands,
  output locations, counts and scope. Do not edit the parent entrypoint or commit.

## Task 3: Integrate, verify and review the complete sprint

Owner: parent Codex harness.
Modify `lean/DefiKernel.lean`, `lean/README.md`, progress ledger and this plan.
Create `review/semantic-kernel/sprint2/` for exact candidate evidence.

- [ ] Import contract runtime checks and automatic audit into ordinary builds;
  document the new wrapper, its trusted selection boundary and audit commands.
- [ ] Run `cd lean && lake build` and fresh Lean commands for old Audit,
  ContractAudit and VerifyAxioms; capture full output. Replay both implementers'
  discriminating negative tests against committed inputs and record hashes.
- [ ] Commit the candidate locally. Give native Grok and Fable the same frozen
  source bundle with design, exact source identity and observed verification.
- [ ] Inspect actual results and model identity; repair concrete findings with
  GPT-6 and covering tests. Re-review material fixes once, retaining all results.
- [ ] Commit adjudication, source/evidence manifests, verdicts and open limits;
  update milestone ledger and push the reviewed sprint to the branch.

Acceptance is the design's explicit contract, not a target theorem count.
