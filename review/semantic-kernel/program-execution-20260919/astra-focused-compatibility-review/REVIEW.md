# Focused compatibility review

Verdict: **REJECT — one diagnostic repair required.** The compatibility acceptance repair works, but this exact candidate must not be integrated until B1 is fixed.

Independent reviewer: requested/reported `gpt-6-astra`, medium; native Codex sub-agent. Author: native Grok 4.6 (parent-supplied identity). Reviewed base `44f2026d063403561bedfe2c22575edf0b60ddf0`, with the eight frozen source hashes in `source-hashes.json`. All eight match; `all-lean-source-hashes.json` binds the surrounding source. Exactly those eight Lean files differ from `/home/charl/defiformal/lean`; the default import root and historical codec/proof files are unchanged. No candidate source edits or author-tree builds were performed.

## Required correction B1

`Delivered.lean:157–160` maps every failed discharge check to `incompleteObligation.libraryTheoremsInstantiated`. A successful typed transfer with only `require_invariant_discharge := true` and `invariants := ["I"]` therefore reports a missing library obligation, although library discharge was not requested. `PolicyProbe.lean` and `policy-probe.log` reproduce this against the real checker (exit 0). The status correctly remains incomplete and the raw successful observation remains available; the reported obligation identity is wrong.

Minimal repair: preserve the identity of the failed discharge obligation when constructing the incomplete report. The invariant-only case must name the invariant family (consistent with `proof.ComponentContract.invariant`), while library-only failures must keep the library family. Preserve acceptance conditions and theorem statements. Add focused invariant-only and library-only diagnostic controls. Follow-up review can reuse the passing unchanged behavior/proof evidence and inspect only this diagnostic change and its directly affected checks/proofs.

## Verification

- `lake build DefiKernel.Certificates.KernelCorrespondence DefiKernel.Certificates.CompatibilityStatusRegression DefiKernel.Certificates.Soundness`: exit 0, 947 jobs. This rebuilt the unchanged historical `Correspondence` module successfully. Linter warnings remain.
- `lake env lean --run DefiKernel/Certificates/CompatibilityStatusRegression.lean ../overlap-run.json`: exit 0; all six checks true. Overlap refused; disjoint USD/share accepted; historical sequential acceptance retained.
- Actual `RunFixtures.lean check ../overlap-run.json` and `raw` invocations: exit 0. Report is refused with `configuration.compositionCompatible`; its world, receipt, outputs, events, nextIndex and cursorFailure exactly match the raw observation (`runtime-results.json`). Alice USD = 4, Bob USD = 6, two events; successful receipt retained.
- `lake env lean DefiKernel/Certificates/Roundtrip.lean`: exit 0, no diagnostics; unchanged historical codec roundtrip proofs remain valid.
- `lake env lean Axioms.lean` (absolute review path): exit 0. `overlayPolicy_accepted_implies_no_false_required` uses only `propext`; typed/step/run corollaries use only `propext`, `Classical.choice`, `Quot.sound`. No forbidden axiom was disclosed.

Every verification command, working directory and exit is preserved in `*-command.json`; raw output is in the corresponding `.log` files. The exact diff is `source.diff`.

## Scope

The four new acceptance lemmas rule out false judgments for accepted delivered reports; they do not prove that all not-applicable/not-reached judgments should be accepted or qualify the full checker. This review does not close P19/P20, branch interpretation, host identity, library instantiation, release gates or full program obligations. It does not request default-root export or whole-sprint campaigns.

The missing-replay assumption diagnostic is already wrong in the unchanged `computeAssumptions` implementation: it labels environment-authenticity missing and replay present. A second direct probe records this inherited issue; it is not a blocker introduced by this repair, and acceptance remains prevented. No historical theorem statement was edited or weakened in the reviewed overlay.
