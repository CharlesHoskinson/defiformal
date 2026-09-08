# Independent GPT-6 certificate planning review, official r1

Verdict: **NEEDS REVISION — planning gate remains open.** This verdict applies to the exact archive `a845bc2b5d6a055252152c47c700adfd3dd89aeb3a7c25c0f1e792d7ccbba3ed`, against delivered source D `a12b7cac05a818cc8d35c2ca440b7170a2807e92`. The package is intact and structurally valid, but its serialized inputs, complete observations, and several discriminating controls are not yet sufficiently determined to authorize implementation against a frozen contract. The seven bounded repairs below do not require certificate implementation during planning.

Reviewer: independent GPT-6 / gpt-6-astra, `/root/interface_final_check`. Author: native Grok, direct end-event `modelUsage` key `grok-4.6-build`, session `01a0804d-066e-70c2-a307-788ff22c80ab`, `end_turn`; root terminal receipt exit 0. Historical author/reviewer identities are unchanged. Current user authorization supplies Grok author / GPT-6 checker / no Foreman for the remaining program.

This is a source-level planning review, not a Lean elaboration, certificate execution, theorem audit, financial-source adjudication, or whole-certificate acceptance. `Lean.Data.Json` and all proposed Certificates declarations remain explicitly unelaborated. No Lean cache, network, excluded assessment, new holdout, production overlay, source edit, or plan edit was used. Ephemeral negative edits affected only the reviewer's external sandbox.

## Evidence established on this candidate

The receipt, compressed stream, decompressed raw hash, archive, anchor, and all 45 manifest rows agree. The 47 archived files comprise that manifest's files plus its self-excluding MANIFEST and ANCHOR. The inventory has 49 rows; all present bytes match. All 24 explicit used-source files equal `git show D:path`. The 53 readiness rows are preserved exactly: 52 present matching files and the explicitly absent non-D `agenda-inventory-after-m3-20260908.json`. Absence is neither manufactured evidence nor a new blocker. Readiness report SHA `9173e34ce186104f9593831d0f8061682656ea2de4eb888dcc424fc22014d9c2` and inputs SHA `341f00291a943e9f7d89684dc02a2f86fd7c9b58af315edc3f8ae783b082bffc` agree.

The actual frozen `package.py --check`, run with a bounded sandbox containing exact archived package and permitted source inputs, returned exit 0 and counts **5 capabilities, 26 requirements, 67 scenarios, 34 unchecked tasks, 46 fixtures, 16 mutants, 520 author consistency checks**. An independent installed OpenSpec strict invocation also returned 0. Counts identify inventories; they do not establish semantic discrimination or constructibility.

Meaningful independent checker-path controls, each followed by exact restoration, returned:

| Actual invocation | Exit | Observed boundary |
|---|---:|---|
| Intact package | 0 | `PASS_SEALED_PLANNING_PACKAGE`, gate false |
| Changed bound strict-output artifact | 1 | Actual manifest hash mismatch |
| Missing same bound artifact | 3 | Actual missing manifest input |
| Empty actual fixture inventory | 3 | Actual empty selection |
| SF01 changed to ZZ99 in the actual specification | 1 | Actual requirement/scenario consistency failure |
| Restored intact sibling | 0 | Same complete package accepted by integrity checker |
| Independent OpenSpec strict validation | 0 | Change valid |

Full argv, cwd, environment overrides, stdout/stderr, tool hashes, mutation timing/inputs, and source/package before/after bindings are in `certificates-official-r1-gpt6-evidence/`. Source/package bytes did not change. Git use in the sandbox was restricted to read-only identity and committed-source queries through the original Git directory; no index or branch mutation occurred.

Failure preservation is real: the root missing-brief-directory launch retains empty raw stream and setup diagnostic, with no authorship credit. Direct native terminal events retain prepare failures at raw lines 1966 (exit 3, missing non-D readiness row), 2082 (exit 1, M07 protected label), and 2206 (exit 1, scenario-map equality), followed by success. Interim streaming exit fields were not used in place of those terminal records. The full original stream remains bound.

## CERT-P1 — Freeze a constructible first-order representation and its raw-input boundary

