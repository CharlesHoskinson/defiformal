Review this narrowly scoped follow-up for unchanged Lean/Python source candidate 28ba18c446f72084ff11b4d125dccf93bf8f4162. The final Fable review accepted with limitations but requested (1) direct evidence that committed git objects match executed bytes, (2) qualification of component locality versus generic foreign-private isolation, and (3) correction of control-run revision prose. Assess whether supplied actual command/hash results and revised claims close those concrete evidence/prose issues. No new code and no new general isolation theorem is claimed. Do not claim independent execution. Return ACCEPT WITH LIMITATIONS or REQUEST CHANGES, preserving remaining proof/mutation limits. This is a native review through stock Codex, no Foreman.

## final-fable.json
{"duration_api_ms":293695,"stop_reason":"end_turn","session_id":"aceb0351-66d3-4081-85df-37eb545637fa","total_cost_usd":4.487135249999999,"usage":{"input_tokens":2,"cache_creation_input_tokens":162912,"cache_read_input_tokens":3893,"output_tokens":22075,"output_tokens_details":{"thinking_tokens":19704},"server_tool_use":{"web_search_requests":0,"web_fetch_requests":0},"service_tier":"standard","cache_creation":{"ephemeral_1h_input_tokens":162912,"ephemeral_5m_input_tokens":0},"inference_geo":"not_available","iterations":[{"input_tokens":2,"output_tokens":22075,"cache_read_input_tokens":3893,"cache_creation_input_tokens":162912,"cache_creation":{"ephemeral_5m_input_tokens":0,"ephemeral_1h_input_tokens":162912},"type":"message"}],"speed":"standard"},"modelUsage":{"claude-haiku-4-5-20251001":{"inputTokens":124042,"outputTokens":22,"cacheReadInputTokens":0,"cacheCreationInputTokens":0,"webSearchRequests":0,"costUSD":0.124152,"contextWindow":200000,"maxOutputTokens":32000,"thinkingTokens":0,"canonicalModel":"claude-haiku-4-5","provider":"firstParty","costBasis":"list"},"claude-fable-5-1":{"inputTokens":2,"outputTokens":22075,"cacheReadInputTokens":3893,"cacheCreationInputTokens":162912,"webSearchRequests":0,"costUSD":4.362983249999999,"contextWindow":1000000,"maxOutputTokens":64000,"thinkingTokens":19704,"canonicalModel":"claude-fable-5-1","provider":"firstParty","costBasis":"list"}},"permission_denials":[],"terminal_reason":"completed","fast_mode_state":"off","fast_mode_disabled_reason":"sdk_opt_in_required","subagent_stats":{"spawned":0,"requested":{"background":0,"foreground":0,"unset":0},"started_in_background":0,"max_depth":0,"spawned_by_subagents":0,"completed":0,"failed":0,"killed":{"parent":0,"user":0,"system":0},"refused":{"depth_limit":0,"concurrency_limit":0,"budget":0},"by_type":{}},"is_error":false,"num_turns":1,"subtype":"success","api_error_status":null,"result":"**Verdict: ACCEPT WITH LIMITATIONS.** The four previously reported holes are closed in the supplied sources, the 93 comparisons and 12 mutants are real and discriminating for what they target, and the imported proof closure is axiom-clean per the supplied audit summary. Two things keep this from a clean accept: the executed evidence is bound to a dirty `ba3661f` working tree rather than to `28ba18c`, and the interface-isolation proof bridge stops one theorem short of the property the adjudication claims.\n\n## Prior findings: verified against source\n\n- **Exporter/read-only bypass.** `lean/DefiKernel/Composition/Interfaces.lean:111` requires globally unique exported cells, and `:117` rejects any import of a cell the same component exports. Combined with `:115` and `:118` (exports and imports may not be anyone's private cell) and `:119-121` (import rights may not exceed the export), I could not construct a catalog where a component holds two conflicting rights to one cell. Negative controls `interface.unique-export-provider`, `interface.self-import`, `interface.self-readonly-import-writable-export` exercise this. Closed.\n- **Cross-domain snapshot.** `Interfaces.lean:126` requires every output cell to be in the template's domain, and `:127` requires the component can read it. `interface.crossdomain-output` tests the otherwise-readable case. Closed.\n- **Interface write proof bridge.** `checkAccess_ok_iff` → `checkAccess_declaredWrites` → `evaluated_writes` → `prepareInvocation_access` → `StepSound.component_writes` → `StepSound.component_locality` → `TraceSound.component_locality` is a genuine chain. I checked that the extracted receipt is the same evaluation the kernel applied (`extractReceipt_total` via `execute_evaluated`), so receipt writes are the real footprint, and kernel `writesOK` makes cells outside that footprint unchanged. This is proof strength, not bounded testing. See the scope gap below.\n- **Admin lift.** `TraceSound.administration` in `Preservation.lean` derives issue/revoke authorization from `issueCapability_admin` and `revokeCapability_admin` at each event's pre-store. Closed.\n\n## Ranked unresolved items\n\n1. **Evidence is not bound to the reviewed commit.** Every executed artifact records `git_head: ba3661f3…` with a dirty tree (`mutations/summary.json`, `source-manifest.json`, `runner-controls-scoped/summary.json`, proof inventory `head`), and `build-verification.json` records no commit at all. Binding to `28ba18c` rests solely on my comparison of the supplied file SHA-256s against the manifests. Those match for every supplied file, so the evidence is valid for these bytes. What is missing is any artifact showing `28ba18c`'s tree contains exactly these bytes. The delivery record must include a `git ls-tree`/hash comparison for the 18 manifest inputs against `28ba18c`, or rerun the drivers at that commit. Until then the \"Candidate changes after review\" scenario is undischarged.\n\n2. **Isolation proof stops at `canWrite`, not at \"foreign private cell\".** `Preservation.lean` (`TraceSound.component_locality`) proves cells with `component.canWrite = false` are unchanged. No theorem states that, under `validateCatalog = true`, a cell in another component's `privateCells` (or a non-exported cell) has `canWrite = false`. That last step is true (private nodup at `Interfaces.lean:110`, plus `:115` and `:118`) and easy, but only `validateCatalog_export_not_private` exists. Likewise nothing states that a nonempty `run` event list implies `validateCatalog = true` (it follows from `startCursor`, `Sequence.lean:33-35`, but is unstated). The adjudication row \"component access checks lacked a proof bridge → resolved\" should be qualified: the funded-foreign-private scenario is proved to the access predicate and otherwise established by `workflows.isolation.private` as a bounded check.\n\n3. **Mutation coverage does not target the fixes from finding 1.** No mutant disables export uniqueness (`:111`), export/import disjointness (`:117`), output-domain (`:126`), or the read check (`checkAccess`, `:138`). These fixes are evidenced by negative comparisons in the unchanged control only. The runner is honest about what it ran, but the report's \"interface bypass\" coverage is write-only. Also note that a mutant re-evaluating the receipt against the post-state would survive these fixtures: transfer, deposit, and withdraw have no state-dependent deltas, so pre and post evaluations coincide. That case is discriminated by `extractReceipt_total` (proof), not by tests, and the report should say so.\n\n4. **Evidence prose inconsistency.** `mutation-runner-report.md` says the runner controls observed revision `86b77b7…`, while `runner-controls-scoped/summary.json` records `ba3661f…` for the same runner hash. Correct the report; it undermines the source-binding narrative.\n\n5. **`workflow_conditional_invariant` adds nothing beyond `run_contract`.** Its `localGuarantee` premise quantifies over all worlds and steps, and is in fact dischargeable from `component_locality` plus the fact that no component can write `collateral`. It is correctly counted as \"conditional_reference_instantiation\", so this is non-blocking, but it should not be cited as an invariant-discovery result.\n\n## Proof strength versus bounded evidence\n\n- **Proved (generic, axiom-clean per supplied summary):** ordered prefix, first-refusal short-circuit, pre-world adjacency, cumulative accounting from actual evaluated supplies, point-of-use authority, ledger locality and supported-predicate framing, admin authorization, append/continuation (this is `List.foldl_append`; scoped as claimed).\n- **Proved for the concrete workflow:** `workflow_protected_writes` by `decide +kernel` and the resulting collateral frame; both counterexamples for the frame premises.\n- **Bounded runtime only:** full-world equality on 32 cells and store for every workflow comparison, foreign-private/read-only/shared siblings, revocation propagation, output routing. Oracle tables in `Tests.lean` are hand-written and independent of the runner.\n- **Assumed:** environment truth, catalog authorship, capability-store provenance, the full axiom-audit log (only summary lines supplied), the legacy 17/17 runner controls (not supplied), and that `28ba18c` matches the hashed bytes.\n\n## Preserved dissent\n\nThe initial reviews' dissent that interface-only tests do not establish composed refusal is now answered by the `workflows.isolation.*` comparisons and the locality chain, subject to item 2. No confidentiality, solvency, or machine-arithmetic claim is made, and none should be inferred from the read checks, which are executable and syntactic rather than proved.","ttft_ms":259717,"type":"result","duration_ms":290914,"uuid":"33fe3979-0149-494c-a8f1-a9fa0689fdd9","ttft_stream_ms":3223,"time_to_request_ms":47,"first_content_frame_ms":3558,"queued_turn_count":0}


