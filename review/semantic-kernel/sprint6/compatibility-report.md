# Sprint 6 compatibility implementation

Implementation uses stock GPT-6, with the Lean skill. Planning gate passed before implementation.
New sources are uncommitted work on baseline `2267e00`; the SHA-256 manifest binds tested source
bytes and does not identify them with the baseline commit. No existing source was changed by
this task. No commit or task checkbox update was made.

`Compatibility.lean` implements closed `BranchId.left/right`, invocation-only `Branch`,
`ParallelBoundary`, `Footprint`, `LocalFailure`, `ConflictKind`, and `AdmissionFailure`.
`analyzeInvocation` resolves lookup, registry, required/declared reads, declared writes plus
all delta targets, and existing access checks, in that order. Reads additionally contain
all writes and selected outputs. Duplicate list entries remain to make witnesses stable.
Numeric inputs, prior outputs, authority, balances, time and environment are not evaluated.
`analyzeBranchFrom` preserves local indices and structurally visits the complete submitted
suffix. `analyzeBranch` starts at zero. `admit` validates catalog, then left, then right,
then `checkCompatibility` checks write/write, left-write/right-read, right-write/left-read.
`firstOverlap` selects the first conflicting entry of the first list.

The computation section ends at `-- BEGIN PROOFS`, suitable for actual-source mutation
projection. `Compatible` is a separate proposition, proved equivalent to the executable check.

Generic proved declarations (namespace `DefiKernel.Parallel`):

- `firstOverlap_none_iff`
- `checkCompatibility_ok_iff`
- `compatible_symm`
- `analyzeInvocation_ok`
- `resolveRefs_member`
- `analyzeBranchFrom_cons`
- `admit_ok`
- `admit_compatible`
- `resolveRefs_mem_of_resolve`
- `resolveRefs_append_ok`
- `analyzeInvocation_coverage`
- `analyzeInvocation_writes_read`
- `analyzeBranchFrom_member`

`analyzeInvocation_ok` exposes actual catalog/registry selection, successful reference resolutions,
access acceptance, and exact footprint concatenation. `analyzeInvocation_coverage` proves all
required and declared reference memberships, all writes/targets, selected outputs, and writes
included in reads without assuming invocation success. `resolveRefs_mem_of_resolve` identifies a
particular resolved cell; `resolveRefs_append_ok` splits resolved concatenation. Branch membership
uses `branch[n]? = some inv` and proves analysis at `index + n`, with both local regions included
in the accepted whole-branch footprint. `admit_ok` exposes catalog validity, both accepted
analyses, and compatibility. These proofs are generic over arbitrary identity types with
`DecidableEq`; no finite reference-universe assumption or financial success premise is required.

Validation: targeted normal Lake build passed. The standalone runtime driver ran 42 unique,
nonempty comparisons, all true, including independently specified complete funded transfer worlds
and stores, exact conservative lists, common reads, both conflict directions, funded hidden
conditional guard/delta/supply siblings, output reads, successful zero undeclared targets,
unreachable suffixes, local error ordering and witness precedence. Positive branch typing passed;
separate issue/revoke inputs failed with actual `Composition.Step` versus `Composition.Invocation`
type mismatches. These are compiler refusal controls, not financial counterexamples.
All 13 named theorem axiom queries completed; only `propext` and `Quot.sound` appear. There are no
proof holes, custom axioms or native decision proofs in these new accepted sources.

Evidence: [commands and exits](compatibility-evidence/runs.json),
[complete runtime log](compatibility-evidence/Runtime.log),
[axiom queries](compatibility-evidence/Axioms.log),
[source manifest](compatibility-evidence/sources.json), and
[tool identities](compatibility-evidence/tools.json). Runtime check IDs are exactly the 42
`parallel.compat.*` labels printed in Runtime.log and defined by `CompatibilityTests.checks`.

Limits: these tests are development fixtures, not preserved holdouts. Full imported generated
axiom coverage, actual-source semantic mutations, full regression and independent native review
remain integration tasks. Admission has no world argument and cannot emit execution artifacts;
the public operator's exact refusal world/output/receipt preservation must be checked/proved in
Execution. This module alone makes no execution congruence, commutation or financial preservation
claim. The membership proof supplies the concrete dependencies needed for those separate proofs.

Source SHA-256 values:

- `lean/DefiKernel/Parallel/Compatibility.lean`: `4459fa2b4a4f1f695d3856cb67a46a7c9df86a90f924be8bd26f55e99ba54243`
- `lean/DefiKernel/Parallel/CompatibilityTests.lean`: `d3a90763fc468c09f8474e18ba95ae0ac6f6750d38d88f4b49d9b72beafc1379`
