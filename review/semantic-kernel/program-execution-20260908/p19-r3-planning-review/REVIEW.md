# P19 official r3 targeted planning review

**CHANGES_REQUIRED — task 20.1 planning only.** The exact candidate is archive SHA-256 `e5b6415c6fe74b8654e9633e48dbc528118072b2f1306865b2c56855dab9b6a9`. R2, R4 and the substantive R5 guard repair are adequate at planning scope. Two narrow contract repairs remain in R1 and R3. Nine fresh real checker/control commands match their expected exits and diagnostics; those controls do not establish semantic correspondence.

The frozen gate remains false. P19 implementation, P20 quantified proofs/compatibility/library instantiation and qualified certificate delivery remain open. This review neither edits nor accepts implementation and requires no new fixture campaign, general parser, Lean execution or source repair.

## Remaining R1 — a projection of the report still observes prior policy

The new separation is useful, but `T-kernel-execute-ok` still concludes `kernelProjection(checkIR ir).world worldEq post` and an invoked receipt from successful decoding/mode and hypothetical `Typed.execute ... = .ok post`, without requiring the source-identity precheck to pass. The same file's precedence explicitly says **“source_identity mismatch: staleSource; kernel not invoked; world is pre”**.

F25, F36, F37 and F41 have identical complete kernel payloads (normalized structural payload SHA `27de8ee746e543cedc8ce887e90ce301d83307124cfe7401d984ebb02761c532`). F25's expected transfer post-world has alice USD 7 and bob USD 3. F37 changes source identity, expects staleSource, keeps alice USD 10 / bob USD 0, has a null receipt and marks execution families not reached. Thus the new theorem still demands a post-world and invoked receipt from a report which deliberately never executes. Renaming that projection does not resolve the contradiction. No separate raw execution function or definition that could return the missing execution observation is specified in the proposed API or authoritative contract.

F36 now correctly retains the recomputed post-world/receipt while refusing its false claimed world, and F41 retains the recomputation while classifying missing environment authenticity as incomplete. Those useful policy examples must remain. Their existence does not justify removing earlier guard premises from a theorem.

Required bounded repair:

- State the supported decoded execution domain, mode and actual **prior guard premises** wherever the theorem projects `checkIR`; or explicitly define a separate raw execution function and prove correspondence for that function, followed by a conditional report-projection connection.
- Apply that correction to Typed success **and error**, step success **and error**, run-cursor projection and claimed-world mismatch. In the error case, a stale report cannot have kernel failure `r` merely because a separate hypothetical execution would return `r`. The mismatch theorem must respect stale-source precedence too. Preserve exact wrapped/located failures, world/store, receipt, outputs, events and index.
- Complete the accepted-report policy premises for `require_library_discharge` / `require_invariant_discharge` and any required compiler/evidence checks. The result algebra explicitly requires incomplete when those flags are set without a recorded check; the current acceptance implication lists source identity, six-class presence, claimed-world agreement, unsupported none and required reached families, but does not define the requested-obligation condition. Use explicit checkable predicates, not assumed Report acceptance or the desired complete conclusion.

These remain unelaborated P20 proof obligations. The repair is a coherent planning statement and precedence table, not a request to prove or implement the checker now. Exact complete F25/F36/F37/F41 inputs and reports, and the theorem contract, are retained in `remaining-contract-findings.json`.

## Remaining R3 — staged accounting and the stored expectations disagree

F24/F49 now correctly store accountingCorrect=false on insufficientFunds, including the failed attempt after F49's successful prefix. The repaired full-world size, policy-refusal post-world and administrative receipt rules are also coherent at this scope.

However, the new authoritative `staged_family_aggregation.stage_order_typed_execute` assigns **guard** to accountingCorrect. `combine_one_command` says a family is true when at least one family stage was reached, all reached stages succeeded and later stages are not evaluated. F17 and F18 both have true guards that run before their stateReadFootprint/envReadFootprint refusals, yet both still store accountingCorrect=not_reached. Under the newly chosen mapping, each already reached a successful accounting stage. This is a literal contract/expectation contradiction, not an unrun mutant result.

Required bounded repair: classify guard consistently with the intended accounting family (the judgment contract names accountingOK and post-balance nonnegativity), or consistently update the staged mapping and these two expectations. Preserve actual guard-before-footprint execution order and never evaluate unreached accounting checks just to populate an outcome. Align the summary complete-refused rule with the chosen multi-stage family aggregation. F17/F18/F24/F49 and the exact aggregation text are retained in `remaining-contract-findings.json`.

## Repairs adequate at this planning scope