## commit-source-verification.json
{
  "source_candidate": "28ba18c446f72084ff11b4d125dccf93bf8f4162",
  "tree_oid": "4347ef86da578a956e626998121be010389e1f19",
  "compared_files": 27,
  "all_match": true,
  "inputs": [
    {
      "path": "lean/DefiKernel.lean",
      "command": [
        "git",
        "show",
        "28ba18c446f72084ff11b4d125dccf93bf8f4162:lean/DefiKernel.lean"
      ],
      "blob_oid": "7b16df641e2fd7f3f119a1ea558458f798e63255",
      "expected_sha256": "00378bd05ac77e3f3d4603a753ebf5ae5aaf0f2063fc9651fe05d4c31997f9e2",
      "committed_sha256": "00378bd05ac77e3f3d4603a753ebf5ae5aaf0f2063fc9651fe05d4c31997f9e2",
      "worktree_sha256": "00378bd05ac77e3f3d4603a753ebf5ae5aaf0f2063fc9651fe05d4c31997f9e2",
      "matches": true
    },
    {
      "path": "lean/DefiKernel/Composition/Audit.lean",
      "command": [
        "git",
        "show",
        "28ba18c446f72084ff11b4d125dccf93bf8f4162:lean/DefiKernel/Composition/Audit.lean"
      ],
      "blob_oid": "7f350e3b451bda3bb0ed5b1daafb02cd727318fe",
      "expected_sha256": "fdd761877de99d376843b96571bfc3e4753a5f357e1ea802acb882c0917720a2",
      "committed_sha256": "fdd761877de99d376843b96571bfc3e4753a5f357e1ea802acb882c0917720a2",
      "worktree_sha256": "fdd761877de99d376843b96571bfc3e4753a5f357e1ea802acb882c0917720a2",
      "matches": true
    },
    {
      "path": "lean/DefiKernel/Composition/Contracts.lean",
      "command": [
        "git",
        "show",
        "28ba18c446f72084ff11b4d125dccf93bf8f4162:lean/DefiKernel/Composition/Contracts.lean"
      ],
      "blob_oid": "a1f8cf7753180fdea9ae0f8095fae1e0d2ec792e",
      "expected_sha256": "d23885a9bc2ed695ef8569b97c47c9f07449a5a6aa98bc86c8797dce648fc46c",
      "committed_sha256": "d23885a9bc2ed695ef8569b97c47c9f07449a5a6aa98bc86c8797dce648fc46c",
      "worktree_sha256": "d23885a9bc2ed695ef8569b97c47c9f07449a5a6aa98bc86c8797dce648fc46c",
      "matches": true
    },
    {
      "path": "lean/DefiKernel/Composition/Examples.lean",
      "command": [
        "git",
        "show",
        "28ba18c446f72084ff11b4d125dccf93bf8f4162:lean/DefiKernel/Composition/Examples.lean"
      ],
      "blob_oid": "4b4cefb9a7cd81d906d668d69ef63501715abe65",
      "expected_sha256": "55fb655e93cc6fa8ec676da466112bc763f8f7e81e71cb8acedf98ffd7b73064",
      "committed_sha256": "55fb655e93cc6fa8ec676da466112bc763f8f7e81e71cb8acedf98ffd7b73064",
      "worktree_sha256": "55fb655e93cc6fa8ec676da466112bc763f8f7e81e71cb8acedf98ffd7b73064",
      "matches": true
    },
    {
      "path": "lean/DefiKernel/Composition/Execution.lean",
      "command": [
        "git",
        "show",
        "28ba18c446f72084ff11b4d125dccf93bf8f4162:lean/DefiKernel/Composition/Execution.lean"
      ],
      "blob_oid": "f94f22503551dc7cbc965459626a33435ac512cc",
      "expected_sha256": "34ac2f2185434d2fc8931b10f3688d909cc984e4e24e16e26c2d115b6fe13602",
      "committed_sha256": "34ac2f2185434d2fc8931b10f3688d909cc984e4e24e16e26c2d115b6fe13602",
      "worktree_sha256": "34ac2f2185434d2fc8931b10f3688d909cc984e4e24e16e26c2d115b6fe13602",
      "matches": true
    },
    {
      "path": "lean/DefiKernel/Composition/ExecutionTests.lean",
      "command": [
        "git",
        "show",
        "28ba18c446f72084ff11b4d125dccf93bf8f4162:lean/DefiKernel/Composition/ExecutionTests.lean"
      ],
      "blob_oid": "7b0110bfc51e21d232cf5fe0f2e7512a7cd2447e",
      "expected_sha256": "68cd7423cafbb63dfcca0e319381eeac9cf31ee4e9c3fd8459f2ab5f4b98a0c5",
      "committed_sha256": "68cd7423cafbb63dfcca0e319381eeac9cf31ee4e9c3fd8459f2ab5f4b98a0c5",
      "worktree_sha256": "68cd7423cafbb63dfcca0e319381eeac9cf31ee4e9c3fd8459f2ab5f4b98a0c5",
      "matches": true
    },
    {
      "path": "lean/DefiKernel/Composition/InterfaceTests.lean",
      "command": [
        "git",
        "show",
        "28ba18c446f72084ff11b4d125dccf93bf8f4162:lean/DefiKernel/Composition/InterfaceTests.lean"
      ],
      "blob_oid": "1e0965bb3e7c1f72274fba529cc93bec5cb770e5",
      "expected_sha256": "710777f2112979bbb4cd70624939901a7f1f25756d5cc08027722ca942ae51b3",
      "committed_sha256": "710777f2112979bbb4cd70624939901a7f1f25756d5cc08027722ca942ae51b3",
      "worktree_sha256": "710777f2112979bbb4cd70624939901a7f1f25756d5cc08027722ca942ae51b3",
      "matches": true
    },
    {
      "path": "lean/DefiKernel/Composition/Interfaces.lean",
      "command": [
        "git",
        "show",
        "28ba18c446f72084ff11b4d125dccf93bf8f4162:lean/DefiKernel/Composition/Interfaces.lean"
      ],
      "blob_oid": "a45abc9035cd5882f58814c089ce151f0f2bbc51",
      "expected_sha256": "4f2a32854b298ca5399eb0aa38bb16e892312517ae4f3a0e49e4bfead369f5fe",
      "committed_sha256": "4f2a32854b298ca5399eb0aa38bb16e892312517ae4f3a0e49e4bfead369f5fe",
      "worktree_sha256": "4f2a32854b298ca5399eb0aa38bb16e892312517ae4f3a0e49e4bfead369f5fe",
      "matches": true
    },
    {
      "path": "lean/DefiKernel/Composition/Preservation.lean",
      "command": [
        "git",
        "show",
        "28ba18c446f72084ff11b4d125dccf93bf8f4162:lean/DefiKernel/Composition/Preservation.lean"
      ],
      "blob_oid": "21eb3370867603b6d58c247f78840984dca0dbc6",
      "expected_sha256": "7b881b25fc71f93751ea8f3f64f3bc2d0ffcdd94b4abb7091ba19dd6b21f3709",
      "committed_sha256": "7b881b25fc71f93751ea8f3f64f3bc2d0ffcdd94b4abb7091ba19dd6b21f3709",
      "worktree_sha256": "7b881b25fc71f93751ea8f3f64f3bc2d0ffcdd94b4abb7091ba19dd6b21f3709",
      "matches": true
    },
    {
      "path": "lean/DefiKernel/Composition/Sequence.lean",
      "command": [
        "git",
        "show",
        "28ba18c446f72084ff11b4d125dccf93bf8f4162:lean/DefiKernel/Composition/Sequence.lean"
      ],
      "blob_oid": "ffdfd5b29d8123c2f49cc2262fc199100794074f",
      "expected_sha256": "32bcdbbce182bf9d494dab76a8a114f9e238f92564ef86e7cab2cd123bc0b729",
      "committed_sha256": "32bcdbbce182bf9d494dab76a8a114f9e238f92564ef86e7cab2cd123bc0b729",
      "worktree_sha256": "32bcdbbce182bf9d494dab76a8a114f9e238f92564ef86e7cab2cd123bc0b729",
      "matches": true
    },
    {
      "path": "lean/DefiKernel/Composition/Tests.lean",
      "command": [
        "git",
        "show",
        "28ba18c446f72084ff11b4d125dccf93bf8f4162:lean/DefiKernel/Composition/Tests.lean"
      ],
      "blob_oid": "4eb52aa5c35b8c721c4794dd0a1fef468dd8d337",
      "expected_sha256": "4596621611ffd8aa92d782f4d8688c601bec438414efba45b5335684d2670980",
      "committed_sha256": "4596621611ffd8aa92d782f4d8688c601bec438414efba45b5335684d2670980",
      "worktree_sha256": "4596621611ffd8aa92d782f4d8688c601bec438414efba45b5335684d2670980",
      "matches": true
    },
    {
      "path": "lean/DefiKernel/Composition/Verify.lean",
      "command": [
        "git",
        "show",
        "28ba18c446f72084ff11b4d125dccf93bf8f4162:lean/DefiKernel/Composition/Verify.lean"
      ],
      "blob_oid": "ec4088ec49455959ad1e2604467f226e69e25998",
      "expected_sha256": "0510c92489398990f07a614f5d8d9228db05220fcf66297afe8a20cb078a4fdb",
      "committed_sha256": "0510c92489398990f07a614f5d8d9228db05220fcf66297afe8a20cb078a4fdb",
      "worktree_sha256": "0510c92489398990f07a614f5d8d9228db05220fcf66297afe8a20cb078a4fdb",
      "matches": true
    },
    {
      "path": "lean/DefiKernel/Typed/Acceptance.lean",
      "command": [
        "git",
        "show",
        "28ba18c446f72084ff11b4d125dccf93bf8f4162:lean/DefiKernel/Typed/Acceptance.lean"
      ],
      "blob_oid": "6215aed9b4efb5354af401504e4bf9d7ba39cd2a",
      "expected_sha256": "4b07f553e6bd0b3ac7cdd3f649ead412af49fb6b37c86a521eafff28262c97d1",
      "committed_sha256": "4b07f553e6bd0b3ac7cdd3f649ead412af49fb6b37c86a521eafff28262c97d1",
      "worktree_sha256": "4b07f553e6bd0b3ac7cdd3f649ead412af49fb6b37c86a521eafff28262c97d1",
      "matches": true
    },
    {
      "path": "lean/DefiKernel/Typed/Audit.lean",
      "command": [
        "git",
        "show",
        "28ba18c446f72084ff11b4d125dccf93bf8f4162:lean/DefiKernel/Typed/Audit.lean"
      ],
      "blob_oid": "c9e2a259936ed139599b35d4ed1467a54f67e460",
      "expected_sha256": "20ffa1753cf50ef5b60dec0d8bb6950c2b9f623011df23c7c0d8a542aeaeb3c4",
      "committed_sha256": "20ffa1753cf50ef5b60dec0d8bb6950c2b9f623011df23c7c0d8a542aeaeb3c4",
      "worktree_sha256": "20ffa1753cf50ef5b60dec0d8bb6950c2b9f623011df23c7c0d8a542aeaeb3c4",
      "matches": true
    },
    {
      "path": "lean/DefiKernel/Typed/Authority.lean",
      "command": [
        "git",
        "show",
        "28ba18c446f72084ff11b4d125dccf93bf8f4162:lean/DefiKernel/Typed/Authority.lean"
      ],
      "blob_oid": "f7fb9de0cb97cc9e003bf487d742ec902250efc9",
      "expected_sha256": "dfd2c140f511144e9928ed4f5ed1db9ee2b56cada1342500d2e60c33ef9a0cdb",
      "committed_sha256": "dfd2c140f511144e9928ed4f5ed1db9ee2b56cada1342500d2e60c33ef9a0cdb",
      "worktree_sha256": "dfd2c140f511144e9928ed4f5ed1db9ee2b56cada1342500d2e60c33ef9a0cdb",
      "matches": true
    },
    {
      "path": "lean/DefiKernel/Typed/AuthorityTests.lean",
      "command": [
        "git",
        "show",
        "28ba18c446f72084ff11b4d125dccf93bf8f4162:lean/DefiKernel/Typed/AuthorityTests.lean"
      ],
      "blob_oid": "0565fc81a0625e064ee560613408356bac7c4cda",
      "expected_sha256": "02c7028ade18e53815d436f57fc3c80cd79c06dc585a3e985b1be8dab544ae77",
      "committed_sha256": "02c7028ade18e53815d436f57fc3c80cd79c06dc585a3e985b1be8dab544ae77",
      "worktree_sha256": "02c7028ade18e53815d436f57fc3c80cd79c06dc585a3e985b1be8dab544ae77",
      "matches": true
    },
    {
      "path": "lean/DefiKernel/Typed/Examples.lean",
      "command": [
        "git",
        "show",
        "28ba18c446f72084ff11b4d125dccf93bf8f4162:lean/DefiKernel/Typed/Examples.lean"
      ],
      "blob_oid": "5094c617948dc2955e6662009fe621b47edc6417",
      "expected_sha256": "640df42460b97cd4ac2aba50dc354aa7d2671a055f39c2ec0eb6c8e0f1197f41",
      "committed_sha256": "640df42460b97cd4ac2aba50dc354aa7d2671a055f39c2ec0eb6c8e0f1197f41",
      "worktree_sha256": "640df42460b97cd4ac2aba50dc354aa7d2671a055f39c2ec0eb6c8e0f1197f41",
      "matches": true
    },
    {
      "path": "lean/DefiKernel/Typed/Expr.lean",
      "command": [
        "git",
        "show",
        "28ba18c446f72084ff11b4d125dccf93bf8f4162:lean/DefiKernel/Typed/Expr.lean"
      ],
      "blob_oid": "4142a771422ee0d74aad24f5c9f7101db0d27195",
      "expected_sha256": "1c4e0c2e38dd6beaed332bfccbda6d256b3f57d27cb7a0db370fb1a9019fbfed",
      "committed_sha256": "1c4e0c2e38dd6beaed332bfccbda6d256b3f57d27cb7a0db370fb1a9019fbfed",
      "worktree_sha256": "1c4e0c2e38dd6beaed332bfccbda6d256b3f57d27cb7a0db370fb1a9019fbfed",
      "matches": true
    },
    {
      "path": "lean/DefiKernel/Typed/ExprTests.lean",
      "command": [
        "git",
        "show",
        "28ba18c446f72084ff11b4d125dccf93bf8f4162:lean/DefiKernel/Typed/ExprTests.lean"
      ],
      "blob_oid": "f101da3b78d9cdf473377b406cac58bc836a4588",
      "expected_sha256": "8fd89353f21e5f3f94f1ed56ae6d1e28d375952b5720ed9e29c177e4a4e88e29",
      "committed_sha256": "8fd89353f21e5f3f94f1ed56ae6d1e28d375952b5720ed9e29c177e4a4e88e29",
      "worktree_sha256": "8fd89353f21e5f3f94f1ed56ae6d1e28d375952b5720ed9e29c177e4a4e88e29",
      "matches": true
    },
    {
      "path": "lean/DefiKernel/Typed/Transition.lean",
      "command": [
        "git",
        "show",
        "28ba18c446f72084ff11b4d125dccf93bf8f4162:lean/DefiKernel/Typed/Transition.lean"
      ],
      "blob_oid": "344109d8e783c2b80f1385fa39f0a4b923b0d07c",
      "expected_sha256": "73f264636236219e45720a531209f8c7ed8f5ee3f615fa34d58bc5596c4499d2",
      "committed_sha256": "73f264636236219e45720a531209f8c7ed8f5ee3f615fa34d58bc5596c4499d2",
      "worktree_sha256": "73f264636236219e45720a531209f8c7ed8f5ee3f615fa34d58bc5596c4499d2",
      "matches": true
    },
    {
      "path": "lean/DefiKernel/Typed/TransitionTests.lean",
      "command": [
        "git",
        "show",
        "28ba18c446f72084ff11b4d125dccf93bf8f4162:lean/DefiKernel/Typed/TransitionTests.lean"
      ],
      "blob_oid": "09ecdc3ee7b659eb08be15701a76595ec3c8b18d",
      "expected_sha256": "e9d3af4f0d81c9ab76ab20e0440228c30c6dcf54f5e80ccd32117f4c961561bc",
      "committed_sha256": "e9d3af4f0d81c9ab76ab20e0440228c30c6dcf54f5e80ccd32117f4c961561bc",
      "worktree_sha256": "e9d3af4f0d81c9ab76ab20e0440228c30c6dcf54f5e80ccd32117f4c961561bc",
      "matches": true
    },
    {
      "path": "lean/DefiKernel/Typed/Types.lean",
      "command": [
        "git",
        "show",
        "28ba18c446f72084ff11b4d125dccf93bf8f4162:lean/DefiKernel/Typed/Types.lean"
      ],
      "blob_oid": "fd5c617ee1c7b7ff56092218e55b0c3ce2ac1da8",
      "expected_sha256": "5f2b7d30028c7445f5523b9a06cb1fb21f36fc28e38d50844d4270177f601f82",
      "committed_sha256": "5f2b7d30028c7445f5523b9a06cb1fb21f36fc28e38d50844d4270177f601f82",
      "worktree_sha256": "5f2b7d30028c7445f5523b9a06cb1fb21f36fc28e38d50844d4270177f601f82",
      "matches": true
    },
    {
      "path": "lean/lake-manifest.json",
      "command": [
        "git",
        "show",
        "28ba18c446f72084ff11b4d125dccf93bf8f4162:lean/lake-manifest.json"
      ],
      "blob_oid": "51fea05cf51f6ff04ca93c5a8d8d40c12d4334b1",
      "expected_sha256": "8a6ceb0b073bcb3e437c3258aedf250b38da4dec0f696db6b2717bd987c43002",
      "committed_sha256": "8a6ceb0b073bcb3e437c3258aedf250b38da4dec0f696db6b2717bd987c43002",
      "worktree_sha256": "8a6ceb0b073bcb3e437c3258aedf250b38da4dec0f696db6b2717bd987c43002",
      "matches": true
    },
    {
      "path": "lean/lakefile.toml",
      "command": [
        "git",
        "show",
        "28ba18c446f72084ff11b4d125dccf93bf8f4162:lean/lakefile.toml"
      ],
      "blob_oid": "3bf93ee79697e086fda3a57b2fb7df069c25eb3c",
      "expected_sha256": "4a1684945bf3632ee11a93b4529ce45335b97a878ca9a4a9a295981e7e97aa86",
      "committed_sha256": "4a1684945bf3632ee11a93b4529ce45335b97a878ca9a4a9a295981e7e97aa86",
      "worktree_sha256": "4a1684945bf3632ee11a93b4529ce45335b97a878ca9a4a9a295981e7e97aa86",
      "matches": true
    },
    {
      "path": "lean/lean-toolchain",
      "command": [
        "git",
        "show",
        "28ba18c446f72084ff11b4d125dccf93bf8f4162:lean/lean-toolchain"
      ],
      "blob_oid": "c084c7fbe586b0276863b66f16d2955a43bc3fc6",
      "expected_sha256": "0d3c76ccd8772d8bcbe207241421a760312b71a6aa82f84194391fdf5cb026d6",
      "committed_sha256": "0d3c76ccd8772d8bcbe207241421a760312b71a6aa82f84194391fdf5cb026d6",
      "worktree_sha256": "0d3c76ccd8772d8bcbe207241421a760312b71a6aa82f84194391fdf5cb026d6",
      "matches": true
    },
    {
      "path": "scripts/check_composition_mutations.py",
      "command": [
        "git",
        "show",
        "28ba18c446f72084ff11b4d125dccf93bf8f4162:scripts/check_composition_mutations.py"
      ],
      "blob_oid": "b86644fbdb49fdbcb8ade27e1b97c7715c22aa3b",
      "expected_sha256": "0c03c093df36cdf64e907ead230a73a25190bc50eccf6670d7259c6fbd64a031",
      "committed_sha256": "0c03c093df36cdf64e907ead230a73a25190bc50eccf6670d7259c6fbd64a031",
      "worktree_sha256": "0c03c093df36cdf64e907ead230a73a25190bc50eccf6670d7259c6fbd64a031",
      "matches": true
    },
    {
      "path": "scripts/test_composition_mutation_runner.py",
      "command": [
        "git",
        "show",
        "28ba18c446f72084ff11b4d125dccf93bf8f4162:scripts/test_composition_mutation_runner.py"
      ],
      "blob_oid": "19c780e4fe776f4d6f93581405230b4fb48d7fdf",
      "expected_sha256": "c1a873d376eac77bc0f2c8e4cf2b512c34333fa3c9a674780e70ab996c49e706",
      "committed_sha256": "c1a873d376eac77bc0f2c8e4cf2b512c34333fa3c9a674780e70ab996c49e706",
      "worktree_sha256": "c1a873d376eac77bc0f2c8e4cf2b512c34333fa3c9a674780e70ab996c49e706",
      "matches": true
    }
  ],
  "scope": "Actual git object bytes were read and compared to executed build and mutation manifests and current worktree. Dirty execution-start HEAD is not treated as source identity."
}


