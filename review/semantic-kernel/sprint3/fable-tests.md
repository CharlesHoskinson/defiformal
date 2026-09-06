**Verdict: revise before acceptance.** The suite is a real CLI regression suite and the log is internally consistent with it, but two gaps block using this package as acceptance evidence. Neither is a code defect in the implementation itself.

**Blockers**

- **Adjudication rule is not discriminated.** The only disagreement in the fixture is annotator a `[]` versus annotator b `['amm']`. That is a subset case with an empty intersection. The positive test only asserts the merged mechanisms list is empty. An implementation that drops all labels on disagreement, or always prefers annotator a, passes every test. The advertised properties, retained intersection and both sides of the symmetric difference recorded as unresolved, are never exercised. Fix: add a unit where a is `['exchange','lending']` and b is `['lending','amm']`, assert the facet equals `['lending']`, the rule is INTERSECTION_UNRESOLVED, and the unresolved record lists both `exchange` and `amm`. Add an order-only case, `['exchange','lending']` versus `['lending','exchange']`, and assert AGREE.

- **No evidence for the committed artifacts.** Every count in the log is the synthetic 374/1. Nothing in scope shows that `check --repo .` passes against the committed 346/29 coverage.json. The log also carries no header: no commit hash, command, Python version, or jsonschema version, so it cannot be bound to candidate 045126ef. Fix: add a read-only test that runs `check` against the parent repository's committed generated directory when present, and prefix the log with the command, commit, and interpreter and dependency versions.

**Medium, fix in this sprint if cheap**

- **Binding set asserted by count only.** The test asserts seven input bindings without naming them. Seven fits three lanes plus manifest, taxonomy, identity map and annotation input, which would mean the two annotation files and the schema are not listed. Assert the exact path set.
- **Weak diagnostic substrings.** `schema`, `units`, `source_records` and `adjudications` match many unrelated failures. The dropped-source case is caught by a hardcoded minItems, not by a provenance check. Tighten to the specific message, for example `deterministic mismatch at /units/0/legacy_id`.
- **Unexplained docs dependency.** setUp copies a research markdown file for the build to consume. If it is a bound input it should appear in the binding assertion; if not, remove the copy.
- **Exit-3 paths do not assert atomicity.** Only the exit-1 annotation cases check that the output directory was not created.

**Future work**

- Coverage counts unresolved differences per facet decision, not per label, and counts empty-versus-empty as a provisional agreement. In the synthetic run that is 374 of 375 agreements. Report label-level counts and a nonempty-agreement count so real coverage is not inflated by mutual non-evidence.
- Add a case that edits source row content with an updated manifest hash and unchanged row count, to confirm the neutral-input cross-check catches it rather than relying on the manifest.
- Cosmetic: mixed relative and absolute paths in messages, and the synthesized `/residue/length` pointer is not a real JSON pointer.

**What holds up.** Coverage arithmetic is consistent: per-facet agreements sum to 346, differences to 29, rows to 72. The suite genuinely covers missing and empty inputs, symlink and path escape, duplicate JSON keys, schema self-validation, byte-level drift of all three outputs, manifest drift, atomic build refusal, and check without regeneration. Test count and per-test temp directories in the log match the file.