`schema.json` gives an envelope, rational shape, natural identifiers, three enumeration arrays, and supported step names. It does not give the actual grammar that constructs the delivered dependent objects. `proposed-api.json` mostly names placeholders (`StateEnc`, `SerializedModule`, `Invocation`, `Grant`, “decoded typed inputs”). This leaves material choices unresolved before implementation:

- Exact `Unit`/`NumericUnit`/packed-value representation; all supported `Expr` constructors, argument indices and unit/signature checks; `PartyRef`, cell references and observation references.
- Template signature, domain, party arity, guard, ordered cell/supply deltas and declared read/write inventories; operation registry lookup and unknown-operation behavior.
- Full state table and nonnegative-state construction; duplicate/missing cell policy, finite-universe ordering and extensional equality. All kernel balances are total functions over `Domain × Party × Asset`, with a nonnegativity witness; a JSON object cannot simply be cast into that type.
- Exact capability entries, rights, liveness, store-index identity and administration configuration; context, environment observation/value/timestamp table and boundary schedule.
- Components, operation interfaces, ports, imports/exports and private cells; literal/prior-output input sources, qualified ports, absolute history positions, history origin, duplicate-key resolution, step/run mode and initial cursor behavior.

These are already required by the selected Typed and sequential Composition increment; they are not requests for Claims, Tree, Atomic, or arbitrary propositions. The author may choose a genuinely bounded constructor subset and explicit unsupported cases, or serialize the full delivered first-order language. It must state which. Any trusted external registry/environment/configuration input must be explicit in the checker signature and identity binding rather than being an undeclared ambient source.

`checkCertificate : Certificate → Report` takes an already decoded object, while its contract says “decode first,” F01 is raw empty bytes, and malformed JSON must never reach execution. Specify the raw bytes/JSON/decoded-IR entrypoints and their distinct outcomes. Define canonical nested-object keys, string/number encoding, duplicate JSON keys, significant array order, and raw lexical number policy. Rejecting scientific notation needs a stated parser/raw-byte strategy; this review does not assume a particular unelaborated Lean JSON parser retains or loses that distinction. State resource-limit behavior, including that a timeout/limit is blocked or incomplete evidence, not semantic refusal or acceptance. No particular arbitrary numerical ceiling is demanded.

Required repair: a source-mapped grammar and decoding/encoding contract sufficient to construct all supported inputs, with exact parser and canonical-byte identity rules. Preserve the explicit unelaborated status until later compiler evidence exists.

## CERT-P2 — Resolve the report, judgment, assumption, and completeness contradictions

`observation-contract.json` requires 14 fields and defines five status constructors. F13, F28, F43, F44, F45 and F46 respectively use an indeterminate status, `decode_ok`, an alternative-status phrase, a conditional completeness phrase, no status, and `blocked`. Some are legitimately codec or external audit tests, but their distinct result types are not specified. They cannot all be compared by the advertised `Report → Report → Bool` equality.

The proposed `JudgmentResult` has only Boolean `recomputed`, `claimed`, and `match`. Actual `Typed.execute` stops before arguments on unknown operation/actor/domain/arity errors, and before `Evaluated` on argument, authority or evaluation errors. Actual issue/revoke do not perform transfer accounting or argument checks. Define not-reached/not-applicable versus false, and how per-family classification coexists with actual short-circuit error precedence. Calling `Args.check` first to populate a mandatory judgment must not change F30's actual unknown-operation result. The actual `prepareInvocation` and catalog prechecks also precede Typed execution on the sequential path.

`complete_for_increment` requires executable families “recomputed and matched” but does not resolve whether a correctly observed refusal constitutes a complete checked report or an accepted module. Optional library/source-refinement families default outstanding and are not required for completeness, while F33/F42 and task 6.1 make their presence incomplete. Choose explicit required-obligation versus informational-outstanding rules. Arbitrary `Prop`, theorem-name strings, caller `Evaluated`, and claimed next-state values must remain non-evidence under either rule.

PB03 lists **six** assumption classes including environment; the JSON contract, common fixtures and S54 say **five**, omitting environment. Reconcile explicitly, including whether environment authenticity is a named class or deliberately subsumed by another class. Presence remains classification, not truth.