## ADJUDICATION.md
# Sprint 5 native review adjudication

Implementation uses GPT-6 through the stock Codex harness. Reviews use the native
Grok and Fable CLIs, with no Foreman. Review is advisory source analysis, not an
independent Lean build or mathematical proof.

Initial source candidate: `ba3661f3e875ef6c48e71300fec339d333dab697`.
Revised source candidate: `28ba18c` (full identity is bound in the final review bundle).

## Initial reviews and remediation

Both providers reviewed interfaces/contracts and execution/preservation separately.
All four initial reviews returned ACCEPT WITH LIMITATIONS, with explicit dissent
that integration must close shared-access and isolation-evidence gaps. That dissent
is retained in the raw responses; the initial reviews alone do not close acceptance.

| Finding | Resolution in revised candidate |
| --- | --- |
| Duplicate or self-declared exports could bypass read-only imports | Require globally unique exported cells and disjoint export/import cells within each component; add conflicting-provider and self-import negative controls |
| Output snapshots could read another domain | Require selected outputs to match the registered operation domain; test the otherwise-visible cross-domain negative |
| Component access checks lacked a proof bridge | Prove the bridge from accepted interface checks to receipt writes and `canWrite`-conditional component locality; foreign-private identification remains demonstrated by bounded configured workflows |
| Administrative authority was implicit in step relations | Add explicit `TraceSound.administration`; invocation receipt rights remain separate |
| Interface-only/adapter-only tests did not establish composed refusal behavior | Add full-world, store, receipt, output, index, and refusal comparisons for private/shared/read-only interference and output routing; integrate all 93 comparisons |
| Initial reports did not evidence the whole new import closure | Save the revised full build, eight fresh verification commands, imported axiom audit, and exact source hashes in `build-verification.json` |
| Argument resolution wording overstated the current syntax | Document principal/party-list resolution, static output validation, and the catalog-authorship assumption |
| A runtime comparison was described as a proof | Correct the interface report to call it a check; distinguish theorem inventory from executed comparisons |