**R2:** All seven custom-operation fixtures now supply a matching live scoped invoke capability at ID 12; F09/F19/F23/F47 also supply the needed alice USD debit at ID 13. Requests refer to the actual permanent IDs. Every affected expected full capability store exactly equals its corrected input store. F18 supplies amount-USD observation data, removing the earlier observationUnit obstruction. F09's repeated debit totals −6 and credit +6; F23's funded −3/+4 reaches accounting; F40 reaches a genuinely absent observation after invoke; F47 declares the vault read to Typed while its component cannot read that resource, and its remaining write/authority/funded transfer premises now support the intended M06 design. This assessment reads actual source order and stored literals; it is not kernel execution. M03/M15 and their protected comparisons now have the required earlier premises. M09/M10 use the same JudgmentOutcome field type on both sides and keep outstanding obligations separate. See `repaired-authority-observations.json` and `projection-and-mutants.json`.

**R4:** The repaired contract specifies compact canonical bytes, raw lexical checks before normalization, named nested key orders plus a UTF-8 lexicographic fallback, source-map ordering and string escaping. `checkIR` is now restricted to DecodedExecution, with a distinct DecodedAudit route. Encoder/decoder byte equality is an explicit future obligation. This closes the previously contradictory whitespace/mode contract at planning scope; no codec implementation or universal roundtrip is accepted.

**R5:** The four exact Prop declarations StepSound, ReceiptAuthorized, TraceSound and RefusalSound are now allowlisted by module/name/kind/sort/path/source hash. Their source hashes match the delivered Execution and Sequence modules and the previous independent declaration inventory. Changed or unrecognized declarations still block; runtime declarations before the proof marker must remain. The intact projected sibling and all compiler-error/empty/timeout honesty requirements remain future implementation gates. The old `consumers_in_closure` arrays are still overinclusive closure lists, despite their “importers” label; use the measured import graph in `dependency-closure.json` when implementing. That naming issue does not block the specified whole-closure mechanism.

## Fresh executed controls and denominators

The real frozen r3 `package.py` was invoked against external reviewer-owned plan/package copies, with Wcert as the read-only dependency root. The frozen manifest was never resealed. All perturbations were restored from exact original bytes. Full argv/cwd/environment/timestamps/exits/log hashes are in `commands.json`; complete stdout/stderr is under `logs/`.

| Control | Actual exit | Observed result |
|---|---:|---|
| Intact package --check | 0 | nonempty sealed package |
| Bound STATUS.json changed | 1 | manifest mismatch |
| Bound STATUS.json missing | 3 | manifest missing, blocked |
| Empty fixture inventory | 3 | fixtures: empty (0 of 0), blocked |
| SF01 requirement identifier changed | 1 | requirement map identity failure |
| Exact restored package --check | 0 | nonempty sealed package |
| openspec validate serialized-kernel-certificates --strict | 0 | valid |
| r3 --reachability over stored r3 values | 0 | planning diagnostic passes |
| r3 --reachability over immutable stored r2 values | 1 | missing matching invoke and related old defects |

The last pair calls the actual stored-value diagnostic, not a reviewer clone or a manifest-mismatch substitute. It demonstrates the bounded reachability checks' discrimination. Inspection of that diagnostic also establishes its limits: checking theorem IDs, allowlist names and selected stored fields does not assess the missing premises or F17/F18 accounting disagreement above.

Measured package counts: 5 spec capabilities, 37 requirements, 99 scenarios, 38 unchecked tasks, 54 planned fixtures, 16 planned mutants, **636 structural planning checks**. Nine fresh commands matched expected behavior. Zero Lean executions, certificate executions or mutant detections are credited. Empty/missing controls are blocked outcomes, not semantic refutations.

## Provenance, preservation and handoff

Requested independent checker: **GPT-6 / gpt-6-astra**; no separate provider telemetry is exposed or inferred. Native author requested `grok-4.6`; both retained terminal streams report actual `grok-4.6-build`, session `01a0827d-aa5e-7b72-bba6-f23b7b809432`. The first attempt ended cancelled at 40 turns/process 1; its partial archive SHA is `a131784a5656d0cca0f7ceb1f6b29995417daf78d36c43cfdffbf6985e6cb4b2`. The bounded continuation ended end_turn at 14 turns/process 0. The shorter package model alias is historical metadata, not replacement telemetry. Both raw compressed streams, process receipts and partial archive are retained and hashed, including unsuccessful prepare/count attempts inside those streams. See `native-identity.json` and `input-snapshots.json`.

All 117 candidate files (25 plan, 47 unchanged historical r2 evidence, 45 r3 evidence) and 26 read-only inventory inputs were freshly verified. The eight runtime project modules and twelve-module closure including copied-example provenance/AxiomAudit still match primary and the prior immutable D bindings; conditional Composition.Preservation is included in that source record. Later primary plan/proof additions do not change this closure. Current AGENTS, prior sealed R1–R5 review and accepted P19/P20 program contract remain the scope authorities.

`after.json` records source, archive, sandbox, input and worktree-status preservation; prior r2 review evidence is unchanged. No source, frozen gate, historical evidence or Lean cache was changed. The checker slot is released. Root may route **only the remaining R1/R3 planning repairs** to native Grok. This rejected candidate has no delivery authorization; `evidence-manifest.json` is an immutable evidence handoff, not an acceptance manifest.
