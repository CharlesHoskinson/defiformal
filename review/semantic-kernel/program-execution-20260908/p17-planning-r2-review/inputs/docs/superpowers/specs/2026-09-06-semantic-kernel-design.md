# DeFi semantic kernel: approved migration design

Approved by Charles Hoskinson on 2026-09-06: save the assessed plan and begin
execution, using GPT-6 implementation and Grok/Fable review through the stock
GPT harness. Do not use Foreman. Base: local commit `8ae0bbf`, 22 commits ahead
of the observed GitHub main `25a13c6`. Preserve those local commits.

## Objective

Establish conditional preservation of financial properties under composition.
Separate the empirical ontology, verified financial libraries, typed open
transition semantics, and chain/runtime adapters. Environment assumptions cross
all layers. A primitive count is not the research objective.

The supplied proposal is preserved verbatim in
`../../research/2026-09-06-defi-source-plan.md`. Its external citation tokens and
two sandbox attachment links are unresolved source material, not verified
references. The assessment below refines that proposal and governs execution.

## Seven work packages

1. **Research mandate and claims.** Supersede both the positive-program roadmap
   and the August AFT roadmap. Update the README and working instructions.
   Preserve historical claims with explicit corrections: withdraw the Q/Sigma
   semantic split and four-primitive objective; distinguish syntactic
   independence from semantic minimality; correct Delta terminology and the
   unsupported inference from clause polarity to absence of a lattice. Audit
   the paper's claim sites before changing published theorem statements.
2. **Kernel specification.** Define typed identities, dimensioned quantities,
   exact arithmetic, transitions, guards/refusals, observations, footprints,
   capabilities, claims, and assumptions. Define operational composition modes
   separately. Lean is the mathematical authority. Executable IR and any Quint
   abstractions must have stated correspondence to it.
3. **Corpus normalization.** Preserve all historical rows. Introduce
   organization/product/version/deployment identities, source revisions,
   chain identity, faceted labels, graph relationships, ambiguity, and residue.
   Split bundled products and versions. Independent annotations and their
   adjudication rules are required. Recover or reconstruct the proposal's
   missing CSV and JSON Schema; recover its external references.
4. **Verification path.** Replace keyword certification with checks of typed
   semantics, footprints, authority, accounting, interfaces, library proof
   instantiation, assumptions, and source correspondence. Bind evidence to
   exact inputs and tool versions. Distinguish proved, bounded, measured,
   refuted, and unchecked obligations. Retain useful existing failure-reporting
   and fidelity infrastructure, including refused behavior.
5. **Metatheory.** Prove initialization and preservation for typing, asset
   accounting, authority and locality; then composition, claim lifecycle and
   conservative extension. Generalize Interface.lean and Nary.lean without
   broadening their historical claims. Assume-guarantee rules need causal or
   inductive premises and initialization, not circular implication alone.
   Frame predicates must depend only on the protected footprint.
6. **Financial libraries and fidelity.** Port exact arithmetic, concentrated
   liquidity, Curve iteration, ordered redemption, loss allocation, transient
   accounting, asynchronous messages, margin/funding, and conditional claims.
   Pin reference implementations and observations. Use differential execution,
   characteristic mutations, and selected concrete refinement proofs.
7. **Generalization and publication.** Freeze the kernel before evaluating
   untouched holdouts. Cases already used to design the kernel are development
   challenges, not untouched holdouts. Track new kernel concepts separately
   from new libraries, coverage, assumptions, and verification effort. Rewrite
   the paper around demonstrated results; adapt visualization after the schema
   settles. Moriarty, Compact, ZKIR and runtime proofs remain adapter work until
   verified interfaces exist.

## First executable increment

Build a deliberately scoped Lean pilot, not the complete future IR. Use one
generic transition representation for a transfer, a fixed-rate vault
deposit/withdrawal, and an oracle-dependent collateralized borrow. These are
reference examples, not assertions of ERC-20/ERC-4626/deployed credit fidelity.

The core records actor, state updates, asset-indexed effects, authority checks,
and declared environment input. Financial formulas and protocol guards live in
example definitions. Require successful and refused examples, generic
accounting/locality results, and negative cases that actually violate the
proposed checks. A proof of an implication must not be advertised as automatic
inference of its hypotheses. Ordinary Lean proof terms are the pilot evidence;
no serialized third-party certificate checker is claimed in this increment.

Pilot numeric domain is explicit exact mathematical arithmetic, with
nonnegative balances and guarded debits. Machine-width arithmetic and chain
rounding require later refinement. No market truth, generic solvency, liveness,
deployed-contract correspondence, or full composition theorem is claimed.

## Acceptance and execution

- Preserve source proposal and this design; save a milestone ledger.
- Build the existing Lean baseline before edits.
- Add the pilot in a fresh namespace and Lake target without altering old proofs.
- Check proofs with Lean, with no `sorry`, custom axioms, or `native_decide`.
- Include live positive/negative examples: unauthorized debit, insufficient
  funds, unbalanced effects, wrong-asset accounting, and rejected credit inputs.
- Independently review the exact candidate with Grok and Fable; record model,
  input identity, raw result, findings, and remediation. Use direct native CLI
  processes launched by Codex, not Foreman. Initial review plus one targeted
  re-review; additional review requires a concrete unresolved finding.
- Keep the remaining seven-package work visible. Completing this increment
  does not complete the full migration or its first three-example fidelity gate.

The first useful milestone is three executable models, checked initial
preservation proofs, and broken variants rejected by the appropriate check.
Calendar estimates are provisional; acceptance conditions govern progress.