No false confidentiality claim is added: interface checks cover declared and
syntactically collected reads, and successful permitted writes. Environment truth,
configuration authenticity, and capability-store provenance remain assumptions.
The unchanged typed expression implementation and authority APIs are supplied to
the final review so their collector and scope behavior can be inspected directly.

The generic initialization/contract theorem retains explicit local and boundary
premises. The concrete collateral frame theorem discharges its protected-write
premise by kernel reduction. The separate boundary-contract fixture uses time as
an explicit assumption and monotone collateral as its guarantee; it does not use
time as a financial price. Nonnegativity is supplied by proof-carrying states and
is not counted as an additional invariant-discovery result.

The mutation projection boundary in `Sequence.lean` was moved above proof-only
relations so the executable projection does not depend on omitted step proofs.
This changes projection organization, not accepted Lean execution semantics.

## Final review

Fable's combined follow-up returns ACCEPT WITH LIMITATIONS. It confirms closure
of conflicting export permissions, cross-domain output snapshots, the receipt
write proof chain, and explicit administrative authority. It asks for a direct
commit-object comparison and a narrower description of private isolation.
`commit-source-verification.json` records actual `git show`/object-ID checks for
27 inputs against source candidate `28ba18c446f72084ff11b4d125dccf93bf8f4162` and
the executed manifests; all match. This bridges earlier dirty execution-start
HEADs without relabeling their historical records. The runner-control report now
distinguishes its initial revision from its final 36-case revision.

