# P19 assumptions judgment fix review

**ACCEPT this exact four-file candidate for integration; A1 is resolved.** Dependent-proof and final author-terminal identity conditions are now satisfied. Original rejection and raw probes remain preserved. No whole P19/P20 acceptance.

Exact SHA-256:

- Check.lean: `bdd321e3c9ca6f7db84c92e2e50eca4968314de0a151281298798c960728b06c`
- Delivered.lean: `556f94b2edc9be9c6337e3fc79d75d8ec8b3d713808ed0c9e427f3f7cee109bc`
- AssumptionsRegression.lean: `91c97c39815213e7111013b25894ca8b85203091f0a57c9f82bc225532435dee`
- f41-assumption-companions.json: `9cb69f8bb937ad410c3554f3dde38e8e3a199339f5d54f9d256cb5fda46f8575`

The six-class membership helper is retained. All six Check judgment maps now use the presence-derived outcome; Delivered's stale/not-reached helper maps accept the same missing-class information. The correction flows through existing makeJudgments, so claimed flags do not establish presence and match flags reflect the actual outcome. Runtime failure-order predicates and kernel computations are unchanged. No theorem statement was changed in these candidate diffs.

Independent evidence (`judgment-commands.json`, with actual argv/cwd/exits and stdout/stderr hashes):

- Focused AssumptionsRegression build: exit 0, 944 jobs. Supplied regression: exit 0, 23/23 checks.
- Original independent 64-literal-case probe: exit 0. Both Check.checkTyped and Delivered.checkTyped pass 64/64 for actual labels, status/first missing, assumptionsDeclared and all six raw kernel fields.
- `JudgmentRoutes.lean`: exit 0. Each production typed/step/run route passes **128/128**, all 64 subsets with both claimed flags. It checks actual report labels, first-missing constructor, accepted/incomplete status, outcome, claimed, match, world, receipt, outputs, events, nextIndex and cursorFailure. Every incomplete case reports false, every complete case true; claiming presence does not change either result.
- `JudgmentPrecedence.lean`: exit 0, **9/9**. For each production mode, stale-source, claimed-world mismatch and insufficient-funds failures retain their exact constructor and kernel observations when all assumptions are removed. Their report judgment becomes false without replacing the prior refusal by an assumption failure.

The additive environment-missing and replay-missing companion expectations now include false/claimed-false/match-true and the correct class labels and first-missing constructors. Their roles conform to `P19-ASSUMPTIONS-CONTRACT-REVIEW.md`. Original F41's inverted environment/replay expectation remains historical and must mismatch the corrected report. Original fixture-file SHA remains `ad1857ecf7269920a2169ab7e644d28da3311cad91be60df09a737cf94fe7742`.

Fully present inputs retain their former helper and judgment values, so previously reviewed complete-assumption runtime observations remain reusable under the recorded source-dependency assessment. Base Check.step/run historical status contracts remain separate from production Delivered policy; the latter is verified here. The old 54-fixture and 16-mutant campaigns are not re-dated or declared unchanged after this repair. No broad rerun is required by these findings.

Before integration, parent must confirm dependent Soundness/KernelCorrespondence and other required historical proofs finish successfully with preserved statements, and final author bytes match this reviewed snapshot. If proof-script patches are needed, review their exact scope separately. No source edits, archives, main builds or candidate modifications were made by this reviewer.

## Finalization

Native author ended with process exit 0 at 2026-09-19 23:32:16 UTC (`../grok-p19-assumptions-judgment-process.json`). Independently rehashed all four final author files: each exactly matches the reviewed candidate above. Verified the copied dependent-build log and original native terminal log both hash to `e1b621e17739469c6741262641aca6a9f8917c232c00ca02a65c0bbb4da2e8bd`; actual log ends with successful completion of 946 jobs. Correspondence, Soundness and KernelCorrespondence source hashes independently match accepted main and `../p19-assumptions-judgment-proof-check.json`; no proof patches or theorem-statement changes were required. The earlier pending-terminal flag in that intermediate proof record is superseded by the final process record and this fresh hash check.

No review condition remains open for the exact candidate. Parent's main integration build must still finish successfully before commit, as planned. No additional broad tests or proof rebuild were performed by this reviewer.
