The new Parallel mutation runner and its synthetic CLI harness are implemented.
The final harness executed **45 cases: 45 passed**, with five accepted toy
mutation runs, four expected assertion failures (exit 1), and 36 expected blocked
runs (exit 3). This is runner infrastructure evidence. Production financial source mutation results are recorded separately under
`mutations/`; this report counts only synthetic runner controls.

The actual command was:

```sh
python3 scripts/test_parallel_mutation_runner.py --repo . --out /tmp/sprint6-controls-final-fae07ca
```

It ran from `/home/charl/defiformal` and exited 0. The repository head observed
was `fae07caa2620c7a1d4ba1a39cb9a9be171ff137d`. The executed runner and harness bytes match their
Git objects at that commit. Exact executed script snapshots and hashes are saved
with the [final summary](runner-controls/final-fae07ca/summary.json) and
[invocation record](runner-controls/final-fae07ca/invocation.json).

| Input or tool | SHA-256 |
| --- | --- |
| `scripts/check_parallel_mutations.py` | `415a92033788a8cfe2e397a3722457c9597610b5001eac0e18ada3d0809dd5d0` |
| `scripts/test_parallel_mutation_runner.py` | `14d807f04c36ad61e3de854ab693f29417201e531942bf012e0c5a84b1f9bb79` |
| Lean executable | `e8baaa71855a616dc351028f3ad2200051b0671f423a1696a100e809302d5550` |

Lean reported version `4.33.0-rc2`, commit
`d8b18978322de05a8f3dba51ef03cf5461676c17`. Each executed variant retains
its generated Lean source, complete log, actual exit, source/specification hashes,
projection order, and tool identity. The accepted cases additionally verify that
captured local source, specification, and runner bytes did not change during
replay. The [artifact integrity check](runner-controls/final-fae07ca/artifact-integrity.json)
passed 470 assertions, including exact source snapshot, specification, generated
fixture and log hashes. Python parsed both final scripts successfully.

The runner requires explicit `--repo`, `--spec`, and `--out`. Output must be a
new location outside the input repository. Module roots must be scoped to
`DefiKernel.Parallel` and include `DefiKernel.Parallel.Audit`. Its manifest
records the complete discovered `DefiKernel` source import closure. A new
Parallel module imported by a listed root is discovered and inlined even if it
is absent from the mutation-site inventory. Mutation targets still must appear
in that inventory. Cached local `.olean` files are not imported by the flattened
execution source. Only new Parallel proof suffixes following `-- BEGIN PROOFS`
are excluded; dependency proof code is retained. The projection expects the
established one-module-per-import-line syntax and exact namespace closure.

Each unchanged control must execute a nonempty, unique, well-formed named
inventory with every comparison true. Each mutation must change exactly one
source occurrence, execute exactly the same inventory, fail every designated
comparison, and retain all protected positive comparisons. Only the expected
`Parallel runtime comparisons failed: N` runtime error is allowed for a counted
mutation. Compile-only errors, compiler errors alongside false comparisons,
unapplied/nonunique/no-op edits, surviving mutations, and incomplete execution
cannot produce acceptance. The supported observation grammar remains lowercase
dotted segments with hyphens or underscores within segments.

All five accepted synthetic cases execute two comparisons. The unchanged control
prints its protected positive and sensitivity comparison as `true`; the mutation
prints the same protected positive as `true` and the sensitivity comparison as
`false`. The extra-module case also checks that the unlisted split module and
its exact bytes appear in the captured closure. These are observations of small
natural-number computations, not financial semantics or new mathematical proofs.

The stale dependency control first compiles an actual local dependency `.olean`
with value 4, then changes that dependency source and its theorem to value 5.
The importing source still requires value 4. The runner sees the changed source,
reports the resulting compilation failure, and exits 3 despite the available
old cache. Its setup command, source/cache hashes, and compiler log are saved in
[the case records](runner-controls/final-fae07ca/cases.json).

The controls cover empty, duplicate, missing and unknown observations/inventories;
partial or extra mutant observations; malformed labels/JSON; source/setup failures;
missing or foreign audit roots; invalid output paths; and mutation/positive-control
failures. Every rejection family is exercised beside a valid accepted sibling.
The initial test-first run against the unchanged Composition runner failed the
new Parallel positive controls because that runner correctly rejects Parallel
scope. A later control exposed an inherited parsing gap: an uppercase malformed
observation was silently ignored and the old parser returned 0. The new parser
blocks it. Those development failures are preserved separately under
[development-red](runner-controls/development-red/uppercase-parser-run.json)
and are excluded from the 45 accepted final control assertions.

This work added only the two new scripts and focused Sprint 6 runner evidence.
It did not edit old runners, Lean source, task checkboxes, or Git commits.
Production financial mutation results, native implementation review, and final
frozen-candidate acceptance are separate integration evidence.

The first production replay passed its unchanged 131-comparison control, then
blocked on the first mutant because Lean unused-variable `Hint:`/`Note:` text
was mistaken for an uppercase malformed observation. A real warning-producing
toy mutation reproduced that block. The revised runner excludes only the two
observed diagnostic prefixes and continues to reject malformed uppercase labels.
The added positive control asserts the actual compiler warning and both
continuation messages, as well as exact runtime comparisons. Its test-first
failure is retained under [revised development evidence](runner-controls/revised-45/development-red/summary.json).
The earlier 44-case bundle remains unchanged at `runner-controls/`; the current
45-case development bundle is at `runner-controls/revised-45/`. The final
postcommit acceptance bundle is at `runner-controls/final-fae07ca/`.