The component-locality theorem proves unchanged cells whose selected component's
`canWrite` predicate is false. It does not additionally prove a generic theorem
identifying every foreign private cell as denied by every valid catalog. That
identification is checked in the funded composed private/shared/read-only fixtures.
No general private-state noninterference result is claimed. The frame theorem's
explicit support and write-disjointness premises retain their full stated proof.

The 12 mutations include interface write-check bypass, not read-check bypass or
separate removal of each new structural catalog check. Those structural changes
have negative runtime siblings. The fixtures do not discriminate re-evaluating a
receipt against a different state when effects are state-independent; the generic
extraction/correspondence proofs supply that guarantee for accepted source.
These mutation limits are recorded rather than called complete branch coverage.

Grok's final combined review remains pending. Delivery is recorded separately.


## mutation-runner-report.md
# Sprint 5 composition mutation runner

Implemented `scripts/check_composition_mutations.py` and its real CLI control
harness. This report records bounded runner and actual workflow mutation evidence.
Composition theorem verification and independent native review are separate
integration obligations.

The final composition harness passed **36/36 actual CLI controls**. The accepted
case compiled fresh unchanged source and executed two true comparisons; its real
`n ≤ 4` → `n ≤ 5` mutant compiled and executed `runner_sensitivity: false` while
`runner_positive` remained true. A surviving `n ≤ 3` mutant returned exit 1.
Compiler-only and mixed compiler/runtime failures returned exit 3, never a
semantic detection. Empty inventories/observations, duplicates, missing checks,
partial execution, missing/nonunique needles, unchanged replacements, malformed
JSON/observations, reserved artifact names, and output misuse were rejected.

