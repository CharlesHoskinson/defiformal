## Why

**Draft amendment — 2026-11-18, pending owner review.** This change would become
the implementation and evidence-delivery milestone. Prospective effort measurement
and actual outside reproduction would remain obligations of the linked
[validation change](../competitive-landscape-validation/proposal.md).
The 2026-11-17 acceptance remains historical evidence for the original contract:
13/17 tasks, four unmet criteria. This draft does not update that acceptance or
authorize integration, publication or archival.

IOG Technical Intelligence assessed DeFiFormal against 13 formal-verification tools and semantic models for DeFi (ConCert, Act, Certora Prover/CVL, CFF, Kontrol, Lean AMM formalization, Marlowe Isabelle semantics, Maude-LP, MEV-formal, Move Prover, Scribble, Solidity SMTChecker, Verity) on capability, performance and maturity. DeFiFormal was benchmarked on the same two workloads on 2026-11-06 and its capabilities were graded from this repository at `2b60322cdc8c98f0e0c27cab3b2d6dcc824c3eda` (branch `semantic-kernel-pivot`). The report is `docs/research/competitive-landscape-2026-11/defiformal-competition-tech-strategy.html`.

Three findings motivate this change:

- The field has solved accounting: 10 of 13 tools have supported, scoped token-conservation findings. Checked composition remains open: no tool has a supported unit-consistency or interface-compatibility cell, and invariant composition is shared only by ConCert. Economic safety has scoped proofs (MEV-formal's ordering safety is the only supported economic cell among competitors), but broader guarantees remain unestablished in the assessed artifacts. DeFiFormal is rated supported on asset units, component interfaces and composition, and already holds the mechanisms for both: dimensioned types, composition contracts with preservation theorems, and four execution modes.
- On the benchmark DeFiFormal lands in the proof-assistant band with Act, ConCert and Verity: all four Suite 1.0 cases established, none without guidance, replay 2.4 to 3.9 s, and the sixteen-transfer case costing the same as the four-transfer case. DeFiFormal and Act are the only tools that establish the whole rational-1 suite, and DeFiFormal proves the seven executor-level cases on its own kernel library, the first measurement in the suite to establish those cases on existing code rather than a benchmark model. Its weak side is the two single-step cases: the transfer needed a separate record and the swap needed a new model, because the kernel has no swap operation, and it did not pass the automatic stage that Act and CFF passed.
- Documentation that reproduces is the column that decides whether a tool can be depended on, and activity does not predict it: reproduction failed for 3 of 13 projects (ConCert, Marlowe Isabelle semantics, Verity), including the two most active Lean and Rocq peers. DeFiFormal was not assessed under the maturity rubric; read under its four headings, its repository is green on activity, tests and documentation and blank on CI, release, outside reproduction and known adoption.

## What Changes

### Proposed completion structure, 2026-11-18

- Retain the accepted implementation, proofs, CI and compiled-release requirements.
- Complete scoped accounting by reporting counts, attribution, evidence sources
  and effort availability. Unrecoverable historical effort remains `null` with a
  reason; this supplies no productivity or effort-saving measurement. Selected
  adapter counts remain distinct from complete-component costs.
- Separate the accepted composition deliverable (II.1) from a new prospective,
  separately recorded reuse-effort experiment in the validation change.
- Separate the delivered compiled package (III.1) from actual outside package-only
  rechecking, and transfer outside P18 reproduction (I.4) to the validation change.
  Both outside-run requirements retain their actual-person and outcome criteria.
- Preserve the old-to-new obligation mapping in tasks.md. Before closing this
  milestone, review this amendment, publish the accounting reconciliation and
  reconcile the revised scenarios with existing evidence. No technical proof
  obligation or scoped financial claim changes.

### Original implementation agenda and historical transitions

- Add one planning slice with 13 tasks in four phases that address five gaps identified by the assessment:
  - D1, no composition across two real financial components: no contract instance that two components share, no lemma invoked by both;
  - D2, arithmetic correspondence covers one operation at one fixed value: no proof that an executable operation and its exact-rational transition agree over the full domain, with rounding, fees and refusal;
  - D3, no stated relation between the Lean model and the pinned deployed code: quantified correspondence and source refinement are open;
  - D4, no adversary or environment model: schedules are inputs, there is no notion of permitted moves, capital, prices or inclusion;
  - D5, no evidence package re-checked by anyone outside the project: no CI, no release, no outside reproduction. Suite 1.0 now records independent leanchecker timings; outside reproduction remains open.
- Phase I is operational. Phase II targets the first composed financial example subject to its financial connection and preservation requirements. Phase III ships the evidence. Phase IV widens the financial scope. Adapter-dependent tasks in every phase require the corresponding pinned artifacts or specified replacements to be available.
- Record for every task its kind and what it serves, as the report does. The report ties tasks to the program at four points only (sprint P18 in I.4, sprint P27 in IV.3, and sprints P16 and P19 in the closing of gaps D3 and D5); any further sprint mapping is proposed in design.md and is this change's, not the report's. The frozen 37-sprint program, its sprint plan and `openspec/specs/` main specs are not edited.
- On 2026-11-17 the owner resumed engineering with historical authoring effort unknown. I.3 and I.4 remain open, but no longer block dependency-ready engineering; their acceptance criteria and outside-reproduction requirements are preserved.
- Preserve the original planning freeze and its independent acceptance record. Implement one reviewed slice at a time under the existing proof and release gates.
- Include the IOG Suite 1.0 and rational-1 adapters in this change, as authorized by the owner on 2026-11-17. Pin the source revision and file hashes, preserve IOG attribution and upstream bytes, and provide portable replay instructions. Importing benchmark models does not establish their properties on the kernel library.

## Capabilities

### New Capabilities

- `benchmark-regression-gate`: CI that runs the build and the axiom audit on every commit, with a demonstrated failure on a deliberate break.
- `composed-financial-workflow`: the sUSDS deposit and token0 quote register under one `ComponentContract`, with an explicit financial connection, actual initialization/preservation, a shared lemma, units, refusal and scoped counts/attribution. Effort availability is explicit; the prospective effort experiment belongs to `competitive-landscape-validation`.
- `arithmetic-correspondence-contracts`: per-operation correspondence between the executable Word-arithmetic operation and its exact-rational transition over the full domain, including rounding, fees and refusal.
- `economic-obligations`: an ordering scenario on the interleaving executor with a replayed counterexample or a proven bound under declared assumptions.
- `reproducible-evidence-package`: compiled proof modules shipped with checker name and version, trusted-import list, check scope and checksums for the composed example and later integrations, with engineering replay evidence. Actual outside reproduction belongs to `competitive-landscape-validation`; adoption still requires corroboration.
- `financial-scope`: an AMM swap operation, an ordering scenario on the interleaving executor, liquidation, and lending beyond borrow.

### Modified Capabilities

None in `openspec/specs/`. Where a task extends an accepted capability (for example P17 platform reuse or P19 certificates), the extension is stated as a delta in this change only.

## Impact

The proposed revision edits planning artifacts only and adds a linked validation
plan. Existing Lean/Solidity/Python implementations, accounting manifests,
historical report, frozen reviews, source observations and release assets retain
their exact bytes and identities. A later accepted apply step must add new
reconciliation records rather than rewrite the 2026-11-17 evidence. The original
milestone can close only under the approved amended contract; the validation
change remains open until its own measurement and outside-run criteria pass.

Planning files live under `openspec/changes/competitive-landscape-adoption/`. The report and its README live under `docs/research/competitive-landscape-2026-11/`. The measurement records behind the report are retained in IOG's assessment repository (`input-output-hk/SOTA-DeFiFormal-Moriarty`), which is private; `evidence-index.json` names them and the report embeds every number. The owner authorized importing the IOG-authored Suite 1.0 and rational-1 adapters into `benchmarks/competitive-landscape/` in this change. All tasks using their adapters, proofs or helpers remain blocked until the required pinned artifacts and dependencies are verified available. Preserve the report and historical evidence; new replay results are separate records.
