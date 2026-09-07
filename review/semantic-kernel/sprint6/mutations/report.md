Final production replay at `fae07caa2620c7a1d4ba1a39cb9a9be171ff137d` passed: **14 of 14 actual
source mutants detected**, with 131 true comparisons in the unchanged control,
131 comparisons in every mutant, and all five protected comparisons true in every
variant. The accepted main replay executed 1,965 named comparisons across its
control and 14 mutants. These counts describe bounded execution sensitivity;
they are not counts of mathematical proofs or deployed-contract validation.

The accepted command ran from `/home/charl/defiformal` and exited 0:

```sh
python3 scripts/check_parallel_mutations.py --repo . --spec review/semantic-kernel/sprint6/mutation-spec.json --out /tmp/sprint6-production-final-fae07ca
```

The [final summary](final-fae07ca/summary.json),
[complete command log](final-fae07ca/cli.log),
[per-variant results](final-fae07ca/results.json), and
[source manifest](final-fae07ca/source-manifest.json) retain the actual command,
exit, generated source hashes, all named observations, required false comparisons,
protected positives, input status, and tool identity. Each counted mutation applied
exactly once to the actual new implementation source, compiled and executed the
complete unique inventory, and produced only the expected runtime-comparison
failure. No compile-only failure, survivor, partial inventory, or failed protected
positive is counted as a detection.

The [canonical specification](../mutation-spec.json) has SHA-256
`5c5fc372c1547271ea8baaedf7fc60bc79efd10c62458bc8934a3a3554426a35`. The executed runner has SHA-256
`415a92033788a8cfe2e397a3722457c9597610b5001eac0e18ada3d0809dd5d0`. Lean reported `Lean (version 4.33.0-rc2, x86_64-unknown-linux-gnu, commit d8b18978322de05a8f3dba51ef03cf5461676c17, Release)`;
its executable SHA-256 is `e8baaa71855a616dc351028f3ad2200051b0671f423a1696a100e809302d5550`.
The capture contains 24 local source modules and three Lake/toolchain inputs.
All captured source, specification, and runner bytes remained unchanged throughout
replay. The scoped Git input status was empty at run start.

The [Git object binding](final-fae07ca/git-object-binding.json) independently
checks all 30 source/specification/script bindings against the observed committed
candidate. The [artifact integrity check](final-fae07ca/artifact-integrity.json)
passed 160 assertions with zero failures, including full log/input/generated-source
hashes, complete inventories, required false/protected true comparisons, and equality
with the earlier successful development replay's captured sources and results.

| Mutation | False comparisons | Required oracle observed false |
| --- | --- | --- |
| `bypass-write-write-composite` | 14 | `parallel.compat.write-write-witness` |
| `omit-expression-reads-composite` | 9 | `parallel.compat.hidden-inactive-guard`, `parallel.compat.hidden-delta`, `parallel.compat.hidden-supply` |
| `omit-output-dependency` | 2 | `parallel.compat.output-dependency` |
| `omit-zero-delta-target` | 14 | `parallel.compat.zero-target`, `parallel.compat.zero-target-exact` |
| `omit-reverse-conflict` | 1 | `parallel.compat.reverse-read` |
| `cancel-peer-after-refusal` | 9 | `parallel.fixture.refusal.peer-runs` |
| `rollback-refused-prefix-at-join` | 5 | `parallel.fixture.refusal.prefix-kept` |
| `replace-merge-with-left-world` | 20 | `parallel.fixture.basic.complete` |
| `double-initial-balances` | 28 | `parallel.fixture.basic.complete` |
| `leak-peer-output-history` | 20 | `parallel.fixture.routing.peer-only` |
| `reuse-left-trusted-boundary` | 1 | `parallel.fixture.boundary.local-identity` |
| `drop-peer-supply-receipts` | 1 | `parallel.fixture.supply.both-receipts` |
| `reuse-live-capability-store` | 1 | `parallel.fixture.capability.revoked` |
| `stale-intra-branch-evaluation` | 26 | `parallel.fixture.stateful.prefix` |

The [mutation design record](mutation-design.md) documents the actual edit and
independent oracle for each of the 14 planned classes. The write/write bypass
is explicitly composite: writes also contribute to reads, so all three conflict
guards are removed together. The expression-read omission is also composite:
the admission collector loses syntactic and redundant declared reads, while the
registered template retains its valid declarations and successful underlying
executor controls. The target omission uses a zero delta absent from declared
writes; its funded underlying-kernel comparison remains protected and true.

The history mutant seeds the left consumer from right-branch outputs. A
[supplemental captured-source diagnostic](history-diagnostics/results.json)
confirms the intended behavioral distinction. In the control, the left branch
refuses at local index 1 with Alice/Bob USD balances 7/3. Under the mutation, the
same consumer succeeds, reaches local index 2, and leaves balances 2/8 after using
the peer's USD5 output. This rules out relying only on an incidental extra-output
mismatch. The diagnostic base hashes match the final accepted control and mutant
source hashes; the supplemental runs add no counted mutation detections.

The stateful mutant changes intra-branch evaluation to use the original world at
every step. Its designated oracle checks independently expected state-dependent
effects, accepted prefix, exact refusal, receipts, outputs and complete final
world. It does not substitute a cached serial result for actual branch execution.
The boundary, dropped-peer-supply and stale-capability mutants each fail exactly
one designated comparison. Their bounded fixtures use distinct trusted boundaries,
independent USD2/share-3 receipt totals, and an actually revoked right-side grant.

The final [runner CLI controls](../runner-controls/final-fae07ca/summary.json)
passed 45 of 45 cases at the same commit: five accepted toy runs, four expected
assertion failures, and 36 expected blocked cases. Their
[integrity check](../runner-controls/final-fae07ca/artifact-integrity.json) passed
470 assertions, including exact committed runner/harness bytes. The
[runner report](../mutation-runner-report.md) records malformed/empty/duplicate/
partial inventory, real stale-cache, edit, compile, survivor, positive-control,
output-location, and compiler-warning controls.

The first production attempt remains under
[development-blocked-r1](development-blocked-r1/cli.log). Its control passed, but
the runner mistook Lean unused-variable diagnostic continuations for observation
labels and blocked the first mutant. It contributes zero accepted detections.
A real warning-producing toy test reproduced the problem; the corrected runner
passes that control while continuing to reject malformed uppercase labels.
The earlier successful development replay remains in this directory's root files;
`final-fae07ca/` is the final committed-candidate acceptance bundle. Raw earlier
logs/manifests were retained without rewriting their original heads or paths.

Accepted financial and proof source files were never edited by the mutations.
The runner captures fresh local dependency source and excludes only new Parallel
proof suffixes from temporary executable projections. Full kernel proofs, imported
axiom coverage, scenario completeness and native review are separate acceptance
evidence. The probes establish sensitivity of these exact rational reference
examples and checks, not maximal parallelism, liveness, generic solvency, machine
arithmetic, or deployed protocol fidelity.
