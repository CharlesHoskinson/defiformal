# Core draft semantic review

Status: PRELIMINARY; NO IMPLEMENTATION VERDICT. Native Grok is actively editing and compiling. GPT-6 reviewed source read-only and ran no Lake, Lean, LSP or build command. Findings apply to the exact hashes below, not an assumed final candidate. The accepted plan and execution role contract remain the authority; this report does not change them.

## Targeted required statement correction

**C1 — CausalRuntime.lean:79, `continueMonitored_common_prefix`.** At inspected hash `0c47ae5ea6a23dbceba051d5df95d22bc9466c743dd79687195617facdaaf0d8`, this theorem concludes two append/decomposition equalities, one for each suffix. It does not state the required equality of monitored states after exactly `prefix.length` tokens in `prefix ++ suffix₁` and `prefix ++ suffix₂`.

The append helper is useful and the runtime behavior appears correct. Add an explicit corollary comparing continuation over `(prefix ++ suffix₁).take prefix.length` and `(prefix ++ suffix₂).take prefix.length`, or the equivalent precise trace-prefix projection. Keep configuration, branches, boundaries, update, initial monitor and initial machine identical. The result can follow from each taken schedule equaling prefix. Do not claim suffix-final states are equal or that callbacks cannot capture external constants. This is the contract in causal-prefix-evidence/spec.md, “Actual-prefix monitor correspondence”, fixed-parameter common-prefix scenario, and design D5.

The actual replay/inductive monitor trace theorem also remains a required later deliverable. Its absence in these four draft core files is an ownership reminder, not a separate defect: Causal may supply it. Similarly binary conversions/simulation and financial interference/witness proofs belong to their assigned lanes and cannot be credited from this review.

## Source inspection results

- Schedule uses an explicit nodup/complete ordered roster and DecidableEq B, without Fintype B or noncomputable enumeration. Empty and singleton constructors have the required typed premises. Count checking walks roster order. Admission validates the catalog, analyzes full branches in order and then checks counts; there is no footprint-overlap rejection.
- Execution selects by own consumed position, uses actual executeStep with own nextIndex/history and the current successful-index boundary, and publishes actual successful world/event/receipt/output/attempt. The selected local update preserves all peer locals. Failed/exhausted selections increment consumed only. Refusal retains the world and successful fields, records the exact located first failure through the dispatcher's active guard, appends an actual error attempt and permits peer execution.
- Machine.refuse and Machine.accept are low-level updates; first-failure and actual-success claims must retain the dispatch/AdvanceSound premises when using them. They are not independently authenticated execution APIs. Their current use by advance satisfies this distinction.
- AdvanceSound and Reachable are shared proposition definitions before the runtime marker. AdvanceSound's success/error constructors retain actual executeStep equations and selected-invocation/active-state premises. The inspected advance_sound proof is a case split over those real outcomes, not a premise that assumes the desired full trace. Other proof lanes should extend these definitions rather than redefine them.
- Continuation folds the full arbitrary entry machine. runPrefix starts the machine without admission, while runNary retains exact supplied schedule and initial world on admission failure. Draft continuation append and consumed-count statements preserve arbitrary-entry binders.
- Observation compares the full finite world/store, every local consumed/nextIndex/failure/output/event, and ordered attempts. Events include index, full step, raw before world and full result world/receipt/outputs. Attempts include participant/index/invocation/raw before world and exact error or full successful result. Receipt equality compares the actual receipt structure. Result comparison additionally retains exact schedule and admission reason.
- Checked the historical worldEq implementation: it compares every cell balance and exact capability store. Typed.State has balances plus a proof of nonnegativity; proof irrelevance and function extensionality justify reduction from these fields to exact state/world equality. No historical canonical branch comparator is used to hide raw event fields.
- Observation's `machineEq_iff` and `resultEq_iff` have the required arbitrary-pair exact-equality conclusions, and locals_ext uses complete roster coverage. This review does not assert these draft proofs elaborate. The author owns transient proof/instance fixes; final fresh compilation and axiom inventory remain required.
- CausalRuntime calls the base advance once, supplies the boundary at the pre-machine successful index, obtains `post.attempts[pre.attempts.length]?` and carries the accumulated monitor/machine pair. Monitor state does not control the financial path. This correctly makes skips supply none and avoids prior-attempt replay. Draft erasure/append statements quantify arbitrary initial monitor and machine.

## Literal anchors and runtime closure

Read-only JSON/source comparison found each of M01–M16's exact accepted needles once before its file's `-- BEGIN PROOFS` marker and once in the whole inspected source. M13 and M15 intentionally share one unique lookup site. M10's storedReceipt is used in the local event result, while the global attempt stores original result; its mutation can therefore distinguish those observations. These are source-location checks, not successful compiling mutation executions.

Recursive inspection of local imports from the four roots found 17 local files, with no excluded Nary proof module or Interface.Tests/Fixtures/Accounting/Preservation import. This is only the present four-root closure, not the future Examples/Tests/Audit production closure. There were no executable declarations after the marker in the inspected four files.

Reusable executable binary conversions can live before Observation's marker, with proofs in BinaryCorrespondence. Tests must share the definitions that the proof relates, without importing BinaryCorrespondence into runtime roots. The current files need not receive unrelated financial proof imports to support that comparison.

## Checks and limits

Commands used: bounded cat/sed source reads; rg declaration/location searches; Python standard-library raw SHA256 rereads, exact JSON needle counts and recursive local import discovery. No source mutation, production mutation, financial fixture execution, compiled API acceptance or proof acceptance occurred. The sole written file is this report. The accepted planning input SHA table remains in acceptance-checklist.md.

All four source hashes were first measured before reads and measured again after the source checks. The final reread below records any concurrent drift; when unchanged, the findings apply to those same bytes. Freeze and fresh compilation still precede a substantive verdict.

```json
[
  {
    "path": "lean/DefiKernel/Nary/Schedule.lean",
    "inspected_sha256": "d564b4dfb49fd63ec5bff5ddeb6638aef58307ef7a9c2746d716ccd896d0d9db",
    "reread_sha256": "d564b4dfb49fd63ec5bff5ddeb6638aef58307ef7a9c2746d716ccd896d0d9db",
    "unchanged": true
  },
  {
    "path": "lean/DefiKernel/Nary/Execution.lean",
    "inspected_sha256": "21bdaf8cde9257eb77c6a5fb98750cc2cfe5e9aa43057651946aad616686ef11",
    "reread_sha256": "21bdaf8cde9257eb77c6a5fb98750cc2cfe5e9aa43057651946aad616686ef11",
    "unchanged": true
  },
  {
    "path": "lean/DefiKernel/Nary/Observation.lean",
    "inspected_sha256": "f47053bbe19c4378a8376858cb3d55d07d0ced1af04bc61d0f60379e7bc2d3c9",
    "reread_sha256": "f47053bbe19c4378a8376858cb3d55d07d0ced1af04bc61d0f60379e7bc2d3c9",
    "unchanged": true
  },
  {
    "path": "lean/DefiKernel/Nary/CausalRuntime.lean",
    "inspected_sha256": "0c47ae5ea6a23dbceba051d5df95d22bc9466c743dd79687195617facdaaf0d8",
    "reread_sha256": "0c47ae5ea6a23dbceba051d5df95d22bc9466c743dd79687195617facdaaf0d8",
    "unchanged": true
  }
]
```