Dotted and hyphenated dotted comparison names have executed accepted siblings;
leading/trailing dots and empty dot segments are rejected in spec/output controls.
The earlier 30-control replay remains under `runner-controls/` as historical evidence.

The unchanged Sprint 4 runner harness passed **17/17 CLI controls**; both legacy
runner source files have zero Git diff. Python syntax checks passed for both new
files. These results do not establish correctness of arbitrary user-supplied
Lean checks or their expected values; source review supplies that trust boundary.

Commands (each exited 0):

```sh
python3 scripts/test_composition_mutation_runner.py --repo . --out /tmp/defiformal-sprint5-runner-controls-scoped-final
python3 scripts/test_typed_kernel_mutation_runner.py --repo . --out /tmp/defiformal-sprint5-legacy-runner-controls
```

[Composition summary](runner-controls-scoped/summary.json) and
[case records](runner-controls-scoped/cases.json) contain exact commands, tool/source
hashes, classification expectations, complete CLI output, observed Lean
comparisons, and log hashes. The `runner-controls-scoped/runs/` directories preserve
actual source projections, input snapshots, manifests, and subprocess logs.
[Legacy summary](legacy-runner-controls/summary.json) and the adjacent artifacts
preserve the unchanged runner replay. Absolute paths in records identify the
original scratch executions; evidence copies retain their original bytes.
The synthetic Git fixture repositories and dependency symlinks are not copied.

