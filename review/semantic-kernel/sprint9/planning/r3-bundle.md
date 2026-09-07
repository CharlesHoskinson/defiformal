Independent Sprint9 r3 OpenSpec planning audit, including full semantic source for the newly restored Fable reviewer. Candidate 0948c177f8939ca6dcc33557c34415d11545ef3e. This is closure of three remaining runner clarifications after the full semantic-source r2 planning audit at 47cd83136ab69b0975594a77c519f6611f6fb555, bundle 1831b58682b2de3500010e75e2dd6e6182f2c07ec6b836f5ac2318df1fa91c4d. Both prior full-source reviewers accepted the semantic M1 plan with limitations; native Opus's three required runner changes are included verbatim below with the root resolution. All prior Lean and runner source inputs have been mechanically checked byte-identical in both Git candidates and the workspace. No Metatheory implementation exists. This is not implementation approval by an author, nor a new independent baseline execution.

Review the FULL revised proposal/design/four specs/tasks/scenario map, exact runner/harness and complete literal adaptation inventory supplied here. Determine whether the timeout reading preserves actual inherited behavior, all literal adaptation decisions are covered, unique needles are required at actual new-source sites, and the historical explicit spec path is corrected. Reassess whether revisions introduce a semantic/proof/scope contradiction; the complete prior semantic-source closure is supplied again for independent inspection by native Fable 5.1; source continuity also binds it to the earlier full audits. If this continuation of the prior audit cannot support a substantive verdict, explicitly say so. Do not invent executed checks or promote source inspection into proof. All supplied file bodies are original bytes; source continuity records are host-generated verification evidence, not your independent execution.

The user requires independent nonauthor GPT6 and native Fable 5.1 (medium effort) passes on this SAME revised candidate/bundle before implementation. Native Grok+Fable 5.1 at medium effort will later review code and evidence, following the latest user instruction; completed Opus reports retain their identity. No Foreman. No tools, code edits, external messages or XML. Return substantive plain text starting VERDICT: ACCEPT / ACCEPT WITH LIMITATIONS / REVISE, then BLOCKERS, REQUIRED CHANGES, NONBLOCKING LIMITATIONS and SCOPE CHECK. Distinguish remaining preimplementation blockers from concrete implementation obligations already stated. A passing verdict does not mean new proofs or tests have run.

Verified unchanged semantic source continuity (prior full review retained):
[
  {
    "path": "lean/DefiKernel/Atomic/Admission.lean",
    "sha256": "e41a34eee617720bbb443253189eafa7934ef6e1603fb197aee6961d84535360",
    "equal_current_and_prior_git_objects": true
  },
  {
    "path": "lean/DefiKernel/Atomic/Audit.lean",
    "sha256": "73e592571182e95006db5a57f914ca8f7cbe8de51983ada3cac0de0d046141ff",
    "equal_current_and_prior_git_objects": true
  },
  {
    "path": "lean/DefiKernel/Atomic/Completion.lean",
    "sha256": "4118076759416087e20ff9093fbe47c7342e72cf7648828cfd492166bcf07646",
    "equal_current_and_prior_git_objects": true
  },
  {
    "path": "lean/DefiKernel/Atomic/Correspondence.lean",
    "sha256": "8464d1eb548fa8e028144118579db317d0f667ae3761cf4c40fad393503c46f2",
    "equal_current_and_prior_git_objects": true
  },
  {
    "path": "lean/DefiKernel/Atomic/Examples.lean",
    "sha256": "771ce6a4de4a24082bcc75c842ac2db3ac072cc63586cd24aecc86c72b097af4",
    "equal_current_and_prior_git_objects": true
  },
  {
    "path": "lean/DefiKernel/Atomic/Execution.lean",
    "sha256": "c9cee888746a2795ae2ddae59d9ffb27ed73339ed5a7ca0737be922af6d96b55",
    "equal_current_and_prior_git_objects": true
  },
  {
    "path": "lean/DefiKernel/Atomic/InvariantFixtures.lean",
    "sha256": "616b1bdb47670b8049f5495287be9c694f71d765c2408091a7e11977430e1b0a",
    "equal_current_and_prior_git_objects": true
  },
  {
    "path": "lean/DefiKernel/Atomic/Observation.lean",
    "sha256": "3e0ab8f53d0bcddc86543207cce4ae832293836e9a301204b090b23d6ccd0cc5",
    "equal_current_and_prior_git_objects": true
  },
  {
    "path": "lean/DefiKernel/Atomic/Policy.lean",
    "sha256": "5b643cbb1b1263ffacb20892afe3f9ec1067191e733f08c3f4040bbe17fa2612",
    "equal_current_and_prior_git_objects": true
  },
  {
    "path": "lean/DefiKernel/Atomic/PolicyProofs.lean",
    "sha256": "9eb5f5fe51692a44860fc27abb2ac2e7196ceb63ba61bb9a416af2cede544ab6",
    "equal_current_and_prior_git_objects": true
  },
  {
    "path": "lean/DefiKernel/Atomic/Preservation.lean",
    "sha256": "1ac0a654964cb11c7c810651831e16d253bb0e875c1f693b4bdb2f735d2b9a6c",
    "equal_current_and_prior_git_objects": true
  },
  {
    "path": "lean/DefiKernel/Atomic/Settlement.lean",
    "sha256": "c27cf9eebfce49357e14c963ab2c0ec4a920b3e26d700f85ad8d51cbb6315ca5",
    "equal_current_and_prior_git_objects": true
  },
  {
    "path": "lean/DefiKernel/Atomic/Soundness.lean",
    "sha256": "4f47288077a5a12ac51efa428ea1e39fa145a3bcffa0f3d04906cc030dc2bb1d",
    "equal_current_and_prior_git_objects": true
  },
  {
    "path": "lean/DefiKernel/Atomic/Tests.lean",
    "sha256": "e42ec7aab417fcd03c492fdc19b1d78f5dfdd91df95adbaf33cf8ea05145e5ad",
    "equal_current_and_prior_git_objects": true
  },
  {
    "path": "lean/DefiKernel/Atomic/Verify.lean",
    "sha256": "f933cff484cbc18d92c463acb717c24f9f82ce960cf3c210a97448abe8548cf4",
    "equal_current_and_prior_git_objects": true
  },
  {
    "path": "lean/DefiKernel/AxiomAudit.lean",
    "sha256": "4a8e330d42e7cd1c46df96ee201923ba2f5d17f37a74b2cb262c318193e72524",
    "equal_current_and_prior_git_objects": true
  },
  {
    "path": "lean/DefiKernel/Composition/Contracts.lean",
    "sha256": "d23885a9bc2ed695ef8569b97c47c9f07449a5a6aa98bc86c8797dce648fc46c",
    "equal_current_and_prior_git_objects": true
  },
  {
    "path": "lean/DefiKernel/Composition/Examples.lean",
    "sha256": "55fb655e93cc6fa8ec676da466112bc763f8f7e81e71cb8acedf98ffd7b73064",
    "equal_current_and_prior_git_objects": true
  },
  {
    "path": "lean/DefiKernel/Composition/Execution.lean",
    "sha256": "34ac2f2185434d2fc8931b10f3688d909cc984e4e24e16e26c2d115b6fe13602",
    "equal_current_and_prior_git_objects": true
  },
  {
    "path": "lean/DefiKernel/Composition/Interfaces.lean",
    "sha256": "4f2a32854b298ca5399eb0aa38bb16e892312517ae4f3a0e49e4bfead369f5fe",
    "equal_current_and_prior_git_objects": true
  },
  {
    "path": "lean/DefiKernel/Composition/Preservation.lean",
    "sha256": "7b881b25fc71f93751ea8f3f64f3bc2d0ffcdd94b4abb7091ba19dd6b21f3709",
    "equal_current_and_prior_git_objects": true
  },
  {
    "path": "lean/DefiKernel/Composition/Sequence.lean",
    "sha256": "32bcdbbce182bf9d494dab76a8a114f9e238f92564ef86e7cab2cd123bc0b729",
    "equal_current_and_prior_git_objects": true
  },
  {
    "path": "lean/DefiKernel/Interleaving/Completion.lean",
    "sha256": "5b3974e55b1893af07a967319f6f3ef680c9e15ed59bd06508817be756382321",
    "equal_current_and_prior_git_objects": true
  },
  {
    "path": "lean/DefiKernel/Interleaving/Examples.lean",
    "sha256": "944421f563bdb3b81a6cf102e72f36396b1cd193b7a1be47b4ced18baff8bb8b",
    "equal_current_and_prior_git_objects": true
  },
  {
    "path": "lean/DefiKernel/Interleaving/Execution.lean",
    "sha256": "8a39ccbaf6cf03479a5b16a156c52a2b6f5bd97a9198b633be27be3b1b899d21",
    "equal_current_and_prior_git_objects": true
  },
  {
    "path": "lean/DefiKernel/Interleaving/Interference.lean",
    "sha256": "e6bc0a1ffbceebb27973d547f2d3b808bc15d6c857e03644c9fa5eeb54ecef90",
    "equal_current_and_prior_git_objects": true
  },
  {
    "path": "lean/DefiKernel/Interleaving/InterferenceFixtures.lean",
    "sha256": "1a08de17a3632aec84ae079f8b9e8145683c009d22b5217695a788b3c7dcfbd0",
    "equal_current_and_prior_git_objects": true
  },
  {
    "path": "lean/DefiKernel/Interleaving/LocalOrder.lean",
    "sha256": "e81054de5ae998516bf0f9a3b9a0ce30ae24a41626b4f3b2c279571f663223be",
    "equal_current_and_prior_git_objects": true
  },
  {
    "path": "lean/DefiKernel/Interleaving/Preservation.lean",
    "sha256": "21199129e97d64bfcdb75c9a860d2263e069f71f59989299c5f8feca62233b2c",
    "equal_current_and_prior_git_objects": true
  },
  {
    "path": "lean/DefiKernel/Interleaving/Schedule.lean",
    "sha256": "a531621726138ef20d1b45edf8c680869a4e35bee4697cfc93d80c250e2b6ad9",
    "equal_current_and_prior_git_objects": true
  },
  {
    "path": "lean/DefiKernel/Interleaving/Soundness.lean",
    "sha256": "f696f995190cd7a6729e536efe1cc7875239625de1070d830c0649061e432337",
    "equal_current_and_prior_git_objects": true
  },
  {
    "path": "lean/DefiKernel/Interleaving/Trace.lean",
    "sha256": "566c89b6b0b9b203daa6458d4a3caeaea998d3ffbddfc63c22f72153320d9ac5",
    "equal_current_and_prior_git_objects": true
  },
  {
    "path": "lean/DefiKernel/Parallel/Commutation.lean",
    "sha256": "c85f69f1bfad39700096c95dbd1450e65eb5f102d4b08a80054f45edf96c52ef",
    "equal_current_and_prior_git_objects": true
  },
  {
    "path": "lean/DefiKernel/Parallel/Compatibility.lean",
    "sha256": "4459fa2b4a4f1f695d3856cb67a46a7c9df86a90f924be8bd26f55e99ba54243",
    "equal_current_and_prior_git_objects": true
  },
  {
    "path": "lean/DefiKernel/Parallel/Dependency.lean",
    "sha256": "72867fdcc9d076bc1beaa6b9cd38a4f75fff9087f703cde1bf3db01760ceb245",
    "equal_current_and_prior_git_objects": true
  },
  {
    "path": "lean/DefiKernel/Parallel/Dependency/Adapter.lean",
    "sha256": "10f9658f56d4fae4d3eed01dd2c2ec78460ed275120d6e6bd3ba9bd90ba00d4c",
    "equal_current_and_prior_git_objects": true
  },
  {
    "path": "lean/DefiKernel/Parallel/Examples.lean",
    "sha256": "d4e1a5992e6e0e65ac89b1445e9d5d4d8675d95be279abc1340872c7c5b878cd",
    "equal_current_and_prior_git_objects": true
  },
  {
    "path": "lean/DefiKernel/Parallel/Execution.lean",
    "sha256": "a4a863d71ddfc5fa057fb5b4c79021aa8d79720710ee7bd70f97f34d01e60089",
    "equal_current_and_prior_git_objects": true
  },
  {
    "path": "lean/DefiKernel/Parallel/Observation.lean",
    "sha256": "38018fbcfb37c08181fbce37b75050077c3dc19d8bee6c0975b7898447ccb84f",
    "equal_current_and_prior_git_objects": true
  },
  {
    "path": "lean/DefiKernel/Parallel/ObservationTests.lean",
    "sha256": "227c4e8e63bfaa66394e8e5946cea5650787651ed2ea6a42cf63a1edada5864e",
    "equal_current_and_prior_git_objects": true
  },
  {
    "path": "lean/DefiKernel/Parallel/Preservation.lean",
    "sha256": "faa047bf614306b00cafc7c4b9278df070b9edb9b26f4d655e68af11a182fa10",
    "equal_current_and_prior_git_objects": true
  },
  {
    "path": "lean/DefiKernel/Typed/Authority.lean",
    "sha256": "dfd2c140f511144e9928ed4f5ed1db9ee2b56cada1342500d2e60c33ef9a0cdb",
    "equal_current_and_prior_git_objects": true
  },
  {
    "path": "lean/DefiKernel/Typed/Examples.lean",
    "sha256": "640df42460b97cd4ac2aba50dc354aa7d2671a055f39c2ec0eb6c8e0f1197f41",
    "equal_current_and_prior_git_objects": true
  },
  {
    "path": "lean/DefiKernel/Typed/Expr.lean",
    "sha256": "1c4e0c2e38dd6beaed332bfccbda6d256b3f57d27cb7a0db370fb1a9019fbfed",
    "equal_current_and_prior_git_objects": true
  },
  {
    "path": "lean/DefiKernel/Typed/Transition.lean",
    "sha256": "73f264636236219e45720a531209f8c7ed8f5ee3f615fa34d58bc5596c4499d2",
    "equal_current_and_prior_git_objects": true
  },
  {
    "path": "lean/DefiKernel/Typed/Types.lean",
    "sha256": "5f2b7d30028c7445f5523b9a06cb1fb21f36fc28e38d50844d4270177f601f82",
    "equal_current_and_prior_git_objects": true
  },
  {
    "path": "lean/lean-toolchain",
    "sha256": "0d3c76ccd8772d8bcbe207241421a760312b71a6aa82f84194391fdf5cb026d6",
    "equal_current_and_prior_git_objects": true
  },
  {
    "path": "lean/lakefile.toml",
    "sha256": "4a1684945bf3632ee11a93b4529ce45335b97a878ca9a4a9a295981e7e97aa86",
    "equal_current_and_prior_git_objects": true
  },
  {
    "path": "lean/lake-manifest.json",
    "sha256": "8a6ceb0b073bcb3e437c3258aedf250b38da4dec0f696db6b2717bd987c43002",
    "equal_current_and_prior_git_objects": true
  },
  {
    "path": "scripts/check_atomic_mutations.py",
    "sha256": "ab64b7681be152bedc0baf9cc0703fd0cbcd82df79c3fb887be9959a41810007",
    "equal_current_and_prior_git_objects": true
  },
  {
    "path": "scripts/test_atomic_mutation_runner.py",
    "sha256": "dc539d354e1c9c7a3f3ccc7278b3d223fd4c015ba842cd4154930d2108e4e662",
    "equal_current_and_prior_git_objects": true
  }
]


===== INPUT AGENTS.md ORIGINAL_SHA256 60c7989fce2d680d68ac18bb970a79de65380aef9a44e70aa7205180c2d15a34 RENDERED_SHA256 60c7989fce2d680d68ac18bb970a79de65380aef9a44e70aa7205180c2d15a34 =====
# Working instructions

The user approved the semantic-kernel pivot on 2026-09-06. Read
`docs/superpowers/specs/2026-09-06-semantic-kernel-design.md` and
`docs/research/semantic-kernel-progress.md` before continuing work.

- The new migration supersedes the old publication-first runstate and the
  positive-program primitive-basis mandate. Historical documents remain
  evidence, not instructions to pursue a withdrawn objective.
- Use GPT-6 for implementation through the stock Codex harness. Have Grok and
  Fable independently check substantive results. Invoke their native CLIs
  directly from Codex. Do not use Foreman. Never substitute a GPT reviewer and
  label its response Grok or Fable.
- Record the exact reviewed revision, requested/reported model identity,
  result, findings, and fixes. An unavailable reviewer is an open review, not
  an approval. Review is advisory evidence, not a mathematical proof.
- Preserve existing proofs and negative results. Put new kernel work in a
  separate namespace. Do not change a historical theorem statement to make a
  new claim pass.
- Read `.claude/skills/defi-footguns/SKILL.md` and
  `formal/v3/GATE-REGISTER.md` when editing or reporting verification behavior.
  Empty checks are blocked. Keep proof, bounded execution, measurement and
  unchecked assumptions distinct, with exact input and tool identities.
- Lean is the mathematical authority. Any executable IR or Quint abstraction
  needs explicit correspondence. No `sorry`, custom axioms or `native_decide`
  in accepted kernel proofs.
- Preserve the original corpus and versioned source evidence. Do not silently
  relabel development examples as untouched holdouts.
- User authorization to execute this migration is already present. Resolve
  routine implementation details without repeatedly requesting approval.

## Reviewer change, 2026-09-07

The user explicitly replaced Fable with Opus for future external reviews. Use
native Grok plus native Claude Opus for substantive implementation/evidence
reviews, and nonauthor GPT-6 plus native Opus for new OpenSpec planning gates.
Request the native `opus` model alias and record the actual returned model.
Existing Fable reports and accepted historical plan bytes retain their original
identity. References to future Fable reviews in older plans are superseded by
this instruction; freeze updated reviewer bindings before new review execution.
GPT-6 implementation, stock Codex harness, and the no-Foreman rule remain in force.

## Latest reviewer change, 2026-09-07

The user subsequently instructed: "fable is back online use 5.1 medium effort".
This supersedes the earlier Opus selection for upcoming reviews. Use nonauthor
GPT-6 plus native Fable 5.1 for new planning gates, and native Grok plus Fable 5.1
for substantive implementation and evidence reviews. Invoke Claude with model
`claude-fable-5-1[1m]` and `--effort medium`, recording the actual returned model.
Preserve completed Opus and historical Fable reports with their original
identities; they are not relabelled as new Fable reviews. GPT-6 stock-harness
implementation, no Foreman, and existing execution authorization remain unchanged.


===== INPUT openspec/changes/operational-continuation-congruence/proposal.md ORIGINAL_SHA256 2a4b3b4c7beeb21ddd52b8d746c5d2c47fe2cfc9f1c7b50b362cfeaa2b620499 RENDERED_SHA256 2a4b3b4c7beeb21ddd52b8d746c5d2c47fe2cfc9f1c7b50b362cfeaa2b620499 =====
## Why

The operational kernel now has explicit sequential, parallel, interleaved and atomic boundaries, but its remaining metatheory cannot be discharged by historical list or binding algebra. This first bounded increment establishes actual sequential regrouping and preservation of old programs under unrelated configuration additions, providing a sound base for later multi-participant composition.

## What Changes

- Add a recursive sequential group executor that propagates the entire existing cursor, including capability administration and first refusal; prove its stepwise correspondence with the existing sequential executor and exact behavioral associativity.
- Define exact cursor observations with locally exposed runtime field comparisons and a restricted sequential context grammar, then prove observational equivalence laws and substitution for contexts with matching full continuation data.
- Define explicit configuration agreement on all referenced invocations and administrative grant scopes, prove actual single-step success/refusal equality, and lift it through supported sequential groups and invocation-only existing composition operators.
- Add independent financial and administrative examples, materiality counterexamples for omitted configuration/catalog/continuation premises, separately labeled synthetic observer pairs, imported proof inventory, production group/observation mutations and fully mapped defensive runner controls with bounded command times.
- Preserve the separate future obligations for operational Interface/Nary generalization, finite-participant grouping, causal composition, projected extension with unrelated state changes, dynamic provenance, and atomic-boundary regrouping.

## Capabilities

### New Capabilities

- `sequential-group-execution`: Real recursive execution with complete cursor propagation, identity, associativity and refusal absorption.
- `continuation-observation`: Exact financial cursor observations, equivalence and explicitly restricted sequential contextual substitution.
- `configuration-congruence`: Preserved old references and valid catalog assumptions yielding exact existing execution/admission agreement.
- `metatheory-regression-evidence`: Independent examples, premise counterexamples, actual production mutations, imported audits and source-bound acceptance evidence.

### Modified Capabilities

None. Existing operator requirements and historical theorem statements remain unchanged.

## Impact

New code belongs under `lean/DefiKernel/Metatheory/`; the root verification import and dedicated mutation scripts are the only planned integration changes. No dependency or toolchain change is needed. Planning uses the final accepted Sprint8 source as its implementation prerequisite, with separate GPT-6/native Fable 5.1 plan audits and native Grok/Fable 5.1 result audits at medium effort through stock Codex. The user already authorized autonomous execution and branch delivery. No Foreman or merge to main.

Accepted dependency: Sprint8 source `99e2e2c61a1a3c5249026921efdc6cd41ac8f21d`,
source/evidence delivery `2c038094c031723f3ade35d8b3f506ccff5b1d3b`, and verified
archive delivery `9501f0a4f0480b2a42ff197907d548cf0c610773`. Fresh baseline14 Lean
commands and13 Python suites passed at that source. Dependency/baseline completion
is separate from independent Sprint9 planning acceptance. Frozen r1 reviews remain
unchanged; this targeted revision addresses the six required native Opus changes
and must receive review of its new exact bytes before implementation.

The latest user reviewer instruction selects native Fable 5.1 with medium effort for upcoming reviews. Completed Opus and Fable reports retain their actual historical identities.


===== INPUT openspec/changes/operational-continuation-congruence/design.md ORIGINAL_SHA256 5e2d9b9a3c2102b18bd5d2997c9878dba589288523d5eb1ddfa92cc707e3860d RENDERED_SHA256 5e2d9b9a3c2102b18bd5d2997c9878dba589288523d5eb1ddfa92cc707e3860d =====
## Context

See proposal.md for motivation. This is increment M1 of
`wiki-llm/operational-metatheory-planning-draft.md`. The inspected source context is
accepted Sprint8 source `99e2e2c61a1a3c5249026921efdc6cd41ac8f21d`.
Source/evidence commit `2c038094c031723f3ade35d8b3f506ccff5b1d3b` and archive
metadata commit `9501f0a4f0480b2a42ff197907d548cf0c610773` were pushed and remotely
verified on `semantic-kernel-pivot`. Native Grok/Opus final acceptance and exact
source/evidence identities are retained in Sprint8's final-review and delivery
records. Fresh Sprint9 baseline evidence at the accepted source passed14 Lean
commands and13 Python suites; corrected final Python metadata is bound in the
planning dependency manifest. These completed prerequisites do not approve this revised plan. The frozen r1/r2
reviews are retained separately; native Opus accepted the semantic plan with
limitations. This revision clarifies three remaining runner requirements and
still needs independent review of its new candidate bytes before implementation. Author remediation is
not independent acceptance.

`Composition.Cursor` stores the whole world, raw events, frozen outputs, absolute
nextIndex and first located failure. `Composition.advance` executes invocation,
issue and revoke; a failed cursor is inert. `continueRun` is a list fold, whereas
this change needs a genuinely recursive group interpreter and its simulation.
`Parallel.observeBranch` retains event index/step/receipt/output, history, nextIndex
and failure, but omits raw event before/after worlds. Existing Parallel,
Interleaving and Atomic operators are invocation-only and keep distinct admission,
execution and public observation contracts.

`Composition.executeStep` first validates the entire catalog. Invocation uses the
complete lookupOperation pair, registry template, actual boundary/history/world,
and receipt extraction. Issue consults the registry-derived operation domain at
`Grant.operation`; the source has no field named grant.scope. Revoke looks up a
capability in the current store and consults its domain's trusted administrator.
These paths determine the configuration hypotheses, including failures.

## Goals / Non-Goals

Goals are recursive sequential cursor simulation and associativity, exact
continuation observations with a restricted context theorem, and configuration
agreement lifted through actual existing operators. All laws retain exact refusal
reasons, requests, evaluated receipts, qualified ordered snapshots, absolute
positions and complete capability stores where those fields are observed.

M2 port/binding algebra, finite-participant execution, parallel tree regrouping,
causal monitors, active new peers, identity-universe extension, arbitrary shared
commutation, dynamic capability provenance and movement of atomic commit
boundaries remain separate changes. No new configuration certificate checker or
runtime program-admission checker is introduced. Supported-program membership and
configuration agreement are explicit propositions used by proofs. They do not
turn program names into certificates or classify malformed configurations by a
new invented runtime label.

## Decisions

### 1. Recursive groups continue the actual cursor

Create `lean/DefiKernel/Metatheory/SequentialGroups.lean` with this interface:

```lean
inductive SeqGroup (P A D : Type)
  | empty
  | step (action : Composition.Step P A D)
  | seq (first second : SeqGroup P A D)

flatten : SeqGroup P A D → List (Composition.Step P A D)
runGroup (cfg : Composition.Config P A D) (boundaries : Nat → Composition.Boundary P A D)
  (cursor : Composition.Cursor P A D) : SeqGroup P A D → Composition.Cursor P A D
```

The empty case returns cursor. A leaf calls Composition.advance once. A sequence
recursively evaluates first, binds the resulting entire cursor, then recursively
evaluates second with that cursor. It does not call Composition.run/startCursor,
flatten, or the list executor in its runtime body. Flatten is a separately
recursive enumeration used by the proof and reference correspondence.

Prove for arbitrary cfg, boundary, cursor and group, with the existing finite typed
instances:

```text
runGroup cfg boundary cursor group
  = Composition.continueRun cfg boundary cursor (flatten group).
```

Induct on the actual group constructors, using the actual first-child result in
the sequence case and the existing list continuation append theorem. This proves
full cursor equality, including raw event worlds, not only ledger equivalence.
Derive both empty identities, refusal absorption and associativity of three actual
groups. A supplied cursor may have a nonzero index, earlier events/history,
administrative store changes, or an existing failure. No success premise or
initial-cursor restriction is allowed in this simulation.

This scope admits nested administrative steps. It does not claim child groups are
transactions; the existing sequential successful prefix remains after refusal.
An alternative definition that simply invokes the old executor on flatten would
make the desired simulation definitional and leave recursive propagation untested,
so it is excluded from the production interpreter.

### 2. Observation contains the full continuation interface

Create `Metatheory/Observation.lean`. `CursorObservation` contains the current
whole world and an exact `Parallel.BranchObservation`. `observeCursor` records
these fields. Its production Boolean comparison explicitly compares pointwise
all typed ledger cells, the complete capability store, ordered event indices and
steps, invoked/admin receipts, event outputs, the full frozen output history,
absolute nextIndex and the complete optional located failure. Write every production comparison locally in Observation.lean: separable Boolean
conjuncts for pointwise ledger, complete store, ordered events, frozen history,
nextIndex and failure. A locally written per-event comparison has separate
index, step, receipt and outputs conjuncts; M13 replaces only its receipt conjunct.
Compare lists with length/order-sensitive pointwise traversal using that local
event comparator. Do not delegate runtime equality to Parallel.worldEq or derived
DecidableEq of BranchObservation/EventObservation, and do not bury those conjuncts
in an imported comparator. Existing world/branch equality lemmas may be reused
only to prove the local comparator correct. Exact leaf-field decidable equality
(e.g. Receipt or LocatedFailure) remains allowed. No test-only selector flags.

Define `CursorEquivalent c d` as pointwise full current ledger equality, complete
store equality and equality of the exact branch observation. Prove comparison
iff that proposition and reflexivity, symmetry and transitivity. World extensional
identity and proof irrelevance justify passing the same computational state into
advance. Observed event records retain exact requests, evaluated deltas/supply,
outputs and issue/revoke IDs. Only past raw event before/after worlds and proof
terms are omitted. The observer does not permit direct inspection of those
omitted diagnostic worlds. This intentionally differs from the stronger full
cursor equality established by group simulation.

Create `Metatheory/Contexts.lean` with `SeqContext.hole`, `before fixed context`
and `after context fixed`. Filling replaces one group hole; fixed nodes are the
same SeqGroup on both sides. Contexts cannot inspect a cursor, reset it, switch
configuration/boundary, add a peer or introduce an atomic commit boundary.

First prove advance and runGroup preserve CursorEquivalent for the same step or
group. Then define `GroupEquivalent cfg boundary g h` by quantifying over EVERY
pair of CursorEquivalent input cursors and requiring equivalent returned cursors.
Prove the equivalence laws and `GroupEquivalent g h → GroupEquivalent (fill C g)
(fill C h)` for this grammar. The universal input premise is needed for fixed
prefix contexts; equality from one particular entry is insufficient. A weaker
same-entry endpoint statement must not be renamed contextual equivalence. For its
negative witness, use groups with the same initially refusing first action and
different suffixes. At the original entry both observations agree; a fixed
authorized funding prefix enables that first action and exposes the different
suffix behavior. All calls use the same boundary function with sufficient exact
authority for the funding movement. Frozen
outputs, store, nextIndex and first failure are used in the advance proof rather
than reconstructed from the current ledger.

### 3. Configuration agreement is an explicit sufficient premise

Create `Metatheory/Configuration.lean` and `ConfigurationGroups.lean`. A reference
set has `calls : Set (ComponentId × OperationId)` and `operations : Set OperationId`.
SupportedStep requires both the invocation pair and invocation operation for an
invoke; requires Grant.operation for issue; revoke has no static operation
reference. SupportedGroup/List/Branch quantify over all submitted leaves, including
unreachable suffixes. Define unions and prove their support laws; none is a new
checker or runtime certificate.

All agreement definitions and congruence theorems bind one shared set of types
P/A/D and one shared set of corresponding DecidableEq/Fintype instances for both
configurations. This is a binder-shape constraint, not a ConfigAgreement field
and not a heterogeneous identity or instance-equality proposition.

`ConfigAgreement old new refs : Prop` has only the following premise fields:
- validateCatalog old.registry old.catalog = true and the same for new;
- old.registry op = new.registry op for every op in refs.operations;
- lookupOperation old.catalog component op = lookupOperation new.catalog component op
  for every (component,op) in refs.calls, preserving the complete component/interface
  pair, including access declarations and None results;
- old.domainAdmin d = new.domainAdmin d for EVERY d.

The final premise is deliberately stronger than agreement only on issue targets:
an arbitrary starting cursor can revoke a capability whose domain comes from its
current store. Both configurations use the same complete initial world/store,
boundary function, history and indices. Full registry-template equality on issue
references is also stronger than the minimal operation-domain equality, but gives
one small sufficient relation for this increment. Both stronger choices remain
explicit in theorem statements and negative examples.

Prove actual `Composition.executeStep old boundary index history step world =
Composition.executeStep new boundary index history step world` from
ConfigAgreement and SupportedStep. Follow actual computation in order: global
validation, prepareInvocation/access/input resolution, registry evaluation,
receipt extraction and snapshots; handle every error branch. For issue, derive
equality of registryAuthorityConfig.operationDomain at grant.operation. For
revoke, use equal store lookup and domainAdmin agreement. Do not use an assumed
executeStep equality, equal successful receipts, or a whole-run equivalence as an
agreement field. Reflexivity is conditional on catalog validity; symmetry and
transitivity are agreement laws, not evidence that arbitrary additions are safe.

Induct advance/continueRun over supported lists, then use actual recursive group
simulation for group congruence. This yields exact cursor equality, including
admin receipts, next fresh IDs, tombstones and refusals. Both-valid catalogs also
make the two actual startCursor results equal.

### 4. Lift through the existing operators without changing their semantics

Create `Metatheory/OperatorLifting.lean`. On supported invocation-only left/right
branches, prove analyzeInvocation/analyzeBranch equality, hence exact Parallel,
Interleaving and Atomic admission equality with their original error precedence.
All static branch positions are covered even if execution would refuse earlier.
Compatibility, schedule counts and Atomic policy are the same on both sides;
Atomic policy lanes/participants and event label are immutable parameters.

Lift actual executeStep equality through isolated Parallel branch execution,
shared Interleaving tokens and Atomic token/attempt/receipt updates. Prove exact
existing Result equality where the runtime data permits structural equality;
otherwise use an explicit full data relation with a separate extensionality proof
that yields equality. Do not weaken to final balances or just committed outcomes.
The Atomic theorem includes admission refusal, kernel abort, lane-supply abort,
unsettled residuals and commit, preserving the supplied schedule and all diagnostic
fields. No operator gets a new admission rule or certificate wrapper.

A direct induction over existing operator machines is bounded and preserves their
contracts. Translating all operators into a new general syntax would add another
semantics and an unnecessary correspondence obligation, so it is excluded.

### 5. Independent examples and negative companions

Create `Metatheory/Examples.lean`, `Tests.lean`, `Audit.lean` and `Verify.lean`.
Reuse existing typed financial templates as inputs but construct expected worlds,
complete stores, requests/receipts, snapshots and failures independently. Tests
must not compute expected values by calling runGroup, flatten/continueRun, or the
new comparator. Generic simulation comparisons are useful additional checks, not
the only financial oracle.

The main sequential fixture starts Alice USD10/Bob0/Carol0. Its first nonempty
leaf transfers7 from Alice to Bob and exports Alice's post-balance3. The second
uses that exact qualified prior output to transfer3 from Alice to Carol, leaving
Alice0/Bob7/Carol3. The third transfers1 from Bob to Alice, leaving
Alice1/Bob6/Carol3. The trusted boundary selects Alice at absolute positions0/1
and Bob at2; the fixture supplies exact valid rights. Independently construct all
three intermediate and final worlds and ordered receipts/snapshots. Include a
separate transfer7 followed by refused transfer6 retaining Alice3/Bob7; its funded
suffix would otherwise move funds. An administrative fixture
issues a capability in one group, invokes it in the next, revokes it in another,
then observes exact denied use and an inert suffix. Start another fixture with
existing store entries and nextIndex nonzero to test fresh-ID/index continuation.
Index-dependent boundaries vary actor and time at known absolute slots; expected
results bind those exact slots.

Configuration positive: a fresh operation/component outside the finite support is
added, both catalogs validate, old component/interface/registry values and admins
remain equal, and a nonempty old program including issue/invoke/revoke has identical
actual execution. Invocation-only Parallel, Interleaving and Atomic siblings use
fixed identical boundaries/schedule/policy and include success and actual refusal
or abort. Empty programs alone do not satisfy this evidence obligation.

Named negative companions establish materiality of the listed omitted premises,
not minimality or necessity of every stronger sufficient hypothesis. Full registry
template equality and all-domain admin equality deliberately exceed the minimal
conditions. The identical-initial-world condition is a theorem-input premise, not
an agreement field. Concrete witnesses cover: changed old
registry behavior; changed old component access/output declaration; newly invalid
or duplicate catalog entry causing exact configuration refusal; grant-only
operation domain changed while invoked-operation lookups agree; changed trusted
admin changing issue/revoke authorization; an extra initial capability changing
issued ID despite equal ledger. These are actual old/new execution differences,
not an expected compilation failure or a fake agreement-checker status. Witness
both validity results where the omitted premise is not catalog validity. For a
changed registry keep signature/output-domain contracts fixed and change a guard,
compatible delta or write behavior. Put the grant-only operation in the registry
without a declaring catalog component so changing its domain does not separately
invalidate a catalog interface. Preserve export/import/private-cell validity when
changing component access/output declarations. These constructive constraints
isolate the stated missing premise rather than introducing an accidental second
validation failure.

Observation counterexamples use equal-ledger cursors with different frozen outputs,
indices or stores and a continuation that produces an actual different result.
Also compare a pair differing only in a past raw event world: the selected observer
intentionally equates them, and the restricted continuation remains equivalent.
Observer-only single-field and omitted-raw-world pairs are explicitly synthetic
arbitrary cursors and may be unreachable. Label their sensitivity results
separately from actual financial execution; the universal-input theorem covers
them, but they are not assertions of reachable trace differences.
A swap of shared withdrawals7 and 6 from USD10 and an explicit one-transaction vs
two-boundary rollback example delimit associativity's scope; no general atomic or
parallel reassociation claim is inferred.

### 6. Fourteen actual mutations and 65 defensive controls

Use `scripts/check_metatheory_mutations.py`,
`scripts/test_metatheory_mutation_runner.py` and `mutations/metatheory.json`, adapting
the accepted Atomic runner's explicit recursive local source discovery and strict
runtime/proof boundary parser. Production mutation targets are ONLY the new
SequentialGroups/Observation runtime definitions. Imported kernel source stays
byte-identical. Every mutation must compile, change exactly one intended source
site, make its designated independent comparison false, and preserve declared
nonempty positive comparisons. A compiler error earns no financial detection. Each M01–M08 needle must occur
exactly once in its target module runtime prefix. M01–M07 may share the same
unique seq-branch needle across separate variants; each replaces it once. Use a
textually distinct leaf-call needle for M08, scoped with its step constructor
where necessary. Record the measured count before applying each replacement;
zero or duplicate matches are blocked, never semantic detections.

| ID | Actual mutation | Designated independent oracle | Protected positive |
| --- | --- | --- | --- |
| M01 | At seq, pass entry world to second child | `metatheory.group.world-chain`: transfer7 then funded continuation retains exact intermediate world | single nonempty leaf |
| M02 | At seq, restore entry capability store | `metatheory.group.store-chain`: issued grant remains usable with exact fresh ID | store-independent nonempty transfer |
| M03 | At seq, reset frozen output history | `metatheory.group.history-chain`: consumer uses first child's exact snapshot | literal-input nonempty sequence |
| M04 | At seq, reset nextIndex to entry index | `metatheory.group.index-chain`: nonzero absolute indices and qualified previous output | single nonempty leaf |
| M05 | At seq, clear first failure | `metatheory.group.refusal-absorption`: funded suffix stays inert after exact middle refusal | successful nonempty sequence |
| M06 | Skip the second child | `metatheory.group.child-executed`: second funded movement appears with exact receipt/world | single nonempty leaf |
| M07 | Reverse child order | `metatheory.group.ordered`: asymmetric movements/producer-consumer result | single nonempty leaf |
| M08 | Replace new leaf call `Composition.advance cfg boundaries cursor action` with `Composition.advance cfg (fun _ ↦ boundaries 0) cursor action` | `metatheory.group.boundary-index`: distinct absolute actor/time yields exact authorization | nonempty index-insensitive boundary sibling |
| M09 | Omit current ledger from cursor comparison | `metatheory.observe.world-diff`: same other fields, changed protected cell must differ | equal nonempty cursor |
| M10 | Omit complete store from comparison | `metatheory.observe.store-diff`: ledger same, tombstone/entry differs | equal nonempty cursor |
| M11 | Omit frozen history comparison | `metatheory.observe.output-diff`: same events, differing qualified history | equal nonempty cursor |
| M12 | Omit failure comparison | `metatheory.observe.failure-diff`: exact reason/location/step differs | equal nonempty cursor |
| M13 | Omit event receipt comparison | `metatheory.observe.receipt-diff`: same remaining fields, evaluated receipt differs | equal nonempty cursor |
| M14 | Omit nextIndex comparison | `metatheory.observe.next-index-diff`: same other fields, absolute position differs | equal nonempty cursor |

M09–M14 are production observation sensitivity checks on explicitly synthetic
arbitrary/unreachable cursor pairs; classify them separately from the eight
executor-routing mutations. The exact M08 replacement is in SequentialGroups.lean;
Composition.advance itself and every imported kernel byte remain unchanged. Include changed/equal pairs for every
subfield beyond the single required mutant site, including event outputs, step,
receipt request/evaluated values and failure step=None versus Some.

The required 65 controls are the actual `cases()` inventory in the updated
`test_atomic_mutation_runner.py` at accepted source99e2e2c, including its two
production audit-output controls and corrected CLI-log pointers. The fresh
Sprint9 baseline also executed all65 controls at that exact source. Adapt module roots, fixtures and labels to
Metatheory, including renaming the discovered Atomic dependency control. Retain
all 11 NEW proof-tail parser controls and both production `#eval`/`IO.userError`
forms. The 52 inherited controls already include
`runtime-definition-after-proof-boundary`, making 12 proof-tail-related controls
in total; 52+11+2=65 counts provenance increments, not disjoint semantic categories.
Capture the exact name map/count and accepted source hash at implementation
freeze; do not silently drop a control. Expected classifications remain valid/violated/blocked,
with exit0/1/3 at the underlying runner. Malformed/partial/empty inventories,
compiler-only failures, dirty/staged/drifting inputs, symlinks and runtime code
hidden after the proof marker remain blocked. Mutant compiler failures and these
runner-defense tests are separate from financial detections.

#### Required runner adaptation and bounded runtime closure

The accepted script and fixture mapping is exhaustive across runtime identifiers,
not only the 65 case names. Save exact old/new strings, source hash and replacement
site in the implementation map; preserve all other behavior and expected exits:

| Surface | Accepted Atomic value | Required Metatheory value |
|---|---|---|
| Driver/default harness path | `scripts/check_atomic_mutations.py` | `scripts/check_metatheory_mutations.py` |
| Harness path | `scripts/test_atomic_mutation_runner.py` | `scripts/test_metatheory_mutation_runner.py` |
| Explicit `--spec` path (driver has no default) | `review/semantic-kernel/sprint8/mutation-spec.json` | `mutations/metatheory.json` |
| Scoped-module regex | `DefiKernel\.Atomic(?:\.[A-Za-z][A-Za-z0-9]*)+` | `DefiKernel\.Metatheory(?:\.[A-Za-z][A-Za-z0-9]*)+` |
| Proof-trimming prefix | `DefiKernel.Atomic.` | `DefiKernel.Metatheory.` |
| Required audit root | `DefiKernel.Atomic.Audit` | `DefiKernel.Metatheory.Audit` |
| Missing-root error | `missing Atomic audit root` | `missing Metatheory audit root` |
| Proof-suffix closure regex | `\n(end DefiKernel\.Atomic(?:\.[A-Za-z][A-Za-z0-9]*)*)\s*$` | `\n(end DefiKernel\.Metatheory(?:\.[A-Za-z][A-Za-z0-9]*)*)\s*$` |
| Exact failed-comparison message | `Atomic runtime comparisons failed: N` | `Metatheory runtime comparisons failed: N` |
| Parsed Lean error line | `error: Atomic runtime comparisons failed: N` | `error: Metatheory runtime comparisons failed: N` |
| Empty/duplicate messages | `Atomic runtime comparisons empty`; `Atomic runtime comparison names are duplicated` | `Metatheory runtime comparisons empty`; `Metatheory runtime comparison names are duplicated` |
| Input/split/absent fixture modules | `DefiKernel.Atomic.{RunnerInput,SplitComputation,Absent}` | `DefiKernel.Metatheory.{RunnerInput,SplitComputation,Absent}` |
| Fixture namespace and paths | `DefiKernel.Atomic`, `lean/DefiKernel/Atomic/` | `DefiKernel.Metatheory`, `lean/DefiKernel/Metatheory/` |
| Production fixture namespace | `DefiKernel.Atomic.Audit` | `DefiKernel.Metatheory.Audit` |
| Imported dependency fixture | `DefiKernel.Interleaving.RunnerDependency` | unchanged: remains outside the trimmed prefix |
| Nonkernel dependency fixture | `SharedFixture` | unchanged |
| Invalid-scope fixture | `DefiKernel.Composition.RunnerInput` | unchanged: still invalid scoped root |
| Dependency discovery case | `discovered-atomic-dependency` | `discovered-metatheory-dependency` |

N is the number of false comparisons, never a printed list. Update both production
Audit `IO.userError` and synthetic harness `throwError` assertions consistently,
including captured projection-order and source-path expectations. Retain all
remaining case names through the existing exact65-name map.

Runtime Audit/Tests/Examples imports must avoid imported Tests, ObservationTests,
Verify and proof-only fixture modules. In particular reuse Atomic.Examples and
Parallel.Examples, not Atomic.Tests or Parallel.ObservationTests, which brings in
the expensive Composition.Examples workflow proof. New proof-lifting modules are
imported by Verify, not the runtime Audit closure; runtime support data must live
in new runtime modules before their proof marker. Inspect the full recursive local
closure, including transitive imports, and record it before mutation execution.
Imported proofs needed by old computational modules remain intact; do not solve
cost by stripping proofs outside the declared Metatheory prefix or changing old
source. Scope all mutation roots to the new computation and Audit dependencies.

Explicitly pass `--timeout-seconds 600` to the mutation runner (each Lean/Git
command); the CLI-control harness gives each runner subprocess 1500 seconds.
Record UTC start/finish and measured monotonic wall time for every command and
case, with the 15 production variants (control plus14 mutants) reported separately.
Import pruning is the first response to excessive cost; any timeout or incomplete
output is blocked evidence (exit3), never semantic detection. Preserve
already completed command logs, the retained fresh output directory and prior
results.json records, plus the outer captured stderr identifying the timed-out
command and limit. Preserve the accepted runner behavior: it does not emit a
per-command log or results.json entry for the timed-out command, and partial
stdout from that command is unavailable. Do not claim a complete inventory or
measured completed-command record for it. No timeout-capture implementation or
additional control is introduced by this sprint; fix and rerun affected jobs. These are
per-command bounds, not a 1500-second cap on the whole 65-control suite.

### 7. Evidence and integration

Every new executable declaration, syntax/macro/initialization block precedes its
file's `-- BEGIN PROOFS` marker. Proof-only definitions that are executable must
also precede it; the projection cannot quietly discard supporting runtime code.
Root `lean/DefiKernel.lean` gains the new Verify import after targeted checks.
No historical namespace or theorem is rewritten. No dependency upgrade is planned.

Use LSP first and pinned Lake from `lean/`; literal installed Lean4 skill runtime,
no sorry/custom axioms/native_decide. Fresh full Lean and prior Python regressions,
14 real mutations and 65 controls need nonempty inventories and exact source/tool/
Git/log/artifact bindings. Scan imported Metatheory theorems and supplemental
declarations mechanically, preserve full pp.proofs statements/private helpers,
and classify generic proofs, concrete instances, counterexamples, generated
constants, runtime observations and compiler controls separately.

## Risks / Trade-offs

- [Ledger-only equivalence loses continuation inputs] → Include full store, ordered
  histories, nextIndex and first failure; prove actual advance preservation.
- [Raw event world omission mistaken for full abstraction] → Restrict the observer
  and context grammar explicitly; group associativity separately proves full cursor equality.
- [Static support misses issue-only registry dependencies] → Collect Grant.operation;
  use a real grant-only operation-domain counterexample.
- [Global validation changes unrelated old execution] → Require both catalogs valid;
  preserve a named invalid-extension refusal witness.
- [Administrative result IDs depend on initial store] → Require the whole same world;
  demonstrate equal-ledger/different-store issue-ID failure.
- [Scope grows into later metatheory] → Only binary sequential syntax and existing
  operator configuration lifting; no new peers, participant types or commit boundaries.
- [Mutation projection or expected values mask an error] → Freeze actual source sites,
  independent full financial expectations, positive siblings and all defensive controls.

## Migration Plan

1. Verify the recorded accepted Sprint8 source/delivery/archive and passing baseline
   bindings, freeze this complete plan and obtain independent GPT-6/native Fable 5.1
   planning verdicts on identical bytes.
2. Recheck baseline input identities before implementation; rerun only if relevant
   inputs changed. Implement only new Metatheory modules, with targeted proof/runtime
   checks before root integration.
3. Freeze implementation/spec/runner source, execute complete new and prior evidence,
   obtain native Grok/Fable 5.1 substantive-result and evidence reviews, and address
   concrete blockers through targeted revisions until resolved.
4. Archive OpenSpec only after acceptance, reconcile source/evidence manifests and
   push the user-authorized branch with remote verification. No merge to main.
   Rollback before delivery removes only the new import/modules in a reviewed
   revision; retain failed review/mutation artifacts and historical accepted bytes.

Reviewer binding follows the 2026-09-07 user override in `AGENTS.md`: future
planning uses nonauthor GPT-6 plus native Fable 5.1; substantive source/evidence
reviews use native Grok plus native Fable 5.1. Request `claude-fable-5-1[1m]`
with medium effort, record the actual returned model identity, and keep unavailable
reviews open. This follows the latest user instruction, superseding the Opus
selection for future reviews. Historical Opus and Fable
reports and accepted historical plan bytes retain their original identity.


===== INPUT openspec/changes/operational-continuation-congruence/tasks.md ORIGINAL_SHA256 d0e54612901526351b2a73879e7a84b0f5f8458ac52fc6340c5cfb60b8d8af9b RENDERED_SHA256 d0e54612901526351b2a73879e7a84b0f5f8458ac52fc6340c5cfb60b8d8af9b =====
## 1. Accepted dependency and independent planning gate

- [ ] 1.1 Verify accepted Sprint8 source99e2e2c, source/evidence2c038094 and archived/delivered9501f0a4 bindings in this change, `wiki-llm/sprint-9-operational-continuation-congruence.md` and the planning manifest; verify acceptance, exact full revisions, remote branch identity and unchanged historical bytes before freezing the Sprint9 bundle.
- [ ] 1.2 Obtain separate non-author GPT-6 and native Fable 5.1 planning reviews of the identical proposal/design/four specs/tasks/scenario map/source bundle; verify exact candidate and bundle hashes, requested `claude-fable-5-1[1m]` model and medium effort and actual returned model identity, substantive verdicts and adjudication, leaving both reviews pending until actually run.
- [ ] 1.3 Verify the completed fresh14 Lean-command and13 Python-suite baselines at accepted source99e2e2c, corrected final metadata and protected source/tool/driver identities under `review/semantic-kernel/sprint9/planning/baseline/`; recheck nonempty inventories and input hashes before creating Metatheory source, rerunning only if relevant inputs change and preserving any failed attempts.

## 2. Actual recursive sequential execution

- [ ] 2.1 Create `lean/DefiKernel/Metatheory/SequentialGroups.lean` with SeqGroup.empty/step/seq, separate flatten and a recursive runGroup using Composition.advance at leaves and the full first-child cursor at seq; record the initial missing-feature check, then verify LSP and `lake build DefiKernel.Metatheory.SequentialGroups` from `lean/` with all runtime declarations before the proof marker.
- [ ] 2.2 Add the first independent group expectations in `Metatheory/Examples.lean` and `Tests.lean`: transfer7 producer exporting Alice3, snapshot consumer transferring3 to Carol and Bob's return1; verify exact Alice1/Bob6/Carol3, ordered outputs, actual receipts and absolute indices for nested groups.
- [ ] 2.3 Prove runGroup equals actual Composition.continueRun on flatten for arbitrary initial cursor, including raw event worlds, history, store, index and failure; verify the generic statement has no successful-only or initial-cursor restriction and targeted Lean checks cover administrative and prefailed instances.
- [ ] 2.4 Derive full-cursor empty identities, refusal absorption and three-group associativity from actual recursive simulation; verify three nonempty groups and the middle-refusal inert-suffix case, retaining a separate reversed-shared-order negative result.

## 3. Exact observations and restricted contexts

- [ ] 3.1 Create `Metatheory/Observation.lean` with observeCursor, CursorEquivalent and the production fieldwise Boolean comparison specified in design.md, with local separate ledger/store/events/history/index/failure conjuncts and a local event index/step/receipt/output comparator (existing equality reuse is proof-only); verify independently constructed equal/changed pairs for current ledger, full store, event index/action/receipt/output, frozen history, nextIndex and exact optional failure.
- [ ] 3.2 Prove comparison iff CursorEquivalent plus reflexivity/symmetry/transitivity; verify the full elaborated statements and a pair differing only in omitted past raw event worlds, without claiming equality of their raw cursors.
- [ ] 3.3 Prove actual Composition.advance and runGroup preserve CursorEquivalent for the same action/group; verify proofs use equal current whole world, history, nextIndex and failure while preserving the observed event prefix, including issue/revoke and actual refusal branches.
- [ ] 3.4 Create `Metatheory/Contexts.lean` with the one-hole before/after fixed-group grammar and universal-input GroupEquivalent; prove its equivalence laws and fill substitution, then verify fixed nonempty prefixes/suffixes and an output-consuming continuation under identical configuration/boundaries.
- [ ] 3.5 Add actual missing-history, missing-index, missing-store and one-entry-only substitution counterexamples in `Metatheory/Examples.lean`/`Tests.lean`; verify each omitted premise permits different real continuation behavior and that no diagnostic inspection, peer addition or boundary movement is admitted by the context grammar.

## 4. Explicit configuration agreement and administrative scope

- [ ] 4.1 Create `Metatheory/Configuration.lean` reference sets, support predicates and ConfigAgreement with both catalogs valid, supported registry/full component-interface lookups equal and all-domain trusted admins equal, using shared P/A/D and typeclass binders rather than a heterogeneous type/instance field; verify support includes every issue Grant.operation and all static suffixes, and agreement contains no desired execution equality or invented runtime checker.
- [ ] 4.2 Prove exact actual Composition.executeStep congruence for supported invokes by following validation, preparation/access/input resolution, execution and receipt extraction; verify generic success and all refusal branches including agreed absent lookups, with identical boundary/index/history/full world premises.
- [ ] 4.3 Prove issue/revoke cases through actual registryAuthorityConfig and current-store lookup, using supported Grant.operation and all-domain admin equality; verify exact issue IDs, tombstones, unknown-capability/admin/domain failures and the grant-only operation-domain negative companion.
- [ ] 4.4 Create `Metatheory/ConfigurationGroups.lean`; lift support and configuration equality through advance/startCursor/continueRun/run and recursive groups, proving support union and valid-config agreement laws; verify full cursor equality across nonempty issue/invoke/revoke groups and unreachable suffix support.
- [ ] 4.5 Add independently executed configuration-premise witnesses for changed old registry, changed complete component/access/output lookup, invalid added catalog, changed grant-only operation domain, changed trusted admin and differing initial store; verify exact old/new outcomes and all remaining applicable premises as materiality witnesses, not minimality of the stronger sufficient hypotheses; keep changed registry signatures/output domains valid, grant-only domain-changing operations uncataloged and component ownership/import/export declarations valid.

## 5. Existing operator lifting

- [ ] 5.1 Create `Metatheory/OperatorLifting.lean` and prove supported analyzeInvocation/analyzeBranch equality and exact existing Parallel/Interleaving/Atomic admission equality; verify both complete valid catalogs, every static position, original error precedence, same policy and schedule, including malformed unreachable suffixes.
- [ ] 5.2 Lift actual step congruence through Parallel isolated branch execution and merge with identical branches/initial whole world; verify exact success and refused-branch results and independently expected nonempty financial controls.
- [ ] 5.3 Lift actual step congruence through shared Interleaving token execution using identical complete schedules and boundaries; verify exact attempt pre-worlds/outcomes, own histories, local indices and retained refusals under success and failure examples.
- [ ] 5.4 Lift actual step congruence through Atomic attempts, receipt-derived table updates and finish/public projection with the same policy/label/schedule; verify exact committed, admission-refused, kernel-aborted, supply-aborted and unsettled results without inserting a new checker or weakening equality to balances.

## 6. Independent examples and imported checks

- [ ] 6.1 Complete group financial and administrative cases in `Metatheory/Examples.lean` and `Tests.lean`, including nonzero starting index/store, index-dependent actor/time, issue-use-revoke-denied-use and retained-prefix refusal; verify independent full expectations and nonempty positive controls for all eight routing mutants.
- [ ] 6.2 Complete unrelated valid configuration-extension fixtures and existing operator siblings in `Metatheory/Examples.lean` and `Tests.lean`; verify both real catalog validity checks, explicit agreement proof instances, nonempty old-program success/refusal and exact whole-store preservation.
- [ ] 6.3 Complete observation sensitivity pairs for every retained subfield and the six designated omission oracles; verify each changed pair differs and each equal nonempty pair compares equal without deriving expected values through the comparator under test, explicitly labeling synthetic arbitrary/unreachable observer-only pairs separately from actual financial runs.
- [ ] 6.4 Add named checked counterexamples to scalar ledger-only continuation, one-entry replacement, shared reordering and moving an atomic commit boundary, plus the configuration witnesses; verify concrete success/refusal/rollback differences and record these as bounds on stronger claims rather than new operator laws.
- [ ] 6.5 Create `Metatheory/Audit.lean` and `Verify.lean`, then integrate only the root verification import; verify all unique nonempty `metatheory.*` runtime observations, automatic imported theorem/supplemental axiom checks and zero forbidden dependencies with `lake build DefiKernel.Metatheory.Verify DefiKernel` from `lean/`.

## 7. Actual mutations and defensive controls

- [ ] 7.1 Add `scripts/check_metatheory_mutations.py`, `scripts/test_metatheory_mutation_runner.py` and `mutations/metatheory.json` by adapting final accepted Sprint8 runner behavior using every design mapping: driver/spec paths, scoped-module regex, audit root, proof-prefix and namespace-closure regex, exact `Metatheory runtime comparisons failed: N` error and empty/duplicate strings, fixture namespaces/paths and production assertions; verify a counted inventory of every case-insensitive Atomic occurrence in both accepted scripts (including descriptive fields, case-name tuple and exact error assertions), its explicit keep/rename decisions and the actual old explicit --spec path, real unchanged source projection, complete module/check inventory and strict executable-before-proof-boundary enforcement with fresh external output directories.
- [ ] 7.2 Implement the exact eight production group-routing mutations M01–M08 in the new interpreter source sites listed in design.md, with M08 replacing only the leaf boundary argument by `(fun _ ↦ boundaries 0)`; verify each needle occurs exactly once in its target runtime prefix, with distinct leaf and seq forms and one replacement per variant, then verify every mutant compiles, its independent full-result comparison is false and its declared nonempty positive sibling remains true, with no imported kernel edit.
- [ ] 7.3 Implement the exact six production observation omission mutations M09–M14 in actual comparison code; verify every changed-pair sensitivity comparison becomes false and equal nonempty pairs remain true, separating this evidence from financial execution-routing detections.
- [ ] 7.4 Adapt all 65 final established actual CLI controls, including the 11 NEW proof-tail controls plus `runtime-definition-after-proof-boundary` already in the 52 inherited controls (12 related cases total), and two production audit-output forms, with an explicit old/new control-name map; verify every real subprocess has the expected valid/violated/blocked classification and compiler-only failures receive no semantic detection credit.
- [ ] 7.5 Freeze Metatheory source, spec and drivers and execute all 14 production mutations plus 65 controls in fresh external trees; verify exact source Git objects, all required false/protected true observations, complete logs/UTC/tool identities, before/after drift checks and artifact manifests while retaining unsuccessful attempts separately; enforce a runtime Audit closure free of imported Tests/proof-only fixtures (reuse Atomic.Examples/Parallel.Examples), explicitly pass runner `--timeout-seconds 600`, retain 1500-second harness runner-subprocess limits, record measured wall time per command/case/variant, and classify any timeout/incomplete output as blocked exit3 with no detection credit; retain completed-command logs/prior records/fresh directory and outer timeout stderr, without claiming a timed-out-command log/record or changing the inherited timeout path.

## 8. Final source-bound acceptance and delivery

- [ ] 8.1 Run fresh full prior Lean and Python regression suites plus the new imported runtime/proof checks; verify nonempty inventories, exact existing input preservation and no regression at the frozen final candidate, distinguishing compiler controls and source-preserving equivalent metadata revisions.
- [ ] 8.2 Generate complete elaborated/source theorem and supplemental inventories with private-name mapping, premise classes, source/module/Git provenance and every actual scenario mapping under `review/semantic-kernel/sprint9/`; verify exact inventory equality with fresh Verify output and distinguish generic proofs, reference instances, counterexamples, generated constants and execution evidence.
- [ ] 8.3 Obtain native Grok and Fable 5.1 substantive source/proof and final evidence reviews on the same bound candidate; verify the requested native `claude-fable-5-1[1m]` model and medium effort, actual returned model identity, provenance logs and adjudication, resolve concrete blockers through targeted revisions until resolved and leave missing verdicts open rather than substituting author review.
- [ ] 8.4 After accepted reviews and complete evidence, archive this OpenSpec change, reconcile wiki/progress and source/evidence manifests, and push the authorized branch; verify archived requirement/scenario preservation, strict validation and remote commit equality without merging to main or rewriting historical accepted evidence.


===== INPUT openspec/changes/operational-continuation-congruence/specs/configuration-congruence/spec.md ORIGINAL_SHA256 e9d7449a607cbd2b3db4796a9654a642a0976995467ece59aef727acbe5861f6 RENDERED_SHA256 e9d7449a607cbd2b3db4796a9654a642a0976995467ece59aef727acbe5861f6 =====
## Purpose

Specify explicit configuration support premises that preserve actual old-program execution and existing operator admission behavior.

## ADDED Requirements

### Requirement: Explicit configuration agreement

Configuration agreement SHALL be a proof premise over a fixed identity universe, with both complete catalogs valid, equal registry templates for every supported operation, equal full component/interface lookup results for every supported invocation pair, and equal trusted domain administrators. Support SHALL include grant-only operation references and every static suffix. Theorems SHALL bind shared identity types and corresponding instances once for both configurations; this SHALL NOT be a heterogeneous type/instance equality field of the agreement proposition.

#### Scenario: Unrelated valid declarations

- **WHEN** an unrelated operation/component is added while both catalogs remain valid and every supported lookup and administrator agrees
- **THEN** a nonempty supported old program retains exact behavior

#### Scenario: Grant-only operation support

- **WHEN** an issued grant references an operation that no invocation in the program calls
- **THEN** that operation remains in the explicit configuration support obligations

#### Scenario: No certificate checker claim

- **WHEN** a theorem is applied using configuration agreement and supported-program premises
- **THEN** the evidence records those premises rather than inventing a new runtime certificate or program-label checker

### Requirement: Exact single-step congruence

Under explicit agreement and support, old and new configurations SHALL give equal actual single-step results for the same full world, authenticated boundary, absolute index and frozen history. Equality SHALL cover success and every refusal, including receipt extraction and administrative failures.

#### Scenario: Invoked success and refusal

- **WHEN** the supported invocation succeeds or fails under the old configuration
- **THEN** the new result has the same world, request/evaluated receipt, outputs or exact failure reason

#### Scenario: Issue and revoke

- **WHEN** supported administration executes against the same current complete store
- **THEN** fresh IDs, tombstones, authorization results and all administrative refusals are equal

#### Scenario: Absent old lookup

- **WHEN** both agreeing supported lookup results are absent
- **THEN** both executions return the same actual unknown-operation or interface refusal

### Requirement: Supported execution lifting

The agreement theorem SHALL lift through sequential continuation and recursive groups, then through the existing invocation-only Parallel, Interleaving and Atomic operators. Every static invocation SHALL be supported; the same boundaries, initial whole world, branch order, schedule, label and Atomic policy SHALL be used.

#### Scenario: Unreachable static suffix

- **WHEN** an early invocation refuses before a later submitted invocation
- **THEN** the later invocation remains covered by the static support premise and structural admission retains its original precedence

#### Scenario: Sequential administration lifting

- **WHEN** issue, invocation and revoke cross nested group boundaries
- **THEN** both configurations return identical complete cursors

#### Scenario: Parallel and interleaved lifting

- **WHEN** supported invocation-only branches use their existing parallel or scheduled shared execution
- **THEN** both admission results and executed results are equal, including exact refusals and histories

#### Scenario: Atomic lifting

- **WHEN** the same supported atomic request commits, refuses admission or aborts
- **THEN** both configurations preserve that exact result, supplied schedule, diagnostic table and public publication behavior

### Requirement: Configuration counterexamples

The evidence SHALL include actual execution differences establishing materiality of the listed agreement or identical-world premises when omitted. It SHALL NOT claim minimality or necessity of full registry-template equality or all-domain administrator equality, which are stronger sufficient conditions. Global catalog validity SHALL remain a premise even for newly added declarations outside old support.

#### Scenario: Changed old registry

- **WHEN** an old supported template changes guard or compatible delta/write behavior while signature/output-domain contracts and remaining applicable premises hold
- **THEN** a concrete old invocation yields a different actual result

#### Scenario: Changed component declaration

- **WHEN** an old component access or output declaration changes without preserving its complete lookup result while export/import/private-cell validity remains intact
- **THEN** a concrete old invocation yields a different access result or frozen output

#### Scenario: Invalid added catalog

- **WHEN** a new duplicate or invalid component makes the complete new catalog invalid
- **THEN** new execution refuses configuration even when old referenced lookups remain unchanged

#### Scenario: Changed grant operation domain

- **WHEN** the domain of a registry operation with no declaring catalog component changes, while invoked lookups and both catalog-validity checks still agree
- **THEN** actual issue success versus operation-domain refusal differs

#### Scenario: Changed trusted administrator

- **WHEN** the relevant domain administrator changes
- **THEN** actual issue or revoke authorization differs

#### Scenario: Changed initial store

- **WHEN** only the initial capability entries differ before authorized issue
- **THEN** the exact returned fresh ID differs, refuting a ledger-only extension premise


===== INPUT openspec/changes/operational-continuation-congruence/specs/continuation-observation/spec.md ORIGINAL_SHA256 e131e95c149e0ae6ac722f2911f8644d90a9bea0f6d97e6bd62b10c0dfd67ebe RENDERED_SHA256 e131e95c149e0ae6ac722f2911f8644d90a9bea0f6d97e6bd62b10c0dfd67ebe =====
## Purpose

Specify exact observable continuation data and substitution laws for a restricted sequential context grammar.

## ADDED Requirements

### Requirement: Exact cursor observations

Cursor observation SHALL retain the full current typed ledger, complete capability store, ordered event index/action/receipt/output fields, frozen qualified history, absolute next position and complete optional located failure. Only past raw event worlds and proof terms SHALL be omitted. Production comparison SHALL expose local separable ledger, store, events, history, next-position and failure conjuncts, with a local per-event index/action/receipt/output comparison. Existing world/branch equality SHALL be reused only in correctness proofs, not as delegated runtime comparison.

#### Scenario: Current world sensitivity

- **WHEN** two cursors differ only at a current ledger cell
- **THEN** their observations differ

#### Scenario: Complete store sensitivity

- **WHEN** two cursors have equal ledgers but different store entries or tombstones
- **THEN** their observations differ

#### Scenario: Qualified output sensitivity

- **WHEN** otherwise equal cursors differ in frozen history value, unit, producer position or qualified key
- **THEN** their observations differ and history order remains significant

#### Scenario: Receipt sensitivity

- **WHEN** otherwise equal event observations differ in invoked request, evaluated receipt, issue ID or revoke ID
- **THEN** their cursor observations differ

#### Scenario: Located failure sensitivity

- **WHEN** otherwise equal cursors differ in failure reason, position or optional failed action
- **THEN** their observations differ

#### Scenario: Next position sensitivity

- **WHEN** otherwise equal cursors have different absolute next positions
- **THEN** their observations differ

### Requirement: Observation equivalence laws

The production comparison SHALL decide the declared observation equivalence, and that equivalence SHALL be reflexive, symmetric and transitive. Equality SHALL NOT silently include or exclude different fields in separate consumers.

#### Scenario: Equivalence laws

- **WHEN** arbitrary well-typed cursors, including explicitly synthetic/unreachable observer pairs, are compared
- **THEN** the Boolean comparison corresponds exactly to the stated relation and all three equivalence laws hold

#### Scenario: Omitted past diagnostic worlds

- **WHEN** cursors agree on all observed fields but differ in a past raw event world
- **THEN** the selected observer equates the explicitly synthetic pair while retaining the restriction on raw diagnostic inspection and making no claim of two reachable traces differing only there

### Requirement: Restricted contextual substitution

Sequential substitution SHALL hold for one-hole contexts formed only by fixed groups before or after the hole under the same configuration and boundary function. Group equivalence SHALL quantify over every pair of equivalent input cursors, and execution SHALL preserve all required continuation data.

#### Scenario: Output-consuming suffix

- **WHEN** equivalent groups are followed by a fixed continuation consuming an earlier qualified snapshot
- **THEN** the filled contexts remain observationally equivalent with the same exact history and results

#### Scenario: Fixed prefix and suffix

- **WHEN** a one-hole context has fixed nonempty groups before and after the hole
- **THEN** equivalent replacement groups remain equivalent for every equivalent input cursor

#### Scenario: Failure-bearing replacement

- **WHEN** equivalent replacement results already carry the same first failure
- **THEN** the fixed suffix remains inert and the filled contexts preserve that exact refusal

### Requirement: Necessary continuation premises

The evidence SHALL include actual counterexamples to substitution based only on equal current ledger or one particular initial execution. Restricted contexts SHALL NOT add peers, inspect omitted raw worlds, change trusted boundaries or move an atomic commit boundary.

#### Scenario: Missing history premise

- **WHEN** equal-ledger cursors provide different frozen snapshots to the same consumer
- **THEN** the actual continuation results differ

#### Scenario: Missing index premise

- **WHEN** equal-ledger cursors select different index-dependent trusted boundaries
- **THEN** the actual continuation authorization or output differs

#### Scenario: Missing store premise

- **WHEN** equal-ledger cursors have different existing capability entries before the same authorized issue
- **THEN** the actual fresh issued IDs and complete stores differ

#### Scenario: One-entry agreement is insufficient

- **WHEN** two groups share the same initially refusing action but have different suffixes, and a fixed authorized funding prefix enables that action
- **THEN** equality at the original entry does not imply equal filled-context execution, demonstrating the need for universal input-cursor equivalence


===== INPUT openspec/changes/operational-continuation-congruence/specs/metatheory-regression-evidence/spec.md ORIGINAL_SHA256 a41f7567d8bf7b625b3262f4f0dda4adb23f64ca9402e6f249cbf013b3cd1438 RENDERED_SHA256 a41f7567d8bf7b625b3262f4f0dda4adb23f64ca9402e6f249cbf013b3cd1438 =====
## Purpose

Require nonempty operational examples, honest proof and mutation inventories, defensive controls and source-bound independent acceptance.

## ADDED Requirements

### Requirement: Planning and baseline gates

Implementation SHALL begin only after accepted Sprint8 delivery, refreshed frozen source context, independent GPT-6 and native Fable 5.1 planning acceptance on identical plan bytes, and a fresh passing baseline. Author review SHALL NOT count as independent planning review. Native Fable reviews SHALL request `claude-fable-5-1[1m]` with medium effort and record the actual returned model identity; unavailable reviews SHALL remain open. Historical Opus and Fable reports SHALL retain their original identity.

#### Scenario: Provisional dependency context

- **WHEN** Sprint9 is drafted while Sprint8 candidate evidence is still under review
- **THEN** the plan remains planning-only and marks the candidate binding for refresh before planning freeze

#### Scenario: Implementation gate

- **WHEN** the complete Sprint9 plan is ready
- **THEN** separate non-author planning verdicts, accepted dependency delivery and fresh baseline are recorded before source implementation

### Requirement: Independent operational evidence

Nonempty financial and administrative cases SHALL compare actual execution with independently constructed full expected data. Generic simulation comparisons, reference instances, counterexamples, synthetic arbitrary/unreachable observation-pair checks and compiler controls SHALL remain separate evidence classes.

#### Scenario: Independent financial expectations

- **WHEN** nested financial groups exercise world, history and boundary routing
- **THEN** expected balances, stores, receipts, outputs and refusals are written independently of the new executor and comparator

#### Scenario: Nonempty administrative evidence

- **WHEN** cross-group issuance, use, revocation and refusal are tested
- **THEN** the comparisons retain actual fresh IDs, tombstones and complete stores

#### Scenario: Boundary scope negative

- **WHEN** one transaction with a later refusal is compared with separately committed boundaries
- **THEN** the differing retained or rolled-back prefix is recorded as a boundary-change counterexample, not sequential associativity

### Requirement: Fourteen production mutations

Exactly fourteen planned mutations SHALL alter actual new group-execution or observation-comparison runtime code. Each SHALL compile, fail its designated independent comparison and retain declared nonempty positive controls. Configuration-premise counterexamples SHALL be separate actual examples, not fake checker mutations.

#### Scenario: Eight execution routing mutations

- **WHEN** world, store, history, index, first failure, child execution, order or boundary selection is mutated
- **THEN** each actual source mutation is detected by its independent execution oracle with protected siblings true

#### Scenario: Six observation omission mutations

- **WHEN** current world, store, history, failure, receipt or next position comparison is omitted
- **THEN** each actual production comparison mutation is detected by an independently constructed synthetic arbitrary/unreachable changed pair while equal pairs stay true, separately classified from financial execution-routing detection

#### Scenario: Compiler failure receives no detection credit

- **WHEN** a mutation fails compilation, times out or loses expected observations
- **THEN** the attempt is blocked and retained as evidence, never counted among the fourteen semantic detections

### Requirement: Defensive runner controls

The dedicated runner SHALL adapt all sixty-five established actual CLI controls to Metatheory roots and names, preserve valid/violated/blocked classifications, and reject empty, malformed, partial, dirty or drifting evidence. Executable declarations SHALL precede proof boundaries. The complete adaptation SHALL bind driver/spec paths, scoped namespace/root/proof regexes, exact failed/empty/duplicate error strings and all fixture/production-assertion names as well as case names. Runtime audit closures SHALL avoid imported Tests and proof-only fixtures; each runner Lean/Git command SHALL have an explicit 600-second timeout, each harness runner subprocess 1500 seconds, and each completed command/case SHALL record measured wall time. Timeouts SHALL be blocked exit3, not detection. The runner mapping obligation includes a counted keep/rename inventory of every case-insensitive Atomic occurrence in both accepted scripts, supplied in planning review. Every production mutation needle SHALL occur exactly once in its target runtime prefix before replacement. Timeout retention means completed-command logs, prior records, the fresh output directory and outer stderr; the inherited runner supplies no per-command log or record for the timed-out command. No new timeout-capture path is claimed.

#### Scenario: Complete actual CLI controls

- **WHEN** the dedicated defensive suite runs against fresh external repositories
- **THEN** all sixty-five named controls execute real subprocesses with expected classifications and complete command/source/artifact/time records:52 inherited (including one base proof-boundary control),11 new proof-tail controls and2 production forms

#### Scenario: Runtime boundary parser controls

- **WHEN** attributed or comment-prefixed runtime code, macros or initialization appears after the proof boundary
- **THEN** the runner blocks it while preserving the established comment/string/character negative siblings, all 12 proof-tail-related cases and both production audit-output forms with exact `Metatheory runtime comparisons failed: N` false-count text

### Requirement: Imported audits and accepted delivery

Final acceptance SHALL include exact imported theorem and supplemental inventories with complete statements, premises and private-name provenance; all previous regression suites; native Grok/Fable 5.1 result and evidence reviews; and verified branch delivery. Empty checks or missing reviewers SHALL remain open gates.

#### Scenario: Complete proof inventory

- **WHEN** the final source is frozen
- **THEN** every imported theorem and supplemental declaration is discovered mechanically, checked for forbidden axioms and bound to exact source Git bytes

#### Scenario: Prior behavior preservation

- **WHEN** the new namespace is integrated
- **THEN** fresh prior Lean and Python regressions pass and historical source/evidence remains preserved

#### Scenario: Independent final acceptance

- **WHEN** source and financial evidence are ready for delivery
- **THEN** native result/evidence verdicts bind the final candidate, all material blockers are resolved, and archive plus authorized branch push are verified


===== INPUT openspec/changes/operational-continuation-congruence/specs/sequential-group-execution/spec.md ORIGINAL_SHA256 7fa56f3c6f24be86090103d19018637efb5968a3951565b87d35498754ac3d67 RENDERED_SHA256 7fa56f3c6f24be86090103d19018637efb5968a3951565b87d35498754ac3d67 =====
## Purpose

Specify finite recursive sequential groups that preserve actual cursor continuation, administrative effects and exact refusal behavior.

## ADDED Requirements

### Requirement: Recursive ordered execution

A finite sequential group SHALL execute its ordered children recursively, passing the complete returned continuation cursor to the next child. Empty groups SHALL be identity and each action SHALL execute through the existing single-step semantics, including issue and revoke.

#### Scenario: Nested producer and consumer

- **WHEN** a snapshot-producing movement, a prior-output consumer and a third movement occur in nested nonempty groups
- **THEN** the consumer uses the exact frozen qualified snapshot and all three actions have the independently expected worlds, receipts and absolute positions

#### Scenario: Empty group identities

- **WHEN** an empty group appears before or after a nonempty group from any existing cursor
- **THEN** the complete result equals execution of that nonempty group alone

#### Scenario: Administrative cross-group continuation

- **WHEN** one child issues a capability and later children invoke and revoke that issued ID
- **THEN** the complete updated store and exact administrative receipts reach every later child

### Requirement: Refusal and absolute continuation

The first located refusal SHALL retain the successful cursor prefix and make every remaining child inert. Child boundaries SHALL use the actual absolute next position; history, events and capability state SHALL NOT be reset.

#### Scenario: Middle refusal absorbs suffix

- **WHEN** transfer7 succeeds from USD10, transfer6 refuses, and a funded suffix would otherwise succeed
- **THEN** Alice remains3 and Bob7, the exact middle failure is retained and the suffix emits no movement, receipt or snapshot

#### Scenario: Previously failed cursor

- **WHEN** a recursive group starts from an already failed nonempty cursor
- **THEN** the complete cursor is unchanged

#### Scenario: Nonzero boundary position

- **WHEN** an existing cursor starts at a nonzero position and trusted actor or time differs by absolute slot
- **THEN** every action uses its actual continuation position and preserves the resulting exact success or refusal; the M08 sensitivity variant changes only the new leaf boundary argument to a constant position0 function, leaving imported single-step semantics unchanged

### Requirement: Actual flattening correspondence

Recursive group execution SHALL equal the existing flat sequential continuation on the same leaf list for every supplied cursor, without a successful-run premise. This correspondence SHALL include full raw events and their worlds, current world/store, outputs, position and failure.

#### Scenario: Successful recursive simulation

- **WHEN** a nonempty nested group succeeds with cross-child output dependencies
- **THEN** its entire cursor equals the actual flat continuation and independently expected financial fields

#### Scenario: Administrative refusal simulation

- **WHEN** a revoke in one group makes a later use refuse
- **THEN** recursive and flat execution retain the same tombstone, denied invocation, local index and successful prefix

#### Scenario: Arbitrary continuation simulation

- **WHEN** the starting cursor contains existing events, outputs, store entries and a nonzero position
- **THEN** the simulation preserves that entire prefix rather than creating a fresh initial cursor

### Requirement: Sequential associativity scope

The two parenthesizations of three sequential groups SHALL return equal complete cursors, derived from actual recursive execution correspondence. This law SHALL preserve leaf order and the existing sequential boundary.

#### Scenario: Three-group associativity

- **WHEN** three nonempty groups are parenthesized left or right, including a failure-bearing case
- **THEN** both executions return the same complete cursor

#### Scenario: Reordering is a distinct behavior

- **WHEN** shared withdrawals7 and6 compete for USD10 in opposite leaf orders
- **THEN** the differing accepted movement and refusal demonstrate that associativity does not permit swapping leaves


===== INPUT wiki-llm/sprint-9-operational-continuation-congruence.md ORIGINAL_SHA256 8459c1d24af747ce0fd4cb6095a154cb32d66bc16a748735c897146eef1f28c1 RENDERED_SHA256 8459c1d24af747ce0fd4cb6095a154cb32d66bc16a748735c897146eef1f28c1 =====
# Sprint 9: operational continuation congruence

Status: author planning draft. No Metatheory implementation, proof or production
mutation result is claimed here. All35 implementation tasks are unchecked. The
plan currently contains four capabilities, 17 requirements and 55 scenarios; these
counts come from the actual OpenSpec files and are checked by the planning map.
Frozen r1 independent GPT-6/native Opus planning reviews are preserved; native
Opus returned ACCEPT WITH LIMITATIONS with six required changes. This author
revision addresses those changes and needs review of its new candidate bytes.
The author is not its independent GPT-6 reviewer. Implementation remains gated;
native result/evidence reviews and delivery remain later gates.

The Sprint8 dependency is accepted source
`99e2e2c61a1a3c5249026921efdc6cd41ac8f21d`. Source/evidence commit
`2c038094c031723f3ade35d8b3f506ccff5b1d3b` and archive metadata
`9501f0a4f0480b2a42ff197907d548cf0c610773` were pushed and remotely verified on
`semantic-kernel-pivot`; the exact acceptance and delivery records are bound in
`review/semantic-kernel/sprint9/planning/dependency-baseline-binding.json`.
Fresh baseline14 Lean commands and13 Python suites passed at that accepted source.
The Python metadata correction is retained and its final hashes are used.

The inherited control inventory is65:52 earlier controls (including the base
`runtime-definition-after-proof-boundary` case),11 NEW proof-tail controls and2
production-form controls;12 controls concern proof-tail behavior in total, including the accepted CLI-log pointer correction.
All65 executed in the fresh baseline. Their accepted harness source hash is bound,
not inferred from a case count. All35 plan task boxes remain unchecked until the
actual planning gate; baseline/dependency completion is recorded separately.
Revised-candidate independent GPT-6/native Fable 5.1 acceptance and implementation remain pending.

The change is [operational-continuation-congruence](../openspec/changes/operational-continuation-congruence/proposal.md),
with [design](../openspec/changes/operational-continuation-congruence/design.md),
[requirements](../openspec/changes/operational-continuation-congruence/specs/) and
[unchecked tasks](../openspec/changes/operational-continuation-congruence/tasks.md).
It implements only increment M1 of the
[operational metatheory draft](operational-metatheory-planning-draft.md).

## Operational boundary

A new recursive SeqGroup has empty, action and sequential-child nodes. Leaves
call actual Composition.advance. A sequence passes the entire first-child cursor
to the second. Flatten is separately defined and used to prove correspondence to
existing Composition.continueRun; it is not the implementation of the new runner.
The simulation quantifies over arbitrary existing cursors, including events with
raw worlds, frozen outputs, nonzero absolute indices, complete administrative
stores and first refusals. Associativity is derived for ordered sequential groups,
including issue/invoke/revoke and failed suffixes. It does not swap shared actions
or move a transaction boundary.

The observer records all current typed balances and complete store plus exact
ordered event actions/indices/receipts/outputs, frozen qualified history, nextIndex
and located failure. The production comparator exposes separate local conjuncts
for ledger/store/events/history/index/failure and event index/step/receipt/outputs;
existing equality reuse is proof-only. Past raw event worlds and proof terms are
omitted explicitly. Observer-only pairs are labeled synthetic arbitrary/unreachable
cursors and are not financial execution traces.
The context grammar is one hole with fixed sequential groups before or after it,
using the same configuration/boundaries. Group equivalence quantifies over every
pair of equivalent input cursors. This is sufficient for actual continuation
substitution; one-entry equality and ledger-only equality are not sufficient.

## Configuration agreement

Agreement is an explicit proposition, not a new admission or certificate checker.
Both complete catalogs must validate. Every supported invocation's registry value
and full component/interface lookup pair must agree, including None and access
fields. Every issue Grant.operation is also supported even when never invoked.
Trusted administrators agree on all domains because an arbitrary starting cursor
can revoke a capability whose domain is read dynamically from its current store.
Identity types, boundaries, histories, indices and complete starting world/store
are fixed. Identity types and instances are shared theorem binders, not an
agreement field. These sufficient hypotheses deliberately remain visible; the
negative examples establish materiality, not minimality of stronger assumptions.

Prove exact actual single-step equality including invocation refusal and receipt
extraction, issuance and revocation. Lift through supported sequential lists and
recursive groups, then unchanged invocation-only Parallel, Interleaving and Atomic
operators. Include static suffix admission, shared own-history/index behavior and
all Atomic commit/abort/refusal outcomes under the same policy/label/schedule.
No equality of executions or successful results may be a field of agreement.

## Concrete evidence

The main nonempty three-group fixture starts Alice10/Bob0/Carol0, transfers7 to
Bob while exporting Alice3, consumes that frozen3 to transfer to Carol, then
returns1 from Bob: final Alice1/Bob6/Carol3. Every intermediate world, receipt and
snapshot is independently specified. Other fixtures cover transfer7/refused6 with
an inert funded suffix, nonzero initial indices, issue/use/revoke/denied-use,
index-dependent trusted actors/time, and valid unrelated configuration additions.

Counterexamples separately cover changed old registry/access/output, invalid
added catalog, changed grant-only operation domain, changed trusted admin and
same-ledger/different-store fresh issuance. Continuation negatives omit history,
index, store or universal-input equivalence. Shared-order competition and
one-transaction versus separate-boundary rollback limit stronger claims. Registry
changes preserve signature/output-domain validity; grant-only domain-changing
operations have no declaring catalog component; changed access/output declarations
preserve ownership/import/export validity so unrelated failures do not mask the
intended counterexample.

The 14 planned real mutations comprise 8 recursive execution defects (world/store/
history/index reset, failure clearing, skipped/reversed child, constant boundary)
and 6 observation omissions (world/store/history/failure/receipt/nextIndex). The
design binds each to a real production source site, named independent negative
oracle and protected nonempty sibling. Configuration premises receive actual
counterexamples, not invented certificate-checker mutations. Every mutant must
compile; compiler failures are blocked and receive no semantic detection credit.
All65 inherited actual CLI controls must execute with exact classifications.
M08 replaces only the new leaf call boundary argument by `(fun _ ↦ boundaries 0)`.
The complete driver namespace/root/proof-regex/error-text/fixture mapping is fixed
in design.md, including `Metatheory runtime comparisons failed: N`. Audit imports
reuse Atomic.Examples/Parallel.Examples and avoid imported Tests/proof-only fixture
modules; Verify imports proof-lifting modules separately. Runner commands have
explicit 600-second limits and harness runner subprocesses1500-second limits, with
measured command/case/variant wall time. Timeouts are blocked exit3, never detections.

## Files and acceptance

New modules are `lean/DefiKernel/Metatheory/{SequentialGroups,Observation,Contexts,
Configuration,ConfigurationGroups,OperatorLifting,Examples,Tests,Audit,Verify}.lean`.
New dedicated mutation scripts and `mutations/metatheory.json` accompany them;
root `lean/DefiKernel.lean` gains one import. Existing kernel/proof namespaces and toolchains
remain unchanged. Every executable declaration precedes its proof marker.

Planning coverage and author validation live under
`review/semantic-kernel/sprint9/planning/`. The future implementation must preserve
full Lean statements, axiom/private-name provenance, exact source/Git/tool/log
bindings, nonempty runtime checks, 14 actual mutants, 65 controls and every prior
regression. Independent planning approval precedes implementation; native Grok and
Fable 5.1 at medium effort review substantive results and final evidence before accepted OpenSpec
archive and user-authorized branch push with remote verification. No Foreman or
merge to main.

M2 interface/binding theory, new finite participants, parallel tree routing,
causal monitors, active-peer conservative extension, identity/provenance theory
and atomic-boundary regrouping remain separate later increments. This plan does
not close those roadmap obligations by analogy with sequential list algebra.

## Focused runner clarification review

The r2 semantic plan was accepted with limitations by GPT-6 and Opus. Three further Opus requests clarify inherited timeout evidence, exhaustive literal adaptation and exact-once mutation needles. The r3 review supplies the full revised plan and runner scripts with the counted adaptation inventory, while binding unchanged semantic source to its already-reviewed r2 Git objects. No implementation begins before both revised verdicts pass. The inaccurate old spec locator is corrected to the actual explicit `review/semantic-kernel/sprint8/mutation-spec.json` input.

The user restored Fable 5.1 at medium effort for future external reviews. The r3 bundle therefore includes the complete unchanged semantic-source closure for Fable to inspect independently, alongside the runner clarifications. Completed Opus reports remain historical evidence under their actual model identity.


===== INPUT scripts/check_atomic_mutations.py ORIGINAL_SHA256 ab64b7681be152bedc0baf9cc0703fd0cbcd82df79c3fb887be9959a41810007 RENDERED_SHA256 ab64b7681be152bedc0baf9cc0703fd0cbcd82df79c3fb887be9959a41810007 =====
#!/usr/bin/env python3
"""Replay the actual atomic Lean implementation under explicit source mutations.

The specification names an ordered, nonempty list of source modules, mutation
sites, required false observations and protected positive controls. Proof-only
suffixes are excluded from temporary execution copies, never from accepted files.
Exit 0: nonempty control and all sensitivity assertions pass; 1: failed assertion;
3: unavailable evidence, malformed specification or compilation/setup failure.
"""
import argparse
import hashlib
import json
from pathlib import Path
import re
import subprocess
import sys
import time
from datetime import datetime, timezone


CHECK_NAME = r'[a-z][a-z0-9_-]*(?:\.[a-z][a-z0-9_-]*)*'


class Blocked(Exception):
    pass


def require(value, message):
    if not value:
        raise Blocked(message)


def check(value, message):
    if not value:
        raise AssertionError(message)


def sha(raw):
    return hashlib.sha256(raw).hexdigest()


def read(path):
    raw = path.read_bytes()
    require(raw.strip(), f'empty required input: {path}')
    return raw


def parse(raw):
    def pairs(items):
        value = {}
        for key, item in items:
            require(key not in value, f'duplicate JSON key: {key}')
            value[key] = item
        return value
    return json.loads(raw, object_pairs_hook=pairs)


def proof_tail_code(source, module):
    """Mask comments and literals for a conservative, bounded command-token guard.

    This is not Lean parsing or macro expansion. In particular an invocation of
    an arbitrary command macro defined before the marker needs source review.
    Masking preserves newlines and cannot join separate tokens accidentally.
    """
    masked = list(source)
    raw_pattern = re.compile(r'r(#+)?"')
    char_pattern = re.compile(r"'(?:\\(?:x[0-9a-fA-F]{2}|u[0-9a-fA-F]{4}|.)|[^'\\\n])'")
    index = 0
    while index < len(source):
        start = index
        if source.startswith('--', index):
            end = source.find('\n', index)
            index = len(source) if end < 0 else end
        elif source.startswith('/-', index):
            depth = 1
            index += 2
            while index < len(source) and depth:
                if source.startswith('/-', index):
                    depth += 1
                    index += 2
                elif source.startswith('-/', index):
                    depth -= 1
                    index += 2
                else:
                    index += 1
            require(depth == 0, f'{module}: unterminated proof-tail comment')
        else:
            raw = raw_pattern.match(source, index) if (
                index == 0 or not (source[index - 1].isalnum() or source[index - 1] == '_')) else None
            char = char_pattern.match(source, index)
            if raw:
                closing = '"' + (raw.group(1) or '')
                end = source.find(closing, raw.end())
                require(end >= 0, f'{module}: unterminated proof-tail raw string')
                index = end + len(closing)
            elif char:
                index = char.end()
            elif source[index] == '"':
                index += 1
                while index < len(source) and source[index] != '"':
                    index += 2 if source[index] == '\\' else 1
                require(index < len(source), f'{module}: unterminated proof-tail string')
                index += 1
            else:
                index += 1
                continue
        masked[start:index] = ['\n' if c == '\n' else ' ' for c in source[start:index]]
    return ''.join(masked)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--repo', type=Path, required=True)
    parser.add_argument('--spec', type=Path, required=True)
    parser.add_argument('--out', type=Path, required=True)
    parser.add_argument('--timeout-seconds', type=int, default=600,
                        help='Per Lean/Git command timeout (default: 600 seconds)')
    args = parser.parse_args()
    require(args.timeout_seconds > 0, 'timeout must be positive')
    started = datetime.now(timezone.utc).isoformat()
    repo, out = args.repo.resolve(), args.out.resolve()
    require(not out.is_relative_to(repo), 'evidence output must be outside the repository')
    require(not args.out.exists() and not args.out.is_symlink(), 'output already exists')
    spec_raw = read(args.spec)
    spec = parse(spec_raw)
    require(isinstance(spec, dict) and set(spec) ==
            {'schema_version', 'modules', 'mutations', 'positive_checks'},
            'invalid mutation specification fields')
    require(type(spec['schema_version']) is int and spec['schema_version'] == 1,
            'unsupported mutation specification version')
    modules, mutations, positives = spec['modules'], spec['mutations'], spec['positive_checks']
    require(isinstance(modules, list) and modules, 'empty module inventory')
    require(isinstance(mutations, list) and mutations, 'empty mutation inventory')
    require(isinstance(positives, list) and positives, 'empty positive-control inventory')
    require(len(set(modules)) == len(modules), 'duplicate source module')
    require(len(set(positives)) == len(positives), 'duplicate positive control')
    require(all(isinstance(name, str) and re.fullmatch(CHECK_NAME, name)
                for name in positives), 'invalid positive check name')
    require('DefiKernel.Atomic.Audit' in modules, 'missing Atomic audit root')
    names = [m['name'] for m in mutations]
    require(len(set(names)) == len(names), 'duplicate mutation name')
    for m in mutations:
        require(isinstance(m, dict) and set(m) ==
                {'name', 'module', 'needle', 'replacement', 'required_false'},
                'invalid mutation fields')
        require(re.fullmatch(r'[a-z][a-z0-9-]*', m['name']), 'invalid mutation name')
        require(m['name'] not in {'control', 'lean-version', 'lean-path', 'git-head',
                                  'git-root-input-status'}, 'reserved variant name')
        require(m['module'] in modules, 'mutation module outside inventory')
        require(isinstance(m['needle'], str) and m['needle'], 'empty mutation needle')
        require(isinstance(m['replacement'], str) and m['replacement'] != m['needle'],
                'mutation must actually change the source')
        require(isinstance(m['required_false'], list) and m['required_false'],
                'mutation has no required false observations')
        require(all(isinstance(name, str) and re.fullmatch(CHECK_NAME, name)
                    for name in m['required_false']), 'invalid required check name')
        require(len(set(m['required_false'])) == len(m['required_false']),
                'duplicate required check')
    # Discover and inline every local import, including split Atomic modules
    # absent from the mutation-site inventory; never load local cached oleans.
    blobs, ordered, visiting = {}, [], set()
    def capture(module):
        require(re.fullmatch(r'[A-Za-z][A-Za-z0-9]*(?:\.[A-Za-z][A-Za-z0-9]*)*', module),
                f'invalid scoped module: {module}')
        require(module not in visiting, f'cyclic local dependency: {module}')
        if module in ordered:
            return
        visiting.add(module)
        relative = 'lean/' + module.replace('.', '/') + '.lean'
        path = (repo / relative).resolve()
        require(path.is_relative_to(repo), f'source path escape: {relative}')
        raw = read(path)
        blobs[relative] = raw
        for line in raw.decode().splitlines():
            if line.startswith('import '):
                imported = line.removeprefix('import ').strip()
                require(re.fullmatch(r'[A-Za-z][A-Za-z0-9_.]*', imported),
                        f'{module}: unsupported import syntax')
                local_path = repo / 'lean' / (imported.replace('.', '/') + '.lean')
                if imported.startswith('DefiKernel.') or local_path.exists():
                    capture(imported)
        visiting.remove(module)
        ordered.append(module)
    for module in modules:
        require(isinstance(module, str) and re.fullmatch(
            r'DefiKernel\.Atomic(?:\.[A-Za-z][A-Za-z0-9]*)+', module),
            f'invalid scoped module: {module}')
        capture(module)
    for relative in ('lean/lean-toolchain', 'lean/lake-manifest.json', 'lean/lakefile.toml'):
        blobs[relative] = read(repo / relative)
    sources = {name: sha(raw) for name, raw in blobs.items()}
    script_sha256 = sha(read(Path(__file__)))
    imports, prefixes = [], {}
    for module in ordered:
        source = blobs['lean/' + module.replace('.', '/') + '.lean'].decode()
        marker = '\n-- BEGIN PROOFS\n'
        require(source.count(marker) <= 1, f'{module}: duplicate proof boundary')
        if marker in source and module.startswith('DefiKernel.Atomic.'):
            source, suffix = source.split(marker)
            # This bounded projection removes theorem tails only. Silently
            # dropping a late runtime declaration would change the computation.
            tail_code = proof_tail_code(suffix, module)
            # Token matching catches same-line attributes/comments and command
            # declarations. Imported namespaces are deliberately not stripped.
            forbidden = re.search(
                r'\b(?:def|abbrev|opaque|instance|structure|inductive|class|axiom|constant|'
                r'macro|macro_rules|syntax|declare_syntax_cat|elab|elab_rules|'
                r'initialize|builtin_initialize|run_cmd|attribute|notation|infix|infixl|'
                r'infixr|prefix|postfix)\b|#(?:eval|reduce|run)\b', tail_code)
            require(not forbidden,
                    f'{module}: runtime declaration after proof boundary')
            closure = re.search(r'\n(end DefiKernel\.Atomic(?:\.[A-Za-z][A-Za-z0-9]*)*)\s*$', suffix)
            require(closure, f'{module}: proof suffix lacks exact namespace closure')
            namespace = closure.group(1)[4:]
            require(f'namespace {namespace}\n' in source, f'{module}: unmatched namespace')
            source += '\n\n' + closure.group(1) + '\n'
        lines = []
        for line in source.splitlines():
            if line.startswith('import '):
                imported = line.removeprefix('import ').strip()
                require(re.fullmatch(r'[A-Za-z][A-Za-z0-9_.]*', imported),
                        f'{module}: unsupported import syntax')
                if imported not in ordered and line not in imports:
                    require(not imported.startswith('DefiKernel.'),
                            f'{module}: omitted internal dependency {imported}')
                    imports.append(line)
            else:
                lines.append(line)
        prefixes[module] = '\n'.join(lines) + '\n'
    require(imports, 'no external dependency imports captured')
    variants = {'control': dict(prefixes)}
    for m in mutations:
        source = prefixes[m['module']]
        require(source.count(m['needle']) == 1, f'{m["name"]}: mutation did not apply exactly once')
        variants[m['name']] = {**prefixes, m['module']: source.replace(m['needle'], m['replacement'], 1)}
    out.mkdir(parents=True, exist_ok=False)
    records, results = [], {}

    def run(label, command):
        tick = time.monotonic()
        proc = subprocess.run(command, cwd=repo / 'lean', capture_output=True, text=True,
                              timeout=args.timeout_seconds)
        log = proc.stdout + proc.stderr
        (out / (label + '.log')).write_text(log)
        records.append({'label': label, 'command': command, 'cwd': str(repo / 'lean'),
                        'exit': proc.returncode, 'log_sha256': sha(log.encode()),
                        'elapsed_seconds': round(time.monotonic() - tick, 6),
                        'timeout_seconds': args.timeout_seconds})
        (out / 'results.json').write_text(json.dumps({'runs': records, 'results': results}, indent=2) + '\n')
        return proc.returncode, log

    status, version = run('lean-version', ['lake', 'env', 'lean', '--version'])
    require(status == 0, 'Lean tool identity unavailable')
    status, executable = run('lean-path', ['lake', 'env', 'which', 'lean'])
    require(status == 0, 'Lean executable path unavailable')
    executable_sha = sha(read(Path(executable.strip())))
    status, head = run('git-head', ['git', 'rev-parse', 'HEAD'])
    require(status == 0, 'Git revision unavailable')
    status, dirty = run('git-root-input-status', ['git', '-C', str(repo), 'status', '--porcelain',
                                                '--untracked-files=all', '--', *blobs])
    require(status == 0, 'Git source status unavailable')
    git_bindings = {}
    for relative, raw in blobs.items():
        command = ['git', '-C', str(repo), 'rev-parse', f'{head.strip()}:{relative}']
        identity = subprocess.run(command, capture_output=True, timeout=args.timeout_seconds)
        require(identity.returncode == 0, f'input absent from frozen Git revision: {relative}')
        object_id = identity.stdout.decode().strip()
        blob_command = ['git', '-C', str(repo), 'cat-file', 'blob', object_id]
        committed = subprocess.run(blob_command, capture_output=True, timeout=args.timeout_seconds)
        require(committed.returncode == 0, f'Git input object unavailable: {relative}')
        require(committed.stdout == raw, f'input differs from frozen Git revision: {relative}')
        git_bindings[relative] = {'git_object': object_id, 'sha256': sha(committed.stdout),
                                  'identity_command': command, 'blob_command': blob_command,
                                  'identity_exit': identity.returncode, 'blob_exit': committed.returncode}
    manifest = {'sources': sources, 'script_sha256': script_sha256,
                'spec_sha256': sha(spec_raw), 'git_head': head.strip(), 'input_status': dirty,
                'git_input_bindings': git_bindings, 'started_utc': started,
                'timeout_seconds_per_command': args.timeout_seconds,
                'binding_scope': 'Captured Lean/config inputs equal HEAD Git objects; external spec/driver '
                                 'are byte-hashed and checked for drift, with production freeze binding separate.',
                'lean_version': version.strip(), 'lean_executable_sha256': executable_sha,
                'scope': 'Fresh local dependency source closure; Atomic proof tails excluded; unchanged dependency proofs retained. Accepted files unchanged.',
                'proof_tail_guard': 'Conservative declaration/command token guard outside nested comments and '
                                    'ordinary/raw strings and character literals; not arbitrary command-macro expansion.',
                'projection_order': ordered, 'module_roots': modules,
                'audit_root': 'DefiKernel.Atomic.Audit', 'python_version': sys.version}
    (out / 'source-manifest.json').write_text(json.dumps(manifest, indent=2) + '\n')
    (out / 'mutation-spec.json').write_bytes(spec_raw)
    for relative, raw in blobs.items():
        target = out / 'inputs' / relative
        target.parent.mkdir(parents=True, exist_ok=True)
        target.write_bytes(raw)
    def verify_inputs():
        # Clear the prior variant's success flags before any read can fail.
        manifest.update(input_sources_unchanged=False, specification_unchanged=False,
                        runner_unchanged=False, git_head_unchanged=False)
        (out / 'source-manifest.json').write_text(json.dumps(manifest, indent=2) + '\n')
        manifest['sources_after'] = {p: sha(read(repo / p)) for p in blobs}
        manifest['spec_sha256_after'] = sha(read(args.spec))
        manifest['script_sha256_after'] = sha(read(Path(__file__)))
        current_head = subprocess.run(['git', '-C', str(repo), 'rev-parse', 'HEAD'],
                                      capture_output=True, text=True, timeout=args.timeout_seconds)
        manifest['git_head_after'] = current_head.stdout.strip()
        manifest['input_sources_unchanged'] = manifest['sources_after'] == sources
        manifest['specification_unchanged'] = manifest['spec_sha256_after'] == sha(spec_raw)
        manifest['runner_unchanged'] = manifest['script_sha256_after'] == script_sha256
        manifest['git_head_unchanged'] = (current_head.returncode == 0 and
                                          manifest['git_head_after'] == head.strip())
        (out / 'source-manifest.json').write_text(json.dumps(manifest, indent=2) + '\n')
        require(manifest['input_sources_unchanged'], 'input sources changed during replay')
        require(manifest['specification_unchanged'], 'specification changed during replay')
        require(manifest['runner_unchanged'], 'runner changed during replay')
        require(manifest['git_head_unchanged'], 'Git revision changed during replay')

    for label, parts in variants.items():
        source = '\n'.join(imports) + '\n\n' + '\n'.join(parts[m] for m in ordered)
        fixture = out / (label + '.lean')
        fixture.write_text(source)
        code, log = run(label, ['lake', 'env', 'lean', str(fixture)])
        verify_inputs()
        observations = re.findall(rf'^({CHECK_NAME}): (true|false)$', log, re.MULTILINE)
        # Lean's unused-variable diagnostics contain standalone Hint:/Note:
        # continuation lines. These exact diagnostic prefixes are not observations.
        diagnostic_prefixes = ('Hint: The binding can be removed (if unused) or named ',
                               'Note: This linter can be disabled with ')
        candidates = [line for line in log.splitlines()
                      if re.match(r'^[A-Za-z0-9_.-]+:', line)
                      and not line.startswith(diagnostic_prefixes)]
        require(len(candidates) == len(observations), f'{label}: malformed observation')
        checks = dict(observations)
        require(checks and len(checks) == len(observations), f'{label}: empty/duplicate observations')
        require(set(positives) <= checks.keys(), f'{label}: missing positive controls')
        false = sorted(name for name, value in checks.items() if value == 'false')
        errors = [line for line in log.splitlines()
                  if re.search(r': error(?:\([^)]*\))?:', line)]
        if label == 'control':
            expected_error = f'error: Atomic runtime comparisons failed: {len(false)}'
            require(not errors or (false and len(errors) == 1 and errors[0].endswith(expected_error)),
                    'control compilation/execution failed')
            check(code == 0 and not false, 'unchanged control has failing comparisons')
            for mutation in mutations:
                require(set(mutation['required_false']) <= checks.keys(),
                        f'{mutation["name"]}: missing required observation in control')
        else:
            require(checks.keys() == results['control']['checks'].keys(), f'{label}: partial execution')
            check(code != 0 or false, f'{label}: all comparisons still pass under mutation')
            expected_error = f'error: Atomic runtime comparisons failed: {len(false)}'
            require(len(errors) == 1 and errors[0].endswith(expected_error),
                    f'{label}: failure is not solely the expected runtime comparison failure')
            required = next(m['required_false'] for m in mutations if m['name'] == label)
            check(code != 0 and set(required) <= set(false), f'{label}: required mutation not detected')
        check(all(checks[name] == 'true' for name in positives), f'{label}: positive control failed')
        results[label] = {'exit': code, 'fixture_sha256': sha(source.encode()),
                          'checks': checks, 'false_comparisons': false}
        (out / 'results.json').write_text(json.dumps({'runs': records, 'results': results}, indent=2) + '\n')
        print(f'{label}: exit={code}; comparisons={len(checks)}; false={false}', flush=True)
    verify_inputs()
    manifest['finished_utc'] = datetime.now(timezone.utc).isoformat()
    (out / 'source-manifest.json').write_text(json.dumps(manifest, indent=2) + '\n')
    print(f'DISCRIMINATES: {len(mutations)} mutants and one nonempty unchanged control')


if __name__ == '__main__':
    try:
        main()
    except AssertionError as exc:
        print(f'FAIL: {exc}', file=sys.stderr)
        sys.exit(1)
    except Exception as exc:
        print(f'BLOCKED: {type(exc).__name__}: {exc}', file=sys.stderr)
        sys.exit(3)


===== INPUT scripts/test_atomic_mutation_runner.py ORIGINAL_SHA256 dc539d354e1c9c7a3f3ccc7278b3d223fd4c015ba842cd4154930d2108e4e662 RENDERED_SHA256 dc539d354e1c9c7a3f3ccc7278b3d223fd4c015ba842cd4154930d2108e4e662 =====
#!/usr/bin/env python3
"""Exercise the mutation runner's CLI against real temporary Lean computations.

No subprocess is mocked. The temporary repository links installed dependency packages
and has its own isolated git metadata. All fixtures/logs stay outside the
source repository. Exit 0 means every nonempty control has the expected classification;
exit 1 means an observed classification differs; exit 3 means the harness could not run.
"""
import argparse
from datetime import datetime, timezone
import hashlib
import json
from pathlib import Path
import re
import shutil
import subprocess
import sys
import time


INPUT_MODULE = 'DefiKernel.Atomic.RunnerInput'
AUDIT_MODULE = 'DefiKernel.Atomic.Audit'
DEPENDENCY = '''import Mathlib.Data.Nat.Basic
namespace DefiKernel.Interleaving
def runnerDependency : Nat := 4
-- BEGIN PROOFS
theorem runnerDependency_value : runnerDependency = 4 := rfl
end DefiKernel.Interleaving
'''
INPUT = '''import DefiKernel.Interleaving.RunnerDependency

namespace DefiKernel.Atomic

example : DefiKernel.Interleaving.runnerDependency = 4 := DefiKernel.Interleaving.runnerDependency_value

def runnerAllows (n : Nat) : Bool := n ≤ 4
def runnerIncludeSensitivity : Bool := true
-- compiler-control

-- BEGIN PROOFS

theorem runnerAllows_zero : runnerAllows 0 = true := by decide

end DefiKernel.Atomic
'''
AUDIT = '''import DefiKernel.Atomic.RunnerInput

namespace DefiKernel.Atomic

open Lean Elab Command in
run_cmd do
  let checks : List (String × Bool) := CHECKS
  for (name, value) in checks do
    liftIO <| IO.println s!"{name}: {value}"
  let failures := (checks.filter (fun pair => !pair.2)).length
  if failures > 0 then
    throwError "Atomic runtime comparisons failed: {failures}"

end DefiKernel.Atomic
'''
PRODUCTION_AUDIT = '''import DefiKernel.Atomic.RunnerInput
namespace DefiKernel.Atomic.Audit
def main : IO Unit := do
  let checks : List (String × Bool) := CHECKS
  if checks.isEmpty then throw (IO.userError "Atomic runtime comparisons empty")
  if !(checks.map Prod.fst).Nodup then
    throw (IO.userError "Atomic runtime comparison names are duplicated")
  for (name, passed) in checks do IO.println s!"{name}: {passed}"
  let failures := checks.filter (!·.2) |>.map Prod.fst
  if !failures.isEmpty then
    throw (IO.userError s!"Atomic runtime comparisons failed: {failures.length}")
#eval main

-- BEGIN PROOFS

end DefiKernel.Atomic.Audit
'''

CHECKS = '''if runnerIncludeSensitivity then
    [("runner_positive", runnerAllows 0), ("runner_sensitivity", !runnerAllows 5)]
    else [("runner_positive", runnerAllows 0)]'''


def sha(raw):
    return hashlib.sha256(raw).hexdigest()


def require(value, message):
    if not value:
        raise RuntimeError(message)


def mutation(needle='n ≤ 4', replacement='n ≤ 5', required=None):
    return {'name': 'probe', 'module': INPUT_MODULE, 'needle': needle,
            'replacement': replacement,
            'required_false': ['runner_sensitivity'] if required is None else required}


def specification(change=None):
    return {'schema_version': 1, 'modules': [INPUT_MODULE, AUDIT_MODULE],
            'mutations': [mutation() if change is None else change],
            'positive_checks': ['runner_positive']}


def cases():
    """Expected classifications are fixed independently of the runner implementation."""
    return [
        {'name': 'production-eval-discriminating-mutant', 'exit': 0, 'production_audit': True,
         'message': 'DISCRIMINATES: 1 mutants and one nonempty unchanged control'},
        {'name': 'production-eval-required-stays-true', 'exit': 1, 'production_audit': True,
         'spec': specification(mutation(required=['runner_positive'])),
         'message': 'required mutation not detected'},
        {'name': 'live-discriminating-mutant', 'exit': 0,
         'message': 'DISCRIMINATES: 1 mutants and one nonempty unchanged control'},
        {'name': 'dotted-comparisons', 'exit': 0,
         'spec': {**specification(mutation(required=['runner.sensitivity'])),
                  'positive_checks': ['runner.positive']},
         'checks': CHECKS.replace('runner_positive', 'runner.positive').replace(
             'runner_sensitivity', 'runner.sensitivity'),
         'message': 'DISCRIMINATES: 1 mutants and one nonempty unchanged control'},
        {'name': 'hyphenated-dotted-comparisons', 'exit': 0,
         'spec': {**specification(mutation(required=['runner.expected-failure'])),
                  'positive_checks': ['runner.permitted-sibling']},
         'checks': CHECKS.replace('runner_positive', 'runner.permitted-sibling').replace(
             'runner_sensitivity', 'runner.expected-failure'),
         'message': 'DISCRIMINATES: 1 mutants and one nonempty unchanged control'},
        {'name': 'empty-dot-segment-spec', 'exit': 3,
         'spec': specification(mutation(required=['runner..sensitivity'])),
         'message': 'invalid required check name'},
        {'name': 'trailing-dot-spec', 'exit': 3,
         'spec': {**specification(), 'positive_checks': ['runner.']},
         'message': 'invalid positive check name'},
        {'name': 'leading-dot-observation', 'exit': 3,
         'extra_audit': '  liftIO <| IO.println ".runner_bad: true"\n',
         'message': 'malformed observation'},
        {'name': 'empty-dot-segment-observation', 'exit': 3,
         'extra_audit': '  liftIO <| IO.println "runner..bad: true"\n',
         'message': 'malformed observation'},
        {'name': 'unused-variable-warning', 'exit': 0,
         'spec': specification(mutation(replacement='true')),
         'message': 'DISCRIMINATES: 1 mutants and one nonempty unchanged control'},
        {'name': 'uppercase-observation', 'exit': 3,
         'extra_audit': '  liftIO <| IO.println "Runner_bad: true"\n',
         'message': 'malformed observation'},
        {'name': 'unknown-mutant-observation', 'exit': 3,
         'extra_audit': '  if runnerAllows 5 then\n'
                        '    liftIO <| IO.println "runner_unknown: true"\n',
         'message': 'probe: partial execution'},
        {'name': 'all-true-mutant', 'exit': 1, 'spec': specification(mutation(replacement='n ≤ 3')),
         'message': 'all comparisons still pass under mutation'},
        {'name': 'required-observation-stays-true', 'exit': 1,
         'spec': specification(mutation(required=['runner_positive'])),
         'message': 'required mutation not detected'},
        {'name': 'positive-control-flipped', 'exit': 1,
         'spec': specification(mutation(replacement='n == 5')),
         'message': 'positive control failed'},
        {'name': 'compilation-only-failure', 'exit': 3,
         'spec': specification(mutation('-- compiler-control', '#check runnerUndefinedConstant')),
         'message': 'failure is not solely the expected runtime comparison failure'},
        {'name': 'compiler-error-with-runtime-failure', 'exit': 3,
         'spec': specification(mutation('n ≤ 4\ndef runnerIncludeSensitivity : Bool := true',
                                        'n ≤ 5\n#check runnerUndefinedConstant\n'
                                        'def runnerIncludeSensitivity : Bool := true')),
         'message': 'failure is not solely the expected runtime comparison failure'},
        {'name': 'empty-observations', 'exit': 3, 'checks': '[]',
         'message': 'control: empty/duplicate observations'},
        {'name': 'duplicate-observations', 'exit': 3,
         'checks': '[("runner_positive", true), ("runner_positive", true), '
                   '("runner_sensitivity", !runnerAllows 5)]',
         'message': 'control: empty/duplicate observations'},
        {'name': 'missing-positive-observation', 'exit': 3,
         'checks': '[("runner_sensitivity", !runnerAllows 5)]',
         'message': 'control: missing positive controls'},
        {'name': 'missing-required-observation', 'exit': 3,
         'spec': specification(mutation(required=['runner_absent'])),
         'message': 'probe: missing required observation in control'},
        {'name': 'partial-mutant-observations', 'exit': 3,
         'spec': specification(mutation('runnerIncludeSensitivity : Bool := true',
                                        'runnerIncludeSensitivity : Bool := false')),
         'message': 'probe: partial execution'},
        {'name': 'no-op-mutation', 'exit': 3,
         'spec': specification(mutation(replacement='n ≤ 4')),
         'message': 'mutation must actually change the source'},
        {'name': 'missing-mutation-needle', 'exit': 3,
         'spec': specification(mutation('runnerNeedleDoesNotExist', 'false')),
         'message': 'mutation did not apply exactly once'},
        {'name': 'missing-source-setup', 'exit': 3, 'missing_source': True,
         'message': 'FileNotFoundError'},
        {'name': 'missing-manifest-setup', 'exit': 3, 'missing_manifest': True,
         'message': 'FileNotFoundError'},
        {'name': 'existing-output-setup', 'exit': 3, 'existing_output': True,
         'message': 'output already exists'},
        {'name': 'reserved-mutation-name', 'exit': 3,
         'spec': specification({**mutation(), 'name': 'lean-version'}),
         'message': 'reserved variant name'},
        {'name': 'empty-module-inventory', 'exit': 3,
         'spec': {**specification(), 'modules': []}, 'message': 'empty module inventory'},
        {'name': 'empty-positive-inventory', 'exit': 3,
         'spec': {**specification(), 'positive_checks': []}, 'message': 'empty positive-control inventory'},
        {'name': 'duplicate-module-inventory', 'exit': 3,
         'spec': {**specification(), 'modules': [INPUT_MODULE, INPUT_MODULE, AUDIT_MODULE]},
         'message': 'duplicate source module'},
        {'name': 'duplicate-mutation-inventory', 'exit': 3,
         'spec': {**specification(), 'mutations': [mutation(), mutation()]}, 'message': 'duplicate mutation name'},
        {'name': 'duplicate-positive-check', 'exit': 3,
         'spec': {**specification(), 'positive_checks': ['runner_positive', 'runner_positive']},
         'message': 'duplicate positive control'},
        {'name': 'duplicate-required-check', 'exit': 3,
         'spec': specification(mutation(required=['runner_sensitivity', 'runner_sensitivity'])),
         'message': 'duplicate required check'},
        {'name': 'nonunique-mutation-needle', 'exit': 3,
         'spec': specification(mutation('def ', 'private def ')), 'message': 'mutation did not apply exactly once'},
        {'name': 'malformed-observation', 'exit': 3,
         'extra_audit': '  liftIO <| IO.println "runner_bad: truth"\n', 'message': 'malformed observation'},
        {'name': 'malformed-json', 'exit': 3, 'raw_spec': '{', 'message': 'JSONDecodeError'},
        {'name': 'duplicate-json-key', 'exit': 3,
         'raw_spec': '{"schema_version": 1, "schema_version": 1}', 'message': 'duplicate JSON key'},
        {'name': 'output-inside-repository', 'exit': 3, 'inside_output': True,
         'message': 'evidence output must be outside the repository'},
        {'name': 'output-symlink', 'exit': 3, 'symlink_output': True, 'message': 'output already exists'},
        {'name': 'discovered-atomic-dependency', 'exit': 0, 'extra_dependency': True,
         'message': 'DISCRIMINATES: 1 mutants and one nonempty unchanged control'},
        {'name': 'fresh-dependency-source-failure', 'exit': 3, 'changed_dependency': True,
         'message': 'control compilation/execution failed'},
        {'name': 'missing-audit-root', 'exit': 3,
         'spec': {**specification(), 'modules': [INPUT_MODULE]},
         'message': 'missing Atomic audit root'},
        {'name': 'foreign-module-root', 'exit': 3,
         'spec': {**specification(), 'modules': [INPUT_MODULE, AUDIT_MODULE,
                                              'DefiKernel.Composition.RunnerInput']},
         'message': 'invalid scoped module'},
        {'name': 'mutation-module-outside-inventory', 'exit': 3,
         'spec': specification({**mutation(), 'module': 'DefiKernel.Atomic.Absent'}),
         'message': 'mutation module outside inventory'},
        {'name': 'unchanged-control-failed', 'exit': 1,
         'checks': '[("runner_positive", true), ("runner_sensitivity", false)]',
         'message': 'unchanged control has failing comparisons'},
        {'name': 'nonkernel-local-dependency', 'exit': 0, 'nonkernel_dependency': True,
         'message': 'DISCRIMINATES: 1 mutants and one nonempty unchanged control'},
        {'name': 'dirty-source-before-run', 'exit': 3, 'dirty_source': True,
         'message': 'input differs from frozen Git revision'},
        {'name': 'staged-source-before-run', 'exit': 3, 'staged_source': True,
         'message': 'input differs from frozen Git revision'},
        {'name': 'source-drift-during-run', 'exit': 3, 'source_drift': True,
         'message': 'input sources changed during replay'},
        {'name': 'source-drift-during-mutant', 'exit': 3, 'source_drift': True,
         'mutant_only_drift': True, 'message': 'input sources changed during replay'},
        {'name': 'specification-drift-during-run', 'exit': 3, 'spec_drift': True,
         'message': 'specification changed during replay'},
        {'name': 'runtime-definition-after-proof-boundary', 'exit': 3, 'late_runtime': True,
         'message': 'runtime declaration after proof boundary'},
        {'name': 'attributed-runtime-after-proof-boundary', 'exit': 3,
         'late_runtime': '@[inline] def hiddenRuntime : Bool := true',
         'message': 'runtime declaration after proof boundary'},
        {'name': 'comment-prefixed-runtime-after-proof-boundary', 'exit': 3,
         'late_runtime': '/- retained documentation -/ def hiddenRuntime : Bool := true',
         'message': 'runtime declaration after proof boundary'},
        {'name': 'macro-after-proof-boundary', 'exit': 3,
         'late_runtime': 'macro "lateRuntime" : command => `(def hiddenRuntime : Bool := true)',
         'message': 'runtime declaration after proof boundary'},
        {'name': 'macro-rules-after-proof-boundary', 'exit': 3,
         'late_runtime': 'macro_rules | `(lateRuntime) => `(def hiddenRuntime : Bool := true)',
         'message': 'runtime declaration after proof boundary'},
        {'name': 'syntax-after-proof-boundary', 'exit': 3,
         'late_runtime': 'syntax "lateRuntime" : command',
         'message': 'runtime declaration after proof boundary'},
        {'name': 'initialize-after-proof-boundary', 'exit': 3,
         'late_runtime': 'initialize hiddenRuntime : IO.Ref Nat ← IO.mkRef 4',
         'message': 'runtime declaration after proof boundary'},
        {'name': 'proof-comment-keywords-sibling', 'exit': 0,
         'late_runtime': '/- def outer /- macro inner -/ initialize outer -/\n-- syntax class',
         'message': 'DISCRIMINATES: 1 mutants and one nonempty unchanged control'},
        {'name': 'proof-string-keywords-sibling', 'exit': 0,
         'late_runtime': 'theorem runtimeWords : "def macro initialize" = "def macro initialize" := rfl',
         'message': 'DISCRIMINATES: 1 mutants and one nonempty unchanged control'},
        {'name': 'raw-string-before-attributed-runtime', 'exit': 3,
         'late_runtime': 'theorem rawWords : r#"def "macro""# = r#"def "macro""# := rfl\n@[inline] def hiddenRuntime : Bool := true',
         'message': 'runtime declaration after proof boundary'},
        {'name': 'character-before-attributed-runtime', 'exit': 3,
         'late_runtime': 'theorem quoteChar : \'"\' = \'"\' := rfl\n@[inline] def hiddenRuntime : Bool := true',
         'message': 'runtime declaration after proof boundary'},
        {'name': 'proof-raw-string-character-sibling', 'exit': 0,
         'late_runtime': 'theorem rawWords : r#"def "macro""# = r#"def "macro""# := rfl\ntheorem quoteChar : \'"\' = \'"\' := rfl',
         'message': 'DISCRIMINATES: 1 mutants and one nonempty unchanged control'},
        {'name': 'empty-mutation-inventory', 'exit': 3,
         'spec': {**specification(), 'mutations': []}, 'message': 'empty mutation inventory'},
    ]


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--repo', type=Path, required=True)
    parser.add_argument('--runner', type=Path)
    parser.add_argument('--out', type=Path, required=True)
    parser.add_argument('--case', action='append', help='Run only these named controls')
    args = parser.parse_args()
    repo, out = args.repo.resolve(), args.out.resolve()
    runner = (args.runner or repo / 'scripts/check_atomic_mutations.py').resolve()
    require(not out.is_relative_to(repo), 'harness output must be outside source repository')
    require(not args.out.exists() and not args.out.is_symlink(), 'harness output already exists')
    require(runner.is_file(), 'runner source unavailable')
    require((repo / 'lean/.lake/packages').is_dir(), 'installed dependency packages unavailable')
    out.mkdir(parents=True)
    before = sha(runner.read_bytes())
    harness_before = sha(Path(__file__).read_bytes())
    started = datetime.now(timezone.utc).isoformat()
    identity = []

    def identify(label, command):
        proc = subprocess.run(command, cwd=repo / 'lean', text=True, capture_output=True, timeout=60)
        log = proc.stdout + proc.stderr
        (out / (label + '.log')).write_text(log)
        identity.append({'label': label, 'command': command, 'cwd': str(repo / 'lean'),
                         'exit': proc.returncode, 'log_sha256': sha(log.encode())})
        require(proc.returncode == 0, f'{label} unavailable: {log}')
        return proc.stdout.strip()

    lean_version = identify('lean-version', ['lake', 'env', 'lean', '--version'])
    lean_path = Path(identify('lean-path', ['lake', 'env', 'which', 'lean']))
    git_head = identify('git-head', ['git', 'rev-parse', 'HEAD'])
    fake = out / 'fixture-repo'
    lean = fake / 'lean'
    typed = lean / 'DefiKernel/Atomic'
    typed.mkdir(parents=True)
    dependency = lean / 'DefiKernel/Interleaving/RunnerDependency.lean'
    dependency.parent.mkdir(parents=True)
    dependency.write_text(DEPENDENCY)
    # Independent metadata prevents even optional index refreshes in the source repo.
    for command in [
        ['git', 'init', '--quiet', str(fake)],
        ['git', '-C', str(fake), '-c', 'user.name=DeFiFormal fixture',
         '-c', 'user.email=fixture@invalid', 'commit', '--allow-empty', '--quiet',
         '-m', 'Initialize isolated mutation-runner fixture'],
    ]:
        proc = subprocess.run(command, text=True, capture_output=True, timeout=60)
        require(proc.returncode == 0, f'isolated fixture git setup failed: {proc.stderr}')
    (lean / '.lake').mkdir()
    # Reuse dependency packages, never the source project's .lake/build directory.
    (lean / '.lake/packages').symlink_to(repo / 'lean/.lake/packages', target_is_directory=True)
    for name in ('lean-toolchain', 'lake-manifest.json', 'lakefile.toml'):
        shutil.copyfile(repo / 'lean' / name, lean / name)
    manifest = (lean / 'lake-manifest.json').read_bytes()
    records = []
    selected = [case for case in cases() if not args.case or case['name'] in args.case]
    require(selected and (not args.case or set(args.case) <= {c['name'] for c in selected}),
            'unknown or empty control selection')
    for case in selected:
        dependency.write_text(DEPENDENCY)
        (lean / 'lake-manifest.json').write_bytes(manifest)
        setup_records = []
        (typed / 'RunnerInput.lean').write_text(INPUT)
        if case.get('nonkernel_dependency'):
            external = lean / 'SharedFixture/RunnerDependency.lean'
            external.parent.mkdir(parents=True, exist_ok=True)
            external.write_text(DEPENDENCY.replace('DefiKernel.Interleaving', 'SharedFixture'))
            (typed / 'RunnerInput.lean').write_text(INPUT.replace(
                'DefiKernel.Interleaving', 'SharedFixture'))
        if case.get('extra_dependency'):
            extra = typed / 'SplitComputation.lean'
            extra.write_text('import DefiKernel.Interleaving.RunnerDependency\n'
                             'namespace DefiKernel.Atomic\n'
                             'def splitLimit : Nat := 4\n'
                             '-- BEGIN PROOFS\n'
                             'theorem splitLimit_value : splitLimit = 4 := rfl\n'
                             'end DefiKernel.Atomic\n')
            (typed / 'RunnerInput.lean').write_text(INPUT.replace(
                'import DefiKernel.Interleaving.RunnerDependency',
                'import DefiKernel.Atomic.SplitComputation').replace(
                    'n ≤ 4', 'n ≤ 4 + (splitLimit - 4)'))
        if case.get('changed_dependency'):
            # Compile the old source, then change only the .lean file. A fresh
            # source projection must see 5 and fail the importing = 4 example.
            olean = lean / '.lake/build/lib/lean/DefiKernel/Interleaving/RunnerDependency.olean'
            olean.parent.mkdir(parents=True, exist_ok=True)
            setup_command = ['lake', 'env', 'lean', '-o', str(olean), str(dependency)]
            setup = subprocess.run(setup_command, cwd=lean, text=True, capture_output=True, timeout=240)
            setup_log = setup.stdout + setup.stderr
            (out / 'stale-dependency-setup.log').write_text(setup_log)
            require(setup.returncode == 0 and olean.is_file(), 'stale dependency control setup failed')
            setup_records.append({'command': setup_command, 'cwd': str(lean),
                                  'exit': setup.returncode, 'log_sha256': sha(setup_log.encode()),
                                  'source_sha256': sha(dependency.read_bytes()),
                                  'olean_sha256': sha(olean.read_bytes())})
            dependency.write_text(DEPENDENCY.replace(':= 4', ':= 5').replace('= 4', '= 5'))
        audit_template = PRODUCTION_AUDIT if case.get('production_audit') else AUDIT
        (typed / 'Audit.lean').write_text(audit_template.replace('CHECKS', case.get('checks', CHECKS)).replace(
            '  let failures :=', case.get('extra_audit', '') + '  let failures :='))
        (lean / 'lake-manifest.json').write_bytes(manifest)
        if case.get('late_runtime'):
            source = typed / 'RunnerInput.lean'
            source.write_text(source.read_text().replace('-- BEGIN PROOFS',
                              '-- BEGIN PROOFS\n' + (case['late_runtime'] if isinstance(case['late_runtime'], str)
                              else 'def hiddenRuntime : Bool := true')))
        if case.get('missing_source'):
            (typed / 'RunnerInput.lean').unlink()
        if case.get('missing_manifest'):
            (lean / 'lake-manifest.json').unlink()
        spec = case.get('spec', specification())
        spec_path = out / (case['name'] + '-spec.json')
        spec_path.write_text(case.get('raw_spec', json.dumps(spec, indent=2) + '\n'))
        result_path = out / 'runs' / case['name']
        if case.get('inside_output'):
            result_path = fake / 'forbidden-output'
        if case.get('symlink_output'):
            result_path.parent.mkdir(parents=True, exist_ok=True)
            result_path.symlink_to(out / 'nonexistent-output', target_is_directory=True)
        if case.get('existing_output'):
            result_path.mkdir(parents=True)
        command = [sys.executable, str(runner), '--repo', str(fake), '--spec', str(spec_path),
                   '--out', str(result_path)]
        if case.get('source_drift') or case.get('spec_drift'):
            drift_path = typed / 'RunnerInput.lean' if case.get('source_drift') else spec_path
            audit = typed / 'Audit.lean'
            drift_statement = 'liftIO <| IO.FS.writeFile ' + json.dumps(str(drift_path)) + \
                ' "-- drifted during actual Lean audit\\n"\n'
            if case.get('mutant_only_drift'):
                drift_statement = 'if runnerAllows 5 then\n    ' + drift_statement
            audit.write_text(audit.read_text().replace('  let checks :',
                '  ' + drift_statement + '  let checks :'))
        for setup_command in [
            ['git', '-C', str(fake), 'add', '-A', '--', 'lean', ':!lean/.lake'],
            ['git', '-C', str(fake), '-c', 'user.name=DeFiFormal fixture',
             '-c', 'user.email=fixture@invalid', 'commit', '--quiet', '--allow-empty',
             '-m', 'Freeze ' + case['name']],
        ]:
            setup = subprocess.run(setup_command, text=True, capture_output=True, timeout=60)
            require(setup.returncode == 0, f'fixture freeze failed: {setup.stderr}')
            setup_records.append({'command': setup_command, 'exit': setup.returncode})
        if case.get('dirty_source') or case.get('staged_source'):
            source = typed / 'RunnerInput.lean'
            source.write_text(source.read_text().replace('-- compiler-control', '-- uncommitted input drift'))
            if case.get('staged_source'):
                setup = subprocess.run(['git', '-C', str(fake), 'add', str(source)],
                                       text=True, capture_output=True, timeout=60)
                require(setup.returncode == 0, 'fixture stage failed')
        tick = time.monotonic()
        proc = subprocess.run(command, cwd=repo, text=True, capture_output=True, timeout=1500)
        elapsed = time.monotonic() - tick
        log = proc.stdout + proc.stderr
        log_path = out / (case['name'] + '.log')
        log_path.write_text(log)
        matched = proc.returncode == case['exit'] and case['message'] in log
        runtime = {}
        results_file = result_path / 'results.json'
        if results_file.exists():
            runtime = json.loads(results_file.read_text())
        # Accepted discrimination additionally requires exact real Lean observations.
        if case['name'] in ('production-eval-discriminating-mutant', 'live-discriminating-mutant', 'dotted-comparisons', 'hyphenated-dotted-comparisons', 'discovered-atomic-dependency', 'unused-variable-warning', 'nonkernel-local-dependency', 'proof-comment-keywords-sibling', 'proof-string-keywords-sibling', 'proof-raw-string-character-sibling'):
            measured = runtime.get('results', {})
            separator = '.' if case['name'] == 'dotted-comparisons' else '_'
            expected_positive = 'runner' + separator + 'positive'
            expected_sensitivity = 'runner' + separator + 'sensitivity'
            if case['name'] == 'hyphenated-dotted-comparisons':
                expected_positive, expected_sensitivity = 'runner.permitted-sibling', 'runner.expected-failure'
            matched = matched and measured.get('control', {}).get('checks') == {
                expected_positive: 'true', expected_sensitivity: 'true'}
            matched = matched and measured.get('probe', {}).get('checks') == {
                expected_positive: 'true', expected_sensitivity: 'false'}
        if case.get('production_audit'):
            # Assertion failures intentionally do not publish accepted result entries.
            # Check actual Lean output for both production-form paths.
            for label, expected in [('control', 'true'), ('probe', 'false')]:
                lean_log_path = result_path / (label + '.log')
                actual_log = lean_log_path.read_text() if lean_log_path.exists() else ''
                matched = matched and re.findall(
                    r'^(runner_positive|runner_sensitivity): (true|false)$',
                    actual_log, re.MULTILINE) == [
                        ('runner_positive', 'true'), ('runner_sensitivity', expected)]
                if label == 'probe':
                    matched = matched and actual_log.count(
                        'error: Atomic runtime comparisons failed: 1') == 1
        if case['name'] == 'unused-variable-warning':
            warning_log = result_path / 'probe.log'
            warning = warning_log.read_text() if warning_log.exists() else ''
            matched = matched and 'warning: Variable name `n` is not explicitly referenced.' in warning
            matched = matched and 'Hint: The binding can be removed' in warning
            matched = matched and 'Note: This linter can be disabled with ' in warning
        source_manifest = result_path / 'source-manifest.json'
        if case.get('extra_dependency'):
            captured = json.loads(source_manifest.read_text()) if source_manifest.exists() else {}
            matched = matched and 'DefiKernel.Atomic.SplitComputation' in captured.get('projection_order', [])
            matched = matched and captured.get('sources', {}).get(
                'lean/DefiKernel/Atomic/SplitComputation.lean') == sha(extra.read_bytes())
            matched = matched and captured.get('input_sources_unchanged') is True
        if case.get('mutant_only_drift'):
            captured = json.loads(source_manifest.read_text()) if source_manifest.exists() else {}
            matched = matched and captured.get('input_sources_unchanged') is False
            matched = matched and runtime.get('results', {}).get('control', {}).get('exit') == 0
        if case.get('nonkernel_dependency'):
            captured = json.loads(source_manifest.read_text()) if source_manifest.exists() else {}
            matched = matched and 'SharedFixture.RunnerDependency' in captured.get('projection_order', [])
            matched = matched and captured.get('sources', {}).get(
                'lean/SharedFixture/RunnerDependency.lean') == sha(external.read_bytes())
        observations = {}
        for variant in ('control', 'probe'):
            variant_log = result_path / (variant + '.log')
            if variant_log.exists():
                raw = variant_log.read_text()
                observations[variant] = {
                    'lines': re.findall(r'^([a-z][a-z0-9_-]*(?:\.[a-z][a-z0-9_-]*)*): (true|false)$', raw, re.MULTILINE),
                    'errors': [line for line in raw.splitlines() if re.search(r': error(?:\([^)]*\))?:', line)],
                    'log_sha256': sha(raw.encode())}
        record = {'name': case['name'], 'command': command, 'cwd': str(repo),
                  'expected_exit': case['exit'], 'actual_exit': proc.returncode,
                  'expected_message': case['message'], 'passed': matched,
                  'elapsed_seconds': round(elapsed, 6), 'log': str(log_path),
                  'log_sha256': sha(log.encode()), 'cli_output': log,
                  'spec_sha256': sha(spec_path.read_bytes()), 'setup_records': setup_records,
                  'lean_observations': observations, 'runner_records': runtime.get('runs', [])}
        records.append(record)
        print(f'{case["name"]}: expected={case["exit"]}; actual={proc.returncode}; '
              f'{"PASS" if matched else "FAIL"}', flush=True)
        (out / 'cases.json').write_text(json.dumps(records, indent=2) + '\n')
    require(records, 'zero controls executed')
    require(before == sha(runner.read_bytes()), 'runner changed during controls; rerun final bytes')
    require(harness_before == sha(Path(__file__).read_bytes()), 'harness changed during controls')
    summary = {'schema_version': 1, 'kind': 'executed-cli-runner-controls',
               'started_utc': started, 'finished_utc': datetime.now(timezone.utc).isoformat(),
               'source_repo': str(repo), 'git_head': git_head,
               'runner_source': str(runner), 'runner_sha256': before,
               'harness_source': str(Path(__file__).resolve()),
               'harness_sha256': harness_before,
               'lean_version': lean_version, 'lean_executable_sha256': sha(lean_path.read_bytes()),
               'python_version': sys.version, 'tool_identity_commands': identity,
               'fixture_scope': 'Synthetic development Lean computations; actual CLI and installed '
                                'Lean/mathlib. No subprocess mocks; no production theorem claim.',
               'fixture_dependency_sha256': sha(DEPENDENCY.encode()),
               'fixture_input_sha256': sha(INPUT.encode()),
               'fixture_audit_template_sha256': sha(AUDIT.encode()),
               'total': len(records), 'passed': sum(r['passed'] for r in records),
               'cases': records}
    (out / 'summary.json').write_text(json.dumps(summary, indent=2) + '\n')
    print(f'CONTROLS: {summary["passed"]}/{summary["total"]} passed', flush=True)
    return 0 if all(r['passed'] for r in records) else 1


if __name__ == '__main__':
    try:
        sys.exit(main())
    except Exception as exc:
        print(f'BLOCKED: {type(exc).__name__}: {exc}', file=sys.stderr)
        sys.exit(3)


===== INPUT lean/DefiKernel/Composition/Sequence.lean ORIGINAL_SHA256 32bcdbbce182bf9d494dab76a8a114f9e238f92564ef86e7cab2cd123bc0b729 RENDERED_SHA256 32bcdbbce182bf9d494dab76a8a114f9e238f92564ef86e7cab2cd123bc0b729 =====
import DefiKernel.Composition.Execution

/-! Finite ordered execution. A refusal commits no new event, preserves the successful prefix,
and makes every continuation inert. Trusted boundary positions are absolute. -/
namespace DefiKernel.Composition
open Typed

structure Event (Party Asset Domain : Type) where
  index : Nat
  step : Step Party Asset Domain
  before : World Party Asset Domain
  result : StepResult Party Asset Domain

structure LocatedFailure (Party Asset Domain : Type) where
  index : Nat
  step : Option (Step Party Asset Domain)
  reason : Failure

structure Cursor (Party Asset Domain : Type) where
  world : World Party Asset Domain
  events : List (Event Party Asset Domain)
  outputs : List (OutputObservation Asset)
  nextIndex : Nat
  failure : Option (LocatedFailure Party Asset Domain)

variable {P A D : Type} [DecidableEq P] [DecidableEq A] [DecidableEq D]
variable [Fintype P] [Fintype A] [Fintype D]

def startCursor (cfg : Config P A D) (world : World P A D) : Cursor P A D :=
  ⟨world, [], [], 0, if validateCatalog cfg.registry cfg.catalog then none
    else some ⟨0, none, .configuration⟩⟩

def advance (cfg : Config P A D) (boundaries : Nat → Boundary P A D)
    (cursor : Cursor P A D) (step : Step P A D) : Cursor P A D :=
  match cursor.failure with
  | some _ => cursor
  | none =>
    match executeStep cfg (boundaries cursor.nextIndex) cursor.nextIndex cursor.outputs
        step cursor.world with
    | .error reason => { cursor with failure := some ⟨cursor.nextIndex, some step, reason⟩ }
    | .ok result =>
      ⟨result.world, cursor.events ++ [⟨cursor.nextIndex, step, cursor.world, result⟩],
        cursor.outputs ++ result.outputs, cursor.nextIndex + 1, none⟩

def continueRun (cfg : Config P A D) (boundaries : Nat → Boundary P A D)
    (cursor : Cursor P A D) (steps : List (Step P A D)) : Cursor P A D :=
  steps.foldl (advance cfg boundaries) cursor

def run (cfg : Config P A D) (boundaries : Nat → Boundary P A D)
    (world : World P A D) (steps : List (Step P A D)) : Cursor P A D :=
  continueRun cfg boundaries (startCursor cfg world) steps

-- BEGIN PROOFS

/-- The trace relates actual step evidence at each preceding world and output history. -/
inductive TraceSound (cfg : Config P A D) (boundaries : Nat → Boundary P A D)
    (initial : World P A D) :
    List (Event P A D) → World P A D → List (OutputObservation A) → Nat → Prop
  | nil : TraceSound cfg boundaries initial [] initial [] 0
  | snoc {events : List (Event P A D)} {pre : World P A D}
      {history : List (OutputObservation A)} {index : Nat}
      (previous : TraceSound cfg boundaries initial events pre history index)
      (step : Step P A D) (result : StepResult P A D)
      (accepted : StepSound cfg (boundaries index) index history step pre result) :
      TraceSound cfg boundaries initial (events ++ [⟨index, step, pre, result⟩])
        result.world (history ++ result.outputs) (index + 1)

def RefusalSound (cfg : Config P A D) (boundaries : Nat → Boundary P A D)
    (cursor : Cursor P A D) : Prop :=
  ∀ failure, cursor.failure = some failure → failure.index = cursor.nextIndex ∧
    match failure.step with
    | none => failure.reason = .configuration ∧ validateCatalog cfg.registry cfg.catalog = false
    | some step => executeStep cfg (boundaries cursor.nextIndex) cursor.nextIndex
        cursor.outputs step cursor.world = .error failure.reason

theorem continueRun_nil (cfg : Config P A D) (boundaries : Nat → Boundary P A D)
    (cursor : Cursor P A D) : continueRun cfg boundaries cursor [] = cursor := rfl

theorem continueRun_append (cfg : Config P A D) (boundaries : Nat → Boundary P A D)
    (cursor : Cursor P A D) (firstSteps suffix : List (Step P A D)) :
    continueRun cfg boundaries cursor (firstSteps ++ suffix) =
      continueRun cfg boundaries (continueRun cfg boundaries cursor firstSteps) suffix := by
  exact List.foldl_append

theorem continueRun_failed (cfg : Config P A D) (boundaries : Nat → Boundary P A D)
    (cursor : Cursor P A D) (failure : LocatedFailure P A D)
    (failed : cursor.failure = some failure) (steps : List (Step P A D)) :
    continueRun cfg boundaries cursor steps = cursor := by
  induction steps with
  | nil => rfl
  | cons step steps ih =>
    simpa [continueRun, List.foldl_cons, advance, failed] using ih

/-- Recorded invocations/admin steps are an ordered prefix of the submitted list. -/
theorem continueRun_order (cfg : Config P A D) (boundaries : Nat → Boundary P A D)
    (cursor : Cursor P A D) (steps : List (Step P A D)) :
    ∃ accepted remaining, steps = accepted ++ remaining ∧
      (continueRun cfg boundaries cursor steps).events.map Event.step =
        cursor.events.map Event.step ++ accepted := by
  induction steps generalizing cursor with
  | nil => exact ⟨[], [], rfl, by simp [continueRun]⟩
  | cons step steps ih =>
    cases hf : cursor.failure with
    | some failure =>
      exact ⟨[], step :: steps, rfl, by rw [continueRun_failed _ _ _ _ hf]; simp⟩
    | none =>
      cases he : executeStep cfg (boundaries cursor.nextIndex) cursor.nextIndex cursor.outputs
          step cursor.world with
      | error reason =>
        have ha : (advance cfg boundaries cursor step).failure =
            some ⟨cursor.nextIndex, some step, reason⟩ := by simp [advance, hf, he]
        refine ⟨[], step :: steps, rfl, ?_⟩
        change (continueRun cfg boundaries (advance cfg boundaries cursor step) steps).events.map
          Event.step = cursor.events.map Event.step ++ []
        rw [continueRun_failed _ _ _ _ ha]
        simp [advance, hf, he]
      | ok result =>
        obtain ⟨accepted, remaining, hs, hout⟩ := ih (advance cfg boundaries cursor step)
        refine ⟨step :: accepted, remaining, by simp [hs], ?_⟩
        change (continueRun cfg boundaries (advance cfg boundaries cursor step) steps).events.map
          Event.step = cursor.events.map Event.step ++ step :: accepted
        rw [hout]
        simp [advance, hf, he, List.map_append, List.append_assoc]

theorem run_order (cfg : Config P A D) (boundaries : Nat → Boundary P A D)
    (initial : World P A D) (steps : List (Step P A D)) :
    ∃ accepted remaining, steps = accepted ++ remaining ∧
      (run cfg boundaries initial steps).events.map Event.step = accepted := by
  simpa [run, startCursor] using continueRun_order cfg boundaries (startCursor cfg initial) steps

theorem advance_trace_sound (cfg : Config P A D) (boundaries : Nat → Boundary P A D)
    (initial : World P A D) (cursor : Cursor P A D) (step : Step P A D)
    (h : TraceSound cfg boundaries initial cursor.events cursor.world
      cursor.outputs cursor.nextIndex) :
    TraceSound cfg boundaries initial (advance cfg boundaries cursor step).events
      (advance cfg boundaries cursor step).world (advance cfg boundaries cursor step).outputs
      (advance cfg boundaries cursor step).nextIndex := by
  cases hf : cursor.failure with
  | some failure => simpa [advance, hf] using h
  | none =>
    cases he : executeStep cfg (boundaries cursor.nextIndex) cursor.nextIndex cursor.outputs
        step cursor.world with
    | error reason => simpa [advance, hf, he] using h
    | ok result =>
      simpa [advance, hf, he] using h.snoc step result (executeStep_sound _ _ _ _ _ _ _ he)

theorem continueRun_trace_sound (cfg : Config P A D) (boundaries : Nat → Boundary P A D)
    (initial : World P A D) (cursor : Cursor P A D) (steps : List (Step P A D))
    (h : TraceSound cfg boundaries initial cursor.events cursor.world
      cursor.outputs cursor.nextIndex) :
    TraceSound cfg boundaries initial (continueRun cfg boundaries cursor steps).events
      (continueRun cfg boundaries cursor steps).world
      (continueRun cfg boundaries cursor steps).outputs
      (continueRun cfg boundaries cursor steps).nextIndex := by
  induction steps generalizing cursor with
  | nil => exact h
  | cons step steps ih =>
    exact ih (advance cfg boundaries cursor step)
      (advance_trace_sound cfg boundaries initial cursor step h)

theorem run_trace_sound (cfg : Config P A D) (boundaries : Nat → Boundary P A D)
    (initial : World P A D) (steps : List (Step P A D)) :
    TraceSound cfg boundaries initial (run cfg boundaries initial steps).events
      (run cfg boundaries initial steps).world (run cfg boundaries initial steps).outputs
      (run cfg boundaries initial steps).nextIndex := by
  apply continueRun_trace_sound
  exact .nil

theorem advance_refusal_sound (cfg : Config P A D) (boundaries : Nat → Boundary P A D)
    (cursor : Cursor P A D) (step : Step P A D) (h : RefusalSound cfg boundaries cursor) :
    RefusalSound cfg boundaries (advance cfg boundaries cursor step) := by
  cases hf : cursor.failure with
  | some failure => simpa [advance, hf] using h
  | none =>
    cases he : executeStep cfg (boundaries cursor.nextIndex) cursor.nextIndex cursor.outputs
        step cursor.world with
    | error reason =>
      intro failure hh
      simp only [advance, hf, he, Option.some.injEq] at hh
      subst failure
      simp [advance, hf, he]
    | ok result =>
      intro failure hh
      simp [advance, hf, he] at hh

theorem continueRun_refusal_sound (cfg : Config P A D) (boundaries : Nat → Boundary P A D)
    (cursor : Cursor P A D) (steps : List (Step P A D)) (h : RefusalSound cfg boundaries cursor) :
    RefusalSound cfg boundaries (continueRun cfg boundaries cursor steps) := by
  induction steps generalizing cursor with
  | nil => exact h
  | cons step steps ih =>
    exact ih (advance cfg boundaries cursor step)
      (advance_refusal_sound cfg boundaries cursor step h)

theorem run_refusal_sound (cfg : Config P A D) (boundaries : Nat → Boundary P A D)
    (initial : World P A D) (steps : List (Step P A D)) :
    RefusalSound cfg boundaries (run cfg boundaries initial steps) := by
  apply continueRun_refusal_sound
  intro failure h
  simp only [startCursor] at h ⊢
  split at h
  · contradiction
  · simp only [Option.some.injEq] at h
    subst failure
    rename_i hv
    exact ⟨rfl, rfl, by simpa using hv⟩

end DefiKernel.Composition


===== INPUT lean/DefiKernel/Composition/Execution.lean ORIGINAL_SHA256 34ac2f2185434d2fc8931b10f3688d909cc984e4e24e16e26c2d115b6fe13602 RENDERED_SHA256 34ac2f2185434d2fc8931b10f3688d909cc984e4e24e16e26c2d115b6fe13602 =====
import DefiKernel.Composition.Interfaces
import DefiKernel.Composition.Contracts

/-! Single-step adaptation of registered execution. Receipts are re-evaluated against the
same pre-state, and are returned only after both execution and extraction succeed. -/
namespace DefiKernel.Composition
open Typed

structure Boundary (Party Asset Domain : Type) where
  ctx : InvocationContext Party Domain
  env : Environment Asset Domain
  now : Nat

structure Config (Party Asset Domain : Type) where
  registry : Registry Party Asset Domain
  domainAdmin : Domain → Party
  catalog : Catalog Party Asset Domain

structure Invocation (Party Asset Domain : Type) where
  component : ComponentId
  operation : OperationId
  parties : List Party
  inputs : List (InputSource Asset)
  capabilityIds : List CapabilityId
  claimedActor : Option Party := none

inductive Step (Party Asset Domain : Type) where
  | invoke (invocation : Invocation Party Asset Domain)
  | issue (grant : Grant Party Asset Domain)
  | revoke (id : CapabilityId)

inductive Failure where
  | configuration
  | interface (reason : InterfaceFailure)
  | kernel (reason : Typed.Refusal)
  | authority (reason : AuthorityFailure)
  | internalReceipt
  deriving DecidableEq, Repr

inductive Receipt (Party Asset Domain : Type) where
  | invoked (request : Request Party Asset Domain) (evaluated : Evaluated Party Asset Domain)
  | issued (id : CapabilityId)
  | revoked (id : CapabilityId)

structure StepResult (Party Asset Domain : Type) where
  world : World Party Asset Domain
  receipt : Receipt Party Asset Domain
  outputs : List (OutputObservation Asset)

variable {P A D : Type} [DecidableEq P] [DecidableEq A] [DecidableEq D]
variable [Fintype P] [Fintype A] [Fintype D]

def Config.authority (cfg : Config P A D) := registryAuthorityConfig cfg.registry cfg.domainAdmin

def Receipt.supply (receipt : Receipt P A D) (d : D) (a : A) : ℚ :=
  match receipt with
  | .invoked _ e => e.supply d a
  | _ => 0

def Receipt.writes (receipt : Receipt P A D) : List (Cell P A D) :=
  match receipt with
  | .invoked _ e => e.writes
  | _ => []

def prepareInvocation (cfg : Config P A D) (boundary : Boundary P A D) (index : Nat)
    (history : List (OutputObservation A)) (inv : Invocation P A D) :
    Except Failure (OperationInterface P A D × Request P A D) := do
  let (component, iface) ← match lookupOperation cfg.catalog inv.component inv.operation with
    | none => .error (.interface .unknownOperation)
    | some pair => .ok pair
  let arguments ← (resolveInputs index history iface inv.inputs).mapError Failure.interface
  let template ← match cfg.registry inv.operation with
    | none => .error (.kernel .unknownOperation)
    | some template => .ok template
  let _ ← (checkAccess component template boundary.ctx inv.parties).mapError Failure.interface
  return (iface, ⟨inv.operation, inv.parties, arguments, inv.capabilityIds, inv.claimedActor⟩)

def extractReceipt (cfg : Config P A D) (boundary : Boundary P A D)
    (request : Request P A D) (pre : World P A D) : Except Failure (Evaluated P A D) := do
  let template ← match cfg.registry request.operation with
    | none => .error .internalReceipt
    | some template => .ok template
  let args ← (Args.check template.signature request.arguments).mapError (fun _ ↦ .internalReceipt)
  (template.evaluate ⟨pre.state, boundary.env, boundary.ctx.principal,
    request.parties, args, boundary.now⟩).mapError (fun _ ↦ .internalReceipt)

def executeStep (cfg : Config P A D) (boundary : Boundary P A D) (index : Nat)
    (history : List (OutputObservation A)) (step : Step P A D) (pre : World P A D) :
    Except Failure (StepResult P A D) := do
  if !validateCatalog cfg.registry cfg.catalog then throw .configuration
  match step with
  | .invoke inv =>
    let (iface, request) ← prepareInvocation cfg boundary index history inv
    let post ← (Typed.execute cfg.registry pre.capabilities boundary.ctx boundary.env boundary.now
      request pre.state).mapError Failure.kernel
    let e ← extractReceipt cfg boundary request pre
    return ⟨post, .invoked request e, snapshots index inv.component iface post.state⟩
  | .issue grant =>
    let (id, store) ← (issueCapability cfg.authority boundary.ctx pre.capabilities grant)
      |>.mapError Failure.authority
    return ⟨⟨pre.state, store⟩, .issued id, []⟩
  | .revoke id =>
    let store ← (revokeCapability cfg.authority boundary.ctx pre.capabilities id)
      |>.mapError Failure.authority
    return ⟨⟨pre.state, store⟩, .revoked id, []⟩

-- BEGIN PROOFS

omit [DecidableEq P] [DecidableEq D] [Fintype P] [Fintype A] [Fintype D] in
/-- The emitted write footprint is exactly the template's resolved declared footprint. -/
theorem evaluated_writes (template : Template P A D)
    (context : EvalContext P A D template.signature) (e : Evaluated P A D)
    (h : template.evaluate context = .ok e) :
    resolveRefs context.caller context.parties template.writes = .ok e.writes := by
  unfold Template.evaluate at h
  simp only [bind, Except.bind, pure, Except.pure] at h
  split at h
  · contradiction
  split at h
  · contradiction
  split at h
  · contradiction
  split at h
  · contradiction
  split at h
  · contradiction
  split at h
  · contradiction
  have hp := Except.ok.inj h
  rw [← hp]
  assumption

omit [Fintype P] [Fintype A] [Fintype D] in
/-- The component and access check are selected from the trusted catalog and registry. -/
theorem prepareInvocation_access (cfg : Config P A D) (boundary : Boundary P A D)
    (index : Nat) (history : List (OutputObservation A)) (inv : Invocation P A D)
    (iface : OperationInterface P A D) (request : Request P A D)
    (h : prepareInvocation cfg boundary index history inv = .ok (iface, request)) :
    ∃ component template, lookupOperation cfg.catalog inv.component inv.operation =
      some (component, iface) ∧ cfg.registry request.operation = some template ∧
      checkAccess component template boundary.ctx request.parties = .ok PUnit.unit := by
  cases hl : lookupOperation cfg.catalog inv.component inv.operation with
  | none => simp [prepareInvocation, hl, bind, Except.bind] at h
  | some pair =>
    rcases pair with ⟨component, selected⟩
    cases ha : resolveInputs index history selected inv.inputs with
    | error reason => simp [prepareInvocation, hl, ha, bind, Except.bind, Except.mapError] at h
    | ok arguments =>
      cases ht : cfg.registry inv.operation with
      | none => simp [prepareInvocation, hl, ha, ht, bind, Except.bind, Except.mapError] at h
      | some template =>
        cases hc : checkAccess component template boundary.ctx inv.parties with
        | error reason =>
          simp [prepareInvocation, hl, ha, ht, hc, bind, Except.bind, Except.mapError] at h
        | ok token =>
          cases token
          simp only [prepareInvocation, hl, ha, ht, hc, bind, Except.bind, Except.mapError,
            pure, Except.pure, Except.ok.injEq, Prod.mk.injEq] at h
          obtain ⟨rfl, rfl⟩ := h
          exact ⟨component, template, rfl, ht, hc⟩

theorem extractReceipt_total (cfg : Config P A D) (boundary : Boundary P A D)
    (request : Request P A D) (pre post : World P A D)
    (h : Typed.execute cfg.registry pre.capabilities boundary.ctx boundary.env boundary.now
      request pre.state = .ok post) :
    ∃ e, extractReceipt cfg boundary request pre = .ok e ∧
      applyEvaluated pre.capabilities boundary.ctx request pre.state e = .ok post := by
  obtain ⟨t, ht, args, ha, e, he, happly⟩ := execute_evaluated _ _ _ _ _ _ _ _ h
  exact ⟨e, by simp [extractReceipt, ht, ha, he, Except.mapError, bind, Except.bind], happly⟩

theorem extractReceipt_correspondence (cfg : Config P A D) (boundary : Boundary P A D)
    (request : Request P A D) (pre post : World P A D) (e : Evaluated P A D)
    (h : Typed.execute cfg.registry pre.capabilities boundary.ctx boundary.env boundary.now
      request pre.state = .ok post) (he : extractReceipt cfg boundary request pre = .ok e) :
    applyEvaluated pre.capabilities boundary.ctx request pre.state e = .ok post := by
  obtain ⟨e', he', happly⟩ := extractReceipt_total cfg boundary request pre post h
  rw [he] at he'
  cases he'
  exact happly

inductive StepSound (cfg : Config P A D) (boundary : Boundary P A D) (index : Nat)
    (history : List (OutputObservation A)) : Step P A D → World P A D → StepResult P A D → Prop
  | invoke (inv : Invocation P A D) (pre post : World P A D)
      (iface : OperationInterface P A D) (request : Request P A D) (e : Evaluated P A D)
      (prepared : prepareInvocation cfg boundary index history inv = .ok (iface, request))
      (executed : Typed.execute cfg.registry pre.capabilities boundary.ctx boundary.env boundary.now
        request pre.state = .ok post)
      (extracted : extractReceipt cfg boundary request pre = .ok e)
      (applied : applyEvaluated pre.capabilities boundary.ctx request pre.state e = .ok post) :
      StepSound cfg boundary index history (.invoke inv) pre
        ⟨post, .invoked request e, snapshots index inv.component iface post.state⟩
  | issue (grant : Grant P A D) (pre : World P A D) (id : CapabilityId)
      (store : CapabilityStore P A D)
      (issued : issueCapability cfg.authority boundary.ctx pre.capabilities grant =
        .ok (id, store)) :
      StepSound cfg boundary index history (.issue grant) pre ⟨⟨pre.state, store⟩, .issued id, []⟩
  | revoke (id : CapabilityId) (pre : World P A D) (store : CapabilityStore P A D)
      (revoked : revokeCapability cfg.authority boundary.ctx pre.capabilities id = .ok store) :
      StepSound cfg boundary index history (.revoke id) pre ⟨⟨pre.state, store⟩, .revoked id, []⟩

theorem executeStep_sound (cfg : Config P A D) (boundary : Boundary P A D) (index : Nat)
    (history : List (OutputObservation A)) (step : Step P A D) (pre : World P A D)
    (result : StepResult P A D) (h : executeStep cfg boundary index history step pre = .ok result) :
    StepSound cfg boundary index history step pre result := by
  cases hv : validateCatalog cfg.registry cfg.catalog with
  | false => cases step <;> simp [executeStep, hv, throw, throwThe, bind, Except.bind] at h
  | true =>
    cases step with
    | invoke inv =>
      simp only [executeStep, hv, Bool.not_true, Bool.false_eq_true, ↓reduceIte,
        bind, Except.bind, pure, Except.pure] at h
      cases hp : prepareInvocation cfg boundary index history inv with
      | error err => simp [hp] at h
      | ok pair =>
        rcases pair with ⟨iface, request⟩
        simp only [hp] at h
        cases hx : Typed.execute cfg.registry pre.capabilities boundary.ctx boundary.env
            boundary.now
            request pre.state with
        | error err => simp [hx, Except.mapError] at h
        | ok post =>
          simp only [hx, Except.mapError] at h
          cases he : extractReceipt cfg boundary request pre with
          | error err => simp [he] at h
          | ok e =>
            simp only [he, Except.ok.injEq] at h
            subst result
            exact .invoke inv pre post iface request e hp hx he
              (extractReceipt_correspondence cfg boundary request pre post e hx he)
    | issue grant =>
      simp only [executeStep, hv, Bool.not_true, Bool.false_eq_true, ↓reduceIte,
        bind, Except.bind, pure, Except.pure] at h
      cases hi : issueCapability cfg.authority boundary.ctx pre.capabilities grant with
      | error err => simp [hi, Except.mapError] at h
      | ok pair =>
        rcases pair with ⟨id, store⟩
        simp only [hi, Except.mapError, Except.ok.injEq] at h
        subst result
        exact .issue grant pre id store hi
    | revoke id =>
      simp only [executeStep, hv, Bool.not_true, Bool.false_eq_true, ↓reduceIte,
        bind, Except.bind, pure, Except.pure] at h
      cases hr : revokeCapability cfg.authority boundary.ctx pre.capabilities id with
      | error err => simp [hr, Except.mapError] at h
      | ok store =>
        simp only [hr, Except.mapError, Except.ok.injEq] at h
        subst result
        exact .revoke id pre store hr

theorem StepSound.accounting {cfg : Config P A D} {boundary : Boundary P A D} {index : Nat}
    {history : List (OutputObservation A)} {step : Step P A D} {pre : World P A D}
    {result : StepResult P A D} (h : StepSound cfg boundary index history step pre result)
    (d : D) (a : A) :
    total result.world.state d a = total pre.state d a + result.receipt.supply d a := by
  cases h with
  | invoke inv pre post iface request e hp hx he ha =>
    exact applyEvaluated_accounting _ _ _ _ _ _ ha d a
  | issue => simp [Receipt.supply]
  | revoke => simp [Receipt.supply]

theorem StepSound.locality {cfg : Config P A D} {boundary : Boundary P A D} {index : Nat}
    {history : List (OutputObservation A)} {step : Step P A D} {pre : World P A D}
    {result : StepResult P A D} (h : StepSound cfg boundary index history step pre result)
    (c : Cell P A D) (hc : c ∉ result.receipt.writes) :
    result.world.state.balance c = pre.state.balance c := by
  cases h with
  | invoke inv pre post iface request e hp hx he ha =>
    exact applyEvaluated_locality _ _ _ _ _ _ ha c hc
  | issue => rfl
  | revoke => rfl

/-- Every declared receipt write is allowed by the selected component interface. -/
theorem StepSound.component_writes {cfg : Config P A D} {boundary : Boundary P A D}
    {index : Nat} {history : List (OutputObservation A)} {inv : Invocation P A D}
    {pre : World P A D} {result : StepResult P A D}
    (h : StepSound cfg boundary index history (.invoke inv) pre result) :
    ∃ component iface, lookupOperation cfg.catalog inv.component inv.operation =
      some (component, iface) ∧ ∀ cell ∈ result.receipt.writes, component.canWrite cell = true := by
  cases h with
  | invoke inv pre post iface request e hp hx he ha =>
    obtain ⟨component, template, hl, ht, hc⟩ := prepareInvocation_access _ _ _ _ _ _ _ hp
    obtain ⟨selected, hs, args, hargs, actual, evaluated, applied⟩ :=
      execute_evaluated _ _ _ _ _ _ _ _ hx
    rw [ht] at hs
    cases hs
    have extracted : extractReceipt cfg boundary request pre = .ok actual := by
      simp [extractReceipt, ht, hargs, evaluated, bind, Except.bind, Except.mapError]
    rw [he] at extracted
    cases extracted
    have writes := evaluated_writes _ _ _ evaluated
    have allowed := checkAccess_declaredWrites component template boundary.ctx
      request.parties e.writes hc writes
    exact ⟨component, iface, hl, by simpa [Receipt.writes] using List.all_eq_true.mp allowed⟩

theorem StepSound.component_locality {cfg : Config P A D} {boundary : Boundary P A D}
    {index : Nat} {history : List (OutputObservation A)} {inv : Invocation P A D}
    {pre : World P A D} {result : StepResult P A D}
    (h : StepSound cfg boundary index history (.invoke inv) pre result) :
    ∃ component iface, lookupOperation cfg.catalog inv.component inv.operation =
      some (component, iface) ∧ ∀ cell, component.canWrite cell = false →
        result.world.state.balance cell = pre.state.balance cell := by
  obtain ⟨component, iface, selected, writes⟩ := h.component_writes
  refine ⟨component, iface, selected, ?_⟩
  intro cell denied
  apply h.locality cell
  intro member
  have allowed := writes cell member
  rw [denied] at allowed
  contradiction

theorem StepSound.invoke_preserves_capabilities {cfg : Config P A D}
    {boundary : Boundary P A D} {index : Nat} {history : List (OutputObservation A)}
    {inv : Invocation P A D} {pre : World P A D} {result : StepResult P A D}
    (h : StepSound cfg boundary index history (.invoke inv) pre result) :
    result.world.capabilities = pre.capabilities := by
  cases h with
  | invoke inv pre post iface request e hp hx he ha =>
    exact execute_preserves_capabilities _ _ _ _ _ _ _ _ hx

theorem StepSound.issue_preserves_ledger {cfg : Config P A D}
    {boundary : Boundary P A D} {index : Nat} {history : List (OutputObservation A)}
    {grant : Grant P A D} {pre : World P A D} {result : StepResult P A D}
    (h : StepSound cfg boundary index history (.issue grant) pre result) :
    result.world.state = pre.state := by cases h; rfl

theorem StepSound.revoke_preserves_ledger {cfg : Config P A D}
    {boundary : Boundary P A D} {index : Nat} {history : List (OutputObservation A)}
    {id : CapabilityId} {pre : World P A D} {result : StepResult P A D}
    (h : StepSound cfg boundary index history (.revoke id) pre result) :
    result.world.state = pre.state := by cases h; rfl

def ReceiptAuthorized (pre : World P A D) (boundary : Boundary P A D)
    (receipt : Receipt P A D) : Prop :=
  match receipt with
  | .invoked request e =>
    hasAuthority pre.capabilities request.capabilityIds boundary.ctx
      request.operation .invoke = true ∧
    (∀ c, e.effect c < 0 → hasAuthority pre.capabilities request.capabilityIds boundary.ctx
      request.operation (.debit c) = true) ∧
    (∀ d a, e.supply d a ≠ 0 → hasAuthority pre.capabilities request.capabilityIds boundary.ctx
      request.operation (.changeSupply d a) = true)
  | _ => True

theorem StepSound.issue_admin {cfg : Config P A D} {boundary : Boundary P A D} {index : Nat}
    {history : List (OutputObservation A)} {grant : Grant P A D} {pre : World P A D}
    {result : StepResult P A D}
    (h : StepSound cfg boundary index history (.issue grant) pre result) :
    boundary.ctx.domain = grant.domain ∧
      boundary.ctx.principal = cfg.domainAdmin grant.domain := by
  cases h with
  | issue grant pre id store hi => exact issueCapability_admin _ _ _ _ _ _ hi

theorem StepSound.revoke_admin {cfg : Config P A D} {boundary : Boundary P A D} {index : Nat}
    {history : List (OutputObservation A)} {id : CapabilityId} {pre : World P A D}
    {result : StepResult P A D} (h : StepSound cfg boundary index history (.revoke id) pre result) :
    ∃ cap, pre.capabilities.lookup id = some cap ∧ boundary.ctx.domain = cap.domain ∧
      boundary.ctx.principal = cfg.domainAdmin cap.domain := by
  cases h with
  | revoke id pre store hr => exact revokeCapability_admin _ _ _ _ _ hr

theorem StepSound.authorized {cfg : Config P A D} {boundary : Boundary P A D} {index : Nat}
    {history : List (OutputObservation A)} {step : Step P A D} {pre : World P A D}
    {result : StepResult P A D} (h : StepSound cfg boundary index history step pre result) :
    ReceiptAuthorized pre boundary result.receipt := by
  cases h with
  | invoke inv pre post iface request e hp hx he ha =>
    obtain ⟨_, _, _, _, _, _, _, hi, _⟩ := (execute_ok_iff ..).mp hx
    obtain ⟨hv, _, _⟩ := (applyEvaluated_ok_iff ..).mp ha
    exact ⟨hi, of_decide_eq_true hv.2.2.2.2.1, of_decide_eq_true hv.2.2.2.2.2.1⟩
  | issue => trivial
  | revoke => trivial

theorem StepSound.domain {cfg : Config P A D} {boundary : Boundary P A D} {index : Nat}
    {history : List (OutputObservation A)} {inv : Invocation P A D} {pre : World P A D}
    {result : StepResult P A D} (h : StepSound cfg boundary index history (.invoke inv) pre result)
    (c : Cell P A D) (hc : result.world.state.balance c ≠ pre.state.balance c) :
    c.1 = boundary.ctx.domain := by
  cases h with
  | invoke inv pre post iface request e hp hx he ha =>
    obtain ⟨_, _, _, _, _, _, _, _, _, hdom⟩ := execute_reads_and_domain _ _ _ _ _ _ _ _ hx
    exact hdom c hc

theorem executeStep_configuration (cfg : Config P A D) (boundary : Boundary P A D) (index : Nat)
    (history : List (OutputObservation A)) (step : Step P A D) (pre : World P A D)
    (h : validateCatalog cfg.registry cfg.catalog = false) :
    executeStep cfg boundary index history step pre = .error .configuration := by
  cases step <;> simp [executeStep, h, throw, throwThe, bind, Except.bind] <;> rfl

theorem executeStep_delegated_refusal (cfg : Config P A D) (boundary : Boundary P A D)
    (index : Nat) (history : List (OutputObservation A)) (inv : Invocation P A D)
    (pre : World P A D) (iface : OperationInterface P A D) (request : Request P A D)
    (reason : Typed.Refusal) (hv : validateCatalog cfg.registry cfg.catalog = true)
    (hp : prepareInvocation cfg boundary index history inv = .ok (iface, request))
    (hx : Typed.execute cfg.registry pre.capabilities boundary.ctx boundary.env boundary.now
      request pre.state = .error reason) :
    executeStep cfg boundary index history (.invoke inv) pre = .error (.kernel reason) := by
  simp [executeStep, hv, hp, hx, Except.mapError, bind, Except.bind]

theorem executeStep_delegated_success (cfg : Config P A D) (boundary : Boundary P A D)
    (index : Nat) (history : List (OutputObservation A)) (inv : Invocation P A D)
    (pre post : World P A D) (iface : OperationInterface P A D) (request : Request P A D)
    (hv : validateCatalog cfg.registry cfg.catalog = true)
    (hp : prepareInvocation cfg boundary index history inv = .ok (iface, request))
    (hx : Typed.execute cfg.registry pre.capabilities boundary.ctx boundary.env boundary.now
      request pre.state = .ok post) :
    ∃ e, extractReceipt cfg boundary request pre = .ok e ∧
      executeStep cfg boundary index history (.invoke inv) pre =
        .ok ⟨post, .invoked request e, snapshots index inv.component iface post.state⟩ := by
  obtain ⟨e, he, _⟩ := extractReceipt_total cfg boundary request pre post hx
  exact ⟨e, he, by
    simp [executeStep, hv, hp, hx, he, Except.mapError, bind, Except.bind, pure, Except.pure]⟩

end DefiKernel.Composition


===== INPUT lean/DefiKernel/Parallel/Observation.lean ORIGINAL_SHA256 38018fbcfb37c08181fbce37b75050077c3dc19d8bee6c0975b7898447ccb84f RENDERED_SHA256 38018fbcfb37c08181fbce37b75050077c3dc19d8bee6c0975b7898447ccb84f =====
import DefiKernel.Composition.Sequence

/-! Branch observations retain every request, receipt, output, and refusal field.
Raw event worlds belong to execution evidence and are deliberately not equated across orders. -/
namespace DefiKernel.Parallel
open Typed Composition

-- These computational equality instances do not alter the existing execution definitions.
deriving instance DecidableEq for Composition.InputSource
deriving instance DecidableEq for Composition.Invocation
deriving instance DecidableEq for Composition.Step
deriving instance DecidableEq for Typed.Request
deriving instance DecidableEq for Typed.Evaluated
deriving instance DecidableEq for Composition.Receipt
deriving instance DecidableEq for Composition.OutputObservation
deriving instance DecidableEq for Composition.LocatedFailure

structure EventObservation (P A D : Type) where
  index : Nat
  step : Step P A D
  receipt : Receipt P A D
  outputs : List (OutputObservation A)
  deriving DecidableEq

structure BranchObservation (P A D : Type) where
  events : List (EventObservation P A D)
  outputs : List (OutputObservation A)
  nextIndex : Nat
  failure : Option (LocatedFailure P A D)
  deriving DecidableEq

def observeEvent {P A D : Type} (event : Event P A D) : EventObservation P A D :=
  ⟨event.index, event.step, event.result.receipt, event.result.outputs⟩

def observeBranch {P A D : Type} (cursor : Cursor P A D) : BranchObservation P A D :=
  ⟨cursor.events.map observeEvent, cursor.outputs, cursor.nextIndex, cursor.failure⟩

-- BEGIN PROOFS

/-- Equality of canonical branch observations includes the exact failure location and step. -/
theorem observeBranch_failure {P A D : Type} {left right : Cursor P A D}
    (h : observeBranch left = observeBranch right) : left.failure = right.failure :=
  congrArg BranchObservation.failure h

/-- Histories are compared as ordered, typed snapshots, not as an unqualified value multiset. -/
theorem observeBranch_outputs {P A D : Type} {left right : Cursor P A D}
    (h : observeBranch left = observeBranch right) : left.outputs = right.outputs :=
  congrArg BranchObservation.outputs h

end DefiKernel.Parallel


===== INPUT review/semantic-kernel/sprint9/planning/r3-resolution.md ORIGINAL_SHA256 66d8f1c2c0eafecab26f12bf5d1df70e76f312897a6104c03c6d475142529d62 RENDERED_SHA256 66d8f1c2c0eafecab26f12bf5d1df70e76f312897a6104c03c6d475142529d62 =====
# Focused closure of the r2 runner clarifications

The r2 candidate47cd83136ab69b0975594a77c519f6611f6fb555 was independently reviewed against the complete semantic source by GPT-6 and native Opus. Both returned ACCEPT WITH LIMITATIONS. Opus found no semantic blocker but requested three runner clarifications; implementation has remained closed pending their resolution and these focused same-candidate reviews.

1. We choose the inherited timeout behavior, option (a). An outer captured `BLOCKED: TimeoutExpired` stderr identifies the command and limit; retain the fresh output directory, already completed command logs and previous results records. The timed-out command has no per-command log or results entry, and its partial stdout is unavailable. No new timeout handler or control is introduced, and no completed evidence is claimed for that command. Measured completed commands and outer suite timing remain separately recorded.
2. The table is a summary. The complete literal inventory enumerates every case-insensitive Atomic occurrence in both exact accepted scripts, with file/line/column/source and explicit keep/rename decisions and counts. This includes case-name verification tuples, exact error assertions, audit_root/scope descriptions and paths. The inventory and its reproducible source are included in the common bundle, alongside both complete accepted scripts. The old explicit --spec input is corrected to `review/semantic-kernel/sprint8/mutation-spec.json`; the intended new location remains `mutations/metatheory.json`.
3. Task7.2 requires every mutation needle to occur exactly once in its target runtime prefix. M01–M07 may use the same unique seq-branch text in separate variants. M08 uses a distinct leaf-call form, with its constructor text if needed. Zero/duplicate matches are blocked. No imported kernel source is edited to manufacture a mutation site.

The normative semantic obligations and M1 scope are unchanged. Following the latest user instruction, the new external reviewer is native Fable 5.1 at medium effort. The bundle contains the complete unchanged semantic-source closure so Fable can inspect it independently, as well as the entire revised plan, all four specifications and task/scenario mapping, exact relevant interpreter/observer and runner source, the adaptation inventory and both prior substantive reports. All prior r2 Lean and runner inputs are mechanically bound byte-for-byte to both Git candidates and the current workspace. This retains the prior full semantic review; it does not claim either reviewer re-executed baseline commands or inherited the prior Opus verdict as its own.

This note is author adjudication preparation. Independent nonauthor GPT-6 and native Fable 5.1 at medium effort must return substantive passing verdicts on the same r3 candidate and bundle before any Metatheory code is created.


===== INPUT review/semantic-kernel/sprint9/planning/runner-literal-adaptation-map.json ORIGINAL_SHA256 79c65243c4b5c230c8dd0db1fa9f9716aae29854bd294081fcd3f86828aff6d3 RENDERED_SHA256 79c65243c4b5c230c8dd0db1fa9f9716aae29854bd294081fcd3f86828aff6d3 =====
{
  "schema_version": 1,
  "status": "AUTHOR_PLANNING_INVENTORY_ONLY",
  "scope": "Exhaustive case-insensitive literal Atomic substrings in both accepted predecessor scripts. No runtime implementation, test execution, or planning acceptance.",
  "accepted_predecessor_revision": "99e2e2c61a1a3c5249026921efdc6cd41ac8f21d",
  "planning_revision": "47cd83136ab69b0975594a77c519f6611f6fb555",
  "generator": {
    "path": "review/semantic-kernel/sprint9/planning/build-runner-literal-map.py",
    "sha256": "0571b0110741ba6ab586c2b840383658df0f68ab6170334b0a01282db5d5218a"
  },
  "reproduce_command": "python3 review/semantic-kernel/sprint9/planning/build-runner-literal-map.py",
  "position_convention": "One-based line/Unicode and UTF-8 byte columns; zero-based offsets. Source-line hashes exclude newline. Each substring match gets a separate record, including two matches on driver line 139.",
  "replacement_policy": {
    "Atomic": "Metatheory",
    "atomic": "metatheory"
  },
  "keep_decisions": [],
  "keep_rationale": "No literal in these two scripts identifies historical evidence that the new driver must retain; all identify the old namespace, protocol, fixture, path, case, or description.",
  "inputs": [
    {
      "path": "scripts/check_atomic_mutations.py",
      "sha256": "ab64b7681be152bedc0baf9cc0703fd0cbcd82df79c3fb887be9959a41810007",
      "bytes": 20659,
      "current_bytes_equal_both_revisions": true,
      "revisions": {
        "99e2e2c61a1a3c5249026921efdc6cd41ac8f21d": {
          "git_blob": "0f402f18b53d7bf7466951a326be2df5bad1e7ed",
          "sha256": "ab64b7681be152bedc0baf9cc0703fd0cbcd82df79c3fb887be9959a41810007",
          "bytes": 20659
        },
        "47cd83136ab69b0975594a77c519f6611f6fb555": {
          "git_blob": "0f402f18b53d7bf7466951a326be2df5bad1e7ed",
          "sha256": "ab64b7681be152bedc0baf9cc0703fd0cbcd82df79c3fb887be9959a41810007",
          "bytes": 20659
        }
      }
    },
    {
      "path": "scripts/test_atomic_mutation_runner.py",
      "sha256": "dc539d354e1c9c7a3f3ccc7278b3d223fd4c015ba842cd4154930d2108e4e662",
      "bytes": 32667,
      "current_bytes_equal_both_revisions": true,
      "revisions": {
        "99e2e2c61a1a3c5249026921efdc6cd41ac8f21d": {
          "git_blob": "1a67e7bd21699fc62ee06b4006e850e4955079c3",
          "sha256": "dc539d354e1c9c7a3f3ccc7278b3d223fd4c015ba842cd4154930d2108e4e662",
          "bytes": 32667
        },
        "47cd83136ab69b0975594a77c519f6611f6fb555": {
          "git_blob": "1a67e7bd21699fc62ee06b4006e850e4955079c3",
          "sha256": "dc539d354e1c9c7a3f3ccc7278b3d223fd4c015ba842cd4154930d2108e4e662",
          "bytes": 32667
        }
      }
    }
  ],
  "adaptations": [
    {
      "source": "scripts/check_atomic_mutations.py",
      "planned_destination": "scripts/check_metatheory_mutations.py",
      "planned_text_sha256": "d08707060c875b6834beaa5cc17e780f97f39b755962ed3a26ca176a94e4314a",
      "planned_text_python_ast_parse": "PASS",
      "remaining_case_insensitive_atomic_occurrences": 0,
      "adapted_script_written_or_executed": false
    },
    {
      "source": "scripts/test_atomic_mutation_runner.py",
      "planned_destination": "scripts/test_metatheory_mutation_runner.py",
      "planned_text_sha256": "19d234039a5d37f2eacd2dc328d17ddd66f57879833a24ff27de9d686bcf1e26",
      "planned_text_python_ast_parse": "PASS",
      "remaining_case_insensitive_atomic_occurrences": 0,
      "adapted_script_written_or_executed": false
    }
  ],
  "historical_spec": {
    "path": "review/semantic-kernel/sprint8/mutation-spec.json",
    "sha256": "91b1c2acddcb3542bb377a878177118125735d40d3845b59b0f6f55051a1a4fc",
    "bytes": 9879,
    "current_bytes_equal_both_revisions": true,
    "revisions": {
      "99e2e2c61a1a3c5249026921efdc6cd41ac8f21d": {
        "git_blob": "b43f23d607e7aa2d9968adf55dd92e492e4dd85e",
        "sha256": "91b1c2acddcb3542bb377a878177118125735d40d3845b59b0f6f55051a1a4fc",
        "bytes": 9879
      },
      "47cd83136ab69b0975594a77c519f6611f6fb555": {
        "git_blob": "b43f23d607e7aa2d9968adf55dd92e492e4dd85e",
        "sha256": "91b1c2acddcb3542bb377a878177118125735d40d3845b59b0f6f55051a1a4fc",
        "bytes": 9879
      }
    },
    "schema_version": 1,
    "mutation_count": 18,
    "modules": [
      "DefiKernel.Atomic.Policy",
      "DefiKernel.Atomic.Execution",
      "DefiKernel.Atomic.Observation",
      "DefiKernel.Atomic.Examples",
      "DefiKernel.Atomic.Tests",
      "DefiKernel.Atomic.Audit"
    ],
    "decision": "keep historical file and bytes unchanged; use as schema predecessor only",
    "planned_new_spec_path": "mutations/metatheory.json",
    "new_spec_requires_fourteen_actual_Metatheory_edits": true
  },
  "counts": {
    "total": 37,
    "rename": 37,
    "keep": 0,
    "by_file": {
      "scripts/check_atomic_mutations.py": 11,
      "scripts/test_atomic_mutation_runner.py": 26
    },
    "by_literal": {
      "atomic": 4,
      "Atomic": 33
    }
  },
  "required_coverage": {
    "lowercase_case_declaration_and_verification_tuple": {
      "source_literal": "discovered-atomic-dependency",
      "occurrence_ids": [
        "L026",
        "L034"
      ],
      "expected_occurrences": 2,
      "status": "PASS"
    },
    "exact_error_one_literal": {
      "source_literal": "error: Atomic runtime comparisons failed: 1",
      "occurrence_ids": [
        "L035"
      ],
      "expected_occurrences": 1,
      "status": "PASS"
    },
    "manifest_audit_root": {
      "source_literal": "'audit_root': 'DefiKernel.Atomic.Audit'",
      "occurrence_ids": [
        "L009"
      ],
      "expected_occurrences": 1,
      "status": "PASS"
    },
    "manifest_scope_description": {
      "source_literal": "Atomic proof tails excluded",
      "occurrence_ids": [
        "L008"
      ],
      "expected_occurrences": 1,
      "status": "PASS"
    },
    "default_driver_path": {
      "source_literal": "scripts/check_atomic_mutations.py",
      "occurrence_ids": [
        "L029"
      ],
      "expected_occurrences": 1,
      "status": "PASS"
    },
    "extra_source_path": {
      "source_literal": "lean/DefiKernel/Atomic/SplitComputation.lean",
      "occurrence_ids": [
        "L037"
      ],
      "expected_occurrences": 1,
      "status": "PASS"
    }
  },
  "occurrences": [
    {
      "id": "L001",
      "file": "scripts/check_atomic_mutations.py",
      "source_sha256": "ab64b7681be152bedc0baf9cc0703fd0cbcd82df79c3fb887be9959a41810007",
      "line": 2,
      "column": 22,
      "byte_column": 22,
      "character_offset": 44,
      "byte_offset": 44,
      "matched_literal": "atomic",
      "source_line": "\"\"\"Replay the actual atomic Lean implementation under explicit source mutations.",
      "source_line_sha256": "fae72d41ea378020f05007cfbfd23d6221ef99d94433764b7dfa765e79e76d39",
      "decision": "rename",
      "replacement": "metatheory",
      "category": "documentation",
      "rationale": "Describe the new Metatheory implementation and its local modules.",
      "replacement_line": "\"\"\"Replay the actual metatheory Lean implementation under explicit source mutations."
    },
    {
      "id": "L002",
      "file": "scripts/check_atomic_mutations.py",
      "source_sha256": "ab64b7681be152bedc0baf9cc0703fd0cbcd82df79c3fb887be9959a41810007",
      "line": 139,
      "column": 25,
      "byte_column": 25,
      "character_offset": 5468,
      "byte_offset": 5468,
      "matched_literal": "Atomic",
      "source_line": "    require('DefiKernel.Atomic.Audit' in modules, 'missing Atomic audit root')",
      "source_line_sha256": "bdb6d989e3e6f654ad8b702ca0856fac14f95d9d88b7dcf49d54e5072f7f9f6f",
      "decision": "rename",
      "replacement": "Metatheory",
      "category": "diagnostic-protocol",
      "rationale": "Use the new audit namespace in emitted and expected diagnostic text; preserve count protocol.",
      "replacement_line": "    require('DefiKernel.Metatheory.Audit' in modules, 'missing Metatheory audit root')"
    },
    {
      "id": "L003",
      "file": "scripts/check_atomic_mutations.py",
      "source_sha256": "ab64b7681be152bedc0baf9cc0703fd0cbcd82df79c3fb887be9959a41810007",
      "line": 139,
      "column": 60,
      "byte_column": 60,
      "character_offset": 5503,
      "byte_offset": 5503,
      "matched_literal": "Atomic",
      "source_line": "    require('DefiKernel.Atomic.Audit' in modules, 'missing Atomic audit root')",
      "source_line_sha256": "bdb6d989e3e6f654ad8b702ca0856fac14f95d9d88b7dcf49d54e5072f7f9f6f",
      "decision": "rename",
      "replacement": "Metatheory",
      "category": "diagnostic-protocol",
      "rationale": "Use the new audit namespace in emitted and expected diagnostic text; preserve count protocol.",
      "replacement_line": "    require('DefiKernel.Metatheory.Audit' in modules, 'missing Metatheory audit root')"
    },
    {
      "id": "L004",
      "file": "scripts/check_atomic_mutations.py",
      "source_sha256": "ab64b7681be152bedc0baf9cc0703fd0cbcd82df79c3fb887be9959a41810007",
      "line": 159,
      "column": 63,
      "byte_column": 63,
      "character_offset": 6885,
      "byte_offset": 6885,
      "matched_literal": "Atomic",
      "source_line": "    # Discover and inline every local import, including split Atomic modules",
      "source_line_sha256": "1ed5abc2636b9897ed29129ae79638dad5ae7416e97d40b51d7977b2a3d97308",
      "decision": "rename",
      "replacement": "Metatheory",
      "category": "documentation",
      "rationale": "Describe the new Metatheory implementation and its local modules.",
      "replacement_line": "    # Discover and inline every local import, including split Metatheory modules"
    },
    {
      "id": "L005",
      "file": "scripts/check_atomic_mutations.py",
      "source_sha256": "ab64b7681be152bedc0baf9cc0703fd0cbcd82df79c3fb887be9959a41810007",
      "line": 186,
      "column": 27,
      "byte_column": 27,
      "character_offset": 8254,
      "byte_offset": 8254,
      "matched_literal": "Atomic",
      "source_line": "            r'DefiKernel\\.Atomic(?:\\.[A-Za-z][A-Za-z0-9]*)+', module),",
      "source_line_sha256": "be1d25dd5fd0c64ee89fc071f38a63a100b3e6784ade369bed1ef1c1c7e627bb",
      "decision": "rename",
      "replacement": "Metatheory",
      "category": "namespace-or-projection-scope",
      "rationale": "Adapt the fixture namespace or allowed mutation/proof-stripping scope to Metatheory only.",
      "replacement_line": "            r'DefiKernel\\.Metatheory(?:\\.[A-Za-z][A-Za-z0-9]*)+', module),"
    },
    {
      "id": "L006",
      "file": "scripts/check_atomic_mutations.py",
      "source_sha256": "ab64b7681be152bedc0baf9cc0703fd0cbcd82df79c3fb887be9959a41810007",
      "line": 198,
      "column": 63,
      "byte_column": 63,
      "character_offset": 8940,
      "byte_offset": 8940,
      "matched_literal": "Atomic",
      "source_line": "        if marker in source and module.startswith('DefiKernel.Atomic.'):",
      "source_line_sha256": "c18fe8ffb780ea7828247d39fab44998c5ffe5754d6c52a487f9d97851c5b8a2",
      "decision": "rename",
      "replacement": "Metatheory",
      "category": "namespace-or-projection-scope",
      "rationale": "Adapt the fixture namespace or allowed mutation/proof-stripping scope to Metatheory only.",
      "replacement_line": "        if marker in source and module.startswith('DefiKernel.Metatheory.'):"
    },
    {
      "id": "L007",
      "file": "scripts/check_atomic_mutations.py",
      "source_sha256": "ab64b7681be152bedc0baf9cc0703fd0cbcd82df79c3fb887be9959a41810007",
      "line": 212,
      "column": 54,
      "byte_column": 54,
      "character_offset": 9910,
      "byte_offset": 9910,
      "matched_literal": "Atomic",
      "source_line": "            closure = re.search(r'\\n(end DefiKernel\\.Atomic(?:\\.[A-Za-z][A-Za-z0-9]*)*)\\s*$', suffix)",
      "source_line_sha256": "23ee65fecf6334a7a65f28eb895c31a7332a32eb6ba01ca989cc98f0922398ce",
      "decision": "rename",
      "replacement": "Metatheory",
      "category": "namespace-or-projection-scope",
      "rationale": "Adapt the fixture namespace or allowed mutation/proof-stripping scope to Metatheory only.",
      "replacement_line": "            closure = re.search(r'\\n(end DefiKernel\\.Metatheory(?:\\.[A-Za-z][A-Za-z0-9]*)*)\\s*$', suffix)"
    },
    {
      "id": "L008",
      "file": "scripts/check_atomic_mutations.py",
      "source_sha256": "ab64b7681be152bedc0baf9cc0703fd0cbcd82df79c3fb887be9959a41810007",
      "line": 282,
      "column": 66,
      "byte_column": 66,
      "character_offset": 14548,
      "byte_offset": 14548,
      "matched_literal": "Atomic",
      "source_line": "                'scope': 'Fresh local dependency source closure; Atomic proof tails excluded; unchanged dependency proofs retained. Accepted files unchanged.',",
      "source_line_sha256": "80c3ac7aacc781c967d53c353520837a8151130ba998823f34bf6d5b0d038b3e",
      "decision": "rename",
      "replacement": "Metatheory",
      "category": "manifest-description",
      "rationale": "Describe only Metatheory proof tails as excluded; imported predecessor proofs remain retained.",
      "replacement_line": "                'scope': 'Fresh local dependency source closure; Metatheory proof tails excluded; unchanged dependency proofs retained. Accepted files unchanged.',"
    },
    {
      "id": "L009",
      "file": "scripts/check_atomic_mutations.py",
      "source_sha256": "ab64b7681be152bedc0baf9cc0703fd0cbcd82df79c3fb887be9959a41810007",
      "line": 286,
      "column": 43,
      "byte_column": 43,
      "character_offset": 14990,
      "byte_offset": 14990,
      "matched_literal": "Atomic",
      "source_line": "                'audit_root': 'DefiKernel.Atomic.Audit', 'python_version': sys.version}",
      "source_line_sha256": "10c34e0d7004b63c5c4f57ee75aedf89b4389810736ce0505e352e5784f0cb0f",
      "decision": "rename",
      "replacement": "Metatheory",
      "category": "manifest-audit-root",
      "rationale": "Bind the new Metatheory Audit module in the manifest.",
      "replacement_line": "                'audit_root': 'DefiKernel.Metatheory.Audit', 'python_version': sys.version}"
    },
    {
      "id": "L010",
      "file": "scripts/check_atomic_mutations.py",
      "source_sha256": "ab64b7681be152bedc0baf9cc0703fd0cbcd82df79c3fb887be9959a41810007",
      "line": 337,
      "column": 39,
      "byte_column": 39,
      "character_offset": 18496,
      "byte_offset": 18496,
      "matched_literal": "Atomic",
      "source_line": "            expected_error = f'error: Atomic runtime comparisons failed: {len(false)}'",
      "source_line_sha256": "ca2133adf9764d66f417b363442ff965fa8b47b70bfac948bbc0d39c4a357a22",
      "decision": "rename",
      "replacement": "Metatheory",
      "category": "diagnostic-protocol",
      "rationale": "Use the new audit namespace in emitted and expected diagnostic text; preserve count protocol.",
      "replacement_line": "            expected_error = f'error: Metatheory runtime comparisons failed: {len(false)}'"
    },
    {
      "id": "L011",
      "file": "scripts/check_atomic_mutations.py",
      "source_sha256": "ab64b7681be152bedc0baf9cc0703fd0cbcd82df79c3fb887be9959a41810007",
      "line": 347,
      "column": 39,
      "byte_column": 39,
      "character_offset": 19247,
      "byte_offset": 19247,
      "matched_literal": "Atomic",
      "source_line": "            expected_error = f'error: Atomic runtime comparisons failed: {len(false)}'",
      "source_line_sha256": "ca2133adf9764d66f417b363442ff965fa8b47b70bfac948bbc0d39c4a357a22",
      "decision": "rename",
      "replacement": "Metatheory",
      "category": "diagnostic-protocol",
      "rationale": "Use the new audit namespace in emitted and expected diagnostic text; preserve count protocol.",
      "replacement_line": "            expected_error = f'error: Metatheory runtime comparisons failed: {len(false)}'"
    },
    {
      "id": "L012",
      "file": "scripts/test_atomic_mutation_runner.py",
      "source_sha256": "dc539d354e1c9c7a3f3ccc7278b3d223fd4c015ba842cd4154930d2108e4e662",
      "line": 21,
      "column": 28,
      "byte_column": 28,
      "character_offset": 647,
      "byte_offset": 647,
      "matched_literal": "Atomic",
      "source_line": "INPUT_MODULE = 'DefiKernel.Atomic.RunnerInput'",
      "source_line_sha256": "dbdcc20c99c002f08d80dc8a50eb8bfe05c3b9b0feb9b1b713c12c30fdb2ac9b",
      "decision": "rename",
      "replacement": "Metatheory",
      "category": "namespace-or-projection-scope",
      "rationale": "Adapt the fixture namespace or allowed mutation/proof-stripping scope to Metatheory only.",
      "replacement_line": "INPUT_MODULE = 'DefiKernel.Metatheory.RunnerInput'"
    },
    {
      "id": "L013",
      "file": "scripts/test_atomic_mutation_runner.py",
      "source_sha256": "dc539d354e1c9c7a3f3ccc7278b3d223fd4c015ba842cd4154930d2108e4e662",
      "line": 22,
      "column": 28,
      "byte_column": 28,
      "character_offset": 694,
      "byte_offset": 694,
      "matched_literal": "Atomic",
      "source_line": "AUDIT_MODULE = 'DefiKernel.Atomic.Audit'",
      "source_line_sha256": "fbd00487736e2bba50df7203adc94d3016f0e90a370b4924d7eb4978859c96d4",
      "decision": "rename",
      "replacement": "Metatheory",
      "category": "namespace-or-projection-scope",
      "rationale": "Adapt the fixture namespace or allowed mutation/proof-stripping scope to Metatheory only.",
      "replacement_line": "AUDIT_MODULE = 'DefiKernel.Metatheory.Audit'"
    },
    {
      "id": "L014",
      "file": "scripts/test_atomic_mutation_runner.py",
      "source_sha256": "dc539d354e1c9c7a3f3ccc7278b3d223fd4c015ba842cd4154930d2108e4e662",
      "line": 32,
      "column": 22,
      "byte_column": 22,
      "character_offset": 1010,
      "byte_offset": 1010,
      "matched_literal": "Atomic",
      "source_line": "namespace DefiKernel.Atomic",
      "source_line_sha256": "18bd2941b31869359be663eb697e35b8ff584b1a1c9723d148e779af838fb6c3",
      "decision": "rename",
      "replacement": "Metatheory",
      "category": "namespace-or-projection-scope",
      "rationale": "Adapt the fixture namespace or allowed mutation/proof-stripping scope to Metatheory only.",
      "replacement_line": "namespace DefiKernel.Metatheory"
    },
    {
      "id": "L015",
      "file": "scripts/test_atomic_mutation_runner.py",
      "source_sha256": "dc539d354e1c9c7a3f3ccc7278b3d223fd4c015ba842cd4154930d2108e4e662",
      "line": 44,
      "column": 16,
      "byte_column": 16,
      "character_offset": 1328,
      "byte_offset": 1330,
      "matched_literal": "Atomic",
      "source_line": "end DefiKernel.Atomic",
      "source_line_sha256": "1f6f0ee44b20382764697028cdf11a3a0e6dcedb79259386f13ba06a52e880a9",
      "decision": "rename",
      "replacement": "Metatheory",
      "category": "namespace-or-projection-scope",
      "rationale": "Adapt the fixture namespace or allowed mutation/proof-stripping scope to Metatheory only.",
      "replacement_line": "end DefiKernel.Metatheory"
    },
    {
      "id": "L016",
      "file": "scripts/test_atomic_mutation_runner.py",
      "source_sha256": "dc539d354e1c9c7a3f3ccc7278b3d223fd4c015ba842cd4154930d2108e4e662",
      "line": 46,
      "column": 30,
      "byte_column": 30,
      "character_offset": 1368,
      "byte_offset": 1370,
      "matched_literal": "Atomic",
      "source_line": "AUDIT = '''import DefiKernel.Atomic.RunnerInput",
      "source_line_sha256": "14ebbe8249f201267dd1bd6344fdc2b7a1cb1e07ac21df622603bccc6e71f5c7",
      "decision": "rename",
      "replacement": "Metatheory",
      "category": "namespace-or-projection-scope",
      "rationale": "Adapt the fixture namespace or allowed mutation/proof-stripping scope to Metatheory only.",
      "replacement_line": "AUDIT = '''import DefiKernel.Metatheory.RunnerInput"
    },
    {
      "id": "L017",
      "file": "scripts/test_atomic_mutation_runner.py",
      "source_sha256": "dc539d354e1c9c7a3f3ccc7278b3d223fd4c015ba842cd4154930d2108e4e662",
      "line": 48,
      "column": 22,
      "byte_column": 22,
      "character_offset": 1409,
      "byte_offset": 1411,
      "matched_literal": "Atomic",
      "source_line": "namespace DefiKernel.Atomic",
      "source_line_sha256": "18bd2941b31869359be663eb697e35b8ff584b1a1c9723d148e779af838fb6c3",
      "decision": "rename",
      "replacement": "Metatheory",
      "category": "namespace-or-projection-scope",
      "rationale": "Adapt the fixture namespace or allowed mutation/proof-stripping scope to Metatheory only.",
      "replacement_line": "namespace DefiKernel.Metatheory"
    },
    {
      "id": "L018",
      "file": "scripts/test_atomic_mutation_runner.py",
      "source_sha256": "dc539d354e1c9c7a3f3ccc7278b3d223fd4c015ba842cd4154930d2108e4e662",
      "line": 57,
      "column": 17,
      "byte_column": 17,
      "character_offset": 1680,
      "byte_offset": 1683,
      "matched_literal": "Atomic",
      "source_line": "    throwError \"Atomic runtime comparisons failed: {failures}\"",
      "source_line_sha256": "563031cef25ee63f2e2cccf853ac10648b264b95661e4c03cb1758c41e8eb03c",
      "decision": "rename",
      "replacement": "Metatheory",
      "category": "diagnostic-protocol",
      "rationale": "Use the new audit namespace in emitted and expected diagnostic text; preserve count protocol.",
      "replacement_line": "    throwError \"Metatheory runtime comparisons failed: {failures}\""
    },
    {
      "id": "L019",
      "file": "scripts/test_atomic_mutation_runner.py",
      "source_sha256": "dc539d354e1c9c7a3f3ccc7278b3d223fd4c015ba842cd4154930d2108e4e662",
      "line": 59,
      "column": 16,
      "byte_column": 16,
      "character_offset": 1743,
      "byte_offset": 1746,
      "matched_literal": "Atomic",
      "source_line": "end DefiKernel.Atomic",
      "source_line_sha256": "1f6f0ee44b20382764697028cdf11a3a0e6dcedb79259386f13ba06a52e880a9",
      "decision": "rename",
      "replacement": "Metatheory",
      "category": "namespace-or-projection-scope",
      "rationale": "Adapt the fixture namespace or allowed mutation/proof-stripping scope to Metatheory only.",
      "replacement_line": "end DefiKernel.Metatheory"
    },
    {
      "id": "L020",
      "file": "scripts/test_atomic_mutation_runner.py",
      "source_sha256": "dc539d354e1c9c7a3f3ccc7278b3d223fd4c015ba842cd4154930d2108e4e662",
      "line": 61,
      "column": 41,
      "byte_column": 41,
      "character_offset": 1794,
      "byte_offset": 1797,
      "matched_literal": "Atomic",
      "source_line": "PRODUCTION_AUDIT = '''import DefiKernel.Atomic.RunnerInput",
      "source_line_sha256": "2cb428e9a3e105fb8895b06086b30076d56911f715314d4f50046646b416ebfc",
      "decision": "rename",
      "replacement": "Metatheory",
      "category": "namespace-or-projection-scope",
      "rationale": "Adapt the fixture namespace or allowed mutation/proof-stripping scope to Metatheory only.",
      "replacement_line": "PRODUCTION_AUDIT = '''import DefiKernel.Metatheory.RunnerInput"
    },
    {
      "id": "L021",
      "file": "scripts/test_atomic_mutation_runner.py",
      "source_sha256": "dc539d354e1c9c7a3f3ccc7278b3d223fd4c015ba842cd4154930d2108e4e662",
      "line": 62,
      "column": 22,
      "byte_column": 22,
      "character_offset": 1834,
      "byte_offset": 1837,
      "matched_literal": "Atomic",
      "source_line": "namespace DefiKernel.Atomic.Audit",
      "source_line_sha256": "1beed832196a23ee6bd7081c61d1cc1fb3add2efcf229952988d0e0e00bde3e0",
      "decision": "rename",
      "replacement": "Metatheory",
      "category": "namespace-or-projection-scope",
      "rationale": "Adapt the fixture namespace or allowed mutation/proof-stripping scope to Metatheory only.",
      "replacement_line": "namespace DefiKernel.Metatheory.Audit"
    },
    {
      "id": "L022",
      "file": "scripts/test_atomic_mutation_runner.py",
      "source_sha256": "dc539d354e1c9c7a3f3ccc7278b3d223fd4c015ba842cd4154930d2108e4e662",
      "line": 65,
      "column": 47,
      "byte_column": 47,
      "character_offset": 1964,
      "byte_offset": 1968,
      "matched_literal": "Atomic",
      "source_line": "  if checks.isEmpty then throw (IO.userError \"Atomic runtime comparisons empty\")",
      "source_line_sha256": "c379953e432440ab1036ea497f8b28d54889e9b394847de121ea2162164c0b1f",
      "decision": "rename",
      "replacement": "Metatheory",
      "category": "diagnostic-protocol",
      "rationale": "Use the new audit namespace in emitted and expected diagnostic text; preserve count protocol.",
      "replacement_line": "  if checks.isEmpty then throw (IO.userError \"Metatheory runtime comparisons empty\")"
    },
    {
      "id": "L023",
      "file": "scripts/test_atomic_mutation_runner.py",
      "source_sha256": "dc539d354e1c9c7a3f3ccc7278b3d223fd4c015ba842cd4154930d2108e4e662",
      "line": 67,
      "column": 26,
      "byte_column": 26,
      "character_offset": 2063,
      "byte_offset": 2067,
      "matched_literal": "Atomic",
      "source_line": "    throw (IO.userError \"Atomic runtime comparison names are duplicated\")",
      "source_line_sha256": "31b7a53de8ddebc8af247885bf32c8182f846c40a4e2f9feda8ab9f6b80bf266",
      "decision": "rename",
      "replacement": "Metatheory",
      "category": "diagnostic-protocol",
      "rationale": "Use the new audit namespace in emitted and expected diagnostic text; preserve count protocol.",
      "replacement_line": "    throw (IO.userError \"Metatheory runtime comparison names are duplicated\")"
    },
    {
      "id": "L024",
      "file": "scripts/test_atomic_mutation_runner.py",
      "source_sha256": "dc539d354e1c9c7a3f3ccc7278b3d223fd4c015ba842cd4154930d2108e4e662",
      "line": 71,
      "column": 28,
      "byte_column": 28,
      "character_offset": 2288,
      "byte_offset": 2293,
      "matched_literal": "Atomic",
      "source_line": "    throw (IO.userError s!\"Atomic runtime comparisons failed: {failures.length}\")",
      "source_line_sha256": "14d725c65b1cc54e7724a1cc7ed75cf56e5ab3c6b41463e21007138234d56acf",
      "decision": "rename",
      "replacement": "Metatheory",
      "category": "diagnostic-protocol",
      "rationale": "Use the new audit namespace in emitted and expected diagnostic text; preserve count protocol.",
      "replacement_line": "    throw (IO.userError s!\"Metatheory runtime comparisons failed: {failures.length}\")"
    },
    {
      "id": "L025",
      "file": "scripts/test_atomic_mutation_runner.py",
      "source_sha256": "dc539d354e1c9c7a3f3ccc7278b3d223fd4c015ba842cd4154930d2108e4e662",
      "line": 76,
      "column": 16,
      "byte_column": 16,
      "character_offset": 2387,
      "byte_offset": 2392,
      "matched_literal": "Atomic",
      "source_line": "end DefiKernel.Atomic.Audit",
      "source_line_sha256": "f8e5b8310375231675cc98822ed94a225846f6113973105e3602dd78e1eac1a2",
      "decision": "rename",
      "replacement": "Metatheory",
      "category": "namespace-or-projection-scope",
      "rationale": "Adapt the fixture namespace or allowed mutation/proof-stripping scope to Metatheory only.",
      "replacement_line": "end DefiKernel.Metatheory.Audit"
    },
    {
      "id": "L026",
      "file": "scripts/test_atomic_mutation_runner.py",
      "source_sha256": "dc539d354e1c9c7a3f3ccc7278b3d223fd4c015ba842cd4154930d2108e4e662",
      "line": 221,
      "column": 30,
      "byte_column": 30,
      "character_offset": 11144,
      "byte_offset": 11161,
      "matched_literal": "atomic",
      "source_line": "        {'name': 'discovered-atomic-dependency', 'exit': 0, 'extra_dependency': True,",
      "source_line_sha256": "4e14f5d6388bbd4c660e0a9146b2d468c7fcbffeb48965dca38b5fea0411c55b",
      "decision": "rename",
      "replacement": "metatheory",
      "category": "case-identity",
      "rationale": "Rename both the case declaration and exact-observation verification tuple member.",
      "replacement_line": "        {'name': 'discovered-metatheory-dependency', 'exit': 0, 'extra_dependency': True,"
    },
    {
      "id": "L027",
      "file": "scripts/test_atomic_mutation_runner.py",
      "source_sha256": "dc539d354e1c9c7a3f3ccc7278b3d223fd4c015ba842cd4154930d2108e4e662",
      "line": 227,
      "column": 30,
      "byte_column": 30,
      "character_offset": 11581,
      "byte_offset": 11598,
      "matched_literal": "Atomic",
      "source_line": "         'message': 'missing Atomic audit root'},",
      "source_line_sha256": "57c25aebbc0d04f87b18db2734225e15b4727fd5a92962d4a30d4b902ab23e68",
      "decision": "rename",
      "replacement": "Metatheory",
      "category": "diagnostic-protocol",
      "rationale": "Use the new audit namespace in emitted and expected diagnostic text; preserve count protocol.",
      "replacement_line": "         'message': 'missing Metatheory audit root'},"
    },
    {
      "id": "L028",
      "file": "scripts/test_atomic_mutation_runner.py",
      "source_sha256": "dc539d354e1c9c7a3f3ccc7278b3d223fd4c015ba842cd4154930d2108e4e662",
      "line": 233,
      "column": 69,
      "byte_column": 69,
      "character_offset": 11995,
      "byte_offset": 12012,
      "matched_literal": "Atomic",
      "source_line": "         'spec': specification({**mutation(), 'module': 'DefiKernel.Atomic.Absent'}),",
      "source_line_sha256": "11e195a5a04d50ba9420b66581668cdfb75afa7b181a045c7440822a2dfee4c5",
      "decision": "rename",
      "replacement": "Metatheory",
      "category": "namespace-or-projection-scope",
      "rationale": "Adapt the fixture namespace or allowed mutation/proof-stripping scope to Metatheory only.",
      "replacement_line": "         'spec': specification({**mutation(), 'module': 'DefiKernel.Metatheory.Absent'}),"
    },
    {
      "id": "L029",
      "file": "scripts/test_atomic_mutation_runner.py",
      "source_sha256": "dc539d354e1c9c7a3f3ccc7278b3d223fd4c015ba842cd4154930d2108e4e662",
      "line": 298,
      "column": 52,
      "byte_column": 52,
      "character_offset": 16515,
      "byte_offset": 16534,
      "matched_literal": "atomic",
      "source_line": "    runner = (args.runner or repo / 'scripts/check_atomic_mutations.py').resolve()",
      "source_line_sha256": "7412ab6442ebad04f03432f7024111ffb89c370d2d5947802ced09548689326c",
      "decision": "rename",
      "replacement": "metatheory",
      "category": "filesystem-path",
      "rationale": "Point the new harness to its new driver or Metatheory fixture source path.",
      "replacement_line": "    runner = (args.runner or repo / 'scripts/check_metatheory_mutations.py').resolve()"
    },
    {
      "id": "L030",
      "file": "scripts/test_atomic_mutation_runner.py",
      "source_sha256": "dc539d354e1c9c7a3f3ccc7278b3d223fd4c015ba842cd4154930d2108e4e662",
      "line": 323,
      "column": 32,
      "byte_column": 32,
      "character_offset": 17904,
      "byte_offset": 17923,
      "matched_literal": "Atomic",
      "source_line": "    typed = lean / 'DefiKernel/Atomic'",
      "source_line_sha256": "3047cb540e3d970be9f7862d7804c5bec6c1cd3dabf7fea8ff0d4e7ad56ef583",
      "decision": "rename",
      "replacement": "Metatheory",
      "category": "filesystem-path",
      "rationale": "Point the new harness to its new driver or Metatheory fixture source path.",
      "replacement_line": "    typed = lean / 'DefiKernel/Metatheory'"
    },
    {
      "id": "L031",
      "file": "scripts/test_atomic_mutation_runner.py",
      "source_sha256": "dc539d354e1c9c7a3f3ccc7278b3d223fd4c015ba842cd4154930d2108e4e662",
      "line": 361,
      "column": 52,
      "byte_column": 52,
      "character_offset": 20130,
      "byte_offset": 20149,
      "matched_literal": "Atomic",
      "source_line": "                             'namespace DefiKernel.Atomic\\n'",
      "source_line_sha256": "c0d0fb1286778211f87c5f6dcec0f104888daf851e740da1f2657eef89472fe6",
      "decision": "rename",
      "replacement": "Metatheory",
      "category": "namespace-or-projection-scope",
      "rationale": "Adapt the fixture namespace or allowed mutation/proof-stripping scope to Metatheory only.",
      "replacement_line": "                             'namespace DefiKernel.Metatheory\\n'"
    },
    {
      "id": "L032",
      "file": "scripts/test_atomic_mutation_runner.py",
      "source_sha256": "dc539d354e1c9c7a3f3ccc7278b3d223fd4c015ba842cd4154930d2108e4e662",
      "line": 365,
      "column": 46,
      "byte_column": 46,
      "character_offset": 20375,
      "byte_offset": 20394,
      "matched_literal": "Atomic",
      "source_line": "                             'end DefiKernel.Atomic\\n')",
      "source_line_sha256": "92f6a230a1219e0d99de6ae035256ca2e551b6a1d715648065fd40555c139b9c",
      "decision": "rename",
      "replacement": "Metatheory",
      "category": "namespace-or-projection-scope",
      "rationale": "Adapt the fixture namespace or allowed mutation/proof-stripping scope to Metatheory only.",
      "replacement_line": "                             'end DefiKernel.Metatheory\\n')"
    },
    {
      "id": "L033",
      "file": "scripts/test_atomic_mutation_runner.py",
      "source_sha256": "dc539d354e1c9c7a3f3ccc7278b3d223fd4c015ba842cd4154930d2108e4e662",
      "line": 368,
      "column": 36,
      "byte_column": 36,
      "character_offset": 20555,
      "byte_offset": 20574,
      "matched_literal": "Atomic",
      "source_line": "                'import DefiKernel.Atomic.SplitComputation').replace(",
      "source_line_sha256": "88b27102e626b4915eddb0df4ff06d0807127d06c909a58fe14c254189c8930c",
      "decision": "rename",
      "replacement": "Metatheory",
      "category": "namespace-or-projection-scope",
      "rationale": "Adapt the fixture namespace or allowed mutation/proof-stripping scope to Metatheory only.",
      "replacement_line": "                'import DefiKernel.Metatheory.SplitComputation').replace("
    },
    {
      "id": "L034",
      "file": "scripts/test_atomic_mutation_runner.py",
      "source_sha256": "dc539d354e1c9c7a3f3ccc7278b3d223fd4c015ba842cd4154930d2108e4e662",
      "line": 448,
      "column": 167,
      "byte_column": 167,
      "character_offset": 25978,
      "byte_offset": 26001,
      "matched_literal": "atomic",
      "source_line": "        if case['name'] in ('production-eval-discriminating-mutant', 'live-discriminating-mutant', 'dotted-comparisons', 'hyphenated-dotted-comparisons', 'discovered-atomic-dependency', 'unused-variable-warning', 'nonkernel-local-dependency', 'proof-comment-keywords-sibling', 'proof-string-keywords-sibling', 'proof-raw-string-character-sibling'):",
      "source_line_sha256": "89e219cde90393d309f57daedab44785600856e80ed75e5374e7370d931b9208",
      "decision": "rename",
      "replacement": "metatheory",
      "category": "case-identity",
      "rationale": "Rename both the case declaration and exact-observation verification tuple member.",
      "replacement_line": "        if case['name'] in ('production-eval-discriminating-mutant', 'live-discriminating-mutant', 'dotted-comparisons', 'hyphenated-dotted-comparisons', 'discovered-metatheory-dependency', 'unused-variable-warning', 'nonkernel-local-dependency', 'proof-comment-keywords-sibling', 'proof-string-keywords-sibling', 'proof-raw-string-character-sibling'):"
    },
    {
      "id": "L035",
      "file": "scripts/test_atomic_mutation_runner.py",
      "source_sha256": "dc539d354e1c9c7a3f3ccc7278b3d223fd4c015ba842cd4154930d2108e4e662",
      "line": 471,
      "column": 33,
      "byte_column": 33,
      "character_offset": 27732,
      "byte_offset": 27755,
      "matched_literal": "Atomic",
      "source_line": "                        'error: Atomic runtime comparisons failed: 1') == 1",
      "source_line_sha256": "0041d6f71aec3086ccf7c7387c8b04685cff285a95cf88d0d020e90e7c82a266",
      "decision": "rename",
      "replacement": "Metatheory",
      "category": "diagnostic-protocol",
      "rationale": "Use the new audit namespace in emitted and expected diagnostic text; preserve count protocol.",
      "replacement_line": "                        'error: Metatheory runtime comparisons failed: 1') == 1"
    },
    {
      "id": "L036",
      "file": "scripts/test_atomic_mutation_runner.py",
      "source_sha256": "dc539d354e1c9c7a3f3ccc7278b3d223fd4c015ba842cd4154930d2108e4e662",
      "line": 481,
      "column": 47,
      "byte_column": 47,
      "character_offset": 28480,
      "byte_offset": 28503,
      "matched_literal": "Atomic",
      "source_line": "            matched = matched and 'DefiKernel.Atomic.SplitComputation' in captured.get('projection_order', [])",
      "source_line_sha256": "e8d3cc0b9bf6a0e36f41a569e0fef318da7b0e379802bed5c4c2bf67e2e3993d",
      "decision": "rename",
      "replacement": "Metatheory",
      "category": "namespace-or-projection-scope",
      "rationale": "Adapt the fixture namespace or allowed mutation/proof-stripping scope to Metatheory only.",
      "replacement_line": "            matched = matched and 'DefiKernel.Metatheory.SplitComputation' in captured.get('projection_order', [])"
    },
    {
      "id": "L037",
      "file": "scripts/test_atomic_mutation_runner.py",
      "source_sha256": "dc539d354e1c9c7a3f3ccc7278b3d223fd4c015ba842cd4154930d2108e4e662",
      "line": 483,
      "column": 34,
      "byte_column": 34,
      "character_offset": 28645,
      "byte_offset": 28668,
      "matched_literal": "Atomic",
      "source_line": "                'lean/DefiKernel/Atomic/SplitComputation.lean') == sha(extra.read_bytes())",
      "source_line_sha256": "9510de8d1eb94e8c182f492b10af2c8bfbc3131fb83d3b8c185e12196ba26d6d",
      "decision": "rename",
      "replacement": "Metatheory",
      "category": "filesystem-path",
      "rationale": "Point the new harness to its new driver or Metatheory fixture source path.",
      "replacement_line": "                'lean/DefiKernel/Metatheory/SplitComputation.lean') == sha(extra.read_bytes())"
    }
  ],
  "control_inventory": {
    "method": "Read cases() list via Python AST; no import or execution.",
    "count": 65,
    "exit_counts": {
      "0": 10,
      "1": 5,
      "3": 50
    },
    "predecessor": [
      {
        "name": "production-eval-discriminating-mutant",
        "exit": 0
      },
      {
        "name": "production-eval-required-stays-true",
        "exit": 1
      },
      {
        "name": "live-discriminating-mutant",
        "exit": 0
      },
      {
        "name": "dotted-comparisons",
        "exit": 0
      },
      {
        "name": "hyphenated-dotted-comparisons",
        "exit": 0
      },
      {
        "name": "empty-dot-segment-spec",
        "exit": 3
      },
      {
        "name": "trailing-dot-spec",
        "exit": 3
      },
      {
        "name": "leading-dot-observation",
        "exit": 3
      },
      {
        "name": "empty-dot-segment-observation",
        "exit": 3
      },
      {
        "name": "unused-variable-warning",
        "exit": 0
      },
      {
        "name": "uppercase-observation",
        "exit": 3
      },
      {
        "name": "unknown-mutant-observation",
        "exit": 3
      },
      {
        "name": "all-true-mutant",
        "exit": 1
      },
      {
        "name": "required-observation-stays-true",
        "exit": 1
      },
      {
        "name": "positive-control-flipped",
        "exit": 1
      },
      {
        "name": "compilation-only-failure",
        "exit": 3
      },
      {
        "name": "compiler-error-with-runtime-failure",
        "exit": 3
      },
      {
        "name": "empty-observations",
        "exit": 3
      },
      {
        "name": "duplicate-observations",
        "exit": 3
      },
      {
        "name": "missing-positive-observation",
        "exit": 3
      },
      {
        "name": "missing-required-observation",
        "exit": 3
      },
      {
        "name": "partial-mutant-observations",
        "exit": 3
      },
      {
        "name": "no-op-mutation",
        "exit": 3
      },
      {
        "name": "missing-mutation-needle",
        "exit": 3
      },
      {
        "name": "missing-source-setup",
        "exit": 3
      },
      {
        "name": "missing-manifest-setup",
        "exit": 3
      },
      {
        "name": "existing-output-setup",
        "exit": 3
      },
      {
        "name": "reserved-mutation-name",
        "exit": 3
      },
      {
        "name": "empty-module-inventory",
        "exit": 3
      },
      {
        "name": "empty-positive-inventory",
        "exit": 3
      },
      {
        "name": "duplicate-module-inventory",
        "exit": 3
      },
      {
        "name": "duplicate-mutation-inventory",
        "exit": 3
      },
      {
        "name": "duplicate-positive-check",
        "exit": 3
      },
      {
        "name": "duplicate-required-check",
        "exit": 3
      },
      {
        "name": "nonunique-mutation-needle",
        "exit": 3
      },
      {
        "name": "malformed-observation",
        "exit": 3
      },
      {
        "name": "malformed-json",
        "exit": 3
      },
      {
        "name": "duplicate-json-key",
        "exit": 3
      },
      {
        "name": "output-inside-repository",
        "exit": 3
      },
      {
        "name": "output-symlink",
        "exit": 3
      },
      {
        "name": "discovered-atomic-dependency",
        "exit": 0
      },
      {
        "name": "fresh-dependency-source-failure",
        "exit": 3
      },
      {
        "name": "missing-audit-root",
        "exit": 3
      },
      {
        "name": "foreign-module-root",
        "exit": 3
      },
      {
        "name": "mutation-module-outside-inventory",
        "exit": 3
      },
      {
        "name": "unchanged-control-failed",
        "exit": 1
      },
      {
        "name": "nonkernel-local-dependency",
        "exit": 0
      },
      {
        "name": "dirty-source-before-run",
        "exit": 3
      },
      {
        "name": "staged-source-before-run",
        "exit": 3
      },
      {
        "name": "source-drift-during-run",
        "exit": 3
      },
      {
        "name": "source-drift-during-mutant",
        "exit": 3
      },
      {
        "name": "specification-drift-during-run",
        "exit": 3
      },
      {
        "name": "runtime-definition-after-proof-boundary",
        "exit": 3
      },
      {
        "name": "attributed-runtime-after-proof-boundary",
        "exit": 3
      },
      {
        "name": "comment-prefixed-runtime-after-proof-boundary",
        "exit": 3
      },
      {
        "name": "macro-after-proof-boundary",
        "exit": 3
      },
      {
        "name": "macro-rules-after-proof-boundary",
        "exit": 3
      },
      {
        "name": "syntax-after-proof-boundary",
        "exit": 3
      },
      {
        "name": "initialize-after-proof-boundary",
        "exit": 3
      },
      {
        "name": "proof-comment-keywords-sibling",
        "exit": 0
      },
      {
        "name": "proof-string-keywords-sibling",
        "exit": 0
      },
      {
        "name": "raw-string-before-attributed-runtime",
        "exit": 3
      },
      {
        "name": "character-before-attributed-runtime",
        "exit": 3
      },
      {
        "name": "proof-raw-string-character-sibling",
        "exit": 0
      },
      {
        "name": "empty-mutation-inventory",
        "exit": 3
      }
    ],
    "planned": [
      {
        "name": "production-eval-discriminating-mutant",
        "exit": 0
      },
      {
        "name": "production-eval-required-stays-true",
        "exit": 1
      },
      {
        "name": "live-discriminating-mutant",
        "exit": 0
      },
      {
        "name": "dotted-comparisons",
        "exit": 0
      },
      {
        "name": "hyphenated-dotted-comparisons",
        "exit": 0
      },
      {
        "name": "empty-dot-segment-spec",
        "exit": 3
      },
      {
        "name": "trailing-dot-spec",
        "exit": 3
      },
      {
        "name": "leading-dot-observation",
        "exit": 3
      },
      {
        "name": "empty-dot-segment-observation",
        "exit": 3
      },
      {
        "name": "unused-variable-warning",
        "exit": 0
      },
      {
        "name": "uppercase-observation",
        "exit": 3
      },
      {
        "name": "unknown-mutant-observation",
        "exit": 3
      },
      {
        "name": "all-true-mutant",
        "exit": 1
      },
      {
        "name": "required-observation-stays-true",
        "exit": 1
      },
      {
        "name": "positive-control-flipped",
        "exit": 1
      },
      {
        "name": "compilation-only-failure",
        "exit": 3
      },
      {
        "name": "compiler-error-with-runtime-failure",
        "exit": 3
      },
      {
        "name": "empty-observations",
        "exit": 3
      },
      {
        "name": "duplicate-observations",
        "exit": 3
      },
      {
        "name": "missing-positive-observation",
        "exit": 3
      },
      {
        "name": "missing-required-observation",
        "exit": 3
      },
      {
        "name": "partial-mutant-observations",
        "exit": 3
      },
      {
        "name": "no-op-mutation",
        "exit": 3
      },
      {
        "name": "missing-mutation-needle",
        "exit": 3
      },
      {
        "name": "missing-source-setup",
        "exit": 3
      },
      {
        "name": "missing-manifest-setup",
        "exit": 3
      },
      {
        "name": "existing-output-setup",
        "exit": 3
      },
      {
        "name": "reserved-mutation-name",
        "exit": 3
      },
      {
        "name": "empty-module-inventory",
        "exit": 3
      },
      {
        "name": "empty-positive-inventory",
        "exit": 3
      },
      {
        "name": "duplicate-module-inventory",
        "exit": 3
      },
      {
        "name": "duplicate-mutation-inventory",
        "exit": 3
      },
      {
        "name": "duplicate-positive-check",
        "exit": 3
      },
      {
        "name": "duplicate-required-check",
        "exit": 3
      },
      {
        "name": "nonunique-mutation-needle",
        "exit": 3
      },
      {
        "name": "malformed-observation",
        "exit": 3
      },
      {
        "name": "malformed-json",
        "exit": 3
      },
      {
        "name": "duplicate-json-key",
        "exit": 3
      },
      {
        "name": "output-inside-repository",
        "exit": 3
      },
      {
        "name": "output-symlink",
        "exit": 3
      },
      {
        "name": "discovered-metatheory-dependency",
        "exit": 0
      },
      {
        "name": "fresh-dependency-source-failure",
        "exit": 3
      },
      {
        "name": "missing-audit-root",
        "exit": 3
      },
      {
        "name": "foreign-module-root",
        "exit": 3
      },
      {
        "name": "mutation-module-outside-inventory",
        "exit": 3
      },
      {
        "name": "unchanged-control-failed",
        "exit": 1
      },
      {
        "name": "nonkernel-local-dependency",
        "exit": 0
      },
      {
        "name": "dirty-source-before-run",
        "exit": 3
      },
      {
        "name": "staged-source-before-run",
        "exit": 3
      },
      {
        "name": "source-drift-during-run",
        "exit": 3
      },
      {
        "name": "source-drift-during-mutant",
        "exit": 3
      },
      {
        "name": "specification-drift-during-run",
        "exit": 3
      },
      {
        "name": "runtime-definition-after-proof-boundary",
        "exit": 3
      },
      {
        "name": "attributed-runtime-after-proof-boundary",
        "exit": 3
      },
      {
        "name": "comment-prefixed-runtime-after-proof-boundary",
        "exit": 3
      },
      {
        "name": "macro-after-proof-boundary",
        "exit": 3
      },
      {
        "name": "macro-rules-after-proof-boundary",
        "exit": 3
      },
      {
        "name": "syntax-after-proof-boundary",
        "exit": 3
      },
      {
        "name": "initialize-after-proof-boundary",
        "exit": 3
      },
      {
        "name": "proof-comment-keywords-sibling",
        "exit": 0
      },
      {
        "name": "proof-string-keywords-sibling",
        "exit": 0
      },
      {
        "name": "raw-string-before-attributed-runtime",
        "exit": 3
      },
      {
        "name": "character-before-attributed-runtime",
        "exit": 3
      },
      {
        "name": "proof-raw-string-character-sibling",
        "exit": 0
      },
      {
        "name": "empty-mutation-inventory",
        "exit": 3
      }
    ],
    "changed_names": [
      {
        "old": "discovered-atomic-dependency",
        "new": "discovered-metatheory-dependency"
      }
    ]
  }
}


===== INPUT review/semantic-kernel/sprint9/planning/build-runner-literal-map.py ORIGINAL_SHA256 0571b0110741ba6ab586c2b840383658df0f68ab6170334b0a01282db5d5218a RENDERED_SHA256 0571b0110741ba6ab586c2b840383658df0f68ab6170334b0a01282db5d5218a =====
#!/usr/bin/env python3
"""Reproduce the planning-only, exhaustive predecessor literal adaptation map.

Reads frozen Git objects and verifies current input bytes. Does not import or
execute either runner, create adapted scripts, or execute any Lean control.
"""
import ast
from collections import Counter
import hashlib
import json
from pathlib import Path
import re
import subprocess


HERE = Path(__file__).resolve().parent
REPO = HERE.parents[3]
ACCEPTED = '99e2e2c61a1a3c5249026921efdc6cd41ac8f21d'
PLANNING = '47cd83136ab69b0975594a77c519f6611f6fb555'
FILES = ('scripts/check_atomic_mutations.py', 'scripts/test_atomic_mutation_runner.py')
SPEC = 'review/semantic-kernel/sprint8/mutation-spec.json'
PATTERN = re.compile('atomic', re.IGNORECASE)
REPLACEMENTS = {'Atomic': 'Metatheory', 'atomic': 'metatheory'}


def sha(data):
    return hashlib.sha256(data).hexdigest()


def git(*args):
    return subprocess.check_output(['git', *args], cwd=REPO)


def binding(path):
    data = (REPO / path).read_bytes()
    revisions = {}
    for revision in (ACCEPTED, PLANNING):
        frozen = git('show', f'{revision}:{path}')
        assert data == frozen, (path, revision, 'input bytes differ')
        revisions[revision] = {
            'git_blob': git('rev-parse', f'{revision}:{path}').decode().strip(),
            'sha256': sha(frozen), 'bytes': len(frozen),
        }
    return data, {'path': path, 'sha256': sha(data), 'bytes': len(data),
                  'current_bytes_equal_both_revisions': True, 'revisions': revisions}


def reason(line):
    if 'discovered-atomic-dependency' in line:
        return ('case-identity', 'Rename both the case declaration and exact-observation verification tuple member.')
    if 'runtime comparison' in line or 'missing Atomic audit root' in line:
        return ('diagnostic-protocol', 'Use the new audit namespace in emitted and expected diagnostic text; preserve count protocol.')
    if "'scope':" in line:
        return ('manifest-description', 'Describe only Metatheory proof tails as excluded; imported predecessor proofs remain retained.')
    if "'audit_root':" in line:
        return ('manifest-audit-root', 'Bind the new Metatheory Audit module in the manifest.')
    if 'check_atomic_mutations.py' in line or 'DefiKernel/Atomic' in line:
        return ('filesystem-path', 'Point the new harness to its new driver or Metatheory fixture source path.')
    if 'DefiKernel' in line:
        return ('namespace-or-projection-scope', 'Adapt the fixture namespace or allowed mutation/proof-stripping scope to Metatheory only.')
    return ('documentation', 'Describe the new Metatheory implementation and its local modules.')


def controls(source):
    tree = ast.parse(source)
    function = next(n for n in tree.body if isinstance(n, ast.FunctionDef) and n.name == 'cases')
    expression = next(n.value for n in function.body if isinstance(n, ast.Return))
    assert isinstance(expression, ast.List)
    result = []
    for entry in expression.elts:
        fields = {k.value: v for k, v in zip(entry.keys, entry.values) if isinstance(k, ast.Constant)}
        result.append({'name': ast.literal_eval(fields['name']), 'exit': ast.literal_eval(fields['exit'])})
    assert len(result) == len({c['name'] for c in result}) == 65
    assert Counter(c['exit'] for c in result) == {0: 10, 1: 5, 3: 50}
    return result


def main():
    occurrences, inputs, adaptations, sources = [], [], [], {}
    for path in FILES:
        data, bound = binding(path)
        inputs.append(bound)
        source = data.decode('utf-8')
        sources[path] = source
        adapted = PATTERN.sub(lambda m: REPLACEMENTS[m.group()], source)
        ast.parse(source)
        ast.parse(adapted)
        assert not PATTERN.search(adapted)
        for match in PATTERN.finditer(source):
            start = source.rfind('\n', 0, match.start()) + 1
            end = source.find('\n', match.end())
            end = len(source) if end < 0 else end
            line = source[start:end]
            category, rationale = reason(line)
            occurrences.append({
                'id': f'L{len(occurrences) + 1:03}', 'file': path,
                'source_sha256': bound['sha256'],
                'line': source.count('\n', 0, match.start()) + 1,
                'column': match.start() - start + 1,
                'byte_column': len(source[start:match.start()].encode()) + 1,
                'character_offset': match.start(), 'byte_offset': len(source[:match.start()].encode()),
                'matched_literal': match.group(), 'source_line': line,
                'source_line_sha256': sha(line.encode()), 'decision': 'rename',
                'replacement': REPLACEMENTS[match.group()], 'category': category, 'rationale': rationale,
                'replacement_line': PATTERN.sub(lambda m: REPLACEMENTS[m.group()], line),
            })
        adaptations.append({'source': path, 'planned_destination': PATTERN.sub('metatheory', path),
                            'planned_text_sha256': sha(adapted.encode()),
                            'planned_text_python_ast_parse': 'PASS',
                            'remaining_case_insensitive_atomic_occurrences': 0,
                            'adapted_script_written_or_executed': False})
    spec_data, spec_bound = binding(SPEC)
    old_spec = json.loads(spec_data)
    assert old_spec['schema_version'] == 1 and len(old_spec['mutations']) == 18
    inherited = controls(sources[FILES[1]])
    planned = [{**c, 'name': PATTERN.sub('metatheory', c['name'])} for c in inherited]
    required = {
        'lowercase_case_declaration_and_verification_tuple': ('discovered-atomic-dependency', 2),
        'exact_error_one_literal': ('error: Atomic runtime comparisons failed: 1', 1),
        'manifest_audit_root': ("'audit_root': 'DefiKernel.Atomic.Audit'", 1),
        'manifest_scope_description': ('Atomic proof tails excluded', 1),
        'default_driver_path': ('scripts/check_atomic_mutations.py', 1),
        'extra_source_path': ('lean/DefiKernel/Atomic/SplitComputation.lean', 1),
    }
    required_coverage = {}
    for label, (needle, expected) in required.items():
        found = [o['id'] for o in occurrences if needle in o['source_line']]
        assert len(found) == expected, (label, found)
        required_coverage[label] = {'source_literal': needle, 'occurrence_ids': found,
                                    'expected_occurrences': expected, 'status': 'PASS'}
    assert len(occurrences) == sum(len(list(PATTERN.finditer(s))) for s in sources.values())
    result = {
        'schema_version': 1, 'status': 'AUTHOR_PLANNING_INVENTORY_ONLY',
        'scope': 'Exhaustive case-insensitive literal Atomic substrings in both accepted predecessor scripts. No runtime implementation, test execution, or planning acceptance.',
        'accepted_predecessor_revision': ACCEPTED, 'planning_revision': PLANNING,
        'generator': {'path': str(Path(__file__).resolve().relative_to(REPO)),
                      'sha256': sha(Path(__file__).read_bytes())},
        'reproduce_command': 'python3 review/semantic-kernel/sprint9/planning/build-runner-literal-map.py',
        'position_convention': 'One-based line/Unicode and UTF-8 byte columns; zero-based offsets. Source-line hashes exclude newline. Each substring match gets a separate record, including two matches on driver line 139.',
        'replacement_policy': REPLACEMENTS, 'keep_decisions': [],
        'keep_rationale': 'No literal in these two scripts identifies historical evidence that the new driver must retain; all identify the old namespace, protocol, fixture, path, case, or description.',
        'inputs': inputs, 'adaptations': adaptations,
        'historical_spec': {**spec_bound, 'schema_version': old_spec['schema_version'],
                            'mutation_count': len(old_spec['mutations']), 'modules': old_spec['modules'],
                            'decision': 'keep historical file and bytes unchanged; use as schema predecessor only',
                            'planned_new_spec_path': 'mutations/metatheory.json',
                            'new_spec_requires_fourteen_actual_Metatheory_edits': True},
        'counts': {'total': len(occurrences), 'rename': len(occurrences), 'keep': 0,
                   'by_file': dict(Counter(o['file'] for o in occurrences)),
                   'by_literal': dict(Counter(o['matched_literal'] for o in occurrences))},
        'required_coverage': required_coverage, 'occurrences': occurrences,
        'control_inventory': {'method': 'Read cases() list via Python AST; no import or execution.',
                              'count': 65, 'exit_counts': {'0': 10, '1': 5, '3': 50},
                              'predecessor': inherited, 'planned': planned,
                              'changed_names': [{'old': a['name'], 'new': b['name']}
                                                for a, b in zip(inherited, planned) if a != b]},
    }
    output = HERE / 'runner-literal-adaptation-map.json'
    output.write_text(json.dumps(result, indent=2, ensure_ascii=False) + '\n')
    print(json.dumps({'output': str(output.relative_to(REPO)), 'sha256': sha(output.read_bytes()),
                      'counts': result['counts'], 'controls': 65}, sort_keys=True))


if __name__ == '__main__':
    main()


===== INPUT review/semantic-kernel/sprint9/planning/runner-adaptation-map.json ORIGINAL_SHA256 2b55949ea78327a8c5ed2b598fbff9a2131f363fbc71b62812153a0bfd61d29a RENDERED_SHA256 2b55949ea78327a8c5ed2b598fbff9a2131f363fbc71b62812153a0bfd61d29a =====
{
  "kind": "planned-not-implemented",
  "accepted_driver": "scripts/check_atomic_mutations.py",
  "accepted_driver_sha256": "ab64b7681be152bedc0baf9cc0703fd0cbcd82df79c3fb887be9959a41810007",
  "accepted_harness": "scripts/test_atomic_mutation_runner.py",
  "accepted_harness_sha256": "dc539d354e1c9c7a3f3ccc7278b3d223fd4c015ba842cd4154930d2108e4e662",
  "mapping": [
    {
      "surface": "Driver/default harness path",
      "accepted_old": "`scripts/check_atomic_mutations.py`",
      "planned_new": "`scripts/check_metatheory_mutations.py`"
    },
    {
      "surface": "Harness path",
      "accepted_old": "`scripts/test_atomic_mutation_runner.py`",
      "planned_new": "`scripts/test_metatheory_mutation_runner.py`"
    },
    {
      "surface": "Explicit `--spec` path (driver has no default)",
      "accepted_old": "`review/semantic-kernel/sprint8/mutation-spec.json`",
      "planned_new": "`mutations/metatheory.json`"
    },
    {
      "surface": "Scoped-module regex",
      "accepted_old": "`DefiKernel\\.Atomic(?:\\.[A-Za-z][A-Za-z0-9]*)+`",
      "planned_new": "`DefiKernel\\.Metatheory(?:\\.[A-Za-z][A-Za-z0-9]*)+`"
    },
    {
      "surface": "Proof-trimming prefix",
      "accepted_old": "`DefiKernel.Atomic.`",
      "planned_new": "`DefiKernel.Metatheory.`"
    },
    {
      "surface": "Required audit root",
      "accepted_old": "`DefiKernel.Atomic.Audit`",
      "planned_new": "`DefiKernel.Metatheory.Audit`"
    },
    {
      "surface": "Missing-root error",
      "accepted_old": "`missing Atomic audit root`",
      "planned_new": "`missing Metatheory audit root`"
    },
    {
      "surface": "Proof-suffix closure regex",
      "accepted_old": "`\\n(end DefiKernel\\.Atomic(?:\\.[A-Za-z][A-Za-z0-9]*)*)\\s*$`",
      "planned_new": "`\\n(end DefiKernel\\.Metatheory(?:\\.[A-Za-z][A-Za-z0-9]*)*)\\s*$`"
    },
    {
      "surface": "Exact failed-comparison message",
      "accepted_old": "`Atomic runtime comparisons failed: N`",
      "planned_new": "`Metatheory runtime comparisons failed: N`"
    },
    {
      "surface": "Parsed Lean error line",
      "accepted_old": "`error: Atomic runtime comparisons failed: N`",
      "planned_new": "`error: Metatheory runtime comparisons failed: N`"
    },
    {
      "surface": "Empty/duplicate messages",
      "accepted_old": "`Atomic runtime comparisons empty`; `Atomic runtime comparison names are duplicated`",
      "planned_new": "`Metatheory runtime comparisons empty`; `Metatheory runtime comparison names are duplicated`"
    },
    {
      "surface": "Input/split/absent fixture modules",
      "accepted_old": "`DefiKernel.Atomic.{RunnerInput,SplitComputation,Absent}`",
      "planned_new": "`DefiKernel.Metatheory.{RunnerInput,SplitComputation,Absent}`"
    },
    {
      "surface": "Fixture namespace and paths",
      "accepted_old": "`DefiKernel.Atomic`, `lean/DefiKernel/Atomic/`",
      "planned_new": "`DefiKernel.Metatheory`, `lean/DefiKernel/Metatheory/`"
    },
    {
      "surface": "Production fixture namespace",
      "accepted_old": "`DefiKernel.Atomic.Audit`",
      "planned_new": "`DefiKernel.Metatheory.Audit`"
    },
    {
      "surface": "Imported dependency fixture",
      "accepted_old": "`DefiKernel.Interleaving.RunnerDependency`",
      "planned_new": "unchanged: remains outside the trimmed prefix"
    },
    {
      "surface": "Nonkernel dependency fixture",
      "accepted_old": "`SharedFixture`",
      "planned_new": "unchanged"
    },
    {
      "surface": "Invalid-scope fixture",
      "accepted_old": "`DefiKernel.Composition.RunnerInput`",
      "planned_new": "unchanged: still invalid scoped root"
    },
    {
      "surface": "Dependency discovery case",
      "accepted_old": "`discovered-atomic-dependency`",
      "planned_new": "`discovered-metatheory-dependency`"
    }
  ],
  "control_provenance": {
    "base": 52,
    "base_includes": "runtime-definition-after-proof-boundary",
    "new_proof_tail": 11,
    "all_proof_tail_related": 12,
    "production_forms": 2,
    "total": 65
  },
  "limits_seconds": {
    "runner_each_Lean_Git_command": 600,
    "harness_each_runner_subprocess": 1500
  },
  "timeout_classification": "blocked exit3, no semantic detection",
  "wall_time": "required actual monotonic per command/case/variant at execution; not yet measured for new Metatheory"
}


===== INPUT review/semantic-kernel/sprint9/planning/author-validation.json ORIGINAL_SHA256 ed43d384e35fdc5a1381cb7eaa3696afd82f6e1a85ad9a04f756748869b01c13 RENDERED_SHA256 ed43d384e35fdc5a1381cb7eaa3696afd82f6e1a85ad9a04f756748869b01c13 =====
{
  "status": "author-planning-validation-passed-independent-gates-pending",
  "started_utc": "2026-09-07T16:59:59.237169+00:00",
  "finished_utc": "2026-09-07T17:00:00.748255+00:00",
  "counts": {
    "capabilities": 4,
    "requirements": 17,
    "scenarios": 55,
    "tasks": 35,
    "unchecked_tasks": 35,
    "planned_mutants": 14,
    "inspected_cli_controls": 65
  },
  "checks": {
    "strict_openspec_exit_zero": true,
    "all_task_checkboxes_unchecked": true,
    "every_requirement_has_scenarios": true,
    "every_scenario_has_when_then": true,
    "every_scenario_has_planned_task_and_module": true,
    "every_task_is_covered": true,
    "fourteen_concrete_runtime_mutants": true,
    "actual_current_control_catalog_has65": true,
    "metatheory_source_absent": true,
    "planning_inputs_unchanged_during_validation": true,
    "required_comparator_conjuncts_local": true,
    "shared_identity_instances_are_binders": true,
    "mutation_timeout_and_import_discipline_explicit": true,
    "runner_namespace_root_regex_error_fixture_map_complete": true,
    "observer_synthetic_classification_explicit": true,
    "proof_tail_provenance12_related_cases": true
  },
  "commands": [
    {
      "argv": [
        "/home/charl/.local/lib/node_modules/@fission-ai/openspec/bin/openspec.js",
        "validate",
        "operational-continuation-congruence",
        "--strict"
      ],
      "cwd": "/home/charl/defiformal",
      "started_utc": "2026-09-07T16:59:59.237254+00:00",
      "finished_utc": "2026-09-07T16:59:59.983057+00:00",
      "exit": 0,
      "stdout": "strict-validation.stdout",
      "stdout_sha256": "b98f08dd3e3d55cccb24c0629912a3b1f5fec4912c49c389fa2c945ff8ba5984",
      "stderr": "strict-validation.stderr",
      "stderr_sha256": "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"
    },
    {
      "argv": [
        "/home/charl/.local/lib/node_modules/@fission-ai/openspec/bin/openspec.js",
        "status",
        "--change",
        "operational-continuation-congruence",
        "--json"
      ],
      "cwd": "/home/charl/defiformal",
      "started_utc": "2026-09-07T16:59:59.983129+00:00",
      "finished_utc": "2026-09-07T17:00:00.702092+00:00",
      "exit": 0,
      "stdout": "status.stdout",
      "stdout_sha256": "16c3364d61e54232250d8a13f45655576754d14b1774b7493032f46320983ec8",
      "stderr": "status.stderr",
      "stderr_sha256": "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"
    }
  ],
  "plan_bindings": {
    "openspec/changes/operational-continuation-congruence/proposal.md": {
      "sha256": "2a4b3b4c7beeb21ddd52b8d746c5d2c47fe2cfc9f1c7b50b362cfeaa2b620499",
      "bytes": 3737
    },
    "openspec/changes/operational-continuation-congruence/design.md": {
      "sha256": "5e2d9b9a3c2102b18bd5d2997c9878dba589288523d5eb1ddfa92cc707e3860d",
      "bytes": 30834
    },
    "openspec/changes/operational-continuation-congruence/tasks.md": {
      "sha256": "d0e54612901526351b2a73879e7a84b0f5f8458ac52fc6340c5cfb60b8d8af9b",
      "bytes": 13697
    },
    "openspec/changes/operational-continuation-congruence/specs/configuration-congruence/spec.md": {
      "sha256": "e9d7449a607cbd2b3db4796a9654a642a0976995467ece59aef727acbe5861f6",
      "bytes": 5703
    },
    "openspec/changes/operational-continuation-congruence/specs/continuation-observation/spec.md": {
      "sha256": "e131e95c149e0ae6ac722f2911f8644d90a9bea0f6d97e6bd62b10c0dfd67ebe",
      "bytes": 5000
    },
    "openspec/changes/operational-continuation-congruence/specs/metatheory-regression-evidence/spec.md": {
      "sha256": "a41f7567d8bf7b625b3262f4f0dda4adb23f64ca9402e6f249cbf013b3cd1438",
      "bytes": 6810
    },
    "openspec/changes/operational-continuation-congruence/specs/sequential-group-execution/spec.md": {
      "sha256": "7fa56f3c6f24be86090103d19018637efb5968a3951565b87d35498754ac3d67",
      "bytes": 4188
    },
    "wiki-llm/sprint-9-operational-continuation-congruence.md": {
      "sha256": "8459c1d24af747ce0fd4cb6095a154cb32d66bc16a748735c897146eef1f28c1",
      "bytes": 9940
    },
    "AGENTS.md": {
      "sha256": "60c7989fce2d680d68ac18bb970a79de65380aef9a44e70aa7205180c2d15a34",
      "bytes": 3171
    },
    "wiki-llm/operational-metatheory-planning-draft.md": {
      "sha256": "9140d371503d1f65c77e4bb991a889a8aff70f48520b7ee9d56d0e86f977ae17",
      "bytes": 29849
    },
    "wiki-llm/sprint-10-operational-interface-bindings-outline.md": {
      "sha256": "775e6127b4e31720d201664e3cc185131f4a88e4606230c1314fafb1166f0650",
      "bytes": 16259
    }
  },
  "accepted_source_candidate": "99e2e2c61a1a3c5249026921efdc6cd41ac8f21d",
  "source_refresh_required": false,
  "planning_freeze_pending": true,
  "inspected_semantic_source_bindings": [
    {
      "path": "lean/DefiKernel/Composition/Execution.lean",
      "sha256": "34ac2f2185434d2fc8931b10f3688d909cc984e4e24e16e26c2d115b6fe13602",
      "accepted_source_git_blob": "f94f22503551dc7cbc965459626a33435ac512cc",
      "current_bytes_equal_accepted_candidate": true
    },
    {
      "path": "lean/DefiKernel/Composition/Sequence.lean",
      "sha256": "32bcdbbce182bf9d494dab76a8a114f9e238f92564ef86e7cab2cd123bc0b729",
      "accepted_source_git_blob": "ffdfd5b29d8123c2f49cc2262fc199100794074f",
      "current_bytes_equal_accepted_candidate": true
    },
    {
      "path": "lean/DefiKernel/Composition/Interfaces.lean",
      "sha256": "4f2a32854b298ca5399eb0aa38bb16e892312517ae4f3a0e49e4bfead369f5fe",
      "accepted_source_git_blob": "a45abc9035cd5882f58814c089ce151f0f2bbc51",
      "current_bytes_equal_accepted_candidate": true
    },
    {
      "path": "lean/DefiKernel/Typed/Authority.lean",
      "sha256": "dfd2c140f511144e9928ed4f5ed1db9ee2b56cada1342500d2e60c33ef9a0cdb",
      "accepted_source_git_blob": "f7fb9de0cb97cc9e003bf487d742ec902250efc9",
      "current_bytes_equal_accepted_candidate": true
    },
    {
      "path": "lean/DefiKernel/Typed/Transition.lean",
      "sha256": "73f264636236219e45720a531209f8c7ed8f5ee3f615fa34d58bc5596c4499d2",
      "accepted_source_git_blob": "344109d8e783c2b80f1385fa39f0a4b923b0d07c",
      "current_bytes_equal_accepted_candidate": true
    },
    {
      "path": "lean/DefiKernel/Parallel/Compatibility.lean",
      "sha256": "4459fa2b4a4f1f695d3856cb67a46a7c9df86a90f924be8bd26f55e99ba54243",
      "accepted_source_git_blob": "db305a859e7cf155b991f20915051f41e289a2fc",
      "current_bytes_equal_accepted_candidate": true
    },
    {
      "path": "lean/DefiKernel/Parallel/Observation.lean",
      "sha256": "38018fbcfb37c08181fbce37b75050077c3dc19d8bee6c0975b7898447ccb84f",
      "accepted_source_git_blob": "015857c7ac8c13af445adbc5145e0ab7f932b4fb",
      "current_bytes_equal_accepted_candidate": true
    },
    {
      "path": "lean/DefiKernel/Parallel/Execution.lean",
      "sha256": "a4a863d71ddfc5fa057fb5b4c79021aa8d79720710ee7bd70f97f34d01e60089",
      "accepted_source_git_blob": "0ae8a088d63ff32b788df65b8d50717662528dfc",
      "current_bytes_equal_accepted_candidate": true
    },
    {
      "path": "lean/DefiKernel/Interleaving/Execution.lean",
      "sha256": "8a39ccbaf6cf03479a5b16a156c52a2b6f5bd97a9198b633be27be3b1b899d21",
      "accepted_source_git_blob": "3b37ded4a3fd02b4283ed7d0a9ad7e9ccbde81c3",
      "current_bytes_equal_accepted_candidate": true
    },
    {
      "path": "lean/DefiKernel/Atomic/Execution.lean",
      "sha256": "c9cee888746a2795ae2ddae59d9ffb27ed73339ed5a7ca0737be922af6d96b55",
      "accepted_source_git_blob": "63fbf541b26b660ac5e7daeb96c296ce952287a5",
      "current_bytes_equal_accepted_candidate": true
    },
    {
      "path": "lean/DefiKernel/Atomic/Policy.lean",
      "sha256": "5b643cbb1b1263ffacb20892afe3f9ec1067191e733f08c3f4040bbe17fa2612",
      "accepted_source_git_blob": "b036e4b4845de910f98d6cb4cb76d9911e78fcec",
      "current_bytes_equal_accepted_candidate": true
    },
    {
      "path": "lean/DefiKernel/Atomic/Observation.lean",
      "sha256": "3e0ab8f53d0bcddc86543207cce4ae832293836e9a301204b090b23d6ccd0cc5",
      "accepted_source_git_blob": "f6f5ed78b2a3f01da5a22ddcae2d4eaadc8fd67b",
      "current_bytes_equal_accepted_candidate": true
    }
  ],
  "inherited_control_source": {
    "path": "scripts/test_atomic_mutation_runner.py",
    "sha256": "dc539d354e1c9c7a3f3ccc7278b3d223fd4c015ba842cd4154930d2108e4e662",
    "count": 65,
    "status": "bytes equal accepted99 source and fresh baseline control source; Sprint9 execution remains pending",
    "git_blob": "1a67e7bd21699fc62ee06b4006e850e4955079c3"
  },
  "tools": [
    {
      "path": "/home/charl/.local/lib/node_modules/@fission-ai/openspec/bin/openspec.js",
      "sha256": "ca136f0e9fd4951dcf93d8ed729ebc97b2d97d3980cd9dc9d42fc80e32e797c6"
    },
    {
      "path": "/usr/bin/python3.14",
      "sha256": "b8d8288faefdd300201f43fcf00f6f539a27218eeed3a3dff5ab10b9c4c99700"
    }
  ],
  "gates": {
    "sprint8_final_accepted_delivery": "passed; accepted source99e2e2c, source/evidence2c038094, verified archive9501f0a4; exact full IDs in dependency binding",
    "independent_gpt6_planning": "r1/r2 ACCEPT WITH LIMITATIONS by nonauthor GPT-6; focused r3 review pending",
    "historical_native_opus_planning": "r1/r2 ACCEPT WITH LIMITATIONS, claude-opus-5; three r2 runner clarifications addressed",
    "native_fable_planning": "latest user selects Fable5.1 medium; same-candidate r3 review pending",
    "fresh_implementation_baseline": "passed at accepted99 source:14 Lean commands and13 Python suites; separate prerequisite evidence, no task checkbox inferred",
    "implementation": "not started",
    "production_mutations_and_cli_controls": "not run for Sprint9",
    "native_result_and_evidence_audits": "not performed",
    "delivery": "not performed"
  },
  "reviewer_policy": {
    "authority": "AGENTS.md reviewer change2026-09-07",
    "planning": [
      "nonauthor GPT-6",
      "native Fable 5.1"
    ],
    "substantive_results": [
      "native Grok",
      "native Fable 5.1"
    ],
    "requested_native_model_alias": "claude-fable-5-1[1m]",
    "requested_effort": "medium",
    "actual_returned_model_identity": "historical r1/r2 native Opus reports claude-opus-5; focused r3 invocation and returned identity pending",
    "historical_fable_identity": "preserved",
    "freeze": "r1/r2 frozen/reviewed; three remaining runner clarifications addressed, focused r3 freeze and reviews pending"
  },
  "dependency_evidence": {
    "path": "review/semantic-kernel/sprint9/planning/dependency-baseline-binding.json",
    "sha256": "007f2a47ef33f93e8bf7ae9ab6ed1318a1a5b54e0e50d6510fba809393eb653d",
    "accepted_source_candidate": "99e2e2c61a1a3c5249026921efdc6cd41ac8f21d",
    "source_evidence_commit": "2c038094c031723f3ade35d8b3f506ccff5b1d3b",
    "archive_metadata_commit": "9501f0a4f0480b2a42ff197907d548cf0c610773",
    "baseline": {
      "actual_source_candidate": "99e2e2c61a1a3c5249026921efdc6cd41ac8f21d",
      "lean_commands": 14,
      "python_suites": 13,
      "lean_source_inputs": 104,
      "python_source_inputs": 148,
      "python_saved_evidence_assertions": 3382,
      "python_file_hashes_checked": 2703,
      "python_symlink_targets_checked": 9,
      "all_commands_passed": true,
      "metadata_correction": "baseline/python/metadata-correction.json",
      "final_metadata_hashes_checked": true,
      "all65_cli_recorded_paths_hashes_outputs_checked": true,
      "note": "Existing completed baseline executions reused at their actual99 source identity. This author refresh reruns no suites.",
      "gate_evidence": "baseline/gate-evidence.json"
    }
  },
  "authorship": "Requested GPT-6 stock harness, targeted author remediation only; independent model/build telemetry unavailable. No Foreman, implementation or mutation runs in this author check. Historical native reviews remain separate recorded invocations; current GPT6/Fable5.1 medium r3 reviews remain pending."
}


===== INPUT review/semantic-kernel/sprint9/planning/scenario-planning-map.json ORIGINAL_SHA256 47b77818d62195dcde3e5183b264b798283e65689a92c8f8612c58ed1068cf03 RENDERED_SHA256 47b77818d62195dcde3e5183b264b798283e65689a92c8f8612c58ed1068cf03 =====
{
  "schema_version": 1,
  "kind": "author-planning-map",
  "counts": {
    "capabilities": 4,
    "requirements": 17,
    "scenarios": 55,
    "tasks": 35,
    "unchecked_tasks": 35,
    "planned_mutants": 14,
    "inspected_cli_controls": 65
  },
  "requirements": [
    {
      "capability": "configuration-congruence",
      "name": "Explicit configuration agreement",
      "source": "openspec/changes/operational-continuation-congruence/specs/configuration-congruence/spec.md",
      "tasks": [
        "4.1",
        "4.3",
        "6.2"
      ]
    },
    {
      "capability": "configuration-congruence",
      "name": "Exact single-step congruence",
      "source": "openspec/changes/operational-continuation-congruence/specs/configuration-congruence/spec.md",
      "tasks": [
        "4.2",
        "4.3"
      ]
    },
    {
      "capability": "configuration-congruence",
      "name": "Supported execution lifting",
      "source": "openspec/changes/operational-continuation-congruence/specs/configuration-congruence/spec.md",
      "tasks": [
        "4.4",
        "5.1",
        "5.2",
        "5.3",
        "5.4",
        "6.2"
      ]
    },
    {
      "capability": "configuration-congruence",
      "name": "Configuration counterexamples",
      "source": "openspec/changes/operational-continuation-congruence/specs/configuration-congruence/spec.md",
      "tasks": [
        "4.5",
        "6.2",
        "6.4"
      ]
    },
    {
      "capability": "continuation-observation",
      "name": "Exact cursor observations",
      "source": "openspec/changes/operational-continuation-congruence/specs/continuation-observation/spec.md",
      "tasks": [
        "3.1",
        "6.3"
      ]
    },
    {
      "capability": "continuation-observation",
      "name": "Observation equivalence laws",
      "source": "openspec/changes/operational-continuation-congruence/specs/continuation-observation/spec.md",
      "tasks": [
        "3.2",
        "6.3"
      ]
    },
    {
      "capability": "continuation-observation",
      "name": "Restricted contextual substitution",
      "source": "openspec/changes/operational-continuation-congruence/specs/continuation-observation/spec.md",
      "tasks": [
        "3.3",
        "3.4"
      ]
    },
    {
      "capability": "continuation-observation",
      "name": "Necessary continuation premises",
      "source": "openspec/changes/operational-continuation-congruence/specs/continuation-observation/spec.md",
      "tasks": [
        "3.5",
        "6.4"
      ]
    },
    {
      "capability": "metatheory-regression-evidence",
      "name": "Planning and baseline gates",
      "source": "openspec/changes/operational-continuation-congruence/specs/metatheory-regression-evidence/spec.md",
      "tasks": [
        "1.1",
        "1.2",
        "1.3"
      ]
    },
    {
      "capability": "metatheory-regression-evidence",
      "name": "Independent operational evidence",
      "source": "openspec/changes/operational-continuation-congruence/specs/metatheory-regression-evidence/spec.md",
      "tasks": [
        "2.2",
        "6.1",
        "6.2",
        "6.3",
        "6.4"
      ]
    },
    {
      "capability": "metatheory-regression-evidence",
      "name": "Fourteen production mutations",
      "source": "openspec/changes/operational-continuation-congruence/specs/metatheory-regression-evidence/spec.md",
      "tasks": [
        "7.2",
        "7.3",
        "7.5"
      ]
    },
    {
      "capability": "metatheory-regression-evidence",
      "name": "Defensive runner controls",
      "source": "openspec/changes/operational-continuation-congruence/specs/metatheory-regression-evidence/spec.md",
      "tasks": [
        "7.1",
        "7.4",
        "7.5"
      ]
    },
    {
      "capability": "metatheory-regression-evidence",
      "name": "Imported audits and accepted delivery",
      "source": "openspec/changes/operational-continuation-congruence/specs/metatheory-regression-evidence/spec.md",
      "tasks": [
        "6.5",
        "8.1",
        "8.2",
        "8.3",
        "8.4"
      ]
    },
    {
      "capability": "sequential-group-execution",
      "name": "Recursive ordered execution",
      "source": "openspec/changes/operational-continuation-congruence/specs/sequential-group-execution/spec.md",
      "tasks": [
        "2.1",
        "2.2",
        "6.1"
      ]
    },
    {
      "capability": "sequential-group-execution",
      "name": "Refusal and absolute continuation",
      "source": "openspec/changes/operational-continuation-congruence/specs/sequential-group-execution/spec.md",
      "tasks": [
        "2.1",
        "2.4",
        "6.1"
      ]
    },
    {
      "capability": "sequential-group-execution",
      "name": "Actual flattening correspondence",
      "source": "openspec/changes/operational-continuation-congruence/specs/sequential-group-execution/spec.md",
      "tasks": [
        "2.3",
        "6.1"
      ]
    },
    {
      "capability": "sequential-group-execution",
      "name": "Sequential associativity scope",
      "source": "openspec/changes/operational-continuation-congruence/specs/sequential-group-execution/spec.md",
      "tasks": [
        "2.4",
        "6.4"
      ]
    }
  ],
  "scenarios": [
    {
      "id": "S9-001",
      "capability": "configuration-congruence",
      "requirement": "Explicit configuration agreement",
      "scenario": "Unrelated valid declarations",
      "when": "an unrelated operation/component is added while both catalogs remain valid and every supported lookup and administrator agrees",
      "then": "a nonempty supported old program retains exact behavior",
      "source": "openspec/changes/operational-continuation-congruence/specs/configuration-congruence/spec.md",
      "line": 11,
      "planned_tasks": [
        "4.1",
        "4.3",
        "6.2"
      ],
      "planned_modules": [
        "lean/DefiKernel/Metatheory/Configuration.lean",
        "lean/DefiKernel/Metatheory/ConfigurationGroups.lean",
        "lean/DefiKernel/Metatheory/OperatorLifting.lean",
        "lean/DefiKernel/Metatheory/Examples.lean",
        "lean/DefiKernel/Metatheory/Tests.lean"
      ],
      "status": "planned-not-implemented",
      "evidence_limits": "Coverage assignment is an author planning link, not a completed check or proof. The implementation map must replace it with actual exact declarations/runtime observations/artifacts."
    },
    {
      "id": "S9-002",
      "capability": "configuration-congruence",
      "requirement": "Explicit configuration agreement",
      "scenario": "Grant-only operation support",
      "when": "an issued grant references an operation that no invocation in the program calls",
      "then": "that operation remains in the explicit configuration support obligations",
      "source": "openspec/changes/operational-continuation-congruence/specs/configuration-congruence/spec.md",
      "line": 16,
      "planned_tasks": [
        "4.1",
        "4.3",
        "6.2"
      ],
      "planned_modules": [
        "lean/DefiKernel/Metatheory/Configuration.lean",
        "lean/DefiKernel/Metatheory/ConfigurationGroups.lean",
        "lean/DefiKernel/Metatheory/OperatorLifting.lean",
        "lean/DefiKernel/Metatheory/Examples.lean",
        "lean/DefiKernel/Metatheory/Tests.lean"
      ],
      "status": "planned-not-implemented",
      "evidence_limits": "Coverage assignment is an author planning link, not a completed check or proof. The implementation map must replace it with actual exact declarations/runtime observations/artifacts."
    },
    {
      "id": "S9-003",
      "capability": "configuration-congruence",
      "requirement": "Explicit configuration agreement",
      "scenario": "No certificate checker claim",
      "when": "a theorem is applied using configuration agreement and supported-program premises",
      "then": "the evidence records those premises rather than inventing a new runtime certificate or program-label checker",
      "source": "openspec/changes/operational-continuation-congruence/specs/configuration-congruence/spec.md",
      "line": 21,
      "planned_tasks": [
        "4.1",
        "4.3",
        "6.2"
      ],
      "planned_modules": [
        "lean/DefiKernel/Metatheory/Configuration.lean",
        "lean/DefiKernel/Metatheory/ConfigurationGroups.lean",
        "lean/DefiKernel/Metatheory/OperatorLifting.lean",
        "lean/DefiKernel/Metatheory/Examples.lean",
        "lean/DefiKernel/Metatheory/Tests.lean"
      ],
      "status": "planned-not-implemented",
      "evidence_limits": "Coverage assignment is an author planning link, not a completed check or proof. The implementation map must replace it with actual exact declarations/runtime observations/artifacts."
    },
    {
      "id": "S9-004",
      "capability": "configuration-congruence",
      "requirement": "Exact single-step congruence",
      "scenario": "Invoked success and refusal",
      "when": "the supported invocation succeeds or fails under the old configuration",
      "then": "the new result has the same world, request/evaluated receipt, outputs or exact failure reason",
      "source": "openspec/changes/operational-continuation-congruence/specs/configuration-congruence/spec.md",
      "line": 30,
      "planned_tasks": [
        "4.2",
        "4.3"
      ],
      "planned_modules": [
        "lean/DefiKernel/Metatheory/Configuration.lean",
        "lean/DefiKernel/Metatheory/ConfigurationGroups.lean",
        "lean/DefiKernel/Metatheory/OperatorLifting.lean",
        "lean/DefiKernel/Metatheory/Examples.lean",
        "lean/DefiKernel/Metatheory/Tests.lean"
      ],
      "status": "planned-not-implemented",
      "evidence_limits": "Coverage assignment is an author planning link, not a completed check or proof. The implementation map must replace it with actual exact declarations/runtime observations/artifacts."
    },
    {
      "id": "S9-005",
      "capability": "configuration-congruence",
      "requirement": "Exact single-step congruence",
      "scenario": "Issue and revoke",
      "when": "supported administration executes against the same current complete store",
      "then": "fresh IDs, tombstones, authorization results and all administrative refusals are equal",
      "source": "openspec/changes/operational-continuation-congruence/specs/configuration-congruence/spec.md",
      "line": 35,
      "planned_tasks": [
        "4.2",
        "4.3"
      ],
      "planned_modules": [
        "lean/DefiKernel/Metatheory/Configuration.lean",
        "lean/DefiKernel/Metatheory/ConfigurationGroups.lean",
        "lean/DefiKernel/Metatheory/OperatorLifting.lean",
        "lean/DefiKernel/Metatheory/Examples.lean",
        "lean/DefiKernel/Metatheory/Tests.lean"
      ],
      "status": "planned-not-implemented",
      "evidence_limits": "Coverage assignment is an author planning link, not a completed check or proof. The implementation map must replace it with actual exact declarations/runtime observations/artifacts."
    },
    {
      "id": "S9-006",
      "capability": "configuration-congruence",
      "requirement": "Exact single-step congruence",
      "scenario": "Absent old lookup",
      "when": "both agreeing supported lookup results are absent",
      "then": "both executions return the same actual unknown-operation or interface refusal",
      "source": "openspec/changes/operational-continuation-congruence/specs/configuration-congruence/spec.md",
      "line": 40,
      "planned_tasks": [
        "4.2",
        "4.3"
      ],
      "planned_modules": [
        "lean/DefiKernel/Metatheory/Configuration.lean",
        "lean/DefiKernel/Metatheory/ConfigurationGroups.lean",
        "lean/DefiKernel/Metatheory/OperatorLifting.lean",
        "lean/DefiKernel/Metatheory/Examples.lean",
        "lean/DefiKernel/Metatheory/Tests.lean"
      ],
      "status": "planned-not-implemented",
      "evidence_limits": "Coverage assignment is an author planning link, not a completed check or proof. The implementation map must replace it with actual exact declarations/runtime observations/artifacts."
    },
    {
      "id": "S9-007",
      "capability": "configuration-congruence",
      "requirement": "Supported execution lifting",
      "scenario": "Unreachable static suffix",
      "when": "an early invocation refuses before a later submitted invocation",
      "then": "the later invocation remains covered by the static support premise and structural admission retains its original precedence",
      "source": "openspec/changes/operational-continuation-congruence/specs/configuration-congruence/spec.md",
      "line": 49,
      "planned_tasks": [
        "4.4",
        "5.1",
        "5.2",
        "5.3",
        "5.4",
        "6.2"
      ],
      "planned_modules": [
        "lean/DefiKernel/Metatheory/Configuration.lean",
        "lean/DefiKernel/Metatheory/ConfigurationGroups.lean",
        "lean/DefiKernel/Metatheory/OperatorLifting.lean",
        "lean/DefiKernel/Metatheory/Examples.lean",
        "lean/DefiKernel/Metatheory/Tests.lean"
      ],
      "status": "planned-not-implemented",
      "evidence_limits": "Coverage assignment is an author planning link, not a completed check or proof. The implementation map must replace it with actual exact declarations/runtime observations/artifacts."
    },
    {
      "id": "S9-008",
      "capability": "configuration-congruence",
      "requirement": "Supported execution lifting",
      "scenario": "Sequential administration lifting",
      "when": "issue, invocation and revoke cross nested group boundaries",
      "then": "both configurations return identical complete cursors",
      "source": "openspec/changes/operational-continuation-congruence/specs/configuration-congruence/spec.md",
      "line": 54,
      "planned_tasks": [
        "4.4",
        "5.1",
        "5.2",
        "5.3",
        "5.4",
        "6.2"
      ],
      "planned_modules": [
        "lean/DefiKernel/Metatheory/Configuration.lean",
        "lean/DefiKernel/Metatheory/ConfigurationGroups.lean",
        "lean/DefiKernel/Metatheory/OperatorLifting.lean",
        "lean/DefiKernel/Metatheory/Examples.lean",
        "lean/DefiKernel/Metatheory/Tests.lean"
      ],
      "status": "planned-not-implemented",
      "evidence_limits": "Coverage assignment is an author planning link, not a completed check or proof. The implementation map must replace it with actual exact declarations/runtime observations/artifacts."
    },
    {
      "id": "S9-009",
      "capability": "configuration-congruence",
      "requirement": "Supported execution lifting",
      "scenario": "Parallel and interleaved lifting",
      "when": "supported invocation-only branches use their existing parallel or scheduled shared execution",
      "then": "both admission results and executed results are equal, including exact refusals and histories",
      "source": "openspec/changes/operational-continuation-congruence/specs/configuration-congruence/spec.md",
      "line": 59,
      "planned_tasks": [
        "4.4",
        "5.1",
        "5.2",
        "5.3",
        "5.4",
        "6.2"
      ],
      "planned_modules": [
        "lean/DefiKernel/Metatheory/Configuration.lean",
        "lean/DefiKernel/Metatheory/ConfigurationGroups.lean",
        "lean/DefiKernel/Metatheory/OperatorLifting.lean",
        "lean/DefiKernel/Metatheory/Examples.lean",
        "lean/DefiKernel/Metatheory/Tests.lean"
      ],
      "status": "planned-not-implemented",
      "evidence_limits": "Coverage assignment is an author planning link, not a completed check or proof. The implementation map must replace it with actual exact declarations/runtime observations/artifacts."
    },
    {
      "id": "S9-010",
      "capability": "configuration-congruence",
      "requirement": "Supported execution lifting",
      "scenario": "Atomic lifting",
      "when": "the same supported atomic request commits, refuses admission or aborts",
      "then": "both configurations preserve that exact result, supplied schedule, diagnostic table and public publication behavior",
      "source": "openspec/changes/operational-continuation-congruence/specs/configuration-congruence/spec.md",
      "line": 64,
      "planned_tasks": [
        "4.4",
        "5.1",
        "5.2",
        "5.3",
        "5.4",
        "6.2"
      ],
      "planned_modules": [
        "lean/DefiKernel/Metatheory/Configuration.lean",
        "lean/DefiKernel/Metatheory/ConfigurationGroups.lean",
        "lean/DefiKernel/Metatheory/OperatorLifting.lean",
        "lean/DefiKernel/Metatheory/Examples.lean",
        "lean/DefiKernel/Metatheory/Tests.lean"
      ],
      "status": "planned-not-implemented",
      "evidence_limits": "Coverage assignment is an author planning link, not a completed check or proof. The implementation map must replace it with actual exact declarations/runtime observations/artifacts."
    },
    {
      "id": "S9-011",
      "capability": "configuration-congruence",
      "requirement": "Configuration counterexamples",
      "scenario": "Changed old registry",
      "when": "an old supported template changes guard or compatible delta/write behavior while signature/output-domain contracts and remaining applicable premises hold",
      "then": "a concrete old invocation yields a different actual result",
      "source": "openspec/changes/operational-continuation-congruence/specs/configuration-congruence/spec.md",
      "line": 73,
      "planned_tasks": [
        "4.5",
        "6.2",
        "6.4"
      ],
      "planned_modules": [
        "lean/DefiKernel/Metatheory/Configuration.lean",
        "lean/DefiKernel/Metatheory/ConfigurationGroups.lean",
        "lean/DefiKernel/Metatheory/OperatorLifting.lean",
        "lean/DefiKernel/Metatheory/Examples.lean",
        "lean/DefiKernel/Metatheory/Tests.lean"
      ],
      "status": "planned-not-implemented",
      "evidence_limits": "Coverage assignment is an author planning link, not a completed check or proof. The implementation map must replace it with actual exact declarations/runtime observations/artifacts."
    },
    {
      "id": "S9-012",
      "capability": "configuration-congruence",
      "requirement": "Configuration counterexamples",
      "scenario": "Changed component declaration",
      "when": "an old component access or output declaration changes without preserving its complete lookup result while export/import/private-cell validity remains intact",
      "then": "a concrete old invocation yields a different access result or frozen output",
      "source": "openspec/changes/operational-continuation-congruence/specs/configuration-congruence/spec.md",
      "line": 78,
      "planned_tasks": [
        "4.5",
        "6.2",
        "6.4"
      ],
      "planned_modules": [
        "lean/DefiKernel/Metatheory/Configuration.lean",
        "lean/DefiKernel/Metatheory/ConfigurationGroups.lean",
        "lean/DefiKernel/Metatheory/OperatorLifting.lean",
        "lean/DefiKernel/Metatheory/Examples.lean",
        "lean/DefiKernel/Metatheory/Tests.lean"
      ],
      "status": "planned-not-implemented",
      "evidence_limits": "Coverage assignment is an author planning link, not a completed check or proof. The implementation map must replace it with actual exact declarations/runtime observations/artifacts."
    },
    {
      "id": "S9-013",
      "capability": "configuration-congruence",
      "requirement": "Configuration counterexamples",
      "scenario": "Invalid added catalog",
      "when": "a new duplicate or invalid component makes the complete new catalog invalid",
      "then": "new execution refuses configuration even when old referenced lookups remain unchanged",
      "source": "openspec/changes/operational-continuation-congruence/specs/configuration-congruence/spec.md",
      "line": 83,
      "planned_tasks": [
        "4.5",
        "6.2",
        "6.4"
      ],
      "planned_modules": [
        "lean/DefiKernel/Metatheory/Configuration.lean",
        "lean/DefiKernel/Metatheory/ConfigurationGroups.lean",
        "lean/DefiKernel/Metatheory/OperatorLifting.lean",
        "lean/DefiKernel/Metatheory/Examples.lean",
        "lean/DefiKernel/Metatheory/Tests.lean"
      ],
      "status": "planned-not-implemented",
      "evidence_limits": "Coverage assignment is an author planning link, not a completed check or proof. The implementation map must replace it with actual exact declarations/runtime observations/artifacts."
    },
    {
      "id": "S9-014",
      "capability": "configuration-congruence",
      "requirement": "Configuration counterexamples",
      "scenario": "Changed grant operation domain",
      "when": "the domain of a registry operation with no declaring catalog component changes, while invoked lookups and both catalog-validity checks still agree",
      "then": "actual issue success versus operation-domain refusal differs",
      "source": "openspec/changes/operational-continuation-congruence/specs/configuration-congruence/spec.md",
      "line": 88,
      "planned_tasks": [
        "4.5",
        "6.2",
        "6.4"
      ],
      "planned_modules": [
        "lean/DefiKernel/Metatheory/Configuration.lean",
        "lean/DefiKernel/Metatheory/ConfigurationGroups.lean",
        "lean/DefiKernel/Metatheory/OperatorLifting.lean",
        "lean/DefiKernel/Metatheory/Examples.lean",
        "lean/DefiKernel/Metatheory/Tests.lean"
      ],
      "status": "planned-not-implemented",
      "evidence_limits": "Coverage assignment is an author planning link, not a completed check or proof. The implementation map must replace it with actual exact declarations/runtime observations/artifacts."
    },
    {
      "id": "S9-015",
      "capability": "configuration-congruence",
      "requirement": "Configuration counterexamples",
      "scenario": "Changed trusted administrator",
      "when": "the relevant domain administrator changes",
      "then": "actual issue or revoke authorization differs",
      "source": "openspec/changes/operational-continuation-congruence/specs/configuration-congruence/spec.md",
      "line": 93,
      "planned_tasks": [
        "4.5",
        "6.2",
        "6.4"
      ],
      "planned_modules": [
        "lean/DefiKernel/Metatheory/Configuration.lean",
        "lean/DefiKernel/Metatheory/ConfigurationGroups.lean",
        "lean/DefiKernel/Metatheory/OperatorLifting.lean",
        "lean/DefiKernel/Metatheory/Examples.lean",
        "lean/DefiKernel/Metatheory/Tests.lean"
      ],
      "status": "planned-not-implemented",
      "evidence_limits": "Coverage assignment is an author planning link, not a completed check or proof. The implementation map must replace it with actual exact declarations/runtime observations/artifacts."
    },
    {
      "id": "S9-016",
      "capability": "configuration-congruence",
      "requirement": "Configuration counterexamples",
      "scenario": "Changed initial store",
      "when": "only the initial capability entries differ before authorized issue",
      "then": "the exact returned fresh ID differs, refuting a ledger-only extension premise",
      "source": "openspec/changes/operational-continuation-congruence/specs/configuration-congruence/spec.md",
      "line": 98,
      "planned_tasks": [
        "4.5",
        "6.2",
        "6.4"
      ],
      "planned_modules": [
        "lean/DefiKernel/Metatheory/Configuration.lean",
        "lean/DefiKernel/Metatheory/ConfigurationGroups.lean",
        "lean/DefiKernel/Metatheory/OperatorLifting.lean",
        "lean/DefiKernel/Metatheory/Examples.lean",
        "lean/DefiKernel/Metatheory/Tests.lean"
      ],
      "status": "planned-not-implemented",
      "evidence_limits": "Coverage assignment is an author planning link, not a completed check or proof. The implementation map must replace it with actual exact declarations/runtime observations/artifacts."
    },
    {
      "id": "S9-017",
      "capability": "continuation-observation",
      "requirement": "Exact cursor observations",
      "scenario": "Current world sensitivity",
      "when": "two cursors differ only at a current ledger cell",
      "then": "their observations differ",
      "source": "openspec/changes/operational-continuation-congruence/specs/continuation-observation/spec.md",
      "line": 11,
      "planned_tasks": [
        "3.1",
        "6.3"
      ],
      "planned_modules": [
        "lean/DefiKernel/Metatheory/Observation.lean",
        "lean/DefiKernel/Metatheory/Contexts.lean",
        "lean/DefiKernel/Metatheory/Examples.lean",
        "lean/DefiKernel/Metatheory/Tests.lean"
      ],
      "status": "planned-not-implemented",
      "evidence_limits": "Coverage assignment is an author planning link, not a completed check or proof. The implementation map must replace it with actual exact declarations/runtime observations/artifacts."
    },
    {
      "id": "S9-018",
      "capability": "continuation-observation",
      "requirement": "Exact cursor observations",
      "scenario": "Complete store sensitivity",
      "when": "two cursors have equal ledgers but different store entries or tombstones",
      "then": "their observations differ",
      "source": "openspec/changes/operational-continuation-congruence/specs/continuation-observation/spec.md",
      "line": 16,
      "planned_tasks": [
        "3.1",
        "6.3"
      ],
      "planned_modules": [
        "lean/DefiKernel/Metatheory/Observation.lean",
        "lean/DefiKernel/Metatheory/Contexts.lean",
        "lean/DefiKernel/Metatheory/Examples.lean",
        "lean/DefiKernel/Metatheory/Tests.lean"
      ],
      "status": "planned-not-implemented",
      "evidence_limits": "Coverage assignment is an author planning link, not a completed check or proof. The implementation map must replace it with actual exact declarations/runtime observations/artifacts."
    },
    {
      "id": "S9-019",
      "capability": "continuation-observation",
      "requirement": "Exact cursor observations",
      "scenario": "Qualified output sensitivity",
      "when": "otherwise equal cursors differ in frozen history value, unit, producer position or qualified key",
      "then": "their observations differ and history order remains significant",
      "source": "openspec/changes/operational-continuation-congruence/specs/continuation-observation/spec.md",
      "line": 21,
      "planned_tasks": [
        "3.1",
        "6.3"
      ],
      "planned_modules": [
        "lean/DefiKernel/Metatheory/Observation.lean",
        "lean/DefiKernel/Metatheory/Contexts.lean",
        "lean/DefiKernel/Metatheory/Examples.lean",
        "lean/DefiKernel/Metatheory/Tests.lean"
      ],
      "status": "planned-not-implemented",
      "evidence_limits": "Coverage assignment is an author planning link, not a completed check or proof. The implementation map must replace it with actual exact declarations/runtime observations/artifacts."
    },
    {
      "id": "S9-020",
      "capability": "continuation-observation",
      "requirement": "Exact cursor observations",
      "scenario": "Receipt sensitivity",
      "when": "otherwise equal event observations differ in invoked request, evaluated receipt, issue ID or revoke ID",
      "then": "their cursor observations differ",
      "source": "openspec/changes/operational-continuation-congruence/specs/continuation-observation/spec.md",
      "line": 26,
      "planned_tasks": [
        "3.1",
        "6.3"
      ],
      "planned_modules": [
        "lean/DefiKernel/Metatheory/Observation.lean",
        "lean/DefiKernel/Metatheory/Contexts.lean",
        "lean/DefiKernel/Metatheory/Examples.lean",
        "lean/DefiKernel/Metatheory/Tests.lean"
      ],
      "status": "planned-not-implemented",
      "evidence_limits": "Coverage assignment is an author planning link, not a completed check or proof. The implementation map must replace it with actual exact declarations/runtime observations/artifacts."
    },
    {
      "id": "S9-021",
      "capability": "continuation-observation",
      "requirement": "Exact cursor observations",
      "scenario": "Located failure sensitivity",
      "when": "otherwise equal cursors differ in failure reason, position or optional failed action",
      "then": "their observations differ",
      "source": "openspec/changes/operational-continuation-congruence/specs/continuation-observation/spec.md",
      "line": 31,
      "planned_tasks": [
        "3.1",
        "6.3"
      ],
      "planned_modules": [
        "lean/DefiKernel/Metatheory/Observation.lean",
        "lean/DefiKernel/Metatheory/Contexts.lean",
        "lean/DefiKernel/Metatheory/Examples.lean",
        "lean/DefiKernel/Metatheory/Tests.lean"
      ],
      "status": "planned-not-implemented",
      "evidence_limits": "Coverage assignment is an author planning link, not a completed check or proof. The implementation map must replace it with actual exact declarations/runtime observations/artifacts."
    },
    {
      "id": "S9-022",
      "capability": "continuation-observation",
      "requirement": "Exact cursor observations",
      "scenario": "Next position sensitivity",
      "when": "otherwise equal cursors have different absolute next positions",
      "then": "their observations differ",
      "source": "openspec/changes/operational-continuation-congruence/specs/continuation-observation/spec.md",
      "line": 36,
      "planned_tasks": [
        "3.1",
        "6.3"
      ],
      "planned_modules": [
        "lean/DefiKernel/Metatheory/Observation.lean",
        "lean/DefiKernel/Metatheory/Contexts.lean",
        "lean/DefiKernel/Metatheory/Examples.lean",
        "lean/DefiKernel/Metatheory/Tests.lean"
      ],
      "status": "planned-not-implemented",
      "evidence_limits": "Coverage assignment is an author planning link, not a completed check or proof. The implementation map must replace it with actual exact declarations/runtime observations/artifacts."
    },
    {
      "id": "S9-023",
      "capability": "continuation-observation",
      "requirement": "Observation equivalence laws",
      "scenario": "Equivalence laws",
      "when": "arbitrary well-typed cursors, including explicitly synthetic/unreachable observer pairs, are compared",
      "then": "the Boolean comparison corresponds exactly to the stated relation and all three equivalence laws hold",
      "source": "openspec/changes/operational-continuation-congruence/specs/continuation-observation/spec.md",
      "line": 45,
      "planned_tasks": [
        "3.2",
        "6.3"
      ],
      "planned_modules": [
        "lean/DefiKernel/Metatheory/Observation.lean",
        "lean/DefiKernel/Metatheory/Contexts.lean",
        "lean/DefiKernel/Metatheory/Examples.lean",
        "lean/DefiKernel/Metatheory/Tests.lean"
      ],
      "status": "planned-not-implemented",
      "evidence_limits": "Coverage assignment is an author planning link, not a completed check or proof. The implementation map must replace it with actual exact declarations/runtime observations/artifacts."
    },
    {
      "id": "S9-024",
      "capability": "continuation-observation",
      "requirement": "Observation equivalence laws",
      "scenario": "Omitted past diagnostic worlds",
      "when": "cursors agree on all observed fields but differ in a past raw event world",
      "then": "the selected observer equates the explicitly synthetic pair while retaining the restriction on raw diagnostic inspection and making no claim of two reachable traces differing only there",
      "source": "openspec/changes/operational-continuation-congruence/specs/continuation-observation/spec.md",
      "line": 50,
      "planned_tasks": [
        "3.2",
        "6.3"
      ],
      "planned_modules": [
        "lean/DefiKernel/Metatheory/Observation.lean",
        "lean/DefiKernel/Metatheory/Contexts.lean",
        "lean/DefiKernel/Metatheory/Examples.lean",
        "lean/DefiKernel/Metatheory/Tests.lean"
      ],
      "status": "planned-not-implemented",
      "evidence_limits": "Coverage assignment is an author planning link, not a completed check or proof. The implementation map must replace it with actual exact declarations/runtime observations/artifacts."
    },
    {
      "id": "S9-025",
      "capability": "continuation-observation",
      "requirement": "Restricted contextual substitution",
      "scenario": "Output-consuming suffix",
      "when": "equivalent groups are followed by a fixed continuation consuming an earlier qualified snapshot",
      "then": "the filled contexts remain observationally equivalent with the same exact history and results",
      "source": "openspec/changes/operational-continuation-congruence/specs/continuation-observation/spec.md",
      "line": 59,
      "planned_tasks": [
        "3.3",
        "3.4"
      ],
      "planned_modules": [
        "lean/DefiKernel/Metatheory/Observation.lean",
        "lean/DefiKernel/Metatheory/Contexts.lean",
        "lean/DefiKernel/Metatheory/Examples.lean",
        "lean/DefiKernel/Metatheory/Tests.lean"
      ],
      "status": "planned-not-implemented",
      "evidence_limits": "Coverage assignment is an author planning link, not a completed check or proof. The implementation map must replace it with actual exact declarations/runtime observations/artifacts."
    },
    {
      "id": "S9-026",
      "capability": "continuation-observation",
      "requirement": "Restricted contextual substitution",
      "scenario": "Fixed prefix and suffix",
      "when": "a one-hole context has fixed nonempty groups before and after the hole",
      "then": "equivalent replacement groups remain equivalent for every equivalent input cursor",
      "source": "openspec/changes/operational-continuation-congruence/specs/continuation-observation/spec.md",
      "line": 64,
      "planned_tasks": [
        "3.3",
        "3.4"
      ],
      "planned_modules": [
        "lean/DefiKernel/Metatheory/Observation.lean",
        "lean/DefiKernel/Metatheory/Contexts.lean",
        "lean/DefiKernel/Metatheory/Examples.lean",
        "lean/DefiKernel/Metatheory/Tests.lean"
      ],
      "status": "planned-not-implemented",
      "evidence_limits": "Coverage assignment is an author planning link, not a completed check or proof. The implementation map must replace it with actual exact declarations/runtime observations/artifacts."
    },
    {
      "id": "S9-027",
      "capability": "continuation-observation",
      "requirement": "Restricted contextual substitution",
      "scenario": "Failure-bearing replacement",
      "when": "equivalent replacement results already carry the same first failure",
      "then": "the fixed suffix remains inert and the filled contexts preserve that exact refusal",
      "source": "openspec/changes/operational-continuation-congruence/specs/continuation-observation/spec.md",
      "line": 69,
      "planned_tasks": [
        "3.3",
        "3.4"
      ],
      "planned_modules": [
        "lean/DefiKernel/Metatheory/Observation.lean",
        "lean/DefiKernel/Metatheory/Contexts.lean",
        "lean/DefiKernel/Metatheory/Examples.lean",
        "lean/DefiKernel/Metatheory/Tests.lean"
      ],
      "status": "planned-not-implemented",
      "evidence_limits": "Coverage assignment is an author planning link, not a completed check or proof. The implementation map must replace it with actual exact declarations/runtime observations/artifacts."
    },
    {
      "id": "S9-028",
      "capability": "continuation-observation",
      "requirement": "Necessary continuation premises",
      "scenario": "Missing history premise",
      "when": "equal-ledger cursors provide different frozen snapshots to the same consumer",
      "then": "the actual continuation results differ",
      "source": "openspec/changes/operational-continuation-congruence/specs/continuation-observation/spec.md",
      "line": 78,
      "planned_tasks": [
        "3.5",
        "6.4"
      ],
      "planned_modules": [
        "lean/DefiKernel/Metatheory/Observation.lean",
        "lean/DefiKernel/Metatheory/Contexts.lean",
        "lean/DefiKernel/Metatheory/Examples.lean",
        "lean/DefiKernel/Metatheory/Tests.lean"
      ],
      "status": "planned-not-implemented",
      "evidence_limits": "Coverage assignment is an author planning link, not a completed check or proof. The implementation map must replace it with actual exact declarations/runtime observations/artifacts."
    },
    {
      "id": "S9-029",
      "capability": "continuation-observation",
      "requirement": "Necessary continuation premises",
      "scenario": "Missing index premise",
      "when": "equal-ledger cursors select different index-dependent trusted boundaries",
      "then": "the actual continuation authorization or output differs",
      "source": "openspec/changes/operational-continuation-congruence/specs/continuation-observation/spec.md",
      "line": 83,
      "planned_tasks": [
        "3.5",
        "6.4"
      ],
      "planned_modules": [
        "lean/DefiKernel/Metatheory/Observation.lean",
        "lean/DefiKernel/Metatheory/Contexts.lean",
        "lean/DefiKernel/Metatheory/Examples.lean",
        "lean/DefiKernel/Metatheory/Tests.lean"
      ],
      "status": "planned-not-implemented",
      "evidence_limits": "Coverage assignment is an author planning link, not a completed check or proof. The implementation map must replace it with actual exact declarations/runtime observations/artifacts."
    },
    {
      "id": "S9-030",
      "capability": "continuation-observation",
      "requirement": "Necessary continuation premises",
      "scenario": "Missing store premise",
      "when": "equal-ledger cursors have different existing capability entries before the same authorized issue",
      "then": "the actual fresh issued IDs and complete stores differ",
      "source": "openspec/changes/operational-continuation-congruence/specs/continuation-observation/spec.md",
      "line": 88,
      "planned_tasks": [
        "3.5",
        "6.4"
      ],
      "planned_modules": [
        "lean/DefiKernel/Metatheory/Observation.lean",
        "lean/DefiKernel/Metatheory/Contexts.lean",
        "lean/DefiKernel/Metatheory/Examples.lean",
        "lean/DefiKernel/Metatheory/Tests.lean"
      ],
      "status": "planned-not-implemented",
      "evidence_limits": "Coverage assignment is an author planning link, not a completed check or proof. The implementation map must replace it with actual exact declarations/runtime observations/artifacts."
    },
    {
      "id": "S9-031",
      "capability": "continuation-observation",
      "requirement": "Necessary continuation premises",
      "scenario": "One-entry agreement is insufficient",
      "when": "two groups share the same initially refusing action but have different suffixes, and a fixed authorized funding prefix enables that action",
      "then": "equality at the original entry does not imply equal filled-context execution, demonstrating the need for universal input-cursor equivalence",
      "source": "openspec/changes/operational-continuation-congruence/specs/continuation-observation/spec.md",
      "line": 93,
      "planned_tasks": [
        "3.5",
        "6.4"
      ],
      "planned_modules": [
        "lean/DefiKernel/Metatheory/Observation.lean",
        "lean/DefiKernel/Metatheory/Contexts.lean",
        "lean/DefiKernel/Metatheory/Examples.lean",
        "lean/DefiKernel/Metatheory/Tests.lean"
      ],
      "status": "planned-not-implemented",
      "evidence_limits": "Coverage assignment is an author planning link, not a completed check or proof. The implementation map must replace it with actual exact declarations/runtime observations/artifacts."
    },
    {
      "id": "S9-032",
      "capability": "metatheory-regression-evidence",
      "requirement": "Planning and baseline gates",
      "scenario": "Provisional dependency context",
      "when": "Sprint9 is drafted while Sprint8 candidate evidence is still under review",
      "then": "the plan remains planning-only and marks the candidate binding for refresh before planning freeze",
      "source": "openspec/changes/operational-continuation-congruence/specs/metatheory-regression-evidence/spec.md",
      "line": 11,
      "planned_tasks": [
        "1.1",
        "1.2",
        "1.3"
      ],
      "planned_modules": [
        "lean/DefiKernel/Metatheory/Audit.lean",
        "lean/DefiKernel/Metatheory/Verify.lean",
        "lean/DefiKernel/Metatheory/Examples.lean",
        "lean/DefiKernel/Metatheory/Tests.lean"
      ],
      "status": "planned-not-implemented",
      "evidence_limits": "Coverage assignment is an author planning link, not a completed check or proof. The implementation map must replace it with actual exact declarations/runtime observations/artifacts."
    },
    {
      "id": "S9-033",
      "capability": "metatheory-regression-evidence",
      "requirement": "Planning and baseline gates",
      "scenario": "Implementation gate",
      "when": "the complete Sprint9 plan is ready",
      "then": "separate non-author planning verdicts, accepted dependency delivery and fresh baseline are recorded before source implementation",
      "source": "openspec/changes/operational-continuation-congruence/specs/metatheory-regression-evidence/spec.md",
      "line": 16,
      "planned_tasks": [
        "1.1",
        "1.2",
        "1.3"
      ],
      "planned_modules": [
        "lean/DefiKernel/Metatheory/Audit.lean",
        "lean/DefiKernel/Metatheory/Verify.lean",
        "lean/DefiKernel/Metatheory/Examples.lean",
        "lean/DefiKernel/Metatheory/Tests.lean"
      ],
      "status": "planned-not-implemented",
      "evidence_limits": "Coverage assignment is an author planning link, not a completed check or proof. The implementation map must replace it with actual exact declarations/runtime observations/artifacts."
    },
    {
      "id": "S9-034",
      "capability": "metatheory-regression-evidence",
      "requirement": "Independent operational evidence",
      "scenario": "Independent financial expectations",
      "when": "nested financial groups exercise world, history and boundary routing",
      "then": "expected balances, stores, receipts, outputs and refusals are written independently of the new executor and comparator",
      "source": "openspec/changes/operational-continuation-congruence/specs/metatheory-regression-evidence/spec.md",
      "line": 25,
      "planned_tasks": [
        "2.2",
        "6.1",
        "6.2",
        "6.3",
        "6.4"
      ],
      "planned_modules": [
        "lean/DefiKernel/Metatheory/Audit.lean",
        "lean/DefiKernel/Metatheory/Verify.lean",
        "lean/DefiKernel/Metatheory/Examples.lean",
        "lean/DefiKernel/Metatheory/Tests.lean"
      ],
      "status": "planned-not-implemented",
      "evidence_limits": "Coverage assignment is an author planning link, not a completed check or proof. The implementation map must replace it with actual exact declarations/runtime observations/artifacts."
    },
    {
      "id": "S9-035",
      "capability": "metatheory-regression-evidence",
      "requirement": "Independent operational evidence",
      "scenario": "Nonempty administrative evidence",
      "when": "cross-group issuance, use, revocation and refusal are tested",
      "then": "the comparisons retain actual fresh IDs, tombstones and complete stores",
      "source": "openspec/changes/operational-continuation-congruence/specs/metatheory-regression-evidence/spec.md",
      "line": 30,
      "planned_tasks": [
        "2.2",
        "6.1",
        "6.2",
        "6.3",
        "6.4"
      ],
      "planned_modules": [
        "lean/DefiKernel/Metatheory/Audit.lean",
        "lean/DefiKernel/Metatheory/Verify.lean",
        "lean/DefiKernel/Metatheory/Examples.lean",
        "lean/DefiKernel/Metatheory/Tests.lean"
      ],
      "status": "planned-not-implemented",
      "evidence_limits": "Coverage assignment is an author planning link, not a completed check or proof. The implementation map must replace it with actual exact declarations/runtime observations/artifacts."
    },
    {
      "id": "S9-036",
      "capability": "metatheory-regression-evidence",
      "requirement": "Independent operational evidence",
      "scenario": "Boundary scope negative",
      "when": "one transaction with a later refusal is compared with separately committed boundaries",
      "then": "the differing retained or rolled-back prefix is recorded as a boundary-change counterexample, not sequential associativity",
      "source": "openspec/changes/operational-continuation-congruence/specs/metatheory-regression-evidence/spec.md",
      "line": 35,
      "planned_tasks": [
        "2.2",
        "6.1",
        "6.2",
        "6.3",
        "6.4"
      ],
      "planned_modules": [
        "lean/DefiKernel/Metatheory/Audit.lean",
        "lean/DefiKernel/Metatheory/Verify.lean",
        "lean/DefiKernel/Metatheory/Examples.lean",
        "lean/DefiKernel/Metatheory/Tests.lean"
      ],
      "status": "planned-not-implemented",
      "evidence_limits": "Coverage assignment is an author planning link, not a completed check or proof. The implementation map must replace it with actual exact declarations/runtime observations/artifacts."
    },
    {
      "id": "S9-037",
      "capability": "metatheory-regression-evidence",
      "requirement": "Fourteen production mutations",
      "scenario": "Eight execution routing mutations",
      "when": "world, store, history, index, first failure, child execution, order or boundary selection is mutated",
      "then": "each actual source mutation is detected by its independent execution oracle with protected siblings true",
      "source": "openspec/changes/operational-continuation-congruence/specs/metatheory-regression-evidence/spec.md",
      "line": 44,
      "planned_tasks": [
        "7.2",
        "7.3",
        "7.5"
      ],
      "planned_modules": [
        "lean/DefiKernel/Metatheory/Audit.lean",
        "lean/DefiKernel/Metatheory/Verify.lean",
        "lean/DefiKernel/Metatheory/Examples.lean",
        "lean/DefiKernel/Metatheory/Tests.lean"
      ],
      "status": "planned-not-implemented",
      "evidence_limits": "Coverage assignment is an author planning link, not a completed check or proof. The implementation map must replace it with actual exact declarations/runtime observations/artifacts."
    },
    {
      "id": "S9-038",
      "capability": "metatheory-regression-evidence",
      "requirement": "Fourteen production mutations",
      "scenario": "Six observation omission mutations",
      "when": "current world, store, history, failure, receipt or next position comparison is omitted",
      "then": "each actual production comparison mutation is detected by an independently constructed synthetic arbitrary/unreachable changed pair while equal pairs stay true, separately classified from financial execution-routing detection",
      "source": "openspec/changes/operational-continuation-congruence/specs/metatheory-regression-evidence/spec.md",
      "line": 49,
      "planned_tasks": [
        "7.2",
        "7.3",
        "7.5"
      ],
      "planned_modules": [
        "lean/DefiKernel/Metatheory/Audit.lean",
        "lean/DefiKernel/Metatheory/Verify.lean",
        "lean/DefiKernel/Metatheory/Examples.lean",
        "lean/DefiKernel/Metatheory/Tests.lean"
      ],
      "status": "planned-not-implemented",
      "evidence_limits": "Coverage assignment is an author planning link, not a completed check or proof. The implementation map must replace it with actual exact declarations/runtime observations/artifacts."
    },
    {
      "id": "S9-039",
      "capability": "metatheory-regression-evidence",
      "requirement": "Fourteen production mutations",
      "scenario": "Compiler failure receives no detection credit",
      "when": "a mutation fails compilation, times out or loses expected observations",
      "then": "the attempt is blocked and retained as evidence, never counted among the fourteen semantic detections",
      "source": "openspec/changes/operational-continuation-congruence/specs/metatheory-regression-evidence/spec.md",
      "line": 54,
      "planned_tasks": [
        "7.2",
        "7.3",
        "7.5"
      ],
      "planned_modules": [
        "lean/DefiKernel/Metatheory/Audit.lean",
        "lean/DefiKernel/Metatheory/Verify.lean",
        "lean/DefiKernel/Metatheory/Examples.lean",
        "lean/DefiKernel/Metatheory/Tests.lean"
      ],
      "status": "planned-not-implemented",
      "evidence_limits": "Coverage assignment is an author planning link, not a completed check or proof. The implementation map must replace it with actual exact declarations/runtime observations/artifacts."
    },
    {
      "id": "S9-040",
      "capability": "metatheory-regression-evidence",
      "requirement": "Defensive runner controls",
      "scenario": "Complete actual CLI controls",
      "when": "the dedicated defensive suite runs against fresh external repositories",
      "then": "all sixty-five named controls execute real subprocesses with expected classifications and complete command/source/artifact/time records:52 inherited (including one base proof-boundary control),11 new proof-tail controls and2 production forms",
      "source": "openspec/changes/operational-continuation-congruence/specs/metatheory-regression-evidence/spec.md",
      "line": 63,
      "planned_tasks": [
        "7.1",
        "7.4",
        "7.5"
      ],
      "planned_modules": [
        "lean/DefiKernel/Metatheory/Audit.lean",
        "lean/DefiKernel/Metatheory/Verify.lean",
        "lean/DefiKernel/Metatheory/Examples.lean",
        "lean/DefiKernel/Metatheory/Tests.lean"
      ],
      "status": "planned-not-implemented",
      "evidence_limits": "Coverage assignment is an author planning link, not a completed check or proof. The implementation map must replace it with actual exact declarations/runtime observations/artifacts."
    },
    {
      "id": "S9-041",
      "capability": "metatheory-regression-evidence",
      "requirement": "Defensive runner controls",
      "scenario": "Runtime boundary parser controls",
      "when": "attributed or comment-prefixed runtime code, macros or initialization appears after the proof boundary",
      "then": "the runner blocks it while preserving the established comment/string/character negative siblings, all 12 proof-tail-related cases and both production audit-output forms with exact `Metatheory runtime comparisons failed: N` false-count text",
      "source": "openspec/changes/operational-continuation-congruence/specs/metatheory-regression-evidence/spec.md",
      "line": 68,
      "planned_tasks": [
        "7.1",
        "7.4",
        "7.5"
      ],
      "planned_modules": [
        "lean/DefiKernel/Metatheory/Audit.lean",
        "lean/DefiKernel/Metatheory/Verify.lean",
        "lean/DefiKernel/Metatheory/Examples.lean",
        "lean/DefiKernel/Metatheory/Tests.lean"
      ],
      "status": "planned-not-implemented",
      "evidence_limits": "Coverage assignment is an author planning link, not a completed check or proof. The implementation map must replace it with actual exact declarations/runtime observations/artifacts."
    },
    {
      "id": "S9-042",
      "capability": "metatheory-regression-evidence",
      "requirement": "Imported audits and accepted delivery",
      "scenario": "Complete proof inventory",
      "when": "the final source is frozen",
      "then": "every imported theorem and supplemental declaration is discovered mechanically, checked for forbidden axioms and bound to exact source Git bytes",
      "source": "openspec/changes/operational-continuation-congruence/specs/metatheory-regression-evidence/spec.md",
      "line": 77,
      "planned_tasks": [
        "6.5",
        "8.1",
        "8.2",
        "8.3",
        "8.4"
      ],
      "planned_modules": [
        "lean/DefiKernel/Metatheory/Audit.lean",
        "lean/DefiKernel/Metatheory/Verify.lean",
        "lean/DefiKernel/Metatheory/Examples.lean",
        "lean/DefiKernel/Metatheory/Tests.lean"
      ],
      "status": "planned-not-implemented",
      "evidence_limits": "Coverage assignment is an author planning link, not a completed check or proof. The implementation map must replace it with actual exact declarations/runtime observations/artifacts."
    },
    {
      "id": "S9-043",
      "capability": "metatheory-regression-evidence",
      "requirement": "Imported audits and accepted delivery",
      "scenario": "Prior behavior preservation",
      "when": "the new namespace is integrated",
      "then": "fresh prior Lean and Python regressions pass and historical source/evidence remains preserved",
      "source": "openspec/changes/operational-continuation-congruence/specs/metatheory-regression-evidence/spec.md",
      "line": 82,
      "planned_tasks": [
        "6.5",
        "8.1",
        "8.2",
        "8.3",
        "8.4"
      ],
      "planned_modules": [
        "lean/DefiKernel/Metatheory/Audit.lean",
        "lean/DefiKernel/Metatheory/Verify.lean",
        "lean/DefiKernel/Metatheory/Examples.lean",
        "lean/DefiKernel/Metatheory/Tests.lean"
      ],
      "status": "planned-not-implemented",
      "evidence_limits": "Coverage assignment is an author planning link, not a completed check or proof. The implementation map must replace it with actual exact declarations/runtime observations/artifacts."
    },
    {
      "id": "S9-044",
      "capability": "metatheory-regression-evidence",
      "requirement": "Imported audits and accepted delivery",
      "scenario": "Independent final acceptance",
      "when": "source and financial evidence are ready for delivery",
      "then": "native result/evidence verdicts bind the final candidate, all material blockers are resolved, and archive plus authorized branch push are verified",
      "source": "openspec/changes/operational-continuation-congruence/specs/metatheory-regression-evidence/spec.md",
      "line": 87,
      "planned_tasks": [
        "6.5",
        "8.1",
        "8.2",
        "8.3",
        "8.4"
      ],
      "planned_modules": [
        "lean/DefiKernel/Metatheory/Audit.lean",
        "lean/DefiKernel/Metatheory/Verify.lean",
        "lean/DefiKernel/Metatheory/Examples.lean",
        "lean/DefiKernel/Metatheory/Tests.lean"
      ],
      "status": "planned-not-implemented",
      "evidence_limits": "Coverage assignment is an author planning link, not a completed check or proof. The implementation map must replace it with actual exact declarations/runtime observations/artifacts."
    },
    {
      "id": "S9-045",
      "capability": "sequential-group-execution",
      "requirement": "Recursive ordered execution",
      "scenario": "Nested producer and consumer",
      "when": "a snapshot-producing movement, a prior-output consumer and a third movement occur in nested nonempty groups",
      "then": "the consumer uses the exact frozen qualified snapshot and all three actions have the independently expected worlds, receipts and absolute positions",
      "source": "openspec/changes/operational-continuation-congruence/specs/sequential-group-execution/spec.md",
      "line": 11,
      "planned_tasks": [
        "2.1",
        "2.2",
        "6.1"
      ],
      "planned_modules": [
        "lean/DefiKernel/Metatheory/SequentialGroups.lean",
        "lean/DefiKernel/Metatheory/Examples.lean",
        "lean/DefiKernel/Metatheory/Tests.lean"
      ],
      "status": "planned-not-implemented",
      "evidence_limits": "Coverage assignment is an author planning link, not a completed check or proof. The implementation map must replace it with actual exact declarations/runtime observations/artifacts."
    },
    {
      "id": "S9-046",
      "capability": "sequential-group-execution",
      "requirement": "Recursive ordered execution",
      "scenario": "Empty group identities",
      "when": "an empty group appears before or after a nonempty group from any existing cursor",
      "then": "the complete result equals execution of that nonempty group alone",
      "source": "openspec/changes/operational-continuation-congruence/specs/sequential-group-execution/spec.md",
      "line": 16,
      "planned_tasks": [
        "2.1",
        "2.2",
        "6.1"
      ],
      "planned_modules": [
        "lean/DefiKernel/Metatheory/SequentialGroups.lean",
        "lean/DefiKernel/Metatheory/Examples.lean",
        "lean/DefiKernel/Metatheory/Tests.lean"
      ],
      "status": "planned-not-implemented",
      "evidence_limits": "Coverage assignment is an author planning link, not a completed check or proof. The implementation map must replace it with actual exact declarations/runtime observations/artifacts."
    },
    {
      "id": "S9-047",
      "capability": "sequential-group-execution",
      "requirement": "Recursive ordered execution",
      "scenario": "Administrative cross-group continuation",
      "when": "one child issues a capability and later children invoke and revoke that issued ID",
      "then": "the complete updated store and exact administrative receipts reach every later child",
      "source": "openspec/changes/operational-continuation-congruence/specs/sequential-group-execution/spec.md",
      "line": 21,
      "planned_tasks": [
        "2.1",
        "2.2",
        "6.1"
      ],
      "planned_modules": [
        "lean/DefiKernel/Metatheory/SequentialGroups.lean",
        "lean/DefiKernel/Metatheory/Examples.lean",
        "lean/DefiKernel/Metatheory/Tests.lean"
      ],
      "status": "planned-not-implemented",
      "evidence_limits": "Coverage assignment is an author planning link, not a completed check or proof. The implementation map must replace it with actual exact declarations/runtime observations/artifacts."
    },
    {
      "id": "S9-048",
      "capability": "sequential-group-execution",
      "requirement": "Refusal and absolute continuation",
      "scenario": "Middle refusal absorbs suffix",
      "when": "transfer7 succeeds from USD10, transfer6 refuses, and a funded suffix would otherwise succeed",
      "then": "Alice remains3 and Bob7, the exact middle failure is retained and the suffix emits no movement, receipt or snapshot",
      "source": "openspec/changes/operational-continuation-congruence/specs/sequential-group-execution/spec.md",
      "line": 30,
      "planned_tasks": [
        "2.1",
        "2.4",
        "6.1"
      ],
      "planned_modules": [
        "lean/DefiKernel/Metatheory/SequentialGroups.lean",
        "lean/DefiKernel/Metatheory/Examples.lean",
        "lean/DefiKernel/Metatheory/Tests.lean"
      ],
      "status": "planned-not-implemented",
      "evidence_limits": "Coverage assignment is an author planning link, not a completed check or proof. The implementation map must replace it with actual exact declarations/runtime observations/artifacts."
    },
    {
      "id": "S9-049",
      "capability": "sequential-group-execution",
      "requirement": "Refusal and absolute continuation",
      "scenario": "Previously failed cursor",
      "when": "a recursive group starts from an already failed nonempty cursor",
      "then": "the complete cursor is unchanged",
      "source": "openspec/changes/operational-continuation-congruence/specs/sequential-group-execution/spec.md",
      "line": 35,
      "planned_tasks": [
        "2.1",
        "2.4",
        "6.1"
      ],
      "planned_modules": [
        "lean/DefiKernel/Metatheory/SequentialGroups.lean",
        "lean/DefiKernel/Metatheory/Examples.lean",
        "lean/DefiKernel/Metatheory/Tests.lean"
      ],
      "status": "planned-not-implemented",
      "evidence_limits": "Coverage assignment is an author planning link, not a completed check or proof. The implementation map must replace it with actual exact declarations/runtime observations/artifacts."
    },
    {
      "id": "S9-050",
      "capability": "sequential-group-execution",
      "requirement": "Refusal and absolute continuation",
      "scenario": "Nonzero boundary position",
      "when": "an existing cursor starts at a nonzero position and trusted actor or time differs by absolute slot",
      "then": "every action uses its actual continuation position and preserves the resulting exact success or refusal; the M08 sensitivity variant changes only the new leaf boundary argument to a constant position0 function, leaving imported single-step semantics unchanged",
      "source": "openspec/changes/operational-continuation-congruence/specs/sequential-group-execution/spec.md",
      "line": 40,
      "planned_tasks": [
        "2.1",
        "2.4",
        "6.1"
      ],
      "planned_modules": [
        "lean/DefiKernel/Metatheory/SequentialGroups.lean",
        "lean/DefiKernel/Metatheory/Examples.lean",
        "lean/DefiKernel/Metatheory/Tests.lean"
      ],
      "status": "planned-not-implemented",
      "evidence_limits": "Coverage assignment is an author planning link, not a completed check or proof. The implementation map must replace it with actual exact declarations/runtime observations/artifacts."
    },
    {
      "id": "S9-051",
      "capability": "sequential-group-execution",
      "requirement": "Actual flattening correspondence",
      "scenario": "Successful recursive simulation",
      "when": "a nonempty nested group succeeds with cross-child output dependencies",
      "then": "its entire cursor equals the actual flat continuation and independently expected financial fields",
      "source": "openspec/changes/operational-continuation-congruence/specs/sequential-group-execution/spec.md",
      "line": 49,
      "planned_tasks": [
        "2.3",
        "6.1"
      ],
      "planned_modules": [
        "lean/DefiKernel/Metatheory/SequentialGroups.lean",
        "lean/DefiKernel/Metatheory/Examples.lean",
        "lean/DefiKernel/Metatheory/Tests.lean"
      ],
      "status": "planned-not-implemented",
      "evidence_limits": "Coverage assignment is an author planning link, not a completed check or proof. The implementation map must replace it with actual exact declarations/runtime observations/artifacts."
    },
    {
      "id": "S9-052",
      "capability": "sequential-group-execution",
      "requirement": "Actual flattening correspondence",
      "scenario": "Administrative refusal simulation",
      "when": "a revoke in one group makes a later use refuse",
      "then": "recursive and flat execution retain the same tombstone, denied invocation, local index and successful prefix",
      "source": "openspec/changes/operational-continuation-congruence/specs/sequential-group-execution/spec.md",
      "line": 54,
      "planned_tasks": [
        "2.3",
        "6.1"
      ],
      "planned_modules": [
        "lean/DefiKernel/Metatheory/SequentialGroups.lean",
        "lean/DefiKernel/Metatheory/Examples.lean",
        "lean/DefiKernel/Metatheory/Tests.lean"
      ],
      "status": "planned-not-implemented",
      "evidence_limits": "Coverage assignment is an author planning link, not a completed check or proof. The implementation map must replace it with actual exact declarations/runtime observations/artifacts."
    },
    {
      "id": "S9-053",
      "capability": "sequential-group-execution",
      "requirement": "Actual flattening correspondence",
      "scenario": "Arbitrary continuation simulation",
      "when": "the starting cursor contains existing events, outputs, store entries and a nonzero position",
      "then": "the simulation preserves that entire prefix rather than creating a fresh initial cursor",
      "source": "openspec/changes/operational-continuation-congruence/specs/sequential-group-execution/spec.md",
      "line": 59,
      "planned_tasks": [
        "2.3",
        "6.1"
      ],
      "planned_modules": [
        "lean/DefiKernel/Metatheory/SequentialGroups.lean",
        "lean/DefiKernel/Metatheory/Examples.lean",
        "lean/DefiKernel/Metatheory/Tests.lean"
      ],
      "status": "planned-not-implemented",
      "evidence_limits": "Coverage assignment is an author planning link, not a completed check or proof. The implementation map must replace it with actual exact declarations/runtime observations/artifacts."
    },
    {
      "id": "S9-054",
      "capability": "sequential-group-execution",
      "requirement": "Sequential associativity scope",
      "scenario": "Three-group associativity",
      "when": "three nonempty groups are parenthesized left or right, including a failure-bearing case",
      "then": "both executions return the same complete cursor",
      "source": "openspec/changes/operational-continuation-congruence/specs/sequential-group-execution/spec.md",
      "line": 68,
      "planned_tasks": [
        "2.4",
        "6.4"
      ],
      "planned_modules": [
        "lean/DefiKernel/Metatheory/SequentialGroups.lean",
        "lean/DefiKernel/Metatheory/Examples.lean",
        "lean/DefiKernel/Metatheory/Tests.lean"
      ],
      "status": "planned-not-implemented",
      "evidence_limits": "Coverage assignment is an author planning link, not a completed check or proof. The implementation map must replace it with actual exact declarations/runtime observations/artifacts."
    },
    {
      "id": "S9-055",
      "capability": "sequential-group-execution",
      "requirement": "Sequential associativity scope",
      "scenario": "Reordering is a distinct behavior",
      "when": "shared withdrawals7 and6 compete for USD10 in opposite leaf orders",
      "then": "the differing accepted movement and refusal demonstrate that associativity does not permit swapping leaves",
      "source": "openspec/changes/operational-continuation-congruence/specs/sequential-group-execution/spec.md",
      "line": 73,
      "planned_tasks": [
        "2.4",
        "6.4"
      ],
      "planned_modules": [
        "lean/DefiKernel/Metatheory/SequentialGroups.lean",
        "lean/DefiKernel/Metatheory/Examples.lean",
        "lean/DefiKernel/Metatheory/Tests.lean"
      ],
      "status": "planned-not-implemented",
      "evidence_limits": "Coverage assignment is an author planning link, not a completed check or proof. The implementation map must replace it with actual exact declarations/runtime observations/artifacts."
    }
  ],
  "tasks": [
    {
      "id": "1.1",
      "description": "Verify accepted Sprint8 source99e2e2c, source/evidence2c038094 and archived/delivered9501f0a4 bindings in this change, `wiki-llm/sprint-9-operational-continuation-congruence.md` and the planning manifest; verify acceptance, exact full revisions, remote branch identity and unchanged historical bytes before freezing the Sprint9 bundle.",
      "status": "unchecked"
    },
    {
      "id": "1.2",
      "description": "Obtain separate non-author GPT-6 and native Fable 5.1 planning reviews of the identical proposal/design/four specs/tasks/scenario map/source bundle; verify exact candidate and bundle hashes, requested `claude-fable-5-1[1m]` model and medium effort and actual returned model identity, substantive verdicts and adjudication, leaving both reviews pending until actually run.",
      "status": "unchecked"
    },
    {
      "id": "1.3",
      "description": "Verify the completed fresh14 Lean-command and13 Python-suite baselines at accepted source99e2e2c, corrected final metadata and protected source/tool/driver identities under `review/semantic-kernel/sprint9/planning/baseline/`; recheck nonempty inventories and input hashes before creating Metatheory source, rerunning only if relevant inputs change and preserving any failed attempts.",
      "status": "unchecked"
    },
    {
      "id": "2.1",
      "description": "Create `lean/DefiKernel/Metatheory/SequentialGroups.lean` with SeqGroup.empty/step/seq, separate flatten and a recursive runGroup using Composition.advance at leaves and the full first-child cursor at seq; record the initial missing-feature check, then verify LSP and `lake build DefiKernel.Metatheory.SequentialGroups` from `lean/` with all runtime declarations before the proof marker.",
      "status": "unchecked"
    },
    {
      "id": "2.2",
      "description": "Add the first independent group expectations in `Metatheory/Examples.lean` and `Tests.lean`: transfer7 producer exporting Alice3, snapshot consumer transferring3 to Carol and Bob's return1; verify exact Alice1/Bob6/Carol3, ordered outputs, actual receipts and absolute indices for nested groups.",
      "status": "unchecked"
    },
    {
      "id": "2.3",
      "description": "Prove runGroup equals actual Composition.continueRun on flatten for arbitrary initial cursor, including raw event worlds, history, store, index and failure; verify the generic statement has no successful-only or initial-cursor restriction and targeted Lean checks cover administrative and prefailed instances.",
      "status": "unchecked"
    },
    {
      "id": "2.4",
      "description": "Derive full-cursor empty identities, refusal absorption and three-group associativity from actual recursive simulation; verify three nonempty groups and the middle-refusal inert-suffix case, retaining a separate reversed-shared-order negative result.",
      "status": "unchecked"
    },
    {
      "id": "3.1",
      "description": "Create `Metatheory/Observation.lean` with observeCursor, CursorEquivalent and the production fieldwise Boolean comparison specified in design.md, with local separate ledger/store/events/history/index/failure conjuncts and a local event index/step/receipt/output comparator (existing equality reuse is proof-only); verify independently constructed equal/changed pairs for current ledger, full store, event index/action/receipt/output, frozen history, nextIndex and exact optional failure.",
      "status": "unchecked"
    },
    {
      "id": "3.2",
      "description": "Prove comparison iff CursorEquivalent plus reflexivity/symmetry/transitivity; verify the full elaborated statements and a pair differing only in omitted past raw event worlds, without claiming equality of their raw cursors.",
      "status": "unchecked"
    },
    {
      "id": "3.3",
      "description": "Prove actual Composition.advance and runGroup preserve CursorEquivalent for the same action/group; verify proofs use equal current whole world, history, nextIndex and failure while preserving the observed event prefix, including issue/revoke and actual refusal branches.",
      "status": "unchecked"
    },
    {
      "id": "3.4",
      "description": "Create `Metatheory/Contexts.lean` with the one-hole before/after fixed-group grammar and universal-input GroupEquivalent; prove its equivalence laws and fill substitution, then verify fixed nonempty prefixes/suffixes and an output-consuming continuation under identical configuration/boundaries.",
      "status": "unchecked"
    },
    {
      "id": "3.5",
      "description": "Add actual missing-history, missing-index, missing-store and one-entry-only substitution counterexamples in `Metatheory/Examples.lean`/`Tests.lean`; verify each omitted premise permits different real continuation behavior and that no diagnostic inspection, peer addition or boundary movement is admitted by the context grammar.",
      "status": "unchecked"
    },
    {
      "id": "4.1",
      "description": "Create `Metatheory/Configuration.lean` reference sets, support predicates and ConfigAgreement with both catalogs valid, supported registry/full component-interface lookups equal and all-domain trusted admins equal, using shared P/A/D and typeclass binders rather than a heterogeneous type/instance field; verify support includes every issue Grant.operation and all static suffixes, and agreement contains no desired execution equality or invented runtime checker.",
      "status": "unchecked"
    },
    {
      "id": "4.2",
      "description": "Prove exact actual Composition.executeStep congruence for supported invokes by following validation, preparation/access/input resolution, execution and receipt extraction; verify generic success and all refusal branches including agreed absent lookups, with identical boundary/index/history/full world premises.",
      "status": "unchecked"
    },
    {
      "id": "4.3",
      "description": "Prove issue/revoke cases through actual registryAuthorityConfig and current-store lookup, using supported Grant.operation and all-domain admin equality; verify exact issue IDs, tombstones, unknown-capability/admin/domain failures and the grant-only operation-domain negative companion.",
      "status": "unchecked"
    },
    {
      "id": "4.4",
      "description": "Create `Metatheory/ConfigurationGroups.lean`; lift support and configuration equality through advance/startCursor/continueRun/run and recursive groups, proving support union and valid-config agreement laws; verify full cursor equality across nonempty issue/invoke/revoke groups and unreachable suffix support.",
      "status": "unchecked"
    },
    {
      "id": "4.5",
      "description": "Add independently executed configuration-premise witnesses for changed old registry, changed complete component/access/output lookup, invalid added catalog, changed grant-only operation domain, changed trusted admin and differing initial store; verify exact old/new outcomes and all remaining applicable premises as materiality witnesses, not minimality of the stronger sufficient hypotheses; keep changed registry signatures/output domains valid, grant-only domain-changing operations uncataloged and component ownership/import/export declarations valid.",
      "status": "unchecked"
    },
    {
      "id": "5.1",
      "description": "Create `Metatheory/OperatorLifting.lean` and prove supported analyzeInvocation/analyzeBranch equality and exact existing Parallel/Interleaving/Atomic admission equality; verify both complete valid catalogs, every static position, original error precedence, same policy and schedule, including malformed unreachable suffixes.",
      "status": "unchecked"
    },
    {
      "id": "5.2",
      "description": "Lift actual step congruence through Parallel isolated branch execution and merge with identical branches/initial whole world; verify exact success and refused-branch results and independently expected nonempty financial controls.",
      "status": "unchecked"
    },
    {
      "id": "5.3",
      "description": "Lift actual step congruence through shared Interleaving token execution using identical complete schedules and boundaries; verify exact attempt pre-worlds/outcomes, own histories, local indices and retained refusals under success and failure examples.",
      "status": "unchecked"
    },
    {
      "id": "5.4",
      "description": "Lift actual step congruence through Atomic attempts, receipt-derived table updates and finish/public projection with the same policy/label/schedule; verify exact committed, admission-refused, kernel-aborted, supply-aborted and unsettled results without inserting a new checker or weakening equality to balances.",
      "status": "unchecked"
    },
    {
      "id": "6.1",
      "description": "Complete group financial and administrative cases in `Metatheory/Examples.lean` and `Tests.lean`, including nonzero starting index/store, index-dependent actor/time, issue-use-revoke-denied-use and retained-prefix refusal; verify independent full expectations and nonempty positive controls for all eight routing mutants.",
      "status": "unchecked"
    },
    {
      "id": "6.2",
      "description": "Complete unrelated valid configuration-extension fixtures and existing operator siblings in `Metatheory/Examples.lean` and `Tests.lean`; verify both real catalog validity checks, explicit agreement proof instances, nonempty old-program success/refusal and exact whole-store preservation.",
      "status": "unchecked"
    },
    {
      "id": "6.3",
      "description": "Complete observation sensitivity pairs for every retained subfield and the six designated omission oracles; verify each changed pair differs and each equal nonempty pair compares equal without deriving expected values through the comparator under test, explicitly labeling synthetic arbitrary/unreachable observer-only pairs separately from actual financial runs.",
      "status": "unchecked"
    },
    {
      "id": "6.4",
      "description": "Add named checked counterexamples to scalar ledger-only continuation, one-entry replacement, shared reordering and moving an atomic commit boundary, plus the configuration witnesses; verify concrete success/refusal/rollback differences and record these as bounds on stronger claims rather than new operator laws.",
      "status": "unchecked"
    },
    {
      "id": "6.5",
      "description": "Create `Metatheory/Audit.lean` and `Verify.lean`, then integrate only the root verification import; verify all unique nonempty `metatheory.*` runtime observations, automatic imported theorem/supplemental axiom checks and zero forbidden dependencies with `lake build DefiKernel.Metatheory.Verify DefiKernel` from `lean/`.",
      "status": "unchecked"
    },
    {
      "id": "7.1",
      "description": "Add `scripts/check_metatheory_mutations.py`, `scripts/test_metatheory_mutation_runner.py` and `mutations/metatheory.json` by adapting final accepted Sprint8 runner behavior using every design mapping: driver/spec paths, scoped-module regex, audit root, proof-prefix and namespace-closure regex, exact `Metatheory runtime comparisons failed: N` error and empty/duplicate strings, fixture namespaces/paths and production assertions; verify a counted inventory of every case-insensitive Atomic occurrence in both accepted scripts (including descriptive fields, case-name tuple and exact error assertions), its explicit keep/rename decisions and the actual old explicit --spec path, real unchanged source projection, complete module/check inventory and strict executable-before-proof-boundary enforcement with fresh external output directories.",
      "status": "unchecked"
    },
    {
      "id": "7.2",
      "description": "Implement the exact eight production group-routing mutations M01–M08 in the new interpreter source sites listed in design.md, with M08 replacing only the leaf boundary argument by `(fun _ ↦ boundaries 0)`; verify each needle occurs exactly once in its target runtime prefix, with distinct leaf and seq forms and one replacement per variant, then verify every mutant compiles, its independent full-result comparison is false and its declared nonempty positive sibling remains true, with no imported kernel edit.",
      "status": "unchecked"
    },
    {
      "id": "7.3",
      "description": "Implement the exact six production observation omission mutations M09–M14 in actual comparison code; verify every changed-pair sensitivity comparison becomes false and equal nonempty pairs remain true, separating this evidence from financial execution-routing detections.",
      "status": "unchecked"
    },
    {
      "id": "7.4",
      "description": "Adapt all 65 final established actual CLI controls, including the 11 NEW proof-tail controls plus `runtime-definition-after-proof-boundary` already in the 52 inherited controls (12 related cases total), and two production audit-output forms, with an explicit old/new control-name map; verify every real subprocess has the expected valid/violated/blocked classification and compiler-only failures receive no semantic detection credit.",
      "status": "unchecked"
    },
    {
      "id": "7.5",
      "description": "Freeze Metatheory source, spec and drivers and execute all 14 production mutations plus 65 controls in fresh external trees; verify exact source Git objects, all required false/protected true observations, complete logs/UTC/tool identities, before/after drift checks and artifact manifests while retaining unsuccessful attempts separately; enforce a runtime Audit closure free of imported Tests/proof-only fixtures (reuse Atomic.Examples/Parallel.Examples), explicitly pass runner `--timeout-seconds 600`, retain 1500-second harness runner-subprocess limits, record measured wall time per command/case/variant, and classify any timeout/incomplete output as blocked exit3 with no detection credit; retain completed-command logs/prior records/fresh directory and outer timeout stderr, without claiming a timed-out-command log/record or changing the inherited timeout path.",
      "status": "unchecked"
    },
    {
      "id": "8.1",
      "description": "Run fresh full prior Lean and Python regression suites plus the new imported runtime/proof checks; verify nonempty inventories, exact existing input preservation and no regression at the frozen final candidate, distinguishing compiler controls and source-preserving equivalent metadata revisions.",
      "status": "unchecked"
    },
    {
      "id": "8.2",
      "description": "Generate complete elaborated/source theorem and supplemental inventories with private-name mapping, premise classes, source/module/Git provenance and every actual scenario mapping under `review/semantic-kernel/sprint9/`; verify exact inventory equality with fresh Verify output and distinguish generic proofs, reference instances, counterexamples, generated constants and execution evidence.",
      "status": "unchecked"
    },
    {
      "id": "8.3",
      "description": "Obtain native Grok and Fable 5.1 substantive source/proof and final evidence reviews on the same bound candidate; verify the requested native `claude-fable-5-1[1m]` model and medium effort, actual returned model identity, provenance logs and adjudication, resolve concrete blockers through targeted revisions until resolved and leave missing verdicts open rather than substituting author review.",
      "status": "unchecked"
    },
    {
      "id": "8.4",
      "description": "After accepted reviews and complete evidence, archive this OpenSpec change, reconcile wiki/progress and source/evidence manifests, and push the authorized branch; verify archived requirement/scenario preservation, strict validation and remote commit equality without merging to main or rewriting historical accepted evidence.",
      "status": "unchecked"
    }
  ],
  "mutants": [
    {
      "id": "M01",
      "actual_runtime_edit": "At seq, pass entry world to second child",
      "designated_oracle": "`metatheory.group.world-chain`: transfer7 then funded continuation retains exact intermediate world",
      "protected_positive": "single nonempty leaf"
    },
    {
      "id": "M02",
      "actual_runtime_edit": "At seq, restore entry capability store",
      "designated_oracle": "`metatheory.group.store-chain`: issued grant remains usable with exact fresh ID",
      "protected_positive": "store-independent nonempty transfer"
    },
    {
      "id": "M03",
      "actual_runtime_edit": "At seq, reset frozen output history",
      "designated_oracle": "`metatheory.group.history-chain`: consumer uses first child's exact snapshot",
      "protected_positive": "literal-input nonempty sequence"
    },
    {
      "id": "M04",
      "actual_runtime_edit": "At seq, reset nextIndex to entry index",
      "designated_oracle": "`metatheory.group.index-chain`: nonzero absolute indices and qualified previous output",
      "protected_positive": "single nonempty leaf"
    },
    {
      "id": "M05",
      "actual_runtime_edit": "At seq, clear first failure",
      "designated_oracle": "`metatheory.group.refusal-absorption`: funded suffix stays inert after exact middle refusal",
      "protected_positive": "successful nonempty sequence"
    },
    {
      "id": "M06",
      "actual_runtime_edit": "Skip the second child",
      "designated_oracle": "`metatheory.group.child-executed`: second funded movement appears with exact receipt/world",
      "protected_positive": "single nonempty leaf"
    },
    {
      "id": "M07",
      "actual_runtime_edit": "Reverse child order",
      "designated_oracle": "`metatheory.group.ordered`: asymmetric movements/producer-consumer result",
      "protected_positive": "single nonempty leaf"
    },
    {
      "id": "M08",
      "actual_runtime_edit": "Replace new leaf call `Composition.advance cfg boundaries cursor action` with `Composition.advance cfg (fun _ ↦ boundaries 0) cursor action`",
      "designated_oracle": "`metatheory.group.boundary-index`: distinct absolute actor/time yields exact authorization",
      "protected_positive": "nonempty index-insensitive boundary sibling"
    },
    {
      "id": "M09",
      "actual_runtime_edit": "Omit current ledger from cursor comparison",
      "designated_oracle": "`metatheory.observe.world-diff`: same other fields, changed protected cell must differ",
      "protected_positive": "equal nonempty cursor"
    },
    {
      "id": "M10",
      "actual_runtime_edit": "Omit complete store from comparison",
      "designated_oracle": "`metatheory.observe.store-diff`: ledger same, tombstone/entry differs",
      "protected_positive": "equal nonempty cursor"
    },
    {
      "id": "M11",
      "actual_runtime_edit": "Omit frozen history comparison",
      "designated_oracle": "`metatheory.observe.output-diff`: same events, differing qualified history",
      "protected_positive": "equal nonempty cursor"
    },
    {
      "id": "M12",
      "actual_runtime_edit": "Omit failure comparison",
      "designated_oracle": "`metatheory.observe.failure-diff`: exact reason/location/step differs",
      "protected_positive": "equal nonempty cursor"
    },
    {
      "id": "M13",
      "actual_runtime_edit": "Omit event receipt comparison",
      "designated_oracle": "`metatheory.observe.receipt-diff`: same remaining fields, evaluated receipt differs",
      "protected_positive": "equal nonempty cursor"
    },
    {
      "id": "M14",
      "actual_runtime_edit": "Omit nextIndex comparison",
      "designated_oracle": "`metatheory.observe.next-index-diff`: same other fields, absolute position differs",
      "protected_positive": "equal nonempty cursor"
    }
  ],
  "controls": [
    {
      "source_name": "production-eval-discriminating-mutant",
      "planned_name": "production-eval-discriminating-mutant",
      "expected_runner_exit": 0,
      "status": "catalog-inspected-not-executed-for-sprint9"
    },
    {
      "source_name": "production-eval-required-stays-true",
      "planned_name": "production-eval-required-stays-true",
      "expected_runner_exit": 1,
      "status": "catalog-inspected-not-executed-for-sprint9"
    },
    {
      "source_name": "live-discriminating-mutant",
      "planned_name": "live-discriminating-mutant",
      "expected_runner_exit": 0,
      "status": "catalog-inspected-not-executed-for-sprint9"
    },
    {
      "source_name": "dotted-comparisons",
      "planned_name": "dotted-comparisons",
      "expected_runner_exit": 0,
      "status": "catalog-inspected-not-executed-for-sprint9"
    },
    {
      "source_name": "hyphenated-dotted-comparisons",
      "planned_name": "hyphenated-dotted-comparisons",
      "expected_runner_exit": 0,
      "status": "catalog-inspected-not-executed-for-sprint9"
    },
    {
      "source_name": "empty-dot-segment-spec",
      "planned_name": "empty-dot-segment-spec",
      "expected_runner_exit": 3,
      "status": "catalog-inspected-not-executed-for-sprint9"
    },
    {
      "source_name": "trailing-dot-spec",
      "planned_name": "trailing-dot-spec",
      "expected_runner_exit": 3,
      "status": "catalog-inspected-not-executed-for-sprint9"
    },
    {
      "source_name": "leading-dot-observation",
      "planned_name": "leading-dot-observation",
      "expected_runner_exit": 3,
      "status": "catalog-inspected-not-executed-for-sprint9"
    },
    {
      "source_name": "empty-dot-segment-observation",
      "planned_name": "empty-dot-segment-observation",
      "expected_runner_exit": 3,
      "status": "catalog-inspected-not-executed-for-sprint9"
    },
    {
      "source_name": "unused-variable-warning",
      "planned_name": "unused-variable-warning",
      "expected_runner_exit": 0,
      "status": "catalog-inspected-not-executed-for-sprint9"
    },
    {
      "source_name": "uppercase-observation",
      "planned_name": "uppercase-observation",
      "expected_runner_exit": 3,
      "status": "catalog-inspected-not-executed-for-sprint9"
    },
    {
      "source_name": "unknown-mutant-observation",
      "planned_name": "unknown-mutant-observation",
      "expected_runner_exit": 3,
      "status": "catalog-inspected-not-executed-for-sprint9"
    },
    {
      "source_name": "all-true-mutant",
      "planned_name": "all-true-mutant",
      "expected_runner_exit": 1,
      "status": "catalog-inspected-not-executed-for-sprint9"
    },
    {
      "source_name": "required-observation-stays-true",
      "planned_name": "required-observation-stays-true",
      "expected_runner_exit": 1,
      "status": "catalog-inspected-not-executed-for-sprint9"
    },
    {
      "source_name": "positive-control-flipped",
      "planned_name": "positive-control-flipped",
      "expected_runner_exit": 1,
      "status": "catalog-inspected-not-executed-for-sprint9"
    },
    {
      "source_name": "compilation-only-failure",
      "planned_name": "compilation-only-failure",
      "expected_runner_exit": 3,
      "status": "catalog-inspected-not-executed-for-sprint9"
    },
    {
      "source_name": "compiler-error-with-runtime-failure",
      "planned_name": "compiler-error-with-runtime-failure",
      "expected_runner_exit": 3,
      "status": "catalog-inspected-not-executed-for-sprint9"
    },
    {
      "source_name": "empty-observations",
      "planned_name": "empty-observations",
      "expected_runner_exit": 3,
      "status": "catalog-inspected-not-executed-for-sprint9"
    },
    {
      "source_name": "duplicate-observations",
      "planned_name": "duplicate-observations",
      "expected_runner_exit": 3,
      "status": "catalog-inspected-not-executed-for-sprint9"
    },
    {
      "source_name": "missing-positive-observation",
      "planned_name": "missing-positive-observation",
      "expected_runner_exit": 3,
      "status": "catalog-inspected-not-executed-for-sprint9"
    },
    {
      "source_name": "missing-required-observation",
      "planned_name": "missing-required-observation",
      "expected_runner_exit": 3,
      "status": "catalog-inspected-not-executed-for-sprint9"
    },
    {
      "source_name": "partial-mutant-observations",
      "planned_name": "partial-mutant-observations",
      "expected_runner_exit": 3,
      "status": "catalog-inspected-not-executed-for-sprint9"
    },
    {
      "source_name": "no-op-mutation",
      "planned_name": "no-op-mutation",
      "expected_runner_exit": 3,
      "status": "catalog-inspected-not-executed-for-sprint9"
    },
    {
      "source_name": "missing-mutation-needle",
      "planned_name": "missing-mutation-needle",
      "expected_runner_exit": 3,
      "status": "catalog-inspected-not-executed-for-sprint9"
    },
    {
      "source_name": "missing-source-setup",
      "planned_name": "missing-source-setup",
      "expected_runner_exit": 3,
      "status": "catalog-inspected-not-executed-for-sprint9"
    },
    {
      "source_name": "missing-manifest-setup",
      "planned_name": "missing-manifest-setup",
      "expected_runner_exit": 3,
      "status": "catalog-inspected-not-executed-for-sprint9"
    },
    {
      "source_name": "existing-output-setup",
      "planned_name": "existing-output-setup",
      "expected_runner_exit": 3,
      "status": "catalog-inspected-not-executed-for-sprint9"
    },
    {
      "source_name": "reserved-mutation-name",
      "planned_name": "reserved-mutation-name",
      "expected_runner_exit": 3,
      "status": "catalog-inspected-not-executed-for-sprint9"
    },
    {
      "source_name": "empty-module-inventory",
      "planned_name": "empty-module-inventory",
      "expected_runner_exit": 3,
      "status": "catalog-inspected-not-executed-for-sprint9"
    },
    {
      "source_name": "empty-positive-inventory",
      "planned_name": "empty-positive-inventory",
      "expected_runner_exit": 3,
      "status": "catalog-inspected-not-executed-for-sprint9"
    },
    {
      "source_name": "duplicate-module-inventory",
      "planned_name": "duplicate-module-inventory",
      "expected_runner_exit": 3,
      "status": "catalog-inspected-not-executed-for-sprint9"
    },
    {
      "source_name": "duplicate-mutation-inventory",
      "planned_name": "duplicate-mutation-inventory",
      "expected_runner_exit": 3,
      "status": "catalog-inspected-not-executed-for-sprint9"
    },
    {
      "source_name": "duplicate-positive-check",
      "planned_name": "duplicate-positive-check",
      "expected_runner_exit": 3,
      "status": "catalog-inspected-not-executed-for-sprint9"
    },
    {
      "source_name": "duplicate-required-check",
      "planned_name": "duplicate-required-check",
      "expected_runner_exit": 3,
      "status": "catalog-inspected-not-executed-for-sprint9"
    },
    {
      "source_name": "nonunique-mutation-needle",
      "planned_name": "nonunique-mutation-needle",
      "expected_runner_exit": 3,
      "status": "catalog-inspected-not-executed-for-sprint9"
    },
    {
      "source_name": "malformed-observation",
      "planned_name": "malformed-observation",
      "expected_runner_exit": 3,
      "status": "catalog-inspected-not-executed-for-sprint9"
    },
    {
      "source_name": "malformed-json",
      "planned_name": "malformed-json",
      "expected_runner_exit": 3,
      "status": "catalog-inspected-not-executed-for-sprint9"
    },
    {
      "source_name": "duplicate-json-key",
      "planned_name": "duplicate-json-key",
      "expected_runner_exit": 3,
      "status": "catalog-inspected-not-executed-for-sprint9"
    },
    {
      "source_name": "output-inside-repository",
      "planned_name": "output-inside-repository",
      "expected_runner_exit": 3,
      "status": "catalog-inspected-not-executed-for-sprint9"
    },
    {
      "source_name": "output-symlink",
      "planned_name": "output-symlink",
      "expected_runner_exit": 3,
      "status": "catalog-inspected-not-executed-for-sprint9"
    },
    {
      "source_name": "discovered-atomic-dependency",
      "planned_name": "discovered-metatheory-dependency",
      "expected_runner_exit": 0,
      "status": "catalog-inspected-not-executed-for-sprint9"
    },
    {
      "source_name": "fresh-dependency-source-failure",
      "planned_name": "fresh-dependency-source-failure",
      "expected_runner_exit": 3,
      "status": "catalog-inspected-not-executed-for-sprint9"
    },
    {
      "source_name": "missing-audit-root",
      "planned_name": "missing-audit-root",
      "expected_runner_exit": 3,
      "status": "catalog-inspected-not-executed-for-sprint9"
    },
    {
      "source_name": "foreign-module-root",
      "planned_name": "foreign-module-root",
      "expected_runner_exit": 3,
      "status": "catalog-inspected-not-executed-for-sprint9"
    },
    {
      "source_name": "mutation-module-outside-inventory",
      "planned_name": "mutation-module-outside-inventory",
      "expected_runner_exit": 3,
      "status": "catalog-inspected-not-executed-for-sprint9"
    },
    {
      "source_name": "unchanged-control-failed",
      "planned_name": "unchanged-control-failed",
      "expected_runner_exit": 1,
      "status": "catalog-inspected-not-executed-for-sprint9"
    },
    {
      "source_name": "nonkernel-local-dependency",
      "planned_name": "nonkernel-local-dependency",
      "expected_runner_exit": 0,
      "status": "catalog-inspected-not-executed-for-sprint9"
    },
    {
      "source_name": "dirty-source-before-run",
      "planned_name": "dirty-source-before-run",
      "expected_runner_exit": 3,
      "status": "catalog-inspected-not-executed-for-sprint9"
    },
    {
      "source_name": "staged-source-before-run",
      "planned_name": "staged-source-before-run",
      "expected_runner_exit": 3,
      "status": "catalog-inspected-not-executed-for-sprint9"
    },
    {
      "source_name": "source-drift-during-run",
      "planned_name": "source-drift-during-run",
      "expected_runner_exit": 3,
      "status": "catalog-inspected-not-executed-for-sprint9"
    },
    {
      "source_name": "source-drift-during-mutant",
      "planned_name": "source-drift-during-mutant",
      "expected_runner_exit": 3,
      "status": "catalog-inspected-not-executed-for-sprint9"
    },
    {
      "source_name": "specification-drift-during-run",
      "planned_name": "specification-drift-during-run",
      "expected_runner_exit": 3,
      "status": "catalog-inspected-not-executed-for-sprint9"
    },
    {
      "source_name": "runtime-definition-after-proof-boundary",
      "planned_name": "runtime-definition-after-proof-boundary",
      "expected_runner_exit": 3,
      "status": "catalog-inspected-not-executed-for-sprint9"
    },
    {
      "source_name": "attributed-runtime-after-proof-boundary",
      "planned_name": "attributed-runtime-after-proof-boundary",
      "expected_runner_exit": 3,
      "status": "catalog-inspected-not-executed-for-sprint9"
    },
    {
      "source_name": "comment-prefixed-runtime-after-proof-boundary",
      "planned_name": "comment-prefixed-runtime-after-proof-boundary",
      "expected_runner_exit": 3,
      "status": "catalog-inspected-not-executed-for-sprint9"
    },
    {
      "source_name": "macro-after-proof-boundary",
      "planned_name": "macro-after-proof-boundary",
      "expected_runner_exit": 3,
      "status": "catalog-inspected-not-executed-for-sprint9"
    },
    {
      "source_name": "macro-rules-after-proof-boundary",
      "planned_name": "macro-rules-after-proof-boundary",
      "expected_runner_exit": 3,
      "status": "catalog-inspected-not-executed-for-sprint9"
    },
    {
      "source_name": "syntax-after-proof-boundary",
      "planned_name": "syntax-after-proof-boundary",
      "expected_runner_exit": 3,
      "status": "catalog-inspected-not-executed-for-sprint9"
    },
    {
      "source_name": "initialize-after-proof-boundary",
      "planned_name": "initialize-after-proof-boundary",
      "expected_runner_exit": 3,
      "status": "catalog-inspected-not-executed-for-sprint9"
    },
    {
      "source_name": "proof-comment-keywords-sibling",
      "planned_name": "proof-comment-keywords-sibling",
      "expected_runner_exit": 0,
      "status": "catalog-inspected-not-executed-for-sprint9"
    },
    {
      "source_name": "proof-string-keywords-sibling",
      "planned_name": "proof-string-keywords-sibling",
      "expected_runner_exit": 0,
      "status": "catalog-inspected-not-executed-for-sprint9"
    },
    {
      "source_name": "raw-string-before-attributed-runtime",
      "planned_name": "raw-string-before-attributed-runtime",
      "expected_runner_exit": 3,
      "status": "catalog-inspected-not-executed-for-sprint9"
    },
    {
      "source_name": "character-before-attributed-runtime",
      "planned_name": "character-before-attributed-runtime",
      "expected_runner_exit": 3,
      "status": "catalog-inspected-not-executed-for-sprint9"
    },
    {
      "source_name": "proof-raw-string-character-sibling",
      "planned_name": "proof-raw-string-character-sibling",
      "expected_runner_exit": 0,
      "status": "catalog-inspected-not-executed-for-sprint9"
    },
    {
      "source_name": "empty-mutation-inventory",
      "planned_name": "empty-mutation-inventory",
      "expected_runner_exit": 3,
      "status": "catalog-inspected-not-executed-for-sprint9"
    }
  ],
  "runner_adaptation_map": {
    "path": "review/semantic-kernel/sprint9/planning/runner-adaptation-map.json",
    "sha256": "2b55949ea78327a8c5ed2b598fbff9a2131f363fbc71b62812153a0bfd61d29a"
  },
  "gates": {
    "sprint8_final_accepted_delivery": "passed; accepted source99e2e2c, source/evidence2c038094, verified archive9501f0a4; exact full IDs in dependency binding",
    "independent_gpt6_planning": "r1/r2 ACCEPT WITH LIMITATIONS by nonauthor GPT-6; focused r3 review pending",
    "historical_native_opus_planning": "r1/r2 ACCEPT WITH LIMITATIONS, claude-opus-5; three r2 runner clarifications addressed",
    "native_fable_planning": "latest user selects Fable5.1 medium; same-candidate r3 review pending",
    "fresh_implementation_baseline": "passed at accepted99 source:14 Lean commands and13 Python suites; separate prerequisite evidence, no task checkbox inferred",
    "implementation": "not started",
    "production_mutations_and_cli_controls": "not run for Sprint9",
    "native_result_and_evidence_audits": "not performed",
    "delivery": "not performed"
  },
  "reviewer_policy": {
    "authority": "AGENTS.md reviewer change2026-09-07",
    "planning": [
      "nonauthor GPT-6",
      "native Fable 5.1"
    ],
    "substantive_results": [
      "native Grok",
      "native Fable 5.1"
    ],
    "requested_native_model_alias": "claude-fable-5-1[1m]",
    "requested_effort": "medium",
    "actual_returned_model_identity": "historical r1/r2 native Opus reports claude-opus-5; focused r3 invocation and returned identity pending",
    "historical_fable_identity": "preserved",
    "freeze": "r1/r2 frozen/reviewed; three remaining runner clarifications addressed, focused r3 freeze and reviews pending"
  },
  "dependency_evidence": {
    "path": "review/semantic-kernel/sprint9/planning/dependency-baseline-binding.json",
    "sha256": "007f2a47ef33f93e8bf7ae9ab6ed1318a1a5b54e0e50d6510fba809393eb653d",
    "accepted_source_candidate": "99e2e2c61a1a3c5249026921efdc6cd41ac8f21d",
    "source_evidence_commit": "2c038094c031723f3ade35d8b3f506ccff5b1d3b",
    "archive_metadata_commit": "9501f0a4f0480b2a42ff197907d548cf0c610773",
    "baseline": {
      "actual_source_candidate": "99e2e2c61a1a3c5249026921efdc6cd41ac8f21d",
      "lean_commands": 14,
      "python_suites": 13,
      "lean_source_inputs": 104,
      "python_source_inputs": 148,
      "python_saved_evidence_assertions": 3382,
      "python_file_hashes_checked": 2703,
      "python_symlink_targets_checked": 9,
      "all_commands_passed": true,
      "metadata_correction": "baseline/python/metadata-correction.json",
      "final_metadata_hashes_checked": true,
      "all65_cli_recorded_paths_hashes_outputs_checked": true,
      "note": "Existing completed baseline executions reused at their actual99 source identity. This author refresh reruns no suites.",
      "gate_evidence": "baseline/gate-evidence.json"
    }
  }
}


===== INPUT review/semantic-kernel/sprint9/planning/baseline/gate-evidence.json ORIGINAL_SHA256 62e9376fc9dbcb4e497935575d1abad2f6c8935c9b806b7e42fa8e6d7704c475 RENDERED_SHA256 62e9376fc9dbcb4e497935575d1abad2f6c8935c9b806b7e42fa8e6d7704c475 =====
{
  "kind": "fresh Sprint9 baseline gate evidence, independent planning gate not yet passed",
  "status": "PASS",
  "checked_utc": "2026-09-07T15:42:13.993607+00:00",
  "actual_execution_revision": "99e2e2c61a1a3c5249026921efdc6cd41ac8f21d",
  "lean_commands": 14,
  "python_suites": 13,
  "lean_source_count": 104,
  "python_source_count": 148,
  "unique_current_equivalent_inputs": 148,
  "current_inputs_equal_actual_revision": true,
  "runtime_counts": [
    135,
    116,
    131,
    93,
    189,
    33,
    43
  ],
  "python_assertions": 3382,
  "no_metatheory_implementation": true,
  "artifacts": {
    "review/semantic-kernel/sprint9/planning/baseline/lean/verification.json": {
      "sha256": "fa5403d38863c42d05eee273d29212ed0fb2a90a97ebbbbf7758e8ec0ad1608e",
      "bytes": 945
    },
    "review/semantic-kernel/sprint9/planning/baseline/lean/lean-runs.json": {
      "sha256": "c560e11db2f27f0d72a2eb60840a296a8899ccb0319f41f4dc023db6b9778925",
      "bytes": 12449
    },
    "review/semantic-kernel/sprint9/planning/baseline/lean/source-before.json": {
      "sha256": "47817779c29d2303216c0f0cb53cca196c28f241a3e6002963d9a85d52a0af5f",
      "bytes": 19863
    },
    "review/semantic-kernel/sprint9/planning/baseline/lean/source-after.json": {
      "sha256": "e9af646f97a36e5b05cf5b36c963c81f174e3e5c4bd100bbbe69ee153e588f9f",
      "bytes": 11543
    },
    "review/semantic-kernel/sprint9/planning/baseline/python/baseline-runs.json": {
      "sha256": "3c73237e05c00cc34744d8d3111fb9c851091e42731b15d58356b34d064c1f8c",
      "bytes": 24257
    },
    "review/semantic-kernel/sprint9/planning/baseline/python/verified-outcomes.json": {
      "sha256": "0f7684159f242dc71bb77fde963e202bba30dbe1de570a360ec66ef96b31138d",
      "bytes": 439157
    },
    "review/semantic-kernel/sprint9/planning/baseline/python/source-binding.json": {
      "sha256": "b809f789534ec362427f6c48f832cc08946dbbe7d32f9e669855834cb6802ca5",
      "bytes": 45942
    },
    "review/semantic-kernel/sprint9/planning/baseline/python/source-binding-after.json": {
      "sha256": "b809f789534ec362427f6c48f832cc08946dbbe7d32f9e669855834cb6802ca5",
      "bytes": 45942
    },
    "review/semantic-kernel/sprint9/planning/baseline/python/artifact-manifest.json": {
      "sha256": "316559f8fa194269b1e0ae9107a5ff23776288f797e89b64c6661f46022386ca",
      "bytes": 444109
    },
    "review/semantic-kernel/sprint9/planning/baseline/python/metadata-correction.json": {
      "sha256": "b17248a43aa4024d2394494bfc6ddf33f718911f3cb1f2a72a139be0880810b3",
      "bytes": 1122
    }
  }
}


===== INPUT review/semantic-kernel/sprint9/planning/r2-gpt6.md ORIGINAL_SHA256 06d97c044c8d99ec6fe5ea0c8091de1e0d5a9d28a24db966ee8cfbc0e9afece5 RENDERED_SHA256 06d97c044c8d99ec6fe5ea0c8091de1e0d5a9d28a24db966ee8cfbc0e9afece5 =====
VERDICT: ACCEPT WITH LIMITATIONS

Frozen candidate: `47cd83136ab69b0975594a77c519f6611f6fb555`.
Bundle: `1831b58682b2de3500010e75e2dd6e6182f2c07ec6b836f5ac2318df1fa91c4d`.

This is an independent nonauthor semantic planning audit through the requested GPT-6 stock Codex harness. I did not author the Sprint9 plan. I authored its Python baseline harness and evidence reconciliation and earlier financial fixtures; this review does not claim independent baseline reproduction. No separate provider model/build telemetry is exposed in this agent session, and none is invented. No native provider calls, Foreman, implementation, source edits or commits were performed.

BLOCKERS

None. The six substantive r1 Opus clarification requests are resolved in the revised normative documents and tasks. The one historical-path correction below does not change an executable interface, premise, mutation or planned result and does not prevent planning acceptance. Both reviewers must still pass this same revised candidate before implementation begins.

REQUIRED CHANGES

No further semantic plan change is required before implementation. The implementation adaptation manifest must bind the actual old specification `review/semantic-kernel/sprint8/mutation-spec.json`; preserve the intended new path `mutations/metatheory.json`. The design table's old value `mutations/atomic.json` is an inaccurate historical locator. At the frozen candidate that directory does not exist, and `check_atomic_mutations.py` declares `--spec` as required, with no default. Thus this is a record correction to carry into adjudication and implementation mapping, not a reason to invent or relabel an old source artifact. Keep reviewed candidate bytes immutable.

SIX-REQUEST REASSESSMENT

1. Comparator locality is now explicit. Design section 2 and task 3.1 require local ledger/store/events/history/index/failure conjuncts and a local event comparator exposing index/action/receipt/outputs separately. Existing world/branch comparisons can support correctness proofs but cannot implement the runtime comparison. Exact leaf-field equality remains allowed. This gives M09–M14 actual new-source sites, including M13's receipt-only conjunct, without changing imported code.

2. Mutation cost and timeout handling are bounded. Task 7.5 and the evidence requirement specify 600 seconds per runner Lean/Git command, 1500 seconds per harness runner subprocess, measured wall time and preserved partial failure output. The import discipline excludes imported Tests, Verify and proof-only fixtures from the runtime closure while preserving old dependency proofs. The proposed Atomic.Examples/Parallel.Examples route is available in the actual imports and avoids the unwanted test-suite route. These are implementation checks and limits, not a claim that future variants will necessarily meet the time budget. A timeout remains blocked evidence with no detection credit.

3. The adaptation table now covers the actual driver regex, proof-prefix/namespace closure, required Audit root, failed/empty/duplicate messages, input/split/absent fixture namespaces and production assertions. The exact numeric `Metatheory runtime comparisons failed: N` contract matches the accepted runner's classification structure. The historical spec-path error is isolated above; no other omitted substantive adaptation surface was found in the inspected driver/harness. All 65 case names and expected exits remain mapped.

4. M08 has an exact feasible new-source edit: change the leaf argument from `boundaries` to `(fun _ ↦ boundaries 0)` when calling `Composition.advance`. This changes boundary selection without touching the imported function or resetting the cursor index, so the designated actor/time-sensitive fixture can distinguish precisely that fault.

5. Shared P/A/D and DecidableEq/Fintype instances are explicitly theorem/definition binders. ConfigAgreement now lists only catalog validity, supported registry lookup equality, full component/interface lookup equality and all-domain administrator equality. No heterogeneous type/instance equality field is required.

6. Negative companions now establish materiality, not minimality of deliberately strong sufficient premises. Valid-catalog construction guidance keeps changed template signatures/output domains valid, uses an uncataloged grant-only operation for a domain witness, and preserves component ownership/import/export validity. This prevents an unrelated configuration failure from masking the intended comparison. Identical initial world/store remains a theorem input, not an agreement field.

The additional r1 limitations are also handled: observer-only pairs are explicitly synthetic and may be unreachable; twelve proof-tail-related cases are correctly distinguished from the provenance arithmetic52+11+2; all 72 bundle inputs now contain their exact original bytes, including JSON.

SEMANTIC AND COVERAGE CHECK

The revised requirements preserve the sound M1 architecture. A genuinely recursive interpreter passes the entire returned cursor to its second child. Existing `Composition.continueRun_append` and `continueRun_failed` support full-cursor simulation for arbitrary starting cursors, including raw event worlds, nonzero indices, administration and failure. Ordered sequential associativity follows from that actual simulation; it does not swap leaves or move commit boundaries.

The observer retains every field read by `Composition.advance`: current world/store, outputs, nextIndex and failure. Past raw event worlds are only carried forward and projected away, so their omission is compatible with the stated observer. Universal-input group equivalence supplies equivalent inputs after any fixed prefix; advance/group congruence handles the fixed suffix. The one-entry funding-prefix counterexample remains a real bound on the stronger contextual claim.

Configuration support still includes every submitted invocation and every issue Grant.operation. Whole-catalog validity accounts for the first check in executeStep and operator admission. Complete used registry/template and component/interface equality cover input resolution, access, evaluation, receipts and snapshots; all-domain administrators cover revocation against dynamically selected stored capability domains. No agreement field assumes execution equality. Actual step equality can lift through full static admission, Parallel branches/merge, Interleaving slots/own histories and Atomic receipt-derived table updates, aborts and finish. Full result equality remains required, not merely equal balances or successful outcomes.

The independent 7/3/1 financial path remains coherent, and full stores, receipts, ordered snapshots and exact refusals remain mandatory independent expectations. Eight execution-routing mutants and six synthetic observer-sensitivity mutants have distinct evidence classes. Compiler failures/timeouts cannot count as any of the fourteen detections.

Mechanical reconciliation passed293 checks: exact frozen candidate and bundle; 72 unique original-byte/Git/input bindings; unchanged existing Lean and script source from r1; four capabilities,17 requirements,55 scenarios,35 unchecked tasks; complete scenario/task assignments;14 mutant IDs;65 exact inherited control names/exits; and bound baseline artifact hashes. Before/after verification confirms no candidate, bundle or input drift. This is source/evidence reconciliation, not a new baseline or proof execution.

NONBLOCKING LIMITATIONS

The old spec-path table entry needs the bounded mapping correction above. More generally, agreement remains stronger than necessary and fixes the identity universe, complete initial world/store and trusted boundaries. Contexts cannot inspect omitted diagnostics, add peers, change configuration/boundaries or introduce atomic boundaries. Synthetic arbitrary-cursor pairs are not reachable financial traces. Finite exact-rational reference execution and finite fault sensitivity do not establish deployed fidelity, full abstraction, machine arithmetic or exhaustive verification.

CLAIM/SCOPE CHECK

Acceptance covers ten planned Metatheory modules, dedicated mutation scripts/specification and the root verification import, with historical semantics preserved. It does not complete Interface/Nary execution, finite-participant routing, causal assume-guarantee, projected unrelated-state extension, dynamic capability provenance or atomic-boundary regrouping. Actual Lean proofs, complete imported inventories, independent expected fixtures,14 fresh production mutations,65 controls, prior regressions and native Grok/Opus result/evidence acceptance remain later obligations. No Metatheory implementation exists at the reviewed candidate. The revised plan is sufficiently precise and noncircular to proceed once its same-candidate planning gate is complete.


===== INPUT review/semantic-kernel/sprint9/planning/r2-opus.md ORIGINAL_SHA256 c9188dc7d6c5351394036e99cafd9a8c9e2150d843a5f75fe4187fc4772c899a RENDERED_SHA256 c9188dc7d6c5351394036e99cafd9a8c9e2150d843a5f75fe4187fc4772c899a =====
VERDICT: ACCEPT WITH LIMITATIONS

Scope of this pass. Planning only. I executed nothing: no Lean, no Lake, no Python, no OpenSpec, no git. Every technical statement below is derived by reading the frozen bytes in this bundle. Author-produced status/evidence JSON is treated as an untrusted claim and is labelled as such. Requested model alias: `opus`. Actual responding model identity: claude-opus-5.

Bundle integrity. For every input in this r2 bundle, including `lean/lake-manifest.json` and all JSON evidence artifacts, ORIGINAL_SHA256 equals RENDERED_SHA256. The r1 rendering caveat is therefore resolved for the bytes actually supplied. Files referenced but not supplied (notably `review/semantic-kernel/sprint9/planning/runner-adaptation-map.json`, cited at sha256 1dbd4b54…, the `author-r1-snapshot/` tree, and the r1 GPT-6 report) cannot be checked here.

WHAT I VERIFIED AGAINST THE FROZEN KERNEL SOURCE

The design's reading of the existing code is accurate everywhere I could check it. `Composition.executeStep` validates the whole catalog first; invoke goes through `lookupOperation` (complete component/interface pair, `None` yielding `.interface .unknownOperation`), `resolveInputs` against the selected interface, `cfg.registry inv.operation`, `checkAccess`, `Typed.execute` (which consults `registry request.operation` exactly once), `extractReceipt` (same operation), and `snapshots` from the selected interface. Issue reaches `registryAuthorityConfig`'s `operationDomain = (registry op).map Template.domain` at `Grant.operation`; there is no `grant.scope` field (`Grant` = holder/domain/operation/right). Revoke reads the capability from the current store and consults `domainAdmin` at that dynamically read domain — which is exactly why all-domain administrator agreement, not issue-target agreement, is the right premise. `Composition.advance` is inert on a failed cursor; `continueRun` is a fold with `continueRun_nil`, `continueRun_append`, `continueRun_failed` available. `Parallel.observeBranch` keeps index/step/receipt/outputs, ordered history, nextIndex and located failure, and drops raw event before/after worlds.

The three M1 theorem families are derivable under this code, non-circularly.

Simulation. `runGroup = continueRun … (flatten g)` by induction on the three constructors: empty via `continueRun_nil`, leaf by unfolding one fold step, seq by `continueRun_append` and `flatten (seq a b) = flatten a ++ flatten b`. No success premise and no initial-cursor restriction are needed, and the equality is full cursor equality including raw event worlds. Empty identities, refusal absorption (`continueRun_failed`) and three-group associativity (`List.append_assoc` through the simulation) follow.

Observation adequacy. `advance` reads exactly `cursor.failure`, `cursor.nextIndex`, `cursor.outputs`, `cursor.world`. All four are observed by `CursorEquivalent`. Pointwise ledger equality plus `funext` plus proof irrelevance on `State.nonneg` plus structure eta gives literal `World` equality, so the same computational state is passed into `executeStep`; the appended event (including its `before` world) is then identical on both sides. Preservation under `advance` and `runGroup` is therefore sound, and the only omitted data (past raw event worlds, proof terms) is genuinely unread. `funext`/`Quot.sound`, `propext` and `Classical.choice` are inside the `AxiomAudit.allowedAxioms` set.

Universal-input `GroupEquivalent` and fill substitution. For `before fixed C`, congruence needs `runGroup` on the fixed prefix to map equivalent cursors to equivalent cursors and then the universal hypothesis at those (not the entry) cursors; for `after C fixed` it needs the hypothesis first and preservation second. The same-entry counterexample is genuinely load-bearing: two groups sharing an initially refusing first action produce identical failed cursors at the entry (suffixes inert), while a fixed authorized funding prefix enables the action and exposes the suffixes. Such a witness is constructible from the existing `Parallel.Examples` store, which already grants Alice `.debit vaultUSD` for operation 10.

Configuration agreement. Each of the four premise fields is used exactly where the plan says: registry equality at supported operations for `prepareInvocation`/`Typed.execute`/`extractReceipt`; complete `lookupOperation` equality (including `None`) for the invoke path; registry equality at `Grant.operation` for `operationDomain`; all-domain `domainAdmin` for revoke against an arbitrary store; both-catalogs-valid for the first guard and for equal `startCursor`. Nothing about execution equality is smuggled into the proposition, and no new checker appears. Lifting is mechanical: `checkCompatibility`, `checkSchedule`, `checkPolicy`, `mergeWorld`, `updateOutstanding`, `checkSupply`, `residuals` and `finish` are all configuration-free, and `runAtomic` depends on `cfg` only through `admit` and `executeStep`, so `Result` equality follows by congruence from equal cursors/machines rather than needing the design's extensionality fallback.

Counts, checked by reading. 4 capabilities; 17 requirements (4/4/5/4); 55 scenarios (16 configuration, 15 observation, 13 evidence, 11 sequential); 35 tasks, all unchecked; 14 mutants (8 routing, 6 observation). The frozen `cases()` inventory contains exactly 65 entries; 52 inherited (including `runtime-definition-after-proof-boundary`), 11 new proof-tail controls, 2 production-form controls. The r1 labelling ambiguity is resolved and the arithmetic is now correct. The scenario map renames only `discovered-atomic-dependency`.

Resolution of the six r1 items. All six are addressed in the r2 bytes, and two of them materially improve feasibility: the comparator-locality clause makes M09–M14 implementable without touching imported kernel bytes (leaf `DecidableEq` on `Receipt`/`LocatedFailure`/`Step` remains available), and the import-discipline clause removes the worst cost item, because avoiding `Atomic.Tests`/`Parallel.ObservationTests` keeps `Composition.Examples` and its `maxHeartbeats 2000000` `decide +kernel` workflow proof out of the runtime closure entirely (`Parallel.Examples` does not import it).

BLOCKERS

None. I found no false, circular or unprovable claim, no assumed `executeStep` equality, no invented certificate or admission checker, and no theorem the existing code cannot support.

REQUIRED CHANGES

1. Timeout evidence semantics contradict the frozen runner. Design §6 requires "Preserve partial logs and the timed-out command/limit," but in `check_atomic_mutations.py` the per-command log write and the `records.append` both occur after `subprocess.run` returns; a `TimeoutExpired` propagates to the top-level handler, giving exit 3 with no log file and no `results.json` entry for that command. The plan simultaneously fixes the control count at 65 and forbids behavior changes beyond the mapping, so a new timeout-capture path would be an uncontrolled behavior change. State which reading is intended: either (a) "preserve" means the harness stderr line naming the command and limit plus the retained fresh output directory and prior records, with no per-command log for the timed-out command, or (b) explicit timeout capture is added, in which case describe the added code and say how it is exercised without altering the 65-name map.

2. "Exhaustive across runtime identifiers" is stronger than the supplied table, and the map file that would settle it is not in this bundle. At minimum the table omits: the in-harness case-name tuple used for exact observation verification, which contains `discovered-atomic-dependency` and must be renamed there as well as in `cases()`; the harness assertion literal `error: Atomic runtime comparisons failed: 1`; and the runner's descriptive manifest fields (`audit_root` value and the `scope` sentence "Atomic proof tails excluded"). Require the implementation map to enumerate every literal `Atomic` occurrence in both frozen scripts with an explicit keep/rename decision and a recorded count, and include that map in the reviewed bytes.

3. Bind needle uniqueness for M01–M08. The runner blocks (exit 3) unless each needle occurs exactly once in the projected control source, and M01–M07 all target the same `seq` expression while M08 targets the leaf `Composition.advance` call. Require task 7.2 to state that the interpreter is written so each planned needle is a uniquely occurring string — in particular that the leaf call form is textually distinct from the `seq` recursion — since a collision silently converts a committed semantic detection into blocked evidence against a fixed count of 14.

NONBLOCKING LIMITATIONS

- The 14 mutants are 8 execution-routing detections plus 6 comparator-sensitivity detections on explicitly synthetic, generally unreachable cursor pairs. The r2 bytes now label this correctly; the final evidence must not present 14 as 14 financial-execution detections.
- Because each observation oracle differs in exactly one field, the six false-inventories should be distinct (unlike Sprint8's last-lane/last-participant collision). This should be recorded as a measured result, not assumed.
- Cost remains a measured risk rather than a proven bound. Under a Metatheory prefix, all Typed/Composition/Parallel/Interleaving/Atomic proof tails in the closure are inlined un-stripped in each of 15 fixtures. The mitigation is sound but unverified here; a timeout fails as blocked, so the failure mode is zero detections, not a false pass.
- Deciding pointwise ledger equality requires `Fintype` on cells, keeping all runtime evidence inside the finite typed universe. This follows existing `Parallel.worldEq` precedent.
- `ConfigAgreement` reflexivity is conditional on catalog validity, and full registry-template equality plus all-domain admin equality are deliberately non-minimal. The r2 bytes now say so; the negatives establish materiality only.
- Counterexample constructibility constraints are correctly stated (changed registry must alter guard/deltas/writes, not signature or output domain, since `validateCatalog` checks those; the grant-only domain witness needs an uncataloged operation; access/output changes must preserve export/import/private-cell validity).
- Claims I cannot verify from this bundle: the 14 Lean commands and 13 Python suites at 99e2e2c with 148 unchanged inputs, the 65-control baseline execution, the Sprint8 native acceptances, the remote-verified deliveries 2c03809/9501f0a, the r1 GPT-6 verdict, and the absence of any `lean/DefiKernel/Metatheory/` file. These are author-reported and internally consistent; they are not independent execution evidence here.

CLAIM/SCOPE CHECK

Claimed and supported: M1 only — recursive `SeqGroup` calling actual `Composition.advance` at leaves with entire-cursor propagation; `flatten` used only for the correspondence proof; full-cursor simulation with no success or initial-cursor premise; identity, refusal absorption, three-group associativity; exact continuation observations retaining ledger, complete store, ordered event index/step/receipt/outputs, frozen history, nextIndex and located failure, omitting only past raw event worlds and proof terms; restricted one-hole before/after fixed grammar with universally quantified `GroupEquivalent` and a real same-entry counterexample; explicit `ConfigAgreement` including grant-only operation support and all-domain admins; derived `executeStep` equality lifted through sequences, groups and the unchanged Parallel/Interleaving/Atomic operators with original static admission and error precedence.

Excluded, with no leakage found in proposal, design, tasks, the four specs or the wiki: no new certificate or program-admission checker, no finite-participant executor, no active-peer extension, no alias rewriter, no atomic-boundary regrouping, no interface/binding algebra, no causal monitors, no dynamic provenance, no general order independence or reassociation. Modified Capabilities is None; integration is limited to the new namespace, one root import and dedicated mutation scripts. The M2–M6 boundary is stated in three places and is not closed by analogy. Reviewer bindings follow the 2026-09-07 AGENTS.md override, and this report is one of the two independent planning verdicts required on these exact r2 bytes; it does not by itself authorize implementation.


===== INPUT review/semantic-kernel/sprint9/planning/r2-opus.invocation.json ORIGINAL_SHA256 e8f9461331cb20e370ba290b994bba122c87966ba656a1a068c91e8c583177fe RENDERED_SHA256 e8f9461331cb20e370ba290b994bba122c87966ba656a1a068c91e8c583177fe =====
{
  "provider": "opus",
  "requested_model": "opus",
  "argv": [
    "claude",
    "--print",
    "--model",
    "opus",
    "--effort",
    "medium",
    "--output-format",
    "json",
    "--tools",
    "",
    "--strict-mcp-config",
    "--mcp-config",
    "{\"mcpServers\":{}}",
    "--setting-sources",
    "",
    "--disable-slash-commands",
    "--no-session-persistence"
  ],
  "candidate": "47cd83136ab69b0975594a77c519f6611f6fb555",
  "bundle_sha256": "1831b58682b2de3500010e75e2dd6e6182f2c07ec6b836f5ac2318df1fa91c4d",
  "started_at": "2026-09-07T16:46:03.564791+00:00",
  "review_kind": "native independent OpenSpec planning review; no implementation or independent execution claimed; no Foreman",
  "cli_identity": {
    "path": "/home/charl/.local/share/claude/versions/2.1.261",
    "sha256": "4ae40dd1784e85753e742e09f267d29ecbb82890361ad3817d27560866d364a6",
    "version_exit": 0,
    "version_output": "2.1.261 (Claude Code)\n"
  },
  "exit_code": 0,
  "finished_at": "2026-09-07T16:51:15.979658+00:00",
  "response_sha256": "66564c1726da0af32825865e929c6016a55c15f5baf6a56e4c01cff14e48d247",
  "response_bytes": 14250,
  "reported_models": [
    "claude-opus-5"
  ],
  "is_error": false,
  "bundle_unchanged": true,
  "inputs_unchanged": true
}


===== INPUT review/semantic-kernel/sprint8/mutation-spec.json ORIGINAL_SHA256 91b1c2acddcb3542bb377a878177118125735d40d3845b59b0f6f55051a1a4fc RENDERED_SHA256 91b1c2acddcb3542bb377a878177118125735d40d3845b59b0f6f55051a1a4fc =====
{
  "schema_version": 1,
  "modules": [
    "DefiKernel.Atomic.Policy",
    "DefiKernel.Atomic.Execution",
    "DefiKernel.Atomic.Observation",
    "DefiKernel.Atomic.Examples",
    "DefiKernel.Atomic.Tests",
    "DefiKernel.Atomic.Audit"
  ],
  "mutations": [
    {
      "name": "retain-prefix-on-abort",
      "module": "DefiKernel.Atomic.Execution",
      "needle": "  | .aborted _ _ _ m => m.entryWorld",
      "replacement": "  | .aborted _ _ _ m => m.speculative.world",
      "required_false": [
        "atomic.fixture.abort.middle.public"
      ]
    },
    {
      "name": "continue-after-first-failure",
      "module": "DefiKernel.Atomic.Execution",
      "needle": "  match m.abort with\n  | some _ => m\n  | none =>",
      "replacement": "  match (none : Option (AbortReason P A D)) with\n  | some _ => m\n  | none =>",
      "required_false": [
        "atomic.fixture.abort.first.stopped"
      ]
    },
    {
      "name": "publish-aborted-outputs",
      "module": "DefiKernel.Atomic.Execution",
      "needle": "  | .aborted _ _ _ _ => []",
      "replacement": "  | .aborted label schedule _ m => [diagnosticEvent label schedule m]",
      "required_false": [
        "atomic.fixture.abort.outputs"
      ]
    },
    {
      "name": "count-aborted-supply",
      "module": "DefiKernel.Atomic.Execution",
      "needle": "  | .aborted _ _ _ _ => fun _ _ => 0",
      "replacement": "  | .aborted _ _ _ m => m.speculative.supply",
      "required_false": [
        "atomic.fixture.abort.supply"
      ]
    },
    {
      "name": "stale-entry-world",
      "module": "DefiKernel.Atomic.Execution",
      "needle": "    let next := Interleaving.advance cfg boundaries left right m.speculative branch",
      "replacement": "    let next := Interleaving.advance cfg boundaries left right\n      { m.speculative with world := m.entryWorld } branch",
      "required_false": [
        "atomic.fixture.live.complete"
      ]
    },
    {
      "name": "peer-history-leakage",
      "module": "DefiKernel.Atomic.Execution",
      "needle": "    let next := Interleaving.advance cfg boundaries left right m.speculative branch",
      "replacement": "    let peer := match branch with | .left => BranchId.right | .right => BranchId.left\n    let own := m.speculative.local branch\n    let leaky := m.speculative.setLocal branch\n      { own with outputs := own.outputs ++ (m.speculative.local peer).outputs }\n    let next := Interleaving.advance cfg boundaries left right leaky branch",
      "required_false": [
        "atomic.fixture.history.peer.only"
      ]
    },
    {
      "name": "global-boundary-index",
      "module": "DefiKernel.Atomic.Execution",
      "needle": "    let next := Interleaving.advance cfg boundaries left right m.speculative branch",
      "replacement": "    let next := Interleaving.advance cfg (fun b _ \u21a6 boundaries b m.position)\n      left right m.speculative branch",
      "required_false": [
        "atomic.fixture.boundary.local"
      ]
    },
    {
      "name": "erase-debt-without-receipt",
      "module": "DefiKernel.Atomic.Policy",
      "needle": "    owed lane p - receiptEffect receipt lane.cell else owed lane p",
      "replacement": "    (if receiptEffect receipt lane.cell = 0 then 0\n      else owed lane p - receiptEffect receipt lane.cell) else owed lane p",
      "required_false": [
        "atomic.fixture.settlement.noop"
      ]
    },
    {
      "name": "opposite-vault-effect-sign",
      "module": "DefiKernel.Atomic.Policy",
      "needle": "    owed lane p - receiptEffect receipt lane.cell else owed lane p",
      "replacement": "    owed lane p + receiptEffect receipt lane.cell else owed lane p",
      "required_false": [
        "atomic.fixture.settlement.under"
      ]
    },
    {
      "name": "global-settlement-sum",
      "module": "DefiKernel.Atomic.Policy",
      "needle": "  policy.lanes.flatMap fun lane \u21a6 policy.participants.filterMap fun principal \u21a6",
      "replacement": "  if (policy.lanes.flatMap fun lane \u21a6\n      policy.participants.map fun principal \u21a6 owed lane principal).sum = 0 then []\n  else policy.lanes.flatMap fun lane \u21a6 policy.participants.filterMap fun principal \u21a6",
      "required_false": [
        "atomic.fixture.settlement.cross.principal"
      ]
    },
    {
      "name": "collapse-principal-keys",
      "module": "DefiKernel.Atomic.Policy",
      "needle": "  fun lane p \u21a6 if lane \u2208 policy.lanes \u2227 p = principal then",
      "replacement": "  fun lane p \u21a6 if lane \u2208 policy.lanes \u2227 True then",
      "required_false": [
        "atomic.fixture.settlement.cross.principal"
      ]
    },
    {
      "name": "collapse-asset-domain-keys",
      "module": "DefiKernel.Atomic.Policy",
      "needle": "    owed lane p - receiptEffect receipt lane.cell else owed lane p",
      "replacement": "    owed lane p - (policy.lanes.map\n      (fun candidate \u21a6 receiptEffect receipt candidate.cell)).sum else owed lane p",
      "required_false": [
        "atomic.fixture.settlement.cross.asset",
        "atomic.fixture.settlement.cross.domain"
      ]
    },
    {
      "name": "omit-final-lane",
      "module": "DefiKernel.Atomic.Policy",
      "needle": "  policy.lanes.flatMap fun lane \u21a6 policy.participants.filterMap fun principal \u21a6\n    if owed lane principal = 0 then none else some \u27e8lane, principal, owed lane principal\u27e9",
      "replacement": "  (policy.lanes.take (policy.lanes.length - 1)).flatMap fun lane \u21a6\n    policy.participants.filterMap fun principal \u21a6\n      if owed lane principal = 0 then none else some \u27e8lane, principal, owed lane principal\u27e9",
      "required_false": [
        "atomic.fixture.settlement.last.lane"
      ]
    },
    {
      "name": "omit-final-participant",
      "module": "DefiKernel.Atomic.Policy",
      "needle": "  policy.lanes.flatMap fun lane \u21a6 policy.participants.filterMap fun principal \u21a6\n    if owed lane principal = 0 then none else some \u27e8lane, principal, owed lane principal\u27e9",
      "replacement": "  policy.lanes.flatMap fun lane \u21a6\n    (policy.participants.take (policy.participants.length - 1)).filterMap fun principal \u21a6\n      if owed lane principal = 0 then none else some \u27e8lane, principal, owed lane principal\u27e9",
      "required_false": [
        "atomic.fixture.settlement.last.participant"
      ]
    },
    {
      "name": "accept-lane-supply",
      "module": "DefiKernel.Atomic.Execution",
      "needle": "        match checkSupply policy result.receipt with",
      "replacement": "        match (none : Option (Lane P A D \u00d7 \u211a)) with",
      "required_false": [
        "atomic.fixture.supply.lane.nonvault"
      ]
    },
    {
      "name": "resurrect-revoked-grants",
      "module": "DefiKernel.Atomic.Execution",
      "needle": "    let next := Interleaving.advance cfg boundaries left right m.speculative branch",
      "replacement": "    let resurrected := { m.speculative.world with capabilities :=\n      \u27e8m.speculative.world.capabilities.entries.map (fun cap \u21a6 { cap with live := true })\u27e9 }\n    let next := Interleaving.advance cfg boundaries left right\n      { m.speculative with world := resurrected } branch",
      "required_false": [
        "atomic.fixture.capability.revoked"
      ]
    },
    {
      "name": "omit-abort-reason",
      "module": "DefiKernel.Atomic.Observation",
      "needle": "def observationEq (left right : Observation P A D) : Bool :=\n  decide (left.label = right.label) && decide (left.schedule = right.schedule) &&\n    decide (left.outcome = right.outcome) && worldEq left.world right.world &&\n    decide (left.events = right.events) && decide (\u2200 d a, left.supply d a = right.supply d a)",
      "replacement": "def observationEq (left right : Observation P A D) : Bool :=\n  let normalize : Outcome P A D \u2192 Outcome P A D := fun outcome \u21a6\n    match outcome with\n    | .aborted (.kernel branch index position invocation _) =>\n      .aborted (.kernel branch index position invocation .configuration)\n    | other => other\n  decide (left.label = right.label) && decide (left.schedule = right.schedule) &&\n    decide (normalize left.outcome = normalize right.outcome) && worldEq left.world right.world &&\n    decide (left.events = right.events) && decide (\u2200 d a, left.supply d a = right.supply d a)",
      "required_false": [
        "atomic.observe.abort.reason"
      ]
    },
    {
      "name": "omit-residual-amount",
      "module": "DefiKernel.Atomic.Observation",
      "needle": "def observationEq (left right : Observation P A D) : Bool :=\n  decide (left.label = right.label) && decide (left.schedule = right.schedule) &&\n    decide (left.outcome = right.outcome) && worldEq left.world right.world &&\n    decide (left.events = right.events) && decide (\u2200 d a, left.supply d a = right.supply d a)",
      "replacement": "def observationEq (left right : Observation P A D) : Bool :=\n  let normalize : Outcome P A D \u2192 Outcome P A D := fun outcome \u21a6\n    match outcome with\n    | .aborted (.unsettled remaining) =>\n      .aborted (.unsettled (remaining.map fun residual \u21a6 { residual with amount := 0 }))\n    | other => other\n  decide (left.label = right.label) && decide (left.schedule = right.schedule) &&\n    decide (normalize left.outcome = normalize right.outcome) && worldEq left.world right.world &&\n    decide (left.events = right.events) && decide (\u2200 d a, left.supply d a = right.supply d a)",
      "required_false": [
        "atomic.observe.residual.amount"
      ]
    }
  ],
  "positive_checks": [
    "atomic.fixture.empty",
    "atomic.fixture.empty.batch",
    "atomic.fixture.catalog",
    "atomic.fixture.store",
    "atomic.fixture.batch.single",
    "atomic.observe.equal"
  ]
}


===== INPUT lean/DefiKernel/Atomic/Admission.lean ORIGINAL_SHA256 e41a34eee617720bbb443253189eafa7934ef6e1603fb197aee6961d84535360 RENDERED_SHA256 e41a34eee617720bbb443253189eafa7934ef6e1603fb197aee6961d84535360 =====
import DefiKernel.Atomic.Execution

/-! Admission decomposition keeps all structural checks ahead of policy and counts. -/
namespace DefiKernel.Atomic
open Typed Composition Parallel Interleaving

variable {P A D : Type} [DecidableEq P] [DecidableEq A] [DecidableEq D]

-- BEGIN PROOFS

theorem admit_ok (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (policy : Policy P A D) (left right : Branch P A D) (schedule : Schedule)
    (lf rf : Footprint P A D)
    (h : admit cfg boundaries policy left right schedule = .ok (lf, rf)) :
    validateCatalog cfg.registry cfg.catalog = true ∧
    analyzeBranch cfg (boundaries .left) left = .ok lf ∧
    analyzeBranch cfg (boundaries .right) right = .ok rf ∧
    checkPolicy policy boundaries left right = .ok ⟨⟩ ∧ Complete left right schedule := by
  unfold admit at h
  simp only [bind, Except.bind, pure, Except.pure] at h
  split at h
  · simp [throw, throwThe] at h
  rename_i hv
  split at h
  · contradiction
  rename_i l hl
  split at h
  · contradiction
  rename_i r hr
  split at h
  · contradiction
  rename_i policyToken hp
  split at h
  · contradiction
  rename_i scheduleToken hs
  cases policyToken
  cases scheduleToken
  obtain ⟨rfl, rfl⟩ := Prod.mk.inj (Except.ok.inj h)
  have unmap {E F X : Type} (f : E → F) (x : Except E X) (v : X)
      (hx : x.mapError f = .ok v) : x = .ok v := by
    cases x <;> simp_all [Except.mapError]
  exact ⟨by simpa using hv, unmap _ _ _ hl, unmap _ _ _ hr, unmap _ _ _ hp,
    (checkSchedule_ok_iff _ _ _).mp (unmap _ _ _ hs)⟩

theorem admit_of_checks (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (policy : Policy P A D) (left right : Branch P A D) (schedule : Schedule)
    (lf rf : Footprint P A D) (hv : validateCatalog cfg.registry cfg.catalog = true)
    (hl : analyzeBranch cfg (boundaries .left) left = .ok lf)
    (hr : analyzeBranch cfg (boundaries .right) right = .ok rf)
    (hp : checkPolicy policy boundaries left right = .ok ⟨⟩)
    (hs : Complete left right schedule) :
    admit cfg boundaries policy left right schedule = .ok (lf, rf) := by
  have hc := (checkSchedule_ok_iff left.length right.length schedule).mpr hs
  simp [admit, hv, hl, hr, hp, hc, bind, Except.bind, Except.mapError, pure, Except.pure]

theorem admit_interleaving (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (policy : Policy P A D) (left right : Branch P A D) (schedule : Schedule)
    (lf rf : Footprint P A D)
    (h : admit cfg boundaries policy left right schedule = .ok (lf, rf)) :
    Interleaving.admit cfg boundaries left right schedule = .ok (lf, rf) := by
  obtain ⟨hv, hl, hr, _, hs⟩ := admit_ok _ _ _ _ _ _ _ _ h
  exact Interleaving.admit_of_checks _ _ _ _ _ _ _ hv hl hr hs

end DefiKernel.Atomic


===== INPUT lean/DefiKernel/Atomic/Audit.lean ORIGINAL_SHA256 73e592571182e95006db5a57f914ca8f7cbe8de51983ada3cac0de0d046141ff RENDERED_SHA256 73e592571182e95006db5a57f914ca8f7cbe8de51983ada3cac0de0d046141ff =====
import DefiKernel.Atomic.Tests

namespace DefiKernel.Atomic.Audit

def main : IO Unit := do
  let checks := Tests.runtimeChecks
  if checks.isEmpty then throw (IO.userError "Atomic runtime comparisons empty")
  if !(checks.map Prod.fst).Nodup then
    throw (IO.userError "Atomic runtime comparison names are duplicated")
  for (name, passed) in checks do IO.println s!"{name}: {passed}"
  let failures := checks.filter (!·.2) |>.map Prod.fst
  if !failures.isEmpty then
    throw (IO.userError s!"Atomic runtime comparisons failed: {failures.length}")

#eval main

-- BEGIN PROOFS

end DefiKernel.Atomic.Audit


===== INPUT lean/DefiKernel/Atomic/Completion.lean ORIGINAL_SHA256 4118076759416087e20ff9093fbe47c7342e72cf7648828cfd492166bcf07646 RENDERED_SHA256 4118076759416087e20ff9093fbe47c7342e72cf7648828cfd492166bcf07646 =====
import DefiKernel.Atomic.Soundness
import DefiKernel.Atomic.Admission
import DefiKernel.Interleaving.Completion

/-! Committing requires no earlier abort and full typed clearance. Complete active
atomic runs agree with the supplied complete interleaving, including local exhaustion. -/
namespace DefiKernel.Atomic
open Typed Composition Parallel Interleaving

variable {P A D : Type} [DecidableEq P] [DecidableEq A] [DecidableEq D]
variable [Fintype P] [Fintype A] [Fintype D]

-- BEGIN PROOFS

omit [DecidableEq P] [DecidableEq A] [DecidableEq D] [Fintype P] [Fintype A] [Fintype D] in
theorem finish_commit_data (label label' : Nat) (schedule schedule' : Schedule)
    (policy : Policy P A D) (m m' : Machine P A D)
    (h : finish label schedule policy m = .committed label' schedule' m') :
    label = label' ∧ schedule = schedule' ∧ m = m' ∧
      m.abort = none ∧ residuals policy m.outstanding = [] := by
  cases ha : m.abort with
  | some reason => simp [finish, ha] at h
  | none =>
    cases hr : residuals policy m.outstanding with
    | nil =>
      simp only [finish, ha, hr, Result.committed.injEq] at h
      exact ⟨h.1, h.2.1, h.2.2, rfl, rfl⟩
    | cons r rest => simp [finish, ha, hr] at h

omit [DecidableEq P] [DecidableEq A] [DecidableEq D] [Fintype P] [Fintype A] [Fintype D] in
theorem finish_commit_iff (label : Nat) (schedule : Schedule)
    (policy : Policy P A D) (m : Machine P A D) :
    finish label schedule policy m = .committed label schedule m ↔
      m.abort = none ∧ residuals policy m.outstanding = [] := by
  constructor
  · intro h
    exact (finish_commit_data _ _ _ _ _ _ _ h).2.2.2
  · rintro ⟨ha, hr⟩
    simp [finish, ha, hr]

theorem runAtomic_commit_data (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (label : Nat) (policy : Policy P A D) (initial : World P A D)
    (left right : Branch P A D) (schedule : Schedule) (m : Machine P A D)
    (h : runAtomic cfg boundaries label policy initial left right schedule =
      .committed label schedule m) :
    ∃ lf rf, admit cfg boundaries policy left right schedule = .ok (lf, rf) ∧
      m = runPrefix cfg boundaries policy initial left right schedule ∧
      m.abort = none ∧ residuals policy m.outstanding = [] := by
  cases ha : admit cfg boundaries policy left right schedule with
  | error reason => simp [runAtomic, ha] at h
  | ok pair =>
    simp only [runAtomic, ha] at h
    obtain ⟨_, _, hm, habort, hr⟩ := finish_commit_data _ _ _ _ _ _ _ h
    subst m
    exact ⟨pair.1, pair.2, rfl, rfl, habort, hr⟩

theorem runPrefix_active_interleaving (cfg : Config P A D)
    (boundaries : ParallelBoundary P A D) (policy : Policy P A D)
    (initial : World P A D) (left right : Branch P A D) (schedule : Schedule)
    (active : (runPrefix cfg boundaries policy initial left right schedule).abort = none) :
    (runPrefix cfg boundaries policy initial left right schedule).speculative =
      Interleaving.runPrefix cfg boundaries initial left right schedule := by
  obtain ⟨preTokens, suffix, hs, hm, _, hf⟩ :=
    runPrefix_prefix cfg boundaries policy initial left right schedule
  have empty := hf active
  subst suffix
  simp only [List.append_nil] at hs
  subst schedule
  exact hm

theorem runPrefix_complete_active_exhaustion (cfg : Config P A D)
    (boundaries : ParallelBoundary P A D) (policy : Policy P A D)
    (initial : World P A D) (left right : Branch P A D) (schedule : Schedule)
    (complete : Complete left right schedule)
    (active : (runPrefix cfg boundaries policy initial left right schedule).abort = none)
    (b : BranchId) :
    ((runPrefix cfg boundaries policy initial left right schedule).speculative.local b).failure =
      none ∧
    ((runPrefix cfg boundaries policy initial left right schedule).speculative.local b).nextIndex =
      (selectBranch left right b).length := by
  have hf := (runPrefix_reachable cfg boundaries policy initial left right schedule).no_failures
    active b
  refine ⟨hf, ?_⟩
  rw [runPrefix_active_interleaving _ _ _ _ _ _ _ active] at hf ⊢
  exact Interleaving.runPrefix_complete_active_exhaustion _ _ _ _ _ _ complete b hf

theorem runAtomic_commit_interleaving (cfg : Config P A D)
    (boundaries : ParallelBoundary P A D) (label : Nat) (policy : Policy P A D)
    (initial : World P A D) (left right : Branch P A D) (schedule : Schedule)
    (m : Machine P A D)
    (h : runAtomic cfg boundaries label policy initial left right schedule =
      .committed label schedule m) :
    Interleaving.runInterleaving cfg boundaries initial left right schedule =
      .executed schedule m.speculative ∧
    ∀ b, (m.speculative.local b).failure = none ∧
      (m.speculative.local b).nextIndex = (selectBranch left right b).length := by
  obtain ⟨lf, rf, ha, rfl, active, _⟩ := runAtomic_commit_data _ _ _ _ _ _ _ _ _ h
  have hi := admit_interleaving _ _ _ _ _ _ _ _ ha
  have complete := (admit_ok _ _ _ _ _ _ _ _ ha).2.2.2.2
  constructor
  · rw [Interleaving.runInterleaving, hi, runPrefix_active_interleaving _ _ _ _ _ _ _ active]
  · exact runPrefix_complete_active_exhaustion _ _ _ _ _ _ _ complete active

end DefiKernel.Atomic


===== INPUT lean/DefiKernel/Atomic/Correspondence.lean ORIGINAL_SHA256 8464d1eb548fa8e028144118579db317d0f667ae3761cf4c40fad393503c46f2 RENDERED_SHA256 8464d1eb548fa8e028144118579db317d0f667ae3761cf4c40fad393503c46f2 =====
import DefiKernel.Atomic.Completion
import DefiKernel.Atomic.Settlement

/-! The converse uses only actual underlying attempts, their receipt supply checks, and
clearance of an independent receipt fold. It does not assume an atomic outcome or agreement. -/
namespace DefiKernel.Atomic
open Typed Composition Parallel Interleaving

variable {P A D : Type} [DecidableEq P] [DecidableEq A] [DecidableEq D]

/-- Each actual underlying attempt succeeded and its actual receipt obeyed lane supply policy. -/
def GoodAttempts (policy : Policy P A D) (attempts : List (Attempt P A D)) : Prop :=
  ∀ attempt ∈ attempts, ∃ result, attempt.outcome = .ok result ∧
    checkSupply policy result.receipt = none

variable [Fintype P] [Fintype A] [Fintype D]

-- BEGIN PROOFS

omit [DecidableEq P] [Fintype P] [Fintype A] [Fintype D] in
theorem GoodAttempts.sublist {policy : Policy P A D} {xs ys : List (Attempt P A D)}
    (h : GoodAttempts policy ys) (sub : xs.Sublist ys) : GoodAttempts policy xs :=
  fun attempt member ↦ h attempt (sub.subset member)

theorem interleaving_advance_attempts_sublist (cfg : Config P A D)
    (boundaries : ParallelBoundary P A D) (left right : Branch P A D)
    (m : Interleaving.Machine P A D) (b : BranchId) :
    m.attempts.Sublist (Interleaving.advance cfg boundaries left right m b).attempts := by
  cases hf : (m.local b).failure with
  | some failure => simp [Interleaving.advance, hf, skip_attempts]
  | none =>
    cases hs : (selectBranch left right b)[(m.local b).consumed]? with
    | none => simp [Interleaving.advance, hf, hs, skip_attempts]
    | some inv =>
      rw [interleaving_advance_appended _ _ _ _ _ _ _ hf hs]
      exact List.sublist_append_left _ _

theorem interleaving_continueRun_attempts_sublist (cfg : Config P A D)
    (boundaries : ParallelBoundary P A D) (left right : Branch P A D)
    (m : Interleaving.Machine P A D) (schedule : Schedule) :
    m.attempts.Sublist
      (Interleaving.continueRun cfg boundaries left right m schedule).attempts := by
  induction schedule generalizing m with
  | nil => exact List.Sublist.refl _
  | cons b tail ih =>
    exact (interleaving_advance_attempts_sublist _ _ _ _ _ _).trans (ih _)

/-- A successful, policy-compliant actual next attempt cannot create an atomic abort. -/
theorem advance_no_abort_of_good_attempts (cfg : Config P A D)
    (boundaries : ParallelBoundary P A D) (policy : Policy P A D)
    (left right : Branch P A D) (m : Machine P A D) (b : BranchId)
    (active : m.abort = none)
    (good : GoodAttempts policy
      (Interleaving.advance cfg boundaries left right m.speculative b).attempts) :
    (advance cfg boundaries policy left right m b).abort = none := by
  cases hg : (Interleaving.advance cfg boundaries left right m.speculative b).attempts[
      m.speculative.attempts.length]? with
  | none => simp [advance, active, hg]
  | some attempt =>
    have hm := List.mem_of_getElem? hg
    obtain ⟨result, he, hs⟩ := good attempt hm
    simp [advance, active, hg, he, hs]

/-- Final actual-trace premises propagate backward to each prefix by attempt-list inclusion. -/
theorem continueRun_no_abort_of_good_attempts (cfg : Config P A D)
    (boundaries : ParallelBoundary P A D) (policy : Policy P A D)
    (left right : Branch P A D) (m : Machine P A D) (schedule : Schedule)
    (active : m.abort = none)
    (good : GoodAttempts policy
      (Interleaving.continueRun cfg boundaries left right m.speculative schedule).attempts) :
    (continueRun cfg boundaries policy left right m schedule).abort = none := by
  induction schedule generalizing m with
  | nil => exact active
  | cons b tail ih =>
    have hsub := interleaving_continueRun_attempts_sublist cfg boundaries left right
      (Interleaving.advance cfg boundaries left right m.speculative b) tail
    have hgood := good.sublist hsub
    have hactive := advance_no_abort_of_good_attempts cfg boundaries policy left right m b
      active hgood
    apply ih (advance cfg boundaries policy left right m b) hactive
    rw [advance_speculative _ _ _ _ _ _ _ active]
    exact good

theorem runPrefix_no_abort_of_good_attempts (cfg : Config P A D)
    (boundaries : ParallelBoundary P A D) (policy : Policy P A D)
    (initial : World P A D) (left right : Branch P A D) (schedule : Schedule)
    (good : GoodAttempts policy
      (Interleaving.runPrefix cfg boundaries initial left right schedule).attempts) :
    (runPrefix cfg boundaries policy initial left right schedule).abort = none :=
  continueRun_no_abort_of_good_attempts cfg boundaries policy left right (Atomic.start initial)
    schedule rfl good

/-- Noncircular converse: successful underlying receipts and full independent-fold clearance
suffice to commit an admitted atomic event. -/
theorem runAtomic_commit_of_interleaving (cfg : Config P A D)
    (boundaries : ParallelBoundary P A D) (label : Nat) (policy : Policy P A D)
    (initial : World P A D) (left right : Branch P A D) (schedule : Schedule)
    (lf rf : Footprint P A D)
    (admitted : admit cfg boundaries policy left right schedule = .ok (lf, rf))
    (good : GoodAttempts policy
      (Interleaving.runPrefix cfg boundaries initial left right schedule).attempts)
    (cleared : residuals policy (outstandingFromAttempts policy boundaries
      (Interleaving.runPrefix cfg boundaries initial left right schedule).attempts) = []) :
    runAtomic cfg boundaries label policy initial left right schedule =
      .committed label schedule (runPrefix cfg boundaries policy initial left right schedule) := by
  have active := runPrefix_no_abort_of_good_attempts cfg boundaries policy initial left right
    schedule good
  have hf :=
    (runPrefix_reachable cfg boundaries policy initial left right schedule).outstanding_fold
  rw [runPrefix_active_interleaving _ _ _ _ _ _ _ active] at hf
  have hc : residuals policy
      (runPrefix cfg boundaries policy initial left right schedule).outstanding = [] := by
    rw [hf]
    exact cleared
  simp only [runAtomic, admitted]
  exact (finish_commit_iff _ _ _ _).mpr ⟨active, hc⟩

/-- Remaining active proves that an actual appended attempt succeeded and passed supply policy. -/
theorem advance_last_good (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (policy : Policy P A D) (left right : Branch P A D) (m : Machine P A D)
    (b : BranchId) (attempt : Attempt P A D)
    (active : (advance cfg boundaries policy left right m b).abort = none)
    (appended : getElem?
      (Interleaving.advance cfg boundaries left right m.speculative b).attempts
      m.speculative.attempts.length = some attempt) :
    ∃ result, attempt.outcome = .ok result ∧ checkSupply policy result.receipt = none := by
  have old := advance_none_before _ _ _ _ _ _ _ active
  cases he : attempt.outcome with
  | error reason => simp [advance, old, appended, he] at active
  | ok result =>
    refine ⟨result, rfl, ?_⟩
    cases hs : checkSupply policy result.receipt with
    | none => rfl
    | some pair => simp [advance, old, appended, he, hs] at active

theorem advance_goodAttempts (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (policy : Policy P A D) (left right : Branch P A D) (m : Machine P A D) (b : BranchId)
    (old : GoodAttempts policy m.speculative.attempts)
    (active : (advance cfg boundaries policy left right m b).abort = none) :
    GoodAttempts policy (advance cfg boundaries policy left right m b).speculative.attempts := by
  have ha := advance_none_before _ _ _ _ _ _ _ active
  rw [advance_speculative _ _ _ _ _ _ _ ha]
  cases hf : (m.speculative.local b).failure with
  | some failure => simpa only [Interleaving.advance, hf, skip_attempts] using old
  | none =>
    cases hs : (selectBranch left right b)[(m.speculative.local b).consumed]? with
    | none => simpa only [Interleaving.advance, hf, hs, skip_attempts] using old
    | some inv =>
      have hg := interleaving_advance_attempt cfg boundaries left right m.speculative b inv hf hs
      have hlast := advance_last_good _ _ _ _ _ _ _ _ active hg
      rw [interleaving_advance_appended _ _ _ _ _ _ _ hf hs]
      intro attempt member
      rcases List.mem_append.mp member with earlier | latest
      · exact old attempt earlier
      · have he := List.mem_singleton.mp latest
        subst attempt
        exact hlast

theorem Reachable.goodAttempts {cfg : Config P A D} {boundaries : ParallelBoundary P A D}
    {policy : Policy P A D} {left right : Branch P A D} {initial : World P A D}
    {m : Machine P A D} (h : Reachable cfg boundaries policy left right initial m)
    (active : m.abort = none) : GoodAttempts policy m.speculative.attempts := by
  induction h with
  | start => simp [GoodAttempts, Atomic.start, Interleaving.start]
  | next b previous ih =>
    exact advance_goodAttempts _ _ _ _ _ _ _
      (ih (advance_none_before _ _ _ _ _ _ _ active)) active

/-- Bidirectional criterion on actual underlying execution and its independently derived debt. -/
theorem runAtomic_commit_iff_interleaving (cfg : Config P A D)
    (boundaries : ParallelBoundary P A D) (label : Nat) (policy : Policy P A D)
    (initial : World P A D) (left right : Branch P A D) (schedule : Schedule)
    (lf rf : Footprint P A D)
    (admitted : admit cfg boundaries policy left right schedule = .ok (lf, rf)) :
    runAtomic cfg boundaries label policy initial left right schedule =
      .committed label schedule (runPrefix cfg boundaries policy initial left right schedule) ↔
    GoodAttempts policy
      (Interleaving.runPrefix cfg boundaries initial left right schedule).attempts ∧
      residuals policy (outstandingFromAttempts policy boundaries
        (Interleaving.runPrefix cfg boundaries initial left right schedule).attempts) = [] := by
  constructor
  · intro committed
    obtain ⟨_, _, _, _, active, cleared⟩ :=
      runAtomic_commit_data _ _ _ _ _ _ _ _ _ committed
    have reach := runPrefix_reachable cfg boundaries policy initial left right schedule
    have agreement := runPrefix_active_interleaving _ _ _ _ _ _ _ active
    have good := reach.goodAttempts active
    have fold := reach.outstanding_fold
    rw [agreement] at good fold
    exact ⟨good, by rwa [fold] at cleared⟩
  · rintro ⟨good, cleared⟩
    exact runAtomic_commit_of_interleaving _ _ _ _ _ _ _ _ _ _ admitted good cleared

/-- A committed event restores each configured lane vault exactly, for arbitrary typed policies. -/
theorem runAtomic_commit_cash (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (label : Nat) (policy : Policy P A D) (initial : World P A D)
    (left right : Branch P A D) (schedule : Schedule) (m : Machine P A D)
    (committed : runAtomic cfg boundaries label policy initial left right schedule =
      .committed label schedule m) (lane : Lane P A D) (hlane : lane ∈ policy.lanes) :
    m.speculative.world.state.balance lane.cell = initial.state.balance lane.cell := by
  obtain ⟨lf, rf, ha, rfl, _, hc⟩ := runAtomic_commit_data _ _ _ _ _ _ _ _ _ committed
  exact (runPrefix_reachable _ _ _ _ _ _ _).cleared_cash
    (admit_ok _ _ _ _ _ _ _ _ ha).2.2.2.1 hc lane hlane

end DefiKernel.Atomic


===== INPUT lean/DefiKernel/Atomic/Examples.lean ORIGINAL_SHA256 771ce6a4de4a24082bcc75c842ac2db3ac072cc63586cd24aecc86c72b097af4 RENDERED_SHA256 771ce6a4de4a24082bcc75c842ac2db3ac072cc63586cd24aecc86c72b097af4 =====
import DefiKernel.Atomic.Policy
import DefiKernel.Parallel.Examples

/-! Independent exact-rational Atomic fixture data. Expected worlds, receipts and outputs never
select an Atomic or Interleaving execution result. These are development examples, not fidelity. -/
namespace DefiKernel.Atomic.Examples
open Typed Composition Parallel Typed.Examples
open Parallel.Examples (C W I B Evt Obs cells cellRef packed output event transferEvent observed)

abbrev P := Party
abbrev A := Asset
abbrev D := Domain

def usdVault : C := (.main, .vault, .usd)
def usdAlice : C := (.main, .alice, .usd)
def usdBob : C := (.main, .bob, .usd)
def shareVault : C := (.main, .vault, .share)
def shareAlice : C := (.main, .alice, .share)
def otherVault : C := (.other, .vault, .usd)
def otherAlice : C := (.other, .alice, .usd)
def collateral : C := (.main, .alice, .collateral)
def refAt (d : D) (a : A) (p : PartyRef P) : CellRef P A D a := ⟨d, p⟩
def packedAt (d : D) (a : A) (p : PartyRef P) : PackedCellRef P A D := ⟨a, refAt d a p⟩

def transferAt (d : D) (a : A) (sender recipient : PartyRef P) : Op where
  signature := [.amount a]
  domain := d
  partyArity := 0
  guard := nonnegative a (.arg .here)
  deltas := [⟨a, refAt d a sender, negate a (.arg .here)⟩,
    ⟨a, refAt d a recipient, .arg .here⟩]
  supplyDeltas := []
  stateReads := []
  envReads := []
  writes := [packedAt d a sender, packedAt d a recipient]

def drawTemplate := transferAt .main .usd (.literal .vault) .caller
def repayTemplate := transferAt .main .usd .caller (.literal .vault)
def drawShareTemplate := transferAt .main .share (.literal .vault) .caller
def repayShareTemplate := transferAt .main .share .caller (.literal .vault)
def drawOtherTemplate := transferAt .other .usd (.literal .vault) .caller
def repayOtherTemplate := transferAt .other .usd .caller (.literal .vault)
def noopTemplate : Op := { drawTemplate with deltas := [], writes := [] }
def repeatedTemplate : Op := { drawTemplate with
  deltas := [⟨.usd, refAt .main .usd (.literal .vault), negate .usd (.arg .here)⟩,
    ⟨.usd, refAt .main .usd (.literal .vault), negate .usd (.arg .here)⟩,
    ⟨.usd, refAt .main .usd .caller,
      .binary (.add (.amount Asset.usd)) (.arg .here) (.arg .here)⟩] }
def mintAt (a : A) : Op where
  signature := [.amount a]
  domain := .main
  partyArity := 0
  guard := .lit true
  deltas := [⟨a, refAt .main a .caller, .arg .here⟩]
  supplyDeltas := [⟨.main, a, .arg .here⟩]
  stateReads := []
  envReads := []
  writes := [packedAt .main a .caller]
def timedDrawTemplate : Op where
  signature := [.amount .usd, .scalar]
  domain := .main
  partyArity := 0
  guard := .binary (.eq .scalar) .now (.arg (.there .here))
  deltas := [⟨.usd, refAt .main .usd (.literal .vault), negate .usd (.arg .here)⟩,
    ⟨.usd, refAt .main .usd .caller, .arg .here⟩]
  supplyDeltas := []
  stateReads := []
  envReads := [.currentTime]
  writes := [packedAt .main .usd (.literal .vault), packedAt .main .usd .caller]
def liveDrawTemplate : Op := { drawTemplate with
  deltas := [⟨.usd, cellRef usdVault,
    .binary (.scale (.amount Asset.usd)) (.lit (-1 / 2 : ℚ)) (.balance (cellRef usdVault))⟩,
    ⟨.usd, refAt .main .usd .caller,
      .binary (.scale (.amount Asset.usd)) (.lit (1 / 2 : ℚ)) (.balance (cellRef usdVault))⟩]
  stateReads := [packed usdVault] }

structure FixtureOp where
  id : Nat
  template : Op
  output : C

def operations : List FixtureOp := [
  ⟨100, drawTemplate, usdVault⟩, ⟨101, repayTemplate, usdVault⟩,
  ⟨102, drawShareTemplate, shareVault⟩, ⟨103, repayShareTemplate, shareVault⟩,
  ⟨104, drawOtherTemplate, otherVault⟩, ⟨105, repayOtherTemplate, otherVault⟩,
  ⟨106, noopTemplate, usdVault⟩, ⟨107, repeatedTemplate, usdVault⟩,
  ⟨108, mintAt .usd, usdAlice⟩, ⟨109, mintAt .share, shareAlice⟩,
  ⟨110, timedDrawTemplate, usdVault⟩, ⟨111, liveDrawTemplate, usdVault⟩]

def fixtureComponent (op : FixtureOp) : Component P A D :=
  ⟨⟨op.id⟩, [], [], cells.zipIdx.map (fun (c, n) ↦ ⟨⟨⟨999⟩, ⟨n⟩⟩, c, true⟩),
    [⟨⟨op.id⟩, op.template.signature.zipIdx.map (fun (u, n) ↦ ⟨⟨10 + n⟩, u⟩),
      [⟨⟨0⟩, op.output⟩]⟩]⟩
def atomCfg : Config P A D where
  registry id := (operations.find? (fun op ↦ id = ⟨op.id⟩)).map FixtureOp.template
  domainAdmin := domainAdmin
  catalog := operations.map fixtureComponent ++
    [⟨⟨999⟩, [], cells.zipIdx.map (fun (c, n) ↦ ⟨⟨n⟩, c, true⟩), [], []⟩]

/-- Exact grants for funded Alice/Bob controls. First entry authorizes Alice's USD draw. -/
def atomStore : Store := ⟨operations.flatMap fun op ↦
  [Party.alice, .bob].flatMap fun actor ↦
    ([Right.invoke, .debit (op.template.domain, .alice, op.output.2.2),
      .debit (op.template.domain, .bob, op.output.2.2),
      .debit (op.template.domain, .vault, op.output.2.2),
      .changeSupply op.template.domain op.output.2.2]).map fun right ↦
        ⟨⟨actor, op.template.domain, ⟨op.id⟩, right⟩, true⟩⟩
def atomCaps : List CapabilityId := (List.range 120).map CapabilityId.mk
def revokedStore : Store := ⟨atomStore.entries.set 0
  ⟨⟨.alice, .main, ⟨100⟩, .invoke⟩, false⟩⟩

/-- Complete tables retain protected collateral9 and set every unlisted cell to zero. -/
def balanceTable (alice bob vault ash vsh oa ov : ℚ) : C → ℚ := fun c ↦
  if c = usdAlice then alice else if c = usdBob then bob else if c = usdVault then vault
  else if c = shareAlice then ash else if c = shareVault then vsh
  else if c = otherAlice then oa else if c = otherVault then ov
  else if c = collateral then 9 else 0

def atomWorld (alice bob vault ash vsh oa ov : Nat) (store : Store := atomStore) : W :=
  ⟨⟨balanceTable alice bob vault ash vsh oa ov, by
    intro c
    simp only [balanceTable]
    repeat' split
    all_goals positivity⟩, store⟩
def atomInitial := atomWorld 1 7 10 8 10 8 10
def afterDraw := atomWorld 8 7 3 8 10 8 10
def afterUnder := atomWorld 2 7 9 8 10 8 10
def afterOver := atomWorld 0 7 11 8 10 8 10
def afterPeerReturn := atomWorld 8 0 10 8 10 8 10
def afterAssetReturn := atomWorld 8 7 3 1 17 8 10
def afterDomainReturn := atomWorld 8 7 3 8 10 1 17
def afterLastLane := atomWorld 1 7 10 9 9 8 10
def afterLastParticipant := atomWorld 1 14 3 8 10 8 10
def afterLaneMint := atomWorld 4 7 10 8 10 8 10
def afterNonlaneMint := atomWorld 1 7 10 11 10 8 10
def afterDrawNonlaneMint := atomWorld 8 7 3 11 10 8 10
def revokedInitial := atomWorld 1 7 10 8 10 8 10 revokedStore

def atomBoundary (_ : BranchId) (_ : Nat) : Boundary P A D :=
  ⟨⟨.alice, .main⟩, fresh, 100⟩
def peerBoundary (branch : BranchId) (_ : Nat) : Boundary P A D :=
  ⟨⟨if branch = .left then .alice else .bob, .main⟩, fresh, 100⟩
def otherBoundary (branch : BranchId) (_ : Nat) : Boundary P A D :=
  ⟨⟨.alice, if branch = .left then .main else .other⟩, fresh, 100⟩
def localBoundary (branch : BranchId) (index : Nat) : Boundary P A D :=
  ⟨⟨if branch = .right then .bob else .alice, .main⟩, fresh,
    (if branch = .left then 100 else 200) + index⟩

def invocation (op : Nat) (a : A) (q : ℚ) : I :=
  ⟨⟨op⟩, ⟨op⟩, [], [.literal ⟨.amount a, q⟩], atomCaps, none⟩
def draw (q : ℚ) := invocation 100 .usd q
def repay (q : ℚ) := invocation 101 .usd q
def drawShare (q : ℚ) := invocation 102 .share q
def repayShare (q : ℚ) := invocation 103 .share q
def drawOther (q : ℚ) := invocation 104 .usd q
def repayOther (q : ℚ) := invocation 105 .usd q
def noop := invocation 106 .usd 0
def repeatedDraw := invocation 107 .usd (7 / 2)
def mintUSD := invocation 108 .usd 3
def mintShare := invocation 109 .share 3
def timedDraw (q time : ℚ) : I :=
  ⟨⟨110⟩, ⟨110⟩, [], [.literal ⟨.amount .usd, q⟩, .literal ⟨.scalar, time⟩], atomCaps, none⟩
def liveDraw := invocation 111 .usd 0

def drawReturnLeft : B := [draw 7, repay 7]
def underLeft : B := [draw 7, repay 6]
def overLeft : B := [draw 7, repay 8]
def creditLeft : B := [draw 7, repay 8, draw 1]
def noOpLeft : B := [draw 7, noop]
def nonlaneLeft : B := [draw 7, mintShare, repay 7]

def expectedTransfer (index : Nat) (inv : I) (sender recipient : C) (q cash : ℚ) : Evt :=
  transferEvent index inv sender recipient q [output index inv.component.value sender.2.2 cash]
def drawEvent (index : Nat := 0) (actor : P := .alice) : Evt :=
  expectedTransfer index (draw 7) usdVault (.main, actor, .usd) 7 3
def repayEvent (index : Nat) (q cash : ℚ) (actor : P := .alice) : Evt :=
  expectedTransfer index (repay q) (.main, actor, .usd) usdVault q cash
def drawReturnEvents : List Evt := [drawEvent, repayEvent 1 7 10]
def underEvents : List Evt := [drawEvent, repayEvent 1 6 9]
def overEvents : List Evt := [drawEvent, repayEvent 1 8 11]
def creditEvents : List Evt := overEvents ++
  [expectedTransfer 2 (draw 1) usdVault usdAlice 1 10]
def peerReturnEvents : List Evt := [drawEvent, repayEvent 0 7 10 .bob]
def assetReturnEvents : List Evt := [drawEvent,
  expectedTransfer 0 (repayShare 7) shareAlice shareVault 7 17]
def domainReturnEvents : List Evt := [drawEvent,
  expectedTransfer 0 (repayOther 7) otherAlice otherVault 7 17]
def lastLaneEvents : List Evt := [expectedTransfer 0 (drawShare 1) shareVault shareAlice 1 9]
def lastParticipantEvents : List Evt := [drawEvent 0 .bob]
def noOpEvent : Evt := event 1 noop [⟨.amount .usd, 0⟩]
  ⟨true, [], [], [], [], [], [], []⟩ [output 1 106 .usd 3]
def repeatedEvent : Evt := event 0 repeatedDraw [⟨.amount .usd, 7 / 2⟩]
  ⟨true, [(usdVault, -7 / 2), (usdVault, -7 / 2), (usdAlice, 7)],
    [], [], [], [], [], [usdVault, usdAlice]⟩ [output 0 107 .usd 3]
def mintEvent (index : Nat) (inv : I) (cell : C) (amount post : ℚ) : Evt :=
  event index inv [⟨.amount cell.2.2, amount⟩]
    ⟨true, [(cell, amount)], [((cell.1, cell.2.2), amount)], [], [], [], [], [cell]⟩
    [output index inv.component.value cell.2.2 post]
def laneMintEvent := mintEvent 0 mintUSD usdAlice 3 4
def nonlaneMintEvent := mintEvent 1 mintShare shareAlice 3 11
def nonlaneEvents : List Evt := [drawEvent, nonlaneMintEvent, repayEvent 2 7 10]


def usdLane : Lane P A D := ⟨.main, .usd, .vault⟩
def shareLane : Lane P A D := ⟨.main, .share, .vault⟩
def otherLane : Lane P A D := ⟨.other, .usd, .vault⟩
def basePolicy : Policy P A D := ⟨[usdLane], [.alice]⟩
def multiLanePolicy : Policy P A D := ⟨[usdLane, shareLane], [.alice]⟩
def domainPolicy : Policy P A D := ⟨[usdLane, otherLane], [.alice]⟩
def multiParticipantPolicy : Policy P A D := ⟨[usdLane], [.alice, .bob]⟩
def batchPolicy : Policy P A D := ⟨[], [.alice, .bob]⟩
def duplicateLanePolicy : Policy P A D := ⟨[usdLane, ⟨.main, .usd, .pool⟩], [.alice]⟩
def duplicateParticipantPolicy : Policy P A D := ⟨[usdLane], [.alice, .bob, .alice]⟩

def drawResiduals : List (Residual P A D) := [⟨usdLane, .alice, 7⟩]
def underResiduals : List (Residual P A D) := [⟨usdLane, .alice, 1⟩]
def overResiduals : List (Residual P A D) := [⟨usdLane, .alice, -1⟩]
def peerResiduals : List (Residual P A D) := [⟨usdLane, .alice, 7⟩, ⟨usdLane, .bob, -7⟩]
def assetResiduals : List (Residual P A D) :=
  [⟨usdLane, .alice, 7⟩, ⟨shareLane, .alice, -7⟩]
def domainResiduals : List (Residual P A D) :=
  [⟨usdLane, .alice, 7⟩, ⟨otherLane, .alice, -7⟩]
def lastLaneResiduals : List (Residual P A D) := [⟨shareLane, .alice, 1⟩]
def lastParticipantResiduals : List (Residual P A D) := [⟨usdLane, .bob, 7⟩]

/-- A direct finite expected table, independent of production update and residual enumeration. -/
def expectedOutstanding (entries : List (Residual P A D)) : Outstanding P A D :=
  fun lane principal ↦ match entries.find? (fun entry ↦
      decide (entry.lane = lane ∧ entry.principal = principal)) with
    | some entry => entry.amount
    | none => 0

-- BEGIN PROOFS

end DefiKernel.Atomic.Examples


===== INPUT lean/DefiKernel/Atomic/Execution.lean ORIGINAL_SHA256 c9cee888746a2795ae2ddae59d9ffb27ed73339ed5a7ca0737be922af6d96b55 RENDERED_SHA256 c9cee888746a2795ae2ddae59d9ffb27ed73339ed5a7ca0737be922af6d96b55 =====
import DefiKernel.Atomic.Policy
import DefiKernel.Interleaving.Execution

/-! A single atomic publication boundary around actual interleaving steps. Diagnostic
receipts describe speculation; only a committed result publishes them. -/
namespace DefiKernel.Atomic
open Typed Composition Parallel Interleaving

inductive AdmissionFailure (P A D : Type) where
  | configuration
  | structural (branch : BranchId) (failure : Parallel.LocalFailure)
  | policy (failure : PolicyFailure P A D)
  | schedule (mismatch : ScheduleMismatch)
  deriving DecidableEq

inductive AbortReason (P A D : Type) where
  | kernel (branch : BranchId) (index position : Nat)
      (invocation : Invocation P A D) (reason : Composition.Failure)
  | laneSupply (branch : BranchId) (index position : Nat)
      (invocation : Invocation P A D) (lane : Lane P A D) (amount : ℚ)
  | unsettled (residual : List (Residual P A D))
  deriving DecidableEq

structure Machine (P A D : Type) where
  entryWorld : World P A D
  speculative : Interleaving.Machine P A D
  outstanding : Outstanding P A D
  position : Nat := 0
  abort : Option (AbortReason P A D) := none

inductive Result (P A D : Type) where
  | refused (label : Nat) (schedule : Schedule) (reason : AdmissionFailure P A D)
      (entry : World P A D)
  | aborted (label : Nat) (schedule : Schedule) (reason : AbortReason P A D)
      (machine : Machine P A D)
  | committed (label : Nat) (schedule : Schedule) (machine : Machine P A D)

structure InnerObservation (P A D : Type) where
  branch : BranchId
  index : Nat
  invocation : Invocation P A D
  receipt : Receipt P A D
  outputs : List (OutputObservation A)
  deriving DecidableEq

/-- One event is published even when the admitted atomic request contains no calls. -/
structure EventObservation (P A D : Type) where
  label : Nat
  schedule : Schedule
  inner : List (InnerObservation P A D)
  deriving DecidableEq

variable {P A D : Type} [DecidableEq P] [DecidableEq A] [DecidableEq D]

def admit (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (policy : Policy P A D) (left right : Branch P A D) (schedule : Schedule) :
    Except (AdmissionFailure P A D) (Footprint P A D × Footprint P A D) := do
  if !validateCatalog cfg.registry cfg.catalog then throw .configuration
  let lf ← (analyzeBranch cfg (boundaries .left) left).mapError (.structural .left)
  let rf ← (analyzeBranch cfg (boundaries .right) right).mapError (.structural .right)
  let _ ← (checkPolicy policy boundaries left right).mapError .policy
  let _ ← (checkSchedule left.length right.length schedule).mapError .schedule
  return (lf, rf)

def start (initial : World P A D) : Machine P A D :=
  ⟨initial, Interleaving.start initial, zeroOutstanding, 0, none⟩

def observeAttempt (attempt : Attempt P A D) : Option (InnerObservation P A D) :=
  match attempt.outcome with
  | .error _ => none
  | .ok result => some ⟨attempt.branch, attempt.index, attempt.invocation,
      result.receipt, result.outputs⟩

def diagnosticEvent (label : Nat) (schedule : Schedule) (m : Machine P A D) :
    EventObservation P A D :=
  ⟨label, schedule, m.speculative.attempts.filterMap observeAttempt⟩

def Result.publicWorld : Result P A D → World P A D
  | .refused _ _ _ entry => entry
  | .aborted _ _ _ m => m.entryWorld
  | .committed _ _ m => m.speculative.world

/-- This production accessor is consumed by the public projection. -/
def committedHistory : Result P A D → List (EventObservation P A D)
  | .refused _ _ _ _ => []
  | .aborted _ _ _ _ => []
  | .committed label schedule m => [diagnosticEvent label schedule m]

variable [Fintype P] [Fintype A] [Fintype D]

/-- Supply is the actual committed receipt sum, never the tentative aborted sum. -/
def committedSupply : Result P A D → D → A → ℚ
  | .refused _ _ _ _ => fun _ _ => 0
  | .aborted _ _ _ _ => fun _ _ => 0
  | .committed _ _ m => m.speculative.supply

def advance (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (policy : Policy P A D) (left right : Branch P A D) (m : Machine P A D)
    (branch : BranchId) : Machine P A D :=
  match m.abort with
  | some _ => m
  | none =>
    let next := Interleaving.advance cfg boundaries left right m.speculative branch
    let running := { m with speculative := next, position := m.position + 1 }
    match next.attempts[m.speculative.attempts.length]? with
    | none => running
    | some attempt =>
      match attempt.outcome with
      | .error reason =>
        { running with abort := some (.kernel attempt.branch attempt.index m.position
            attempt.invocation reason) }
      | .ok result =>
        let owed := updateOutstanding policy m.outstanding
          (boundaries attempt.branch attempt.index).ctx.principal result.receipt
        let accepted := { running with outstanding := owed }
        match checkSupply policy result.receipt with
        | none => accepted
        | some (lane, amount) =>
          { accepted with abort := some (.laneSupply attempt.branch attempt.index m.position
              attempt.invocation lane amount) }

def continueRun (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (policy : Policy P A D) (left right : Branch P A D) (m : Machine P A D)
    (schedule : Schedule) : Machine P A D :=
  schedule.foldl (advance cfg boundaries policy left right) m

def runPrefix (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (policy : Policy P A D) (initial : World P A D) (left right : Branch P A D)
    (schedule : Schedule) : Machine P A D :=
  continueRun cfg boundaries policy left right (start initial) schedule

def finish (label : Nat) (schedule : Schedule) (policy : Policy P A D)
    (m : Machine P A D) : Result P A D :=
  match m.abort with
  | some reason => .aborted label schedule reason m
  | none =>
    match residuals policy m.outstanding with
    | [] => .committed label schedule m
    | remaining => .aborted label schedule (.unsettled remaining) m

def runAtomic (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (label : Nat) (policy : Policy P A D) (initial : World P A D)
    (left right : Branch P A D) (schedule : Schedule) : Result P A D :=
  match Atomic.admit cfg boundaries policy left right schedule with
  | .error reason => .refused label schedule reason initial
  | .ok _ => finish label schedule policy
      (runPrefix cfg boundaries policy initial left right schedule)

-- BEGIN PROOFS

theorem advance_aborted (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (policy : Policy P A D) (left right : Branch P A D) (m : Machine P A D)
    (branch : BranchId) (reason : AbortReason P A D) (h : m.abort = some reason) :
    advance cfg boundaries policy left right m branch = m := by
  simp [advance, h]

theorem continueRun_append (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (policy : Policy P A D) (left right : Branch P A D) (m : Machine P A D)
    (s t : Schedule) :
    continueRun cfg boundaries policy left right m (s ++ t) =
      continueRun cfg boundaries policy left right
        (continueRun cfg boundaries policy left right m s) t := List.foldl_append

theorem continueRun_aborted (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (policy : Policy P A D) (left right : Branch P A D) (m : Machine P A D)
    (s : Schedule) (reason : AbortReason P A D) (h : m.abort = some reason) :
    continueRun cfg boundaries policy left right m s = m := by
  induction s with
  | nil => rfl
  | cons b s ih => simpa only [continueRun, List.foldl_cons,
      advance_aborted cfg boundaries policy left right m b reason h] using ih

end DefiKernel.Atomic


===== INPUT lean/DefiKernel/Atomic/InvariantFixtures.lean ORIGINAL_SHA256 616b1bdb47670b8049f5495287be9c694f71d765c2408091a7e11977430e1b0a RENDERED_SHA256 616b1bdb47670b8049f5495287be9c694f71d765c2408091a7e11977430e1b0a =====
import DefiKernel.Atomic.Examples
import DefiKernel.Atomic.Preservation
import DefiKernel.Atomic.Settlement
import DefiKernel.Interleaving.InterferenceFixtures

/-! Nonempty transient instances of the initialized invariant rule, with independently
checked negative witnesses for scalar clearing and unrestricted predicate frames. -/
namespace DefiKernel.Atomic.InvariantFixtures
open Typed Composition Parallel Interleaving Typed.Examples Atomic.Examples

def drawFootprint : Footprint P A D :=
  ⟨[usdVault, usdAlice, usdVault, usdAlice, usdVault],
    [usdVault, usdAlice, usdVault, usdAlice]⟩
def repayFootprint : Footprint P A D :=
  ⟨[usdAlice, usdVault, usdAlice, usdVault, usdVault],
    [usdAlice, usdVault, usdAlice, usdVault]⟩
def collateralInvariant (_ : BranchId) (s : State P A D) : Prop := s.balance collateral = 9
def unchangedCollateral (_ : BranchId) (pre post : State P A D) : Prop :=
  post.balance collateral = pre.balance collateral
def drawPrefix := Atomic.runPrefix atomCfg atomBoundary basePolicy atomInitial drawReturnLeft []
  [.left]
def unpaidInterleaving := Interleaving.runPrefix atomCfg atomBoundary atomInitial [draw 7] []
  [.left]
def unpaidAtomic := runAtomic atomCfg atomBoundary 8 basePolicy atomInitial [draw 7] [] [.left]

-- BEGIN PROOFS

theorem draw_analyzed (b : BranchId) (index : Nat) :
    analyzeInvocation atomCfg (atomBoundary b index) (draw 7) = .ok drawFootprint := by
  change analyzeInvocation atomCfg (atomBoundary .left 0) (draw 7) = .ok drawFootprint
  decide +kernel

theorem repay_analyzed (b : BranchId) (index : Nat) :
    analyzeInvocation atomCfg (atomBoundary b index) (repay 7) = .ok repayFootprint := by
  change analyzeInvocation atomCfg (atomBoundary .left 0) (repay 7) = .ok repayFootprint
  decide +kernel

theorem draw_return_local_obligation : LocalObligation atomCfg atomBoundary
    drawReturnLeft [] collateralInvariant unchangedCollateral := by
  intro b index inv selected history pre result initialized step
  suffices same : result.world.state.balance collateral = pre.state.balance collateral from
    ⟨same.trans initialized, same⟩
  cases b with
  | right => simp [selectBranch] at selected
  | left =>
    cases index with
    | zero =>
      simp only [selectBranch, drawReturnLeft, List.getElem?_cons_zero,
        Option.some.injEq] at selected
      subst inv
      exact Interleaving.InterferenceFixtures.sound_target_frame drawFootprint
        (draw_analyzed .left 0) step collateral (by decide)
    | succ n =>
      cases n with
      | zero =>
        simp only [selectBranch, drawReturnLeft, List.getElem?_cons_succ,
          List.getElem?_cons_zero, Option.some.injEq] at selected
        subst inv
        exact Interleaving.InterferenceFixtures.sound_target_frame repayFootprint
          (repay_analyzed .left 1) step collateral (by decide)
      | succ n => simp [selectBranch, drawReturnLeft] at selected

theorem collateral_cross : CrossInclusion unchangedCollateral unchangedCollateral := by
  intro b peer _ pre post same
  exact same

theorem collateral_stable : Stable collateralInvariant unchangedCollateral := by
  intro b pre post initialized same
  exact same.trans initialized

theorem collateral_initialized : ∀ b, collateralInvariant b atomInitial.state := by
  intro b
  change atomInitial.state.balance collateral = 9
  decide +kernel

theorem draw_return_public_invariant (schedule : Schedule) :
    ∀ b, collateralInvariant b (runAtomic atomCfg atomBoundary 8 basePolicy atomInitial
      drawReturnLeft [] schedule).publicWorld.state :=
  runAtomic_two_invariants atomCfg atomBoundary 8 basePolicy atomInitial drawReturnLeft [] schedule
    collateralInvariant unchangedCollateral unchangedCollateral collateral_initialized
    draw_return_local_obligation collateral_cross collateral_stable

theorem draw_return_diagnostic_invariant (schedule : Schedule) :
    ∀ b, collateralInvariant b (Atomic.runPrefix atomCfg atomBoundary basePolicy atomInitial
      drawReturnLeft [] schedule).speculative.world.state :=
  (Atomic.runPrefix_reachable atomCfg atomBoundary basePolicy atomInitial
    drawReturnLeft [] schedule).interleaving.two_invariants
      collateralInvariant unchangedCollateral unchangedCollateral
      collateral_initialized draw_return_local_obligation collateral_cross collateral_stable

/-- The invariant holds during a real draw while the qualified obligation is nonzero. -/
theorem nonempty_transient_invariant : basePolicy.lanes ≠ [] ∧
    drawPrefix.outstanding usdLane .alice = 7 ∧
    drawPrefix.speculative.world.state.balance usdVault = 3 ∧
    ∀ b, collateralInvariant b drawPrefix.speculative.world.state := by
  refine ⟨by decide, by decide +kernel, by decide +kernel,
    draw_return_diagnostic_invariant [.left]⟩

/-- Cancelling signed amounts across authenticated borrowers does not clear either key. -/
theorem scalar_netting_counterexample :
    (peerResiduals.map Residual.amount).sum = 0 ∧
    residuals multiParticipantPolicy (expectedOutstanding peerResiduals) = peerResiduals ∧
    peerResiduals ≠ [] := by decide +kernel

theorem missing_frame_support_counterexample :
    AgreeOn (∅ : Set (Cell P A D)) atomInitial.state drawPrefix.speculative.world.state ∧
    atomInitial.state.balance usdAlice = 1 ∧
    drawPrefix.speculative.world.state.balance usdAlice ≠ 1 := by
  refine ⟨?_, by decide +kernel, by decide +kernel⟩
  intro c impossible
  cases impossible

theorem empty_support_is_false :
    ¬ Supports (∅ : Set (Cell P A D)) (fun s : State P A D => s.balance usdAlice = 1) := by
  intro support
  have witness := missing_frame_support_counterexample
  exact witness.2.2 ((support _ _ witness.1).mp witness.2.1)

/-- Actual underlying financial success leaves debt; omitting clearance changes publication. -/
theorem underlying_success_does_not_imply_commit :
    unpaidInterleaving.left.failure = none ∧ unpaidInterleaving.left.nextIndex = 1 ∧
    (observe unpaidAtomic).outcome = .aborted (.unsettled drawResiduals) := by decide +kernel

end DefiKernel.Atomic.InvariantFixtures


===== INPUT lean/DefiKernel/Atomic/Observation.lean ORIGINAL_SHA256 3e0ab8f53d0bcddc86543207cce4ae832293836e9a301204b090b23d6ccd0cc5 RENDERED_SHA256 3e0ab8f53d0bcddc86543207cce4ae832293836e9a301204b090b23d6ccd0cc5 =====
import DefiKernel.Atomic.Execution

/-! Public equality retains the atomic event label, schedule, exact refusal, full
world and every committed receipt/output/supply field. Diagnostics are separate. -/
namespace DefiKernel.Atomic
open Typed Composition Parallel Interleaving

inductive Outcome (P A D : Type) where
  | refused (reason : AdmissionFailure P A D)
  | aborted (reason : AbortReason P A D)
  | committed
  deriving DecidableEq

structure Observation (P A D : Type) where
  label : Nat
  schedule : Schedule
  outcome : Outcome P A D
  world : World P A D
  events : List (EventObservation P A D)
  supply : D → A → ℚ

variable {P A D : Type} [DecidableEq P] [DecidableEq A] [DecidableEq D]
variable [Fintype P] [Fintype A] [Fintype D]

def observe (result : Result P A D) : Observation P A D :=
  let (label, schedule, outcome) := match result with
    | .refused label schedule reason _ => (label, schedule, Outcome.refused reason)
    | .aborted label schedule reason _ => (label, schedule, Outcome.aborted reason)
    | .committed label schedule _ => (label, schedule, Outcome.committed)
  ⟨label, schedule, outcome, result.publicWorld,
    committedHistory result, committedSupply result⟩

def Observation.Equivalent (left right : Observation P A D) : Prop :=
  left.label = right.label ∧ left.schedule = right.schedule ∧
    left.outcome = right.outcome ∧ WorldEquivalent left.world right.world ∧
    left.events = right.events ∧ ∀ d a, left.supply d a = right.supply d a

def observationEq (left right : Observation P A D) : Bool :=
  decide (left.label = right.label) && decide (left.schedule = right.schedule) &&
    decide (left.outcome = right.outcome) && worldEq left.world right.world &&
    decide (left.events = right.events) && decide (∀ d a, left.supply d a = right.supply d a)

def observationsEqual (left right : Result P A D) : Bool :=
  observationEq (observe left) (observe right)

-- BEGIN PROOFS

theorem observationEq_iff (left right : Observation P A D) :
    observationEq left right = true ↔ left.Equivalent right := by
  simp [observationEq, Observation.Equivalent, worldEq, WorldEquivalent, and_assoc]

theorem observationsEqual_iff (left right : Result P A D) :
    observationsEqual left right = true ↔ (observe left).Equivalent (observe right) :=
  observationEq_iff _ _

omit [DecidableEq P] [Fintype P] [Fintype A] [Fintype D] in
theorem observe_aborted_world (label : Nat) (schedule : Schedule)
    (reason : AbortReason P A D) (m : Machine P A D) :
    (observe (.aborted label schedule reason m)).world = m.entryWorld := rfl

omit [DecidableEq P] [Fintype P] [Fintype A] [Fintype D] in
theorem observe_aborted_history (label : Nat) (schedule : Schedule)
    (reason : AbortReason P A D) (m : Machine P A D) :
    (observe (.aborted label schedule reason m)).events = [] := rfl

omit [DecidableEq P] [Fintype P] [Fintype A] [Fintype D] in
theorem observe_aborted_supply (label : Nat) (schedule : Schedule)
    (reason : AbortReason P A D) (m : Machine P A D) (d : D) (a : A) :
    (observe (.aborted label schedule reason m)).supply d a = 0 := rfl

omit [DecidableEq P] [Fintype P] [Fintype A] [Fintype D] in
theorem observe_refused_world (label : Nat) (schedule : Schedule)
    (reason : AdmissionFailure P A D) (entry : World P A D) :
    (observe (.refused label schedule reason entry)).world = entry := rfl

omit [DecidableEq P] [Fintype P] [Fintype A] [Fintype D] in
theorem observe_refused_history (label : Nat) (schedule : Schedule)
    (reason : AdmissionFailure P A D) (entry : World P A D) :
    (observe (.refused label schedule reason entry)).events = [] := rfl

omit [DecidableEq P] [Fintype P] [Fintype A] [Fintype D] in
theorem observe_refused_supply (label : Nat) (schedule : Schedule)
    (reason : AdmissionFailure P A D) (entry : World P A D) (d : D) (a : A) :
    (observe (.refused label schedule reason entry)).supply d a = 0 := rfl

omit [DecidableEq P] [Fintype P] [Fintype A] [Fintype D] in
theorem observe_commit_one_event (label : Nat) (schedule : Schedule) (m : Machine P A D) :
    (observe (.committed label schedule m)).events = [diagnosticEvent label schedule m] := rfl

omit [DecidableEq P] [Fintype P] [Fintype A] [Fintype D] in
theorem observe_commit_world (label : Nat) (schedule : Schedule) (m : Machine P A D) :
    (observe (.committed label schedule m)).world = m.speculative.world := rfl

end DefiKernel.Atomic


===== INPUT lean/DefiKernel/Atomic/Policy.lean ORIGINAL_SHA256 5b643cbb1b1263ffacb20892afe3f9ec1067191e733f08c3f4040bbe17fa2612 RENDERED_SHA256 5b643cbb1b1263ffacb20892afe3f9ec1067191e733f08c3f4040bbe17fa2612 =====
import DefiKernel.Interleaving.Execution

/-! Typed clearing policy and receipt-derived signed obligations. Lane uniqueness uses the
entire domain/asset key, so changing the vault does not remove an ambiguity. -/
namespace DefiKernel.Atomic
open Typed Composition Parallel Interleaving

structure Lane (P A D : Type) where
  domain : D
  asset : A
  vault : P
  deriving DecidableEq, Repr

def Lane.cell {P A D : Type} (lane : Lane P A D) : Cell P A D :=
  (lane.domain, lane.vault, lane.asset)

structure Policy (P A D : Type) where
  lanes : List (Lane P A D)
  participants : List P

abbrev Outstanding (P A D : Type) := Lane P A D → P → ℚ

structure Residual (P A D : Type) where
  lane : Lane P A D
  principal : P
  amount : ℚ
  deriving DecidableEq, Repr

inductive PolicyFailure (P A D : Type) where
  | duplicateLane (firstIndex secondIndex : Nat) (first second : Lane P A D)
  | duplicateParticipant (firstIndex secondIndex : Nat) (principal : P)
  | uncoveredParticipant (branch : BranchId) (index : Nat) (principal : P)
  deriving DecidableEq, Repr

/-- Search in first-index then second-index order, retaining both original values. -/
def firstDuplicate {X K : Type} [DecidableEq K] (key : X → K) (index : Nat) :
    List X → Option (Nat × Nat × X × X)
  | [] => none
  | x :: xs =>
    match (xs.zipIdx (index + 1)).find? (fun item ↦ key x == key item.1) with
    | some (y, j) => some (index, j, x, y)
    | none => firstDuplicate key (index + 1) xs

variable {P A D : Type} [DecidableEq P] [DecidableEq A] [DecidableEq D]

/-- Coverage visits every static invocation, including suffixes that might never execute. -/
def uncoveredFrom (participants : List P) (branch : BranchId)
    (boundary : Nat → Boundary P A D) (index : Nat) :
    Branch P A D → Option (PolicyFailure P A D)
  | [] => none
  | _ :: xs =>
    if (boundary index).ctx.principal ∈ participants then
      uncoveredFrom participants branch boundary (index + 1) xs
    else some (.uncoveredParticipant branch index (boundary index).ctx.principal)

def checkPolicy (policy : Policy P A D) (boundaries : ParallelBoundary P A D)
    (left right : Branch P A D) : Except (PolicyFailure P A D) (PUnit : Type) := do
  match firstDuplicate (fun lane ↦ (lane.domain, lane.asset)) 0 policy.lanes with
  | some (i, j, first, second) => throw (.duplicateLane i j first second)
  | none => pure ()
  match firstDuplicate id 0 policy.participants with
  | some (i, j, principal, _) => throw (.duplicateParticipant i j principal)
  | none => pure ()
  match uncoveredFrom policy.participants .left (boundaries .left) 0 left with
  | some failure => throw failure
  | none => pure ()
  match uncoveredFrom policy.participants .right (boundaries .right) 0 right with
  | some failure => throw failure
  | none => pure ()
  return ⟨⟩

def receiptEffect (receipt : Receipt P A D) (cell : Cell P A D) : ℚ :=
  match receipt with
  | .invoked _ e => e.effect cell
  | _ => 0

def zeroOutstanding : Outstanding P A D := fun _ _ ↦ 0

def updateOutstanding (policy : Policy P A D) (owed : Outstanding P A D)
    (principal : P) (receipt : Receipt P A D) : Outstanding P A D :=
  fun lane p ↦ if lane ∈ policy.lanes ∧ p = principal then
    owed lane p - receiptEffect receipt lane.cell else owed lane p

/-- Canonical lane-major, participant-minor enumeration of every nonzero table entry. -/
def residuals (policy : Policy P A D) (owed : Outstanding P A D) : List (Residual P A D) :=
  policy.lanes.flatMap fun lane ↦ policy.participants.filterMap fun principal ↦
    if owed lane principal = 0 then none else some ⟨lane, principal, owed lane principal⟩

def checkSupply (policy : Policy P A D) (receipt : Receipt P A D) : Option (Lane P A D × ℚ) :=
  (policy.lanes.find? (fun lane ↦ receipt.supply lane.domain lane.asset != 0)).map
    (fun lane ↦ (lane, receipt.supply lane.domain lane.asset))

-- BEGIN PROOFS

end DefiKernel.Atomic


===== INPUT lean/DefiKernel/Atomic/PolicyProofs.lean ORIGINAL_SHA256 9eb5f5fe51692a44860fc27abb2ac2e7196ceb63ba61bb9a416af2cede544ab6 RENDERED_SHA256 9eb5f5fe51692a44860fc27abb2ac2e7196ceb63ba61bb9a416af2cede544ab6 =====
import DefiKernel.Atomic.Policy
import Mathlib.Data.List.Nodup

/-! Policy admission is equivalent to complete typed uniqueness and static coverage.
Residual observations enumerate exactly the configured nonzero keys. -/
namespace DefiKernel.Atomic
open Typed Composition Parallel Interleaving

-- BEGIN PROOFS

private theorem find_key_none {X K : Type} [DecidableEq K] (key : X → K)
    (x : X) (xs : List X) (index : Nat) :
    (xs.zipIdx index).find? (fun item ↦ key x == key item.1) = none ↔
      key x ∉ xs.map key := by
  rw [List.find?_eq_none]
  constructor
  · intro h hm
    rcases List.mem_map.mp hm with ⟨y, hy, heq⟩
    have hm' : y ∈ (xs.zipIdx index).map Prod.fst := by
      simpa only [List.zipIdx_map_fst] using hy
    rcases List.mem_map.mp hm' with ⟨pair, hp, hpy⟩
    have := h pair hp
    simp [hpy, heq] at this
  · intro h pair hp heq
    apply h
    exact List.mem_map.mpr ⟨pair.1, List.fst_mem_of_mem_zipIdx hp,
      (beq_iff_eq.mp heq).symm⟩

theorem firstDuplicate_none_iff {X K : Type} [DecidableEq K] (key : X → K)
    (index : Nat) (xs : List X) :
    firstDuplicate key index xs = none ↔ (xs.map key).Nodup := by
  induction xs generalizing index with
  | nil => simp [firstDuplicate]
  | cons x xs ih =>
    rw [firstDuplicate]
    cases h : (xs.zipIdx (index + 1)).find? (fun item ↦ key x == key item.1) with
    | none =>
      have hn := (find_key_none key x xs (index + 1)).mp h
      simp [ih, hn]
    | some pair =>
      have hn : ¬ key x ∉ xs.map key := by
        intro hx
        have := (find_key_none key x xs (index + 1)).mpr hx
        rw [h] at this
        contradiction
      simp only [Option.some_ne_none, List.map_cons, List.nodup_cons, false_iff]
      exact fun hnodup ↦ hn hnodup.1

variable {P A D : Type} [DecidableEq P] [DecidableEq A] [DecidableEq D]

omit [DecidableEq A] [DecidableEq D] in
theorem uncoveredFrom_none_iff (participants : List P) (b : BranchId)
    (boundary : Nat → Boundary P A D) (index : Nat) (xs : Branch P A D) :
    uncoveredFrom participants b boundary index xs = none ↔
      ∀ j, j < xs.length → (boundary (index + j)).ctx.principal ∈ participants := by
  induction xs generalizing index with
  | nil => simp [uncoveredFrom]
  | cons x xs ih =>
    simp only [uncoveredFrom]
    by_cases h : (boundary index).ctx.principal ∈ participants
    · simp only [h, ↓reduceIte, ih]
      constructor
      · intro hall j hj
        cases j with
        | zero => simpa using h
        | succ j =>
          have := hall j (by simpa using hj)
          simpa [Nat.add_assoc, Nat.add_comm, Nat.add_left_comm] using this
      · intro hall j hj
        have := hall (j + 1) (by simpa using Nat.succ_lt_succ hj)
        simpa [Nat.add_assoc, Nat.add_comm, Nat.add_left_comm] using this
    · simp only [h, ↓reduceIte, Option.some_ne_none, false_iff]
      intro hall
      exact h (by simpa using hall 0 (by simp))

/-- All four policy phases characterize acceptance, including unreachable static suffixes. -/
theorem checkPolicy_ok_iff (policy : Policy P A D) (boundaries : ParallelBoundary P A D)
    (left right : Branch P A D) :
    checkPolicy policy boundaries left right = .ok ⟨⟩ ↔
      (policy.lanes.map (fun lane ↦ (lane.domain, lane.asset))).Nodup ∧
      policy.participants.Nodup ∧
      (∀ i, i < left.length → (boundaries .left i).ctx.principal ∈ policy.participants) ∧
      (∀ i, i < right.length → (boundaries .right i).ctx.principal ∈ policy.participants) := by
  have hl := firstDuplicate_none_iff (fun lane : Lane P A D ↦
    (lane.domain, lane.asset)) 0 policy.lanes
  have hp := firstDuplicate_none_iff id 0 policy.participants
  have hleft := uncoveredFrom_none_iff policy.participants .left (boundaries .left) 0 left
  have hright := uncoveredFrom_none_iff policy.participants .right (boundaries .right) 0 right
  simp only [List.map_id, Nat.zero_add] at hp hleft hright
  rw [← hl, ← hp, ← hleft, ← hright]
  unfold checkPolicy
  cases firstDuplicate (fun lane ↦ (lane.domain, lane.asset)) 0 policy.lanes <;>
    cases firstDuplicate id 0 policy.participants <;>
    cases uncoveredFrom policy.participants .left (boundaries .left) 0 left <;>
    cases uncoveredFrom policy.participants .right (boundaries .right) 0 right <;>
    simp [pure, Except.pure, bind, Except.bind, throw]

theorem checkPolicy_participants_nodup (policy : Policy P A D)
    (boundaries : ParallelBoundary P A D) (left right : Branch P A D)
    (h : checkPolicy policy boundaries left right = .ok ⟨⟩) :
    policy.participants.Nodup := (checkPolicy_ok_iff policy boundaries left right).mp h |>.2.1

theorem checkPolicy_covers (policy : Policy P A D) (boundaries : ParallelBoundary P A D)
    (left right : Branch P A D) (h : checkPolicy policy boundaries left right = .ok ⟨⟩)
    (b : BranchId) (i : Nat) (hi : i < (Interleaving.selectBranch left right b).length) :
    (boundaries b i).ctx.principal ∈ policy.participants := by
  have hc := (checkPolicy_ok_iff policy boundaries left right).mp h
  cases b with
  | left => exact hc.2.2.1 i hi
  | right => exact hc.2.2.2 i hi

@[simp] theorem receiptEffect_invoked (request : Request P A D) (e : Evaluated P A D)
    (cell : Cell P A D) : receiptEffect (.invoked request e) cell = e.effect cell := rfl

@[simp] theorem receiptEffect_issued (id : CapabilityId) (cell : Cell P A D) :
    receiptEffect (.issued id) cell = 0 := rfl

@[simp] theorem receiptEffect_revoked (id : CapabilityId) (cell : Cell P A D) :
    receiptEffect (.revoked id) cell = 0 := rfl

theorem updateOutstanding_own (policy : Policy P A D) (owed : Outstanding P A D)
    (principal : P) (receipt : Receipt P A D) (lane : Lane P A D)
    (hlane : lane ∈ policy.lanes) :
    updateOutstanding policy owed principal receipt lane principal =
      owed lane principal - receiptEffect receipt lane.cell := by
  simp [updateOutstanding, hlane]

theorem updateOutstanding_other (policy : Policy P A D) (owed : Outstanding P A D)
    (principal p : P) (receipt : Receipt P A D) (lane : Lane P A D) (hp : p ≠ principal) :
    updateOutstanding policy owed principal receipt lane p = owed lane p := by
  simp [updateOutstanding, hp]

theorem updateOutstanding_unconfigured (policy : Policy P A D) (owed : Outstanding P A D)
    (principal p : P) (receipt : Receipt P A D) (lane : Lane P A D)
    (hlane : lane ∉ policy.lanes) :
    updateOutstanding policy owed principal receipt lane p = owed lane p := by
  simp [updateOutstanding, hlane]

theorem updateOutstanding_zero_effect (policy : Policy P A D) (owed : Outstanding P A D)
    (principal p : P) (receipt : Receipt P A D) (lane : Lane P A D)
    (hzero : receiptEffect receipt lane.cell = 0) :
    updateOutstanding policy owed principal receipt lane p = owed lane p := by
  simp [updateOutstanding, hzero]

omit [DecidableEq P] [DecidableEq A] [DecidableEq D] in
/-- Exact residual membership includes all three key qualifications and the signed value. -/
theorem mem_residuals_iff (policy : Policy P A D) (owed : Outstanding P A D)
    (r : Residual P A D) :
    r ∈ residuals policy owed ↔ r.lane ∈ policy.lanes ∧
      r.principal ∈ policy.participants ∧ r.amount = owed r.lane r.principal ∧ r.amount ≠ 0 := by
  rcases r with ⟨lane, principal, amount⟩
  simp only [residuals, List.mem_flatMap, List.mem_filterMap]
  constructor
  · rintro ⟨l, hl, p, hp, heq⟩
    split at heq
    · contradiction
    · cases Option.some.inj heq
      exact ⟨hl, hp, rfl, by assumption⟩
  · rintro ⟨hl, hp, heq, hne⟩
    refine ⟨lane, hl, principal, hp, ?_⟩
    simp [← heq, hne]

omit [DecidableEq P] [DecidableEq A] [DecidableEq D] in
/-- Clearance is pointwise over the entire configured rectangle, not a global net sum. -/
theorem residuals_eq_nil_iff (policy : Policy P A D) (owed : Outstanding P A D) :
    residuals policy owed = [] ↔
      ∀ lane ∈ policy.lanes, ∀ p ∈ policy.participants, owed lane p = 0 := by
  constructor
  · intro h lane hl p hp
    by_contra hn
    have hm := (mem_residuals_iff policy owed ⟨lane, p, owed lane p⟩).mpr
      ⟨hl, hp, rfl, hn⟩
    simp [h] at hm
  · intro h
    apply List.eq_nil_iff_forall_not_mem.mpr
    intro r hr
    have hm := (mem_residuals_iff policy owed r).mp hr
    exact hm.2.2.2 (hm.2.2.1.trans (h r.lane hm.1 r.principal hm.2.1))

omit [DecidableEq P] [DecidableEq A] [DecidableEq D] in
@[simp] theorem residuals_zero (policy : Policy P A D) :
    residuals policy zeroOutstanding = [] := by
  apply (residuals_eq_nil_iff policy zeroOutstanding).mpr
  intros
  rfl

omit [DecidableEq P] in
theorem checkSupply_none_iff (policy : Policy P A D) (receipt : Receipt P A D) :
    checkSupply policy receipt = none ↔
      ∀ lane ∈ policy.lanes, receipt.supply lane.domain lane.asset = 0 := by
  simp [checkSupply]

theorem checkPolicy_lanes_nodup (policy : Policy P A D)
    (boundaries : ParallelBoundary P A D) (left right : Branch P A D)
    (h : checkPolicy policy boundaries left right = .ok ⟨⟩) : policy.lanes.Nodup :=
  List.Nodup.of_map _ ((checkPolicy_ok_iff policy boundaries left right).mp h).1

omit [DecidableEq P] [DecidableEq A] [DecidableEq D] in
theorem residuals_eq_filterMap_product (policy : Policy P A D) (owed : Outstanding P A D) :
    residuals policy owed = (policy.lanes.product policy.participants).filterMap
      (fun key ↦ if owed key.1 key.2 = 0 then none
        else some ⟨key.1, key.2, owed key.1 key.2⟩) := by
  simp [residuals, List.product, List.filterMap_flatMap, List.filterMap_map]

omit [DecidableEq P] [DecidableEq A] [DecidableEq D] in
theorem residuals_keys (policy : Policy P A D) (owed : Outstanding P A D) :
    (residuals policy owed).map (fun r ↦ (r.lane, r.principal)) =
      (policy.lanes.product policy.participants).filter (fun key ↦ owed key.1 key.2 != 0) := by
  rw [residuals_eq_filterMap_product, List.map_filterMap]
  simp only [← List.filterMap_eq_filter]
  congr 1
  funext key
  by_cases h : owed key.1 key.2 = 0 <;> simp [h, Option.guard]

omit [DecidableEq P] [DecidableEq A] [DecidableEq D] in
/-- Every nonzero lane/principal key appears exactly once under admitted uniqueness. -/
theorem residuals_keys_nodup (policy : Policy P A D) (owed : Outstanding P A D)
    (hl : policy.lanes.Nodup) (hp : policy.participants.Nodup) :
    ((residuals policy owed).map (fun r ↦ (r.lane, r.principal))).Nodup := by
  rw [residuals_keys]
  exact (hl.product hp).filter _

omit [DecidableEq P] [DecidableEq A] [DecidableEq D] in
theorem residuals_nodup (policy : Policy P A D) (owed : Outstanding P A D)
    (hl : policy.lanes.Nodup) (hp : policy.participants.Nodup) :
    (residuals policy owed).Nodup :=
  List.Nodup.of_map _ (residuals_keys_nodup policy owed hl hp)

private theorem sum_sub_at (participants : List P) (principal : P) (f : P → ℚ) (delta : ℚ)
    (hn : participants.Nodup) (hm : principal ∈ participants) :
    (participants.map (fun p ↦ if p = principal then f p - delta else f p)).sum =
      (participants.map f).sum - delta := by
  induction participants with
  | nil => simp at hm
  | cons p ps ih =>
    rcases List.nodup_cons.mp hn with ⟨hnot, htail⟩
    by_cases heq : p = principal
    · subst p
      have hmap : ps.map (fun p ↦ if p = principal then f p - delta else f p) = ps.map f := by
        apply List.map_congr_left
        intro q hq
        have hne : q ≠ principal := by intro h; subst q; exact hnot hq
        simp [hne]
      simp [hmap, sub_add_eq_add_sub]
    · have hmem : principal ∈ ps := (List.mem_cons.mp hm).resolve_left (Ne.symm heq)
      simp only [List.map_cons, List.sum_cons, heq, ↓reduceIte, ih htail hmem]
      exact (add_sub_assoc _ _ _).symm

/-- Complete duplicate-free participant sums decrease by precisely the lane receipt effect. -/
theorem updateOutstanding_sum (policy : Policy P A D) (owed : Outstanding P A D)
    (principal : P) (receipt : Receipt P A D) (lane : Lane P A D)
    (hlane : lane ∈ policy.lanes) (hn : policy.participants.Nodup)
    (hm : principal ∈ policy.participants) :
    (policy.participants.map (updateOutstanding policy owed principal receipt lane)).sum =
      (policy.participants.map (owed lane)).sum - receiptEffect receipt lane.cell := by
  unfold updateOutstanding
  simpa only [hlane, true_and] using
    sum_sub_at policy.participants principal (owed lane) (receiptEffect receipt lane.cell) hn hm

end DefiKernel.Atomic


===== INPUT lean/DefiKernel/Atomic/Preservation.lean ORIGINAL_SHA256 1ac0a654964cb11c7c810651831e16d253bb0e875c1f693b4bdb2f735d2b9a6c RENDERED_SHA256 1ac0a654964cb11c7c810651831e16d253bb0e875c1f693b4bdb2f735d2b9a6c =====
import DefiKernel.Atomic.Completion
import DefiKernel.Atomic.Observation
import DefiKernel.Interleaving.Preservation
import DefiKernel.Interleaving.Interference

/-! Public macro laws follow from actual speculative reachability and complete rollback.
Authority statements retain the authenticated boundary and initial-store trust premises. -/
namespace DefiKernel.Atomic
open Typed Composition Parallel Interleaving

variable {P A D : Type} [DecidableEq P] [DecidableEq A] [DecidableEq D]
variable [Fintype P] [Fintype A] [Fintype D]

-- BEGIN PROOFS

theorem runAtomic_noncommit_identity (cfg : Config P A D)
    (boundaries : ParallelBoundary P A D) (label : Nat) (policy : Policy P A D)
    (initial : World P A D) (left right : Branch P A D) (schedule : Schedule)
    (noncommit : ∀ m, runAtomic cfg boundaries label policy initial left right schedule ≠
      .committed label schedule m) :
    (runAtomic cfg boundaries label policy initial left right schedule).publicWorld = initial ∧
      committedHistory
        (runAtomic cfg boundaries label policy initial left right schedule) = [] ∧
      ∀ d a, committedSupply (runAtomic cfg boundaries label policy initial left right schedule)
        d a = 0 := by
  have entry := (runPrefix_reachable cfg boundaries policy initial left right schedule).entry
  cases ha : admit cfg boundaries policy left right schedule with
  | error reason => simp [runAtomic, ha, Result.publicWorld, committedHistory, committedSupply]
  | ok pair =>
    cases hb : (runPrefix cfg boundaries policy initial left right schedule).abort with
    | some reason =>
      simp [runAtomic, ha, finish, hb, Result.publicWorld, committedHistory, committedSupply, entry]
    | none =>
      cases hr : residuals policy
          (runPrefix cfg boundaries policy initial left right schedule).outstanding with
      | nil => exact False.elim (noncommit
          (runPrefix cfg boundaries policy initial left right schedule)
          (by simp [runAtomic, ha, finish, hb, hr]))
      | cons r rest =>
        simp [runAtomic, ha, finish, hb, hr, Result.publicWorld,
          committedHistory, committedSupply, entry]

theorem runAtomic_commit_reachable (cfg : Config P A D)
    (boundaries : ParallelBoundary P A D) (label : Nat) (policy : Policy P A D)
    (initial : World P A D) (left right : Branch P A D) (schedule : Schedule)
    (m : Machine P A D)
    (h : runAtomic cfg boundaries label policy initial left right schedule =
      .committed label schedule m) : Reachable cfg boundaries policy left right initial m := by
  obtain ⟨_, _, _, rfl, _, _⟩ := runAtomic_commit_data _ _ _ _ _ _ _ _ _ h
  exact runPrefix_reachable _ _ _ _ _ _ _

/-- Actual receipt accounting includes authorized nonlane supply and zero aborted supply. -/
theorem runAtomic_accounting (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (label : Nat) (policy : Policy P A D) (initial : World P A D)
    (left right : Branch P A D) (schedule : Schedule) (d : D) (a : A) :
    total
      (runAtomic cfg boundaries label policy initial left right schedule).publicWorld.state d a =
    total initial.state d a + committedSupply
      (runAtomic cfg boundaries label policy initial left right schedule) d a := by
  by_cases hc : ∃ m, runAtomic cfg boundaries label policy initial left right schedule =
      .committed label schedule m
  · obtain ⟨m, hm⟩ := hc
    have sound := runAtomic_commit_reachable _ _ _ _ _ _ _ _ _ hm
    rw [hm]
    exact sound.interleaving.accounting d a
  · have hi := runAtomic_noncommit_identity cfg boundaries label policy initial left right
      schedule (by simpa using hc)
    rw [hi.1, hi.2.2 d a, add_zero]

theorem runAtomic_store (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (label : Nat) (policy : Policy P A D) (initial : World P A D)
    (left right : Branch P A D) (schedule : Schedule) :
    (runAtomic cfg boundaries label policy initial left right schedule).publicWorld.capabilities =
      initial.capabilities := by
  by_cases hc : ∃ m, runAtomic cfg boundaries label policy initial left right schedule =
      .committed label schedule m
  · obtain ⟨m, hm⟩ := hc
    have sound := runAtomic_commit_reachable _ _ _ _ _ _ _ _ _ hm
    rw [hm]
    exact sound.interleaving.store
  · exact congrArg (fun w : World P A D => w.capabilities)
      (runAtomic_noncommit_identity _ _ _ _ _ _ _ _ (by simpa using hc)).1

theorem runAtomic_nonnegative (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (label : Nat) (policy : Policy P A D) (initial : World P A D)
    (left right : Branch P A D) (schedule : Schedule) (c : Cell P A D) :
    0 ≤
      (runAtomic cfg boundaries label policy initial left right schedule).publicWorld.state.balance
        c :=
  (runAtomic cfg boundaries label policy initial left right schedule).publicWorld.state.nonneg c

theorem runAtomic_commit_authority (cfg : Config P A D)
    (boundaries : ParallelBoundary P A D) (label : Nat) (policy : Policy P A D)
    (initial : World P A D) (left right : Branch P A D) (schedule : Schedule)
    (m : Machine P A D)
    (committed : runAtomic cfg boundaries label policy initial left right schedule =
      .committed label schedule m)
    (attempt : Attempt P A D) (member : attempt ∈ m.speculative.attempts)
    (result : StepResult P A D) (success : attempt.outcome = .ok result) :
    ReceiptAuthorized attempt.before (boundaries attempt.branch attempt.index) result.receipt :=
  (runAtomic_commit_reachable _ _ _ _ _ _ _ _ _ committed).interleaving.authority
    attempt member result success

theorem runAtomic_commit_before_store (cfg : Config P A D)
    (boundaries : ParallelBoundary P A D) (label : Nat) (policy : Policy P A D)
    (initial : World P A D) (left right : Branch P A D) (schedule : Schedule)
    (m : Machine P A D)
    (committed : runAtomic cfg boundaries label policy initial left right schedule =
      .committed label schedule m)
    (attempt : Attempt P A D) (member : attempt ∈ m.speculative.attempts) :
    attempt.before.capabilities = initial.capabilities :=
  (runAtomic_commit_reachable _ _ _ _ _ _ _ _ _ committed).interleaving.before_stores
    attempt member

theorem runAtomic_commit_locality (cfg : Config P A D)
    (boundaries : ParallelBoundary P A D) (label : Nat) (policy : Policy P A D)
    (initial : World P A D) (left right : Branch P A D) (schedule : Schedule)
    (m : Machine P A D)
    (committed : runAtomic cfg boundaries label policy initial left right schedule =
      .committed label schedule m)
    (c : Cell P A D) (untouched : c ∉ m.speculative.writes) :
    m.speculative.world.state.balance c = initial.state.balance c :=
  (runAtomic_commit_reachable _ _ _ _ _ _ _ _ _ committed).interleaving.locality c untouched

theorem runAtomic_commit_predicate_frame (cfg : Config P A D)
    (boundaries : ParallelBoundary P A D) (label : Nat) (policy : Policy P A D)
    (initial : World P A D) (left right : Branch P A D) (schedule : Schedule)
    (m : Machine P A D)
    (committed : runAtomic cfg boundaries label policy initial left right schedule =
      .committed label schedule m)
    (region : Set (Cell P A D)) (predicate : State P A D → Prop)
    (support : Supports region predicate) (untouched : ∀ c ∈ region, c ∉ m.speculative.writes) :
    predicate initial.state ↔ predicate m.speculative.world.state :=
  (runAtomic_commit_reachable _ _ _ _ _ _ _ _ _ committed).interleaving.predicate_frame
    region predicate support untouched

theorem runAtomic_analyzed_locality (cfg : Config P A D)
    (boundaries : ParallelBoundary P A D) (label : Nat) (policy : Policy P A D)
    (initial : World P A D) (left right : Branch P A D) (schedule : Schedule)
    (lf rf : Footprint P A D)
    (hl : analyzeBranch cfg (boundaries .left) left = .ok lf)
    (hr : analyzeBranch cfg (boundaries .right) right = .ok rf)
    (c : Cell P A D) (untouched : c ∉ lf.writes ++ rf.writes) :
    (runAtomic cfg boundaries label policy initial left right schedule).publicWorld.state.balance
      c =
      initial.state.balance c := by
  by_cases hc : ∃ m, runAtomic cfg boundaries label policy initial left right schedule =
      .committed label schedule m
  · obtain ⟨m, hm⟩ := hc
    have sound := runAtomic_commit_reachable _ _ _ _ _ _ _ _ _ hm
    rw [hm]
    exact sound.interleaving.analyzed_locality lf rf hl hr c untouched
  · rw [(runAtomic_noncommit_identity _ _ _ _ _ _ _ _ (by simpa using hc)).1]

theorem runAtomic_analyzed_predicate_frame (cfg : Config P A D)
    (boundaries : ParallelBoundary P A D) (label : Nat) (policy : Policy P A D)
    (initial : World P A D) (left right : Branch P A D) (schedule : Schedule)
    (lf rf : Footprint P A D)
    (hl : analyzeBranch cfg (boundaries .left) left = .ok lf)
    (hr : analyzeBranch cfg (boundaries .right) right = .ok rf)
    (region : Set (Cell P A D)) (predicate : State P A D → Prop)
    (support : Supports region predicate) (untouched : ∀ c ∈ region, c ∉ lf.writes ++ rf.writes) :
    predicate initial.state ↔ predicate
      (runAtomic cfg boundaries label policy initial left right schedule).publicWorld.state := by
  apply supported_frame support
  intro c hc
  exact (runAtomic_analyzed_locality _ _ _ _ _ _ _ _ _ _ hl hr c (untouched c hc)).symm

/-- Initialization and actual per-call obligations establish a ledger invariant through
nonzero transient obligations as well as public rollback. No whole-result premise is used. -/
theorem runAtomic_two_invariants (cfg : Config P A D)
    (boundaries : ParallelBoundary P A D) (label : Nat) (policy : Policy P A D)
    (initial : World P A D) (left right : Branch P A D) (schedule : Schedule)
    (invariant : BranchId → LedgerPredicate P A D)
    (guarantee rely : BranchId → LedgerRelation P A D)
    (initialized : ∀ b, invariant b initial.state)
    (localObligation : LocalObligation cfg boundaries left right invariant guarantee)
    (cross : CrossInclusion guarantee rely) (stable : Stable invariant rely) :
    ∀ b, invariant b
      (runAtomic cfg boundaries label policy initial left right schedule).publicWorld.state := by
  by_cases hc : ∃ m, runAtomic cfg boundaries label policy initial left right schedule =
      .committed label schedule m
  · obtain ⟨m, hm⟩ := hc
    have sound := runAtomic_commit_reachable _ _ _ _ _ _ _ _ _ hm
    rw [hm]
    exact sound.interleaving.two_invariants invariant guarantee rely initialized
      localObligation cross stable
  · rw [(runAtomic_noncommit_identity _ _ _ _ _ _ _ _ (by simpa using hc)).1]
    exact initialized

end DefiKernel.Atomic


===== INPUT lean/DefiKernel/Atomic/Settlement.lean ORIGINAL_SHA256 c27cf9eebfce49357e14c963ab2c0ec4a920b3e26d700f85ad8d51cbb6315ca5 RENDERED_SHA256 c27cf9eebfce49357e14c963ab2c0ec4a920b3e26d700f85ad8d51cbb6315ca5 =====
import DefiKernel.Atomic.PolicyProofs
import DefiKernel.Atomic.Soundness
import DefiKernel.Interleaving.LocalOrder

/-! Receipt-derived obligations are an independent fold of actual attempts. Every reachable
prefix conserves each lane's cash plus the complete signed participant sum, including the
successful step that triggers a lane-supply abort. -/
namespace DefiKernel.Atomic
open Typed Composition Parallel Interleaving

variable {P A D : Type} [DecidableEq P] [DecidableEq A] [DecidableEq D]

def attemptOutstanding (policy : Policy P A D) (boundaries : ParallelBoundary P A D)
    (owed : Outstanding P A D) (attempt : Attempt P A D) : Outstanding P A D :=
  match attempt.outcome with
  | .error _ => owed
  | .ok result => updateOutstanding policy owed
      (boundaries attempt.branch attempt.index).ctx.principal result.receipt

def outstandingFromAttempts (policy : Policy P A D) (boundaries : ParallelBoundary P A D)
    (attempts : List (Attempt P A D)) : Outstanding P A D :=
  attempts.foldl (attemptOutstanding policy boundaries) zeroOutstanding

variable [Fintype P] [Fintype A] [Fintype D]

-- BEGIN PROOFS

/-- The same evaluated receipt used by execution gives the exact change at every cell. -/
theorem step_receipt_balance {cfg : Config P A D} {boundary : Boundary P A D}
    {index : Nat} {history : List (OutputObservation A)} {step : Step P A D}
    {pre : World P A D} {result : StepResult P A D}
    (h : StepSound cfg boundary index history step pre result) (cell : Cell P A D) :
    result.world.state.balance cell =
      pre.state.balance cell + receiptEffect result.receipt cell := by
  cases h with
  | invoke inv pre post iface request e prepared executed extracted applied =>
    exact ((applyEvaluated_ok_iff _ _ _ _ _ _).mp applied).2.2 cell
  | issue => simp [receiptEffect]
  | revoke => simp [receiptEffect]

omit [Fintype P] [Fintype A] [Fintype D] in
theorem outstandingFromAttempts_append (policy : Policy P A D)
    (boundaries : ParallelBoundary P A D) (xs ys : List (Attempt P A D)) :
    outstandingFromAttempts policy boundaries (xs ++ ys) =
      ys.foldl (attemptOutstanding policy boundaries)
        (outstandingFromAttempts policy boundaries xs) := List.foldl_append

/-- Supply rejection retains the just-updated diagnostic table. -/
theorem advance_outstanding (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (policy : Policy P A D) (left right : Branch P A D) (m : Machine P A D)
    (b : BranchId) (active : m.abort = none) :
    (advance cfg boundaries policy left right m b).outstanding =
      match (Interleaving.advance cfg boundaries left right m.speculative b).attempts[
          m.speculative.attempts.length]? with
      | none => m.outstanding
      | some attempt => attemptOutstanding policy boundaries m.outstanding attempt := by
  cases hg : (Interleaving.advance cfg boundaries left right m.speculative b).attempts[
      m.speculative.attempts.length]? with
  | none => simp [advance, active, hg]
  | some attempt =>
    cases he : attempt.outcome with
    | error reason => simp [advance, active, hg, attemptOutstanding, he]
    | ok result =>
      simp only [advance, active, hg, attemptOutstanding, he]
      split <;> rfl

/-- Actual attempts, including the final successful supply-violating receipt, determine debt. -/
theorem advance_outstanding_fold (cfg : Config P A D)
    (boundaries : ParallelBoundary P A D) (policy : Policy P A D)
    (left right : Branch P A D) (m : Machine P A D) (b : BranchId)
    (old : m.outstanding = outstandingFromAttempts policy boundaries m.speculative.attempts) :
    (advance cfg boundaries policy left right m b).outstanding =
      outstandingFromAttempts policy boundaries
        (advance cfg boundaries policy left right m b).speculative.attempts := by
  cases ha : m.abort with
  | some reason => simpa only [advance_aborted _ _ _ _ _ _ _ reason ha] using old
  | none =>
    rw [advance_outstanding _ _ _ _ _ _ _ ha, advance_speculative _ _ _ _ _ _ _ ha]
    cases hf : (m.speculative.local b).failure with
    | some failure =>
      simp only [Interleaving.advance, hf]
      cases b <;> simpa [Interleaving.Machine.skip, Interleaving.Machine.setLocal] using old
    | none =>
      cases hs : (selectBranch left right b)[(m.speculative.local b).consumed]? with
      | none =>
        simp only [Interleaving.advance, hf, hs]
        cases b <;> simpa [Interleaving.Machine.skip, Interleaving.Machine.setLocal] using old
      | some inv =>
        rw [interleaving_advance_appended _ _ _ _ _ _ _ hf hs]
        simp [outstandingFromAttempts_append, old]

theorem Reachable.outstanding_fold {cfg : Config P A D}
    {boundaries : ParallelBoundary P A D} {policy : Policy P A D}
    {left right : Branch P A D} {initial : World P A D} {m : Machine P A D}
    (h : Reachable cfg boundaries policy left right initial m) :
    m.outstanding = outstandingFromAttempts policy boundaries m.speculative.attempts := by
  induction h with
  | start => rfl
  | next b previous ih => exact advance_outstanding_fold _ _ _ _ _ _ _ ih

/-- A real accepted invocation preserves lane cash plus all qualified outstanding entries. -/
theorem accepted_cash_owed {cfg : Config P A D} {boundary : Boundary P A D}
    {index : Nat} {history : List (OutputObservation A)} {inv : Invocation P A D}
    {pre : World P A D} {result : StepResult P A D}
    (executed : executeStep cfg boundary index history (.invoke inv) pre = .ok result)
    (policy : Policy P A D) (owed : Outstanding P A D) (lane : Lane P A D)
    (hlane : lane ∈ policy.lanes) (hn : policy.participants.Nodup)
    (hp : boundary.ctx.principal ∈ policy.participants) :
    result.world.state.balance lane.cell +
      (policy.participants.map
        (updateOutstanding policy owed boundary.ctx.principal result.receipt lane)).sum =
      pre.state.balance lane.cell + (policy.participants.map (owed lane)).sum := by
  rw [step_receipt_balance (executeStep_sound _ _ _ _ _ _ _ executed),
    updateOutstanding_sum _ _ _ _ _ hlane hn hp]
  rw [add_assoc, ← add_sub_assoc, add_sub_cancel_left]

/-- Every reachable diagnostic prefix conserves lane cash plus signed participant obligations. -/
theorem Reachable.cash_owed {cfg : Config P A D}
    {boundaries : ParallelBoundary P A D} {policy : Policy P A D}
    {left right : Branch P A D} {initial : World P A D} {m : Machine P A D}
    (h : Reachable cfg boundaries policy left right initial m)
    (admitted : checkPolicy policy boundaries left right = .ok ⟨⟩)
    (lane : Lane P A D) (hlane : lane ∈ policy.lanes) :
    m.speculative.world.state.balance lane.cell +
      (policy.participants.map (m.outstanding lane)).sum = initial.state.balance lane.cell := by
  induction h with
  | start =>
    change initial.state.balance lane.cell +
      (policy.participants.map (fun _ ↦ (0 : ℚ))).sum = initial.state.balance lane.cell
    simp
  | @next m b previous ih =>
    cases ha : m.abort with
    | some reason => simpa only [advance_aborted _ _ _ _ _ _ _ reason ha] using ih
    | none =>
      have hf := previous.no_failures ha b
      rw [advance_outstanding _ _ _ _ _ _ _ ha, advance_speculative _ _ _ _ _ _ _ ha]
      cases hs : (selectBranch left right b)[(m.speculative.local b).consumed]? with
      | none =>
        simp only [Interleaving.advance, hf, hs]
        cases b <;> simpa [Interleaving.Machine.skip, Interleaving.Machine.setLocal] using ih
      | some inv =>
        have hidx := previous.interleaving.attempt_index b hf inv hs
        have hp := checkPolicy_covers policy boundaries left right admitted b
          (m.speculative.local b).nextIndex (by
            rw [hidx]
            exact (List.getElem?_eq_some_iff.mp hs).1)
        have hg := interleaving_advance_attempt cfg boundaries left right m.speculative b inv hf hs
        rw [hg]
        cases he : executeStep cfg (boundaries b (m.speculative.local b).nextIndex)
            (m.speculative.local b).nextIndex (m.speculative.local b).outputs
            (.invoke inv) m.speculative.world with
        | error reason =>
          simp only [he, attemptOutstanding, Interleaving.advance, hf, hs]
          cases b <;> simpa [Interleaving.Machine.refuse, Interleaving.Machine.setLocal] using ih
        | ok result =>
          simp only [he, attemptOutstanding, Interleaving.advance, hf, hs]
          have hstep := accepted_cash_owed he policy m.outstanding lane hlane
            (checkPolicy_participants_nodup _ _ _ _ admitted) hp
          cases b <;>
            simpa [Interleaving.Machine.accept, Interleaving.Machine.setLocal] using hstep.trans ih

theorem runPrefix_cash_owed (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (policy : Policy P A D) (initial : World P A D) (left right : Branch P A D)
    (schedule : Schedule) (admitted : checkPolicy policy boundaries left right = .ok ⟨⟩)
    (lane : Lane P A D) (hlane : lane ∈ policy.lanes) :
    (runPrefix cfg boundaries policy initial left right schedule).speculative.world.state.balance
      lane.cell + (policy.participants.map
        ((runPrefix cfg boundaries policy initial left right schedule).outstanding lane)).sum =
      initial.state.balance lane.cell :=
  (runPrefix_reachable _ _ _ _ _ _ _).cash_owed admitted lane hlane

/-- Full pointwise clearance restores each configured vault cell exactly. -/
theorem Reachable.cleared_cash {cfg : Config P A D}
    {boundaries : ParallelBoundary P A D} {policy : Policy P A D}
    {left right : Branch P A D} {initial : World P A D} {m : Machine P A D}
    (h : Reachable cfg boundaries policy left right initial m)
    (admitted : checkPolicy policy boundaries left right = .ok ⟨⟩)
    (cleared : residuals policy m.outstanding = [])
    (lane : Lane P A D) (hlane : lane ∈ policy.lanes) :
    m.speculative.world.state.balance lane.cell = initial.state.balance lane.cell := by
  have hall := (residuals_eq_nil_iff policy m.outstanding).mp cleared lane hlane
  have hs : (policy.participants.map (m.outstanding lane)).sum = 0 :=
    List.sum_eq_zero (by intro p hp; rcases List.mem_map.mp hp with ⟨q, hq, rfl⟩; exact hall q hq)
  simpa [hs] using h.cash_owed admitted lane hlane

end DefiKernel.Atomic


===== INPUT lean/DefiKernel/Atomic/Soundness.lean ORIGINAL_SHA256 4f47288077a5a12ac51efa428ea1e39fa145a3bcffa0f3d04906cc030dc2bb1d RENDERED_SHA256 4f47288077a5a12ac51efa428ea1e39fa145a3bcffa0f3d04906cc030dc2bb1d =====
import DefiKernel.Atomic.Execution
import DefiKernel.Interleaving.Soundness

/-! Actual atomic steps either preserve a halted machine or take one existing
interleaving step. Every diagnostic machine is an actual interleaving prefix. -/
namespace DefiKernel.Atomic
open Typed Composition Parallel Interleaving

variable {P A D : Type} [DecidableEq P] [DecidableEq A] [DecidableEq D]
variable [Fintype P] [Fintype A] [Fintype D]

inductive Reachable (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (policy : Policy P A D) (left right : Branch P A D) (initial : World P A D) :
    Machine P A D → Prop
  | start : Reachable cfg boundaries policy left right initial (Atomic.start initial)
  | next {m : Machine P A D} (branch : BranchId)
      (previous : Reachable cfg boundaries policy left right initial m) :
      Reachable cfg boundaries policy left right initial
        (advance cfg boundaries policy left right m branch)

-- BEGIN PROOFS

/-- Selection of an active real call appends exactly one attempt with the actual result. -/
theorem interleaving_advance_appended (cfg : Config P A D)
    (boundaries : ParallelBoundary P A D) (left right : Branch P A D)
    (m : Interleaving.Machine P A D) (branch : BranchId) (inv : Invocation P A D)
    (active : (m.local branch).failure = none)
    (selected : (selectBranch left right branch)[(m.local branch).consumed]? = some inv) :
    (Interleaving.advance cfg boundaries left right m branch).attempts =
      m.attempts ++ [⟨branch, (m.local branch).nextIndex, inv, m.world,
        executeStep cfg (boundaries branch (m.local branch).nextIndex)
          (m.local branch).nextIndex (m.local branch).outputs (.invoke inv) m.world⟩] := by
  simp only [Interleaving.advance, active, selected]
  cases he : executeStep cfg (boundaries branch (m.local branch).nextIndex)
      (m.local branch).nextIndex (m.local branch).outputs (.invoke inv) m.world <;> rfl

theorem interleaving_advance_attempt (cfg : Config P A D)
    (boundaries : ParallelBoundary P A D) (left right : Branch P A D)
    (m : Interleaving.Machine P A D) (branch : BranchId) (inv : Invocation P A D)
    (active : (m.local branch).failure = none)
    (selected : (selectBranch left right branch)[(m.local branch).consumed]? = some inv) :
    (Interleaving.advance cfg boundaries left right m branch).attempts[m.attempts.length]? =
      some ⟨branch, (m.local branch).nextIndex, inv, m.world,
        executeStep cfg (boundaries branch (m.local branch).nextIndex)
          (m.local branch).nextIndex (m.local branch).outputs (.invoke inv) m.world⟩ := by
  rw [interleaving_advance_appended _ _ _ _ _ _ _ active selected]
  simp

theorem advance_entry (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (policy : Policy P A D) (left right : Branch P A D) (m : Machine P A D)
    (branch : BranchId) :
    (advance cfg boundaries policy left right m branch).entryWorld = m.entryWorld := by
  unfold advance
  split
  · rfl
  · dsimp only
    split
    · rfl
    · split
      · rfl
      · split <;> rfl

theorem advance_speculative (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (policy : Policy P A D) (left right : Branch P A D) (m : Machine P A D)
    (branch : BranchId) (active : m.abort = none) :
    (advance cfg boundaries policy left right m branch).speculative =
      Interleaving.advance cfg boundaries left right m.speculative branch := by
  unfold advance
  rw [active]
  dsimp only
  split
  · rfl
  · split
    · rfl
    · split <;> rfl

theorem advance_position (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (policy : Policy P A D) (left right : Branch P A D) (m : Machine P A D)
    (branch : BranchId) (active : m.abort = none) :
    (advance cfg boundaries policy left right m branch).position = m.position + 1 := by
  unfold advance
  rw [active]
  dsimp only
  split
  · rfl
  · split
    · rfl
    · split <;> rfl

theorem advance_none_before (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (policy : Policy P A D) (left right : Branch P A D) (m : Machine P A D)
    (branch : BranchId)
    (active : (advance cfg boundaries policy left right m branch).abort = none) :
    m.abort = none := by
  cases h : m.abort with
  | none => rfl
  | some reason => simp [advance_aborted _ _ _ _ _ _ _ reason h, h] at active

theorem advance_no_failures (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (policy : Policy P A D) (left right : Branch P A D) (m : Machine P A D)
    (branch : BranchId)
    (old : ∀ b, (m.speculative.local b).failure = none)
    (active : (advance cfg boundaries policy left right m branch).abort = none) :
    ∀ b, ((advance cfg boundaries policy left right m branch).speculative.local b).failure =
      none := by
  have ha := advance_none_before _ _ _ _ _ _ _ active
  have hl : m.speculative.left.failure = none := old .left
  have hr : m.speculative.right.failure = none := old .right
  intro b
  rw [advance_speculative _ _ _ _ _ _ _ ha]
  cases hs : (selectBranch left right branch)[(m.speculative.local branch).consumed]? with
  | none =>
    simp only [Interleaving.advance, old branch, hs]
    cases branch <;> cases b <;>
      simp [Interleaving.Machine.skip, Interleaving.Machine.setLocal,
        Interleaving.Machine.local, hl, hr]
  | some inv =>
    have hg := interleaving_advance_attempt cfg boundaries left right m.speculative
      branch inv (old branch) hs
    cases he : executeStep cfg (boundaries branch (m.speculative.local branch).nextIndex)
        (m.speculative.local branch).nextIndex (m.speculative.local branch).outputs
        (.invoke inv) m.speculative.world with
    | error reason =>
      rw [he] at hg
      simp only [advance, ha, hg] at active
      contradiction
    | ok result =>
      simp only [Interleaving.advance, old branch, hs, he]
      cases branch <;> cases b <;>
        simp [Interleaving.Machine.accept, Interleaving.Machine.setLocal,
          Interleaving.Machine.local, hl, hr]

theorem Reachable.entry {cfg : Config P A D} {boundaries : ParallelBoundary P A D}
    {policy : Policy P A D} {left right : Branch P A D} {initial : World P A D}
    {m : Machine P A D} (h : Reachable cfg boundaries policy left right initial m) :
    m.entryWorld = initial := by
  induction h with
  | start => rfl
  | next branch previous ih => exact (advance_entry _ _ _ _ _ _ _).trans ih

theorem Reachable.interleaving {cfg : Config P A D} {boundaries : ParallelBoundary P A D}
    {policy : Policy P A D} {left right : Branch P A D} {initial : World P A D}
    {m : Machine P A D} (h : Reachable cfg boundaries policy left right initial m) :
    Interleaving.Reachable cfg boundaries left right initial m.speculative := by
  induction h with
  | start => exact .start
  | @next m branch previous ih =>
    cases ha : m.abort with
    | none =>
      rw [advance_speculative _ _ _ _ _ _ _ ha]
      exact .next branch ih (Interleaving.advance_sound _ _ _ _ _ _)
    | some reason =>
      rw [advance_aborted _ _ _ _ _ _ _ reason ha]
      exact ih

theorem Reachable.no_failures {cfg : Config P A D} {boundaries : ParallelBoundary P A D}
    {policy : Policy P A D} {left right : Branch P A D} {initial : World P A D}
    {m : Machine P A D} (h : Reachable cfg boundaries policy left right initial m)
    (active : m.abort = none) : ∀ b, (m.speculative.local b).failure = none := by
  induction h with
  | start => intro b; cases b <;> rfl
  | next branch previous ih =>
    exact advance_no_failures _ _ _ _ _ _ _
      (ih (advance_none_before _ _ _ _ _ _ _ active)) active

theorem continueRun_reachable (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (policy : Policy P A D) (left right : Branch P A D) (initial : World P A D)
    (m : Machine P A D) (h : Reachable cfg boundaries policy left right initial m)
    (schedule : Schedule) : Reachable cfg boundaries policy left right initial
      (continueRun cfg boundaries policy left right m schedule) := by
  induction schedule generalizing m with
  | nil => exact h
  | cons b tail ih => exact ih _ (.next b h)

theorem runPrefix_reachable (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (policy : Policy P A D) (initial : World P A D) (left right : Branch P A D)
    (schedule : Schedule) : Reachable cfg boundaries policy left right initial
      (runPrefix cfg boundaries policy initial left right schedule) :=
  continueRun_reachable _ _ _ _ _ _ _ .start _

/-- A witness is a literal prefix of the supplied schedule, not a reordered trace. -/
theorem continueRun_prefix (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (policy : Policy P A D) (left right : Branch P A D) (m : Machine P A D)
    (schedule : Schedule) :
    ∃ preTokens suffix, schedule = preTokens ++ suffix ∧
      (continueRun cfg boundaries policy left right m schedule).speculative =
        Interleaving.continueRun cfg boundaries left right m.speculative preTokens ∧
      (continueRun cfg boundaries policy left right m schedule).position =
        m.position + preTokens.length ∧
      ((continueRun cfg boundaries policy left right m schedule).abort = none →
        suffix = []) := by
  induction schedule generalizing m with
  | nil => exact ⟨[], [], rfl, rfl, (Nat.add_zero _).symm, fun _ => rfl⟩
  | cons b tail ih =>
    cases ha : m.abort with
    | some reason =>
      rw [continueRun_aborted _ _ _ _ _ _ _ reason ha]
      exact ⟨[], b :: tail, rfl, rfl, (Nat.add_zero _).symm, by simp [ha]⟩
    | none =>
      let next := advance cfg boundaries policy left right m b
      obtain ⟨preTokens, suffix, hs, hw, hp, hf⟩ := ih next
      refine ⟨b :: preTokens, suffix, by simp [hs], ?_, ?_, hf⟩
      · change (continueRun cfg boundaries policy left right next tail).speculative = _
        rw [hw]
        rw [show next.speculative = Interleaving.advance cfg boundaries left right
          m.speculative b from advance_speculative _ _ _ _ _ _ _ ha]
        rfl
      · change (continueRun cfg boundaries policy left right next tail).position = _
        rw [hp, show next.position = m.position + 1 from advance_position _ _ _ _ _ _ _ ha]
        simp [Nat.add_comm, Nat.add_left_comm]

theorem runPrefix_prefix (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (policy : Policy P A D) (initial : World P A D) (left right : Branch P A D)
    (schedule : Schedule) :
    ∃ preTokens suffix, schedule = preTokens ++ suffix ∧
      (runPrefix cfg boundaries policy initial left right schedule).speculative =
        Interleaving.runPrefix cfg boundaries initial left right preTokens ∧
      (runPrefix cfg boundaries policy initial left right schedule).position =
        preTokens.length ∧
      ((runPrefix cfg boundaries policy initial left right schedule).abort = none →
        suffix = []) := by
  simpa only [runPrefix, Interleaving.runPrefix, Atomic.start, Nat.zero_add] using
    continueRun_prefix cfg boundaries policy left right (Atomic.start initial) schedule

end DefiKernel.Atomic


===== INPUT lean/DefiKernel/Atomic/Tests.lean ORIGINAL_SHA256 e42ec7aab417fcd03c492fdc19b1d78f5dfdd91df95adbaf33cf8ea05145e5ad RENDERED_SHA256 e42ec7aab417fcd03c492fdc19b1d78f5dfdd91df95adbaf33cf8ea05145e5ad =====
import DefiKernel.Atomic.Examples
import DefiKernel.Atomic.Observation
import DefiKernel.Interleaving.Examples
import DefiKernel.Parallel.ObservationTests

/-! Named bounded checks compare production execution with independent complete expectations. -/
namespace DefiKernel.Atomic.Tests
open Typed Composition Parallel Typed.Examples Atomic.Examples
open Parallel.Examples (C W I B Evt output observed event)

abbrev O := Observation P A D
abbrev R := Atomic.Result P A D
abbrev Inner := InnerObservation P A D

def expectedInner (branch : BranchId) (e : Evt) : Inner :=
  ⟨branch, e.index, match e.step with | .invoke inv => inv | _ => draw 0,
    e.receipt, e.outputs⟩
def inners (branch : BranchId) (events : List Evt) : List Inner :=
  events.map (expectedInner branch)
def supplyZero : D → A → ℚ := fun _ _ ↦ 0
def shareSupply : D → A → ℚ := fun d a ↦ if d = .main ∧ a = .share then 3 else 0

def expectedCommit (schedule : Interleaving.Schedule) (world : W) (events : List Inner)
    (supply : D → A → ℚ := supplyZero) : O :=
  ⟨42, schedule, .committed, world, [⟨42, schedule, events⟩], supply⟩
def expectedAbort (schedule : Interleaving.Schedule) (reason : AbortReason P A D)
    (world : W := atomInitial) : O := ⟨42, schedule, .aborted reason, world, [], supplyZero⟩
def expectedRefused (schedule : Interleaving.Schedule) (reason : Atomic.AdmissionFailure P A D)
    (world : W := atomInitial) : O := ⟨42, schedule, .refused reason, world, [], supplyZero⟩
def run (left right : B) (schedule : Interleaving.Schedule)
    (policy : Policy P A D := basePolicy) (boundary : ParallelBoundary P A D := atomBoundary)
    (world : W := atomInitial) : R := runAtomic atomCfg boundary 42 policy world left right schedule

def checkExpected (actual : R) (expected : O) : Bool := observationEq (observe actual) expected

def allLanes : List (Lane P A D) := Parallel.Examples.cells.map fun c ↦ ⟨c.1, c.2.2, c.2.1⟩
def tableMatches (actual : Outstanding P A D) (expected : List (Residual P A D)) : Bool :=
  allLanes.all fun lane ↦ [Party.alice, .bob, .vault, .pool].all fun p ↦
    decide (actual lane p = expectedOutstanding expected lane p)
def machineMatches (m : Atomic.Machine P A D) (count position : Nat) (world : W)
    (owed : List (Residual P A D)) (events : List Inner) : Bool :=
  worldEq m.speculative.world world && worldEq m.entryWorld atomInitial &&
    decide (m.speculative.attempts.length = count ∧ m.position = position) &&
    tableMatches m.outstanding owed && decide ((diagnosticEvent 42 [] m).inner = events)
def diagnosticMatches (actual : R) (count position : Nat) (world : W)
    (owed : List (Residual P A D)) (events : List Inner) : Bool :=
  match actual with
  | .refused _ _ _ _ => false
  | .aborted _ _ _ m | .committed _ _ m => machineMatches m count position world owed events

def drawReturn := run drawReturnLeft [] [.left, .left]
def underReturn := run underLeft [] [.left, .left]
def overReturn := run overLeft [] [.left, .left]
def creditReturn := run creditLeft [] [.left, .left, .left]
def peerReturn := run [draw 7] [repay 7] [.left, .right] multiParticipantPolicy peerBoundary
def assetReturn := run [draw 7] [repayShare 7] [.left, .right] multiLanePolicy
def domainReturn := run [draw 7] [repayOther 7] [.left, .right] domainPolicy otherBoundary
def noOpRun := run noOpLeft [] [.left, .left]
def repeatedRun := run [repeatedDraw, repay 7] [] [.left, .left]
def nonlaneRun := run nonlaneLeft [] [.left, .left, .left]
def firstFail := run [draw 11, draw 1] [mintShare] [.left, .right, .left]
def middleFail := run [draw 7, draw 6, draw 1] [mintShare] [.left, .right, .left, .left]
def mintFail := run [mintShare, draw 11] [] [.left, .left]
def abortFirst : AbortReason P A D := .kernel .left 0 0 (draw 11) (.kernel .insufficientFunds)
def abortMiddle : AbortReason P A D := .kernel .left 1 2 (draw 6) (.kernel .insufficientFunds)
def abortMint : AbortReason P A D := .kernel .left 1 1 (draw 11) (.kernel .insufficientFunds)
def mintFirstEvent := mintEvent 0 mintShare shareAlice 3 11

def settlementChecks : List (String × Bool) := [
  ("atomic.fixture.catalog", validateCatalog atomCfg.registry atomCfg.catalog),
  ("atomic.fixture.store", decide (atomStore.entries.length = 120)),
  ("atomic.fixture.empty", checkExpected (run [] [] []) (expectedCommit [] atomInitial [])),
  ("atomic.fixture.empty.batch", checkExpected (run [] [] [] batchPolicy)
    (expectedCommit [] atomInitial [])),
  ("atomic.fixture.settlement.draw.return", checkExpected drawReturn
    (expectedCommit [.left, .left] atomInitial (inners .left drawReturnEvents))),
  ("atomic.fixture.settlement.draw.prefix", machineMatches
    (runPrefix atomCfg atomBoundary basePolicy atomInitial drawReturnLeft [] [.left])
    1 1 afterDraw drawResiduals (inners .left [drawEvent])),
  ("atomic.fixture.settlement.initial.table", machineMatches (Atomic.start atomInitial)
    0 0 atomInitial [] []),
  ("atomic.fixture.settlement.clear.table", diagnosticMatches drawReturn
    2 2 atomInitial [] (inners .left drawReturnEvents)),
  ("atomic.fixture.settlement.under", checkExpected underReturn
    (expectedAbort [.left, .left] (.unsettled underResiduals))),
  ("atomic.fixture.settlement.under.diagnostic", diagnosticMatches underReturn
    2 2 afterUnder underResiduals (inners .left underEvents)),
  ("atomic.fixture.settlement.over", checkExpected overReturn
    (expectedAbort [.left, .left] (.unsettled overResiduals))),
  ("atomic.fixture.settlement.credit.prefix", machineMatches
    (runPrefix atomCfg atomBoundary basePolicy atomInitial creditLeft [] [.left, .left])
    2 2 afterOver overResiduals (inners .left overEvents)),
  ("atomic.fixture.settlement.credit.commit", checkExpected creditReturn
    (expectedCommit [.left, .left, .left] atomInitial (inners .left creditEvents))),
  ("atomic.fixture.settlement.cross.principal", checkExpected peerReturn
    (expectedAbort [.left, .right] (.unsettled peerResiduals))),
  ("atomic.fixture.settlement.cross.principal.table", diagnosticMatches peerReturn
    2 2 afterPeerReturn peerResiduals
    [expectedInner .left drawEvent, expectedInner .right (repayEvent 0 7 10 .bob)]),
  ("atomic.fixture.settlement.cross.asset", checkExpected assetReturn
    (expectedAbort [.left, .right] (.unsettled assetResiduals))),
  ("atomic.fixture.settlement.cross.domain", checkExpected domainReturn
    (expectedAbort [.left, .right] (.unsettled domainResiduals))),
  ("atomic.fixture.settlement.last.lane", checkExpected
    (run [drawShare 1] [] [.left] multiLanePolicy)
    (expectedAbort [.left] (.unsettled lastLaneResiduals))),
  ("atomic.fixture.settlement.last.participant", checkExpected
    (run [] [draw 7] [.right] multiParticipantPolicy peerBoundary)
    (expectedAbort [.right] (.unsettled lastParticipantResiduals))),
  ("atomic.fixture.settlement.noop", checkExpected noOpRun
    (expectedAbort [.left, .left] (.unsettled drawResiduals))),
  ("atomic.fixture.settlement.noop.table", diagnosticMatches noOpRun
    2 2 afterDraw drawResiduals (inners .left [drawEvent, noOpEvent])),
  ("atomic.fixture.settlement.repeated.prefix", machineMatches
    (runPrefix atomCfg atomBoundary basePolicy atomInitial [repeatedDraw, repay 7] [] [.left])
    1 1 afterDraw drawResiduals (inners .left [repeatedEvent])),
  ("atomic.fixture.settlement.repeated.commit", checkExpected repeatedRun
    (expectedCommit [.left, .left] atomInitial (inners .left [repeatedEvent, repayEvent 1 7 10]))),
  ("atomic.fixture.supply.lane.nonvault", checkExpected (run [mintUSD] [] [.left])
    (expectedAbort [.left] (.laneSupply .left 0 0 mintUSD usdLane 3))),
  ("atomic.fixture.supply.lane.diagnostic", diagnosticMatches (run [mintUSD] [] [.left])
    1 1 afterLaneMint [] (inners .left [laneMintEvent])),
  ("atomic.fixture.supply.nonlane", checkExpected nonlaneRun
    (expectedCommit [.left, .left, .left] afterNonlaneMint
      (inners .left nonlaneEvents) shareSupply)),
  ("atomic.fixture.abort.first.public", checkExpected firstFail
    (expectedAbort [.left, .right, .left] abortFirst)),
  ("atomic.fixture.abort.first.stopped", diagnosticMatches firstFail 1 1 atomInitial [] []),
  ("atomic.fixture.abort.middle.public", checkExpected middleFail
    (expectedAbort [.left, .right, .left, .left] abortMiddle)),
  ("atomic.fixture.abort.middle.stopped", diagnosticMatches middleFail 3 3 afterDrawNonlaneMint
    drawResiduals [expectedInner .left drawEvent, expectedInner .right mintFirstEvent]),
  ("atomic.fixture.abort.outputs", decide ((observe middleFail).events = [])),
  ("atomic.fixture.abort.supply", checkExpected mintFail
    (expectedAbort [.left, .left] abortMint)),
  ("atomic.fixture.abort.supply.diagnostic", diagnosticMatches mintFail 2 2 afterNonlaneMint []
    (inners .left [mintFirstEvent])),
  ("atomic.fixture.collateral", decide ((observe nonlaneRun).world.state.balance collateral = 9 ∧
    (observe middleFail).world.state.balance collateral = 9)),
  ("atomic.fixture.capability.revoked", checkExpected
    (run drawReturnLeft [] [.left, .left] basePolicy atomBoundary revokedInitial)
    (expectedAbort [.left, .left]
      (.kernel .left 0 0 (draw 7) (.kernel .unauthorizedInvoke)) revokedInitial)),
  ("atomic.fixture.capability.live", checkExpected drawReturn
    (expectedCommit [.left, .left] atomInitial (inners .left drawReturnEvents))) ]

/-- Earlier reference fixtures retain independent complete event expectations. -/
def oldRun (cfg : Config P A D) (boundary : ParallelBoundary P A D) (world : W)
    (left right : B) (schedule : Interleaving.Schedule) : R :=
  runAtomic cfg boundary 42 ⟨[], [.alice, .bob, .vault, .pool]⟩ world left right schedule

def liveRun := oldRun Interleaving.Examples.liveCfg Parallel.Examples.boundaries
  Parallel.Examples.initial [Parallel.Examples.usd 0, Parallel.Examples.usd 0]
  [Parallel.Examples.peerUSD 4] [.left, .right, .left]
def liveWorld : W := ⟨⟨Parallel.Examples.balanceTable (9 / 2) (19 / 2) 20 0 16 1, by
  intro c
  simp only [Parallel.Examples.balanceTable]
  repeat' split
  all_goals norm_num⟩, Parallel.Examples.store⟩
def liveEvents : List Inner := [
  expectedInner .left (Parallel.Examples.statefulEvent 0 5 5),
  expectedInner .right (Parallel.Examples.transferEvent 0 (Parallel.Examples.peerUSD 4)
    Parallel.Examples.vaultUSD Parallel.Examples.aliceUSD 4 [output 0 1 .usd 9]),
  expectedInner .left (Parallel.Examples.statefulEvent 1 (9 / 2) (19 / 2))]
def peerOnlyRun := oldRun Parallel.Examples.sameAssetCfg Parallel.Examples.boundaries
  Parallel.Examples.initial [Parallel.Examples.usd 3, Interleaving.Examples.peerOnly]
  [Parallel.Examples.peerUSD 4] [.left, .right, .left]
def ownRun := oldRun Parallel.Examples.sameAssetCfg Parallel.Examples.boundaries
  Parallel.Examples.initial [Parallel.Examples.usd 3, Interleaving.Examples.snapshotConsumer]
  [Parallel.Examples.peerUSD 4] [.left, .right, .left]
def ownWorld : W := ⟨⟨Parallel.Examples.balanceTable 4 6 20 0 16 5, by
  intro c
  simp only [Parallel.Examples.balanceTable]
  repeat' split
  all_goals decide⟩, Parallel.Examples.store⟩
def timedRun := oldRun Parallel.Examples.timedCfg Parallel.Examples.timedBoundaries
  Parallel.Examples.initial Parallel.Examples.timedLeft Parallel.Examples.timedRight
  [.right, .left, .left, .right]
def timedWorld : W := ⟨⟨Parallel.Examples.balanceTable 8 2 14 6, by
  intro c
  simp only [Parallel.Examples.balanceTable]
  repeat' split
  all_goals decide⟩, Parallel.Examples.store⟩

def historyChecks : List (String × Bool) := [
  ("atomic.fixture.live.complete", checkExpected liveRun
    (expectedCommit [.left, .right, .left] liveWorld liveEvents)),
  ("atomic.fixture.history.peer.only", checkExpected peerOnlyRun
    (expectedAbort [.left, .right, .left]
      (.kernel .left 1 2 Interleaving.Examples.peerOnly (.interface .unavailableOutput))
      Parallel.Examples.initial)),
  ("atomic.fixture.history.own", checkExpected ownRun
    (expectedCommit [.left, .right, .left] ownWorld [
      expectedInner .left (Parallel.Examples.leftEvent 0 3 3),
      expectedInner .right (Parallel.Examples.peerEvent 0 4 5),
      expectedInner .left (Parallel.Examples.transferEvent 1
        Interleaving.Examples.snapshotConsumer Parallel.Examples.aliceUSD Parallel.Examples.bobUSD
        3 [output 1 0 .usd 6])])),
  ("atomic.fixture.boundary.local", checkExpected timedRun
    (expectedCommit [.right, .left, .left, .right] timedWorld [
      expectedInner .right (Parallel.Examples.timedEvent 0
        (Parallel.Examples.timedInvocation 1 11 .share 4 200 .alice)
        Parallel.Examples.vaultShare Parallel.Examples.aliceShare 4 200 4),
      expectedInner .left (Parallel.Examples.timedEvent 0
        (Parallel.Examples.timedInvocation 0 10 .usd 3 100 .bob)
        Parallel.Examples.aliceUSD Parallel.Examples.bobUSD 3 100 3),
      expectedInner .left (Parallel.Examples.timedEvent 1
        (Parallel.Examples.timedInvocation 0 10 .usd 1 101 .alice)
        Parallel.Examples.bobUSD Parallel.Examples.aliceUSD 1 101 2),
      expectedInner .right (Parallel.Examples.timedEvent 1
        (Parallel.Examples.timedInvocation 1 11 .share 2 201 .alice)
        Parallel.Examples.vaultShare Parallel.Examples.aliceShare 2 201 6)])) ]

def invalidCfg : Config P A D := { atomCfg with catalog := atomCfg.catalog ++ atomCfg.catalog }
def unknown : I := { draw 1 with operation := ⟨9999⟩ }
def laterBoundary (_ : BranchId) (index : Nat) : Boundary P A D :=
  ⟨⟨if index = 0 then .alice else .bob, .main⟩, fresh, 100⟩
def missingCap : I := { draw 7 with capabilityIds := [] }
def debitMissing : I := { draw 7 with capabilityIds := [⟨0⟩] }
def batchSingle := run [draw 7] [] [.left] batchPolicy

def admissionChecks : List (String × Bool) := [
  ("atomic.fixture.batch.single", checkExpected batchSingle
    (expectedCommit [.left] afterDraw (inners .left [drawEvent]))),
  ("atomic.fixture.order.commit", checkExpected (run [draw 7] [repay 7] [.left, .right])
    (expectedCommit [.left, .right] atomInitial
      [expectedInner .left drawEvent, expectedInner .right (repayEvent 0 7 10)])),
  ("atomic.fixture.order.abort", checkExpected (run [draw 7] [repay 7] [.right, .left])
    (expectedAbort [.right, .left]
      (.kernel .right 0 0 (repay 7) (.kernel .insufficientFunds)))),
  ("atomic.fixture.capability.missing", checkExpected (run [missingCap] [] [.left])
    (expectedAbort [.left] (.kernel .left 0 0 missingCap (.kernel .unauthorizedInvoke)))),
  ("atomic.fixture.capability.debit", checkExpected (run [debitMissing] [] [.left])
    (expectedAbort [.left] (.kernel .left 0 0 debitMissing (.kernel .unauthorizedDebit)))),
  ("atomic.admission.configuration", checkExpected
    (runAtomic invalidCfg atomBoundary 42 duplicateLanePolicy atomInitial [unknown] [] [])
    (expectedRefused [] .configuration)),
  ("atomic.admission.left", checkExpected
    (run [draw 11, unknown] [unknown] [] duplicateLanePolicy)
    (expectedRefused [] (.structural .left ⟨1, .interface .unknownOperation⟩))),
  ("atomic.admission.right", checkExpected (run [draw 7] [unknown] [] duplicateLanePolicy)
    (expectedRefused [] (.structural .right ⟨0, .interface .unknownOperation⟩))),
  ("atomic.admission.lane.alternate.vault", checkExpected
    (run [draw 7] [] [] duplicateLanePolicy)
    (expectedRefused [] (.policy (.duplicateLane 0 1 usdLane ⟨.main, .usd, .pool⟩)))),
  ("atomic.admission.lane.same.vault", checkExpected
    (run [] [] [] ⟨[usdLane, usdLane], [.alice]⟩)
    (expectedRefused [] (.policy (.duplicateLane 0 1 usdLane usdLane)))),
  ("atomic.admission.participant.duplicate", checkExpected
    (run [] [] [] duplicateParticipantPolicy)
    (expectedRefused [] (.policy (.duplicateParticipant 0 2 .alice)))),
  ("atomic.admission.participant.peer", checkExpected
    (run [draw 7] [repay 7] [] basePolicy peerBoundary)
    (expectedRefused [] (.policy (.uncoveredParticipant .right 0 .bob)))),
  ("atomic.admission.participant.suffix", checkExpected
    (run [draw 11, draw 0] [] [] basePolicy laterBoundary)
    (expectedRefused [] (.policy (.uncoveredParticipant .left 1 .bob)))),
  ("atomic.admission.schedule.missing", checkExpected (run [draw 7] [repay 7] [.left])
    (expectedRefused [.left] (.schedule ⟨1, 1, 1, 0⟩))),
  ("atomic.admission.schedule.excess", checkExpected (run [] [] [.right])
    (expectedRefused [.right] (.schedule ⟨0, 0, 0, 1⟩))),
  ("atomic.admission.extra.participant", checkExpected
    (run drawReturnLeft [] [.left, .left] multiParticipantPolicy)
    (expectedCommit [.left, .left] atomInitial (inners .left drawReturnEvents))) ]

def baselineObservation : O := expectedCommit [.left] afterDraw (inners .left [drawEvent])
def baselineInner : Inner := expectedInner .left drawEvent
def differentObservation (changed : O) : Bool := !observationEq baselineObservation changed
def changedInner (f : Inner → Inner) : O :=
  { baselineObservation with events := [⟨42, [.left], [f baselineInner]⟩] }
def changedOutput (output : OutputObservation A) : Bool :=
  differentObservation (changedInner fun e ↦ {e with outputs := [output]})
def abortObservation (reason : AbortReason P A D) : O :=
  expectedAbort [.left, .right, .left, .left] reason
def abortDifference (reason : AbortReason P A D) : Bool :=
  !observationEq (abortObservation abortMiddle) (abortObservation reason)
def residualObservation (entries : List (Residual P A D)) : O :=
  expectedAbort [.left, .right] (.unsettled entries)
def residualDifference (entries : List (Residual P A D)) : Bool :=
  !observationEq (residualObservation peerResiduals) (residualObservation entries)
def supplyObservation (reason : AbortReason P A D) : O := expectedAbort [.left] reason
def supplyDifference (reason : AbortReason P A D) : Bool :=
  !observationEq (supplyObservation (.laneSupply .left 0 0 mintUSD usdLane 3))
    (supplyObservation reason)

def observationChecks : List (String × Bool) := [
  ("atomic.observe.equal", observationEq baselineObservation
    ⟨42, [.left], .committed, atomWorld 8 7 3 8 10 8 10,
      [⟨42, [.left], [⟨.left, 0, draw 7,
        (Parallel.Examples.transferEvent 0 (draw 7) usdVault usdAlice 7
          [output 0 100 .usd 3]).receipt, [output 0 100 .usd 3]⟩]⟩], fun _ _ ↦ 0⟩),
  ("atomic.observe.kind", differentObservation {baselineObservation with
    outcome := .aborted (.unsettled drawResiduals)}),
  ("atomic.observe.label", differentObservation {baselineObservation with label := 43}),
  ("atomic.observe.schedule", differentObservation {baselineObservation with schedule := [.right]}),
  ("atomic.observe.world", differentObservation {baselineObservation with world := atomInitial}),
  ("atomic.observe.store", differentObservation {baselineObservation with
    world := {afterDraw with capabilities := revokedStore}}),
  ("atomic.observe.supply", differentObservation {baselineObservation with supply := shareSupply}),
  ("atomic.observe.events", differentObservation {baselineObservation with events := []}),
  ("atomic.observe.event.label", differentObservation {baselineObservation with
    events := [⟨43, [.left], [baselineInner]⟩]}),
  ("atomic.observe.event.schedule", differentObservation {baselineObservation with
    events := [⟨42, [.right], [baselineInner]⟩]}),
  ("atomic.observe.event.inner", differentObservation {baselineObservation with
    events := [⟨42, [.left], []⟩]}),
  ("atomic.observe.inner.branch",
    differentObservation (changedInner fun e ↦ {e with branch := .right})),
  ("atomic.observe.inner.index", differentObservation (changedInner fun e ↦ {e with index := 1})),
  ("atomic.observe.inner.invocation", differentObservation
    (changedInner fun e ↦ {e with invocation := draw 8})),
  ("atomic.observe.inner.outputs",
    differentObservation (changedInner fun e ↦ {e with outputs := []})),
  ("atomic.observe.output.index", changedOutput (output 1 100 .usd 3)),
  ("atomic.observe.output.component", changedOutput (output 0 101 .usd 3)),
  ("atomic.observe.output.port", changedOutput ⟨0, ⟨⟨100⟩, ⟨1⟩⟩, ⟨.amount .usd, 3⟩⟩),
  ("atomic.observe.output.asset", changedOutput (output 0 100 .share 3)),
  ("atomic.observe.output.amount", changedOutput (output 0 100 .usd 4)),
  ("atomic.observe.abort.equal", observationEq (abortObservation abortMiddle)
    (expectedAbort [.left, .right, .left, .left]
      (.kernel .left 1 2 (draw 6) (.kernel .insufficientFunds)))),
  ("atomic.observe.abort.reason", abortDifference (.kernel .left 1 2 (draw 6) (.kernel .guard))),
  ("atomic.observe.abort.branch", abortDifference
    (.kernel .right 1 2 (draw 6) (.kernel .insufficientFunds))),
  ("atomic.observe.abort.index", abortDifference
    (.kernel .left 0 2 (draw 6) (.kernel .insufficientFunds))),
  ("atomic.observe.abort.position", abortDifference
    (.kernel .left 1 1 (draw 6) (.kernel .insufficientFunds))),
  ("atomic.observe.abort.invocation", abortDifference
    (.kernel .left 1 2 (draw 7) (.kernel .insufficientFunds))),
  ("atomic.observe.abort.label", !observationEq (abortObservation abortMiddle)
    {abortObservation abortMiddle with label := 43}),
  ("atomic.observe.abort.schedule", !observationEq (abortObservation abortMiddle)
    {abortObservation abortMiddle with schedule := [.left]}),
  ("atomic.observe.residual.equal", observationEq (residualObservation peerResiduals)
    (residualObservation [⟨usdLane, .alice, 7⟩, ⟨usdLane, .bob, -7⟩])),
  ("atomic.observe.residual.amount", residualDifference
    [⟨usdLane, .alice, 8⟩, ⟨usdLane, .bob, -7⟩]),
  ("atomic.observe.residual.principal", residualDifference
    [⟨usdLane, .vault, 7⟩, ⟨usdLane, .bob, -7⟩]),
  ("atomic.observe.residual.asset", residualDifference
    [⟨shareLane, .alice, 7⟩, ⟨usdLane, .bob, -7⟩]),
  ("atomic.observe.residual.domain", residualDifference
    [⟨otherLane, .alice, 7⟩, ⟨usdLane, .bob, -7⟩]),
  ("atomic.observe.residual.vault", residualDifference
    [⟨⟨.main, .usd, .pool⟩, .alice, 7⟩, ⟨usdLane, .bob, -7⟩]),
  ("atomic.observe.residual.order", residualDifference
    [⟨usdLane, .bob, -7⟩, ⟨usdLane, .alice, 7⟩]),
  ("atomic.observe.residual.omitted", residualDifference [⟨usdLane, .alice, 7⟩]),
  ("atomic.observe.supply.abort.amount",
    supplyDifference (.laneSupply .left 0 0 mintUSD usdLane 4)),
  ("atomic.observe.supply.abort.lane",
    supplyDifference (.laneSupply .left 0 0 mintUSD shareLane 3)),
  ("atomic.observe.supply.abort.branch",
    supplyDifference (.laneSupply .right 0 0 mintUSD usdLane 3)),
  ("atomic.observe.supply.abort.index", supplyDifference (.laneSupply .left 1 0 mintUSD usdLane 3)),
  ("atomic.observe.supply.abort.position",
    supplyDifference (.laneSupply .left 0 1 mintUSD usdLane 3)),
  ("atomic.observe.supply.abort.invocation", supplyDifference
    (.laneSupply .left 0 0 mintShare usdLane 3)),
  ("atomic.observe.admission.reason", !observationEq (expectedRefused [] .configuration)
    (expectedRefused [] (.policy (.duplicateParticipant 0 1 .alice)))),
  ("atomic.observe.admission.label", !observationEq (expectedRefused [] .configuration)
    {expectedRefused [] .configuration with label := 43}),
  ("atomic.observe.admission.schedule", !observationEq (expectedRefused [] .configuration)
    (expectedRefused [.left] .configuration)),
  ("atomic.observe.diagnostic.erased", observationsEqual
    (.aborted 42 [.left] abortFirst (Atomic.start atomInitial))
    (.aborted 42 [.left] abortFirst
      {Atomic.start atomInitial with speculative := Interleaving.start afterDraw})) ]

def receiptRequest : Request P A D := ⟨⟨100⟩, [], [⟨.amount .usd, 7⟩], atomCaps, none⟩
def receiptEvaluated := Parallel.Examples.evaluatedTransfer usdVault usdAlice 7

def requestChanges : List (String × Request P A D) := [
  ("operation", {receiptRequest with operation := ⟨101⟩}),
  ("parties", {receiptRequest with parties := [.bob]}),
  ("arguments", {receiptRequest with arguments := [⟨.amount .usd, 8⟩]}),
  ("capabilities", {receiptRequest with capabilityIds := []}),
  ("actor", {receiptRequest with claimedActor := some .bob}) ]
def evaluatedChanges : List (String × Evaluated P A D) := [
  ("guard", {receiptEvaluated with guard := false}),
  ("deltas", {receiptEvaluated with deltas := [(usdVault, -6), (usdAlice, 6)]}),
  ("supply", {receiptEvaluated with supplies := [((.main, .usd), 1)]}),
  ("required.state", {receiptEvaluated with requiredStateReads := [usdAlice]}),
  ("required.environment", {receiptEvaluated with requiredEnvReads := [.currentTime]}),
  ("declared.state", {receiptEvaluated with declaredStateReads := [usdAlice]}),
  ("declared.environment", {receiptEvaluated with declaredEnvReads := [.currentTime]}),
  ("writes", {receiptEvaluated with writes := [usdVault]}) ]
def receiptChecks : List (String × Bool) :=
  requestChanges.map (fun (name, request) ↦ ("atomic.observe.request." ++ name,
    differentObservation (changedInner fun e ↦
      {e with receipt := .invoked request receiptEvaluated}))) ++
  evaluatedChanges.map (fun (name, evaluated) ↦ ("atomic.observe.receipt." ++ name,
    differentObservation (changedInner fun e ↦
      {e with receipt := .invoked receiptRequest evaluated}))) ++
  [("atomic.observe.receipt.constructor", differentObservation
    (changedInner fun e ↦ {e with receipt := .revoked ⟨0⟩}))]

def afterDrawLaneMint := atomWorld 11 7 3 8 10 8 10
def laneMintAfterDrawEvent := mintEvent 1 mintUSD usdAlice 3 11
def laneMintAfterDraw := run [draw 7, mintUSD, repay 7] [noop]
  [.left, .left, .right, .left]
def fundedWorld : W := ⟨⟨Parallel.Examples.balanceTable 2 8 20 0 16 5, by
  intro c
  simp only [Parallel.Examples.balanceTable]
  repeat' split
  all_goals decide⟩, Parallel.Examples.store⟩
def snapshotWorld : W := ⟨⟨Parallel.Examples.balanceTable 2 8 20 0, by
  intro c
  simp only [Parallel.Examples.balanceTable]
  repeat' split
  all_goals decide⟩, Parallel.Examples.store⟩

def extendedChecks : List (String × Bool) := [
  ("atomic.fixture.settlement.over.diagnostic", diagnosticMatches overReturn
    2 2 afterOver overResiduals (inners .left overEvents)),
  ("atomic.fixture.settlement.cross.asset.table", diagnosticMatches assetReturn
    2 2 afterAssetReturn assetResiduals [expectedInner .left drawEvent,
      expectedInner .right (expectedTransfer 0 (repayShare 7) shareAlice shareVault 7 17)]),
  ("atomic.fixture.settlement.cross.domain.table", diagnosticMatches domainReturn
    2 2 afterDomainReturn domainResiduals [expectedInner .left drawEvent,
      expectedInner .right (expectedTransfer 0 (repayOther 7) otherAlice otherVault 7 17)]),
  ("atomic.fixture.settlement.last.lane.table", diagnosticMatches
    (run [drawShare 1] [] [.left] multiLanePolicy) 1 1 afterLastLane lastLaneResiduals
    (inners .left lastLaneEvents)),
  ("atomic.fixture.settlement.last.participant.table", diagnosticMatches
    (run [] [draw 7] [.right] multiParticipantPolicy peerBoundary)
    1 1 afterLastParticipant lastParticipantResiduals (inners .right lastParticipantEvents)),
  ("atomic.fixture.supply.lane.after.draw", checkExpected laneMintAfterDraw
    (expectedAbort [.left, .left, .right, .left]
      (.laneSupply .left 1 1 mintUSD usdLane 3))),
  ("atomic.fixture.supply.lane.after.draw.table", diagnosticMatches laneMintAfterDraw
    2 2 afterDrawLaneMint drawResiduals (inners .left [drawEvent, laneMintAfterDrawEvent])),
  ("atomic.fixture.history.funded.literal", checkExpected
    (oldRun Parallel.Examples.sameAssetCfg Parallel.Examples.boundaries Parallel.Examples.initial
      [Parallel.Examples.usd 3, Parallel.Examples.usd 5] [Parallel.Examples.peerUSD 4]
      [.left, .right, .left])
    (expectedCommit [.left, .right, .left] fundedWorld [
      expectedInner .left (Parallel.Examples.leftEvent 0 3 3),
      expectedInner .right (Parallel.Examples.peerEvent 0 4 5),
      expectedInner .left (Parallel.Examples.leftEvent 1 5 8)])),
  ("atomic.fixture.history.both.own", checkExpected
    (oldRun Interleaving.Examples.snapshotCfg Parallel.Examples.boundaries Parallel.Examples.initial
      [Parallel.Examples.usd 2, Interleaving.Examples.snapshotConsumer]
      [Parallel.Examples.usd 1, Interleaving.Examples.snapshotConsumer]
      [.left, .right, .left, .right])
    (expectedCommit [.left, .right, .left, .right] snapshotWorld [
      expectedInner .left (Parallel.Examples.leftEvent 0 2 2),
      expectedInner .right (Parallel.Examples.leftEvent 0 1 3),
      expectedInner .left (Parallel.Examples.transferEvent 1 Interleaving.Examples.snapshotConsumer
        Parallel.Examples.aliceUSD Parallel.Examples.bobUSD 2 [output 1 0 .usd 5]),
      expectedInner .right (Parallel.Examples.transferEvent 1 Interleaving.Examples.snapshotConsumer
        Parallel.Examples.aliceUSD Parallel.Examples.bobUSD 3 [output 1 0 .usd 8])])) ]

/-- Public-world chaining starts a fresh history even after a speculative USD snapshot. -/
def abortedProducer := run [mintUSD, draw 11] [] [.left, .left] batchPolicy
def abortedSnapshotConsumer : I :=
  { draw 4 with inputs := [.priorOutput 0 ⟨⟨108⟩, ⟨0⟩⟩] }
def followup := run [noop, abortedSnapshotConsumer] [] [.left, .left]
  batchPolicy atomBoundary abortedProducer.publicWorld
def followupFunded := run [noop, draw 4] [] [.left, .left]
  batchPolicy atomBoundary abortedProducer.publicWorld
def initialNoOpEvent : Evt := event 0 noop [⟨.amount .usd, 0⟩]
  ⟨true, [], [], [], [], [], [], []⟩ [output 0 106 .usd 10]
def followupChecks : List (String × Bool) := [
  ("atomic.fixture.followup.producer.aborted", checkExpected abortedProducer
    (expectedAbort [.left, .left]
      (.kernel .left 1 1 (draw 11) (.kernel .insufficientFunds)))),
  ("atomic.fixture.followup.producer.diagnostic", diagnosticMatches abortedProducer
    2 2 afterLaneMint [] (inners .left [laneMintEvent])),
  ("atomic.fixture.followup.fresh.history", checkExpected followup
    (expectedAbort [.left, .left]
      (.kernel .left 1 1 abortedSnapshotConsumer (.interface .unavailableOutput)))),
  ("atomic.fixture.followup.funded.literal", checkExpected followupFunded
    (expectedCommit [.left, .left] (atomWorld 5 7 6 8 10 8 10)
      (inners .left [initialNoOpEvent, expectedTransfer 1 (draw 4) usdVault usdAlice 4 6]))) ]

def dualSupplyTemplate : Op where
  signature := []
  domain := .main
  partyArity := 0
  guard := .lit true
  deltas := [⟨.usd, refAt .main .usd .caller, .lit (3 : ℚ)⟩,
    ⟨.share, refAt .main .share .caller, .lit (4 : ℚ)⟩]
  supplyDeltas := [⟨.main, .usd, .lit (3 : ℚ)⟩, ⟨.main, .share, .lit (4 : ℚ)⟩]
  stateReads := []
  envReads := []
  writes := [packedAt .main .usd .caller, packedAt .main .share .caller]
def dualSupplyCfg : Config P A D := { atomCfg with
  registry := fun id ↦ if id = ⟨112⟩ then some dualSupplyTemplate else atomCfg.registry id
  catalog := atomCfg.catalog ++ [fixtureComponent ⟨112, dualSupplyTemplate, usdAlice⟩] }
def dualSupplyStore : Store := ⟨atomStore.entries ++
  [⟨⟨.alice, .main, ⟨112⟩, .invoke⟩, true⟩,
   ⟨⟨.alice, .main, ⟨112⟩, .changeSupply .main .usd⟩, true⟩,
   ⟨⟨.alice, .main, ⟨112⟩, .changeSupply .main .share⟩, true⟩]⟩
def dualSupplyInitial : W := atomWorld 1 7 10 8 10 8 10 dualSupplyStore
def dualSupplyInvocation : I := ⟨⟨112⟩, ⟨112⟩, [], [], [⟨120⟩, ⟨121⟩, ⟨122⟩], none⟩
def dualSupplyRun (lanes : List (Lane P A D)) : R :=
  runAtomic dualSupplyCfg atomBoundary 42 ⟨lanes, [.alice]⟩ dualSupplyInitial
    [draw 7, dualSupplyInvocation, draw 1] [] [.left, .left, .left]
def dualSupplyEvent : Evt := event 1 dualSupplyInvocation []
  ⟨true, [(usdAlice, 3), (shareAlice, 4)], [((.main, .usd), 3), ((.main, .share), 4)],
    [], [], [], [], [usdAlice, shareAlice]⟩ [output 1 112 .usd 11]
def dualSupplyDiagnostic (actual : R) : Bool := match actual with
  | .refused _ _ _ _ => false
  | .aborted _ _ _ m | .committed _ _ m =>
    worldEq m.entryWorld dualSupplyInitial &&
    worldEq m.speculative.world (atomWorld 11 7 3 12 10 8 10 dualSupplyStore) &&
    decide (m.speculative.attempts.length = 2 ∧ m.position = 2) &&
    tableMatches m.outstanding drawResiduals &&
    decide ((diagnosticEvent 42 [] m).inner = inners .left [drawEvent, dualSupplyEvent])

def precedenceChecks : List (String × Bool) := [
  ("atomic.admission.precedence.lane.participant.uncovered.count", checkExpected
    (run [draw 11, draw 0] [] [] ⟨[usdLane, usdLane], [.alice, .alice]⟩ laterBoundary)
    (expectedRefused [] (.policy (.duplicateLane 0 1 usdLane usdLane)))),
  ("atomic.admission.precedence.participant.uncovered.count", checkExpected
    (run [draw 11, draw 0] [] [] ⟨[usdLane], [.alice, .alice]⟩ laterBoundary)
    (expectedRefused [] (.policy (.duplicateParticipant 0 1 .alice)))),
  ("atomic.fixture.supply.first.lane.usd", checkExpected (dualSupplyRun [usdLane, shareLane])
    (expectedAbort [.left, .left, .left]
      (.laneSupply .left 1 1 dualSupplyInvocation usdLane 3) dualSupplyInitial)),
  ("atomic.fixture.supply.first.lane.share", checkExpected (dualSupplyRun [shareLane, usdLane])
    (expectedAbort [.left, .left, .left]
      (.laneSupply .left 1 1 dualSupplyInvocation shareLane 4) dualSupplyInitial)),
  ("atomic.fixture.supply.first.lane.diagnostic.usd",
    dualSupplyDiagnostic (dualSupplyRun [usdLane, shareLane])),
  ("atomic.fixture.supply.first.lane.diagnostic.share",
    dualSupplyDiagnostic (dualSupplyRun [shareLane, usdLane])) ]

def runtimeChecks : List (String × Bool) :=
  settlementChecks ++ historyChecks ++ admissionChecks ++ observationChecks ++
    receiptChecks ++ extendedChecks ++ followupChecks ++ precedenceChecks

-- BEGIN PROOFS

end DefiKernel.Atomic.Tests


===== INPUT lean/DefiKernel/Atomic/Verify.lean ORIGINAL_SHA256 f933cff484cbc18d92c463acb717c24f9f82ce960cf3c210a97448abe8548cf4 RENDERED_SHA256 f933cff484cbc18d92c463acb717c24f9f82ce960cf3c210a97448abe8548cf4 =====
import DefiKernel.Atomic.Audit
import DefiKernel.Atomic.PolicyProofs
import DefiKernel.Atomic.Admission
import DefiKernel.Atomic.Soundness
import DefiKernel.Atomic.Completion
import DefiKernel.Atomic.Settlement
import DefiKernel.Atomic.Preservation
import DefiKernel.Atomic.Correspondence
import DefiKernel.Atomic.InvariantFixtures
import DefiKernel.AxiomAudit

/-! Enumerate every imported Atomic theorem and supplemental declaration by actual module
provenance. Runtime comparisons remain distinct from universal proofs and finite instances. -/
#audit_axioms DefiKernel.Atomic


===== INPUT lean/DefiKernel/AxiomAudit.lean ORIGINAL_SHA256 4a8e330d42e7cd1c46df96ee201923ba2f5d17f37a74b2cb262c318193e72524 RENDERED_SHA256 4a8e330d42e7cd1c46df96ee201923ba2f5d17f37a74b2cb262c318193e72524 =====
import Lean.Elab.Command
import Lean.Util.CollectAxioms

/-!
Audit theorem constants and supplemental definitions, opaque constants, and axioms in
imported modules whose names extend a given module prefix.
Discovery uses elaborated constant kinds and module provenance, never declaration source text.
Files outside the import closure and declarations in the current module are outside this scope.
-/

namespace DefiKernel.AxiomAudit

open Lean Elab Command

/-- The only permitted transitive axioms for the pilot's inspected declarations. -/
def allowedAxioms : Array Name := #[``propext, ``Classical.choice, ``Quot.sound]

/-- Discover all imported theorem constants with module provenance under `modulePrefix`. -/
def importedTheorems (env : Environment) (modulePrefix : Name) : Array (Name × Name) :=
  (env.constants.fold (init := #[]) fun found name info =>
    match info with
    | .thmInfo _ =>
      match env.getModuleIdxFor? name with
      | some idx =>
        let moduleName := env.header.moduleNames[idx.toNat]!
        if modulePrefix.isPrefixOf moduleName then found.push (name, moduleName) else found
      | none => found
    | _ => found).qsort fun a b => Name.lt a.1 b.1

/-- Discover imported definitions, opaque constants, and axioms under `modulePrefix`. -/
def importedSupplemental (env : Environment) (modulePrefix : Name) : Array (Name × Name × String) :=
  (env.constants.fold (init := #[]) fun found name info =>
    let kind := match info with
      | .defnInfo _ => "definition"
      | .opaqueInfo _ => "opaque"
      | .axiomInfo _ => "axiom"
      | _ => "other"
    if kind == "other" then found else
    match env.getModuleIdxFor? name with
    | some idx =>
      let moduleName := env.header.moduleNames[idx.toNat]!
      if modulePrefix.isPrefixOf moduleName then found.push (name, moduleName, kind) else found
    | none => found).qsort fun a b => Name.lt a.1 b.1

/--
Report every discovered theorem with its module and exact transitive axiom set.
Also inspect definitions, opaque constants, and axiom declarations, even if no theorem uses them.
Reject empty imported theorem scope and every dependency outside the standard allowlist.
For example, `#audit_axioms DefiKernel` audits loaded `DefiKernel.*` modules.
-/
elab "#audit_axioms " modulePrefix:ident : command => do
  let scopePrefix := modulePrefix.getId
  let env ← getEnv
  let modules := env.header.moduleNames.filter (scopePrefix.isPrefixOf ·)
  let theorems := importedTheorems env scopePrefix
  logInfo m!"AXIOM AUDIT scope: imported module prefix {scopePrefix}; modules={modules}"
  if theorems.isEmpty then
    throwError "AXIOM AUDIT BLOCKED: empty theorem scope for imported module prefix {scopePrefix}; theorems=0"
  let mut rejected : Nat := 0
  for (name, moduleName) in theorems do
    let axioms ← collectAxioms name
    logInfo m!"AXIOM AUDIT theorem: {name}; module={moduleName}; axioms={axioms}"
    let forbidden := axioms.filter fun ax => !allowedAxioms.contains ax
    unless forbidden.isEmpty do
      rejected := rejected + 1
      logError m!"AXIOM AUDIT FORBIDDEN: {name}; axioms={forbidden}"
  let supplemental := importedSupplemental env scopePrefix
  let mut supplementalRejected : Nat := 0
  for (name, moduleName, kind) in supplemental do
    let axioms ← collectAxioms name
    logInfo m!"AXIOM AUDIT declaration: {name}; module={moduleName}; kind={kind}; axioms={axioms}"
    let forbidden := axioms.filter fun ax => !allowedAxioms.contains ax
    unless forbidden.isEmpty do
      supplementalRejected := supplementalRejected + 1
      logError m!"AXIOM AUDIT DECLARATION FORBIDDEN: {name}; kind={kind}; axioms={forbidden}"
  if rejected > 0 then
    throwError "AXIOM AUDIT FAILED: {rejected}/{theorems.size} theorems use forbidden axioms"
  if supplementalRejected > 0 then
    throwError (m!"AXIOM AUDIT DECLARATIONS FAILED: {supplementalRejected}/{supplemental.size} " ++
      m!"supplemental declarations use forbidden axioms")
  if supplemental.isEmpty then
    logInfo "AXIOM AUDIT DECLARATIONS: supplemental declarations=0; theorem audit remains required"
  else
    logInfo <| m!"AXIOM AUDIT DECLARATIONS PASSED: {supplemental.size}/{supplemental.size} " ++
      m!"supplemental declarations; forbidden=0"
  logInfo m!"AXIOM AUDIT PASSED: {theorems.size}/{theorems.size} theorems; forbidden=0"

end DefiKernel.AxiomAudit


===== INPUT lean/DefiKernel/Composition/Contracts.lean ORIGINAL_SHA256 d23885a9bc2ed695ef8569b97c47c9f07449a5a6aa98bc86c8797dce648fc46c RENDERED_SHA256 d23885a9bc2ed695ef8569b97c47c9f07449a5a6aa98bc86c8797dce648fc46c =====
import DefiKernel.Typed.Transition

/-! Proof-level contracts and ledger support. These predicates are not executable certificates;
initialization, environment truth, and local guarantees require separate proof premises. -/
namespace DefiKernel.Composition

open Typed

abbrev World (Party Asset Domain : Type) := ExecutionResult Party Asset Domain

/-- Semantic obligations are separate from finite interface validation. -/
structure ComponentContract (Party Asset Domain Boundary : Type) where
  initial : World Party Asset Domain → Prop
  assumes : Boundary → World Party Asset Domain → Prop
  invariant : World Party Asset Domain → Prop
  guarantees : Boundary → World Party Asset Domain → World Party Asset Domain → Prop

variable {Party Asset Domain Boundary : Type}

/-- Initialization and the inductive rule must actually be proved by a contract instance. -/
structure ContractObligations
    (contract : ComponentContract Party Asset Domain Boundary) : Prop where
  initialized : ∀ w, contract.initial w → contract.invariant w
  preserved : ∀ b pre post, contract.invariant pre → contract.assumes b pre →
    contract.guarantees b pre post → contract.invariant post

def Initial (contracts : List (ComponentContract Party Asset Domain Boundary))
    (world : World Party Asset Domain) : Prop :=
  ∀ contract ∈ contracts, contract.initial world

def AgreeOn (region : Set (Cell Party Asset Domain))
    (pre post : State Party Asset Domain) : Prop :=
  ∀ cell ∈ region, pre.balance cell = post.balance cell

/-- Only ledger predicates are framed; this definition does not cover capability-store reads. -/
def Supports (region : Set (Cell Party Asset Domain))
    (predicate : State Party Asset Domain → Prop) : Prop :=
  ∀ pre post, AgreeOn region pre post → (predicate pre ↔ predicate post)

-- BEGIN PROOFS

theorem AgreeOn.refl (region : Set (Cell Party Asset Domain))
    (state : State Party Asset Domain) : AgreeOn region state state := by
  intro cell hc
  rfl

theorem AgreeOn.symm {region : Set (Cell Party Asset Domain)}
    {s t : State Party Asset Domain} (h : AgreeOn region s t) : AgreeOn region t s := by
  intro cell hc
  exact (h cell hc).symm

theorem AgreeOn.trans {region : Set (Cell Party Asset Domain)}
    {s t u : State Party Asset Domain} (hst : AgreeOn region s t)
    (htu : AgreeOn region t u) : AgreeOn region s u := by
  intro cell hc
  exact (hst cell hc).trans (htu cell hc)

theorem supported_frame {region : Set (Cell Party Asset Domain)}
    {predicate : State Party Asset Domain → Prop} (support : Supports region predicate)
    {pre post : State Party Asset Domain} (unchanged : AgreeOn region pre post) :
    predicate pre ↔ predicate post := support pre post unchanged

theorem supports_balance (cell : Cell Party Asset Domain) (predicate : ℚ → Prop) :
    Supports {cell} (fun state ↦ predicate (state.balance cell)) := by
  intro pre post h
  change predicate (pre.balance cell) ↔ predicate (post.balance cell)
  rw [h cell (Set.mem_singleton cell)]

theorem initialized_invariants
    (contracts : List (ComponentContract Party Asset Domain Boundary))
    (obligations : ∀ c ∈ contracts, ContractObligations c)
    (world : World Party Asset Domain) (initial : Initial contracts world) :
    ∀ c ∈ contracts, c.invariant world := by
  intro c hc
  exact (obligations c hc).initialized world (initial c hc)

end DefiKernel.Composition


===== INPUT lean/DefiKernel/Composition/Examples.lean ORIGINAL_SHA256 55fb655e93cc6fa8ec676da466112bc763f8f7e81e71cb8acedf98ffd7b73064 RENDERED_SHA256 55fb655e93cc6fa8ec676da466112bc763f8f7e81e71cb8acedf98ffd7b73064 =====
import DefiKernel.Composition.Preservation
import DefiKernel.Typed.Examples
namespace DefiKernel.Composition.Examples
open Typed Typed.Examples
abbrev C := Cell Party Asset Domain
abbrev W := World Party Asset Domain
abbrev S := Step Party Asset Domain
def aliceUsd : C := (.main, .alice, .usd)
def bobUsd : C := (.main, .bob, .usd)
def vaultUsd : C := (.main, .vault, .usd)
def aliceShare : C := (.main, .alice, .share)
def collateral : C := (.main, .alice, .collateral)
def transferInterface : OperationInterface Party Asset Domain :=
  ⟨transferId, [⟨⟨0⟩, .amount .usd⟩], [⟨⟨1⟩, aliceUsd⟩]⟩
def depositInterface : OperationInterface Party Asset Domain :=
  ⟨depositId, [⟨⟨2⟩, .amount .usd⟩], [⟨⟨3⟩, aliceShare⟩, ⟨⟨4⟩, aliceUsd⟩]⟩
def withdrawInterface : OperationInterface Party Asset Domain :=
  ⟨withdrawId, [⟨⟨5⟩, .amount .share⟩], [⟨⟨6⟩, aliceUsd⟩]⟩
def catalog : Catalog Party Asset Domain := [
  ⟨⟨0⟩, [bobUsd], [⟨⟨10⟩, aliceUsd, true⟩], [], [transferInterface]⟩,
  ⟨⟨1⟩, [vaultUsd, aliceShare], [], [⟨⟨⟨0⟩, ⟨10⟩⟩, aliceUsd, true⟩],
    [depositInterface, withdrawInterface]⟩,
  ⟨⟨2⟩, [collateral], [], [], []⟩]
def cfg : Config Party Asset Domain := ⟨registry, domainAdmin, catalog⟩
def boundary (_ : Nat) : Boundary Party Asset Domain := ⟨aliceContext, fresh, 100⟩
/-- Independent table: no call to administrative execution. -/
def expectedStore : Store := ⟨[
  ⟨⟨.alice, .main, ⟨0⟩, .invoke⟩, true⟩,
  ⟨⟨.alice, .main, ⟨0⟩, .debit aliceUsd⟩, true⟩,
  ⟨⟨.alice, .main, ⟨1⟩, .invoke⟩, true⟩,
  ⟨⟨.alice, .main, ⟨1⟩, .debit aliceUsd⟩, true⟩,
  ⟨⟨.alice, .main, ⟨1⟩, .changeSupply .main .share⟩, true⟩,
  ⟨⟨.alice, .main, ⟨2⟩, .invoke⟩, true⟩,
  ⟨⟨.alice, .main, ⟨2⟩, .debit vaultUsd⟩, true⟩,
  ⟨⟨.alice, .main, ⟨2⟩, .debit aliceShare⟩, true⟩,
  ⟨⟨.alice, .main, ⟨2⟩, .changeSupply .main .share⟩, true⟩,
  ⟨⟨.alice, .main, ⟨3⟩, .invoke⟩, true⟩,
  ⟨⟨.alice, .main, ⟨3⟩, .debit (.main, .pool, .usd)⟩, true⟩,
  ⟨⟨.alice, .main, ⟨3⟩, .changeSupply .main .debt⟩, true⟩]⟩
def initialWorld : W := ⟨initial, expectedStore⟩
def transferStep (q : ℚ) : S := .invoke
  ⟨⟨0⟩, transferId, [.bob], [.literal ⟨.amount .usd, q⟩], allCapabilityIds, none⟩
def depositSource (source : InputSource Asset) : S := .invoke
  ⟨⟨1⟩, depositId, [], [source], allCapabilityIds, none⟩
def depositStep (q : ℚ) : S := depositSource (.literal ⟨.amount .usd, q⟩)
def withdrawStep (q : ℚ) : S := .invoke
  ⟨⟨1⟩, withdrawId, [], [.literal ⟨.amount .share, q⟩], allCapabilityIds, none⟩
def routedDeposit (index : Nat := 0) : S := depositSource (.priorOutput index ⟨⟨0⟩, ⟨1⟩⟩)
def workflow : List S := [transferStep 3, depositStep 4, withdrawStep 2]
/-- Boundary truth is an explicit premise, independent of structural validation. -/
def collateralContract : ComponentContract Party Asset Domain ℚ where
  initial w := w.state.balance collateral = 10
  assumes price _ := 1 ≤ price
  invariant w := 10 ≤ w.state.balance collateral
  guarantees price pre post := price * pre.state.balance collateral ≤ post.state.balance collateral
/-- Concrete post-transfer ledger for the support counterexample. -/
def transferred : Ledger where
  balance c := if c = aliceUsd then 7 else if c = bobUsd then 3 else initial.balance c
  nonneg c := by
    split
    · decide
    · split
      · decide
      · exact initial.nonneg c
def boundaryContract : ComponentContract Party Asset Domain (Boundary Party Asset Domain) where
  initial := collateralContract.initial
  assumes b _ := b.now = 100
  invariant := collateralContract.invariant
  guarantees _ pre post := pre.state.balance collateral ≤ post.state.balance collateral
-- BEGIN PROOFS
theorem collateralContract_obligations : ContractObligations collateralContract := by
  constructor
  · intro w h
    exact le_of_eq h.symm
  · intro price pre post hi ha hg
    change 10 ≤ post.state.balance collateral
    change 10 ≤ pre.state.balance collateral at hi
    change 1 ≤ price at ha
    change price * pre.state.balance collateral ≤ post.state.balance collateral at hg
    have hm : pre.state.balance collateral ≤ price * pre.state.balance collateral := by
      simpa using mul_le_mul_of_nonneg_right ha (pre.state.nonneg collateral)
    exact hi.trans (hm.trans hg)
theorem collateral_initialized : collateralContract.initial initialWorld := by rfl
theorem collateral_supported : Supports {collateral}
    (fun s : Ledger ↦ 10 ≤ s.balance collateral) := supports_balance collateral _
theorem unsupported_predicate_counterexample :
    ¬ Supports {collateral} (fun s : Ledger ↦ s.balance aliceUsd = 10) := by
  intro h
  have agree : AgreeOn {collateral} initial transferred := by
    intro cell hc
    have he : cell = collateral := hc
    subst cell
    rfl
  have bad := (h initial transferred agree).mp (show initial.balance aliceUsd = 10 from rfl)
  change (7 : ℚ) = 10 at bad
  exact (by decide : (7 : ℚ) ≠ 10) bad

theorem dropping_disjointness_counterexample :
    Supports {aliceUsd} (fun s : Ledger ↦ s.balance aliceUsd = 10) ∧
    initial.balance aliceUsd = 10 ∧ transferred.balance aliceUsd ≠ 10 := by
  exact ⟨supports_balance aliceUsd (fun q ↦ q = 10), rfl, by decide⟩

theorem workflow_accounting (d : Domain) (a : Asset) :
    total (Composition.run cfg boundary initialWorld workflow).world.state d a =
    total initialWorld.state d a +
      traceSupply (Composition.run cfg boundary initialWorld workflow).events d a :=
  run_accounting cfg boundary initialWorld workflow d a

theorem refused_mint_prefix_accounting (d : Domain) (a : Asset) :
    total (Composition.run cfg boundary initialWorld
      [depositStep 4, transferStep 8]).world.state d a =
    total initialWorld.state d a +
      traceSupply (Composition.run cfg boundary initialWorld
        [depositStep 4, transferStep 8]).events d a :=
  run_accounting cfg boundary initialWorld [depositStep 4,transferStep 8] d a

theorem workflow_nonnegative (c : C) :
    0 ≤ (Composition.run cfg boundary initialWorld workflow).world.state.balance c :=
  run_nonnegative cfg boundary initialWorld workflow c

set_option maxRecDepth 10000 in
set_option maxHeartbeats 2000000 in
-- Kernel reduction expands the complete finite workflow, including authority and footprint checks.
theorem workflow_protected_writes :
    collateral ∉ traceWrites (Composition.run cfg boundary initialWorld workflow).events := by
  decide +kernel

theorem workflow_collateral_frame :
    (10 ≤ initialWorld.state.balance collateral) ↔
    10 ≤ (Composition.run cfg boundary initialWorld workflow).world.state.balance collateral := by
  apply run_frame cfg boundary initialWorld workflow {collateral}
    (fun s ↦ 10 ≤ s.balance collateral) collateral_supported
  intro cell member
  have eq : cell = collateral := member
  subst cell
  exact workflow_protected_writes

theorem boundaryContract_obligations : ContractObligations boundaryContract :=
  ⟨collateralContract_obligations.initialized,
    fun _ _ _ hi _ hg ↦ hi.trans hg⟩

theorem workflow_conditional_invariant
    (localGuarantee : ∀ n outputs step pre result,
      StepSound cfg (boundary n) n outputs step pre result →
      boundaryContract.invariant pre → boundaryContract.assumes (boundary n) pre ∧
        boundaryContract.guarantees (boundary n) pre result.world) :
    boundaryContract.invariant (Composition.run cfg boundary initialWorld workflow).world :=
  run_contract cfg boundary initialWorld workflow boundaryContract boundaryContract_obligations
    collateral_initialized localGuarantee

end DefiKernel.Composition.Examples


===== INPUT lean/DefiKernel/Composition/Interfaces.lean ORIGINAL_SHA256 4f2a32854b298ca5399eb0aa38bb16e892312517ae4f3a0e49e4bfead369f5fe RENDERED_SHA256 4f2a32854b298ca5399eb0aa38bb16e892312517ae4f3a0e49e4bfead369f5fe =====
import DefiKernel.Typed.Transition

/-! Finite component declarations, concrete access checks and immutable value snapshots.
Catalog validation is structural; it does not discharge semantic contracts or kernel authority. -/
namespace DefiKernel.Composition
open Typed

structure ComponentId where
  value : Nat
  deriving DecidableEq, Repr

structure PortId where
  value : Nat
  deriving DecidableEq, Repr

structure QualifiedPort where
  component : ComponentId
  port : PortId
  deriving DecidableEq, Repr

structure InputPort (Asset : Type) where
  id : PortId
  unit : Typed.Unit Asset
  deriving DecidableEq, Repr

structure OutputPort (Party Asset Domain : Type) where
  id : PortId
  cell : Cell Party Asset Domain
  deriving DecidableEq, Repr

structure ResourcePort (Party Asset Domain : Type) where
  id : PortId
  cell : Cell Party Asset Domain
  writable : Bool
  deriving DecidableEq, Repr

structure ResourceImport (Party Asset Domain : Type) where
  source : QualifiedPort
  cell : Cell Party Asset Domain
  writable : Bool
  deriving DecidableEq, Repr

structure OperationInterface (Party Asset Domain : Type) where
  operation : OperationId
  inputs : List (InputPort Asset)
  outputs : List (OutputPort Party Asset Domain)
  deriving DecidableEq, Repr

structure Component (Party Asset Domain : Type) where
  id : ComponentId
  privateCells : List (Cell Party Asset Domain)
  exports : List (ResourcePort Party Asset Domain)
  imports : List (ResourceImport Party Asset Domain)
  operations : List (OperationInterface Party Asset Domain)
  deriving DecidableEq, Repr

abbrev Catalog (Party Asset Domain : Type) := List (Component Party Asset Domain)

inductive InterfaceFailure where
  | unknownOperation
  | resolution (reason : EvalFailure)
  | readAccess
  | writeAccess
  | inputCount
  | inputUnit
  | unavailableOutput
  deriving DecidableEq, Repr

inductive InputSource (Asset : Type) where
  | literal (value : PackedValue Asset)
  | priorOutput (step : Nat) (port : QualifiedPort)

structure OutputObservation (Asset : Type) where
  step : Nat
  port : QualifiedPort
  value : PackedValue Asset

variable {Party Asset Domain : Type}
variable [DecidableEq Party] [DecidableEq Asset] [DecidableEq Domain]

def Component.canRead (component : Component Party Asset Domain)
    (cell : Cell Party Asset Domain) : Bool :=
  decide (cell ∈ component.privateCells) ||
    component.exports.any (fun p ↦ decide (p.cell = cell)) ||
    component.imports.any (fun p ↦ decide (p.cell = cell))

def Component.canWrite (component : Component Party Asset Domain)
    (cell : Cell Party Asset Domain) : Bool :=
  decide (cell ∈ component.privateCells) ||
    component.exports.any (fun p ↦ decide (p.cell = cell) && p.writable) ||
    component.imports.any (fun p ↦ decide (p.cell = cell) && p.writable)

def lookupOperation (catalog : Catalog Party Asset Domain) (componentId : ComponentId)
    (operationId : OperationId) :
    Option (Component Party Asset Domain × OperationInterface Party Asset Domain) := do
  let component ← catalog.find? (fun c ↦ decide (c.id = componentId))
  let interface ← component.operations.find? (fun i ↦ decide (i.operation = operationId))
  return (component, interface)

def Component.portIds (component : Component Party Asset Domain) : List PortId :=
  component.exports.map ResourcePort.id ++ component.operations.flatMap
    (fun i ↦ i.inputs.map InputPort.id ++ i.outputs.map OutputPort.id)

/-- Private ownership excludes all shared ports, including the owner's own exports.
An import may reduce write access, but cannot grant more rights than its exact export. -/
def validateCatalog (registry : Registry Party Asset Domain)
    (catalog : Catalog Party Asset Domain) : Bool :=
  decide ((catalog.map Component.id).Nodup) &&
  decide ((catalog.flatMap (fun c ↦ c.operations.map OperationInterface.operation)).Nodup) &&
  decide ((catalog.flatMap Component.privateCells).Nodup) &&
  decide ((catalog.flatMap (fun c ↦ c.exports.map ResourcePort.cell)).Nodup) &&
  catalog.all (fun c ↦
    decide (c.portIds.Nodup) && decide ((c.imports.map ResourceImport.source).Nodup) &&
    c.exports.all (fun p ↦
      !(catalog.any (fun owner ↦ decide (p.cell ∈ owner.privateCells)))) &&
    c.imports.all (fun p ↦
      !(c.exports.any (fun e ↦ decide (e.cell = p.cell))) &&
      !(catalog.any (fun owner ↦ decide (p.cell ∈ owner.privateCells))) &&
      catalog.any (fun source ↦ decide (source.id = p.source.component) &&
        source.exports.any (fun e ↦ decide (e.id = p.source.port) &&
          decide (e.cell = p.cell) && (!p.writable || e.writable)))) &&
    c.operations.all (fun i ↦
      (match registry i.operation with
       | none => false
       | some template => decide (i.inputs.map InputPort.unit = template.signature) &&
         i.outputs.all (fun o ↦ decide (o.cell.1 = template.domain))) &&
      i.outputs.all (fun o ↦ c.canRead o.cell)))

/-- Resolve references without evaluating financial expressions. Both expression branches,
supply/guard reads, declared reads, declared writes and every delta target are checked. -/
def checkAccess (component : Component Party Asset Domain)
    (template : Template Party Asset Domain) (ctx : InvocationContext Party Domain)
    (parties : List Party) : Except InterfaceFailure PUnit := do
  let reads ← (resolveRefs ctx.principal parties
    (template.requiredStateReads ++ template.stateReads)).mapError .resolution
  let writes ← (resolveRefs ctx.principal parties
    (template.writes ++ template.deltas.map (fun d ↦ ⟨d.asset, d.target⟩))).mapError .resolution
  if !(reads.all component.canRead) then throw .readAccess
  if !(writes.all component.canWrite) then throw .writeAccess
  return ⟨⟩

/-- Earlier absolute positions are necessary even if an untrusted history contains a future key.
The runner additionally ensures history contains only actual successful snapshots. -/
def resolveSource (index : Nat) (history : List (OutputObservation Asset)) :
    InputSource Asset → Except InterfaceFailure (PackedValue Asset)
  | .literal value => .ok value
  | .priorOutput step port =>
    if step < index then
      match history.find? (fun o ↦ decide (o.step = step ∧ o.port = port)) with
      | some output => .ok output.value
      | none => .error .unavailableOutput
    else .error .unavailableOutput

def resolveInputs (index : Nat) (history : List (OutputObservation Asset))
    (interface : OperationInterface Party Asset Domain) (sources : List (InputSource Asset)) :
    Except InterfaceFailure (List (PackedValue Asset)) := do
  if sources.length != interface.inputs.length then throw .inputCount
  let values ← sources.mapM (resolveSource index history)
  if values.map Sigma.fst != interface.inputs.map InputPort.unit then throw .inputUnit
  return values

/-- Output units are intrinsic to the selected cell and balances are copied after commitment. -/
def snapshots (index : Nat) (component : ComponentId)
    (interface : OperationInterface Party Asset Domain) (state : State Party Asset Domain) :
    List (OutputObservation Asset) :=
  interface.outputs.map (fun o ↦
    ⟨index, ⟨component, o.id⟩, ⟨.amount o.cell.2.2, state.balance o.cell⟩⟩)

-- BEGIN PROOFS

/-- Successful prechecks resolve the complete conservative reference inventories and
accept every concrete read and write; no financial expression evaluation is assumed. -/
theorem checkAccess_ok_iff (component : Component Party Asset Domain)
    (template : Template Party Asset Domain) (ctx : InvocationContext Party Domain)
    (parties : List Party) :
    checkAccess component template ctx parties = .ok PUnit.unit ↔
      ∃ reads writes,
        resolveRefs ctx.principal parties
          (template.requiredStateReads ++ template.stateReads) = .ok reads ∧
        resolveRefs ctx.principal parties
          (template.writes ++ template.deltas.map (fun d ↦ ⟨d.asset, d.target⟩)) = .ok writes ∧
        reads.all component.canRead = true ∧ writes.all component.canWrite = true := by
  unfold checkAccess
  cases hr : resolveRefs ctx.principal parties
    (template.requiredStateReads ++ template.stateReads) with
  | error e => simp [Except.mapError, bind, Except.bind]
  | ok reads =>
    cases hw : resolveRefs ctx.principal parties
      (template.writes ++ template.deltas.map (fun d ↦ ⟨d.asset, d.target⟩)) with
    | error e => simp [Except.mapError, bind, Except.bind]
    | ok writes =>
      simp only [Except.mapError, bind, Except.bind]
      by_cases r : reads.all component.canRead = true <;>
        by_cases w : writes.all component.canWrite = true <;>
        simp [r, w, -List.all_eq_true, throw, throwThe, pure, Except.pure]


/-- In particular every resolved declared write accepted by the precheck is writable. -/
theorem checkAccess_declaredWrites (component : Component Party Asset Domain)
    (template : Template Party Asset Domain) (ctx : InvocationContext Party Domain)
    (parties : List Party) (writes : List (Cell Party Asset Domain))
    (accepted : checkAccess component template ctx parties = .ok PUnit.unit)
    (resolved : resolveRefs ctx.principal parties template.writes = .ok writes) :
    writes.all component.canWrite = true := by
  obtain ⟨reads, allWrites, _, hw, _, allowed⟩ :=
    (checkAccess_ok_iff component template ctx parties).mp accepted
  simp only [resolveRefs, List.mapM_append] at hw
  change (template.writes.mapM (fun ref ↦ ref.2.resolve ctx.principal parties)) =
    .ok writes at resolved
  rw [resolved] at hw
  cases ht : (template.deltas.map
      (fun d ↦ (⟨d.asset, d.target⟩ : PackedCellRef Party Asset Domain))).mapM
      (fun ref ↦ ref.2.resolve ctx.principal parties) with
  | error e => simp [ht, bind, Except.bind] at hw
  | ok targets =>
    simp only [ht, bind, Except.bind, pure, Except.pure, Except.ok.injEq] at hw
    subst allWrites
    simp only [List.all_append, Bool.and_eq_true] at allowed
    exact allowed.1

/-- A validated catalog keeps every export away from every private owner. -/
theorem validateCatalog_export_not_private (registry : Registry Party Asset Domain)
    (catalog : Catalog Party Asset Domain) (valid : validateCatalog registry catalog = true)
    (component owner : Component Party Asset Domain) (hc : component ∈ catalog)
    (ho : owner ∈ catalog) (port : ResourcePort Party Asset Domain)
    (hp : port ∈ component.exports) : port.cell ∉ owner.privateCells := by
  simp only [validateCatalog, Bool.and_eq_true] at valid
  have componentValid := List.all_eq_true.mp valid.2 component hc
  simp only [Bool.and_eq_true] at componentValid
  have exportValid := List.all_eq_true.mp componentValid.1.1.2 port hp
  simpa using (show ¬port.cell ∈ owner.privateCells from by
    intro h
    have : catalog.any (fun c ↦ decide (port.cell ∈ c.privateCells)) = true :=
      List.any_eq_true.mpr ⟨owner, ho, by simpa using h⟩
    simp [this] at exportValid)

omit [DecidableEq Party] [DecidableEq Asset] [DecidableEq Domain] in
theorem snapshots_length (index : Nat) (component : ComponentId)
    (interface : OperationInterface Party Asset Domain) (state : State Party Asset Domain) :
    (snapshots index component interface state).length = interface.outputs.length := by
  simp [snapshots]

omit [DecidableEq Party] [DecidableEq Asset] [DecidableEq Domain] in
theorem snapshot_of_selected (index : Nat) (component : ComponentId)
    (interface : OperationInterface Party Asset Domain) (state : State Party Asset Domain)
    (output : OutputPort Party Asset Domain) (h : output ∈ interface.outputs) :
    (⟨index, ⟨component, output.id⟩,
      ⟨.amount output.cell.2.2, state.balance output.cell⟩⟩ : OutputObservation Asset) ∈
      snapshots index component interface state := by
  exact List.mem_map.mpr ⟨output, h, rfl⟩

omit [DecidableEq Asset] in
theorem resolveSource_literal (index : Nat) (history : List (OutputObservation Asset))
    (value : PackedValue Asset) : resolveSource index history (.literal value) = .ok value := rfl

omit [DecidableEq Asset] in
theorem resolveSource_not_prior (index step : Nat) (history : List (OutputObservation Asset))
    (port : QualifiedPort) (h : ¬step < index) :
    resolveSource index history (.priorOutput step port) = .error .unavailableOutput := by
  simp [resolveSource, h]

end DefiKernel.Composition


===== INPUT lean/DefiKernel/Composition/Preservation.lean ORIGINAL_SHA256 7b881b25fc71f93751ea8f3f64f3bc2d0ffcdd94b4abb7091ba19dd6b21f3709 RENDERED_SHA256 7b881b25fc71f93751ea8f3f64f3bc2d0ffcdd94b4abb7091ba19dd6b21f3709 =====
import DefiKernel.Composition.Sequence

/-! Induction over actual successful prefixes. Supply is taken from evaluated receipts;
framing requires explicit ledger support, and invariant reasoning requires local premises. -/
namespace DefiKernel.Composition
open Typed

variable {P A D : Type} [DecidableEq P] [DecidableEq A] [DecidableEq D]
variable [Fintype P] [Fintype A] [Fintype D]

def traceSupply (events : List (Event P A D)) (domain : D) (asset : A) : ℚ :=
  (events.map (fun event ↦ event.result.receipt.supply domain asset)).sum

def traceWrites (events : List (Event P A D)) : List (Cell P A D) :=
  events.flatMap (fun event ↦ event.result.receipt.writes)

-- BEGIN PROOFS

theorem TraceSound.accounting {cfg : Config P A D} {boundaries : Nat → Boundary P A D}
    {initial final : World P A D} {events : List (Event P A D)}
    {history : List (OutputObservation A)} {index : Nat}
    (h : TraceSound cfg boundaries initial events final history index) (d : D) (a : A) :
    total final.state d a = total initial.state d a + traceSupply events d a := by
  induction h with
  | nil => simp [traceSupply]
  | snoc previous step result accepted ih =>
    rw [accepted.accounting, ih]
    simp [traceSupply, List.map_append, List.sum_append, add_assoc]

theorem TraceSound.locality {cfg : Config P A D} {boundaries : Nat → Boundary P A D}
    {initial final : World P A D} {events : List (Event P A D)}
    {history : List (OutputObservation A)} {index : Nat}
    (h : TraceSound cfg boundaries initial events final history index)
    (cell : Cell P A D) (untouched : cell ∉ traceWrites events) :
    final.state.balance cell = initial.state.balance cell := by
  induction h with
  | nil => rfl
  | snoc previous step result accepted ih =>
    simp only [traceWrites, List.flatMap_append, List.flatMap_singleton, List.mem_append,
      not_or] at untouched
    exact (accepted.locality cell untouched.2).trans (ih untouched.1)

theorem TraceSound.steps {cfg : Config P A D} {boundaries : Nat → Boundary P A D}
    {initial final : World P A D} {events : List (Event P A D)}
    {history : List (OutputObservation A)} {index : Nat}
    (h : TraceSound cfg boundaries initial events final history index) :
    ∀ event ∈ events, ∃ priorOutputs,
      StepSound cfg (boundaries event.index) event.index priorOutputs
        event.step event.before event.result := by
  induction h with
  | nil => simp
  | snoc previous step result accepted ih =>
    intro event member
    simp only [List.mem_append, List.mem_singleton] at member
    rcases member with member | rfl
    · exact ih event member
    · exact ⟨_, accepted⟩

theorem TraceSound.authority {cfg : Config P A D} {boundaries : Nat → Boundary P A D}
    {initial final : World P A D} {events : List (Event P A D)}
    {history : List (OutputObservation A)} {index : Nat}
    (h : TraceSound cfg boundaries initial events final history index) :
    ∀ event ∈ events,
      ReceiptAuthorized event.before (boundaries event.index) event.result.receipt := by
  intro event member
  obtain ⟨prior, accepted⟩ := h.steps event member
  exact accepted.authorized

theorem TraceSound.component_locality {cfg : Config P A D}
    {boundaries : Nat → Boundary P A D} {initial final : World P A D}
    {events : List (Event P A D)} {history : List (OutputObservation A)} {index : Nat}
    (h : TraceSound cfg boundaries initial events final history index) :
    ∀ event ∈ events, ∀ inv, event.step = .invoke inv →
      ∃ component iface, lookupOperation cfg.catalog inv.component inv.operation =
        some (component, iface) ∧ ∀ cell, component.canWrite cell = false →
          event.result.world.state.balance cell = event.before.state.balance cell := by
  intro event member inv he
  obtain ⟨prior, accepted⟩ := h.steps event member
  rw [he] at accepted
  exact accepted.component_locality

/-- Administrative authorization is separate from invocation receipt rights. -/
theorem TraceSound.administration {cfg : Config P A D} {boundaries : Nat → Boundary P A D}
    {initial final : World P A D} {events : List (Event P A D)}
    {history : List (OutputObservation A)} {index : Nat}
    (h : TraceSound cfg boundaries initial events final history index) :
    ∀ event ∈ events, match event.step with
    | .invoke _ => True
    | .issue grant => (boundaries event.index).ctx.domain = grant.domain ∧
        (boundaries event.index).ctx.principal = cfg.domainAdmin grant.domain
    | .revoke id => ∃ cap, event.before.capabilities.lookup id = some cap ∧
        (boundaries event.index).ctx.domain = cap.domain ∧
        (boundaries event.index).ctx.principal = cfg.domainAdmin cap.domain := by
  intro event member
  obtain ⟨prior, accepted⟩ := h.steps event member
  cases he : event.step with
  | invoke inv => trivial
  | issue grant =>
    rw [he] at accepted
    exact accepted.issue_admin
  | revoke id =>
    rw [he] at accepted
    exact accepted.revoke_admin

theorem TraceSound.invariant {cfg : Config P A D} {boundaries : Nat → Boundary P A D}
    {initial final : World P A D} {events : List (Event P A D)}
    {history : List (OutputObservation A)} {index : Nat}
    (h : TraceSound cfg boundaries initial events final history index)
    (invariant : World P A D → Prop) (initialized : invariant initial)
    (preserves : ∀ n outputs step pre result,
      StepSound cfg (boundaries n) n outputs step pre result →
      invariant pre → invariant result.world) :
    invariant final := by
  induction h with
  | nil => exact initialized
  | snoc previous step result accepted ih => exact preserves _ _ _ _ _ accepted ih

theorem TraceSound.event_invariants {cfg : Config P A D} {boundaries : Nat → Boundary P A D}
    {initial final : World P A D} {events : List (Event P A D)}
    {history : List (OutputObservation A)} {index : Nat}
    (h : TraceSound cfg boundaries initial events final history index)
    (invariant : World P A D → Prop) (initialized : invariant initial)
    (preserves : ∀ n outputs step pre result,
      StepSound cfg (boundaries n) n outputs step pre result →
      invariant pre → invariant result.world) :
    ∀ event ∈ events, invariant event.before ∧ invariant event.result.world := by
  induction h with
  | nil => simp
  | snoc previous step result accepted ih =>
    intro event member
    simp only [List.mem_append, List.mem_singleton] at member
    rcases member with member | rfl
    · exact ih event member
    · have hp := previous.invariant invariant initialized preserves
      exact ⟨hp, preserves _ _ _ _ _ accepted hp⟩

theorem TraceSound.frame {cfg : Config P A D} {boundaries : Nat → Boundary P A D}
    {initial final : World P A D} {events : List (Event P A D)}
    {history : List (OutputObservation A)} {index : Nat}
    (h : TraceSound cfg boundaries initial events final history index)
    (region : Set (Cell P A D)) (untouched : ∀ cell ∈ region, cell ∉ traceWrites events) :
    AgreeOn region initial.state final.state := by
  intro cell member
  exact (h.locality cell (untouched cell member)).symm

theorem TraceSound.predicate_frame {cfg : Config P A D} {boundaries : Nat → Boundary P A D}
    {initial final : World P A D} {events : List (Event P A D)}
    {history : List (OutputObservation A)} {index : Nat}
    (h : TraceSound cfg boundaries initial events final history index)
    (region : Set (Cell P A D)) (predicate : State P A D → Prop)
    (support : Supports region predicate) (untouched : ∀ cell ∈ region, cell ∉ traceWrites events) :
    predicate initial.state ↔ predicate final.state :=
  supported_frame support (h.frame region untouched)

theorem run_accounting (cfg : Config P A D) (boundaries : Nat → Boundary P A D)
    (initial : World P A D) (steps : List (Step P A D)) (d : D) (a : A) :
    total (run cfg boundaries initial steps).world.state d a =
      total initial.state d a + traceSupply (run cfg boundaries initial steps).events d a :=
  (run_trace_sound cfg boundaries initial steps).accounting d a

theorem run_nonnegative (cfg : Config P A D) (boundaries : Nat → Boundary P A D)
    (initial : World P A D) (steps : List (Step P A D)) (cell : Cell P A D) :
    0 ≤ (run cfg boundaries initial steps).world.state.balance cell :=
  (run cfg boundaries initial steps).world.state.nonneg cell

theorem run_prefix_nonnegative (cfg : Config P A D) (boundaries : Nat → Boundary P A D)
    (initial : World P A D) (steps : List (Step P A D)) :
    ∀ event ∈ (run cfg boundaries initial steps).events, ∀ cell,
      0 ≤ event.before.state.balance cell ∧ 0 ≤ event.result.world.state.balance cell := by
  intro event member cell
  exact ⟨event.before.state.nonneg cell, event.result.world.state.nonneg cell⟩

theorem run_frame (cfg : Config P A D) (boundaries : Nat → Boundary P A D)
    (initial : World P A D) (steps : List (Step P A D))
    (region : Set (Cell P A D)) (predicate : State P A D → Prop)
    (support : Supports region predicate)
    (untouched : ∀ cell ∈ region, cell ∉ traceWrites (run cfg boundaries initial steps).events) :
    predicate initial.state ↔ predicate (run cfg boundaries initial steps).world.state :=
  (run_trace_sound cfg boundaries initial steps).predicate_frame region predicate support untouched

theorem run_contract (cfg : Config P A D) (boundaries : Nat → Boundary P A D)
    (initial : World P A D) (steps : List (Step P A D))
    (contract : ComponentContract P A D (Boundary P A D))
    (obligations : ContractObligations contract) (initialized : contract.initial initial)
    (localGuarantee : ∀ n outputs step pre result,
      StepSound cfg (boundaries n) n outputs step pre result →
      contract.invariant pre → contract.assumes (boundaries n) pre ∧
        contract.guarantees (boundaries n) pre result.world) :
    contract.invariant (run cfg boundaries initial steps).world := by
  apply (run_trace_sound cfg boundaries initial steps).invariant contract.invariant
    (obligations.initialized initial initialized)
  intro n outputs step pre result accepted inv
  obtain ⟨assumes, guarantees⟩ := localGuarantee n outputs step pre result accepted inv
  exact obligations.preserved (boundaries n) pre result.world inv assumes guarantees

end DefiKernel.Composition


===== INPUT lean/DefiKernel/Interleaving/Completion.lean ORIGINAL_SHA256 5b3974e55b1893af07a967319f6f3ef680c9e15ed59bd06508817be756382321 RENDERED_SHA256 5b3974e55b1893af07a967319f6f3ef680c9e15ed59bd06508817be756382321 =====
import DefiKernel.Interleaving.Trace

/-! Public refusal and complete-schedule outcome laws. Admission refusals contain the exact
reason, unchanged initial world and supplied schedule; their constructor has no attempts or
outputs. The canonical comparator intentionally ignores the supplied schedule even for refused
results. It compares their exact reasons and full worlds instead; raw Result equality retains
that schedule. Complete active branches exhaust their invocations; failed branches retain the
exact failure recorded by the actual trace. -/
namespace DefiKernel.Interleaving
open Typed Composition Parallel

variable {P A D : Type} [DecidableEq P] [DecidableEq A] [DecidableEq D]
variable [Fintype P] [Fintype A] [Fintype D]

-- BEGIN PROOFS

/-- A preflight refusal returns the unchanged initial world without an execution payload. -/
theorem runInterleaving_admission_refusal (cfg : Config P A D)
    (boundaries : ParallelBoundary P A D) (initial : World P A D)
    (left right : Branch P A D) (schedule : Schedule)
    (reason : DefiKernel.Interleaving.AdmissionFailure P A D)
    (h : DefiKernel.Interleaving.admit cfg boundaries left right schedule = .error reason) :
    runInterleaving cfg boundaries initial left right schedule =
      .refused reason initial schedule := by
  simp only [runInterleaving, h]

/-- Every active branch of a complete schedule has successfully exhausted its static slots. -/
theorem runPrefix_complete_active_exhaustion (cfg : Config P A D)
    (boundaries : ParallelBoundary P A D) (initial : World P A D)
    (left right : Branch P A D) (schedule : Schedule) (complete : Complete left right schedule)
    (b : BranchId)
    (active : ((runPrefix cfg boundaries initial left right schedule).local b).failure = none) :
    ((runPrefix cfg boundaries initial left right schedule).local b).nextIndex =
      (selectBranch left right b).length := by
  have h := (runPrefix_reachable cfg boundaries initial left right schedule).active_index b active
  rw [runPrefix_consumed] at h
  cases b <;> simpa only [selectBranch, complete.1, complete.2, Nat.min_self] using h

/-- Every branch is either exhausted without failure or retains its exact located refusal. -/
theorem runPrefix_complete_exhausted_or_refused (cfg : Config P A D)
    (boundaries : ParallelBoundary P A D) (initial : World P A D)
    (left right : Branch P A D) (schedule : Schedule) (complete : Complete left right schedule)
    (b : BranchId) :
    (((runPrefix cfg boundaries initial left right schedule).local b).failure = none ∧
      ((runPrefix cfg boundaries initial left right schedule).local b).nextIndex =
        (selectBranch left right b).length) ∨
    ∃ failure,
      ((runPrefix cfg boundaries initial left right schedule).local b).failure = some failure ∧
      failure.index =
        ((runPrefix cfg boundaries initial left right schedule).local b).nextIndex := by
  cases h : ((runPrefix cfg boundaries initial left right schedule).local b).failure with
  | none => exact .inl ⟨rfl,
      runPrefix_complete_active_exhaustion cfg boundaries initial left right schedule complete b h⟩
  | some failure => exact .inr ⟨failure, rfl,
      (runPrefix_reachable cfg boundaries initial left right schedule).failure_index b failure h⟩

end DefiKernel.Interleaving


===== INPUT lean/DefiKernel/Interleaving/Examples.lean ORIGINAL_SHA256 944421f563bdb3b81a6cf102e72f36396b1cd193b7a1be47b4ced18baff8bb8b RENDERED_SHA256 944421f563bdb3b81a6cf102e72f36396b1cd193b7a1be47b4ced18baff8bb8b =====
import DefiKernel.Interleaving.Execution
import DefiKernel.Parallel.Examples

/-! Exact rational development fixtures. Expected ledgers, receipts and outputs are direct tables;
none is extracted from `runInterleaving`. These fixtures make no deployed-protocol fidelity claim.
-/
namespace DefiKernel.Interleaving.Examples
open Typed Composition Parallel Typed.Examples Parallel.Examples

abbrev R := Interleaving.Result Party Asset Domain
abbrev M := Machine Party Asset Domain

def matchesExpected (actual : R) (balance : C → ℚ) (left right : Obs)
    (consumedLeft consumedRight : Nat) (expectedStore : Store := store) : Bool :=
  match actual with
  | .refused _ _ _ => false
  | .executed _ m => decide ((∀ c, m.world.state.balance c = balance c) ∧
      m.world.capabilities = expectedStore ∧ m.left.observe = left ∧ m.right.observe = right ∧
      m.left.consumed = consumedLeft ∧ m.right.consumed = consumedRight)

def admissionRefused (actual : R) (reason : Interleaving.AdmissionFailure Party Asset Domain)
    (schedule : Schedule) (expected : W := initial) : Bool :=
  match actual with
  | .refused r w s => decide (r = reason ∧ s = schedule) && worldEq w expected
  | .executed _ _ => false

def sharedBalance (alice bob vault : ℚ) : C → ℚ := fun c ↦
  if c = aliceUSD then alice else if c = bobUSD then bob else if c = vaultUSD then vault
  else if c = protectedCell then 9 else 0

def sharedInitial : W := ⟨⟨sharedBalance 0 0 10, by
  intro c
  simp only [sharedBalance]
  repeat' split
  all_goals decide⟩, store⟩
def sharedCfg := config (transferTemplate .usd (.literal .vault) (.literal .alice))
  (transferTemplate .usd (.literal .vault) (.literal .bob)) [aliceUSD] [bobUSD]
def sharedLeft : B := [usd 7]
def sharedRight : B := [peerUSD 6]
def sharedLR := runInterleaving sharedCfg boundaries sharedInitial sharedLeft sharedRight
  [.left, .right]
def sharedRL := runInterleaving sharedCfg boundaries sharedInitial sharedLeft sharedRight
  [.right, .left]
def withdrawalLeft := observed [transferEvent 0 (usd 7) vaultUSD aliceUSD 7 [output 0 0 .usd 7]]
def withdrawalRight := observed
  [transferEvent 0 (peerUSD 6) vaultUSD bobUSD 6 [output 0 1 .usd 6]]

def replenishInitial : W := ⟨⟨sharedBalance 10 0 0, by
  intro c
  simp only [sharedBalance]
  repeat' split
  all_goals decide⟩, store⟩
def replenishCfg := config (transferTemplate .usd (.literal .alice) (.literal .vault))
  (transferTemplate .usd (.literal .vault) (.literal .bob)) [vaultUSD] [bobUSD]
def depositExpected := observed [transferEvent 0 (usd 7) aliceUSD vaultUSD 7 [output 0 0 .usd 7]]
def replenishLR := runInterleaving replenishCfg boundaries replenishInitial [usd 7]
  [peerUSD 6, peerUSD 1] [.left, .right, .right]
def replenishRL := runInterleaving replenishCfg boundaries replenishInitial [usd 7]
  [peerUSD 6, peerUSD 1] [.right, .left, .right]

/-- Both branches invoke component 0, so the fully qualified output key is identical. -/
def snapshotCfg := config usdTransfer shareTransfer [bobUSD] [aliceShare]
def snapshotConsumer := source (usd 0) 0
def snapshotRun := runInterleaving snapshotCfg boundaries initial
  [usd 3, snapshotConsumer] [usd 1] [.left, .right, .left]
def snapshotLeft := observed [leftEvent 0 3 3,
  transferEvent 1 snapshotConsumer aliceUSD bobUSD 3 [output 1 0 .usd 7]]
def snapshotRight := observed [leftEvent 0 1 4]

/-- The peer transfers four dollars into Alice's balance between the two live reads. -/
def liveCfg := config statefulTransfer
  (transferTemplate .usd (.literal .vault) (.literal .alice)) [bobUSD] [aliceUSD]
def liveRun := runInterleaving liveCfg boundaries initial [usd 0, usd 0] [peerUSD 4]
  [.left, .right, .left]
def liveLeft := observed [statefulEvent 0 5 5, statefulEvent 1 (9 / 2) (19 / 2)]
def liveRight := observed [transferEvent 0 (peerUSD 4) vaultUSD aliceUSD 4 [output 0 1 .usd 9]]

def peerOnly := source (usd 0) 1
def peerOnlyRun := runInterleaving sameAssetCfg boundaries initial [usd 3, peerOnly]
  [peerUSD 4] [.left, .right, .left]
def peerOnlyLeft := observed [leftEvent 0 3 3]
  (failure 1 peerOnly (.interface .unavailableOutput))
def peerOnlyRight := observed [peerEvent 0 4 5]

def immediateRun := runInterleaving cfg boundaries initial [usd 11, usd 1]
  [shares 4, shares 2] [.left, .right, .left, .right]
def middleRun := runInterleaving cfg boundaries initial [usd 3, usd 8, usd 1]
  [shares 4, shares 2] [.left, .right, .left, .right, .left]
def dualRun := runInterleaving cfg boundaries initial [usd 3, usd 8, usd 1]
  [shares 4, shares 17, shares 1] [.left, .right, .left, .right, .left, .right]
def middleLeft := observed [leftEvent 0 3 3]
  (failure 1 (usd 8) (.kernel .insufficientFunds))
def continuedRight := observed [rightEvent 0 4 4, rightEvent 1 2 6]

def supplyRun := runInterleaving supplyCfg boundaries initial [usd 2, usd (-13), usd 1]
  [shares (-3)] [.left, .right, .left, .left]
def supplyLeft := observed [supplyEvent 0 (usd 2) aliceUSD 2 12]
  (failure 1 (usd (-13)) (.kernel .insufficientFunds))
def supplyRight := observed [supplyEvent 0 (shares (-3)) vaultShare (-3) 17]

def schedules : List (String × Schedule) := [
  ("llrr", [.left, .left, .right, .right]), ("lrlr", [.left, .right, .left, .right]),
  ("lrrl", [.left, .right, .right, .left]), ("rllr", [.right, .left, .left, .right]),
  ("rlrl", [.right, .left, .right, .left]), ("rrll", [.right, .right, .left, .left])]
def disjointLeft : B := [usd 3, usd 2]
def disjointRight : B := [shares 4, shares 2]
def disjointLeftExpected := observed [leftEvent 0 3 3, leftEvent 1 2 5]

/-- Directly supplied attempt oracles include all pre/post cells and the entire capability store. -/
structure ExpectedAttempt where
  branch : BranchId
  index : Nat
  invocation : I
  before : C → ℚ
  after : C → ℚ
  outcome : Except Composition.Failure Evt

def attemptMatches (actual : Attempt Party Asset Domain) (expected : ExpectedAttempt) : Bool :=
  decide (actual.branch = expected.branch ∧ actual.index = expected.index ∧
    actual.invocation = expected.invocation ∧
    (∀ c, actual.before.state.balance c = expected.before c) ∧
    actual.before.capabilities = store) &&
  match actual.outcome, expected.outcome with
  | .error actualReason, .error expectedReason => decide (actualReason = expectedReason)
  | .ok result, .ok event => decide
      ((∀ c, result.world.state.balance c = expected.after c) ∧
        result.world.capabilities = store ∧ result.receipt = event.receipt ∧
        result.outputs = event.outputs)
  | _, _ => false

def attemptsMatch (actual : R) (expected : List ExpectedAttempt) : Bool :=
  match actual with
  | .refused _ _ _ => false
  | .executed _ m => m.attempts.length == expected.length &&
      (m.attempts.zip expected).all fun (a, e) ↦ attemptMatches a e

def sharedLRAttempts : List ExpectedAttempt := [
  ⟨.left, 0, usd 7, sharedBalance 0 0 10, sharedBalance 7 0 3,
    .ok (transferEvent 0 (usd 7) vaultUSD aliceUSD 7 [output 0 0 .usd 7])⟩,
  ⟨.right, 0, peerUSD 6, sharedBalance 7 0 3, sharedBalance 7 0 3,
    .error (.kernel .insufficientFunds)⟩]
def replenishRLAttempts : List ExpectedAttempt := [
  ⟨.right, 0, peerUSD 6, sharedBalance 10 0 0, sharedBalance 10 0 0,
    .error (.kernel .insufficientFunds)⟩,
  ⟨.left, 0, usd 7, sharedBalance 10 0 0, sharedBalance 3 0 7,
    .ok (transferEvent 0 (usd 7) aliceUSD vaultUSD 7 [output 0 0 .usd 7])⟩]

end DefiKernel.Interleaving.Examples


===== INPUT lean/DefiKernel/Interleaving/Execution.lean ORIGINAL_SHA256 8a39ccbaf6cf03479a5b16a156c52a2b6f5bd97a9198b633be27be3b1b899d21 RENDERED_SHA256 8a39ccbaf6cf03479a5b16a156c52a2b6f5bd97a9198b633be27be3b1b899d21 =====
import DefiKernel.Interleaving.Schedule
import DefiKernel.Parallel.Observation
import DefiKernel.Parallel.Execution

/-! Finite replay over one evolving world. Local histories and permanent refusals stay separate;
consumed static slots advance even when a failed suffix produces no further attempt. -/
namespace DefiKernel.Interleaving
open Typed Composition Parallel

structure LocalState (P A D : Type) where
  consumed : Nat := 0
  events : List (Event P A D) := []
  outputs : List (OutputObservation A) := []
  nextIndex : Nat := 0
  failure : Option (LocatedFailure P A D) := none

structure Attempt (P A D : Type) where
  branch : BranchId
  index : Nat
  invocation : Invocation P A D
  before : World P A D
  outcome : Except Composition.Failure (StepResult P A D)

structure Machine (P A D : Type) where
  world : World P A D
  left : LocalState P A D := {}
  right : LocalState P A D := {}
  attempts : List (Attempt P A D) := []

inductive Result (P A D : Type) where
  | refused (reason : Interleaving.AdmissionFailure P A D) (world : World P A D)
      (schedule : Schedule)
  | executed (schedule : Schedule) (machine : Machine P A D)

variable {P A D : Type} [DecidableEq P] [DecidableEq A] [DecidableEq D]

def Machine.local (m : Machine P A D) : BranchId → LocalState P A D
  | .left => m.left
  | .right => m.right

def Machine.setLocal (m : Machine P A D) (b : BranchId)
    (localState : LocalState P A D) : Machine P A D :=
  match b with
  | .left => { m with left := localState }
  | .right => { m with right := localState }

def selectBranch (left right : Branch P A D) : BranchId → Branch P A D
  | .left => left
  | .right => right

def start (initial : World P A D) : Machine P A D := ⟨initial, {}, {}, []⟩

/-- The new public projection owns every preserved field, including exact located failure. -/
def LocalState.observe (localState : LocalState P A D) : BranchObservation P A D :=
  ⟨localState.events.map observeEvent, localState.outputs,
    localState.nextIndex, localState.failure⟩

def LocalState.toCursor (localState : LocalState P A D) (world : World P A D) : Cursor P A D :=
  ⟨world, localState.events, localState.outputs, localState.nextIndex, localState.failure⟩

def Attempt.supply (attempt : Attempt P A D) (d : D) (a : A) : ℚ :=
  match attempt.outcome with
  | .error _ => 0
  | .ok result => result.receipt.supply d a

/-- Executable aggregation of actual successful attempts; refusals contribute zero. -/
def Machine.supply (m : Machine P A D) (d : D) (a : A) : ℚ :=
  (m.attempts.map (fun attempt ↦ attempt.supply d a)).sum

def Attempt.writes (attempt : Attempt P A D) : List (Cell P A D) :=
  match attempt.outcome with
  | .error _ => []
  | .ok result => result.receipt.writes

def Machine.writes (m : Machine P A D) : List (Cell P A D) :=
  m.attempts.flatMap Attempt.writes

def Machine.skip (m : Machine P A D) (b : BranchId) : Machine P A D :=
  m.setLocal b { m.local b with consumed := (m.local b).consumed + 1 }

def Machine.refuse (m : Machine P A D) (b : BranchId) (inv : Invocation P A D)
    (reason : Composition.Failure) : Machine P A D :=
  let own := m.local b
  let stopped : LocalState P A D := { own with
    consumed := own.consumed + 1
    failure := some ⟨own.nextIndex, some (.invoke inv), reason⟩ }
  let updated := m.setLocal b stopped
  { updated with attempts := m.attempts ++
      [⟨b, own.nextIndex, inv, m.world, .error reason⟩] }

def Machine.accept (m : Machine P A D) (b : BranchId) (inv : Invocation P A D)
    (result : StepResult P A D) : Machine P A D :=
  let own := m.local b
  let advanced : LocalState P A D := ⟨own.consumed + 1,
    own.events ++ [⟨own.nextIndex, .invoke inv, m.world, result⟩],
    own.outputs ++ result.outputs, own.nextIndex + 1, none⟩
  let updated := m.setLocal b advanced
  { updated with world := result.world, attempts := m.attempts ++
      [⟨b, own.nextIndex, inv, m.world, .ok result⟩] }

variable [Fintype P] [Fintype A] [Fintype D]

/-- Advance exactly one static branch slot, preserving the peer's local state. -/
def advance (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (left right : Branch P A D) (m : Machine P A D) (b : BranchId) : Machine P A D :=
  let own := m.local b
  match own.failure with
  | some _ => m.skip b
  | none =>
    match (selectBranch left right b)[own.consumed]? with
    | none => m.skip b
    | some inv =>
      let outcome := executeStep cfg (boundaries b own.nextIndex) own.nextIndex own.outputs
        (.invoke inv) m.world
      match outcome with
      | .error reason => m.refuse b inv reason
      | .ok result => m.accept b inv result

def continueRun (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (left right : Branch P A D) (m : Machine P A D) (schedule : Schedule) : Machine P A D :=
  schedule.foldl (advance cfg boundaries left right) m

def runPrefix (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (initial : World P A D) (left right : Branch P A D) (schedule : Schedule) : Machine P A D :=
  continueRun cfg boundaries left right (start initial) schedule

def runInterleaving (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (initial : World P A D) (left right : Branch P A D) (schedule : Schedule) :
    Interleaving.Result P A D :=
  match Interleaving.admit cfg boundaries left right schedule with
  | .error reason => .refused reason initial schedule
  | .ok _ => .executed schedule (runPrefix cfg boundaries initial left right schedule)

/-- Exact financial fields, without raw foreign event worlds or global scheduling order. -/
def ProjectedEquivalent (m : Machine P A D) (joined : Parallel.Joined P A D) : Prop :=
  Parallel.WorldEquivalent m.world joined.world ∧
    m.left.observe = observeBranch joined.left ∧ m.right.observe = observeBranch joined.right

def observationsEqual (left right : Interleaving.Result P A D) : Bool :=
  match left, right with
  | .refused lr lw _, .refused rr rw _ => decide (lr = rr) && Parallel.worldEq lw rw
  | .executed _ l, .executed _ r => Parallel.worldEq l.world r.world &&
      decide (l.left.observe = r.left.observe) && decide (l.right.observe = r.right.observe)
  | _, _ => false

def matchesParallel (result : Interleaving.Result P A D) (parallel : Parallel.Result P A D) :
    Bool :=
  match result, parallel with
  | .executed _ m, .executed joined => Parallel.worldEq m.world joined.world &&
      decide (m.left.observe = observeBranch joined.left) &&
      decide (m.right.observe = observeBranch joined.right)
  | _, _ => false

-- BEGIN PROOFS

omit [DecidableEq P] [DecidableEq A] [DecidableEq D] [Fintype P] [Fintype A] [Fintype D] in
theorem local_setLocal (m : Machine P A D) (b : BranchId) (l : LocalState P A D) :
    (m.setLocal b l).local b = l := by cases b <;> rfl

omit [DecidableEq P] [DecidableEq A] [DecidableEq D] [Fintype P] [Fintype A] [Fintype D] in
theorem setLocal_world (m : Machine P A D) (b : BranchId) (l : LocalState P A D) :
    (m.setLocal b l).world = m.world := by cases b <;> rfl

omit [DecidableEq P] [DecidableEq A] [DecidableEq D] [Fintype P] [Fintype A] [Fintype D] in
theorem observe_toCursor (l : LocalState P A D) (w : World P A D) :
    observeBranch (l.toCursor w) = l.observe := rfl

theorem continueRun_append (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (left right : Branch P A D) (m : Machine P A D) (s t : Schedule) :
    continueRun cfg boundaries left right m (s ++ t) =
      continueRun cfg boundaries left right (continueRun cfg boundaries left right m s) t :=
  List.foldl_append

theorem matchesParallel_iff (schedule : Schedule) (m : Machine P A D)
    (joined : Parallel.Joined P A D) :
    matchesParallel (.executed schedule m) (.executed joined) = true ↔
      ProjectedEquivalent m joined := by
  simp [matchesParallel, ProjectedEquivalent, Parallel.worldEq, Parallel.WorldEquivalent, and_assoc]

end DefiKernel.Interleaving


===== INPUT lean/DefiKernel/Interleaving/Interference.lean ORIGINAL_SHA256 e6bc0a1ffbceebb27973d547f2d3b808bc15d6c857e03644c9fa5eeb54ecef90 RENDERED_SHA256 e6bc0a1ffbceebb27973d547f2d3b808bc15d6c857e03644c9fa5eeb54ecef90 =====
import DefiKernel.Interleaving.LocalOrder

/-! Initialized rely/guarantee reasoning over actual shared-world executions. Local obligations
quantify over arbitrary histories and worlds; they never assume the peer invariant or run result. -/
namespace DefiKernel.Interleaving
open Typed Composition Parallel

abbrev LedgerPredicate (P A D : Type) := State P A D → Prop
abbrev LedgerRelation (P A D : Type) := State P A D → State P A D → Prop

variable {P A D : Type} [DecidableEq P] [DecidableEq A] [DecidableEq D]
variable [Fintype P] [Fintype A] [Fintype D]

/-- Each branch proves its own invariant and guarantee from its own invariant alone. -/
def LocalObligation (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (left right : Branch P A D) (invariant : BranchId → LedgerPredicate P A D)
    (guarantee : BranchId → LedgerRelation P A D) : Prop :=
  ∀ b index inv, (selectBranch left right b)[index]? = some inv →
    ∀ history pre result, invariant b pre.state →
      StepSound cfg (boundaries b index) index history (.invoke inv) pre result →
      invariant b result.world.state ∧ guarantee b pre.state result.world.state

def CrossInclusion (guarantee rely : BranchId → LedgerRelation P A D) : Prop :=
  ∀ b peer, b ≠ peer → ∀ pre post, guarantee b pre post → rely peer pre post

def Stable (invariant : BranchId → LedgerPredicate P A D)
    (rely : BranchId → LedgerRelation P A D) : Prop :=
  ∀ b pre post, invariant b pre → rely b pre post → invariant b post

-- BEGIN PROOFS

theorem Reachable.two_invariants {cfg : Config P A D}
    {boundaries : ParallelBoundary P A D} {left right : Branch P A D}
    {initial : World P A D} {m : Machine P A D}
    (h : Reachable cfg boundaries left right initial m)
    (invariant : BranchId → LedgerPredicate P A D)
    (guarantee rely : BranchId → LedgerRelation P A D)
    (initialized : ∀ b, invariant b initial.state)
    (localObligation : LocalObligation cfg boundaries left right invariant guarantee)
    (cross : CrossInclusion guarantee rely) (stable : Stable invariant rely) :
    ∀ b, invariant b m.world.state := by
  induction h with
  | start => exact initialized
  | next b previous step ih =>
    cases step with
    | halted => simpa only [skip_world] using ih
    | exhausted => simpa only [skip_world] using ih
    | refused => simpa only [refuse_world] using ih
    | accepted inv result active selected executed =>
      have index := previous.attempt_index b active inv selected
      have selected' : (selectBranch left right b)[_]? = some inv := selected
      rw [← index] at selected'
      have own := localObligation b _ inv selected' _ _ _ (ih b)
        (executeStep_sound _ _ _ _ _ _ _ executed)
      intro other
      change invariant other result.world.state
      by_cases same : b = other
      · subst other
        exact own.1
      · exact stable other _ _ (ih other) (cross b other same _ _ own.2)

theorem runPrefix_two_invariants (cfg : Config P A D)
    (boundaries : ParallelBoundary P A D) (initial : World P A D)
    (left right : Branch P A D) (schedule : Schedule)
    (invariant : BranchId → LedgerPredicate P A D)
    (guarantee rely : BranchId → LedgerRelation P A D)
    (initialized : ∀ b, invariant b initial.state)
    (localObligation : LocalObligation cfg boundaries left right invariant guarantee)
    (cross : CrossInclusion guarantee rely) (stable : Stable invariant rely) :
    ∀ b, invariant b (runPrefix cfg boundaries initial left right schedule).world.state :=
  (runPrefix_reachable cfg boundaries initial left right schedule).two_invariants
    invariant guarantee rely initialized localObligation cross stable

/-- Any supplied finite prefix retains both initialized invariants, including stopped branches. -/
theorem every_prefix_two_invariants (cfg : Config P A D)
    (boundaries : ParallelBoundary P A D) (initial : World P A D)
    (left right : Branch P A D) (schedule : Schedule)
    (invariant : BranchId → LedgerPredicate P A D)
    (guarantee rely : BranchId → LedgerRelation P A D)
    (initialized : ∀ b, invariant b initial.state)
    (localObligation : LocalObligation cfg boundaries left right invariant guarantee)
    (cross : CrossInclusion guarantee rely) (stable : Stable invariant rely) (length : Nat) :
    ∀ b, invariant b
      (runPrefix cfg boundaries initial left right (schedule.take length)).world.state :=
  runPrefix_two_invariants cfg boundaries initial left right (schedule.take length)
    invariant guarantee rely initialized localObligation cross stable

end DefiKernel.Interleaving


===== INPUT lean/DefiKernel/Interleaving/InterferenceFixtures.lean ORIGINAL_SHA256 1a08de17a3632aec84ae079f8b9e8145683c009d22b5217695a788b3c7dcfbd0 RENDERED_SHA256 1a08de17a3632aec84ae079f8b9e8145683c009d22b5217695a788b3c7dcfbd0 =====
import DefiKernel.Interleaving.Interference
import DefiKernel.Interleaving.Preservation
import DefiKernel.Interleaving.Examples
import DefiKernel.Parallel.Preservation

/-! Shared-liquidity development instances and counterexamples. Conservation has a local proof
independent of the invariant antecedent; the generic rely/guarantee rule still exposes it. -/
namespace DefiKernel.Interleaving.InterferenceFixtures
open Typed Composition Parallel Typed.Examples Parallel.Examples Interleaving.Examples

abbrev Ledger := State Party Asset Domain

def dollars (amount : ℚ) (_ : BranchId) (s : Ledger) : Prop := total s .main .usd = amount
def sameDollars (_ : BranchId) (pre post : Ledger) : Prop :=
  total post .main .usd = total pre .main .usd

def leftFP : Footprint Party Asset Domain :=
  ⟨[vaultUSD, aliceUSD, vaultUSD, aliceUSD, aliceUSD], [vaultUSD, aliceUSD, vaultUSD, aliceUSD]⟩
def rightFP : Footprint Party Asset Domain :=
  ⟨[vaultUSD, bobUSD, vaultUSD, bobUSD, bobUSD], [vaultUSD, bobUSD, vaultUSD, bobUSD]⟩
def collateral (s : Ledger) : Prop := s.balance protectedCell = 9

def fragile : BranchId → Ledger → Prop
  | .left, s => s.balance bobUSD = 0
  | .right, s => total s .main .usd = 10

def rightPrefix := runPrefix sharedCfg boundaries sharedInitial sharedLeft sharedRight [.right]
def leftPrefix := runPrefix sharedCfg boundaries sharedInitial sharedLeft sharedRight [.left]

-- BEGIN PROOFS

theorem shared_supply_free : ∀ op template, sharedCfg.registry op = some template →
    template.supplyDeltas = [] := by
  intro op template selected
  change (if op = ⟨10⟩ then some (transferTemplate .usd (.literal .vault) (.literal .alice))
    else if op = ⟨11⟩ then some (transferTemplate .usd (.literal .vault) (.literal .bob))
    else none) = some template at selected
  split_ifs at selected <;> cases selected <;> rfl

/-- The local total relation needs no invariant antecedent or peer assumption. -/
theorem shared_step_total (boundary : Boundary Party Asset Domain) (index : Nat)
    (history : List (OutputObservation Asset)) (inv : I) (pre : W)
    (result : StepResult Party Asset Domain)
    (h : StepSound sharedCfg boundary index history (.invoke inv) pre result) :
    total result.world.state .main .usd = total pre.state .main .usd := by
  rw [h.accounting, step_no_supply shared_supply_free h, add_zero]

theorem shared_local_obligation (amount : ℚ) :
    LocalObligation sharedCfg boundaries sharedLeft sharedRight (dollars amount) sameDollars := by
  intro b index inv _ history pre result initialized step
  have totalEq := shared_step_total _ _ _ _ _ _ step
  exact ⟨totalEq.trans initialized, totalEq⟩

theorem shared_cross : CrossInclusion sameDollars sameDollars := by
  intro b peer _ pre post h
  exact h

theorem shared_stable (amount : ℚ) : Stable (dollars amount) sameDollars := by
  intro b pre post initialized same
  exact same.trans initialized

theorem shared_initialized : ∀ b, dollars 10 b sharedInitial.state := by
  intro b
  change total sharedInitial.state .main .usd = 10
  decide +kernel

theorem shared_every_prefix (schedule : Schedule) (length : Nat) :
    ∀ b, dollars 10 b (runPrefix sharedCfg boundaries sharedInitial
      sharedLeft sharedRight (schedule.take length)).world.state :=
  every_prefix_two_invariants sharedCfg boundaries sharedInitial sharedLeft sharedRight schedule
    (dollars 10) sameDollars sameDollars shared_initialized (shared_local_obligation 10)
    shared_cross (shared_stable 10) length

theorem shared_all_tokens (schedule : Schedule) :
    total (runPrefix sharedCfg boundaries sharedInitial sharedLeft sharedRight schedule).world.state
      .main .usd = 10 :=
  runPrefix_two_invariants sharedCfg boundaries sharedInitial sharedLeft sharedRight schedule
    (dollars 10) sameDollars sameDollars shared_initialized (shared_local_obligation 10)
    shared_cross (shared_stable 10) .left

theorem shared_left_analyzed : analyzeBranch sharedCfg (boundaries .left) sharedLeft =
    .ok leftFP := by decide +kernel

theorem shared_right_analyzed : analyzeBranch sharedCfg (boundaries .right) sharedRight =
    .ok rightFP := by decide +kernel

theorem shared_overlap : vaultUSD ∈ leftFP.writes ∧ vaultUSD ∈ rightFP.writes := by decide

theorem collateral_supported : Supports {protectedCell} collateral :=
  supports_balance protectedCell (· = 9)

theorem protected_collateral_all_tokens (schedule : Schedule) :
    collateral (runPrefix sharedCfg boundaries sharedInitial
      sharedLeft sharedRight schedule).world.state := by
  have frame := (runPrefix_reachable sharedCfg boundaries sharedInitial sharedLeft sharedRight
    schedule).analyzed_predicate_frame leftFP rightFP shared_left_analyzed shared_right_analyzed
    {protectedCell} collateral collateral_supported
  have untouched : ∀ c ∈ ({protectedCell} : Set C), c ∉ leftFP.writes ++ rightFP.writes := by
    intro c member
    have eq := Set.mem_singleton_iff.mp member
    subst c
    decide
  apply (frame untouched).mp
  change sharedInitial.state.balance protectedCell = 9
  decide +kernel

/-- All noninitial premises hold for total USD11, but even the empty prefix has total USD10. -/
theorem missing_initialization_counterexample :
    LocalObligation sharedCfg boundaries sharedLeft sharedRight (dollars 11) sameDollars ∧
    CrossInclusion sameDollars sameDollars ∧ Stable (dollars 11) sameDollars ∧
    ¬ dollars 11 .left
      (runPrefix sharedCfg boundaries sharedInitial sharedLeft sharedRight []).world.state := by
  refine ⟨shared_local_obligation 11, shared_cross, shared_stable 11, ?_⟩
  change total sharedInitial.state .main .usd ≠ 11
  rw [shared_initialized .left]
  decide

/-- StepSound version of the analyzed target frame for local universal obligations. -/
theorem sound_target_frame {cfg : Config Party Asset Domain}
    {boundary : Boundary Party Asset Domain} {index : Nat}
    {history : List (OutputObservation Asset)} {inv : I} {pre : W}
    {result : StepResult Party Asset Domain} (fp : Footprint Party Asset Domain)
    (analyzed : analyzeInvocation cfg boundary inv = .ok fp)
    (h : StepSound cfg boundary index history (.invoke inv) pre result) :
    ∀ c, c ∉ fp.writes → result.world.state.balance c = pre.state.balance c := by
  cases h with
  | invoke inv pre post iface request e prepared executed extracted applied =>
    obtain ⟨op, parties, _⟩ := prepareInvocation_shape _ _ _ _ _ _ _ prepared
    apply execute_target_frame cfg.registry pre.capabilities boundary.ctx boundary.env boundary.now
      request pre.state post {c | c ∈ fp.writes} _ executed
    intro template selected
    rw [op] at selected
    rw [parties]
    exact (analyzed_dependencies _ _ _ _ analyzed template selected).2.1

theorem fragile_local_obligation :
    LocalObligation sharedCfg boundaries sharedLeft sharedRight fragile sameDollars := by
  intro b index inv selected history pre result initialized step
  have totalEq := shared_step_total _ _ _ _ _ _ step
  refine ⟨?_, totalEq⟩
  cases b with
  | right => exact totalEq.trans initialized
  | left =>
    cases index with
    | zero =>
      simp only [selectBranch, sharedLeft, List.getElem?_cons_zero, Option.some.injEq] at selected
      subst inv
      have analyzed : analyzeInvocation sharedCfg (boundaries .left 0) (usd 7) =
          .ok leftFP := by decide +kernel
      exact (sound_target_frame leftFP analyzed step bobUSD (by decide)).trans initialized
    | succ n => simp [selectBranch, sharedLeft] at selected

theorem fragile_initialized : ∀ b, fragile b sharedInitial.state := by
  intro b
  cases b
  · change sharedInitial.state.balance bobUSD = 0
    decide +kernel
  · exact shared_initialized .right

/-- The peer transfers six dollars to Bob while conserving total USD; this breaks Bob=0. -/
theorem missing_peer_stability_counterexample :
    LocalObligation sharedCfg boundaries sharedLeft sharedRight fragile sameDollars ∧
    CrossInclusion sameDollars sameDollars ∧ (∀ b, fragile b sharedInitial.state) ∧
    sameDollars .left sharedInitial.state rightPrefix.world.state ∧
    ¬ fragile .left rightPrefix.world.state := by
  refine ⟨fragile_local_obligation, shared_cross, fragile_initialized, ?_, ?_⟩
  · exact (shared_all_tokens [.right]).trans (shared_initialized .left).symm
  · change rightPrefix.world.state.balance bobUSD ≠ 0
    decide +kernel

theorem fragile_not_stable : ¬ Stable fragile sameDollars := by
  intro stable
  have witness := missing_peer_stability_counterexample
  exact witness.2.2.2.2 (stable .left _ _ (fragile_initialized .left) witness.2.2.2.1)

/-- Empty region agreement alone cannot protect a financial predicate on a written cell. -/
theorem missing_frame_support_counterexample :
    AgreeOn (∅ : Set C) sharedInitial.state leftPrefix.world.state ∧
    sharedInitial.state.balance aliceUSD = 0 ∧ leftPrefix.world.state.balance aliceUSD ≠ 0 := by
  refine ⟨?_, ?_, ?_⟩
  · intro c impossible
    cases impossible
  · decide +kernel
  · decide +kernel

theorem empty_support_is_false :
    ¬ Supports (∅ : Set C) (fun s : Ledger ↦ s.balance aliceUSD = 0) := by
  intro support
  have witness := missing_frame_support_counterexample
  exact witness.2.2 ((support _ _ witness.1).mp witness.2.1)

end DefiKernel.Interleaving.InterferenceFixtures


===== INPUT lean/DefiKernel/Interleaving/LocalOrder.lean ORIGINAL_SHA256 e81054de5ae998516bf0f9a3b9a0ce30ae24a41626b4f3b2c279571f663223be RENDERED_SHA256 e81054de5ae998516bf0f9a3b9a0ce30ae24a41626b4f3b2c279571f663223be =====
import DefiKernel.Interleaving.Soundness

/-! Active local indices count successful static slots. Exhausted internal tokens consume slots
without increasing the successful index; before any real attempt the two indices agree. -/
namespace DefiKernel.Interleaving
open Typed Composition Parallel

variable {P A D : Type} [DecidableEq P] [DecidableEq A] [DecidableEq D]
variable [Fintype P] [Fintype A] [Fintype D]

-- BEGIN PROOFS

theorem AdvanceSound.active_index {cfg : Config P A D}
    {boundaries : ParallelBoundary P A D} {left right : Branch P A D}
    {m post : Machine P A D} {b : BranchId}
    (step : AdvanceSound cfg boundaries left right m b post)
    (previous : ∀ own, (m.local own).failure = none →
      (m.local own).nextIndex = min (m.local own).consumed
        (selectBranch left right own).length) :
    ∀ own, (post.local own).failure = none →
      (post.local own).nextIndex = min (post.local own).consumed
        (selectBranch left right own).length := by
  intro own active
  have hl := previous .left
  have hr := previous .right
  cases step with
  | halted failure failed =>
    cases b <;> cases own <;>
      simp_all [Machine.skip, Machine.setLocal, Machine.local, selectBranch]
  | exhausted oldActive absent =>
    have hb := List.getElem?_eq_none_iff.mp absent
    cases b <;> cases own <;>
      simp_all [Machine.skip, Machine.setLocal, Machine.local, selectBranch] <;> omega
  | refused inv reason oldActive selected rejected =>
    cases b <;> cases own <;>
      simp_all [Machine.refuse, Machine.setLocal, Machine.local, selectBranch]
  | accepted inv result oldActive selected executed =>
    obtain ⟨hb, _⟩ := List.getElem?_eq_some_iff.mp selected
    cases b <;> cases own <;>
      dsimp [Machine.accept, Machine.setLocal, Machine.local, selectBranch] at * <;>
      simp_all <;>
      have hb' := hb <;>
      simp only [Machine.local, selectBranch] at hb' <;> omega

theorem Reachable.active_index {cfg : Config P A D}
    {boundaries : ParallelBoundary P A D} {left right : Branch P A D}
    {initial : World P A D} {m : Machine P A D}
    (h : Reachable cfg boundaries left right initial m) :
    ∀ b, (m.local b).failure = none →
      (m.local b).nextIndex = min (m.local b).consumed (selectBranch left right b).length := by
  induction h with
  | start => intro b; cases b <;> simp [Interleaving.start, Machine.local]
  | next b previous step ih => exact step.active_index ih

theorem Reachable.attempt_index {cfg : Config P A D}
    {boundaries : ParallelBoundary P A D} {left right : Branch P A D}
    {initial : World P A D} {m : Machine P A D}
    (h : Reachable cfg boundaries left right initial m) (b : BranchId)
    (active : (m.local b).failure = none) (inv : Invocation P A D)
    (selected : (selectBranch left right b)[(m.local b).consumed]? = some inv) :
    (m.local b).nextIndex = (m.local b).consumed := by
  obtain ⟨hb, _⟩ := List.getElem?_eq_some_iff.mp selected
  rw [h.active_index b active, min_eq_left (Nat.le_of_lt hb)]

end DefiKernel.Interleaving


===== INPUT lean/DefiKernel/Interleaving/Preservation.lean ORIGINAL_SHA256 21199129e97d64bfcdb75c9a860d2263e069f71f59989299c5f8feca62233b2c RENDERED_SHA256 21199129e97d64bfcdb75c9a860d2263e069f71f59989299c5f8feca62233b2c =====
import DefiKernel.Interleaving.Soundness
import DefiKernel.Interleaving.LocalOrder
import DefiKernel.Composition.Preservation
import DefiKernel.Parallel.Dependency.Adapter

/-! Accounting and locality telescope actual scheduled effects. Authority is checked at each
attempt's real pre-world, with a separate proof that every capability store is the initial one. -/
namespace DefiKernel.Interleaving
open Typed Composition Parallel

variable {P A D : Type} [DecidableEq P] [DecidableEq A] [DecidableEq D]
variable [Fintype P] [Fintype A] [Fintype D]

-- BEGIN PROOFS

theorem AdvanceSound.accounting {cfg : Config P A D} {boundaries : ParallelBoundary P A D}
    {left right : Branch P A D} {m post : Machine P A D} {b : BranchId}
    (h : AdvanceSound cfg boundaries left right m b post) (d : D) (a : A) :
    total post.world.state d a - total m.world.state d a = post.supply d a - m.supply d a := by
  cases h with
  | halted => simp [skip_world, Machine.supply, skip_attempts]
  | exhausted => simp [skip_world, Machine.supply, skip_attempts]
  | refused =>
    simp [Machine.supply, Machine.refuse, Attempt.supply, setLocal_world]
  | accepted inv result active selected executed =>
    have he := (executeStep_sound _ _ _ _ _ _ _ executed).accounting d a
    simp only [Machine.supply, Machine.accept, List.map_append,
      List.map_singleton, List.sum_append, List.sum_singleton, Attempt.supply]
    linarith

theorem Reachable.accounting {cfg : Config P A D} {boundaries : ParallelBoundary P A D}
    {left right : Branch P A D} {initial : World P A D} {m : Machine P A D}
    (h : Reachable cfg boundaries left right initial m) (d : D) (a : A) :
    total m.world.state d a = total initial.state d a + m.supply d a := by
  induction h with
  | start => simp [Interleaving.start, Machine.supply]
  | next b previous step ih =>
    have he := step.accounting d a
    linarith

theorem AdvanceSound.before_stores {cfg : Config P A D}
    {boundaries : ParallelBoundary P A D} {left right : Branch P A D}
    {initial : World P A D} {m post : Machine P A D} {b : BranchId}
    (h : AdvanceSound cfg boundaries left right m b post)
    (store : m.world.capabilities = initial.capabilities)
    (previous : ∀ attempt ∈ m.attempts, attempt.before.capabilities = initial.capabilities) :
    ∀ attempt ∈ post.attempts, attempt.before.capabilities = initial.capabilities := by
  cases h with
  | halted => simpa [skip_attempts] using previous
  | exhausted => simpa [skip_attempts] using previous
  | refused =>
    intro attempt member
    simp only [Machine.refuse, List.mem_append, List.mem_singleton] at member
    rcases member with member | rfl
    · exact previous attempt member
    · exact store
  | accepted =>
    intro attempt member
    simp only [Machine.accept, List.mem_append, List.mem_singleton] at member
    rcases member with member | rfl
    · exact previous attempt member
    · exact store

theorem Reachable.before_stores {cfg : Config P A D} {boundaries : ParallelBoundary P A D}
    {left right : Branch P A D} {initial : World P A D} {m : Machine P A D}
    (h : Reachable cfg boundaries left right initial m) :
    ∀ attempt ∈ m.attempts, attempt.before.capabilities = initial.capabilities := by
  induction h with
  | start => simp [Interleaving.start]
  | next b previous step ih => exact step.before_stores previous.store ih

theorem Reachable.authority {cfg : Config P A D} {boundaries : ParallelBoundary P A D}
    {left right : Branch P A D} {initial : World P A D} {m : Machine P A D}
    (h : Reachable cfg boundaries left right initial m) (attempt : Attempt P A D)
    (member : attempt ∈ m.attempts) (result : StepResult P A D)
    (success : attempt.outcome = .ok result) :
    ReceiptAuthorized attempt.before (boundaries attempt.branch attempt.index) result.receipt := by
  obtain ⟨history, executed⟩ := h.attempts attempt member
  rw [success] at executed
  exact (executeStep_sound _ _ _ _ _ _ _ executed).authorized

theorem Reachable.initial_store_authority {cfg : Config P A D}
    {boundaries : ParallelBoundary P A D} {left right : Branch P A D}
    {initial : World P A D} {m : Machine P A D}
    (h : Reachable cfg boundaries left right initial m) (attempt : Attempt P A D)
    (member : attempt ∈ m.attempts) (result : StepResult P A D)
    (success : attempt.outcome = .ok result) :
    ReceiptAuthorized ⟨attempt.before.state, initial.capabilities⟩
      (boundaries attempt.branch attempt.index) result.receipt := by
  have authorized := h.authority attempt member result success
  have store := h.before_stores attempt member
  cases hr : result.receipt <;> simp_all [ReceiptAuthorized]

theorem AdvanceSound.locality {cfg : Config P A D} {boundaries : ParallelBoundary P A D}
    {left right : Branch P A D} {m post : Machine P A D} {b : BranchId}
    (h : AdvanceSound cfg boundaries left right m b post) (c : Cell P A D)
    (untouched : c ∉ post.writes) :
    post.world.state.balance c = m.world.state.balance c ∧ c ∉ m.writes := by
  cases h with
  | halted => simpa [skip_world, Machine.writes, skip_attempts] using untouched
  | exhausted => simpa [skip_world, Machine.writes, skip_attempts] using untouched
  | refused =>
    simpa [Machine.writes, Machine.refuse, Attempt.writes, setLocal_world] using untouched
  | accepted inv result active selected executed =>
    simp only [Machine.writes, Machine.accept, List.flatMap_append,
      List.flatMap_singleton, Attempt.writes, List.mem_append, not_or] at untouched
    exact ⟨(executeStep_sound _ _ _ _ _ _ _ executed).locality c untouched.2, untouched.1⟩

theorem Reachable.locality {cfg : Config P A D} {boundaries : ParallelBoundary P A D}
    {left right : Branch P A D} {initial : World P A D} {m : Machine P A D}
    (h : Reachable cfg boundaries left right initial m) (c : Cell P A D)
    (untouched : c ∉ m.writes) : m.world.state.balance c = initial.state.balance c := by
  induction h with
  | start => rfl
  | next b previous step ih =>
    obtain ⟨same, old⟩ := step.locality c untouched
    exact same.trans (ih old)

theorem Reachable.frame {cfg : Config P A D} {boundaries : ParallelBoundary P A D}
    {left right : Branch P A D} {initial : World P A D} {m : Machine P A D}
    (h : Reachable cfg boundaries left right initial m) (region : Set (Cell P A D))
    (untouched : ∀ c ∈ region, c ∉ m.writes) : AgreeOn region initial.state m.world.state := by
  intro c member
  exact (h.locality c (untouched c member)).symm

theorem Reachable.predicate_frame {cfg : Config P A D}
    {boundaries : ParallelBoundary P A D} {left right : Branch P A D}
    {initial : World P A D} {m : Machine P A D}
    (h : Reachable cfg boundaries left right initial m) (region : Set (Cell P A D))
    (predicate : State P A D → Prop) (support : Supports region predicate)
    (untouched : ∀ c ∈ region, c ∉ m.writes) :
    predicate initial.state ↔ predicate m.world.state :=
  supported_frame support (h.frame region untouched)

omit [Fintype P] [Fintype A] [Fintype D] in
theorem analyzed_selected (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (left right : Branch P A D) (lf rf : Footprint P A D)
    (hl : analyzeBranch cfg (boundaries .left) left = .ok lf)
    (hr : analyzeBranch cfg (boundaries .right) right = .ok rf)
    (b : BranchId) (n : Nat) (inv : Invocation P A D)
    (selected : (selectBranch left right b)[n]? = some inv) :
    ∃ fp, analyzeInvocation cfg (boundaries b n) inv = .ok fp ∧
      ∀ c ∈ fp.writes, c ∈ lf.writes ++ rf.writes := by
  cases b with
  | left =>
    obtain ⟨fp, hf, _, hw⟩ := analyzeBranchFrom_member cfg (boundaries .left)
      0 left lf hl n inv selected
    exact ⟨fp, by simpa using hf, fun c hc ↦ List.mem_append_left _ (hw c hc)⟩
  | right =>
    obtain ⟨fp, hf, _, hw⟩ := analyzeBranchFrom_member cfg (boundaries .right)
      0 right rf hr n inv selected
    exact ⟨fp, by simpa using hf, fun c hc ↦ List.mem_append_right _ (hw c hc)⟩

theorem Reachable.analyzed_locality {cfg : Config P A D}
    {boundaries : ParallelBoundary P A D} {left right : Branch P A D}
    {initial : World P A D} {m : Machine P A D}
    (h : Reachable cfg boundaries left right initial m) (lf rf : Footprint P A D)
    (hl : analyzeBranch cfg (boundaries .left) left = .ok lf)
    (hr : analyzeBranch cfg (boundaries .right) right = .ok rf)
    (c : Cell P A D) (untouched : c ∉ lf.writes ++ rf.writes) :
    m.world.state.balance c = initial.state.balance c := by
  induction h with
  | start => rfl
  | @next pre post b previous step ih =>
    cases step with
    | halted => simpa [skip_world] using ih
    | exhausted => simpa [skip_world] using ih
    | refused => simpa [refuse_world] using ih
    | accepted inv result active selected executed =>
      have hi := previous.attempt_index b active inv selected
      obtain ⟨fp, hf, hw⟩ := analyzed_selected cfg boundaries left right lf rf hl hr
        b (pre.local b).consumed inv selected
      rw [← hi] at hf
      have framed := (executeStep_target_frame cfg (boundaries b (pre.local b).nextIndex)
        (pre.local b).nextIndex (pre.local b).outputs inv pre.world result fp hf executed).1
      exact (framed c (fun hc ↦ untouched (hw c hc))).trans ih

theorem Reachable.analyzed_predicate_frame {cfg : Config P A D}
    {boundaries : ParallelBoundary P A D} {left right : Branch P A D}
    {initial : World P A D} {m : Machine P A D}
    (h : Reachable cfg boundaries left right initial m) (lf rf : Footprint P A D)
    (hl : analyzeBranch cfg (boundaries .left) left = .ok lf)
    (hr : analyzeBranch cfg (boundaries .right) right = .ok rf)
    (region : Set (Cell P A D)) (predicate : State P A D → Prop)
    (support : Supports region predicate)
    (untouched : ∀ c ∈ region, c ∉ lf.writes ++ rf.writes) :
    predicate initial.state ↔ predicate m.world.state := by
  apply supported_frame support
  intro c hc
  exact (h.analyzed_locality lf rf hl hr c (untouched c hc)).symm

theorem runPrefix_accounting (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (initial : World P A D) (left right : Branch P A D) (schedule : Schedule) (d : D) (a : A) :
    total (runPrefix cfg boundaries initial left right schedule).world.state d a =
      total initial.state d a + (runPrefix cfg boundaries initial left right schedule).supply d a :=
  (runPrefix_reachable cfg boundaries initial left right schedule).accounting d a

theorem runPrefix_store (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (initial : World P A D) (left right : Branch P A D) (schedule : Schedule) :
    (runPrefix cfg boundaries initial left right schedule).world.capabilities =
      initial.capabilities :=
  (runPrefix_reachable cfg boundaries initial left right schedule).store

theorem runPrefix_nonnegative (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (initial : World P A D) (left right : Branch P A D) (schedule : Schedule) (c : Cell P A D) :
    0 ≤ (runPrefix cfg boundaries initial left right schedule).world.state.balance c :=
  (runPrefix cfg boundaries initial left right schedule).world.state.nonneg c

theorem runPrefix_frame (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (initial : World P A D) (left right : Branch P A D) (schedule : Schedule)
    (region : Set (Cell P A D)) (predicate : State P A D → Prop)
    (support : Supports region predicate)
    (untouched : ∀ c ∈ region,
      c ∉ (runPrefix cfg boundaries initial left right schedule).writes) :
    predicate initial.state ↔
      predicate (runPrefix cfg boundaries initial left right schedule).world.state :=
  (runPrefix_reachable cfg boundaries initial left right schedule).predicate_frame
    region predicate support untouched

end DefiKernel.Interleaving


===== INPUT lean/DefiKernel/Interleaving/Schedule.lean ORIGINAL_SHA256 a531621726138ef20d1b45edf8c680869a4e35bee4697cfc93d80c250e2b6ad9 RENDERED_SHA256 a531621726138ef20d1b45edf8c680869a4e35bee4697cfc93d80c250e2b6ad9 =====
import DefiKernel.Parallel.Compatibility

/-! Complete finite schedules and ordered structural admission. Overlapping footprints are
admitted here; compatibility remains a separate premise for disjoint recovery. -/
namespace DefiKernel.Interleaving
open Typed Composition Parallel

abbrev Schedule := List BranchId

structure ScheduleMismatch where
  expectedLeft : Nat
  observedLeft : Nat
  expectedRight : Nat
  observedRight : Nat
  deriving DecidableEq, Repr

def checkSchedule (leftLength rightLength : Nat) (schedule : Schedule) :
    Except ScheduleMismatch (PUnit : Type) :=
  if schedule.count .left = leftLength ∧ schedule.count .right = rightLength then .ok ⟨⟩
  else .error ⟨leftLength, schedule.count .left, rightLength, schedule.count .right⟩

def Complete {P A D : Type} (left right : Branch P A D) (schedule : Schedule) : Prop :=
  schedule.count .left = left.length ∧ schedule.count .right = right.length

inductive AdmissionFailure (P A D : Type) where
  | configuration
  | structural (branch : BranchId) (failure : Parallel.LocalFailure)
  | schedule (mismatch : ScheduleMismatch)
  deriving DecidableEq, Repr

variable {P A D : Type} [DecidableEq P] [DecidableEq A] [DecidableEq D]

def admit (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (left right : Branch P A D) (schedule : Schedule) :
    Except (AdmissionFailure P A D) (Footprint P A D × Footprint P A D) := do
  if !validateCatalog cfg.registry cfg.catalog then throw .configuration
  let lf ← (analyzeBranch cfg (boundaries .left) left).mapError (.structural .left)
  let rf ← (analyzeBranch cfg (boundaries .right) right).mapError (.structural .right)
  let _ ← (checkSchedule left.length right.length schedule).mapError .schedule
  return (lf, rf)

-- BEGIN PROOFS

theorem checkSchedule_ok_iff (leftLength rightLength : Nat) (schedule : Schedule) :
    checkSchedule leftLength rightLength schedule = .ok ⟨⟩ ↔
      schedule.count .left = leftLength ∧ schedule.count .right = rightLength := by
  simp [checkSchedule]

theorem checkSchedule_error_iff (leftLength rightLength : Nat) (schedule : Schedule)
    (mismatch : ScheduleMismatch) :
    checkSchedule leftLength rightLength schedule = .error mismatch ↔
      ¬ (schedule.count .left = leftLength ∧ schedule.count .right = rightLength) ∧
      mismatch = ⟨leftLength, schedule.count .left, rightLength, schedule.count .right⟩ := by
  by_cases h : schedule.count .left = leftLength ∧ schedule.count .right = rightLength
  · simp [checkSchedule, h]
  · simp only [checkSchedule, h, if_false, Except.error.injEq, not_false_eq_true, true_and]
    exact eq_comm

theorem count_sum_length (schedule : Schedule) :
    schedule.count .left + schedule.count .right = schedule.length := by
  induction schedule with
  | nil => rfl
  | cons branch schedule ih =>
    cases branch <;> simp at * <;> omega

theorem count_append (branch : BranchId) (first second : Schedule) :
    (first ++ second).count branch = first.count branch + second.count branch :=
  List.count_append

theorem count_left_cons (schedule : Schedule) :
    (BranchId.left :: schedule).count .left = schedule.count .left + 1 := by simp

theorem count_right_cons (schedule : Schedule) :
    (BranchId.right :: schedule).count .right = schedule.count .right + 1 := by simp

omit [DecidableEq P] [DecidableEq A] [DecidableEq D] in
theorem Complete.length {left right : Branch P A D} {schedule : Schedule}
    (h : Complete left right schedule) : schedule.length = left.length + right.length := by
  rw [← count_sum_length, h.1, h.2]

omit [DecidableEq P] [DecidableEq A] [DecidableEq D] in
theorem complete_empty_iff (schedule : Schedule) :
    Complete ([] : Branch P A D) [] schedule ↔ schedule = [] := by
  constructor
  · intro h
    exact List.length_eq_zero_iff.mp h.length
  · rintro rfl
    exact ⟨rfl, rfl⟩

omit [DecidableEq P] [DecidableEq A] [DecidableEq D] in
theorem complete_left_cons_iff (inv : Invocation P A D) (left right : Branch P A D)
    (schedule : Schedule) :
    Complete (inv :: left) right (.left :: schedule) ↔ Complete left right schedule := by
  simp [Complete]

omit [DecidableEq P] [DecidableEq A] [DecidableEq D] in
theorem complete_right_cons_iff (inv : Invocation P A D) (left right : Branch P A D)
    (schedule : Schedule) :
    Complete left (inv :: right) (.right :: schedule) ↔ Complete left right schedule := by
  simp [Complete]

omit [DecidableEq P] [DecidableEq A] [DecidableEq D] in
theorem Complete.prefix_counts {left right : Branch P A D} {preTokens suffix : Schedule}
    (h : Complete left right (preTokens ++ suffix)) :
    preTokens.count .left ≤ left.length ∧ preTokens.count .right ≤ right.length := by
  obtain ⟨hl, hr⟩ := h
  simp only [List.count_append] at hl hr
  omega

omit [DecidableEq P] [DecidableEq A] [DecidableEq D] in
theorem Complete.left_slot {left right : Branch P A D} {preTokens suffix : Schedule}
    (h : Complete left right (preTokens ++ .left :: suffix)) :
    preTokens.count .left < left.length := by
  have hl := h.1
  simp only [List.count_append, List.count_cons_self] at hl
  omega

omit [DecidableEq P] [DecidableEq A] [DecidableEq D] in
theorem Complete.right_slot {left right : Branch P A D} {preTokens suffix : Schedule}
    (h : Complete left right (preTokens ++ .right :: suffix)) :
    preTokens.count .right < right.length := by
  have hr := h.2
  simp only [List.count_append, List.count_cons_self] at hr
  omega

theorem admit_ok (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (left right : Branch P A D) (schedule : Schedule) (lf rf : Footprint P A D)
    (h : admit cfg boundaries left right schedule = .ok (lf, rf)) :
    validateCatalog cfg.registry cfg.catalog = true ∧
    analyzeBranch cfg (boundaries .left) left = .ok lf ∧
    analyzeBranch cfg (boundaries .right) right = .ok rf ∧ Complete left right schedule := by
  unfold admit at h
  simp only [bind, Except.bind, pure, Except.pure] at h
  split at h
  · simp [throw, throwThe] at h
  rename_i hv
  split at h
  · contradiction
  rename_i l hl
  split at h
  · contradiction
  rename_i r hr
  split at h
  · contradiction
  rename_i token hc
  cases token
  obtain ⟨rfl, rfl⟩ := Prod.mk.inj (Except.ok.inj h)
  have unmap {E F X : Type} (f : E → F) (x : Except E X) (v : X)
      (hx : x.mapError f = .ok v) : x = .ok v := by
    cases x <;> simp_all [Except.mapError]
  exact ⟨by simpa using hv, unmap _ _ _ hl, unmap _ _ _ hr,
    (checkSchedule_ok_iff _ _ _).mp (unmap _ _ _ hc)⟩

theorem admit_of_checks (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (left right : Branch P A D) (schedule : Schedule) (lf rf : Footprint P A D)
    (hv : validateCatalog cfg.registry cfg.catalog = true)
    (hl : analyzeBranch cfg (boundaries .left) left = .ok lf)
    (hr : analyzeBranch cfg (boundaries .right) right = .ok rf)
    (hs : Complete left right schedule) :
    admit cfg boundaries left right schedule = .ok (lf, rf) := by
  simp [admit, hv, hl, hr, checkSchedule, hs.1, hs.2, Except.mapError,
    bind, Except.bind, pure, Except.pure]

theorem admit_of_parallel (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (left right : Branch P A D) (schedule : Schedule) (lf rf : Footprint P A D)
    (hp : Parallel.admit cfg boundaries left right = .ok (lf, rf))
    (hs : Complete left right schedule) :
    admit cfg boundaries left right schedule = .ok (lf, rf) := by
  obtain ⟨hv, hl, hr, _⟩ := Parallel.admit_ok cfg boundaries left right lf rf hp
  exact admit_of_checks cfg boundaries left right schedule lf rf hv hl hr hs

theorem admit_left_member (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (left right : Branch P A D) (schedule : Schedule) (lf rf : Footprint P A D)
    (h : admit cfg boundaries left right schedule = .ok (lf, rf))
    (n : Nat) (inv : Invocation P A D) (hi : left[n]? = some inv) :
    ∃ part, analyzeInvocation cfg (boundaries .left n) inv = .ok part ∧
      (∀ c ∈ part.reads, c ∈ lf.reads) ∧ (∀ c ∈ part.writes, c ∈ lf.writes) := by
  have hl := (admit_ok cfg boundaries left right schedule lf rf h).2.1
  simpa using analyzeBranchFrom_member cfg (boundaries .left) 0 left lf hl n inv hi

theorem admit_right_member (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (left right : Branch P A D) (schedule : Schedule) (lf rf : Footprint P A D)
    (h : admit cfg boundaries left right schedule = .ok (lf, rf))
    (n : Nat) (inv : Invocation P A D) (hi : right[n]? = some inv) :
    ∃ part, analyzeInvocation cfg (boundaries .right n) inv = .ok part ∧
      (∀ c ∈ part.reads, c ∈ rf.reads) ∧ (∀ c ∈ part.writes, c ∈ rf.writes) := by
  have hr := (admit_ok cfg boundaries left right schedule lf rf h).2.2.1
  simpa using analyzeBranchFrom_member cfg (boundaries .right) 0 right rf hr n inv hi

end DefiKernel.Interleaving


===== INPUT lean/DefiKernel/Interleaving/Soundness.lean ORIGINAL_SHA256 f696f995190cd7a6729e536efe1cc7875239625de1070d830c0649061e432337 RENDERED_SHA256 f696f995190cd7a6729e536efe1cc7875239625de1070d830c0649061e432337 =====
import DefiKernel.Interleaving.Execution

/-! Reachability witnesses for actual attempts, including refused calls at their original
pre-world. The final world may subsequently change through successful peer invocations. -/
namespace DefiKernel.Interleaving
open Typed Composition Parallel

variable {P A D : Type} [DecidableEq P] [DecidableEq A] [DecidableEq D]
variable [Fintype P] [Fintype A] [Fintype D]

inductive AdvanceSound (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (left right : Branch P A D) (m : Machine P A D) (b : BranchId) : Machine P A D → Prop
  | halted (failure : LocatedFailure P A D) (failed : (m.local b).failure = some failure) :
      AdvanceSound cfg boundaries left right m b (m.skip b)
  | exhausted (active : (m.local b).failure = none)
      (absent : (selectBranch left right b)[(m.local b).consumed]? = none) :
      AdvanceSound cfg boundaries left right m b (m.skip b)
  | refused (inv : Invocation P A D) (reason : Composition.Failure)
      (active : (m.local b).failure = none)
      (selected : (selectBranch left right b)[(m.local b).consumed]? = some inv)
      (rejected : executeStep cfg (boundaries b (m.local b).nextIndex) (m.local b).nextIndex
        (m.local b).outputs (.invoke inv) m.world = .error reason) :
      AdvanceSound cfg boundaries left right m b (m.refuse b inv reason)
  | accepted (inv : Invocation P A D) (result : StepResult P A D)
      (active : (m.local b).failure = none)
      (selected : (selectBranch left right b)[(m.local b).consumed]? = some inv)
      (executed : executeStep cfg (boundaries b (m.local b).nextIndex) (m.local b).nextIndex
        (m.local b).outputs (.invoke inv) m.world = .ok result) :
      AdvanceSound cfg boundaries left right m b (m.accept b inv result)

inductive Reachable (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (left right : Branch P A D) (initial : World P A D) : Machine P A D → Prop
  | start : Reachable cfg boundaries left right initial (Interleaving.start initial)
  | next {pre post : Machine P A D} (b : BranchId)
      (previous : Reachable cfg boundaries left right initial pre)
      (step : AdvanceSound cfg boundaries left right pre b post) :
      Reachable cfg boundaries left right initial post

def AttemptSound (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (attempt : Attempt P A D) : Prop :=
  ∃ history, executeStep cfg (boundaries attempt.branch attempt.index) attempt.index history
    (.invoke attempt.invocation) attempt.before = attempt.outcome

-- BEGIN PROOFS

theorem advance_sound (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (left right : Branch P A D) (m : Machine P A D) (b : BranchId) :
    AdvanceSound cfg boundaries left right m b (advance cfg boundaries left right m b) := by
  cases hf : (m.local b).failure with
  | some failure =>
    simpa [advance, hf] using AdvanceSound.halted (cfg := cfg) (boundaries := boundaries)
      (left := left) (right := right) (m := m) (b := b) failure hf
  | none =>
    cases hs : (selectBranch left right b)[(m.local b).consumed]? with
    | none =>
      simpa [advance, hf, hs] using AdvanceSound.exhausted (cfg := cfg)
        (boundaries := boundaries) (left := left) (right := right) (m := m) (b := b) hf hs
    | some inv =>
      cases he : executeStep cfg (boundaries b (m.local b).nextIndex) (m.local b).nextIndex
          (m.local b).outputs (.invoke inv) m.world with
      | error reason =>
        simpa [advance, hf, hs, he] using AdvanceSound.refused (cfg := cfg)
          (boundaries := boundaries) (left := left) (right := right) (m := m) (b := b)
          inv reason hf hs he
      | ok result =>
        simpa [advance, hf, hs, he] using AdvanceSound.accepted (cfg := cfg)
          (boundaries := boundaries) (left := left) (right := right) (m := m) (b := b)
          inv result hf hs he

theorem continueRun_reachable (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (left right : Branch P A D) (initial : World P A D) (m : Machine P A D)
    (h : Reachable cfg boundaries left right initial m) (schedule : Schedule) :
    Reachable cfg boundaries left right initial
      (continueRun cfg boundaries left right m schedule) := by
  induction schedule generalizing m with
  | nil => exact h
  | cons b tail ih =>
    exact ih _ (.next b h (advance_sound cfg boundaries left right m b))

theorem runPrefix_reachable (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (initial : World P A D) (left right : Branch P A D) (schedule : Schedule) :
    Reachable cfg boundaries left right initial
      (runPrefix cfg boundaries initial left right schedule) :=
  continueRun_reachable cfg boundaries left right initial (start initial) .start schedule

omit [DecidableEq P] [DecidableEq A] [DecidableEq D] [Fintype P] [Fintype A] [Fintype D] in
theorem skip_world (m : Machine P A D) (b : BranchId) : (m.skip b).world = m.world := by
  cases b <;> rfl

omit [DecidableEq P] [DecidableEq A] [DecidableEq D] [Fintype P] [Fintype A] [Fintype D] in
theorem refuse_world (m : Machine P A D) (b : BranchId) (inv : Invocation P A D)
    (reason : Composition.Failure) : (m.refuse b inv reason).world = m.world := by
  cases b <;> rfl

omit [DecidableEq P] [DecidableEq A] [DecidableEq D] [Fintype P] [Fintype A] [Fintype D] in
theorem accept_world (m : Machine P A D) (b : BranchId) (inv : Invocation P A D)
    (result : StepResult P A D) : (m.accept b inv result).world = result.world := rfl

omit [DecidableEq P] [DecidableEq A] [DecidableEq D] [Fintype P] [Fintype A] [Fintype D] in
theorem skip_attempts (m : Machine P A D) (b : BranchId) :
    (m.skip b).attempts = m.attempts := by cases b <;> rfl

theorem AdvanceSound.store {cfg : Config P A D} {boundaries : ParallelBoundary P A D}
    {left right : Branch P A D} {m post : Machine P A D} {b : BranchId}
    (h : AdvanceSound cfg boundaries left right m b post) :
    post.world.capabilities = m.world.capabilities := by
  cases h with
  | halted => rw [skip_world]
  | exhausted => rw [skip_world]
  | refused => rw [refuse_world]
  | accepted inv result active selected executed =>
    exact (executeStep_sound _ _ _ _ _ _ _ executed).invoke_preserves_capabilities

theorem Reachable.store {cfg : Config P A D} {boundaries : ParallelBoundary P A D}
    {left right : Branch P A D} {initial : World P A D} {m : Machine P A D}
    (h : Reachable cfg boundaries left right initial m) :
    m.world.capabilities = initial.capabilities := by
  induction h with
  | start => rfl
  | next b previous step ih => exact step.store.trans ih

theorem AdvanceSound.attempts {cfg : Config P A D} {boundaries : ParallelBoundary P A D}
    {left right : Branch P A D} {m post : Machine P A D} {b : BranchId}
    (h : AdvanceSound cfg boundaries left right m b post)
    (previous : ∀ attempt ∈ m.attempts, AttemptSound cfg boundaries attempt) :
    ∀ attempt ∈ post.attempts, AttemptSound cfg boundaries attempt := by
  cases h with
  | halted => simpa [skip_attempts] using previous
  | exhausted => simpa [skip_attempts] using previous
  | refused inv reason active selected rejected =>
    intro attempt member
    simp only [Machine.refuse, List.mem_append, List.mem_singleton] at member
    rcases member with member | rfl
    · exact previous attempt member
    · exact ⟨_, rejected⟩
  | accepted inv result active selected executed =>
    intro attempt member
    simp only [Machine.accept, List.mem_append, List.mem_singleton] at member
    rcases member with member | rfl
    · exact previous attempt member
    · exact ⟨_, executed⟩

theorem Reachable.attempts {cfg : Config P A D} {boundaries : ParallelBoundary P A D}
    {left right : Branch P A D} {initial : World P A D} {m : Machine P A D}
    (h : Reachable cfg boundaries left right initial m) :
    ∀ attempt ∈ m.attempts, AttemptSound cfg boundaries attempt := by
  induction h with
  | start => simp [Interleaving.start]
  | next b previous step ih => exact step.attempts ih

theorem AdvanceSound.consumed {cfg : Config P A D} {boundaries : ParallelBoundary P A D}
    {left right : Branch P A D} {m post : Machine P A D} {b : BranchId}
    (h : AdvanceSound cfg boundaries left right m b post) (own : BranchId) :
    (post.local own).consumed =
      (m.local own).consumed + if b = own then 1 else 0 := by
  cases h <;> cases b <;> cases own <;>
    simp [Machine.skip, Machine.refuse, Machine.accept, Machine.setLocal, Machine.local]

theorem advance_consumed (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (left right : Branch P A D) (m : Machine P A D) (b own : BranchId) :
    ((advance cfg boundaries left right m b).local own).consumed =
      (m.local own).consumed + if b = own then 1 else 0 :=
  (advance_sound cfg boundaries left right m b).consumed own

theorem continueRun_consumed (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (left right : Branch P A D) (m : Machine P A D) (schedule : Schedule) (b : BranchId) :
    ((continueRun cfg boundaries left right m schedule).local b).consumed =
      (m.local b).consumed + schedule.count b := by
  induction schedule generalizing m with
  | nil => simp [continueRun]
  | cons next tail ih =>
    rw [show continueRun cfg boundaries left right m (next :: tail) =
      continueRun cfg boundaries left right
        (advance cfg boundaries left right m next) tail from rfl]
    rw [ih, advance_consumed]
    by_cases h : next = b <;> simp [h, Nat.add_assoc, Nat.add_comm]

theorem runPrefix_consumed (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (initial : World P A D) (left right : Branch P A D) (schedule : Schedule) (b : BranchId) :
    ((runPrefix cfg boundaries initial left right schedule).local b).consumed =
      schedule.count b := by
  rw [runPrefix, continueRun_consumed]
  cases b <;> simp [Interleaving.start, Machine.local]

theorem runPrefix_complete_counts (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (initial : World P A D) (left right : Branch P A D) (schedule : Schedule)
    (h : Complete left right schedule) :
    (runPrefix cfg boundaries initial left right schedule).left.consumed = left.length ∧
    (runPrefix cfg boundaries initial left right schedule).right.consumed = right.length := by
  exact ⟨(runPrefix_consumed cfg boundaries initial left right schedule .left).trans h.1,
    (runPrefix_consumed cfg boundaries initial left right schedule .right).trans h.2⟩

end DefiKernel.Interleaving


===== INPUT lean/DefiKernel/Interleaving/Trace.lean ORIGINAL_SHA256 566c89b6b0b9b203daa6458d4a3caeaea998d3ffbddfc63c22f72153320d9ac5 RENDERED_SHA256 566c89b6b0b9b203daa6458d4a3caeaea998d3ffbddfc63c22f72153320d9ac5 =====
import DefiKernel.Interleaving.Soundness
import DefiKernel.Interleaving.LocalOrder

/-! The global attempt chain and its branch projections are derived from real execution.
Refusal witnesses refer to the world at that attempt, not the later peer-updated final world. -/
namespace DefiKernel.Interleaving
open Typed Composition Parallel

variable {P A D : Type} [DecidableEq P] [DecidableEq A] [DecidableEq D]
variable [Fintype P] [Fintype A] [Fintype D]

inductive AttemptChain (initial : World P A D) :
    List (Attempt P A D) → World P A D → Prop
  | empty : AttemptChain initial [] initial
  | success {attempts : List (Attempt P A D)} {pre : World P A D}
      {attempt : Attempt P A D} {result : StepResult P A D}
      (previous : AttemptChain initial attempts pre) (before : attempt.before = pre)
      (outcome : attempt.outcome = .ok result) :
      AttemptChain initial (attempts ++ [attempt]) result.world
  | refusal {attempts : List (Attempt P A D)} {pre : World P A D}
      {attempt : Attempt P A D} {reason : Composition.Failure}
      (previous : AttemptChain initial attempts pre) (before : attempt.before = pre)
      (outcome : attempt.outcome = .error reason) :
      AttemptChain initial (attempts ++ [attempt]) pre

def successfulEvent (b : BranchId) (attempt : Attempt P A D) : Option (Event P A D) :=
  if attempt.branch = b then
    match attempt.outcome with
    | .error _ => none
    | .ok result => some ⟨attempt.index, .invoke attempt.invocation, attempt.before, result⟩
  else none

-- BEGIN PROOFS

theorem Reachable.attempt_chain {cfg : Config P A D} {boundaries : ParallelBoundary P A D}
    {left right : Branch P A D} {initial : World P A D} {m : Machine P A D}
    (h : Reachable cfg boundaries left right initial m) :
    AttemptChain initial m.attempts m.world := by
  induction h with
  | start => exact .empty
  | next b previous step ih =>
    cases step with
    | halted => simpa [skip_world, skip_attempts] using ih
    | exhausted => simpa [skip_world, skip_attempts] using ih
    | refused inv reason active selected rejected =>
      rw [refuse_world]
      exact .refusal ih rfl rfl
    | accepted inv result active selected executed => exact .success ih rfl rfl

theorem Reachable.branch_projection {cfg : Config P A D}
    {boundaries : ParallelBoundary P A D} {left right : Branch P A D}
    {initial : World P A D} {m : Machine P A D}
    (h : Reachable cfg boundaries left right initial m) :
    ∀ b, (m.local b).events = m.attempts.filterMap (successfulEvent b) := by
  induction h with
  | start => intro b; cases b <;> rfl
  | next b previous step ih =>
    intro own
    have hl := ih .left
    have hr := ih .right
    cases step <;> cases b <;> cases own <;>
      simp_all [Machine.skip, Machine.refuse, Machine.accept, Machine.setLocal, Machine.local,
        successfulEvent, List.filterMap_append]

theorem Reachable.local_history {cfg : Config P A D} {boundaries : ParallelBoundary P A D}
    {left right : Branch P A D} {initial : World P A D} {m : Machine P A D}
    (h : Reachable cfg boundaries left right initial m) :
    ∀ b, (m.local b).outputs = (m.local b).events.flatMap (fun event ↦ event.result.outputs) := by
  induction h with
  | start => intro b; cases b <;> rfl
  | next b previous step ih =>
    intro own
    have hl := ih .left
    have hr := ih .right
    cases step <;> cases b <;> cases own <;>
      simp_all [Machine.skip, Machine.refuse, Machine.accept, Machine.setLocal, Machine.local]

theorem Reachable.local_event_index {cfg : Config P A D}
    {boundaries : ParallelBoundary P A D} {left right : Branch P A D}
    {initial : World P A D} {m : Machine P A D}
    (h : Reachable cfg boundaries left right initial m) :
    ∀ b, (m.local b).nextIndex = (m.local b).events.length := by
  induction h with
  | start => intro b; cases b <;> rfl
  | next b previous step ih =>
    intro own
    have hl := ih .left
    have hr := ih .right
    cases step <;> cases b <;> cases own <;>
      simp_all [Machine.skip, Machine.refuse, Machine.accept, Machine.setLocal, Machine.local]

theorem Reachable.local_order {cfg : Config P A D} {boundaries : ParallelBoundary P A D}
    {left right : Branch P A D} {initial : World P A D} {m : Machine P A D}
    (h : Reachable cfg boundaries left right initial m) :
    ∀ b, (m.local b).events.map Event.step =
      ((selectBranch left right b).take (m.local b).nextIndex).map Step.invoke := by
  induction h with
  | start => intro b; cases b <;> rfl
  | @next pre post b previous step ih =>
    intro own
    have hl := ih .left
    have hr := ih .right
    have ho := ih own
    cases step with
    | halted =>
      cases b <;> cases own <;>
        simpa [Machine.skip, Machine.setLocal, Machine.local] using ho
    | exhausted =>
      cases b <;> cases own <;>
        simpa [Machine.skip, Machine.setLocal, Machine.local] using ho
    | refused =>
      cases b <;> cases own <;>
        simpa [Machine.refuse, Machine.setLocal, Machine.local] using ho
    | accepted inv result active selected executed =>
      have hi := previous.attempt_index b active inv selected
      have ht : (selectBranch left right b).take ((pre.local b).nextIndex + 1) =
          (selectBranch left right b).take (pre.local b).nextIndex ++ [inv] := by
        rw [hi, List.take_add_one]
        simp [selected]
      cases b <;> cases own <;>
        simp_all [Machine.accept, Machine.setLocal, Machine.local, selectBranch]

theorem Reachable.failure_index {cfg : Config P A D} {boundaries : ParallelBoundary P A D}
    {left right : Branch P A D} {initial : World P A D} {m : Machine P A D}
    (h : Reachable cfg boundaries left right initial m) :
    ∀ b failure, (m.local b).failure = some failure → failure.index = (m.local b).nextIndex := by
  induction h with
  | start => intro b; cases b <;> simp [Interleaving.start, Machine.local]
  | next b previous step ih =>
    intro own failure hf
    have hl := ih .left
    have hr := ih .right
    cases step <;> cases b <;> cases own <;>
      simp_all [Machine.skip, Machine.refuse, Machine.accept, Machine.setLocal, Machine.local]
    all_goals cases hf; rfl

theorem AdvanceSound.refusal_stable {cfg : Config P A D}
    {boundaries : ParallelBoundary P A D} {left right : Branch P A D}
    {m post : Machine P A D} {b : BranchId}
    (h : AdvanceSound cfg boundaries left right m b post) (own : BranchId)
    (failure : LocatedFailure P A D) (failed : (m.local own).failure = some failure) :
    (post.local own).failure = some failure ∧
      (post.local own).events = (m.local own).events ∧
      (post.local own).outputs = (m.local own).outputs ∧
      (post.local own).nextIndex = (m.local own).nextIndex := by
  cases h <;> cases b <;> cases own <;>
    simp_all [Machine.skip, Machine.refuse, Machine.accept, Machine.setLocal, Machine.local]

theorem advance_refusal_stable (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (left right : Branch P A D) (m : Machine P A D) (b own : BranchId)
    (failure : LocatedFailure P A D) (failed : (m.local own).failure = some failure) :
    let post := advance cfg boundaries left right m b
    (post.local own).failure = some failure ∧
      (post.local own).events = (m.local own).events ∧
      (post.local own).outputs = (m.local own).outputs ∧
      (post.local own).nextIndex = (m.local own).nextIndex :=
  (advance_sound cfg boundaries left right m b).refusal_stable own failure failed

theorem continueRun_refusal_stable (cfg : Config P A D)
    (boundaries : ParallelBoundary P A D) (left right : Branch P A D)
    (m : Machine P A D) (schedule : Schedule) (own : BranchId)
    (failure : LocatedFailure P A D) (failed : (m.local own).failure = some failure) :
    let post := continueRun cfg boundaries left right m schedule
    (post.local own).failure = some failure ∧
      (post.local own).events = (m.local own).events ∧
      (post.local own).outputs = (m.local own).outputs ∧
      (post.local own).nextIndex = (m.local own).nextIndex := by
  induction schedule generalizing m with
  | nil => exact ⟨failed, rfl, rfl, rfl⟩
  | cons b tail ih =>
    have first := advance_refusal_stable cfg boundaries left right m b own failure failed
    have rest := ih _ first.1
    exact ⟨rest.1, rest.2.1.trans first.2.1,
      rest.2.2.1.trans first.2.2.1, rest.2.2.2.trans first.2.2.2⟩

end DefiKernel.Interleaving


===== INPUT lean/DefiKernel/Parallel/Commutation.lean ORIGINAL_SHA256 c85f69f1bfad39700096c95dbd1450e65eb5f102d4b08a80054f45edf96c52ef RENDERED_SHA256 c85f69f1bfad39700096c95dbd1450e65eb5f102d4b08a80054f45edf96c52ef =====
import DefiKernel.Parallel.Execution
import DefiKernel.Parallel.Dependency.Adapter

/-! Congruence of full local histories and exact refusals, then correspondence to actual
serial branch re-execution. Dependency premises are discharged from checked admission. -/
namespace DefiKernel.Parallel
open Typed Composition

variable {P A D : Type} [DecidableEq P] [DecidableEq A] [DecidableEq D]
variable [Fintype P] [Fintype A] [Fintype D]

-- BEGIN PROOFS

structure CursorAgrees (region : Set (Cell P A D)) (left right : Cursor P A D) : Prop where
  state : AgreeOn region left.world.state right.world.state
  capabilities : left.world.capabilities = right.world.capabilities
  events : left.events.map observeEvent = right.events.map observeEvent
  outputs : left.outputs = right.outputs
  nextIndex : left.nextIndex = right.nextIndex
  failure : left.failure = right.failure

omit [DecidableEq P] [DecidableEq A] [DecidableEq D] [Fintype P] [Fintype A] [Fintype D] in
theorem CursorAgrees.observation {region : Set (Cell P A D)} {left right : Cursor P A D}
    (h : CursorAgrees region left right) : observeBranch left = observeBranch right := by
  simp only [observeBranch, h.events, h.outputs, h.nextIndex, h.failure]

theorem continueRun_congr (cfg : Config P A D) (boundary : Nat → Boundary P A D)
    (branch : Branch P A D) (index : Nat) (fp : Footprint P A D)
    (region : Set (Cell P A D)) (left right : Cursor P A D)
    (hf : analyzeBranchFrom cfg boundary index branch = .ok fp)
    (hin : ∀ c ∈ fp.reads, c ∈ region) (hi : left.nextIndex = index)
    (ha : CursorAgrees region left right) :
    CursorAgrees region (continueRun cfg boundary left (branch.map Step.invoke))
      (continueRun cfg boundary right (branch.map Step.invoke)) := by
  induction branch generalizing index fp left right with
  | nil => exact ha
  | cons inv tail ih =>
    obtain ⟨head, rest, hh, ht, hfp⟩ := analyzeBranchFrom_cons _ _ _ _ _ _ hf
    have hhead : ∀ c ∈ head.reads, c ∈ region := by
      intro c hc
      apply hin c
      simp [hfp, Footprint.append, hc]
    have hrest : ∀ c ∈ rest.reads, c ∈ region := by
      intro c hc
      apply hin c
      simp [hfp, Footprint.append, hc]
    have hir : right.nextIndex = index := ha.nextIndex.symm.trans hi
    cases hfl : left.failure with
    | some failure =>
      have hfr : right.failure = some failure := ha.failure.symm.trans hfl
      simpa [continueRun_failed cfg boundary left failure hfl,
        continueRun_failed cfg boundary right failure hfr] using ha
    | none =>
      have hfr : right.failure = none := ha.failure.symm.trans hfl
      have hs := executeStep_congr cfg (boundary index) index left.outputs inv
        left.world right.world head region hh hhead ha.state ha.capabilities
      change CursorAgrees region
        (continueRun cfg boundary (advance cfg boundary left (.invoke inv))
          (tail.map Step.invoke))
        (continueRun cfg boundary (advance cfg boundary right (.invoke inv))
          (tail.map Step.invoke))
      cases hl : executeStep cfg (boundary index) index left.outputs (.invoke inv) left.world with
      | error le =>
        cases hr : executeStep cfg (boundary index) index left.outputs
            (.invoke inv) right.world with
        | ok rr => simp [hl, hr, StepAgrees] at hs
        | error re =>
          simp only [hl, hr, StepAgrees] at hs
          subst re
          have hal : advance cfg boundary left (.invoke inv) =
              { left with failure := some ⟨index, some (.invoke inv), le⟩ } := by
            simp [advance, hfl, hi, hl]
          have har : advance cfg boundary right (.invoke inv) =
              { right with failure := some ⟨index, some (.invoke inv), le⟩ } := by
            simp [advance, hfr, hir, ← ha.outputs, hr]
          rw [hal, har]
          rw [continueRun_failed cfg boundary _ _ rfl,
            continueRun_failed cfg boundary _ _ rfl]
          exact ⟨ha.state, ha.capabilities, ha.events, ha.outputs, ha.nextIndex, rfl⟩
      | ok lr =>
        cases hr : executeStep cfg (boundary index) index left.outputs
            (.invoke inv) right.world with
        | error re => simp [hl, hr, StepAgrees] at hs
        | ok rr =>
          simp only [hl, hr, StepAgrees] at hs
          let nl : Cursor P A D :=
            ⟨lr.world, left.events ++ [⟨index, .invoke inv, left.world, lr⟩],
              left.outputs ++ lr.outputs, index + 1, none⟩
          let nr : Cursor P A D :=
            ⟨rr.world, right.events ++ [⟨index, .invoke inv, right.world, rr⟩],
              right.outputs ++ rr.outputs, index + 1, none⟩
          have hal : advance cfg boundary left (.invoke inv) = nl := by
            simp [advance, hfl, hi, hl, nl]
          have har : advance cfg boundary right (.invoke inv) = nr := by
            simp [advance, hfr, hir, ← ha.outputs, hr, nr]
          rw [hal, har]
          apply ih (index + 1) rest nl nr ht hrest rfl
          refine ⟨hs.1, hs.2.1, ?_, ?_, rfl, rfl⟩
          · simp [nl, nr, List.map_append, observeEvent, ha.events, hs.2.2.1, hs.2.2.2]
          · simp [nl, nr, ha.outputs, hs.2.2.2]

theorem runBranch_congr (cfg : Config P A D) (boundary : Nat → Boundary P A D)
    (branch : Branch P A D) (fp : Footprint P A D) (region : Set (Cell P A D))
    (left right : World P A D) (hf : analyzeBranch cfg boundary branch = .ok fp)
    (hin : ∀ c ∈ fp.reads, c ∈ region) (ha : AgreeOn region left.state right.state)
    (hc : left.capabilities = right.capabilities) :
    CursorAgrees region (runBranch cfg boundary left branch)
      (runBranch cfg boundary right branch) := by
  apply continueRun_congr cfg boundary branch 0 fp region _ _ hf hin rfl
  exact ⟨ha, hc, rfl, rfl, rfl, rfl⟩

theorem continueRun_frame (cfg : Config P A D) (boundary : Nat → Boundary P A D)
    (branch : Branch P A D) (index : Nat) (fp : Footprint P A D) (cursor : Cursor P A D)
    (hf : analyzeBranchFrom cfg boundary index branch = .ok fp)
    (hi : cursor.nextIndex = index) :
    (∀ c, c ∉ fp.writes →
      (continueRun cfg boundary cursor (branch.map Step.invoke)).world.state.balance c =
        cursor.world.state.balance c) ∧
      (continueRun cfg boundary cursor (branch.map Step.invoke)).world.capabilities =
        cursor.world.capabilities := by
  induction branch generalizing index fp cursor with
  | nil => exact ⟨fun _ _ ↦ rfl, rfl⟩
  | cons inv tail ih =>
    obtain ⟨head, rest, hh, ht, hfp⟩ := analyzeBranchFrom_cons _ _ _ _ _ _ hf
    cases hfl : cursor.failure with
    | some failure =>
      rw [continueRun_failed cfg boundary cursor failure hfl]
      exact ⟨fun _ _ ↦ rfl, rfl⟩
    | none =>
      change (∀ c, c ∉ fp.writes →
        (continueRun cfg boundary (advance cfg boundary cursor (.invoke inv))
          (tail.map Step.invoke)).world.state.balance c = cursor.world.state.balance c) ∧
        (continueRun cfg boundary (advance cfg boundary cursor (.invoke inv))
          (tail.map Step.invoke)).world.capabilities = cursor.world.capabilities
      cases hx : executeStep cfg (boundary index) index cursor.outputs
          (.invoke inv) cursor.world with
      | error reason =>
        have hadv : advance cfg boundary cursor (.invoke inv) =
            { cursor with failure := some ⟨index, some (.invoke inv), reason⟩ } := by
          simp [advance, hfl, hi, hx]
        rw [hadv, continueRun_failed cfg boundary _ _ rfl]
        exact ⟨fun _ _ ↦ rfl, rfl⟩
      | ok result =>
        let next : Cursor P A D :=
          ⟨result.world, cursor.events ++ [⟨index, .invoke inv, cursor.world, result⟩],
            cursor.outputs ++ result.outputs, index + 1, none⟩
        have hadv : advance cfg boundary cursor (.invoke inv) = next := by
          simp [advance, hfl, hi, hx, next]
        rw [hadv]
        have hs := executeStep_target_frame cfg (boundary index) index cursor.outputs inv
          cursor.world result head hh hx
        have htail := ih (index + 1) rest next ht rfl
        refine ⟨?_, htail.2.trans hs.2⟩
        intro c hc
        have hhead : c ∉ head.writes := by
          intro hm; apply hc; simp [hfp, Footprint.append, hm]
        have hrest : c ∉ rest.writes := by
          intro hm; apply hc; simp [hfp, Footprint.append, hm]
        exact (htail.1 c hrest).trans (hs.1 c hhead)

theorem runBranch_frame (cfg : Config P A D) (boundary : Nat → Boundary P A D)
    (initial : World P A D) (branch : Branch P A D) (fp : Footprint P A D)
    (hf : analyzeBranch cfg boundary branch = .ok fp) :
    (∀ c, c ∉ fp.writes → (runBranch cfg boundary initial branch).world.state.balance c =
      initial.state.balance c) ∧
      (runBranch cfg boundary initial branch).world.capabilities = initial.capabilities := by
  exact continueRun_frame cfg boundary branch 0 fp (startCursor cfg initial) hf rfl

omit [Fintype P] [Fintype A] [Fintype D] in
theorem analyzeBranchFrom_writes_read (cfg : Config P A D)
    (boundary : Nat → Boundary P A D) (index : Nat) (branch : Branch P A D)
    (fp : Footprint P A D) (hf : analyzeBranchFrom cfg boundary index branch = .ok fp) :
    ∀ c ∈ fp.writes, c ∈ fp.reads := by
  induction branch generalizing index fp with
  | nil =>
    have he : fp = Footprint.empty := by simpa [analyzeBranchFrom] using hf.symm
    simp [he, Footprint.empty]
  | cons inv tail ih =>
    obtain ⟨head, rest, hh, ht, rfl⟩ := analyzeBranchFrom_cons _ _ _ _ _ _ hf
    intro c hc
    rcases List.mem_append.mp hc with hc | hc
    · exact List.mem_append_left _ (analyzeInvocation_writes_read _ _ _ _ hh c hc)
    · exact List.mem_append_right _ (ih (index + 1) rest ht c hc)

/-- The real second run has the same local observations, including exact refusal. -/
theorem rerun_after_peer (cfg : Config P A D) (ownBoundary peerBoundary : Nat → Boundary P A D)
    (initial : World P A D) (own peer : Branch P A D) (ownFp peerFp : Footprint P A D)
    (ho : analyzeBranch cfg ownBoundary own = .ok ownFp)
    (hp : analyzeBranch cfg peerBoundary peer = .ok peerFp)
    (hd : ∀ c ∈ peerFp.writes, c ∉ ownFp.reads) :
    CursorAgrees {c | c ∈ ownFp.reads} (runBranch cfg ownBoundary initial own)
      (runBranch cfg ownBoundary (runBranch cfg peerBoundary initial peer).world own) := by
  have frame := runBranch_frame cfg peerBoundary initial peer peerFp hp
  apply runBranch_congr cfg ownBoundary own ownFp _ _ _ ho (fun _ h ↦ h)
  · intro c hc
    exact (frame.1 c (fun hw ↦ hd c hw hc)).symm
  · exact frame.2.symm

/-- Region merge equals a fresh right execution after the real left retained prefix. -/
theorem merge_serialLR (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (initial : World P A D) (left right : Branch P A D) (lf rf : Footprint P A D)
    (hl : analyzeBranch cfg (boundaries .left) left = .ok lf)
    (hr : analyzeBranch cfg (boundaries .right) right = .ok rf)
    (hc : Compatible lf rf) :
    WorldEquivalent
      (mergeWorld lf rf initial (runBranch cfg (boundaries .left) initial left).world
        (runBranch cfg (boundaries .right) initial right).world)
      (runBranch cfg (boundaries .right)
        (runBranch cfg (boundaries .left) initial left).world right).world := by
  have le := runBranch_frame cfg (boundaries .left) initial left lf hl
  have re := runBranch_frame cfg (boundaries .right)
    (runBranch cfg (boundaries .left) initial left).world right rf hr
  have ra := rerun_after_peer cfg (boundaries .right) (boundaries .left)
    initial right left rf lf hr hl hc.2.1
  refine ⟨?_, (re.2.trans le.2).symm⟩
  intro c
  by_cases hcl : c ∈ lf.writes
  · have hcr := hc.1 c hcl
    simpa [mergeWorld, hcl] using (re.1 c hcr).symm
  · by_cases hcr : c ∈ rf.writes
    · have hread := analyzeBranchFrom_writes_read cfg (boundaries .right) 0 right rf hr c hcr
      simpa [mergeWorld, hcl, hcr] using ra.state c hread
    · simpa [mergeWorld, hcl, hcr] using ((re.1 c hcr).trans (le.1 c hcl)).symm

theorem runParallel_serialLR (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (initial : World P A D) (left right : Branch P A D) :
    ObservationallyEquivalent (runParallel cfg boundaries initial left right)
      (runSerialLR cfg boundaries initial left right) := by
  cases ha : admit cfg boundaries left right with
  | error reason => simp [runParallel, runSerialLR, ha, ObservationallyEquivalent, WorldEquivalent]
  | ok pair =>
    rcases pair with ⟨lf, rf⟩
    obtain ⟨_, hl, hr, hc⟩ := admit_ok cfg boundaries left right lf rf ha
    simp only [runParallel, runSerialLR, ha, ObservationallyEquivalent]
    exact ⟨merge_serialLR cfg boundaries initial left right lf rf hl hr hc, True.intro,
      (rerun_after_peer cfg (boundaries .right) (boundaries .left)
        initial right left rf lf hr hl hc.2.1).observation⟩

omit [Fintype P] [Fintype A] [Fintype D] in
theorem mergeWorld_swap (lf rf : Footprint P A D) (initial left right : World P A D)
    (hc : Compatible lf rf) :
    WorldEquivalent (mergeWorld lf rf initial left right)
      (mergeWorld rf lf initial right left) := by
  refine ⟨?_, rfl⟩
  intro c
  by_cases hl : c ∈ lf.writes
  · simp [mergeWorld, hl, hc.1 c hl]
  · by_cases hr : c ∈ rf.writes <;> simp [mergeWorld, hl, hr]

theorem runParallel_serialRL (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (initial : World P A D) (left right : Branch P A D) :
    ObservationallyEquivalent (runParallel cfg boundaries initial left right)
      (runSerialRL cfg boundaries initial left right) := by
  cases ha : admit cfg boundaries left right with
  | error reason => simp [runParallel, runSerialRL, ha, ObservationallyEquivalent, WorldEquivalent]
  | ok pair =>
    rcases pair with ⟨lf, rf⟩
    obtain ⟨_, hl, hr, hc⟩ := admit_ok cfg boundaries left right lf rf ha
    let swapped : ParallelBoundary P A D := fun side ↦
      match side with | .left => boundaries .right | .right => boundaries .left
    have hm := merge_serialLR cfg swapped initial right left rf lf hr hl (compatible_symm hc)
    have hs := mergeWorld_swap lf rf initial
      (runBranch cfg (boundaries .left) initial left).world
      (runBranch cfg (boundaries .right) initial right).world hc
    simp only [runParallel, runSerialRL, ha, ObservationallyEquivalent]
    exact ⟨⟨fun c ↦ (hs.1 c).trans (hm.1 c), hs.2.trans hm.2⟩,
      (rerun_after_peer cfg (boundaries .left) (boundaries .right)
        initial left right lf rf hl hr hc.2.2).observation, True.intro⟩

/-- Singleton calls inherit exact refusal-aware sequential correspondence. -/
theorem singleton_commutation (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (initial : World P A D) (left right : Invocation P A D) :
    ObservationallyEquivalent (runParallel cfg boundaries initial [left] [right])
      (runSerialLR cfg boundaries initial [left] [right]) ∧
    ObservationallyEquivalent (runParallel cfg boundaries initial [left] [right])
      (runSerialRL cfg boundaries initial [left] [right]) :=
  ⟨runParallel_serialLR _ _ _ _ _, runParallel_serialRL _ _ _ _ _⟩

theorem runBranch_empty (cfg : Config P A D) (boundary : Nat → Boundary P A D)
    (initial : World P A D) : runBranch cfg boundary initial [] = startCursor cfg initial := rfl

/-- An admitted empty peer has no events or outputs and contributes no ledger change. -/
theorem runParallel_empty_right (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (initial : World P A D) (left : Branch P A D) (lf : Footprint P A D)
    (ha : admit cfg boundaries left [] = .ok (lf, .empty)) :
    ObservationallyEquivalent (runParallel cfg boundaries initial left [])
      (.executed ⟨(runBranch cfg (boundaries .left) initial left).world,
        runBranch cfg (boundaries .left) initial left, startCursor cfg initial⟩) := by
  obtain ⟨_, hl, _, _⟩ := admit_ok cfg boundaries left [] lf .empty ha
  have hf := runBranch_frame cfg (boundaries .left) initial left lf hl
  simp only [runParallel, ha, ObservationallyEquivalent, runBranch_empty]
  refine ⟨⟨?_, hf.2.symm⟩, True.intro, True.intro⟩
  intro c
  by_cases hc : c ∈ lf.writes
  · simp [mergeWorld, hc]
  · simpa [mergeWorld, hc, Footprint.empty] using (hf.1 c hc).symm

theorem runParallel_empty_left (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (initial : World P A D) (right : Branch P A D) (rf : Footprint P A D)
    (ha : admit cfg boundaries [] right = .ok (.empty, rf)) :
    ObservationallyEquivalent (runParallel cfg boundaries initial [] right)
      (.executed ⟨(runBranch cfg (boundaries .right) initial right).world,
        startCursor cfg initial, runBranch cfg (boundaries .right) initial right⟩) := by
  obtain ⟨_, _, hr, _⟩ := admit_ok cfg boundaries [] right .empty rf ha
  have hf := runBranch_frame cfg (boundaries .right) initial right rf hr
  simp only [runParallel, ha, ObservationallyEquivalent, runBranch_empty]
  refine ⟨⟨?_, hf.2.symm⟩, True.intro, True.intro⟩
  intro c
  by_cases hc : c ∈ rf.writes
  · simp [mergeWorld, hc, Footprint.empty]
  · simpa [mergeWorld, hc, Footprint.empty] using (hf.1 c hc).symm

/-- Both real sequential schedules yield the same complete canonical observation. -/
theorem serial_orders_equivalent (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (initial : World P A D) (left right : Branch P A D) :
    ObservationallyEquivalent (runSerialLR cfg boundaries initial left right)
      (runSerialRL cfg boundaries initial left right) :=
  (runParallel_serialLR cfg boundaries initial left right).symm.trans
    (runParallel_serialRL cfg boundaries initial left right)

end DefiKernel.Parallel


===== INPUT lean/DefiKernel/Parallel/Compatibility.lean ORIGINAL_SHA256 4459fa2b4a4f1f695d3856cb67a46a7c9df86a90f924be8bd26f55e99ba54243 RENDERED_SHA256 4459fa2b4a4f1f695d3856cb67a46a7c9df86a90f924be8bd26f55e99ba54243 =====
import DefiKernel.Composition.Execution

/-! Conservative admission for invocation-only branches. Lists preserve deterministic witnesses. -/
namespace DefiKernel.Parallel
open Typed Composition

inductive BranchId where
  | left
  | right
  deriving DecidableEq, Repr
abbrev Branch (P A D : Type) := List (Invocation P A D)
abbrev ParallelBoundary (P A D : Type) := BranchId → Nat → Boundary P A D
structure Footprint (P A D : Type) where
  reads : List (Cell P A D)
  writes : List (Cell P A D)
  deriving DecidableEq, Repr
structure LocalFailure where
  index : Nat
  reason : Composition.Failure
  deriving DecidableEq, Repr
inductive ConflictKind where
  | writeWrite
  | leftWriteRightRead
  | rightWriteLeftRead
  deriving DecidableEq, Repr
inductive AdmissionFailure (P A D : Type) where
  | configuration
  | structural (branch : BranchId) (failure : LocalFailure)
  | conflict (kind : ConflictKind) (cell : Cell P A D)
  deriving DecidableEq, Repr
variable {P A D : Type} [DecidableEq P] [DecidableEq A] [DecidableEq D]
def Footprint.empty : Footprint P A D := ⟨[], []⟩
def Footprint.append (a b : Footprint P A D) : Footprint P A D :=
  ⟨a.reads ++ b.reads, a.writes ++ b.writes⟩
/-- Lookup, read resolution, write/target resolution, then access checks.
No financial values are evaluated. -/
def analyzeInvocation (cfg : Config P A D) (boundary : Boundary P A D)
    (inv : Invocation P A D) : Except Composition.Failure (Footprint P A D) := do
  let (component, iface) ← match lookupOperation cfg.catalog inv.component inv.operation with
    | none => .error (.interface .unknownOperation)
    | some pair => .ok pair
  let template ← match cfg.registry inv.operation with
    | none => .error (.kernel .unknownOperation)
    | some template => .ok template
  let reads ← (resolveRefs boundary.ctx.principal inv.parties
    (template.requiredStateReads ++ template.stateReads)).mapError
      (fun e ↦ .interface (.resolution e))
  let writes ← (resolveRefs boundary.ctx.principal inv.parties
    (template.writes ++ template.deltas.map (fun d ↦ ⟨d.asset, d.target⟩))).mapError
      (fun e ↦ .interface (.resolution e))
  let _ ← (checkAccess component template boundary.ctx inv.parties).mapError .interface
  return ⟨reads ++ writes ++ iface.outputs.map OutputPort.cell, writes⟩
/-- Structural analysis covers the entire suffix even when a financial prefix would refuse. -/
def analyzeBranchFrom (cfg : Config P A D) (boundary : Nat → Boundary P A D)
    (index : Nat) : Branch P A D → Except LocalFailure (Footprint P A D)
  | [] => .ok .empty
  | inv :: tail => do
    let head ← (analyzeInvocation cfg (boundary index) inv).mapError (⟨index, ·⟩)
    let rest ← analyzeBranchFrom cfg boundary (index + 1) tail
    return head.append rest
def analyzeBranch (cfg : Config P A D) (boundary : Nat → Boundary P A D)
    (branch : Branch P A D) : Except LocalFailure (Footprint P A D) :=
  analyzeBranchFrom cfg boundary 0 branch
def firstOverlap (xs ys : List (Cell P A D)) : Option (Cell P A D) :=
  xs.find? (fun c ↦ decide (c ∈ ys))
def checkCompatibility (left right : Footprint P A D) :
    Except (AdmissionFailure P A D) PUnit :=
  match firstOverlap left.writes right.writes with
  | some c => .error (.conflict .writeWrite c)
  | none => match firstOverlap left.writes right.reads with
    | some c => .error (.conflict .leftWriteRightRead c)
    | none => match firstOverlap right.writes left.reads with
      | some c => .error (.conflict .rightWriteLeftRead c)
      | none => .ok ⟨⟩
def admit (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (left right : Branch P A D) : Except (AdmissionFailure P A D)
      (Footprint P A D × Footprint P A D) := do
  if !validateCatalog cfg.registry cfg.catalog then throw .configuration
  let lf ← (analyzeBranch cfg (boundaries .left) left).mapError (.structural .left)
  let rf ← (analyzeBranch cfg (boundaries .right) right).mapError (.structural .right)
  let _ ← checkCompatibility lf rf
  return (lf, rf)

-- BEGIN PROOFS

def Compatible (left right : Footprint P A D) : Prop :=
  (∀ c ∈ left.writes, c ∉ right.writes) ∧
  (∀ c ∈ left.writes, c ∉ right.reads) ∧
  (∀ c ∈ right.writes, c ∉ left.reads)
theorem firstOverlap_none_iff (xs ys : List (Cell P A D)) :
    firstOverlap xs ys = none ↔ ∀ c ∈ xs, c ∉ ys := by
  simp [firstOverlap, List.find?_eq_none]
theorem checkCompatibility_ok_iff (left right : Footprint P A D) :
    checkCompatibility left right = .ok PUnit.unit ↔ Compatible left right := by
  unfold Compatible
  simp only [← firstOverlap_none_iff]
  unfold checkCompatibility
  cases hww : firstOverlap left.writes right.writes <;>
    cases hlr : firstOverlap left.writes right.reads <;>
    cases hrl : firstOverlap right.writes left.reads <;>
    simp_all
omit [DecidableEq P] [DecidableEq A] [DecidableEq D] in
theorem compatible_symm {left right : Footprint P A D} (h : Compatible left right) :
    Compatible right left := by
  exact ⟨fun c hr hl ↦ h.1 c hl hr, h.2.2, h.2.1⟩
theorem analyzeInvocation_ok (cfg : Config P A D) (boundary : Boundary P A D)
    (inv : Invocation P A D) (fp : Footprint P A D)
    (h : analyzeInvocation cfg boundary inv = .ok fp) :
    ∃ component iface template reads writes,
      lookupOperation cfg.catalog inv.component inv.operation = some (component, iface) ∧
      cfg.registry inv.operation = some template ∧
      resolveRefs boundary.ctx.principal inv.parties
        (template.requiredStateReads ++ template.stateReads) = .ok reads ∧
      resolveRefs boundary.ctx.principal inv.parties
        (template.writes ++ template.deltas.map (fun d ↦ ⟨d.asset, d.target⟩)) = .ok writes ∧
      checkAccess component template boundary.ctx inv.parties = .ok PUnit.unit ∧
      fp = ⟨reads ++ writes ++ iface.outputs.map OutputPort.cell, writes⟩ := by
  unfold analyzeInvocation at h
  simp only [bind, Except.bind, Except.mapError, pure, Except.pure] at h
  split at h
  · contradiction
  rename_i pair hl
  rcases pair with ⟨component, iface⟩
  split at h
  · contradiction
  rename_i template ht
  split at h
  · contradiction
  rename_i reads hr
  split at h
  · contradiction
  rename_i writes hw
  split at h
  · contradiction
  rename_i token hc
  cases token
  have unmap {E F X : Type} (f : E → F) (x : Except E X) (v : X)
      (hx : x.mapError f = .ok v) : x = .ok v := by
    cases x <;> simp_all [Except.mapError]
  exact ⟨component, iface, template, reads, writes, hl, ht,
    unmap _ _ _ hr, unmap _ _ _ hw, unmap _ _ _ hc, (Except.ok.inj h).symm⟩
omit [DecidableEq P] [DecidableEq A] [DecidableEq D] in
theorem resolveRefs_member (caller : P) (parties : List P)
    (refs : List (PackedCellRef P A D)) (cells : List (Cell P A D))
    (h : resolveRefs caller parties refs = .ok cells)
    (ref : PackedCellRef P A D) (hr : ref ∈ refs) :
    ∃ cell ∈ cells, ref.2.resolve caller parties = .ok cell := by
  induction refs generalizing cells with
  | nil => simp at hr
  | cons head tail ih =>
    simp only [resolveRefs, List.mapM_cons, bind, Except.bind] at h
    cases hh : head.2.resolve caller parties with
    | error e => simp [hh] at h
    | ok cell =>
      cases ht : resolveRefs caller parties tail with
      | error e =>
        simp only [resolveRefs] at ht
        simp [hh, ht] at h
      | ok rest =>
        have htt := ht
        simp only [resolveRefs] at ht
        simp only [hh, ht, pure, Except.pure,
          Except.ok.injEq] at h
        subst cells
        rcases List.mem_cons.mp hr with he | hm
        · subst ref; exact ⟨cell, by simp, hh⟩
        · obtain ⟨c, hc, resolved⟩ := ih rest htt hm
          exact ⟨c, List.mem_cons_of_mem _ hc, resolved⟩
theorem analyzeBranchFrom_cons (cfg : Config P A D) (boundary : Nat → Boundary P A D)
    (index : Nat) (inv : Invocation P A D) (tail : Branch P A D) (fp : Footprint P A D)
    (h : analyzeBranchFrom cfg boundary index (inv :: tail) = .ok fp) :
    ∃ head rest, analyzeInvocation cfg (boundary index) inv = .ok head ∧
      analyzeBranchFrom cfg boundary (index + 1) tail = .ok rest ∧ fp = head.append rest := by
  unfold analyzeBranchFrom at h
  cases hh : analyzeInvocation cfg (boundary index) inv with
  | error e => simp [hh, Except.mapError, bind, Except.bind] at h
  | ok head =>
    cases ht : analyzeBranchFrom cfg boundary (index + 1) tail with
    | error e => simp [hh, ht, Except.mapError, bind, Except.bind] at h
    | ok rest =>
      simp only [hh, ht, Except.mapError, bind, Except.bind, pure, Except.pure,
        Except.ok.injEq] at h
      exact ⟨head, rest, rfl, rfl, h.symm⟩
theorem admit_ok (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (left right : Branch P A D) (lf rf : Footprint P A D)
    (h : admit cfg boundaries left right = .ok (lf, rf)) :
    validateCatalog cfg.registry cfg.catalog = true ∧
    analyzeBranch cfg (boundaries .left) left = .ok lf ∧
    analyzeBranch cfg (boundaries .right) right = .ok rf ∧ Compatible lf rf := by
  unfold admit at h
  simp only [bind, Except.bind, pure, Except.pure] at h
  split at h
  · simp [throw, throwThe] at h
  rename_i hv
  split at h
  · contradiction
  rename_i l hl
  split at h
  · contradiction
  rename_i r hr
  split at h
  · contradiction
  rename_i token hc
  cases token
  obtain ⟨rfl, rfl⟩ := Prod.mk.inj (Except.ok.inj h)
  have unmap {E F X : Type} (f : E → F) (x : Except E X) (v : X)
      (hx : x.mapError f = .ok v) : x = .ok v := by
    cases x <;> simp_all [Except.mapError]
  exact ⟨by simpa using hv, unmap _ _ _ hl, unmap _ _ _ hr,
    (checkCompatibility_ok_iff _ _).mp hc⟩

theorem admit_compatible (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (left right : Branch P A D) (lf rf : Footprint P A D)
    (h : admit cfg boundaries left right = .ok (lf, rf)) : Compatible lf rf :=
  (admit_ok cfg boundaries left right lf rf h).2.2.2

omit [DecidableEq P] [DecidableEq A] [DecidableEq D] in
theorem resolveRefs_mem_of_resolve (caller : P) (parties : List P)
    (refs : List (PackedCellRef P A D)) (cells : List (Cell P A D))
    (h : resolveRefs caller parties refs = .ok cells)
    (ref : PackedCellRef P A D) (hr : ref ∈ refs) (cell : Cell P A D)
    (resolved : ref.2.resolve caller parties = .ok cell) : cell ∈ cells := by
  obtain ⟨c, hc, he⟩ := resolveRefs_member caller parties refs cells h ref hr
  rw [resolved] at he
  cases he
  exact hc

omit [DecidableEq P] [DecidableEq A] [DecidableEq D] in
theorem resolveRefs_append_ok (caller : P) (parties : List P)
    (xs ys : List (PackedCellRef P A D)) (cells : List (Cell P A D))
    (h : resolveRefs caller parties (xs ++ ys) = .ok cells) :
    ∃ left right, resolveRefs caller parties xs = .ok left ∧
      resolveRefs caller parties ys = .ok right ∧ cells = left ++ right := by
  simp only [resolveRefs, List.mapM_append] at h
  change ((resolveRefs caller parties xs).bind fun left ↦
    (resolveRefs caller parties ys).bind fun right ↦ .ok (left ++ right)) = .ok cells at h
  cases hx : resolveRefs caller parties xs with
  | error e => simp [hx, Except.bind] at h
  | ok left =>
    cases hy : resolveRefs caller parties ys with
    | error e => simp [hx, hy, Except.bind] at h
    | ok right =>
      simp only [hx, hy, Except.bind, Except.ok.injEq] at h
      exact ⟨left, right, rfl, rfl, h.symm⟩

/-- Accepted analysis covers every syntactic/declared read, every potential write and target,
and every output, regardless of whether the invocation would execute successfully. -/
theorem analyzeInvocation_coverage (cfg : Config P A D) (boundary : Boundary P A D)
    (inv : Invocation P A D) (fp : Footprint P A D)
    (h : analyzeInvocation cfg boundary inv = .ok fp) :
    ∃ component iface template,
      lookupOperation cfg.catalog inv.component inv.operation = some (component, iface) ∧
      cfg.registry inv.operation = some template ∧
      (∀ ref ∈ template.requiredStateReads ++ template.stateReads,
        ∃ c ∈ fp.reads, ref.2.resolve boundary.ctx.principal inv.parties = .ok c) ∧
      (∀ ref ∈ template.writes ++ template.deltas.map (fun d ↦ ⟨d.asset, d.target⟩),
        ∃ c ∈ fp.writes, ref.2.resolve boundary.ctx.principal inv.parties = .ok c) ∧
      (∀ output ∈ iface.outputs, output.cell ∈ fp.reads) ∧
      (∀ c ∈ fp.writes, c ∈ fp.reads) := by
  obtain ⟨component, iface, template, reads, writes, hl, ht, hr, hw, _, rfl⟩ :=
    analyzeInvocation_ok cfg boundary inv fp h
  refine ⟨component, iface, template, hl, ht, ?_, ?_, ?_, ?_⟩
  · intro ref hm
    obtain ⟨c, hc, he⟩ := resolveRefs_member _ _ _ _ hr ref hm
    exact ⟨c, by simp [hc], he⟩
  · intro ref hm
    exact resolveRefs_member _ _ _ _ hw ref hm
  · intro output hm
    simp only [List.mem_append, List.mem_map]
    exact Or.inr ⟨output, hm, rfl⟩
  · intro c hc
    simp [hc]

theorem analyzeInvocation_writes_read (cfg : Config P A D) (boundary : Boundary P A D)
    (inv : Invocation P A D) (fp : Footprint P A D)
    (h : analyzeInvocation cfg boundary inv = .ok fp) :
    ∀ c ∈ fp.writes, c ∈ fp.reads := by
  obtain ⟨_, _, _, _, _, _, _, _, hw⟩ := analyzeInvocation_coverage cfg boundary inv fp h
  exact hw

/-- Every local invocation has its own analyzed footprint contained in the whole branch. -/
theorem analyzeBranchFrom_member (cfg : Config P A D) (boundary : Nat → Boundary P A D)
    (index : Nat) (branch : Branch P A D) (fp : Footprint P A D)
    (h : analyzeBranchFrom cfg boundary index branch = .ok fp)
    (n : Nat) (inv : Invocation P A D) (atIndex : branch[n]? = some inv) :
    ∃ part, analyzeInvocation cfg (boundary (index + n)) inv = .ok part ∧
      (∀ c ∈ part.reads, c ∈ fp.reads) ∧ (∀ c ∈ part.writes, c ∈ fp.writes) := by
  induction branch generalizing index fp n with
  | nil => simp at atIndex
  | cons head tail ih =>
    obtain ⟨hf, tf, hh, ht, rfl⟩ := analyzeBranchFrom_cons _ _ _ _ _ _ h
    cases n with
    | zero =>
      simp only [List.getElem?_cons_zero, Option.some.injEq] at atIndex
      subst inv
      exact ⟨hf, by simpa using hh,
        fun c hc ↦ List.mem_append_left _ hc, fun c hc ↦ List.mem_append_left _ hc⟩
    | succ n =>
      simp only [List.getElem?_cons_succ] at atIndex
      obtain ⟨part, hl, hr, hw⟩ := ih (index + 1) tf ht n atIndex
      refine ⟨part, ?_, fun c hc ↦ List.mem_append_right _ (hr c hc),
        fun c hc ↦ List.mem_append_right _ (hw c hc)⟩
      simpa [Nat.add_assoc, Nat.add_comm, Nat.add_left_comm] using hl

end DefiKernel.Parallel


===== INPUT lean/DefiKernel/Parallel/Dependency.lean ORIGINAL_SHA256 72867fdcc9d076bc1beaa6b9cd38a4f75fff9087f703cde1bf3db01760ceb245 RENDERED_SHA256 72867fdcc9d076bc1beaa6b9cd38a4f75fff9087f703cde1bf3db01760ceb245 =====
import DefiKernel.Composition.Contracts

/-! Complete evaluation and execution dependence on resolved reads and potential delta targets.
No successful footprint check is assumed in the refusal proofs. -/
namespace DefiKernel.Parallel
open Typed Composition

variable {P A D : Type} [DecidableEq P] [DecidableEq A] [DecidableEq D]

def ResolvedReadsAgree (template : Template P A D) (caller : P) (parties : List P)
    (left right : State P A D) : Prop :=
  ∀ ref ∈ template.requiredStateReads, ∀ c,
    ref.2.resolve caller parties = .ok c → left.balance c = right.balance c

def TargetsWithin (template : Template P A D) (caller : P) (parties : List P)
    (region : Set (Cell P A D)) : Prop :=
  ∀ d ∈ template.deltas, ∀ c, d.target.resolve caller parties = .ok c → c ∈ region

-- BEGIN PROOFS

omit [DecidableEq P] [DecidableEq D] in
/-- Complete expression results agree on a resolved syntactic read region. -/
theorem expression_congr_of_region {signature : List (Unit A)} {u : Unit A}
    (expression : Expr P A D signature u) (left right : State P A D)
    (env : Environment A D) (caller : P) (parties : List P) (args : Args signature) (now : Nat)
    (region : Set (Cell P A D)) (ha : AgreeOn region left right)
    (hr : ∀ ref ∈ expression.stateReads, ∀ c,
      ref.2.resolve caller parties = .ok c → c ∈ region) :
    expression.eval ⟨left, env, caller, parties, args, now⟩ =
      expression.eval ⟨right, env, caller, parties, args, now⟩ := by
  apply expression.eval_congr_of_resolved
    ⟨left, env, caller, parties, args, now⟩
    ⟨right, env, caller, parties, args, now⟩ rfl rfl rfl
  · intro ref hm c hc
    exact ha c (hr ref hm c hc)
  · intro key hk
    cases key <;> rfl

theorem mapM_congr_on {α β ε : Type} (xs : List α) (f g : α → Except ε β)
    (h : ∀ x ∈ xs, f x = g x) : xs.mapM f = xs.mapM g := by
  induction xs with
  | nil => rfl
  | cons x xs ih =>
    simp only [List.mapM_cons, h x (by simp), ih (fun y hy ↦ h y (by simp [hy]))]

theorem mapM_ok_mem {α β ε : Type} (xs : List α) (f : α → Except ε β)
    (ys : List β) (h : xs.mapM f = .ok ys) :
    ∀ y ∈ ys, ∃ x ∈ xs, f x = .ok y := by
  induction xs generalizing ys with
  | nil =>
    have hy : ys = [] := (Except.ok.inj h).symm
    subst ys
    simp
  | cons x xs ih =>
    rw [List.mapM_cons] at h
    cases hx : f x <;> simp only [hx, bind, Except.bind] at h
    · contradiction
    rename_i z
    cases ht : xs.mapM f <;> simp only [ht, bind, Except.bind, pure, Except.pure] at h
    · contradiction
    cases h
    intro y hy
    rcases List.mem_cons.mp hy with rfl | hy
    · exact ⟨x, by simp, hx⟩
    · obtain ⟨a, ha, hf⟩ := ih _ ht y hy
      exact ⟨a, by simp [ha], hf⟩

theorem evaluate_congr (template : Template P A D) (left right : State P A D)
    (env : Environment A D) (caller : P) (parties : List P)
    (args : Args template.signature) (now : Nat)
    (h : ResolvedReadsAgree template caller parties left right) :
    template.evaluate ⟨left, env, caller, parties, args, now⟩ =
      template.evaluate ⟨right, env, caller, parties, args, now⟩ := by
  have expr {u : Unit A} (e : Expr P A D template.signature u)
      (he : ∀ ref ∈ e.stateReads, ref ∈ template.requiredStateReads) :
      e.eval ⟨left, env, caller, parties, args, now⟩ =
        e.eval ⟨right, env, caller, parties, args, now⟩ := by
    apply e.eval_congr_of_resolved
      ⟨left, env, caller, parties, args, now⟩
      ⟨right, env, caller, parties, args, now⟩ rfl rfl rfl
    · intro ref hr c hc
      exact h ref (he ref hr) c hc
    · intro key hk
      cases key <;> rfl
  have hg := expr template.guard (by intros; simp_all [Template.requiredStateReads])
  have hd := mapM_congr_on template.deltas
    (fun d ↦ do
      let c ← d.target.resolve caller parties
      let a ← d.amount.eval ⟨left, env, caller, parties, args, now⟩
      pure (c, a))
    (fun d ↦ do
      let c ← d.target.resolve caller parties
      let a ← d.amount.eval ⟨right, env, caller, parties, args, now⟩
      pure (c, a)) (by
        intro d hd
        rw [expr d.amount (by
          intro ref hr
          simp only [Template.requiredStateReads, List.mem_append, List.mem_flatMap]
          exact Or.inl (Or.inr ⟨d, hd, hr⟩))])
  have hs := mapM_congr_on template.supplyDeltas
    (fun d ↦ do
      let a ← d.amount.eval ⟨left, env, caller, parties, args, now⟩
      pure ((d.domain, d.asset), a))
    (fun d ↦ do
      let a ← d.amount.eval ⟨right, env, caller, parties, args, now⟩
      pure ((d.domain, d.asset), a)) (by
        intro d hd
        rw [expr d.amount (by
          intro ref hr
          simp only [Template.requiredStateReads, List.mem_append, List.mem_flatMap]
          exact Or.inr ⟨d, hd, hr⟩)])
  unfold Template.evaluate
  rw [hg, hd, hs]

theorem evaluated_targets (template : Template P A D)
    (ctx : EvalContext P A D template.signature) (e : Evaluated P A D)
    (h : template.evaluate ctx = .ok e) :
    ∀ entry ∈ e.deltas, ∃ d ∈ template.deltas,
      d.target.resolve ctx.caller ctx.parties = .ok entry.1 := by
  unfold Template.evaluate at h
  simp only [bind, Except.bind, pure, Except.pure] at h
  split at h
  · contradiction
  split at h
  · contradiction
  split at h
  · contradiction
  split at h
  · contradiction
  split at h
  · contradiction
  rename_i deltas hd
  split at h
  · contradiction
  cases h
  intro entry he
  obtain ⟨d, hm, hv⟩ := mapM_ok_mem _ _ _ hd entry he
  refine ⟨d, hm, ?_⟩
  cases hc : d.target.resolve ctx.caller ctx.parties <;>
    simp only [hc, bind, Except.bind] at hv
  · contradiction
  cases ha : d.amount.eval ctx <;> simp only [ha, bind, Except.bind] at hv
  · contradiction
  cases hv
  rfl

theorem evaluated_effect_zero_outside (template : Template P A D)
    (ctx : EvalContext P A D template.signature) (e : Evaluated P A D)
    (h : template.evaluate ctx = .ok e) (region : Set (Cell P A D))
    (ht : TargetsWithin template ctx.caller ctx.parties region)
    (c : Cell P A D) (hc : c ∉ region) : e.effect c = 0 := by
  apply List.sum_eq_zero
  intro v hv
  obtain ⟨entry, he, rfl⟩ := List.mem_map.mp hv
  have hn : entry.1 ≠ c := by
    intro eq
    obtain ⟨d, hd, hr⟩ := evaluated_targets template ctx e h entry he
    exact hc (eq ▸ ht d hd entry.1 hr)
  simp [hn]

variable [Fintype P] [Fintype A] [Fintype D]

/-- Equality on potential targets suffices even if accounting or writes later refuse. -/
theorem funds_iff (left right : State P A D) (e : Evaluated P A D)
    (region : Set (Cell P A D)) (ha : AgreeOn region left right)
    (hz : ∀ c, c ∉ region → e.effect c = 0) :
    (∀ c, 0 ≤ left.balance c + e.effect c) ↔
      (∀ c, 0 ≤ right.balance c + e.effect c) := by
  constructor
  · intro h c
    by_cases hc : c ∈ region
    · rw [← ha c hc]
      exact h c
    · simpa [hz c hc] using right.nonneg c
  · intro h c
    by_cases hc : c ∈ region
    · rw [ha c hc]
      exact h c
    · simpa [hz c hc] using left.nonneg c

/-- Success compares the protected region and fixed store; errors compare exact constructors. -/
def ExecutionAgrees (region : Set (Cell P A D)) :
    Except Typed.Refusal (ExecutionResult P A D) →
    Except Typed.Refusal (ExecutionResult P A D) → Prop
  | .error a, .error b => a = b
  | .ok a, .ok b => AgreeOn region a.state b.state ∧ a.capabilities = b.capabilities
  | _, _ => False

theorem applyEvaluated_congr (store : CapabilityStore P A D)
    (ctx : InvocationContext P D) (request : Request P A D)
    (left right : State P A D) (e : Evaluated P A D)
    (region : Set (Cell P A D)) (ha : AgreeOn region left right)
    (hz : ∀ c, c ∉ region → e.effect c = 0) :
    ExecutionAgrees region (applyEvaluated store ctx request left e)
      (applyEvaluated store ctx request right e) := by
  have hf := funds_iff left right e region ha hz
  by_cases hl : ∀ c, 0 ≤ left.balance c + e.effect c
  · have hr := hf.mp hl
    unfold applyEvaluated
    simp only [dif_pos hl, dif_pos hr]
    split_ifs <;> try rfl
    exact ⟨fun c hc ↦ congrArg (fun q ↦ q + e.effect c) (ha c hc), rfl⟩
  · have hr : ¬ ∀ c, 0 ≤ right.balance c + e.effect c := fun h ↦ hl (hf.mpr h)
    unfold applyEvaluated
    simp only [dif_neg hl, dif_neg hr]
    split_ifs <;> rfl

/-- Complete registered execution dependence, including every exact refusal. -/
theorem execute_congr (registry : Registry P A D) (store : CapabilityStore P A D)
    (ctx : InvocationContext P D) (env : Environment A D) (now : Nat)
    (request : Request P A D) (left right : State P A D) (region : Set (Cell P A D))
    (ha : AgreeOn region left right)
    (hr : ∀ template, registry request.operation = some template →
      ResolvedReadsAgree template ctx.principal request.parties left right)
    (ht : ∀ template, registry request.operation = some template →
      TargetsWithin template ctx.principal request.parties region) :
    ExecutionAgrees region (Typed.execute registry store ctx env now request left)
      (Typed.execute registry store ctx env now request right) := by
  unfold Typed.execute
  cases hs : registry request.operation with
  | none => rfl
  | some template =>
    simp only [bind, Except.bind]
    split_ifs <;> (try simp only [throw, throwThe, bind, Except.bind])
    all_goals try rfl
    all_goals
      cases argsOk : Args.check template.signature request.arguments <;>
        simp only [Except.mapError, bind, Except.bind]
    all_goals try rfl
    rename_i args
    have he := evaluate_congr template left right env ctx.principal request.parties args now
      (hr template hs)
    rw [← he]
    cases ev : template.evaluate ⟨left, env, ctx.principal, request.parties, args, now⟩ with
    | error reason => rfl
    | ok e =>
      simp only [Except.mapError, bind, Except.bind]
      exact applyEvaluated_congr store ctx request left right e region ha
        (evaluated_effect_zero_outside template _ e ev region (ht template hs))

theorem execute_refusal_iff (registry : Registry P A D) (store : CapabilityStore P A D)
    (ctx : InvocationContext P D) (env : Environment A D) (now : Nat)
    (request : Request P A D) (left right : State P A D) (region : Set (Cell P A D))
    (ha : AgreeOn region left right)
    (hr : ∀ template, registry request.operation = some template →
      ResolvedReadsAgree template ctx.principal request.parties left right)
    (ht : ∀ template, registry request.operation = some template →
      TargetsWithin template ctx.principal request.parties region) (reason : Typed.Refusal) :
    Typed.execute registry store ctx env now request left = .error reason ↔
      Typed.execute registry store ctx env now request right = .error reason := by
  have h := execute_congr registry store ctx env now request left right region ha hr ht
  cases hl : Typed.execute registry store ctx env now request left <;>
    cases hh : Typed.execute registry store ctx env now request right <;>
    simp_all [ExecutionAgrees]

theorem execute_success_congr (registry : Registry P A D) (store : CapabilityStore P A D)
    (ctx : InvocationContext P D) (env : Environment A D) (now : Nat)
    (request : Request P A D) (left right : State P A D) (region : Set (Cell P A D))
    (ha : AgreeOn region left right)
    (hr : ∀ template, registry request.operation = some template →
      ResolvedReadsAgree template ctx.principal request.parties left right)
    (ht : ∀ template, registry request.operation = some template →
      TargetsWithin template ctx.principal request.parties region)
    (post : ExecutionResult P A D)
    (hx : Typed.execute registry store ctx env now request left = .ok post) :
    ∃ other, Typed.execute registry store ctx env now request right = .ok other ∧
      AgreeOn region post.state other.state ∧ post.capabilities = store ∧
      other.capabilities = store := by
  have h := execute_congr registry store ctx env now request left right region ha hr ht
  rw [hx] at h
  cases hh : Typed.execute registry store ctx env now request right with
  | error reason => simp [hh, ExecutionAgrees] at h
  | ok other =>
    rw [hh] at h
    have hp := execute_preserves_capabilities registry store ctx env now request left post hx
    have ho := execute_preserves_capabilities registry store ctx env now request right other hh
    exact ⟨other, rfl, h.1, hp, ho⟩

/-- Each success frames its own input outside potential targets, regardless of foreign balances. -/
theorem execute_target_frame (registry : Registry P A D) (store : CapabilityStore P A D)
    (ctx : InvocationContext P D) (env : Environment A D) (now : Nat)
    (request : Request P A D) (pre : State P A D) (post : ExecutionResult P A D)
    (region : Set (Cell P A D))
    (ht : ∀ template, registry request.operation = some template →
      TargetsWithin template ctx.principal request.parties region)
    (hx : Typed.execute registry store ctx env now request pre = .ok post) :
    ∀ c, c ∉ region → post.state.balance c = pre.balance c := by
  obtain ⟨template, hs, args, _, e, he, happly⟩ :=
    execute_evaluated registry store ctx env now request pre post hx
  have hp := (applyEvaluated_ok_iff store ctx request pre e post).mp happly
  intro c hc
  rw [hp.2.2 c, evaluated_effect_zero_outside template _ e he region (ht template hs) c hc]
  exact add_zero _

end DefiKernel.Parallel


===== INPUT lean/DefiKernel/Parallel/Dependency/Adapter.lean ORIGINAL_SHA256 10f9658f56d4fae4d3eed01dd2c2ec78460ed275120d6e6bd3ba9bd90ba00d4c RENDERED_SHA256 10f9658f56d4fae4d3eed01dd2c2ec78460ed275120d6e6bd3ba9bd90ba00d4c =====
import DefiKernel.Parallel.Dependency
import DefiKernel.Parallel.Compatibility

/-! State dependence for the existing composition adapter, with same-prestate receipts and
selected post-state snapshots. Boundaries and local histories are identical inputs. -/
namespace DefiKernel.Parallel
open Typed Composition

variable {P A D : Type} [DecidableEq P] [DecidableEq A] [DecidableEq D]
variable [Fintype P] [Fintype A] [Fintype D]

-- BEGIN PROOFS

theorem prepareInvocation_shape (cfg : Config P A D) (boundary : Boundary P A D)
    (index : Nat) (history : List (OutputObservation A)) (inv : Invocation P A D)
    (iface : OperationInterface P A D) (request : Request P A D)
    (h : prepareInvocation cfg boundary index history inv = .ok (iface, request)) :
    request.operation = inv.operation ∧ request.parties = inv.parties ∧
      ∃ component, lookupOperation cfg.catalog inv.component inv.operation =
        some (component, iface) := by
  unfold prepareInvocation at h
  simp only [bind, Except.bind, Except.mapError, pure, Except.pure] at h
  split at h
  · contradiction
  rename_i pair hl
  rcases pair with ⟨component, selected⟩
  split at h
  · contradiction
  split at h
  · contradiction
  split at h
  · contradiction
  cases h
  exact ⟨rfl, rfl, component, hl⟩

theorem analyzed_dependencies (cfg : Config P A D) (boundary : Boundary P A D)
    (inv : Invocation P A D) (fp : Footprint P A D)
    (hf : analyzeInvocation cfg boundary inv = .ok fp)
    (template : Template P A D) (hs : cfg.registry inv.operation = some template) :
    (∀ ref ∈ template.requiredStateReads, ∀ c,
      ref.2.resolve boundary.ctx.principal inv.parties = .ok c → c ∈ fp.reads) ∧
    TargetsWithin template boundary.ctx.principal inv.parties {c | c ∈ fp.writes} ∧
    (∀ c ∈ fp.writes, c ∈ fp.reads) := by
  obtain ⟨component, iface, selected, reads, writes, hl, ht, hr, hw, hc, rfl⟩ :=
    analyzeInvocation_ok cfg boundary inv fp hf
  rw [hs] at ht
  cases ht
  refine ⟨?_, ?_, ?_⟩
  · intro ref hm c hres
    obtain ⟨cell, hm', hres'⟩ := resolveRefs_member _ _ _ _ hr ref (by simp [hm])
    rw [hres] at hres'
    cases hres'
    simp [hm']
  · intro d hd c hres
    obtain ⟨cell, hm', hres'⟩ := resolveRefs_member _ _ _ _ hw ⟨d.asset, d.target⟩
      (List.mem_append_right _ (List.mem_map.mpr ⟨d, hd, rfl⟩))
    rw [hres] at hres'
    cases hres'
    exact hm'
  · intros
    simp_all

theorem analyzed_outputs (cfg : Config P A D) (boundary : Boundary P A D)
    (inv : Invocation P A D) (fp : Footprint P A D)
    (hf : analyzeInvocation cfg boundary inv = .ok fp)
    (component : Component P A D) (iface : OperationInterface P A D)
    (hl : lookupOperation cfg.catalog inv.component inv.operation = some (component, iface)) :
    ∀ output ∈ iface.outputs, output.cell ∈ fp.reads := by
  obtain ⟨selected, si, template, reads, writes, hs, _, _, _, _, rfl⟩ :=
    analyzeInvocation_ok cfg boundary inv fp hf
  rw [hl] at hs
  cases hs
  intro output ho
  simp only [List.mem_append, List.mem_map]
  exact Or.inr ⟨output, ho, rfl⟩

theorem snapshots_congr (index : Nat) (component : ComponentId)
    (iface : OperationInterface P A D) (left right : State P A D)
    (h : ∀ output ∈ iface.outputs, left.balance output.cell = right.balance output.cell) :
    snapshots index component iface left = snapshots index component iface right := by
  unfold snapshots
  apply List.map_congr_left
  intro output ho
  simp only [h output ho]

theorem extractReceipt_congr (cfg : Config P A D) (boundary : Boundary P A D)
    (request : Request P A D) (left right : World P A D)
    (hr : ∀ template, cfg.registry request.operation = some template →
      ResolvedReadsAgree template boundary.ctx.principal request.parties left.state right.state) :
    extractReceipt cfg boundary request left = extractReceipt cfg boundary request right := by
  unfold extractReceipt
  cases hs : cfg.registry request.operation with
  | none => rfl
  | some template =>
    simp only [bind, Except.bind]
    cases ha : Args.check template.signature request.arguments with
    | error reason => rfl
    | ok args =>
      simp only [Except.mapError, bind, Except.bind]
      rw [evaluate_congr template left.state right.state boundary.env boundary.ctx.principal
        request.parties args boundary.now (hr template hs)]

def StepAgrees (region : Set (Cell P A D)) :
    Except Failure (StepResult P A D) → Except Failure (StepResult P A D) → Prop
  | .error a, .error b => a = b
  | .ok a, .ok b => AgreeOn region a.world.state b.world.state ∧
      a.world.capabilities = b.world.capabilities ∧ a.receipt = b.receipt ∧ a.outputs = b.outputs
  | _, _ => False

theorem executeStep_congr (cfg : Config P A D) (boundary : Boundary P A D)
    (index : Nat) (history : List (OutputObservation A)) (inv : Invocation P A D)
    (left right : World P A D) (fp : Footprint P A D) (region : Set (Cell P A D))
    (hf : analyzeInvocation cfg boundary inv = .ok fp)
    (hin : ∀ c ∈ fp.reads, c ∈ region) (ha : AgreeOn region left.state right.state)
    (hcap : left.capabilities = right.capabilities) :
    StepAgrees region (executeStep cfg boundary index history (.invoke inv) left)
      (executeStep cfg boundary index history (.invoke inv) right) := by
  unfold executeStep
  by_cases hv : validateCatalog cfg.registry cfg.catalog = true
  · simp only [hv, Bool.not_true, Bool.false_eq_true, ↓reduceIte, bind, Except.bind]
    cases hp : prepareInvocation cfg boundary index history inv with
    | error reason => rfl
    | ok pair =>
      rcases pair with ⟨iface, request⟩
      simp only [bind, Except.bind]
      obtain ⟨hop, hparties, component, hlookup⟩ := prepareInvocation_shape _ _ _ _ _ _ _ hp
      have hr : ∀ template, cfg.registry request.operation = some template →
          ResolvedReadsAgree template boundary.ctx.principal request.parties
            left.state right.state := by
        intro template hs ref href c hc
        rw [hop] at hs
        rw [hparties] at hc
        exact ha c (hin c ((analyzed_dependencies _ _ _ _ hf template hs).1 ref href c hc))
      have ht : ∀ template, cfg.registry request.operation = some template →
          TargetsWithin template boundary.ctx.principal request.parties region := by
        intro template hs d hd c hc
        rw [hop] at hs
        rw [hparties] at hc
        have dep := analyzed_dependencies _ _ _ _ hf template hs
        exact hin c (dep.2.2 c (dep.2.1 d hd c hc))
      have he := extractReceipt_congr cfg boundary request left right hr
      have hx := execute_congr cfg.registry left.capabilities boundary.ctx boundary.env boundary.now
        request left.state right.state region ha hr ht
      rw [← hcap]
      cases hleft : Typed.execute cfg.registry left.capabilities boundary.ctx boundary.env
          boundary.now request left.state <;>
        cases hright : Typed.execute cfg.registry left.capabilities boundary.ctx boundary.env
          boundary.now request right.state <;>
        simp only [hleft, hright, ExecutionAgrees] at hx
      · cases hx
        rfl
      · rename_i post other
        simp only [Except.mapError, bind, Except.bind]
        rw [← he]
        cases hrp : extractReceipt cfg boundary request left with
        | error reason => rfl
        | ok e =>
          exact ⟨hx.1, hx.2, rfl, snapshots_congr index inv.component iface _ _
            (fun output ho ↦ hx.1 output.cell
              (hin _ (analyzed_outputs _ _ _ _ hf _ _ hlookup output ho)))⟩
  · have hfalse : validateCatalog cfg.registry cfg.catalog = false := Bool.eq_false_iff.mpr hv
    simp only [hfalse, Bool.not_false, ↓reduceIte, bind, Except.bind]
    rfl

/-- Successful adapter execution changes only the analyzed write region. -/
theorem executeStep_target_frame (cfg : Config P A D) (boundary : Boundary P A D)
    (index : Nat) (history : List (OutputObservation A)) (inv : Invocation P A D)
    (pre : World P A D) (result : StepResult P A D) (fp : Footprint P A D)
    (hf : analyzeInvocation cfg boundary inv = .ok fp)
    (hx : executeStep cfg boundary index history (.invoke inv) pre = .ok result) :
    (∀ c, c ∉ fp.writes → result.world.state.balance c = pre.state.balance c) ∧
      result.world.capabilities = pre.capabilities := by
  have sound := executeStep_sound cfg boundary index history (.invoke inv) pre result hx
  cases sound with
  | invoke inv pre post iface request e hp he hex happly =>
    obtain ⟨hop, hparties, _⟩ := prepareInvocation_shape _ _ _ _ _ _ _ hp
    refine ⟨?_, execute_preserves_capabilities _ _ _ _ _ _ _ _ he⟩
    apply execute_target_frame cfg.registry pre.capabilities boundary.ctx boundary.env boundary.now
      request pre.state post {c | c ∈ fp.writes} _ he
    intro template hs
    rw [hop] at hs
    rw [hparties]
    exact (analyzed_dependencies _ _ _ _ hf template hs).2.1

theorem executeStep_refusal_iff (cfg : Config P A D) (boundary : Boundary P A D)
    (index : Nat) (history : List (OutputObservation A)) (inv : Invocation P A D)
    (left right : World P A D) (fp : Footprint P A D) (region : Set (Cell P A D))
    (hf : analyzeInvocation cfg boundary inv = .ok fp)
    (hin : ∀ c ∈ fp.reads, c ∈ region) (ha : AgreeOn region left.state right.state)
    (hcap : left.capabilities = right.capabilities) (reason : Failure) :
    executeStep cfg boundary index history (.invoke inv) left = .error reason ↔
      executeStep cfg boundary index history (.invoke inv) right = .error reason := by
  have h := executeStep_congr cfg boundary index history inv left right fp region hf hin ha hcap
  cases hl : executeStep cfg boundary index history (.invoke inv) left <;>
    cases hr : executeStep cfg boundary index history (.invoke inv) right <;>
    simp_all [StepAgrees]

end DefiKernel.Parallel


===== INPUT lean/DefiKernel/Parallel/Examples.lean ORIGINAL_SHA256 d4e1a5992e6e0e65ac89b1445e9d5d4d8675d95be279abc1340872c7c5b878cd RENDERED_SHA256 d4e1a5992e6e0e65ac89b1445e9d5d4d8675d95be279abc1340872c7c5b878cd =====
import DefiKernel.Parallel.Execution
import DefiKernel.Typed.Examples

/-! Independent financial fixtures for binary parallel composition. Expected receipts and complete
ledger tables are written directly, without evaluating templates or selecting executor results. -/
namespace DefiKernel.Parallel.Examples
open Typed Composition Typed.Examples
abbrev C := Cell Party Asset Domain
abbrev W := World Party Asset Domain
abbrev I := Invocation Party Asset Domain
abbrev B := Branch Party Asset Domain
abbrev Evt := EventObservation Party Asset Domain
abbrev Obs := BranchObservation Party Asset Domain
abbrev R := Parallel.Result Party Asset Domain

def aliceUSD : C := (.main, .alice, .usd)
def bobUSD : C := (.main, .bob, .usd)
def vaultUSD : C := (.main, .vault, .usd)
def poolUSD : C := (.main, .pool, .usd)
def vaultShare : C := (.main, .vault, .share)
def aliceShare : C := (.main, .alice, .share)
def protectedCell : C := (.main, .alice, .collateral)
def cells : List C := [Domain.main, .other].flatMap fun d ↦
  [Party.alice, .bob, .vault, .pool].flatMap fun p ↦
    [Asset.usd, .share, .collateral, .debt].map fun a ↦ (d, p, a)
def cellRef (c : C) : CellRef Party Asset Domain c.2.2 := ⟨c.1, .literal c.2.1⟩
def packed (c : C) : PackedCellRef Party Asset Domain := ⟨c.2.2, cellRef c⟩

/-- Both numerical ports are zero, but their components differ. The provider grants exact
access to every cell so access checks cannot mask the intended compatibility controls. -/
def config (lt rt : Op) (lo ro : List C := []) : Config Party Asset Domain where
  registry id := if id = ⟨10⟩ then some lt else if id = ⟨11⟩ then some rt else none
  domainAdmin := domainAdmin
  catalog := [
    ⟨⟨0⟩, [], [], cells.zipIdx.map (fun (c, n) ↦ ⟨⟨⟨2⟩, ⟨n⟩⟩, c, true⟩),
      [⟨⟨10⟩, lt.signature.zipIdx.map (fun (u, n) ↦ ⟨⟨n + 10⟩, u⟩),
        lo.zipIdx.map (fun (c, n) ↦ ⟨⟨n⟩, c⟩)⟩]⟩,
    ⟨⟨1⟩, [], [], cells.zipIdx.map (fun (c, n) ↦ ⟨⟨⟨2⟩, ⟨n⟩⟩, c, true⟩),
      [⟨⟨11⟩, rt.signature.zipIdx.map (fun (u, n) ↦ ⟨⟨n + 10⟩, u⟩),
        ro.zipIdx.map (fun (c, n) ↦ ⟨⟨n⟩, c⟩)⟩]⟩,
    ⟨⟨2⟩, [], cells.zipIdx.map (fun (c, n) ↦ ⟨⟨n⟩, c, true⟩), [], []⟩]

def transferTemplate (a : Asset) (sender recipient : PartyRef Party) : Op where
  signature := [.amount a]
  domain := .main
  partyArity := 0
  guard := nonnegative a (.arg .here)
  deltas := [⟨a, ref a sender, negate a (.arg .here)⟩,
    ⟨a, ref a recipient, .arg .here⟩]
  supplyDeltas := []
  stateReads := []
  envReads := []
  writes := [packedRef a sender, packedRef a recipient]
def usdTransfer := transferTemplate .usd (.literal .alice) (.literal .bob)
def shareTransfer := transferTemplate .share (.literal .vault) (.literal .alice)
def peerUSDTransfer := transferTemplate .usd (.literal .vault) (.literal .pool)
def cfg := config usdTransfer shareTransfer [bobUSD] [aliceShare]
def sameAssetCfg := config usdTransfer peerUSDTransfer [bobUSD] [poolUSD]

def store : Store := ⟨[
  ⟨⟨.alice, .main, ⟨10⟩, .invoke⟩, true⟩,
  ⟨⟨.alice, .main, ⟨10⟩, .debit aliceUSD⟩, true⟩,
  ⟨⟨.alice, .main, ⟨11⟩, .invoke⟩, true⟩,
  ⟨⟨.alice, .main, ⟨11⟩, .debit vaultShare⟩, true⟩,
  ⟨⟨.alice, .main, ⟨11⟩, .debit vaultUSD⟩, true⟩,
  ⟨⟨.alice, .main, ⟨10⟩, .changeSupply .main .usd⟩, true⟩,
  ⟨⟨.alice, .main, ⟨11⟩, .changeSupply .main .share⟩, true⟩,
  ⟨⟨.bob, .main, ⟨10⟩, .invoke⟩, true⟩,
  ⟨⟨.bob, .main, ⟨10⟩, .debit bobUSD⟩, true⟩,
  ⟨⟨.vault, .main, ⟨11⟩, .invoke⟩, true⟩,
  ⟨⟨.vault, .main, ⟨11⟩, .debit vaultShare⟩, true⟩,
  ⟨⟨.alice, .main, ⟨10⟩, .debit vaultUSD⟩, true⟩]⟩
def caps : List CapabilityId := (List.range 12).map CapabilityId.mk

def balanceTable (au bu vs ash : ℚ) (vu : ℚ := 20) (pu : ℚ := 1) : C → ℚ := fun c ↦
  if c = aliceUSD then au else if c = bobUSD then bu else if c = vaultShare then vs
  else if c = aliceShare then ash else if c = vaultUSD then vu else if c = poolUSD then pu
  else if c = protectedCell then 9 else 0

def initial : W := ⟨⟨balanceTable 10 0 20 0, by
  intro c
  simp only [balanceTable]
  repeat' split
  all_goals decide⟩, store⟩
def boundaries (_ : BranchId) (_ : Nat) : Boundary Party Asset Domain :=
  ⟨aliceContext, fresh, 100⟩

def invoke (component op : Nat) (a : Asset) (q : ℚ) : I :=
  ⟨⟨component⟩, ⟨op⟩, [], [.literal ⟨.amount a, q⟩], caps, none⟩
def usd (q : ℚ) := invoke 0 10 .usd q
def shares (q : ℚ) := invoke 1 11 .share q
def peerUSD (q : ℚ) := invoke 1 11 .usd q

def source (inv : I) (component : Nat) : I :=
  { inv with inputs := [.priorOutput 0 ⟨⟨component⟩, ⟨0⟩⟩] }

def output (index component : Nat) (a : Asset) (q : ℚ) : OutputObservation Asset :=
  ⟨index, ⟨⟨component⟩, ⟨0⟩⟩, ⟨.amount a, q⟩⟩

def evaluatedTransfer (sender recipient : C) (q : ℚ) : Evaluated Party Asset Domain :=
  ⟨true, [(sender, -q), (recipient, q)], [], [], [], [], [], [sender, recipient]⟩
def event (index : Nat) (inv : I) (args : List (PackedValue Asset))
    (evaluated : Evaluated Party Asset Domain) (outputs : List (OutputObservation Asset)) : Evt :=
  ⟨index, .invoke inv,
    .invoked ⟨inv.operation, inv.parties, args, inv.capabilityIds, inv.claimedActor⟩ evaluated,
    outputs⟩
def transferEvent (index : Nat) (inv : I) (sender recipient : C) (q : ℚ)
    (outputs : List (OutputObservation Asset)) : Evt :=
  event index inv [⟨.amount sender.2.2, q⟩] (evaluatedTransfer sender recipient q) outputs

def observed (events : List Evt)
    (failure : Option (LocatedFailure Party Asset Domain) := none) : Obs :=
  ⟨events, events.flatMap EventObservation.outputs, events.length, failure⟩
def failure (index : Nat) (inv : I) (reason : Composition.Failure) :
    Option (LocatedFailure Party Asset Domain) := some ⟨index, some (.invoke inv), reason⟩
def leftEvent (index : Nat) (q after : ℚ) : Evt :=
  transferEvent index (usd q) aliceUSD bobUSD q [output index 0 .usd after]
def rightEvent (index : Nat) (q after : ℚ) : Evt :=
  transferEvent index (shares q) vaultShare aliceShare q [output index 1 .share after]
def peerEvent (index : Nat) (q after : ℚ) : Evt :=
  transferEvent index (peerUSD q) vaultUSD poolUSD q [output index 1 .usd after]

def matchesExpected (actual : R) (balance : C → ℚ) (expectedLeft expectedRight : Obs)
    (expectedStore : Store := store) : Bool :=
  match actual with
  | .refused _ _ => false
  | .executed result =>
    decide ((∀ c, result.world.state.balance c = balance c) ∧
      result.world.capabilities = expectedStore ∧
      result.left.world.capabilities = expectedStore ∧
      result.right.world.capabilities = expectedStore ∧
      observeBranch result.left = expectedLeft ∧ observeBranch result.right = expectedRight)

def basicLeft : Obs := observed [leftEvent 0 3 3]
def basicRight : Obs := observed [rightEvent 0 4 4]

def supplyTemplate (a : Asset) (owner : Party) : Op where
  signature := [.amount a]
  domain := .main
  partyArity := 0
  guard := .lit true
  deltas := [⟨a, ref a (.literal owner), .arg .here⟩]
  supplyDeltas := [⟨.main, a, .arg .here⟩]
  stateReads := []
  envReads := []
  writes := [packedRef a (.literal owner)]
def supplyCfg := config (supplyTemplate .usd .alice) (supplyTemplate .share .vault)
  [aliceUSD] [vaultShare]
def supplyEvent (index : Nat) (inv : I) (cell : C) (q post : ℚ) : Evt :=
  event index inv [⟨.amount cell.2.2, q⟩]
    ⟨true, [(cell, q)], [((cell.1, cell.2.2), q)], [], [], [], [], [cell]⟩
    [output index inv.component.value cell.2.2 post]

def statefulTransfer : Op := { usdTransfer with
  guard := .binary (.le (.amount .usd)) (.lit 4) (.balance (cellRef aliceUSD))
  deltas := [⟨.usd, cellRef aliceUSD, .binary (.scale (.amount Asset.usd))
    (.lit (-1 / 2 : ℚ)) (.balance (cellRef aliceUSD))⟩,
    ⟨.usd, cellRef bobUSD, .binary (.scale (.amount Asset.usd))
      (.lit (1 / 2 : ℚ)) (.balance (cellRef aliceUSD))⟩]
  stateReads := [packed aliceUSD] }
def statefulCfg := config statefulTransfer shareTransfer [bobUSD] [aliceShare]
def statefulEvent (index : Nat) (amount post : ℚ) : Evt :=
  event index (usd 0) [⟨.amount .usd, 0⟩]
    { evaluatedTransfer aliceUSD bobUSD amount with
      requiredStateReads := [aliceUSD, aliceUSD, aliceUSD]
      declaredStateReads := [aliceUSD] }
    [output index 0 .usd post]

/-- State-dependent mint amount appears independently in both delta and supply evaluation. -/
def statefulSupply : Op := { supplyTemplate .share .vault with
  deltas := [⟨.share, cellRef vaultShare,
    .binary (.scale (.amount Asset.share)) (.lit (1 / 2 : ℚ)) (.balance (cellRef vaultShare))⟩]
  supplyDeltas := [⟨.main, .share,
    .binary (.scale (.amount Asset.share)) (.lit (1 / 2 : ℚ)) (.balance (cellRef vaultShare))⟩]
  stateReads := [packed vaultShare] }
def statefulSupplyEvent (index : Nat) (amount post : ℚ) : Evt :=
  event index (shares 0) [⟨.amount .share, 0⟩]
    ⟨true, [(vaultShare, amount)], [((.main, .share), amount)],
      [vaultShare, vaultShare], [], [vaultShare], [], [vaultShare]⟩
    [output index 1 .share post]

/-- Temporal values constrain the trusted invocation boundary; they do not set a price. -/
def timedTemplate (a : Asset) : Op where
  signature := [.amount a, .scalar]
  domain := .main
  partyArity := 1
  guard := .binary (.eq .scalar) .now (.arg (.there .here))
  deltas := [⟨a, ref a .caller, negate a (.arg .here)⟩,
    ⟨a, ref a (.argument 0), .arg .here⟩]
  supplyDeltas := []
  stateReads := []
  envReads := [.currentTime]
  writes := [packedRef a .caller, packedRef a (.argument 0)]
def timedCfg := config (timedTemplate .usd) (timedTemplate .share) [bobUSD] [aliceShare]
def timedBoundaries (branch : BranchId) (index : Nat) : Boundary Party Asset Domain :=
  match branch with
  | .left => ⟨⟨if index = 0 then .alice else .bob, .main⟩, fresh, 100 + index⟩
  | .right => ⟨⟨.vault, .main⟩, fresh, 200 + index⟩
def timedInvocation (component op : Nat) (a : Asset) (q time : ℚ) (recipient : Party) : I :=
  ⟨⟨component⟩, ⟨op⟩, [recipient],
    [.literal ⟨.amount a, q⟩, .literal ⟨.scalar, time⟩], caps, none⟩
def timedLeft : B := [timedInvocation 0 10 .usd 3 100 .bob,
  timedInvocation 0 10 .usd 1 101 .alice]
def timedRight : B := [timedInvocation 1 11 .share 4 200 .alice,
  timedInvocation 1 11 .share 2 201 .alice]
def timedEvent (index : Nat) (inv : I) (sender recipient : C) (q time post : ℚ) : Evt :=
  event index inv [⟨.amount sender.2.2, q⟩, ⟨.scalar, time⟩]
    { evaluatedTransfer sender recipient q with
      requiredEnvReads := [.currentTime], declaredEnvReads := [.currentTime] }
    [output index inv.component.value sender.2.2 post]
def timedExpectedLeft := observed [
  timedEvent 0 (timedInvocation 0 10 .usd 3 100 .bob) aliceUSD bobUSD 3 100 3,
  timedEvent 1 (timedInvocation 0 10 .usd 1 101 .alice) bobUSD aliceUSD 1 101 2]
def timedExpectedRight := observed [
  timedEvent 0 (timedInvocation 1 11 .share 4 200 .alice) vaultShare aliceShare 4 200 4,
  timedEvent 1 (timedInvocation 1 11 .share 2 201 .alice) vaultShare aliceShare 2 201 6]


def noOp : Op where
  signature := []
  domain := .main
  partyArity := 0
  guard := .lit true
  deltas := []
  supplyDeltas := []
  stateReads := []
  envReads := []
  writes := []
def noOpInvocation : I := { usd 0 with inputs := [] }
def noOpEvaluated : Evaluated Party Asset Domain := ⟨true, [], [], [], [], [], [], []⟩
def sharedReadCfg := config noOp noOp [protectedCell] []
def sharedReadExpected := observed [event 0 noOpInvocation [] noOpEvaluated
  [output 0 0 .collateral 9]]
def paramTemplate : Op := { transferTemplate .usd (.argument 0) (.argument 1) with
  partyArity := 2 }
def reusableCfg := config paramTemplate shareTransfer

def revokedStore : Store := ⟨store.entries.set 2 ⟨⟨.alice, .main, ⟨11⟩, .invoke⟩, false⟩⟩
def revokedInitial : W := ⟨initial.state, revokedStore⟩

def cancelling : Op := { noOp with
  deltas := [⟨.usd, cellRef aliceUSD, .lit 1⟩, ⟨.usd, cellRef aliceUSD, .lit (-1)⟩] }
def cancellingInvocation : I := { shares 0 with inputs := [] }
def cancellingExpected : Obs := observed [event 0 cancellingInvocation []
  ⟨true, [(aliceUSD, 1), (aliceUSD, -1)], [], [], [], [], [], []⟩ []]

end DefiKernel.Parallel.Examples


===== INPUT lean/DefiKernel/Parallel/Execution.lean ORIGINAL_SHA256 a4a863d71ddfc5fa057fb5b4c79021aa8d79720710ee7bd70f97f34d01e60089 RENDERED_SHA256 a4a863d71ddfc5fa057fb5b4c79021aa8d79720710ee7bd70f97f34d01e60089 =====
import DefiKernel.Parallel.Compatibility
import DefiKernel.Parallel.Observation

/-! Binary fork/join over invocation-only branches. Each branch retains its own successful
prefix and refusal. Serial references rerun the existing executor with fresh local histories. -/
namespace DefiKernel.Parallel
open Typed Composition

structure Joined (P A D : Type) where
  world : World P A D
  left : Cursor P A D
  right : Cursor P A D

inductive Result (P A D : Type) where
  | refused (reason : AdmissionFailure P A D) (world : World P A D)
  | executed (joined : Joined P A D)

variable {P A D : Type} [DecidableEq P] [DecidableEq A] [DecidableEq D]
variable [Fintype P] [Fintype A] [Fintype D]

/-- An admitted region chooses one complete balance, never a sum of branch base balances. -/
def mergeWorld (leftFootprint rightFootprint : Footprint P A D)
    (initial left right : World P A D) : World P A D :=
  ⟨⟨fun c ↦ if c ∈ leftFootprint.writes then left.state.balance c
      else if c ∈ rightFootprint.writes then right.state.balance c
      else initial.state.balance c,
    fun c ↦ by
      split
      · exact left.state.nonneg c
      · split
        · exact right.state.nonneg c
        · exact initial.state.nonneg c⟩,
    initial.capabilities⟩

def runBranch (cfg : Config P A D) (boundary : Nat → Boundary P A D)
    (initial : World P A D) (branch : Branch P A D) : Cursor P A D :=
  Composition.run cfg boundary initial (branch.map Step.invoke)

def runParallel (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (initial : World P A D) (left right : Branch P A D) : Result P A D :=
  match admit cfg boundaries left right with
  | .error reason => .refused reason initial
  | .ok (leftFootprint, rightFootprint) =>
    let l := runBranch cfg (boundaries .left) initial left
    let r := runBranch cfg (boundaries .right) initial right
    .executed ⟨mergeWorld leftFootprint rightFootprint initial l.world r.world, l, r⟩

/-- Right always runs after left's retained prefix, including when left has refused. -/
def runSerialLR (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (initial : World P A D) (left right : Branch P A D) : Result P A D :=
  match admit cfg boundaries left right with
  | .error reason => .refused reason initial
  | .ok _ =>
    let l := runBranch cfg (boundaries .left) initial left
    let r := runBranch cfg (boundaries .right) l.world right
    .executed ⟨r.world, l, r⟩

/-- Evaluation order changes; branch labels, local history and trusted positions do not. -/
def runSerialRL (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (initial : World P A D) (left right : Branch P A D) : Result P A D :=
  match admit cfg boundaries left right with
  | .error reason => .refused reason initial
  | .ok _ =>
    let r := runBranch cfg (boundaries .right) initial right
    let l := runBranch cfg (boundaries .left) r.world left
    .executed ⟨l.world, l, r⟩

/-- Pointwise full-ledger equality plus exact capability-store equality. -/
def WorldEquivalent (left right : World P A D) : Prop :=
  (∀ c, left.state.balance c = right.state.balance c) ∧
    left.capabilities = right.capabilities

/-- Raw event worlds are omitted, but every financial and local refusal observation is kept. -/
def ObservationallyEquivalent (left right : Result P A D) : Prop :=
  match left, right with
  | .refused le lw, .refused re rw => le = re ∧ WorldEquivalent lw rw
  | .executed l, .executed r => WorldEquivalent l.world r.world ∧
      observeBranch l.left = observeBranch r.left ∧
      observeBranch l.right = observeBranch r.right
  | _, _ => False

def worldEq (left right : World P A D) : Bool :=
  decide ((∀ c, left.state.balance c = right.state.balance c) ∧
    left.capabilities = right.capabilities)

def observationsEqual (left right : Result P A D) : Bool :=
  match left, right with
  | .refused le lw, .refused re rw => decide (le = re) && worldEq lw rw
  | .executed l, .executed r => worldEq l.world r.world &&
      decide (observeBranch l.left = observeBranch r.left) &&
      decide (observeBranch l.right = observeBranch r.right)
  | _, _ => false

-- BEGIN PROOFS

omit [Fintype P] [Fintype A] [Fintype D] in
theorem mergeWorld_store (lf rf : Footprint P A D) (initial left right : World P A D) :
    (mergeWorld lf rf initial left right).capabilities = initial.capabilities := rfl

omit [Fintype P] [Fintype A] [Fintype D] in
theorem mergeWorld_nonnegative (lf rf : Footprint P A D)
    (initial left right : World P A D) (c : Cell P A D) :
    0 ≤ (mergeWorld lf rf initial left right).state.balance c :=
  (mergeWorld lf rf initial left right).state.nonneg c

omit [Fintype P] [Fintype A] [Fintype D] in
theorem mergeWorld_outside (lf rf : Footprint P A D) (initial left right : World P A D)
    (c : Cell P A D) (hl : c ∉ lf.writes) (hr : c ∉ rf.writes) :
    (mergeWorld lf rf initial left right).state.balance c = initial.state.balance c := by
  simp [mergeWorld, hl, hr]

theorem worldEq_iff (left right : World P A D) :
    worldEq left right = true ↔ WorldEquivalent left right := by simp [worldEq, WorldEquivalent]

theorem observationsEqual_iff (left right : Result P A D) :
    observationsEqual left right = true ↔ ObservationallyEquivalent left right := by
  cases left <;> cases right <;>
    simp [observationsEqual, ObservationallyEquivalent, worldEq, WorldEquivalent, and_assoc]

theorem runParallel_refuses (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (initial : World P A D) (left right : Branch P A D) (reason : AdmissionFailure P A D)
    (h : admit cfg boundaries left right = .error reason) :
    runParallel cfg boundaries initial left right = .refused reason initial := by
  simp [runParallel, h]

omit [DecidableEq P] [DecidableEq A] [DecidableEq D] [Fintype P] [Fintype A] [Fintype D] in
theorem WorldEquivalent.refl (world : World P A D) : WorldEquivalent world world :=
  ⟨fun _ ↦ rfl, rfl⟩

omit [DecidableEq P] [DecidableEq A] [DecidableEq D] [Fintype P] [Fintype A] [Fintype D] in
theorem WorldEquivalent.symm {left right : World P A D} (h : WorldEquivalent left right) :
    WorldEquivalent right left := ⟨fun c ↦ (h.1 c).symm, h.2.symm⟩

omit [DecidableEq P] [DecidableEq A] [DecidableEq D] [Fintype P] [Fintype A] [Fintype D] in
theorem WorldEquivalent.trans {first middle last : World P A D}
    (h : WorldEquivalent first middle) (g : WorldEquivalent middle last) :
    WorldEquivalent first last := ⟨fun c ↦ (h.1 c).trans (g.1 c), h.2.trans g.2⟩

omit [DecidableEq P] [DecidableEq A] [DecidableEq D] [Fintype P] [Fintype A] [Fintype D] in
theorem ObservationallyEquivalent.refl (result : Result P A D) :
    ObservationallyEquivalent result result := by
  cases result with
  | refused reason world => exact ⟨rfl, .refl world⟩
  | executed joined => exact ⟨.refl joined.world, rfl, rfl⟩

omit [DecidableEq P] [DecidableEq A] [DecidableEq D] [Fintype P] [Fintype A] [Fintype D] in
theorem ObservationallyEquivalent.symm {left right : Result P A D}
    (h : ObservationallyEquivalent left right) : ObservationallyEquivalent right left := by
  cases left <;> cases right
  · exact ⟨h.1.symm, h.2.symm⟩
  · exact h.elim
  · exact h.elim
  · exact ⟨h.1.symm, h.2.1.symm, h.2.2.symm⟩

omit [DecidableEq P] [DecidableEq A] [DecidableEq D] [Fintype P] [Fintype A] [Fintype D] in
theorem ObservationallyEquivalent.trans {first middle last : Result P A D}
    (h : ObservationallyEquivalent first middle) (g : ObservationallyEquivalent middle last) :
    ObservationallyEquivalent first last := by
  cases first <;> cases middle <;> cases last
  · exact ⟨h.1.trans g.1, h.2.trans g.2⟩
  · exact g.elim
  · exact h.elim
  · exact h.elim
  · exact h.elim
  · exact h.elim
  · exact g.elim
  · exact ⟨h.1.trans g.1, h.2.1.trans g.2.1, h.2.2.trans g.2.2⟩

end DefiKernel.Parallel


===== INPUT lean/DefiKernel/Parallel/ObservationTests.lean ORIGINAL_SHA256 227c4e8e63bfaa66394e8e5946cea5650787651ed2ea6a42cf63a1edada5864e RENDERED_SHA256 227c4e8e63bfaa66394e8e5946cea5650787651ed2ea6a42cf63a1edada5864e =====
import DefiKernel.Parallel.Execution
import DefiKernel.Composition.Examples

namespace DefiKernel.Parallel.ObservationTests
open Typed Typed.Examples Composition Composition.Examples

def emptyCursor : Cursor Party Asset Domain := startCursor cfg initialWorld

def refusal (index : Nat) (reason : Failure) : Cursor Party Asset Domain :=
  { emptyCursor with failure := some ⟨index, none, reason⟩ }

def invocation : Invocation Party Asset Domain :=
  ⟨⟨0⟩, transferId, [.bob], [.literal ⟨.amount .usd, 3⟩], allCapabilityIds, none⟩

def request : Request Party Asset Domain :=
  ⟨transferId, [.bob], [⟨.amount .usd, 3⟩], allCapabilityIds, none⟩

def evaluated : Evaluated Party Asset Domain :=
  ⟨true, [(aliceUsd, -3), (bobUsd, 3)], [], [], [], [], [], [aliceUsd, bobUsd]⟩

def output : OutputObservation Asset := ⟨0, ⟨⟨0⟩, ⟨1⟩⟩, ⟨.amount .usd, 7⟩⟩

def event : Event Party Asset Domain :=
  ⟨0, .invoke invocation, initialWorld, ⟨initialWorld, .invoked request evaluated, [output]⟩⟩

def changedWorld : World Party Asset Domain := ⟨transferred, expectedStore⟩

def receiptChanges : List (String × Receipt Party Asset Domain) := [
  ("kind", .issued ⟨0⟩),
  ("request", .invoked { request with claimedActor := some .bob } evaluated),
  ("guard", .invoked request { evaluated with guard := false }),
  ("deltas", .invoked request { evaluated with deltas := [(aliceUsd, -4), (bobUsd, 4)] }),
  ("supplies", .invoked request { evaluated with supplies := [((.main, .usd), 1)] }),
  ("required-state", .invoked request { evaluated with requiredStateReads := [aliceUsd] }),
  ("required-env", .invoked request { evaluated with requiredEnvReads := [.currentTime] }),
  ("declared-state", .invoked request { evaluated with declaredStateReads := [aliceUsd] }),
  ("declared-env", .invoked request { evaluated with declaredEnvReads := [.currentTime] }),
  ("writes", .invoked request { evaluated with writes := [aliceUsd] })]

def checks : List (String × Bool) := [
  ("parallel.observe.empty", decide (observeBranch emptyCursor = ⟨[], [], 0, none⟩)),
  ("parallel.observe.refusal-reason", decide
    (observeBranch (refusal 0 (.kernel .guard)) ≠
      observeBranch (refusal 0 (.kernel .insufficientFunds)))),
  ("parallel.observe.refusal-index", decide
    (observeBranch (refusal 0 (.kernel .guard)) ≠
      observeBranch (refusal 1 (.kernel .guard)))),
  ("parallel.observe.refusal-step", decide
    (observeBranch (refusal 0 (.kernel .guard)) ≠
      observeBranch { emptyCursor with failure := some ⟨0, some (.invoke invocation),
        .kernel .guard⟩ })),
  ("parallel.observe.local-index", decide
    (observeBranch emptyCursor ≠ observeBranch { emptyCursor with nextIndex := 1 })),
  ("parallel.observe.history", decide
    (observeBranch emptyCursor ≠ observeBranch { emptyCursor with outputs := [output] })),
  ("parallel.observe.event-index", decide
    (observeEvent event ≠ observeEvent { event with index := 1 })),
  ("parallel.observe.event-step", decide
    (observeEvent event ≠ observeEvent { event with step :=
      (.invoke { invocation with parties := [.vault] }) })),
  ("parallel.observe.event-outputs", decide
    (observeEvent event ≠ observeEvent
      { event with result := { event.result with outputs := [] } })),
  ("parallel.observe.output-unit", decide
    (observeEvent event ≠ observeEvent { event with result := { event.result with
      outputs := [{ output with value := ⟨.amount .share, 7⟩ }] } })),
  ("parallel.observe.output-value", decide
    (observeEvent event ≠ observeEvent { event with result := { event.result with
      outputs := [{ output with value := ⟨.amount .usd, 8⟩ }] } })),
  ("parallel.observe.raw-world-context", decide
    (observeEvent event = observeEvent { event with
      before := changedWorld
      result := { event.result with world := changedWorld } })),
  ("parallel.observe.final-ledger", !(worldEq initialWorld changedWorld)),
  ("parallel.observe.final-store", !(worldEq initialWorld
    { initialWorld with capabilities := ⟨[]⟩ }))] ++
  receiptChanges.map fun (label, receipt) ↦
    ("parallel.observe.receipt." ++ label, decide
      (observeEvent event ≠ observeEvent { event with result := { event.result with receipt } }))

end DefiKernel.Parallel.ObservationTests


===== INPUT lean/DefiKernel/Parallel/Preservation.lean ORIGINAL_SHA256 faa047bf614306b00cafc7c4b9278df070b9edb9b26f4d655e68af11a182fa10 RENDERED_SHA256 faa047bf614306b00cafc7c4b9278df070b9edb9b26f4d655e68af11a182fa10 =====
import DefiKernel.Parallel.Commutation
import DefiKernel.Composition.Preservation

/-! Joined accounting, point-of-use authority in the fixed input store, and supported ledger
invariants. Nonnegativity is proof-carrying; initialization and local preservation are premises. -/
namespace DefiKernel.Parallel
open Typed Composition

variable {P A D : Type} [DecidableEq P] [DecidableEq A] [DecidableEq D]
variable [Fintype P] [Fintype A] [Fintype D]

/-- Net supply from both actual successful branch receipt sequences, including refused prefixes. -/
def Joined.supply (joined : Joined P A D) (domain : D) (asset : A) : ℚ :=
  traceSupply joined.left.events domain asset + traceSupply joined.right.events domain asset

-- BEGIN PROOFS

theorem mergeWorld_balance_sum (lf rf : Footprint P A D) (initial left right : World P A D)
    (hd : ∀ c ∈ lf.writes, c ∉ rf.writes)
    (hl : ∀ c, c ∉ lf.writes → left.state.balance c = initial.state.balance c)
    (hr : ∀ c, c ∉ rf.writes → right.state.balance c = initial.state.balance c)
    (c : Cell P A D) :
    (mergeWorld lf rf initial left right).state.balance c =
      left.state.balance c + right.state.balance c - initial.state.balance c := by
  by_cases hcl : c ∈ lf.writes
  · simp [mergeWorld, hcl, hr c (hd c hcl)]
  · by_cases hcr : c ∈ rf.writes
    · simp [mergeWorld, hcl, hcr, hl c hcl]
    · simp [mergeWorld, hcl, hcr, hl c hcl, hr c hcr]

theorem mergeWorld_accounting (lf rf : Footprint P A D) (initial left right : World P A D)
    (hd : ∀ c ∈ lf.writes, c ∉ rf.writes)
    (hl : ∀ c, c ∉ lf.writes → left.state.balance c = initial.state.balance c)
    (hr : ∀ c, c ∉ rf.writes → right.state.balance c = initial.state.balance c)
    (d : D) (a : A) :
    total (mergeWorld lf rf initial left right).state d a =
      total left.state d a + total right.state d a - total initial.state d a := by
  simp only [total, mergeWorld_balance_sum lf rf initial left right hd hl hr,
    Finset.sum_sub_distrib, Finset.sum_add_distrib]

theorem runBranch_accounting (cfg : Config P A D) (boundary : Nat → Boundary P A D)
    (initial : World P A D) (branch : Branch P A D) (d : D) (a : A) :
    total (runBranch cfg boundary initial branch).world.state d a =
      total initial.state d a + traceSupply (runBranch cfg boundary initial branch).events d a :=
  run_accounting cfg boundary initial (branch.map Step.invoke) d a

/-- Actual successful receipt supplies from both independent runs determine joined accounting. -/
theorem runParallel_accounting (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (initial : World P A D) (left right : Branch P A D) (lf rf : Footprint P A D)
    (hadmit : admit cfg boundaries left right = .ok (lf, rf)) (d : D) (a : A) :
    total (mergeWorld lf rf initial
      (runBranch cfg (boundaries .left) initial left).world
      (runBranch cfg (boundaries .right) initial right).world).state d a =
      total initial.state d a +
        traceSupply (runBranch cfg (boundaries .left) initial left).events d a +
        traceSupply (runBranch cfg (boundaries .right) initial right).events d a := by
  obtain ⟨hv, hl, hr, hc⟩ := admit_ok cfg boundaries left right lf rf hadmit
  rw [mergeWorld_accounting lf rf initial _ _ hc.1
    (runBranch_frame cfg (boundaries .left) initial left lf hl).1
    (runBranch_frame cfg (boundaries .right) initial right rf hr).1]
  rw [runBranch_accounting, runBranch_accounting]
  linarith

theorem runBranch_events_invoke (cfg : Config P A D) (boundary : Nat → Boundary P A D)
    (initial : World P A D) (branch : Branch P A D) :
    ∀ event ∈ (runBranch cfg boundary initial branch).events,
      ∃ inv ∈ branch, event.step = .invoke inv := by
  obtain ⟨accepted, remaining, hs, he⟩ :=
    run_order cfg boundary initial (branch.map Step.invoke)
  intro event hm
  have hstep : event.step ∈ accepted := he ▸ List.mem_map.mpr ⟨event, hm, rfl⟩
  have hall : event.step ∈ branch.map Step.invoke := by
    rw [hs]
    exact List.mem_append_left _ hstep
  obtain ⟨inv, hi, hh⟩ := List.mem_map.mp hall
  exact ⟨inv, hi, hh.symm⟩

theorem trace_invoke_stores {cfg : Config P A D} {boundary : Nat → Boundary P A D}
    {initial final : World P A D} {events : List (Event P A D)}
    {history : List (OutputObservation A)} {index : Nat}
    (h : TraceSound cfg boundary initial events final history index)
    (hi : ∀ event ∈ events, ∃ inv, event.step = .invoke inv) :
    final.capabilities = initial.capabilities ∧
      ∀ event ∈ events, event.before.capabilities = initial.capabilities ∧
        event.result.world.capabilities = initial.capabilities := by
  induction h with
  | nil => exact ⟨rfl, by simp⟩
  | @snoc events pre history index previous step result sound ih =>
    obtain ⟨hp, he⟩ := ih (by
      intro event hm
      exact hi event (List.mem_append_left _ hm))
    obtain ⟨inv, hstep⟩ := hi ⟨index, step, pre, result⟩ (by simp)
    change step = .invoke inv at hstep
    have hcap : result.world.capabilities = pre.capabilities := by
      rw [hstep] at sound
      exact sound.invoke_preserves_capabilities
    refine ⟨hcap.trans hp, ?_⟩
    intro event hm
    rcases List.mem_append.mp hm with hm | hm
    · exact he event hm
    · have eq := List.mem_singleton.mp hm
      subst event
      exact ⟨hp, hcap.trans hp⟩

/-- Every successful invocation uses authority from the initial fixed store, including prefixes
whose later invocation refuses. The actual local boundary remains attached to each event. -/
theorem runBranch_authority (cfg : Config P A D) (boundary : Nat → Boundary P A D)
    (initial : World P A D) (branch : Branch P A D) :
    ∀ event ∈ (runBranch cfg boundary initial branch).events,
      ReceiptAuthorized initial (boundary event.index) event.result.receipt := by
  have ht := run_trace_sound cfg boundary initial (branch.map Step.invoke)
  have hi : ∀ event ∈ (runBranch cfg boundary initial branch).events,
      ∃ inv, event.step = .invoke inv := by
    intro event hm
    obtain ⟨inv, _, he⟩ := runBranch_events_invoke cfg boundary initial branch event hm
    exact ⟨inv, he⟩
  have hs := trace_invoke_stores ht hi
  intro event hm
  have ha := ht.authority event hm
  have hc := (hs.2 event hm).1
  cases hr : event.result.receipt <;> simp only [hr, ReceiptAuthorized] at ha ⊢
  simpa only [hc] using ha

theorem runBranch_prefix_nonnegative (cfg : Config P A D) (boundary : Nat → Boundary P A D)
    (initial : World P A D) (branch : Branch P A D) :
    ∀ event ∈ (runBranch cfg boundary initial branch).events, ∀ c,
      0 ≤ event.before.state.balance c ∧ 0 ≤ event.result.world.state.balance c :=
  run_prefix_nonnegative cfg boundary initial (branch.map Step.invoke)

/-- The join frames every predicate whose explicit support avoids both write regions. -/
theorem mergeWorld_supported_frame (lf rf : Footprint P A D)
    (initial left right : World P A D) (region : Set (Cell P A D))
    (predicate : State P A D → Prop) (support : Supports region predicate)
    (untouched : ∀ c ∈ region, c ∉ lf.writes ∧ c ∉ rf.writes) :
    predicate initial.state ↔ predicate (mergeWorld lf rf initial left right).state := by
  apply supported_frame support
  intro c hc
  exact (mergeWorld_outside lf rf initial left right c
    (untouched c hc).1 (untouched c hc).2).symm

theorem mergeWorld_agrees_left (lf rf : Footprint P A D)
    (initial left right : World P A D) (region : Set (Cell P A D))
    (locality : ∀ c, c ∉ lf.writes → left.state.balance c = initial.state.balance c)
    (peer : ∀ c ∈ region, c ∉ rf.writes) :
    AgreeOn region left.state (mergeWorld lf rf initial left right).state := by
  intro c hc
  by_cases hw : c ∈ lf.writes
  · simp [mergeWorld, hw]
  · simp [mergeWorld, hw, peer c hc, locality c hw]

theorem mergeWorld_agrees_right (lf rf : Footprint P A D)
    (initial left right : World P A D) (region : Set (Cell P A D))
    (locality : ∀ c, c ∉ rf.writes → right.state.balance c = initial.state.balance c)
    (peer : ∀ c ∈ region, c ∉ lf.writes) :
    AgreeOn region right.state (mergeWorld lf rf initial left right).state := by
  intro c hc
  by_cases hw : c ∈ rf.writes
  · simp [mergeWorld, hw, peer c hc]
  · simp [mergeWorld, hw, peer c hc, locality c hw]

theorem mergeWorld_two_invariants (lf rf : Footprint P A D)
    (initial left right : World P A D) (ls rs : Set (Cell P A D))
    (lp rp : State P A D → Prop) (lSupport : Supports ls lp) (rSupport : Supports rs rp)
    (hl : ∀ c, c ∉ lf.writes → left.state.balance c = initial.state.balance c)
    (hr : ∀ c, c ∉ rf.writes → right.state.balance c = initial.state.balance c)
    (lpeer : ∀ c ∈ ls, c ∉ rf.writes) (rpeer : ∀ c ∈ rs, c ∉ lf.writes)
    (li : lp left.state) (ri : rp right.state) :
    lp (mergeWorld lf rf initial left right).state ∧
      rp (mergeWorld lf rf initial left right).state :=
  ⟨(supported_frame lSupport (mergeWorld_agrees_left lf rf initial left right ls hl lpeer)).mp li,
    (supported_frame rSupport (mergeWorld_agrees_right lf rf initial left right rs hr rpeer)).mp ri⟩

/-- Non-circular initialized induction obligations for a branch's own ledger predicate. -/
def LocalPreservation (cfg : Config P A D) (boundary : Nat → Boundary P A D)
    (predicate : State P A D → Prop) : Prop :=
  ∀ n outputs step pre result, StepSound cfg (boundary n) n outputs step pre result →
    predicate pre.state → predicate result.world.state

theorem runBranch_invariant (cfg : Config P A D) (boundary : Nat → Boundary P A D)
    (initial : World P A D) (branch : Branch P A D) (predicate : State P A D → Prop)
    (initialized : predicate initial.state) (preserves : LocalPreservation cfg boundary predicate) :
    predicate (runBranch cfg boundary initial branch).world.state :=
  (run_trace_sound cfg boundary initial (branch.map Step.invoke)).invariant
    (fun w ↦ predicate w.state) initialized preserves

theorem evaluated_supplies_empty (template : Template P A D)
    (ctx : EvalContext P A D template.signature) (e : Evaluated P A D)
    (hn : template.supplyDeltas = []) (he : template.evaluate ctx = .ok e) :
    e.supplies = [] := by
  unfold Template.evaluate at he
  rw [hn] at he
  simp only [List.mapM_nil, bind, Except.bind, pure, Except.pure] at he
  repeat' first | split at he | contradiction
  cases he
  rfl

theorem extractReceipt_supplies_empty (cfg : Config P A D) (boundary : Boundary P A D)
    (request : Request P A D) (pre : World P A D) (e : Evaluated P A D)
    (hn : ∀ op template, cfg.registry op = some template → template.supplyDeltas = [])
    (he : extractReceipt cfg boundary request pre = .ok e) : e.supplies = [] := by
  unfold extractReceipt at he
  cases hs : cfg.registry request.operation with
  | none => simp [hs, bind, Except.bind] at he
  | some template =>
    simp only [hs, bind, Except.bind] at he
    cases ha : Args.check template.signature request.arguments with
    | error reason => simp [ha, Except.mapError] at he
    | ok args =>
      simp only [ha, Except.mapError, bind, Except.bind] at he
      cases hv : template.evaluate
          ⟨pre.state, boundary.env, boundary.ctx.principal, request.parties, args, boundary.now⟩
          <;> simp only [hv, Except.mapError] at he
      · contradiction
      · cases he
        exact evaluated_supplies_empty template _ _ (hn _ _ hs) hv

theorem step_no_supply {cfg : Config P A D} {boundary : Boundary P A D}
    {n : Nat} {outputs : List (OutputObservation A)} {step : Step P A D}
    {pre : World P A D} {result : StepResult P A D}
    (hn : ∀ op template, cfg.registry op = some template → template.supplyDeltas = [])
    (hs : StepSound cfg boundary n outputs step pre result) (d : D) (a : A) :
    result.receipt.supply d a = 0 := by
  cases hs with
  | invoke inv pre post iface request e prepared executed extracted applied =>
    have he := extractReceipt_supplies_empty cfg boundary request pre e hn extracted
    simp [Receipt.supply, Evaluated.supply, he]
  | issue => rfl
  | revoke => rfl

theorem local_total_preservation (cfg : Config P A D) (boundary : Nat → Boundary P A D)
    (hn : ∀ op template, cfg.registry op = some template → template.supplyDeltas = [])
    (d : D) (a : A) (amount : ℚ) :
    LocalPreservation cfg boundary (fun s ↦ total s d a = amount) := by
  intro n outputs step pre result hs hi
  rw [hs.accounting d a, step_no_supply hn hs d a, add_zero]
  exact hi

theorem supports_total (d : D) (a : A) (predicate : ℚ → Prop) :
    Supports {c : Cell P A D | c.1 = d ∧ c.2.2 = a}
      (fun s ↦ predicate (total s d a)) := by
  intro pre post h
  have ht : total pre d a = total post d a := by
    apply Finset.sum_congr rfl
    intro party hp
    exact h (d, party, a) ⟨rfl, rfl⟩
  change predicate (total pre d a) ↔ predicate (total post d a)
  rw [ht]

/-- Both branch invariants are initialized and preserved individually before supported join. -/
theorem runParallel_two_invariants (cfg : Config P A D) (boundaries : ParallelBoundary P A D)
    (initial : World P A D) (left right : Branch P A D) (lf rf : Footprint P A D)
    (hadmit : admit cfg boundaries left right = .ok (lf, rf))
    (ls rs : Set (Cell P A D)) (lp rp : State P A D → Prop)
    (lSupport : Supports ls lp) (rSupport : Supports rs rp)
    (lpeer : ∀ c ∈ ls, c ∉ rf.writes) (rpeer : ∀ c ∈ rs, c ∉ lf.writes)
    (li : lp initial.state) (ri : rp initial.state)
    (lPreserves : LocalPreservation cfg (boundaries .left) lp)
    (rPreserves : LocalPreservation cfg (boundaries .right) rp) :
    lp (mergeWorld lf rf initial (runBranch cfg (boundaries .left) initial left).world
      (runBranch cfg (boundaries .right) initial right).world).state ∧
    rp (mergeWorld lf rf initial (runBranch cfg (boundaries .left) initial left).world
      (runBranch cfg (boundaries .right) initial right).world).state := by
  obtain ⟨_, hl, hr, _⟩ := admit_ok cfg boundaries left right lf rf hadmit
  exact mergeWorld_two_invariants lf rf initial _ _ ls rs lp rp lSupport rSupport
    (runBranch_frame cfg (boundaries .left) initial left lf hl).1
    (runBranch_frame cfg (boundaries .right) initial right rf hr).1 lpeer rpeer
    (runBranch_invariant cfg (boundaries .left) initial left lp li lPreserves)
    (runBranch_invariant cfg (boundaries .right) initial right rp ri rPreserves)

/-- Accounting binds the public executed result to both of its actual receipt sequences. -/
theorem runParallel_executed_accounting (cfg : Config P A D)
    (boundaries : ParallelBoundary P A D) (initial : World P A D)
    (left right : Branch P A D) (joined : Joined P A D)
    (hx : runParallel cfg boundaries initial left right = .executed joined) (d : D) (a : A) :
    total joined.world.state d a = total initial.state d a + joined.supply d a := by
  cases hadmit : admit cfg boundaries left right with
  | error reason => simp [runParallel, hadmit] at hx
  | ok pair =>
    rcases pair with ⟨lf, rf⟩
    simp only [runParallel, hadmit, Result.executed.injEq] at hx
    subst joined
    simpa only [Joined.supply, add_assoc] using
      runParallel_accounting cfg boundaries initial left right lf rf hadmit d a

theorem runParallel_executed_authority (cfg : Config P A D)
    (boundaries : ParallelBoundary P A D) (initial : World P A D)
    (left right : Branch P A D) (joined : Joined P A D)
    (hx : runParallel cfg boundaries initial left right = .executed joined) :
    (∀ event ∈ joined.left.events,
      ReceiptAuthorized initial (boundaries .left event.index) event.result.receipt) ∧
    (∀ event ∈ joined.right.events,
      ReceiptAuthorized initial (boundaries .right event.index) event.result.receipt) := by
  cases hadmit : admit cfg boundaries left right with
  | error reason => simp [runParallel, hadmit] at hx
  | ok pair =>
    rcases pair with ⟨lf, rf⟩
    simp only [runParallel, hadmit, Result.executed.injEq] at hx
    subst joined
    exact ⟨runBranch_authority cfg (boundaries .left) initial left,
      runBranch_authority cfg (boundaries .right) initial right⟩

theorem runParallel_executed_frame (cfg : Config P A D)
    (boundaries : ParallelBoundary P A D) (initial : World P A D)
    (left right : Branch P A D) (lf rf : Footprint P A D) (joined : Joined P A D)
    (hadmit : admit cfg boundaries left right = .ok (lf, rf))
    (hx : runParallel cfg boundaries initial left right = .executed joined) :
    (∀ c, c ∉ lf.writes → c ∉ rf.writes →
      joined.world.state.balance c = initial.state.balance c) ∧
      joined.world.capabilities = initial.capabilities := by
  simp only [runParallel, hadmit, Result.executed.injEq] at hx
  subst joined
  exact ⟨mergeWorld_outside lf rf initial _ _, rfl⟩

theorem runParallel_executed_nonnegative (cfg : Config P A D)
    (boundaries : ParallelBoundary P A D) (initial : World P A D)
    (left right : Branch P A D) (joined : Joined P A D)
    (hx : runParallel cfg boundaries initial left right = .executed joined) :
    (∀ c, 0 ≤ joined.world.state.balance c) ∧
    (∀ event ∈ joined.left.events ++ joined.right.events, ∀ c,
      0 ≤ event.before.state.balance c ∧ 0 ≤ event.result.world.state.balance c) := by
  exact ⟨joined.world.state.nonneg,
    fun event _ c ↦ ⟨event.before.state.nonneg c, event.result.world.state.nonneg c⟩⟩

theorem runParallel_executed_supported_frame (cfg : Config P A D)
    (boundaries : ParallelBoundary P A D) (initial : World P A D)
    (left right : Branch P A D) (lf rf : Footprint P A D) (joined : Joined P A D)
    (hadmit : admit cfg boundaries left right = .ok (lf, rf))
    (hx : runParallel cfg boundaries initial left right = .executed joined)
    (region : Set (Cell P A D)) (predicate : State P A D → Prop)
    (support : Supports region predicate)
    (untouched : ∀ c ∈ region, c ∉ lf.writes ∧ c ∉ rf.writes) :
    predicate initial.state ↔ predicate joined.world.state := by
  apply supported_frame support
  intro c hc
  exact ((runParallel_executed_frame cfg boundaries initial left right lf rf joined hadmit hx).1
    c (untouched c hc).1 (untouched c hc).2).symm

theorem runParallel_executed_two_invariants (cfg : Config P A D)
    (boundaries : ParallelBoundary P A D) (initial : World P A D)
    (left right : Branch P A D) (lf rf : Footprint P A D) (joined : Joined P A D)
    (hadmit : admit cfg boundaries left right = .ok (lf, rf))
    (hx : runParallel cfg boundaries initial left right = .executed joined)
    (ls rs : Set (Cell P A D)) (lp rp : State P A D → Prop)
    (lSupport : Supports ls lp) (rSupport : Supports rs rp)
    (lpeer : ∀ c ∈ ls, c ∉ rf.writes) (rpeer : ∀ c ∈ rs, c ∉ lf.writes)
    (li : lp initial.state) (ri : rp initial.state)
    (lPreserves : LocalPreservation cfg (boundaries .left) lp)
    (rPreserves : LocalPreservation cfg (boundaries .right) rp) :
    lp joined.world.state ∧ rp joined.world.state := by
  simp only [runParallel, hadmit, Result.executed.injEq] at hx
  subst joined
  exact runParallel_two_invariants cfg boundaries initial left right lf rf hadmit
    ls rs lp rp lSupport rSupport lpeer rpeer li ri lPreserves rPreserves

end DefiKernel.Parallel


===== INPUT lean/DefiKernel/Typed/Authority.lean ORIGINAL_SHA256 dfd2c140f511144e9928ed4f5ed1db9ee2b56cada1342500d2e60c33ef9a0cdb RENDERED_SHA256 dfd2c140f511144e9928ed4f5ed1db9ee2b56cada1342500d2e60c33ef9a0cdb =====
import DefiKernel.Typed.Types

/-! Nondelegating capability administration under a trusted actor, domain administrator and
operation-domain lookup. List positions are permanent IDs: revoked entries remain as tombstones.
Authentication, registry truth, allowances and replay prevention are outside this model. -/
namespace DefiKernel.Typed

inductive Right (Party Asset Domain : Type) where
  | invoke
  | debit (cell : Cell Party Asset Domain)
  | changeSupply (domain : Domain) (asset : Asset)
  deriving DecidableEq, Repr

def Right.inDomain {Party Asset Domain : Type} [DecidableEq Domain]
    (right : Right Party Asset Domain) (domain : Domain) : Bool :=
  match right with
  | .invoke => true
  | .debit cell => decide (cell.1 = domain)
  | .changeSupply d _ => decide (d = domain)

structure Grant (Party Asset Domain : Type) where
  holder : Party
  domain : Domain
  operation : OperationId
  right : Right Party Asset Domain
  deriving DecidableEq, Repr

structure Capability (Party Asset Domain : Type) extends Grant Party Asset Domain where
  live : Bool
  deriving DecidableEq, Repr

/-- The adapter supplies this immutable configuration, separately from caller requests. -/
structure AuthorityConfig (Party Domain : Type) where
  domainAdmin : Domain → Party
  operationDomain : OperationId → Option Domain

/-- No entry is removed; length is the next fresh ID, so no separate counter invariant is needed. -/
structure CapabilityStore (Party Asset Domain : Type) where
  entries : List (Capability Party Asset Domain)
  deriving DecidableEq, Repr

def CapabilityStore.empty {Party Asset Domain : Type} : CapabilityStore Party Asset Domain := ⟨[]⟩

def CapabilityStore.nextId {Party Asset Domain : Type}
    (store : CapabilityStore Party Asset Domain) : CapabilityId := ⟨store.entries.length⟩

def CapabilityStore.lookup {Party Asset Domain : Type}
    (store : CapabilityStore Party Asset Domain) (id : CapabilityId) := store.entries[id.value]?

inductive AuthorityFailure where
  | unauthorizedAdmin
  | operationDomain
  | resourceDomain
  | unknownCapability
  deriving DecidableEq, Repr

variable {Party Asset Domain : Type}
variable [DecidableEq Party] [DecidableEq Asset] [DecidableEq Domain]

def isDomainAdmin (config : AuthorityConfig Party Domain) (ctx : InvocationContext Party Domain)
    (domain : Domain) : Bool :=
  decide (ctx.domain = domain ∧ ctx.principal = config.domainAdmin domain)

/-- A grant cannot choose its ID or reactivate an existing entry. -/
def issueCapability (config : AuthorityConfig Party Domain) (ctx : InvocationContext Party Domain)
    (store : CapabilityStore Party Asset Domain) (grant : Grant Party Asset Domain) :
    Except AuthorityFailure (CapabilityId × CapabilityStore Party Asset Domain) :=
  if isDomainAdmin config ctx grant.domain then
    if config.operationDomain grant.operation = some grant.domain then
      if grant.right.inDomain grant.domain then
        .ok (store.nextId, ⟨store.entries ++ [⟨grant, true⟩]⟩)
      else .error .resourceDomain
    else .error .operationDomain
  else .error .unauthorizedAdmin

/-- Revocation is idempotent and retains the ID permanently, including its original scope. -/
def revokeCapability (config : AuthorityConfig Party Domain) (ctx : InvocationContext Party Domain)
    (store : CapabilityStore Party Asset Domain) (id : CapabilityId) :
    Except AuthorityFailure (CapabilityStore Party Asset Domain) :=
  match store.lookup id with
  | none => .error .unknownCapability
  | some cap =>
    if isDomainAdmin config ctx cap.domain then
      .ok ⟨store.entries.set id.value { cap with live := false }⟩
    else .error .unauthorizedAdmin

/-- Each supplied ID must itself pass all scope checks to contribute an exact right. -/
def authorizesId (store : CapabilityStore Party Asset Domain)
    (ctx : InvocationContext Party Domain) (operation : OperationId)
    (right : Right Party Asset Domain) (id : CapabilityId) : Bool :=
  match store.lookup id with
  | none => false
  | some cap => decide (cap.live = true ∧ cap.holder = ctx.principal ∧
      cap.domain = ctx.domain ∧ cap.operation = operation ∧ cap.right = right ∧
      right.inDomain ctx.domain = true)

/-- Existential use means duplicate request IDs confer no additional rights. -/
def hasAuthority (store : CapabilityStore Party Asset Domain)
    (ids : List CapabilityId) (ctx : InvocationContext Party Domain)
    (operation : OperationId) (right : Right Party Asset Domain) : Bool :=
  ids.any (authorizesId store ctx operation right)

-- BEGIN PROOFS

omit [DecidableEq Asset] in
theorem issueCapability_ok_iff (config : AuthorityConfig Party Domain)
    (ctx : InvocationContext Party Domain) (store : CapabilityStore Party Asset Domain)
    (grant : Grant Party Asset Domain) (id : CapabilityId)
    (post : CapabilityStore Party Asset Domain) :
    issueCapability config ctx store grant = .ok (id, post) ↔
      isDomainAdmin config ctx grant.domain = true ∧
      config.operationDomain grant.operation = some grant.domain ∧
      grant.right.inDomain grant.domain = true ∧
      id = store.nextId ∧ post = ⟨store.entries ++ [⟨grant, true⟩]⟩ := by
  unfold issueCapability
  split <;> simp_all
  split <;> simp_all
  split <;> simp_all
  aesop

omit [DecidableEq Asset] in
theorem issueCapability_admin (config : AuthorityConfig Party Domain)
    (ctx : InvocationContext Party Domain) (store : CapabilityStore Party Asset Domain)
    (grant : Grant Party Asset Domain) (id : CapabilityId)
    (post : CapabilityStore Party Asset Domain)
    (h : issueCapability config ctx store grant = .ok (id, post)) :
    ctx.domain = grant.domain ∧ ctx.principal = config.domainAdmin grant.domain := by
  simpa [isDomainAdmin] using (issueCapability_ok_iff ..).mp h |>.1

omit [DecidableEq Party] [DecidableEq Asset] [DecidableEq Domain] in
theorem lookup_nextId (store : CapabilityStore Party Asset Domain) :
    store.lookup store.nextId = none := by simp [CapabilityStore.lookup, CapabilityStore.nextId]

omit [DecidableEq Asset] in
theorem issueCapability_fresh (config : AuthorityConfig Party Domain)
    (ctx : InvocationContext Party Domain) (store : CapabilityStore Party Asset Domain)
    (grant : Grant Party Asset Domain) (id : CapabilityId)
    (post : CapabilityStore Party Asset Domain)
    (h : issueCapability config ctx store grant = .ok (id, post)) :
    store.lookup id = none ∧ post.lookup id = some ⟨grant, true⟩ ∧
      post.nextId.value = store.nextId.value + 1 := by
  obtain ⟨_, _, _, rfl, rfl⟩ := (issueCapability_ok_iff ..).mp h
  simp [CapabilityStore.lookup, CapabilityStore.nextId]

omit [DecidableEq Asset] in
theorem issueCapability_preserves_other (config : AuthorityConfig Party Domain)
    (ctx : InvocationContext Party Domain) (store : CapabilityStore Party Asset Domain)
    (grant : Grant Party Asset Domain) (id other : CapabilityId)
    (post : CapabilityStore Party Asset Domain)
    (h : issueCapability config ctx store grant = .ok (id, post)) (hne : other ≠ id) :
    post.lookup other = store.lookup other := by
  obtain ⟨_, _, _, rfl, rfl⟩ := (issueCapability_ok_iff ..).mp h
  have hn : other.value ≠ store.entries.length := by
    intro he
    apply hne
    cases other
    simp_all [CapabilityStore.nextId]
  simp only [CapabilityStore.lookup, List.getElem?_append]
  split
  · rfl
  · rename_i hge
    have ht : store.entries.length < other.value := by omega
    have hz : other.value - store.entries.length ≠ 0 := by omega
    simp [List.getElem?_eq_none (by omega : store.entries.length ≤ other.value), hz]

omit [DecidableEq Asset] in
theorem issueCapability_ne_existing (config : AuthorityConfig Party Domain)
    (ctx : InvocationContext Party Domain) (store : CapabilityStore Party Asset Domain)
    (grant : Grant Party Asset Domain) (id old : CapabilityId)
    (post : CapabilityStore Party Asset Domain) (cap : Capability Party Asset Domain)
    (h : issueCapability config ctx store grant = .ok (id, post))
    (hold : store.lookup old = some cap) : id ≠ old := by
  intro he
  have hf := (issueCapability_fresh config ctx store grant id post h).1
  rw [he, hold] at hf
  contradiction

omit [DecidableEq Asset] in
theorem revokeCapability_ok_iff (config : AuthorityConfig Party Domain)
    (ctx : InvocationContext Party Domain) (store : CapabilityStore Party Asset Domain)
    (id : CapabilityId) (post : CapabilityStore Party Asset Domain) :
    revokeCapability config ctx store id = .ok post ↔
      ∃ cap, store.lookup id = some cap ∧ isDomainAdmin config ctx cap.domain = true ∧
        post = ⟨store.entries.set id.value { cap with live := false }⟩ := by
  unfold revokeCapability
  split <;> simp_all
  split <;> simp_all
  aesop

omit [DecidableEq Asset] in
theorem revokeCapability_admin (config : AuthorityConfig Party Domain)
    (ctx : InvocationContext Party Domain) (store : CapabilityStore Party Asset Domain)
    (id : CapabilityId) (post : CapabilityStore Party Asset Domain)
    (h : revokeCapability config ctx store id = .ok post) :
    ∃ cap, store.lookup id = some cap ∧ ctx.domain = cap.domain ∧
      ctx.principal = config.domainAdmin cap.domain := by
  obtain ⟨cap, hc, ha, _⟩ := (revokeCapability_ok_iff ..).mp h
  exact ⟨cap, hc, by simpa [isDomainAdmin] using ha⟩

omit [DecidableEq Asset] in
theorem revokeCapability_tombstone (config : AuthorityConfig Party Domain)
    (ctx : InvocationContext Party Domain) (store : CapabilityStore Party Asset Domain)
    (id : CapabilityId) (post : CapabilityStore Party Asset Domain)
    (h : revokeCapability config ctx store id = .ok post) :
    ∃ cap, store.lookup id = some cap ∧
      post.lookup id = some { cap with live := false } ∧ post.nextId = store.nextId := by
  obtain ⟨cap, hc, _, rfl⟩ := (revokeCapability_ok_iff ..).mp h
  have hi : id.value < store.entries.length := by
    by_contra hn
    have hn' : store.entries.length ≤ id.value := by omega
    simp [CapabilityStore.lookup, List.getElem?_eq_none hn'] at hc
  exact ⟨cap, hc, by simp [CapabilityStore.lookup, hi], by simp [CapabilityStore.nextId]⟩

omit [DecidableEq Asset] in
theorem revokeCapability_preserves_other (config : AuthorityConfig Party Domain)
    (ctx : InvocationContext Party Domain) (store : CapabilityStore Party Asset Domain)
    (id other : CapabilityId) (post : CapabilityStore Party Asset Domain)
    (h : revokeCapability config ctx store id = .ok post) (hne : other ≠ id) :
    post.lookup other = store.lookup other := by
  obtain ⟨cap, _, _, rfl⟩ := (revokeCapability_ok_iff ..).mp h
  have hn : id.value ≠ other.value := by
    intro he
    apply hne
    cases id
    cases other
    simp_all
  simp [CapabilityStore.lookup, List.getElem?_set_ne hn]

theorem authorizesId_iff (store : CapabilityStore Party Asset Domain)
    (ctx : InvocationContext Party Domain) (operation : OperationId)
    (right : Right Party Asset Domain) (id : CapabilityId) :
    authorizesId store ctx operation right id = true ↔
      ∃ cap, store.lookup id = some cap ∧ cap.live = true ∧ cap.holder = ctx.principal ∧
        cap.domain = ctx.domain ∧ cap.operation = operation ∧ cap.right = right ∧
        right.inDomain ctx.domain = true := by
  unfold authorizesId
  split <;> simp_all

theorem hasAuthority_iff (store : CapabilityStore Party Asset Domain) (ids : List CapabilityId)
    (ctx : InvocationContext Party Domain) (operation : OperationId)
    (right : Right Party Asset Domain) :
    hasAuthority store ids ctx operation right = true ↔
      ∃ id ∈ ids, authorizesId store ctx operation right id = true := by
  simp [hasAuthority]

theorem hasAuthority_duplicate (store : CapabilityStore Party Asset Domain)
    (ids : List CapabilityId) (id : CapabilityId) (ctx : InvocationContext Party Domain)
    (operation : OperationId) (right : Right Party Asset Domain) :
    hasAuthority store (id :: id :: ids) ctx operation right =
      hasAuthority store (id :: ids) ctx operation right := by
  simp [hasAuthority]

theorem revokeCapability_cannot_use (config : AuthorityConfig Party Domain)
    (adminCtx ctx : InvocationContext Party Domain) (store : CapabilityStore Party Asset Domain)
    (id : CapabilityId) (post : CapabilityStore Party Asset Domain)
    (operation : OperationId) (right : Right Party Asset Domain)
    (h : revokeCapability config adminCtx store id = .ok post) :
    authorizesId post ctx operation right id = false := by
  obtain ⟨cap, _, hc, _⟩ := revokeCapability_tombstone config adminCtx store id post h
  simp [authorizesId, hc]

/-- Reissuing authority leaves every existing revoked ID unusable. -/
theorem issueCapability_keeps_revoked (config : AuthorityConfig Party Domain)
    (adminCtx ctx : InvocationContext Party Domain) (store : CapabilityStore Party Asset Domain)
    (grant : Grant Party Asset Domain) (id old : CapabilityId)
    (post : CapabilityStore Party Asset Domain) (cap : Capability Party Asset Domain)
    (operation : OperationId) (right : Right Party Asset Domain)
    (h : issueCapability config adminCtx store grant = .ok (id, post))
    (hold : store.lookup old = some cap) (hdead : cap.live = false) :
    authorizesId post ctx operation right old = false := by
  have hne := issueCapability_ne_existing config adminCtx store grant id old post cap h hold
  have hp := issueCapability_preserves_other config adminCtx store grant id old post h hne.symm
  simp [authorizesId, hp, hold, hdead]

end DefiKernel.Typed


===== INPUT lean/DefiKernel/Typed/Examples.lean ORIGINAL_SHA256 640df42460b97cd4ac2aba50dc354aa7d2671a055f39c2ec0eb6c8e0f1197f41 RENDERED_SHA256 640df42460b97cd4ac2aba50dc354aa7d2671a055f39c2ec0eb6c8e0f1197f41 =====
import DefiKernel.Typed.Transition

/-! Registered reference financial libraries. Exact rates and declared locked collateral are
model assumptions, not deployed-contract fidelity or market-solvency claims. -/
namespace DefiKernel.Typed
namespace Examples

inductive Party where
  | alice | bob | vault | pool
  deriving DecidableEq, Repr

inductive Asset where
  | usd | share | collateral | debt
  deriving DecidableEq, Repr

inductive Domain where
  | main | other
  deriving DecidableEq, Repr

instance : Fintype Party := ⟨{.alice, .bob, .vault, .pool}, by
  intro p; cases p <;> simp⟩
instance : Fintype Asset := ⟨{.usd, .share, .collateral, .debt}, by
  intro a; cases a <;> simp⟩
instance : Fintype Domain := ⟨{.main, .other}, by intro d; cases d <;> simp⟩

abbrev Ledger := State Party Asset Domain
abbrev Store := CapabilityStore Party Asset Domain
abbrev Op := Template Party Asset Domain
abbrev Call := Request Party Asset Domain
abbrev Result := ExecutionResult Party Asset Domain
abbrev E (signature : List (Unit Asset)) := Expr Party Asset Domain signature

/-- Original reference balances on main; every other-domain balance is zero. -/
def initial : Ledger where
  balance c := match c with
    | (.main, .alice, .usd) => 10
    | (.main, .alice, .share) => 4
    | (.main, .alice, .collateral) => 10
    | (.main, .alice, .debt) => 2
    | (.main, .vault, .usd) => 20
    | (.main, .pool, .usd) => 100
    | _ => 0
  nonneg c := by
    rcases c with ⟨d, p, a⟩
    cases d <;> cases p <;> cases a <;> decide

def ref (a : Asset) (owner : PartyRef Party) : CellRef Party Asset Domain a :=
  ⟨.main, owner⟩

def packedRef (a : Asset) (owner : PartyRef Party) : PackedCellRef Party Asset Domain :=
  ⟨a, ref a owner⟩

def allGuards {signature : List (Unit Asset)} : List (E signature .bool) → E signature .bool
  | [] => .lit true
  | g :: gs => .binary .and g (allGuards gs)

def nonnegative {signature : List (Unit Asset)} (a : Asset)
    (q : E signature (.amount a)) : E signature .bool :=
  .binary (.le (.amount a)) (.lit 0) q

def negate {signature : List (Unit Asset)} (a : Asset)
    (q : E signature (.amount a)) : E signature (.amount a) :=
  .unary (.neg (.amount a)) q

def usdSignature : List (Unit Asset) := [.amount .usd]
def shareSignature : List (Unit Asset) := [.amount .share]
def usdQuantity : E usdSignature (.amount .usd) := .arg .here
def shareQuantity : E shareSignature (.amount .share) := .arg .here

/-- Registered USD movement; zero and self transfer retain net-effect semantics. -/
def transfer : Op where
  signature := usdSignature
  domain := .main
  partyArity := 1
  guard := nonnegative .usd usdQuantity
  deltas := [⟨.usd, ref .usd .caller, negate .usd usdQuantity⟩,
    ⟨.usd, ref .usd (.argument 0), usdQuantity⟩]
  supplyDeltas := []
  stateReads := []
  envReads := []
  writes := [packedRef .usd .caller, packedRef .usd (.argument 0)]

/-- Two USD per share is a dimensioned library price, not a unit-changing scalar. -/
def mintedShares : E usdSignature (.amount .share) :=
  .binary (.unconvert Asset.share Asset.usd) usdQuantity (.lit 2)

def deposit : Op where
  signature := usdSignature
  domain := .main
  partyArity := 0
  guard := nonnegative .usd usdQuantity
  deltas := [⟨.usd, ref .usd .caller, negate .usd usdQuantity⟩,
    ⟨.usd, ref .usd (.literal .vault), usdQuantity⟩,
    ⟨.share, ref .share .caller, mintedShares⟩]
  supplyDeltas := [⟨.main, .share, mintedShares⟩]
  stateReads := []
  envReads := []
  writes := [packedRef .usd .caller, packedRef .usd (.literal .vault), packedRef .share .caller]

def redeemedUsd : E shareSignature (.amount .usd) :=
  .binary (.convert Asset.share Asset.usd) shareQuantity (.lit 2)

def withdraw : Op where
  signature := shareSignature
  domain := .main
  partyArity := 0
  guard := nonnegative .share shareQuantity
  deltas := [⟨.usd, ref .usd (.literal .vault), negate .usd redeemedUsd⟩,
    ⟨.usd, ref .usd .caller, redeemedUsd⟩,
    ⟨.share, ref .share .caller, negate .share shareQuantity⟩]
  supplyDeltas := [⟨.main, .share, negate .share shareQuantity⟩]
  stateReads := []
  envReads := []
  writes := [packedRef .usd (.literal .vault), packedRef .usd .caller, packedRef .share .caller]

def priceKey : ObservationKey Domain := ⟨.main, ⟨7⟩⟩
def collateralPrice : E usdSignature (.price .collateral .usd) := .observe ⟨priceKey⟩

/-- One USD per debt token is the reference denomination, explicitly dimensioned. -/
def mintedDebt : E usdSignature (.amount .debt) :=
  .binary (.unconvert Asset.debt Asset.usd) usdQuantity (.lit 1)

def debtValue : E usdSignature (.amount .usd) :=
  .binary (.convert Asset.debt Asset.usd)
    (.binary (.add (.amount Asset.debt)) (.balance (ref .debt .caller)) mintedDebt) (.lit 1)

def collateralValue : E usdSignature (.amount .usd) :=
  .binary (.convert Asset.collateral Asset.usd) (.balance (ref .collateral .caller)) collateralPrice

def borrowGuard : E usdSignature .bool := allGuards [
  nonnegative .usd usdQuantity,
  .binary (.lt (.price Asset.collateral Asset.usd)) (.lit 0) collateralPrice,
  .binary (.le .scalar) (.timestamp priceKey) .now,
  .binary (.le .scalar) .now (.binary (.add .scalar) (.timestamp priceKey) (.lit 5)),
  .binary (.le (.amount Asset.usd))
    (.binary (.scale (.amount Asset.usd)) (.lit 2) debtValue) collateralValue]

def borrow : Op where
  signature := usdSignature
  domain := .main
  partyArity := 0
  guard := borrowGuard
  deltas := [⟨.usd, ref .usd (.literal .pool), negate .usd usdQuantity⟩,
    ⟨.usd, ref .usd .caller, usdQuantity⟩,
    ⟨.debt, ref .debt .caller, mintedDebt⟩]
  supplyDeltas := [⟨.main, .debt, mintedDebt⟩]
  stateReads := [packedRef .debt .caller, packedRef .collateral .caller]
  envReads := [.observation priceKey, .currentTime]
  writes := [packedRef .usd (.literal .pool), packedRef .usd .caller, packedRef .debt .caller]

def transferId : OperationId := ⟨0⟩
def depositId : OperationId := ⟨1⟩
def withdrawId : OperationId := ⟨2⟩
def borrowId : OperationId := ⟨3⟩

def registry : Registry Party Asset Domain := fun id ↦ match id.value with
  | 0 => some transfer
  | 1 => some deposit
  | 2 => some withdraw
  | 3 => some borrow
  | _ => none

/-- Vault is the fixture's administrative principal; this does not move ledger balances. -/
def domainAdmin : Domain → Party := fun _ ↦ .vault
def authorityConfig : AuthorityConfig Party Domain := registryAuthorityConfig registry domainAdmin
def adminContext : InvocationContext Party Domain := ⟨.vault, .main⟩
def aliceContext : InvocationContext Party Domain := ⟨.alice, .main⟩
def bobContext : InvocationContext Party Domain := ⟨.bob, .main⟩

def grant (operation : OperationId) (right : Right Party Asset Domain) : Grant Party Asset Domain :=
  ⟨.alice, .main, operation, right⟩

/-- Every operation has its own invocation and exact resource grants. -/
def grants : List (Grant Party Asset Domain) := [
  grant transferId .invoke, grant transferId (.debit (.main, .alice, .usd)),
  grant depositId .invoke, grant depositId (.debit (.main, .alice, .usd)),
  grant depositId (.changeSupply .main .share),
  grant withdrawId .invoke, grant withdrawId (.debit (.main, .vault, .usd)),
  grant withdrawId (.debit (.main, .alice, .share)), grant withdrawId (.changeSupply .main .share),
  grant borrowId .invoke, grant borrowId (.debit (.main, .pool, .usd)),
  grant borrowId (.changeSupply .main .debt)]

def issueGrants (store : Store) : List (Grant Party Asset Domain) → Except AuthorityFailure Store
  | [] => .ok store
  | g :: gs => do
    let (_, next) ← issueCapability authorityConfig adminContext store g
    issueGrants next gs

/-- Provisioning failure is propagated; execution never substitutes a fabricated store. -/
def provisioned : Except AuthorityFailure Store := issueGrants .empty grants
def allCapabilityIds : List CapabilityId := (List.range grants.length).map CapabilityId.mk

def transferRequest (q : ℚ) (recipient : Party := .bob) : Call :=
  ⟨transferId, [recipient], [⟨.amount .usd, q⟩], allCapabilityIds, none⟩
def depositRequest (q : ℚ) : Call :=
  ⟨depositId, [], [⟨.amount .usd, q⟩], allCapabilityIds, none⟩
def withdrawRequest (q : ℚ) : Call :=
  ⟨withdrawId, [], [⟨.amount .share, q⟩], allCapabilityIds, none⟩
def borrowRequest (q : ℚ) : Call :=
  ⟨borrowId, [], [⟨.amount .usd, q⟩], allCapabilityIds, none⟩

/-- Supplying a different feed creates a different key; it cannot replace feed seven. -/
def oracle (feed : Nat) (price : ℚ) (observedAt : Nat) : Environment Asset Domain := fun key ↦
  if key = ⟨.main, ⟨feed⟩⟩ then some ⟨⟨.price .collateral .usd, price⟩, observedAt⟩ else none

def fresh : Environment Asset Domain := oracle 7 2 98

inductive ReferenceFailure where
  | authority (reason : AuthorityFailure)
  | execution (reason : Refusal)
  deriving DecidableEq, Repr

def runWith (store : Store) (ctx : InvocationContext Party Domain)
    (env : Environment Asset Domain) (now : Nat) (request : Call) (state : Ledger := initial) :
    Except ReferenceFailure Result :=
  (execute registry store ctx env now request state).mapError .execution

def run (request : Call) : Except ReferenceFailure Result := do
  let store ← provisioned.mapError .authority
  runWith store aliceContext fresh 100 request

def runOracle (env : Environment Asset Domain) (now : Nat) (request : Call) :
    Except ReferenceFailure Result := do
  let store ← provisioned.mapError .authority
  runWith store aliceContext env now request

def runContext (ctx : InvocationContext Party Domain) (request : Call) :
    Except ReferenceFailure Result := do
  let store ← provisioned.mapError .authority
  runWith store ctx fresh 100 request

def runRevoked (id : CapabilityId) (request : Call) : Except ReferenceFailure Result := do
  let store ← provisioned.mapError .authority
  let revoked ← (revokeCapability authorityConfig adminContext store id).mapError .authority
  runWith revoked aliceContext fresh 100 request

def allCells : List (Cell Party Asset Domain) :=
  [Domain.main, .other].flatMap fun d ↦ [Party.alice, .bob, .vault, .pool].flatMap fun p ↦
    [Asset.usd, .share, .collateral, .debt].map fun a ↦ (d, p, a)

def observe (result : Except ReferenceFailure Result) : Except ReferenceFailure (List ℚ) :=
  result.map fun post ↦ allCells.map post.state.balance

end Examples

-- BEGIN PROOFS

namespace Examples

theorem allCells_complete (cell : Cell Party Asset Domain) : cell ∈ allCells := by
  rcases cell with ⟨d, p, a⟩
  cases d <;> cases p <;> cases a <;> decide

theorem allCells_nodup : allCells.Nodup := by decide

end Examples
end DefiKernel.Typed


===== INPUT lean/DefiKernel/Typed/Expr.lean ORIGINAL_SHA256 1c4e0c2e38dd6beaed332bfccbda6d256b3f57d27cb7a0db370fb1a9019fbfed RENDERED_SHA256 1c4e0c2e38dd6beaed332bfccbda6d256b3f57d27cb7a0db370fb1a9019fbfed =====
import DefiKernel.Typed.Types

/-! A closed dimensioned expression language. All arithmetic is exact rational arithmetic.
Read sets conservatively include both conditional branches. Environment truth is assumed. -/
namespace DefiKernel.Typed

inductive Var {Asset : Type} : List (Unit Asset) → Unit Asset → Type where
  | here {u : Unit Asset} {signature : List (Unit Asset)} : Var (u :: signature) u
  | there {u v : Unit Asset} {signature : List (Unit Asset)} :
      Var signature u → Var (v :: signature) u

inductive Args {Asset : Type} : List (Unit Asset) → Type where
  | nil : Args []
  | cons {u : Unit Asset} {signature : List (Unit Asset)} :
      Value u → Args signature → Args (u :: signature)

def Args.get {Asset : Type} {signature : List (Unit Asset)} {u : Unit Asset} :
    Args signature → Var signature u → Value u
  | .cons value _, .here => value
  | .cons _ rest, .there v => rest.get v

/-- Check arity and every delivered unit before exposing typed arguments to evaluation. -/
def Args.check {Asset : Type} [DecidableEq Asset] (signature : List (Unit Asset))
    (values : List (PackedValue Asset)) : Except EvalFailure (Args signature) :=
  match signature, values with
  | [], [] => .ok .nil
  | u :: us, ⟨v, value⟩ :: vs =>
    if h : v = u then do
      let rest ← Args.check us vs
      return .cons (h ▸ value) rest
    else .error .argumentUnit
  | _, _ => .error .argumentCount

inductive UnaryOp (Asset : Type) : Unit Asset → Unit Asset → Type where
  | neg (u : NumericUnit Asset) : UnaryOp Asset u.toUnit u.toUnit
  | not : UnaryOp Asset .bool .bool

inductive BinaryOp (Asset : Type) : Unit Asset → Unit Asset → Unit Asset → Type where
  | add (u : NumericUnit Asset) : BinaryOp Asset u.toUnit u.toUnit u.toUnit
  | sub (u : NumericUnit Asset) : BinaryOp Asset u.toUnit u.toUnit u.toUnit
  | scale (u : NumericUnit Asset) : BinaryOp Asset .scalar u.toUnit u.toUnit
  | divide (u : NumericUnit Asset) : BinaryOp Asset u.toUnit .scalar u.toUnit
  | ratio (u : NumericUnit Asset) : BinaryOp Asset u.toUnit u.toUnit .scalar
  | convert (base quote : Asset) : BinaryOp Asset (.amount base) (.price base quote) (.amount quote)
  | unconvert (base quote : Asset) :
      BinaryOp Asset (.amount quote) (.price base quote) (.amount base)
  | le (u : NumericUnit Asset) : BinaryOp Asset u.toUnit u.toUnit .bool
  | lt (u : NumericUnit Asset) : BinaryOp Asset u.toUnit u.toUnit .bool
  | eq (u : Unit Asset) : BinaryOp Asset u u .bool
  | and : BinaryOp Asset .bool .bool .bool
  | or : BinaryOp Asset .bool .bool .bool

def UnaryOp.eval {Asset : Type} {u v : Unit Asset} :
    UnaryOp Asset u v → Value u → Value v
  | .neg n, x => numericValue n (- numericRat n x)
  | .not, x => !x

/-- Division checks its denominator explicitly; rational division is otherwise total at zero. -/
def BinaryOp.eval {Asset : Type} {u v w : Unit Asset} :
    BinaryOp Asset u v w → Value u → Value v → Except EvalFailure (Value w)
  | .add n, x, y => .ok (numericValue n (numericRat n x + numericRat n y))
  | .sub n, x, y => .ok (numericValue n (numericRat n x - numericRat n y))
  | .scale n, x, y => .ok (numericValue n (x * numericRat n y))
  | .divide n, x, y =>
    if y = 0 then .error .divisionByZero else .ok (numericValue n (numericRat n x / y))
  | .ratio n, x, y =>
    if numericRat n y = 0 then .error .divisionByZero
    else .ok (numericRat n x / numericRat n y)
  | .convert _ _, x, y => .ok (x * y)
  | .unconvert _ _, x, y =>
    if y = 0 then .error .divisionByZero else .ok (x / y)
  | .le n, x, y => .ok (decide (numericRat n x ≤ numericRat n y))
  | .lt n, x, y => .ok (decide (numericRat n x < numericRat n y))
  | .eq _, x, y => .ok (decide (x = y))
  | .and, x, y => .ok (x && y)
  | .or, x, y => .ok (x || y)

inductive Expr (Party Asset Domain : Type) (signature : List (Unit Asset)) :
    Unit Asset → Type where
  | lit {u} (value : Value u) : Expr Party Asset Domain signature u
  | arg {u} (v : Var signature u) : Expr Party Asset Domain signature u
  | balance {a} (cell : CellRef Party Asset Domain a) :
      Expr Party Asset Domain signature (.amount a)
  | observe {u} (key : ObservationRef Asset Domain u) : Expr Party Asset Domain signature u
  | timestamp (key : ObservationKey Domain) : Expr Party Asset Domain signature .scalar
  | now : Expr Party Asset Domain signature .scalar
  | unary {u v} (op : UnaryOp Asset u v) (x : Expr Party Asset Domain signature u) :
      Expr Party Asset Domain signature v
  | binary {u v w} (op : BinaryOp Asset u v w)
      (x : Expr Party Asset Domain signature u) (y : Expr Party Asset Domain signature v) :
      Expr Party Asset Domain signature w
  | ite {u} (condition : Expr Party Asset Domain signature .bool)
      (yes no : Expr Party Asset Domain signature u) : Expr Party Asset Domain signature u

abbrev PackedCellRef (Party Asset Domain : Type) :=
  (asset : Asset) × CellRef Party Asset Domain asset

inductive EnvRead (Domain : Type) where
  | observation (key : ObservationKey Domain)
  | currentTime
  deriving DecidableEq, Repr

structure EvalContext (Party Asset Domain : Type) (signature : List (Unit Asset)) where
  state : State Party Asset Domain
  env : Environment Asset Domain
  caller : Party
  parties : List Party
  args : Args signature
  now : Nat

def readBalance {Party Asset Domain : Type} {signature : List (Unit Asset)}
    (ctx : EvalContext Party Asset Domain signature) (ref : PackedCellRef Party Asset Domain) :
    Except EvalFailure ℚ := do
  let c ← ref.2.resolve ctx.caller ctx.parties
  return ctx.state.balance c

def readObservation {Asset Domain : Type} [DecidableEq Asset] {u : Unit Asset}
    (env : Environment Asset Domain) (ref : ObservationRef Asset Domain u) :
    Except EvalFailure (Value u) :=
  match env ref.key with
  | none => .error .missingObservation
  | some observation =>
    if h : observation.value.1 = u then .ok (h ▸ observation.value.2)
    else .error .observationUnit

/-- Binary operators, including boolean and/or, evaluate both operands. Only `ite`
selects a branch lazily. Read inventories conservatively include every branch. -/
def Expr.eval {Party Asset Domain : Type} [DecidableEq Asset]
    {signature : List (Unit Asset)} {u : Unit Asset}
    (ctx : EvalContext Party Asset Domain signature) :
    Expr Party Asset Domain signature u → Except EvalFailure (Value u)
  | .lit value => .ok value
  | .arg v => .ok (ctx.args.get v)
  | .balance ref => readBalance ctx ⟨_, ref⟩
  | .observe ref => readObservation ctx.env ref
  | .timestamp key => match ctx.env key with
    | none => .error .missingObservation
    | some observation => .ok observation.timestamp
  | .now => .ok ctx.now
  | .unary op x => do return op.eval (← x.eval ctx)
  | .binary op x y => do op.eval (← x.eval ctx) (← y.eval ctx)
  | .ite condition yes no => do
    if ← condition.eval ctx then yes.eval ctx else no.eval ctx

/-- Syntactic reads include inactive branches and all expression children. -/
def Expr.stateReads {Party Asset Domain : Type} {signature : List (Unit Asset)} {u : Unit Asset} :
    Expr Party Asset Domain signature u → List (PackedCellRef Party Asset Domain)
  | .balance ref => [⟨_, ref⟩]
  | .unary _ x => x.stateReads
  | .binary _ x y => x.stateReads ++ y.stateReads
  | .ite condition yes no => condition.stateReads ++ yes.stateReads ++ no.stateReads
  | .lit _ | .arg _ | .observe _ | .timestamp _ | .now => []

def Expr.envReads {Party Asset Domain : Type} {signature : List (Unit Asset)} {u : Unit Asset} :
    Expr Party Asset Domain signature u → List (EnvRead Domain)
  | .observe ref => [.observation ref.key]
  | .timestamp key => [.observation key]
  | .now => [.currentTime]
  | .unary _ x => x.envReads
  | .binary _ x y => x.envReads ++ y.envReads
  | .ite condition yes no => condition.envReads ++ yes.envReads ++ no.envReads
  | .lit _ | .arg _ | .balance _ => []

def Expr.resolveStateReads {Party Asset Domain : Type} {signature : List (Unit Asset)}
    {u : Unit Asset} (caller : Party) (parties : List Party)
    (expression : Expr Party Asset Domain signature u) :
    Except EvalFailure (List (Cell Party Asset Domain)) :=
  expression.stateReads.mapM (fun ref ↦ ref.2.resolve caller parties)

def EnvRead.Agree {Party Asset Domain : Type} {signature : List (Unit Asset)}
    (left right : EvalContext Party Asset Domain signature) : EnvRead Domain → Prop
  | .observation key => left.env key = right.env key
  | .currentTime => left.now = right.now

-- BEGIN PROOFS

/-- Equality on all recorded reads and typed arguments preserves the entire evaluation result,
including missing-input, wrong-unit and zero-division refusal behavior. -/
theorem Expr.eval_congr {Party Asset Domain : Type} [DecidableEq Asset]
    {signature : List (Unit Asset)} {u : Unit Asset}
    (expression : Expr Party Asset Domain signature u)
    (left right : EvalContext Party Asset Domain signature)
    (ha : left.args = right.args)
    (hs : ∀ ref ∈ expression.stateReads, readBalance left ref = readBalance right ref)
    (he : ∀ key ∈ expression.envReads, EnvRead.Agree left right key) :
    expression.eval left = expression.eval right := by
  induction expression with
  | lit value => rfl
  | arg v => simp only [Expr.eval, ha]
  | balance ref => exact hs ⟨_, ref⟩ (by simp [Expr.stateReads])
  | observe ref =>
    have h := he (.observation ref.key) (by simp [Expr.envReads])
    simp only [EnvRead.Agree] at h
    simp only [Expr.eval, readObservation, h]
  | timestamp key =>
    have h := he (.observation key) (by simp [Expr.envReads])
    simp only [EnvRead.Agree] at h
    simp only [Expr.eval, h]
  | now =>
    have h := he .currentTime (by simp [Expr.envReads])
    simp only [EnvRead.Agree] at h
    simp only [Expr.eval, h]
  | unary op x ih =>
    have hx := ih hs he
    simp only [Expr.eval, hx]
  | binary op x y ihx ihy =>
    have hx := ihx
      (fun ref h ↦ hs ref (by simp [Expr.stateReads, h]))
      (fun key h ↦ he key (by simp [Expr.envReads, h]))
    have hy := ihy
      (fun ref h ↦ hs ref (by simp [Expr.stateReads, h]))
      (fun key h ↦ he key (by simp [Expr.envReads, h]))
    simp only [Expr.eval, hx, hy]
  | ite condition yes no ihc ihy ihn =>
    have hc := ihc
      (fun ref h ↦ hs ref (by simp [Expr.stateReads, h]))
      (fun key h ↦ he key (by simp [Expr.envReads, h]))
    have hy := ihy
      (fun ref h ↦ hs ref (by simp [Expr.stateReads, h]))
      (fun key h ↦ he key (by simp [Expr.envReads, h]))
    have hn := ihn
      (fun ref h ↦ hs ref (by simp [Expr.stateReads, h]))
      (fun key h ↦ he key (by simp [Expr.envReads, h]))
    simp only [Expr.eval, hc, hy, hn]

/-- Equal caller/party inputs and equal balances at successfully resolved references suffice
for state-read agreement. Invalid party indices produce the same refusal on both sides. -/
theorem readBalance_congr {Party Asset Domain : Type} {signature : List (Unit Asset)}
    (left right : EvalContext Party Asset Domain signature) (ref : PackedCellRef Party Asset Domain)
    (hc : left.caller = right.caller) (hp : left.parties = right.parties)
    (hs : ∀ c, ref.2.resolve left.caller left.parties = .ok c →
      left.state.balance c = right.state.balance c) :
    readBalance left ref = readBalance right ref := by
  simp only [readBalance, ← hc, ← hp]
  cases h : ref.2.resolve left.caller left.parties with
  | error reason => rfl
  | ok c => simp [hs c h]

/-- A concrete ledger formulation of read dependence. Only successfully resolved cells need
equal balances; the same caller and party arguments also preserve resolution failures. -/
theorem Expr.eval_congr_of_resolved {Party Asset Domain : Type} [DecidableEq Asset]
    {signature : List (Unit Asset)} {u : Unit Asset}
    (expression : Expr Party Asset Domain signature u)
    (left right : EvalContext Party Asset Domain signature)
    (ha : left.args = right.args) (hc : left.caller = right.caller)
    (hp : left.parties = right.parties)
    (hs : ∀ ref ∈ expression.stateReads, ∀ c,
      ref.2.resolve left.caller left.parties = .ok c →
        left.state.balance c = right.state.balance c)
    (he : ∀ key ∈ expression.envReads, EnvRead.Agree left right key) :
    expression.eval left = expression.eval right := by
  apply expression.eval_congr left right ha _ he
  intro ref href
  exact readBalance_congr left right ref hc hp (hs ref href)

end DefiKernel.Typed


===== INPUT lean/DefiKernel/Typed/Transition.lean ORIGINAL_SHA256 73f264636236219e45720a531209f8c7ed8f5ee3f615fa34d58bc5596c4499d2 RENDERED_SHA256 73f264636236219e45720a531209f8c7ed8f5ee3f615fa34d58bc5596c4499d2 =====
import DefiKernel.Typed.Expr
import DefiKernel.Typed.Authority
import Mathlib.Tactic.Linarith

/-! Registered first-order transitions. Checks concern aggregate net effects; they do not model
intermediate debit order, consumable allowances, replay prevention, or observation truth. -/
namespace DefiKernel.Typed

structure CellDelta (Party Asset Domain : Type) (signature : List (Unit Asset)) where
  asset : Asset
  target : CellRef Party Asset Domain asset
  amount : Expr Party Asset Domain signature (.amount asset)

structure SupplyDelta (Party Asset Domain : Type) (signature : List (Unit Asset)) where
  domain : Domain
  asset : Asset
  amount : Expr Party Asset Domain signature (.amount asset)

structure Template (Party Asset Domain : Type) where
  signature : List (Unit Asset)
  domain : Domain
  partyArity : Nat
  guard : Expr Party Asset Domain signature .bool
  deltas : List (CellDelta Party Asset Domain signature)
  supplyDeltas : List (SupplyDelta Party Asset Domain signature)
  stateReads : List (PackedCellRef Party Asset Domain)
  envReads : List (EnvRead Domain)
  writes : List (PackedCellRef Party Asset Domain)

abbrev Registry (Party Asset Domain : Type) := OperationId → Option (Template Party Asset Domain)

/-- Issuance and execution use the same trusted registry to determine the operation domain. -/
def registryAuthorityConfig {Party Asset Domain : Type} (registry : Registry Party Asset Domain)
    (domainAdmin : Domain → Party) : AuthorityConfig Party Domain :=
  ⟨domainAdmin, fun operation ↦ (registry operation).map Template.domain⟩

structure Request (Party Asset Domain : Type) where
  operation : OperationId
  parties : List Party
  arguments : List (PackedValue Asset)
  capabilityIds : List CapabilityId
  claimedActor : Option Party := none

inductive Refusal where
  | unknownOperation
  | actorMismatch
  | domainMismatch
  | partyArity
  | evaluation (reason : EvalFailure)
  | unauthorizedInvoke
  | guard
  | stateReadFootprint
  | envReadFootprint
  | crossDomain
  | unauthorizedDebit
  | unauthorizedSupply
  | insufficientFunds
  | accounting
  | writeFootprint
  deriving DecidableEq, Repr

/-- Internal evaluated data; caller requests cannot supply this record to `execute`. -/
structure Evaluated (Party Asset Domain : Type) where
  guard : Bool
  deltas : List (Cell Party Asset Domain × ℚ)
  supplies : List ((Domain × Asset) × ℚ)
  requiredStateReads : List (Cell Party Asset Domain)
  requiredEnvReads : List (EnvRead Domain)
  declaredStateReads : List (Cell Party Asset Domain)
  declaredEnvReads : List (EnvRead Domain)
  writes : List (Cell Party Asset Domain)

structure ExecutionResult (Party Asset Domain : Type) where
  state : State Party Asset Domain
  capabilities : CapabilityStore Party Asset Domain

variable {Party Asset Domain : Type}
variable [DecidableEq Party] [DecidableEq Asset] [DecidableEq Domain]

def Template.requiredStateReads (template : Template Party Asset Domain) :=
  template.guard.stateReads ++ template.deltas.flatMap (fun d ↦ d.amount.stateReads) ++
    template.supplyDeltas.flatMap (fun d ↦ d.amount.stateReads)

def Template.requiredEnvReads (template : Template Party Asset Domain) :=
  template.guard.envReads ++ template.deltas.flatMap (fun d ↦ d.amount.envReads) ++
    template.supplyDeltas.flatMap (fun d ↦ d.amount.envReads)

def resolveRefs (caller : Party) (parties : List Party)
    (refs : List (PackedCellRef Party Asset Domain)) :
    Except EvalFailure (List (Cell Party Asset Domain)) :=
  refs.mapM (fun ref ↦ ref.2.resolve caller parties)

def Template.evaluate (template : Template Party Asset Domain)
    (ctx : EvalContext Party Asset Domain template.signature) :
    Except EvalFailure (Evaluated Party Asset Domain) := do
  let required ← resolveRefs ctx.caller ctx.parties template.requiredStateReads
  let declared ← resolveRefs ctx.caller ctx.parties template.stateReads
  let writes ← resolveRefs ctx.caller ctx.parties template.writes
  let guard ← template.guard.eval ctx
  let deltas ← template.deltas.mapM fun d ↦ do
    let cell ← d.target.resolve ctx.caller ctx.parties
    let amount ← d.amount.eval ctx
    return (cell, amount)
  let supplies ← template.supplyDeltas.mapM fun d ↦ do
    let amount ← d.amount.eval ctx
    return ((d.domain, d.asset), amount)
  return ⟨guard, deltas, supplies, required, template.requiredEnvReads, declared,
    template.envReads, writes⟩

/-- Every repeated entry contributes by addition, including repeated supply changes. -/
def Evaluated.effect (evaluated : Evaluated Party Asset Domain)
    (cell : Cell Party Asset Domain) : ℚ :=
  (evaluated.deltas.map (fun d ↦ if d.1 = cell then d.2 else 0)).sum

def Evaluated.supply (evaluated : Evaluated Party Asset Domain)
    (domain : Domain) (asset : Asset) : ℚ :=
  (evaluated.supplies.map (fun d ↦ if d.1 = (domain, asset) then d.2 else 0)).sum

variable [Fintype Party] [Fintype Asset] [Fintype Domain]

def Evaluated.stateReadsOK (e : Evaluated Party Asset Domain) : Bool :=
  e.requiredStateReads.all (fun c ↦ decide (c ∈ e.declaredStateReads))

def Evaluated.envReadsOK (e : Evaluated Party Asset Domain) : Bool :=
  e.requiredEnvReads.all (fun k ↦ decide (k ∈ e.declaredEnvReads))

/-- Required state reads and actual net movement stay within the invocation domain.
Environment observations may explicitly refer to other domains; their truth is adapter supplied. -/
def Evaluated.domainOK (e : Evaluated Party Asset Domain) (domain : Domain) : Bool :=
  decide ((∀ c ∈ e.requiredStateReads, c.1 = domain) ∧
    (∀ c, e.effect c ≠ 0 → c.1 = domain) ∧ ∀ d a, e.supply d a ≠ 0 → d = domain)

def Evaluated.debitsOK (e : Evaluated Party Asset Domain)
    (store : CapabilityStore Party Asset Domain) (request : Request Party Asset Domain)
    (ctx : InvocationContext Party Domain) : Bool :=
  decide (∀ c, e.effect c < 0 →
    hasAuthority store request.capabilityIds ctx request.operation (.debit c) = true)

def Evaluated.suppliesOK (e : Evaluated Party Asset Domain)
    (store : CapabilityStore Party Asset Domain) (request : Request Party Asset Domain)
    (ctx : InvocationContext Party Domain) : Bool :=
  decide (∀ d a, e.supply d a ≠ 0 →
    hasAuthority store request.capabilityIds ctx request.operation (.changeSupply d a) = true)

def Evaluated.accountingOK (e : Evaluated Party Asset Domain) : Bool :=
  decide (∀ d a, ∑ p, e.effect (d, p, a) = e.supply d a)

def Evaluated.writesOK (e : Evaluated Party Asset Domain) : Bool :=
  decide (∀ c, c ∉ e.writes → e.effect c = 0)

/-- All branches are computational. Only the nonnegativity witness enters the state value. -/
def applyEvaluated (store : CapabilityStore Party Asset Domain)
    (ctx : InvocationContext Party Domain) (request : Request Party Asset Domain)
    (state : State Party Asset Domain) (e : Evaluated Party Asset Domain) :
    Except Refusal (ExecutionResult Party Asset Domain) :=
  if !e.guard then .error .guard
  else if !e.stateReadsOK then .error .stateReadFootprint
  else if !e.envReadsOK then .error .envReadFootprint
  else if !e.domainOK ctx.domain then .error .crossDomain
  else if !e.debitsOK store request ctx then .error .unauthorizedDebit
  else if !e.suppliesOK store request ctx then .error .unauthorizedSupply
  else if hn : ∀ c, 0 ≤ state.balance c + e.effect c then
    if !e.accountingOK then .error .accounting
    else if !e.writesOK then .error .writeFootprint
    else .ok ⟨⟨fun c ↦ state.balance c + e.effect c, hn⟩, store⟩
  else .error .insufficientFunds

/-- Registry selection and actor/domain binding precede `Args.check`, which precedes invoke
checking. Template evaluation (including effect/supply expressions) precedes guard and footprint
checks. Successful read/domain conditions are not refused-path confidentiality guarantees. -/
def execute (registry : Registry Party Asset Domain)
    (store : CapabilityStore Party Asset Domain) (ctx : InvocationContext Party Domain)
    (env : Environment Asset Domain) (now : Nat) (request : Request Party Asset Domain)
    (state : State Party Asset Domain) : Except Refusal (ExecutionResult Party Asset Domain) := do
  let template ← match registry request.operation with
    | none => .error .unknownOperation
    | some template => .ok template
  if request.claimedActor.isSome && request.claimedActor != some ctx.principal then
    throw .actorMismatch
  if ctx.domain != template.domain then throw .domainMismatch
  if request.parties.length != template.partyArity then throw .partyArity
  let args ← (Args.check template.signature request.arguments).mapError Refusal.evaluation
  if !hasAuthority store request.capabilityIds ctx request.operation .invoke then
    throw .unauthorizedInvoke
  let evaluated ← (template.evaluate ⟨state, env, ctx.principal, request.parties, args, now⟩)
    |>.mapError Refusal.evaluation
  applyEvaluated store ctx request state evaluated

/-- Logical view of the actual checks; this does not construct executable states. -/
def Evaluated.Valid (store : CapabilityStore Party Asset Domain)
    (ctx : InvocationContext Party Domain) (request : Request Party Asset Domain)
    (state : State Party Asset Domain) (e : Evaluated Party Asset Domain) : Prop :=
  e.guard = true ∧ e.stateReadsOK = true ∧ e.envReadsOK = true ∧
  e.domainOK ctx.domain = true ∧ e.debitsOK store request ctx = true ∧
  e.suppliesOK store request ctx = true ∧ (∀ c, 0 ≤ state.balance c + e.effect c) ∧
  e.accountingOK = true ∧ e.writesOK = true

variable (registry : Registry Party Asset Domain) (store : CapabilityStore Party Asset Domain)
variable (ctx : InvocationContext Party Domain) (env : Environment Asset Domain) (now : Nat)
variable (request : Request Party Asset Domain) (state : State Party Asset Domain)
variable (post : ExecutionResult Party Asset Domain)

-- BEGIN PROOFS

theorem applyEvaluated_ok_iff (store : CapabilityStore Party Asset Domain)
    (ctx : InvocationContext Party Domain) (request : Request Party Asset Domain)
    (state : State Party Asset Domain) (e : Evaluated Party Asset Domain)
    (post : ExecutionResult Party Asset Domain) :
    applyEvaluated store ctx request state e = .ok post ↔
      e.Valid store ctx request state ∧ post.capabilities = store ∧
      ∀ c, post.state.balance c = state.balance c + e.effect c := by
  rcases post with ⟨⟨balance, nonneg⟩, capabilities⟩
  unfold applyEvaluated
  split_ifs <;> simp_all [Evaluated.Valid, funext_iff]
  aesop

/-- Success binds the selected template, typed arguments and actual evaluation result to all
checks and the exact post-state. No caller-supplied validity certificate occurs here. -/
theorem execute_ok_iff (registry : Registry Party Asset Domain)
    (store : CapabilityStore Party Asset Domain) (ctx : InvocationContext Party Domain)
    (env : Environment Asset Domain) (now : Nat) (request : Request Party Asset Domain)
    (state : State Party Asset Domain) (post : ExecutionResult Party Asset Domain) :
    execute registry store ctx env now request state = .ok post ↔
      ∃ template, registry request.operation = some template ∧
      (request.claimedActor = none ∨ request.claimedActor = some ctx.principal) ∧
      ctx.domain = template.domain ∧ request.parties.length = template.partyArity ∧
      ∃ args, Args.check template.signature request.arguments = .ok args ∧
      hasAuthority store request.capabilityIds ctx request.operation .invoke = true ∧
      ∃ e, template.evaluate ⟨state, env, ctx.principal, request.parties, args, now⟩ = .ok e ∧
      e.Valid store ctx request state ∧ post.capabilities = store ∧
      ∀ c, post.state.balance c = state.balance c + e.effect c := by
  unfold execute
  cases hr : registry request.operation with
  | none => simp [bind, Except.bind]
  | some template =>
    simp only [bind, Except.bind, Option.some.injEq, exists_eq_left']
    cases hc : request.claimedActor <;>
      simp only [Option.isSome, Bool.false_and, Bool.true_and] <;>
      split_ifs <;> simp_all [throw, throwThe]
    all_goals
      cases ha : Args.check template.signature request.arguments <;>
        simp_all [Except.mapError]
    all_goals
      rename_i args
      cases he : template.evaluate ⟨state, env, ctx.principal, request.parties, args, now⟩ <;>
        simp_all [applyEvaluated_ok_iff]

theorem applyEvaluated_accounting (store : CapabilityStore Party Asset Domain)
    (ctx : InvocationContext Party Domain) (request : Request Party Asset Domain)
    (state : State Party Asset Domain) (e : Evaluated Party Asset Domain)
    (post : ExecutionResult Party Asset Domain)
    (h : applyEvaluated store ctx request state e = .ok post) (d : Domain) (a : Asset) :
    total post.state d a = total state d a + e.supply d a := by
  obtain ⟨hv, _, hu⟩ := (applyEvaluated_ok_iff ..).mp h
  have ha : ∀ d a, ∑ p, e.effect (d, p, a) = e.supply d a :=
    of_decide_eq_true hv.2.2.2.2.2.2.2.1
  simp only [total, hu, Finset.sum_add_distrib, ha]

theorem applyEvaluated_locality (store : CapabilityStore Party Asset Domain)
    (ctx : InvocationContext Party Domain) (request : Request Party Asset Domain)
    (state : State Party Asset Domain) (e : Evaluated Party Asset Domain)
    (post : ExecutionResult Party Asset Domain)
    (h : applyEvaluated store ctx request state e = .ok post)
    (c : Cell Party Asset Domain) (hc : c ∉ e.writes) :
    post.state.balance c = state.balance c := by
  obtain ⟨hv, _, hu⟩ := (applyEvaluated_ok_iff ..).mp h
  have hw : ∀ c, c ∉ e.writes → e.effect c = 0 :=
    of_decide_eq_true hv.2.2.2.2.2.2.2.2
  simp [hu, hw c hc]

theorem applyEvaluated_debit_authority (store : CapabilityStore Party Asset Domain)
    (ctx : InvocationContext Party Domain) (request : Request Party Asset Domain)
    (state : State Party Asset Domain) (e : Evaluated Party Asset Domain)
    (post : ExecutionResult Party Asset Domain)
    (h : applyEvaluated store ctx request state e = .ok post)
    (c : Cell Party Asset Domain) (hc : post.state.balance c < state.balance c) :
    hasAuthority store request.capabilityIds ctx request.operation (.debit c) = true := by
  obtain ⟨hv, _, hu⟩ := (applyEvaluated_ok_iff ..).mp h
  have hd : ∀ c, e.effect c < 0 →
      hasAuthority store request.capabilityIds ctx request.operation (.debit c) = true :=
    of_decide_eq_true hv.2.2.2.2.1
  apply hd c
  rw [hu] at hc
  linarith

theorem applyEvaluated_supply_authority (store : CapabilityStore Party Asset Domain)
    (ctx : InvocationContext Party Domain) (request : Request Party Asset Domain)
    (state : State Party Asset Domain) (e : Evaluated Party Asset Domain)
    (post : ExecutionResult Party Asset Domain)
    (h : applyEvaluated store ctx request state e = .ok post) (d : Domain) (a : Asset)
    (hc : total post.state d a ≠ total state d a) :
    hasAuthority store request.capabilityIds ctx request.operation (.changeSupply d a) = true := by
  obtain ⟨hv, _, _⟩ := (applyEvaluated_ok_iff ..).mp h
  have hs : ∀ d a, e.supply d a ≠ 0 →
      hasAuthority store request.capabilityIds ctx request.operation (.changeSupply d a) = true :=
    of_decide_eq_true hv.2.2.2.2.2.1
  apply hs d a
  intro hz
  exact hc (by simpa [hz] using applyEvaluated_accounting store ctx request state e post h d a)

/-- Every successful execution has a selected registered template and a checked evaluation
whose concrete application produced the post-state. -/
theorem execute_evaluated
    (h : execute registry store ctx env now request state = .ok post) :
    ∃ template, registry request.operation = some template ∧
      ∃ args, Args.check template.signature request.arguments = .ok args ∧
      ∃ e, template.evaluate ⟨state, env, ctx.principal, request.parties, args, now⟩ = .ok e ∧
        applyEvaluated store ctx request state e = .ok post := by
  obtain ⟨t, ht, _, _, _, args, ha, _, e, he, hv, hcap, hu⟩ := (execute_ok_iff ..).mp h
  exact ⟨t, ht, args, ha, e, he, (applyEvaluated_ok_iff ..).mpr ⟨hv, hcap, hu⟩⟩

theorem execute_preserves_capabilities
    (h : execute registry store ctx env now request state = .ok post) :
    post.capabilities = store := by
  obtain ⟨_, _, _, _, _, _, _, _, _, _, _, hcap, _⟩ := (execute_ok_iff ..).mp h
  exact hcap

theorem execute_nonnegative
    (h : execute registry store ctx env now request state = .ok post) :
    ∀ c, 0 ≤ post.state.balance c := by
  obtain ⟨_, _, _, _, _, _, _, _, e, _, hv, _, hu⟩ := (execute_ok_iff ..).mp h
  intro c
  rw [hu]
  exact hv.2.2.2.2.2.2.1 c

theorem execute_invocation_authority
    (h : execute registry store ctx env now request state = .ok post) :
    ∃ id ∈ request.capabilityIds, ∃ cap,
      store.lookup id = some cap ∧ cap.live = true ∧ cap.holder = ctx.principal ∧
      cap.domain = ctx.domain ∧ cap.operation = request.operation ∧ cap.right = .invoke := by
  obtain ⟨_, _, _, _, _, _, _, hi, _⟩ := (execute_ok_iff ..).mp h
  obtain ⟨id, hid, hi⟩ := (hasAuthority_iff ..).mp hi
  obtain ⟨cap, hcap, hl, hh, hd, ho, hr, _⟩ := (authorizesId_iff ..).mp hi
  exact ⟨id, hid, cap, hcap, hl, hh, hd, ho, hr⟩

theorem execute_debit_authority
    (h : execute registry store ctx env now request state = .ok post)
    (c : Cell Party Asset Domain) (hc : post.state.balance c < state.balance c) :
    ∃ id ∈ request.capabilityIds, ∃ cap,
      store.lookup id = some cap ∧ cap.live = true ∧ cap.holder = ctx.principal ∧
      cap.domain = ctx.domain ∧ cap.operation = request.operation ∧ cap.right = .debit c := by
  obtain ⟨_, _, _, _, e, _, he⟩ := execute_evaluated registry store ctx env now request state post h
  have hi := applyEvaluated_debit_authority store ctx request state e post he c hc
  obtain ⟨id, hid, hi⟩ := (hasAuthority_iff ..).mp hi
  obtain ⟨cap, hcap, hl, hh, hd, ho, hr, _⟩ := (authorizesId_iff ..).mp hi
  exact ⟨id, hid, cap, hcap, hl, hh, hd, ho, hr⟩

theorem execute_supply_authority
    (h : execute registry store ctx env now request state = .ok post) (d : Domain) (a : Asset)
    (hc : total post.state d a ≠ total state d a) :
    ∃ id ∈ request.capabilityIds, ∃ cap,
      store.lookup id = some cap ∧ cap.live = true ∧ cap.holder = ctx.principal ∧
      cap.domain = ctx.domain ∧ cap.operation = request.operation ∧
      cap.right = .changeSupply d a := by
  obtain ⟨_, _, _, _, e, _, he⟩ := execute_evaluated registry store ctx env now request state post h
  have hi := applyEvaluated_supply_authority store ctx request state e post he d a hc
  obtain ⟨id, hid, hi⟩ := (hasAuthority_iff ..).mp hi
  obtain ⟨cap, hcap, hl, hh, hd, ho, hr, _⟩ := (authorizesId_iff ..).mp hi
  exact ⟨id, hid, cap, hcap, hl, hh, hd, ho, hr⟩

theorem execute_accounting_and_locality
    (h : execute registry store ctx env now request state = .ok post) :
    ∃ template, registry request.operation = some template ∧
      ∃ args, Args.check template.signature request.arguments = .ok args ∧
      ∃ e, template.evaluate ⟨state, env, ctx.principal, request.parties, args, now⟩ = .ok e ∧
        (∀ d a, total post.state d a = total state d a + e.supply d a) ∧
        (∀ c, c ∉ e.writes → post.state.balance c = state.balance c) := by
  obtain ⟨t, ht, args, ha, e, he, happly⟩ :=
    execute_evaluated registry store ctx env now request state post h
  exact ⟨t, ht, args, ha, e, he,
    applyEvaluated_accounting store ctx request state e post happly,
    applyEvaluated_locality store ctx request state e post happly⟩

/-- Successfully recorded reads are declared and domain-local, and all changed balances stay
in the authenticated invocation domain. -/
theorem execute_reads_and_domain
    (h : execute registry store ctx env now request state = .ok post) :
    ∃ template, registry request.operation = some template ∧
      ctx.domain = template.domain ∧
      ∃ args, Args.check template.signature request.arguments = .ok args ∧
      ∃ e, template.evaluate ⟨state, env, ctx.principal, request.parties, args, now⟩ = .ok e ∧
        (∀ c ∈ e.requiredStateReads, c ∈ e.declaredStateReads ∧ c.1 = ctx.domain) ∧
        (∀ k ∈ e.requiredEnvReads, k ∈ e.declaredEnvReads) ∧
        (∀ c, post.state.balance c ≠ state.balance c → c.1 = ctx.domain) := by
  obtain ⟨t, ht, _, hd, _, args, ha, _, e, he, hv, _, hu⟩ := (execute_ok_iff ..).mp h
  have hs : ∀ c ∈ e.requiredStateReads, c ∈ e.declaredStateReads := by
    simpa [Evaluated.stateReadsOK] using hv.2.1
  have hen : ∀ k ∈ e.requiredEnvReads, k ∈ e.declaredEnvReads := by
    simpa [Evaluated.envReadsOK] using hv.2.2.1
  have hdom : (∀ c ∈ e.requiredStateReads, c.1 = ctx.domain) ∧
      (∀ c, e.effect c ≠ 0 → c.1 = ctx.domain) ∧
      ∀ d a, e.supply d a ≠ 0 → d = ctx.domain := of_decide_eq_true hv.2.2.2.1
  refine ⟨t, ht, hd, args, ha, e, he, ?_, hen, ?_⟩
  · exact fun c hc ↦ ⟨hs c hc, hdom.1 c hc⟩
  · intro c hc
    apply hdom.2.1 c
    intro hz
    exact hc (by simp [hu, hz])

omit [Fintype Party] [Fintype Asset] [Fintype Domain] in
theorem Evaluated.effect_cons (e : Evaluated Party Asset Domain)
    (entry : Cell Party Asset Domain × ℚ) (c : Cell Party Asset Domain) :
    ({ e with deltas := entry :: e.deltas } : Evaluated Party Asset Domain).effect c =
      (if entry.1 = c then entry.2 else 0) + e.effect c := by
  simp [Evaluated.effect]

omit [DecidableEq Party] [Fintype Party] [Fintype Asset] [Fintype Domain] in
theorem Evaluated.supply_cons (e : Evaluated Party Asset Domain)
    (entry : (Domain × Asset) × ℚ) (d : Domain) (a : Asset) :
    ({ e with supplies := entry :: e.supplies } : Evaluated Party Asset Domain).supply d a =
      (if entry.1 = (d, a) then entry.2 else 0) + e.supply d a := by
  simp [Evaluated.supply]

end DefiKernel.Typed


===== INPUT lean/DefiKernel/Typed/Types.lean ORIGINAL_SHA256 5f2b7d30028c7445f5523b9a06cb1fb21f36fc28e38d50844d4270177f601f82 RENDERED_SHA256 5f2b7d30028c7445f5523b9a06cb1fb21f36fc28e38d50844d4270177f601f82 =====
import Mathlib.Data.Rat.Defs
import Mathlib.Algebra.BigOperators.Group.Finset.Basic
import Mathlib.Data.Fintype.Prod

/-! Reusable finite-ledger identities and dimensioned values. Identity authentication,
observation truth and the finite deployment universe are external assumptions. -/
namespace DefiKernel.Typed

structure ClaimId where
  value : Nat
  deriving DecidableEq, Repr

structure CapabilityId where
  value : Nat
  deriving DecidableEq, Repr

structure OperationId where
  value : Nat
  deriving DecidableEq, Repr

structure ObservationId where
  value : Nat
  deriving DecidableEq, Repr

abbrev Cell (Party Asset Domain : Type) := Domain × Party × Asset

/-- Amount expressions can be signed; a quantity is explicitly nonnegative. -/
structure Quantity {Asset : Type} (asset : Asset) where
  amount : ℚ
  nonneg : 0 ≤ amount

structure State (Party Asset Domain : Type) where
  balance : Cell Party Asset Domain → ℚ
  nonneg : ∀ c, 0 ≤ balance c

def total {Party Asset Domain : Type} [Fintype Party]
    (s : State Party Asset Domain) (domain : Domain) (asset : Asset) : ℚ :=
  ∑ party, s.balance (domain, party, asset)

/-- A price is quote-asset units per one base-asset unit. -/
inductive Unit (Asset : Type) where
  | amount (asset : Asset)
  | price (base quote : Asset)
  | scalar
  | bool
  deriving DecidableEq, Repr

/-- Numeric dimensions exclude booleans without a user-supplied typeclass. -/
inductive NumericUnit (Asset : Type) where
  | amount (asset : Asset)
  | price (base quote : Asset)
  | scalar
  deriving DecidableEq, Repr

abbrev NumericUnit.toUnit {Asset : Type} : NumericUnit Asset → Unit Asset
  | .amount a => .amount a
  | .price a b => .price a b
  | .scalar => .scalar

abbrev Value {Asset : Type} : Unit Asset → Type
  | .bool => Bool
  | .amount _ | .price _ _ | .scalar => ℚ

instance {Asset : Type} (u : Unit Asset) : DecidableEq (Value u) := by
  cases u <;> exact inferInstance

instance {Asset : Type} (u : Unit Asset) : Repr (Value u) := by
  cases u <;> exact inferInstance

def numericValue {Asset : Type} (u : NumericUnit Asset) (q : ℚ) : Value u.toUnit :=
  match u with
  | .amount _ | .price _ _ | .scalar => q

def numericRat {Asset : Type} (u : NumericUnit Asset) (v : Value u.toUnit) : ℚ :=
  match u with
  | .amount _ | .price _ _ | .scalar => v

abbrev PackedValue (Asset : Type) := (u : Unit Asset) × Value u

inductive EvalFailure where
  | argumentCount
  | argumentUnit
  | partyArgument
  | missingObservation
  | observationUnit
  | divisionByZero
  deriving DecidableEq, Repr

inductive PartyRef (Party : Type) where
  | caller
  | literal (party : Party)
  | argument (index : Nat)
  deriving DecidableEq, Repr

def PartyRef.resolve {Party : Type} (caller : Party) (parties : List Party) :
    PartyRef Party → Except EvalFailure Party
  | .caller => .ok caller
  | .literal p => .ok p
  | .argument n => match parties[n]? with
    | some p => .ok p
    | none => .error .partyArgument

structure CellRef (Party Asset Domain : Type) (asset : Asset) where
  domain : Domain
  owner : PartyRef Party
  deriving DecidableEq, Repr

def CellRef.resolve {Party Asset Domain : Type} {asset : Asset}
    (caller : Party) (parties : List Party) (c : CellRef Party Asset Domain asset) :
    Except EvalFailure (Cell Party Asset Domain) := do
  let party ← c.owner.resolve caller parties
  return (c.domain, party, asset)

structure ObservationKey (Domain : Type) where
  domain : Domain
  id : ObservationId
  deriving DecidableEq, Repr

/-- Expected unit is intrinsic; the environment's delivered unit is checked at lookup. -/
structure ObservationRef (Asset Domain : Type) (unit : Unit Asset) where
  key : ObservationKey Domain
  deriving DecidableEq, Repr

structure Observation (Asset : Type) where
  value : PackedValue Asset
  timestamp : Nat

abbrev Environment (Asset Domain : Type) := ObservationKey Domain → Option (Observation Asset)

/-- Adapter-supplied identity. Constructing this value is not signature verification. -/
structure InvocationContext (Party Domain : Type) where
  principal : Party
  domain : Domain
  deriving DecidableEq, Repr

-- BEGIN PROOFS

theorem numericRat_numericValue {Asset : Type} (u : NumericUnit Asset) (q : ℚ) :
    numericRat u (numericValue u q) = q := by cases u <;> rfl

theorem numericValue_numericRat {Asset : Type} (u : NumericUnit Asset) (v : Value u.toUnit) :
    numericValue u (numericRat u v) = v := by cases u <;> rfl

end DefiKernel.Typed


===== INPUT lean/lean-toolchain ORIGINAL_SHA256 0d3c76ccd8772d8bcbe207241421a760312b71a6aa82f84194391fdf5cb026d6 RENDERED_SHA256 0d3c76ccd8772d8bcbe207241421a760312b71a6aa82f84194391fdf5cb026d6 =====
leanprover/lean4:v4.33.0-rc2


===== INPUT lean/lakefile.toml ORIGINAL_SHA256 4a1684945bf3632ee11a93b4529ce45335b97a878ca9a4a9a295981e7e97aa86 RENDERED_SHA256 4a1684945bf3632ee11a93b4529ce45335b97a878ca9a4a9a295981e7e97aa86 =====
name = "defialgebra"
version = "0.1.0"
keywords = ["math"]
defaultTargets = ["Defialgebra", "DefiKernel"]

[leanOptions]
pp.unicode.fun = true # pretty-prints `fun a ↦ b`
relaxedAutoImplicit = false
weak.linter.mathlibStandardSet = true
maxSynthPendingDepth = 3

[[require]]
name = "mathlib"
scope = "leanprover-community"
rev = "v4.33.0-rc2"

[[lean_lib]]
name = "Defialgebra"

[[lean_lib]]
name = "DefiKernel"


===== INPUT lean/lake-manifest.json ORIGINAL_SHA256 8a6ceb0b073bcb3e437c3258aedf250b38da4dec0f696db6b2717bd987c43002 RENDERED_SHA256 8a6ceb0b073bcb3e437c3258aedf250b38da4dec0f696db6b2717bd987c43002 =====
{"version": "1.2.0",
 "packagesDir": ".lake/packages",
 "packages":
 [{"url": "https://github.com/leanprover-community/mathlib4",
   "type": "git",
   "subDir": null,
   "scope": "leanprover-community",
   "rev": "51e6992efd06126df61a496bebf8f49482a4e129",
   "name": "mathlib",
   "manifestFile": "lake-manifest.json",
   "inputRev": "v4.33.0-rc2",
   "inherited": false,
   "configFile": "lakefile.lean"},
  {"url": "https://github.com/leanprover-community/plausible",
   "type": "git",
   "subDir": null,
   "scope": "leanprover-community",
   "rev": "123d15766ba49356c02ebad2a4462dfe12d79899",
   "name": "plausible",
   "manifestFile": "lake-manifest.json",
   "inputRev": "main",
   "inherited": true,
   "configFile": "lakefile.toml"},
  {"url": "https://github.com/leanprover-community/LeanSearchClient",
   "type": "git",
   "subDir": null,
   "scope": "leanprover-community",
   "rev": "f5c090429dff3cf66cb65562526c9ea6e8edfbcb",
   "name": "LeanSearchClient",
   "manifestFile": "lake-manifest.json",
   "inputRev": "main",
   "inherited": true,
   "configFile": "lakefile.toml"},
  {"url": "https://github.com/leanprover-community/import-graph",
   "type": "git",
   "subDir": null,
   "scope": "leanprover-community",
   "rev": "bb3469a87774349fe01898d8bf2fc6a1ce6411ca",
   "name": "importGraph",
   "manifestFile": "lake-manifest.json",
   "inputRev": "main",
   "inherited": true,
   "configFile": "lakefile.toml"},
  {"url": "https://github.com/leanprover-community/ProofWidgets4",
   "type": "git",
   "subDir": null,
   "scope": "leanprover-community",
   "rev": "222c58dad7706a6e7cae46c0edd65ea881d3ee27",
   "name": "proofwidgets",
   "manifestFile": "lake-manifest.json",
   "inputRev": "main",
   "inherited": true,
   "configFile": "lakefile.lean"},
  {"url": "https://github.com/leanprover-community/aesop",
   "type": "git",
   "subDir": null,
   "scope": "leanprover-community",
   "rev": "7db8190085343afde2f5d2cdcc9bac719b6ec02c",
   "name": "aesop",
   "manifestFile": "lake-manifest.json",
   "inputRev": "master",
   "inherited": true,
   "configFile": "lakefile.toml"},
  {"url": "https://github.com/leanprover-community/quote4",
   "type": "git",
   "subDir": null,
   "scope": "leanprover-community",
   "rev": "ef42f8944eaf5b6cbfbe75d1917d824c7dd6cf33",
   "name": "Qq",
   "manifestFile": "lake-manifest.json",
   "inputRev": "master",
   "inherited": true,
   "configFile": "lakefile.toml"},
  {"url": "https://github.com/leanprover-community/batteries",
   "type": "git",
   "subDir": null,
   "scope": "leanprover-community",
   "rev": "76e1c118b0700b4ceafe99532e887d6431625e1a",
   "name": "batteries",
   "manifestFile": "lake-manifest.json",
   "inputRev": "main",
   "inherited": true,
   "configFile": "lakefile.toml"},
  {"url": "https://github.com/leanprover/lean4-cli",
   "type": "git",
   "subDir": null,
   "scope": "leanprover",
   "rev": "1319485273bf87833fa472afbcefdedecb16b45f",
   "name": "Cli",
   "manifestFile": "lake-manifest.json",
   "inputRev": "v4.33.0-rc2",
   "inherited": true,
   "configFile": "lakefile.toml"}],
 "name": "defialgebra",
 "lakeDir": ".lake",
 "fixedToolchain": false}
