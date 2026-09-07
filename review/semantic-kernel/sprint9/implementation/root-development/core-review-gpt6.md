# Bounded independent core review

Spec compliance: **ACCEPT WITH LIMITATIONS** for the three reviewed core modules.
Code quality: **ACCEPT**. No blocking findings or required source changes.

This is an internal nonauthor GPT-6 review by `/root/sprint7_runner`, not native
final acceptance. The reviewer did not author these three modules. The reviewer
previously authored the mutation driver/harness/spec; those artifacts and their
logic are expressly excluded. This review assesses the core's exposed mutation
sites against the accepted design, without independently accepting the reviewer's
own mutation specification. No Lean/Lake/control/mutation execution was performed
in this review. Root-reported LSP/build results are not recast as reviewer execution.

Reviewed at 2026-09-07T17:18:59.330053+00:00. Git HEAD was planning candidate
`0948c177f8939ca6dcc33557c34415d11545ef3e`; the reviewed implementation is new
working-tree source, not source committed at that planning revision. Each complete
file exactly equals the added bytes in `core-review.diff`, SHA256
`0400bdd78b9629e5810955f9bd228f94d28b6a6b320baee0d2d9143701b7d849`.

| Source | SHA256 |
|---|---|
| `lean/DefiKernel/Metatheory/SequentialGroups.lean` | `a42c93cc5a25e001f3da4e347e0dd8c1593ae9a167ca67185cecb808162aa448` |
| `lean/DefiKernel/Metatheory/Observation.lean` | `6ceedf99d806d8510fb609c94b2be2d8250c7453e12453d4ed11756d6238553b` |
| `lean/DefiKernel/Metatheory/Contexts.lean` | `6c0539645086ffe51e3668621ca7fa08d7937b6d590c3d9b3c6c649c79eac743` |

The normative comparison used the accepted r3 design sections 1–2 and mutation
site constraints in section 6, tasks 2.1/2.3/2.4/3.1–3.4, and the
`sequential-group-execution` and `continuation-observation` capability specs. The
planning gate/adjudication authorizes implementation, not final result acceptance.

## Semantic and premise review

- **Actual recursion and full-cursor simulation:** `SequentialGroups.lean:21–27`
  implements exactly empty identity, one actual `Composition.advance` at a leaf,
  and ordered recursion through the entire intermediate cursor. It calls neither
  `startCursor`, `run`, nor `flatten` in that runtime body. The separate flattening
  recursion supports the generic theorem at line 33; its only inputs are the shared
  configuration, boundary function, arbitrary cursor and group. There is no
  successful-run premise, trace invariant, fresh-cursor premise or assumed
  execution equality. Induction generalizes the cursor. The administrative actions
  are covered by the existing `Step` type and unchanged leaf semantics. Full-cursor
  empty identities, located-refusal absorption and ordered associativity follow;
  none claims reordering or transactional rollback.
- **Exact observations:** `Observation.lean:9–42` retains the current world plus
  `Parallel.observeBranch`. Its local event comparator checks index, complete step,
  complete receipt and outputs. The local recursive list comparator checks both
  order and length. The cursor comparison has explicit full-ledger, whole-store,
  events, history, next-index and complete-failure conjuncts. Leaf-field decidable
  equality is permitted by the design. No imported world/branch comparator or
  aggregate derived event equality hides these runtime sites. `cursorEq_iff` and
  the three relation laws compare exactly these same fields. Past raw event before
  and result worlds are omitted; current world state and capabilities are retained.
- **Adequacy without circular execution assumptions:** `world_eq_of_fields`
  derives actual world identity from pointwise balances and whole-store equality,
  using function extensionality and proof irrelevance for state nonnegativity.
  `advance_preserves` at line 121 extracts equal world, history, index and failure,
  then splits the real `Composition.executeStep` result once after substituting
  those equal inputs. Its failed-cursor branch is inert; its error branch preserves
  the observed prefix and exact new refusal; its success branch appends the same
  new observed event. The old event prefixes need only have equal observations.
  This matches the actual `Composition.advance` read dependencies and covers
  invokes, issue and revoke without a step-success hypothesis. Group preservation
  follows by recursion on the group.
- **Universal restricted contexts:** `Contexts.lean:8–28` admits only one hole
  with fixed groups before/after it. Configuration and boundary function remain
  shared external parameters. `GroupEquivalent` quantifies over every equivalent
  input pair, not one original state. Its transitivity uses the common middle
  execution at the right input; reflexivity follows from preservation. In
  `GroupEquivalent.fill` at line 52, the fixed-prefix case first preserves input
  equivalence, then invokes the universal induction hypothesis at those returned
  cursors. The suffix case preserves equivalence after substitution. There is no
  cursor inspection, cursor reset, additional peer or atomic-boundary constructor.

## Projection and code-quality review

All declarations needed by runtime or supporting proposition definitions occur
before the sole proof marker in each module (lines 29, 44 and 30 respectively).
The suffixes contain 6, 11 and 7 explicit theorems respectively, with `omit` commands
for unused instance binders and the exact final namespace closure. A read-only
source assertion found no definition/instance/structure/inductive declaration after
those markers, and no `sorry`, `native_decide` or custom axiom token. This is a
bounded source check, not the later elaborated dependency/axiom audit.

The imports are limited to actual sequence semantics, the new predecessor module,
and the existing observation data/leaf equality instances. No historical Tests or
proof-only fixture module is imported by these three files. Definitions and short
induction proofs follow the stated operator structure; no unused alternate
executor, test selector, assertion assumption, or replacement admission checker
appears. No code-quality revision is required.

The runtime seq block is explicit and unique, and the leaf call has a distinct
`.step action` prefix. The six planned observation omissions have separately
spelled ledger/store/history/failure/receipt/next-index expressions in the new
runtime prefix. Thus the required mutation sites are constructible without edits
to imported semantics. This does not establish full projected-closure uniqueness,
compilation of variants, designated false outcomes, or protected sibling outcomes;
those are still execution obligations under the source freeze.

## Limits and remaining evidence

The core implements the requested generic definitions and laws, but this bounded
review does not mark the complete task checkboxes done. Administrative/prefailed
instances, three nonempty groups, the middle-refusal funded suffix, exact field
sensitivity fixtures, the omitted diagnostic-world pair, fixed nonempty contexts,
and the one-entry-only counterexample belong to the independent fixture evidence
still being completed. Axioms/elaborated inventories, production projection cost,
all 14 mutations, all 65 controls, regressions and native final reviews remain
separate gates. In particular the six synthetic comparator detections must remain
separate from the eight routing detections. No stronger M2–M6 or deployment claim
is established here.