Define the complete failure/receipt/event serialization, exact constructor payloads, nullability, refusal-prefix world/store, outputs and index. `Sequence.advance` on a later refusal retains the earlier successful world, events, outputs and index and becomes inert; “world_on_accepted” alone does not specify that required refused observation. Disambiguate decode uniqueness versus catalog duplication so F08 reaches the intended `configuration` boundary.

Required repair: one consistent result algebra and completeness truth table, with explicit per-mode applicability and all expected fields. Audit/codec controls may have their own result type; do not expand the execution status enum accidentally through fixture prose.

## CERT-P3 — Materialize independently determined fixture inputs and observations

All 46 entries were read; `design-inventory-audit.json` preserves their per-entry assessment inputs and missing report fields. The existing fixtures are largely useful scenario descriptions, not literal complete test cases. Examples include F13 `well_formed_module: true`, F27 `catalog_valid: true`, F17 `guard_reads_balance: true`, and F26 `export_of_private_cell: true`. These cannot establish the very judgments the checker must recompute. F08 supplies only `[0,0]`, without otherwise-valid distinct operation/port/ownership data; multiple catalog faults could leave its mutant undetected.

The common fixture universe names 4 parties × 4 assets × 2 domains = 32 cells, but does not include the promised capability table or a complete baseline module/configuration. A comment pointing to `Composition.Examples.expectedStore` is not that table. The real table has 12 entries; real administration uses `.vault`, while the ordinary invocation boundary uses `.alice`. F22's `issue_then_revoke_id_0` cannot silently use the 12-entry store and ordinary invocation boundary: issuance then has fresh id 12 and needs an administrative boundary. This is an unresolved premise, not evidence that the delivered authority API is wrong.

F25's independent 10−3=7 and 0+3=3 arithmetic is correct. Its expected world omits initial alice collateral 10, alice debt 2 and pool USD 100. Applying the stated “unspecified cells 0” full-state convention to that expected world changes those balances incorrectly. If a baseline-plus-frame shorthand is intended, define and materialize that operation independently. The actual transfer preserves all these cells and the full store. F27 also omits actual receipt contents, snapshots, events and nextIndex, replacing them with true-valued descriptive claims.

Coverage of existing entries:

| Entries | What remains to make the planned control determinate |
|---|---|
| F01–F07, F11–F14, F28 | Exact raw documents or typed codec inputs; explicit valid baseline/patch location, parser boundary, full codec outcome and canonical-order sibling |
| F08, F26 | Full catalogs with only the designated invalidity and valid registry/interfaces elsewhere |
| F09–F10, F15–F25, F29–F30 | Exact templates, requests, contexts, stores, environments and full worlds; earlier-check premises established from literals |
| F27, F32 | Actual sequential steps, boundaries, histories, qualified ports, receipts and complete cursor observations |
| F31, F36–F37 | Actual compared reports/claimed world/source record, rather than narrative keys; intact same-input siblings |
| F16, F33–F35, F38–F43 | Literal non-evidence and assumption inputs under the chosen incomplete/outstanding policy |
| F44–F46 | Separate exact audit invocation/import inventory outcomes, rather than caller-supplied coverage/count booleans |

The plan promises history dependence and inert successful-prefix preservation but provides only a one-invoke success sketch and a future-output refusal sketch. Supply a literal successful producer/prior-output consumer and a successful-prefix→refusal→inert-later-step run, including independent full expected cursor fields. Issue and revoke need successful administrative observations and store identities. This qualifies the already chosen sequential scope; it does not require concurrency operators.

Required repair: complete independent baseline(s) with explicit, deterministic fixture substitutions and materialized expected observations, including full frame preservation and exact earlier-check premises. It is acceptable to reuse the cited development literals with source bindings. No new holdout or financial claim is needed.

## CERT-P4 — Repair the specific non-discriminating mutant/oracle pairs

All 16 mutant entries have syntactically distinct designated and protected labels. Nine existing source needles are unique at D; seven are correctly classified future anchors in the inventory. The following table assesses semantic design, not unrun detection:

