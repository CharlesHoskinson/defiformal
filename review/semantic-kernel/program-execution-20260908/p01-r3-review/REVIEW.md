# P01 r3 independent re-review — ACCEPT_WITH_LIMITATIONS

All four required P01 findings R1–R4 are closed for this exact candidate and the retained independent evidence described below. No required source repair remains. This accepts the bounded compatible-recovery slice; it does not accept whole M4 or P02.

## Identity and preservation

Independent checker requested model: **`gpt-6-astra`**, through the stock Codex harness. Separate provider-returned model telemetry is not exposed to this session and is not inferred. Native author identity is preserved as requested Grok4.6, reported `grok-4.6-build`, process 0/`end_turn`; author exit is not acceptance. No Foreman, subagents, commits, pushes or candidate source edits were used in this review.

The frozen r3 archive SHA-256 is **`a2fde1553823c5ba33d7e94bab6ba74048e1f230ec35899fca045575766a3739`**. Changed source hashes:

| File | SHA-256 |
|---|---|
| `Recovery.lean` | `4fe6fffbe8825ff60c1c7c451e81e3db24e5ecfd7097db9e022c17dbe80714fc` |
| `RecoveryChecks.lean` | `9e96d42b571c6bde7096a00111333bd9371b3ba26f53f7a902ac9c975c103df4` |

All ten archived Tree sources match the live reviewed sources. All 51 bound source/config files match their manifest before and after review; HEAD remains `a12b7cac05a818cc8d35c2ca440b7170a2807e92`, and worktree porcelain is unchanged during this review. There are no new project modules. The six foundation files, Compatibility, DisjointRuntime, all 38 non-Tree dependencies and all three configuration files retain their r2 hashes. The r2 source archive, reports and failed-review evidence were not changed.

The source diff adds definitions/proofs/checks; no previous source statement is removed or weakened. All **1,360** previously source-explicit elaborated declaration types compare exactly equal against the r2 inventory. The prior detailed generic-premise review remains applicable. Evidence: [inputs.json](inputs.json), [before.json](before.json), [after.json](after.json), [archive-source-verification.json](archive-source-verification.json), and both `*-r2-r3.diff` files.

## Finding closure

### R1 — CLOSED by generic proofs

`Recovery.lean:1012` proves actual recursive `.2` equals `isolatedLocals` over `Tree.leaves`. Lines1024/1032/1040 prove both empty units and association as actual local-list equalities. `wellFormed_isolated_lookup` at line 1104 compares recursive DFS and roster locals by identity; it correctly does not assert that DFS order equals roster order.

`isolatedReference_roster_normalized` at line 1127 combines recursive world and identity-normalized locals. `complete_schedule_recursive_lookup` at line 1147 derives the shared complete-schedule local result from the original recovery theorem and the new local correspondence. Its premises remain well-formed tree, valid catalog, actual successful analysis, distinct-participant compatibility and completeness; the desired local equality is a conclusion, not a premise. Together with unchanged world flat-reference/grouping/frame laws, these discharge the original state/local reference requirement. Runtime companions include a swapped `[1,0]` DFS versus `[0,1]` roster and unit/association checks.

### R2 — CLOSED by candidate proofs/execution plus retained independent literal audit

The new actual branches are participant0: USD3 then USD8; participant1: shares4. Both `[0,0,1]` and `[1,0,0]` are complete. `refuseAdmit001` and `refuseAdmit100` invoke actual `admitIsolated`; error branches fail their runtime rows. Successful analysis and compatibility are not replaced by an empty-association fallback. Nonempty writes cause actual transfers and the refusing branch retains its successful prefix while its peer succeeds.

The candidate proves completeness for both schedules, kernel-certifies admission for001 (including an existence witness), and instantiates `complete_schedule_canonicalEq_of_admitIsolated` at lines 487/498. Those two instantiated theorems condition on actual admission; no conclusion premise is introduced. Admission100 is freshly exercised successfully. The generic theorem plus these checked premises and actual executions are sufficient for the bounded gate; another theorem packaging all concrete hypotheses into a single closed declaration is not required.

The candidate's `refuseCheck` verifies shared/isolated full canonical equality and independent literal AliceUSD7, BobUSD3, AliceShare4, VaultShare16, nonzero unowned sentinel9, unchanged capability store, consumed2/1, one event per participant and the financial refusal reason. However, its own literal checks only require nonempty output histories and do not independently specify every receipt or the failure index/step. The author report's description of exact local coverage is therefore broader than its 59 rows alone establish.

The additional reviewer-owned [LiteralWitnessAudit.lean](LiteralWitnessAudit.lean) closes that exact-field gap. It directly constructs complete expected local lists, independently of the executor, analyzer, receipt extractor, snapshot function and candidate expected-value helpers. Four passing comparisons cover both actual shared schedules and both admitted isolated references. They compare:

- consumed2/1 and nextIndex1/1;
- exact event index0, submitted invocation, request operation/arguments/capability IDs and actor field;
- evaluated receipt guard, signed balance deltas, supply/read/write fields;
- exact USD output3 at component0/port0 and share output4 at component1/port0, including ordered event outputs and retained histories;
- participant0 failure exactly `index1`, `some (invoke USD8)`, `kernel insufficientFunds`; participant1 has no failure.