## Integration contract

Run from the repository root, selecting a new output path outside the repository:

```sh
python3 scripts/check_composition_mutations.py --repo . --spec review/semantic-kernel/sprint5/mutation-spec.json --out /tmp/composition-mutations-NEW
```

Schema version 1 has exactly these top-level fields:

```json
{
  "schema_version": 1,
  "modules": ["DefiKernel.Composition.RunnerInput", "DefiKernel.Composition.RunnerAudit"],
  "positive_checks": ["runner_positive"],
  "mutations": [{
    "name": "probe",
    "module": "DefiKernel.Composition.RunnerInput",
    "needle": "n ≤ 4",
    "replacement": "n ≤ 5",
    "required_false": ["runner_sensitivity"]
  }]
}
```

All inventories must be nonempty and unique. Each mutation applies exactly once
in its named executable projection. Names for comparisons use lowercase letters,
digits, underscores and hyphens in nonempty dot-separated segments, each starting
with a letter; variant names use lowercase
letters, digits and hyphens and cannot overwrite reserved tool/control logs.
Every required comparison must exist in the unchanged run, and every mutant must
execute the identical comparison set. Positive controls must remain true.
The runtime driver prints `name: true` or `name: false`, then throws exactly
`Composition runtime comparisons failed: N` when N comparisons fail. A detected
mutant must have that single diagnostic, a nonzero Lean exit, and every named
required false comparison. Additional compilation errors block acceptance.

