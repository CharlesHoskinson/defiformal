# P19 official r4 planning acceptance

**ACCEPT_WITH_LIMITATIONS — program task 20.1 only.** The accepted planning candidate is archive SHA-256 `e73a61d9c98256270696ead1c3c554b070f100075b76d594d4ec251636ee5e5a`. The remaining R1/R3 planning repairs are adequate. There are no mandatory planning repairs left from the scoped r3 review. R2/R4 and the substantive R5 repair retain their earlier planning assessment.

This external verdict leaves frozen `STATUS.gate_accepted=false` unchanged. It does not accept a certificate implementation or prove correspondence. P19 implementation tasks 20.2–20.4, P20 quantified correspondence/compatibility/library instantiation, qualified certificate delivery and wider operators remain open. The statements remain explicitly unelaborated, with proof gates assigned to P20. No Lean/cache execution, certificate implementation, mutation campaign, commit or publication was performed.

## R1 — actual raw execution and guarded report connection

`rawExecute : DecodedExecution → RawObservation` is now explicitly separate from `checkIR` and never consults report policy. Its seven fields are world, receipt, outputs, events, nextIndex, cursorFailure and kernelFailure. The supported domain is the finite declared execution grammar, with complete nonnegative state tables, unique registry IDs, the matching mode payload and supported invoke/issue/revoke steps.

Five quantified raw obligations cover Typed success/error, step success/error and run-cursor. They state the relevant exact wrapped refusal, pre/post world and full store, receipt, outputs, events, index and located failure. Typed and standalone step observations use empty events, index zero and no cursor failure; the run projection retains the successful-prefix world, events, outputs, index, located refusal and last successful receipt. These are source-shaped specifications of delivered Typed.execute, Composition.executeStep and Composition.run, not proofs of a newly implemented wrapper.

The six checkIR connection/guard obligations now require the decoded execution domain and actual source-identity condition. A stale document has its own pre-world/null-receipt/not-reached theorem. The success, error, step and run connections therefore no longer infer a report observation from a hypothetical execution that its source guard prevented. The claimed-world mismatch theorem also requires source identity. The accepted-report theorem includes explicit `requested_discharge_ok`, alongside source identity, six-class presence, claimed-world agreement, supported form, successful raw result and the required reached families. No premise assumes Report.accepted or the desired final conclusion.

F25/F36/F37/F41 retain their identical entire kernel payload and distinct policy observations: F25 accepted post-world; F36 false claimed world refused with recomputed post-world/receipt; F37 stale identity refused with pre-world and no execution; F41 missing environment authenticity incomplete with recomputed post-world/receipt. Their exact stored inputs, reports, full statements and premise assessments are in `scoped-contract-audit.json`.

Two interpretations fix the intended reading for later implementation without changing the frozen bytes:

1. `recorded_*_compiler_check` must use the actual matching candidate/compiler/audit records required by `audit.identity_split`, including path/hash identity, successful compiler execution and nonempty relevant inventory. The shorter description of `source_pin.compiler_record` does not authorize trusting caller-supplied names, exit values or inventory claims alone. Assumption presence remains classification, not evidence of external truth.
2. The explicit source-guarded Typed/step error theorems preserve kernel failures after source identity. Success-report policy checks must not overwrite those error constructors. This follows the exact error obligations and the distinction between complete refusal and accepted execution; the prose sequence of policy checks is not authorization to weaken those obligations.

These are limits of the accepted contract, not evidence that an implementation satisfies them. P20 must elaborate and independently verify the actual obligations, including all required compiler/evidence connections.

## R3 — coherent accounting stages

Guard is now explicitly a prior check outside accountingCorrect. The judgment contract, staged aggregation, complete-refused summary and CC08 all agree. Guard still executes before footprint, but a true guard alone contributes no accounting stage. F17/F18 therefore correctly retain accountingCorrect=not_reached after their footprint refusals. F24/F49 retain accountingCorrect=false on the reached nonnegative-post-balance failure, including F49's failed attempt after a successful prefix. No accountingOK evaluation is authorized after insufficientFunds, and no unreached stage is evaluated merely to fill a report field. The four exact stored rows are retained in the audit artifact.

