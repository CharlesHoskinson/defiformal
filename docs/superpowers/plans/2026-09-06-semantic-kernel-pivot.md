# Semantic Kernel Pivot Implementation Plan

> Execution: GPT-6 through the stock Codex harness; direct Grok and Fable CLI
> reviews. Use subagent-driven-development for the bounded Lean implementation.
> User has approved execution. Foreman must not be invoked.

**Goal:** Save the full migration and deliver its first executable Lean pilot.

**Architecture:** Preserve legacy research as evidence. Add a separate semantic
kernel namespace and pilot library. Use native Lean proof checking before any
claim of verification; retain explicit scope for unimplemented metatheory.

**Tech stack:** existing Lean/mathlib pins, Python standard library for evidence
packaging if needed, native Codex agents, Grok CLI, Claude CLI with Fable.

## Global constraints

- Follow `../specs/2026-09-06-semantic-kernel-design.md`.
- No Foreman invocation, external publishing, or destructive history changes.
- GPT-6 implements; requested reviewers are Grok and `claude-fable-5-1`.
- No `sorry`, custom axioms, or `native_decide` in the pilot.
- Do not claim production protocol fidelity, a complete IR/certificate checker,
  general composition, solvency, or liveness from pilot results.
- Exact proof and model coverage must appear in the result ledger.

## Task 1: Save and activate the migration

Files: this plan, the design, `docs/research/2026-09-06-defi-source-plan.md`,
`docs/research/semantic-kernel-progress.md`, `README.md`, `AGENTS.md`, and
supersession notices on both older roadmaps and runstate entry points.

- [ ] Preserve the supplied Markdown byte-for-byte and record SHA-256.
- [ ] Save the assessed seven work packages and first-increment scope.
- [ ] Update active instructions and README; mark old research instructions
  historical without deleting their supporting evidence.
- [ ] Inspect links, claim scope, diff whitespace, and source-copy identity.

## Task 2: Implement the Lean pilot

Owned files: `lean/DefiKernel.lean`, `lean/DefiKernel/*.lean`, and
`lean/lakefile.toml`. Implementer reads the design before working.

Consumes: existing Lean/mathlib pins and the design's acceptance contract.
Produces: a `DefiKernel` target with generic transition/effect semantics,
three reference examples, proofs and executable acceptance/refusal examples.

- [ ] Write concrete acceptance/refusal statements before their implementations;
  observe rejection of the missing or defective behavior, then make them pass.
- [ ] Define identities, quantity/effect semantics, guards and checked transitions.
- [ ] Prove accounting and locality under explicit premises; instantiate the
  same transition representation in transfer, vault, and credit libraries.
- [ ] Add meaningful negative witnesses and runtime checks for the examples.
- [ ] Run `lake build DefiKernel` and `lake build`; capture full logs and axiom
  output. Record exact theorem names, finite checks, and outstanding limitations.
- [ ] Report file list, checks and concerns without changing unrelated files.

## Task 3: Independent review and remediation

Files: `review/semantic-kernel/2026-09-06/` with review brief, candidate identity,
raw native reviewer responses, and adjudication. Evidence must bind the reviewed
sources and requirements. No reviewer edits the implementation directly.

- [ ] Freeze a candidate commit and build a review bundle from exact files.
- [ ] Invoke Grok and Fable directly with the same requirements and candidate.
- [ ] Inspect result status and actual content; a missing, off-topic, or failed
  invocation is not an approval. Record provider-reported model identity.
- [ ] Resolve concrete correctness findings with GPT-6 and covering tests.
- [ ] Re-review changes if material findings required a fix; bind final checks
  and review coverage to the resulting revision.

## Task 4: Record the first increment and remaining work

- [ ] Update `docs/research/semantic-kernel-progress.md` with observed results,
  reviewer dispositions, and unresolved work from all seven packages.
- [ ] Verify the working diff and commit the reviewed increment locally.
- [ ] Report delivered scope, test evidence and next acceptance gate.

## Subsequent increments

The full seven-package design remains the migration backlog. Next: complete
corpus schema/provenance and adjudication workflow, specify operational
composition and assumption discharge, and extend the pilot toward a typed IR
with checkable certificates. Preserve separate development and untouched
evaluation manifests before importing adversarial protocols. Each increment
gets its own concrete implementation plan and the requested review pattern.