Only Composition modules can be explicit mutation targets. All local DefiKernel
imports are recursively read, hashed, topologically ordered and concatenated
from current source; no project olean is imported. Imported Composition modules
must be listed explicitly. External Mathlib dependencies remain installed package
imports, identified by the recorded Lake manifest/toolchain. Composition proof
suffixes beginning at the unique `-- BEGIN PROOFS` marker are replaced by the
matching namespace closure. Unchanged dependency proof tails are retained.
A real Typed fixture theorem located after its proof marker is referenced from
Composition to exercise that distinction. No accepted source file is rewritten.

The runner records input hashes before/after replay, executable Lean identity,
Git revision and dirty-input status, spec/script hashes, and all subprocess
commands/log hashes, including blocked runs that reached subprocess execution.
Exit 0 means all specified nonempty mutations discriminate; exit 1 means an
executed semantic expectation failed; exit 3 means malformed or unavailable
evidence. Projection supports the documented simple one-module-per-import
syntax and matching namespace closure, and deliberately blocks unsupported input.

Runner-control source/tool binding:

- Runner SHA-256: `0c03c093df36cdf64e907ead230a73a25190bc50eccf6670d7259c6fbd64a031`.
- Harness SHA-256: `c1a873d376eac77bc0f2c8e4cf2b512c34333fa3c9a674780e70ab996c49e706`.
- Lean: `Lean (version 4.33.0-rc2, x86_64-unknown-linux-gnu, commit d8b18978322de05a8f3dba51ef03cf5461676c17, Release)`.
- Initial controls observed `86b77b7f658f57530cc3833c66812d26d9925018`; the final
  36-case scoped-name controls observed `ba3661f3e875ef6c48e71300fec339d333dab697`
  with new runner files uncommitted. Current committed bytes are verified against
  `28ba18c` in `commit-source-verification.json`.

## Source-change rejection during integration

The first real workflow replay compiled an unchanged control (85/85 true) and
all twelve altered implementations. Each mutant produced its designated false
comparisons. The runner nevertheless returned **exit 3** because accepted source
bytes changed during replay. This run is not accepted final mutation evidence.
The [rejection record](mutation-probe-rejected.json) preserves the command,
classification, captured/current input hashes and all measured outcomes; the
[probe artifacts](mutation-probe-artifacts/source-manifest.json) retain the exact
captured source closure, projections and compiler/runtime logs. This exercises
the source-unchanged guard on an actual concurrent source change.

## Accepted actual workflow mutations

The final source-bound CLI replay exited **0**, with **93/93**
unchanged comparisons true and **12/12** actual source mutants detected. Every
mutant compiled, executed the identical comparison inventory, failed all its
designated comparisons, and preserved all six positive controls. Inputs matched
before/after hashes and were rechecked against current source before evidence copy.

[Final summary](mutations/summary.json), [exact CLI command](mutations/command.json),
[CLI output](mutations/cli-output.log), [source manifest](mutations/source-manifest.json),
and [complete results](mutations/results.json) bind the source, spec, tool and
observations. [Mutation specification](mutation-spec.json) records every exact
needle/replacement and designated false comparison. Copied scratch paths retain
the original bytes; all actual projections, inputs and per-variant logs are adjacent.

Protected positives include three catalog checks plus an actual permitted
transfer with receipts/snapshots, a permitted shared write, and a funded kernel
execution. Each remained true in every mutant.

| Mutation | Designated executed failures |
| --- | --- |
| reverse-order | `workflows.transfer.deposit.withdraw`, `workflows.order.transfer.first` |
| drop-first-step | `workflows.consecutive` |
| continue-after-refusal | `workflows.first.refusal`, `workflows.resume.terminal` |
| reset-ledger | `workflows.consecutive` |
| reset-capability-store | `workflows.admin.live.repeat` |
| omit-revocation-propagation | `execution.revoke.ledger.receipt`, `workflows.admin.revocation` |
| interface-write-bypass | `interface.foreign-write`, `interface.readonly-write`, `workflows.isolation.private`, `workflows.isolation.readonly` |
| wrong-output-index | `workflows.output.index` |
| wrong-output-unit | `interface.wrong-output-unit`, `workflows.output.unit` |
| drop-supply-receipt | `workflows.order.deposit.first`, `workflows.transfer.deposit.withdraw` |
| reset-continuation-index | `workflows.resume.output`, `workflows.resume.time` |
| wrong-snapshot-index | `interface.snapshot-exact`, `workflows.output.index` |

The supplied mutations alter executable implementation behavior, including
receipt payload supplies; they do not edit expected workflow values or runtime
check definitions. The dropped supply mutation clears actual receipt `supplies`
after genuine kernel execution, and is detected by independent expected receipts.
These reference workflows do not establish deployed-contract fidelity, machine
arithmetic refinement, or general semantic correctness.

