# Independent GPT-6 review: FundedEnabledness r2

Verdict: **ACCEPT for the four actual F10 current-world enabledness helpers and their stated receipt/output/store/frame conclusions.** The reviewed source is unchanged from the provisional source review. Integration into the live-selected FundedK theorem is a separate native task and is not accepted here. This is not full Sprint11 acceptance.

Exact source: `lean/DefiKernel/Nary/FundedEnabledness.lean`, 34,369 bytes, SHA-256 `98eccaec1a755d5758d1b88fcb5e0f18e6a35d327ee990beb1094b22bc90f0b7`. Worktree, private proof-cache copy, final archive/snapshot, and the prior reviewed stage snapshot are byte-equal.

Reviewer: independent GPT-6 / gpt-6-astra, stock Codex task `/root/causal_check`. Direct parsing of the final native stream finds its last end event at line1659, session `01a07ed4-abae-7fe3-ab13-19f9ce8da8b2`, with modelUsage object key `grok-4.6-build`; root records native exit0. The earlier r1 outer timeout exit124 and absence of any end event remain preserved and are not relabeled a completed native run. No usage values/signatures are reproduced.

## Mathematical acceptance

Each top-level helper quantifies an arbitrary current world `pre : W`, whose State type already certifies all balances nonnegative. The hypotheses are the fixed F10 capability store and the following current amount condition. Call configuration, boundary, operation, index, and supplied history remain the actual F10 definitions:

| Theorem | Additional premise | Actual call | Conclusion beyond actual success |
| --- | --- | --- | --- |
| f10_producer_enabled | budget=6 | p0/index0/inv200/history[] | receipt rec200, singleton qualified budget output, every balance unchanged |
| f10_consumer_enabled | vault≥6 | p0/index1/inv201/history[budgetOut0] | receipt rec201, no outputs, vault−6, recipient+6, all other cells framed |
| f10_deposit1_enabled | donor1≥1 | p1/index0/inv202/history[] | receipt rec202, no outputs, donor1−1, vault+1, all other cells framed |
| f10_deposit2_enabled | donor2≥2 | p2/index0/inv203/history[] | receipt rec203, no outputs, donor2−2, vault+2, all other cells framed |

Every result also retains exactly f10Store. Every theorem concludes `∃ result, executeStep ... = .ok result` together with its full listed observations. The current world is not restricted to the literal initial world or enumerated fixture intermediates. No K, Reachable, desired post-state, successful result argument, prior whole-run result, or future-success hypothesis occurs in these four top-level interfaces. The consumer's success premise vault≥6 is intentionally weaker than the K-derived vault≥10 needed to preserve reserve4; the helper does not claim reserve4 under its weaker premise.

The source constructs each post world using `applyWorld` with the actual evaluated effects. Nonnegativity of the resulting ledger is proved from the current funding inequality plus State.nonneg for every cell. Internal execute helpers accept a proof needed to form this post-world value, but the top-level helpers derive that proof; callers do not supply an unproved desired postcondition.

The constructive route uses the accepted `execute_ok_iff` equivalence. It discharges actual registry selection, actor/domain/arity, typed argument checking, invoke authority, template evaluation, and complete Evaluated.Valid obligations. Those include actual financial guard, required/declared reads, environment/domain checks, debit and supply authority, every-cell nonnegativity, accounting, and writes. Concrete kernel computations establish fixed catalog/store metadata; symbolic current-state arithmetic establishes dynamic guards and nonnegativity. The implementation does not replace the real configuration, remove a financial guard, or infer progress from StepSound.

`executeStep_invoke_ok` combines catalog validation, real preparation, proved Typed.execute success, actual receipt extraction, and snapshots. This internal transport helper is configuration-parameterized over the fixture type family and has intermediate execution premises; those premises are discharged by the concrete constructions and do not leak into the four public enabledness statements. Actual prepared consumer input resolves the qualified own-output key/index to six. Full receipt metadata, output snapshots and store are retained; the result is not merely a statement about two balances.

Producer budget=6 is needed for the exact exported six and is maintained by FundedK. Consumer history is explicitly the supplied singleton producer output. Donor outputs are empty because their declared interfaces export nothing. All unaffected ledger cells, including budget/sentinel where relevant, are covered by the universal frame conclusions. Fixed F10 configuration/amounts/types remain essential scope limits; these are not generic all-protocol or arbitrary-stream-length claims.

## Remaining bridge boundary

The current native FundedCausal bridge must apply these helpers to the actual live selected machine. Producer budget/store, consumer own history/funding, and donor funding are supplied by the previously reviewed K/assumption facts. Donor helpers are specialized to empty history at index0, while the older K explicitly tracked only p0 history. The bridge must establish that donor history from actual reachability (or separately prove no-input invocation history independence), rather than introduce a new unproved history or success assumption. That requirement is an integration obligation, not a flaw in these exact helper statements. This review does not claim the bridge, schedule induction, or full scenario matrix has been closed by the helper module alone.

## Independent checks and provenance

Under root's exclusive proof-cache release, the reviewer ran one read-only `lake env lean --stdin` probe in `/home/charl/.cache/defiformal-sprint11-builds/proof`; it exited0. The probe independently enumerated actual imported theorem constants owned by FundedEnabledness, retained their complete statements and outer-expanded types, collected transitive axioms, and ran literal #print axioms for the four helpers plus the transport lemma. It found221 theorem constants including all99 explicit source theorems, with no missing explicit declaration or ellipsis. The only axiom names are `propext`, `Classical.choice`, `Quot.sound`. Generated constants are not counted as additional independent claims. Full untruncated output and JSON statements are retained under `funded-enabledness-r2-logs/`.

Before/after bindings cover24 local imported source files, their matching worktree/private source copies, retained compiled artifacts, toolchain/configuration pins, and observed Lean/Lake executable hashes. No checked bytes drifted. This was compiled-module introspection, not a reviewer rebuild of the dependency closure. The author separately retained fresh r2 target build and source elaboration exit0, plus99 explicit axiom prints. External Lean/Mathlib packages retain pinned-environment trust. The proof cache has been released back to root; the causal cache was not accessed.

All53 files in final stage archive `e98d82bf6c5f3a2a19af8222f1ae3000e946041dda3eaa86b895d77fc059ad8c` match their live counterparts. All51 entries in the self-excluding author final-artifact manifest match their hashes and sizes. Earlier failed author probes and the r1 timeout evidence remain preserved; no reviewer Lean probe failed. The author's statements.json contains source signature excerpts associated with its elaboration evidence; the independent actual environment statements are separately retained here.

No feature source, author evidence, or build cache was edited by this review. The prior provisional SOURCE-REVIEW and stage snapshots remain intact. The companion input manifest binds final/provisional source identity, author/native evidence, actual statements/axioms, command/exit, before/after bindings, and this report. Official whole-kernel inventory, integrated build, mutation acceptance, native bridge review, and delivery remain separate gates.
