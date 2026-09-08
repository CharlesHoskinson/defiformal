# P01 R1–R4 bounded repair (native Grok 4.6)

Status: `candidate_pending_independent_review`. This is a bounded repair of the
accepted M4 recovery slice against GPT-6 P01 findings R1–R4. It is not whole-M4
acceptance, not P02, and not author self-acceptance.

- Author: native Grok 4.6
- Checker: independent GPT-6 (not this document)
- Foreman / subagents: not used
- Commits / push / OpenSpec task-checkbox edits: none
- Worktree: `/home/charl/defiformal-wt-sprint12-grok-gpt6-20260908`
- HEAD: `a12b7cac05a818cc8d35c2ca440b7170a2807e92` (unchanged)
- Frozen r2 archive (preserved, not overwritten):
  `review/semantic-kernel/program-loop-20260908/native-worker/m4-compatible-recovery-r2-stage.tar.gz`
  SHA-256 `9b700c0f6ff4a49d008cb3e5eb6a6d9a6b10ad9366b8a63f0c2619eb205c7741`
- Review contract: `/home/charl/defiformal/review/semantic-kernel/program-execution-20260908/p01/REVIEW.md`
- Cache: this worktree `lean/.lake` (directory, exclusive to this author after GPT-6 release)
- Lean 4.33.0-rc2 / Lake 5.0.0-src+d8b1897 (`d8b18978322de05a8f3dba51ef03cf5461676c17`)

The generic recovery theorem `complete_schedule_canonicalEq` and its inspected
premises are retained with the original claim boundary. No historical theorem
statement or docstring was edited to make a result pass.

## Changed sources

| File | SHA-256 | Bytes |
|---|---|---:|
| `lean/DefiKernel/Nary/Tree/Recovery.lean` | `4fe6fffbe8825ff60c1c7c451e81e3db24e5ecfd7097db9e022c17dbe80714fc` | 59879 |
| `lean/DefiKernel/Nary/Tree/RecoveryChecks.lean` | `9e96d42b571c6bde7096a00111333bd9371b3ba26f53f7a902ac9c975c103df4` | 27038 |

Unchanged (r2 hashes): `DisjointRuntime.lean`, `Compatibility.lean`, and the six
sealed foundation files (`Shape`, `Execution`, `Paths`, `Observation`,
`Simulation`, `FoundationChecks`). No new Tree modules were added.

Source token scan of the two edited files: zero `sorry`, zero `native_decide`,
zero `axiom` declarations. Computational kernel facts use `decide +kernel`.

## R1 — recursive local-list correspondence

`runIsolatedTree_locals` proves
`(runIsolatedTree … tree).2 = isolatedLocals … (Tree.leaves tree)`.
Empty-left, empty-right and association laws hold as actual list equalities on
`.2`. Well-formed roster correspondence is identity lookup
(`lookupIsolatedLocal`), not DFS-equals-roster list equality.

`isolatedReference_roster_normalized` combines the recursive world with
roster-normalized locals. `complete_schedule_recursive_lookup` derives shared
complete-schedule locals versus the recursive list by identity from the existing
`complete_schedule_canonicalEq`; it does not assume the desired equality.

Runtime: `recovery.r1.locals-eq-leaves`, `recovery.r1.dfs-not-roster` (swap tree
DFS `[1,0]` versus roster `[0,1]`), `recovery.r1.lookup-normalized`, unit and
association local rows.

## R2 — compatible refusal recovery witness

`refuseBranches`: identity 0 runs USD3 then USD8; identity 1 runs shares 4.
Complete schedules `[0,0,1]` and `[1,0,0]` (counts match branch lengths 2 and 1).
Admission is the actual `admitIsolated` result: `.error` fails the check. There
is no empty-assoc fallback on this witness.

Independent expected values (from Parallel.Examples genesis Alice USD 10, vault
share 20, protectedCell 9):

| Field | Expected |
|---|---|
| Alice USD | 7 |
| Bob USD | 3 |
| Alice share | 4 |
| Vault share | 16 |
| Unowned sentinel `protectedCell` | 9, nonzero |
| Capability store | initial store |
| Consumed | 2 (refusing stream), 1 (peer) |
| Events | one successful prefix event each |
| Outputs | nonempty on both |
| Located refusal | identity 0, `.kernel .insufficientFunds` |

Kernel binding: `funded_refuse_canonicalEq_001` / `_100` are `exact`
`complete_schedule_canonicalEq_of_admitIsolated` on this catalog.
`funded_refuse_admit_001_isOk` / `_exists` certify actual admission.
`funded_refuse_independence_of_admit` compares the two complete orders through
the same admitted reference.

The older all-success `disjAssoc` still uses analyzeAll-or-empty for the
all-success companion. That is not the R2 witness.

## R3 — assigned F15 7/6 from 10

Existing USD3/USD8 opposite-order rows remain, labelled as the auxiliary
companion. `funded_f15_complete` is unchanged.

Normative D7 instance: USD7 versus USD6 from 10.

| Order | Alice residual | Refusal |
|---|---|---|
| `[0,1]` | 3 | identity 1, `.kernel .insufficientFunds` |
| `[1,0]` | 4 | identity 0, `.kernel .insufficientFunds` |

Kernel: `funded_f15_normative_lr_alice3`, `funded_f15_normative_rl_alice4`,
`funded_f15_normative_canonical_ne` (3 ≠ 4 bridges to `canonicalEq = false`),
`funded_f15_normative_incompatible` (analyzeAll succeeds and pairwise check is
not `.ok`). `competing_writes_not_compatible` is not weakened.

## R4 — canonical versus full field controls

Existing valid controls reused: reflexivity, failure-diff, world-diff. Added:

- Canonical negatives: receipt, consumed, output (failure already present)
- Canonical positives / full negatives: raw event-world only, global attempts only

Comparators are the existing `canonicalEq` and `fullMachineEq`. No second
implementation and no F19/P02 campaign.

## Compile and checks

All official commands from `lean/`, exit 0. Complete stdout/stderr in `logs/`.

| Label | Command | Exit | Seconds |
|---|---|---:|---:|
| lean-version | `lake env lean --version` | 0 | 0.446 |
| lake-version | `lake --version` | 0 | 0.037 |
| targeted-build | `lake build Compatibility Recovery RecoveryChecks` | 0 | 0.639 |
| disjointruntime | `lake env lean DisjointRuntime.lean` | 0 | 1.587 |
| compatibility | `lake env lean Compatibility.lean` | 0 | 1.452 |
| recovery | `lake env lean Recovery.lean` | 0 | 2.096 |
| recoverychecks | `lake env lean RecoveryChecks.lean` | 0 | 5.331 |

`recoverychecks` printed 59 unique nonempty rows, 59 true, 0 false, no duplicate
names, suite non-empty. Incremental compile failures during authoring are in
`attempts/` and receive no mutation-detection credit.

## Limitations

- Not P02 eighteen mutants, full F01–F20, or ninety-schedule enumeration
- Foundation six-module acceptance is carried, not re-closed
- No whole M4 / whole-program acceptance
- No deployed-source refinement or untouched evaluation credit
- Arbitrary populated-entry schedule independence remains excluded
- `disjAssoc` empty fallback remains on the all-success companion only
- Author report is not GPT-6 acceptance

Next action: root freezes this candidate archive and obtains targeted GPT-6
rereview of the exact repaired sources.