These are independent measured checks, not new source theorems and not author coverage credit. Their exact source and complete logs are mandatory accepted evidence; omitting them would omit part of this acceptance basis. The original all-success association fallback remains only a companion and is not used to discharge R2.

### R3 — CLOSED by concrete kernel counterexample and execution

The candidate retains the old3/8 companion under an explicit auxiliary comment and adds the assigned withdrawals7/6 from10. Both schedules have completeness proofs. `funded_f15_normative_lr_alice3` and `_rl_alice4` at lines544/549 are kernel-checked concrete equalities (`decide +kernel`, not native evaluation admitted as a proof). `funded_f15_normative_canonical_ne` at line 553 derives `canonicalEq = false` from those unequal balances through the actual comparator equivalence. Actual analysis succeeds and the checker refuses compatibility; a separate kernel theorem records that fact.

Candidate execution confirms the balances3/4 and opposite losing identities/reasons. The last two reviewer literal-audit rows additionally check the entire losing failure: LR participant1 fails at index0 on `invoke USD6`; RL participant0 fails at index0 on `invoke USD7`; each winner has no failure. Both reasons are exactly `kernel insufficientFunds`. These close the precise opposite-failure requirement without a wider campaign.

### R4 — CLOSED by actual comparator controls

The source constructs one-field receipt-only, consumed-only, output-only and retained failure differences, and all canonical negatives pass. The raw-event pair differs only in an event's before-world while its final world/local canonical fields remain equal; the attempt pair differs only in global attempts. Each pair yields canonical true and `fullMachineEq` false using the existing production comparators. These are intentional synthetic projection controls, not claims that the synthetic administrative events arose from admitted financial execution. The positive/negative pair structure meets the bounded F19 distinction; full F19 campaign coverage remains P02.

## Fresh checks and exact counts

All commands ran from `/home/charl/defiformal-wt-sprint12-grok-gpt6-20260908/lean`. The exclusively assigned private `.lake` directory was used; no other worktree was built. [commands.json](commands.json) records exact argv, cwd, exits and durations. Complete stdout/stderr are retained under [logs/](logs/).

| Command/check | Result |
|---|---|
| `lake env lean --version`; `lake --version` | Both exit 0; Lean4.33.0-rc2 / Lake5.0.0-src+d8b1897, commit `d8b18978322de05a8f3dba51ef03cf5461676c17` |
| Targeted `lake build` of Compatibility, Recovery, RecoveryChecks | Exit0,971 jobs; exact unchanged artifacts replayed |
| Direct `lake env lean` on Compatibility, Recovery, RecoveryChecks | All exit 0; changed sources freshly elaborated |
| Candidate RecoveryChecks execution | **59 unique rows: 59 true, 0 false** |
| Reviewer LiteralWitnessAudit execution | **6 separate unique rows: 6 true, 0 false** |
| Complete imported declaration/type/axiom inventory | Exit0;48/48 project modules, 0 missing/extra |

The candidate's main rejects empty/duplicate inventories and any false row; the reviewer literal audit independently does the same. Counts are separately attributed in [runtime-summary.json](runtime-summary.json). There were no failed or timed-out check attempts in this r3 review. Historical r2 setup failures remain historical, without semantic refutation credit.

The refreshed [inventory.json](inventory.json) contains **5,797 elaborated declarations**, including **2,415 theorem constants**, 2,885 definitions, 123 inductives, 251 constructors and 123 recursors. All declarations have complete printed types and transitive axiom sets; there are no statement elisions. The only axioms are `propext`, `Classical.choice`, `Quot.sound`; forbidden rows and custom axiom declarations are zero. The 48 source files contain zero `sorry`, `native_decide` or `axiom` tokens.

The four P01 modules have 525 elaborated constants, including 269 theorem constants and 126 source-explicit theorem declarations (30 more than r2); 44 names are private/compiler-generated. These counts describe declarations, not independent financial guarantees. Source-explicit versus generated classification is documented separately from Lean's module-provenance discovery. [inventory-summary.json](inventory-summary.json) and [p01-named-theorem-statements.txt](p01-named-theorem-statements.txt) retain the new types and comparison results.

## Acceptance and delivery limits

- Accept only this exact P01 source manifest plus its retained review evidence. Include `LiteralWitnessAudit.lean`, its command receipt and complete execution logs in delivery; the six reviewer rows must remain distinct from the author's 59.
- Preserve the author's original report as historical evidence with the local-field coverage correction above; do not rewrite it to claim its own checks covered the reviewer literals.
- Carry the existing six-module foundation acceptance. Original tasks2.1–3.5 still await their P02 fixture obligations; P01 does not close them anew.
- P02's full F01–F20, ninety-schedule and eighteen-mutant campaigns, contracts/monitors and whole-M4 integration remain open. None was run or credited here.
- The mathematical claim remains conditional genesis compatible complete-schedule canonical recovery. Arbitrary populated-entry schedule independence, raw trace/monitor equality, deployed-source refinement, untouched evaluation and full-program completion are excluded.
- Parent owns integration, commit, push and readback to `semantic-kernel-pivot`; no merge to main is authorized by this verdict. The reviewed private Lean cache is released to the parent now.

There are no remaining required R1–R4 fixes. Later routine delivery should preserve this exact evidence basis and perform the affected-consumer/integrated checks appropriate to the composite delivered tree.