| Mutant | Independent assessment |
|---|---|
| M01 | Its replacement calls `Args.check` in **both** branches. It does not implement the stated skip-check defect; removing `mapError` may instead create a type mismatch. The note defers the actual mutation. Replace with a precise future semantic branch that can accept the false claim and a feasible return type, without inventing typed arguments from a wrong-unit value. |
| M02 | Intended claimed-state bypass is useful. Specify decoding `StateEnc` into the actual execution-result/report type; `.ok w` currently names the wrong layer. F36 must be the same fully valid transfer sibling with only its claimed state changed. |
| M03 | Skipping accounting is discriminating on a funded, otherwise valid debit-3/credit-4 case; F25 is unaffected. Literal premises and runnable projection remain required. |
| M04 | Skipping debit authority can be discriminating with invoke authority present and all later checks valid; F25 is unaffected. |
| M05 | Removing component-id Nodup can be discriminating only if F08 has no additional catalog faults. It is not an “always true” catalog mutant. |
| M06 | F27 is a successful allowed-read case. Skipping read-access does not falsify it. The acknowledged dedicated forbidden-read companion is absent. Add it with valid catalog, valid writable targets, actual required forbidden read, and successful remaining kernel checks. |
| M07 | Canonicality defect and protected zero-denominator check are appropriate concepts. Freeze a complete future branch with exact error payload/type and positive one-half sibling. |
| M08 | The literal source change deletes actor checking; it does not swap two checks. F29's dual defect can detect the changed constructor and F25 is unaffected. Align name/description with the actual mutation. |
| M09 | Useful nonempty-theorem-string defect, conditional on fixing the result/outstanding policy and materializing F33/F38. |
| M10 | Useful invariant-string-as-pass defect; future result types and F38/F33 outcomes must be consistent. |
| M11 | Replacing exact `Option FailurePath` equality by `isSome` needs two valid complete reports with different **present** constructors. F31 currently supplies an untyped `{ok:false}` with no constructor, which can fail parsing before equality; it does not establish this mutant's designated false. Supply the exact comparator input pair. |
| M12 | Ignoring effects changes the F25 alice7 observation and leaves F23's earlier accounting refusal unchanged; this is a suitable semantic pair after projection and literal inputs are fixed. |
| M13 | Append→overwrite-head is meaningful, but F22 has no exact issued-id or old-entry preservation observation and no fixed administrative/store premises. Use a nonempty literal store and inspect returned fresh id, length, old entries and new grant before the later revoke/invoke observations. |
| M14 | Removing export-not-private is meaningful with an otherwise valid F26; F08's distinct duplicate-component control can remain protected. |
| M15 | Actual replacement changes `missingObservation` to `observationUnit`; this is an exact-constructor defect, not fabricated-zero behavior. The note is honest. Rename the intended coverage consistently and retain a real missing-observation input and protected typing refusal. |
| M16 | The supported-invoke fallback needs a payload that reaches that fallback and can otherwise decode as invoke; `{ctor:treeJoin}` alone does not establish a quiet accept. Freeze that valid-rest unsupported sibling or state an exact different refusal outcome that the mutant is meant to falsify. |

“Protected positive” means the comparison check remains true; it need not mean the kernel execution succeeds. Thus F08/F05/F15/F21/F23/F24 can legitimately protect an expected refusal. Do not replace these merely because they are refusal fixtures. Require each designated false and protected comparison to be computed over actual serialized/entrypoint behavior, not static labels.

## CERT-P5 — Define the mutation projection for actual dependency targets

`runner-adaptation.json` permits only name/comment adaptations from the inherited Interface driver. The actual driver captures all local imports but strips proof tails only when the module name starts `DefiKernel.Interface.`; it also requires an exact Interface namespace closure. A literal Certificates adaptation will leave proofs in imported Typed/Composition modules. The planned M03/M04/M05/M06/M08/M12/M13/M14/M15 alter those modules' computational definitions while retaining proofs of their old behavior. For example, M03 changes `applyEvaluated` while its `applyEvaluated_ok_iff` still states accounting validity. Compilation failure is correctly blocked by EV03, but cannot be credited as the intended semantic detection.

Required repair: freeze an explicit, source-bound runtime/proof projection and local dependency closure for each permitted mutation target and its consumers, including checks that no runtime declaration is discarded and that an intact projected sibling reproduces the intended observations. Alternatively choose another stated mechanism that executes the changed runtime behavior without requiring obsolete proof terms. Preserve the inherited one-mutant SPEC protocol, exact output grammar, protected checks, timeout honesty and nonzero failure classification. A new generic Lean parser or change to old accepted source is not required.