## Previously adequate repairs and source bindings

The r3 fixture file, mutation definitions, projection allowlist, baseline, schema and observation contract are byte-identical in r4. Thus the seven repaired scoped invoke/debit fixtures, F18 observation unit, full expected stores, type-compatible M09/M10 mutations and four source-bound Prop declarations retain their prior assessment. Canonical byte ordering/escaping and distinct execution/audit/codec domains are unchanged; the grammar only adds the explicit rawExecute route and source guard. All eleven edited plan files were compared directly to r3 (`plan-delta.json`, `other-plan-diff.txt`); no new operator scope or implementation gate is inferred.

The actual runtime closure remains eight project modules: Typed Types/Expr/Authority/Transition and Composition Interfaces/Contracts/Execution/Sequence. Including copied-example provenance and AxiomAudit gives twelve, with conditional Composition.Preservation recorded. All source bytes and fourteen Lean/toolchain/config inventory inputs match current primary and the prior immutable D bindings. `dependency-closure.json` retains the measured graph. Cached objects are not acceptance evidence.

Of the full twenty-six historical inventory inputs, twenty-three match primary. Three context files differ: `AGENTS.md`, `roadmap.md`, and `docs/research/semantic-kernel-progress.md`. Their exact Wcert snapshots are retained. They must not replace current primary instructions/progress. Historical package replay uses an explicit retained dependency root, as the actual commands did; this review does not claim the old context hashes describe current primary.

## Fresh real controls

All ten bounded commands completed with the expected actual exit and diagnostic. The real frozen r4 package.py ran with external reviewer-owned plan/package copies, read-only Wcert dependencies, and no reseal of frozen inputs. Every perturbation was restored byte-for-byte. Exact argv, cwd, environment, timestamps, exits and full log hashes are in `commands.json`; full stdout/stderr is in `logs/`.

| Control | Actual exit |
|---|---:|
| Intact package --check | 0 |
| Changed bound STATUS.json: manifest mismatch | 1 |
| Missing bound STATUS.json: manifest missing | 3 |
| Empty fixtures: empty (0 of 0) | 3 |
| Changed SF01: requirement-map identity failure | 1 |
| Exact restored package --check | 0 |
| openspec validate serialized-kernel-certificates --strict | 0 |
| Stored r4 --reachability | 0 |
| Real r4 diagnostic on preserved r2 values | 1 |
| Real r4 diagnostic on preserved r3 values | 1 |

The last two are direct stored-value checks, not manifest-mismatch substitutes. Missing/empty controls are expected blocked results, not semantic refutations. Fresh intact/restored checks measure 5 spec capabilities, 37 requirements, 99 scenarios, 38 unchecked tasks, 54 planned fixtures, 16 planned mutants, **640 structural planning checks** and **71 current manifest entries**. These are not kernel/certificate executions or theorem proofs. The author's earlier 43-entry successful control seal and 68-entry live-control reseal failure remain historical; the 71-entry frozen package is the candidate freshly verified here. No failure is converted to semantic detection.

## Native identity, preservation and accepted handoff

Independent checker requested: **GPT-6 / gpt-6-astra**; separate actual provider telemetry is unavailable and is not inferred. Native author requested `grok-4.6`; the retained raw terminal reports **grok-4.6-build**, session `01a0827d-aa5e-7b72-bba6-f23b7b809432`, 27 turns, end_turn. Root's frozen process receipt records exit 0. The raw stream, stderr, previous cancelled attempt, partial archives, failed prepare/count attempts and live-control reseal failure are preserved with their original identities. See `native-identity.json` and `input-snapshots.json`.

All 165 candidate files (25 plan, 47 r2 evidence, 45 r3 evidence, 48 r4 evidence), 26 read-only inputs, 92 historical evidence files, prior r3 review bytes and worktree status are preserved. The accepted plan is exactly the frozen overlay; source/context translations must be recorded separately. `accepted-inputs.json` identifies that overlay and the dependency-root requirements; `evidence-manifest.json` binds this report and retained evidence. This authorizes task 20.1 planning closure only, with the two interpretations above carried into implementation/review. The independent checker slot is released.