Correct design D10's stale grouping: it claims M01–M12 future and M13–M16 existing, whereas the actual inventory is seven future / nine existing across Check/Decode/Observation and Typed Transition/Authority/Expr plus Composition Interfaces. Do not count a compiler error from that mismatch as a caught mutation.

## CERT-P6 — Freeze correspondence proof obligations and actual audit/source identities

RC01 requires roundtrip for **every supported module**. Tasks 2.4, 5.1 and 5.2 only name finite fixture checks, and the latter allow “prove or computationally check” selected cases. The proposed API lists a Correspondence role but supplies no actual quantified representation or entrypoint theorem statements. Finite F25/F27 equality alone cannot establish faithful representation over the supported grammar.

Required repair: identify the exact supported IR domain, canonicality/validity hypotheses, extensional finite-state equality, and encode/decode and accepted/refused entrypoint correspondence statements; assign their proof/check obligations explicitly. Computational tests remain valuable independent evidence. If any correspondence is deliberately only bounded, label it bounded and do not use it to discharge the universal RC01 requirement. Wrapping actual `execute`/`executeStep`/`run` is the correct architecture but does not itself prove the codec is faithful.

PB05 requires imported Certificates **plus the explicitly used Typed/Composition modules**. Task 8.2 only invokes `#audit_axioms DefiKernel.Certificates`. The actual command filters theorem declarations by defining-module prefix; it does not inventory all theorem declarations in the imported Typed/Composition modules just because a Certificates module imports them. D11 also omits the proposed Correspondence and Soundness proof modules from its Certificates list. Specify actual audit invocations/scope equality and nonempty theorem inventory for all declared roots, including the new proof objects and their statements; preserve the auditor's supplemental inspection of definitions, opaque constants and axiom declarations. No whole-repository audit is demanded. If Examples is imported instead of only copying its independent literals, its real local closure includes `Composition.Preservation`; record that conditional dependency honestly.

A caller-supplied D string and audit-root strings cannot establish which checker/build or proof objects executed. Bind the immutable delivered dependencies, actual new checker candidate/toolchain and actual compiler/audit records separately from the untrusted certificate fields. Reject or classify stale/missing/substituted records through the actual matching path. This is ordinary source/evidence identity, not a request for a new cryptographic attestation system. Source authenticity, environment truth, replay prevention and deployed refinement remain explicit assumptions or later obligations.

## CERT-P7 — Replace scripted expected exceptions with real planning controls

In `package.py:run_controls`, empty inventory uses `if not []: raise Blocked`, missing-cited unconditionally raises Blocked, and changed-bytes unconditionally raises Failed. They do not pass changed inputs through `--check` or the relevant production validation function. The changed-spec helper raises the expected Failed even when its own discrimination condition fails; its valid sibling only checks one unchanged Typed source file. Therefore the five retained “matched” records do not substantiate their claimed checker-path behaviors.

The independent actual CLI probes above establish those current boundaries on this candidate, so this is not a claim that the current integrity checker accepts missing or changed inputs. Required repair: make the author controls exercise the real checker on isolated intact/empty/missing/changed candidates, preserve actual stdout/stderr/argv/exits, and ensure a broken control fails the control suite. Keep old records and failed attempts as historical evidence; do not replace their identity or retrospectively label them real gate executions. Reseal and rerun strict/integrity after the semantic planning repairs.

## Limits and next authorized step

The package correctly rejects names/tags as proof, routes computation through delivered APIs, preserves exact rational intent, separates runtime checks from `ComponentContract` propositions, keeps source truth external, restricts this increment to first-order Typed and sequential Composition, and leaves Arithmetic/Atomic/Claims/Tree/Nary/Quint/deployed refinement and future operators outside its acceptance claim. The original source-plan requirement to recompute judgments is preserved in intent. These strengths do not close the gaps above.

Native Grok can now repair only this planning package and its evidence/checker, preserving the frozen r1 archive and this review, then freeze a new official planning candidate for independent GPT-6 review. No user permission question or new mathematical/financial design is needed. Certificate implementation, source-level axiom acceptance, and global roadmap certificate checkboxes remain later gates.

Exact file, source, native, tool and review evidence identities are in `certificates-official-r1-gpt6-inputs.json`. No present verdict attaches to a later edited candidate.
